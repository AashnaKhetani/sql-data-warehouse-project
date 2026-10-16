/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'data_warehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'data_warehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

-- Drop and recreate the 'DataWarehouse' database

DROP DATABASE IF EXISTS "data_warehouse" WITH (FORCE);
CREATE DATABASE "data_warehouse";
  
-- Create Schemas

CREATE SCHEMA bronze;

CREATE SCHEMA silver;

CREATE SCHEMA gold;

