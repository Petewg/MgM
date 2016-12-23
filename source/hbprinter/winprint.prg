// -----------------------------------------------------------------------------
// HBPRINTER - Harbour Win32 Printing library source code
//
// Copyright 2002-2005 Richard Rylko <rrylko@poczta.onet.pl>
// -----------------------------------------------------------------------------
#define __HBPRN__

#include "HBClass.ch"
#include "minigui.ch"
#include "winprint.ch"

// #define _DEBUG_

/* Background Modes */

#define TRANSPARENT 1
#define OPAQUE  2
#define BKMODE_LAST 2

MEMVAR page, scale, azoom, ahs, npages
MEMVAR dx, dy, ngroup, ath, Iloscstron
MEMVAR aopisy

CLASS HBPrinter

   DATA    hDC          INIT 0
   PROTECT hDCRef       INIT 0
   DATA    PrinterName  INIT ""

   DATA    lEscaped     INIT .F.
   DATA    nFromPage    INIT 1
   DATA    nToPage      INIT 0
   PROTECT CurPage      INIT 1
   DATA    nCopies      INIT 1
   DATA    nWhatToPrint INIT 0
   PROTECT PrintOpt     INIT 1

   DATA    PrinterDefault INIT ""
   DATA    Error INIT 0 READONLY
   DATA    PaperNames INIT {}
   DATA    BINNAMES INIT {}
   DATA    DOCNAME INIT "HBPRINTER"
   DATA    TextColor INIT 0
   DATA    BkColor INIT 0xFFFFFF
   DATA    BkMode INIT 1      // TRANSPARENT
   DATA    PolyFillMode INIT 1
   DATA    Cargo INIT { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
   DATA    FONTS INIT { {}, {}, 0, {} }
   DATA    BRUSHES INIT { {}, {} }
   DATA    PENS INIT { {}, {} }
   DATA    REGIONS INIT { {}, {} }
   DATA    IMAGELISTS INIT { {}, {} }
   DATA    UNITS INIT 0
   DATA    DEVCAPS INIT { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }
   DATA    MAXROW INIT 0
   DATA    MAXCOL INIT 0
   PROTECT METAFILES INIT {}
   PROTECT BasePageName INIT ""
   DATA    PREVIEWMODE INIT .F.
   DATA    THUMBNAILS INIT .F.
   DATA    CLSPREVIEW INIT .T.
   DATA    VIEWPORTORG INIT { 0, 0 }
   DATA    PREVIEWRECT INIT { 0, 0, 0, 0 }
   PROTECT PRINTINGEMF INIT .F.
   DATA    PRINTING INIT .F.
   DATA    PREVIEWSCALE INIT 1
   DATA    Printers INIT {}
   DATA    Ports INIT {}
   PROTECT Version INIT 2.38

   METHOD New()
   METHOD SelectPrinter( cPrinter, lPrev )
   METHOD SetDevMode( what, newvalue )
   METHOD SetUserMode( what, value, value2 )
   METHOD Startdoc( ldocname )
   METHOD SetPage( orient, size, fontname )
   METHOD Startpage()
   METHOD Endpage()
   METHOD Enddoc()
   METHOD SetTextColor( clr )
   METHOD GetTextColor()      INLINE ::TextColor
   METHOD SetBkColor( clr )
   METHOD GetBkColor()        INLINE ::BkColor
   METHOD SetBkMode( nmode )
   METHOD GetBkMode()         INLINE ::BkMode
   METHOD DefineImageList( defname, cpicture, nicons )
   METHOD DrawImageList( defname, nicon, row, col, torow, tocol, lstyle, color )
   METHOD DefineBrush( defname, lstyle, lcolor, lhatch )
   METHOD ModifyBrush( defname, lstyle, lcolor, lhatch )
   METHOD SelectBrush( defname )
   METHOD DefinePen( defname, lstyle, lwidth, lcolor )
   METHOD ModifyPen( defname, lstyle, lwidth, lcolor )
   METHOD SelectPen( defname )
   METHOD DefineFont( defname, lfontname, lfontsize, lfontwidth, langle, lweight, litalic, lunderline, lstrikeout )
   METHOD ModifyFont( defname, lfontname, lfontsize, lfontwidth, langle, lweight, lnweight, litalic, lnitalic, lunderline, lnunderline, lstrikeout, lnstrikeout )
   METHOD SelectFont( defname )
   METHOD GetObjByName( defname, what, retpos )
   METHOD DrawText( row, col, torow, tocol, txt, style, defname )
   METHOD TextOut( row, col, txt, defname )
   METHOD Say( row, col, txt, defname, lcolor, lalign )
   METHOD SetCharset( charset ) INLINE rr_setcharset( charset )
   METHOD Rectangle( row, col, torow, tocol, defpen, defbrush )
   METHOD RoundRect( row, col, torow, tocol, widthellipse, heightellipse, defpen, defbrush )
   METHOD FillRect( row, col, torow, tocol, defbrush )
   METHOD FrameRect( row, col, torow, tocol, defbrush )
   METHOD InvertRect( row, col, torow, tocol )
   METHOD Ellipse( row, col, torow, tocol, defpen, defbrush )
   METHOD Arc( row, col, torow, tocol, rowsarc, colsarc, rowearc, colearc, defpen )
   METHOD ArcTo( row, col, torow, tocol, rowrad1, colrad1, rowrad2, colrad2, defpen )
   METHOD Chord( row, col, torow, tocol, rowrad1, colrad1, rowrad2, colrad2, defpen, defbrush )
   METHOD Pie( row, col, torow, tocol, rowrad1, colrad1, rowrad2, colrad2, defpen, defbrush )
   METHOD Polygon( apoints, defpen, defbrush, style )
   METHOD PolyBezier( apoints, defpen )
   METHOD PolyBezierTo( apoints, defpen )
   METHOD SetUnits( newvalue, r, c )
   METHOD Convert( arr, lsize )
   METHOD DefineRectRgn( defname, row, col, torow, tocol )
   METHOD DefinePolygonRgn( defname, apoints, style )
   METHOD DefineEllipticRgn( defname, row, col, torow, tocol )
   METHOD DefineRoundRectRgn( defname, row, col, torow, tocol, widthellipse, heightellipse )
   METHOD CombineRgn( defname, reg1, reg2, style )
   METHOD SelectClipRgn( defname )
   METHOD DeleteClipRgn()
   METHOD SetPolyFillMode( style )
   METHOD GetPolyFillMode()   INLINE ::PolyFillMode
   METHOD SetViewPortOrg( row, col )
   METHOD GetViewPortOrg()
   METHOD DxColors( par )
   METHOD SetRGB( red, green, blue )
   METHOD SetTextCharExtra( col )
   METHOD GetTextCharExtra()
   METHOD SetTextJustification( col )
   METHOD GetTextJustification()
   METHOD SetTextAlign( style )
   METHOD GetTextAlign()
   METHOD Picture( row, col, torow, tocol, cpicture, extrow, extcol )
   METHOD Line( row, col, torow, tocol, defpen )
   METHOD LineTo( row, col, defpen )
   METHOD SaveMetaFiles( number, filename )
   METHOD GetTextExtent( ctext, apoint, deffont )
   METHOD GetTextExtent_mm( ctext, apoint, deffont )
   METHOD End()
#ifdef _DEBUG_
   METHOD ReportData( l_x1, l_x2, l_x3, l_x4, l_x5, l_x6 )
#endif
   METHOD Preview()
   METHOD PrevPrint( n1 )
   METHOD PrevShow()
   METHOD PrevThumb( nclick )
   METHOD PrevClose( lEsc )
   METHOD PrintOption()
   METHOD GetVersion() INLINE ::Version

ENDCLASS


METHOD New() CLASS HBPrinter

   LOCAL aprnport
   aprnport := rr_getprinters()
   IF aprnport <> ",,"
      aprnport := str2arr( aprnport, ",," )
      AEval( aprnport, {| x, xi | aprnport[ xi ] := str2arr( x, ',' ) } )
      AEval( aprnport, {| x | AAdd( ::Printers, x[ 1 ] ), AAdd( ::ports, x[ 2 ] ) } )
      ::PrinterDefault := RR_GETDEFAULTPRINTER()
   ELSE
      ::error := 1
   ENDIF
   ::BasePageName := GetTempFolder() + "\" + StrZero( Seconds() * 100, 8 ) + "_HBP_print_preview_"

RETURN self

METHOD SelectPrinter( cPrinter, lPrev ) CLASS HBPrinter

   LOCAL txtp := "", txtb := "", t := { 0, 0, 1, 0 }
   IF cPrinter == Nil
      ::hDCRef := rr_getdc( ::PrinterDefault )
      ::hDC := ::hDCRef
      ::PrinterName := ::PrinterDefault
   ELSEIF Empty( cPrinter )
      ::hDCRef := rr_printdialog( t )
      ::nfrompage := t[ 1 ]
      ::ntopage := t[ 2 ]
      ::ncopies := t[ 3 ]
      ::nwhattoprint := t[ 4 ]
      ::hDC := ::hDCRef
      ::PrinterName := rr_PrinterName()
   ELSE
      ::hDCRef := rr_getdc( cPrinter )
      ::hDC := ::hDCRef
      ::PrinterName := cPrinter
   ENDIF
   IF ValType( lPrev ) == "L"
      IF lprev
         ::PreviewMode := .T.
      ENDIF
   ENDIF
   IF ::hDC == 0
      ::error := 1
      ::PrinterName := ""
   ELSE
      rr_devicecapabilities( @txtp, @txtb )
      ::PaperNames := str2arr( txtp, ",," )
      ::BinNames := str2arr( txtb, ",," )
      AEval( ::BinNames, {| x, xi | ::BinNames[ xi ] := str2arr( x, ',' ) } )
      AEval( ::PaperNames, {| x, xi | ::PaperNames[ xi ] := str2arr( x, ',' ) } )
      AAdd( ::Fonts[ 1 ], rr_getcurrentobject( 1 ) ) ; AAdd( ::Fonts[ 2 ], "*" ) ; AAdd( ::Fonts[ 4 ], {} )
      AAdd( ::Fonts[ 1 ], rr_getcurrentobject( 1 ) ) ; AAdd( ::Fonts[ 2 ], "DEFAULT" ) ; AAdd( ::Fonts[ 4 ], {} )
      AAdd( ::Brushes[ 1 ], rr_getcurrentobject( 2 ) ) ; AAdd( ::Brushes[ 2 ], "*" )
      AAdd( ::Brushes[ 1 ], rr_getcurrentobject( 2 ) ) ; AAdd( ::Brushes[ 2 ], "DEFAULT" )
      AAdd( ::Pens[ 1 ], rr_getcurrentobject( 3 ) ) ; AAdd( ::Pens[ 2 ], "*" )
      AAdd( ::Pens[ 1 ], rr_getcurrentobject( 3 ) ) ; AAdd( ::Pens[ 2 ], "DEFAULT" )
      AAdd( ::Regions[ 1 ], 0 ) ; AAdd( ::Regions[ 2 ], "*" )
      AAdd( ::Regions[ 1 ], 0 ) ; AAdd( ::Regions[ 2 ], "DEFAULT" )
      ::Fonts[ 3 ] := ::Fonts[ 1, 1 ]
      rr_getdevicecaps( ::DEVCAPS, ::Fonts[ 3 ] )
      ::setunits( ::units )
   ENDIF

RETURN NIL

METHOD SetDevMode( what, newvalue ) CLASS HBPrinter
   ::hDCRef := rr_setdevmode( what, newvalue )
   rr_getdevicecaps( ::DEVCAPS, ::Fonts[ 3 ] )
   ::setunits( ::units )

RETURN Self

METHOD SetUserMode( what, value, value2 ) CLASS HBPrinter
   ::hDCRef := rr_setusermode( what, value, value2 )
   rr_getdevicecaps( ::DEVCAPS, ::Fonts[ 3 ] )
   ::setunits( ::units )

RETURN Self

METHOD StartDoc( ldocname ) CLASS HBPrinter
   ::Printing := .T.
   IF ldocname <> NIL
      ::DOCNAME := ldocname
   ENDIF
   IF !::PreviewMode
      rr_startdoc( ::DOCNAME )
   ENDIF

RETURN self

METHOD SetPage( orient, size, fontname ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( fontname, "F" )
   IF size <> NIL
      ::SetDevMode( DM_PAPERSIZE, size )
   ENDIF
   IF orient <> NIL
      ::SetDevMode( DM_ORIENTATION, orient )
   ENDIF
   IF lhand <> 0
      ::Fonts[ 3 ] := lhand
   ENDIF
   rr_getdevicecaps( ::DEVCAPS, ::Fonts[ 3 ] )
   ::setunits( ::units )

RETURN Self

METHOD Startpage() CLASS HBPrinter
   if ::PreviewMode
      ::hDC := rr_createmfile( ::BasePageName + StrZero( Len( ::metafiles ) + 1, 4 ) + '.emf' )
   ELSE
      rr_Startpage()
   ENDIF
   IF !::Printingemf
      rr_selectcliprgn( ::Regions[ 1, 1 ] )
      rr_setviewportorg( ::ViewPortOrg )
      rr_settextcolor( ::textcolor )
      rr_setbkcolor( ::bkcolor )
      rr_setbkmode( ::bkmode )
      rr_selectbrush( ::Brushes[ 1, 1 ] )
      rr_selectpen( ::Pens[ 1, 1 ] )
      rr_selectfont( ::Fonts[ 1, 1 ] )
   ENDIF

RETURN self

METHOD Endpage() CLASS HBPrinter
   if ::PreviewMode
      rr_closemfile()
      AAdd( ::MetaFiles, { ::BasePageName + StrZero( Len( ::metafiles ) + 1, 4 ) + '.emf', ::DEVCAPS[ 1 ], ::DEVCAPS[ 2 ], ::DEVCAPS[ 3 ], ::DEVCAPS[ 4 ], ::DEVCAPS[ 15 ], ::DEVCAPS[ 17 ] } )
   ELSE
      rr_endpage()
   ENDIF

RETURN self

METHOD SaveMetaFiles( number, filename ) CLASS HBPrinter
   if ::PreviewMode
	   DEFAULT filename := ::DOCNAME + "_"
      IF number == NIL
         AEval( ::metafiles, {| x, xi | __CopyFile( x[ 1 ], filename + StrZero( xi, 4 ) + ".emf" ) } )
      ELSE
         COPY FILE ( ::BasePageName + StrZero( number, 4 ) + '.emf' ) TO ( iif( At( ".emf", filename ) > 0, filename, Left( filename, Len( filename ) -1 ) + "_" + StrZero( number, 4 ) + ".emf" ) )
      ENDIF
   ENDIF

RETURN self

METHOD EndDoc() CLASS HBPrinter

   if ::PreviewMode
      ::preview()
   ELSE
      rr_enddoc()
   ENDIF
   ::Printing := .F.

RETURN self

METHOD SetTextColor( clr ) CLASS HBPrinter

   LOCAL lret := ::Textcolor
   IF clr <> NIL
      // BEGIN RL 2003-08-03
      IF ValType ( clr ) == 'N'
         ::TextColor := rr_settextcolor( clr )
      ELSEIF ValType ( clr ) == 'A'
         ::TextColor := rr_settextcolor( RGB ( clr[ 1 ], clr[ 2 ], clr[ 3 ] ) )
      ENDIF
      // END RL
   ENDIF

RETURN lret

METHOD SetPolyFillMode( style ) CLASS HBPrinter

   LOCAL lret := ::PolyFillMode
   ::PolyFillMode := rr_setpolyfillmode( style )

RETURN lret

METHOD SetBkColor( clr ) CLASS HBPrinter

   LOCAL lret := ::BkColor
   // BEGIN RL 2003-08-03
   IF ValType ( clr ) == 'N'
      ::BkColor := rr_setbkcolor( clr )
   ELSEIF ValType ( clr ) == 'A'
      ::BkColor := rr_setbkcolor( RGB ( clr[ 1 ], clr[ 2 ], clr[ 3 ] ) )
   ENDIF
   // END RL

RETURN lret

METHOD SetBkMode( nmode ) CLASS HBPrinter

   LOCAL lret := ::Bkmode
   ::BkMode := nmode
   rr_setbkmode( nmode )

RETURN lret

METHOD DefineBrush( defname, lstyle, lcolor, lhatch ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( defname, "B" )
   IF lhand <> 0
      RETURN self
   ENDIF
   // BEGIN RL 2003-08-03
   IF ISARRAY ( lcolor )
      lcolor := RGB ( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] )
   ENDIF
   // END RL
   hb_Default( @lstyle, BS_NULL )
   hb_Default( @lcolor, 0xFFFFFF )
   hb_Default( @lhatch, HS_HORIZONTAL )
   AAdd( ::Brushes[ 1 ], rr_createbrush( lstyle, lcolor, lhatch ) )
   AAdd( ::Brushes[ 2 ], Upper( AllTrim( defname ) ) )

RETURN self

METHOD SelectBrush( defname ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( defname, "B" )
   IF lhand <> 0
      rr_selectbrush( lhand )
      ::Brushes[ 1, 1 ] := lhand
   ENDIF

RETURN self

METHOD ModifyBrush( defname, lstyle, lcolor, lhatch ) CLASS HBPrinter

   LOCAL lhand := 0, lpos
   IF defname == "*"
      lpos := AScan( ::Brushes[ 1 ], ::Brushes[ 1, 1 ], 2 )
      IF lpos > 1
         lhand := ::Brushes[ 1, lpos ]
      ENDIF
   ELSE
      lhand := ::getobjbyname( defname, "B" )
      lpos := ::getobjbyname( defname, "B", .T. )
   ENDIF
   IF lhand == 0 .OR. lpos == 0
      ::error := 1
      RETURN self
   ENDIF
   // BEGIN RL 2003-08-03
   IF ISARRAY ( lcolor )
      lcolor := RGB ( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] )
   ENDIF
   // END RL
   hb_Default( @lstyle, -1 )
   hb_Default( @lcolor, -1 )
   hb_Default( @lhatch, -1 )
   ::Brushes[ 1, lpos ] := rr_modifybrush( lhand, lstyle, lcolor, lhatch )
   IF lhand == ::Brushes[ 1, 1 ]
      ::selectbrush( ::Brushes[ 2, lpos ] )
   ENDIF

RETURN self

METHOD DefinePen( defname, lstyle, lwidth, lcolor ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( defname, "P" )
   IF lhand <> 0
      RETURN self
   ENDIF
   // BEGIN RL 2003-08-03
   IF ISARRAY ( lcolor )
      lcolor := RGB ( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] )
   ENDIF
   // END RL
   hb_Default( @lstyle, PS_SOLID )
   hb_Default( @lcolor, 0xFFFFFF )
   hb_Default( @lwidth, 0 )
   AAdd( ::Pens[ 1 ], rr_createpen( lstyle, lwidth, lcolor ) )
   AAdd( ::Pens[ 2 ], Upper( AllTrim( defname ) ) )

RETURN self

METHOD ModifyPen( defname, lstyle, lwidth, lcolor ) CLASS HBPrinter

   LOCAL lhand := 0, lpos
   IF defname == "*"
      lpos := AScan( ::Pens[ 1 ], ::Pens[ 1, 1 ], 2 )
      IF lpos > 1
         lhand := ::Pens[ 1, lpos ]
      ENDIF
   ELSE
      lhand := ::getobjbyname( defname, "P" )
      lpos := ::getobjbyname( defname, "P", .T. )
   ENDIF
   IF lhand == 0 .OR. lpos <= 1
      ::error := 1
      RETURN self
   ENDIF
   // BEGIN RL 2003-08-03
   IF ISARRAY ( lcolor )
      lcolor := RGB ( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] )
   ENDIF
   // END RL
   hb_Default( @lstyle, -1 ) 
   hb_Default( @lcolor, -1 )
   hb_Default( @lwidth, -1 )
   ::Pens[ 1, lpos ] := rr_modifypen( lhand, lstyle, lwidth, lcolor )
   IF lhand == ::Pens[ 1, 1 ]
      ::selectpen( ::Pens[ 2, lpos ] )
   ENDIF

RETURN self

METHOD SelectPen( defname ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( defname, "P" )
   IF lhand <> 0
      rr_selectpen( lhand )
      ::Pens[ 1, 1 ] := lhand
   ENDIF

RETURN self

METHOD DefineFont( defname, lfontname, lfontsize, lfontwidth, langle, lweight, litalic, lunderline, lstrikeout ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( lfontname, "F" )
   IF lhand <> 0
      RETURN self
   ENDIF
   lfontname := if( lfontname == NIL, "", Upper( AllTrim( lfontname ) ) )
   hb_Default( @lfontsize, -1 )
   hb_Default( @lfontwidth, 0 )
   hb_Default( @langle, -1 )
   lweight := if( Empty( lweight ), 0, 1 )
   litalic := if( Empty( litalic ), 0, 1 )
   lunderline := if( Empty( lunderline ), 0, 1 )
   lstrikeout := if( Empty( lstrikeout ), 0, 1 )
   AAdd( ::Fonts[ 1 ], rr_createfont( lfontname, lfontsize, -lfontwidth, langle * 10, lweight, litalic, lunderline, lstrikeout ) )
   AAdd( ::Fonts[ 2 ], Upper( AllTrim( defname ) ) )
   AAdd( ::Fonts[ 4 ], { lfontname, lfontsize, lfontwidth, langle, lweight, litalic, lunderline, lstrikeout } )

RETURN self

METHOD ModifyFont( defname, lfontname, lfontsize, lfontwidth, langle, lweight, lnweight, litalic, lnitalic, lunderline, lnunderline, lstrikeout, lnstrikeout ) CLASS HBPrinter

   LOCAL lhand := 0, lpos
   IF defname == "*"
      lpos := AScan( ::Fonts[ 1 ], ::Fonts[ 1, 1 ], 2 )
      IF lpos > 1
         lhand := ::Fonts[ 1, lpos ]
      ENDIF
   ELSE
      lhand := ::getobjbyname( defname, "F" )
      lpos := ::getobjbyname( defname, "F", .T. )
   ENDIF
   IF lhand == 0 .OR. lpos <= 1
      ::error := 1
      RETURN self
   ENDIF

   iif(lfontname <> NIL , ::Fonts[4,lpos,1] := Upper(Alltrim(lfontname)), NIL)
   iif(lfontsize <> NIL , ::Fonts[4,lpos,2] := lfontsize, NIL)
   iif(lfontwidth <> NIL, ::Fonts[4,lpos,3] := lfontwidth, NIL)
   iif(langle <> NIL    , ::Fonts[4,lpos,4] := langle, NIL)
   iif(lweight , ::Fonts[4,lpos,5] := 1, NIL)
   iif(lnweight, ::Fonts[4,lpos,5] := 0, NIL)
   iif(litalic , ::Fonts[4,lpos,6] := 1, NIL)
   iif(lnitalic, ::Fonts[4,lpos,6] := 0, NIL)
   iif(lunderline , ::Fonts[4,lpos,7] := 1, NIL)
   iif(lnunderline, ::Fonts[4,lpos,7] := 0, NIL)
   iif(lstrikeout , ::Fonts[4,lpos,8] := 1, NIL)
   iif(lnstrikeout, ::Fonts[4,lpos,8] := 0, NIL)

   ::Fonts[ 1, lpos ] := rr_createfont( ::Fonts[ 4, lpos, 1 ], ::Fonts[ 4, lpos, 2 ], -::Fonts[ 4, lpos, 3 ], ::Fonts[ 4, lpos, 4 ] * 10, ::Fonts[ 4, lpos, 5 ], ::Fonts[ 4, lpos, 6 ], ::Fonts[ 4, lpos, 7 ], ::Fonts[ 4, lpos, 8 ] )

   IF lhand == ::Fonts[ 1, 1 ]
      ::selectfont( ::Fonts[ 2, lpos ] )
   ENDIF
   rr_deleteobjects( { 0, lhand } )

RETURN self

METHOD SelectFont( defname ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( defname, "F" )
   IF lhand <> 0
      rr_selectfont( lhand )
      ::Fonts[ 1, 1 ] := lhand
   ENDIF

RETURN self

METHOD SetUnits( newvalue, r, c ) CLASS HBPrinter

   LOCAL oldvalue := ::Units
   newvalue := if( ValType( newvalue ) == "N", newvalue, 0 )
   ::Units := if( newvalue < 0 .OR. newvalue > 4, 0, newvalue )
   SWITCH ::Units
   CASE 0   // ROWCOL
      ::MaxRow := ::DevCaps[ 13 ] -1
      ::MaxCol := ::DevCaps[ 14 ] -1
      EXIT
   CASE 1   // MM
      ::MaxRow := ::DevCaps[ 1 ] -1
      ::MaxCol := ::DevCaps[ 2 ] -1
      EXIT
   CASE 2   // INCHES
      ::MaxRow := ( ::DevCaps[ 1 ] / 25.4 ) -1
      ::MaxCol := ( ::DevCaps[ 2 ] / 25.4 ) -1
      EXIT
   CASE 3   // PIXEL
      ::MaxRow := ::DevCaps[ 3 ]
      ::MaxCol := ::DevCaps[ 4 ]
      EXIT
   CASE 4   // ROWS   COLS
      iif( ValType( r ) == "N", ::MaxRow := r - 1, NIL )
      iif( ValType( c ) == "N", ::MaxCol := c - 1, NIL )
   ENDSWITCH

RETURN oldvalue

METHOD Convert( arr, lsize ) CLASS HBPrinter

   LOCAL aret := AClone( arr )
   SWITCH ::Units
   CASE 0        // ROWCOL
      aret[ 1 ] := ( arr[ 1 ] ) * ::DEVCAPS[ 11 ]
      aret[ 2 ] := ( arr[ 2 ] ) * ::DEVCAPS[ 12 ]
      EXIT
   CASE 3        // PIXEL
      EXIT
   CASE 4        // ROWS   COLS
      aret[ 1 ] := ( arr[ 1 ] ) * ::DEVCAPS[ 3 ] / ( ::maxrow + 1 )
      aret[ 2 ] := ( arr[ 2 ] ) * ::DEVCAPS[ 4 ] / ( ::maxcol + 1 )
      EXIT
   CASE 1        // MM
      aret[ 1 ] := ( arr[ 1 ] ) * ::DEVCAPS[ 5 ] / 25.4 -if( lsize == NIL, ::DEVCAPS[ 9 ], 0 )
      aret[ 2 ] := ( arr[ 2 ] ) * ::DEVCAPS[ 6 ] / 25.4 -if( lsize == NIL, ::DEVCAPS[ 10 ], 0 )
      EXIT
   CASE 2        // INCHES
      aret[ 1 ] := ( arr[ 1 ] ) * ::DEVCAPS[ 5 ] -if( lsize == NIL, ::DEVCAPS[ 9 ], 0 )
      aret[ 2 ] := ( arr[ 2 ] ) * ::DEVCAPS[ 6 ] -if( lsize == NIL, ::DEVCAPS[ 10 ], 0 )
      EXIT
#ifndef __XHARBOUR__
   OTHERWISE
#else
   DEFAULT
#endif
      aret[ 1 ] := ( arr[ 1 ] ) * ::DEVCAPS[ 11 ]
      aret[ 2 ] := ( arr[ 2 ] ) * ::DEVCAPS[ 12 ]
   ENDSWITCH

RETURN aret

METHOD DrawText( row, col, torow, tocol, txt, style, defname ) CLASS HBPrinter

   LOCAL lhf := ::getobjbyname( defname, "F" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   rr_drawtext( ::Convert( { row, col } ), ::Convert( { torow, tocol } ), txt, style, lhf )

RETURN self

METHOD TEXTOUT( row, col, txt, defname ) CLASS HBPrinter

   LOCAL lhf := ::getobjbyname( defname, "F" )
   rr_textout( txt, ::Convert( { row, col } ), lhf, numat( " ", txt ) )

RETURN self

METHOD Say( row, col, txt, defname, lcolor, lalign ) CLASS HBPrinter

   LOCAL atxt := {}, i, lhf := ::getobjbyname( defname, "F" ), oldalign
   LOCAL apos
   DO CASE
   CASE ValType( txt ) == "N"    ;  AAdd( atxt, Str( txt ) )
   CASE ValType( txt ) == "D"    ;  AAdd( atxt, DToC( txt ) )
   CASE ValType( txt ) == "L"    ;  AAdd( atxt, if( txt, ".T.", ".F." ) )
   CASE ValType( txt ) == "U"    ;  AAdd( atxt, "NIL" )
   CASE ValType( txt ) $ "BO"    ;  AAdd( atxt, "" )
   CASE ValType( txt ) == "A"    ;  AEval( txt, {| x | AAdd( atxt, sayconvert( x ) ) } )
   CASE ValType( txt ) $ "MC"    ;  atxt := str2arr( txt, hb_osNewLine() )
   ENDCASE
   apos := ::convert( { row, col } )
   IF lcolor <> NIL
      // BEGIN RL 2003-08-03
      IF ValType ( lcolor ) == 'N'
         rr_settextcolor( lcolor )
      ELSEIF ValType ( lcolor ) == 'A'
         rr_settextcolor( RGB ( lcolor[ 1 ], lcolor[ 2 ], lcolor[ 3 ] ) )
      ENDIF
      // END RL
   ENDIF
   IF lalign <> NIL
      oldalign := rr_gettextalign()
      rr_settextalign( lalign )
   ENDIF
   FOR i := 1 TO Len( atxt )
      rr_textout( atxt[ i ], apos, lhf, numat( " ", atxt[ i ] ) )
      apos[ 1 ] += ::DEVCAPS[ 11 ]
   NEXT
   IF lalign <> NIL
      rr_settextalign( oldalign )
   ENDIF
   IF lcolor <> NIL
      rr_settextcolor( ::textcolor )
   ENDIF

RETURN self

METHOD DefineImageList( defname, cpicture, nicons ) CLASS HBPrinter

   LOCAL lhi := ::getobjbyname( defname, "I" ), w := 0, h := 0, hand
   IF lhi <> 0
      RETURN self
   ENDIF
   hand := rr_createimagelist( cpicture, nicons, @w, @h )
   IF hand <> 0 .AND. w > 0 .AND. h > 0
      AAdd( ::imagelists[ 1 ], { hand, nicons, w, h } )
      AAdd( ::imagelists[ 2 ], Upper( AllTrim( defname ) ) )
   ENDIF

RETURN self

METHOD DrawImageList( defname, nicon, row, col, torow, tocol, lstyle, color ) CLASS HBPrinter

   LOCAL lhi := ::getobjbyname( defname, "I" )
   IF Empty( lhi )
      RETURN self
   ENDIF
   hb_Default( @COLOR, -1 )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error := rr_drawimagelist( lhi[ 1 ], nicon, ::convert( { row, col } ), ::convert( { torow - row, tocol - col } ), lhi[ 3 ], lhi[ 4 ], lstyle, color )

RETURN self

METHOD Rectangle( row, col, torow, tocol, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::getobjbyname( defpen, "P" ), lhb := ::getobjbyname( defbrush, "B" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_rectangle( ::convert( { row, col } ), ::convert( { torow, tocol } ), lhp, lhb )

RETURN self

METHOD FrameRect( row, col, torow, tocol, defbrush ) CLASS HBPrinter

   LOCAL lhb := ::getobjbyname( defbrush, "B" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_framerect( ::convert( { row, col } ), ::convert( { torow, tocol } ), lhb )

RETURN self

METHOD RoundRect( row, col, torow, tocol, widthellipse, heightellipse, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::getobjbyname( defpen, "P" ), lhb := ::getobjbyname( defbrush, "B" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_roundrect( ::convert( { row, col } ), ::convert( { torow, tocol } ), ::convert( { widthellipse, heightellipse } ), lhp, lhb )

RETURN self

METHOD FillRect( row, col, torow, tocol, defbrush ) CLASS HBPrinter

   LOCAL lhb := ::getobjbyname( defbrush, "B" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_fillrect( ::convert( { row, col } ), ::convert( { torow, tocol } ), lhb )

RETURN self

METHOD InvertRect( row, col, torow, tocol ) CLASS HBPrinter
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_invertrect( ::convert( { row, col } ), ::convert( { torow, tocol } ) )

RETURN self

METHOD Ellipse( row, col, torow, tocol, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::getobjbyname( defpen, "P" ), lhb := ::getobjbyname( defbrush, "B" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_ellipse( ::convert( { row, col } ), ::convert( { torow, tocol } ), lhp, lhb )

RETURN self

METHOD Arc( row, col, torow, tocol, rowsarc, colsarc, rowearc, colearc, defpen ) CLASS HBPrinter

   LOCAL lhp := ::getobjbyname( defpen, "P" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_arc( ::convert( { row, col } ), ::convert( { torow, tocol } ), ::convert( { rowsarc, colsarc } ), ::convert( { rowearc, colearc } ), lhp )

RETURN self

METHOD ArcTo( row, col, torow, tocol, rowrad1, colrad1, rowrad2, colrad2, defpen ) CLASS HBPrinter

   LOCAL lhp := ::getobjbyname( defpen, "P" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_arcto( ::convert( { row, col } ), ::convert( { torow, tocol } ), ::convert( { rowrad1, colrad1 } ), ::convert( { rowrad2, colrad2 } ), lhp )

RETURN self


METHOD Chord( row, col, torow, tocol, rowrad1, colrad1, rowrad2, colrad2, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::getobjbyname( defpen, "P" ), lhb := ::getobjbyname( defbrush, "B" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_chord( ::convert( { row, col } ), ::convert( { torow, tocol } ), ::convert( { rowrad1, colrad1 } ), ::convert( { rowrad2, colrad2 } ), lhp, lhb )

RETURN self

METHOD Pie( row, col, torow, tocol, rowrad1, colrad1, rowrad2, colrad2, defpen, defbrush ) CLASS HBPrinter

   LOCAL lhp := ::getobjbyname( defpen, "P" ), lhb := ::getobjbyname( defbrush, "B" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_pie( ::convert( { row, col } ), ::convert( { torow, tocol } ), ::convert( { rowrad1, colrad1 } ), ::convert( { rowrad2, colrad2 } ), lhp, lhb )

RETURN self

METHOD Polygon( apoints, defpen, defbrush, style ) CLASS HBPrinter

   LOCAL apx := {}, apy := {}, temp
   LOCAL lhp := ::getobjbyname( defpen, "P" ), lhb := ::getobjbyname( defbrush, "B" )
   AEval( apoints, {| x | temp := ::convert( x ), AAdd( apx, temp[ 2 ] ), AAdd( apy, temp[ 1 ] ) } )
   ::error := rr_polygon( apx, apy, lhp, lhb, style )

RETURN self

METHOD PolyBezier( apoints, defpen ) CLASS HBPrinter

   LOCAL apx := {}, apy := {}, temp
   LOCAL lhp := ::getobjbyname( defpen, "P" )
   AEval( apoints, {| x | temp := ::convert( x ), AAdd( apx, temp[ 2 ] ), AAdd( apy, temp[ 1 ] ) } )
   ::error := rr_polybezier( apx, apy, lhp )

RETURN self

METHOD PolyBezierTo( apoints, defpen ) CLASS HBPrinter

   LOCAL apx := {}, apy := {}, temp
   LOCAL lhp := ::getobjbyname( defpen, "P" )
   AEval( apoints, {| x | temp := ::convert( x ), AAdd( apx, temp[ 2 ] ), AAdd( apy, temp[ 1 ] ) } )
   ::error := rr_polybezierto( apx, apy, lhp )

RETURN self

METHOD Line( row, col, torow, tocol, defpen ) CLASS HBPrinter

   LOCAL lhp := ::getobjbyname( defpen, "P" )
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   ::error = rr_line( ::convert( { row, col } ), ::convert( { torow, tocol } ), lhp )

RETURN self

METHOD LineTo( row, col, defpen ) CLASS HBPrinter

   LOCAL lhp := ::getobjbyname( defpen, "P" )
   ::error = rr_lineto( ::convert( { row, col } ), lhp )

RETURN self

METHOD GetTextExtent( ctext, apoint, deffont ) CLASS HBPrinter

   LOCAL lhf := ::getobjbyname( deffont, "F" )
   ::error = rr_gettextextent( ctext, apoint, lhf )

RETURN self

METHOD GetTextExtent_mm( ctext, apoint, deffont ) CLASS HBPrinter

   LOCAL lhf := ::getobjbyname( deffont, "F" )
   ::error = rr_gettextextent( ctext, apoint, lhf )
   apoint[ 1 ] := 25.4 * apoint[ 1 ] / ::DevCaps[ 5 ]
   apoint[ 2 ] := 25.4 * apoint[ 2 ] / ::DevCaps[ 6 ]

RETURN self

METHOD GetObjByName( defname, what, retpos ) CLASS HBPrinter

   LOCAL lfound, lret := 0, aref, ahref
   IF ValType( defname ) == "C"
      DO CASE
      CASE what == "F" ; aref := ::Fonts[ 2 ]      ; ahref := ::Fonts[ 1 ]
      CASE what == "B" ; aref := ::Brushes[ 2 ]    ; ahref := ::Brushes[ 1 ]
      CASE what == "P" ; aref := ::Pens[ 2 ]       ; ahref := ::Pens[ 1 ]
      CASE what == "R" ; aref := ::Regions[ 2 ]    ; ahref := ::Regions[ 1 ]
      CASE what == "I" ; aref := ::ImageLists[ 2 ] ; ahref := ::ImageLists[ 1 ]
      ENDCASE
      lfound := AScan( aref, Upper( AllTrim( defname ) ) )
      IF lfound > 0
         IF aref[ lfound ] == Upper( AllTrim( defname ) )
            IF retpos <> NIL
               lret := lfound
            ELSE
               lret := ahref[ lfound ]
            ENDIF
         ENDIF
      ENDIF
   ENDIF

RETURN lret

METHOD DefineRectRgn( defname, row, col, torow, tocol ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( defname, "R" )
   IF lhand <> 0
      RETURN self
   ENDIF
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   AAdd( ::Regions[ 1 ], rr_creatergn( ::convert( { row, col } ), ::convert( { torow, tocol } ), 1 ) )
   AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )

RETURN self

METHOD DefineEllipticRgn( defname, row, col, torow, tocol ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( defname, "R" )
   IF lhand <> 0
      RETURN self
   ENDIF
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   AAdd( ::Regions[ 1 ], rr_creatergn( ::convert( { row, col } ), ::convert( { torow, tocol } ), 2 ) )
   AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )

RETURN self

METHOD DefineRoundRectRgn( defname, row, col, torow, tocol, widthellipse, heightellipse ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( defname, "R" )
   IF lhand <> 0
      RETURN self
   ENDIF
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   AAdd( ::Regions[ 1 ], rr_creatergn( ::convert( { row, col } ), ::convert( { torow, tocol } ), 3, ::convert( { widthellipse, heightellipse } ) ) )
   AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )

RETURN self

METHOD DefinePolygonRgn( defname, apoints, style ) CLASS HBPrinter

   LOCAL apx := {}, apy := {}, temp
   LOCAL lhand := ::getobjbyname( defname, "R" )
   IF lhand <> 0
      RETURN self
   ENDIF
   AEval( apoints, {| x | temp := ::convert( x ), AAdd( apx, temp[ 2 ] ), AAdd( apy, temp[ 1 ] ) } )
   AAdd( ::Regions[ 1 ], rr_createPolygonrgn( apx, apy, style ) )
   AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )

RETURN self

METHOD CombineRgn( defname, reg1, reg2, style ) CLASS HBPrinter

   LOCAL lr1 := ::getobjbyname( reg1, "R" ), lr2 := ::getobjbyname( reg2, "R" )
   LOCAL lhand := ::getobjbyname( defname, "R" )
   IF lhand <> 0 .OR. lr1 == 0 .OR. lr2 == 0
      RETURN self
   ENDIF
   AAdd( ::Regions[ 1 ], rr_combinergn( lr1, lr2, style ) )
   AAdd( ::Regions[ 2 ], Upper( AllTrim( defname ) ) )

RETURN self

METHOD SelectClipRgn( defname ) CLASS HBPrinter

   LOCAL lhand := ::getobjbyname( defname, "R" )
   IF lhand <> 0
      rr_selectcliprgn( lhand )
      ::Regions[ 1, 1 ] := lhand
   ENDIF

RETURN self

METHOD DeleteClipRgn() CLASS HBPrinter
   ::Regions[ 1, 1 ] := 0
   rr_deletecliprgn()

RETURN self

METHOD SetViewPortOrg( row, col ) CLASS HBPrinter
   row := if( row <> NIL, row, 0 )
   col := if( col <> NIL, col, 0 )
   ::ViewPortOrg := ::convert( { row, col } )
   rr_setviewportorg( ::ViewPortOrg )

RETURN self

METHOD GetViewPortOrg() CLASS HBPrinter
   rr_getviewportorg( ::ViewPortOrg )

RETURN self

METHOD End() CLASS HBPrinter
   if ::PreviewMode
      AEval( ::metafiles, {| x | FErase( x[ 1 ] ) } )
      ::MetaFiles := {}
   ENDIF
   if ::HDCRef != 0
      ef_resetprinter()
      rr_deletedc( ::HDCRef )
   ENDIF
   rr_deleteobjects( ::Fonts[ 1 ] )
   rr_deleteobjects( ::Brushes[ 1 ] )
   rr_deleteobjects( ::Pens[ 1 ] )
   rr_deleteobjects( ::Regions[ 1 ] )
   rr_deleteimagelists( ::ImageLists[ 1 ] )
   rr_finish()

RETURN NIL

METHOD DXCOLORS( par ) CLASS HBPrinter

   STATIC rgbColorNames := ;
      { { "aliceblue",           0xfffff8f0 }, ;
      { "antiquewhite",          0xffd7ebfa }, ;
      { "aqua",                  0xffffff00 }, ;
      { "aquamarine",            0xffd4ff7f }, ;
      { "azure",                 0xfffffff0 }, ;
      { "beige",                 0xffdcf5f5 }, ;
      { "bisque",                0xffc4e4ff }, ;
      { "black",                 0xff000000 }, ;
      { "blanchedalmond",        0xffcdebff }, ;
      { "blue",                  0xffff0000 }, ;
      { "blueviolet",            0xffe22b8a }, ;
      { "brown",                 0xff2a2aa5 }, ;
      { "burlywood",             0xff87b8de }, ;
      { "cadetblue",             0xffa09e5f }, ;
      { "chartreuse",            0xff00ff7f }, ;
      { "chocolate",             0xff1e69d2 }, ;
      { "coral",                 0xff507fff }, ;
      { "cornflowerblue",        0xffed9564 }, ;
      { "cornsilk",              0xffdcf8ff }, ;
      { "crimson",               0xff3c14dc }, ;
      { "cyan",                  0xffffff00 }, ;
      { "darkblue",              0xff8b0000 }, ;
      { "darkcyan",              0xff8b8b00 }, ;
      { "darkgoldenrod",         0xff0b86b8 }, ;
      { "darkgray",              0xffa9a9a9 }, ;
      { "darkgreen",             0xff006400 }, ;
      { "darkkhaki",             0xff6bb7bd }, ;
      { "darkmagenta",           0xff8b008b }, ;
      { "darkolivegreen",        0xff2f6b55 }, ;
      { "darkorange",            0xff008cff }, ;
      { "darkorchid",            0xffcc3299 }, ;
      { "darkred",               0xff00008b }, ;
      { "darksalmon",            0xff7a96e9 }, ;
      { "darkseagreen",          0xff8fbc8f }, ;
      { "darkslateblue",         0xff8b3d48 }, ;
      { "darkslategray",         0xff4f4f2f }, ;
      { "darkturquoise",         0xffd1ce00 }, ;
      { "darkviolet",            0xffd30094 }, ;
      { "deeppink",              0xff9314ff }, ;
      { "deepskyblue",           0xffffbf00 }, ;
      { "dimgray",               0xff696969 }, ;
      { "dodgerblue",            0xffff901e }, ;
      { "firebrick",             0xff2222b2 }, ;
      { "floralwhite",           0xfff0faff }, ;
      { "forestgreen",           0xff228b22 }, ;
      { "fuchsia",               0xffff00ff }, ;
      { "gainsboro",             0xffdcdcdc }, ;
      { "ghostwhite",            0xfffff8f8 }, ;
      { "gold",                  0xff00d7ff }, ;
      { "goldenrod",             0xff20a5da }, ;
      { "gray",                  0xff808080 }, ;
      { "green",                 0xff008000 }, ;
      { "greenyellow",           0xff2fffad }, ;
      { "honeydew",              0xfff0fff0 }, ;
      { "hotpink",               0xffb469ff }, ;
      { "indianred",             0xff5c5ccd }, ;
      { "indigo",                0xff82004b }, ;
      { "ivory",                 0xfff0ffff }, ;
      { "khaki",                 0xff8ce6f0 }, ;
      { "lavender",              0xfffae6e6 }, ;
      { "lavenderblush",         0xfff5f0ff }, ;
      { "lawngreen",             0xff00fc7c }, ;
      { "lemonchiffon",          0xffcdfaff }, ;
      { "lightblue",             0xffe6d8ad }, ;
      { "lightcoral",            0xff8080f0 }, ;
      { "lightcyan",             0xffffffe0 }, ;
      { "lightgoldenrodyellow",  0xffd2fafa }, ;
      { "lightgreen",            0xff90ee90 }, ;
      { "lightgrey",             0xffd3d3d3 }, ;
      { "lightpink",             0xffc1b6ff }, ;
      { "lightsalmon",           0xff7aa0ff }, ;
      { "lightseagreen",         0xffaab220 }, ;
      { "lightskyblue",          0xffface87 }, ;
      { "lightslategray",        0xff998877 }, ;
      { "lightsteelblue",        0xffdec4b0 }, ;
      { "lightyellow",           0xffe0ffff }, ;
      { "lime",                  0xff00ff00 }, ;
      { "limegreen",             0xff32cd32 }, ;
      { "linen",                 0xffe6f0fa }, ;
      { "magenta",               0xffff00ff }, ;
      { "maroon",                0xff000080 }, ;
      { "mediumaquamarine",      0xffaacd66 }, ;
      { "mediumblue",            0xffcd0000 }, ;
      { "mediumorchid",          0xffd355ba }, ;
      { "mediumpurple",          0xffdb7093 }, ;
      { "mediumseagreen",        0xff71b33c }, ;
      { "mediumslateblue",       0xffee687b }, ;
      { "mediumspringgreen",     0xff9afa00 }, ;
      { "mediumturquoise",       0xffccd148 }, ;
      { "mediumvioletred",       0xff8515c7 }, ;
      { "midnightblue",          0xff701919 }, ;
      { "mintcream",             0xfffafff5 }, ;
      { "mistyrose",             0xffe1e4ff }, ;
      { "moccasin",              0xffb5e4ff }, ;
      { "navajowhite",           0xffaddeff }, ;
      { "navy",                  0xff800000 }, ;
      { "oldlace",               0xffe6f5fd }, ;
      { "olive",                 0xff008080 }, ;
      { "olivedrab",             0xff238e6b }, ;
      { "orange",                0xff00a5ff }, ;
      { "orangered",             0xff0045ff }, ;
      { "orchid",                0xffd670da }, ;
      { "palegoldenrod",         0xffaae8ee }, ;
      { "palegreen",             0xff98fb98 }, ;
      { "paleturquoise",         0xffeeeeaf }, ;
      { "palevioletred",         0xff9370db }, ;
      { "papayawhip",            0xffd5efff }, ;
      { "peachpuff",             0xffb9daff }, ;
      { "peru",                  0xff3f85cd }, ;
      { "pink",                  0xffcbc0ff }, ;
      { "plum",                  0xffdda0dd }, ;
      { "powderblue",            0xffe6e0b0 }, ;
      { "purple",                0xff800080 }, ;
      { "red",                   0xff0000ff }, ;
      { "rosybrown",             0xff8f8fbc }, ;
      { "royalblue",             0xffe16941 }, ;
      { "saddlebrown",           0xff13458b }, ;
      { "salmon",                0xff7280fa }, ;
      { "sandybrown",            0xff60a4f4 }, ;
      { "seagreen",              0xff578b2e }, ;
      { "seashell",              0xffeef5ff }, ;
      { "sienna",                0xff2d52a0 }, ;
      { "silver",                0xffc0c0c0 }, ;
      { "skyblue",               0xffebce87 }, ;
      { "slateblue",             0xffcd5a6a }, ;
      { "slategray",             0xff908070 }, ;
      { "snow",                  0xfffafaff }, ;
      { "springgreen",           0xff7fff00 }, ;
      { "steelblue",             0xffb48246 }, ;
      { "tan",                   0xff8cb4d2 }, ;
      { "teal",                  0xff808000 }, ;
      { "thistle",               0xffd8bfd8 }, ;
      { "tomato",                0xff4763ff }, ;
      { "turquoise",             0xffd0e040 }, ;
      { "violet",                0xffee82ee }, ;
      { "wheat",                 0xffb3def5 }, ;
      { "white",                 0xffffffff }, ;
      { "whitesmoke",            0xfff5f5f5 }, ;
      { "yellow",                0xff00ffff }, ;
      { "yellowgreen",           0xff32cd9a } }
   LOCAL ltemp := 0

   IF ValType( par ) == "C"
      par := Lower( AllTrim( par ) )
      AEval( rgbcolornames, {| x | if( x[ 1 ] == par, ltemp := x[ 2 ], '' ) } )
   ELSEIF ValType( par ) == "N"
      ltemp := if( par <= Len( rgbcolornames ), rgbcolornames[ par, 2 ], 0 )
   ENDIF

RETURN ltemp

METHOD SetRGB( red, green, blue ) CLASS HBPrinter
RETURN rr_setrgb( red, green, blue )

METHOD SetTextCharExtra( col ) CLASS HBPrinter

   LOCAL p1 := ::convert( { 0, 0 } ), p2 := ::convert( { 0, col } )

RETURN rr_SetTextCharExtra( p2[ 2 ] -p1[ 2 ] )

METHOD GetTextCharExtra() CLASS HBPrinter
RETURN rr_GetTextCharExtra()

METHOD SetTextJustification( col ) CLASS HBPrinter

   LOCAL p1 := ::convert( { 0, 0 } ), p2 := ::convert( { 0, col } )

RETURN rr_SetTextJustification( p2[ 2 ] -p1[ 2 ] )

METHOD GetTextJustification() CLASS HBPrinter
RETURN rr_GetTextJustification()

METHOD SetTextAlign( style ) CLASS HBPrinter
RETURN rr_settextalign( style )

METHOD GetTextAlign() CLASS HBPrinter
RETURN rr_gettextalign()

METHOD Picture( row, col, torow, tocol, cpicture, extrow, extcol ) CLASS HBPrinter

   LOCAL lp1 := ::convert( { row, col } ), lp2, lp3
   hb_Default( @torow, ::maxrow )
   hb_Default( @tocol, ::maxcol )
   lp2 := ::convert( { torow, tocol }, 1 )
   hb_Default( @extrow, 0 )
   hb_Default( @extcol, 0 )
   lp3 := ::convert( { extrow, extcol } )
   rr_drawpicture( cpicture, lp1, lp2, lp3 )

RETURN self

STATIC FUNCTION sayconvert( ltxt )

   DO CASE
   CASE ValType( ltxt ) $ "MC"    ;  RETURN ltxt
   CASE ValType( ltxt ) == "N"    ;  RETURN Str( ltxt )
   CASE ValType( ltxt ) == "D"    ;  RETURN DToC( ltxt )
   CASE ValType( ltxt ) == "L"    ;  RETURN IF( ltxt, ".T.", ".F." )
   ENDCASE

RETURN ""

STATIC FUNCTION str2arr( cList, cDelimiter )

   LOCAL nPos
   LOCAL aList := {}
   LOCAL nlencd := 0
   LOCAL asub
   DO CASE
   CASE ValType( cDelimiter ) == 'C'
      cDelimiter := if( cDelimiter == NIL, ",", cDelimiter )
      nlencd := Len( cdelimiter )
      DO WHILE ( nPos := At( cDelimiter, cList ) ) != 0
         AAdd( aList, SubStr( cList, 1, nPos - 1 ) )
         cList := SubStr( cList, nPos + nlencd )
      ENDDO
      AAdd( aList, cList )
   CASE ValType( cDelimiter ) == 'N'
      DO WHILE Len( ( nPos := Left( cList, cDelimiter ) ) ) == cDelimiter
         AAdd( aList, nPos )
         cList := SubStr( cList, cDelimiter + 1 )
      ENDDO
   CASE ValType( cDelimiter ) == 'A'
      AEval( cDelimiter, {| x | nlencd += x } )
      DO WHILE Len( ( nPos := Left( cList, nlencd ) ) ) == nlencd
         asub := {}
         AEval( cDelimiter, {| x | AAdd( asub, Left( nPos, x ) ), nPos := SubStr( nPos, x + 1 ) } )
         AAdd( aList, asub )
         cList := SubStr( cList, nlencd + 1 )
      ENDDO
   ENDCASE

RETURN ( aList )

#ifdef HB_DYNLIB
STATIC FUNCTION NumAt( cSearch, cString )

   LOCAL n := 0, nAt, nPos := 0
   DO WHILE ( nAt := At( cSearch, SubStr( cString, nPos + 1 ) ) ) > 0
      nPos += nAt
      ++n
   ENDDO

RETURN n
#endif

METHOD PrevThumb( nclick ) CLASS HBPrinter

   LOCAL i, spage
   IF iloscstron == 1
      RETURN self
   ENDIF
   IF nclick <> NIL
      page := ngroup * 15 + nclick
      ::prevshow()
      SetProperty ( 'hbpreview', 'combo_1', 'value', Page )
      RETURN self
   ENDIF
   IF Int( ( page - 1 ) / 15 ) <> ngroup
      ngroup := Int( ( page - 1 ) / 15 )
   ELSE
      RETURN self
   ENDIF
   spage := ngroup * 15

   FOR i := 1 TO 15
      IF i + spage > iloscstron
         HideWindow( ath[ i, 5 ] )
      ELSE
         if ::Metafiles[ i + spage, 2 ] >= ::Metafiles[ i + spage, 3 ]
            ath[ i, 3 ] := dy - 5
            ath[ i, 4 ] := dx * ::Metafiles[ i + spage, 3 ] / ::Metafiles[ i + spage, 2 ] -5
         ELSE
            ath[ i, 4 ] := dx - 5
            ath[ i, 3 ] := dy * ::Metafiles[ i + spage, 2 ] / ::Metafiles[ i + spage, 3 ] -5
         ENDIF
         rr_playthumb( ath[ i ], ::Metafiles[ i + spage, 1 ], AllTrim( Str( i + spage ) ), i )
         CShowControl( ath[ i, 5 ] )
      ENDIF
   NEXT

RETURN self

METHOD PrevShow() CLASS HBPrinter

   LOCAL spos := { 0, 0 }

   if ::Thumbnails
      ::Prevthumb()
   ENDIF
   IF !Empty( azoom[ 3 ] ) .AND. !Empty( azoom[ 4 ] )
      spos[ 1 ] := GetScrollpos( ahs[ 5, 7 ], SB_HORZ ) / azoom[ 4 ]
      spos[ 2 ] := GetScrollpos( ahs[ 5, 7 ], SB_VERT ) / ( azoom[ 3 ] )
   ENDIF
   if ::MetaFiles[ page, 2 ] >= ::MetaFiles[ page, 3 ]
      azoom[ 3 ] := ( ahs[ 5, 3 ] ) * scale - 60
      azoom[ 4 ] := ( ahs[ 5, 3 ] * ::MetaFiles[ page, 3 ] / ::MetaFiles[ page, 2 ] ) * scale - 60
   ELSE
      azoom[ 3 ] := ( ahs[ 5, 4 ] * ::MetaFiles[ page, 2 ] / ::MetaFiles[ page, 3 ] ) * scale - 60
      azoom[ 4 ] := ( ahs[ 5, 4 ] ) * scale - 60
   ENDIF
   _SetItem ( "StatusBar", "hbpreview", 1, aopisy[ 15 ] + " " + AllTrim( Str( page ) ) )

   IF azoom[ 3 ] < 30
      scale := scale * 1.25
      ::prevshow()
      MsgExclamation( aopisy[ 18 ] + " -", aopisy[ 1 ], , .F., .F. )
   ENDIF
   HideWindow( ahs[ 6, 7 ] )
   _SetControlHeight( "i1", "hbpreview1", azoom[ 3 ] + 20 )
   _SetControlWidth ( "i1", "hbpreview1", azoom[ 4 ] )
   SetScrollRange( ahs[ 5, 7 ], SB_VERT, 0, azoom[ 3 ] + 20, .T. )
   SetScrollRange( ahs[ 5, 7 ], SB_HORZ, 0, azoom[ 4 ], .T. )

   IF !rr_previewplay( ahs[ 6, 7 ], ::METAFILES[ page, 1 ], azoom )
      scale := scale / 1.25
      ::PrevShow()
      MsgExclamation( aopisy[ 18 ] + " +", aopisy[ 1 ], , .F., .F. )
   ENDIF
   rr_scrollwindow( ahs[ 5, 7 ], -spos[ 1 ] * azoom[ 4 ], -spos[ 2 ] * azoom[ 3 ] )
   CShowControl( ahs[ 6, 7 ] )

RETURN self

METHOD PrevPrint( n1 ) CLASS HBPrinter

   LOCAL i, ilkop, toprint := .T.
   ::Previewmode := .F.
   ::Printingemf := .T.
   rr_lalabye( 1 )
   IF n1 <> NIL
      ::startdoc()
      ::setpage( ::MetaFiles[ n1, 6 ], ::MetaFiles[ n1, 7 ] )
      ::startpage()
      rr_PlayEnhMetaFile( ::MetaFiles[ n1 ], ::hDCRef )
      ::endpage()
      ::enddoc()
   ELSE
      FOR ilkop = 1 to ::nCopies
         ::startdoc()
         FOR i := Max( 1, ::nFromPage ) TO Min( iloscstron, ::nToPage )
            DO CASE
            CASE ::PrintOpt == 1                      ; toprint := .T.
            CASE ::PrintOpt == 2 .OR. ::PrintOpt == 4 ; toprint := !( i % 2 == 0 )
            CASE ::PrintOpt == 3 .OR. ::PrintOpt == 5 ; toprint := ( i % 2 == 0 )
            ENDCASE
            IF toprint
               toprint := .F.
               ::setpage( ::MetaFiles[ i, 6 ], ::MetaFiles[ i, 7 ] )
               ::startpage()
               rr_PlayEnhMetaFile( ::MetaFiles[ i ], ::hDCRef )
               ::endpage()
            ENDIF
         NEXT i
         ::enddoc()

         if ::PrintOpt == 4 .OR. ::PrintOpt == 5
            MsgBox( aopisy[ 30 ], aopisy[ 29 ], .F., .F. )
            ::startdoc()
            FOR i := Max( 1, ::nFromPage ) TO Min( iloscstron, ::nToPage )
               DO CASE
               CASE ::PrintOpt == 4 ; toprint := ( i % 2 == 0 )
               CASE ::PrintOpt == 5 ; toprint := !( i % 2 == 0 )
               ENDCASE
               IF toprint
                  toprint := .F.
                  ::setpage( ::MetaFiles[ i, 6 ], ::MetaFiles[ i, 7 ] )
                  ::startpage()
                  rr_PlayEnhMetaFile( ::MetaFiles[ i ], ::hDCRef )
                  ::endpage()
               ENDIF
            NEXT i
            ::enddoc()
         ENDIF
      NEXT ilkop
   ENDIF
   rr_lalabye( 0 )
   ::printingemf := .F.
   ::Previewmode := .T.

RETURN self

STATIC FUNCTION LangInit
   
#ifdef _MULTILINGUAL_
   LOCAL cLang
#endif
   LOCAL aLang := {  'Preview', ;    // 01
							'&Cancel', ;    // 02
							'&Print', ;     // 03
							'&Save', ;      // 04
							'&First', ;     // 05
							'P&revious', ;  // 06
							'&Next', ;      // 07
							'&Last', ;      // 08
							'Zoom &In', ;   // 09
							'&Zoom Out', ;  // 10
							'&Options', ;   // 11
							'Go To Page:', ;   // 12
							'Page preview ', ; // 13
							'Thumbnails preview', ; // 14
							'Page', ;               // 15
							'Print only current page', ;  // 16
							'Pages:', ;        // 17
							'No more zoom', ;  // 18
							'Print options', ; // 19
							'Print from', ; 	 // 20
							'to', ;    			 // 21
							'Copies', ;			 // 22
							'Print Range', ;   // 23 
							'All from range', ; // 24
							'Odd only', ;   	  // 25
							'Even only', ;   	  // 26
							'All but odd first', ;  // 27
							'All but even first', ; // 28
							'Printing ....', ;		// 29
							'Waiting for paper change...', ; // 30
							'Sa&ve as...', ; // 31
							'Save &All', ;   // 32
							'EMF Files', ;   // 33
							'All Files', ;   // 34
							'Ok'         ;   // 35
						}

#ifdef _MULTILINGUAL_
   cLang := Upper( Left( Set ( _SET_LANGUAGE ), 2 ) )

   // LANGUAGE IS NOT SUPPORTED BY hb_langSelect() FUNCTION
   IF ( _HMG_LANG_ID == 'FI' )    // FINNISH
      cLang := 'FI'
   ENDIF

   DO CASE
      // Russian
   CASE cLang == 'RU'
      aLang := { 'œÓÒÏÓÚ', ;
         '¬˚ıÓ‰', ;
         'œÂ˜‡Ú¸', ;
         '—Óı‡ÌËÚ¸', ;
         'Õ‡˜‡ÎÓ', ;
         'Õ‡Á‡‰', ;
         '¬ÔÂÂ‰', ;
         ' ÓÌÂˆ', ;
         '”‚ÂÎË˜ËÚ¸', ;
         '”ÏÂÌ¸¯ËÚ¸', ;
         'ŒÔˆËË', ;
         '—Ú‡ÌËˆ‡:', ;
         'œÓÒÏÓÚ ÒÚ‡ÌËˆ˚ ', ;
         'ÃËÌË‡Ú˛˚', ;
         '—Ú‡ÌËˆ‡', ;
         'œÂ˜‡Ú‡Ú¸ ÚÂÍÛ˘Û˛', ;
         '—Ú‡ÌËˆ:', ;
         'ƒÓÒÚË„ÌÛÚ ÔÂ‰ÂÎ Ï‡Ò¯Ú‡·ËÓ‚‡ÌËˇ!', ;
         'œ‡‡ÏÂÚ˚ ÔÂ˜‡ÚË', ;
         '—Ú‡ÌËˆ˚ Ò', ;
         'ÔÓ', ;
         ' ÓÔËÈ', ;
         'Õ‡ÔÂ˜‡Ú‡Ú¸', ;
         '¬ÒÂ ÒÚ‡ÌËˆ˚', ;
         'ÕÂ˜∏ÚÌ˚Â', ;
         '◊∏ÚÌ˚Â', ;
         '¬ÒÂ, ÌÓ ‚Ì‡˜‡ÎÂ ÌÂ˜∏ÚÌ˚Â', ;
         '¬ÒÂ, ÌÓ ‚Ì‡˜‡ÎÂ ˜∏ÚÌ˚Â', ;
         'œÂ˜‡Ú¸ ....', ;
         '¬ÒÚ‡‚¸ÚÂ ·ÛÏ‡„Û...', ;
         '—Óı‡ÌËÚ¸ Í‡Í...', ;
         '—Óı‡ÌËÚ¸ ‚ÒÂ', ;
         '‘‡ÈÎ˚ EMF', ;
         '¬ÒÂ Ù‡ÈÎ˚',  ;
			'Ok' ;
         }

      // Ukrainian
   CASE cLang == 'UK' .OR. cLang == 'UA'
      aLang := { 'œÂÂ„Îˇ‰', ;
         '¬Ëıi‰', ;
         'ƒÛÍ', ;
         '«·ÂÂ„ÚË', ;
         'œÓ˜‡ÚÓÍ', ;
         'Õ‡Á‡‰', ;
         '¬ÔÂÂ‰', ;
         ' iÌÂˆ¸', ;
         '«·iÎ¸¯ËÚË', ;
         '«ÏÂÌ¯ËÚË', ;
         'ŒÔˆiø', ;
         '—ÚÓiÌÍ‡:', ;
         'œÂÂ„Îˇ‰ ÒÚÓiÌÍË ', ;
         'ÃiÌi‡Ú˛Ë', ;
         '—ÚÓiÌÍ‡', ;
         'ƒÛÍÛ‚‡ÚË ÔÓÚÓ˜ÌÛ', ;
         '—ÚÓiÌÓÍ:', ;
         'ƒÓÒˇ„ÌÛÚ‡ ÏÂÊ‡ Ï‡Ò¯Ú‡·Û‚‡ÌÌˇ!', ;
         'œ‡‡ÏÂÚË ‰ÛÍÛ', ;
         '—ÚÓiÌÍË Á', ;
         'ÔÓ', ;
         ' ÓÔiÈ', ;
         'Õ‡‰ÛÍÛ‚‡ÚË', ;
         '”Òi ÒÚiÌÍË', ;
         'ÕÂÔ‡Ìi', ;
         'œ‡Ìi', ;
         '”Òi, ‡ÎÂ ÒÔÂ¯Û ÌÂÔ‡Ìi', ;
         '”Òi, ‡ÎÂ ÒÔÂ¯Û Ô‡Ìi', ;
         'ƒÛÍ ....', ;
         '«‡ÏiÌiÚ¸ Ô‡Ôi...', ;
         '«·ÂÂ„ÚË ˇÍ...', ;
         '«·ÂÂ„ÚË ‚ÒÂ', ;
         '‘‡ÈÎË EMF', ;
         '”Òi Ù‡ÈÎË', ;
			'Ok' ;			
         }

      // Italian
   CASE cLang == 'IT'
      aLang := { 'Anteprima', ;
         '&Cancella', ;
         'S&tampa', ;
         '&Salva', ;
         '&Primo', ;
         '&Indietro', ;
         '&Avanti', ;
         '&Ultimo', ;
         'Zoom In', ;
         'Zoom Out', ;
         '&Opzioni', ;
         'Pagina:', ;
         'Pagina anteprima ', ;
         'Miniatura Anteprima', ;
         'Pagina', ;
         'Stampa solo pagina attuale', ;
         'Pagine:', ;
         'Limite zoom !', ;
         'Opzioni Stampa', ;
         'Stampa da', ;
         'a', ;
         'Copie', ;
         'Range Stampa', ;
         'Tutte', ;
         'Solo dispari', ;
         'Solo pari', ;
         'Tutte iniziando dispari', ;
         'Tutte iniziando pari', ;
         'Stampa in corso ....', ;
         'Attendere cambio carta...', ;
         'Sa&ve as...', ;
         'Save &All', ;
         'EMF Files', ;
         'All Files',  ;
			'Ok' ;
         }

      // Spanish
   CASE cLang == 'ES'
      aLang := { 'Vista Previa', ;
         '&Cancelar', ;
         '&Imprimir', ;
         '&Guardar', ;
         '&Primera', ;
         '&Anterior', ;
         '&Siguiente', ;
         '&Ultima', ;
         'Zoom +', ;
         'Zoom -', ;
         '&Opciones', ;
         'Pag.:', ;
         'Pagina ', ;
         'Miniaturas', ;
         'Pag.', ;
         'Imprimir solo pag. actual', ;
         'Paginas:', ;
         'Zoom Maximo/Minimo', ;
         'Opciones de Impresion', ;
         'Imprimir Desde', ;
         'Hasta', ;
         'Copias', ;
         'Imprimir rango', ;
         'Todo a partir de desde', ;
         'Solo impares', ;
         'Solo pares', ;
         'Todo (impares primero)', ;
         'Todo (pares primero)', ;
         'Imprimiendo ....', ;
         'Esperando cambio de papel...', ;
         'Sa&ve as...', ;
         'Save &All', ;
         'EMF Files', ;
         'All Files',  ;
			'Ok' ;
         }

      // Polish
   CASE cLang == 'PL'
      aLang := { 'Podglπd', ;
         '&Rezygnuj', ;
         '&Drukuj', ;
         '&Zapisz', ;
         '&Pierwsza', ;
         'Poprz&ednia', ;
         '&NastÍpna', ;
         '&Ostatnia', ;
         'Po&wiÍksz', ;
         'Po&mniejsz', ;
         'Opc&je', ;
         'Idü do strony:', ;
         'Podglπd strony', ;
         'Podglπd miniaturek', ;
         'Strona', ;
         'Drukuj aktualnπ stronÍ', ;
         'Stron:', ;
         'Nie moøna wiÍcej !', ;
         'Opcje drukowania', ;
         'Drukuj od', ;
         'do', ;
         'Kopii', ;
         'Zakres', ;
         'Wszystkie z zakresu', ;
         'Tylko nieparzyste', ;
         'Tylko parzyste', ;
         'Najpierw nieparzyste', ;
         'Najpierw parzyste', ;
         'Drukowanie ....', ;
         'Czekam na zmiane papieru...', ;
         'Zapisz jako..', ;
         'Zapisz wszystko', ;
         'Pliki EMF', ;
         'Wszystkie pliki', ;
			'Ok' ;
         }

      // Portuguese
   CASE cLang == 'PT'
      aLang := { 'PrÈvisualizaÁ„o', ;
         '&Cancelar', ;
         '&Imprimir', ;
         '&Salvar', ;
         '&Primeira', ;
         '&Anterior', ;
         'PrÛximo', ;
         '&⁄ltimo', ;
         'Zoom +', ;
         'Zoom -', ;
         '&OpÁıes', ;
         'Pag.:', ;
         'P·gina ', ;
         'Miniaturas', ;
         'Pag.', ;
         'Imprimir somente a pag. atual', ;
         'P·ginas:', ;
         'Zoom M·ximo/Minimo', ;
         'OpÁıes de Impress„o', ;
         'Imprimir de', ;
         'a', ;
         'CÛpias', ;
         'Imprimir rango', ;
         'Tudo a partir desta', ;
         'SÛ Õmpares', ;
         'SÛ Pares', ;
         'Todas as Õmpares Primeiro', ;
         'Todas Pares primeiro', ;
         'Imprimindo ....', ;
         'Esperando por papel...', ;
         'Sa&lvar Como...', ;
         'Salvar &Tudo', ;
         'Arquivos EMF', ;
         'Todos Arquivos', ;
			'Ok' ;
         }

      // German
   CASE cLang == 'DE'
      aLang := { 'Vorschau', ;
         '&Abbruch', ;
         '&Drucken', ;
         '&Speichern', ;
         '&Erste', ;
         '&Vorige', ;
         '&N‰chste', ;
         '&Letzte', ;
         'Ver&grˆﬂern', ;
         'Ver&kleinern', ;
         '&Optionen', ;
         'Seite:', ;
         'Seitenvorschau', ;
         '‹berblick', ;
         'Seite', ;
         'Aktuelle Seite drucken', ;
         'Seiten:', ;
         'Maximum erreicht!', ;
         'Druckeroptionen', ;
         'Drucke von', ;
         'bis', ;
         'Anzahl', ;
         'Bereich', ;
         'Alle Seiten', ;
         'Ungerade Seiten', ;
         'Gerade Seiten', ;
         'Alles, ungerade Seiten zuerst', ;
         'Alles, gerade Seiten zuerst', ;
         'Druckt ....', ;
         'Bitte Papier nachlegen...', ;
         'Sa&ve as...', ;
         'Save &All', ;
         'EMF Files', ;
         'All Files', ;
			'Ok' ;
         }

      // French
   CASE cLang == 'FR'
      aLang := { 'PrÈvisualisation', ;
         '&Abandonner', ;
         '&Imprimer', ;
         '&Sauver', ;
         '&Premier', ;
         'P&rÈcÈdent', ;
         '&Suivant', ;
         '&Dernier', ;
         'Zoom +', ;
         'Zoom -', ;
         '&Options', ;
         'Aller ‡ la page:', ;
         'AperÁu de la page', ;
         'AperÁu affichettes', ;
         'Page', ;
         'Imprimer la page en cours', ;
         'Pages:', ;
         'Plus de zoom !', ;
         "Options d'impression", ;
         'Imprimer de', ;
         '‡', ;
         'Copies', ;
         "Intervalle d'impression", ;
         "Tout dans l'intervalle", ;
         'Impair seulement', ;
         'Pair seulement', ;
         "Tout mais impair d'abord", ;
         "Tout mais pair d'abord", ;
         'Impression ....', ;
         'Attente de changement de papier...', ;
         'Sa&ve as...', ;
         'Save &All', ;
         'EMF Files', ;
         'All Files', ;
			'Ok' ;
         }

      // Finnish
   CASE cLang == 'FI'
      aLang := { 'Esikatsele', ;
         '&Keskeyt‰', ;
         '&Tulosta', ;
         'T&allenna', ;
         '&Ensimm‰inen', ;
         'E&dellinen', ;
         '&Seuraava', ;
         '&Viimeinen', ;
         'Suurenna', ;
         'Pienenn‰', ;
         '&Optiot', ;
         'Mene sivulle:', ;
         'Esikatsele sivu ', ;
         'Esikatsele miniatyyrit', ;
         'Sivu', ;
         'Tulosta t‰m‰ sivu', ;
         'Sivuja:', ;
         'Ei voi suurentaa !', ;
         'Tulostus optiot', ;
         'Alkaen', ;
         '->', ;
         'Kopiot', ;
         'Tulostus alue', ;
         'Kaikki alueelta', ;
         'Vain parittomat', ;
         'Vain parilleset', ;
         'Kaikki paitsi ensim. pariton', ;
         'Kaikki paitsi ensim. parillinen', ;
         'Tulostan ....', ;
         'Odotan paperin vaihtoa...', ;
         'Tallenna nimell‰...', ;
         'Tallenna kaikki', ;
         'EMF Tiedostot', ;
         'Kaikki Tiedostot', ;
			'Ok' ;
         }

      // Dutch
   CASE cLang == 'NL'
      aLang := { 'Afdrukvoorbeeld', ;
         'Annuleer', ;
         'Print', ;
         'Opslaan', ;
         'Eerste', ;
         'Vorige', ;
         'Volgende', ;
         'Laatste', ;
         'Inzoomen', ;
         'Uitzoomen', ;
         'Opties', ;
         'Ga naar pagina:', ;
         'Pagina voorbeeld ', ;
         'Thumbnails voorbeeld', ;
         'Pagina', ;
         'Print alleen huidige pagina', ;
         "Pagina's:", ;
         'Geen zoom meer !', ;
         'Print opties', ;
         'Print van', ;
         'tot', ;
         'Aantal exemplaren', ;
         "Pagina's", ;
         "Alle pagina's", ;
         'Alleen oneven', ;
         'Alleen even', ;
         'Alles maar oneven eerst', ;
         'Alles maar even eerst', ;
         'Printen ....', ;
         'Wacht op papier wissel...', ;
         'Be&waar als...', ;
         'Bewaar &Alles', ;
         'EMF-bestanden', ;
         'Alle bestanden', ;
			'Ok' ;
         }

      // Czech
   CASE cLang == 'CS'
      aLang := { "N·hled", ;
         "&Storno", ;
         "&Tisk", ;
         "&Uloûit", ;
         "&PrvnÌ", ;
         "P&¯edchozÌ", ;
         "&DalöÌ", ;
         "P&oslednÌ", ;
         "Z&vÏtöit", ;
         "&Zmenöit", ;
         "&Moûnosti", ;
         "Ukaû stranu:", ;
         "N·hled strany ", ;
         "N·hled vÌce str·n", ;
         "Strana", ;
         "Tisk aktu·lnÌ strany", ;
         "Str·n:", ;
         "Nemoûno d·le mÏnit velikost!", ;
         "Moûnosti tisku", ;
         "Tisk od", ;
         "po", ;
         "KÛpiÌ", ;
         "Tisk stran", ;
         "Vöechny stran", ;
         "Jenom lichÈ", ;
         "Jenom sudÈ", ;
         "Vöechny kromÏ prvnÌ lichÈ", ;
         "Vöechny kromÏ prvnÌ sudÈj", ;
         "Tisknu ...", ;
         "»ek·m na papÌr ...", ;
         "Uloûit &jako...", ;
         "Uloûit &vöechno", ;
         "EMF soubor", ;
         "Vöechny soubory", ;
			'Ok' ;
         }

      // Slovak
   CASE cLang == 'SK'
      aLang := { "N·hæad", ;
         "&Storno", ;
         "&TlaË", ;
         "&Uloûiù", ;
         "&Prv·", ;
         "P&redch·zaj˙ca", ;
         "&œalöia", ;
         "Po&sledn·", ;
         "Z&v‰Ëöiù", ;
         "&Zmenöiù", ;
         "&Moûnosti", ;
         "Uk·û stranu:", ;
         "N·hæad strany ", ;
         "N·hæad viacer˝ch str·nok", ;
         "Strana", ;
         "TlaË aktu·lnej strany", ;
         "Strana:", ;
         "Veækosù Ôalej nie je moûnÈ meniù!", ;
         "Moûnosti tlaËe", ;
         "TlaË od", ;
         "po", ;
         "KÛpiÌ", ;
         "TlaË str·n", ;
         "Vöetky strany", ;
         "Len nep·rne", ;
         "Len p·rne", ;
         "Vöetko okrem prvej nep·rnej", ;
         "Vöetko okrem prvej p·rnej", ;
         "TlaËÌm ...", ;
         "»ak·m na papier ...", ;
         "Uloûiù &ako...", ;
         "Uloûiù &vöetko", ;
         "EMF s˙bor", ;
         "Vöetky s˙bory", ;
			'Ok' ;
         }

      // Slovenian
   CASE cLang == 'SL'
      aLang := { 'Predgled', ;
         'Prekini', ;
         'Natisni', ;
         'Shrani', ;
         'Prva', ;
         'Prejönja', ;
         'Naslednja', ;
         'Zadnja', ;
         'PoveËaj', ;
         'Pomanjöaj', ;
         'Moûnosti', ;
         'Skok na stran:', ;
         'Predgled', ;
         'Mini predgled', ;
         'Stran', ;
         'Samo trenutna stran', ;
         'Strani:', ;
         'Ni veË poveËave!', ;
         'Moûnosti tiskanja', ;
         'Tiskaj od', ;
         'do', ;
         'Kopij', ;
         'Tiskanje', ;
         'Vse iz izbora', ;
         'Samo neparne strani', ;
         'Samo parne strani', ;
         'Vse - le brez prve neparne strani', ;
         'Vse - le brez prve parne strani', ;
         'Tiskanje ....', ;
         '»akanje na zamenjavo papirja...', ;
         'Shrani kot...', ;
         'Shrani vse', ;
         'EMF datoteke', ;
         'Vse datoteke', ;
			'Ok' ;
         }

      // Hungarian
   CASE cLang == 'HU'
      aLang := { "ElınÈzet", ;
         "&MÈgse", ;
         "Nyo&mtat·s", ;
         "&MentÈs", ;
         "&Elsı", ;
         "E&lızı", ;
         "&Kˆvetkezı", ;
         "&UtolsÛ", ;
         "&NagyÌt·s", ;
         "K&icsinyÌtÈs", ;
         "&OpciÛk", ;
         "Oldalt mutasd:", ;
         "Oldal elınÈzete ", ;
         "Tˆbb oldal elınÈzete", ;
         "Oldal", ;
         "Aktu·lis oldal nyomtat·sa", ;
         "Oldal:", ;
         "A nagys·g tov·bb nem v·ltoztathatÛ!", ;
         "Nyomtat·si lehetısÈgek", ;
         "Nyomtat·s ettıl", ;
         "eddig", ;
         "M·solat", ;
         "Oldalak nyomtat·sa", ;
         "Minden oldalt", ;
         "Csak a p·ratlan", ;
         "Csak a p·ros", ;
         "Mindet kivÈve az elsı p·ratlant", ;
         "Mindet kivÈve az elsı p·rost", ;
         "Nyomtatom ...", ;
         "PapÌrra v·rok ...", ;
         "MentÈs m·skÈnt ...", ;
         "Mindet mentsd", ;
         "EMF ·llom·ny", ;
         "Minden ·llom·ny", ;
			'Ok' ;
         }

      // Greek - Ellinika
   CASE cLang == 'EL'
      aLang := {  '–ÒÔ‚ÔÎﬁ', ;
						'∏&ÓÔ‰ÔÚ', ;
						'&≈ÍÙ˝˘ÛÁ', ;
						'&¡ÔËﬁÍÂıÛÁ ÛÂÎﬂ‰·Ú', ;
						'&1Á ÛÂÎﬂ‰·', ;
						'–&ÒÔÁ„.”ÂÎ.', ;
						'&≈¸ÏÂÌÁ', ;
						'&‘ÂÎÂıÙ·ﬂ·', ;
						'Zoom +', ;
						'Zoom -', ;
						'&≈ÈÎÔ„›Ú', ;
						'–ÒÔ‚ÔÎﬁ ÛÂÎﬂ‰·Ú:', ;
						'–ÒÔ‚ÔÎﬁ ', ;
						'ÃÈÍÒÔ„Ò·ˆﬂÂÚ', ;
						'”ÂÎ.', ;
						'‘˝˘ÛÂ Ï¸ÌÔ ÙÁÌ ·ÒÔ˝Û·', ;
						'”ÂÎﬂ‰ÂÚ:', ;
						'‘›ÎÔÚ zoom', ;
						'≈ÈÎÔ„›Ú', ;
						'‘˝˘ÛÂ ·¸ ÛÂÎﬂ‰·', ;
						'∏˘Ú ÛÂÎﬂ‰·', ;
						'¡ÌÙﬂ„Ò·ˆ·', ;
						'≈˝ÒÔÚ ÂÍÙ˝˘ÛÁÚ', ;
						'œÎÂÚ ÙÈÚ ÛÂÎﬂ‰ÂÚ', ;
						'Ã¸ÌÔ ÙÈÚ ÏÔÌ›Ú ÛÂÎﬂ‰ÂÚ ', ;
						'Ã¸ÌÔ ÙÈÚ Êı„›Ú ÛÂÎﬂ‰ÂÚ', ;
						'œÎÂÚ ÂÍÙÔÚ ·Ô ÙÁÌ 1Á ÏÔÌﬁ', ;
						'œÎÂÚ ÂÍÙÔÚ ·Ô ÙÁÌ 1Á Êı„ﬁ', ;
						'≈ÍÙı˛Ì˘ ....', ;
						'¡Ì·ÏÔÌﬁ „È· ·ÎÎ·„ﬁ ˜·ÒÙÈÔ˝...', ;
						'¡ÔËﬁÍÂıÛÁ ÛÂÎﬂ‰·Ú ˘Ú..', ;
						'¡ÔËﬁÍÂıÛÁ ¸Î˘Ì Ù˘Ì ÛÂÎﬂ‰˘Ì', ;
						'¡Ò˜Âﬂ· EMF', ;
						'ºÎ· Ù· ·Ò˜Âﬂ·', ;
						'≈ÌÙ‹ÓÂÈ' ;
					}

      // Bulgarian
   CASE cLang == 'BG'
      aLang := { 'œÂ„ÎÂ‰', ;
         '»ÁıÓ‰', ;
         'œÂ˜‡Ú', ;
         '—˙ı‡ÌË', ;
         'Õ‡˜‡ÎÓ', ;
         'Õ‡Á‡‰', ;
         'Õ‡ÔÂ‰', ;
         ' ‡È', ;
         '”‚ÂÎË˜Ë', ;
         'Õ‡Ï‡ÎË', ;
         'ŒÔˆËË', ;
         '—Ú‡ÌËˆ‡:', ;
         'œÂ„ÎÂ‰ Ì‡ ÒÚ‡ÌËˆ‡Ú‡ ', ;
         'ÃËÌË‡Ú˛Ë', ;
         '—Ú‡ÌËˆ‡', ;
         'œÂ˜‡Ú‡ÌÂ Ì‡ ÚÂÍÛ˘‡', ;
         '—Ú‡ÌËˆË:', ;
         'ƒÓÒÚË„Ì‡Ú e ÔÂ‰ÂÎ‡ Ì‡ Ï‡˘‡·Ë‡ÌÂ!', ;
         'œ‡‡ÏÂÚË Á‡ ÔÂ˜‡Ú', ;
         '—Ú‡ÌËˆË ÓÚ', ;
         '‰Ó', ;
         ' ÓÔËˇ', ;
         'Õ‡ÔÂ˜‡Ú‡È', ;
         '¬ÒË˜ÍË ÒÚ‡ÌËˆË', ;
         'ÕÂ˜ÂÚÌËÚÂ', ;
         '◊ÂÚÌËÚÂ', ;
         '¬ÒË˜ÍË, ÌÓ Ô˙‚Ó ÌÂ˜ÂÚÌËÚÂ', ;
         '¬ÒË˜ÍË, ÌÓ Ô˙‚Ó ˜ÂÚÌËÚÂ', ;
         'œÂ˜‡Ú ....', ;
         'œÓÒÚ‡‚ÂÚÂ ı‡ÚËˇ...', ;
         '—˙ı‡ÌË Í‡ÚÓ...', ;
         '—˙ı‡ÌË ‚ÒË˜ÍÓ', ;
         '‘‡ÈÎÓ‚Â EMF', ;
         '¬ÒË˜ÍË Ù‡ÈÎÓ‚Â',  ;
			'Ok' ;
         }
   ENDCASE

#endif

RETURN aLang

METHOD Preview() CLASS HBPrinter
   
   LOCAL i, pi := 1
   LOCAL cToolButtonFont := GetDefaultFontName() // 'Segoe UI' for Vista or later, 'Tahoma' for XP, "MS Sans Serif" otherwise
	LOCAL nButtons, nButWidth
   PRIVATE page := 1, scale := ::PREVIEWSCALE, azoom := { 0, 0, 0, 0 }, ahs := {}, npages := {}
   PRIVATE dx, dy, ngroup := -1, ath := {}, iloscstron := Len( ::metafiles )
   PRIVATE aOpisy := LangInit()

   ::nFromPage := Min( ::nFromPage, iloscstron )
   if ::nwhattoprint < 2
      ::nTopage := iloscstron
   ELSE
      ::nToPage := Min( iloscstron, ::nToPage )
   ENDIF

   IF !::PreviewMode .OR. Empty( ::metafiles )
      RETURN self
   ENDIF

   FOR pi = 1 TO iloscstron
      AAdd( npages, PadL( pi, 4 ) )
   NEXT pi

   AAdd( ahs, { 0, 0, 0, 0, 0, 0, 0 } )

   if ::Previewrect[ 3 ] == -1 .AND. ::Previewrect[ 4 ] == -1
      ::Previewrect := rr_getdesktoparea()
   ENDIF
   if ::PreviewRect[ 3 ] > 0 .AND. ::PreviewRect[ 4 ] > 0
      ahs[ 1, 1 ] := ::Previewrect[ 1 ]
      ahs[ 1, 2 ] := ::Previewrect[ 2 ]
      ahs[ 1, 3 ] := ::Previewrect[ 3 ]
      ahs[ 1, 4 ] := ::Previewrect[ 4 ]
      ahs[ 1, 5 ] := ::Previewrect[ 3 ] - ::Previewrect[ 1 ] + 1
      ahs[ 1, 6 ] := ::Previewrect[ 4 ] - ::Previewrect[ 2 ] + 1
   ELSE
      pi := rr_getdesktoparea()
      ahs[ 1, 1 ] := pi[ 1 ] + 10
      ahs[ 1, 2 ] := pi[ 2 ] + 10
      ahs[ 1, 3 ] := pi[ 3 ] - 10
      ahs[ 1, 4 ] := pi[ 4 ] - 10
      ahs[ 1, 5 ] := ahs[ 1, 3 ] - ahs[ 1, 1 ] + 1
      ahs[ 1, 6 ] := ahs[ 1, 4 ] - ahs[ 1, 2 ] + 1
   ENDIF

   DEFINE WINDOW HBPREVIEW ;
      AT  ahs[ 1, 1 ], ahs[ 1, 2 ] ;
      WIDTH ahs[ 1, 6 ] HEIGHT ahs[ 1, 5 ] ;
      TITLE aopisy[ 1 ] ICON 'zzz_Printicon' ;
      MODAL NOSIZE ;
      FONT 'Arial' SIZE 9

   _DefineHotKey( "HBPREVIEW", 0,  VK_ESCAPE, {|| ::PrevClose( .T. ) } ) // Escape
   _DefineHotKey( "HBPREVIEW", 0, VK_ADD, {|| scale := scale * 1.25, ::PrevShow() } ) // zoom in
   _DefineHotKey( "HBPREVIEW", 0, VK_SUBTRACT, {|| scale := scale / 1.25, ::PrevShow() } ) // zoom out
   _DefineHotKey( "HBPREVIEW", MOD_CONTROL, VK_P, {|| ::prevprint(), if( ::CLSPREVIEW, ::PrevClose( .F. ), NIL ) } ) // Print
   _DefineHotKey( "HBPREVIEW", 0,  VK_PRIOR, {|| page := ::CurPage := if( page == 1, 1, page - 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // back
   _DefineHotKey( "HBPREVIEW", 0,  VK_NEXT, {|| page := ::CurPage := if( page == iloscstron, page, page + 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // next

   DEFINE STATUSBAR
      STATUSITEM aopisy[ 15 ] + " " + hb_ntos( page ) WIDTH 100
      STATUSITEM aopisy[ 16 ] WIDTH 200 ICON 'zzz_Printicon'  ACTION ::PREVPRINT( page ) RAISED
      STATUSITEM aopisy[ 17 ] + " " + hb_ntos( iloscstron ) WIDTH 100
   END STATUSBAR

   // @ 15, ahs[ 1, 6 ] - 277  COMBOBOX combo_1 ITEMS npages VALUE 1 WIDTH 58 FONT 'Arial' SIZE 8 NOTABSTOP ON CHANGE {|| page := ::CurPage := HBPREVIEW.combo_1.value, ::PrevShow() }
   // @ 19, ahs[ 1, 6 ] - 384 LABEL prl VALUE aopisy[ 12 ] WIDTH 100 HEIGHT 18 FONT 'Arial' SIZE 8 BACKCOLOR iif( isseven(), { 211, 218, 237 }, iif( _HMG_IsXP, { 239, 235, 219 }, NIL ) ) RIGHTALIGN
	
	nButWidth := 75
	
//	@ 19, ahs[ 1, 6 ] - ((nButtons * nButWidth) -   5) LABEL prl VALUE aopisy[ 12 ] WIDTH 100 HEIGHT 18 FONT 'Arial' SIZE 8 BACKCOLOR iif( isseven(), { 211, 218, 237 }, iif( _HMG_IsXP, { 239, 235, 219 }, NIL ) ) RIGHTALIGN
//	@ 15, ahs[ 1, 6 ] - ((nButtons * nButWidth) -   5) + 105 COMBOBOX combo_1 ITEMS npages VALUE 1 WIDTH 58 FONT 'Arial' SIZE 8 NOTABSTOP ON CHANGE {|| page := ::CurPage := HBPREVIEW.combo_1.value, ::PrevShow() }	
	IF iloscstron > 1
		nButtons := 10 // 6 + Iif( iloscstron > 1, 4 , 0 )
		@ 19, ( (nButtons * nButWidth) +  60 ) LABEL prl VALUE aopisy[ 12 ] WIDTH 100 HEIGHT 18 FONT 'Arial' SIZE 8 BACKCOLOR iif( isseven(), { 211, 218, 237 }, iif( _HMG_IsXP, { 239, 235, 219 }, NIL ) ) RIGHTALIGN
		@ 15, ( (nButtons * nButWidth) + 170 ) COMBOBOX combo_1 ITEMS npages VALUE 1 WIDTH 40 FONT 'Arial' SIZE 8 NOTABSTOP ON CHANGE {|| page := ::CurPage := HBPREVIEW.combo_1.value, ::PrevShow() }	
	ENDIF

   DEFINE SPLITBOX
      DEFINE TOOLBAR TB1 BUTTONSIZE /*50, 37*/ nButWidth, 40 FONT iif( AScan( rr_GetFontNames(), {| x | x == cToolButtonFont } ) > 0, cToolButtonFont, 'Arial' ) SIZE 8 FLAT BREAK

			BUTTON B2 CAPTION  aopisy[ 3 ]  PICTURE 'hbprint_print'   ACTION {|| ::prevprint(), iif( ::CLSPREVIEW, ::PrevClose( .F. ), nil ) }
         BUTTON B3 CAPTION  aopisy[ 4 ]  PICTURE 'hbprint_save'  WHOLEDROPDOWN
         DEFINE DROPDOWN MENU BUTTON B3
            ITEM aopisy[ 4 ]  ACTION {|| ::savemetafiles( ::CurPage ) }
            ITEM aopisy[ 31 ] ACTION {|| pi := Putfile ( { { aopisy[ 33 ], '*.emf' }, { aopisy[ 34 ], '*.*' } }, , GetStartUpFolder(), .T., ::DOCNAME ), iif( Empty( pi ), , ::savemetafiles( ::CurPage, pi ) ) }
            ITEM aopisy[ 32 ] ACTION {|| ::savemetafiles() }
			END MENU
			BUTTON B1 CAPTION  aopisy[ 2 ]  PICTURE 'hbprint_close'   ACTION {|| ::PrevClose( .T. ) } SEPARATOR			
			BUTTON B10 CAPTION aopisy[ 11 ] PICTURE 'hbprint_option'  ACTION {|| ::PrintOption() } SEPARATOR
			BUTTON B8 CAPTION  aopisy[ 9 ]  PICTURE 'hbprint_zoomin'  ACTION {|| scale := scale * 1.25, ::PrevShow() }
			BUTTON B9 CAPTION  aopisy[ 10 ] PICTURE 'hbprint_zoomout' ACTION {|| scale := scale / 1.25, ::PrevShow() } SEPARATOR			
			IF iloscstron > 1
				BUTTON B4 CAPTION  aopisy[ 5 ] PICTURE 'hbprint_top'   ACTION {|| page := ::CurPage := 1, HBPREVIEW.combo_1.value := page, ::PrevShow() }
				BUTTON B5 CAPTION  aopisy[ 6 ] PICTURE 'hbprint_back'  ACTION {|| page := ::CurPage := iif( page == 1, 1, page - 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() }
				BUTTON B6 CAPTION  aopisy[ 7 ] PICTURE 'hbprint_next'  ACTION {|| page := ::CurPage := iif( page == iloscstron, page, page + 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() }
				BUTTON B7 CAPTION  aopisy[ 8 ] PICTURE 'hbprint_end'   ACTION {|| page := ::CurPage := iloscstron, HBPREVIEW.combo_1.value := page, ::PrevShow() } SEPARATOR
			ENDIF

      END TOOLBAR

      AAdd( ahs, { 0, 0, 0, 0, 0, 0, GetFormHandle( "hbpreview" ) } )
      rr_getclientrect( ahs[ 2 ] )
      AAdd( ahs, { 0, 0, 0, 0, 0, 0, GetControlHandle( "Tb1", "hbpreview" ) } )
      rr_getclientrect( ahs[ 3 ] )
      AAdd( ahs, { 0, 0, 0, 0, 0, 0, GetControlHandle( "StatusBar", "hbpreview" ) } )
      rr_getclientrect( ahs[ 4 ] )

   DEFINE WINDOW HBPREVIEW1  ;
      WIDTH ahs[ 2, 6 ] - 15  HEIGHT ahs[ 2, 5 ] - ahs[ 3, 5 ] - ahs[ 4, 5 ] - 10 ;
      VIRTUAL WIDTH ahs[ 2, 6 ] - 5;
      VIRTUAL HEIGHT ahs[ 2, 5 ] - ahs[ 3, 5 ] - ahs[ 4, 5 ] ;
		SPLITCHILD NOCAPTION //GRIPPERTEXT "P"
      // TITLE aopisy[ 13 ] SPLITCHILD GRIPPERTEXT "P"

      AAdd( ahs, { 0, 0, 0, 0, 0, 0, GetFormHandle( "hbpreview1" ) } )
      rr_getclientrect( ahs[ 5 ] )
      @ ahs[ 5, 2 ] + 10, ahs[ 5, 1 ] + 10 IMAGE I1  PICTURE "" WIDTH ahs[ 5, 6 ] - 10 HEIGHT ahs[ 5, 5 ] - 10
		// @ ahs[ 5, 2 ] + 10, ((ahs[ 2, 6 ] - 15)/2) - ((ahs[ 5, 6 ] - 10)/4) IMAGE I1  PICTURE "" WIDTH ahs[ 5, 6 ] - 10 HEIGHT ahs[ 5, 5 ] - 10
      AAdd( ahs, { 0, 0, 0, 0, 0, 0, GetControlHandle( "i1", "hbpreview1" ) } )
      rr_getclientrect( ahs[ 6 ] )

      _DefineHotKey( "HBPREVIEW1", 0, VK_ESCAPE,      {|| _ReleaseWindow( "HBPREVIEW" ) } )
      _DefineHotKey( "HBPREVIEW1", 0, VK_ADD,         {|| scale := scale * 1.25, :: PrevShow () } )
      _DefineHotKey( "HBPREVIEW1", 0, VK_SUBTRACT,    {|| scale := scale / 1.25, :: PrevShow () } )
      _DefineHotKey( "HBPREVIEW1", MOD_CONTROL, VK_P, {|| ::prevprint(), iif( ::CLSPREVIEW, ::PrevClose( .F. ), NIL ) } ) // Print

   IF iloscstron > 1
      _DefineHotKey( "HBPREVIEW1", 0, VK_PRIOR, {|| page := ::CurPage := iif( page == 1, 1, page - 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // back
      _DefineHotKey( "HBPREVIEW1", 0, VK_NEXT,  {|| page := ::CurPage := iif( page == iloscstron, page, page + 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // next
      _DefineHotKey( "HBPREVIEW1", 0, VK_END,   {|| page := ::CurPage := iloscstron, HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // end
      _DefineHotKey( "HBPREVIEW1", 0, VK_HOME,  {|| page := ::CurPage := 1, HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // home
      _DefineHotKey( "HBPREVIEW1", 0, VK_LEFT,  {|| page := ::CurPage := iif( page == 1, 1, page - 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // Left
      _DefineHotKey( "HBPREVIEW1", 0, VK_UP,    {|| page := ::CurPage := iif( page == 1, 1, page - 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // up
      _DefineHotKey( "HBPREVIEW1", 0, VK_RIGHT, {|| page := ::CurPage := iif( page == iloscstron, page, page + 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // right
      _DefineHotKey( "HBPREVIEW1", 0, VK_DOWN,  {|| page := ::CurPage := iif( page == iloscstron, page, page + 1 ), HBPREVIEW.combo_1.value := page, ::PrevShow() } ) // down
   ENDIF
   END WINDOW
	CENTER WINDOW HBPREVIEW1

   IF ::thumbnails .AND. iloscstron > 1
      DEFINE WINDOW HBPREVIEW2  ;
         WIDTH ahs[ 2, 6 ] - 15  HEIGHT ahs[ 2, 5 ] - ahs[ 3, 5 ] - ahs[ 4, 5 ] - 10 ;
         TITLE aopisy[ 14 ] SPLITCHILD GRIPPERTEXT "T"

      AAdd( ahs, { 0, 0, 0, 0, 0, 0, GetFormHandle( "hbpreview2" ) } )
      rr_getClientRect( ahs[ 7 ] )
      dx := ( ahs[ 5, 6 ] - 20 ) / 5 - 5
      dy := ahs[ 5, 5 ] / 3 - 5
      FOR i := 1 TO 15
         AAdd( ath, { 0, 0, 0, 0, 0 } )
         if ::Metafiles[ 1, 2 ] >= ::Metafiles[ 1, 3 ]
            ath[ i, 3 ] := dy - 5
            ath[ i, 4 ] := dx * ::Metafiles[ 1, 3 ] / ::Metafiles[ 1, 2 ] - 5
         ELSE
            ath[ i, 4 ] := dx - 5
            ath[ i, 3 ] := dy * ::Metafiles[ 1, 2 ] / ::Metafiles[ 1, 3 ] - 5
         ENDIF
         ath[ i, 1 ] := Int( ( i - 1 ) / 5 ) * dy + 5
         ath[ i, 2 ] := ( ( i - 1 ) % 5 ) * dx + 5
      NEXT
      @ath[ 1,1 ], ath[ 1,2 ]  image it1  of hbpreview2 PICTURE "" action {|| ::Prevthumb( 1 ) } width ath[ 1,4 ] height ath[ 1,3 ]
      @ath[ 2,1 ], ath[ 2,2 ]  image it2  of hbpreview2 PICTURE "" action {|| ::Prevthumb( 2 ) } width ath[ 2,4 ] height ath[ 2,3 ]
      @ath[ 3,1 ], ath[ 3,2 ]  image it3  of hbpreview2 PICTURE "" action {|| ::Prevthumb( 3 ) } width ath[ 3,4 ] height ath[ 3,3 ]
      @ath[ 4,1 ], ath[ 4,2 ]  image it4  of hbpreview2 PICTURE "" action {|| ::Prevthumb( 4 ) } width ath[ 4,4 ] height ath[ 4,3 ]
      @ath[ 5,1 ], ath[ 5,2 ]  image it5  of hbpreview2 PICTURE "" action {|| ::Prevthumb( 5 ) } width ath[ 5,4 ] height ath[ 5,3 ]
      @ath[ 6,1 ], ath[ 6,2 ]  image it6  of hbpreview2 PICTURE "" action {|| ::Prevthumb( 6 ) } width ath[ 6,4 ] height ath[ 6,3 ]
      @ath[ 7,1 ], ath[ 7,2 ]  image it7  of hbpreview2 PICTURE "" action {|| ::Prevthumb( 7 ) } width ath[ 7,4 ] height ath[ 7,3 ]
      @ath[ 8,1 ], ath[ 8,2 ]  image it8  of hbpreview2 PICTURE "" action {|| ::Prevthumb( 8 ) } width ath[ 8,4 ] height ath[ 8,3 ]
      @ath[ 9,1 ], ath[ 9,2 ]  image it9  of hbpreview2 PICTURE "" action {|| ::Prevthumb( 9 ) } width ath[ 9,4 ] height ath[ 9,3 ]
      @ath[ 10, 1 ], ath[ 10, 2 ]  image it10 of hbpreview2 PICTURE "" action {|| ::Prevthumb( 10 ) } width ath[ 10, 4 ] height ath[ 10, 3 ]
      @ath[ 11, 1 ], ath[ 11, 2 ]  image it11 of hbpreview2 PICTURE "" action {|| ::Prevthumb( 11 ) } width ath[ 11, 4 ] height ath[ 11, 3 ]
      @ath[ 12, 1 ], ath[ 12, 2 ]  image it12 of hbpreview2 PICTURE "" action {|| ::Prevthumb( 12 ) } width ath[ 12, 4 ] height ath[ 12, 3 ]
      @ath[ 13, 1 ], ath[ 13, 2 ]  image it13 of hbpreview2 PICTURE "" action {|| ::Prevthumb( 13 ) } width ath[ 13, 4 ] height ath[ 13, 3 ]
      @ath[ 14, 1 ], ath[ 14, 2 ]  image it14 of hbpreview2 PICTURE "" action {|| ::Prevthumb( 14 ) } width ath[ 14, 4 ] height ath[ 14, 3 ]
      @ath[ 15, 1 ], ath[ 15, 2 ]  image it15 of hbpreview2 PICTURE "" action {|| ::Prevthumb( 15 ) } width ath[ 15, 4 ] height ath[ 15, 3 ]

      FOR i := 1 TO 15
         ath[ i, 5 ] := GetControlHandle( "it" + hb_ntos( i ), "hbpreview2" )
         rr_playthumb( ath[ i ], ::Metafiles[ i ], hb_ntos( i ), i )
         IF i >= iloscstron
            EXIT
         ENDIF
      NEXT

      END WINDOW
   ENDIF
   END SPLITBOX
   END WINDOW
   ::PrevShow()
   ACTIVATE WINDOW HBPREVIEW

RETURN NIL

METHOD PrevClose( lEsc ) CLASS HBPrinter

   ::lEscaped := lEsc
   _ReleaseWindow ( "HBPREVIEW" )

RETURN self

METHOD PrintOption() CLASS HBPrinter

   LOCAL OKprint := .F.

   IF IsWindowDefined( PrOpt ) == .F.
      
      SET GETBOX FOCUS BACKCOLOR
      
      /*
		DEFINE WINDOW PrOpt AT 0, 0 ;
         WIDTH 300 HEIGHT 150 ;
         TITLE aopisy[ 19 ] ;
         ICON 'zzz_Printicon' ;
         MODAL ;
         NOSIZE ;
         FONT 'Arial' SIZE 9

      @  2,   2 FRAME   PrOptFrame  WIDTH 290 HEIGHT 118 - iif( _HMG_IsXP, GetBorderHeight(), 0 )
      @ 18,  10 LABEL   label_11  VALUE aopisy[ 20 ] WIDTH 79 HEIGHT 21 FONT 'Arial' SIZE 9  VCENTERALIGN
      @ 18,  90 TEXTBOX textFrom HEIGHT 21 WIDTH 33 NUMERIC Font 'Arial' SIZE 9 MAXLENGTH 3 RIGHTALIGN ON ENTER PrOpt.TextTo.setfocus
      @ 18, 134 LABEL   label_12  VALUE aopisy[ 21 ] WIDTH 14 HEIGHT 21 FONT 'Arial' SIZE 9  VCENTERALIGN
      @ 18, 156 TEXTBOX textTo HEIGHT 21 WIDTH 33 NUMERIC Font 'Arial' SIZE 9 MAXLENGTH 3 RIGHTALIGN ON ENTER PrOpt.TextCopies.setfocus
      @ 18, 200 LABEL   label_18  VALUE aopisy[ 22 ] WIDTH 40 HEIGHT 21 FONT 'Arial' SIZE 9  VCENTERALIGN
      @ 18, 252 TEXTBOX textCopies  HEIGHT 21 WIDTH 30 NUMERIC Font 'Arial' SIZE 9 MAXLENGTH 3 RIGHTALIGN ON ENTER PrOpt.prnCombo.setfocus
      @ 50,  10 LABEL   label_13  VALUE aopisy[ 23 ] WIDTH 79 HEIGHT 21 FONT 'Arial' SIZE 9  VCENTERALIGN
      @ 50,  90 COMBOBOX prnCombo VALUE ::PRINTOPT ITEMS { aopisy[ 24 ], aopisy[ 25 ], aopisy[ 26 ], aopisy[ 27 ], aopisy[ 28 ] } ;
         WIDTH 195 FONT 'Arial' SIZE 9 ON ENTER PrOpt.Button_14.setfocus

      @ 84, 90  BUTTON button_14 CAPTION "&OK" ;
         ACTION {|| OKprint := .T., ::nFromPage := PrOpt.textFrom.Value, ::nToPage := PrOpt.textTo.Value, ;
         ::nCopies := Max( PrOpt.textCopies.Value, 1 ), ::PrintOpt := PrOpt.prnCombo.Value, PrOpt.Release } ;
         WIDTH 93 HEIGHT 24 ;
         FONT 'Arial' SIZE 9

      @ 84, 190 BUTTON button_15 CAPTION aopisy[ 2 ] ;
         ACTION PrOpt.Release ;
         WIDTH 93 HEIGHT 24 ;
         FONT 'Arial' SIZE 9

      END WINDOW
		*/
		LOAD WINDOW PrOpt
      _DefineHotKey( "PrOpt", 0, VK_ESCAPE, {|| _ReleaseWindow( "PrOpt" ) } )
      PrOpt.textCopies.Value := ::nCopies
      PrOpt.textFrom.Value := Max( ::nfrompage, 1 )
      PrOpt.textTo.Value := iif( ::nwhattoprint < 2, iloscstron, ::ntopage )
      PrOpt.Center
      PrOpt.Activate

   ENDIF

RETURN OKPrint

#ifdef _DEBUG_
METHOD ReportData( l_x1, l_x2, l_x3, l_x4, l_x5, l_x6 ) CLASS HBPrinter
   SET PRINTER TO "hbprinter.rep" ADDITIVE
   SET DEVICE TO PRINT
   SET PRINTER ON
   SET CONSOLE OFF
   ? '-----------------', Date(), Time()
   ?
   ?? if( ValType( l_x1 ) <> "U", l_x1, "," )
   ?? if( ValType( l_x2 ) <> "U", l_x2, "," )
   ?? if( ValType( l_x3 ) <> "U", l_x3, "," )
   ?? if( ValType( l_x4 ) <> "U", l_x4, "," )
   ?? if( ValType( l_x5 ) <> "U", l_x5, "," )
   ?? if( ValType( l_x6 ) <> "U", l_x6, "," )
   ? 'HDC            :', ::HDC
   ? 'HDCREF         :', ::HDCREF
   ? 'PRINTERNAME    :', ::PRINTERNAME
   ? 'PRINTEDEFAULT  :', ::PRINTERDEFAULT
   ? 'VERT X HORZ SIZE         :', ::DEVCAPS[ 1 ], "x", ::DEVCAPS[ 2 ]
   ? 'VERT X HORZ RES          :', ::DEVCAPS[ 3 ], "x", ::DEVCAPS[ 4 ]
   ? 'VERT X HORZ LOGPIX       :', ::DEVCAPS[ 5 ], "x", ::DEVCAPS[ 6 ]
   ? 'VERT X HORZ PHYS. SIZE   :', ::DEVCAPS[ 7 ], "x", ::DEVCAPS[ 8 ]
   ? 'VERT X HORZ PHYS. OFFSET :', ::DEVCAPS[ 9 ], "x", ::DEVCAPS[ 10 ]
   ? 'VERT X HORZ FONT SIZE    :', ::DEVCAPS[ 11 ], "x", ::DEVCAPS[ 12 ]
   ? 'VERT X HORZ ROWS COLS    :', ::DEVCAPS[ 13 ], "x", ::DEVCAPS[ 14 ]
   ? 'ORIENTATION              :', ::DEVCAPS[ 15 ]
   ? 'PAPER SIZE               :', ::DEVCAPS[ 17 ]
   SET PRINTER OFF
   SET PRINTER TO
   SET CONSOLE ON
   SET DEVICE TO SCREEN

RETURN self
#endif


#pragma BEGINDUMP

#include <mgdefs.h>
#include "hbapiitm.h"

#include <olectl.h>
#include <commctrl.h>

#ifdef __XHARBOUR__
#define HB_PARC         hb_parc
#define HB_PARNL3       hb_parnl
#else
#define HB_PARC         hb_parvc
#if defined( _WIN64 )
#define HB_PARNL3       hb_parvnll
#else
#define HB_PARNL3       hb_parvnl
#endif
#endif

static HDC              hDC    = NULL;
static HDC              hDCRef = NULL;
static HDC              hDCtemp;
static DEVMODE *        pDevMode  = NULL;
static DEVMODE *        pDevMode2 = NULL;
static DEVNAMES *       pDevNames = NULL;
static HANDLE           hPrinter  = NULL;
static PRINTER_INFO_2 * pi2       = NULL;
static PRINTER_INFO_2 * pi22      = NULL; // to restore printer dev mode after print.
static PRINTER_DEFAULTS pd;
static PRINTDLG         pdlg;
static DOCINFO          di;
static int              nFromPage = 0;
static int              nToPage   = 0;
static char             PrinterName[ 128 ];
static char             PrinterDefault[ 128 ];
static DWORD            charset = DEFAULT_CHARSET;
static HFONT            hfont;
static HPEN             hpen;
static HBRUSH           hbrush;
static int              textjust  = 0;
static int              devcaps[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 };
static int              preview      = 0;
static int              polyfillmode = 1;
static HRGN             hrgn         = NULL;
static HBITMAP          himgbmp;
static HBITMAP          hbmp[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
static OSVERSIONINFO    osvi;

void   rr_getdevmode( void );

static far int  nFontIndex = 0;
static far BOOL bGetName   = FALSE;

// EnumFonts call back routine
static int CALLBACK EnumFontsCallBack( LOGFONT FAR * lpLogFont,
                                       TEXTMETRIC FAR * lpTextMetric, int nFontType, LPARAM lParam )
{
   HB_SYMBOL_UNUSED( lpTextMetric );
   HB_SYMBOL_UNUSED( nFontType );
   HB_SYMBOL_UNUSED( lParam );

   ++nFontIndex;
   if( bGetName )
      HB_STORC( lpLogFont->lfFaceName, -1, nFontIndex );
   return 1;
}

// GetFontNames: Count and return an unsorted array of font names
HB_FUNC( RR_GETFONTNAMES )
{
   HDC hDC = GetDC( NULL );
   FONTENUMPROC lpEnumFontsCallBack = ( FONTENUMPROC )
                                      MakeProcInstance( ( FARPROC ) EnumFontsCallBack, GetModuleHandle( 0 ) );

   // Get the number of fonts
   nFontIndex = 0;
   bGetName   = FALSE;
   EnumFonts( hDC, NULL, lpEnumFontsCallBack, ( LPARAM ) NULL );

   // Get the font names
   hb_reta( nFontIndex );
   nFontIndex = 0;
   bGetName   = TRUE;
   EnumFonts( hDC, NULL, lpEnumFontsCallBack, ( LPARAM ) NULL );
   ReleaseDC( NULL, hDC );
}

HB_FUNC( RR_FINISH )
{
   pDevMode  = NULL;
   pDevMode2 = NULL;
   pDevNames = NULL;
   ClosePrinter( hPrinter );
   hPrinter = NULL;
   pi2      = NULL;
   memset( &pd, 0, sizeof( pd ) );
   memset( &pdlg, 0, sizeof( pdlg ) );
   memset( &di, 0, sizeof( di ) );
   nFromPage = 0;
   nToPage   = 0;
   hfont     = NULL;
   hpen      = NULL;
   hbrush    = NULL;
   textjust  = 0;
   memset( &devcaps, 0, sizeof( devcaps ) );
   devcaps[ 15 ] = 1;
   preview       = 0;
   polyfillmode  = 1;
   hrgn    = NULL;
   himgbmp = NULL;
   memset( &hbmp, 0, sizeof( hbmp ) );
}

HB_FUNC( RR_PRINTERNAME )
{
   hb_retc( PrinterName );
}

HB_FUNC( RR_PRINTDIALOG )
{
   LPCTSTR pDevice;

   memset( &pdlg, 0, sizeof( pdlg ) );
   pdlg.lStructSize = sizeof( pdlg );
   pdlg.hDevMode    = ( HANDLE ) NULL;
   pdlg.hDevNames   = ( HANDLE ) NULL;
   pdlg.Flags       = PD_RETURNDC | PD_ALLPAGES;
   pdlg.hwndOwner   = GetActiveWindow(); // Identifies the window that owns the dialog box.
   pdlg.hDC         = NULL;
   pdlg.nCopies     = 1;
   pdlg.nFromPage   = 1;
   pdlg.nToPage     = -1;
   pdlg.nMinPage    = 1;
   pdlg.nMaxPage    = 0xFFFF;

   if( PrintDlg( &pdlg ) )
   {
      hDC = pdlg.hDC;

      if( hDC == NULL )
      {
         strcpy( PrinterName, "" );
      }
      else
      {
         pDevMode  = ( LPDEVMODE ) GlobalLock( pdlg.hDevMode );
         pDevNames = ( LPDEVNAMES ) GlobalLock( pdlg.hDevNames );

         // Note: pDevMode->dmDeviceName is limited to 32 characters.
         // if the printer name is greater than 32, like network printers,
         // the rr_getdc() function return a null handle. So, I'm using
         // pDevNames instead pDevMode. (E.F.)
         //strcpy(PrinterName,pDevMode->dmDeviceName);

         pDevice = ( LPCTSTR ) pDevNames + pDevNames->wDeviceOffset;
         strcpy( PrinterName, ( char * ) pDevice );

         HB_STORNI( pdlg.nFromPage, 1, 1 );
         HB_STORNI( pdlg.nToPage, 1, 2 );
         HB_STORNI( pDevMode->dmCopies > 1 ? pDevMode->dmCopies : pdlg.nCopies, 1, 3 );
         if( ( pdlg.Flags & PD_PAGENUMS ) == PD_PAGENUMS )
            HB_STORNI( 2, 1, 4 );
         else if( ( pdlg.Flags & PD_SELECTION ) == PD_SELECTION )
            HB_STORNI( 1, 1, 4 );
         else
            HB_STORNI( 0, 1, 4 );

         rr_getdevmode();

         GlobalUnlock( pdlg.hDevMode );
         GlobalUnlock( pdlg.hDevNames );
      }
   }
   else
      hDC = 0;

   hDCRef = hDC;

   HB_RETNL( ( LONG_PTR ) hDC );
}

HB_FUNC( RR_GETDC )
{
   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      hDC = CreateDC( "WINSPOOL", hb_parc( 1 ), NULL, NULL );
   else
      hDC = CreateDC( NULL, hb_parc( 1 ), NULL, NULL );

   if( hDC )
   {
      strcpy( PrinterName, hb_parc( 1 ) );
      rr_getdevmode();
   }

   hDCRef = hDC;
   HB_RETNL( ( LONG_PTR ) hDC );
}

void rr_getdevmode()
{
   DWORD dwNeeded = 0;

   memset( &pd, 0, sizeof( pd ) );
   pd.DesiredAccess = PRINTER_ALL_ACCESS;
   OpenPrinter( PrinterName, &hPrinter, NULL );
   GetPrinter( hPrinter, 2, 0, 0, &dwNeeded );
   pi2 = ( PRINTER_INFO_2 * ) GlobalAlloc( GPTR, dwNeeded );
   GetPrinter( hPrinter, 2, ( LPBYTE ) pi2, dwNeeded, &dwNeeded );
   pi22 = ( PRINTER_INFO_2 * ) GlobalAlloc( GPTR, dwNeeded );
   GetPrinter( hPrinter, 2, ( LPBYTE ) pi22, dwNeeded, &dwNeeded );
   if( pDevMode )
      pi2->pDevMode = pDevMode;
   else if( pi2->pDevMode == NULL )
   {
      dwNeeded  = DocumentProperties( NULL, hPrinter, PrinterName, NULL, NULL, 0 );
      pDevMode2 = ( DEVMODE * ) GlobalAlloc( GPTR, dwNeeded );
      DocumentProperties( NULL, hPrinter, PrinterName, pDevMode2, NULL, DM_OUT_BUFFER );
      pi2->pDevMode = pDevMode2;
   }

   hfont  = ( HFONT ) GetCurrentObject( hDC, OBJ_FONT );
   hbrush = ( HBRUSH ) GetCurrentObject( hDC, OBJ_BRUSH );
   hpen   = ( HPEN ) GetCurrentObject( hDC, OBJ_PEN );
}

HB_FUNC( EF_RESETPRINTER )
{
   if( pi22 )
      SetPrinter( hPrinter, 2, ( LPBYTE ) pi22, 0 );

   GlobalFree( pi22 );
   pi22 = NULL;
}

HB_FUNC( RR_DELETEDC )
{
   if( pDevMode )
      GlobalFree( pDevMode );

   if( pDevMode2 )
      GlobalFree( pDevMode2 );

   if( pDevNames )
      GlobalFree( pDevNames );

   if( pi2 )
      GlobalFree( pi2 );

   DeleteDC( ( HDC ) HB_PARNL( 1 ) );
}

HB_FUNC( RR_GETDEVICECAPS )
{
   TEXTMETRIC tm;
   UINT       i;
   HFONT      xfont = ( HFONT ) HB_PARNL( 2 );

   if( xfont != 0 )
      SelectObject( hDCRef, xfont );

   GetTextMetrics( hDCRef, &tm );
   devcaps[ 1 ]  = GetDeviceCaps( hDCRef, VERTSIZE );
   devcaps[ 2 ]  = GetDeviceCaps( hDCRef, HORZSIZE );
   devcaps[ 3 ]  = GetDeviceCaps( hDCRef, VERTRES );
   devcaps[ 4 ]  = GetDeviceCaps( hDCRef, HORZRES );
   devcaps[ 5 ]  = GetDeviceCaps( hDCRef, LOGPIXELSY );
   devcaps[ 6 ]  = GetDeviceCaps( hDCRef, LOGPIXELSX );
   devcaps[ 7 ]  = GetDeviceCaps( hDCRef, PHYSICALHEIGHT );
   devcaps[ 8 ]  = GetDeviceCaps( hDCRef, PHYSICALWIDTH );
   devcaps[ 9 ]  = GetDeviceCaps( hDCRef, PHYSICALOFFSETY );
   devcaps[ 10 ] = GetDeviceCaps( hDCRef, PHYSICALOFFSETX );

   devcaps[ 11 ] = tm.tmHeight;
   devcaps[ 12 ] = tm.tmAveCharWidth;
   devcaps[ 13 ] = ( int ) ( ( devcaps[ 3 ] - tm.tmAscent ) / tm.tmHeight );
   devcaps[ 14 ] = ( int ) ( devcaps[ 4 ] / tm.tmAveCharWidth );
   devcaps[ 15 ] = ( int ) pi2->pDevMode->dmOrientation;
   devcaps[ 16 ] = ( int ) tm.tmAscent;
   devcaps[ 17 ] = ( int ) pi2->pDevMode->dmPaperSize;
   for( i = 1; i <= hb_parinfa( 1, 0 ); i++ )
      HB_STORNI( devcaps[ i ], 1, i );

   if( xfont != 0 )
      SelectObject( hDCRef, hfont );
}

HB_FUNC( RR_SETDEVMODE )
{
   DWORD what = hb_parnl( 1 );

   if( what == ( pi2->pDevMode->dmFields & what ) )
   {
      pi2->pDevMode->dmFields = pi2->pDevMode->dmFields | what;

      if( what == DM_ORIENTATION )
         pi2->pDevMode->dmOrientation = ( short ) hb_parni( 2 );

      if( what == DM_PAPERSIZE )
         pi2->pDevMode->dmPaperSize = ( short ) hb_parni( 2 );

      if( what == DM_SCALE )
         pi2->pDevMode->dmScale = ( short ) hb_parni( 2 );

      if( what == DM_COPIES )
         pi2->pDevMode->dmCopies = ( short ) hb_parni( 2 );

      if( what == DM_DEFAULTSOURCE )
         pi2->pDevMode->dmDefaultSource = ( short ) hb_parni( 2 );

      if( what == DM_PRINTQUALITY )
         pi2->pDevMode->dmPrintQuality = ( short ) hb_parni( 2 );

      if( what == DM_COLOR )
         pi2->pDevMode->dmColor = ( short ) hb_parni( 2 );

      if( what == DM_DUPLEX )
         pi2->pDevMode->dmDuplex = ( short ) hb_parni( 2 );
   }

   DocumentProperties( NULL, hPrinter, PrinterName, pi2->pDevMode, pi2->pDevMode, DM_IN_BUFFER | DM_OUT_BUFFER );
   SetPrinter( hPrinter, 2, ( LPBYTE ) pi2, 0 );
   ResetDC( hDCRef, pi2->pDevMode );
   HB_RETNL( ( LONG_PTR ) hDCRef );
}

HB_FUNC( RR_SETUSERMODE )
{
   DWORD what = hb_parnl( 1 );

   if( what == ( pi2->pDevMode->dmFields & what ) )
   {
      pi2->pDevMode->dmFields      = pi2->pDevMode->dmFields | DM_PAPERSIZE | DM_PAPERWIDTH | DM_PAPERLENGTH;
      pi2->pDevMode->dmPaperSize   = DMPAPER_USER;
      pi2->pDevMode->dmPaperWidth  = ( short ) hb_parnl( 2 );
      pi2->pDevMode->dmPaperLength = ( short ) hb_parnl( 3 );
   }

   DocumentProperties( NULL, hPrinter, PrinterName, pi2->pDevMode, pi2->pDevMode, DM_IN_BUFFER | DM_OUT_BUFFER );
   SetPrinter( hPrinter, 2, ( LPBYTE ) pi2, 0 );
   ResetDC( hDCRef, pi2->pDevMode );
   HB_RETNL( ( LONG_PTR ) hDCRef );
}

#ifdef UNICODE
typedef BOOL ( WINAPI * _GETDEFAULTPRINTER )( LPWSTR, LPDWORD );
  #define GETDEFAULTPRINTER  "GetDefaultPrinterW"
#else
typedef BOOL ( WINAPI * _GETDEFAULTPRINTER )( LPSTR, LPDWORD );
  #define GETDEFAULTPRINTER  "GetDefaultPrinterA"
#endif
#define MAX_BUFFER_SIZE      254
HB_FUNC( RR_GETDEFAULTPRINTER )
{
   DWORD Needed, Returned;
   DWORD BuffSize = MAX_BUFFER_SIZE;
   LPPRINTER_INFO_5 PrinterInfo;

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS ) /* Windows 95 or 98 */
   {
      EnumPrinters( PRINTER_ENUM_DEFAULT, NULL, 5, NULL, 0, &Needed, &Returned );
      PrinterInfo = ( LPPRINTER_INFO_5 ) LocalAlloc( LPTR, Needed );
      EnumPrinters( PRINTER_ENUM_DEFAULT, NULL, 5, ( LPBYTE ) PrinterInfo, Needed, &Needed, &Returned );
      strcpy( PrinterDefault, PrinterInfo->pPrinterName );
      LocalFree( PrinterInfo );
   }
   else if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {
      if( osvi.dwMajorVersion == 5 ) /* Windows 2000 or XP */
      {
         BOOL  bFlag;
         TCHAR lpPrinterName[ MAX_BUFFER_SIZE ];
         _GETDEFAULTPRINTER fnGetDefaultPrinter;

         HMODULE hWinSpool = LoadLibrary( "winspool.drv" );
         if( ! hWinSpool )
         {
            hb_retc( "" );
            return;
         }
         fnGetDefaultPrinter = ( _GETDEFAULTPRINTER ) GetProcAddress( hWinSpool, GETDEFAULTPRINTER );
         if( ! fnGetDefaultPrinter )
         {
            FreeLibrary( hWinSpool );
            hb_retc( "" );
            return;
         }

         bFlag = ( *fnGetDefaultPrinter )( lpPrinterName, &BuffSize );
         strcpy( PrinterDefault, lpPrinterName );
         FreeLibrary( hWinSpool );
         if( ! bFlag )
         {
            hb_retc( "" );
            return;
         }
      }
      else  /* Windows NT 4.0 or earlier */
      {
         GetProfileString( "windows", "device", "", PrinterDefault, BuffSize );
         strtok( PrinterDefault, "," );
      }
   }

   hb_retc( PrinterDefault );
}
#undef MAX_BUFFER_SIZE
#undef GETDEFAULTPRINTER

HB_FUNC( RR_GETPRINTERS )
{
   DWORD   dwSize     = 0;
   DWORD   dwPrinters = 0;
   DWORD   i;
   HGLOBAL pBuffer;
   HGLOBAL cBuffer;
   PRINTER_INFO_4 * pInfo4 = NULL;
   PRINTER_INFO_5 * pInfo5 = NULL;
   DWORD level;
   DWORD flags;

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
   GetVersionEx( &osvi );
   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {
      level = 4;
      flags = PRINTER_ENUM_CONNECTIONS | PRINTER_ENUM_LOCAL;
   }
   else
   {
      level = 5;
      flags = PRINTER_ENUM_LOCAL;
   }

   EnumPrinters( flags, NULL, level, NULL, 0, &dwSize, &dwPrinters );

   pBuffer = ( char * ) GlobalAlloc( GPTR, dwSize );
   if( pBuffer == NULL )
   {
      hb_retc( ",," );
      return;
   }

   EnumPrinters( flags, NULL, level, ( LPBYTE ) pBuffer, dwSize, &dwSize, &dwPrinters );

   if( dwPrinters == 0 )
   {
      hb_retc( ",," );
      GlobalFree( pBuffer );
      return;
   }

   cBuffer = ( char * ) GlobalAlloc( GPTR, dwPrinters * 256 );

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      pInfo4 = ( PRINTER_INFO_4 * ) pBuffer;
   else
      pInfo5 = ( PRINTER_INFO_5 * ) pBuffer;

   for( i = 0; i < dwPrinters; i++ )
   {
      if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      {
         strcat( ( char * ) cBuffer, pInfo4->pPrinterName );
         strcat( ( char * ) cBuffer, "," );
         if( pInfo4->Attributes == PRINTER_ATTRIBUTE_LOCAL )
            strcat( ( char * ) cBuffer, "local printer" );
         else
            strcat( ( char * ) cBuffer, "network printer" );

         pInfo4++;
      }
      else
      {
         strcat( ( char * ) cBuffer, pInfo5->pPrinterName );
         strcat( ( char * ) cBuffer, "," );
         strcat( ( char * ) cBuffer, pInfo5->pPortName );
         pInfo5++;
      }

      if( i < dwPrinters - 1 )
         strcat( ( char * ) cBuffer, ",," );
   }

   hb_retc( ( const char * ) cBuffer );
   GlobalFree( pBuffer );
   GlobalFree( cBuffer );
}

HB_FUNC( RR_STARTDOC )
{
   memset( &di, 0, sizeof( di ) );
   di.cbSize      = sizeof( di );
   di.lpszDocName = hb_parc( 1 );
   StartDoc( hDC, &di );
}

HB_FUNC( RR_STARTPAGE )
{
   StartPage( hDC );
   SetTextAlign( hDC, TA_BASELINE );
}

HB_FUNC( RR_ENDPAGE )
{
   EndPage( hDC );
}

HB_FUNC( RR_ENDDOC )
{
   EndDoc( hDC );
}

HB_FUNC( RR_ABORTDOC )
{
   AbortDoc( hDC );
   DeleteDC( hDC );
}

HB_FUNC( RR_DEVICECAPABILITIES )
{
   HGLOBAL cGBuffer, pGBuffer, nGBuffer, sGBuffer, bnGBuffer, bwGBuffer, bcGBuffer;
   char *  cBuffer, * pBuffer, * nBuffer, * sBuffer, * bnBuffer, * bwBuffer, * bcBuffer;
   DWORD   numpapers, numbins, i;
   LPPOINT lp;
   char    buffer[ sizeof( long ) * 8 + 1 ];

   numpapers = DeviceCapabilities( pi2->pPrinterName, pi2->pPortName, DC_PAPERNAMES, NULL, NULL );
   if( numpapers > 0 )
   {
      pGBuffer = GlobalAlloc( GPTR, numpapers * 64 );
      nGBuffer = GlobalAlloc( GPTR, numpapers * sizeof( WORD ) );
      sGBuffer = GlobalAlloc( GPTR, numpapers * sizeof( POINT ) );
      cGBuffer = GlobalAlloc( GPTR, numpapers * 128 );
      pBuffer  = ( char * ) pGBuffer;
      nBuffer  = ( char * ) nGBuffer;
      sBuffer  = ( char * ) sGBuffer;
      cBuffer  = ( char * ) cGBuffer;
      DeviceCapabilities( pi2->pPrinterName, pi2->pPortName, DC_PAPERNAMES, pBuffer, pi2->pDevMode );
      DeviceCapabilities( pi2->pPrinterName, pi2->pPortName, DC_PAPERS, nBuffer, pi2->pDevMode );
      DeviceCapabilities( pi2->pPrinterName, pi2->pPortName, DC_PAPERSIZE, sBuffer, pi2->pDevMode );
      cBuffer[ 0 ] = 0;
      for( i = 0; i < numpapers; i++ )
      {
         strcat( cBuffer, pBuffer );
         strcat( cBuffer, "," );
         strcat( cBuffer, itoa( *nBuffer, buffer, 10 ) );
         strcat( cBuffer, "," );

         lp = ( LPPOINT ) sBuffer;
         strcat( cBuffer, ltoa( lp->x, buffer, 10 ) );
         strcat( cBuffer, "," );
         strcat( cBuffer, ltoa( lp->y, buffer, 10 ) );
         if( i < numpapers - 1 )
            strcat( cBuffer, ",," );
         pBuffer += 64;
         nBuffer += sizeof( WORD );
         sBuffer += sizeof( POINT );
      }

      hb_storc( cBuffer, 1 );

      GlobalFree( cGBuffer );
      GlobalFree( pGBuffer );
      GlobalFree( nGBuffer );
      GlobalFree( sGBuffer );
   }
   else
      hb_storc( "", 1 );

   numbins = DeviceCapabilities( pi2->pPrinterName, pi2->pPortName, DC_BINNAMES, NULL, NULL );
   if( numbins > 0 )
   {
      bnGBuffer = GlobalAlloc( GPTR, numbins * 24 );
      bwGBuffer = GlobalAlloc( GPTR, numbins * sizeof( WORD ) );
      bcGBuffer = GlobalAlloc( GPTR, numbins * 64 );
      bnBuffer  = ( char * ) bnGBuffer;
      bwBuffer  = ( char * ) bwGBuffer;
      bcBuffer  = ( char * ) bcGBuffer;
      DeviceCapabilities( pi2->pPrinterName, pi2->pPortName, DC_BINNAMES, bnBuffer, pi2->pDevMode );
      DeviceCapabilities( pi2->pPrinterName, pi2->pPortName, DC_BINS, bwBuffer, pi2->pDevMode );
      bcBuffer[ 0 ] = 0;
      for( i = 0; i < numbins; i++ )
      {
         strcat( bcBuffer, bnBuffer );
         strcat( bcBuffer, "," );
         strcat( bcBuffer, itoa( *bwBuffer, buffer, 10 ) );

         if( i < numbins - 1 )
            strcat( bcBuffer, ",," );
         bnBuffer += 24;
         bwBuffer += sizeof( WORD );
      }

      hb_storc( bcBuffer, 2 );

      GlobalFree( bnGBuffer );
      GlobalFree( bwGBuffer );
      GlobalFree( bcGBuffer );
   }
   else
      hb_storc( "", 2 );
}

HB_FUNC( RR_SETPOLYFILLMODE )
{
   if( SetPolyFillMode( hDC, ( COLORREF ) hb_parnl( 1 ) ) != 0 )
      hb_retnl( hb_parnl( 1 ) );
   else
      hb_retnl( ( LONG ) GetPolyFillMode( hDC ) );
}

HB_FUNC( RR_SETTEXTCOLOR )
{
   if( SetTextColor( hDC, ( COLORREF ) hb_parnl( 1 ) ) != CLR_INVALID )
      hb_retnl( hb_parnl( 1 ) );
   else
      hb_retnl( ( LONG ) GetTextColor( hDC ) );
}

HB_FUNC( RR_SETBKCOLOR )
{
   if( SetBkColor( hDC, ( COLORREF ) hb_parnl( 1 ) ) != CLR_INVALID )
      hb_retnl( hb_parnl( 1 ) );
   else
      hb_retnl( ( LONG ) GetBkColor( hDC ) );
}

HB_FUNC( RR_SETBKMODE )
{
   if( hb_parni( 1 ) == 1 )
      SetBkMode( hDC, TRANSPARENT );
   else
      SetBkMode( hDC, OPAQUE );
}

HB_FUNC( RR_DELETEOBJECTS )
{
   UINT i;

   for( i = 2; i <= hb_parinfa( 1, 0 ); i++ )
      DeleteObject( ( HGDIOBJ ) HB_PARVNL( 1, i ) );
}

HB_FUNC( RR_DELETEIMAGELISTS )
{
   UINT i;

   for( i = 1; i <= hb_parinfa( 1, 0 ); i++ )
      ImageList_Destroy( ( HIMAGELIST ) HB_PARNL3( 1, i, 1 ) );
}

HB_FUNC( RR_SAVEMETAFILE )
{
   CopyEnhMetaFile( ( HENHMETAFILE ) HB_PARNL( 1 ), hb_parc( 2 ) );
}

HB_FUNC( RR_GETCURRENTOBJECT )
{
   int     what = hb_parni( 1 );
   HGDIOBJ hand;

   if( what == 1 )
      hand = GetCurrentObject( hDC, OBJ_FONT );
   else if( what == 2 )
      hand = GetCurrentObject( hDC, OBJ_BRUSH );
   else
      hand = GetCurrentObject( hDC, OBJ_PEN );

   HB_RETNL( ( LONG_PTR ) hand );
}

HB_FUNC( RR_GETSTOCKOBJECT )
{
   HB_RETNL( ( LONG_PTR ) GetStockObject( hb_parni( 1 ) ) );
}

HB_FUNC( RR_CREATEPEN )
{
   HB_RETNL( ( LONG_PTR ) CreatePen( hb_parni( 1 ), hb_parni( 2 ), ( COLORREF ) hb_parnl( 3 ) ) );
}

HB_FUNC( RR_MODIFYPEN )
{
   LOGPEN ppn;
   int    i;
   HPEN   hp;

   memset( &ppn, 0, sizeof( LOGPEN ) );
   i = GetObject( ( HPEN ) HB_PARNL( 1 ), sizeof( LOGPEN ), &ppn );
   if( i > 0 )
   {
      if( hb_parni( 2 ) >= 0 )
         ppn.lopnStyle = ( UINT ) hb_parni( 2 );

      if( hb_parnl( 3 ) >= 0 )
         ppn.lopnWidth.x = hb_parnl( 3 );

      if( hb_parnl( 4 ) >= 0 )
         ppn.lopnColor = ( COLORREF ) hb_parnl( 4 );

      hp = CreatePenIndirect( &ppn );
      if( hp != NULL )
      {
         DeleteObject( ( HPEN ) HB_PARNL( 1 ) );
         HB_RETNL( ( LONG_PTR ) hp );
      }
      else
         hb_retnl( ( LONG ) hb_parnl( 1 ) );
   }
   else
      hb_retnl( ( LONG ) hb_parnl( 1 ) );
}

HB_FUNC( RR_SELECTPEN )
{
   SelectObject( hDC, ( HPEN ) HB_PARNL( 1 ) );
   hpen = ( HPEN ) HB_PARNL( 1 );
}

HB_FUNC( RR_CREATEBRUSH )
{
   LOGBRUSH pbr;

   pbr.lbStyle = hb_parni( 1 );
   pbr.lbColor = ( COLORREF ) hb_parnl( 2 );
   pbr.lbHatch = ( LONG ) hb_parnl( 3 );
   HB_RETNL( ( LONG_PTR ) CreateBrushIndirect( &pbr ) );
}

HB_FUNC( RR_MODIFYBRUSH )
{
   LOGBRUSH ppn;
   int      i;
   HBRUSH   hb;

   memset( &ppn, 0, sizeof( LOGBRUSH ) );
   i = GetObject( ( HBRUSH ) HB_PARNL( 1 ), sizeof( LOGBRUSH ), &ppn );
   if( i > 0 )
   {
      if( hb_parni( 2 ) >= 0 )
         ppn.lbStyle = ( UINT ) hb_parni( 2 );

      if( hb_parnl( 3 ) >= 0 )
         ppn.lbColor = ( COLORREF ) hb_parnl( 3 );

      if( hb_parnl( 4 ) >= 0 )
         ppn.lbHatch = hb_parnl( 4 );

      hb = CreateBrushIndirect( &ppn );
      if( hb != NULL )
      {
         DeleteObject( ( HBRUSH ) HB_PARNL( 1 ) );
         HB_RETNL( ( LONG_PTR ) hb );
      }
      else
         hb_retnl( ( LONG ) hb_parnl( 1 ) );
   }
   else
      hb_retnl( ( LONG ) hb_parnl( 1 ) );
}

HB_FUNC( RR_SELECTBRUSH )
{
   SelectObject( hDC, ( HBRUSH ) HB_PARNL( 1 ) );
   hbrush = ( HBRUSH ) HB_PARNL( 1 );
}

HB_FUNC( RR_CREATEFONT )
{
   const char * FontName  = hb_parc( 1 );
   int          FontSize  = hb_parni( 2 );
   LONG         FontWidth = hb_parnl( 3 );
   LONG         Orient    = hb_parnl( 4 );
   LONG         Weight    = hb_parnl( 5 );
   int          Italic    = hb_parni( 6 );
   int          Underline = hb_parni( 7 );
   int          Strikeout = hb_parni( 8 );
   HFONT        oldfont, hxfont;
   LONG         newWidth, FontHeight;
   TEXTMETRIC   tm;
   BYTE         bItalic, bUnderline, bStrikeOut;

   newWidth = ( LONG ) FontWidth;
   if( FontSize <= 0 )
      FontSize = 10;

   if( FontWidth < 0 )
      newWidth = 0;

   if( Orient <= 0 )
      Orient = 0;

   if( Weight <= 0 )
      Weight = FW_NORMAL;
   else
      Weight = FW_BOLD;

   if( Italic <= 0 )
      bItalic = 0;
   else
      bItalic = 1;

   if( Underline <= 0 )
      bUnderline = 0;
   else
      bUnderline = 1;

   if( Strikeout <= 0 )
      bStrikeOut = 0;
   else
      bStrikeOut = 1;

   FontHeight = -MulDiv( FontSize, GetDeviceCaps( hDCRef, LOGPIXELSY ), 72 );
   hxfont     = CreateFont
                (
      FontHeight,
      newWidth,
      Orient,
      Orient,
      Weight,
      bItalic,
      bUnderline,
      bStrikeOut,
      charset,
      OUT_TT_PRECIS,
      CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,
      FF_DONTCARE,
      FontName
                );
   if( FontWidth < 0 )
   {
      oldfont = ( HFONT ) SelectObject( hDC, hxfont );
      GetTextMetrics( hDC, &tm );
      SelectObject( hDC, oldfont );
      DeleteObject( hxfont );
      newWidth = ( int ) ( ( float ) -( tm.tmAveCharWidth + tm.tmOverhang ) * FontWidth / 100 );
      hxfont   = CreateFont
                 (
         FontHeight,
         newWidth,
         Orient,
         Orient,
         Weight,
         bItalic,
         bUnderline,
         bStrikeOut,
         charset,
         OUT_TT_PRECIS,
         CLIP_DEFAULT_PRECIS,
         DEFAULT_QUALITY,
         FF_DONTCARE,
         FontName
                 );
   }

   HB_RETNL( ( LONG_PTR ) hxfont );
}

HB_FUNC( RR_MODIFYFONT )
{
   LOGFONT ppn;
   int     i;
   HFONT   hf;
   LONG    nHeight;

   memset( &ppn, 0, sizeof( LOGFONT ) );
   i = GetObject( ( HFONT ) HB_PARNL( 1 ), sizeof( LOGFONT ), &ppn );
   if( i > 0 )
   {
      //     if (hb_parc(2)!="")
      //       ppn.lfFaceName = hb_parc(2);

      if( hb_parni( 3 ) > 0 )
      {
         nHeight      = -MulDiv( hb_parni( 3 ), GetDeviceCaps( hDC, LOGPIXELSY ), 72 );
         ppn.lfHeight = nHeight;
      }

      if( hb_parnl( 4 ) >= 0 )
         ppn.lfWidth = ( LONG ) hb_parnl( 4 ) * ppn.lfWidth / 100;

      if( hb_parnl( 5 ) >= 0 )
      {
         ppn.lfOrientation = hb_parnl( 5 );
         ppn.lfEscapement  = hb_parnl( 5 );
      }

      if( hb_parnl( 6 ) >= 0 )
      {
         if( hb_parnl( 6 ) == 0 )
            ppn.lfWeight = FW_NORMAL;
         else
            ppn.lfWeight = FW_BOLD;
      }

      if( hb_parni( 7 ) >= 0 )
         ppn.lfItalic = ( BYTE ) hb_parni( 7 );

      if( hb_parni( 8 ) >= 0 )
         ppn.lfUnderline = ( BYTE ) hb_parni( 8 );

      if( hb_parni( 9 ) >= 0 )
         ppn.lfStrikeOut = ( BYTE ) hb_parni( 9 );

      hf = CreateFontIndirect( &ppn );
      if( hf != NULL )
      {
         DeleteObject( ( HFONT ) HB_PARNL( 1 ) );
         HB_RETNL( ( LONG_PTR ) hf );
      }
      else
         hb_retnl( ( LONG ) hb_parnl( 1 ) );
   }
   else
      hb_retnl( ( LONG ) hb_parnl( 1 ) );
}

HB_FUNC( RR_SELECTFONT )
{
   SelectObject( hDC, ( HFONT ) HB_PARNL( 1 ) );
   hfont = ( HFONT ) HB_PARNL( 1 );
}

HB_FUNC( RR_SETCHARSET )
{
   charset = ( DWORD ) hb_parnl( 1 );
}

HB_FUNC( RR_TEXTOUT )
{
   HGDIOBJ xfont = ( HFONT ) HB_PARNL( 3 );
   HFONT prevfont = NULL;
   SIZE  szMetric;
   int   lspace = hb_parni( 4 );

   if( xfont != 0 )
      prevfont = ( HFONT ) SelectObject( hDC, xfont );

   if( textjust > 0 )
   {
      GetTextExtentPoint32( hDC, hb_parc( 1 ), hb_parclen( 1 ), &szMetric );
      if( szMetric.cx < textjust )      // or can be for better look (szMetric.cx>(int) textjust*2/3)
         if( lspace > 0 )
            SetTextJustification( hDC, ( int ) textjust - szMetric.cx, lspace );
   }

   hb_retl( TextOut( hDC, HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ) + devcaps[ 16 ], hb_parc( 1 ), hb_parclen( 1 ) ) );
   if( xfont != 0 )
      SelectObject( hDC, prevfont );

   if( textjust > 0 )
      SetTextJustification( hDC, 0, 0 );
}

HB_FUNC( RR_DRAWTEXT )
{
   HGDIOBJ xfont = ( HFONT ) HB_PARNL( 5 );
   HFONT prevfont = NULL;
   RECT  rect;
   UINT  uFormat;

   SIZE sSize;
   const char * pszData = hb_parc( 3 );
   int          iLen    = strlen( pszData );
   int          iStyle  = hb_parni( 4 );
   LONG         w, h;

   SetRect( &rect, HB_PARVNL( 1, 2 ), HB_PARVNL( 1, 1 ), HB_PARVNL( 2, 2 ), HB_PARVNL( 2, 1 ) );

   if( xfont != 0 )
      prevfont = ( HFONT ) SelectObject( hDC, xfont );

   GetTextExtentPoint32( hDC, pszData, iLen, &sSize );
   w = ( LONG ) sSize.cx;  // text width
   h = ( LONG ) sSize.cy;  // text height

   // Center text vertically within rectangle
   if( w < rect.right - rect.left )
      rect.top = rect.top + ( rect.bottom - rect.top + h / 2 ) / 2;
   else
      rect.top = rect.top + ( rect.bottom - rect.top - h / 2 ) / 2;

   uFormat = DT_NOCLIP | DT_NOPREFIX | DT_WORDBREAK | DT_END_ELLIPSIS;

   if( iStyle == 0 )
      uFormat = uFormat | DT_LEFT;
   else if( iStyle == 2 )
      uFormat = uFormat | DT_RIGHT;
   else if( iStyle == 1 )
      uFormat = uFormat | DT_CENTER;

   hb_retni( DrawText( hDC, pszData, -1, &rect, uFormat ) );
   if( xfont != 0 )
      SelectObject( hDC, prevfont );
}

HB_FUNC( RR_RECTANGLE )
{
   LONG_PTR xpen   = HB_PARNL( 3 );
   LONG_PTR xbrush = HB_PARNL( 4 );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   if( xbrush != 0 )
      SelectObject( hDC, ( HBRUSH ) xbrush );

   hb_retni( Rectangle( hDC, HB_PARVNL( 1, 2 ), HB_PARVNL( 1, 1 ), HB_PARVNL( 2, 2 ), HB_PARVNL( 2, 1 ) ) );
   if( xpen != 0 )
      SelectObject( hDC, hpen );

   if( xbrush != 0 )
      SelectObject( hDC, hbrush );
}

HB_FUNC( RR_CLOSEMFILE )
{
   DeleteEnhMetaFile( CloseEnhMetaFile( hDC ) );
}

HB_FUNC( RR_CREATEMFILE )
{
   RECT emfrect;

   SetRect( &emfrect, 0, 0, GetDeviceCaps( hDCRef, HORZSIZE ) * 100, GetDeviceCaps( hDCRef, VERTSIZE ) * 100 );
   hDC = CreateEnhMetaFile( hDCRef, hb_parc( 1 ), &emfrect, "hbprinter\0emf file\0\0" );
   SetTextAlign( hDC, TA_BASELINE );
   preview = 1;
   HB_RETNL( ( LONG_PTR ) hDC );
}

HB_FUNC( RR_DELETECLIPRGN )
{
   SelectClipRgn( hDC, NULL );
}

HB_FUNC( RR_CREATERGN )
{
   POINT lpp;

   GetViewportOrgEx( hDC, &lpp );
   if( hb_parni( 3 ) == 2 )
      HB_RETNL( ( LONG_PTR ) CreateEllipticRgn( HB_PARNI( 1, 2 ) + lpp.x, HB_PARNI( 1, 1 ) + lpp.y, HB_PARNI( 2, 2 ) + lpp.x, HB_PARNI( 2, 1 ) + lpp.y ) );
   else if( hb_parni( 3 ) == 3 )
      HB_RETNL
      (
         ( LONG_PTR ) CreateRoundRectRgn
         (
            HB_PARNI( 1, 2 ) + lpp.x,
            HB_PARNI( 1, 1 ) + lpp.y,
            HB_PARNI( 2, 2 ) + lpp.x,
            HB_PARNI( 2, 1 ) + lpp.y,
            HB_PARNI( 4, 2 ) + lpp.x,
            HB_PARNI( 4, 1 ) + lpp.y
         )
      );
   else
      HB_RETNL( ( LONG_PTR ) CreateRectRgn( HB_PARNI( 1, 2 ) + lpp.x, HB_PARNI( 1, 1 ) + lpp.y, HB_PARNI( 2, 2 ) + lpp.x, HB_PARNI( 2, 1 ) + lpp.y ) );
}

HB_FUNC( RR_CREATEPOLYGONRGN )
{
   int   number = hb_parinfa( 1, 0 );
   int   i;
   POINT apoints[ 1024 ];

   for( i = 0; i <= number - 1; i++ )
   {
      apoints[ i ].x = HB_PARNI( 1, i + 1 );
      apoints[ i ].y = HB_PARNI( 2, i + 1 );
   }

   HB_RETNL( ( LONG_PTR ) CreatePolygonRgn( apoints, number, hb_parni( 3 ) ) );
}

HB_FUNC( RR_COMBINERGN )
{
   HRGN rgnnew = CreateRectRgn( 0, 0, 1, 1 );

   CombineRgn( rgnnew, ( HRGN ) HB_PARNL( 1 ), ( HRGN ) HB_PARNL( 2 ), hb_parni( 3 ) );
   HB_RETNL( ( LONG_PTR ) rgnnew );
}

HB_FUNC( RR_SELECTCLIPRGN )
{
   SelectClipRgn( hDC, ( HRGN ) HB_PARNL( 1 ) );
   hrgn = ( HRGN ) HB_PARNL( 1 );
}

HB_FUNC( RR_SETVIEWPORTORG )
{
   hb_retl( SetViewportOrgEx( hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), NULL ) );
}

HB_FUNC( RR_GETVIEWPORTORG )
{
   POINT lpp;

   hb_retl( GetViewportOrgEx( hDC, &lpp ) );
   HB_STORVNL( lpp.x, 1, 2 );
   HB_STORVNL( lpp.y, 1, 1 );
}

HB_FUNC( RR_SETRGB )
{
   hb_retnl( RGB( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

HB_FUNC( RR_SETTEXTCHAREXTRA )
{
   hb_retni( SetTextCharacterExtra( hDC, hb_parni( 1 ) ) );
}

HB_FUNC( RR_GETTEXTCHAREXTRA )
{
   hb_retni( GetTextCharacterExtra( hDC ) );
}

HB_FUNC( RR_SETTEXTJUSTIFICATION )
{
   textjust = hb_parni( 1 );
}

HB_FUNC( RR_GETTEXTJUSTIFICATION )
{
   hb_retni( textjust );
}

HB_FUNC( RR_GETTEXTALIGN )
{
   hb_retni( GetTextAlign( hDC ) );
}

HB_FUNC( RR_SETTEXTALIGN )
{
   hb_retni( SetTextAlign( hDC, TA_BASELINE | hb_parni( 1 ) ) );
}

HB_FUNC( RR_PICTURE )
{
   IStream *  iStream;
   IPicture * iPicture;
   HGLOBAL    hGlobal;
   void *     pGlobal;
   HANDLE     hFile;
   DWORD      nFileSize;
   DWORD      nReadByte;
   long       lWidth, lHeight;
   int        x, y, xe, ye;
   int        r   = HB_PARNI( 2, 1 );
   int        c   = HB_PARNI( 2, 2 );
   int        dr  = HB_PARNI( 3, 1 );
   int        dc  = HB_PARNI( 3, 2 );
   int        tor = HB_PARNI( 4, 1 );
   int        toc = HB_PARNI( 4, 2 );
   HRGN       hrgn1;
   POINT      lpp;

   hFile = CreateFile( hb_parc( 1 ), GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
   if( hFile == INVALID_HANDLE_VALUE )
      return;

   nFileSize = GetFileSize( hFile, NULL );
   hGlobal   = GlobalAlloc( GMEM_MOVEABLE, nFileSize );
   pGlobal   = GlobalLock( hGlobal );
   ReadFile( hFile, pGlobal, nFileSize, &nReadByte, NULL );
   CloseHandle( hFile );
   GlobalUnlock( hGlobal );
   CreateStreamOnHGlobal( hGlobal, TRUE, &iStream );
   OleLoadPicture( iStream, nFileSize, TRUE, &IID_IPicture, ( LPVOID * ) &iPicture );
   GlobalFree( hGlobal );
   iStream->lpVtbl->Release( iStream );
   if( iPicture == NULL )
      return;

   iPicture->lpVtbl->get_Width( iPicture, &lWidth );
   iPicture->lpVtbl->get_Height( iPicture, &lHeight );
   if( dc == 0 )
      dc = ( int ) ( ( float ) dr * lWidth / lHeight );

   if( dr == 0 )
      dr = ( int ) ( ( float ) dc * lHeight / lWidth );

   if( tor <= 0 )
      tor = dr;

   if( toc <= 0 )
      toc = dc;

   x  = c;
   y  = r;
   xe = c + toc - 1;
   ye = r + tor - 1;
   GetViewportOrgEx( hDC, &lpp );
   hrgn1 = CreateRectRgn( c + lpp.x, r + lpp.y, xe + lpp.x, ye + lpp.y );
   if( hrgn == NULL )
      SelectClipRgn( hDC, hrgn1 );
   else
      ExtSelectClipRgn( hDC, hrgn1, RGN_AND );

   while( x < xe )
   {
      while( y < ye )
      {
         iPicture->lpVtbl->Render( iPicture, hDC, x, y, dc, dr, 0, lHeight, lWidth, -lHeight, NULL );
         y += dr;
      }

      y  = r;
      x += dc;
   }

   iPicture->lpVtbl->Release( iPicture );
   SelectClipRgn( hDC, hrgn );
   DeleteObject( hrgn1 );
   hb_retni( 0 );
}

LPVOID rr_loadpicturefromresource( char * resname, LONG * lwidth, LONG * lheight )
{
   HBITMAP    hbmpx;
   IPicture * iPicture = NULL;
   IStream *  iStream  = NULL;
   PICTDESC   picd;
   HGLOBAL    hGlobalres;
   HGLOBAL    hGlobal;
   HRSRC      hSource;
   LPVOID     lpVoid;
   HINSTANCE  hinstance = GetModuleHandle( NULL );
   int        nSize;

   hbmpx = ( HBITMAP ) LoadImage( GetModuleHandle( NULL ), resname, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );
   if( hbmpx != NULL )
   {
      picd.cbSizeofstruct = sizeof( PICTDESC );
      picd.picType        = PICTYPE_BITMAP;
      picd.bmp.hbitmap    = hbmpx;
      OleCreatePictureIndirect( &picd, &IID_IPicture, TRUE, ( LPVOID * ) &iPicture );
   }
   else
   {
      hSource = FindResource( hinstance, resname, "HMGPICTURE" );
      if( hSource == NULL )
         return NULL;

      hGlobalres = LoadResource( hinstance, hSource );
      if( hGlobalres == NULL )
         return NULL;

      lpVoid = LockResource( hGlobalres );
      if( lpVoid == NULL )
         return NULL;

      nSize   = SizeofResource( hinstance, hSource );
      hGlobal = GlobalAlloc( GPTR, nSize );
      if( hGlobal == NULL )
         return NULL;

      memcpy( hGlobal, lpVoid, nSize );
      FreeResource( hGlobalres );
      CreateStreamOnHGlobal( hGlobal, TRUE, &iStream );
      if( iStream == NULL )
      {
         GlobalFree( hGlobal );
         return NULL;
      }

      OleLoadPicture( iStream, nSize, TRUE, &IID_IPicture, ( LPVOID * ) &iPicture );
      iStream->lpVtbl->Release( iStream );
      GlobalFree( hGlobal );
   }

   if( iPicture != NULL )
   {
      iPicture->lpVtbl->get_Width( iPicture, lwidth );
      iPicture->lpVtbl->get_Height( iPicture, lheight );
   }

   return iPicture;
}

LPVOID rr_loadpicture( char * filename, LONG * lwidth, LONG * lheight )
{
   IStream *  iStream  = NULL;
   IPicture * iPicture = NULL;
   HGLOBAL    hGlobal;
   void *     pGlobal;
   HANDLE     hFile;
   DWORD      nFileSize, nReadByte;

   hFile = CreateFile( filename, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
   if( hFile == INVALID_HANDLE_VALUE )
      return NULL;

   nFileSize = GetFileSize( hFile, NULL );
   hGlobal   = GlobalAlloc( GMEM_MOVEABLE, nFileSize + 4096 );
   pGlobal   = GlobalLock( hGlobal );
   ReadFile( hFile, pGlobal, nFileSize, &nReadByte, NULL );
   CloseHandle( hFile );
   CreateStreamOnHGlobal( hGlobal, TRUE, &iStream );
   if( iStream == NULL )
   {
      GlobalUnlock( hGlobal );
      GlobalFree( hGlobal );
      return NULL;
   }

   OleLoadPicture( iStream, nFileSize, TRUE, &IID_IPicture, ( LPVOID * ) &iPicture );
   GlobalUnlock( hGlobal );
   GlobalFree( hGlobal );
   iStream->lpVtbl->Release( iStream );
   iStream = NULL;
   if( iPicture != NULL )
   {
      iPicture->lpVtbl->get_Width( iPicture, lwidth );
      iPicture->lpVtbl->get_Height( iPicture, lheight );
   }

   return iPicture;
}

HB_FUNC( RR_DRAWPICTURE )
{
   IPicture * ipic;
   int        x, y, xe, ye;
   int        r       = HB_PARNI( 2, 1 );
   int        c       = HB_PARNI( 2, 2 );
   int        dr      = HB_PARNI( 3, 1 );
   int        dc      = HB_PARNI( 3, 2 );
   int        tor     = HB_PARNI( 4, 1 );
   int        toc     = HB_PARNI( 4, 2 );
   long       lwidth  = 0;
   long       lheight = 0;
   RECT       lrect;
   HRGN       hrgn1;
   POINT      lpp;
   int        lw, lh;

   ipic = ( IPicture * ) rr_loadpicture( ( char * ) hb_parc( 1 ), &lwidth, &lheight );
   if( ipic == NULL )
      ipic = ( IPicture * ) rr_loadpicturefromresource( ( char * ) hb_parc( 1 ), &lwidth, &lheight );

   if( ipic == NULL )
      return;

   lw = MulDiv( lwidth, devcaps[ 6 ], 2540 );
   lh = MulDiv( lheight, devcaps[ 5 ], 2540 );
   if( dc == 0 )
      dc = ( int ) ( ( float ) dr * lw / lh );

   if( dr == 0 )
      dr = ( int ) ( ( float ) dc * lh / lw );

   if( tor <= 0 )
      tor = dr;

   if( toc <= 0 )
      toc = dc;

   x  = c;
   y  = r;
   xe = c + toc - 1;
   ye = r + tor - 1;
   GetViewportOrgEx( hDC, &lpp );
   hrgn1 = CreateRectRgn( c + lpp.x, r + lpp.y, xe + lpp.x, ye + lpp.y );
   if( hrgn == NULL )
      SelectClipRgn( hDC, hrgn1 );
   else
      ExtSelectClipRgn( hDC, hrgn1, RGN_AND );

   while( x < xe )
   {
      while( y < ye )
      {
         SetRect( &lrect, x, y, dc + x, dr + y );
         ipic->lpVtbl->Render( ipic, hDC, x, y, dc, dr, 0, lheight, lwidth, -lheight, &lrect );
         y += dr;
      }

      y  = r;
      x += dc;
   }

   ipic->lpVtbl->Release( ipic );
   SelectClipRgn( hDC, hrgn );
   DeleteObject( hrgn1 );
   hb_retni( 0 );
}

HB_FUNC( RR_CREATEIMAGELIST )
{
   HBITMAP    hbmpx;
   BITMAP     bm;
   HIMAGELIST himl;
   int        dx, number;

   hbmpx = ( HBITMAP ) LoadImage( 0, hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_CREATEDIBSECTION );
   if( hbmpx == NULL )
      hbmpx = ( HBITMAP ) LoadImage( GetModuleHandle( NULL ), hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );

   if( hbmpx == NULL )
      return;

   GetObject( hbmpx, sizeof( BITMAP ), &bm );
   number = HB_ISNIL( 2 ) ? 0 : hb_parni( 2 );
   if( number == 0 )
   {
      number = ( int ) bm.bmWidth / bm.bmHeight;
      dx     = bm.bmHeight;
   }
   else
      dx = ( int ) bm.bmWidth / number;

   himl = ImageList_Create( dx, bm.bmHeight, ILC_COLOR24 | ILC_MASK, number, 0 );
   ImageList_AddMasked( himl, hbmpx, CLR_DEFAULT );
   hb_storni( dx, 3 );
   hb_storni( bm.bmHeight, 4 );
   DeleteObject( hbmpx );
   HB_RETNL( ( LONG_PTR ) himl );
}

HB_FUNC( RR_DRAWIMAGELIST )
{
   HIMAGELIST himl = ( HIMAGELIST ) HB_PARNL( 1 );
   HDC        tempdc, temp2dc;
   HBITMAP    hbmpx;
   RECT       rect;
   HWND       hwnd = GetActiveWindow();

   rect.left   = HB_PARNI( 3, 2 );
   rect.top    = HB_PARNI( 3, 1 );
   rect.right  = HB_PARNI( 4, 2 );
   rect.bottom = HB_PARNI( 4, 1 );
   temp2dc     = GetWindowDC( hwnd );
   tempdc      = CreateCompatibleDC( temp2dc );
   hbmpx       = CreateCompatibleBitmap( temp2dc, hb_parni( 5 ), hb_parni( 6 ) );
   ReleaseDC( hwnd, temp2dc );
   SelectObject( tempdc, hbmpx );
   BitBlt( tempdc, 0, 0, hb_parni( 5 ), hb_parni( 6 ), tempdc, 0, 0, WHITENESS );
   if( hb_parnl( 8 ) >= 0 )
      ImageList_SetBkColor( himl, ( COLORREF ) hb_parnl( 8 ) );

   ImageList_Draw( himl, hb_parni( 2 ) - 1, tempdc, 0, 0, hb_parni( 7 ) );
   if( hb_parnl( 8 ) >= 0 )
      ImageList_SetBkColor( himl, CLR_NONE );

   hb_retl( StretchBlt( hDC, rect.left, rect.top, rect.right, rect.bottom, tempdc, 0, 0, hb_parni( 5 ), hb_parni( 6 ), SRCCOPY ) );
   DeleteDC( tempdc );
   DeleteObject( hbmpx );
}

HB_FUNC( RR_POLYGON )
{
   int   number = hb_parinfa( 1, 0 );
   int   i;
   int   styl = GetPolyFillMode( hDC );
   POINT apoints[ 1024 ];
   LONG_PTR  xpen   = HB_PARNL( 3 );
   LONG_PTR  xbrush = HB_PARNL( 4 );

   for( i = 0; i <= number - 1; i++ )
   {
      apoints[ i ].x = HB_PARNI( 1, i + 1 );
      apoints[ i ].y = HB_PARNI( 2, i + 1 );
   }

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   if( xbrush != 0 )
      SelectObject( hDC, ( HBRUSH ) xbrush );

   SetPolyFillMode( hDC, hb_parni( 5 ) );

   hb_retnl( ( LONG ) Polygon( hDC, apoints, number ) );

   if( xpen != 0 )
      SelectObject( hDC, hpen );

   if( xbrush != 0 )
      SelectObject( hDC, hbrush );

   SetPolyFillMode( hDC, styl );
}

HB_FUNC( RR_POLYBEZIER )
{
   DWORD number = ( DWORD ) hb_parinfa( 1, 0 );
   DWORD i;
   POINT apoints[ 1024 ];
   LONG_PTR  xpen = HB_PARNL( 3 );

   for( i = 0; i <= number - 1; i++ )
   {
      apoints[ i ].x = HB_PARNI( 1, i + 1 );
      apoints[ i ].y = HB_PARNI( 2, i + 1 );
   }

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   hb_retnl( ( LONG ) PolyBezier( hDC, apoints, number ) );

   if( xpen != 0 )
      SelectObject( hDC, hpen );
}

HB_FUNC( RR_POLYBEZIERTO )
{
   DWORD number = ( DWORD ) hb_parinfa( 1, 0 );
   DWORD i;
   POINT apoints[ 1024 ];
   LONG_PTR  xpen = HB_PARNL( 3 );

   for( i = 0; i <= number - 1; i++ )
   {
      apoints[ i ].x = HB_PARNI( 1, i + 1 );
      apoints[ i ].y = HB_PARNI( 2, i + 1 );
   }

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   hb_retnl( ( LONG ) PolyBezierTo( hDC, apoints, number ) );

   if( xpen != 0 )
      SelectObject( hDC, hpen );
}

HB_FUNC( RR_GETTEXTEXTENT )
{
   LONG_PTR xfont = HB_PARNL( 3 );
   SIZE szMetric;

   if( xfont != 0 )
      SelectObject( hDC, ( HPEN ) xfont );

   hb_retni( GetTextExtentPoint32( hDC, hb_parc( 1 ), hb_parclen( 1 ), &szMetric ) );
   HB_STORNI( szMetric.cy, 2, 1 );
   HB_STORNI( szMetric.cx, 2, 2 );
   if( xfont != 0 )
      SelectObject( hDC, hfont );
}

HB_FUNC( RR_ROUNDRECT )
{
   LONG_PTR xpen   = HB_PARNL( 4 );
   LONG_PTR xbrush = HB_PARNL( 5 );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   if( xbrush != 0 )
      SelectObject( hDC, ( HBRUSH ) xbrush );

   hb_retni( RoundRect( hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ) ) );

   if( xbrush != 0 )
      SelectObject( hDC, ( HBRUSH ) hbrush );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) hpen );
}

HB_FUNC( RR_ELLIPSE )
{
   LONG_PTR xpen   = HB_PARNL( 3 );
   LONG_PTR xbrush = HB_PARNL( 4 );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   if( xbrush != 0 )
      SelectObject( hDC, ( HBRUSH ) xbrush );

   hb_retni( Ellipse( hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ) ) );

   if( xpen != 0 )
      SelectObject( hDC, hpen );

   if( xbrush != 0 )
      SelectObject( hDC, hbrush );
}

HB_FUNC( RR_CHORD )
{
   LONG_PTR xpen   = HB_PARNL( 5 );
   LONG_PTR xbrush = HB_PARNL( 6 );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   if( xbrush != 0 )
      SelectObject( hDC, ( HBRUSH ) xbrush );

   hb_retni( Chord( hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ), HB_PARNI( 4, 2 ), HB_PARNI( 4, 1 ) ) );

   if( xpen != 0 )
      SelectObject( hDC, hpen );

   if( xbrush != 0 )
      SelectObject( hDC, hbrush );
}

HB_FUNC( RR_ARCTO )
{
   LONG_PTR xpen = HB_PARNL( 5 );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   hb_retni( ArcTo( hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ), HB_PARNI( 4, 2 ), HB_PARNI( 4, 1 ) ) );

   if( xpen != 0 )
      SelectObject( hDC, hpen );
}

HB_FUNC( RR_ARC )
{
   LONG_PTR xpen = HB_PARNL( 5 );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   hb_retni( Arc( hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ), HB_PARNI( 4, 2 ), HB_PARNI( 4, 1 ) ) );

   if( xpen != 0 )
      SelectObject( hDC, hpen );
}

HB_FUNC( RR_PIE )
{
   LONG_PTR xpen   = HB_PARNL( 5 );
   LONG_PTR xbrush = HB_PARNL( 6 );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   if( xbrush != 0 )
      SelectObject( hDC, ( HBRUSH ) xbrush );

   hb_retni( Pie( hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ), HB_PARNI( 3, 2 ), HB_PARNI( 3, 1 ), HB_PARNI( 4, 2 ), HB_PARNI( 4, 1 ) ) );

   if( xpen != 0 )
      SelectObject( hDC, hpen );

   if( xbrush != 0 )
      SelectObject( hDC, hbrush );
}

HB_FUNC( RR_FILLRECT )
{
   RECT rect;

   rect.left   = HB_PARNI( 1, 2 );
   rect.top    = HB_PARNI( 1, 1 );
   rect.right  = HB_PARNI( 2, 2 );
   rect.bottom = HB_PARNI( 2, 1 );
   hb_retni( FillRect( hDC, &rect, ( HBRUSH ) HB_PARNL( 3 ) ) );
}

HB_FUNC( RR_FRAMERECT )
{
   RECT rect;

   rect.left   = HB_PARNI( 1, 2 );
   rect.top    = HB_PARNI( 1, 1 );
   rect.right  = HB_PARNI( 2, 2 );
   rect.bottom = HB_PARNI( 2, 1 );
   hb_retni( FrameRect( hDC, &rect, ( HBRUSH ) HB_PARNL( 3 ) ) );
}

HB_FUNC( RR_LINE )
{
   LONG_PTR xpen = HB_PARNL( 3 );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   MoveToEx( hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ), NULL );
   hb_retni( LineTo( hDC, HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ) ) );
   if( xpen != 0 )
      SelectObject( hDC, hpen );
}

HB_FUNC( RR_LINETO )
{
   LONG_PTR xpen = HB_PARNL( 2 );

   if( xpen != 0 )
      SelectObject( hDC, ( HPEN ) xpen );

   hb_retni( LineTo( hDC, HB_PARNI( 1, 2 ), HB_PARNI( 1, 1 ) ) );
   if( xpen != 0 )
      SelectObject( hDC, hpen );
}

HB_FUNC( RR_INVERTRECT )
{
   RECT rect;

   rect.left   = HB_PARNI( 1, 2 );
   rect.top    = HB_PARNI( 1, 1 );
   rect.right  = HB_PARNI( 2, 2 );
   rect.bottom = HB_PARNI( 2, 1 );
   hb_retni( InvertRect( hDC, &rect ) );
}

HB_FUNC( RR_GETDESKTOPAREA )
{
   RECT rect;

   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_reta( 4 );
   HB_STORNI( ( INT ) rect.top, -1, 1 );
   HB_STORNI( ( INT ) rect.left, -1, 2 );
   HB_STORNI( ( INT ) rect.bottom - rect.top, -1, 3 );
   HB_STORNI( ( INT ) rect.right - rect.left, -1, 4 );
}

HB_FUNC( RR_GETCLIENTRECT )
{
   RECT rect;

   GetClientRect( ( HWND ) HB_PARVNL( 1, 7 ), &rect );
   HB_STORNI( rect.top, 1, 1 );
   HB_STORNI( rect.left, 1, 2 );
   HB_STORNI( rect.bottom, 1, 3 );
   HB_STORNI( rect.right, 1, 4 );
   HB_STORNI( rect.bottom - rect.top + 1, 1, 5 );
   HB_STORNI( rect.right - rect.left + 1, 1, 6 );
}

HB_FUNC( RR_SCROLLWINDOW )
{
   ScrollWindow( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ), NULL, NULL );
}

HB_FUNC( RR_PREVIEWPLAY )
{
   RECT rect;
   HDC  imgDC      = GetWindowDC( ( HWND ) HB_PARNL( 1 ) );
   HDC  tmpDC      = CreateCompatibleDC( imgDC );
   HENHMETAFILE hh = GetEnhMetaFile( HB_PARC( 2, 1 ) );

   if( tmpDC == NULL )
   {
      ReleaseDC( ( HWND ) HB_PARNL( 1 ), imgDC );
      hb_retl( 0 );
   }

   if( himgbmp != 0 )
      DeleteObject( himgbmp );

   SetRect( &rect, 0, 0, HB_PARVNL( 3, 4 ), HB_PARVNL( 3, 3 ) );
   himgbmp = CreateCompatibleBitmap( imgDC, rect.right, rect.bottom );
   DeleteObject( SelectObject( tmpDC, ( HBITMAP ) himgbmp ) );
   FillRect( tmpDC, &rect, ( HBRUSH ) GetStockObject( WHITE_BRUSH ) );
   PlayEnhMetaFile( tmpDC, hh, &rect );
   DeleteEnhMetaFile( hh );
   SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) STM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himgbmp );
   ReleaseDC( ( HWND ) HB_PARNL( 1 ), imgDC );
   DeleteDC( tmpDC );
   if( himgbmp == 0 )
      hb_retl( 0 );
   else
      hb_retl( 1 );
}

HB_FUNC( RR_PLAYTHUMB )
{
   RECT rect;
   HDC  tmpDC;
   HDC  imgDC      = GetWindowDC( ( HWND ) HB_PARVNL( 1, 5 ) );
   HENHMETAFILE hh = GetEnhMetaFile( HB_PARC( 2, 1 ) );
   int          i;

   i     = hb_parni( 4 ) - 1;
   tmpDC = CreateCompatibleDC( imgDC );
   SetRect( &rect, 0, 0, HB_PARNI( 1, 4 ), HB_PARNI( 1, 3 ) );
   hbmp[ i ] = CreateCompatibleBitmap( imgDC, rect.right, rect.bottom );
   DeleteObject( SelectObject( tmpDC, hbmp[ i ] ) );
   FillRect( tmpDC, &rect, ( HBRUSH ) GetStockObject( WHITE_BRUSH ) );
   PlayEnhMetaFile( tmpDC, hh, &rect );
   DeleteEnhMetaFile( hh );
   TextOut( tmpDC, ( int ) rect.right / 2 - 5, ( int ) rect.bottom / 2 - 5, hb_parc( 3 ), hb_parclen( 3 ) );
   SendMessage( ( HWND ) HB_PARVNL( 1, 5 ), ( UINT ) STM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) hbmp[ i ] );
   ReleaseDC( ( HWND ) HB_PARVNL( 1, 5 ), imgDC );
   DeleteDC( tmpDC );
}

HB_FUNC( RR_PLAYENHMETAFILE )
{
   RECT rect;
   HENHMETAFILE hh = GetEnhMetaFile( HB_PARC( 1, 1 ) );

   SetRect( &rect, 0, 0, HB_PARVNL( 1, 5 ), HB_PARVNL( 1, 4 ) );
   PlayEnhMetaFile( ( HDC ) HB_PARNL( 2 ), hh, &rect );
   DeleteEnhMetaFile( hh );
}

HB_FUNC( RR_LALABYE )
{
   if( hb_parni( 1 ) == 1 )
   {
      hDCtemp = hDC;
      hDC     = hDCRef;
   }
   else
      hDC = hDCtemp;
}

#pragma ENDDUMP
