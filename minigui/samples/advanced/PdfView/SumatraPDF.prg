/*

  SumatraPDF.prg
  Library functions for handling SumatraPDF reader in plugin mode
  Version: 2017-05-28
  Author:  KDJ

  Designed for SumatraPDF ver. 3.1.2
  https://www.sumatrapdfreader.org

  Compile to library libSumatraPDF.a or include SumatraPDF.prg into your project
  
  Contains functions:
    Sumatra_FileOpen
    Sumatra_FileClose
    Sumatra_FileName
    Sumatra_FileSaveAs
    Sumatra_FilePrint
    Sumatra_FileProperties
    Sumatra_FrameHandle
    Sumatra_FrameAdjust
    Sumatra_FrameRedraw
    Sumatra_Bookmarks
    Sumatra_BookmarksHandle
    Sumatra_BookmarksExist
    Sumatra_BookmarksExpand
    Sumatra_Toolbar
    Sumatra_ToolbarHandle
    Sumatra_PageGoTo
    Sumatra_PageNumber
    Sumatra_PageCount
    Sumatra_FindText
    Sumatra_Zoom
    Sumatra_Rotate
    Sumatra_About
    GetWindowText2

*/


#include "hmg.ch"


/*
  Sumatra_FileOpen(cPanel, cPdfFile, [nPage], [nZoom], [lBookmarks], [lToolbar], [cLanguage], [cSumatraPDFExe])
    nZoom can be:
      2 - fit page
      3 - actual (real) size
      4 - fit width (default)
  --> >0 - if no error, page number of cPdfFile is returned
  -->  0 - if error loading cPdfFile occurs
  --> -1 - if cPanel window is not defined
  --> -2 - if SumatraPDF executable file not found
  --> -3 - if cPdfFile does not exist
*/
FUNCTION Sumatra_FileOpen(cPanel, cPdfFile, nPage, nZoom, lBookmarks, lToolbar, cLang, cExeFile)
  LOCAL nHFrame
  LOCAL cZoom

  IF ! _IsWindowDefined(cPanel)
    RETURN -1
  ENDIF

  IF (! HB_IsChar(cExeFile)) .or. Empty(cExeFile)
    cExeFile := HB_DirBase() + "SumatraPDF.exe"
  ENDIF

  IF ! HB_FileExists(cExeFile)
    RETURN -2
  ENDIF

  IF (! HB_IsChar(cPdfFile)) .or. (VolSerial(HB_ULeft(cPdfFile, 3)) == -1) .or. (! HB_FileExists(cPdfFile))
    RETURN -3
  ENDIF

  IF (! HB_IsNumeric(nPage)) .or. (nPage < 1)
    nPage := 1
  ENDIF

  IF ! HB_IsNumeric(nZoom)
    nZoom := 4
  ENDIF

  SWITCH nZoom
    CASE 2
      cZoom := '"fit page"'
      EXIT
    CASE 3
      cZoom := '"actual size"'
      EXIT
    OTHERWISE
      cZoom := '"fit width"'
  ENDSWITCH

  IF (! HB_IsChar(cLang)) .or. Empty(cLang)
    cLang := "en"
  ENDIF

  IF Sumatra_FrameHandle(cPanel) != 0
    Sumatra_FileClose(cPanel)
  ENDIF

  ShellExecute(0, 'open', cExeFile, '-page ' + HB_NtoS(nPage) + ' -lang ' + cLang + ' -zoom ' + cZoom + ' -plugin ' +  HB_NtoS(GetFormHandle(cPanel)) + ' "' + cPdfFile + '"', NIL, 10 /*SW_SHOWDEFAULT*/)

  DO WHILE ((nHFrame := Sumatra_FrameHandle(cPanel)) == 0) .or. (Sumatra_ToolbarHandle(cPanel) == 0) .or. (Sumatra_BookmarksHandle(cPanel) == 0)
    HB_IdleSleep(0.01)
  ENDDO

  Sumatra_Toolbar(cPanel, lToolbar)
  SendMessage(nHFrame, 273 /*WM_COMMAND*/, 417 /*IDM_VIEW_BOOKMARKS*/, 0)
  Sumatra_Bookmarks(cPanel, lBookmarks)

  IF nPage > Sumatra_PageCount(cPanel)
    Sumatra_PageGoTo(cPanel, 2 /*last page*/)
  ENDIF

  SetWindowText(nHFrame, cPdfFile)

RETURN Sumatra_PageNumber(cPanel)


