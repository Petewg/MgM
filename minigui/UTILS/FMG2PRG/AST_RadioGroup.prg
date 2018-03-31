 ************************************************************************************ 
 * Program Name....: AST_RadioGroup.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE RADIOGROUP Command to @ ... Command Syntax from HMG Form File
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
 * October 09, 2007 10:59:08 AM, Tabuk, KSA - Source Code completion.
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
** Function Name...: AST_RadioGroup()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_RADIOGROUP(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... RADIOGROUP Command Syntax
**
** Description.....: Converts DEFINE RADIOGROUP Command to @ ... RADIOGROUP Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_RadioGroup(cReadString,cTerminator)

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
	// HMG RADIOGROUP @... Command Snytax:
	// ------------------------------
	//	@ <nRow> ,<nCol> 
	//		RADIOGROUP <ControlName> 
	//		[ OF | PARENT <cParentWindowName> ]
	//		OPTIONS <acOptions> 
	//		[ VALUE <nValue> ]  
	//		[ WIDTH <nWidth> ]  
	//		[ SPACING <nSpacing> ] 
	//		[ FONT <cFontName> SIZE <nFontSize> ] 
	//		[ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
	//		[ TOOLTIP <cToolTipText> ] 
	//		[ BACKCOLOR <aBackColor> ]
	//		[ FONTCOLOR <aFontColor> ]
	//		[ ON CHANGE <OnChangeProcedure> | <bBlock> ] 
	//		[ TRANSPARENT ]
	//		[ HELPID <nHelpId> ] 
	//		[ INVISIBLE ]
	//		[ NOTABSTOP ]
	//		[ READONLY <alReadOnly> ]
	//		[ HORIZONTAL ]
	//
	//------------------------------------------------------------------------------------------------
	// @ <nRow> ,<nCol> RADIOGROUP <ControlName> OF <ParentWindowName>;
	// 	OPTIONS <acOptions> ;
	//		VALUE <nValue> WIDTH <nWidth> FONT <cFontName> SIZE <nFontSize> ON CHANGE <OnChangeProcedure | <bBlock>
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE RADIOGROUP",""))			   // DEFINE RADIOGROUP rdgrpOptions
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))								   // ROW    62
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))								   // COL    24
	aProperties_[ 4] := aDefCommandList_[ 4]                                                     // WIDTH  240                                                                                  
	aProperties_[ 5] := aDefCommandList_[ 5]                                                     // HEIGHT 50                                                                                   
	aProperties_[ 6] := aDefCommandList_[ 6]                                                     // OPTIONS { "Archive Existing Files and Make new one","No backup and Overwrite Existing File"}
	aProperties_[ 7] := aDefCommandList_[ 7]                                                     // VALUE 1                                                                                     
	aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"NAME",""))								   // FONTNAME "Arial"
	aProperties_[ 9] := ALLTRIM(STRTRAN(aDefCommandList_[ 9],"FONT",""))								   // FONTSIZE 9
	aProperties_[10] := aDefCommandList_[10]                                                     // TOOLTIP ""
	aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"ON","ON "))							   // ONCHANGE Nil
	aProperties_[12] := aDefCommandList_[12]                                                     // FONTBOLD .F.     
	aProperties_[13] := aDefCommandList_[13]                                                     // FONTITALIC .F.   
	aProperties_[14] := aDefCommandList_[14]                                                     // FONTUNDERLINE .F.
	aProperties_[15] := aDefCommandList_[15]                                                     // FONTSTRIKEOUT .F.
	aProperties_[16] := aDefCommandList_[16]                                                     // HELPID Nil       
	aProperties_[17] := aDefCommandList_[17]                                                     // TABSTOP .T.      
	aProperties_[18] := aDefCommandList_[18]                                                     // VISIBLE .T.      
	aProperties_[19] := aDefCommandList_[19]                                                     // TRANSPARENT .F.  
	aProperties_[20] := aDefCommandList_[20]                                                     // SPACING 25       
	aProperties_[21] := aDefCommandList_[21]                                                     // BACKCOLOR Nil    
	aProperties_[22] := aDefCommandList_[22]                                                     // FONTCOLOR Nil    
	aProperties_[23] := aDefCommandList_[23]                                                     // READONLY Nil     
	aProperties_[24] := aDefCommandList_[24]                                                     // HORIZONTAL .F.   
	aProperties_[25] := aDefCommandList_[25]                                                     // END RADIOGROUP   

	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " " + " RADIOGROUP " +;
				  aProperties_[1] + " " + " OF ~LDCS_Form;" + CRLF +;
				  LDCS_iLevel(3) + aProperties_[6] + ";" + CRLF +;
				  LDCS_iLevel(3) + aProperties_[7] + " " + aProperties_[4] + " " + ;
				  aProperties_[8] + " " + aProperties_[9] + " " + aProperties_[11] + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal
















