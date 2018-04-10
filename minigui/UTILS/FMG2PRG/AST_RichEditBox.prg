 ************************************************************************************ 
 * Program Name....: AST_RichEditBox.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE RICHEDITBOX Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 * 						http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 * 						La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 09, 2007 03:04:08 AM, Tabuk, KSA
 * Last Updated....:
 *
 * Revision History: 
 * -----------------
 * October 04, 2007 09:32:42 PM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 09, 2007 03:04:08 AM, Tabuk, KSA
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
** Function Name...: AST_RichEditBox()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_RICHEDITBOX(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... RICHEDITBOX Command Syntax
**
** Description.....: Converts DEFINE RICHEDITBOX Command to @ ... RICHEDITBOX Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_RichEditBox(cReadString,cTerminator)

	LOCAL cRetVal := ""

	LOCAL aDefCommandList_ := {},;
			aProperties_	  := {}

	LOCAL sReadLine := ""
	
	LOCAL cSyntax := "MEMVAR"	
	
	AADD(aDefCommandList_, cReadString)
	WHILE oFileHandle:MORETOREAD()
		sReadLine := ALLTRIM(oFileHandle:READLINE())
		
		IF SUBSTR(sReadLine, 1, 5) == "FIELD"
			cSyntax := "DBF"
		ENDIF
		
		AADD(aDefCommandList_, sReadLine)
		IF ALLTRIM(sReadLine) == cTerminator
			EXIT
		ENDIF
	ENDDO

	aProperties_ := ARRAY(LEN(aDefCommandList_)) 

	//////////////////////////////////////////////////////////////////////////////////////////////////
	// HMG RICHEDITBOX @... Command Snytax:
	// -------------------------------------
	//	@ <nRow>,<nCol> RICHEDITBOX <ControlName> 
	//		[ OF | PARENT> <ParentWindowName> ] 
	//		[ WIDTH <nWidth> ] 
	//		[ HEIGHT <nHeight> ] 
	//		[ FIELD <Field> ] 
	//		[ VALUE <cValue> ] 
	//		[ READONLY ] 
	//		[ FONT <cFontName> ] 
	//		[ SIZE <nFontSize> ] 
	//		[ BOLD ] 
	//		[ ITALIC ] 
	//		[ UNDERLINE ] 
	//		[ STRIKEOUT ] 
	//		[ TOOLTIP <cToolTip> ] 
	//		[ BACKCOLOR <aBackColor> ] 
	//		[ MAXLENGTH <nMaxLength> ] 
	//		[ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ] 
	//		[ ON CHANGE <OnChangeProcedure> | <bBlock> ] 
	//		[ ON LOSTFOCUS <OnLostFocusProcedur> | <bBlock> ] 
	//		[ HELPID <nHelpId> ] 
	//		[ INVISIBLE ] 
	//		[ NOTABSTOP ] 
	//
	//------------------------------------------------------------------------------------------------
	// MEMVAR Only Syntax:
	// -------------------
	// @ <nRow> ,<nCol> RICHEDITBOX <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>
	// 	VALUE <cValue> FONT <cFontName> SIZE <nFontSize>
	//
	// DBF FIELD Syntax:
	// -----------------
	// @ <nRow> ,<nCol> RICHEDITBOX <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>;
	// 	FIELD <Field> VALUE <cValue> FONT <cFontName> SIZE <nFontSize>                                               
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////


	DO CASE
		CASE cSyntax == "MEMVAR"
			aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE RICHEDITBOX",""))		   // DEFINE RICHEDITBOX rchMemvar
			aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))							   // ROW    40
			aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))							   // COL    30
			aProperties_[ 4] := aDefCommandList_[ 4]                                                  // WIDTH  209
			aProperties_[ 5] := aDefCommandList_[ 5]                                                  // HEIGHT 244
			aProperties_[ 6] := aDefCommandList_[ 6]                                                  // VALUE ""  
			aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"NAME",""))							   // FONTNAME "Arial"
			aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"FONT",""))							   // FONTSIZE 9
			aProperties_[ 9] := aDefCommandList_[ 9]                                                  // TOOLTIP ""       
			aProperties_[10] := aDefCommandList_[10]                                                  // ONCHANGE Nil     
			aProperties_[11] := aDefCommandList_[11]                                                  // ONGOTFOCUS Nil   
			aProperties_[12] := aDefCommandList_[12]                                                  // ONLOSTFOCUS Nil  
			aProperties_[13] := aDefCommandList_[13]                                                  // FONTBOLD .F.     
			aProperties_[14] := aDefCommandList_[14]                                                  // FONTITALIC .F.   
			aProperties_[15] := aDefCommandList_[15]                                                  // FONTUNDERLINE .F.
			aProperties_[16] := aDefCommandList_[16]                                                  // FONTSTRIKEOUT .F.
			aProperties_[17] := aDefCommandList_[17]                                                  // HELPID Nil       
			aProperties_[18] := aDefCommandList_[18]                                                  // TABSTOP .T.      
			aProperties_[19] := aDefCommandList_[19]                                                  // VISIBLE .T.      
			aProperties_[20] := aDefCommandList_[20]                                                  // READONLY .F.     
			aProperties_[21] := aDefCommandList_[21]                                                  // BACKCOLOR Nil    
			aProperties_[22] := aDefCommandList_[22]                                                  // END RICHEDITBOX  

			*- pad short numbers row,column
		   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
		   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

			/////////////////////////////////////////////////////////////////////////////////////////////////////
			// @ <nRow> ,<nCol> RICHEDITBOX <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>
			// 	VALUE <cValue> FONT <cFontName> SIZE <nFontSize>
			/////////////////////////////////////////////////////////////////////////////////////////////////////
			cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " RICHEDITBOX " +;
						  aProperties_[1] + " ~LDCS_Form " + aProperties_[4] + " " + aProperties_[5] + " " +;
						  aProperties_[6] + " " + aProperties_[7] + " " + aProperties_[8] + CRLF

		CASE cSyntax == "DBF"
			aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE RICHEDITBOX",""))		   // DEFINE RICHEDITBOX rchDbfField
			aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))							   // ROW    40
			aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))   							// COL    270
			aProperties_[ 4] := aDefCommandList_[ 4]                                                  // WIDTH  250
			aProperties_[ 5] := aDefCommandList_[ 5]                                                  // HEIGHT 250
			aProperties_[ 6] := aDefCommandList_[ 6]                                                  // VALUE ""  
			aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"NAME",""))							   // FONTNAME "Arial"
			aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"FONT",""))							   // FONTSIZE 9
			aProperties_[ 9] := aDefCommandList_[ 9]                                                  // TOOLTIP ""       
			aProperties_[10] := aDefCommandList_[10]                                                  // ONCHANGE Nil     
			aProperties_[11] := aDefCommandList_[11]                                                  // ONGOTFOCUS Nil   
			aProperties_[12] := aDefCommandList_[12]                                                  // ONLOSTFOCUS Nil  
			aProperties_[13] := aDefCommandList_[13]                                                  // FONTBOLD .F.     
			aProperties_[14] := aDefCommandList_[14]                                                  // FONTITALIC .F.   
			aProperties_[15] := aDefCommandList_[15]                                                  // FONTUNDERLINE .F.
			aProperties_[16] := aDefCommandList_[16]                                                  // FONTSTRIKEOUT .F.
			aProperties_[17] := aDefCommandList_[17]                                                  // HELPID Nil       
			aProperties_[18] := aDefCommandList_[18]                                                  // TABSTOP .T.      
			aProperties_[19] := aDefCommandList_[19]                                                  // VISIBLE .T.      
			aProperties_[20] := aDefCommandList_[20]                                                  // READONLY .F.     
			aProperties_[21] := aDefCommandList_[21]                                                  // BACKCOLOR NIL    
			aProperties_[22] := aDefCommandList_[22]                                                  // FIELD MYFILE->F1 
			aProperties_[23] := aDefCommandList_[23]                                                  // END RICHEDITBOX  
 
			*- pad short numbers row,column
		   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
		   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

			//////////////////////////////////////////////////////////////////////////////////////////////////////
			// @ <nRow> ,<nCol> RICHEDITBOX <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>;
			// 	FIELD <Field> VALUE <cValue> FONT <cFontName> SIZE <nFontSize>                                
			///////////////////////////////////////////////////////////////////////////////////////////////////////
			cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " RICHEDITBOX " + ;
						  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[4] + " " + aProperties_[5] + ";" + CRLF +;
						  LDCS_iLevel(3) + aProperties_[22] + " " + aProperties_[6] + " " +;
						  aProperties_[7] + " " + aProperties_[8] + CRLF

	ENDCASE

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal

















