USE P21Play
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Andrew Podner>
-- Create date: <12/2/2016>
-- Description:	<Resets all active scanner sessions and
--		creates an audit record for reporting purposes>
-- =============================================
CREATE PROCEDURE dbo.apc_sp_kill_all_scanners AS
BEGIN
BEGIN TRANSACTION
--CREATE AUDIT TRAIL RECORDS
	INSERT INTO audit_trail
		(source_area_cd
		,table_changed
		,column_changed
		,column_description
		,key1_cd
		,key1_value
		,key2_cd
		,key2_value
		,key3_cd
		,key3_value
		,inv_mast_uid
		,uid_value
		,auxiliary_value
		,line_no
		,old_value
		,new_value
		)
	SELECT 
		1447
		,'[rf_terminal]'
		,'row_status_flag'
		,null
		,'location_id'
		,location_id
		,'user_id'
		,current_user_id
		,'login_date'
		,login_date
		,null
		,rf_terminal_uid
		,null
		,null
		,'704'
		,'705'
	FROM 
		dbo.rf_terminal 
	WHERE 
		row_status_flag = 704

	--SOFT DELETE RF BINS
	UPDATE b SET
		b.delete_flag = 'Y'
		,b.last_maintained_by = 'P21_DBA'
		,b.date_last_modified = GETDATE()	
	FROM 
		bin b
			INNER JOIN rf_terminal r on b.rf_terminal_uid = r.rf_terminal_uid
	WHERE
		r.row_status_flag = 704

	--KILL RF TERMINAL SESSIONS
	UPDATE rf SET
		rf.date_last_modified = GETDATE()
		,rf.last_maintained_by = 'P21_DBA'
		,row_status_flag = 705
	FROM 
		rf_terminal rf
	WHERE
		row_status_flag = 704

COMMIT TRANSACTION



END
GO
