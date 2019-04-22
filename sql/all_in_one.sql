DROP DATABASE IF EXISTS atlbeltline;

CREATE DATABASE IF NOT EXISTS atlbeltline CHARACTER SET utf8 COLLATE utf8_general_ci;
USE atlbeltline;

-- SET GLOBAL log_bin_trust_function_creators = 1;



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
DELIMITER $$

-- Make sure the email address is formated correctly.
CREATE TRIGGER tgr1_email1 BEFORE INSERT ON Email FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF NEW.EmailAddress NOT RLIKE '^[0-9A-Za-z]+@[0-9A-Za-z]+\.[0-9A-Za-z]+$' THEN
		SET ermsg = 'Invalid email address.';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

END $$


-- Make sure the email address is formated correctly.
CREATE TRIGGER tgr2_email2 BEFORE UPDATE ON Email FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF NEW.EmailAddress NOT RLIKE '^[0-9A-Za-z]+@[0-9A-Za-z]+\.[0-9A-Za-z]+$' THEN
		SET ermsg = 'Invalid email address.';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

END $$


-- Prohibit the deletion on email when that email is the only email of its owner.
CREATE TRIGGER tgr3_email3 BEFORE DELETE ON Email FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF (SELECT count(*) FROM Email WHERE UserName LIKE OLD.UserName) = 1 THEN
        IF @force = 'force delete' THEN
            SET @trigger_warning = 'The data has been forced deleted.';
        ELSE
            SET ermsg = 'The only email of this user, connot delete.';
            SIGNAL SQLSTATE '45000' SET message_text = ermsg;
        END IF;
	END IF;

END $$


-- Make sure the manager of a site has the title of manager.
CREATE TRIGGER tgr4_site1 BEFORE INSERT ON Site FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	DECLARE holder varchar(50);

	SET holder = (SELECT Title FROM Employee WHERE UserName LIKE NEW.ManagerName LIMIT 1);
	IF holder NOT LIKE 'Manager' THEN
		SET ermsg = 'Invalid manager assignment.';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;
END $$


-- Make sure the manager of a site has the title of manager.
CREATE TRIGGER tgr5_site2 AFTER UPDATE ON Site FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	DECLARE holder varchar(20);

	SET holder = (SELECT Title FROM Employee WHERE UserName LIKE NEW.ManagerName LIMIT 1);
	IF holder NOT LIKE 'Manager' THEN
		SET ermsg = 'Invalid manager assignment.';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;
END $$


-- Prohibit the deletion on site if that is the only site connected with some transit.
CREATE TRIGGER tgr6_site3 BEFORE DELETE ON Site FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
    DECLARE rout varchar(20);
    DECLARE tt varchar(20);

	IF (SELECT count(*) FROM
             (SELECT Num, SiteName FROM
                 (SELECT count(*) AS Num, SiteName FROM Connects JOIN Transit USING (TransportType, Route) GROUP BY TransportType, Route) AS x
              WHERE Num = 1 AND SiteName LIKE OLD.SiteName) AS y
         LIMIT 1 ) > 0  THEN
        IF @force = 'force delete' THEN
            SET @trigger_warning = 'The data has been forced deleted.';
        ELSE
            SET ermsg = 'The only site of some transit, connot delete.';
            SIGNAL SQLSTATE '45000' SET message_text = ermsg;
        END IF;
	 END IF;

END $$


-- Check if all information about the event is correct
CREATE TRIGGER tgr7_event1 BEFORE INSERT ON Events FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	SET ermsg = 'Invalid event, having time overlapping.';

	IF NEW.EndDate < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Invalid date, ending is earlier than beginning.';
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
		SIGNAL SQLSTATE '45000' SET message_text = 'Minimun number of required staffs cannot be less than one.';
	END IF;

	IF NEW.Price < 0 Then
		SIGNAL SQLSTATE '45000' SET message_text = 'Price cannot be negative.';
	END IF;

	IF NEW.Capacity < 1 THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Capacity cannot be less than one.';
	END IF;
END $$


-- Check if all information about the event is correct
CREATE TRIGGER tgr8_event2 BEFORE UPDATE ON Events FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	SET ermsg = 'Invalid event, having time overlapping.';

	IF NEW.EndDate < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Invalid date, ending is earlier than beginning.';
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
		SIGNAL SQLSTATE '45000' SET message_text = 'Minimun number of required staffs cannot be less than one.';
	END IF;

	IF NEW.Price < 0 Then
		SIGNAL SQLSTATE '45000' SET message_text = 'Price cannot be negative.';
	END IF;

	IF NEW.Capacity < 1 THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Capacity cannot be less than one.';
	END IF;
END $$


-- -- If new username not belong to a visitor, error is vocated
CREATE TRIGGER tgr9_vs1 BEFORE INSERT ON VisitSite FOR EACH ROW
BEGIN
	IF (SELECT IsVisitor FROM Users WHERE UserName LIKE NEW.UserName LIMIT 1) LIKE 'No' THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'The user is not a visitor.';
	END IF;
END $$


-- If new username not belong to a visitor, error is vocated
CREATE TRIGGER tgr10_vs2 BEFORE UPDATE ON VisitSite FOR EACH ROW
BEGIN
	IF (SELECT IsVisitor FROM Users WHERE UserName LIKE NEW.UserName LIMIT 1) LIKE 'No' THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'This user is not a visitor.';
	END IF;
END $$


-- Making sure that new visit date is between start and end date
CREATE TRIGGER tgr11_ve1 BEFORE INSERT ON VisitEvent FOR EACH ROW
BEGIN
	IF NEW.Date < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Visiting before start date.';
	END IF;

	IF NEW.Date > (SELECT EndDate FROM Events WHERE SiteName LIKE NEW.SiteName
						AND EventName LIKE NEW.EventName
						AND StartDate = NEW.StartDate LIMIT 1) THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Visiting after end date.';
	END IF;
END $$


-- Making sure that new visit date is between start and end date
-- Automatically drop row from VisitSite with the old user and old date, and add new row with new user and new date
CREATE TRIGGER tgr12_ve2 BEFORE UPDATE ON VisitEvent FOR EACH ROW
BEGIN
	IF NEW.Date < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Visiting before start date.';
	END IF;

	IF NEW.Date > (SELECT EndDate FROM Events WHERE SiteName LIKE NEW.SiteName
						AND EventName LIKE NEW.EventName
						AND StartDate = NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Visiting after end date.';
	END IF;
END $$


-- Make user the employee is a staff, and make sure there is no time conflict
CREATE TRIGGER tgr13_at1 BEFORE INSERT ON AssignTo FOR EACH ROW
BEGIN
	DECLARE hold varchar(50);
    DECLARE end_date date;

	SET hold = (SELECT Title FROM EMPLOYEE WHERE UserName LIKE NEW.StaffName LIMIT 1);

	IF hold NOT LIKE 'Staff' THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Not a staff, cannot assign to event.';
	END IF;
    
    SET end_date = (SELECT EndDate 
                    FROM `Events` 
                    WHERE SiteName = NEW.SiteName 
                    AND EventName = NEW.EventName 
                    AND StartDate = NEW.StartDate LIMIT 1);

	IF end_date >= ANY (SELECT StartDate 
                         FROM AssignTo 
                         WHERE StaffName = New.StaffName)  THEN 
        IF NEW.StartDate <= ANY (SELECT EndDate 
                                  FROM `Events`
                                  JOIN AssignTo 
                                  USING (SiteName, EventName, StartDate) 
                                  WHERE StaffName = NEW.StaffName 
                                  AND (SiteName, EventName, StartDate) IN
                                  (SELECT SiteName, EventName, StartDate FROM AssignTo WHERE StartDate <= end_date AND StaffName = NEW.StaffName)) 
        THEN
            SIGNAL SQLSTATE '45000' SET message_text = 'Time conflict, cannot assign to event.';
        END IF;
    END IF;
END $$



-- Make user the employee is a staff, and make sure there is no time conflict
CREATE TRIGGER tgr14_at2 BEFORE UPDATE ON AssignTo FOR EACH ROW
BEGIN
	DECLARE hold varchar(50);
    DECLARE end_date date;

	SET hold = (SELECT Title FROM EMPLOYEE WHERE UserName LIKE NEW.StaffName LIMIT 1);

	IF hold NOT LIKE 'Staff' THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Not a staff, cannot assign to event.';
	END IF;
    
    SET end_date = (SELECT EndDate 
                    FROM `Events` 
                    WHERE SiteName = NEW.SiteName 
                    AND EventName = NEW.EventName 
                    AND StartDate = NEW.StartDate LIMIT 1);

	IF end_date >= ANY (SELECT StartDate 
                         FROM AssignTo 
                         WHERE StaffName = New.StaffName)  THEN 
        IF NEW.StartDate <= ANY (SELECT EndDate 
                                  FROM `Events`
                                  JOIN AssignTo 
                                  USING (SiteName, EventName, StartDate) 
                                  WHERE StaffName = NEW.StaffName 
                                  AND (SiteName, EventName, StartDate) IN
                                  (SELECT SiteName, EventName, StartDate FROM AssignTo WHERE StartDate <= end_date AND StaffName = NEW.StaffName)) 
        THEN
            SIGNAL SQLSTATE '45000' SET message_text = 'Time conflict, cannot assign to event.';
        END IF;
    END IF;
END $$


-- Make sure the number of staff that serves in an event is not lower than the minimun requirement of staff
CREATE TRIGGER tgr15_at3 BEFORE DELETE ON AssignTo FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF (SELECT count(*) FROM AssignTo WHERE SiteName = OLD.SiteName
					AND EventName = OLD.EventName
                    AND StartDate = OLD.StartDate) =
                    (SELECT MinStaffReq FROM EVENTS WHERE SiteName = OLD.SiteName
                					AND EventName = OLD.EventName
                                    AND StartDate = OLD.StartDate) THEN
        IF @force = 'force delete' THEN
            SET @trigger_warning = 'The data has been forced deleted.';
        ELSE
            SET ermsg = 'Staff number of this site will be less than the minimun required staff number, connot delete.';
            SIGNAL SQLSTATE '45000' SET message_text = ermsg;
        END IF;
		
	END IF;

END $$


-- Make sure that each transit connect to at least one site
CREATE TRIGGER tgr16_connect1 BEFORE DELETE ON Connects FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF (SELECT count(*) FROM Connects WHERE Route = OLD.Route
					AND TransportType = OLD.TransportType) = 1 THEN 
        IF @force = 'force delete' THEN
            SET @trigger_warning = 'The data has been forced deleted.';
        ELSE
            SET ermsg = 'The only site of this transit, connot delete.';
		    SIGNAL SQLSTATE '45000' SET message_text = ermsg;
        END IF;
	END IF;
END $$


-- Make sure that all information about a new transit are correct
CREATE TRIGGER tgr17_transit1 BEFORE INSERT ON Transit FOR EACH ROW
BEGIN
    DECLARE ermsg varchar(100);
	IF NEW.Route NOT RLIKE '^[0-9]+$' THEN
        IF NEW.Route NOT RLIKE '^[a-zA-z]+$' THEN
		    SET ermsg = 'Invalid route of the transit.';
		    SIGNAL SQLSTATE '45000' SET message_text = ermsg;
        END IF;
	END IF;

	IF NEW.Price < 0 THEN
		SET ermsg = 'Price cannot be negative.';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;
END $$


-- Make sure that all information about a new transit are correct
CREATE TRIGGER tgr18_transit2 BEFORE UPDATE ON Transit FOR EACH ROW
BEGIN
    DECLARE ermsg varchar(100);
	IF NEW.Route NOT RLIKE '^[0-9]+$' THEN
        IF NEW.Route NOT RLIKE '^[a-zA-z]+$' THEN
		    SET ermsg = 'Invalid Route of The Transit.';
		    SIGNAL SQLSTATE '45000' SET message_text = ermsg;
        END IF;
	END IF;

	IF NEW.Price < 0 THEN
		SET ermsg = 'Price Cannot Be Negative.';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;
END $$


-- Prohibit the changing on the title of an employee.
CREATE TRIGGER tgr19_employee1 BEFORE UPDATE ON Employee FOR EACH ROW
BEGIN
    IF OLD.Title != NEW.Title THEN
        SIGNAL SQLSTATE '45000' SET message_text = 'Cannot change the title of the employee.';
    END IF;
    WHILE length(NEW.EmployeeID) < 9 DO
        SET NEW.EmployeeID = concat('0', NEW.EmployeeID);
    END WHILE;
END $$


-- Delete all records about one's visiting when a user is no longer a visitor.
CREATE TRIGGER tgr20_visitor1 BEFORE UPDATE ON Users FOR EACH ROW
BEGIN
    IF OLD.IsVisitor = 'Yes' AND NEW.IsVisitor = 'No' THEN
        DELETE FROM VisitEvent WHERE UserName = OLD.UserName;
        DELETE FROM VisitSite WHERE UserName = OLD.UserName;
    END IF;
END $$

DELIMITER ;



USE atlbeltline;

-- SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER $$
CREATE FUNCTION get_type(em_title int, is_visitor int) RETURNS varchar(20) DETERMINISTIC 
BEGIN
    IF em_title = 1 THEN
            RETURN 'Administrator';
    ELSE 
        IF em_title = 2 THEN 
            RETURN 'Manager';
        ELSE
            IF em_title = 3 THEN 
                RETURN 'Staff';
            ELSE
                IF is_visitor = 1 THEN 
                    RETURN 'Visitor';
                ELSE 
                    RETURN 'User';
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
GROUP BY UserName HAVING IsVisitor = 'Yes';

CREATE VIEW event_visit_num AS 
SELECT UserName, FirstName, LastName, count(*) AS NumMyEventVisit, IsVisitor 
FROM VisitEvent LEFT JOIN Users USING(UserName) 
GROUP BY UserName HAVING IsVisitor = 'Yes';

CREATE VIEW for_visitor AS 
SELECT UserName, FirstName, LastName, NumMySiteVisit, NumMyEventVisit 
FROM site_visit_num LEFT JOIN event_visit_num USING(UserName, FirstName, LastName);

CREATE VIEW for_staff_pre AS 
SELECT UserName, EmployeeID, count(*) AS NumEventShifts, Title 
FROM Employee LEFT JOIN AssignTo ON Employee.UserName = AssignTo.StaffName 
GROUP BY UserName HAVING Title = 'Staff';

CREATE VIEW for_staff AS
SELECT * FROM for_staff_pre JOIN AssignTO ON for_staff_pre.UserName = AssignTo.StaffName INNER JOIN Users USING (UserName) LEFT JOIN Events USING(SiteName, EventName, StartDate); 

CREATE VIEW transit_logged_num AS 
SELECT Route, TransportType, count(*) AS NumLogged 
FROM Transit LEFT JOIN Take USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW transit_connect_num AS 
SELECT Route, TransportType, count(*) AS NumConnected, Price 
FROM Transit LEFT JOIN Connects USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW for_transit AS 
SELECT Route, TransportType, Price, NumLogged, NumConnected 
FROM transit_logged_num LEFT JOIN transit_connect_num USING(Route, TransportType);

CREATE VIEW event_staff_num AS 
SELECT SiteName, EventName, StartDate, count(*) AS StaffCount 
FROM Events LEFT JOIN AssignTo USING(SiteName, EventName, StartDate) 
GROUP BY SiteName, EventName, StartDate;

CREATE VIEW daily_visit_event AS 
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, count(*) AS DailyVisit 
FROM `Events` INNER JOIN VisitEvent USING(SiteName, EventName, StartDate)
GROUP BY SiteName, EventName, StartDate, `Date`;

CREATE VIEW daily_event AS
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, DailyVisit, (DailyVisit * Price) AS DailyRevenue 
FROM daily_visit_event;

CREATE VIEW for_event_pre AS
SELECT SiteName, EventName, StartDate, count(*) AS CountStaff 
FROM AssignTo GROUP BY SiteName, EventName, StartDate;

CREATE VIEW for_event AS 
SELECT SiteName, EventName, StartDate, Events.Price, sum(DailyVisit) AS TotalVisit, sum(DailyRevenue) AS TotalRevenue, (Capacity - sum(DailyVisit)) AS TicketRem, (Events.EndDate - StartDate + 1) AS Duration, Description, CountStaff, daily_event.EndDate   
FROM daily_event INNER JOIN Events USING(SiteName, EventName, StartDate) INNER JOIN for_event_pre USING (SiteName, EventName, StartDate)
GROUP BY SiteName, EventName, StartDate;

CREATE VIEW daily_visit_site AS 
SELECT SiteName, `Date`, count(*) AS DailyVisit, 0 AS DailyRevenue 
FROM VisitSite
GROUP BY SiteName,`Date`;

CREATE  VIEW daily_site_pre AS 
(SELECT * FROM daily_visit_site)
UNION
(SELECT SiteName, `Date`, sum(DailyVisit) AS DailyVisit, sum(DailyRevenue) AS DailyRevenue
FROM daily_event GROUP BY SiteName,`Date` );

CREATE  VIEW daily_site AS 
SELECT SiteName, `Date`, sum(DailyVisit) AS DailyVisit, sum(DailyRevenue) AS DailyRevenue
FROM daily_site_pre 
GROUP BY SiteName, `Date`;

CREATE VIEW full_daily_site_pre AS
SELECT SiteName, `Date`, DailyVisit, DailyRevenue, IF(daily_site.Date >= for_event.StartDate AND daily_site.Date <= (for_event.StartDate + for_event.Duration), CountStaff, 0) AS CountStaff FROM daily_site LEFT JOIN for_event USING(SiteName);

CREATE VIEW full_daily_site AS
SELECT SiteName, `Date`, DailyVisit, DailyRevenue, sum(CountStaff) AS CountStaff, sum(IF(CountStaff = 0, 0, 1)) AS EventCount FROM full_daily_site_pre GROUP BY SiteName, `Date`;

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
SELECT SiteName, TotalVisit, TotalRevenue, CountStaff, count(*) AS CountEvent, ManagerName, EveryDay 
FROM total_site LEFT JOIN count_site_staff USING(SiteName) JOIN Events USING(SiteName) JOIN Site USING(SiteName) 
GROUP BY SiteName;

CREATE VIEW visit_one_event AS
SELECT UserName, EventName, SiteName, count(*) AS MyVisit, StartDate 
FROM for_event JOIN VisitEvent USING(SiteName, EventName, StartDate)
GROUP BY UserName, EventName, SiteName, StartDate;

CREATE VIEW visit_one_site AS
SELECT UserName, SiteName, CountEvent, TotalVisit, count(*) AS MyVisit 
FROM for_site FULL JOIN VisitSite USING(SiteName) 
GROUP BY UserName, SiteName;

CREATE VIEW visit_hisotry_pre AS
(SELECT `Date`, SiteName, UserName FROM VisitSite) UNION (SELECT `Date`, SiteName, UserName FROM VisitEvent);

CREATE VIEW visit_history AS
SELECT `Date`, EventName, SiteName, Price, UserName
FROM VisitEvent FULL JOIN visit_hisotry_pre USING(`Date`, SiteName, UserName) LEFT JOIN `EVENTS` USING(SiteName, EventName, StartDate);

CREATE VIEW for_schedule AS
SELECT EventName, SiteName, StartDate, (StartDate + Duration - 1) AS EndDate, CountStaff, StaffName, Description 
FROM AssignTo JOIN for_event USING(EventName, SiteName, StartDate);

CREATE VIEW explore_event AS 
SELECT x.SiteName AS Site, x.SiteName, x.StartDate, x.EndDate, x.TicketRem, x.Price, x.TotalVisit, x.Description, y.UserName, IF(x.SiteName = y.SiteName AND x.EventName = y.EventName AND x.StartDate = y.StartDate, y.MyVisit, 0) AS MyVisit FROM for_event AS x , visit_one_event AS y;


CREATE VIEW explore_site AS
SELECT x.UserName, x.SiteName, x.Date, y.TotalVisit, y.CountEvent, y.EveryDay, IF(x.SiteName = y.SiteName, 1, 0) AS MyVisit FROM VisitSite AS x, for_site as y;



USE atlbeltline;
DELIMITER $$


-- change if the user is or not a visitor
CREATE PROCEDURE switch_visitor(in user_name varchar(100), in new_visitor int)
-- order of parameter
-- username, new state of if the user is visitor
BEGIN
    IF new_visitor != 0 AND new_visitor != 1 THEN 
        SET @error = 'New_visitor is out of range.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
    IF EXISTS(SELECT * FROM Users WHERE UserName = user_name) THEN
        SET new_visitor = new_visitor + 1;
        UPDATE Users SET IsVisitor = new_visitor WHERE UserName = user_name;
    ELSE 
        SET @error = 'User does not exist.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE login(in email_address varchar(100))
-- order of parameter
-- email address
-- password
BEGIN
    DECLARE user_name varchar(50);
    DECLARE result varchar(100);     
	
	SET user_name = (SELECT UserName FROM Email WHERE EmailAddress LIKE email_address LIMIT 1);
	IF NOT EXISTS(SELECT UserName FROM Email WHERE EmailAddress LIKE email_address LIMIT 1) THEN 
		SET @error = 'Email address does not exist.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
	ELSE
        SET result = (SELECT Password FROM Users WHERE UserName = user_name LIMIT 1);
        SELECT result;
	END IF;
END $$


CREATE PROCEDURE register_user(in user_name varchar(50), in pass_word varchar(100), in first_name varchar(50), in last_name varchar(50), in is_visitor int ) 
-- order of parameter
-- username, password, firstname, lastname, is_visitor
-- is_visitor's value shall be 0 or 1 (0 for 'Yes', 1 for 'No')
BEGIN    
    IF EXISTS(SELECT * FROM USERS WHERE UserName = user_name) THEN 
        SET @error = 'Username already exists.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    ELSE
        IF is_visitor != 1 AND is_visitor != 0 THEN
            SET @error = 'IsVisitor is out of range.';
            SIGNAL SQLSTATE '45000' SET message_text = @error;
        ELSE 
            SET is_visitor = is_visitor + 1;
            INSERT INTO Users(UserName, Password, FirstName, LastName, IsVisitor) 
                VALUES(user_name, pass_word, first_name, last_name, is_visitor);
        END IF;
    END IF;
END $$



CREATE PROCEDURE register_employee(in user_name varchar(50), in phone_ char(10), in address_ varchar(100),  in city_ varchar(100),  in state_ varchar(5), in zip_code char(5), in title_ varchar(20) ) 
-- order of parameter
-- username, phone, city, address, state, zipcode, employee type
-- state's value shall be the abbreviation of states in uppercase or be 'other'
-- this procedure require a register_user() to be called before it
BEGIN  
    IF title_ = 'ADMINISTRATOR' THEN 
        SET @error = 'Cannot create administrator.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    ELSE 
        INSERT INTO Employee(Username, Phone, Address, City, State, ZipCode, Title) VALUES(user_name, phone_, address_, city_, state_, zip_code, title_);
    END IF;
END $$


CREATE PROCEDURE register_employee_aft(in user_name varchar(50), in employee_id varchar(9), in phone_ char(10), in address_ varchar(100), in city_ varchar(100),  in state_ varchar(5), in zip_code char(5), in title_ varchar(20) ) 
-- order of parameter
-- username, employee id, phone, address, city, state, zipcode, employee type
-- state's value shall be the abbreviation of states in uppercase or be 'other'
-- this procedure require a register_user() to be called before it
BEGIN    
     
    IF title_ = 'ADMINISTRATOR' THEN 
        SET @error = 'Cannot create administrator.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    ELSE 
        INSERT INTO Employee(Username, Phone, Address, City, State, ZipCode, Title, EmployeeID) VALUES(user_name, phone_, address_, city_, state_, zip_code, title_, employee_id);
    END IF;
END $$



CREATE PROCEDURE add_email(in user_name varchar(50), in email_address varchar(100) )
-- order of parameter
-- username, emailaddress
BEGIN  
    INSERT INTO Email VALUES(email_address, user_name);
END $$


CREATE PROCEDURE delete_email(in email_address varchar(100) )
-- order of parameter
-- emailaddress
BEGIN 
    DELETE FROM Email WHERE EmailAddress LIKE email_address;
END $$


CREATE PROCEDURE take_transit(in user_name varchar(50), in route_ varchar(20), in transport_type varchar(10), in take_date date )
-- order of parameter
-- username, route, transport type, date
BEGIN 
    INSERT INTO Take VALUES(user_name, route_, transport_type, take_date);
END $$


CREATE PROCEDURE edit_profile(in user_name varchar(50), in first_name varchar(50), in last_name varchar(50), in is_visitor int(1), in phone_ char(10) )
-- order of parameter
-- username, first name, last name, is visitor, phone
BEGIN 
    SET is_visitor = is_visitor + 1;
    UPDATE Users 
    SET FirstName = first_name, LastName = last_name, IsVisitor = is_visitor 
    WHERE UserName LIKE user_name;
    UPDATE Employee
    SET Phone = phone_ 
    WHERE UserName LIKE user_name;
END $$


CREATE PROCEDURE manage_user(in user_name varchar(50), in new_status varchar(10) )
-- order of parameters
-- username, new status
BEGIN
    DECLARE status_ varchar(10);
    DECLARE em_id int(9);
    SET status_ = new_status;
    IF ('APPROVED' IN (SELECT `Status` FROM Users WHERE UserName = user_name)) AND (new_status = 'DENIED') THEN 
        SET @error = 'Cannot deny an approved user.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    ELSE
        UPDATE Users SET Status = status_ WHERE UserName = user_name;
        IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) AND status_ = 'APPROVED' THEN                
            SET em_id = 000000001;
            WHILE EXISTS(SELECT * FROM Employee WHERE EmployeeID = em_id) DO
                SET em_id = em_id + 1;
            END WHILE;
            UPDATE Employee SET EmployeeID = em_id WHERE UserName = user_name;
        END IF;
    END IF;
