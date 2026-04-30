

SELECT *
 FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data` 
 LIMIT 1000;

-- Remove duplicate rows from the raw dataset to make sure each record is unique.

SELECT DISTINCT *
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`;

-- Count NULL values in each column to see how much data is missing.
SELECT
  COUNTIF(year IS NULL) AS null_year,
  COUNTIF(make IS NULL) AS null_make,
  COUNTIF(model IS NULL) AS null_model,
  COUNTIF(condition IS NULL) AS null_condition,
  COUNTIF(odometer IS NULL) AS null_odometer,
  COUNTIF(transmission IS NULL) AS null_transmission,
  COUNTIF(color IS NULL) AS null_color,
  COUNTIF(interior IS NULL) AS null_interior,
  COUNTIF(mmr IS NULL) AS null_mmr,
  COUNTIF(sellingprice IS NULL) AS null_sellingprice
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`;


-- Remove rows where selling price or MMR is zero or negative because these values are invalid.

SELECT *
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice > 0
AND mmr > 0;
 
 -- Change body type to uppercase to fix differences like SUV, suv, and Suv.

SELECT *,
  UPPER(body) AS body_clean
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`;


-- Convert make and model to title case to fix differences like BMW and bmw.

SELECT *,
  INITCAP(make) AS make_clean,
  INITCAP(model) AS model_clean
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`;

--- Change dashes to NULL because they mean missing values for color and interior.

SELECT *,
  NULLIF(color, '—') AS color_clean,
  NULLIF(interior, '—') AS interior_clean
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`;

-- Removing records with invalid year values by keeping only data within the 1990–2025 range.

SELECT *
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE year BETWEEN 1990 AND 2025;

-- Removing rows where odometer is negative because mileage cannot be a negative value

SELECT *
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE odometer >= 0;

-- Convert saledate from string format to a proper timestamp
-- so that we can group and analyse sales by month, quarter and year
SELECT *,
  PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate) AS saledate_clean
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`;


--------------------SECTION 1 — PROBLEM IDENTIFICATION----------------------
----------------------------------------------------------------------------

-- Makes and models with negative profit margins
-- Identifying makes and models where the selling price is lower than the market value, indicating a loss.

SELECT
  make,
  model,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(mmr), 2) AS avg_market_value,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit,
  ROUND(AVG((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100), 2) AS avg_margin_pct
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL AND mmr IS NOT NULL
GROUP BY make, model
HAVING avg_profit < 0
ORDER BY avg_profit ASC;


-- States with the lowest sales volumes
-- Identify states with the fewest sales to highlight underperforming regions.
SELECT
  state,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY state
ORDER BY units_sold ASC;

-- Find cars sold below market value to see how often the business sells at a loss.
SELECT
  make,
  model,
  year,
  state,
  odometer,
  mmr AS market_value,
  sellingprice,
  ROUND(sellingprice - mmr, 2) AS loss_amount
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice < mmr
AND sellingprice IS NOT NULL
AND mmr IS NOT NULL
ORDER BY loss_amount ASC;

--Group high-mileage cars by make and model to find which ones are often overpriced.
SELECT
  INITCAP(make) AS make,
  INITCAP(model) AS model,
  COUNT(*) AS units_sold,
  ROUND(AVG(odometer), 0) AS avg_odometer,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(mmr), 2) AS avg_market_value,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE odometer > 100000
AND sellingprice > (
  SELECT AVG(sellingprice)
  FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
)
GROUP BY make, model
ORDER BY avg_odometer DESC;

-- Identify sellers who regularly sell cars below market value.
SELECT
  seller,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(mmr), 2) AS avg_market_value,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL AND mmr IS NOT NULL
GROUP BY seller
HAVING avg_profit < 0
ORDER BY avg_profit ASC;

-- Identify body types that generate the lowest average revenue.
SELECT
  UPPER(body) AS body_type,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(mmr), 2) AS avg_market_value,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL AND body IS NOT NULL
GROUP BY body_type
ORDER BY avg_selling_price ASC;

-- Count records missing a condition score since it affects pricing accuracy.
SELECT
  COUNT(*) AS total_records,
  COUNTIF(condition IS NULL OR TRIM(CAST(condition AS STRING)) = '') AS missing_condition,
  ROUND(COUNTIF(condition IS NULL OR TRIM(CAST(condition AS STRING)) = '') / COUNT(*) * 100, 2) AS missing_pct
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`;

-- Find cars with low condition scores that are also sold below market value.
SELECT
  make,
  model,
  year,
  condition,
  odometer,
  sellingprice,
  mmr AS market_value,
  ROUND(sellingprice - mmr, 2) AS profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE CAST(condition AS FLOAT64) <= 2
