::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- The absolute path, enclosed in double quotes, to the VHD being created.
set BASE_LAYER_FILE="%~dp0T005.vhd"
::
::-- The layer's size in MegaBytes (MB).
set BASE_LAYER_SIZE=10
::