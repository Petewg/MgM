/*

  Pdf viewer using SumatraPDF.exe

  Source files:
    PdfView.prg
    PdfView_C.prg
    SumatraPDF.prg
    PdfView.ch
    PdfView.rc
    Resource\ButtonArrow.bmp
    Resource\SumatraPDF.ico

*/

#define PDFVIEW_VERSION "2017-05-28"

#include "Directry.ch"
#include "hmg.ch"
#include "PdfView.ch"
#include "i_winuser.ch"

STATIC snHFocusMenu
STATIC snHMenuMain

STATIC saTab
STATIC saPanel
STATIC slMenuActive
STATIC scDirStart

//saved in .recent
STATIC saSession
STATIC saRecent

//saved in .ini
STATIC slPdfView_Max
STATIC snPdfView_R
STATIC snPdfView_C
STATIC snPdfView_W
STATIC snPdfView_H
STATIC snFiles_W
STATIC snRecent_W
STATIC snRecent_H
STATIC slRecentNames
STATIC snRecentAmount
STATIC snZoom
STATIC slMenuBar
STATIC slToolbar
STATIC slBookmarks
STATIC slOpenAtOnce
STATIC slSessionRest
STATIC slTabGoToFile
STATIC slEscExit
STATIC scSumatraDir
STATIC scFileDir
STATIC scFileLast
STATIC scLang


FUNCTION Main()
  LOCAL lSessionOnInit := .F.
  LOCAL lOnGotFocus    := .F.

  SET FONT TO "MS Shell Dlg", 8
  SET DEFAULT ICON TO "SumatraPDF"
  SET CENTERWINDOW RELATIVE PARENT

  SettingsRead()

  IF IsExeRunning( cFileNoPath( HB_ArgV( 0 ) ) )
    MsgWin(LangStr("AppRunning"))
    QUIT
  ENDIF

  DEFINE WINDOW PdfView;
    ROW    snPdfView_R;
    COL    snPdfView_C;
    WIDTH  snPdfView_W;
    HEIGHT snPdfView_H;
    TITLE  "PdfView";
    MAIN;
    ON INIT      ((lSessionOnInit := (SessionOpen(1) .or. SessionOpen(3))), FileListRefresh(scFileLast), (lSessionOnInit := .F.));
    ON GOTFOCUS  ((lOnGotFocus := .T.), FileListRefresh(PdfView.Files.Cell(PdfView.Files.VALUE, F_NAME)), (lOnGotFocus := .F.), TabCloseAllEmpty());
    ON SIZE      PdfViewResize(.T.);
    ON MAXIMIZE  PdfViewResize(.T.);
    ON RELEASE   (SettingsWrite(), DestroyMenu(snHMenuMain))

    DEFINE GRID Files
      ROW            0
      COL            -1
      WIDTH          snFiles_W
      HEADERS        {NIL, NIL, NIL, NIL, NIL}
      WIDTHS         {snFiles_W - 4, 0, 0, 0, 0}
      CELLNAVIGATION .F.
      ONDBLCLICK     FileOpen(NIL, (GetKeyState(VK_CONTROL) < 0), (GetKeyState(VK_SHIFT) < 0))
      ONCHANGE       If(slOpenAtOnce .and. (! lSessionOnInit) .and. (! lOnGotFocus) .and. (! ("D" $ PdfView.Files.Cell(PdfView.Files.VALUE, F_ATTR))), FileOpen(), NIL)
    END GRID

    DEFINE TAB Tabs;
      ROW    0;
      COL    0;
      WIDTH  0;
      HEIGHT 20
    END TAB

    DEFINE STATUSBAR
      STATUSITEM ""
      STATUSITEM "" WIDTH 140
    END STATUSBAR
  END WINDOW

  ListView_ChangeExtendedStyle(PdfView.Files.HANDLE, LVS_EX_INFOTIP)
  HMG_ChangeWindowStyle(PdfView.Tabs.HANDLE, 0x8000 /*TCS_FOCUSNEVER*/, NIL, .F., .F.)

  TabNew(PanelNew())

  IF slPdfView_Max
    PdfView.MAXIMIZE
  ENDIF

  SetOnKey(.T.)
  SetLangInterface()
  PdfViewResize(.T.)
  ChangeWindowMessageFilter(PdfView.HANDLE, 74 /*WM_COPYDATA*/, 1 /*MSGFLT_ALLOW*/)

  InstallEventHandler("MainEventHandler")

  DEFINE TIMER PdfTimer PARENT PdfView INTERVAL 100 ACTION StatusSetPage(.F.)

  PdfView.ACTIVATE

RETURN NIL


FUNCTION SetLangInterface(cNewLang)
  LOCAL aLang
  LOCAL cName
  LOCAL cAction
  LOCAL n

  IF ! (scLang == cNewLang)
    aLang := LangStr()

    IF ! Empty(cNewLang)
      scLang := cNewLang

      IF slMenuBar
         RELEASE MAIN MENU OF PdfView
      ELSE
        DestroyMenu(snHMenuMain)
      ENDIF
    ENDIF

    DEFINE MAINMENU OF PdfView
      DEFINE POPUP LangStr("File")
        MENUITEM LangStr("OpenCurTab") + e"\tEnter"                 NAME Open         ACTION FileOpen()
        MENUITEM LangStr("OpenNewTab") + e"\tShift+Enter"           NAME OpenTab      ACTION FileOpen(NIL, .F., .T.)
        SEPARATOR
        MENUITEM LangStr("OpenPage") + e"...\tCtrlt+Enter"          NAME OpenPage     ACTION FileOpen(NIL, .T., .F.)
        MENUITEM LangStr("OpenPageTab") + e"...\tCtrlt+Shift+Enter" NAME OpenPageTab  ACTION FileOpen(NIL, .T., .T.)
        SEPARATOR
        MENUITEM LangStr("OpenSession")                             NAME FileSession  ACTION SessionOpen(4)
        MENUITEM LangStr("RecentFiles") + "..."                     NAME FileRecent   ACTION RecentFiles()
        SEPARATOR
        MENUITEM LangStr("RefreshList") + e"\tF5"                   NAME FileRefresh  ACTION FileListRefresh(PdfView.Files.Cell(PdfView.Files.VALUE, F_NAME))
        SEPARATOR
        MENUITEM LangStr("Exit") + e"\tAlt+F4"                      NAME FileExit     ACTION ThisWindow.RELEASE
      END POPUP
      DEFINE POPUP LangStr("Document")
        MENUITEM LangStr("SaveAs") + e"...\tCtrl+S"                 NAME DocSaveAs    ACTION Sumatra_FileSaveAs(PanelName())
        MENUITEM LangStr("Print") + e"...\tCtrl+P"                  NAME DocPrint     ACTION Sumatra_FilePrint(PanelName())
        MENUITEM LangStr("Proper") + e"...\tCtrl+D"                 NAME DocProper    ACTION Sumatra_FileProperties(PanelName())
        MENUITEM LangStr("Close") + e"\tCtrl+W"                     NAME DocClose     ACTION TabClose()
        SEPARATOR
        MENUITEM LangStr("ChooseDoc") + e"\tAlt+0"                  NAME DocChoose    ACTION TabMenu(.F.)
        SEPARATOR
        MENUITEM LangStr("GoToFile") + e"\tCtrl+Shift+F"            NAME DocGoToFile  ACTION FileGoTo()
      END POPUP
      DEFINE POPUP LangStr("Page")
        MENUITEM LangStr("GoTo") + e"...\tCtrl+G"                   NAME PageGoTo     ACTION Sumatra_PageGoTo(PanelName())
        SEPARATOR
        MENUITEM LangStr("Prev") + e"\tCtrl+<-"                     NAME PagePrev     ACTION Sumatra_PageGoTo(PanelName(), -1)
        MENUITEM LangStr("Next") + e"\tCtrl+->"                     NAME PageNext     ACTION Sumatra_PageGoTo(PanelName(),  1)
        MENUITEM LangStr("First") + e"\tHome"                       NAME PageFirst    ACTION Sumatra_PageGoTo(PanelName(), -2)
        MENUITEM LangStr("Last") + e"\tEnd"                         NAME PageLast     ACTION Sumatra_PageGoTo(PanelName(),  2)
      END POPUP
      DEFINE POPUP LangStr("Find")
        MENUITEM LangStr("Text") + e"...\tCtrl+F"                   NAME FindText     ACTION Sumatra_FindText(PanelName())
        SEPARATOR
        MENUITEM LangStr("PrevOccur") + e"\tShift+F3"               NAME FindPrev     ACTION Sumatra_FindText(PanelName(), -1)
        MENUITEM LangStr("NextOccur") + e"\tF3"                     NAME FindNext     ACTION Sumatra_FindText(PanelName(),  1)
      END POPUP
      DEFINE POPUP LangStr("Zoom")
        MENUITEM LangStr("SizeDn") + e"\tCtrl+Minus"                NAME ZoomSizeDn   ACTION Sumatra_Zoom(PanelName(), -1)
        MENUITEM LangStr("SizeUp") + e"\tCtrl+Plus"                 NAME ZoomSizeUp   ACTION Sumatra_Zoom(PanelName(),  1)
        MENUITEM LangStr("ZoomFactor") + e"...\tCtrl+Y"             NAME ZoomFactor   ACTION Sumatra_Zoom(PanelName())
        SEPARATOR
        MENUITEM LangStr("FitPage") + e"\tCtrl+0"                   NAME ZoomFitPage  ACTION SetZoom(2)
        MENUITEM LangStr("ActualSize") + e"\tCtrl+1"                NAME ZoomActual   ACTION SetZoom(3)
        MENUITEM LangStr("FitWidth") + e"\tCtrl+2"                  NAME ZoomFitWidth ACTION SetZoom(4)
      END POPUP
      DEFINE POPUP LangStr("Rotate")
        MENUITEM LangStr("Left") + e"\tCtrl+Shift+Minus"            NAME RotateLeft   ACTION Sumatra_Rotate(PanelName(), -1)
        MENUITEM LangStr("Right") + e"\tCtrl+Shift+Plus"            NAME RotateRight  ACTION Sumatra_Rotate(PanelName(),  1)
        MENUITEM e"&180°\tCtrl+Shift+Num*"                          NAME Rotate180    ACTION Sumatra_Rotate(PanelName())
      END POPUP
      DEFINE POPUP LangStr("View")
        MENUITEM LangStr("MenuBar") + e"\tF9"                       NAME MenuBar      ACTION SetMenu(PdfView.HANDLE, If((slMenuBar := ! slMenuBar), snHMenuMain, 0))
        MENUITEM LangStr("Toolbar") + e"\tF8"                       NAME Toolbar      ACTION Sumatra_Toolbar(PanelName(), ! Sumatra_Toolbar(PanelName()))
        DEFINE POPUP LangStr("Bookmarks") NAME Bookmarks
          MENUITEM LangStr("Show") + e"\tF12"                       NAME BookShow     ACTION Sumatra_Bookmarks(PanelName(), ! Sumatra_Bookmarks(PanelName()))
          SEPARATOR
          MENUITEM LangStr("ExpandAll") + e"\tCtrl+F12"             NAME BookExpand   ACTION Sumatra_BookmarksExpand(PanelName(), .T.)
          MENUITEM LangStr("CollapseAll") + e"\tAlt+F12"            NAME BookCollapse ACTION Sumatra_BookmarksExpand(PanelName(), .F.)
        END POPUP
      END POPUP
      DEFINE POPUP LangStr("Settings")
        MENUITEM LangStr("OpenAtOnce")                              NAME OpenAtOnce   ACTION (slOpenAtOnce  := ! slOpenAtOnce)
        MENUITEM LangStr("RestSession")                             NAME RestSession  ACTION (slSessionRest := ! slSessionRest)
        MENUITEM LangStr("TabGoToFile")                             NAME TabGoToFile  ACTION (slTabGoToFile := ! slTabGoToFile)
        MENUITEM LangStr("EscExit")                                 NAME EscExit      ACTION ((slEscExit    := ! slEscExit), SetOnKey(.T.))
        SEPARATOR
        MENUITEM LangStr("SumatraDir")                              NAME SumatraDir   ACTION InputSumatraDir()
        DEFINE POPUP LangStr("Language")
          FOR n := 1 TO Len(aLang)
            cName   := "Lang_" + aLang[n][3]
            cAction := "SetLangInterface('" + aLang[n][3] + "')"
            MENUITEM aLang[n][1] + Chr(9) + aLang[n][2]             NAME &cName       ACTION &cAction
            IF aLang[n][3] == scLang
              SetProperty("PdfView", cName, "CHECKED", .T.)
            ENDIF
          NEXT
        END POPUP
        SEPARATOR
        MENUITEM LangStr("AboutPdfView") + e"\tF1"                  NAME AboutPdfView ACTION AboutPdfView()
        MENUITEM LangStr("AboutSumatra") + e"\tShift+F1"            NAME AboutSumatra ACTION Sumatra_About(PanelName())
      END POPUP
    END MENU

    snHMenuMain := GetMenu(PdfView.HANDLE)

    IF ! slMenuBar
      SetMenu(PdfView.HANDLE, 0)
    ENDIF

    IF ! Empty(cNewLang)
      //PdfView.REDRAW
      SessionReopen()
    ENDIF
  ENDIF

RETURN NIL


FUNCTION MenuCommandsEnable()
  LOCAL lPdfSelected := (PdfView.Files.VALUE > 0) .and. (! ("D" $ PdfView.Files.Cell(PdfView.Files.VALUE, F_ATTR)))
  LOCAL cPanel       := PanelName()
  LOCAL lPdfOpened   := (Sumatra_FrameHandle(cPanel) != 0)
  LOCAL lPdfLoaded   := (Sumatra_PageCount(cPanel) > 0)

  GetSumatraSettings()

  PdfView.Open.ENABLED         := lPdfSelected
  PdfView.OpenTab.ENABLED      := lPdfSelected
  PdfView.OpenPage.ENABLED     := lPdfSelected
  PdfView.OpenPageTab.ENABLED  := lPdfSelected
  PdfView.FileSession.ENABLED  := ! Empty(saSession)
  PdfView.DocSaveAs.ENABLED    := lPdfLoaded
  PdfView.DocPrint.ENABLED     := lPdfLoaded
  PdfView.DocProper.ENABLED    := lPdfLoaded
  PdfView.DocClose.ENABLED     := lPdfOpened
  PdfView.DocChoose.ENABLED    := (Len(saTab) > 1)
  PdfView.DocGoToFile.ENABLED  := lPdfOpened
  PdfView.PageGoto.ENABLED     := lPdfLoaded
  PdfView.PagePrev.ENABLED     := lPdfLoaded
  PdfView.PageNext.ENABLED     := lPdfLoaded
  PdfView.PageFirst.ENABLED    := lPdfLoaded
  PdfView.PageLast.ENABLED     := lPdfLoaded
  PdfView.FindText.ENABLED     := lPdfLoaded
  PdfView.FindPrev.ENABLED     := lPdfLoaded
  PdfView.FindNext.ENABLED     := lPdfLoaded
  PdfView.ZoomSizeDn.ENABLED   := lPdfLoaded
  PdfView.ZoomSizeUp.ENABLED   := lPdfLoaded
  PdfView.ZoomFactor.ENABLED   := lPdfLoaded
  PdfView.ZoomFitPage.ENABLED  := lPdfLoaded
  PdfView.ZoomActual.ENABLED   := lPdfLoaded
  PdfView.ZoomFitWidth.ENABLED := lPdfLoaded
  PdfView.Rotate180.ENABLED    := lPdfLoaded
  PdfView.RotateLeft.ENABLED   := lPdfLoaded
  PdfView.RotateRight.ENABLED  := lPdfLoaded
  PdfView.Toolbar.ENABLED      := lPdfOpened
  PdfView.Bookmarks.ENABLED    := Sumatra_BookmarksExist(cPanel)
  PdfView.BookExpand.ENABLED   := slBookmarks
  PdfView.BookCollapse.ENABLED := slBookmarks
  PdfView.AboutSumatra.ENABLED := lPdfOpened

  PdfView.ZoomFitPage.CHECKED  := (snZoom == 2)
  PdfView.ZoomActual.CHECKED   := (snZoom == 3)
  PdfView.ZoomFitWidth.CHECKED := ((snZoom != 2) .and. (snZoom != 3))
  PdfView.MenuBar.CHECKED      := slMenuBar
  PdfView.Toolbar.CHECKED      := slToolbar
  PdfView.Bookmarks.CHECKED    := slBookmarks
  PdfView.BookShow.CHECKED     := slBookmarks
  PdfView.OpenAtOnce.CHECKED   := slOpenAtOnce
  PdfView.RestSession.CHECKED  := slSessionRest
  PdfView.TabGoToFile.CHECKED  := slTabGoToFile
  PdfView.EscExit.CHECKED      := slEscExit

