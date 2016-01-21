USE [AdventureWorks2016CTP3]
GO

--new memory only table
--would not work in master ;)
create table t1Mem
(
	ID int identity(1,1) primary key 
	        nonclustered hash with(bucket_count=30000),
	Col01 money not null,
	Col02 nvarchar(100) null,
	Col03 bit not null default(1)
)
with (memory_optimized = on, durability=schema_only)
;
go

--have a quick look here:
--"c:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA" 
--compiler is here:
--"c:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Binn\Xtp"

--load in some data so we have a memory footprint.
insert into t1Mem
(Col01,Col02)
values
(125.00,N'Welcome at TechConference Vienna 2016!');
go 10000

--let's add a column
alter table t1Mem
	add StatusID tinyint null;
go

--set some data
update t1Mem
	set StatusID = 5;
go

--make it non-nullable
alter table t1mem
	alter column StatusID tinyint not null;
go


--we want to query for reporting 
--columnstore speeds this up
--BUT needs to be persisted
create table t2Mem
(
	ID int identity(1,1) primary key 
	     nonclustered hash with(bucket_count=1000),
	Col01 money not null,
	Col02 nvarchar(100) not null,
	Col03 bit not null default(1),
	index ix_cci_t2Mem clustered columnstore
)
with (memory_optimized = on, durability=schema_only)
;
go


--íf we want to put a Columnstore index on it, 
--then data needs to be persisted,
--means Schema and table for durability.
create table t2Mem
(
	ID int identity(1,1) primary key 
	     nonclustered hash with(bucket_count=1000),
	Col01 money not null,
	Col02 nvarchar(100) not null,
	Col03 bit not null default(1),
	index ix_cci_t2Mem clustered columnstore
)
with (memory_optimized = on, durability=schema_and_data)
;
go



--again, after creation, have a quick look here:
--"c:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA" 
create procedure memInsert_t1mem
	with
		native_compilation,
		schemabinding
as
begin atomic
	with
	(
		transaction isolation level = snapshot,
		language = N'us_english'
	)

	insert into dbo.t1Mem
	(Col01,Col02,StatusID)
	values
	(250.00,N'....absolutely fantastic conference...',3)
	;
end
go

--go,go,goooooooooo
exec memInsert_t1mem

select count(*)
from t1mem

--let's alter the procedure to add more data at once
alter procedure memInsert_t1mem(@rowsToInsert int = 10000)
	with
		native_compilation,
		schemabinding
as
begin atomic
	with
	(
		transaction isolation level = snapshot,
		language = N'us_english'
	)
	declare @counter int = 1;

	while(@counter <= @rowsToInsert)
	begin
		insert into dbo.t1mem
		(Col01,Col02,StatusID)
		values
		(250.00,N'...hurry up, more demos are waiting!!',3)
		;

		set @counter = @counter+1;
	end

	--// What do we have in the table
	select Col01, Col02, Col03, StatusID
	from dbo.t1Mem
	;

end
go

--moooooore data
exec memInsert_t1mem 100000;

select count(*)
from t1mem

--look for native objects
SELECT name, description FROM sys.dm_os_loaded_modules
where description = 'XTP Native DLL'

--cleanup 
drop procedure memInsert_t1mem
drop table t1Mem
drop table t2Mem