@echo off
"%~dp0\..\Driver.cmd" "%~dp0\config.cmd" 2>&1 | findstr /C:"SYSERR" /B >nul
if %errorlevel% neq 0 echo "%~f0: failed!"