 ************************************************************************************ 
 * Program Name....: AST_Player.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE PLAYER Command to @ ... Command Syntax from HMG Form File
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
 * October 14, 2007 12:40:43 AM, Tabuk, KSA - Source Code completion.
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
** Function Name...: AST_Player()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_PLAYER(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... PLAYER Command Syntax
**
** Description.....: Converts DEFINE PLAYER Command to @ ... PLAYER Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_Player(cReadString,cTerminator)

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
	// HMG PLAYER @... Command Snytax:
	// ------------------------------
	//	@ <nRow> ,<nCol> 
	//		PLAYER <ControlName> 
	//		[ OF | PARENT <ParentWindowName> ]
	//		WIDTH <nWidth> 
	//		HEIGHT <nHeight> 
	//		FILE <cFileName> 
	//		[ NOAUTOSIZEWINDOW ] 
	//		[ NOAUTOSIZEMOVIE ] 
	//		[ NOERRORDLG ] 
	//		[ NOMENU ] 
	//		[ NOOPEN ] 
	//		[ NOPLAYBAR ] 
	//		[ SHOWALL ] 
	//		[ SHOWMODE ] 
	//		[ SHOWNAME ] 
	//		[ SHOWPOSITION ] 
	//		[ HELPID <nHelpId> ] 
	//
	//------------------------------------------------------------------------------------------------
	// La DALE-Aid Creative Solutions @ ... Command PLAYER Syntax:
	// ==========================================================
	// @ <nRow> ,<nCol> PLAYER <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>
	// 	FILE <cFileName>
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE PLAYER",""))		   // DEFINE PLAYER Player_1
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))					   // ROW    50
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))					   // COL    100
	aProperties_[ 4] := aDefCommandList_[ 4]                                            // WIDTH  120          
	aProperties_[ 5] := aDefCommandList_[ 5]                                            // HEIGHT 120          
	aProperties_[ 6] := aDefCommandList_[ 6]                                            // FILE ""             
	aProperties_[ 7] := aDefCommandList_[ 7]                                            // HELPID Nil          
	aProperties_[ 8] := aDefCommandList_[ 8]                                            // NOAUTOSIZEWINDOW .F.
	aProperties_[ 9] := aDefCommandList_[ 9]                                            // NOAUTOSIZEMOVIE .F. 
	aProperties_[10] := aDefCommandList_[10]                                            // NOERRORDLG .F.      
	aProperties_[11] := aDefCommandList_[11]                                            // NOMENU .F.          
	aProperties_[12] := aDefCommandList_[12]                                            // NOOPEN .F.          
	aProperties_[13] := aDefCommandList_[13]                                            // NOPLAYBAR .F.       
	aProperties_[14] := aDefCommandList_[14]                                            // SHOWALL .F.         
	aProperties_[15] := aDefCommandList_[15]                                            // SHOWMODE .F.        
	aProperties_[16] := aDefCommandList_[16]                                            // SHOWNAME .F.        
	aProperties_[17] := aDefCommandList_[17]                                            // SHOWPOSITION .F.    
	aProperties_[18] := aDefCommandList_[18]                                            // END PLAYER          

	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " PLAYER " +;
				  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[4] + " " + aProperties_[5] + " " +;
				  aProperties_[6] + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal








