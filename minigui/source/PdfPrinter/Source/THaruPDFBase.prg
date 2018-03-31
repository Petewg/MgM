/*
 * Proyecto: QuickSQL
 * Fichero: THaruPDFBase.prg
 * Descripción:
 * Autor: Carlos Mora
 * Fecha: 26/03/2013
 */

#include 'hbclass.ch'
#include 'common.ch'
#include 'harupdf.ch'

#define __NODEBUG__
#include 'debug.ch'

#ifdef __XHARBOUR__
#translate HB_HHasKey( <u> ) => HHasKey( <u> )
#endif

//------------------------------------------------------------------------------
CLASS THaruPDFBase

   // Implementación de la clase wrapper, que reemplaza al objeto Printer de FW
   // No se usa directamente sino a través de la
   DATA hPdf
   DATA hPage
   DATA LoadedFonts

   DATA nPageSize INIT HPDF_PAGE_SIZE_A4
   DATA nOrientation INIT HPDF_PAGE_PORTRAIT // HPDF_PAGE_LANDSCAPE
   DATA nHeight, nWidth

   DATA cFileName
   DATA nPermission
   DATA cPassword, cOwnerPassword

   DATA hImageList

   DATA lPreview INIT .F.
   DATA bPreview

   CONSTRUCTOR New()
   METHOD SetPage()
   METHOD SetLandscape()
   METHOD SetPortrait()
   METHOD SetCompression( cMode ) INLINE HPDF_SetCompressionMode( ::hPdf, cMode )
   METHOD SetPermission( cMode )
   METHOD SetAuthor( cAuthor ) INLINE HPDF_SetInfoAttr( ::hPdf, HPDF_INFO_AUTHOR, cAuthor )
   METHOD SetTitle( cTitle ) INLINE HPDF_SetInfoAttr( ::hPdf, HPDF_INFO_TITLE, cTitle )
   METHOD GetAuthor() INLINE HPDF_GetInfoAttr( ::hPdf, HPDF_INFO_AUTHOR )
   METHOD GetTitle() INLINE HPDF_GetInfoAttr( ::hPdf, HPDF_INFO_TITLE )

   METHOD StartPage()
   METHOD EndPage()
   METHOD Say()
   METHOD CmSay()
   METHOD SayRotate( nTop, nLeft, cTxt, oFont, nClrText, nAngle )
   METHOD DefineFont()
   METHOD Cmtr2Pix( nRow, nCol )
   METHOD Mmtr2Pix( nRow, nCol )
   METHOD CmRect2Pix()
   METHOD nVertRes() INLINE 72
   METHOD nHorzRes() INLINE 72
   METHOD nLogPixelX() INLINE 72  // Number of pixels per logical inch
   METHOD nLogPixelY() INLINE 72
   METHOD nVertSize() INLINE HPDF_Page_GetHeight( ::hPage )
   METHOD nHorzSize() INLINE HPDF_Page_GetWidth( ::hPage )
   METHOD SizeInch2Pix()
   METHOD CmSayBitmap()
   METHOD SayBitmap()
   METHOD GetImageFromFile()
   METHOD Line()
   METHOD CmLine()
   METHOD Rect()
   METHOD CmRect()
   MESSAGE Box METHOD Rect
   MESSAGE CmBox METHOD CmRect
   METHOD RoundBox( nTop, nLeft, nBottom, nRight, nWidth, nHeight, oPen, nColor, nBackColor, lFondo )
   METHOD CmRoundBox( nTop, nLeft, nBottom, nRight, nWidth, nHeight, oPen, nColor, nBackColor, lFondo )
   MESSAGE RoundRect METHOD RoundBox
   MESSAGE CmRoundRect METHOD CmRoundBox
   METHOD SetPen()
   METHOD DashLine()
   METHOD CmDashLine()
   METHOD Save()
   METHOD SyncPage()
   METHOD CheckPage()
   METHOD GetTextWidth()
   METHOD GetTextHeight()
   METHOD End()

