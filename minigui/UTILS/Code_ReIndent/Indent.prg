*
* INDENT.EXE (v.1.8) is a customizable program to reindent your .PRG files
* Placed in the public domain for the Clipper/Harbour/MiniGUI community
* by Joe Fanucchi MD (drjoe@meditrax.com, fantasyspinner2002@yahoo.com)
* Comments and enhancements are welcome.
*
* Changes:
*  v 1.1 corrected a bug which resulted in failure to outdent ELSE and ELSEIF and OTHERWISE commands,
*        and added more documentation comments
*  v 1.2 changed the method of writing back to the source file from LIST TO to FWRITE()
*  v 1.3 corrected a bug which LTRIM()'ed all lines beginning with "* "
*  v 1.4 corrected a bug which resulted in failure to indent multi-line ITEM commands
*        and eliminated the need to begin a line with "* " in order to be recognized as a comment
*        (all lines beginning with "*" are now treated as comment lines)
*  v 1.5 Added option to create a header listing all FUNCTIONs and PROCEDUREs alphabetically
*        Added CharOnly() function, and option to replace divider lines of variable length
*        (such as *--------------------- or ***************** )
*        with standardized divider *------------------------------------------------------------*
*  v 1.6 Changed the telephone and fax numbers in the "Help/Contact OHS" links
*        Added support for indented FUNCTIONs and PROCEDUREs (Thanks to Ross McKenzie for these suggestions)
*        Added a Browse button for the source code folder
*  v 1.7 Added Tooltips for configuration window checkboxes
*        Added option to indent DEFINE MENU structures
*        Eliminated indenting of single-line "IF;[action];ENDIF" commands
*  v 1.8 Ajout de la liste des fenêtres
*        Ajout option Quitter dans le menu
*		 Françisation du programme
*        Suppression d'un bug quand on veut indenter ce programme avec lui même

#include "minigui.ch"
#include "indent.ch"                                // #DEFINE statements for memvars arrays used throughout the program
MEMVAR aGlobal, nLastLine
DECLARE WINDOW ShowProg_1
*---------------------------------------------------------------
PROCEDURE MAIN()
*---------------------------------------------------------------
PUBLIC aGlobal[ 20 ]                                // used to store public variables used throughout the program
SET DELETED ON

z_lhorizln  := .T.                                  // must add a checkbox for this

DEFINE WINDOW Trax_1 ;
   AT 0,0 ;
   WIDTH MIN( 800, GetDesktopWidth()) ;
   HEIGHT MIN( 600, GetDesktopHeight()) ;
   TITLE 'MediTrax Code ReIndent 1.8' ;
   ICON 'OHS.ICO' ;
   MAIN NOMAXIMIZE NOSIZE ;
   ON INIT GetPrgVars() ;                           // store user preferences to memvars
   ON PAINT ( FillBlue( _HMG_MainHandle ), ;        // color the screen: MiniGUI contributed file
   TextPaint() )

   DEFINE MAIN MENU
      POPUP '&Indent Code'
         ITEM '&Select .PRG File'      ACTION FindPrg()
         SEPARATOR
         ITEM '&Exit'                  ACTION ReleaseAllWindows()
      END POPUP

      POPUP '&Configure'
         ITEM '&Indenting Options'     ACTION ConfigureIndent()
         ITEM '&Restore Defaults'      ACTION ( RestoreCfgDefaults( .F. ), ConfigureIndent() )
      END POPUP

      POPUP '&Help'
      * these will invoke the default mail client and web browser
         ITEM "About Code ReIndent"    ACTION AboutMCR()
         ITEM "Contact OHS"            ACTION ContactMediTrax()
      END POPUP
   END MENU
END WINDOW
CENTER WINDOW Trax_1

IF FILE( 'MTFLASH3.BMP' )
   DEFINE WINDOW MT_Splash ;
      AT 0, 0 ;
      WIDTH 365 HEIGHT 92 ;
      TOPMOST NOCAPTION ;
      ON INIT SplashDelay()

      IF FILE('MTFLASH3.BMP' )
         @ -4, -4 IMAGE img_1 ;
            PICTURE 'MTFLASH3.BMP' ;
            WIDTH 365 ;
            HEIGHT 92
      ENDIF

   END WINDOW
   CENTER WINDOW MT_Splash

   ACTIVATE WINDOW MT_Splash, Trax_1
ELSE
   ACTIVATE WINDOW Trax_1
ENDIF

RETURN
*
*---------------------------------------------------------------
function TextPaint()
*---------------------------------------------------------------
DRAW TEXT IN WINDOW Trax_1 AT 23, 27 ;
   VALUE "MediTrax   Code ReIndent" ;
   FONT "Verdana" SIZE 24 BOLD ITALIC ;
   FONTCOLOR BLACK TRANSPARENT

DRAW TEXT IN WINDOW Trax_1 AT 20, 24 ;
   VALUE "MediTrax   Code ReIndent" ;
   FONT "Verdana" SIZE 24 BOLD ITALIC ;
   FONTCOLOR { 151, 223, 255 } TRANSPARENT

DRAW TEXT IN WINDOW Trax_1 AT 28, 192 ;
   VALUE "TM" ;
   FONT "Verdana" SIZE 8 BOLD ITALIC ;
   FONTCOLOR BLACK TRANSPARENT

DRAW TEXT IN WINDOW Trax_1 AT 26, 190 ;
   VALUE "TM" ;
   FONT "Verdana" SIZE 8 BOLD ITALIC ;
   FONTCOLOR { 151, 223, 255 } TRANSPARENT

DRAW TEXT IN WINDOW Trax_1 AT Trax_1.Height - 80, Trax_1.Width - 360 ;
   VALUE "Developed 2005-2012 Occupational Health Systems, Inc." ;
   FONT "Tahoma" SIZE 10 ITALIC ;
   FONTCOLOR { 151, 223, 255 } TRANSPARENT
Return Nil
*
*---------------------------------------------------------------
STATIC FUNCTION AboutMCR
*---------------------------------------------------------------
* Subroutine of the "Help" menu option
MsgInfo ( "MediTrax Code ReIndent" + CHR(13) + "Version 1.7 (25 May 2005)" ;
   + CHR(13) + "Version 1.8 (09 November 2012)" ;
   + CHR(13) + CHR(13) + "A customizable reindenter" ;
   + CHR(13) + "for Clipper/MiniGUI code" ;
   + CHR(13) + "written by Joe Fanucchi MD" ;
   + CHR(13) + CHR(13) + "Placed in the public domain" ;
   + CHR(13) + "for the Clipper/MiniGUI community" ;
   + CHR(13) + "by" ;
   + CHR(13) + "Occupational Health Systems, Inc.    " ;
   + CHR(13) + "Alamo, California 94507-1349" ;
   + CHR(13) + "www.meditrax.com", ;
   "About MediTrax Code ReIndent" )

RETURN NIL
*
*---------------------------------------------------------------------------
STATIC FUNCTION Blank( xItem )
*---------------------------------------------------------------------------
* Returns an empty data field
DO CASE
CASE VALTYPE( xItem ) == "C"
   RETU SPACE( LEN( xItem ))
CASE VALTYPE( xItem ) == "D"
   RETU CTOD( "" )
CASE VALTYPE( xItem ) == "L"
   RETU .F.
CASE VALTYPE( xItem ) == "N"
   RETU 0
CASE VALTYPE( xItem ) == "M"
   RETU ""
