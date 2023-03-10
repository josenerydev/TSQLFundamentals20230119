---------------------------------------------------------------------
-- T-SQL Fundamentals Fourth Edition
-- Chapter 07 - T-SQL for Data Analysis
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Window Functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Window Functions, Described
---------------------------------------------------------------------

USE TSQLV6;

SELECT empid, ordermonth, val,
  SUM(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runval
FROM Sales.EmpOrders;

---------------------------------------------------------------------
-- Ranking Window Functions
---------------------------------------------------------------------

SELECT orderid, custid, val,
  ROW_NUMBER() OVER(ORDER BY val) AS rownum,
  RANK()       OVER(ORDER BY val) AS rank,
  DENSE_RANK() OVER(ORDER BY val) AS dense_rank,
  NTILE(10)    OVER(ORDER BY val) AS ntile
FROM Sales.OrderValues
ORDER BY val;

SELECT orderid, custid, val,
  ROW_NUMBER() OVER(PARTITION BY custid
                    ORDER BY val) AS rownum
FROM Sales.OrderValues
ORDER BY custid, val;

SELECT DISTINCT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues;

SELECT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;

---------------------------------------------------------------------
-- Offset Window Functions
---------------------------------------------------------------------

-- LAG and LEAD
SELECT custid, orderid, val,
  LAG(val)  OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS prevval,
  LEAD(val) OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS nextval
FROM Sales.OrderValues
ORDER BY custid, orderdate, orderid;

-- FIRST_VALUE and LAST_VALUE
SELECT custid, orderid, val,
  FIRST_VALUE(val) OVER(PARTITION BY custid
                        ORDER BY orderdate, orderid
                        ROWS BETWEEN UNBOUNDED PRECEDING
                                 AND CURRENT ROW) AS firstval,
  LAST_VALUE(val)  OVER(PARTITION BY custid
                        ORDER BY orderdate, orderid
                        ROWS BETWEEN CURRENT ROW
                                 AND UNBOUNDED FOLLOWING) AS lastval
FROM Sales.OrderValues
ORDER BY custid, orderdate, orderid;

-- Ship dates for orders placed in or after 2022 by customers 20, 32 and 46
SELECT orderid, custid, orderdate, shippeddate
FROM Sales.Orders
WHERE custid IN (9, 20, 32, 73)
  AND orderdate >= '20220101'
ORDER BY custid, orderdate, orderid;

-- Add last known shipped date
SELECT orderid, custid, orderdate, shippeddate,
  LAST_VALUE(shippeddate) IGNORE NULLS 
    OVER(PARTITION BY custid
         ORDER BY orderdate, orderid
         ROWS UNBOUNDED PRECEDING) AS lastknownshippeddate
FROM Sales.Orders
WHERE custid IN (9, 20, 32, 73)
  AND orderdate >= '20220101'
ORDER BY custid, orderdate, orderid;

-- Add prev known shipped date
SELECT orderid, custid, orderdate, shippeddate,
  LAG(shippeddate) IGNORE NULLS 
    OVER(PARTITION BY custid
         ORDER BY orderdate, orderid) AS prevknownshippeddate
FROM Sales.Orders
WHERE custid IN (9, 20, 32, 73)
  AND orderdate >= '20220101'
ORDER BY custid, orderdate, orderid;

---------------------------------------------------------------------
-- Aggregate Window Functions
---------------------------------------------------------------------

SELECT orderid, custid, val,
  SUM(val) OVER() AS totalvalue,
  SUM(val) OVER(PARTITION BY custid) AS custtotalvalue
FROM Sales.OrderValues;

SELECT orderid, custid, val,
  100. * val / SUM(val) OVER() AS pctall,
  100. * val / SUM(val) OVER(PARTITION BY custid) AS pctcust
FROM Sales.OrderValues;

SELECT empid, ordermonth, val,
  SUM(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runval
FROM Sales.EmpOrders;

---------------------------------------------------------------------
-- The WINDOW clause
---------------------------------------------------------------------

-- Query database compatibility level
SELECT DATABASEPROPERTYEX(N'TSQLV6', N'CompatibilityLevel');

-- Sample query without WINDOW clause
SELECT empid, ordermonth, val,
  SUM(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runsum,
  MIN(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runmin,
  MAX(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runmax,
  AVG(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runavg
FROM Sales.EmpOrders;

-- Sample query with WINDOW clause
SELECT empid, ordermonth, val,
  SUM(val) OVER W AS runsum,
  MIN(val) OVER W AS runmin,
  MAX(val) OVER W AS runmax,
  AVG(val) OVER W AS runavg
FROM Sales.EmpOrders
WINDOW W AS (PARTITION BY empid
             ORDER BY ordermonth
             ROWS BETWEEN UNBOUNDED PRECEDING
                      AND CURRENT ROW);

-- Naming part of window specification
SELECT custid, orderid, val,
  FIRST_VALUE(val) OVER(PO
                        ROWS BETWEEN UNBOUNDED PRECEDING
                                 AND CURRENT ROW) AS firstval,
  LAST_VALUE(val)  OVER(PO
                        ROWS BETWEEN CURRENT ROW
                                 AND UNBOUNDED FOLLOWING) AS lastval
FROM Sales.OrderValues
WINDOW PO AS (PARTITION BY custid
              ORDER BY orderdate, orderid)
ORDER BY custid, orderdate, orderid;

-- Use one window name in another window name specification
SELECT orderid, custid, orderdate, qty, val,
  ROW_NUMBER() OVER PO AS ordernum,
  MAX(orderdate) OVER P AS maxorderdate,
  SUM(qty) OVER POF AS runsumqty,
  SUM(val) OVER POF AS runsumval
FROM Sales.OrderValues
WINDOW P AS ( PARTITION BY custid ),
       PO AS ( P ORDER BY orderdate, orderid ),
       POF AS ( PO ROWS UNBOUNDED PRECEDING )
ORDER BY custid, orderdate, orderid;

---------------------------------------------------------------------
-- Pivoting Data
---------------------------------------------------------------------

-- Listing 1: Code to Create and Populate the Orders Table
USE TSQLV6;

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid   INT        NOT NULL
    CONSTRAINT PK_Orders PRIMARY KEY,
  orderdate DATE       NOT NULL,
  empid     INT        NOT NULL,
  custid    VARCHAR(5) NOT NULL,
  qty       INT        NOT NULL
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
  (30001, '20200802', 3, 'A', 10),
  (10001, '20201224', 2, 'A', 12),
  (10005, '20201224', 1, 'B', 20),
  (40001, '20210109', 2, 'A', 40),
  (10006, '20210118', 1, 'C', 14),
  (20001, '20210212', 2, 'B', 12),
  (40005, '20220212', 3, 'A', 10),
  (20002, '20220216', 1, 'C', 20),
  (30003, '20220418', 2, 'B', 15),
  (30004, '20200418', 3, 'C', 22),
  (30007, '20220907', 3, 'D', 30);

SELECT * FROM dbo.Orders;

-- Query against Orders, grouping by employee and customer
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

---------------------------------------------------------------------
-- Pivoting with a Grouped Query
---------------------------------------------------------------------

-- Query against Orders, grouping by employee, pivoting customers,
-- aggregating sum of quantity
SELECT empid,
  SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN custid = 'B' THEN qty END) AS B,
  SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN custid = 'D' THEN qty END) AS D  
FROM dbo.Orders
GROUP BY empid;

---------------------------------------------------------------------
-- Pivoting with the PIVOT Operator
---------------------------------------------------------------------

-- Logical equivalent of previous query using the native PIVOT operator
SELECT empid, A, B, C, D
FROM (SELECT empid, custid, qty
      FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

-- Query demonstrating the problem with implicit grouping
SELECT empid, A, B, C, D
FROM dbo.Orders
  PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

-- Logical equivalent of previous query
SELECT empid,
  SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN custid = 'B' THEN qty END) AS B,
  SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN custid = 'D' THEN qty END) AS D  
FROM dbo.Orders
GROUP BY orderid, orderdate, empid;

-- Query against Orders, grouping by customer, pivoting employees,
-- aggregating sum of quantity
SELECT custid, [1], [2], [3]
FROM (SELECT empid, custid, qty
      FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR empid IN([1], [2], [3])) AS P;

---------------------------------------------------------------------
-- Unpivoting Data
---------------------------------------------------------------------

-- Code to create and populate the EmpCustOrders table
USE TSQLV6;

DROP TABLE IF EXISTS dbo.EmpCustOrders;

CREATE TABLE dbo.EmpCustOrders
(
  empid INT NOT NULL
    CONSTRAINT PK_EmpCustOrders PRIMARY KEY,
  A VARCHAR(5) NULL,
  B VARCHAR(5) NULL,
  C VARCHAR(5) NULL,
  D VARCHAR(5) NULL
);

INSERT INTO dbo.EmpCustOrders(empid, A, B, C, D)
  SELECT empid, A, B, C, D
  FROM (SELECT empid, custid, qty
        FROM dbo.Orders) AS D
    PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

SELECT * FROM dbo.EmpCustOrders;

---------------------------------------------------------------------
-- Unpivoting with the APPLY Operator
---------------------------------------------------------------------

-- Unpivot Step 1: generate copies
SELECT *
FROM dbo.EmpCustOrders
  CROSS JOIN (VALUES('A'),('B'),('C'),('D')) AS C(custid);

-- Unpivot Step 2: extract elements
/*
SELECT empid, custid, qty
FROM dbo.EmpCustOrders
  CROSS JOIN (VALUES('A', A),('B', B),('C', C),('D', D)) AS C(custid, qty);
*/

SELECT empid, custid, qty
FROM dbo.EmpCustOrders
  CROSS APPLY (VALUES('A', A),('B', B),('C', C),('D', D)) AS C(custid, qty);

-- Unpivot Step 3: eliminate NULLs
SELECT empid, custid, qty
FROM dbo.EmpCustOrders
  CROSS APPLY (VALUES('A', A),('B', B),('C', C),('D', D)) AS C(custid, qty)
WHERE qty IS NOT NULL;

---------------------------------------------------------------------
-- Unpivoting with the UNPIVOT Operator
---------------------------------------------------------------------

-- Query using the native UNPIVOT operator
SELECT empid, custid, qty
FROM dbo.EmpCustOrders
  UNPIVOT(qty FOR custid IN(A, B, C, D)) AS U;

-- Cleanup
DROP TABLE IF EXISTS dbo.EmpCustOrders;
  
---------------------------------------------------------------------
-- Grouping Sets
---------------------------------------------------------------------

-- Four queries, each with a different grouping set
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

SELECT empid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid;

SELECT custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid;

SELECT SUM(qty) AS sumqty
FROM dbo.Orders;

-- Unifying result sets of four queries
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid

UNION ALL

SELECT empid, NULL, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid

UNION ALL

SELECT NULL, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid

UNION ALL

SELECT NULL, NULL, SUM(qty) AS sumqty
FROM dbo.Orders;

---------------------------------------------------------------------
-- GROUPING SETS Subclause
---------------------------------------------------------------------

-- Using the GROUPING SETS subclause
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY
  GROUPING SETS
  (
    (empid, custid),
    (empid),
    (custid),
    ()
  );

---------------------------------------------------------------------
-- CUBE Subclause
---------------------------------------------------------------------

-- Using the CUBE subclause
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

---------------------------------------------------------------------
-- ROLLUP Subclause
---------------------------------------------------------------------

-- Using the ROLLUP subclause
SELECT 
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate));

---------------------------------------------------------------------
-- GROUPING and GROUPING_ID Function
---------------------------------------------------------------------

SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

SELECT
  GROUPING(empid) AS grpemp,
  GROUPING(custid) AS grpcust,
  empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);

