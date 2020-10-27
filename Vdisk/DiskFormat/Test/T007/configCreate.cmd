::
::-----------------------------------------------------------------------------
::-- Configuration file settings needed by the Q:\Vdisk\BaseCreate.cmd script.
::-- This script is called from the same command processor as the Q:\Vdisk\BaseCreate.cmd script
::-- Therefore, you can use other environment variables within this command process,
::-- like the user specific %TEMP% variable, and it will refer to the same one visible to the 
::-- script.
::--
::-- Do not code a startlocal or endlocal within this script, at least at this top most level,
::-- as it will erase the values set by the script.
::-----------------------------------------------------------------------------
::
::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0..\..\..\..\Argument
::
::-- The absolute path, enclosed in double quotes, to the VHD being created.
set BASE_LAYER_FILE=%TEST_VHD_FILE%
::
::-- The layer's size in MegaBytes (MB).
set BASE_LAYER_SIZE=10
::