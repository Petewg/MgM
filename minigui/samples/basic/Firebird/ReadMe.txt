
This is a little example of how to access a Firebird database
through a ODBC driver. 

Is based on sample ODBC_2 from MiniGUI Extended v1.9.98 package.

To install Firebird you need to go to page :
http://www.firebirdsql.org/ , then choose Downloads, Server
Packages , Firebird 2.5 and download the Windows executable 
installer (6.4Mb), also choose ODBC Driver and download 
the Windows Full Install (1.0Mb).

Run both installers with the default options. Copy the 
\Firebird directory to C:\MiniGUI\Samples\Basic and double
click the compile batch file to create the executable.

This example is running by default in a local server (the
client and the server are in the same machine), but it very
easy to use a non local database only by indicating in the 
connection string the complete path of the database file; 
For example :

Local Machine :

    ...;DBNAME=EMPLOYEE.FDB;')

External Server :

    ...;DBNAME=192.168.1.20:C:\Data\EMPLOYEE.FDB;')


Of course you must always install the ODBC driver on the 
client machine.

You must note that the grid is not showing "live" data; The
data shown is from the loading time and in a multiuser 
enviroment, the SQL data could be changed from another PCs.
You can use the Reload button to load the actual sql data
and update the grid.

Greats
Hugo Rozas
hugo.rozas@gmail.com










