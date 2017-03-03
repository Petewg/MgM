/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2013 Verchenko Andrey <verchenkoag@gmail.com>
 * Helped and taught by Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include "minigui.ch"

Static cTextIsx
//////////////////////////////////////////////////////////////////////////////
// Function: Required language box for memo fields
FUNCTION FORMA_MEMO(cTitle,cField) 
   LOCAL nDesktopWidth  := GetDesktopWidth()
   LOCAL nDesktopHeight := GetDesktopHeight() - GetTaskBarHeight()
   LOCAL aBackColor := n2RGB( M->nTbrwColorPane )
   LOCAL aTextColor := n2RGB( M->nTbrwColorText )
   LOCAL cFont := M->aFontEdit[1], nFontSize := M->aFontEdit[2]
   LOCAL lFBold := M->aFontEdit[3], lFItalic := M->aFontEdit[4]
   LOCAL cText

   cText := FIELDGET(FIELDNUM(cField))  // read from the database memo field 
   cTextIsx := cText

  IF !IsWindowActive( Form_Memo )

     // ----------------------------------------------------------------
     // IniGetPosWindow () - Restore the window coordinates of the ini-file
     // IniSetPosWindow () - Save the coordinates of the window in the ini-file

      DEFINE WINDOW Form_Memo ;
              AT nDesktopHeight - 235, nDesktopWidth - 405  ;
              WIDTH  400    ;
              HEIGHT  230   ;
              TITLE "Field: " + cTitle + "       [ Ctrl+W - exit with saving ]" ;
              CHILD         ;
              FONT cFont SIZE nFontSize ;
              NOMINIMIZE NOMAXIMIZE ;
              ON INIT { || IniGetPosWindow(), ResizeFormMemo()    , ;
                           Form_Memo.Edit_Memo.FontBold := lFBold , ;
                           Form_Memo.Edit_Memo.FontItalic := lFItalic } ;
              ON SIZE { || ResizeFormMemo() } ;
              ON INTERACTIVECLOSE { || MyMemoWrite(cField), IniSetPosWindow() } 

         @ 0, 0 EDITBOX Edit_Memo             ;
              WIDTH 380 HEIGHT 190            ;
              VALUE cText                     ;
              BACKCOLOR aBackColor            ;
              FONTCOLOR aTextColor            ;
              MAXLENGTH 200          

         ON KEY CONTROL+W ACTION ThisWindow.Release    // exit on Ctrl + W

      END WINDOW
      ACTIVATE WINDOW Form_Memo 

  ELSE   
       
      If _IsWindowDefined( "Form_Memo" ) 
         If IsIconic( GetFormHandle("Form_Memo") ) 
            _Restore( GetFormHandle("Form_Memo") ) 
         Else 
            DoMethod( "Form_Memo", "SetFocus" ) 
         EndIf 
         Form_Memo.Edit_Memo.Value := cText

      EndIf 

  ENDIF  // !IsWindowActive()

  RETURN .F.

//////////////////////////////////////////////////////////////////////////////
// Function: check and write a memo field in the database
FUNCTION MyMemoWrite(cField)
   LOCAL lChangeMemo := .F.

   IF !(cTextIsx == Form_Memo.Edit_Memo.Value)
      lChangeMemo := .T.

      IF MsgYesNo( "Memo field is changed! Record changes to the database ?","Change", .f. )
        // Record lock 
        IF (M->oBrw:cAlias)->( RLock() )
           Replace &cField With Form_Memo.Edit_Memo.Value
           UnLock
        ELSE
           MsgInfo("Account is locked!")
        ENDIF
      ENDIF

   ENDIF

  RETURN NIL

//////////////////////////////////////////////////////////////////////////////
// Resize function EDITBOX 
FUNCTION ResizeFormMemo()
   LOCAL cForm := _HMG_ThisFormName
   LOCAL hWnd := GetFormHandle(cForm)

   Form_Memo.Edit_Memo.Width := GetClientWidth(hWnd)
   Form_Memo.Edit_Memo.Height := GetClientHeight(hWnd)

  RETURN NIL
