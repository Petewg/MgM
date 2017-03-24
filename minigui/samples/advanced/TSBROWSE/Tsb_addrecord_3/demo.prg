/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */

#include "minigui.ch"
#include "tsbrowse.ch"

REQUEST DBFCDX

FIELD KODS, NAME, ID

MEMVAR oBrw, aResult

*-----------------------------------
PROCEDURE Main()
*-----------------------------------
LOCAL i, oCol, aStru, cAls //, cBrw
LOCAL cFile := "datab"

 RddSetDefault("DBFCDX")

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
            { "ID"  , "+",  4, 0 }  ;
          }

 IF ! hb_FileExists( cFile + ".dbf" )
    dbCreate( cFile, aStru )
 ENDIF

 USE datab ALIAS base NEW

 IF LastRec() == 0
    FOR i := 10 TO 1 STEP -1
       APPEND BLANK
       REPLACE KODS WITH hb_ntos(i), ;
               NAME WITH RandStr(15),   ;
               EDIZ WITH 'kg',          ;
               KOLV WITH RecNo() * 1.5, ;
               CENA WITH RecNo() * 2.5
    NEXT
 ENDIF

 dbGoTop()

 IF ! hb_FileExists( cFile + IndexExt() )
    INDEX ON TR0(KODS)   TAG KOD  FOR ! deleted()
    INDEX ON UPPER(NAME) TAG NAM  FOR ! deleted()
    INDEX ON ID          TAG FRE  FOR   deleted()
 EndIf

 OrdSetFocus("NAM")
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
     
       // cBrw       := :cControlName
       :hFontHead := GetFontHandle( "FontBold" )
       :hFontFoot := :hFontHead
       :lCellBrw  := .T.

       :aColSel   := { "KODS", "NAME", "KOLV", "CENA", "ID" }

       :LoadFields(.T.)

       :SetColor( { 6 }, { { |a,b,c| a:=a,  If( c:nCell == b, {Rgb( 66, 255, 236), Rgb(209, 227, 248)}, ; 
                                                       {Rgb(220, 220, 220), Rgb(220, 220, 220)} ) } } )           

        oCol                   := :GetColumn('KODS')
        oCol:lEdit             := .F. 
        oCol:cHeading          := "Product"+CRLF+"code"
        oCol:cOrder            := "KOD"
        oCol:lNoDescend        := .T.
        oCol:nAlign            := 1
        oCol:nFAlign           := 1
        oCol:cFooting          := {|nc| nc := (oBrw:cAlias)->( OrdKeyNo() ),    ;
                                        iif( empty(nc), '', '#'+hb_ntos(nc) ) }
       
        oCol                   := :GetColumn('NAME')
        oCol:cHeading          := "Denomination"
        oCol:nWidth            := 190
        oCol:lNoDescend        := .T.
        oCol:lOnGotFocusSelect := .T.
        oCol:lEmptyValToChar   := .T.
        oCol:bPrevEdit         := { |val,brw| Prev(val,brw) }
        oCol:bPostEdit         := { |val,brw| Post(val,brw) }

        oCol                   := :GetColumn('KOLV')
        oCol:cHeading          := "Amount"      
        oCol:lOnGotFocusSelect := .T.
        oCol:lEmptyValToChar   := .T.
        oCol:bPrevEdit         := { |val,brw    | Prev(val,brw    ) }
        oCol:bPostEdit         := { |val,brw,add| Post(val,brw,add) }

        oCol                   := :GetColumn('CENA')
        oCol:cHeading          := "Price"+CRLF+"for unit"
        oCol:lOnGotFocusSelect := .T.
        oCol:lEmptyValToChar   := .T.
        oCol:bPrevEdit         := { |val,brw    | Prev(val,brw    ) }
        oCol:bPostEdit         := { |val,brw,add| Post(val,brw,add) }

        oCol                   := :GetColumn('ID')
        oCol:lEdit             := .F. 
        oCol:nWidth            := 60
        oCol:cHeading          := "Id"
        oCol:cPicture          := '99999'
        oCol:nAlign            := 1
        oCol:nFAlign           := 1
        oCol:cFooting          := {|nc| nc := (oBrw:cAlias)->( OrdKeyCount() ), ;
                                        iif( empty(nc), '', hb_ntos(nc) ) }

       :aSortBmp := { LoadImage("br_up.bmp"), LoadImage("br_dn.bmp") }

       :SetIndexCols( :nColumn('KODS'), :nColumn('NAME') )
       :SetOrder( :nColumn('NAME') )

        AEval( :aColumns, {|oCol| oCol:lFixLite := .T. } )

       :lNoGrayBar   := .T.
       :nWheelLines  := 1
       :nClrLine     := COLOR_GRID
       :nHeightCell  += 5
       :nHeightHead  += 5
       :nHeightFoot  += :nHeightCell + 5
       :lDrawFooters := .T.
       :lFooting     := .T.
       :lNoVScroll   := .F.
       :lNoHScroll   := .T.
       :nFreeze      := 1
       :lLockFreeze  := .T.

       :bChange      := {|oBr| oBr:DrawFooters() }
       :bUserKeys    := {|nKy,nFl,oBr| OnKeyDown(nKy, nFl, oBr) }
       :bLDblClick   := {|uP1,uP2,nFl,oBr| uP1 := Nil, uP2 := Nil, nFl := Nil, ;
                                      oBr:PostMsg( WM_KEYDOWN, VK_F4, 0 ) }

       :nFireKey     := VK_F4                       // default Edit

       if :nLen > :nRowCount()
          :ResetVScroll( .T. )
          :oHScroll:SetRange(0,0)
       EndIf
       
    END WITH
    
    END TBROWSE

    @ 06,  10  BUTTON BADD  CAPTION "Add     F2"  ACTION oBrw:PostMsg( WM_KEYDOWN, VK_F2, 0 )
    @ 06, 110  BUTTON BDEL  CAPTION "Del"         ACTION oBrw:PostMsg( WM_KEYDOWN, VK_F3, 0 )
    @ 06, 210  BUTTON BEDIT CAPTION "Edit    F4"  ACTION oBrw:PostMsg( WM_KEYDOWN, VK_F4, 0 )
    @ 06, 310  BUTTON BORD  CAPTION "Set Orders"  ACTION oBrw:PostMsg( WM_KEYDOWN, VK_F6, 0 )

 END WINDOW

 oBrw:SetNoHoles()
 oBrw:SetFocus()

 CENTER   WINDOW win_1
 ACTIVATE WINDOW win_1

