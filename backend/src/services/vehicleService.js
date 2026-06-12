const db = require('../db');

async function lookupVehicle(workshopId, registrationNumber) {
  const result = await db.query(
    `SELECT v.*, c.name as customer_name, c.mobile as customer_mobile, c.email as customer_email, c.id as customer_id
     FROM vehicles v
     LEFT JOIN customers c ON v.customer_id = c.id
     WHERE v.workshop_id = $1 AND v.registration_number ILIKE $2`,
    [workshopId, registrationNumber]
  );
  return result.rows[0];
}

async function createOrUpdateVehicle(workshopId, data) {
  const existing = await lookupVehicle(workshopId, data.registrationNumber);

  if (existing) {
    const result = await db.query(
      `UPDATE vehicles SET make = COALESCE($1, make), model = COALESCE($2, model), year = COALESCE($3, year),
       variant = COALESCE($4, variant), color = COALESCE($5, color), vin = COALESCE($6, vin),
       fuel_level = COALESCE($7, fuel_level), odometer = COALESCE($8, odometer),
       avg_km_per_day = COALESCE($9, avg_km_per_day), customer_id = COALESCE($10, customer_id), updated_at = NOW()
       WHERE id = $11 RETURNING *`,
      [data.make, data.model, data.year, data.variant, data.color, data.vin, data.fuelLevel, data.odometer, data.avgKmPerDay, data.customerId, existing.id]
    );
    return result.rows[0];
  }

  const result = await db.query(
    `INSERT INTO vehicles (workshop_id, customer_id, registration_number, make, model, year, variant, color, vin, fuel_level, odometer, avg_km_per_day)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
     RETURNING *`,
    [workshopId, data.customerId, data.registrationNumber, data.make, data.model, data.year, data.variant, data.color, data.vin, data.fuelLevel, data.odometer, data.avgKmPerDay]
  );
  return result.rows[0];
}

async function getServiceHistory(vehicleId) {
  const [history, invoices, repairs] = await Promise.all([
    db.query(
      `SELECT * FROM service_history WHERE vehicle_id = $1 ORDER BY service_date DESC LIMIT 10`,
      [vehicleId]
    ),
    db.query(
      `SELECT i.* FROM invoices i
       JOIN repair_orders ro ON i.repair_order_id = ro.id
       WHERE ro.vehicle_id = $1 ORDER BY i.created_at DESC LIMIT 10`,
      [vehicleId]
    ),
    db.query(
      `SELECT ro.ro_number, ro.stage, ro.created_at,
              STRING_AGG(c.description, ', ') WITHIN GROUP (ORDER BY c.created_at) AS complaints
       FROM repair_orders ro
       LEFT JOIN complaints c ON ro.id = c.repair_order_id
       WHERE ro.vehicle_id = $1
       GROUP BY ro.id, ro.ro_number, ro.stage, ro.created_at
       ORDER BY ro.created_at DESC
       OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY`,
      [vehicleId]
    ),
  ]);

  return {
    serviceHistory: history.rows,
    previousInvoices: invoices.rows,
    previousRepairs: repairs.rows,
  };
}

async function saveVehicleImage(vehicleId, imageType, imageUrl) {
  const existing = await db.query(
    'SELECT id FROM vehicle_images WHERE vehicle_id = $1 AND image_type = $2',
    [vehicleId, imageType],
  );
  if (existing.rows[0]) return;

  await db.query(
    'INSERT INTO vehicle_images (vehicle_id, image_type, image_url) VALUES ($1, $2, $3)',
    [vehicleId, imageType, imageUrl],
  );
}

async function getVehicleImages(vehicleId) {
  const result = await db.query(
    'SELECT * FROM vehicle_images WHERE vehicle_id = $1 ORDER BY created_at',
    [vehicleId]
  );
  return result.rows;
}

module.exports = {
  lookupVehicle,
  createOrUpdateVehicle,
  getServiceHistory,
  saveVehicleImage,
  getVehicleImages,
};
