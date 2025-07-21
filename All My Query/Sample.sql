----------------------Pups----------------------
--------------------Sample 1--------------------
--Queryy for retrive Book Name, Book Type, Book Price, Publication Date
USE pubs
go
SELECT title as N'نام کتاب',
       [type] as N'نوع کتاب',
	   price as N'قیمت کتاب',
	   pubdate as N'تاریخ انتشار' 
FROM DBO.titles

--------------------Sample 2--------------------
--Queryy for retrive Book Name, Book Price, Publication Date, Publication Season
SELECT title as N'نام کتاب', 
	   price as N'قیمت کتاب',
	   pubdate as N'تاریخ انتشار',
CASE   WHEN MONTH(pubdate) between 1 and 3 THEN N'بهار'
	   WHEN MONTH(pubdate) between 4 and 6 THEN N'تابستان'
	   WHEN MONTH(pubdate) between 7 and 9 THEN N'پاییز'
	   WHEN MONTH(pubdate) between 10 and 12 THEN N'زمستان'
	   END as N'فصل انتشار'
FROM dbo.titles

--------------------Sample 3--------------------
--Queryy for retrive Uniteis Names 'CA' --> کالیفرنیا,
--'MI' --> میشیگان,'OR' --> اورنج کانتی, other --> ایالت های دیگر
SELECT CONCAT_WS(' ', au_fname, au_lname) as N'نام کامل',
CASE   WHEN [state]='CA' THEN N'کالیفرنیا'
	   WHEN [state]='MI' THEN N'میشیگان'
	   WHEN [state]='OR' THEN N'اورنج کانتی'
	   ELSE N'ایالت های دیگر' END as N'شهر تولد'
FROM dbo.authors

--------------------Sample 4--------------------
--Agreagated Column: AVG(Price)
--Non-Agreggated Column: Type
SELECT [type],
	   AVG(Price)
FROM dbo.titles
GROUP BY [type]
--------------------Sample 5---------------------
--Queryy for retrive The Difference of Price of Each Book with The Average of all Books 
DECLARE @AVGprice money
SELECT @AVGprice=AVG(price) FROM dbo.titles
PRINT @AVGprice
SELECT title, [type], price,
	   price-@AVGprice AS [DIFF]
FROM dbo.titles
ORDER BY price DESC
--------------------Sample 6---------------------
SELECT title, [type],price,
(price-(SELECT AVG(price)FROM dbo.titles
WHERE [type]=OutterQuery.[type])) AS [DIFF]
FROM dbo.titles AS OutterQuery
--------------------Sample 7---------------------
--Solution 1
SELECT CONCAT_WS(' ',au_fname,au_lname) AS [FullName],
	   city
FROM dbo.authors
WHERE city in(select city from dbo.publishers)
--Solution 2
SELECT CONCAT_WS(' ',au_fname,au_lname) AS [FullName], city
FROM dbo.authors AS OutterQuery
WHERE EXISTS
(SELECT city FROM dbo.publishers WHERE city=OutterQuery.city)
--------------------Sample 8---------------------
SELECT title, [type], price
FROM dbo.titles AS A
WHERE price = (SELECT MAX(price) FROM dbo.titles AS B WHERE B.[type]=A.[type])
ORDER BY price DESC
--------------------Sample 9---------------------
SELECT title, [type], price
FROM dbo.titles AS A
WHERE title in (SELECT top 1 with ties title FROM dbo.titles AS B WHERE B.[type]=A.[type] order by price DESC)
ORDER BY price DESC
--------------------Sample 10---------------------
SELECT A.title, A.[type], A.price FROM
(SELECT 
DENSE_RANK()  OVER(PARTITION BY [type] ORDER BY price DESC) AS RN,
title, [type],price
FROM dbo.titles) AS A
WHERE A.RN =1
ORDER BY A.price DESC
ORDER BY price DESC
--------------------Sample 11---------------------
--Query FROM dbo.authors and dbo.titles for: title,type
--price,writer
SELECT
A.title AS [NameBook],
A.[type] AS [Kind],
A.price AS [Price],
CONCAT_WS(' ', C.au_fname, C.au_lname) AS [FullName]
FROM
dbo.titles AS A 
INNER JOIN dbo.titleauthor AS B
ON
A.title_id = B.title_id
INNER JOIN dbo.authors AS C
ON
B.au_id = C.au_id
ORDER BY price DESC
--------------------Sample 12---------------------
--Query For retrieving Book Name, Number Of Writers and order it by number
SELECT 
A.title AS [BookName],
COUNT(C.au_id) AS [Number]
FROM
dbo.titles AS A 
INNER JOIN dbo.titleauthor AS B
ON
A.title_id = B.title_id
INNER JOIN dbo.authors AS C
ON
B.au_id = C.au_id
GROUP BY A.title
ORDER BY [Number] DESC
--------------------Sample 13---------------------
--Query For retrieving Book Name, Number Of Writers and order it by number
SELECT titles.type AS Type, titles.title AS Name, titles.price AS Price, COUNT(titleauthor.au_id) AS Number
FROM     titleauthor INNER JOIN
                  titles ON titleauthor.title_id = titles.title_id
