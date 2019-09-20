CREATE TABLE [dbo].[FactInternetSalesWithoutDistr]
(
	[ProductKey] [int] NOT NULL,
	[OrderDateKey] [int] NOT NULL,
	[DueDateKey] [int] NOT NULL,
	[ShipDateKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[PromotionKey] [int] NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[SalesTerritoryKey] [int] NOT NULL,
	[SalesOrderNumber] [nvarchar](20) NOT NULL,
	[SalesOrderLineNumber] [tinyint] NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[OrderQuantity] [smallint] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[ExtendedAmount] [money] NOT NULL,
	[UnitPriceDiscountPct] [float] NOT NULL,
	[DiscountAmount] [float] NOT NULL,
	[ProductStandardCost] [money] NOT NULL,
	[TotalProductCost] [money] NOT NULL,
	[SalesAmount] [money] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[Freight] [money] NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[CustomerPONumber] [nvarchar](25) NULL
);


-- Explicitly Created Round Robin Table
CREATE TABLE [dbo].[FactInternetSalesWithDistr]
(
	[ProductKey] [int] NOT NULL,
	[OrderDateKey] [int] NOT NULL,
	[DueDateKey] [int] NOT NULL,
	[ShipDateKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[PromotionKey] [int] NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[SalesTerritoryKey] [int] NOT NULL,
	[SalesOrderNumber] [nvarchar](20) NOT NULL,
	[SalesOrderLineNumber] [tinyint] NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[OrderQuantity] [smallint] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[ExtendedAmount] [money] NOT NULL,
	[UnitPriceDiscountPct] [float] NOT NULL,
	[DiscountAmount] [float] NOT NULL,
	[ProductStandardCost] [money] NOT NULL,
	[TotalProductCost] [money] NOT NULL,
	[SalesAmount] [money] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[Freight] [money] NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[CustomerPONumber] [nvarchar](25) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
);


-- View the distribution method using sys tables
SELECT o.name as tableName, distribution_policy_desc
FROM sys.pdw_table_distribution_properties ptdp
JOIN sys.objects o
ON ptdp.object_id = o.object_id
WHERE ptdp.object_id = object_id('FactInternetSalesWithoutDistr')
OR ptdp.object_id = object_id('FactInternetSalesWithDistr');

--exercise 3
-- Create table with round-robin distribution
CREATE TABLE dbo.Orders
(
OrderID int IDENTITY(1,1) NOT NULL
,OrderDate datetime NOT NULL
,OrderDescription char(15) DEFAULT 'NewOrder' )
WITH
( CLUSTERED INDEX (OrderID)
, DISTRIBUTION = ROUND_ROBIN
);			    
-- Insert Date
-- View data in individual distributions
SET NOCOUNT ON
DECLARE @i INT SET @i = 1
DECLARE @date DATETIME SET @date = dateadd(mi,@i,'2019-08-01') WHILE (@i <= 60)
BEGIN
INSERT INTO dbo.Orders (OrderDate) SELECT @date
SET @i = @i+1;
END;

-- Check number of rows
select count(*) from dbo.Orders;

-- View data in distributions
SELECT
o.name AS tableName, pnp.pdw_node_id, pnp.distribution_id,
pnp.rows FROM
sys.pdw_nodes_partitions AS pnp JOIN sys.pdw_nodes_tables AS NTables ON pnp.object_id = NTables.object_id
AND pnp.pdw_node_id = NTables.pdw_node_id
JOIN sys.pdw_table_mappings AS TMap ON NTables.name = TMap.physical_name
AND substring(TMap.physical_name,40, 10) = pnp.distribution_id
JOIN sys.objects AS o
ON TMap.object_id = o.object_id
WHERE o.name in ('orders')
ORDER BY distribution_id;

-- Create another Orders table with Hash Distribution
CREATE TABLE dbo.Orders2
(
OrderID int IDENTITY(1,1) NOT NULL
,OrderDate datetime NOT NULL
,OrderDescription char(15) DEFAULT 'NewOrder'
)
WITH
( CLUSTERED INDEX (OrderID)
, DISTRIBUTION = HASH(OrderDate)
);


-- Insert 60 rows into Orders2
SET NOCOUNT ON
DECLARE @i INT SET @i = 1
DECLARE @date DATETIME SET @date = dateadd(mi,@i,'2019-08-01')
WHILE (@i <= 60)
BEGIN
INSERT INTO dbo.Orders2 (OrderDate) SELECT @date
SET @i = @i+1;
END;

-- Check number of rows
select count(*) from dbo.Orders2;

-- View Distributions

SELECT
o.name AS tableName, pnp.pdw_node_id, pnp.distribution_id, pnp.rows FROM sys.pdw_nodes_partitions AS pnp JOIN sys.pdw_nodes_tables AS NTables ON pnp.object_id = NTables.object_id
AND pnp.pdw_node_id = NTables.pdw_node_id
JOIN sys.pdw_table_mappings AS TMap ON NTables.name = TMap.physical_name
AND substring(TMap.physical_name,40, 10) = pnp.distribution_id
JOIN sys.objects AS o
ON TMap.object_id = o.object_id
WHERE o.name in ('orders2');

-- truncate the table


-- genereta new data with 5 hash functions
TRUNCATE TABLE dbo.Orders2;

SET NOCOUNT ON
DECLARE @i INT SET @i = 1
DECLARE @date DATETIME SET @date = dateadd(mi,@i,'2019-08-01')
WHILE (@i <= 5)
BEGIN
INSERT INTO dbo.Orders2 (OrderDate) SELECT @date
INSERT INTO dbo.Orders2 (OrderDate) SELECT dateadd(week,1,@date)
INSERT INTO dbo.Orders2 (OrderDate) SELECT dateadd(week,2,@date)
INSERT INTO dbo.Orders2 (OrderDate) SELECT dateadd(week,3,@date)
INSERT INTO dbo.Orders2 (OrderDate) SELECT dateadd(week,4,@date)
INSERT INTO dbo.Orders2 (OrderDate) SELECT dateadd(week,5,@date)
SET @i = @i+1;
END

--We can see our distributions
SELECT
o.name AS tableName, pnp.pdw_node_id, pnp.distribution_id, pnp.rows FROM sys.pdw_nodes_partitions AS pnp JOIN sys.pdw_nodes_tables AS NTables ON pnp.object_id = NTables.object_id
AND pnp.pdw_node_id = NTables.pdw_node_id
JOIN sys.pdw_table_mappings AS TMap ON NTables.name = TMap.physical_name
AND substring(TMap.physical_name,40, 10) = pnp.distribution_id
JOIN sys.objects AS o
ON TMap.object_id = o.object_id
WHERE o.name in ('orders2');
			    
--Exercise 4
--DimSalesTerritory_REPLICATE
CREATE TABLE dbo.DimSalesTerritory_REPLICATE WITH
(
CLUSTERED COLUMNSTORE INDEX,
DISTRIBUTION = ROUND_ROBIN
)
AS SELECT * FROM dbo.DimSalesTerritory
OPTION (LABEL = 'CTAS : DimSalesTerritory_REPLICATE');

CREATE TABLE dbo.DimDate_REPLICATE
WITH
(
CLUSTERED COLUMNSTORE INDEX,
DISTRIBUTION = ROUND_ROBIN
)
AS SELECT * FROM dbo.DimDate
OPTION (LABEL = 'CTAS : DimDate_REPLICATE');

-- Switch table names to get Round Robin distribution
RENAME OBJECT dbo.DimDate to DimDate_old;
RENAME OBJECT dbo.DimDate_REPLICATE TO DimDate;
RENAME OBJECT dbo.DimSalesTerritory to DimSalesTerritory_old;
RENAME OBJECT dbo.DimSalesTerritory_REPLICATE TO DimSalesTerritory;

-- Check distribution style of tables of DimDate

SELECT o.name as tableName, distribution_policy_desc
FROM sys.pdw_table_distribution_properties ptdp
JOIN sys.objects o
ON ptdp.object_id = o.object_id
WHERE o.name in ('DimDate','DimSalesTerritory','FactInternetSales');

-- Get the distributions
SELECT
o.name AS tableName, pnp.pdw_node_id, pnp.distribution_id, pnp.rows FROM sys.pdw_nodes_partitions AS pnp JOIN sys.pdw_nodes_tables AS NTables ON pnp.object_id = NTables.object_id
AND pnp.pdw_node_id = NTables.pdw_node_id
JOIN sys.pdw_table_mappings AS TMap ON NTables.name = TMap.physical_name
AND substring(TMap.physical_name,40, 10) = pnp.distribution_id
JOIN sys.objects AS o
ON TMap.object_id = o.object_id
WHERE o.name in ('DimDate') ORDER BY distribution_id; 
			    
-- Compare the difference with DimDate_old (HASH distribution)

SELECT
o.name AS tableName, pnp.pdw_node_id, pnp.distribution_id, pnp.rows FROM sys.pdw_nodes_partitions AS pnp JOIN sys.pdw_nodes_tables AS NTables ON pnp.object_id = NTables.object_id
AND pnp.pdw_node_id = NTables.pdw_node_id
JOIN sys.pdw_table_mappings AS TMap ON NTables.name = TMap.physical_name
AND substring(TMap.physical_name,40, 10) = pnp.distribution_id
JOIN sys.objects AS o
ON TMap.object_id = o.object_id
WHERE o.name in ('DimDate_old') ORDER BY distribution_id

-- Sales Sum
SELECT TotalSalesAmount = SUM(SalesAmount)
FROM dbo.FactInternetSales s
INNER JOIN dbo.DimDate d
ON d.DateKey = s.OrderDateKey
INNER JOIN dbo.DimSalesTerritory t
ON t.SalesTerritoryKey = s.SalesTerritoryKey
WHERE d.FiscalYear = 2004
AND t.SalesTerritoryGroup = 'North America'
OPTION (LABEL = 'STATEMENT:RoundRobinQuery');


-- List of steps

SELECT step_index, operation_type
FROM sys.dm_pdw_exec_requests er
JOIN sys.dm_pdw_request_steps rs
ON er.request_id = rs.request_id
WHERE er.[label] = 'STATEMENT:RoundRobinQuery';
			    
-- Create dim tables with REPLICATE distribution method
CREATE TABLE dbo.DimSalesTerritory_REPLICATE WITH
(
CLUSTERED COLUMNSTORE INDEX,
DISTRIBUTION = REPLICATE
)
AS SELECT * FROM dbo.DimSalesTerritory
OPTION (LABEL = 'CTAS : DimSalesTerritory_REPLICATE');

CREATE TABLE dbo.DimDate_REPLICATE
WITH
(
CLUSTERED COLUMNSTORE INDEX,
DISTRIBUTION = REPLICATE
)
AS SELECT * FROM dbo.DimDate
OPTION (LABEL = 'CTAS : DimDate_REPLICATE');


-- Switch table names
RENAME OBJECT dbo.DimSalesTerritory to DimSalesTerritory_RR;
RENAME OBJECT dbo.DimSalesTerritory_REPLICATE TO DimSalesTerritory;
RENAME OBJECT dbo.DimDate to DimDate_RR;
RENAME OBJECT dbo.DimDate_REPLICATE TO DimDate;




-- Run the SQL against DimDate, DimSalesTerritory and FactInternetSAles
SELECT TotalSalesAmount = SUM(SalesAmount)
FROM dbo.FactInternetSales s
INNER JOIN dbo.DimDate d
ON d.DateKey = s.OrderDateKey
INNER JOIN dbo.DimSalesTerritory t
ON t.SalesTerritoryKey = s.SalesTerritoryKey
WHERE d.FiscalYear = 2004
AND t.SalesTerritoryGroup = 'North America'
OPTION (LABEL = 'STATEMENT:ReplicatedTableQuery');

-- Get list of operations
SELECT step_index, operation_type
FROM sys.dm_pdw_exec_requests er
JOIN sys.dm_pdw_request_steps rs
ON er.request_id = rs.request_id
WHERE er.[label] = 'STATEMENT:RoundRobinQuery';

-- Getting Sales Amount
SELECT TotalSalesAmount = SUM(SalesAmount)
FROM dbo.FactInternetSales s
INNER JOIN dbo.DimDate d
ON d.DateKey = s.OrderDateKey
INNER JOIN dbo.DimSalesTerritory t
ON t.SalesTerritoryKey = s.SalesTerritoryKey
WHERE d.FiscalYear = 2004
AND t.SalesTerritoryGroup = 'North America'
OPTION (LABEL = 'STATEMENT:ReplicatedTableQuery');

-- Get list of operations
SELECT step_index, operation_type
FROM sys.dm_pdw_exec_requests er
JOIN sys.dm_pdw_request_steps rs
ON er.request_id = rs.request_id
WHERE er.[label] = 'STATEMENT:ReplicatedTableQuery';

-- Run SQL again
SELECT TotalSalesAmount = SUM(SalesAmount)
FROM dbo.FactInternetSales s
INNER JOIN dbo.DimDate d
ON d.DateKey = s.OrderDateKey
INNER JOIN dbo.DimSalesTerritory t
ON t.SalesTerritoryKey = s.SalesTerritoryKey
WHERE d.FiscalYear = 2004
AND t.SalesTerritoryGroup = 'North America'
OPTION (LABEL = 'STATEMENT:ReplicatedTableQuery_lucky');

-- Check the operation list
SELECT step_index, operation_type
FROM sys.dm_pdw_exec_requests er
JOIN sys.dm_pdw_request_steps rs
ON er.request_id = rs.request_id
WHERE er.[label] = 'STATEMENT:ReplicatedTableQuery_lucky';





--Exercise 5: Managing Statistics
-- Check the auto statistics option
SELECT
tb.name AS table_name, co.name AS column_name, STATS_DATE(st.object_id,st.stats_id) AS stats_last_updated_date FROM
sys.objects ob
JOIN sys.stats st ON ob.object_id = st.object_id
JOIN sys.stats_columns sc ON st.stats_id = sc.stats_id
AND st.object_id = sc.object_id
JOIN sys.columns co ON sc.column_id = co.column_id
AND sc.object_id = co.object_id
JOIN sys.types ty ON co.user_type_id = ty.user_type_id
JOIN sys.tables tb ON co.object_id = tb.object_id WHERE
st.user_created = 1
AND tb.name IN ('DimDate', 'DimSalesTerritory');


--create statistics for each column
CREATE STATISTICS SalesTerritoryKey ON DimSalesTerritory (SalesTerritoryKey);
CREATE STATISTICS SalesTerritoryAlternateKey ON DimSalesTerritory (SalesTerritoryAlternateKey);
CREATE STATISTICS SalesTerritoryRegion ON DimSalesTerritory (SalesTerritoryRegion);
CREATE STATISTICS SalesTerritoryCountry ON DimSalesTerritory (SalesTerritoryCountry);
CREATE STATISTICS SalesTerritoryGroup ON DimSalesTerritory (SalesTerritoryGroup);
CREATE STATISTICS DateKey ON DimDate (DateKey);
CREATE STATISTICS FullDateAlternateKey ON DimDate (FullDateAlternateKey); 
CREATE STATISTICS DayNumberOfWeek ON DimDate (DayNumberOfWeek);
CREATE STATISTICS EnglishDayNameOfWeek ON DimDate (EnglishDayNameOfWeek);
CREATE STATISTICS SpanishDayNameOfWeek ON DimDate (SpanishDayNameOfWeek);
CREATE STATISTICS FrenchDayNameOfWeek ON DimDate (FrenchDayNameOfWeek);
CREATE STATISTICS DayNumberOfMonth ON DimDate (DayNumberOfMonth); 
CREATE STATISTICS DayNumberOfYear ON DimDate (DayNumberOfYear);
CREATE STATISTICS WeekNumberOfYear ON DimDate (WeekNumberOfYear);
CREATE STATISTICS EnglishMonthName ON DimDate (EnglishMonthName);
CREATE STATISTICS SpanishMonthName ON DimDate (SpanishMonthName);
CREATE STATISTICS FrenchMonthName ON DimDate (FrenchMonthName);
CREATE STATISTICS MonthNumberOfYear ON DimDate (MonthNumberOfYear);
CREATE STATISTICS CalendarQuarter ON DimDate (CalendarQuarter);
CREATE STATISTICS CalendarYear ON DimDate (CalendarYear);
CREATE STATISTICS CalendarSemester ON DimDate (CalendarSemester);
CREATE STATISTICS FiscalQuarter ON DimDate (FiscalQuarter);
CREATE STATISTICS FiscalYear ON DimDate (FiscalYear);
CREATE STATISTICS FiscalSemester ON DimDate (FiscalSemester);


--update statistics on column
UPDATE STATISTICS dbo.DimDate (DateKey);
--update statistics on table
UPDATE STATISTICS dbo.DimDate;

--Exercise 6: Partititons
--create table with partitions
CREATE TABLE OrdersPartition
(
OrderID int IDENTITY(1,1) NOT NULL
,OrderDate datetime NOT NULL
,OrderDescription char(15) DEFAULT 'NewOrder'
)
WITH
(
CLUSTERED COLUMNSTORE INDEX,
DISTRIBUTION = ROUND_ROBIN,
PARTITION
(
OrderDate RANGE RIGHT FOR VALUES
(
'2017-02-05T00:00:00.000'
, '2017-02-12T00:00:00.000'
, '2017-02-19T00:00:00.000'
, '2017-02-26T00:00:00.000'
, '2017-03-05T00:00:00.000'
, '2017-03-12T00:00:00.000'
, '2017-03-19T00:00:00.000'
)
)
);

--generate data
SET NOCOUNT ON
DECLARE @i INT SET @i = 1
DECLARE @date DATETIME SET @date = dateadd(mi,@i,'2017-02-05')
WHILE (@i <= 10)
BEGIN
INSERT INTO OrdersPartition (OrderDate) SELECT @date
INSERT INTO OrdersPartition (OrderDate) SELECT dateadd(week,1,@date)
INSERT INTO OrdersPartition (OrderDate) SELECT dateadd(week,2,@date)
INSERT INTO OrdersPartition (OrderDate) SELECT dateadd(week,3,@date)
INSERT INTO OrdersPartition (OrderDate) SELECT dateadd(week,4,@date)
INSERT INTO OrdersPartition (OrderDate) SELECT dateadd(week,5,@date)
SET @i= @i+1;
END

--check #rows
SELECT COUNT(*) FROM OrdersPartition;

--information about partitions
SELECT
o.name AS Table_name, pnp.partition_number AS Partition_number, sum(pnp.rows) AS Row_count
FROM sys.pdw_nodes_partitions AS pnp
JOIN sys.pdw_nodes_tables AS NTables ON pnp.object_id = NTables.object_id
AND pnp.pdw_node_id = NTables.pdw_node_id
JOIN sys.pdw_table_mappings AS TMap ON NTables.name = TMap.physical_name
AND substring(TMap.physical_name,40, 10) = pnp.distribution_id
JOIN sys.objects AS o ON TMap.object_id = o.object_id
WHERE o.name in ('OrdersPartition')
GROUP BY partition_number, o.name, pnp.data_compression_desc;

--create new table
CREATE TABLE dbo.Orders_Staging
(OrderID int IDENTITY(1,1) NOT NULL
,OrderDate datetime NOT NULL
,OrderDescription char(15) DEFAULT 'NewOrder'
);

-- Check the partitions

SELECT
o.name AS Table_name, pnp.partition_number AS Partition_number, sum(pnp.rows) AS Row_count
FROM sys.pdw_nodes_partitions AS pnp
JOIN sys.pdw_nodes_tables AS NTables ON pnp.object_id = NTables.object_id
AND pnp.pdw_node_id = NTables.pdw_node_id
JOIN sys.pdw_table_mappings AS TMap ON NTables.name = TMap.physical_name
AND substring(TMap.physical_name,40, 10) = pnp.distribution_id
JOIN sys.objects AS o ON TMap.object_id = o.object_id
WHERE o.name in ('Orders_Staging')
GROUP BY partition_number, o.name, pnp.data_compression_desc;
			    
--switch partitions
ALTER TABLE dbo.OrdersPartition SWITCH PARTITION 3 to dbo.Orders_Staging;

--review partitions
SELECT
o.name AS Table_name, pnp.partition_number AS Partition_number, sum(pnp.rows) AS Row_count
FROM sys.pdw_nodes_partitions AS pnp
JOIN sys.pdw_nodes_tables AS NTables ON pnp.object_id = NTables.object_id
AND pnp.pdw_node_id = NTables.pdw_node_id
JOIN sys.pdw_table_mappings AS TMap ON NTables.name = TMap.physical_name
AND substring(TMap.physical_name,40, 10) = pnp.distribution_id
JOIN sys.objects AS o ON TMap.object_id = o.object_id
WHERE o.name in ('OrdersPartition')
GROUP BY partition_number, o.name, pnp.data_compression_desc;


SELECT
o.name AS Table_name, pnp.partition_number AS Partition_number, sum(pnp.rows) AS Row_count
FROM sys.pdw_nodes_partitions AS pnp
JOIN sys.pdw_nodes_tables AS NTables ON pnp.object_id = NTables.object_id
AND pnp.pdw_node_id = NTables.pdw_node_id
JOIN sys.pdw_table_mappings AS TMap ON NTables.name = TMap.physical_name
AND substring(TMap.physical_name,40, 10) = pnp.distribution_id
JOIN sys.objects AS o ON TMap.object_id = o.object_id
WHERE o.name in ('Orders_Staging')
GROUP BY partition_number, o.name, pnp.data_compression_desc;
