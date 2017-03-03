/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * InputWindowEx function
 * Copyright 2008 Jozef Rudnicki <j_rudnicki@wp.pl>
*/

#include "minigui.ch"
//*********************************************************************************
#define F_LWIDTH  1 // label width
#define F_CTYPE   2 // control type
#define F_CWIDTH  3 // control width
#define F_CHEIGHT 4 // control height
#define F_VALUE   5 // control value ( combobox, textbox numeric, editbox )
#define MAX_F     5

Function InputWindowEx( cTitle , aLabels , aValues , aFormats ,;
                        nRow , nCol, lCenterWindow, aButOKCancelCaptions, bCode )
*********************************************************************************
  local i, imax, nControlRow, cLabel, cControl, xFormat
  local nWidth, nHeight, nWinWidth, nWinHeight, nRowHeight:=28  //30

  memvar aResult
  private aResult:={}

  lCenterWindow := if( nRow = NIL .and. nCol = NIL, .t., .f. )
  default nRow to 0
  default nCol to 0
  default aButOKCancelCaptions to {}

  if Len( aButOKCancelCaptions ) = 0
    if Set ( _SET_LANGUAGE ) == 'ES'
      AAdd( aButOKCancelCaptions, 'Aceptar' )
      AAdd( aButOKCancelCaptions, 'Cancelar' )
    else
      AAdd( aButOKCancelCaptions, '&Ok' )
      AAdd( aButOKCancelCaptions, '&Cancel' )
    endif
  endif

  nWinWidth := 250
  nWinHeight := 0
  imax := Len ( aLabels )
  ASize(aResult,imax)
  FOR i:=1 TO imax
    IF valType ( aFormats[i] ) == 'A' .and. valType(aFormats[i,1])<>'C'
      // InputWindowEx new syntax defaults
      ASize(aFormats[i],MAX_F)
      default aFormats[i,F_LWIDTH]  to  90  // default nLabelWidth
      default aFormats[i,F_CWIDTH]  to 140  // default nControlWidth
      if aFormats[i,F_CHEIGHT]==nil         // default nControlHeight
        aFormats[i,F_CHEIGHT]:=nRowHeight
        if empty(aFormats[i,F_CTYPE])       // label -> empty string or nil
        elseif aFormats[i,F_CTYPE]='EB'
          aFormats[i,F_CHEIGHT]:=3*nRowHeight
        endif
      endif
    ELSE
      // InputWindow syntax convertion
      xFormat:=aFormats[i]
      do case
      case aValues[i] == nil                        // Label only
        aFormats[i]:={90,'',140,nRowHeight}
      case valType ( aValues[i] ) == 'L'
        aFormats[i]:={90,'CH',140,nRowHeight}       // CheckBox
      case valType ( aValues[i] ) == 'D'
        aFormats[i]:={90,'DP',140,nRowHeight}       // DatePicker
      case valType ( aValues[i] ) == 'N'
        if valType ( xFormat ) == 'C'
          aFormats[i]:={90,'TN',140,nRowHeight}     // TextBox Numeric
        elseif valType ( xFormat ) == 'A'
          aFormats[i]:={90,'CB',140,nRowHeight}     // ComboBox
        endif
      case valType ( aValues[i] ) == 'C'
        aFormats[i]:={90,'TX',140,nRowHeight}       // TextBox
        if valType ( xFormat ) == 'N'
          if xFormat > 32
            aFormats[i]:={90,'EB',140,3*nRowHeight} // EditBox
          endif
        endif
      case valType ( aValues[i] ) == 'M'
        aFormats[i]:={90,'EB',140,3*nRowHeight}     // EditBox
      endcase
      ASize(aFormats[i],MAX_F)
      aFormats[i,F_VALUE]:=xFormat
    ENDIF
    nWinWidth:=max( aFormats[i,F_LWIDTH]+aFormats[i,F_CWIDTH], nWinWidth )
    nWinHeight+=aFormats[i,F_CHEIGHT]
  NEXT i

  nWinHeight += 3*nRowHeight  // place for ok/cancel buttons
  nWinWidth  += 30
  if nRow + nWinHeight > GetDeskTopHeight()
    nRow := GetDeskTopHeight() - nWinHeight
  endif

  DEFINE WINDOW _InputWindow ;
      AT nRow, nCol ;
      WIDTH nWinWidth ;
      HEIGHT nWinHeight ;
      TITLE cTitle ;
      MODAL NOSIZE NOSYSMENU

      nControlRow := 10
      FOR i:=1 TO imax
        cLabel   := 'Label_' + alltrim(str(i,2,0))
        cControl := 'Control_' + alltrim(str(i,2,0))

        @ nControlRow + 2, 10 LABEL &cLabel OF _InputWindow ;
                          VALUE aLabels[i] WIDTH aFormats[i,F_LWIDTH]
        DO CASE
        CASE aValues[i] == nil
          IF valType(aFormats[i,F_VALUE])='C'
            if 'BOLD'$aFormats[i,F_VALUE]
              SetProperty('_InputWindow',cLabel,'FONTBOLD',.t.)
            endif
            if 'ITALIC'$aFormats[i,F_VALUE]
              SetProperty('_InputWindow',cLabel,'FONTITALIC',.t.)
            endif
            if 'UNDERLINE'$aFormats[i,F_VALUE]
              SetProperty('_InputWindow',cLabel,'FONTUNDERLINE',.t.)
            endif
            if 'STRIKEOUT'$aFormats[i,F_VALUE]
              SetProperty('_InputWindow',cLabel,'FONTSTRIKEOUT',.t.)
            endif
          ENDIF
          SetProperty('_InputWindow',cLabel,'WIDTH',aFormats[i,F_LWIDTH]+aFormats[i,F_CWIDTH])
        CASE aFormats[i,F_CTYPE] = 'CH'
          @ nControlRow, 10+aFormats[i,F_LWIDTH] CHECKBOX &cControl OF _InputWindow ;
                             CAPTION '' VALUE aValues[i]
        CASE aFormats[i,F_CTYPE] = 'DP'
          @ nControlRow, 10+aFormats[i,F_LWIDTH] DATEPICKER &cControl OF _InputWindow ;
                             VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH]
        CASE aFormats[i,F_CTYPE] = 'CB'
          @ nControlRow, 10+aFormats[i,F_LWIDTH] COMBOBOX &cControl OF _InputWindow ;
                             ITEMS aFormats[i,F_VALUE] ;
                             VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH] ;
                             FONT 'Arial' SIZE 10
        CASE aFormats[i,F_CTYPE] = 'TN'
          if at( '.' , aFormats[i,F_VALUE] ) > 0
            @ nControlRow, 10+aFormats[i,F_LWIDTH] TEXTBOX &cControl OF _InputWindow ;
                               VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH] ;
                               FONT 'Arial' SIZE 10 ;
                               NUMERIC INPUTMASK aFormats[i,F_VALUE]
          else
            @ nControlRow, 10+aFormats[i,F_LWIDTH] TEXTBOX &cControl OF _InputWindow ;
                               VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH] ;
                               FONT 'Arial' SIZE 10 ;
                               MAXLENGTH Len(aFormats[i,F_VALUE]) NUMERIC
          endif
        CASE aFormats[i,F_CTYPE] = 'TX'
          @ nControlRow, 10+aFormats[i,F_LWIDTH] TEXTBOX &cControl OF _InputWindow ;
                             VALUE aValues[i] WIDTH aFormats[i,F_CWIDTH] ;
                             FONT 'Arial' SIZE 10 ;
                             MAXLENGTH aFormats[i,F_VALUE]
        CASE aFormats[i,F_CTYPE] = 'EB'
          if aFormats[i,F_CHEIGHT]>nRowHeight
            SetProperty('_InputWindow',cLabel,'HEIGHT',aFormats[i,F_CHEIGHT])
            @ nControlRow, 10+aFormats[i,F_LWIDTH] EDITBOX &cControl OF _InputWindow ;
                               WIDTH aFormats[i,F_CWIDTH] ;
                               HEIGHT aFormats[i,F_CHEIGHT] ;
                               VALUE aValues[i] ;
                               FONT 'Arial' SIZE 10
          else
            @ nControlRow, 10+aFormats[i,F_LWIDTH] EDITBOX &cControl OF _InputWindow ;
                               WIDTH aFormats[i,F_CWIDTH] ;
                               HEIGHT aFormats[i,F_CHEIGHT] ;
                               VALUE aValues[i] ;
                               FONT 'Arial' SIZE 10 ;
                               MAXLENGTH aFormats[i,F_VALUE]
          endif
        ENDCASE
        nControlRow := nControlRow + aFormats[i,F_CHEIGHT]
      NEXT i
      i:=(nWinHeight-nControlRow-2*nRowHeight)/2
      @ nControlRow+i, nWinWidth - 260 BUTTON BUTTON_1 OF _InputWindow ;
                           CAPTION aButOKCancelCaptions[1] ;
                           ACTION xInputWindowOk()
      @ nControlRow+i, nWinWidth - 130 BUTTON BUTTON_2 OF _InputWindow ;
                           CAPTION aButOKCancelCaptions[2] ;
                           ACTION xInputWindowCancel()
      if valType(bCode)='B'
        Eval(bCode)
      endif
  END WINDOW

  if lCenterWindow
    CENTER WINDOW _InputWindow
  endif
  ACTIVATE WINDOW _InputWindow
  RETURN ( aResult )

static Function xInputWindowOk()
********************************
  Local i , cControlName
  memvar aResult

  for i := 1 to len (aResult)
    cControlName := 'Control_' + Alltrim ( Str ( i , 0 ) )
    if _IsControlDefined(cControlName,'_InputWindow')
      aResult[i] := _GetValue ( cControlName , '_InputWindow' )
    else
      aResult[i] := nil
    endif
  next i
  RELEASE WINDOW _InputWindow
  RETURN NIL

static Function xInputWindowCancel()
************************************
  Local i
  memvar aResult

  for i := 1 to len (aResult)
    aResult[i] := nil
  next i
  RELEASE WINDOW _InputWindow
  RETURN NIL
