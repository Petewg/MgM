/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2017 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2017 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Пример работы с объектами на форме / команды псевдо ООП 
 * Передача параметров через Cargo переменные / "стиль программирования" MiniGui
 * An example of working with objects on a form / command pseudo OOP 
 * Passing parameters via Cargo variables / "programming style" MiniGui
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

Function MAIN
   Local aBackColor, aMenu, aIcon, aImg, nMaxWidth, nMaxHeight
   Local cObj, cImg1, cImg2, aDim2, aDim3, nFontSize := 16
   Local cForm := 'Form_1', nPos, aSets := { 1, 1, 1 }
   Local cFileSets := 'demo.cfg'

   aMenu := {"Menu-1" , "Menu-2" , "Menu-3"    }
   aIcon := {"m_One32", "m_Two32", "m_Three32" }
   aImg  := {"f_one64", "f_two64", "f_three64" }

   aDim2 := {"Checking the label menu and settings 1" , "Checking the label menu and settings 2" , "Checking the label menu and settings 3"    }
   aDim3 := {"Checking the button menu and settings 1" , "Checking the button menu and settings 2" , "Checking the button menu and settings 3" }

   cImg1 := "gear64x1" ;  cImg2 := "gear64x2"

   If file(cFileSets)
      cObj := hb_memoread(cFileSets)
      If ! empty(cObj)
         aSets := &cObj
      EndIf
   EndIf

   DEFINE WINDOW &cForm ;
      AT 0,0 WIDTH 600 HEIGHT 350                            ;
      TITLE "Test: context menu/pictures/Cargo"              ;
      MAIN                                                   ;
      ICON "1MAIN_ICO"                                       ;
      ON RELEASE hb_memowrit(cFileSets, hb_valtoexp(This.Cargo)) ;
      BACKCOLOR  SILVER
       
      This.Cargo := aSets                // set modes for the menu
      nMaxWidth  := This.ClientWidth    
      nMaxHeight := This.ClientHeight 
      aBackColor := This.BackColor

      @ 10, 10 LABEL Label_1 VALUE MiniGUIVersion() WIDTH This.Width-20 HEIGHT 42 ;
         TRANSPARENT FONTCOLOR BLACK SIZE 12 BOLD CENTERALIGN
      @ 35, 10 LABEL Label_2 VALUE hb_compiler() WIDTH This.Width-20 HEIGHT 42 ;
         TRANSPARENT FONTCOLOR BLACK SIZE 12 BOLD CENTERALIGN
      @ 60, 10 LABEL Label_3 VALUE Version() WIDTH This.Width-20 HEIGHT 42 ;
         TRANSPARENT FONTCOLOR BLACK SIZE 12 BOLD CENTERALIGN

      // displaying pictures via the function for changing several pictures
      cObj := 'Image_1'
      nPos := This.Cargo[1]

      @ 20, 20 IMAGE &cObj PICTURE aImg[ nPos ] WIDTH 64 HEIGHT 64 ;
         BACKGROUNDCOLOR aBackColor STRETCH TRANSPARENT            ;
         OnMouseHover RC_CURSOR( "MINIGUI_FINGER" )                ;
         ACTION       {|pos| pos := MyShowCntMenu(),               ;
                           ThisWindow.Cargo[1] := pos,             ;
                           ChangeImagePicture() } 
        This.&(cObj).Cargo := { nPos, aMenu, aIcon, aImg } // parameter passing through Cargo

      @ 20, nMaxWidth-64-20 IMAGE Image_2 PICTURE cImg1 WIDTH 64 HEIGHT 64   ;
        BACKGROUNDCOLOR aBackColor STRETCH TRANSPARENT                       ;
        OnMouseHover ( This.Picture := cImg2 , RC_CURSOR("MINIGUI_FINGER") ) ;
        OnMouseLeave   This.Picture := cImg1                                 ;
        ACTION   ( MsgDebug(ThisWindow.Name, This.Name, This.Type, ThisWindow.Cargo ), ;
                   SetFocus(This.Label_1.Handle) )

        nPos := This.Cargo[2]
      @ 100, 110 LABEL Label_1Get VALUE aDim2[nPos] WIDTH 400 HEIGHT nFontSize*2 ;
        FONTCOLOR BLACK BACKCOLOR WHITE SIZE nFontSize CENTERALIGN VCENTERALIGN BORDER ;
        OnMouseHover ( RC_CURSOR( "MINIGUI_FINGER" ), ColorBackFontInvert({WHITE,BLACK}) ) ;
        OnMouseLeave   ColorBackFontInvert({BLACK,WHITE})    ;
        ACTION       {|pos| pos := MyShowCntMenu() ,         ; 
                       This.Value := This.Cargo[2][pos],     ;
                       ThisWindow.Cargo[2] := pos }
        This.Label_1Get.Cargo := { nPos, aDim2, aIcon, aImg } // parameter passing through Cargo

        nPos := This.Cargo[3]
      @ 140, 110 BUTTONEX Button_S1 WIDTH 400 HEIGHT nFontSize*2  ;
         CAPTION aDim3[nPos] SIZE nFontSize                       ;
         FONTCOLOR BLACK BACKCOLOR YELLOW                         ;
         NOHOTLIGHT NOXPSTYLE HANDCURSOR NOTABSTOP                ;
         On MouseHover  ColorBackFontInvert({YELLOW,BLACK})       ;
         On MouseLeave  ColorBackFontInvert({BLACK,YELLOW})       ;
         ACTION        {|pos| pos := MyShowCntMenu(),             ;
                         This.Caption := This.Cargo[2][pos],      ; 
                         ThisWindow.Cargo[3] := pos,              ;
                         SetFocus(This.Label_1.Handle) }
        This.Button_S1.Cargo := { nPos, aDim3, aIcon, aImg } // parameter passing through Cargo

       This.Sizable   := .F.  // NOSIZE
       This.MinButton := .F.  // NOMINIMIZE
       This.MaxButton := .F.  // NOMAXIMIZE
       This.Center

   END WINDOW

   ACTIVATE WINDOW &cForm

   Return Nil

