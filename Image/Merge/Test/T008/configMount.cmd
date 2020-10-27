::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%BIND_ARGUMENT%
::
::-- Required: The absolute path, enclosed in double quotes, to the VHD being mounted.
set MOUNT_VDISK_FILE=%MOUNT_VDISK_FILE%
::
::-- Required: The drive letter (only - no colon ':') to assign the mounted VHD.
set MOUNT_VDISK_DRIVE_LETTER=%MOUNT_VDISK_DRIVE_LETTER%
::
::-- The absolute path, absent double quotes, to the directory that contains the logging methods.
set LOGGER_BIND=%LOGGER_BIND%
::
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- logger.
set LOGGER_CONFIG_FILE=%LOGGER_CONFIG_FILE%
::
::-- The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
set GUID_BIND=%GUID_BIND%
::