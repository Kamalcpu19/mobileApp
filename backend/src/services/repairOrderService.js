const db = require('../db');
const { v4: uuidv4 } = require('uuid');

const STAGES = [
  'inspection',
  'estimation_request',
  'estimate',
  'approval_pending',
  'spares_pending',
  'work_in_progress',
  'ready_for_delivery',
  'invoice',
  'delivered',
];

async function generateRoNumber() {
  return `RO-${Date.now().toString().slice(-8)}`;
}

async function createRepairOrder(workshopId, advisorId, data) {
  const roNumber = await generateRoNumber();
  const result = await db.query(
    `INSERT INTO repair_orders (workshop_id, ro_number, customer_id, vehicle_id, advisor_id, appointment_id, stage, vehicle_detection_status, odometer_in)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
     RETURNING *`,
    [
      workshopId,
      roNumber,
      data.customerId || null,
      data.vehicleId || null,
      advisorId,
      data.appointmentId || null,
      'inspection',
      data.detectionStatus || 'not_detected',
      data.odometerIn || null,
    ]
  );

  await db.query(
    `INSERT INTO stage_history (repair_order_id, to_stage, changed_by)
     VALUES ($1, $2, $3)`,
    [result.rows[0].id, 'inspection', advisorId]
  );

  return result.rows[0];
}

async function getRepairOrders(workshopId, { stage, search }) {
  let query = `
    SELECT ro.*, c.name as customer_name, c.mobile as customer_mobile,
           v.registration_number, v.make, v.model, jc.job_card_number
    FROM repair_orders ro
    LEFT JOIN customers c ON ro.customer_id = c.id
    LEFT JOIN vehicles v ON ro.vehicle_id = v.id
    LEFT JOIN job_cards jc ON ro.id = jc.repair_order_id
    WHERE ro.workshop_id = $1
  `;
  const params = [workshopId];
  let paramIndex = 2;

  if (stage) {
    query += ` AND ro.stage = $${paramIndex++}`;
    params.push(stage);
  }

  if (search) {
    query += ` AND (v.registration_number ILIKE $${paramIndex} OR c.name ILIKE $${paramIndex} OR ro.ro_number ILIKE $${paramIndex})`;
    params.push(`%${search}%`);
  }

  query += ' ORDER BY ro.updated_at DESC';
  const result = await db.query(query, params);
  return result.rows;
}

async function getRepairOrderById(id, workshopId) {
  const result = await db.query(
    `SELECT ro.*, c.name as customer_name, c.mobile as customer_mobile, c.email as customer_email,
            v.registration_number, v.make, v.model, v.year, v.variant, v.color, v.vin, v.fuel_level, v.odometer,
            jc.job_card_number, jc.status as job_card_status
     FROM repair_orders ro
     LEFT JOIN customers c ON ro.customer_id = c.id
     LEFT JOIN vehicles v ON ro.vehicle_id = v.id
     LEFT JOIN job_cards jc ON ro.id = jc.repair_order_id
     WHERE ro.id = $1 AND ro.workshop_id = $2`,
    [id, workshopId]
  );
  return result.rows[0];
}

async function updateStage(repairOrderId, newStage, userId, notes) {
  const current = await db.query('SELECT stage FROM repair_orders WHERE id = $1', [repairOrderId]);
  const fromStage = current.rows[0]?.stage;

  await db.query(
    `UPDATE repair_orders SET stage = $1, updated_at = NOW() WHERE id = $2`,
    [newStage, repairOrderId]
  );

  await db.query(
    `INSERT INTO stage_history (repair_order_id, from_stage, to_stage, changed_by, notes)
     VALUES ($1, $2, $3, $4, $5)`,
    [repairOrderId, fromStage, newStage, userId, notes]
  );

  return getRepairOrderById(repairOrderId);
}

async function getStageHistory(repairOrderId) {
  const result = await db.query(
    `SELECT sh.*, u.full_name as changed_by_name
     FROM stage_history sh
     LEFT JOIN users u ON sh.changed_by = u.id
     WHERE sh.repair_order_id = $1
     ORDER BY sh.created_at ASC`,
    [repairOrderId]
  );
  return result.rows;
}

async function closeJobCard(repairOrderId, data, userId) {
  await db.query(
    `UPDATE repair_orders SET odometer_out = $1, next_service_reminder = $2, stage = 'delivered', updated_at = NOW()
     WHERE id = $3`,
    [data.odometerOut, data.nextServiceReminder, repairOrderId]
  );

  await db.query(
    `UPDATE job_cards SET status = 'closed', updated_at = NOW() WHERE repair_order_id = $1`,
    [repairOrderId]
  );

  return updateStage(repairOrderId, 'delivered', userId, 'Job card closed');
}

module.exports = {
  STAGES,
  createRepairOrder,
  getRepairOrders,
  getRepairOrderById,
  updateStage,
  getStageHistory,
  closeJobCard,
};
