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
  echo ::--	Given a child/derived differencing VHD related to a bootable parent VHD,>&2
  echo ::--	first merge the child's content into the parent then reset the child>&2
  echo ::--	and establish it as the default boot volume.>&2
  echo ::-->&2
  echo ::--  Assumes:>&2
  echo ::--	1.  Review the assumptions stated by this module's more primative
  echo ::--	    Relies on Windows BCDedit, DiskPart and Native Boot features of Windows 7 and above.>&2
  echo ::-->&2
  echo ::--  Input:>&2
  echo ::--	1.  ^%1: Either:>&2
  echo ::--		 	The full path name to a configuration file conatining>&2
  echo ::--		 	argument values.>&2
  echo ::--			"/?" displays the "help".>&2
  echo ::-->&2
  echo ::--  Output:>&2
  echo ::--	1.  Review output assumptions of the modules called below.>&2
  echo ::--	2.  errorlevel:>&2
  echo ::--		0: Either:>&2
  echo ::--			Successful execution of "/?">&2
  echo ::--			Parent/Base image was successfully updated and a new>&2
  echo ::--			  image has been created to protect it >&2
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
  echo ::-- The absolute path, without double quotes, to the Vdisk methods.>&2
  echo set BIND_VDISK=^<VdiskMethodsAbsoluteFilePath^>>&2
  echo ::-- The absolute path, enclosed in double quotes, to the differencing (a.k.a. - child/derived) VHD >&2
  echo ::-- To be deleted and then recreated to revert the image back to its>&2
  echo ::-- last known state and then protect it moving forward from>&2
  echo ::-- changes either unintentional or malicious.>&2
  echo set NATIVE_BOOT_DERIVED_FILE="<DerivedVHDAbsoluteFilePath>">&2
  echo ::>&2  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to the base (a.k.a. - parent) VHD. >&2
  echo ::-- This VHD contains the application and OS programs that are essential >&2
  echo ::-- to delivering the services required by role assumed by a person using this image.>&2
  echo ::-- For example, a BU student needs MS Office and Google docs to function at BU.>&2
  echo ::-- Therefore, you would not see games or other exotic software included in the perminant image.>&2
  echo set NATIVE_BOOT_BASE_FILE="<DerivedVHDAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The absolute path, without double quotes, to the configuration file for the>&2
  echo ::-- DerivedMerge module.>&2
  echo set DERIVED_MERGE_CONFIG_FILE=^<DerivedMergeConfigurationAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, without double quotes, to the configuration file for the>&2
  echo ::-- DerivedReset module.>&2
  echo set DERIVED_RESET_CONFIG_FILE=^<DerivedResetConfigurationAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the logging methods.>&2
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to the configuration file needed by the>&2
  echo ::-- logger>&2
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>">&2
  echo ::>&2
  echo exit /b 0 >&2
exit /b


:Main:
  setlocal

  if "%~1"==""       call :Abort "Please specify configuration file as first and only parameter.  Example follows:" & call :Help & exit /b 1
  if "%~1"=="/?"     call :Help & exit /b 0
  if not exist "%~1" call :Abort "Unable to locate provided configuration file:'%~1'.  Example follows:" & call :Help & exit /b 1
  
  call "%~1"
  if errorlevel 1 call :Abort "Problem detected while processing paramters from configuration file:'%~1'" & exit /b 1

  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY GUID_BIND BIND_VDISK DERIVED_MERGE_CONFIG_FILE DERIVED_RESET_CONFIG_FILE LOGGER_BIND LOGGER_CONFIG_FILE
  if errorlevel 1 (
     call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
     call :Abort "Please correct errors in configuration file:'%~1'"
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
     if errorlevel 1 call :Abort "Generation of unique Transaction Id failed" & exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Starting: Image Update: Parent:'" %NATIVE_BOOT_BASE_FILE% "'" " Child:'" %NATIVE_BOOT_DERIVED_FILE% "'"
  ::-- Update the parent by merging the child content into it.
  call "%BIND_VDISK%\DerivedMerge.cmd" "%DERIVED_MERGE_CONFIG_FILE%"
  if errorlevel 1 call :Abort "Module:'%BIND_VDISK%\DerivedMerge.cmd'" & exit /b 1
  ::-- Reset the child VHD and make it bootable.
  call "%BIND_VDISK%\DerivedReset.cmd" "%DERIVED_RESET_CONFIG_FILE%"
  if errorlevel 1 call :Abort "Module:'%BIND_VDISK%\DerivedReset.cmd'" & exit /b 1

  call :Inform "Ended: Image Update: Successful: Parent:'" %NATIVE_BOOT_BASE_FILE% "'" " Child:'" %NATIVE_BOOT_DERIVED_FILE% "'"

exit /b 0


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0


  shutdown /i /r /c "Merge of derived image to its base successful.  Booting to this new image."
