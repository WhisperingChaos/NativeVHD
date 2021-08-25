@echo off
setlocal

  call "%~dp0\config.cmd"
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  call :TestArtifactsRemove
  if %errorlevel% NEQ 0 exit /b %errorlevel%
  
  if not defined METHOD_PATH (
    set METHOD_PATH=%~dp0\..\..\..\
  )
  call :TestPreConfig
  if %errorlevel% neq 0 exit /b %errorlevel%

  call "%METHOD_PATH%\Create.cmd" "%~dp0\config.cmd"
  if %errorlevel% neq 0 exit /b %errorlevel%

  call :TestValidation
  if %errorlevel% neq 0 exit /b %errorlevel%
	
  call :TestArtifactsRemove
  if %errorlevel% neq 0 exit /b %errorlevel%
  
endlocal
exit /b %errorlevel%


:TestArtifactsRemove:

  if not exist "%TASK_CREATE_SHARED_REQUEST_DIR%" (
    goto :TestArtifactsRemoveExit
  )
  del "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%" > nul 2> nul
  rmdir "%TASK_CREATE_SHARED_REQUEST_DIR%" > nul 2> nul
  if %errorlevel% neq 0 (
	echo Abort: unexpected files in TASK_CREATE_SHARED_REQUEST_DIR: '%TASK_CREATE_SHARED_REQUEST_DIR%' >&2
	exit /b 1
  )
:TestArtifactsRemoveExit:
exit /b 0


:TestPreConfig:

  mkdir "%TASK_CREATE_SHARED_REQUEST_DIR%"
  if %errorlevel% neq 0 (
  	echo Abort: Can't create TASK_CREATE_SHARED_REQUEST_DIR: '%TASK_CREATE_SHARED_REQUEST_DIR%' >&2
	exit /b 1
  )
 exit /b 0


:TestValidation:
  
  if not exist "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%" (
    echo Abort: failed to create TASK_CREATE_NAME: '%TASK_CREATE_NAME%' in directory TASK_CREATE_SHARED_REQUEST_DIR: '%TASK_CREATE_SHARED_REQUEST_DIR%'. >&2
	exit /b 1
  )
  type "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%"  | find ":: Request Dynamic Variable Body" >nul
  if %errorlevel% neq 0 (
  	echo Abort: Missing task body preface. >&2
	exit /b 1
  )
  type "%TASK_CREATE_SHARED_REQUEST_DIR%\%TASK_CREATE_NAME%"  | find /v ":: Request Dynamic Variable Body" >&2
  if %errorlevel% neq 1 (
  	echo Abort: Expecting only preface but other data in task body.>&2
	exit /b 1
  )
exit /b 0