/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample

  Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  CSBox ( Combined Search Box )

  Started by Bicahi Esgici <esgici@gmail.com>

  Enhanced by S.Rathinagiri <srgiri@dataone.in>

  Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

PROC _DefineComboSearchBox( cCSBoxName,; 
                            cCSBoxParent,; 
                            cCSBoxCol,; 
                            cCSBoxRow,; 
                            cCSBoxWidth,; 
                            cCSBoxHeight,; 
                            cCSBoxValue,;
                            cFontName,; 
                            nFontSize,; 
                            cToolTip,; 
                            nMaxLenght,;
                            lUpper,; 
                            lLower,; 
                            lNumeric,;
                            bLostFocus,; 
                            bGotFocus,; 
                            bEnter,;
                            lRightAlign,; 
                            nHelpId,; 
                            lBold,; 
                            lItalic,; 
                            lUnderline,; 
                            aBackColor,; 
                            aFontColor,; 
                            lNoTabStop,; 
                            aArray )

   LOCAL cParentName := ''

   DEFAULT cCSBoxWidth  := 120
   DEFAULT cCSBoxHeight := 24
   DEFAULT cCSBoxValue  := ""
   DEFAULT bGotFocus    := ""
   DEFAULT bLostFocus   := ""
   DEFAULT nMaxLenght   := 255
   DEFAULT lUpper       := .F.
   DEFAULT lLower       := .F.
   DEFAULT lNumeric     := .F.
   DEFAULT bEnter       := ""

   IF _HMG_BeginWindowActive = .T.
      cParentName := _HMG_ActiveFormName
   ELSE
      cParentName := cCSBoxParent
   ENDIF

   DEFINE TEXTBOX &cCSBoxName
      PARENT        &cCSBoxParent
      ROW           cCSBoxRow
      COL           cCSBoxCol
      WIDTH         cCSBoxWidth
      HEIGHT        cCSBoxHeight
      VALUE         cCSBoxValue
      FONTNAME      cFontName
      FONTSIZE      nFontSize
      TOOLTIP       cToolTip
      MAXLENGTH     nMaxLenght
      UPPERCASE     lUpper
      LOWERCASE     lLower
      NUMERIC       lNumeric
      ONLOSTFOCUS   iif( ISBLOCK(bLostFocus), Eval(bLostFocus), NIL )
      ONGOTFOCUS    iif( ISBLOCK(bGotFocus), Eval(bGotFocus), NIL )
      ONENTER       iif( ISBLOCK(bEnter), Eval(bEnter), NIL )
      ONCHANGE      CreateCSBox( cParentName, cCSBoxName, aArray, cCSBoxRow, cCSBoxCol )
      RIGHTALIGN    lRightAlign
      HELPID        nHelpId
      FONTBOLD      lBold
      FONTITALIC    lItalic
      FONTUNDERLINE lUnderline
      BACKCOLOR     aBackColor
      FONTCOLOR     aFontColor
      TABSTOP       lNoTabStop
   END TEXTBOX

RETURN // _DefineComboSearchBox()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

STATIC PROC CreateCSBox( cParentName, cCSBoxName, aitems ) 

   LOCAL nFormRow       := thisWindow.row
   LOCAL nFormCol       := thisWindow.col
   LOCAL nControlRow    := this.row + 1
   LOCAL nControlCol    := this.col + 1
   LOCAL nControlWidth  := this.width
   LOCAL nControlHeight := this.height
   LOCAL cCurValue      := this.value
   LOCAL cFontname      := this.fontname
   LOCAL nFontsize      := this.Fontsize
   LOCAL cTooltip       := this.tooltip
   LOCAL lFontbold      := this.fontbold
   LOCAL lFontitalic    := this.fontitalic
   LOCAL lFontunderline := this.fontunderline
   LOCAL aBackcolor     := this.backcolor
   LOCAL aFontcolor     := this.fontcolor
   LOCAL aResults       := {}
   LOCAL nContIndx      := GetControlIndex( this.name, thiswindow.name )   
   LOCAL result         := 0
   LOCAL nItemNo        := 0
   LOCAL nListBoxHeight := 0
   LOCAL nCaret          := this.CaretPos

   LOCAL cCSBxName := 'frm' + cCSBoxName

   IF !EMPTY( cCurValue )

      IF _HMG_aControlContainerRow [nContIndx] # -1
         ncontrolrow += _HMG_aControlContainerRow [nContIndx]
         ncontrolcol += _HMG_aControlContainerCol [nContIndx]
      ENDIF   

      FOR nItemNo := 1 TO LEN( aitems )
         IF UPPER( aitems[ nItemNo ] ) == UPPER( cCurValue )
            EXIT // item selected already
         ENDIF
         IF UPPER( LEFT( aitems[ nItemNo ], LEN( cCurValue ) ) ) == UPPER( cCurValue )
            AADD( aResults, aitems[ nItemNo ] )
         ENDIF
      NEXT nItemNo

      IF LEN( aResults ) > 0

         nListBoxHeight := MAX(MIN((LEN(aResults) * 16)+6,thiswindow.height - nControlRow - nControlHeight - 14),40)
         
         DEFINE WINDOW &cCSBxName ;
            AT     nFormRow+nControlRow+GetTitleHeight(), nFormCol+nControlCol ;
            WIDTH  nControlWidth+GetBorderWidth() ;
            HEIGHT nListBoxHeight+nControlHeight+GetBorderHeight() ;
            TITLE '' ;
            MODAL ;
            NOCAPTION ;
            NOSIZE 
         
            ON KEY UP     ACTION _CSDoUpKey()  
            ON KEY DOWN   ACTION _CSDoDownKey()
            ON KEY ESCAPE ACTION _CSDoEscKey( cParentName, cCSBoxName ) 
            
            DEFINE TEXTBOX _cstext
               ROW           3
               COL           3
               WIDTH         nControlWidth
               HEIGHT        nControlHeight
               FONTNAME      cFontname
               FONTSIZE      nFontsize
               TOOLTIP       cTooltip
               FONTBOLD      lFontbold
               FONTITALIC    lFontitalic
               FONTUNDERLINE lFontunderline
               BACKCOLOR     aBackcolor
               FONTCOLOR     aFontcolor
               ON CHANGE     _CSTextChanged( cParentName, aitems )
               ON ENTER      _CSItemSelected( cParentName, cCSBoxName )
            END TEXTBOX
            
            DEFINE LISTBOX _cslist
               ROW         nControlHeight+3
               COL         3
               WIDTH       nControlWidth
               HEIGHT      nListBoxHeight-GetBorderHeight()
               ITEMS       aResults
               ON DBLCLICK _CSItemSelected( cParentName, cCSBoxName )
               VALUE       1    
            END LISTBOX
            
         END WINDOW

         SetProperty( cCSBxName, '_cstext', "VALUE", cCurValue )
         SetProperty( cCSBxName, '_cstext', "CaretPos", nCaret )

         ACTIVATE WINDOW &cCSBxName

      ENDIF

   ENDIF   

