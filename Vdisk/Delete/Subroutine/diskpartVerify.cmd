:subroutine:
setlocal

  for /F "delims=" %%M in ('del %DELETE_VHD_FILE% ^>nul 2^>^&1') do call :Abort "Delete of DELETE_VHD_FILE '" %DELETE_VHD_FILE% "' failed because: " "%%M"  
  if %errorlevel% neq 0 exit /b 1
    
endlocal
exit /b 0


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 


