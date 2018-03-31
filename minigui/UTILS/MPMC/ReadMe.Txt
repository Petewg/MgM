MiniGUI Project Manager - Console Version (MPMC) is a tool intented to speed up 
the application building process. It uses MAKE tool bundled with BCC compiler.

This way, only modified files are recompiled speeding building process a lot.

Usage: mpmc <ProjectFile> [/d] [/c]

/d: Debug
/c: Clean the temporary and OBJ files

Look at \MINIGUI\UTILS\MPM\SAMPLE\DEMO.MPM For configuration details.

Environment settings (Bcc Folder, Harbour Folder and MiniGUI Folder)
are stored in 'mpm.ini' file, located at Windows folder. This file is created
the first time you run MPM GUI version and automatically updated by it.

You can create it manually if you want. This is an example:

	BCCFOLDER=C:\BORLAND\BCC55
	MINIGUIFOLDER=C:\MINIGUI
	HARBOURFOLDER=C:\MINIGUI\HARBOUR

Enjoy!