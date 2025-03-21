SQL Server Scripts Collection

# Script SQL Server Backup Job

Repositori ini berisi skrip SQL Server untuk membuat job backup harian secara otomatis untuk database tertentu. Termasuk **Full Backup** dan **Differential Backup**.

## 📌 Fitur
- **Full Backup**: Berjalan setiap hari pukul 22:00 (10 malam)
- **Differential Backup**: Membackup perubahan saja setiap 6 jam, mulai pukul 06:00 pagi
- **Mendukung Kompresi** agar file backup lebih kecil
- **Bisa dijalankan manual** untuk pengujian

---

## 🚀 Panduan Setup

### 1️⃣ Full Backup Job

Job ini akan membuat backup lengkap database target setiap hari pukul 10 malam.

#### Perintah Setup
```sql
EXEC sp_add_job 
    @job_name = 'Daily Full Backup DB',
    @enabled = 1,
    @description = 'Full Backup harian database tertentu',
    @owner_login_name = 'sa';
```

#### Logika Backup
Skrip akan menyimpan file backup ke `C:\SQLBackups\` dengan format nama:
```
NamaDatabaseAnda_YYYYMMDD.bak
```

#### Jalankan Manual
Untuk menjalankan job secara manual:
```sql
EXEC sp_start_job @job_name = 'Daily Full Backup DB';
```

---

### 2️⃣ Differential Backup Job

Job ini hanya membackup perubahan (differential) sejak full backup terakhir. Berjalan tiap 6 jam, mulai pukul 6 pagi.

#### Perintah Setup
```sql
EXEC sp_add_job 
    @job_name = 'Daily Differential Backup DB',
    @enabled = 1,
    @description = 'Differential Backup harian database tertentu',
    @owner_login_name = 'sa';
```

#### Logika Backup
File differential backup akan disimpan dengan format:
```
NamaDatabaseAnda_diff_YYYYMMDD.bak
```

#### Jalankan Manual
Untuk menjalankan job differential secara manual:
```sql
EXEC sp_start_job @job_name = 'Daily Differential Backup DB';
```

---

## 🔍 Cek Status Job
Untuk mengecek apakah job sudah dibuat dan aktif:
```sql
SELECT job_id, name, enabled FROM msdb.dbo.sysjobs WHERE name LIKE 'Daily%Backup%';
```

---

## 🔧 Panduan Restore

### 🛠️ Restore Full Backup Saja
```sql
RESTORE DATABASE NamaDatabaseAnda 
FROM DISK = 'C:\SQLBackups\NamaDatabaseAnda_YYYYMMDD.bak' 
WITH REPLACE;
```

### 🛠️ Restore Full Backup + Differential Backup
1. Restore full backup dulu (gunakan NORECOVERY):
```sql
RESTORE DATABASE NamaDatabaseAnda 
FROM DISK = 'C:\SQLBackups\NamaDatabaseAnda_YYYYMMDD.bak' 
WITH NORECOVERY;
```

2. Restore differential backup terbaru (gunakan RECOVERY):
```sql
RESTORE DATABASE NamaDatabaseAnda 
FROM DISK = 'C:\SQLBackups\NamaDatabaseAnda_diff_YYYYMMDD.bak' 
WITH RECOVERY;
```

---

## 💡 Catatan
- Ganti `NamaDatabaseAnda` dengan nama database yang ingin dibackup.
- Pastikan folder `C:\SQLBackups\` sudah ada dan SQL Server punya izin menulis di folder itu.
- Sesuaikan jadwal backup sesuai kebutuhan.

Selamat scripting SQL! 🚀

