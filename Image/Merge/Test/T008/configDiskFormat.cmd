set BIND_ARGUMENT=%BIND_ARGUMENT%
::
::-- Required: The absolute path, enclosed in double quotes, to the VHD being formatted.
set DISK_FORMAT_FILE=%DISK_FORMAT_FILE%
::
::-- Optional: The volume label to assign the VHD, enclosed in double quotes.
set DISK_FORMAT_VOLUME_LABEL=%DISK_FORMAT_VOLUME_LABEL%
::
::-- Optional: Destroy an existing partition: "NO" or "YES".  Defaults to "NO".
set DISK_FORMAT_DESTROY_EXISTING=%DISK_FORMAT_DESTROY_EXISTING%
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