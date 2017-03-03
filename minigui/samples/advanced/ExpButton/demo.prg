/*
 *  MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright (C) 2013 Sergey Logoshny
*/

#include "minigui.ch"

ANNOUNCE RDDSYS

MEMVAR aButStyles

//-------------------------------------------------------------------\\
FUNCTION Main()
//-------------------------------------------------------------------\\
Local i, cItemName, Width, Height
Local HBtn1DropMenu, HBtn2DropMenu, HBtn3DropMenu, HBtn4DropMenu
Local cResPath := GetStartupFolder() + "\images\"

SET MENUSTYLE EXTENDED

PUBLIC aButStyles:={;
       {0,1, {106,131,160},{106,131,160},{106,131,160},{106,131,160}, BLACK,BLACK,1, {106,131,160},RED },;
       {1,3, {182,189,210}, {220,220,220}, {182,189,210}  ,WHITE, BLACK,BLACK,1, {220,220,220},WHITE },;
       {2,4, {106,131,160}, {220,220,220}, {220,220,220}  ,{220,220,220}, BLACK,BLACK,0, {220,220,220},WHITE },;
       {3,4, {192,192,192}, {192,192,192}, {192,192,192} ,{192,192,192}, BLACK,BLACK,0, {82,189,210},BLACK },;
       {4,2, GRAY ,{255,255,255},   {106,131,160} ,{255,255,255}, BLACK,BLACK,1, GRAY,{106,131,160} },;
       {5,2, GRAY ,{220,220,220},   GRAY ,{255,255,255}, BLACK,{196,0,0},1, GRAY,RED },;
       {6,4, GRAY ,{220,220,220},   {106,131,160} ,{255,255,255}, BLACK,BLACK,1, GRAY,{106,131,160} },;
       {7,2, GRAY ,{255,255,255},   {106,131,160} ,{255,255,255}, BLACK,BLACK,2, GRAY,{106,131,160} },;
       {8,2, GRAY ,{220,220,220},   GRAY ,{255,255,255}, BLACK,{196,0,0},2, GRAY,RED },;
       {9,4, GRAY ,{220,220,220},   {106,131,160} ,{255,255,255}, BLACK,BLACK,2, GRAY,{106,131,160} },;
       {10,1,{196,164,164},{196,164,164},{196,164,164},{196,164,164}, WHITE,WHITE,0, {106,131,160},RED },;
       {11,1,{196,164,164},{196,164,164},{196,164,164},{196,164,164}, BLACK,RED,0, {106,131,160},RED };
}

DEFINE WINDOW WinMain AT 0,0 WIDTH 440 HEIGHT 350 ;
       TITLE 'Experimentation' ;
       MAIN ;
       NOMAXIMIZE NOSIZE NOCAPTION ;
       BACKCOLOR {196,164,164}

	Width:=WinMain.Width
	Height:=WinMain.Height

//-------------------------------------------------------------------\\
// Window Border
//-------------------------------------------------------------------\\

	DRAW LINE IN WINDOW WinMain ;
		AT 0, 0 TO 0, Width ;
		PENCOLOR BLACK ;
		PENWIDTH 2

	DRAW LINE IN WINDOW WinMain ;
		AT Height, 0 TO Height, Width ;
		PENCOLOR BLACK ;
		PENWIDTH 2

	DRAW LINE IN WINDOW WinMain ;
		AT 0, 0 TO Height, 0 ;
		PENCOLOR BLACK ;
		PENWIDTH 2

	DRAW LINE IN WINDOW WinMain ;
		AT 0, Width TO Height, Width ;
		PENCOLOR BLACK ;
		PENWIDTH 2

//-------------------------------------------------------------------\\
// OwnerDraw Title
//-------------------------------------------------------------------\\

@ 1,1 IMAGE FWTop PICTURE cResPath+'FW.bmp' WIDTH Width-2 HEIGHT 24 STRETCH

@ 2,5 LABEL lblTop WIDTH Width-30 HEIGHT 22 VALUE ' OwnButtonPaint Function Demo' ;
      FONTCOLOR WHITE TRANSPARENT VCENTERALIGN ;
      ACTION MoveActiveWindow() 
 
//-------------------------------------------------------------------\\
// OwnerDraw Close button
//-------------------------------------------------------------------\\

@ 5,Width-24 BUTTONEX btnClose WIDTH 16 HEIGHT 14 PICTURE cResPath+'bc2.bmp' ;                    
      ACTION ThisWindow.Release()

//-------------------------------------------------------------------\\
// OwnerDraw Menu
//-------------------------------------------------------------------\\

@ 25,01  IMAGE FWMenu PICTURE cResPath+'FW1.bmp'  WIDTH Width-2 HEIGHT 24 STRETCH

