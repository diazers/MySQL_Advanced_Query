SELECT * FROM dc_bikeshare.q1_2012;

-- WINDOW FUNCTION atau fungsi jendela atau partisi adalah suatu fungsi yang digunakan untuk agregasi secara terpisah
-- WINDOW FUNCTION akan melakukan kalkulasi di seluruh kumpulan baris tabel tetapi secara terpisah atau masing-masing
-- tidak seperti fungsi agregat biasa, penggunaan WINDOW FUNCTION tidak menyebabkan baris dikelompokkan menjadi satu baris keluaran seperti GROUPED BY
-- bukan seperti Query GROUP By, dimana semua data akan di Group sesuai atribut

-- contoh kita inigin mentotal berapa detik perjalanan yang sudah terjadi tetapi kita ingin membuat penambahannya secara bertahap
-- kita bisa menggunakan WINDOW FUNCTION yaitu salah satunya OVER()
SELECT duration_seconds,
       SUM(duration_seconds) OVER (ORDER BY start_time) AS running_total
  FROM dc_bikeshare.q1_2012
 LIMIT 500
-- query diatas menghasilkan penjumlahan bertahap durasi penggunaan sepeda daei satu baris ke baris selanjutnya
-- lalu duiurutkan berdasarkan waktyu mulai menggunakan sepeda (start_time)
-- dalam bahasa query diatas bisa diterjemahkan menjadi 
-- ambil jumlah durasi_detik di seluruh rangkaian hasil, lalu diurutkan berdasarkan waktu_mulai

-- Jika kita ingin mempersempit jendela dari seluruh kumpulan data menjadi grup individual dalam kumpulan data, 
-- kita dapat menggunakan PARTITION BY untuk melakukannya:
SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_total
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 -- Kueri di atas mengelompokkan dan mengurutkan kueri berdasarkan start_terminal
 -- Dalam setiap nilai start_terminal, ia diurutkan berdasarkan start_time, dan penjumlahan total secara bertahap yg berjalan di seluruh baris saat ini dan semua baris durasi_detik sebelumnya.
 -- ketika start_termnal berubah, maka duration_second juga akan mulai lagi dari awal, hal ini terjadi karena kita menggunakan PARTITION BY()
 -- ORDER BY setelah PARTITION BY mengurutkan penjumlahan bertahap dari duration_seconds
 
 -- apabila kita tidak menggunakan ORDER BY maka akan menampilkan keseluruhan total penjumlahan dari duration_seconds
 -- selama start_terminalnya sama, maka hasil penjumlahan totalnya akan sama
 -- penjumlahan total duration_seconds akan berubah ketika masuk ke baris start_terminal yang berbeda
SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal) AS start_terminal_total
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 
 -- ORDER dan PARTITION mendefinisikan apa yang disebut sebagai "jendela"
 -- subset data yang diurutkan di mana perhitungan dibuat.
 
 -- kita bisa juga memodifikasi kueri dari contoh di atas untuk menunjukkan durasi setiap perjalanan 
 -- sebagai persentase dari total waktu yang diperoleh pengendara dari setiap terminal_start
  SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER (PARTITION BY start_terminal) AS start_terminal_sum,
       (duration_seconds/SUM(duration_seconds) OVER (PARTITION BY start_terminal))*100 AS pct_of_total_time
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 
 -- Saat menggunakan window function, selain SUM() fungsi agregat yang lain seperti COUNT dan AVG juga bisa digunakan 
 SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal) AS running_total,
       COUNT(duration_seconds) OVER
         (PARTITION BY start_terminal) AS running_count,
       AVG(duration_seconds) OVER
         (PARTITION BY start_terminal) AS running_avg
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 
 -- penambahan ORDER BY akan membuat kalkulasi agrgat secara bertahap sama seperti yang sudah dilakukan sebelumnya
 SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_total,
       COUNT(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_count,
       AVG(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_avg
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'

-- Tulis kueri yang menunjukkan total durasi bersepeda, tetapi dikelompokkan berdasarkan end_terminal, 
-- dan dengan durasi perjalanan diurutkan dalam urutan menurun.
SELECT end_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY end_terminal ORDER BY duration_seconds DESC)
         AS running_total
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 
 -- ROW_NUMBER()
 -- ROW_NUMBER() akan menampilkan jumlah baris berurutan dimulai dari 1 
 -- dan nomor baris sesuai dengan pengurutan di ORDER BY di dalam window function
 -- ROW_NUMBER() tidak mengharuskan kita menentukan variabel di dalam tanda kurung
 SELECT start_terminal,
        start_time,
        duration_seconds,
        ROW_NUMBER() OVER (ORDER BY start_time) AS 'row_number'
  FROM  dc_bikeshare.q1_2012
 WHERE  start_time < '2012-01-08'
 
-- Menggunakan klausa PARTITION BY memungkinkan kita untuk mulai menghitung dari angka 1 lagi untuk setiap partisi. 
-- Kueri berikut memulai penghitungan dari awal lagi untuk setiap terminal
SELECT start_terminal,
       start_time,
       duration_seconds,
       ROW_NUMBER() OVER (PARTITION BY start_terminal
                          ORDER BY start_time) AS 'row_number'
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'

-- RANK() and DENSE_RANK()
-- RANK() sedikit berbeda dari ROW_NUMBER()
-- RANK() bisa memunculkan angka yang sama apabila dia diurutkan berdasarkan suatu kolom
-- dan pada kolom tersebut terdapat nilai yang sama
-- berbeda dengan ROW_NUMBER yang akan menghasilkan angka urutan yang berbeda
SELECT start_terminal,
	   start_time,
       duration_seconds,
       RANK() OVER (PARTITION BY start_terminal
                    ORDER BY start_time) AS 'rank'
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
-- kueri diatas pada baris 4 dan 5 diberikan angka yang sama, yaitu 4
-- karena pada window function di order by berdasarkan start_time
-- ketika terdapat value start_time yang sama maka akan diberi peringkat yang sama
-- tetapi rank selanjutnya akan menghasilkan angka 6, rank ke 5 akan di skip

-- DENSE_RANK()
-- DENSE_RANK() akan melakukan hal yang sama seperti RANK(), hanya saja tidak akan men-skip angka RANK yang muncul
-- ketika terdapat angka rank yang muncul lebih dari satu kali
SELECT start_terminal,
	   start_time,
       duration_seconds,
       DENSE_RANK() OVER (PARTITION BY start_terminal
                    ORDER BY start_time) AS 'rank'
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 
 -- Tulis kueri yang menunjukkan 5 perjalanan terpanjang dari setiap terminal awal (start_terminal), 
 -- diurutkan berdasarkan terminal, dan perjalanan terpanjang hingga terpendek dalam setiap terminal. 
 -- Batasi untuk perjalanan yang terjadi sebelum 8 Januari 2012.
 SELECT *
  FROM (
        SELECT start_terminal,
               start_time,
               duration_seconds AS trip_time,
               RANK() OVER (PARTITION BY start_terminal ORDER BY duration_seconds DESC) AS 'rank'
          FROM dc_bikeshare.q1_2012
         WHERE start_time < '2012-01-08'
	   ) sub
 WHERE sub.rank <= 5
 
 -- NTILE()
 -- Anda dapat menggunakan fungsi jendela untuk mengidentifikasi persentil atau kuartil, atau subdivisi lainnya
 -- ORDER BY menentukan kolom mana yang akan digunakan untuk menentukan kuartil (atau berapa pun jumlah n-tile yang kita tentukan)
 SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
          AS quartile,
       NTILE(5) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS quintile,
       NTILE(100) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS percentile
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
-- yang perlu diperhatikan adalah pertimbangkan banyak baris untuk setiap partisi
-- quartile NTILE(4) pada start_terminal 31000 akan menghasilkan angka yg benar
-- tetapi saat digunakan pada percentile NTILE(100) akan menunjukan hasil bukan seperti yg diharapkan
-- karena data pada start_termnal 31000 kurang dari 100
-- Jika kita menjalankan window_function yang sangat kecil, 
-- pertimbangkan untuk menggunakan n-tile yang sesuai.

-- menulis kueri yang hanya menampilkan durasi perjalanan dan persentil 
-- di mana baris percentil durasi tersebut berada (berada di seluruh kumpulan data dan tidak dipartisi oleh terminal)
SELECT duration_seconds,
       NTILE(100) OVER (ORDER BY duration_seconds)
         AS percentile
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY 1 DESC
 
 -- LAG and LEAD
 -- LAG atau LEAD digunakan untuk membuat baris kolom yang melebihkan atau mengurangi urutan suatu baris dari baris lain
 -- kita hanya perlu memasukkan kolom mana yang akan ditarik dan berapa baris yang ingin kita tarik.
 -- LAG memperlambat n-baris dari baris yang seharusnya dan LEAD memajukan n-baris dari baris seharusnya
SELECT start_terminal,
       duration_seconds,
       LAG(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds) AS 'lag',
       LEAD(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds) AS 'lead'
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 -- terlihat pada kolom lag, nilai 74 yang seharusnya di baris pertama menjadi di baris kedua karena LAG(1)
-- di kolom lead nilai 277 yang harusnya di baris kedua menjadi di baris pertama karena LEAD(1)

-- hal Ini akan sangat berguna jika kita ingin menghitung perbedaan antar baris
SELECT start_terminal,
       duration_seconds,
       LAG(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS "LAG 1",
       duration_seconds -LAG(duration_seconds, 1) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS difference
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 -- Baris pertama dari kolom LAG 1 adalah null karena tidak ada baris sebelumnya yang dapat ditarik. 
 -- begitu juga saat menggunakan LEAD akan membuat null di akhir kumpulan data. 
 -- Jika Anda ingin membuat hasilnya sedikit lebih bersih, kita dapat membungkusnya dengan kueri luar untuk menghapus null
 SELECT *
  FROM (
    SELECT start_terminal,
           duration_seconds,
           LAG(duration_seconds, 1) OVER
             (PARTITION BY start_terminal ORDER BY duration_seconds)
             AS "LAG 1",
           duration_seconds -LAG(duration_seconds, 1) OVER
             (PARTITION BY start_terminal ORDER BY duration_seconds)
             AS difference
      FROM dc_bikeshare.q1_2012
     WHERE start_time < '2012-01-08'
     ORDER BY start_terminal, duration_seconds
       ) sub
 WHERE sub.difference IS NOT NULL
 
 SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER ntile_window AS quartile,
       NTILE(5) OVER ntile_window AS quintile,
       NTILE(100) OVER ntile_window AS percentile
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
WINDOW ntile_window AS
         (PARTITION BY start_terminal ORDER BY duration_seconds)
 ORDER BY start_terminal, duration_seconds
 
 -- WINDOW
 -- Jika kita berencana untuk menulis beberapa fungsi jendela ke kueri yang sama, menggunakan jendela yang sama
 -- kita dapat membuat alias. Ambil contoh query NTILE di bawah ini
SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS quartile,
       NTILE(5) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS quintile,
       NTILE(100) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS percentile
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 
 -- kita dapat mempersingikat penulisan query diatas menjadi 
 SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER ntile_window AS quartile,
       NTILE(5) OVER ntile_window AS quintile,
       NTILE(100) OVER ntile_window AS percentile
  FROM dc_bikeshare.q1_2012
 WHERE start_time < '2012-01-08'
WINDOW ntile_window AS
         (PARTITION BY start_terminal ORDER BY duration_seconds)
 ORDER BY start_terminal, duration_seconds
 -- CATATN : Klausa WINDOW, jika disertakan, harus selalu muncul setelah klausa WHERE.