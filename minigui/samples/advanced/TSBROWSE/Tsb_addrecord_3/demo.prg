/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */

#include "minigui.ch"
#include "tsbrowse.ch"

REQUEST DBFCDX

FIELD KODS, NAME, ID

MEMVAR oBrw, aResult

// -----------------------------------
PROCEDURE Main()
// -----------------------------------
   LOCAL i, oCol, aStru, cAls, cBrw
   LOCAL cFile := "datab"

   rddSetDefault( "DBFCDX" )

   SET CENTURY      ON
   SET DATE         GERMAN
   SET DELETED      ON
   SET EXCLUSIVE    ON
   SET EPOCH TO     2000
   SET AUTOPEN      ON
   SET EXACT        ON
   SET SOFTSEEK     ON

   SET NAVIGATION   EXTENDED

   SET FONT TO "Arial", 11

   aStru := { ;
      { "KODS", "C", 10, 0 }, ;
      { "NAME", "C", 15, 0 }, ;
      { "EDIZ", "C", 10, 0 }, ;
      { "KOLV", "N", 15, 3 }, ;
      { "CENA", "N", 15, 3 }, ;
      { "ID", "+",  4, 0 }  ;
      }

   IF ! hb_FileExists( cFile + ".dbf" )
      dbCreate( cFile, aStru )
   ENDIF

   USE datab ALIAS base NEW

   IF LastRec() == 0
      FOR i := 10 TO 1 STEP -1
         APPEND BLANK
         REPLACE KODS WITH hb_ntos( i ), ;
            NAME WITH RandStr( 15 ),   ;
            EDIZ WITH 'kg',          ;
            KOLV WITH RecNo() * 1.5, ;
            CENA WITH RecNo() * 2.5
      NEXT
   ENDIF

   dbGoTop()

   IF ! hb_FileExists( cFile + IndexExt() )
      INDEX ON TR0( KODS )   TAG KOD  FOR ! Deleted()
      INDEX ON Upper( NAME ) TAG NAM  FOR ! Deleted()
      INDEX ON ID          TAG FRE  FOR   Deleted()
   ENDIF

   ordSetFocus( "NAM" )
   dbGoTop()
   cALs := Alias()

   GO TOP

   DEFINE FONT FontBold FONTNAME _HMG_DefaultFontName ;
      SIZE _HMG_DefaultFontSize BOLD  // Default for TsBrowse

   PRIVATE oBrw

   DEFINE WINDOW win_1 AT 0, 0 WIDTH 650 HEIGHT 500 ;
      MAIN TITLE "TSBrowse Add Record Demo"         ;
      NOMAXIMIZE NOSIZE        ;
      ON INIT NIL              ;
      ON RELEASE  dbCloseAll()

   DEFINE TBROWSE oBrw AT 40, 10 ALIAS cAls  WIDTH 620 HEIGHT 418  CELL

   WITH OBJECT oBrw

      cBrw       := :cControlName
      :hFontHead := GetFontHandle( "FontBold" )
      :hFontFoot := :hFontHead
      :lCellBrw  := .T.

      :aColSel   := { "KODS", "NAME", "KOLV", "CENA", "ID" }

      :LoadFields( .T. )

      :SetColor( { 6 }, { {|a, b, c| If( c:nCell == b, { Rgb( 66, 255, 236 ), Rgb( 209, 227, 248 ) }, ;
         { Rgb( 220, 220, 220 ), Rgb( 220, 220, 220 ) } ) } } )

      oCol                   := :GetColumn( 'KODS' )
      oCol:lEdit             := .F.
      oCol:cHeading          := "Product" + CRLF + "code"
      oCol:cOrder            := "KOD"
      oCol:lNoDescend        := .T.
      oCol:nAlign            := 1
      oCol:nFAlign           := 1
      oCol:cFooting          := {| nc| nc := ( oBrw:cAlias )->( ordKeyNo() ),    ;
         iif( Empty( nc ), '', '#' + hb_ntos( nc ) ) }

      oCol                   := :GetColumn( 'NAME' )
      oCol:cHeading          := "Denomination"
      oCol:cOrder            := "NAM"
      oCol:nWidth            := 190
      oCol:lNoDescend        := .T.
      oCol:lOnGotFocusSelect := .T.
      oCol:lEmptyValToChar   := .T.
      oCol:bPrevEdit         := {|val, brw| Prev( val, brw ) }
      oCol:bPostEdit         := {|val, brw| Post( val, brw ) }

      oCol                   := :GetColumn( 'KOLV' )
      oCol:cHeading          := "Amount"
      oCol:lOnGotFocusSelect := .T.
      oCol:lEmptyValToChar   := .T.
      oCol:bPrevEdit         := {|val, brw    | Prev( val, brw    ) }
      oCol:bPostEdit         := {|val, brw, add| Post( val, brw, add ) }

      oCol                   := :GetColumn( 'CENA' )
      oCol:cHeading          := "Price" + CRLF + "for unit"
      oCol:lOnGotFocusSelect := .T.
      oCol:lEmptyValToChar   := .T.
      oCol:bPrevEdit         := {|val, brw    | Prev( val, brw    ) }
      oCol:bPostEdit         := {|val, brw, add| Post( val, brw, add ) }

      oCol                   := :GetColumn( 'ID' )
      oCol:lEdit             := .F.
      oCol:nWidth            := 60
      oCol:cHeading          := "Id"
      oCol:cPicture          := '99999'
      oCol:nAlign            := 1
      oCol:nFAlign           := 1
      oCol:cFooting          := {| nc| nc := ( oBrw:cAlias )->( ordKeyCount() ), ;
         iif( Empty( nc ), '', hb_ntos( nc ) ) }

      :aSortBmp := { LoadImage( "br_up.bmp" ), LoadImage( "br_dn.bmp" ) }

      :SetIndexCols( :nColumn( 'KODS' ), :nColumn( 'NAME' ) )
      :SetOrder( :nColumn( 'NAME' ) )

      AEval( :aColumns, {| oCol| oCol:lFixLite := .T. } )

      :lNoGrayBar   := .T.
      :nWheelLines  := 1
      :nClrLine     := COLOR_GRID
      :nHeightCell  += 5
      :nHeightHead  += 5
      :nHeightFoot  := :nHeightCell + 5
      :lDrawFooters := .T.
      :lFooting     := .T.
      :lNoVScroll   := .F.
      :lNoHScroll   := .T.
      :nFreeze      := 1
      :lLockFreeze  := .T.

      :SetDeleteMode( .T., .F. )

      :bChange      := {| oBr| oBr:DrawFooters() }
      :bLDblClick   := {| uP1, uP2, nFl, oBr| uP1 := Nil, uP2 := Nil, nFl := Nil, ;
         oBr:PostMsg( WM_KEYDOWN, VK_F4, 0 ) }

      :nFireKey     := VK_F4                       // default Edit

      :UserKeys( VK_RETURN, {| oBr      | oBr:SetFocus(), .F. } )
      :UserKeys( VK_F2, {| oBr, nKy, cKy| Add_Rec( oBr, nKy, cKy ), oBr:SetFocus() } )
      :UserKeys( VK_F3, {| oBr, nKy, cKy| Del_Rec( oBr, nKy, cKy ), oBr:SetFocus(), .F. } )
      :UserKeys( VK_F6, {| oBr          | oBr:SetOrder( oBr:nColumn( ;
         iif( ( oBr:cAlias )->( ordSetFocus() ) == "KOD", 'NAME', 'KODS' ) ) ), oBr:SetFocus() } )

      if :nLen > :nRowCount()
         :ResetVScroll( .T. )
         :oHScroll:SetRange( 0, 0 )
      ENDIF

   END WITH

   END TBROWSE

   @ 06,  10  BUTTON BADD  CAPTION "Add     F2"  ACTION oBrw:PostMsg( WM_KEYDOWN, VK_F2, 0 )
   @ 06, 110  BUTTON BDEL  CAPTION "Del     F3"  ACTION oBrw:PostMsg( WM_KEYDOWN, VK_F3, 0 )
   @ 06, 210  BUTTON BEDIT CAPTION "Edit    F4"  ACTION oBrw:PostMsg( WM_KEYDOWN, VK_F4, 0 )
   @ 06, 310  BUTTON BORD  CAPTION "Order   F6"  ACTION oBrw:PostMsg( WM_KEYDOWN, VK_F6, 0 )

   @ 0, 0 GETBOX DELETE  HEIGHT 5  WIDTH 7  VALUE "" ;
      BACKCOLOR { RED, RED, RED }  INVISIBLE

   END WINDOW

   oBrw:SetNoHoles()
   oBrw:SetFocus()

   CENTER   WINDOW win_1
   ACTIVATE WINDOW win_1