RETURN NIL


FUNCTION SetOnKey(lSet)

  IF lSet
    ON KEY TAB                    OF PdfView ACTION SetFocusNextCtl(.F.)
    ON KEY SHIFT+TAB              OF PdfView ACTION SetFocusNextCtl(.T.)
    ON KEY CONTROL+TAB            OF PdfView ACTION TabChange(-1)
    ON KEY CONTROL+SHIFT+TAB      OF PdfView ACTION TabChange(-2)
    ON KEY CONTROL+W              OF PdfView ACTION TabClose()
    ON KEY CONTROL+S              OF PdfView ACTION Sumatra_FileSaveAs(PanelName())
    ON KEY CONTROL+P              OF PdfView ACTION Sumatra_FilePrint(PanelName())
    ON KEY CONTROL+D              OF PdfView ACTION Sumatra_FileProperties(PanelName())
    ON KEY CONTROL+SHIFT+F        OF PdfView ACTION FileGoTo()
    ON KEY F5                     OF PdfView ACTION FileListRefresh(PdfView.Files.Cell(PdfView.Files.VALUE, F_NAME))
    ON KEY CONTROL+G              OF PdfView ACTION Sumatra_PageGoTo(PanelName())
    ON KEY CONTROL+F              OF PdfView ACTION Sumatra_FindText(PanelName())
    ON KEY SHIFT+F3               OF PdfView ACTION Sumatra_FindText(PanelName(), -1)
    ON KEY F3                     OF PdfView ACTION Sumatra_FindText(PanelName(),  1)
    ON KEY CONTROL+MINUS          OF PdfView ACTION Sumatra_Zoom(PanelName(), -1)
    ON KEY CONTROL+SUBTRACT       OF PdfView ACTION Sumatra_Zoom(PanelName(), -1)
    ON KEY CONTROL+PLUS           OF PdfView ACTION Sumatra_Zoom(PanelName(),  1)
    ON KEY CONTROL+ADD            OF PdfView ACTION Sumatra_Zoom(PanelName(),  1)
    ON KEY CONTROL+Y              OF PdfView ACTION Sumatra_Zoom(PanelName())
    ON KEY CONTROL+0              OF PdfView ACTION SetZoom(2)
    ON KEY CONTROL+NUMPAD0        OF PdfView ACTION SetZoom(2)
    ON KEY CONTROL+1              OF PdfView ACTION SetZoom(3)
    ON KEY CONTROL+NUMPAD1        OF PdfView ACTION SetZoom(3)
    ON KEY CONTROL+2              OF PdfView ACTION SetZoom(4)
    ON KEY CONTROL+NUMPAD2        OF PdfView ACTION SetZoom(4)
    ON KEY CONTROL+7              OF PdfView ACTION NIL
    ON KEY CONTROL+NUMPAD7        OF PdfView ACTION NIL
    ON KEY CONTROL+8              OF PdfView ACTION NIL
    ON KEY CONTROL+NUMPAD8        OF PdfView ACTION NIL
    ON KEY CONTROL+SHIFT+MINUS    OF PdfView ACTION Sumatra_Rotate(PanelName(), -1)
    ON KEY CONTROL+SHIFT+SUBTRACT OF PdfView ACTION Sumatra_Rotate(PanelName(), -1)
    ON KEY CONTROL+SHIFT+PLUS     OF PdfView ACTION Sumatra_Rotate(PanelName(),  1)
    ON KEY CONTROL+SHIFT+ADD      OF PdfView ACTION Sumatra_Rotate(PanelName(),  1)
    ON KEY CONTROL+SHIFT+MULTIPLY OF PdfView ACTION Sumatra_Rotate(PanelName())
    ON KEY CONTROL+SHIFT+DIVIDE   OF PdfView ACTION Sumatra_Rotate(PanelName())
    ON KEY F9                     OF PdfView ACTION SetMenu(PdfView.HANDLE, If((slMenuBar := ! slMenuBar), snHMenuMain, 0))
    ON KEY F8                     OF PdfView ACTION Sumatra_Toolbar(PanelName(), ! Sumatra_Toolbar(PanelName()))
    ON KEY CONTROL+F12            OF PdfView ACTION Sumatra_BookmarksExpand(PanelName(), .T.)
    ON KEY ALT+F12                OF PdfView ACTION Sumatra_BookmarksExpand(PanelName(), .F.)
    ON KEY ALT+RETURN             OF PdfView ACTION If(IsMaximized(PdfView.HANDLE), PdfView.RESTORE, PdfView.MAXIMIZE)
    ON KEY ALT+1                  OF PdfView ACTION TabChange(1)
    ON KEY ALT+2                  OF PdfView ACTION TabChange(2)
    ON KEY ALT+3                  OF PdfView ACTION TabChange(3)
    ON KEY ALT+4                  OF PdfView ACTION TabChange(4)
    ON KEY ALT+5                  OF PdfView ACTION TabChange(5)
    ON KEY ALT+6                  OF PdfView ACTION TabChange(6)
    ON KEY ALT+7                  OF PdfView ACTION TabChange(7)
    ON KEY ALT+8                  OF PdfView ACTION TabChange(8)
    ON KEY ALT+9                  OF PdfView ACTION TabChange(0)
    ON KEY ALT+0                  OF PdfView ACTION TabMenu(.F.)
    ON KEY ALT+NUMPAD1            OF PdfView ACTION TabChange(1)
    ON KEY ALT+NUMPAD2            OF PdfView ACTION TabChange(2)
    ON KEY ALT+NUMPAD3            OF PdfView ACTION TabChange(3)
    ON KEY ALT+NUMPAD4            OF PdfView ACTION TabChange(4)
    ON KEY ALT+NUMPAD5            OF PdfView ACTION TabChange(5)
    ON KEY ALT+NUMPAD6            OF PdfView ACTION TabChange(6)
    ON KEY ALT+NUMPAD7            OF PdfView ACTION TabChange(7)
    ON KEY ALT+NUMPAD8            OF PdfView ACTION TabChange(8)
    ON KEY ALT+NUMPAD9            OF PdfView ACTION TabChange(0)
    ON KEY ALT+NUMPAD0            OF PdfView ACTION TabMenu(.F.)
    ON KEY F1                     OF PdfView ACTION AboutPdfView()
    ON KEY SHIFT+F1               OF PdfView ACTION Sumatra_About(PanelName())

    IF slEscExit
      ON KEY ESCAPE      OF PdfView ACTION PdfView.RELEASE
    ELSE
      RELEASE KEY ESCAPE OF PdfView
    ENDIF
  ELSE
    RELEASE KEY TAB                    OF PdfView
    RELEASE KEY SHIFT+TAB              OF PdfView
    RELEASE KEY CONTROL+TAB            OF PdfView
    RELEASE KEY CONTROL+SHIFT+TAB      OF PdfView
    RELEASE KEY CONTROL+W              OF PdfView
    RELEASE KEY CONTROL+S              OF PdfView
    RELEASE KEY CONTROL+P              OF PdfView
    RELEASE KEY CONTROL+D              OF PdfView
    RELEASE KEY CONTROL+SHIFT+F        OF PdfView
    RELEASE KEY F5                     OF PdfView
    RELEASE KEY CONTROL+G              OF PdfView
    RELEASE KEY CONTROL+F              OF PdfView
    RELEASE KEY SHIFT+F3               OF PdfView
    RELEASE KEY F3                     OF PdfView
    RELEASE KEY CONTROL+MINUS          OF PdfView
    RELEASE KEY CONTROL+SUBTRACT       OF PdfView
    RELEASE KEY CONTROL+PLUS           OF PdfView
    RELEASE KEY CONTROL+ADD            OF PdfView
    RELEASE KEY CONTROL+Y              OF PdfView
    RELEASE KEY CONTROL+0              OF PdfView
    RELEASE KEY CONTROL+NUMPAD0        OF PdfView
    RELEASE KEY CONTROL+1              OF PdfView
    RELEASE KEY CONTROL+NUMPAD1        OF PdfView
    RELEASE KEY CONTROL+2              OF PdfView
    RELEASE KEY CONTROL+NUMPAD2        OF PdfView
    RELEASE KEY CONTROL+7              OF PdfView
    RELEASE KEY CONTROL+NUMPAD7        OF PdfView
    RELEASE KEY CONTROL+8              OF PdfView
    RELEASE KEY CONTROL+NUMPAD8        OF PdfView
    RELEASE KEY CONTROL+SHIFT+MINUS    OF PdfView
    RELEASE KEY CONTROL+SHIFT+SUBTRACT OF PdfView
    RELEASE KEY CONTROL+SHIFT+PLUS     OF PdfView
    RELEASE KEY CONTROL+SHIFT+ADD      OF PdfView
    RELEASE KEY CONTROL+SHIFT+MULTIPLY OF PdfView
    RELEASE KEY CONTROL+SHIFT+DIVIDE   OF PdfView
    RELEASE KEY F9                     OF PdfView
    RELEASE KEY F8                     OF PdfView
    RELEASE KEY CONTROL+F12            OF PdfView
    RELEASE KEY ALT+F12                OF PdfView
    RELEASE KEY ALT+RETURN             OF PdfView
    RELEASE KEY ALT+1                  OF PdfView
    RELEASE KEY ALT+2                  OF PdfView
    RELEASE KEY ALT+3                  OF PdfView
    RELEASE KEY ALT+4                  OF PdfView
    RELEASE KEY ALT+5                  OF PdfView
    RELEASE KEY ALT+6                  OF PdfView
    RELEASE KEY ALT+7                  OF PdfView
    RELEASE KEY ALT+8                  OF PdfView
    RELEASE KEY ALT+9                  OF PdfView
    RELEASE KEY ALT+0                  OF PdfView
    RELEASE KEY ALT+NUMPAD1            OF PdfView
    RELEASE KEY ALT+NUMPAD2            OF PdfView
    RELEASE KEY ALT+NUMPAD3            OF PdfView
    RELEASE KEY ALT+NUMPAD4            OF PdfView
    RELEASE KEY ALT+NUMPAD5            OF PdfView
    RELEASE KEY ALT+NUMPAD6            OF PdfView
    RELEASE KEY ALT+NUMPAD7            OF PdfView
    RELEASE KEY ALT+NUMPAD8            OF PdfView
    RELEASE KEY ALT+NUMPAD9            OF PdfView
    RELEASE KEY ALT+NUMPAD0            OF PdfView
    RELEASE KEY F1                     OF PdfView
    RELEASE KEY SHIFT+F1               OF PdfView
    RELEASE KEY ESCAPE                 OF PdfView
  ENDIF

RETURN NIL


FUNCTION FileMenu(nRow, nCol)
  LOCAL aRect
  LOCAL nHMenu
  LOCAL nCmd

  //menu from keyboard
  IF nRow == 0xFFFF
    SendMessage(PdfView.Files.HANDLE, 0x1013 /*LVM_ENSUREVISIBLE*/, PdfView.Files.VALUE - 1, 0)
  ENDIF

  aRect    := ListView_GetItemRect(PdfView.Files.HANDLE, PdfView.Files.VALUE - 1)
  aRect[4] := ClientToScreenRow(PdfView.Files.HANDLE, aRect[1] + aRect[4])
  aRect[1] := ClientToScreenRow(PdfView.Files.HANDLE, aRect[1])
  aRect[2] := ClientToScreenCol(PdfView.Files.HANDLE, aRect[2])

  IF nRow == 0xFFFF
    nRow := aRect[4]
    nCol := aRect[2]
  ELSEIF (nRow < aRect[1]) .or. (nRow > aRect[4])
    RETURN NIL
  ENDIF

  nHMenu := CreatePopupMenu()

  IF ! ("D" $ PdfView.Files.Cell(PdfView.Files.VALUE, F_ATTR))
    AppendMenuString(nHMenu, 1, LangStr("OpenCurTab") + e"\tEnter")
    AppendMenuString(nHMenu, 2, LangStr("OpenNewTab") + e"\tShift+Enter")
    AppendMenuSeparator(nHMenu)
    AppendMenuString(nHMenu, 3, LangStr("OpenPage") + e"...\tCtrlt+Enter")
    AppendMenuString(nHMenu, 4, LangStr("OpenPageTab") + e"...\tCtrlt+Shift+Enter")
    AppendMenuSeparator(nHMenu)
  ELSEIF ! (PdfView.Files.Cell(PdfView.Files.VALUE, F_NAME) == "<..>")
    AppendMenuString(nHMenu, 5, LangStr("GoToSubDir") + e"\t-> (Enter)")
    AppendMenuSeparator(nHMenu)
  ENDIF

  IF ! ("K" $ PdfView.Files.Cell(PdfView.Files.VALUE, F_ATTR))
    AppendMenuString(nHMenu, 6, LangStr("GoToParentDir") + e"\t<-")
    AppendMenuSeparator(nHMenu)
  ENDIF

  AppendMenuString(nHMenu, 7, LangStr("RefreshList") + e"\tF5")

  slMenuActive := .T.
  SetOnKey(.F.)

  nCmd := TrackPopupMenu2(nHMenu, 0x0180 /*TPM_NONOTIFY|TPM_RETURNCMD*/, nRow, nCol, PdfView.HANDLE)

  DestroyMenu(nHMenu)
  SetOnKey(.T.)
  slMenuActive := .F.

  SWITCH nCmd
    CASE 6
      PdfView.Files.VALUE := 1
    CASE 1
    CASE 5
      FileOpen()
      EXIT
    CASE 2
      FileOpen(NIL, .F., .T.)
      EXIT
    CASE 3
      FileOpen(NIL, .T., .F.)
      EXIT
    CASE 4
      FileOpen(NIL, .T., .T.)
      EXIT
    CASE 7
      FileListRefresh(PdfView.Files.Cell(PdfView.Files.VALUE, F_NAME))
      EXIT
  ENDSWITCH

RETURN NIL


FUNCTION TabMenu(lMouse)
  LOCAL nHMenu
  LOCAL nRow, nCol
  LOCAL nCmd
  LOCAL n

  IF Len(saTab) > 1
    nHMenu := CreatePopupMenu()

    FOR n := 1 TO Len(saTab)
      AppendMenuString(nHMenu, n, Sumatra_FileName(PanelName(saTab[n])) + If(n < 9, e"\tAlt+" + HB_NtoS(n), If(n == Len(saTab), e"\tAlt+9", "")))
    NEXT

    xCheckMenuItem(nHMenu, PdfView.Tabs.VALUE)

    IF lMouse
      HMG_GetCursorPos(NIL, @nRow, @nCol)
    ELSE
      nRow := GetWindowRow(PdfView.Tabs.HANDLE) + GetWindowHeight(PdfView.Tabs.HANDLE)
      nCol := GetWindowCol(PdfView.Tabs.HANDLE)
    ENDIF

    slMenuActive := .T.
    SetOnKey(.F.)

    nCmd := TrackPopupMenu2(nHMenu, 0x0180 /*TPM_NONOTIFY|TPM_RETURNCMD*/, nRow, nCol, PdfView.HANDLE)

    DestroyMenu(nHMenu)
    SetOnKey(.T.)
    slMenuActive := .F.

    IF nCmd > 0
      TabChange(nCmd)
    ENDIF
  ENDIF

RETURN NIL


FUNCTION SetFocusNextCtl(lPrevious)
  LOCAL nHFocus := GetFocus()
  LOCAL cPanel  := PanelName()
  LOCAL nHFrame := Sumatra_FrameHandle(cPanel)
  LOCAL nHBook

  IF nHFrame != 0
    nHBook := Sumatra_BookmarksHandle(cPanel)

    IF nHFocus == PdfView.Files.HANDLE
      SetFocus(If(lPrevious, nHFrame, If(Sumatra_Bookmarks(cPanel), nHBook, nHFrame)))
    ELSEIF nHFocus == nHBook
      SetFocus(If(lPrevious, PdfView.Files.HANDLE, nHFrame))
    ELSE
      SetFocus(If(lPrevious, If(Sumatra_Bookmarks(cPanel), nHBook, PdfView.Files.HANDLE), PdfView.Files.HANDLE))
    ENDIF
  ENDIF

