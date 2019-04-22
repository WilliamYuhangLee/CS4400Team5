DELIMITER $$


CREATE PROCEDURE filter_transit(in site_name varchar(50), in route_ varchar(20), in transport_type varchar(10), in low_price float, in high_price float)
-- order of parameter
-- site name, transport type, lower bondary of price, higher bondary of price
-- null value means not apply to the filter
BEGIN
    DECLARE new_site_name varchar(100);
    DECLARE new_route_ varchar(20);
    DECLARE new_high_price int;
    
    IF length(site_name) > 0 THEN
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF;
    IF length(route_) > 0 THEN
        SET new_route_ = route_;
    ELSE 
        SET new_route_ = '%';
    END IF;
    IF high_price = 0 THEN
        SET new_high_price = 1000.00;
    ELSE
        SET new_high_price = high_price;
    END IF;
    IF length(transport_type) > 0 THEN 
        SELECT DISTINCT Route, TransportType, Price, NumConnected, NumLogged FROM for_transit JOIN Connects USING(Route, TransportType) WHERE SiteName LIKE new_site_name AND TransportType = transport_type AND Price >= low_price AND Price <= new_high_price AND Route LIKE new_route_;
    ELSE 
        SELECT DISTINCT Route, TransportType, Price, NumConnected, NumLogged  FROM for_transit JOIN Connects USING(Route, TransportType) WHERE SiteName LIKE new_site_name AND Price >= low_price AND Price <= new_high_price AND Route LIKE new_route_;
    END IF;
END $$


CREATE PROCEDURE filter_transit_history(in user_name varchar(100), in site_name varchar(50), in transport_type varchar(10), in start_date date, in end_date date )
BEGIN
    DECLARE new_site_name varchar(100);
    DECLARE new_start_date date;
    DECLARE new_end_date date;
     
     
    
    IF length(user_name) > 0 THEN
        IF length(site_name) > 0 THEN
            SET new_site_name = site_name;
        ELSE 
            SET new_site_name = '%';
        END IF;
        IF end_date = '0000-00-00' THEN
            SET new_end_date = '9999-12-31';
        ELSE 
            SET new_end_date = end_date;
        END IF;
        IF start_date = '0000-00-00' THEN
            SET new_start_date = '1000-01-01';
        ELSE 
            SET new_start_date = start_date;
        END IF;
        IF length(transport_type) >  0 THEN 
            SELECT DISTINCT Route, TransportType, Price, `Date` FROM Take JOIN Transit USING(Route, TransportType) JOIN Connects USING(Route, TransportType) WHERE UserName = user_name AND SiteName LIKE new_site_name AND TransportType = transport_type AND `Date` >= new_start_date AND `Date` <= new_end_date;
        ELSE 
            SELECT DISTINCT Route, TransportType, Price, `Date` FROM Take JOIN Transit USING(Route, TransportType) JOIN Connects USING(Route, TransportType) WHERE UserName = user_name AND SiteName LIKE new_site_name AND `Date` >= new_start_date AND `Date` <= new_end_date;
        END IF;
    ELSE 
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;  
    
   
END $$



CREATE PROCEDURE filter_user(in user_name varchar(100), in type_ varchar(20), in status_ varchar(10) )
-- order of parameter
-- username, type, status
BEGIN 
    DECLARE new_user_name varchar(100);
    DECLARE new_type_ varchar(20);
    DECLARE new_status_ varchar(10);
     
     
    IF length(user_name) > 0 THEN 
        SET new_user_name = user_name;
    ELSE 
        SET new_user_name = '%';
    END IF;
    IF length(type_) > 0 THEN 
        SET new_type_ = type_;
    ELSE 
        SET new_type_ = '%';
    END IF;
    IF length(status_) > 0 THEN 
        SELECT UserName, Type, `Status`, NumEmailCount FROM for_users WHERE UserName LIKE new_user_name AND Type LIKE new_type_ AND `Status` = status_;
    ELSE 
        SELECT UserName, Type, `Status`, NumEmailCount  FROM for_users WHERE UserName LIKE new_user_name AND Type LIKE new_type_;
    END IF;
END $$


