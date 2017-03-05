/*
Creates a list of jobs that have run in the last week and what the
outcome of the last run was.  Useful for getting a weekly summary
on what jobs are running right and which ones are not.

NOTE: you need to have db mail running on your SQL server for this
	to work
*/

declare @tableHTML varchar(MAX)
declare @recipient_list VARCHAR(MAX) = 'user@email_address.com'
declare @email_subject VARCHAR(MAX) = 'SQL Job History Report'

CREATE TABLE #temp_job_status (
	session_id VARCHAR(20)
	,job_id VARCHAR(MAX)
	,job_name VARCHAR(MAX)
	,run_requested_date DATETIME
	,run_requested_source INT
	,queued_date DATETIME
	,start_execution_date DATETIME
	,last_executed_step_id INT
	,last_executed_step_date DATETIME
	,stop_execution_date DATETIME
	,next_scheduled_run_date DATETIME
	,job_history_id DECIMAL(19,0)
	,[message] VARCHAR(MAX)
	,run_status INT
	,operator_id_emailed INT
	,operator_id_netsent INT
	,operator_id_paged INT

)
INSERT INTO #temp_job_status
EXEC msdb.dbo.sp_help_jobactivity

SELECT 
	s.category_id
	,t.job_name
	,CONVERT(VARCHAR, t.run_requested_date, 101) as request_date
	,CONVERT(VARCHAR, t.start_execution_date, 101) as started_date
	,CONVERT(VARCHAR, t.stop_execution_date, 101) as stopped_date
	,CONVERT(VARCHAR, t.next_scheduled_run_date, 101) as next_request_date
	,t.[message]

INTO #temp_status_table	
FROM 
	#temp_job_status t
		INNER JOIN msdb.dbo.sysjobs s on t.job_id = s.job_id
WHERE
	run_requested_date is not null
	and next_scheduled_run_date is not null
	and category_id <> 100
	and run_requested_date >= DATEADD(DAY, -7, GETDATE())
ORDER BY
	run_requested_date DESC

SET @tableHTML = 
						N'<H1>SQL Job History Report</H1>' +						
						N'<table border="1" cellspacing="0" cellpadding="2">' +
							N'<th>Job Name</th>' +
							N'<th>Req Start Date</th>' + 
							N'<th>Started Date</th>'+ 
							N'<th>Stopped Date</th>' +
							N'<th>Next Run Date</th>' + 
							N'<th>Notes</th></tr>' +
						CAST ( (	SELECT 
										td = job_name, '',
										td = request_date, '',
										td = started_date, '',
										td = stopped_date, '',
										td = next_request_date, '',
										td = [message], ''
									from #temp_status_table
									FOR XML PATH('tr'), TYPE 
						) AS NVARCHAR(MAX) ) +
						N'</table>' ;
										
exec msdb.dbo.sp_send_dbmail @profile_name = 'Default'
							, @recipients= @recipient_list 
							, @reply_to='sysadmin@mydomain.com'
							, @body = @tableHTML
							, @body_format = 'HTML'
							, @subject= @email_subject

DROP TABLE #temp_job_status
DROP TABLE #temp_status_table