-- ============================================================
-- TechWorld Electronics — Capstone Data Analytics Database
-- PostgreSQL Database Setup Script
-- ============================================================
/*
This script creates and populates a full transactional database for TechWorld, a consumer electronics 
company operating across multiple regions. Designed for analytics projects covering:
• Customer segmentation & lifetime value
• Product performance & category analysis
• Sales trend analysis (seasonal, regional, channel)
• Employee productivity & commission tracking
• Order fulfillment & return rate analysis
*/
-- ============================================================

SET client_encoding = 'UTF8';

-- Clean up existing objects (views are dropped automatically via CASCADE)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

-- ============================================================
-- 1. EMPLOYEES
-- ============================================================
CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(120) UNIQUE NOT NULL,
    phone           VARCHAR(20),
    hire_date       DATE NOT NULL,
    job_title       VARCHAR(80) NOT NULL,
    department      VARCHAR(50) NOT NULL,
    salary          NUMERIC(12,2) NOT NULL CHECK (salary > 0),
    commission_pct  NUMERIC(4,2) DEFAULT 0.00 CHECK (commission_pct >= 0 AND commission_pct <= 0.25),
    manager_id      INT REFERENCES employees(employee_id),
    region          VARCHAR(40) NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- 2. CUSTOMERS
-- ============================================================
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(120) UNIQUE NOT NULL,
    phone           VARCHAR(20),
    date_of_birth   DATE,
    gender          VARCHAR(20) CHECK (gender IN ('Male','Female','Non-Binary','Prefer Not to Say')),
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    customer_segment VARCHAR(20) NOT NULL CHECK (customer_segment IN ('Regular','Premium','Enterprise')),
    city            VARCHAR(60) NOT NULL,
    state_province  VARCHAR(60),
    country         VARCHAR(60) NOT NULL,
    postal_code     VARCHAR(15),
    loyalty_points  INT DEFAULT 0 CHECK (loyalty_points >= 0),
    preferred_channel VARCHAR(20) CHECK (preferred_channel IN ('Online','In-Store','Phone','Mobile App')),
    is_active       BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- 3. PRODUCTS
-- ============================================================
CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(120) NOT NULL,
    sku             VARCHAR(30) UNIQUE NOT NULL,
    category        VARCHAR(40) NOT NULL,
    sub_category    VARCHAR(40),
    brand           VARCHAR(60) NOT NULL,
    unit_cost       NUMERIC(10,2) NOT NULL CHECK (unit_cost > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    weight_kg       NUMERIC(6,2),
    warranty_months INT DEFAULT 12 CHECK (warranty_months >= 0),
    launch_date     DATE,
    is_discontinued BOOLEAN DEFAULT FALSE,
    stock_quantity  INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reorder_level   INT DEFAULT 10,
    supplier_name   VARCHAR(80),
    rating          NUMERIC(2,1) CHECK (rating >= 1.0 AND rating <= 5.0),
    CONSTRAINT chk_price_gt_cost CHECK (unit_price >= unit_cost)
);

-- ============================================================
-- 4. ORDERS
-- ============================================================
CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    employee_id     INT REFERENCES employees(employee_id),
    order_date      TIMESTAMP NOT NULL DEFAULT NOW(),
    required_date   DATE,
    shipped_date    DATE,
    order_status    VARCHAR(20) NOT NULL CHECK (order_status IN ('Pending','Processing','Shipped','Delivered','Cancelled','Returned')),
    sales_channel   VARCHAR(20) NOT NULL CHECK (sales_channel IN ('Online','In-Store','Phone','Mobile App')),
    payment_method  VARCHAR(20) NOT NULL CHECK (payment_method IN ('Credit Card','Debit Card','Bank Transfer','PayPal','Cash','Gift Card')),
    shipping_method VARCHAR(30) CHECK (shipping_method IN ('Standard','Express','Overnight','In-Store Pickup')),
    shipping_cost   NUMERIC(8,2) DEFAULT 0.00 CHECK (shipping_cost >= 0),
    discount_pct    NUMERIC(4,2) DEFAULT 0.00 CHECK (discount_pct >= 0 AND discount_pct <= 0.50),
    tax_amount      NUMERIC(10,2) DEFAULT 0.00 CHECK (tax_amount >= 0),
    total_amount    NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    notes           TEXT
);

-- ============================================================
-- 5. ORDER_ITEMS
-- ============================================================
CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id      INT NOT NULL REFERENCES products(product_id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    discount_pct    NUMERIC(4,2) DEFAULT 0.00 CHECK (discount_pct >= 0 AND discount_pct <= 0.50),
    line_total      NUMERIC(12,2) NOT NULL CHECK (line_total > 0),
    UNIQUE (order_id, product_id)
);

-- ============================================================
-- INDEXES for query performance
-- ============================================================
CREATE INDEX idx_orders_customer      ON orders(customer_id);
CREATE INDEX idx_orders_employee      ON orders(employee_id);
CREATE INDEX idx_orders_date          ON orders(order_date);
CREATE INDEX idx_orders_status        ON orders(order_status);
CREATE INDEX idx_order_items_order    ON order_items(order_id);
CREATE INDEX idx_order_items_product  ON order_items(product_id);
CREATE INDEX idx_products_category    ON products(category);
CREATE INDEX idx_customers_segment    ON customers(customer_segment);
CREATE INDEX idx_customers_country    ON customers(country);

-- ============================================================
-- SEED DATA — EMPLOYEES (25 records)
-- ============================================================
INSERT INTO employees (first_name, last_name, email, phone, hire_date, job_title, department, salary, commission_pct, manager_id, region, is_active) VALUES
('James',    'Okonkwo',   'james.okonkwo@techworld.com',   '+234-801-234-0001', '2018-03-15', 'VP of Sales',            'Sales',           185000.00, 0.00,  NULL, 'West Africa',     TRUE),
('Amina',    'Bello',     'amina.bello@techworld.com',     '+234-802-345-0002', '2019-06-01', 'Regional Sales Manager', 'Sales',           125000.00, 0.08,  1,    'West Africa',     TRUE),
('Chen',     'Wei',       'chen.wei@techworld.com',        '+86-138-0001-0003', '2019-01-10', 'Regional Sales Manager', 'Sales',           130000.00, 0.08,  1,    'Asia Pacific',    TRUE),
('Sarah',    'Mitchell',  'sarah.mitchell@techworld.com',  '+1-415-555-0004',   '2018-09-20', 'Regional Sales Manager', 'Sales',           128000.00, 0.08,  1,    'North America',   TRUE),
('Klaus',    'Müller',    'klaus.mueller@techworld.com',   '+49-30-5555-0005',  '2019-04-05', 'Regional Sales Manager', 'Sales',           126000.00, 0.08,  1,    'Europe',          TRUE),
('Fatima',   'Al-Rashid', 'fatima.alrashid@techworld.com', '+971-50-555-0006',  '2020-02-14', 'Senior Sales Rep',       'Sales',            92000.00, 0.12,  2,    'West Africa',     TRUE),
('Oluwaseun','Adeyemi',   'seun.adeyemi@techworld.com',    '+234-803-456-0007', '2020-07-01', 'Sales Representative',   'Sales',            72000.00, 0.10,  2,    'West Africa',     TRUE),
('Priya',    'Sharma',    'priya.sharma@techworld.com',    '+91-98765-00008',   '2020-03-18', 'Senior Sales Rep',       'Sales',            88000.00, 0.12,  3,    'Asia Pacific',    TRUE),
('Takeshi',  'Yamamoto',  'takeshi.yamamoto@techworld.com','+81-3-5555-0009',   '2021-01-06', 'Sales Representative',   'Sales',            76000.00, 0.10,  3,    'Asia Pacific',    TRUE),
('Emily',    'Carter',    'emily.carter@techworld.com',    '+1-212-555-0010',   '2019-11-11', 'Senior Sales Rep',       'Sales',            95000.00, 0.12,  4,    'North America',   TRUE),
('David',    'Johnson',   'david.johnson@techworld.com',   '+1-310-555-0011',   '2021-05-15', 'Sales Representative',   'Sales',            70000.00, 0.10,  4,    'North America',   TRUE),
('Luisa',    'Fernández',  'luisa.fernandez@techworld.com', '+34-91-555-0012',   '2020-08-22', 'Senior Sales Rep',       'Sales',            90000.00, 0.12,  5,    'Europe',         TRUE),
('Marco',    'Rossi',     'marco.rossi@techworld.com',     '+39-02-5555-0013',  '2021-09-01', 'Sales Representative',   'Sales',            68000.00, 0.10,  5,    'Europe',          TRUE),
('Grace',    'Njoroge',   'grace.njoroge@techworld.com',   '+254-722-555-014',  '2019-05-10', 'Director of Marketing',  'Marketing',       140000.00, 0.00,  NULL, 'East Africa',     TRUE),
('Raj',      'Patel',     'raj.patel@techworld.com',       '+91-99887-00015',   '2020-01-20', 'Marketing Analyst',      'Marketing',        65000.00, 0.00,  14,   'Asia Pacific',    TRUE),
('Olivia',   'Brown',     'olivia.brown@techworld.com',    '+44-20-5555-0016',  '2018-11-05', 'Head of Operations',     'Operations',      155000.00, 0.00,  NULL, 'Europe',          TRUE),
('Samuel',   'Eze',       'samuel.eze@techworld.com',      '+234-805-678-0017', '2020-06-15', 'Warehouse Manager',      'Operations',       58000.00, 0.00,  16,   'West Africa',     TRUE),
('Aisha',    'Mohammed',  'aisha.mohammed@techworld.com',  '+234-806-789-0018', '2021-03-01', 'Logistics Coordinator',  'Operations',       52000.00, 0.00,  16,   'West Africa',     TRUE),
('Tom',      'Williams',  'tom.williams@techworld.com',    '+1-650-555-0019',   '2019-07-22', 'CTO',                    'Technology',      195000.00, 0.00,  NULL, 'North America',   TRUE),
('Yuki',     'Tanaka',    'yuki.tanaka@techworld.com',     '+81-3-5555-0020',   '2020-10-12', 'Senior Developer',       'Technology',      105000.00, 0.00,  19,   'Asia Pacific',    TRUE),
('Ahmed',    'Hassan',    'ahmed.hassan@techworld.com',    '+20-2-5555-0021',   '2021-08-14', 'Data Analyst',           'Technology',       72000.00, 0.00,  19,   'North Africa',    TRUE),
('Linda',    'Osei',      'linda.osei@techworld.com',      '+233-24-555-0022',  '2019-12-01', 'Finance Manager',        'Finance',         115000.00, 0.00,  NULL, 'West Africa',     TRUE),
('Peter',    'Andersen',  'peter.andersen@techworld.com',  '+45-33-5555-0023',  '2021-02-10', 'Accountant',             'Finance',          62000.00, 0.00,  22,   'Europe',          TRUE),
('Ngozi',    'Ibe',       'ngozi.ibe@techworld.com',       '+234-807-890-0024', '2020-05-05', 'HR Manager',             'Human Resources', 100000.00, 0.00,  NULL, 'West Africa',     TRUE),
('Maria',    'Garcia',    'maria.garcia@techworld.com',    '+52-55-5555-0025',  '2022-01-15', 'Sales Representative',   'Sales',            65000.00, 0.10,  4,    'Latin America',   TRUE);

-- ============================================================
-- SEED DATA — PRODUCTS (40 records)
-- ============================================================
INSERT INTO products (product_name, sku, category, sub_category, brand, unit_cost, unit_price, weight_kg, warranty_months, launch_date, is_discontinued, stock_quantity, reorder_level, supplier_name, rating) VALUES
-- Smartphones
('TechWorld Pro X 256GB',        'TW-SP-001', 'Smartphones',     'Flagship',        'TechWorld',     420.00,  999.99,  0.19, 24, '2024-03-15', FALSE, 850,  100, 'Shenzhen Components Ltd',   4.6),
('TechWorld Lite 128GB',         'TW-SP-002', 'Smartphones',     'Mid-Range',       'TechWorld',     180.00,  449.99,  0.17, 12, '2024-06-01', FALSE, 1200, 150, 'Shenzhen Components Ltd',   4.3),
('TechWorld SE 64GB',            'TW-SP-003', 'Smartphones',     'Budget',          'TechWorld',     95.00,   199.99,  0.16, 12, '2023-11-20', FALSE, 2000, 200, 'GuangDong Electronics',     4.0),
('NovaTech Ultra 512GB',        'NT-SP-004', 'Smartphones',     'Flagship',        'NovaTech',      480.00, 1099.99,  0.21, 24, '2024-09-10', FALSE, 400,  60,  'Taiwan Precision Corp',     4.7),
('BudgetKing A10',              'BK-SP-005', 'Smartphones',     'Budget',          'BudgetKing',    55.00,   129.99,  0.18, 6,  '2023-05-15', FALSE, 3000, 300, 'GuangDong Electronics',     3.8),
-- Laptops
('TechWorld PowerBook 15"',     'TW-LP-006', 'Laptops',         'Professional',    'TechWorld',     650.00, 1499.99,  1.80, 24, '2024-01-20', FALSE, 500,  50,  'Intel Malaysia Sdn Bhd',    4.5),
('TechWorld AirSlim 13"',       'TW-LP-007', 'Laptops',         'Ultrabook',       'TechWorld',     480.00, 1099.99,  1.10, 24, '2024-04-10', FALSE, 700,  70,  'Intel Malaysia Sdn Bhd',    4.4),
('TechWorld StudyMate 14"',     'TW-LP-008', 'Laptops',         'Student',         'TechWorld',     280.00,  599.99,  1.50, 12, '2023-08-01', FALSE, 1100, 120, 'GuangDong Electronics',     4.1),
('NovaTech Creator Pro 16"',    'NT-LP-009', 'Laptops',         'Professional',    'NovaTech',      780.00, 1899.99,  2.10, 36, '2024-07-05', FALSE, 300,  30,  'Taiwan Precision Corp',     4.8),
('BudgetKing CloudBook 11"',    'BK-LP-010', 'Laptops',         'Budget',          'BudgetKing',    120.00,  279.99,  1.20, 12, '2023-02-28', TRUE,  150,  20,  'GuangDong Electronics',     3.5),
-- Tablets
('TechWorld Tab Pro 12.9"',     'TW-TB-011', 'Tablets',         'Premium',         'TechWorld',     320.00,  749.99,  0.68, 24, '2024-05-15', FALSE, 600,  60,  'Shenzhen Components Ltd',   4.5),
('TechWorld Tab Mini 8.3"',     'TW-TB-012', 'Tablets',         'Compact',         'TechWorld',     160.00,  379.99,  0.30, 12, '2024-02-01', FALSE, 900,  90,  'Shenzhen Components Ltd',   4.2),
('NovaTech Slate 10"',          'NT-TB-013', 'Tablets',         'Standard',        'NovaTech',      200.00,  499.99,  0.48, 18, '2024-03-20', FALSE, 550,  55,  'Taiwan Precision Corp',     4.3),
('BudgetKing PadLite 10"',      'BK-TB-014', 'Tablets',         'Budget',          'BudgetKing',    70.00,   159.99,  0.45, 6,  '2023-07-10', FALSE, 1800, 200, 'GuangDong Electronics',     3.6),
-- Audio
('TechWorld SoundMax Pro',      'TW-AU-015', 'Audio',           'Headphones',      'TechWorld',     85.00,   249.99,  0.25, 12, '2024-01-10', FALSE, 1500, 150, 'Dongguan Audio Systems',    4.4),
('TechWorld EarPods Elite',     'TW-AU-016', 'Audio',           'Earbuds',         'TechWorld',     45.00,   149.99,  0.05, 12, '2024-06-20', FALSE, 2200, 200, 'Dongguan Audio Systems',    4.3),
('TechWorld HomeSphere',        'TW-AU-017', 'Audio',           'Smart Speaker',   'TechWorld',     60.00,   179.99,  1.20, 12, '2023-10-05', FALSE, 800,  80,  'Dongguan Audio Systems',    4.1),
('NovaTech StudioCans',         'NT-AU-018', 'Audio',           'Headphones',      'NovaTech',      110.00,  329.99,  0.32, 24, '2024-04-15', FALSE, 650,  65,  'Japan Audio Precision',     4.7),
('BudgetKing SoundBuds',        'BK-AU-019', 'Audio',           'Earbuds',         'BudgetKing',    12.00,   34.99,   0.04, 3,  '2023-03-01', FALSE, 5000, 500, 'GuangDong Electronics',     3.4),
-- Wearables
('TechWorld FitBand Ultra',     'TW-WR-020', 'Wearables',       'Smartwatch',      'TechWorld',     95.00,   299.99,  0.05, 12, '2024-08-01', FALSE, 1000, 100, 'Shenzhen Components Ltd',   4.5),
('TechWorld FitBand SE',        'TW-WR-021', 'Wearables',       'Fitness Tracker', 'TechWorld',     35.00,   99.99,   0.03, 6,  '2023-12-10', FALSE, 2500, 250, 'Shenzhen Components Ltd',   4.0),
('NovaTech ChronoSmart',       'NT-WR-022', 'Wearables',       'Smartwatch',      'NovaTech',      130.00,  399.99,  0.06, 18, '2024-05-25', FALSE, 450,  45,  'Taiwan Precision Corp',     4.6),
-- Accessories
('TechWorld 65W USB-C Charger', 'TW-AC-023', 'Accessories',     'Charger',         'TechWorld',     12.00,   39.99,   0.12, 12, '2023-06-01', FALSE, 4000, 400, 'Shenzhen Components Ltd',   4.3),
('TechWorld Laptop Sleeve 15"', 'TW-AC-024', 'Accessories',     'Case',            'TechWorld',     8.00,    29.99,   0.20, 6,  '2023-04-15', FALSE, 3000, 300, 'Dongguan Textiles',         4.1),
('TechWorld Wireless Mouse',    'TW-AC-025', 'Accessories',     'Peripheral',      'TechWorld',     10.00,   34.99,   0.08, 12, '2023-09-20', FALSE, 3500, 350, 'Shenzhen Components Ltd',   4.2),
('TechWorld USB Hub 7-Port',    'TW-AC-026', 'Accessories',     'Peripheral',      'TechWorld',     15.00,   49.99,   0.15, 12, '2024-01-05', FALSE, 2000, 200, 'Shenzhen Components Ltd',   4.0),
('NovaTech Keyboard Mech RGB',  'NT-AC-027', 'Accessories',     'Peripheral',      'NovaTech',      35.00,   99.99,   0.90, 24, '2024-02-14', FALSE, 800,  80,  'Taiwan Precision Corp',     4.5),
('TechWorld Screen Protector',  'TW-AC-028', 'Accessories',     'Protection',      'TechWorld',     2.00,    14.99,   0.02, 0,  '2023-01-10', FALSE, 8000, 800, 'GuangDong Electronics',     3.9),
-- Smart Home
('TechWorld HomeCam 360',       'TW-SH-029', 'Smart Home',      'Security Camera', 'TechWorld',     40.00,   119.99,  0.30, 24, '2024-03-01', FALSE, 1200, 120, 'Shenzhen Components Ltd',   4.3),
('TechWorld SmartPlug 4-Pack',  'TW-SH-030', 'Smart Home',      'Smart Plug',      'TechWorld',     18.00,   59.99,   0.40, 12, '2023-08-15', FALSE, 2500, 250, 'Shenzhen Components Ltd',   4.1),
('TechWorld DoorBell Pro',      'TW-SH-031', 'Smart Home',      'Doorbell',        'TechWorld',     55.00,   169.99,  0.35, 24, '2024-06-10', FALSE, 700,  70,  'Shenzhen Components Ltd',   4.4),
('NovaTech ThermoSmart',        'NT-SH-032', 'Smart Home',      'Thermostat',      'NovaTech',      65.00,   199.99,  0.22, 24, '2024-01-22', FALSE, 500,  50,  'Taiwan Precision Corp',     4.6),
-- Monitors & Displays
('TechWorld UltraView 27" 4K',  'TW-MN-033', 'Monitors',        '4K Display',      'TechWorld',     220.00,  549.99,  5.50, 36, '2024-02-28', FALSE, 400,  40,  'LG Display Vietnam',        4.5),
('TechWorld CurveMax 34"',      'TW-MN-034', 'Monitors',        'Ultrawide',       'TechWorld',     350.00,  849.99,  7.80, 36, '2024-07-15', FALSE, 250,  25,  'LG Display Vietnam',        4.6),
('NovaTech ProDisplay 32" 5K',  'NT-MN-035', 'Monitors',        '5K Display',      'NovaTech',      520.00, 1299.99,  8.20, 36, '2024-09-01', FALSE, 150,  15,  'Japan Display Inc',         4.8),
-- Storage
('TechWorld SSD 1TB NVMe',      'TW-ST-036', 'Storage',         'SSD',             'TechWorld',     45.00,   109.99,  0.05, 60, '2023-10-15', FALSE, 3000, 300, 'Samsung Semiconductor',     4.4),
('TechWorld SSD 2TB NVMe',      'TW-ST-037', 'Storage',         'SSD',             'TechWorld',     80.00,   189.99,  0.05, 60, '2024-04-01', FALSE, 1500, 150, 'Samsung Semiconductor',     4.5),
('TechWorld External HDD 4TB',  'TW-ST-038', 'Storage',         'External Drive',  'TechWorld',     55.00,   129.99,  0.25, 24, '2023-06-20', FALSE, 1800, 180, 'Western Digital Thailand',   4.2),
-- Gaming
('TechWorld GameStation X',     'TW-GM-039', 'Gaming',          'Console',         'TechWorld',     280.00,  499.99,  3.50, 12, '2024-11-15', FALSE, 600,  60,  'Foxconn Assembly',          4.5),
('TechWorld ProController',     'TW-GM-040', 'Gaming',          'Controller',      'TechWorld',     25.00,   69.99,   0.28, 6,  '2024-11-15', FALSE, 2000, 200, 'Foxconn Assembly',          4.3);

-- ============================================================
-- SEED DATA — CUSTOMERS (80 records)
-- ============================================================
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, registration_date, customer_segment, city, state_province, country, postal_code, loyalty_points, preferred_channel, is_active) VALUES
-- West Africa
('Chinedu',  'Okafor',     'chinedu.okafor@email.com',      '+234-812-111-0001', '1990-05-14', 'Male',           '2022-01-10', 'Premium',    'Lagos',         'Lagos',          'Nigeria',        '100001', 4200, 'Online',     TRUE),
('Adaeze',   'Nwosu',      'adaeze.nwosu@email.com',        '+234-803-222-0002', '1985-11-30', 'Female',         '2021-06-15', 'Enterprise', 'Lagos',         'Lagos',          'Nigeria',        '100223', 8900, 'Phone',      TRUE),
('Emeka',    'Eze',        'emeka.eze@email.com',           '+234-814-333-0003', '1992-03-22', 'Male',           '2023-02-20', 'Regular',    'Abuja',         'FCT',            'Nigeria',        '900001', 1200, 'Online',     TRUE),
('Funke',    'Adebayo',    'funke.adebayo@email.com',       '+234-805-444-0004', '1988-08-09', 'Female',         '2022-09-01', 'Premium',    'Ibadan',        'Oyo',            'Nigeria',        '200001', 3600, 'In-Store',   TRUE),
('Tunde',    'Bakare',     'tunde.bakare@email.com',        '+234-816-555-0005', '1995-01-17', 'Male',           '2023-07-12', 'Regular',    'Port Harcourt', 'Rivers',         'Nigeria',        '500001', 800,  'Mobile App', TRUE),
('Yaa',      'Asantewaa',  'yaa.asantewaa@email.com',       '+233-24-666-0006',  '1991-06-25', 'Female',         '2022-03-18', 'Premium',    'Accra',         'Greater Accra',  'Ghana',          'GA001',  5100, 'Online',     TRUE),
('Kwame',    'Mensah',     'kwame.mensah@email.com',        '+233-27-777-0007',  '1987-12-03', 'Male',           '2021-11-22', 'Enterprise', 'Kumasi',        'Ashanti',        'Ghana',          'AK001',  7200, 'Phone',      TRUE),
('Aminata',  'Diallo',     'aminata.diallo@email.com',      '+221-77-888-0008',  '1993-04-11', 'Female',         '2023-01-05', 'Regular',    'Dakar',         'Dakar',          'Senegal',        '10000',  950,  'Online',     TRUE),
('Moussa',   'Traoré',     'moussa.traore@email.com',       '+225-07-999-0009',  '1989-09-28', 'Male',           '2022-08-14', 'Premium',    'Abidjan',       'Lagunes',        'Ivory Coast',    '01BP',   3100, 'In-Store',   TRUE),
('Binta',    'Kamara',     'binta.kamara@email.com',        '+232-76-101-0010',  '1994-02-19', 'Female',         '2023-05-30', 'Regular',    'Freetown',      'Western Area',   'Sierra Leone',   'SL001',  600,  'Mobile App', TRUE),
-- East Africa
('Wanjiku',  'Kamau',      'wanjiku.kamau@email.com',       '+254-722-111-0011', '1990-07-08', 'Female',         '2021-09-10', 'Enterprise', 'Nairobi',       'Nairobi County', 'Kenya',          '00100',  9500, 'Online',     TRUE),
('Brian',    'Otieno',     'brian.otieno@email.com',        '+254-733-222-0012', '1996-11-15', 'Male',           '2023-03-25', 'Regular',    'Mombasa',       'Mombasa County', 'Kenya',          '80100',  720,  'Mobile App', TRUE),
('Amani',    'Mwangi',     'amani.mwangi@email.com',       '+254-710-333-0013', '1988-05-20', 'Male',           '2022-06-08', 'Premium',    'Nairobi',       'Nairobi County', 'Kenya',          '00200',  4800, 'Online',     TRUE),
('Halima',   'Abdi',       'halima.abdi@email.com',        '+252-61-444-0014',  '1992-10-02', 'Female',         '2023-08-19', 'Regular',    'Mogadishu',     'Banadir',        'Somalia',        'MG001',  350,  'Phone',      TRUE),
('Emmanuel', 'Ndayisaba',  'emmanuel.ndayisaba@email.com',  '+257-79-555-0015',  '1986-03-30', 'Male',           '2022-12-01', 'Premium',    'Bujumbura',     'Bujumbura Mairie','Burundi',       'BJ001',  2900, 'In-Store',   TRUE),
-- Southern Africa
('Thabo',    'Molefe',     'thabo.molefe@email.com',        '+27-82-666-0016',   '1991-08-12', 'Male',           '2021-04-20', 'Enterprise', 'Johannesburg',  'Gauteng',        'South Africa',   '2001',   11200,'Online',     TRUE),
('Naledi',   'Dlamini',    'naledi.dlamini@email.com',      '+27-73-777-0017',   '1994-01-25', 'Female',         '2022-10-10', 'Premium',    'Cape Town',     'Western Cape',   'South Africa',   '8001',   5600, 'In-Store',   TRUE),
('Blessing', 'Moyo',       'blessing.moyo@email.com',       '+263-77-888-0018',  '1993-06-07', 'Female',         '2023-04-15', 'Regular',    'Harare',        'Harare',         'Zimbabwe',       'HRE001', 1100, 'Mobile App', TRUE),
('Tatenda',  'Chikaura',   'tatenda.chikaura@email.com',    '+263-71-999-0019',  '1987-11-18', 'Male',           '2022-07-22', 'Premium',    'Bulawayo',      'Bulawayo',       'Zimbabwe',       'BYO001', 3400, 'Online',     TRUE),
('Chipo',    'Banda',      'chipo.banda@email.com',         '+260-96-101-0020',  '1995-04-03', 'Female',         '2023-09-05', 'Regular',    'Lusaka',        'Lusaka',         'Zambia',         '10101',  480,  'Phone',      TRUE),
-- North America
('Michael',  'Thompson',   'michael.thompson@email.com',    '+1-212-111-0021',   '1985-09-16', 'Male',           '2021-01-25', 'Enterprise', 'New York',      'New York',       'United States',  '10001',  15800,'Online',     TRUE),
('Jessica',  'Williams',   'jessica.williams@email.com',    '+1-310-222-0022',   '1990-12-08', 'Female',         '2022-04-12', 'Premium',    'Los Angeles',   'California',     'United States',  '90001',  6700, 'Mobile App', TRUE),
('Robert',   'Davis',      'robert.davis@email.com',        '+1-312-333-0023',   '1988-02-28', 'Male',           '2021-08-30', 'Enterprise', 'Chicago',       'Illinois',       'United States',  '60601',  12400,'Online',     TRUE),
('Amanda',   'Wilson',     'amanda.wilson@email.com',       '+1-415-444-0024',   '1993-07-14', 'Female',         '2023-01-18', 'Premium',    'San Francisco', 'California',     'United States',  '94102',  4100, 'In-Store',   TRUE),
('Daniel',   'Martinez',   'daniel.martinez@email.com',     '+1-305-555-0025',   '1991-10-22', 'Male',           '2022-11-05', 'Regular',    'Miami',         'Florida',        'United States',  '33101',  2300, 'Online',     TRUE),
('Jennifer', 'Anderson',   'jennifer.anderson@email.com',   '+1-206-666-0026',   '1986-05-01', 'Female',         '2021-05-14', 'Enterprise', 'Seattle',       'Washington',     'United States',  '98101',  13500,'Phone',      TRUE),
('Christopher','Taylor',   'chris.taylor@email.com',        '+1-512-777-0027',   '1994-08-19', 'Male',           '2023-06-20', 'Regular',    'Austin',        'Texas',          'United States',  '73301',  900,  'Mobile App', TRUE),
('Ashley',   'Thomas',     'ashley.thomas@email.com',       '+1-617-888-0028',   '1989-03-11', 'Female',         '2022-02-28', 'Premium',    'Boston',        'Massachusetts',  'United States',  '02101',  5200, 'Online',     TRUE),
('Sophie',   'Tremblay',   'sophie.tremblay@email.com',     '+1-514-999-0029',   '1992-06-30', 'Female',         '2022-09-15', 'Premium',    'Montreal',      'Quebec',         'Canada',         'H2X1Y4', 4800, 'Online',     TRUE),
('Liam',     'O''Brien',   'liam.obrien@email.com',         '+1-416-101-0030',   '1987-01-05', 'Male',           '2021-12-01', 'Enterprise', 'Toronto',       'Ontario',        'Canada',         'M5V2T6', 10200,'In-Store',   TRUE),
-- Europe
('Hans',     'Schmidt',    'hans.schmidt@email.com',        '+49-30-111-0031',   '1984-10-20', 'Male',           '2021-03-08', 'Enterprise', 'Berlin',        'Berlin',         'Germany',        '10115',  14000,'Online',     TRUE),
('Anna',     'Weber',      'anna.weber@email.com',          '+49-89-222-0032',   '1991-04-15', 'Female',         '2022-07-20', 'Premium',    'Munich',        'Bavaria',        'Germany',        '80331',  5900, 'In-Store',   TRUE),
('Pierre',   'Dubois',     'pierre.dubois@email.com',       '+33-1-333-0033',    '1988-09-02', 'Male',           '2021-10-12', 'Enterprise', 'Paris',         'Île-de-France',  'France',         '75001',  11800,'Phone',      TRUE),
('Marie',    'Laurent',    'marie.laurent@email.com',       '+33-4-444-0034',    '1993-12-18', 'Female',         '2023-02-14', 'Regular',    'Lyon',          'Auvergne-Rhône-Alpes', 'France', '69001',  1600, 'Online',     TRUE),
('James',    'Wilson',     'james.wilson.uk@email.com',     '+44-20-555-0035',   '1986-07-24', 'Male',           '2021-06-30', 'Enterprise', 'London',        'Greater London', 'United Kingdom', 'EC1A1BB',13200,'Online',     TRUE),
('Emma',     'Davies',     'emma.davies@email.com',         '+44-121-666-0036',  '1995-02-10', 'Female',         '2023-04-22', 'Regular',    'Birmingham',    'West Midlands',  'United Kingdom', 'B11AA',  750,  'Mobile App', TRUE),
('Alessandro','Bianchi',   'alessandro.bianchi@email.com',  '+39-02-777-0037',   '1989-11-06', 'Male',           '2022-01-18', 'Premium',    'Milan',         'Lombardy',       'Italy',          '20121',  4500, 'In-Store',   TRUE),
('Elena',    'Petrov',     'elena.petrov@email.com',        '+34-91-888-0038',   '1992-05-29', 'Female',         '2022-08-05', 'Premium',    'Madrid',        'Community of Madrid', 'Spain',   '28001',  3800, 'Online',     TRUE),
('Erik',     'Johansson',  'erik.johansson@email.com',      '+46-8-999-0039',    '1987-08-13', 'Male',           '2021-11-28', 'Enterprise', 'Stockholm',     'Stockholm',      'Sweden',         '11120',  9800, 'Online',     TRUE),
('Katarzyna','Nowak',      'katarzyna.nowak@email.com',     '+48-22-101-0040',   '1994-03-07', 'Female',         '2023-06-10', 'Regular',    'Warsaw',        'Masovia',        'Poland',         '00001',  1050, 'Mobile App', TRUE),
-- Asia Pacific
('Hiroshi',  'Suzuki',     'hiroshi.suzuki@email.com',      '+81-3-111-0041',    '1983-12-25', 'Male',           '2020-09-15', 'Enterprise', 'Tokyo',         'Tokyo',          'Japan',          '100-0001',16500,'Online',    TRUE),
('Yumi',     'Watanabe',   'yumi.watanabe@email.com',       '+81-6-222-0042',    '1990-06-18', 'Female',         '2022-03-10', 'Premium',    'Osaka',         'Osaka',          'Japan',          '530-0001',6200, 'In-Store',  TRUE),
('Wei',      'Zhang',      'wei.zhang@email.com',           '+86-10-333-0043',   '1988-01-30', 'Male',           '2021-07-25', 'Enterprise', 'Beijing',       'Beijing',        'China',          '100000', 14200,'Online',     TRUE),
('Li',       'Wang',       'li.wang@email.com',             '+86-21-444-0044',   '1993-09-12', 'Female',         '2022-12-08', 'Premium',    'Shanghai',      'Shanghai',       'China',          '200000', 5100, 'Mobile App', TRUE),
('Sanjay',   'Kumar',      'sanjay.kumar@email.com',        '+91-11-555-0045',   '1987-04-22', 'Male',           '2021-02-14', 'Enterprise', 'New Delhi',     'Delhi',          'India',          '110001', 11000,'Phone',      TRUE),
('Ananya',   'Reddy',      'ananya.reddy@email.com',        '+91-80-666-0046',   '1994-08-05', 'Female',         '2023-03-01', 'Regular',    'Bangalore',     'Karnataka',      'India',          '560001', 1400, 'Online',     TRUE),
('Minh',     'Nguyen',     'minh.nguyen@email.com',         '+84-28-777-0047',   '1991-11-20', 'Male',           '2022-05-18', 'Premium',    'Ho Chi Minh City','Ho Chi Minh',  'Vietnam',        '70000',  3700, 'Online',     TRUE),
('Suki',     'Park',       'suki.park@email.com',           '+82-2-888-0048',    '1989-02-14', 'Female',         '2021-10-05', 'Enterprise', 'Seoul',         'Seoul',          'South Korea',    '04524',  12800,'Online',     TRUE),
('Arjun',    'Singh',      'arjun.singh@email.com',         '+91-22-999-0049',   '1992-07-31', 'Male',           '2022-11-12', 'Premium',    'Mumbai',        'Maharashtra',    'India',          '400001', 4600, 'In-Store',   TRUE),
('Mei',      'Lin',        'mei.lin@email.com',             '+65-6-101-0050',    '1995-05-08', 'Female',         '2023-07-25', 'Regular',    'Singapore',     'Central',        'Singapore',      '048580', 880,  'Mobile App', TRUE),
-- Middle East
('Omar',     'Al-Fayed',   'omar.alfayed@email.com',        '+971-50-111-0051',  '1986-10-14', 'Male',           '2021-08-20', 'Enterprise', 'Dubai',         'Dubai',          'UAE',            '00000',  13600,'Online',     TRUE),
('Layla',    'Hassan',     'layla.hassan@email.com',        '+971-55-222-0052',  '1993-03-26', 'Female',         '2022-06-15', 'Premium',    'Abu Dhabi',     'Abu Dhabi',      'UAE',            '00000',  5400, 'In-Store',   TRUE),
('Yusuf',    'Kaya',       'yusuf.kaya@email.com',          '+90-212-333-0053',  '1988-07-09', 'Male',           '2022-01-30', 'Premium',    'Istanbul',      'Istanbul',       'Turkey',         '34000',  4200, 'Online',     TRUE),
('Nour',     'Saeed',      'nour.saeed@email.com',          '+966-50-444-0054',  '1991-12-01', 'Female',         '2023-05-08', 'Regular',    'Riyadh',        'Riyadh',         'Saudi Arabia',   '11564',  1300, 'Phone',      TRUE),
-- Latin America
('Carlos',   'Rodriguez',  'carlos.rodriguez@email.com',    '+52-55-111-0055',   '1989-04-18', 'Male',           '2021-09-25', 'Enterprise', 'Mexico City',   'CDMX',           'Mexico',         '06600',  10500,'Online',     TRUE),
('Isabella', 'Santos',     'isabella.santos@email.com',     '+55-11-222-0056',   '1992-08-22', 'Female',         '2022-04-10', 'Premium',    'São Paulo',     'São Paulo',      'Brazil',         '01000',  5800, 'Mobile App', TRUE),
('Diego',    'Herrera',    'diego.herrera@email.com',       '+57-1-333-0057',    '1990-01-13', 'Male',           '2023-01-22', 'Regular',    'Bogotá',        'Cundinamarca',   'Colombia',       '110111', 1100, 'Online',     TRUE),
('Valentina','López',      'valentina.lopez@email.com',     '+56-2-444-0058',    '1994-06-05', 'Female',         '2022-10-30', 'Premium',    'Santiago',      'Santiago',        'Chile',          '8320000',3900, 'In-Store',   TRUE),
('Mateo',    'González',   'mateo.gonzalez@email.com',      '+54-11-555-0059',   '1987-11-27', 'Male',           '2021-05-18', 'Enterprise', 'Buenos Aires',  'Buenos Aires',   'Argentina',      'C1002',  8700, 'Online',     TRUE),
-- North Africa
('Fatima',   'Benali',     'fatima.benali@email.com',       '+212-6-666-0060',   '1991-02-08', 'Female',         '2022-08-14', 'Premium',    'Casablanca',    'Casablanca-Settat','Morocco',      '20000',  4100, 'Online',     TRUE),
('Youssef',  'El-Masry',   'youssef.elmasry@email.com',     '+20-2-777-0061',    '1986-05-30', 'Male',           '2021-04-10', 'Enterprise', 'Cairo',         'Cairo',          'Egypt',          '11511',  11500,'Phone',      TRUE),
('Amira',    'Trabelsi',   'amira.trabelsi@email.com',      '+216-71-888-0062',  '1993-10-16', 'Female',         '2023-03-20', 'Regular',    'Tunis',         'Tunis',          'Tunisia',        '1000',   780,  'Mobile App', TRUE),
-- Oceania
('Jack',     'Mitchell',   'jack.mitchell@email.com',       '+61-2-111-0063',    '1988-06-12', 'Male',           '2021-07-08', 'Enterprise', 'Sydney',        'New South Wales','Australia',      '2000',   12900,'Online',     TRUE),
('Olivia',   'Hughes',     'olivia.hughes@email.com',       '+61-3-222-0064',    '1992-09-25', 'Female',         '2022-05-15', 'Premium',    'Melbourne',     'Victoria',       'Australia',      '3000',   5500, 'In-Store',   TRUE),
('Liam',     'Campbell',   'liam.campbell@email.com',       '+64-4-333-0065',    '1990-03-04', 'Male',           '2022-11-22', 'Premium',    'Auckland',      'Auckland',       'New Zealand',    '1010',   4300, 'Online',     TRUE),
-- Additional diversity
('Aiko',     'Nakamura',   'aiko.nakamura@email.com',       '+81-45-444-0066',   '1996-01-19', 'Non-Binary',     '2023-08-01', 'Regular',    'Yokohama',      'Kanagawa',       'Japan',          '220-0012',550,  'Mobile App', TRUE),
('Pat',      'Andersen',   'pat.andersen@email.com',        '+45-33-555-0067',   '1985-04-28', 'Prefer Not to Say','2021-02-14','Enterprise', 'Copenhagen',    'Capital Region', 'Denmark',        '1050',   10800,'Online',     TRUE),
('Zainab',   'Osman',      'zainab.osman@email.com',        '+249-91-666-0068',  '1993-08-10', 'Female',         '2023-05-05', 'Regular',    'Khartoum',      'Khartoum',       'Sudan',          '11111',  620,  'Phone',      TRUE),
('Liu',      'Chen',       'liu.chen@email.com',            '+86-20-777-0069',   '1989-12-22', 'Male',           '2022-02-28', 'Premium',    'Guangzhou',     'Guangdong',      'China',          '510000', 4700, 'Online',     TRUE),
('Nneka',    'Onyema',     'nneka.onyema@email.com',        '+234-808-888-0070', '1991-07-15', 'Female',         '2022-06-20', 'Premium',    'Enugu',         'Enugu',          'Nigeria',        '400001', 3500, 'In-Store',   TRUE),
('Raj',      'Malhotra',   'raj.malhotra@email.com',        '+91-44-999-0071',   '1986-10-08', 'Male',           '2021-09-12', 'Enterprise', 'Chennai',       'Tamil Nadu',     'India',          '600001', 9200, 'Online',     TRUE),
('Sara',     'Björk',      'sara.bjork@email.com',          '+354-5-101-0072',   '1994-05-21', 'Female',         '2023-01-30', 'Regular',    'Reykjavik',     'Capital Region', 'Iceland',        '101',    1250, 'Mobile App', TRUE),
('Ahmed',    'Ibrahim',    'ahmed.ibrahim.cust@email.com',  '+234-809-102-0073', '1988-09-03', 'Male',           '2022-04-08', 'Premium',    'Kano',          'Kano',           'Nigeria',        '700001', 3800, 'Phone',      TRUE),
('Elena',    'Volkov',     'elena.volkov@email.com',        '+7-495-103-0074',   '1990-02-14', 'Female',         '2022-10-18', 'Premium',    'Moscow',        'Moscow',         'Russia',         '101000', 4900, 'Online',     TRUE),
('John',     'Doe',        'john.doe@email.com',            '+1-646-104-0075',   '1984-11-30', 'Male',           '2020-12-01', 'Enterprise', 'New York',      'New York',       'United States',  '10002',  18200,'Online',     TRUE),
('Chioma',   'Igwe',       'chioma.igwe@email.com',         '+234-810-105-0076', '1997-03-25', 'Female',         '2024-01-10', 'Regular',    'Owerri',        'Imo',            'Nigeria',        '460001', 200,  'Mobile App', TRUE),
('Henrik',   'Larsen',     'henrik.larsen@email.com',       '+47-22-106-0077',   '1985-08-17', 'Male',           '2021-06-05', 'Enterprise', 'Oslo',          'Oslo',           'Norway',         '0150',   11400,'Online',     TRUE),
('Priscilla','Mensah',     'priscilla.mensah@email.com',    '+233-20-107-0078',  '1992-12-09', 'Female',         '2022-09-28', 'Premium',    'Takoradi',      'Western',        'Ghana',          'WR001',  3200, 'In-Store',   TRUE),
('Kenji',    'Ito',        'kenji.ito@email.com',           '+81-52-108-0079',   '1991-06-01', 'Male',           '2022-07-14', 'Premium',    'Nagoya',        'Aichi',          'Japan',          '450-0002',4400, 'Online',    TRUE),
('Aisha',    'Bah',        'aisha.bah@email.com',           '+220-3-109-0080',   '1995-09-14', 'Female',         '2023-10-01', 'Regular',    'Banjul',        'Banjul',         'Gambia',         'GM001',  300,  'Phone',      TRUE);


