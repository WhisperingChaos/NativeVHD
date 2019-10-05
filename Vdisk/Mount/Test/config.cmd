::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\Argument
::
::-- The absolute path, enclosed in double quotes, to the file containing the Test Table.
set TEST_TABLE_FILE="%~dp0\testTable.txt"
::
::-- Direct test output to 'nul' device. Valid values: 'NO', 'SYSOUT', 'SYSERR', or 'BOTH'.  Default is 'BOTH'.
::-- Note: redirection operator ^> can be specified for each command in the test table.  Therefore, specifying 'NO'
::-- allows complete control of redirection by each command.
set TEST_NULLIFY_OUTPUT=BOTH
::
::-- Determine if running tests after a failure should continue.  Valid values: 'EXIT', or 'CONTINUE'.  Default is 'CONTINUE'.
set TEST_ON_FAILURE=EXIT
set VDISK_METHOD_PATH=%~dp0\..\..\