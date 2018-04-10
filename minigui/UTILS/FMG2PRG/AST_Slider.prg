 ************************************************************************************ 
 * Program Name....: AST_Slider.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE SLIDER Command to @ ... Command Syntax from HMG Form File
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
 * Revision History: 
 * -----------------
 * October 04, 2007 09:32:42 PM, Tabuk, KSA - Source Code completion.
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
** Function Name...: AST_Slider()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_SLIDER(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... SLIDER Command Syntax
**
** Description.....: Converts DEFINE SLIDER Command to @ ... SLIDER Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_Slider(cReadString,cTerminator)

	LOCAL cRetVal := ""

	LOCAL aDefCommandList_ := {},;
			aProperties_	  := {}

	LOCAL sReadLine := ""
	
	LOCAL cSyntax := "HORIZONTAL"

	AADD(aDefCommandList_, cReadString)
	WHILE oFileHandle:MORETOREAD()
		sReadLine := ALLTRIM(oFileHandle:READLINE())

		IF SUBSTR(sReadLine,1,8) == "VERTICAL"
			cSyntax := "VERTICAL"
		ENDIF
		
		AADD(aDefCommandList_, sReadLine)
		IF ALLTRIM(sReadLine) == cTerminator
			EXIT
		ENDIF
	ENDDO

	aProperties_ := ARRAY(LEN(aDefCommandList_)) 

	//////////////////////////////////////////////////////////////////////////////////////////////////
	// HMG SLIDER @... Command Snytax:
	// ------------------------------
	//	@ <nRow> ,<nCol> 
	//		SLIDER <ControlName> 
	//		[ OF | PARENT <ParentWindowName> ]
	//		RANGE <nRangeMin> , <nRangeMax>
	//		[ VALUE <nValue> ] 
	//		[ WIDTH <nWidth> ]
	//		[ HEIGHT <nHeight> ]
	//		[ TOOLTIP <cToolTipText> ] 
	//		[ ON CHANGE <OnChangeProcedure> | <bBlock> ] 
	//		[ VERTICAL ]
	//		[ NOTICKS ]
	//		[ BOTH ]
	//		[ TOP ]
	//		[ LEFT ] 
	//		[ HELPID <nHelpId> ] 
	//		[ INVISIBLE ]
	//		[ NOTABSTOP ]
	//
	//------------------------------------------------------------------------------------------------
	// @ <nRow> ,<nCol> SLIDER <ControlName> OF <ParentWindowName> RANGE <nRangeMin> , <nRangeMax>;
	// 	VALUE <nValue> WIDTH <nWidth> HEIGHT <nHeight> TOOLTIP <cToolTipText> ON CHANGE <OnChangeProcedure>	
	//
	// @ <nRow> ,<nCol> SLIDER <ControlName> OF <ParentWindowName> RANGE <nRangeMin> , <nRangeMax>;        
	// 	VALUE <nValue> WIDTH <nWidth> HEIGHT <nHeight> TOOLTIP <cToolTipText>; 
	//    ON CHANGE <OnChangeProcedure> VERTICAL
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	DO CASE
		CASE cSyntax == "HORIZONTAL"     
			aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE SLIDER",""))  		 // DEFINE SLIDER Slider_1
			aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))						 // ROW    110
			aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))					    // COL    40
			aProperties_[ 4] := aDefCommandList_[ 4]                                             // WIDTH  30 
			aProperties_[ 5] := aDefCommandList_[ 5]                                             // HEIGHT 110
			aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"RANGEMIN",""))   			 // RANGEMIN 1
			aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"RANGEMAX",""))			    // RANGEMAX 10
			aProperties_[ 8] := aDefCommandList_[ 8]                                             // VALUE 0   
			aProperties_[ 9] := aDefCommandList_[ 9]                                             // TOOLTIP ""
			aProperties_[10] := ALLTRIM(STRTRAN(aDefCommandList_[10],"ON","ON "))				    // ONCHANGE Nil
			aProperties_[11] := aDefCommandList_[11]                                             // HELPID Nil   
			aProperties_[12] := aDefCommandList_[12]                                             // TABSTOP .T.  
			aProperties_[13] := aDefCommandList_[13]                                             // VISIBLE .T.  
			aProperties_[14] := aDefCommandList_[14]                                             // BACKCOLOR NIL
			aProperties_[15] := aDefCommandList_[15]                                             // END SLIDER   

			*- pad short numbers row,column
		   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
		   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

			////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// @ <nRow> ,<nCol> SLIDER <ControlName> OF <ParentWindowName> RANGE <nRangeMin> , <nRangeMax>;
			// 	VALUE <nValue> WIDTH <nWidth> HEIGHT <nHeight> TOOLTIP <cToolTipText> ON CHANGE <OnChangeProcedure>
			////////////////////////////////////////////////////////////////////////////////////////////////////////////

			cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " SLIDER " +;
						  aProperties_[1] + " OF ~LDCS_Form RANGE " + aProperties_[6] + "," + aProperties_[7] + ";" +;
						  CRLF +;
						  LDCS_iLevel(3) + aProperties_[8] + " " + aProperties_[4] + " " + aProperties_[5] + " " +;
						  aProperties_[9] + " " + aProperties_[10] + CRLF


		CASE cSyntax == "VERTICAL"
			aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE SLIDER",""))	   	// DEFINE SLIDER Slider_1
			aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))					   // ROW    110
			aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))					   // COL    40
			aProperties_[ 4] := aDefCommandList_[ 4]                                            // WIDTH  30 
			aProperties_[ 5] := aDefCommandList_[ 5]                                            // HEIGHT 110
			aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"RANGEMIN",""))			   // RANGEMIN 1
			aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"RANGEMAX",""))			   // RANGEMAX 10
			aProperties_[ 8] := aDefCommandList_[ 8]                                            // VALUE 0   
			aProperties_[ 9] := aDefCommandList_[ 9]                                            // TOOLTIP ""
			aProperties_[10] := ALLTRIM(STRTRAN(aDefCommandList_[10],"ON","ON "))				   // ONCHANGE Nil
			aProperties_[11] := aDefCommandList_[11]                                            // HELPID Nil   
			aProperties_[12] := aDefCommandList_[12]                                            // TABSTOP .T.  
			aProperties_[13] := aDefCommandList_[13]                                            // VISIBLE .T.  
			aProperties_[14] := aDefCommandList_[14]                                            // VERTICAL .T. 
			aProperties_[15] := aDefCommandList_[15]                                            // BACKCOLOR NIL
			aProperties_[16] := aDefCommandList_[16]                                            // END SLIDER   

			*- pad short numbers row,column
		   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
		   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

			////////////////////////////////////////////////////////////////////////////////////////////////
			// @ <nRow> ,<nCol> SLIDER <ControlName> OF <ParentWindowName> RANGE <nRangeMin> , <nRangeMax>;        
			// 	VALUE <nValue> WIDTH <nWidth> HEIGHT <nHeight> TOOLTIP <cToolTipText>; 
			//    ON CHANGE <OnChangeProcedure> VERTICAL
			////////////////////////////////////////////////////////////////////////////////////////////////

			cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " SLIDER " +;
						  aProperties_[1] + " OF ~LDCS_Form RANGE " + aProperties_[6] + "," + aProperties_[7] + ";" +;
						  CRLF +;
						  LDCS_iLevel(3) + aProperties_[8] + " " + aProperties_[4] + " " + aProperties_[5] + " " + ;
						  aProperties_[9] + ";" + CRLF +;
						  LDCS_iLevel(3) + aProperties_[10] + " VERTICAL" + CRLF

	ENDCASE


	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal







