 ************************************************************************************ 
 * Program Name....: AST_Grid.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE GRID Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 * 						http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 * 						La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: OOctober 13, 2007 07:00:44 PM, Tabuk, KSA
 * Last Updated....:
 *
* Revision History: 
 * -----------------
 * October 04, 2007 09:32:42 PM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 13, 2007 07:00:44 PM, Tabuk, KSA
 * ----------------------------------------
 * 	Original Source Code - Simplified syntax just to format it with @...command
 *
 *************************************************************************************/


#include "minigui.ch"
*#include "inkey.ch"
*#include "common.ch"
#include "dale-aid.ch"

*#define CRLF  HB_OSNEWLINE()

**************************************************************************************
** Function Name...: AST_Grid()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_GRID(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
** 								 anExp2 => is a numeric array containing the indention in terms
** 												  of spaces 
** 								 cExp3  => is the termination string to signal the end of
** 												  define command
**
** Returns.........: cRetVal => contains the converted @ ... GRID Command Syntax
**
** Description.....: Converts DEFINE GRID Command to @ ... GRID Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
** 							1. oFileHandle - Object Container for TFileRead() CLASS
**								2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_Grid(cReadString,cTerminator)

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
	// HMG GRID @... Command Snytax:
	// ------------------------------
	//	@ <nRow> ,<nCol>
	//		GRID <ControlName> 
	//		[ OF | PARENT <ParentWindowName> ]
	//		WIDTH <nWidth> 
	//		HEIGHT <nHeight> 
	//		HEADERS <acHeaders> 
	//		WIDTHS <anWidths> 
	//		[ ITEMS <acItems> ] 
	//		[ VALUE <nValue> ] 
	//		[ FONT <cFontname> SIZE <nFontsize> ]
	//		[ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
	//		[ TOOLTIP <cToolTipText> ] 
	//		[ BACKCOLOR <aBackColor> ]
	//		[ FONTCOLOR <aFontColor> ]
	//		[ DYNAMICBACKCOLOR <aDynamicBackColor> ]
	//		[ DYNAMICFORECOLOR <aDynamicBackColor> ]
	//		[ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
	//		[ ON CHANGE <OnChangeProcedure> | <bBlock> ]  
	//		[ ON LOSTFOCUS <OnGotFocusProcedur> | <bBlock> ]
	//		[ [ ON DBLCLICK <OnDblClickProcedure> | <bBlock> ]  | 
	//		[ EDIT | ALLOWEDIT ] ]
	//		[ COLUMNCONTROLS {aControlDef1,aControlDef2,...aControlDefN}
	//		[ COLUMNVALID {bValid1,bValid2,...bValidN}
	//		[ COLUMNWHEN {bWhen1,bWhen2,...bWhenN}
	//		[ ON HEADCLICK <abBlock> ]
	//		[ VIRTUAL ]
	//		[ ITEMCOUNT <nItemCount> ]
	//		[ ON QUERYDATA <OnQueryDataProcedure> | <bBlock> ]
	//		[ MULTISELECT ]  
	//		[ NOLINES ]  
	//		[ NOHEADERS ]
	//		[ IMAGE <acImageNames> ]  
	//		[ JUSTIFY <anJustifyValue> ]
	//		[ HELPID <nHelpId> ] 
	//		[ BREAK ]
	//
	//------------------------------------------------------------------------------------------------
	// @ <nRow> ,<nCol> GRID <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>;
	// 	HEADERS <acHeaders> WIDTHS <anWidths> ITEMS <acItems> VALUE <nValue>
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////

	aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE GRID",""))   // DEFINE GRID Grid_1
	aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))			   // ROW    20
	aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))			   // COL    190
	aProperties_[ 4] := aDefCommandList_[ 4]                                      // WIDTH  160    
	aProperties_[ 5] := aDefCommandList_[ 5]                                      // HEIGHT 140    
	aProperties_[ 6] := aDefCommandList_[ 6]                                      // ITEMS { {""} }
	aProperties_[ 7] := aDefCommandList_[ 7]                                      // VALUE 0       
	aProperties_[ 8] := aDefCommandList_[ 8]                                      // WIDTHS { 0 }  
	aProperties_[ 9] := aDefCommandList_[ 9]                                      // HEADERS {''}  
	aProperties_[10] := ALLTRIM(STRTRAN(aDefCommandList_[10],"NAME",""))			   // FONTNAME "Arial"
	aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"FONT",""))			   // FONTSIZE 9
	aProperties_[12] := aDefCommandList_[12]                                      // TOOLTIP ""          
	aProperties_[13] := aDefCommandList_[13]                                      // ONCHANGE Nil        
	aProperties_[14] := aDefCommandList_[14]                                      // ONGOTFOCUS Nil      
	aProperties_[15] := aDefCommandList_[15]                                      // ONLOSTFOCUS Nil     
	aProperties_[16] := aDefCommandList_[16]                                      // FONTBOLD .F.        
	aProperties_[17] := aDefCommandList_[17]                                      // FONTITALIC .F.      
	aProperties_[18] := aDefCommandList_[18]                                      // FONTUNDERLINE .F.   
	aProperties_[19] := aDefCommandList_[19]                                      // FONTSTRIKEOUT .F.   
	aProperties_[20] := aDefCommandList_[20]                                      // ONDBLCLICK Nil      
	aProperties_[21] := aDefCommandList_[21]                                      // ONHEADCLICK Nil     
	aProperties_[22] := aDefCommandList_[22]                                      // ONQUERYDATA Nil     
	aProperties_[23] := aDefCommandList_[23]                                      // MULTISELECT .F.     
	aProperties_[24] := aDefCommandList_[24]                                      // ALLOWEDIT .F.       
	aProperties_[25] := aDefCommandList_[25]                                      // VIRTUAL .F.         
	aProperties_[26] := aDefCommandList_[26]                                      // DYNAMICBACKCOLOR Nil
	aProperties_[27] := aDefCommandList_[27]                                      // DYNAMICFORECOLOR Nil
	aProperties_[28] := aDefCommandList_[28]                                      // COLUMNWHEN Nil      
	aProperties_[29] := aDefCommandList_[29]                                      // COLUMNVALID Nil     
	aProperties_[30] := aDefCommandList_[30]                                      // COLUMNCONTROLS Nil  
	aProperties_[31] := aDefCommandList_[31]                                      // SHOWHEADERS .T.     
	aProperties_[32] := aDefCommandList_[32]                                      // NOLINES .F.         
	aProperties_[33] := aDefCommandList_[33]                                      // HELPID Nil          
	aProperties_[34] := aDefCommandList_[34]                                      // IMAGE Nil           
	aProperties_[35] := aDefCommandList_[35]                                      // JUSTIFY Nil         
	aProperties_[36] := aDefCommandList_[36]                                      // ITEMCOUNT Nil       
	aProperties_[37] := aDefCommandList_[37]                                      // BACKCOLOR NIL       
	aProperties_[38] := aDefCommandList_[38]                                      // FONTCOLOR NIL       
	aProperties_[39] := aDefCommandList_[39]                                      // END GRID            


	*- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

	// @ <nRow> ,<nCol> GRID <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>;
	// 	HEADERS <acHeaders> WIDTHS <anWidths> ITEMS <acItems> VALUE <nValue>

	cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " GRID " + ;
				  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[4] + " " + aProperties_[5] + ";" + CRLF +;
				  LDCS_iLevel(3) + aProperties_[9] + " " + aProperties_[8] + " " + aProperties_[6] + ;
				  " " + aProperties_[7] + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

	RETURN cRetVal


























