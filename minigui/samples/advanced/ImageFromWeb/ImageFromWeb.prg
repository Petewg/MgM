/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * View image(s) from website
 * This example was contributed to HMG forum by KDJ 30/Oct/2017
 * Updated by KDJ 28/Nov/2017
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

/*
  In URL field you can type internet address or path to local html file.

  Keyboard:
    Alt+Enter    - maximize/restore main window
    Esc          - quit
    Enter        - view image (also double click on item of image list)
    Ctrl+W       - close view
    Shift+Del    - remove image from list
    Ctrl+C       - copy image address to clipboard
    Ctrl+Shift+C - copy all image addresses to clipboard
    Ctrl+S       - save as
*/

#include "hmg.ch"

#xtranslate IsMaximized ( <hWnd> ) => IsZoomed ( <hWnd> )

STATIC slKeepRatio := .T.
STATIC snPosView   := 0
STATIC scTmpDir


FUNCTION Main()
  LOCAL aImg := { {"Eiffel Tower", "http://media.thisisinsider.com/images/58d919eaf2d0331b008b4bbd-960-720.jpg"}, ;
                  {"London Tower", "https://i2.wp.com/travelbluebook.com/wp-content/uploads/2016/02/Tower-of-London.jpg"}, ;
                  {"Pisa Tower",   "http://media1.britannica.com/eb-media/88/80588-004-0B5DCB41.jpg"}, ;
                  {"Taj Mahal",    "http://images.says.com/uploads/story_source/source_image/547108/2b63.jpg"}, ;
                  {"Tower Bridge", "http://www.goandco.co.uk/images/offices/tower-bridge.jpg"} }
  LOCAL n

  SET FONT TO "MS Shell Dlg", 8

  DEFINE WINDOW MainWnd;
    WIDTH  480 + GetSystemMetrics(7 /*SM_CXFIXEDFRAME*/) * 2;
    HEIGHT 320 + GetSystemMetrics(4 /*SM_CYCAPTION*/) + GetSystemMetrics(8 /*SM_CYFIXEDFRAME*/) * 2;
    MINWIDTH  300;
    MINHEIGHT 200;
    TITLE  "Image from website";
    ICON "download.ico";
    MAIN;
    ON PAINT    PaintFrame(MainWnd.HANDLE, 41, 170, GetProperty('MainWnd', "CLIENTWIDTH") - 180, GetProperty('MainWnd', "CLIENTHEIGHT") - 51 - GetWindowHeight(MainWnd.STATUSBAR.HANDLE));
    ON SIZE     MainWndResize();
    ON MAXIMIZE MainWndResize();
    ON RELEASE  HB_DirRemoveAll(scTmpDir)

    DEFINE LABEL UrlLabel
      ROW    13
      COL    10
      WIDTH  24
      HEIGHT 13
      VALUE  "URL:"
    END LABEL

    DEFINE TEXTBOX UrlTBox
      ROW      10
      COL      35
      HEIGHT   21
      DATATYPE CHARACTER
      ONCHANGE (MainWnd.UrlButton.ENABLED := ! Empty(This.VALUE))
      ONENTER  ImageFind(aImg)
    END TEXTBOX

    DEFINE BUTTON UrlButton
      ROW      9
      WIDTH    20
      HEIGHT   23
      CAPTION  "->"
      ACTION   ImageFind(aImg)
    END BUTTON

    DEFINE GRID PicGrid
      ROW            41
      COL            10
      WIDTH          150
      SHOWHEADERS    .F.
      WIDTHS         {0}
      CELLNAVIGATION .F.
      ONCHANGE       UpdateStatus(aImg)
      ONDBLCLICK     ImageView(aImg)
    END GRID

    DEFINE CONTEXT MENU CONTROL PicGrid
      MENUITEM "View"             + e"\tEnter"			ACTION ImageView(aImg)
      MENUITEM "Close view"       + e"\tCtrl+W"			ACTION ImageClose(aImg)
      MENUITEM "Remove from list" + e"\tShift+Del"		ACTION ImageRemove(aImg)
      SEPARATOR
      MENUITEM "Copy url"         + e"\tCtrl+C(Ins)"		ACTION ImageCopyUrl(aImg, .F.)
      MENUITEM "Copy all urls"    + e"\tCtrl+Shift+C(Ins)"	ACTION ImageCopyUrl(aImg, .T.)
      SEPARATOR
      MENUITEM "Save as"          + e"\tCtrl+S"			ACTION ImageSaveAs(aImg)
    END MENU

    DEFINE CHECKBOX RatioChBox
      COL      10
      WIDTH    150
      HEIGHT   16
      TABSTOP  .F.
      VALUE    slKeepRatio
      CAPTION  "&Keep original aspect ratio"
      ONCHANGE (slKeepRatio := This.VALUE, MainWndResize())
    END CHECKBOX

    DEFINE BUTTON ViewButton
      COL     10
      WIDTH   70
      HEIGHT  23
      CAPTION "View"
      ACTION  ImageView(aImg)
      DEFAULT .T. 
    END BUTTON

    DEFINE BUTTON SaveButton
      COL     90
      WIDTH   70
      HEIGHT  23
      CAPTION "Save as"
      ACTION  ImageSaveAs(aImg)
    END BUTTON

    DEFINE IMAGE PicImage
      STRETCH .T.
    END IMAGE

    DEFINE STATUSBAR
      STATUSITEM ""
      STATUSITEM "" WIDTH 90
    END STATUSBAR

    ON KEY CONTROL+C		ACTION ImageCopyUrl(aImg, .F.)
    ON KEY CONTROL+INSERT	ACTION ImageCopyUrl(aImg, .F.)
    ON KEY CTRL+SHIFT+C		ACTION ImageCopyUrl(aImg, .T.)
    ON KEY CTRL+SHIFT+INSERT	ACTION ImageCopyUrl(aImg, .T.)
    ON KEY CONTROL+S		ACTION ImageSaveAs(aImg)
    ON KEY CONTROL+W		ACTION ImageClose(aImg)
    ON KEY SHIFT+DELETE		ACTION ImageRemove(aImg)
    ON KEY ALT+RETURN		ACTION iif(IsMaximized(MainWnd.HANDLE), MainWnd.RESTORE, MainWnd.MAXIMIZE)
    ON KEY ESCAPE		ACTION MainWnd.RELEASE
  END WINDOW

  MainWnd.UrlTBox.VALUE := "http://www.globalphotos.org/tajmahal.htm"

  FOR n := 1 TO Len(aImg)
    MainWnd.PicGrid.AddItem({aImg[n][1]})
  NEXT

  MainWnd.PicGrid.VALUE := 1

  MainWndResize()
  MainWnd.CENTER
  MainWnd.ACTIVATE

