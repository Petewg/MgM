/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2002-07 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Patch sample by Pierpaolo Martinello 2018
*/
ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM "MailBox Checker"
#define VERSION ' version 1.4'
#define COPYRIGHT ' 2002-2007 Grigory Filatov'

#define NTRIM( n ) LTrim( Str( n ) )
#define MsgInfo( c ) MsgInfo( c, "Information", , .f. )
#define MsgAlert( c ) MsgEXCLAMATION( c, "Attention", , .f. )

STATIC oSocket, aAccounts := {}, lConnect := .F., cAudioFile := "sounds\mail1.wav", nInterval := 180, lSplash := .T.

DECLARE WINDOW Form_Start
DECLARE WINDOW Form_Pass

MEMVAR cCryptKey, cIniFile
*--------------------------------------------------------*
PROCEDURE main
*--------------------------------------------------------*

   PUBLIC cCryptKey := REPL( "#$@%&", 2 )
   PUBLIC cIniFile := GetStartupFolder() + "\" + Lower( cFileNoExt( GetExeFileName() ) ) + ".ini"

   SET EPOCH TO ( Year( Date() ) -50 )

   SET DATE GERMAN

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 0 HEIGHT 0 ;
      TITLE PROGRAM ;
      ICON "ICON_1" ;
      MAIN NOSHOW ;
      NOTIFYICON "ICON_1" ;
      NOTIFYTOOLTIP PROGRAM + ": Left Click - Start/Stop, Right Click - Menu" ;
      ON NOTIFYCLICK IF( lConnect, oSocket:Close(), StartCheck() )

   IF File( cIniFile )
      WriteIni( "Information", "Date", DToC( Date() ), cIniFile )
      WriteIni( "Information", "Time", Time(), cIniFile )
   ELSE
      Defaults( .T. )
   ENDIF

   cAudioFile := GetIni( "Options", "Sound", cAudioFile, cIniFile )

   nInterval  := Val( GetIni( "Options", "Interval", NTRIM( nInterval ), cIniFile ) )

   lSplash    := ( GetIni( "Options", "Splash", "ON", cIniFile ) == "ON" )

   RightMenu()

   DEFINE TIMER Timer_1 ;
      INTERVAL nInterval * 1000 ;
      ACTION IF( lConnect, , StartCheck() )

   END WINDOW

   IF lSplash

      DEFINE WINDOW Form_Start ;
         AT 0, 0 ;
         WIDTH 160 HEIGHT 210 ;
         TOPMOST NOCAPTION ;
         ON INIT ( SysWait(), IF( IsWindowDefined( Form_Start ), Form_Start.Release, ) )

      IF File( 'LOGO.GIF' )
         @ -2, -2 IMAGE Image_1 ;
            PICTURE 'LOGO.GIF' ;
            WIDTH Form_Start.Width -4 ;
            HEIGHT Form_Start.Height -4 ;
            ACTION Form_Start.Release ;
            STRETCH WHITEBACKGROUND
      ELSE
         @ 30, 20 LABEL Label_1 ;
            WIDTH 160 HEIGHT 40 ;
            VALUE 'Loading' ;
            FONT 'Arial' SIZE 24
         @ 80, 45 LABEL Label_2 ;
            WIDTH 160 HEIGHT 40 ;
            VALUE 'Mail' ;
            FONT 'Arial' SIZE 24
         @ 130, 20 LABEL Label_3 ;
            WIDTH 160 HEIGHT 40 ;
            VALUE 'Checker' ;
            FONT 'Arial' SIZE 24
      ENDIF

      END WINDOW

      CENTER WINDOW Form_Start

      ACTIVATE WINDOW Form_Start, Form_1

   ELSE

      ACTIVATE WINDOW Form_1

   ENDIF

RETURN

*--------------------------------------------------------*
PROCEDURE RightMenu()
*--------------------------------------------------------*

   LOCAL nItem, cItem

   aAccounts  := LoadAccounts()

   DEFINE NOTIFY MENU OF Form_1
      FOR nItem := 1 TO Len( aAccounts )
         cItem := 'Item_' + NTRIM( nItem )
         ITEM aAccounts[ nItem ][ 1 ] ACTION ActToggle() NAME &cItem
         IF aAccounts[ nItem ][ 5 ]
            Form_1.&( cItem ).Checked := .T.
         ENDIF
      NEXT
      SEPARATOR
      ITEM '&Settings...'        ACTION Settings()
      SEPARATOR
      ITEM 'Start &Check'        ACTION IF( !lConnect, StartCheck(), )
      ITEM '&About...'           ACTION ShellAbout( "Check MailBox", PROGRAM + VERSION + CRLF + ;
           "Copyright " + Chr( 169 ) + COPYRIGHT, LoadIconByName( "ICON_1", 32, 32 ) ) 

      SEPARATOR
      ITEM 'E&xit'            ACTION Form_1.Release
   END MENU

