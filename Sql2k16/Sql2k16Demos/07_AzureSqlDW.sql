--count the january data
SELECT count(*)
FROM dbo.FactResellerSales
Where OrderDateKey >= '20020101' and OrderDateKey < '20020201'

--count the february data
SELECT count(*)
FROM dbo.FactResellerSales
Where OrderDateKey >= '20020201' and OrderDateKey < '20020301'

--count the march data
SELECT count(*)
FROM dbo.FactResellerSales
Where OrderDateKey >= '20020301' and OrderDateKey < '20020401'


CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<password123P>';

-- STEP 2: Create a database scoped credential to authenticate against your Azure storage account.
-- Replace the <storage_account_key> with your Azure storage account key (primary access key). 
-- To find the key, open your storage account on Azure Portal (https://portal.azure.com/).
CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential 
WITH IDENTITY = '<identity>', 
SECRET = '<key>';

select * from sys.database_credentials;

-- STEP 3: Create an external data source to specify location and credential for your Azure storage account.
-- Replace the <container_name> with your Azure storage blob container.
-- Replace the <storage_account_name> with your Azure storage account name.
CREATE EXTERNAL DATA SOURCE AzureStorage 
WITH (	
		TYPE = Hadoop, 
		LOCATION = 'wasbs://<storage_account_name>@<container_name>.blob.core.windows.net',
		CREDENTIAL = AzureStorageCredential
); 

select * from sys.external_data_sources;

-- Step 4: Create an external file format to specify the layout of data stored in Azure blob storage. 
-- The data is in a pipe-delimited text file.
CREATE EXTERNAL FILE FORMAT TextFile 
WITH (
		FORMAT_TYPE = DelimitedText, 
		FORMAT_OPTIONS (FIELD_TERMINATOR = '|')
);

select * from sys.external_file_formats;



--export data
Create EXTERNAL TABLE Weblogs200201 WITH
(
    LOCATION = 'reseller2002/01',
    DATA_SOURCE=AzureStorage,
    FILE_FORMAT=TextFile
)
AS
SELECT *
FROM
    dbo.FactResellerSales
Where OrderDateKey >= '20020101' and OrderDateKey < '20020201'
go

Create EXTERNAL TABLE Weblogs200202 WITH
(
    LOCATION = 'reseller2002/02',
    DATA_SOURCE=AzureStorage,
    FILE_FORMAT=TextFile
)
AS
SELECT *
FROM
    dbo.FactResellerSales
Where OrderDateKey >= '20020201' and OrderDateKey < '20020301'
go


Create EXTERNAL TABLE Weblogs200203 WITH
(
    LOCATION = 'reseller2002/03',
    DATA_SOURCE=AzureStorage,
    FILE_FORMAT=TextFile
)
AS
SELECT *
FROM
    dbo.FactResellerSales
Where OrderDateKey >= '20020301' and OrderDateKey < '20020401'

Select Count(*) from Weblogs200201
Select Count(*) from Weblogs200202
Select * from Weblogs200203


CREATE EXTERNAL TABLE dbo.Weblogs (
	[ProductKey] [int] NOT NULL,
	[OrderDateKey] [int] NOT NULL,
	[DueDateKey] [int] NOT NULL,
	[ShipDateKey] [int] NOT NULL,
	[ResellerKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[PromotionKey] [int] NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[SalesTerritoryKey] [int] NOT NULL,
	[SalesOrderNumber] [nvarchar](20) NOT NULL,
	[SalesOrderLineNumber] [tinyint] NOT NULL,
	[RevisionNumber] [tinyint] NULL,
	[OrderQuantity] [smallint] NULL,
	[UnitPrice] [money] NULL,
	[ExtendedAmount] [money] NULL,
	[UnitPriceDiscountPct] [float] NULL,
	[DiscountAmount] [float] NULL,
	[ProductStandardCost] [money] NULL,
	[TotalProductCost] [money] NULL,
	[SalesAmount] [money] NULL,
	[TaxAmt] [money] NULL,
	[Freight] [money] NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[CustomerPONumber] [nvarchar](25) NULL
)
WITH (
		LOCATION='reseller2002', 
		DATA_SOURCE=AzureStorage, 
		FILE_FORMAT=TextFile
);

Select Count(*) from Weblogs
Select * from Weblogs


--------------Scale on the fly....................................
--you can't be in the same db when rescaling
--use master (new script)

ALTER DATABASE  AdventureWorksDWAzure 
MODIFY (SERVICE_OBJECTIVE = 'DW1000')


-----------------Cleanup....................................
drop EXTERNAL TABLE Weblogs200201;
go
drop EXTERNAL TABLE Weblogs200202;
go
drop EXTERNAL TABLE Weblogs200203;
go
drop EXTERNAL TABLE Weblogs;

drop EXTERNAL DATA SOURCE AzureStorage;
go
drop DATABASE SCOPED CREDENTIAL AzureStorageCredential;
go
drop EXTERNAL FILE FORMAT TextFile
go
drop master key
go

