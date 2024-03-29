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
  echo ::-- Purpose:
  echo ::--   Establish default boot entry given its description or GUID.
  echo ::--
  echo ::-- Assumes:
  echo ::--   1. Executing script with Administrator privileges.
  echo ::--   2. Depends on bcdedit.
  echo ::--
  echo ::-- Input:
  echo ::--   1. ^%1: Either:
  echo ::--      full path name to a configuration file containing argument values
  echo ::--      or
  echo ::--      "/?" displays the "help".
  echo ::--
  echo ::-- Output:
  echo ::--   1. errorlevel:
  echo ::--      0: Successful execution
  echo ::--      1: Failure
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
  echo ::-- Required: Either a boot entry's description or GUID.  If description specified,
  echo ::-- its text must exactly match all characters in the boot entry's description.
  echo ::-- A description must also uniquely identify a boot entry.  If GUID is specified,
  echo ::-- it must be encapsulated in brackets: {}.  A GUID match takes precedence over
  echo ::-- a matching description.
  echo set BOOT_ENTRY_DESCRIPTION_OR_GUID=^{^<BootEntryGUID^>^}
  echo ::
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
  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY BOOT_ENTRY_DESCRIPTION_OR_GUID
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
  call :Inform "Start: Boot Entry: '" %BOOT_ENTRY_DESCRIPTION_OR_GUID% "' default set."

  call bcdedit | findstr /R /C:"Access is denied" >nul
  if %errorlevel% == 0 (
    call :Abort "Failed to set BOOT_ENTRY_DESCRIPTION_OR_GUID:'%BOOT_ENTRY_DESCRIPTION_OR_GUID%' as default."  " Please run with Administrator priviledges."
    exit /b 1
  )
  call :GUIDsearch "%BOOT_ENTRY_DESCRIPTION_OR_GUID%" BOOT_GUID
  if %errorlevel% neq 0 (
    call :Abort "Could not find boot entry associated to BOOT_ENTRY_DESCRIPTION_OR_GUID:'%BOOT_ENTRY_DESCRIPTION_OR_GUID%'."
    exit /b 1
  )
  call bcdedit /default %BOOT_GUID% >nul
  if %errorlevel% neq 0 (
    call :Abort "Failure when attempting to set default boot entry using GUID:'%BOOT_GUID%'"
    exit /b 1
  )
  call :Inform "Ended: Boot Entry: '%BOOT_ENTRY_DESCRIPTION_OR_GUID%' default set: Successful"
  
endlocal
exit /b 0


:GUIDsearch:
setlocal
set BOOT_ENTRY_DESCRIPTION_OR_GUID=%~1
set BOOT_GUID_RTN=%~2

  ::-- precedence to GUID
  call bcdedit /v | findstr /R /C:"identifier" | findstr /R /C:"%BOOT_ENTRY_DESCRIPTION_OR_GUID%" >nul
  if %errorlevel% == 0 (
    endlocal
    set %BOOT_GUID_RTN%=%BOOT_ENTRY_DESCRIPTION_OR_GUID%
    exit /b 0
  )
  set ENTRY_CNT=0
  for /f "tokens=1" %%g in ( 'call "%~dp0\GUIDtoDescriptionMapGen.cmd" ^| findstr /R /C:"%BOOT_ENTRY_DESCRIPTION_OR_GUID%"') do (
    call :GUIDGet "%%g" ENTRY_CNT ENTRY_GUID
    if errorlevel 1 exit /b 1
  )
  if %ENTRY_CNT% equ 0 (
    call :Abort "Provided BOOT_ENTRY_DESCRIPTION_OR_GUID:'%BOOT_ENTRY_DESCRIPTION_OR_GUID%' not associated to any boot entry."
    exit /b 1
  )
  if %ENTRY_CNT% gtr 1 (
    call :Abort "Provided BOOT_ENTRY_DESCRIPTION_OR_GUID:'%BOOT_ENTRY_DESCRIPTION_OR_GUID%' selects more than one boot entry."
    exit /b 1
  )
( endlocal
  set %BOOT_GUID_RTN%=%ENTRY_GUID%
  exit /b 0
)


:GUIDGet:
setlocal
  set GUID_IN=%~1
  set ENTRY_CNT_RTN=%~2
  set ENTRY_GUID_RTN=%~3
  
  if "%GUID_IN%" == "" (
    call :Abort "GUID not specified check GUID to Description map."
    exit /b 1
  )
  echo %GUID_IN% | findstr /R /C:"\{.*}" >nul
  if not %errorlevel% == 0 (
    call :Abort "Invalid GUID format: GUID_IN:'%GUID_IN%'."
    exit /b 1
  )
( endlocal
  set /a %ENTRY_CNT_RTN%+=1
  set %ENTRY_GUID_RTN%=%GUID_IN%
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