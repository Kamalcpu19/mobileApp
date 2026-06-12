const db = require('../db');

async function getInspectionTemplates(workshopId, inspectionType = 'pre') {
  const result = await db.query(
    `SELECT * FROM inspection_templates WHERE workshop_id = $1 AND inspection_type = $2 ORDER BY sort_order`,
    [workshopId, inspectionType]
  );
  return result.rows;
}

async function initializeInspection(repairOrderId, workshopId, inspectionType = 'pre') {
  const templates = await getInspectionTemplates(workshopId, inspectionType);
  const items = [];

  for (const template of templates) {
    const existing = await db.query(
      `SELECT * FROM inspection_items
       WHERE repair_order_id = $1 AND template_id = $2 AND inspection_type = $3`,
      [repairOrderId, template.id, inspectionType],
    );

    if (existing.rows[0]) {
      items.push(existing.rows[0]);
      continue;
    }

    const result = await db.query(
      `INSERT INTO inspection_items (repair_order_id, template_id, category, item_name, inspection_type, status)
       OUTPUT INSERTED.*
       VALUES ($1, $2, $3, $4, $5, 'pending')`,
      [repairOrderId, template.id, template.category, template.item_name, inspectionType],
    );
    if (result.rows[0]) items.push(result.rows[0]);
  }

  if (items.length === 0) {
    const existing = await db.query(
      'SELECT * FROM inspection_items WHERE repair_order_id = $1 AND inspection_type = $2 ORDER BY created_at',
      [repairOrderId, inspectionType]
    );
    return existing.rows;
  }

  return items;
}

async function getInspectionItems(repairOrderId, inspectionType) {
  let query = 'SELECT * FROM inspection_items WHERE repair_order_id = $1';
  const params = [repairOrderId];

  if (inspectionType) {
    query += ' AND inspection_type = $2';
    params.push(inspectionType);
  }

  query += ' ORDER BY category, item_name';
  const result = await db.query(query, params);
  return result.rows;
}

async function updateInspectionItem(itemId, data) {
  const result = await db.query(
    `UPDATE inspection_items SET status = COALESCE($1, status), comment = COALESCE($2, comment),
     image_url = COALESCE($3, image_url), updated_at = NOW()
     WHERE id = $4 RETURNING *`,
    [data.status, data.comment, data.imageUrl, itemId]
  );
  return result.rows[0];
}

module.exports = {
  getInspectionTemplates,
  initializeInspection,
  getInspectionItems,
  updateInspectionItem,
};