RETURN

*--------------------------------------------------------*
PROCEDURE SysWait( nWait )
*--------------------------------------------------------*

   LOCAL iTime := Seconds()

   DEFAULT nWait TO 2

   DO WHILE Seconds() - iTime < nWait
      DO EVENTS
   ENDDO

RETURN

*--------------------------------------------------------*
FUNCTION LoadAccounts()
*--------------------------------------------------------*

   LOCAL aArray := Array( 16, 5 ), nI, cAccount, cServer, cLogin, cPass, lCheck

   FOR nI := 1 TO 16

      cAccount := GetIni( NTRIM( nI ) + "/16", "Account", "", cIniFile )
      cServer  := GetIni( NTRIM( nI ) + "/16", "Server", "", cIniFile )
      cLogin   := GetIni( NTRIM( nI ) + "/16", "Login", "", cIniFile )
      cPass    := DeCripta( GetIni( NTRIM( nI ) + "/16", "Password", "", cIniFile ), cCryptKey )
      lCheck   := ( GetIni( NTRIM( nI ) + "/16", "Check", "ON", cIniFile ) == "ON" )

      IF Empty( cAccount )
         ASize( aArray, nI -1 )
         EXIT
      ELSE
         aArray[ nI ] := { cAccount, cServer, cLogin, cPass, lCheck }
         WriteIni( NTRIM( nI ) + "/16", "MailBox", "0", cIniFile )
      ENDIF

   NEXT

Return( aArray )

*--------------------------------------------------------*
FUNCTION ActToggle()
*--------------------------------------------------------*

   LOCAL cItem := This.Name
   LOCAL nItem := Val( SubStr( cItem, At( "_", cItem ) + 1 ) )

   aAccounts[ nItem ][ 5 ] := !aAccounts[ nItem ][ 5 ]
   WriteIni( NTRIM( nItem ) + "/16", "Check", if( aAccounts[ nItem ][ 5 ], "ON", "OFF" ), cIniFile )
   cItem := 'Item_' + NTRIM( nItem )
   Form_1.&( cItem ).Checked := aAccounts[ nItem ][ 5 ]

RETURN NIL

*--------------------------------------------------------*
FUNCTION Defaults( lNew )
*--------------------------------------------------------*

   WriteIni( "Information", "Program", PROGRAM + VERSION, cIniFile )
   WriteIni( "Information", "Author", Chr( 169 ) + COPYRIGHT, cIniFile )
   WriteIni( "Information", "Contact", "gfilatov@inbox.ru", cIniFile )
   WriteIni( "Information", "Date", DToC( Date() ), cIniFile )
   WriteIni( "Information", "Time", Time(), cIniFile )

   WriteIni( "Options", "Sound", cAudioFile, cIniFile )
   WriteIni( "Options", "Interval", NTRIM( nInterval ), cIniFile )
   WriteIni( "Options", "Splash", if( lSplash, "ON", "OFF" ), cIniFile )
   IF lNew
      WriteIni( "1/16", "Account", "AccountName", cIniFile )
      WriteIni( "1/16", "Server", "POP3Server", cIniFile )
      WriteIni( "1/16", "Login", "username@server.com", cIniFile )
      WriteIni( "1/16", "Password", EnCripta( "UserPass", cCryptKey ), cIniFile )
      WriteIni( "1/16", "Check", "ON", cIniFile )
      WriteIni( "1/16", "MailBox", "0", cIniFile )
   ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION StartCheck()
