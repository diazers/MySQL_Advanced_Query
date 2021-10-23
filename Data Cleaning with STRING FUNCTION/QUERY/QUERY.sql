SELECT *
FROM sf_crime.incidents_2014_2013

-- mengubah gaya penulisan suatu text atau string menjadi besar huruf kapitas semua (UPPER) atau kecil semua (LOWER)
SELECT incidnt_num,
       address,
       UPPER(address) AS address_upper,
       LOWER(address) AS address_lower
  FROM sf_crime.incidents_2014_2013
  
  -- LEFT, RIGHT, and LENGTH
  -- kita dapat menggunakan LEFT untuk menarik sejumlah karakter tertentu dari sisi kiri string dan menampilkannya sebagai string terpisah.
  -- kita lihat bahwa kolom date menggunakan format yang sangat panjang dan dalam format strig, kita bisa hanya mengambil data tanggal saja, 10 karakter dari kiri
  SELECT incidnt_num,
       date,
       LEFT(date, 10) AS cleaned_date
  FROM sf_crime.incidents_2014_2013
  
  -- RIGHT melakukan hal yang sama, tetapi dari sisi kanan:
  SELECT incidnt_num,
       date,
       LEFT(date, 10) AS cleaned_date,
       RIGHT(date, 17) AS cleaned_time
  FROM sf_crime.incidents_2014_2013
  
  -- LEN menghasilkan julah panjang dari suatu karakter
    SELECT category,
       LENGTH(category) panjang_karakter
  FROM sf_crime.incidents_2014_2013
  
  -- LEFT DAN RIGHT bekerja dengan baik dalam kasus ini karena kita tahu bahwa jumlah karakter akan konsisten di seluruh baris pada kolom date. 
  -- Jika tidak konsisten, kita bisa mengambil karakter tertentu menggunakan LENGTH, 
  -- LENGTH(date) akan selalu menghasilkan angka 28 dalam dataset ini. 
  -- Karena kita tahu bahwa 10 karakter pertama akan menjadi tanggal, dan kan diikuti oleh spasi (total 11 karakter), kita dapat merepresentasikan fungsi RIGHT seperti ini:
  SELECT incidnt_num,
		 date,
         LEFT(date, 10) AS cleaned_date,
         RIGHT(date, LENGTH(date) - 11) AS cleaned_time  ## 28 - 11 hasilnya 17, jadi akan diambil 17 karakter dari kanan
  FROM sf_crime.incidents_2014_2013
  
  -- POSITION and INSTR
  -- POSITION memungkinkan Anda untuk menentukan substring, lalu mengembalikan nilai numerik yang sama dengan nomor karakter 
  -- (dihitung dari kiri) tempat substring itu pertama kali muncul di string target
  -- kita akan mengecek posisi huruf a pertama dari kiri suatu string
  SELECT incidnt_num,
		 descript,
		 POSITION('A' IN descript) AS a_position
  FROM   sf_crime.incidents_2014_2013
  
 -- INSTR berfungsi untuk mencapai hasil yang sama, cukup ganti IN dengan koma dan alihkan urutan string dan substring:
 SELECT incidnt_num,
        descript,
        INSTR(descript, 'A') AS a_position
  FROM  sf_crime.incidents_2014_2013
  
  -- TRIM, RTRIM, LTRIM
  -- Fungsi TRIM digunakan untuk menghapus karakter dari awal dan atau akhir suatu string dengan menyatakan string apa yang akan dipotong
  -- TRIM([{BOTH | LEADING | TRAILING} [remstr] FROM ] str)
  SELECT location,
       TRIM('(' FROM location),
       TRIM(')' FROM location)
  FROM sf_crime.incidents_2014_2013
  
  -- menghapus leading space atau trailing space
  SELECT LTRIM('  MySQL LTRIM function')
  SELECT RTRIM('MySQL RTRIM function   ')
  
  -- kolom location adalah gabungan dari latttitude dan longitude
  -- kita akan mencoba memisahkan data pada lolom location, menjadi lattitude dan longitude
  SELECT location,
		 TRIM(leading '(' FROM LEFT(location, POSITION(',' IN location) - 1)) AS lattitude,
		 TRIM(trailing ')' FROM RIGHT(location, LENGTH(location) - POSITION(',' IN location) ) ) AS longitude
  FROM 	 sf_crime.incidents_2014_2013
  
  
  -- SUBSTRING, SUBSTRING_INDEX
  -- LEFT dan RIGHT keduanya membuat substring dengan panjang tertentu, 
  -- tetapi keduanya hanya mulai mnegambil karakter dari ssalah satu sisi, kiri atau kanan. 
  -- Jika kita ingin memulai dari tengah string, kita dapat menggunakan SUBSTR. 
  -- Sintaksnya adalah SUBSTR(*string*, *posisi karakter awal*, *# karakter*):
  -- kita akan mengambil hari dari string date
  SELECT incidnt_num,
       date,
       SUBSTR(date, 4, 2) AS day     ## mulai mabil karakter dari karakter ke-4, dan ambil 2 karakter
  FROM sf_crime.incidents_2014_2013
  
 -- CONCAT
 -- kita dapat menggabungkan string dari beberapa kolom bersama-sama menggunakan CONCAT. 
 -- urutkan nilai yang ingin Anda gabungkan dan pisahkan dengan koma. 
 -- Jika Anda ingin nilai hard-code, lampirkan dalam tanda kutip tunggal
 -- kita akan menggabungkan kolom day_of_week dengan kolom date yang sudah diformat menjadi cleaned_date 
 SELECT incidnt_num,
       day_of_week,
       LEFT(date, 10) AS cleaned_date,
       CONCAT(day_of_week, ', ', LEFT(date, 10)) AS day_and_date
  FROM sf_crime.incidents_2014_2013
  
  -- kita akan mereplikasi kolom location dengan menggabungkan kolom lat dan lon
  SELECT CONCAT('(', lat, ', ', lon, ')') AS concat_location,
		 location
  FROM sf_crime.incidents_2014_2013
  
  -- menulis kueri yang membuat kolom tanggal dengan format YYYY-MM-DD
  -- catatan, hal ini hanya bisa dilakukan apabila kolom tersebut ber tipe data string
  SELECT incidnt_num,
	     date,
		 CONCAT(SUBSTR(date, 7, 4) , '-' , LEFT(date, 2) , '-' , SUBSTR(date, 4, 2)) AS cleaned_date
  FROM sf_crime.incidents_2014_2013
  
  -- kita juga bisa menggunakan STR_TO_DATE untuk merubah tipe data dari tipe data string menjadi DATE
  SELECT incidnt_num,
         date,
         STR_TO_DATE(CONCAT(SUBSTR(date, 7, 4) , '-' , LEFT(date, 2) , '-' , SUBSTR(date, 4, 2)), '%Y-%m-%d') AS cleaned_date
  FROM sf_crime.incidents_2014_2013

-- menulis kueri yang menghasilkan kolom berformat DATETIME dari kolom tanggal dan waktu di tutorial.sf_crime_incidents_2014_01. 
-- beserta kolom interval 1 minggu kemudian.
SELECT incidnt_num,
       STR_TO_DATE(CONCAT(SUBSTR(date, 7, 4) , '-' , LEFT(date, 2) , '-' , SUBSTR(date, 4, 2) , ' ' , time , ':00' ), '%Y-%m-%d %H:%i:%s') AS timestamp,
       STR_TO_DATE(CONCAT(SUBSTR(date, 7, 4) , '-' , LEFT(date, 2) , '-' , SUBSTR(date, 4, 2) , ' ' , time , ':00' ), '%Y-%m-%d %H:%i:%s') + INTERVAL 1 WEEK AS timestamp_plus_interval
  FROM sf_crime.incidents_2014_2013
  
-- COALESCE
-- Fungsi ini mengubah NULL Value menjadi value yang kita inginkan
-- karena di data ini tidak ada null value, jadi tida bisa dicoba