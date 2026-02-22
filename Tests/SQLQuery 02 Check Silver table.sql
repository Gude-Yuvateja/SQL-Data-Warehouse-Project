-- Silver layer 1st CRM Table Check

-- Check For nulls or Duplicates in primary key
-- Expectation : No Result

SELECT 
	cst_id,
	COUNT(*)
FROM Silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Check for unwanted spaces
-- Expectation : No Results

SELECT cst_key
FROM Silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT cst_firstname
FROM Silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM Silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM Silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

SELECT cst_marital_status
FROM Silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);


-- Data Standardization And Consistency

SELECT DISTINCT cst_gndr 
FROM Silver.crm_cust_info;

SELECT DISTINCT cst_material_status
FROM Silver.crm_cust_info;

SELECT * FROM Silver.crm_cust_info;




-- Silver layer 2nd CRM Table check 

-- Check For nulls or Duplicates in primary key
-- Expectation : No Result

SELECT 
	prd_id,
	COUNT(*)
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Check for unwanted spaces
-- Expectation : No Results

SELECT prd_key
FROM Silver.crm_prd_info
WHERE prd_key != TRIM(prd_key);

SELECT prd_nm
FROM Silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for NULLS or Negative Numbers
-- Expectation : No Result

SELECT prd_cost
FROM Silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Data Standardization And Consistency

SELECT DISTINCT prd_line 
FROM Silver.crm_prd_info;


-- Check for Invalid Date Orders

SELECT *
FROM Silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

SELECT * FROM Silver.crm_prd_info;





-- Silver layer 3rd CRM Table check 


-- Check for Invaild Date orders

SELECT
*
FROM Silver.crm_sales_details
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
FROM Silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;


SELECT * FROM Silver.crm_sales_details;




-- Silver layer 1st ERP Table check 

-- Identify out-of-Range Dates

SELECT DISTINCT 
bdate
FROM Silver.erp_cust_az12
WHERE bdate < '1900-01-01' OR bdate > GETDATE();


-- Data Standardization and consistency

SELECT DISTINCT 
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	 ELSE 'N/A'
END AS gen
FROM Silver.erp_cust_az12;


SELECT * FROM Silver.erp_cust_az12;





-- Silver layer 2nd ERP Table check 

-- Data Standardization and Consistency

SELECT DISTINCT Cntry AS Old,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
		 ELSE TRIM(cntry)
	END AS cntry
FROM Silver.erp_loc_a101
ORDER BY cntry

SELECT * FROM Silver.erp_loc_a101;





-- Silver layer 3rd ERP Table check 

-- Check for unwanted spaces

SELECT * FROM Silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance);


-- Data Standardization and consistency

SELECT DISTINCT 
cat
FROM Silver.erp_px_cat_g1v2;

SELECT DISTINCT 
subcat
FROM Silver.erp_px_cat_g1v2;

SELECT DISTINCT 
maintenance
FROM Silver.erp_px_cat_g1v2;

SELECT * FROM Silver.erp_px_cat_g1v2;
