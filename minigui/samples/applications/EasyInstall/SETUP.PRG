/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2004-2006 Grigory Filatov <gfilatov@inbox.ru>
 *
 * July 2005 Additions as noted by Joe Fanucchi <drjoe@meditrax.com>
 *
 *  FOR PROGRAMMING:
 *   Changed the grammar of window titles and of some instructions
 *   Renamed most controls (so I can keep them clear in my head)
 *   Put all the control visibility statements in ShowStep() and HideStep() functions, to minimize repetitive code
 *
 *  FOR THE USER:
 *   Changed the size of the Form_2 window, and the size and position of RichEdit boxes, frames, and buttons
 *   Added the ability to specify an icon to be used for the Desktop and Start Menu links
 *   Added the ability for the user to confirm creation of a new destination folder
 *   Added a RichEdit box to notify the user of installation success/failure
*/
*----------------------------------------------------------------------------------*

#include "minigui.ch"
#include "fileio.ch"

#define MsgYesNo( c, t )   MsgYesNo( c, t, .F., , .F. )
#define MsgNoYes( c )   MsgYesNo( c, "Confirming...", .T., , .F. )
#define MsgAlert( c )   MsgExclamation( c, "Error !", , .F. )

#define EWX_REBOOT      2

#define WM_CLOSE        0x0010

*------------------------------------------------------------*
PROCEDURE Main
*------------------------------------------------------------*
LOCAL x := GetDesktopWidth()
LOCAL y := GetDesktopHeight()

LOCAL cPath     := GetStartUpFolder() + "\"
LOCAL cFileName := cFileNoExt( GetExeFileName() )
LOCAL cCfgFile  := cPath + Lower( cFileName ) + ".ini"

* JF: made some small changes to the grammar, not a significant change:
LOCAL cMsg   := "Do you wish to cancel this installation?"

LOCAL aLink        := {}
LOCAL cWhat2Link2  := ""
* JF: added the ability to specify an icon for the Desktop and Start Menu links
LOCAL cIconName    := ''
LOCAL cImgExt      := "bmp"
* JF: changed the default install folder to "C:\Program Files\" + cProgramName
LOCAL cDestinPath
LOCAL cLinkName    := ""
LOCAL cOnDesktop   := "0"
LOCAL cProgramName := ""
LOCAL cSMenuFolder := ""
LOCAL cTmpFld      := ""
LOCAL i
LOCAL lChange      := .F.
LOCAL lExit        := .F.
LOCAL lNeedReboot  := .F.
LOCAL lNoLinks     := .F.
LOCAL lOnDesktop   := .F.
LOCAL lStartMenu   := .F.

*------------------------------------------------------------*

BEGIN INI FILE cCfgFile

GET cDestinPath  SECTION "General" ENTRY "InstallPath" DEFAULT cDestinPath
GET cProgramName SECTION "General" ENTRY "ProgramName" DEFAULT cProgramName
* JF: added the ability to specify an icon for the Desktop and Start Menu links
GET cIconName    SECTION "General" ENTRY "IconName"    DEFAULT cIconName
GET lNeedReboot  SECTION "General" ENTRY "NeedReboot"  DEFAULT lNeedReboot

FOR i := 1 TO 99
  GET cLinkName   SECTION "Links" ENTRY "LinkName" + LTRIM( STR( i )) DEFAULT ""
  GET cWhat2Link2 SECTION "Links" ENTRY "FileName" + LTRIM( STR( i )) DEFAULT ""
  GET cOnDesktop  SECTION "Links" ENTRY "OnDesktop" + LTRIM( STR( i )) DEFAULT cOnDesktop
  IF EMPTY( cLinkName)
    EXIT
  ELSE
    Aadd( aLink, { cLinkName, cWhat2Link2, VAL( cOnDesktop ) })
  ENDIF
NEXT

GET cSMenuFolder SECTION "Folder" ENTRY "StartMenuFolder" DEFAULT cSMenuFolder

END INI

*------------------------------------------------------------*

