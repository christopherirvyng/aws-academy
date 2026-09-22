# Lab: Querying Data by Using Athena & AWS Glue

## 📌 Overview & Objectives
Praktikum ini bertujuan untuk menganalisis data transaksi taksi berukuran besar (CSV) yang tersimpan di **Amazon S3** secara *serverless* menggunakan **Amazon Athena** dan **AWS Glue Data Catalog** tanpa mengelola infrastruktur database RDBMS.

### Objectives:
- Mengonfigurasi AWS Glue Database dan mentransformasi skema metadata menggunakan Athena *Bulk Add Columns*.
- Menerapkan strategi optimasi query (*Bucketizing* & *Partitioning*) untuk memangkas *Data Scanned* dan biaya.
- Membuat *SQL Views* biasa dan *Joined Views* di Athena untuk mempermudah perbandingan analisis pendapatan bagi tim Data Science.

---

## 🛠️ AWS Services Used
- **Amazon Athena**: Interactive query service berbasis standar SQL.
- **AWS Glue Data Catalog**: Menyimpan metadata skema database & tabel.
- **Amazon S3**: Tempat penyimpanan objek data mentah (CSV) dan hasil query.
- **Apache Parquet**: Format penyimpanan terkompresi berbasis kolom (*columnar storage*).

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
- **Comparative Analysis View (`comparepay`):** Menggabungkan data agregasi pembayaran *credit card* dan *cash* per vendor menggunakan CTE (`WITH`) dan `JOIN` untuk membandingkan total pendapatan.

---

## 📊 Summary Strategy Comparison

| Strategy | Implementation | Benefit |
| :--- | :--- | :--- |
| **Unoptimized (Full CSV)** | Query langsung ke S3 CSV `yellow` | Fleksibel tetapi men-scan seluruh dataset |
| **Bucketizing** | Menyiapkan terpisah data `jan` | Sangat cepat untuk analisis data kurun waktu tertentu |
| **Partitioning + Parquet** | Partisi `paytype` & format Columnar Parquet | **Paling Hemat & Cepat** (mengurangi data scanned secara drastis) |
| **Athena Views & Joined Views** | `cctrips`, `cashtrips`, & `comparepay` | Memudahkan reusability & menyederhanakan logika query kompleks |

> 📄 *Script SQL lengkap dari Task 1 hingga Task 4 tersedia pada file [`queries.sql`](./queries.sql).*