SELECT
  GROUPING_ID(empid, custid) AS groupingset,
  empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);
GO

---------------------------------------------------------------------
-- Time Series
---------------------------------------------------------------------

-- Sample data
USE TSQLV6;

DROP TABLE IF EXISTS dbo.SensorMeasurements, dbo.Sensors;

CREATE TABLE dbo.Sensors
(
  sensorid    INT         NOT NULL
    CONSTRAINT PK_Sensors PRIMARY KEY,
  description VARCHAR(50) NOT NULL
);

INSERT INTO dbo.Sensors(sensorid, description)
VALUES
  (1, 'Restaurant Fancy Schmancy beer fridge'),
  (2, 'Restaurant Fancy Schmancy wine cellar');

CREATE TABLE dbo.SensorMeasurements
(
  sensorid    INT NOT NULL
    CONSTRAINT FK_SensorMeasurements_Sensors REFERENCES dbo.Sensors,
  ts          DATETIME2(0)  NOT NULL,
  temperature NUMERIC(5, 2) NOT NULL, -- Fahrenheit
  humidity    NUMERIC(5, 2) NOT NULL, -- percent
  CONSTRAINT PK_SensorMeasurements PRIMARY KEY(sensorid, ts)
);

INSERT INTO dbo.SensorMeasurements(sensorid, ts, temperature, humidity)
VALUES
  (1, '20220609 06:00:03', 39.16, 86.28),
  (1, '20220609 09:59:57', 39.72, 83.44),
  (1, '20220609 13:59:59', 38.93, 84.33),
  (1, '20220609 18:00:00', 39.42, 79.66),
  (1, '20220609 22:00:01', 40.08, 94.44),
  (1, '20220610 01:59:57', 41.26, 90.42),
  (1, '20220610 05:59:59', 40.89, 72.94),
  (1, '20220610 09:59:58', 40.03, 84.48),
  (1, '20220610 14:00:03', 41.23, 93.47),
  (1, '20220610 17:59:59', 39.32, 88.09),
  (1, '20220610 21:59:57', 41.19, 92.89),
  (1, '20220611 01:59:58', 40.88, 89.23),
  (1, '20220611 06:00:03', 41.14, 82.27),
  (1, '20220611 10:00:00', 39.20, 86.00),
  (1, '20220611 14:00:02', 39.41, 74.92),
  (1, '20220611 18:00:02', 41.12, 87.37),
  (1, '20220611 21:59:59', 40.67, 84.63),
  (1, '20220612 02:00:02', 41.15, 86.16),
  (1, '20220612 06:00:02', 39.23, 74.59),
  (1, '20220612 10:00:00', 41.40, 86.80),
  (1, '20220612 14:00:00', 41.20, 79.97),
  (1, '20220612 18:00:03', 40.11, 92.84),
  (1, '20220612 22:00:03', 40.87, 94.23),
  (1, '20220613 02:00:00', 39.03, 92.44),
  (1, '20220613 05:59:57', 40.19, 94.72),
  (1, '20220613 10:00:02', 39.55, 87.77),
  (1, '20220613 14:00:02', 38.94, 89.06),
  (1, '20220613 18:00:03', 40.88, 73.81),
  (1, '20220613 21:59:57', 41.24, 86.56),
  (1, '20220614 02:00:00', 40.25, 76.64),
  (1, '20220614 06:00:01', 40.73, 90.66),
  (1, '20220614 10:00:03', 40.82, 92.76),
  (1, '20220614 13:59:58', 39.70, 73.74),
  (1, '20220614 17:59:57', 39.65, 89.38),
  (1, '20220614 22:00:02', 39.47, 73.36),
  (1, '20220615 02:00:03', 39.14, 77.89),
  (1, '20220615 06:00:00', 40.82, 86.84),
  (1, '20220615 09:59:57', 39.91, 90.09),
  (1, '20220615 13:59:57', 41.34, 82.88),
  (1, '20220615 18:00:01', 40.51, 86.58),
  (1, '20220615 22:00:00', 41.23, 83.85),
  (2, '20220609 06:00:01', 54.95, 75.39),
  (2, '20220609 10:00:03', 56.94, 71.34),
  (2, '20220609 13:59:59', 54.07, 68.09),
  (2, '20220609 18:00:02', 54.05, 65.50),
  (2, '20220609 22:00:00', 53.37, 66.28),
  (2, '20220610 01:59:58', 56.33, 79.90),
  (2, '20220610 05:59:58', 57.00, 65.88),
  (2, '20220610 10:00:02', 54.64, 61.10),
  (2, '20220610 14:00:01', 53.48, 69.76),
  (2, '20220610 17:59:57', 55.15, 65.85),
  (2, '20220610 22:00:02', 54.48, 75.90),
  (2, '20220611 02:00:00', 54.55, 62.28),
  (2, '20220611 06:00:01', 54.56, 66.36),
  (2, '20220611 09:59:58', 55.92, 77.53),
  (2, '20220611 14:00:02', 55.89, 68.57),
  (2, '20220611 18:00:01', 54.82, 62.04),
  (2, '20220611 22:00:01', 55.58, 76.20),
  (2, '20220613 01:59:58', 56.29, 62.33),
  (2, '20220615 10:00:03', 53.24, 70.67),
  (2, '20220615 13:59:59', 55.93, 77.60),
  (2, '20220615 18:00:01', 54.05, 66.56),
  (2, '20220615 21:59:58', 54.66, 61.13);