RETURN NIL


FUNCTION PdfViewResize(lAll)
  LOCAL cPanel  := PanelName()
  LOCAL nMainCW := GetProperty("PdfView", "CLIENTAREAWIDTH")
  LOCAL nMainCH := GetProperty("PdfView", "CLIENTAREAHEIGHT") - GetWindowHeight(PdfView.STATUSBAR.HANDLE)
  LOCAL nFilesW := PdfView.Files.WIDTH
  LOCAL nTabsH  := If(PdfView.Tabs.VISIBLE, PdfView.Tabs.HEIGHT, 0)
  LOCAL nFrameW := (GetProperty(cPanel, "WIDTH") - GetProperty(cPanel, "CLIENTAREAWIDTH")) / 2 - GetBorderWidth()

  IF lAll
    IF (nMainCW - nFilesW) < (200 - nFrameW)
      nFilesW := nMainCW - 200 - nFrameW
      PdfView.Files.WIDTH := nFilesW
    ENDIF

    PdfView.Files.HEIGHT := nMainCH
    PdfView.Files.ColumnWIDTH(1) := nFilesW - 4 - If(PdfView.Files.ITEMCOUNT > ListViewGetCountPerPage(PdfView.Files.HANDLE), GetVScrollBarWidth(), 0)

    PdfView.Tabs.COL   := nFilesW
    PdfView.Tabs.WIDTH := nMainCW - nFilesW

    SendMessage(PdfView.Files.HANDLE, 0x1013 /*LVM_ENSUREVISIBLE*/, PdfView.Files.VALUE - 1, 0)
  ENDIF

  SetProperty(cPanel, "ROW", ClientToScreenRow(GetParent(GetFormHandle(cPanel)), nTabsH) - GetWindowHeight(PdfView.STATUSBAR.HANDLE) - GetBorderHeight() / 2)
  SetProperty(cPanel, "COL", ClientToScreenCol(GetParent(GetFormHandle(cPanel)), nFilesW - 1))
  SetProperty(cPanel, "WIDTH", nMainCW - (nFilesW - 1) + nFrameW)
  SetProperty(cPanel, "HEIGHT", nMainCH - nTabsH)

  Sumatra_FrameAdjust(cPanel)

RETURN NIL


FUNCTION PanelNew()
  LOCAL nPanel
  LOCAL cPanel

  IF (Len(saTab) == 1) .and. saPanel[saTab[1]]
    nPanel := saTab[1]
  ELSE
    nPanel := aScan(saPanel, .T.)
  ENDIF

  IF nPanel == 0
    aAdd(saPanel, .T.)

    nPanel := Len(saPanel)
    cPanel := PanelName(nPanel)

    DEFINE WINDOW &cPanel;
      PARENT   PdfView;
      ROW      0xFFFF;
      COL      0xFFFF;
      WIDTH    0;
      HEIGHT   0;
      PANEL;
      ON PAINT Sumatra_FrameRedraw(cPanel)
    END WINDOW
    SetProperty(cPanel, "VISIBLE", .F.)

    HMG_ChangeWindowStyle(GetFormHandle(cPanel), WS_SIZEBOX, NIL, .F., .F.)
    ChangeWindowMessageFilter(GetFormHandle(cPanel), 74 /*WM_COPYDATA*/, 1 /*MSGFLT_ALLOW*/)
  ENDIF

RETURN nPanel


FUNCTION PanelName(nPanel)

  IF ! HB_IsNumeric(nPanel)
    nPanel := saTab[PdfView.Tabs.VALUE]
  ENDIF

  IF (nPanel > 0) .and. (nPanel <= Len(saPanel))
    RETURN "P" + HB_NtoS(nPanel)
  ENDIF

RETURN ""


FUNCTION PanelShow(nPanel, lShow)
  LOCAL nHWnd := GetFormHandle(PanelName(nPanel))

  IF lShow
    ShowWindow(nHWnd)
  ELSE
    SetWindowPos(nHWnd, 0, 0xFFFF, 0xFFFF, 0, 0, 0x94 /*SWP_HIDEWINDOW|SWP_NOACTIVATE|SWP_NOZORDER*/)
  ENDIF

RETURN NIL


FUNCTION TabNew(nPanel)
  LOCAL nTab := Len(saTab) + 1

  aAdd(saTab, nPanel)
  PdfView.Tabs.AddPage(nTab, "")

  PdfView.Tabs.VALUE   := nTab
  PdfView.Tabs.VISIBLE := (nTab > 1)

RETURN NIL


FUNCTION TabChange(nTabNew)
  LOCAL nTabCurr
  LOCAL lFileFocus

  IF Len(saTab) > 1
    nTabCurr := PdfView.Tabs.VALUE

    IF nTabNew == 0 //last tab
      nTabNew := Len(saTab)
    ELSEIF nTabNew == -1 //next tab
      IF nTabCurr == Len(saTab)
        nTabNew := 1
      ELSE
        nTabNew := nTabCurr + 1
      ENDIF
    ELSEIF nTabNew == -2 //previous tab
      IF nTabCurr == 1
        nTabNew := Len(saTab)
      ELSE
        nTabNew := nTabCurr - 1
      ENDIF
    ENDIF

    IF (nTabNew != nTabCurr) .and. (nTabNew <= Len(saTab))
      lFileFocus := (GetFocus() == PdfView.Files.HANDLE)
      PdfView.Tabs.VALUE := nTabNew

      PanelShow(saTab[nTabCurr], .F.)
      PanelShow(saTab[nTabNew],  .T.)
      PdfViewResize(.F.)
      StatusSetFile()

      IF slTabGoToFile
        FileGoTo()
      ENDIF

      SetFocus(If(lFileFocus, PdfView.Files.HANDLE, Sumatra_FrameHandle(PanelName(saTab[nTabNew]))))
    ENDIF
  ENDIF

RETURN NIL


FUNCTION TabClose(nTab)
  LOCAL lFileFocus := (GetFocus() == PdfView.Files.HANDLE)
  LOCAL nTabCurr   := PdfView.Tabs.VALUE
  LOCAL cPanel

  IF ! HB_IsNumeric(nTab)
    nTab := nTabCurr
  ENDIF

  cPanel := PanelName(saTab[nTab])
  saPanel[saTab[nTab]] := .T.

  IF nTab == nTabCurr
    GetSumatraSettings()
  ENDIF

  RecentAdd(Sumatra_FileName(cPanel), Sumatra_PageNumber(cPanel))
  Sumatra_FileClose(cPanel, .T.)

  IF Len(saTab) > 1
    IF nTab == nTabCurr
      PanelShow(saTab[nTab], .F.)

      IF nTab == Len(saTab)
        --nTabCurr
      ENDIF
    ELSEIF nTab < nTabCurr
      --nTabCurr
    ENDIF

    HB_aDel(saTab, nTab, .T.)
    PdfView.Tabs.DeletePage(nTab)
    PdfView.Tabs.VALUE := nTabCurr

    PanelShow(saTab[nTabCurr], .T.)
  ENDIF

  PdfView.Tabs.VISIBLE := (Len(saTab) > 1)

  PdfViewResize(.F.)
  StatusSetFile()

  IF lFileFocus .or. (Sumatra_FrameHandle(PanelName(saTab[nTabCurr])) == 0)
    PdfView.Files.SETFOCUS
  ELSE
    SetFocus(Sumatra_FrameHandle(PanelName(saTab[nTabCurr])))
  ENDIF

RETURN NIL


FUNCTION TabCloseAllEmpty()
  LOCAL n

  FOR n := 1 TO Len(saTab)
    IF Sumatra_FrameHandle(PanelName(saTab[n])) == 0
      TabClose(n)
    ENDIF
  NEXT

RETURN NIL


FUNCTION FileListRefresh(cFileSel)
  LOCAL nSel := 1
  LOCAL aFile
  LOCAL nLen
  LOCAL n

  EnableWindowRedraw(PdfView.Files.HANDLE, .F.)
  PdfView.Files.DELETEALLITEMS

  IF ! Empty(scFileDir)
    IF VolSerial(HB_ULeft(scFileDir, 3)) == -1
      cFileSel  := HB_ULeft(scFileDir, 2)
      scFileDir := ""
    ELSE
      DO WHILE ! HB_DirExists(scFileDir)
        cFileSel  := ""
        scFileDir := DirParent(scFileDir)
      ENDDO
    ENDIF
  ENDIF

  IF Empty(scFileDir)
    FOR n := 65 TO 90 //from "A" to "Z"
      IF IsDisk(Chr(n))
        PdfView.Files.AddItem({Chr(n) + ":", 0, "", "", "DK"})

        IF (Chr(n) + ":") == cFileSel
          nSel := PdfView.Files.ITEMCOUNT
        ENDIF
      ENDIF
    NEXT

  ELSE
    aFile := Directory(scFileDir + "*.*", "DHS")

    FOR n := Len(aFile) TO 1 STEP -1
      IF "D" $ aFile[n][F_ATTR]
        IF (aFile[n][F_NAME] == ".") .or. (aFile[n][F_NAME] == "..")
          HB_aDel(aFile, n, .T.)
        ENDIF
      ELSEIF HMG_StrCmp(HB_FNameExt(aFile[n][F_NAME]), ".pdf", .F.) != 0
        HB_aDel(aFile, n, .T.)
      ENDIF
    NEXT

    aSort(aFile, NIL, NIL, ;
          {|a1, a2|
            IF ("D" $ a1[F_ATTR]) .and. (! ("D" $ a2[F_ATTR]))
              RETURN .T.
            ELSEIF (! ("D" $ a1[F_ATTR])) .and. ("D" $ a2[F_ATTR])
              RETURN .F.
            ENDIF
            RETURN (HMG_StrCmp(a1[F_NAME], a2[F_NAME], .F.) < 0)
          })

    HB_aIns(aFile, 1, {"..", 0, "", "", "D"}, .T.)

    nLen := Len(aFile)

    FOR n := 1 TO nLen
      IF "D" $ aFile[n][F_ATTR]
        aFile[n][F_NAME] := "<" + aFile[n][F_NAME] + ">"
      ENDIF

      PdfView.Files.AddItem(aFile[n])

      IF aFile[n][F_NAME] == cFileSel
        nSel := n
      ENDIF
    NEXT
  ENDIF

  EnableWindowRedraw(PdfView.Files.HANDLE, .T., .T.)

  PdfView.Files.VALUE := nSel
  PdfView.Files.ColumnWIDTH(1) := PdfView.Files.WIDTH - 4 - If(PdfView.Files.ITEMCOUNT > ListViewGetCountPerPage(PdfView.Files.HANDLE), GetVScrollBarWidth(), 0)
  PdfView.Files.Header(1) := If(Empty(scFileDir), "Disk", scFileDir)

RETURN NIL


FUNCTION FileGoTo()
  LOCAL cFile
  LOCAL cDir
  LOCAL nCount
  LOCAL n

  IF ! saPanel[saTab[PdfView.Tabs.VALUE]]
    cFile := Sumatra_FileName(PanelName())

    IF HB_FileExists(cFile)
      cDir  := HB_fNameDir(cFile)
      cFile := HB_fNameNameExt(cFile)

      IF HMG_StrCmp(cDir, scFileDir, .F.) == 0
        nCount := PdfView.Files.ITEMCOUNT

        FOR n := 1 TO nCount
          IF HMG_StrCmp(cFile, PdfView.Files.Cell(n, F_NAME), .F.) == 0
            PdfView.Files.VALUE := n
            EXIT
          ENDIF
        NEXT

      ELSE
        scFileDir := cDir
        FileListRefresh(cFile)
      ENDIF
    ENDIF
  ENDIF

RETURN NIL


FUNCTION FileOpen(cFile, lAtPage, lNewTab)
  LOCAL lRecentFile := .F.
  LOCAL nPage
  LOCAL nPos
  LOCAL lFileFocus
  LOCAL cSumatraExe
  LOCAL cRecentFile
  LOCAL nRecentPage
  LOCAL nPanel

  IF HB_IsChar(cFile)
    lRecentFile := .T.
  ELSE
    cFile := PdfView.Files.Cell(PdfView.Files.VALUE, F_NAME)

    IF "D" $ PdfView.Files.Cell(PdfView.Files.VALUE, F_ATTR)
      IF "K" $ PdfView.Files.Cell(PdfView.Files.VALUE, F_ATTR)
        IF VolSerial(DirSepAdd(cFile)) == -1
          MsgWin(cFile + CRLF + CRLF + LangStr("NoDisk"))
        ELSE
          scFileDir := DirSepAdd(cFile)
          cFile     := ""
        ENDIF
      ELSE
        cFile := HB_USubstr(cFile, 2, Len(cFile) - 2)

        IF cFile == ".."
          IF Len(scFileDir) == 3
            cFile := DirSepDel(scFileDir)
          ELSE
            cFile := "<" + HB_FNameNameExt(DirSepDel(scFileDir)) + ">"
          ENDIF
          scFileDir := DirParent(scFileDir)
        ELSE
          scFileDir := DirSepAdd(scFileDir + cFile)
          cFile    := ""
        ENDIF
      ENDIF

      FileListRefresh(cFile)
      RETURN NIL
    ENDIF

    cFile := scFileDir + cFile
  ENDIF

  IF HB_IsLogical(lAtPage) .and. lAtPage
    nPage := InputPageNum()

    IF HB_IsNIL(nPage)
      RETURN NIL
    ENDIF
  ELSE
    IF HMG_StrCmp(cFile, Sumatra_FileName(PanelName()), .F.) == 0
      nPage := Sumatra_PageNumber(PanelName())
    ELSE
      nPos  := HB_aScan(saRecent, {|aFile| HMG_StrCmp(aFile[1], cFile, .F.) == 0})
      nPage := If(nPos > 0, saRecent[nPos][2], 1)
    ENDIF
  ENDIF

  GetSumatraSettings()

  lFileFocus  := (GetFocus() == PdfView.Files.HANDLE)
  cSumatraExe := "SumatraPDF.exe"

  IF HB_IsLogical(lNewTab) .and. lNewTab
    nPanel := PanelNew()
  ELSE
    nPanel := saTab[PdfView.Tabs.VALUE]
  ENDIF

  IF nPanel == saTab[PdfView.Tabs.VALUE]
    cRecentFile := Sumatra_FileName(PanelName())
    nRecentPage := Sumatra_PageNumber(PanelName())
  ELSE
    PanelShow(nPanel, .T.)
  ENDIF

  nPage := Sumatra_FileOpen(PanelName(nPanel), cFile, nPage, snZoom, slBookmarks, slToolbar, scLang, If(Empty(scSumatraDir), HB_DirBase(), scSumatraDir) + cSumatraExe)

  SWITCH nPage
    CASE -1
      //MsgWin("Panel window is not defined!")
      EXIT
    CASE -2
      IF nPanel != saTab[PdfView.Tabs.VALUE]
        PanelShow(nPanel, .F.)
      ENDIF

      MsgWin(If(Empty(scSumatraDir), HB_DirBase(), DirSepAdd(TrueName(scSumatraDir))) + cSumatraExe + CRLF + CRLF + LangStr("NoFile") + CRLF + LangStr("SetPath") + ": " + cSumatraExe + ".")
      InputSumatraDir()
      EXIT
    CASE -3
      IF nPanel != saTab[PdfView.Tabs.VALUE]
        PanelShow(nPanel, .F.)
      ENDIF

      MsgWin(cFile + CRLF + CRLF + LangStr("NoFile") + If(lRecentFile, "", CRLF + LangStr("ListRefresh")))

      IF ! lRecentFile
        FileListRefresh("")
      ENDIF
      EXIT
    OTHERWISE
      saPanel[nPanel] := .F.

      IF nPanel == saTab[PdfView.Tabs.VALUE]
        RecentAdd(cRecentFile, nRecentPage)
      ELSE
        PanelShow(NIL, .F.)
        TabNew(nPanel)
        PdfViewResize(.F.)
      ENDIF

      StatusSetFile()
      SetFocus(If(lFileFocus, PdfView.Files.HANDLE, Sumatra_FrameHandle(PanelName())))
  ENDSWITCH

RETURN NIL


