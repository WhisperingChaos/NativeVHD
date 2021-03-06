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
  echo ::--   Integrate derived image state into its base image by merging the
  echo ::--   protective, child VHD layer into its corresponding parent.  After
  echo ::--   a successful merge, delete the derived image then recreate it.  Why delete it?
  echo ::--   It returns disk space back to the drive.  Also, one can gauge the difference
  echo ::--   between a derived image and its base by simply viewing the size of the derived
  echo ::--   one.
  echo ::--
  echo ::-- Assumes:
  echo ::--   1. Executing script with Administrator privileges.
  echo ::--   2. Depends on Vdisk utilities.
  echo ::--
  echo ::-- Input:
  echo ::--   1. ^%1: Either:
  echo ::--      - The full path name to a configuration file containing argument values.
  echo ::--      - "/?" displays the "help".
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
  echo set BIND_ARGUMENT=^<ArgumentMethodsAbsoluteFilePath^>
  echo ::
  echo ::-- Required: The absolute path, without double quotes, to the Vdisk methods.
  echo set BIND_VDISK=^<VdiskMethodsAbsoluteFilePath^>
  echo ::
  echo ::-- Required: The absolute path, enclosed in double quotes, to the VHD layer being reverted.
  echo set MERGE_LAYER_FILE="<VHDAbsoluteFilePath>"
  echo ::
  echo ::-- Required: The absolute path, enclosed in double quotes, to the immediate parent of the VHD layer.
  echo set MERGE_CANONICAL_BASE_FILE="<VHDAbsoluteFilePath>"
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
  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY MERGE_LAYER_FILE MERGE_CANONICAL_BASE_FILE BIND_VDISK
  if %errorlevel% neq 0 (
    if not exist "%BIND_ARGUMENT%\Check.cmd" (
      call :Abort "Failed to bind argument check.  No Check method at filepath:'%BIND_ARGUMENT%\Check'"
      exit /b 1
    )
    call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
    call :Abort "Please correct errors in configuration file '%~1'"
    exit /b 1
  )
  if not exist %MERGE_LAYER_FILE% (
    call :Abort "MERGE_LAYER_FILE must exist to be reverted:'" %MERGE_LAYER_FILE% "' does not exist or inaccessible due to permissions."
    exit /b 1
  )
  if not exist %MERGE_CANONICAL_BASE_FILE% (
    call :Abort "MERGE_CANONICAL_BASE_FILE must exist to be reverted:'" %MERGE_CANONICAL_BASE_FILE% "' does not exist or inaccessible due to permissions."
    exit /b 1
  )
  set LAYER_CANONICAL_LAYER_FILE=MERGE_LAYER_FILE
  set LAYER_CANONICAL_OUTPUT_PARENT_FILE=MERGE_BASE_FILE
  for /F "tokens=1* delims=" %%k in ( 'call "%BIND_VDISK%LayerCanonicalParentPathGet.cmd" "%~dpn0\Subroutine\configLayerCanonicalParentPathGet.cmd" ^| findstr /R /C:"^set MERGE_BASE_FILE=.*"' ) do (
    call :CanonicalMatch %%k || exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Started: Image: " '%MERGE_LAYER_FILE%' " revert"
  
  set LAYER_MERGE_FILE=%MERGE_LAYER_FILE%
  call "%BIND_VDISK%LayerMerge.cmd" "%~dpn0\Subroutine\configLayerMerge.cmd"
  if %errorlevel% neq 0 exit /b 1

  set DELETE_VHD_FILE=%MERGE_LAYER_FILE%
  call "%BIND_VDISK%Delete.cmd" "%~dpn0\Subroutine\configDelete.cmd"
  if %errorlevel% neq 0 exit /b 1

  set BASE_LAYER_FILE=%MERGE_CANONICAL_BASE_FILE%
  set DERIVED_LAYER_FILE=%MERGE_LAYER_FILE%
  call "%BIND_VDISK%LayerCreate.cmd" "%~dpn0\Subroutine\configLayerCreate.cmd"
  if %errorlevel% neq 0 exit /b 1
  
  call :Inform "Ended: Image: '" %MERGE_LAYER_FILE% "' revert: Successful"
  
endlocal
exit /b 0


:CanonicalMatch:
setlocal

  if not "%1" == "set" (
    call :Abort "Logic error - expected 'set' but encountered: '" %1 "'"
  )
  %1 %2=%3
  if not %MERGE_BASE_FILE% == %MERGE_CANONICAL_BASE_FILE% (
    call :Abort "Canonical path to base layer MERGE_CANONICAL_BASE_FILE: '" %MERGE_CANONICAL_BASE_FILE% "' different from actual value: '" %MERGE_CANONICAL_BASE_FILE% "' referenced by MERGE_LAYER_FILE: '" %MERGE_LAYER_FILE% "'"
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