CREATE PROCEDURE filter_site_adm(in site_name varchar(50), in manager_name varchar(100), in open_everyday int )
-- order of parameter
-- site name, manager name, if open every day
BEGIN 
    DECLARE new_site_name varchar(50);
    DECLARE new_manager_name varchar(100);
    DECLARE new_open_everyday int;
    
    IF length(site_name) > 0 THEN 
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF;
    IF length(manager_name) > 0 THEN 
        SET new_manager_name = manager_name;
    ELSE 
        SET new_manager_name = '%';
    END IF;
    SET new_open_everyday = open_everyday + 1;
    
    SELECT SiteName, ManagerName, EveryDay FROM for_site WHERE SiteName LIKE new_site_name AND ManagerName LIKE new_manager_name AND EveryDay = new_open_everyday;
END $$


CREATE PROCEDURE filter_event_adm(in manager_name varchar(100), in event_name varchar(50), in key_word varchar(100), in start_date date, in end_date date, in short_duration int, in long_duration int, in low_visit int, in high_visit int, in low_revenue float, in high_revenue float )
-- order of parameter
-- event nane, key word in description, start date, end date, lower bondary of duration, higher bondary of duration, lower bondary of visit, higher bondary of visit, lower bondary of revenue, higher bondary of revenue
BEGIN 
    DECLARE new_event_name varchar(50);
    DECLARE new_key_word varchar(100);
    DECLARE new_start_date date;
    DECLARE new_end_date date;
    DECLARE new_long_duration int;
    DECLARE new_high_visit int;
    DECLARE new_high_revenue float;
    DECLARE site_name varchar(50);
    
    IF length(event_name) > 0 THEN 
        SET new_event_name = event_name;
    ELSE 
        SET new_event_name = '%';
    END IF;
    IF length(key_word) > 0 THEN 
        SET new_key_word = concat('%', concat(key_word, '%'));
    ELSE 
        SET new_key_word = '%';
    END IF;
    IF end_date = '0000-00-00' THEN
        SET new_end_date = '9999-12-31';
    ELSE 
        SET new_end_date = end_date;
    END IF;
    IF start_date = '0000-00-00' THEN
            SET new_start_date = '1000-01-01';
    ELSE 
        SET new_start_date = start_date;
    END IF;
    IF long_duration = 0 THEN
        SET new_long_duration = ~0;
    ELSE
        SET new_long_duration = long_duration;
    END IF;
    IF high_visit = 0 THEN
        SET new_high_visit = ~0;
    ELSE
        SET new_high_visit = high_visit;
    END IF;
    IF high_revenue = 0 THEN
        SET new_high_revenue = ~0 - 1.0;
    ELSE
        SET new_high_revenue = high_revenue;
    END IF;   
    
    SELECT SiteName INTO site_name FROM Site WHERE ManagerName = manager_name;    
    
    SELECT EventName, CountStaff, Duration, TotalVisit, TotalRevenue, Description, StartDate, EndDate FROM for_event WHERE SiteName = site_name AND EventName LIKE new_event_name AND Description LIKE new_key_word AND StartDate >= new_start_date AND EndDate <= new_end_date AND Duration >= short_duration AND Duration <= new_long_duration AND TotalVisit >= low_visit AND TotalVisit <= new_high_visit AND TotalRevenue >= low_revenue AND TotalRevenue <= new_high_revenue;
    
END $$


CREATE PROCEDURE filter_event_daily(in site_name varchar(50), in event_name varchar(50), in start_date date, in low_visit int, in high_visit int, in low_revenue float, in high_revenue float )
-- order of parameter
-- site name, manager name, if open every day
BEGIN 
    DECLARE new_high_visit int;
    DECLARE new_high_revenue float;
    
    IF high_visit = 0 THEN
        SET new_high_visit = ~0;
    ELSE
        SET new_high_visit = high_visit;
    END IF;
    IF high_revenue = 0 THEN
        SET new_high_revenue = ~0 - 1.0;
    ELSE
        SET new_high_revenue = high_revenue;
    END IF;  
    
    IF length(site_name) > 0 AND length(event_name) > 0 AND start_date != '0000-00-00' THEN
        SELECT `Date`, DailyVisit, DailyRevenue FROM daily_event WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date AND DailyVisit >= low_price AND DailyVisit <= new_high_price AND DailyRevenue >= low_revenue AND DailyRevenue <= new_high_revenue;
    ELSE 
        SET @error = 'Primary key cannot have null value.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE filter_staff(in site_name varchar(50), in first_name varchar(50), in last_name varchar(50), in start_date date, in end_date date )
