CREATE DATABASE loan_portfolio;
USE loan_portfolio;

DROP TABLE IF EXISTS loan_data;

CREATE TABLE loan_data (
    loan_amnt DOUBLE,
    term INT,
    int_rate DOUBLE,
    grade VARCHAR(10),
    annual_inc DOUBLE,
    dti DOUBLE,
    issue_d VARCHAR(50),
    emp_length VARCHAR(50),      -- Changed to text to handle "10+ years"
    purpose VARCHAR(100),
    home_ownership VARCHAR(50),
    is_default INT,
    vintage_year INT,
    emp_length_years INT,        -- Added our cleaned Python column
    income_band VARCHAR(50),
    dti_band VARCHAR(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_lending_club_data.csv'
INTO TABLE loan_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Query 1: Portfolio Overview by Vintage Year
SELECT 
    vintage_year,
    COUNT(loan_amnt) AS total_loans_issued,
    SUM(loan_amnt) AS total_funded_amount,
    ROUND(AVG(int_rate), 2) AS average_interest_rate,
    ROUND(AVG(is_default) * 100, 2) AS default_rate_percentage
FROM 
    loan_data
GROUP BY 
    vintage_year
ORDER BY 
    vintage_year ASC;

-- Query 2: Risk Ranking using Window Functions
WITH PurposeRisk AS (
    SELECT 
        grade,
        purpose,
        COUNT(loan_amnt) AS loan_count,
        ROUND(AVG(is_default) * 100, 2) AS default_rate
    FROM 
        loan_data
    GROUP BY 
        grade, purpose
    HAVING 
        loan_count > 100 
)
SELECT 
    grade,
    purpose,
    loan_count,
    default_rate,
    RANK() OVER (PARTITION BY grade ORDER BY default_rate DESC) AS risk_rank
FROM 
    PurposeRisk
ORDER BY 
    grade ASC, 
    risk_rank ASC;

-- Query 3: Term Length and Income Impact
SELECT 
    income_band,
    term AS term_months,
    COUNT(loan_amnt) AS total_loans,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate,
    ROUND(AVG(is_default) * 100, 2) AS default_rate_percentage
FROM 
    loan_data
GROUP BY 
    income_band, 
    term
ORDER BY 
    income_band ASC, 
    term ASC;