RETURN

// -----------------------------------
FUNCTION TR0( c )
// -----------------------------------
RETURN PadL( AllTrim( c ), Len( c ) )

// -----------------------------------
FUNCTION RandStr( nLen )
// -----------------------------------
   LOCAL cSet  := "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
   LOCAL cPass := ""
   LOCAL i

   IF PCount() < 1
      cPass := " "
   ELSE
      FOR i := 1 TO nLen
         cPass += SubStr( cSet, Random( 52 ), 1 )
      NEXT
   ENDIF

RETURN cPass

// -----------------------------------
STATIC FUNCTION Prev( uVal, oBrw )
// -----------------------------------
   LOCAL nCol, oCol

   WITH OBJECT oBrw
      nCol := :nCell
      oCol := :aColumns[ nCol ]
      oCol:Cargo := uVal            // old value
   END WITH

RETURN .T.

// -----------------------------------
STATIC FUNCTION Post( uVal, oBrw )
// -----------------------------------
   LOCAL nCol, oCol, cNam, uOld, lMod, cAls

   WITH OBJECT oBrw
      nCol := :nCell
      oCol := :aColumns[ nCol ]
      cNam := oCol:cName
      uOld := oCol:Cargo            // old value
      lMod := ! uVal == uOld        // .T. - modify value
      cAls := :cAlias
   END WITH

