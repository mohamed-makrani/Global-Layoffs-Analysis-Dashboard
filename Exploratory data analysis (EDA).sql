-- 👨‍💻 Use the target database
USE world_layoffs;

-- 🧠 1. TEMPORAL ANALYSIS: How have layoffs evolved over time?

-- 1.1. Identify the range of dates
SELECT MIN(date) AS start_date, MAX(date) AS end_date
FROM layoffs_staging2;

-- 1.2. Total layoffs by date
SELECT date, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE date IS NOT NULL
GROUP BY date
ORDER BY date;

-- 1.3. Total layoffs by year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE YEAR(date) IS NOT NULL
GROUP BY year
ORDER BY year DESC;

-- 1.4. Total layoffs by month
SELECT MONTH(date) AS month, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE MONTH(date) IS NOT NULL
GROUP BY month
ORDER BY month;

-- 1.5. Monthly peak in 2020
SELECT date, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE date BETWEEN '2020-03-11' AND '2020-12-23'
GROUP BY date
ORDER BY total_laid_off DESC;

-- 1.6. Monthly peak in 2021
SELECT date, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE date BETWEEN '2021-01-06' AND '2021-12-22'
GROUP BY date
ORDER BY total_laid_off DESC;

-- 1.7. Monthly peak in 2022
SELECT date, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE date BETWEEN '2022-01-08' AND '2022-12-27'
GROUP BY date
ORDER BY total_laid_off DESC;

-- 1.8. Monthly peak in 2023
SELECT date, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE date BETWEEN '2023-01-02' AND '2023-03-06'
GROUP BY date
ORDER BY total_laid_off DESC;

-- 🧠 2. INDUSTRY IMPACT

-- 2.1. Industries with the highest total layoffs
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY total_laid_off DESC;

-- 2.2. Industries with highest workforce layoff percentage
SELECT industry, SUM(percentage_laid_off) AS total_percentage
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY total_percentage DESC;

-- 🧠 3. GEOGRAPHIC PERSPECTIVE

-- 3.1. Countries most affected by layoffs
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_laid_off DESC;

-- 3.2. Compare countries by company impact
SELECT country, company, SUM(total_laid_off) AS total_laid_off, AVG(total_laid_off) AS avg_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY country, company
ORDER BY total_laid_off DESC;

-- 🧠 4. COMPANY STAGE & FUNDING

-- 4.1. Early stage companies' average layoffs
WITH cteEarly AS (
  SELECT company, stage, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  WHERE stage IN ('Series A', 'Series B', 'Series C')
    AND company IS NOT NULL
    AND total_laid_off IS NOT NULL
  GROUP BY company, stage
)
SELECT AVG(total_laid_off) AS avg_early_stage_layoffs
FROM cteEarly;

-- 4.2. Late stage companies' average layoffs
WITH cteLate AS (
  SELECT company, stage, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  WHERE stage NOT IN ('Series A', 'Series B', 'Series C')
    AND company IS NOT NULL
    AND total_laid_off IS NOT NULL
  GROUP BY company, stage
)
SELECT AVG(total_laid_off) AS avg_late_stage_layoffs
FROM cteLate;

-- 4.3. Relationship between funding raised and layoffs
WITH cteFunding AS (
  SELECT company,
         SUM(total_laid_off) AS total_laid_off,
         SUM(funds_raised_millions) AS total_funds
  FROM layoffs_staging2
  WHERE company IS NOT NULL
    AND total_laid_off IS NOT NULL
    AND funds_raised_millions IS NOT NULL
  GROUP BY company
)
SELECT *
FROM cteFunding
ORDER BY total_funds DESC;

-- 🧠 5. SEVERITY OF LAYOFFS

-- 5.1. Identify companies with high funding and high layoffs
WITH cteSeverity AS (
  SELECT company,
         SUM(total_laid_off) AS total_laid_off,
         SUM(funds_raised_millions) AS total_funds
  FROM layoffs_staging2
  WHERE company IS NOT NULL
    AND total_laid_off IS NOT NULL
    AND funds_raised_millions IS NOT NULL
  GROUP BY company
)
SELECT *
FROM cteSeverity
ORDER BY total_funds DESC;

