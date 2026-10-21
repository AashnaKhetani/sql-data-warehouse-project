/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_customers cascade;

create view gold.dim_customers AS
select 
	row_number() over (order by cst_id) as customer_key, -- Surrogate Key
	cci.cst_id as customer_id,
	cci.cst_key as customer_number,
	cci.cst_firstname as first_name,
	cci.cst_lastname as last_name,
	ela.cntry as country,
	cci.cst_marital_status as marital_status,
	case
		when cci.cst_gndr != 'n/a' then cci.cst_gndr -- CRM is considered Master for gender info
		else coalesce(eca.gen, 'n/a')	-- Fallback to ERP data
	end as gender,
	eca.bdate as birthdate,
	cci.cst_create_date as create_date
from silver.crm_cust_info cci
left join silver.erp_cust_az12 eca 
on cci.cst_key = eca.cid
left join silver.erp_loc_a101 ela 
on cci.cst_key = ela.cid;


-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================


DROP VIEW IF EXISTS gold.dim_products cascade;

create view gold.dim_products as

select
	row_number() over(order by cpi.prd_start_dt, cpi.prd_key) as product_key, --surrogate key that creates a unique id for every new prd_key with a start date
	cpi.prd_id as product_id,
	cpi.prd_key as product_number,
	cpi.prd_nm as product_name,
	cpi.cat_id as category_id,
	epc.cat as category,
	epc.subcat as subcategory,
	cpi.prd_line as product_line,
	cpi.prd_cost as cost,
	epc.maintenance,
	cpi.prd_start_dt as start_date
from silver.crm_prd_info cpi
left join silver.erp_px_cat_g1v2 epc
on cpi.cat_id = epc.id 
where cpi.prd_end_dt is null; --filter out all historical data



-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================


DROP VIEW IF EXISTS gold.fact_sales cascade;

create view gold.fact_sales as

-- join dimensions with fact and add surrogate keys from dims to the fact
select
	csd.sls_ord_num as order_number,
--	csd.sls_prd_key, - removed and added dimension's surrogate key
	dp.product_key,
--	csd.sls_cust_id, - removed and added dimension's surrogate key
	dc.customer_key,
	csd.sls_order_dt as order_date,
	csd.sls_ship_dt as ship_date,
	csd.sls_due_dt as due_date,
	csd.sls_sales as sales_amount,
	csd.sls_quantity as quantity,
	csd.sls_price as price 
from silver.crm_sales_details csd
left join gold.dim_customers dc
on csd.sls_cust_id = dc.customer_id
left join gold.dim_products dp 
on csd.sls_prd_key = dp.product_number ;
