/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Demo was contributed to HMG forum by Edward 12/Mar/2018
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

#include "hmg.ch"
#include "hmg_hpdf.ch"
#include "harupdf.ch"

FUNCTION Main()

   SELECT HPDFDOC "sample.pdf" PAPERLENGTH 300 PAPERWIDTH 300

   START HPDFDOC

   SET HPDFDOC ENCODING TO "WinAnsiEncoding"

   START HPDFPAGE

   @ 20, 10 HPDFPRINT SKEW "This is a sample Skewed Text." SIZE 22 COLOR { 255, 0, 0 } ANGLE 10 SKEW 33

   @ 40, 10 HPDFPRINT SCALE "This is a sample Scaled Text." FONT "Arial" SIZE 22 BOLD COLOR { 255, 0, 0 } XSCALE 0.5 YSCALE 2

   @ 60, 10 HPDFPRINT RENDER "This is a sample Render Stroke Text." FONT "Courier" SIZE 22 BOLD COLOR { 0, 255, 0 } STROKE RIM 0.8

   @ 80, 10 HPDFPRINT RENDER "This is a sample Render Fill Text." SIZE 22 COLOR { 0, 255, 0 } FILL RIM 0.5

   @ 100, 10 HPDFPRINT RENDER "This is a sample Render Fill Then Stroke Text." SIZE 22 COLOR { 0, 255, 0 } FILL_THEN_STROKE RIM 1

   @ 120, 10 HPDFPRINT RENDER "This is a sample Render Fill Clipping Text." SIZE 22 COLOR { 0, 255, 0 } FILL_CLIPPING RIM 0.5

   @ 140, 10 HPDFPRINT RENDER "This is a sample Render Stroke Clipping Text." SIZE 22 COLOR { 0, 255, 0 } STROKE_CLIPPING RIM 0.5

   @ 160, 10 HPDFPRINT RENDER "This is a sample Render Fill Stroke Clipping Text." SIZE 22 ITALIC COLOR { 255, 0, 0 } FILL_STROKE_CLIPPING RIM 0.5

   @ 230, 60 HPDFPRINT CIRCLED TEXT "This is a sample Circled Text." FONT "Courier" SIZE 30 BOLD COLOR { 0, 0, 255 } RADIUS 35 RIMS

   @ 230, 160 HPDFPRINT CIRCLED TEXT "This is a sample another Circled Text. " SIZE 20 BOLD COLOR { 200, 200, 200 } RADIUS 35

   @ 230, 160 HPDFPRINT CIRCLE RADIUS 28 PENWIDTH .2 COLOR {10,105,55} FILLED
   @ 230, 160 HPDFPRINT CIRCLE RADIUS 16.5 COLOR {10,10,10} FILLED
   @ 230, 160 HPDFPRINT CIRCLED TEXT "TIPSQUIRREL" FONT "Times" SIZE 20 BOLD COLOR {250,250,250} RADIUS 20 RIMS TOP
   @ 230, 160 HPDFPRINT CIRCLED TEXT "  " + Chr(72) + "               " + Chr(72) FONT "ZapfDingbats" SIZE 20 BOLD COLOR {250,250,250} RADIUS 20 BOTTOM
   @ 230, 160 HPDFPRINT CIRCLED TEXT "       PS NUTS      " SIZE 20 BOLD COLOR {250,250,250} RADIUS 20 BOTTOM

   END HPDFPAGE

   START HPDFPAGE

   @  5, 10 HPDFPRINT "Default font and size." UNDERLINE

   @ 10, 100 HPDFPRINT "This is a sample Text CENTER." CENTER
   @ 15, 200 HPDFPRINT "This is a sample Text in BOLD RIGHT." BOLD RIGHT
   @ 20, 10 HPDFPRINT "This is a sample Text in ITALIC." ITALIC

   SET HPDFDOC FONT SIZE TO 8
   SET HPDFDOC FONT NAME TO "Arial Narrow"

   @ 30, 10 HPDFPRINT "Arial Narrow 8" FONT "Helvetica" SIZE 12 UNDERLINE
   @ 35, 10 HPDFPRINT "This is a sample Text."
   @ 40, 10 HPDFPRINT "This is a sample Text in BOLD" BOLD
   @ 45, 10 HPDFPRINT "This is a sample Text in ITALIC" ITALIC

   SET HPDFDOC FONT SIZE TO 10
   SET HPDFDOC FONT NAME TO "Courier"

   @ 55, 10 HPDFPRINT "Courier 10" FONT "Helvetica" SIZE 12 UNDERLINE
   @ 60, 10 HPDFPRINT "This is a sample Text."
   @ 65, 10 HPDFPRINT "This is a sample Text."
   @ 70, 10 HPDFPRINT "This is a sample Text."

   SET HPDFDOC FONT SIZE TO 18
   SET HPDFDOC FONT NAME TO "Times-Roman"

   @ 85, 10 HPDFPRINT "Times-Roman (built-in) 18" FONT "Helvetica" SIZE 12 UNDERLINE
   @ 90, 10 HPDFPRINT "This is a sample Text BOLD ITALIC UNDERLINE STRIKEOUT" BOLD ITALIC UNDERLINE STRIKEOUT

   SET HPDFDOC FONT NAME TO "Times"

   @ 115, 10 HPDFPRINT "Times 18" FONT "Helvetica" SIZE 12 UNDERLINE
   @ 120, 10 HPDFPRINT "This is a sample Text baseline................................................................"
   @ 120, 150 HPDFPRINT "Sample Text BOLD ANGLE 90" BOLD COLOR { 255, 0, 0 } ANGLE 90
   @ 120, 150 HPDFPRINT "Sample Text ANGLE -90" COLOR { 255, 0, 0 } ANGLE - 90
   @ 120, 170 HPDFPRINT "Sample Text UNDERLINE ANGLE 90 BOTTOM" UNDERLINE COLOR { 0, 255, 0 } ANGLE 90 RIGHT
   @ 120, 190 HPDFPRINT "Sample Text ITALIC STRIKEOUT ANGLE 90 MIDDLE" ITALIC STRIKEOUT COLOR { 0, 0, 255 } ANGLE 90 CENTER

   SET HPDFDOC FONT SIZE TO 13
   SET HPDFDOC FONT NAME TO "Symbol"

   @ 135, 10 HPDFPRINT "Symbol 13" FONT "Helvetica" SIZE 12 UNDERLINE
   @ 140, 10 HPDFPRINT "This is a sample Text."

   SET HPDFDOC FONT SIZE TO 6
   SET HPDFDOC FONT NAME TO "ZapfDingbats"

   @ 150, 10 HPDFPRINT "ZapfDingbats 6" FONT "Helvetica" SIZE 12 UNDERLINE
   @ 155, 10 HPDFPRINT "This is a sample Text."

   SET HPDFDOC FONT SIZE TO 22

   @ 170, 10 HPDFPRINT "ZapfDingbats 22" FONT "Helvetica" SIZE 12 UNDERLINE
   @ 175, 10 HPDFPRINT "This is a sample Text."

   SET HPDFDOC FONT SIZE TO
   SET HPDFDOC FONT NAME TO

   @ 190, 10 HPDFPRINT "Back to Defaults"

   END HPDFPAGE

   START HPDFPAGE

   @ 10, 20  HPDFPRINT "I want Euro sign here: " + Chr( 128 )

   @ 20, 20  HPDFPRINT "I want this STRIKEOUT (not working)" STRIKEOUT

   @ 18, 67  HPDFPRINT "_________"
   @ 20, 92  HPDFPRINT "<----  This line was drawing to simulate a baseline (made manually)" SIZE 9 COLOR { 0, 0, 255 }

   @ 30, 20  HPDFPRINT "I want this italic" ITALIC
   @ 40, 20  HPDFPRINT "I want this bold" BOLD
   @ 50, 20  HPDFPRINT "I want this UNDERLINE (not working)" UNDERLINE

   @ 50, 67  HPDFPRINT "_________"
   @ 52, 92  HPDFPRINT "<----  This line was drawing to simulate a baseline (made manually)" SIZE 9 COLOR { 0, 0, 255 }

   @ 60, 20 HPDFPRINT "I have " + App.Cargo + " in Courier-Bold" FONT "Courier-Bold"

   @ 80, 10 HPDFPRINT "This is a sample Text in default font in ITALIC." ITALIC
   @ 90, 10 HPDFPRINT "This is a sample Text in default font in BOLD." BOLD

   @ 100, 10 HPDFPRINT "This is a sample Text in Helvetica font in ITALIC." FONT "Helvetica" SIZE 14 ITALIC
   @ 110, 10 HPDFPRINT "This is a sample Text in Helvetica font in BOLD and ITALIC." FONT "Helvetica" SIZE 14 BOLD ITALIC

   @ 120, 10 HPDFPRINT "This is a sample Text in Times-Roman font in ITALIC with size 8" FONT "Times-Roman" SIZE 8 ITALIC

   @ 135, 200 HPDFPRINT "This is right aligned text" SIZE 14 RIGHT

   @ 150, 105 HPDFPRINT "This is center aligned text" COLOR { 255, 0, 0 } CENTER

   @ 170, 100 HPDFPRINT "This is text in bigger font size" SIZE 30 COLOR { 255, 0, 0 }

   END HPDFPAGE

   END HPDFDOC

   EXECUTE FILE 'sample.pdf'

RETURN NIL