END $$


CREATE PROCEDURE edit_site(in site_name varchar(50), in zip_code varchar(5), in address_ varchar(100), in manager_name varchar(50), in open_every_day int(1) )
-- order of parameter
-- site name, zipcode, address, manager name, if open everyday
-- open_every_day's value shall be 0 or 1 (1 for yes, 0 for no)
BEGIN 
    SET open_every_day = open_every_day + 1;
    UPDATE Site 
    SET Zipcode = zip_code, Address = address_, ManagerName = manager_name, EveryDay = open_every_day 
    WHERE SiteName = site_name;
END $$


CREATE PROCEDURE create_site(in site_name varchar(50), in zip_code varchar(5), in address_ varchar(100), in manager_name varchar(50), in open_every_day int(1) )
-- order of parameter
-- site name, zipcode, address, manager name, if open everyday
-- open_every_day's value shall be 0 or 1 (1 for yes, 0 for no)
BEGIN   
    SET open_every_day = open_every_day + 1;    
    INSERT INTO Site VALUES(site_name, zip_code, address_, open_every_day, manager_name);
END $$


CREATE PROCEDURE edit_transit(in transport_type varchar(10), in old_route varchar(20), in new_route varchar(20), in price_ float )
-- order of parameter
-- transport type, old route, new route , price
-- if the route has no change, new_route and old_route shall have the same value
BEGIN 
    UPDATE Transit 
    SET Route = new_route, Price = price_ 
    WHERE TransportType = transport_type AND Route = old_route;
END $$


CREATE PROCEDURE create_transit(in transport_type varchar(10), in route_ varchar(20), in price_ float )
-- order of parameter
-- transport type, route, price
BEGIN 
    INSERT INTO Transit VALUES(route_, transport_type, price_);
END $$


CREATE PROCEDURE connect_site(in transport_type varchar(10), in route_ varchar(20), in site_name varchar(50) )
-- order of parameter
-- transport type, route, site_name
BEGIN 
    IF ! EXISTS(SELECT * FROM Connects WHERE TransportType = transport_type AND Route = route_ AND SiteName = site_name) THEN 
        INSERT INTO Connects VALUES(route_, transport_type, site_name);
    ELSE 
        SET @error = 'This site has been connected.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE disconnect_site(in transport_type varchar(10), in route_ varchar(20), in site_name varchar(50) )
-- order of parameter
-- transport type, route, site_name
BEGIN 
    IF EXISTS(SELECT * FROM Connects WHERE TransportType = transport_type AND Route = route_ AND SiteName = site_name) THEN 
        DELETE FROM Connects WHERE TransportType = transport_type AND Route = route_ AND SiteName = site_name;
    ELSE 
        SET @error = 'This site has been disconnected.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
    
END $$


CREATE PROCEDURE edit_event(in site_name varchar(50), in event_name varchar(50), in start_date date, in description_ text )
-- order of parameter
-- site name, event name, start date, new discription
BEGIN 
    IF NOT EXISTS(SELECT * FROM Events WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date) THEN 
        SET @error = 'This event does not exist.';
    END IF;
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    UPDATE `Events` 
    SET Description = description_ 
    WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date;
END $$


CREATE PROCEDURE create_event(in site_name varchar(50), in event_name varchar(50), in start_date date, in end_date date, in min_staff_req int, in price_ float, in capacity_ int, in description_ text )
-- order of parameter
-- site name, event name, start date, end date, minimun staff requirment, price, capacity, discription
BEGIN 
    INSERT INTO Events VALUES(site_name, event_name, start_date, end_date, min_staff_req, price_, capacity_, description_);
END $$


CREATE PROCEDURE assign_staff(in site_name varchar(50), in event_name varchar(50), in start_date date, in staff_name varchar(50) )
-- order of parameter
-- site name, event name, start date, staff name
BEGIN 
    IF ! EXISTS(SELECT * FROM AssignTo WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND StaffName = staff_name) THEN 
        INSERT INTO AssignTo VALUES(staff_name, site_name, event_name, start_date);
    ELSE 
        SET @error = 'This staff has been assigned.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
    
END $$


