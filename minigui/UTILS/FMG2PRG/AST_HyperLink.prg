 ************************************************************************************ 
 * Program Name....: AST_HyperLink.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: 
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
 *
 * Revision History: 
 * -----------------
 * October 07, 2007 02:41:23 PM, Tabuk, KSA - Source Code completion.
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
** Function Name...: AST_HyperLink()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_HYPERLINK(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... HYPERLINK Command Syntax
**
** Description.....: Converts DEFINE HYPERLINK Command to @ ... HYPERLINK Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_HyperLink(cReadString,cTerminator)

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
	// HMG HYPERLINK @... Command Snytax:
	// ------------------------------
	//	@ <nRow>,<nCol> HYPERLINK <ControlName> 
	//		[ OF <ParentWindowName> ]
	//		[ VALUE <cControlValue> ] 
	//		[ ADDRESS <cLinkAddress>]
	//		[ WIDTH <nWidth> ] 
	//		[ HEIGHT <nHeight> ] 
	//		[ AUTOSIZE ] 
	//		[ FONT <cFontName> ] 
	//		[ SIZE <nFontSize> ] 
	//		[ BOLD ] 
	//		[ ITALIC ] 
	//		[ TOOLTIP <cToolTipText> ] 
	//		[ BACKCOLOR <anBackColor> ] 
	//		[ FONTCOLOR <anFontColor> ]
	//		[ RIGHTALIGN ] 
	//		[ CENTERALIGN ]
	//		[ HELPID <nHelpId> ] 
	//		[ HANDCURSOR ]
	//		[ INVISIBLE ] 
	//------------------------------------------------------------------------------------------------
	// @ <nRow> ,<nCol> LABEL <ControlName> OF <ParentWindowName> VALUE <cValue>;
	// 	ADDRESS <cLinkAddress> WIDTH <nWidth> HEIGHT <nHeight> FONT <cFontName> SIZE <nFontSize> HANDCURSOR
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE HYPERLINK",""))   // DEFINE HYPERLINK url_DaleAid
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))					  // ROW    170
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))				     // COL    210
	aProperties_[ 4] := aDefCommandList_[ 4]                                           // WIDTH  160                                     
	aProperties_[ 5] := aDefCommandList_[ 5]                                           // HEIGHT 20                                      
	aProperties_[ 6] := aDefCommandList_[ 6]                                           // VALUE "http://www.dale-aid.com.ph"             
	aProperties_[ 7] := aDefCommandList_[ 7]                                           // ADDRESS "http://harbourminigui.googlepages.com"
	aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"NAME",""))					  // FONTNAME "Arial"
	aProperties_[ 9] := ALLTRIM(STRTRAN(aDefCommandList_[ 9],"FONT",""))					  // FONTSIZE 9
	aProperties_[10] := aDefCommandList_[10]                                           // TOOLTIP ""       
	aProperties_[11] := aDefCommandList_[11]                                           // FONTBOLD .F.     
	aProperties_[12] := aDefCommandList_[12]                                           // FONTITALIC .F.   
	aProperties_[13] := aDefCommandList_[13]                                           // FONTUNDERLINE .F.
	aProperties_[14] := aDefCommandList_[14]                                           // FONTSTRIKEOUT .F.
	aProperties_[15] := aDefCommandList_[15]                                           // AUTOSIZE .F.     
	aProperties_[16] := aDefCommandList_[16]                                           // HELPID Nil       
	aProperties_[17] := aDefCommandList_[17]                                           // VISIBLE .T.      
	aProperties_[18] := aDefCommandList_[18]                                           // HANDCURSOR .F.   
	aProperties_[19] := aDefCommandList_[19]                                           // BACKCOLOR Nil    
	aProperties_[20] := aDefCommandList_[20]                                           // FONTCOLOR Nil    
	aProperties_[21] := aDefCommandList_[21]                                           // END HYPERLINK	   

	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " HYPERLINK " +;
				  aProperties_[6] + ";" + CRLF +;
				  LDCS_iLevel(3) + aProperties_[7] + " " + aProperties_[4] + " " + aProperties_[5] + " " +;
				  aProperties_[8] + " " + aProperties_[9] + " HANDCURSOR" + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal







