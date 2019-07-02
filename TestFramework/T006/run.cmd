@echo off
"%~dp0\..\Driver.cmd" "%~dp0\config.cmd" 2>&1 | findstr /C:"SYSERR" /C:"SYSOUT" >nul
if %errorlevel% neq 1 echo "%~f0: failed!"