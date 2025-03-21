USE msdb;
GO

-- ==============================
-- Differential Backup (Backup perubahan saja)
-- ==============================
EXEC sp_add_job  
    @job_name = 'Daily Differential Backup DB',
    @enabled = 1,
    @description = 'Differential Backup harian database tertentu',
    @owner_login_name = 'sa';
GO

-- Step Differential Backup
EXEC sp_add_jobstep  
    @job_name = 'Daily Differential Backup DB',
    @step_name = 'Differential Backup',
    @subsystem = 'TSQL',
    @command = 
        'DECLARE @dbName VARCHAR(256) = ''NamaDatabaseAnda''
        DECLARE @path VARCHAR(512) = ''C:\SQLBackups\''
        DECLARE @fileName VARCHAR(512)

        SET @fileName = @path + @dbName + ''_diff_'' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 120), ''-'', '''') + ''.bak''
        BACKUP DATABASE @dbName TO DISK = @fileName WITH DIFFERENTIAL, INIT, COMPRESSION';
GO

-- Schedule Differential Backup (Tiap 6 Jam)
EXEC sp_add_jobschedule  
    @job_name = 'Daily Differential Backup DB',
    @name = 'Differential Backup Schedule',
    @freq_type = 4,  -- 4 = Daily
    @freq_interval = 1,
    @freq_subday_type = 8,  -- Setiap 6 jam
    @freq_subday_interval = 6,
    @active_start_time = 60000;  -- Mulai jam 6 pagi
GO

EXEC sp_add_jobserver  
    @job_name = 'Daily Differential Backup DB',
    @server_name = @@SERVERNAME;
GO

-- Jalankan manual untuk tes Differential Backup
EXEC sp_start_job @job_name = 'Daily Differential Backup DB';
GO

-- Cek status Job
SELECT job_id, name, enabled FROM msdb.dbo.sysjobs WHERE name LIKE 'Daily%Backup%';
GO