RETURN NIL


FUNCTION MainWndResize()
  LOCAL nHBmp := MainWnd.PicImage.HBITMAP
  LOCAL nCAW  := GetProperty('MainWnd', "CLIENTWIDTH")
  LOCAL nCAH  := GetProperty('MainWnd', "CLIENTHEIGHT") - GetWindowHeight(MainWnd.STATUSBAR.HANDLE)
  LOCAL nPicR := 42
  LOCAL nPicC := 171
  LOCAL nPicW := nCAW - 182
  LOCAL nPicH := nCAH - 53
  LOCAL nPicRatio, nBmpRatio

  IF slKeepRatio .and. (nHBmp != 0)
    nPicRatio := nPicW / nPicH
    nBmpRatio := BT_BitmapWidth(nHBmp) / BT_BitmapHeight(nHBmp)

    IF nPicRatio < nBmpRatio
      nPicH := Int(nPicW / nBmpRatio)
      nPicR += Int((nCAH - 53 - nPicH) / 2)
    ELSEIF nPicRatio > nBmpRatio
      nPicW := Int(nPicH * nBmpRatio)
      nPicC += Int((nCAW - 182 - nPicW) / 2)
    ENDIF
  ENDIF

  MainWnd.UrlTBox.WIDTH   := nCAW - 65
  MainWnd.UrlButton.COL   := nCAW - 30
  MainWnd.PicGrid.HEIGHT  := nCAH - 110
  MainWnd.RatioChBox.ROW  := nCAH - 59
  MainWnd.ViewButton.ROW  := nCAH - 33
  MainWnd.SaveButton.ROW  := nCAH - 33
  MainWnd.PicImage.ROW    := nPicR
  MainWnd.PicImage.COL    := nPicC
  MainWnd.PicImage.WIDTH  := nPicW
  MainWnd.PicImage.HEIGHT := nPicH

  MainWnd.PicGrid.ColumnWIDTH(1) := 150 - GetBorderWidth()/2 - iif(MainWnd.PicGrid.ITEMCOUNT > ListViewGetCountPerPage(MainWnd.PicGrid.HANDLE), GetVScrollBarWidth(), 0)

  MainWnd.PicImage.Refresh

