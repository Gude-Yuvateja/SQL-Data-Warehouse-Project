-- adding Data from CSV file 

CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	DECLARE @Start_time DATETIME, @End_time DATETIME, @Batch_Start_time DATETIME, @Batch_End_time DATETIME;
	BEGIN TRY
		SET @Batch_Start_time = GETDATE();
		PRINT '============================================================';
		PRINT 'Loading Bronze layer';
		PRINT '============================================================';

		PRINT '============================================================';
		PRINT 'Loading CRM Tables';
		PRINT '============================================================';

		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Bronze.crm_cust_info'
		TRUNCATE TABLE Bronze.crm_cust_info; 

		PRINT '>> Inserting Data Into : Bronze.crm_cust_info'
		BULK INSERT Bronze.crm_cust_info
		From 'C:\Users\PC\OneDrive\Desktop\SQL\DATA WAREHOUSE PROJECT\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'

		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Bronze.crm_prd_info'
		TRUNCATE TABLE Bronze.crm_prd_info;

		PRINT '>> Inserting Data Into : Bronze.crm_prd_info'
		BULK INSERT Bronze.crm_prd_info
		From 'C:\Users\PC\OneDrive\Desktop\SQL\DATA WAREHOUSE PROJECT\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'

		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Bronze.crm_sales_details'
		TRUNCATE TABLE Bronze.crm_sales_details;

		PRINT '>> Inserting Data Into : Bronze.crm_sales_details'
		BULK INSERT Bronze.crm_sales_details
		From 'C:\Users\PC\OneDrive\Desktop\SQL\DATA WAREHOUSE PROJECT\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'

		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Bronze.erp_cust_az12'
		TRUNCATE TABLE Bronze.erp_cust_az12;

		PRINT '>> Inserting Data Into : Bronze.erp_cust_az12'
		BULK INSERT Bronze.erp_cust_az12
		From 'C:\Users\PC\OneDrive\Desktop\SQL\DATA WAREHOUSE PROJECT\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'

		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Bronze.erp_loc_a101'
		TRUNCATE TABLE Bronze.erp_loc_a101;

		PRINT '>> Inserting Data Into : Bronze.erp_loc_a101'
		BULK INSERT Bronze.erp_loc_a101
		From 'C:\Users\PC\OneDrive\Desktop\SQL\DATA WAREHOUSE PROJECT\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'
		
		SET @Start_time = GETDATE();
		PRINT '>> Truncate Table : Bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE Bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into : Bronze.erp_px_cat_g1v2'
		BULK INSERT Bronze.erp_px_cat_g1v2
		From 'C:\Users\PC\OneDrive\Desktop\SQL\DATA WAREHOUSE PROJECT\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @END_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST(DATEDIFF(Second, @Start_time, @End_time) AS NVARCHAR) + ' Seconds';
		PRINT '--------------'
	
		SET @Batch_END_time = GETDATE();
		PRINT '============================================================';
		PRINT 'Loading Bronze layer is Completed';
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
END


EXEC Bronze.load_bronze;