#include <hmg.ch>
#define CRLF chr(13)+chr(10)

function main()
local cSMsg:="Do Something"
SET AUTOADJUST ON NOBUTTONS

DEFINE WINDOW MainForm;
   AT 90,90;
   WIDTH 780;
   HEIGHT 550;
  TITLE 'Inventory Renamer';
   MAIN; //   NOSIZE
   
   DEFINE MAIN Menu of MainForm
      DEFINE POPUP "File"
         MENUITEM "Select From List" ACTION DoList()
         SEPARATOR
         MENUITEM "Exit" ACTION ThisWindow.Release
      END POPUP
   END MENU

   DEFINE STATUSBAR
      STATUSITEM cSMsg
      CLOCK
      DATE
   END STATUSBAR
   @ 005,005 EDITBOX Edit_1            ;
      WIDTH 760 HEIGHT 425 ;// READONLY    ;
         VALUE " ";
       FONTCOLOR {128,000,128}           ;
      FONT "Courier New" SIZE 10
   @ 440, 665 BUTTON bn_Go;
      OF MainForm;
      CAPTION "Rename";
      ACTION MsgInfo("Go!")
   @ 443, 10  LABEL lb_Stat ;
     VALUE " ";
      WIDTH 650;
      TRANSPARENT
   
END WINDOW       

MainForm.Center
MainForm.Activate

return NIL

//-----------------------
function Dolist()
local cList, n, nTokens
local cStr:=""

if !file("EditBoxScroll.prg")
   MsgInfo("Didn't find a EditBoxScroll.prg")
    return NIL
endif

cList:=memoread("EditBoxScroll.prg")
nTokens:=numtoken(cList,CRLF)

MsgInfo("List is "+str(len(cList))+" bytes long"+ CRLF + str(nTokens)+" lines in the list")

For n := 1 to nTokens
  cDir:=token(cList,CRLF,n)
  cStr:=cStr+""+strzero(n,3)+": "+cDir+CRLF
  MainForm.Edit_1.Value:=cStr
  MainForm.Edit_1.Caretpos := len(MainForm.Edit_1.Value)-1
   DoEvents()
Next

INSERT_CTRL_END()

return NIL

//-------------------
function strzero(nNum,nLen)
return right(replicate("0",nLen)+ltrim(token(str(nNum),".",1)),nLen)

//-------------------
#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( INSERT_CTRL_END )
{
   keybd_event(
      VK_CONTROL,   // virtual-key code
      0,      // hardware scan code
      0,      // flags specifying various function options
      0      // additional data associated with keystroke
   );

   keybd_event(
      VK_END   ,   // virtual-key code
      0,      // hardware scan code
      0,      // flags specifying various function options
      0      // additional data associated with keystroke
   );

   keybd_event(
      VK_CONTROL,   // virtual-key code
      0,      // hardware scan code
      KEYEVENTF_KEYUP,// flags specifying various function options
      0      // additional data associated with keystroke
   );
}

#pragma ENDDUMP