RETURN NIL


FUNCTION UpdateStatus(aImg)
  LOCAL nPos

  IF MainWnd.PicGrid.ITEMCOUNT == 0
    MainWnd.STATUSBAR.Item(1) := ""
    MainWnd.STATUSBAR.Item(2) := ""
  ELSE
    nPos := MainWnd.PicGrid.VALUE

    IF (nPos > 0) .and. (nPos <= Len(aImg))
      MainWnd.STATUSBAR.Item(1) := aImg[MainWnd.PicGrid.VALUE][2]
      MainWnd.STATUSBAR.Item(2) := iif(MainWnd.PicGrid.VALUE == snPosView, HB_NtoS(BT_BitmapWidth(MainWnd.PicImage.HBITMAP)) + "x" + HB_NtoS(BT_BitmapHeight(MainWnd.PicImage.HBITMAP)), "")
    ENDIF
  ENDIF

RETURN NIL


FUNCTION ImageFind(aImg)
  LOCAL cUrl    := AllTrim(MainWnd.UrlTBox.VALUE)
  LOCAL cProto1 := "http://"
  LOCAL cProto2 := "https://"
  LOCAL cHtmlFile
  LOCAL cHtml
  LOCAL aTagImg
  LOCAL aTagA
  LOCAL cImgUrl
  LOCAL nNumLen
  LOCAL n, n1, n2, n3, n4

  IF Empty(cUrl)
    RETURN NIL
  ENDIF

  IF Empty(scTmpDir) .or. (! HB_DirExists(scTmpDir))
    scTmpDir := DirTmpCreate()
  ENDIF

  IF (HB_UTF8Left(cUrl, 7) == cProto1) .or. (HB_UTF8Left(cUrl, 8) == cProto2)
    cHtmlFile := scTmpDir + "s.htm"

    MainWnd.STATUSBAR.Item(1) := "Wait: downloading website"
    MainWnd.STATUSBAR.Item(2) := ""

    IF ! URLDownloadToFile(cUrl, cHtmlFile)
      UpdateStatus(aImg)
      MsgExclamation("Can not download:" + CRLF + cUrl, MainWnd.TITLE)
      RETURN NIL
    ENDIF
  ELSE
    cHtmlFile := cUrl

    IF ! HB_FileExists(cHtmlFile)
      MsgExclamation("File does not exist:" + CRLF + cHtmlFile, MainWnd.TITLE)
      RETURN NIL
    ENDIF
  ENDIF

  cHtml   := HB_MemoRead(cHtmlFile)
  aTagImg := {}
  aTagA   := {}
  n1      := 1

  DO WHILE (n1 := HB_UTF8At("<img ", cHtml, n1)) > 0
    IF (n2 := HB_UTF8At(">", cHtml, n1 + 5)) == 0
      EXIT
    ENDIF

    IF (n3 := HB_UTF8At(' src="', cHtml, n1 + 4, n2 - 1)) > 0
      n3 += 6
      n4 := HB_UTF8At('"', cHtml, n3, n2 - 1)
    ELSE
      n4 := 0
    ENDIF

    IF (n3 == 0) .or. (n4 == 0)
      IF (n3 := HB_UTF8At(' data-src="', cHtml, n1 + 4, n2 - 1)) > 0
        n3 += 11

        IF (n4 := HB_UTF8At('"', cHtml, n3, n2 - 1)) == 0
          n3 := n4
        ENDIF
      ELSE
        n4 := 0
      ENDIF
    ENDIF

    cImgUrl := HB_UTF8SubStr(cHtml, n3, n4 - n3)

    IF ! Empty(cImgUrl)
      IF (! (HB_UTF8Left(cImgUrl, 7)) == cProto1) .and. (! (HB_UTF8Left(cImgUrl, 8) == cProto2))
        IF HB_UTF8Left(cImgUrl, 1) == "/"
          cImgUrl := HB_UTF8Left(cUrl, HB_UTF8At("/", cUrl, 9) - 1) + cImgUrl
        ELSEIF HB_UTF8Left(cImgUrl, 2) == "./"
          cImgUrl := HB_UTF8Left(cUrl, HB_UTF8RAt("/", cUrl)) + HB_UTF8SubStr(cImgUrl, 3)
        ELSEIF HB_UTF8Left(cImgUrl, 3) == "../"
          n := HB_UTF8RAt("/", cUrl)

          DO WHILE HB_UTF8Left(cImgUrl, 3) == "../"
            cImgUrl := HB_UTF8SubStr(cImgUrl, 4)
            n := HB_UTF8RAt("/", cUrl, 0, n - 1)
          ENDDO

          cImgUrl := HB_UTF8Left(cUrl, n) + cImgUrl
        ELSE
          cImgUrl := HB_UTF8Left(cUrl, HB_UTF8RAt("/", cUrl)) + cImgUrl
        ENDIF
      ENDIF

      aAdd(aTagImg, cImgUrl)
    ENDIF

    n1 := n2 + 1
  ENDDO

  n1 := 1

  DO WHILE (n1 := HB_UTF8At("<a ", cHtml, n1)) > 0
    IF (n2 := HB_UTF8At(">", cHtml, n1 + 3)) == 0
      EXIT
    ENDIF

    IF (n3 := HB_UTF8At(' href="', cHtml, n1 + 2, n2 - 1)) > 0
      n3 += 7
      n4 := HB_UTF8At('"', cHtml, n3, n2 - 1)
    ELSE
      n4 := 0
    ENDIF

    cImgUrl := HB_UTF8SubStr(cHtml, n3, n4 - n3)

    IF IsImage(cImgUrl)
      IF (! (HB_UTF8Left(cImgUrl, 7)) == cProto1) .and. (! (HB_UTF8Left(cImgUrl, 8) == cProto2))
        IF HB_UTF8Left(cImgUrl, 1) == "/"
          cImgUrl := HB_UTF8Left(cUrl, HB_UTF8At("/", cUrl, 9) - 1) + cImgUrl
        ELSEIF HB_UTF8Left(cImgUrl, 2) == "./"
          cImgUrl := HB_UTF8Left(cUrl, HB_UTF8RAt("/", cUrl)) + HB_UTF8SubStr(cImgUrl, 3)
        ELSEIF HB_UTF8Left(cImgUrl, 3) == "../"
          n := HB_UTF8RAt("/", cUrl)

          DO WHILE HB_UTF8Left(cImgUrl, 3) == "../"
            cImgUrl := HB_UTF8SubStr(cImgUrl, 4)
            n := HB_UTF8RAt("/", cUrl, 0, n - 1)
          ENDDO

          cImgUrl := HB_UTF8Left(cUrl, n) + cImgUrl
        ELSE
          cImgUrl := HB_UTF8Left(cUrl, HB_UTF8RAt("/", cUrl)) + cImgUrl
        ENDIF
      ENDIF

      aAdd(aTagA, cImgUrl)
    ENDIF

    n1 := n2 + 1
  ENDDO

  IF Empty(aTagImg) .and. Empty(aTagA)
    MsgExclamation("Not found images at:" + CRLF + cUrl, MainWnd.TITLE)
  ELSE
    ImageClose(aImg)
    HB_FileDelete(scTmpDir + "*.*", "HRS")
    aSize(aImg, 0)
    MainWnd.PicGrid.DELETEALLITEMS

    nNumLen := Len(HB_NtoS(Len(aTagImg)))

    FOR n := 1 TO Len(aTagImg)
      aAdd(aImg, {"img_" + StrZero(n, nNumLen), aTagImg[n], HB_NtoS(Len(aImg) + 1)})
      MainWnd.PicGrid.AddItem({aTail(aImg)[1]})
    NEXT

    nNumLen := Len(HB_NtoS(Len(aTagA)))

    FOR n := 1 TO Len(aTagA)
      aAdd(aImg, {"a_" + StrZero(n, nNumLen), aTagA[n], HB_NtoS(Len(aImg) + 1)})
      MainWnd.PicGrid.AddItem({aTail(aImg)[1]})
    NEXT

    MainWnd.PicGrid.VALUE := 1
    MainWnd.PicGrid.SETFOCUS
    MainWndResize()
  ENDIF

