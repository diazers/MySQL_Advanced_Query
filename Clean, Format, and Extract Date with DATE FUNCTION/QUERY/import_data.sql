show variables like "secure_file_priv" ## Taruh file yang ingin diimport (.CSV) ke directory yang ditampilkan dari query ini
show variables like "local_infile"     ## periksa apakah local infile telah diaktifkan atau belum, Anda perlu mengatur local_infile ON untuk dapat mengimpor data dengan cepat menggunakan LOAD DATA INFILE
SET GLOBAL local_infile = 'ON';    

-- upload dataset ini,dataset ini berisi data perusahaan-perusahaan teknologi
-- dataset ini ditambah data tanggal yang sudah terformat dan tidak terformat (US standar) agar memudahkan kita saat pengetesan syntax
-- pertama membuat tabelnya
-- kemudian kita upload/import menggunakan fungsi LOAD DATA LOCAL INFILE agar mempercepat proses upload
 -- dataset ini juga terdapat data yang masih us standard dan sudah terstandar
CREATE TABLE companies(
						permalink VARCHAR(100),
                        name VARCHAR(100),
                        homepage_url VARCHAR(100),
                        category_code VARCHAR(100),
                        funding_total_usd INT,
                        status VARCHAR(100),
                        country_code VARCHAR(100),
                        state_code VARCHAR(100),
                        region VARCHAR(100),
                        city VARCHAR(100),
                        funding_rounds INT,
                        founded_at VARCHAR(100),
                        founded_month VARCHAR(100),
                        founded_quarter VARCHAR(100),
                        founded_year INT,
                        first_funding_at VARCHAR(100),
						last_funding_at VARCHAR(100),
                        last_milestone_at VARCHAR(100),
                        id INT
                        );

LOAD DATA LOCAL INFILE "C:/Program Files/MySQL/MySQL Server 8.0/Uploads/crunchbase_companies.csv" 
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE acquisitions(
						company_permalink VARCHAR(100),
                        company_name VARCHAR(100),
                        company_category_code VARCHAR(100),
                        company_country_code VARCHAR(100),
                        company_state_code VARCHAR(100),
                        company_region VARCHAR(100),
                        company_city VARCHAR(100),
                        acquirer_permalink VARCHAR(100),
                        acquirer_name VARCHAR(100),
                        acquirer_category_code VARCHAR(100),
                        acquirer_country_code VARCHAR(100),
                        acquirer_state_code VARCHAR(100),
                        acquirer_region VARCHAR(100),
                        acquirer_city VARCHAR(100),
                        acquired_at VARCHAR(100),
                        acquired_month VARCHAR(100),
						acquired_quarter VARCHAR(100),
                        acquired_year INT,
                        price_amount INT,
                        price_currency_code VARCHAR(100),
                        id INT
                        );

LOAD DATA LOCAL INFILE "C:/Program Files/MySQL/MySQL Server 8.0/Uploads/crunchbase_acquisitions.csv" 
INTO TABLE acquisitions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


CREATE TABLE companies_clean_dates(
						permalink VARCHAR(100),
                        name VARCHAR(100),
                        homepage_url VARCHAR(100),
                        category_code VARCHAR(100),
                        funding_total_usd INT,
                        status VARCHAR(100),
                        country_code VARCHAR(100),
                        state_code VARCHAR(100),
                        region VARCHAR(100),
                        city VARCHAR(100),
                        funding_rounds INT,
                        founded_at VARCHAR(100),
                        founded_at_clean DATE,
                        id INT
                        );

LOAD DATA LOCAL INFILE "C:/Program Files/MySQL/MySQL Server 8.0/Uploads/companies_clean_date.csv" 
INTO TABLE companies_clean_dates
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
 
 CREATE TABLE acquisitions_clean_dates(
						company_permalink VARCHAR(100),
                        acquirer_permalink VARCHAR(100),
                        acquirer_name VARCHAR(100),
                        acquirer_category_code VARCHAR(100),
                        acquirer_country_code VARCHAR(100),
                        acquirer_state_code VARCHAR(100),
                        acquirer_region VARCHAR(100),
                        acquirer_city VARCHAR(100),
                        price_amount INT,
                        price_currency_code VARCHAR(100),
                        acquired_at VARCHAR(100),
                        acquired_at_cleaned DATETIME,
                        id INT
                        );
 
LOAD DATA LOCAL INFILE "C:/Program Files/MySQL/MySQL Server 8.0/Uploads/acquisitions_clean_date.csv" 
INTO TABLE acquisitions_clean_dates
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
 
 SELECT * FROM crunchbase.companies_clean_dates;
 SELECT * FROM crunchbase.acquisitions_clean_dates;
 
 -- sebelumnya kita lakukan sedikit data cleaning terlebih dahulu pada kolom berformat tanggal
 -- terlihat bahwa data yang sebelumnya blank space ('') di tabel companies_clean_dates pada kolom founded_at_clean menjadi 0000-00-00
 -- sama seperti acquisitions_clean_dates pada kolom acquired_at_cleaned, field yang blank space ('') menjadi 0000-00-00
 -- kita bisa update field yang memiliki value 0000-00-00 menjadi NULL
 -- kita lakukan juga terhadap kolom founded_at dan acquired_at pada tabel companies dan acquititions
 
 -- sebelumnya kita non aktifkan terlebih dahulu safe mode apabila masih aktif agar kita bisa melakukan UPDATE
 SET SQL_SAFE_UPDATES = 0;
 
 UPDATE companies_clean_dates
SET founded_at_clean = NULL
WHERE founded_at_clean = '0000-00-00'
 
 UPDATE acquisitions_clean_dates
SET acquired_at_cleaned = NULL
WHERE acquired_at_cleaned = '0000-00-00'

 UPDATE acquisitions
SET acquired_at = NULL
WHERE acquired_at = ''

 UPDATE companies
SET founded_at = NULL
WHERE founded_at = ''