 -- Sample Exam (1)
------------------------------
USE AdventureWorksDW2022
GO
------------------------------
--Question (1)
SELECT X.EmployeeKey,X.FullName,X.CalendarYear,X.TotalSalesAmount FROM(
SELECT
DENSE_RANK() OVER(PARTITION BY B.CalendarYear ORDER BY SUM(A.SalesAmount) DESC) AS [RN],
A.EmployeeKey,CONCAT_WS(' ',C.FirstName,C.LastName) AS [FullName],
B.CalendarYear,SUM(A.SalesAmount) AS [TotalSalesAmount]
FROM
dbo.FactResellerSales AS A INNER JOIN dbo.DimDate AS B
ON 
A.DueDateKey = B.DateKey
INNER JOIN dbo.DimEmployee AS C
ON
C.EmployeeKey = A.EmployeeKey
GROUP BY  C.FirstName,C.LastName,A.EmployeeKey,B.CalendarYear) AS X
WHERE X.RN=1
ORDER BY X.CalendarYear 
------------------------------
--Question (2)
SELECT
DENSE_RANK()  OVER(PARTITION BY X.[FullName] ORDER BY X.[TotalSalesAmounQuota]DESC)
,X.EmployeeKey,X.FullName,X.CalendarYear,X.TotalSalesAmounQuota
FROM(
SELECT A.EmployeeKey, CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
C.CalendarYear, SUM(B.SalesAmountQuota) AS [TotalSalesAmounQuota]
FROM 
dbo.DimEmployee AS A INNER JOIN dbo.FactSalesQuota AS B
ON
A.EmployeeKey = B.EmployeeKey
INNER JOIN dbo.DimDate AS C
ON
B.DateKey = C.DateKey
GROUP BY A.EmployeeKey,A.FirstName, A.LastName, C.CalendarYear) AS X
------------------------------
--Question (3) 
SELECT
DENSE_RANK()  OVER(PARTITION BY X.[FullName] ORDER BY X.[DiffTotalSalesAmounQuota]DESC)
,X.EmployeeKey,X.FullName,X.CalendarYear,X.[DiffTotalSalesAmounQuota]
FROM(
SELECT A.EmployeeKey, CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
C.CalendarYear, (SUM(B.SalesAmountQuota)-SUM(D.SalesAmount)) AS [DiffTotalSalesAmounQuota]
FROM 
dbo.DimEmployee AS A INNER JOIN dbo.FactSalesQuota AS B
ON
A.EmployeeKey = B.EmployeeKey
INNER JOIN dbo.DimDate AS C
ON
B.DateKey = C.DateKey
INNER JOIN dbo.FactResellerSales AS D
ON
A.EmployeeKey = D.EmployeeKey
GROUP BY A.EmployeeKey,A.FirstName, A.LastName, C.CalendarYear) AS X
--------------------------------------------------------------------
--Question (4)
SELECT X.FullName,X.Gender,X.[CountOrderQuantity] FROM(
SELECT TOP (5) WITH TIES
DENSE_RANK()  OVER(PARTITION BY A.CustomerKey ORDER BY COUNT(B.OrderQuantity)) AS RN,
A.CustomerKey,CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],A.Gender,A.EnglishEducation,
A.YearlyIncome,COUNT(B.OrderQuantity) AS [CountOrderQuantity]
FROM 
dbo.DimCustomer AS A INNER JOIN dbo.FactInternetSales AS B
ON
A.CustomerKey = B.CustomerKey
GROUP BY A.CustomerKey,A.FirstName, A.LastName,A.Gender,A.EnglishEducation,A.YearlyIncome
ORDER BY COUNT(B.OrderQuantity) DESC) AS X
WHERE X.EnglishEducation IN ('master','bachelors') AND X.YearlyIncome BETWEEN 50000 AND 70000 AND X.FullName LIKE 'AM%'
---------------------------------------------------------------------
--Question (5)
;WITH X AS(
SELECT 
ROW_NUMBER() OVER(ORDER BY AVG(B.TaxAmt) DESC) AS RN, A.GeographyKey, A.BirthDate,
A.CustomerKey,CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName], AVG(B.TaxAmt) AS [AVGTaxAmt]
FROM 
dbo.DimCustomer AS A INNER JOIN dbo.FactInternetSales AS B
ON
A.CustomerKey = B.CustomerKey
WHERE A.Gender = 'F' 
GROUP BY A.CustomerKey,A.FirstName, A.LastName, A.GeographyKey, A.BirthDate
HAVING AVG(B.TaxAmt)>50
)
SELECT X.FullName,DATEDIFF(YEAR,X.BirthDate,GETDATE()) AS [AGE], Y.EnglishCountryRegionName AS [Country],
X.AVGTaxAmt
FROM
X INNER JOIN dbo.DimGeography AS Y
ON
Y.GeographyKey = X.GeographyKey
WHERE Y.EnglishCountryRegionName NOT IN ('Australia','United States')
---------------------------------------------------------------
--Question (6)
USE pubs
GO

