USE [Airline Loyalty Program];

--Retrieving the customer loyalty activity table
SELECT * from [Customer Loyalty Activity];

/*Overall trends in loyalty point accumilation and redemption over the years*/
SELECT Year, SUM(CAST([Points Redeemed] AS decimal(10,0)))  As "Redeemed Points", SUM(CAST([Points Accumulated] AS decimal(10,0)))  As "Accumulated Points" 
FROM [Customer Loyalty Activity] 
GROUP BY Year
ORDER BY Year; 

/*Dollar cost of points redeemed per month*/
SELECT SUM(CAST([Dollar Cost Points Redeemed] AS INT)) As "Dollar Cost of Points Redeemed",[Month], [Year] 
FROM [Customer Loyalty Activity] 
GROUP BY Month, Year 
ORDER BY Month ASC, Year;

--Retrieving Customer Loyalty History
SELECT * from [Customer Loyalty  History];

/*Distribution of customers accross different countries, provinces and cities*/
SELECT COUNT(*) AS "Customer Distribution", [Country], [Province], [City] 
FROM [Customer Loyalty  History] 
GROUP BY Country, Province, City;

SELECT COUNT(*) AS "Customer Distribution", [Country], [Province], [City], [Enrollment Year]
FROM [Customer Loyalty  History] GROUP BY Country, Province, City, "Enrollment Year"
ORDER BY [Enrollment Year], Province ASC;

/*Distribution of Loyalty Card Status*/
SELECT COUNT([Loyalty Card]) AS "Loyalty Card Distribution", [Loyalty Card]   
FROM [Customer Loyalty  History]
GROUP BY [Loyalty Card];

/*Distibution of Loyalty Card by Province & Cities per enrollment year*/
SELECT COUNT([Loyalty Card]) AS "Loyalty Card Distribution", [Loyalty Card], [Province], [City], [Enrollment Year]
FROM [Customer Loyalty  History]
GROUP BY [Loyalty Card],[Province], [City], "Enrollment Year" 
ORDER BY "Enrollment Year" ASC;

/*Distribution of customers based on Gender per year*/
SELECT COUNT(*) AS "Customer Distribution", [Gender], [Enrollment Year]
FROM [Customer Loyalty  History]
GROUP BY [Gender], [Enrollment Year]
ORDER BY [Enrollment Year];

/*Distribution of customers based on their marital status $ Education Level*/
SELECT COUNT(*) AS "Customer Distribution", [Marital Status], [Education]
FROM [Customer Loyalty  History]
GROUP BY [Marital Status], [Education];

SELECT COUNT(*) AS "Customer Distribution", [Marital Status], [Education], [Enrollment Year] 
FROM [Customer Loyalty  History]
GROUP BY [Marital Status], [Education], [Enrollment Year] 
ORDER BY[Enrollment Year];

--Joining Tables
/*Correlation of customer points accumilation and Customers's province*/
SELECT SUM(CAST("Points Accumulated" AS DECIMAL(10,1))) AS "Points Accumulated", Province
FROM [Customer Loyalty Activity] inner join [Customer Loyalty  History]
ON [Customer Loyalty  History]."Loyalty Number" = [Customer Loyalty Activity]."Loyalty Number"
GROUP BY Province;

/*Average salary of customer based on their loyalty card status */
SELECT AVG(CAST("Salary" AS INT)) As "Average Salary", [Loyalty Card]
FROM [Customer Loyalty  History]
GROUP BY [Loyalty Card] 

/*Average distance travelled by customers in each province*/
SELECT AVG(CAST(Distance AS INT)) AS "Average Distance Travelled", Province
FROM [Customer Loyalty Activity]
inner join [Customer Loyalty  History]
ON [Customer Loyalty Activity]."Loyalty Number" = [Customer Loyalty  History]."Loyalty Number" 
GROUP BY Province;

/*Comparison of Dollar Coin Reedemed across different Education Levels*/
SELECT SUM(CAST("Dollar Cost Points Redeemed" AS INT)) AS "Dollar Cost Points Redeemed", Education
FROM [Customer Loyalty Activity] 
right join [Customer Loyalty  History] 
ON [Customer Loyalty Activity]."Loyalty Number" = [Customer Loyalty  History]."Loyalty Number"
GROUP BY Education;

/*Months with the highest flights booked*/
SELECT Top 3 SUM(CAST([Total Flights] AS INT)) As "Total Flights", Month
FROM[Customer Loyalty Activity]
GROUP BY Month  
ORDER BY [Total Flights] DESC;

 /*Average CLV for customers in the different cities*/
SELECT AVG(CONVERT(DECIMAL(10,2), "CLV")) AS "Customer Lifetime Value", City
FROM[Customer Loyalty  History]
GROUP BY City;