RETURN NIL


FUNCTION ImageRemove(aImg)
  LOCAL nPos

  IF MainWnd.PicGrid.ITEMCOUNT > 0
    nPos := MainWnd.PicGrid.VALUE

    IF nPos == snPosView
      MainWnd.PicImage.PICTURE := ""
      snPosView := 0

      MainWndResize()
    ELSEIF nPos < snPosView
      --snPosView
    ENDIF

    HB_aDel(aImg, nPos, .T.)
    MainWnd.PicGrid.DeleteItem(nPos)

    IF nPos > Len(aImg)
      MainWnd.PicGrid.VALUE := nPos - 1
    ENDIF

    MainWndResize()
    UpdateStatus(aImg)
  ENDIF

RETURN NIL


FUNCTION ImageCopyUrl(aImg, lAll)
  LOCAL cText
  LOCAL n

  IF lAll
    cText := ""

    FOR n := 1 TO Len(aImg)
      cText += aImg[n][2] + CRLF
    NEXT

    System.Clipboard := HB_StrShrink(cText, 2)
  ELSE
    System.Clipboard := aImg[MainWnd.PicGrid.VALUE][2]
  ENDIF

RETURN NIL


FUNCTION ImageView(aImg)
  LOCAL nPos := MainWnd.PicGrid.VALUE
  LOCAL cTmpFile

  IF (MainWnd.PicGrid.ITEMCOUNT > 0) .and. (nPos != snPosView)
    cTmpFile := ImageDownload(aImg, nPos)

    IF ! Empty(cTmpFile)
      IF snPosView > 0
        MainWnd.PicGrid.Cell(snPosView, 1) := aImg[snPosView][1]
      ENDIF

      snPosView := nPos
      MainWnd.PicGrid.Cell(nPos, 1) := "  " + aImg[nPos][1]
      MainWnd.PicImage.PICTURE := cTmpFile

      MainWndResize()
      UpdateStatus(aImg)
    ENDIF
  ENDIF

