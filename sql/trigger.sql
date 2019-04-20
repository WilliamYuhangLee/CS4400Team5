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
    -- IF EXISTS(SELECT * FROM VisitSite WHERE SiteName = NEW.SiteName AND UserName = NEW.UserName AND `Date` = NEW.Date) THEN
    --     DELETE FROM VisitSite WHERE SiteName = NEW.SiteName AND UserName = NEW.UserName AND `Date` = NEW.Date;
    -- END IF;
END $$


-- If new username not belong to a visitor, error is vocated
CREATE TRIGGER tgr10_vs2 BEFORE UPDATE ON VisitSite FOR EACH ROW
BEGIN
	IF (SELECT IsVisitor FROM Users WHERE UserName LIKE NEW.UserName LIMIT 1) LIKE 'No' THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'This user is not a visitor.';
	END IF;
END $$


-- Making sure that new visit date is between start and end date
-- Automatically add new row to VisitSite with the same user and same date
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
    
    IF NOT EXISTS(SELECT * FROM VisitSite WHERE UserName LIKE NEW.UserName AND SiteName LIKE NEW.SiteName AND `Date` = NEW.Date) THEN
	   INSERT INTO VisitSite VALUES (NEW.UserName, NEW.SiteName, NEW.Date);
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

	DELETE FROM VisitSite WHERE UserName LIKE OLD.UserName AND SiteName LIKE OLD.SiteName AND Date = OLD.Date;

    IF NOT EXISTS(SELECT * FROM VisitSite WHERE UserName LIKE NEW.UserName AND SiteName LIKE NEW.SiteName AND `Date` = NEW.Date) THEN
	   INSERT INTO VisitSite VALUES (NEW.UserName, NEW.SiteName, NEW.Date);
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
