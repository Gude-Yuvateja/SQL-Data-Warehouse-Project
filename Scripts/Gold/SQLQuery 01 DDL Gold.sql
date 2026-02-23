
IF OBJECT_ID('Gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW Gold.dim_customers;
GO

CREATE VIEW Gold.dim_customers AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS Customer_Key,
	ci.cst_id AS Customer_ID,
	ci.cst_key AS Customer_Number,
	ci.cst_firstname AS First_Name,
	ci.cst_lastname AS Last_Name,
	la.cntry AS Country,
	ci.cst_marital_status AS Maritsl_Status,
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr   -- CRM is the master for Gender Info
		 ELSE COALESCE(ca.gen, 'N/A')
	END AS Gender,
	ca.bdate As Birth_Date,
	ci.cst_create_date AS Create_Date
FROM Silver.crm_cust_info AS ci
LEFT JOIN Silver.erp_cust_az12 AS ca
ON ca.cid = ci.cst_key
LEFT JOIN Silver.erp_loc_a101 AS la
ON la.cid = ci.cst_key;


GO


IF OBJECT_ID('Gold.dim_products', 'V') IS NOT NULL
	DROP VIEW Gold.dim_products;
GO

CREATE VIEW Gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS Product_Key,
	pn.prd_id AS Product_ID,
	pn.prd_key AS Product_Number,
	pn.prd_nm AS Product_Name,
	pn.cat_id AS Category_ID,
	pc.cat AS Category,
	pc.subcat AS Sub_Category,
	pc.maintenance AS Maintenance,
	pn.prd_cost AS Product_Cost,
	pn.prd_line AS Product_Line,
	pn.prd_start_dt AS Product_Start_Date
FROM Silver.crm_prd_info AS pn
LEFT JOIN Silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;   -- Filter out all historical data 

GO

IF OBJECT_ID('Gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW Gold.fact_sales;
GO

CREATE VIEW Gold.fact_sales AS 
SELECT
	sd.sls_ord_num AS Order_Number,
	pr.Product_Key,
	cu.Customer_Key,
	sd.sls_order_dt AS Order_Date,
	sd.sls_ship_dt AS Ship_Date,
	sd.sls_due_dt AS Due_Date,
	sd.sls_sales AS Sales_Amount,
	sd.sls_quantity AS Sales_Quantity,
	sd.sls_price AS Sales_Price
FROM Silver.crm_sales_details AS sd
LEFT JOIN Gold.dim_products AS pr
ON sd.sls_prd_key = pr.Product_Number
LEFT JOIN Gold.dim_customers AS cu
ON sd.sls_cust_id = cu.Customer_ID;