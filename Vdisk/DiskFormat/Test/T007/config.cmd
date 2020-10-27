::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- Required: The absolute path, enclosed in double quotes, to the VHD being formatted.
set DISK_FORMAT_FILE=%TEST_VHD_FILE%
::
::-- Optional: The volume label to assign the VHD, enclosed in double quotes.
set DISK_FORMAT_VOLUME_LABEL="VolumeLabel"
::