////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION ChangeImagePicture() 
   LOCAL cForm := ThisWindow.Name
   LOCAL cObj  := This.Name
   LOCAL nPos  := This.Cargo[1]
   LOCAL aMenu := This.Cargo[2]
   LOCAL aIcon := This.Cargo[3]
   LOCAL aImg  := This.Cargo[4]

   SetProperty( cForm, cObj, "Picture", aImg[nPos] )
   This.Cargo := { nPos, aMenu, aIcon, aImg }
  
   RETURN Nil 

////////////////////////////////////////////////////////////////////////////////
FUNCTION ColorBackFontInvert(aColor)
   LOCAL cForm   := ThisWindow.Name
   LOCAL cObj    := This.Name
   LOCAL cType   := This.Type
   LOCAL aBColor := This.BackColor
   LOCAL aFColor := This.FontColor
   DEFAULT aColor := {}

   IF Empty(aColor)
      This.FontColor := aBColor
      This.BackColor := aFColor
   ELSE
      This.FontColor := aColor[1]
      This.BackColor := aColor[2]
   ENDIF

   Return {aFColor,aBColor}

////////////////////////////////////////////////////////////////////////////////
FUNCTION MyShowCntMenu()   
   LOCAL cForm  := ThisWindow.Name
   LOCAL nY     := ThisWindow.Row
   LOCAL nX     := ThisWindow.Col
   LOCAL cObj   := This.Name
   LOCAL aCargo := This.Cargo
   LOCAL nMenuItem := aCargo[1]
   LOCAL aMenuItem := aCargo[2]
   LOCAL aMenuIco  := aCargo[3]
   LOCAL cFont  := "Comic Sans MS", nFontSize := 16
   LOCAL nI, hFont, Font1, Font2, cIco
   LOCAL cMenu, cImg, cName, bAction, lChk, lDis
   PRIVATE nMsg      
   m->nMsg := 0

   nY += This.Row + This.Height + GetBorderHeight() + GetTitleHeight() - 5
   nX += This.Col + GetBorderWidth() - 5         
   
   hFont := GetFontHandle( "Font_CMZ1" )  
   IF hFont == 0
      DEFINE FONT Font_CMZ1  FONTNAME "Comic Sans MS" SIZE 16 BOLD
   ENDIF
   hFont := GetFontHandle( "Font_CMZ2" ) 
   IF hFont == 0
      DEFINE FONT Font_CMZ2  FONTNAME "Times New Roman" SIZE 16
   ENDIF

   Font1 := GetFontHandle( "Font_CMZ1" )
   Font2 := GetFontHandle( "Font_CMZ2" )

   SET MENUSTYLE EXTENDED     // switch the menu style to advanced
   SetMenuBitmapHeight( 32 )  // set icon size 32x32

   DEFINE CONTEXT MENU OF &cForm
       FOR nI := 1 TO LEN(aMenuItem)
          cMenu   := aMenuItem[nI]
          cName   := StrZero(nI, 3) 
          bAction := hb_macroBlock( 'm->nMsg := ' + cName  )
          cImg    := '' 
          lChk    := .F.                                
          lDis    := .F.
          _DefineMenuItem( cMenu, bAction, cName, cImg, lChk, lDis, , Font1 , , .F., .F. )
          // Change by name (NAME) of the BMP menu to icon resources
          cIco := aMenuIco[nI]
          _SetMenuItemIcon( cName, cForm, cIco )
       NEXT
       SEPARATOR                             
       MENUITEM  "Exit"  ACTION m->nMsg := 0 FONT Font2 IMAGE "" NAME MyMenuItemExit
   END MENU

   // Change by name (NAME) of the BMP menu to icon resources
   _SetMenuItemIcon( "MyMenuItemExit" , cForm , "m_Exit32" )
   
   _ShowContextMenu(cForm, nY, nX) // DISPLAYING THE MENU     
   InkeyGui()

   DEFINE CONTEXT MENU OF &cForm  // deleting menu after exiting 
   END MENU

   SET MENUSTYLE STANDARD  // MANDATORY! Return to the standard menu style!
   
   RELEASE FONT Font_CMZ1 // remove fonts 
   RELEASE FONT Font_CMZ2

   IF m->nMsg > 0
      nMenuItem := m->nMsg  // return the changed menu value
   ENDIF

   This.Cargo[1] := nMenuItem   // remember the set value in Cargo variable

