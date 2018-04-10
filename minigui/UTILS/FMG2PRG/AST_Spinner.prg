 ************************************************************************************ 
 * Program Name....: AST_Spinner.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE SPINNER Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 * 						http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 * 						La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 13, 2007 07:27:49 PM, Tabuk, KSA
 * Last Updated....:
 *
 * Revision History: 
 * -----------------
 * October 13, 2007 07:49:52 PM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 13, 2007 07:27:49 PM, Tabuk, KSA
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
** Function Name...: AST_Spinner()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_SPINNER(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... SPINNER Command Syntax
**
** Description.....: Converts DEFINE SPINNER Command to @ ... SPINNER Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_Spinner(cReadString,cTerminator)

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
	// HMG SPINNER @... Command Snytax:
	// ------------------------------
	//	@ <nRow> ,<nCol> 
	//		SPINNER <ControlName> 
	//		[ OF | PARENT <ParentWindowName> ]
	//		RANGE <nRangeMin> , <nRangeMax>
	//		[ VALUE <nValue> ] 
	//		[ WIDTH <nWidth> ]  
	//		[ HEIGHT <nHeight> ]
	//		[ FONT <cFontName> SIZE <nFontSize> ] 
	//		[ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
	//		[ TOOLTIP <cToolTipText> ] 
	//		[ BACKCOLOR <aBackColor> ]
	//		[ FONTCOLOR <aFontColor> ]
	//		[ ON GOTFOCUS <OnGotFocusProcedure> | <bBlock> ] 
	//		[ ON CHANGE <OnChangeProcedure> | <bBlock> ]
	//		[ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
	//		[ HELPID <nHelpId> ] 
	//		[ INVISIBLE ]
	//		[ NOTABSTOP ]
	//		[ WRAP ]
	//		[ READONLY ]
	//		[ INCREMENT <nIncrement> ] 
	//
	//------------------------------------------------------------------------------------------------
	// @ <nRow> ,<nCol> SPINNER <ControlName> OF <ParentWindowName> RANGE <nRangeMin> , <nRangeMax>
	// 	VALUE <nValue> WIDTH <nWidth> HEIGHT <nHeight>;
	//		FONT <cFontName> SIZE <nFontSize> ON CHANGE <OnChangeProcedure> | <bBlock>
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE SPINNER",""))   // DEFINE SPINNER Spinner_1
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))				   // ROW    70
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))				   // COL    30
	aProperties_[ 4] := aDefCommandList_[ 4]                                         // WIDTH  120
	aProperties_[ 5] := aDefCommandList_[ 5]                                         // HEIGHT 24 
	aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"RANGEMIN",""))		   // RANGEMIN 1
	aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"RANGEMAX",""))		   // RANGEMAX 10
	aProperties_[ 8] := aDefCommandList_[ 8]                                         // VALUE 0
	aProperties_[ 9] := ALLTRIM(STRTRAN(aDefCommandList_[ 9],"NAME",""))				   // FONTNAME "Arial"
	aProperties_[10] := ALLTRIM(STRTRAN(aDefCommandList_[10],"FONT",""))				   // FONTSIZE 9
	aProperties_[11] := aDefCommandList_[11]                                         // TOOLTIP ""
	aProperties_[12] := ALLTRIM(STRTRAN(aDefCommandList_[12],"ON","ON "))			   // ONCHANGE Nil
	aProperties_[13] := aDefCommandList_[13]                                         // ONGOTFOCUS Nil   
	aProperties_[14] := aDefCommandList_[14]                                         // ONLOSTFOCUS Nil  
	aProperties_[15] := aDefCommandList_[15]                                         // FONTBOLD .F.     
	aProperties_[16] := aDefCommandList_[16]                                         // FONTITALIC .F.   
	aProperties_[17] := aDefCommandList_[17]                                         // FONTUNDERLINE .F.
	aProperties_[18] := aDefCommandList_[18]                                         // FONTSTRIKEOUT .F.
	aProperties_[19] := aDefCommandList_[19]                                         // HELPID Nil       
	aProperties_[20] := aDefCommandList_[20]                                         // TABSTOP .T.      
	aProperties_[21] := aDefCommandList_[21]                                         // VISIBLE .T.      
	aProperties_[22] := aDefCommandList_[22]                                         // WRAP .F.         
	aProperties_[23] := aDefCommandList_[23]                                         // READONLY .F.     
	aProperties_[24] := aDefCommandList_[24]                                         // INCREMENT 1      
	aProperties_[25] := aDefCommandList_[25]                                         // BACKCOLOR NIL    
	aProperties_[26] := aDefCommandList_[26]                                         // FONTCOLOR NIL    
	aProperties_[27] := aDefCommandList_[27]                                         // END SPINNER      
	
	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " SPINNER " + ;
				  aProperties_[1] + " OF ~LDCS_Form RANGE " + aProperties_[6] + "," + aProperties_[7] + ";" + CRLF +;
				  LDCS_iLevel(3) + aProperties_[8] + " " + aProperties_[4] + " " + aProperties_[5] + ";" + CRLF +;
				  LDCS_iLevel(3) + aProperties_[9] + " " + aProperties_[10] + " " + aProperties_[12] + CRLF


	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal
