-- ============================================================
-- SEED DATA — ORDERS (200 records)
-- Spread across 2023-01-01 to 2025-12-15 for trend analysis
-- ============================================================

-- Helper: Generate orders with realistic patterns
-- Using a DO block for procedural generation
DO $$
DECLARE
    v_order_id      INT;
    v_customer_id   INT;
    v_employee_id   INT;
    v_order_date    TIMESTAMP;
    v_status        VARCHAR(20);
    v_channel       VARCHAR(20);
    v_payment       VARCHAR(20);
    v_shipping      VARCHAR(30);
    v_ship_cost     NUMERIC(8,2);
    v_discount      NUMERIC(4,2);
    v_total         NUMERIC(12,2);
    v_tax           NUMERIC(10,2);
    v_shipped_date  DATE;
    v_required_date DATE;
    v_rand          FLOAT;
    v_channels      VARCHAR(20)[] := ARRAY['Online','In-Store','Phone','Mobile App'];
    v_payments      VARCHAR(20)[] := ARRAY['Credit Card','Debit Card','Bank Transfer','PayPal','Cash','Gift Card'];
    v_shippings     VARCHAR(30)[] := ARRAY['Standard','Express','Overnight','In-Store Pickup'];
    v_statuses      VARCHAR(20)[] := ARRAY['Delivered','Delivered','Delivered','Delivered','Delivered','Shipped','Processing','Pending','Cancelled','Returned'];
    v_sales_emps    INT[] := ARRAY[2,3,4,5,6,7,8,9,10,11,12,13,25];
    i               INT;
    j               INT;
    v_num_items     INT;
    v_product_id    INT;
    v_qty           INT;
    v_uprice        NUMERIC(10,2);
    v_item_disc     NUMERIC(4,2);
    v_line_total    NUMERIC(12,2);
    v_subtotal      NUMERIC(12,2);
    v_used_products INT[];
    v_product_exists BOOLEAN;
