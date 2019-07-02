@echo off
goto Main

:Help:
  echo ::----------------------------------------------------------------------------->&2
  echo ::-->&2
  echo ::--  Module:	%~f0>&2
  echo ::--  Version:	1.1>&2
  echo ::--  Author:	Richard Moyse>&2	
  echo ::-->&2
  echo ::--  Purpose:>&2
  echo ::--	Generate a GUID.>&2
  echo ::-->&2
  echo ::--  Assumes:>&2
  echo ::--    1.  Powershell installed and available to batch command environment.
  echo ::-->&2
  echo ::--  Input:>&2
  echo ::--	1.  %1: Either and environment variable name whose value will reflect>&2
  echo ::--	        either a GUID or /? to display this help. >&2
  echo ::-->&2
  echo ::--  Output:>&2
  echo ::--	1.  When successful, the provided environmentvariable name>&2
  echo ::--	    will contain a GUID.  Otherwise, its value could be anything.>&2
  echo ::--	2.  errorlevel:>&2
  echo ::--		0: Successfully generated GUID.>&2
  echo ::--		1: Problem generating GUID.>&2
  echo ::-->&2
  echo ::----------------------------------------------------------------------------->&2
exit /b

:Main:
  setlocal

  if "%~1"=="/?" call :Help & exit /b 0
  if "%~1"==""   echo "Please specify name of environment variable to receive the GUID value">&2 & call :Help & exit /b 1

  powershell -command "exit" 1> nul 2>nul
  if not errorlevel 0 echo "Powershell environment not present/callable.  Need it to generate uuid.">&2 & exit /b 1  

  for /f %%u in ('powershell -command "$([guid]::NewGuid().ToString())"') do set GEN_PY_GUID=%%u

  if "%GEN_PY_GUID%" == "" exit /b 1 

  ::-- return GUID to caller via passed environment variable.
  endlocal & set %1=%GEN_PY_GUID%

exit /b 0
