/*
* MiniGUI Extended - Harbour Win32 GUI library
* (c) MiniGUI Extended Team Grigory Filatov  Janusz Pora  Jacek Kubica
*
* MsgMenu()
* (c) 2005 2006 Carlos Britos  <bcd12a@yahoo.com.ar>
* IGCM tool to compile app with Minigui Extended
* http://www.geocities.com/bcd12a/

2006.08.12
     * New; version 2
       !!! Different sintax !!!
       + Several lines of buttons
       + Buttons have the ButtonEx features:
           . backcolor ,fontcolor, bold
           . bmp at left,rigth or top of caption
           . flat ,...
       + text of message with several lines
       + Now is possible to disable buttons
       + Backcolor in form of msgmenu()
       + Timer to exit
       + Animated Icon

2006.02.12
     ! fixed problems, reported by "Joe Fanucchi" <drjoe@meditrax.com>
         Contributed by Grigory Filatov

2005.11.20
     ! fixed problems, reported by "Mel Smith" <Medsyntel@aol.com>
     ! fixed warning messages (compiling)
     ! fixed xpStyle
     * random formName
*/

// MsgMenu() Return a numeric value of the clicked button
// The last button in the list of buttons and key ESC return value 0, if is defined CAN in cStyle string

// n := MsgMenu(  ,; /*[cMessage    ]*/
//                ,; /* aCaptions    */
//                ,; /* aPictures    */
//                ,; /*[cBitmap     ]*/
//                ,; /*[cTitle      ]*/
//                ,; /*[nFocusBtn   ]*/
//                ,; /*[aToolTips   ]*/
//                ,; /*[cStyle      ]*/
//                ,; /*[aDisableBtns]*/
//                ,; /*[nBtnsPorLine]*/
//                ,; /*[aBackColWin ]*/
//                ,; /*[aBackColBtn ]*/
//                ,; /*[aFontColBtn ]*/
//                ,; /*[nSizeBmpBtn ]*/
//                )  /*[nTimeToExit ]*/

/*
  Remarks
  cMessage     = text of message. ( several lines with chr(13)+chr(10) )
  aCaptions    = array with caption of each button (*1)
  aPictures    = array with bmp or ico of each button (files or compiled in .RC) (*1)
  cBitmap      = file .bmp .gif .ani to use at the left of the message. Max size = 45x45 (*6)
  cTitle       = text in the title bar
  nFocusBtn    = number of the focused button (by default = 1)
  aToolTips    = array with tooltips  (by default = no tooltip) (*2)
  cStyle       = string to define the Style of the Msgmenu. (*3)
                 Number = size of buttons (*4)
                 AST ERR ESC ASK = different sounds. If not defined by default is PlayBeep()
                 CAN or Cancel = The last button in the list of buttons and key ESC return value 0
                 LEF or LEFT = bmp in button is at left position (by default is on the top)
                 TEX or LEFTTEXT = Text in button is at left position of bmp (by default is on the right)
                 FLA or FLAT = Flat buttons.
                 BOL or BOLD = FontBold in buttons.
                 ICO or ICON = Image in buttons are icons. (*7)
  aDisableBtns = numeric array. The number (position in array) of the buttons to be disabled
  nBtnsPorLine = number of buttons in one horizontal line. By default is all in one line, 1 = Vertical (*5)
  aBackColWin  = Backcolor of window
  aBackColBtn  = Backcolor of buttons
  aFontColBtn  = color text of buttons
  nSizeBmpBtn  = size of bmp in buttons, by default is 25
  nTimeToExit  = number of seconds to return de value of focused button

  (*1) aCaptions aPictures , Both are optional, but one of these must be defined; or both
  (*2) The length of arrays aCaptions, aPictures and aToolTips must be the same for all or nil
  (*3) is not case sensitive , the first 3 letters is enough.
  (*4) You can set the minimum width and heigth of buttons. It should be first in the cStyle list (ex: "50 ask.." and not "ask 50..")
  (*5) Value must be between 1 and the length of aCaptions or aPictures
  (*6) bmp or gif can be compiled in .RC but .ani must be a file
  (*7) Image in buttons could be Bmp or Ico, by default are Bmp. With 'ICO' only use files.ico ; Don't mix.
*/

#include "minigui.ch"