GROUP BY titles.type, titles.title, titles.price
ORDER BY COUNT(titleauthor.au_id) DESC


----------------------AdventureWorksDW2022----------------------
----------------------------Sample 1----------------------------
--Queryy for retrivING first 5 Costumer by order on Number of children
USE AdventureWorksDW2022
GO
SELECT TOP 5 with ties  CONCAT_WS(' ',FirstName,LastName) as [Full Name],
	   TotalChildren as [NumberOfChildren]
FROM dbo.DimCustomer
ORDER BY TotalChildren DESC

----------------------------Sample 2----------------------------
--Retrive Titanic DataSet with CSV Format
SELECT * FROM dbo.titanic

----------------------------Sample 3----------------------------
--Retrive Titanic DataSet with CSV Format and Store new Data into new Table
SELECT [Name] as [FullName],
	   Sex as [Gender],
	   Ticket as [Lisence]
INTO dbo.titanic_titanic
FROM dbo.titanic
SELECT * FROM titanic_titanic

----------------------------Sample 4----------------------------
--Generate Random Data
SELECT TOP 70 percent *,
       NEWID() as [GUID]
INTO pubs.dbo.SecondTitanic
FROM titanic_titanic

----------------------------Sample 5----------------------------
--Queryy for retriving all employee whose first names start with 'Farhad' and
-- LastName starts with 'L' character
SELECT EmployeeKey as [ID],
	   CONCAT_WS(' ', FirstName,LastName) as [FullName],
	   BirthDate,
	   NEWID() as [GUID]
FROM dbo.DimEmployee
WHERE FirstName like '[D-M]%'
ORDER BY [GUID]

----------------------------Sample 6----------------------------
--Queryy for retriving ProductAlterKey with:
-- 1) Start with 'C' character, 2) A<Second Character<M, 3)Third Character= -
-- 4) Forth Character shuold be Number, 5) other characters not care
SELECT ProductKey as [ID],
	   EnglishProductName as [Product],
	   ProductAlternateKey
FROM DimProduct
WHERE ProductAlternateKey like 'C[A-M]-[1-9]%'

----------------------------Sample 7-----------------------------
--Queryy for retriving for Costomer Name, Costumer Age, Sex,YearlyIncome,
--NumberOfChildren, Education with under these conditions in the below:
--1) 50 < YearlyIncome < 100, 2)NumberOfChildren in {1,4,5}
--3) Costumer Name satrts with 'M' and Second Letter should be [c-z] and other not care
SELECT CONCAT_WS(' ', FirstName, LastName) as [FullName],
	   DATEDIFF(YEAR, BirthDate, GETDATE()) as [Age],
	   Gender as Sex,
	   YearlyIncome as [Yealy Income],
	   TotalChildren as [NumberOfChildren],
	   EnglishEducation as [EducationLevel]
FROM dbo.DimCustomer
WHERE YearlyIncome between 50000 and 100000 and
	  TotalChildren not in (1, 4 ,5) and
	  FirstName like 'M_[c-z]%'

----------------------------Sample 8----------------------------
--Queryy for retriving for Products: 
--1) with {Baleck,Silver} Color, 2)List Price must not be 'NULL'
--3) ProductAlternateKey starts with [a-m], second starts with [n-z],
-- Third starts with '-' and other not care
SELECT ProductAlternateKey,
	   EnglishProductName as [Name],
	   Color
FROM dbo.DimProduct
WHERE ProductAlternateKey like '[a-m][n-z]-%' and
	  Color in ('Black','Silver')

----------------------------Sample 9----------------------------
--Queryy for retriving for Employee Name, Employee Age, Department, ExperianceYear,
--with under these conditions in the below:1) Department <> Production,
--2) 30< BaseRate <60, 3) 20 < VacationHour < 40
SELECT CONCAT_WS(' ', FirstName, LastName) as [FullName],
	   DATEDIFF(YEAR, BirthDate, GETDATE()) as [Age],
	   DepartmentName,
	   DATEDIFF(YEAR, StartDate,GETDATE()) as [ExperianceYear]
