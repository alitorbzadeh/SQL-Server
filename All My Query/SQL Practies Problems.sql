--------------------Northwind--------------------
USE Northwind
GO
--------------------Sample 1---------------------
--------------------Beginning--------------------
SELECT * 
FROM dbo.Shippers
--------------------Sample 2---------------------
SELECT CategoryName, [Description] 
FROM dbo.Categories
--------------------Sample 3---------------------
SELECT FirstName, LastName, HireDate 
FROM dbo.Employees
WHERE Title='Sales Representative'
--------------------Sample 4---------------------
SELECT *,FirstName, LastName, HireDate 
FROM dbo.Employees
WHERE Title='Sales Representative' AND Country='USA'
--------------------Sample 5---------------------
SELECT CONCAT_WS(' ', B.FirstName, B.LastName) AS [FullName],
	   A.OrderID,
	   D.ProductName,
	   A.OrderID,
	   A.OrderDate
FROM 
dbo.Orders AS A INNER JOIN dbo.Employees AS B
ON
A.EmployeeID=B.EmployeeID
INNER JOIN dbo.[Order Details] AS C
ON
A.OrderID=C.OrderID
INNER JOIN dbo.Products AS D
ON
C.ProductID=D.ProductID
WHERE B.EmployeeID=5
--------------------Sample 6---------------------
SELECT SupplierID,ContactName,ContactTitle
FROM dbo.Suppliers
WHERE ContactTitle <> 'Marketing Manager'
--------------------Sample 7---------------------
SELECT ProductID, ProductName  
FROM dbo.Products
WHERE ProductName LIKE 'queso%'
--------------------Sample 8---------------------
SELECT OrderID,CustomerID,ShipCountry
FROM dbo.Orders
WHERE ShipCountry in ('France','Belgium')
--------------------Sample 9---------------------
SELECT OrderID,CustomerID,ShipCountry
FROM dbo.Orders
WHERE ShipCountry in ('Brazil','Mexico','Argentina','Venezuela')
--------------------Sample 10---------------------
SELECT FirstName,LastName,Title,BirthDate
FROM dbo.Employees 
ORDER BY DATEDIFF(YEAR,BirthDate,GETDATE()) DESC
--------------------Sample 11---------------------
SELECT FirstName,LastName,Title,CONVERT(date,BirthDate)
FROM dbo.Employees 
ORDER BY DATEDIFF(YEAR,BirthDate,GETDATE()) DESC
--------------------Sample 12---------------------
SELECT FirstName,LastName,
CONCAT_WS(' ',FirstName,LastName) AS [FullName]
FROM dbo.Employees 
--------------------Sample 13---------------------
SELECT OrderID, ProductID, UnitPrice, Quantity,
UnitPrice*Quantity AS [solution]
FROM dbo.[Order Details]
--------------------Sample 14---------------------
-- Agregate Column: Count(CustomerID)
-- Non-Aggregate Column: -
SELECT Count(CustomerID) 
FROM dbo.Customers
--------------------Sample 15---------------------
--Solution 1
--Agreggate Column: MIN(YEAR(OrderDate))
--Non-Agreggate Column: OrderDate
SELECT TOP 1 OrderDate AS [FirstOrder]
FROM dbo.Orders
GROUP BY OrderDate
HAVING MIN(YEAR(OrderDate))=YEAR(OrderDate)
--Solution 2
SELECT TOP 1  OrderDate AS [FirstOrder]
FROM dbo.Orders 
ORDER BY OrderDate ASC
--Solution 3
SELECT X.FirstOrder 
FROM(
SELECT 
ROW_NUMBER() OVER(ORDER BY OrderDate ASC) AS RN,
OrderDate AS [FirstOrder]
FROM dbo.Orders) AS X
WHERE X.RN = 1
--------------------Sample 16---------------------
SELECT distinct Country
FROM dbo.Customers
ORDER BY Country ASC
--------------------Sample 17---------------------
--Aggregate Column: COUNT(ContactTitle) 
--Non-Aggregate Column: ContactTitle
SELECT ContactTitle, Count(ContactTitle) As [Count]
FROM dbo.Customers
GROUP BY ContactTitle
ORDER BY [Count] DESC
--------------------Sample 18---------------------
SELECT A.ProductID, A.ProductName, B.CompanyName
FROM 
dbo.Products AS A INNER JOIN dbo.Suppliers AS B
ON
A.SupplierID = B.SupplierID
ORDER BY ProductID
--------------------Sample 19---------------------
SELECT A.OrderID, CONVERT(date,A.OrderDate) AS [Orderdate],
B.CompanyName
FROM 
dbo.Orders AS A INNER JOIN dbo.Shippers AS B
ON
A.ShipVia = B.ShipperID
ORDER BY A.OrderDate
--------------------Sample 20---------------------
-------------------Intermediate-------------------
--Aggregate Column: Count(ProductID)
--Non-Aggregate Column: CategoryName
SELECT B.CategoryName, COUNT(A.ProductID) AS [TotalNumber]
FROM 
dbo.Products AS A INNER JOIN dbo.Categories AS B
ON
A.CategoryID=B.CategoryID
GROUP BY B.CategoryName
ORDER BY [TotalNumber] DESC
--------------------Sample 21---------------------
--Aggregate Column: Count(CustomerID)
--Non-Aggregate Column: Country, City
SELECT Country, City, COUNT(CustomerID) AS TotalNumber
FROM dbo.Customers
GROUP BY Country, City
ORDER BY TotalNumber DESC
--------------------Sample 22---------------------
SELECT ProductID, ProductName, UnitsInStock, ReorderLevel
FROM dbo.Products
WHERE UnitsInStock < ReorderLevel
ORDER BY ProductID ASC
--------------------Sample 23---------------------
SELECT *
FROM dbo.Products
WHERE UnitsInStock+UnitsOnOrder <= ReorderLevel
AND
	  Discontinued = 0
