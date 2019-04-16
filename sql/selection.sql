USE atlbeltline;
DELIMITER $$


CREATE PROCEDURE filter_transit(in site_name varchar(50), in transport_type varchar(10), in low_price float, in high_price float, out error varchar(300))
-- order of parameter
-- contain site, transport type, the higher bondary of price, the lower bondary of price
-- for low_price, negative value means not apply to filter
-- for high_price, greater or equal to 1000 mean not apply to filter
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '45000' CALL handle2(error);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION CALL handle1(error);
    SELECT * FROM for_transit
    WHERE ((Route, TransportType) IN (SELECT Route, TransportType FROM connects WHERE SiteName LIKE concat("%", site_name ) ) ) 
    AND TransportType LIKE concat("%", transport_type) AND Price > low_price 
    AND Price < high_price;
END $$
