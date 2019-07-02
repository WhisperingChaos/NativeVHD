::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\Argument
::-- The absolute path, enclosed in double quotes, to the file containing the Test Table.
set TEST_TABLE_FILE="%~dp0\table.txt"
::-- Test logging with GUID
set LOGGER_BIND="%~dp0\..\..\logger"
::-- This file is also the logging config file
set LOGGER_CONFIG_FILE="%~f0"
set LOG_FILE="%~dp0\log.txt"
set GUID_BIND="%~dp0\..\..\GUID"
exit /b 0