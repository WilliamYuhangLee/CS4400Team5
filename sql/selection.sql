USE atlbeltline;
DELIMITER $$

CREATE PROCEDURE filter_transit(in site_name varchar(50), in transport_type varchar(10), in high_price float, in low_price float, out error varchar(300))
-- order of parameter
-- contain site, transport type, the higher bondary of price, the lower bondary of price
-- for high_price and low_price, negative value means not apply to filter
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    IF site_name THEN 
        IF transport_type THEN 
            IF high_price >= 0 THEN 
                IF low_price >= 0 THEN 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Route, TransportType IN SELECT Route, TransportType FROM Connects WHERE SiteName = site_name 
                    AND TransportType = transport_type AND Price < high_price AND Price > low_price;
                ELSE 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Route, TransportType IN SELECT Route, TransportType FROM Connects WHERE SiteName = site_name 
                    AND TransportType = transport_type AND Price < high_price;
                END IF;
            ELSE
                IF low_price >= 0 THEN 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Route, TransportType IN SELECT Route, TransportType FROM Connects WHERE SiteName = site_name 
                    AND TransportType = transport_type AND Price > low_price;
                ELSE 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Route, TransportType IN SELECT Route, TransportType FROM Connects WHERE SiteName = site_name 
                    AND TransportType = transport_type;
                END IF;
            END IF;
        ELSE
            IF high_price >= 0 THEN 
                IF low_price >= 0 THEN 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Route, TransportType IN SELECT Route, TransportType FROM Connects WHERE SiteName = site_name 
                    AND Price < high_price AND Price > low_price;
                ELSE 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Route, TransportType IN SELECT Route, TransportType FROM Connects WHERE SiteName = site_name 
                    AND Price < high_price;
                END IF;
            ELSE
                IF low_price >= 0 THEN 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Route, TransportType IN SELECT Route, TransportType FROM Connects WHERE SiteName = site_name 
                    AND Price > low_price;
                ELSE 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Route, TransportType IN SELECT Route, TransportType FROM Connects WHERE SiteName = site_name;
                END IF;
            END IF;
        END IF;
    ELSE
        IF transport_type THEN 
            IF high_price >= 0 THEN 
                IF low_price >= 0 THEN 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE TransportType = transport_type AND Price < high_price AND Price > low_price;
                ELSE 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE TransportType = transport_type AND Price < high_price;
                END IF;
            ELSE
                IF low_price >= 0 THEN 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE TransportType = transport_type AND Price > low_price;
                ELSE 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE TransportType = transport_type;
                END IF;
            END IF;
        ELSE
            IF high_price >= 0 THEN 
                IF low_price >= 0 THEN 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Price < high_price AND Price > low_price;
                ELSE 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Price < high_price;
                END IF;
            ELSE
                IF low_price >= 0 THEN 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit
                    WHERE Price > low_price;
                ELSE 
                    SELECT Route, TransportType, Price, NumConnected FROM for_transit;
                END IF;
            END IF;
        END IF;
    END IF;
END $$
