/*
  SumatraPDF ver. 3.1.2
  https://www.sumatrapdfreader.org
*/


#include "hmg.ch"


/*
  Sumatra_PanelCreate(cParentFormName, cPanelName, [nRow], [nCol], [nWidth], [nHeight], [cPdfFile], [nPage], [lBookmarks], [lToolbar], [cLanguage], [cSumatraPDFExe])
  -->  0 - if no error
  --> -1 - if cPdfFile is specified and SumatraPDF executable file not found
  --> -2 - if cPdfFile is specified and it does not exist
*/
FUNCTION Sumatra_PanelCreate(cForm, cPanel, nRow, nCol, nWidth, nHeight, cPdfFile, nPage, lBookmarks, lToolbar, cLang, cExeFile)
  LOCAL nHFrame

  IF (! HB_IsChar(cExeFile)) .or. Empty(cExeFile)
    cExeFile := "SumatraPDF.exe"
  ENDIF

  IF (! HB_IsChar(cPdfFile)) .or. (File(cPdfFile) .and. File(cExeFile))
    IF Sumatra_FrameHandle(cPanel) != 0
      IF (! HB_IsNumeric(nRow))
        nRow := GetProperty(cPanel, "ROW")
      ENDIF
      IF (! HB_IsNumeric(nCol))
        nCol := GetProperty(cPanel, "COL")
      ENDIF
      IF (! HB_IsNumeric(nWidth))
        nWidth := GetProperty(cPanel, "WIDTH")
      ENDIF
      IF (! HB_IsNumeric(nHeight))
        nHeight := GetProperty(cPanel, "HEIGHT")
      ENDIF

      Sumatra_PanelClose(cPanel)
    ENDIF
  ENDIF

  IF (! _IsWindowDefined(cPanel))
    IF (! HB_IsNumeric(nRow))
      nRow := 0
    ENDIF
    IF (! HB_IsNumeric(nCol))
      nCol := 0
    ENDIF
    IF (! HB_IsNumeric(nWidth))
      nWidth := 100
    ENDIF
    IF (! HB_IsNumeric(nHeight))
      nHeight := 100
    ENDIF

    DEFINE WINDOW &cPanel;
      ROW    nRow;
      COL    nCol;
      WIDTH  nWidth;
      HEIGHT nHeight;
      PARENT &cForm;
      PANEL;
      ON PAINT Sumatra_PanelRedraw(cPanel)
    END WINDOW

    DoMethod(cPanel, "SHOW")
  ENDIF

  IF HB_IsChar(cPdfFile)
    IF File(cPdfFile)
      IF File(cExeFile)
        IF (! HB_IsNumeric(nPage)) .or. (nPage < 1)
          nPage := 1
        ENDIF
        IF (! HB_IsChar(cLang)) .or. Empty(cLang)
          cLang := "en"
        ENDIF

      	EXECUTE FILE '"' + cExeFile + '"' PARAMETERS '-page ' + HB_NtoS(nPage) + ' -lang ' + cLang + ' -plugin ' + HB_NtoS(GetProperty(cPanel, 'HANDLE')) + ' "' + cPdfFile + '"'

        DO WHILE (nHFrame := Sumatra_FrameHandle(cPanel)) == 0
          HB_IdleSleep(0.01)
        ENDDO

        HB_IdleSleep(0.03)
        Sumatra_Toolbar(cPanel, lToolbar)
        SendMessage(nHFrame, 273 /*WM_COMMAND*/, 417 /*IDM_VIEW_BOOKMARKS*/, 0)
        Sumatra_Bookmarks(cPanel, lBookmarks)
        SetProperty(cPanel, "TITLE", cPdfFile)
      ELSE
        RETURN -1
      ENDIF
    ELSE
      RETURN -2
    ENDIF
  ENDIF

RETURN 0


FUNCTION Sumatra_PanelClose(cPanel)

  IF _IsWindowDefined(cPanel)
    SendMessage(GetFormHandle(cPanel), 16 /*WM_CLOSE*/, 0, 0)
  ENDIF

RETURN NIL


       //Sumatra_PanelSize(cPanel, [nRow], [nCol], [nWidth], [nHeight])