ENDCASE
RETURN NIL
*
*-----------------------------------------------------------------------------
FUNCTION BublSort( nElements, aArray1, aArray2, aArray3, aArray4, aArray5 )
*-----------------------------------------------------------------------------
* Bubble sorts 2 to 5 arrays when the elements of the second (and further)
*   arrays must remain in sync with the elements of the first (key) array
*   as that first array is sorted
* (Don't use for just one array, as we can use ASORT for that...)
* NOTE: the arrays must be the SAME SIZE

LOCAL cThisElement                                           // contents of this array element
LOCAL i
LOCAL nNeed2Sort := 2                                        // how many arrays are involved in the sort?

IF VALTYPE( aArray3 ) == "A"
  ++nNeed2Sort
  IF VALTYPE( aArray4 ) == "A"
    ++nNeed2Sort
  * Added v 1.8
  IF VALTYPE( aArray5 ) == "A"
    ++nNeed2Sort
  ENDIF
ENDIF
ENDIF

FOR i := 1 TO ( nElements - 1 )
  IF aArray1[ i ] > aArray1[ i + 1 ]
    cThisElement     := aArray1[ i ]
    aArray1[ i ]     := aArray1[ i + 1 ]
    aArray1[ i + 1 ] := cThisElement

    cThisElement     := aArray2[ i ]
    aArray2[ i ]     := aArray2[ i + 1 ]
    aArray2[ i + 1 ] := cThisElement

    IF nNeed2Sort > 2
      cThisElement     := aArray3[ i ]
      aArray3[ i ]     := aArray3[ i + 1 ]
      aArray3[ i + 1 ] := cThisElement
      IF nNeed2Sort > 3
        cThisElement     := aArray4[ i ]
        aArray4[ i ]     := aArray4[ i + 1 ]
        aArray4[ i + 1 ] := cThisElement
        * Added v 1.8
        IF nNeed2Sort == 5
          cThisElement     := aArray5[ i ]
          aArray5[ i ]     := aArray5[ i + 1 ]
          aArray5[ i + 1 ] := cThisElement
        ENDIF
      ENDIF
    ENDIF

    i := MAX( 0, i - 2 )
  ENDIF
NEXT i

RETURN NIL
*
*---------------------------------------------------------------------------
FUNCTION CharOnly( cOKChars, cString2Check )
*---------------------------------------------------------------------------
* Processes cString2Check and removes all but the characters in cOKChars;
  * from Clipper Tools 9/17/94

LOCAL cSingleChar
LOCAL cStringOutput := ""
LOCAL i

FOR i := 1 TO LEN( cString2Check )
  IF ( cSingleChar := SUBSTR( cString2Check, i, 1 )) $ cOKChars
    cStringOutput += cSingleChar
  ENDIF
NEXT i

RETURN cStringOutput
*
*---------------------------------------------------------------
STATIC FUNCTION ConfigureIndent
*---------------------------------------------------------------
* Enables user to enter indenting preferences
SET FONT TO "Arial" , 10

IF ! IsWindowDefined ( MCICfg_1 )
  DEFINE WINDOW MCICfg_1 ;
    AT 0,0 ;
    WIDTH 540 HEIGHT 415 ;
    TITLE "Configure Indent Values" ;
    MODAL ;
    NOSIZE NOSYSMENU ;
    ON INIT { || UpdtChkCmt(), UpdtChkAct() } ;
    FONT 'Arial' SIZE 10

    @ 15,15 LABEL Label_1 ;
      VALUE 'Please indicate whether you wish to:' ;
      WIDTH 250 HEIGHT 22

    * Tooltip added v 1.7
    @ 40,25 CHECKBOX Check_Fun ;
      CAPTION ' Indent FUNCTIONs/PROCEDUREs' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_lfunction ;
      TOOLTIP "All lines of a FUNCTION or PROCEDURE will be indented " ;
        + "until the final RETURN line is encountered. The RETURN line " ;
        + "will be 'outdented' to the left margin. RETU commands which " ;
        + "occur within a function will not be 'outdented'." ;
      ON CHANGE z_lfunction := MCICfg_1.Check_Fun.Value

    * Tooltip added v 1.7
    @ 65,25 CHECKBOX Check_Mul ;
      CAPTION ' Indent multiline statements' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_lmultline ;
      TOOLTIP "The second and all subsequent lines of a multi-line " ;
        + "command will be indented." ;
      ON CHANGE z_lmultline := MCICfg_1.Check_Mul.Value

    * Tooltip added v 1.7
    @ 90,25 CHECKBOX Check_Whi ;
      CAPTION ' Indent WHILE/DO WHILE statements' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_ldowhile ;
      TOOLTIP "All lines within WHILE / ENDDO and WHILE / ENDDO structures " ;
        + "will be indented. Lines which begin " ;
        + "with the word WHILE will not be indented if they are part of a " ;
        + "multi-line command such as APPEND FROM cDBF WHILE Myfunc()" ;
      ON CHANGE z_ldowhile := MCICfg_1.Check_Whi.Value

    @115,25 CHECKBOX Check_For ;
      CAPTION ' Indent FOR/NEXT statements' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_lfornext ;
      TOOLTIP "All lines within FOR / NEXT structures will be indented. Lines which begin " ;
        + "with the word FOR will not be indented if they are part of a " ;
        + "multi-line command such as APPEND FROM cDBF FOR ! DELETED()" ;
      ON CHANGE z_lfornext := MCICfg_1.Check_For.Value

    @140,25 CHECKBOX Check_Ifc ;
      CAPTION ' Indent IF/CASE statements' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_lifcase ;
      TOOLTIP "IF / ELSE / ENDIF and DO CASE / CASE / OTHERWISE / ENDCASE structures will be " ;
        + "indented. Single-line commands such as IF EMPTY(cText); cText:='x'; ENDIF " ;
        + "will not be indented."
      ON CHANGE z_lifcase := MCICfg_1.Check_Ifc.Value

    * Tooltip added v 1.7
    @165,25 CHECKBOX Check_Win ;
      CAPTION ' Indent DEFINE WINDOW statements' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_lwindow ;
      TOOLTIP "All lines within a DEFINE WINDOW / END WINDOW structure " ;
        + "will be indented." ;
      ON CHANGE { || z_lwindow := MCICfg_1.Check_Win.Value }

    * Option added v 1.7
    @190,25 CHECKBOX Check_Mnu ;
      CAPTION ' Indent DEFINE MENU statements' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_lmenuitem ;
      TOOLTIP "All lines within a DEFINE MENU / END MENU structure " ;
        + "or a DEFINE MAIN MENU / END MENU structure " ;
        + "will be indented." ;
      ON CHANGE z_lmenuitem := MCICfg_1.Check_Mnu.Value

    * Tooltip added v 1.7
    @215,25 CHECKBOX Check_Pop ;
      CAPTION ' Indent POPUP statements' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_lpopup ;
      TOOLTIP "All lines within a POPUP / END POPUP structure " ;
        + "or a DEFINE POPUP / END POPUP structure " ;
        + "will be indented." ;
      ON CHANGE z_lpopup := MCICfg_1.Check_Pop.Value

    * Tooltip added v 1.7
    @240,25 CHECKBOX Check_Cmt ;
      CAPTION ' Align "//" and "**" comments' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_lcomment ;
      TOOLTIP "Programmer's comments which begin with // or ** will be aligned " ;
        + "at (or as near as possible to) the specified column" ;
      ON CHANGE UpdtChkCmt()

    * Tooltip added v 1.7
    @265,25 CHECKBOX Check_Act ;
      CAPTION ' Align ACTION statements' ;
      WIDTH 250 HEIGHT 22 ;
      VALUE z_laction ;
      TOOLTIP "ACTION statements will be aligned " ;
        + "at (or as near as possible to) the specified column" ;
      ON CHANGE UpdtChkAct()

    * Tooltip added v 1.7
    @290,25 CHECKBOX Check_Hdr ;
      CAPTION ' Create a header listing all FUNCTIONs, PROCEDUREs and WINDOWs' ;
      WIDTH 440 HEIGHT 22 ;
      VALUE z_llistfunx ;
      TOOLTIP "A list of all FUNCTIONs, PROCEDUREs and WINDOWs" ;
        + " will be created at the top of the source" ;
        + " code file. If a list has been created" ;
        + " previously, it will be updated." ;
      ON CHANGE { || z_llistfunx := MCICfg_1.Check_Hdr.Value }

    @ 25,315 FRAME Frame_1 CAPTION 'Indent Levels' ;
      WIDTH 180 HEIGHT 108

    @ 50,325 LABEL Label_2 ;
      VALUE 'Indent spacing:' ;
      RIGHTALIGN ;
      WIDTH 110 HEIGHT 22

    @ 47,440 TEXTBOX Text_2 ;
      VALUE z_nindent ;
      WIDTH 30 HEIGHT 22 ;
      NUMERIC ;
      MAXLENGTH 2 RIGHTALIGN ;
      ON CHANGE z_nindent := MCICfg_1.Text_2.Value

    @ 75,325 LABEL Label_3 ;
      VALUE 'Comment column:' ;
      RIGHTALIGN ;
      WIDTH 110 HEIGHT 22

    @ 72,440 TEXTBOX Text_3 ;
      VALUE z_ncomment ;
      WIDTH 30 HEIGHT 22 ;
      NUMERIC ;
      MAXLENGTH 2 RIGHTALIGN ;
      TOOLTIP "Programmer's comments which begin with // or ** will be aligned " ;
        + "at (or as near as possible to) the specified column" ;
      ON CHANGE z_ncomment := MCICfg_1.Text_3.Value

    @100,325 LABEL Label_4 ;
      VALUE 'ACTION column:' ;
      RIGHTALIGN ;
      WIDTH 110 HEIGHT 22

    @ 97,440 TEXTBOX Text_4 ;
      VALUE z_naction ;
      WIDTH 30 HEIGHT 22 ;
      NUMERIC ;
      MAXLENGTH 2 RIGHTALIGN ;
      TOOLTIP "ACTION statements will be aligned " ;
        + "at (or as near as possible to) the specified column" ;
      ON CHANGE z_naction := MCICfg_1.Text_4.Value

    @145,315 FRAME Frame_2 CAPTION 'Location of Files' ;
      WIDTH 180 HEIGHT 105

    @175,325 TEXTBOX Text_5 ;
      VALUE TRIM( z_cfolder ) ;
      WIDTH 160 HEIGHT 22 ;
      MAXLENGTH 30 ;
      ON CHANGE z_cfolder := UPPER( MCICfg_1.Text_5.Value )

    @210,345 BUTTON Button_Brw ;
      CAPTION "&Browse" ;
      ACTION GetPrgFolder() ;
      TOOLTIP "Tell us the secret ... where do you keep your " ;
        + "valuable source code files?" ;
      WIDTH 120 HEIGHT 28

    @335,65 BUTTON Button_Sav ;
      CAPTION "&Save" ;
      ACTION { || SaveCfg(), MCICfg_1.Hide, MsgInfo( "Configuration settings saved   ", "Confirming..." ), MCICfg_1.Release } ;
      WIDTH 120 HEIGHT 28

    @335,200 BUTTON Button_Cnc ;
      CAPTION "&Cancel" ;
      ACTION MCICfg_1.Release ;
      WIDTH 120 HEIGHT 28

    @335,335 BUTTON Button_Def ;
      CAPTION "&Restore Defaults"  ACTION RestoreCfgDefaults( .T. ) ;
      WIDTH 120 HEIGHT 28

    * Tooltip width added v 1.7
    SET TOOLTIP MAXWIDTH TO 200 OF MCICfg_1

  END WINDOW

  MCICfg_1.Center()

  MCICfg_1.Activate()
ELSE
  MCICfg_1.SetFocus
ENDIF

RETURN NIL
*
*---------------------------------------------------------------
STATIC FUNCTION ContactMediTrax
*---------------------------------------------------------------
* Subroutine of the "Help" menu option
* Displays how to contact OHS Inc.
* Shameless self-promotion. You can edit this out if you want :)
IF .NOT. IsWindowDefined ( Contact_OHS )
   DEFINE WINDOW Contact_OHS ;
      AT 0,0 ;
      WIDTH 460 ;
      HEIGHT 178 - IF(IsXPThemeActive(), 0, 8) ;
      TITLE 'Contact OHS' ;
      ICON 'OHS.ICO' ;
      NOMINIMIZE NOMAXIMIZE ;
      BACKCOLOR WHITE

      @ 1,1    FRAME FRAME1 WIDTH 327 HEIGHT 142
      @ 1,330  FRAME FRAME2 WIDTH 120 HEIGHT 142

     * Thanks to Dr Jacek Kubica for this image
      @ 26,334  IMAGE IMAGE_1 PICTURE "surg.bmp" WIDTH 111 HEIGHT 88

      @ 20,10  LABEL LB_NORM VALUE 'E-mail MediTrax Support:' ;
         FONT 'Arial' SIZE 09  ;
         BACKCOLOR WHITE ;
         AUTOSIZE

      @ 20,160 HYPERLINK LB_MAIL VALUE 'support@meditrax.com' ;
         FONT 'Arial' SIZE 09  ;
         AUTOSIZE ;
         ADDRESS 'support@meditrax.com';            // e-mail address
      TOOLTIP 'Click to open your email client';
         BACKCOLOR WHITE ;
         HANDCURSOR

      @ 50,10  LABEL LB_NORM1 VALUE 'Visit MediTrax on the Web: ' ;
         FONT 'Arial' SIZE 09  ;
         BACKCOLOR WHITE ;
         AUTOSIZE

      @ 50,160 HYPERLINK LB_URL1 ;
         VALUE 'http://www.meditrax.com' ;
         FONT 'Arial' SIZE 09 ;
         AUTOSIZE ;
         ADDRESS "http://www.meditrax.com";         //Full url (with http://)
      TOOLTIP 'Click to open your browser' ;
         BACKCOLOR WHITE ;
         HANDCURSOR

    @ 80,10  LABEL LB_NORM2 VALUE 'MediTrax Telephone (US): ' ;
      FONT 'Arial' SIZE 09  ;
      BACKCOLOR WHITE ;
      AUTOSIZE

    @ 80,160 LABEL LB_URL2 ;
      VALUE '925.820.7758' ;
      FONT 'Arial' SIZE 09 ;
      FONTCOLOR BLUE ;
      AUTOSIZE ;
      BACKCOLOR WHITE

    @ 110,10  LABEL LB_NORM3 VALUE 'MediTrax Fax (US): ' ;
      FONT 'Arial' SIZE 09  ;
      BACKCOLOR WHITE ;
      AUTOSIZE

    @ 110,160 LABEL LB_URL3 ;
      VALUE '925.820.7650' ;
      FONT 'Arial' SIZE 09 ;
      FONTCOLOR BLUE ;
      AUTOSIZE ;
      BACKCOLOR WHITE
   END WINDOW
   CENTER WINDOW Contact_OHS
   Contact_OHS.Activate
ELSE
   Contact_OHS.SetFocus
ENDIF

RETURN NIL
*
*---------------------------------------------------------------------------
STATIC FUNCTION FindPrg()
*---------------------------------------------------------------------------
* Enables selection of a specific .PRG file, and calls the routine
* which imports each line into a temporary .DBF file
LOCAL cPrgFile := "", i
lEscaped := .F.

cPrgFile := Getfile ( { {'.PRG Files','*.prg'}, {'All Files','*.*'} } , 'Open File' , z_cfolder , .f. , .t. )

IF EMPTY( cPrgFile )
   MsgExclamation( "No file was selected to indent   ", "Aborting..." )
   lEscaped := .T.
   RETU NIL
ENDIF

IF FILE( "MCITEXT.DBF" )
   USE MCITEXT ALIAS "MCITEXT" NEW EXCLUSIVE
   ZAP
   CLOSE MCITEXT
ELSE
   DBCREATE( "MCITEXT", {  ;
      { "cTXTLINE",  "C", 254, 0 } ;
      } )
ENDIF

USE MCITEXT ALIAS "MCITEXT" NEW EXCLUSIVE
APPEND FROM ( cPrgFile ) SDF
nLastLine := LASTREC()
FOR i := 1 TO nLastLine
   GO i
   IF LEN( TRIM( MCITEXT->ctxtline )) == 254        // line is too long
      MsgStop( "Line " + LTRIM( STR( i, 4 )) + " is too long to edit!   " ;
         + CRLF + "(Maximum line length is 254 characters)   ", "Line length exceeded" )
      lEscaped := .T.
      EXIT
   ENDIF
NEXT i
CLOSE MCITEXT

IF lEscaped
   RETU NIL
ENDIF

ShowProgress( cPrgFile )

RETURN NIL
*
*---------------------------------------------------------------
STATIC FUNCTION GetPrgFolder
*---------------------------------------------------------------
LOCAL cFolder := ""

cFolder := GetFolder()

IF EMPTY( cFolder )
  MsgExclamation( "No folder was selected   ", "Aborting..." )
  lEscaped := .T.
  RETU NIL
ENDIF

MCICfg_1.Text_5.Value := cFolder

RETURN NIL
*
*---------------------------------------------------------------
STATIC FUNCTION GetPrgVars( lBrandNew )
*---------------------------------------------------------------
* Stores configuration values to memvars
IF ! VALTYPE( lBrandNew ) == "L"
  lBrandNew := .F.
ENDIF

IF ! FILE( "MCICFG.DBF" )
  lBrandNew := .T.
  DBCREATE( "MCICFG.DBF", {  ;
    { "CFOLDER",    "C", 40, 0 }, ;
    { "LACTION",    "L",  1, 0 }, ;
    { "LCOMMENT",   "L",  1, 0 }, ;
    { "LIFCASE",    "L",  1, 0 }, ;
    { "LDOWHILE",   "L",  1, 0 }, ;
    { "LFORNEXT",   "L",  1, 0 }, ;
    { "LFUNCTION",  "L",  1, 0 }, ;
    { "LLISTFUNX",  "L",  1, 0 }, ;
    { "LMENUITEM",  "L",  1, 0 }, ;
    { "LPOPUP",     "L",  1, 0 }, ;
    { "LMULTLINE",  "L",  1, 0 }, ;
    { "LWINDOW",    "L",  1, 0 }, ;
    { "NACTION",    "N",  2, 0 }, ;
    { "NCOMMENT",   "N",  2, 0 }, ;
    { "NINDENT",    "N",  2, 0 } ;
    } )
ENDIF

* Now store the configuration variables to memvars
IF lBrandNew                                                                // enables user to reset default values
  z_cfolder   := "C:\MINIGUI"                                               // default folder for .PRG files
  z_laction   := .T.                                                        // align ACTION statements?
  z_lcomment  := .T.                                                        // align comments?
  z_ldowhile  := .T.                                                        // indent DO WHILE / WHILE statements?
  z_lfornext  := .T.                                                        // indent FOR statements?
  z_lfunction := .T.                                                        // indent FUNCTIONs/PROCEDUREs
  z_lifcase   := .T.                                                        // indent IF / CASE statements?
  z_llistfunx := .T.                                                        // create a header listing FUNCTIONs and PROCEDUREs?
  z_lmenuitem := .T.                                                        // indent ITEM / MENUITEM statements?
  z_lmultline := .T.                                                        // indent 2nd and subsequent lines of multiline statements?
  z_lpopup    := .T.                                                        // indent POPUP statements?
  z_lwindow   := .T.                                                        // indent DEFINE WINDOW statements?
  z_naction   := 40                                                         // column to align ACTION statements
  z_ncomment  := 52                                                         // column to align "//" and "**" comments
  z_nindent   := 2                                                          // spaces at each level of indent
  SaveCfg()                                                                 // store default vars back into data table
ELSE
  USE ( "MCICFG" ) ALIAS "MCICFG" NEW EXCLUSIVE
  GO TOP
  z_cfolder   := What2Store( "CFOLDER" )
  z_laction   := What2Store( "LACTION" )
  z_lcomment  := What2Store( "LCOMMENT" )
  z_ldowhile  := What2Store( "LDOWHILE" )
  z_lfornext  := What2Store( "LFORNEXT" )
  z_lfunction := What2Store( "LFUNCTION" )
  z_lifcase   := What2Store( "LIFCASE" )
  z_llistfunx := What2Store( "LLISTFUNX" )
  z_lmenuitem := What2Store( "LMENUITEM" )
  z_lmultline := What2Store( "LMULTLINE" )
  z_lpopup    := What2Store( "LPOPUP" )
  z_lwindow   := What2Store( "LWINDOW" )
  z_naction   := What2Store( "NACTION" )
  z_ncomment  := What2Store( "NCOMMENT" )
  z_nindent   := What2Store( "NINDENT" )
  CLOSE MCICFG
ENDIF

RETURN NIL
*
*---------------------------------------------------------------
STATIC FUNCTION IndentIt( cPrgFile )
*---------------------------------------------------------------
* Main routine for indenting each line of the temporary MCITEXT.DBF file
LOCAL aFuncList[ 1 ]                                                        // Array of FUNCTIONs/PROCEDUREs/STATIC FUNCTIONs
LOCAL aFuncType[ 1 ]                                                        // Type of FUNCTION/PROCEDURE declaration
LOCAL aWindList[ 1 ]                                                        // List of Window's name
LOCAL aRetuList[ 1 ]                                                        // Array of RETURN lines from FUNCTIONs/PROCEDUREs/STATIC FUNCTIONs
LOCAL bFuncHead := { | cText | LEFT( UPPER( cText ), 9 ) == "FUNCTION " ;   // Is this the first line of a PROCEDURE or FUNCTION?
      .OR. LEFT( UPPER( cText) , 16 ) == "STATIC FUNCTION " ;
      .OR. LEFT( UPPER( cText) , 5 ) == "PROC " ;
      .OR. LEFT( UPPER( cText ), 10 ) == "PROCEDURE " }
LOCAL cAction                                                               // ACTION clause of code line
LOCAL cComment                                                              // comment portion of code line
LOCAL cLineText                                                             // trimmed line of code
LOCAL cOrigText                                                             // original line of code
LOCAL cTrialLine                                                            // trial text, used to ensure max length isn't exceeded
LOCAL lAddAction    := .F.                                                  // is there an ACTION statement?
LOCAL lAddSemi      := .F.                                                  // does comment end with a semicolon?
LOCAL lMLLine1      := .F.                                                  // is this the first line of a multiline command?
LOCAL lMultLine     := .F.                                                  // is this part of a multiline command?
LOCAL lReturning    := .F.                                                  // has there been a RETU line in this PROCEDURE/FUNCTION?
LOCAL nBreakPoint   := 0                                                    // where can we cut out extra spaces if the line is too long?
LOCAL nFuncList     := 0                                                    // number of FUNCTIONs/PROCEDUREs/STATIC FUNCTIONs
LOCAL nHeaderLen    := 0                                                    // length of header lines
LOCAL nIndentSpaces := 0                                                    // leading spaces for this indent level
LOCAL nLastLine                                                             // how many lines in the .PRG file?
LOCAL nLastReturn                                                           // record pointer to the most recent RETURN statement
LOCAL nMLFudge      := 0                                                    // extra spaces for multi-line commands
LOCAL nPercent      := 0                                                    // what percentage of lines is complete?
LOCAL nThisLine     := 0                                                    // which line are we indenting?
LOCAL nThisRecNo                                                            // record pointer
LOCAL cTmpLine                                                              // for finding the window's name
LOCAL nCommentCol

USE MCITEXT ALIAS "MCITEXT" NEW EXCLUSIVE
nLastLine := LASTREC()

