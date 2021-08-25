@echo off
setlocal

  call "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  if not defined TASK_FETCH_PATH set TASK_FETCH_PATH=..\..\..\

  call :TestDirDelete "%TASK_FETCH_SHARED_SCAN_DIR%"
  set TASK_NAME=TaskDisplayVariableValue.cmd
  call :TaskSharedCreate "%TASK_FETCH_SHARED_SCAN_DIR%" "%TASK_NAME%"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  set VARIABLE_NAME=NHN.TRANSACTION_ID
  set VARIABLE_VALUE=Transaction GUID
  call :TaskSharedDynamicEnvironmentVariable "%TASK_FETCH_SHARED_SCAN_DIR%\%TASK_NAME%" "%VARIABLE_NAME%" "%VARIABLE_VALUE%"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call :TestDirDelete "%TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR%"
  call :TaskPrivateCreate "%TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR%" "%TASK_NAME%" "%VARIABLE_NAME%" "%VARIABLE_VALUE%"
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  call "%TASK_FETCH_PATH%\FetchExecute.cmd" "%~dp0\config.cmd" | findstr /R /C:"%VARIABLE_VALUE%" >nul 2>nul
  if %errorlevel% NEQ 0 exit /b %errorlevel%

  if exist "%TASK_FETCH_SHARED_SCAN_DIR%\%TASK_NAME%" exit /b 1
  
  call :TestDirDelete "%TASK_FETCH_SHARED_SCAN_DIR%
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call :TestDirDelete "%TASK_FETCH_PRIVATE_IMPLEMENTATION_DIR%"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
endlocal
exit /b 0


:TaskSharedCreate:
setlocal
  set DIR_SHARED=%~1
  set TASK_NAME=%~2
  
  mkdir "%DIR_SHARED%" >nul
  echo Shared>"%DIR_SHARED%\%TASK_NAME%"
  if not exist "%DIR_SHARED%\%TASK_NAME%" exit /b 1
  
endlocal
exit /b 0


:TaskSharedDynamicEnvironmentVariable:
setlocal
  set TASK_SHARED_PATHFILE_NAME=%~1
  set VARIABLE_NAME=%~2
  set VARIABLE_VALUE=%~3

  if not exist "%TASK_SHARED_PATHFILE_NAME%" exit /b 1
  
  echo %VARIABLE_NAME%=%VARIABLE_VALUE%>>"%TASK_SHARED_PATHFILE_NAME%"
  if %errorlevel% neq 0 exit /b 1
  
endlocal
exit /b 0  


:TaskPrivateCreate:
setlocal
  set DIR_PRIVATE=%~1
  set TASK_NAME=%~2
  set VARIABLE_NAME=%~3
  set VARIABLE_VALUE=%~4
  
  mkdir "%DIR_PRIVATE%" >nul
  (
  echo @echo off
  echo setlocal
  echo echo %%%VARIABLE_NAME%%%
  echo endlocal
  echo exit /b 0
  )>"%DIR_PRIVATE%\%TASK_NAME%"
 
endlocal
exit /b 0  


:TestDirDelete:
setlocal
  set DIR_NAME=%~n1
  
  ::-- shared directory should be within directory of this test program.
  ::-- limit directory removal so poorly sepecified config setting doesn't
  ::-- arbitarily remove a directory like the root.
  if not exist "%~dp0\%DIR_NAME%" goto TestDirDeleteSuccess
  
  rmdir /s /q "%~dp0\%DIR_NAME%" >&2
  if %errorlevel% neq 0 exit /b %errorlevel%

:TestDirDeleteSuccess:
endlocal
exit /b 0