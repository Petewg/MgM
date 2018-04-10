/*
 * Harbour MiniGUI (H)orizontal Splitter Demo
 * Copyright 2017 P.Chornyj <myorg63@mail.ru>
 */
ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

#include "demo.ch"

#xtranslate RECTWIDTH ( <aRect> ) => ( <aRect>\[3\] - <aRect>\[1\] )
#xtranslate RECTHEIGHT( <aRect> ) => ( <aRect>\[4\] - <aRect>\[2\] )
///////////////////////////////////////////////////////////////////////////////
procedure main()

   local aRect := { 0, 0, 0, 0 }
   local w, h, nBorder, nYPos

   set events func to App_OnEvents

   define window  Form_1 ;
      clientarea  400, 200 ;
      title       'HSplitter demo' ;
      windowtype  MAIN ;
      on release  HSplitter_Release( Form_1.Handle )

      GetClientRect( This.Handle, @aRect )
      w := RECTWIDTH ( aRect )
      h := RECTHEIGHT( aRect )

      nYPos   := Int( 0.5 * h  )
      nBorder := 4

      @ 0, 0 editbox EditBox_1 ;
         width    w ;
         height   nYPos ;
         value    LOREMIPSUM_L ;
         tooltip  'EditBox_1' ;
         nohscroll 

      @ nYPos + nBorder, 0 editbox EditBox_2 ;
         width    w ;
         height   h - ( nYPos + nBorder ) ;
         value    LOREMIPSUM_R ;
         tooltip  'EditBox_2' ;
         nohscroll 
   end window

   // Add Horizontal Splitter to Form_1   
   HSplitter_Init( Form_1.Handle, { Form_1.EditBox_1.Handle, Form_1.EditBox_2.Handle }, nYPos, nBorder )

   Form_1.Cursor := IDC_SIZENS

   Form_1.Center()
   Form_1.Activate()

return

///////////////////////////////////////////////////////////////////////////////
// FUNCTION App_OnEvents( hwnd, msg, wParam, lParam )
///////////////////////////////////////////////////////////////////////////////
#translate $_ => ( hwnd, msg, wParam, lParam )

function App_OnEvents$_
   local nRes

   switch msg
   case WM_LBUTTONDOWN
      nRes := HSplitter_OnLButtonDown$_
      exit

   case WM_LBUTTONUP
      nRes := HSplitter_OnLButtonUp$_
      exit

   case WM_MOUSEMOVE
      nRes := HSplitter_OnMouseMove$_
      exit

   case WM_SIZE        
      nRes := HSplitter_OnSize$_
      exit
   otherwise
      nRes := Events$_
   end

return nRes
