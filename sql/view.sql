USE atlbeltline;

-- SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER $$
CREATE FUNCTION get_type(em_title int, is_visitor int) RETURNS varchar(20) DETERMINISTIC 
BEGIN
    IF em_title = 1 THEN
            RETURN 'Administrator';
    ELSE 
        IF em_title = 2 THEN 
            RETURN 'Manager';
        ELSE
            IF em_title = 3 THEN 
                RETURN 'Staff';
            ELSE
                IF is_visitor = 1 THEN 
                    RETURN 'Visitor';
                ELSE 
                    RETURN 'User';
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
GROUP BY UserName HAVING IsVisitor = 'Yes';

CREATE VIEW event_visit_num AS 
SELECT UserName, FirstName, LastName, count(*) AS NumMyEventVisit, IsVisitor 
FROM VisitEvent LEFT JOIN Users USING(UserName) 
GROUP BY UserName HAVING IsVisitor = 'Yes';

CREATE VIEW for_visitor AS 
SELECT UserName, FirstName, LastName, NumMySiteVisit, NumMyEventVisit 
FROM site_visit_num LEFT JOIN event_visit_num USING(UserName, FirstName, LastName);

CREATE VIEW for_staff_pre AS 
SELECT UserName, EmployeeID, count(*) AS NumEventShifts, Title 
FROM Employee LEFT JOIN AssignTo ON Employee.UserName = AssignTo.StaffName 
GROUP BY UserName HAVING Title = 'Staff';

CREATE VIEW for_staff AS
SELECT * FROM for_staff_pre JOIN AssignTO ON for_staff_pre.UserName = AssignTo.StaffName INNER JOIN Users USING (UserName) LEFT JOIN Events USING(SiteName, EventName, StartDate); 

CREATE VIEW transit_logged_num AS 
SELECT Route, TransportType, count(*) AS NumLogged 
FROM Transit LEFT JOIN Take USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW transit_connect_num AS 
SELECT Route, TransportType, count(*) AS NumConnected, Price 
FROM Transit LEFT JOIN Connects USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW for_transit AS 
SELECT Route, TransportType, Price, NumLogged, NumConnected 
FROM transit_logged_num LEFT JOIN transit_connect_num USING(Route, TransportType);

CREATE VIEW event_staff_num AS 
SELECT SiteName, EventName, StartDate, count(*) AS StaffCount 
FROM Events LEFT JOIN AssignTo USING(SiteName, EventName, StartDate) 
GROUP BY SiteName, EventName, StartDate;

CREATE VIEW daily_visit_event AS 
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, count(*) AS DailyVisit 
FROM `Events` INNER JOIN VisitEvent USING(SiteName, EventName, StartDate)
GROUP BY SiteName, EventName, StartDate, `Date`;

CREATE VIEW daily_event AS
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, DailyVisit, (DailyVisit * Price) AS DailyRevenue 
FROM daily_visit_event;

CREATE VIEW for_event_pre AS
SELECT SiteName, EventName, StartDate, count(*) AS CountStaff 
FROM AssignTo GROUP BY SiteName, EventName, StartDate;

CREATE VIEW for_event AS 
SELECT SiteName, EventName, StartDate, Events.Price, IF(DailyVisit >= 1, sum(DailyVisit), 0) AS TotalVisit, IF(DailyVisit >= 1, sum(DailyRevenue), 0) AS TotalRevenue, IF(DailyVisit >= 1, (Capacity - sum(DailyVisit)), Capacity) AS TicketRem, (Events.EndDate - StartDate + 1) AS Duration, Description, CountStaff, Events.EndDate   
FROM daily_event RIGHT JOIN Events USING(SiteName, EventName, StartDate) INNER JOIN for_event_pre USING (SiteName, EventName, StartDate)
GROUP BY SiteName, EventName, StartDate;


CREATE VIEW daily_visit_site AS 
SELECT SiteName, `Date`, count(*) AS DailyVisit, 0 AS DailyRevenue 
FROM VisitSite
GROUP BY SiteName,`Date`;

