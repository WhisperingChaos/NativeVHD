@echo off
goto Main

:Help:
(
  echo ::-----------------------------------------------------------------------------
  echo ::--
  echo ::--  Module:	%~f0
  echo ::--  Version:	1.0
  echo ::--  Author:	Richard Moyse
  echo ::--
  echo ::-- Purpose:
  echo ::--   Produces a map from one or more BCD boot loader entries.  The map rows
  echo ::--   consist of an entry's GUID followed by its Description attribute.  Also,
  echo ::--   a space separates the GUID from its dedescription.
  echo ::--
  echo ::-- Assumes:
  echo ::--   1. Executing script with Administrator privileges.
  echo ::--   2. Depends on bcdedit.
  echo ::--   3. BCD store associated to current OS instance.
  echo ::--
  echo ::-- Input:
  echo ::--   Use "/?" to view this help text.
  echo ::--
  echo ::-- Output:
  echo ::--   1. STDOUT:  Stream of map rows.
  echo ::--   2. errorlevel
  echo ::--      0: Successful execution
  echo ::--      1: Failure
  echo ::--
  echo ::-----------------------------------------------------------------------------
)>&2
 
:Main:
setlocal

  if "%~1"=="/?" (
    call :Help
    exit /b 0
  )
  call bcdedit.exe /v >nul
  if %errorlevel% neq 0 exit /b 1
    
  set PARSE_STATE=
  for /F "tokens=1,*" %%e in ('bcdedit.exe /v') do (
    call :Parser "%%e" "%%f"
    if errorlevel 1 (
      endlocal
      exit /b 1
    )
  )
endlocal
exit /b 0


:Parser:
setlocal 
  set TOKEN_LEFTMOST=%~1
  set TOKENS_REMAINING=%~2

  set PARSE_STATE_RTN=PARSE_STATE

  call :IsLoaderFind "%TOKENS_REMAINING%"
  if errorlevel 1 (
    endlocal
    set ENTRY_GUID=
    set ENTRY_DESC=
	set %PARSE_STATE_RTN%=entrystart
    exit /b 0
  )
  if not "%PARSE_STATE%" == "entrystart" (
    exit /b 0
  )
  call :IsEntryAttrib identifier ENTRY_GUID "%TOKEN_LEFTMOST%" "%TOKENS_REMAINING%"
  if errorlevel 1 goto ParseAttribFound
  call :IsEntryAttrib description ENTRY_DESC "%TOKEN_LEFTMOST%" "%TOKENS_REMAINING%"
  if errorlevel 1 goto ParseAttribFound
  exit /b 0
  :ParseAttribFound:
  if "%ENTRY_DESC%" == "" (
    endlocal
	set ENTRY_GUID=%ENTRY_GUID%
    exit /b 0
  )
  if "%ENTRY_GUID%" == "" (
    endlocal
	set ENTRY_DESC=%ENTRY_DESC%
    exit /b 0
  )
  echo %ENTRY_GUID% %ENTRY_DESC%
  set PARSE_STATE=entryfind
endlocal
exit /b 0

  
:IsLoaderFind:
setlocal 
  set TOKENS_REMAINING=%~1

  if "Boot Loader" == "%TOKENS_REMAINING%" (
    exit /b 1
  )
endlocal
exit /b 0


:IsEntryAttrib:
setlocal 
  set ENTRY_ATTRIB_NAME=%1
  set ENTRY_ATTRIB_VALUE_RTN=%2
  set TOKEN_LEFTMOST=%~3
  set TOKENS_REMAINING=%~4

  if not "%ENTRY_ATTRIB_NAME%" == "%TOKEN_LEFTMOST%" (
    exit /b 0
  )
( endlocal
  set %ENTRY_ATTRIB_VALUE_RTN%=%TOKENS_REMAINING%
  exit /b 1
)