RETURN

FUNCTION TR0( c )
RETURN PADL(AllTrim(c), len(c))

*-----------------------------------
FUNCTION RandStr( nLen )
*-----------------------------------
   LOCAL cSet  := "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
   LOCAL cPass := ""
   LOCAL i

   If pCount() < 1
      cPass := " "
   Else
      FOR i := 1 TO nLen
         cPass += SubStr( cSet, Random( 52 ), 1 )
      NEXT
   EndIf

RETURN cPass

*-----------------------------------
STATIC FUNCTION Prev( uVal, oBrw )
*-----------------------------------
Local nCol, oCol

 WITH OBJECT oBrw
    nCol := :nCell
    oCol := :aColumns[ nCol ]
    oCol:Cargo := uVal            // old value
 END WITH

RETURN .T.

*-----------------------------------
STATIC FUNCTION Post( uVal, oBrw )
*-----------------------------------
// this function does not do anything useful! p.d. 24/03/2017
// and produce compilation errors
HB_SYMBOL_UNUSED( uVal )
HB_SYMBOL_UNUSED( oBrw )
/*
Local nCol, oCol, uOld , cNam, lMod, cAls

 WITH OBJECT oBrw
    nCol := :nCell
    oCol := :aColumns[ nCol ]
    //cNam := oCol:cName
    //uOld := oCol:Cargo            // old value
    // lMod := ! uVal == uOld        // .T. - modify value
    // cAls := :cAlias
 END WITH
 */
RETURN .T.

*-----------------------------------
STATIC FUNC OnKeyDown( nKey, nFlg, oBrw )
*-----------------------------------
Local uRet, cOrd

 nFlg := Nil

 If     nKey == VK_RETURN
    uRet := .F.
    oBrw:SetFocus()
 ElseIf nKey == VK_F2
    Add_Rec(oBrw)
    oBrw:SetFocus()
 ElseIf nKey == VK_F3
    oBrw:SetFocus()
    uRet := .F.
 ElseIf nKey == VK_F4
    oBrw:SetFocus()
 ElseIf nKey == VK_F6
    WITH OBJECT oBrw
       cOrd := (:cAlias)->( OrdSetFocus() )
       :SetOrder( :nColumn(iif( cOrd == "KOD", 'NAME', 'KODS' )) )
       :SetFocus()
    END WITH
 EndIf

RETURN uRet

