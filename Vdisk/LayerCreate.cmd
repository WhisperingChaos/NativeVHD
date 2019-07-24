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
  echo ::--	    Create a VHD layer. A layer is dependent on another immutable layer.>&2
  echo ::--     This immutable layer is usually called base/parent, while the layer>&2
  echo ::--     created to protect it from write operations is referred to as the>&2
  echo ::--     derived/child one.  Also, note a base/parent can also be a dependent>&2
  echo ::--     layer.  Therefore, a file system may be composed of several dependent>&2
  echo ::--     layers before layering terminates at one that determines the>&2
  echo ::--     the fundamental characteristics of the VHD, like its type/size.>&2
  echo ::-->&2
  echo ::--  Assumes:>&2
  echo ::--	1.  Executing script with Administrator privileges.>&2
  echo ::--	2.  Depends on diskpart.>&2
  echo ::-->&2
  echo ::--  Input:>&2
  echo ::--  1. ^%1: Either:>&2
  echo ::--    The full path name to a configuration file containing argument values.>&2
  echo ::--    "/?" displays the "help".>&2
  echo ::-->&2
  echo ::--  Output:>&2
  echo ::--	 1. errorlevel:>&2
  echo ::--		 0: Either:>&2
  echo ::--		   Successful execution of "/?">&2
  echo ::--		 1: Failure>&2
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
  echo ::-- The absolute filepath, enclosed in double quotes, to a preexisting base/parent VHD.>&2
  echo set BASE_LAYER_FILE="<VHDBaseAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The absolute filepath, enclosed in double quotes, for the new derived/child layer VHD.>&2
  echo set DERIVED_LAYER_FILE="<VHDDerivedAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to the configuration file needed by the>&2
  echo ::-- dispart executor.>&2
  echo set DISKPART_EXECUTOR_CONFIG_FILE="<DiskpartExecutorAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the logging methods.>&2
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to the configuration file needed by the>&2
  echo ::-- logger.>&2
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.>&2
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo exit /b 0 >&2

exit /b 0


:Main:
setlocal

  if "%~1"=="" (
    call :Abort "Please specify configuration file as first and only parameter.  Example follows:"
    call :Help
    exit /b 1
  )
  if "%~1"=="/?" (
    call :Help
    exit /b 0
  )
  if not exist "%~1" (
    call :Abort "Unable to locate provided configuration file:'%~1'.  Example follows:"
    call :Help
    exit /b 1
  )
  call "%~1"
  if %errorlevel% neq 0 (
    call :Abort "Problem detected while processing paramters from configuration file '%~1'"
    exit /b 1
  )
  ::-- Determine if the transaction identifier has been defined before the configuration of this module.
  ::-- If it has, this module is a more primative element of an aggregate transaction.  Therefore, its
  ::-- logged error messages will reflect the aggregate transaction id.  This allows the "tracing" of
  ::-- an aggregate transaction through all its primative modules as they generate messages during their
  ::-- execution with the shared transaction identifier.  Otherwise, this module is being executed
  ::-- as a stand alone transaction, therefore, generate its own unique transaction id.
  if "%NHN.TRANSACTION_ID%"=="" (
    if not "%GUID_BIND%" == "" (
      call "%GUID_BIND%\gen" NHN.TRANSACTION_ID
      if %errorlevel% neq 0 (
        call :Abort "Generation of unique Transaction Id failed"
        exit /b 1
      )
    )
  )
  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY BASE_LAYER_FILE DERIVED_LAYER_FILE DISKPART_EXECUTOR_CONFIG_FILE
  if %errorlevel% neq 0 (
    if not exist "%BIND_ARGUMENT%\Check.cmd" (
      call :Abort "Failed to bind argument check.  No Check method at filepath:'%BIND_ARGUMENT%\Check'"
      exit /b 1
    )
    call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
    call :Abort "Please correct errors in configuration file '%~1'"
    exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Started: Layer VHD: '" %DERIVED_LAYER_FILE% "' creation"
  if not exist %BASE_LAYER_FILE% (
    call :Abort "BASE_LAYER_FILE must exist to create new derived/child layer:'" %BASE_LAYER_FILE% "' does not exist or inaccessible due to permissions."
    exit /b 1
  )
  call %~dp0\DiskpartExecutor.cmd %DISKPART_EXECUTOR_CONFIG_FILE%
  if %errorlevel% neq 0 exit /b 1
  
  call :Inform "Ended: Layer VHD: '" %DERIVED_LAYER_FILE% "' creation: Successful"
  
endlocal
exit /b 0


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0