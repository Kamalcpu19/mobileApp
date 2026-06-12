const bcrypt = require('bcryptjs');
const db = require('./index');

async function getOrCreateWorkshop() {
  const existing = await db.query('SELECT TOP 1 id FROM workshops ORDER BY created_at');
  if (existing.rows[0]) return existing.rows[0].id;

  const result = await db.query(
    `INSERT INTO workshops (name, address, phone, email, country_code)
     OUTPUT INSERTED.id
     VALUES (@p1, @p2, @p3, @p4, @p5)`,
    ['Premium Auto Workshop', '123 Industrial Area, Mumbai', '+91-9876543210', 'info@premiumauto.com', 'IN'],
  );
  return result.rows[0].id;
}

async function seed() {
  try {
    const workshopId = await getOrCreateWorkshop();

    const existingUser = await db.query(
      'SELECT id FROM users WHERE username = @p1',
      ['advisor'],
    );

    if (!existingUser.rows[0]) {
      const passwordHash = await bcrypt.hash('password123', 10);
      await db.query(
        `INSERT INTO users (workshop_id, username, password_hash, full_name, email, phone, role)
         VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7)`,
        [workshopId, 'advisor', passwordHash, 'John Smith', 'john@premiumauto.com', '+91-9876543211', 'service_advisor'],
      );
    }

    const existingSettings = await db.query(
      'SELECT id FROM automation_settings WHERE workshop_id = @p1',
      [workshopId],
    );

    if (!existingSettings.rows[0]) {
      await db.query(
        `INSERT INTO automation_settings (workshop_id, vehicle_identification_enabled, complaints_ai_enabled, ai_quote_agent_enabled)
         VALUES (@p1, @p2, @p3, @p4)`,
        [workshopId, true, true, true],
      );
    }

    const customers = [
      ['Rajesh Kumar', '+91-9988776655', 'rajesh@email.com'],
      ['Priya Sharma', '+91-8877665544', 'priya@email.com'],
      ['Amit Patel', '+91-7766554433', 'amit@email.com'],
    ];

    const customerIds = [];
    for (const [name, mobile, email] of customers) {
      let result = await db.query(
        'SELECT id FROM customers WHERE workshop_id = @p1 AND mobile = @p2',
        [workshopId, mobile],
      );
      if (!result.rows[0]) {
        result = await db.query(
          `INSERT INTO customers (workshop_id, name, mobile, email)
           OUTPUT INSERTED.id
           VALUES (@p1, @p2, @p3, @p4)`,
          [workshopId, name, mobile, email],
        );
      }
      customerIds.push(result.rows[0].id);
    }

    const vehicles = [
      [customerIds[0], 'MH12AB1234', 'Maruti', 'Swift', 2022, 'VXI', 'White', 'MA3ERLF1S00234567', 75.5, 45000],
      [customerIds[1], 'MH14CD5678', 'Hyundai', 'Creta', 2023, 'SX', 'Black', 'MALBM51BLPM123456', 60.0, 32000],
      [customerIds[2], 'MH01EF9012', 'Tata', 'Nexon', 2021, 'XZ+', 'Blue', 'MAT632012K1A23456', 45.0, 68000],
    ];

    const vehicleIds = [];
    for (const v of vehicles) {
      let result = await db.query(
        'SELECT id FROM vehicles WHERE workshop_id = @p1 AND registration_number = @p2',
        [workshopId, v[1]],
      );
      if (!result.rows[0]) {
        result = await db.query(
          `INSERT INTO vehicles (workshop_id, customer_id, registration_number, make, model, year, variant, color, vin, fuel_level, odometer)
           OUTPUT INSERTED.id
           VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11)`,
          [workshopId, ...v],
        );
      } else {
        await db.query(
          'UPDATE vehicles SET odometer = @p1 WHERE id = @p2',
          [v[10], result.rows[0].id],
        );
      }
      vehicleIds.push(result.rows[0].id);
    }

    const advisorResult = await db.query('SELECT id FROM users WHERE username = @p1', ['advisor']);
    const advisorId = advisorResult.rows[0].id;
    const today = new Date().toISOString().split('T')[0];
    const appointmentCategories = ['AM', 'PM', 'APP', 'Call In'];

    const appointmentCount = await db.query(
      'SELECT COUNT(*) AS count FROM appointments WHERE workshop_id = @p1',
      [workshopId],
    );
    if ((appointmentCount.rows[0].count || 0) === 0) {
      for (let i = 0; i < 4; i++) {
        await db.query(
          `INSERT INTO appointments (workshop_id, customer_id, vehicle_id, advisor_id, category, appointment_date, appointment_time, status)
           VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)`,
          [workshopId, customerIds[i % customerIds.length], vehicleIds[i % vehicleIds.length], advisorId, appointmentCategories[i], today, `${9 + i}:00:00`, 'scheduled'],
        );
      }
    }

    const templateCount = await db.query(
      'SELECT COUNT(*) AS count FROM inspection_templates WHERE workshop_id = @p1',
      [workshopId],
    );
    if ((templateCount.rows[0].count || 0) === 0) {
      const inspectionItems = [
        ['Pre and Post Checks', 'Electrical wiring', 'pre'],
        ['Pre and Post Checks', 'ABS cable', 'pre'],
        ['Pre and Post Checks', 'Wheel bearing', 'pre'],
        ['Car Check In', 'Hand brake adjustment', 'pre'],
        ['Car Check In', 'Coolant system', 'pre'],
        ['Car Check In', 'Tyre pressure', 'pre'],
        ['Check In Category', 'Power steering fluid', 'pre'],
        ['Check In Category', 'Engine oil', 'pre'],
        ['Check In Category', 'Steering vibration', 'pre'],
      ];
      for (let i = 0; i < inspectionItems.length; i++) {
        await db.query(
          `INSERT INTO inspection_templates (workshop_id, category, item_name, inspection_type, sort_order)
           VALUES (@p1, @p2, @p3, @p4, @p5)`,
          [workshopId, inspectionItems[i][0], inspectionItems[i][1], inspectionItems[i][2], i],
        );
      }
    }

    const inventoryCount = await db.query(
      'SELECT COUNT(*) AS count FROM inventory WHERE workshop_id = @p1',
      [workshopId],
    );
    if ((inventoryCount.rows[0].count || 0) === 0) {
      const inventoryItems = [
        ['BRK001', 'Brake Pads Front', 'Front brake pad set', 2500, 20],
        ['OIL001', 'Engine Oil 5W30', 'Synthetic engine oil 4L', 1200, 50],
        ['FLT001', 'Air Filter', 'Engine air filter', 450, 30],
        ['SPK001', 'Spark Plugs Set', 'Iridium spark plugs x4', 1800, 15],
      ];
      for (const item of inventoryItems) {
        await db.query(
          `INSERT INTO inventory (workshop_id, part_number, name, description, unit_price, quantity_in_stock)
           VALUES (@p1, @p2, @p3, @p4, @p5, @p6)`,
          [workshopId, ...item],
        );
      }
    }

    const roExisting = await db.query(
      'SELECT TOP 1 id FROM repair_orders WHERE workshop_id = @p1 ORDER BY created_at DESC',
      [workshopId],
    );

    if (!roExisting.rows[0]) {
      const roNumber = `RO-${Date.now().toString().slice(-6)}`;
      const roResult = await db.query(
        `INSERT INTO repair_orders (workshop_id, ro_number, customer_id, vehicle_id, advisor_id, stage, vehicle_detection_status, odometer_in)
         OUTPUT INSERTED.id
         VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)`,
        [workshopId, roNumber, customerIds[0], vehicleIds[0], advisorId, 'estimation_request', 'detected', 45000],
      );

      const roId = roResult.rows[0].id;
      await db.query(
        `INSERT INTO job_cards (repair_order_id, job_card_number, status)
         VALUES (@p1, @p2, @p3)`,
        [roId, `JC-${Date.now().toString().slice(-6)}`, 'active'],
      );

      await db.query(
        `INSERT INTO complaints (repair_order_id, description, source)
         VALUES (@p1, @p2, @p3), (@p1, @p4, @p5)`,
        [roId, 'Brake squeaking noise while driving', 'manual', 'AC not cooling properly', 'manual'],
      );

      const estimateResult = await db.query(
        `INSERT INTO estimates (repair_order_id, estimate_number, status, subtotal, tax_amount, total_amount)
         OUTPUT INSERTED.id
         VALUES (@p1, @p2, @p3, @p4, @p5, @p6)`,
        [roId, `EST-${Date.now().toString().slice(-6)}`, 'pending_approval', 5500, 990, 6490],
      );

      await db.query(
        `INSERT INTO estimate_line_items (estimate_id, item_type, name, quantity, unit_price, total_price, approval_status)
         VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7)`,
        [estimateResult.rows[0].id, 'part', 'Brake Pads Front', 1, 2500, 2500, 'pending'],
      );
      await db.query(
        `INSERT INTO estimate_line_items (estimate_id, item_type, name, quantity, unit_price, total_price, approval_status)
         VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7)`,
        [estimateResult.rows[0].id, 'service', 'Brake Service', 1, 3000, 3000, 'pending'],
      );

      await db.query(
        `INSERT INTO invoices (repair_order_id, estimate_id, invoice_number, subtotal, tax_amount, total_amount, paid_amount, due_amount, due_date, status)
         VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10)`,
        [roId, estimateResult.rows[0].id, `INV-${Date.now().toString().slice(-6)}`, 5500, 990, 6490, 0, 6490, today, 'pending'],
      );

      await db.query(
        `INSERT INTO customer_messages (workshop_id, customer_id, repair_order_id, message)
         VALUES (@p1, @p2, @p3, @p4)`,
        [workshopId, customerIds[0], roId, 'When will my car be ready?'],
      );
      await db.query(
        `INSERT INTO customer_messages (workshop_id, customer_id, message)
         VALUES (@p1, @p2, @p3)`,
        [workshopId, customerIds[1], 'Can I reschedule my appointment?'],
      );
    }

    console.log('Seed data inserted successfully.');
    console.log('Login: username=advisor, password=password123');
  } catch (error) {
    console.error('Seed failed:', error.message);
    process.exit(1);
  } finally {
    await db.closePool();
  }
}

seed();