FUNCTION Sumatra_PanelSize(cPanel, nRow, nCol, nWidth, nHeight)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)

  IF _IsWindowDefined(cPanel)
    IF HB_IsNumeric(nRow)
      nRow := ClientToScreenRow(GetParent(GetFormHandle(cPanel)), nRow)
      SetProperty(cPanel, "ROW", nRow)
    ENDIF
    IF HB_IsNumeric(nCol)
      nCol := ClientToScreenCol(GetParent(GetFormHandle(cPanel)), nCol)
      SetProperty(cPanel, "COL", nCol)
    ENDIF
    IF HB_IsNumeric(nWidth)
      nWidth -= GetBorderWidth()
      SetProperty(cPanel, "WIDTH", nWidth)
    ENDIF
    IF HB_IsNumeric(nHeight)
      SetProperty(cPanel, "HEIGHT", nHeight)
    ENDIF

    IF nHFrame != 0
      SetWindowPos(nHFrame, 0, 0, 0, GetProperty(cPanel, "CLIENTAREAWIDTH"), GetProperty(cPanel, "CLIENTAREAHEIGHT"), 0x0016 /*SWP_NOACTIVATE|SWP_NOZORDER|SWP_NOMOVE*/)
      RedrawWindow(nHFrame)
    ENDIF
  ENDIF

RETURN NIL


