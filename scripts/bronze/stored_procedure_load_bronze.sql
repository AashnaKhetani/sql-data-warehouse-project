/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    call bronze.load_bronze();
===============================================================================
*/


CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time   TIMESTAMP;
    v_duration   INTERVAL;
    b_start_time TIMESTAMP;
    b_end_time   TIMESTAMP;
    b_duration   INTERVAL;
    
BEGIN
	b_start_time := clock_timestamp();
    RAISE NOTICE '=======================================================';
    RAISE NOTICE 'STARTING BRONZE LAYER DATA WAREHOUSE INGESTION';
    RAISE NOTICE '=======================================================';

    -- ========================================================================
    -- 1. CRM SOURCE SYSTEM
    -- ========================================================================
    RAISE NOTICE '>>> Processing CRM Source System Files...';

    -- Table: bronze.crm_cust_info
    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE '   -> Truncating and loading bronze.crm_cust_info...';
        TRUNCATE TABLE bronze.crm_cust_info;
        EXECUTE 'COPY bronze.crm_cust_info FROM ''/Users/Shared/datasets/source_crm/cust_info.csv'' WITH (FORMAT CSV, HEADER true, FREEZE true)';
        v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded crm_cust_info in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load crm_cust_info. Reason: %', SQLERRM;
    END;

    -- Table: bronze.crm_prd_info
    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE '   -> Truncating and loading bronze.crm_prd_info...';
        TRUNCATE TABLE bronze.crm_prd_info;
        EXECUTE 'COPY bronze.crm_prd_info FROM ''/Users/Shared/datasets/source_crm/prd_info.csv'' WITH (FORMAT CSV, HEADER true, FREEZE true)';
        v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded crm_prd_info in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load crm_prd_info. Reason: %', SQLERRM;
    END;

    -- Table: bronze.crm_sales_details
    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE '   -> Truncating and loading bronze.crm_sales_details...';
        TRUNCATE TABLE bronze.crm_sales_details;
        EXECUTE 'COPY bronze.crm_sales_details FROM ''/Users/Shared/datasets/source_crm/sales_details.csv'' WITH (FORMAT CSV, HEADER true, FREEZE true)';
        v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded crm_sales_details in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load crm_sales_details. Reason: %', SQLERRM;
    END;


    -- ========================================================================
    -- 2. ERP SOURCE SYSTEM
    -- ========================================================================
    RAISE NOTICE '>>> Processing ERP Source System Files...';

    -- Table: bronze.erp_cust_az12
    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE '   -> Truncating and loading bronze.erp_cust_az12...';
        TRUNCATE TABLE bronze.erp_cust_az12;
        EXECUTE 'COPY bronze.erp_cust_az12 FROM ''/Users/Shared/datasets/source_erp/cust_az12.csv'' WITH (FORMAT CSV, HEADER true, FREEZE true)';
        v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded erp_cust_az12 in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load erp_cust_az12. Reason: %', SQLERRM;
    END;

    -- Table: bronze.erp_loc_a101
    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE '   -> Truncating and loading bronze.erp_loc_a101...';
        TRUNCATE TABLE bronze.erp_loc_a101;
        EXECUTE 'COPY bronze.erp_loc_a101 FROM ''/Users/Shared/datasets/source_erp/loc_a101.csv'' WITH (FORMAT CSV, HEADER true, FREEZE true)';
        v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded erp_loc_a101 in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load erp_loc_a101. Reason: %', SQLERRM;
    END;

    -- Table: bronze.erp_px_cat_g1v2
    BEGIN
        v_start_time := clock_timestamp();
        RAISE NOTICE '   -> Truncating and loading bronze.erp_px_cat_g1v2...';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        EXECUTE 'COPY bronze.erp_px_cat_g1v2 FROM ''/Users/Shared/datasets/source_erp/px_cat_g1v2.csv'' WITH (FORMAT CSV, HEADER true, FREEZE true)';
        v_end_time := clock_timestamp();
        v_duration := v_end_time - v_start_time;
        RAISE NOTICE '      [SUCCESS] Loaded erp_px_cat_g1v2 in % seconds', v_duration;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '      [ERROR] Failed to load erp_px_cat_g1v2. Reason: %', SQLERRM;
    END;

	b_end_time := clock_timestamp();
	b_duration := b_end_time - b_start_time;
    -- ========================================================================
    -- END OF LOADING PROCESS
    -- ========================================================================
    RAISE NOTICE '=======================================================';
    RAISE NOTICE 'BATCH JOB COMPLETED in % seconds: Review logs above for any errors.', b_duration;
    RAISE NOTICE '=======================================================';

END;
$$;
