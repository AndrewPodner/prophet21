
SELECT
	h.oe_hdr_uid
	,qh.quote_hdr_uid
INTO #temp_quotes
FROM 
	dbo.oe_hdr h WITH (NOLOCK)
		INNER JOIN dbo.quote_hdr qh on h.oe_hdr_uid = qh.oe_hdr_uid 
WHERE
    (h.cancel_flag = 'N' or h.cancel_flag is null)
	and h.completed = 'N'
	and h.projected_order = 'Y'
	and h.date_created < '20160701'


/*** ORDER HEADER ***/
UPDATE h SET 
	completed = 'Y'
	,cancel_flag = 'Y'
	,date_last_modified = GETDATE()
	,last_maintained_by = 'admin'
FROM 
	oe_hdr h WITH (NOLOCK)
		INNER JOIN #temp_quotes q on h.oe_hdr_uid = q.oe_hdr_uid


/*** ORDER LINE ***/
UPDATE l SET 
	l.complete = 'Y'
	,l.cancel_flag = 'Y'
	,date_last_modified = GETDATE()
	,last_maintained_by = 'admin'

FROM dbo.oe_line l WITH (NOLOCK)
	INNER JOIN #temp_quotes q on l.oe_hdr_uid = q.oe_hdr_uid 



/***QUOTE HEADER ***/
UPDATE qh SET
	qh.complete_flag = 'Y'
	,qh.date_last_modified = GETDATE()
	,qh.last_maintained_by = 'admin'

FROM
	dbo.quote_hdr qh WITH (NOLOCK)
		INNER JOIN #temp_quotes t on qh.quote_hdr_uid = t.quote_hdr_uid


/***QUOTE LINE***/
UPDATE ql SET
	ql.line_complete_flag = 'Y'
	,ql.date_last_modified = GETDATE()
	,ql.last_maintained_by = 'admin'	

FROM
	dbo.quote_line ql WITH (NOLOCK)
		INNER JOIN dbo.oe_line ol WITH (NOLOCK) on ql.oe_line_uid = ol.oe_line_uid
		INNER JOIN #temp_quotes q on ol.oe_hdr_uid = q.oe_hdr_uid

	






DROP TABLE #temp_quotes
