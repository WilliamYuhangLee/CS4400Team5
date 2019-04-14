USE cs4400;
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
	DECLARE NewPrimaryEmail varchar(100);

	IF (SELECT count(*) FROM Email WHERE UserName LIKE OLD.UserName) = 1 THEN
		SET ermsg = 'The Only Email Of This User, Connot Delete!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

	SELECT EmailAddress FROM Email WHERE UserName = OLD.UserName AND EmailAddress != OLD.EmailAddress LIMIT 1 INTO NewPrimaryEmail;
	UPDATE TABLE Users SET PrimaryEmail = NewPrimaryEmail WHERE UserName = OLD.UserName;
    
END $$



CREATE TRIGGER tgr4_site1 BEFORE INSERT ON Site FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	DECLARE holder varchar(50);

	SET holder = (SELECT title FROM employee WHERE UserName LIKE NEW.ManagerName LIMIT 1);
	IF holder NOT LIKE 'Manager' THEN
		SET ermsg = 'Invalid Manager Assignment!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;
END $$



CREATE TRIGGER tgr5_site2 BEFORE UPDATE ON Site FOR EACH ROW
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
	DECLARE NewPrimarySite varchar(50);
	DECLARE OneRoute varchar(20);
	DECLARE OneTT varchar(20);

	IF (SELECT count(*) FROM 
            (SELECT Num, SiteName FROM
                (SELECT count(*) AS Num, SiteName FROM Connects JOIN Transit USING (TransportType, Route) GROUP BY (TransportType, Route)) AS x
             WHERE Num = 1 AND SiteName LIKE OLD.SiteName) AS y
        LIMIT 1 ) > 0 THEN
		SET ermsg = 'The Only Site Of Some Transit, Connot Delete!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

	WHILE (SELECT count(*) FROM Transit WHERE PrimarySite = OLD.SiteName) > 0 DO
		SELECT Route, TransportType FROM Transit WHERE PrimarySite = OLD.SiteName LIMIT 1 INTO OneRoute, OneTT;
		SELECT SiteName FROM Connects WHERE Route = OneRoute AND TransportType = OneTT AND SiteName != OLD.SiteName LIMIT 1 INTO NewPrimarySite;
		UPDATE TABLE Transit SET PrimarySite = NewPrimarySite WHERE Route = OneRoute AND TransportType = OneTT;
	END WHILE

END $$



CREATE TRIGGER tgr7_event1 BEFORE INSERT ON Events FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	SET ermsg = "Invalid Event, Having Time Overlapping!!";

	IF NEW.EndDate < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Invalid Date, Ending Is Earlier Than Beginning!!";
	END IF;

	IF NEW.EndDate <= ANY (SELECT StartDate FROM Events WHERE SiteName LIKE NEW.SiteNAme 
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

	IF (SELECT Title FROM EMPLOYEE WHERE UserName LIKE NEW.PrimaryStaff) NOT LIKE 'Staff' THEN
		SIGNAL SQLSTATE '45000' SET message_text = "The Primary Staff Is Not A Staff!!";
	ELSE
		INSERT INTO AssignTo VALUES (NEW.PrimaryStaff, NEW.SiteName, NEW.EventName, NEW.StartDate);
	END IF

END $$



CREATE TRIGGER tgr8_event2 BEFORE UPDATE ON Events FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);
	SET ermsg = "Invalid Event, Having Time Overlapping!!";

	IF NEW.EndDate < NEW.StartDate THEN
		SIGNAL SQLSTATE '45000' SET message_text = 
			"Invalid Date, Ending Is Earlier Than Beginning!!";
	END IF;

	IF NEW.EndDate <= ANY (SELECT StartDate FROM Events WHERE SiteName LIKE NEW.SiteNAme 
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
		SIGNAL SQLSTATE '45000' SET message_text = 
			"Minimun Number of Required Staffs Cannot Be Less Than One!!";
	END IF;

	IF NEW.Price < 0 Then
		SIGNAL SQLSTATE '45000' SET message_text = "Price Cannot Be Negative!!";
	END IF;

	IF NEW.Capacity < 1 THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Capacity Cannot Be Less Than One!!";
	END IF;

	IF (SELECT Title FROM EMPLOYEE WHERE UserName LIKE NEW.PrimaryStaff) NOT LIKE 'Staff' THEN
		SIGNAL SQLSTATE '45000' SET message_text = "The Primary Staff Is Not A Staff!!";
	ELSE
		IF OLD.PrimaryStaff NOT LIKE NEW.PrimaryStaff AND
			NEW.PrimaryStaff NOT IN (SELECT StaffName FROM AssignTo WHERE SiteName = OLD.SiteName
										AND EventName = OLD.EventName
										AND StartDate = OLD.StartDate) THEN
			INSERT INTO AssignTo VALUES (NEW.PrimaryStaff, OLD.SiteName, 
							OLD.EventName, OLD.StartDate);
			DELETE FROM AssignTo WHERE SiteName = OLD.SiteName 
						AND EventName = OLD.EventName 
						AND StartDate = OLD.StartDate 
						AND StaffName = OLD.PrimaryStaff;
		END IF;
	END IF
END $$



CREATE TRIGGER tgr9_vs1 BEFORE INSERT ON VisitSite FOR EACH ROW
BEGIN
	IF (SELECT IsVisitor FROM Users WHERE UserName LIKE NEW.UserName LIMIT 1) LIKE "No" THEN
		SIGNAL SQLSTATE '45000' SET message_text = "The User Is Not A Visitor!!";
	END IF;
END $$



CREATE TRIGGER tgr10_vs2 BEFORE UPDATE ON VisitSite FOR EACH ROW
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
						AND StartDate = NEW.StartDate) THEN
		SIGNAL SQLSTATE '45000' SET message_text = "Visiting After End Date!!!";
	END IF;

	INSERT INTO VisitSite VALUES (NEW.UserName, NEW.SiteName, NEW.Date);
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

	DELETE FROM VisitSite WHERE UserName LIKE OLD.UserName 
			AND SiteName LIKE OLD.SiteName 
			AND Date = OLD.Date;
	INSERT INTO VisitSite VALUES (NEW.UserName, NEW.SiteName, NEW.Date);