CREATE PROCEDURE remove_staff(in site_name varchar(50), in event_name varchar(50), in start_date date, in staff_name varchar(50) )
-- order of parameter
-- site name, event name, start date, staff name
BEGIN  
    IF EXISTS(SELECT * FROM AssignTo WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND StaffName = staff_name) THEN 
        DELETE FROM AssignTo WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND StaffName = staff_name;
    ELSE 
        SET @error = 'This staff has been unassigned.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE log_event(in site_name varchar(50), in event_name varchar(50), in start_date date, in user_name varchar(50), in log_date date )
-- order of parameter
-- site name, event name, start date, user name, visit date
BEGIN  
    INSERT INTO VisitEvent VALUES(user_name, site_name, event_name, start_date, log_date);
END $$


CREATE PROCEDURE log_site(in site_name varchar(50), in user_name varchar(50), in log_date date )
-- order of parameter
-- site name, user name, visit date
BEGIN  
    INSERT INTO VisitSite VALUES(user_name, site_name, log_date);
END $$


CREATE PROCEDURE query_user_by_email(in email_address varchar(100) )
-- order of parameter
-- email address
-- user name, password, status, first name, last name, is visitor, is employee
BEGIN
     DECLARE user_name varchar(100);
     DECLARE pass_word varchar(100);
     DECLARE status_ varchar(20);
     DECLARE first_name varchar(100);
     DECLARE last_name varchar(100);
     DECLARE is_visitor int(1);
     DECLARE is_employee int(1);
     
    IF EXISTS(SELECT * FROM Email WHERE EmailAddress = email_address) THEN 
        SET user_name = (SELECT UserName FROM Email WHERE EmailAddress = email_address LIMIT 1);
        SELECT `Password`, `Status`, FirstName, LastName, IsVisitor INTO pass_word, status_, first_name, last_name, is_visitor FROM Users WHERE UserName = user_name LIMIT 1 ;
        SET is_visitor = is_visitor - 1;
        IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) THEN
            SET is_employee = 1;
        ELSE 
            SET is_employee = 0;
        END IF;
        SELECT user_name, pass_word, first_name, last_name, is_visitor, status_, is_employee;
    ELSE 
        SET @error = 'Email Address does not exist.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
    
END $$


CREATE PROCEDURE query_user_by_username(in user_name varchar(100) )
-- order of parameter
-- user name
-- password, status, first name, last name, is visitor, is employee
BEGIN
    DECLARE pass_word varchar(100);
    DECLARE status_ varchar(20);
    DECLARE first_name varchar(100);
    DECLARE last_name varchar(100);
    DECLARE is_visitor int(1);
    DECLARE is_employee int(1);
     
    SELECT `Password`, `Status`, FirstName, LastName, IsVisitor INTO pass_word, status_, first_name, last_name, is_visitor FROM Users WHERE UserName = user_name LIMIT 1 ;
    SET is_visitor = is_visitor - 1;
    IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) THEN
        SET is_employee = 1;
    ELSE 
        SET is_employee = 0;
    END IF;
    IF length(pass_word) > 1 THEN 
        SELECT pass_word, first_name, last_name, is_visitor, status_, is_employee;
    ELSE 
        SET @error = concat(user_name, ' does not exist.');
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
    
END $$


CREATE PROCEDURE query_employee_sitename(in user_name varchar(100))
-- order of parameter
-- user name
-- site name
BEGIN 
    DECLARE site_name varchar(50);
     
    IF EXISTS(SELECT * FROM Site WHERE ManagerName = user_name) THEN
        SELECT SiteName INTO site_name FROM Site WHERE ManagerName = user_name;
        SELECT site_name;
    ELSE 
        SELECT "";
    END IF;    
END $$


CREATE PROCEDURE query_employee_by_username(in user_name varchar(100) )
-- order of parameter
-- user name
-- employee id, phone, address, city, state, zip code, title
BEGIN 
    DECLARE employee_id varchar(9); 
    DECLARE phone_ varchar(10); 
    DECLARE address_ varchar(100); 
    DECLARE city_ varchar(100); 
    DECLARE state_ varchar(100); 
    DECLARE zip_code varchar(10); 
    DECLARE title_ varchar(20);
     
    IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) THEN
        SELECT EmployeeID, Phone, Address, City, State, ZipCode, Title 
        INTO employee_id, phone_, address_, city_, state_, zip_code, title_ 
        FROM Employee WHERE UserName = user_name;
        SELECT  phone_, address_, city_, state_, zip_code, title_, employee_id;
    ELSE 
        SET @error = 'This user is not an employee.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;    
END $$


CREATE PROCEDURE query_employee_by_email(in email_address varchar(100))
-- order of parameter
-- email address
-- user name, employee id, phone, address, city, state, zip code, title
BEGIN
     
    DECLARE user_name varchar(100); 
    DECLARE employee_id varchar(9); 
    DECLARE phone_ varchar(10); 
    DECLARE address_ varchar(100); 
    DECLARE city_ varchar(100); 
    DECLARE state_ varchar(100); 
    DECLARE zip_code varchar(10); 
    DECLARE title_ varchar(20);
    
    SELECT UserName INTO user_name FROM Email WHERE EmailAddress = email_address;
    IF length(user_name) > 0 THEN 
        IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) THEN
            SELECT EmployeeID, Phone, Address, City, State, ZipCode, Title 
            INTO employee_id, phone_, address_, city_, state_, zip_code, title_ 
            FROM Employee WHERE UserName = user_name;
            SELECT user_name, phone_, address_, city_, state_, zip_code, title_, employee_id;
        ELSE 
            SET @error = 'This user is not an employee.';
            SIGNAL SQLSTATE '45000' SET message_text = @error;
        END IF;  
    ELSE 
        SET @error = 'This user does not exist.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE delete_user(in user_name varchar(100) )
-- order of parameter
-- user name
BEGIN 
    DELETE FROM Users WHERE UserName = user_name;
END $$


CREATE PROCEDURE check_email(in email_address varchar(100))
-- order of parameter
-- email address, result
-- 1 for you can insert, 0 for not
BEGIN 
    DECLARE result int(1);
    IF EXISTS(SELECT UserName FROM Email WHERE EmailAddress = email_address LIMIT 1) THEN 
        SET result = 0;
    ELSE
        SET result = 1;
    END IF;
    SELECT result;
END $$


CREATE PROCEDURE check_username(in user_name varchar(100))
-- order of parameter
-- user name, result
-- 1 for you can insert, 0 for not
BEGIN 
    DECLARE result int(1);
    IF EXISTS(SELECT UserName FROM Users WHERE UserName = user_name LIMIT 1) THEN 
        SET result = 0;
    ELSE
        SET result = 1;
    END IF;
    SELECT result;
END $$


CREATE PROCEDURE check_status(in user_name varchar(100))
-- order of parameter
-- user name, result
-- 1 for approved, 0 for other status
BEGIN
    DECLARE result int(1);
     
    IF (SELECT `Status` FROM Users WHERE UserName = user_name LIMIT 1) = 'APPROVED' THEN 
        SET result = 1;
    ELSE
        SET result = 0;
    END IF;
    SELECT result;
END $$


CREATE PROCEDURE query_site_by_site_name(in site_name varchar(100))
-- order of parameter
-- site name
-- zip code, address, manager name
BEGIN   
    DECLARE zip_code varchar(5); 
    DECLARE address_ varchar(100);
    DECLARE every_day varchar(10);
    DECLARE manager_name varchar(100);
     
    IF length(site_name) > 0 THEN
        SELECT Zipcode, Address, EveryDay, ManagerName INTO zip_code, address_, every_day, manager_name FROM Site WHERE SiteName = site_name;
        IF length(zip_code) > 1 THEN 
            SELECT zip_code, address_, every_day, manager_name;
        ELSE 
            SET @error = concat(site_name, ' does not exist.');
            SIGNAL SQLSTATE '45000' SET message_text = @error;
        END IF;
    ELSE 
        SET @error = 'Site name cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;    
END $$


CREATE PROCEDURE query_event_by_pk(in site_name varchar(50), in event_name varchar(50), in start_date date)
-- order of parameter
-- site name, event name, start date
-- end date, minimun staff requirement, capacity, description
BEGIN
    DECLARE end_date date; 
    DECLARE min_staff_req int; 
    DECLARE capacity_ int;
    DECLARE description_ text;
    DECLARE duration_ int;
    DECLARE price_ int;
     
    IF length(site_name) > 0 AND length(event_name) > 0 AND start_date != '0000-00-00' THEN
        SELECT EndDate, MinStaffReq, Capacity, Description, Duration, Price INTO end_date, min_staff_req, capacity_, description_, duration_, price_ FROM for_event WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date LIMIT 1;        
        IF length(description_) > 1 THEN 
            SELECT end_date, min_staff_req, capacity_, description_, duration_, price_;
        ELSE 
            SET @error = concat(event_name, ' does not exist.');
            SIGNAL SQLSTATE '45000' SET message_text = @error;
        END IF;
    ELSE 
        SET @error = 'Primary key cannot have null value.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
    
END $$


CREATE PROCEDURE check_phone(in phone_ varchar(10))
-- order of parameter
-- phone
-- 1 for you can insert, 0 for not
BEGIN
    DECLARE result int;
    
    IF EXISTS(SELECT * FROM Employee WHERE Phone = phone_) THEN
        SET result = 0;
    ELSE 
        SET result = 1;
    END IF;
    SELECT result;
END $$


CREATE PROCEDURE get_all_sites() 
BEGIN
    SELECT SiteName, ZipCode, Address, (EveryDay - 1) AS OpenEveryDay, ManagerName FROM Site;
END $$



CREATE PROCEDURE delete_site(in site_name varchar(50))
BEGIN
    DELETE FROM Site WHERE SiteName = site_name;
END $$



CREATE PROCEDURE get_free_managers()
BEGIN
    SELECT UserName FROM Employee WHERE Title = "MANAGER" AND UserName NOT IN (SELECT ManagerName FROM Site);
END $$



CREATE PROCEDURE get_all_events()
BEGIN
    SELECT SiteName, EventName, StartDate, EndDate, MinStaffReq, Price, Capacity, Description FROM Events;
END $$


CREATE PROCEDURE delete_transit(in route_ varchar(20), in transport_type varchar(20))
BEGIN
    DELETE FROM Transit WHERE Route = route_ AND TransportType = transport_type;
