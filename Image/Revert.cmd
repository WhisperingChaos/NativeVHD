@echo off
goto Main

:Help:
  echo ::----------------------------------------------------------------------------->&2
  echo ::-->&2
  echo ::--  Module:	%~f0>&2
  echo ::--  Version:	1.0>&2
  echo ::--  Author:	Richard Moyse>&2
  echo ::-->&2
  echo ::-- Purpose:>&2
  echo ::--   Rollback Image state to reflect base VHD state by deleting the VHD layer>&2
  echo ::--   that protects it.  After deleting this layer, recreate it to once again>&2
  echo ::--   protect the base VHD.>&2
  echo ::-->&2
  echo ::-- Assumes:>&2
  echo ::--   1. Executing script with Administrator privileges.>&2
  echo ::--   2. Depends on Vdisk utilities.>&2
  echo ::-->&2
  echo ::-- Input:>&2
  echo ::--   1. ^%1: Either:>&2
  echo ::--     The full path name to a configuration file containing	argument values.>&2
  echo ::--			"/?" displays the "help".>&2
  echo ::-->&2
  echo ::-- Output:>&2
  echo ::--   1. errorlevel:>&2
  echo ::--			0: Successful execution of "/?">&2
  echo ::--     1: Failure>&2
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
  echo ::-- Required: The absolute path, without double quotes, to the Argument methods.>&2
  echo set BIND_ARGUMENT=^<ArgumentMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- Required: The absolute path, without double quotes, to the Vdisk methods.>&2
  echo set BIND_VDISK=^<VdiskMethodsAbsoluteFilePath^>>&2
  echo ::>&2
  echo ::-- Required: The absolute path, enclosed in double quotes, to the VHD layer being reverted.>&2
  echo set REVERT_LAYER_FILE="<VHDAbsoluteFilePath>">&2
  echo ::>&2
  echo ::-- Required: The absolute path, enclosed in double quotes, to the immediate parent of the VHD layer.>&2
  echo set REVERT_CANONICAL_BASE_FILE="<VHDAbsoluteFilePath>">&2
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
  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY REVERT_LAYER_FILE REVERT_CANONICAL_BASE_FILE
  if %errorlevel% neq 0 (
    if not exist "%BIND_ARGUMENT%\Check.cmd" (
      call :Abort "Failed to bind argument check.  No Check method at filepath:'%BIND_ARGUMENT%\Check'"
      exit /b 1
    )
    call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
    call :Abort "Please correct errors in configuration file '%~1'"
    exit /b 1
  )
  if not exist %REVERT_LAYER_FILE% (
    call :Abort "REVERT_LAYER_FILE must exist to be reverted:'" %REVERT_LAYER_FILE% "' does not exist or inaccessible due to permissions."
    exit /b 1
  )
  if not exist %REVERT_CANONICAL_BASE_FILE% (
    call :Abort "REVERT_CANONICAL_BASE_FILE must exist to be reverted:'" %REVERT_CANONICAL_BASE_FILE% "' does not exist or inaccessible due to permissions."
    exit /b 1
  )
  for /F "tokens=1* delims=" %%k in ( 'call "%BIND_VDISK%LayerCanonicalParentPathGet.cmd" "%~dpn0\Subroutine\configLayerCanonicalParentPathGet.cmd" ^| findstr /R /C:"^set REVERT_BASE_FILE=.*"' ) do (
    call :CanonicalMatch %%k || exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Started: Image: " '%REVERT_LAYER_FILE%' " revert"
  
  set DELETE_VHD_FILE=%REVERT_LAYER_FILE%
  call "%BIND_VDISK%Delete.cmd" "%~dpn0\Subroutine\configDelete.cmd"
  
  set BASE_LAYER_FILE=%REVERT_CANONICAL_BASE_FILE%
  set DERIVED_LAYER_FILE=%REVERT_LAYER_FILE%
  call "%BIND_VDISK%LayerCreate.cmd" "%~dpn0\Subroutine\configLayerCreate.cmd"
  
  call :Inform "Ended: Image: '" %REVERT_LAYER_FILE% "' revert: Successful"
  
endlocal
exit /b 0


:CanonicalMatch:
setlocal

  if not "%1" == "set" (
    call :Abort "Logic error - expected 'set' but encountered: '" %1 "'"
  )
  %1 %2=%3
  if not %REVERT_BASE_FILE% == %REVERT_CANONICAL_BASE_FILE% (
    call :Abort "Canonical path to base layer REVERT_CANONICAL_BASE_FILE: '" %REVERT_CANONICAL_BASE_FILE% "' different from actual value: '" %REVERT_CANONICAL_BASE_FILE% "' referenced by REVERT_LAYER_FILE: '" %REVERT_LAYER_FILE% "'"
    exit /b 1
  )
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