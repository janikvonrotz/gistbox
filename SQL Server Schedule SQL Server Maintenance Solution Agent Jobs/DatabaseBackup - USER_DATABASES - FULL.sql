/*
User databases

Full backup one day per week
Job Name: DatabaseBackup - USER_DATABASES - FULL
Execute on sunday at 21:00
*/

USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseBackup - USER_DATABASES - FULL', @name=N'DatabaseBackup - USER_DATABASES - FULL', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20140207, 
		@active_end_date=99991231, 
		@active_start_time=210000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
