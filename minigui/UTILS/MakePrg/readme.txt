$Rev: 14 $

MakePrg.exe
-----------
Author: Phil Ide
(c) Copyright Phil Ide 2004, All Rights Reserved

This source is released under an Apache style licence.

Purpose:
--------
Creates source files ready for editing and adds a header section to
the start of the file.  If the file already exists, the header is
inserted at the top of the file.

Being the lazy sort of chap I am, I hate typing this header section each
time I create a new source file, and even cut'n'paste is waaaaay too
much effort for me.  I developed this applet to aid this task.
Originally I changed the value of individual content items by passing
a parameter for that item on the command line, but found that I tended
to forget what all the parameters were.  So I ended up just running
the applet without parameters and getting the default values and then
having to edit these in my editor when I loaded the source file.

This version resolves this issue completely by offering cascading
configuration files and the ability to create user-defines macros just
by editing one of the configuration files and not forcing me to
recompile the applet.

Usage:
------
The command line is simple:

  makeprg <file> [<message>] [mode]

Where:
  <file> is the file you wish to create or add the header to
  <message> will replace the $$MESSAGE$$ macro in the header
  <mode> is one of:
     /c = console mode
     /g = graphics mode

If you wish to omit <message> but still pass <mode>, you must pass a
null string for <message>:

   makeprg myfile.prg "" /g


Configuration files:
--------------------
The application searches for a configuration file.  It searches
various directories in the following order:

  1.  Current directory
  2.  %USERPROFILE%\Application Data\makePrg
  3.  The directory where the application (makeprg.exe) resides

The configuration file consists of several sections, and looks
somewhat similar to an *.ini file.  The various sections are described
below.  MakePrg will load each of the above files if it can find them,
and will use them in a preferential order when searching for items.  The
order it uses when searching for items is the same as that above.

--------------------
[console]
This section is followed by a list of #include files to replace the
$$INCLUDE%% macro.  The files are listed in the order they will appear
in the resulting source file.  This section is used when a console
mode source file is created.

  example:
   [console]
   common.ch
   appevent.ch

--------------------
[graphics]
This section is followed by a list of #include files to replace the
$$INCLUDE%% macro.  The files are listed in the order they will appear
in the resulting source file.  This section is used when a GUI mode
source file is created.

  example:
   [graphics]
   common.ch
   appevent.ch
   gra.ch
   xbp.ch

--------------------
[default]
If this section exists, it will be used to determine which mode the
sourcefile will be created for (console or graphics).  If <mode> is
passed on the command line, it will override the setting in
[default].  This section must contain a single item, 'mode', which
indicates the name of a section to use to create the #include macros.
This would usually be 'console' or 'graphics', but you can use any
name provided the section actually exists.

  example:
  [default]
  mode=console


--------------------
[vars]
This section is used to define additional macro's.  This may seem
silly when you can write the value straight into the header section, but
the [vars] section is handled slightly differently from the other
sections.

With the other sections, the search is performed in each of the
available config files in the order noted above.  As soon as a section
is found the search ends.  In other words, if the section is found in
the first config file, the other two are not searched for that section.

With the [vars] section though, all three files are searched (using
the same order).  When a section is found, it's user-defined variables
are loaded and added to the list of user-defined variables.  However,
a variable must be unique, and if an existing variable is found, the new
variable is discarded.  Therefore if you have a variable 'author'
defined in all three files, it will be loaded from the first file
(current directory) but not the others.  You can use this mechanism to
provide defaults.

For example, you might create a config file in the makeprg.exe home
directory with 'author=Guest'.  In the %USERPROFILE%\..\Makeprg
directory you could have 'author=Joe Bloggs'.  Then you can create a
config file in the local (source) directory which gives another name.
If this doesn't exist, MakePrg will use 'Joe Bloggs'.  If another user
logs onto the machine who doesn't have a config file in his home
directory, you will get 'Guest' unless you create an overide file in the
local source directory.

Macros are define in the format <name>=<value>

  example:
   [vars]
   system=MyProject
   author=Phil Ide

--------------------
[header]
This section *must* be the last section in the configuration file.  It
defines the data that will be written to the header section of the new
source file, and may contain embedded macros.  Please see "Using Macros"
below.

Predefined macros:
------------------
  FILE     - source file being created (includes path if this was passed
             as an argument to makeprg.exe!)

  DATE     - output in dd-MMM-yyyy format
  MESSAGE  - Second (optional) parameter passed to makeprg.exe
  TIME     - Time in HH:MM format
  DATETIME - Date in dd-MMM-yyyy HH:MM:SS format, e.g.
             14-May-2004 12:34:53


Using Macros:
------------------
To use a macro in the header section, bound the macro with '$$' signs:

  $$DATE$$

Note that predefined macros are case sensitive and must be in uppercase.

User-defined macros (from the [vars] section) are additionally inbound
by '%' signs:

  $$%system%$$

Further, you can reference environment variables in the same way:

  $$%path%$$

Note that neither user-defined macros nor environment variable
references are case sensitive.

