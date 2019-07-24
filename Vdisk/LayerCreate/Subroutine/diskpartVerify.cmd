:subroutine:

  if not exist %DERIVED_LAYER_FILE% (
    call :Abort "Can't find newly created: '" %DERIVED_LAYER_FILE% "'. See contents of: '" %DISKPART_CREATE_CMD_FILE% "'"
    exit /b 1
  )
exit /b 0


:Abort:
  echo /t "Abort" /p "%~f0" /m "%~1%~2%~3%~4%~5%~6%~7%~8%~9" >&2
  if not "%LOGGER_BIND%"=="" call "%LOGGER_BIND%\Record" %LOGGER_CONFIG_FILE% "%NHN.TRANSACTION_ID%" "Abort" "%~f0" "%~1%~2%~3%~4%~5%~6%~7%~8%~9"
exit /b 1 