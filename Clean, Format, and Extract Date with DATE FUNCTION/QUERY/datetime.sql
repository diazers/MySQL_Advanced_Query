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

-- kita bisa menambah kolom baru di tabel companies berisi kolom dengan tanggal yang sudah terformat
ALTER TABLE companies
ADD date_cleaned DATE

UPDATE companies
SET date_cleaned = date_format(str_to_date(founded_at,'%m/%d/%Y' ), '%Y/%m/%d' )
-- kalau Error Code: 1411. Incorrect datetime value: '1.0' for function str_to_date
-- berarti ada value semacam string di kolom founded_at yang harus kita bersihkan terlebuh dahulu

-- kita bisa menggunakan fungsi extract untuk mengekstrak sebagian atau nagian dari suatu tanggal
-- misal kita hanya mengambildetik, menit, tanggal atau bulan saja
-- gunakana EXTRACT pada data yang sudah terformat
SELECT 	founded_at_clean,
		EXTRACT(DAY FROM founded_at_clean) AS 'DAY_OF_FOUNDED'
FROM	companies_clean_dates
 
SELECT 	acquired_at_cleaned,
		EXTRACT(QUARTER FROM acquired_at_cleaned) AS 'MONTH_OF_ACQUIRED'
FROM	acquisitions_clean_dates

SELECT acquired_at_cleaned,
       EXTRACT(year   FROM acquired_at_cleaned) AS year,
       EXTRACT(month  FROM acquired_at_cleaned) AS month,
       EXTRACT(day   FROM acquired_at_cleaned) AS day,
       EXTRACT(hour   FROM acquired_at_cleaned) AS hour,
       EXTRACT(minute FROM acquired_at_cleaned) AS minute,
       EXTRACT(second FROM acquired_at_cleaned) AS second
  FROM acquisitions_clean_dates

-- kita bisa juga jadikan tanggal didalam control flow CASE WHEN sebagai syarat agregasi
-- misal kueri yang menghitung jumlah perusahaan yang diakuisisi dalam 3 tahun, 5 tahun, dan 10 tahun didirikan (dalam 3 kolom terpisah). 
-- Sertakan juga kolom untuk total perusahaan yang diakuisisi. Kelompokkan berdasarkan kategori dan batasi hanya baris yang meiliki tanggal berdirinya perusahaan.
SELECT companies.category_code,
       COUNT(CASE WHEN DATE_FORMAT(acquired_at_cleaned, '%Y-%m-%d') <= companies.founded_at_clean + INTERVAL 3 YEAR THEN 1 ELSE NULL END) AS acquired_3_yrs,
       COUNT(CASE WHEN DATE_FORMAT(acquired_at_cleaned, '%Y-%m-%d') <= companies.founded_at_clean + INTERVAL 5 YEAR THEN 1 ELSE NULL END) AS acquired_5_yrs,
       COUNT(CASE WHEN DATE_FORMAT(acquired_at_cleaned, '%Y-%m-%d') <= companies.founded_at_clean + INTERVAL 10 YEAR THEN 1 ELSE NULL END) AS acquired_10_yrs,
       COUNT(1) AS total
  FROM crunchbase.companies_clean_dates companies
  JOIN crunchbase.acquisitions_clean_dates acquisitions
    ON acquisitions.company_permalink = companies.permalink
 WHERE founded_at_clean IS NOT NULL
 GROUP BY 1
 ORDER BY 5 DESC

SELECT CURRENT_DATE AS date,
       CURRENT_TIME AS time,
       CURRENT_TIMESTAMP AS timestamp,
       LOCALTIME,
       LOCALTIMESTAMP,
       NOW() AS now

-- kita bisa juga jadikan tanggal didalam control flow CASE WHEN sebagai syarat agregasi
-- misal kueri yang menghitung jumlah perusahaan yang diakuisisi dalam 3 tahun, 5 tahun, dan 10 tahun didirikan (dalam 3 kolom terpisah). 
-- Sertakan juga kolom untuk total perusahaan yang diakuisisi. Kelompokkan berdasarkan kategori dan batasi hanya baris yang meiliki tanggal berdirinya perusahaan.
SELECT companies.category_code,
       COUNT(CASE WHEN DATE_FORMAT(acquired_at_cleaned, '%Y-%m-%d') <= companies.founded_at_clean + INTERVAL 3 YEAR THEN 1 ELSE NULL END) AS acquired_3_yrs,
       COUNT(CASE WHEN DATE_FORMAT(acquired_at_cleaned, '%Y-%m-%d') <= companies.founded_at_clean + INTERVAL 5 YEAR THEN 1 ELSE NULL END) AS acquired_5_yrs,
       COUNT(CASE WHEN DATE_FORMAT(acquired_at_cleaned, '%Y-%m-%d') <= companies.founded_at_clean + INTERVAL 10 YEAR THEN 1 ELSE NULL END) AS acquired_10_yrs,
       COUNT(1) AS total
  FROM crunchbase.companies_clean_dates companies
  JOIN crunchbase.acquisitions_clean_dates acquisitions
    ON acquisitions.company_permalink = companies.permalink
 WHERE founded_at_clean IS NOT NULL
 GROUP BY 1
 ORDER BY 5 DESC

SELECT acquired_at_cleaned,
       DATE_FORMAT(acquired_at_cleaned, '%Y-%m-%d') acquired_at_cleaned
FROM   acquisitions_clean_dates
/* selain itu ada lebih banyak fungsi yang bisa digunakan, bisa untuk melakukan operasi aritmatika pada tanggal
atau bisa juga digunakan untuk mengekstrak suatu bagian dari tanggal, menganti zona waktu, dll. BIsa dilihat di dokumentasi 
https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html */