ENDCLASS

//------------------------------------------------------------------------------
METHOD New( cFileName, cPassword, cOwnerPassword, nPermission, lPreview, bPreview )
//------------------------------------------------------------------------------

   ::hPdf := HPDF_New()
   ::LoadedFonts := {}

   IF ::hPdf == NIL
      hmg_Alert( " Pdf could not been created!" )
      RETURN NIL
   ENDIF

   HPDF_SetCompressionMode( ::hPdf, HPDF_COMP_ALL )

   ::cFileName := cFileName
   ::cPassword := cPassword
   ::cOwnerPassword := cOwnerPassword
   ::nPermission := nPermission

   ::hImageList := { => }

   DEFAULT lPreview TO .F.

   // Mastintin
   IF HB_ISLOGICAL( lPreview )
      ::lPreview := lPreview
      IF HB_ISBLOCK( bPreview )
         ::bPreview := bPreview
      ELSE
         ::bPreview := {|o| HaruOpenPdf( o:cFileName ) }
      ENDIF
   ENDIF

RETURN Self

//------------------------------------------------------------------------------
METHOD SetPage( nPageSize )
//------------------------------------------------------------------------------

   ::nPageSize := nPageSize
   ::SyncPage()

RETURN Self

//------------------------------------------------------------------------------
METHOD SyncPage()
//------------------------------------------------------------------------------

   IF ::hPage != NIL
      HPDF_Page_SetSize( ::hPage, ::nPageSize, ::nOrientation )
      ::nHeight := HPDF_Page_GetHeight( ::hPage )
      ::nWidth  := HPDF_Page_GetWidth( ::hPage )
   ENDIF

RETURN NIL

//------------------------------------------------------------------------------
METHOD CheckPage()
//------------------------------------------------------------------------------

   IF ::hPage == NIL
      ::StartPage()
   ENDIF

RETURN NIL

//------------------------------------------------------------------------------
METHOD SetLandscape()
//------------------------------------------------------------------------------

   ::nOrientation := HPDF_PAGE_LANDSCAPE
   ::SyncPage()

RETURN Self

//------------------------------------------------------------------------------
METHOD SetPortrait()
//------------------------------------------------------------------------------

   ::nOrientation := HPDF_PAGE_PORTRAIT
   ::SyncPage()

RETURN Self

//------------------------------------------------------------------------------
METHOD SetPermission( cMode )
//------------------------------------------------------------------------------

   DEFAULT cMode TO ''

   cMode := Upper( cMode )
   IF ValType( ::nPermission ) != 'N'
      ::nPermission := 0
   ENDIF

   SWITCH cMode
   CASE "READ"     ; ::nPermission += HPDF_ENABLE_READ     ; EXIT
   CASE "PRINT"    ; ::nPermission += HPDF_ENABLE_PRINT    ; EXIT
   CASE "COPY"     ; ::nPermission += HPDF_ENABLE_COPY     ; EXIT
   CASE "EDIT"     ; ::nPermission += HPDF_ENABLE_EDIT     ; EXIT
   CASE "EDIT_ALL" ; ::nPermission += HPDF_ENABLE_EDIT_ALL ; EXIT
   ENDSWITCH

   HPDF_SetPermission( ::hPage, ::nPermission )

RETURN NIL

//------------------------------------------------------------------------------
METHOD StartPage()
//------------------------------------------------------------------------------

   ::hPage := HPDF_AddPage( ::hPdf )
   ::SyncPage()

RETURN Self

//------------------------------------------------------------------------------
METHOD EndPage()
//------------------------------------------------------------------------------

   ::hPage := NIL

RETURN Self

