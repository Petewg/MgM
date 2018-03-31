/*
 * MiniGUI TaskBar Notifier Demo
 *
 * Author: P.Chornyj <myorg63@mail.ru>
*/

#include "minigui.ch"
#include "taskbarnotifier.ch"

PROCEDURE Main

	LOAD WINDOW Main
	ON KEY ESCAPE OF Main ACTION ThisWindow.Release
	CENTER WINDOW Main
	ACTIVATE WINDOW Main

RETURN

/*
*/
PROCEDURE ShowPopup_1()
local popup1
local aClr1 := {   0,   0, 200 }
local aClr2 := { 255,   0,   0 }
local aClr3 := {   0,   0,   0 } 
local aClr4 := {   0,   0, 255 } 

	INIT NOTIFIER popup1 SKIN skin.bmp
	
	KEEP VISIBLE OF popup1 ONMOUSEOVER ( Main.Check_1.Value )
	RESHOW OF popup1 ONMOUSEOVER ( Main.Check_2.Value )

	SET TITLE RECTANGE OF popup1 TO 42, 15, 115, 30

        IF ( Main.Check_3.Value )
		SET TITLE ONDBLCLICK ACTION MsgInfo( popup1:ObjectName() + " Title was clicked" ) OF popup1 ON
	ELSE
		SET TITLE ONDBLCLICK OF popup1 OFF
	ENDIF
	SET TITLE NORMAL COLOR aClr1 OF popup1
	SET TITLE HOVER COLOR aClr2 OF popup1

	SET CONTENT RECTANGE OF popup1 TO 12, 45, 135, 110
        IF ( Main.Check_4.Value )
		SET CONTENT ONDBLCLICK ACTION MsgInfo( popup1:ObjectName() + " Content was clicked" ) OF popup1 ON
	ELSE
		SET CONTENT ONDBLCLICK OF popup1 OFF
	ENDIF
	SET CONTENT NORMAL COLOR aClr3 OF popup1
	SET CONTENT HOVER COLOR aClr4 OF popup1

	SHOW NOTIFIER popup1 TITLE Main.Text_2.Value CONTENT Main.Text_3.Value ;
		DELAYS SHOWING Main.Text_1.Value STAYING Main.Text_4.Value HIDING Main.Text_5.Value

RETURN
/*
*/
PROCEDURE ShowPopup_2()
local popup2
//local aClr1 := { 200,   0,   0 }
//local aClr2 := { 255,   0,   0 }
local aClr3 := { 255,   0,   0 } 
local aClr4 := {   0,   0, 255 } 

	INIT NOTIFIER popup2 SKIN skin2.bmp
	
	KEEP VISIBLE OF popup2 ONMOUSEOVER ( Main.Check_1.Value )
	RESHOW OF popup2 ONMOUSEOVER ( Main.Check_2.Value )

	SET CONTENT RECTANGE OF popup2 TO 122, 90, 287, 140
        IF ( Main.Check_4.Value )
		SET CONTENT ONDBLCLICK ACTION MsgInfo( popup2:ObjectName() + " Content was clicked" ) OF popup2 ON
	ELSE
		SET CONTENT ONDBLCLICK OF popup2 OFF
	ENDIF
	SET CONTENT NORMAL COLOR aClr3 OF popup2
	SET CONTENT HOVER COLOR aClr4 OF popup2

	SHOW NOTIFIER popup2 TITLE Main.Text_2.Value CONTENT Main.Text_3.Value ;
		DELAYS SHOWING Main.Text_1.Value STAYING Main.Text_4.Value HIDING Main.Text_5.Value

RETURN
/*
*/
PROCEDURE ShowPopup_3()
local popup3
local aClr1 := {   0,   0,   0 }
local aClr2 := { 255,   0,   0 }
local aClr3 := { 255, 255,   0 } 
local aClr4 := { 255, 255, 255 } 

	INIT NOTIFIER popup3 SKIN skin3.bmp
	
	KEEP VISIBLE OF popup3 ONMOUSEOVER ( Main.Check_1.Value )
	RESHOW OF popup3 ONMOUSEOVER ( Main.Check_2.Value )

	SET TITLE RECTANGE OF popup3 TO 144, 60, 260, 80

        IF ( Main.Check_3.Value )
		SET TITLE ONDBLCLICK ACTION MsgInfo( popup3:ObjectName() + " Title was clicked" ) OF popup3 ON
	ELSE
		SET TITLE ONDBLCLICK OF popup3 OFF
	ENDIF
	SET TITLE NORMAL COLOR aClr1 OF popup3
	SET TITLE HOVER COLOR aClr2 OF popup3

	SET CONTENT RECTANGE OF popup3 TO 122, 90, 287, 140
        IF ( Main.Check_4.Value )
		SET CONTENT ONDBLCLICK ACTION MsgInfo( popup3:ObjectName() + " Content was clicked" ) OF popup3 ON
	ELSE
		SET CONTENT ONDBLCLICK OF popup3 OFF
	ENDIF
	SET CONTENT NORMAL COLOR aClr3 OF popup3
	SET CONTENT HOVER COLOR aClr4 OF popup3

	SHOW NOTIFIER popup3 TITLE Main.Text_2.Value CONTENT Main.Text_3.Value ;
		DELAYS SHOWING Main.Text_1.Value STAYING Main.Text_4.Value HIDING Main.Text_5.Value

RETURN
