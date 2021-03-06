# Cloud Data Integration 101

## Summary
Join Rock Your Data and Matillion and learn best practices for Cloud Analytics and Data Integration. Find out the differences between ETL and ELT from Matillion and see their built for the cloud product on a live demo.
You will hear real-world use cases about data warehouse modernization and cloud data migration projects from industry experts. Finally, a hands-on opportunity where you will learn more about unlocking the potential of your data with Matillion's cloud-based approach to data transformation.

## Getting Matillion Trial
For this workshop, we will use the Orbitera platform where we will launch the Matillion EC2 instance. 
1. Click on the link [Matillion Trial](https://matillion.orbitera.com/c2m/customer/testDrives/index)
2. Sign Up using your and your company information
3. Launch **Matillion ETL for Snowflake**. It will take 10-20 minutes to provision a Matillion instance and you will get an email with URL, login, and password. 

## Connecting Matillion
1. Open the URL that you've got from **Orbitera**. Enter credentials.
2. On the **Join Project** screen choose the project **Test Drive** under the project group **Group**. It has default **environment**.

## Running the first Matillion Job
Matillion ETL instance has two jobs:
* dim_airoports_setup
* dim_airports

Open the **dim_airoports_setup**. Click the right button and choose **Run Job (test)**. It will create tables and load data from S3 into Snowflake. It will create the following tables:
* matillion_stg_airports (with data)
* matillion_us_state_lookup (with data)
* matillion_dim_airports (empty)

Then it will execute the transforamtion job **dim_airports**. It will query **matillion_stg_airports**, apply transformation logic and write into the dimension tables **matillion_dim_airoports**.

Matillion allows us to organize jobs in folders. Let's also create a folder **101**.

## Loading data from S3:
Ok, we ran existing jobs and we got some data in Snowflake. Let's create another job.

1. Click right button on folder **101** in left upper corner and choose **Add Orchestration Job** with name *fact_flights_setup_s3*.
2. We should create a new table based on existing S3 data. We will use the Matillion component **S3 Load Generator**. Drag and drop it to the canvas. 
> S3 Load Generator -  Help to guest data schema and create components for creating tables and load data into this table.
3. We should specify the S3 path for data file *s3://flights-ireland/2001.csv.gz* and click **ok**.
4. Specify compressions type **GZip** and click **Get Sample**. Matillion will guess the schema for you and save you time. 
5. You might change options or test load. We will click **ok**. Matillion will place two components **Create/Replace Table** and **S3 Load**. We should connect components with lines.
> Create/Replace Table - Generate DDL and execute it. It creates or replaces a table.

> S3 Load - Load data into an existing table from objects stored in Amazon Simple Storage Service (Amazon S3).

6. Under the properties of **Create/Replace Table**, we specify *Replace* option, give a new name for a new table *stg_flights*.  
7. Under the properties of **S3 Load** change the table name for *stg_flights* and change the option **On Error** to **Continue**. It will help to continue load in case of failure.
8. We can click anywhere on canvas with the right button and choose **Run Job (test)**. You may notice in the right bottom the Taskbar. It gives us detail information about the job run.
9. When the job finished to run click on a small arrow sign in the Tasks window. It will open a new tab and you can find how many rows were inserted into *stg_flights* tables.

## Loading data from the transactional database
In this case, we will use the RDS database. 
>RDS - Amazon Relational Database Service is a distributed relational database service by Amazon Web Services. It is a web service running "in the cloud" designed to simplify the setup, operation, and scaling of a relational database for use in applications.

1. Click right button on **101** in left upper corner and choose **Add Orchestration Job** with name *fact_flights_setup_rds*.
2. We will query Mysql instance and load data into the *airports*. We will use the Matillion component **RDS Query**. Drag and drop it to the canvas and connect with the **start**.
> RDS Query - Run an SQL Query on an RDS database and copy the result to a table, via S3. Parameters:
RDS Endpoint: metlrds.c16gwuxkvj5t.eu-west-1.rds.amazonaws.com

* Database name: test
* Username: testdrive
* Password: password01 (use option *store in component*)
* SQL Query: select * from raw_airports
* Target Table: airports
* S3 Staging Area: (you get this with your email)
* Table: airports

3. Run the job and check the number of rows with **Task Info**. Matillion will load additional rows into our table.

## Adding Business Logic with Transformation Job

1. Click right button on **101** in left upper corner and choose **Add Transformation Job** with name *fact_flights*.
2. Add **Table Input** component. 
>Tableau Input - Read chosen columns from an input table or view into the job.
3. Choose the source table **stg_flights** and add all **Column Names**.
4. Click **SQL** tab and you will see what Matillion does with data
```sql 
SELECT 
  "iata", 
  "airport", 
  "city", 
  "state", 
  "country", 
  "lat", 
  "long" 
FROM "SQXLKDNY"."PUBLIC"."stg_flights" 
```
5. Check the data sample. Click on **Sample** tab and click **Data**. Matillion will show you sample of data.
6. Add **Filter** component and connect with **Tablea Input**.
> Filter - Filter rows from the input to pass a subset of rows to the next component based on a set of conditions. (WHERE condition)
7. Change the **Filter** properties to *AirTime Not Equal to NA*. It is the same as 
```sql 
WHERE (NOT("ArrTime" = 'NA')) 
```
8. Let's add **Calculator** component. 
>Calculator - Adds new columns by performing calculations. Each row in produces one row of output. Any pre-existing columns that share a name with a created column will be overwritten. 
9. In the **Calculator** component we will calculate the arrival delay using the arrival time *ArrTime* and scheduled arrival time *CRSArrTime*. Click **Properties** and it will open new window. Click **+** and specify the new column details.
* Name: arrival delay
* Logic: CASE WHEN "ArrTime" - "CRSArrTime" < 0 THEN 0 ELSE "ArrTime" - "CRSArrTime" END

The data we have now is giving us the delay, where applicable, for all flights, sorted by year and month number. We will add a month's name. We can use **Calculator step** and write *CASE* statement or we can leverage Matillion component - **Fixed Flow**.
>Fixed Flow - Allows you to generate lines of fixed input or input from variables. Useful for simple static mappings

1. Drag and drop **Fixed Flow**
2. Edit properties and create new column names:
* **MonthNumber** as NUMBER, size 2
* **MonthName** as VARCHAR, size 10
3. Fill the Value parameters. You can copy-paste this into your component with **Text Mode**:
1	January
2	February
3	March
4	April
5	May
6	June
7	July
8	August
9	September
10	October
11	November
12	December
4. Add **Join** component and connect both data flows.
>Join - Join 2 or more input flows into a single output.
5. Specify the main table as **Calculator 0** with alias **f** 
6. Add *inner join* with **Fixed Flow 0** with alias **m**.
7. Specify the join condition as *"f"."Month"="m"."MonthNumber"*
8. Specify output components by add all - **Add All**.
9. To get average delay by month, we will use the **Aggregate** component. 
>Aggregate - This component works by grouping multiple input rows into a single output row. Input columns can be added to the groupings, or have an aggregation applied to them.
10. In **Aggregate** component properties we will aggregate:
* *arrival delay* with *Sum*
* *FlightNum* with *Count*
and group by *MonthName*
We can review the begin of the SQL:
```sql
SELECT 
  "MonthName", 
  SUM("arrival delay") AS "sum_arrival delay", 
  COUNT("FlightNum") AS "count_FlightNum" 
FROM ($T{Join 0}) 
GROUP BY "MonthName"
```
11. Next, we will calculate average delay. Drag and drop another **Calculator** component and connect it with **Aggregate** component. 
12. Create new column name *avg delay by month* with logic *"sum_arrival delay"/"count_FlightNum"*. Review the data with Sample.
13. Drag and drop **Rewrite Tablea** component and connect with **Calculator**
>Rewrite Table - Write the input data flow out to a new table. It will create table during the run.
14. Add table name *flight_delay* and run the job.





