DROP DATABASE IF EXISTS atlbeltline;

CREATE DATABASE IF NOT EXISTS atlbeltline CHARACTER SET utf8 COLLATE utf8_general_ci;
USE atlbeltline;



CREATE TABLE IF NOT EXISTS Users (
	UserName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	-- there is no domain constraint on UserName

	Password varchar(100) NOT NULL,
	-- Password required to be hashed before storage, so I actually store a hash code

	Status ENUM('DENIED', 'APPROVED', 'PENDING') DEFAULT 'PENDING' NOT NULL,
	-- Status of a user can only be one of these three

	FirstName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--

	LastName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--

	IsVisitor ENUM('NO', 'YES') DEFAULT 'NO' NOT NULL,
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

	EmployeeID char(9) UNIQUE,
	--

	Phone char(10) NOT NULL UNIQUE,
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
		'OTHER') DEFAULT 'GA' NOT NULL,
	--

	Zipcode char(5) NOT NULL,
	--

	Title ENUM('ADMINISTRATOR', 'MANAGER', 'STAFF') DEFAULT 'STAFF' NOT NULL,
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

	TransportType ENUM('MARTA', 'BUS', 'BIKE') NOT NULL,
	--

	Price float(5,2) NOT NULL,
	--

	CONSTRAINT PK_Transit PRIMARY KEY (Route, TransportType)
	--

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS Site (
	SiteName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--

	Zipcode char(5) NOT NULL,
	--

	Address varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci,
	--

	EveryDay ENUM('NO', 'YES') NOT NULL,
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

	Price float(5,2) NOT NULL DEFAULT 000.00,
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

	TransportType ENUM('MARTA', 'BUS', 'BIKE') NOT NULL,
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

	TransportType ENUM('MARTA', 'BUS', 'BIKE') NOT NULL,
	--

	`Date` date NOT NULL,
	--

	CONSTRAINT FK7_Take1 FOREIGN KEY (UserName) REFERENCES Users(UserName)
	ON DELETE CASCADE ON UPDATE CASCADE,
	--

	CONSTRAINT FK8_Take2 FOREIGN KEY (Route, TransportType) REFERENCES Transit(Route, TransportType)
	ON DELETE CASCADE ON UPDATE CASCADE,
	--

	CONSTRAINT PK_Take PRIMARY KEY (UserName, Route, TransportType, `Date`)
	--

) ENGINE INNODB CHARACTER SET utf8 COLLATE utf8_general_ci;



