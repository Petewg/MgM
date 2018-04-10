*******************************************************************************
* PROGRAMA: Demo ON PAINT event
* LENGUAJE: HMG
* FECHA:    Setiembre 2012
* AUTOR:    Dr. CLAUDIO SOTO
* PAIS:     URUGUAY
* E-MAIL:   srvet@adinet.com.uy
* BLOG:     http://srvet.blogspot.com
*******************************************************************************


#include "hmg.ch"


FUNCTION MAIN

    DEFINE WINDOW Win1;
        AT 0,0;
        WIDTH  800;
        HEIGHT 600;
        TITLE  "Demo7: Draw Functions";
        MAIN;
        ON PAINT Proc_ON_PAINT ();
        ON SIZE      {|| BT_ClientAreaInvalidateAll ("Win1"), Proc_LABEL() };
        ON MAXIMIZE  {|| BT_ClientAreaInvalidateAll ("Win1"), Proc_LABEL() }


        DEFINE MAIN MENU
            DEFINE POPUP "File"
                MENUITEM "Exit" ACTION Win1.Release
            END POPUP
        END MENU


        DEFINE STATUSBAR
            DATE
            CLOCK
        END STATUSBAR


        @   30, 300 LABEL  Label_1  VALUE " " AUTOSIZE 
        @   80, 300 LABEL  Label_2  VALUE " " AUTOSIZE TRANSPARENT FONTCOLOR BLACK 

        @  435, 410 BUTTON Button_1 CAPTION "Maximize" ACTION Win1.Maximize
        @  435, 280 BUTTON Button_2 CAPTION "Click"    ACTION MsgInfo ("Hello")

   END WINDOW

Proc_LABEL ()
   
   CENTER WINDOW Win1
   ACTIVATE WINDOW Win1

RETURN NIL


PROCEDURE Proc_LABEL
   LOCAL Width  := BT_ClientAreaWidth  ("Win1")
   LOCAL Height := BT_ClientAreaHeight ("Win1") 
   Win1.Label_1.Value := "Client Area WIDTH "+str(Width)
   Win1.Label_2.Value := "Client Area HEIGHT"+str(Height)
RETURN


PROCEDURE Proc_ON_PAINT    
LOCAL Width  := BT_ClientAreaWidth  ("Win1")
LOCAL Height := BT_ClientAreaHeight ("Win1") - BT_StatusBarHeight ("Win1")
LOCAL hDC, BTstruct
LOCAL cText
LOCAL nTypeText
LOCAL nAlingText

   hDC = BT_CreateDC ("Win1", BT_HDC_INVALIDCLIENTAREA, @BTstruct)

         BT_DrawGradientFillVertical (hDC, 0, 0, Width, Height, {100,0,33}, BLACK)

         BT_DrawLine (hDC, 0, 0, Height, Width, ORANGE, 5)
         BT_DrawLine (hDC, Height, 0, 0, Width, ORANGE, 5)

         BT_DrawLine (hDC, 0, Width/2, Height, Width/2, ORANGE, 5)
         BT_DrawLine (hDC, Height/2, 0, Height/2, Width, ORANGE, 5)

         BT_DrawEllipse (hDC, 140, 200, 400, 230, WHITE, 5)

         BT_DrawFillRectangle (hDC,  20, 250, 300, 100, ORANGE, RED, 3)
         BT_DrawFillRoundRect (hDC, 400, 250, 300, 100, 10, 10, ORANGE, RED, 3)
         BT_DrawFillEllipse   (hDC, 180, 250, 300, 160, BLACK, BROWN, 2)

         cText := "ABC ¡…Õ”⁄‹ ·ÈÌÛ˙¸ abcgjq"
         nTypeText  := BT_TEXT_OPAQUE + BT_TEXT_BOLD + BT_TEXT_UNDERLINE + BT_TEXT_ITALIC
         nAlingText := BT_TEXT_LEFT + BT_TEXT_TOP
         BT_DrawText (hDC, 230, 110, cText, "Comic Sans MS", 32, RED, {228,228,228}, nTypeText, nAlingText)

         BT_DrawRectangle (hDC, 220, 90, 610, 80, YELLOW, 1)

   BT_DeleteDC (BTstruct)
RETURN