@ 26,02  BUTTONEX MenuBut1 WIDTH 80 HEIGHT 22  CAPTION 'Menu-1' ;
          ACTION ShowBtnDropMenu('WinMain', This.Name,HBtn1DropMenu) ;
          TOOLTIP 'Menu-1'
          DEFINE CONTEXT MENU CONTROL MenuBut1
                  FOR i=1 TO 4
                      cItemName:='MenuBut1_'+Hb_NToS(i)
                      MENUITEM 'MenuBut1_'+Hb_NToS(i);
                      ACTION MsgInfo(This.Name) NAME &cItemName  
                  NEXT
          END MENU
          HBtn1DropMenu := _HMG_xContextMenuHandle
          SET CONTEXT MENU CONTROL MenuBut1 OF WinMain OFF
          WinMain.MenuBut1.Cargo:='1'

@ 26,82  BUTTONEX MenuBut2 WIDTH 80 HEIGHT 22  CAPTION 'Menu-2' ;
          ACTION ShowBtnDropMenu('WinMain', This.Name,HBtn2DropMenu) ;
          TOOLTIP 'Menu-2'
          DEFINE CONTEXT MENU CONTROL MenuBut2
                  FOR i=1 TO 4
                      cItemName:='MenuBut2_'+Hb_NToS(i)
                      MENUITEM 'MenuBut2_'+Hb_NToS(i);
                      ACTION MsgInfo(This.Name) NAME &cItemName  
                  NEXT
          END MENU
          HBtn2DropMenu := _HMG_xContextMenuHandle
          SET CONTEXT MENU CONTROL MenuBut2 OF WinMain OFF
          WinMain.MenuBut2.Cargo:='1'

@ 26,162 BUTTONEX MenuBut3 WIDTH 80 HEIGHT 22  CAPTION 'Menu-3' ;
          ACTION ShowBtnDropMenu('WinMain', This.Name,HBtn3DropMenu) ;
          TOOLTIP 'Menu-3'
          DEFINE CONTEXT MENU CONTROL MenuBut3
                  FOR i=1 TO 4
                      cItemName:='MenuBut3_'+Hb_NToS(i)
                      MENUITEM 'MenuBut3_'+Hb_NToS(i);
                      ACTION MsgInfo(This.Name) NAME &cItemName
                  NEXT
          END MENU
          HBtn3DropMenu := _HMG_xContextMenuHandle
          SET CONTEXT MENU CONTROL MenuBut3 OF WinMain OFF
          WinMain.MenuBut3.Cargo:='1'

@ 26,242 BUTTONEX MenuBut4 WIDTH 80 HEIGHT 22  CAPTION 'Menu-4' ;  
          ACTION ShowBtnDropMenu('WinMain', This.Name,HBtn4DropMenu) ;
          TOOLTIP 'Menu-4'
          DEFINE CONTEXT MENU CONTROL MenuBut4
                  FOR i=1 TO 4
                      cItemName:='MenuBut4_'+Hb_NToS(i)
                      MENUITEM 'MenuBut4_'+Hb_NToS(i);
                      ACTION MsgInfo(This.Name) NAME &cItemName
                  NEXT
          END MENU
          HBtn4DropMenu := _HMG_xContextMenuHandle
          SET CONTEXT MENU CONTROL MenuBut4 OF WinMain OFF
          WinMain.MenuBut4.Cargo:='1'

//-------------------------------------------------------------------\\
// OwnerDraw ToolBar
//-------------------------------------------------------------------\\

@ 49,01  IMAGE FW2 PICTURE cResPath+'fw2.bmp' WIDTH Width-2 HEIGHT 22 STRETCH

@ 50,10  BUTTONEX Bar2But1 HEIGHT 20 WIDTH 20    PICTURE cResPath+'open_gr.bmp' ;
	  ACTION MsgInfo(This.Name)
          WinMain.Bar2But1.Cargo:='3,'+cResPath+'open.bmp'

@ 50,40  BUTTONEX Bar2But2 HEIGHT 20 WIDTH 20    PICTURE cResPath+'save_gr.bmp' ;
	  ACTION MsgInfo(This.Name) 
          WinMain.Bar2But2.Cargo:='3,'+cResPath+'save.bmp'

@ 50,70  BUTTONEX Bar2But3 HEIGHT 20 WIDTH 20   PICTURE cResPath+'new_gr.bmp' ;
	  ACTION MsgInfo(This.Name)
          WinMain.Bar2But3.Cargo:='3,'+cResPath+'new.bmp'

@ 50,100 BUTTONEX Bar2But4 HEIGHT 20 WIDTH 20  PICTURE cResPath+'del_gr.bmp' ;
	  ACTION MsgInfo(This.Name) 
          WinMain.Bar2But4.Cargo:='3,'+cResPath+'del.bmp'


/////////////////////////////////////////////////////////////////


@ 89,01  IMAGE FW1 PICTURE cResPath+'FW.bmp' WIDTH Width-2 HEIGHT 42 STRETCH

