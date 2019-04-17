DELIMITER $$

CREATE PROCEDURE test1(in user_name varchar(50), in pass_word varchar(100), in first_name varchar(50), in last_name varchar(50), in is_visitor int, out error varchar(300)) 
-- order of parameter
-- username, password, firstname, lastname, is_visitor
-- is_visitor's value shall be 0 or 1 (0 for "Yes", 1 for "No")
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS @num = NUMBER;
        GET DIAGNOSTICS condition @num @error = MESSAGE_TEXT;
        SIGNAL SQLSTATE '45000' SET message_text = error;
    END;
    IF EXISTS(SELECT * FROM USERS WHERE UserName = user_name) THEN 
        SET error = "Username already exists.";
        SIGNAL SQLSTATE '45000' SET message_text = error;
    ELSE
        IF is_visitor != 1 AND is_visitor != 0 THEN
            SET error = "IsVisitor is out of range.";
            SIGNAL SQLSTATE '45000' SET message_text = error;
        ELSE 
            SET is_visitor = is_visitor + 1;
            INSERT INTO Users(UserName, Password, FirstName, LastName, IsVisitor) 
                VALUES(user_name, pass_word, first_name, last_name, is_visitor);
        END IF;
    END IF;
END $$

CREATE PROCEDURE test2(in user_name varchar(100), out error varchar(300))
-- order of parameter
-- username
BEGIN 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS @num = NUMBER;
        GET DIAGNOSTICS condition @num @error = MESSAGE_TEXT;
        SIGNAL SQLSTATE '45000' SET message_text = error;
    END;
    IF length(user_name) > 0 THEN
        SELECT EmailAddress, UserName FROM Email WHERE UserName = user_name;
    ELSE 
        SET error = "Username cannot be null.";
        SIGNAL SQLSTATE '45000' SET message_text = error;
    END IF;
END $$


CREATE PROCEDURE test3(in user_name varchar(50), in email_address varchar(100), out error varchar(300))
-- order of parameter
-- username, emailaddress
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS @num = NUMBER;
        GET DIAGNOSTICS condition @num @error = MESSAGE_TEXT;
        SIGNAL SQLSTATE '45000' SET message_text = error;
    END;
    INSERT INTO Email VALUES(email_address, user_name);
END $$


CREATE PROCEDURE test4(in email_address varchar(100), out error varchar(300))
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
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        GET DIAGNOSTICS @num = NUMBER;
        GET DIAGNOSTICS condition @num @error = MESSAGE_TEXT;
        SIGNAL SQLSTATE '45000' SET message_text = error;
    END;
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
        SIGNAL SQLSTATE '45000' SET message_text = error;
    END IF;
    SELECT user_name, pass_word, status_, first_name, last_name, is_visitor, is_employee;
END $$