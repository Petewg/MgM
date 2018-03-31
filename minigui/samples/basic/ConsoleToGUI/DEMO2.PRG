/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

STATIC cName, cStreet1, cStreet2, cCity, cState, cZipcode, lOk := .F.

/****************************************************************************/
FUNCTION Main()

   LOCAL nWidth := 58, nHeight := 22, n := 2, ;
      nCol := ColCharToPix( 1 ) + GetBorderWidth() / 2, ;
      nCtrlW := ColCharToPix( 40.5 ), nCtrlH := RowCharToPix( 1.4 )

   cName := Space( 40 )
   cStreet1 := cStreet2 := cCity := Space( 40 )
   cState := Space( 2 )
   cZipcode := Space( 5 )

   SET Font TO "Courier", 10

   Define Window f1 ;
      At 0, 0 ;
      Width ColCharToPix( nWidth ) ;
      Height RowCharToPix( nHeight ) + GetBorderHeight() / iif( IsWinXP(), .5, 2 ) ;
      Title "Enter Form" ;
      Icon "demo2.ico" ;
      Main ;
      ON Maximize ( f1.width := ColCharToPix( nWidth ), ;
      f1.height := RowCharToPix( nHeight ) + GetBorderHeight() / iif( IsWinXP(), .5, 2 ) ) ;
      Nosize

   @RowCharToPix( 1 ), nCol LABEL l1 value "Enter Name    " font "MS Sans Serif" size 8

   @RowCharToPix( 1 ) -n, LenChartopix( f1 .l1. value ) getbox cName value cName PICTURE "@!" ;
      width nCtrlW height nCtrlH ;
      valid {|| CheckEmpty( ( cName := f1 .cName. value ), "You must enter a name" ) }

   @RowCharToPix( 4 ) -n, nCol LABEL l2 value "Enter street 1" font "MS Sans Serif" size 8

   @RowCharToPix( 4 ) -2 * n, LenChartopix( f1 .l2. value ) getbox cStreet1 value cStreet1 ;
      width nCtrlW height nCtrlH ;
      valid {|| CheckEmpty( ( cStreet1 := f1 .cStreet1. value ), "You must enter a street address" ) }

   @RowCharToPix( 7 ) -2 * n, nCol LABEL l3 value "Enter street 2" font "MS Sans Serif" size 8

   @RowCharToPix( 7 ) -3 * n, LenChartopix( f1 .l3. value ) getbox cStreet2 value cStreet2 ;
      width nCtrlW height nCtrlH

   @RowCharToPix( 10 ) -3 * n, nCol LABEL l4 value "Enter City    " font "MS Sans Serif" size 8

   @RowCharToPix( 10 ) -4 * n, LenChartopix( f1 .l4. value ) getbox cCity value cCity PICTURE "@!" ;
      width nCtrlW height nCtrlH ;
      valid {|| CheckEmpty( ( cCity := f1 .cCity. value ), "You must enter a city name" ) }

   @RowCharToPix( 13 ) -4 * n, nCol LABEL l5 value "Enter state   " font "MS Sans Serif" size 8

   @RowCharToPix( 13 ) -5 * n, LenChartopix( f1 .l5. value ) getbox cState value cState PICTURE "@!" ;
      width ColCharToPix( 3.5 ) height nCtrlH ;
      valid {|| IfState( ( cState := f1 .cState. value ) ) }

   @RowCharToPix( 16 ) -6 * n, nCol LABEL l6 value "Enter zipcode " font "MS Sans Serif" size 8

   @RowCharToPix( 16 ) -7 * n, LenChartopix( f1 .l6. value ) getbox cZipcode value cZipcode PICTURE "99999" ;
      width ColCharToPix( 6 ) height nCtrlH ;
      valid {|| CheckEmpty( ( cZipcode := f1 .cZipcode. value ), "You must enter a zipcode" ) }

   Define Button b1
      row f1.height - 60 -iif( IsWinXP(), GetBorderHeight(), 0 )
      col nCol
      width ColCharToPix( 9 )
      height RowCharToPix( 1.65 )
      caption "&Ok"
      fontname "MS Sans Serif"
      fontsize 8
      action ( lOk := !Empty( cName ) .AND. !Empty( cStreet1 ) .AND. !Empty( cCity ) .AND. !Empty( cState ) .AND. !Empty( cZipcode ), ;
         ShowMsg(), f1.release() )
   End Button

   Define Button b2
      row f1.height - 60 -iif( IsWinXP(), GetBorderHeight(), 0 )
      col nCol + f1 .b1. width + 10
      width ColCharToPix( 9 )
      height RowCharToPix( 1.65 )
      caption "&Cancel"
      fontname "MS Sans Serif"
      fontsize 8
      action f1.release()
   End Button

   ON KEY ESCAPE Action f1 .b2. onclick()

   End Window

   Center Window f1

   Activate Window f1

