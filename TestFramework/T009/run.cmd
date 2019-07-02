@echo off
setlocal

  set TEST_FILE_PATH="%~dp0\testOut.txt"
  call :capture "%~dp0\..\Driver.cmd"  "%~dp0\config.cmd"  > %TEST_FILE_PATH%
  if %errorlevel% neq 1 echo "%~f0: failed!" & exit /b 1
  
  findstr "TEST_ON_FAILURE.*misspelled" %TEST_FILE_PATH% >nul
  if %errorlevel% neq 0 echo "%~f0: failed!" & exit /b 1

 del %TEST_FILE_PATH% >nul

endlocal
exit /b 0

:capture:

call %1 %2 2>&1

exit /b
