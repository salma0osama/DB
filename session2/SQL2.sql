create database Co
use Co

create table Department (
	Dnum tinyint identity (1,1) primary key,
	Dname varchar(255),
	Location varchar(255),
	ManagerID int,
	--foreign key (ManagerID) references Employee (SSN) on delete cascade ,
);

create table Employee (
	SSN INT IDENTITY(1,1) primary key,
	Fname nvarchar(255),	
	Lname nvarchar(255),
	Gender char(1),
	BirthDate date,
	SuperID int,
	Dnum tinyint,
	foreign key (SuperID) references Employee (SSN) ,
	foreign key (Dnum) references Department (Dnum),
);

create table Project (
	Pnum tinyint identity (1,1) primary key,
	pname varchar(255),
	City varchar(255),
	Dnum tinyint,
	ESSN int,
	foreign key (Dnum) references Department (Dnum) ,
	foreign key (ESSN) references Employee (SSN) ,
);
create table Dependent (
	Name nvarchar(255) primary key,
	Gender varchar(10),
	ESSN int ,
	foreign key (ESSN) references Employee (SSN)
);
create table ManagerHireDate(
	ESSN int,
    Dnum tinyint,
    HiringDate date,
    primary key (ESSN, Dnum),
    foreign key (ESSN) references Employee (SSN) ,
    foreign key (Dnum) references Department (Dnum)
);
create table EmployeeWorkingHours(
	ESSN int,
    Pnum tinyint,
    WorkingHours decimal(4,2),
    primary key (ESSN, Pnum),
    foreign key (ESSN) references Employee(SSN),
    foreign key (Pnum) references Project(Pnum)
);

alter table Department add foreign key (ManagerID) references Employee(SSN);


select * from Employee
select * from Department
select * from Dependent
select * from Project
select * from EmployeeWorkingHours


insert into Department (Dname , Location , ManagerID) 
values ('Marketing','Cairo',NULL),
	   ('Sales','Giza',NULL),
	   ('Engineering','Alex',NULL),
	   ('Human Resources', 'Benha', NULL);


insert into Employee (Fname , Lname ,Gender, BirthDate , SuperID , Dnum) 
values ('Salma','Osama','F','2004-07-04',NULL,2),
	   ('Sara','Ahmed','F','2002-06-11',1,2),
	   ('Ahmed','Mohammed','M','2000-09-05',1,2),
	   ('Omar','Khaled','M','1997-01-01',2,3),
	   ('Ramy','Sayed','M','2001-12-15',5,3),
	   ('Fares','Ali','M','1999-09-17',1,2);
	  
update Department set ManagerID = 1 where Dnum = 5;
update Department set ManagerID = 2 where Dnum = 2; 
update Department set ManagerID = 3 where Dnum = 3; 
update Department set ManagerID = 4 where Dnum = 4; 


insert into Project (pname, City, Dnum, ESSN) 
values ('P1', 'Cairo', 2, 1),     
	   ('P2', 'Giza', 2, 2),             
	   ('P3', 'Cairo', 2, 3),          
	   ('P4', 'Giza', 2, 6);    

insert into EmployeeWorkingHours (ESSN, Pnum, WorkingHours) 
values (1, 1, 40.00),  
	   (1, 4, 10.45),
	   (2, 3, 15.30);

update Employee set Dnum = 3 where SSN = 5;

delete from Dependent where Name = 'Fares';

select * from Employee where Dnum = 2;

select Fname , Lname , pname , Workinghours from Employee 
join Project on pnum = Pnum 
join EmployeeWorkingHours on WorkingHours = WorkingHours;