FOR nThisLine := 1 TO nLastLine
  GO nThisLine
  * Increment ProgressBar
  Slider( nThisLine, nLastLine )

  cAction    := ""
  cComment   := ""
  cOrigText  := MCITEXT->cTxtLine                                           // store the original text in a memvar
  cLineText  := TRIM( LTRIM( cOrigText ))                                   // shorten the line as much as possible
  cTrialLine := ""
  lAddSemi   := .F.                                                         // comment doesn't end with a semicolon

  IF z_llistfunx                                                            // add a list of FUNCTIONs and PROCEDUREs at the top of the file?
    * Routine to list all PROCEDURES and FUNCTIONS added v 1.5
    * Is this the first line of a PROCEDURE or FUNCTION?

    DO CASE
    * CASE LEFT( UPPER( cLineText ), 9 ) == "FUNCTION " .OR. LEFT( UPPER( cLineText) , 16 ) == "STATIC FUNCTION " ;
    *     .OR. LEFT( UPPER( cLineText) , 5 ) == "PROC " .OR. LEFT( UPPER( cLineText ), 10 ) == "PROCEDURE "
    CASE EVAL( bFuncHead, UPPER( cLineText ))

      ASIZE( aFuncList, ++nFuncList )                                       // add an array element
      aFuncList[ nFuncList ] := ""                                          // store a blank character string

      ASIZE( aFuncType, nFuncList )                                         // add an array element
      aFuncType[ nFuncList ] := 1                                           // default to FUNCTION

      ASIZE( aWindList, nFuncList )                                         // add an array element
      aWindList[ nFuncList ] := "WINDOWS : "                                // default to WINDOWS

      ASIZE( aRetuList, nFuncList )                                         // add an array element
      aRetuList[ nFuncList ] := ""                                          // store a blank character string

      * Now remember what type of function it is, and store that value to aFuncType[ nFuncList ]
      *  so we can later replace the wording at the beginning of the line after sorting the array alphabetically
      DO CASE
      CASE LEFT( UPPER( cLineText ), 13 ) == "FUNCTION MAIN"
        aFuncType[ nFuncList ] := "FUNCTION"
        aFuncList[ nFuncList ] := TRIM( SUBSTR( cLineText, 9 ))                    // store the function name and parameters
      CASE LEFT( UPPER( cLineText ), 9 ) == "FUNCTION "
        aFuncType[ nFuncList ] := "FUNCTION "
        aFuncList[ nFuncList ] := TRIM( SUBSTR( cLineText, 10 ))                  // store the function name and parameters
      CASE LEFT( UPPER( cLineText ), 16 ) == "STATIC FUNCTION "
        aFuncType[ nFuncList ] := "STATIC FUNCTION "
        aFuncList[ nFuncList ] := TRIM( SUBSTR( cLineText, 17 ))                  // store the function name and parameters
      CASE LEFT( UPPER( cLineText ), 5 ) == "PROC "
        aFuncType[ nFuncList ] := "PROC "
        aFuncList[ nFuncList ] := TRIM( SUBSTR( cLineText, 6 ))                   // store the function name and parameters
      CASE LEFT( UPPER( cLineText ), 10 ) == "PROCEDURE "
        aFuncType[ nFuncList ] := "PROCEDURE "
        aFuncList[ nFuncList ] := TRIM( SUBSTR( cLineText, 11 ))                  // store the function name and parameters
      ENDCASE

      DO CASE                                                               // remove the comments from the right side of the line
      CASE " //" $ aFuncList[ nFuncList ]                                   // avoids "commenting" URLs
        aFuncList[ nFuncList ] := TRIM( LEFT( aFuncList[ nFuncList ], AT( " //", aFuncList[ nFuncList ] )))
      CASE " **" $ aFuncList[ nFuncList ]
        aFuncList[ nFuncList ] := TRIM( LEFT( aFuncList[ nFuncList ], AT( " **", aFuncList[ nFuncList ] )))
      ENDCASE

      DO CASE
      CASE RIGHT( aFuncList[ nFuncList ], 2 ) == "()"                                    // clip off the empty parentheses
         aFuncList[ nFuncList ] := TRIM( LEFT( aFuncList[ nFuncList ], LEN( aFuncList[ nFuncList ] ) - 2 ))
      CASE RIGHT( aFuncList[ nFuncList ], 3 ) == "( )"                                   // clip off the empty parentheses
         aFuncList[ nFuncList ] := TRIM( LEFT( aFuncList[ nFuncList ], LEN( aFuncList[ nFuncList ] ) - 3 ))
      CASE RIGHT( aFuncList[ nFuncList ], 1 ) == ";"                                    // clip off the semicolon
         aFuncList[ nFuncList ] := TRIM( LEFT( aFuncList[ nFuncList ], LEN( aFuncList[ nFuncList ] ) - 1 )) + " [...]"
      ENDCASE

    CASE LEFT( UPPER( cLineText ), 4 ) == "RETU" .AND. ! EMPTY( aFuncList[ nFuncList ] ) // continue to update this while we're in the same FUNCTION
      aRetuList[ nFuncList ] := cLineText                                   // store the return statement and the return value (if any)
    ENDCASE
  ENDIF

  DO CASE
  CASE LEFT( cLineText, 1 ) == "*"
    * It's a comment line. Don't adjust spacing
  CASE z_lcomment                                                           // we want to align comments in a specific column
    * Remove the comment portion first, just in case the comment ends with a semicolon
    DO CASE                                                                 // remove the comments from the right side of the line
    CASE " //" $ cLineText                                                  // avoids "commenting" URLs
      cComment := SUBSTR( cLineText, AT( " //", cLineText ) + 1 )
      cLineText := TRIM( LEFT( cLineText, AT( " //", cLineText )))
    CASE " **" $ cLineText
      cComment := SUBSTR( cLineText, AT( " **", cLineText ) + 1 )
      cLineText := TRIM( LEFT( cLineText, AT( " **", cLineText )))
    ENDCASE
  CASE RIGHT( cLineText, 1 ) == ";"
    cLineText := TRIM( LEFT( cLineText, LEN( cLineText ) - 1 ))
    lAddSemi := .T.
  ENDCASE

  lAddAction := .F.                                                         // there's no ACTION statement
  IF z_laction                                                              // we want to align ACTION statements in a specific column
    DO CASE
    CASE LEFT( cLineText, 1 ) == "*"
      * It's a comment line. Don't adjust spacing
    CASE " ACTION " $ UPPER( cLineText )                                      // remove the ACTION statement from the right side of the line
      cAction   := SUBSTR( cLineText, AT( " ACTION ", UPPER( cLineText )) + 1 ) // "ACTION MsgInfo()"
      cLineText := TRIM( LEFT( cLineText, AT( " ACTION ", UPPER( cLineText )) - 1 ))
      lAddAction := .T.                                                     // there's an ACTION statement
    ENDCASE
  ENDIF

  * Adjust the spaces if we're backing out one indentation level
  DO CASE
  CASE LEFT( cLineText, 1 ) == "*"
    * It's a comment line. Don't adjust spacing
  CASE z_ldowhile .AND. LEFT( LTRIM( UPPER( cLineText )), 4 ) == "ENDD"     // indent DO WHILE / WHILE statements?
    nIndentSpaces -= z_nindent
  CASE z_lfornext .AND. LEFT( LTRIM( UPPER( cLineText )), 4 ) == "NEXT"     // indent FOR/NEXT statements?
    nIndentSpaces -= z_nindent
  CASE z_lifcase .AND. LEFT( LTRIM( UPPER( cLineText )), 4 ) $ "ELSE/ENDI/ENDC/CASE/OTHE"      // indent IF/ELSE/CASE statements?
    nIndentSpaces -= z_nindent
    lReturning := .F.                                                       // a RETURN statement inside a condition will NOT be backdented
  CASE z_lwindow .AND. LEFT( LTRIM( UPPER( cLineText )), 8 ) $ "END WIND"   // indent WINDOW statements?
    nIndentSpaces -= z_nindent
  CASE z_lmenuitem .AND. LEFT( LTRIM( UPPER( cLineText )), 8 ) == "END MENU" // indent MENU statements?
    nIndentSpaces -= z_nindent
  CASE z_lpopup .AND. LEFT( LTRIM( UPPER( cLineText )), 8 ) == "END POPU"   // indent POPUP statements?
    nIndentSpaces -= z_nindent
  CASE z_lfunction .AND. lReturning .AND. EVAL( bFuncHead, UPPER( cLineText )) // Is this the first line of a PROCEDURE or FUNCTION?
    nIndentSpaces := 0
  ENDCASE

  nIndentSpaces := MAX( 0, nIndentSpaces )                                  // negative values shouldn't happen
  IF LEFT( cLineText, 1 ) == "*"
    IF z_lhorizln .AND. "---" $ cLineText .AND. cLineText == CHARONLY( "*-", cLineText )                             // it's a horizontal spacer line
      cOrigText := "*" + REPLICATE( "-", 60 ) + "*"                         // move it to the left margin
    ENDIF
    * It's a comment line. Dont adjust anything.
    cTrialLine := cOrigText
  ELSE
    cTrialLine := TRIM( SPACE( nIndentSpaces + nMLFudge ) + cLineText )
  ENDIF

  IF lAddAction                                                             // there's an ACTION statement to be replaced
    * paste the ACTION clause back, as close as possible to the desired aligned column
    cTrialLine := PADR( cTrialLine, MAX( LEN( TRIM( cTrialLine )) + 1, z_naction - 1 )) + cAction
  ENDIF

  IF z_lcomment                                                             // if we want to put the comment in a specific column
     nCommentCol := MAX( z_ncomment, LEN( cTrialLine ) + 2 )
     cTrialLine := TRIM( PADR( cTrialLine, nCommentCol - 1 ) + " " + cComment )
  ENDIF
  cTrialLine += IIF( lAddSemi, ";", "" )

  * Is the line too long?
  WHILE LEN( cTrialLine ) > 254
    FOR nBreakPoint := LEN( cTrialLine ) - 2 TO 1 STEP -1                   // start at the right end of the line
      IF SUBSTR( cTrialLine, nBreakPoint, 3 ) == SPACE( 3 )                 // Replace all 3-space voids with 2-space voids
        cTrialLine := LEFT( cTrialLine, nBreakPoint ) + SUBSTR( cTrialLine, nBreakPoint + 2 )
      ENDIF
    NEXT
    EXIT
  ENDDO

  * Is it still too long?
  WHILE LEN( cTrialLine ) > 254
    FOR nBreakPoint := LEN( cTrialLine ) - 1 TO 1 STEP -1                   // start at the right end of the line
      IF SUBSTR( cTrialLine, nBreakPoint, 2 ) == SPACE( 2 )                 // Replace all 2-space voids with 1-space voids
        cTrialLine := LEFT( cTrialLine, nBreakPoint ) + SUBSTR( cTrialLine, nBreakPoint + 2 )
      ENDIF
    NEXT
    EXIT
  ENDDO

  IF LEN( cTrialLine ) > 254                                                // seems impossible it would still be too long!
    CLOSE MCITEXT
    MsgStop( "Line " + LTRIM( STR( nThisLine, 4 )) + " is longer than 254 characters   ", "Aborting..." )
    RETU NIL
  ENDIF

  SELECT MCITEXT
  REPLACE MCITEXT->cTxtLine WITH cTrialLine
  DBGOTO( RECNO())

  * Now to adjust the indentation for the next line
  cTrialLine := UPPER( LTRIM( cTrialLine ))
  IF z_lmultline                                                            // do we indent multi-line commands?
    DO CASE
    CASE LEFT( cLineText, 2 ) == "* "
      * It's a comment line. Don't adjust spacing
    CASE RIGHT( cTrialLine, 1 ) == ";" .AND. ! lMultLine                     // is this command continued on the next line?
      lMultLine  := .T.                                                     // this is part of a multiline command
      lMLLine1   := .T.                                                     // this is the first line of a multiline command
      nMLFudge   := z_nindent                                               // add extra indentation for the next line
    CASE RIGHT( cTrialLine, 1 ) == ";"                                       // is this command continued on the next line?
      lMLLine1   := .F.                                                     // this isn't the first line of the multiline command
    CASE lMultLine                                                          // the previous line ended in a semicolon, but this one doesn't
      lMLLine1   := .F.                                                     // this isn't the first line of the multiline command
      lMultLine  := .F.
      nMLFudge   := 0                                                       // stop the "extra" indentation after this line
    ENDCASE
  ENDIF

  DO CASE
  CASE LEFT( cLineText, 2 ) == "* "
    * It's a comment line. Don't adjust spacing
  CASE z_lfunction .AND. EVAL( bFuncHead, UPPER( cLineText ))
    * ( LEFT( UPPER( cLineText ), 9 ) == "FUNCTION " ;   // Is this the first line of a PROCEDURE or FUNCTION?
    *   .OR. LEFT( UPPER( cLineText) , 16 ) == "STATIC FUNCTION " ;
    *   .OR. LEFT( UPPER( cLineText) , 5 ) == "PROC " ;
    *   .OR. LEFT( UPPER( cLineText ), 10 ) == "PROCEDURE " )
    nIndentSpaces := z_nindent                                              // this line is at the left margin; indent lines in the FUNCTION
    nMLFudge := 0                                                           // next line will already be indented; no need to add multiline indentation

    IF lReturning                                                           // we need to backdent the most recent RETURN line
      nThisRecNo := MCITEXT->( RECNO())                                     // insert a record pointer
      GO nLastReturn                                                        // we're starting a new FUNCTION; need to backdent the most recent RETURN statement
      REPLACE MCITEXT->cTxtLine WITH LTRIM( MCITEXT->cTxtLine )             // move the RETURN statement to the left margin
      DBGOTO( RECNO())
      GO nThisRecNo                                                         // return to where we were
    ENDIF
    lReturning := .F.

  CASE z_lfunction .AND. LEFT( UPPER( cLineText ), 4 ) == "RETU"            // This MIGHT be the last RETURN line in a PROCEDURE or FUNCTION
    lReturning := .T.
    nLastReturn := MCITEXT->( RECNO())

  CASE z_lifcase .AND. ( LEFT( cTrialLine, 5 ) $ "CASE " .OR. LEFT( cTrialLine, 4 ) $ "ELSE/OTHE" ; // indent IF/ELSE/ENDIF/CASE statements?
    .OR. LEFT( cTrialLine, 7 ) == "DO CASE" .OR. LEFT( cTrialLine, 3 ) == "IF " ) // indent IF/ELSE/ENDIF/CASE statements?
    * v 1.7 change: don't indent "IF EMPTY( cText );cText := 'pierpaolo';ENDIF"
    IF ! OneLineIfEndif( cTrialLine )
      nIndentSpaces += z_nindent
      nMLFudge := 0                                                           // next line will already be indented; no need to add multiline indentation
    ENDIF
  CASE z_lwindow .AND. (  LEFT( cTrialLine, 11 ) == "DEFINE WIND" .OR. LEFT( cTrialLine, 9 ) == "DEFI WIND" ) // indent DEFINE WINDOW statements?
    cTmpLine = SUBSTR(cLineText, AT(' ',cLineText)+1) // to substract DEFI or DEFIN or DEFINE
    cTmpLine = SUBSTR(cTmpLine, AT(' ',cTmpLine)+1)   // to substract WIND or WINDO or WINDOW
    IF AT(" ",cTmpLine) > 0                           // to get the name of the windows (followed by " " or ";")
      cTmpLine := LEFT (cTmpLine, AT(' ',cTmpLine)-1)
    ELSE
      IF AT(";",cTmpLine) > 0
        cTmpLine := LEFT (cTmpLine, AT(';',cTmpLine)-1)
      ENDIF
    ENDIF
    IF z_llistfunx                                                            // add a list of WINDOWs at the top of the file?
      aWindList[nFuncList] := aWindList[nFuncList] + cTmpLine + " "
      nIndentSpaces += z_nindent
      nMLFudge := 0                                                           // next line will already be indented; no need to add multiline indentation
    ENDIF
  CASE z_lmenuitem .AND. ( LEFT( cTrialLine, 11 ) == "DEFINE MENU" .OR. LEFT( cTrialLine, 9 ) == "DEFI MENU" ; // indent DEFINE MENU statements?
    .OR. LEFT( cTrialLine, 16 ) == "DEFINE MAIN MENU" .OR. LEFT( cTrialLine, 14 ) == "DEFI MAIN MENU" ) // indent DEFINE MENU statements?
    nIndentSpaces += z_nindent
    nMLFudge := 0                                                           // next line will already be indented; no need to add multiline indentation
  CASE z_lpopup .AND. ( LEFT( cTrialLine, 11 ) == "DEFINE POPU" .OR. LEFT( cTrialLine, 9 ) == "DEFI POPU" ; // indent POPUP statements?
    .OR. LEFT( cTrialLine, 6 ) == "POPUP "  )                               // indent POPUP statements?
    nIndentSpaces += z_nindent
    nMLFudge := 0                                                           // next line will already be indented; no need to add multiline indentation
  CASE z_ldowhile .AND. LEFT( cTrialLine, 9 ) == "DO WHILE "                // indent DO WHILE / WHILE statements?
    nIndentSpaces += z_nindent
    nMLFudge := 0                                                           // next line will already be indented; no need to add multiline indentation
  CASE z_lmultline .AND. lMultLine .AND. ! lMLLine1
    * this is the second (or subsequent) line of a multiline command; don't adjust the spacing
  CASE z_ldowhile .AND. LEFT( cTrialLine, 6 ) == "WHILE "                   // this is not a DO WHILE statement, it's a WHILE condition for e.g. APPEND ... WHILE
    nIndentSpaces += z_nindent
    nMLFudge := 0                                                           // next line will already be indented; no need to add multiline indentation
  CASE z_lfornext .AND. LEFT( cTrialLine, 4 ) == "FOR "                     // this is not a FOR/NEXT statement, it's a FOR condition for e.g. APPEND ... FOR
    nIndentSpaces += z_nindent
    nMLFudge := 0                                                           // next line will already be indented; no need to add multiline indentation
  ENDCASE