SELECT * FROM dbo.Sensors;

SELECT * FROM dbo.SensorMeasurements;
GO

---------------------------------------------------------------------
-- The DATE_BUCKET function
---------------------------------------------------------------------

DECLARE
  @ts          AS DATETIME2(0) = '20220102 12:00:03',
  @bucketwidth AS INT = 12,
  @origin      AS DATETIME2(0) = '20220101 00:05:00';

SELECT DATE_BUCKET(hour, @bucketwidth, @ts, @origin);
GO

---------------------------------------------------------------------
-- Custom computation of start of containing bucket
---------------------------------------------------------------------

-- Compute difference in hours (could be up by 1)
DECLARE
  @ts          AS DATETIME2(0) = '20220102 12:00:03',
  @bucketwidth AS INT = 12,
  @origin      AS DATETIME2(0) = '20220101 00:05:00';
  
SELECT
  DATEDIFF(hour, @origin, @ts) AS grosshourdiff;
GO

-- Subtract 1 if needed to get difference in full hours
DECLARE
  @ts          AS DATETIME2(0) = '20220102 12:00:03',
  @bucketwidth AS INT = 12,
  @origin      AS DATETIME2(0) = '20220101 00:05:00';
  
SELECT
  DATEDIFF(hour, @origin, @ts)
    - CASE
        WHEN DATEADD(hour, DATEDIFF(hour, @origin, @ts), @origin)
               > @ts THEN 1
        ELSE 0
      END AS nethourdiff;
