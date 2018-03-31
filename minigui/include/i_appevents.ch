/*
 * MINIGUI - Harbour Win32 GUI library source code
 * 
 * Copyright 2017 P.Chornyj <myorg63@mail.ru>
 */

#xcommand ON APPEVENT [ID] <nId> ACTION <bAction> OF <window> [<noactive: NOACTIVE>] [<once: ONCE>] ;
=> ;
AppEvents( <window>, <nId>, <bAction>, !<.noactive.>, <.once.> )

#xcommand ON APPEVENT [ID] <nId> ACTION <bAction> OF <window> [<noactive: NOACTIVE>] [<once: ONCE>] [RESULT] TO <lResult> ;
=> ;
<lResult> := AppEvents( <window>, <nId>, <bAction>, !<.noactive.>, <.once.> )


#xtranslate EMIT [EVENT] [ID] <nId> OF <window> ;
=> ;
SendMessage( <window>, <nId>, 0, 0 )


#xcommand REMOVE APPEVENT [ID] [<nId>] OF <window> [<once: ONCE>] ;
=> ;
AppEventsRemove( <window>, <nId>, <.once.> )

#xcommand REMOVE APPEVENT [ID] [<nId>] OF <window> [<once: ONCE>] [RESULT] TO <lResult> ;
=> ;
<lResult> := AppEventsRemove( <window>, <nId>, <.once.> )

#xcommand REMOVE APPEVENT ALL OF <window> [<once: ONCE>] ;
=> ;
AppEventsRemove( <window>, 0, <.once.> )

#xcommand REMOVE APPEVENT ALL OF <window> [<once: ONCE>] [RESULT] TO <lResult> ;
=> ;
<lResult> := AppEventsRemove( <window>, 0, <.once.> )


#xcommand UPDATE APPEVENT [ID] <nId> [ACTION <bAction>] OF <window> [<noactive: NOACTIVE>] [<once: ONCE>] ;
=> ;
AppEventsUpdate( <window>, <nId>, <bAction>, !<.noactive.>, <.once.> )

#xcommand UPDATE APPEVENT [ID] <nId> [ACTION <bAction>] OF <window> [<noactive: NOACTIVE>] [<once: ONCE>] [RESULT] TO <lResult> ;
=> ;
<lResult> := AppEventsUpdate( <window>, <nId>, <bAction>, !<.noactive.>, <.once.> )


#xcommand [DEFINE] [WINDOW] MESSAGEONLY <window> [EVENTS [FUNC] <efunc>] [RESULT] TO <lResult> ; 
=> ; 
<lResult> := InitMessageOnlyWindow( <"window">, <"efunc"> ) 


#xcommand ON WINEVENT [ID] <nId> ACTION <bAction> OF <window> [<noactive: NOACTIVE>] [<once: ONCE>];
=> ;
WinEvents( <window>, <nId>, <bAction>, !<.noactive.>, <.once.> )

#xcommand ON WINEVENT [ID] <nId> ACTION <bAction> OF <window> [<noactive: NOACTIVE>] [<once: ONCE>] [RESULT] TO <lResult>;
=> ;
<lResult> := WinEvents( <window>, <nId>, <bAction>, !<.noactive.>, <.once.> )


#xcommand REMOVE WINEVENT [ID] [<nId>] OF <window> [<once: ONCE>];
=> ;
WinEventsRemove( <window>, <nId>, <.once.> )

#xcommand REMOVE WINEVENT [ID] [<nId>] OF <window> [<once: ONCE>] [RESULT] TO <lResult>;
=> ;
<lResult> := WinEventsRemove( <window>, <nId>, <.once.> )

#xcommand REMOVE WINEVENT ALL OF <window> [<once: ONCE>];
=> ;
WinEventsRemove( <window>, 0, <.once.> )

#xcommand REMOVE WINEVENT ALL OF <window> [<once: ONCE>] [RESULT] TO <lResult>;
=> ;
<lResult> := WinEventsRemove( <window>, 0, <.once.> )


#xcommand UPDATE WINEVENT [ID] <nId> [ACTION <bAction>] OF <window> [<noactive: NOACTIVE>] [<once: ONCE>];
=> ;
WinEventsUpdate( <window>, <nId>, <bAction>, !<.noactive.>, <.once.> )

#xcommand UPDATE WINEVENT [ID] <nId> [ACTION <bAction>] OF <window> [<noactive: NOACTIVE>] [<once: ONCE>] [RESULT] TO <lResult>;
=> ;
<lResult> := WinEventsUpdate( <window>, <nId>, <bAction>, !<.noactive.>, <.once.> )
