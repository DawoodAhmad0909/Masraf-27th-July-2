CREATE DATABASE MD27thJ2_db;
USE MD27thJ2_db;

CREATE TABLE manufacturers (
	manufacturer_id        INT PRIMARY KEY AUTO_INCREMENT,
	name                   TEXT,
	country                TEXT,
	founded_year           INT,
	quality_certification  TEXT
);

SELECT * FROM manufacturers ;

INSERT INTO manufacturers (name, country, founded_year, quality_certification) VALUES
	('SunPower', 'USA', 1985, 'ISO 9001'),
	('LG Solar', 'South Korea', 1958, 'IEC 61215'),
	('Canadian Solar', 'Canada', 2001, 'UL 1703'),
	('Jinko Solar', 'China', 2006, 'TUV Rheinland'),
	('REC Group', 'Norway', 1996, 'IEC 61730');

CREATE TABLE solarPanels (
	panel_id            INT PRIMARY KEY AUTO_INCREMENT,
	model_number        TEXT,
	manufacturer_id     INT,
	panel_type          TEXT,
	power_output_watts  INT,
	efficiency          DECIMAL (10,2),
	dimensions          TEXT,
	weight_kg           DECIMAL (10,2),
	price               DECIMAL (10,2),
	warranty_years      INT,
	FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
);

SELECT * FROM solarPanels ;

INSERT INTO solarPanels (model_number, manufacturer_id, panel_type, power_output_watts,
	efficiency, dimensions, weight_kg, price, warranty_years) VALUES
	('SPR-X22-360', 1, 'Monocrystalline', 360, 22.8, '68.5×40.6×1.4 in', 18.6, 285.00, 25),
	('LG365Q1C-A5', 2, 'Monocrystalline', 365, 21.4, '66.7×40.0×1.4 in', 17.5, 270.00, 25),
	('CS6K-300MS', 3, 'Polycrystalline', 300, 18.4, '65.0×39.0×1.6 in', 19.0, 190.00, 12),
	('JKM395M-72HL4', 4, 'Monocrystalline', 395, 20.5, '77.6×39.1×1.4 in', 23.0, 310.00, 15),
	('REC365TP4', 5, 'Monocrystalline', 365, 21.3, '68.6×40.9×1.4 in', 19.1, 275.00, 20);

CREATE TABLE customers (
	customer_id    INT PRIMARY KEY AUTO_INCREMENT,
	first_name     TEXT,
	last_name      TEXT,
	email          TEXT,
	phone          TEXT,
	address        TEXT,
	city           TEXT,
	state          TEXT,
	zip_code       TEXT,
	customer_type  TEXT
);

SELECT * FROM customers ;

INSERT INTO customers (first_name, last_name, email, phone, address, city, state, zip_code, customer_type) VALUES
	('John', 'Smith', 'john.smith@email.com', '555-123-4567', '123 Green Energy Dr', 'Austin', 'TX', '78701', 'Residential'),
	('Sarah', 'Johnson', 'sarah.j@email.com', '555-234-5678', '456 Solar Lane', 'San Diego', 'CA', '92101', 'Residential'),
	('GreenTech Solutions', '', 'info@greentech.com', '555-345-6789', '789 Renewable Blvd', 'Denver', 'CO', '80202', 'Commercial'),
	('EcoPower Industries', '', 'contact@ecopower.com', '555-456-7890', '321 Sustainability Ave', 'Chicago', 'IL', '60601', 'Industrial');

CREATE TABLE installers (
	installer_id    INT PRIMARY KEY AUTO_INCREMENT,
	company_name    TEXT,
	contact_person  TEXT,
	email           TEXT,
	phone           TEXT,
	service_area    TEXT,
	certification   TEXT
);

SELECT * FROM installers ;

INSERT INTO installers (company_name, contact_person, email, phone, service_area, certification) VALUES
	('SunPro Installation', 'Mike Thompson', 'install@sunpro.com', '555-111-2222', 'Southwest USA', 'NABCEP'),
	('EcoSolar Solutions', 'Lisa Chen', 'info@ecosolar.com', '555-222-3333', 'West Coast USA', 'NABCEP'),
	('GreenTech Installers', 'David Wilson', 'contact@greentechinstall.com', '555-333-4444', 'Midwest USA', 'SEI');

CREATE TABLE inventory (
	inventory_id        INT PRIMARY KEY AUTO_INCREMENT,
	panel_id            INT,
	quantity_in_stock   INT,
	last_restock_date   DATE,
	warehouse_location  TEXT,
	FOREIGN KEY (panel_id) REFERENCES solarPanels(panel_id)
);

SELECT * FROM inventory ;

INSERT INTO inventory (panel_id, quantity_in_stock, last_restock_date, warehouse_location) VALUES
	(1, 120, '2023-05-15', 'TX Warehouse'),
	(2, 85, '2023-05-20', 'CA Warehouse'),
	(3, 200, '2023-05-10', 'CO Warehouse'),
	(4, 65, '2023-05-25', 'IL Warehouse'),
	(5, 95, '2023-05-18', 'TX Warehouse');

CREATE TABLE sales (
	sale_id               INT PRIMARY KEY AUTO_INCREMENT,
	customer_id           INT,
	panel_id              INT,
	installer_id          INT,
	sale_date             DATE,
	quantity              INT,
	unit_price            DECIMAL (10,2),
	total_price           DECIMAL (10,2),
	discount              DECIMAL (10,2),
	installation_included BOOLEAN,
	payment_method        TEXT,
	FOREIGN KEY (installer_id) REFERENCES installers(installer_id),
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY (panel_id) REFERENCES solarPanels(panel_id)
);