GO

-- Compute difference in hours in full 12-hour units
DECLARE
  @ts          AS DATETIME2(0) = '20220102 12:00:03',
  @bucketwidth AS INT = 12,
  @origin      AS DATETIME2(0) = '20220101 00:05:00';
  
SELECT
  (DATEDIFF(hour, @origin, @ts)
    - CASE
        WHEN DATEADD(hour, DATEDIFF(hour, @origin, @ts), @origin)
                > @ts THEN 1
        ELSE 0
      END) / @bucketwidth * @bucketwidth AS hoursinwholebuckets;
GO

-- Compute start of 12-hour bucket by adding above result to origin
DECLARE
  @ts          AS DATETIME2(0) = '20220102 12:00:03',
  @bucketwidth AS INT = 12,
  @origin      AS DATETIME2(0) = '20220101 00:05:00';
  
SELECT
  DATEADD(
    hour,
    (DATEDIFF(hour, @origin, @ts)
      - CASE
          WHEN DATEADD(hour, DATEDIFF(hour, @origin, @ts), @origin)
                 > @ts THEN 1
          ELSE 0
        END) / @bucketwidth * @bucketwidth,
    @origin) AS bucketstart;
GO

---------------------------------------------------------------------
-- Applying date bucket logic to sample data
---------------------------------------------------------------------

