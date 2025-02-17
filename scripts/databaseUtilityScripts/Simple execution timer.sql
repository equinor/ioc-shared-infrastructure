-- Timer
DECLARE @IntervalTime DATETIME = SYSDATETIME()

-- Insert your code to be timed here --

PRINT(CONCAT('Duration: ', DATEDIFF(MILLISECOND, @IntervalTime, SYSDATETIME()), ' milliseconds.'))


-- For subsequeny timers in the same run, use the following syntax
SET @IntervalTime = SYSDATETIME()

-- Insert your code to be timed here --

PRINT(CONCAT('Duration: ', DATEDIFF(MILLISECOND, @IntervalTime, SYSDATETIME()), ' milliseconds.'))