SELECT * FROM sales ;

INSERT INTO sales (customer_id, panel_id, installer_id, sale_date, quantity,
	unit_price, total_price, discount, installation_included, payment_method) VALUES
	(1, 1, 1, '2023-06-10', 20, 275.00, 5500.00, 200.00, TRUE, 'Loan'),
	(2, 2, 2, '2023-06-15', 15, 260.00, 3900.00, 150.00, TRUE, 'Credit'),
	(3, 3, NULL, '2023-06-20', 100, 185.00, 18500.00, 500.00, FALSE, 'Cash'),
	(4, 4, 3, '2023-06-25', 250, 300.00, 75000.00, 2500.00, TRUE, 'Lease');

-- 1. List all monocrystalline solar panels with efficiency above 20%, sorted by price.
SELECT 
	panel_id,model_number,panel_type,power_output_watts,efficiency,price
FROM solarPanels
WHERE efficiency>20.0
ORDER BY price DESC;

-- 2. Show the average price difference between monocrystalline and polycrystalline panels.
SELECT
    ROUND(AVG(CASE WHEN panel_type = 'Monocrystalline' THEN price END),2) AS avg_monocrystalline_price,
    ROUND(AVG(CASE WHEN panel_type = 'Polycrystalline' THEN price END),2) AS avg_polycrystalline_price,
    ROUND(ABS(
        AVG(CASE WHEN panel_type = 'Monocrystalline' THEN price END) -
        AVG(CASE WHEN panel_type = 'Polycrystalline' THEN price END)
    ),2) AS avg_price_difference
FROM solarPanels;

-- 3. Find panels from manufacturers founded before 2000 with warranties of 20+ years.
SELECT
    sp.model_number,sp.panel_type,sp.warranty_years,
    m.name AS manufacturer_name,m.founded_year
FROM solarPanels sp
JOIN manufacturers m ON sp.manufacturer_id = m.manufacturer_id
WHERE
    m.founded_year < 2000
    AND sp.warranty_years >= 20;
    
-- 4. Calculate monthly sales revenue for the last 6 months, grouped by panel type.
SELECT
    DATE_FORMAT(s.sale_date, '%Y-%m') AS sale_month,
    sp.panel_type,
    SUM(s.total_price - s.discount) AS monthly_revenue
FROM sales s
JOIN solarPanels sp ON s.panel_id = sp.panel_id
WHERE s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY sale_month, sp.panel_type
ORDER BY sale_month, sp.panel_type;
    
-- 5. Identify the top 3 best-selling solar panels by quantity sold.
SELECT
    sp.model_number,sp.panel_type,
    SUM(s.quantity) AS total_quantity_sold
FROM sales s
JOIN solarPanels sp ON s.panel_id = sp.panel_id
GROUP BY s.panel_id
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- 6. Find customers who made purchases over $10,000 and their preferred panel types.
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(s.total_price - s.discount) AS total_spent,
    GROUP_CONCAT(DISTINCT sp.panel_type) AS preferred_panel_types
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN solarPanels sp ON s.panel_id = sp.panel_id
GROUP BY c.customer_id
HAVING total_spent > 10000;
    
-- 7. List panels with stock levels below their 3-month average sales quantity.
SELECT
    sp.model_number,i.quantity_in_stock,
    ROUND(SUM(s.quantity)/3, 2) AS avg_monthly_sales
FROM solarPanels sp
JOIN inventory i ON sp.panel_id = i.panel_id
JOIN sales s ON sp.panel_id = s.panel_id
WHERE s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY sp.panel_id, i.quantity_in_stock
HAVING i.quantity_in_stock < avg_monthly_sales;

-- 8. Show inventory value by warehouse location (quantity × price).
SELECT
    i.warehouse_location,
    SUM(i.quantity_in_stock * sp.price) AS total_inventory_value
FROM inventory i
JOIN solarPanels sp ON i.panel_id = sp.panel_id
GROUP BY i.warehouse_location
ORDER BY total_inventory_value DESC;
    
-- 9. Calculate the percentage of residential vs. commercial/industrial customers.
SELECT
    customer_type,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percentage
FROM customers
GROUP BY customer_type;

-- 10. Find repeat customers (those with more than one purchase).
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(s.sale_id) AS purchase_count
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY customer_name
HAVING purchase_count > 1;
    
-- 11. Rank installers by total installation revenue generated.
SELECT
    i.company_name,i.contact_person,
    SUM(s.total_price - s.discount) AS total_installation_revenue
FROM sales s
JOIN installers i ON s.installer_id = i.installer_id
WHERE s.installation_included = TRUE
GROUP BY i.company_name,i.contact_person
ORDER BY total_installation_revenue DESC;
    
-- 12. Calculate the average system size (in watts) for each installer's projects.
SELECT
    i.company_name,i.contact_person,
    ROUND(AVG(s.quantity * sp.power_output_watts), 2) AS avg_system_size_watts
FROM sales s
JOIN installers i ON s.installer_id = i.installer_id
JOIN solarPanels sp ON s.panel_id = sp.panel_id
GROUP BY i.company_name,i.contact_person
ORDER BY avg_system_size_watts DESC;