*-----------------------------------
STATIC FUNC Add_Rec( oBrw )
*-----------------------------------
Local /*cBrw,*/ cAls
Local nWdt, nPos, nLen
Local nRow, nCol, nRec, oCel
Local cKods, cName, cKodP, cNamP
Local nY , nX , nW , nHgt
Local nX1, nW1
Local nX2, nW2
Local cWnd  := oBrw:cParentWnd
Local hWnd  := GetFormHandle(cWnd)
Local hInpl := _HMG_InplaceParentHandle

 _HMG_InplaceParentHandle := hWnd

 PRIVATE aResult

 WITH OBJECT oBrw

    //cBrw := :cControlName
    cAls := :cAlias

    nRow := :nTop  + GetWindowRow(hWnd) - GetBorderHeight() 
    nCol := :nLeft + GetWindowCol(hWnd) - GetBorderWidth () + 1

    nPos := iif( :nLen < :nRowCount(), :nLen, :nRowCount() )
    oCel := :GetCellInfo(nPos, :nColumn("KODS"))
    nY   := oCel:nRow + :nHeightCell 
    nX   := oCel:nCol
    nW   := oCel:nWidth
    nHgt := :nHeightCell
    nWdt := nW 
    nW1  := nW - 4
    nX1  := 1

    oCel := :GetCellInfo(nPos, :nColumn("NAME"))
    nW   := oCel:nWidth
    nW2  := nW 
    nWdt += nW

 END WITH

 nRow  += nY
 nCol  += nX 

 nLen  := len( (cAls)->KODS )
 cKods := GetNewKod()
 cKodP := "@K "+repl('9', nLen)

 nLen  := len( (cAls)->NAME )
 cName := space(nLen)
 cNamP := "@K "+repl('X', nLen)

 DEFINE WINDOW wNewRec  ;
    AT nRow, nCol  WIDTH nWdt  HEIGHT nHgt  TITLE ''      ;
    MODAL          NOSIZE      NOSYSMENU    NOCAPTION     ;
    ON INIT      ( This.Topmost := .T., InkeyGui(10),     ;
                   This.Topmost := .F. )                  ;

    @ 0, nX1 GETBOX KODS  HEIGHT nHgt  WIDTH nW1  VALUE cKods  PICTURE cKodP  VALID VldNewRec()

    nX2 := This.KODS.Width + nX1 + 1

    @ 0, nX2 GETBOX NAME  HEIGHT nHgt  WIDTH nW2  VALUE cName  PICTURE cNamP  VALID VldNewRec()

    ON KEY ESCAPE ACTION  ThisWindow.Release
    
 END WINDOW

 ACTIVATE WINDOW wNewRec

 _HMG_InplaceParentHandle := hInpl

 If ! Empty(aResult)
    dbSelectArea(cAls)
    dbAppend()
    If ! NetErr() .and. RLock()
       nRec := RecNo()
       REPL KODS with aResult[1], ;
            NAME with aResult[2]
       If oBrw:nLen == oBrw:nRowCount()
          oBrw:oHScroll:SetRange(0,0)
       EndIf
       oBrw:GotoRec(nRec)
       nCol := oBrw:nColumn("NAME")
       If nCol != oBrw:nCell
          oBrw:nCell := nCol
          oBrw:DrawSelect()
       EndIf
       oBrw:lChanged := .T.
       oBrw:PostEdit(aResult[2], nCol, Nil)
       DO EVENTS
       oBrw:PostMsg(WM_KEYDOWN, VK_F4, 0)
    EndIf 
 EndIf

RETURN Nil

*-----------------------------------
STATIC FUNC GetNewKod()            
*-----------------------------------
Local cAls := oBrw:cAlias
Local nLen  := len( (cAls)->KODS )

RETURN left(hb_ntos((cAls)->( OrdKeyCount() )+1)+space(nLen), nLen)

*-----------------------------------
STATIC FUNC VldNewRec()            
*-----------------------------------
Local cWnd := _HMG_ThisFormName
Local cGet := _HMG_ThisControlName
Local cAls := oBrw:cAlias
Local lRet := .T., lSek, cOrd
Local cVal := _GetValue(cGet, cWnd)
Local cGkd := 'KODS', cKod

 If empty(cVal)
    lRet := .F.
 ElseIf cGet == cGkd
 ElseIf cGet == 'NAME'
    cKod := _GetValue(cGkd, cWnd)
    cOrd := OrdSetFocus("KOD")
    lSek := (cAls)->( dbSeek(TR0(cKod)) )       
    OrdSetFocus(cOrd)

    If lSek
       Tone(500, 1)
       _SetValue(cGkd, cWnd, GetNewKod())
       _SetFocus(cGkd, cWnd)
       aResult := NIL
    Else
       aResult := { cKod, cVal }
       DoMethod(cWnd, 'Release')
    EndIf
 EndIf

RETURN lRet
