DELIMITER $$
CREATE PROCEDURE screen_one_login(in email_address varchar(100), in pass_word varchar(100))
BEGIN
	DECLARE username varchar(50);
	SET @result = " ";
	SET username = (SELECT UserName FROM Email WHERE EmailAddress LIKE email_address LIMIT 1);
	IF (SELECT username IS NULL) THEN 
		SET @result = "Email address does not exist.";
	ELSE
		IF (SELECT Password FROM Users WHERE UserName LIKE username LIMIT 1) = pass_word THEN
			SET @result = "Logging in successfully.";
		ELSE
			SET @result = "Password is wrong.";
		END IF;
	END IF;
	SELECT @result;
END $$

-- Correct way to call it

-- SET @a = "/*your email address*/";
-- SET @b = "/*your password after hashing*/";
-- CALL screen_one_login(@a, @b);

-- Then it will return the information about logina