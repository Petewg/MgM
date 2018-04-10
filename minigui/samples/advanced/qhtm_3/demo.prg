/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "MiniGUI.ch"
#include "I_QHTM.ch"
#include "Inkey.ch"

// ќпределени€ WinAPI

#define WM_NOTIFY	             78

//  оманды (переназначаемые ссылки)

#define ID_CMD                  'CMD:'
#define ID_CMD_STOPLOG          ( ID_CMD + 'STOPLOG' )  // ќстановить логирование

Memvar nScrollPos, aBreak

Procedure Main
Local cIntro := ''

If !QHTM_Init()
   MsgStop( ( 'Library QHTM.dll not loaded.' + CRLF + ;
              'Program terminated.'                   ;
            ), 'Error' )
   Quit
Endif

Set default icon to 'MAIN'

Set Events function to MyEvents

cIntro := '<body bgcolor="White">'
cIntro += '<center><img src="res:QHTM_LOGO"></center>'
cIntro += '<h3 align="center"><font color="Navy" face="Georgia">This example shows next functions:</font></h3>'
cIntro += '<big><ol>'
cIntro += '<li>Adding web-page text to display text'
cIntro += '<ul><font color="Maroon">'
cIntro += '<li>QHTM_AddHTML()'
cIntro += '<li>QHTM_AddHTML2()'
cIntro += '</ul></font>'
cIntro += '<li>Getting and restore position of scrolling'
cIntro += '<ul><font color="Maroon">'
cIntro += '<li>QHTM_GetScrollPos()'
cIntro += '<li>QHTM_SetScrollPos()'
cIntro += '<li>QHTM_ScrollPos()'
cIntro += '<li>QHTM_ScrollPercent()'
cIntro += '</ul></font>'
cIntro += '</ol>'

Define window wMain at 0, 0 ;
       Width 630 Height 600 ;
       Title 'QHTM Demo'    ;
       Main                 ;
       NoMaximize           ;
       NoSize

   Define main menu
     
     Define Popup 'File'
        MenuItem 'Exit Alt+X' Action wMain.Release
     End Popup
     
     Define Popup 'Test'
        MenuItem 'QHTM_AddHTML()' Action TestAddHTML()
        MenuItem 'QHTM_AddHTML2()' Action TestAddHTML2()
     End Popup
     
   End Menu
   
   @ 0, 0 QHTM HTML_Intro                                                                         ;
          Value cIntro                                                                            ;
          Width  ( wMain.Width - GetBorderWidth() * 2 )                                           ;
          Height ( wMain.Height - GetTitleHeight() - GetMenuBarHeight() - GetBorderHeight() * 2 ) ;
          Border

End Window

On Key Alt+X of wMain Action AppDone()

Center Window wMain
Activate Window wMain

Return

****** End of Main ******


/******
*
*       AppDone()
*
*       «авершение работы
*
*/

Procedure AppDone

QHTM_End()
QUIT

Return

****** End of AppDone ******


/******
*
*       MyEvents( hWnd, nMsg, wParam, lParam )
*
*       ѕользовательска€ обработка событий.
*       «десь будем раздел€ть команды запуска процедур и перехода по ссылкам
*       в QHTM
*
*/
 
Function MyEvents( hWnd, nMsg, wParam, lParam )
Memvar aBreak
Local nPos , ;
      cLink

If ( nMsg == WM_NOTIFY )

   If ( ( nPos := AScan( _HMG_aControlIds , wParam ) ) > 0 )

      If ( _HMG_aControlNames[ nPos ] == 'MyHTML' )

         If ( ID_CMD $ QHTM_GetNotify( lParam ) )
            
            cLink := QHTM_GetLink( lParam )
            
            If ( cLink == ID_CMD_STOPLOG )
               aBreak[ 'Stop' ] := .T.
            Endif
         
         Endif
         
      Endif
      
   Endif
     
Endif

