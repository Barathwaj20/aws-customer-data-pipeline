-- ═══════════════════════════════════════════
-- Athena Queries — AWS Data Engineering Projects
-- Author: Barathwaj K G
-- ═══════════════════════════════════════════

-- 1. Create table for clean customers CSV output
CREATE EXTERNAL TABLE IF NOT EXISTS customers_clean (
    id      STRING,
    name    STRING,
    email   STRING,
    phone   STRING,
    dob     STRING,
    salary  INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
LOCATION 's3://mb-trgt1-bucket/unclean_customers_clean/'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 2. Create table for clean Sample employee output
CREATE EXTERNAL TABLE IF NOT EXISTS sample_clean (
    EMPLOYEE_ID  STRING,
    NAME         STRING,
    AGE          INT,
    HIRE_DATE    STRING,
    SALARY       INT,
    DEPARTMENT   STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
LOCATION 's3://mb-trgt1-bucket/sample_clean/'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 3. View all clean customer records
SELECT * FROM customers_clean LIMIT 20;

-- 4. Count total clean records
SELECT
    'customers' AS source, COUNT(*) AS clean_records FROM customers_clean
UNION ALL
SELECT
    'employees' AS source, COUNT(*) AS clean_records FROM sample_clean;

-- 5. Salary statistics per source
SELECT
    AVG(salary) AS avg_salary,
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    COUNT(*)    AS total_records
FROM customers_clean;

-- 6. Department headcount and avg salary
SELECT
    DEPARTMENT,
    COUNT(*)         AS headcount,
    AVG(SALARY)      AS avg_salary,
    MAX(SALARY)      AS max_salary
FROM sample_clean
GROUP BY DEPARTMENT
ORDER BY avg_salary DESC;

-- 7. Top 3 earners per department (window function)
SELECT * FROM (
    SELECT
        NAME,
        DEPARTMENT,
        SALARY,
        RANK() OVER (PARTITION BY DEPARTMENT ORDER BY SALARY DESC) AS sal_rank
    FROM sample_clean
) t WHERE sal_rank <= 3;

-- 8. Records with salary above company average
SELECT NAME, SALARY, DEPARTMENT
FROM sample_clean
WHERE SALARY > (SELECT AVG(SALARY) FROM sample_clean)
ORDER BY SALARY DESC;

-- 9. Email domain distribution
SELECT
    SPLIT_PART(email, '@', 2) AS domain,
    COUNT(*) AS count
FROM customers_clean
GROUP BY SPLIT_PART(email, '@', 2)
ORDER BY count DESC;
