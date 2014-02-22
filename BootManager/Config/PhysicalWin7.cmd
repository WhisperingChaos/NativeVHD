::-----------------------------------------------------------------------------
::-- Configuration file settings needed by the 
::-- \Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\BootManager\Replace.cmd script.
::-- This script is called from the same command processor as the
::-- \Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\BootManager\Replace.cmd script
::-- Therefore, you can use other environment variables within this command process,
::-- like the user specific %TEMP% variable, and it will refer to the same one visible to the
::-- script.
::--
::-- Do not code a startlocal or endlocal within this script, at least at this top most level,
::-- as it will erase the values set by the script.
::-----------------------------------------------------------------------------
::
::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~d0\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Argument
::
::-- The absolute path, absent double quotes, to the directory that contains
::-- the GUID generation methods.
set GUID_BIND=%~d0\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\GUID
::
::-- The absolute path, absent double quotes, to the directory that contains the logging methods.
set LOGGER_BIND=%~d0\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Logger
::
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- logger
set LOGGER_CONFIG_FILE="%~d0\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Logger\Config\Logger.cmd"
::
::-- The absolute path, enclosed in double quotes, to a previously
::-- saved boot manager instance containing the boot entry that should
::-- be immediately booted next time the machine is started.
::-- Use "BCDedit /export" to create this instance
set BOOT_MANAGER_INSTANCE="%~d0\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\BootManager\Instances\PhysicalWin7"
::
exit /b 0