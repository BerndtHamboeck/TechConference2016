--pk -> unique clustered (b-tree)
--nonclustered (b-tree)
--nonclustered columnstore (using where)
create table dbo.T1(
	c1 int identity(1,1),
	c2 nvarchar(20),
	c3 int
	constraint PK_T1_C1 PRIMARY KEY CLUSTERED (c1));
go

create nonclustered index [NCI_T1_C2_C3] on dbo.T1
(
	c3 ASC,
	c2 ASC
)
go

--add a nonclustered columnstore index
create nonclustered columnstore index NCI_T1
	on dbo.T1(c1,c2,c3)
	where c3 = 5 --YES, we can use a where clause here
go

--insert
insert into dbo.T1
	values ('Berndt',3), ('Lara',4), ('Lina',5);
go

--update
update dbo.T1 set c3 = 5
where c3 < 5;
go

--delete
delete from dbo.T1
where C3 = 5;

--cleanup
drop table t1;
go

--table1:
--  clustered columnstore
--  unique nonclustered (b-tree)
--table2:
--  clustered columnstore
--  foreign key

create table dbo.T1(
	c1 int identity(1,1),
	c2 varchar(20),
	constraint UQ_T1_C1 unique nonclustered (c1),
	index CCI_T1 clustered columnstore );

create table dbo.T2(
	id int,
	c1_t1 int not null,
	constraint FK_T2_T1_c1 
		foreign key (c1_t1) 
			references dbo.T1(c1) );


insert into dbo.T1 (c2)
	values ('Berndt'), ('Lara'), ('Lina');

insert into dbo.T2 (id, c1_t1)
	values (1, 1 );


select *
from dbo.T1 join 
     dbo.T2 on T1.c1 = T2.c1_t1;


create clustered columnstore index CCI_T2
	on dbo.T2;

--check fk
insert into dbo.T2 (id, c1_t1)
	values (9, 9 );



drop table t2;
drop table t1;