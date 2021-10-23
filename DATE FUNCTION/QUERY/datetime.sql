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


 /* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
 -- Mengecek berapa lama waktu suatu persuahaan diakuisisi oleh perusahaan lain
 -- berupa selisih tanggal perusahaan itu didirikan 'founded_at_clean' dengan kapan perusahaaan itu diakuisisi 'acquired_at_cleaned'
 -- 'founded_at_clean' dan 'acquired_at_cleaned' adalah dua kolom berbentuk tanggal yang sudah terformat
 -- namun kolom 'founded_at_clean' bertipe DATE sedangkan 'acquired_at_cleaned' bertipe DATETIME
 -- DATEDIFF digunakan untuk mengetahui selisih antara kedua tanggal
 -- kita juga akan memformat kolom 'founded_at_clean' agar menjadi DATETIME terlebih dahulu agar bisa dikurangkan dengan 'acquired_at_cleaned'
 SELECT companies.permalink,
       companies.founded_at_clean,
       acquisitions.acquired_at_cleaned,
       DATEDIFF(acquisitions.acquired_at_cleaned, date_format(str_to_date(companies.founded_at,'%m/%d/%Y' ), '%Y/%m/%d %H/%i/%s' )) AS time_to_acquisition
  FROM crunchbase.companies_clean_dates companies
  JOIN crunchbase.acquisitions_clean_dates acquisitions
    ON acquisitions.company_permalink = companies.permalink
 WHERE founded_at_clean IS NOT NULL
 
 -- bisa juga menggunankan TIMESTAMPFIFF, hanya saja urutannya dibalik, kita bisa menentukan selisih hari, bulan, tahun  
    SELECT companies.permalink,
       companies.founded_at_clean,
       acquisitions.acquired_at_cleaned,
       TIMESTAMPDIFF(MONTH, date_format(str_to_date(companies.founded_at,'%m/%d/%Y' ), '%Y/%m/%d %H/%i/%s' ),acquisitions.acquired_at_cleaned) AS time_to_acquisition
  FROM crunchbase.companies_clean_dates companies
  JOIN crunchbase.acquisitions_clean_dates acquisitions
    ON acquisitions.company_permalink = companies.permalink
 WHERE founded_at_clean IS NOT NULL
 
 -- Mengecek berapa lama waktu suatu persuahaan diakuisisi oleh perusahaan lain
 -- berupa selisih tanggal perusahaan itu didirikan 'founded_at' dengan kapan perusahaaan itu diakuisisi 'acquired_at'
 -- dua kolom tersebut masih berbentuk string dan masih menggunakan sistem penanggalan US kita dapat memformat kedua kolom tersebut menjadi format DATE
 SELECT companies.permalink,
	   date_format(str_to_date(acquisitions.acquired_at,'%m/%d/%Y' ), '%Y/%m/%d' ) AS cleaned_acquired_at,
	   date_format(str_to_date(companies.founded_at,'%m/%d/%Y' ), '%Y/%m/%d' ) AS cleaned_founded_at,
       DATEDIFF(date_format(str_to_date(acquisitions.acquired_at,'%m/%d/%Y' ), '%Y/%m/%d' ), date_format(str_to_date(companies.founded_at,'%m/%d/%Y' ), '%Y/%m/%d' )) AS time_to_acquisition
  FROM crunchbase.companies companies
  JOIN crunchbase.acquisitions acquisitions
    ON acquisitions.company_permalink = companies.permalink
  WHERE founded_at IS NOT NULL  
  -- karena kolom 'founded_at' dan 'acquired_at' bertipe data string, kita format menggunakan fungsi date_format dan str_to_date
  -- kita ubah format sebelumnya dimana sistem penanggaolan US yang urutannya bulan-hari-tahun menjadi tahun-bulan-hari, sesuai standar SQL
  -- DATEDIFF() digunakan untuk menghitung selisih antara kedua tanggal
  -- walaupun sudah di filter agar cleaned_founded_at tidak NULL, tetapi hasil query masih menunjukan null, karena kita melakukan DATE_FORMAT
  -- field yang tadinya NULL ikut terformat dan menjadi '0000/00/00', hal ini bisa diakali mengguakan query diatas menjadi sub-query
  -- sub-query akan dibahas selanjutnya
 
 -- TIMEDIFF digunakan untuk mengkalkulasi selisih dari DATETIME atau DATE yang berbeda
  SELECT TIMEDIFF('2010-01-02 01:00:00', '2010-01-01 01:00:00') diff;

  
 -- Interval digunakan untuk menambahkan durasi waktu tertentu terhadap waktu yang kita pilih
 -- kita bisa menggunakan operasi aritmatika untuk (+,-,x,:) pada suatu tanggal atau waktu yang dipilih
SELECT permalink,
       date_format(str_to_date(founded_at,'%m/%d/%Y' ), '%Y/%m/%d' ) AS cleaned_founded_at,
       date_format(str_to_date(founded_at,'%m/%d/%Y' ), '%Y/%m/%d' ) + INTERVAL 1 WEEK AS plus_one_week
  FROM crunchbase.companies
 WHERE founded_at IS NOT NULL

 
 SELECT permalink,
       date_format(str_to_date(founded_at,'%m/%d/%Y' ), '%Y/%m/%d' ) AS cleaned_founded_at,
       date_format(str_to_date(founded_at,'%m/%d/%Y' ), '%Y/%m/%d' ) + INTERVAL -4 DAY AS plus_one_week
  FROM crunchbase.companies
 WHERE founded_at IS NOT NULL
 
 -- menentukan berapa lama perusahaan itu berdiri
 -- dihitung dengan cara selisih antara tanggal sekarang dikurang dengan perusahaan itu didirikan
 SELECT permalink,
       date_format(str_to_date(founded_at,'%m/%d/%Y' ), '%Y/%m/%d' ) AS cleaned_founded_at,
       DATEDIFF(CURDATE(),date_format(str_to_date(founded_at,'%m/%d/%Y' ), '%Y/%m/%d' )) AS founded_time_ago
  FROM crunchbase.companies
 WHERE founded_at IS NOT NULL
  -- CURDATE() akan menampilkan tanggal sekarang dalam format DATE (YYYY-mm-dd)
  -- NOW() akan menampilkan waktu sekarang dalam format DATE_TIME ((YYYY-mm-dd HH-ii-SS))
  
  SELECT NOW();
  SELECT CURDATE();
  
 -- menentukan berapa lama perusahaan itu berdiri dan menghilangkan NULL Values juga bisa menggunakan bantuan sub-query
  SELECT	*
  FROM 		 (
			  SELECT permalink,
					 date_format(str_to_date(founded_at,'%m/%d/%Y' ), '%Y/%m/%d' ) AS cleaned_founded_at,
					 DATEDIFF(CURDATE(),date_format(str_to_date(founded_at,'%m/%d/%Y' ), '%Y/%m/%d' )) AS founded_time_ago
			  FROM crunchbase.companies
			  ) AS sub_query
   WHERE sub_query.founded_time_ago IS NOT NULL

-- kita bisa menggunakan fungsi extract untuk mengekstrak sebagian atau nagian dari suatu tanggal
-- misal kita hanya mengambildetik, menit, tanggal atau bulan saja
-- gunakana EXTRACT pada data yang sudah terformat
SELECT 	founded_at_clean,
		EXTRACT(DAY FROM founded_at_clean) AS 'DAY_OF_FOUNDED'
FROM	companies_clean_dates
 
SELECT 	acquired_at_cleaned,
		EXTRACT(QUARTER FROM acquired_at_cleaned) AS 'MONTH_OF_ACQUIRED'
FROM	acquisitions_clean_dates
 