RETURN nMenuItem

///////////////////////////////////////////////////////////////////////////
FUNCTION _ShowContextMenu(ParentFormName, nRow, nCol, lCentered)
   LOCAL xContextMenuParentHandle := 0
   LOCAL aRow := GetCursorPos()
   DEFAULT lCentered := ( nRow == NIL .and. nCol == NIL )
   DEFAULT nRow := 0, nCol := 0, ParentFormName := ""

   If .Not. _IsWindowDefined (ParentFormName)
      xContextMenuParentHandle := _HMG_xContextMenuParentHandle
   else
      xContextMenuParentHandle := GetFormHandle ( ParentFormName )
   Endif
   if xContextMenuParentHandle == 0
      MsgMiniGuiError("Context Menu is not defined. Program terminated")
   endif
   IF lCentered
      //nCol := GetWindowCol(xContextMenuParentHandle) + GetWindowWidth(xContextMenuParentHandle)/2 - 60
      //nRow := GetWindowRow(xContextMenuParentHandle) + GetWindowHeight(xContextMenuParentHandle)/2 - GetTitleHeight() - 5
   ELSEIF nRow == 0 .and. nCol == 0
      nCol := aRow[2]
      nRow := aRow[1]
   ENDIF

   TrackPopupMenu ( _HMG_xContextMenuHandle , nCol , nRow , xContextMenuParentHandle )

RETURN Nil
