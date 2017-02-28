/*
Cleanup

sp_purge_jobhistory one day per week
Job Name: sp_purge_jobhistory
Execute on monday at 04:00
*/

USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'sp_purge_jobhistory', @name=N'sp_purge_jobhistory', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=2, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20140207, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
