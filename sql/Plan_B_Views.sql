USE cs4400;

DELIMITER $$
CREATE FUNCTION get_type(em_title int, is_visitor int) RETURNS varchar(20)
BEGIN
    IF em_title = 1 THEN
            RETURN "Administrator";
    ELSE 
        IF em_title = 2 THEN 
            RETURN "Manager";
        ELSE
            IF em_title = 3 THEN 
                RETURN "Staff";
            ELSE
                IF is_visitor = 1 THEN 
                    RETURN "Visitor";
                ELSE 
                    RETURN "User";
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
GROUP BY UserName HAVING IsVisitor = "Yes";

CREATE VIEW event_visit_num AS 
SELECT UserName, FirstName, LastName, count(*) AS NumMyEventVisit, IsVisitor 
FROM VisitEvent LEFT JOIN Users USING(UserName) 
GROUP BY UserName HAVING IsVisitor = "Yes";

CREATE VIEW for_visitor AS 
SELECT UserName, FirstName, LastName, NumMySiteVisit, NumMyEventVisit 
FROM site_visit_num LEFT JOIN event_visit_num USING(UserName, FirstName, LastName);

CREATE VIEW for_staff AS 
SELECT UserName, EmployeeID, count(*) AS NumEventShifts, Title 
FROM Employee LEFT JOIN AssignTo ON Employee.UserName = AssignTo.StaffName 
GROUP BY UserName HAVING Title = "Staff";

CREATE VIEW tansit_logged_num AS 
SELECT Route, TransportType, count(*) AS NumLogged 
FROM Transit LEFT JOIN Take USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW transit_connect_num AS 
SELECT Route, TransportType, count(*) AS NumConnected, Price 
FROM Transit LEFT JOIN Connects USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW for_transit AS 
SELECT Route, TransportType, Price, NumLogged, NumConnected 
FROM tansit_logged_num LEFT JOIN transit_connect_num USING(Route, TransportType);

CREATE VIEW event_staff_num AS 
SELECT SiteName, EventName, StartDate, count(*) AS StaffCount 
FROM Events LEFT JOIN AssignTo USING(SiteName, EventName, StartDate) 
GROUP BY SiteName, EventName, StartDate;

CREATE VIEW daily_visit_event AS 
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, count(*) AS DailyVisit 
FROM Events LEFT JOIN VisitEvent USING(SiteName, EventName, StartDate) 
GROUP BY SiteName, EventName, StartDate, `Date`;

CREATE VIEW daily_event AS
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, DailyVisit, (DailyVisit * Price) AS DailyRevenue 
FROM daily_visit_event;

CREATE VIEW for_event AS 
SELECT SiteName, EventName, StartDate, Events.Price, count(DailyVisit) AS TotalVisit, count(DailyRevenue) AS TotalRevenue, (Capacity - count(DailyRevenue)) AS TicketRem, (Events.EndDate - StartDate) AS Duration 
FROM daily_event LEFT JOIN Events USING(SiteName, EventName, StartDate)
GROUP BY `Date`;

CREATE VIEW daily_site AS 
SELECT SiteName, `Date`, count(DailyVisit) AS DailyVisit, count(DailyRevenue) AS DailyRevenue
FROM daily_event LEFT JOIN Site USING(SiteName) 
GROUP BY SiteName, `Date`;

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
SELECT SiteName, TotalVisit, TotalRevenue, CountStaff, count(*) AS CountEvent, ManagerName 
FROM total_site LEFT JOIN count_site_staff USING(SiteName) JOIN Events USING(SiteName) JOIN Site USING(SiteName) 
GROUP BY SiteName;

CREATE VIEW visit_one_event AS
SELECT UserName, EventName, SiteName, Price, TicketRem, TotalVisit, count(*) AS MyVisit
FROM for_event FULL JOIN VisitEvent USING(SiteName, EventName, StartDate)
GROUP BY UserName, EventName, SiteName, StartDate;

CREATE VIEW visit_one_site AS
SELECT UserName, SiteName, CountEvent, TotalVisit, count(*) AS MyVisit 
FROM for_site FULL JOIN VisitSite USING(SiteName) 
GROUP BY UserName, SiteName;

CREATE VIEW visit_hisotry_pre AS
(SELECT `Date`, SiteName, UserName FROM VisitSite) UNION (SELECT `Date`, SiteName, UserName FROM VisitEvent);

CREATE VIEW visit_history AS
SELECT `Date`, EventName, SiteName, Price, UserName
FROM VisitEvent FULL JOIN visit_hisotry_pre USING(`Date`, SiteName, UserName) LEFT JOIN EVENTS USING(SiteName, EventName, StartDate);