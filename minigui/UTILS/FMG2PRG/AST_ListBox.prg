 ************************************************************************************ 
 * Program Name....: AST_ListBox.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE LISTBOX Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 * 						http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 * 						La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 14, 2007 01:08:25 AM, Tabuk, KSA
 * Last Updated....:
 *
 * Revision History: 
 * -----------------
 * October 14, 2007 01:08:25 AM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 14, 2007 01:08:25 AM, Tabuk, KSA
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
** Function Name...: AST_ListBox()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_LISTBOX(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... LISTBOX Command Syntax
**
** Description.....: Converts DEFINE LISTBOX Command to @ ... LISTBOX Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_ListBox(cReadString,cTerminator)

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
	// HMG LISTBOX @... Command Snytax:
	// ------------------------------
	//	@ <nRow> ,<nCol>
	//		LISTBOX <ControlName> 
	//		[ OF | PARENT <ParentWindowName> ]
	//		WIDTH <nWidth> 
	//		HEIGHT <nHeight> 
	//		[ ITEMS <acItems> ] 
	//		[ VALUE <nValue> ] 
	//		[ FONT <cFontName> SIZE <nFontSize> ]
	//		[ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
	//		[ TOOLTIP <cToolTipText> ]    
	//		[ BACKCOLOR <aBackColor> ]
	//		[ FONTCOLOR <aFontColor> ]
	//		[ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
	//		[ ON CHANGE <OnChangeProcedure> | <bBlock> ]    
	//		[ ON LOSTFOCUS <OnLostFocusProcedur> | <bBlock> ]
	//		[ ON DBLCLICK <OnDblClickProcedure> | bBlock> ] 
	//		[ MULTISELECT ]
	//		[ HELPID <nHelpId> ] 
	//		[ BREAK ]
	//		[ INVISIBLE ]
	//		[ NOTABSTOP ]
	//		[ SORT ] 
	//
	//------------------------------------------------------------------------------------------------
	// @ <nRow> ,<nCol> LISTBOX <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>;
	// 	ITEMS <acItems> VALUE <nValue> FONT <cFontName> SIZE <nFontSize> ON DBLCLICK <OnDblClickProcedure>
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE LISTBOX",""))		   // DEFINE LISTBOX List_2
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))						   // ROW    30
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))						   // COL    180
	aProperties_[ 4] := aDefCommandList_[ 4]                                               // WIDTH  140
	aProperties_[ 5] := aDefCommandList_[ 5]                                               // HEIGHT 130
	aProperties_[ 6] := aDefCommandList_[ 6]                                               // ITEMS {""}
	aProperties_[ 7] := aDefCommandList_[ 7]                                               // VALUE 0   
	aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"NAME",""))						   // FONTNAME "Arial"
	aProperties_[ 9] := ALLTRIM(STRTRAN(aDefCommandList_[ 9],"FONT",""))						   // FONTSIZE 9
	aProperties_[10] := aDefCommandList_[10]                                               // TOOLTIP ""       
	aProperties_[11] := aDefCommandList_[11]                                               // ONCHANGE Nil     
	aProperties_[12] := aDefCommandList_[12]                                               // ONGOTFOCUS Nil   
	aProperties_[13] := aDefCommandList_[13]                                               // ONLOSTFOCUS Nil  
	aProperties_[14] := aDefCommandList_[14]                                               // FONTBOLD .F.     
	aProperties_[15] := aDefCommandList_[15]                                               // FONTITALIC .F.   
	aProperties_[16] := aDefCommandList_[16]                                               // FONTUNDERLINE .F.
	aProperties_[17] := aDefCommandList_[17]                                               // FONTSTRIKEOUT .F.
	aProperties_[18] := aDefCommandList_[18]                                               // BACKCOLOR Nil    
	aProperties_[19] := aDefCommandList_[19]                                               // FONTCOLOR Nil    
	aProperties_[20] := ALLTRIM(STRTRAN(aDefCommandList_[20],"ON","ON "))					   // ONDBLCLICK Nil
	aProperties_[21] := aDefCommandList_[21]                                               // HELPID Nil     
	aProperties_[22] := aDefCommandList_[22]                                               // TABSTOP .T.    
	aProperties_[23] := aDefCommandList_[23]                                               // VISIBLE .T.    
	aProperties_[24] := aDefCommandList_[24]                                               // SORT .F.       
	aProperties_[25] := aDefCommandList_[25]                                               // MULTISELECT .T.
	aProperties_[26] := aDefCommandList_[26]                                               // END LISTBOX    

	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " LISTBOX " +;
				  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[4] + " " + aProperties_[5] + ";" + CRLF +;
				  LDCS_iLevel(3) + aProperties_[6] + " " + aProperties_[7] + " " + aProperties_[8] + " " +;
				  aProperties_[9] + " " + aProperties_[20] + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal













