 ************************************************************************************ 
 * Program Name....: AST_EditBox.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE EDITBOX Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 *                   http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 *                   La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 10, 2007 02:28:08 AM, Tabuk, KSA
 * Last Updated....:
 *
 *
 * Revision History: 
 * -----------------
 * October 10, 2007 02:41:25 AM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 10, 2007 02:28:08 AM, Tabuk, KSA
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
** Function Name...: AST_EditBox()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_EDITBOX(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
**                          anExp2 => is a numeric array containing the indention in terms
**                                       of spaces 
**                          cExp3  => is the termination string to signal the end of
**                                       define command
**
** Returns.........: cRetVal => contains the converted @ ... EDITBOX Command Syntax
**
** Description.....: Converts DEFINE EDITBOX Command to @ ... EDITBOX Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
**                      1. oFileHandle - Object Container for TFileRead() CLASS
**                      2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_EditBox(cReadString,cTerminator)

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
   // HMG EDITBOX @... Command Snytax:
   // ------------------------------
   // @ <nRow> ,<nCol>
   //    EDITBOX<ControlName> 
   //    [ OF | PARENT <ParentWindowName> ]
   //    WIDTH <nWidth> 
   //    HEIGHT <nHeight> 
   //    [ FIELD <FieldName> ]
   //    [ VALUE <cValue> ] 
   //    [ READONLY ] 
   //    [ FONT <cFontName> SIZE <nFontSize> ]
   //    [ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
   //    [ TOOLTIP <cToolTipText> ]
   //    [ BACKCOLOR <aBackColor> ]
   //    [ FONTCOLOR <aFontColor> ]
   //    [ MAXLENGTH <nInputLength> ] 
   //    [ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
   //    [ ON CHANGE <OnChangeProcedure> | <bBlock> ] 
   //    [ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
   //    [ HELPID <nHelpId> ] 
   //    [ BREAK ]
   //    [ INVISIBLE ] 
   //    [ NOTABSTOP ]      
   //    [ NOVSCROLL ] 
   //    [ NOHSCROLL ]   
   //
   //------------------------------------------------------------------------------------------------
   // Memvar Syntax:
   // --------------
   // @ <nRow> ,<nCol> EDITBOX <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>;
   //    VALUE <cValue> FONT <cFontName> SIZE <nFontSize> TOOLTIP <cToolTipText>
   //
   // DBF Field Syntax:
   // -----------------
   // @ <nRow> ,<nCol> EDITBOX <ControlName> OF <ParentWindowName> WIDTH <nWidth> HEIGHT <nHeight>;
   //    FIELD <FieldName> VALUE <cValue> FONT <cFontName> SIZE <nFontSize>;
   //    TOOLTIP <cToolTipText>
   //
   //////////////////////////////////////////////////////////////////////////////////////////////////


   DO CASE
      CASE cSyntax == "MEMVAR"
         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE EDITBOX",""))   // DEFINE EDITBOX Edit_1
         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))              // ROW    170
         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))              // COL    90
         aProperties_[ 4] := aDefCommandList_[ 4]                                         // WIDTH  120
         aProperties_[ 5] := aDefCommandList_[ 5]                                         // HEIGHT 120
         aProperties_[ 6] := aDefCommandList_[ 6]                                         // VALUE ""  
         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"NAME",""))             // FONTNAME "Arial"
         aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"FONT",""))             // FONTSIZE 9
         aProperties_[ 9] := aDefCommandList_[ 9]                                         // TOOLTIP ""       
         aProperties_[10] := aDefCommandList_[10]                                         // ONCHANGE Nil     
         aProperties_[11] := aDefCommandList_[11]                                         // ONGOTFOCUS Nil   
         aProperties_[12] := aDefCommandList_[12]                                         // ONLOSTFOCUS Nil  
         aProperties_[13] := aDefCommandList_[13]                                         // FONTBOLD .F.     
         aProperties_[14] := aDefCommandList_[14]                                         // FONTITALIC .F.   
         aProperties_[15] := aDefCommandList_[15]                                         // FONTUNDERLINE .F.
         aProperties_[16] := aDefCommandList_[16]                                         // FONTSTRIKEOUT .F.
         aProperties_[17] := aDefCommandList_[17]                                         // HELPID Nil       
         aProperties_[18] := aDefCommandList_[18]                                         // TABSTOP .T.      
         aProperties_[19] := aDefCommandList_[19]                                         // VISIBLE .T.      
         aProperties_[20] := aDefCommandList_[20]                                         // READONLY .F.     
         aProperties_[21] := aDefCommandList_[21]                                         // HSCROLLBAR .T.   
         aProperties_[22] := aDefCommandList_[22]                                         // VSCROLLBAR .T.   
         aProperties_[23] := aDefCommandList_[23]                                         // BACKCOLOR NIL    
         aProperties_[24] := aDefCommandList_[24]                                         // FONTCOLOR NIL    
         aProperties_[25] := aDefCommandList_[25]                                         // END EDITBOX      

         *- pad short numbers row,column
         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

         cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " EDITBOX " +;
                    aProperties_[1] + " OF ~LDCS_Form " + aProperties_[4] + " " + aProperties_[5] + ";" + CRLF +;
                    LDCS_iLevel(3) + aProperties_[6] + " " + aProperties_[7] + " " +;
                    aProperties_[8] + " " + aProperties_[9] + CRLF

      CASE cSyntax == "DBF"
         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE EDITBOX",""))   // DEFINE EDITBOX Edit_2
         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))              // ROW    30
         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))              // COL    390
         aProperties_[ 4] := aDefCommandList_[ 4]                                         // WIDTH  120
         aProperties_[ 5] := aDefCommandList_[ 5]                                         // HEIGHT 120
         aProperties_[ 6] := aDefCommandList_[ 6]                                         // VALUE ""  
         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"NAME",""))             // FONTNAME "Arial"
         aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"FONT",""))             // FONTSIZE 9
         aProperties_[ 9] := aDefCommandList_[ 9]                                         // TOOLTIP ""       
         aProperties_[10] := aDefCommandList_[10]                                         // ONCHANGE Nil     
         aProperties_[11] := aDefCommandList_[11]                                         // ONGOTFOCUS Nil   
         aProperties_[12] := aDefCommandList_[12]                                         // ONLOSTFOCUS Nil  
         aProperties_[13] := aDefCommandList_[13]                                         // FONTBOLD .F.     
         aProperties_[14] := aDefCommandList_[14]                                         // FONTITALIC .F.   
         aProperties_[15] := aDefCommandList_[15]                                         // FONTUNDERLINE .F.
         aProperties_[16] := aDefCommandList_[16]                                         // FONTSTRIKEOUT .F.
         aProperties_[17] := aDefCommandList_[17]                                         // HELPID Nil       
         aProperties_[18] := aDefCommandList_[18]                                         // TABSTOP .T.      
         aProperties_[19] := aDefCommandList_[19]                                         // VISIBLE .T.      
         aProperties_[20] := aDefCommandList_[20]                                         // READONLY .F.     
         aProperties_[21] := aDefCommandList_[21]                                         // HSCROLLBAR .T.   
         aProperties_[22] := aDefCommandList_[22]                                         // VSCROLLBAR .T.   
         aProperties_[23] := aDefCommandList_[23]                                         // BACKCOLOR Nil    
         aProperties_[24] := aDefCommandList_[24]                                         // FONTCOLOR Nil    
         aProperties_[25] := aDefCommandList_[25]                                         // FIELD MYFIELD->F2
         aProperties_[26] := aDefCommandList_[26]                                         // END EDITBOX      

         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

         cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " EDITBOX " +;
                    aProperties_[1] + " OF ~LDCS_Form " + aProperties_[4] + " " + aProperties_[5] + ";" + CRLF +;
                    LDCS_iLevel(3) + aProperties_[25] + " " + aProperties_[6] + " " + ;
                    aProperties_[7] + " " + aProperties_[8] + ";" + CRLF +;
                    LDCS_iLevel(3) + aProperties_[9] + CRLF
   ENDCASE

   sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

   RETURN cRetVal




















