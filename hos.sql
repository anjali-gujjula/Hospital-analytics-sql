-- HOSPITAL ANALYTICS PROJECT
-- Author: Anjali Gujjula
-- Date: 2026-05-30
-- Tool:MYSQL
-- Dataset: 318,438 patient records

CREATE DATABASE hospital_analytics;
USE hospital_analytics;
CREATE TABLE train_data(
	case_id INT,
    Hospital_code INT,
    Hospital_type_code VARCHAR(5),
    City_Code_Hospital INT,
    Hospital_region_code VARCHAR(5),
    Available_Extra_Rooms INT,
    Department VARCHAR(50),
    Ward_type VARCHAR(5),
    Ward_Facility_Code VARCHAR(5),
    Bed_Grade FLOAT,
    patientid INT,
    City_Code_Patient INT,
    Type_of_Admission VARCHAR(50),
    Severity_of_Illness VARCHAR(50),
    Visitors_with_Patient INT,
    Age VARCHAR(20),
    Admission_Deposit FLOAT,
    Stay VARCHAR(20)
    );
SELECT count(*) FROM train_data;
SELECT * FROM train_data;

-- Data Cleaning Phase


SELECT 
    SUM(CASE WHEN Hospital_code IS NULL THEN 1 ELSE 0 END) AS null_hospital_code,
    SUM(CASE WHEN Department IS NULL THEN 1 ELSE 0 END) AS null_department,
    SUM(CASE WHEN Bed_Grade IS NULL THEN 1 ELSE 0 END) AS null_bed_grade,
    SUM(CASE WHEN City_Code_Patient IS NULL THEN 1 ELSE 0 END) AS null_city_code,
    SUM(CASE WHEN Severity_of_Illness IS NULL THEN 1 ELSE 0 END) AS null_severity,
    SUM(CASE WHEN Stay IS NULL THEN 1 ELSE 0 END) AS null_stay
FROM train_data;
-- What age groups exist?
SELECT DISTINCT Age FROM train_data;

-- What stay durations exist?
SELECT DISTINCT Stay FROM train_data ORDER BY Stay;

-- What severity levels exist?
SELECT DISTINCT Severity_of_Illness FROM train_data;

-- What departments exist?
SELECT DISTINCT Department FROM train_data;
-- patients per department
SELECT Department,
				count(*) AS total_patients 
FROM train_data 
GROUP BY Department 
ORDER BY total_patients DESC;

-- we have to clean the bed_grade and city_code fields because those two are having null values

UPDATE train_data SET Bed_Grade=( SELECT avg_grade FROM ( SELECT ROUND(AVG(Bed_Grade)) AS avg_grade FROM train_data) AS temp ) WHERE Bed_Grade IS NULL;
UPDATE train_data SET City_Code_Patient=0 WHERE City_Code_Patient IS NULL;

-- Query 1: Department load analysis 
-- Business Problem: Which departments most crowded in the hospital?

SELECT Department,
				COUNT(*) AS total_patients,
                ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM train_data),2) AS percentage 
FROM train_data 
GROUP BY Department 
ORDER BY total_patients DESC;

-- Query 2:Illness severity breakdown
-- Business problem :How serious are the coming into the hospital?

SELECT 
		Severity_of_Illness,
        COUNT(*) AS total_patients,
        ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM train_data),2) AS percentage 
FROM train_data 
GROUP BY Severity_of_Illness 
ORDER BY total_patients DESC;

-- Query 3:Stay duration pattern
-- Business Problem: How long are patients typically staying in each department?

WITH stay_ranked AS(
		SELECT 
			Department,
			Stay,
			COUNT(*) as total_patients,
			RANK() OVER(
			PARTITION BY Department 
			ORDER BY COUNT(*) DESC) AS stay_rank
		FROM train_data
        GROUP BY Department,Stay
        ORDER BY Department,stay_rank )
        SELECT 
			Department,
            Stay,total_patients,
            stay_rank 
		FROM stay_ranked 
        WHERE stay_rank=1;
        
-- Query 4: Extreme case hotspots
-- Business problem: Which departments are handling the most life threatening cases?

WITH dept_total AS (
					SELECT 
						Department,
						COUNT(*) AS dept_total
                    FROM train_data
                    GROUP BY Department
                    ),
	  extreme AS   (
					SELECT 
						Department ,
						COUNT(*) AS extreme_cases
                    FROM train_data
                    WHERE Severity_of_Illness='Extreme'
                    GROUP BY Department
                    )
		SELECT e.Department,
				e.extreme_cases,
                d.dept_total,
                ROUND(e.extreme_cases *100.0/d.dept_total ,2) AS extreme_percentage
                FROM extreme e JOIN dept_total d ON e.Department=d.Department
                ORDER BY extreme_percentage DESC;
						

