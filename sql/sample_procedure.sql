DELIMITER $$

CREATE PROCEDURE handle4(out error varchar(300))
BEGIN
    GET DIAGNOSTICS CONDITION 1
         @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
     SELECT @p2;
END $$

CREATE PROCEDURE handle3(out error varchar(300))
BEGIN
    GET DIAGNOSTICS CONDITION 1
         @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
     SET error = @p2;
     SIGNAL SQLSTATE '45000' SET message_text = error;
END $$

CREATE PROCEDURE register_user_test(in user_name varchar(50), in pass_word varchar(100), in first_name varchar(50), in last_name varchar(50), in is_visitor int, out error varchar(300)) 
-- order of parameter
-- username, password, firstname, lastname, is_visitor
-- is_visitor's value shall be 0 or 1 (0 for "Yes", 1 for "No")
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle3(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle4(error);
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

CREATE PROCEDURE query_email_by_username_test(in user_name varchar(100), out error varchar(300))
-- order of parameter
-- username
BEGIN   
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle3(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle4(error);
    IF length(user_name) > 0 THEN
        SELECT EmailAddress, UserName FROM Email WHERE UserName = user_name;
    ELSE 
        SET error = "Username cannot be null.";
        SIGNAL SQLSTATE '45000' SET message_text = error;
    END IF;
END $$


CREATE PROCEDURE add_email_test(in user_name varchar(50), in email_address varchar(100), out error varchar(300))
-- order of parameter
-- username, emailaddress
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle3(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle4(error);
    INSERT INTO Email VALUES(email_address, user_name);
END $$