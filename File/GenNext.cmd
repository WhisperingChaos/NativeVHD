@echo off
goto Main

:Help:
  echo ::-----------------------------------------------------------------------------
  echo ::--
  echo ::--  Module:	%~f0
  echo ::--  Version:	1.0
  echo ::--  Author:	Richard Moyse
  echo ::--
  echo ::-- Purpose:
  echo ::--   Attempts to preserve the state of a file by copying it.  The copy is
  echo ::--   assigned a composite name whose first component consists of up to 250
  echo ::--   characters of the targeted file name suffixed by an underscore followed
  echo ::--   a nine digit decimal number.  Also, to preserve the state of the copied
  echo ::--   file, it's modify attribute is set to read only.
  echo ::--
  echo ::--   The composite name adheres to a deterministic generational scheme implemented
  echo ::--   by sequence label appended to the original file name (current generation).
  echo ::--   The sequence label is implemented as an integer appended to the
  echo ::--   original name.  The greater a file's squence value the more recently it
  echo ::--   was derived from the original file.
  echo ::--
  echo ::-- Assumes:
  echo ::--   1. Windows file name length limit 260 characters.
  echo ::--   2. Account running the script had the privileges needed Windows file name length limit 260 characters.
  echo ::--
  echo ::-- Input:
  echo ::--   1. ^%1: Either:
  echo ::--     The full path name to a configuration file containing	argument values.
  echo ::--			"/?" displays the "help".
  echo ::--
  echo ::-- Output:
  echo ::--   1. errorlevel:
  echo ::--			0: Successful execution of "/?"
  echo ::--     1: Failure
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
  echo ::-- Required: The absolute path, enclosed in double quotes, to the file whose
  echo ::-- name will be tagged (renamed) with a generational label
  echo ::-- as    layer being reverted.
  echo set GEN_BASE_FILE_NAME="<AbsoluteFilePath>"
  echo ::
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

exit /b 0


:Main:
setlocal
  
  if "%~1"=="" (
    call :Abort "Please specify configuration file as first and only parameter.  Example follows:"
    call :Help >&2
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
  call "%BIND_ARGUMENT%\Check" ARGUMENT_CHECK_EMPTY GEN_BASE_FILE_NAME
  if %errorlevel% neq 0 (
    if not exist "%BIND_ARGUMENT%\Check.cmd" (
      call :Abort "Failed to bind argument check.  No Check method at filepath:'%BIND_ARGUMENT%\Check'"
      exit /b 1
    )
    call :Abort "Following configuration variables must be defined:'%ARGUMENT_CHECK_EMPTY%'"
    call :Abort "Please correct errors in configuration file '%~1'"
    exit /b 1
  )
  if not exist %GEN_BASE_FILE_NAME% (
    call :Abort "GEN_BASE_FILE_NAME must exist:'" %GEN_BASE_FILE_NAME% "' does not exist or inaccessible due to permissions."
    exit /b 1
  )
  ::-- Module is configured, now log the start of this effort.
  call :Inform "Started: File: '" %GEN_BASE_FILE_NAME% "' generational"

  set seqNumCurrent=
  call :GenNumCurrentGet %GEN_BASE_FILE_NAME% seqNumCurrent^
  || exit /b 1

  set /a seqNumNext=seqNumCurrent+1
  set genCompositeFileName=
  call :CompositeNmBuild %GEN_BASE_FILE_NAME% %seqNumNext% genCompositeFileName^
  || exit /b 1

  if exist %genCompositeFileName% (
    call :Abort "Composite filename already exists genCompositeFileName:'" %genCompositeFileName% "' potential concurrent request or sequence number rollover."
	exit /b 1 
  )
  copy /b /v %GEN_BASE_FILE_NAME% %genCompositeFileName%>nul
  if %errorlevel% NEQ 0 (
    call :Abort "Unable to preserve GEN_BASE_FILE_NAME:'" %GEN_BASE_FILE_NAME% "' as:'" %genCompositeFileName% "' copy failed."
	exit /b 1
  )
pause  
  call :Inform "Ended: File: '" %GEN_BASE_FILE_NAME% "' generational: Successful"
  
endlocal
exit /b 0


:GenNumCurrentGet:
setlocal
set genCurrentPath=%~dp1
set genCurrentFileName=%~n1
set genCurrentFileExt=%~x1
set seqNumCurrentRTN=%2

  set seqNumCurrent=
  call :GenSequenceMostRecentGet "%genCurrentPath%" "%genCurrentFileName%" "%genCurrentFileExt%" seqNumCurrent
  if %errorlevel% NEQ 0 set seqNumCurrent=0
(
endlocal
set %seqNumCurrentRTN%=%seqNumCurrent%
exit /b 0
)

:GenSequenceMostRecentGet:
setlocal
set genCurrentPath=%~1
set genCurrentFileName=%~2
set genCurrentFileExt=%~3
set seqNumReturn=%4

  set seqNum=
  for /f %%f IN ('dir /b /o-n "%genCurrentPath%\%genCurrentFileName%_*%genCurrentFileExt%"') do (
    call :GenSequenceExtract: "%%f" seqNum^
	&& goto GenSequenceMostRecentGetBreak
  )
  exit /b 1
  
  :GenSequenceMostRecentGetBreak:
(
endlocal
set %seqNumReturn%=%seqNum%
exit /b 0
)


:GenSequenceExtract:
setlocal
set genName=%~n1
set seqNumReturn=%2

  set seqNum=%genName:~-10%
  echo %seqNum%|findstr /r /c:"^_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$">nul
  if %errorlevel% NEQ 0 exit /b 1
  set seqNum=%seqNum:~-9,9%
(
endlocal
set %seqNumReturn%=%seqNum%
exit /b 0
)


:CompositeNmBuild:
setlocal
set genCurrentPathFileName=%~dpn1
set genCurrentFileExt=%~x1
set seqNum=%2
set genFileNmRTN=%3

  set GEN_SEQNUM_MAX=999999999
  if %seqNum% GTR %GEN_SEQNUM_MAX% (
    call :Abort "Generation sequence number exceeded GEN_SEQNUM_MAX=%GEN_SEQNUM_MAX% ."
	exit /b 1
  )
  if %seqNum% LSS 1 (
    call :Abort "Generation sequence number not in range GEN_SEQNUM_MAX=1-%GEN_SEQNUM_MAX% ."
	exit /b 1
  )
  set seqNumPadded=000000000%seqNum%
  set seqNumPadded=%seqNumPadded:~-9%
(
endlocal 
set %genFileNmRTN%=^"%genCurrentPathFileName%_%seqNumPadded%%genCurrentFileExt%"
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