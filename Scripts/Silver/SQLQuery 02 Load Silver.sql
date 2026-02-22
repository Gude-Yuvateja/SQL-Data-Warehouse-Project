CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
	DECLARE @Start_time DATETIME, @End_time DATETIME, @Batch_Start_time DATETIME, @Batch_End_time DATETIME;
	BEGIN TRY
		SET @Batch_Start_time = GETDATE();
		PRINT '============================================================';
		PRINT 'Loading Silver layer';
		PRINT '============================================================';

		PRINT '============================================================';
		PRINT 'Loading CRM Tables';
		PRINT '============================================================';
		
		-- Loading silver.crm_cust_info
		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Silver.crm_cust_info'
		TRUNCATE TABLE Silver.crm_cust_info; 
		PRINT '>> Inserting Data Into : Silver.crm_cust_info'
		INSERT INTO Silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 ELSE 'N/A'
			END AS cst_marital_status,    -- Normalize marital status values to readable formate
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 ELSE 'N/A'
			END AS cst_gndr,           -- Normalize gndr values to readable formate
			cst_create_date
		FROM (
			SELECT *,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM Bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) AS t WHERE flag_last = 1;      -- Select the most recent records per customer
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'

		-- Loading Silver.crm_prd_info
		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Silver.crm_prd_info'
		TRUNCATE TABLE Silver.crm_prd_info;
		PRINT '>> Inserting Data Into : Silver.crm_prd_info'
		INSERT INTO Silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				 WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				 ELSE 'N/A'
			END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
		FROM Bronze.crm_prd_info
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'

		-- Loading.crm_sales_details 
		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Silver.crm_sales_details'
		TRUNCATE TABLE Silver.crm_sales_details;
		PRINT '>> Inserting Data Into : Silver.crm_sales_details'
		INSERT INTO Silver.crm_sales_details (
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
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE WHEN sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
				 ELSE sls_sales
			END AS sls_sales,     -- Recalculate sales if orginal value is missing or incorrect
			sls_quantity,
			CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity,0)
				 ELSE sls_price
			END AS sls_price
		FROM Bronze.crm_sales_details
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'
		
		PRINT '============================================================';
		PRINT 'Loading ERP Tables';
		PRINT '============================================================';
		
		-- Loading Silver.erp_cust_az12
		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Silver.erp_cust_az12'
		TRUNCATE TABLE Silver.erp_cust_az12;
		PRINT '>> Inserting Data Into : Silver.erp_cust_az12'
		INSERT INTO Silver.erp_cust_az12 ( cid, bdate, gen)
		SELECT
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				 ELSE cid
			END AS cid,
			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate,   -- Set Future birthdates to NULL
			CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
				 WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
				 ELSE 'N/A'
			END AS gen   -- Normalize gender values and handle unknown cases
		FROM Bronze.erp_cust_az12
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'

		-- Loading Silver.erp_loc_a101
		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Silver.erp_loc_a101'
		TRUNCATE TABLE Silver.erp_loc_a101;
		PRINT '>> Inserting Data Into : Silver.erp_loc_a101'
		INSERT INTO Silver.erp_loc_a101 ( cid, cntry)
		SELECT 
			REPLACE(cid, '-', '') cid,
			CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
				 ELSE TRIM(cntry)
			END AS cntry
		FROM Bronze.erp_loc_a101;
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'

		-- Loading Silver.erp_px_cat_g1v2
		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Silver.erp_px_cat_g1v2'
		TRUNCATE TABLE Silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into : Silver.erp_px_cat_g1v2'
		INSERT INTO Silver.erp_px_cat_g1v2 
		(id, cat, subcat, maintenance)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM Bronze.erp_px_cat_g1v2
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'
	
		SET @Batch_END_time = GETDATE();
		PRINT '============================================================';
		PRINT 'Loading Silver layer is Completed';
		PRINT '-- Total Load Duration : ' + CAST(DATEDIFF(Second, @Batch_Start_time, @Batch_End_time) AS NVARCHAR) + ' Seconds';
		PRINT '============================================================';
	END TRY
	BEGIN CATCH
		PRINT '==========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '============================================'
	END CATCH
END;


EXEC Silver.load_silver;