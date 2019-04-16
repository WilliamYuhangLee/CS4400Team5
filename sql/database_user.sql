DROP USER IF EXISTS 'altbeltline'@'%';
CREATE USER 'altbeltline'@'%' IDENTIFIED BY 'cs4400team5';
GRANT ALL PRIVILEGES ON altbeltline.* TO 'altbeltline'@'%';