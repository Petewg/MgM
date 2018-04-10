/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"
#include "tsbrowse.ch"
#include "Dbstruct.ch"

REQUEST DBFCDX


FUNCTION Main()

   LOCAL cDbf := GetStartupFolder() + '\Test.dbf'
   LOCAL i, cAlias
   LOCAL oBrw_1

   SET CENTURY ON
   SET DELETED ON

   IF ! File( cDbf )
      CreateTable()      
   ENDIF

   rddSetDefault( 'DBFCDX' )
   cAlias := cFileNoExt( cDbf )

   USE ( cDbf ) Alias ( cAlias ) SHARED NEW

   Test->( ordSetFocus( 1 ) )

   DEFINE WINDOW Form_1 ;
      At 0, 0 ;
      WIDTH 600 ;
      HEIGHT 470 ;
      TITLE 'TsBrowse sample: Order' ;
      MAIN ;
      NOMAXIMIZE ;
      NOSIZE

   END WINDOW

   oBrw_1 := CreateBrowse( "oBrw_1", 'Form_1', 2, 2, Form_1.Width - 10, ;
      Form_1.Height - GetTitleHeight() - iif( IsThemed(), 1, 2 ) * GetBorderHeight() - 2, cAlias )

   // modify the default settings
   oBrw_1:aColumns[ 1 ]:cHeading  := "Number"
   oBrw_1:SetColSize( 1, 94 )
   oBrw_1:aColumns[ 1 ]:nAlign    := DT_RIGHT
   // editing is available for ALL columns
   FOR i := 1 TO Test->( Fcount() ) - 1
      oBrw_1:aColumns[ i ]:lEdit  := TRUE
   NEXT
   oBrw_1:aColumns[ 1 ]:nEditMove := DT_DONT_MOVE
   oBrw_1:aColumns[ 5 ]:cHeading  := "Birthday"
   oBrw_1:SetColSize( 5, 120 )
   // hide the last column
   oBrw_1:HideColumns( 6, .T. )

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL


FUNCTION CreateBrowse( cBrw, cParent, nRow, nCol, nWidth, nHeight, cAlias )

   LOCAL oBrw

   DEFINE TBROWSE &cBrw ;
      AT nRow, nCol ;
      ALIAS cAlias ;
      OF &cParent ;
      WIDTH  nWidth ;
      HEIGHT nHeight ;
      COLORS { CLR_BLACK, CLR_BLUE } ;
      FONT "MS Sans Serif" ;
      SIZE 9

      :SetAppendMode( .F. )
      :SetDeleteMode( .F. )

      :lNoHScroll := .T.
      :lCellBrw := .T.
      :nSelWidth := 16

   END TBROWSE

   // loading the ALL database fields
   LoadFields( cBrw, cParent )

   oBrw := TBrw_Obj( cBrw, cParent )

   WITH OBJECT oBrw
      :nHeightCell += 2
      :nHeightHead += 18
      :nWheelLines := 1

      :lNoChangeOrd := TRUE
      :hBrush := CreateSolidBrush( 230, 240, 255 )

      :SetColor( { 16 },  {        RGB(  43, 149, 168 ) } )                             //  SyperHeader backcolor
      :SetColor( {  3 },  {        RGB( 255, 255, 255 ) } )                             //  Header font color
      :SetColor( {  4 },  { {|| { RGB(  43, 149, 168 ), RGB(   0,  54,  94 ) } } } )    //  Header backcolor
      :SetColor( { 17 },  {        RGB( 255, 255, 255 ) } )                             //  Font color in SyperHeader
      :SetColor( {  6 },  { {|| { RGB( 255, 255,  74 ), RGB( 240, 240,   0 ) } } } )    //  Cursor backcolor
      :SetColor( { 12 },  { {|| { RGB( 128, 128, 128 ), RGB( 250, 250, 250 ) } } } )    //  Inactive cursor backcolor
      :SetColor( {  2 },  { {||   RGB( 230, 240, 255 ) } } )                            //  Grid backcolor
      :SetColor( {  1 },  { {||   RGB(   0,   0,   0 ) } } )                            //  Text color in grid
      :SetColor( {  5 },  { {||   RGB(   0,   0, 255 ) } } )                            //  Text color of cursor in grid
      :SetColor( { 11 },  { {||   RGB(   0,   0,   0 ) } } )                            //  Text color of inactive cursor in grid

      :nClrLine := COLOR_GRID

      :ResetVScroll()
   END OBJECT

RETURN oBrw


Static Function TBrw_Obj( cBrw, cParent )          
   Local oBrw, i

   If ( i := GetControlIndex( cBrw, cParent ) ) > 0
      oBrw := _HMG_aControlIds [ i ]
   EndIf

Return oBrw


Procedure CreateTable
	Local aDbf[6][4], i

        aDbf[1][ DBS_NAME ] := "Code"
        aDbf[1][ DBS_TYPE ] := "Numeric"
        aDbf[1][ DBS_LEN ]  := 10
        aDbf[1][ DBS_DEC ]  := 0
        //
        aDbf[2][ DBS_NAME ] := "First"
        aDbf[2][ DBS_TYPE ] := "Character"
        aDbf[2][ DBS_LEN ]  := 25
        aDbf[2][ DBS_DEC ]  := 0
        //
        aDbf[3][ DBS_NAME ] := "Last"
        aDbf[3][ DBS_TYPE ] := "Character"
        aDbf[3][ DBS_LEN ]  := 25
        aDbf[3][ DBS_DEC ]  := 0
        //
        aDbf[4][ DBS_NAME ] := "Married"
        aDbf[4][ DBS_TYPE ] := "Logical"
        aDbf[4][ DBS_LEN ]  := 1
        aDbf[4][ DBS_DEC ]  := 0
        //
        aDbf[5][ DBS_NAME ] := "Birth"
        aDbf[5][ DBS_TYPE ] := "Date"
        aDbf[5][ DBS_LEN ]  := 8
        aDbf[5][ DBS_DEC ]  := 0
        //
        aDbf[6][ DBS_NAME ] := "Bio"
        aDbf[6][ DBS_TYPE ] := "Memo"
        aDbf[6][ DBS_LEN ]  := 10
        aDbf[6][ DBS_DEC ]  := 0

        DBCREATE("Test", aDbf, "DBFCDX")

	Use test Via "DBFCDX"

	For i:= 1 To 100
		append blank
		Replace code with i 
		Replace First With 'First Name '+ Ltrim(Str(i))
		Replace Last With 'Last Name '+ Ltrim(Str(i))
		Replace Married With ( i/2 == int(i/2) )
		replace birth with date()-Max(10000, Random(20000))+Random(LastRec())
	Next i

	Index On field->code Tag code

	Use

Return
