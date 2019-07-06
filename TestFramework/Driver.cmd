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
  echo ::--	Provide a testing framework to permit test driven development.>&2
  echo ::--	A test is represented as a separate line (row) within a file.  This file is>&2
  echo ::-- called a "Test Table".  Each row of this file must define the following>&2
  echo ::-- columns:>&2
  echo ::--		1. test description,>&2
  echo ::--     2. errorlevel test,>&2
  echo ::--		3. batch command.>&2
  echo ::--	Columns are delinated by close bracket ('}').  Therefore column values>&2
  echo ::--	cannot contain this character.>&2
  echo ::-- 
  echo ::-->&2
  echo ::--  Assumes:>&2
  echo ::-->&2
  echo ::--  Input:>&2
  echo ::--	1.  ^%1: Either:>&2
  echo ::--		 	The full path name to a configuration file.>&2
  echo ::--			"/?" displays the "help".>&2
  echo ::-->&2
  echo ::--  Output:>&2
  echo ::--	1.  errorlevel:>&2
  echo ::--		0: Either:>&2
  echo ::--			Successful execution of "/?">&2
  echo ::--			Creation was successful>&2
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
  echo ::-- The absolute path, enclosed in double quotes, to the file containing the Test Table.>&2
  echo set TEST_TABLE_FILE="<TestTableAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- Direct test output to 'nul' device. Valid values: 'NO', 'SYSOUT', 'SYSERR', or 'BOTH'.  Default is 'BOTH'.>&2
  echo ::-- Note: redirection operator ^> can be specified for each command in the Test Table.  Therefore, specifying 'NO'>&2
  echo ::-- allows complete control of redirection by each command.>&2
  echo set TEST_NULLIFY_OUTPUT=BOTH>&2
  echo ::>&2
  echo ::-- Determine if running tests after a failure should continue.  Valid values: 'EXIT', or 'CONTINUE'.  Default is 'CONTINUE'.>&2
  echo set TEST_ON_FAILURE=CONTINUE>&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the logging methods.>&2
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- The absolute path, enclosed in double quotes, to the configuration file needed by the>&2
  echo ::-- logger>&2
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.>&2
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo exit /b 0 >&2

exit /b 0


:Main:
  setlocal

  if "%~1"==""       call :Abort "Please specify configuration file as first and only parameter.  Example follows:" & call :Help & exit /b 1
  if "%~1"=="/?"     call :Help & exit /b 0
  if not exist "%~1" call :Abort "Unable to locate provided configuration file:'%~1'.  Example follows:" & call :Help & exit /b 1
  
  call "%~1"
  if errorlevel 1 call :Abort "Problem detected while processing paramters from configuration file '%~1'" & exit /b 1

  if not exist "%BIND_ARGUMENT%\Check.cmd" call :Abort "Failed to bind argument check.  No Check method at filepath:'%BIND_ARGUMENT%\Check" & exit /b 1

  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY TEST_TABLE_FILE
  if errorlevel 1 (
     call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
     call :Abort "Please correct errors in configuration file '%~1'"
     exit /b 1
  )
 
  ::-- Determine if the transaction identifier has been defined before the configuration of this module.
  ::-- If it has, this module is a more primative element of an aggregate transaction.  Therefore, its
  ::-- logged error messages will reflect the aggregate transaction id.  This allows the "tracing" of
  ::-- an aggregate transaction through all its primative modules as they generate messages during their
  ::-- execution with the shared transaction identifier.  Otherwise, this module is being executed
  ::-- as a stand alone transaction, therefore, generate its own unique transaction id.
  if not "%GUID_BIND%"=="" ( 
    if "%NHN.TRANSACTION_ID%"=="" (
       call "%GUID_BIND%\gen" NHN.TRANSACTION_ID
       if errorlevel 1 call :Abort "Generation of unique Transaction Id failed" & exit /b 1
    )
  )

  ::-- Module is configured, now log the start of this effort.
  call :Inform "Started: Testing: '%TEST_TABLE_FILE%'"

  if not exist %TEST_TABLE_FILE% call :Abort "Testing Table file named: '%TEST_TABLE_FILE%' not found." & exit /b 1

  call :nullifyDeviceOpt SYSOUT SYSERR "%TEST_NULLIFY_OUTPUT%" 
  if %errorlevel% NEQ 0 exit /b 1

  call :onFailureOpt %TEST_ON_FAILURE%
  if %errorlevel% NEQ 0 exit /b 1

