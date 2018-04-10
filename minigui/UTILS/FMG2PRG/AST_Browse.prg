 ************************************************************************************ 
 * Program Name....: AST_Browse.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE BUTTON Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 *                   http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 *                   La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 04, 2007 02:34:32 PM, Tabuk, KSA
 * Last Updated....:
 *
 *
 * Revision History: 
 * -----------------
 * October 04, 2007 04:34:58 PM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 04, 2007 02:34:32 PM, Tabuk, KSA
 * ----------------------------------------
 *    Original Source Code
 *
 *************************************************************************************/


#include "minigui.ch"
*#include "inkey.ch"
*#include "common.ch"
#include "dale-aid.ch"

*#define CRLF  HB_OSNEWLINE()



***************************************************************************************
function AST_Browse(cReadString,cTerminator)


   LOCAL cRetVal := ""

   LOCAL aDefCommandList_ := {},;
         aProperties_     := {}
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
   // HMG BROWSE @.. Command Syntax:
   // ------------------------------
   // @ <nRow> ,<nCol>
   //       BROWSE <ControlName> 
   //       [ OF | PARENT <ParentWindowName> ]
   //       WIDTH <nWidth> 
   //       HEIGHT <nHeight> 
   //       HEADERS <acHeaders> 
   //       WIDTHS <anWidths> 
   //       WORKAREA <WorkAreaName>  
   //       FIELDS <acFields> 
   //       [ VALUE <nValue> ] 
   //       [ FONT <cFontname> SIZE <nFontsize> ] 
   //       [ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
   //       [ TOOLTIP <cToolTipText> ] 
   //       [ DYNAMICBACKCOLOR <aDynamicBackColor> ]
   //       [ DYNAMICFORECOLOR <aDynamicBackColor> ]
   //       [ INPUTMASK <acInputMask> ]
   //       [ FORMAT <acFormat> ]
   //       [ BACKCOLOR <aBackColor> ]
   //       [ FONTCOLOR <aFontColor> ]
   //       [ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
   //       [ ON CHANGE <OnChangeProcedure> | <bBlock> ]  
   //       [ ON LOSTFOCUS <OnGotFocusProcedur> | <bBlock> ]
   //       [ [ ON DBLCLICK <OnDblClickProcedure> | <bBlock> ]  | 
   //       [ EDIT  [ INPLACE ] ] [ APPEND ]
   //       [ ON HEADCLICK <abBlock> ]   
   //       [ WHEN <abBlock> ]   
   //       [ VALID <abBlock> ] 
   //       [ VALIDMESSAGES <acValidationMessages> ] 
   //       [ READONLY <alReadOnlyFields> ] 
   //       [ LOCK ]  
   //       [ DELETE ]  
   //       [ NOLINES ]  
   //       [ IMAGE <acImageNames> ]  
   //       [ JUSTIFY <anJustifyValue> ] 
   //       [ NOVSCROLL ]
   //       [ HELPID <nHelpId> ] 
   //       [ BREAK ]
   //
   //------------------------------------------------------------------------------------------------
   // La DALE-Aid Creative Solutions @ ... Command BROWSE Syntax:
   // ===========================================================
   // @ <nRow>,<nCol> BROWSE <ControlName> OF <ParentwindowName> WIDTH <nWidth> HEIGHT <nHeight>;
   //    HEADERS <acHeaders> WIDTHS <anWidths> WORKAREA <WorkAreaName> FIELDS <acFields>;
   //    VALUE <nValue> FONT <cFontName> SIZE <nFontSize> ON DBLCLICK <OnDblClickProcedure> | <bBlock>;
   //    ON HEADCLICK <abBlock>
   //
   //////////////////////////////////////////////////////////////////////////////////////////////////

   aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE BROWSE",""))   // DEFINE BROWSE brwTopics
   aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))             // ROW    27
   aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))             // COL    17
   aProperties_[ 4] := aDefCommandList_[ 4]                                        // WIDTH  250
   aProperties_[ 5] := aDefCommandList_[ 5]                                        // HEIGHT 100
   aProperties_[ 6] := aDefCommandList_[ 6]                                        // VALUE 0     
   aProperties_[ 7] := aDefCommandList_[ 7]                                        // WIDTHS {0}  
   aProperties_[ 8] := aDefCommandList_[ 8]                                        // HEADERS {''}
   aProperties_[ 9] := aDefCommandList_[ 9]                                        // WORKAREA Nil
   aProperties_[10] := aDefCommandList_[10]                                        // FIELDS {''} 
   aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"NAME",""))            // FONTNAME "Arial"
   aProperties_[12] := ALLTRIM(STRTRAN(aDefCommandList_[12],"FONT",""))            // FONTSIZE 9
   aProperties_[13] := aDefCommandList_[13]                                        // TOOLTIP ""       
   aProperties_[14] := aDefCommandList_[14]                                        // ONCHANGE Nil     
   aProperties_[15] := aDefCommandList_[15]                                        // ONGOTFOCUS Nil   
   aProperties_[16] := aDefCommandList_[16]                                        // ONLOSTFOCUS Nil  
   aProperties_[17] := aDefCommandList_[17]                                        // FONTBOLD .F.     
   aProperties_[18] := aDefCommandList_[18]                                        // FONTITALIC .F.   
   aProperties_[19] := aDefCommandList_[19]                                        // FONTUNDERLINE .F.
   aProperties_[20] := aDefCommandList_[20]                                        // FONTSTRIKEOUT .F.
   aProperties_[21] := ALLTRIM(STRTRAN(aDefCommandList_[21],"ONDBLCLICK",""))      // ONDBLCLICK Nil
   aProperties_[22] := aDefCommandList_[22]                                        // ALLOWEDIT .F.  
   aProperties_[23] := aDefCommandList_[23]                                        // ALLOWAPPEND .F.
   aProperties_[24] := ALLTRIM(STRTRAN(aDefCommandList_[24],"ONHEADCLICK",""))     // ONHEADCLICK Nil
   aProperties_[25] := aDefCommandList_[25]                                        // ALLOWDELETE .F.     
   aProperties_[26] := aDefCommandList_[26]                                        // HELPID Nil          
   aProperties_[27] := aDefCommandList_[27]                                        // VALID Nil           
   aProperties_[28] := aDefCommandList_[28]                                        // VALIDMESSAGES Nil   
   aProperties_[29] := aDefCommandList_[29]                                        // LOCK .F.            
   aProperties_[30] := aDefCommandList_[30]                                        // VSCROLLBAR .T.      
   aProperties_[31] := aDefCommandList_[31]                                        // DYNAMICBACKCOLOR Nil
   aProperties_[32] := aDefCommandList_[32]                                        // DYNAMICFORECOLOR Nil
   aProperties_[33] := aDefCommandList_[33]                                        // INPUTMASK Nil       
   aProperties_[34] := aDefCommandList_[34]                                        // FORMAT Nil          
   aProperties_[35] := aDefCommandList_[35]                                        // WHEN Nil            
   aProperties_[36] := aDefCommandList_[36]                                        // BACKCOLOR Nil       
   aProperties_[37] := aDefCommandList_[37]                                        // FONTCOLOR Nil       
   aProperties_[38] := aDefCommandList_[38]                                        // IMAGE Nil           
   aProperties_[39] := aDefCommandList_[39]                                        // JUSTIFY Nil         
   aProperties_[40] := aDefCommandList_[40]                                        // NOLINES .F.         
   aProperties_[41] := aDefCommandList_[41]                                        // READONLYFIELDS Nil  
   aProperties_[42] := aDefCommandList_[42]                                        // END BROWSE 
            
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)            
            
   cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " BROWSE " +;
              aProperties_[1] + " OF ~LDSC_Form " + aProperties_[4] + " " + aProperties_[5] + "; " + CRLF +;
              LDCS_iLevel(3) + aProperties_[8] + " " + aProperties_[7] + " " +;
              aProperties_[9] + " " + aProperties_[10] + "; " + CRLF + ;
              LDCS_iLevel(3) + aProperties_[11] + " " + aProperties_[12] +;
              " ON DBLCLICK " + aProperties_[21] + "; " + CRLF +;
              LDCS_iLevel(3) + "ON HEADCLICK " + aProperties_[24] + CRLF

	sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

   RETURN cRetVal







