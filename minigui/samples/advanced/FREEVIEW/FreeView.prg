/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * FreeImage.dll should present to use this sample
 * http://freeimage.sourceforge.net/
 *
 * Copyright 2003-2015 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "FreeImage.ch"

#include "minigui.ch"
#include "winprint.ch"

#xcommand ON KEY SPACE [ OF <parent> ] ACTION <action> ;
      => ;
      _DefineHotKey ( < "parent" >, 0, VK_SPACE, < { action } > )

#xcommand ON KEY GRAYPLUS [ OF <parent> ] ACTION <action> ;
      => ;
      _DefineHotKey ( < "parent" >, 0, VK_ADD, < { action } > )

#xcommand ON KEY GRAYMINUS [ OF <parent> ] ACTION <action> ;
      => ;
      _DefineHotKey ( < "parent" >, 0, VK_SUBTRACT, < { action } > )

#define PROGRAM 'FreeImage Viewer Lite'
#define VERSION ' version 1.6'
#define COPYRIGHT ' 2003-2015 Grigory Filatov'

#define MsgAlert( c ) MsgAlert( c, "Attention" )
#define CLR_DEFAULT 0xff000000

STATIC handle, nWidth, nHeight, cFile := "", nKoef := 1, aFiles := {}, nItem := 1, nLoadTime := 0, cSaveFile

MEMVAR nScrWidth, nScrHeight
MEMVAR nLen, nWidthOrig, nHeightOrig


