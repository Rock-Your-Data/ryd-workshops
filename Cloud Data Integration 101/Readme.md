# Cloud Data Integration 101

## Summary
Join Rock Your Data and Matillion and learn best practices for Cloud Analytics and Data Integration. Find out the differences between ETL and ELT from Matillion and see their built for the cloud product on a live demo.
You will hear real world use cases about data warehouse modernization and cloud data migration projects from industry experts. Finally, a hands-on opportunity where you will learn more on unlocking the potential of your data with Matillion's cloud-based approach to data transformation.

## Getting Matillion Trial
For this workshop, we will use the Orbitera platform where we will launch the Matillion EC2 instance. 
1. Click on the link [Matillion Trial](https://matillion.orbitera.com/c2m/customer/testDrives/index)
2. Sign Up using your and your company information
3. Launch **Matillion ETL for Snowflake**. It will take 10-20 minutes to provision Matillion instance and you will get an email with URL, login, and password. 

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
8. We can click anywhere on canvas with right button and choose **Run Job (test)**. You may notice in right bottom the Task bar. It gives us detail information about the job run.
9. When job finish to run click on small arrow signe in Tasks window. It will open new tabe and you can find how many rows were insreted into *stg_flights* tables.

## Loading data from transactional database
In this case we will use RDS databse. 
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
2. Add **Tablea Input** component. 
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
7. Change the **Filter** properties to *AirTime Not Equal to NA*.



