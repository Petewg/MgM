 ************************************************************************************ 
 * Program Name....: AST_TextBox.Prg
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
 * Date Created....: October 05, 2007 12:40:22 AM, Tabuk, KSA
 * Last Updated....:
 *
 * IDE DESIGN NOTE: During form design, At least fill out the Maxlength, Numeric, Character
 *						  Date, InputMask, Field, Event: LostFocus. Failure to do so would 
 *						  generate bound error array access.
 *
 *
 * Revision History: 
 * -----------------
 * October 05, 2007 06:20:06 PM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 05, 2007 12:40:22 AM, Tabuk, KSA
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
** Function Name...: AST_TextBox()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_Frame(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
**                          anExp2 => is a numeric array containing the indention in terms
**                                       of spaces 
**                          cExp3  => is the termination string to signal the end of
**                                       define command
**
** Returns.........: cRetVal => contains the converted @ ... TEXTBOX Command Syntax
**
** Description.....: Converts DEFINE TEXTBOX Command to @ ... TEXTBOX Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
**                      1. oFileHandle - Object Container for TFileRead() CLASS
**                      2. sCtrlObjects - Container for Control Objects Roster
**
** Algorithm.......: There are 7 Syntax Variations, 3 Types for Characters including
**                      the handling for memory variables, fields and password. There
**                      are 2 syntax types for handling numeric data for fields and memvar.
**                      There are 2 syntax types for date memvar and field value.
**
**                   ALGORITHM IMPLEMENTATION:
**                   NUMV -> Memvar Numeric Input
**                   NUMF -> DBF Numeric Input
**                   CHRP -> Password Input 
**                   CHRC -> Memvar Character Input
**                   CHRF -> DBF Character Input
**                   DTEV -> Memvar DATE Input
**                   DTEF -> DBF DATE Input
**
** NOTE: This routine is completed, proper syntax is not achieved. However somehow
**       the outcome is acceptable and could be edited thru text editor. The main goal
**       as of the moment is to format the command with @ command.
**                          October 05, 2007 08:16:08 PM - Danny
***************************************************************************************
function AST_TextBox(cReadString,cTerminator)

   LOCAL cRetVal := ""

   LOCAL aDefCommandList_ := {},;
         aProperties_     := {}
         
   LOCAL sReadLine := ""
   LOCAL SyntaxType := ""
   LOCAL LogicHelper := FALSE
   LOCAL UpperLower  := FALSE
   
   LOCAL nKeywordPos := 0
   LOCAL cTemp1 := ""
   LOCAL cTemp2 := ""

   AADD(aDefCommandList_, cReadString)
   WHILE oFileHandle:MORETOREAD()
      sReadLine := ALLTRIM(oFileHandle:READLINE())

		IF SUBSTR(sReadLine,1,5) == "FIELD"
			LogicHelper := TRUE
		ENDIF

		IF SUBSTR(sReadLine,1,9) == "UPPERCASE"
			UpperLower := TRUE
		ENDIF

		IF SUBSTR(sReadLine,1,8) == "PASSWORD" .AND. RIGHT(sReadLine,3) == ".T."
			SyntaxType := "CHRP"
		ENDIF

		IF SUBSTR(sReadLine,1,7) == "NUMERIC" .AND. RIGHT(sReadLine,3) == ".T."
			IF LogicHelper
				SyntaxType := "NUMF"
			ELSE
				SyntaxType := "NUMV"
			ENDIF
		ENDIF
		
		IF SUBSTR(sReadLine,1,4) == "DATE" .AND. RIGHT(sReadLine,3) == ".T."
			IF LogicHelper
				SyntaxType := "DTEF"
			ELSE
				SyntaxType := "DTEV"
			ENDIF
		ENDIF

      AADD(aDefCommandList_, sReadLine)
      IF ALLTRIM(sReadLine) == cTerminator
         EXIT
      ENDIF
   ENDDO

	IF EMPTY(SyntaxType)
		IF LogicHelper
			SyntaxType := "CHRF"
		ELSE
			SyntaxType := "CHRV"
		ENDIF
	ENDIF


   aProperties_ := ARRAY(LEN(aDefCommandList_)) 

   
   //////////////////////////////////////////////////////////////////////////////////////////////////
   // HMG TEXTBOX @ Command Syntax:
   // -----------------------------
   // @ <nRow> ,<nCol> 
   //    TEXTBOX <ControlName> 
   //    [ OF | PARENT <ParentWindowName> ]
   //    [ HEIGHT <nHeight> ] 
   //    [ FIELD <FieldName> ]
   //    [ VALUE <nValue> ]
   //    [ READONLY ] 
   //    [ WIDTH <nWidth> ] 
   //    [ NUMERIC ] [ INPUTMASK <cMask> ] 
   //    [ FORMAT <cFormat> ] | PASSWORD ] 
   //    [ FONT <cFontName> SIZE <nFontSize> ]
   //    [ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
   //    [ TOOLTIP <cToolTipText> ]
   //    [ BACKCOLOR <aBackColor> ]
   //    [ FONTCOLOR <aFontColor> ]
   //    [ DATE ]
   //    [ MAXLENGTH <nInputLength> ]
   //    [ UPPERCASE | LOWERCASE ] 
   //    [ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
   //    [ ON CHANGE <OnChangeProcedure> | <bBlock> ] 
   //    [ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ] 
   //    [ ON ENTER <OnEnterProcedure> | <bBlock> ] 
   //    [ RIGHTALIGN ]
   //    [ INVISIBLE ] 
   //    [ NOTABSTOP ]
   //    [ HELPID <nHelpId> ]
   //
   ///////////////////////////////////////////////////////////////////////////////////////////////////

   DO CASE
      CASE SyntaxType == "CHRP"
         ///////////////////////////////////////////////////////////////////////////////////////////////////
         // La DALE-Aid Creative Solutions @ ... Command TEXTBOX PASSWORD Syntax:
         // ---------------------------------------------------------------------
         // @ <nRow> ,<nCol> TEXTBOX <ControlName> OF <ParentWindowName> HEIGHT <nHeight> VALUE <nValue> WIDTH <nWidth>;
         //    PASSWORD MAXLENGTH <nInputLength> UPPERCASE ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock>
         ///////////////////////////////////////////////////////////////////////////////////////////////////

         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE TEXTBOX",""))               // DEFINE TEXTBOX txbPassword
         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))                          // ROW    200                
         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))                          // COL    100                
         aProperties_[ 4] := aDefCommandList_[ 4]                                                     // WIDTH  120                
         aProperties_[ 5] := aDefCommandList_[ 5]                                                     // HEIGHT 24                 
         aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"NAME",""))                         // FONTNAME "Arial"          
         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"FONT",""))                         // FONTSIZE 9                
         aProperties_[ 8] := aDefCommandList_[ 8]                                                     // TOOLTIP ""                
         aProperties_[ 9] := aDefCommandList_[ 9]                                                     // ONCHANGE Nil              
         aProperties_[10] := aDefCommandList_[10]                                                     // ONGOTFOCUS Nil            
         aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"ONLOSTFOCUS","ON LOSTFOCUS"))      // ONLOSTFOCUS Nil       
         aProperties_[12] := aDefCommandList_[12]                                                     // FONTBOLD .F.     
         aProperties_[13] := aDefCommandList_[13]                                                     // FONTITALIC .F.   
         aProperties_[14] := aDefCommandList_[14]                                                     // FONTUNDERLINE .F.
         aProperties_[15] := aDefCommandList_[15]                                                     // FONTSTRIKEOUT .F.
         aProperties_[16] := aDefCommandList_[16]                                                     // ONENTER Nil      
         aProperties_[17] := aDefCommandList_[17]                                                     // HELPID Nil       
         aProperties_[18] := aDefCommandList_[18]                                                     // TABSTOP .T.      
         aProperties_[19] := aDefCommandList_[19]                                                     // VISIBLE .T.      
         aProperties_[20] := aDefCommandList_[20]                                                     // READONLY .F.     
         aProperties_[21] := aDefCommandList_[21]                                                     // RIGHTALIGN .F.   
         aProperties_[22] := ALLTRIM(STRTRAN(aDefCommandList_[22],".T.",""))                          // PASSWORD .T.     
         aProperties_[23] := aDefCommandList_[23]                                                     // BACKCOLOR NIL    
         aProperties_[24] := aDefCommandList_[24]                                                     // FONTCOLOR NIL    
         aProperties_[25] := aDefCommandList_[25]                                                     // INPUTMASK Nil    
         aProperties_[26] := aDefCommandList_[26]                                                     // FORMAT Nil       
         aProperties_[27] := aDefCommandList_[27]                                                     // VALUE ""         
         aProperties_[28] := aDefCommandList_[28]                                                     // END TEXTBOX      
           
         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)
           
           
         cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " TEXTBOX " +;
                    aProperties_[1] + " OF ~LDCS_Form " + aProperties_[5] + " " + aProperties_[27] +;
                    " " + aProperties_[4] + ";" + CRLF + LDCS_iLevel(3) + "PASSWORD MAXLENGTH 10 UPPERCASE " +;
                    aProperties_[11] + CRLF
           
      CASE SyntaxType == "CHRF"
         ///////////////////////////////////////////////////////////////////////////////////////////////////
         // @ <nRow> ,<nCol> TEXTBOX <ControlName> OF <ParentWindowName> HEIGHT <nHeight> FIELD <FieldName>; 
         //    VALUE <nValue> WIDTH <nWidth> FONT <cFontName> SIZE <nFontSize> TOOLTIP <cToolTipText>; 
         //    MAXLENGTH <nInputLegnth> [UPPERCASE] ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock>
         ///////////////////////////////////////////////////////////////////////////////////////////////////
         
			IF UpperLower
	         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE TEXTBOX",""))           // DEFINE TEXTBOX txbField
	         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))                      // ROW    80          
	         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))                      // COL    100         
	         aProperties_[ 4] := aDefCommandList_[ 4]                                                 // WIDTH  120 
	         aProperties_[ 5] := aDefCommandList_[ 5]                                                 // HEIGHT 24  
	         aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"NAME",""))                     // FONTNAME "Arial"   
	         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"FONT",""))                     // FONTSIZE 9         
	         aProperties_[ 8] := aDefCommandList_[ 8]                                                 // TOOLTIP ""    
	         aProperties_[ 9] := aDefCommandList_[ 9]                                                 // ONCHANGE Nil  
	         aProperties_[10] := aDefCommandList_[10]                                                 // ONGOTFOCUS Nil
	         aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"ONLOSTFOCUS","ON LOSTFOCUS"))  // ONLOSTFOCUS Nil    
	         aProperties_[12] := aDefCommandList_[12]                                                 // FONTBOLD .F.     
	         aProperties_[13] := aDefCommandList_[13]                                                 // FONTITALIC .F.   
	         aProperties_[14] := aDefCommandList_[14]                                                 // FONTUNDERLINE .F.
	         aProperties_[15] := aDefCommandList_[15]                                                 // FONTSTRIKEOUT .F.
	         aProperties_[16] := aDefCommandList_[16]                                                 // ONENTER Nil      
	         aProperties_[17] := aDefCommandList_[17]                                                 // HELPID Nil       
	         aProperties_[18] := aDefCommandList_[18]                                                 // TABSTOP .T.      
	         aProperties_[19] := aDefCommandList_[19]                                                 // VISIBLE .T.      
	         aProperties_[20] := aDefCommandList_[20]                                                 // READONLY .F.     
	         aProperties_[21] := aDefCommandList_[21]                                                 // RIGHTALIGN .F.   
	         aProperties_[22] := ALLTRIM(STRTRAN(aDefCommandList_[22],".T.",""))                      // UPPERCASE .T.      
	         aProperties_[23] := aDefCommandList_[23]                                                 // MAXLENGTH 60    
	         aProperties_[24] := aDefCommandList_[24]                                                 // BACKCOLOR NIL   
	         aProperties_[25] := aDefCommandList_[25]                                                 // FONTCOLOR NIL   
	         aProperties_[26] := aDefCommandList_[26]                                                 // FIELD MYFILE->F1
	         aProperties_[27] := aDefCommandList_[27]                                                 // INPUTMASK Nil   
	         aProperties_[28] := aDefCommandList_[28]                                                 // FORMAT Nil      
	         aProperties_[29] := aDefCommandList_[29]                                                 // VALUE ""        
	         aProperties_[30] := aDefCommandList_[30]                                                 // END TEXTBOX     
	
	         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
	         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

            cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " TEXTBOX " + aProperties_[1] +;
                       " OF ~LDCS_Form " + aProperties_[5] + " " + aProperties_[26] + "; " + CRLF +;
                       LDCS_iLevel(3) + aProperties_[29] + " " + aProperties_[4] + " " + aProperties_[6] + " " +;
                       aProperties_[7] + " " + aProperties_[8] + "; " + CRLF +;
                       LDCS_iLevel(3) + aProperties_[23] + " " + aProperties_[22] + " " + aProperties_[11] + CRLF
         ELSE
	         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE TEXTBOX",""))           // DEFINE TEXTBOX txbField
	         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))                      // ROW    80          
	         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))                      // COL    100         
	         aProperties_[ 4] := aDefCommandList_[ 4]                                                 // WIDTH  120 
	         aProperties_[ 5] := aDefCommandList_[ 5]                                                 // HEIGHT 24  
	         aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"NAME",""))                     // FONTNAME "Arial"   
	         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"FONT",""))                     // FONTSIZE 9         
	         aProperties_[ 8] := aDefCommandList_[ 8]                                                 // TOOLTIP ""    
	         aProperties_[ 9] := aDefCommandList_[ 9]                                                 // ONCHANGE Nil  
	         aProperties_[10] := aDefCommandList_[10]                                                 // ONGOTFOCUS Nil
	         aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"ONLOSTFOCUS","ON LOSTFOCUS"))  // ONLOSTFOCUS Nil    
	         aProperties_[12] := aDefCommandList_[12]                                                 // FONTBOLD .F.     
	         aProperties_[13] := aDefCommandList_[13]                                                 // FONTITALIC .F.   
	         aProperties_[14] := aDefCommandList_[14]                                                 // FONTUNDERLINE .F.
	         aProperties_[15] := aDefCommandList_[15]                                                 // FONTSTRIKEOUT .F.
	         aProperties_[16] := aDefCommandList_[16]                                                 // ONENTER Nil      
	         aProperties_[17] := aDefCommandList_[17]                                                 // HELPID Nil       
	         aProperties_[18] := aDefCommandList_[18]                                                 // TABSTOP .T.      
	         aProperties_[19] := aDefCommandList_[19]                                                 // VISIBLE .T.      
	         aProperties_[20] := aDefCommandList_[20]                                                 // READONLY .F.     
	         aProperties_[21] := aDefCommandList_[21]                                                 // RIGHTALIGN .F.   
	         aProperties_[22] := aDefCommandList_[22]                                                 // MAXLENGTH 60    
	         aProperties_[23] := aDefCommandList_[23]                                                 // BACKCOLOR NIL   
	         aProperties_[24] := aDefCommandList_[24]                                                 // FONTCOLOR NIL   
	         aProperties_[25] := aDefCommandList_[25]                                                 // FIELD MYFILE->F1
	         aProperties_[26] := aDefCommandList_[26]                                                 // INPUTMASK Nil   
	         aProperties_[27] := aDefCommandList_[27]                                                 // FORMAT Nil      
	         aProperties_[28] := aDefCommandList_[28]                                                 // VALUE ""        
	         aProperties_[29] := aDefCommandList_[29]                                                 // END TEXTBOX     
	
	         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
	         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

            cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " TEXTBOX " + aProperties_[1] +;
                       " OF ~LDCS_Form " + aProperties_[5] + " " + aProperties_[26] + "; " + CRLF +;
                       LDCS_iLevel(3) + aProperties_[28] + " " + aProperties_[4] + " " + aProperties_[6] + " " +;
                       aProperties_[7] + " " + aProperties_[8] + "; " + CRLF +;
                       LDCS_iLevel(3) + aProperties_[23] + " " + aProperties_[11] + CRLF       
         ENDIF

      CASE SyntaxType == "CHRV"

         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE TEXTBOX",""))          // DEFINE TEXTBOX tb_charvar
         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))                     // ROW    40            
         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",))                       // COL    100           
         aProperties_[ 4] := aDefCommandList_[ 4]                                                // WIDTH  120 
         aProperties_[ 5] := aDefCommandList_[ 5]                                                // HEIGHT 24  
         aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"NAME",""))                    // FONTNAME "Arial"     
         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"FONT",""))                    // FONTSIZE 9           
         aProperties_[ 8] := aDefCommandList_[ 8]                                                // TOOLTIP ""    
         aProperties_[ 9] := aDefCommandList_[ 9]                                                // ONCHANGE Nil  
         aProperties_[10] := aDefCommandList_[10]                                                // ONGOTFOCUS Nil
         aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"ONLOSTFOCUS","ON LOSTFOCUS")) // ONLOSTFOCUS Nil      
         aProperties_[12] := aDefCommandList_[12]                                                // FONTBOLD .F.     
         aProperties_[13] := aDefCommandList_[13]                                                // FONTITALIC .F.   
         aProperties_[14] := aDefCommandList_[14]                                                // FONTUNDERLINE .F.
         aProperties_[15] := aDefCommandList_[15]                                                // FONTSTRIKEOUT .F.
         aProperties_[16] := aDefCommandList_[16]                                                // ONENTER Nil      
         aProperties_[17] := aDefCommandList_[17]                                                // HELPID Nil       
         aProperties_[18] := aDefCommandList_[18]                                                // TABSTOP .T.      
         aProperties_[19] := aDefCommandList_[19]                                                // VISIBLE .T.      
         aProperties_[20] := aDefCommandList_[20]                                                // READONLY .F.     
         aProperties_[21] := aDefCommandList_[21]                                                // RIGHTALIGN .F.   
         aProperties_[22] := aDefCommandList_[22]                                                // MAXLENGTH 40     
         aProperties_[23] := aDefCommandList_[23]                                                // BACKCOLOR NIL    
         aProperties_[24] := aDefCommandList_[24]                                                // FONTCOLOR NIL    
         aProperties_[25] := aDefCommandList_[25]                                                // INPUTMASK Nil    
         aProperties_[26] := aDefCommandList_[26]                                                // FORMAT Nil       
         aProperties_[27] := aDefCommandList_[27]                                                // VALUE ""         
         aProperties_[28] := aDefCommandList_[28]                                                // END TEXTBOX      

         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

         ///////////////////////////////////////////////////////////////////////////////////////////////////
         // @ <nRow> ,<nCol> TEXTBOX <ControlName> OF <ParentWindowName> HEIGHT <nHeight> VALUE <nValue> WIDTH <nWidth>;
         //    FONT <cFontName> SIZE <nFontSize> TOOLTIP <cToolTipText> MAXLENGTH <nInputLegnth> ON LOSTFOCUS <ProcName>
         ///////////////////////////////////////////////////////////////////////////////////////////////////
         IF UpperLower
            cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " TEXTBOX " +;
                       aProperties_[1] + " OF ~LDCS_Form " + aProperties_[5] + " " + aProperties_[27] + " " +;
                       aProperties_[4] + ";" + CRLF + ;
                       LDCS_iLevel(3) + aProperties_[6] + " " + aProperties_[7] + " " + aProperties_[8] + " " +;
                       aProperties_[22] + " UPPERCASE " + aProperties_[11] + CRLF
         ELSE
            cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " TEXTBOX " +;
                       aProperties_[1] + " OF ~LDCS_Form " + aProperties_[5] + " " + aProperties_[27] + " " +;
                       aProperties_[4] + ";" + CRLF + ;
                       LDCS_iLevel(3) + aProperties_[6] + " " + aProperties_[7] + " " + aProperties_[8] + " " +;
                       aProperties_[22] + " " + aProperties_[11] + CRLF

         ENDIF

      CASE SyntaxType == "NUMF"
     
         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE TEXTBOX",""))            // DEFINE TEXTBOX txbNumField            
         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))                       // ROW    40                         
         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))                       // COL    280                        
         aProperties_[ 4] := aDefCommandList_[ 4]                                                  // WIDTH  120
         aProperties_[ 5] := aDefCommandList_[ 5]                                                  // HEIGHT 24 
         aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"NAME",""))                      // FONTNAME "Arial"                  
         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"FONT",""))                      // FONTSIZE 9                        
         aProperties_[ 8] := aDefCommandList_[ 8]                                                  // TOOLTIP ""    
         aProperties_[ 9] := aDefCommandList_[ 9]                                                  // ONCHANGE Nil  
         aProperties_[10] := aDefCommandList_[10]                                                  // ONGOTFOCUS Nil
         aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"ONLOSTFOCUS","ON LOSTFOCUS"))   // ONLOSTFOCUS Nil                   
         aProperties_[12] := aDefCommandList_[12]                                                  // FONTBOLD .F.                 
         aProperties_[13] := aDefCommandList_[13]                                                  // FONTITALIC .F.               
         aProperties_[14] := aDefCommandList_[14]                                                  // FONTUNDERLINE .F.            
         aProperties_[15] := aDefCommandList_[15]                                                  // FONTSTRIKEOUT .F.            
         aProperties_[16] := aDefCommandList_[16]                                                  // ONENTER Nil                  
         aProperties_[17] := aDefCommandList_[17]                                                  // HELPID Nil                   
         aProperties_[18] := aDefCommandList_[18]                                                  // TABSTOP .T.                  
         aProperties_[19] := aDefCommandList_[19]                                                  // VISIBLE .T.                  
         aProperties_[20] := aDefCommandList_[20]                                                  // READONLY .F.                 
         aProperties_[21] := aDefCommandList_[21]                                                  // RIGHTALIGN .F.               
         aProperties_[22] := aDefCommandList_[22]                                                  // BACKCOLOR NIL                
         aProperties_[23] := aDefCommandList_[23]                                                  // FONTCOLOR NIL                
         aProperties_[24] := aDefCommandList_[24]                                                  // FIELD MYFILE->f1             
         aProperties_[25] := aDefCommandList_[25]                                                  // INPUTMASK "99,999,999,999.99"
         aProperties_[26] := aDefCommandList_[26]                                                  // FORMAT Nil                   
         aProperties_[27] := aDefCommandList_[27]                                                  // NUMERIC .T.                  
         aProperties_[28] := aDefCommandList_[28]                                                  // VALUE Nil                    
         aProperties_[29] := aDefCommandList_[29]                                                  // END TEXTBOX                  
        
         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)
     
         ///////////////////////////////////////////////////////////////////////////////////////////////////
         // @ <nRow> ,<nCol> TEXTBOX <ControlName> OF <ParentWindowName> HEIGHT <nHeight> FIELD <FieldName>;
         //    VALUE <nValue> WIDTH <nWidth> NUMERIC INPUTMASK <cMask> FONT <cFontName> SIZE <nFontSize>;
         //    TOOLTIP <cToolTipText> ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
         ///////////////////////////////////////////////////////////////////////////////////////////////////    
     
         cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " TEXTBOX " +;
                    aProperties_[1] + " OF ~LDCS_Form " + aProperties_[5] + " " +;
                    aProperties_[24] + "; " + CRLF +;
                    LDCS_iLevel(3) + aProperties_[28] + " " + aProperties_[4] + " NUMERIC " +;
                    aProperties_[25] + " " + aProperties_[6] + " " + aProperties_[7] + ";" + CRLF +;
                    LDCS_iLevel(3) + aProperties_[8] + " " + aProperties_[11] + CRLF
     
      CASE SyntaxType == "NUMV"

         aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE TEXTBOX",""))            // DEFINE TEXTBOX txbNumeric        
         aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))                       // ROW    160                   
         aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))                       // COL    100                   
         aProperties_[ 4] := aDefCommandList_[ 4]                                                  // WIDTH  120
         aProperties_[ 5] := aDefCommandList_[ 5]                                                  // HEIGHT 24 
         aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"NAME",""))                      // FONTNAME "Arial"             
         aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"FONT",""))                      // FONTSIZE 9                   
         aProperties_[ 8] := aDefCommandList_[ 8]                                                  // TOOLTIP ""    
         aProperties_[ 9] := aDefCommandList_[ 9]                                                  // ONCHANGE Nil  
         aProperties_[10] := aDefCommandList_[10]                                                  // ONGOTFOCUS Nil
         aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"ONLOSTFOCUS","ON LOSTFOCUS"))   // ONLOSTFOCUS Nil              
         aProperties_[12] := aDefCommandList_[12]                                                  // FONTBOLD .F.                 
         aProperties_[13] := aDefCommandList_[13]                                                  // FONTITALIC .F.               
         aProperties_[14] := aDefCommandList_[14]                                                  // FONTUNDERLINE .F.            
         aProperties_[15] := aDefCommandList_[15]                                                  // FONTSTRIKEOUT .F.            
         aProperties_[16] := aDefCommandList_[16]                                                  // ONENTER Nil                  
         aProperties_[17] := aDefCommandList_[17]                                                  // HELPID Nil                   
         aProperties_[18] := aDefCommandList_[18]                                                  // TABSTOP .T.                  
         aProperties_[19] := aDefCommandList_[19]                                                  // VISIBLE .T.                  
         aProperties_[20] := aDefCommandList_[20]                                                  // READONLY .F.                 
         aProperties_[21] := aDefCommandList_[21]                                                  // RIGHTALIGN .F.               
         aProperties_[22] := aDefCommandList_[22]                                                  // BACKCOLOR NIL                
         aProperties_[23] := aDefCommandList_[23]                                                  // FONTCOLOR NIL                
         aProperties_[24] := aDefCommandList_[24]                                                  // INPUTMASK "99,999,999,999.99"
         aProperties_[25] := aDefCommandList_[25]                                                  // FORMAT Nil                   
         aProperties_[26] := aDefCommandList_[26]                                                  // NUMERIC .T.                  
         aProperties_[27] := aDefCommandList_[27]                                                  // VALUE Nil                    
         aProperties_[28] := aDefCommandList_[28]                                                  // END TEXTBOX                  

         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

         ///////////////////////////////////////////////////////////////////////////////////////////////////
         // @ <nRow> ,<nCol> TEXTBOX <ControlName> OF <ParentWindowName> HEIGHT <nHeight>;
         //    VALUE <nValue> WIDTH <nWidth> NUMERIC INPUTMASK <cMask> FONT <cFontName> SIZE <nFontSize>;     
         //    TOOLTIP <cToolTipText> ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]                        
         //
         ///////////////////////////////////////////////////////////////////////////////////////////////////
         
         cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " TEXTBOX " +;
         			  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[5] + "; " + CRLF +;
         			  LDCS_iLevel(3) + aProperties_[27] + " " + aProperties_[4] + " NUMERIC " +;
         			  aProperties_[24] + " " + aProperties_[6] + " " + aProperties_[7] + ";" + CRLF +;
         			  LDCS_iLevel(3) + aProperties_[8] + " " + aProperties_[11] + CRLF

      CASE SyntaxType == "DTEF"

			aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE TEXTBOX",""))			   // DEFINE TEXTBOX txbDateField
			aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))							   // ROW    80                  
			aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))							   // COL    280                 
			aProperties_[ 4] := aDefCommandList_[ 4]                                                  // WIDTH  120                 
			aProperties_[ 5] := aDefCommandList_[ 5]                                                  // HEIGHT 24                  
			aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"NAME",""))							   // FONTNAME "Arial"           
			aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"FONT",""))							   // FONTSIZE 9                 
			aProperties_[ 8] := aDefCommandList_[ 8]                                                  // TOOLTIP ""                 
			aProperties_[ 9] := aDefCommandList_[ 9]                                                  // ONCHANGE Nil               
			aProperties_[10] := aDefCommandList_[10]                                                  // ONGOTFOCUS Nil             
			aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"ONLOSTFOCUS","ON LOSTFOCUS"))	// ONLOSTFOCUS Nil        
			aProperties_[12] := aDefCommandList_[12]                                                  // FONTBOLD .F.     
			aProperties_[13] := aDefCommandList_[13]                                                  // FONTITALIC .F.   
			aProperties_[14] := aDefCommandList_[14]                                                  // FONTUNDERLINE .F.
			aProperties_[15] := aDefCommandList_[15]                                                  // FONTSTRIKEOUT .F.
			aProperties_[16] := aDefCommandList_[16]                                                  // ONENTER Nil      
			aProperties_[17] := aDefCommandList_[17]                                                  // HELPID Nil       
			aProperties_[18] := aDefCommandList_[18]                                                  // TABSTOP .T.      
			aProperties_[19] := aDefCommandList_[19]                                                  // VISIBLE .T.      
			aProperties_[20] := aDefCommandList_[20]                                                  // READONLY .F.     
			aProperties_[21] := aDefCommandList_[21]                                                  // RIGHTALIGN .F.   
			aProperties_[22] := aDefCommandList_[22]                                                  // BACKCOLOR Nil    
			aProperties_[23] := aDefCommandList_[23]                                                  // FONTCOLOR Nil    
			aProperties_[24] := aDefCommandList_[24]                                                  // FIELD MYFILE->F1 
			aProperties_[25] := aDefCommandList_[25]                                                  // INPUTMASK Nil    
			aProperties_[26] := aDefCommandList_[26]                                                  // FORMAT Nil       
			aProperties_[27] := aDefCommandList_[27]                                                  // DATE .T.         
			aProperties_[28] := aDefCommandList_[28]                                                  // VALUE CTOD("")   
			aProperties_[29] := aDefCommandList_[29]   																// END TEXTBOX                

         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

         ///////////////////////////////////////////////////////////////////////////////////////////////////
         // @ <nRow> ,<nCol> TEXTBOX <ControlName> OF <ParentWindowName> HEIGHT <nHeight> FIELD <FieldName>;
         //    VALUE <nValue> WIDTH <nWidth>  FONT <cFontName> SIZE <nFontSize> TOOLTIP <cToolTipText>;
         //    DATE ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
         /////////////////////////////////////////////////////////////////////////////////////////////////// 

			cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " TEXTBOX " +;
						  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[5] + " " + aProperties_[24] + ";" + CRLF +;
						  LDCS_iLevel(3) + aProperties_[28] + " " + aProperties_[4] + " " + aProperties_[6] +;
						  " " + aProperties_[7] + " " + aProperties_[8] + "; " + CRLF +;
						  LDCS_iLevel(3) + "DATE " + aProperties_[11] + CRLF


      CASE SyntaxType == "DTEV"

			aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE TEXTBOX",""))		   	// DEFINE TEXTBOX txbDate
			aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))						   	// ROW    120        
			aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))						   	// COL    100        
			aProperties_[ 4] := aDefCommandList_[ 4]                                                  // WIDTH  120
			aProperties_[ 5] := aDefCommandList_[ 5]                                                  // HEIGHT 24 
			aProperties_[ 6] := ALLTRIM(STRTRAN(aDefCommandList_[ 6],"NAME",""))						   	// FONTNAME "Arial"  
			aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"FONT",""))						   	// FONTSIZE 9        
			aProperties_[ 8] := aDefCommandList_[ 8]                                                  // TOOLTIP ""     
			aProperties_[ 9] := aDefCommandList_[ 9]                                                  // ONCHANGE Nil   
			aProperties_[10] := aDefCommandList_[10]                                                  // ONGOTFOCUS Nil 
			aProperties_[11] := ALLTRIM(STRTRAN(aDefCommandList_[11],"ONLOSTFOCUS","ON LOSTFOCUS"))   // ONLOSTFOCUS Nil   
			aProperties_[12] := aDefCommandList_[12]                                                  // FONTBOLD .F.     
			aProperties_[13] := aDefCommandList_[13]                                                  // FONTITALIC .F.   
			aProperties_[14] := aDefCommandList_[14]                                                  // FONTUNDERLINE .F.
			aProperties_[15] := aDefCommandList_[15]                                                  // FONTSTRIKEOUT .F.
			aProperties_[16] := aDefCommandList_[16]                                                  // ONENTER Nil      
			aProperties_[17] := aDefCommandList_[17]                                                  // HELPID Nil       
			aProperties_[18] := aDefCommandList_[18]                                                  // TABSTOP .T.      
			aProperties_[19] := aDefCommandList_[19]                                                  // VISIBLE .T.      
			aProperties_[20] := aDefCommandList_[20]                                                  // READONLY .F.     
			aProperties_[21] := aDefCommandList_[21]                                                  // RIGHTALIGN .F.   
			aProperties_[22] := aDefCommandList_[22]                                                  // BACKCOLOR NIL    
			aProperties_[23] := aDefCommandList_[23]                                                  // FONTCOLOR NIL    
			aProperties_[24] := aDefCommandList_[24]                                                  // INPUTMASK Nil    
			aProperties_[25] := aDefCommandList_[25]                                                  // FORMAT Nil       
			aProperties_[26] := aDefCommandList_[26]                                                  // DATE .T.         
			aProperties_[27] := aDefCommandList_[27]                                                  // VALUE CTOD("")   
			aProperties_[28] := aDefCommandList_[28]                                                  // END TEXTBOX      

         aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
         aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

         ///////////////////////////////////////////////////////////////////////////////////////////////////
         // @ <nRow> ,<nCol> TEXTBOX <ControlName> OF <ParentWindowName> HEIGHT <nHeight> FIELD <FieldName>;
         //    VALUE <nValue> WIDTH <nWidth>  FONT <cFontName> SIZE <nFontSize> TOOLTIP <cToolTipText>;
         //    DATE ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]
         /////////////////////////////////////////////////////////////////////////////////////////////////// 

			cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " TEXTBOX " +;
						  aProperties_[1] + " OF ~LDCS_Form " + aProperties_[5] +  ";" + CRLF +;
						  LDCS_iLevel(3) + aProperties_[27] + " " + aProperties_[4] + " " + aProperties_[6] +;
						  " " + aProperties_[7] + " " + aProperties_[8] + "; " + CRLF +;
						  LDCS_iLevel(3) + "DATE " + aProperties_[11] + CRLF

   ENDCASE

   sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

   RETURN cRetVal






















