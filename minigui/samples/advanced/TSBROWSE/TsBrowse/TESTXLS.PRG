* TSBrowse testing Excel conections

#include "MiniGui.ch"
#include "TSBrowse.ch"

#define CLR_PINK   RGB( 255, 128, 128)
#define CLR_NBLUE  RGB( 128, 128, 192)

#ifndef __XHARBOUR__
   Static oWnd, oBrw
#endif

//--------------------------------------------------------------------------------------------------------------------//

Function TestXLS()

   Local cBmp, cTitle, bExtern, newBrush
   FIELD State,Last

   DbSelectArea( "Employee" )
   Index on State+Last To StName

   DEFINE FONT Font_1a  FONTNAME "Arial" SIZE 10
   DEFINE FONT Font_2a  FONTNAME "Wingdings" SIZE 18
   cBmp := "Bitmaps\ArrowBig.bmp"

   cTitle := "Database: " + Trim(  Alias()   ) + ".dbf"
   bExtern := {|oSheet| oSheet:Columns( 10 ):Set( "NumberFormat", "#,##0.00" ) }

   DEFINE WINDOW Form_11 At 40,60 ;
         WIDTH 800 HEIGHT 540 ;
         TITLE  "TSBrowse/Excel conectivity.    One Click From TSBrowse To Excel   And more...";
         ICON "Demo.ico";
         CHILD;

   DEFINE BKGBRUSH newBrush PATTERN IN Form_11 BITMAP PAPER

   DEFINE SPLITBOX

      DEFINE TOOLBAREX Bar_1 BUTTONSIZE 28, 28
         BUTTON Btn_1 PICTURE "Excel16" ;
            ACTION oBrw:ExcelOle( "Test.xls", .T.,, cTitle,,, bExtern ) ;
            TOOLTIP "Export Browse to Excel"

         BUTTON Btn_2 PICTURE "REPORT" ;
            ACTION freport(oBrw) ;
            TOOLTIP "Report from Browse"

         BUTTON Btn_3 PICTURE "Exitb16" ;
            ACTION Form_11.Release ;
            TOOLTIP "Exit"
      END TOOLBAR

   END SPLITBOX

   @ 50, 20 TBROWSE oBrw ALIAS "Employee"  WIDTH 760 HEIGHT 440  ;
           AUTOCOLS TRANSPARENT SELECTOR cBmp EDITABLE

   Add Super Header To oBrw From Column 2 To Column 3 Color CLR_BLUE, { CLR_NBLUE, CLR_WHITE } ;
       Title "Name" 3DLook

   Add Super Header To oBrw FROM Column 4 TO Column 6 Color CLR_BLUE, { CLR_NBLUE, CLR_WHITE } ;
       Title "Address" 3DLook

      oBrw:nHeightCell += 4
      oBrw:nHeightHead += 3
      oBrw:nHeightSuper += 3
      oBrw:SetColor( { CLR_HEADF, CLR_HEADB, CLR_FOCUSF, CLR_FOCUSB }, { CLR_BLUE, { CLR_WHITE, CLR_NBLUE, 2 }, ;
                 CLR_BLACK, -1 } )
      oBrw:ChangeFont( "Font_2", 9, 2 )
      oBrw:aColumns[ 9 ]:nHAlign := DT_VERT

   END WINDOW

   ACTIVATE WINDOW Form_11

   RELEASE FONT Font_1a
   RELEASE FONT Font_2a

Return Nil

