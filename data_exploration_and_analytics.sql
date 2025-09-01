SELECT * FROM cases
SELECT * FROM pacer_cases

-- ### Data Exploration

-- 1. How many cases by year?

SELECT YEAR(date_last_filed) AS year, COUNT(*) AS num_cases
FROM dbo.cases
WHERE YEAR(date_last_filed) IS NOT NULL
GROUP BY YEAR(date_last_filed)
ORDER BY year;

-- 2. Top jurisdictions
SELECT court_name, COUNT(*) AS case_count
FROM dbo.pacer_cases
GROUP BY court_name
ORDER BY case_count DESC;

SELECT * FROM documents;

-- ## Data Analysis
-- 1. Case Master Table (basic info) from cases + pacer_cases tables

CREATE VIEW case_master AS
SELECT 
    c.case_row_id,
    c.case_number,
    pc.court_code,
    c.date_filed,
    c.date_closed,
    DATEDIFF(day, c.date_filed, c.date_closed) AS duration_days
FROM cases c
LEFT JOIN pacer_cases pc
    ON c.case_name = pc.case_name;

-- ** Check for the validity of the table
SELECT * FROM case_master
WHERE duration_days IS NOT NULL

-- 2. Parties Table (plaintiffs/defendants)
-- Count number of parties per case by role
CREATE VIEW party_counts AS
SELECT 
    case_row_id,
    SUM(CASE WHEN party_type = 'Plaintiff' THEN 1 ELSE 0 END) AS n_plaintiffs,
    SUM(CASE WHEN party_type = 'Defendant' THEN 1 ELSE 0 END) AS n_defendants,
    SUM(CASE WHEN party_type LIKE '%Counter%' 
             AND party_type LIKE '%Plaintiff%' THEN 1 ELSE 0 END) AS n_counter_plaintiffs,
    SUM(CASE WHEN party_type LIKE '%Counter%' 
             AND party_type LIKE '%Defendant%' THEN 1 ELSE 0 END) AS n_counter_defendants,
    SUM(CASE WHEN party_type LIKE '%Third%' THEN 1 ELSE 0 END) AS n_third_parties
FROM names
GROUP BY case_row_id;


-- ** Check the for the validity of the table
SELECT * FROM party_counts

-- Flag repeat litigants (appear in >5 cases), that needs to be at the party_name level
CREATE VIEW repeat_parties AS
SELECT 
    name,
    COUNT(DISTINCT case_row_id) AS total_cases,
    CASE WHEN COUNT(DISTINCT case_row_id) > 5 THEN 1 ELSE 0 END AS is_repeat
FROM names
GROUP BY name;

-- ** Check the for the validity of the table
SELECT * FROM repeat_parties
WHERE name IS NOT NULL AND is_repeat = 1 


-- 3. Attorneys Table

CREATE VIEW attorney_counts AS
SELECT 
    case_row_id,
    COUNT(DISTINCT name) AS n_attorneys
FROM attorneys
GROUP BY case_row_id;

-- ** Check the validity of the table
SELECT * FROM attorney_counts

-- 4. Documents Table (Case outcome Analysis)

-- create an outcome view
CREATE VIEW case_outcomes AS
SELECT
    d.case_row_id,
    MAX(d.date_filed) AS last_doc_date,
    CASE
        WHEN SUM(CASE WHEN d.long_description LIKE '%Settlement%' THEN 1 ELSE 0 END) > 0
            THEN 'Settlement'
        WHEN SUM(CASE WHEN d.long_description LIKE '%Dismiss%' 
                           OR d.long_description LIKE '%Dismissal%' THEN 1 ELSE 0 END) > 0
            THEN 'Dismissed'
        WHEN SUM(CASE WHEN d.long_description LIKE '%Judgment%' THEN 1 ELSE 0 END) > 0
            THEN 'Judgment'
        ELSE 'Ongoing/Other'
    END AS inferred_outcome
FROM documents d
GROUP BY d.case_row_id;

-- add case duration
CREATE VIEW case_durations AS
SELECT
    c.case_row_id,
    c.case_number,
    c.date_filed,
    co.last_doc_date,
    DATEDIFF(DAY, c.date_filed, co.last_doc_date) AS case_duration_days,
    co.inferred_outcome
FROM cases c
LEFT JOIN case_outcomes co
    ON c.case_row_id = co.case_row_id;

-- 5. Litigation Masters

CREATE VIEW litigation_master AS
SELECT 
    cm.case_row_id,
    cm.case_number,
    cm.court_code,
    cm.date_filed,
    cm.date_closed,
    cm.duration_days,
    pc.n_plaintiffs,
    pc.n_defendants,
    pc.n_counter_plaintiffs,
    pc.n_counter_defendants,
    pc.n_third_parties,
    ac.n_attorneys,
    co.inferred_outcome,
    cd.case_duration_days
FROM case_master cm
LEFT JOIN party_counts pc
    ON cm.case_row_id = pc.case_row_id
LEFT JOIN attorney_counts ac
    ON cm.case_row_id = ac.case_row_id
LEFT JOIN case_durations cd
    ON cm.case_row_id = cd.case_row_id
LEFT JOIN case_outcomes co
    ON cm.case_row_id = co.case_row_id;

-- Check for the final litigation_master table (integration of all perspectives)
SELECT * FROM litigation_master;

-- Extract cleaned data for STATA use

SELECT 
    case_row_id,
    case_number,
    COALESCE(court_code, 'Unknown') AS court_code,
    COALESCE(date_filed, '1900-01-01') AS date_filed,
    COALESCE(date_closed, '1900-01-01') AS date_closed,
    COALESCE(duration_days, 0) AS duration_days,

    COALESCE(n_plaintiffs, 0) AS n_plaintiffs,
    COALESCE(n_defendants, 0) AS n_defendants,
    COALESCE(n_counter_plaintiffs, 0) AS n_counter_plaintiffs,
    COALESCE(n_counter_defendants, 0) AS n_counter_defendants,
    COALESCE(n_third_parties, 0) AS n_third_parties,

    COALESCE(n_attorneys, 0) AS n_attorneys,

    COALESCE(inferred_outcome, 'Ongoing/Other') AS inferred_outcome,
    COALESCE(case_duration_days, 0) AS case_duration_days
FROM litigation_master;
