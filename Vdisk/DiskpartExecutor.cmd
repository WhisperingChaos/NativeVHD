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
  echo ::--     Create, execute, and destroy a diskpart command file.  A diskpart>&2
  echo ::--     command file is erased after successful its execution and the>&2
  echo ::--     approval of a user provided constraint routine that verifies its>&2
  echo ::--     output artifacts.>&2
  echo ::-->&2
  echo ::-- Assumes:>&2
  echo ::--	  1.  Executing script with Administrator privileges.>&2
  echo ::--	  2.  Depends on diskpart.>&2
  echo ::-->&2
  echo ::-- Input:>&2
  echo ::--   1.  Either:>&2
  echo ::--     a.  The full path name to a configuration file containing argument values.>&2
  echo ::--     b.  "/?" displays the "help".>&2
  echo ::-->&2
  echo ::-- Output:>&2
  echo ::--   1.  errorlevel:>&2
  echo ::--     0:  Either:>&2
  echo ::--         a. Successful execution of "/?"
  echo ::--         b. Successful execution of this module.>&2
  echo ::--     1:  Failure>&2
  echo ::-->&2
  echo ::----------------------------------------------------------------------------->&2
  echo ::>&2
  echo ::>&2
  echo ::----------------------------------------------------------------------------->&2
  echo ::-- Configuration file settings needed by the %~f0 script.>&2
  echo ::-- This script is called from the same command processor as the %~f0 script.>&2
  echo ::-- Therefore, you can use other environment variables within this command process,>&2
  echo ::-- like the user specific %%TEMP%% variable, and it will refer to the same one>&2
  echo ::-- visible to the script.>&2
  echo ::-->&2
  echo ::-- Do not code a startlocal or endlocal within this script, at least at this top most level,>&2
  echo ::-- as it will erase the values set by the script.>&2
  echo ::----------------------------------------------------------------------------->&2
  echo ::>&2
  echo ::-- Required: The absolute path, without double quotes, to the Argument methods.>&2
  echo set BIND_ARGUMENT=^<ArgumentCheckAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- Required: The absolute path, without double quotes, to a command that generates a>&2
  echo ::-- cohesive set of diskpart commands.  Generator takes no arguments and produces>&2
  echo ::-- commands as strings to SYSOUT.>&2
  echo set DISKPART_CMD_GENERATOR=^<CMDgeneratorAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- Required: The absolute path, without double quotes, to a command that verifies diskpart's>&2
  echo ::-- expected outcome.  Checker accepts no arguments - caller must use no overlapping>&2
  echo ::-- environment variables that it sets before calling %~f0 to implement the Checker.>&2
  echo ::-- A return value by the checker other than 0 signifies an error.>&2
  echo set DISKPART_CONSTRAINT_CHECK=^<ConstraintCheckAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- Optional: The absolute path, absent double quotes, to the directory that contains the logging methods.>&2
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- Optional: The absolute path, enclosed in double quotes, to the configuration file needed by the>&2
  echo ::-- logger.>&2
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- Optional: The absolute path, absent double quotes, to the directory that contains the GUID generation methods.>&2
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo exit /b 0 >&2

exit /b 0


:Main:
setlocal
  
  if "%~1"=="" ( call :Abort "Please specify configuration file as first and only parameter.  Example follows:"
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
  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY DISKPART_CMD_GENERATOR DISKPART_CONSTRAINT_CHECK
  if %errorlevel% neq 0 (
    if not exist "%BIND_ARGUMENT%\Check.cmd" (
      call :Abort "Failed to bind argument check.  No Check method at filepath:'%BIND_ARGUMENT%\Check'"
	  exit /b 1
	)
    call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
    call :Abort "Please correct errors in configuration file '%~1'"
    exit /b 1
  )
  if not exist "%DISKPART_CMD_GENERATOR%" (
    call :Abort "DISKPART_CMD_GENERATOR must be defined.  Could not find: '"  "%DISKPART_CMD_GENERATOR%" "'"
    exit /b 1
  )
  if not exist "%DISKPART_CONSTRAINT_CHECK%" (
    call :Abort "DISKPART_CONSTRAINT_CHECK must be defined.  Could not find: '"  "%DISKPART_CONSTRAINT_CHECK%" "'"
    exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Started: dispart command: '" "%DISKPART_CMD_GENERATOR%" "' execution."
  ::-- Create dispart create command file 
  set DISPART_FILE_PREAMBLE=%TEMP%\%~n0Script.%RANDOM%
  set DISKPART_CMD_FILE="%DISPART_FILE_PREAMBLE%.txt"
  set DISKPART_CMD_LOG_FILE="%DISPART_FILE_PREAMBLE%.log"

  call "%DISKPART_CMD_GENERATOR%" > %DISKPART_CMD_FILE%
  if not exist %DISKPART_CMD_FILE% (
    call :Abort "Could not create required Diskpart Command file named: '" %DISKPART_CMD_FILE% "'"
    exit /b 1
  )
  diskpart /s %DISKPART_CMD_FILE% > %DISKPART_CMD_LOG_FILE%
  if %errorlevel% neq 0 (
    call :Abort "Diskpart failed.  See contents of: '" %DISKPART_CMD_LOG_FILE% "' and '" %DISKPART_CMD_FILE% "'"
    exit /b 1
  )
  ::-- Although successful, make sure output artifacts exist
  call "%DISKPART_CONSTRAINT_CHECK%"
  if %errorlevel% neq 0 (
    call :Abort "Verification failed. Contents of: '" %DISKPART_CMD_LOG_FILE% "' and '" %DISKPART_CMD_FILE% "'" " might help debugging."
    exit /b 1
  )
  ::-- clean up temporary files
  del %DISKPART_CMD_FILE% > nul
  del %DISKPART_CMD_LOG_FILE% > nul
  
  call :Inform "Ended: dispart command: '" "%DISKPART_CMD_GENERATOR%" "' execution: Successful"
  
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