RETURN NIL


FUNCTION ImageClose(aImg)

  IF (MainWnd.PicGrid.ITEMCOUNT > 0) .and. (snPosView > 0)
    MainWnd.PicGrid.Cell(snPosView, 1) := aImg[snPosView][1]
    MainWnd.PicImage.PICTURE := ""
    snPosView := 0

    MainWndResize()
    UpdateStatus(aImg)
  ENDIF

RETURN NIL


FUNCTION ImageSaveAs(aImg)
  LOCAL nPos
  LOCAL cExt
  LOCAL cTargetFile
  LOCAL cTmpFile

  IF MainWnd.PicGrid.ITEMCOUNT > 0
    nPos        := MainWnd.PicGrid.VALUE

    cExt        := GetExtension(aImg[nPos][2])
    cTargetFile := PutFile({{"*" + cExt, "*" + cExt}}, NIL, HB_CWD(), .F., aImg[nPos][1] + cExt, cExt)

    IF ! Empty(cTargetFile)
      cTmpFile := ImageDownload(aImg, nPos)

      IF ! Empty(cTmpFile)
        IF HB_fCopy(cTmpFile, cTargetFile) != 0
          MsgExclamation("Can not save file:" + CRLF + cTargetFile, MainWnd.TITLE)
        ENDIF
      ENDIF
    ENDIF
  ENDIF

