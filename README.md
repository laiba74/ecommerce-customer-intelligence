# E-commerce Customer Experience & Delivery Performance Analysis

## Project Overview
This project analyzes customer experience, delivery performance, revenue behavior, and regional operational risk using the Brazilian Olist e-commerce dataset.

The goal was to identify how delivery performance impacts customer satisfaction, which regions create operational risk, and where the business should prioritize growth and logistics improvements.

## Business Objectives
- Analyze revenue and order trends over time
- Measure the impact of late deliveries on review scores
- Identify high-risk regions by delivery and customer satisfaction
- Segment orders by value and delivery performance
- Build SQL-based market opportunity and revenue-at-risk models
- Create an executive Power BI dashboard for business reporting

## Tools Used
- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- MySQL
- Power BI
- GitHub

## Dataset
The project uses multiple raw Olist datasets including customers, orders, order items, payments, reviews, products, sellers, and product category translation files.

These files were merged into an order-level analytical dataset for Python, SQL, and dashboard analysis.

## Data Preparation
Data preparation was completed in Python.

Steps included:
- Loaded and inspected 8 raw CSV files
- Merged customer, order, item, payment, review, product, seller, and category data
- Converted date columns into datetime format
- Aggregated transaction-level data into one row per order
- Created delivery and customer experience metrics
- Checked duplicates and missing values
- Exported cleaned datasets for SQL and Power BI analysis

## Feature Engineering
Created the following business-ready fields:
- order_value
- purchase_year
- purchase_month
- purchase_day
- approval_delay_days
- delivery_days
- carrier_to_customer_days
- delivery_delay_days
- is_late_delivery
- review_bucket
- order_value_bucket

## SQL Analysis
Advanced SQL analysis was performed in MySQL.

Key SQL analyses included:
1. Customer value segmentation
2. Late delivery impact on review scores
3. Revenue and shipping cost by state
4. Review score driver analysis
5. Monthly revenue and seasonality trends
6. High-value orders vs delivery performance
7. State-level revenue-at-risk analysis
8. Retention analysis limitation check
9. Delivery impact by order value segment
10. State delivery efficiency benchmarking
11. Composite market opportunity scoring
12. Executive KPI summary

## Key Insights
- Late deliveries reduced average review scores from 4.31 to 2.55.
- High-value orders experienced slightly higher late-delivery rates than low-value orders.
- São Paulo was the strongest market by revenue and operational efficiency.
- Rio de Janeiro generated strong revenue but showed elevated delivery risk.
- Bahia showed severe operational issues, with high late-delivery rates and weaker reviews.
- Shipping cost represented a meaningful share of revenue and should be monitored closely.
- The sample used for SQL contained mostly one-time customers, limiting retention analysis.

## Business Recommendations
- Prioritize logistics improvements in high-risk states such as RJ and BA.
- Monitor high-value orders more closely to protect premium customer experience.
- Use SP and MG as benchmark markets for operational best practices.
- Improve customer communication for delayed deliveries.
- Reassess shipping cost and fulfillment strategy in low-efficiency regions.

## Dashboard Preview
Power BI dashboard to be added.

![Dashboard Preview](images/dashboard_preview.png)

## Project Limitations
For SQL performance and import practicality, a smaller sample of the processed order-level dataset was used in MySQL. Python analysis was performed on the full processed dataset.

Retention analysis was limited because the SQL sample contained mostly one-time customers.

## Conclusion
This project demonstrates an end-to-end data analytics workflow from raw data preparation to business-focused SQL analysis and dashboard reporting. The analysis highlights the strong relationship between delivery performance, customer satisfaction, and regional revenue risk.
