/*
Atlas Precision Consulting LLC - 1/23/2024
By: Andrew Podner
Script to clean up the PORG data that is archived in P21
This script deletes any data older than 3 months ago.
This script deletes any data older than a specified number of months.

This is useful when your supporting tables for PORG Data are getting
so full that it begins to have a performance effect on the tables
and also on the speed at which PORG is generating items in the P21user interface.

This script and any associated comments are a good faith attempt to
assist the consumer with their environment.  No warranty is expressed
or implied.   Consumer uses this script at his/her own risk.

!!!! Test all code in a Play / Pre-Production Environment before running
against the live database!!!!!

This script may take a long time to run if there is a large build up of data.
It should only be run in an overnight process or a maintenance window.
*/


--set this to the number of months of PORG data you
--wish to retain
declare @monthsToRetain int = 3



---DO NOT MODIFY BELOW THIS POINT---

IF OBJECT_ID('tempdb..#temp_gpor') IS NOT NULL
    DROP TABLE #temp_gpor


CREATE TABLE #temp_gpor (
	gpor_uid DECIMAL(19,0)
)

--select all of the PORG run headers and get them into a temp table, then
--use those IDs to delete the child records.

INSERT INTO #temp_gpor (gpor_uid)
	SELECT gpor_run_hdr_uid FROM dbo.gpor_run_hdr
		WHERE date_created <= DATEADD(MONTH, -1 * @monthsToRetain, GETDATE())


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

--END SCRIPT--
