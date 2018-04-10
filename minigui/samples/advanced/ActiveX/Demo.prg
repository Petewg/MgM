/*
   Marcelo Torres, Noviembre de 2006.
   TActivex para [x]Harbour Minigui.
   Adaptacion del trabajo de:
   ---------------------------------------------
   Lira Lira Oscar Joel [oSkAr]
   Clase TAxtiveX_FreeWin para Fivewin
   Noviembre 8 del 2006
   email: oscarlira78@hotmail.com
   http://freewin.sytes.net
   CopyRight 2006 Todos los Derechos Reservados
   ---------------------------------------------
   Adapted by Grigory Filatov <gfilatov@inbox.ru> from
   http://msdn2.microsoft.com/en-us/library/Aa752043.aspx
*/

#include "minigui.ch"
#ifndef __XHARBOUR__
   #include "hbcompat.ch"
#endif

Set Procedure To tAxPrg.prg

Static oWActiveX
Static oActiveX
Static bVerde := .T.
Static lThemed := .F.

FUNCTION Main()

   lThemed := IsThemed()

   DEFINE WINDOW WinDemo ;
      AT 0,0 ;
      WIDTH 808 ;
      HEIGHT 534 + IF(lThemed, 10, 0) ;
      TITLE 'Minigui ActiveX Support Demo' ;
      ICON 'DEMO.ICO' ;
      MAIN ;
      ON INIT fOpenActivex() ;
      ON RELEASE fCloseActivex() ;
      ON SIZE Adjust() ;
      ON MAXIMIZE Adjust() ;
      FONT 'Verdana' ;
      SIZE 10

      @ GetProperty( "WinDemo" , "height" ) - 60 - IF(lThemed, GetBorderHeight() + 1, 0), 08 LABEL LSemaforo ;
         VALUE " " ;
         WIDTH 27 ;
         HEIGHT 27 ;
         BACKCOLOR {0,255,0}

      @ GetProperty( "WinDemo" , "height" ) - 57 - IF(lThemed, GetBorderHeight() + 1, 0), 43 TEXTBOX URL_ToNavigate ;
         HEIGHT 23 ;
         WIDTH GetProperty( "WinDemo" , "width" ) - 170 ;
         ON ENTER Navegar()

      @ GetProperty( "WinDemo" , "height" ) - 60 - IF(lThemed, GetBorderHeight() + 1, 0), ;
         GetProperty( "WinDemo" , "width" ) - 115 - IF(lThemed, GetBorderHeight() + 1, 0) BUTTON BNavigate ;
         CAPTION 'Navigate' ;
         ACTION Navegar() ;
         WIDTH 100 ;
         HEIGHT 28

      @ 5 , 10 BUTTON BBack ;
         CAPTION 'Back' ;
         ACTION fGoBack() ;
         WIDTH 74 ;
         HEIGHT 21

      @ 5 , 95 BUTTON BForward ;
         CAPTION 'Forward' ;
         ACTION fGoForward() ;
         WIDTH 74 ;
         HEIGHT 21

      @ 5 , 180 BUTTON BHome ;
         CAPTION 'Home' ;
         ACTION ( oActiveX:GoHome(), WinDemo.BBack.Enabled := .t. ) ;
         WIDTH 74 ;
         HEIGHT 21

      @ 5 , 265 BUTTON BSearch ;
         CAPTION 'Search' ;
         ACTION ( oActiveX:GoSearch(), WinDemo.BBack.Enabled := .t. ) ;
         WIDTH 74 ;
         HEIGHT 21

      @ 5 , 350 BUTTON BPrint ;
         CAPTION 'Print' ;
         ACTION Show_DropDownMenu() ;
         WIDTH 74 ;
         HEIGHT 21

      DEFINE CONTEXT MENU CONTROL BPrint
         MENUITEM "Preview..." ACTION fPrint(.t.)
         MENUITEM "Print"      ACTION fPrint(.f.)
      END MENU

      DEFINE TIMER TSemaforo ;
         INTERVAL 500 ;
         ACTION SwitchSemaforo()

   END WINDOW

   SET CONTEXT MENU CONTROL BPrint OF WinDemo OFF

   WinDemo.BBack.Enabled := .f.
   WinDemo.BForward.Enabled := .f.

   Center Window WinDemo

   Activate Window WinDemo