-- First, compute bucket start per input time stamp

-- With DATE_BUCKET
DECLARE
  @bucketwidth AS INT = 12,
  @origin      AS DATETIME2(0) = '19000101 00:00:00';

SELECT sensorid, ts,
  DATE_BUCKET(hour, @bucketwidth, ts, @origin) AS bucketstart
FROM dbo.SensorMeasurements;
GO

-- Without DATE_BUCKET
DECLARE
  @bucketwidth AS INT = 12,
  @origin      AS DATETIME2(0) = '19000101 00:00:00';

SELECT sensorid, ts,
  DATEADD(
    hour,
    (DATEDIFF(hour, @origin, ts)
      - CASE
          WHEN DATEADD(hour, DATEDIFF(hour, @origin, ts), @origin)
                 > ts THEN 1
          ELSE 0
        END) / @bucketwidth * @bucketwidth,
    @origin) AS bucketstart
FROM dbo.SensorMeasurements;
GO

-- Grouping and aggregating data by bucket

-- With DATE_BUCKET
DECLARE
  @bucketwidth AS INT = 12,
  @origin      AS DATETIME2(0) = '19000101 00:00:00';

WITH C AS
(
  SELECT sensorid, ts, temperature,
    DATE_BUCKET(hour, @bucketwidth, ts, @origin) AS bucketstart
  FROM dbo.SensorMeasurements
)
SELECT sensorid, bucketstart,
  DATEADD(hour, @bucketwidth, bucketstart) AS bucketend,
  MIN(temperature) AS mintemp,
  MAX(temperature) AS maxtemp,
  AVG(temperature) AS avgtemp
