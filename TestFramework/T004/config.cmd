::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\Argument
::
::-- The absolute path, enclosed in double quotes, to the file containing the Test Table.
set TEST_TABLE_FILE="%~dp0\table.txt"
::--  Test to suppress SYSERR  
set TEST_NULLIFY_OUTPUT=SYSERR
::
exit /b 0