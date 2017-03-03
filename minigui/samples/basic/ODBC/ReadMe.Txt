If you have trouble running this sample (usually a GPF) you must create your
own 'odbc32.lib' using implib utility:

c:\borland\bcc55\bin\implib odbc32.lib c:\windows\system32\odbc32.dll

Then you must copy odbc32.lib to your harbour's lib folder 
(c:\minigui\harbour\lib if you are using MiniGUI binary distribution).