--------------------Sample 24---------------------
SELECT 
CustomerID, CompanyName, Region,
CASE WHEN Region IS NULL THEN 1
	 ELSE 0 END AS [Region1]
FROM dbo.Customers
ORDER BY [Region1], Region, CustomerID
--------------------Sample 25---------------------
--Aggregate Column: AVG(Freight)
--Non-Aggregate Column: ShipCountry
SELECT TOP (3) ShipCountry, AVG(Freight) AS [Average]
FROM dbo.Orders
GROUP BY ShipCountry
ORDER BY [Average] DESC
--------------------Sample 26---------------------
--Aggregate Column: AVG(Freight)
--Non-Aggregate Column: ShipCountry
SELECT TOP (3) ShipCountry, AVG(Freight) AS [Average]
FROM dbo.Orders
WHERE YEAR(OrderDate)=2015
GROUP BY ShipCountry
ORDER BY [Average] DESC
--------------------Sample 27----------------------
--No Expected Result
--------------------Sample 28----------------------
SELECT TOP 3
    ShipCountry,
    AVG(Freight) AS AverageFreight
FROM Orders
WHERE OrderDate >= (
    SELECT DATEADD(year, -1, MAX(OrderDate)) 
    FROM Orders
)
GROUP BY ShipCountry
ORDER BY AverageFreight DESC;
--------------------Sample 29----------------------
SELECT A.EmployeeID, A.LastName, B.OrderID, D.ProductName, C.Quantity
FROM
dbo.Employees AS A INNER JOIN dbo.Orders AS B
ON 
A.EmployeeID = B.EmployeeID
INNER JOIN dbo.[Order Details] AS C
ON 
B.OrderID = C.OrderID
INNER JOIN dbo.Products AS D
ON
D.ProductID = C.ProductID
--------------------Sample 30----------------------
SELECT CustomerID , NULL AS [OrderDate]
FROM dbo.Customers
WHERE CustomerID NOT IN (SELECT CustomerID  FROM dbo.Orders AS B)
--------------------Sample 31----------------------
SELECT CustomerID, NULL AS [CustomerID] 
FROM dbo.Customers
WHERE CustomerID 
NOT IN
(SELECT distinct CustomerID FROM Orders WHERE EmployeeID = 4)
--------------------Sample 32----------------------
SELECT RN.CustomerID, RN.CompanyName, RN.OrderID, 
SUM(RN.TotalOrderAmount) AS [TOTAL] 
FROM(
SELECT A.CustomerID, A.CompanyName, C.OrderID,
(C.Quantity*C.UnitPrice) AS [TotalOrderAmount],
B.OrderDate,C.Discount
FROM 
dbo.Customers AS A INNER JOIN dbo.Orders AS B
ON
A.CustomerID=B.CustomerID
INNER JOIN dbo.[Order Details] AS C
ON
B.OrderID=C.OrderID) AS RN
WHERE YEAR(RN.OrderDate)=1997 AND RN.Discount=0
GROUP BY RN.CustomerID, RN.CompanyName, RN.OrderID
HAVING SUM(RN.TotalOrderAmount) >= 10000
ORDER BY [TOTAL]
--------------------Sample 33----------------------
SELECT RN.CustomerID, RN.CompanyName, RN.OrderID, 
SUM(RN.TotalOrderAmount) AS [TOTAL] 
FROM(
SELECT A.CustomerID, A.CompanyName, C.OrderID,
(C.Quantity*C.UnitPrice) AS [TotalOrderAmount],

B.OrderDate,C.Discount
FROM 
dbo.Customers AS A INNER JOIN dbo.Orders AS B
ON
A.CustomerID=B.CustomerID
INNER JOIN dbo.[Order Details] AS C
ON
B.OrderID=C.OrderID) AS RN
WHERE YEAR(RN.OrderDate)=1998 
GROUP BY RN.CustomerID, RN.CompanyName, RN.OrderID
HAVING SUM(RN.TotalOrderAmount) >= 15000
ORDER BY [TOTAL]
--------------------Sample 34----------------------
SELECT RN.CustomerID, RN.CompanyName, 
SUM(RN.TotalWithDiscount) AS [TOTAL_DISCOUNT], 
SUM(RN.TotalWithoutDiscount) AS [TOTAL_WITHOUT_DISCOUNT]
FROM(
SELECT A.CustomerID, A.CompanyName, C.OrderID,
(C.Quantity*C.UnitPrice*(1-C.Discount)) AS [TotalWithDiscount],
(C.Quantity*C.UnitPrice) AS [TotalWithoutDiscount],
B.OrderDate,C.Discount
FROM 
dbo.Customers AS A INNER JOIN dbo.Orders AS B
ON
A.CustomerID=B.CustomerID
INNER JOIN dbo.[Order Details] AS C
ON
B.OrderID=C.OrderID) AS RN
WHERE YEAR(RN.OrderDate)=1998 
GROUP BY RN.CustomerID, RN.CompanyName, RN.OrderID
HAVING  SUM(RN.TotalWithoutDiscount)>15000
ORDER BY [TOTAL_DISCOUNT]
--------------------Sample 35----------------------
SELECT EmployeeID, OrderID, OrderDate FROM dbo.Orders
WHERE DAY(OrderDate) IN (31,30)
ORDER BY EmployeeID, OrderID
--------------------Sample 36----------------------
--Solution 1
SELECT TOP (10) OrderID, COUNT(*) 
FROM dbo.[Order Details]
WHERE OrderID IN (SELECT OrderID FROM dbo.Orders AS B)
GROUP BY OrderID 
ORDER BY COUNT(*) DESC
--Solution 2
SELECT TOP (10) OrderID, COUNT(*) 
FROM dbo.[Order Details] AS A
WHERE EXISTS(SELECT OrderID FROM dbo.Orders AS B WHERE B.OrderID=A.OrderID)
GROUP BY OrderID 
ORDER BY COUNT(*) DESC
--Solution 3
SELECT TOP (10) A.OrderID, COUNT(*) AS [Total]
FROM 
dbo.Orders AS A INNER JOIN dbo.[Order Details] AS B
ON
A.OrderID = B.OrderID
GROUP BY A.OrderID
ORDER BY [Total] DESC
--------------------Sample 37----------------------
SELECT TOP 2 PERCENT OrderID
FROM dbo.Orders
ORDER BY NEWID()
--------------------Sample 38----------------------
SELECT OrderID,Quantity
FROM dbo.[Order Details]
WHERE Quantity >= 60 
GROUP BY OrderID,Quantity
HAVING COUNT(*) > 1
--------------------Sample 39----------------------
SELECT OrderID,ProductID,UnitPrice,Q=Discount FROM dbo.[Order Details] AS B
WHERE EXISTS
(SELECT * FROM(
SELECT OrderID,Quantity
FROM dbo.[Order Details]
WHERE Quantity >= 60 
GROUP BY OrderID,Quantity
HAVING COUNT(*) > 1) AS A WHERE A.OrderID=B.OrderID)
--------------------Sample 40----------------------
--Not-Expected ANSWER
--------------------Sample 41----------------------
SELECT OrderID, OrderDate, RequiredDate, ShippedDate 
FROM dbo.Orders
WHERE RequiredDate < ShippedDate
--------------------Sample 42----------------------
SELECT X.EmployeeID, X.FullName, COUNT(*) 
FROM(
SELECT B.OrderID, B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName] 
FROM
dbo.Employees AS A INNER JOIN dbo.Orders AS B
ON
A.EmployeeID = B.EmployeeID
INNER JOIN dbo.[Order Details] AS C
ON 
B.OrderID = C.OrderID
WHERE B.RequiredDate < B.ShippedDate) AS X
GROUP BY GROUPING SETS((X.EmployeeID, X.FullName),())
ORDER BY COUNT(*) DESC
--------------------Sample 43----------------------
;WITH X AS(
SELECT B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
COUNT(B.EmployeeID) AS [Total]
FROM 
dbo.Employees AS A INNER JOIN  dbo.[Orders] AS B
ON
A.EmployeeID = B.EmployeeID
GROUP BY B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) 
),
Y AS (
SELECT B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
COUNT(B.EmployeeID) AS [Total]
FROM 
dbo.Employees AS A INNER JOIN  dbo.[Orders] AS B
ON
A.EmployeeID = B.EmployeeID
WHERE B.RequiredDate < B.ShippedDate
GROUP BY B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) 
)
SELECT A.EmployeeID, A.FullName, A.Total, B.Total AS [OrderRate] 
FROM 
X AS A INNER JOIN Y AS B
ON
A.EmployeeID = B.EmployeeID
ORDER BY Total DESC
--------------------Sample 44----------------------
--Its relatred to Left JOIN
--------------------Sample 45----------------------
--------------------Sample 46----------------------
;WITH X AS(
SELECT B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
COUNT(B.EmployeeID) AS [Total]
FROM 
dbo.Employees AS A INNER JOIN  dbo.[Orders] AS B
ON
A.EmployeeID = B.EmployeeID
GROUP BY B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) 
),
Y AS (
SELECT B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
COUNT(B.EmployeeID) AS [Total]
FROM 
dbo.Employees AS A INNER JOIN  dbo.[Orders] AS B
ON
A.EmployeeID = B.EmployeeID
WHERE B.RequiredDate < B.ShippedDate
GROUP BY B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) 
),
Z AS (
SELECT A.EmployeeID, A.Total, B.Total AS [OrderLate] , (CAST(B.Total AS float) / A.Total)*100 AS [Per]
FROM 
X AS A INNER JOIN Y AS B
ON 
A.EmployeeID = B.EmployeeID
)
SELECT Z.EmployeeID, Z.Total, Z.OrderLate, Z.[Per] FROM Z
--------------------Sample 47----------------------
;WITH X AS(
SELECT B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
COUNT(B.EmployeeID) AS [Total]
FROM 
dbo.Employees AS A INNER JOIN  dbo.[Orders] AS B
ON
A.EmployeeID = B.EmployeeID
GROUP BY B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) 
),
Y AS (
SELECT B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
COUNT(B.EmployeeID) AS [Total]
FROM 
dbo.Employees AS A INNER JOIN  dbo.[Orders] AS B
ON
A.EmployeeID = B.EmployeeID
WHERE B.RequiredDate < B.ShippedDate
GROUP BY B.EmployeeID, CONCAT_WS(' ', A.FirstName, A.LastName) 
),
Z AS (
SELECT A.EmployeeID, A.Total, B.Total AS [OrderLate] , CONVERT(decimal(10,2),(CAST(B.Total AS float) / A.Total)*100) AS [Per]
FROM 
X AS A INNER JOIN Y AS B
ON 
A.EmployeeID = B.EmployeeID
)
SELECT Z.EmployeeID, Z.Total, Z.OrderLate, Z.[Per] FROM Z
--------------------Sample 48----------------------
SELECT B.CustomerID, C.CompanyName, SUM(A.Quantity*A.UnitPrice) AS [TotalAmount],
CASE WHEN SUM(A.Quantity*A.UnitPrice) BETWEEN 0 AND 1000 THEN 'Low'
     WHEN  SUM(A.Quantity*A.UnitPrice) BETWEEN 1000 AND 5000 THEN 'Medium'
	 WHEN  SUM(A.Quantity*A.UnitPrice) BETWEEN 5000 AND 10000 THEN 'High'
	 WHEN  SUM(A.Quantity*A.UnitPrice) > 10000 THEN 'Very High' END AS [Kinds]
