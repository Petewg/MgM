/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Demo was contributed to HMG forum by Edward 02/Apr/2018
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

#include "hmg.ch"
#include "i_winnls.ch"  // Constants for HMG_GetLocaleInfo

Function Main

//LOCALE_SDECIMAL
//Character(s) used as the decimal separator.
//The maximum allowed is four.
LOCAL cDec := HMG_GetLocaleInfo( LOCALE_SDECIMAL )
//LOCALE_SNEGATIVESIGN
//String value for the negative sign.
//The maximum allowed is five.
LOCAL cNeg := HMG_GetLocaleInfo( LOCALE_SNEGATIVESIGN )
//LOCALE_STHOUSAND
//Character(s) used to separate groups of digits to
//the left of the decimal. The maximum allowed is four.
LOCAL cTho := HMG_GetLocaleInfo( LOCALE_STHOUSAND )
//LOCALE_SGROUPING
//Sizes for each group of digits to the left of the
//decimal. An explicit size is needed for each group,
//and sizes are separated by semicolons. If the last
//value is zero, the preceding value is repeated. For
//example, to group thousands, specify 3;0.
//Indic locales group the first thousand and then group
//by hundreds - for example 12,34,56,789, which is
//represented by 3;2;0.
LOCAL cGro := HMG_GetLocaleInfo( LOCALE_SGROUPING )

LOCAL aDec := {}

AEval( Array(10), {|x,i| AAdd( aDec, hb_ntos( i - 1 ) ) } )

DEFINE WINDOW frm1 ;
   WIDTH 397 HEIGHT 416 ;
   TITLE "User Locale Numerics Demo" ;
   MAIN ;
   NOMAXIMIZE NOSIZE

   @ 30, 30 LABEL Label_1 VALUE "Decimal symbol:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb1
            ROW    30
            COL    190
            WIDTH  160
            HEIGHT 100
            ITEMS { cDec }
            VALUE 1
            DISPLAYEDIT .T.
      END COMBOBOX

   //LOCALE_IDIGITS
   //Number of fractional digits. The maximum allowed is two.
   @ 60, 30 LABEL Label_2 VALUE "No. of digits after decimal:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb2
            ROW    60
            COL    190
            WIDTH  160
            HEIGHT 220
            ITEMS aDec
            VALUE Val( HMG_GetLocaleInfo( LOCALE_IDIGITS ) ) + 1
      END COMBOBOX

   @ 90, 30 LABEL Label_3 VALUE "Digit grouping symbol:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb3
            ROW    90
            COL    190
            WIDTH  160
            HEIGHT 100
            ITEMS { cTho }
            VALUE 1
            DISPLAYEDIT .T.
      END COMBOBOX

   @120, 30 LABEL Label_4 VALUE "Digit grouping:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb4
            ROW    120
            COL    190
            WIDTH  160
            HEIGHT 100
            ITEMS { '123456789', '123'+cTho+'456'+cTho+'789', '123456'+cTho+'789', '12'+cTho+'34'+cTho+'56'+cTho+'789' }
            VALUE 1
      END COMBOBOX

	frm1.cmb4.VALUE := IF(cGro = '0', 1, ;
			  IF(cGro == '3;0', 2, ;
			  IF(cGro == '3;0;0', 3, ;
			  IF(cGro == '3;2;0', 4, 0 ))))

   @150, 30 LABEL Label_5 VALUE "Negative sign symbol:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb5
            ROW    150
            COL    190
            WIDTH  160
            HEIGHT 100
            ITEMS { cNeg }
            VALUE 1
            DISPLAYEDIT .T.
      END COMBOBOX

   //LOCALE_INEGNUMBER
   //Negative number mode, that is, the format for a negative
   //number. The maximum allowed is two.
   @180, 30 LABEL Label_6 VALUE "Negative number format:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb6
            ROW    180
            COL    190
            WIDTH  160
            HEIGHT 120
            ITEMS { '(1'+cDec+'1)', cNeg+'1'+cDec+'1', cNeg+' 1'+cDec+'1', '1'+cDec+'1'+cNeg, '1'+cDec+'1 '+cNeg }
            VALUE 1
      END COMBOBOX

	frm1.cmb6.VALUE := IF(HMG_GetLocaleInfo( LOCALE_INEGNUMBER ) ='0', 1 , ;
			  IF(HMG_GetLocaleInfo( LOCALE_INEGNUMBER ) ='1', 2, ;
			  IF(HMG_GetLocaleInfo( LOCALE_INEGNUMBER ) ='2', 3, ;
			  IF(HMG_GetLocaleInfo( LOCALE_INEGNUMBER ) ='3', 4, ;
			  IF(HMG_GetLocaleInfo( LOCALE_INEGNUMBER ) ='4', 5, 0 )))))

   //LOCALE_ILZERO
   //Specifier for leading zeros in decimal fields. The maximum allowed is two.
   @210, 30 LABEL Label_7 VALUE "Display leading zeros:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb7
            ROW    210
            COL    190
            WIDTH  160
            HEIGHT 120
            ITEMS { cDec + '7', '0' + cDec + '7' }
            VALUE IF( HMG_GetLocaleInfo( LOCALE_ILZERO ) = '0', 1, 2 )
      END COMBOBOX

   @240, 30 LABEL Label_8 VALUE "List separator:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb8
            ROW    240
            COL    190
            WIDTH  160
            HEIGHT 100
            ITEMS { HMG_GetLocaleInfo( LOCALE_SLIST ) }
            VALUE 1
            DISPLAYEDIT .T.
      END COMBOBOX

   @270, 30 LABEL Label_9 VALUE "Measurement system:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb9
            ROW    270
            COL    190
            WIDTH  160
            HEIGHT 120
            ITEMS { 'Metric', 'U.S.' }
            VALUE IF( HMG_GetLocaleInfo( LOCALE_IMEASURE ) = '0', 1, 2 )
      END COMBOBOX

IF IsWinNT()

   //LOCALE_SNATIVEDIGITS
   //Native equivalents to ASCII zero through 9.
   @300, 30 LABEL Label_10 VALUE "Standard digits:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb10
            ROW    300
            COL    190
            WIDTH  160
            HEIGHT 120
            ITEMS { HMG_GetLocaleInfo( LOCALE_SNATIVEDIGITS ) }
            VALUE 1
      END COMBOBOX

   @330, 30 LABEL Label_11 VALUE "Use native digits:" AUTOSIZE VCENTERALIGN

      DEFINE COMBOBOX cmb11
            ROW    330
            COL    190
            WIDTH  160
            HEIGHT 100
            ITEMS { 'Context-based', 'Never', 'Native' }
            VALUE Val( HMG_GetLocaleInfo( LOCALE_IDIGITSUBSTITUTION ) ) + 1
      END COMBOBOX

ENDIF

   ON KEY ESCAPE ACTION frm1.Release

END WINDOW

CENTER WINDOW frm1
ACTIVATE WINDOW frm1

Return Nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( HMG_GETLOCALEINFO )
{
   INT LCType = hb_parni( 1 );
   LPTSTR cText;

   cText = ( LPTSTR ) hb_xgrab( 128 );

   GetLocaleInfo( LOCALE_USER_DEFAULT, LCType, cText, 128 );

   hb_retc( cText );
   hb_xfree( cText );
}

#pragma ENDDUMP
