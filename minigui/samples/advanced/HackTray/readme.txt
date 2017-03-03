Manipulating The Windows Taskbar

Introduction

Most often when visiting VC++ forums, we see questions like how to show the ShutDown dialog, Logoff dialog, how to lock the windows taskbar and others. Hence it quite fascinated me to try out a few things with the windows taskbar. The article is a result of this fascination. :) 

Well this article is for those who don't know how to do this. This article simply lists the message numbers which when sent to the taskbar makes it do something (so don't expect too much). ;) 

The Message Numbers

Note: I am using WM_COMMAND and the message number goes into the WPARAM parameter.

Serial. 	Msg Number 	Description Of The Message 
1. 	305 	Displays the Start menu
2. 	401 	Displays Run Dialog
3. 	402 	Displays Logoff Dialog
4. 	403 	Command to cascade all toplevel windows
5. 	404 	Command to Tile Horizontally all top level windows
6. 	405 	Command to Tile Vertically all top level windows
7. 	407 	Shows the desktop. Do look at message number 419.
8. 	408 	Shows the Date and Time Dialog
9. 	413 	Shows taskbar properties
10. 	415 	Minimize all windows
11. 	416 	Maximize all windows. To see the effect of this command first do Minimize and then Maximize all. 
12. 	419 	Well I am a bit confused about this message. This also shows the desktop. Maybe somebody can notice the difference.
13. 	420 	Shows task manager
14. 	421 	Opens Customize Taskbar Dialog
15. 	424 	Locks the taskbar
16. 	503 	Opens Help and Support Center Dialog
17. 	505 	Opens Control panel
18. 	506 	Shows the Shutdown computer dialog
19. 	510 	Displays the Printers and Faxes dialog
20. 	41093 	Displays Find Files Dialog
21. 	41094 	Displays Find Computers Dialog

Watch Out

You might have noticed the huge gap between the last few messages. I didn't find any in between this. I think there might be some but maybe I didn't notice it. For example, the Lock statusbar message number. Initially I didn't notice the difference but when I tried to resize the taskbar LOL then I realised something had happened. Heh I was quick to retest the whole thing to find out which message number caused the event.

How Can You Help Me

Well if you know of any other messages, please tell me. I will post them here along with the others.

Disclaimer

I don't know how reliable this information is. Well all of them work in WinXP and 2000. Please test the above information before using it. The author does not take any responsibility for any kind of damage caused due to this article. Please use this at your own risk.

License

This article, along with any associated source code and files, is licensed under The Code Project Open License (CPOL)

About the Author

Nibu babu thomas
