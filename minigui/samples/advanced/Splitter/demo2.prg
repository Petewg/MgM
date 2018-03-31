/*
 * Harbour MiniGUI (V)ertical Splitter Demo
 * Copyright 2017 P.Chornyj <myorg63@mail.ru>
 */
ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

#include "demo.ch"

#xtranslate RECTWIDTH ( <aRect> ) => ( <aRect>\[3\] - <aRect>\[1\] )
#xtranslate RECTHEIGHT( <aRect> ) => ( <aRect>\[4\] - <aRect>\[2\] )
///////////////////////////////////////////////////////////////////////////////
function main()
   local aRect := { 0, 0, 0, 0 }
   local w, h, nBorder, nXPos

   set events func to App_OnEvents

   define window  Form_1 ;
      clientarea  400, 200 ;
      title       'VSplitter demo' ;
      windowtype  MAIN ;
      on release  VSplitter_Release( Form_1.Handle )

      GetClientRect( This.Handle, @aRect )
      w := RECTWIDTH ( aRect )
      h := RECTHEIGHT( aRect )

      nXPos   := Int( 0.5 * w  )
      nBorder := 4

      @ 0, 0 editbox EditBox_1 ;
         width    nXPos ;
         height   h ;
         value    LOREMIPSUM_L ;
         tooltip  'EditBox_1' ;
         nohscroll 

      @ 0, nXPos + nBorder editbox EditBox_2 ;
         width    w  - ( nXPos + nBorder );
         height   h ;
         value    LOREMIPSUM_R ;
         tooltip  'EditBox_2' ;
         nohscroll 
   end window

   // Add Vertical Splitter to Form_1   
   VSplitter_Init( Form_1.Handle, { Form_1.EditBox_1.Handle, Form_1.EditBox_2.Handle }, nXPos, nBorder )

   Form_1.Cursor := IDC_SIZEWE

   Form_1.Center()
   Form_1.Activate()

   RETURN Nil

///////////////////////////////////////////////////////////////////////////////
// FUNCTION App_OnEvents( hwnd, msg, wParam, lParam )
///////////////////////////////////////////////////////////////////////////////
#translate $_ => ( hwnd, msg, wParam, lParam )

function App_OnEvents$_
   local nRes

   switch msg
   case WM_LBUTTONDOWN
      nRes := VSplitter_OnLButtonDown$_
      exit

   case WM_LBUTTONUP
      nRes := VSplitter_OnLButtonUp$_
      exit

   case WM_MOUSEMOVE
      nRes := VSplitter_OnMouseMove$_
      exit

   case WM_SIZE        
      nRes := VSplitter_OnSize$_
      exit
   otherwise
      nRes := Events$_
   end

   return nRes
