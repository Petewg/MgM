/************************************************************************************ 
 * Program Name....: Fmg2Prg.Prg
 * System Name.....: HMG Assistant Release 2007
 * Purpose ........: Convert HMG Control Objects Alternate Syntax to @... Commands statement
 *
 * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>
 *                   http://harbourminigui.googlepages.com
 *  
 * Author..........: Danny A. del Pilar
 * E-mail..........: dhaine_adp@yahoo.com
 * Note............: Copyright (c) 2007 Danny A. del Pilar, All Rights Reserved.
 *                   La DALE-Aid Creative Solutions, Philippines
 *
 * Date Created....: September 24, 2007 02:18:12 PM, Tabuk, KSA
 * Last Updated....:
 *  
 * Revision History: 
 *
 * TODO LIST:
 *   Notes: @... MONTHCALENDAR and @... CHECKBUTTON are not included in the conversion
 *				process because both of those command are variation syntax of the 
 *				DATEPICKER and BUTTON commands respectively.
 *
 *
 *************************************************************************************/


#include "minigui.ch"
*#include "inkey.ch"
*#include "common.ch"
#include "dale-aid.ch"

*#define CRLF  HB_OSNEWLINE()

************************
function Main()

   PRIVATE ValidationInProgress := FALSE

   PRIVATE cInputFile    := ""
   PRIVATE cOutputFile   := ""
   PRIVATE cTargetFolder := ""

   DEFINE WINDOW frmFmg2Prg;
      AT 0,0;
      WIDTH 483 HEIGHT 328;
      TITLE "HMG Prg (Source Code) Generator";
      ICON "DaleAid.ico";
      MAIN NOMAXIMIZE;
      ON INTERACTIVECLOSE ValidationInProgress := TRUE;
      FONT "Arial" SIZE 9     
      
      DEFINE MAINMENU
         DEFINE POPUP "&File"
            ITEM "E&xit" ACTION frmFmg2Prg.Release
         END POPUP
         
         DEFINE POPUP "&Help"
            ITEM "Using Form File Converter" ACTION NIL
         END POPUP
         
      END MENU

      @ 23, 20 LABEL lblSourceFile OF frmFmg2Prg VALUE "&Source HMG Form File:";
         WIDTH 135 HEIGHT 20 FONT "ARIAL" SIZE 9
   
      @ 20,157 TEXTBOX txbSourceFile OF frmFmg2Prg HEIGHT 24 VALUE "" WIDTH 250;
         FONT "ARIAL" SIZE 9 TOOLTIP "" MAXLENGTH 2000 ON LOSTFOCUS Validation(This.Name)
   
      @ 18,410 BUTTON btnSourceFile OF frmFmg2Prg;
         PICTURE "folder.bmp" ACTION ButtonSourceFile();
         WIDTH 28 HEIGHT 27;
         TOOLTIP "Specify source file to convert."

      @ 53, 22 FRAME FrameOutput OF frmFmg2Prg CAPTION "Output:" WIDTH 432 HEIGHT 80
   
      @ 73, 30 LABEL lblTargetFolder OF frmFmg2Prg VALUE "Output Folder Location:";
         WIDTH 130 HEIGHT 20 FONT "ARIAL" SIZE 9   
   
      @ 70,166 TEXTBOX txbTargetFolder OF frmFmg2Prg HEIGHT 24 VALUE "" WIDTH 250;
         FONT "ARIAL" SIZE 9 TOOLTIP "" MAXLENGTH 2000
         
      @ 69,419 BUTTON btnTargetFolder OF frmFmg2Prg;
         PICTURE "folder.bmp" ACTION frmFmg2Prg.txbTargetFolder.Value := GETFOLDER() WIDTH 28 HEIGHT 27

      @ 103,30 LABEL lblOutputFileName OF frmFmg2Prg VALUE "Output File Name:";
         WIDTH 100 HEIGHT 20 FONT "ARIAL" SIZE 9 

      @ 100,140 TEXTBOX txbOutputFileName OF frmFmg2Prg HEIGHT 24;
         VALUE "" WIDTH 305;
         FONT "ARIAL" SIZE 9 TOOLTIP "" MAXLENGTH 255 ON LOSTFOCUS Validation(This.Name)
   
      @ 240,20 BUTTON btnFmg2Prg OF frmFmg2Prg CAPTION "Generate &Prg Source File";
         ACTION AST_CodeConverter() WIDTH 250 HEIGHT 24
         
      @ 240,270 BUTTON btnCancel OF frmFmg2Prg CAPTION "&Exit" ACTION frmFmg2Prg.Release;
         WIDTH 185 HEIGHT 24
   
      @ 140,22 FRAME FrameOption OF frmFmg2Prg CAPTION "File Convertion Options:" WIDTH 432 HEIGHT 90 

      @ 157,40 CHECKBOX chkDirectives OF frmFmg2PrG;
         CAPTION "Include Compiler Directives";
         WIDTH 390 HEIGHT 18 VALUE .F.

      @ 178,40 CHECKBOX chkSourceComment OF frmFmg2Prg;
         CAPTION "Insert Source File Comment Header";
         WIDTH 390 HEIGHT 18 VALUE .F.
   
      @ 201,40 CHECKBOX chkFunctionComment OF frmFmg2Prg;
         CAPTION "Insert Function Comment Header";
         WIDTH 390 HEIGHT 18 VALUE .F.    
   
   END WINDOW

   frmFmg2Prg.Center
   frmFmg2Prg.Activate

   RETURN NIL