//------------------------------------------------------------------------------
METHOD Say( nRow, nCol, cText, oFont, nWidth, nClrText, nBkMode, nPad )
//------------------------------------------------------------------------------

   LOCAL c, nTextHeight

   HB_SYMBOL_UNUSED( nBkMode )

   ::CheckPage()
   HPDF_Page_BeginText( ::hPage )
   IF oFont == NIL
      nTextHeight := HPDF_Page_GetCurrentFontSize( ::hPage )
   ELSE
      HPDF_Page_SetFontAndSize( ::hPage, oFont[ 1 ], oFont[ 2 ] )
      nTextHeight := oFont[ 2 ]
   ENDIF
   IF ValType( nClrText ) == 'N'
      c := HPDF_Page_GetRGBFill( ::hPage )
      HPDF_Page_SetRGBFill( ::hPage, ( nClrText % 256 ) / 256.00, ( Int( nClrText / 0x100 ) % 256 ) / 256.00, ( Int( nClrText / 0x10000 ) % 256 ) / 256.00 )
   ENDIF

   DO CASE
   CASE nPad == NIL .OR. nPad == HPDF_TALIGN_LEFT
      HPDF_Page_TextOut( ::hPage, nCol, ::nHeight - nRow - nTextHeight, cText )
   CASE nPad == HPDF_TALIGN_RIGHT
      nWidth := HPDF_Page_TextWidth( ::hPage, cText )
      HPDF_Page_TextOut( ::hPage, nCol - nWidth, ::nHeight - nRow - nTextHeight, cText )
      OTHER
      nWidth := HPDF_Page_TextWidth( ::hPage, cText )
      HPDF_Page_TextOut( ::hPage, nCol - nWidth / 2, ::nHeight - nRow - nTextHeight, cText )
   ENDCASE

   IF ValType( c ) == 'A'
      HPDF_Page_SetRGBFill( ::hPage, c[ 1 ], c[ 2 ], c[ 3 ] )
   ENDIF
   HPDF_Page_EndText( ::hPage )

RETURN Self

//------------------------------------------------------------------------------
METHOD CmSay( nRow, nCol, cText, oFont, nWidth, nClrText, nBkMode, nPad, lO2A )
//------------------------------------------------------------------------------

   ::Cmtr2Pix( @nRow, @nCol )
   IF nWidth != Nil
      ::Cmtr2Pix( 0, @nWidth )
   ENDIF
   ::Say( nRow, nCol, cText, oFont, nWidth, nClrText, nBkMode, nPad, lO2A )

RETURN Self

//------------------------------------------------------------------------------
METHOD DefineFont( cFontName, nSize, lEmbed )
//------------------------------------------------------------------------------

   LOCAL font_list := {           ;
      "Courier",                  ;
      "Courier-Bold",             ;
      "Courier-Oblique",          ;
      "Courier-BoldOblique",      ;
      "Helvetica",                ;
      "Helvetica-Bold",           ;
      "Helvetica-Oblique",        ;
      "Helvetica-BoldOblique",    ;
      "Times-Roman",              ;
      "Times-Bold",               ;
      "Times-Italic",             ;
      "Times-BoldItalic",         ;
      "Symbol",                   ;
      "ZapfDingbats"              ;
      }

   LOCAL i, ttf_list

   i := AScan( font_list, {| x| Upper( x ) == Upper( cFontName ) } )
   IF i > 0 // Standard font
      cFontName := font_list[ i ]
   ELSE
      i := AScan( ::LoadedFonts, {| x| Upper( x[ 1 ] ) == Upper( cFontName ) } )
      IF i > 0
         cFontName := ::LoadedFonts[ i ][ 2 ]
         DEBUGMSG 'Activada fuente ' + cFontName
      ELSE
         ttf_list := GetHaruFontList()
         i := AScan( ttf_list, {| x| Upper( x[ 1 ] ) == Upper( cFontName ) } )
         IF i > 0
            cFontName := HPDF_LoadTTFontFromFile( ::hPdf, ttf_list[ i, 2 ], lEmbed )
            DEBUGMSG 'Cargada fuente ' + cFontName
            DEBUGMSG 'Fichero ' + ttf_list[ i, 2 ]
            AAdd( ::LoadedFonts, { ttf_list[ i, 1 ], cFontName } )
         ELSE
            hmg_Alert( 'Fuente desconocida ' + cFontName )
            RETURN NIL
         ENDIF
      ENDIF
   ENDIF

