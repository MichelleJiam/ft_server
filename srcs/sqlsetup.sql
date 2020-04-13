CREATE DATABASE wordpress;

GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';

GRANT SELECT, INSERT, DELETE, UPDATE ON phpmyadmin.* TO 'root'@'localhost';

FLUSH PRIVILEGES;

update mysql.user set plugin = 'mysql_native_password' where user='root';

EXIT