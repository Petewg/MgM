/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 This program is free software; you can redistribute it and/or modify it under 
 the terms of the GNU General Public License as published by the Free Software 
 Foundation; either version 2 of the License, or (at your option) any later 
 version. 

 This program is distributed in the hope that it will be useful, but WITHOUT 
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with 
 this software; see the file COPYING. If not, write to the Free Software 
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or 
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text 
 contained in this release of Harbour Minigui.

 The exception is that, if you link the Harbour Minigui library with other 
 files to produce an executable, this does not by itself cause the resulting 
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the 
 Harbour-Minigui library code into it.

 Parts of this project are based upon:

	"Harbour GUI framework for Win32"
 	Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - http://harbour-project.org

	"Harbour Project"
	Copyright 1999-2017, http://harbour-project.org/

	"WHAT32"
	Copyright 2002 AJ Wos <andrwos@aust1.net> 

	"HWGUI"
  	Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#xcommand DRAW TEXT IN WINDOW <windowname> ;
          AT <nRow>,<nCol> ;
          VALUE <cString>  ;
          [ FONT <cFont> ] ;
          [ SIZE <nSize> ] ;
          [ BACKCOLOR <aBkRGB> ] ;
          [ FONTCOLOR <aRGB> ] ;
          [ <lBold : BOLD> ] ;
          [ <lItalic : ITALIC> ] ;
          [ <lUnderline : UNDERLINE> ] ;
          [ <lStrikeout : STRIKEOUT> ] ;
          [ <lTransparent: TRANSPARENT> ] ;
          [ ANGLE <nAngle> ] ;
       =>;
          drawtextout(<"windowname">,<nRow>,<nCol>,<cString>,<aRGB>,<aBkRGB>,<cFont>,<nSize>, ;
		<.lBold.>,<.lItalic.>,<.lUnderline.>,<.lStrikeout.>,<.lTransparent.>,<nAngle>)

#xcommand DRAW LINE IN WINDOW <windowname> AT <frow>,<fcol> ;
             TO <trow>,<tcol> ;
             [PENCOLOR <penrgb>] ;
             [PENWIDTH <pnwidth>];
          =>;
          drawline(<"windowname">,<frow>,<fcol>,<trow>,<tcol>,[<penrgb>],<pnwidth>)

#xcommand DRAW RECTANGLE IN WINDOW <windowname> AT <frow>,<fcol> ;
             TO <trow>,<tcol> ;
             [PENCOLOR <penrgb>] ;
             [PENWIDTH <pnwidth>];
             [FILLCOLOR <fillrgb>];
          =>;
          drawrect(<"windowname">,<frow>,<fcol>,<trow>,<tcol>,[<penrgb>],<pnwidth>,[<fillrgb>])

#xcommand DRAW ROUNDRECTANGLE IN WINDOW <windowname> AT <frow>,<fcol> ;
             TO <trow>,<tcol> ;
             ROUNDWIDTH <width>;
             ROUNDHEIGHT <height>;
             [PENCOLOR <penrgb>] ;
             [PENWIDTH <pnwidth>];
             [FILLCOLOR <fillrgb>];
          =>;
          drawroundrect(<"windowname">,<frow>,<fcol>,<trow>,<tcol>,<width>,<height>,[<penrgb>],<pnwidth>,[<fillrgb>])
        
#xcommand DRAW ELLIPSE IN WINDOW <windowname> AT <frow>,<fcol> ;
             TO <trow>,<tcol> ;
             [PENCOLOR <penrgb>] ;
             [PENWIDTH <pnwidth>];
             [FILLCOLOR <fillrgb>];
          =>;
          drawellipse(<"windowname">,<frow>,<fcol>,<trow>,<tcol>,[<penrgb>],<pnwidth>,[<fillrgb>])

#xcommand DRAW ARC IN WINDOW <windowname> AT <frow>,<fcol> ;
             TO <trow>,<tcol> ;
             FROM RADIAL <rrow>, <rcol>;
             TO RADIAL <rrow1>, <rcol1>;
             [PENCOLOR <penrgb>] ;
             [PENWIDTH <pnwidth>];
          =>;
          drawarc(<"windowname">,<frow>,<fcol>,<trow>,<tcol>,<rrow>,<rcol>,<rrow1>,<rcol1>,[<penrgb>],<pnwidth>)

