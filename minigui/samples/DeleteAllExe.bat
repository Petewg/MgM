:: Delete All Samples
:: 
::
@ echo off


ren Advanced\7-Zip\7za.exe 7za.ex_
ren Advanced\ReStart\restart.exe restart.ex_
ren Applications\FREE_MEMORY\Memory.exe Memory.ex_


del basic\*.exe /s/q
del Advanced\*.exe /s/q
del Applications\*.exe /s/q


ren Advanced\7-Zip\7za.ex_ 7za.exe
ren Advanced\ReStart\restart.ex_ restart.exe
ren Applications\FREE_MEMORY\Memory.ex_ Memory.exe


:END
