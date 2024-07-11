-- Data Cleaning

select *
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values
-- 4. Remove Any Columns or Rows




create table layoffs_staging
like layoffs;

select * 
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;

select *
from layoffs_staging;

with duplicate_cte as
(
	select *,
	row_number() over(
	partition by 
    Company, Location_HQ, Industry, Laid_Off_Count, Percentage, Date, Stage, Funds_Raised, Country) as row_num 
	from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

select *
from layoffs_staging
where Company = 'Cazoo';


with duplicate_cte as
(
	select *,
	row_number() over(
	partition by 
    Company, Location_HQ, Industry, Laid_Off_Count, Percentage, Date, Stage, Funds_Raised, Country) as row_num 
	from layoffs_staging
)
delete
from duplicate_cte
where row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `Company` text,
  `Location_HQ` text,
  `Industry` text,
  `Laid_Off_Count` text,
  `Date` text,
  `Source` text,
  `Funds_Raised` double DEFAULT NULL,
  `Stage` text,
  `Date_Added` text,
  `Country` text,
  `Percentage` text,
  `List_of_Employees_Laid_Off` text,
  `Row_Num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
	row_number() over(
	partition by 
    Company, Location_HQ, Industry, Laid_Off_Count, Percentage, Date, Stage, Funds_Raised, Country) as row_num 
	from layoffs_staging;

delete
from layoffs_staging2
where Row_Num > 1;

select *
from layoffs_staging2;

-- Standardizing Data

select Company, trim(Company)
from layoffs_staging2;

 update layoffs_staging2
 set Company = trim(Company);

select distinct Country
from layoffs_staging2
order by 1;

select `Date`
from layoffs_staging2;

update layoffs_staging2
set `Date` = STR_TO_DATE(Date, '%m/%d/%Y');

alter table layoffs_staging2
modify column `Date` Date;

select Company, Industry, Laid_Off_Count, Percentage, Country
from layoffs_staging2
WHERE COALESCE(Laid_Off_Count, '') = ''
and COALESCE(Percentage, '') = '';

delete 
from layoffs_staging2
WHERE COALESCE(Laid_Off_Count, '') = ''
and COALESCE(Percentage, '') = '';

select * 
from layoffs_staging2;

alter table layoffs_staging2
drop column Row_Num;
