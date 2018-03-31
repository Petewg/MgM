 ************************************************************************************ 
 * Program Name....: AST_AnimateBox.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE ANIMATEBOX Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 * 						http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 * 						La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 13, 2007 08:07:36 PM, Tabuk, KSA
 * Last Updated....:
 *
 *
 * Revision History: 
 * -----------------
 * October 04, 2007 09:32:42 PM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 13, 2007 08:07:36 PM, Tabuk, KSA
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
** Function Name...: AST_AnimateBox()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_ANIMATEBOX(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... ANIMATEBOX Command Syntax
**
** Description.....: Converts DEFINE ANIMATEBOX Command to @ ... ANIMATEBOX Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_AnimateBox(cReadString,cTerminator)

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

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE ANIMATEBOX",""))	   // DEFINE ANIMATEBOX Animate_1
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))						   // ROW    220
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))						   // COL    290
	aProperties_[ 4] := aDefCommandList_[ 4]                                               // WIDTH  210     
	aProperties_[ 5] := aDefCommandList_[ 5]                                               // HEIGHT 60      
	aProperties_[ 6] := aDefCommandList_[ 6]                                               // FILE ""        
	aProperties_[ 7] := aDefCommandList_[ 7]                                               // HELPID Nil     
	aProperties_[ 8] := aDefCommandList_[ 8]                                               // TRANSPARENT .F.
	aProperties_[ 9] := aDefCommandList_[ 9]                                               // AUTOPLAY .F.   
	aProperties_[10] := aDefCommandList_[10]                                               // CENTER .F.     
	aProperties_[11] := aDefCommandList_[11]                                               // END ANIMATEBOX 

	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " ANIMATEBOX " +;
				  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[4] + " " + aProperties_[5] + " " +;
				  aProperties_[6] + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal
