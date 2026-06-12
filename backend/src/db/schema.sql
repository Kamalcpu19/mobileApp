-- Workshop Service Advisor Database Schema (SQL Server)

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = DB_NAME())
BEGIN
  RAISERROR('Database must exist before running migration. Create database workshop_advisor first.', 16, 1);
END
GO

IF OBJECT_ID('stage_history', 'U') IS NOT NULL DROP TABLE stage_history;
IF OBJECT_ID('payments', 'U') IS NOT NULL DROP TABLE payments;
IF OBJECT_ID('customer_messages', 'U') IS NOT NULL DROP TABLE customer_messages;
IF OBJECT_ID('service_history', 'U') IS NOT NULL DROP TABLE service_history;
IF OBJECT_ID('inventory', 'U') IS NOT NULL DROP TABLE inventory;
IF OBJECT_ID('spares', 'U') IS NOT NULL DROP TABLE spares;
IF OBJECT_ID('estimate_line_items', 'U') IS NOT NULL DROP TABLE estimate_line_items;
IF OBJECT_ID('estimates', 'U') IS NOT NULL DROP TABLE estimates;
IF OBJECT_ID('ai_recommendations', 'U') IS NOT NULL DROP TABLE ai_recommendations;
IF OBJECT_ID('complaints', 'U') IS NOT NULL DROP TABLE complaints;
IF OBJECT_ID('inspection_items', 'U') IS NOT NULL DROP TABLE inspection_items;
IF OBJECT_ID('inspection_templates', 'U') IS NOT NULL DROP TABLE inspection_templates;
IF OBJECT_ID('job_cards', 'U') IS NOT NULL DROP TABLE job_cards;
IF OBJECT_ID('invoices', 'U') IS NOT NULL DROP TABLE invoices;
IF OBJECT_ID('vehicle_images', 'U') IS NOT NULL DROP TABLE vehicle_images;
IF OBJECT_ID('repair_orders', 'U') IS NOT NULL DROP TABLE repair_orders;
IF OBJECT_ID('appointments', 'U') IS NOT NULL DROP TABLE appointments;
IF OBJECT_ID('vehicles', 'U') IS NOT NULL DROP TABLE vehicles;
IF OBJECT_ID('customers', 'U') IS NOT NULL DROP TABLE customers;
IF OBJECT_ID('automation_settings', 'U') IS NOT NULL DROP TABLE automation_settings;
IF OBJECT_ID('users', 'U') IS NOT NULL DROP TABLE users;
IF OBJECT_ID('workshops', 'U') IS NOT NULL DROP TABLE workshops;

CREATE TABLE workshops (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name NVARCHAR(255) NOT NULL,
    address NVARCHAR(MAX),
    phone NVARCHAR(20),
    email NVARCHAR(255),
    logo_url NVARCHAR(MAX),
    country_code NVARCHAR(5) DEFAULT 'IN',
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE users (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workshop_id UNIQUEIDENTIFIER REFERENCES workshops(id) ON DELETE NO ACTION,
    username NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    full_name NVARCHAR(255) NOT NULL,
    email NVARCHAR(255),
    phone NVARCHAR(20),
    role NVARCHAR(50) DEFAULT 'service_advisor',
    avatar_url NVARCHAR(MAX),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE automation_settings (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workshop_id UNIQUEIDENTIFIER UNIQUE REFERENCES workshops(id) ON DELETE NO ACTION,
    vehicle_identification_enabled BIT DEFAULT 1,
    complaints_ai_enabled BIT DEFAULT 1,
    ai_quote_agent_enabled BIT DEFAULT 1,
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE customers (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workshop_id UNIQUEIDENTIFIER REFERENCES workshops(id) ON DELETE NO ACTION,
    name NVARCHAR(255) NOT NULL,
    mobile NVARCHAR(20) NOT NULL,
    email NVARCHAR(255),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE vehicles (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workshop_id UNIQUEIDENTIFIER REFERENCES workshops(id) ON DELETE NO ACTION,
    customer_id UNIQUEIDENTIFIER REFERENCES customers(id) ON DELETE NO ACTION,
    registration_number NVARCHAR(20) NOT NULL,
    make NVARCHAR(100),
    model NVARCHAR(100),
    year INT,
    variant NVARCHAR(100),
    color NVARCHAR(50),
    vin NVARCHAR(50),
    fuel_level DECIMAL(5,2),
    odometer INT,
    avg_km_per_day INT,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_vehicles_workshop_reg UNIQUE (workshop_id, registration_number)
);

CREATE TABLE vehicle_images (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    vehicle_id UNIQUEIDENTIFIER REFERENCES vehicles(id) ON DELETE NO ACTION,
    image_type NVARCHAR(50) NOT NULL,
    image_url NVARCHAR(MAX) NOT NULL,
    created_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE appointments (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workshop_id UNIQUEIDENTIFIER REFERENCES workshops(id) ON DELETE NO ACTION,
    customer_id UNIQUEIDENTIFIER REFERENCES customers(id) ON DELETE NO ACTION,
    vehicle_id UNIQUEIDENTIFIER REFERENCES vehicles(id) ON DELETE NO ACTION,
    advisor_id UNIQUEIDENTIFIER REFERENCES users(id) ON DELETE NO ACTION,
    category NVARCHAR(20) NOT NULL DEFAULT 'AM',
    appointment_date DATE NOT NULL,
    appointment_time TIME,
    status NVARCHAR(50) DEFAULT 'scheduled',
    notes NVARCHAR(MAX),
    is_auto_reminder BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE repair_orders (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workshop_id UNIQUEIDENTIFIER REFERENCES workshops(id) ON DELETE NO ACTION,
    ro_number NVARCHAR(50) NOT NULL UNIQUE,
    customer_id UNIQUEIDENTIFIER REFERENCES customers(id) ON DELETE NO ACTION,
    vehicle_id UNIQUEIDENTIFIER REFERENCES vehicles(id) ON DELETE NO ACTION,
    advisor_id UNIQUEIDENTIFIER REFERENCES users(id) ON DELETE NO ACTION,
    appointment_id UNIQUEIDENTIFIER REFERENCES appointments(id) ON DELETE NO ACTION,
    stage NVARCHAR(50) DEFAULT 'inspection',
    vehicle_detection_status NVARCHAR(20) DEFAULT 'not_detected',
    odometer_in INT,
    odometer_out INT,
    next_service_reminder DATE,
    notes NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE inspection_templates (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workshop_id UNIQUEIDENTIFIER REFERENCES workshops(id) ON DELETE NO ACTION,
    category NVARCHAR(100) NOT NULL,
    item_name NVARCHAR(255) NOT NULL,
    inspection_type NVARCHAR(50) DEFAULT 'pre',
    sort_order INT DEFAULT 0
);

CREATE TABLE inspection_items (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repair_order_id UNIQUEIDENTIFIER REFERENCES repair_orders(id) ON DELETE NO ACTION,
    template_id UNIQUEIDENTIFIER REFERENCES inspection_templates(id) ON DELETE NO ACTION,
    category NVARCHAR(100),
    item_name NVARCHAR(255) NOT NULL,
    status NVARCHAR(20) DEFAULT 'pending',
    comment NVARCHAR(MAX),
    image_url NVARCHAR(MAX),
    inspection_type NVARCHAR(50) DEFAULT 'pre',
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE complaints (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repair_order_id UNIQUEIDENTIFIER REFERENCES repair_orders(id) ON DELETE NO ACTION,
    description NVARCHAR(MAX) NOT NULL,
    source NVARCHAR(20) DEFAULT 'manual',
    status NVARCHAR(50) DEFAULT 'open',
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE ai_recommendations (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repair_order_id UNIQUEIDENTIFIER REFERENCES repair_orders(id) ON DELETE NO ACTION,
    recommendation_type NVARCHAR(50) NOT NULL,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    is_selected BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE job_cards (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repair_order_id UNIQUEIDENTIFIER UNIQUE REFERENCES repair_orders(id) ON DELETE NO ACTION,
    job_card_number NVARCHAR(50) NOT NULL UNIQUE,
    status NVARCHAR(50) DEFAULT 'active',
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE estimates (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repair_order_id UNIQUEIDENTIFIER REFERENCES repair_orders(id) ON DELETE NO ACTION,
    estimate_number NVARCHAR(50) NOT NULL UNIQUE,
    status NVARCHAR(50) DEFAULT 'draft',
    subtotal DECIMAL(12,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0,
    approval_token NVARCHAR(255),
    approved_at DATETIME2,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE estimate_line_items (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    estimate_id UNIQUEIDENTIFIER REFERENCES estimates(id) ON DELETE NO ACTION,
    item_type NVARCHAR(20) NOT NULL,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    part_number NVARCHAR(100),
    quantity DECIMAL(10,2) DEFAULT 1,
    unit_price DECIMAL(12,2) DEFAULT 0,
    total_price DECIMAL(12,2) DEFAULT 0,
    approval_status NVARCHAR(20) DEFAULT 'pending',
    sort_order INT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE spares (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repair_order_id UNIQUEIDENTIFIER REFERENCES repair_orders(id) ON DELETE NO ACTION,
    part_name NVARCHAR(255) NOT NULL,
    part_number NVARCHAR(100),
    quantity DECIMAL(10,2) DEFAULT 1,
    status NVARCHAR(50) DEFAULT 'pending',
    issued_at DATETIME2,
    created_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE invoices (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repair_order_id UNIQUEIDENTIFIER REFERENCES repair_orders(id) ON DELETE NO ACTION,
    estimate_id UNIQUEIDENTIFIER REFERENCES estimates(id) ON DELETE NO ACTION,
    invoice_number NVARCHAR(50) NOT NULL UNIQUE,
    subtotal DECIMAL(12,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0,
    paid_amount DECIMAL(12,2) DEFAULT 0,
    due_amount DECIMAL(12,2) DEFAULT 0,
    due_date DATE,
    status NVARCHAR(50) DEFAULT 'pending',
    pdf_url NVARCHAR(MAX),
    payment_link NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE payments (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    invoice_id UNIQUEIDENTIFIER REFERENCES invoices(id) ON DELETE NO ACTION,
    amount DECIMAL(12,2) NOT NULL,
    payment_method NVARCHAR(50),
    transaction_id NVARCHAR(255),
    status NVARCHAR(50) DEFAULT 'completed',
    paid_at DATETIME2 DEFAULT GETUTCDATE(),
    created_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE customer_messages (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workshop_id UNIQUEIDENTIFIER REFERENCES workshops(id) ON DELETE NO ACTION,
    customer_id UNIQUEIDENTIFIER REFERENCES customers(id) ON DELETE NO ACTION,
    repair_order_id UNIQUEIDENTIFIER REFERENCES repair_orders(id) ON DELETE NO ACTION,
    message NVARCHAR(MAX) NOT NULL,
    is_read BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE service_history (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    vehicle_id UNIQUEIDENTIFIER REFERENCES vehicles(id) ON DELETE NO ACTION,
    repair_order_id UNIQUEIDENTIFIER REFERENCES repair_orders(id) ON DELETE NO ACTION,
    service_date DATE NOT NULL,
    odometer INT,
    description NVARCHAR(MAX),
    total_amount DECIMAL(12,2),
    created_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE stage_history (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    repair_order_id UNIQUEIDENTIFIER REFERENCES repair_orders(id) ON DELETE NO ACTION,
    from_stage NVARCHAR(50),
    to_stage NVARCHAR(50) NOT NULL,
    changed_by UNIQUEIDENTIFIER REFERENCES users(id) ON DELETE NO ACTION,
    notes NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE inventory (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    workshop_id UNIQUEIDENTIFIER REFERENCES workshops(id) ON DELETE NO ACTION,
    part_number NVARCHAR(100),
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    unit_price DECIMAL(12,2) DEFAULT 0,
    quantity_in_stock DECIMAL(10,2) DEFAULT 0,
    created_at DATETIME2 DEFAULT GETUTCDATE()
);

CREATE INDEX idx_repair_orders_stage ON repair_orders(stage);
CREATE INDEX idx_repair_orders_workshop ON repair_orders(workshop_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_vehicles_registration ON vehicles(registration_number);
