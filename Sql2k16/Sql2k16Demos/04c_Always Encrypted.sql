create database [AlwaysEncrypted]
go


--setup the master key and column encryption key.
--do this from the UI in SSMS, RMB on the security node of the database.
--names used: SqlServer2k16ColumnMasterKey, Sql2k16ColumnEncryptionKey
--connect object explorer -> options>> -> additional conn. parameter:
--column encryption setting=enabled

use AlwaysEncrypted
go

--create table for our data.
create table dbo.EncryptedEmployee
(
	BusinessEntityID int identity(1,1) NOT NULL,
	NationalIDNumber nvarchar(15) collate latin1_general_bin2
		encrypted with
		(
			column_encryption_key = Sql2k16ColumnEncryptionKey,
			encryption_type = deterministic,
			algorithm = 'AEAD_AES_256_CBC_HMAC_SHA_256'
		) NOT NULL,
	LoginID nvarchar(256) collate latin1_general_bin2
		encrypted with
		(
			column_encryption_key = Sql2k16ColumnEncryptionKey,
			encryption_type = randomized,
			algorithm = 'AEAD_AES_256_CBC_HMAC_SHA_256'
		) NOT NULL,
	JobTitle nvarchar(50) NOT NULL,
	BirthDate date NOT NULL,
)
;
go

--let's look at the empty table.
select * from dbo.EncryptedEmployee

--so can we enter data into it via T-SQL statements?
insert into dbo.EncryptedEmployee
(BusinessEntityID, NationalIDNumber, LoginID, JobTitle, BirthDate)
select BusinessEntityID, NationalIDNumber collate latin1_general_bin2, 
       LoginID collate latin1_general_bin2, JobTitle, BirthDate
from AdventureWorks2016CTP3.HumanResources.Employee
;
--answer: Narrp!

--let's try it from C#
--first, lets get the prep done. some procedures for our app to call.


--insert data.
create procedure dbo.insertEncryptedEmployee
(
	@NationalIdNumber nvarchar(15),
	@LoginId nvarchar(256),
	@JobTitle nvarchar(50),
	@BirthDate date
)
as
begin

	insert into dbo.EncryptedEmployee
	(NationalIDNumber, LoginID, JobTitle, BirthDate)
	values
	(@NationalIdNumber, @LoginId, @JobTitle,@BirthDate)
	;

end
go

--// Select Data
create procedure dbo.selectData
as
begin
	
	Select BusinessEntityID, NationalIDNumber, LoginID, JobTitle, BirthDate
	from dbo.EncryptedEmployee
	;

end
--Now we go to the app.

--// What does this look like to the DBA?
exec selectData

drop procedure dbo.insertEncryptedEmployee
drop table dbo.EncryptedEmployee
drop database [AlwaysEncrypted]