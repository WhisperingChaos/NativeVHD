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
  echo ::--    Create a request to run another process. Place this request in a
  echo ::--    folder that's shared with the other process.  The request consists of
  echo ::--    two elements.  The first, the request's file name, must mirror the
  echo ::--    name of an executable file responsible for starting the "answering"
  echo ::--    process.  This executable file must exist in a directory accessible
  echo ::--    to only the entity responsible for running the answering process.
  echo ::--    The second element is a list of Windows batch environment variables
  echo ::--    and their values.  This list should only contain "dynamic" context
  echo ::--    required by the second answering process.  Dynamic context refers to
  echo ::--    argument values established during the execution of the first process.
  echo ::--    For example, the first requesting process' transaction GUID.  Providing
  echo ::--    this value permits the the second answering process to associate its
  echo ::--    log file history with the requester.
  echo ::--
  echo ::--    Static context required by the second answering process should be
  echo ::--    encoded in its own set of configuration files.
  echo ::--    
  echo ::--  Security:
  echo ::--    This segregation of request from its answer helps prevent malicious 
  echo ::--    code from being executed.  However, certain configuration changes in
  echo ::--    a request may require corresponding ones in the configuration files
  echo ::--    of the answering process.  
  echo ::--
  echo ::--  Assumes:
  echo ::--    1. The requesting process running this script has authority to write to
  echo ::--       the directory shared with the second process.
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
  echo ::-- Required: The absolute path, without double quotes, to the shared process directory.
  echo ::-- This should be identical to the path specified by a corresponding instance
  echo ::-- of the Task "Fetch" method.
  echo set TASK_CREATE_SHARED_REQUEST_DIR=^<AbsoluteFilePath^>
  echo ::
  echo ::-- Required: A filename, whose type refers to an executable, that maps to a
  echo ::-- requested task performed by another process.  Although the file type suggests
  echo ::-- an executable, the contents of this file doesn't contain "executable" code.
  echo ::-- Instead, it defines a list of batch environment variable names paired with their
  echo ::-- values that are made available to the process that actually performs the task.  
  echo set TASK_CREATE_NAME=^<FileName.ExecutableType^>
  echo ::
  echo ::-- Optional: An absolute file path name, without double quotes, to a file containing
  echo ::-- a Windows newline delimited list of environment variable names and their
  echo ::-- associated values.  An item in the list has the
  echo ::-- format: ^<EnvironmentVariableName^>=^<Value^> .  This list is appended to the
  echo ::-- contents of the newly created TASK_CREATE_NAME.  Use this method of providing
  echo ::-- dynamic context (passing dynamic arguments) to the process running the task.  For
  echo ::-- example, one can pass the dynamically assigned transaction GUID to the process that
  echo ::-- actually performs the task, as a means of maintaining continuity between the
  echo ::-- the currently process, that's making a request, to the one that performs it.
  echo ::-- Use the value of "STDIN" to "pipe" the list of environment variables to
  echo ::-- this create function.
  echo set TASK_CREATE_BODY_FILE=^<AbsoluteFilePath^>
  echo ::
  echo ::-- Optional: The absolute path, absent double quotes, to the directory that contains the logging methods.
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>
  echo ::
  echo ::-- Optional: The absolute path, enclosed in double quotes, to the configuration file needed by the
  echo ::-- logger.
  echo set LOGGER_CONFIG_FILE="^<LogConfigurationAbsoluteFilePath^>"
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
  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY TASK_CREATE_SHARED_REQUEST_DIR TASK_CREATE_NAME
  if %errorlevel% neq 0 (
    if not exist "%BIND_ARGUMENT%\Check.cmd" (
      call :Abort "Failed to bind argument check.  No Check method at filepath:'%BIND_ARGUMENT%\Check'."
      exit /b 1
    )
    call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
    call :Abort "Please correct errors in configuration file '%~1'"
    exit /b 1
  )
  if not exist "%TASK_CREATE_SHARED_REQUEST_DIR%" (
    call :Abort "Please specify a shared request directory: TASK_CREATE_SHARED_REQUEST_DIR:'" "%TASK_CREATE_SHARED_REQUEST_DIR%" "' that exists and is accessible."
	exit /b 1
  )
  if exist "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%" (
    call :Abort "Task request already exists:'" "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%" "'."
    exit /b 1
  )
  set PIPE_VIA_STDIN=F
  call :BodyFileCheck "%TASK_CREATE_BODY_FILE%" PIPE_VIA_STDIN
  if %errorlevel% neq 0 (
    call :Abort "Cannot find/access TASK_CREATE_BODY_FILE:'" "%TASK_CREATE_BODY_FILE%" "'."
	exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Started: Task: '" "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%" "' Create."

  echo :: Request Dynamic Variable Body> "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%"
  if not exist "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%" (
    call :Abort "Unable to create task named:'" "%TASK_CREATE_NAME%" "' in directory:'" "%TASK_CREATE_SHARED_REQUEST_DIR%" "'."
	exit /b 1
  )
  if "%TASK_CREATE_BODY_FILE%" == "" (
    goto MainExitSuccess
  )
  set FIND_BODY_INPUT="%TASK_CREATE_BODY_FILE%"
  if "%PIPE_VIA_STDIN%"=="T" (
    set FIND_BODY_INPUT=
	call :Inform "Body contents being streamed from STDIN via pipe."
  )
  :: allow anything in body.  It's up to FetchExecute to filter content.  For example, 
  :: fetchexecute currently scans for only environment variable "name=value" pairs. 
  find /V "" %FIND_BODY_INPUT% >>"%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%"
  if %errorlevel% neq 0 (
	call :Abort "Creation of task request body failed from TASK_CREATE_BODY_FILE:'" "%TASK_CREATE_BODY_FILE%" "'."
	exit /b 1
  )
:MainExitSuccess:
  call :Inform "Ended: Task: '" "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%" "' Create: Successful"
  
endlocal
exit /b 0


:BodyFileCheck:
setlocal
  set BODY_FILE=%~1
  set PIPE_RTN=%~2

  set PIPE_STDIN=F
  if "%BODY_FILE%" == "" (
	goto :BodyFileCheckExit
  )
  if /I "%BODY_FILE%" == "STDIN" (
    set PIPE_STDIN=T
	goto :BodyFileCheckExit
  )
  if not exist "%BODY_FILE%" (
    exit /b 1
  )
:BodyFileCheckExit:
(
endlocal
set %PIPE_RTN%=%PIPE_STDIN%
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