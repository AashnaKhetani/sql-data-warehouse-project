/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
      This stored procedure does not accept any parameters or return any values.

Usage Example:
    call silver.load_silver();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
	v_start_time TIMESTAMP;
    v_end_time   TIMESTAMP;
    v_duration   INTERVAL;
    batch_start_time TIMESTAMP;
    batch_end_time   TIMESTAMP;
    batch_duration   INTERVAL;
    
BEGIN
	batch_start_time := clock_timestamp();
    RAISE NOTICE '=======================================================';
    RAISE NOTICE 'STARTING SILVER LAYER DATA WAREHOUSE LOAD';
    RAISE NOTICE '=======================================================';

    -- ========================================================================
    -- 1. CRM SOURCE SYSTEM
    -- ========================================================================
    RAISE NOTICE '>>> Loading CRM Tables into Silver Layer...';

    -- Table: silver.crm_cust_info
    BEGIN
    	v_start_time := clock_timestamp();
		RAISE NOTICE '   -> Truncating and loading silver.crm_cust_info...';
	    TRUNCATE TABLE silver.crm_cust_info;
		insert into silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		
		select 
		cst_id,
		cst_key,
		TRIM(cst_firstname) as cst_firstname,
		TRIM(cst_lastname) as cst_lastname,
		
		case	
			when upper(cst_marital_status) = 'S' then 'Single'
			when upper(cst_marital_status) = 'M' then 'Married'
			else 'n/a'
		end as cst_marital_status,
		
		case
			when upper(cst_gndr) = 'F' then 'Female'
			when upper(cst_gndr) = 'M' then 'Male'
			else 'n/a'
		end as cst_gndr,
		
		cst_create_date 
		
		from (
		
		select *, 
		
		ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag
		
		from bronze.crm_cust_info where cst_id is not NULL)t where flag = 1;
		v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded crm_cust_info in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load crm_cust_info. Reason: %', SQLERRM;
    END;
	
	-- Table: silver.crm_prd_info
    BEGIN
		v_start_time := clock_timestamp();
		RAISE NOTICE '   -> Truncating and loading silver.crm_prd_info...';
	    TRUNCATE TABLE silver.crm_prd_info;
		insert into SILVER.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		
		select 
		prd_id,
		replace(substring(prd_key, 1, 5), '-' , '_') as cat_id,
		substring(prd_key, 7, length(prd_key) ) as prd_key,
		prd_nm,
		coalesce(prd_cost, 0) as prd_cost,
		
		case upper(trim(prd_line))
			when 'M' then 'Mountain'
			when 'R' then 'Road'
			when 'S' then 'Other Sales'
			when 'T' then 'Touring'
			else 'n/a'
		end as prd_line,
		
		cast(prd_start_dt as DATE) as prd_start_dt,
		
		cast((lead(prd_start_dt) over (partition by prd_key order by prd_start_dt ASC)) - interval '1 day' as DATE) as prd_end_dt
		
		from bronze.crm_prd_info;
		v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded crm_prd_info in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load crm_prd_info. Reason: %', SQLERRM;
    END;

    -- Table: silver.crm_sales_details
    BEGIN
        v_start_time := clock_timestamp();
		RAISE NOTICE '   -> Truncating and loading silver.crm_sales_details...';
	    TRUNCATE TABLE silver.crm_sales_details;
		
		insert INTO silver.crm_sales_details (
		    sls_ord_num,
		    sls_prd_key,
		    sls_cust_id,
		    sls_order_dt,
		    sls_ship_dt,
		    sls_due_dt,
		    sls_sales,
		    sls_quantity,
		    sls_price
		)
		
		select
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		case
			when sls_order_dt = 0 or LENGTH(sls_order_dt :: varchar) != 8 then null
			else to_date(sls_order_dt :: text, 'YYYYMMDD')
		end as sls_order_dt,
		
		case
			when sls_ship_dt = 0 or LENGTH(sls_ship_dt :: varchar) != 8 then null
			else to_date(sls_ship_dt :: text, 'YYYYMMDD')
		end as sls_ship_dt,
		
		case
			when sls_due_dt = 0 or LENGTH(sls_due_dt :: varchar) != 8 then null
			else to_date(sls_due_dt :: text, 'YYYYMMDD')
		end as sls_due_dt,
		
		case
			when sls_sales is null or sls_sales <0 or sls_sales != sls_quantity * sls_price then abs(sls_quantity) * abs(sls_price)
			else sls_sales
		end as sls_sales,
		
		abs(sls_quantity) as sls_quantity,
		
		case
			when sls_price is null or sls_price <=0 then abs(sls_sales)/ nullif(sls_quantity,0)
			else sls_price
		end as sls_price
		
		
		from bronze.crm_sales_details;
		v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded crm_sales_details in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load crm_sales_details. Reason: %', SQLERRM;
    END;


    -- ========================================================================
    -- 2. ERP SOURCE SYSTEM
    -- ========================================================================
    RAISE NOTICE '>>> Loading ERP Tables into Silver Layer...';

    -- Table: silver.erp_cust_az12
    BEGIN
        v_start_time := clock_timestamp();    
    
		
		RAISE NOTICE '   -> Truncating and loading silver.erp_cust_az12...';
	    TRUNCATE TABLE silver.erp_cust_az12;
		
		insert into silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		
		select 
		
		case
			when cid like 'NAS%' then substring(cid,4, length(cid)) 
			else cid
		end	as cid,
		
		case
			when bdate > current_timestamp then null
			else bdate
		end as bdate,
		
		case
			when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
			when upper(trim(gen)) in ('M', 'MALE') then 'Male'
			else 'n/a'
		end as gen
		from bronze.erp_cust_az12;
		
		RAISE NOTICE '   -> Truncating and loading silver.erp_loc_a101...';
	    TRUNCATE TABLE silver.erp_loc_a101;
		v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded erp_cust_az12 in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load erp_cust_az12. Reason: %', SQLERRM;
    END;


    -- Table: silver.erp_loc_a101
    BEGIN
        v_start_time := clock_timestamp();
		insert into silver.erp_loc_a101 (
			cid,
			cntry
		)
		
		select
		replace(cid, '-', '') as cid,
		case
			when trim(cntry) = 'DE' then 'Germany'
			when trim(cntry) IN ('US', 'USA') then 'United States'
			when trim(cntry) = ''  or cntry is null then 'n/a'
			else trim(cntry)	
		end as cntry
		from bronze.erp_loc_a101;
		v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded erp_loc_a101 in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load erp_loc_a101. Reason: %', SQLERRM;
    END;

    -- Table: silver.erp_px_cat_g1v2
    BEGIN
        v_start_time := clock_timestamp();
		RAISE NOTICE '   -> Truncating and loading silver.erp_px_cat_g1v2...';
	    TRUNCATE TABLE silver.erp_px_cat_g1v2;
		
		insert into silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		
		select
		id,
		cat,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2;
		v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded erp_px_cat_g1v2 in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load erp_px_cat_g1v2. Reason: %', SQLERRM;
    END;

	batch_end_time := clock_timestamp();
	batch_duration := batch_end_time - batch_start_time;
    -- ========================================================================
    -- END OF SILVER LAYER LOADING PROCESS
    -- ========================================================================
    RAISE NOTICE '=======================================================';
    RAISE NOTICE 'SILVER LAYER LOADING BATCH JOB COMPLETED in % seconds: Review logs above for any errors.', batch_duration;
    RAISE NOTICE '=======================================================';

END;
$$;


-- call this procedure using: call silver.load_silver();