/*Correlation of Employment Type and customer gender*/
SELECT "Enrollment Type", "Gender", COUNT(*) AS Count
FROM [Customer Loyalty  History]
GROUP BY [Enrollment Type], [Gender]

/*Average annual income of customers in the different loyalty card status*/
SELECT AVG(CONVERT(INT, "Salary")) AS "Average Salary", "Loyalty Card" 
FROM [Customer Loyalty  History]
GROUP BY "Loyalty Card";

/*Trends of Customer membership enrollment and cancellation over the years*/
SELECT COUNT("Enrollment Year") AS "Total Enrolled Per Year","Enrollment Year", 'Enrolled' AS "Action"
from [Customer Loyalty  History] GROUP BY "Enrollment Year" 
UNION 
SELECT COUNT(*) AS "Total Cancellations Per Year","Cancellation Year", 'Cancelled' AS "Action"
from [Customer Loyalty  History] WHERE "Cancellation Year" IS NOT NULL GROUP BY "Cancellation Year";

/*Average dollar cost of points redeemed per distance traveled*/
SELECT
    AVG(
        CASE
            WHEN "Distance" <> 0 THEN CONVERT(DECIMAL(10, 2), "Dollar Cost Points Redeemed") / "Distance" --If "Distance" is not zero, it performs the division, otherwise, it returns NULL
            ELSE NULL 
        END
    ) AS Avg_Cost_Per_Distance
FROM
    [Customer Loyalty Activity];

/*Average CLV of customers based on their Marital status*/
Select AVG(CAST("CLV" AS DECIMAL(10,2))) AS "Average Customer Lifetime Value", "Marital Status"
FROM [Customer Loyalty  History] 
GROUP BY "Marital Status";

/*Effects of loyalty card status on the enrollment and cancellation trends*/
SELECT
    main."Enrollment Year",
    main."Enrolled Customers",
    sub."Cancellation Year",
    sub."Cancelled Customers",
    sub."Loyalty Card"
    
FROM
    (
        SELECT
            COUNT("Enrollment Year") AS "Enrolled Customers",
            "Enrollment Year",
            "Loyalty Card"
        FROM
            [Customer Loyalty  History]
        GROUP BY
            "Enrollment Year", "Loyalty Card"  
		
    ) AS main
JOIN
    (
        SELECT
            COUNT("Cancellation Year") AS "Cancelled Customers",
            "Loyalty Card",
            "Cancellation Year"
        FROM
            [Customer Loyalty  History]
        WHERE
            "Cancellation Year" <> 0
        GROUP BY
            "Loyalty Card", "Cancellation Year" 
		
    ) AS sub
ON
    main."Loyalty Card" = sub."Loyalty Card" AND main."Enrollment Year" = sub."Cancellation Year"

ORDER BY sub."Cancellation Year", main."Enrollment Year";

/*Distance travelled and points redeemed per city*/
SELECT SUM(CAST([Distance] AS INT)) AS "Total Distance",  SUM(CAST([Points Redeemed] AS INT)) AS "Total Points Redeemed", City 
FROM [Customer Loyalty Activity] join [Customer Loyalty  History]
ON [Customer Loyalty Activity]."Loyalty Number" = [Customer Loyalty  History]."Loyalty Number"
Group by City order by City ASC;

 /*Correlation of Enrollment Month and Loyalty Points*/
 SELECT "Enrollment Year", "Enrollment Month", SUM(CAST("Points Accumulated" AS decimal(10,1))) AS "Points Accumulated"
 from [Customer Loyalty  History] 
 Inner Join [Customer Loyalty Activity]
 ON [Customer Loyalty  History]."Loyalty Number"=[Customer Loyalty Activity]."Loyalty Number"
 GROUP BY "Enrollment Month", "Enrollment Year" ORDER BY "Enrollment Month", "Enrollment Year";

 /*Trends in Loyalty Points accumulation and redemption based on quarterly basis*/
SELECT 
    "Year",
    DATEPART(QUARTER, CONVERT(DATE, CAST("Year" AS VARCHAR) + '-' + CAST(MIN("Month") AS VARCHAR) + '-01')) AS "Quarter",
    SUM(CAST("Points Accumulated" AS DECIMAL(10,1))) AS "Points Accumulated",
    SUM(CAST("Points Redeemed" AS DECIMAL(10,1))) AS "Points Redeemed"
FROM 
    [Customer Loyalty Activity]
GROUP BY 
    "Year", DATEPART(QUARTER, CONVERT(DATE, CAST("Year" AS VARCHAR) + '-' + CAST("Month" AS VARCHAR) + '-01'))
ORDER BY 
    "Year", "Quarter";





