@call %~d0\miniguim\batch\SetPaths.bat
hbmk2 Demo-client hbct.hbc

@call %~d0\miniguim\batch\buildapp.bat Demo-Main          

del Demo-client.exe