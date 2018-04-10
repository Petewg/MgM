/*******************************************************************************
    Filename        : TextCase.Prg
    URL             : \CaseConvert\TextCase.Prg

    Created         : 12 January 2018 (14:05:41)
    Created by      : Pierpaolo Martinello

    Last Updated    : 18 January 2018 (23:11:55)
    Updated by      : Pierpaolo

    Comments        : HL_ATokens     Line 188
*******************************************************************************/
/*

   Based upon Camel Case work by PCA.
   Based upon Esgici Hmg Demo
   Adapted for Minigui Extended by Pierpaolo Martinello
   DB10

*/

#include <hmg.ch>

#define  HRBDfDelmtrs Chr( 0 )  + Chr( 9 ) + Chr( 10 ) + Chr( 13 ) +;  // Harbour Default delimiters
                      Chr( 26 ) + ;                                    // hb_BChar( 138 ) + hb_BChar( 141 ) +
                      Chr( 32 ) + ",.;:!\?/\\<>()#&%+_-*"

#define SB_BOTH       3

MEMVAR aTypeCond
MEMVAR aAddDelmt
MEMVAR aCaseConv

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE Main()

   InitData()

   LOAD   WINDOW TextCase AS frmTextCase
   ON KEY ESCAPE OF frmTextCase ACTION ThisWindow.Release()
   CENTER WINDOW frmTextCase
   ACTIVATE WINDOW frmTextCase

RETURN // TextCase.Main

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE SayInfo()

   DEFINE WINDOW frmInfo ;
      AT 0,0 ;
      WIDTH  670 ;
      HEIGHT 600;
      TITLE "Info" ;
      MODAL ;
      ON INIT ( frmInfo.imgLCaseInfo.Hide(), frmInfo.hlnkWikiLC.Hide() )

      DEFINE MAIN MENU OF frmInfo
         DEFINE POPUP "Info"
            ITEM "&About Program"        NAME mitPrgInfo ACTION ( frmInfo.imgLCaseInfo.Hide(), frmInfo.imgPrgInfo.Show(), frmInfo.hlnkWikiLC.Hide() )
            ITEM "&Text Case Conversion" NAME mitTCCInfo ACTION ( frmInfo.imgPrgInfo.Hide(), frmInfo.imgLCaseInfo.Show(), frmInfo.hlnkWikiLC.Show() )
            ITEM "&Back to program"+chr(9)+"Esc"  Action ThisWindow.Release
         END POPUP
      END MENU

      ON KEY ESCAPE OF frmInfo ACTION ThisWindow.Release

      @  0, 0 IMAGE imgLCaseInfo PICTURE "CaseComp" WIDTH 680 HEIGHT 510

      @  0, 0 IMAGE imgPrgInfo   PICTURE "PrgInfo"  WIDTH 670 HEIGHT 500

      DEFINE HYPERLINK hlnkWikiLC
             ROW        510
             COL        270
             VALUE      'Source'
             AUTOSIZE   .T.
             ADDRESS    'http://en.wikipedia.org/wiki/Letter_case#Computers'
             HANDCURSOR .T.
         END HYPERLINK

   END WINDOW

   CENTER   WINDOW frmInfo
   ACTIVATE WINDOW frmInfo

RETURN // SayInfo()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE InitData()

PUBLIC aTypeCond := { ;                // Conversion types and conditions
                      { 2, 2, 10, 1 },;    // Camel ( all lower except 1st )
                      { 2, 2, 11, 1 },;    // Lower ( all lower except 2nd )
                      { 2, 2,  3, 2 },;    // Start ( Convert only 1.st to Upper )
                      { 2, 2,  2, 3 },;    // U_Snake
                      { 2, 2,  7, 3 },;    // L_Snake
                      { 2, 2,  3, 4 },;    // U_Train
                      { 2, 2,  3, 4 } }    // L_Train

PUBLIC aAddDelmt := { '', ' ', '_', '-', ',', ';', ':' }

PUBLIC aCaseConv := { ;
       { | cText | cText }                                                                 ,;  //  1  left intact
       { | cText | UPPER( cText ) }                                                        ,;  //  2  uppercase all
       { | cText | UPPER( LEFT( cText, 1 ) ) + SUBSTR( cText, 2 ) }                        ,;  //  3  uppercase only 1st
       { | cText | LEFT( cText, 1 ) + UPPER( SUBSTR( cText, 2, 1 ) + SUBSTR( cText, 3 ) )} ,;  //  4  uppercase only 2nd
       { | cText | LOWER( LEFT( cText, 1 ) ) + UPPER( SUBSTR( cText, 2 ) )}                ,;  //  5  uppercase all except 1st
       { | cText | STUFF( UPPER( cText ), 2, 1, LOWER( SUBSTR( cText, 2, 1 ) ) ) }         ,;  //  6  uppercase all except 2nd
       { | cText | LOWER( cText ) }                                                        ,;  //  7  lowercase all
       { | cText | LOWER( LEFT( cText, 1 ) ) + SUBSTR( cText, 2 ) }                        ,;  //  8  lowercase only 1st
       { | cText | LEFT( cText, 1 ) + LOWER( SUBSTR( cText, 2, 1 ) + SUBSTR( cText, 3 ) )} ,;  //  9  lowercase only 2nd
       { | cText | UPPER( LEFT( cText, 1 ) ) + LOWER( SUBSTR( cText, 2 ) ) }               ,;  // 10  lowercase all except 1st
       { | cText | STUFF( LOWER( cText ), 2, 1, UPPER( SUBSTR( cText, 2, 1 ) ) ) }         }   // 11  lowercase all except 2nd

