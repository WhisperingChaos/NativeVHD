:subroutine:
setlocal

call :QuoteRemove %LAYER_CANONICAL_LAYER_FILE% LAYER_CANONICAL_LAYER_FILE_NO_QUOTES
type %DISKPART_CMD_LOG_FILE% | findstr /C:"Filename: %LAYER_CANONICAL_LAYER_FILE_NO_QUOTES%" >nul 2>nul
if %errorlevel% NEQ 0 (
  call :Abort "Logic error - expected concordance between provided layer filepath: '" %LAYER_CANONICAL_LAYER_FILE% "' and actual filepath: '" "%LAYER_CANONICAL_LAYER_FILE_NO_QUOTES%" "'" 
  exit /b 1
)
for /F "token=1,2,3*" %%d in ( 'type %DISKPART_CMD_LOG_FILE% | findstr /C:"Parent Filename: " 2>nul') do call ExtractName %%d %%e "%%f" %
if %errorlevel% NEQ 0 (
  call :Abort "Mounted '" %MOUNT_VDISK_FILE% "' to incorrect drive letter"
  exit /b 1
)
endlocal  
exit /b 0


:QuoteRemove:
set local

endlocal && set $2=%~1
exit /b 0


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 