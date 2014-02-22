@echo off
goto Main

:Help:
  echo ::----------------------------------------------------------------------------->&2
  echo ::-->&2
  echo ::--  Module:	%~f0>&2
  echo ::--  Version:	1.0>&2
  echo ::--  Author:	Richard Moyse>&2	
  echo ::-->&2
  echo ::--  Purpose:>&2
  echo ::--	Configure the boot manager to immediately start the OS on a given>&2
  echo ::--	volume.>&2
  echo ::-->&2
  echo ::--  Assumes:>&2
  echo ::--	1.  Relies on Windows BCDedit feature of Windows 7 and above.>&2
  echo ::--	2.  Executing script with Administrator privileges.>&2
  echo ::--	3.  An exported boot manager image properly preconfigured>&2
  echo ::--	    to immediately boot the desired volume.>&2
  echo ::--	4.  Chages are applied to the default boot manager instance.>&2
  echo ::-->&2
  echo ::--  Input:>&2
  echo ::--	1.  ^%1: Either:>&2
  echo ::--		 	The full path name to a configuration file conatining>&2
  echo ::--		 	argument values.>&2
  echo ::--			"/?" displays the "help".>&2
  echo ::-->&2
  echo ::--  Output:>&2
  echo ::--	1.  A new child VHD.>&2
  echo ::--	2.  A new boot manager instance that replaced the default boot manager instance,>&2
  echo ::--	    with a new entry to boot the child VHD's image, as the new default boot OS.>&2
  echo ::--	3.  errorlevel:>&2
  echo ::--		0: Either:>&2
  echo ::--			Successful execution of "/?">&2
  echo ::--			Reset was successful>&2
  echo ::--		1: Failure>&2
  echo ::-->&2
  echo ::----------------------------------------------------------------------------->&2
  echo ::>&2
  echo ::>&2
  echo ::----------------------------------------------------------------------------->&2
  echo ::-- Configuration file settings needed by the %~f0 script.>&2
  echo ::-- This script is called from the same command processor as the %~f0 script>&2
  echo ::-- Therefore, you can use other environment variables within this command process,>&2
  echo ::-- like the user specific %%TEMP%% variable, and it will refer to the same one visible to the >&2
  echo ::-- script.>&2
  echo ::-->&2
  echo ::-- Do not code a startlocal or endlocal within this script, at least at this top most level,>&2
  echo ::-- as it will erase the values set by the script.>&2
  echo ::----------------------------------------------------------------------------->&2
  echo ::>&2
  echo ::-- The absolute path, without double quotes, to the Argument methods.>&2
  echo set BIND_ARGUMENT=^<ArgumentCheckAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.>&2
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the logging methods.>&2
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to the configuration file needed by the>&2
  echo ::-- logger>&2
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The volume name whose chil
  echo ::-- The absolute path, enclosed in double quotes, to a previously>&2
  echo ::-- saved boot manager instance containing the boot entry that should>&2
  echo ::-- be immediately booted next time the machine is started.>&2
  echo ::-- Use "BCDedit /export" to create this instance>&2
  echo set BOOT_MANAGER_INSTANCE="<BCDbootManagerAbsoluteFilePath>">&2
  echo ::>&2
  echo exit /b 0 >&2
exit /b


