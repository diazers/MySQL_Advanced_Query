show variables like "secure_file_priv" ## Taruh file yang ingin diimport (.CSV) ke directory yang ditampilkan dari query ini
show variables like "local_infile"     ## periksa apakah local infile telah diaktifkan atau belum, Anda perlu mengatur local_infile ON untuk dapat mengimpor data dengan cepat menggunakan LOAD DATA INFILE
SET GLOBAL local_infile = 'ON';  

-- buat database dengan nama sf_crime, lalu gunakan tabel tersebut
USE dc_bikeshare

-- buat tabel incidents_2014_2013
CREATE TABLE q1_2012(
						duration VARCHAR(100) NOT NULL,
                        duration_seconds FLOAT NOT NULL,
                        start_time DATETIME NOT NULL,
                        start_station VARCHAR(100) NOT NULL,
                        start_terminal FLOAT NOT NULL,
                        end_time DATETIME NOT NULL,
                        end_station VARCHAR(100) NOT NULL,
                        end_terminal FLOAT NOT NULL,
                        bike_number VARCHAR(100) NOT NULL,
                        rider_type VARCHAR(100) NOT NULL,
                        id INT NOT NULL
				   );



LOAD DATA LOCAL INFILE "C:/Program Files/MySQL/MySQL Server 8.0/Uploads/dc_bikeshare_q1_2012.csv" 
INTO TABLE q1_2012
FIELDS TERMINATED BY ','
ENCLOSED BY '"'  
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM dc_bikeshare.q1_2012;