BEGIN
    FOR i IN 1..200 LOOP
        -- Pick random customer (1-80)
        v_customer_id := 1 + floor(random() * 80)::INT;

        -- Pick random sales employee
        v_employee_id := v_sales_emps[1 + floor(random() * array_length(v_sales_emps, 1))::INT];

        -- Generate order date spread across 3 years with seasonal weighting
        -- More orders in Q4 (holiday season) and Q2
        v_rand := random();
        IF v_rand < 0.15 THEN
            -- Q1 2023
            v_order_date := '2023-01-01'::TIMESTAMP + make_interval(days => floor(random() * 90)::INT, hours => floor(random() * 14)::INT);
        ELSIF v_rand < 0.28 THEN
            -- Q2 2023
            v_order_date := '2023-04-01'::TIMESTAMP + make_interval(days => floor(random() * 91)::INT, hours => floor(random() * 14)::INT);
        ELSIF v_rand < 0.38 THEN
            -- Q3 2023
            v_order_date := '2023-07-01'::TIMESTAMP + make_interval(days => floor(random() * 92)::INT, hours => floor(random() * 14)::INT);
        ELSIF v_rand < 0.52 THEN
            -- Q4 2023 (holiday peak)
            v_order_date := '2023-10-01'::TIMESTAMP + make_interval(days => floor(random() * 92)::INT, hours => floor(random() * 14)::INT);
        ELSIF v_rand < 0.60 THEN
            -- Q1 2024
            v_order_date := '2024-01-01'::TIMESTAMP + make_interval(days => floor(random() * 91)::INT, hours => floor(random() * 14)::INT);
        ELSIF v_rand < 0.70 THEN
            -- Q2 2024
            v_order_date := '2024-04-01'::TIMESTAMP + make_interval(days => floor(random() * 91)::INT, hours => floor(random() * 14)::INT);
        ELSIF v_rand < 0.78 THEN
            -- Q3 2024
            v_order_date := '2024-07-01'::TIMESTAMP + make_interval(days => floor(random() * 92)::INT, hours => floor(random() * 14)::INT);
        ELSIF v_rand < 0.90 THEN
            -- Q4 2024 (holiday peak)
            v_order_date := '2024-10-01'::TIMESTAMP + make_interval(days => floor(random() * 92)::INT, hours => floor(random() * 14)::INT);
        ELSE
            -- 2025 (Jan–Dec partial)
            v_order_date := '2025-01-01'::TIMESTAMP + make_interval(days => floor(random() * 348)::INT, hours => floor(random() * 14)::INT);
        END IF;

        -- Channel and payment
        v_channel := v_channels[1 + floor(random() * 4)::INT];
        v_payment := v_payments[1 + floor(random() * 6)::INT];

        -- Shipping
        IF v_channel = 'In-Store' THEN
            v_shipping := 'In-Store Pickup';
            v_ship_cost := 0.00;
        ELSE
            v_shipping := v_shippings[1 + floor(random() * 3)::INT];
            v_ship_cost := CASE v_shipping
                WHEN 'Standard' THEN round((5 + random() * 10)::NUMERIC, 2)
                WHEN 'Express'  THEN round((15 + random() * 15)::NUMERIC, 2)
                WHEN 'Overnight' THEN round((25 + random() * 20)::NUMERIC, 2)
                ELSE 0.00
            END;
        END IF;

        -- Status (weighted toward Delivered)
        v_status := v_statuses[1 + floor(random() * 10)::INT];

        -- Dates
        v_required_date := (v_order_date + (7 + floor(random() * 14))::INT * INTERVAL '1 day')::DATE;

        IF v_status IN ('Shipped','Delivered') THEN
            v_shipped_date := (v_order_date + (1 + floor(random() * 7))::INT * INTERVAL '1 day')::DATE;
        ELSE
            v_shipped_date := NULL;
        END IF;

        -- Order-level discount (0-15%)
        v_discount := round((random() * 0.15)::NUMERIC, 2);

        -- Generate order items first to calculate total
        v_num_items := 1 + floor(random() * 4)::INT;  -- 1-4 items per order
        v_subtotal := 0;
        v_used_products := ARRAY[]::INT[];

        -- Insert order with placeholder total
        INSERT INTO orders (customer_id, employee_id, order_date, required_date, shipped_date, order_status, sales_channel, payment_method, shipping_method, shipping_cost, discount_pct, tax_amount, total_amount, notes)
        VALUES (v_customer_id, v_employee_id, v_order_date, v_required_date, v_shipped_date, v_status, v_channel, v_payment, v_shipping, v_ship_cost, v_discount, 0, 0, NULL)
        RETURNING order_id INTO v_order_id;

        -- Insert order items
        FOR j IN 1..v_num_items LOOP
            -- Pick unique product
            LOOP
                v_product_id := 1 + floor(random() * 40)::INT;
                v_product_exists := v_product_id = ANY(v_used_products);
                EXIT WHEN NOT v_product_exists;
            END LOOP;
            v_used_products := array_append(v_used_products, v_product_id);

            -- Get product price
            SELECT unit_price INTO v_uprice FROM products WHERE product_id = v_product_id;

            v_qty := 1 + floor(random() * 3)::INT;  -- 1-3 quantity
            v_item_disc := round((random() * 0.10)::NUMERIC, 2);  -- 0-10% item discount
            v_line_total := round(v_qty * v_uprice * (1 - v_item_disc), 2);

            INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct, line_total)
            VALUES (v_order_id, v_product_id, v_qty, v_uprice, v_item_disc, v_line_total);

            v_subtotal := v_subtotal + v_line_total;
        END LOOP;

        -- Calculate tax and total
        v_tax := round(v_subtotal * 0.075, 2);  -- 7.5% tax
        v_total := round(v_subtotal * (1 - v_discount) + v_tax + v_ship_cost, 2);

        -- Update order with actual totals
        UPDATE orders SET tax_amount = v_tax, total_amount = v_total
        WHERE order_id = v_order_id;

        -- Add notes for special cases
        IF v_status = 'Cancelled' THEN
            UPDATE orders SET notes = 'Customer requested cancellation' WHERE order_id = v_order_id;
        ELSIF v_status = 'Returned' THEN
            UPDATE orders SET notes = 'Product returned – refund processed' WHERE order_id = v_order_id;
        END IF;

    END LOOP;
