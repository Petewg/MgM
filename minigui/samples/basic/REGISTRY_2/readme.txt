Setting F12 as a global hotkey in Windows
Tue, 2011.12.13 - 17:19 — muzso
 
I used to set the F12 key in Ubuntu as the global hotkey to play/pause the current song in my music player
(since my keyboard does not have media keys). Very useful since it's a key that is easy to find and press
(eg. pressing a key that is surrounded by other keys requires a lot more attention/concentration from you).
However in Windows F12 does not work as a hotkey (by default). If an app tries to register F12 as a global
hotkey, it'll get an error.

If you google on the topic, you'll find the description of the RegisterHotKey function. It mentions that:
The F12 key is reserved for use by the debugger at all times, so it should not be registered as a hot key.
Even when you are not debugging an application, F12 is reserved in case a kernel-mode debugger or a just-
in-time debugger is resident.

Now this is pretty much upsetting. But not all is lost.
I tried to google for a way to disable the kernel from registering F12, but found instead the description
of the HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug\UserDebuggerHotKey registry key. Modifying
this you can set the keycode (scancode) that is registered as a global hotkey for the debugger. By default
it's value is zero (0x0), but you can set it to eg. 0x2F (VK_HELP) which is not present on most PC keyboards,
thus you can free up the F12 key.  Of course a reboot is necessary after having set this registry key.

PS: of course if you use a debugger, you should either leave this as it is, or set it to a key that you're
comfortable with.

Details description of UserDebuggerHotKey from MSDN:
http://technet.microsoft.com/en-us/library/cc786263.aspx