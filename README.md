# 🏥 Hospital Operations & Patient Analytics

## 📋 Project Overview
End-to-end SQL analytics project on 318,438 real patient records 
from a multi-hospital healthcare system. Analyzed patient flow, 
illness severity, age group risks, and hospital performance.

## 🎯 Business Questions Answered
1. Which departments are most overcrowded?
2. What is the distribution of illness severity?
3. How long do patients stay in each department?
4. Which departments handle the most critical cases?
5. Which age groups are at highest risk?
6. Which hospitals handle the most patients?
7. Is there a pattern between illness severity and cost?

## 📊 Dataset
- Source: Kaggle — Healthcare Analytics II
- Size: 318,438 patient records
- Columns: 18 features including department, severity, age, stay duration

## 🛠️ Tools Used
- MySQL — Data storage and analysis
- Python (pandas) — Data loading
- Power BI — Dashboard visualization

## 💡 Key Findings
- Gynecology handles 63% of all patients
- 55% of cases are Moderate severity
- 17.81% are Extreme — over 56,000 critical cases
- Hospital type 'a' handles the highest patient volume (143K)
- Average admission deposit is consistent across age groups (~4,800)

## 🔧 SQL Concepts Used
- Window Functions (RANK)
- CTEs (Common Table Expressions)
- Stored Procedures (3 automated reports)
- Query Optimization (5 indexes)
- CASE WHEN, Subqueries, JOINs
- Aggregation Functions

## 📁 Project Structure
-hospital-analytics-sql
        -hos.sql            #Main SQL file with all queries
        -README.md          #Project documentation
        -dashboard.png      #PowerBI dashboard screenshot
## 🚀 How to Run
1. Import train.csv into MySQL using load_data.py
2. Run hos.sql in MySQL Workbench
3. Open Hospital_Analytics_Dashboard.pbix in PowerBI

## 📷 Dashboard Preview
[Screenshot](dashboard.png)

