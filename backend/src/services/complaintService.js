const db = require('../db');

async function getComplaints(repairOrderId) {
  const result = await db.query(
    'SELECT * FROM complaints WHERE repair_order_id = $1 ORDER BY created_at DESC',
    [repairOrderId]
  );
  return result.rows;
}

async function addComplaint(repairOrderId, description, source = 'manual') {
  const result = await db.query(
    `INSERT INTO complaints (repair_order_id, description, source) VALUES ($1, $2, $3) RETURNING *`,
    [repairOrderId, description, source]
  );
  return result.rows[0];
}

async function updateComplaintStatus(complaintId, status) {
  const result = await db.query(
    `UPDATE complaints SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *`,
    [status, complaintId]
  );
  return result.rows[0];
}

module.exports = { getComplaints, addComplaint, updateComplaintStatus };