*--------------------------------------------------------*

   LOCAL nI, cServer, cUser, cPass, aMsg, nNewMail, cTip := ""

   FOR nI := 1 TO Len( aAccounts )

      DO EVENTS

      IF aAccounts[ nI ][ 5 ]

         oSocket := TPop3():New()

         cServer  := aAccounts[ nI ][ 2 ]
         cUser    := aAccounts[ nI ][ 3 ]
         cPass    := aAccounts[ nI ][ 4 ]

         IF oSocket:Connect( AllTrim( cServer ) )

            lConnect := .T.
            DO EVENTS

            Form_1.NotifyTooltip := PROGRAM + ": Checking " + cServer + "..."
            Form_1.NotifyIcon := "ICON_1"

            IF Empty( cPass )
               cPass := cGetPassWord( 15, "Enter password for " + cUser )
            ENDIF

            IF oSocket:Login( AllTrim( cUser ), AllTrim( cPass ) )

               aMsg := oSocket:List( .F. )

               IF ( nNewMail := Len( aMsg ) - Val( GetIni( NTRIM( nI ) + "/16", "MailBox", "0", cIniFile ) ) ) > 0
                  WriteIni( NTRIM( nI ) + "/16", "MailBox", NTRIM( nNewMail ), cIniFile )
                  cTip += IF( Empty( cTip ), "", ", " ) + aAccounts[ nI ][ 1 ] + ": " + NTRIM( nNewMail )
               ENDIF

            ENDIF

         ELSE
            lConnect := .F.
            Form_1.NotifyIcon := "ICON_3"
            Form_1.NotifyTooltip := PROGRAM + ": Cann't connect to " + AllTrim( cServer )
            SysWait( 1 )
         ENDIF

         oSocket:Close()

      ENDIF

   NEXT

   IF lConnect
      lConnect := .F.

      IF Empty( cTip )
         Form_1.NotifyTooltip := PROGRAM + ": No new mail"
      ELSE
         Form_1.NotifyTooltip := cTip

         IF !Empty( cAudioFile )
            PLAY WAVE ( cAudioFile )
         ENDIF

         FOR nI := 1 TO 5
            Form_1.NotifyIcon := "ICON_2"
            SysWait( .5 )
            Form_1.NotifyIcon := "ICON_4"
            SysWait( .5 )
         NEXT

         Form_1.NotifyIcon := "ICON_2"
      ENDIF
   ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION Settings()
