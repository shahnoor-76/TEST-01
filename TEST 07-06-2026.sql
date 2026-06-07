-----
----- TEST

--Q1. List top 5 customers by total order amount.
--Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.

SELECT TOP 5
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(sod.TotalAmount) AS TotalSpent
FROM dbo.Customer c
JOIN dbo.SalesOrder so
    ON c.CustomerID = so.CustomerID
JOIN dbo.SalesOrderDetail sod
    ON so.OrderID = sod.OrderID
GROUP BY
    c.CustomerID,
    c.Name
ORDER BY
    TotalSpent DESC;

----Q2. Find the number of products supplied by each supplier.
---Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.

SELECT 
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(DISTINCT pod.ProductID) AS ProductCount
FROM dbo.Supplier s
INNER JOIN dbo.PurchaseOrder po
    ON s.SupplierID = po.SupplierID
INNER JOIN dbo.PurchaseOrderDetail pod
    ON po.OrderID = pod.OrderID
GROUP BY 
    s.SupplierID,
    s.Name
HAVING 
    COUNT(DISTINCT pod.ProductID) > 10;
    
    
    ----Q3. Identify products that have been ordered but never returned.
----Show ProductID, ProductName, and total order quantity.

SELECT 
    p.ProductID,
    p.Name,
    SUM(sod.Quantity) AS TotalOrderQuantity
FROM Product p
INNER JOIN SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
LEFT JOIN ReturnDetail rd
    ON p.ProductID = rd.ProductID
WHERE rd.ProductID IS NULL
GROUP BY 
    p.ProductID,
    p.Name;

----Q4. For each category, find the most expensive product.
----Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.
SELECT 
    p.CategoryID,
    p.Price
FROM Product p
INNER JOIN Category c
    ON p.CategoryID = c.CategoryID
WHERE p.Price = (
    SELECT MAX(p2.Price)
    FROM Product p2
    WHERE p2.CategoryID = p.CategoryID
);

----Q5. List all sales orders with customer name, product name, category, and supplier.
---For each sales order, display:
----OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.

SELECT 
    so.OrderID,
    cu.CustomerID,
    p.ProductID,
    c.CategoryID,
    s.SupplierID,
    sod.Quantity
FROM SalesOrder so
INNER JOIN Customer cu
    ON so.CustomerID = cu.CustomerID
INNER JOIN SalesOrderDetail sod
    ON so.OrderID = sod.OrderID
INNER JOIN Product p
    ON sod.ProductID = p.ProductID
INNER JOIN Category c
    ON p.CategoryID = c.CategoryID
INNER JOIN Supplier s
    ON p.ProductID = s.SupplierID;

-----Q6. Find all shipments with details of warehouse, manager, and products shipped.
----Display:
----ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.


----Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.

WITH OrderTotals AS (
    SELECT 
        so.CustomerID,
        so.OrderID,
        SUM(sod.Quantity * sod.UnitPrice) AS TotalAmount,
        RANK() OVER (
            PARTITION BY so.CustomerID 
            ORDER BY SUM(sod.Quantity * sod.UnitPrice) DESC
        ) AS rnk
    FROM SalesOrder so
    INNER JOIN Customer cu
        ON so.CustomerID = cu.CustomerID
    INNER JOIN SalesOrderDetail sod
        ON so.OrderID = sod.OrderID
    GROUP BY 
        so.CustomerID,
        
        so.OrderID
)
SELECT 
    CustomerID,
    OrderID,
    TotalAmount
FROM OrderTotals
WHERE rnk <= 3;
-----Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.
SELECT 
    p.ProductID,
    p.Name,
    sod.OrderID,
    so.OrderDate,
    sod.Quantity,
    LAG(sod.Quantity) OVER (
        PARTITION BY p.ProductID 
        ORDER BY so.OrderDate
    ) AS PrevQuantity,
    LEAD(sod.Quantity) OVER (
        PARTITION BY p.ProductID 
        ORDER BY so.OrderDate
    ) AS NextQuantity
FROM SalesOrderDetail sod
INNER JOIN SalesOrder so
    ON sod.OrderID = so.OrderID
INNER JOIN Product p
    ON sod.ProductID = p.ProductID;

-----Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
-----CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.

-----Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount for all products supplied by that supplier.
