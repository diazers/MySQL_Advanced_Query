-- SUBQUERY
-- SUBQUERY adalah query bersarang/berlapis dalam query lain seperti SELECT, WHERE, FROM, INSERT, UPDATE atau DELETE. 
-- SUBQUERY juga dapat disarangkan/dimasukan di dalam subquery lain.
-- SUBQUERY disebut juga inner query sedangkan query yang berisi subquery disebut outer query. 
-- SUBQUERY dapat digunakan di mana saja ekspresi tersebut digunakan dan harus ditutup dalam tanda kurung.

USE	sf_crime;

SELECT 	* 
FROM 	sf_crime.incidents_2014_2013;

-- subquery di dalam FROM
SELECT sub.*
  FROM (
          SELECT *
          FROM sf_crime.incidents_2014_2013
          WHERE day_of_week = 'Friday'
       ) sub
 WHERE sub.resolution = 'NONE'
 -- query diatas akan mengekesekusi inner query atau subquery terlebih dahulu, baru kemudian mengeksekusi outer query
 -- setiap subquery harus diberi alias, contoh diatas diberi alias sub
 -- kita juga bisa memberi indentasi pada subquery agar lebih mudah dibaca
 
 -- menulis kueri yang memilih semua Perintah Penangkapan (WARRANT ARREST) dari dataset, 
 -- lalu dibungkus dalam kueri luar yang hanya menampilkan insiden yang belum terselesaikan.
 SELECT sub.*
 FROM (
		SELECT *
		FROM sf_crime.incidents_2014_2013
		WHERE descript = 'WARRANT ARREST'
	  ) sub
 WHERE sub.resolution = 'NONE'

-- dua contoh subquery diatas sebenarnya bisa dilakukan tanpa menggunakan subquery dengan menambahkan beberapa kondisi menggunakan clausa WHERE
-- seperti query dibawah ini :
SELECT	*
FROM	sf_crime.incidents_2014_2013
WHERE	descript = 'WARRANT ARREST' AND resolution = 'NONE'

-- selanjutnya kita akan mengeksplore best practice ketika kondisi dimana subquery sangat cocok digunakan karena lebih efektif dan efisien

-- subquery di dalam SELECT statement
SELECT 	time, (SELECT AVG(time) FROM sf_crime.incidents_2014_2013) as average
FROM sf_crime.incidents_2014_2013
-- sebenarnya rata-rata waktu idealnya bukan seperti ini, tetapi ini hanya menunjukan contoh subquery di SELECT STATEMENT
-- cara seperti ini mirip dengan cara windowing menggunakan PARTITION BY

-- Menggunakan subkueri untuk mengagregasi dalam beberapa tahap
-- Contoh, bagaimana jika kita ingin mengetahui berapa banyak insiden yang dilaporkan setiap hari dalam seminggu? Lebih baik lagi, 
-- atau bagaimana jika ingin mengetahui berapa banyak insiden yang terjadi secara rata-rata pada hari Jumat di bulan Desember? atau Januari? 
-- Ada dua langkah untuk melakukan ini: 
-- 1. menghitung jumlah insiden setiap hari (inner query)
-- 2. lalu menentukan rata-rata bulanan (outer query )
SELECT LEFT(sub.date, 2) AS cleaned_month,
       sub.day_of_week,
       AVG(sub.incidents) AS average_incidents
  FROM (
        SELECT day_of_week,
               date,
               COUNT(incidnt_num) AS incidents
          FROM sf_crime.incidents_2014_2013
         GROUP BY 1,2
       ) sub
 GROUP BY 1,2
 ORDER BY 1,2
-- Secara umum, paling mudah untuk menulis kueri dalam terlebih dahulu dan merevisinya hingga hasilnya masuk akal dan sesuai, 
-- lalu beralih ke kueri luar.

-- menulis kueri yang menampilkan jumlah rata-rata insiden bulanan untuk setiap kategori. 
SELECT sub.category,
       AVG(sub.incidents) AS avg_incidents_per_month
  FROM (
         SELECT LEFT(date, 2) AS month,
                category,
                COUNT(1) AS incidents
		 FROM   sf_crime.incidents_2014_2013
         GROUP BY 1,2
       ) sub
  GROUP BY 1
  
  -- subquery di dalam WHERE (conditional logic)
  -- kkta dapat menggunakan subkueri dalam penulisan fungsi logika kondisional (bersama dengan WHERE, JOIN/ON, atau CASE
  -- dengan catatan IN hanya bisa digunakan di postgreeSQL, untuk mysql kita harus membuat Ssubquery dalam subquery atau join
  SELECT *
  FROM sf_crime.incidents_2014_2013
  WHERE Date = (  SELECT MIN(date)
                  FROM sf_crime.incidents_2014_2013
			   )

-- Kalau menggunakan IN kita harus membuat subquery dalam subquery dan menggunakan temp_tab
SELECT *
  FROM sf_crime.incidents_2014_2013
 WHERE DATE IN (  SELECT * FROM (
								   SELECT DATE
								   FROM sf_crime.incidents_2014_2013
								   ORDER BY DATE
								   LIMIT 5
								) temp_tab)
  
-- Joining subqueries
-- kita bisa menghasilkan hasil yang sama sperti query sebelumnya menggunakan JOIN
SELECT *
  FROM sf_crime.incidents_2014_2013 AS incidents
  JOIN ( SELECT date
           FROM sf_crime.incidents_2014_2013
          ORDER BY date
          LIMIT 5
       ) sub
    ON incidents.date = sub.date
 
 -- Kueri berikut memberi peringkat pada semua hasil berdasarkan berapa banyak insiden yang dilaporkan dalam hari tertentu. 
 -- hal Ini dilakukan dengan cara menggabungkan jumlah total insiden setiap hari di inner query, lalu menggunakan nilai tersebut untuk mengurutkan outer query:
SELECT incidents.*,
       sub.incidents AS incidents_that_day
  FROM sf_crime.incidents_2014_2013 incidents
  JOIN ( SELECT date,
          COUNT(incidnt_num) AS incidents
           FROM sf_crime.incidents_2014_2013
          GROUP BY 1
       ) sub
    ON incidents.date = sub.date
 ORDER BY sub.incidents DESC, time
 
 -- kueri yang menampilkan semua baris dari tiga kategori dengan insiden paling sedikit yang dilaporkan.
 SELECT incidents.*,
       sub.count AS total_incidents_in_category
  FROM sf_crime.incidents_2014_2013 incidents
  JOIN (
        SELECT category,
               COUNT(*) AS count
          FROM sf_crime.incidents_2014_2013
         GROUP BY 1
         ORDER BY 2
         LIMIT 3
       ) sub
    ON sub.category = incidents.category
    
-- SUBQUERY juga bisa lebih unggul dibanding menggunakan JOIN
-- jadi kita harus menyesuaikan sesuai kondisi dan keperluan apakah lebih efektif dan efisien menggunakan subquery atau join