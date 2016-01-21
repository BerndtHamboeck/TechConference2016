USE [AdventureWorks2016CTP3]
GO

--scenario: use a new table
--Table [Person].[Person_Temporal] with schema similar to [Person].[Person]
create table [Person].[Person_Temporal](
	[BusinessEntityID] [int] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [dbo].[Name] NOT NULL,
	[MiddleName] [dbo].[Name] NULL,
	[LastName] [dbo].[Name] NOT NULL,
	[EmailPromotion] [int] NOT NULL,

	CONSTRAINT [PK_Person_Temporal_BusinessEntityID] PRIMARY KEY CLUSTERED 
	(
		[BusinessEntityID] ASC
	),
	--magic starts here
	ValidFrom datetime2(7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	ValidTo datetime2(7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) 
--and ends here
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Person].[Person_Temporal_History]));
go


--	Loading data from the table	[Person].[Person]

insert into [Person].[Person_Temporal]
([BusinessEntityID]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[EmailPromotion]
)
select [BusinessEntityID]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[EmailPromotion]
from [Person].[Person] order by [BusinessEntityID];
go

--data, there, history empty
Select * from [Person].[Person_Temporal];
Select * from [Person].[Person_Temporal_History];
go

update [Person].[Person_Temporal]
set title = 'Dr.'
where BusinessEntityID in ( 1,2);
go

--find the change and the original row
Select *, ValidFrom, ValidTo from [Person].[Person_Temporal]
where BusinessEntityID in (1,2);
Select * from [Person].[Person_Temporal_History];
go

--update again
update [Person].[Person_Temporal]
set title = 'Dr. Dr.'
where BusinessEntityID = 1;
go

--find the change and the original rows
Select * from [Person].[Person_Temporal]
where BusinessEntityID in (1,2);
Select * from [Person].[Person_Temporal_History]
order by BusinessEntityID, ValidFrom Desc;
go

--delete a row
delete from [Person].[Person_Temporal]
where BusinessEntityID = 1;
go

--the latest row for 1 is there in the hist. and has a end date
Select * from [Person].[Person_Temporal]
where BusinessEntityID in (1,2);
Select * from [Person].[Person_Temporal_History]
order by BusinessEntityID, ValidFrom Desc;
go

--complete history
Select *, ValidFrom, ValidTo from [Person].[Person_Temporal]
for system_time ALL
where BusinessEntityID in (1,2)
order by ValidTo desc

--recover deleted row
BEGIN TRAN

	INSERT INTO [Person].[Person_Temporal]
	([BusinessEntityID]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[EmailPromotion]
	)
	SELECT TOP 1 [BusinessEntityID]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[EmailPromotion]
	FROM [Person].[Person_Temporal]
	FOR SYSTEM_TIME ALL
	WHERE BusinessEntityID = 1
	ORDER BY [ValidTo] DESC ;

COMMIT
go

--check that it is back
Select * from [Person].[Person_Temporal]
where BusinessEntityID in (1,2);
Select * from [Person].[Person_Temporal_History];
go


--a new column (schema change will be transparently propagated to history)
alter table [Person].[Person_Temporal]
	add YearOfBirth DATE NULL;
go

--Remove HIDDEN flag for period columns
alter table [Person].[Person_Temporal]
alter column ValidFrom DROP HIDDEN;
alter table [Person].[Person_Temporal]
alter column ValidTo DROP HIDDEN;
go

--YearOfBirth is there...
Select * from [Person].[Person_Temporal]
where BusinessEntityID in (1,2);
Select * from [Person].[Person_Temporal_History];
go

--let's get the complete history
Select * from [Person].[Person_Temporal]
for system_time ALL
--for system_time as of ''
--for system_time between '' and ''
--for system_time contained in ('','')
where BusinessEntityID in (1,2)
order by ValidTo desc;
go

--scenario: use existing table
--create another table, which is not a temporal table
select top 10 [BusinessEntityID],[TerritoryID],[SalesQuota],[Bonus],
              [CommissionPct],[SalesYTD],[SalesLastYear] 
into [Sales].[SalesPerson_Temporal]
from [Sales].[SalesPerson];
go

--temporal table must have a primary key
alter table [Sales].[SalesPerson_Temporal]
add constraint PK_SalesPerson_Temporal PRIMARY KEY CLUSTERED (BusinessEntityID);
go

--add period columns
alter table [Sales].[SalesPerson_Temporal] add
	 SysStartTime datetime2(0) GENERATED ALWAYS AS ROW START HIDDEN 
         CONSTRAINT DF_SysStart DEFAULT DATEADD(second, -1, SYSUTCDATETIME()),
	 SysEndTime datetime2(0) GENERATED ALWAYS AS ROW END HIDDEN 
         CONSTRAINT DF_SysEnd DEFAULT CONVERT(datetime2 (0), '9999-12-31 23:59:59'),
	 PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime);
go


/*Generate default history table*/
alter table [Sales].[SalesPerson_Temporal]
set (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Sales].[SalesPerson_Temporal_History]));
go

/*Query full history for newly created table*/
select *, SysStartTime, SysEndTime
from [Sales].[SalesPerson_Temporal]
for system_time ALL;



--get some information about your temporal table(s)
 SELECT T1.object_id, T1.name as TemporalTableName, SCHEMA_NAME(T1.schema_id) AS TemporalTableSchema,
 T2.name as HistoryTableName, SCHEMA_NAME(T2.schema_id) AS HistoryTableSchema,
 T1.temporal_type,
 T1.temporal_type_desc
 FROM sys.tables T1
 LEFT JOIN sys.tables T2 
 ON T1.history_table_id = T2.object_id
 WHERE T1.temporal_type <> 0
 ORDER BY T1.temporal_type desc;

--cleanup
IF EXISTS (SELECT * FROM sys.tables
WHERE [Name] = 'Person_Temporal' AND temporal_type = 2)
	ALTER TABLE [Person].[Person_Temporal] SET (SYSTEM_VERSIONING = OFF);

DROP TABLE IF EXISTS [Person].[Person_Temporal];
DROP TABLE IF EXISTS [Person].[Person_Temporal_History];


IF EXISTS (SELECT * FROM sys.tables
WHERE [Name] = 'SalesPerson_Temporal' AND temporal_type = 2)
	ALTER TABLE [Sales].[SalesPerson_Temporal] SET (SYSTEM_VERSIONING = OFF);

DROP TABLE IF EXISTS [Sales].[SalesPerson_Temporal];
DROP TABLE IF EXISTS [Sales].[SalesPerson_Temporal_History];





