del /q /f /s     "C:\Users\zServicePc\AppData\Local\Temp\*.*">nul
del /q /f /s /AH "C:\Users\zServicePc\AppData\Local\Temp\*.*">nul
del /q /f /s     "C:\Users\Aman\AppData\Local\Temp\*.*">nul
del /q /f /s /AH "C:\Users\Aman\AppData\Local\Temp\*.*">nul
del /q /f /s     "C:\Windows\Temp\*.*">nul
del /q /f /s /AH "C:\Windows\Temp\*.*">nul
del /q /f        "C:\TDSSKiller.*log.txt">nul
rd /q /s         "C:\Users\zServicePc\AppData\Local\Mozilla\Firefox\Profiles\r3uln8j2.default\Cache">nul
mkdir            "C:\Users\zServicePc\AppData\Local\Mozilla\Firefox\Profiles\r3uln8j2.default\Cache">nul
rd /q /s         "C:\Users\zServicePc\AppData\Local\Mozilla\Firefox\Profiles\r3uln8j2.default\OfflineCache">nul
mkdir            "C:\Users\zServicePc\AppData\Local\Mozilla\Firefox\Profiles\r3uln8j2.default\OfflineCache">nul
rd /q /s	 "C:\Users\Aman\AppData\Local\Mozilla\Firefox\Profiles\8hv8ja2k.default\Cache">nul
mkdir            "C:\Users\Aman\AppData\Local\Mozilla\Firefox\Profiles\8hv8ja2k.default\Cache">nul
rd /q /s	 "C:\Users\Aman\AppData\Local\Mozilla\Firefox\Profiles\8hv8ja2k.default\OfflineCache">nul
mkdir            "C:\Users\Aman\AppData\Local\Mozilla\Firefox\Profiles\8hv8ja2k.default\OfflineCache">nul
schtasks /Run /TN "\Student\TempFileDeleteAman">nul
schtasks /Run /TN "\Student\RecycleBinEmptyAman">nul
schtasks /Run /TN "\Student\TempFileDeletezServicePC">nul
schtasks /Run /TN "\Student\RecycleBinEmptyzServicePC">nul
