/*
 * Harbour MiniGUI Accelerators Demo
 * (c) 2017 P.Ch.
*/

#include "minigui.ch"
#include "i_winuser.ch"

#include "demo.ch"

MEMVAR hMenu, hAccel

//////////////////////////////////////////////////////////////////////////////
function Main()

   SET EVENTS FUNCTION TO App_OnEvents

   DEFINE WINDOW Win_1 ;
      CLIENTAREA 400, 400 ;
      TITLE 'Accelerators Demo' ;
      MAIN ;
      ON INIT Win1_OnInit( ThisWindow.Handle ) ;
      ON RELEASE DestroyMenu( hMenu )

   END WINDOW

   Win_1.Center
   Win_1.Activate

return 0

//////////////////////////////////////////////////////////////////////////////
static procedure Win1_OnInit( hWnd )

   public hMenu  := LoadMenu( Nil, 'MainMenu' )
   public hAccel := LoadAccelerators( Nil, 'FontAccel' )

   if ! Empty( hMenu )
      SetMenu( hWnd, hMenu )
   endif

#if 0  // normal behavior
   if ! Empty( hAccel )
      SetAcceleratorTable( hWnd, hAccel )
   endif
#else  // test behavior
   TestSomeFuncs( hAccel, hWnd )
#endif

return

//////////////////////////////////////////////////////////////////////////////
function App_OnEvents( hWnd, nMsg, wParam, lParam )

   local nResult

   switch nMsg
   case WM_COMMAND
      switch LoWord( wParam )
      case IDM_REGULAR
      case IDM_BOLD
      case IDM_ITALIC
      case IDM_ULINE
         MsgInfo( "IDM_:" + hb_NtoS( LoWord( wParam ) ), ;
                  "From a " + iif( 0 == HiWord( wParam ), 'Menu', 'Accelerator' ) )
         nResult := 0
         exit   
      otherwise
         nResult := Events( hWnd, nMsg, wParam, lParam )
      end
      exit
   otherwise
      nResult := Events( hWnd, nMsg, wParam, lParam )
   end switch

return nResult

//////////////////////////////////////////////////////////////////////////////
static procedure TestSomeFuncs( hAccel, hWnd )

   local  aAccel
   local  hAccel2, pAccel := 0
   local  nLen

   nLen := CopyAcceleratorTable( hAccel, @pAccel )

   // stage 1
   if nLen > 0 .and. ! Empty( pAccel )
      hAccel2 := CreateAcceleratorTable( pAccel, nLen )

      if ! Empty( hAccel2 ) .and. Empty( pAccel )
         if DestroyAcceleratorTable( hAccel )
            hAccel := hAccel2
         endif
      endif
   endif

   // stage 2
   if ! Empty( hAccel )
      aAccel := AcceleratorTable2Array( hAccel )

      if ! Empty( aAccel )
         hAccel2 := Array2AcceleratorTable( aAccel )

         if ! Empty( hAccel2 )
            if DestroyAcceleratorTable( hAccel )
               hAccel := hAccel2
            endif
         endif
      endif
   endif

   SetAcceleratorTable( hWnd, hAccel )

   if Len( aAccel ) > 0
      ShowVirtKey( aAccel[1] )

      PostMessage( hWnd, WM_COMMAND, MAKELONG( aAccel[1][3], 1 ), 0 )
   endif

return

#define FALT        0x10
#define FCONTROL    0x08
#define FNOINVERT   0x02
#define FSHIFT      0x04
#define FVIRTKEY    1

static procedure ShowVirtKey( aAccel )

   local cAlt
   local cControl
   local cShift
   local cMsg     := ''
   local nVirtKey := aAccel[1]

   if hb_bitAnd( nVirtKey, FALT ) != 0
      cAlt := "ALT"
      cMsg := cAlt
   endif

   if hb_bitAnd( nVirtKey, FCONTROL ) != 0
      cControl := "CTRL"
      cMsg     += Iif( Empty( cMsg ), cControl, '+' + cControl )
   endif

   if hb_bitAnd( nVirtKey, FSHIFT ) != 0
      cShift := "SHIFT"
      cMsg   += Iif( Empty( cMsg ), cShift, '+' + cShift )
   endif

   if hb_bitAnd( nVirtKey, FVIRTKEY ) != 0
      cMsg += Iif( Empty( cMsg ), HMG_GetVKeyNameByCode( aAccel[2] ), '+' + hb_UChar( aAccel[2] ) ) 
   endif

   MsgInfo( "KEYSTROKE:" + cMsg + CRLF + "IDM_:" + hb_NtoS( aAccel[3]), "Simulating a keystroke" )

return

//////////////////////////////////////////////////////////////////////////////
static function HMG_GetVKeyNameByCode( nCode )

   local anKeys := {  8,  9, 13, 27, 35, 36, 37, 38, 39, 40, 45, 46, 33, 34, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, ;
      65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, ;
      89, 90, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123 }
   local acKeys := { "BACK", "TAB", "RETURN", "ESCAPE", "END", "HOME", "LEFT", "UP", "RIGHT", "DOWN", "INSERT", "DELETE", "PRIOR", "NEXT", ;
      "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", ;
      "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" }
   local n

   if ( n := AScan( anKeys, nCode ) ) > 0
      return acKeys[n]
   endif

return "Cannot found a key name"
