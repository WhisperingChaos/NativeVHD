::-- Required: The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%BIND_ARGUMENT%
::
::-- Required: The absolute path, enclosed in double quotes, to the differencing (a.k.a. - child/derived) VHD 
::-- whose contents will be merged into its immediate parent VHD.
set LAYER_MERGE_FILE=%LAYER_MERGE_FILE%
::
::-- Optional: The absolute path, absent double quotes, to the directory that contains the logging methods.
set LOGGER_BIND=%LOGGER_BIND%
::
::-- Optional: The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- logger
set LOGGER_CONFIG_FILE=%LOGGER_CONFIG_FILE%
::
::-- Optional: The absolute path, absent double quotes, to the directory that contains the GUID generation methods.
set GUID_BIND=%GUID_BIND%
::