END $$;


-- ============================================================
-- VIEWS FOR ANALYTICS
-- ============================================================

-- Customer Lifetime Value summary
CREATE OR REPLACE VIEW vw_customer_lifetime_value AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.customer_segment,
    c.country,
    c.registration_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS lifetime_revenue,
    COALESCE(AVG(o.total_amount), 0) AS avg_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    c.loyalty_points
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status NOT IN ('Cancelled','Returned')
GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_segment, c.country, c.registration_date, c.loyalty_points;

-- Product Performance summary
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    p.brand,
    p.unit_cost,
    p.unit_price,
    (p.unit_price - p.unit_cost) AS gross_margin,
    round(((p.unit_price - p.unit_cost) / p.unit_price) * 100, 1) AS margin_pct,
    COUNT(DISTINCT oi.order_id) AS times_ordered,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    p.stock_quantity,
    p.rating,
    p.is_discontinued
FROM products p
LEFT JOIN (
    SELECT oi2.product_id, oi2.order_id, oi2.quantity, oi2.line_total
    FROM order_items oi2
    INNER JOIN orders o ON oi2.order_id = o.order_id
    WHERE o.order_status NOT IN ('Cancelled','Returned')
) oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category, p.brand, p.unit_cost, p.unit_price, p.stock_quantity, p.rating, p.is_discontinued;