#xcommand DRAW PIE IN WINDOW <windowname> AT <frow>,<fcol> ;
             TO <trow>,<tcol> ;
             FROM RADIAL <rrow>, <rcol>;
             TO RADIAL <rrow1>, <rcol1>;
             [PENCOLOR <penrgb>] ;
             [PENWIDTH <pnwidth>];
             [FILLCOLOR <fillrgb>];
          =>;
          drawpie(<"windowname">,<frow>,<fcol>,<trow>,<tcol>,<rrow>,<rcol>,<rrow1>,<rcol1>,[<penrgb>],<pnwidth>,[<fillrgb>])
          
// Points should be in the format {{row1,col1},{row2,col2},{row3,col3},{row4,col4}.....}                
#xcommand DRAW POLYGON IN WINDOW <windowname> ;
            points <pointsarr> ;
            [PENCOLOR <penrgb>] ;
            [PENWIDTH <penwidth>] ;
            [FILLCOLOR <fillrgb>] ;
         =>;
         drawpolygon(<"windowname">,[<pointsarr>],[<penrgb>],<penwidth>,[<fillrgb>])          

#xcommand DRAW POLYBEZIER IN WINDOW <windowname> ;
            points <pointsarr> ;
            [PENCOLOR <penrgb>] ;
            [PENWIDTH <penwidth>] ;
         =>;
         drawpolybezier(<"windowname">,[<pointsarr>],[<penrgb>],<penwidth>)          


#xcommand DRAW ICON IN WINDOW <windowname> AT <row>,<col> ;
          PICTURE <filename> ;
          [ WIDTH <w> ] ;
          [ HEIGHT <h> ] ;
          [ COLOR <rgb> ] ; 
          [ <transparent: TRANSPARENT> ] ;
          => ;
          hmg_drawicon(<"windowname">,<filename>,<row>,<col>,[<w>],[<h>],[<rgb>],<.transparent.>)


#xcommand ERASE WINDOW <windowname> ;
          => ;
         EraseBarGraph(<"windowname">) ;;
         ErasePieGraph(<"windowname">) ;;
         EraseWindow(<"windowname">)


/* Default parameters management */
#xcommand DEFAULT <uVar1> := <uVal1> [, <uVarN> := <uValN> ] ;
		=> ;
		<uVar1> := iif( <uVar1> == NIL, <uVal1>, <uVar1> ) ;
		[; <uVarN> := iif( <uVarN> == NIL, <uValN>, <uVarN> ) ]

#translate RGB( <nRed>, <nGreen>, <nBlue> ) => ;
              ( <nRed> + ( <nGreen> * 256 ) + ( <nBlue> * 65536 ) )

#xtranslate nRGB2Arr( <nColor> ) => ;
              { GetRed( <nColor> ), GetGreen( <nColor> ), GetBlue( <nColor> ) }

#xcommand DRAW GRAPH IN WINDOW <window> ;
      AT <nT>,<nL> 			;
      TO <nB>,<nR>			;
      TITLE <cTitle>			;
      TYPE PIE				;
      SERIES <aSer>			;
      DEPTH <nD>			;
      SERIENAMES <aName>		;
      COLORS <aColor>			;
      [ <l3D : 3DVIEW> ]		;
      [ <lxVal : SHOWXVALUES> ]		;
      [ <lSLeg : SHOWLEGENDS>		;
      [ <placement:RIGHT,BOTTOM> ] ]	;
      [ DATAMASK <mask> ]		;
      [ <lNoborder : NOBORDER> ]	;
=> ;
      DrawPieGraph(<"window">,;
			<nT>,;
			<nL>,;
			<nB>,;
			<nR>,;
			<aSer>,;
			<aName>,;
			<aColor>,;
			<cTitle>,;
			<nD>,;
			<.l3D.>,;
			<.lxVal.>,;
			<.lSLeg.>,;
			<mask>,;
			<.lNoborder.>, <"placement">)

#define BARS      1
#define LINES     2
#define POINTS    3

#xcommand DRAW GRAPH				;
		IN WINDOW <window>		;
		AT <nT>,<nL>			;
		[ TO <nB>,<nR> ]		;
		[ WIDTH <nW> ]			;
		[ HEIGHT <nH>	]		;
		[ TITLE <cTitle> ]		;
		TYPE <nType>			;
		SERIES <aSer>			;
		YVALUES <aYVal>			;
		DEPTH <nD>			;
		[ BARWIDTH <nW> ]		;
		[ BARSEPARATOR <nSep> ]		;
		HVALUES <nRange>		;
		SERIENAMES <aName>		;
		COLORS <aColor>			;
		[ <l3D : 3DVIEW> ]		;
		[ <lGrid : SHOWGRID> ]		;
		[ <lxGrid : SHOWXGRID> ]	; 
		[ <lyGrid : SHOWYGRID> ]	; 
		[ <lxVal : SHOWXVALUES> ]	; 
		[ <lyVal : SHOWYVALUES> ]	; 
		[ <lSLeg : SHOWLEGENDS> ]	; 
		[ <lViewVal : SHOWDATAVALUES> ]	; 
		[ DATAMASK <mask> ]		; 
		[ LEGENDSWIDTH <nLegendsWidth> ];
		[ <lNoborder : NOBORDER> ]	; 