Events( hWnd, nMsg, wParam, lParam )
  
Return 0

****** End of MyEvents ******


/******
*
*       TestAddHTML()
*
*       ƒобавление кода HTML к существующему с сохранением
*       текущего положени€
*
*/

Static Procedure TestAddHTML
Local cValue  := GetWindowText( GetControlHandle( 'HTML_Intro', 'wMain' ) ), ;
      nHandle

Private nScrollPos := 0

Define window wAddHTML at 0, 0     ;
       Width 600 Height 400        ;
       Title 'Demo QHTM_AddHTML()' ;
       Modal                       ;
       NoSize

   @ 0, 0 QHTM MyHTML                                                                ;
          Width  ( wAddHTML.Width - GetBorderWidth() * 2 )                           ;
          Height ( wAddHTML.Height - GetTitleHeight() - GetBorderHeight() * 2 - 45 ) ;
          Border

   @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.MyHTML.Col + 10 ) Button btnGetPos ;
     Caption 'GetScrollPos' Action GetQHTMPos( nHandle )

   @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.btnGetPos.Col + wAddHTML.btnGetPos.Width + 20 ) Button btnSetPos ;
     Caption 'SetScrollPos' Action SetQHTMPos( nHandle )

   @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.btnSetPos.Col + wAddHTML.btnSetPos.Width + 20 ) Button btnGoTo ;
     Caption 'Goto 50%' Action { || MsgInfo( 'Current position: ' + hb_ntos( QHTM_ScrollPercent( nHandle ) ) + '%' ), ; 
                                    QHTM_ScrollPercent( nHandle, 50 )                                                     ;
                               }
     
   @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.MyHTML.Width - 120 ) Button btnStart                          ;
     Caption 'Add HTML' Action { | nHeight, aSize | QHTM_AddHTML( nHandle, cValue )                          , ;
                                                    nHeight := GetWindowHeight( nHandle )                    , ;
					       aSize := QHTM_GetSize( nHandle )                         , ;
					       Iif( ( aSize[ 2 ] > nHeight )                            , ;
					            SetProperty( 'wAddHTML', 'btnGoTo', 'Enabled', .T. ), ;
						 )                                                       ;
			     }        

End Window

nHandle := GetControlHandle( 'MyHTML', 'wAddHTML' )

//  нопку восстановлени€ позиции прокрутки запрещаем до запоминани€ позиции 

wAddHTML.btnSetPos.Enabled := .F.
wAddHTML.btnGoTo.Enabled   := .F.

On Key Escape of wAddHTML Action wAddHTML.Release
On Key Alt+X of wAddHTML Action AppDone()

Center window wAddHTML
Activate window wAddHTML

Return

****** End of TestAddHTML ******


/******
*
*       GetQHTMPos( nHandle )
*
*       ѕолучение текущей позиции прокрутки
*
*/

Static Procedure GetQHTMPos( nHandle )
Local nPos      , ;
      cMsg := ''

nPos := QHTM_GetScrollPos( nHandle )
//nPos := QHTM_ScrollPos( nHandle )

cMsg += '<p><b>QHTM_GetScrollPos()</b></p><p>'
cMsg += ( 'Position:' + Str( nPos ) )

If Empty( nPos )
   cMsg += ( '<br>' + '<font color="Red"><i>A zero value is not remembered.</i></font>' )
Else
   nScrollPos := nPos
   wAddHTML.btnSetPos.Enabled := .T.
Endif

QHTM_MessageBox( cMsg, 'Get scroll pos' )

Return

****** End of GetQHTMPos ******


/******
*
*       SetQHTMPos( nHandle )
*
*       ¬осстановление позиции прокрутки
*
*/

Static Procedure SetQHTMPos( nHandle )
Memvar nScrollPos
QHTM_SetScrollPos( nHandle, nScrollPos )
//QHTM_ScrollPos( nHandle, nScrollPos )
Return

****** End of SetQHTMPos ******


/******
*
*       TestAddHTML2()
*
*       ƒобавление кода HTML к существующему с возможностью
*       выбора текущего положени€ (не измен€ть или устанавливать
*       на добавленные строки)
*
*/

Static Procedure TestAddHTML2
Private aBreak := { 'Stop' => .F., ;
                    'Exit' => .T.  ;
		}

Define window wAddHTML at 0, 0                    ;
       Width 400 Height 190                       ;
       Title 'Logging ouput demo QHTM_AddHTML2()' ;
       Modal                                      ;
       NoSize

   @ 0, 0 QHTM MyHTML                                                                ;
          Value '<body bgcolor="White"><h3>Lengthy operation</h3></body>'            ;
          Width  ( wAddHTML.Width - GetBorderWidth() * 2 )                           ;
          Height ( wAddHTML.Height - GetTitleHeight() - GetBorderHeight() * 2 - 45 ) ;
          Border

   @ ( wAddHTML.MyHTML.Height + 20 ), ( wAddHTML.MyHTML.Col + 20 ) Checkbox cbxScroll ;
     Caption 'Auto scroll' Width 80 Height 15 

   @ ( wAddHTML.MyHTML.Height + 10 ), ( wAddHTML.MyHTML.Width - 120 ) Button btnStart ;
     Caption 'Start' Action { || HB_HFill( aBreak, .F. ), Logging() }
            
End Window

On Key Escape of wAddHTML Action { || HB_HFill( aBreak, .T. ), wAddHTML.Release }
On Key Alt+X of wAddHTML Action AppDone()

Center window wAddHTML
Activate window wAddHTML

Return

****** End of TestAddHTML2 ******


/******
*
*       Logging()
*
*       ѕример формирование лога
*
*
*/
  
Static Procedure Logging
Memvar aBreak
Static nLine := 1
Local nHandle := GetControlHandle( 'MyHTML', 'wAddHTML' )                                                             , ;
      aMsg    := { '<code><br>Line number %1$s</code>'                                                                , ;
                   '<code><br>Oops, something went wrong at line %1$s</code>'                                         , ;
                   '<code><br><font color="red"Oops, something went wrong at line %1$s</code></font>'                 , ;
                   '<code><br><font bgcolor="red">Something went wrong <i>really</i> wrong at line %1$s</font></code>', ;
                   '<code><br><font color=blue>Warning on line %1$s, <a href="CMD:STOPLOG" title="click me and I promise to stop">Click here</a> to stop this output.</font></code>', ;
                   "<code><br><font bgcolor='yellow'>This looks groovy</font> don't you think?</code>"                  ;
                 }                                                                                                    , ;
      nLen                                                                                                            , ;
      cString

//<code><br><font color=blue>Warning on line %d, <a href=\"blah\" title='click me and I promise to stop'>Click here</a> to stop this output.</font></code>"
wAddHTML.btnStart.Caption := 'Stop'
wAddHTML.btnStart.Action  := { || aBreak[ 'Stop' ] := .T. }

nLen := Len( aMsg )

Do while !aBreak[ 'Stop' ]

   cString := aMsg[ HB_RandomInt( 1, nLen ) ]
   cString := HB_StrFormat( cString, LTrim( Str( nLine ) ) )
   
   If wAddHTML.cbxScroll.Value  
      QHTM_AddHTML2( nHandle, cString, 2 )
   Else
      QHTM_AddHTML2( nHandle, cString, 1 )
   Endif

   nLine ++
   
   Do Events
   
   // «амедл€ет вывод
   
   Inkey( 0.1, INKEY_ALL )
   
Enddo

If !aBreak[ 'Exit' ]
   wAddHTML.btnStart.Caption := 'Start'
   wAddHTML.btnStart.Action  := { || HB_HFill( aBreak, .F. ), Logging() }
Endif

Return

****** End of Logging ******