IF FileSize( cCfgFile ) == 0
  BEGIN INI FILE cCfgFile

  * JF: changed the default install path to "C:\Program Files\" + cProgramName
  SET SECTION "General" ENTRY "InstallPath" TO cDestinPath
  SET SECTION "General" ENTRY "ProgramName" TO cProgramName
  SET SECTION "General" ENTRY "NeedReboot"  TO lNeedReboot
  * JF: added the ability to specify an icon for the Desktop and Start Menu links
  SET SECTION "General" ENTRY "IconName"    TO cIconName

  FOR i := 1 TO LEN( aLink )
    SET SECTION "Links" ENTRY "LinkName" + LTRIM( STR( i )) TO aLink[i][1]
    SET SECTION "Links" ENTRY "FileName" + LTRIM( STR( i )) TO aLink[i][2]
    SET SECTION "Links" ENTRY "OnDesktop" + LTRIM( STR( i )) TO STR( aLink[i][3], 1)
  NEXT

  SET SECTION "Folder" ENTRY "StartMenuFolder" TO cSMenuFolder

  END INI
ENDIF

* JF: Added this variable so the expression is only checked once
IF EMPTY( LEN( aLink ))
  lNoLinks := .T.
ELSE
  lOnDesktop := ASCAN( aLink, { |e| e[3] == 1 } ) > 0
  lStartMenu := ( ASCAN( aLink, { |e| e[3] == 0 } ) > 0 ) .AND. ! EMPTY( cSMenuFolder )
ENDIF

*------------------------------------------------------------*

* JF: changed the default install path to "C:\Program Files\" + cProgramName
IF EMPTY( cDestinPath )              // JF: If the installation path isn't in the SETUP.INI file, create it here
  cDestinPath := GetProgramFilesFolder() + "\" + cProgramName
ENDIF

IF x <= 1024 .AND. y <= 768

  DEFINE WINDOW Form_1 ;
    AT 0,0             ;
    WIDTH x HEIGHT y   ;
    MAIN               ;
    ICON 'setup.ico'   ;                                           // JF: changed the icon to a CD, not a significant change
    NOSIZE NOCAPTION   ;
    ON PAINT ( FillBlue( _HMG_MainHandle ), TextPaint(cProgramName) )

  ON KEY ALT+X  ACTION IIF( MsgYesNo( cMsg, "Cancel ?" ), Form_1.Release, ;
    BringWindowToTop( GetFormHandle( "Form_2" ) ) )
  ON KEY ALT+F4 ACTION IIF( MsgYesNo( cMsg, "Cancel ?" ), Form_1.Release, ;
    BringWindowToTop( GetFormHandle( "Form_2" ) ) )

ELSE

  DEFINE WINDOW Form_1 ;
    AT 0,0             ;
    WIDTH 1024         ;
    HEIGHT 768         ;
    TITLE cProgramName + " Setup" ;
    MAIN               ;
    ICON 'setup.ico'   ;                                           // JF: changed the icon to a CD, not a significant change
    NOSIZE NOMAXIMIZE  ;
    ON PAINT ( FillBlue( _HMG_MainHandle ), TextPaint(cProgramName) ) ;
    ON INTERACTIVECLOSE IIF( lExit, .T., IIF( MsgYesNo( cMsg, "Cancel ?" ), .T., ;
    ( BringWindowToTop( GetFormHandle( "Form_2" ) ), .F. ) ) )

ENDIF

  DEFINE TIMER Timer_1 INTERVAL 75 ;
    ACTION ( BringWindowToTop( GetFormHandle( "Form_2" )), Form_1.Timer_1.Release )

END WINDOW

*------------------------------------------------------------*

DEFINE WINDOW Form_2  ;
  AT 0, 0     ;
  WIDTH 540   ;
  HEIGHT 280 - IF(IsXPThemeActive(), 0, 8) ;             // JF: added height to the window to make more room for buttons at the bottom
  TITLE ""    ;
  NOSYSMENU NOSIZE    ;
  CHILD       ;
  ON INIT ( Form_2.Btn_Fwd2Step2.SetFocus ) ;     // JF: renamed the buttons, not a significant change
  ON RELEASE PostMessage( _HMG_MainHandle, WM_CLOSE, 0, 0 ) ;
  ON INTERACTIVECLOSE IIF( lExit, .T., ( lExit := MsgNoYes( cMsg ), lExit ) ) ;
  FONT 'MS Sans Serif'			 ;
  SIZE 8

  ON KEY ALT+X   ACTION IIF( MsgNoYes( cMsg ), ( lExit := .T., Form_1.Release ), )
  ON KEY ESCAPE  ACTION IIF( MsgNoYes( cMsg ), ( lExit := .T., Form_1.Release ), )

  IF File( cPath + "setup.jpg" )
    cImgExt := "jpg"
  ELSEIF File( cPath + "setup.gif" )
    cImgExt := "gif"
  ENDIF

  @ 0, 0 IMAGE Image_1 ;
    PICTURE cPath + "setup." + cImgExt ;
    WIDTH 163 ;
    HEIGHT 250

  * JF: changed the placement of all buttons and enlarged them from HEIGHT 23 to HEIGHT 26
  @ Form_2.Height - 69, 290 BUTTON Btn_Fwd2Step2 ;                        // JF: this was Btn_1
    CAPTION '&Next >' ;
    ACTION ( HideStep1(), ShowStep2( cProgramName )) ;
    WIDTH 78 ;
    HEIGHT 26

  @ Form_2.Height - 69, 390 BUTTON Btn_Cancel ;                           // JF: this was Btn_2
    CAPTION '&Cancel' ;
    ACTION ( Form_2.Release ) ;
    WIDTH 78 ;
    HEIGHT 26

  @ Form_2.Height - 69, 190 BUTTON Btn_Back2Intro ;                      // JF: this was Btn_3
    CAPTION '< &Back' ;
    ACTION ( HideStep2(), ShowStep1( cProgramName )) ;
    WIDTH 78 ;
    HEIGHT 26

  @ Form_2.Height - 69, 290 BUTTON Btn_4 ;
    CAPTION IIF( lNoLinks, "&Install", '&Next >' ) ;
    ; // JF: if there are no links to be created, proceed to install
    ACTION IIF( lNoLinks, ;
    ; // JF: changed Install() function as described below
    Install( cPath, cDestinPath, aLink, lOnDesktop, lStartMenu, cSMenuFolder, ;
    cProgramName, cIconName, @lNeedReboot ), ;
    ;
    ( HideStep2(), ShowStep3( cProgramName, lOnDeskTop, lStartMenu, lChange ))) ;
    WIDTH 78 ;
    HEIGHT 26

  @ Form_2.Height - 69, 190 BUTTON Btn_Back2Step2 ;                    // JF: this was Btn_5
    CAPTION '< &Back' ;
    ACTION ( HideStep3(), ShowStep2( cProgramName )) ;
    WIDTH 78 ;
    HEIGHT 26

  * JF: Changed Install() function as described below
  @ Form_2.Height - 69, 290 BUTTON Btn_Install ;                       // JF: this was Btn_6
    CAPTION "&Install" ;
    ACTION { || Install( cPath, cDestinPath, aLink, lOnDesktop, lStartMenu, cSMenuFolder, ;
    cProgramName, cIconName, @lNeedReboot ) } ;
    WIDTH 78 ;
    HEIGHT 26

  @ Form_2.Height - 69, 290 BUTTON Btn_Finish ;                        // JF: this was Btn_7
    CAPTION "&Finish" ;
    ACTION ( lExit := .T., IIF( lNeedReboot, ExitWindows( EWX_REBOOT ), Form_2.Release )) ;
    WIDTH 78 ;
    HEIGHT 26

  * JF: enlarged all RICHEDITBOXes, eliminated ON GOTFOCUS statements
  @ 8, 173 RICHEDITBOX Edit_Welcome VALUE "" ;
    WIDTH Form_2.Width - 188 HEIGHT Form_2.Height - 92 ;
    FONT 'MS Sans Serif' SIZE 10 ;
    MAXLENGTH 32768 ;
    ; // ON GOTFOCUS ( Form_2.Btn_Fwd2Step2.SetFocus ) ;
    NOTABSTOP

  @ 8, 173 RICHEDITBOX Edit_IsDestinOK VALUE "" ;
    WIDTH Form_2.Width - 188 HEIGHT Form_2.Height - 165 ;
    FONT 'MS Sans Serif' SIZE 10 ;
    MAXLENGTH 32768 ;
    ; // ON GOTFOCUS ( Form_2.Btn_4.SetFocus ) ;
    NOTABSTOP

  @ 8, 173 RICHEDITBOX Edit_AreLinksOK VALUE "" ;
    WIDTH Form_2.Width - 188 HEIGHT Form_2.Height - 180 ;
    FONT 'MS Sans Serif' SIZE 10 ;
    MAXLENGTH 32768 ;
    ; // ON GOTFOCUS ( Form_2.Btn_Install.SetFocus ) ;
    NOTABSTOP

  @ 8, 173 RICHEDITBOX Edit_Success VALUE "" ;
    WIDTH Form_2.Width - 188 HEIGHT Form_2.Height - IIF( lNeedReboot, 145, 160 );
    FONT 'MS Sans Serif' SIZE 10 ;
    MAXLENGTH 32768 ;
    ; // ON GOTFOCUS ( Form_2.Btn_Install.SetFocus ) ;
    NOTABSTOP

  * JF: Added a box to explain that SETUP.ZIP could not be found
  @ 8, 173 RICHEDITBOX Edit_Failure VALUE "" ;
    WIDTH Form_2.Width - 188 HEIGHT Form_2.Height - 122 ;
    FONT 'MS Sans Serif' SIZE 10 ;
    MAXLENGTH 32768 ;
    ON GOTFOCUS ( Form_2.Btn_Finish.SetFocus ) ;
    NOTABSTOP

  @ Form_2.Height - 144, 173 FRAME Frame_Destin ;
    CAPTION 'Destination Folder' ;
    WIDTH Form_2.Width - 188 ;
    HEIGHT 60 ;
    OPAQUE ;
    FONT 'MS Sans Serif' SIZE 9

  @ Form_2.Height - 121, 182 TEXTBOX Text_Destin VALUE cDestinPath ;
    HEIGHT 24 ;
    WIDTH 250 ;
    FONT 'MS Sans Serif' SIZE 10 ;
    ON GOTFOCUS _PushKey( VK_HOME ) ;
    ON CHANGE ( cDestinPath := Form_2.Text_Destin.Value ) ;
    ON ENTER ( cDestinPath := Form_2.Text_Destin.Value, Form_2.Btn_4.SetFocus )

  @ Form_2.Height - 122, Form_2.Width - 102 BUTTON Btn_Browse ;
    CAPTION '&Browse' ;
    ACTION IIF( EMPTY( cTmpFld := GetFolder( "Select the folder in which you wish" ;
    + CRLF + "to install " + cProgramName + ":" )), , ;
    ( cDestinPath := cTmpFld, Form_2.Text_Destin.Value := cDestinPath )) ;
    WIDTH 75 ;
    HEIGHT 26

  @ Form_2.Height - 164, 173 FRAME Frame_Links ;
    CAPTION 'Shortcuts' ;
    WIDTH Form_2.Width - 188 ;
    HEIGHT 80 ;
    OPAQUE ;
    FONT 'MS Sans Serif' SIZE 9

  @ Form_2.Height - 144, 190 CHECKBOX CheckBox_1 ;
    CAPTION "Create a shortcut to " + cProgramName + " on the Desktop" ;
    VALUE lOnDesktop ;
    WIDTH 300 HEIGHT 26 ;
    ON CHANGE ( lChange := .T., lOnDesktop := Form_2.CheckBox_1.Value )

  @ Form_2.Height - 118, 190 CHECKBOX CheckBox_2 ;
    CAPTION "Create a shortcut to " + cProgramName + " in the Start Menu" ;
    VALUE lStartMenu ;
    WIDTH 300 HEIGHT 26 ;
    ON CHANGE ( lChange := .T., lStartMenu := Form_2.CheckBox_2.Value )

  @ Form_2.Height - 125, 173 FRAME Frame_Reboot ;
    CAPTION 'Restart the computer' ;
    WIDTH Form_2.Width - 188 ;
    HEIGHT 46 ;
    OPAQUE ;
    FONT 'MS Sans Serif' SIZE 9

  * JF: changed "reboot" to "restart", and changed to a horizontal display
  @ Form_2.Height - 111, 202 RADIOGROUP Radio_Reboot ;
    OPTIONS { "Restart &Now", "Restart &Later" } ;
    VALUE 1 WIDTH 90 ;
    SPACING 10 ;
    HORIZONTAL ;
    FONT 'MS Sans Serif' SIZE 9 ;
    ON CHANGE ( lNeedReboot := ( Form_2.Radio_Reboot.Value == 1 ))

END WINDOW

* JF: made some small changes to the grammar:
Form_2.Edit_Welcome.Value := CRLF + " Welcome to the " + cProgramName + " Setup program." ;
    + CRLF + CRLF + " This will install " + cProgramName + " on your computer." ;
    + CRLF + CRLF + " It is strongly recommended that you close all other" ;
    + CRLF + " applications before continuing. This will help prevent" ;
    + CRLF + " any conflicts during the installation process." ;
    + CRLF + CRLF + " Click Next to continue, or Cancel to exit Setup." ;

* JF: changed the instruction to ensure the caption of Btn_4 is correct:
Form_2.Edit_IsDestinOK.Value := CRLF + " Setup will install " + cProgramName ;
  + " in the following" + CRLF ;
  + " folder. To install the program in this folder, click " + IIF( lNoLinks, "Install", "Next" ) + "." ;
  + CRLF + CRLF + " To install the program in a different folder, click Browse" ;
  + CRLF + " and select another folder."

Form_2.Edit_AreLinksOK.Value := CRLF + " Setup can create shortcuts to " + cProgramName ;
  + CRLF + " on the Desktop and on the Start Menu." ;
  + CRLF + CRLF + " Click Install to continue, or Cancel to exit Setup."

* JF: added program name to the notification
Form_2.Edit_Success.Value := CRLF + " Setup has successfully completed the installation" ;
  + CRLF + " of " + cProgramName + "." ;
  + CRLF + CRLF + IIF( lNeedReboot, " You must restart your computer to finish the" ;
  + CRLF + " installation process. Please indicate whether you" ;
  + CRLF + " wish to restart now, or at a later time.", " Click Finish to complete Setup." )

Form_2.Edit_Failure.Value := CRLF + " The file SETUP.ZIP could not be located." ;
  + CRLF + CRLF + " Program installation cannot proceed without this file." ;
  + CRLF + " You should run this Setup program again when the" ;
  + CRLF + " SETUP.ZIP file is available." ;
  + CRLF + CRLF + " Click Exit to exit the Setup program."

* JF: Visibility of controls has been moved to HideStepn() and ShowStepn() functions
HideStep2()
HideStep3()

Form_2.Edit_Success.Visible := .F.
Form_2.Frame_Reboot.Visible := .F.
Form_2.Radio_Reboot.Visible := .F.
Form_2.Btn_Finish.Visible   := .F.
Form_2.Edit_Failure.Visible := .F.

* JF: Display the controls for Step 1:
ShowStep1( cProgramName )

CENTER WINDOW Form_2
CENTER WINDOW Form_1

ACTIVATE WINDOW Form_2, Form_1

RETURN

*------------------------------------------------------------*
STATIC FUNCTION TextPaint( cProgramName )
*------------------------------------------------------------*

  DRAW TEXT IN WINDOW Form_1 AT 12, 17 ;
    VALUE cProgramName ;
    FONT "Times New Roman" SIZE 32 BOLD ITALIC ;
    FONTCOLOR BLACK TRANSPARENT

  DRAW TEXT IN WINDOW Form_1 AT 10, 14 ;
    VALUE cProgramName ;
    FONT "Times New Roman" SIZE 32 BOLD ITALIC ;
    FONTCOLOR WHITE TRANSPARENT

  DRAW TEXT IN WINDOW Form_1 AT Form_1.Height - 54, Form_1.Width - 400 ;
    VALUE "Copyright " + CHR( 169 ) + " 2004-2006 Grigory Filatov, Ukraine. All Rights Reserved." ;
    FONT "Tahoma" SIZE 9 ITALIC ;
    FONTCOLOR { 23, 23, 127 } TRANSPARENT            // JF: changed the fontcolor, not a significant change

RETURN NIL

*------------------------------------------------------------*
STATIC FUNCTION ShowStep1( cProgramName )
*------------------------------------------------------------*
* JF: display the Step 1 "Welcome" and navigation button
Form_2.Title := " " + cProgramName + " Setup - Step 1"    // JF: added the program name to the window title
Form_2.Edit_Welcome.Visible  := .T.
Form_2.Btn_Fwd2Step2.Visible := .T.
Form_2.Btn_Fwd2Step2.SetFocus

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION HideStep1
*------------------------------------------------------------*
* JF: hide the Step 1 "Welcome" and navigation button
Form_2.Edit_Welcome.Visible  := .F.
Form_2.Btn_Fwd2Step2.Visible := .F.

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION ShowStep2( cProgramName )
*------------------------------------------------------------*
Form_2.Title := " " + cProgramName + " Setup - Step 2"     // JF: added the program name to the window title
* JF: show the "Confirm Destination" elements:
Form_2.Edit_IsDestinOK.Visible := .T.
Form_2.Frame_Destin.Visible    := .T.
Form_2.Text_Destin.Visible     := .T.
Form_2.Btn_Browse.Visible      := .T.
* JF: show the Step 2 navigation buttons
Form_2.Btn_Back2Intro.Visible  := .T.
Form_2.Btn_4.Visible           := .T.
Form_2.Btn_4.SetFocus

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION HideStep2
*------------------------------------------------------------*
* JF: hide the "Confirm Destination" elements:
Form_2.Edit_IsDestinOK.Visible := .F.
Form_2.Frame_Destin.Visible    := .F.
Form_2.Text_Destin.Visible     := .F.
Form_2.Btn_Browse.Visible      := .F.
* JF: hide the Step 2 navigation buttons
Form_2.Btn_Back2Intro.Visible  := .F.
Form_2.Btn_4.Visible           := .F.

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION ShowStep3( cProgramName, lOnDeskTop, lStartMenu, lChange )
*------------------------------------------------------------*
Form_2.Title := " " + cProgramName + " Setup - Step 3"          // JF: added the program name to the window title
* JF: show the "Confirm Links" text and checkboxes:
Form_2.Edit_AreLinksOK.Visible := .T.
Form_2.Frame_Links.Visible     := .T.
Form_2.CheckBox_1.Visible      := lOnDesktop .OR. lChange
Form_2.CheckBox_2.Visible      := lStartMenu .OR. lChange
* JF: show the navigation buttons:
Form_2.Btn_Back2Step2.Visible  := .T.
Form_2.Btn_Install.Visible     := .T.
Form_2.Btn_Install.SetFocus

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION HideStep3
*------------------------------------------------------------*
* JF: hide the "Confirm Links" text and checkboxes:
Form_2.Edit_AreLinksOK.Visible := .F.
Form_2.Frame_Links.Visible     := .F.
Form_2.CheckBox_1.Visible      := .F.
Form_2.CheckBox_2.Visible      := .F.
* JF: hide the navigation buttons:
Form_2.Btn_Back2Step2.Visible  := .F.
Form_2.Btn_Install.Visible     := .F.