CREATE TABLE IF NOT EXISTS VisitSite (
	UserName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--

	SiteName varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	--

	`Date` date NOT NULL,
	--

	CONSTRAINT FK8_VS1 FOREIGN KEY (UserName) REFERENCES Users(UserName)
	ON DELETE CASCADE ON UPDATE CASCADE,
	--

	CONSTRAINT FK9_VS2 FOREIGN KEY (SiteName) REFERENCES Site(SiteName)
	ON DELETE CASCADE ON UPDATE CASCADE,
	--

	CONSTRAINT PK_VS PRIMARY KEY (UserName, SiteName, `Date`)
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

	`Date` date NOT NULL,
	--

	CONSTRAINT FK11_VE1 FOREIGN KEY (UserName) REFERENCES Users(UserName)
	ON DELETE CASCADE ON UPDATE CASCADE,
	--

	CONSTRAINT FK12_VE2 FOREIGN KEY (SiteName, EventName, StartDate) REFERENCES Events(SiteName, EventName, StartDate)
	ON DELETE CASCADE ON UPDATE CASCADE,
	--

	CONSTRAINT PK_SE PRIMARY KEY (UserName, SiteName, EventName, StartDate, `Date`)
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


USE atlbeltline;
-- SET @@byDeletingSite := "no";
DELIMITER $$

CREATE TRIGGER tgr1_email1 BEFORE INSERT ON Email FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF NEW.EmailAddress NOT RLIKE '[0-9A-Za-z]+@[0-9A-Za-z]+\.[0-9A-Za-z]+' THEN
		SET ermsg = 'Invalid Email Address!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

END $$



CREATE TRIGGER tgr2_email2 BEFORE UPDATE ON Email FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF NEW.EmailAddress NOT RLIKE '[0-9A-Za-z]+@[0-9A-Za-z]+\.[0-9A-Za-z]+' THEN
		SET ermsg = 'Invalid Email Address!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

END $$



CREATE TRIGGER tgr3_email3 BEFORE DELETE ON Email FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF (SELECT count(*) FROM Email WHERE UserName LIKE OLD.UserName) = 1 THEN
		SET ermsg = 'The Only Email Of This User, Connot Delete!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

END $$



CREATE TRIGGER tgr4_site1 AFTER INSERT ON Site FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	DECLARE holder varchar(50);

	SET holder = (SELECT title FROM employee WHERE UserName LIKE NEW.ManagerName LIMIT 1);
	IF holder NOT LIKE 'Manager' THEN
		SET ermsg = 'Invalid Manager Assignment!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;
END $$



CREATE TRIGGER tgr5_site2 AFTER UPDATE ON Site FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	DECLARE holder varchar(20);

	SET holder = (SELECT title FROM employee WHERE UserName LIKE NEW.ManagerName LIMIT 1);
	IF holder NOT LIKE 'Manager' THEN
		SET ermsg = 'Invalid Manager Assignment!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;
END $$



CREATE TRIGGER tgr6_site3 BEFORE DELETE ON Site FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
    DECLARE rout varchar(20);
    DECLARE tt varchar(20);

    -- SET @@byDeletingSite := "yes";

    -- WHILE (SELECT Num FROM
    --     (SELECT count(*) AS Num FROM Connects WHERE SiteName LIKE OLD.SiteName) AS x
    --     LIMIT 1 > 0) DO
    --     SELECT Route, TransportType FROM Connects WHERE SiteName LIKE OLD.SiteName LIMIT 1 INTO rout, tt;
    --     DELETE FROM Transit WHERE Route LIKE rout AND TransportType LIKE tt;
    -- END WHILE;

    -- SET @@byDeletingSite := "no";

	IF (SELECT count(*) FROM
             (SELECT Num, SiteName FROM
                 (SELECT count(*) AS Num, SiteName FROM Connects JOIN Transit USING (TransportType, Route) GROUP BY (TransportType, Route)) AS x
              WHERE Num = 1 AND SiteName LIKE OLD.SiteName) AS y
         LIMIT 1 ) > 0 THEN
	 	SET ermsg = 'The Only Site Of Some Transit, Connot Delete!!';
	 	SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	 END IF;

END $$



CREATE TRIGGER tgr7_event1 BEFORE INSERT ON Events FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	SET ermsg = "Invalid Event, Having Time Overlapping!!";

	IF NEW.EndDate < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Invalid Date, Ending Is Earlier Than Beginning!!";
	END IF;

	IF NEW.EndDate >= ANY (SELECT StartDate FROM Events WHERE SiteName LIKE NEW.SiteNAme
							AND EventName LIKE NEW.EventName
							AND StartDate > NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

	IF NEW.StartDate <= ANY (SELECT EndDate FROM Events WHERE SiteName LIKE NEW.SiteNAme
							AND EventName LIKE NEW.EventName
							AND StartDate < NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

	IF NEW.MinStaffReq < 1 THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Minimun Number of Required Staffs Cannot Be Less Than One!!";
	END IF;

	IF NEW.Price < 0 Then
		SIGNAL SQLSTATE '45000' SET message_text = "Price Cannot Be Negative!!";
	END IF;

	IF NEW.Capacity < 1 THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Capacity Cannot Be Less Than One!!";
	END IF;
END $$



CREATE TRIGGER tgr8_event2 BEFORE UPDATE ON Events FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	SET ermsg = "Invalid Event, Having Time Overlapping!!";

	IF NEW.EndDate < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Invalid Date, Ending Is Earlier Than Beginning!!";
	END IF;

	IF NEW.EndDate >= ANY (SELECT StartDate FROM Events WHERE SiteName LIKE NEW.SiteNAme
							AND EventName LIKE NEW.EventName
							AND StartDate > NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

	IF NEW.StartDate <= ANY (SELECT EndDate FROM Events WHERE SiteName LIKE NEW.SiteNAme
							AND EventName LIKE NEW.EventName
							AND StartDate < NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

	IF NEW.MinStaffReq < 1 THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Minimun Number of Required Staffs Cannot Be Less Than One!!";
	END IF;

	IF NEW.Price < 0 Then
		SIGNAL SQLSTATE '45000' SET message_text = "Price Cannot Be Negative!!";
	END IF;

	IF NEW.Capacity < 1 THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Capacity Cannot Be Less Than One!!";
	END IF;
END $$



CREATE TRIGGER tgr9_vs1 AFTER INSERT ON VisitSite FOR EACH ROW
BEGIN
	IF (SELECT IsVisitor FROM Users WHERE UserName LIKE NEW.UserName LIMIT 1) LIKE "No" THEN
		SIGNAL SQLSTATE '45000' SET message_text = "The User Is Not A Visitor!!";
	END IF;
END $$



CREATE TRIGGER tgr10_vs2 AFTER UPDATE ON VisitSite FOR EACH ROW
BEGIN
	IF (SELECT IsVisitor FROM Users WHERE UserName LIKE NEW.UserName LIMIT 1) LIKE "No" THEN
		SIGNAL SQLSTATE '45000' SET message_text = "The User Is Not A Visitor!!";
	END IF;
END $$



CREATE TRIGGER tgr11_ve1 BEFORE INSERT ON VisitEvent FOR EACH ROW
BEGIN
	IF NEW.Date < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Visiting Before Start Date!!!";
	END IF;

	IF NEW.Date > (SELECT EndDate FROM Events WHERE SiteName LIKE NEW.SiteName
						AND EventName LIKE NEW.EventName
						AND StartDate = NEW.StartDate LIMIT 1) THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Visiting After End Date!!!";
	END IF;

    IF EXISTS (SELECT * FROM VisitSite WHERE UserName LIKE NEW.UserName AND SiteName LIKE NEW.SiteName AND 'Date' = NEW.Date)  THEN
	   INSERT INTO VisitSite VALUES (NEW.UserName, NEW.SiteName, NEW.Date);
    END IF;
END $$



CREATE TRIGGER tgr12_ve2 BEFORE UPDATE ON VisitEvent FOR EACH ROW
BEGIN
	IF NEW.Date < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Visiting Before Start Date!!!";
	END IF;

	IF NEW.Date > (SELECT EndDate FROM Events WHERE SiteName LIKE NEW.SiteName
						AND EventName LIKE NEW.EventName
						AND StartDate = NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Visiting After End Date!!!";
	END IF;

	DELETE FROM VisitSite WHERE UserName LIKE OLD.UserName AND SiteName LIKE OLD.SiteName AND Date = OLD.Date;

    IF EXISTS (SELECT * FROM VisitSite WHERE UserName LIKE NEW.UserName AND SiteName LIKE NEW.SiteName AND 'Date' = NEW.Date) THEN
	   INSERT INTO VisitSite VALUES (NEW.UserName, NEW.SiteName, NEW.Date);
    END IF;
END $$



CREATE TRIGGER tgr13_at1 AFTER INSERT ON AssignTo FOR EACH ROW
BEGIN
	DECLARE hold varchar(50);

	SET hold = (SELECT Title FROM EMPLOYEE WHERE UserName LIKE NEW.StaffName LIMIT 1);

	IF hold NOT LIKE 'Staff' THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Not A Staff, Cannot Assign To Event!!";
	END IF;

	IF (SELECT EndDate FROM Events WHERE SiteName LIKE NEW.SiteName
					AND EventName LIKE NEW.EventName
					AND StartDate = NEW.StartDate LIMIT 1)
	>= ANY (SELECT StartDate FROM Events
			JOIN AssignTo USING (SiteName, EventName, StartDate)
			WHERE StaffName LIKE NEW.StaffName AND StartDate > NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Time Conflict, Cannot Assign To Event!! Type1";
	END IF;

	IF NEW.StartDate <= ANY (SELECT EndDate FROM Events
			JOIN AssignTo USING (SiteName, EventName, StartDate)
			WHERE StaffName LIKE NEW.StaffName AND StartDate < NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Time Conflict, Cannot Assign To Event!! Type2";
	END IF;
END $$




CREATE TRIGGER tgr14_at2 AFTER UPDATE ON AssignTo FOR EACH ROW
BEGIN
	DECLARE hold varchar(50);

	SET hold = (SELECT Title FROM EMPLOYEE WHERE UserName LIKE NEW.StaffName LIMIT 1);

	IF hold NOT LIKE 'Staff' THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Not A Staff, Cannot Assign To Event!!";
	END IF;

	IF (SELECT EndDate FROM Events WHERE SiteName LIKE NEW.SiteName
					AND EventName LIKE NEW.EventName
					AND StartDate = NEW.StartDate LIMIT 1)
	<= ANY (SELECT StartDate FROM Events
			JOIN AssignTo USING (SiteName, EventName, StartDate)
			WHERE StaffName LIKE NEW.StaffName AND StartDate > NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Time Conflict, Cannot Assign To Event!!";
	END IF;

	IF NEW.StartDate <= ANY (SELECT EndDate FROM Events
			JOIN AssignTo USING (SiteName, EventName, StartDate)
			WHERE StaffName LIKE NEW.StaffName AND StartDate < NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Time Conflict, Cannot Assign To Event!!";
	END IF;
END $$



CREATE TRIGGER tgr15_at3 BEFORE DELETE ON AssignTo FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF (SELECT count(*) FROM AssignTo WHERE SiteNeme = OLD.SiteName
					AND EventName = OLD.EventName
                    AND StartDate = OLD.StartDate) =
                    (SELECT MinStaffReq FROM EVENTS WHERE SiteNeme = OLD.SiteName
                					AND EventName = OLD.EventName
                                    AND StartDate = OLD.StartDate) THEN
		SET ermsg = 'Staff Number Of This Site Will Be Less Than The Minimun Required Staff Number, Connot Delete!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

END $$



CREATE TRIGGER tgr16_connect1 BEFORE DELETE ON Connects FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF (SELECT count(*) FROM Connects WHERE Route = OLD.Route
					AND TransportType = OLD.TransportType) = 1 THEN
        -- IF @@byDeletingSite LIKE 'no' THEN
		    SET ermsg = 'The Only Site Of This Transit, Connot Delete!!';
		    SIGNAL SQLSTATE '45000' SET message_text = ermsg;
        -- END IF;
	END IF;
END $$



CREATE TRIGGER tgr17_transit1 BEFORE INSERT ON Transit FOR EACH ROW
BEGIN
    DECLARE ermsg varchar(100);
	IF NEW.Route NOT RLIKE '[0-9]+' THEN
        IF NEW.Route NOT RLIKE '[a-zA-z]+' THEN
		    SET ermsg = 'Invalid Route of The Transit!!';
		    SIGNAL SQLSTATE '45000' SET message_text = ermsg;
        END IF;
	END IF;

	IF NEW.Price < 0 THEN
		SET ermsg = 'Price Cannot Be Negative!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;
END $$



CREATE TRIGGER tgr18_transit2 BEFORE UPDATE ON Transit FOR EACH ROW
BEGIN
    DECLARE ermsg varchar(100);
	IF NEW.Route NOT RLIKE '[0-9]+' THEN
        IF NEW.Route NOT RLIKE '[a-zA-z]+' THEN
		    SET ermsg = 'Invalid Route of The Transit!!';
		    SIGNAL SQLSTATE '45000' SET message_text = ermsg;
        END IF;
	END IF;

	IF NEW.Price < 0 THEN
		SET ermsg = 'Price Cannot Be Negative!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;
END $$



-- CREATE TRIGGER tgr19_employee1 BEFORE DELETE ON Employee FOR EACH ROW
-- BEGIN
--     IF OLD.Title = 'Staff' THEN
--         IF SELECT count(*) FROM
--             (SELECT Num, StaffName FROM
--                 (SELECT count(*) AS Num, StaffName FROM AssignTo GROUP BY (SiteName, EventName, StartDate)) AS x
--                 WHERE Num = 1 AND StaffName = OLD.StaffName) AS y
--                 > 0 THEN
--             SIGNAL SQLSTATE '45000' SET message_text = 'The Only Staff For Some Event, Cannot Delete!!';
--         END IF;
--     END IF;
-- END $$



CREATE TRIGGER tgr19_employee1 BEFORE UPDATE ON Employee FOR EACH ROW
BEGIN
    IF OLD.Title != NEW.Title THEN
        SIGNAL SQLSTATE '45000' SET message_text = 'Cannot Change The Title Of The Employee!!';
    END IF;
END $$

DELIMITER ;


USE atlbeltline;

SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER $$
CREATE FUNCTION get_type(em_title int, is_visitor int) RETURNS varchar(20)
BEGIN
    IF em_title = 1 THEN
            RETURN "Administrator";
    ELSE 
        IF em_title = 2 THEN 
            RETURN "Manager";
        ELSE
            IF em_title = 3 THEN 
                RETURN "Staff";
            ELSE
                IF is_visitor = 1 THEN 
                    RETURN "Visitor";
                ELSE 
                    RETURN "User";
                END IF;
            END IF;
        END IF;
    END IF;
    
END $$

DELIMITER ;

CREATE VIEW for_users AS 
SELECT Users.UserName, Status, Users.FirstName, Users.LastName, count(*) AS NumEmailCount, get_type(Employee.Title, Users.IsVisitor) AS Type
FROM Users LEFT JOIN Email USING(UserName) LEFT JOIN Employee ON Users.UserName = Employee.UserName 
GROUP BY Users.UserName;

CREATE VIEW site_visit_num AS 
SELECT UserName, FirstName, LastName, count(*) AS NumMySiteVisit, IsVisitor 
FROM Users LEFT JOIN VisitSite USING(UserName) 
GROUP BY UserName HAVING IsVisitor = "Yes";

CREATE VIEW event_visit_num AS 
SELECT UserName, FirstName, LastName, count(*) AS NumMyEventVisit, IsVisitor 
FROM VisitEvent LEFT JOIN Users USING(UserName) 
GROUP BY UserName HAVING IsVisitor = "Yes";

CREATE VIEW for_visitor AS 
SELECT UserName, FirstName, LastName, NumMySiteVisit, NumMyEventVisit 
FROM site_visit_num LEFT JOIN event_visit_num USING(UserName, FirstName, LastName);

CREATE VIEW for_staff AS 
SELECT UserName, EmployeeID, count(*) AS NumEventShifts, Title 
FROM Employee LEFT JOIN AssignTo ON Employee.UserName = AssignTo.StaffName 
GROUP BY UserName HAVING Title = "Staff";

CREATE VIEW tansit_logged_num AS 
SELECT Route, TransportType, count(*) AS NumLogged 
FROM Transit LEFT JOIN Take USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW transit_connect_num AS 
SELECT Route, TransportType, count(*) AS NumConnected, Price 
FROM Transit LEFT JOIN Connects USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW for_transit AS 
SELECT Route, TransportType, Price, NumLogged, NumConnected 
FROM tansit_logged_num LEFT JOIN transit_connect_num USING(Route, TransportType);

CREATE VIEW event_staff_num AS 
SELECT SiteName, EventName, StartDate, count(*) AS StaffCount 
FROM Events LEFT JOIN AssignTo USING(SiteName, EventName, StartDate) 
GROUP BY SiteName, EventName, StartDate;

CREATE VIEW daily_visit_event AS 
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, count(*) AS DailyVisit 
FROM Events LEFT JOIN VisitEvent USING(SiteName, EventName, StartDate) WHERE `Date` != null 
GROUP BY SiteName, EventName, StartDate, `Date`;

CREATE VIEW daily_event AS
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, DailyVisit, (DailyVisit * Price) AS DailyRevenue 
FROM daily_visit_event;

CREATE VIEW for_event AS 
SELECT SiteName, EventName, StartDate, Events.Price, count(DailyVisit) AS TotalVisit, count(DailyRevenue) AS TotalRevenue, (Capacity - count(DailyRevenue)) AS TicketRem, (Events.EndDate - StartDate) AS Duration 
FROM daily_event LEFT JOIN Events USING(SiteName, EventName, StartDate) WHERE `Date` != null 
GROUP BY `Date`;

CREATE VIEW daily_site AS 
SELECT SiteName, `Date`, count(DailyVisit) AS DailyVisit, count(DailyRevenue) AS DailyRevenue
FROM daily_event LEFT JOIN Site USING(SiteName) WHERE `Date` != null 
GROUP BY SiteName, `Date`;

CREATE VIEW staff_site AS 
SELECT DISTINCT SiteName, StaffName 
FROM AssignTo;

CREATE VIEW count_site_staff AS
SELECT SiteName, count(*) AS CountStaff 
FROM staff_site 
GROUP BY SiteName;

CREATE VIEW total_site AS 
SELECT SiteName, count(DailyVisit) AS TotalVisit, count(DailyRevenue) AS TotalRevenue 
FROM daily_site 
GROUP BY SiteName;

CREATE VIEW for_site AS
SELECT SiteName, TotalVisit, TotalRevenue, CountStaff, count(*) AS CountEvent, ManagerName 
FROM total_site LEFT JOIN count_site_staff USING(SiteName) JOIN Events USING(SiteName) JOIN Site USING(SiteName) 
GROUP BY SiteName;

CREATE VIEW visit_one_event AS
SELECT UserName, EventName, SiteName, Price, TicketRem, TotalVisit, count(*) AS MyVisit
FROM for_event FULL JOIN VisitEvent USING(SiteName, EventName, StartDate)
GROUP BY UserName, EventName, SiteName, StartDate;

CREATE VIEW visit_one_site AS
SELECT UserName, SiteName, CountEvent, TotalVisit, count(*) AS MyVisit 
FROM for_site FULL JOIN VisitSite USING(SiteName) 
GROUP BY UserName, SiteName;

CREATE VIEW visit_hisotry_pre AS
(SELECT `Date`, SiteName, UserName FROM VisitSite) UNION (SELECT `Date`, SiteName, UserName FROM VisitEvent);

CREATE VIEW visit_history AS
SELECT `Date`, EventName, SiteName, Price, UserName
FROM VisitEvent FULL JOIN visit_hisotry_pre USING(`Date`, SiteName, UserName) LEFT JOIN EVENTS USING(SiteName, EventName, StartDate);

USE atlbeltline;

DELIMITER $$


CREATE PROCEDURE handle1(out error varchar(300))
BEGIN
    GET DIAGNOSTICS CONDITION 1
         @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
     SET error = '11';
     -- SELECT @p2;
END $$

CREATE PROCEDURE handle2(out error varchar(300))
BEGIN
    GET DIAGNOSTICS CONDITION 1
         @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
     SET error = @p2;
END $$


CREATE PROCEDURE login(in email_address varchar(100), out result varchar(100), out error varchar(300))
-- order of parameter
-- email address, password
BEGIN
    DECLARE username varchar(50);
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
	
	SET username = (SELECT UserName FROM Email WHERE EmailAddress LIKE email_address LIMIT 1);
	IF (SELECT username IS NULL) THEN 
		SET error = "Email address does not exist.";
	ELSE
        SET result = (SELECT Password FROM Users WHERE UserName LIKE username LIMIT 1);
	END IF;
END $$
-- Correct way to call it

-- SET @a = "/*email address*/";
-- SET @b = "/*password after hashing*/";
-- CALL login(@a, @b);

-- Or

-- CALL login("/*email address*/", "/*password after hashing*/");

-- Then it will return the information about login
-- For the following procedures, if there is no need for further explanation,
-- there will not be a documentation.



CREATE PROCEDURE register_user(in user_name varchar(50), in pass_word varchar(100), in first_name varchar(50), in last_name varchar(50), in is_visitor int, out error varchar(300)) 
-- order of parameter
-- username, password, firstname, lastname, is_visitor
-- is_visitor's value shall be 0 or 1 (0 for "Yes", 1 for "No")
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF EXISTS(SELECT * FROM USERS WHERE UserName = user_name) THEN 
        SET error = "Username already exists.";
    ELSE
        IF is_visitor != 1 AND is_visitor != 0 THEN
            SET error = "IsVisitor is out of range.";
        ELSE 
            SET is_visitor = is_visitor + 1;
            INSERT INTO Users(UserName, Password, FirstName, LastName, IsVisitor) 
                VALUES(user_name, pass_word, first_name, last_name, is_visitor);
        END IF;
    END IF;
END $$



CREATE PROCEDURE register_employee(in user_name varchar(50), in phone_ char(10), in address_ varchar(100),  in city_ varchar(100),  in state_ varchar(5), in zip_code char(5), in title_ varchar(20), out error varchar(300)) 
-- order of parameter
-- username, phone, city, address, state, zipcode, employee type
-- state's value shall be the abbreviation of states in uppercase or be 'other'
-- this procedure require a register_user() to be called before it
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);    
    IF title_ = "ADMINISTRATOR" THEN 
        SET error = "Cannot create administrator.";
    ELSE 
        INSERT INTO Employee(Username, Phone, Address, City, State, ZipCode, Title) VALUES(user_name, phone_, address_, city_, state_, zip_code, title_);
    END IF;
END $$


CREATE PROCEDURE register_employee_aft(in user_name varchar(50), in employee_id varchar(9), in phone_ char(10), in address_ varchar(100), in city_ varchar(100),  in state_ varchar(5), in zip_code char(5), in title_ varchar(20), out error varchar(300)) 
-- order of parameter
-- username, employee id, phone, address, city, state, zipcode, employee type
-- state's value shall be the abbreviation of states in uppercase or be 'other'
-- this procedure require a register_user() to be called before it
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF title_ = "ADMINISTRATOR" THEN 
        SET error = "Cannot create administrator.";
    ELSE 
        INSERT INTO Employee(Username, Phone, Address, City, State, ZipCode, Title, EmployeeID) VALUES(user_name, phone_, address_, city_, state_, zip_code, title_, employee_id);
    END IF;
    
END $$



CREATE PROCEDURE add_email(in user_name varchar(50), in email_address varchar(100), out error varchar(300))
-- order of parameter
-- username, emailaddress
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    INSERT INTO Email VALUES(email_address, user_name);
END $$


CREATE PROCEDURE delete_email(in email_address varchar(100), out error varchar(300))
-- order of parameter
-- emailaddress
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    DELETE FROM Email WHERE EmailAddress LIKE email_address;
END $$



CREATE PROCEDURE take_tansit(in user_name varchar(50), in route_ varchar(20), in transport_type varchar(10), in take_date date, out error varchar(300))
-- order of parameter
-- username, route, transport type, date
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    INSERT INTO Take VALUES(user_name, route_, transport_type, take_date);
END $$


CREATE PROCEDURE edit_profile(in user_name varchar(50), in first_name varchar(50), in last_name varchar(50), in is_visitor int(1), in phone_ char(10), out error varchar(300))
-- order of parameter
-- username, first name, last name, is visitor, phone
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    SET is_visitor = is_visitor + 1;
    UPDATE Users 
    SET FirstName = first_name, LastName = last_name, IsVisitor = is_visitor 
    WHERE UserName LIKE user_name;
    UPDATE Employee
    SET Phone = phone_ 
    WHERE UserName LIKE user_name;
END $$


CREATE PROCEDURE manage_user(in user_name varchar(50), in new_status varchar(10), out error varchar(300))
-- order of parameters
-- username, new status
BEGIN
    DECLARE status_ varchar(10);
    DECLARE em_id int(9);
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    SET status_ = new_status;
    IF ("APPROVED" IN (SELECT `Status` FROM Users WHERE UserName = user_name)) AND (new_status = "DENIED") THEN 
        SET error = "Cannot deny an approved user.";
    ELSE
        UPDATE Users SET Status = status_ WHERE UserName = user_name;
        IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) AND (SELECT EmployeeID FROM Employee WHERE UserName = user_name = null) AND status_ = "APPROVED" THEN                
            SET em_id = 000000001;
            WHILE EXISTS(SELECT * FROM Employee WHERE EmployeeID = em_id) DO
                SET em_id = em_id + 1;
            END WHILE;
            UPDATE Employee SET EmployeeID = em_id WHERE UserName = user_name;
        END IF;
    END IF;
END $$


CREATE PROCEDURE edit_site(in site_name varchar(50), in zip_code varchar(5), in address_ varchar(100), in manager_name varchar(50), in open_every_day int(1), out error varchar(300))
-- order of parameter
-- site name, zipcode, address, manager name, if open everyday
-- open_every_day's value shall be 0 or 1 (1 for yes, 0 for no)
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    SET open_every_day = open_every_day + 1;
    UPDATE Site 
    SET Zipcode = zip_code, Address = address_, ManagerName = manager_name, EveryDay = open_every_day 
    WHERE SiteName = site_name;
END $$


CREATE PROCEDURE create_site(in site_name varchar(50), in zip_code varchar(5), in address_ varchar(100), in manager_name varchar(50), in open_every_day int(1), out error varchar(300))
-- order of parameter
-- site name, zipcode, address, manager name, if open everyday
-- open_every_day's value shall be 0 or 1 (1 for yes, 0 for no)
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    SET open_every_day = open_every_day + 1;    
    INSERT INTO Site VALUES(site_name, zip_code, address_, open_every_day, manager_name);
END $$


CREATE PROCEDURE edit_transit(in transport_type varchar(10), in old_route varchar(20), in new_route varchar(20), in price_ float, out error varchar(300))
-- order of parameter
-- transport type, old route, new route , price
-- if the route has no change, new_route and old_route shall have the same value
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    UPDATE Transit 
    SET Route = new_route, Price = price_ 
    WHERE TransportType = transport_type AND Route = old_route;
END $$


CREATE PROCEDURE create_transit(in transport_type varchar(10), in route_ varchar(20), in price_ float, out error varchar(300))
-- order of parameter
-- transport type, route, price
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    INSERT INTO Transit VALUES(route_, transport_type, price_);
END $$


CREATE PROCEDURE connect_site(in transport_type varchar(10), in route_ varchar(20), in site_name varchar(50), out error varchar(300))
-- order of parameter
-- transport type, route, site_name
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF ! EXISTS(SELECT * FROM Connects WHERE TransportType = transport_type AND Route = route_ AND SiteName = site_name) THEN 
        INSERT INTO Connects VALUES(route_, transport_type, site_name);
    END IF;
END $$


CREATE PROCEDURE disconnect_site(in transport_type varchar(10), in route_ varchar(20), in site_name varchar(50), out error varchar(300))
-- order of parameter
-- transport type, route, site_name
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF EXISTS(SELECT * FROM Connects WHERE TransportType = transport_type AND Route = route_ AND SiteName = site_name) THEN 
        DELETE FROM Connects WHERE TransportType = transport_type AND Route = route_ AND SiteName = site_name;
    END IF;
END $$


CREATE PROCEDURE edit_evetn(in site_name varchar(50), in event_name varchar(50), in start_date date, in description_ text, out error varchar(300))
-- order of parameter
-- site name, event name, start date, new discription
BEGIN 
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    UPDATE `Events` 
    SET Description = description_ 
    WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date;
END $$


CREATE PROCEDURE create_event(in site_name varchar(50), in event_name varchar(50), in start_date date, in end_date date, in min_staff_req int, in price_ float, in capacity_ int, in description_ text, out error varchar(300))
-- order of parameter
-- site name, event name, start date, end date, minimun staff requirment, price, capacity, discription
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    INSERT INTO Events VALUES(site_name, event_name, start_date, end_date, min_staff_req, price_, capacity_, description_);
END $$


CREATE PROCEDURE assign_staff(in site_name varchar(50), in event_name varchar(50), in start_date date, in staff_name varchar(50), out error varchar(300))
-- order of parameter
-- site name, event name, start date, staff name
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF ! EXISTS(SELECT * FROM AssignTo WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND StaffName = staff_name) THEN 
        INSERT INTO AssignTo VALUES(staff_name, site_name, event_name, start_date);
    END IF;
END $$


CREATE PROCEDURE remove_staff(in site_name varchar(50), in event_name varchar(50), in start_date date, in staff_name varchar(50), out error varchar(300))
-- order of parameter
-- site name, event name, start date, staff name
BEGIN 
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF EXISTS(SELECT * FROM AssignTo WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND StaffName = staff_name) THEN 
        DELETE FROM AssignTo WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND StaffName = staff_name;
    END IF;
END $$


CREATE PROCEDURE log_event(in site_name varchar(50), in event_name varchar(50), in start_date date, in user_name varchar(50), in log_date date, out error varchar(300))
-- order of parameter
-- site name, event name, start date, user name, visit date
BEGIN 
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    INSERT INTO VisitEvent VALUES(user_name, site_name, event_name, start_date, log_date);
END $$


CREATE PROCEDURE log_site(in site_name varchar(50), in user_name varchar(50), in log_date date, out error varchar(300))
-- order of parameter
-- site name, user name, visit date
BEGIN 
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    INSERT INTO VisitSite VALUES(user_name, site_name, log_date);
END $$


CREATE PROCEDURE query_user_by_email(in email_address varchar(100), out user_name varchar(100), out pass_word varchar(100), out status_ varchar(20), out first_name varchar(100), out last_name varchar(100), out is_visitor int(1), out is_employee int(1), out error varchar(300))
-- order of parameter
-- email address
-- user name, password, status, first name, last name, is visitor, is employee
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF EXISTS(SELECT * FROM Email WHERE EmailAddress = email_address) THEN 
        SET user_name = (SELECT UserName FROM Email WHERE EmailAddress = email_address LIMIT 1);
        SELECT `Password`, `Status`, FirstName, LastName, IsVisitor INTO pass_word, status_, first_name, last_name, is_visitor FROM Users WHERE UserName = user_name LIMIT 1 ;
        SET is_visitor = is_visitor - 1;
        IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) THEN
            SET is_employee = 1;
        ELSE 
            SET is_employee = 0;
        END IF;
    ELSE 
        SET error = "Email Address does not exist.";
    END IF;
END $$


CREATE PROCEDURE query_user_by_username(in user_name varchar(100), out pass_word varchar(100), out status_ varchar(20), out first_name varchar(100), out last_name varchar(100), out is_visitor int(1), out is_employee int(1), out error varchar(300))
-- order of parameter
-- user name
-- password, status, first name, last name, is visitor, is employee
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    SELECT `Password`, `Status`, FirstName, LastName, IsVisitor INTO pass_word, status_, first_name, last_name, is_visitor FROM Users WHERE UserName = user_name LIMIT 1 ;
    IF is_visitor = 2 THEN 
        SET is_visitor = 0;
    END IF;
    IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) THEN
        SET is_employee = 1;
    ELSE 
        SET is_employee = 0;
    END IF;
END $$


CREATE PROCEDURE query_employee_by_username(in user_name varchar(100), out employee_id varchar(9), out phone_ varchar(10), out address_ varchar(100), out city_ varchar(100), out state_ varchar(100), out zip_code varchar(10), out title_ varchar(10), out error varchar(300))
-- order of parameter
-- user name
-- employee id, phone, address, city, state, zip code, title
BEGIN 
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) THEN
        SELECT EmployeeID, Phone, Address, City, State, ZipCode, Title 
        INTO employee_id, phone_, address_, city_, state_, zip_code, title_ 
        FROM Employee WHERE UserName = user_name;
    ELSE 
        SET error = "This user is not an employee.";
    END IF;
END $$


CREATE PROCEDURE query_employee_by_email(in email_address varchar(100), out user_name varchar(100), out employee_id varchar(9), out phone_ varchar(10), out address_ varchar(100), out city_ varchar(100), out state_ varchar(100), out zip_code varchar(10), out title_ varchar(10), out error varchar(300))
-- order of parameter
-- email address
-- user name, employee id, phone, address, city, state, zip code, title
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    SELECT UserName INTO user_name FROM Email WHERE EmailAddress = email_address;
    CALL query_employee_by_user(user_name, employee_id, phone_, address_, city_, state_, zip_code, title_, error);
END $$


CREATE PROCEDURE delete_user(in user_name varchar(100), out error varchar(300))
-- order of parameter
-- user name
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    DELETE FROM Users WHERE UserName = user_name;
END $$


CREATE PROCEDURE check_email(in email_address varchar(100), out result int(1), out error varchar(300))
-- order of parameter
-- email address, result
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF (SELECT UserName FROM Email WHERE EmailAddress = email_address LIMIT 1) THEN 
        SET result = 0;
    ELSE
        SET result = 1;
    END IF;
END $$


CREATE PROCEDURE check_username(in user_name varchar(100), out result int(1), out error varchar(300))
-- order of parameter
-- user name, result
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF (SELECT UserName FROM Users WHERE UserName = user_address LIMIT 1) THEN 
        SET result = 0;
    ELSE
        SET result = 1;
    END IF;
END $$


CREATE PROCEDURE check_status(in user_name varchar(100), out result int(1), out error varchar(300))
-- order of parameter
-- user name, result
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF (SELECT `Status` FROM Users WHERE UserName = user_address LIMIT 1) = "APPROVED" THEN 
        SET result = 1;
    ELSE
        SET result = 0;
    END IF;
END $$




DELIMITER ;

DROP USER IF EXISTS 'alterbeltline'@'%';
CREATE USER 'alterbeltline'@'%' IDENTIFIED BY 'cs4400team5';
GRANT ALL PRIVILEGES ON altbeltline.* TO 'alterbeltline'@'%';