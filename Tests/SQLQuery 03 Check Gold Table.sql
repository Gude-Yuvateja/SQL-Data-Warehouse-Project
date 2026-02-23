-- GOLD Tables Test case


-- Creating customers dimension  

SELECT cst_id, COUNT(*) FROM (
SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM Silver.crm_cust_info AS ci
LEFT JOIN Silver.erp_cust_az12 AS ca
ON ca.cid = ci.cst_key
LEFT JOIN Silver.erp_loc_a101 AS la
ON la.cid = ci.cst_key) AS t
GROUP BY cst_id 
HAVING COUNT(*) > 1;


SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr   -- CRM is the master for Gender Info
		 ELSE COALESCE(ca.gen, 'N/A')
	END AS new_gen
FROM Silver.crm_cust_info AS ci
LEFT JOIN Silver.erp_cust_az12 AS ca
ON ca.cid = ci.cst_key
LEFT JOIN Silver.erp_loc_a101 AS la
ON la.cid = ci.cst_key
ORDER BY 1,2;


SELECT * FROM Gold.dim_customers



-- Creating Product Dimension

SELECT prd_key, COUNT(*) FROM (
SELECT
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM Silver.crm_prd_info AS pn
LEFT JOIN Silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL   -- Filter out all historical data 
) AS t GROUP BY prd_key
HAVING COUNT(*) > 1;


SELECT * FROM Gold.dim_products



-- Creating Sales Fact

SELECT * FROM Gold.fact_sales


-- Foreign Key Integrity (Dimensions)

SELECT *
FROM Gold.fact_sales AS f
LEFT JOIN Gold.dim_products AS p
ON p.Product_Key = f.Product_Key
WHERE p.Product_Key IS NULL


SELECT *
FROM Gold.fact_sales AS f
LEFT JOIN Gold.dim_customers AS c
ON f.Customer_Key = c.Customer_Key
WHERE c.Customer_Key IS NULL