FROM C
GROUP BY sensorid, bucketstart
ORDER BY sensorid, bucketstart;
GO

-- Without DATE_BUCKET
DECLARE
  @bucketwidth AS INT = 12,
  @origin      AS DATETIME2(0) = '19000101 00:00:00';

WITH C AS
(
  SELECT sensorid, ts, temperature,
    DATEADD(
      hour,
      (DATEDIFF(hour, @origin, ts)
        - CASE
            WHEN DATEADD(hour, DATEDIFF(hour, @origin, ts), @origin)
                   > ts THEN 1
            ELSE 0
          END) / @bucketwidth * @bucketwidth,
      @origin) AS bucketstart
  FROM dbo.SensorMeasurements
)
SELECT sensorid, bucketstart,
  DATEADD(hour, @bucketwidth, bucketstart) AS bucketend,
  MIN(temperature) AS mintemp,
  MAX(temperature) AS maxtemp,
  AVG(temperature) AS avgtemp
FROM C
GROUP BY sensorid, bucketstart
ORDER BY sensorid, bucketstart;
GO

-- Using 7 days as the bucket size and Monday as the origin
DECLARE
  @bucketwidth AS INT = 7,
  @origin      AS DATE = '19000101';

WITH C AS
(
  SELECT sensorid, ts, temperature,
    DATEADD(
      day,
      (DATEDIFF(day, @origin, ts)
        - CASE
            WHEN DATEADD(day, DATEDIFF(day, @origin, ts), @origin)
                   > ts THEN 1
            ELSE 0
          END) / @bucketwidth * @bucketwidth,
      @origin) AS bucketstart
  FROM dbo.SensorMeasurements
)
SELECT sensorid, bucketstart,
  DATEADD(day, @bucketwidth, bucketstart) AS bucketend,
  MIN(temperature) AS mintemp,
  MAX(temperature) AS maxtemp,
  AVG(temperature) AS avgtemp
FROM C
GROUP BY sensorid, bucketstart
ORDER BY sensorid, bucketstart;
GO

-- Alternatively can use 1 as the number and week as the date part
DECLARE
  @bucketwidth AS INT = 1,
  @origin      AS DATE = '19000101';

WITH C AS
(
  SELECT sensorid, ts, temperature,
    DATEADD(
      week,
      (DATEDIFF(week, @origin, ts)
        - CASE
            WHEN DATEADD(week, DATEDIFF(week, @origin, ts), @origin)
                   > ts THEN 1
            ELSE 0
          END) / @bucketwidth * @bucketwidth,
      @origin) AS bucketstart
  FROM dbo.SensorMeasurements
)
SELECT sensorid, bucketstart,
  DATEADD(week, @bucketwidth, bucketstart) AS bucketend,
  MIN(temperature) AS mintemp,
  MAX(temperature) AS maxtemp,
  AVG(temperature) AS avgtemp
FROM C
GROUP BY sensorid, bucketstart
ORDER BY sensorid, bucketstart;
GO

