@echo off
call gen TRANSACTION_ID
if errorlevel 0 echo %TRANSACTION_ID%
if errorlevel 1 echo problem
pause
