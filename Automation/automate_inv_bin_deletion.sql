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

	EXEC [dbo].[p21_inv_bin_deletion]
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