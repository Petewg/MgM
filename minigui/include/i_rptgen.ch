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
  Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
  Copyright 2001 Antonio Linares <alinares@fivetech.com>
 www - https://harbour.github.io/

 "Harbour Project"
 Copyright 1999-2020, https://harbour.github.io/

 "WHAT32"
 Copyright 2002 AJ Wos <andrwos@aust1.net>

 "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#ifndef _RPTGEN_
#define _RPTGEN_

#xcommand LOAD REPORT <w> ;
	=> ;
	_HMG_RPTDATA \[ 162 \] := <"w"> ;;
	#include \<<w>.rmg\> ;;
	#xtranslate \<w\> . Execute ( \<p1\> , \<p2\> ) => ExecuteReport ( \<"w"\> , \<p1\> , \<p2\> )


* Report Main .................................................................

#xcommand DEFINE REPORT <name>	=> _DefineReport( <(name)> ) ; #xtranslate \<name\> . Execute ( \<p1\> , \<p2\> ) => ExecuteReport ( \<(name)\> , \<p1\> , \<p2\> )

#xcommand END REPORT	=> _EndReport() 

#xcommand DEFINE REPORT TEMPLATE => _DefineReport( "_TEMPLATE_" ) 

#xcommand BANDHEIGHT	<nValue> => _BandHeight(<nValue>)


* Skip Expression .............................................................

#xcommand ITERATOR	<xValue> => _HMG_RPTDATA \[164\] := <{xValue}>
#xcommand STOPPER	<xValue> => _HMG_RPTDATA \[165\] := <{xValue}>


* Layout ......................................................................

#xcommand BEGIN LAYOUT	=> _BeginLayout()
#xcommand ORIENTATION	<nValue> => _HMG_RPTDATA \[155\] := <nValue>
#xcommand PAPERSIZE	<nValue> => _HMG_RPTDATA \[156\] := <nValue>

#xcommand PAPERWIDTH	<nValue> => _HMG_RPTDATA \[118\] := <nValue>
#xcommand PAPERLENGTH	<nValue> => _HMG_RPTDATA \[119\] := <nValue>

#xcommand END LAYOUT	=> _EndLayout()


* Header ......................................................................

#xcommand BEGIN HEADER => _BeginHeader()

#xcommand END HEADER  => _EndHeader()


* Detail ......................................................................

#xcommand BEGIN DETAIL => _BeginDetail()

#xcommand END DETAIL  => _EndDetail()


* Data ......................................................................

#xcommand BEGIN DATA => _BeginData()

#xcommand END DATA  => _EndData()


* Footer ......................................................................

#xcommand BEGIN FOOTER => _BeginFooter()

#xcommand END FOOTER  => _EndFooter()


* Text ......................................................................

#xcommand BEGIN TEXT => _BeginText()

#xcommand END TEXT  => _EndText()

#xcommand EXPRESSION <value> ;
	=> ;
	_HMG_RPTDATA \[ 116 \] := <"value">


* Line ......................................................................

#xcommand BEGIN LINE => _BeginLine()

#xcommand END LINE  => _EndLine()


* Image ......................................................................

#xcommand BEGIN PICTURE => _BeginImage()

#xcommand END PICTURE  => _EndImage()

#xcommand FROMROW	<nValue> => _HMG_RPTDATA \[ 110 \] := <nValue>
#xcommand FROMCOL	<nValue> => _HMG_RPTDATA \[ 111 \] := <nValue>
#xcommand TOROW		<nValue> => _HMG_RPTDATA \[ 112 \] := <nValue>
#xcommand TOCOL		<nValue> => _HMG_RPTDATA \[ 113 \] := <nValue>
#xcommand PENWIDTH	<nValue> => _HMG_RPTDATA \[ 114 \] := <nValue>
#xcommand PENCOLOR	<aValue> => _HMG_RPTDATA \[ 115 \] := <aValue>

* Rectangle ...................................................................

#xcommand BEGIN RECTANGLE => _BeginRectangle()

#xcommand END RECTANGLE  => _EndRectangle()

* Misc ************************************************************************

#xtranslate Application.CurrentReport.PageNumber => _HMG_RPTDATA \[ 117 \]

#xtranslate _PageNo => _HMG_RPTDATA \[ 117 \]

* Execute *********************************************************************

#xcommand EXECUTE REPORT <ReportName> ;
	[ <preview : PREVIEW> ] ;
	[ <select : SELECTPRINTER> ] ;
=> ;
ExecuteReport ( <(ReportName)> , <.preview.> , <.select.> )

#xcommand EXECUTE REPORT <ReportName> FILE <FileName> ;
=> ;
ExecuteReport ( <(ReportName)> , .f. , .f. , <FileName> )


* Layout ......................................................................

#xcommand BEGIN SUMMARY => _BeginSummary()
#xcommand END SUMMARY  => _EndSummary()


* Group .......................................................................
        
#xcommand BEGIN GROUP => _BeginGroup()


#xcommand GROUPEXPRESSION <value> ;
	=> ;
	_HMG_RPTDATA \[ 125 \] := <"value">


#xcommand END GROUP  => _EndGroup()

* Group Header ......................................................................

#xcommand BEGIN GROUPHEADER => _BeginGroupHeader()

#xcommand END GROUPHEADER  => _EndGroupHeader()

* Group Footer ......................................................................

#xcommand BEGIN GROUPFOOTER => _BeginGroupFooter()

#xcommand END GROUPFOOTER  => _EndGroupFooter()

#endif