RETURN { HPDF_GetFont( ::hPdf, cFontName, "WinAnsiEncoding" ), nSize }

METHOD Cmtr2Pix( nRow, nCol )

   nRow *= 72 / 2.54
   nCol *= 72 / 2.54

RETURN Self

METHOD Mmtr2Pix( nRow, nCol )

   nRow *= 72 / 25.4
   nCol *= 72 / 25.4

RETURN Self

METHOD CmRect2Pix( aRect )

   LOCAL aTmp[ 4 ]

   aTmp[ 1 ] = Max( 0, aRect[ 1 ] * 72 / 2.54 )
   aTmp[ 2 ] = Max( 0, aRect[ 2 ] * 72 / 2.54 )
   aTmp[ 3 ] = Max( 0, aRect[ 3 ] * 72 / 2.54 )
   aTmp[ 4 ] = Max( 0, aRect[ 4 ] * 72 / 2.54 )

RETURN aTmp

METHOD SizeInch2Pix( nHeight, nWidth )

   nHeight *= 72
   nWidth *= 72

RETURN { nHeight, nWidth }

METHOD GetImageFromFile( cImageFile )

   IF hb_HHasKey( ::hImageList, cImageFile )
      RETURN ::hImageList[ cImageFile ]
   ENDIF
   IF !File( cImageFile )
      IF( Lower( Right( cImageFile, 4 ) ) == '.bmp' ) // En el código esta como bmp, probar si ya fue transformado a png
         cImageFile := Left( cImageFile, Len( cImageFile ) - 3 ) + 'png'
         RETURN ::GetImageFromFile( cImageFile )
      ELSE
         hmg_Alert( cImageFile + ' no encontrado' )
         RETURN NIL
      ENDIF
   ENDIF
   IF( Lower( Right( cImageFile, 4 ) ) == '.png' )
      RETURN ( ::hImageList[ cImageFile ] := HPDF_LoadPngImageFromFile( ::hPdf, cImageFile ) )
   ENDIF

RETURN ( ::hImageList[ cImageFile ] := HPDF_LoadJpegImageFromFile( ::hPdf, cImageFile ) )

METHOD SayBitmap( nRow, nCol, xBitmap, nWidth, nHeight, nRaster )

   LOCAL image

   HB_SYMBOL_UNUSED( nRaster )

   IF !Empty( image := ::GetImageFromFile( xBitmap ) )
      HPDF_Page_DrawImage( ::hPage, image, nCol, ::nHeight - nRow - nHeight, nWidth, nHeight /* iw, ih*/)
   ENDIF

RETURN Self

METHOD Line( nTop, nLeft, nBottom, nRight, oPen )

   IF oPen != NIL
      ::SetPen( oPen )
   ENDIF
   HPDF_Page_MoveTo( ::hPage, nLeft, ::nHeight - nTop )
   HPDF_Page_LineTo( ::hPage, nRight, ::nHeight - nBottom )
   HPDF_Page_Stroke( ::hPage )

RETURN Self

METHOD Save( cFilename )

   FErase( cFilename )

   IF ValType( ::nPermission ) != 'N'
      ::nPermission := ( HPDF_ENABLE_READ + HPDF_ENABLE_PRINT + HPDF_ENABLE_COPY )
   ENDIF

   IF ValType( ::cPassword ) == 'C' .AND. !Empty( ::cPassword )
      IF Empty( ::cOwnerPassword )
         ::cOwnerPassword := ::cPassword + '+1'
      ENDIF
      HPDF_SetPassword( ::hPdf, ::cOwnerPassword, ::cPassword )
      HPDF_SetPermission( ::hPdf, ::nPermission )
   ENDIF

RETURN HPDF_SaveToFile( ::hPdf, cFilename )

