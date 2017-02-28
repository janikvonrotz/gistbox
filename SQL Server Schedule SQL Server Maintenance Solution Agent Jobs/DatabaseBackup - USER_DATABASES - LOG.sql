/*
User databases

Transaction log backup every hour
Job Name: DatabaseBackup - USER_DATABASES - LOG
Execute at 06:00
*/

USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseBackup - USER_DATABASES - LOG', @name=N'DatabaseBackup - USER_DATABASES - LOG', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20140207, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=55959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
