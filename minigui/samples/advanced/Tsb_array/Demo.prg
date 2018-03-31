#include "minigui.ch"
#include "tsbrowse.ch"

#define CLR_PINK   RGB( 255, 128, 128)
#define CLR_NBLUE  RGB( 128, 128, 192)

Memvar oBrw1, oBrw2
Memvar aDatos_origen, aDatos_destin


Procedure Main()

   Public oBrw1, oBrw2
   Public aDatos_origen, aDatos_destin

   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 840 ;
      HEIGHT 480 ;
      TITLE "TsBrowse Array Test" ;
      MAIN ;
      FONT 'Tahoma' SIZE 10

      Sample1()

   END WINDOW

   ACTIVATE WINDOW Form1

Return

*--------------------------------------------------------------

Function Sample1()

   aDatos_origen := {}
   aDatos_destin := {{,,,}}

   AADD( aDatos_origen, {"Ena         ", "Art01", "Mod01", "200"} )
   AADD( aDatos_origen, {"Dyo         ", "Art02", "Mod01", "200"} )
   AADD( aDatos_origen, {"Tria        ", "Art03", "Mod01", "200"} )
   AADD( aDatos_origen, {"Tessera     ", "Art04", "Mod01", "200"} )
   AADD( aDatos_origen, {"Pente       ", "Art05", "Mod01", "200"} )
   AADD( aDatos_origen, {"Exi         ", "Art06", "Mod01", "200"} )
   AADD( aDatos_origen, {"Epta        ", "Art07", "Mod01", "200"} )
   AADD( aDatos_origen, {"Okto        ", "Art08", "Mod01", "200"} )
   AADD( aDatos_origen, {"Ennea       ", "Art09", "Mod01", "200"} )
   AADD( aDatos_origen, {"Deka        ", "Art10", "Mod02", "200"} )
   AADD( aDatos_origen, {"Enteka      ", "Art11", "Mod02", "200"} )
   AADD( aDatos_origen, {"Dodeka      ", "Art12", "Mod02", "200"} )
   AADD( aDatos_origen, {"Dekatria    ", "Art13", "Mod02", "200"} )
   AADD( aDatos_origen, {"Dekatessera ", "Art14", "Mod02", "200"} )
   AADD( aDatos_origen, {"Dekapente   ", "Art15", "Mod02", "200"} )
   AADD( aDatos_origen, {"Dekaexi     ", "Art16", "Mod02", "200"} )
   AADD( aDatos_origen, {"Dekaepta    ", "Art17", "Mod02", "200"} )
   AADD( aDatos_origen, {"Dekaokto    ", "Art18", "Mod02", "200"} )

   IF !_IsControlDefined ("oBrw1", "Form1")

      DEFINE TBROWSE oBrw1 ;
         AT 60,10 ;
         OF Form1 ;
         WIDTH 330 ;
         HEIGHT 340 ;
         FONT "Verdana" ;
         SIZE 10 ;
         ON GOTFOCUS fModelo_Hab(1) ;
         ON DBLCLICK CopyRec();
         GRID

         oBrw1:SetArray( aDatos_origen )

         ADD COLUMN TO TBROWSE oBrw1 ;
            DATA ARRAY ELEMENT 1;
            TITLE "Rubro" SIZE 120

         ADD COLUMN TO TBROWSE oBrw1 ;
            DATA ARRAY ELEMENT 2;
            TITLE "Articulo" SIZE 80

         ADD COLUMN TO TBROWSE oBrw1 ;
            DATA ARRAY ELEMENT 3;
            TITLE "Marca" SIZE 80

         ADD COLUMN TO TBROWSE oBrw1 ;
            DATA ARRAY ELEMENT 4;
            TITLE "M" SIZE 30

         oBrw1:SetColor({5,6},{CLR_WHITE,CLR_MAGENTA})
         oBrw1:SetColor( { 3, 4 }, { CLR_WHITE, CLR_NBLUE } )

      END TBROWSE

      DEFINE TBROWSE oBrw2 ;
         AT 60,450 ;
         OF Form1 ;
         WIDTH 330 ;
         HEIGHT 340 ;
         ON GOTFOCUS fModelo_Hab(2) ;
         GRID

         oBrw2:SetArray( aDatos_destin )
         AIns( ASize( oBrw2:aDefValue, Len( oBrw2:aDefValue ) + 1 ), 1 )

         ADD COLUMN TO TBROWSE oBrw2 ;
            DATA ARRAY ELEMENT 1;
            TITLE "Rubro" SIZE 120

         ADD COLUMN TO TBROWSE oBrw2 ;
            DATA ARRAY ELEMENT 2;
            TITLE "Articulo" SIZE 80

         ADD COLUMN TO TBROWSE oBrw2 ;
            DATA ARRAY ELEMENT 3;
            TITLE "Marca" SIZE 80

         ADD COLUMN TO TBROWSE oBrw2 ;
            DATA ARRAY ELEMENT 4;
            TITLE "C" SIZE 30

         oBrw2:SetColor( { 5, 6 }, {CLR_WHITE, CLR_MAGENTA } )
         oBrw2:SetColor( { 3, 4 }, { CLR_WHITE, CLR_NBLUE } )

         oBrw2:SetDeleteMode( .T., .T.)   // Activate Key DEL and confirmation

      END TBROWSE

      @ 110,355 BUTTON Button_1 OF Form1;
         CAPTION "Add";
         ACTION CopyRec() ;
         WIDTH  80;
         HEIGHT 28 ;
         FONT "Arial" SIZE 9

      @ 150,355 BUTTON Button_2 OF Form1;
         CAPTION "Del";
         ACTION DelRec() ;
         WIDTH  80;
         HEIGHT 28 ;
         FONT "Arial" SIZE 9

      oBrw2:SetFocus()

   ENDIF