=> ;
		GraphShow(<"window">,		;
		<nT>,				;
		<nL>,				;
		<nB>,				;
		<nR>,				;
		<nH>,				;
		<nW>,				;
		<aSer>,				;
		<cTitle>,			;
		<aYVal>,			;
		<nD>,				;
		<nW>,				;
		<nSep>,				;
		<nRange>,			;
		<.l3D.>,			;
		<.lGrid.>,			;
		<.lxGrid.>,			;
		<.lyGrid.>,			;
		<.lxVal.>,			;
		<.lyVal.>,			;
		<.lSLeg.>,			;
		<aName>,			;
		<aColor>,			;
		<nType>,			;
		<.lViewVal.>,			;
		<mask>, <nLegendsWidth>, <.lNoborder.>)

#xcommand PRINT GRAPH				;
		IN WINDOW <window>		;
		AT <nT>,<nL>			;
		[ TO <nB>,<nR> ]		;
		[ WIDTH <nW> ]			;
		[ HEIGHT <nH>	]		;
		[ TITLE <cTitle> ]		;
		TYPE <nType>			;
		SERIES <aSer>			;
		YVALUES <aYVal>			;
		DEPTH <nD>			;
		[ BARWIDTH <nW> ]		;
		[ BARSEPARATOR <nSep> ]		;
		HVALUES <nRange>		;
		SERIENAMES <aName>		;
		COLORS <aColor>			;
		[ <l3D : 3DVIEW> ]		;
		[ <lGrid : SHOWGRID> ]		;
		[ <lxGrid : SHOWXGRID> ]	; 
		[ <lyGrid : SHOWYGRID> ]	; 
		[ <lxVal : SHOWXVALUES> ]	; 
		[ <lyVal : SHOWYVALUES> ]	; 
		[ <lSLeg : SHOWLEGENDS> ]	; 
		[ <lViewVal : SHOWDATAVALUES> ]	; 
		[ DATAMASK <mask> ]		; 
		[ LEGENDSWIDTH <nLegendsWidth> ];
		[ LIBRARY <clib> ]		; 
=> ;
		_GraphPrint(<"window">,		;
		<nT>,				;
		<nL>,				;
		<nB>,				;
		<nR>,				;
		<nH>,				;
		<nW>,				;
		<aSer>,				;
		<cTitle>,			;
		<aYVal>,			;
		<nD>,				;
		<nW>,				;
		<nSep>,				;
		<nRange>,			;
		<.l3D.>,			;
		<.lGrid.>,			;
		<.lxGrid.>,			;
		<.lyGrid.>,			;
		<.lxVal.>,			;
		<.lyVal.>,			;
		<.lSLeg.>,			;
		<aName>,			;
		<aColor>,			;
		<nType>,			;
		<.lViewVal.>,			;
		<mask>, <nLegendsWidth>, 0, 0, <"clib">)

#xcommand PRINT GRAPH IN WINDOW <window>;
      AT <nT>,<nL>			;
      TO <nB>,<nR>			;
      TITLE <cTitle>			;
      TYPE PIE				;
      SERIES <aSer>			;
      DEPTH <nD>			;
      SERIENAMES <aName>		;
      COLORS <aColor>			;
      [ <l3D : 3DVIEW> ]		;
      [ <lxVal : SHOWXVALUES> ]		;
      [ <lSLeg : SHOWLEGENDS>		;
      [ <placement:RIGHT,BOTTOM> ] ]	;
      [ DATAMASK <mask> ]		;
      [ LIBRARY <clib> ]		;
=> ;
      _PiePrint(<"window">,;
		<nT>,;
		<nL>,;
		<nB>,;
		<nR>,;
		<aSer>,;
		<aName>,;
		<aColor>,;
		<cTitle>,;
		<nD>,;
		<.l3D.>,;
		<.lxVal.>,;
		<.lSLeg.>,;
		<mask>,;
		0, 0, <"clib">, <"placement">)
