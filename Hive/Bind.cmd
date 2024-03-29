@echo off
::-----------------------------------------------------------------------------
::--
::--  Provides a dynamic (during runtime) "Bind" service to permit a module
::--  to request, find, and get addressability to the services offerred by
::--  another module.  Essentially, one can create
::--  a composite module by linking together a number of other modules.  The
::--  composite module would contain batch calls with some specific name and
::--  its arguments.  This name can then reference some implementation that 
::--  matches the name and can accept the arguments.  It's very similar to a
::--  "Windows Registry".
::--
::--  Input: %0 - The location of this module.  It forms the root of 
::--              the module hive.
::--
::--         %1 - The environment variable that will be assigned the bound
::--              location of the requested hive.
::--   
::--         %2 - The hive name to locate
::--
::--
::--  Output:
::--      PATH -  Windows PATH variable directory list prefixed with the
::--              directory path of the given successfully bound module.
::--
::--
::--  a redirection entry is given precedence over an actual entry.
::--
::-----------------------------------------------------------------------------
:Main:
  
  setlocal

  set MODULE_NAME_PRIMARY=%~dp0
  ::--  create path to module hive.  Hive must be relative to directory containing this linker.
  set HIVE_FOR_MODULE=%~dp0%~2
  ::--  determine if requested module hive exists
  if not exist "%HIVE_FOR_MODULE%" call :Abort "Hive does not exist: '%HIVE_FOR_MODULE%'" & exit /B
  ::--  does redirect exist?
  ::--  see if an executable module exists in hive location.
  where /R "%HIVE_FOR_MODULE%" "%~n1.*" 1>nul 2>nul
  if errorlevel 1 call :Abort "No executable module not found in hive: '%HIVE_FOR_MODULE%'" & exit /B
  ::--  successfully located module now include it in PATH variable as the first directory
  ::--  Since it's positioned as the first directory, this module will be found before any others
  ::--  in the path.
  endlocal & SET PATH=%HIVE_FOR_MODULE%;%PATH%

exit /b 0


:RootHere:

  set MODULE_NAME_PRIMARY=%~dp0
  if "%2"=="" set DRIVE_LST=H:I
  :DriveLstTry:
    if "%DRIVE_LST%"=="" (
      call :Abort "Hive does not support this method: '%~1' specify: 'Bind' or 'RootHere'
      exit /b
    )
    subst %DRIVE_LST:1,2% "%MODULE_NAME_PRIMARY%"
    if errorlevel 1 (
      set DRIVE_LST=%DRIVE_LST:1,2%
      goto DriveLstTry
    )

exit /b 0



::-----------------------------------------------------------------------------
::--
::--  Generate a standard abort message directed to syserr and set return
::--  code to iindicate failure.  
::--  
::--  Code written assumes no log module present.
::--
::--  Input:
::--	%1  - Message content
::--
::--  Output:
::--    Abort messsage written to syserr
::--    errorlevel = 1
::--  
::-----------------------------------------------------------------------------
:Abort:

  echo "Abort", "%MODULE_NAME_PRIMARY%", "%DATE:~4%", "%TIME%", "%~1"

exit /b 1