@echo off
"%~dp0\..\Driver.cmd" "%~dp0\config.cmd" 2>&1 | find "hello" >nul
if %errorlevel% neq 0 echo "%~f0: failed!"