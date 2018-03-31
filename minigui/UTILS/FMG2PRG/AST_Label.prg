 ************************************************************************************ 
 * Program Name....: AST_Label.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE LABEL Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 * 						http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 * 						La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 04, 2007 09:09:35 PM, Tabuk, KSA
 * Last Updated....:
 *
 * Revision History: 
 * -----------------
 * October 04, 2007 09:32:42 PM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 04, 2007 09:09:35 PM, Tabuk, KSA
 * ----------------------------------------
 * 	Original Source Code
 *
 *************************************************************************************/


#include "minigui.ch"
*#include "inkey.ch"
*#include "common.ch"
#include "dale-aid.ch"

*#define CRLF  HB_OSNEWLINE()

**************************************************************************************
** Function Name...: AST_Label()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_LABEL(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... LABEL Command Syntax
**
** Description.....: Converts DEFINE LABEL Command to @ ... LABEL Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_Label(cReadString,cTerminator)

	LOCAL cRetVal := ""

	LOCAL aDefCommandList_ := {},;
			aProperties_	  := {}
	LOCAL sReadLine := ""
	
	LOCAL nKeywordPos := 0
	LOCAL cTemp1 := ""
	LOCAL cTemp2 := ""

	AADD(aDefCommandList_, cReadString)
	WHILE oFileHandle:MORETOREAD()
		sReadLine := ALLTRIM(oFileHandle:READLINE())
		AADD(aDefCommandList_, sReadLine)
		IF ALLTRIM(sReadLine) == cTerminator
			EXIT
		ENDIF
	ENDDO

	aProperties_ := ARRAY(LEN(aDefCommandList_)) 

	//////////////////////////////////////////////////////////////////////////////////////////////////
	// HMG LABEL @... Command Snytax:
	// ------------------------------
	//	@ <nRow> ,<nCol> 
	//		LABEL<ControlName> 
	//		[ OF | PARENT <ParentWindowName> ]
	//		VALUE <cValue> 
	//		[ ACTION  | ONCLICK | 
	//		ON CLICK  <ActionProcedureName> | <bBlock> ]
	//		[ WIDTH <nWidth> ] 
	//		[ HEIGHT <nHeight> ] 
	//		[ AUTOSIZE ]
	//		[ FONT <cFontname> SIZE <nFontsize> ] 
	//		[ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
	//		[ TOOLTIP <cToolTipText> ] 
	//		[ BACKCOLOR <anBackColor> ] 
	//		[ FONTCOLOR <anFontColor>]   
	//		[ TRANSPARENT ]
	//		[ RIGHTALIGN | CENTERALIGN ]
	//		[ HELPID <nHelpId> ] 
	//		[ INVISIBLE ] 
	//
	//------------------------------------------------------------------------------------------------
	// @ <nRow> ,<nCol> LABEL <ControlName> OF <ParentWindowName> VALUE <cValue>;
	// 	ACTION <ActionProcedure> | <bBlock> WIDTH <nWidth> HEIGHT <nHeight> FONT <cFontName> SIZE <nFontSize>
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE LABEL",""))   // DEFINE LABEL lblHMGTxtManual
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))			    // ROW    13
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))			    // COL    10
	aProperties_[ 4] := aDefCommandList_[ 4]                                       // WIDTH  130                   
	aProperties_[ 5] := aDefCommandList_[ 5]                                       // HEIGHT 18                    
	aProperties_[ 6] := aDefCommandList_[ 6]                                       // VALUE "Load HMG Text Manual:"
	aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"NAME",""))			    // FONTNAME "Arial"
	aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"FONT",""))			    // FONTSIZE 9
	aProperties_[ 9] := aDefCommandList_[ 9]                                       // TOOLTIP ""       
	aProperties_[10] := aDefCommandList_[10]                                       // FONTBOLD .F.     
	aProperties_[11] := aDefCommandList_[11]                                       // FONTITALIC .F.   
	aProperties_[12] := aDefCommandList_[12]                                       // FONTUNDERLINE .F.
	aProperties_[13] := aDefCommandList_[13]                                       // FONTSTRIKEOUT .F.
	aProperties_[14] := aDefCommandList_[14]                                       // HELPID Nil       
	aProperties_[15] := aDefCommandList_[15]                                       // VISIBLE .T.      
	aProperties_[16] := aDefCommandList_[16]                                       // TRANSPARENT .F.  
	aProperties_[17] := aDefCommandList_[17]                                       // ACTION Nil       
	aProperties_[18] := aDefCommandList_[18]                                       // AUTOSIZE .F.     
	aProperties_[19] := aDefCommandList_[19]                                       // BACKCOLOR NIL    
	aProperties_[20] := aDefCommandList_[20]                                       // FONTCOLOR NIL    
	aProperties_[21] := aDefCommandList_[21]                                       // END LABEL        

	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " LABEL " +;
				  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[6] + "; " + CRLF +;
				  LDCS_iLevel(3) + aProperties_[17] + " " + aProperties_[4] + " " +;
				  aProperties_[5] + " " + aProperties_[7] + " " + aProperties_[8] + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal


