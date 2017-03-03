/*
* MINIGUI - Harbour Win32 GUI library Demo
*
* (c) 2016 Grigory Filatov <gfilatov@inbox.ru>
*
*/

#include "minigui.ch"


PROCEDURE MAIN
   LOCAL aCaptions := { "Command Link Caption", "Close a sample" }
   LOCAL aNotes    := { "This is a test note.", "Exit from this sample" }
   LOCAL aImages   := { "arrow.bmp", "appoint.bmp" }
   LOCAL i, cImage, cLabel, cLabel2
   LOCAL nRow := 22
   
   Set FONT TO "Arial" , 10

   DEFINE WINDOW Win_1 ;
          AT 0, 0 ;
          WIDTH 298 + Iif( ISVISTAORLATER(), 1, 2 ) * GetBorderWidth() ;
          HEIGHT GetTitleHeight() + 222 + GetBorderHeight() ;
          TITLE "Control Panel" ;
          MAIN NOMINIMIZE NOMAXIMIZE NOSIZE ;
          BACKCOLOR Iif( ISVISTAORLATER(), { 233, 236, 216 }, NIL ) ;
          FONT 'MS Sans Serif' SIZE 9

      FOR i := 1 TO Len( aCaptions )
         
         cImage := "Image_" + Str( i, 1 )
         @ nRow, 24 IMAGE &cImage ;
                          PICTURE aImages[i] ; // "arrow.bmp" ;
                          WIDTH 24 ;
                          HEIGHT 24 ;
                          TRANSPARENT
         
         cLabel := "Button_" + Str( i, 1 )
         @ nRow, 54 LABEL &cLabel VALUE aCaptions[ i ] ;
                          WIDTH 227 ;
                          HEIGHT 20 ;
                          BOLD ;
                          TRANSPARENT ;
                          ACTION DoAction( Val( Right( this.name, 1 ) ) ) ;
                          ON MOUSEHOVER CreateBtnBorder( ThisWindow.Name, this.row - 12, this.col - 38, this.row + this.height + 48, this.col + this.width + 14 ) ;
                          ON MOUSELEAVE erasewindow( ThisWindow.Name )
         
         cLabel2 := "Note_" + Str( i, 1 )
         @ nRow + 21, 54 LABEL &cLabel2 VALUE aNotes[ i ] ;
                               WIDTH 227 ;
                               HEIGHT 60 ;
                               TRANSPARENT ;
                               ACTION DoAction( Val( Right( this.name, 1 ) ) ) ;
                               ON MOUSEHOVER CreateBtnBorder( ThisWindow.Name, this.row - 12 - 21, this.col - 38, this.row - 21 + this.height + 8, this.col + this.width + 14 ) ;
                               ON MOUSELEAVE erasewindow( ThisWindow.Name )
         
         nRow += 80
         
      NEXT
      
   END WINDOW
   
   CENTER WINDOW Win_1
   
   ACTIVATE WINDOW Win_1
   
   RETURN
   
   
FUNCTION CreateBtnBorder( cWin, t, l, b, r )
   
   Rc_Cursor( "MINIGUI_FINGER" )
   
   DRAW PANEL ;
   IN WINDOW &cWin ;
   AT t, l ;
   TO b, r
   
   RETURN NIL
   
FUNCTION DoAction( /*Val( Right( this.name, 1 )*/ arg )
   IF arg == 2
      RELEASE WINDOW ALL
   ELSE
      msgInfo( arg, "DoAction" )
   ENDIF
   RETURN NIL










