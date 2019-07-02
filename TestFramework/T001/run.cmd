@echo off
"%~dp0\..\Driver.cmd" "%~dp0\config.cmd" | find "hello" >nul
if %errorlevel% neq 0 echo "%~f0: failed!"