FROM 
dbo.[Order Details] AS A INNER JOIN dbo.Orders AS B
ON
A.OrderID = B.OrderID 
INNER JOIN dbo.Customers AS C
ON
C.CustomerID = B.CustomerID
WHERE B.OrderDate >= '1997-01-01' AND B.OrderDate < '1998-01-01'
GROUP BY B.CustomerID, C.CompanyName
--------------------Sample 49----------------------
--------------------Sample 50----------------------
;WITH X AS(
SELECT B.CustomerID, C.CompanyName, SUM(A.Quantity*A.UnitPrice) AS [TotalAmount],
CASE WHEN SUM(A.Quantity*A.UnitPrice) BETWEEN 0 AND 1000 THEN 'Low'
     WHEN  SUM(A.Quantity*A.UnitPrice) BETWEEN 1000 AND 5000 THEN 'Medium'
	 WHEN  SUM(A.Quantity*A.UnitPrice) BETWEEN 5000 AND 10000 THEN 'High'
	 WHEN  SUM(A.Quantity*A.UnitPrice) > 10000 THEN 'Very High' END AS [Kinds]
FROM 
dbo.[Order Details] AS A INNER JOIN dbo.Orders AS B
ON
A.OrderID = B.OrderID 
INNER JOIN dbo.Customers AS C
ON
C.CustomerID = B.CustomerID
WHERE B.OrderDate >= '1997-01-01' AND B.OrderDate < '1998-01-01'
GROUP BY B.CustomerID, C.CompanyName
), 
Y AS(
SELECT COUNT(1) AS [AllAmount] 
FROM X
),
Z AS(
SELECT X.Kinds AS [CustomerGroup], COUNT(X.Kinds) AS [TotalInGroup]
FROM X
GROUP BY X.Kinds
)
SELECT Z.CustomerGroup,Z.TotalInGroup,
CONVERT(decimal(10,2),(CAST(Z.TotalInGroup AS float)/Y.AllAmount))*100 AS  PercentageInGroup
FROM Y,Z
--------------------Sample 51----------------------
--------------------Sample 52----------------------
SELECT * FROM (
SELECT A.Country FROM dbo.Customers AS A
UNION
SELECT B.Country FROM dbo.Suppliers AS B) AS C
--------------------Sample 53----------------------
--(Outter Join)
--------------------Sample 54----------------------
--(Outter Join)
--------------------Sample 55----------------------
SELECT B.ShipCountry, B.CustomerID, B.OrderID, B.OrderDate FROM
(SELECT
DENSE_RANK() OVER(PARTITION BY A.ShipCountry ORDER BY A.OrderDate ASC) AS RN,
A.OrderID, A.ShipCountry,A.CustomerID,A.OrderDate FROM dbo.Orders AS A) AS B
WHERE B.RN=1
ORDER BY B.OrderID DESC
--------------------Sample 56----------------------
--------------------Sample 57----------------------