FROM dbo.DimEmployee
WHERE DepartmentName <> 'Production' and
	  BaseRate between 30 and 60 and
	  VacationHours between 20 and 40

----------------------------Sample 10---------------------------
--Agreagated Column: AVG(YearlyIncome)
--Non-Agreggated Column: EnglishEducation, Sxe
SELECT EnglishEducation,
	   Gender,
	   AVG(YearlyIncome)
FROM dbo.DimCustomer
GROUP BY GROUPING SETS((EnglishEducation,Gender),())
----------------------------Sample 11---------------------------
--Aggregate Column: Max(Age), Min(Age)
--Non-Aggregate Column: EnglishEducation
SELECT EnglishEducation,
	   MAX(DATEDIFF(YEAR,BirthDate,GETDATE())) AS [oldest],
	   MIN(DATEDIFF(YEAR,BirthDate,GETDATE())) AS [youngest]
FROM dbo.DimCustomer
GROUP BY EnglishEducation
ORDER BY EnglishEducation ASC
----------------------------Sample 12---------------------------
--Aggregate Column: AVG(YearlyIncome)
--Non-Aggregate Column: EnglishOccupation
SELECT EnglishOccupation,
	   AVG(YearlyIncome)
FROM dbo.DimCustomer
GROUP BY EnglishOccupation
----------------------------Sample 13---------------------------
--Aggregate Column: Count(costumerkey)
--Non-Aggregate Column: Year
SELECT YEAR(BirthDate) AS [BirthDate],
	   COUNT(CustomerKey)
FROM dbo.DimCustomer
GROUP BY YEAR(BirthDate)
ORDER BY [BirthDate] DESC
----------------------------Sample 14---------------------------
--Aggregate Column: Count(customerkey)
--Non-Aggregate Column: Gender, MaritalStatus, Department
SELECT Gender AS [SEX],
	   MaritalStatus,
	   DepartmentName,
	   COUNT(EmployeeKey) AS [NumberOfEmployee],
	   AVG(VacationHours) AS [Vacation]
FROM dbo.DimEmployee
GROUP BY Gender, MaritalStatus,DepartmentName
ORDER BY DepartmentName
----------------------------Sample 15---------------------------
--Aggregate Column: Count(customerkey)
--Non-Aggregate Column: (Gender, MaritalStatus, Department),(Gender,Marital)(Gender)()
SELECT Gender AS [SEX],
	   MaritalStatus,
	   DepartmentName,
	   COUNT(EmployeeKey) AS [NumberOfEmployee],
	   AVG(VacationHours) AS [Vacation]
FROM dbo.DimEmployee
GROUP BY GROUPING SETs((Gender, MaritalStatus,DepartmentName),
					   (),(Gender,MaritalStatus),(Gender)) 
ORDER BY DepartmentName
----------------------------Sample 16---------------------------
--Aggregate Column: AVG(YearlyIncome)
--Non-Aggregate Column: (Gender,MaritalStatus,AgeGroup),(),(Gender),(AgeGroup)
SELECT Gender,MaritalStatus,
CASE WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) < 40 THEN 'Young'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) between 40 and 60 THEN 'MiddleAge'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) between 60 and 80 THEN 'Age'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) > 80 THEN 'Aged'
END AS [AgeGroup], AVG(YearlyIncome)
FROM dbo.DimCustomer
GROUP BY GROUPING SETS((Gender,MaritalStatus,
CASE WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) < 40 THEN 'Young'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) between 40 and 60 THEN 'MiddleAge'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) between 60 and 80 THEN 'Age'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) > 80 THEN 'Aged' END),(),(Gender),
(CASE WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) < 40 THEN 'Young'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) between 40 and 60 THEN 'MiddleAge'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) between 60 and 80 THEN 'Age'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) > 80 THEN 'Aged' END))
ORDER BY MaritalStatus
----------------------------Sample 17---------------------------
--Aggregate Column: AVG(YearlyIncome)
--Non-Aggregate Column: (Gender,MaritalStatus,AgeGroup),(),(Gender),(AgeGroup)
SELECT Dev.Gender,Dev.MaritalStatus,Dev.AgeGroup,
	   AVG(Dev.YearlyIncome) AS [YearlyIncome] 
FROM 
(SELECT Gender, MaritalStatus,YearlyIncome,
CASE WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) < 40 THEN 'Young'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) between 40 and 60 THEN 'MiddleAge'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) between 60 and 80 THEN 'Age'
	 WHEN DATEDIFF(YEAR,BirthDate,GETDATE()) > 80 THEN 'Aged'
