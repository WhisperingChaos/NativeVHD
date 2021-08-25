@echo off
goto Main

:Help:
(
  echo ::-----------------------------------------------------------------------------
  echo ::--
  echo ::--  Module:	%~f0
  echo ::--  Version:	1.0
  echo ::--  Author:	Richard Moyse	
  echo ::--
  echo ::--  Purpose:
  echo ::--    Fetch command names from a directory shared with other processes.
  echo ::--    Using this name, execute its implementation that's located in a 
  echo ::--    directory private - accessible to only this process.  If the  
  echo ::--    command's implementation exists in this private directory, then
  echo ::--    execute it.  Once executed, delete the command name from the shared
  echo ::--    directory.
  echo ::--
  echo ::--    This script is designed to be periodically executed by Task Scheduler.
  echo ::--    It runs each task to completion before starting the next one.  The
  echo ::--    tasks are executed in sorted order by name, therefore, one can execute
  echo ::--    a chain of ordered tasks without writing additional code.
  echo ::--
  echo ::--  Security:
  echo ::--    To prevent arbitrary execution of code, a command's arguments should be
  echo ::--    statically known to prevent dynamic injection during execution.  Therefore
  echo ::--    the command name can be followed by a relative filename that identifies
  echo ::--    the command name's corresponding configuration file.  Again this
  echo ::--    configuration file must exist in the corresponding directory relative
  echo ::--    to the private one for the implemented command to be executed.
  echo ::--
  echo ::--  Assumes:
  echo ::--    1. User account running this script has authority to read from the shared
  echo ::--       directory.
  echo ::--    2. User account running this script has authority to read from a private
  echo ::--       directory that contains command implementations and configuration
  echo ::--       files.
  echo ::--
  echo ::--  Input:
  echo ::--    1.  %1: The configuration file name or /? to display this help. 
  echo ::--
  echo ::--  Output:
  echo ::--    1. errorlevel:
  echo ::--       0: Successfully executed current task.
  echo ::--       1: Failure while running current task.
  echo ::--    2. SYSOUT - Informational messages.
  echo ::--    3. SYSERR - Error messages
  echo ::--
  echo ::-----------------------------------------------------------------------------
  echo ::
  echo ::
  echo ::-----------------------------------------------------------------------------
  echo ::-- Configuration file settings needed by the %~f0 script.
  echo ::-- The configuration setting routing is called from the same command
  echo ::-- processor as the %~f0 script.  Therefore, you can use other environment
  echo ::-- variables within this command process, like the user specific %%TEMP%%
  echo ::-- variable, and it will refer to the same one visible to the script.
  echo ::--
  echo ::-- Do not code a startlocal or endlocal within this script, at least at this
  echo ::-- top most level, as it will erase the values set by the script.
  echo ::-----------------------------------------------------------------------------
  echo ::
  echo ::-- Required: The absolute path, without double quotes, to the Argument methods.
  echo set BIND_ARGUMENT=^<ArgumentCheckAbsoluteFilePath^>
  echo ::
  echo ::-- Required: The absolute path, without double quotes, to the shared process directory
  echo ::-- that should be scanned for command names.
  echo set TASK_FETCH_SHARED_SCAN_DIR=<AbsoluteFilePath>
  echo ::-- Required: The absolute path, without double quotes, to the command implementation
  echo ::-- directory that's private to this process.
  echo set TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR=^<AbsoluteFilePath^>
  echo ::-- Optional: The absolute path, absent double quotes, to the directory that contains the logging methods.
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>
  echo ::
  echo ::-- Optional: The absolute path, enclosed in double quotes, to the configuration file needed by the
  echo ::-- logger.
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>"
  echo ::
  echo ::-- Optional: The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>
  echo ::
  echo exit /b 0
)>&2
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
    call :Abort "Unable to locate provided configuration file: '%~1'.  Example follows:"
    call :Help
    exit /b 1
  )
  call "%~1"
  if %errorlevel% neq 0 ( 
    call :Abort "Poblem detected while processing paramters from configuration file '%~1'"
    exit /b 1
  )
  call :TransactionRequest "%NHN.TRANSACTION_ID%" "%GUID_BIND%" "NHN.TRANSACTION_ID"
  if %errorlevel% neq 0 (
    call :Abort "Failed to generated Transaction ID when requested."
    exit /b 1
  )
  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY TASK_FETCH_SHARED_SCAN_DIR TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR
  if %errorlevel% neq 0 (
    if not exist "%BIND_ARGUMENT%\Check.cmd" (
      call :Abort "Failed to bind argument check.  No Check method at filepath:'%BIND_ARGUMENT%\Check'"
      exit /b 1
    )
    call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
    call :Abort "Please correct errors in configuration file '%~1'"
    exit /b 1
  )
  if not exist %TASK_FETCH_SHARED_SCAN_DIR% (
    call :Abort "Please specify a TASK_FETCH_SHARED_SCAN_DIR that exists.  Cannot find '" %TASK_FETCH_SHARED_SCAN_DIR% "'"
    exit /b 1
  )
  if not exist "%TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR%" (
    call :Abort "Please specify a TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR that exists.  Cannot find '" "%TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR%" "'"
    exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Started: Task: '" %TASK_FETCH_SHARED_SCAN_DIR% "' FetchExecute"

  dir /on /b "%TASK_FETCH_SHARED_SCAN_DIR%\*.*" | findstr /R /C:"^..*" >nul
  if %errorlevel% neq 0 (
	call :Inform "No tasks found in '%TASK_FETCH_SHARED_SCAN_DIR%' to perform."
	goto :EndSuccess:
  )
  setlocal EnableDelayedExpansion
  for /F "delims=" %%t in ( 'dir /on /b "%TASK_FETCH_SHARED_SCAN_DIR%\*.*"' ) do (
    call :TaskExecuteDelete "%TASK_FETCH_SHARED_SCAN_DIR%" "%TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR%" "%%t"
	if !errorlevel! neq 0 exit /b 1
  )
  endlocal

:EndSuccess:
  call :Inform "Ended: Task: '" %TASK_FETCH_SHARED_SCAN_DIR% "' FetchExecute: Successful"
  
endlocal
exit /b 0


:TaskExecuteDelete:
setlocal
::-- Environment variable names can't be used in this context.  The purpose of this routine is to establish
::-- the dynamic context of the requested private process. by using numbered arguments, there can be no
::-- overlap with a variable name.  Furthermore, the value of numbered arguments are automatically
::-- restore when returning from a call - without using setlocal/endlocal.  This prevents malicious
::-- code from affecting these values even after a call.
::
::-- Documents the association between argument number and a descriptive name.  
::set TASK_REQUEST_DIR=%~1
::set TASK_CODE_DIR=%~2
::set TASK_NAME=%~3
  
  if not exist "%~2\%~3%" (
    call :Abort "Requested Task: '" "%~3%" "' does not exist in TASK_CODE_DIR: '" "%TASK_CODE_DIR" "'."
    exit /b 1
  )
  call :TaskDynamicEnvironmentSet "%~1\%~3%"
  
  call "%~2\%~3"
  if %errorlevel% neq 0 (
    call :Abort "Task: '" "%~3" "' in TASK_REQUEST_DIR: '" "%~1" "' failed with errorlevel: %errorlevel%."
    exit /b %errorlevel%
  )	
  :: successful task execution - delete request
  del "%~1\%~3" >nul
  if %errorlevel% neq 0 (
    call :Abort "Requested Task: '" "%~3" "' does not exist in TASK_REQUEST_DIR: '" "%~1" "'."
    exit /b 1
  )
endlocal
exit /b 0


:TaskDynamicEnvironmentSet:
::-- no setlocal - need dynamic environment variables visible to the task that will use them. 
::set TASK_REQUEST_PATHFILE=%~1

  :: A reasonable environment variable name is expected.  Not all valid name characters are allowed, like '?{}[]
  :: using ^ delimiter permits setting "for" statement options, like "delims" to an empty set
  for /F tokens^=*^ delims^=^ eol^=  %%v in ( 'type "%~1" ^| findstr /R /C:"^[a-z][a-z0-9\._\-\~]*=.*"' ) do (
	set %%v
  )
exit /b 0
 
  
::-- Determine if the transaction identifier has been defined before the configuration of this module.
::-- If it has, this module is a more primative element of an aggregate transaction.  Therefore, its
::-- logged error messages will reflect the aggregate transaction id.  This allows the "tracing" of
::-- an aggregate transaction through all its primative modules as they generate messages during their
::-- execution with the shared transaction identifier.  Otherwise, this module is being executed
::-- as a stand alone transaction, therefore, generate its own unique transaction id.
:TransactionRequest:
setlocal
  set TRANS_ID=%~1
  set GUID_BIND=%~2
  set TRAMS_ENV_VARIABLE_NAME=%~3
   
  if defined TRANS_ID exit /b 0
  if not defined GUID_BIND exit /b 0
  if not exist "%GUID_BIND%\gen.cmd" (
    call :Abort "Transaction ID generator defined by GUID_BIND:'" "%GUID_BIND%\gen" "' doesn't exist."
	exit /b 1
  )
  call "%GUID_BIND%\gen" TRANS_ID_VAR
  if %errorlevel% neq 0 (
    call :Abort "Problem encountered when generating unique Transaction Id."
    exit /b 1
  )
(
endlocal
set %TRAMS_ENV_VARIABLE_NAME%=%TRANS_ID_VAR%
)
exit /b 0


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0