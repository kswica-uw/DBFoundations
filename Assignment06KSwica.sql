--*************************************************************************--
-- Title: Assignment06
-- Author: KSwica
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,KSwica,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KSwica')
	 Begin 
	  Alter Database [Assignment06DB_KSwica] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KSwica;
	 End
	Create Database Assignment06DB_KSwica;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KSwica;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

--PLEASE NOTE: Working code was used from the Assignment 5 submission. Steps to demonstrate how the code was developed were omitted here for simplicity. 

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

GO 
CREATE VIEW vCategories 
    WITH SCHEMABINDING
    AS SELECT
        CategoryID
        ,CategoryName
    FROM dbo.Categories;
GO 

CREATE VIEW vProducts
    WITH SCHEMABINDING
    AS SELECT
        ProductID
        ,ProductName
        ,CategoryID
        ,UnitPrice
    FROM dbo.Products;
GO 

CREATE VIEW vEmployees
    WITH SCHEMABINDING
    AS SELECT
        EmployeeID
        , EmployeeFirstName
        , EmployeeLastName
        , ManagerID
    FROM dbo.Employees; 
GO 

CREATE VIEW vInventories
    WITH SCHEMABINDING
    AS SELECT
        InventoryID
        ,InventoryDate
        ,EmployeeID
        ,ProductID
        ,[Count]
    FROM dbo.Inventories;
GO 


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY Select On Categories to Public;
GRANT Select on vCategories to Public; 

DENY Select On Products to Public; 
Grant Select On vProducts to Public; 

Deny Select On Employees to Public; 
Grant Select On vEmployees to Public;

Deny Select on Inventories to Public; 
Grant Select On vInventories to Public; 

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

GO
CREATE VIEW vProductsByCategories 
    AS 
        SELECT TOP 1000000000 CategoryName, ProductName, UnitPrice 
            FROM Categories as c JOIN Products as p
             ON c.CategoryID=p.CategoryID
        ORDER BY 1,2; 
GO 


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33
GO 
CREATE VIEW vInventoriesByProductsByDates 
    AS 
        SELECT TOP 1000000000 ProductName, InventoryDate, [Count]
            FROM Products AS p JOIN Inventories AS i 
                ON p.ProductID=i.ProductID
        ORDER BY 1,2,3;
GO 

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

GO 
CREATE VIEW vInventoriesByEmployeesByDates
    AS 
        SELECT DISTINCT TOP 1000000000 
            i.InventoryDate,
            e.EmployeeFirstName + ' ' + e.EmployeeLastName as [EmployeeName]
        FROM Inventories AS i JOIN Employees as e
            ON i.EmployeeID=e.EmployeeID
        ORDER BY 1; 
GO 


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37
GO 
CREATE VIEW vInventoriesByProductsByCategories
    AS 
        SELECT TOP 1000000000 c.CategoryName,p.ProductName,i.InventoryDate,i.[Count]
            FROM Products as p 
                LEFT JOIN Categories as c 
                    ON p.categoryid=c.categoryid
                LEFT JOIN Inventories as i 
                    ON p.productid=i.productid
            ORDER BY c.CategoryName,p.ProductName,i.InventoryDate,i.[Count];
GO 

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C�te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran� Fant�stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik��ri	      2017-01-01	  57	  Steven Buchanan

GO 
CREATE VIEW vInventoriesByProductsByEmployees
    AS 
        SELECT TOP 1000000000
        c.CategoryName,
        p.ProductName,
        i.InventoryDate,
        i.[Count],
        e.EmployeeFirstName + ' '+ e.EmployeeLastName AS [EmployeeName]
        FROM Products AS p 
            JOIN Categories AS c 
                ON p.CategoryID=c.CategoryID
            JOIN Inventories AS i 
                ON i.ProductID=p.ProductID
            JOIN Employees AS e 
                ON e.EmployeeID=i.EmployeeID
        ORDER BY 3,1,2,4;
GO 

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

GO 
CREATE VIEW vInventoriesForChaiAndChangByEmployees 
    AS 
        SELECT
            c.CategoryName,
            p.ProductName,
            i.InventoryDate,
            i.[Count],
            e.EmployeeFirstName + ' '+ e.EmployeeLastName AS [EmployeeName]
        FROM Products AS p 
            JOIN Categories AS c 
                ON p.CategoryID=c.CategoryID
            JOIN Inventories AS i 
                ON i.ProductID=p.ProductID
            JOIN Employees AS e 
                ON e.EmployeeID=i.EmployeeID
            WHERE p.ProductName = 'Chai' OR p.ProductName= 'Chang';
GO 


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King
GO 
CREATE VIEW vEmployeesByManager
    AS 
        SELECT TOP 1000000000
            m.EmployeeFirstName+' '+m.EmployeeLastName AS [Manager],
            e.EmployeeFirstName+' '+e.EmployeeLastName AS [Employee]
        FROM Employees as e 
            JOIN Employees as m 
                ON m.EmployeeID=e.ManagerID
        ORDER BY [Manager],[Employee];  
GO 


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth
GO 
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees 
    AS 
        SELECT TOP 100000000
            c.CategoryID,
            c.CategoryName,
            p.ProductID,
            p.ProductName,
            p.UnitPrice,
            i.InventoryID,
            i.InventoryDate,
            i.[Count],
            e.EmployeeID,
            e.EmployeeFirstName+' '+e.EmployeeLastName AS [Employee],
            m.EmployeeFirstName+' '+m.EmployeeLastName AS [Manager]
            FROM vCategories AS c 
                JOIN vProducts AS p
                    ON c.CategoryID=p.CategoryID
                JOIN vInventories AS i 
                    ON i.ProductID=p.ProductID
                JOIN vEmployees AS e 
                    ON e.EmployeeID=i.EmployeeID
                JOIN vEmployees as m 
                    ON m.EmployeeID=e.ManagerID
            ORDER BY c.CategoryName, p.ProductName, i.InventoryID, [Employee]; 
GO 
    

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/
