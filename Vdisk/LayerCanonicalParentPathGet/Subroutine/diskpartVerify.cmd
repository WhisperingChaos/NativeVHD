:subroutine:
setlocal

  call :QuoteRemove %LAYER_CANONICAL_LAYER_FILE% LAYER_CANONICAL_LAYER_FILE_NO_QUOTES
  type %DISKPART_CMD_LOG_FILE% | findstr /C:"Filename: %LAYER_CANONICAL_LAYER_FILE_NO_QUOTES%" >nul 2>nul
  if %errorlevel% NEQ 0 (
    call :Abort "Logic error - expected concordance between provided layer filepath: '" %LAYER_CANONICAL_LAYER_FILE% "' and actual filepath." 
    exit /b 1
  )
  type %DISKPART_CMD_LOG_FILE% | findstr /C:"Is Child: Yes" >nul 2>nul
  if %errorlevel% NEQ 0 (
    call :Abort "LAYER_CANONICAL_LAYER_FILE: '" %LAYER_CANONICAL_LAYER_FILE% "' refers to a base VHD - not a layer." 
    exit /b 1
  )
  for /F "tokens=1,2,3*" %%d in ( 'type %DISKPART_CMD_LOG_FILE% ^| findstr /C:"Parent Filename: " 2^>nul' ) do (
    call :CanonicalNameExtract %%d %%e "%%f" %LAYER_CANONICAL_OUTPUT_PARENT_FILE% || exit /b
  )
  if %errorlevel% neq 0 (
    call :Abort "Logic error - expected to find 'Parent Filename:' attribute for LAYER_CANONICAL_LAYER_FILE:'" %LAYER_CANONICAL_LAYER_FILE% "'"
    exit /b 1
  )
endlocal
exit /b 0


:QuoteRemove:
  
  set $2=%~1
  
exit /b 0


:CanonicalNameExtract:

  if not "%1" == "Parent" (
    call :Abort "Logic error - expected 'Parent' but found: '" "%1" "'"
    exit /b 1
  )  
  if not "%2" == "Filename:" (
    call :Abort "Logic error - expected 'Filename:' but found: '" "%2" "'"
    exit /b 1
  )
  echo set %4=%3
  
exit /b 0

  
:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1