RETURN NIL


FUNCTION ImageDownload(aImg, nPos)
  LOCAL cTmpFile

  IF Empty(scTmpDir) .or. (! HB_DirExists(scTmpDir))
    scTmpDir := DirTmpCreate()
  ENDIF

  cTmpFile := scTmpDir + HB_NtoS(nPos) + GetExtension(aImg[nPos][2])

  IF ! HB_FileExists(cTmpFile)
    MainWnd.STATUSBAR.Item(1) := "Wait: downloading image"
    MainWnd.STATUSBAR.Item(2) := ""
    IF URLDownloadToFile(aImg[nPos][2], cTmpFile)
      UpdateStatus(aImg)
    ELSE
      cTmpFile := ""
      UpdateStatus(aImg)
      MsgExclamation("Can not download image:" + CRLF + aImg[nPos][2], MainWnd.TITLE)
    ENDIF
  ENDIF

RETURN cTmpFile


FUNCTION IsImage(cName)

  SWITCH Lower(HB_TokenGet(cName, HB_TokenCount(cName, "."), "."))
    CASE "jpeg"
    CASE "jpg"
    CASE "png"
    CASE "gif"
    CASE "bmp"
      RETURN .T.
  ENDSWITCH

RETURN .F.


FUNCTION GetExtension(cName)
  LOCAL cExt := Lower(HB_TokenGet(cName, HB_TokenCount(cName, "."), "."))

  IF ! ((cExt == "jpeg") .or. (cExt == "jpg") .or. (cExt == "png") .or. (cExt == "gif") .or. (cExt == "bmp"))
    cExt := "jpg"
  ENDIF

RETURN "." + cExt


FUNCTION DirTmpCreate()
  LOCAL cTmpDir := GetTempDir()
  LOCAL cName   := HB_fNameName(GetProgramFileName())
  LOCAL nCount  := 0

  HB_DirBuild(cTmpDir)

  DO WHILE HB_fNameExists(cTmpDir + cName + "_" + HB_NtoS(nCount))
    ++nCount
  ENDDO

  HB_DirCreate(cTmpDir += cName + "_" + HB_NtoS(nCount) + "\")

RETURN cTmpDir


#pragma BEGINDUMP

#include <mgdefs.h>
#include <urlmon.h>


      // IsZoomed(nHWnd)
HB_FUNC( ISZOOMED )
{
   hb_retl( IsZoomed( ( HWND ) HB_PARNL( 1 ) ) );
}


      // PaintFrame(nHWnd, nRow, nCol, nWidth, nHeight)
HB_FUNC( PAINTFRAME )
{
  HWND        hWnd;
  PAINTSTRUCT ps;
  RECT        rc;
  HDC         hdc;

  hWnd = ( HWND ) HB_PARNL( 1 );
  hdc  = BeginPaint( hWnd, &ps );

  if( hdc )
  {
    rc.top    = (LONG) hb_parnl(2);
    rc.left   = (LONG) hb_parnl(3);
    rc.right  = rc.left + (LONG) hb_parnl(4);
    rc.bottom = rc.top  + (LONG) hb_parnl(5);

    DrawEdge( hdc, &rc, EDGE_BUMP, BF_FLAT | BF_RECT );

    EndPaint( hWnd, &ps );
  }
}


      // https://msdn.microsoft.com/en-us/library/ms775123(v=vs.85).aspx
      // URLDownloadToFile(cURL, cFile)
HB_FUNC( URLDOWNLOADTOFILE )
{
  HRESULT hr = URLDownloadToFile( NULL, hb_parc(1), hb_parc(2), 0, NULL );
  
  hb_retl( hr == S_OK );
}

#pragma ENDDUMP