RETURN .T.

// -----------------------------------
STATIC FUNCTION Del_Rec( oBrw )
// -----------------------------------
   LOCAL oCel, nY, nX, nH, nK, lNoG

   WITH OBJECT oBrw

      lNoG := :lNoGrayBar
      oCel := :GetCellInfo( :nRowPos, :nColumn( "KODS" ) )
      nY   := oCel:nRow
      nX   := oCel:nCol
      nH   := oCel:nHeight

      :lNoGrayBar := .F.

      win_1.DELETE.Row    := nY + 2
      win_1.DELETE.Col    := nX + 2
      win_1.DELETE.Height := nH -4
      win_1.DELETE.Show()
      win_1.DELETE.SetFocus()
      DO EVENTS
      ShowGetValid( win_1.DELETE.Handle, " Y - delete ", 'DELETE RECORD', 'E' )
      nK := InkeyGui( 10 * 1000 )
      win_1.DELETE.Hide()

      :lNoGrayBar := lNoG

      IF nK == 89 // .or. nK == 13
         :DeleteRow( .F. )
      ENDIF

   END WITH

RETURN NIL

// -----------------------------------
STATIC FUNCTION Add_Rec( oBrw )
// -----------------------------------
   LOCAL cBrw, cAls
   LOCAL nWdt, nPos, nLen
   LOCAL nRow, nCol, nRec, oCel
   LOCAL cKods, cName, cKodP, cNamP
   LOCAL nY, nX, nW, nHgt
   LOCAL nX1, nW1
   LOCAL nX2, nW2
   LOCAL cWnd  := oBrw:cParentWnd
   LOCAL hWnd  := GetFormHandle( cWnd )
   LOCAL hInpl := _HMG_InplaceParentHandle

   _HMG_InplaceParentHandle := hWnd

   PRIVATE aResult

   WITH OBJECT oBrw

      cBrw := :cControlName
      cAls := :cAlias

      nRow := :nTop  + GetWindowRow( hWnd ) - GetBorderHeight()
      nCol := :nLeft + GetWindowCol( hWnd ) - GetBorderWidth () + 1

      nPos := iif( :nLen < :nRowCount(), :nLen, :nRowCount() )
      oCel := :GetCellInfo( nPos, :nColumn( "KODS" ) )
      nY   := oCel:nRow + :nHeightCell
      nX   := oCel:nCol
      nW   := oCel:nWidth
      nHgt := :nHeightCell
      nWdt := nW
      nW1  := nW -4
      nX1  := 1

      oCel := :GetCellInfo( nPos, :nColumn( "NAME" ) )
      nW   := oCel:nWidth
      nW2  := nW
      nWdt += nW

   END WITH

   nRow  += nY
   nCol  += nX

   nLen  := Len( ( cAls )->KODS )
   cKods := GetNewKod()
   cKodP := "@K " + repl( '9', nLen )

   nLen  := Len( ( cAls )->NAME )
   cName := Space( nLen )
   cNamP := "@K " + repl( 'X', nLen )

   DEFINE WINDOW wNewRec  ;
      AT nRow, nCol  WIDTH nWdt  HEIGHT nHgt  TITLE ''      ;
      MODAL          NOSIZE      NOSYSMENU    NOCAPTION     ;
      ON INIT      ( This.Topmost := .T., InkeyGui( 10 ),     ;
      This.Topmost := .F. )

   @ 0, nX1 GETBOX KODS  HEIGHT nHgt  WIDTH nW1  VALUE cKods  PICTURE cKodP  VALID VldNewRec()

   nX2 := This.KODS.Width + nX1 + 1

   @ 0, nX2 GETBOX NAME  HEIGHT nHgt  WIDTH nW2  VALUE cName  PICTURE cNamP  VALID VldNewRec()

   ON KEY ESCAPE ACTION  ThisWindow.Release

   END WINDOW

   ACTIVATE WINDOW wNewRec

   _HMG_InplaceParentHandle := hInpl

   IF ! Empty( aResult )
      dbSelectArea( cAls )
      dbAppend()
      IF ! NetErr() .AND. RLock()
         nRec := RecNo()
         REPL KODS WITH aResult[ 1 ], ;
            NAME WITH aResult[ 2 ]
         IF oBrw:nLen == oBrw:nRowCount()
            oBrw:oHScroll:SetRange( 0, 0 )
         ENDIF
         oBrw:GotoRec( nRec )
         nCol := oBrw:nColumn( "NAME" )
         IF nCol != oBrw:nCell
            oBrw:nCell := nCol
            oBrw:DrawSelect()
         ENDIF
         oBrw:lChanged := .T.
         oBrw:PostEdit( aResult[ 2 ], nCol, Nil )
         DO EVENTS
         oBrw:PostMsg( WM_KEYDOWN, VK_F4, 0 )
      ENDIF
   ENDIF

RETURN NIL

// -----------------------------------
STATIC FUNCTION GetNewKod()
// -----------------------------------
   LOCAL cAls := oBrw:cAlias
   LOCAL nLen := Len( ( cAls )->KODS )

RETURN Left( hb_ntos( ( cAls )->( ordKeyCount() ) + 1 ) + Space( nLen ), nLen )

// -----------------------------------
STATIC FUNCTION VldNewRec()
// -----------------------------------
   LOCAL cWnd := _HMG_ThisFormName
   LOCAL cGet := _HMG_ThisControlName
   LOCAL cAls := oBrw:cAlias
   LOCAL lRet := .T., lSek, cOrd
   LOCAL cVal := _GetValue( cGet, cWnd )
   LOCAL cGkd := 'KODS', cKod

   IF Empty( cVal )
      lRet := .F.
   ELSEIF cGet == cGkd
   ELSEIF cGet == 'NAME'
      cKod := _GetValue( cGkd, cWnd )
      cOrd := ordSetFocus( "KOD" )
      lSek := ( cAls )->( dbSeek( TR0( cKod ) ) )
      ordSetFocus( cOrd )

      IF lSek
         Tone( 500, 1 )
         _SetValue( cGkd, cWnd, GetNewKod() )
         _SetFocus( cGkd, cWnd )
         aResult := NIL
      ELSE
         aResult := { cKod, cVal }
         DoMethod( cWnd, 'Release' )
      ENDIF
   ENDIF

RETURN lRet


#pragma BEGINDUMP

#define _WIN32_WINNT 0x0600

#include <windows.h>

#include "hbapi.h"
#include "hbapicdp.h"