@ 90,10  BUTTONEX Bar1But1 HEIGHT 40 WIDTH 50   CAPTION "Open" PICTURE cResPath+'open.bmp' ;
          FONT "Arial" SIZE 8 VERTICAL ;
	  ACTION MsgInfo(This.Name)
          WinMain.Bar1But1.Cargo:='2,'+cResPath+'open.bmp'

@ 90,60  BUTTONEX Bar1But2 HEIGHT 40 WIDTH 50    CAPTION "Save" PICTURE cResPath+'save.bmp' ;
          FONT "Arial" SIZE 8 VERTICAL ;
	  ACTION MsgInfo(This.Name) 
          WinMain.Bar1But2.Cargo:='2,'+cResPath+'save.bmp'

@ 90,110 BUTTONEX Bar1But3 HEIGHT 40 WIDTH 50  CAPTION "Add" PICTURE cResPath+'new.bmp' ;
          FONT "Arial" SIZE 8 VERTICAL ;
	  ACTION MsgInfo(This.Name)
          WinMain.Bar1But3.Cargo:='2,'+cResPath+'new.bmp'

@ 90,160 BUTTONEX Bar1But4 HEIGHT 40 WIDTH 50 CAPTION "Del" PICTURE cResPath+'del.bmp' ;
          FONT "Arial" SIZE 8 VERTICAL ;
	  ACTION MsgInfo(This.Name) 
          WinMain.Bar1But4.Cargo:='2,'+cResPath+'del.bmp'


/////////////////////////////////////////////////////////////////


@ 160,20  BUTTONEX But1 HEIGHT 22 WIDTH 120  CAPTION 'Button-1'  ;
	  ACTION MsgInfo(This.Name)
          WinMain.But1.Cargo:='4'

@ 160,160 BUTTONEX But2 HEIGHT 22 WIDTH 120  CAPTION 'Button-2'  ;
	  ACTION MsgInfo(This.Name)
          WinMain.But2.Cargo:='5'

@ 160,300 BUTTONEX But3 HEIGHT 22 WIDTH 120  CAPTION 'Button-3'  ;
	  ACTION MsgInfo(This.Name)
          WinMain.But3.Cargo:='6'

@ 190,20  BUTTONEX But4 HEIGHT 22 WIDTH 120  CAPTION 'Button-4'  ;
	  ACTION MsgInfo(This.Name)
          WinMain.But4.Cargo:='7'

@ 190,160 BUTTONEX But5 HEIGHT 22 WIDTH 120  CAPTION 'Button-5'  ;
	  ACTION MsgInfo(This.Name)
          WinMain.But5.Cargo:='8'

@ 190,300 BUTTONEX But6 HEIGHT 22 WIDTH 120  CAPTION 'Button-6'  ;
	  ACTION MsgInfo(This.Name)
          WinMain.But6.Cargo:='9'


/////////////////////////////////////////////////////////////////


@ 230,40  BUTTONEX ImgBut1  PICTURE cResPath+"img1.bmp" WIDTH 150 HEIGHT 94  ADJUST  NOTRANSPARENT ;
          FONT "Arial" SIZE 12 ;
	  ACTION MsgInfo(This.Name)
          WinMain.ImgBut1.Cargo:='0,'+cResPath+'img11.bmp'
          WinMain.ImgBut1.Caption:='ImageButton1'

@ 230,240 BUTTONEX ImgBut2  PICTURE cResPath+"img2.bmp" WIDTH 150 HEIGHT 40 ADJUST  ;
          FONT "Arial" SIZE 11 ;
	  ACTION MsgInfo(This.Name)
          WinMain.ImgBut2.Cargo:='10,'+cResPath+'img21.bmp'
          WinMain.ImgBut2.Caption:='ImageButton2'

@ 280,240 BUTTONEX ImgBut3  PICTURE cResPath+"img3.bmp" WIDTH 150 HEIGHT 40 ADJUST  ;
          FONT "Arial" SIZE 11 ;
	  ACTION MsgInfo(This.Name)
          WinMain.ImgBut3.Cargo:='10,'+cResPath+'img31.bmp'
          WinMain.ImgBut3.Caption:='ImageButton3'

END WINDOW 

CENTER WINDOW WinMain
ACTIVATE WINDOW WinMain
RETURN NIL

//-------------------------------------------------------------------\\

FUNCTION ShowBtnDropMenu(cWin,cBut,HBtnDropMenu)
LOCAL aPos:={0,0,0,0}

	GetWindowRect( GetControlHandle( cBut, cWin ), /*@*/aPos )

	TrackPopupMenu( HBtnDropMenu, aPos[1], ;
                aPos[2] + GetProperty(cWin,cBut,'Height'), GetFormHandle( cWin ) )
RETURN NIL

//-------------------------------------------------------------------\\

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

PROCEDURE MoveActiveWindow(hWnd)

	Default hWnd := GetActiveWindow()

	PostMessage(hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0)
RETURN