:Main:
  setlocal

  if "%~1"==""       call :Abort "Please specify configuration file as first and only parameter.  Example follows:" & call :Help & exit /b 1
  if "%~1"=="/?"     call :Help & exit /b 0
  if not exist "%~1" call :Abort "Unable to locate provided configuration file: '%~1'.  Example follows:" & call :Help & exit /b 1
  
  call "%~1"
  if errorlevel 1 call :Abort "Problem detected while processing paramters from configuration file:'%~1'." & exit /b 1

  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY GUID_BIND LOGGER_BIND LOGGER_CONFIG_FILE BOOT_MANAGER_INSTANCE
  if errorlevel 1 (
     call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'."
     call :Abort "Please correct errors in configuration file '%~1'."
     exit /b 1
  )
  ::-- Determine if the transaction identifier has been defined before the configuration of this module.
  ::-- If it has, this module is a more primative element of an aggregate transaction.  Therefore, its
  ::-- logged error messages will reflect the aggregate transaction id.  This allows the "tracing" of
  ::-- an aggregate transaction through all its primative modules as they generate messages during their
  ::-- execution with the shared transaction identifier.  Otherwise, this module is being executed
  ::-- as a stand alone transaction, therefore, generate its own unique transaction id.
  if "%NHN.TRANSACTION_ID%"=="" (
     call "%GUID_BIND%\gen" NHN.TRANSACTION_ID
     if errorlevel 1 call :Abort "Generation of unique Transaction Id failed." & exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Starting: Boot Manager Replace with:'" %BOOT_MANAGER_INSTANCE% "'"

  call :BootReplace %BOOT_MANAGER_INSTANCE%
  if errorlevel 1 exit /b 1

  call :Inform "Ended: Boot Manager Replace with:'" %BOOT_MANAGER_INSTANCE% "'"

exit /b 0

::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Perform a "safe" replacement of the current boot manager instance
::--	by first creating a backup of its state, then overwriting
::--	the current boot manager instance with the desired preconfigured
::--	instance
::--
::--  Assumes:
::--    1.  Administratitive privileges to run BCDedit.
::--
::--  Input:
::--    1.  %1 - An absolute directory path to a preconfigured boot manager
::--		 instance containing the desired boot entry(s).
::--  Output:
::--	1.  When Successful, an updated BCD boot manager file located in primary boot parition
::--	    containing the desired boot manager entry(s).
::--    2.  errorlevel -
::--		0 - successfully replaced boot boot manager instance.
::--		1 - failed - boot manager instance should revert to its
::--		    state immediately before the execution of this script.
;;--
::-----------------------------------------------------------------------------
:BootReplace:
  setlocal

  if "%~1" == ""     call :Abort "Specify preconfigured exported bootmanager instance"     & exit /b 1
  if not exist "%~1" call :Abort "Could not find preconfigured bootmanager instance:'%~1'" & exit /b 1

  set BOOT.REPAIR.BACKUP.FILE=%TEMP%\BootManager7Backup.%RANDOM%

  ::-- Create backup of current boot manager state in order to rollback during an abort
  bcdedit /export "%BOOT.REPAIR.BACKUP.FILE%" >nul
  if errorlevel 1 call :Abort "Boot manager backup to file:'%BOOT.REPAIR.BACKUP.FILE%' failed" & exit /b 1

  ::-- Import the apppropriate template file.
  bcdedit /import %1 >nul
  if errorlevel 1 call :BootReplaceRollback "BCDedit import of preconfigured boot manager instance failed. File:'%~1'" "%BOOT.REPAIR.BACKUP.FILE%" & exit /b 1

  ::-- successfully updated boot manager with customized template.  Remove the backup.
  del "%BOOT.REPAIR.BACKUP.FILE%" >nul
  ::-- Specify '*' in file name to remove all the hidden backup files, as more than one can be created.
  del /Q /F /AH "%BOOT.REPAIR.BACKUP.FILE%*" >nul

exit /b 0


::-----------------------------------------------------------------------------
::--
::--  Purpose:
::--	Restore backup copy of boot manager, that was created immediately before
::--	the attempt to replace the boot manager instance,
::--	due to some problem encountered by the attempted import. 
::--
::--  Input:
::--	1.  %1 - An error message detailing the reason for the rollaback.
::--    2.  %2 - An environment variable containing an absolute filename
::--		 to a boot manager backup created by a BCDedit
::--		/export, immediately executed before this attempt to replace it.
::--
::--  Output:
::--	1.  When successful, the new boot manager instance will be
::--	    located in primary boot parition.
::--    2.  errorlevel:
::--		1 - Continue signaling error 
;;--
::-----------------------------------------------------------------------------
:BootRepairRollback:

  call :Abort %1
  bcdedit /import %2 >nul
  if errorlevel 1 call :Abort "Attempted restore of boot manager failed.  Boot manager maybe corrupted and require Windows Repair process.  Boot Manager backup file name: '%BOOT.REPAIR.BACKUP.FILE%'"
  
exit /b 1


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0