#include <commctrl.h>
/*
typedef struct _tagEDITBALLOONTIP
{
   DWORD   cbStruct;
   LPCWSTR pszTitle;
   LPCWSTR pszText;
   INT     ttiIcon; // From TTI_*
} EDITBALLOONTIP, *PEDITBALLOONTIP;
*/
#define EM_SHOWBALLOONTIP   (ECM_FIRST + 3)     // Show a balloon tip associated to the edit control
#define Edit_ShowBalloonTip(hwnd, peditballoontip)  (BOOL)SNDMSG((hwnd), EM_SHOWBALLOONTIP, 0, (LPARAM)(peditballoontip))
#define EM_HIDEBALLOONTIP   (ECM_FIRST + 4)     // Hide any balloon tip associated with the edit control
#define Edit_HideBalloonTip(hwnd)  (BOOL)SNDMSG((hwnd), EM_HIDEBALLOONTIP, 0, 0)

// ToolTip Icons (Set with TTM_SETTITLE)
#define TTI_NONE                0
#define TTI_INFO                1
#define TTI_WARNING             2
#define TTI_ERROR               3
#if (_WIN32_WINNT >= 0x0600)
  #define TTI_INFO_LARGE        4
  #define TTI_WARNING_LARGE     5
  #define TTI_ERROR_LARGE       6
#endif  // (_WIN32_WINNT >= 0x0600)

#define ECM_FIRST               0x1500      // Edit control messages

/*
   ShowGetValid( hWnd, cText [ , cTitul ]   [ , cTypeIcon ] )
*/

#if ( HB_VER_MAJOR == 3 )
  #define _hb_cdpGetU16( cdp, fCtrl, ch)  hb_cdpGetU16(cdp, ch )
  #define _hb_cdpGetChar(cdp, fCtrl, ch)  hb_cdpGetChar(cdp, ch)
#else
  #define _hb_cdpGetU16( cdp, fCtrl, ch)  hb_cdpGetU16(cdp, fCtrl, ch )
  #define _hb_cdpGetChar(cdp, fCtrl, ch)  hb_cdpGetChar(cdp, fCtrl, ch)
#endif

HB_FUNC( SHOWGETVALID )
{
   int i, k;
   const char *tp, *s;
   WCHAR Text[512];
   WCHAR Title[512];

   EDITBALLOONTIP bl;

   PHB_CODEPAGE  s_cdpHost = hb_vmCDP();

   HWND hWnd = ( HWND ) hb_parnl(1);

   if( ! IsWindow( hWnd ) )
      return;

   bl.cbStruct = sizeof( EDITBALLOONTIP );
   bl.pszTitle = NULL;
   bl.pszText  = NULL;
   bl.ttiIcon  = TTI_NONE;

   if( HB_ISCHAR( 2 ) ){

       ZeroMemory( Text,  sizeof(Text) );

       k = hb_parclen(2);
       s = (const char *) hb_parc(2);
       for(i=0;i<k;i++) Text[i] = _hb_cdpGetU16( s_cdpHost, TRUE, s[i] );
       bl.pszText  = Text;
   }

   if( HB_ISCHAR( 3 ) ){

       ZeroMemory( Title,  sizeof(Title) );

       k = hb_parclen(3);
       s = (const char *) hb_parc(3);
       for(i=0;i<k;i++) Title[i] = _hb_cdpGetU16( s_cdpHost, TRUE, s[i] );
       bl.pszTitle  = Title;
   }

   tp = ( const char * ) hb_parc(4);

   switch( *tp ){
       case 'E' :  bl.ttiIcon  = TTI_ERROR_LARGE;   break;
       case 'e' :  bl.ttiIcon  = TTI_ERROR;         break;

       case 'I' :  bl.ttiIcon  = TTI_INFO_LARGE;    break;
       case 'i' :  bl.ttiIcon  = TTI_INFO;          break;

       case 'W' :  bl.ttiIcon  = TTI_WARNING_LARGE; break;
       case 'w' :  bl.ttiIcon  = TTI_WARNING;       break;

   }

   Edit_ShowBalloonTip( hWnd, &bl );

}

#pragma ENDDUMP
