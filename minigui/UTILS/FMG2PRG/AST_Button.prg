 ************************************************************************************ 
 * Program Name....: AST_Button.Prg
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
 * Date Created....: October 03, 2007 09:44:38 AM, Tabuk, KSA
 * Last Updated....:
 *
 *
 *
 * Revision History: 
 * -----------------
 * October 04, 2007 04:34:17 PM, Tabuk, KSA - source code completion.
 *
 *
 *
 * October 03, 2007 09:44:38 AM, Tabuk, KSA
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
function AST_Button(cReadString,cTerminator)

   LOCAL cRetVal := ""

   LOCAL aDefCommandList_ := {},;
         aProperties_     := {}
   LOCAL sReadLine := ""
   LOCAL cIndention := ""
   
   LOCAL nKeywordPos := 0
   LOCAL cTemp1 := ""
   LOCAL cTemp2 := ""

   cIndention := LDCS_iLevel(2)

   AADD(aDefCommandList_, cReadString)
   WHILE oFileHandle:MORETOREAD()
      sReadLine := ALLTRIM(oFileHandle:READLINE())
      AADD(aDefCommandList_, sReadLine)
      IF ALLTRIM(sReadLine) == cTerminator
         EXIT
      ENDIF
   ENDDO

   aProperties_ := ARRAY(LEN(aDefCommandList_)) 

   aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE BUTTON"))              // DEFINE BUTTON btnCancel
   aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW"))                        // ROW    240
   aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL"))                        // COL    270
   aProperties_[ 4] := aDefCommandList_[ 4]                                                // WIDTH  185
   aProperties_[ 5] := aDefCommandList_[ 5]                                                // HEIGHT 28
   aProperties_[ 6] := aDefCommandList_[ 6]                                                // ACTION Nil
   aProperties_[ 7] := aDefCommandList_[ 7]                                                // CAPTION "&Cancel"
   aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8], "NAME"))                      // FONTNAME "Arial"
   aProperties_[ 9] := ALLTRIM(STRTRAN(aDefCommandList_[ 9], "FONT"))                      // FONTSIZE 9
   aProperties_[10] := aDefCommandList_[10]                                                // TOOLTIP "" + " " 
   aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"FONT",""))                    // FONTBOLD .F.     
   aProperties_[12] := ALLTRIM(STRTRAN(aDefCommandList_[12],"FONT",""))                    // FONTITALIC .F.   
   aProperties_[13] := ALLTRIM(STRTRAN(aDefCommandList_[13],"FONT",""))                    // FONTUNDERLINE .F.
   aProperties_[14] := ALLTRIM(STRTRAN(aDefCommandList_[14],"FONT",""))                    // FONTSTRIKEOUT .F.
   aProperties_[15] := ALLTRIM(STRTRAN(aDefCommandList_[15],"ONGOTFOCUS","ON GOTFOCUS"))   // ONGOTFOCUS Nil   
   aProperties_[16] := ALLTRIM(STRTRAN(aDefCommandList_[16],"ONLOSTFOCUS","ON LOSTFOCUS")) // ONLOSTFOCUS Nil  
   aProperties_[17] := aDefCommandList_[17]                                                // HELPID Nil       
   aProperties_[18] := aDefCommandList_[18]                                                // FLAT .F.         
   aProperties_[19] := aDefCommandList_[19]                                                // TABSTOP .T.      
   aProperties_[20] := aDefCommandList_[20]                                                // VISIBLE .T.      
   aProperties_[21] := aDefCommandList_[21]                                                // TRANSPARENT .F.  
   aProperties_[22] := aDefCommandList_[22]                                                // PICTURE Nil      
   aProperties_[23] := aDefCommandList_[23]                                                // PICTALIGNMENT TOP
   aProperties_[24] := aDefCommandList_[24]                                                // END BUTTON       

   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

   //////////////////////////////////////////////////////////////////
   // determine the @ command... BUTTON syntax to be used whether; //
   // TEXTONLY, IMAGEONLY or TEXTIMAGE                             //
   //////////////////////////////////////////////////////////////////
   cTemp1 := aDefCommandList_[ 7 ]
   cTemp1 := ALLTRIM(STRTRAN(cTemp1,"CAPTION",""))

   cTemp2 := aDefCommandList_[ 22 ]
   cTemp2 := ALLTRIM(STRTRAN(cTemp2,"PICTURE",""))

   DO CASE
      *- Image Only
      CASE UPPER(cTemp1) == "NIL" .AND. UPPER(cTemp2) <> "NIL"
         /////////////////////////////////////////////////////////////////////////////////////////
         // HMG Image Only Syntax:
         // ----------------------
         // @ <nRow> ,<nCol> 
         //       BUTTON <ButtonName> 
         //       [ OF<ParentWindowName> ]
         //       PICTURE <cPictureName> 
         //       ACTION | ONCLICK | ON CLICK <ActionProcedureName> | <bBlock> 
         //       [ WIDTH <nWidth> HEIGHT <nHeight> ] 
         //       [ TOOLTIP <cToolTipText> ] 
         //       [ FLAT ]   
         //       [ NOTRANSPARENT ]
         //       [ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
         //       [ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
         //       [ NOTABSTOP ]
         //       [ HELPID <nHelpId> ]
         //       [ INVISIBLE ] 
         //
         //---------------------------------------------------------------------------------------
         //
         // ========================================================
         // @ <nRow>, <nCol> BUTTON <ControlName> OF <ParentWindowName>;
         //    PICTURE <cPictureName> ACTION <ActionProcedureName> | bBlock> WIDTH <nWidth> HEIGHT <nHeight>
         /////////////////////////////////////////////////////////////////////////////////////////

         cRetVal := LDCS_iLevel(2) + ;
                    "@ " + aProperties_[2] + "," + aProperties_[3] + " BUTTON " +;
                    aProperties_[1] + " OF ~LDCS_Form" + " ;" + CRLF + ;
                    LDCS_iLevel(3) + aProperties_[22] + " " + aProperties_[6] + " " +;
                    aProperties_[4] + " " + aProperties_[5] + " " + CRLF

      *- Text Only
      CASE UPPER(cTemp1) <> "NIL" .AND. UPPER(cTemp2) == "NIL"
         /////////////////////////////////////////////////////////////////////////////////////////
         // HMG Text Only Syntax:
         // ---------------------
         // @ <nRow> ,<nCol> 
         //    BUTTON <ControlName> 
         //    [ OF | PARENT <ParentWindowName> ]
         //    CAPTION <cCaption>  
         //    ACTION | ONCLICK | ON CLICK <ActionProcedureName> | <bBlock> 
         //    [ WIDTH <nWidth> HEIGHT <nHeight> ] 
         //    [ FONT <cFontName> SIZE <nFontSize> ]
         //    [ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
         //    [ TOOLTIP <cToolTipText> ] 
         //    [ FLAT ] 
         //    [ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
         //    [ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
         //    [ NOTABSTOP ]
         //    [ HELPID <nHelpId> ]
         //    [ INVISIBLE ] 
         //
         //-----------------------------------------------------------------------------------------
         //
         // =======================================================
         // @ <nRow>, <nCol> BUTTON <ControlName> OF <ParentWindowName> CAPTION <cCaption>;
         //    ACTION <ActionProcedureName> | <bBlock> WIDTH <nWidth> HEIGHT <nHeight>;
         //    FONT <cFontName> SIZE <nFontSize>
         ///////////////////////////////////////////////////////////////////////////////////////////

         cRetVal := LDCS_iLevel(2) +;
                    "@ " + aProperties_[2] + "," + aProperties_[3] + " BUTTON " +;
                    aProperties_[1] + " OF ~LDCS_Form " + aProperties_[7] + " " +;
                    aProperties_[6] + " " + aProperties_[8] + " " + aProperties_[9] + CRLF
         
      *- Text and Image
      CASE UPPER(cTemp1) <> "NIL" .AND. UPPER(cTemp2) <> "NIL"
         ///////////////////////////////////////////////////////////////////////////////////////////
         // HMG Button Text And Image Syntax:
         // ---------------------------------
         //    @ <nRow> ,<nCol> 
         //       BUTTON <ButtonName> 
         //       [ OF<ParentWindowName> ]
         //       CAPTION <cCaption>  
         //       PICTURE <cPictureName> [ TOP | BOTTOM | LEFT | RIGHT ]
         //       ACTION | ONCLICK | ON CLICK <ActionProcedureName> | <bBlock> 
         //       [ WIDTH <nWidth> HEIGHT <nHeight> ] 
         //       [ TOOLTIP <cToolTipText> ] 
         //       [ FLAT ]   
         //       [ NOTRANSPARENT ]
         //       [ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
         //       [ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
         //       [ NOTABSTOP ]
         //       [ HELPID <nHelpId> ]
         //       [ INVISIBLE ]
         //
         //-----------------------------------------------------------------------------------------
         //
         // @ <nRow>, <nCol> BUTTON <ControlName> OF <ParentWindowName> CAPTION <cCaption>;
         //    PICTURE <cPictureName> LEFT ACTION <ActionProcedureName> | <bBlock> WIDTH <nWidth> HEIGHT <nHeight>
         //
         ///////////////////////////////////////////////////////////////////////////////////////////

         cRetVal := LDCS_iLevel(2) +;
                    "@ " + aProperties_[2] + "," + aProperties_[3] + " BUTTON " +;
                    aProperties_[1] + " OF ~LDCS_Form " + aProperties_[7] + "; " + CRLF +;
                    LDCS_iLevel(3) + aProperties_[22] + " LEFT " + ";" + CRLF +;
                    LDCS_iLevel(3) + aProperties_[4] + " " + aProperties_[5] + CRLF
   ENDCASE
   
   sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF
   
   RETURN cRetVal