FUNCTION Sumatra_PanelRedraw(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    RedrawWindow(nHFrame)
  ENDIF

RETURN NIL


       //Sumatra_FrameHandle(cPanel) --> handle to Sumatra frame embeded in panel or 0 if no frame
FUNCTION Sumatra_FrameHandle(cPanel)

  IF _IsWindowDefined(cPanel)
    RETURN FindWindowEx(GetFormHandle(cPanel), 0, "SUMATRA_PDF_FRAME", 0)
  ENDIF

RETURN 0


       //Sumatra_BookmarksHandle(cPanel) --> handle to Sumatra bookmarks tree
FUNCTION Sumatra_BookmarksHandle(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL aHWnd
  LOCAL n

  IF nHFrame != 0
    aHWnd := EnumChildWindows(nHFrame)

    FOR n := 1 TO Len(aHWnd)
      IF GetClassName(aHWnd[n]) == "SysTreeView32" .and. GetWindowText2(aHWnd[n]) == "TOC"
        RETURN aHWnd[n]
      ENDIF
    NEXT
  ENDIF

RETURN 0


FUNCTION Sumatra_BookmarksExist(cPanel)
  LOCAL lExist := .F.
  LOCAL nHBook := Sumatra_BookmarksHandle(cPanel)

  IF nHBook != 0
    lExist := (SendMessage(nHBook, 4357 /*TVM_GETCOUNT*/, 0, 0) != 0)
  ENDIF

RETURN lExist


       //Sumatra_Bookmarks(cPanel, [lShow]) - show/hide Sumatra bookmarks
       //--> previous setting
FUNCTION Sumatra_Bookmarks(cPanel, lShow)
  LOCAL lVisible := .F.
  LOCAL nHFrame  := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    lVisible := IsWindowVisible(Sumatra_BookmarksHandle(cPanel))

    IF HB_IsLogical(lShow)
      IF (lShow != lVisible) .and. Sumatra_BookmarksExist(cPanel)
        SendMessage(nHFrame, 273 /*WM_COMMAND*/, 417 /*IDM_VIEW_BOOKMARKS*/, 0)
      ENDIF
    ENDIF
  ENDIF

RETURN lVisible


       //Sumatra_Toolbar(cPanel, [lShow]) - show/hide Sumatra toolbar
       //--> previous setting
FUNCTION Sumatra_Toolbar(cPanel, lShow)
  LOCAL lVisible := .F.
  LOCAL nHFrame  := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    lVisible := IsWindowVisible(FindWindowEx(nHFrame, 0, "ReBarWindow32", 0))

    IF HB_IsLogical(lShow)
      IF lShow != lVisible
        SendMessage(nHFrame, 273 /*WM_COMMAND*/, 419 /*IDM_VIEW_SHOW_HIDE_TOOLBAR*/, 0)
      ENDIF
    ENDIF
  ENDIF

RETURN lVisible


       //Sumatra_FileName(cPanel) --> name of opened PDF file or empty string
FUNCTION Sumatra_FileName(cPanel)

  IF _IsWindowDefined(cPanel)
    RETURN GetProperty(cPanel, "TITLE")
  ENDIF

RETURN ""


FUNCTION Sumatra_FileSaveAs(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    PostMessage(nHFrame, 273 /*WM_COMMAND*/, 402 /*IDM_SAVEAS*/, 0)
  ENDIF

RETURN NIL


FUNCTION Sumatra_FilePrint(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    PostMessage(nHFrame, 273 /*WM_COMMAND*/, 403 /*IDM_PRINT*/, 0)
  ENDIF

RETURN NIL


FUNCTION Sumatra_FileProperties(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    PostMessage(nHFrame, 273 /*WM_COMMAND*/, 409 /*IDM_PROPERTIES*/, 0)
  ENDIF

RETURN NIL


/*
  nAction:
  -1 - go to previous page
   1 - go to next page
  -2 - go to first page
   2 - go to last page
  otherwise - "Go to" dialog
*/
FUNCTION Sumatra_PageGoTo(cPanel, nAction)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL nWParam

  IF nHFrame != 0
    IF (! HB_IsNumeric(nAction))
      nAction := 0
    ENDIF

    SWITCH nAction
      CASE -1;   nWParam := 431 /*IDM_GOTO_PREV_PAGE*/;  EXIT
      CASE  1;   nWParam := 430 /*IDM_GOTO_NEXT_PAGE*/;  EXIT
      CASE -2;   nWParam := 432 /*IDM_GOTO_FIRST_PAGE*/; EXIT
      CASE  2;   nWParam := 433 /*IDM_GOTO_LAST_PAGE*/;  EXIT
      OTHERWISE; nWParam := 434 /*IDM_GOTO_PAGE*/
    ENDSWITCH

    PostMessage(nHFrame, 273 /*WM_COMMAND*/, nWParam, 0)
  ENDIF

RETURN NIL


/*
  Get current PDF page number
  Returns 0 if error loading occurs
*/
FUNCTION Sumatra_PageNumber(cPanel)
  LOCAL nPage   := 0
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL nHReBar
  LOCAL aHWnd
  LOCAL n

  IF nHFrame != 0
    nHReBar := FindWindowEx(nHFrame, 0, "ReBarWindow32", 0)

    IF nHReBar != 0
      aHWnd := EnumChildWindows(nHReBar)

      FOR n := 1 TO Len(aHWnd)
        IF (GetClassName(aHWnd[n]) == "Edit") .and. (HB_BitAnd(GetWindowLongPtr(aHWnd[n], -16 /*GWL_STYLE*/), 0x2002 /*ES_NUMBER|ES_RIGHT*/) != 0)
          nPage := Val(GetWindowText2(aHWnd[n]))
          EXIT
        ENDIF
      NEXT

    ENDIF
  ENDIF

RETURN nPage


/*
  Get page count in opened PDF
  Returns 0 if error loading occurs
*/
FUNCTION Sumatra_PageCount(cPanel)
  LOCAL nCount  := 0
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL nHReBar
  LOCAL aHWnd
  LOCAL cText
  LOCAL n

  IF nHFrame != 0
    nHReBar := FindWindowEx(nHFrame, 0, "ReBarWindow32", 0)

    IF nHReBar != 0
      aHWnd := EnumChildWindows(nHReBar)

      FOR n := 1 TO Len(aHWnd)
        IF (GetClassName(aHWnd[n]) == "Static")
          cText := GetWindowText2(aHWnd[n])

          IF Left(cText, 3) == " / "
            nCount := Val(Substr(cText, 4))
            EXIT
          ENDIF
        ENDIF
      NEXT

    ENDIF
  ENDIF

RETURN nCount


/*
  nAction:
  -1 - find previous
   1 - find next
  otherwise - "Find" dialog
*/
FUNCTION Sumatra_FindText(cPanel, nAction)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL nWParam

  IF nHFrame != 0
    IF (! HB_IsNumeric(nAction))
      nAction := 0
    ENDIF

    SWITCH nAction
      CASE -1;   nWParam := 437 /*IDM_FIND_PREV*/;  EXIT
      CASE  1;   nWParam := 436 /*IDM_FIND_NEXT*/;  EXIT
      OTHERWISE; nWParam := 435 /*IDM_FIND_FIRST*/
    ENDSWITCH

    PostMessage(nHFrame, 273 /*WM_COMMAND*/, nWParam, 0)
  ENDIF

RETURN NIL


/*
  nAction:
  -1 - size down
   1 - size up
   2 - fit page
   3 - real size
   4 - fit width
  otherwise - "Zoom factor" dialog
*/
FUNCTION Sumatra_Zoom(cPanel, nAction)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL nWParam

  IF nHFrame != 0
    IF (! HB_IsNumeric(nAction))
      nAction := 0
    ENDIF

    SWITCH nAction
      CASE -1;   nWParam := 3013 /*IDT_VIEW_ZOOMOUT*/;     EXIT
      CASE  1;   nWParam := 3012 /*IDT_VIEW_ZOOMIN*/;      EXIT
      CASE  2;   nWParam :=  440 /*IDM_ZOOM_FIT_PAGE*/;    EXIT
      CASE  3;   nWParam :=  441 /*IDM_ZOOM_ACTUAL_SIZE*/; EXIT
      CASE  4;   nWParam :=  442 /*IDM_ZOOM_FIT_WIDTH*/;   EXIT
      OTHERWISE; nWParam :=  457 /*IDM_ZOOM_CUSTOM*/
    ENDSWITCH

    PostMessage(nHFrame, 273 /*WM_COMMAND*/, nWParam, 0)
  ENDIF

RETURN NIL


/*
  nAction:
  -1 - rotate left
   1 - rotate right
  otherwise - rotate 180°
*/
FUNCTION Sumatra_Rotate(cPanel, nAction)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL nWParam

  IF nHFrame != 0
    IF (! HB_IsNumeric(nAction))
      nAction := 0
    ENDIF

    IF nAction == -1
      nWParam := 415 /*IDM_VIEW_ROTATE_LEFT*/
    ELSE
      nWParam := 416 /*IDM_VIEW_ROTATE_RIGHT*/
    ENDIF

    PostMessage(nHFrame, 273 /*WM_COMMAND*/, nWParam, 0)

    IF nAction == 0
      PostMessage(nHFrame, 273 /*WM_COMMAND*/, nWParam, 0)
    ENDIF
  ENDIF

RETURN NIL


STATIC FUNCTION EnumChildWindows(hWnd)
  LOCAL aChilds := {}

  C_EnumChildWindows( hWnd, {|hChild| AAdd( aChilds, hChild ), .T. } )

RETURN aChilds


#pragma BEGINDUMP

#include <mgdefs.h>
#include "hbapiitm.h"

       //GetWindowText2(nHWnd)
HB_FUNC( GETWINDOWTEXT2 )
{
  HWND hWnd    = (HWND)   HB_PARNL(1);
  INT  nLen    = (INT)    SendMessage(hWnd, WM_GETTEXTLENGTH, 0, 0) + 1;
  LPTSTR cText = (LPTSTR) hb_xgrab(nLen * sizeof(TCHAR));

  SendMessage(hWnd, WM_GETTEXT, nLen, (LPARAM) cText);
  hb_retclen(cText, nLen - 1);
  hb_xfree(cText);
}

//        GetParent(hWnd)
HB_FUNC ( GETPARENT )
{
   HWND hWnd = (HWND) HB_PARNL (1);
   HB_RETNL ((LONG_PTR) GetParent(hWnd) );
}

//       ClientToScreenRow (hWnd, Row) --> New_Row 
HB_FUNC (CLIENTTOSCREENROW)
{
   HWND hWnd = (HWND) HB_PARNL (1);
   LONG y    = (LONG) hb_parnl (2);
   POINT Point;
   Point.x = 0;
   Point.y = y;
   ClientToScreen(hWnd, &Point);
   hb_retnl ((LONG) Point.y );
}

//       ClientToScreenCol (hWnd, Col) --> New_Col 
HB_FUNC (CLIENTTOSCREENCOL)
{
   HWND hWnd = (HWND) HB_PARNL (1);
   LONG x    = (LONG) hb_parnl (2);
   POINT Point;
   Point.x = x;
   Point.y = 0;
   ClientToScreen(hWnd, &Point);
   hb_retnl ((LONG) Point.x );
}

//        GetWindowLongPtr (hWnd, nIndex) --> return dwRetLong
HB_FUNC ( GETWINDOWLONGPTR )
{
   HWND hWnd  = (HWND) HB_PARNL (1);
   int nIndex = (int)  hb_parnl (2);
   LONG_PTR dwRetLong = GetWindowLongPtr (hWnd, nIndex);
   HB_RETNL((LONG_PTR) dwRetLong);
}


static BOOL CALLBACK EnumChildProc( HWND hWnd, LPARAM lParam )
{
   PHB_ITEM pCodeBlock = ( PHB_ITEM ) lParam;
   PHB_ITEM pHWnd = hb_itemPutNInt( NULL, ( LONG_PTR ) hWnd );

   if( pCodeBlock )
   {
      hb_evalBlock1( pCodeBlock, pHWnd );
   }

   hb_itemRelease( pHWnd );

   return ( ( BOOL ) hb_parl( -1 ) );
}

HB_FUNC( C_ENUMCHILDWINDOWS )
{
   HWND hWnd = ( HWND ) HB_PARNL( 1 );
   PHB_ITEM pCodeBlock = hb_param( 2, HB_IT_BLOCK );

   if( IsWindow( hWnd ) && pCodeBlock )
   {
      hb_retl( EnumChildWindows( hWnd, EnumChildProc, ( LPARAM ) pCodeBlock ) ? HB_TRUE : HB_FALSE );
   }
}

#pragma ENDDUMP
