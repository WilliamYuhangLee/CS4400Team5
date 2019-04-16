DROP USER IF EXISTS 'atlbeltline'@'localhost';
CREATE USER 'atlbeltline'@'localhost' IDENTIFIED BY 'cs4400team5';
GRANT ALL PRIVILEGES ON atlbeltline.* TO 'atlbeltline'@'localhost';