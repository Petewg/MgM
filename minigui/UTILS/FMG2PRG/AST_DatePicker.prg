 ************************************************************************************ 
 * Program Name....: AST_DatePicker.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE DATEPICKER Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 *                   http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 *                   La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 07, 2007 09:19:49 PM, Tabuk, KSA
 * Last Updated....:
 *
 *
 * Revision History: 
 * -----------------
 * October 09, 2007 01:29:58 AM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 07, 2007 09:19:49 PM, Tabuk, KSA
 * ----------------------------------------
 *    Original Source Code
 *
 *************************************************************************************/


#include "minigui.ch"
*#include "inkey.ch"
*#include "common.ch"
#include "dale-aid.ch"

*#define CRLF  HB_OSNEWLINE()

**************************************************************************************
** Function Name...: AST_DatePicker()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_DATEPICKER(cExp1, anExp2)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file

**                          cExp2  => is the termination string to signal the end of
**                                       define command
**
** Returns.........: cRetVal => contains the converted @ ... DATEPICKER Command Syntax
**
** Description.....: Converts DEFINE DATEPICKER Command to @ ... DATEPICKER Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
**                      1. oFileHandle - Object Container for TFileRead() CLASS
**                      2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_DatePicker(cReadString,cTerminator)

   LOCAL cRetVal := ""

   LOCAL aDefCommandList_ := {},;
         aProperties_     := {}
         
   LOCAL sReadLine := ""
   
   LOCAL cSyntax := "MEMVAR"

   AADD(aDefCommandList_, cReadString)
   WHILE oFileHandle:MORETOREAD()
      sReadLine := ALLTRIM(oFileHandle:READLINE())
      
      IF SUBSTR(sReadLine,1,5) == "FIELD"
         cSyntax := "DBF"
      ENDIF
      
      AADD(aDefCommandList_, sReadLine)
      IF ALLTRIM(sReadLine) == cTerminator
         EXIT
      ENDIF
   ENDDO

   aProperties_ := ARRAY(LEN(aDefCommandList_)) 

   //////////////////////////////////////////////////////////////////////////////////////////////////
   // HMG LABEL @... Command Snytax:
   // ------------------------------
   // @ <nRow> ,<nCol> 
   //    DATEPICKER<ControlName> 
   //    [ OF | PARENT <cParentWindowName> ]
   //    [ VALUE <dValue> ] 
   //    [ FIELD <FieldName> ]
   //    [ WIDTH <nWidth> ] 
   //    [ FONT <cFontName> SIZE <nFontSize> ]
   //    [ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
   //    [ TOOLTIP <cToolTipText> ]
   //    [ SHOWNONE ]
   //    [ UPDOWN ]
   //    [ RIGHTALIGN ]
   //    [ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
   //    [ ON CHANGE <OnChangeProcedure> | <bBlock> ] 
   //    [ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
   //    [ HELPID <nHelpId> ] 
   //    [ ON ENTER <OnEnterProcedure> | <bBlock> ] 
   //    [ INVISIBLE ] 
   //    [ NOTABSTOP ]
   //////////////////////////////////////////////////////////////////////////////////////////////////


   DO CASE
      CASE cSyntax == "MEMVAR"
         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE DATEPICKER",""))	   // DEFINE DATEPICKER dpkMemVar
         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))						   // ROW    60
         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))						   // COL    100
         aProperties_[ 4] := aDefCommandList_[ 4]                                               // WIDTH  120            
         aProperties_[ 5] := aDefCommandList_[ 5]                                               // HEIGHT 24             
         aProperties_[ 6] := aDefCommandList_[ 6]                                               // VALUE CTOD("  /  /  ")
         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"NAME",""))						   // FONTNAME "Arial"
         aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"FONT",""))						   // FONTSIZE 9
         aProperties_[ 9] := aDefCommandList_[ 9]                                               // TOOLTIP ""       
         aProperties_[10] := aDefCommandList_[10]                                               // ONCHANGE Nil     
         aProperties_[11] := aDefCommandList_[11]                                               // ONGOTFOCUS Nil   
         aProperties_[12] := aDefCommandList_[12]                                               // ONLOSTFOCUS Nil  
         aProperties_[13] := aDefCommandList_[13]                                               // FONTBOLD .F.     
         aProperties_[14] := aDefCommandList_[14]                                               // FONTITALIC .F.   
         aProperties_[15] := aDefCommandList_[15]                                               // FONTUNDERLINE .F.
         aProperties_[16] := aDefCommandList_[16]                                               // FONTSTRIKEOUT .F.
         aProperties_[17] := aDefCommandList_[17]                                               // ONENTER Nil      
         aProperties_[18] := aDefCommandList_[18]                                               // HELPID Nil       
         aProperties_[19] := aDefCommandList_[19]                                               // TABSTOP .T.      
         aProperties_[20] := aDefCommandList_[20]                                               // VISIBLE .T.      
         aProperties_[21] := aDefCommandList_[21]                                               // SHOWNONE .F.     
         aProperties_[22] := aDefCommandList_[22]                                               // UPDOWN .F.       
         aProperties_[23] := aDefCommandList_[23]                                               // RIGHTALIGN .F.   
         aProperties_[24] := aDefCommandList_[24]                                               // END DATEPICKER   

         *- pad short numbers row,column
         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)
         
         ///////////////////////////////////////////////////////////////////////////////////       
         // @ <nRow> ,<nCol> DATEPICKER <ControlName> OF <ParentWindowName> VALUE <cValue>;
         //    WIDTH <nWidth> HEIGHT <nHeight> FONT <cFontName> SIZE <nFontSize>
         ////////////////////////////////////////////////////////////////////////////////////
         cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " DATEPICKER " +;
         			  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[6] + ";" + CRLF +;
         			  LDCS_iLevel(3) + aProperties_[4] + " " + aProperties_[5] + " " +;
         			  aProperties_[7] + " " + aProperties_[8] + CRLF

      CASE cSyntax == "DBF"
         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE DATEPICKER",""))	     // DEFINE DATEPICKER dpkField
         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))						     // ROW    100                
         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))						     // COL    100                
         aProperties_[ 4] := aDefCommandList_[ 4]                                                 // WIDTH  120                
         aProperties_[ 5] := aDefCommandList_[ 5]                                                 // HEIGHT 24                 
         aProperties_[ 6] := aDefCommandList_[ 6]                                                 // VALUE CTOD("  /  /  ")    
         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"NAME",""))						     // FONTNAME "Arial"          
         aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"FONT",""))						     // FONTSIZE 9                
         aProperties_[ 9] := aDefCommandList_[ 9]                                                 // TOOLTIP ""                
         aProperties_[10] := aDefCommandList_[10]                                                 // ONCHANGE Nil              
         aProperties_[11] := aDefCommandList_[11]                                                 // ONGOTFOCUS Nil            
         aProperties_[12] := ALLTRIM(STRTRAN(aDefCommandList_[12],"ONLOSTFOCUS","ON LOSTFOCUS"))  // ONLOSTFOCUS Nil           
         aProperties_[13] := aDefCommandList_[13]                                                 // FONTBOLD .F.              
         aProperties_[14] := aDefCommandList_[14]                                                 // FONTITALIC .F.            
         aProperties_[15] := aDefCommandList_[15]                                                 // FONTUNDERLINE .F.         
         aProperties_[16] := aDefCommandList_[16]                                                 // FONTSTRIKEOUT .F.         
         aProperties_[17] := aDefCommandList_[17]                                                 // ONENTER Nil               
         aProperties_[18] := aDefCommandList_[18]                                                 // HELPID Nil                
         aProperties_[19] := aDefCommandList_[19]                                                 // TABSTOP .T.               
         aProperties_[20] := aDefCommandList_[20]                                                 // VISIBLE .T.               
         aProperties_[21] := aDefCommandList_[21]                                                 // SHOWNONE .F.              
         aProperties_[22] := aDefCommandList_[22]                                                 // UPDOWN .F.                
         aProperties_[23] := aDefCommandList_[23]                                                 // RIGHTALIGN .F.            
         aProperties_[24] := aDefCommandList_[24]                                                 // FIELD MYFIELD->F1         
         aProperties_[25] := aDefCommandList_[25]                                                 // END DATEPICKER            
      
         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

         ////////////////////////////////////////////////////////////////////////////////////////////////////////////
         //  @ <nRow> ,<nCol> DATEPICKER <ControlName> OF <ParentWindowName> VALUE <cValue> FIELD <FieldName>;
         //    WIDTH <nWidth> HEIGHT <nHeight> FONT <cFontName> SIZE <nFontSize> ON LOSTFOCUS <Procedure> | <bBlock>            
         ////////////////////////////////////////////////////////////////////////////////////////////////////////////
			cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " DATEPICKER " +;
						  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[6] + " " + aProperties_[24] + ";" + CRLF +;
         			  LDCS_iLevel(3) + aProperties_[4] + " " + aProperties_[5] + " " +;
         			  aProperties_[7] + " " + aProperties_[8] + " " + aProperties_[12] + CRLF						  

   ENDCASE

   sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

   RETURN cRetVal



