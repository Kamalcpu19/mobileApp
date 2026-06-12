const db = require('../db');

async function getDashboardCounts(workshopId) {
  const today = new Date().toISOString().split('T')[0];

  const [messages, appointments, attention, payments] = await Promise.all([
    db.query(
      `SELECT COUNT(*) AS count FROM customer_messages WHERE workshop_id = $1 AND is_read = 0`,
      [workshopId]
    ),
    db.query(
      `SELECT COUNT(*) AS count FROM appointments WHERE workshop_id = $1 AND appointment_date = $2 AND status = 'scheduled'`,
      [workshopId, today]
    ),
    db.query(
      `SELECT COUNT(*) AS count FROM repair_orders WHERE workshop_id = $1 AND stage NOT IN ('delivered', 'inspection')`,
      [workshopId]
    ),
    db.query(
      `SELECT COUNT(*) AS count FROM invoices i
       JOIN repair_orders ro ON i.repair_order_id = ro.id
       WHERE ro.workshop_id = $1 AND i.status = 'pending' AND i.due_amount > 0`,
      [workshopId]
    ),
  ]);

  return {
    customerMessages: parseInt(messages.rows[0].count, 10),
    todaysAppointments: parseInt(appointments.rows[0].count, 10),
    vehicleAttention: parseInt(attention.rows[0].count, 10),
    pendingPayments: parseInt(payments.rows[0].count, 10),
  };
}

module.exports = { getDashboardCounts };
