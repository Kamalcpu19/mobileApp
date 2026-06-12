const db = require('../db');

async function createOrUpdateCustomer(workshopId, data) {
  if (data.id) {
    const result = await db.query(
      `UPDATE customers SET name = $1, mobile = $2, email = $3, updated_at = NOW() WHERE id = $4 RETURNING *`,
      [data.name, data.mobile, data.email, data.id]
    );
    return result.rows[0];
  }

  const result = await db.query(
    `INSERT INTO customers (workshop_id, name, mobile, email) VALUES ($1, $2, $3, $4) RETURNING *`,
    [workshopId, data.name, data.mobile, data.email]
  );
  return result.rows[0];
}

async function getCustomer(id) {
  const result = await db.query('SELECT * FROM customers WHERE id = $1', [id]);
  return result.rows[0];
}

async function getMessages(workshopId) {
  const result = await db.query(
    `SELECT cm.*, c.name as customer_name FROM customer_messages cm
     JOIN customers c ON cm.customer_id = c.id
     WHERE cm.workshop_id = $1 ORDER BY cm.created_at DESC`,
    [workshopId]
  );
  return result.rows;
}

async function markMessageRead(messageId) {
  await db.query('UPDATE customer_messages SET is_read = TRUE WHERE id = $1', [messageId]);
}

module.exports = { createOrUpdateCustomer, getCustomer, getMessages, markMessageRead };
