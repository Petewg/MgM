Report Interpreter Generation IV - Windows 98/NT/2000/XP/VISTA/SEVEN/8.1
Copyright (c) 2002-2015 Pierpaolo Martinello. All Rights Reserved.

TERMS OF USE:
~~~~~~~~~~~~~
This software is FREEWARE.
It contains no warranties/guaranties of any kind inferred of implied.
I am not responsible for any damage/harm/loss or data directly/indirectly that
this program may cause.
That means you will not receive nag screens asking you to pay money after a
certain amount of time.
In turn this program may be distributed freely as long as it is not modified
without notify the author.

IMPORTANT:
~~~~~~~~~~
I will not provide full, but only minimal support for this program.

SOURCE CODE:
~~~~~~~~~~~~
All included source is Copyright(c) 2002-2015 Pierpaolo Martinello, unless otherwise stated.
The code is provided AS IS.
It contains no warranties/guaranties of any kind inferred of implied.
I am not responsible for any damage/harm/loss or data directly/indirectly that
this code may cause.
USE AT YOUR OWN RISK.

Whats News:
~~~~~~~~~~~

January 2018
    Mitigated annoying debugger messages by printing incorrect barcodes
	
December 2017
    Fixed wrong interpretation of command SET HPDFINFO DATECREATED ....

November 2017
    Added new commands to support font attibute in group section.
    New: SET GROUPBOLD    // Default .T.
    New: SET HGROUPCOLOR  // Default BLUE
    New: SET GTGROUPCOLOR // Default BLUE

May 2015
    Added more support to compatibility between hbprinter, miniprint and pdfprint
    in particular, added support for the "strikeout" font in pdfprint but without
    the angle option, added support for SET EXTRA TEXTCHAR in Pdfprint.
    Fixed a bug using scripts with Miniprint.

August 2014
    Optimizing the function MSGT, removed the old C code and Use
    of the internal functions of MiniGUI.

July 2013
    New feature: improved charset support for miniprint( unfinished for the pdf! )
    patch to improve the handling of arrays

May 2013  Version 4 Beta 3
    New feature: Generation of barcode without the aid of specific fonts,
    available for all versions of Interface.
    Putarray and memosay is also available for Miniprint and PDFPrint.
    Many commands are usable in all interfaces.
    Updated on debug mode (can evaluate the entire row or single parameter).
    Add optional Vertical and Horizontal Rules.
    Harupdf, discovered undocumented limit: does not handle font larger than 300 pts.

April 2013  Version 4 Beta 2
    Changed many internal functions
    Implemented the option "List by group" for Miniprint/Pdfprint
    Added compatibility between PICTURE and PRINT IMAGE commands
    Added support for print Tif and Png images even at Miniprint and Hbprinter
    Implemented the SET MARGIN for MINIPRINT

February 2013  Version 4 Beta 1
    Fix bugs and new test version
    Added support for the creation of reports in Pdf
    This version is considered as Beta release

December 2012
    Correct bug in the press of empty databases

December 2011
    Correct bug in the press of the fields memo
    introduced in the conversion in oop.
    Implemented possibility to stamp array
    with the functions Putarray and memosay.
    Putarray is not (for now) supported in Miniprint
    you use memosay if prorprio you want to use Miniprint

November 2011
   Objects language test.
   Improved the debug: on error case the signalings are sent forth
   once alone and reassumed at the end of the press and/or preview
   The demo of 2page/recno (file ReportD.mod) can switch from 
   MiniPrint and HbPrinter only change the first char.

October 2011
   Add debug capability for miniprint section ,little revision
   and new demo

October 2009

BugFix for memo implementation and new demo

History
Aug 2009

   Extended the use of the options FONT and COLOR for the commands
   "TEXTOUT","DRAW TEXT","PRINT","SAY" using MINIPRINT syntax
   Reduced the source code in use

Febr 2009
    Minority bug Fix
    Added support for all windows colors included in hbprinter
    enhanced debugger, now show the exact line with the error and if debug is set
    off (default) do not stop the program.
    Revised group option.
    Enhanced script, now define font is not necessary, you can define the font
    directly in the same line of field, as miniprint implementation.
    Added code for dual implementation (hbprinter/miniprint)(Beta for now).

December 20 Th 2008
    Revision of the abilities of group, evaluation of the string of description
    of group and of description of total of group using the operator {|| exp }
    Sees Winreport.chm for details.
    Patches to show the total and correct number of page when it is listed
    a single database

June 17 th 2008
    Implemented latest Hbprinter changes (added SET USER PAPERSIZE)
    Changed Ntrim definition

June 5 th 2008
    Implemented change cursor waiting for printing procedure
    Implemented the possibility to use variables and fields to point out a picture
Fix
    Removed Set Epoch (by request from italian programmer)
    Correct bug in the declaration of a variable as array
    Calculation of the pages to be fixed (found bug using a codeblock in the filter of the db)
    Cleanig unused code (thanks to Grigory Filatov)

May 12 th 2008
   Added  SET INLINESBT now print the calculation on the same line of the writing "Subtotal" (default is ON)
   Added  SET INLINETOT now print the calculation on the same line of the writing "Total" (default is ON)
   Revised print routine (do not execute if no record found)

March 27 th 2008
   Changed the style of the code, using the HASH and
   reducing so the variables of memory and optimized the code.
   The errors in the section Body is brought an only time
   and not more for every record.
   Added a window of splash(escludibile) to point out
   the progression of the jobs
   Introduced the command Set SPLASH TO
   Example of use SET SPLASH TO "Working in progress... "
   Or SET SPLASH TO
   In the case Set SPLASH TO is used, without string,
   the window of splash is hidden.

14 Feb. 2008
   Added SET COPIE TO
   Added IF ELSE ENDIF support
   Added ABORT variable
   Added SUBLINE command
   Added ADDLINE command
   Revised Group Function
   Added a revised version of Msgmulty.
   Msgmulty is made by Bicahi Esgici <esgici@gmail.com>

I hope this code will help someone.

Thank you for using Report Interpreter!

Pierpaolo Martinello
email:    pier.martinello at alice.it
