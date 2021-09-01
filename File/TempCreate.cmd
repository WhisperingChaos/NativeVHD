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
  echo ::--	   Create a temporary file and return its absolute file path name.
  echo ::--    install packages.  Prepare to "revert" the current OS image to its
  echo ::--    most recently "merged" state.
  echo ::--
  echo ::--  Assumes:
  echo ::--    1.  Relies on Windows BCDedit feature of Windows 7 and above.
  echo ::--    2.  The OS is managed as a set of Virtual Hard Drives ^(VHDs^) where
  echo ::--        a bootable child VHD protects the state of its parent VHD.
  echo ::--
  echo ::--  Input:
  echo ::--	1.  %1: Either:
  echo ::--		 	The full path name to a configuration file conatining
  echo ::--		 	argument values.
  echo ::--			"/?" displays the "help".
  echo ::--
  echo ::--  Output:
  echo ::--	1.  A request to revert the current installation that's processed by
  echo ::--     a "utility" bootable partition.
  echo ::--	2.  errorlevel:
  echo ::--		0: Either:
  echo ::--			Successful execution of "/?"
  echo ::--			Preparations to revert the desired volume was successful.
  echo ::--		1: Failure.
  echo ::--
  echo ::-----------------------------------------------------------------------------
  echo ::
  echo ::
  echo ::-----------------------------------------------------------------------------
  echo ::-- Configuration file settings needed by the %~f0 script.
  echo ::-- This script is called from the same command processor as the %~f0 script
  echo ::-- Therefore, you can use other environment variables within this command process,
  echo ::-- like the user specific %%TEMP%% variable, and it will refer to the same one visible to the 
  echo ::-- script.
  echo ::--
  echo ::-- Do not code a startlocal or endlocal within this script, at least at this top most level,
  echo ::-- as it will erase the values set by the script.
  echo ::-----------------------------------------------------------------------------
  echo ::
  echo ::-- Required: The absolute path, without double quotes, to the Argument methods.
  echo set BIND_ARGUMENT=^<ArgumentCheckAbsoluteFilePath^>
  echo ::
  echo ::-- Required: Specifies either a environment variable to receive the newly created
  echo ::-- temporary file.
  echo set FILE_TEMP_CREATE_ABSOLUTE_FILEPATH_OUT=^<EnvironmentVariableName^>
  echo ::
  echo ::-- Required: The absolute path, absent double quotes, to an existing directory that
  echo ::-- will contain the temporary file.  Default specified by Windows TEMP environment
  echo ::-- variable.  
  echo set FILE_TEMP_CREATE_PATH=%TEMP%
  echo ::
  echo ::-- Optional: An optional prefix applied to tempfile name.  
  echo set FILE_TEMP_CREATE_PREFIX=^<TempFilePrefix^>
  echo ::
  echo ::-- Optional: An optional suffix applied to tempfile name.  A suffix may
  echo ::-- include a file extension.
  echo set FILE_TEMP_CREATE_SUFFIX=^<TempFileSuffix^>
  echo ::
  echo ::-- Optional: The absolute path, absent double quotes, to the directory that contains the logging methods.
  echo set LOGGER_BIND=^<LogMethodsAbsoluteFilePath^>
  echo ::
  echo ::-- Optional: The absolute path, enclosed in double quotes, to the configuration file needed by the
  echo ::-- logger
  echo set LOGGER_CONFIG_FILE="<LogConfigurationAbsoluteFilePath>"
  echo ::
  echo ::-- Optional: The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
  echo set GUID_BIND=^<GUIDmethodsAbsoluteFilePath^>
  echo ::

  echo exit /b 0
)>&2

exit /b

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
  if errorlevel 1 ( 
    call :Abort "Problem detected while processing paramters from configuration file:'%~1'."
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
  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY FILE_TEMP_CREATE_ABSOLUTE_FILEPATH_OUT FILE_TEMP_CREATE_PATH
  if errorlevel 1 (
    call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'."
    call :Abort "Please correct errors in configuration file '%~1'."
    exit /b 1
  )
  if not exist "%FILE_TEMP_CREATE_PATH%" (
    call :Abort "Directory to contain temp file doesn't exist: FILE_TEMP_CREATE_PATH:'%FILE_TEMP_CREATE_PATH%'."
    exit /b 1
  ) 
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Starting: Temparary File Create:'%FILE_TEMP_CREATE_PATH%'."
  call :FileCreate "%FILE_TEMP_CREATE_PATH%" "%FILE_TEMP_CREATE_PREFIX%" "%FILE_TEMP_CREATE_SUFFIX%" TEMP_FILEPATH 
  call :Inform "Ended: Temparary File Create:'%FILE_TEMP_CREATE_PATH%'" " Successful."

( endlocal
  set %FILE_TEMP_CREATE_ABSOLUTE_FILEPATH_OUT%=%TEMP_FILEPATH%
  exit /b 0
)


:FileCreate:
setlocal EnableDelayedExpansion
  set DIRECTORY=%~1
  set PREFIX=%~2
  set SUFFIX=%~3
  set TEMP_FILEPATH_RTN=%~4
  
  for /L %%i in (0,1,9) do (
    set MIDDLE=!MIDDLE!!RANDOM!
    set PATH_FILE_NAME=%DIRECTORY%\%PREFIX%!MIDDLE!%SUFFIX%%EXTENSION%
    if not exist "!PATH_FILE_NAME!" goto :FileCreateBreak
  )
  call :Abort "Cannot generate unique file name.  Final attempt:'%PATH_FILE_NAME%'."
  exit /b 1
  :FileCreateBreak:
  type nul>"%PATH_FILE_NAME%"
( endlocal
  set %TEMP_FILEPATH_RTN%=%PATH_FILE_NAME%
  exit /b 0
)	


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


:Inform:
  echo /t "Inform" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Inform" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 0