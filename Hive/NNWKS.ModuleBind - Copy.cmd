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
::--         %1 - The relative directory to find the implementation of
::--              this module.  It is "relative" to the root directory
::--              of this module hive.  Since this relative directory
::--              can be composed of other parent directories, a parent
::--              direcotry can, for example, represenet a name space.
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
  set MODULE_NAME_PRIMARY=%~dpn0
  ::--  create path to module hive.  Hive must be relative to directory containing this linker.
  set HIVE_FOR_MODULE=%~dp0%~1
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