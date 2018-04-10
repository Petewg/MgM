 ************************************************************************************ 
 * Program Name....: AST_IPAddress.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Converts HMG DEFINE IPADDRESS Command to @ ... Command Syntax from HMG Form File
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 *                   http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 *                   La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: October 10, 2007 02:50:05 AM, Tabuk, KSA
 * Last Updated....:
 *
 *
 * Revision History: 
 * -----------------
 * October 10, 2007 03:08:30 AM, Tabuk, KSA - Source Code completion.
 *
 *
 * October 10, 2007 02:50:05 AM, Tabuk, KSA
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
** Function Name...: AST_IPAddress()
** Called by.......: AST_CodeConverter()
**
** Syntax..........: AST_IPADDRESS(cExp1, anExp2,cExp3)
**
** Parameters......: WHERE: cExp1  => is the last string read from the source form file
**                          anExp2 => is a numeric array containing the indention in terms
**                                       of spaces 
**                          cExp3  => is the termination string to signal the end of
**                                       define command
**
** Returns.........: cRetVal => contains the converted @ ... IPADDRESS Command Syntax
**
** Description.....: Converts DEFINE IPADDRESS Command to @ ... IPADDRESS Command Syntax
**
** Notes...........: Inherrited PRIVATE Variables used from AST_Converter():
**                      1. oFileHandle - Object Container for TFileRead() CLASS
**                      2. sCtrlObjects - Container for Control Objects Roster
**
***************************************************************************************
function AST_IPAddress(cReadString,cTerminator)

   LOCAL cRetVal := ""

   LOCAL aDefCommandList_ := {},;
         aProperties_     := {}
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
   // HMG LABEL @... Command Snytax:
   // ------------------------------
   // @ <nRow> ,<nCol> 
   //    IPADDRESS <ControlName> 
   //    [ OF | PARENT <ParentWindowName> ]  
   //    [ HEIGHT <nHeight> ]  
   //    [ WIDTH <nWidth> ]
   //    [ VALUE <anValue> ]
   //    [ FONT <cFontName> SIZE <nFontSize> ]
   //    [ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]
   //    [ TOOLTIP <cToolTipText> ]    
   //    [ ON CHANGE <OnChangeProcedure> | <bBlock> ]    
   //    [ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]
   //    [ ON LOSTFOCUS <OnGotFocusProcedur> | <bBlock> ]
   //    [ HELPID <nHelpId> ] 
   //    [ INVISIBLE ]
   //    [ NOTABSTOP ]
   //------------------------------------------------------------------------------------------------
   // @ <nRow> ,<nCol> IPADDRESS <ControlName> OF <ParentWindowName>
   //    VALUE <anValue> ON LOSTFOCUS <OnGotFocusProcedur>
   //
   //////////////////////////////////////////////////////////////////////////////////////////////////

   aProperties_[ 1] := ALLTRIM(STRTRAN(aDefCommandList_[ 1],"DEFINE IPADDRESS",""))       // DEFINE IPADDRESS IpAddress_1
   aProperties_[ 2] := ALLTRIM(STRTRAN(aDefCommandList_[ 2],"ROW",""))                    // ROW    30
   aProperties_[ 3] := ALLTRIM(STRTRAN(aDefCommandList_[ 3],"COL",""))                    // COL    30
   aProperties_[ 4] := aDefCommandList_[ 4]                                               // WIDTH  120             
   aProperties_[ 5] := aDefCommandList_[ 5]                                               // HEIGHT 24              
   aProperties_[ 6] := aDefCommandList_[ 6]                                               // VALUE { 0 , 0 , 0 , 0 }
   aProperties_[ 7] := ALLTRIM(STRTRAN(aDefCommandList_[ 7],"NAME",""))                   // FONTNAME "Arial"
   aProperties_[ 8] := ALLTRIM(STRTRAN(aDefCommandList_[ 8],"FONT",""))                   // FONTSIZE 9
   aProperties_[ 9] := aDefCommandList_[ 9]                                               // TOOLTIP ""    
   aProperties_[10] := aDefCommandList_[10]                                               // ONCHANGE Nil  
   aProperties_[11] := aDefCommandList_[11]                                               // ONGOTFOCUS Nil
   aProperties_[12] := ALLTRIM(STRTRAN(aDefCommandList_[12],"ON","ON "))                  // ONLOSTFOCUS Nil
   aProperties_[13] := aDefCommandList_[13]                                               // FONTBOLD .F.     
   aProperties_[14] := aDefCommandList_[14]                                               // FONTITALIC .F.   
   aProperties_[15] := aDefCommandList_[15]                                               // FONTUNDERLINE .F.
   aProperties_[16] := aDefCommandList_[16]                                               // FONTSTRIKEOUT .F.
   aProperties_[17] := aDefCommandList_[17]                                               // HELPID Nil       
   aProperties_[18] := aDefCommandList_[18]                                               // TABSTOP .T.      
   aProperties_[19] := aDefCommandList_[19]                                               // VISIBLE .T.      
   aProperties_[20] := aDefCommandList_[20]                                               // END IPADDRESS    

   *- pad short numbers row,column
   aProperties_[2] := RIGHT(SPACE(3) + aProperties_[2],3)
   aProperties_[3] := RIGHT(SPACE(3) + aProperties_[3],3)

   cRetVal += LDCS_iLevel(2) + "@ " + aProperties_[2] + "," + aProperties_[3] + " IPADDRESS " +;
              aProperties_[1] + " OF ~LDCS_Form " + aProperties_[6] + " " + aProperties_[12] + CRLF

   sCtrlObjects += LDCS_iLevel(1) + "// " + "~LDCS_Form." + aProperties_[1] + ".Value" + CRLF

   RETURN cRetVal











