@echo off
setlocal

  if not defined METHOD_PATH (
    set METHOD_PATH=%~dp0\..\..\..\
  )
  call "%METHOD_PATH%\DefaultSet.cmd" "%~dp0\config.cmd" 2>&1 | findstr /R /C:"Abort.*Failed to set BOOT_ENTRY_DESCRIPTION_OR_GUID:.*as default.*Please run with Administrator priviledges"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
endlocal
exit /b %errorlevel%