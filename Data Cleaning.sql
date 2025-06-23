-- Use the database
USE world_layoffs;

-- -----------------------------------
-- 🛠️ STEP 1: CREATE STAGING TABLE
-- -----------------------------------

-- Create an empty copy of the original table
CREATE TABLE layoffs_staging LIKE layoffs;

-- Copy the data into the staging table
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- -----------------------------------
-- 🧹 STEP 2: REMOVE DUPLICATES
-- -----------------------------------

-- Create new staging table with row numbers to identify duplicates
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  date TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

-- Insert data with row numbers based on duplicate criteria
INSERT INTO layoffs_staging2
SELECT *, 
       ROW_NUMBER() OVER (
         PARTITION BY company, location, industry, total_laid_off, 
                      percentage_laid_off, date, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- Disable safe updates to allow DELETE without WHERE key
SET sql_safe_updates = 0;

-- Delete all duplicates (keep row_num = 1)
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- -----------------------------------
-- ✏️ STEP 3: STANDARDIZE DATA
-- -----------------------------------

-- Trim whitespace from company names
UPDATE layoffs_staging2 
SET company = TRIM(company);

-- Standardize industry names
UPDATE layoffs_staging2 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Fix specific location inconsistencies
UPDATE layoffs_staging2 
SET location = 'Dusseldorf'
WHERE company = 'Springlane';

-- Clean company names that start with special characters
UPDATE layoffs_staging2 
SET company = 'Paid'
WHERE company LIKE '#%';

-- Fix country formatting issues
UPDATE layoffs_staging2 
SET country = 'United States'
WHERE country LIKE 'United States.';

-- -----------------------------------
-- 🗓️ STEP 4: CONVERT DATE FORMAT
-- -----------------------------------

-- Convert 'date' from string to DATE format
UPDATE layoffs_staging2 
SET date = STR_TO_DATE(date, '%Y-%m-%d');

-- Change column type to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- -----------------------------------
-- 🚫 STEP 5: HANDLE MISSING VALUES
-- -----------------------------------

-- Fill missing industry for known companies
UPDATE layoffs_staging2 
SET industry = 'Transportation'
WHERE company = 'Carvana';

-- Remove rows with both `total_laid_off` and `percentage_laid_off` missing
DELETE FROM layoffs_staging2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- -----------------------------------
-- 🧽 STEP 6: CLEANUP
-- -----------------------------------

-- Drop helper column used for deduplication
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