FUNCTION MsgMenu( cMensaje , aCaptions , aPictures , cBitmap , cTitulo , nFocusBtn , aToolTips , cStyle , aEnabled , nBtnsPorLinea , aBackColWin , aBackColBtn , aFontColBtn , nSizeBmpBtn , nTimeExit )
    LOCAL cClickedBut := "" ,cBtnFocus := "" , cBtnEnabled := "" , cBtnName := "", cFontEnUso := ""
    LOCAL lNoToolTips := .F., lBtnEscape := .F., lVirtualHeight := .F., lBmpOnTop := .T., lLeftText := .F., lFlat := .F., lBold := .F., lIconos := .F.
    LOCAL aNombreBtns := {}
    LOCAL Form_MenuOp := 'Frm_' + LTRIM( STR( Random ( 9999 ) ,4 ,0 ))
    LOCAL nWidthBtn := 25 , nHeigthBtn := 25 , nCentrador := 0 , nButtons := 0 , nWinHeight := 0 , nSizeIcon := 0 , nWinWidth := 0
    LOCAL x := 0 , i := 0 , nX := -1 , nZ := 0 , nY := 0 , xz := 1 , nParamCap := 1 , nParamPic := 1 , nEnters := 1 , nFontSizeEnUso := 0 , nFontHandle := 0
    LOCAL nInterSpace := 8 , nRetVal := 0 , nLenMensaje := 0 , nVHeight := 0 , nHeightTitleBar := 0 , nLineasBtns := 1 , nHeigthMessages := 0

    DEFAULT cStyle TO ''
    DEFAULT aBackColWin TO NIL
    DEFAULT aBackColBtn TO NIL
    DEFAULT aFontColBtn TO NIL
    DEFAULT nSizeBmpBtn TO 25

    cStyle               := UPPER( cStyle )
    lBtnEscape           := 'CAN' $ cStyle
    nWidthBtn            := MAX( VAL( cStyle ) , nWidthBtn )
    // font name size
    cFontEnUso           := _HMG_DefaultFontName
    nFontSizeEnUso       := _HMG_DefaultFontSize
    _HMG_DefaultFontName := IF( IsXpThemeActive() , "Tahoma" , "MS Sans serif" )
    _HMG_DefaultFontSize := 9
    nFontHandle          := InitFont ( _HMG_DefaultFontName, 9, .F., .F., .F., .F. )

    // Bmp at top, rigth or left
    IF 'LEF' $ cStyle
       lBmpOnTop := .F.
       IF 'TEX' $ cStyle
          lLeftText := .T.
       ENDIF
    ENDIF

    // sound
    IF 'AST' $ cStyle
       PlayAsterisk()
    ELSEIF 'ERR' $ cStyle
       PlayHand()
    ELSEIF 'EXC' $ cStyle
       PlayExclamation()
    ELSEIF 'ASK' $ cStyle
       PlayQuestion()
    ELSE
       PlayBeep()
    ENDIF

    IF 'FLA' $ cStyle
       lFlat := .T.
    ENDIF
    IF 'BOL' $ cStyle
       lBold := .T.
    ENDIF
    IF 'ICO' $ cStyle
       lIconos := .T.
    ENDIF

    nHeightTitleBar := GetTitleHeight()
    // number of buttons
    nButtons        := MAX( IF( VALTYPE( aCaptions ) # 'U' , LEN( aCaptions ) , 0 ) , IF( VALTYPE( aPictures ) # 'U' , LEN( aPictures ) , 0 ) )
    aNombreBtns     := array( nButtons )

    // number of buttons per line
    IF VALTYPE( nBtnsPorLinea ) == 'U'
        nBtnsPorLinea := nButtons
    ENDIF
    nLineasBtns := nButtons / nBtnsPorLinea
    IF ( nButtons / nBtnsPorLinea # int( nButtons / nBtnsPorLinea ) )
        nLineasBtns += 1
    ENDIF

    // captions and pictures
    IF empty( aCaptions )
       aCaptions := array( nButtons )
       nParamCap := 0
    ENDIF
    IF empty( aPictures )
       aPictures := array( nButtons )
       nParamPic := 0
    ENDIF
    IF empty( aToolTips )
       aToolTips := array( nButtons )
    ENDIF

    // size of buttons
    nHeigthBtn  := MAX( VAL( cStyle ) , 25 )
    nHeigthBtn  := MAX( nSizeBmpBtn , nHeigthBtn )
    nWidthBtn   := MAX( nSizeBmpBtn , nWidthBtn )

    // internal name of buttons
    FOR i := 1 to nButtons
       aNombreBtns[i] := '_Msg_Btn' + LTRIM( STR( i ))

       // width of captions
       IF VALTYPE( aCaptions[i] ) # "U"
          nWidthBtn := MAX( nWidthBtn , GetTextWidth( NIL , aCaptions[i] , nFontHandle ) +8 )
       ENDIF

    NEXT
    // button focused
    nFocusBtn := IF( VALTYPE( nFocusBtn ) == 'U' , 1 , nFocusBtn )

    // resize heigth, add captions
    IF ( nParamCap * nParamPic # 0 )
       nHeigthBtn += 30
    ENDIF

    // gif or bmp at the left of message
    nSizeIcon := IF( VALTYPE( cBitmap  ) # 'U' , 50 , 0 )

    // length of message
    IF VALTYPE( cMensaje ) # 'U'
         // if the message has several lines
        nEnters := MlCount( cMensaje , 200 )
        nHeigthMessages := ( nEnters * 13 )
        // length of each line
        FOR xz := 1 TO nEnters
            nLenMensaje := MAX( GetTextWidth( NIL, ALLTRIM(MemoLine( cMensaje , 200 , xz )) , nFontHandle ) , nLenMensaje )
        NEXT
        nLenMensaje += 6
        nHeigthMessages := MAX( nSizeIcon , nHeigthMessages )
        if nSizeIcon > 0 .AND. nEnters == 1
            cMensaje := CHR(13)+CHR(10) + cMensaje
            nEnters := 2
        endif
    ELSE
        nLenMensaje := 0
        nHeigthMessages := IF( nSizeIcon == 0 , 20 , MAX( nSizeIcon , 20 ) )
    ENDIF

    // minimun width ( message + gif )
    nWinWidth   := nSizeIcon + nInterSpace + nLenMensaje

    // width and heigth of form
    nWinWidth   := MAX( nWinWidth ,  ( nWidthBtn + nInterSpace ) * nBtnsPorLinea ) + 20
    IF ! lBmpOnTop
        nWinWidth   += nBtnsPorLinea * nSizeBmpBtn
        nWidthBtn   += nSizeBmpBtn
        nHeigthBtn  := nSizeBmpBtn
    ENDIF
    nWinHeight := nHeightTitleBar + nHeigthMessages + ( nLineasBtns * ( nHeigthBtn + nInterSpace ) ) + 20
    nCentrador := ( nWinWidth - (( nWidthBtn + nInterSpace ) * nBtnsPorLinea ) ) / 2

    // scroll form when there are lot of butons
    IF nWinHeight > ( GetDesktopHeight() - 50 )
       nVHeight       := nWinHeight + 30
       nWinHeight     := ( GetDesktopHeight() - 50 )
       lVirtualHeight := .T.
       // add scrollbar width
       nWinWidth      += 16
    ELSE
       nVHeight       := NIL
       lVirtualHeight := .F.
    ENDIF

    DEFINE WINDOW &Form_MenuOp ;
       AT 0 , 0 ;
       WIDTH nWinWidth ;
       HEIGHT ( nWinHeight + IF( IsXPThemeActive(), 6, 0) ) ;
       VIRTUAL HEIGHT nVHeight ;
       TITLE cTitulo ;
       MODAL ;
       BACKCOLOR aBackColWin ;
       NOSIZE ;
       NOSYSMENU

       IF VALTYPE( cBitmap ) # 'U'
          IF UPPER( Right( cBitmap , 4 )) == '.ANI'
             AnimateIcon( Form_MenuOp, cBitmap )
          ELSE
             @ 10 , 10 ;
             IMAGE   _Msg_Img ;
             OF      Form_MenuOp ;
             PICTURE cBitmap ;
;//             WIDTH   nSizeIcon - 5 ;
;//             HEIGHT  nSizeIcon - 5 ;
             ADJUSTIMAGE TRANSPARENT
          ENDIF
       ENDIF

       IF nLenMensaje # 0
          @ IF( nHeigthMessages # 20 , 5 , ( nHeigthMessages / 2 ) - 9 ) , nSizeIcon ;
          LABEL      _Msg_Lbl ;
          OF         Form_MenuOp ;
          VALUE      cMensaje ;
          WIDTH      nWinWidth - IF( lVirtualHeight , 16 , 0 ) - nSizeIcon - 10 ;
          HEIGHT     nHeigthMessages ;
          TRANSPARENT ;
          CENTERALIGN

           _SetControlHeight ( '_Msg_Lbl' , Form_MenuOp , ( nEnters * 13 ) + 5  )
       ENDIF

       nHeigthMessages += if( nHeigthMessages # 20 , 10 , 0 )

       FOR i := 1 TO nButtons
          nX += 1
          IF nX == nBtnsPorLinea
             nX := 0
             nZ += 1
             nY := 0
          ENDIF

          cBtnName := aNombreBtns[i]

          DEFINE BUTTONEX &cBtnName
                PARENT     Form_MenuOp
                ROW        nHeigthMessages + ( nZ * ( nHeigthBtn + nInterSpace ))
                COL        nCentrador + ( nY * ( nWidthBtn  + nInterSpace ))
                WIDTH      nWidthBtn
                HEIGHT     nHeigthBtn
                ACTION     ( cClickedBut := This.Name , ThisWindow.release )
                if lIconos
                   ICON    aPictures[i]
                else
                   PICTURE aPictures[i]
                endif
                CAPTION    aCaptions[i]
                FLAT       lFlat
                LEFTTEXT   lLeftText
                FONTCOLOR  aFontColBtn
                FONTBOLD   lBold
                BACKCOLOR  aBackColBtn
                NOXPSTYLE  (aBackColBtn != NIL)
                VERTICAL   lBmpOnTop
                TOOLTIP    aToolTips[i]
          END BUTTONEX

          nY += 1
       NEXT

       // timer (if defined) return the focused button
       IF VALTYPE( nTimeExit ) == 'N'
          _DefineTimer ( "_Msg_Timer", Form_MenuOp, nTimeExit * 1000 , {||IF( _IsWindowActive( Form_MenuOp ),( cClickedBut := GetProperty( Form_MenuOp, "FocusedControl" ) , ThisWindow.release ) ,)} )
       ENDIF

       IF lBtnEscape
          ON KEY ESCAPE ACTION IF( _IsWindowActive( Form_MenuOp ),( cClickedBut := 'dummy' , ThisWindow.release ) ,)
       ENDIF

    END WINDOW
    CENTER WINDOW &Form_MenuOp
    cBtnFocus := '_Msg_Btn' + LTRIM( STR( nFocusBtn ) )
    DoMethod(Form_MenuOp,cBtnFocus,'SetFocus')

    IF VALTYPE( aEnabled ) # 'U'
       FOR xz := 1 TO LEN( aEnabled )
          cBtnEnabled := '_Msg_Btn' + LTRIM( STR( aEnabled [xz] ) )
          SetProperty(Form_MenuOp,cBtnEnabled,'enabled',.F.)
       NEXT
    ENDIF

    ACTIVATE WINDOW &Form_MenuOp

    IF GetObjectType( nFontHandle ) == OBJ_FONT
       DeleteObject( nFontHandle )
    ENDIF

    nRetVal := ASCAN( aNombreBtns , @cClickedBut )
    IF lBtnEscape .AND. nButtons == nRetVal
       nRetVal := 0
    ENDIF
    // restore font size
    _HMG_DefaultFontName := cFontEnUso
    _HMG_DefaultFontSize := nFontSizeEnUso

RETURN nRetVal


FUNCTION AnimateIcon( FormName, cValue, x, y, w, h )
LOCAL nFormHandle := 0

   DEFAULT x       TO 10
   DEFAULT y       TO 10
   DEFAULT w       TO 32
   DEFAULT h       TO 32

   IF _IsWindowDefined( FormName )
      nFormHandle := GetFormHandle( FormName )
      IconAnimate( nFormHandle, cValue, x, y, w, h )
   ENDIF

RETURN NIL


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

HB_FUNC (ICONANIMATE)
{
    HWND  h;
    HBITMAP hBitmap;
    HWND hwnd;
    int Style;
    hwnd = (HWND) hb_parnl (1);
    Style = WS_CHILD | WS_VISIBLE | SS_ICON | WS_TABSTOP;

    h = CreateWindowEx(0,"static",NULL,Style,
        hb_parni(4),
        hb_parni(3),
        hb_parni(5),
        hb_parni(6),
        hwnd,(HMENU)hb_parni(2) , GetModuleHandle(NULL) , NULL ) ;
    hBitmap = (HBITMAP)LoadImage(0,hb_parc(2),IMAGE_ICON,hb_parni(5), hb_parni(6),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
    SendMessage(h,(UINT)STM_SETIMAGE,(WPARAM)IMAGE_ICON,(LPARAM)hBitmap);
    SendMessage(h,100,(WPARAM)STM_SETIMAGE,(LPARAM)IMAGE_ICON);
    hb_retnl( (LONG) hBitmap );
}

#pragma ENDDUMP