METHOD GetTextWidth( cText, oFont )

   HPDF_Page_SetFontAndSize( ::hPage, oFont[ 1 ], oFont[ 2 ] )

RETURN HPDF_Page_TextWidth( ::hPage, cText )

METHOD GetTextHeight( cText, oFont )

   HB_SYMBOL_UNUSED( cText )

   HPDF_Page_SetFontAndSize( ::hPage, oFont[ 1 ], oFont[ 2 ] )

RETURN oFont[ 2 ] // La altura de la fuente cuando la creamos

METHOD End()

   LOCAL nResult

   IF ValType( ::cFileName ) == 'C'
      nResult := ::Save( ::cFileName )
   ENDIF

   HPDF_Free( ::hPdf )

   IF ::lPreview
      Eval( ::bPreview, Self )
   ENDIF

RETURN nResult

METHOD Rect( nTop, nLeft, nBottom, nRight, oPen, nColor )

   ::SetPen( oPen, nColor )

   HPDF_Page_Rectangle( ::hPage, nLeft, ::nHeight - nBottom, nRight - nLeft, nBottom - nTop )
   HPDF_Page_Stroke( ::hPage )

RETURN Self

METHOD CmRect( nTop, nLeft, nBottom, nRight, oPen, nColor )

   ::Rect( nTop * 72 / 2.54, nLeft * 72 / 2.54, nBottom * 72 / 2.54, nRight * 72 / 2.54, oPen, nColor )

RETURN Self

METHOD CmLine( nTop, nLeft, nBottom, nRight, oPen )

   ::Line( nTop * 72 / 2.54, nLeft * 72 / 2.54, nBottom * 72 / 2.54, nRight * 72 / 2.54, oPen )

RETURN Self

METHOD CmDashLine( nTop, nLeft, nBottom, nRight, oPen, nDashMode )

   ::DashLine( nTop * 72 / 2.54, nLeft * 72 / 2.54, nBottom * 72 / 2.54, nRight * 72 / 2.54, oPen, nDashMode )

RETURN Self

METHOD DashLine( nTop, nLeft, nBottom, nRight, oPen, nDashMode )

   HB_SYMBOL_UNUSED( nDashMode )

   HPDF_Page_SetDash( ::hPage, { 3, 7 }, 2, 2 )
   ::Line( nTop, nLeft, nBottom, nRight, oPen )
   HPDF_Page_SetDash( ::hPage, NIL, 0, 0 )

RETURN Self

METHOD CmSayBitmap( nRow, nCol, xBitmap, nWidth, nHeight, nRaster )

RETURN ::SayBitmap( nRow * 72 / 2.54, nCol * 72 / 2.54, xBitmap, nWidth * 72 / 2.54, nHeight * 72 / 2.54, nRaster )

