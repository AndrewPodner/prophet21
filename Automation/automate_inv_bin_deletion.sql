/**
 * The p21 stored procedure for inv bin deletion cleans up
 * inv bin records with 0 quantity linked.  From the P21
 * desktop, you can do this on a more granular basis.
 *
 * This script will loop through all active locations with lot/bin
 * integration enabled and execute the p21 stored proc for each location
 *
 */

DECLARE @location INT
DECLARE @company VARCHAR(20)
DECLARE @msg VARCHAR(255)
DECLARE locCursor CURSOR FOR 
	SELECT 
		location_id, company_id
	FROM 
		location 
	WHERE 
		delete_flag = 'N'
		and lot_bin_integration = 'Y'
	ORDER BY
		company_id, location_id

OPEN locCursor
FETCH NEXT FROM locCursor INTO @location, @company
WHILE @@FETCH_STATUS = 0
BEGIN

	EXEC dbo.p21_inv_bin_deletion
		@as_CompanyID	= @company
		,@ai_LocationID = @location
		,@as_BeginItemID =''
		,@as_EndItemID = 'ZZZZZZZZZZZZZZZZZZZ'
		,@as_BeginBinID = ''
		,@as_EndBinID = 'ZZZZZZZZZZZ'
	SET @msg = 'Inv Bin Deletion Completed for Company ' + @company + ', Location ' + CAST(@location AS VARCHAR)

	RAISERROR(@msg,0,1) WITH NOWAIT

	FETCH NEXT FROM locCursor INTO @location, @company

END
CLOSE locCursor
DEALLOCATE locCursor