RETURN NIL

Static Procedure fOpenActivex()
   oWActiveX := TActiveX():New( "WinDemo", "Shell.Explorer.2" , 32 , 0 , ;
                GetProperty( "WinDemo" , "width" ) - 2*GetBorderHeight() , GetProperty( "WinDemo" , "height" ) - 102 - IF(lThemed, GetBorderHeight(), 0) )
   oActiveX := oWActiveX:Load()
   oActiveX:Silent := 1
   oActiveX:Navigate( "www.google.com" )
Return

Static Procedure fCloseActivex()
   If Valtype(oWActiveX) <> "U"
      oWActiveX:Release()
   endif
Return

Procedure SwitchSemaforo()
   if oActiveX:Busy()
      if bVerde
         bVerde := .F.
         WinDemo.LSemaforo.BackColor := {255,0,0}
      endif
   else
      if !bVerde
         bVerde := .T.
         WinDemo.LSemaforo.BackColor := {0,255,0}
         SetProperty( "WinDemo" , "URL_ToNavigate" , "value" , oActiveX:LocationURL() )
      endif
   endif
Return

Procedure Navegar()
   oActiveX:Navigate( GetProperty( "WinDemo" , "URL_ToNavigate" , "value" ) )
   WinDemo.BBack.Enabled := .t.
Return

Static Procedure fGoBack()
   If Valtype(oActiveX) <> "U"
      Try
         oActiveX:GoBack()
         WinDemo.BForward.Enabled := .t.
      Catch
         WinDemo.BBack.Enabled := .f.
      End
   endif
Return

Static Procedure fGoForward()
   If Valtype(oActiveX) <> "U"
      Try
         oActiveX:GoForward()
         WinDemo.BBack.Enabled := .t.
      Catch
         WinDemo.BForward.Enabled := .f.
      End
   endif
Return

#define OLECMDID_PRINT 6
#define OLECMDID_PRINTPREVIEW 7
#define OLECMDEXECOPT_DODEFAULT 0

Static Procedure fPrint(lPreview)
   If Valtype(oWActiveX) <> "U"
	If lPreview
		oActiveX:ExecWB( OLECMDID_PRINTPREVIEW, OLECMDEXECOPT_DODEFAULT )
        Else
		oActiveX:ExecWB( OLECMDID_PRINT, OLECMDEXECOPT_DODEFAULT )
	EndIf
   endif
Return

Static Procedure Show_DropDownMenu()
   Local aPos:={0,0,0,0}

   GetWindowRect( GetControlHandle( "BPrint", "WinDemo" ), aPos )
   TrackPopupMenu( _HMG_xContextMenuHandle, aPos[1], aPos[2] + WinDemo.BPrint.Height, GetFormHandle( "WinDemo" ) )
Return

Procedure Adjust()
   SetProperty( "WinDemo" , "LSemaforo" , "row" , GetProperty( "WinDemo" , "height" ) - 60 - IF(lThemed, GetBorderHeight() + 1, 0) )
   SetProperty( "WinDemo" , "URL_ToNavigate" , "row" , GetProperty( "WinDemo" , "height" ) - 57 - IF(lThemed, GetBorderHeight() + 1, 0) )
   SetProperty( "WinDemo" , "URL_ToNavigate" , "width" , GetProperty( "WinDemo" , "width" ) - 170 )
   SetProperty( "WinDemo" , "BNavigate" , "row" , GetProperty( "WinDemo" , "height" ) - 60 - IF(lThemed, GetBorderHeight() + 1, 0) )
   SetProperty( "WinDemo" , "BNavigate" , "col" , GetProperty( "WinDemo" , "width" ) - 115 - IF(lThemed, GetBorderHeight() + 1, 0) )
   oWActiveX:Adjust()
Return
