#define WM_NOTIFY 78
#define LVN_KEYDOWN ( - 155 )

//------------------------------------------------------------------------------
FUNCTION MyEvents( hWnd, nMsg, wParam, lParam )
//------------------------------------------------------------------------------
   LOCAL i, nVirtKey, cKey, Result := 0
   LOCAL cFormName := "", cControlName := ""

   if nMsg = WM_NOTIFY
      if GetNotifyCode( lParam ) = LVN_KEYDOWN

         nVirtKey := GetGridvKey( lParam )
         cKey := KeyToChar( nVirtKey )

         i := Ascan( _HMG_aFormHandles , hWnd )
         cFormName := if( i > 0, _HMG_aFormNames[ i ], "" )
         i := Ascan( _HMG_aControlHandles, GetHwndFrom( lParam ) )
         cControlName := if( i > 0, _HMG_aControlNames[ i ], "" )

         if cFormName == "Form_1" .and. cControlName == "Browse_1"
            Result := Form1Event1( i, nVirtKey, cKey )
         elseif cFormName == "Form_1" .and. cControlName == "Grid_1"
            Result := Form1Event2( i, nVirtKey, cKey )
         elseif cFormName == "Form2" .and. cControlName == "Browse_1"
            //
         elseif cFormName == "winPreparChild" .and. cControlName == "Browse_1"
            //
         elseif cFormName == "winUsersRights" .and. cControlName == "Grid_1"
            //
         else
            Result := Events( hWnd, nMsg, wParam, lParam )
         endif

      else
         Result := Events( hWnd, nMsg, wParam, lParam )
      endif
   else
      Result := Events( hWnd, nMsg, wParam, lParam )
   endif

RETURN Result

//------------------------------------------------------------------------------
Static Function KeyToChar( nVirtKey )
//------------------------------------------------------------------------------
   LOCAL i, cRetChar := ""
   LOCAL nKeyboardMode := GetKeyboardMode()
   LOCAL lShift := CheckBit( GetKeyState( 16 ), 32768 )
   LOCAL aKeysNumPad := { 96,97,98,99,100,101,102,103,104,105,106,107,109,110,111 }
   LOCAL cKeysNumPad := "0123456789*+-./"
   LOCAL aKeys1 := { 192,189,187,219,221,220,186,222,188,190,191 }
   LOCAL cKeys1US := "`-=[]\;',./"
   LOCAL cKeys1ShiftUS := '~_+{}|:"<>?'
   LOCAL cKeys1RU := "¨-=ÕÚ\ÆÝÁÞ."
   LOCAL cKeys1ShiftRU := "¨_+ÕÚ/ÆÝÁÞ,"
   LOCAL cKeys2US := "1234567890QWERTYUIOPASDFGHJKLZXCVBNM "
   LOCAL cKeys2ShiftUS := "!@#$%^&*()QWERTYUIOPASDFGHJKLZXCVBNM "
   LOCAL cKeys2RU := "1234567890ÉÖÓÊÅÍÃØÙÇÔÛÂÀÏÐÎËÄß×ÑÌÈÒÜ "
   LOCAL cKeys2ShiftRU := '!"¹;%:?*()ÉÖÓÊÅÍÃØÙÇÔÛÂÀÏÐÎËÄß×ÑÌÈÒÜ '

   i := ascan( aKeysNumPad, nVirtKey )
   if i > 0
      RETURN substr( cKeysNumPad, i, 1 )
   endif

   i := ascan( aKeys1, nVirtKey )
   if i > 0
      if nKeyboardMode == 1033 // US
         if lShift
            cRetChar := substr( cKeys1ShiftUS, i, 1 )
         else
            cRetChar := substr( cKeys1US, i, 1 )
         endif
      elseif nKeyboardMode == 1049 // RU
         if lShift
            cRetChar := substr( cKeys1ShiftRU, i, 1 )
         else
            cRetChar := substr( cKeys1RU, i, 1 )
         endif
      endif
      RETURN cRetChar
   endif

   i := at( chr( nVirtKey ), cKeys2US )
   if i > 0
      if nKeyboardMode == 1033 // US
         if lShift
            cRetChar := substr( cKeys2ShiftUS, i, 1 )
         else
            cRetChar := substr( cKeys2US, i, 1 )
         endif
      elseif nKeyboardMode == 1049 // RU
         if lShift
            cRetChar := substr( cKeys2ShiftRU, i, 1 )
         else
            cRetChar := substr( cKeys2RU, i, 1 )
         endif
      endif
   endif

   RETURN cRetChar

//------------------------------------------------------------------------------
#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( GETKEYBOARDMODE )
{
   HKL kbl;
   HWND CurApp;
   DWORD idthd;
   int newmode;

   CurApp=GetForegroundWindow();
   idthd=GetWindowThreadProcessId(CurApp,NULL);

   kbl=GetKeyboardLayout(idthd);
   newmode=(int)LOWORD(kbl);

   hb_retnl(newmode);
}

#pragma ENDDUMP
//------------------------------------------------------------------------------