---------------------------------------------------------------------
-- Gap filling
---------------------------------------------------------------------

-- Produce all possible bucket start times with GENERATE_SERIES
DECLARE
  @bucketwidth AS INT = 12,
  @startperiod AS DATETIME2(0) = '20220609 00:00:00',
  @endperiod   AS DATETIME2(0) = '20220615 12:00:00';

SELECT DATEADD(hour, value * @bucketwidth, @startperiod) AS ts
FROM GENERATE_SERIES(0, DATEDIFF(hour, @startperiod, @endperiod) / @bucketwidth) AS N;
GO

-- Gap filling solution using the DATE_BUCKET function
DECLARE
  @bucketwidth AS INT = 12,
  @startperiod AS DATETIME2(0) = '20220609 00:00:00',
  @endperiod   AS DATETIME2(0) = '20220615 12:00:00';

WITH TS AS
(
  SELECT DATEADD(hour, value * @bucketwidth, @startperiod) AS ts
  FROM GENERATE_SERIES(0, DATEDIFF(hour, @startperiod, @endperiod) / @bucketwidth) AS N
),
C1 AS
(
  SELECT sensorid, ts, temperature,
    DATE_BUCKET(hour, @bucketwidth, ts, @startperiod) AS bucketstart
  FROM dbo.SensorMeasurements
),
C2 AS
(
  SELECT sensorid, bucketstart,
    MIN(temperature) AS mintemp,
    MAX(temperature) AS maxtemp,
    AVG(temperature) AS avgtemp
  FROM C1
  GROUP BY sensorid, bucketstart
)
SELECT S.sensorid, TS.ts AS bucketstart,
  DATEADD(hour, @bucketwidth, TS.ts) AS bucketend,
  mintemp, maxtemp, avgtemp
FROM dbo.Sensors AS S
  CROSS JOIN TS
  LEFT OUTER JOIN C2
    ON S.sensorid = C2.sensorid
    AND TS.ts = C2.bucketstart
ORDER BY sensorid, bucketstart;
GO

-- Produce all possible bucket start times with GetNums
DECLARE
  @bucketwidth AS INT = 12,
  @startperiod AS DATETIME2(0) = '20220609 00:00:00',
  @endperiod   AS DATETIME2(0) = '20220615 12:00:00';

SELECT DATEADD(hour, n * @bucketwidth, @startperiod) AS ts
FROM dbo.GetNums(0, DATEDIFF(hour, @startperiod, @endperiod) / @bucketwidth) AS N;
GO

-- Gap filling solution using GetNums and the custom method
DECLARE
  @bucketwidth AS INT = 12,
  @startperiod AS DATETIME2(0) = '20220609 00:00:00',
  @endperiod   AS DATETIME2(0) = '20220615 12:00:00';

WITH TS AS
(
  SELECT DATEADD(hour, n * @bucketwidth, @startperiod) AS ts
  FROM dbo.GetNums(0, DATEDIFF(hour, @startperiod, @endperiod) / @bucketwidth) AS N
),
C1 AS
(
  SELECT sensorid, ts, temperature,
    DATEADD(
      hour,
      (DATEDIFF(hour, @startperiod, ts)
        - CASE
            WHEN DATEADD(hour, DATEDIFF(hour, @startperiod, ts), @startperiod)
                   > ts THEN 1
            ELSE 0
          END) / @bucketwidth * @bucketwidth,
      @startperiod) AS bucketstart
  FROM dbo.SensorMeasurements
),
C2 AS
(
  SELECT sensorid, bucketstart,
    MIN(temperature) AS mintemp,
    MAX(temperature) AS maxtemp,
    AVG(temperature) AS avgtemp
  FROM C1
  GROUP BY sensorid, bucketstart
)
SELECT S.sensorid, TS.ts AS bucketstart,
  DATEADD(hour, @bucketwidth, TS.ts) AS bucketend,
  mintemp, maxtemp, avgtemp
FROM dbo.Sensors AS S
  CROSS JOIN TS
  LEFT OUTER JOIN C2
    ON S.sensorid = C2.sensorid
    AND TS.ts = C2.bucketstart
ORDER BY sensorid, bucketstart;
GO
