@echo off
goto Main

:Help:
  echo ::----------------------------------------------------------------------------->&2
  echo ::-->&2
  echo ::--  Module:	%~f0>&2
  echo ::--  Version:	1.0>&2
  echo ::--  Author:	Richard Moyse>&2	
  echo ::-->&2
  echo ::--  Purpose:>&2
  echo ::--	Generate a GUID.>&2
  echo ::-->&2
  echo ::--  Assumes:>&2
  echo ::--    1.  Portable-Python located in C:\Program Files\meld-1.7.3.0\python>&2
  echo ::--	   Poratable-Python provides GUID generator object.
  echo ::-->&2
  echo ::--  Input:>&2
  echo ::--	1.  %1: Either and environment variable name whose value will reflect>&2
  echo ::--	        either a GUID or /? to display this help. >&2
  echo ::-->&2
  echo ::--  Output:>&2
  echo ::--	1.  When successful, the provided provided environmentvariable name>&2
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
  
  set GEN_PY_PYTHON_BIND=C:\Program Files\meld-1.7.3.0\python
  if not exist "%GEN_PY_PYTHON_BIND%\Python-Portable.exe" exit /b 1

  set GEN_PY=%TEMP%\%~nx0.%RANDOM%.py
  set GEN_PY_OUTPUT=%GEN_PY%.output
  ::-- Generate Python script to produce GUID
  echo import uuid>"%GEN_PY%"
  echo f=open('%GEN_PY_OUTPUT%','w')>>"%GEN_PY%"
  echo f.write(str(uuid.uuid4()))>>"%GEN_PY%"
  echo f.close()>>"%GEN_PY%"

  if not exist "%GEN_PY%" exit /b 1 
  ::-- call Python to execute script
  call "%GEN_PY_PYTHON_BIND%\Python-Portable" "%GEN_PY%"

  if not exist "%GEN_PY_OUTPUT%" exit /b 1
  ::-- make sure GUID was created
  set /P GEN_PY_GUID=<"%GEN_PY_OUTPUT%"
  if "%GEN_PY_GUID%"=="" exit /b 1
  ::-- GUID generation most likely successful now delete temp files
  del "%GEN_PY_OUTPUT%">nul
  del "%GEN_PY%">nul

  ::-- return GUID to caller via passed environment variable.
  endlocal & set %1=%GEN_PY_GUID%

exit /b 0