NEXT nThisLine

* Now to replace the code in the source file
Slider( 0, nLastLine )                                                      // reset the progress bar
PutItBack( cPrgFile, nLastLine, aFuncList, aFuncType, aWindList, aRetuList, nFuncList ) // copy lines into source file
RETURN NIL
*
*--------------------------------------------------------------------------------
* Added v 1.7
STATIC FUNCTION OneLineIfEndif( cThisLine )
*--------------------------------------------------------------------------------
* Determines if the beginning and end of an IF/ENDIF command are on the same line
LOCAL nSemiColons := 0                                                      // how many semicolons in the line?

cThisLine := UPPER( cThisLine )
IF "ENDI" $ UPPER( cThisLine ) .AND. ";" $ cThisLine
  WHILE ";" $ cThisLine
    ++nSemiColons
    cThisLine := TRIM( LTRIM( SUBSTR( cThisLine, AT( ";", cThisLine ) + 1 )))
  ENDDO
  IF nSemiColons > 1 .AND. LEFT( cThisLine, 4 ) == "ENDI"                   // must be at least two semicolons to complete IF;command;ENDIF
    RETU .T.
  ENDIF
ENDIF

RETURN .F.
*
*---------------------------------------------------------------------------------
STATIC FUNCTION PutItBack( cPrgFile, nLastLine, aFuncList, aFuncType, aWindList, aRetuList, nFuncList )
*---------------------------------------------------------------------------------
* Copies indented code back into the source .PRG file
LOCAL cSrcFile                                                              // name of the actual source code file
LOCAL cTempFile  := LEFT( cPrgFile, LEN( cPrgFile ) - 1 ) + "x"
LOCAL nHalfMax                                                              // half the length of the FUNCTION list lines
LOCAL nHandle                                                               // file handle
LOCAL nMaxLength := 78                                                      // length of longest FUNCTION declaration
LOCAL nThisFunc
LOCAL nThisLine  := 0
LOCAL cLineText, cText
LOCAL nHeaderLen

