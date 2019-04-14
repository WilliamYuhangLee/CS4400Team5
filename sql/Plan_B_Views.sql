USE cs4400;

CREATE VIEW for_users AS 
SELECT UserName, Status, FirstName, LastName, count(*) AS NumEmailCount 
FROM Users JOIN Email USING(UserName) 
GROUP BY UserName;

CREATE VIEW site_visit_num AS 
SELECT UserName, FirstName, LastName, count(*) AS NumMySiteVisit, IsVisitor 
FROM Users JOIN VisitSite USING(UserName) 
GROUP BY UserName HAVING IsVisitor = "Yes";

CREATE VIEW event_visit_num AS 
SELECT UserName, FirstName, LastName, count(*) AS NumMyEventVisit, IsVisitor 
FROM VisitEvent JOIN Users USING(UserName) 
GROUP BY UserName HAVING IsVisitor = "Yes";

CREATE VIEW for_visitor AS 
SELECT UserName, FirstName, LastName, NumMySiteVisit, NumMyEventVisit 
FROM site_visit_num JOIN event_visit_num USING(UserName, FirstName, LastName);

CREATE VIEW for_staff AS 
SELECT UserName, EmployeeID, count(*) AS NumEventShifts, Title 
FROM Employee JOIN AssignTo ON Employee.UserName = AssignTo.StaffName 
GROUP BY UserName HAVING Title = "Staff";

CREATE VIEW tansit_logged_num AS 
SELECT Route, TransportType, count(*) AS NumLogged 
FROM Transit JOIN Take USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW transit_connect_num AS 
SELECT Route, TransportType, count(*) AS NumConnected 
FROM Transit JOIN Connects USING(Route, TransportType) 
GROUP BY Route, TransportType;

CREATE VIEW for_transit AS 
SELECT Route, TransportType, NumLogged, NumConnected 
FROM tansit_logged_num JOIN transit_connect_num USING(Route, TransportType);

CREATE VIEW event_staff_num AS 
SELECT SiteName, EventName, StartDate, count(*) AS StaffCount 
FROM Events JOIN AssignTo USING(SiteName, EventName, StartDate) 
GROUP BY SiteName, EventName, StartDate;

CREATE VIEW daily_visit_event AS 
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, count(*) AS DailyVisit 
FROM Events JOIN VisitEvent USING(SiteName, EventName, StartDate) 
GROUP BY SiteName, EventName, StartDate, `Date`;

CREATE VIEW daily_event AS
SELECT SiteName, EventName, StartDate, EndDate, `Date`, Price, DailyVisit, (DailyVisit * Price) AS DailyRevenue 
FROM daily_visit_event;

CREATE VIEW for_event AS 
SELECT SiteName, EventName, StartDate, Events.Price, count(DailyVisit) AS TotalVisit, count(DailyRevenue) AS TotalRevenue, (Capacity - count(DailyRevenue)) AS TicketRem, (Events.EndDate - StartDate) AS Duration 
FROM daily_event JOIN Events USING(SiteName, EventName, StartDate)
GROUP BY `Date`;

CREATE VIEW daily_site AS 
SELECT SiteName, `Date`, count(DailyVisit) AS DailyVisit, count(DailyRevenue) AS DailyRevenue
FROM daily_event JOIN Site USING(SiteName) 
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
SELECT SiteName, TotalVisit, TotalRevenue, CountStaff, count(*) AS CountEvent 
FROM total_site JOIN count_site_staff USING(SiteName) JOIN Events USING(SiteName) 
GROUP BY SiteName;