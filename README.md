# SolarConnect Pro: Solar Panel Sales & Management System
## Objectives

To digitize solar panel sales operations with real-time inventory tracking, customer management, and sales analytics for the renewable energy sector

## Overview 

The MD27thJ2_db database is a comprehensive and well-structured relational database designed to support a solar panel sales and distribution business. It captures key aspects of the supply chain, from manufacturing and inventory to sales and installation. The schema consists of six core entities:

1. Manufacturers: Stores data about solar panel producers, including certification and country of origin.

2. Solar Panels: Holds specifications such as model number, power output, efficiency, and price.

3. Customers: Includes both residential and business customers with contact and location information.

4. Installers: Contains certified installation providers with service area and certifications.

5. Inventory: Tracks solar panel stock levels by warehouse location and restock date.

6. Sales: Records detailed transactions, including quantities sold, prices, discounts, payment methods, and whether installation was included.


The database also supports advanced analytical queries to provide insights into:

1. Best-selling and most efficient solar panels

2. Customer segmentation and high-value clients

3. Sales trends over time by panel type

4. Installer performance and average system sizes

5. Inventory monitoring and warehouse valuation

## Database Creation 
``` sql
CREATE DATABASE MD27thJ2_db;
USE MD27thJ2_db;
```
## Table Creation 
### Table:manufacturers
``` sql
CREATE TABLE manufacturers (
        manufacturer_id        INT PRIMARY KEY AUTO_INCREMENT,
        name                   TEXT,
        country                TEXT,
        founded_year           INT,
        quality_certification  TEXT
);

SELECT * FROM manufacturers ;
```
### Table:solarPanels
``` sql
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
```
### Table:customers
``` sql
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
```
### Table:installers
``` sql
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
```
### Table:inventory
``` sql
CREATE TABLE inventory (
        inventory_id        INT PRIMARY KEY AUTO_INCREMENT,
        panel_id            INT,
        quantity_in_stock   INT,
        last_restock_date   DATE,
        warehouse_location  TEXT,
        FOREIGN KEY (panel_id) REFERENCES solarPanels(panel_id)
);

SELECT * FROM inventory ;
```
### Table:sales
``` sql
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
```
## Key Queries

#### 1. List all monocrystalline solar panels with efficiency above 20%, sorted by price.
``` sql
SELECT 
        panel_id,model_number,panel_type,power_output_watts,efficiency,price
FROM solarPanels
WHERE 
   efficiency>20.0
   AND panel_type='monocrystalline'
ORDER BY price DESC;
```
#### 2. Show the average price difference between monocrystalline and polycrystalline panels.
``` sql
SELECT
    ROUND(AVG(CASE WHEN panel_type = 'Monocrystalline' THEN price END),2) AS avg_monocrystalline_price,
    ROUND(AVG(CASE WHEN panel_type = 'Polycrystalline' THEN price END),2) AS avg_polycrystalline_price,
    ROUND(ABS(
        AVG(CASE WHEN panel_type = 'Monocrystalline' THEN price END) -
        AVG(CASE WHEN panel_type = 'Polycrystalline' THEN price END)
    ),2) AS avg_price_difference
FROM solarPanels;
```
#### 3. Find panels from manufacturers founded before 2000 with warranties of 20+ years.
``` sql
SELECT
    sp.model_number,sp.panel_type,sp.warranty_years,
    m.name AS manufacturer_name,m.founded_year
FROM solarPanels sp
JOIN manufacturers m ON sp.manufacturer_id = m.manufacturer_id
WHERE
    m.founded_year < 2000
    AND sp.warranty_years >= 20;
```
#### 4. Calculate monthly sales revenue for the last 6 months, grouped by panel type.
``` sql
SELECT
    DATE_FORMAT(s.sale_date, '%Y-%m') AS sale_month,
    sp.panel_type,
    SUM(s.total_price - s.discount) AS monthly_revenue
FROM sales s
JOIN solarPanels sp ON s.panel_id = sp.panel_id
WHERE s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY sale_month, sp.panel_type
ORDER BY sale_month, sp.panel_type;
```
#### 5. Identify the top 3 best-selling solar panels by quantity sold.
``` sql
SELECT
    sp.model_number,sp.panel_type,
    SUM(s.quantity) AS total_quantity_sold
FROM sales s
JOIN solarPanels sp ON s.panel_id = sp.panel_id
GROUP BY sp.model_number,sp.panel_type
ORDER BY total_quantity_sold DESC
LIMIT 3;
```
#### 6. Find customers who made purchases over $10,000 and their preferred panel types.
``` sql
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(s.total_price - s.discount) AS total_spent,
    GROUP_CONCAT(DISTINCT sp.panel_type) AS preferred_panel_types
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN solarPanels sp ON s.panel_id = sp.panel_id
GROUP BY c.customer_id
HAVING total_spent > 10000;
```
#### 7. List panels with stock levels below their 3-month average sales quantity.
``` sql
SELECT
    sp.model_number,i.quantity_in_stock,
    ROUND(SUM(s.quantity)/3, 2) AS avg_monthly_sales
FROM solarPanels sp
JOIN inventory i ON sp.panel_id = i.panel_id
JOIN sales s ON sp.panel_id = s.panel_id
WHERE s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY sp.panel_id, i.quantity_in_stock
HAVING i.quantity_in_stock < avg_monthly_sales;
```
#### 8. Show inventory value by warehouse location (quantity × price).
``` sql
SELECT
    i.warehouse_location,
    SUM(i.quantity_in_stock * sp.price) AS total_inventory_value
FROM inventory i
JOIN solarPanels sp ON i.panel_id = sp.panel_id
GROUP BY i.warehouse_location
ORDER BY total_inventory_value DESC;
```
#### 9. Calculate the percentage of residential vs. commercial/industrial customers.
``` sql
SELECT
    customer_type,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percentage
FROM customers
GROUP BY customer_type;
```
#### 10. Find repeat customers (those with more than one purchase).
``` sql
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(s.sale_id) AS purchase_count
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY customer_name,c.customer_id
HAVING purchase_count > 1;
```
#### 11. Rank installers by total installation revenue generated.
``` sql
SELECT
    i.company_name,i.contact_person,
    SUM(s.total_price - s.discount) AS total_installation_revenue
FROM sales s
JOIN installers i ON s.installer_id = i.installer_id
WHERE s.installation_included = TRUE
GROUP BY i.company_name,i.contact_person
ORDER BY total_installation_revenue DESC;
```
#### 12. Calculate the average system size (in watts) for each installer's projects.
``` sql
SELECT
    i.company_name,i.contact_person,
    ROUND(AVG(s.quantity * sp.power_output_watts), 2) AS avg_system_size_watts
FROM sales s
JOIN installers i ON s.installer_id = i.installer_id
JOIN solarPanels sp ON s.panel_id = sp.panel_id
GROUP BY i.company_name,i.contact_person
ORDER BY avg_system_size_watts DESC;
```
## Conclusion 

The MD27thJ2_db offers a robust data foundation for managing and analyzing the operations of a solar energy business. It enables:

1. Operational efficiency through accurate inventory and sales tracking.

2. Strategic insights with revenue breakdowns, customer behavior analysis, and installer rankings.

3. Scalability and flexibility, making it easy to adapt to new business requirements such as support for new panel types, regional expansion, or integration with IoT-based smart systems.

This database is well-suited for powering dashboards, generating business reports, and supporting decision-making in a growing renewable energy enterprise.