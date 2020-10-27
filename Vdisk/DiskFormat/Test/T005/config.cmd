::-- The absolute path, without double quotes, to the Argument methods.
set BIND_ARGUMENT=%~dp0\..\..\..\..\Argument
::
::-- The absolute path, enclosed in double quotes, to the differencing (a.k.a. - child/derived) VHD >&2
::-- whose contents will be merged into its immediate parent VHD.>&2
set DISK_FORMAT_FILE="%~dp0\ShouldNotExist.vhd">&2
::
