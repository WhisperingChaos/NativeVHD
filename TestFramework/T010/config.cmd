::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\Argument
::
::-- The absolute path, enclosed in double quotes, to the file containing the Test Table.
set TEST_TABLE_FILE="%~dp0\table.txt"
::-- Test to suppress both SYSOUT & SYSERR - as default
::-- set TEST_NULLIFY_OUTPUT=BOTH 
::-- Determine if running tests after a failure should continue.  Valid values: 'EXIT', or 'CONTINUE'.  Default is 'CONTINUE'.
::-- Test stop after first error - 'EXIT'
set TEST_ON_FAILURE=EXIT
::
exit /b 0