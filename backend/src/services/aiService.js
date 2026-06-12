const OpenAI = require('openai');
const config = require('../config');
const db = require('../db');

let openai = null;
if (config.openai.apiKey) {
  openai = new OpenAI({ apiKey: config.openai.apiKey });
}

async function getAutomationSettings(workshopId) {
  const result = await db.query(
    'SELECT * FROM automation_settings WHERE workshop_id = $1',
    [workshopId]
  );
  return result.rows[0] || {
    vehicle_identification_enabled: true,
    complaints_ai_enabled: true,
    ai_quote_agent_enabled: true,
  };
}

async function analyzeComplaints(repairOrderId, workshopId) {
  const settings = await getAutomationSettings(workshopId);
  if (!settings.complaints_ai_enabled) {
    return { enabled: false, recommendations: [] };
  }

  const complaints = await db.query(
    'SELECT description FROM complaints WHERE repair_order_id = $1',
    [repairOrderId]
  );

  const inspection = await db.query(
    `SELECT item_name, status FROM inspection_items WHERE repair_order_id = $1 AND status IN ('action_required', 'urgent', 'concern')`,
    [repairOrderId]
  );

  const complaintText = complaints.rows.map((c) => c.description).join('; ');
  const inspectionText = inspection.rows.map((i) => `${i.item_name}: ${i.status}`).join('; ');

  const recommendations = await generateRecommendations(complaintText, inspectionText, 'complaint');

  for (const rec of recommendations) {
    await db.query(
      `INSERT INTO ai_recommendations (repair_order_id, recommendation_type, title, description)
       VALUES ($1, $2, $3, $4)`,
      [repairOrderId, rec.type, rec.title, rec.description]
    );
  }

  return { enabled: true, recommendations };
}

async function generateEstimate(repairOrderId, workshopId) {
  const settings = await getAutomationSettings(workshopId);
  if (!settings.ai_quote_agent_enabled) {
    return { enabled: false, items: [] };
  }

  const [complaints, inspection, inventory] = await Promise.all([
    db.query('SELECT description FROM complaints WHERE repair_order_id = $1', [repairOrderId]),
    db.query(`SELECT item_name, status FROM inspection_items WHERE repair_order_id = $1`, [repairOrderId]),
    db.query('SELECT name, part_number, unit_price FROM inventory WHERE workshop_id = $1 LIMIT 20', [workshopId]),
  ]);

  const context = {
    complaints: complaints.rows.map((c) => c.description).join('; '),
    inspection: inspection.rows.map((i) => `${i.item_name}: ${i.status}`).join('; '),
    inventory: inventory.rows,
  };

  const items = await generateEstimateItems(context);
  return { enabled: true, items };
}

async function generateRecommendations(complaints, inspection, type) {
  if (!openai) {
    return getFallbackRecommendations(complaints, type);
  }

  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: `You are an automotive service advisor AI. Analyze complaints and inspection findings.
          Return JSON array with objects: { "type": "service|part|checklist", "title": string, "description": string }`,
        },
        {
          role: 'user',
          content: `Complaints: ${complaints}\nInspection findings: ${inspection}`,
        },
      ],
      response_format: { type: 'json_object' },
    });

    const parsed = JSON.parse(response.choices[0].message.content);
    return parsed.recommendations || parsed.items || [];
  } catch {
    return getFallbackRecommendations(complaints, type);
  }
}

async function generateEstimateItems(context) {
  if (!openai) {
    return getFallbackEstimateItems(context);
  }

  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: `You are an automotive estimate AI. Generate estimate line items.
          Return JSON: { "items": [{ "itemType": "part|service|labor", "name": string, "description": string, "quantity": number, "unitPrice": number }] }`,
        },
        {
          role: 'user',
          content: JSON.stringify(context),
        },
      ],
      response_format: { type: 'json_object' },
    });

    const parsed = JSON.parse(response.choices[0].message.content);
    return parsed.items || [];
  } catch {
    return getFallbackEstimateItems(context);
  }
}

function getFallbackRecommendations(complaints, type) {
  const lower = (complaints || '').toLowerCase();
  const recs = [];

  if (lower.includes('brake')) {
    recs.push({ type: 'service', title: 'Brake System Inspection', description: 'Complete brake system check and pad replacement if needed' });
    recs.push({ type: 'part', title: 'Brake Pads Front', description: 'Replace front brake pads' });
  }
  if (lower.includes('ac') || lower.includes('cooling')) {
    recs.push({ type: 'service', title: 'AC System Service', description: 'AC gas refill and compressor check' });
    recs.push({ type: 'checklist', title: 'Coolant System Check', description: 'Verify coolant levels and radiator condition' });
  }
  if (recs.length === 0) {
    recs.push({ type: 'service', title: 'General Diagnostic', description: 'Comprehensive vehicle diagnostic scan' });
    recs.push({ type: 'checklist', title: 'Multi-point Inspection', description: 'Standard multi-point vehicle inspection' });
  }
  return recs;
}

function getFallbackEstimateItems(context) {
  return [
    { itemType: 'service', name: 'Diagnostic Service', description: 'Vehicle diagnostic and troubleshooting', quantity: 1, unitPrice: 1500 },
    { itemType: 'part', name: 'Consumables', description: 'General consumables and fluids', quantity: 1, unitPrice: 500 },
    { itemType: 'labor', name: 'Labor Charges', description: 'Standard labor charges', quantity: 2, unitPrice: 800 },
  ];
}

async function getRecommendations(repairOrderId) {
  const result = await db.query(
    'SELECT * FROM ai_recommendations WHERE repair_order_id = $1 ORDER BY created_at',
    [repairOrderId]
  );
  return result.rows;
}

async function selectRecommendation(recommendationId, isSelected) {
  const result = await db.query(
    'UPDATE ai_recommendations SET is_selected = $1 WHERE id = $2 RETURNING *',
    [isSelected, recommendationId]
  );
  return result.rows[0];
}

async function generatePaymentReminder(type, customerName, amount, dueDate) {
  const templates = {
    friendly: `Hi ${customerName}, this is a friendly reminder that your payment of ₹${amount} is due on ${dueDate}. Thank you!`,
    due_today: `Dear ${customerName}, your payment of ₹${amount} is due today. Please arrange payment at your earliest convenience.`,
    overdue: `Dear ${customerName}, your payment of ₹${amount} was due on ${dueDate} and is now overdue. Please contact us to settle.`,
    final: `Final Notice: ${customerName}, your outstanding balance of ₹${amount} requires immediate attention. Please contact us today.`,
  };
  return templates[type] || templates.friendly;
}

async function recognizeNumberPlate(imageBase64) {
  if (!openai) {
    return { detected: false, registrationNumber: null };
  }

  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: 'Extract the vehicle registration/license plate number from this image. Return JSON: { "detected": boolean, "registrationNumber": string|null }' },
            { type: 'image_url', image_url: { url: `data:image/jpeg;base64,${imageBase64}` } },
          ],
        },
      ],
      response_format: { type: 'json_object' },
    });
    return JSON.parse(response.choices[0].message.content);
  } catch {
    return { detected: false, registrationNumber: null };
  }
}

module.exports = {
  getAutomationSettings,
  analyzeComplaints,
  generateEstimate,
  getRecommendations,
  selectRecommendation,
  generatePaymentReminder,
  recognizeNumberPlate,
};