END $$


CREATE PROCEDURE check_transit(in route_ varchar(20), in transport_type varchar(20))
BEGIN
    DECLARE result int;
    IF EXISTS(SELECT * FROM Transit WHERE Route = route_ AND TransportType = transport_type) THEN 
        SET result = 0;
    ELSE 
        SET result = 1;
    END IF;
    SELECT result;
END $$


CREATE PROCEDURE check_site(in site_name varchar(50))
BEGIN
    DECLARE result int;
    IF EXISTS(SELECT * FROM Site WHERE SiteName = site_name) THEN 
        SET result = 0;
    ELSE 
        SET result = 1;
    END IF;
    SELECT result;
END $$


DELIMITER ;


DELIMITER $$


CREATE PROCEDURE filter_transit(in site_name varchar(50), in route_ varchar(20), in transport_type varchar(10), in low_price float, in high_price float)
-- order of parameter
-- site name, transport type, lower bondary of price, higher bondary of price
-- null value means not apply to the filter
BEGIN
    DECLARE new_site_name varchar(100);
    DECLARE new_route_ varchar(20);
    DECLARE new_high_price int;
    
    IF length(site_name) > 0 THEN
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF;
    IF length(route_) > 0 THEN
        SET new_route_ = route_;
    ELSE 
        SET new_route_ = '%';
    END IF;
    IF high_price = 0 THEN
        SET new_high_price = 1000.00;
    ELSE
        SET new_high_price = high_price;
    END IF;
    IF length(transport_type) > 0 THEN 
        SELECT DISTINCT Route, TransportType, Price, NumConnected, NumLogged  FROM for_transit JOIN Connects USING(Route, TransportType) WHERE SiteName LIKE new_site_name AND TransportType = transport_type AND Price >= low_price AND Price <= new_high_price AND Route LIKE new_route_;
    ELSE 
        SELECT DISTINCT Route, TransportType, Price, NumConnected, NumLogged  FROM for_transit JOIN Connects USING(Route, TransportType) WHERE SiteName LIKE new_site_name AND Price >= low_price AND Price <= new_high_price AND Route LIKE new_route_;
    END IF;
END $$


CREATE PROCEDURE filter_transit_history(in user_name varchar(100), in site_name varchar(50), in transport_type varchar(10), in start_date date, in end_date date )
BEGIN
    DECLARE new_site_name varchar(100);
    DECLARE new_start_date date;
    DECLARE new_end_date date;
     
     
    
    IF length(user_name) > 0 THEN
        IF length(site_name) > 0 THEN
            SET new_site_name = site_name;
        ELSE 
            SET new_site_name = '%';
        END IF;
        IF end_date = '0000-00-00' THEN
            SET new_end_date = '9999-12-31';
        ELSE 
            SET new_end_date = end_date;
        END IF;
        IF start_date = '0000-00-00' THEN
            SET new_start_date = '1000-01-01';
        ELSE 
            SET new_start_date = start_date;
        END IF;
        IF length(transport_type) >  0 THEN 
            SELECT DISTINCT Route, TransportType, Price, `Date` FROM Take JOIN Transit USING(Route, TransportType) JOIN Connects USING(Route, TransportType) WHERE UserName = user_name AND SiteName LIKE new_site_name AND TransportType = transport_type AND `Date` >= new_start_date AND `Date` <= new_end_date;
        ELSE 
            SELECT DISTINCT Route, TransportType, Price, `Date` FROM Take JOIN Transit USING(Route, TransportType) JOIN Connects USING(Route, TransportType) WHERE UserName = user_name AND SiteName LIKE new_site_name AND `Date` >= new_start_date AND `Date` <= new_end_date;
        END IF;
    ELSE 
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;  
    
   
END $$



CREATE PROCEDURE filter_user(in user_name varchar(100), in type_ varchar(20), in status_ varchar(10) )
-- order of parameter
-- username, type, status
BEGIN 
    DECLARE new_user_name varchar(100);
    DECLARE new_type_ varchar(20);
    DECLARE new_status_ varchar(10);
     
     
    IF length(user_name) > 0 THEN 
        SET new_user_name = user_name;
    ELSE 
        SET new_user_name = '%';
    END IF;
    IF length(type_) > 0 THEN 
        SET new_type_ = type_;
    ELSE 
        SET new_type_ = '%';
    END IF;
    IF length(status_) > 0 THEN 
        SELECT UserName, Type, `Status`, NumEmailCount FROM for_users WHERE UserName LIKE new_user_name AND Type LIKE new_type_ AND `Status` = status_;
    ELSE 
        SELECT UserName, Type, `Status`, NumEmailCount  FROM for_users WHERE UserName LIKE new_user_name AND Type LIKE new_type_;
    END IF;
END $$


CREATE PROCEDURE filter_site_adm(in site_name varchar(50), in manager_name varchar(100), in open_everyday int )
-- order of parameter
-- site name, manager name, if open every day
BEGIN 
    DECLARE new_site_name varchar(50);
    DECLARE new_manager_name varchar(100);
    DECLARE new_open_everyday int;
    
    IF length(site_name) > 0 THEN 
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF;
    IF length(manager_name) > 0 THEN 
        SET new_manager_name = manager_name;
    ELSE 
        SET new_manager_name = '%';
    END IF;
    SET new_open_everyday = open_everyday + 1;
    
    SELECT SiteName, ManagerName, EveryDay FROM for_site WHERE SiteName LIKE new_site_name AND ManagerName LIKE new_manager_name AND EveryDay = new_open_everyday;
END $$


CREATE PROCEDURE filter_event_adm(in manager_name varchar(100), in event_name varchar(50), in key_word varchar(100), in start_date date, in end_date date, in short_duration int, in long_duration int, in low_visit int, in high_visit int, in low_revenue float, in high_revenue float )
-- order of parameter
-- event nane, key word in description, start date, end date, lower bondary of duration, higher bondary of duration, lower bondary of visit, higher bondary of visit, lower bondary of revenue, higher bondary of revenue
BEGIN 
    DECLARE new_event_name varchar(50);
    DECLARE new_key_word varchar(100);
    DECLARE new_start_date date;
    DECLARE new_end_date date;
    DECLARE new_long_duration int;
    DECLARE new_high_visit int;
    DECLARE new_high_revenue float;
    DECLARE site_name varchar(50);
    
    IF length(event_name) > 0 THEN 
        SET new_event_name = event_name;
    ELSE 
        SET new_event_name = '%';
    END IF;
    IF length(key_word) > 0 THEN 
        SET new_key_word = concat('%', concat(key_word, '%'));
    ELSE 
        SET new_key_word = '%';
    END IF;
    IF end_date = '0000-00-00' THEN
        SET new_end_date = '9999-12-31';
    ELSE 
        SET new_end_date = end_date;
    END IF;
    IF start_date = '0000-00-00' THEN
            SET new_start_date = '1000-01-01';
    ELSE 
        SET new_start_date = start_date;
    END IF;
    IF long_duration = 0 THEN
        SET new_long_duration = ~0;
    ELSE
        SET new_long_duration = long_duration;
    END IF;
    IF high_visit = 0 THEN
        SET new_high_visit = ~0;
    ELSE
        SET new_high_visit = high_visit;
    END IF;
    IF high_revenue = 0 THEN
        SET new_high_revenue = ~0 - 1.0;
    ELSE
        SET new_high_revenue = high_revenue;
    END IF;   
    
    SELECT SiteName INTO site_name FROM Site WHERE ManagerName = manager_name;    
    
    SELECT EventName, CountStaff, Duration, TotalVisit, TotalRevenue FROM for_event WHERE SiteName = site_name AND EventName LIKE new_event_name AND Description LIKE new_key_word AND StartDate >= new_start_date AND EndDate <= new_end_date AND Duration >= short_duration AND Duration <= new_long_duration AND TotalVisit >= low_visit AND TotalVisit <= new_high_visit AND TotalRevenue >= low_revenue AND TotalRevenue <= new_high_revenue;
    
END $$


CREATE PROCEDURE filter_event_daily(in site_name varchar(50), in event_name varchar(50), in start_date date, in low_visit int, in high_visit int, in low_revenue float, in high_revenue float )
-- order of parameter
-- site name, manager name, if open every day
BEGIN 
    DECLARE new_high_visit int;
    DECLARE new_high_revenue float;
    
    IF high_visit = 0 THEN
        SET new_high_visit = ~0;
    ELSE
        SET new_high_visit = high_visit;
    END IF;
    IF high_revenue = 0 THEN
        SET new_high_revenue = ~0 - 1.0;
    ELSE
        SET new_high_revenue = high_revenue;
    END IF;  
    
    IF length(site_name) > 0 AND length(event_name) > 0 AND start_date != '0000-00-00' THEN
        SELECT `Date`, DailyVisit, DailyRevenue FROM daily_event WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND DailyVisit >= low_price AND DailyVisit <= new_high_price AND DailyRevenue >= low_revenue AND DailyRevenue <= new_high_revenue;
    ELSE 
        SET @error = 'Primary key cannot have null value.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE filter_staff(in site_name varchar(50), in first_name varchar(50), in last_name varchar(50), in start_date date, in end_date date )
-- order of parameter
-- site name, first name, last name, start date, end date
BEGIN
    DECLARE new_site_name varchar(50);
    DECLARE new_first_name varchar(50);
    DECLARE new_last_name varchar(50);
    DECLARE new_start_date date;
    DECLARE new_end_date date;
    
    IF length(site_name) > 0 THEN 
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF;
    IF length(first_name) > 0 THEN 
        SET new_first_name = first_name;
    ELSE 
        SET new_first_name = '%';
    END IF;
    IF length(last_name) > 0 THEN 
        SET new_last_name = last_name;
    ELSE 
        SET new_last_name = '%';
    END IF;
    IF end_date = '0000-00-00' THEN
        SET new_end_date = '9999-12-31';
    ELSE 
        SET new_end_date = end_date;
    END IF;
    IF start_date = '0000-00-00' THEN
        SET new_start_date = '1000-01-01';
    ELSE 
        SET new_start_date = start_date;
    END IF;
    
    SELECT concat(FirstName, LastName) AS `StaffName`, NumEventShifts FROM for_staff 
    WHERE SiteName LIKE new_site_name AND FirstName LIKE new_first_name AND LastName LIKE new_last_name AND StartDate >= new_start_date AND EndDate <= new_end_date;

