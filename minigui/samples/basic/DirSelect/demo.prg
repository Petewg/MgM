/*
   MINIGUI - Harbour Win32 GUI library Demo

   Purpose is to test the function hb_DirScan() which allows scanning of a whole dir with subdirs.
   Also some other interesting HB_* functions to split filename from directory name.
*/

#include "hmg.ch"

#define NTRIM( n ) hb_ntos( n )

FUNCTION Main()

   LOCAL cSMsg := ""
   LOCAL aHeaders := { 'Select', 'Path', 'Name', 'Bytes', 'Date', 'Time', 'Attr' }
   LOCAL aLijst := {}

   DEFINE WINDOW MainForm ;
      AT 90, 90 ;
      WIDTH 920 ;
      HEIGHT 550 ;
      TITLE 'Directory Scan for *.prg' ;
      MAIN ;
      ON INIT Resize() ;
      ON MAXIMIZE Resize() ;
      ON SIZE Resize()

   DEFINE MAIN MENU of MainForm
      DEFINE POPUP "File"
         MENUITEM "Directory" ACTION DoFolder( "" )
         MENUITEM "About" ACTION About()
         SEPARATOR
         MENUITEM "Exit" ACTION ThisWindow.Release
      END POPUP
   END MENU

   DEFINE STATUSBAR
      STATUSITEM cSMsg
      CLOCK
      DATE
   END STATUSBAR

   @ 005, 005 GRID Grid_1 ;
      WIDTH 1000 HEIGHT 425 ;
      HEADERS aHeaders ;
      WIDTHS { 20, 300, 300, 100, 80, 80, 50 } ;
      ITEMS aLijst ;
      FONT "Courier New" SIZE 10 ;
      FONTCOLOR BLUE ;
      ON DBLCLICK  SelectMe() ;
      LOCKCOLUMNS 1

      @ 440,50 BUTTON Button_1 CAPTION "Select All" WIDTH 120 HEIGHT 28 ACTION SelectAll()

   END WINDOW

   MainForm.Center
   MainForm.Activate

RETURN NIL
//-----------------------
FUNCTION About()
   MsgInfo( PadC("hb_DirScan() Example", 60) + CRLF + CRLF + MiniguiVersion() )

RETURN NIL
//-----------------------
FUNCTION Resize()
   MainForm.Grid_1.Width := MainForm.Width - 25
   MainForm.Grid_1.Height := MainForm.Height - 125
   MainForm.Button_1.Row := MainForm.Height - 110 - GetBorderHeight() / 2

RETURN NIL
//-----------------------
FUNCTION SelectMe()

   LOCAL aLine := MainForm.Grid_1.Item( This.CellRowIndex )

   MainForm.Grid_1.Item( This.CellRowIndex ) := iif( Empty( aLine[1] ), { "x" }, { " " } )

   MainForm.Grid_1.Refresh()

RETURN NIL
//-----------------------
FUNCTION SelectAll()

   LOCAL i

   FOR i:=1 TO MainForm.Grid_1.ItemCount
      MainForm.Grid_1.Item( i ) := { "x" }
   NEXT
   MainForm.Grid_1.SetFocus()
   MainForm.Grid_1.Refresh()

RETURN NIL
//------------------------
PROCEDURE DoFolder( cNewDir )

   STATIC cFolder := "", cNewFolder := "", cMsg := ""
   LOCAL cExePath := Left( ExeName(), RAt( "\", ExeName() ) )
   LOCAL aDir
   LOCAL k

   MainForm.Statusbar.Item( 1 ) := " "

   IF Empty( cNewDir )
      BEGIN INI File ( cExePath + "dirselect.ini" )
         GET cFolder SECTION "General" ENTRY "LastPath"
      END INI

      cNewFolder := GetFolder( "Select a Folder", iif( Empty( cFolder ), cExePath, cFolder ) )
   
   ELSE
      cNewFolder := cNewDir
   ENDIF

   IF !Empty( cNewFolder )
      cFolder := cNewFolder
      BEGIN INI File ( cExePath + "dirselect.ini" )
         SET SECTION "General" ENTRY "LastPath" TO cFolder
      END INI
   ENDIF

   IF !Empty( cFolder )

      MainForm.StatusBar.Item( 1 ) := cFolder
  	
      IF !( DirChange( cFolder ) == 0 )    // changing to the directory in question to read it
         MsgStop( "Error Changing to " + cFolder )
         RETURN // get outta here - there's nothing left to do 4 u.
      ENDIF
  
      WAIT WINDOW "Scanning Directories" NOWAIT
      InkeyGUI(100)

      aDir := hb_DirScan( cFolder, "*.prg" )

      MainForm.Grid_1.DeleteAllItems()

      FOR k := 1 TO Len( aDir )  

         MainForm.Grid_1.Additem( { " ", cFolder + hb_FNameDir( aDir[k,1] ), hb_FNameNameExt( aDir[k,1] ), ;
            Transform( aDir[k,2], "999,999,999" ), ;
            DToC( aDir[k,3] ), aDir[k,4], aDir[k,5] } )

         cMsg := "Reading " + NTRIM( Int( k / Len( aDir ) * 100 ) ) + "%"
         WAIT WINDOW cMsg NOWAIT

      NEXT

      InkeyGUI(100)
      WAIT CLEAR
      MainForm.Grid_1.Value := 1

   ELSE

      MsgStop( "No Folder Selected" )

   ENDIF

RETURN
