USE [P21]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [crm_follow_up_add_task]
	@orderNo varchar(255)
	,@activityId varchar(10)
    ,@comments text
	,@lossReason varchar(40)
	,@targetCompletionDate datetime
	,@userName varchar(80)
AS
SET NOCOUNT ON
BEGIN
	DECLARE @counterVal VARCHAR(10)
	DECLARE @contactId VARCHAR(16)
	DECLARE @subject VARCHAR(255)
	DECLARE @customerId DECIMAL(19,0)
	DECLARE @quoteHdrUid INT

	--Get the contact id from the order
	SELECT 
		@contactId = contact_id
		,@customerId = customer_id
	FROM
		p21_view_oe_hdr
	WHERE
		order_no = @orderNo

	--Build the subject for the task
	SELECT
		@subject = CONCAT(activity_desc, ': ', @orderNo)
	FROM
		activity
	WHERE
		activity_id = @activityId

	-- Get the next counter value
	EXEC @counterVal = p21_get_counter @strCounterID = 'ACT'

	--If this is a lost quote, append the reason to the beginning of the comment 
	--string
	IF @activityId = 'QUOTE-LOST'
	BEGIN
		SET @comments = CONCAT(@lossReason, ': ', @comments) 
	END
	
	-- Add the activity record
	INSERT INTO activity_trans 
	( activity_trans_no
	, activity_id
	, contact_id
	, entry_date
	, assigned_by_id
	, assigned_to_id
	, completed_flag
	, comments
	, date_created
	, date_last_modified
	, last_maintained_by
	, subject
	, reminder_time_offset
	, reminder_time_offset_cd
	, private_task
	, target_complete_date
	, followup
	, followup_comment_cd
	, transaction_type_cd
	, transaction_no
	, company_id
	, link_id
	, link_type_cd
	, hard_touch_flag
	, create_outlook_task_flag
	, sync_task_type_cd
	, start_date 
	, completed_date
	, completed_by_id
) VALUES 
	( @counterVal -- get from counter where the type is 'ACT'
	, @activityId
	, @contactId
	, GETDATE()
	, @userName
	, @userName
	, 'Y'
	, @comments
	, GETDATE()
	, GETDATE()
	, @userName
	, @subject
	, 0
	, 1413
	, 'N'
	, @targetCompletionDate
	, 'N'
	, 1441
	, 709 -- transaction type order/quote
	, @orderNo
	, '1' --company
	, @customerId --link_id
	, 1203 --link type customer
	, 'Y'
	, 'N'
	, 2740
	, GETDATE() 
	, GETDATE()
	, @userName
	)

	--If the quote is lost, we need to go ahead and complete it
	IF @activityId = 'QUOTE-LOST'
	BEGIN
		--OE Header
		UPDATE dbo.oe_hdr SET 
			completed = 'Y'
			,last_maintained_by = @userName
			,date_last_modified = GETDATE()
		WHERE 
			order_no = @orderNo

		--Get the quote header uid
		SELECT 
			@quoteHdrUid = quote_hdr_uid
		FROM
			p21_view_oe_hdr h
				INNER JOIN p21_view_quote_hdr q on h.oe_hdr_uid = q.oe_hdr_uid
		WHERE
			h.order_no = @orderNo

		--update the quote header
		UPDATE dbo.quote_hdr SET
			complete_flag = 'Y'
			,last_maintained_by = @userName
			,date_last_modified = GETDATE()
		WHERE 
			quote_hdr_uid = @quoteHdrUid

		--update the quote lines
		UPDATE quote_line SET 
			line_complete_flag = 'Y'
			, date_last_modified = GETDATE()
			, last_maintained_by = @userName
		 WHERE 
			quote_line_uid IN (
				 SELECT
					q.quote_line_uid
				 FROM
					p21_view_oe_line o
						INNER JOIN p21_view_quote_line q on o.oe_line_uid = q.oe_line_uid
				 WHERE
					o.order_no = @orderNo 
			)
			

	END

	SELECT 1 as result
END

