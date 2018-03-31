/*
 * MiniGUI Demonstration of icons from the library shell32.dll
 *
 * Copyright 2013 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Copyright 2013-2015 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include "minigui.ch"
#include "i_winuser.ch"

#xtranslate LTRIM( STR( <i> ) ) => hb_ntos( <i> )

Procedure MAIN
LOCAL nDesktopHeight := GetDesktopHeight() - GetTaskBarHeight()

SET MULTIPLE OFF WARNING

SET FONT TO "Tahoma", 9

DEFINE WINDOW Form_1 ;
	VIRTUAL HEIGHT nDesktopHeight * 1.4 ;
	TITLE "Icons from shell32.dll" ;
	MAIN ;
	ON INIT MyDrawIcons()

        This.Sizable   := .F.  // NOSIZE
        This.MinButton := .F.  // NOMINIMIZE
        This.MaxButton := .F.  // NOMAXIMIZE

	ON KEY ESCAPE ACTION ThisWindow.Release()

	ON KEY PRIOR ACTION SendMessage( Application.Handle, WM_VSCROLL, SB_PAGEUP, 0 )
	ON KEY NEXT ACTION SendMessage( Application.Handle, WM_VSCROLL, SB_PAGEDOWN, 0 )
	ON KEY UP ACTION SendMessage( Application.Handle, WM_VSCROLL, SB_LINEUP, 0 )
	ON KEY DOWN ACTION SendMessage( Application.Handle, WM_VSCROLL, SB_LINEDOWN, 0 )
END WINDOW

Form_1.Activate()

Return

/////////////////////////////////////////////////////////////////////////////////
Function MyDrawIcons()
   LOCAL nJ := 0, nI, cStr, cObj, nRow := 10, nCol
   LOCAL nWidth  := Form_1.Width
   LOCAL cIconSrc := System.SystemFolder + "\shell32.dll"
   LOCAL nCount := ExtractIcon( cIconSrc, -1 ) - 1

   FOR nI := 0 TO nCount

       nCol := 10 + 70 * ( ++nJ - 1 )
       IF nCol > nWidth - 80
          nRow += 70
          nJ := 1
          nCol := 10
       ENDIF

       cObj := "Btn_"+LTRIM(STR(nI))
       @ nRow, nCol  BUTTON &cObj    ;
         OF Form_1                   ;
         ICON cIconSrc               ;
         EXTRACT nI FLAT             ;
         WIDTH 38  HEIGHT 38         ;
         ACTION SaveThisIcon( cIconSrc, Val( SubStr( This.Name, At( "_", This.Name ) + 1 ) ) )

       cObj := "Lbl_"+LTRIM(STR(nI))
       cStr := "nI="+LTRIM(STR(nI))
       @ nRow + 40, nCol LABEL &cObj ;
         OF Form_1 VALUE cStr        ;
         WIDTH 60 HEIGHT 12          ;
         TRANSPARENT FONTCOLOR BLUE

       IF nI % 18 == 0
          DO EVENTS
       ENDIF
   NEXT

Return NIL

/////////////////////////////////////////////////////////////////////////////////
Function SaveThisIcon( cSrcName, nI )
   LOCAL cFileName := PutFile ( {{"Icon Files (*.ico)" ,"*.ico"}} ,"Save Icon" ,  , .T. )

   IF !Empty(cFileName) .AND. SaveIcon( cFileName, cSrcName, nI )
	MsgInfo( "Icon was saved successfully", "Result" )
   ENDIF

Return NIL

/////////////////////////////////////////////////////////////////////////////////
#include <saveicon.c>
