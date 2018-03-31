/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * ImageButtons Demo
 * (C) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
 * HMG 1.0 Experimental Build 8e
*/

#include "minigui.ch"

Function Main()

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 410 ;
      HEIGHT 180 ;
      MAIN;
      ICON "aMAIN";
      TITLE 'ImageButtons Demo by Jacek Kubica <kubica@wssk.wroc.pl>'

      DEFINE MAIN MENU
              POPUP 'Standard'
                ITEM 'Disable button1' ACTION {||  (Form_1.Button_1.Enabled := .f.)}
                ITEM 'Enable button1'  ACTION  {|| (Form_1.Button_1.Enabled := .t.)}
                ITEM 'Disable button2' ACTION {||  (Form_1.Button_2.Enabled := .f.)}
                ITEM 'Enable button2'  ACTION  {|| (Form_1.Button_2.Enabled := .t.)}
                ITEM 'Disable button3' ACTION {||  (Form_1.Button_3.Enabled := .f.)}
                ITEM 'Enable button3'  ACTION  {|| (Form_1.Button_3.Enabled := .t.)}
                ITEM 'Disable button4' ACTION {||  (Form_1.Button_4.Enabled := .f.)}
                ITEM 'Enable button4'  ACTION  {|| (Form_1.Button_4.Enabled := .t.)}
                SEPARATOR
                ITEM 'Set new picture for button4' ACTION {|| (Form_1.Button_4.Picture := 'clear')}
                SEPARATOR
                ITEM 'Get picture for button4' ACTION MsgInfo(Form_1.Button_4.Picture)
              END POPUP

              POPUP 'Icons'
                ITEM 'Disable button1i' ACTION {||  (Form_1.Button_1i.Enabled := .f.)}
                ITEM 'Enable button1i'  ACTION  {|| (Form_1.Button_1i.Enabled := .t.)}
                ITEM 'Disable button2i' ACTION {||  (Form_1.Button_2i.Enabled := .f.)}
                ITEM 'Enable button2i'  ACTION  {|| (Form_1.Button_2i.Enabled := .t.)}
                ITEM 'Disable button3i' ACTION {||  (Form_1.Button_3i.Enabled := .f.)}
                ITEM 'Enable button3i'  ACTION  {|| (Form_1.Button_3i.Enabled := .t.)}
                ITEM 'Disable button4i' ACTION {||  (Form_1.Button_4i.Enabled := .f.)}
                ITEM 'Enable button4i'  ACTION  {|| (Form_1.Button_4i.Enabled := .t.)}
                SEPARATOR
                ITEM 'Set new icon for button4i' ACTION {|| (Form_1.Button_4i.Icon := 'system.ico')}
                SEPARATOR
                ITEM 'Get icon for button4i' ACTION MsgInfo(Form_1.Button_4i.Icon)
              END POPUP

              POPUP 'Masked bitmap'
                ITEM 'Disable button1e' ACTION {||  (Form_1.Button_1e.Enabled := .f.)}
                ITEM 'Enable button1e'  ACTION  {||  (Form_1.Button_1e.Enabled := .t.)}
                ITEM 'Disable button2e' ACTION {||  (Form_1.Button_2e.Enabled := .f.)}
                ITEM 'Enable button2e'  ACTION  {|| (Form_1.Button_2e.Enabled := .t.)}
                ITEM 'Disable button3e' ACTION {||  (Form_1.Button_3e.Enabled := .f.)}
                ITEM 'Enable button3e'  ACTION  {|| (Form_1.Button_3e.Enabled := .t.)}
                ITEM 'Disable button4e' ACTION {||  (Form_1.Button_4e.Enabled := .f.)}
                ITEM 'Enable button4e'  ACTION  {|| (Form_1.Button_4e.Enabled := .t.)}
                SEPARATOR
                ITEM 'Set new picture for button4e' ACTION {|| (Form_1.Button_4e.Picture := {'clear','cleard'})}
                SEPARATOR
                ITEM 'Get picture for button4e' ACTION MsgInfo(Form_1.Button_4e.Picture)
              END POPUP
      END MENU

           @ 0,205 Label Label1 Value "1" AUTOSIZE
           @ 0,205+28 Label Label2 Value "2" AUTOSIZE
           @ 0,205+2*28 Label Label3 Value "3" AUTOSIZE
           @ 0,205+3*28 Label Label4 Value "4" AUTOSIZE

         // standard
                @ 20,80 Label Label_2 Value "Bitmaps (*.bmp) " AUTOSIZE
                @ 20,195      BUTTON Button_1 PICTURE "strzal" WIDTH 24 HEIGHT 20 ACTION TONE(600)
                @ 20,195+28   BUTTON Button_2 PICTURE "close"  WIDTH 24 HEIGHT 20 ACTION TONE(600)
                @ 20,195+2*28 BUTTON Button_3 PICTURE "clear"  WIDTH 24 HEIGHT 20 ACTION TONE(600)
                @ 20,195+3*28 BUTTON Button_4 PICTURE "bold"   WIDTH 24 HEIGHT 20 ACTION TONE(600)

                DEFINE BUTTON ImageButton_1
                  ROW   20
                  COL   195+4*28
                  PICTURE 'strzal'
                  ACTION MsgInfo('Arrow Click!')
                  WIDTH 24
                  HEIGHT 20
                  TOOLTIP 'Alt Syntax Demo - BITMAP'
                END BUTTON

        // icons
                @ 60,80 Label Label_3 Value "Icons (*.ico)" AUTOSIZE
                @ 60,195      BUTTON Button_1i ICON "arrow.ico" WIDTH 24 HEIGHT 20 ACTION TONE(600) TOOLTIP "Image button with icon from file arrow.ico" // from file
                @ 60,195+28   BUTTON Button_2i ICON "close.ico"  WIDTH 24 HEIGHT 20 ACTION TONE(600)  TOOLTIP "Image button with icon from file close.ico"// from file
                @ 60,195+2*28 BUTTON Button_3i ICON "clearico" WIDTH 24 HEIGHT 20 ACTION TONE(600)  TOOLTIP "Image button with icon defined in *.rc file"     // from rc
                @ 60,195+3*28 BUTTON Button_4i ICON "boldico"  WIDTH 24 HEIGHT 20 ACTION TONE(600)  TOOLTIP "Image button with icon defined in *.rc file"    // from rc

                DEFINE BUTTON ImageButton_2
                  ROW   60
                  COL   195+4*28
                  ICON 'arrow.ico'
                  ACTION MsgInfo('Arrow Click!')
                  WIDTH 24
                  HEIGHT 20
                  TOOLTIP 'Alt Syntax Demo - ICON'
                END BUTTON

        // masked bitmaps
                @ 100,80 Label    Label_1 Value "Masked bitmaps  " AUTOSIZE
                @ 100,195      BUTTON Button_1e PICTURE {"strzal","strzald"} WIDTH 24 HEIGHT 20 ACTION TONE(600)
                @ 100,195+28   BUTTON Button_2e PICTURE {"close","closed"}  WIDTH 24 HEIGHT 20 ACTION TONE(600)
                @ 100,195+2*28 BUTTON Button_3e PICTURE {"clear","cleard"}  WIDTH 24 HEIGHT 20 ACTION TONE(600)
                @ 100,195+3*28 BUTTON Button_4e PICTURE {"bold","boldd"}  WIDTH 24 HEIGHT 20 ACTION TONE(600)

                DEFINE BUTTON ImageButton_3
                  ROW   100
                  COL   195+4*28
                  PICTURE {'strzal','strzald'}
                  ACTION MsgInfo('Arrow Click!')
                  WIDTH 24
                  HEIGHT 20
                  TOOLTIP 'Alt Syntax Demo - Masked Bitmap'
                END BUTTON
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil
