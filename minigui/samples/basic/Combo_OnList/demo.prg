/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Combo OnList events demo
 * (C) 2005 Martin Waller <wallerm@freenet.de>
 *
 * Main procedure name changed - Kevin Carmody - 2007.03.28
*/

#INCLUDE "minigui.ch"

PROCEDURE MAIN
LOCAL nRow, nColumn, abKeyBlocks, aResults

nRow               := 0
nColumn            := 0
abKeyBlocks        := ARRAY(0)
aResults           := ARRAY(0)

DEFINE WINDOW Demo ;
   AT 0,0 ;
   WIDTH 0 ;
   HEIGHT 0 ;
   MAIN ;
   TITLE "Combo OnList events demo - RETURN: Search and ESC: Close" ;
   NOSIZE ;
   NOSYSMENU ;
   FONT "Verdana" ;
   SIZE 10

   ON KEY ESCAPE ACTION { || THISWINDOW.RELEASE }
   ON KEY RETURN ACTION { || MSGBOX("Searching...") }

   nRow := Demo.ROW + 15
   nColumn := Demo.COL + 15

   @ nRow,nColumn LABEL DemoLabel1 ;
      VALUE "Search for:" ;
      AUTOSIZE ;
      FONT "VERDANA" ;
      SIZE 10

   @ nRow - 2, ;
     GETPROPERTY("Demo","DemoLabel1","COL") + ;
     GETPROPERTY("Demo","DemoLabel1","WIDTH") + 55 ;
     COMBOBOX DemoCombo ;
     ITEMS {"Number","Name"} ;
     VALUE 1 ;
     WIDTH 210 ;
     HEIGHT 90 ;
     FONT "VERDANA" ;
     SIZE 10 ;
     ON LISTDISPLAY { || abKeyBlocks := _KeysOff(), ;
                         MSGBOX("Now ESC closes the combolist." + CHR(10)+CHR(13) + ;
                                "Not the window! -" + CHR(10)+CHR(13) + ;
                                "RETURN chooses the combolist item"  + CHR(10)+CHR(13) + ;
                                "and doesn't start searching!") } ;
     ON LISTCLOSE { || _KeysOn(abKeyBlocks), ;
                       MSGBOX("Now ESC again closes the window."   + CHR(10)+CHR(13) + ;
                              "RETURN again starts searching!")  }

   @ GETPROPERTY("Demo","DemoLabel1","ROW") + ;
     GETPROPERTY("Demo","DemoLabel1","HEIGHT") + 10, ;
      nColumn LABEL DemoLabel2 ;
      VALUE "Searchargument  :" ;
      AUTOSIZE ;
      FONT "VERDANA" ;
      SIZE 10

   @ GETPROPERTY("Demo","DemoLabel2","ROW") - 2, ;
     GETPROPERTY("Demo","DemoLabel2","COL") + ;
     GETPROPERTY("Demo","DemoLabel2","WIDTH") + 5 ;
      TEXTBOX DemoText1 ;
      VALUE "" ;
      WIDTH 210 ;
      HEIGHT GETPROPERTY("Demo","DemoLabel2","HEIGHT") ;
      MAXLENGTH 25 ;
      FONT "VERDANA" ;
      SIZE 10

   @ GETPROPERTY("Demo","DemoCombo","ROW"), ;
     GETPROPERTY("Demo","DemoCombo","COL") + ;
     GETPROPERTY("Demo","DemoCombo","WIDTH") + 60 ;
      BUTTON DemoButton1 ;
      CAPTION "&Search" ;
      ON CLICK { || MSGBOX("Searching...") } ;
      FONT "VERDANA" ;
      SIZE 10

   @ GETPROPERTY("Demo","DemoButton1","ROW") + ;
     GETPROPERTY("Demo","DemoButton1","HEIGHT") + 10, ;
     GETPROPERTY("Demo","DemoButton1","COL") ;
      BUTTON DemoButton2 ;
      CAPTION "&Cancel" ;
      ON CLICK { || DOMETHOD("Demo","RELEASE") } ;
      FONT "VERDANA" ;
      SIZE 10

   SETPROPERTY("Demo","WIDTH", ;
               GETPROPERTY("Demo","DemoButton1","COL") + ;
               GETPROPERTY("Demo","DemoButton1","WIDTH") + 15)

   SETPROPERTY("Demo","HEIGHT", ;
               GETPROPERTY("Demo","DemoButton2","ROW") + ;
               GETPROPERTY("Demo","DemoButton2","HEIGHT") + 35)

END WINDOW

Demo.CENTER
Demo.ACTIVATE

RETURN

/*-------------------------------------------------------------------------------------------*/

STATIC FUNCTION _KeysOff
LOCAL bKeyBlock, abRetVal := ARRAY(0)

STORE KEY ESCAPE OF Demo TO bKeyBlock
AADD(abRetVal, bKeyBlock)
RELEASE KEY ESCAPE OF Demo

STORE KEY RETURN OF Demo TO bKeyBlock
AADD(abRetVal, bKeyBlock)
RELEASE KEY RETURN OF Demo

RETURN( abRetVal )

/*-------------------------------------------------------------------------------------------*/

STATIC PROCEDURE _KeysOn(abKeyBlocks)

_DefineHotKey("Demo", 0, 27, abKeyBlocks[1])
_DefineHotKey("Demo", 0, 13, abKeyBlocks[2])

RETURN