 ************************************************************************************ 
 * Program Name....: AST_ComboBox.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE COMBOBOX Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 * 						http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 * 						La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 09, 2007 01:50:41 AM, Tabuk, KSA
 * Last Updated....:
 *
 * Revision History: 
 * -----------------
 * October 09, 2007 02:29:00 AM , Tabuk, KSA - Source Code completion.
 *
 *
 * October 09, 2007 01:50:41 AM, KSA
 * ---------------------------------
 * 	Original Source Code
 *
 *************************************************************************************/


#include "minigui.ch"
*#include "inkey.ch"
*#include "common.ch"
#include "dale-aid.ch"

*#define CRLF  HB_OSNEWLINE()

**************************************************************************************
** Function Name...: AST_ComboBox()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_COMBOBOX(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... COMBOBOX Command Syntax
**
** Description.....: Converts DEFINE COMBOBOX Command to @ ... COMBOBOX Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_ComboBox(cReadString,cTerminator)

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
	// HMG COMBOBOX @... Command Snytax:
	// ---------------------------------
	//	@ <nRow> ,<nCol> 
	//		COMBOBOX <ControlName> 
	//		[ OF | PARENT <ParentWindowName> ]
	//		[ ITEMS <caItems> ] 
	//		[ ITEMSOURCE <ItemSourceField> ]
	//		[ VALUE <nValue> ] 
	//		[ VALUESOURCE <ValueSourceField> ]
	//		[ DISPLAYEDIT ]
	//		[ WIDTH <nWodth> ] 
	//		[ HEIGHT <nHeight>]
	//		[ FONT <cFontName> SIZE <nFontSize> ] 
	//		[ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
	//		[ TOOLTIP <cToolTipText> ] 
	//		[ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
	//		[ ON CHANGE <OnChangeProcedure> | <bBlock> ] 
	//		[ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
	//		[ ON ENTER <OnEnterProcedure> | <bBlock> ]
	//		[ ON DISPLAYCHANGE <OnDisplayChangeProcedure> | <bBlock> ]
	//		[ NOTABSTOP ]
	//		[ HELPID <nHelpId> ] 
	//		[ BREAK ]
	//		[ GRIPPERTEXT <cGripperText> ] 
	//		[ INVISIBLE ]
	//		[ SORT ] 
	//
	// =============================================================
	// @ <nRow> ,<nCol> COMBOBOX <ControlName> OF <ParentWindowName> ITEMS <caItems> VALUE <nValue>;
	// 	WIDTH <nWidth> HEIGHT <nHeight> FONT <cFontName> SIZE <nFontSize> ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock>
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE COMBOBOX",""))				   // DEFINE COMBOBOX cboMemVar
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))								   // ROW    60
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))								   // COL    280
	aProperties_[ 4] := aDefCommandList_[ 4]                                                     // WIDTH  100                
	aProperties_[ 5] := aDefCommandList_[ 5]                                                     // HEIGHT 100                
	aProperties_[ 6] := aDefCommandList_[ 6]                                                     // ITEMS {"Option1","Option"}
	aProperties_[ 7] := aDefCommandList_[ 7]                                                     // VALUE 0                   
	aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"NAME",""))								   // FONTNAME "Arial"
	aProperties_[ 9] := ALLTRIM(STRTRAN(aDefCommandList_[ 9],"FONT",""))								   // FONTSIZE 9
	aProperties_[10] := aDefCommandList_[10]                                                     // TOOLTIP ""    
	aProperties_[11] := aDefCommandList_[11]                                                     // ONCHANGE Nil  
	aProperties_[12] := aDefCommandList_[12]                                                     // ONGOTFOCUS Nil
	aProperties_[13] := ALLTRIM(STRTRAN(aDefCommandList_[13],"ON","ON "))							   // ONLOSTFOCUS Nil
	aProperties_[14] := aDefCommandList_[14]                                                     // FONTBOLD .F.       
	aProperties_[15] := aDefCommandList_[15]                                                     // FONTITALIC .F.     
	aProperties_[16] := aDefCommandList_[16]                                                     // FONTUNDERLINE .F.  
	aProperties_[17] := aDefCommandList_[17]                                                     // FONTSTRIKEOUT .F.  
	aProperties_[18] := aDefCommandList_[18]                                                     // HELPID Nil         
	aProperties_[19] := aDefCommandList_[19]                                                     // TABSTOP .T.        
	aProperties_[20] := aDefCommandList_[20]                                                     // VISIBLE .T.        
	aProperties_[21] := aDefCommandList_[21]                                                     // SORT .F.           
	aProperties_[22] := aDefCommandList_[22]                                                     // ONENTER Nil        
	aProperties_[23] := aDefCommandList_[23]                                                     // ONDISPLAYCHANGE Nil
	aProperties_[24] := aDefCommandList_[24]                                                     // DISPLAYEDIT .F.    
	aProperties_[25] := aDefCommandList_[25]                                                     // END COMBOBOX       

	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " COMBOBOX " + ;
				  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[6] + " " + aProperties_[7] + ";" + CRLF +;
				  LDCS_iLevel(3) + aProperties_[4] + " " + aProperties_[5] + " " + aProperties_[8] + " " +;
				  aProperties_[9] + " " + aProperties_[13] + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal














