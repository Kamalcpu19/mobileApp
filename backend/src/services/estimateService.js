const db = require('../db');
const { v4: uuidv4 } = require('uuid');

async function createEstimate(repairOrderId) {
  const estimateNumber = `EST-${Date.now().toString().slice(-8)}`;
  const result = await db.query(
    `INSERT INTO estimates (repair_order_id, estimate_number, status, approval_token)
     VALUES ($1, $2, 'draft', $3)
     RETURNING *`,
    [repairOrderId, estimateNumber, uuidv4()]
  );
  return result.rows[0];
}

async function getEstimate(repairOrderId) {
  const estimate = await db.query(
    'SELECT * FROM estimates WHERE repair_order_id = $1 ORDER BY created_at DESC LIMIT 1',
    [repairOrderId]
  );
  if (!estimate.rows[0]) return null;

  const items = await db.query(
    'SELECT * FROM estimate_line_items WHERE estimate_id = $1 ORDER BY sort_order, approval_status DESC',
    [estimate.rows[0].id]
  );

  return { ...estimate.rows[0], lineItems: items.rows };
}

async function addLineItem(estimateId, item) {
  const totalPrice = (item.quantity || 1) * (item.unitPrice || 0);
  const result = await db.query(
    `INSERT INTO estimate_line_items (estimate_id, item_type, name, description, part_number, quantity, unit_price, total_price)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING *`,
    [estimateId, item.itemType, item.name, item.description, item.partNumber, item.quantity || 1, item.unitPrice || 0, totalPrice]
  );
  await recalculateEstimate(estimateId);
  return result.rows[0];
}

async function recalculateEstimate(estimateId) {
  const items = await db.query(
    'SELECT SUM(total_price) as subtotal FROM estimate_line_items WHERE estimate_id = $1',
    [estimateId]
  );
  const subtotal = parseFloat(items.rows[0].subtotal) || 0;
  const taxAmount = subtotal * 0.18;
  const totalAmount = subtotal + taxAmount;

  await db.query(
    `UPDATE estimates SET subtotal = $1, tax_amount = $2, total_amount = $3, updated_at = NOW() WHERE id = $4`,
    [subtotal, taxAmount, totalAmount, estimateId]
  );
}

async function submitForApproval(estimateId) {
  await db.query(
    `UPDATE estimates SET status = 'pending_approval', updated_at = NOW() WHERE id = $1`,
    [estimateId]
  );
  return getEstimateById(estimateId);
}

async function getEstimateById(estimateId) {
  const estimate = await db.query('SELECT * FROM estimates WHERE id = $1', [estimateId]);
  if (!estimate.rows[0]) return null;
  const items = await db.query(
    'SELECT * FROM estimate_line_items WHERE estimate_id = $1 ORDER BY approval_status DESC, sort_order',
    [estimateId]
  );
  return { ...estimate.rows[0], lineItems: items.rows };
}

async function approveLineItem(itemId, status) {
  await db.query(
    'UPDATE estimate_line_items SET approval_status = $1 WHERE id = $2',
    [status, itemId]
  );
}

async function approveEstimate(estimateId, approvals) {
  for (const { itemId, status } of approvals) {
    await approveLineItem(itemId, status);
  }

  const allApproved = approvals.every((a) => a.status === 'approved');
  await db.query(
    `UPDATE estimates SET status = $1, approved_at = CASE WHEN $2 THEN NOW() ELSE NULL END, updated_at = NOW() WHERE id = $3`,
    [allApproved ? 'approved' : 'partially_approved', allApproved, estimateId]
  );

  return getEstimateById(estimateId);
}

async function getEstimateByToken(token) {
  const estimate = await db.query('SELECT * FROM estimates WHERE approval_token = $1', [token]);
  if (!estimate.rows[0]) return null;
  return getEstimateById(estimate.rows[0].id);
}

module.exports = {
  createEstimate,
  getEstimate,
  addLineItem,
  submitForApproval,
  getEstimateById,
  approveEstimate,
  getEstimateByToken,
};