END AS [AgeGroup]
FROM dbo.DimCustomer) AS Dev
GROUP BY GROUPING SETS((),(Dev.Gender),(Dev.AgeGroup),(Dev.Gender,Dev.MaritalStatus,Dev.AgeGroup))
----------------------------Sample 18---------------------------
--Query for retriveing 10 costumers with maximum of number of order on 2013
SELECT TOP 10 with ties
CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
SUM(B.OrderQuantity) AS [NumberOfOrder]
FROM
dbo.DimCustomer AS A INNER JOIN dbo.FactInternetSales AS B
ON
A.CustomerKey = B.CustomerKey
WHERE YEAR(B.OrderDate)=2013
GROUP BY CONCAT_WS(' ', A.FirstName, A.LastName)
ORDER BY SUM(B.OrderQuantity) DESC, [FullName] DESC
----------------------------Sample 19---------------------------
SELECT * FROM(
SELECT
DENSE_RANK() OVER(PARTITION BY C.EnglishCountryRegionName ORDER BY SUM(B.SalesAmount) DESC) AS RN,
A.CustomerKey AS [ID],
CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
C.EnglishCountryRegionName,
SUM(B.SalesAmount) AS [SalesOfAmount],
AVG(B.Freight) AS [Average]
FROM
dbo.DimCustomer AS A JOIN dbo.FactInternetSales AS B
ON
A.CustomerKey = B.CustomerKey
JOIN dbo.DimGeography AS C
ON
A.GeographyKey = C.GeographyKey
GROUP BY CONCAT_WS(' ', A.FirstName, A.LastName), 
		 C.EnglishCountryRegionName,A.CustomerKey) AS T
WHERE RN <= 5
----------------------------Sample 20---------------------------
;WITH X AS (
SELECT
DENSE_RANK() OVER(PARTITION BY C.EnglishCountryRegionName ORDER BY SUM(B.SalesAmount) DESC) AS RN,
A.CustomerKey AS [ID],
CONCAT_WS(' ', A.FirstName, A.LastName) AS [FullName],
C.EnglishCountryRegionName,
SUM(B.SalesAmount) AS [SalesOfAmount],
AVG(B.Freight) AS [Average]
FROM
dbo.DimCustomer AS A JOIN dbo.FactInternetSales AS B
ON
A.CustomerKey = B.CustomerKey
JOIN dbo.DimGeography AS C
ON
A.GeographyKey = C.GeographyKey
GROUP BY CONCAT_WS(' ', A.FirstName, A.LastName), 
		 C.EnglishCountryRegionName,A.CustomerKey
)
SELECT X.RN, X.FullName, X.EnglishCountryRegionName, X.SalesOfAmount, X.Average FROM X
WHERE X.RN<=5
----------------------------Sample 21---------------------------
--Query for retriveing 10 costumers with maximum of number of order on 2013
SELECT TOP (10) WITH TIES DimCustomer.CustomerKey, CONCAT_WS(DimCustomer.FirstName, DimCustomer.MiddleName, DimCustomer.LastName) AS FullName, SUM(FactInternetSales.OrderQuantity) AS Amount
FROM     DimCustomer INNER JOIN
                  FactInternetSales ON DimCustomer.CustomerKey = FactInternetSales.CustomerKey
WHERE  (YEAR(FactInternetSales.OrderDate) = 2013)
GROUP BY DimCustomer.CustomerKey, CONCAT_WS(DimCustomer.FirstName, DimCustomer.MiddleName, DimCustomer.LastName)
ORDER BY Amount DESC
----------------------------Sample 22---------------------------
SELECT * FROM
(SELECT
DENSE_RANK() OVER(PARTITION BY DimGeography.EnglishCountryRegionName ORDER BY SUM(FactInternetSales.SalesAmount) DESC) AS RN,
CONCAT_WS(DimCustomer.FirstName, DimCustomer.MiddleName, DimCustomer.LastName) AS [FullName], DimGeography.EnglishCountryRegionName, SUM(FactInternetSales.SalesAmount) AS Expr2, AVG(FactInternetSales.Freight) AS Expr1
FROM     DimCustomer INNER JOIN
                  DimGeography ON DimCustomer.GeographyKey = DimGeography.GeographyKey INNER JOIN
                  FactInternetSales ON DimCustomer.CustomerKey = FactInternetSales.CustomerKey
GROUP BY CONCAT_WS(DimCustomer.FirstName, DimCustomer.MiddleName, DimCustomer.LastName), DimGeography.EnglishCountryRegionName) AS X
WHERE X.RN<5
----------------------------Sample 23---------------------------