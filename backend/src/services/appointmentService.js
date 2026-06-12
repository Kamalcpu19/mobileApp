const db = require('../db');

async function getAppointments(workshopId, { category, search, date }) {
  let query = `
    SELECT a.*, c.name as customer_name, c.mobile as customer_mobile, c.email as customer_email,
           v.registration_number, v.make, v.model
    FROM appointments a
    LEFT JOIN customers c ON a.customer_id = c.id
    LEFT JOIN vehicles v ON a.vehicle_id = v.id
    WHERE a.workshop_id = $1
  `;
  const params = [workshopId];
  let paramIndex = 2;

  if (date) {
    query += ` AND a.appointment_date = $${paramIndex++}`;
    params.push(date);
  }

  if (category && category !== 'All') {
    if (category === 'Auto Reminder') {
      query += ` AND a.is_auto_reminder = TRUE`;
    } else {
      query += ` AND a.category = $${paramIndex++}`;
      params.push(category);
    }
  }

  if (search) {
    query += ` AND (c.name ILIKE $${paramIndex} OR v.registration_number ILIKE $${paramIndex} OR c.mobile ILIKE $${paramIndex})`;
    params.push(`%${search}%`);
    paramIndex++;
  }

  query += ' ORDER BY a.appointment_time ASC';
  const result = await db.query(query, params);
  return result.rows;
}

async function getAppointmentById(id, workshopId) {
  const result = await db.query(
    `SELECT a.*, c.name as customer_name, c.mobile as customer_mobile, c.email as customer_email,
            v.registration_number, v.make, v.model, v.year, v.color
     FROM appointments a
     LEFT JOIN customers c ON a.customer_id = c.id
     LEFT JOIN vehicles v ON a.vehicle_id = v.id
     WHERE a.id = $1 AND a.workshop_id = $2`,
    [id, workshopId]
  );
  return result.rows[0];
}

module.exports = { getAppointments, getAppointmentById };
