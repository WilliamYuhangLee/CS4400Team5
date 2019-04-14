USE cs4400;

DELIMITER $$



CREATE PROCEDURE login(in email_address varchar(100))
-- order of parameter
-- email address, password
BEGIN
	DECLARE username varchar(50);
	SET @result = "";
	SET username = (SELECT UserName FROM Email WHERE EmailAddress LIKE email_address LIMIT 1);
	IF (SELECT username IS NULL) THEN 
		SET @result = "Email address does not exist.";
	ELSE
        SET @result = (SELECT Password FROM Users WHERE UserName LIKE username LIMIT 1);
	END IF;
	SELECT @result;
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



CREATE PROCEDURE register_user(in user_name varchar(50), in pass_word varchar(100), in first_name varchar(50), in last_name varchar(50), in is_visitor int) 
-- order of parameter
-- username, password, firstname, lastname, is_visitor
-- is_visitor's value shall be 1 or 2 (1 for "Yes", 2 for "No")
BEGIN
    SET @result = "";
    IF EXISTS(SELECT * FROM USERS WHERE UserName = user_name) THEN 
        SET @result = "Username already exists.";
    ELSE
        IF is_visitor != 1 OR is_visitor != 2 THEN
            SET @result = "IsVisitor is out of range.";
        ELSE 
            INSERT INTO Users(UserName, Password, FirstName, LastName, IsVisitor) 
                VALUES(user_name, pass_word, firs_name, last_name, is_visitor);
            SET @result = "Registering successfully.";
        END IF;
    END IF;
    SELECT @result;
END $$



CREATE PROCEDURE register_employee(in user_name varchar(50), in phone_ char(10), in city_ varchar(100), in address_ varchar(100),  in state varchar(5), in zip_code char(5), in title_ int) 
-- order of parameter
-- username, phone, city, address, state, zipcode, employee type
-- state's value shall be the abbreviation of states in uppercase or be 'other'
-- title's value shall be 1 or 2 (1 for "Manager", 2 for "Staff")
-- this procedure require a register_user() to be called before it
BEGIN
    DECLARE new_title int;
    SET new_title = title_ + 1;
    INSERT INTO Employee(Username, Phone, Address, City, State, ZipCode, Title) VALUES(@currentuser, phone_, address_, city_, state_, new_title);
END $$



CREATE PROCEDURE add_email(in user_name varchar(50), in email_address varchar(100))
-- order of parameter
-- username, emailaddress
BEGIN
    INSERT INTO Email VALUES(user_name, email_address);
END $$


CREATE PROCEDURE delete_email(in email_address varchar(100))
-- order of parameter
-- emailaddress
BEGIN
    DELETE FROM Email WHERE EmailAddress LIKE email_address;
END $$



CREATE PROCEDURE take_tansit(in user_name varchar(50), in route_ varchar(20), in transport_type int(1), in take_date date)
-- order of parameter
-- username, route, transport type, date
-- transport_type's value shall be 1, 2, or 3 (1 for "MARTA", 2 for "Bus", 3 for "Bike")
BEGIN
    INSERT INTO Take VALUES(user_name, route_, transport_type, take_date);
END $$


CREATE PROCEDURE edit_profile(in user_name varchar(50), in first_name varchar(50), in last_name varchar(50), in is_visitor int(1), in phone_ char(10))
-- order of parameter
-- username, first name, last name, is visitor, phone
-- is_visitor's value shall be 1 or 2 (1 for "Yes", 2 for "No")
BEGIN
    UPDATE Users 
    SET FirstName = first_name, LastName = last_name, IsVisitor = is_visitor 
    WHERE UserName LIKE user_name;
    UPDATE Employee
    SET Phone = phone_ 
    WHERE UserName LIKE user_name;
END $$


CREATE PROCEDURE manage_user(in user_name varchar(50), in new_status int(1))
-- order of parameters
-- username, new status
-- new_status' value should be 1 or 2 (1 for "Denied", 2 for "Approval")
BEGIN
    DECLARE status_ int;
    DECLARE em_id int(9);
    SET status_ = new_status + 1;
    IF new_status != 1 && new_status != 2 THEN
        SET @result = "New status out of range.";
    ELSE
        IF ("Approval" IN (SELECT `Status` FROM Users WHERE UserName = user_name)) AND (new_status = 1) THEN 
            SET @result = "Cannot deny an approved user.";
        ELSE
            UPDATE Users SET Status = status_ WHERE UserName = user_name;
            IF EXISTS(SELECT * FROM Employee WHERE UserName = user_name) AND (SELECT EmployeeID FROM Employee WHERE UserName = user_name = null) AND status_ = 3 THEN                
                SET em_id = 000000001;
                WHILE EXISTS(SELECT * FROM Employee WHERE EmployeeID = em_id) DO
                    SET em_id = em_id + 1;
                END WHILE;
                UPDATE Employee SET EmployeeID = em_id WHERE UserName = user_name;
            END IF;            
            SET @result = "Successfully changed the status.";
        END IF;
    END IF;
    SELECT @result;
END $$


