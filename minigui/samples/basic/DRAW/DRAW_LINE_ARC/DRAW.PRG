ANNOUNCE RDDSYS

#include <minigui.ch>


PROCEDURE Main()

   DEFINE WINDOW Draw ;
     AT 0, 0 ;
     WIDTH 600 HEIGHT 600 ;
     TITLE "DRAWING EXAMPLES" ;
     MAIN ;
     NOMAXIMIZE ;
     NOSIZE ;
     ON INIT Draw()

     DEFINE STATUSBAR
     END STATUSBAR

   END WINDOW // Draw

   Draw.Center
   Draw.Activate

RETURN // Main()


function draw()

**********Diagonale 
DRAW LINE IN WINDOW draw AT 10,10 TO 500,500
showstatus("LINE DIAGONAL",1)

* viertelkreis quadrant 1 durchmesser 400
DRAW RECTANGLE IN WINDOW draw AT 100,100 TO 500,500 
DRAW ARC IN WINDOW draw AT 100,100 TO 500,500 FROM RADIAL 300,500 TO RADIAL 100,300  
showstatus("ARC in quadrant 1",2)

* viertelkreis quadrant 2 durchmesser 400
DRAW RECTANGLE IN WINDOW draw AT 100,100 TO 500,500
DRAW ARC IN WINDOW draw AT 100,100 TO 500,500 FROM RADIAL 100,300 TO RADIAL 300,100
showstatus("ARC in quadrant 2",2)

* viertelkreis quadrant 3 durchmesser 400
DRAW RECTANGLE IN WINDOW draw AT 100,100 TO 500,500
DRAW ARC IN WINDOW draw AT 100,100 TO 500,500 FROM RADIAL 300,100 TO RADIAL 500,300
showstatus("ARC in quadrant 3",2)

* viertelkreis quadrant 4 durchmesser 400
DRAW RECTANGLE IN WINDOW draw AT 100,100 TO 500,500
DRAW ARC IN WINDOW draw AT 100,100 TO 500,500 FROM RADIAL 500,300 TO RADIAL 300,500 
showstatus("ARC in quadrant 4",3)

********************demos mit linie der endpunkte RADIAL, diese mit kreismittelpunkt=mittelpunkt des rectangles verbunden schneiden den kreis, dort sind die anfangs/endpunkte des bogens
erase window draw

DRAW RECTANGLE IN WINDOW draw AT 100,100 TO 500,500
****** diagonalen
draw line in window draw at 100,100 to 500,500
draw line in window draw at 500,100 to 100,500
****** radial endpunkte vom draw arc
draw line in window draw at 500,550 to 100,50
****** endpunkte mit kreismittelpunkt verbinden
draw line in window draw at 500,550 to 300,300
draw line in window draw at 100,50 to 300,300

DRAW ARC IN WINDOW draw AT 100,100 TO 500,500 FROM RADIAL 500,550 TO RADIAL 100,50  
showstatus("ARC with RADIAL-points connected with the center of the RECTANGLE=center of the ARC",5)


erase window draw

DRAW RECTANGLE IN WINDOW draw AT 100,100 TO 500,500
****** diagonalen
draw line in window draw at 100,100 to 500,500
draw line in window draw at 500,100 to 100,500
****** radial endpunkte vom draw arc
draw line in window draw at 350,550 to 50,350
****** endpunkte mit kreismittelpunkt verbinden
draw line in window draw at 350,550 to 300,300
draw line in window draw at 50,350 to 300,300

DRAW ARC IN WINDOW draw AT 100,100 TO 500,500 FROM RADIAL 350,550 TO RADIAL 50,350  
showstatus("ARC with RADIAL-points connected with the center of the RECTANGLE=center of the ARC",.01)

return nil


function showstatus(cMsg,nSec)

draw.statusbar.item(1):=cMsg
InkeyGUI(nSec*1000)          // delay in seconds

return nil