END $$

CREATE PROCEDURE filter_daily_site(in site_name varchar(50), in start_date date, in end_date date, low_event int, in high_event int, in low_staff int, in high_staff int, in low_visit int, in high_visit int, in low_revenue float, in high_revenue float )
-- order of parameters
-- site name, start date, end date, lower bondary of event count, higher bondary of event count, lower bondary of staff count, higher bondary of staff count, lower bondary of daily visits, higher bondary of daily visits, lower bondary of daily revenue, higher bondary of daily revenue
BEGIN
    DECLARE new_start_date date;
    DECLARE new_end_date date;
    DECLARE new_high_event int;
    DECLARE new_high_staff int;
    DECLARE new_high_visit int;
    DECLARE new_high_revenue float;
    
     
     
    
    IF length(site_name) = 0 THEN 
        SET @error = 'Site name cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    ELSE
        IF end_date = '0000-00-00' THEN
            SET new_end_date = '9999-12-31';
        ELSE 
            SET new_end_date = end_date;
        END IF;
        IF start_date = '0000-00-00' THEN
            SET new_start_date = '1000-01-01';
        ELSE 
            SET new_start_date = start_date;
        END IF;
        IF high_revenue = 0 THEN
            SET new_high_revenue = ~0 - 1.0;
        ELSE
            SET new_high_revenue = high_revenue;
        END IF;
        IF high_staff = 0 THEN
            SET new_high_staff = ~0;
        ELSE
            SET new_high_staff = high_staff;
        END IF;
        IF high_visit = 0 THEN
            SET new_high_visit = ~0;
        ELSE
            SET new_high_visit = high_visit;
        END IF;
        IF high_event = 0 THEN
            SET new_high_event = ~0;
        ELSE
            SET new_high_event = high_event;
        END IF;
        SELECT `Date`, EventCount, CountStaff, DailyVisit, DailyReveneu FROM full_daily_site 
        WHERE SiteName = site_name AND `Date` >= new_start_date AND `Date` <= new_end_date AND EventCount >= low_event AND EventCount <= new_high_event AND CountStaff >= low_staff AND CountStaff <= new_high_staff AND DailyVisit >= low_visit AND DailyVisit <= low_new_high_visit AND DailyRevenue >= low_revenue AND DailyRevenue <= new_high_revenue;
    END IF;
END $$



CREATE PROCEDURE filter_daily_event(in site_name varchar(50), in date_ date )
-- order of parameters
-- site name, date
BEGIN
     
    IF length(site_name) = 0 OR date_ = '0000-00-00' THEN 
        SET @error = 'Site name or date cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    ELSE 
        SELECT EventName, SiteName, StartDate, DailyVisit, DailyRevenue FROM daily_event WHERE SiteName = site_name AND `Date` = date_;
    END IF;
END $$


CREATE PROCEDURE filter_schedule(in user_name varchar(100), in event_name varchar(50), in key_word varchar(200), in start_date date, in end_date date)
-- order of parameter
-- username, event name, description keyword, start date, end date
BEGIN
    DECLARE new_event_name varchar(50);
    DECLARE new_key_word varchar(200);
    
    IF length(event_name) > 0 THEN 
        SET new_event_name = event_name;
    ELSE 
        SET new_event_name = '%';
    END IF;
    IF length(key_word) > 0 THEN 
        SET new_key_word = concat('%', concat(key_word, '%'));
    ELSE 
        SET new_key_word = '%';
    END IF;
    
    IF start_date = '0000-00-00' THEN 
        IF end_date = '0000-00-00' THEN
            SELECT EventName, SiteName, StartDate, EndDate, CountStaff, Description FROM for_schedule 
            WHERE StaffName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key_word;
        ELSE 
            SELECT EventName, SiteName, StartDate, EndDate, CountStaff, Description FROM for_schedule 
            WHERE StaffName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key_word AND EndDate = end_date;
        END IF;
    ELSE 
        IF end_date = '0000-00-00' THEN
            SELECT EventName, SiteName, StartDate, EndDate, CountStaff, Description FROM for_schedule 
            WHERE StaffName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key_word AND StartDate = start_date;
        ELSE 
            SELECT EventName, SiteName, StartDate, EndDate, CountStaff, Description FROM for_schedule 
            WHERE StaffName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key_word AND EndDate = end_date AND StartDate = start_date;
        END IF;
    END IF; 
END $$


CREATE PROCEDURE filter_event_vis(in user_name varchar(100), in event_name varchar(50), in key_word varchar(200), in site_name varchar(50), in start_date date, in end_date date, in low_visit int, in high_visit int, in low_price float, in high_price float, in is_visited int, in is_sold_out int )
-- order of parameter
-- username, event name, description keyword, site name, start date, end date, lower bondary of total visit, higher bondary of total visit, lower bondary of price, higher bondary of price, if show visited event, if show sold-out-ticket event
BEGIN
    DECLARE new_site_name varchar(100);
    DECLARE new_event_name varchar(100);
    DECLARE new_key varchar(200);
    DECLARE new_high_visit int;
    DECLARE new_high_price float;
    DECLARE new_visited int;
    DECLARE new_sold int;
    
    SET new_event_name = concat('%', concat(event_name, '%'));
    SET new_key = concat('%', concat(key_word, '%'));
    IF length(site_name) > 0 THEN
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF;    
    IF high_visit > 0 THEN
        SET new_high_visit = high_visit;
    ELSE 
        SET new_high_visit = ~0;
    END IF;    
    IF high_price > 0 THEN
        SET new_high_price = high_price;
    ELSE 
        SET new_high_price = ~0;
    END IF;
    IF is_visited = 1 THEN
        SET new_visited = ~0;
    ELSE 
        SET new_visited = 1;
    END IF;
    IF is_sold_out = 1 THEN
        SET new_sold = 0;
    ELSE 
        SET new_sold = 1;
    END IF;
    
    IF length(user_name) > 0 THEN
        IF start_date = '0000-00-00' THEN 
            IF end_date = '0000-00-00' THEN
                SELECT EventName, SiteName, Price, TicketRem, TotalVisit, MyVisit, StartDate, EndDate FROM explore_event
                WHERE UserName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key AND TotalVisit <= new_high_visit AND TotalVisit >= low_visit AND Price >= low_price AND Price <= new_high_price AND MyVisit < new_visited AND TicketRem >= new_sold ;
            ELSE 
                SELECT EventName, SiteName, Price, TicketRem, TotalVisit, MyVisit, StartDate, EndDate FROM explore_event
                WHERE UserName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key AND TotalVisit <= new_high_visit AND TotalVisit >= low_visit AND Price >= low_price AND Price <= new_high_price AND MyVisit < new_visited AND TicketRem >= new_sold AND EndDate = end_date;
            END IF;
        ELSE 
            IF end_date = '0000-00-00' THEN
                SELECT EventName, SiteName, Price, TicketRem, TotalVisit, MyVisit, StartDate, EndDate  FROM explore _event
                WHERE UserName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key AND TotalVisit <= new_high_visit AND TotalVisit >= low_visit AND Price >= low_price AND Price <= new_high_price AND MyVisit < new_visited AND TicketRem >= new_sold AND StartDate = start_date;
            ELSE 
                SELECT EventName, SiteName, Price, TicketRem, TotalVisit, MyVisit, StartDate, EndDate FROM explore _event
                WHERE UserName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key AND TotalVisit <= new_high_visit AND TotalVisit >= low_visit AND Price >= low_price AND Price <= new_high_price AND MyVisit < new_visited AND TicketRem >= new_sold AND EndDate = end_date AND StartDate = start_date;
            END IF;
        END IF; 
    ELSE
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
    
END $$



CREATE PROCEDURE filter_site_vis(in user_name varchar(100), in site_name varchar(50), in open_everyday int, in start_date date, in end_date date, in low_visit int, in high_visit int, in low_event int, in high_event int, in is_visited int )
-- order of paremeter
-- username, site name, if site open everyday, start date, end date, lower bondary of total visit, higher bondary of total visit, lower bondary of event count, higher bondary of event count, if this site has been visited 
-- open_everyday's value shall be 0, 1, or 2, in which 0 for all, 1 for no, 2 for yes
BEGIN
    DECLARE new_site_name varchar(50);
    DECLARE new_start_date date;
    DECLARE new_end_date date;
    DECLARE new_high_visit int;
    DECLARE new_high_event int;
    DECLARE new_visited int;
    
    IF length(site_name) > 0 THEN
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF; 
    IF end_date = '0000-00-00' THEN
        SET new_end_date = '9999-12-31';
    ELSE 
        SET new_end_date = end_date;
    END IF;
    IF start_date = '0000-00-00' THEN
            SET new_start_date = '1000-01-01';
    ELSE 
        SET new_start_date = start_date;
    END IF;
    IF high_visit = 0 THEN
        SET new_high_visit = ~0;
    ELSE
        SET new_high_visit = high_visit;
    END IF;
    IF high_event = 0 THEN
        SET new_high_event = ~0;
    ELSE
        SET new_high_event = high_event;
    END IF;
    IF is_visited = 1 THEN
        SET new_visited = ~0;
    ELSE 
        SET new_visited = 1;
    END IF;
    
    IF length(user_name) > 0 THEN 
        IF open_everyday = 0 THEN
            SELECT SiteName, CountEvent, TotalVist, sum(MyVisit) AS MyVisits, `Date`, EveryDay FROM explore_site 
            WHERE UserName = user_name AND SiteName LIKE new_site_name AND `Date` >= new_start_date AND `Date` <= new_end_date AND
            TotalVisit >= low_visit AND TotalVisit <= new_high_visit GROUP BY SiteName, UserName HAVING MyVisits < new_visited;
        ELSE 
            SELECT SiteName, CountEvent, TotalVist, sum(MyVisit) AS MyVisits, `Date`, EveryDay FROM explore_site 
            WHERE UserName = user_name AND SiteName LIKE new_site_name AND `Date` >= new_start_date AND `Date` <= new_end_date AND
            TotalVisit >= low_visit AND TotalVisit <= new_high_visit GROUP BY SiteName, UserName HAVING MyVisits < new_visited AND 
            EveryDay = open_everyday;
        END IF;
    ELSE 
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$