*--------------------------------------------------------*

   LOCAL aAcc := {}, aSrv := {}, aUsr := {}, aPwd := {}, aChk := {}, ;
      nAcc := 1, cAudio := cAudioFile

   AEval( aAccounts, {| e| AAdd( aAcc, e[ 1 ] ) } )
   AEval( aAccounts, {| e| AAdd( aSrv, e[ 2 ] ) } )
   AEval( aAccounts, {| e| AAdd( aUsr, e[ 3 ] ) } )
   AEval( aAccounts, {| e| AAdd( aPwd, e[ 4 ] ) } )
   AEval( aAccounts, {| e| AAdd( aChk, e[ 5 ] ) } )

   IF _Iswindowdefined( "Form_2" )
      DoMethod( "Form_2", "SETFOCUS" )
      RETURN NIL
   ENDIF

   DEFINE WINDOW Form_2 AT 0, 0 WIDTH 524 HEIGHT 296 TITLE "Settings" ;
      ICON "ICON_1" MODAL NOSIZE ;
      FONT _GetSysFont() SIZE 11

   @ 5, 7 FRAME Frame_1 CAPTION "Accounts" WIDTH 270 HEIGHT 210

   @ 27, 25 TEXTBOX Text_4 HEIGHT 24 WIDTH 205 VALUE "New Account" ;
      ON ENTER Form_2 .PicButton_1. SetFocus

   @ 26, 238 BUTTON PicButton_1 PICTURE "ADD" ;
      ACTION {|| IF( !Empty( Form_2 .Text_4. Value ), ;
      IF( Len( aAcc ) < 17, ;
      ( Form_2 .Combo_1. AddItem( Form_2 .Text_4. Value ), ;
      AAdd( aAcc, Form_2 .Text_4. Value ), ;
      AAdd( aSrv, "" ), AAdd( aUsr, "" ), AAdd( aPwd, "" ), AAdd( aChk, .T. ), ;
      Form_2 .Combo_1. Value := Len( aAcc ), ;
      Form_2 .Text_1. Value := ATail( aSrv ), ;
      Form_2 .Text_2. Value := ATail( aUsr ), ;
      Form_2 .Text_3. Value := ATail( aPwd ) ), ;
      MsgAlert( "Can not add more than 16 accounts!" ) ), ;
      MsgAlert( "Name is empty!" ) ) } ;
      WIDTH 26 HEIGHT 26 TOOLTIP "Add New Account"

   @ 62, 25 COMBOBOX Combo_1 WIDTH 205 HEIGHT 200 ITEMS aAcc VALUE nAcc ;
      ON CHANGE ( nAcc := Form_2 .Combo_1. Value, ;
      Form_2 .Text_1. Value := aSrv[ nAcc ], ;
      Form_2 .Text_2. Value := aUsr[ nAcc ], ;
      Form_2 .Text_3. Value := aPwd[ nAcc ], ;
      Form_2 .Text_4. Value := aAcc[ nAcc ] )

   @ 61, 238 BUTTON PicButton_2 PICTURE "DEL" ;
      ACTION {|| IF( Len( aAcc ) > 1, ;
      ( nAcc := Form_2 .Combo_1. Value, ;
      ADel( aAcc, nAcc ), ASize( aAcc, Len( aAcc ) -1 ), ;
      ADel( aSrv, nAcc ), ASize( aSrv, Len( aSrv ) -1 ), ;
      ADel( aUsr, nAcc ), ASize( aUsr, Len( aUsr ) -1 ), ;
      ADel( aPwd, nAcc ), ASize( aPwd, Len( aPwd ) -1 ), ;
      ADel( aChk, nAcc ), ASize( aChk, Len( aChk ) -1 ), ;
      Form_2 .Combo_1. DeleteItem( nAcc ), ;
      nAcc := IF( nAcc > 1, nAcc -1, 1 ), ;
      Form_2 .Combo_1. Value := nAcc, ;
      Form_2 .Text_1. Value := aSrv[ nAcc ], ;
      Form_2 .Text_2. Value := aUsr[ nAcc ], ;
      Form_2 .Text_3. Value := aPwd[ nAcc ], ;
      Form_2 .Text_4. Value := aAcc[ nAcc ], ;
      Form_2 .Combo_1. SetFocus ), ;
      MsgAlert( "Can not delete ALL existing accounts!" ) ) } ;
      WIDTH 26 HEIGHT 26 TOOLTIP "Delete Current Account"

   @ 100, 25 LABEL Label_1 VALUE "POP3 server:" WIDTH 100 HEIGHT 24
   @ 095, 115 TEXTBOX Text_1 HEIGHT 24 WIDTH 150 VALUE aSrv[ nAcc ] ;
      ON LOSTFOCUS {|| nAcc := Form_2 .Combo_1. Value, ;
      aSrv[ nAcc ] := Form_2 .Text_1. Value } ;
      ON ENTER Form_2 .Text_2. SetFocus

   @ 140, 25 LABEL Label_2 VALUE "Username:" WIDTH 100 HEIGHT 24
   @ 135, 115 TEXTBOX Text_2 HEIGHT 24 WIDTH 150 VALUE aUsr[ nAcc ] ;
      ON LOSTFOCUS {|| nAcc := Form_2 .Combo_1. Value, ;
      aUsr[ nAcc ] := Form_2 .Text_2. Value } ;
      ON ENTER Form_2 .Text_3. SetFocus

   @ 180, 25 LABEL Label_3 VALUE "Password:" WIDTH 100 HEIGHT 24
   @ 175, 115 TEXTBOX Text_3 HEIGHT 24 WIDTH 150 VALUE aPwd[ nAcc ] PASSWORD ;
      ON LOSTFOCUS {|| nAcc := Form_2 .Combo_1. Value, ;
      aPwd[ nAcc ] := Form_2 .Text_3. Value } ;
      ON ENTER Form_2 .Text_1. SetFocus

   @  5, 290 FRAME Frame_2 CAPTION "Sound" WIDTH 218 HEIGHT 100
   @ 31, 305 LABEL Label_6 VALUE "Wave file:" WIDTH 100 HEIGHT 24
   @ 62, 305 TEXTBOX Text_5 HEIGHT 24 WIDTH 156 VALUE cAudio ;
      ON CHANGE cAudio := Form_2 .Text_5. Value ;
      ON ENTER Form_2 .Button_4. SetFocus

   @ 61, 470 BUTTON PicButton_3 PICTURE "OPEN" ;
      ACTION {|| cAudio := ;
      GetFile( { { "Audio files", "*.wav" } }, "Select a File" ), ;
      IF( Empty( cAudio ), cAudio := cAudioFile, Form_2 .Text_5. Value := cAudio ), ;
      Form_2 .Text_5. SetFocus } ;
      WIDTH 26 HEIGHT 26 TOOLTIP "Select Wave file"
   @ 26, 415 BUTTON Button_4 CAPTION "&Play" ;
      ACTION Play_Click( Form_2 .Text_5. Value ) ;
      WIDTH 80 HEIGHT 26 TOOLTIP "Play Wave file"

   @ 110, 290 FRAME Frame_3 CAPTION "Interval" WIDTH 218 HEIGHT 105
   @ 140, 305 LABEL Label_4 VALUE "Check mailbox every" WIDTH 175 HEIGHT 24
   @ 175, 305 SPINNER Spinner_1 RANGE 1, 30 VALUE Int( nInterval / 60 ) ;
      WIDTH 40 HEIGHT 24
   @ 178, 350 LABEL Label_5 VALUE "minutes" WIDTH 116 HEIGHT 24

   @ 230, 25 CHECKBOX Check_1 ;
      CAPTION "Show Splash Screen at StartUp" WIDTH 220 HEIGHT 28 VALUE lSplash

   @ 230, 290 BUTTON Button_5 CAPTION "&Save" ;
      ACTION {|| SaveConfig( aAcc, aSrv, aUsr, aPwd, aChk, cAudio, ;
      Form_2 .Spinner_1. Value, Form_2 .Check_1. Value ), ;
      Form_2.Release } WIDTH 100 HEIGHT 28 TOOLTIP "Save CURRENT settings"

   @ 230, 407 BUTTON Button_6 CAPTION "&Cancel" ;
      ACTION Form_2.RELEASE WIDTH 100 HEIGHT 28 TOOLTIP "Discard changes"
   END WINDOW

   CENTER WINDOW Form_2

   ACTIVATE WINDOW Form_2

