show variables like "secure_file_priv" ## Taruh file yang ingin diimport (.CSV) ke directory yang ditampilkan dari query ini
show variables like "local_infile"     ## periksa apakah local infile telah diaktifkan atau belum, Anda perlu mengatur local_infile ON untuk dapat mengimpor data dengan cepat menggunakan LOAD DATA INFILE
SET GLOBAL local_infile = 'ON';  

-- buat database dengan nama sf_crime, lalu gunakan tabel tersebut
USE sf_crime

-- buat tabel incidents_2014_2013
CREATE TABLE incidents_2014_2013(
						incidnt_num INT(255) NOT NULL,
                        category VARCHAR(100) NOT NULL,
                        descript VARCHAR(100) NOT NULL,
                        day_of_week VARCHAR(100) NOT NULL,
                        date VARCHAR(100) NOT NULL,
                        time VARCHAR(100) NOT NULL,
                        pd_district VARCHAR(100) NOT NULL,
                        resolution VARCHAR(100) NOT NULL,
                        address VARCHAR(100) NOT NULL,
                        lon FLOAT(7,4) NOT NULL,
                        lat FLOAT(6,4) NOT NULL,
                        location VARCHAR(100) NOT NULL,
                        id INT NOT NULL AUTO_INCREMENT,
                        PRIMARY KEY (id)
                        );



LOAD DATA LOCAL INFILE "C:/Program Files/MySQL/MySQL Server 8.0/Uploads/sf_crime_incidents_2014_01.csv" 
INTO TABLE incidents_2014_2013
FIELDS TERMINATED BY ','
ENCLOSED BY '"'  
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;