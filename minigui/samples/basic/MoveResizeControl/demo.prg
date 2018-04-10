/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2014 Dr. Claudio Soto <srvet@adinet.com.uy>
 * Based on the contribution of Marek Olszewski and B. P. Davis
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
*/

#include "hmg.ch"

FUNCTION MAIN

   LOCAL i, cLabelName

   DEFINE WINDOW Form_1;
      AT 0, 0;
      WIDTH 700;
      HEIGHT 400;
      TITLE "Move and Resize Control With Cursor";
      MAIN

   @ 300, 10 LABEL Label_0 VALUE "Put the cursor over control and press F3 (Info), F5 (Move) or F9 (Resize), while Move or Resize ESC -> Undo" AUTOSIZE

   @ 320, 10 LABEL Label_00 VALUE "Press F7 - Toggle On/Off for Move and Resize Control With Cursor" AUTOSIZE

   DEFINE button Button_1
      ROW 120
      COL 15
      WIDTH 120
      HEIGHT 30
      CAPTION "New Form"
      ACTION New_Form()
   END BUTTON


   FOR i := 1 TO 3
      cLabelName := "Label_" + hb_ntos( i, 1 )

      DEFINE LABEL &cLabelName
         PARENT Form_1
         ROW 20
         COL 120 * ( i - 1 ) + 40
         VALUE "Label no. " + Str( i, 1 )
         WIDTH 110
         HEIGHT 40
         FONTSIZE 10
         TOOLTIP "this is label no.  " + Str( i, 1 )
         ALIGNMENT CENTER
         ALIGNMENT VCENTER
         BACKCOLOR { 255, 255, 0 }
      END LABEL

   NEXT i

   ON KEY F3 ACTION OnKeyPress( VK_F3 )
   ON KEY F5 ACTION OnKeyPress( VK_F5 )
   ON KEY F7 ACTION HMG_EnableKeyControlWithCursor ( ! HMG_EnableKeyControlWithCursor() )
   ON KEY F9 ACTION OnKeyPress( VK_F9 )

   END WINDOW

   Form_1.Center ()
   Form_1.Activate ()

RETURN NIL


PROCEDURE New_Form

   LOCAL aRows

   IF IsWindowDefined ( Form_2 ) == .F.
      aRows := Array ( 9 )
      aRows[1] := { 'Simpson', 'Homer', '555-5555' }
      aRows[2] := { 'Mulder', 'Fox', '324-6432' }
      aRows[3] := { 'Smart', 'Max', '432-5892' }
      aRows[4] := { 'Grillo', 'Pepe', '894-2332' }
      aRows[5] := { 'Kirk', 'James', '346-9873' }
      aRows[6] := { 'Barriga', 'Carlos', '394-9654' }
      aRows[7] := { 'Flanders', 'Ned', '435-3211' }
      aRows[8] := { 'Smith', 'John', '123-1234' }
      aRows[9] := { 'Pedemonti', 'Flavio', '000-0000' }

      DEFINE WINDOW Form_2 ;
         AT 0, 0 ;
         WIDTH 800 ;
         HEIGHT 600 ;
         TITLE "Form 2" ;
         WINDOWTYPE STANDARD

      @ 100, 100 GRID Grid_1 ;
         WIDTH 400 ;
         HEIGHT 300 ;
         HEADERS { 'Last Name', 'First Name', 'Phone' } ;
         WIDTHS { 140, 140, 140 } ;
         ITEMS aRows ;
         VALUE 1 ;
         JUSTIFY { GRID_JTFY_LEFT, GRID_JTFY_LEFT, GRID_JTFY_RIGHT }

      ON KEY F3 ACTION OnKeyPress( VK_F3 )
      ON KEY F5 ACTION OnKeyPress( VK_F5 )
      ON KEY F9 ACTION OnKeyPress( VK_F9 )

      END WINDOW
      ACTIVATE WINDOW Form_2
   ENDIF

RETURN


// ***************************************************************
// GENERAL FUNCTIONS for Move and Resize Control With Cursor  *
// ***************************************************************


FUNCTION OnKeyPress( nVKey )

   IF HMG_EnableKeyControlWithCursor() <> .T.
      RETURN NIL
   ENDIF

   IF nVKey == VK_F3       // Info
      HMG_InfoControlWithCursor()

   ELSEIF nVKey == VK_F5   // Move
      HMG_MoveControlWithCursor()

   ELSEIF nVKey == VK_F9   // Resize
      HMG_ResizeControlWithCursor()

   ENDIF

RETURN NIL


FUNCTION HMG_EnableKeyControlWithCursor( lOnOff )

   STATIC lOn := .T.
   IF ValType ( lOnOff ) == "L"
      lOn := lOnOff
   ENDIF

RETURN lOn


PROCEDURE HMG_InfoControlWithCursor

   LOCAL hWnd, aPos
   LOCAL cFormName, cControlName

   aPos := GetCursorPos ()
   hWnd := WindowFromPoint ( { aPos[ 2 ], aPos[ 1 ] } )

   IF GetControlIndexByHandle ( hWnd ) > 0
      GetControlNameByHandle ( hWnd, @cControlName, @cFormName )
      MsgInfo ( { cFormName + "." + cControlName, hb_osNewLine(), hb_osNewLine(), ;
         "Row    : ", GetProperty ( cFormName, cControlName, "Row" ), hb_osNewLine(), ;
         "Col    : ", GetProperty ( cFormName, cControlName, "Col" ), hb_osNewLine(), ;
         "Width  : ", GetProperty ( cFormName, cControlName, "Width" ), hb_osNewLine(), ;
         "Height : ", GetProperty ( cFormName, cControlName, "Height" ) }, "Control Info" )
   ENDIF

