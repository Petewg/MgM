 ************************************************************************************ 
 * Program Name....: AST_CheckBox.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE CHECKBOX Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 * 						http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 * 						La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 07, 2007 03:03:57 PM, Tabuk, KSA
 * Last Updated....:
 *
*
 * Revision History: 
 * -----------------
 * October 04, 2007 09:32:42 PM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 07, 2007 03:03:57 PM, Tabuk, KSA
 * ----------------------------------------
 * 	Original Source Code
 *
 *************************************************************************************/


#include "minigui.ch"
*#include "inkey.ch"
*#include "common.ch"
#include "dale-aid.ch"

*#define CRLF  HB_OSNEWLINE()


***************************************************************************************
function AST_CheckBox(cReadString,cTerminator)

	LOCAL cRetVal := ""

	LOCAL aDefCommandList_ := {},;
			aProperties_	  := {}
			
	LOCAL sReadLine := ""

	LOCAL cSyntaxType := "MEMVAR"	

	AADD(aDefCommandList_, cReadString)
	WHILE oFileHandle:MORETOREAD()
		sReadLine := ALLTRIM(oFileHandle:READLINE())
		
		IF SUBSTR(sReadLine, 1, 5) == "FIELD"
			cSyntaxType := "DBFIELD"
		ENDIF
		
		AADD(aDefCommandList_, sReadLine)
		IF ALLTRIM(sReadLine) == cTerminator
			EXIT
		ENDIF
	ENDDO

	aProperties_ := ARRAY(LEN(aDefCommandList_)) 

	//////////////////////////////////////////////////////////////////////////////////////////////////
	// HMG CHECKBOX @... Command Snytax:
	// ------------------------------
	//	@ <nRow> ,<nCol> 
	//			CHECKBOX <ControlName> 
	//			[ OF | PARENT <ParentWindowName> ]
	//			CAPTION <cCaption> 
	//			[ WIDTH <nWidth>] [ HEIGHT <nHeight> ] 
	//			[ VALUE <lValue> ] 
	//			[ FIELD <FieldName> ]
	//			[ FONT <cFontName> SIZE <nFontSize> ]
	//			[ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
	//			[ TOOLTIP <cToolTipText> ]
	//			[ BACKCOLOR <aBackColor> ]
	//			[ FONTCOLOR <aFontColor> ]
	//			[ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
	//			[ ON CHANGE <OnChangeProcedure> | <bBlock> ] 
	//			[ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
	//			[ TRANSPARENT ]
	//			[ HELPID <nHelpId> ] 
	//			[ INVISIBLE ] 
	//			[ NOTABSTOP ]
	//
	//------------------------------------------------------------------------------------------------
	// DBF and Non-DBF CHECKBOX SYNTAX:
	// --------------------------------
	// @ <nRow> ,<nCol> LABEL <ControlName> OF <ParentWindowName>;
	// 	CAPTION <cCaption>;	
	//		WIDTH <nWidth> HEIGHT <nHeight> VALUE <lValue> [ FIELD <FieldName> ]
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	DO CASE
		CASE cSyntaxType == "MEMVAR"
			aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE CHECKBOX",""))	   // DEFINE CHECKBOX ckbNonDbf
			aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))				   	// ROW    60
			aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))					   // COL    120
			aProperties_[ 4] := aDefCommandList_[ 4]                                            // WIDTH  160                 
			aProperties_[ 5] := aDefCommandList_[ 5]                                            // HEIGHT 30                  
			aProperties_[ 6] := aDefCommandList_[ 6]                                            // CAPTION "Check Box Non-DBF"
			aProperties_[ 7] := aDefCommandList_[ 7]                                            // VALUE .F.                  
			aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"NAME",""))					   // FONTNAME "Arial"
			aProperties_[ 9] := ALLTRIM(STRTRAN(aDefCommandList_[ 9],"FONT",""))					   // FONTSIZE 9
			aProperties_[10] := aDefCommandList_[10]                                            // TOOLTIP ""       
			aProperties_[11] := aDefCommandList_[11]                                            // ONCHANGE Nil     
			aProperties_[12] := aDefCommandList_[12]                                            // ONGOTFOCUS Nil   
			aProperties_[13] := aDefCommandList_[13]                                            // ONLOSTFOCUS Nil  
			aProperties_[14] := aDefCommandList_[14]                                            // FONTBOLD .F.     
			aProperties_[15] := aDefCommandList_[15]                                            // FONTITALIC .F.   
			aProperties_[16] := aDefCommandList_[16]                                            // FONTUNDERLINE .F.
			aProperties_[17] := aDefCommandList_[17]                                            // FONTSTRIKEOUT .F.
			aProperties_[18] := aDefCommandList_[18]                                            // BACKCOLOR NIL    
			aProperties_[19] := aDefCommandList_[19]                                            // FONTCOLOR NIL    
			aProperties_[20] := aDefCommandList_[20]                                            // HELPID Nil       
			aProperties_[21] := aDefCommandList_[21]                                            // TABSTOP .T.      
			aProperties_[22] := aDefCommandList_[22]                                            // VISIBLE .T.      
			aProperties_[23] := aDefCommandList_[23]                                            // TRANSPARENT .F.  
			aProperties_[24] := aDefCommandList_[24]                                            // END CHECKBOX     
                                   
			*- pad short numbers row,column
		   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
		   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)
                                   
			cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " CHECKBOX " + ;
						  aProperties_[1] + " OF ~LDCS_Form " + ";" + CRLF +;
						  LDCS_iLevel(3) + aProperties_[6] + ";" + CRLF +;
						  LDCS_iLevel(3) + aProperties_[4] + " " + aProperties_[5] + " " +;
						  aProperties_[7] + CRLF

                                   
		CASE cSyntaxType == "DBFIELD"
			aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE CHECKBOX",""))	   // DEFINE CHECKBOX ckbDbf
			aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))					   // ROW    110
			aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))					   // COL    120
			aProperties_[ 4] := aDefCommandList_[ 4]                                            // WIDTH  230                             
			aProperties_[ 5] := aDefCommandList_[ 5]                                            // HEIGHT 30                              
			aProperties_[ 6] := aDefCommandList_[ 6]                                            // CAPTION "Check Box DBF Reference Field"
			aProperties_[ 7] := aDefCommandList_[ 7]                                            // VALUE .F.                              
			aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"NAME",""))					   // FONTNAME "Arial"
			aProperties_[ 9] := ALLTRIM(STRTRAN(aDefCommandList_[ 9],"FONT",""))					   // FONTSIZE 9
			aProperties_[10] := aDefCommandList_[10]                                            // TOOLTIP ""       
			aProperties_[11] := aDefCommandList_[11]                                            // ONCHANGE Nil     
			aProperties_[12] := aDefCommandList_[12]                                            // ONGOTFOCUS Nil   
			aProperties_[13] := aDefCommandList_[13]                                            // ONLOSTFOCUS Nil  
			aProperties_[14] := aDefCommandList_[14]                                            // FONTBOLD .F.     
			aProperties_[15] := aDefCommandList_[15]                                            // FONTITALIC .F.   
			aProperties_[16] := aDefCommandList_[16]                                            // FONTUNDERLINE .F.
			aProperties_[17] := aDefCommandList_[17]                                            // FONTSTRIKEOUT .F.
			aProperties_[18] := aDefCommandList_[18]                                            // FIELD MYFIELD->F1
			aProperties_[19] := aDefCommandList_[19]                                            // BACKCOLOR NIL    
			aProperties_[20] := aDefCommandList_[20]                                            // FONTCOLOR NIL    
			aProperties_[21] := aDefCommandList_[21]                                            // HELPID Nil       
			aProperties_[22] := aDefCommandList_[22]                                            // TABSTOP .T.      
			aProperties_[23] := aDefCommandList_[23]                                            // VISIBLE .T.      
			aProperties_[24] := aDefCommandList_[24]                                            // TRANSPARENT .F.  
			aProperties_[25] := aDefCommandList_[25]                                            // END CHECKBOX     

			*- pad short numbers row,column
		   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
		   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

			cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " CHECKBOX " + ;
						  aProperties_[1] + " OF ~LDCS_Form " + ";" + CRLF +;
						  LDCS_iLevel(3) + aProperties_[6] + ";" + CRLF +;
						  LDCS_iLevel(3) + aProperties_[4] + " " + aProperties_[5] + " " +;
						  aProperties_[7] + " " + aProperties_[18] + CRLF

	ENDCASE

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal















