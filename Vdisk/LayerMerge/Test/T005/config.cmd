::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- The absolute path, enclosed in double quotes, to the Layered VHD being created.
set DERIVED_LAYER_FILE="%~dp0Layer.vhd"
::-- The absolute path, enclosed in double quotes, to the configuration file needed by the
::-- dispart executor.
set DISKPART_EXECUTOR_CONFIG_FILE="%~f0"