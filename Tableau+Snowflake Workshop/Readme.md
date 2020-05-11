# Create a table in DW and load data into it.
```sql
CREATE TABLE superstore_orders
(
	"rowid" BIGINT  
	,"row id" DOUBLE
	,"order id" VARCHAR(2000)   
	,"order date" TIMESTAMP 
	,"ship date" TIMESTAMP   
	,"ship mode" STRING 
	,"customer id" STRING  
	,"customer name" STRING 
	,segment STRING 
	,country STRING
	,city STRING  
	,state STRING
	,"postal code" DOUBLE  
	,"region" STRING 
	,"product id" STRING
	,category STRING  
	,"sub-category" STRING
	,"product name" STRING
	,sales DOUBLE    
	,quantity DOUBLE
	,discount DOUBLE
	,profit DOUBLE 
);
```

```sql
copy into superstore_orders
  from @TUG
  pattern='unload_superstore_single.csv'
  file_format = (type = csv field_delimiter = '|' skip_header = 1);
```

# VARIANT Example
```sql
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.WEATHER.WEATHER_14_TOTAL LIMIT 2;
```