::-- Using environment variables below because variable assignment via set will preserve the
::-- exact puncuation (especially quoting) specified for each column value.  At first, attempted
::-- to pass each variable value by encapsulating in quotes, like "%%i", however, this
::-- simple mechanism fails when the column values themselves contain quotes.
  set EXIT_LEVEL=0
  for /F "tokens=1,2,3* delims=}" %%i in ( 'type "%TEST_TABLE_FILE%"' ) do (
    set TEST_DESCRIPTION=%%i
    set TEST_CONDITION=%%j
    set TEST_COMMAND=%%k
    call :runCapture %SYSOUT% %SYSERR% || if "%TEST_ON_FAILURE%" == "EXIT" goto mainexit
  )
:mainexit:

  call :Inform "Ended: Testing: '%TEST_TABLE_FILE%'"

  endlocal & set EXIT_LEVEL=%EXIT_LEVEL%
exit /b %EXIT_LEVEL%


:nullifyDeviceOpt:
  setlocal

  set NULL_OPT=%~3

  if "%NULL_OPT%" == "" (
    set NULL_OPT=BOTH
  )
  if "%NULL_OPT%" == "BOTH" (
      set SYSOUT_DEVICE="1>nul"
      set SYSERR_DEVICE="2>nul"
  ) else if "%NULL_OPT%" == "SYSOUT" (
      set SYSOUT_DEVICE=">nul"
  ) else if "%NULL_OPT%" == "SYSERR" (
      set SYSERR_DEVICE="2>nul"
  ) else if not "%NULL_OPT%" == "NO" (
      call :Abort "TEST_NULLIFY_OUTPUT option value unknown: '%NULL_OPT%'.  See help - /?" & exit /b 1
  )

  endlocal & set %1=%SYSOUT_DEVICE%&set %2=%SYSERR_DEVICE%
exit /b 0

:onFailureOpt:

  if "%TEST_ON_FAILURE%" == "" (
    set TEST_ON_FAILURE=CONTINUE
  )
  if "%TEST_ON_FAILURE%" == "CONTINUE" exit /b 0

  if "%TEST_ON_FAILURE%" == "EXIT" exit /b 0

  call :Abort "TEST_ON_FAILURE option value unknown: '%TEST_ON_FAILURE%'.  See help - /?" & exit /b 1

exit /b 0

::-----------------------------------------------------------------------------
::- 
::- Create a level above the actual test being run to integrate
::- the redirection operator ('>') specified for the Driver's
::- SYSOUT & SYSERR output streams so these redirection requests
::- don't interfer with the ones specified for the actual command.
::-  
::-----------------------------------------------------------------------------
:runCapture:
  setlocal

  call :runTest %~1 %~2
  
  if %errorlevel% %TEST_CONDITION% (
    call :Abort "Test: '%TEST_DESCRIPTION%' failed.  Command: '%TEST_COMMAND%'"
	set EXIT_LEVEL=1
  )

  endlocal & set EXIT_LEVEL=%EXIT_LEVEL%
exit/b %EXIT_LEVEL%

::-----------------------------------------------------------------------------
::- 
::- Execute the test code by starting another instance of the command processor.
::- Calling another command processor evaluates the string which replaces 
::- the environment variable TEST_COMMAND below allowing this string to use
::- environment variables too.  Therefore, when coding the batch command 
::- column most batch expressions are natively available - no special puncuation
::- needed.  For example the TEST_COMMAND can incorporate piping ('|').
::- 
::- Note: use "call" keyword to invoke cmd.exe as this keyword will always 
::- sucessfully execute cmd.exe even if future versions of windows batch releases 
::- deviate from treating cmd as a built-in command.
::-  
::-----------------------------------------------------------------------------
:runTest: 

call cmd /c "%TEST_COMMAND%"

exit /b


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0