RETURN // CreateCSBox()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
   
STATIC PROC _CSTextChanged( cParentName, aItems )

   LOCAL cCurValue      := GetProperty( ThisWindow.Name, '_cstext', "VALUE" ) 
   LOCAL aResults       := {}
   LOCAL nItemNo        := 0
   LOCAL nListBoxHeight := 0
   LOCAL nParentHeight  := GetProperty( cParentName, "HEIGHT" )
   LOCAL nParentRow     := GetProperty( cParentName, "ROW" )

   DoMethod( ThisWindow.Name, "_csList", 'DeleteAllItems' ) 

   FOR nItemNo := 1 TO LEN( aitems )
      IF UPPER( LEFT( aitems[ nItemNo ], LEN( cCurValue ) ) ) == UPPER( cCurValue )
         AADD( aResults, aitems[ nItemNo ] )
      ENDIF
   NEXT nItemNo
   
   IF LEN(aResults) > 0
      FOR nItemNo := 1 TO LEN( aResults )
         DoMethod( ThisWindow.Name, "_csList", 'AddItem', aResults[ nItemNo ] ) 
      NEXT i
      SetProperty( ThisWindow.Name, "_csList", "VALUE", 1 ) 
   ENDIF

   nListBoxHeight := MAX(MIN((LEN(aResults) * 16)+6,(nParentHeight + nParentRow - ;
                    GetProperty( ThisWindow.Name, 'ROW' ) -  ;
                    GetProperty( ThisWindow.Name, "_csText", 'ROW' ) -  ;
                    GetProperty( ThisWindow.Name, "_csText", 'HEIGHT' ) -  14)), 40) 

   SetProperty( ThisWindow.Name, "_csList", "HEIGHT", nListBoxHeight - GetBorderHeight() ) 
   SetProperty( ThisWindow.Name, "HEIGHT", nListBoxHeight + GetProperty( ThisWindow.Name, '_cstext', "HEIGHT" ) ) 

RETURN // _CSTextChanged()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

STATIC PROC _CSItemSelected( cParentName, cTxBName )

   LOCAL nListValue
   LOCAL cListItem

   IF GetProperty( ThisWindow.Name, "_csList", "VALUE" ) > 0 

      nListValue := GetProperty( ThisWindow.Name, '_csList', "VALUE" )
      cListItem  := GetProperty( ThisWindow.Name, '_csList', "ITEM", nListValue )

      SetProperty( cParentName, cTxBName, "VALUE", cListItem )

      SetProperty( cParentName, cTxBName, "CARETPOS", ;
                    LEN( GetProperty( ThisWindow.Name, '_csList', "ITEM", ;
                         GetProperty( ThisWindow.Name, '_csList', "VALUE" ) ) ) )

      DoMethod( ThisWindow.Name, "Release" ) 

   ENDIF  
          
RETURN // _CSItemSelected()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

STATIC PROC _CSDoUpKey()

   IF GetProperty( ThisWindow.Name, '_csList', "ItemCount" ) > 0 .AND. ;
      GetProperty( ThisWindow.Name, '_csList', "VALUE" ) > 1

      SetProperty( ThisWindow.Name, '_csList', "VALUE", GetProperty( ThisWindow.Name, '_csList', "VALUE" ) - 1 )

   ENDIF
   
RETURN // _CSDoUpKey()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

STATIC PROC _CSDoDownKey()

   IF GetProperty( ThisWindow.Name, '_csList', "ItemCount" ) > 0 .AND. ;
      GetProperty( ThisWindow.Name, '_csList', "VALUE" )     < ;
      GetProperty( ThisWindow.Name, '_csList', "ItemCount" )

      SetProperty( ThisWindow.Name, '_csList', "VALUE", GetProperty( ThisWindow.Name, '_csList', "VALUE" ) + 1 ) 

   ENDIF

RETURN // _CSDoDownKey()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

STATIC PROC _CSDoEscKey( cParentName, cCSBoxName )

   SetProperty( cParentName, cCSBoxName, "VALUE", '' )

   DoMethod( ThisWindow.Name, "Release" ) 

RETURN // _CSDoEscKey()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
