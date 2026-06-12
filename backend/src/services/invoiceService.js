const db = require('../db');
const { v4: uuidv4 } = require('uuid');

async function createJobCard(repairOrderId) {
  const existing = await db.query(
    'SELECT * FROM job_cards WHERE repair_order_id = $1',
    [repairOrderId],
  );

  let jobCard;
  if (existing.rows[0]) {
    const updated = await db.query(
      `UPDATE job_cards SET status = 'active', updated_at = NOW()
       OUTPUT INSERTED.*
       WHERE repair_order_id = $1`,
      [repairOrderId],
    );
    jobCard = updated.rows[0];
  } else {
    const jobCardNumber = `JC-${Date.now().toString().slice(-8)}`;
    const result = await db.query(
      `INSERT INTO job_cards (repair_order_id, job_card_number, status)
       OUTPUT INSERTED.*
       VALUES ($1, $2, 'active')`,
      [repairOrderId, jobCardNumber],
    );
    jobCard = result.rows[0];
  }

  await db.query(
    `UPDATE repair_orders SET stage = 'estimation_request', updated_at = NOW() WHERE id = $1`,
    [repairOrderId],
  );

  return jobCard;
}

async function getJobCard(repairOrderId) {
  const result = await db.query(
    'SELECT * FROM job_cards WHERE repair_order_id = $1',
    [repairOrderId]
  );
  return result.rows[0];
}

async function generateInvoice(repairOrderId) {
  const estimate = await db.query(
    `SELECT * FROM estimates WHERE repair_order_id = $1 AND status IN ('approved', 'partially_approved') ORDER BY created_at DESC LIMIT 1`,
    [repairOrderId]
  );

  const invoiceNumber = `INV-${Date.now().toString().slice(-8)}`;
  const subtotal = estimate.rows[0]?.subtotal || 0;
  const taxAmount = estimate.rows[0]?.tax_amount || 0;
  const totalAmount = estimate.rows[0]?.total_amount || 0;
  const dueDate = new Date();
  dueDate.setDate(dueDate.getDate() + 15);

  const result = await db.query(
    `INSERT INTO invoices (repair_order_id, estimate_id, invoice_number, subtotal, tax_amount, total_amount, due_amount, due_date, status, payment_link)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'pending', $9)
     RETURNING *`,
    [repairOrderId, estimate.rows[0]?.id, invoiceNumber, subtotal, taxAmount, totalAmount, totalAmount, dueDate.toISOString().split('T')[0], `https://pay.workshop.com/${uuidv4()}`]
  );

  await db.query(
    `UPDATE repair_orders SET stage = 'invoice', updated_at = NOW() WHERE id = $1`,
    [repairOrderId]
  );

  return result.rows[0];
}

async function getInvoice(repairOrderId) {
  const result = await db.query(
    'SELECT * FROM invoices WHERE repair_order_id = $1 ORDER BY created_at DESC LIMIT 1',
    [repairOrderId]
  );
  return result.rows[0];
}

async function getPendingPayments(workshopId) {
  const result = await db.query(
    `SELECT i.*, c.name as customer_name, c.mobile as customer_mobile, c.email as customer_email,
            v.registration_number, ro.ro_number, jc.job_card_number
     FROM invoices i
     JOIN repair_orders ro ON i.repair_order_id = ro.id
     JOIN customers c ON ro.customer_id = c.id
     JOIN vehicles v ON ro.vehicle_id = v.id
     LEFT JOIN job_cards jc ON ro.id = jc.repair_order_id
     WHERE ro.workshop_id = $1 AND i.status = 'pending' AND i.due_amount > 0
     ORDER BY i.due_date ASC`,
    [workshopId]
  );
  return result.rows;
}

async function recordPayment(invoiceId, amount, method) {
  await db.query(
    `INSERT INTO payments (invoice_id, amount, payment_method) VALUES ($1, $2, $3)`,
    [invoiceId, amount, method]
  );

  const invoice = await db.query('SELECT * FROM invoices WHERE id = $1', [invoiceId]);
  const paidAmount = parseFloat(invoice.rows[0].paid_amount) + parseFloat(amount);
  const dueAmount = parseFloat(invoice.rows[0].total_amount) - paidAmount;
  const status = dueAmount <= 0 ? 'paid' : 'partial';

  await db.query(
    `UPDATE invoices SET paid_amount = $1, due_amount = $2, status = $3, updated_at = NOW() WHERE id = $4`,
    [paidAmount, Math.max(0, dueAmount), status, invoiceId]
  );

  return db.query('SELECT * FROM invoices WHERE id = $1', [invoiceId]).then((r) => r.rows[0]);
}

module.exports = {
  createJobCard,
  getJobCard,
  generateInvoice,
  getInvoice,
  getPendingPayments,
  recordPayment,
};