/*
  SessionOpen(nAction, [aFiles])
  nAction:
    1 - on start - open files passed from commad line
    2 - open files passed via WM_COPYDATA (aFiles parameter is required)
    3 - on start - restore last session
    4 - open last session when program already is running
*/
FUNCTION SessionOpen(nAction, aFiles)
  LOCAL nCount     := 0
  LOCAL lFileFocus := (GetFocus() == PdfView.Files.HANDLE)
  LOCAL nTabCurr   := PdfView.Tabs.VALUE
  LOCAL nPanel
  LOCAL nStart
  LOCAL nEnd
  LOCAL cFile
  LOCAL nPage
  LOCAL nPos
  LOCAL n

  GetSumatraSettings()

  IF (nAction == 1)
    nStart := 1
    nEnd   := HB_ArgC()
  ELSEIF (nAction == 2)
    nStart := 2
    nEnd   := Len(aFiles)
  ELSEIF (nAction == 3) .and. slSessionRest .or. (nAction == 4)
    nStart := 2
    nEnd   := Len(saSession)
  ELSE
    nStart := 1
    nEnd   := 0
  ENDIF

  FOR n := nStart TO nEnd
    nPanel := PanelNew()

    IF nPanel != saTab[PdfView.Tabs.VALUE]
      PanelShow(nPanel, .T.)
    ENDIF

    IF (nAction == 1)
      cFile := HB_ArgV(n)

      IF HB_ULeft(cFile, 1) == "\"
        cFile := HB_ULeft(scDirStart, 2) + cFile
      ELSEIF ! (HB_USubstr(cFile, 2, 1) == ":")
        cFile := scDirStart + cFile
      ENDIF

      nPos  := HB_aScan(saRecent, {|aFile| HMG_StrCmp(aFile[1], cFile, .F.) == 0})
      nPage := If(nPos > 0, saRecent[nPos][2], 1)
    ELSEIF (nAction == 2)
      cFile := aFiles[n]

      IF HB_ULeft(cFile, 1) == "\"
        cFile := HB_ULeft(aFiles[1], 2) + cFile
      ELSEIF ! (HB_USubstr(cFile, 2, 1) == ":")
        cFile := aFiles[1] + cFile
      ENDIF

      nPos  := HB_aScan(saRecent, {|aFile| HMG_StrCmp(aFile[1], cFile, .F.) == 0})
      nPage := If(nPos > 0, saRecent[nPos][2], 1)
    ELSE
      cFile := saSession[n][1]
      nPage := saSession[n][2]
    ENDIF

    IF Sumatra_FileOpen(PanelName(nPanel), cFile, nPage, snZoom, slBookmarks, slToolbar, scLang, If(Empty(scSumatraDir), HB_DirBase(), scSumatraDir) + "SumatraPDF.exe") >= 0
      ++nCount
      saPanel[nPanel] := .F.

      IF nPanel != saTab[PdfView.Tabs.VALUE]
        PanelShow(NIL, .F.)
        TabNew(nPanel)
        PdfViewResize(.F.)
      ENDIF

      StatusSetFile()

      IF (nAction > 2) .and. (nCount <= saSession[1][2])
        nTabCurr := PdfView.Tabs.VALUE
      ENDIF
    ELSE
      IF nPanel != saTab[PdfView.Tabs.VALUE]
        PanelShow(nPanel, .F.)
      ENDIF
    ENDIF
  NEXT

  IF (nAction > 2) .and. (nCount > 0) .and. (nTabCurr != PdfView.Tabs.VALUE)
    TabChange(nTabCurr)
  ENDIF

  IF (nAction == 2) .or. (nAction == 4)
    IF lFileFocus .or. (Sumatra_FrameHandle(PanelName()) == 0)
      PdfView.Files.SETFOCUS
    ELSE
      SetFocus(Sumatra_FrameHandle(PanelName()))
    ENDIF
  ENDIF

RETURN (nCount > 0)


FUNCTION SessionReopen()
  LOCAL lFileFocus := (GetFocus() == PdfView.Files.HANDLE)
  LOCAL nTab       := 1
  LOCAL nTabCurr   := PdfView.Tabs.VALUE
  LOCAL nCount     := Len(saTab)
  LOCAL cFile
  LOCAL nPage
  LOCAL cPanel
  LOCAL n

  FOR n := 1 TO nCount
    TabChange(nTab)

    cPanel := PanelName()
    cFile  := Sumatra_FileName(cPanel)

    IF ! Empty(cFile)
      nPage := Sumatra_PageNumber(cPanel)

      GetSumatraSettings()

      nPage := Sumatra_FileOpen(cPanel, cFile, nPage, snZoom, slBookmarks, slToolbar, scLang, If(Empty(scSumatraDir), HB_DirBase(), scSumatraDir) + "SumatraPDF.exe")

      IF nPage >= 0
        ++nTab
      ELSE
        TabClose(nTab)

        IF nTab < nTabCurr
          --nTabCurr
        ENDIF
      ENDIF
    ENDIF
  NEXT

  IF nTabCurr > Len(saTab)
    nTabCurr := Len(saTab)
  ENDIF

  TabChange(nTabCurr)
  StatusSetPage(.T.)

  IF lFileFocus .or. (Sumatra_FrameHandle(PanelName()) == 0)
    PdfView.Files.SETFOCUS
  ELSE
    SetFocus(Sumatra_FrameHandle(PanelName()))
  ENDIF

RETURN NIL


FUNCTION RecentAdd(cFile, nPage)
  LOCAL nPos

  IF (snRecentAmount > 0) .and. (! Empty(cFile)) .and. (! Empty(nPage))
    nPos := HB_aScan(saRecent, {|aFile| HMG_StrCmp(aFile[1], cFile, .F.) == 0})

    IF nPos > 0
      HB_aDel(saRecent, nPos, .T.)
    ENDIF

    HB_aIns(saRecent, 1, {cFile, nPage}, (Len(saRecent) < snRecentAmount))
  ENDIF

RETURN NIL


FUNCTION StatusSetFile()
  LOCAL cFile := Sumatra_FileName(PanelName())

  IF Empty(cFile)
    PdfView.TITLE := "PdfView"
    PdfView.Tabs.Caption(PdfView.Tabs.VALUE) := ""
    PdfView.STATUSBAR.Item(1) := ""
  ELSE
    PdfView.TITLE := "PdfView: " + HB_fNameNameExt(cFile)
    PdfView.Tabs.Caption(PdfView.Tabs.VALUE) := HB_fNameName(cFile)
    PdfView.STATUSBAR.Item(1) := cFile
  ENDIF

RETURN NIL


FUNCTION StatusSetPage(lForce)
  STATIC nPage   := 0
  STATIC nCount  := 0
  LOCAL  nPage1  := Sumatra_PageNumber(PanelName())
  LOCAL  nCount1 := Sumatra_PageCount(PanelName())

  IF lForce .or. (nPage != nPage1) .or. (nCount != nCount1)
    nPage  := nPage1
    nCount := nCount1

    PdfView.STATUSBAR.Item(2) := If(nCount == 0, "", LangStr("Page", .T.) + ": " + HB_NtoS(nPage) + "/" + HB_NtoS(nCount))
  ENDIF

  RELEASE MEMORY

RETURN NIL


FUNCTION SetZoom(nZoomNew)

  IF Sumatra_PageCount(PanelName()) > 0
    snZoom := nZoomNew
    Sumatra_Zoom(PanelName(), snZoom)
  ENDIF

RETURN NIL


FUNCTION GetSumatraSettings()
  LOCAL cPanel := PanelName()
  LOCAL nHToolbar

  IF Sumatra_FrameHandle(cPanel) != 0
    IF Sumatra_PageCount(cPanel) > 0
      nHToolbar := Sumatra_ToolbarHandle(cPanel)

      IF HB_BitAnd(SendMessage(nHToolbar, 1042 /*TB_GETSTATE*/, 3027 /*IDT_VIEW_FIT_PAGE*/, 0), 0x01 /*TBSTATE_CHECKED*/) != 0
        snZoom := 2
      ELSEIF HB_BitAnd(SendMessage(nHToolbar, 1042 /*TB_GETSTATE*/, 3026 /*IDT_VIEW_FIT_WIDTH*/, 0), 0x01 /*TBSTATE_CHECKED*/) != 0
        snZoom := 4
      ENDIF
    ENDIF

    IF Sumatra_BookmarksExist(cPanel)
      slBookmarks := Sumatra_Bookmarks(cPanel)
    ENDIF

    slToolbar := Sumatra_Toolbar(cPanel)
  ENDIF

RETURN NIL


FUNCTION InputPageNum()
  LOCAL nPage

  DEFINE WINDOW InputPage;
    WIDTH  230 + GetSystemMetrics(7 /*SM_CXFIXEDFRAME*/) * 2;
    HEIGHT  74 + GetSystemMetrics(4 /*SM_CYCAPTION*/) + GetSystemMetrics(8 /*SM_CYFIXEDFRAME*/) * 2;
    TITLE  LangStr("OpenFilePage");
    MODAL;
    NOSIZE

    DEFINE LABEL PageNumber
      ROW       13
      COL       45
      WIDTH     90
      HEIGHT    13
      ALIGNMENT RIGHT
      VALUE     LangStr("PageNum") + ":"
    END LABEL

    DEFINE TEXTBOX Number
      ROW          10
      COL         140
      WIDTH        40
      HEIGHT       21
      VALUE         1
      MAXLENGTH     5
      RIGHTALIGN  .T.
      DATATYPE    NUMERIC
      ONENTER     ((nPage := InputPage.Number.VALUE), InputPage.RELEASE)
    END TEXTBOX

    DEFINE BUTTON Open
      ROW     41
      COL     40
      WIDTH   70
      HEIGHT  23
      CAPTION LangStr("Open")
      ACTION  ((nPage := InputPage.Number.VALUE), InputPage.RELEASE)
      DEFAULT .T.
    END BUTTON

    DEFINE BUTTON Cancel
      ROW      41
      COL     120
      WIDTH    70
      HEIGHT   23
      CAPTION LangStr("Cancel")
      ACTION  InputPage.RELEASE
    END BUTTON
  END WINDOW

  C_Center(InputPage.HANDLE, .T.)
  ON KEY ESCAPE OF InputPage ACTION InputPage.RELEASE

  InputPage.ACTIVATE

  IF HB_IsNumeric(nPage) .and. (nPage < 1)
    nPage := 1
  ENDIF

RETURN nPage


FUNCTION InputSumatraDir()
  LOCAL cDir

  DEFINE WINDOW InputDir;
    WIDTH  250 + GetSystemMetrics(7 /*SM_CXFIXEDFRAME*/) * 2;
    HEIGHT  74 + GetSystemMetrics(4 /*SM_CYCAPTION*/) + GetSystemMetrics(8 /*SM_CYFIXEDFRAME*/) * 2;
    TITLE  LangStr("SumatraDir", .T.);
    MODAL;
    NOSIZE

    DEFINE TEXTBOX Dir
      ROW         10
      COL         10
      WIDTH       230
      HEIGHT      21
      VALUE       scSumatraDir
      MAXLENGTH   260
      DATATYPE    CHARACTER
      ONENTER     ((cDir := InputDir.Dir.VALUE), InputDir.RELEASE)
    END TEXTBOX

    DEFINE BUTTON Browse
      ROW     41
      COL     10
      WIDTH   70
      HEIGHT  23
      CAPTION LangStr("Browse") + "..."
      ACTION  BrowseForSumatraDir()
    END BUTTON

    DEFINE BUTTON OK
      ROW     41
      COL     90
      WIDTH   70
      HEIGHT  23
      CAPTION LangStr("OK")
      ACTION  ((cDir := InputDir.Dir.VALUE), InputDir.RELEASE)
      DEFAULT .T.
    END BUTTON

    DEFINE BUTTON Cancel
      ROW     41
      COL     170
      WIDTH   70
      HEIGHT  23
      CAPTION LangStr("Cancel")
      ACTION  InputDir.RELEASE
    END BUTTON
  END WINDOW

  C_Center(InputDir.HANDLE, .T.)
  ON KEY ESCAPE OF InputDir ACTION InputDir.RELEASE

  InputDir.ACTIVATE

  IF HB_IsString(cDir)
    scSumatraDir := DirSepAdd(cDir)
  ENDIF

RETURN NIL


FUNCTION BrowseForSumatraDir()
  LOCAL cDir := DirSepAdd(TrueName(InputDir.Dir.VALUE))

  IF ! HB_DirExists(cDir)
    cDir := HB_DirBase()
  ENDIF

  cDir := DirSepAdd(C_BrowseForFolder(NIL, CRLF + LangStr("SelFolder") + ":", HB_BitOr(BIF_NEWDIALOGSTYLE, BIF_NONEWFOLDERBUTTON), NIL, cDir))

  IF ! Empty(cDir)
    InputDir.Dir.VALUE := cDir
    InputDir.Dir.SETFOCUS
  ENDIF

RETURN NIL


FUNCTION AboutPdfView()
  LOCAL nCW, nW1, nW2

  DEFINE WINDOW About;
    WIDTH  270 + GetSystemMetrics(7 /*SM_CXFIXEDFRAME*/) * 2;
    HEIGHT 188 + GetSystemMetrics(4 /*SM_CYCAPTION*/) + GetSystemMetrics(8 /*SM_CYFIXEDFRAME*/) * 2;
    TITLE  LangStr("AboutPdfView");
    MODAL;
    NOSIZE;
    ON MOUSECLICK About.RELEASE

    DEFINE LABEL Label1
      ROW       10
      COL       0
      HEIGHT    32
      FONTNAME  "Times New Roman"
      FONTSIZE  22
      FONTBOLD  .T.
      VALUE     "PdfView"
    END LABEL

    DEFINE LABEL Label2
      ROW    25
      COL    0
      HEIGHT 13
      VALUE  "v." + PDFVIEW_VERSION + " (" + LTrim(Str(HB_Version(17 /*HB_VERSION_BITWIDTH*/))) + "-bit)"
    END LABEL

    DEFINE LABEL Label3
      ROW    50
      COL    0
      HEIGHT 13
      VALUE  LangStr("PdfViewUsing") + ":"
    END LABEL

    DEFINE HYPERLINK Link
      ROW        50
      COL        0
      HEIGHT     13
      HANDCURSOR .T.
      VALUE      "SumatraPDF"
      ADDRESS    "https://www.sumatrapdfreader.org"
    END HYPERLINK

    DEFINE LABEL Label4
      ROW        80
      COL        -2
      WIDTH      274
      HEIGHT     43
      CLIENTEDGE .T.
      VALUE      CRLF + LangStr("Author") + ": Krzysztof Janicki aka KDJ"
    END LABEL

    DEFINE LABEL Label5
      ROW        121
      COL        -2
      WIDTH      274
      HEIGHT     69
      CLIENTEDGE .T.
      VALUE      CRLF + Chr(9) + ;
                 LangStr("Translators") + ":"        + CRLF + Chr(9) + Space(4) + ;
                 "Pablo César (Portuguese, Spanish)" + CRLF + Chr(9) + Space(4) + ;
                 "Krzysztof Janicki (Polish, Russian)"
    END LABEL
  END WINDOW

  nCW := GetProperty("About", "CLIENTAREAWIDTH")

  nW1 := GetTextWidth(, About.Label1.VALUE, GetWindowFont(About.Label1.HANDLE))
  nW2 := GetTextWidth(, About.Label2.VALUE, GetWindowFont(About.Label2.HANDLE))

  About.Label1.WIDTH := nW1
  About.Label2.WIDTH := nW2

  About.Label1.COL   := Int((nCW - nW1 - nW2 - 10) / 2)
  About.Label2.COL   := About.Label1.COL + nW1 + 10

  nW1 := GetTextWidth(, About.Label3.VALUE, GetWindowFont(About.Label3.HANDLE))
  nW2 := GetTextWidth(, About.Link.VALUE,   GetWindowFont(About.Link.HANDLE))

  About.Label3.WIDTH := nW1
  About.Link.WIDTH   := nW2
  About.Label3.COL   := Int((nCW - nW1 - nW2 - 5) / 2)
  About.Link.COL     := About.Label3.COL + nW1 + 5

  HMG_ChangeWindowStyle(About.Label4.HANDLE, 0x0001 /*SS_CENTER*/, NIL, .F., .F.)

  About.Center()
  About.ACTIVATE

RETURN NIL