END $$



CREATE TRIGGER tgr13_at1 BEFORE INSERT ON AssignTo FOR EACH ROW
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




CREATE TRIGGER tgr14_at2 BEFORE UPDATE ON AssignTo FOR EACH ROW
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
                    AND StartDate = OLD.StartDate) = 1 THEN
		SET ermsg = 'The Only Site Of This Transit, Connot Delete!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
	END IF;

END $$



CREATE TRIGGER tgr16_connect1 BEFORE DELETE ON Connects FOR EACH ROW
BEGIN
	DECLARE ermsg varchar(100);

	IF (SELECT count(*) FROM Connects WHERE Route = OLD.Route 
					AND TransportType = OLD.TransportType) = 1 THEN
		SET ermsg = 'The Only Site Of This Transit, Connot Delete!!';
		SIGNAL SQLSTATE '45000' SET message_text = ermsg;
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



CREATE TRIGGER tgr19_employee1 BEFORE DELETE ON Employee FOR EACH ROW
BEGIN
    DECLARE OneSN varchar(100);
    DECLARE OneEN varchar(100);
    DECLARE OneST date;
    DECLARE OneStaff varchar(100);
    
    IF OLD.Title = 'Staff' THEN
        IF SELECT count(*) FROM 
            (SELECT Num, StaffName FROM 
                (SELECT count(*) AS Num, StaffName FROM AssignTo GROUP BY (SiteName, EventName, StartDate)) AS x
                WHERE Num = 1 AND StaffName = OLD.StaffName) AS y
                > 0 THEN
            SIGNAL SQLSTATE '45000' SET message_text = 'The Only Staff For Some Event, Cannot Delete!!';
        END IF;
        
        WHILE (SELECT count(*) FROM Events WHERE PrimaryStaff = OLD.UserName) > 0 DO
            SELECT SiteName, EventName, StartDate FROM Events WHERE PrimaryStaff = OLD.UserName LIMIT 1 INTO OneSN, OneEN, OneST;
            SELECT StaffName FROM AssignTo WHERE SiteName = OneSN AND EventName = OneEN AND StartDate = OneST AND StaffName != OLD.UserName LIMIT 1 INTO OneStaff;
            UPDATE TABLE Events SET PrimaryStaff = OneStaff WHERE SiteName = OneSN AND EventName = OneEN AND StartDate = OneST;
	   END WHILE
    END IF;
END $$



CREATE TRIGGER tgr20_employee2 BEFORE UPDATE ON Employee FOR EACH ROW
BEGIN
    IF OLD.Title != NEW.Title THEN
        SIGNAL SQLSTATE '45000' SET message_text = 'Cannot Change The Title Of The Employee!!';
    END IF;
END $$



CREATE TRIGGER stgr1_user1 AFTER INSERT ON Users FOR EACH ROW
BEGIN
    INSERT INTO Email VALUES (NEW.PrimaryEmail, NEW.UserName);
END $$



CREATE TRIGGER stgr2_user2 BEFORE UPDATE ON Users FOR EACH ROW
BEGIN
    IF OLD.PrimaryEmail NOT LIKE NEW.PrimaryEmail AND
        NEW.PrimaryEmail NOT IN (SELECT EmailAddress FROM Email WHERE UserName = OLD.UserName) THEN
        INSERT INTO Email VALUES (NEW.PrimaryEmail, OLD.UserName);
        DELETE FROM Email WHERE UserName = OLD.UserName  
                    AND EmailAddress = OLD.PrimaryEmail;
    END IF;
END $$

DELIMITER ;