SELECT TOP (5) CONCAT_WS(' ',A.FirstName, A.LastName )  AS [FullName]
FROM dbo.Employees AS A
WHERE A.HireDate >= '1990-01-01'
ORDER BY A.HireDate
----------------------------------------------------------------------
-- Sample Exam (2)
------------------------------
USE AdventureWorksDW2022
GO
------------------------------
--Question (1)

;WITH X AS (
SELECT A.ProductKey, C.ProductCategoryKey,A.EnglishProductName
FROM
dbo.DimProduct AS A INNER JOIN dbo.DimProductSubcategory AS B
ON
A.ProductSubcategoryKey = B.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory AS C
ON
C.ProductCategoryKey = B.ProductCategoryKey
),
-----------
Y AS(
SELECT E.ProductKey, D.FirstName, D.LastName,E.OrderDate,E.SalesAmount
FROM 
dbo.DimCustomer AS D INNER JOIN dbo.FactInternetSales AS E 
ON
D.CustomerKey = E.CustomerKey
INNER JOIN dbo.DimGeography AS F
ON
F.GeographyKey = D.GeographyKey
WHERE D.Gender = 'M'
AND 
DATEDIFF(YEAR,D.BirthDate,GETDATE()) BETWEEN 30 AND 50
AND 
F.EnglishCountryRegionName NOT IN ('Australia','Canada','United States')
),
---------
Z AS(
SELECT CONCAT_WS(' ',Y.FirstName,Y.LastName) AS [FullName],'YES' AS [Bike Category],
SUM(Y.SalesAmount) AS [TotalSalesAmount]
FROM
X INNER JOIN Y
ON
X.ProductKey = Y.ProductKey

WHERE X.EnglishProductName = 'Bikes' 
AND 
Y.OrderDate BETWEEN '2013-01-01' AND '2013-12-30'
GROUP BY Y.FirstName,Y.LastName
),
-----------
D AS (
SELECT CONCAT_WS(' ',Y.FirstName,Y.LastName) AS [FullName],
'NO' AS [Bike Category],
SUM(Y.SalesAmount) AS [TotalSalesAmount]
FROM
X INNER JOIN Y
ON
X.ProductKey = Y.ProductKey
WHERE X.EnglishProductName <> 'Bikes' 
AND 
Y.OrderDate BETWEEN '2012-01-01' AND '2012-12-30'
GROUP BY Y.FirstName,Y.LastName
)
SELECT 
DENSE_RANK()  OVER(PARTITION BY G.[Bike Category] ORDER BY G.TotalSalesAmount DESC) AS RN,
G.FullName,G.[Bike Category],G.TotalSalesAmount
FROM(
SELECT Z.FullName,Z.TotalSalesAmount,Z.[Bike Category] FROM Z
UNION
SELECT D.FullName, D.TotalSalesAmount,D.[Bike Category] FROM D) AS G
---------------------------------------------------------------------






