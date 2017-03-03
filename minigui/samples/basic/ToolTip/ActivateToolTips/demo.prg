/*
  Name:  SET TOOLTIP ON | OFF Demo
  Description: Enable/Disable ToolTip Messages.

  Note: The change of the swith on|off do not function "on the fly", if SET TOOLTIP is ON,
        changing the value for OFF only affect to the new TOOLTIP definitions.

  Author: Antonio Novo <antonionovo@gmail.com>
  Date Created: 31/10/2005

  Revised: Grigory Filatov <gfilatov@inbox.ru>
  Date: 01/11/2005

  Revised: Petr Chornyj <myorg63@mail.ru>
  Date: 10/23/2016
 */

#include "minigui.ch"

MEMVAR aBtnTips

FUNCTION Main()

   PRIVATE aBtnTips := {}

   SET TOOLTIP ON
   SET TOOLTIPBALLOON ON

   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 350 ;
      HEIGHT 300 ;
      TITLE "SET TOOLTIP ON | OFF Demo (" + __FILE__ + ")" ;
      MAIN NOMAXIMIZE NOSIZE

      AAdd( aBtnTips, "Set ToolTip ON" )
      @ 20,120 BUTTON Button1 CAPTION "ToolTip ON" ACTION ToolTipOn() ;
         TOOLTIP ATail( aBtnTips )

      Form1.Button1.Enabled := ! IsToolTipActive

      AAdd( aBtnTips, "Set ToolTip OFF" )
      @ 55,120 BUTTON Button2 CAPTION "Set ToolTip OFF" ACTION ToolTipOff() ;
         TOOLTIP ATail( aBtnTips )

      Form1.Button2.Enabled := ! Form1.Button1.Enabled

      AAdd( aBtnTips, "Click Here to Test Modal Window" )
      @ 90,120 BUTTON Button3 CAPTION "Modal Window" ACTION Button3_Click() ;
         TOOLTIP ATail( aBtnTips )

      AAdd( aBtnTips, "Click Here to Exit this Sample" )
      @ 160,120 BUTTON Button4 CAPTION "Exit" ACTION ThisWindow.Release ;
         TOOLTIP ATail( aBtnTips )

      DEFINE STATUSBAR

         STATUSITEM "ToolTip Status is " + iif( IsToolTipActive, "ON", "OFF" ) ACTION MsgInfo( 'Click!' ) 

      END STATUSBAR

   END WINDOW

   SET TOOLTIP TEXTCOLOR TO RED   OF Form1
   SET TOOLTIP BACKCOLOR TO WHITE OF Form1

   IF IsVistaOrLater()
      ADD TOOLTIPICON WARNING_LARGE WITH MESSAGE "Action:" TO Form1
   ELSE
      ADD TOOLTIPICON WARNING       WITH MESSAGE "Action:" TO Form1
   ENDIF   

   CENTER   WINDOW Form1
   ACTIVATE WINDOW Form1

   RETURN NIL


PROCEDURE Button3_Click()

   DEFINE WINDOW Form2 ;
      AT 0,0 ;
      WIDTH 400 HEIGHT 200 ;
      TITLE 'Modal Test'  ;
      MODAL NOSIZE

      @ 110,150 BUTTON Button1 CAPTION "Exit" ACTION ThisWindow.Release ;
            TOOLTIP "Click Here to Close this Window"

      DEFINE STATUSBAR

         STATUSITEM "ToolTip Status is " + iif( IsToolTipActive, "ON", "OFF" ) ACTION MsgInfo( 'Click!' ) 

      END STATUSBAR
   END WINDOW

   IF IsVistaOrLater()
      ADD TOOLTIPICON INFO_LARGE WITH MESSAGE "Info:" TO Form2
   ELSE
      ADD TOOLTIPICON INFO       WITH MESSAGE "Info:" TO Form2
   ENDIF   
   
   Form2.Center
   Form2.Activate

   RETURN


STATIC PROCEDURE ToolTipOn()

   LOCAL i

   Form1.Button1.Enabled := .F.
   Form1.Button2.Enabled := .T.

   SET TOOLTIP ON

   Form1.StatusBar.Item( 1 ) := "ToolTip Status is " + iif( IsToolTipActive, "ON", "OFF" )

   FOR i := 1 to Len( aBtnTips )
       SetProperty( "Form1", "Button" + hb_NToS( i ), "ToolTip", aBtnTips[ i ] ) 
   NEXT

   RETURN


STATIC PROCEDURE ToolTipOff()

   LOCAL i

   Form1.Button1.Enabled := .T.
   Form1.Button2.Enabled := .F.

   SET TOOLTIP OFF

   Form1.StatusBar.Item( 1 ) := "ToolTip Status is " + iif( IsToolTipActive, "ON", "OFF" )

   FOR i := 1 to Len( aBtnTips )
       SetProperty( "Form1", "Button" + hb_NToS( i ), "ToolTip", "" )
   NEXT

   RETURN 
