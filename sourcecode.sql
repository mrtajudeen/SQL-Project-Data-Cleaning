-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Data Cleaning

SELECT * FROM layoffs;


-- Create a new table. Dot work on the raw original Data
-----------------------------------------------------
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

SELECT * FROM layoffs_staging;
-----------------------------------------------------


--- These are the cleaning we are gonna apply
-----------------------------------------------------
-- 1. Remove Duplicates
-- 2. Standardize
-- 3. Null values and Blank values
-- 4. Remove any columns we don't need
-----------------------------------------------------




-- 1. Remove Duplicates
-----------------------------------------------------

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`)  AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS (
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
    country, funds_raised_millions)  AS row_num
	FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

SELECT * FROM layoffs_staging
WHERE company = 'Casper';


-- This doesn't work in MySQL specifically (To delete duplicate)
WITH duplicate_cte AS (
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
    country, funds_raised_millions)  AS row_num
	FROM layoffs_staging
)
DELETE FROM duplicate_cte
WHERE row_num > 1;


-- So we can do this by creating a new table, adding the a new coulm which will the the row_num we created, and then deleting from there
-- 1. Create a new table called `layoffs_staging2`
-- 2. Same as the `layoffs_staging2` but with extra `row_num` column
-- 3. Insert the the data using: we can use the query from 'duplicate_cte' cte
-- 4. Now we can delete the desired rows with DELETE FROM our new table

-- STEP 1 & 2

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- checking if the table was created successfully
SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;


-- STEP 3

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions)  AS row_num
FROM layoffs_staging;

-- STEP 4
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- CHECK RESULTS
SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

----------------------------------------------------- -- Done with Removing Duplicates





-- 2. Standardizing
-----------------------------------------------------

-- COMPANY
-- We are checking to see and remove white spaces
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(Company);


-- INDUSTRY
-- We chech the industry and We found different versions of the same industry
-- Crypto, Cryptograpy, etc
-- So we change all those to Crypto

SELECT DISTINCT Industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
where industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT Industry
FROM layoffs_staging2;


-- COUNTRY
-- checking the location column
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- checking the country column
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- We have a  problem with a trailing . with some version of 'United States'
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
order by 1;

-- Now fix
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United%';


-- DATE
-- We need to change from string type to date type
-- The dates are in the format MM/DD/YYYY

SELECT * FROM layoffs_staging2;


SELECT `date`,
STR_TO_DATE(date, '%m/%d/%Y')
FROM layoffs_staging2;

-- Update now
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(date, '%m/%d/%Y');

-- check to see if it worked
SELECT `date`
FROM layoffs_staging2;

-- Regardless of the change the column type of date is still 'text'
-- So we change it

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT * FROM layoffs_staging2;

----------------------------------------------------- -- Done with Standardizing


-- 3. WORKING WITH NULLS
----------------------------------------------------- --

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Try to see if we can populate
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND (t2.industry IS NOT NULL);

-- Now update
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- We still have some industry null, so lets check it
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

-- There is only row for that, thats why we could not populate it because there was only one row.
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';


-- Lets check if any columns still have nulls or blanks
SELECT company FROM layoffs_staging2 WHERE company IS NULL or company = '';  -- None

SELECT location FROM layoffs_staging2 WHERE location IS NULL or location = '';  -- None

SELECT * FROM layoffs_staging2 WHERE industry IS NULL or industry = '';  -- None

SELECT total_laid_off FROM layoffs_staging2 WHERE total_laid_off IS NULL 
OR total_laid_off = '';  -- 739 ROW returned

SELECT percentage_laid_off FROM layoffs_staging2 WHERE percentage_laid_off IS NULL 
OR percentage_laid_off = '';  -- 784 ROW returned

SELECT `date` FROM layoffs_staging2 WHERE `date` IS NULL or `date` = '';  -- None

SELECT * FROM layoffs_staging2 WHERE stage IS NULL or stage = '';  -- 6 rows returned

SELECT * FROM layoffs_staging2 WHERE country IS NULL or country = '';  -- None

SELECT * FROM layoffs_staging2 WHERE funds_raised_millions IS NULL 
OR funds_raised_millions = '';  -- 216 rows returned


-- We are almost done with but, we have null values in total_laid_off and percentage_laid_off
-- It looks like those rows will be kind of useless for any future exploratory
-- Also the stage row has some nulls

SELECT * FROM
layoffs_staging2;
----------------------------------------------------- -- Done with NULLS





-- 4. Removing columns and rows not needed
-----------------------------------------------------

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- NOW WE ARE GOING TO DELETE THE ROWS WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL
-- 361 ROWS AFFECTED
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Lets check our data now
SELECT * FROM
layoffs_staging2;

-- FINISHING UP
-- We don't really need the row_num column anymore.
-- So lets drop it

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Lets check our data now
SELECT * FROM
layoffs_staging2;

-- We are done Now. 
-- We have a better and more clean data.
-- Next we will do Data Exploration on this cleaned data.

----------------------------------------------------- -- Done with removing columns