CREATE PROCEDURE query_email_by_username(in user_name varchar(100) )
-- order of parameter
-- username
BEGIN   
     
    IF length(user_name) > 0 THEN
        SELECT EmailAddress FROM Email WHERE UserName = user_name;
    ELSE 
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE query_transit_by_pk(in route_ varchar(20), in transport_type varchar(20) )
-- order of parameter
-- route, transport type
BEGIN   
     
    IF length(route_) > 0  AND length(transport_type) > 0 THEN
        SELECT Price, SiteName FROM Connects JOIN Transit USING(Route, TransportType) WHERE Route = route_ AND TransportType = transport_type;
    ELSE 
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$



CREATE PROCEDURE query_staff_by_event (in site_name varchar(50), in event_name varchar(50), in start_date date )
-- order of parameter
-- site name, event name, start date
BEGIN
     
    IF length(site_name) > 0 AND length(event_name) > 0 AND start_date != '0000-00-00' THEN
        SELECT StaffName, FirstName, LastName AS Name FROM AssignTo JOIN Users ON StaffName = UserName WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date;
    ELSE 
        SET @error = 'Primary key cannot have null value.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE query_transit_by_site(in site_name varchar(50) )
BEGIN
     
    IF length(site_name) > 0 THEN 
        SELECT Route, TransportType, Price FROM Transit JOIN Connects USING(Route, TransportType) WHERE SiteName = site_name;
    ELSE 
        SET @error = 'Site name cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE get_all_transit()
BEGIN
    SELECT Route, TransportType, Price, count(*) AS CountSite FROM Transit JOIN Connects USING(TransportType, Route) Group BY TransportType, Route;
END $$

DELIMITER ;


DELIMITER ;

USE atlbeltline;

CALL register_user('james.smith', 'jsmith123', 'James', 'Smith', 0 );
CALL manage_user('james.smith', 'APPROVED' );
CALL register_user('michael.smith', 'msmith456', 'Michael', 'Smith', 1 );
CALL manage_user('michael.smith', 'APPROVED' );
CALL register_user('robert.smith', 'rsmith789', 'Robert ', 'Smith', 0 );
CALL manage_user('robert.smith', 'APPROVED' );
CALL register_user('maria.garcia', 'mgarcia123', 'Maria', 'Garcia', 1 );
CALL manage_user('maria.garcia', 'APPROVED' );
CALL register_user('david.smith', 'dsmith456', 'David', 'Smith', 0 );
CALL manage_user('david.smith', 'APPROVED' );
CALL register_user('manager1', 'manager1', 'Manager', 'One', 0 );
CALL register_user('manager2', 'manager2', 'Manager', 'Two', 1 );
CALL manage_user('manager2', 'APPROVED' );
CALL register_user('manager3', 'manager3', 'Manager', 'Three', 0 );
CALL manage_user('manager3', 'APPROVED' );
CALL register_user('manager4', 'manager4', 'Manager', 'Four', 1 );
CALL manage_user('manager4', 'APPROVED' );
CALL register_user('manager5', 'manager5', 'Manager', 'Five', 1 );
CALL manage_user('manager5', 'APPROVED' );
CALL register_user('maria.rodriguez', 'mrodriguez', 'Maria', 'Rodriguez', 1 );
CALL manage_user('maria.rodriguez', 'DENIED' );
CALL register_user('mary.smith', 'msmith789', 'Mary', 'Smith', 1 );
CALL manage_user('mary.smith', 'APPROVED' );
CALL register_user('maria.hernandez', 'mhernandez', 'Maria', 'Hernandez', 1 );
CALL manage_user('maria.hernandez', 'APPROVED' );
CALL register_user('staff1', 'staff1234', 'Staff', 'One', 0 );
CALL manage_user('staff1', 'APPROVED' );
CALL register_user('staff2', 'staff4567', 'Staff', 'Two', 1 );
CALL manage_user('staff2', 'APPROVED' );
CALL register_user('staff3', 'staff7890', 'Staff', 'Three', 1 );
CALL manage_user('staff3', 'APPROVED' );
CALL register_user('user1', 'user123456', 'User', 'One', 0 );
CALL register_user('visitor1', 'visitor123', 'Visitor', 'One', 1 );
CALL manage_user('visitor1', 'APPROVED' );

CALL add_email('james.smith', 'jsmith@gmail.com' );
CALL add_email('james.smith', 'jsmith@hotmail.com' );
CALL add_email('james.smith', 'jsmith@gatech.edu' );
CALL add_email('james.smith', 'jsmith@outlook.com' );
CALL add_email('michael.smith', 'msmith@gmail.com' );
CALL add_email('robert.smith', 'rsmith@hotmail.com' );
CALL add_email('maria.garcia', 'mgarcia@yahoo.com' );
CALL add_email('maria.garcia', 'mgarcia@gatech.edu' );
CALL add_email('david.smith', 'dsmith@outlook.com' );
CALL add_email('maria.rodriguez', 'mrodriguez@gmail.com' );
CALL add_email('mary.smith', 'mary@outlook.com' );
CALL add_email('maria.hernandez', 'mh@gatech.edu' );
CALL add_email('maria.hernandez', 'mh123@gmail.com' );
CALL add_email('manager1', 'm1@beltline.com' );
CALL add_email('manager2', 'm2@beltline.com' );
CALL add_email('manager3', 'm3@beltline.com' );
CALL add_email('manager4', 'm4@beltline.com' );
CALL add_email('manager5', 'm5@beltline.com' );
CALL add_email('staff1', 's1@beltline.com' );
CALL add_email('staff2', 's2@beltline.com' );
CALL add_email('staff3', 's3@beltline.com' );
CALL add_email('user1', 'u1@beltline.com' );
CALL add_email('visitor1', 'v1@beltline.com' );

INSERT INTO Employee VALUES('james.smith', '000000001', '4043721234', '123 East Main Street', 'Rochester', 'NY', '14604', 1);
CALL register_employee_aft('michael.smith', '000000002', '4043726789', '350 Ferst Drive', 'Atlanta', 'GA', '30332', 'STAFF' );
CALL register_employee_aft('robert.smith', '000000003', '1234567890', '123 East Main Street', 'Columbus', 'OH', '43215', 'STAFF' );
CALL register_employee_aft('maria.garcia', '000000004', '7890123456', '123 East Main Street', 'Richland', 'PA', '17987', 'MANAGER' );
CALL register_employee_aft('david.smith', '000000005', '5124776435', '350 Ferst Drive', 'Atlanta', 'GA', '30332', 'MANAGER' );
CALL register_employee_aft('manager1', '000000006', '8045126767', '123 East Main Street', 'Rochester', 'NY', '14604', 'MANAGER' );
CALL register_employee_aft('manager2', '000000007', '9876543210', '123 East Main Street', 'Rochester', 'NY', '14604', 'MANAGER' );
CALL register_employee_aft('manager3', '000000008', '5432167890', '350 Ferst Drive', 'Atlanta', 'GA', '30332', 'MANAGER' );
CALL register_employee_aft('manager4', '000000009', '8053467565', '123 East Main Street', 'Columbus', 'OH', '43215', 'MANAGER' );
CALL register_employee_aft('manager5', '000000010', '8031446782', '801 Atlantic Drive', 'Atlanta', 'GA', '30332', 'MANAGER' );
CALL register_employee_aft('staff1', '000000011', '8024456765', '266 Ferst Drive Northwest', 'Atlanta', 'GA', '30332', 'STAFF' );
CALL register_employee_aft('staff2', '000000012', '8888888888', '266 Ferst Drive Northwest', 'Atlanta', 'GA', '30332', 'STAFF' );
CALL register_employee_aft('staff3', '000000013', '3333333333', '801 Atlantic Drive', 'Atlanta', 'GA', '30332', 'STAFF' );
	
CALL create_site('Piedmont Park', '30306', '400 Park Drive Northeast', 'manager2', 1 );
CALL create_site('Atlanta Beltline Center', '30307', '112 Krog Street Northeast', 'manager3', 0 );
CALL create_site('Historic Fourth Ward Park', '30308', '680 Dallas Street Northeast', 'manager4', 1 );
CALL create_site('Westview Cemetery', '30310', '1680 Westview Drive Southwest', 'manager5', 0 );
CALL create_site('Inman Park', '30307', '', 'david.smith', 1 );