AND sellingprice < mmr
AND condition IS NOT NULL
ORDER BY profit ASC;

-- Compare sales volume and average selling price by transmission type to find underperformers.
SELECT
  UPPER(transmission) AS transmission_type,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
AND transmission IS NOT NULL
AND TRIM(transmission) != ''
GROUP BY transmission_type
ORDER BY units_sold ASC;

-- Identify manufacturing years with the lowest sales to spot slow-moving inventory.
SELECT
  year,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY year
ORDER BY units_sold ASC;


----------------------------------------------------------------
----------Section 2 HISTORICAL VS RECENT ANALYSIS---------------
----------------------------------------------------------------
-- Track total sales volume year over year to see if the business is growing or declining.
SELECT
  EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_year,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY sale_year
ORDER BY sale_year ASC;

-- Track how the average selling price changes year over year.
SELECT
  EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_year,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(mmr), 2) AS avg_market_value,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY sale_year
ORDER BY sale_year ASC;

-- Compare which car makes dominated older years versus recent years.
SELECT
  INITCAP(make) AS make,
  CASE
    WHEN year < 2013 THEN 'Older (before 2013)'
    ELSE 'Recent (2013 and after)'
  END AS era,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY make, era
ORDER BY era, total_revenue DESC;

-- Track how demand for different body types
-- has shifted across the years
SELECT
  EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_year,
  UPPER(body) AS body_type,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL AND body IS NOT NULL
GROUP BY sale_year, body_type
ORDER BY sale_year ASC, units_sold DESC;

-- Track how profit margins have changed
-- over the years to identify improvement or decline
SELECT
  EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_year,
  ROUND(AVG((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100), 2) AS avg_margin_pct,
  COUNTIF((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100 >= 10) AS high_margin_count,
  COUNTIF((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100 BETWEEN 0 AND 9.99) AS medium_margin_count,
  COUNTIF((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100 < 0) AS low_margin_count
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL AND mmr IS NOT NULL
GROUP BY sale_year
ORDER BY sale_year ASC;

-- See which states were strong historically
-- and which are growing or declining recently
SELECT
  UPPER(state) AS state,
  CASE
    WHEN EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) < 2013 THEN 'Older'
    ELSE 'Recent'
  END AS era,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY state, era
ORDER BY state, era;

-- Track the average mileage of cars being sold
-- each year to understand inventory age and quality
SELECT
  year,
  ROUND(AVG(odometer), 0) AS avg_odometer,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  COUNT(*) AS units_sold
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE odometer IS NOT NULL AND odometer >= 0
GROUP BY year
ORDER BY year ASC;

-- Identify which sellers have grown
-- or declined in sales volume over time
SELECT
  seller,
  EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_year,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY seller, sale_year
ORDER BY seller, sale_year ASC;

-- Track whether the quality of cars being sold
-- has improved or declined over the years
SELECT
  year,
  ROUND(AVG(CAST(condition AS FLOAT64)), 2) AS avg_condition_score,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE condition IS NOT NULL
AND TRIM(CAST(condition AS STRING)) != ''
GROUP BY year
ORDER BY year ASC;

-------------------------------------------------------------
-------------SECTION 3 — SOLUTIONS FROM THE DATA------------
-------------------------------------------------------------


-- Identify the best performing makes and models
-- by revenue and profit margin to guide inventory decisions
SELECT
  INITCAP(make) AS make,
  INITCAP(model) AS model,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit,
  ROUND(AVG((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100), 2) AS avg_margin_pct
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL AND mmr IS NOT NULL
GROUP BY make, model
ORDER BY total_revenue DESC
LIMIT 20;

-- Identify the top performing states by revenue
-- to guide dealership expansion decisions
SELECT
  UPPER(state) AS state,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY state
ORDER BY total_revenue DESC;

-- Group cars into mileage brackets to find
-- which range yields the highest selling price
SELECT
  CASE
    WHEN odometer BETWEEN 0 AND 25000 THEN '0 - 25,000'
    WHEN odometer BETWEEN 25001 AND 50000 THEN '25,001 - 50,000'
    WHEN odometer BETWEEN 50001 AND 75000 THEN '50,001 - 75,000'
    WHEN odometer BETWEEN 75001 AND 100000 THEN '75,001 - 100,000'
    ELSE 'Over 100,000'
  END AS mileage_bracket,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE odometer IS NOT NULL AND odometer >= 0
AND sellingprice IS NOT NULL
GROUP BY mileage_bracket
ORDER BY avg_selling_price DESC;

-- Identify sellers with the highest profit margins
-- and consistent sales volume to guide partnerships
SELECT
  seller,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(mmr), 2) AS avg_market_value,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit,
  ROUND(AVG((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100), 2) AS avg_margin_pct
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL AND mmr IS NOT NULL
GROUP BY seller
HAVING units_sold >= 10
ORDER BY avg_margin_pct DESC
LIMIT 20;

-- Find which body types are performing best
-- in recent years to guide stocking decisions
SELECT
  UPPER(body) AS body_type,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
AND EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) >= 2014
GROUP BY body_type
ORDER BY total_revenue DESC;

-- Show the recommended selling price range per make
-- based on market value to guide pricing strategy
SELECT
  INITCAP(make) AS make,
  ROUND(MIN(sellingprice), 2) AS min_price,
  ROUND(AVG(sellingprice), 2) AS avg_price,
  ROUND(MAX(sellingprice), 2) AS max_price,
  ROUND(AVG(mmr), 2) AS avg_market_value,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL AND mmr IS NOT NULL
GROUP BY make
ORDER BY avg_price DESC;

-- Find which condition score produces
-- the best profit margins to guide buying decisions
SELECT
  CAST(condition AS STRING) AS condition_score,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit,
  ROUND(AVG((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100), 2) AS avg_margin_pct
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE condition IS NOT NULL
AND TRIM(CAST(condition AS STRING)) != ''
AND sellingprice IS NOT NULL
GROUP BY condition_score
ORDER BY avg_margin_pct DESC;

-- Track which transmission types are growing
-- in recent years to align inventory with demand
SELECT
  UPPER(transmission) AS transmission_type,
  EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_year,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE transmission IS NOT NULL
AND TRIM(transmission) != ''
AND sellingprice IS NOT NULL
GROUP BY transmission_type, sale_year
ORDER BY sale_year ASC, units_sold DESC;

-- Identify which manufacturing years yield
-- the best revenue and profit margins
SELECT
  year,
  COUNT(*) AS units_sold,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(AVG(sellingprice - mmr), 2) AS avg_profit,
  ROUND(AVG((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100), 2) AS avg_margin_pct
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL AND mmr IS NOT NULL
GROUP BY year
ORDER BY avg_margin_pct DESC;


SELECT *
 FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`;

-- Find all cars sold below their market value
-- to understand how frequently the business sells at a loss
SELECT
  INITCAP(make) AS make,
  INITCAP(model) AS model,
  year,
  UPPER(state) AS state,
  odometer,
  mmr AS market_value,
  sellingprice,
  ROUND(mmr - sellingprice, 2) AS loss_amount
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice < mmr
AND sellingprice IS NOT NULL
AND mmr IS NOT NULL
ORDER BY loss_amount DESC;

-- See which states were strong historically
-- and which are growing or declining recently
SELECT
  CONCAT('US-', UPPER(state)) AS state,
  CASE
    WHEN EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) < 2013 THEN 'Older'
    ELSE 'Recent'
  END AS era,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY state, era
ORDER BY state, era;

-- See which states were strong historically
-- and which are growing or declining recently
SELECT
  UPPER(state) AS state,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
GROUP BY state
ORDER BY total_revenue DESC;

-- Group transactions by month and quarter
-- to identify seasonal trends in car sales
SELECT
  EXTRACT(YEAR FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_year,
  EXTRACT(MONTH FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_month,
  EXTRACT(QUARTER FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_quarter,
  INITCAP(make) AS make,
  UPPER(body) AS body_type,
  UPPER(state) AS state,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue,
  ROUND(AVG(sellingprice), 2) AS avg_selling_price,
  ROUND(SUM(sellingprice - mmr), 2) AS total_profit,
  ROUND(AVG((sellingprice - mmr) / NULLIF(sellingprice, 0) * 100), 2) AS avg_margin_pct
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
AND mmr IS NOT NULL
GROUP BY sale_year, sale_month, sale_quarter, make, body_type, state
ORDER BY sale_year, sale_quarter, sale_month;

-- Group sales by month and quarter
SELECT
  EXTRACT(MONTH FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_month,
  EXTRACT(QUARTER FROM PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS sale_quarter,
  COUNT(*) AS units_sold,
  ROUND(SUM(sellingprice), 2) AS total_revenue
FROM `brightmotors-494007.Car_Sales_Data.Car_Sales_Data`
WHERE sellingprice IS NOT NULL
AND saledate IS NOT NULL
GROUP BY sale_month, sale_quarter
ORDER BY sale_month ASC;