RETURN // InitData()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE AdjustConds()                             // Adjust Conditions

   LOCAL nTCCType := frmTextCase.rgbConvType.Value

   SHOWSCROLLBAR (GetControlHandle("cmbCaseConv","frmTextCase"), SB_BOTH , .F.)
   frmTextCase.txbResult.Value := ''

   frmTextCase.rgbPunct.Value    := aTypeCond[ nTCCType, 1 ]
   frmTextCase.rgbSpace.Value    := aTypeCond[ nTCCType, 2 ]
   frmTextCase.cmbCaseConv.Value := aTypeCond[ nTCCType, 3 ]
   frmTextCase.rgbDelmAdd.Value  := aTypeCond[ nTCCType, 4 ]

RETURN // AdjustConds()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE TCCApply( cSrcText )

   LOCAL nTCCType := frmTextCase.rgbConvType.Value

   LOCAL cDelims := HRBDfDelmtrs

   LOCAL cCntChr := LEFT( cDelims, 5 ),;
         cPuncts := SUBSTR( cDelims, 7 )

   LOCAL nPnCond := frmTextCase.rgbPunct.Value,;
         nSpCond := frmTextCase.rgbSpace.Value,;
         nCCCond := frmTextCase.cmbCaseConv.Value,;
         nDACond := frmTextCase.rgbDelmAdd.Value

   LOCAL cAddDlm := aAddDelmt[ nDACond ]

   LOCAL cResult := '',;
         n1Token,;
         c1Token,;
         aSrcText

   IF nPnCond = 1            // left intact
      cDelims := LEFT( cDelims, 6 )
   ENDIF

   IF nSpCond = 1            // left intact
      cDelims := STRTRAN( cDelims, " ", "" )  // cCntChr + cPuncts
   ENDIF

   aSrcText := HL_ATokens( cSrcText, cDelims )

   FOR n1Token := 1 TO LEN( aSrcText )
      c1Token := aSrcText[ n1Token ]
      cResult += EVAL( aCaseConv[ nCCCond ], c1Token ) + IF( n1Token < LEN( aSrcText ), cAddDlm, '' )
   NEXT n1Token

   frmTextCase.txbResult.Value := cResult

   frmTextCase.txbResult.SetFocus()

RETURN // TCCApply()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   HL_ATokens()   : Convert a string to an array

   Syntax : HL_ATOKENS( <cString>,  [<cDelims>],  [<lIncEmpt>] ) --> <aTokens>

   Arguments :  <cString>, : String to convert
                <cDelims>  : Delimiters, one or more character; default is ','
                <lIncEmpt> : Include empty elements; default is .F.

   Return : <aTokens> : Array produced from <cString>

   Since HB_ATOKENS() works only single char delimiter

   DB11

*/

FUNCTION HL_ATokens(;
                     cString,;  // String to convert
                     cDelims,;  // Delimiters
                     lIncEmpt ) // Include empty elems

   LOCAL aRVal  := {},;
         c1Elem := ''

   HB_DEFAULT( @cDelims, ',' )
   HB_DEFAULT( @lIncEmpt, .F. )

   TOKENINIT( cString, cDelims, 1 )

   WHILE !TOKENEND()
      c1Elem := TOKENNEXT( cString )
      IF !EMPTY( c1Elem ) .OR. lIncEmpt
         AADD( aRVal, c1Elem )
      ENDIF
   ENDDO

   TOKENEXIT()

RETU aRVal // HL_ATokens()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION HL_Arr2Text( ;
                       aArray,;
                       cDelim )  // element delimiter
   LOCAL cRVal := ''

   HB_DEFAULT( aArray, {} )
   HB_DEFAULT( @cDelim, ' | ' )

   AEVAL( aArray, { | x1 | cRVal += HB_ValToStr( x1 ) + cDelim } )

RETU cRVal // HL_Arr2Text(

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


// SHOWSCROLLBAR (hWnd, wBar, bShow)
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC ( SHOWSCROLLBAR )
{
   HWND hWnd  = (HWND) HB_PARNL (1);
   INT  wBar  = (INT)  hb_parni (2);
   BOOL bShow = (BOOL) hb_parl  (3);

   hb_retl (ShowScrollBar (hWnd, wBar, bShow));
}

#pragma ENDDUMP
