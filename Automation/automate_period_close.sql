/*
Script to close one period and open the next in P21
Must be run on the 1st day of the month (e.g. 12:01am)

*/
DECLARE @curYear INT = YEAR(GETDATE())
DECLARE @curPeriod INT = MONTH(GETDATE())
DECLARE @prevYear INT = YEAR(DATEADD(DAY, -1, GETDATE()))
DECLARE @prevPeriod INT = MONTH(DATEADD(DAY, -1, GETDATE()))

UPDATE periods SET 
	period_closed = 'Y' 
WHERE 
	period = @prevPeriod 
	and year_for_period = @prevYear

UPDATE periods SET 
	period_closed = 'N' 
WHERE 
	period = @curPeriod 
	and year_for_period = @curYear
