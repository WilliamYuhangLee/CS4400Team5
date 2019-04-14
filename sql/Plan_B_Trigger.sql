USE cs4400;
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

    IF SELECT Num FROM
    (SELECT count(*) FROM VisitSite WHERE UserName LIKE NEW.UserName AND SiteName LIKE NEW.SiteName AND 'Date' = NEW.Date)
    AS x LIMIT 1 > 0 THEN
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