FUNCTION MsgWin(aMsg)
  LOCAL cMsg := ""
  LOCAL nHDC
  LOCAL nHFont
  LOCAL cLine
  LOCAL nLaW, nLaH
  LOCAL nCAW

  IF HB_IsString(aMsg)
    aMsg := HB_aTokens(aMsg, .T. /*lEOL*/)
  ENDIF

  IF IsWindowVisible(App.Handle)
    DEFINE WINDOW MsgWnd;
      MODAL;
      NOSIZE
  ELSE
    DEFINE WINDOW MsgWnd;
      CHILD;
      NOMINIMIZE;
      NOMAXIMIZE;
      NOSIZE
  ENDIF

    DEFINE LABEL MsgText
      ROW 10
    END LABEL

    DEFINE BUTTON OK
      WIDTH   80
      HEIGHT  23
      CAPTION LangStr("OK")
      ACTION  MsgWnd.RELEASE
    END BUTTON
  END WINDOW

  nHDC   := GetDC(MsgWnd.MsgText.HANDLE)
  nHFont := GetWindowFont(MsgWnd.MsgText.HANDLE)
  nLaW   := 100

  FOR EACH cLine IN aMsg
    nLaW := Max(nLaW, GetTextWidth(nHDC, cLine, nHFont))
    cMsg += cLine + CRLF
  NEXT

  nLaH := GetTextHeight(nHDC, aMsg[1], nHFont) * Len(aMsg)

  ReleaseDC(MsgWnd.MsgText.HANDLE, nHDC)

  nCAW := nLaW + 20

  MsgWnd.WIDTH  := nCAW + (MsgWnd.WIDTH - GetProperty("MsgWnd", "CLIENTAREAWIDTH"))
  MsgWnd.HEIGHT := nLaH + 53 + (MsgWnd.HEIGHT - GetProperty("MsgWnd", "CLIENTAREAHEIGHT"))
  MsgWnd.TITLE  := "PdfView"

  MsgWnd.MsgText.COL     := Int((nCAW - nLaW) / 2)
  MsgWnd.MsgText.WIDTH   := nLaW
  MsgWnd.MsgText.HEIGHT  := nLaH
  MsgWnd.MsgText.CAPTION := cMsg

  MsgWnd.OK.ROW := nLaH + 20
  MsgWnd.OK.COL := Int((nCAW - 80) / 2)

  C_Center(MsgWnd.HANDLE, .T.)
  //EventCreate({ || If(LoWord(EventWPARAM()) == 2 /*IDCANCEL*/, MsgWnd.RELEASE, NIL) }, MsgWnd.HANDLE, 273 /*WM_COMMAND*/)

  MsgWnd.ACTIVATE

RETURN NIL


FUNCTION RecentFiles()
  LOCAL lFileFocus := (GetFocus() == PdfView.Files.HANDLE)
  LOCAL aFile

  DEFINE WINDOW Recent;
    ROW    0;
    COL    0;
    WIDTH  snRecent_W;
    HEIGHT snRecent_H;
    TITLE  LangStr("RecentFiles", .T.);
    MODAL;
    ON PAINT   PaintSizeGrip(Recent.HANDLE);
    ON SIZE    RecentResize();
    ON RELEASE ((snRecent_W := Recent.WIDTH), (snRecent_H := Recent.HEIGHT), RecentAmount(.F.))

    DEFINE GRID Files
      ROW            10
      COL            10
      SHOWHEADERS    .F.
      WIDTHS         {0}
      CELLNAVIGATION .F.
      ONDBLCLICK     RecentFileOpen((GetKeyState(VK_CONTROL) < 0), (GetKeyState(VK_SHIFT) < 0))
      ONCHANGE       RecentCount()
      //ONKEY          RecentFilesOnKey()
    END GRID

    DEFINE CHECKBOX Names
      COL      15
      WIDTH    90
      HEIGHT   16
      CAPTION  LangStr("OnlyNames")
      VALUE    slRecentNames
      ONCHANGE RecentNames()
    END CHECKBOX

    DEFINE LABEL Count
      WIDTH     60
      HEIGHT    13
      ALIGNMENT RIGHT
    END LABEL

    DEFINE LABEL AmountLabel
      ROW    10
      COL    10
      HEIGHT 13
      VALUE  LangStr("FilesAmount") + ":"
    END LABEL

    DEFINE SPINNER Amount
      ROW         0
      COL         0
      WIDTH       40
      HEIGHT      21
      RANGEMIN    0
      RANGEMAX    999
      VALUE       snRecentAmount
      ONLOSTFOCUS RecentAmount(.T.)
    END SPINNER

    DEFINE BUTTON Open
      WIDTH         90
      HEIGHT        23
      CAPTION       LangStr("Open")
      PICTURE       "BUTTONARROW"
      PICTALIGNMENT RIGHT
      ACTION        RecentOpenMenu()
    END BUTTON

    DEFINE BUTTON Remove
      WIDTH         90
      HEIGHT        23
      CAPTION       LangStr("Remove")
      PICTURE       "ButtonArrow"
      PICTALIGNMENT RIGHT
      ACTION        RecentRemoveMenu()
    END BUTTON
  END WINDOW

  ListView_ChangeExtendedStyle(Recent.Files.HANDLE, LVS_EX_INFOTIP)

  FOR EACH aFile IN saRecent
    Recent.Files.AddItem({If(slRecentNames, HB_fNameName(aFile[1]), aFile[1])})
  NEXT

  ON KEY SHIFT+DELETE OF Recent ACTION RecentFilesOnKey()
  Recent.Files.VALUE := 1

  Recent.AmountLabel.WIDTH := GetTextWidth(, LangStr("FilesAmount") + ":", GetWindowFont(Recent.AmountLabel.HANDLE))

  RecentCount()
  RecentButtonsEnable()
  RecentResize()
  Recent.Center()
  Recent.ACTIVATE

  SetFocus(If(lFileFocus, PdfView.Files.HANDLE, Sumatra_FrameHandle(PanelName())))

RETURN NIL


FUNCTION RecentNames()
  LOCAL n

  slRecentNames := Recent.Names.VALUE

  FOR n := 1 TO Len(saRecent)
    Recent.Files.Cell(n, 1) := If(slRecentNames, HB_fNameName(saRecent[n][1]), saRecent[n][1])
  NEXT

RETURN NIL


FUNCTION RecentCount()

  Recent.Count.VALUE := HB_NtoS(Recent.Files.VALUE) + "/" + HB_NtoS(Recent.Files.ITEMCOUNT)

RETURN NIL


FUNCTION RecentAmount(lRefreshList)
  LOCAL n

  snRecentAmount := Recent.Amount.VALUE

  IF snRecentAmount < Len(saRecent)
    IF lRefreshList
      EnableWindowRedraw(Recent.Files.HANDLE, .F.)

      FOR n := Len(saRecent) TO (snRecentAmount + 1) STEP -1
        Recent.Files.DeleteItem(n)
      NEXT

      IF Recent.Files.VALUE == 0
        Recent.Files.VALUE := snRecentAmount
      ENDIF

      EnableWindowRedraw(Recent.Files.HANDLE, .T., .T.)
      RecentCount()
      RecentButtonsEnable()
    ENDIF

    aSize(saRecent, snRecentAmount)
  ENDIF

RETURN NIL


FUNCTION RecentOpenMenu()
  LOCAL aRect  := {0, 0, 0, 0}
  LOCAL nHMenu := CreatePopupMenu()
  LOCAL nCmd

  GetWindowRect(Recent.Open.HANDLE, aRect)

  AppendMenuString(nHMenu, 1, LangStr("OpenCurTab") + e"\tEnter")
  AppendMenuString(nHMenu, 2, LangStr("OpenNewTab") + e"\tShift+Enter")
  AppendMenuSeparator(nHMenu)
  AppendMenuString(nHMenu, 3, LangStr("OpenPage") + e"...\tCtrlt+Enter")
  AppendMenuString(nHMenu, 4, LangStr("OpenPageTab") + e"...\tCtrlt+Shift+Enter")

  nCmd := TrackPopupMenu2(nHMenu, 0x0188 /*TPM_NONOTIFY|TPM_RETURNCMD|TPM_RIGHTALIGN*/, aRect[4], aRect[3], Recent.HANDLE)

  DestroyMenu(nHMenu)

  SWITCH nCmd
    CASE 1
      RecentFileOpen(.F., .F.)
      EXIT
    CASE 2
      RecentFileOpen(.F., .T.)
      EXIT
    CASE 3
      RecentFileOpen(.T., .F.)
      EXIT
    CASE 4
      RecentFileOpen(.T., .T.)
      EXIT
  ENDSWITCH

RETURN NIL


FUNCTION RecentRemoveMenu()
  LOCAL aRect  := {0, 0, 0, 0}
  LOCAL nHMenu := CreatePopupMenu()
  LOCAL nCmd

  GetWindowRect(Recent.Remove.HANDLE, aRect)

  AppendMenuString(nHMenu, 1, LangStr("Selected") + e"\tShift+Del")
  AppendMenuString(nHMenu, 2, LangStr("NonExistent"))
  AppendMenuString(nHMenu, 3, LangStr("All"))

  nCmd := TrackPopupMenu2(nHMenu, 0x0188 /*TPM_NONOTIFY|TPM_RETURNCMD|TPM_RIGHTALIGN*/, aRect[4], aRect[3], Recent.HANDLE)

  DestroyMenu(nHMenu)

  IF nCmd > 0
    RecentFileRemove(nCmd)
  ENDIF

RETURN NIL


FUNCTION RecentResize()
  LOCAL nRecentCW := GetProperty("Recent", "CLIENTAREAWIDTH")
  LOCAL nRecentCH := GetProperty("Recent", "CLIENTAREAHEIGHT")

  Recent.Files.WIDTH     := nRecentCW - 20
  Recent.Files.HEIGHT    := nRecentCH - 74
  Recent.Names.ROW       := nRecentCH - 59
  Recent.Count.ROW       := nRecentCH - 59
  Recent.Count.COL       := nRecentCW - Recent.Count.WIDTH - 15
  Recent.AmountLabel.ROW := nRecentCH - 29
  Recent.Amount.ROW      := nRecentCH - 32
  Recent.Amount.COL      := Recent.AmountLabel.WIDTH + 13
  Recent.Open.ROW        := nRecentCH - 33
  Recent.Open.COL        := nRecentCW - (90 + 10) * 2
  Recent.Remove.ROW      := nRecentCH - 33
  Recent.Remove.COL      := nRecentCW - (90 + 10)

  Recent.Files.ColumnWIDTH(1) := nRecentCW - 20 - 4 - If(Recent.Files.ITEMCOUNT > ListViewGetCountPerPage(Recent.Files.HANDLE), GetVScrollBarWidth(), 0)

RETURN NIL


FUNCTION RecentFilesOnKey()

  IF Recent.FocusedControl == "Files"
    RecentFileRemove(1)
  ENDIF

RETURN NIL


FUNCTION RecentButtonsEnable()
  LOCAL lEnable := (Recent.Files.ITEMCOUNT > 0)
  LOCAL nHFocus := GetFocus()

  IF (! lEnable) .and. ((nHFocus == Recent.Open.HANDLE) .or. (nHFocus == Recent.Remove.HANDLE))
    Recent.Files.SETFOCUS
  ENDIF

  Recent.Open.ENABLED   := lEnable
  Recent.Remove.ENABLED := lEnable

RETURN NIL


FUNCTION RecentFileOpen(lAtPage, lNewTab)
  LOCAL nPos := Recent.Files.VALUE
  LOCAL cFile
  LOCAL n

  IF nPos > 0
    cFile := saRecent[nPos][1]

    FileOpen(cFile, lAtPage, lNewTab)

    EnableWindowRedraw(Recent.Files.HANDLE, .F.)

    IF Recent.Files.ITEMCOUNT < Len(saRecent)
      Recent.Files.AddItem({""})
    ENDIF

    FOR n := 1 TO Len(saRecent)
      Recent.Files.Cell(n, 1) := If(slRecentNames, HB_fNameName(saRecent[n][1]), saRecent[n][1])

      IF HMG_StrCmp(cFile, saRecent[n][1], .F.) == 0
        nPos := n
      ENDIF
    NEXT

    Recent.Files.VALUE := nPos

    EnableWindowRedraw(Recent.Files.HANDLE, .T., .T.)
    RecentCount()
  ENDIF

RETURN NIL


/*
  nAction:
    1 - remove selected
    2 - remove non-existent
    3 - remove all
*/
FUNCTION RecentFileRemove(nAction)
  LOCAL nPos := Recent.Files.VALUE
  LOCAL n

  IF nPos > 0
    IF nAction == 1
      Recent.Files.DeleteItem(nPos)
      HB_aDel(saRecent, nPos, .T.)

      IF nPos > Recent.Files.ITEMCOUNT
        Recent.Files.VALUE := Recent.Files.ITEMCOUNT
      ELSE
        Recent.Files.VALUE := nPos
      ENDIF
    ELSEIF nAction == 2
      EnableWindowRedraw(Recent.Files.HANDLE, .F.)

      FOR n := Len(saRecent) TO 1 STEP -1
        IF ! HB_FileExists(saRecent[n][1])
          Recent.Files.DeleteItem(n)
          HB_aDel(saRecent, n, .T.)
        ENDIF
      NEXT

      IF nPos > Recent.Files.ITEMCOUNT
        Recent.Files.VALUE := Recent.Files.ITEMCOUNT
      ELSE
        Recent.Files.VALUE := nPos
      ENDIF

      EnableWindowRedraw(Recent.Files.HANDLE, .T., .T.)
    ELSEIF nAction == 3
      Recent.Files.DELETEALLITEMS
      aSize(saRecent, 0)
    ENDIF

    RecentCount()
    RecentButtonsEnable()
  ENDIF

RETURN NIL


