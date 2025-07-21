USE AdventureWorksDW2022
GO
------------------------------
--Question (1)
;WITH X AS(
SELECT E.CustomerKey, E.FirstName, E.LastName, D.OrderDate, C.EnglishProductCategoryName,D.SalesAmount
FROM 
dbo.DimProduct AS A INNER JOIN DBO.DimProductSubcategory AS B
ON
A.ProductSubcategoryKey=B.ProductSubcategoryKey
INNER JOIN DBO.DimProductCategory AS C
ON
C.ProductCategoryKey = B.ProductCategoryKey
INNER JOIN FactInternetSales AS D
ON
D.ProductKey = A.ProductKey
INNER JOIN DBO.DimCustomer AS E
ON
E.CustomerKey = D.CustomerKey
INNER JOIN DBO.DimGeography AS F
ON
F.GeographyKey = E.GeographyKey
WHERE
E.MaritalStatus = 'M'
AND
E.Gender = 'M'
AND
DATEDIFF(YEAR, E.BirthDate,GETDATE()) BETWEEN 30 AND 50
AND
F.EnglishCountryRegionName NOT IN ('Australia','United States','Canada')),

ALL_EX_2012_013 AS(
SELECT * FROM X
WHERE YEAR(X.OrderDate) NOT IN (2012,2013)
),
JUST_2012 AS(
SELECT * FROM X
WHERE YEAR(X.OrderDate) = 2012
AND 
X.EnglishProductCategoryName <> 'Bikes'
),
JUST_2013 AS(
SELECT * FROM X
WHERE YEAR(X.OrderDate) = 2013
AND 
X.EnglishProductCategoryName = 'Bikes'
),
[ALL] AS(
SELECT * FROM ALL_EX_2012_013
UNION ALL
SELECT * FROM JUST_2012
UNION ALL
SELECT * FROM JUST_2013
)
SELECT [ALL].CustomerKey, 
CONCAT_WS(' ',[ALL].FirstName,[ALL].LastName) AS [FullName],
SUM([ALL].SalesAmount) AS [TotalSalesAmoun]
FROM [ALL]
GROUP BY [ALL].CustomerKey,[ALL].FirstName,[ALL].LastName
ORDER BY [TotalSalesAmoun] DESC
------------------------------------------------------------
------------------------------
--Question (2)
SELECT X.ResellerName, X.OrderYear, X.TotalSalesAmount, X.AVGTaxAmount, X.TotalFreight FROM(
SELECT 
DENSE_RANK() OVER(PARTITION BY A.ResellerName ORDER BY SUM(D.SalesAmount) DESC) AS RN,
A.ResellerName, YEAR(D.OrderDate) AS [OrderYear],
SUM(D.SalesAmount) AS [TotalSalesAmount],
AVG(D.TaxAmt) AS [AVGTaxAmount],
SUM(D.Freight) AS [TotalFreight]
FROM 
dbo.DimReseller AS A INNER JOIN dbo.DimGeography AS B
ON
A.GeographyKey = B.GeographyKey
INNER JOIN dbo.DimCustomer AS C
ON
C.GeographyKey = B.GeographyKey
INNER JOIN dbo.FactInternetSales AS D
ON
D.CustomerKey = C.CustomerKey
GROUP BY A.ResellerName, YEAR(D.OrderDate)
)AS X
WHERE X.RN < = 2
------------------------------
--Question (3)
;WITH [FOR_2012] AS(
SELECT  A.City, SUM(C.SalesAmount) AS [TotalSalesAmoun]
FROM
dbo.DimGeography AS A INNER JOIN dbo.DimCustomer AS B
ON
A.GeographyKey = B.GeographyKey
INNER JOIN dbo.FactInternetSales AS C
ON 
C.CustomerKey = B.CustomerKey
WHERE 
A.EnglishCountryRegionName = 'Germany'
AND
C.OrderDate BETWEEN '2012-01-01' AND '2012-12-30'
GROUP BY  A.City
),
[FOR_2013] AS(
SELECT  A.City, SUM(C.SalesAmount) AS [TotalSalesAmoun]
FROM
dbo.DimGeography AS A INNER JOIN dbo.DimCustomer AS B
ON
A.GeographyKey = B.GeographyKey
INNER JOIN dbo.FactInternetSales AS C
ON 
C.CustomerKey = B.CustomerKey
WHERE 
A.EnglishCountryRegionName = 'Germany'
AND
C.OrderDate BETWEEN '2013-01-01' AND '2013-12-31'
GROUP BY  A.City
)
SELECT M.City, 
N.TotalSalesAmoun AS [TotalSalesAmoun_2012], 
M.TotalSalesAmoun  AS [TotalSalesAmoun_2013],
(M.TotalSalesAmoun-N.TotalSalesAmoun) AS [Differnce]
FROM 
[FOR_2012] AS N INNER JOIN [FOR_2013] AS M
ON
N.City = M.City
ORDER BY City 
------------------------------------------------
--Question (4)
;WITH X AS(
SELECT B.CustomerKey,
SUM(B.SalesAmount) AS [TotalSalesAmoun]
FROM dbo.FactInternetSales AS B
WHERE 
B.OrderDate BETWEEN '2013-01-01' AND '2013-12-31'
AND
B.CustomerKey IN (
SELECT DISTINCT A.CustomerKey FROM dbo.FactInternetSales AS A
WHERE A.OrderDate BETWEEN '2011-01-01' AND '2012-12-31')
GROUP BY B.CustomerKey
),
Y AS(
SELECT B.CustomerKey,
SUM(B.SalesAmount) AS [TotalSalesAmoun]
FROM dbo.FactInternetSales AS B
WHERE 
B.CustomerKey IN (
SELECT DISTINCT A.CustomerKey FROM dbo.FactInternetSales AS A
WHERE A.OrderDate BETWEEN '2011-01-01' AND '2012-12-31')
GROUP BY B.CustomerKey
)
SELECT X.CustomerKey, X.TotalSalesAmoun, Y.TotalSalesAmoun AS [ForAll] FROM X,Y
WHERE 
X.CustomerKey = Y.CustomerKey
AND
X.TotalSalesAmoun > 0.7*Y.TotalSalesAmoun
----------------------------------------------------------
--Question (5)
SELECT M.ProductKey, COUNT(M.OrderQuantity) AS [Number] FROM dbo.FactInternetSales AS M
WHERE
MONTH(M.OrderDate) IN (10,11,12)
AND
EXISTS (
SELECT X.ProductKey FROM(
SELECT C.ProductKey, C.EnglishProductName
FROM 
dbo.DimProductCategory AS A INNER JOIN dbo.DimProductSubcategory AS B
ON
A.ProductCategoryKey = B.ProductCategoryKey
INNER JOIN dbo.DimProduct AS C
ON
B.ProductSubcategoryKey = C.ProductSubcategoryKey
WHERE A.EnglishProductCategoryName = 'Bikes') AS X WHERE X.ProductKey = M.ProductKey)
GROUP BY M.ProductKey
HAVING COUNT(M.OrderQuantity) BETWEEN 10 AND 100
ORDER BY [Number] DESC
--------------------------------------
--Question (6)
;WITH X AS(
SELECT A.EmployeeKey, SUM(A.SalesAmountQuota) AS [SalesAmountQuota]  
FROM FactSalesQuota AS A
WHERE A.[Date] BETWEEN '2013-07-01' AND '2013-12-31'
GROUP BY A.EmployeeKey),
Y AS (
SELECT B.EmployeeKey, SUM(B.SalesAmount) AS [TotalSalesAmount]
FROM dbo.FactResellerSales  AS B
WHERE B.OrderDate BETWEEN '2013-07-01' AND '2013-12-31'
GROUP BY B.EmployeeKey)

SELECT A.EmployeeKey,A.SalesAmountQuota,B.TotalSalesAmount
FROM 
X AS A INNER JOIN Y AS B
ON
A.EmployeeKey = B.EmployeeKey
WHERE B.TotalSalesAmount > 0.6 * A.SalesAmountQuota





