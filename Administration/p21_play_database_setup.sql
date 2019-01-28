/*
Script to Restore and Set Up your play database.
*/
USE master
GO

--Set these variables as appropriate for system
DECLARE @backupFile VARCHAR(80) = 'S:\YourBackupFileNameHere.bak'
DECLARE @playRulesLocation VARCHAR(80) = 'C:\Program Files (x86)\Activant\DynaChangeRulesPlay'
DECLARE @playCrystalPath VARCHAR(80) = 'C:\Reports_P21Play'
DECLARE @liveCrystalPath VARCHAR(80) = 'C:\P21_Reports'
DECLARE @playScriptPath VARCHAR(80) = 'C:\P21Forms_P21Play'

--Assumes that you have an existing Play database, comment this out
--if you don't.  
ALTER DATABASE [P21Play] SET SINGLE_USER WITH ROLLBACK IMMEDIATE 

--Restores the database and modify the SQL file names
--****MODIFY FILENAME AND PATH AS NEEDED FOR YOUR SERVER******
RESTORE DATABASE [P21Play] FROM DISK = @backupFile WITH REPLACE 
, MOVE 'seed16_Data' to 'S:\P21Play.mdf'
, MOVE 'seed16_Log' to 'L:\P21Play.ldf'

--Put the database into multi user mode
ALTER DATABASE [P21Play] SET MULTI_USER

--Trust P21 to execute stored procedures
ALTER DATABASE [P21Play] SET TRUSTWORTHY ON;

--Positively set the owner of the DB, modify as you see fit
ALTER AUTHORIZATION ON DATABASE::P21Play TO sa;

-- Append Company names with P21Play
UPDATE [P21Play].dbo.company SET 
	company_name = LEFT(company_name, 20) + ' (P21Play)';

--Change the DynaChange Rules Directories to a Play Directory 
-- (modify path for your deployment)
UPDATE [P21Play].dbo.system_setting SET 
	value = @playRulesLocation + '\Distribution'
WHERE 
	name = 'bre_distribution_folder';

UPDATE [P21Play].dbo.system_setting SET 
	value = @playRulesLocation
WHERE 
	name = 'bre_dll_folder';


--Change All Reports to Play Directory
UPDATE [P21Play].dbo.system_setting SET 
	value = @playCrystalPath WHERE name = 'crystal_directory';

--Change label definition x location to Play Directory
UPDATE [P21Play].dbo.label_definition_x_loc SET 
	label_template_filename = REPLACE([label_template_filename], @liveCrystalPath, @playCrystalPath);	

--Change Crystal External Reports
UPDATE [P21Play].dbo.[crystal_external_report] SET 
	report_path = @playCrystalPath;

-- Update System script path
-- Avoids unintended document "merging" in production-generated forms
UPDATE [P21Play].dbo.system_setting 
SET [value] = @playScriptPath
WHERE [name] = 'script_path';

-- Update User script paths (if set) to a subfolder of the system script path, i.e.:
--    C:\P21Forms_P21Play\John.Public
-- Avoids unintended document "merging" in production-generated forms
UPDATE [P21Play].dbo.users
SET script_path = @playScriptPath + '\' + [P21Play].dbo.users.id
WHERE DATALENGTH( [P21Play].dbo.users.script_path ) > 0

--Shut off all alerts & Rebuild Alert system
UPDATE [P21Play].dbo.alert_implementation SET 
	row_status_flag = 705;

EXEC [P21Play].dbo.p21_add_job_category;

--Fix Orphaned Users
USE P21Play
GO
EXEC sp_change_users_login 'Auto_Fix', '<user_name>'  --add a line for each user you want to fix