FUNCTION MainEventHandler(nHWnd, nMsg, nWParam, nLParam)
  LOCAL nHWndFrom
  LOCAL cPanel
  LOCAL nMaxY
  LOCAL aRect1, aRect2
  LOCAL nCol, i

  IF nMsg == WM_NOTIFY
    IF _IsControlDefined("Files", "PdfView") .and. GetHwndFrom(nLParam) == PdfView.Files.HANDLE
      IF GetNotifyCode(nLParam) == LVN_KEYDOWN
        IF GetGridvKey(nLParam) == VK_F12
          IF (GetKeyState(VK_CONTROL) >= 0) .and. (GetKeyState(VK_SHIFT) >= 0) .and. (GetKeyState(VK_MENU) >= 0)
            Sumatra_Bookmarks(PanelName(), ! Sumatra_Bookmarks(PanelName()))
            PdfView.Files.SETFOCUS
          ENDIF
        ELSEIF GetGridvKey(nLParam) == VK_LEFT
          IF (GetKeyState(VK_CONTROL) >= 0) .and. (GetKeyState(VK_SHIFT) >= 0) .and. (GetKeyState(VK_MENU) >= 0) .and. (PdfView.Files.Cell(1, F_NAME) == "<..>")
            PdfView.Files.VALUE := 1
            FileOpen()
          ENDIF
        ELSEIF GetGridvKey(nLParam) == VK_RIGHT
          IF (GetKeyState(VK_CONTROL) >= 0) .and. (GetKeyState(VK_SHIFT) >= 0) .and. (GetKeyState(VK_MENU) >= 0) .and. ("D" $ PdfView.Files.Cell(PdfView.Files.VALUE, F_ATTR)) .and. (! (PdfView.Files.Cell(PdfView.Files.VALUE, F_NAME) == "<..>"))
            FileOpen()
          ENDIF
        ENDIF
      ENDIF
    ENDIF
  ENDIF

  IF PdfView.Tabs.VISIBLE
    IF nMsg == 517 /*WM_RBUTTONUP*/
      TabChange(Tab_HitTest(nHWnd, nLParam))
      TabMenu(.T.)
    ELSEIF nMsg == 519 /*WM_MBUTTONDOWN*/
      IF nWParam == 0x10 /*MK_MBUTTON*/
        TabClose(Tab_HitTest(nHWnd, nLParam))
      ENDIF
    ENDIF
  ENDIF

  IF nHWnd == PdfView.HANDLE
    SWITCH nMsg
      CASE 36 /*WM_GETMINMAXINFO*/
        SetMinMaxTrackSize(nLParam, 550, 300)
        EXIT

      CASE 274 /*WM_SYSCOMMAND*/
        IF HB_BitAnd(nWParam, 0xFFF0) == 0xF100 /*SC_KEYMENU*/
          //for Win-10
          IF GetFocus() != PdfView.Files.HANDLE
            snHFocusMenu := GetFocus()
            PdfView.Files.SETFOCUS
            PostMessage(nHWnd, nMsg, nWParam, nLParam)
            RETURN 1
          ENDIF

          IF GetMenu(nHWnd) == 0
            SetMenu(nHWnd, snHMenuMain)
          ELSEIF ! slMenuBar
            SetMenu(nHWnd, 0)
            RETURN 1
          ENDIF

          PdfView.PdfTimer.ENABLED := .F.
        ENDIF
        RETURN 0

      CASE 278 /*WM_INITMENU*/
        slMenuActive := .T.
        MenuCommandsEnable()
        SetOnKey(.F.)
        RETURN 0

      CASE 530 /*WM_EXITMENULOOP*/
        slMenuActive := .F.
        SetOnKey(.T.)

        //for Win-10
        IF IsWindowEnabled(snHFocusMenu)
          SetFocus(snHFocusMenu)
          snHFocusMenu := NIL
        ENDIF

        IF ! slMenuBar
          SetMenu(nHWnd, 0)
        ENDIF

        PdfView.PdfTimer.ENABLED := .T.
        RETURN 0

      CASE 78 /*WM_NOTIFY*/
        nHWndFrom := GetHWNDFrom(nLParam)

        IF nHWndFrom == PdfView.Files.HANDLE
          SWITCH GetNotifyCode(nLParam)
            CASE -2 /*NM_CLICK*/
            CASE -5 /*NM_RCLICK*/
            CASE -6 /*NM_RDBLCLK*/
              //IF (PdfView.Files.VALUE == 0) .and. (PdfView.Files.CELLROW > 0)
                //PdfView.Files.VALUE := PdfView.Files.CELLROW
              //ENDIF
              EXIT
            CASE -3 /*NM_DBLCLK*/
              IF (PdfView.Files.VALUE == 0) //.and. (PdfView.Files.CELLROW > 0)
                //PdfView.Files.VALUE := PdfView.Files.CELLROW
              ELSE
                FileOpen(NIL, (GetKeyState(VK_CONTROL) < 0), (GetKeyState(VK_SHIFT) < 0))
              ENDIF
              RETURN 1
          ENDSWITCH

        ELSEIF nHWndFrom == PdfView.Tabs.HANDLE
          SWITCH GetNotifyCode(nLParam)
            CASE -551 /*TCN_SELCHANGE*/
              PanelShow(saTab[PdfView.Tabs.VALUE], .T.)
              PdfViewResize(.F.)
              StatusSetFile()
              EXIT
            CASE -552 /*TCN_SELCHANGING*/
              PanelShow(saTab[PdfView.Tabs.VALUE], .F.)
              RETURN 0
          ENDSWITCH
        ENDIF
        EXIT

      CASE 123 /*WM_CONTEXTMENU*/
        IF nWParam == PdfView.Files.HANDLE
          FileMenu(HiWord(nLParam), LoWord(nLParam))
        ENDIF
        EXIT

      CASE 74 /*WM_COPYDATA*/
        IF GetCopyDataAction(nLParam) == 1
          SessionOpen(2, HB_aTokens(GetCopyDataString(nLParam), Chr(9)))
        ENDIF
        EXIT
    ENDSWITCH

  ELSEIF nHWnd == GetFormHandle(cPanel := PanelName())
    SWITCH nMsg
      CASE 36 /*WM_GETMINMAXINFO*/
        nMaxY := GetProperty("PdfView", "CLIENTAREAHEIGHT") - If(PdfView.Tabs.VISIBLE, PdfView.Tabs.HEIGHT, 0) - GetWindowHeight(PdfView.STATUSBAR.HANDLE)
        SetMinMaxTrackSize(nLParam, 200, nMaxY, GetProperty("PdfView", "CLIENTAREAWIDTH") - 100, nMaxY)
        EXIT

      CASE 532 /*WM_SIZING*/
        aRect1 := Array(4)
        aRect2 := Array(4)

        GetWindowRect(nHWnd, aRect1)
        GetRectArray(nLParam, aRect2)

        SWITCH nWParam
          CASE 1 /*WMSZ_LEFT*/
          CASE 4 /*WMSZ_TOPLEFT*/
          CASE 7 /*WMSZ_BOTTOMLEFT*/
            IF aRect1[1] != aRect2[1]
              nCol := ScreenToClientCol(PdfView.HANDLE, aRect2[1])
              PdfView.Files.WIDTH := nCol + 1
              PdfView.Files.ColumnWIDTH(1) := nCol - 4 - If(PdfView.Files.ITEMCOUNT > ListViewGetCountPerPage(PdfView.Files.HANDLE), GetVScrollBarWidth(), 0)
              PdfView.Tabs.COL := nCol
              SetProperty(cPanel, "WIDTH", GetProperty("PdfView", "CLIENTAREAWIDTH") - nCol + (GetProperty(cPanel, "WIDTH") - GetProperty(cPanel, "CLIENTAREAWIDTH")) / 2 - GetBorderWidth())
              Sumatra_FrameAdjust(cPanel)
            ENDIF
            EXIT
          OTHERWISE
            SetRectArray(nLParam, aRect1)
        ENDSWITCH
        EXIT

      CASE 74 /*WM_COPYDATA*/
        IF GetCopyDataAction(nLParam) == 0x4C5255 /*URL*/
          ShellExecute(0, "open", "rundll32.exe", "url.dll, FileProtocolHandler " + GetCopyDataString(nLParam, .T.), NIL, 1 /*SW_SHOWNORMAL*/)
        ENDIF
        EXIT
    ENDSWITCH

  ELSEIF IsWindowDefined(Recent) .and. (nHWnd == Recent.HANDLE)
    SWITCH nMsg
      CASE 36 /*WM_GETMINMAXINFO*/
        SetMinMaxTrackSize(nLParam, 380, 250)
        EXIT

      CASE 78 /*WM_NOTIFY*/
        nHWndFrom := GetHWNDFrom(nLParam)

        IF nHWndFrom == Recent.Files.HANDLE
          SWITCH GetNotifyCode(nLParam)
            CASE -2 /*NM_CLICK*/
            CASE -5 /*NM_RCLICK*/
            CASE -6 /*NM_RDBLCLK*/
              //IF (Recent.Files.VALUE == 0) .and. (Recent.Files.CELLROW > 0)
                //Recent.Files.VALUE := Recent.Files.CELLROW
              //ENDIF
              EXIT
            CASE -3 /*NM_DBLCLK*/
              IF (Recent.Files.VALUE == 0) //.and. (Recent.Files.CELLROW > 0)
                //Recent.Files.VALUE := Recent.Files.CELLROW
              ELSEIF (Recent.Files.VALUE > 0)
                RecentFileOpen((GetKeyState(VK_CONTROL) < 0), (GetKeyState(VK_SHIFT) < 0))
              ENDIF
              RETURN 1
          ENDSWITCH
        ENDIF
        EXIT

      CASE 273 //WM_COMMAND
        IF LoWord(nWParam) == 2 /*IDCANCEL*/
          Recent.RELEASE
        ENDIF
        EXIT
    ENDSWITCH
  ENDIF

RETURN NIL


FUNCTION SettingsRead()
  LOCAL aLine
  LOCAL cLine
  LOCAL cValue
  LOCAL aFile
  LOCAL nPos
  LOCAL nPosS
  LOCAL nPosF
  LOCAL n

  saTab        := {}
  saPanel      := {}
  slMenuActive := .F.

  saSession := {}
  saRecent  := {}

  slPdfView_Max  := .F.
  snPdfView_R    := 100
  snPdfView_C    := 100
  snPdfView_W    := 650
  snPdfView_H    := 450
  snFiles_W      := 150
  snRecent_W     := 380
  snRecent_H     := 250
  slRecentNames  := .F.
  snRecentAmount := 99
  snZoom         := 0
  slMenuBar      := .T.
  slToolbar      := .F.
  slBookmarks    := .T.
  slOpenAtOnce   := .F.
  slSessionRest  := .F.
  slTabGoToFile  := .F.
  slEscExit      := .F.
  scSumatraDir   := ""
  scFileDir      := HB_CWD()
  scFileLast     := ""
  scLang         := "en"

  aLine := HB_aTokens(HB_MemoRead(HB_fNameExtSet(HB_ArgV( 0 ), "ini")), CRLF)

  FOR EACH cLine IN aLine
    cLine := AllTrim(cLine)
    nPos  := HB_UAt("=", cLine)

    IF nPos > 0
      cValue := HB_USubstr(cLine, nPos + 1)

      SWITCH HB_ULeft(cLine, nPos - 1)
        CASE "PdfView_Max"  ; slPdfView_Max  := (cValue == "T") ; EXIT
        CASE "PdfView_R"    ; snPdfView_R    := Val(cValue)     ; EXIT
        CASE "PdfView_C"    ; snPdfView_C    := Val(cValue)     ; EXIT
        CASE "PdfView_W"    ; snPdfView_W    := Val(cValue)     ; EXIT
        CASE "PdfView_H"    ; snPdfView_H    := Val(cValue)     ; EXIT
        CASE "Files_W"      ; snFiles_W      := Val(cValue)     ; EXIT
        CASE "Recent_W"     ; snRecent_W     := Val(cValue)     ; EXIT
        CASE "Recent_H"     ; snRecent_H     := Val(cValue)     ; EXIT
        CASE "RecentNames"  ; slRecentNames  := (cValue == "T") ; EXIT
        CASE "RecentAmount" ; snRecentAmount := Val(cValue)     ; EXIT
        CASE "Zoom"         ; snZoom         := Val(cValue)     ; EXIT
        CASE "MenuBar"      ; slMenuBar      := (cValue == "T") ; EXIT
        CASE "Toolbar"      ; slToolbar      := (cValue == "T") ; EXIT
        CASE "Bookmarks"    ; slBookmarks    := (cValue == "T") ; EXIT
        CASE "OpenAtOnce"   ; slOpenAtOnce   := (cValue == "T") ; EXIT
        CASE "RestSession"  ; slSessionRest  := (cValue == "T") ; EXIT
        CASE "TabGoToFile"  ; slTabGoToFile  := (cValue == "T") ; EXIT
        CASE "EscExit"      ; slEscExit      := (cValue == "T") ; EXIT
        CASE "SumatraDir"   ; scSumatraDir   := cValue          ; EXIT
        CASE "FileDir"      ; scFileDir      := cValue          ; EXIT
        CASE "FileLast"     ; scFileLast     := cValue          ; EXIT
        CASE "Lang"         ; scLang         := cValue          ; EXIT
      ENDSWITCH
    ENDIF
  NEXT

  IF snPdfView_W < 550
    snPdfView_W := 550
  ENDIF

  IF snPdfView_H < 300
    snPdfView_H := 300
  ENDIF

  IF snFiles_W < 100
    snFiles_W := 100
  ENDIF

  IF snRecent_W < 380
    snRecent_W := 380
  ENDIF

  IF snRecent_H < 250
    snRecent_H := 250
  ENDIF

  scSumatraDir := DirSepAdd(scSumatraDir)

  IF ! Empty(scFileDir)
    IF (VolSerial(HB_ULeft(scFileDir, 3)) == -1) .or. (! HB_DirExists(scFileDir))
      scFileDir := HB_CWD()
    ELSE
      scFileDir := DirSepAdd(scFileDir)
    ENDIF
  ENDIF

  scDirStart := HB_CWD(HB_DirBase())

  IF HB_aScan(LangStr(), {|aLang| aLang[3] == scLang}) == 0
    scLang := "en"
  ENDIF

  aLine := HB_aTokens(HB_MemoRead(HB_fNameExtSet(HB_ArgV( 0 ), "recent")), CRLF)
  nPosS := HB_aScan(aLine, "<session>", NIL, NIL, .T.)
  nPosF := HB_aScan(aLine, "<files>", NIL, NIL, .T.)

  IF nPosS > 0
    nPos := If(nPosS > nPosF, Len(aLine), nPosF - 1)

    FOR n := (nPosS + 1) TO nPos
      IF ! Empty(aLine[n])
        aFile := HB_aTokens(aLine[n], Chr(9))
        aAdd(saSession, {aFile[1], If(Len(aFile) > 1, Val(aFile[2]), 1)})
      ENDIF
    NEXT
  ENDIF

  IF nPosF > 0
    nPos := If(nPosF > nPosS, Len(aLine), nPosS - 1)

    FOR n := (nPosF + 1) TO nPos
      IF ! Empty(aLine[n])
        aFile := HB_aTokens(aLine[n], Chr(9))
        aAdd(saRecent, {aFile[1], If(Len(aFile) > 1, Val(aFile[2]), 1)})
      ENDIF
    NEXT
  ENDIF

RETURN NIL


FUNCTION SettingsWrite()
  LOCAL aWndPos := GetWindowNormalPos(PdfView.HANDLE)
  LOCAL cText   := "<session>" + CRLF
  LOCAL nPanel
  LOCAL cPanel
  LOCAL nPage
  LOCAL cFile
  LOCAL aFile

  GetSumatraSettings()

  IF ! saPanel[saTab[PdfView.Tabs.VALUE]]
    cText += "tab" + Chr(9) + HB_NtoS(PdfView.Tabs.VALUE) + CRLF

    FOR EACH nPanel IN saTab
      cPanel := PanelName(nPanel)
      cFile  := Sumatra_FileName(cPanel)
      nPage  := Sumatra_PageNumber(cPanel)

      IF ! Empty(cFile)
        cText += cFile + Chr(9) + HB_NtoS(nPage) + CRLF

        IF nPage > 0
          RecentAdd(cFile, nPage)
        ENDIF
      ENDIF

      Sumatra_FileClose(cPanel, .F.)
    NEXT
  ENDIF

  cText += "<files>" + CRLF

  FOR EACH aFile IN saRecent
    cText += aFile[1] + Chr(9) + HB_NtoS(aFile[2]) + CRLF
  NEXT

  HB_MemoWrit(HB_fNameExtSet(Lower(HB_ArgV( 0 )), "recent"), cText)

  cText := "PdfView_Max="  + If(IsMaximized(PdfView.HANDLE), "T", "F") + CRLF + ;
           "PdfView_R="    + HB_NtoS(aWndPos[2]) + CRLF + ;
           "PdfView_C="    + HB_NtoS(aWndPos[1]) + CRLF + ;
           "PdfView_W="    + HB_NtoS(aWndPos[3] - aWndPos[1]) + CRLF + ;
           "PdfView_H="    + HB_NtoS(aWndPos[4] - aWndPos[2]) + CRLF + ;
           "Files_W="      + HB_NtoS(PdfView.Files.WIDTH) + CRLF + ;
           "Recent_W="     + HB_NtoS(snRecent_W) + CRLF + ;
           "Recent_H="     + HB_NtoS(snRecent_H) + CRLF + ;
           "RecentNames="  + If(slRecentNames, "T", "F") + CRLF + ;
           "RecentAmount=" + HB_NtoS(snRecentAmount) + CRLF + ;
           "Zoom="         + HB_NtoS(snZoom) + CRLF + ;
           "MenuBar="      + If(slMenuBar, "T", "F") + CRLF + ;
           "Toolbar="      + If(slToolbar, "T", "F") + CRLF + ;
           "Bookmarks="    + If(slBookmarks, "T", "F") + CRLF + ;
           "RestSession="  + If(slSessionRest, "T", "F") + CRLF + ;
           "TabGoToFile="  + If(slTabGoToFile, "T", "F") + CRLF + ;
           "OpenAtOnce="   + If(slOpenAtOnce, "T", "F") + CRLF + ;
           "EscExit="      + If(slEscExit, "T", "F") + CRLF + ;
           "SumatraDir="   + scSumatraDir + CRLF + ;
           "FileDir="      + scFileDir + CRLF + ;
           "FileLast="     + PdfView.Files.Cell(PdfView.Files.VALUE, F_NAME) + CRLF + ;
           "Lang="         + scLang + CRLF

  HB_MemoWrit(HB_fNameExtSet(Lower(HB_ArgV( 0 )), "ini"), cText)

RETURN NIL


