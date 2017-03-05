/*
Script to clean up the PORG data that is archived in P21
This script deletes any data older than 3 months ago.
*/
USE P21Play
GO

CREATE TABLE #temp_gpor (
	gpor_uid DECIMAL(19,0)
)

INSERT INTO #temp_gpor (gpor_uid)
	SELECT gpor_run_hdr_uid FROM dbo.gpor_run_hdr
		WHERE date_created <= DATEADD(MONTH, -3, GETDATE())


DELETE FROM dbo.gpor_vss WHERE gpor_run_hdr_uid in
	(SELECT gpor_uid from #temp_gpor)

DELETE FROM dbo.gpor_run WHERE  gpor_run_hdr_uid in
	(SELECT gpor_uid from #temp_gpor)

DELETE FROM dbo.gpor_run_drp_forecasts WHERE gpor_run_hdr_uid in
	(SELECT gpor_uid from #temp_gpor)

DELETE FROM dbo.gpor_run_hdr WHERE gpor_run_hdr_uid in
	(SELECT gpor_uid from #temp_gpor)

DELETE FROM dbo.gpor_dynamic_look_ahead WHERE gpor_run_hdr_uid in
	(SELECT gpor_uid from #temp_gpor)

DROP TABLE #temp_gpor

