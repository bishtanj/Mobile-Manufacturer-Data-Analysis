--SQL Advance Case Study


--Q1--BEGIN 
  
  SELECT DISTINCT L.State FROM DIM_LOCATION AS L
  INNER JOIN FACT_TRANSACTIONS AS T
  ON L.IDLocation= T.IDLocation
  INNER JOIN DIM_MODEL AS M
  ON M.IDModel= T.IDModel
  WHERE YEAR(T.Date) >= 2005
 

--Q1--END

--Q2--BEGIN

  SELECT TOP 1 L.State, COUNT(T.Quantity) AS CELL_COUNT
  FROM DIM_LOCATION AS L
  INNER JOIN FACT_TRANSACTIONS AS T 
  ON L.IDLocation=T.IDLocation
  INNER JOIN DIM_MODEL AS M
  ON M.IDModel= T.IDModel
  INNER JOIN DIM_MANUFACTURER AS N
  ON M.IDManufacturer=N.IDManufacturer
  WHERE N.Manufacturer_Name= 'Samsung'
  AND L.Country= 'US'
  GROUP BY L.State
  ORDER BY CELL_COUNT DESC



--Q2--END

--Q3--BEGIN      
	
  SELECT M.Model_Name, L.ZipCode, L.State , COUNT(T.IDCustomer) AS Tran_Count
  FROM DIM_MODEL AS M
  INNER JOIN FACT_TRANSACTIONS AS T
  ON M.IDModel= T.IDModel
  INNER JOIN DIM_LOCATION AS L
  ON T.IDLocation=L.IDLocation
  GROUP BY M.Model_Name, L.ZipCode, L.State




--Q3--END

--Q4--BEGIN


SELECT TOP 1 Manufacturer_Name, Model_Name , Unit_price
FROM DIM_MODEL AS M
INNER JOIN DIM_MANUFACTURER AS N
ON M.IDManufacturer = N.IDManufacturer
ORDER BY Unit_price ASC



--Q4--END

--Q5--BEGIN

SELECT MODEL_NAME, MANUFACTURER_NAME, AVG(UNIT_PRICE) AS AVG_PRICE
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M
ON T.IDModel= M.IDModel
INNER JOIN DIM_MANUFACTURER AS A
ON A.IDMANUFACTURER = M.IDMANUFACTURER
WHERE MANUFACTURER_NAME IN 
                            (
                                SELECT TOP 5   Manufacturer_Name
                                FROM FACT_TRANSACTIONS AS T 
                                INNER JOIN DIM_MODEL AS M 
                                ON T.IDModel = M.IDModel 
                                INNER JOIN DIM_MANUFACTURER AS A
                                ON M.IDManufacturer = A.IDManufacturer
                                GROUP BY Manufacturer_Name   
								ORDER BY SUM(T.Quantity)
                            ) 
GROUP BY Model_Name , MANUFACTURER_NAME
ORDER BY AVG_PRICE DESC



--Q5--END

--Q6--BEGIN

SELECT Customer_Name, AVG(T.TotalPrice) AS AVG_SPENT, YEAR(T.Date) AS YEAR
FROM DIM_CUSTOMER AS C
INNER JOIN FACT_TRANSACTIONS AS T
ON C.IDCustomer=T.IDCustomer
WHERE YEAR(T.Date) = 2009
GROUP BY Customer_Name, YEAR(T.DATE)
HAVING AVG(TOTALPRICE) > 500



--Q6--END
	
--Q7--BEGIN  
	
SELECT * FROM 
(
SELECT TOP 5 IDModel FROM FACT_TRANSACTIONS
WHERE YEAR([Date]) = 2008
GROUP BY  IDModel, YEAR([Date])
ORDER BY  SUM(Quantity) DESC
) as A

intersect

SELECT * FROM 
(
SELECT TOP 5 IDModel FROM FACT_TRANSACTIONS
WHERE YEAR([Date]) = 2009
GROUP BY IDModel, YEAR([Date])
ORDER BY SUM(Quantity) DESC
) AS B

intersect

SELECT * FROM 
(
SELECT TOP 5 IDModel FROM FACT_TRANSACTIONS
WHERE YEAR([Date]) = 2010
GROUP BY IDModel, YEAR([Date])
ORDER BY  SUM(Quantity) DESC
) AS C




--Q7--END	
--Q8--BEGIN

SELECT * FROM (
SELECT TOP 1 * 
FROM (
        SELECT TOP 2  Manufacturer_Name ,SUM(TotalPrice) AS SALES , YEAR([Date]) AS [YEAR]
        FROM FACT_TRANSACTIONS AS T 
        INNER JOIN DIM_MODEL AS M 
        ON T.IDModel = M.IDModel 
        INNER JOIN DIM_MANUFACTURER AS A 
        ON M.IDManufacturer = A.IDManufacturer
        WHERE YEAR([Date]) = 2009
        GROUP BY Manufacturer_Name , YEAR([Date])
        ORDER BY SALES DESC 
        ) AS A 
ORDER BY SALES ASC ) AS X 

UNION

SELECT * FROM (
SELECT TOP 1 * 
FROM (
        SELECT TOP 2  Manufacturer_Name , SUM(TotalPrice) AS SALES , YEAR([Date]) AS [YEAR]
        FROM FACT_TRANSACTIONS AS T 
        INNER JOIN DIM_MODEL AS M 
        ON T.IDModel = M.IDModel 
        INNER JOIN DIM_MANUFACTURER AS A 
        ON M.IDManufacturer = A.IDManufacturer
        WHERE YEAR([Date]) = 2010
        GROUP BY Manufacturer_Name , YEAR([Date])
        ORDER BY SALES DESC 
        ) AS B 
ORDER BY SALES ASC ) AS Y



--Q8--END
--Q9--BEGIN
	
SELECT Manufacturer_Name
FROM FACT_TRANSACTIONS AS T 
INNER JOIN DIM_MODEL AS M 
ON T.IDModel = M.IDModel 
INNER JOIN DIM_MANUFACTURER AS A 
ON M.IDManufacturer = A.IDManufacturer
WHERE YEAR([Date]) = 2010

EXCEPT

SELECT Manufacturer_Name
FROM FACT_TRANSACTIONS AS T 
INNER JOIN DIM_MODEL AS M 
ON T.IDModel = M.IDModel 
INNER JOIN DIM_MANUFACTURER AS A 
ON M.IDManufacturer = A.IDManufacturer
WHERE YEAR([Date]) = 2009



--Q9--END

--Q10--BEGIN
	
SELECT * , ((AVG_SPEND - DIFF)/DIFF) AS [%CHANGE]
FROM (
        SELECT * , LAG(AVG_SPEND ,1) OVER( partition BY IDCustomer  ORDER BY [YEAR]) AS [DIFF]
        FROM (	
                SELECT  IDCustomer, AVG(TotalPrice) AS AVG_SPEND , AVG(Quantity) AS AVG_QTY , YEAR([Date]) AS [YEAR]
                FROM FACT_TRANSACTIONS
                WHERE IDCustomer IN 
                                    (SELECT TOP 10 IDCustomer FROM FACT_TRANSACTIONS 
                                     GROUP BY IDCustomer
                                     ORDER BY SUM(TotalPrice) DESC )
                GROUP BY IDCustomer , YEAR([Date])
        ) AS A 
) AS X 



--Q10--END
	