::-----------------------------------------------------------------------------
::-- Configuration file settings needed by the DerivedReset.cmd script.
::-- This script is called from the same command processor as the DerivedReset.cmd script
::-- Therefore, you can use other environment variables within this command process,
::-- like the user specific %TEMP% variable, and it will refer to the same one visible to the 
::-- script.
::--
::-- Do not code a startlocal or endlocal within this script, at least at this top most level,
::-- as it will erase the values set by the script.
::-----------------------------------------------------------------------------
::-- The absolute path, without double quotes, to the ArgumentCheck routine.
set BIND_ARGUMENT=C:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Argument

::-- The absolute path, without double quotes, to the Vdisk methods.
set BIND_VDISK=C:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Vdisk

::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
set GUID_BIND=C:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\GUID

::-- The absolute path, without double quotes, to the configuration file for the
::-- DerivedMerge module.
set DERIVED_MERGE_CONFIG_FILE=%~f0

::-- The absolute path, without double quotes, to the configuration file for the
::-- DerivedReset module.
set DERIVED_RESET_CONFIG_FILE=%~f0

::-- The absolute path, enclosed in double quotes, to the differencing (a.k.a. - child/derived) VHD 
::-- To be deleted and then recreated to revert the image back to its
::-- last known state and then protect it moving forward from
::-- changes either intentional or malicious
set NATIVE_BOOT_DERIVED_FILE="C:\NativeBoot\Derived.vhd"

::-- The absolute path, enclosed in double quotes, to the base (a.k.a. - parent) VHD. 
::-- This VHD contains the application and OS programs that are essential 
::-- to delivering the services required by role assumed by a person using this image.
::-- For example, a BU student needs MS Office and Google docs to function at BU.
::-- Therefore, you would not see games or other exotic software included in the perminant image.
set NATIVE_BOOT_BASE_FILE="C:\NativeBoot\Win7Ultimate.vhd"

::-- The windows Volume (drive label name) assigned to the VHD.  Should reflect the role name of the
::-- person using this image.
set NATIVE_BOOT_VOL_NAME=Student

::-- The boot entry description name that will be assigned to the newly created derived VHD.  
::-- This name appears on the boot menu, and will become the default volume selected to boot,
::-- if not manually changed during the boot process.
set NATIVE_BOOT_LOADER_NAME=Student

::-- The absolute path, enclosed in double quotes, to a previously saved boot manager instance (a.k.a. template)
::-- containing the boot entries you wish to also potentially access when booting using this boot choice.
::-- Use "BCDedit /export" to create this template
set NATIVE_BOOT_BOOT_MANAGER_TEMPLATE="C:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\BootManager\Instances\PhysicalWin7GamesTemplate"

::-- The absolute path, absent double quotes, to the directory that contains the logging methods.
set LOGGER_BIND=C:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Logger
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- logger.
set LOGGER_CONFIG_FILE="C:\Users\zServicePC\Desktop\PC Configuration\System Utilities\Utilities\Logger\Config\Logger.cmd"


exit /b 0