use TSQLV6;

drop table if exists dbo.Employees;

create table dbo.Employees
(
	empid INT not null,
	firstname varchar(30) not null,
	lastname varchar(30) not null,
	hiredate date not null,
	mgrid int null,
	ssn varchar(20) not null,
	salary money not null
);

alter table dbo.Employees
	add constraint PK_Employees
	primary key(empid);

alter table dbo.Employees
	add constraint UNQ_Employees_ssn
	unique(ssn);

create unique index idx_ssn_notnull on dbo.Employees(ssn) where ssn is not null;

drop table if exists dbo.Orders;

create table dbo.Orders
(
	orderid int not null,
	empid int not null,
	custid varchar(10) not null,
	orderts datetime2 not null,
	qty int not null,
	constraint PK_Orders primary key(orderid)
);

alter table dbo.Orders
	add constraint FK_Orders_Employees
	foreign key(empid)
	references dbo.Employees(empid);

alter table dbo.Employees
	add constraint FK_Employees_Employees
	foreign key(mgrid)
	references dbo.Employees(empid);

alter table dbo.Employees
	add constraint CHK_Employees_salary
	check(salary > 0.00);

alter table dbo.Orders
	add constraint DFT_Orders_orderts
	default(sysdatetime()) for orderts;

drop table if exists dbo.Orders, dbo.Employees