IF FILE( cTempFile )
  FERASE( cTempFile )
ENDIF

cSrcFile := UPPER( TRIM( cPrgFile ))                                        // C:\MINIGUI\MYCODE\SOURCE.PRG
WHILE "\" $ cSrcFile
  cSrcFile := LTRIM( SUBSTR( cSrcFile, AT( "\", cSrcFile ) + 1 ))           // SOURCE.PRG
ENDDO

nHandle := FCREATE( cTempFile )

ShowProg_1.Title := "Copying " + LTRIM( STR( nLastLine, 5 )) + " lines of indented code to source file"

* Added v 1.5
IF z_llistfunx .AND. nFuncList > 0                                          // add a list of FUNCTIONs, PROCEDUREs and WINDOWs at the top of the file?
  FOR nThisFunc := 1 TO nFuncList
    nMaxLength := MAX( MAX( nMaxLength, LEN( aFuncType[ nThisFunc ] ) + LEN( aFuncList[ nThisFunc ] )), ;
      LEN( aRetuList[ nThisFunc ] ) + 2 )
  NEXT nThisFunc
  nMaxLength += 4
  nHalfMax := INT(( nMaxLength / 2 ) - ( 12 + ( LEN( cSrcFile ) / 2 )))
  BublSort( nFuncList, aFuncList, aFuncType, aWindList, aRetuList )
  FWRITE( nHandle, PADR( REPLICATE( "*", nHalfMax ) + " FUNCTIONS/PROCEDURES IN " + UPPER( cSrcFile ) + " ", ;
    nMaxLength + 2, "*" ) + CRLF )              // put in a top header line
  FOR nThisFunc := 1 TO nFuncList
    FWRITE( nHandle, PADR( "** " + aFuncType[ nThisFunc] + aFuncList[ nThisFunc ], nMaxLength ) + "**" + CRLF ;
      + IIF (aWindList[ nThisFunc ] == "WINDOWS : ", "" , "**  " + PADR( aWindList[ nThisFunc ], nMaxLength - 4 ) + "**" + CRLF) ;
      + "**  " + PADR( aRetuList[ nThisFunc ], nMaxLength - 4 ) + "**" + CRLF )
  NEXT nThisFunc
  FWRITE( nHandle, REPLICATE( "*", nMaxLength + 2 ) + CRLF )
ENDIF

SELECT MCITEXT

FOR nThisLine := 1 TO nLastLine
  GO nThisLine
  cLineText := TRIM( LTRIM( MCITEXT->cTxtLine ))
  DO CASE
  CASE "******" $ cLineText .AND. " FUNCTIONS/PROCEDURES " $ cLineText
    nHeaderLen := LEN( cLineText )
    * Added v 1.8
    Go ++nThisLine // pour résoudre le problème de blocage quand on veut réindenter le programme qui réindente!!!
    WHILE LEN( TRIM( LTRIM( MCITEXT->cTxtLine ))) == nHeaderLen .AND. RIGHT( TRIM( MCITEXT->cTxtLine ), 2 ) == "**"
      GO ++nThisLine
    ENDDO
    --nThisLine
    LOOP
  CASE Slider( nThisLine, nLastLine )
    cText := TRIM( MCITEXT->cTxtLine )
    FWRITE( nHandle, cText + IIF( nThisLine == nLastLine, "", CRLF ))
    SELECT MCITEXT
  ENDCASE
NEXT nThisLine
CLOSE MCITEXT
FCLOSE( nHandle )

FERASE( cPrgFile )
RENAME ( cTempFile ) TO ( cPrgFile )

ShowProg_1.Hide
MsgInfo( cPrgFile + CRLF + "Reindenting completed!   ", "Success..." )

RETURN NIL
*
*---------------------------------------------------------------
STATIC FUNCTION ResetCfgWin
*---------------------------------------------------------------
* Resets the checkboxes and indents to their default values
MCICfg_1.Check_Fun.Value := z_lfunction
MCICfg_1.Check_Mul.Value := z_lmultline
MCICfg_1.Check_Whi.Value := z_ldowhile
MCICfg_1.Check_For.Value := z_lfornext
MCICfg_1.Check_Ifc.Value := z_lifcase
MCICfg_1.Check_Pop.Value := z_lpopup
MCICfg_1.Check_Win.Value := z_lwindow
MCICfg_1.Check_Cmt.Value := z_lcomment
MCICfg_1.Check_Act.Value := z_laction
MCICfg_1.Check_Hdr.Value := z_llistfunx
MCICfg_1.Text_2.Value  := z_nindent
MCICfg_1.Text_3.Value  := z_ncomment
MCICfg_1.Text_4.Value  := z_naction

RETURN NIL
*
*---------------------------------------------------------------
STATIC FUNCTION RestoreCfgDefaults( lFromCfgWin )
*---------------------------------------------------------------
* Confirms intent to restore defaults, and calls appropriate functions
IF MsgYesNo( "Are you sure?", "Restore defaults?")
  GetPrgVars( .T. )
  IF lFromCfgWin
    ResetCfgWin()                                                           // restore defaults
    UpdtChkCmt()                                                            // update "enabled" status for column align value
    UpdtChkAct()                                                            // update "enabled" status for column align value
  ENDIF
  MsgInfo( "Default configuration settings restored   ", "Confirming..." )
ENDIF

RETURN NIL
*
*---------------------------------------------------------------------------
STATIC FUNCTION SaveCfg
*---------------------------------------------------------------------------
* Stores configuration preferences in .DBF
USE ( "MCICFG" ) ALIAS "MCICFG" NEW EXCLUSIVE
IF EOF()
  APPEND BLANK
ENDIF
RLock()

REPLACE MCICFG->CFOLDER   WITH z_cfolder
REPLACE MCICFG->LACTION   WITH z_laction
REPLACE MCICFG->LCOMMENT  WITH z_lcomment
REPLACE MCICFG->LDOWHILE  WITH z_ldowhile
REPLACE MCICFG->LFORNEXT  WITH z_lfornext
REPLACE MCICFG->LFUNCTION WITH z_lfunction
REPLACE MCICFG->LIFCASE   WITH z_lifcase
REPLACE MCICFG->LLISTFUNX WITH z_llistfunx
REPLACE MCICFG->LMENUITEM WITH z_lmenuitem
REPLACE MCICFG->LMULTLINE WITH z_lmultline
REPLACE MCICFG->LPOPUP    WITH z_lpopup
REPLACE MCICFG->LWINDOW   WITH z_lwindow
REPLACE MCICFG->NACTION   WITH z_naction
REPLACE MCICFG->NCOMMENT  WITH z_ncomment
REPLACE MCICFG->NINDENT   WITH z_nindent

UNLOCK
DBGOTO( RECNO())
CLOSE MCICFG

RETURN NIL
*
*---------------------------------------------------------------
STATIC FUNCTION ShowProgress( cPrgFile )
*---------------------------------------------------------------
* Progress bar used for indenting and copying
IF .NOT. IsWindowDefined ( ShowProg_1 )
  DEFINE WINDOW ShowProg_1 ;
		AT 0,0 ;
    WIDTH 500 HEIGHT 152 ;
    TITLE "Indenting " + LTRIM( STR( nLastLine, 5 )) + " lines of Program Code" ;
    NOMINIMIZE NOMAXIMIZE ;
    FONT "Arial" SIZE 10 ;
    ON INIT { || IndentIt( cPrgFile ), ShowProg_1.Release }

    @ 30, 46 PROGRESSBAR Progress_1 ;
    RANGE 0, 100 ;
    WIDTH 400       ;
		HEIGHT 26 			;
		SMOOTH

    @ 76,14 LABEL Label_1 ;
    VALUE cPrgFile ;
    WIDTH 470 HEIGHT 24 FONT "Arial" SIZE 10

	END WINDOW

  ShowProg_1.Progress_1.Value := 0
  CENTER WINDOW ShowProg_1
  ACTIVATE WINDOW ShowProg_1
ELSE
  ShowProg_1.Title := ""
  ShowProg_1.Label_1.Value := ""
  ShowProg_1.Progress_1.Value := 0
  ShowProg_1.SetFocus
ENDIF

RETURN NIL
*
*---------------------------------------------------------------
STATIC FUNCTION Slider( nThisLine, nLastLine )
*---------------------------------------------------------------
* Moves the slider on the progress bar
LOCAL nPercent := VAL( STR(( nThisLine / nLastLine ) * 100, 3, 0 ))

ShowProg_1.Progress_1.Value := nPercent
ShowProg_1.Progress_1.SetFocus

RETURN .T.
*
*---------------------------------------------------------------
STATIC FUNCTION SplashDelay
*---------------------------------------------------------------
* Enables timing of "splash" graphic at startup
* From Harbour/MiniGUI contributed files
LOCAL iTime

iTime := Seconds()
While Seconds() - iTime < 1
EndDo

MT_Splash.Release

RETURN NIL
*
*---------------------------------------------------------------------------
STATIC FUNCTION UpdtChkCmt
*---------------------------------------------------------------------------
* Resets "enabled" property of comment-column alignment in configuration window
z_lcomment := MCICfg_1.Check_Cmt.Value
MCICfg_1.Text_3.Enabled := z_lcomment

RETURN NIL
*
*---------------------------------------------------------------------------
STATIC FUNCTION UpdtChkAct
*---------------------------------------------------------------------------
* Resets "enabled" property of action-column alignment in configuration window
z_laction := MCICfg_1.Check_Act.Value
MCICfg_1.Text_4.Enabled := z_laction

RETURN NIL
*
*---------------------------------------------------------------------------
STATIC FUNCTION What2Store( cFieldName, lBlanking )
*---------------------------------------------------------------------------
* Extracts the value of a single field in a .DBF file
* Enables the return of a "blank" value for the field
LOCAL nFieldPos := FIELDPOS( cFieldName )

IF ! VALTYPE( lBlanking ) == "L"
  lBlanking := .F.
ENDIF

IF lBlanking
  RETU BLANK( FIELDGET( nFieldPos ))
ENDIF
RETURN FIELDGET( nFieldPos )
*
*---------------------------------------------------------------------------
#pragma BEGINDUMP
#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "winreg.h"
#include "tchar.h"

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

   hwnd  = (HWND) hb_parnl (1);
   hdc   = GetDC(hwnd);

   GetClientRect(hwnd, &rect);

   cx = rect.top;
   cy = rect.bottom + 1;
   steps = (cy - cx) / 3;
   rect.bottom = 0;

   for( i = 0 ; i < steps ; i++ )
   {
      rect.bottom += 3;
      brush = CreateSolidBrush( RGB(0, 0, blue) );
      FillRect(hdc, &rect, brush);
      DeleteObject(brush);
      rect.top += 3;
      blue -= 1;
   }

   ReleaseDC(hwnd, hdc);
   hb_ret();
}

#pragma ENDDUMP
*
*---------------------------------------------------------------------------
* EOF
*---------------------------------------------------------------------------