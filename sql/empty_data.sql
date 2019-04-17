DELIMITER ;

USE atlbeltline;

SET @force = "force delete";

DELETE FROM VisitEvent;
DELETE FROM VisitSite;
DELETE FROM AssignTo;
DELETE FROM Take;
DELETE FROM Connects;
DELETE FROM `Events`;
DELETE FROM Site;
DELETE FROM Transit;
DELETE FROM Employee;
DELETE FROM Email;
DELETE FROM Users;

SET @force = "not forece delete";