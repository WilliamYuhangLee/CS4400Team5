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
        SELECT SiteName INTO site_name FROM Site WHERE ManagerName = user_name LIMIT 1;
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
    
    SELECT UserName INTO user_name FROM Email WHERE EmailAddress = email_address LIMIT 1;
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
        SELECT Zipcode, Address, EveryDay, ManagerName INTO zip_code, address_, every_day, manager_name FROM Site WHERE SiteName = site_name LIMIT 1;
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
    SELECT UserName, FirstName, LastName FROM Employee JOIN Users USING(UserName) WHERE Title = "MANAGER" AND UserName NOT IN (SELECT ManagerName FROM Site);
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


CREATE PROCEDURE filter_visit_history(in user_name varchar(100))
BEGIN
    IF length(user_name) > 0 THEN
        (SELECT UserName, Date, SiteName, EventName, Price FROM visit_history WHERE UserName = user_name) UNION (SELECT UserName, Date, SiteName, "Null", 0.00 FROM visitsite WHERE UserName = user_name);
    ELSE 
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE delete_event(in site_name varchar(50), in event_site varchar(50), in start_date date)
BEGIN
    DELETE FROM Events WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date;
END $$


DELIMITER ;