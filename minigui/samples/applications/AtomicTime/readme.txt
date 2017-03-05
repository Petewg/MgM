AtomicTime v1.1
===============


Description
-----------
AtomicTime is a very simple time synchronizing program that retrieves the
accurate time from one of several specialized time servers on the Internet.
Once the network time has been retrieved the program can set your computer's
clock to match it.

Options in the program enable you to automatically obtain the time from the
time server and set your clock appropriately at program startup. It is also
possible to have the program automatically exit after the time has been set
and so is ideal for running a program at Windows Startup to sync your clock
when your computer is started.

AtomicTime uses the standard Time protocol (UDP port 37). See RFC 868 for
more details. The time retrieved from the network time server is given
as the number of seconds since midnight on January 1st 1900. Since the
protocol only allows accuracy down to the second you may not get the most
accurate time possible but it is usually good enough to always be within
about half a second of "true" time. Network latency is accommodated in the
calculations involved in setting your computer clock.


Requirements
------------
Works on Win2K, WinNT, Win98, WinME, WinXP.
Should work on Win95 but not tested.


Installation
------------
Unzip all the files into one directory. That's all!
No dll's or other complicated files to be installed!
After this you can run AtomicTime by double clicking on the AtomicTime.exe
file. 


Usage
-----
Clicking the setup button ">>" shows you the program options. Clicking the
same button will hide the options.

The setup options allows you to choose the time server that is used by
selecting from a preset list in the dropdown list. You may prefer to use
one that is located nearer your computer for faster responses.

Select whether you want the program to automatically obtain and synchronize
to the network time when you start the program by clicking in the "Auto
sync at program startup" checkbox.

Select whether you want the program to exit after it has synced your clock
time by clicking in the "Exit after time has been synced" checkbox. If you
have this option set, the next time you start the program you can prevent
the program from exiting by de-selecting this same checkbox.


Disclaimer
----------
This product is supplied AS IS. 
That means I support this product on my free will only. No upgrades, patches
or other stuff is provided on a regular basis.
I also bear no responsibilities for any damage to the software installed on
your PC caused by any actions when using this product.

If you have a minute to drop me an e-mail I will be happy if you share in it
your opinion about the program.


Distribution
------------
You may NOT distribute this software by any type of media or network device or
tool including the Internet. You may have only one copy of the installation 
package of this software.
You are not allowed to use this software for any commercial purposes. Personal
use, unlimited and unrestricted, is allowed.


Contacts
--------
In case you have any questions about this product please direct them to one (or
better both) of my e-mail addresses: gfilatov@inbox.ru, gfilatov@front.ru.


Best regards,
Grigory Filatov
October 2004