CALL create_event('Piedmont Park', 'Eastside Trail', '2019-02-04', '2019-02-05', 1, 0.00, 99999, 'A combination of multi-use trail and linear greenspace, the Eastside Trail was the first finished section of the Atlanta BeltLine trail in the old rail corridor. The Eastside Trail, which was funded by a combination of public and private philanthropic sources, runs from the tip of Piedmont Park to Reynoldstown. More details at https://beltline.org/explore-atlanta-beltline-trails/eastside-trail/' );
CALL create_event('Inman Park', 'Eastside Trail', '2019-02-04', '2019-02-05', 1, 0.00, 99999, 'A combination of multi-use trail and linear greenspace, the Eastside Trail was the first finished section of the Atlanta BeltLine trail in the old rail corridor. The Eastside Trail, which was funded by a combination of public and private philanthropic sources, runs from the tip of Piedmont Park to Reynoldstown. More details at https://beltline.org/explore-atlanta-beltline-trails/eastside-trail/' );
CALL create_event('Inman Park', 'Eastside Trail', '2019-03-01', '2019-03-02', 1, 0.00, 99999, 'A combination of multi-use trail and linear greenspace, the Eastside Trail was the first finished section of the Atlanta BeltLine trail in the old rail corridor. The Eastside Trail, which was funded by a combination of public and private philanthropic sources, runs from the tip of Piedmont Park to Reynoldstown. More details at https://beltline.org/explore-atlanta-beltline-trails/eastside-trail/' );
CALL create_event('Historic Fourth Ward Park', 'Eastside Trail', '2019-02-13', '2019-02-14', 1, 0.00, 99999, 'A combination of multi-use trail and linear greenspace, the Eastside Trail was the first finished section of the Atlanta BeltLine trail in the old rail corridor. The Eastside Trail, which was funded by a combination of public and private philanthropic sources, runs from the tip of Piedmont Park to Reynoldstown. More details at https://beltline.org/explore-atlanta-beltline-trails/eastside-trail/' );
CALL create_event('Westview Cemetery', 'Westside Trail', '2019-02-18', '2019-02-21', 1, 0.00, 99999, 'The Westside Trail is a free amenity that offers a bicycle and pedestrian-safe corridor with a 14-foot-wide multi-use trail surrounded by mature trees and grasses thanks to Trees Atlanta’s Arboretum. With 16 points of entry, 14 of which will be ADA-accessible with ramp and stair systems, the trail provides numerous access points for people of all abilities. More details at: https://beltline.org/explore-atlanta-beltline-trails/westside-trail/' );
CALL create_event('Inman Park', 'Bus Tour', '2019-02-01', '2019-02-02', 2, 25.00, 6, 'The Atlanta BeltLine Partnership’s tour program operates with a natural gas-powered, ADA accessible tour bus funded through contributions from 10th & Monroe, LLC, SunTrust Bank Trusteed Foundations – Florence C. and Harry L. English Memorial Fund and Thomas Guy Woolford Charitable Trust, and AGL Resources' );
CALL create_event('Inman Park', 'Bus Tour', '2019-02-08', '2019-02-10', 2, 25.00, 6, 'The Atlanta BeltLine Partnership’s tour program operates with a natural gas-powered, ADA accessible tour bus funded through contributions from 10th & Monroe, LLC, SunTrust Bank Trusteed Foundations – Florence C. and Harry L. English Memorial Fund and Thomas Guy Woolford Charitable Trust, and AGL Resources' );
CALL create_event('Inman Park', 'Private Bus Tour', '2019-02-01', '2019-02-02', 1, 40.00, 4, 'Private tours are available most days, pending bus and tour guide availability. Private tours can accommodate up to 4 guests per tour, and are subject to a tour fee (nonprofit rates are available). As a nonprofit organization with limited resources, we are unable to offer free private tours. We thank you for your support and your understanding as we try to provide as many private group tours as possible. The Atlanta BeltLine Partnership’s tour program operates with a natural gas-powered, ADA accessible tour bus funded through contributions from 10th & Monroe, LLC, SunTrust Bank Trusteed Foundations – Florence C. and Harry L. English Memorial Fund and Thomas Guy Woolford Charitable Trust, and AGL Resources' );
CALL create_event('Inman Park', 'Arboretum Walking Tour', '2019-02-08', '2019-02-11', 1, 5.00, 5, 'Official Atlanta BeltLine Arboretum Walking Tours provide an up-close view of the Westside Trail and the Atlanta BeltLine Arboretum led by Trees Atlanta Docents. The one and a half hour tours step off at at 10am (Oct thru May), and 9am (June thru September). Departure for all tours is from Rose Circle Park near Brown Middle School. More details at: https://beltline.org/visit/atlanta-beltline-tours/#arboretum-walking' );
CALL create_event('Inman Park', 'Official Atlanta BeltLine Bike Tour', '2019-02-09', '2019-02-14', 1, 5.00, 5, 'These tours will include rest stops highlighting assets and points of interest along the Atlanta BeltLine. Staff will lead the rides, and each group will have a ride sweep to help with any unexpected mechanical difficulties.' );

CALL create_transit('MARTA', 'Blue', 2.00 );
CALL create_transit('BUS', '152', 2.00 );
CALL create_transit('BIKE', 'Relay', 1.00 );

CALL connect_site('MARTA', 'Blue', 'Inman Park' );
CALL connect_site('MARTA', 'Blue', 'Piedmont Park' );
CALL connect_site('MARTA', 'Blue', 'Historic Fourth Ward Park' );
CALL connect_site('MARTA', 'Blue', 'Westview Cemetery' );
CALL connect_site('BUS', '152', 'Inman Park' );
CALL connect_site('BUS', '152', 'Piedmont Park' );
CALL connect_site('BUS', '152', 'Historic Fourth Ward Park' );
CALL connect_site('BIKE', 'Relay', 'Piedmont Park' );
CALL connect_site('BIKE', 'Relay', 'Historic Fourth Ward Park' );

CALL take_transit('manager2', 'Blue', 'MARTA', '2019-03-20' );
CALL take_transit('manager2', '152', 'BUS', '2019-03-20' );
CALL take_transit('manager3', 'Relay', 'BIKE', '2019-03-20' );
CALL take_transit('manager2', 'Blue', 'MARTA', '2019-03-21' );
CALL take_transit('maria.hernandez', '152', 'BUS', '2019-03-20' );
CALL take_transit('maria.hernandez', 'Relay', 'BIKE', '2019-03-20' );
CALL take_transit('manager2', 'Blue', 'MARTA', '2019-03-22' );
CALL take_transit('maria.hernandez', '152', 'BUS', '2019-03-22' );
CALL take_transit('mary.smith', 'Relay', 'BIKE', '2019-03-23' );
CALL take_transit('visitor1', 'Blue', 'MARTA', '2019-03-21' );

CALL assign_staff('Piedmont Park', 'Eastside Trail', '2019-02-04', 'michael.smith' );
CALL assign_staff('Piedmont Park', 'Eastside Trail', '2019-02-04', 'staff1' );
CALL assign_staff('Inman Park', 'Eastside Trail', '2019-02-04', 'robert.smith' );
CALL assign_staff('Inman Park', 'Eastside Trail', '2019-02-04', 'staff2' );
CALL assign_staff('Inman Park', 'Eastside Trail', '2019-03-01', 'staff1' );
CALL assign_staff('Historic Fourth Ward Park', 'Eastside Trail', '2019-02-13', 'michael.smith' );
CALL assign_staff('Westview Cemetery', 'Westside Trail', '2019-02-18', 'staff1' );
CALL assign_staff('Westview Cemetery', 'Westside Trail', '2019-02-18', 'staff3' );
CALL assign_staff('Inman Park', 'Bus Tour', '2019-02-01', 'michael.smith' );
CALL assign_staff('Inman Park', 'Bus Tour', '2019-02-01', 'staff2' );
CALL assign_staff('Inman Park', 'Bus Tour', '2019-02-08', 'robert.smith' );
CALL assign_staff('Inman Park', 'Bus Tour', '2019-02-08', 'michael.smith' );
CALL assign_staff('Inman Park', 'Private Bus Tour', '2019-02-01', 'robert.smith' );
CALL assign_staff('Inman Park', 'Arboretum Walking Tour', '2019-02-08', 'staff3' );
CALL assign_staff('Inman Park', 'Official Atlanta BeltLine Bike Tour', '2019-02-09', 'staff1' );

CALL log_event('Historic Fourth Ward Park', 'Eastside Trail', '2019-02-13', 'mary.smith', '2019-02-13' );
CALL log_event('Historic Fourth Ward Park', 'Eastside Trail', '2019-02-13', 'mary.smith', '2019-02-14' );
CALL log_event('Historic Fourth Ward Park', 'Eastside Trail', '2019-02-13', 'visitor1', '2019-02-14' );
CALL log_event('Inman Park', 'Official Atlanta BeltLine Bike Tour', '2019-02-09', 'visitor1', '2019-02-10' );
CALL log_event('Inman Park', 'Bus Tour', '2019-02-01', 'mary.smith', '2019-02-01' );
CALL log_event('Inman Park', 'Bus Tour', '2019-02-01', 'maria.garcia', '2019-02-02' );
CALL log_event('Inman Park', 'Bus Tour', '2019-02-01', 'manager2', '2019-02-02' );
CALL log_event('Inman Park', 'Bus Tour', '2019-02-01', 'manager4', '2019-02-01' );
CALL log_event('Inman Park', 'Bus Tour', '2019-02-01', 'manager5', '2019-02-02' );
CALL log_event('Inman Park', 'Bus Tour', '2019-02-01', 'staff2', '2019-02-02' );
CALL log_event('Inman Park', 'Private Bus Tour', '2019-02-01', 'mary.smith', '2019-02-01' );
CALL log_event('Inman Park', 'Private Bus Tour', '2019-02-01', 'mary.smith', '2019-02-02' );
CALL log_event('Inman Park', 'Official Atlanta BeltLine Bike Tour', '2019-02-09', 'mary.smith', '2019-02-10' );
CALL log_event('Inman Park', 'Arboretum Walking Tour', '2019-02-08', 'mary.smith', '2019-02-10' );
CALL log_event('Piedmont Park', 'Eastside Trail', '2019-02-04', 'mary.smith', '2019-02-04' );
CALL log_event('Westview Cemetery', 'Westside Trail', '2019-02-18', 'mary.smith', '2019-02-19' );
CALL log_event('Westview Cemetery', 'Westside Trail', '2019-02-18', 'visitor1', '2019-02-19' );

CALL log_site('Atlanta Beltline Center', 'mary.smith', '2019-02-01' );
CALL log_site('Atlanta Beltline Center', 'mary.smith', '2019-02-10' );
CALL log_site('Atlanta Beltline Center', 'visitor1', '2019-02-13' );
CALL log_site('Atlanta Beltline Center', 'visitor1', '2019-02-09' );
CALL log_site('Historic Fourth Ward Park', 'mary.smith', '2019-02-02' );
CALL log_site('Historic Fourth Ward Park', 'visitor1', '2019-02-11' );
CALL log_site('Inman Park', 'mary.smith', '2019-02-01' );
CALL log_site('Inman Park', 'mary.smith', '2019-02-02' );
CALL log_site('Inman Park', 'mary.smith', '2019-02-03' );
CALL log_site('Inman Park', 'visitor1', '2019-02-01' );
CALL log_site('Piedmont Park', 'mary.smith', '2019-02-02' );
CALL log_site('Piedmont Park', 'visitor1', '2019-02-11' );
CALL log_site('Piedmont Park', 'visitor1', '2019-02-01' );
CALL log_site('Westview Cemetery', 'visitor1', '2019-02-06' );