RETURN NIL

*--------------------------------------------------------*
FUNCTION SaveConfig( aAcc, aSrv, aUsr, aPwd, aChk, cAudio, nInt, lShow )
*--------------------------------------------------------*

   LOCAL nItem

   cAudioFile := cAudio
   lSplash    := lShow
   nInterval  := Int( nInt * 60 )
   Form_1 .Timer_1. Value := nInterval * 1000

   IF File( cIniFile )
      FErase( cIniFile )
   ENDIF

   Defaults( .F. )

   FOR nItem := 1 TO Len( aAcc )

      WriteIni( NTRIM( nItem ) + "/16", "Account", aAcc[ nItem ], cIniFile )
      WriteIni( NTRIM( nItem ) + "/16", "Server", aSrv[ nItem ], cIniFile )
      WriteIni( NTRIM( nItem ) + "/16", "Login", aUsr[ nItem ], cIniFile )
      WriteIni( NTRIM( nItem ) + "/16", "Password", EnCripta( aPwd[ nItem ], cCryptKey ), cIniFile )
      WriteIni( NTRIM( nItem ) + "/16", "Check", IF( aChk[ nItem ], "ON", "OFF" ), cIniFile )
      WriteIni( NTRIM( nItem ) + "/16", "MailBox", "0", cIniFile )

   NEXT

   RightMenu()

RETURN NIL

*--------------------------------------------------------*
PROCEDURE Play_Click( cAudio )
*--------------------------------------------------------*

   IF !Empty( cAudio )
      PLAY WAVE ( cAudio )
   ENDIF

RETURN

*--------------------------------------------------------*
FUNCTION GetIni( cSection, cEntry, cDefault, cFile )
*--------------------------------------------------------*


RETURN GetPrivateProfileString( cSection, cEntry, cDefault, cFile )

*--------------------------------------------------------*

FUNCTION WriteIni( cSection, cEntry, cValue, cFile )
*--------------------------------------------------------*


RETURN( WritePrivateProfileString( cSection, cEntry, cValue, cFile ) )

