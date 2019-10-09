@echo off
:main:
setlocal

  set TEST_TABLE_FILE="%~dp0testTable.txt"
  set TEST_VDISK_METHOD_PATH=%~dp0..\
  
  call :TestTableDelete
  if %errorlevel% neq 0 exit /b 1 

  call :TestTableGen
  if %errorlevel% neq 0 exit /b 1

  call "%TEST_VDISK_METHOD_PATH%..\testFramework\Driver.cmd"  "%~dp0\config.cmd" >nul
  if %errorlevel% neq 0 exit /b 1
  
  call :TestTableDelete
  
endlocal
exit /b %errorlevel%


:TestTableDelete:

  if exist %TEST_TABLE_FILE% (
    del %TEST_TABLE_FILE% >nul
    exit /b %errorlevel%
  )
exit /b 0


:TestTableGen:
setlocal

  for /F "tokens=1,2*" %%D in ( 'dir /b /ad %TEST_VDISK_METHOD_PATH%') do (
    call :TestMethodIsDefined "%%D" && call :TestTableAppend "%%D"
  )

endlocal
exit /b 0


:TestMethodIsDefined:
setlocal
  ::-- ignore garbage
  if "%~1" == "" exit /b 1
  ::-- limit testing while testing the test.
  ::if /I not "%~1"=="Delete" exit /b 1
  ::-- Don't even consider including test directory, even if it doesn't have
  ::-- a "test" subdirectory, to prevent potential deadly recursion.
  if /I "%~1" == "test" exit /b 1
  ::-- Must have a test directory
  call :TestCmdFileGen "%~1" TEST_METHOD_CMMD_FILE
  if not exist %TEST_METHOD_CMMD_FILE% exit /b 1

endlocal
exit /b 0


:TestTableAppend:

  call :TestCmdFileGen "%~1" TEST_METHOD_CMMD_FILE
  echo %~1 } neq 0 } %TEST_METHOD_CMMD_FILE%>>%TEST_TABLE_FILE%
  
exit /b 0


:TestCmdFileGen:

  set %2="%TEST_VDISK_METHOD_PATH%%~1\test\test.cmd"
  
exit /b 0