# Bright Motors — Car Sales Analysis
**Role:** Junior Data Analyst
**Institution:** BrightLearn Data Analytics
**Dataset:** Bright Car Sales
**Tools Used:** Google BigQuery | Google Looker Studio | Google Sheets | Canva

---

## Project Overview
This project was completed as part of a BrightLearn Data Analytics case study. The goal was to analyse historical car sales data for Bright Motors and deliver actionable insights to the newly appointed Head of Sales to help expand the dealership network, improve sales performance and optimise inventory.

---

## Objectives
- Identify which car makes and models generate the most revenue
- Understand the relationship between price, mileage and year of manufacture
- Determine which regions have the highest sales volumes
- Identify emerging trends in customer purchasing preferences
- Provide data driven recommendations to increase dealership profitability

---

## Dataset
- **File:** car_sales_data.csv
- **Rows:** 558,000+
- **Columns:** 16
- **Key Fields:** year, make, model, body, transmission, state, odometer, sellingprice, mmr, saledate
- **Period:** 2014 — 2015

---

## Project Structure

```
brightmotors-analysis/
│
├── 1. Project description and raw data
│   ├── car_sales_data.csv
│   └── BrightLearn Case Study Brief.pdf
│
├── 2. Project Planning
│   ├── Mind Map
│   ├── Gantt Chart
│   └── Architecture Diagram
│
├── 3. Data Processing
│   ├── car_sales_queries.sql
│   └── car_sales_processed.xlsx
│
└── 4. Project Presentation
    └── BrightMotors_Presentation.pdf
     └── BrightMotors report
```

---

## Methodology

### 1. Project Planning
- Created a mind map outlining the full project workflow
- Designed a data architecture diagram on Canva showing the flow from raw data to final dashboard
- Built a Gantt chart style project plan with milestones and deadlines

### 2. Data Cleaning (Google BigQuery)
- Removed duplicate records
- Checked and handled NULL values across all columns
- Standardised text casing for make, model and body type
- Filtered out invalid prices and negative odometer values
- Converted saledate to proper timestamp format
- Filtered unrealistic year values outside 1990 to 2025

### 3. Data Analysis (Google BigQuery)
Analysis was structured across three sections with 28 queries total:

**Section 1 — Problem Identification**
- Makes and models with negative profit margins
- States with lowest sales volumes
- Cars sold below MMR market value
- High mileage cars sold above average price
- Sellers consistently selling below market value
- Body types with lowest average selling price
- Missing condition score analysis
- Low condition cars sold at a loss
- Transmission type underperformance
- Years of manufacture with lowest sales

**Section 2 — Historical vs Recent Analysis**
- Sales volume per year
- Average selling price per year
- Top makes older vs recent years
- Body type demand over the years
- Profit margin trend year over year
- Regional performance over time
- Average odometer reading over the years
- Seller performance over time
- Average condition of cars sold over the years
- Sales volume by month and quarter

**Section 3 — Solutions from the Data**
- Top makes and models to prioritise in inventory
- States with highest revenue potential
- Optimal mileage range for highest selling price
- Best sellers to partner with
- Body types to stock based on recent trends
- Recommended price range per make
- Condition tier vs profit margin
- Transmission type growing in demand
- Best manufacturing years to stock

### 4. Visualisation (Google Looker Studio)
- Built an interactive dashboard across 10 pages
- Used Red for problem identification charts
- Used Blue for historical analysis charts
- Used Green for solution charts
- Added slicers for region, year and body type across all pages
- Connected directly to processed Google Sheets data

### 5. Presentation
- Built a professional presentation summarising all findings
- Structured around problem identification, historical analysis and solutions
- Delivered to the Head of Sales with data driven recommendations

---

## Key Findings

### Problems Identified
- Bentley, Mercedes-Benz and BMW have the highest negative profit margins
- Alabama has the lowest sales volume with only 27 units sold
- Ford has the largest total loss from cars sold below market value at -$60M
- 96.4% of inventory is automatic transmission showing very limited diversity
- 2.11% of records are missing condition scores
- Profit margins declined from -13.9% in 2014 to -15.2% in 2015

### Historical Trends
- Sales volume grew from 53,727 units in 2014 to 505,072 in 2015
- Average selling price increased from $11,309 in 2014 to $13,856 in 2015
- Ford is the strongest performing make across both older and recent years
- Nissan and BMW declined significantly in recent years
- Sedan and SUV dominate sales across all years
- Q1 is the strongest quarter with over 350,000 units sold
- February is the busiest month with 163,053 units sold

### Solutions
- Ford F-150 is the top model to prioritise in inventory
- California and Florida have the highest revenue potential for expansion
- Cars with 0 to 25,000 miles yield the highest average selling price of $20k+
- Wholesale Enterprise Inc has the highest profit margin among sellers at 37.5%
- Sedan and SUV are the top body types to stock based on recent trends
- 1982 manufactured cars yield the highest profit margin at 29%

---

## Deliverables
| # | Folder | File | Description |
|---|---|---|---|
| 1 | Project description and raw data | car_sales_data.csv | Raw dataset |
| 2 | Project Planning | Mind Map, Gantt Chart, Architecture Diagram | Project planning documents |
| 3 | Data Processing | car_sales_queries.sql | All 28 SQL queries |
| 3 | Data Processing | car_sales_processed.xlsx | Cleaned and processed dataset |
| 4 | Project Presentation | BrightMotors_Presentation.pdf | Final presentation |

---

## Dashboard
View the interactive dashboard here:
[Bright Motors Dashboard](https://datastudio.google.com/reporting/157ba57e-fdf9-484f-a3c1-7d6ad9f65372)

---

## Notes
- No fuel type column existed in the dataset so body type was used as the closest equivalent for slicer filtering
- No units sold column existed so each row was counted as one unit sold
- MMR (Manheim Market Report) was used as a proxy for cost price since no actual cost column was available
- The 2014 data only covers the last few months of the year which explains the large difference in volume between 2014 and 2015

---

## Author
Junior Data Analyst
BrightLearn Data Analytics Case Study
brightlearn.co.za

---