-- Monthly Sales Trend
CREATE OR REPLACE VIEW vw_monthly_sales_trend AS
SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS month,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS returns,
    SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations
FROM orders o
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- Employee Sales Performance
CREATE OR REPLACE VIEW vw_employee_sales_performance AS
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.job_title,
    e.region,
    e.commission_pct,
    COUNT(DISTINCT o.order_id) AS orders_handled,
    COALESCE(SUM(o.total_amount), 0) AS total_sales,
    COALESCE(AVG(o.total_amount), 0) AS avg_order_value,
    COALESCE(SUM(o.total_amount) * e.commission_pct, 0) AS estimated_commission,
    COUNT(DISTINCT o.customer_id) AS unique_customers_served
FROM employees e
LEFT JOIN orders o ON e.employee_id = o.employee_id AND o.order_status NOT IN ('Cancelled','Returned')
WHERE e.department = 'Sales'
GROUP BY e.employee_id, e.first_name, e.last_name, e.job_title, e.region, e.commission_pct;

-- Regional Sales Breakdown
CREATE OR REPLACE VIEW vw_regional_sales AS
SELECT
    c.country,
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    COALESCE(SUM(o.total_amount), 0) AS revenue,
    COALESCE(AVG(o.total_amount), 0) AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status NOT IN ('Cancelled','Returned')
GROUP BY c.country, c.customer_segment
ORDER BY revenue DESC;


-- DEVELOPER: SOYOOLA SODUNKE
-- HAPPY CODING GUYS