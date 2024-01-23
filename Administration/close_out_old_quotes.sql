/*
Atlas Precision Consulting LLC - 1/23/2024
By: Andrew Podner
Script to clean up the open quotes and set them to complete
This script completes any quote older than a specified date.

This script and any associated comments are a good faith attempt to
assist the consumer with their environment.  No warranty is expressed
or implied.   Consumer uses this script at his/her own risk.

!!!! Test all code in a Play / Pre-Production Environment before running
against the live database!!!!!

This script may take a long time to run if there is a large build up of data.
It should only be run in an overnight process or a maintenance window.
*/

declare @startDate date = '2020-01-01' --edit this date to change the scope (YYYY-MM-DD)
declare @modifiedByUser varchar(40) = 'admin'
declare @updateData char(1) = 'N'  --valid values are Y and N
declare @keepUnexpiredQuotes char(1) = 'Y' --valid values are Y and N, determines if unexpired quotes will be completed or not.



--DO NOT EDIT BELOW THIS LINE--
IF OBJECT_ID('tempdb..#temp_quotes') IS NOT NULL
    DROP TABLE #temp_quotes


SELECT
	h.oe_hdr_uid
	,qh.quote_hdr_uid
	,h.order_no
	,h.customer_id
	,h.ship2_name
	,qh.expiration_date
	,qh.date_created
INTO #temp_quotes
FROM 
	dbo.oe_hdr h WITH (NOLOCK)
		INNER JOIN dbo.quote_hdr qh WITH (NOLOCK) on h.oe_hdr_uid = qh.oe_hdr_uid 
WHERE
    (h.cancel_flag = 'N' or h.cancel_flag is null)
	and h.completed = 'N'
	and h.projected_order = 'Y'
	and h.date_created < @startDate



--handler for keeping unexpired quotes, and treating null expire date as not expired
if (@keepUnexpiredQuotes = 'Y')
begin 
	update #temp_quotes set expiration_date = '2049-12-31' where expiration_date is null;
	delete from #temp_quotes where expiration_date > GETDATE()
end


--handler for null or blank update user
if (isnull(@modifiedByUser,'') = '')
begin
	set @modifiedByUser = 'admin'
end


--handler to determine if we are running in preview mode or actually
--doing the update.
if (@updateData = 'Y')
begin

	/*** ORDER HEADER ***/
	UPDATE h SET 
		completed = 'Y'
		,date_last_modified = GETDATE()
		,last_maintained_by = @modifiedByUser
	FROM 
		oe_hdr h
			INNER JOIN #temp_quotes q on h.oe_hdr_uid = q.oe_hdr_uid


	/*** ORDER LINE ***/
	UPDATE l SET 
		l.complete = 'Y'
		,date_last_modified = GETDATE()
		,last_maintained_by = @modifiedByUser

	FROM dbo.oe_line l
		INNER JOIN #temp_quotes q on l.oe_hdr_uid = q.oe_hdr_uid 



	/***QUOTE HEADER ***/
	UPDATE qh SET
		qh.complete_flag = 'Y'
		,qh.date_last_modified = GETDATE()
		,qh.last_maintained_by = @modifiedByUser

	FROM
		dbo.quote_hdr qh 
			INNER JOIN #temp_quotes t on qh.quote_hdr_uid = t.quote_hdr_uid


	/***QUOTE LINE***/
	UPDATE ql SET
		ql.line_complete_flag = 'Y'
		,ql.date_last_modified = GETDATE()
		,ql.last_maintained_by = @modifiedByUser	

	FROM
		dbo.quote_line ql 
			INNER JOIN dbo.oe_line ol on ql.oe_line_uid = ol.oe_line_uid
			INNER JOIN #temp_quotes q on ol.oe_hdr_uid = q.oe_hdr_uid

end
else
begin
	select * from #temp_quotes
end









DROP TABLE #temp_quotes