RETURN


PROCEDURE HMG_MoveControlWithCursor

   LOCAL hWnd, aPos
   LOCAL cFormName, cControlName

   aPos := GetCursorPos ()
   hWnd := WindowFromPoint ( { aPos[ 2 ], aPos[ 1 ] } )

   IF GetControlIndexByHandle ( hWnd ) > 0
      GetControlNameByHandle ( hWnd, @cControlName, @cFormName )
      DoMethod( cFormName, cControlName, "SetFocus" )
      HMG_InterActiveMove  ( hWnd )
      aPos := ScreenToClient ( GetFormHandle( cFormName ), GetWindowCol ( hWnd ), GetWindowRow ( hWnd ) )
      SetProperty ( cFormName, cControlName, "Col", aPos[ 1 ] )
      SetProperty ( cFormName, cControlName, "Row", aPos[ 2 ] )
   ENDIF

RETURN


PROCEDURE HMG_ResizeControlWithCursor

   LOCAL hWnd, aPos
   LOCAL nWidth, nHeight
   LOCAL cFormName, cControlName

   aPos := GetCursorPos ()
   hWnd := WindowFromPoint ( { aPos[ 2 ], aPos[ 1 ] } )

   IF GetControlIndexByHandle ( hWnd ) > 0
      GetControlNameByHandle ( hWnd, @cControlName, @cFormName )
      DoMethod( cFormName, cControlName, "SetFocus" )
      HMG_InterActiveSize ( hWnd )
      nWidth   := GetWindowWidth  ( hWnd )
      nHeight  := GetWindowHeight ( hWnd )
      SetProperty ( cFormName, cControlName, "Width",  nWidth )
      SetProperty ( cFormName, cControlName, "Height", nHeight )
   ENDIF

RETURN


FUNCTION GetControlNameByHandle ( hWnd, cControlName, cFormParentName )

   LOCAL nIndexControlParent, ControlParentHandle
   LOCAL nIndexControl := GetControlIndexByHandle ( hWnd )

   cControlName := cFormParentName := ""

   IF nIndexControl > 0
      cControlName := GetControlNameByIndex ( nIndexControl )
      ControlParentHandle := GetControlParentHandleByIndex ( nIndexControl )
      IF ControlParentHandle <> 0
         nIndexControlParent := GetFormIndexByHandle ( ControlParentHandle )
         cFormParentName     := GetFormNameByIndex ( nIndexControlParent )
      ENDIF
   ENDIF

RETURN nIndexControl


FUNCTION GetControlIndexByHandle ( hWnd, nControlSubIndex1, nControlSubIndex2 )

   LOCAL i, ControlHandle, nIndex := 0

   FOR i = 1 TO Len ( _HMG_aControlHandles )
      ControlHandle := _HMG_aControlHandles[i ]
      IF HMG_CompareHandle ( hWnd, ControlHandle, @nControlSubIndex1, @nControlSubIndex2 ) == .T.
         nIndex := i
         EXIT
      ENDIF
   NEXT

RETURN nIndex


FUNCTION HMG_CompareHandle ( Handle1, Handle2, nSubIndex1, nSubIndex2 )

   LOCAL i, k

   nSubIndex1 := nSubIndex2 := 0

   IF ValType ( Handle1 ) == "N" .AND. ValType ( Handle2 ) == "N"
      IF Handle1 == Handle2
         RETURN .T.
      ENDIF

   ELSEIF ValType ( Handle1 ) == "A" .AND. ValType ( Handle2 ) == "N"
      FOR i = 1 TO Len ( Handle1 )
         IF Handle1[i ] == Handle2
            nSubIndex1 := i
            RETURN .T.
         ENDIF
      NEXT
   ELSEIF ValType ( Handle1 ) == "N" .AND. ValType ( Handle2 ) == "A"
      FOR k = 1 TO Len ( Handle2 )
         IF Handle1 == Handle2[k ]
            nSubIndex2 := k
            RETURN .T.
         ENDIF
      NEXT

   ELSEIF ValType ( Handle1 ) == "A" .AND. ValType ( Handle2 ) == "A"
      FOR i = 1 TO Len ( Handle1 )
         FOR k = 1 TO Len ( Handle2 )
            IF Handle1[i ] == Handle2[k ]
               nSubIndex1 := i
               nSubIndex2 := k
               RETURN .T.
            ENDIF
         NEXT
      NEXT
   ENDIF

RETURN .F.


#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC ( HMG_INTERACTIVEMOVE )
{
   HWND hWnd = (HWND) HB_PARNL (1);
   if (! IsWindow(hWnd) )
       hWnd = GetFocus();
   keybd_event  (VK_RIGHT, 0, 0, 0);
   keybd_event  (VK_LEFT,  0, 0, 0);
   SendMessage  (hWnd, WM_SYSCOMMAND, SC_MOVE, 0);
   RedrawWindow (hWnd, NULL, NULL, RDW_ERASE | RDW_FRAME | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW);
}

HB_FUNC ( HMG_INTERACTIVESIZE )
{
   HWND hWnd = (HWND) HB_PARNL (1);
   if (! IsWindow(hWnd) )
       hWnd = GetFocus();
   keybd_event  (VK_DOWN,  0, 0, 0);
   keybd_event  (VK_RIGHT, 0, 0, 0);
   SendMessage  (hWnd, WM_SYSCOMMAND, SC_SIZE, 0);
   RedrawWindow (hWnd, NULL, NULL, RDW_ERASE | RDW_FRAME | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW);
}

#pragma ENDDUMP
