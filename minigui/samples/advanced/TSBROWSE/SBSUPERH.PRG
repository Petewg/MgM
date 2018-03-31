* TSBrowse testing superheaders

#include "MiniGui.ch"
#include "TSBrowse.ch"

/*
#define CLR_PINK   RGB( 255, 128, 128)
#define CLR_NBLUE  RGB( 128, 128, 192)
*/
Function fSuperCol()

   Local oBrw, xVar, ;
         aMeses := { "January", "February", "March", "April", "May", "June", ;
                     "July", "August", "September", "October", ;
                     "November", "December" }
   Local nVar1, nVar2

   Field Code

   Set( _SET_DELETED, .T. )

   Select("Products")
   Products->(dbgotop())
   IF !_IsControlDefined ("oBrw","Form_5")

      DEFINE WINDOW Form_5 ;
         AT 200,150 ;
         WIDTH 500 HEIGHT 400 ;
         TITLE "Super Columns" ;
         ICON "Demo.ico" ;
         CHILD

         DEFINE TBROWSE oBrw AT 0,0 ALIAS "Products" CELLED ;
            WIDTH 490 HEIGHT 350  ;
            COLORS {CLR_BLACK, CLR_NBLUE} ;

         oBrw:nFreeze := 2
         oBrw:nHeightCell += 1
         oBrw:SetAppendMode( .T. )
         oBrw:SetDeleteMode( .T., .T.)

//         ADD COLUMN TO oBrw TITLE "Code" DATA Products->Code EDITABLE
         ADD COLUMN TO oBrw TITLE "Code" DATA FieldWBlock( "Code", Select() ) EDITABLE

         ADD COLUMN TO oBrw TITLE "Product" DATA FieldWBlock( "Descr", Select() ) EDITABLE

         For xVar := 1 To 12
//             bData := &( "{ || Products->Unit" + LTrim( Str( xVar ) ) + "}" )
//             ADD COLUMN TO oBrw TITLE "Quantity" DATA bData EDITABLE
            ADD COLUMN TO oBrw TITLE "Quantity" DATA FieldWBlock( "Unit" + LTrim( Str( xVar ) ), Select() ) EDITABLE

//             bData := &( "{ || Products->Import" + LTrim( Str( xVar ) ) + "}" )
//             ADD COLUMN TO oBrw TITLE "Import" DATA bData EDITABLE
            ADD COLUMN TO oBrw TITLE "Import" DATA FieldWBlock( "Import" + LTrim( Str( xVar ) ), Select() ) EDITABLE
         Next

         nVar1 := 3
         For nVar2 := 1 To 12
            ADD SUPER HEADER TO oBrw FROM COLUMN nVar1 TO COLUMN ++nVar1 ;
               TITLE aMeses[ nVar2 ] //FONT oFont
            ++nVar1
         Next

      END TBROWSE

      END WINDOW
      ACTIVATE WINDOW  Form_5
   else
      RESTORE WINDOW Form_5
   endif

Return Nil


Function fSuperBit()

   Local oBrw, hBmp

   Field First, Last
   Select("Employee")
   Employee->(dbgotop())

   IF !_IsControlDefined ("oBrw","Form_6")
      hBmp := LoadImage ("bitmaps\Logo.bmp")

       DEFINE WINDOW Form_6 ;
         AT 250,200 ;
         WIDTH 500 HEIGHT 400 ;
         TITLE "Super Headers ( BitMaps ) ";
         ICON "Demo.ico" ;
         CHILD


         DEFINE TBROWSE oBrw AT 0,0 GRID ALIAS "Employee" ;
            WIDTH 490 HEIGHT 350  ;
            COLORS {CLR_BLACK, CLR_NBLUE} ;

         oBrw:LoadFields( .T. )

         ADD SUPER HEADER TO oBrw FROM COLUMN 1 TO COLUMN 4 ;
             BITMAP hBmp NOLINES
         END TBROWSE

      END WINDOW

      ACTIVATE WINDOW  Form_6
   else
      RESTORE WINDOW Form_6
   endif

Return Nil