CREATE PROCEDURE edit_site(in site_name varchar(50), in zip_code varchar(5), in address_ varchar(100), in manager_name varchar(50), in open_every_day int(1))
-- order of parameter
-- site name, zipcode, address, manager name, if open everyday
-- open_every_day's value shall be 1 or 2 (1 for yes, 2 for no)
BEGIN
    UPDATE Site 
    SET Zipcode = zip_code, Address = address_, ManagerName = manager_name, EveryDay = open_every_day 
    WHERE SiteName = site_name;
END $$


CREATE PROCEDURE create_site(in site_name varchar(50), in zip_code varchar(5), in address_ varchar(100), in manager_name varchar(50), in open_every_day int(1))
-- order of parameter
-- site name, zipcode, address, manager name, if open everyday
-- open_every_day's value shall be 1 or 2 (1 for yes, 2 for no)
BEGIN
    INSERT INTO Site VALUES(site_name, zip_code, address_, open_every_day, manager_name);
END $$


CREATE PROCEDURE edit_transit(in transport_type int, in old_route varchar(20), in new_route varchar(20), in price_ float)
-- order of parameter
-- transport type, old route, new route , price
-- transport_type's value shall be 1, 2, or 3 (1 for MARTA, 2 for Bus, 3 for Bike)
-- if the route has no change, new_route and old_route shall have the same value
BEGIN
    UPDATE Transit 
    SET Route = new_route, Price = price_ 
    WHERE TransportType = transport_type AND Route = old_route;
END $$


CREATE PROCEDURE create_transit(in transport_type int, in route_ varchar(20), in price_ float)
-- order of parameter
-- transport type, route, price
-- transport_type's value shall be 1, 2, or 3 (1 for MARTA, 2 for Bus, 3 for Bike)
BEGIN
    INSERT INTO Transit VALUES(route_, transport_type, price_);
END $$


CREATE PROCEDURE connect_site(in transport_type int, in route_ varchar(20), in site_name varchar(50))
-- order of parameter
-- transport type, route, site_name
-- transport_type's value shall be 1, 2, or 3 (1 for MARTA, 2 for Bus, 3 for Bike)
BEGIN
    IF ! EXISTS(SELECT * FROM Connects WHERE TransportType = transport_type AND Route = route_ AND SiteName = site_name) THEN 
        INSERT INTO Connects VALUES(route_, transport_type, site_name);
    END IF;
END $$


CREATE PROCEDURE disconnect_site(in transport_type int, in route_ varchar(20), in site_name varchar(50))
-- order of parameter
-- transport type, route, site_name
-- transport_type's value shall be 1, 2, or 3 (1 for MARTA, 2 for Bus, 3 for Bike)
BEGIN
    IF EXISTS(SELECT * FROM Connects WHERE TransportType = transport_type AND Route = route_ AND SiteName = site_name) THEN 
        DELETE FROM Connects WHERE TransportType = transport_type AND Route = route_ AND SiteName = site_name;
    END IF;
END $$


CREATE PROCEDURE edit_evetn(in site_name varchar(50), in event_name varchar(50), in start_date date, in description_ text)
-- order of parameter
-- site name, event name, start date, new discription
BEGIN 
    UPDATE `Events` 
    SET Description = description_ 
    WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date;
END $$


CREATE PROCEDURE create_event(in site_name varchar(50), in event_name varchar(50), in start_date date, in end_date date, in min_staff_req int, in price_ float, in capacity_ int, in description_ text)
-- order of parameter
-- site name, event name, start date, end date, minimun staff requirment, price, capacity, discription
BEGIN
    INSERT INTO Events VALUES(site_name, event_name, start_date, end_date, min_staff_req, price_, capacity_, description_);
END $$


CREATE PROCEDURE assign_staff(in site_name varchar(50), in event_name varchar(50), in start_date date, in staff_name varchar(50))
-- order of parameter
-- site name, event name, start date, staff name
BEGIN
    IF ! EXISTS(SELECT * FROM AssignTo WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND StaffName = staff_name) THEN 
        INSERT INTO AssignTo VALUES(staff_name, site_name, event_name, start_date);
    END IF;
END $$


CREATE PROCEDURE remove_staff(in site_name varchar(50), in event_name varchar(50), in start_date date, in staff_name varchar(50))
-- order of parameter
-- site name, event name, start date, staff name
BEGIN 
    IF EXISTS(SELECT * FROM AssignTo WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND StaffName = staff_name) THEN 
        DELETE FROM AssignTo WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND StaffName = staff_name;
    END IF;
END $$


CREATE PROCEDURE log_event(in site_name varchar(50), in event_name varchar(50), in start_date date, in user_name varchar(50), in log_date date)
-- order of parameter
-- site name, event name, start date, user name, visit date
BEGIN 
    INSERT INTO VisitEvent VALUES(user_name, site_name, event_name, start_date, log_date);
END $$


CREATE PROCEDURE log_site(in site_name varchar(50), in user_name varchar(50), in log_date date)
-- order of parameter
-- site name, user name, visit date
BEGIN 
    INSERT INTO VisitSite VALUES(user_name, site_name, log_date);
END $$



DELIMITER ;