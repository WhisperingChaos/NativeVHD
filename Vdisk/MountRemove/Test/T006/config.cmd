::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- Required: The absolute path, enclosed in double quotes, to the VHD being mounted.>&2
set MOUNT_REMOVE_VDISK_FILE=%TEST_VHD_FILE%
::
::-- Required: The drive letter (only - no colon ':') to assign the mounted VHD.>&2
set MOUNT_REMOVE_VDISK_DRIVE_LETTER=P
::