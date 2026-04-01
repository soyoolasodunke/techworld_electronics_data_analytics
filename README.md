# TechWorld Electronics Data Analytics

## About This Dataset

TechWorld is a global consumer electronics company that manufactures and sells products across ten categories — smartphones, laptops, tablets, audio equipment, wearables, accessories, smart home devices, monitors, storage drives, and gaming hardware. The company operates through four sales channels (online, in-store, phone, and mobile app) and serves customers across 45 countries spanning West Africa, East Africa, Southern Africa, North Africa, the Middle East, Europe, North America, Latin America, Asia Pacific, and Oceania.

This database captures three years of transactional activity from January 2023 through December 2025, representing the company's full commercial lifecycle: customer acquisition and segmentation, multi-channel order processing, product portfolio management, employee-driven sales execution, and regional go-to-market operations.

**What the data contains.** Five interconnected tables model the core business. 
- The `customers` table holds 80 records with demographic attributes, geographic location, loyalty programme standing, a three-tier segmentation model (Regular, Premium, Enterprise), and preferred purchase channel. 
- The `products` table holds 40 SKUs across three brands — TechWorld (the house brand), NovaTech (premium partner), and BudgetKing (value tier) — each with cost, price, margin, warranty, supplier, stock levels, and customer rating data. 
- The `employees` table holds 25 staff across six departments (Sales, Marketing, Operations, Technology, Finance, Human Resources), with a management hierarchy, regional assignments, and commission structures for sales personnel. 
- The `orders` table contains 200 transactions with full lifecycle tracking: order date, required date, shipped date, status (including cancellations and returns), payment method, shipping method, discount, tax, and total amount. 
- The `order_items` table breaks each order into individual line items with per-item pricing, quantity, discount, and computed line totals.

**How the data is structured for analysis.** Order volumes follow realistic seasonal patterns — Q4 is weighted as a holiday peak, Q2 carries above-average activity, and Q1/Q3 are lighter. Orders are distributed across all four sales channels and six payment methods. Each order is linked to a sales-team employee with a commission percentage, enabling performance and compensation analysis. Product pricing includes both unit cost and unit price, making margin and profitability analysis possible at the SKU, sub-category, category, and brand levels. Customer segmentation and geographic diversity support cohort analysis, regional revenue comparison, and lifetime value modelling.

**Five pre-built views** are included to accelerate analysis:
- `vw_customer_lifetime_value` (per-customer order count, revenue, and average order value), 
- `vw_product_performance` (units sold, revenue, and margin by product), 
- `vw_monthly_sales_trend` (monthly order volume, revenue, returns, and cancellations), 
- `vw_employee_sales_performance` (sales rep productivity and estimated commission), and 
- `vw_regional_sales` (country-level revenue by customer segment)

**Suggested project directions** 
The dataset supports a wide range of analytical exercises: 
- identifying high-value customer segments and modelling lifetime value, 
- analysing product profitability across brands and categories, 
- detecting seasonal revenue patterns and calculating year-over-year growth, 
- evaluating sales channel effectiveness, benchmarking employee performance against commission structures, 
- measuring return and cancellation rates by product or region, and 
- building dashboards that combine customer, order, and product dimensions into a unified commercial picture.

## Status

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/twbs/bootstrap/blob/main/LICENSE)
