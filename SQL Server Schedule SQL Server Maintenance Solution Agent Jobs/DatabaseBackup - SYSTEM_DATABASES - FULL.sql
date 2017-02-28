/*
System databases

Full backup every day
Job Name: DatabaseBackup - SYSTEM_DATABASES - FULL
Execute at 23:00 
*/

USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name = N'DatabaseBackup - SYSTEM_DATABASES - FULL', @name=N'DatabaseBackup - SYSTEM_DATABASES - FULL', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20140101, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