FUNCTION DirSepAdd(cDir)

  IF (! Empty(cDir)) .and. (! (HB_URight(cDir, 1) == "\"))
    cDir += "\"
  ENDIF

RETURN cDir


FUNCTION DirSepDel(cDir)

  IF HB_URight(cDir, 1) == "\"
    cDir := HB_StrShrink(cDir)
  ENDIF

RETURN cDir


FUNCTION DirParent(cDir)

  cDir := DirSepDel(cDir)

RETURN HB_ULeft(cDir, HB_UTF8RAt("\", cDir))


FUNCTION LangStr(cStr, lRemoveAmpersand)
  LOCAL cText

  IF ! HB_IsChar(cStr)
    RETURN { ;
             {"English",    "",            "en"}, ;
             {"Polish",     "(Polski)",    "pl"}, ;
             {"Portuguese", hb_Translate( "(Português)", "UTF8", "CP1251" ), "pt"}, ;
             {"Russian",    hb_Translate( "(Русский)", "UTF8", "CP1251" ), "ru"}, ;
             {"Spanish",    hb_Translate( "(Español)", "UTF8", "CP1251" ), "es"}  ;
           }
  ENDIF

  cText := ""

  SWITCH scLang
    CASE "pl"
      SWITCH cStr
        CASE "File"          ; cText := "&Plik"                               ; EXIT
        CASE "OpenCurTab"    ; cText := "&Otwórz w bieżącej karcie"           ; EXIT
        CASE "OpenNewTab"    ; cText := "Otwórz w &nowej karcie"              ; EXIT
        CASE "OpenPage"      ; cText := "Otwórz na &stronie"                  ; EXIT
        CASE "OpenPageTab"   ; cText := "Otwórz na stronie w nowej &karcie"   ; EXIT
        CASE "OpenSession"   ; cText := "Otwórz ostatnią s&esję"              ; EXIT
        CASE "RecentFiles"   ; cText := "Ostatnio otwarte &pliki"             ; EXIT
        CASE "GoToSubDir"    ; cText := "Przejdź do podkatalogu"              ; EXIT
        CASE "GoToParentDir" ; cText := "Przejdź do katalogu nadrzędnego"     ; EXIT
        CASE "RefreshList"   ; cText := "Odśwież &listę"                      ; EXIT
        CASE "Exit"          ; cText := "&Zakończ"                            ; EXIT
        CASE "Document"      ; cText := "&Dokument"                           ; EXIT
        CASE "SaveAs"        ; cText := "Z&apisz jako"                        ; EXIT
        CASE "Print"         ; cText := "&Drukuj"                             ; EXIT
        CASE "Proper"        ; cText := "&Właściwości"                        ; EXIT
        CASE "Close"         ; cText := "&Zamknij"                            ; EXIT
        CASE "ChooseDoc"     ; cText := "W&ybierz dokument"                   ; EXIT
        CASE "GoToFile"      ; cText := "Przejdź do &pliku"                   ; EXIT
        CASE "Page"          ; cText := "&Strona"                             ; EXIT
        CASE "GoTo"          ; cText := "Przejdź &do"                         ; EXIT
        CASE "Prev"          ; cText := "Poprz&ednia"                         ; EXIT
        CASE "Next"          ; cText := "&Następna"                           ; EXIT
        CASE "First"         ; cText := "&Pierwsza"                           ; EXIT
        CASE "Last"          ; cText := "&Ostatnia"                           ; EXIT
        CASE "Find"          ; cText := "&Znajdź"                             ; EXIT
        CASE "Text"          ; cText := "&Tekst"                              ; EXIT
        CASE "PrevOccur"     ; cText := "&Poprzednie wystąpienie"             ; EXIT
        CASE "NextOccur"     ; cText := "&Następne wystąpienie"               ; EXIT
        CASE "Zoom"          ; cText := "&Rozmiar"                            ; EXIT
        CASE "SizeDn"        ; cText := "&Zmniejsz"                           ; EXIT
        CASE "SizeUp"        ; cText := "&Powiększ"                           ; EXIT
        CASE "ZoomFactor"    ; cText := "&Współczynnik powiększenia"          ; EXIT
        CASE "FitPage"       ; cText := "&Dopasuj do strony"                  ; EXIT
        CASE "ActualSize"    ; cText := "&Rozmiar rzeczywisty"                ; EXIT
        CASE "FitWidth"      ; cText := "Dopasuj do &szerokości"              ; EXIT
        CASE "Rotate"        ; cText := "&Obrót"                              ; EXIT
        CASE "Left"          ; cText := "W &lewo"                             ; EXIT
        CASE "Right"         ; cText := "W &prawo"                            ; EXIT
        CASE "View"          ; cText := "&Widok"                              ; EXIT
        CASE "MenuBar"       ; cText := "Pasek &menu"                         ; EXIT
        CASE "Toolbar"       ; cText := "Pasek &narzędzi"                     ; EXIT
        CASE "Bookmarks"     ; cText := "&Zakładki PDF"                       ; EXIT
        CASE "Show"          ; cText := "&Pokaż"                              ; EXIT
        CASE "ExpandAll"     ; cText := "&Rozwiń wszystkie"                   ; EXIT
        CASE "CollapseAll"   ; cText := "&Zwiń wszystkie"                     ; EXIT
        CASE "Settings"      ; cText := "&Ustawienia"                         ; EXIT
        CASE "OpenAtOnce"    ; cText := "&Otwieraj PDF od razu"               ; EXIT
        CASE "RestSession"   ; cText := "&Przywróć ostatnią sesję na starcie" ; EXIT
        CASE "TabGoToFile"   ; cText := "&Zmieniając kartę, przejdź do pliku" ; EXIT
        CASE "EscExit"       ; cText := "&Esc - kończy program"               ; EXIT
        CASE "SumatraDir"    ; cText := "&Katalog SumatraPDF"                 ; EXIT
        CASE "Language"      ; cText := "&Język"                              ; EXIT
        CASE "AboutPdfView"  ; cText := "O programie PdfView"                 ; EXIT
        CASE "AboutSumatra"  ; cText := "O programie SumatraPDF"              ; EXIT

        CASE "AppRunning"    ; cText := "Program już jest uruchomiony!"       ; EXIT
        CASE "NoDisk"        ; cText := "Dysk jest niedostępny!"              ; EXIT
        CASE "NoFile"        ; cText := "Plik nie istnieje!"                  ; EXIT
        CASE "SetPath"       ; cText := "Ustaw ścieżkę do"                    ; EXIT
        CASE "ListRefresh"   ; cText := "Lista zostanie odświeżona."          ; EXIT
        CASE "OpenFilePage"  ; cText := "Otwórz plik na stronie"              ; EXIT
        CASE "PageNum"       ; cText := "Numer strony"                        ; EXIT
        CASE "SelFolder"     ; cText := "Wybierz folder SumatraPDF"           ; EXIT
        CASE "OnlyNames"     ; cText := "Tylko &nazwy"                        ; EXIT
        CASE "FilesAmount"   ; cText := "Liczba &plików"                      ; EXIT
        CASE "Selected"      ; cText := "&Zaznaczony"                         ; EXIT
        CASE "NonExistent"   ; cText := "&Nieistniejące"                      ; EXIT
        CASE "All"           ; cText := "&Wszystkie"                          ; EXIT
        CASE "PdfViewUsing"  ; cText := "Podgląd plików PDF za pomocą"        ; EXIT
        CASE "Author"        ; cText := "Autor"                               ; EXIT
        CASE "Translators"   ; cText := "Tłumacze"                            ; EXIT

        CASE "Open"          ; cText := "&Otwórz"                             ; EXIT
        CASE "Remove"        ; cText := "&Usuń"                               ; EXIT
        CASE "Browse"        ; cText := "&Przeglądaj"                         ; EXIT
        CASE "OK"            ; cText := "OK"                                  ; EXIT
        CASE "Cancel"        ; cText := "&Anuluj"                             ; EXIT
      ENDSWITCH
      EXIT

    //Portuguese - translated by Pablo César
    CASE "pt"
      SWITCH cStr
        CASE "File"          ; cText := "Arquivo"                          ; EXIT
          CASE "OpenCurTab"    ; cText := "&Open in current tab"             ; EXIT
          CASE "OpenNewTab"    ; cText := "Open in &new tab"                 ; EXIT
        CASE "OpenPage"      ; cText := "Abrir arquivo na página"          ; EXIT
          CASE "OpenPageTab"   ; cText := "Open at page in new &tab"         ; EXIT
          CASE "OpenSession"   ; cText := "Open last &session"               ; EXIT
          CASE "RecentFiles"   ; cText := "Recent &files"                    ; EXIT
          CASE "GoToSubDir"    ; cText := "Go to subdirectory"               ; EXIT
          CASE "GoToParentDir" ; cText := "Go to parent directory"           ; EXIT
        CASE "RefreshList"   ; cText := "Atualizar"                        ; EXIT
        CASE "Exit"          ; cText := "Sair"                             ; EXIT
          CASE "Document"      ; cText := "&Document"                        ; EXIT
        CASE "SaveAs"        ; cText := "Salvar como"                      ; EXIT
        CASE "Print"         ; cText := "Imprimir"                         ; EXIT
        CASE "Proper"        ; cText := "Propriedades"                     ; EXIT
        CASE "Close"         ; cText := "Fechar"                           ; EXIT
          CASE "ChooseDoc"     ; cText := "Choose &document"                 ; EXIT
          CASE "GoToFile"      ; cText := "Go to &file"                      ; EXIT
        CASE "Page"          ; cText := "Página"                           ; EXIT
        CASE "GoTo"          ; cText := "Ir para"                          ; EXIT
        CASE "Prev"          ; cText := "Anterior"                         ; EXIT
        CASE "Next"          ; cText := "Próximo"                          ; EXIT
        CASE "First"         ; cText := "Primeiro"                         ; EXIT
        CASE "Last"          ; cText := "Ultimo"                           ; EXIT
        CASE "Find"          ; cText := "Procurar"                         ; EXIT
        CASE "Text"          ; cText := "Texto"                            ; EXIT
        CASE "PrevOccur"     ; cText := "Ocorrência anterior"              ; EXIT
        CASE "NextOccur"     ; cText := "Próxima ocorrência"               ; EXIT
        CASE "Zoom"          ; cText := "Visualização"                     ; EXIT
        CASE "SizeDn"        ; cText := "Diminuir"                         ; EXIT
        CASE "SizeUp"        ; cText := "Aumentar"                         ; EXIT
        CASE "ZoomFactor"    ; cText := "Nível de ampliação"               ; EXIT
        CASE "FitPage"       ; cText := "Ajuste de página"                 ; EXIT
        CASE "ActualSize"    ; cText := "Zoom automático"                  ; EXIT
        CASE "FitWidth"      ; cText := "Ajuste de largura"                ; EXIT
        CASE "Rotate"        ; cText := "Girar"                            ; EXIT
        CASE "Left"          ; cText := "Para a esquerda"                  ; EXIT
        CASE "Right"         ; cText := "Para a direita"                   ; EXIT
        CASE "View"          ; cText := "Exibir"                           ; EXIT
        CASE "MenuBar"       ; cText := "Barra de menú"                    ; EXIT
        CASE "Toolbar"       ; cText := "Barra de ferramentas"             ; EXIT
        CASE "Bookmarks"     ; cText := "Marcadores"                       ; EXIT
        CASE "Show"          ; cText := "Exibir"                           ; EXIT
        CASE "ExpandAll"     ; cText := "Expandir todos"                   ; EXIT
        CASE "CollapseAll"   ; cText := "Recolher todos"                   ; EXIT
        CASE "Settings"      ; cText := "Configurações"                    ; EXIT
        CASE "OpenAtOnce"    ; cText := "Abrir ao click"                   ; EXIT
          CASE "RestSession"   ; cText := "&Restore last session on start"   ; EXIT
          CASE "TabGoToFile"   ; cText := "&Changing tab, go to file"        ; EXIT
        CASE "EscExit"       ; cText := "Esc - Fechar o programa"          ; EXIT
        CASE "SumatraDir"    ; cText := "Pasta do SumatraPDF"              ; EXIT
        CASE "Language"      ; cText := "Idiomas"                          ; EXIT
          CASE "AboutPdfView"  ; cText := "About PdfView"                    ; EXIT
          CASE "AboutSumatra"  ; cText := "About SumatraPDF"                 ; EXIT

        CASE "AppRunning"    ; cText := "O programa já está em execução!"  ; EXIT
        CASE "NoDisk"        ; cText := "O disco está inacessível!"        ; EXIT
        CASE "NoFile"        ; cText := "O arquivo não existe!"            ; EXIT
        CASE "SetPath"       ; cText := "Defina o caminho para"            ; EXIT
        CASE "ListRefresh"   ; cText := "A lista será atualizada."         ; EXIT
        CASE "OpenFilePage"  ; cText := "Abrir arquivo na página"          ; EXIT
        CASE "PageNum"       ; cText := "Número de página"                 ; EXIT
        CASE "SelFolder"     ; cText := "Selecione a pasta do SumatraPDF"  ; EXIT
          CASE "OnlyNames"     ; cText := "Only &names"                      ; EXIT
          CASE "FilesAmount"   ; cText := "Amount of &files"                 ; EXIT
          CASE "Selected"      ; cText := "&Selected"                        ; EXIT
          CASE "NonExistent"   ; cText := "&Non-existent"                    ; EXIT
          CASE "All"           ; cText := "&All"                             ; EXIT
          CASE "PdfViewUsing"  ; cText := "PDF viewer using"                 ; EXIT
          CASE "Author"        ; cText := "Author"                           ; EXIT
          CASE "Translators"   ; cText := "Translators"                      ; EXIT

        CASE "Open"          ; cText := "Abrir"                            ; EXIT
          CASE "Remove"        ; cText := "&Remove"                          ; EXIT
        CASE "Browse"        ; cText := "Localizar"                        ; EXIT
        CASE "OK"            ; cText := "Ok"                               ; EXIT
        CASE "Cancel"        ; cText := "Cancelar"                         ; EXIT
      ENDSWITCH
      EXIT

    CASE "ru"
      SWITCH cStr
        CASE "File"          ; cText := "файл"                                    ; EXIT
        CASE "OpenCurTab"    ; cText := "Открыть в текущей вкладке"               ; EXIT
        CASE "OpenNewTab"    ; cText := "Открыть в новой вкладке"                 ; EXIT
        CASE "OpenPage"      ; cText := "Открыть на странице"                     ; EXIT
        CASE "OpenPageTab"   ; cText := "Открыть на странице в новой вкладке"     ; EXIT
        CASE "OpenSession"   ; cText := "Открыть последнюю сессию"                ; EXIT
        CASE "RecentFiles"   ; cText := "Недавние файлы"                          ; EXIT
        CASE "GoToSubDir"    ; cText := "Перейти в подкаталог"                    ; EXIT
        CASE "GoToParentDir" ; cText := "Перейти в родительский каталог"          ; EXIT
        CASE "RefreshList"   ; cText := "Обновить список"                         ; EXIT
        CASE "Exit"          ; cText := "Выход"                                   ; EXIT
        CASE "Document"      ; cText := "Документ"                                ; EXIT
        CASE "SaveAs"        ; cText := "Сохранить как"                           ; EXIT
        CASE "Print"         ; cText := "Печать"                                  ; EXIT
        CASE "Proper"        ; cText := "Свойства"                                ; EXIT
        CASE "Close"         ; cText := "Закрыть"                                 ; EXIT
        CASE "ChooseDoc"     ; cText := "Выбрать документ"                        ; EXIT
        CASE "GoToFile"      ; cText := "Перейти к файлу"                         ; EXIT
        CASE "Page"          ; cText := "Страница"                                ; EXIT
        CASE "GoTo"          ; cText := "Перейти к"                               ; EXIT
        CASE "Prev"          ; cText := "Предыдущая"                              ; EXIT
        CASE "Next"          ; cText := "Следущая"                                ; EXIT
        CASE "First"         ; cText := "Первая"                                  ; EXIT
        CASE "Last"          ; cText := "Последняя"                               ; EXIT
        CASE "Find"          ; cText := "Найти"                                   ; EXIT
        CASE "Text"          ; cText := "Текст"                                   ; EXIT
        CASE "PrevOccur"     ; cText := "Предыдущее вхождение"                    ; EXIT
        CASE "NextOccur"     ; cText := "Следующее вхождение"                     ; EXIT
        CASE "Zoom"          ; cText := "Масштаб"                                 ; EXIT
        CASE "SizeDn"        ; cText := "Увеличить"                               ; EXIT
        CASE "SizeUp"        ; cText := "Уменьшить"                               ; EXIT
        CASE "ZoomFactor"    ; cText := "Указать масштаб"                         ; EXIT
        CASE "FitPage"       ; cText := "По размеру страницы"                     ; EXIT
        CASE "ActualSize"    ; cText := "Настоящий размер"                        ; EXIT
        CASE "FitWidth"      ; cText := "По ширине"                               ; EXIT
        CASE "Rotate"        ; cText := "Вращать"                                 ; EXIT
        CASE "Left"          ; cText := "В лево"                                  ; EXIT
        CASE "Right"         ; cText := "В право"                                 ; EXIT
        CASE "View"          ; cText := "Вид"                                     ; EXIT
        CASE "MenuBar"       ; cText := "Панель меню"                             ; EXIT
        CASE "Toolbar"       ; cText := "Панель инструментов"                     ; EXIT
        CASE "Bookmarks"     ; cText := "Закладки PDF"                            ; EXIT
        CASE "Show"          ; cText := "Показать"                                ; EXIT
        CASE "ExpandAll"     ; cText := "Расширить все"                           ; EXIT
        CASE "CollapseAll"   ; cText := "Свернуть все"                            ; EXIT
        CASE "Settings"      ; cText := "Настройки"                               ; EXIT
        CASE "OpenAtOnce"    ; cText := "Открыть PDF немедленно"                  ; EXIT
        CASE "RestSession"   ; cText := "Восстановить последнюю сессию на старте" ; EXIT
        CASE "TabGoToFile"   ; cText := "Изменение вкладки, перейдите к файлу"    ; EXIT
        CASE "EscExit"       ; cText := "Esc - выход"                             ; EXIT
        CASE "SumatraDir"    ; cText := "Каталог SumatraPDF"                      ; EXIT
        CASE "Language"      ; cText := "Язык"                                    ; EXIT
        CASE "AboutPdfView"  ; cText := "О программе PdfView"                     ; EXIT
        CASE "AboutSumatra"  ; cText := "О программе SumatraPDF"                  ; EXIT

        CASE "AppRunning"    ; cText := "Программа уже работает!"                 ; EXIT
        CASE "NoDisk"        ; cText := "Диск не доступен!"                       ; EXIT
        CASE "NoFile"        ; cText := "Файл не существует!"                     ; EXIT
        CASE "SetPath"       ; cText := "Установить путь к"                       ; EXIT
        CASE "ListRefresh"   ; cText := "Список будет обновлен."                  ; EXIT
        CASE "OpenFilePage"  ; cText := "Открыть файл на странице"                ; EXIT
        CASE "PageNum"       ; cText := "Номер страницы"                          ; EXIT
        CASE "SelFolder"     ; cText := "Выберите папку SumatraPDF"               ; EXIT
        CASE "OnlyNames"     ; cText := "Только имена"                            ; EXIT
        CASE "FilesAmount"   ; cText := "Количество файлов"                       ; EXIT
        CASE "Selected"      ; cText := "Выбранный"                               ; EXIT
        CASE "NonExistent"   ; cText := "Несуществующий"                          ; EXIT
        CASE "All"           ; cText := "Все"                                     ; EXIT
        CASE "PdfViewUsing"  ; cText := "Просмотр PDF файлов с помощью"           ; EXIT
        CASE "Author"        ; cText := "Автор"                                   ; EXIT
        CASE "Translators"   ; cText := "Переводчики"                             ; EXIT

        CASE "Open"          ; cText := "Открыть"                                 ; EXIT
        CASE "Remove"        ; cText := "Удалить"                                 ; EXIT
        CASE "Browse"        ; cText := "Выбрать"                                 ; EXIT
        CASE "OK"            ; cText := "OK"                                      ; EXIT
        CASE "Cancel"        ; cText := "Отмена"                                  ; EXIT
      ENDSWITCH
      EXIT

    //Spanish - translated by Pablo César
    CASE "es"
      SWITCH cStr
        CASE "File"          ; cText := "Archivo"                          ; EXIT
          CASE "OpenCurTab"    ; cText := "&Open in current tab"             ; EXIT
          CASE "OpenNewTab"    ; cText := "Open in &new tab"                 ; EXIT
        CASE "OpenPage"      ; cText := "Abrir archivo en la página"       ; EXIT
          CASE "OpenPageTab"   ; cText := "Open at page in new &tab"         ; EXIT
          CASE "OpenSession"   ; cText := "Open last &session"               ; EXIT
          CASE "RecentFiles"   ; cText := "Recent &files"                    ; EXIT
          CASE "GoToSubDir"    ; cText := "Go to subdirectory"               ; EXIT
          CASE "GoToParentDir" ; cText := "Go to parent directory"           ; EXIT
        CASE "RefreshList"   ; cText := "Actualizar"                       ; EXIT
        CASE "Exit"          ; cText := "Salir"                            ; EXIT
          CASE "Document"      ; cText := "&Document"                        ; EXIT
        CASE "SaveAs"        ; cText := "Guardar como"                     ; EXIT
        CASE "Print"         ; cText := "Impresión"                        ; EXIT
        CASE "Proper"        ; cText := "Propriedades"                     ; EXIT
        CASE "Close"         ; cText := "Cerrar"                           ; EXIT
          CASE "ChooseDoc"     ; cText := "Choose &document"                 ; EXIT
          CASE "GoToFile"      ; cText := "Go to &file"                      ; EXIT
        CASE "Page"          ; cText := "Página"                           ; EXIT
        CASE "GoTo"          ; cText := "Ir para"                          ; EXIT
        CASE "Prev"          ; cText := "Anterior"                         ; EXIT
        CASE "Next"          ; cText := "Próximo"                          ; EXIT
        CASE "First"         ; cText := "Primer"                           ; EXIT
        CASE "Last"          ; cText := "Ultimo"                           ; EXIT
        CASE "Find"          ; cText := "Procurar"                         ; EXIT
        CASE "Text"          ; cText := "Texto"                            ; EXIT
        CASE "PrevOccur"     ; cText := "Ocurrencia previa"                ; EXIT
        CASE "NextOccur"     ; cText := "Ocurrencia posterior"             ; EXIT
        CASE "Zoom"          ; cText := "Visualización"                    ; EXIT
        CASE "SizeDn"        ; cText := "Disminuir"                        ; EXIT
        CASE "SizeUp"        ; cText := "Aumentar"                         ; EXIT
        CASE "ZoomFactor"    ; cText := "Nivel del zoom"                   ; EXIT
        CASE "FitPage"       ; cText := "Ajuste de página"                 ; EXIT
        CASE "ActualSize"    ; cText := "Zoom automático"                  ; EXIT
        CASE "FitWidth"      ; cText := "Ajuste del ancho"                 ; EXIT
        CASE "Rotate"        ; cText := "Girar"                            ; EXIT
        CASE "Left"          ; cText := "Hacia la izquierda"               ; EXIT
        CASE "Right"         ; cText := "Hacia la derecha"                 ; EXIT
        CASE "View"          ; cText := "Exibición"                        ; EXIT
        CASE "MenuBar"       ; cText := "Barra de menú"                    ; EXIT
        CASE "Toolbar"       ; cText := "Barra de herramientas"            ; EXIT
        CASE "Bookmarks"     ; cText := "Marcadores"                       ; EXIT
        CASE "Show"          ; cText := "Exibir"                           ; EXIT
        CASE "ExpandAll"     ; cText := "Expandir todos"                   ; EXIT
        CASE "CollapseAll"   ; cText := "Retraer todos"                    ; EXIT
        CASE "Settings"      ; cText := "Configuraciones"                  ; EXIT
        CASE "OpenAtOnce"    ; cText := "Abrir de inmediato"               ; EXIT
          CASE "RestSession"   ; cText := "&Restore last session on start"   ; EXIT
          CASE "TabGoToFile"   ; cText := "&Changing tab, go to file"        ; EXIT
        CASE "EscExit"       ; cText := "Esc - Cierre del programa"        ; EXIT
        CASE "SumatraDir"    ; cText := "Carpeta del SumatraPDF"           ; EXIT
        CASE "Language"      ; cText := "Idiomas"                          ; EXIT
          CASE "AboutPdfView"  ; cText := "About PdfView"                    ; EXIT
          CASE "AboutSumatra"  ; cText := "About SumatraPDF"                 ; EXIT

        CASE "AppRunning"    ; cText := "El programa ya está en marcha!"   ; EXIT
        CASE "NoDisk"        ; cText := "El disco es inaccesible!"         ; EXIT
        CASE "NoFile"        ; cText := "El archivo no existe!"            ; EXIT
        CASE "SetPath"       ; cText := "Fije la ruta"                     ; EXIT
        CASE "ListRefresh"   ; cText := "Se actualizará la lista."         ; EXIT
        CASE "OpenFilePage"  ; cText := "Abrir archivo en la página"       ; EXIT
        CASE "PageNum"       ; cText := "Número de página"                 ; EXIT
        CASE "SelFolder"     ; cText := "Seleccione la carpeta SumatraPDF" ; EXIT
          CASE "OnlyNames"     ; cText := "Only &names"                      ; EXIT
          CASE "FilesAmount"   ; cText := "Amount of &files"                 ; EXIT
          CASE "Selected"      ; cText := "&Selected"                        ; EXIT
          CASE "NonExistent"   ; cText := "&Non-existent"                    ; EXIT
          CASE "All"           ; cText := "&All"                             ; EXIT
          CASE "PdfViewUsing"  ; cText := "PDF viewer using"                 ; EXIT
          CASE "Author"        ; cText := "Author"                           ; EXIT
          CASE "Translators"   ; cText := "Translators"                      ; EXIT

        CASE "Open"          ; cText := "Abrir"                            ; EXIT
          CASE "Remove"        ; cText := "&Remove"                          ; EXIT
        CASE "Browse"        ; cText := "Buscar"                           ; EXIT
        CASE "OK"            ; cText := "Ok"                               ; EXIT
        CASE "Cancel"        ; cText := "Cancelar"                         ; EXIT
      ENDSWITCH
      EXIT
  ENDSWITCH

  IF Empty(cText)
    SWITCH cStr
      CASE "File"          ; cText := "&File"                          ; EXIT
      CASE "OpenCurTab"    ; cText := "&Open in current tab"           ; EXIT
      CASE "OpenNewTab"    ; cText := "Open in &new tab"               ; EXIT
      CASE "OpenPage"      ; cText := "Open at &page"                  ; EXIT
      CASE "OpenPageTab"   ; cText := "Open at page in new &tab"       ; EXIT
      CASE "OpenSession"   ; cText := "Open last &session"             ; EXIT
      CASE "RecentFiles"   ; cText := "Recent &files"                  ; EXIT
      CASE "GoToSubDir"    ; cText := "Go to subdirectory"             ; EXIT
      CASE "GoToParentDir" ; cText := "Go to parent directory"         ; EXIT
      CASE "RefreshList"   ; cText := "&Refresh list"                  ; EXIT
      CASE "Exit"          ; cText := "E&xit"                          ; EXIT
      CASE "Document"      ; cText := "&Document"                      ; EXIT
      CASE "SaveAs"        ; cText := "&Save as"                       ; EXIT
      CASE "Print"         ; cText := "&Print"                         ; EXIT
      CASE "Proper"        ; cText := "P&roperties"                    ; EXIT
      CASE "Close"         ; cText := "&Close"                         ; EXIT
      CASE "ChooseDoc"     ; cText := "Choose &document"               ; EXIT
      CASE "GoToFile"      ; cText := "Go to &file"                    ; EXIT
      CASE "Page"          ; cText := "&Page"                          ; EXIT
      CASE "GoTo"          ; cText := "&Go to"                         ; EXIT
      CASE "Prev"          ; cText := "&Previous"                      ; EXIT
      CASE "Next"          ; cText := "&Next"                          ; EXIT
      CASE "First"         ; cText := "&First"                         ; EXIT
      CASE "Last"          ; cText := "&Last"                          ; EXIT
      CASE "Find"          ; cText := "Fi&nd"                          ; EXIT
      CASE "Text"          ; cText := "&Text"                          ; EXIT
      CASE "PrevOccur"     ; cText := "&Previous occurence"            ; EXIT
      CASE "NextOccur"     ; cText := "&Next occurence"                ; EXIT
      CASE "Zoom"          ; cText := "&Zoom"                          ; EXIT
      CASE "SizeDn"        ; cText := "Size &down"                     ; EXIT
      CASE "SizeUp"        ; cText := "Size &up"                       ; EXIT
      CASE "ZoomFactor"    ; cText := "&Zoom factor"                   ; EXIT
      CASE "FitPage"       ; cText := "Fit &page"                      ; EXIT
      CASE "ActualSize"    ; cText := "&Actual size"                   ; EXIT
      CASE "FitWidth"      ; cText := "Fit &width"                     ; EXIT
      CASE "Rotate"        ; cText := "&Rotate"                        ; EXIT
      CASE "Left"          ; cText := "&Left"                          ; EXIT
      CASE "Right"         ; cText := "&Right"                         ; EXIT
      CASE "View"          ; cText := "&View"                          ; EXIT
      CASE "MenuBar"       ; cText := "&Menu bar"                      ; EXIT
      CASE "Toolbar"       ; cText := "&Toolbar"                       ; EXIT
      CASE "Bookmarks"     ; cText := "PDF &bookmarks"                 ; EXIT
      CASE "Show"          ; cText := "&Show"                          ; EXIT
      CASE "ExpandAll"     ; cText := "&Expand all"                    ; EXIT
      CASE "CollapseAll"   ; cText := "&Collapse all"                  ; EXIT
      CASE "Settings"      ; cText := "&Settings"                      ; EXIT
      CASE "OpenAtOnce"    ; cText := "&Open PDF immediately"          ; EXIT
      CASE "RestSession"   ; cText := "&Restore last session on start" ; EXIT
      CASE "TabGoToFile"   ; cText := "&Changing tab, go to file"      ; EXIT
      CASE "EscExit"       ; cText := "&Esc - exit program"            ; EXIT
      CASE "SumatraDir"    ; cText := "&SumatraPDF directory"          ; EXIT
      CASE "Language"      ; cText := "&Language"                      ; EXIT
      CASE "AboutPdfView"  ; cText := "About PdfView"                  ; EXIT
      CASE "AboutSumatra"  ; cText := "About SumatraPDF"               ; EXIT

      CASE "AppRunning"    ; cText := "Program already is running!"    ; EXIT
      CASE "NoDisk"        ; cText := "Disk is not available!"         ; EXIT
      CASE "NoFile"        ; cText := "File does not exist!"           ; EXIT
      CASE "SetPath"       ; cText := "Set path to"                    ; EXIT
      CASE "ListRefresh"   ; cText := "List will be refreshed."        ; EXIT
      CASE "OpenFilePage"  ; cText := "Open file at page"              ; EXIT
      CASE "PageNum"       ; cText := "Page number"                    ; EXIT
      CASE "SelFolder"     ; cText := "Select SumatraPDF folder"       ; EXIT
      CASE "OnlyNames"     ; cText := "Only &names"                    ; EXIT
      CASE "FilesAmount"   ; cText := "Amount of &files"               ; EXIT
      CASE "Selected"      ; cText := "&Selected"                      ; EXIT
      CASE "NonExistent"   ; cText := "&Non-existent"                  ; EXIT
      CASE "All"           ; cText := "&All"                           ; EXIT
      CASE "PdfViewUsing"  ; cText := "PDF viewer using"               ; EXIT
      CASE "Author"        ; cText := "Author"                         ; EXIT
      CASE "Translators"   ; cText := "Translators"                    ; EXIT

      CASE "Open"          ; cText := "&Open"                          ; EXIT
      CASE "Remove"        ; cText := "&Remove"                        ; EXIT
      CASE "Browse"        ; cText := "&Browse"                        ; EXIT
      CASE "OK"            ; cText := "OK"                             ; EXIT
      CASE "Cancel"        ; cText := "&Cancel"                        ; EXIT
    ENDSWITCH
  ENDIF

  IF lRemoveAmpersand == .T.
    cText := StrTran(cText, "&", "", 1, 1)
  ENDIF

RETURN hb_Translate( cText, "UTF8", "CP1251" )