-- order of parameter
-- site name, first name, last name, start date, end date
BEGIN
    DECLARE new_site_name varchar(50);
    DECLARE new_first_name varchar(50);
    DECLARE new_last_name varchar(50);
    DECLARE new_start_date date;
    DECLARE new_end_date date;
    
    IF length(site_name) > 0 THEN 
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF;
    IF length(first_name) > 0 THEN 
        SET new_first_name = first_name;
    ELSE 
        SET new_first_name = '%';
    END IF;
    IF length(last_name) > 0 THEN 
        SET new_last_name = last_name;
    ELSE 
        SET new_last_name = '%';
    END IF;
    IF end_date = '0000-00-00' THEN
        SET new_end_date = '9999-12-31';
    ELSE 
        SET new_end_date = end_date;
    END IF;
    IF start_date = '0000-00-00' THEN
        SET new_start_date = '1000-01-01';
    ELSE 
        SET new_start_date = start_date;
    END IF;
    
    SELECT concat(FirstName, LastName) AS `StaffName`, NumEventShifts, SiteName, EventName, StartDate, EndDate FROM for_staff 
    WHERE SiteName LIKE new_site_name AND FirstName LIKE new_first_name AND LastName LIKE new_last_name AND StartDate >= new_start_date AND EndDate <= new_end_date;

END $$

CREATE PROCEDURE filter_daily_site(in site_name varchar(50), in start_date date, in end_date date, low_event int, in high_event int, in low_staff int, in high_staff int, in low_visit int, in high_visit int, in low_revenue float, in high_revenue float )
-- order of parameters
-- site name, start date, end date, lower bondary of event count, higher bondary of event count, lower bondary of staff count, higher bondary of staff count, lower bondary of daily visits, higher bondary of daily visits, lower bondary of daily revenue, higher bondary of daily revenue
BEGIN
    DECLARE new_start_date date;
    DECLARE new_end_date date;
    DECLARE new_high_event int;
    DECLARE new_high_staff int;
    DECLARE new_high_visit int;
    DECLARE new_high_revenue float;
    
     
     
    
    IF length(site_name) = 0 THEN 
        SET @error = 'Site name cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    ELSE
        IF end_date = '0000-00-00' THEN
            SET new_end_date = '9999-12-31';
        ELSE 
            SET new_end_date = end_date;
        END IF;
        IF start_date = '0000-00-00' THEN
            SET new_start_date = '1000-01-01';
        ELSE 
            SET new_start_date = start_date;
        END IF;
        IF high_revenue = 0 THEN
            SET new_high_revenue = ~0 - 1.0;
        ELSE
            SET new_high_revenue = high_revenue;
        END IF;
        IF high_staff = 0 THEN
            SET new_high_staff = ~0;
        ELSE
            SET new_high_staff = high_staff;
        END IF;
        IF high_visit = 0 THEN
            SET new_high_visit = ~0;
        ELSE
            SET new_high_visit = high_visit;
        END IF;
        IF high_event = 0 THEN
            SET new_high_event = ~0;
        ELSE
            SET new_high_event = high_event;
        END IF;
        SELECT `Date`, EventCount, CountStaff, DailyVisit, DailyReveneu FROM full_daily_site 
        WHERE SiteName = site_name AND `Date` >= new_start_date AND `Date` <= new_end_date AND EventCount >= low_event AND EventCount <= new_high_event AND CountStaff >= low_staff AND CountStaff <= new_high_staff AND DailyVisit >= low_visit AND DailyVisit <= low_new_high_visit AND DailyRevenue >= low_revenue AND DailyRevenue <= new_high_revenue;
    END IF;
END $$



CREATE PROCEDURE filter_daily_event(in site_name varchar(50), in date_ date )
-- order of parameters
-- site name, date
BEGIN
     
    IF length(site_name) = 0 OR date_ = '0000-00-00' THEN 
        SET @error = 'Site name or date cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    ELSE 
        SELECT EventName, SiteName, StartDate, DailyVisit, DailyRevenue,`Date` FROM daily_event WHERE SiteName = site_name AND `Date` = date_;
    END IF;
END $$


