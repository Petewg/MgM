/*
  Name: SET TOOLTIP ON | OFF Demo
  Description: Enable/Disable ToolTip Messages.
  Note: The change of the swith on|off do not function "on the fly", if SET TOOLTIP is ON,
        changing the value for OFF only affect to the new TOOLTIP definitions.
  Author: Antonio Novo <antonionovo@gmail.com>
  Date Created: 31/10/2005
  Revized: Grigory Filatov <gfilatov@inbox.ru>
  Date: 01/11/2005
*/

#include "minigui.ch"

Memvar aBtnTips

Function Main
	Private aBtnTips := {}

	Set ToolTipBalloon On
	Set ToolTip ON

	DEFINE WINDOW Form1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE "SET TOOLTIP ON | OFF Demo" ;
		MAIN NOMAXIMIZE NOSIZE

	        aadd( aBtnTips, "Set ToolTip ON (Default)" )
		@ 20,50 BUTTON Button1 CAPTION "ToolTip ON" ACTION Demo3ToolTipOn() ;
	         TOOLTIP atail(aBtnTips)

	        aadd( aBtnTips, "Set ToolTip OFF" )
		@ 50,50 BUTTON Button2 CAPTION "Set ToolTip OFF" ACTION Demo3ToolTipOff() ;
	         TOOLTIP atail(aBtnTips)

	        aadd( aBtnTips, "Click Here to Test Modal Window" )
		@ 80,50 BUTTON Button3 CAPTION "Modal Window" ACTION Modal_CLick() ;
	         TOOLTIP atail(aBtnTips)

	        aadd( aBtnTips, "Click Here to Exit this Sample" )
		@ 110,50 BUTTON Button4 CAPTION "Exit" ACTION ThisWindow.Release ;
	         TOOLTIP atail(aBtnTips)
				
				
		@ 20,250 BUTTON Button6 CAPTION "Set large icons" ACTION SetIconSize( .t. ) ;
	         TOOLTIP atail(aBtnTips)								
		@ 50,250 BUTTON Button5 CAPTION "Set small icons" ACTION SetIconSize( .f. ) ;
	         TOOLTIP atail(aBtnTips)								

		DEFINE STATUSBAR

			STATUSITEM "ToolTip Status is " + iif(_lSetToolTip(), "ON", "OFF") ACTION MsgInfo('Click!') 

		END STATUSBAR

	END WINDOW
	
	ADD TOOLTIPICON WARNING WITH MESSAGE "Warning" OF Form1

	SET TOOLTIP TEXTCOLOR TO RED OF Form1

	SET TOOLTIP BACKCOLOR TO WHITE OF Form1

	CENTER WINDOW Form1

	ACTIVATE WINDOW Form1

Return Nil

*-----------------------------------------------------------------------------*
Procedure Modal_CLick
*-----------------------------------------------------------------------------*

	DEFINE WINDOW Form2 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 200 ;
		TITLE 'Modal Test'  ;
		MODAL NOSIZE

		@ 110,150 BUTTON Button1 CAPTION "Exit" ACTION ThisWindow.Release ;
	         TOOLTIP "Click Here to Close this Window"

		DEFINE STATUSBAR

			STATUSITEM "ToolTip Status is " + iif(_lSetToolTip(), "ON", "OFF") ACTION MsgInfo('Click!') 

		END STATUSBAR

	END WINDOW

	Form2.Center

	Form2.Activate

Return

Function Demo3ToolTipOn
Local i

   SET TOOLTIP ON

   Form1.StatusBar.Item(1) := "ToolTip Status is " + iif(_lSetToolTip(), "ON", "OFF")
   for i:=1 to len(aBtnTips)
       SetProperty ( "Form1", "Button" + ltrim(str(i)), "ToolTip", aBtnTips [i] ) 
   next

Return Nil

Function Demo3ToolTipOff
Local i

   SET TOOLTIP OFF

   Form1.StatusBar.Item(1) := "ToolTip Status is " + iif(_lSetToolTip(), "ON", "OFF")
   for i:=1 to len(aBtnTips)
       SetProperty ( "Form1", "Button" + ltrim(str(i)), "ToolTip", "" ) 
   next

Return Nil


STATIC PROCEDURE SetIconSize( lLarge )

	IF lLarge
		IF win_osIsVistaOrUpper()
			ADD TOOLTIPICON WARNING_LARGE WITH MESSAGE "Warning (large icon)" OF Form1
		ELSE
			MsgExclamation( "Not supported on your Windows version!" + hb_EoL() + ;
                         "Large tooltip icons are available on Vista or later.", "Unsupported OS version" )
		ENDIF
	ELSE
		ADD TOOLTIPICON WARNING       WITH MESSAGE "Warning (small icon)" OF Form1
	ENDIF
	
	RETURN
	