FUNCTION Sumatra_FileClose(cPanel, lRedraw)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL nHPanel
  LOCAL nPID

  IF nHFrame != 0
    nHPanel := GetFormHandle(cPanel)
    EnableWindowRedraw(nHPanel, .F.)

    GetWindowThreadProcessId(nHFrame, NIL, @nPID)
    TerminateProcess(nPID)

    DO WHILE IsValidWindowHandle(nHFrame)
    ENDDO

    EnableWindowRedraw(nHPanel, .T., lRedraw)
  ENDIF

RETURN NIL


       //Sumatra_FileName(cPanel) --> name of opened PDF file or empty string
FUNCTION Sumatra_FileName(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    RETURN GetWindowText(nHFrame)
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


       //Sumatra_FrameHandle(cPanel) --> handle to Sumatra frame embeded in panel or 0 if no frame
FUNCTION Sumatra_FrameHandle(cPanel)

  IF _IsWindowDefined(cPanel)
    RETURN FindWindowEx(GetFormHandle(cPanel), 0, "SUMATRA_PDF_FRAME", 0)
  ENDIF

RETURN 0


FUNCTION Sumatra_FrameAdjust(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    SetWindowPos(nHFrame, 0, 0, 0, GetProperty(cPanel, "CLIENTAREAWIDTH"), GetProperty(cPanel, "CLIENTAREAHEIGHT"), 0x0016 /*SWP_NOACTIVATE|SWP_NOZORDER|SWP_NOMOVE*/)
  ENDIF

RETURN NIL


FUNCTION Sumatra_FrameRedraw(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    RedrawWindow(nHFrame)
  ENDIF

RETURN NIL


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


       //Sumatra_BookmarksHandle(cPanel) --> handle to Sumatra bookmarks tree
FUNCTION Sumatra_BookmarksHandle(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL aHWnd
  LOCAL n

  IF nHFrame != 0
    aHWnd := EnumChildWindows(nHFrame)

    FOR n := 1 TO Len(aHWnd)
      IF (GetClassName(aHWnd[n]) == "SysTreeView32") .and. (GetWindowText2(aHWnd[n]) == "TOC")
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


       //Sumatra_BookmarksExpand(cPanel, lExpand) - expand or collapse all items in bookmarks tree
FUNCTION Sumatra_BookmarksExpand(cPanel, lExpand)
  LOCAL nHBook := Sumatra_BookmarksHandle(cPanel)
  LOCAL nHItem
  LOCAL nExpand

  IF IsWindowVisible(nHBook)
    nHItem  := TreeView_GetRoot(nHBook)
    nExpand := If(lExpand, 2 /*TVE_EXPAND*/, 1 /*TVE_COLLAPSE*/)

    DO WHILE nHItem != 0
      TreeView_ExpandChildrenRecursive(nHBook, nHItem, nExpand, .T.)
      nHItem := TreeView_GetNextSibling(nHBook, nHItem)
    ENDDO

    SendMessage(nHBook, 4372 /*TVM_ENSUREVISIBLE*/, 0, TreeView_GetSelection(nHBook))
  ENDIF

RETURN NIL


       //Sumatra_Toolbar(cPanel, [lShow]) - show/hide Sumatra toolbar
       //--> previous setting
FUNCTION Sumatra_Toolbar(cPanel, lShow)
  LOCAL lVisible := .F.
  LOCAL nHFrame  := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    lVisible := IsWindowVisible(Sumatra_ToolbarHandle(cPanel))

    IF HB_IsLogical(lShow)
      IF lShow != lVisible
        SendMessage(nHFrame, 273 /*WM_COMMAND*/, 419 /*IDM_VIEW_SHOW_HIDE_TOOLBAR*/, 0)
      ENDIF
    ENDIF
  ENDIF

RETURN lVisible


       //Sumatra_ToolbarHandle(cPanel) --> handle to Sumatra toolbar
FUNCTION Sumatra_ToolbarHandle(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL nHReBar

  IF nHFrame != 0
    nHReBar := FindWindowEx(nHFrame, 0, "ReBarWindow32", 0)

    IF nHReBar != 0
      RETURN FindWindowEx(nHReBar, 0, "ToolbarWindow32", 0)
    ENDIF
  ENDIF

RETURN 0


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
      CASE -1;   nWParam := 431 /*IDM_GOTO_PREV_PAGE*/  ; EXIT
      CASE  1;   nWParam := 430 /*IDM_GOTO_NEXT_PAGE*/  ; EXIT
      CASE -2;   nWParam := 432 /*IDM_GOTO_FIRST_PAGE*/ ; EXIT
      CASE  2;   nWParam := 433 /*IDM_GOTO_LAST_PAGE*/  ; EXIT
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

  LOCAL cText
  LOCAL nPos
  LOCAL n

  IF nHFrame != 0
    nHReBar := FindWindowEx(nHFrame, 0, "ReBarWindow32", 0)

    IF nHReBar != 0
      aHWnd := EnumChildWindows(nHReBar)

      FOR n := 1 TO Len(aHWnd)
        IF (GetClassName(aHWnd[n]) == "Static")
          cText := GetWindowText2(aHWnd[n])
          nPos  := HB_UAt("(", cText)

          IF nPos > 0
            nPage := Val(Substr(cText, nPos + 1))
            EXIT
          ENDIF
        ENDIF
      NEXT

      IF nPage == 0
        FOR n := 1 TO Len(aHWnd)
          IF (GetClassName(aHWnd[n]) == "Edit") .and. (HB_BitAnd(GetWindowLongPtr(aHWnd[n], -16 /*GWL_STYLE*/), 0x2002 /*ES_NUMBER|ES_RIGHT*/) != 0)
            nPage := Val(GetWindowText2(aHWnd[n]))
            EXIT
          ENDIF
        NEXT
      ENDIF
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
  LOCAL nPos
  LOCAL n


  IF nHFrame != 0
    nHReBar := FindWindowEx(nHFrame, 0, "ReBarWindow32", 0)

    IF nHReBar != 0
      aHWnd := EnumChildWindows(nHReBar)

      FOR n := 1 TO Len(aHWnd)
        IF (GetClassName(aHWnd[n]) == "Static")
          cText := GetWindowText2(aHWnd[n])
          nPos  := HB_UAt("/", cText)

          IF nPos > 0
            nCount := Val(Substr(cText, nPos + 1))
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
      CASE -1;   nWParam := 437 /*IDM_FIND_PREV*/ ; EXIT
      CASE  1;   nWParam := 436 /*IDM_FIND_NEXT*/ ; EXIT
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

  IF nHFrame != 0
    IF (! HB_IsNumeric(nAction))
      nAction := 0
    ENDIF

    SWITCH nAction
      CASE -1
        SendMessage(nHFrame, 273 /*WM_COMMAND*/, 3013 /*IDT_VIEW_ZOOMOUT*/, 0)
        EXIT
      CASE 1
        SendMessage(nHFrame, 273 /*WM_COMMAND*/, 3012 /*IDT_VIEW_ZOOMIN*/, 0)
        EXIT
      CASE 2
        SendMessage(nHFrame, 273 /*WM_COMMAND*/, 3026 /*IDT_VIEW_FIT_WIDTH*/, 0)
        SendMessage(nHFrame, 273 /*WM_COMMAND*/,  440 /*IDM_ZOOM_FIT_PAGE*/, 0)
        EXIT
      CASE 3
        SendMessage(nHFrame, 273 /*WM_COMMAND*/, 3026 /*IDT_VIEW_FIT_WIDTH*/, 0)
        SendMessage(nHFrame, 273 /*WM_COMMAND*/,  441 /*IDM_ZOOM_ACTUAL_SIZE*/, 0)
        EXIT
      CASE 4
        SendMessage(nHFrame, 273 /*WM_COMMAND*/, 3026 /*IDT_VIEW_FIT_WIDTH*/, 0)
        EXIT
      OTHERWISE
        PostMessage(nHFrame, 273 /*WM_COMMAND*/,  457 /*IDM_ZOOM_CUSTOM*/, 0)
        EXIT
    ENDSWITCH
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

    SendMessage(nHFrame, 273 /*WM_COMMAND*/, nWParam, 0)

    IF nAction == 0
      SendMessage(nHFrame, 273 /*WM_COMMAND*/, nWParam, 0)
    ENDIF
  ENDIF

RETURN NIL


FUNCTION Sumatra_About(cPanel)
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)

  IF nHFrame != 0
    PostMessage(nHFrame, 273 /*WM_COMMAND*/, 551 /*IDM_ABOUT*/, 0)
  ENDIF

RETURN NIL


STATIC FUNCTION EnumChildWindows(hWnd)
  LOCAL aChilds := {}

  C_EnumChildWindows( hWnd, {|hChild| AAdd( aChilds, hChild ), .T. } )

RETURN aChilds


#pragma BEGINDUMP

#include <mgdefs.h>
#include "hbapiitm.h"

#include <commctrl.h>

//--------------------------------------------------------------------------------------------------------
//   TreeView_ExpandChildrenRecursive ( hWndTV, ItemHandle, nExpand, fRecurse )
//--------------------------------------------------------------------------------------------------------

BOOL TreeView_IsNode (HWND hWndTV, HTREEITEM ItemHandle)
{   if ( TreeView_GetChild (hWndTV , ItemHandle) != NULL )
        return TRUE;
    else
        return FALSE;
}

void TreeView_ExpandChildrenRecursive (HWND hWndTV, HTREEITEM ItemHandle, UINT nExpand)
{
   HTREEITEM ChildItem;
   HTREEITEM NextItem;

   if ( TreeView_IsNode ( hWndTV, ItemHandle ) )
   {
        TreeView_Expand ( hWndTV, ItemHandle, nExpand );
        ChildItem = TreeView_GetChild ( hWndTV , ItemHandle );

        while ( ChildItem != NULL )
        {
            TreeView_ExpandChildrenRecursive (hWndTV, ChildItem, nExpand);
      
            NextItem = TreeView_GetNextSibling (hWndTV, ChildItem);
            ChildItem = NextItem;
        }
   }
}

HB_FUNC (TREEVIEW_EXPANDCHILDRENRECURSIVE)
{
   HWND      hWndTV     = (HWND)      HB_PARNL (1);
   HTREEITEM ItemHandle = (HTREEITEM) HB_PARNL (2);
   UINT      nExpand    = (UINT)      hb_parnl (3);
   BOOL      fRecurse   = (BOOL)      hb_parl  (4);
   
   if ( fRecurse == FALSE )
      TreeView_Expand ( hWndTV, ItemHandle, nExpand );
   else
   {
      HWND hWndParent = GetParent (hWndTV);
      BOOL lEnabled   = IsWindowEnabled (hWndParent);
      
      EnableWindow (hWndParent, FALSE);
      
      TreeView_ExpandChildrenRecursive ( hWndTV, ItemHandle, nExpand );
      
      if (lEnabled == TRUE)
          EnableWindow (hWndParent, TRUE);
   }
}

HB_FUNC (TREEVIEW_GETNEXTSIBLING)
{
   HWND        hWndTV     = (HWND) HB_PARNL (1);
   HTREEITEM   ItemHandle = (HTREEITEM) HB_PARNL (2);
   HTREEITEM   NextItemHandle = TreeView_GetNextSibling ( hWndTV , ItemHandle ) ;
   HB_RETNL ((LONG_PTR) NextItemHandle ) ;
}

HB_FUNC (TREEVIEW_GETROOT)
{
   HWND hWndTV = (HWND) HB_PARNL (1);
   HTREEITEM RootItemHandle = TreeView_GetRoot ( hWndTV );
   HB_RETNL ((LONG_PTR) RootItemHandle ) ;
}

HB_FUNC( WINMAJORVERSIONNUMBER )
{
   OSVERSIONINFOEX osvi;

   ZeroMemory(&osvi,sizeof(OSVERSIONINFOEX));
   osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);

    GetVersionEx((OSVERSIONINFO*)&osvi);

   hb_retni( osvi.dwMajorVersion );
}

HB_FUNC( WINMINORVERSIONNUMBER )
{
   OSVERSIONINFOEX osvi;

   ZeroMemory(&osvi,sizeof(OSVERSIONINFOEX));
   osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);

   GetVersionEx((OSVERSIONINFO*)&osvi);

   hb_retni( osvi.dwMinorVersion ) ;
}

//        GetWindowThreadProcessId (hWnd, @nThread, @nProcessID)
HB_FUNC ( GETWINDOWTHREADPROCESSID )
{
   HWND hWnd = (HWND) HB_PARNL (1);
   DWORD nThread, nProcessID;

   nThread = GetWindowThreadProcessId (hWnd, &nProcessID);

   if ( HB_ISBYREF(2) )
        hb_storni (nThread, 2); 
   if ( HB_ISBYREF(3) )
        hb_storni (nProcessID, 3); 
}

//        TerminateProcess ( [ nProcessID ] , [ nExitCode ] )
HB_FUNC ( TERMINATEPROCESS )
{
   DWORD ProcessID = HB_ISNUM (1) ? (DWORD) hb_parnl(1) : GetCurrentProcessId();
   UINT  uExitCode = (UINT) hb_parnl (2);
   HANDLE hProcess = OpenProcess ( PROCESS_TERMINATE, FALSE, ProcessID );
   if ( hProcess != NULL )
   {   if ( TerminateProcess (hProcess, uExitCode) == FALSE )
           CloseHandle (hProcess);
   }
}

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

//       ClientToScreen (hWnd, @x, @y)
HB_FUNC (CLIENTTOSCREEN)
{
   HWND hWnd = (HWND) HB_PARNL (1);
   LONG x    = (LONG) hb_parnl (2);
   LONG y    = (LONG) hb_parnl (3);
   POINT Point;
   Point.x = x;
   Point.y = y;
   hb_retl (ClientToScreen(hWnd, &Point));
   if (HB_ISBYREF(2))
       hb_stornl ((LONG) Point.x, 2);
   if (HB_ISBYREF(3))
       hb_stornl ((LONG) Point.y, 3);
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
