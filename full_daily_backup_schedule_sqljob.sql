USE msdb;
GO

-- ==============================
-- 1. Full Backup Harian
-- ==============================
EXEC sp_add_job  
    @job_name = 'Daily Full Backup DB',
    @enabled = 1,
    @description = 'Full Backup harian database tertentu',
    @owner_login_name = 'sa'; -- Ganti sesuai user
GO

-- Step Full Backup
EXEC sp_add_jobstep  
    @job_name = 'Daily Full Backup DB',
    @step_name = 'Full Backup',
    @subsystem = 'TSQL',
    @command = 
        'DECLARE @dbName VARCHAR(256) = ''NamaDatabaseAnda''
        DECLARE @path VARCHAR(512) = ''C:\SQLBackups\''
        DECLARE @fileName VARCHAR(512)

        SET @fileName = @path + @dbName + ''_'' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 120), ''-'', '''') + ''.bak''
        BACKUP DATABASE @dbName TO DISK = @fileName WITH INIT, FORMAT, COMPRESSION';
GO

-- Schedule Full Backup Harian
EXEC sp_add_jobschedule  
    @job_name = 'Daily Full Backup DB',
    @name = 'Daily Backup Schedule',
    @freq_type = 4,  -- 4 = Daily
    @freq_interval = 1,
    @active_start_time = 220000;  -- 22:00 (10 malam)
GO

EXEC sp_add_jobserver  
    @job_name = 'Daily Full Backup DB',
    @server_name = @@SERVERNAME;
GO

-- Jalankan manual untuk tes Full Backup
EXEC sp_start_job @job_name = 'Daily Full Backup DB';
GO