FUNCTION Main( fname )

   LOCAL nLen := 0, aRect := GetDesktopArea()
   PRIVATE nScrWidth := aRect[ 3 ] - aRect[ 1 ], nScrHeight := aRect[ 4 ] - aRect[ 2 ]

   DEFAULT fname := "FreeView.jpg"

   IF !File( 'FreeImage.Dll' )
      MsgAlert( "Can't found the FreeImage.Dll" )
      RETURN NIL
   ENDIF

   fi_Initialise()

   cFile := fname
   aFiles := Directory( "*.JPG" )
   AEval( Directory( "*.JPEG" ), {| e| AAdd( aFiles, e ) } )
   AEval( Directory( "*.PNG" ), {| e| AAdd( aFiles, e ) } )
   AEval( Directory( "*.BMP" ), {| e| AAdd( aFiles, e ) } )
   AEval( Directory( "*.TIF" ), {| e| AAdd( aFiles, e ) } )
   AEval( Directory( "*.PSD" ), {| e| AAdd( aFiles, e ) } )
   AEval( Directory( "*.ICO" ), {| e| AAdd( aFiles, e ) } )
   nLen := Len( aFiles )
   nItem := AScan( aFiles, {| e| Upper( e[ 1 ] ) = Upper( cFile ) } )

   SET CENTURY ON
   SET DATE GERMAN

   DEFINE WINDOW Form_Main ;
      AT 0, 0 ;
      WIDTH 520 HEIGHT 354 ;
      TITLE PROGRAM ;
      ICON 'IMAGE' ;
      MAIN ;
      ON INIT IF( fname <> "FreeView.jpg", FileOpen( fname, .F. ), ( handle := FI_Load( FIF_JPEG, fname, JPEG_DEFAULT ), ;
         nWidth := FI_GetWidth( handle ), nHeight := FI_GetHeight( handle ), ;
         Form_Main.StatusBar.Item( 1 ) := hb_ntos( nWidth ) + " x " + hb_ntos( nHeight ), ;
         Form_Main.StatusBar.Item( 2 ) := hb_ntos( nItem ) + "/" + hb_ntos( nLen ), ;
         Form_Main.StatusBar.Item( 3 ) := Str( nKoef * 100, 4 ) + " %", ;
         Form_Main.StatusBar.Item( 4 ) := LTrim( Str( filesize( fname ) / 1024 ) ) + " KB", ;
         Form_Main.StatusBar.Item( 5 ) := DToC( filedate( fname ) ) + " / " + cfiletime( fname ), ;
         Form_Main.Width  := nWidth + GetBorderWidth() + 4, ;
         Form_Main.Height := nHeight + GetTitleHeight() + 64, ;
         PaintWindow() ) ) ;
      ON PAINT PaintWindow() ;
      ON RELEASE fi_Deinitialise() ;
      FONT 'MS Sans Serif' SIZE 9

   DEFINE MAIN MENU

   DEFINE POPUP "&File"
      MENUITEM "&Open" + Chr( 9 ) + " Ctrl+O" ACTION FileOpen()
      SEPARATOR
      MENUITEM "&Save" + Chr( 9 ) + " Ctrl+S" ACTION FileSave()
      MENUITEM "Save &as..." + Chr( 9 ) + "Ctrl+A" ACTION FileSaveAs()
      SEPARATOR
      MENUITEM "&Print" + Chr( 9 ) + " Ctrl+P" ACTION FilePrint()
      SEPARATOR
      MENUITEM "E&xit" + Chr( 9 ) + " Esc" ACTION ReleaseAllWindows()
   END POPUP

   DEFINE POPUP "&View"
      MENUITEM "&Information" + Chr( 9 ) + " Ctrl+I" ACTION PictInfo()
      SEPARATOR
      MENUITEM "&Full screen" + Chr( 9 ) + " Ctrl+Enter" ACTION FullScreen()
      SEPARATOR
      MENUITEM "&Zoom In" + Chr( 9 ) + " Gray +" ACTION Zoom( 1 )
      MENUITEM "Zoom &Out" + Chr( 9 ) + " Gray -" ACTION Zoom( -1 )
      MENUITEM "Original &size" + Chr( 9 ) + " Ctrl+H" ACTION Zoom( 0 )
      SEPARATOR
      MENUITEM "Rotate &Left" + Chr( 9 ) + " Ctrl+L" ACTION Rotate( 90 )
      MENUITEM "Rotate &Right" + Chr( 9 ) + " Ctrl+R" ACTION Rotate( -90 )
   END POPUP

   DEFINE POPUP "&Help"
      MENUITEM "&About" ACTION MsgAbout()
   END POPUP

   END MENU

   ON KEY F12 ACTION Form_Main.Minimize

   ON KEY ESCAPE ACTION ReleaseAllWindows()

   ON KEY CONTROL + RETURN ACTION FullScreen()

   ON KEY CONTROL + O ACTION FileOpen()

   ON KEY CONTROL + S ACTION FileSave()

   ON KEY CONTROL + A ACTION FileSaveAs()

   ON KEY CONTROL + P ACTION FilePrint()

   ON KEY CONTROL + I ACTION PictInfo()

   ON KEY CONTROL + L ACTION Rotate( 90 )

   ON KEY CONTROL + R ACTION Rotate( -90 )

   ON KEY CONTROL + H ACTION Zoom( 0 )

   ON KEY GRAYPLUS ACTION Zoom( 1 )

   ON KEY GRAYMINUS ACTION Zoom( -1 )

   ON KEY HOME ACTION ( nItem := 1, Next( 0 ) )

   ON KEY END ACTION ( nItem := Len( aFiles ), Next( 0 ) )

   ON KEY BACK ACTION Next( -1 )

   ON KEY SPACE ACTION Next( 1 )

   @ 8, 336 TEXTBOX Text_1 HEIGHT 20 WIDTH 80 VALUE iif( Empty( nLen ), "", hb_ntos( nItem ) + "/" + hb_ntos( nLen ) )

   DEFINE IMAGELIST ImageList_1 ;
      BUTTONSIZE 24, 24 ;
      IMAGE { 'tb_24' } ;
      COLORMASK CLR_DEFAULT ;
      IMAGECOUNT 19 ;
      MASK

   DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 24, 24 IMAGELIST 'ImageList_1' FLAT BORDER

   BUTTON Button_1  ;
      PICTUREINDEX 0 ;
      ADJUST ;
      TOOLTIP 'Open' ;
      ACTION FileOpen()

   BUTTON Button_2 ;
      PICTUREINDEX 3 ;
      ADJUST ;
      TOOLTIP 'Save as' ;
      ACTION FileSaveAs()

   BUTTON Button_3;
      PICTUREINDEX 4 ;
      ADJUST ;
      TOOLTIP 'Print' ;
      ACTION FilePrint() SEPARATOR

   BUTTON Button_4;
      PICTUREINDEX 10 ;
      ADJUST ;
      TOOLTIP 'Info' ;
      ACTION PictInfo()

   BUTTON Button_5 ;
      PICTUREINDEX 11 ;
      ADJUST ;
      TOOLTIP 'Zoom out' ;
      ACTION Zoom( 1 )

   BUTTON Button_6 ;
      PICTUREINDEX 12 ;
      ADJUST ;
      TOOLTIP 'Zoom in' ;
      ACTION Zoom( -1 )

   BUTTON Button_7 ;
      PICTUREINDEX 15 ;
      ADJUST ;
      TOOLTIP 'Rotate Left' ;
      ACTION Rotate( 90 )

   BUTTON Button_8 ;
      PICTUREINDEX 16 ;
      ADJUST ;
      TOOLTIP 'Rotate Right' ;
      ACTION Rotate( -90 ) SEPARATOR

   BUTTON Button_9 ;
      PICTUREINDEX 13 ;
      ADJUST ;
      TOOLTIP 'Previous' ;
      ACTION Next( -1 )

   BUTTON Button_10 ;
      PICTUREINDEX 14 ;
      ADJUST ;
      TOOLTIP 'Next' ;
      ACTION Next( 1 )

   END TOOLBAR

   Form_Main.Button_2.Enabled := !Empty( nLen )
   Form_Main.Button_3.Enabled := !Empty( nLen )
   Form_Main.Button_4.Enabled := !Empty( nLen )
   Form_Main.Button_5.Enabled := !Empty( nLen )
   Form_Main.Button_6.Enabled := !Empty( nLen )
   Form_Main.Button_7.Enabled := ( nLen > 1.OR. fname <> "FreeView.jpg" )
   Form_Main.Button_8.Enabled := ( nLen > 1.OR. fname <> "FreeView.jpg" )
   Form_Main.Button_9.Enabled := ( nLen > 1 )
   Form_Main.Button_10.Enabled := ( nLen > 1 )

   DEFINE STATUSBAR
      STATUSITEM "No file loaded" WIDTH 80
      STATUSITEM "" WIDTH 60
      STATUSITEM "" WIDTH 52 ACTION Zoom( 0 )
      STATUSITEM "" WIDTH 80
      STATUSITEM "" WIDTH 124
   END STATUSBAR

   END WINDOW

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW Form_Main

