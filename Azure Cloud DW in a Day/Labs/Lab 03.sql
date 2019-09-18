--Exercise 1
--Drop table


--create new table
CREATE TABLE dbo.SuperStoreOrders
(
	RowID [int] NOT NULL,
    OrderID [nvarchar](200) NOT NULL,
    OrderDate DATE NOT NULL,
    ShipDate DATE NOT NULL,
    ShipMode [nvarchar](200) NOT NULL,
    CustomerID [nvarchar](200) NOT NULL,
    CustomerName [nvarchar](200) NOT NULL,
    Segment [nvarchar](200) NOT NULL,
    Country [nvarchar](200) NOT NULL,
    City [nvarchar](200) NOT NULL,
    State [nvarchar](200) NOT NULL,
    PostalCode int,
    Region [nvarchar](200) NOT NULL,
    ProductID [nvarchar](200) NOT NULL,
    Category [nvarchar](200) NOT NULL,
    SubCategory [nvarchar](200) NOT NULL,
    ProductName [nvarchar](200) NOT NULL,
    Sales [money] NOT NULL,
    Quantity int,
    Discount [money] NOT NULL,
    Profit [money] NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( RowID ),
	CLUSTERED COLUMNSTORE INDEX
);

--check the result
select City, SUM (Sales) as Sales_Amount 
from dbo.SuperStoreOrders
group by City
order by City desc;