RETURN( NIL )

/****************************************************************************/
#define MsgAlert( c ) MsgEXCLAMATION( c, "Attention" )

STATIC FUNCTION ShowMsg()

   IF lOk
      MsgAlert( StrTran( AllTrim( cName ) + ";" + AllTrim( cStreet1 ) + ";" + ;
         AllTrim( cStreet2 ) + iif( !Empty( cStreet2 ), ";", "" ) + AllTrim( cCity ) + " " + cState + "  " + cZipcode, ";", CRLF ) )
   ENDIF

RETURN( NIL )

/****************************************************************************/
STATIC FUNCTION CheckEmpty( cVar, cMsg )

   LOCAL lRetVal := .T.

   IF Empty( cVar ) .AND. !( f1.focusedcontrol == "b2" )
      MsgAlert( cMsg )
      lRetVal := .F.
   ENDIF

RETURN( lRetVal )

/****************************************************************************/
#define STATES_ARRAY { "AK = Alaska","AL = Alabama","AR = Arkansas","AZ = Arizona",;
      "CA = California", "CO = Colorado", "CT = Connecticut", "DC = Dist. of Col.", ;
      "DE = Delaware", "FL = Florida", "GA = Georgia", "HI = Hawaii", "IA = Iowa", ;
      "ID = Idaho", "IL = Illinois", "IN = Indiana", "KS = Kansas", "KY = Kentucky", ;
      "LA = Louisiana", "MA = Massachusetts", "MD = Maryland", "ME = Maine", "MI = Michigan", ;
      "MN = Minnesota", "MO = Missouri", "MS = Mississippi", "MT = Montana", "NE = Nebraska", ;
      "NC = North Carolina", "ND = North Dakota", "NH = New Hampshire", "NJ = New Jersey", ;
      "NM = New Mexico", "NV = Nevada", "NY = New York", "OH = Ohio", "OK = Oklahoma", ;
      "OR = Oregon", "PA = Pennsylvania", "PR = Puerto Rico", "RI = Rhode Island", ;
      "SC = South Carolina", "SD = South Dakota", "TN = Tennessee", "TX = Texas", ;
      "UT = Utah", "VA = Virginia", "VT = Vermont", "WA = Washington", "WI = Wisconsin", ;
      "WV = West Virginia", "WY = Wyoming" }

STATIC FUNCTION IfState( cState )

   LOCAL lExact, nPosition

   lExact := Set( _SET_EXACT, FALSE )
   nPosition := AScan( STATES_ARRAY, Upper( cState ) ) // STATES_ARRAY is a #define
   IF nPosition == 0
      MsgAlert( "Invalid State Abbreviation." )
   ENDIF
   SET( _SET_EXACT, lExact )

RETURN( nPosition > 0 )

/****************************************************************************/
STATIC FUNCTION IsWinXP()

RETURN _HMG_IsXP
/*
*/
STATIC FUNCTION RowCharToPix( nValor )

RETURN nValor * 14
/*
*/
STATIC FUNCTION ColCharToPix( nValor )

RETURN nValor * 8
/*
Static Function RowPixToChar( nValor )
Return Round(nValor/14,0)

Static Function ColPixToChar( nValor )
Return Round(nValor/8,0)
*/
STATIC FUNCTION LenChartopix( cText )

RETURN ColChartopix( Len( cText ) + 1 )