Return Nil

*--------------------------------------------------------------

Function fModelo_Hab(mod)

   IF mod == 1
      Form1.Button_1.Enabled := .t.
      Form1.Button_2.Enabled := .f.
   ELSE
      Form1.Button_1.Enabled := .f.
      Form1.Button_2.Enabled := .t.
   ENDIF

Return Nil

*--------------------------------------------------------------

Function CopyRec()
   LOCAL cItem, nRow, nVal, oRow

   IF Len(oBrw2:aArray) == 1 .AND. ( Empty(oBrw2:aArray[ 1, 1 ]) .OR. SubStr(oBrw2:aArray[ 1, 1 ], 1, 3) == '???' )
      nRow := 1
      oBrw2:aArray[ nRow, 1 ] := aDatos_origen[oBrw1:nAt][1]
      oBrw2:aArray[ nRow, 2 ] := aDatos_origen[oBrw1:nAt][2]
      oBrw2:aArray[ nRow, 3 ] := aDatos_origen[oBrw1:nAt][3]
      oBrw2:aArray[ nRow, 4 ] := 1
   ELSE
      cItem := {aDatos_origen[oBrw1:nAt][1],aDatos_origen [oBrw1:nAt][2],aDatos_origen[oBrw1:nAt][3],1}
      nRow := oBrw2:nLen + 1
      oBrw2:ResetSeek()
      oBrw2:nColOrder := 1
      oRow := oBrw2:nAt
      IF ASeek( aDatos_origen[oBrw1:nAt][1], oBrw2 )
         nRow:= oBrw2:nAt
         IF nRow - oRow  != 0
            IF nRow - oRow  > 0
               oBrw2:PageDown( nRow - oRow )
            ELSE
               oBrw2:PageUp( oRow - nRow )
               oBrw2:Display()
            ENDIF
         ENDIF
         nVal := oBrw2:aArray[ nRow, 4 ]+1
         oBrw2:aArray[ nRow, 4 ]:= nVal
      ELSE
         oBrw2:AddItem( cItem )
      ENDIF
   ENDIF
   oBrw2:GoPos( nRow, 1)
   oBrw2:Refresh()

Return Nil

*--------------------------------------------------------------

Function delRec()

   oBrw2:DeleteRow()
   oBrw2:Refresh()

Return Nil

*--------------------------------------------------------------

Static Function ASeek( uSeek, oBrw )

   Local nEle, uData, ;
         lFound := .F., ;
         aArray := oBrw:aArray, ;
         nCol   := oBrw:nColOrder, ;
         nRecNo := oBrw:nAt

   For nEle := 1 To Len( aArray )

      uData := aArray[ nEle, nCol ]

      If uData = uSeek
         lFound := .T.
         Exit
      EndIf

   Next

   If lFound .and. nEle <= oBrw:nLen
      oBrw:nAt := nEle
   Else
      oBrw:nAt := nRecNo
   EndIf

Return lFound
