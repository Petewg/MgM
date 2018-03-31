#include "MiniGui.ch"
#include "TSBrowse.ch"
/*
#define CLR_PINK   RGB( 255, 128, 128)
#define CLR_NBLUE  RGB( 128, 128, 192)
*/
Function SBAlign()

   Local oBrw

   Local ahBmp:= {LoadImage( "Bitmaps\Level1.bmp" ), ;
                  LoadImage( "Bitmaps\Level3.bmp" ), ;
                  LoadImage( "Bitmaps\Level2.bmp" ) }

   IF !_IsControlDefined ("oBrw","Form_2")

      // to see how SetDeleteMode() works:
      Set( _SET_DELETED, .T. )

      Select("Test2")
      Test2->(dbgotop())

      DEFINE WINDOW Form_2 ;
         AT 100,50 ;
         WIDTH 380 HEIGHT 300 ;
         TITLE "MiniGUI TsBrowse: Alignment in Code Blocks and " + ;
                           "Alignable BitMaps" ;
         ICON "Demo.ico" ;
         FONT "Arial" SIZE 9 ;
         CHILD

         DEFINE TBROWSE oBrw AT 10,15 ALIAS "Test2" ;
            OF "Form_2" WIDTH 340 HEIGHT 240 CELLED;
            COLORS {CLR_BLACK, CLR_PINK}

      // see new behaviour of VALID clause
         ADD COLUMN TO oBrw ;
            HEADER "Name" ;
            DATA FieldWBlock( "Field1", Select() ) ;
            PICTURE "@!" ;
            VALID {|uVar| ! Empty( uVar ) };
            3DLOOK FALSE SIZE 200 ;
            EDITABLE MOVE DT_MOVE_RIGHT

         ADD COLUMN TO oBrw ;
            HEADER "Result" ;
            DATA { | uVar | If( uVar == Nil, Test2->Field2, ;
                   If( ! Empty( uVar ), Test2->Field2 := uVar, ;
                   If( oBrw:lAppendMode, ( oBrw:skip( - 1 ),oBrw:Refresh(.T.) ), Nil ) ) ) };
            COLORS CLR_BLACK,CLR_PINK ;
            ALIGN DT_CENTER ;
            SIZE 70 PIXELS ;
            3DLOOK TRUE ;
            EDITABLE MOVE DT_MOVE_NEXT

      // alignment in code blocks
         ADD COLUMN TO oBrw ;
            HEADER "A  B  C " ;
            DATA { || If( Test2->Field2 < 6, ahBmp[ 3 ], ;
                      If( Test2->Field2 < 9, ahBmp[ 2 ], ;
                       ahBmp[ 1 ] ) ) } ;
            3DLOOK TRUE ;
            ALIGN { || nMakeLong( DT_CENTER, If( Test2->Field2 < 6, DT_RIGHT, ;
                       If( Test2->Field2 < 9, DT_CENTER, DT_LEFT ) ) ) }, ;
                  DT_LEFT, DT_LEFT ;
            COLOR CLR_BLACK, CLR_NBLUE ;
            SIZE 45 BITMAP


      // delete rows by pressing Del key
         oBrw:SetDeleteMode( .T., .T. )  // ( lOnOff, lConfirm, bDelete)

      // activating Auto Append feature
         oBrw:SetAppendMode( .T. )

      // setting cursor colors (5,6) to hole browse
         oBrw:SetColor( { 5, 6 }, { CLR_WHITE, CLR_BLACK } )

      // setting cursor colors to specific columns (3)
         oBrw:SetColor( { 5, 6 }, { CLR_BLACK, CLR_WHITE }, 3 )

      // increasing cells height
         oBrw:nHeightCell += 4

      // we don't want horizontal scroll bar
         oBrw:lNoHScroll := .T.

         END TBROWSE
      END WINDOW

      ACTIVATE WINDOW Form_2

   endif
   AEval( ahBmp,{ | x | DeleteObject( x ) } )

Return Nil
