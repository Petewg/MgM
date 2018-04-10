How to compile MySQL libraries?

Step by step instructions:

1) Install MySQL Server on yor machine - don't forget to choose custom installation option and check
include files to be installed. Example here is for MySQL 5.1 version.

2) From 'C:\Program Files\MySQL\MySQL Server 5.1\include\' copy ALL files to 'C:\minigui\source\MySQL\'

3) From 'C:\Program Files\MySQL\MySQL Server 5.1\bin\' copy file 'libmysql.dll' to 'C:\minigui\source\MySQL\'

4) RUN: makelib

5) if linker cannot find function HB_NTOS() then MiniGUI harbour binary is not yet in sync with official Harbour
In 'tmysql.prg' simply add at the end:

static function hb_ntos(nValue)
return ltrim(str(nValue))

6) When everything is ok new 'mysql.lib' is created in 'C:\MiniGUI\Harbour\lib\'.

7) RUN: "implib libmySQL.lib libmySQL.dll" and copy 'libmysql.lib' to 'C:\MiniGUI\Harbour\lib\'.

Explanation:

The Borland linker does not like the 'libmySQL.lib' library that comes with MySQL, it gives this error message:
Error: 'LIBMYSQL.LIB' contains invalid OMF record, type 0x21 (possibly COFF)
You can get around this problem by creating this lib from "dll" version of the library with implib command.


8) 'libmysql.dll' must be copied to each MiniGUI app that uses MySQL server


--
Mitja Podgornik <yamamoto@rocketmail.com>
