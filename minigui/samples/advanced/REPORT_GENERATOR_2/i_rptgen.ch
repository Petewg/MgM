#ifndef _RPTGEN_
#define _RPTGEN_

#include "miniprint.ch"

#xcommand LOAD REPORT <w> ; 
	=> ;
	_HMG_RPTDATA \[ 162 \] := <"w"> ;;
	#include \<<w>.rmg\>  ;;
	#xtranslate \<w\> . Execute ( \<p1\> , \<p2\> ) => ExecuteReport ( \<"w"\> , \<p1\> , \<p2\> )  


* Report Main .................................................................

#xcommand DEFINE REPORT <name>	=> _DefineReport( <"name">) ; #xtranslate \<name\> . Execute ( \<p1\> , \<p2\> ) => ExecuteReport ( \<"name"\> , \<p1\> , \<p2\> )  

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
	=>;
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

#xcommand EXECUTE REPORT <ReportName>  ;
=> ;
ExecuteReport ( <"ReportName"> , .f. , .f. )

#xcommand EXECUTE REPORT <ReportName> PREVIEW ;
=> ;
ExecuteReport ( <"ReportName"> , .t. , .f. )

#xcommand EXECUTE REPORT <ReportName> PREVIEW SELECTPRINTER ;
=> ;
ExecuteReport ( <"ReportName"> , .t. , .t. )

#xcommand EXECUTE REPORT <ReportName> FILE <FileName> ;
=> ;
ExecuteReport ( <"ReportName"> , .f. , .f. , <FileName> )


* Layout ......................................................................

#xcommand BEGIN SUMMARY => _BeginSummary()
#xcommand END SUMMARY  => _EndSummary() 


*******************************************************************************

* Group .......................................................................
        
#xcommand BEGIN GROUP => _BeginGroup()


#xcommand GROUPEXPRESSION <value> ;
	=>;
	_HMG_RPTDATA \[ 125 \] := <"value"> 


#xcommand END GROUP  => _EndGroup() 

* Group Header ......................................................................

#xcommand BEGIN GROUPHEADER => _BeginGroupHeader()

#xcommand END GROUPHEADER  => _EndGroupHeader() 

* Group Footer ......................................................................

#xcommand BEGIN GROUPFOOTER => _BeginGroupFooter()

#xcommand END GROUPFOOTER  => _EndGroupFooter() 

#endif