METHOD RoundBox( nTop, nLeft, nBottom, nRight, nWidth, nHeight, oPen, nColor, nBackColor )

   LOCAL nRay
   LOCAL xposTop, xposBotton
   LOCAL nRound

   DEFAULT nWidth To 0, nHeight TO 0

   nRound:= Min( nWidth, nHeight )

   HPDF_Page_GSave( ::hPage )

   ::SetPen( oPen, nColor )

   IF HB_ISNUMERIC( nBackColor )
      HPDF_Page_SetRGBFill( ::hPage, ( nBackColor  % 256 ) / 256.00, ( Int( nBackColor / 0x100 )  % 256 )  / 256.00, ( Int( nBackColor / 0x10000 ) % 256 ) / 256.00 )
   ENDIF

   IF Empty( nRound )

      HPDF_Page_Rectangle( ::hPage, nLeft, ::nHeight - nBottom, nRight - nLeft,  nBottom - nTop )

   ELSE

      nRay = Round( iif( ::nWidth > ::nHeight, Min( nRound,Int( ::nHeight / 2 ) ), Min( nRound,Int(::nWidth / 2 ) ) ), 0 )

      xposTop := ::nHeight - nTop
      xposBotton := ::nHeight - nBottom

      HPDF_Page_MoveTo ( ::hPage, nLeft + nRay,  xposTop )
      HPDF_Page_LineTo ( ::hPage, nRight - nRay, xposTop )

      HPDF_Page_CurveTo( ::hPage, nRight, xposTop, nRight,  xposTop, nRight,  xposTop - nRay )

      HPDF_Page_LineTo ( ::hPage, nRight, xposBotton + nRay )
      HPDF_Page_CurveTo( ::hPage, nRight, xposBotton, nRight, xposBotton, nRight - nRay,  xposBotton  )
      HPDF_Page_LineTo ( ::hPage, nLeft + nRay, xposBotton )
      HPDF_Page_CurveTo( ::hPage, nLeft, xposBotton,  nLeft, xposBotton, nLeft, xposBotton + nRay )

      HPDF_Page_LineTo ( ::hPage, nLeft, xposTop - nRay )
      HPDF_Page_CurveTo( ::hPage, nLeft, xposTop,  nLeft, xposTop, nLeft + nRay, xposTop )


   ENDIF

   IF HB_ISNUMERIC( nBackColor )
      HPDF_Page_FillStroke ( ::hPage )
   ELSE
      HPDF_Page_Stroke ( ::hPage )
   ENDIF

   HPDF_Page_GRestore( ::hPage )

RETURN Self

METHOD SetPen( oPen, nColor )
   IF oPen != NIL
      IF ValType( oPen ) == 'N'
         HPDF_Page_SetLineWidth( ::hPage, oPen )
      ELSE
         HPDF_Page_SetLineWidth( ::hPage, oPen:nWidth )
         nColor:= oPen:nColor
      ENDIF
   ENDIF
   IF ValType( nColor ) == 'N'
      HPDF_Page_SetRGBStroke( ::hPage, ( nColor % 256 ) / 256.00, ( Int( nColor / 0x100 ) % 256 ) / 256.00, ( Int( nColor / 0x10000 ) % 256 ) / 256.00 )
   ENDIF

RETURN Self

METHOD CmRoundBox( nTop, nLeft, nBottom, nRight, nWidth, nHeight, oPen, nColor, nBackColor, lFondo )

RETURN ::RoundBox( nTop * 72 / 2.54, nLeft * 72 / 2.54, nBottom * 72 / 2.54, nRight * 72 / 2.54, nWidth * 72 / 2.54, nHeight * 72 / 2.54, oPen, nColor, nBackColor, lFondo )

METHOD SayRotate( nTop, nLeft, cTxt, oFont, nClrText, nAngle )

   LOCAL aBackColor
   LOCAL nRadian := ( nAngle / 180 ) * 3.141592 /* Calcurate the radian value. */

    IF ValType( nClrText ) == 'N'
      aBackColor:= HPDF_Page_GetRGBFill( ::hPage )
      HPDF_Page_SetRGBFill( ::hPage, ( nClrText % 256 ) / 256.00, ( Int( nClrText / 0x100 ) % 256 ) / 256.00, ( Int( nClrText / 0x10000 ) % 256 ) / 256.00 )
   ENDIF

   /* FONT and SIZE*/
   If !Empty( oFont )
       HPDF_Page_SetFontAndSize( ::hPage, oFont[1], oFont[2] )
   EndI

   /* Rotating text */
   HPDF_Page_BeginText( ::hPage )
   HPDF_Page_SetTextMatrix( ::hPage, cos( nRadian ),;
                                     sin( nRadian ),;
                                     -( sin( nRadian ) ),;
                                     cos( nRadian ), nLeft, HPDF_Page_GetHeight( ::hPage )-( nTop ) )
   HPDF_Page_ShowText( ::hPage, cTxt )

   IF ValType( aBackColor ) == 'A'
      HPDF_Page_SetRGBFill( ::hPage, aBackColor[1], aBackColor[2], aBackColor[3] )
   ENDIF

   HPDF_Page_EndText( ::hPage )

RETURN Self