********************************
static function ButtonSourceFile

   frmFmg2Prg.txbSourceFile.Value := GETFILE({{"HMG Form Files","*.fmg"}})
   Validation("TXBSOURCEFILE")
   
   RETURN NIL
   



*****************************************
static function Validation(ControlName)

   LOCAL cMsg      := ""
   LOCAL cMsgTitle := ""
   
   LOCAL TVar1 := ""
   LOCAL TVar2 := ""
   LOCAL TVar3 := ""
   LOCAL ControlObject

   BEGIN SEQUENCE
   
   ControlObject := ALLTRIM(UPPER(ControlName))

   IF ValidationInProgress
      BREAK
   ENDIF
   
   ValidationInProgress := TRUE
   
   DO CASE
      CASE ControlObject == "TXBSOURCEFILE"
         IF !EMPTY(frmFmg2Prg.txbSourceFile.Value)
            TVar1 := ALLTRIM(frmFmg2Prg.txbSourceFile.Value)
            TVar2 := RAT("\", TVar1)                           // extract HMG form file name and drop folder location
            
            TVar3 := SUBSTR(TVar1, TVar2+1)
            TVar3 := STRTRAN(TVar3,".Fmg",".Prg")              // change extension name from HMG Fmg to Prg
            
            frmFmg2Prg.txbOutputFileName.Value := TVar3
            frmFmg2Prg.txbTargetFolder.Value := SUBSTR(Tvar1,1,TVar2-1)
            
            IF FILE(frmFmg2Prg.txbTargetFolder.Value + "\" + frmFmg2Prg.txbOutputFileName.Value)
               MSGSTOP("A source code of the same name as the output file name is already exist." + CRLF +;
                       "Please choose another name for the output file.","HMG Assistant Write Error")
               frmFmg2Prg.txbOutputFilename.Setfocus()
               BREAK
            ENDIF
         ENDIF

      CASE ControlObject == "TXBOUTPUTFILENAME"
         IF FILE(frmFmg2Prg.txbTargetFolder.Value + "\" + frmFmg2Prg.txbOutputFileName.Value)
            MSGSTOP("A source code of the same name as the output file name is already exist." + CRLF +;
                    "Please choose another name for the output file.","HMG Assistant Write Error")
            frmFmg2Prg.txbOutputFilename.Setfocus()
            BREAK
         ENDIF      
   ENDCASE  
   END SEQUENCE
   
   ValidationInProgress := FALSE
   RETURN NIL
   



***********************************
static function AST_CodeConverter()

   LOCAL cSourceComment := ""
   LOCAL cFunctionComment := ""
   LOCAL cDirectives := ""
   LOCAL cTextStub := ""
   
   LOCAL BlankLine := CRLF
   
   LOCAL cBuffer := ""
   
   LOCAL cReadString := ""

   PRIVATE cTargetFile := ""
   PRIVATE cSourceFile := ""
   PRIVATE oFileHandle := ""
   
   PRIVATE sCtrlObjects := ""							// variable to hold control objects roster
   
	sCtrlObjects += LDCS_iLevel(1) + REPLICATE("/",99) + CRLF
	sCtrlObjects += LDCS_iLevel(1) + "// Form Control Objects Roster:" + CRLF
	sCtrlObjects += LDCS_iLevel(1) + "// -------------------------------" + CRLF + LDCS_iLevel(1) + "// " + CRLF
   
   cTextStub := LDCS_TextStub() 
   cSourceComment := LDCS_SourceComment()       // format La DALE-Aid Creative Solutions source comment header
   cFunctionComment := LDCS_FunctionComment()   // format La DALE-Creative Solutions Function Comment Header
   cDirectives := LDCS_CompilerOptions()        // set default La DALE-Aid Creative Solutions include headers

   *- setup the output file
   cTargetFile := ALLTRIM(frmFmg2Prg.txbTargetFolder.Value) + "\" + ALLTRIM(frmFmg2Prg.txbOutputFileName.Value)
   cSourceFile := ALLTRIM(frmFmg2Prg.txbSourceFile.Value)

	cBuffer += cTextStub									// insert credit banner

   IF frmFmg2Prg.chkSourceComment.Value = TRUE
      cBuffer += cSourceComment + BlankLine
   ENDIF

   IF frmFmg2Prg.chkDirectives.Value = TRUE
      cBuffer += cDirectives + CRLF
   ENDIF

   IF frmFmg2Prg.chkFunctionComment.Value = TRUE
      cBuffer += cFunctionComment + CRLF
   ENDIF

   BEGIN SEQUENCE

   oFileHandle := TFileRead():New(cSourceFile,4096)     // set variable to source HMG form file
   oFileHandle:Open()                                   // Open file and
   IF oFileHandle:Error()                               // verify file open if successful
      MSGSTOP("Unable to open the specified file.","Open error")
      BREAK
   ENDIF

   cBuffer += BlankLine

   WHILE oFileHandle:MORETOREAD()
      cReadString := ALLTRIM(oFileHandle:READLINE())
      
      DO CASE
         CASE cReadString == "END WINDOW"
            cBuffer += LDCS_iLevel(1) + cReadString + BlankLine
            
            cBuffer += LDCS_iLevel(1) + "~LDCS_Form.Center" + CRLF
            cBuffer += LDCS_iLevel(1) + "~LDCS_Form.Activate" + CRLF
            cBuffer += LDCS_iLevel(1) + "RETURN NIL" + CRLF + CRLF
            
            EXIT
            
         CASE "DEFINE WINDOW TEMPLATE" $ cReadString
            cBuffer += LDCS_iLevel(1) + cReadString + CRLF + BlankLine
            
            *-> insert La DALE-Aid Default Windows Defintion Syntax
            cBuffer += LDCS_iLevel(1) + "DEFINE WINDOW ~LDCS_Form;" + CRLF
            cBuffer += LDCS_iLevel(2) + "AT 0,0;" + CRLF
            cBuffer += LDCS_iLevel(2) + "WIDTH n HEIGHT n;" + CRLF
            cBuffer += LDCS_iLevel(2) + 'TITLE "DALE-AID";' + CRLF
            cBuffer += LDCS_iLevel(2) + 'ICON <Path> + "DaleAid.ico";' + CRLF
            cBuffer += LDCS_iLevel(2) + "MAIN NOMAXIMIZE;" + CRLF
            cBuffer += LDCS_iLevel(2) + 'FONT "Arial" SIZE 9' + CRLF
      
         CASE "ANIMATEBOX" $ cReadString; cBuffer += AST_AnimateBox(cReadString,"END ANIMATEBOX")
         CASE "BROWSE" $ cReadString    ; cBuffer += AST_Browse(cReadString,"END BROWSE")
         CASE "BUTTON" $ cReadString    ; cBuffer += AST_Button(cReadString,"END BUTTON")    
         CASE "CHECKBOX" $ cReadString  ; cBuffer += AST_CheckBox(cReadString,"END CHECKBOX")

         CASE "CHECKBUTTON" $ cReadString
            cBuffer += LDCS_iLevel(1) + cReadString + CRLF

         CASE "COMBOBOX" $ cReadString  ; cBuffer += AST_ComboBox(cReadString,"END COMBOBOX")
         CASE "DATEPICKER" $ cReadString; cBuffer += AST_DatePicker(cReadString,"END DATEPICKER")
         CASE "EDITBOX" $ cReadString   ; cBuffer += AST_EditBox(cReadString,"END EDITBOX")
         CASE "FRAME" $ cReadString     ; cBuffer += AST_Frame(cReadString,"END FRAME")
         CASE "GRID" $ cReadString      ; cBuffer += AST_Grid(cReadString,"END GRID")
         CASE "HYPERLINK" $ cReadString ; cBuffer += AST_HyperLink(cReadString,"END HYPERLINK")
         CASE "IMAGE" $ cReadString     ; cBuffer += AST_Image(cReadString,"END IMAGE")
         CASE "IPADDRESS" $ cReadString ; cBuffer += AST_IPAddress(cReadString,"END IPADDRESS")
         CASE "LABEL" $ cReadString     ; cBuffer += AST_Label(cReadString,"END LABEL")
         CASE "LISTBOX" $ cReadString   ; cBuffer += AST_ListBox(cReadString,"END LISTBOX")

         CASE "MONTHCALENDAR" $ cReadString
            cBuffer += LDCS_iLevel(2) + cReadString + CRLF

         CASE "PLAYER" $ cReadString     ; cBuffer += AST_Player(cReadString,"END PLAYER")
         CASE "PROGRESSBAR" $ cReadString; cBuffer += AST_ProgressBar(cReadString,"END PROGRESSBAR")
         CASE "RADIOGROUP" $ cReadString ; cBuffer += AST_RadioGroup(cReadString,"END RADIOGROUP")
         CASE "RICHEDITBOX" $ cReadString; cBuffer += AST_RichEditBox(cReadString, "END RICHEDITBOX")
         CASE "SLIDER" $ cReadString     ; cBuffer += AST_Slider(cReadString,"END SLIDER")
         CASE "SPINNER" $ cReadString    ; cBuffer += AST_Spinner(cReadString,"END SPINNER")
         CASE "TEXTBOX" $ cReadString    ; cBuffer += AST_TextBox(cReadString,"END TEXTBOX")

      *--> all unsupported translations will go here:
      OTHERWISE
         IF .NOT. "*" $ cReadString .OR. EMPTY(cReadString)
            IF "DEFINE" $ cReadString .OR. "END" $ cReadString
               cBuffer += LDCS_iLevel(2) + cReadString + CRLF
            ELSE
               cBuffer += LDCS_iLevel(3) + cReadString + CRLF
            ENDIF
         ENDIF
      ENDCASE
      
   ENDDO
   
	*-> append the control objects roster
	cBuffer += CRLF + sCtrlObjects + LDCS_iLevel(1) + "// " + CRLF
	cBuffer += LDCS_iLevel(1) + REPLICATE("/",99) + CRLF + CRLF + CRLF
   
   *-- and finally write the output file to hard disk
   MEMOWRIT(cTargetFile, cBuffer)
   MSGINFO("The File: " + cTargetFile + " has been generated successfully.","Operation Completed")
   frmFmg2Prg.Release
   END SEQUENCE
   oFileHandle:Close() 
   RETURN NIL



*******************************
static function LDCS_TextStub()

	LOCAL cDate    := "",;
			acMonth_ := {"January","February","March","April","May","June","July","August","September","October","November","December"}
	
	cDate := "Date Created: " + ALLTRIM(STR(DAY(DATE()))) + " " + acMonth_[ MONTH(DATE()) ] + " " +;
				 ALLTRIM(STR(YEAR(DATE()))) + " Time: " + TIME()

   RETURN "*************************************************************************************" + CRLF +;
          "** This file has been automatically generated by HMG Assistant® Release 2007" + CRLF +;
          "** " + CRLF +;
          "** " + cDate + CRLF +;
          "** " + CRLF +;
          "** HMG Assistant® Release 2007  Created by Danny A. del Pilar" + CRLF +;
          "** Copyright © 2007 La DALE-Aid® Creative Solutions, All Rights Reserved." + CRLF +;
          "**"  + CRLF +;
          "*************************************************************************************" + CRLF + CRLF




************************************
static function LDCS_SourceComment()

   RETURN CRLF +;
         "/************************************************************************************" + CRLF +;
         " * Program Name....: " + CRLF +;
         " * System Name.....: " + CRLF +;
         " * Purpose ........: " + CRLF +;
         " *" + CRLF +;
         " * Syntax..........: Harbour MiniGUI Library by Roberto Lopez <harbourminigui@gmail.com>" + CRLF +;
         " *                   http://harbourminigui.googlepages.com" + CRLF +;
         " *  " + CRLF +;
         " * Author..........: Danny A. del Pilar" + CRLF +;
         " * E-mail..........: dhaine_adp@yahoo.com" + CRLF +;
         " * Note............: Copyright © 2007 Danny A. del Pilar, All Rights Reserved." + CRLF +;
         " *                   La DALE-Aid® Creative Solutions, Philippines" + CRLF +;
         " *" + CRLF +;
         " * Date Created....: "  + CRLF +;
         " * Last Updated....: " + CRLF +;
         " * " + CRLF +;
         " * CHANGE LOG:" + CRLF +;
         " * "  + CRLF +;
         " * "  + CRLF +;
         " * "  + CRLF +;
         " * TODO LIST:" + CRLF +;
         " * "  + CRLF +;
         " * "  + CRLF +;
         " * Revision History:" + CRLF +;
         " * -----------------" + CRLF +;
         " * " + CRLF +;
         " * " + CRLF +;
         " *************************************************************************************/" + CRLF



**************************************
static function LDCS_FunctionComment()

   RETURN CRLF +;
         "**************************************************************************************" + CRLF +;
         "** Function Name...:" + CRLF +;
         "** Called by.......:" + CRLF +;
         "**" + CRLF +;
         "** Syntax..........:" + CRLF +;
         "**" + CRLF +;
         "** Parameters......:" + CRLF +;
         "**" + CRLF +;
         "** Returns.........:" + CRLF +;
         "**" + CRLF +;
         "** Description.....:" + CRLF +;
         "**" + CRLF +;
         "** Notes...........:" + CRLF +;
         "**" + CRLF +;
         "***************************************************************************************" + CRLF +;
         "function Main()" + CRLF


**************************************
static function LDCS_CompilerOptions()

   RETURN '#include "hmg.ch"' + CRLF + CRLF



//----------------------------- START OF PUBLIC FUNCTION DECLARATION -------------------------------

*******************************
function LDCS_ILevel(nLevel)

   LOCAL cRetVal := ""
   LOCAL anIndentLevel_ := {3,6,9,12,15,18,21}     // indention level from 1 to 7 positions
   cRetVal := SPACE( anIndentLevel_[ nLevel ] )
   RETURN cRetVal


//----------------------------- END OF PUBLIC FUNCTION DECLARATION ---------------------------------