-- Query 5:Age Group risk analysis
-- Business problem: Which age groups are most at risk and cost the most?

SELECT
		Age,
        COUNT(*) AS extreme_cases,
        ROUND(AVG(Admission_Deposit),2) AS avg_deposit,
        SUM(Admission_Deposit) AS admission_deposit,
        RANK() OVER(ORDER BY COUNT(*) DESC) AS risk_rank
FROM train_data 
WHERE Severity_of_Illness='Extreme' 
GROUP BY Age 
ORDER BY extreme_cases DESC;


-- Query 6:Hospital performance
-- Business problem:Which hospitals are handling the highest patient load and most critical cases?


WITH hospital_stats AS (
						SELECT 
							Hospital_code,
							Hospital_type_code,
							COUNT(*) AS total_patients,
							SUM(CASE WHEN Severity_of_Illness='Extreme' THEN 1 ELSE 0 END ) AS extreme_cases 
                        FROM train_data 
                        GROUP BY Hospital_code,Hospital_type_code 
                        )
SELECT *,
						RANK() OVER(ORDER BY total_patients DESC ) AS volume_rank,
						RANK() OVER(ORDER BY extreme_cases DESC) AS extreme_cases_rank
FROM hospital_stats 
ORDER BY volume_rank
LIMIT 10;


-- Query 7:Financial analysis
-- Business problem: Do sicker patients pay more? is there a pattern between illness severity and admission cost?
set profiling=1;
SELECT
		Severity_of_Illness,
        Type_of_Admission,
        COUNT(*) AS total_patients,
        ROUND(AVG(Admission_Deposit),2) AS avg_deposit,
        ROUND(MIN(Admission_Deposit),2) AS min_deposit,
        ROUND(MAX(Admission_Deposit),2) AS max_deposit
FROM train_data
GROUP BY Severity_of_Illness,Type_of_Admission
ORDER BY avg_deposit DESC;

-- Stored Procedures

-- Procedure 1:Daily Department Summary
-- Business Use:Hospital manager runs this every morning to see department load

DELIMITER $$
			CREATE PROCEDURE department_load()
            BEGIN
					SELECT 
						Department,
						COUNT(*) AS total_patients, 
						SUM(CASE WHEN Severity_of_Illness='Extreme' THEN 1 ELSE 0 END) AS extreme_case_count ,
						ROUND(AVG(Admission_Deposit),2) AS avg_deposit  
                    FROM train_data 
                    GROUP BY Department
                    ORDER BY total_patients DESC;
			END $$

CALL department_load;

-- Procedure 2 : Ptient Severity Report
-- Business Use: Doctor wants to see how many extreme cases each age group has with their average deposit

DELIMITER $$
			CREATE PROCEDURE Severity_report()
            BEGIN
					SELECT *,
						RANK() OVER(ORDER BY extreme_cases DESC)  AS severity_rank
					FROM (
                    SELECT 
						Age,
						COUNT(*) AS extreme_cases,
						ROUND(AVG(Admission_Deposit),2) AS avg_deposit
                    FROM train_data 
                    WHERE Severity_of_Illness='Extreme' 
                    GROUP BY Age 
                    ORDER BY extreme_cases DESC) AS temp ;
			END $$
CALL Severity_report;

-- Procedure 3: Hospital performance report
-- Business Use: Top 10 hospitals by patient voume and extreme cases at any time without writing the query again


  DELIMITER $$
			CREATE PROCEDURE hospital_performance_report()
            BEGIN
					WITH hospital_stats AS (
											SELECT Hospital_code,
												   Hospital_type_code,
													COUNT(*) AS total_patients,
													SUM(CASE WHEN Severity_of_Illness='Extreme' THEN 1 ELSE 0 END ) AS extreme_cases 
													FROM train_data 
													GROUP BY Hospital_code,Hospital_type_code )
											SELECT *,
													RANK() OVER(ORDER BY total_patients DESC ) AS volume_rank,
													RANK() OVER(ORDER BY extreme_cases DESC) AS extreme_cases_rank
													FROM hospital_stats 
													ORDER BY volume_rank
													LIMIT 10;
			END $$
CALL hospital_performance_report;

-- Indexes

CREATE INDEX idx_department ON train_data(Department(50));
CREATE INDEX idx_severity ON train_data(Severity_of_Illness(50));
CREATE INDEX idx_age ON train_data(Age(20));
CREATE INDEX idx_hospital_code ON train_data(Hospital_code);
CREATE INDEX idx_admission_deposit ON train_data(Admission_Deposit);
SET profiling=1;
EXPLAIN 
		SELECT 
			Department,
			count(*) AS total_patients 
        FROM train_data 
        WHERE  Severity_of_Illness='Extreme' 
        GROUP BY Department 
        ORDER BY total_patients DESC;
SHOW PROFILES;

