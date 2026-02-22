
-- Bronze layer 1st CRM Table check 

SELECT * FROM Bronze.crm_cust_info;


-- Check For nulls or Duplicates in primary key
-- Expectation : No Result

SELECT 
	cst_id,
	COUNT(*)
FROM Bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Check for unwanted spaces
-- Expectation : No Results

SELECT cst_key
FROM Bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT cst_firstname
FROM Bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM Bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM Bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

SELECT cst_marital_status
FROM Bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);


-- Data Standardization And Consistency

SELECT DISTINCT cst_gndr 
FROM Bronze.crm_cust_info;

SELECT DISTINCT cst_material_status
FROM Bronze.crm_cust_info;




-- Bronze layer 2nd CRM Table check 

SELECT * FROM Bronze.crm_prd_info;


-- Check For nulls or Duplicates in primary key
-- Expectation : No Result

SELECT 
	prd_id,
	COUNT(*)
FROM Bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Check for unwanted spaces
-- Expectation : No Results

SELECT prd_key
FROM Bronze.crm_prd_info
WHERE prd_key != TRIM(prd_key);

SELECT prd_nm
FROM Bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for NULLS or Negative Numbers
-- Expectation : No Result

SELECT prd_cost
FROM Bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Data Standardization And Consistency

SELECT DISTINCT prd_line 
FROM Bronze.crm_prd_info;


-- Check for Invalid Date Orders

SELECT *
FROM Bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;





-- Bronze layer 3rd CRM Table check 

SELECT * FROM Bronze.crm_sales_details;

-- Check for Invaild Dates

SELECT
NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

SELECT
NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM Bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

SELECT
NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM Bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101


-- Check for Invaild Date orders

SELECT
*
FROM Bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


-- Check Data consistency : B/w Sales, Quantity, and price 
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, ZERO, OR NEGATIVE

SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,
	CASE WHEN sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) 
			THEN sls_quantity * ABS(sls_price)
		 ELSE sls_sales
	END AS sls_sales,

	CASE WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity,0)
		 ELSE sls_price
	END AS sls_price
FROM Bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;






-- Bronze layer 1st ERP Table check 

SELECT * FROM Bronze.erp_cust_az12;


-- Identify out-of-Range Dates

SELECT DISTINCT 
bdate
FROM Bronze.erp_cust_az12
WHERE bdate < '1900-01-01' OR bdate > GETDATE();


-- Data Standardization and consistency

SELECT DISTINCT 
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	 ELSE 'N/A'
END AS gen
FROM Bronze.erp_cust_az12;




-- Bronze layer 2nd ERP Table check 

SELECT * FROM Bronze.erp_loc_a101;


-- Data Standardization and Consistency

SELECT DISTINCT Cntry AS Old,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
		 ELSE TRIM(cntry)
	END AS cntry   -- Normalize and handle missing or blank country codes
FROM Bronze.erp_loc_a101
ORDER BY cntry;



-- Bronze layer 3rd ERP Table check 

SELECT * FROM Bronze.erp_px_cat_g1v2;

-- Check for unwanted spaces

SELECT * FROM Bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance);


-- Data Standardization and consistency

SELECT DISTINCT 
cat
FROM Bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
subcat
FROM Bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
maintenance
FROM Bronze.erp_px_cat_g1v2;