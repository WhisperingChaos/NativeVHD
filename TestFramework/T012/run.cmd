@echo off
setlocal
  :: make log environment variables available 
  call "%~dp0\config.cmd" 
  
  :: delete possible leftover log file
  del %LOG_FILE% >nul 2>nul
  
  set TEST_FILE_PATH="%~dp0\testOut.txt"
  call :capture "%~dp0\..\Driver.cmd"  "%~dp0\config.cmd" > %TEST_FILE_PATH%
  if %errorlevel% neq 0 echo "%~f0: failed!" & exit /b 1

  findstr /C:"Inform" %TEST_FILE_PATH% >nul
  if %errorlevel% neq 0 echo "%~f0: failed!" & exit /b 1

  del %TEST_FILE_PATH% >nul

  if not exist %LOG_FILE% echo "%~f0: failed!" & exit /b 1

  :: make sure GUID specified
  findstr "\/k \"[1234567890abcdef-][1234567890abcdef-]*\"" %LOG_FILE% >nul
  if %errorlevel% neq 0 echo "%~f0: failed!" & exit /b 1

  findstr /C:"Abort" %LOG_FILE% >nul
  if %errorlevel% neq 1 echo "%~f0: failed!" & exit /b 1

  del %LOG_FILE% >nul
  
endlocal
exit /b 0

:capture:

call %1 %2 2>&1

exit /b
