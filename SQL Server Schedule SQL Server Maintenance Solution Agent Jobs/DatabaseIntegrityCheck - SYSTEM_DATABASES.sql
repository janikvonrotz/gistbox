/*
System databases

Integrity check one day per week
Job Name: DatabaseIntegrityCheck - SYSTEM_DATABASES
Execute on sunday at 22:00
*/

USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseIntegrityCheck - SYSTEM_DATABASES', @name=N'DatabaseIntegrityCheck - SYSTEM_DATABASES', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20140207, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
