# Lab: Querying Data by Using Athena & AWS Glue

## 📌 Overview & Objectives
Praktikum ini bertujuan untuk menganalisis data transaksi taksi berukuran besar (CSV) yang tersimpan di **Amazon S3** secara *serverless* menggunakan **Amazon Athena** dan **AWS Glue Data Catalog** tanpa mengelola infrastruktur database RDBMS.

### Key Objectives:
- Mengonfigurasi AWS Glue Database dan mentransformasi skema metadata menggunakan Athena *Bulk Add Columns*.
- Menerapkan strategi optimasi query (*Bucketizing*, *Partitioning*, dan *File Compression* Gzip) untuk memangkas *Data Scanned* dan biaya.
- Membuat *SQL Views* biasa dan *Joined Views* di Athena untuk mempermudah perbandingan analisis pendapatan.
- Menganalisis kebijakan akses IAM (`Policy-For-Data-Scientists`) dan menguji eksekusi *Athena Named Queries* melalui AWS CLI.

---

## 🛠️ AWS Services Used
- **Amazon Athena**: Interactive query service berbasis standar SQL.
- **AWS Glue Data Catalog**: Menyimpan metadata skema database & tabel.
- **Amazon S3**: Tempat penyimpanan objek data mentah (CSV) dan hasil query.
- **AWS CloudFormation & AWS CLI**: Otomatisasi pengerahan infrastruktur dan eksekusi query via terminal.
- **AWS IAM**: Pengaturan izin dan keamanan akses berbasis kebijakan (*Least Privilege*).
- **Apache Parquet & Gzip**: Format kompresi dan penyimpanan terkompresi berbasis kolom.

---

## 🎯 Key Tasks & Implementations

### Task 1: Database & Table Creation
- Membentuk database `taxidata` dan mendefinisikan *External Table* `yellow` untuk data CSV satu tahun penuh di S3.

### Task 2: Query Optimization using Bucketizing
- Memisahkan data bulan Januari ke dalam tabel terpisah `jan` (*high-cardinality optimization*).
- **Hasil:** Query ke tabel *bucketized* membaca jauh lebih sedikit data dibandingkan query dengan filter `WHERE` pada tabel utuh (`yellow`).

### Task 3: Query Optimization using Partitions & Parquet
- Mengonversi data ke format **Apache Parquet** dan dipartisi berdasarkan kolom `paytype` (*low-cardinality*).
- **Hasil:** Memangkas ukuran file dan membatasi pemindaian S3 hanya pada folder partisi yang relevan saat query dipanggil.

### Task 4: Creating Views for Data Analysis
- **Filtering Views:** Membuat view `cctrips` (transaksi Credit Card) dan `cashtrips` (transaksi Cash).
- **Comparative Analysis View (`comparepay`):** Menggabungkan data agregasi pembayaran *credit card* dan *cash* per vendor menggunakan CTE (`WITH`) dan `JOIN`.

### Task 5: Optimizing Athena Queries with File Compression (.gz)
- Membandingkan ukuran file dan performa query antara CSV mentah uncompressed (`jan`) dengan file terkompresi Gzip (`jan_gzip`).
- **Hasil:** Athena mampu membaca file `.gz` secara langsung (*on-the-fly*). Kompresi secara signifikan memperkecil *Data Scanned* dari S3, sehingga menurunkan biaya operasional Athena secara langsung.

### Task 6: Reviewing IAM Policy (`Policy-For-Data-Scientists`)
- Menganalisis izin akses untuk pengguna `mary` (IAM Data Scientist).
- Memastikan hak akses terbatas pada pembacaan/penulisan S3, pengelolaan AWS Glue/Athena, tanpa izin membuat S3 bucket baru (*least privilege principle*).

### Task 7: Executing Athena Named Queries via AWS CLI
- Menguji ketersediaan dan eksekusi *Athena Named Query* (`FaresOver100DollarsUS`) menggunakan credentials `mary` di terminal.
- Mengonfirmasi bahwa pengguna dengan kebijakan `Policy-For-Data-Scientists` dapat menjalankan query terkelola tanpa memiliki akses administratif penuh.

---

## 📊 Summary Strategy Comparison

| Strategy | Implementation | Benefit |
| :--- | :--- | :--- |
| **Unoptimized (Full CSV)** | Query langsung ke S3 CSV `yellow` | Fleksibel tetapi men-scan seluruh dataset |
| **Bucketizing** | Menyiapkan terpisah data `jan` | Sangat cepat untuk analisis data kurun waktu tertentu |
| **Partitioning + Parquet** | Partisi `paytype` & format Columnar Parquet | **Paling Hemat & Cepat** (mengurangi data scanned secara drastis) |
| **Athena Views & Joined Views** | `cctrips`, `cashtrips`, & `comparepay` | Memudahkan reusability & menyederhanakan logika query kompleks |
| **File Compression (Gzip)** | External table `jan_gzip` (.csv.gz) | Mengurangi ukuran file S3 & biaya *data scanned* Athena |
| **IAM Access Control & CLI** | `Policy-For-Data-Scientists` & Named Queries | Keamanan infrastruktur & otomatisasi eksekusi via AWS CLI |

> 📄 *Script SQL lengkap dari Task 1 hingga Task 5 tersedia pada file [`queries.sql`](./queries.sql).*
