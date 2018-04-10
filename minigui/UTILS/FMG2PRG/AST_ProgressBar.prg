 ************************************************************************************ 
 * Program Name....: AST_ProgressBar.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE PROGRESSBAR Command to @ ... Command Syntax from HMG Form File
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
 * October 09, 2007 01:05:47 PM, Tabuk, KSA - Source Code completion.
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
** Function Name...: AST_ProgressBar()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_PROGRESSBAR(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... PROGRESSBAR Command Syntax
**
** Description.....: Converts DEFINE PROGRESSBAR Command to @ ... PROGRESSBAR Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_ProgressBar(cReadString,cTerminator)

	LOCAL cRetVal := ""

	LOCAL aDefCommandList_ := {},;
			aProperties_	  := {}
	LOCAL sReadLine := ""
	
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
	// HMG PROGRESSBAR @... Command Snytax:
	// -------------------------------------
	//	@ <nRow> ,<nCol> 
	//		PROGRESSBAR<ControlName> 
	//		[ OF | PARENT <ParentWindowName> ]
	//		RANGE <nRangeMin> , <nRangeMax>
	//		[ WIDTH <nWidth> ]
	//		[ HEIGHT <nHeight> ]  
	//		[ TOOLTIP <cToolTipText> ]
	//		[ VERTICAL ]
	//		[ SMOOTH ]   
	//		[ HELPID <nHelpId> ] 
	//		[ BACKCOLOR <aBackColor> ]
	//		[ FORECOLOR <aForeColor> ]
	//
	//------------------------------------------------------------------------------------------------
	// @ <nRow> ,<nCol> PROGRESSBAR <ControlName> OF <ParentWindowName> RANGE <nRangeMin> , <nRangeMax>
	// 	WIDTH <nWidth> HEIGHT <nHeight> SMOOTH
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE PROGRESSBAR",""))			   // DEFINE PROGRESSBAR EbookMonitor
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))								   // ROW    40
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))								   // COL    30
	aProperties_[ 4] := aDefCommandList_[ 4]                                                     // WIDTH  280
	aProperties_[ 5] := aDefCommandList_[ 5]                                                     // HEIGHT 20 
	aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"RANGEMIN",""))						   // RANGEMIN 1
	aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"RANGEMAX",""))						   // RANGEMAX 10
	aProperties_[ 8] := aDefCommandList_[ 8]                                                     // VALUE 0        
	aProperties_[ 9] := aDefCommandList_[ 9]                                                     // TOOLTIP ""     
	aProperties_[10] := aDefCommandList_[10]                                                     // HELPID Nil     
	aProperties_[11] := aDefCommandList_[11]                                                     // VISIBLE .T.    
	aProperties_[12] := aDefCommandList_[12]                                                     // SMOOTH .F.     
	aProperties_[13] := aDefCommandList_[13]                                                     // VERTICAL .F.   
	aProperties_[14] := aDefCommandList_[14]                                                     // BACKCOLOR Nil  
	aProperties_[15] := aDefCommandList_[15]                                                     // FORECOLOR Nil  
	aProperties_[16] := aDefCommandList_[16]                                                     // END PROGRESSBAR

	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " PROGRESSBAR " +;
				  aProperties_[1] + " OF ~LDCS_Form RANGE " + aProperties_[6] + "," + aProperties_[7] + " " +;
				  aProperties_[4] + " " + aProperties_[5] + " SMOOTH" + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal






