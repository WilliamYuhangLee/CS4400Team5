CREATE DATABASE IF NOT EXISTS CS4400 CHARACTER SET utf8 COLLATE utf8_general_ci;
USE CS4400;



CREATE TABLE IF NOT EXISTS Users (
	UserName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- there is no domain constraint on UserName

	Password int NOT NULL,
	-- Password required to be hashed before storage, so I actually store a hash code

	Status ENUM('Pending', 'Denied', 'Approval') DEFAULT 'Pending' NOT NULL,
	-- Status of a user can only be one of these three

	FirstName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	LastName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 
	
	IsVisitor ENUM('Yes', 'No') DEFAULT 'No' NOT NULL,
	-- This labeled if a user also a visitor
	
	CONSTRAINT PK_User PRIMARY KEY (UserName)
	-- 

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS Email (
	EmailAddress varchar(100) NOT NULL,
	-- 
	
	UserName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	CONSTRAINT FK1_Email1 FOREIGN KEY (UserName) REFERENCES Users(UserName) 
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 

	CONSTRAINT PK_Email PRIMARY KEY (EmailAddress)
	-- 

) ENGINE INNODB  CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS Employee (
	UserName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	EmployeeID int(9) NOT NULL UNIQUE,
	-- 

	Phone int(9) NOT NULL UNIQUE,
	-- 

	Address varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	City varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	State ENUM('AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
		'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
		'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
		'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC',
		'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY',
		'Other') NOT NULL DEFAULT 'GA',
	-- 

	Zipcode int(5) NOT NULL,
	-- 
	
	Title ENUM('Administrator', 'Manager', 'Staff') DEFAULT 'Staff' NOT NULL,
	--
	
	CONSTRAINT FK2_Employee1 FOREIGN KEY (UserName) REFERENCES Users(UserName) 
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 

	CONSTRAINT PK_Employee PRIMARY KEY (UserName)
	-- 

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS Transit (
	Route varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	TransportType ENUM('Marta', 'Bus', 'Bike') NOT NULL,
	-- 

	Price float(3,2) NOT NULL,
	-- 

	CONSTRAINT PK_Transit PRIMARY KEY (Route, TransportType)
	-- 

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS Site (
	SiteName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--

	Zipcode int(5) NOT NULL,
	--

	Address varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--
	
	EveryDay enum('Yes', 'No') NOT NULL,
	--
	
	ManagerName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL UNIQUE,
	--

	CONSTRAINT PK_Site PRIMARY KEY (SiteName),
	--

	CONSTRAINT FK4_Site1_Manage FOREIGN KEY (ManagerName) REFERENCES Employee(UserName) 
	ON DELETE RESTRICT ON UPDATE CASCADE
	--

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS Events (
	SiteName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--

	EventName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--
	
	StartDate date NOT NULL,
	--
	
	EndDate date NOT NULL,
	--
	
	MinStaffReq int NOT NULL DEFAULT 1,
	--
	
	Price float(3,2) NOT NULL DEFAULT 000.00,
	--
	
	Capacity int NOT NULL DEFAULT 10,
	--

	Description text CHARACTER SET utf8 COLLATE utf8_general_ci,
	--	
	
	CONSTRAINT FK4_Event1_Host FOREIGN KEY (SiteName) REFERENCES Site(SiteName)
	ON DELETE CASCADE ON UPDATE CASCADE,
	--

	CONSTRAINT PK_Event PRIMARY KEY (SiteName, EventName, StartDate)
	--

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS Connects (	
	Route varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	TransportType ENUM('Marta', 'Bus', 'Bike') NOT NULL,
	-- 

	SiteName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 
	CONSTRAINT FK_Connect_A_18 FOREIGN KEY (SiteName) REFERENCES Site(SiteName)
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 

	CONSTRAINT FK6_Connect2 FOREIGN KEY (Route, TransportType) REFERENCES Transit(Route, TransportType)
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 
	
	CONSTRAINT PK_AT PRIMARY KEY (SiteName, Route, TransportType)
	-- 

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS Take (
	UserName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	Route varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	TransportType ENUM('Marta', 'Bus', 'Bike') NOT NULL,
	-- 

	Date date NOT NULL,
	-- 

	CONSTRAINT FK7_Take1 FOREIGN KEY (UserName) REFERENCES Users(UserName)	
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 

	CONSTRAINT FK8_Take2 FOREIGN KEY (Route, TransportType) REFERENCES Transit(Route, TransportType)
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 
	
	CONSTRAINT PK_Take PRIMARY KEY (UserName, Route, TransportType, Date)
	-- 

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS VisitSite (
	UserName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	SiteName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	Date date NOT NULL,
	-- 
	
	CONSTRAINT FK8_VS1 FOREIGN KEY (UserName) REFERENCES Users(UserName)	
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 

	CONSTRAINT FK9_VS2 FOREIGN KEY (SiteName) REFERENCES Site(SiteName)	
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 

	CONSTRAINT PK_VS PRIMARY KEY (UserName, SiteName, Date)
	-- 

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS VisitEvent (
	UserName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	SiteName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 

	EventName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- 
	
	StartDate date NOT NULL,
	-- 

	Date date NOT NULL,
	-- 

	CONSTRAINT FK11_VE1 FOREIGN KEY (UserName) REFERENCES Users(UserName)
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 
	
	CONSTRAINT FK12_VE2 FOREIGN KEY (SiteName, EventName, StartDate) REFERENCES Events(SiteName, EventName, StartDate)
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 

	CONSTRAINT PK_SE PRIMARY KEY (UserName, SiteName, EventName, StartDate, Date)
	-- 

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS AssignTo (
	StaffName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--

	SiteName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--

	EventName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--
	
	StartDate date NOT NULL,
	-- 
	
	CONSTRAINT FK13_AT1 FOREIGN KEY (StaffName) REFERENCES Employee(UserName)
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 
	
	CONSTRAINT FK14_AT2 FOREIGN KEY (SiteName, EventName, StartDate) REFERENCES Events(SiteName, EventName, StartDate)
	ON DELETE CASCADE ON UPDATE CASCADE,
	-- 

	CONSTRAINT PK_AT PRIMARY KEY (StaffName, SiteName, EventName, StartDate)
	-- 

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;
