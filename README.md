# SQL Project - Olist Brazilian E-Commerce
## About the project
This purpose of this project is to practice using different SQL clauses and functions both in Google BigQuery and SQL Server. Below are the steps taken in this project.

- Obtain raw data from Kaggle <a href="https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce" target="_blank">Brazilian E-Commerce Public Dataset by Olist</a>
- Clean the dataset in BigQuery (file: Step 1 BQ_cleanup) using STRING functions such as
  - INITCAP
  - REPLACE
  - SUBSTR
  - CHAR_LENGTH
  - LEFT
- Clean the geolocation data to get only unique zip codes, check for duplicates, and export tables to Google Storage, where it can be later downloaded as local files. (file: Step 2 BQ_export)
- Use SQL Server to further calculate KPIs. Since this is done on MacOS, SQL Server is used in Azure Data Studio and the tables were imported there using Import Wizard.
- JOIN tables (file: Step 3 SQLServer_JOIN_functions)
- KPI Calculation from basic to advanced queries and subqueries (file: Step 4 SQLServer_Queries)

## Relevant KPIs

Time/Delivery Performance
1. Average time from purchase to delivered (group by seller state)
2. How long the process take if the seller is in SP (Sao Paulo)? (from purchase to delivered)
3. Waiting time for SP to SP vs SP to other states
4. How many hours most customers waited for their purchase to be approved (how many hours)? (seller response time)
5. Count number of orders that are delivered after expected delivery date
6. How many days most customer have to wait for their order to be delivered after it is approved?

Product/Sale Performance
7. Product ranking per month
8. Three most purchased products per month
9. Monthly sales changes in Rio de Janeiro
10. Percentile ranking for sellers in Rio de Janeiro

Purchase Behavior
11. Most popular day of purchase
12. Most popular purchase time of day
13. Payment methods that are used the most

Customer Churn
14. Number of customer who reordered the same category in a different order
15. How many more items of the same category was ordered by each customer

Others
16. Sellers/Customers are from which city the most
17. Select all products related to 'game'
18. Highest freight costs ever costed for each product category

## Key learning points & Used functions
- Advanced subqueries, window functions,
- DATEDIFF, STRING_AGG, OVER(), DATEPART, PARTITION BY, ROW_NUMBER(), LAG, CUME_DIST
- Aggregations: AVG, SUM, COUNT, MAX

## Samples of query results
- 1) How long the process take if the seller is in SP (Sao Paulo)? (from purchase to delivered)
    ![alt text](https://github.com/jassjitsupa/GIF_jajitsupa/blob/main/BrazilEC1.png)
- 2) Monthly sales changes in Rio de Janeiro
    ![alt text](https://github.com/jassjitsupa/GIF_jajitsupa/blob/main/BrazilEC2.png)
- 3) Three most purchased products per month
    ![alt text](https://github.com/jassjitsupa/GIF_jajitsupa/blob/main/BrazilEC3.png)
- 4) How many days most customer have to wait for their order to be delivered after it is approved?
    ![alt text](https://github.com/jassjitsupa/GIF_jajitsupa/blob/main/BrazilEC4.png)
- 5) How many hours most customers waited for their purchase to be approved (how many hours)? (seller response time)
    ![alt text](https://github.com/jassjitsupa/GIF_jajitsupa/blob/main/BrazilEC5.png)
