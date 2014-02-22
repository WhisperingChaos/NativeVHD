::-----------------------------------------------------------------------------
::-- Configuration file settings needed by the %~f0 script.
::-- This script is called from the same command processor as the %~f0 script
::-- Therefore, you can use other environment variables within this command process,
::-- like the user specific %%TEMP%% variable, and it will refer to the same one visible to the 
::-- script.
::--
::-- Do not code a startlocal or endlocal within this script, at least at this top most level,
::-- as it will erase the values set by the script.
::-----------------------------------------------------------------------------
::
::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=E:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Argument
::
::-- The absolute path, without double quotes, to the Boot Manager methods.
set BOOT_MANAGER_BIND=E:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\BootManager
::
::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
set GUID_BIND=E:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\GUID
::
::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
set STARTUP_BIND=E:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Startup
::
::-- The absolute path, absent double quotes, to the directory that contains the logging methods.
set LOGGER_BIND=E:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Logger
::
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- logger
set LOGGER_CONFIG_FILE="E:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Logger\Config\logger.cmd"
::
::-- The windows Volume (drive label name) assigned to the VHD.  Should reflect the role name of the
::-- person using this image.  The label name must not contain spaces.
set VOLUME_LABEL_TO_REVERT=Student
::
exit /b 0 
