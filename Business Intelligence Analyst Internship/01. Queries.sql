-- Query 1
-- cek keunikan ID untuk menjadi Primary Key
SELECT CustomerID 
FROM `muamalat-final-project.datasets.Customers` 
GROUP BY CustomerID
HAVING count(CustomerID) > 1;

SELECT OrderID 
FROM `muamalat-final-project.datasets.Orders` 
GROUP BY OrderID
HAVING count(OrderID) > 1;

SELECT ProdNumber
FROM `muamalat-final-project.datasets.Products` 
GROUP BY ProdNumber
HAVING count(ProdNumber) > 1;

SELECT CategoryID
FROM `muamalat-final-project.datasets.ProductCategory` 
GROUP BY CategoryID
HAVING count(CategoryID) > 1;

-- Query 2
-- rename field Category di tabel Products menjadi CategoryID
CREATE TABLE `muamalat-final-project.datasets.products_temp` AS
SELECT
  ProdNumber,
  ProdName,
  Category AS CategoryID,
  Price
FROM
  `muamalat-final-project.datasets.Products`
-- drop tabel original
DROP TABLE `muamalat-final-project.datasets.Products`;
-- rename tabel baru
ALTER TABLE `muamalat-final-project.datasets.products_temp` RENAME TO Products;


-- Query 3
CREATE TABLE `muamalat-final-project.datasets.MasterTable` AS
SELECT 
  o.Date AS OrderDate,
  pc.CategoryName AS ProductCategoryName,
  p.ProdName AS ProductName,
  p.Price AS ProductPrice,
  o.Quantity AS OrderQty,
  p.Price * o.Quantity AS TotalSales,
  c.CustomerEmail,
  c.CustomerCity
FROM `muamalat-final-project.datasets.Orders` AS o
JOIN `muamalat-final-project.datasets.Products` AS p ON o.ProdNumber = p.ProdNumber
JOIN `muamalat-final-project.datasets.ProductCategory` AS pc ON p.CategoryID = pc.CategoryID
JOIN `muamalat-final-project.datasets.Customers` AS c ON o.CustomerID = c.CustomerID
ORDER BY
  OrderDate,
  ProductCategoryName;