CREATE PROCEDURE filter_schedule(in user_name varchar(100), in event_name varchar(50), in key_word varchar(200), in start_date date, in end_date date)
-- order of parameter
-- username, event name, description keyword, start date, end date
BEGIN
    DECLARE new_event_name varchar(50);
    DECLARE new_key_word varchar(200);
    
    IF length(event_name) > 0 THEN 
        SET new_event_name = event_name;
    ELSE 
        SET new_event_name = '%';
    END IF;
    IF length(key_word) > 0 THEN 
        SET new_key_word = concat('%', concat(key_word, '%'));
    ELSE 
        SET new_key_word = '%';
    END IF;
    
    IF start_date = '0000-00-00' THEN 
        IF end_date = '0000-00-00' THEN
            SELECT EventName, SiteName, StartDate, EndDate, CountStaff, Description FROM for_schedule 
            WHERE StaffName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key_word;
        ELSE 
            SELECT EventName, SiteName, StartDate, EndDate, CountStaff, Description FROM for_schedule 
            WHERE StaffName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key_word AND EndDate = end_date;
        END IF;
    ELSE 
        IF end_date = '0000-00-00' THEN
            SELECT EventName, SiteName, StartDate, EndDate, CountStaff, Description FROM for_schedule 
            WHERE StaffName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key_word AND StartDate = start_date;
        ELSE 
            SELECT EventName, SiteName, StartDate, EndDate, CountStaff, Description FROM for_schedule 
            WHERE StaffName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key_word AND EndDate = end_date AND StartDate = start_date;
        END IF;
    END IF;     
END $$


CREATE PROCEDURE filter_event_vis(in user_name varchar(100), in event_name varchar(50), in key_word varchar(200), in site_name varchar(50), in start_date date, in end_date date, in low_visit int, in high_visit int, in low_price float, in high_price float, in is_visited int, in is_sold_out int )
-- order of parameter
-- username, event name, description keyword, site name, start date, end date, lower bondary of total visit, higher bondary of total visit, lower bondary of price, higher bondary of price, if show visited event, if show sold-out-ticket event
BEGIN
    DECLARE new_site_name varchar(100);
    DECLARE new_event_name varchar(100);
    DECLARE new_key varchar(200);
    DECLARE new_high_visit int;
    DECLARE new_high_price float;
    DECLARE new_visited int;
    DECLARE new_sold int;
    
    SET new_event_name = concat('%', concat(event_name, '%'));
    SET new_key = concat('%', concat(key_word, '%'));
    IF length(site_name) > 0 THEN
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF;    
    IF high_visit > 0 THEN
        SET new_high_visit = high_visit;
    ELSE 
        SET new_high_visit = ~0;
    END IF;    
    IF high_price > 0 THEN
        SET new_high_price = high_price;
    ELSE 
        SET new_high_price = ~0;
    END IF;
    IF is_visited = 1 THEN
        SET new_visited = ~0;
    ELSE 
        SET new_visited = 1;
    END IF;
    IF is_sold_out = 1 THEN
        SET new_sold = 0;
    ELSE 
        SET new_sold = 1;
    END IF;
    
    IF length(user_name) > 0 THEN
        IF start_date = '0000-00-00' THEN 
            IF end_date = '0000-00-00' THEN
                SELECT EventName, SiteName, Price, TicketRem, TotalVisit, MyVisit, StartDate, EndDate FROM explore_event
                WHERE UserName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key AND TotalVisit <= new_high_visit AND TotalVisit >= low_visit AND Price >= low_price AND Price <= new_high_price AND MyVisit < new_visited AND TicketRem >= new_sold ;
            ELSE 
                SELECT EventName, SiteName, Price, TicketRem, TotalVisit, MyVisit, StartDate, EndDate FROM explore_event
                WHERE UserName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key AND TotalVisit <= new_high_visit AND TotalVisit >= low_visit AND Price >= low_price AND Price <= new_high_price AND MyVisit < new_visited AND TicketRem >= new_sold AND EndDate = end_date;
            END IF;
        ELSE 
            IF end_date = '0000-00-00' THEN
                SELECT EventName, SiteName, Price, TicketRem, TotalVisit, MyVisit, StartDate, EndDate  FROM explore _event
                WHERE UserName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key AND TotalVisit <= new_high_visit AND TotalVisit >= low_visit AND Price >= low_price AND Price <= new_high_price AND MyVisit < new_visited AND TicketRem >= new_sold AND StartDate = start_date;
            ELSE 
                SELECT EventName, SiteName, Price, TicketRem, TotalVisit, MyVisit, StartDate, EndDate FROM explore _event
                WHERE UserName = user_name AND EventName LIKE new_event_name AND Description LIKE new_key AND TotalVisit <= new_high_visit AND TotalVisit >= low_visit AND Price >= low_price AND Price <= new_high_price AND MyVisit < new_visited AND TicketRem >= new_sold AND EndDate = end_date AND StartDate = start_date;
            END IF;
        END IF;     
    ELSE
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
    
END $$



CREATE PROCEDURE filter_site_vis(in user_name varchar(100), in site_name varchar(50), in open_everyday int, in start_date date, in end_date date, in low_visit int, in high_visit int, in low_event int, in high_event int, in is_visited int )
-- order of paremeter
-- username, site name, if site open everyday, start date, end date, lower bondary of total visit, higher bondary of total visit, lower bondary of event count, higher bondary of event count, if this site has been visited 
-- open_everyday's value shall be 0, 1, or 2, in which 0 for all, 1 for no, 2 for yes
BEGIN
    DECLARE new_site_name varchar(50);
    DECLARE new_start_date date;
    DECLARE new_end_date date;
    DECLARE new_high_visit int;
    DECLARE new_high_event int;
    DECLARE new_visited int;
    
    IF length(site_name) > 0 THEN
        SET new_site_name = site_name;
    ELSE 
        SET new_site_name = '%';
    END IF; 
    IF end_date = '0000-00-00' THEN
        SET new_end_date = '9999-12-31';
    ELSE 
        SET new_end_date = end_date;
    END IF;
    IF start_date = '0000-00-00' THEN
            SET new_start_date = '1000-01-01';
    ELSE 
        SET new_start_date = start_date;
    END IF;
    IF high_visit = 0 THEN
        SET new_high_visit = ~0;
    ELSE
        SET new_high_visit = high_visit;
    END IF;
    IF high_event = 0 THEN
        SET new_high_event = ~0;
    ELSE
        SET new_high_event = high_event;
    END IF;
    IF is_visited = 1 THEN
        SET new_visited = ~0;
    ELSE 
        SET new_visited = 1;
    END IF;
    
    IF length(user_name) > 0 THEN 
        IF open_everyday = 0 THEN
            SELECT SiteName, CountEvent, TotalVisit, sum(MyVisit) AS MyVisits, `Date`, EveryDay FROM explore_site 
            WHERE UserName = user_name AND SiteName LIKE new_site_name AND `Date` >= new_start_date AND `Date` <= new_end_date AND
            TotalVisit >= low_visit AND TotalVisit <= new_high_visit GROUP BY SiteName, UserName HAVING MyVisits < new_visited;
        ELSE 
            SELECT SiteName, CountEvent, TotalVisit, sum(MyVisit) AS MyVisits, `Date`, EveryDay FROM explore_site 
            WHERE UserName = user_name AND SiteName LIKE new_site_name AND `Date` >= new_start_date AND `Date` <= new_end_date AND
            TotalVisit >= low_visit AND TotalVisit <= new_high_visit GROUP BY SiteName, UserName HAVING MyVisits < new_visited AND 
            EveryDay = open_everyday;
        END IF;
    ELSE 
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$








CREATE PROCEDURE query_email_by_username(in user_name varchar(100) )
-- order of parameter
-- username
BEGIN   
     
    IF length(user_name) > 0 THEN
        SELECT EmailAddress FROM Email WHERE UserName = user_name;
    ELSE 
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE query_transit_by_pk(in route_ varchar(20), in transport_type varchar(20) )
-- order of parameter
-- route, transport type
BEGIN   
     
    IF length(route_) > 0  AND length(transport_type) > 0 THEN
        SELECT Price, SiteName FROM Connects JOIN Transit USING(Route, TransportType) WHERE Route = route_ AND TransportType = transport_type;
    ELSE 
        SET @error = 'Username cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$



CREATE PROCEDURE query_staff_by_event (in site_name varchar(50), in event_name varchar(50), in start_date date )
-- order of parameter
-- site name, event name, start date
BEGIN
     
    IF length(site_name) > 0 AND length(event_name) > 0 AND start_date != '0000-00-00' THEN
        SELECT StaffName, FirstName, LastName AS Name FROM AssignTo JOIN Users ON StaffName = UserName WHERE SiteName = site_name AND EventName = event_name AND StartDate = start_date;
    ELSE 
        SET @error = 'Primary key cannot have null value.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE query_transit_by_site(in site_name varchar(50) )
BEGIN
     
    IF length(site_name) > 0 THEN 
        SELECT Route, TransportType, Price FROM Transit JOIN Connects USING(Route, TransportType) WHERE SiteName = site_name;
    ELSE 
        SET @error = 'Site name cannot be null.';
        SIGNAL SQLSTATE '45000' SET message_text = @error;
    END IF;
END $$


CREATE PROCEDURE get_all_transit()
BEGIN
    SELECT Route, TransportType, Price, count(*) AS CountSite FROM Transit JOIN Connects USING(TransportType, Route) Group BY TransportType, Route;
END $$

DELIMITER ;