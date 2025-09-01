-- #### SERVER DESIGN
-- Create a database called Patents Litigation
USE master
GO
-- Create the new Database if it is doesn't exist already
IF NOT EXISTS (
    SELECT [name]
    FROM sys.databases
    WHERE [name] = N'patents_litigation'
)
CREATE DATABASE patents_litigation
GO

SELECT * FROM dbo.pacer_cases

-- Convert the column to a date type
ALTER TABLE cases
ALTER COLUMN date_closed DATE;

-- Now, update the column to the new format
-- This will work because SQL can parse a string to a date type
UPDATE cases
SET date_closed = CONVERT(DATE, date_closed, 101);

-- Alter date_closed column data type
ALTER TABLE pacer_cases
ALTER COLUMN date_closed DATE;

-- Update the data to the correct format (pacer_cases table)
UPDATE pacer_cases
SET date_filed = CONVERT(DATE, date_filed, 101);

UPDATE pacer_cases
SET date_closed = CONVERT(DATE, date_closed, 101);

-- Drop tables
DROP TABLE documents;

SELECT * FROM dbo.documents



-- Safely Change Non-Numeric Values to NULL
UPDATE documents
SET doc_number = NULL
WHERE TRY_CAST(doc_number AS INT) IS NULL;

-- Update the data to the correct format (documents table)
ALTER TABLE documents
ALTER COLUMN doc_number INT;

-- Checking data in the table
SELECT * FROM pacer_cases;
SELECT * FROM attorneys;
SELECT * FROM cases;
SELECT * FROM names;
SELECT * FROM documents;
