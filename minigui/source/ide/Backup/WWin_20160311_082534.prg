#include "minigui.ch"

DECLARE WINDOW WaitWindow

*------------------------------------------------------------------------------*
FUNCTION ShowInfo2( uMessage )
*------------------------------------------------------------------------------*

    LOCAL lHide
    LOCAL nLen
    LOCAL lOldCenterWindowStyle

    lHide := IIf( Upper(ValType(uMessage)) == "L", !uMessage, .F. )
    IF lHide
       IF ISWINDOWDEFINED( WaitWindow )
          WaitWindow.hide
       ENDIF
       RETURN NIL
    ENDIF

    uMessage := IIf(uMessage == NIL, "Processing! Please wait.", HB_ValToStr(uMessage))

    nLen :=  Len(uMessage)*10

    IF !ISWINDOWDEFINED(WaitWindow)
       DEFINE WINDOW WaitWindow At 0, 0 WIDTH nLen + 10 HEIGHT 84 + iif(IsAppXPThemed(),8,0) ;
                     TITLE "Signal!" ;
                     CHILD NOAUTORELEASE NOMINIMIZE NOMAXIMIZE NOSIZE NOSYSMENU

           DEFINE ANIMATEBOX Animate_1
             ROW    05
             COL    05
             WIDTH  40
             HEIGHT 50
             FILE "building.avi"
             AUTOPLAY .T.
             CENTER .T.
             TRANSPARENT .T.
          END ANIMATEBOX

          DEFINE LABEL MessageLabel
             ROW    05
             COL    50
             WIDTH  nLen - 50
             HEIGHT 50
             VALUE uMessage
             FONTNAME "Tahoma"
             FONTSIZE 12
             FONTBOLD .T.
             TRANSPARENT .T.
             FONTCOLOR { 240, 90, 70 }
             CLIENTEDGE .T.
             CENTERALIGN .T.
          END LABEL

       END WINDOW

    ELSE
       WaitWindow.Width := nLen + 10
       WaitWindow.MessageLabel.Width := nLen - 50
       WaitWindow.MessageLabel.Value := uMessage
       WaitWindow.Hide
 
    ENDIF

    lOldCenterWindowStyle := _SetCenterWindowStyle ( .T. )
    CENTER WINDOW WaitWindow
    _SetCenterWindowStyle ( lOldCenterWindowStyle )
    WaitWindow.Show

RETURN NIL