*--------------------------------------------------------*
FUNCTION cGetPassWord( nMaxLen, cTitle, cBmp )
*--------------------------------------------------------*

   LOCAL nTries := 0, lGo := .F., cPassword := Space( nMaxLen )

   DEFAULT cBmp TO "KEY"

   DEFINE WINDOW Form_Pass ;
      AT 0, 0 ;
      WIDTH 250 HEIGHT 145 ;
      TITLE cTitle ;
      MODAL ;
      NOSIZE NOSYSMENU ;
      ON PAINT Form_Pass .Text_1. SetFocus ;
      ON RELEASE {|| IF( lGo, cPassword := AllTrim( Form_Pass .Text_1. Value ), ) } ;
      FONT _GetSysFont() SIZE 11

   @ 10, 55 LABEL Label_1 ;
      VALUE "Enter password..." ;
      WIDTH 170 HEIGHT 24 FONT _GetSysFont() SIZE 12

   @ 40, 55 TEXTBOX Text_1 ;
      WIDTH 170 PASSWORD ;
      TOOLTIP "Enter Password" MAXLENGTH nMaxLen ;
      ON ENTER {|| nTries++, lGo := Len(  Form_Pass .Text_1. Value ) > 0, ;
      If( nTries > 2 .OR. lGo, Form_Pass.Release, ;
      ( MsgAlert( "Empty password!" ), Form_Pass .Text_1. SetFocus ) ) }

   @ 40, 10 IMAGE Image_1 ;
      PICTURE cBmp ;
      WIDTH 36 ;
      HEIGHT 38

   @ 80, 50 BUTTON Button_1 ;
      CAPTION "Continue" ;
      ACTION {|| nTries++, lGo := Len( Form_Pass .Text_1. Value ) > 0, ;
      If( nTries > 2 .OR. lGo, Form_Pass.Release, ;
      ( MsgAlert( "Empty password!" ), Form_Pass .Text_1. SetFocus ) ) } ;
      WIDTH 80 HEIGHT 28

   @ 80, 145 BUTTON Button_2 ;
      CAPTION "Exit" ;
      ACTION Form_Pass.Release ;
      WIDTH 80 HEIGHT 28

   END WINDOW

   center window Form_Pass

   activate window Form_Pass

RETURN cPassword

/*
* Add By Pierpaolo 2018
*/

*--------------------------------------------------------*
FUNCTION Decripta ( cString,chiave )
*--------------------------------------------------------*
   LOCAL nTam, cCrypt := "", i

   Chiave  := iif( Empty( Chiave ), "@#$%", Chiave )
   Chiave  := _adc( chiave, ordinale( 1 ) )
   cString := iif( Empty( cString ) .OR. Len ( cString ) < 3  ;
      , "NOPASSW0RD",cString )
   nTam := Len( cString )
   DO WHILE Len( Chiave ) < nTam
      Chiave += Chiave
   ENDDO
   cCrypt := ""
   FOR i := 1 TO nTam
      cCrypt += Chr( Asc( SubStr( cString, i, 1 ) ) - Asc( SubStr( Chiave, i, 1 ) ) )
   NEXT

RETURN cCrypt
/*
*/
*--------------------------------------------------------*
FUNCTION Encripta( cString,chiave )
*--------------------------------------------------------*
   LOCAL nTam, cCrypt := "", i

   Chiave  := iif( Empty( Chiave ), "@#$%", Chiave )
   Chiave  := _adc( chiave, ordinale( 1 ) )
   cString := iif( Empty( cString ) .OR. Len ( cString ) < 3  ;
      , "NOPASSW0RD",cString )
   nTam := Len( cString )
   DO WHILE Len( Chiave ) < nTam
      Chiave += Chiave
   ENDDO
   cCrypt := ""
   FOR i := 1 TO nTam
      cCrypt += Chr( Asc( SubStr( cString, i, 1 ) ) + Asc( SubStr( Chiave, i, 1 ) ) )
   NEXT

RETURN cCrypt
/*
*/
*--------------------------------------------------------*
FUNCTION Ordinale( nmb )
*--------------------------------------------------------*
   LOCAL nString
   nmb     := iif( nmb == NIL, 0, nmb )
   nString := Right( Str( nmb ), 1 )

RETURN nString
/*
*/
*--------------------------------------------------------*
FUNCTION _adc ( iString, adc )
*--------------------------------------------------------*
   LOCAL lRes := '', i
   FOR i = 1 TO Len ( iString )
      lres += SubStr( iString, i, 1 )
      IF i = Val( adc )
         lres += adc
      ENDIF
   NEXT

RETURN lres
/*
*/
*--------------------------------------------------------*
FUNCTION _sdc ( iString, adc )
*--------------------------------------------------------*
   LOCAL lRes := '', i
   FOR i = 1 TO Len ( iString )
      IF i = Val( adc )
         LOOP
      ENDIF
      lres += SubStr( iString, i, 1 )
   NEXT

RETURN lres
/*
* End of Patch Pierpaolo 2018
*/
