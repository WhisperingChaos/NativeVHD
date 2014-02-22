@echo off
goto Main

:Help:
  echo ::-----------------------------------------------------------------------------
  echo ::--
  echo ::--  Purpose:
  echo ::--	Insure that the provided list of configuration options to this routine
  echo ::--	have been provided.
  echo ::--
  echo ::--  Assumes:
  echo ::--    1.  The configuration file has been executed before calling this
  echo ::--	    routine so the environment variables containing the configuration
  echo ::--	    have been defined.
  echo ::--    2.  Currently assumes that all settings must be specified.
  echo ::--
  echo ::--  Input:
  echo ::--	1.  %1: The name of an environment variable to contain the name(s)
  echo ::--		 of variables that haven't been defined.
  echo ::--		 every configuration variable to be examined.
  echo ::--	2.  %2-n: N number of environment variable names to check.
  echo ::--
  echo ::--  Output:
  echo ::--    1.  The enviornment variable name passed as %1 will either contain a list 
  echo ::--	    of one or more missing environment variable names or it will be empty.
  echo ::--    2.  errorlevel:
  echo ::--		0: All variables have been defined
  echo ::--		1: At least one variable hasn't been defined.
  echo ::--
  echo ::-----------------------------------------------------------------------------
exit /b 0

:Main:
  setlocal

  if "%~1"=="/?" call :Help & exit /b 0

  set ARGUMENT_CHECK_EMPTY=
  :ArgumentCheckNext:

    if "%2"=="" goto ArgumentCheckExit
    call :ArgumentIsEmpty %%%2%%
    if errorlevel 1 call set ARGUMENT_CHECK_EMPTY=%ARGUMENT_CHECK_EMPTY% %2
    shift /2

  goto ArgumentCheckNext

  :ArgumentIsEmpty:
    if "%~1"=="" exit /b 1
  exit /b 0

  :ArgumentCheckExit:
    set ARGUMENT_CHECK_ERRORLVL=1
    if "%ARGUMENT_CHECK_EMPTY%"=="" set ARGUMENT_CHECK_ERRORLVL=0
endlocal & set %1=%ARGUMENT_CHECK_EMPTY% & exit /b %ARGUMENT_CHECK_ERRORLVL% 
