# Cloud Data Integration 101

## Summary
Join Rock Your Data and Matillion and learn best practices for Cloud Analytics and Data Integration. Find out the differences between ETL and ELT from Matillion and see their built for the cloud product on a live demo.
You will hear real world use cases about data warehouse modernization and cloud data migration projects from industry experts. Finally, a hands-on opportunity where you will learn more on unlocking the potential of your data with Matillion's cloud-based approach to data transformation.

## Getting Matillion Trial
For this workshop, we will use Orbitera platform where we will launch Matillion EC2 instnce. 
1. Click on the link [Matillion Trial](https://matillion.orbitera.com/c2m/customer/testDrives/index)
2. Sign Up using your and your company information
3. Launch **Matillion ETL for Snowflake**. It will take 10-20 minutes to provision Matillion isntance and you will get email with URL, login and password. 

## Connecting Matillion
1. Open the URL that you've got from **Orbitera**. Enter credentials.
2.On the **Join Project** screen choose the project **Test Drive** under the project group **Group**. It has default **environment**.

## Running the first Matillion Job
Matillion ETL instance has two jobs:
* dim_airoports_setup
* dim_airports

1. Open the **dim_airoports_setup**. Click right button and choose **Run Job (test)**. It will create tables and load data from S3 into Snowflake. Then it will execute the transforamtion job **dim_airports**. It will query **matillion_stg_airports**, apply transformation logic and write into the dimension tables **matillion_dim_airoports**. 

