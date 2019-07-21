::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\Argument
::
::-- The absolute path, absent double quotes, to the directory that contains the logging methods.
set LOGGER_BIND=%~dp0\..\..\..\Logger
::
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- logger.
set LOGGER_CONFIG_FILE="%~f0"
::
::-- The absolute path, enclosed in double quotes, to a file designated
::-- as a log.
set LOG_FILE="%~dp0\log.txt"
::
::-- The absolute path, absent double quotes, to the directory that contains the logging methods.
set GUID_BIND=%~dp0\..\..\..\GUID