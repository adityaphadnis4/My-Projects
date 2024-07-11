-- Exploratory Data Analysis

select * 
from layoffs_staging2;

-- Looking at Percenage to see how big these Layoffs were
select max(Percentage), min(Percentage) 
from layoffs_staging2
where (Percentage is not null or COALESCE(Percentage, '') != '');

-- --------------------------------------------------------------------------------------------------------------------------------------

-- Which Companies had 100% of their company laid off
select * 
from layoffs_staging2
where Percentage = 1;
-- These are mostly startups or small scale business

-- ----------------------------------------------------------------------------------------------------------------------------------------

-- In order to find how big some of these Companies were, I used order by Funds Raised
select * 
from layoffs_staging2
where Percentage = 1
order by Funds_Raised desc;
-- Britishvolt is an EV company who raised $2.4B
-- Deliveroo Australia raised more than $1.5B and went under. Thats too bad!

-- ---------------------------------------------------------------------------------------------------------------------------------------

-- Companies with biggest single Layoff

select Company, Laid_Off_Count
from layoffs_staging2
order by 2 desc
limit 5;
-- A company like Lyft had to lay off 982 employees in a single day.

-- ----------------------------------------------------------------------------------------------------------------------------------------

-- Companies with the most total layoffs
select Company, sum(Laid_Off_Count)
from layoffs_staging2
group by Company
order by 2 desc
limit 10;
-- Amazon laid off the most out of all companies.
-- Top 3 Companies are Amazon, Meta, and Tesla in that order.

-- ----------------------------------------------------------------------------------------------------------------------------------------

-- Companies with the most total layoffs by location
select Location_HQ, sum(Laid_Off_Count)
from layoffs_staging2
group by Location_HQ
order by 2 desc
limit 10;
-- People from SF Bay Area are let go the most, in comparison to any other locations.

-- ----------------------------------------------------------------------------------------------------------------------------------------

-- Total Layoff in the past 3 Years
select Country, sum(Laid_Off_Count)
from layoffs_staging2
group by Country
order by 2 desc;
-- United States has layed off almost half a million employees in the last 3 years. 2nd is India - 47127 only!!

select Year(`Date`), sum(Laid_Off_Count)
from layoffs_staging2
group by Year(`Date`)
order by 2 desc;
-- Most lay offs took place in the year 2023, then 2022. Layoffs of the rest of the years is nothing in comparison.
-- Although the data does indicate that there will more layoffs in the year 2024 than in the year 2023.alter

select Industry, sum(Laid_Off_Count)
from layoffs_staging2
group by Industry
order by 2 desc;
-- The Retail and Consumer Indusrty have had almost similar number of layoffs, in the ballpark of 65k.
-- Such is the case with Transportation and other industries - around 55k.

-- ----------------------------------------------------------------------------------------------------------------------------------------

-- Now let us look the Layoffs per Year
-- I will use CTEs for that
with company_year as 
(
	select Company, Year(`Date`) as Years, sum(Laid_Off_Count) as Total_Layoffs
    from layoffs_staging2
    group by Company, Year(`Date`)
),
company_year_rank as
(
	select Company, Years, Total_Layoffs, dense_rank() over
    (
		partition by Years
        order by Total_Layoffs desc
    ) as Ranking
    from company_year
    
)
select Company, Years, Total_Layoffs, Ranking
from company_year_rank
where Ranking <= 3
and Years is not null
order by Years asc, Total_Layoffs;

-- ----------------------------------------------------------------------------------------------------------------------------------------

-- Rolling total of Layoffs per month
select substring(`Date`,1,7) as Dates, sum(Laid_Off_Count) as Total_Layoffs
from layoffs_staging2
group by Dates
order by Dates asc;

-- Now I will use the above in a CTE
with rolling_total as
(
	select substring(`Date`,1,7) as `Month`, sum(Laid_Off_Count) as total_layoffs
    from layoffs_staging2
    where substring(`Date`,1,7) is not null
    group by `Month`
    order by 1 asc
)
select `Month`, total_layoffs,
sum(total_layoffs) over(order by `Month`) as Rolling_Total
from rolling_total;