CREATE  VIEW daily_site_pre AS 
(SELECT * FROM daily_visit_site)
UNION
(SELECT SiteName, `Date`, sum(DailyVisit) AS DailyVisit, sum(DailyRevenue) AS DailyRevenue
FROM daily_event GROUP BY SiteName,`Date` );

CREATE  VIEW daily_site AS 
SELECT SiteName, `Date`, sum(DailyVisit) AS DailyVisit, sum(DailyRevenue) AS DailyRevenue
FROM daily_site_pre 
GROUP BY SiteName, `Date`;

CREATE VIEW full_daily_site_pre AS
SELECT SiteName, `Date`, DailyVisit, DailyRevenue, IF(daily_site.Date >= for_event.StartDate AND daily_site.Date <= (for_event.StartDate + for_event.Duration), CountStaff, 0) AS CountStaff FROM daily_site LEFT JOIN for_event USING(SiteName);

CREATE VIEW full_daily_site AS
SELECT SiteName, `Date`, DailyVisit, DailyRevenue, sum(CountStaff) AS CountStaff, sum(IF(CountStaff = 0, 0, 1)) AS EventCount FROM full_daily_site_pre GROUP BY SiteName, `Date`;

CREATE VIEW staff_site AS 
SELECT DISTINCT SiteName, StaffName 
FROM AssignTo;

CREATE VIEW count_site_staff AS
SELECT SiteName, count(*) AS CountStaff 
FROM staff_site 
GROUP BY SiteName;

CREATE VIEW total_site AS 
SELECT SiteName, sum(DailyVisit) AS TotalVisit, sum(DailyRevenue) AS TotalRevenue 
FROM daily_site 
GROUP BY SiteName;

CREATE VIEW for_site AS
SELECT Site.SiteName AS SiteName, IF(TotalVisit, TotalVisit, 0) AS TotalVisit, IF(TotalRevenue, TotalRevenue, 0) AS TotalRevenue, IF(CountStaff, CountStaff, 0) AS CountStaff, count(*) AS CountEvent , ManagerName, EveryDay 
FROM total_site LEFT JOIN count_site_staff ON total_site.SiteName = count_site_staff.SiteName JOIN Events ON total_site.SiteName = Events.SiteName RIGHT JOIN Site ON total_site.SiteName = Site.SiteName 
GROUP BY Site.SiteName;


CREATE VIEW visit_one_event AS
SELECT UserName, EventName, SiteName, count(*) AS MyVisit, StartDate 
FROM for_event JOIN VisitEvent USING(SiteName, EventName, StartDate)
GROUP BY UserName, EventName, SiteName, StartDate;

CREATE VIEW visit_one_site AS
SELECT UserName, SiteName, CountEvent, TotalVisit, count(*) AS MyVisit 
FROM for_site FULL JOIN VisitSite USING(SiteName) 
GROUP BY UserName, SiteName;

CREATE VIEW visit_hisotry_pre AS
(SELECT `Date`, SiteName, UserName FROM VisitSite) UNION (SELECT `Date`, SiteName, UserName FROM VisitEvent);

CREATE VIEW visit_history AS
SELECT `Date`, EventName, SiteName, Price, UserName
FROM VisitEvent FULL JOIN visit_hisotry_pre USING(`Date`, SiteName, UserName) LEFT JOIN `EVENTS` USING(SiteName, EventName, StartDate);

CREATE VIEW for_schedule AS
SELECT EventName, SiteName, StartDate, EndDate, CountStaff, StaffName, Description 
FROM AssignTo LEFT JOIN for_event USING(EventName, SiteName, StartDate);

CREATE VIEW explore_event AS 
SELECT x.SiteName AS SiteName, x.EventName, x.StartDate, x.EndDate, x.TicketRem, x.Price, x.TotalVisit, x.Description, y.UserName, IF(x.SiteName = y.SiteName AND x.EventName = y.EventName AND x.StartDate = y.StartDate, y.MyVisit, 0) AS MyVisit FROM for_event AS x , visit_one_event AS y;


CREATE VIEW explore_site AS
SELECT x.UserName, x.SiteName, x.Date, y.TotalVisit, y.CountEvent, y.EveryDay, IF(x.SiteName = y.SiteName, 1, 0) AS MyVisit FROM VisitSite AS x, for_site as y;