RETURN NIL
*
*------------------------------------------------------------*
FUNCTION Install( cSetupPath, cDestinPath, aLink, lOnDesktop, lStartMenu, cSMenuFolder, ;
  cProgramName, cIcon, lNeedReboot )
*------------------------------------------------------------*
* JF: Install() has 3 possible results:
* JF:  - the installation failed because SETUP.ZIP could not be found
* JF:  - the installation failed because the user refused to allow creation of a new folder
* JF:  - the installation was successful

LOCAL cDesktop    := GetDesktopFolder()
LOCAL cSMenuPath  := GetSpecialFolder( CSIDL_PROGRAMS )
LOCAL cLinkName   := ""
LOCAL cExeName    := ""
LOCAL i

RELEASE KEY ALT+X OF Form_2
RELEASE KEY ESCAPE OF Form_2

IF FILE( cSetupPath + "setup.zip" )
  IF ! IsZipFile( cSetupPath + "setup.zip" )
    MsgStop( "The file Setup.zip is not a ZIP file!", , , .F. )
    lNeedReboot := .F.
    BailOut( cProgramName )
    RETU NIL
  ENDIF
  cDestinPath := IIF( Right( cDestinPath, 1 ) == "\", Left( cDestinPath, LEN( cDestinPath) - 1 ), cDestinPath )

  IF ! IsDirectory( cDestinPath )
    * JF: ask the user to approve the creation of a new folder
    IF ! MsgYesNo( "The folder " + cDestinPath + " does not exist. Create it? ", "Create Folder ?" )
      * JF: Return the user to Step 2, to specify a destination folder
      HideStep3()
      ShowStep2( cProgramName )
      RETU NIL
    ELSE
      CreateFolder( cDestinPath )
    ENDIF
  ENDIF

 *------------------------------------------------------------*
  * JF 25 Jul 2005: Modified the next 9 lines
  * UNCOMPRESS does not work in some cases if the SETUP.ZIP file is on a read-only CD
  COPY FILE ( cSetupPath + "setup.zip" ) TO ( cDestinPath + "\setup.zip" )

  * UNCOMPRESS FILE cSetupPath + "setup.zip" ;
  UNCOMPRESS FILE ( cDestinPath + "\setup.zip" ) ;
    EXTRACTPATH cDestinPath ;
    CREATEDIR

  FERASE( cDestinPath + "\setup.zip" )
*------------------------------------------------------------*

  * JF: If no ICON was specified in the SETUP.INI file, use the program name as a default
  IF EMPTY( cIcon ) .OR. ( ! FILE( cDestinPath + "\" + cIcon ))
    cIcon := cExeName
  ELSE
    cIcon := cDestinPath + "\" + cIcon
  ENDIF

  IF lOnDeskTop
    i := ASCAN( aLink, {|e| e[3] == 1} )
    cLinkName := cDesktop + "\" + aLink[i][1]
    cExeName := cDestinPath + "\" + aLink[i][2]
    * JF: added the ability to specify the name of an ICON for the LINKS
    IF CreateFileLink( cLinkName, cExeName, cFilePath(cExeName), cIcon ) # 0
      * JF: changed MsgStop() to MsgExclamation(), since the installation of the program was completed
      MsgAlert( "Setup was unable to create the Desktop Link" )
    ENDIF
  ENDIF

  IF lStartMenu
    IF ! IsDirectory( cSMenuPath + "\" + cSMenuFolder )
      CreateFolder( cSMenuPath + "\" + cSMenuFolder )
    ENDIF

    FOR i := 1 To LEN( aLink )
      IF aLink[i][3] == 0
        cLinkName := cSMenuPath + "\" + cSMenuFolder + "\" + aLink[i][1]
        cExeName  := cDestinPath + "\" + aLink[i][2]
        IF CreateFileLink( cLinkName, cExeName, cFilePath(cExeName), IF(i > 2, cExeName, cIcon) ) # 0
          * JF: changed MsgStop() to MsgExclamation(), since the installation of the program was completed
          MsgAlert( "Setup was unable to create the Start Menu Link" )
        ENDIF
      ENDIF
    NEXT
  ENDIF
  Go2Finish( cProgramName, lNeedReboot ) // JF: Inform the user that installation was successful
ELSE
  * JF: Don't reboot if the installation was unsuccessful
  lNeedReboot := .F.
  * JF: Inform the user that SETUP.ZIP could not be found, and exit Setup
  BailOut( cProgramName )
ENDIF

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION Go2Finish( cProgramName, lNeedReboot )
*------------------------------------------------------------*
* JF: Install() can be called from Step 2 or Step 3, so hide both sets of controls
HideStep2()
HideStep3()

* JF: Inform the user that installation was successful
Form_2.Title := " " + cProgramName + " Setup Completed !"
Form_2.Edit_Success.Visible := .T.

* JF: Display the "Reboot" options if required
Form_2.Frame_Reboot.Visible := lNeedReboot
Form_2.Radio_Reboot.Visible := lNeedReboot

* JF: Display only the "Finish" button
Form_2.Btn_Cancel.Visible := .F.
Form_2.Btn_Finish.Visible := .T.
Form_2.Btn_Finish.SetFocus

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION BailOut( cProgramName )
*------------------------------------------------------------*
* JF: Installation was unsuccessful because SETUP.ZIP was not found
* JF: Install() can be called from Step 2 or Step 3, so hide both sets of controls
HideStep2()
HideStep3()

* JF: Inform the user that installation was unsuccessful
Form_2.Title := " " + cProgramName + " Setup Cancelled !"
Form_2.Edit_Failure.Visible := .T.

* JF: Display only the "Finish" button
Form_2.Btn_Cancel.Visible   := .F.
Form_2.Btn_Finish.Caption   := "E&xit"
Form_2.Btn_Finish.Visible   := .T.
Form_2.Btn_Finish.SetFocus

RETURN NIL
*
*--------------------------------------------------------*
FUNCTION IsZipFile( cFilename )
*--------------------------------------------------------*
   LOCAL nHandle, cBuffer := Space(4)

   IF ( nHandle := FOPEN( cFilename, FO_READ + FO_SHARED ) ) <> -1

	FSEEK( nHandle, 0, FS_SET ) // go to top of file

	IF FREAD( nHandle, @cBuffer, 4 ) == 4

		IF Left( cBuffer, 1 ) == 'P' .AND. Substr( cBuffer, 2, 1 ) == 'K' .AND. ;
			Substr( cBuffer, 3, 1 ) == Chr(3) .AND. Right( cBuffer, 1 ) == Chr(4)
			FCLOSE( nHandle )           // close file
			RETURN .T.
		ENDIF
	ENDIF

	FCLOSE( nHandle )           // close file

   ENDIF

RETURN .F.
*
*------------------------------------------------------------*
PROCEDURE ExitWindows( nFlag )
*------------------------------------------------------------*
IF IsWinNT()
  EnablePermissions()
ENDIF

IF ExitWindowsEx( nFlag, 0 )
  Form_2.Release
ENDIF

RETURN
*
#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

#include <ShlObj.h>

void ChangePIF(LPCSTR cPIF);
HRESULT WINAPI CreateLink(LPSTR lpszLink, LPSTR lpszPathObj, LPSTR lpszWorkPath, LPSTR lpszIco, int nIco);

HB_FUNC( CREATEFILELINK )
{
   hb_retnl( (LONG) CreateLink( (char *) hb_parc(1), (char *) hb_parc(2), (char *) hb_parc(3), (char *) hb_parc(4),
             (hb_pcount()>4)? hb_parni(5) : 0 )) ;
}

/***************************************************************************\
*                                                                           *
*  Autor: Jose F. Gimenez (JFG)                                             *
*         <jfgimenez@wanadoo.es> <tecnico.sireinsa@ctv.es>                  *
*                                                                           *
*  Fecha: 2000.10.02                                                        *
*                                                                           *
\***************************************************************************/

void ChangePIF(LPCSTR cPIF)
{
   char buffer[1024];
   HFILE h;
   long  filesize;

   strcpy(buffer, cPIF);
   strcat(buffer, ".pif");
   if ((h=_lopen(buffer, 2))>0)
      {
      filesize=_hread(h, &buffer, 1024);
      buffer[0x63]=0x10;     // Cerrar al salir
      buffer[0x1ad]=0x0a;    // Pantalla completa
      buffer[0x2d4]=0x01;
      buffer[0x2c5]=0x22;    // No Permitir protector de pantalla
      buffer[0x1ae]=0x11;    // Quitar ALT+ENTRAR
      buffer[0x2e0]=0x01;
      _llseek(h, 0, 0);
      _hwrite(h, buffer, filesize);
      _lclose(h);
      }
}

HRESULT WINAPI CreateLink(LPSTR lpszLink, LPSTR lpszPathObj, LPSTR lpszWorkPath, LPSTR lpszIco, int nIco)
{
    long hres;
    IShellLink * psl;

    hres = CoInitialize(NULL);
    if (SUCCEEDED(hres))
       {
       hres = CoCreateInstance(&CLSID_ShellLink, NULL,
           CLSCTX_INPROC_SERVER, &IID_IShellLink, ( LPVOID ) &psl);

       if (SUCCEEDED(hres))
       {

           IPersistFile * ppf;

           psl->lpVtbl->SetPath(psl, lpszPathObj);
           psl->lpVtbl->SetIconLocation(psl, lpszIco, nIco);
           psl->lpVtbl->SetWorkingDirectory(psl, lpszWorkPath);

           hres = psl->lpVtbl->QueryInterface(psl,
                                              &IID_IPersistFile,
                                              ( LPVOID ) &ppf);

           if (SUCCEEDED(hres))
           {
               WORD wsz[MAX_PATH];
               char cPath[MAX_PATH];

               strcpy(cPath, lpszLink);
               strcat(cPath, ".lnk");

               MultiByteToWideChar(CP_ACP, 0, cPath, -1, wsz, MAX_PATH);

               hres = ppf->lpVtbl->Save(ppf, wsz, TRUE);
               ppf->lpVtbl->Release(ppf);

               // modificar el PIF para los programas MS-DOS
               ChangePIF(lpszLink);

           }
           psl->lpVtbl->Release(psl);
       }
       CoUninitialize();
    }
    return hres;
}

/***************************************************************************/

HB_FUNC( FILLBLUE )
{
    HWND   hwnd;
    HBRUSH brush;
    RECT   rect;
    HDC    hdc;
    int    cx;
    int    cy;
    int    blue = 200;
    int    steps;
    int    i;

    hwnd  = (HWND) hb_parnl( 1 );
    hdc   = GetDC( hwnd );

    GetClientRect( hwnd, &rect );

    cx = rect.top;
    cy = rect.bottom;
    steps = (cy - cx) / 4;
    rect.bottom = 0;

    for( i = 0 ; i < steps ; i++ )
    {
        rect.bottom += 4;
        brush = CreateSolidBrush( RGB( 0, 0, blue ));
        FillRect( hdc, &rect, brush );
        DeleteObject( brush );
        rect.top += 4;
        blue -= 1;
    }

    ReleaseDC( hwnd, hdc );
}

HB_FUNC( ENABLEPERMISSIONS )

{
    LUID tmpLuid;
    TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
    DWORD lBufferNeeded;
    HANDLE hdlTokenHandle;
    HANDLE hdlProcessHandle = GetCurrentProcess();

    OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

    LookupPrivilegeValue(NULL, "SeShutdownPrivilege", &tmpLuid);

    tkp.PrivilegeCount            = 1;
    tkp.Privileges[0].Luid        = tmpLuid;
    tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

    AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

HB_FUNC( EXITWINDOWSEX )

{
    hb_retl( ExitWindowsEx( (UINT) hb_parni( 1 ), (DWORD) hb_parnl( 2 )) );
}

#pragma ENDDUMP

*------------------------------------------------------------*
* EOF
*------------------------------------------------------------*