RETURN NIL


STATIC FUNCTION FileOpen( fname, lInit )

   LOCAL cPath := "\" + CurDir() + IF( Empty( CurDir() ), "", "\" ), ;
      nLen := Len( aFiles ), nFormWidth, nFormHeight, nStart

   DEFAULT fname := "", lInit :=.T.

   IF Empty( fname )
      fname := GetFile( { { "Image files (*.bmp;*.jpg;*.jpeg;*.gif;*.png;*.psd;*.tif;*.ico)", ;
         "*.bmp;*.jpg;*.jpeg;*.gif;*.png;*.psd;*.tif;*.ico" } }, "Open", cPath )
   ELSE
      fname := IF( At( '"', fname ) > 0, StrTran( fname, '"', '' ), fname )
   ENDIF

   IF !Empty( fname ).AND. File( fname )
      IF handle != Nil
         FI_Unload( handle )
         handle := Nil
      ENDIF
      cFile := fname
      IF lInit
         aFiles := Directory( "*.JPG" )
         AEval( Directory( "*.JPEG" ), {| e| AAdd( aFiles, e ) } )
         AEval( Directory( "*.PNG" ), {| e| AAdd( aFiles, e ) } )
         AEval( Directory( "*.BMP" ), {| e| AAdd( aFiles, e ) } )
         AEval( Directory( "*.GIF" ), {| e| AAdd( aFiles, e ) } )
         AEval( Directory( "*.TIF" ), {| e| AAdd( aFiles, e ) } )
         AEval( Directory( "*.PSD" ), {| e| AAdd( aFiles, e ) } )
         AEval( Directory( "*.ICO" ), {| e| AAdd( aFiles, e ) } )
         nLen := Len( aFiles )
         nItem := AScan( aFiles, {| e| Upper( e[ 1 ] ) = Upper( cFileNoPath( cFile ) ) } )
      ENDIF
      nKoef := 1

      nStart := Seconds()
      handle := FI_Load( fi_GetFileType( fname, 0 ), fname, 0 )
      nLoadTime := Seconds() - nStart

      nWidth  := FI_GetWidth( handle )
      nHeight := FI_GetHeight( handle )

      DO WHILE.T.
         nFormWidth  := Round( nWidth * nKoef, 0 ) + GetBorderWidth() + 4
         nFormHeight := Round( nHeight * nKoef, 0 ) + GetTitleHeight() + 2 * GetBorderHeight() + GetMenuBarHeight() + IF( IsWinNT(), 60, 56 )
         IF ( nFormWidth <= nScrWidth.AND. nFormHeight <= nScrHeight ).OR. nKoef < 0.11
            EXIT
         ENDIF
         nKoef -= 0.01
      ENDDO

      Form_Main.Width := IF( nFormWidth < 400, 400, nFormWidth )
      Form_Main.Height := IF( nFormHeight < 100, 100, nFormHeight )

      IF !Form_Main.Button_2.Enabled.OR. lInit
         Form_Main.Button_2.Enabled :=.T.
         Form_Main.Button_3.Enabled :=.T.
         Form_Main.Button_4.Enabled :=.T.
         Form_Main.Button_5.Enabled :=.T.
         Form_Main.Button_6.Enabled :=.T.
         Form_Main.Button_7.Enabled := ( nLen > 1.OR. fname <> "FreeView.jpg" )
         Form_Main.Button_8.Enabled := ( nLen > 1.OR. fname <> "FreeView.jpg" )
         Form_Main.Button_9.Enabled := ( nLen > 1 )
         Form_Main.Button_10.Enabled := ( nLen > 1 )
      ENDIF
      Form_Main.Text_1.Value := hb_ntos( nItem ) + "/" + hb_ntos( nLen )

      Form_Main.Title := cFileNoPath( fname ) + ' - ' + PROGRAM + ;
         IF( nKoef # 1, " (Zoom: " + hb_ntos( Round( nKoef * nWidth, 0 ) ) + " x " + hb_ntos( Round( nKoef * nHeight, 0 ) ) + ")", "" )
      Form_Main.StatusBar.Item( 1 ) := hb_ntos( nWidth ) + " x " + hb_ntos( nHeight )
      Form_Main.StatusBar.Item( 2 ) := hb_ntos( nItem ) + "/" + hb_ntos( nLen )
      Form_Main.StatusBar.Item( 3 ) := Str( nKoef * 100, 4 ) + " %"
      Form_Main.StatusBar.Item( 4 ) := LTrim( Str( aFiles[ nItem ][ 2 ] / 1024 ) ) + " KB"
      Form_Main.StatusBar.Item( 5 ) := DToC( aFiles[ nItem ][ 3 ] ) + " / " + aFiles[ nItem ][ 4 ]

      PaintWindow()
      Form_Main.Center
   ENDIF

RETURN NIL


STATIC FUNCTION FileSave()

   LOCAL cPath := "\" + CurDir() + IF( Empty( CurDir() ), "", "\" )
   LOCAL cExt := Lower( cFileExt( cFile ) ), nFif, nFormat, cSaveFile, nIndex
	
   IF handle == Nil
      RETURN NIL
   ENDIF

   IF cExt == "jpg".OR. cExt == "jpeg"
      nFif := FIF_JPEG
      nFormat := JPEG_DEFAULT
      nIndex := 2
   ELSEIF cExt == "png"
      nFif := FIF_PNG
      nFormat := PNG_DEFAULT
      nIndex := 3
   ELSE
      nFif := FIF_BMP
      nFormat := BMP_DEFAULT
      nIndex := 1
   ENDIF

   cSaveFile := PutFile2( { { "Bmp files (*.bmp)", "*.bmp" }, { "Jpg files (*.jpg;*.jpeg)", "*.jpg;*.jpeg" }, ;
      { "Png files (*.png)", "*.png" } }, 'Save...', cPath,.T., @nIndex )

   IF !Empty( cSaveFile )
      cSaveFile := IF( At( ".", cSaveFile ) > 0, cFileNoPath( cSaveFile ), cSaveFile )

      IF.NOT. FI_Save( nFif, handle, cSaveFile + "." + cExt, nFormat )
         MsgAlert( "Can't save a file" )
      ENDIF
   ENDIF

RETURN NIL


STATIC FUNCTION FileSaveAs()

   LOCAL cPath := "\" + CurDir() + IF( Empty( CurDir() ), "", "\" )
   LOCAL cExt := Lower( cFileExt( cFile ) ), nFif, nFormat, cSaveFile, nIndex
	
   IF handle == Nil
      RETURN NIL
   ENDIF

   IF cExt == "jpg".OR. cExt == "jpeg"
      nIndex := 2
   ELSEIF cExt == "png"
      nIndex := 3
   ELSE
      nIndex := 1
   ENDIF
   cSaveFile := PutFile2( { { "Bmp files (*.bmp)", "*.bmp" }, { "Jpg files (*.jpg;*.jpeg)", "*.jpg;*.jpeg" }, ;
      { "Png files (*.png)", "*.png" } }, 'Save Image As...', cPath,.T., @nIndex )

   IF !Empty( cSaveFile )
      IF nIndex == 2
         nFif := FIF_JPEG
         nFormat := JPEG_DEFAULT
         cExt := "jpg"
      ELSEIF nIndex == 3
         nFif := FIF_PNG
         nFormat := PNG_DEFAULT
         cExt := "png"
      ELSE
         nFif := FIF_BMP
         nFormat := BMP_DEFAULT
         cExt := "bmp"
      ENDIF

      cSaveFile := IF( At( ".", cSaveFile ) > 0, cSaveFile, cSaveFile + "." + cExt )

      IF.NOT. FI_Save( nFif, handle, cSaveFile, nFormat )
         MsgAlert( "Can't save a file" )
      ENDIF
   ENDIF

RETURN NIL


STATIC FUNCTION FullScreen()

   LOCAL nMode := IF( nWidth < nScrWidth.AND. nHeight < nScrHeight, 0, 2 )
   PRIVATE nLen := Len( aFiles ), nWidthOrig := nWidth, nHeightOrig := nHeight

   cSaveFile := GetTempFolder() + "\" + cFileNoExt( cFile ) + ".bmp"

   DEFINE WINDOW Form_2 AT 0, 0 ;
      WIDTH GetDesktopWidth() HEIGHT GetDesktopHeight() ;
      CHILD TOPMOST NOSIZE NOCAPTION ;
      ON INIT ( FI_Save( FIF_BMP, handle, cSaveFile, BMP_DEFAULT ), ;
         DrawPicture( GetFormHandle( "Form_2" ), cSaveFile, nMode ), ;
         Form_2.Label_1.Value := cFile + " [ " + hb_ntos( nItem ) + " / " + hb_ntos( nLen ) + " ]" ) ;
      ON RELEASE ( FErase( cSaveFile ), ;
         Form_Main.Width  := Round( nWidth * nKoef, 0 ) + GetBorderWidth() + 4, ;
         Form_Main.Height := Round( nHeight * nKoef, 0 ) + GetTitleHeight() + GetBorderHeight() + GetMenuBarHeight() + 60, ;
         IF( Form_Main.Width < 400, Form_Main.Width := 400, ), ;
         IF( Form_Main.Height < 100, Form_Main.Height := 100, ), Form_Main.Center ) ;
      BACKCOLOR BLACK

   ON KEY ESCAPE ACTION Form_2.Release

   ON KEY RETURN ACTION Form_2.Release

   ON KEY CONTROL + RETURN ACTION Form_2.Release

   ON KEY LEFT ACTION NextFS( -1 )

   ON KEY RIGHT ACTION NextFS( 1 )

   ON KEY UP ACTION ( nItem := 1, NextFS( 0 ) )

   ON KEY DOWN ACTION ( nItem := Len( aFiles ), NextFS( 0 ) )

   ON KEY BACK ACTION NextFS( -1 )

   ON KEY SPACE ACTION NextFS( 1 )

   @ 0, 0 LABEL Label_1 VALUE "" ;
      WIDTH nScrWidth HEIGHT 16 ;
      FONT 'Tahoma' SIZE 9 ;
      FONTCOLOR GREEN TRANSPARENT
   END WINDOW

   ACTIVATE WINDOW Form_2

RETURN NIL


STATIC FUNCTION NextFS( nOp )

   LOCAL nMode, fname, clone
   LOCAL nFormWidth := Form_2.Width, nFormHeight := Form_2.Height, nRatio := nWidth / nHeight, nW, nH

   IF nLen > 1
      FErase( cSaveFile )
      FI_Unload( handle )

      IF nOp < 0
         nItem--
         nItem := IF( nItem < 1, nLen, nItem )
      ELSEIF nOp > 0
         nItem++
         nItem := IF( nItem > nLen, 1, nItem )
      ENDIF

      cFile := aFiles[ nItem ][ 1 ]
      cSaveFile := GetTempFolder() + "\" + cFileNoExt( cFile ) + ".bmp"

      fname := CurDrive() + ":\" + CurDir() + IF( Empty( CurDir() ), "", "\" ) + cFile

      handle := FI_Load( fi_GetFileType( fname, 0 ), fname, 0 )

      nWidth  := FI_GetWidth( handle )
      nHeight := FI_GetHeight( handle )

      nMode := IF( nWidth < nScrWidth.AND. nHeight < nScrHeight, 0, 2 )

      IF nWidth > nFormWidth.OR. nHeight > nFormHeight.OR. nWidthOrig >= nFormWidth.OR. nHeightOrig >= nFormHeight
         nW := nFormWidth
         nH := nFormHeight
         IF nRatio >= 1
            nH := Round( nHeight * ( 10 * nW / nWidth ) / 10, 0 )
         ELSE
            nW := Round( nWidth * ( 10 * nH / nHeight ) / 10, 0 )
         ENDIF
         nWidth := nW
         nHeight := nH
         clone := fi_Clone( handle )
         FI_Unload( handle )
         handle := FI_Rescale( clone, nWidth, nHeight, FILTER_BICUBIC )
         fi_Unload( clone )
      ENDIF

      FI_Save( FIF_BMP, handle, cSaveFile, BMP_DEFAULT )

      ERASE WINDOW Form_2
      DrawPicture( GetFormHandle( "Form_2" ), cSaveFile, nMode )

      Form_2.Label_1.Value := cFile + " [ " + hb_ntos( nItem ) + " / " + hb_ntos( nLen ) + " ]"
   ENDIF

RETURN NIL


STATIC FUNCTION Next( nOp )

   LOCAL nLen := Len( aFiles )

   IF nLen > 1
      IF nOp < 0
         nItem--
         nItem := IF( nItem < 1, nLen, nItem )
      ELSEIF nOp > 0
         nItem++
         nItem := IF( nItem > nLen, 1, nItem )
      ENDIF

      FileOpen( aFiles[ nItem ][ 1 ],.F. )
   ELSE
      Form_Main.Text_1.Value := hb_ntos( nItem ) + "/" + hb_ntos( nLen )
   ENDIF

RETURN NIL


STATIC FUNCTION FilePrint()

   LOCAL cTmpFile, nScale := 1 / 3.937, nX, nY, nH, nW

   IF !Empty( cFile ).AND. File( cFile )

      INIT PRINTSYS

      SELECT BY DIALOG

      IF HBPRNERROR != 0
         RETURN NIL
      ENDIF

      cTmpFile := GetTempFolder() + "\" + cFileNoExt( cFile ) + ".bmp"
      FI_Save( FIF_BMP, handle, cTmpFile, BMP_DEFAULT )

      SET UNITS MM       // Sets @... units to milimeters
      SET PAPERSIZE DMPAPER_A4  // Sets paper size to A4

      IF nHeight >= nWidth
         SET ORIENTATION PORTRAIT // Sets paper orientation to portrait
         nH := 250
         nW := 170
      ELSE
         SET ORIENTATION LANDSCAPE // Sets paper orientation to landscape
         nH := 170
         nW := 250
      ENDIF

      SET BIN DMBIN_FIRST    // Use first bin
      SET QUALITY DMRES_HIGH   // Sets print quality to high
      SET COLORMODE DMCOLOR_COLOR  // Set print color mode to color
      SET PREVIEW ON    // Enables print preview
      SET PREVIEW RECT 0, 0, nScrHeight, nScrWidth
      START DOC NAME Left( PROGRAM, 9 )

      START PAGE

      DO WHILE.T.

         nX := Round( nHeight * nScale, 0 )
         nY := Round( nWidth * nScale, 0 )

         IF ( nX <= nH.AND. nY <= nW ).OR. nScale < 0.15
            EXIT
         ENDIF

         nScale -= 0.05

      ENDDO

      @ 15, 20 PICTURE cTmpFile SIZE nX, nY

      END PAGE

      END DOC

      RELEASE PRINTSYS

      FErase( cTmpFile )

   ENDIF

RETURN NIL


STATIC FUNCTION Zoom( nOp )

   LOCAL nPictWidth, nPictHeight

   IF handle == Nil
      RETURN NIL
   ENDIF

   IF Empty( nOp ).AND. nKoef == 1
      RETURN NIL
   ENDIF

   IF Int( nKoef * 10 ) # Round( nKoef, 1 ) * 10
      nKoef := Int( nKoef * 10 ) / 10
   ELSE
      nKoef := Round( nKoef, 1 )
   ENDIF
   IF nOp < 0.AND. nKoef > 0.11
      nKoef -= 0.1
   ELSEIF nOp > 0.AND. nKoef < 9.9
      nKoef += 0.1
   ELSE
      nKoef := 1
   ENDIF

   nPictWidth := Round( nWidth * nKoef, 0 )
   nPictHeight := Round( nHeight * nKoef, 0 )

   Form_Main.Width  := nPictWidth + GetBorderWidth() + 4
   Form_Main.Height := nPictHeight + GetTitleHeight() + GetBorderHeight() + GetMenuBarHeight() + 60

   IF Form_Main.Width < 400
      Form_Main.Width := 400
   ENDIF
   IF Form_Main.Height < 100
      Form_Main.Height := 100
   ENDIF

   Form_Main.Title := cFileNoPath( cFile ) + ' - ' + PROGRAM + ;
      IF( nKoef # 1, " (Zoom: " + hb_ntos( nPictWidth ) + " x " + hb_ntos( nPictHeight ) + ")", "" )
   Form_Main.StatusBar.Item( 3 ) := Str( nKoef * 100, 4 ) + " %"

   InvalidateRect( Application.Handle, 0 )

   Form_Main.Center

RETURN NIL


STATIC FUNCTION PictInfo()

   LOCAL cExt := Lower( cFileExt( cFile ) )
   LOCAL aLabel := {}, cLabel, aText := {}, cText, n

   AAdd( aLabel, "File name:" )
   AAdd( aLabel, "Folder:" )
   AAdd( aLabel, "Compression:" )
   AAdd( aLabel, "Original size:" )
   AAdd( aLabel, "Disk size:" )
   AAdd( aLabel, "Current folder index:" )
   AAdd( aLabel, "File date/time:" )
   AAdd( aLabel, "Loaded in:" )

   AAdd( aText, cFileNoPath( cFile ) )
   AAdd( aText, CurDrive() + ":\" + CurDir() + IF( Empty( CurDir() ), "", "\" ) )
   IF cExt == "jpg"
      AAdd( aText, "JPG" )
   ELSEIF cExt == "bmp"
      AAdd( aText, "None" )
   ELSEIF cExt == "png"
      AAdd( aText, "PNG" )
   ELSEIF cExt == "tif"
      AAdd( aText, "TIFF" )
   ELSEIF cExt == "ico"
      AAdd( aText, "Windows ICON - None" )
   ENDIF
   AAdd( aText, hb_ntos( nWidth ) + " x " + hb_ntos( nHeight ) + " Pixels" )
   AAdd( aText, LTrim( Str( aFiles[ nItem ][ 2 ] / 1024 ) ) + " KB (" + LTrim( Str( aFiles[ nItem ][ 2 ] ) ) + " Bytes)" )
   AAdd( aText, hb_ntos( nItem ) + " / " + hb_ntos( Len( aFiles ) ) )
   AAdd( aText, DToC( aFiles[ nItem ][ 3 ] ) + " / " + aFiles[ nItem ][ 4 ] )
   AAdd( aText, hb_ntos( Int( nLoadTime * 1000 ) ) + " milliseconds" )

   DEFINE WINDOW Form_Info AT 0, 0 ;
      WIDTH 360 HEIGHT 300 ;
      TITLE PROGRAM + " - Image properties" ;
      CHILD ;
      NOSIZE ;
      NOSYSMENU ;
      ON INIT Form_Info.Button_OK. SetFocus ;
      FONT 'MS Sans Serif' ;
      SIZE 9

   @ 8, 8 FRAME Frame_1 ;
      WIDTH 338 ;
      HEIGHT 212

   FOR n := 1 TO Len( aLabel )
      cLabel := "Label_" + hb_ntos( n )
      @ ( n - 1 ) * 24 + 23, 20 LABEL &cLabel ;
         VALUE aLabel[ n ] ;
         WIDTH 100 HEIGHT 20
   NEXT

   FOR n := 1 TO Len( aText )
      cText := "Text_" + hb_ntos( n )
      @ ( n - 1 ) * 24 + 21, 134 TEXTBOX &cText ;
         VALUE aText[ n ] ;
         HEIGHT 20 ;
         WIDTH 200 ;
         READONLY
   NEXT

   @ Form_Info.Height - 68 - IF( IsXPThemeActive(), 4, 0 ), Form_Info.Width / 2 - 50 BUTTON Button_OK ;
      CAPTION "OK" ;
      ACTION Form_Info.Release ;
      WIDTH 96 HEIGHT 32

   END WINDOW

   CENTER WINDOW Form_Info

   ACTIVATE WINDOW Form_Info

RETURN NIL


STATIC FUNCTION Rotate( n )

   LOCAL new_handle
   LOCAL nFormWidth, nFormHeight

   IF handle == Nil
      RETURN NIL
   ENDIF

   IF !( ( new_handle := FI_RotateClassic( handle, n ) ) == Nil )

      FI_Unload( handle )
      handle := new_handle

      nWidth := FI_GetWidth( handle )
      nHeight := FI_GetHeight( handle )

      nKoef := 1

      DO WHILE.T.
         nFormWidth  := Round( nWidth * nKoef, 0 ) + GetBorderWidth() + 4
         nFormHeight := Round( nHeight * nKoef, 0 ) + GetTitleHeight() + 2 * GetBorderHeight() + GetMenuBarHeight() + IF( IsWinNT(), 60, 56 )
         IF ( nFormWidth <= nScrWidth.AND. nFormHeight <= nScrHeight ).OR. nKoef < 0.11
            EXIT
         ENDIF
         nKoef -= 0.01
      ENDDO

      Form_Main.Width := IF( nFormWidth < 400, 400, nFormWidth )
      Form_Main.Height := IF( nFormHeight < 100, 100, nFormHeight )

      PaintWindow()
      Form_Main.Center

   ENDIF

RETURN NIL


STATIC FUNCTION PaintWindow()

   LOCAL pps, hDC

   IF handle == Nil
      RETURN -1
   ENDIF

   hDC := BeginPaint( Application.Handle, @pps )

   FI_WinDraw( handle, hDC, 36, 0, Round( nHeight * nKoef, 0 ) + 36, Round( nWidth * nKoef, 0 ) )

   EndPaint( Application.Handle, pps )

   InvalidateRect( Application.Handle, 0 )

RETURN 0


STATIC FUNCTION MsgAbout()
RETURN MsgInfo( PadC( PROGRAM + VERSION, 40 ) + CRLF + ;
      PadC( "Copyright " + Chr( 169 ) + COPYRIGHT, 40 ) + CRLF + CRLF + ;
      hb_Compiler() + CRLF + Version() + CRLF + ;
      Left( MiniGuiVersion(), 38 ) + CRLF + ;
      "FreeImage.dll version: " + FI_GetVersion() + CRLF + CRLF + ;
      PadC( "This program is Freeware!", 40 ), "About..." )


STATIC FUNCTION cFileTime( cFileName )

   LOCAL aFiles := Directory( cFileName )

RETURN IF( Len( aFiles ) == 1, aFiles[ 1, 4 ], '' )


STATIC FUNCTION cFileExt( cPathMask )

   LOCAL cExt := AllTrim( cFileNoPath( cPathMask ) )
   LOCAL n    := RAt( ".", cExt )

RETURN AllTrim( If( n > 0.AND. Len( cExt ) > n, Right( cExt, Len( cExt ) - n ), "" ) )


STATIC FUNCTION Putfile2 ( aFilter, title, cIniFolder, nochangedir, nFilterIndex )

   LOCAL c := '', n

   IF aFilter == Nil
      aFilter := {}
   ENDIF

   FOR n := 1 TO Len ( aFilter )
      c += aFilter[n ][1 ] + Chr( 0 ) + aFilter[n ][2 ] + Chr( 0 )
   NEXT

RETURN C_PutFile2 ( c, title, cIniFolder, nochangedir, @nFilterIndex )


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

#ifdef __XHARBOUR__
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

#define NIL                        (0)  // Nothing...
//  Drawing styles

#define CENTER                      0
#define TILE                        1
#define STRETCH                     2

HB_FUNC ( DRAWPICTURE )
{
    HWND       hWnd = ( HWND ) hb_parnl( 1 );
    HDC        dc = GetDC( hWnd );
    HANDLE     picture;
    BITMAP     bitmap;
    HDC        bits;
    HANDLE     old;

    POINT      size;
    POINT      origin = { NIL,NIL };

    RECT       box;
    int        row;
    int        col;

    int desktopx = GetSystemMetrics (SM_CXSCREEN);
    int desktopy = GetSystemMetrics (SM_CYSCREEN);

    if ((picture = LoadImage (NIL,hb_parc(2),IMAGE_BITMAP,NIL,NIL,LR_LOADFROMFILE)) == NULL) {
        hb_retl (FALSE);
        }

    if ((bits = CreateCompatibleDC (dc)) == NULL) {
        DeleteObject (picture);
        hb_retl (FALSE);
        }

    if ((old = SelectObject (bits,picture)) == NULL) {
        DeleteObject (picture);
        DeleteDC (bits);
        hb_retl (FALSE);
        }

    SetMapMode (bits,GetMapMode (dc));

    if (!GetObject (picture,sizeof (BITMAP), (LPSTR) &bitmap)) {
        SelectObject (bits,old);
        DeleteObject (picture);
        DeleteDC (bits);
        hb_retl (FALSE);
        }

    size.x = bitmap.bmWidth;
    size.y = bitmap.bmHeight;
    DPtoLP (dc,&size,1);

    origin.x = NIL;
    origin.y = NIL;
    DPtoLP (bits,&origin,1);

    switch (hb_parnl(3)) {

        case CENTER :

             box.left = (desktopx - size.x) / 2;
             box.top  = (desktopy - size.y) / 2;

             BitBlt (dc,
                     box.left,
                     box.top,
                     size.x,
                     size.y,
                     bits,
                     origin.x,
                     origin.y,
                     SRCCOPY);
             break;

        case TILE :

             for (row = NIL; row < ((desktopy / size.y) + 1); row++) {

                 for (col = NIL; col < ((desktopx / size.x) + 1); col++) {

                     box.left = col * size.x;
                     box.top = row * size.y;

                     BitBlt (dc,
                             box.left,
                             box.top,
                             size.x,
                             size.y,
                             bits,
                             origin.x,
                             origin.y,
                             SRCCOPY);
                     }
                 }
              break;

         case STRETCH :

              StretchBlt (dc,
                          NIL,
                          NIL,
                          desktopx,
                          desktopy,
                          bits,
                          origin.x,
                          origin.y,
                          size.x,
                          size.y,
                          SRCCOPY);
              break;
              }

    SelectObject (bits,old);
    DeleteDC     (bits);
    DeleteObject (picture);
    ReleaseDC(hWnd, dc);

    hb_retl (TRUE);
}

HB_FUNC ( C_PUTFILE2 )
{
    OPENFILENAME ofn;
    char buffer[512];

    int flags = OFN_FILEMUSTEXIST | OFN_EXPLORER ;

    if ( hb_parl(4) )
    {
        flags = flags | OFN_NOCHANGEDIR ;
    }

    strcpy( buffer, "" );

    memset( (void*) &ofn, 0, sizeof( OPENFILENAME ) );
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = GetActiveWindow() ;
    ofn.lpstrFilter = hb_parc(1) ;
    ofn.lpstrFile = buffer;
    ofn.nMaxFile = 512;
    ofn.lpstrInitialDir = hb_parc(3);
    ofn.nFilterIndex    = hb_parni(5);
    ofn.lpstrTitle = hb_parc(2) ;
    ofn.Flags = flags;

    if( GetSaveFileName( &ofn ) )
    {
        hb_stornl(ofn.nFilterIndex, 5 );
        hb_retc( ofn.lpstrFile );
    }
    else
    {
        hb_retc( "" );
    }
}

#pragma ENDDUMP
