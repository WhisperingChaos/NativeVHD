::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\Argument
::-- The absolute path, enclosed in double quotes, to the file containing the Test Table.
set TEST_TABLE_FILE="%~dp0\table.txt"
::-- Test use of quotes, pipe operator in test table and environment variable expansion.
::-- Do in "negative" perspective from T014 to ensure these tests are working as intended.
set TEST_NULLIFY_OUTPUT=NO
set T015_HI=bye
exit /b 0