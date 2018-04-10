/*
 * Copyright 2008 Pritpal Bedi <pritpal@vouchcac.com>
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option )
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.   If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/ ).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.   To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

*------------------------------------------------------------------------*
*------------------------------------------------------------------------*
*------------------------------------------------------------------------*
//
//                              HaruPdf.prg
//
//                  Pritpal Bedi <pritpal@vouchcac.com>
//
*------------------------------------------------------------------------*
*------------------------------------------------------------------------*
*------------------------------------------------------------------------*
//
//                  Minigui Adaption by Pierpaolo Martinello
//                          <pier.martinello[at]alice.it>
//

ANNOUNCE RDDSYS

#require "hbzebra"
#require "hbhpdf"

#include "hbzebra.ch"

#include 'harupdf.ch'
#include "minigui.ch"


#ifdef __XHARBOUR__
#define hb_NumToHex NUMTOHEX
#endif

#define rLEFT   1
#define rTOP    2
#define rRIGHT  3
#define rBOTTOM 4

Memvar MyPdf, cpos
*------------------------------------------------------------------------*
Function Main( cFileToSave )
*------------------------------------------------------------------------*
   default( cFileToSave ) to 'TestHaru.pdf'
   Public MyPdf:= cFileToSave
   SET AUTOADJUST ON

   Load window MH
        mh.check_17.enabled := .F.
        mh.center
        mh.activate

Return Nil

*------------------------------------------------------------------------*
Function Generate( cFileToSave )
*------------------------------------------------------------------------*
   If file(cFileToSave)
      Ferase(cFileToSave)
   Endif
   if DesignHaruPDF( cFileToSave )
      MsgInfo( 'PDF File <'+cFileToSave+'> is Created!' )
   else
      MsgAlert( 'Some problems in creating the PDF!', 'Error' )
   endif

   Return nil
*------------------------------------------------------------------------*
Function View( cFileToSave )
*------------------------------------------------------------------------*
   if file(cFileToSave)
      execute file cFileToSave
   Else
      msgalert ("Press generate first!", 'Alert')
   Endif
return nil
*------------------------------------------------------------------------*
Function DesignHaruPDF( cFileToSave )
*------------------------------------------------------------------------*
   Local i, page, height, width, def_font, tw,  samp_text, font, grid := .f.
   Local page_title := 'Minigui Extended Pdf Generator Demo'
   Local font_list  := { ;
                        "Courier",                  ;
                        "Courier-Bold",             ;
                        "Courier-Oblique",          ;
                        "Courier-BoldOblique",      ;
                        "Helvetica",                ;
                        "Helvetica-Bold",           ;
                        "Helvetica-Oblique",        ;
                        "Helvetica-BoldOblique",    ;
                        "Times-Roman",              ;
                        "Times-Bold",               ;
                        "Times-Italic",             ;
                        "Times-BoldItalic",         ;
                        "Symbol",                   ;
                        "ZapfDingbats"              ;
                      }

   Local pdf := HPDF_New()
   Public cpos :={}
   if pdf == NIL
      msgalert( 'Pdf could not been created!', 'Error' )
      return nil
   endif

   If file ( cFileToSave )
      Ferase( cFileToSave )
   Endif

   /* set compression mode */

   HPDF_SetCompressionMode( pdf, HPDF_COMP_ALL )

   
   // Passwords and Permissions
   //
   if Mh.Check_1.value
      HPDF_SetPassword(pdf, 'owner','user' )
   Endif
   
   if Mh.Check_2.value
      HPDF_SetPermission(pdf, HPDF_ENABLE_READ)  // cannot print
   Endif

   if Mh.Check_3.value
      HPDF_SetEncryptionMode(pdf, HPDF_ENCRYPT_R3, 16)
   Endif

   page := HPDF_AddPage(pdf)
   aadd(cpos ,page)
   HPDF_Page_SetSize(HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )
   height := HPDF_Page_GetHeight(page)
   width  := HPDF_Page_GetWidth(page)


   /* Print the lines of the page. */

   HPDF_Page_SetLineWidth( page, 1 )
   HPDF_Page_Rectangle( page, 50, 50, width - 100, height - 110 )
   HPDF_Page_Stroke( page )

   /* Print the title of the page(with positioning center). */

   def_font = HPDF_GetFont( pdf, "Helvetica", NIL )

   HPDF_Page_SetFontAndSize( page, def_font, 24 )
   tw := HPDF_Page_TextWidth( page, page_title )
   HPDF_Page_BeginText( page )
   HPDF_Page_TextOut( page, (width - tw) / 2, height - 50, page_title )
   HPDF_Page_EndText( page )

   /* output subtitle. */

   HPDF_Page_BeginText( page )
   HPDF_Page_SetFontAndSize( page, def_font, 16 )
   HPDF_Page_TextOut( page, 60, height - 80, "<Standard Type1 fonts samples>")
   HPDF_Page_EndText( page )

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 60, height - 105 )

   for i := 1 to len( font_list )
      samp_text := "abcdefgABCDEFG12345!#$%&+-@?"
      font := HPDF_GetFont( pdf, font_list[ i ], NIL )

      HPDF_Page_SetFontAndSize( page, def_font, 9 )
      HPDF_Page_ShowText( page, font_list[ i ] )
      HPDF_Page_MoveTextPos( page, 0, -18 )

      HPDF_Page_SetFontAndSize( page, font, 20 )
      HPDF_Page_ShowText( page, samp_text )
      HPDF_Page_MoveTextPos( page, 0, -20 )
   next

   HPDF_Page_EndText( page )

   if Mh.Check_4.value
      Print_jpg( pdf )
   Endif
   if Mh.Check_5.value
      Page_Lines( pdf )
   Endif
   If Mh.Check_6.value
      Page_Text( pdf , Mh.Check_7.value )
   Endif
   If Mh.Check_8.value
      Page_TextScaling( pdf ,Mh.Check_9.value )
   EndIf
   if Mh.Check_10.value
      Page_Graphics( pdf , Mh.Check_11.value )
   Endif
   if Mh.Check_12.value
      Page_Annotation( pdf )
   Endif
   if Mh.Check_13.value
      Page_Images( pdf )
   Endif
   // Commentout the following line if you need ASCII chart by Codepages
   if Mh.Check_13.value
      Page_CodePages( pdf )
   Endif
   if Mh.Check_14.value
      Page_Link_Annotation( pdf )
   Endif
   //PrintText(atail(cpos) )
   if Mh.Check_15.value
      Print_TTFont ( pdf , "Files\PenguinAttack.ttf" , if (mh.RadioGroup_1.value=1,"-E",'') ) // Embedded
   Endif
   if Mh.Check_16.value
      Page_Slide ( pdf )
   Endif

   if Mh.Check_18.value
      Page_Zebra ( pdf )
   Endif

   HPDF_SaveToFile( pdf, cFileToSave )
   * msgbox(HPDF_GETERROR(),"Errore")
   HPDF_Free( pdf )
   release cpos
   return file( cFileToSave )

*------------------------------------------------------------------------*
Static Function Page_Lines( pdf )
*------------------------------------------------------------------------*
   Local page_title := "Line Example"
   Local font, page

   Local DASH_MODE1 := {3}
   Local DASH_MODE2 := {3, 7}
   Local DASH_MODE3 := {8, 7, 2, 7}

   Local x, y, x1, y1, x2, y2, x3, y3, tw

   /* create default-font */
   font := HPDF_GetFont( pdf, "Helvetica", NIL )

   /* add a new page object. */
   page := HPDF_AddPage(pdf)
   aadd(cpos ,page)

   /* print the lines of the page. */
   HPDF_Page_SetLineWidth(page, 1)
   HPDF_Page_Rectangle(page, 50, 50, HPDF_Page_GetWidth(page) - 100,;
                                     HPDF_Page_GetHeight(page) - 110)
   HPDF_Page_Stroke(page)

   /* print the title of the page(with positioning center). */
   HPDF_Page_SetFontAndSize(page, font, 24)
   tw = HPDF_Page_TextWidth(page, page_title)
   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page,(HPDF_Page_GetWidth(page) - tw) / 2, ;
                                HPDF_Page_GetHeight(page) - 50)
   HPDF_Page_ShowText(page, page_title)
   HPDF_Page_EndText(page)

   HPDF_Page_SetFontAndSize(page, font, 10)

   /* Draw verious widths of lines. */
   HPDF_Page_SetLineWidth(page, 0)
   draw_line(page, 60, 770, "line width = 0")

   HPDF_Page_SetLineWidth(page, 1.0)
   draw_line(page, 60, 740, "line width = 1.0")

   HPDF_Page_SetLineWidth(page, 2.0)
   draw_line(page, 60, 710, "line width = 2.0")

   /* Line dash pattern */
   HPDF_Page_SetLineWidth(page, 1.0)

   HPDF_Page_SetDash(page, DASH_MODE1, 1, 1)
   draw_line(page, 60, 680, "dash_ptn=[3], phase=1 -- 2 on, 3 off, 3 on...")

   HPDF_Page_SetDash(page, DASH_MODE2, 2, 2)
   draw_line(page, 60, 650, "dash_ptn=[7, 3], phase=2 -- 5 on 3 off, 7 on,...")

   HPDF_Page_SetDash(page, DASH_MODE3, 4, 0)
   draw_line(page, 60, 620, "dash_ptn=[8, 7, 2, 7], phase=0")

   HPDF_Page_SetDash(page, NIL, 0, 0)

   HPDF_Page_SetLineWidth(page, 30)
   HPDF_Page_SetRGBStroke(page, 0.0, 0.5, 0.0)

   /* Line Cap Style */
   HPDF_Page_SetLineCap(page, HPDF_BUTT_END)
   draw_line2(page, 60, 570, "PDF_BUTT_END")

   HPDF_Page_SetLineCap(page, HPDF_ROUND_END)
   draw_line2(page, 60, 505, "PDF_ROUND_END")

   HPDF_Page_SetLineCap(page, HPDF_PROJECTING_SCUARE_END)
   draw_line2(page, 60, 440, "PDF_PROJECTING_SCUARE_END")

   /* Line Join Style */
   HPDF_Page_SetLineWidth(page, 30)
   HPDF_Page_SetRGBStroke(page, 0.0, 0.0, 0.5)

   HPDF_Page_SetLineJoin(page, HPDF_MITER_JOIN)
   HPDF_Page_MoveTo(page, 120, 300)
   HPDF_Page_LineTo(page, 160, 340)
   HPDF_Page_LineTo(page, 200, 300)
   HPDF_Page_Stroke(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, 60, 360)
   HPDF_Page_ShowText(page, "PDF_MITER_JOIN")
   HPDF_Page_EndText(page)

   HPDF_Page_SetLineJoin(page, HPDF_ROUND_JOIN)
   HPDF_Page_MoveTo(page, 120, 195)
   HPDF_Page_LineTo(page, 160, 235)
   HPDF_Page_LineTo(page, 200, 195)
   HPDF_Page_Stroke(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, 60, 255)
   HPDF_Page_ShowText(page, "PDF_ROUND_JOIN")
   HPDF_Page_EndText(page)

   HPDF_Page_SetLineJoin(page, HPDF_BEVEL_JOIN)
   HPDF_Page_MoveTo(page, 120, 90)
   HPDF_Page_LineTo(page, 160, 130)
   HPDF_Page_LineTo(page, 200, 90)
   HPDF_Page_Stroke(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, 60, 150)
   HPDF_Page_ShowText(page, "PDF_BEVEL_JOIN")
   HPDF_Page_EndText(page)

   /* Draw Rectangle */
   HPDF_Page_SetLineWidth(page, 2)
   HPDF_Page_SetRGBStroke(page, 0, 0, 0)
   HPDF_Page_SetRGBFill(page, 0.75, 0.0, 0.0)

   draw_rect(page, 300, 770, "Stroke")
   HPDF_Page_Stroke(page)

   draw_rect(page, 300, 720, "Fill")
   HPDF_Page_Fill(page)

   draw_rect(page, 300, 670, "Fill then Stroke")
   HPDF_Page_FillStroke(page)

   /* Clip Rect */
   HPDF_Page_GSave(page)   /* Save the current graphic state */
   draw_rect(page, 300, 620, "Clip Rectangle")
   HPDF_Page_Clip(page)
   HPDF_Page_Stroke(page)
   HPDF_Page_SetFontAndSize(page, font, 13)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, 290, 600)
   HPDF_Page_SetTextLeading(page, 12)
   HPDF_Page_ShowText(page, "Clip Clip Clip Clip Clip Clipi Clip Clip Clip")
   HPDF_Page_ShowTextNextLine(page, "Clip Clip Clip Clip Clip Clip Clip Clip Clip")
   HPDF_Page_ShowTextNextLine(page, "Clip Clip Clip Clip Clip Clip Clip Clip Clip")
   HPDF_Page_EndText(page)
   HPDF_Page_GRestore(page)

   /* Curve Example(CurveTo2) */
   x  := 330
   y  := 440
   x1 := 430
   y1 := 530
   x2 := 480
   y2 := 470
   x3 := 480
   y3 := 90

   HPDF_Page_SetRGBFill(page, 0, 0, 0)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, 300, 540)
   HPDF_Page_ShowText(page, "CurveTo2(x1, y1, x2. y2)")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x + 5, y - 5)
   HPDF_Page_ShowText(page, "Current point")
   HPDF_Page_MoveTextPos(page, x1 - x, y1 - y)
   HPDF_Page_ShowText(page, "(x1, y1)")
   HPDF_Page_MoveTextPos(page, x2 - x1, y2 - y1)
   HPDF_Page_ShowText(page, "(x2, y2)")
   HPDF_Page_EndText(page)

   HPDF_Page_SetDash(page, DASH_MODE1, 1, 0)

   HPDF_Page_SetLineWidth(page, 0.5)
   HPDF_Page_MoveTo(page, x1, y1)
   HPDF_Page_LineTo(page, x2, y2)
   HPDF_Page_Stroke(page)

   HPDF_Page_SetDash(page, NIL, 0, 0)

   HPDF_Page_SetLineWidth(page, 1.5)

   HPDF_Page_MoveTo(page, x, y)
   HPDF_Page_CurveTo2(page, x1, y1, x2, y2)
   HPDF_Page_Stroke(page)

   /* Curve Example(CurveTo3) */
   y  -= 150
   y1 -= 150
   y2 -= 150

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, 300, 390)
   HPDF_Page_ShowText(page, "CurveTo3(x1, y1, x2. y2)")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x + 5, y - 5)
   HPDF_Page_ShowText(page, "Current point")
   HPDF_Page_MoveTextPos(page, x1 - x, y1 - y)
   HPDF_Page_ShowText(page, "(x1, y1)")
   HPDF_Page_MoveTextPos(page, x2 - x1, y2 - y1)
   HPDF_Page_ShowText(page, "(x2, y2)")
   HPDF_Page_EndText(page)

   HPDF_Page_SetDash(page, DASH_MODE1, 1, 0)

   HPDF_Page_SetLineWidth(page, 0.5)
   HPDF_Page_MoveTo(page, x, y)
   HPDF_Page_LineTo(page, x1, y1)
   HPDF_Page_Stroke(page)

   HPDF_Page_SetDash(page, NIL, 0, 0)

   HPDF_Page_SetLineWidth(page, 1.5)
   HPDF_Page_MoveTo(page, x, y)
   HPDF_Page_CurveTo3(page, x1, y1, x2, y2)
   HPDF_Page_Stroke(page)

   /* Curve Example(CurveTo) */
   y  -= 150
   y1 -= 160
   y2 -= 130
   x2 += 10

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, 300, 240)
   HPDF_Page_ShowText(page, "CurveTo(x1, y1, x2. y2, x3, y3)")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x + 5, y - 5)
   HPDF_Page_ShowText(page, "Current point")
   HPDF_Page_MoveTextPos(page, x1 - x, y1 - y)
   HPDF_Page_ShowText(page, "(x1, y1)")
   HPDF_Page_MoveTextPos(page, x2 - x1, y2 - y1)
   HPDF_Page_ShowText(page, "(x2, y2)")
   HPDF_Page_MoveTextPos(page, x3 - x2, y3 - y2)
   HPDF_Page_ShowText(page, "(x3, y3)")
   HPDF_Page_EndText(page)

   HPDF_Page_SetDash(page, DASH_MODE1, 1, 0)

   HPDF_Page_SetLineWidth(page, 0.5)
   HPDF_Page_MoveTo(page, x, y)
   HPDF_Page_LineTo(page, x1, y1)
   HPDF_Page_Stroke(page)
   HPDF_Page_MoveTo(page, x2, y2)
   HPDF_Page_LineTo(page, x3, y3)
   HPDF_Page_Stroke(page)

   HPDF_Page_SetDash(page, NIL, 0, 0)

   HPDF_Page_SetLineWidth(page, 1.5)
   HPDF_Page_MoveTo(page, x, y)
   HPDF_Page_CurveTo(page, x1, y1, x2, y2, x3, y3)
   HPDF_Page_Stroke(page)

   RETURN  NIL
*------------------------------------------------------------------------*
static function draw_rect( page, x, y, label )
*------------------------------------------------------------------------*
   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x, y - 10)
   HPDF_Page_ShowText(page, label)
   HPDF_Page_EndText(page)

   HPDF_Page_Rectangle(page, x, y - 40, 220, 25)
   Return nil
*------------------------------------------------------------------------*
Static Function draw_line( page, x, y, label )
*------------------------------------------------------------------------*
   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x, y - 10)
   HPDF_Page_ShowText(page, label)
   HPDF_Page_EndText(page)

   HPDF_Page_MoveTo(page, x, y - 15)
   HPDF_Page_LineTo(page, x + 220, y - 15)
   HPDF_Page_Stroke(page)
   Return nil
*------------------------------------------------------------------------*
Static Function draw_line2( page, x, y, label )
*------------------------------------------------------------------------*
   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x, y)
   HPDF_Page_ShowText(page, label)
   HPDF_Page_EndText(page)

   HPDF_Page_MoveTo(page, x + 30, y - 25)
   HPDF_Page_LineTo(page, x + 160, y - 25)
   HPDF_Page_Stroke(page)
   Return NIL
*------------------------------------------------------------------------*
Static Function Page_Text( pdf, grid )
*------------------------------------------------------------------------*
   Local page, page_height, font, rect := array( 4 )
   Local SAMP_TXT := "The quick brown fox jumps over the lazy dog. "
   Local angle1, angle2, rad1, rad2,i,x,y,buf
   default grid to .f.

   /* add a new page object. */
   page = HPDF_AddPage(pdf)
   aadd(cpos ,page)
   HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A5, HPDF_PAGE_PORTRAIT)

   //print_grid( pdf, page )
   if grid
      print_grid (pdf, page)
   Endif
   
   page_height := HPDF_Page_GetHeight(page)

   font := HPDF_GetFont(pdf, "Helvetica", NIL)
   HPDF_Page_SetTextLeading(page, 20)

   /* text_rect method */

   /* HPDF_TALIGN_LEFT */
   rect[ rLEFT   ] := 25
   rect[ rTOP    ] := 545
   rect[ rRIGHT  ] := 200
   rect[ rBOTTOM ] := rect[ 2 ] - 40

   HPDF_Page_Rectangle(page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
                                       rect[ rTOP ] - rect[ rBOTTOM ] )
   HPDF_Page_Stroke(page)

   HPDF_Page_BeginText(page)

   HPDF_Page_SetFontAndSize(page, font, 10)
   HPDF_Page_TextOut(page, rect[ rLEFT ], rect[ rTOP ] + 3, "HPDF_TALIGN_LEFT")

   HPDF_Page_SetFontAndSize(page, font, 13)
   HPDF_Page_TextRect(page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ],;
                                       SAMP_TXT, HPDF_TALIGN_LEFT, NIL)

   HPDF_Page_EndText(page)

   /* HPDF_TALIGN_RIGTH */
   rect[ rLEFT  ] := 220
   rect[ rRIGHT ] := 395

   HPDF_Page_Rectangle( page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
               rect[ rTOP ] - rect[ rBOTTOM ])
   HPDF_Page_Stroke(page)

   HPDF_Page_BeginText(page)

   HPDF_Page_SetFontAndSize(page, font, 10)
   HPDF_Page_TextOut(page, rect[ rLEFT ], rect[ rTOP ] + 3, "HPDF_TALIGN_RIGTH")

   HPDF_Page_SetFontAndSize(page, font, 13)
   HPDF_Page_TextRect(page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
               SAMP_TXT, HPDF_TALIGN_RIGHT, NIL)

   HPDF_Page_EndText(page)

   /* HPDF_TALIGN_CENTER */
   rect[ rLEFT   ] := 25
   rect[ rTOP    ] := 475
   rect[ rRIGHT  ] := 200
   rect[ rBOTTOM ] := rect[ rTOP ] - 40

   HPDF_Page_Rectangle(page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
               rect[ rTOP ] - rect[ rBOTTOM ])
   HPDF_Page_Stroke(page)

   HPDF_Page_BeginText(page)

   HPDF_Page_SetFontAndSize(page, font, 10)
   HPDF_Page_TextOut(page, rect[ rLEFT ], rect[ rTOP ] + 3, "HPDF_TALIGN_CENTER")

   HPDF_Page_SetFontAndSize(page, font, 13)
   HPDF_Page_TextRect(page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ],;
               SAMP_TXT, HPDF_TALIGN_CENTER, NIL)

   HPDF_Page_EndText(page)

   /* HPDF_TALIGN_JUSTIFY */
   rect[ rLEFT  ] := 220
   rect[ rRIGHT ] := 395

   HPDF_Page_Rectangle(page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ],;
                                            rect[ rTOP ] - rect[ rBOTTOM ])
   HPDF_Page_Stroke(page)

   HPDF_Page_BeginText(page)

   HPDF_Page_SetFontAndSize(page, font, 10)
   HPDF_Page_TextOut(page, rect[ rLEFT ], rect[ rTOP ] + 3, "HPDF_TALIGN_JUSTIFY")

   HPDF_Page_SetFontAndSize(page, font, 13)
   HPDF_Page_TextRect(page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
                                            SAMP_TXT, HPDF_TALIGN_JUSTIFY, NIL)

   HPDF_Page_EndText(page)

   /* Skewed coordinate system */
   HPDF_Page_GSave(page)

   angle1 := 5
   angle2 := 10
   rad1   := angle1 / 180 * 3.141592
   rad2   := angle2 / 180 * 3.141592

   HPDF_Page_Concat(page, 1, tan(rad1), tan(rad2), 1, 25, 350)
   rect[ rLEFT   ] := 0
   rect[ rTOP    ] := 40
   rect[ rRIGHT  ] := 175
   rect[ rBOTTOM ] := 0

   HPDF_Page_Rectangle(page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ],;
                                            rect[ rTOP ] - rect[ rBOTTOM ])
   HPDF_Page_Stroke(page)

   HPDF_Page_BeginText(page)

   HPDF_Page_SetFontAndSize(page, font, 10)
   HPDF_Page_TextOut(page, rect[ rLEFT ], rect[ rTOP ] + 3, "Skewed coordinate system")

   HPDF_Page_SetFontAndSize(page, font, 13)
   HPDF_Page_TextRect(page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
                                            SAMP_TXT, HPDF_TALIGN_LEFT, NIL)

   HPDF_Page_EndText(page)

   HPDF_Page_GRestore(page)


   /* Rotated coordinate system */
   HPDF_Page_GSave(page)

   angle1 := 5
   rad1   := angle1 / 180 * 3.141592

   HPDF_Page_Concat(page, cos(rad1), sin(rad1), -sin(rad1), cos(rad1), 220, 350)
   rect[ rLEFT   ] := 0
   rect[ rTOP    ] := 40
   rect[ rRIGHT  ] := 175
   rect[ rBOTTOM ] := 0

   HPDF_Page_Rectangle(page, rect[ rLEFT ], rect[ rBOTTOM ], rect[ rRIGHT ] - rect[ rLEFT ], ;
                                            rect[ rTOP ] - rect[ rBOTTOM ])
   HPDF_Page_Stroke(page)

   HPDF_Page_BeginText(page)

   HPDF_Page_SetFontAndSize(page, font, 10)
   HPDF_Page_TextOut(page, rect[ rLEFT ], rect[ rTOP ] + 3, "Rotated coordinate system")

   HPDF_Page_SetFontAndSize(page, font, 13)
   HPDF_Page_TextRect(page, rect[ rLEFT ], rect[ rTOP ], rect[ rRIGHT ], rect[ rBOTTOM ], ;
                                            SAMP_TXT, HPDF_TALIGN_LEFT, NIL)

   HPDF_Page_EndText(page)

   HPDF_Page_GRestore(page)


   /* text along a circle */
   HPDF_Page_SetGrayStroke(page, 0)
   HPDF_Page_Circle(page, 210, 190, 145)
   HPDF_Page_Circle(page, 210, 190, 113)
   HPDF_Page_Stroke(page)

   angle1 := 360 /(len(SAMP_TXT))
   angle2 := 180

   HPDF_Page_BeginText(page)
   font := HPDF_GetFont(pdf, "Courier-Bold", NIL)
   HPDF_Page_SetFontAndSize(page, font, 30)

   for i := 0  to len(SAMP_TXT)
       rad1 :=(angle2 - 90) / 180 * 3.141592
       rad2 := angle2 / 180 * 3.141592

       x := 210 + cos(rad2) * 122
       y := 190 + sin(rad2) * 122

       HPDF_Page_SetTextMatrix(page, cos(rad1), sin(rad1), -sin(rad1), cos(rad1), x, y)

       buf := substr( SAMP_TXT,i, 1 )
       HPDF_Page_ShowText(page, buf)
       angle2 -= angle1
   next

   HPDF_Page_EndText(page)

   Return nil
/*------------------------------------------------------------------------*
Static Function PrintText( page )
*------------------------------------------------------------------------*
   Local buf, pos := HPDF_Page_GetCurrentTextPos( page )

   static no := 0
   no++

   buf := ltrim( str( no ) )+ ' '+ltrim(str(pos[1]))+' '+ltrim(str(pos[2]))

   HPDF_Page_ShowText(page, buf)
   Return nil */
*------------------------------------------------------------------------*
Static Function Page_TextScaling( pdf, grid )
*------------------------------------------------------------------------*
   Local font, page, tw, angle1, angle2, buf, len, fsize, i, r, b, g, yPos, rad1, rad2
   Local samp_text  := "abcdefgABCDEFG123!#$%&+-@?"
   Local samp_text2 := "The quick brown fox jumps over the lazy dog."
   Local page_title := "Text Demo"
   Default grid to  .f.

   /* set compression mode */
   //HPDF_SetCompressionMode(pdf, HPDF_COMP_ALL)

   /* create default-font */
   font = HPDF_GetFont(pdf, "Helvetica", NIL)

   /* add a new page object. */
   page = HPDF_AddPage(pdf)
   *HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT)
   aadd(cpos ,page)

   /* draw grid to the page */
   if grid
      print_grid(pdf, page)
   Endif
   
   /* print the lines of the page.
   HPDF_Page_SetLineWidth(page, 1)
   HPDF_Page_Rectangle(page, 50, 50, HPDF_Page_GetWidth(page) - 100,
               HPDF_Page_GetHeight(page) - 110)
   HPDF_Page_Stroke(page)
   */

   /* print the title of the page(with positioning center). */
   HPDF_Page_SetFontAndSize(page, font, 24)
   tw = HPDF_Page_TextWidth(page, page_title)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page,(HPDF_Page_GetWidth(page) - tw) / 2,;
               HPDF_Page_GetHeight(page) - 50, page_title)
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, 60, HPDF_Page_GetHeight(page) - 60)

   /*
    * font size
    */
   fsize := 8
   do while (fsize < 60)
       /* set style and size of font. */
       HPDF_Page_SetFontAndSize(page, font, fsize)

       /* set the position of the text. */
       HPDF_Page_MoveTextPos(page, 0, -5 - fsize)

       /* measure the number of characters which included in the page. */
       buf := samp_text
       len := HPDF_Page_MeasureText(page, samp_text, ;
                       HPDF_Page_GetWidth(page) - 120, .F., NIL)

       HPDF_Page_ShowText(page, substr(buf,1,len) )

       /* print the description. */
       HPDF_Page_MoveTextPos(page, 0, -10)
       HPDF_Page_SetFontAndSize(page, font, 8)
       buf := "Fontsize="+ltrim( str( fsize, 0 ) )

       HPDF_Page_ShowText(page, buf)

       fsize *= 1.5
   enddo

   /*
    * font color
    */
   HPDF_Page_SetFontAndSize(page, font, 8)
   HPDF_Page_MoveTextPos(page, 0, -30)
   HPDF_Page_ShowText(page, "Font color")

   HPDF_Page_SetFontAndSize(page, font, 18)
   HPDF_Page_MoveTextPos(page, 0, -20)
   len := len( samp_text )
   for i := 1 to len
       r := i / len
       g := 1 -(i / len)
       buf := substr( samp_text, i, 1 )

       HPDF_Page_SetRGBFill(page, r, g, 0.0)
       HPDF_Page_ShowText(page, buf)
   next
   HPDF_Page_MoveTextPos(page, 0, -25)

   for i := 1 to len
       r := i /len
       b := 1 -(i /len)
       buf := substr( samp_text, i, 1 )

       HPDF_Page_SetRGBFill(page, r, 0.0, b)
       HPDF_Page_ShowText(page, buf)
   next
   HPDF_Page_MoveTextPos(page, 0, -25)

   for i = 1 to len
       b := i /len
       g := 1 -(i /len)
       buf := substr( samp_text, i, 1 )

       HPDF_Page_SetRGBFill(page, 0.0, g, b)
       HPDF_Page_ShowText(page, buf)
   next

   HPDF_Page_EndText(page)

   ypos := 450

   /*
    * Font rendering mode
    */
   HPDF_Page_SetFontAndSize(page, font, 32)
   HPDF_Page_SetRGBFill(page, 0.5, 0.5, 0.0)
   HPDF_Page_SetLineWidth(page, 1.5)

    /* PDF_FILL */
   show_description(page,  60, ypos, "RenderingMode=PDF_FILL")
   HPDF_Page_SetTextRenderingMode(page, HPDF_FILL)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 60, ypos, "ABCabc123")
   HPDF_Page_EndText(page)

   /* PDF_STROKE */
   show_description(page, 60, ypos - 50, "RenderingMode=PDF_STROKE")
   HPDF_Page_SetTextRenderingMode(page, HPDF_STROKE)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 60, ypos - 50, "ABCabc123")
   HPDF_Page_EndText(page)

   /* PDF_FILL_THEN_STROKE */
   show_description(page, 60, ypos - 100, "RenderingMode=PDF_FILL_THEN_STROKE")
   HPDF_Page_SetTextRenderingMode(page, HPDF_FILL_THEN_STROKE)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 60, ypos - 100, "ABCabc123")
   HPDF_Page_EndText(page)

   /* PDF_FILL_CLIPPING */
   show_description(page, 60, ypos - 150, "RenderingMode=PDF_FILL_CLIPPING")
   HPDF_Page_GSave(page)
   HPDF_Page_SetTextRenderingMode(page, HPDF_FILL_CLIPPING)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 60, ypos - 150, "ABCabc123")
   HPDF_Page_EndText(page)
   show_stripe_pattern(page, 60, ypos - 150)
   HPDF_Page_GRestore(page)

   /* PDF_STROKE_CLIPPING */
   show_description(page, 60, ypos - 200, "RenderingMode=PDF_STROKE_CLIPPING")
   HPDF_Page_GSave(page)
   HPDF_Page_SetTextRenderingMode(page, HPDF_STROKE_CLIPPING)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 60, ypos - 200, "ABCabc123")
   HPDF_Page_EndText(page)
   show_stripe_pattern(page, 60, ypos - 200)
   HPDF_Page_GRestore(page)

   /* PDF_FILL_STROKE_CLIPPING */
   show_description(page, 60, ypos - 250, "RenderingMode=PDF_FILL_STROKE_CLIPPING")
   HPDF_Page_GSave(page)
   HPDF_Page_SetTextRenderingMode(page, HPDF_FILL_STROKE_CLIPPING)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 60, ypos - 250, "ABCabc123")
   HPDF_Page_EndText(page)
   show_stripe_pattern(page, 60, ypos - 250)
   HPDF_Page_GRestore(page)

   /* Reset text attributes */
   HPDF_Page_SetTextRenderingMode(page, HPDF_FILL)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)
   HPDF_Page_SetFontAndSize(page, font, 30)


   /*
    * Rotating text
    */
   angle1 := 30                   /* A rotation of 30 degrees. */
   rad1 := angle1 / 180 * 3.141592 /* Calcurate the radian value. */

   show_description(page, 320, ypos - 60, "Rotating text")
   HPDF_Page_BeginText(page)
   HPDF_Page_SetTextMatrix(page, cos(rad1), sin(rad1), -sin(rad1), cos(rad1), 330, ypos - 60)
   HPDF_Page_ShowText(page, "ABCabc123")
   HPDF_Page_EndText(page)


   /*
    * Skewing text.
    */
   show_description(page, 320, ypos - 120, "Skewing text")
   HPDF_Page_BeginText(page)

   angle1 = 10
   angle2 = 20
   rad1 = angle1 / 180 * 3.141592
   rad2 = angle2 / 180 * 3.141592

   HPDF_Page_SetTextMatrix(page, 1, tan(rad1), tan(rad2), 1, 320, ypos - 120)
   HPDF_Page_ShowText(page, "ABCabc123")
   HPDF_Page_EndText(page)


   /*
    * scaling text(X direction)
    */
   show_description(page, 320, ypos - 175, "Scaling text(X direction)")
   HPDF_Page_BeginText(page)
   HPDF_Page_SetTextMatrix(page, 1.5, 0, 0, 1, 320, ypos - 175)
   HPDF_Page_ShowText(page, "ABCabc12")
   HPDF_Page_EndText(page)


   /*
    * scaling text(Y direction)
    */
   show_description(page, 320, ypos - 250, "Scaling text(Y direction)")
   HPDF_Page_BeginText(page)
   HPDF_Page_SetTextMatrix(page, 1, 0, 0, 2, 320, ypos - 250)
   HPDF_Page_ShowText(page, "ABCabc123")
   HPDF_Page_EndText(page)


   /*
    * char spacing, word spacing
    */

   show_description(page, 60, 140, "char-spacing 0")
   show_description(page, 60, 100, "char-spacing 1.5")
   show_description(page, 60, 60, "char-spacing 1.5, word-spacing 2.5")

   HPDF_Page_SetFontAndSize(page, font, 20)
   HPDF_Page_SetRGBFill(page, 0.1, 0.3, 0.1)

   /* char-spacing 0 */
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 60, 140, samp_text2)
   HPDF_Page_EndText(page)

   /* char-spacing 1.5 */
   HPDF_Page_SetCharSpace(page, 1.5)

   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 60, 100, samp_text2)
   HPDF_Page_EndText(page)

   /* char-spacing 1.5, word-spacing 3.5 */
   HPDF_Page_SetWordSpace(page, 2.5)

   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 60, 60, samp_text2)
   HPDF_Page_EndText(page)

   //HPDF_SetCompressionMode(pdf, nComp)

   Return nil
*------------------------------------------------------------------------*
Static Function show_stripe_pattern( page, x, y)
*------------------------------------------------------------------------*
   Local iy := 0

   do while(iy < 50)
       HPDF_Page_SetRGBStroke(page, 0.0, 0.0, 0.5)
       HPDF_Page_SetLineWidth(page, 1)
       HPDF_Page_MoveTo(page, x, y + iy)
       HPDF_Page_LineTo(page, x + HPDF_Page_TextWidth(page, "ABCabc123"), y + iy)
       HPDF_Page_Stroke(page)
       iy += 3
   enddo

   HPDF_Page_SetLineWidth(page, 2.5)
   Return nil
*------------------------------------------------------------------------*
static function show_description( page, x, y, text )
*------------------------------------------------------------------------*
   Local fsize := HPDF_Page_GetCurrentFontSize( page)
   Local font  := HPDF_Page_GetCurrentFont(page)
   Local c     := HPDF_Page_GetRGBFill(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)
   HPDF_Page_SetTextRenderingMode(page, HPDF_FILL)
   HPDF_Page_SetFontAndSize(page, font, 10)
   HPDF_Page_TextOut(page, x, y - 12, text)
   HPDF_Page_EndText(page)

   HPDF_Page_SetFontAndSize(page, font, fsize)
   HPDF_Page_SetRGBFill(page, c[1], c[2], c[3])
   Return nil
*------------------------------------------------------------------------*
#define PAGE_WIDTH   420
#define PAGE_HEIGHT  400
#define CELL_WIDTH   20
#define CELL_HEIGHT  20
#define CELL_HEADER  10

Static function Page_CodePages( pdf )
*------------------------------------------------------------------------*
   Local page, outline, font2, font_name, root, i, font, dst
   Local cResPath := "files" + hb_OSPathSeparator()
   Local cAfm := cResPath+"a010013l.afm"
   Local cPfb := cResPath+"a010013l.pfb"
   Local encodings := { ;
            "StandardEncoding",;
            "MacRomanEncoding",;
            "WinAnsiEncoding", ;
            "ISO8859-2",       ;
            "ISO8859-3",       ;
            "ISO8859-4",       ;
            "ISO8859-5",       ;
            "ISO8859-9",       ;
            "ISO8859-10",      ;
            "ISO8859-13",      ;
            "ISO8859-14",      ;
            "ISO8859-15",      ;
            "ISO8859-16",      ;
            "CP1250",          ;
            "CP1251",          ;
            "CP1252",          ;
            "CP1254",          ;
            "CP1257",          ;
            "KOI8-R",          ;
            "Symbol-Set",      ;
            "ZapfDingbats-Set" }

   /* Set page mode to use outlines. */
   HPDF_SetPageMode(pdf, HPDF_PAGE_MODE_USE_OUTLINE)

   /* get default font */
   font := HPDF_GetFont(pdf, "Helvetica", NIL)

   /* load font object */
   font_name := HPDF_LoadType1FontFromFile(pdf, cAfm, cPfb )

   /* create outline root. */
   root = HPDF_CreateOutline(pdf, NIL, "Encoding list", NIL)
   HPDF_Outline_SetOpened(root, .t.)

   for i := 1 to len( encodings )
       page = HPDF_AddPage(pdf)
       aadd(cpos ,page)

       HPDF_Page_SetWidth(page, PAGE_WIDTH)
       HPDF_Page_SetHeight(page, PAGE_HEIGHT)

       outline = HPDF_CreateOutline(pdf, root, encodings[i], NIL)
       dst = HPDF_Page_CreateDestination(page)
       HPDF_Destination_SetXYZ(dst, 0, HPDF_Page_GetHeight(page), 1)

       /* HPDF_Destination_SetFitB(dst) */
       HPDF_Outline_SetDestination(outline, dst)

       HPDF_Page_SetFontAndSize(page, font, 15)
       draw_graph(page)

       HPDF_Page_BeginText(page)
       HPDF_Page_SetFontAndSize(page, font, 20)
       HPDF_Page_MoveTextPos(page, 40, PAGE_HEIGHT - 50)
       HPDF_Page_ShowText(page, encodings[i] )
       HPDF_Page_ShowText(page, " Encoding" )
       HPDF_Page_EndText(page)

       if (encodings[i] == "Symbol-Set")
           font2 = HPDF_GetFont(pdf, "Symbol", NIL)
       elseif (encodings[i] == "ZapfDingbats-Set")
           font2 = HPDF_GetFont(pdf, "ZapfDingbats", NIL)
       else
           font2 = HPDF_GetFont(pdf, font_name, encodings[i])
       endif

       HPDF_Page_SetFontAndSize(page, font2, 14)
       draw_fonts(page)
   next

   return nil
*------------------------------------------------------------------------*
static function draw_graph( page )
*------------------------------------------------------------------------*
   Local buf, i, x, y

   /* Draw 16 X 15 cells */

   /* Draw vertical lines. */
   HPDF_Page_SetLineWidth(page, 0.5)

   for i := 0 to 17
       x = i * CELL_WIDTH + 40;

       HPDF_Page_MoveTo(page, x, PAGE_HEIGHT - 60)
       HPDF_Page_LineTo(page, x, 40)
       HPDF_Page_Stroke(page)

       if (i > 0 .and. i <= 16)
           HPDF_Page_BeginText(page)
           HPDF_Page_MoveTextPos(page, x + 5, PAGE_HEIGHT - 75)
           buf := hb_NumToHex( i-1 )
           HPDF_Page_ShowText(page, buf)
           HPDF_Page_EndText(page)
       endif
   next

   /* Draw horizontal lines. */
   for i := 0 to 15
       y := i * CELL_HEIGHT + 40

       HPDF_Page_MoveTo(page, 40, y)
       HPDF_Page_LineTo(page, PAGE_WIDTH - 40, y)
       HPDF_Page_Stroke(page)

       if (i < 14)
           HPDF_Page_BeginText(page)
           HPDF_Page_MoveTextPos(page, 45, y + 5)
           buf := hb_NumToHex( 15-i )
           HPDF_Page_ShowText(page, buf)
           HPDF_Page_EndText(page)
       endif
   next
   Return nil
*------------------------------------------------------------------------*
Static function draw_fonts(page)
*------------------------------------------------------------------------*
   Local i,j,buf, x, y, d

   HPDF_Page_BeginText(page)

   /* Draw all character from 0x20 to 0xFF to the canvas. */
   for i := 1 to 16
     for j := 1 to 16
        y = PAGE_HEIGHT - 55 - ((i - 1) * CELL_HEIGHT)
        x = j * CELL_WIDTH + 50

        buf := (i - 1) * 16 + (j - 1)
        if (buf >= 32)
           d  := x - HPDF_Page_TextWidth( page, chr( buf ) ) / 2
           HPDF_Page_TextOut( page, d, y, chr( buf ) )
         endif
      next
   next

   HPDF_Page_EndText(page)

   Return nil
*------------------------------------------------------------------------*
Static Function Page_Graphics( pdf , grid )
*------------------------------------------------------------------------*
   Local page, pos
   Default grid to .F.
   /* add a new page object. */
   page := HPDF_AddPage(pdf)
   aadd(cpos ,page)

   HPDF_Page_SetHeight(page, 220)
   HPDF_Page_SetWidth(page, 200)

   /* draw grid to the page */
   if grid
      print_grid(pdf, page)
   Endif

   /* draw pie chart
    *   A: 45% Red
    *   B: 25% Blue
    *   C: 15% green
    *   D: other yellow
    */

   /* A */
   HPDF_Page_SetRGBFill(page, 1.0, 0, 0)
   HPDF_Page_MoveTo(page, 100, 100)
   HPDF_Page_LineTo(page, 100, 180)
   HPDF_Page_Arc(page, 100, 100, 80, 0, 360 * 0.45)
   pos := HPDF_Page_GetCurrentPos(page)
   HPDF_Page_LineTo(page, 100, 100)
   HPDF_Page_Fill(page)

   /* B */
   HPDF_Page_SetRGBFill(page, 0, 0, 1.0)
   HPDF_Page_MoveTo(page, 100, 100)
   HPDF_Page_LineTo(page, pos[1], pos[2])
   HPDF_Page_Arc(page, 100, 100, 80, 360 * 0.45, 360 * 0.7)
   pos := HPDF_Page_GetCurrentPos(page)
   HPDF_Page_LineTo(page, 100, 100)
   HPDF_Page_Fill(page)

   /* C */
   HPDF_Page_SetRGBFill(page, 0, 1.0, 0)
   HPDF_Page_MoveTo(page, 100, 100)
   HPDF_Page_LineTo(page, pos[1], pos[2])
   HPDF_Page_Arc(page, 100, 100, 80, 360 * 0.7, 360 * 0.85)
   pos := HPDF_Page_GetCurrentPos(page)
   HPDF_Page_LineTo(page, 100, 100)
   HPDF_Page_Fill(page)

   /* D */
   HPDF_Page_SetRGBFill(page, 1.0, 1.0, 0)
   HPDF_Page_MoveTo(page, 100, 100)
   HPDF_Page_LineTo(page, pos[1], pos[2])
   HPDF_Page_Arc(page, 100, 100, 80, 360 * 0.85, 360)
   pos := HPDF_Page_GetCurrentPos(page)
   HPDF_Page_LineTo(page, 100, 100)
   HPDF_Page_Fill(page)

   /* draw center circle */
   HPDF_Page_SetGrayStroke(page, 0)
   HPDF_Page_SetGrayFill(page, 1)
   HPDF_Page_Circle(page, 100, 100, 30)
   HPDF_Page_Fill(page)

   Return nil
*------------------------------------------------------------------------*
Static Function Page_Annotation( pdf )
*------------------------------------------------------------------------*
   Local rect1 := {50 , 350, 150, 400}
   Local rect2 := {210, 350, 350, 400}
   Local rect3 := {50 , 250, 150, 300}
   Local rect4 := {210, 250, 350, 300}
   Local rect5 := {50 , 150, 150, 200}
   Local rect6 := {210, 150, 350, 200}
   Local rect7 := {50 , 50 , 150, 100}
   Local rect8 := {210, 50 , 350, 100}

   Local page, font, encoding, annot

   /* use Times-Roman font. */
   font = HPDF_GetFont(pdf, "Times-Roman", "WinAnsiEncoding")

   page = HPDF_AddPage(pdf)
   aadd( cpos, page )

   HPDF_Page_SetWidth(page, 400)
   HPDF_Page_SetHeight(page, 500)

   HPDF_Page_BeginText(page)
   HPDF_Page_SetFontAndSize(page, font, 16)
   HPDF_Page_MoveTextPos(page, 130, 450)
   HPDF_Page_ShowText(page, "Annotation Demo")
   HPDF_Page_EndText(page)


   annot = HPDF_Page_CreateTextAnnot(page, rect1, ;
               "Annotation with Comment Icons"+chr(13)+chr(10)+;
               "This annotation set to be opened initially.",;
               NIL)

   HPDF_TextAnnot_SetIcon(annot, HPDF_ANNOT_ICON_COMMENT)
   HPDF_TextAnnot_SetOpened(annot, HPDF_TRUE)

   annot = HPDF_Page_CreateTextAnnot(page, rect2, "Annotation with Key Icon", NIL)
   HPDF_TextAnnot_SetIcon(annot, HPDF_ANNOT_ICON_PARAGRAPH)

   annot = HPDF_Page_CreateTextAnnot(page, rect3, "Annotation with Note Icon", NIL)
   HPDF_TextAnnot_SetIcon(annot, HPDF_ANNOT_ICON_NOTE)

   annot = HPDF_Page_CreateTextAnnot(page, rect4, "Annotation with Help Icon", NIL)
   *HPDF_TextAnnot_SetIcon(annot, 1 )
   HPDF_TextAnnot_SetIcon(annot, HPDF_ANNOT_ICON_HELP)

   annot = HPDF_Page_CreateTextAnnot(page, rect5, "Annotation with NewParagraph Icon", NIL)
   HPDF_TextAnnot_SetIcon(annot, HPDF_ANNOT_ICON_NEW_PARAGRAPH)

   annot = HPDF_Page_CreateTextAnnot(page, rect6, "Annotation with Paragraph Icon", NIL)
   HPDF_TextAnnot_SetIcon(annot, HPDF_ANNOT_ICON_PARAGRAPH)

   annot = HPDF_Page_CreateTextAnnot(page, rect7, "Annotation with Insert Icon", NIL)
   HPDF_TextAnnot_SetIcon(annot, HPDF_ANNOT_ICON_INSERT)

   encoding = HPDF_GetEncoder(pdf, "ISO8859-2")

   HPDF_Page_CreateTextAnnot(page, rect8,"Annotation with ISO8859 text гдежзий", encoding)

   HPDF_Page_SetFontAndSize(page, font, 11)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, rect1[1] + 35, rect1[2] - 20)
   HPDF_Page_ShowText(page, "Comment Icon.")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, rect2[1] + 35, rect2[2] - 20)
   HPDF_Page_ShowText(page, "Key Icon")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, rect3[1] + 35, rect3[2] - 20)
   HPDF_Page_ShowText(page, "Note Icon.")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, rect4[1] + 35, rect4[2] - 20)
   HPDF_Page_ShowText(page, "Help Icon")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, rect5[1] + 35, rect5[2] - 20)
   HPDF_Page_ShowText(page, "NewParagraph Icon")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, rect6[1] + 35, rect6[2] - 20)
   HPDF_Page_ShowText(page, "Paragraph Icon")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, rect7[1] + 35, rect7[2] - 20)
   HPDF_Page_ShowText(page, "Insert Icon")
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, rect8[1] + 35, rect8[2] - 20)
   HPDF_Page_ShowText(page, "Text Icon(ISO8859-2 text)")
   HPDF_Page_EndText(page)

   Return nil
*------------------------------------------------------------------------*
Static function Page_Images( pdf )
*------------------------------------------------------------------------*
   Local font, page, dst, image, image1, image2, image3
   Local x, y, angle, angle1, angle2, rad, rad1, rad2, iw, ih
   Local cImagePath := "files" + hb_OSPathSeparator()

   /* create default-font */
   font := HPDF_GetFont(pdf, "Helvetica", Nil)

   /* add a new page object. */
   page := HPDF_AddPage(pdf)
   aadd( cpos, page )
   
   HPDF_Page_SetWidth(page, 550)
   HPDF_Page_SetHeight(page, 500)

   dst := HPDF_Page_CreateDestination(page)
   HPDF_Destination_SetXYZ(dst, 0, HPDF_Page_GetHeight(page), 1)
   HPDF_SetOpenAction(pdf, dst)

   HPDF_Page_BeginText(page)
   HPDF_Page_SetFontAndSize(page, font, 20)
   HPDF_Page_MoveTextPos(page, 220, HPDF_Page_GetHeight(page) - 70)
   HPDF_Page_ShowText(page, "ImageDemo")
   HPDF_Page_EndText(page)

   /* load image file. */
   image := HPDF_LoadPngImageFromFile(pdf, cImagePath+"basn3p02.png")

   /* image1 is masked by image2. */
   image1 := HPDF_LoadPngImageFromFile(pdf, cImagePath+"basn3p02.png")

   /* image2 is a mask image. */
   image2 := HPDF_LoadPngImageFromFile(pdf, cImagePath+"basn0g01.png")

   /* image3 is a RGB-color image. we use this image for color-mask
    * demo.
    */
   image3 = HPDF_LoadPngImageFromFile(pdf, cImagePath+"maskimage.png")

   iw := HPDF_Image_GetWidth(image)
   ih := HPDF_Image_GetHeight(image)
   HPDF_Page_SetLineWidth(page, 0.5)

   x := 100
   y := HPDF_Page_GetHeight(page) - 150

   /* Draw image to the canvas.(normal-mode with actual size.)*/
   HPDF_Page_DrawImage(page, image, x, y, iw, ih)

   show_description_1(page, x, y, "Actual Size")

   x += 150

   /* Scalling image(X direction) */
   HPDF_Page_DrawImage(page, image, x, y, iw * 1.5, ih)

   show_description_1(page, x, y, "Scalling image(X direction)")

   x += 150

   /* Scalling image(Y direction). */
   HPDF_Page_DrawImage(page, image, x, y, iw, ih * 1.5)
   show_description_1(page, x, y, "Scalling image(Y direction)")

   x := 100
   y -= 120

   /* Skewing image. */
   angle1 := 10
   angle2 := 20
   rad1   := angle1 / 180 * 3.141592
   rad2   := angle2 / 180 * 3.141592

   HPDF_Page_GSave(page)
   HPDF_Page_Concat(page, iw, tan(rad1) * iw, tan(rad2) * ih, ih, x, y)
   HPDF_Page_ExecuteXObject(page, image)
   HPDF_Page_GRestore(page)

   show_description_1(page, x, y, "Skewing image")

   x += 150

   /* Rotating image */
   angle = 30     /* rotation of 30 degrees. */
   rad = angle / 180 * 3.141592 /* Calcurate the radian value. */

   HPDF_Page_GSave(page)
   HPDF_Page_Concat(page, iw * cos(rad), ;
               iw * sin(rad), ;
               ih * -sin(rad), ;
               ih * cos(rad), ;
               x, y)
   HPDF_Page_ExecuteXObject(page, image)
   HPDF_Page_GRestore(page)

   show_description_1(page, x, y, "Rotating image")

   x += 150

   /* draw masked image. */

   /* Set image2 to the mask image of image1 */
   HPDF_Image_SetMaskImage(image1, image2)

   HPDF_Page_SetRGBFill(page, 0, 0, 0)
   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x - 6, y + 14)
   HPDF_Page_ShowText(page, "MASKMASK")
   HPDF_Page_EndText(page)

   HPDF_Page_DrawImage(page, image1, x - 3, y - 3, iw + 6, ih + 6)

   show_description_1(page, x, y, "masked image")

   x := 100
   y -= 120

   /* color mask. */
   HPDF_Page_SetRGBFill(page, 0, 0, 0)
   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x - 6, y + 14)
   HPDF_Page_ShowText(page, "MASKMASK")
   HPDF_Page_EndText(page)

   HPDF_Image_SetColorMask(image3, 0, 255, 0, 0, 0, 255)
   HPDF_Page_DrawImage(page, image3, x, y, iw, ih)

   show_description_1(page, x, y, "Color Mask")

   Return nil
*------------------------------------------------------------------------*
Static function show_description_1( page, x, y, text , addline)
*------------------------------------------------------------------------*
   Local buf:=''
   default addline  to .T.
   if addLine
      HPDF_Page_MoveTo(page, x, y - 10)
      HPDF_Page_LineTo(page, x, y + 10)
      HPDF_Page_MoveTo(page, x - 10, y)
      HPDF_Page_LineTo(page, x + 10, y)
      HPDF_Page_Stroke(page)
      HPDF_Page_SetFontAndSize(page, HPDF_Page_GetCurrentFont(page), 8)
      HPDF_Page_SetRGBFill(page, 0, 0, 0)
      buf := "x="+ltrim(str(x,10,0))+",y="+ltrim(str(y,10,0))
   Endif

   HPDF_Page_BeginText(page)

   HPDF_Page_MoveTextPos(page, x - HPDF_Page_TextWidth(page, buf) - 5, y - 10)
   HPDF_Page_ShowText(page, buf)
   HPDF_Page_EndText(page)

   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page, x , y - 25)
   HPDF_Page_ShowText(page, text)
   HPDF_Page_EndText(page)

   Return nil
*------------------------------------------------------------------------*
Static function Print_jpg( pdf )
*------------------------------------------------------------------------*
    Local cImagePath := "files" + hb_OSPathSeparator(), font, dst, page
    Local image1, image2, x, y, iw, ih
    
    font = HPDF_GetFont (pdf, "Helvetica", Nil);
    /* add a new page object. */
    page = HPDF_AddPage (pdf)
    aadd( cpos, page )

    HPDF_Page_SetWidth (page, 650)
    HPDF_Page_SetHeight (page, 500)

    dst = HPDF_Page_CreateDestination (page)
    HPDF_Destination_SetXYZ (dst, 0, HPDF_Page_GetHeight (page), 1)
    HPDF_SetOpenAction(pdf, dst)

    HPDF_Page_BeginText (page)
    HPDF_Page_SetFontAndSize (page, font, 20)
    HPDF_Page_MoveTextPos(page, (HPDF_Page_GetWidth(page)/2) - 50, HPDF_Page_GetHeight(page) - 70)
    HPDF_Page_ShowText (page, "JpegDemo")
    HPDF_Page_EndText (page)

    HPDF_Page_SetFontAndSize (page, font, 12)
    image1 = HPDF_LoadJPEGImageFromFile(pdf, cImagePath+"rgb.jpg")

    image2 = HPDF_LoadJPEGImageFromFile(pdf, cImagePath+"gray.jpg")
    iw := HPDF_Image_GetWidth(image1)
    ih := HPDF_Image_GetHeight(image1)

    x := 70
    y := HPDF_Page_GetHeight(page) - 410

    HPDF_Page_DrawImage(page, image1, x, y, iw, ih)
    Show_Description_1(page, x, y, "rgb.jpg - 24bit color image", .F.)

    iw := HPDF_Image_GetWidth(image2)
    ih := HPDF_Image_GetHeight(image2)

    x := 340
    y := HPDF_Page_GetHeight(page) - 410

    HPDF_Page_DrawImage(page, image2, x, y, iw, ih)
    Show_Description_1(page, x, y, "gray.jpg - 8bit grayscale image", .F.)

Return nil
*------------------------------------------------------------------------*
Static function print_grid( pdf, page )
*------------------------------------------------------------------------*
   Local  height,width,font,x,y

    height = HPDF_Page_GetHeight (page)
    width = HPDF_Page_GetWidth (page)
    font = HPDF_GetFont (pdf, "Helvetica", Nil)

    HPDF_Page_SetFontAndSize (page, font, 5)
    HPDF_Page_SetGrayFill (page, 0.5)
    HPDF_Page_SetGrayStroke (page, 0.8)

    /* Draw horizontal lines */
    y := 0
    while (y < height)
        if (y % 10 == 0)
            HPDF_Page_SetLineWidth (page, 0.5)
        else
           if (HPDF_Page_GetLineWidth (page) != 0.25)
              HPDF_Page_SetLineWidth (page, 0.25)
           Endif
        Endif

        HPDF_Page_MoveTo (page, 0, y)
        HPDF_Page_LineTo (page, width, y)
        HPDF_Page_Stroke (page)

        if (y % 10 == 0 .and. y > 0)
            HPDF_Page_SetGrayStroke (page, 0.5)

            HPDF_Page_MoveTo (page, 0, y)
            HPDF_Page_LineTo (page, 5, y)
            HPDF_Page_Stroke (page)

            HPDF_Page_SetGrayStroke (page, 0.8)
        Endif

        y += 5
    End

    /* Draw vertical lines */
    x := 0
    while (x < width)
        if (x % 10 == 0)
            HPDF_Page_SetLineWidth (page, 0.5)
        else
            if (HPDF_Page_GetLineWidth (page) != 0.25)
                HPDF_Page_SetLineWidth (page, 0.25)
            Endif
        Endif

        HPDF_Page_MoveTo (page, x, 0)
        HPDF_Page_LineTo (page, x, height)
        HPDF_Page_Stroke (page)

        if (x % 50 == 0 .and. x > 0)
            HPDF_Page_SetGrayStroke (page, 0.5)

            HPDF_Page_MoveTo (page, x, 0)
            HPDF_Page_LineTo (page, x, 5)
            HPDF_Page_Stroke (page)

            HPDF_Page_MoveTo (page, x, height)
            HPDF_Page_LineTo (page, x, height - 5)
            HPDF_Page_Stroke (page)

            HPDF_Page_SetGrayStroke (page, 0.8)
        Endif

        x += 5
    End

    /* Draw horizontal text */

    y := 0
    while (y < height)
        if (y % 10 == 0 .and. y > 0)
            HPDF_Page_BeginText (page)
            HPDF_Page_MoveTextPos (page, 5, y - 2)
            HPDF_Page_ShowText (page, ltrim(str(Y)))
            HPDF_Page_EndText (page)
        Endif

        y += 5
    End


    /* Draw virtical text */

    x := 0
    while (x < width)
        if (x % 50 == 0 .and. x > 0)

            HPDF_Page_BeginText (page)
            HPDF_Page_MoveTextPos (page, x, 5)
            HPDF_Page_ShowText (page, ltrim(str(x)))
            HPDF_Page_EndText (page)

            HPDF_Page_BeginText (page)
            HPDF_Page_MoveTextPos (page, x, height - 10)
            HPDF_Page_ShowText (page, ltrim(str(x)))
            HPDF_Page_EndText (page)
        Endif

        x += 5
    End

    HPDF_Page_SetGrayFill (page, 0)
    HPDF_Page_SetGrayStroke (page, 0)

Return Nil
*------------------------------------------------------------------------*
Static Function Page_Link_Annotation( pdf )
*------------------------------------------------------------------------*
   Local index_page, Font, /*i,*/ Tp, Dst, annot, rect := array(4), page:={},;
   Uri:= "http://www.hmgextended.com" //,pagex
/*
   #define rLEFT   1
   #define rTOP    2
   #define rRIGHT  3
   #define rBOTTOM 4
*/
    /* create default-font */
    font := HPDF_GetFont (pdf, "Helvetica", Nil)

    /* create index page */
    index_page := HPDF_AddPage (pdf)
    HPDF_Page_SetWidth (index_page, 300)
    HPDF_Page_SetHeight (index_page, 220)

    /* Add 7 pages to the document. */
    //for i = 1 to 7
/*
    i=0
    while i < 8
        i ++
        aadd(page, HPDF_AddPage(pdf) )
        pagex := atail (page) //:= HPDF_AddPage(pdf)
        print_page(atail (page), font, i )
        //aadd(page,pagex)
    End
*/
    HPDF_Page_BeginText (index_page)
    HPDF_Page_SetFontAndSize (index_page, font, 10)
    HPDF_Page_MoveTextPos (index_page, 15, 200)
    HPDF_Page_ShowText (index_page, "Link Annotation Demo")
    HPDF_Page_EndText (index_page)


     * Create Link-Annotation object on index page.

    HPDF_Page_BeginText(index_page)
    HPDF_Page_SetFontAndSize (index_page, font, 8)
    HPDF_Page_MoveTextPos (index_page, 20, 180)
    HPDF_Page_SetTextLeading (index_page, 23)

    /* page1 (HPDF_ANNOT_NO_HIGHTLIGHT) */
    Tp = HPDF_Page_GetCurrentTextPos (index_page)

    HPDF_Page_ShowText (index_page, "Jump to Page 1 (HilightMode=HPDF_ANNOT_NO_HIGHTLIGHT)")

    rect [ rLEFT ]   := tp[1] - 4
    rect [ rBOTTOM ] := Tp[2] - 4
    rect [ rRIGHT ]  := HPDF_Page_GetCurrentTextPos (index_page)[1] + 4
    rect [ rTOP ]    := Tp[2] + 10

    HPDF_Page_MoveToNextLine (index_page)

    dst := HPDF_Page_CreateDestination (cpos[1]) 

    annot := HPDF_Page_CreateLinkAnnot (index_page, rect, dst)

    HPDF_LinkAnnot_SetHighlightMode (annot, HPDF_ANNOT_NO_HIGHTLIGHT)

    /* page2 (HPDF_ANNOT_INVERT_BOX)*/
    Tp = HPDF_Page_GetCurrentTextPos (index_page)

    HPDF_Page_ShowText (index_page, "Jump to Page 2 (HilightMode=HPDF_ANNOT_INVERT_BOX)")
    rect [ rLEFT ]   := Tp[1] - 4
    rect [ rBOTTOM ] := Tp[2] - 4
    rect [ rRIGHT ]  := HPDF_Page_GetCurrentTextPos (index_page)[1] + 4
    rect [ rTOP ]    := Tp[2] + 10

    HPDF_Page_MoveToNextLine (index_page)

    dst := HPDF_Page_CreateDestination (cpos[2])

    annot := HPDF_Page_CreateLinkAnnot (index_page, rect, dst)

    HPDF_LinkAnnot_SetHighlightMode (annot, HPDF_ANNOT_INVERT_BOX)

    /* page3 (HPDF_ANNOT_INVERT_BORDER) */
    Tp = HPDF_Page_GetCurrentTextPos (index_page)

    HPDF_Page_ShowText (index_page, "Jump to Page 3 (HilightMode=HPDF_ANNOT_INVERT_BORDER)")
    rect [ rLEFT ] := Tp[1] - 4
    rect [ rBOTTOM ] := Tp[2] - 4
    rect [ rRIGHT ] := HPDF_Page_GetCurrentTextPos (index_page)[1]+ 4
    rect [ rTOP ] := Tp[2] + 10

    HPDF_Page_MoveToNextLine (index_page)

    dst := HPDF_Page_CreateDestination (cpos[3])

    annot := HPDF_Page_CreateLinkAnnot (index_page, rect, dst)

    HPDF_LinkAnnot_SetHighlightMode (annot, HPDF_ANNOT_INVERT_BORDER)

    /* page4 (HPDF_ANNOT_DOWN_APPEARANCE) */
    tp = HPDF_Page_GetCurrentTextPos (index_page)

    HPDF_Page_ShowText (index_page, "Jump to Page 4 (HilightMode=HPDF_ANNOT_DOWN_APPEARANCE)")
    rect [ rLEFT ] := Tp[1] - 4
    rect [ rBOTTOM ] := Tp[2] - 4
    rect [ rRIGHT ] := HPDF_Page_GetCurrentTextPos (index_page)[1]+ 4
    rect [ rTOP ] := Tp[2] + 10

    HPDF_Page_MoveToNextLine (index_page)

    dst := HPDF_Page_CreateDestination (cpos[4])

    annot := HPDF_Page_CreateLinkAnnot (index_page, rect, dst)

    HPDF_LinkAnnot_SetHighlightMode (annot, HPDF_ANNOT_DOWN_APPEARANCE)


    /* page5 (dash border) */
    tp = HPDF_Page_GetCurrentTextPos (index_page)

    HPDF_Page_ShowText (index_page, "Jump to Page 5 (dash border)")
    rect [ rLEFT ]   := Tp[1] - 4
    rect [ rBOTTOM ] := Tp[2] - 4
    rect [ rRIGHT ]  := HPDF_Page_GetCurrentTextPos (index_page)[1]+ 4
    rect [ rTOP ]    := Tp[2] + 10

    HPDF_Page_MoveToNextLine (index_page)

    dst := HPDF_Page_CreateDestination (cpos[5])

    annot := HPDF_Page_CreateLinkAnnot (index_page, rect, dst)

    HPDF_LinkAnnot_SetBorderStyle (annot, 1, 3, 2)


    /* page6 (no border) */
    tp = HPDF_Page_GetCurrentTextPos (index_page)

    HPDF_Page_ShowText (index_page, "Jump to Page 6 (no border)")
    rect [ rLEFT ]   := Tp[1] - 4
    rect [ rBOTTOM ] := Tp[2] - 4
    rect [ rRIGHT ]  := HPDF_Page_GetCurrentTextPos (index_page)[1]+ 4
    rect [ rTOP ]    := Tp[2] + 10

    HPDF_Page_MoveToNextLine (index_page)

    dst := HPDF_Page_CreateDestination (cpos[6])

    annot := HPDF_Page_CreateLinkAnnot (index_page, rect, dst)

    HPDF_LinkAnnot_SetBorderStyle (annot, 0, 0, 0)


    /* page7 (bold border) */
    tp = HPDF_Page_GetCurrentTextPos (index_page)

    HPDF_Page_ShowText (index_page, "Jump to Page 7 (bold border)")
    rect [ rLEFT ]   := Tp[1] - 4
    rect [ rBOTTOM ] := Tp[2] - 4
    rect [ rRIGHT ]  := HPDF_Page_GetCurrentTextPos (index_page)[1]+ 4
    rect [ rTOP ]    := Tp[2] + 10

    HPDF_Page_MoveToNextLine (index_page)

    dst := HPDF_Page_CreateDestination (cpos[7])

    annot := HPDF_Page_CreateLinkAnnot (index_page, rect, dst)

    HPDF_LinkAnnot_SetBorderStyle (annot, 2, 0, 0)


    /* URI link */
    tp = HPDF_Page_GetCurrentTextPos (index_page)

    HPDF_Page_ShowText (index_page, "URI (")
    HPDF_Page_ShowText (index_page, uri)
    HPDF_Page_ShowText (index_page, ")")

    rect [ rLEFT ]   := Tp[1] - 4
    rect [ rBOTTOM ] := Tp[2] - 4
    rect [ rRIGHT ]  := HPDF_Page_GetCurrentTextPos (index_page)[1]+ 4
    rect [ rTOP ]    := Tp[2] + 10

    HPDF_Page_CreateURILinkAnnot (index_page, rect, uri)

    HPDF_Page_EndText (index_page)
Return Nil
/*------------------------------------------------------------------------*
Static Function Print_page  (page, font,page_num)
*------------------------------------------------------------------------*

    HPDF_Page_SetWidth (page, 200)
    HPDF_Page_SetHeight (page, 200)

    HPDF_Page_SetFontAndSize (page, font, 20)
    HPDF_Page_BeginText (page)
    HPDF_Page_MoveTextPos (page, 50, 150)
    HPDF_Page_ShowText (page, ltrim(str(page_num) ) )
    HPDF_Page_EndText (page)

return nil
*/
*------------------------------------------------------------------------*
Static Function Print_TTFont ( pdf , TTName , emb )
*------------------------------------------------------------------------*
    Local SAMP_TXT := "The quick brown fox jumps over the lazy dog."
    Local title_font, pw, page_height, page_width, embed
    Local detail_font, detail_font_name, page
    Default emb to ''

    /* Add a new page object. */
    page := HPDF_AddPage (pdf)
    aadd(cpos ,page)

    title_font := HPDF_GetFont (pdf, "Helvetica", Nil)

    if (pcount() > 2 .and. emb == "-E" )
        embed := HPDF_TRUE
    else
        embed := HPDF_FALSE
    Endif

    detail_font_name := HPDF_LoadTTFontFromFile (pdf, TTName, embed)

    detail_font := HPDF_GetFont (pdf, detail_font_name, Nil)

    HPDF_Page_SetFontAndSize (page, title_font, 10)

    HPDF_Page_BeginText (page)

    /* Move the position of the text to top of the page. */
    HPDF_Page_MoveTextPos(page, 10, 190)
    HPDF_Page_ShowText (page, detail_font_name)

    if embed = HPDF_TRUE
        HPDF_Page_ShowText (page, " (Embedded Subset)")
    Else
        HPDF_Page_ShowText (page, " (NOT embedded Subset)")
    endif

    HPDF_Page_SetFontAndSize (page, detail_font, 15)
    HPDF_Page_MoveTextPos (page, 10, -20)
    HPDF_Page_ShowText (page, "abcdefghijklmnopqrstuvwxyz")
    HPDF_Page_MoveTextPos (page, 0, -20)
    HPDF_Page_ShowText (page, "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    HPDF_Page_MoveTextPos (page, 0, -20)
    HPDF_Page_ShowText (page, "1234567890")
    HPDF_Page_MoveTextPos (page, 0, -20)

    HPDF_Page_SetFontAndSize (page, detail_font, 10)
    HPDF_Page_ShowText (page, SAMP_TXT)
    HPDF_Page_MoveTextPos (page, 0, -18)

    HPDF_Page_SetFontAndSize (page, detail_font, 16)
    HPDF_Page_ShowText (page, SAMP_TXT)
    HPDF_Page_MoveTextPos (page, 0, -27)

    HPDF_Page_SetFontAndSize (page, detail_font, 23)
    HPDF_Page_ShowText (page, SAMP_TXT)
    HPDF_Page_MoveTextPos (page, 0, -36)

    HPDF_Page_SetFontAndSize (page, detail_font, 30)
    HPDF_Page_ShowText (page, SAMP_TXT)
    HPDF_Page_MoveTextPos (page, 0, -36)

    pw := HPDF_Page_TextWidth (page, SAMP_TXT)
    page_height := 210
    page_width  := pw + 40

    HPDF_Page_SetWidth (page, page_width)
    HPDF_Page_SetHeight (page, page_height)

    /* Finish to print text. */
    HPDF_Page_EndText (page)

    HPDF_Page_SetLineWidth (page, 0.5)

    HPDF_Page_MoveTo (page, 10, page_height - 25)
    HPDF_Page_LineTo (page, page_width - 10, page_height - 25)
    HPDF_Page_Stroke (page)

    HPDF_Page_MoveTo (page, 10, page_height - 85)
    HPDF_Page_LineTo (page, page_width - 10, page_height - 85)
    HPDF_Page_Stroke (page)

Return nil
*------------------------------------------------------------------------*
Static Function Page_slide (pdf)
*------------------------------------------------------------------------*
Local page0,page1,page2,page3,page4,page5,page6,page7,page8,page9,page10,;
      page11,page12,page13,page14,page15,page16,font

    /* create default-font */
    font = HPDF_GetFont (pdf, "Courier", NIL)

    /* Add 17 pages to the document. */
    page0 := HPDF_AddPage (pdf)
    page1 := HPDF_AddPage (pdf)
    page2 := HPDF_AddPage (pdf)
    page3 := HPDF_AddPage (pdf)
    page4 := HPDF_AddPage (pdf)
    page5 := HPDF_AddPage (pdf)
    page6 := HPDF_AddPage (pdf)
    page7 := HPDF_AddPage (pdf)
    page8 := HPDF_AddPage (pdf)
    page9 := HPDF_AddPage (pdf)
    page10 := HPDF_AddPage (pdf)
    page11 := HPDF_AddPage (pdf)
    page12 := HPDF_AddPage (pdf)
    page13 := HPDF_AddPage (pdf)
    page14 := HPDF_AddPage (pdf)
    page15 := HPDF_AddPage (pdf)
    page16 := HPDF_AddPage (pdf)

    Slide_page(page0, "HPDF_TS_WIPE_RIGHT", font,;
                         HPDF_TS_WIPE_RIGHT, NIL, page1)
    Slide_page(page1, "HPDF_TS_WIPE_UP", font,;
                        HPDF_TS_WIPE_UP, page0, page2)
    Slide_page(page2, "HPDF_TS_WIPE_LEFT", font,;
                        HPDF_TS_WIPE_LEFT, page1, page3)
    Slide_page(page3, "HPDF_TS_WIPE_DOWN", font,;
                        HPDF_TS_WIPE_DOWN, page2, page4)
    Slide_page(page4, "HPDF_TS_BARN_DOORS_HORIZONTAL_OUT", font,;
                        HPDF_TS_BARN_DOORS_HORIZONTAL_OUT, page3, page5)
    Slide_page(page5, "HPDF_TS_BARN_DOORS_HORIZONTAL_IN", font,;
                        HPDF_TS_BARN_DOORS_HORIZONTAL_IN, page4, page6)
    Slide_page(page6, "HPDF_TS_BARN_DOORS_VERTICAL_OUT", font,;
                        HPDF_TS_BARN_DOORS_VERTICAL_OUT, page5, page7)
    Slide_page(page7, "HPDF_TS_BARN_DOORS_VERTICAL_IN", font,;
                        HPDF_TS_BARN_DOORS_VERTICAL_IN, page6, page8)
    Slide_page(page8, "HPDF_TS_BOX_OUT", font,;
                        HPDF_TS_BOX_OUT, page7, page9)
    Slide_page(page9, "HPDF_TS_BOX_IN", font,;
                        HPDF_TS_BOX_IN, page8, page10)
    Slide_page(page10, "HPDF_TS_BLINDS_HORIZONTAL", font,;
                         HPDF_TS_BLINDS_HORIZONTAL, page9, page11)
    Slide_page(page11, "HPDF_TS_BLINDS_VERTICAL", font,;
                         HPDF_TS_BLINDS_VERTICAL, page10, page12)
    Slide_page(page12, "HPDF_TS_DISSOLVE", font,;
                         HPDF_TS_DISSOLVE, page11, page13)
    Slide_page(page13, "HPDF_TS_GLITTER_RIGHT", font,;
                         HPDF_TS_GLITTER_RIGHT, page12, page14)
    Slide_page(page14, "HPDF_TS_GLITTER_DOWN", font,;
                         HPDF_TS_GLITTER_DOWN, page13, page15)
    Slide_page(page15, "HPDF_TS_GLITTER_TOP_LEFT_TO_BOTTOM_RIGHT", font,;
                         HPDF_TS_GLITTER_TOP_LEFT_TO_BOTTOM_RIGHT, page14, page16)
    Slide_page(page16, "HPDF_TS_REPLACE", font,HPDF_TS_REPLACE, page15, NIL)

    HPDF_SetPageMode (pdf, HPDF_PAGE_MODE_FULL_SCREEN)

Return Nil

*------------------------------------------------------------------------*
Static Function Slide_page (page, caption, font, style, prev, next)
*------------------------------------------------------------------------*
    Local r,g,b,rect := array(4),dst, annot
/*
    #define rLEFT   1
    #define rTOP    2
    #define rRIGHT  3
    #define rBOTTOM 4
*/
    r := rand() 
    g := rand() 
    b := rand() 

    HPDF_Page_SetWidth (page, 800)
    HPDF_Page_SetHeight (page, 600)

    HPDF_Page_SetRGBFill (page, r, g, b);

    HPDF_Page_Rectangle (page, 0, 0, 800, 600)
    HPDF_Page_Fill (page)

    HPDF_Page_SetRGBFill (page, 1.0 - r, 1.0 - g, 1.0 - b)

    HPDF_Page_SetFontAndSize (page, font, 30)

    HPDF_Page_BeginText (page)
    HPDF_Page_SetTextMatrix (page, 0.8, 0.0, 0.0, 1.0, 0.0, 0.0)
    HPDF_Page_TextOut (page, 50, 530, caption)

    HPDF_Page_SetTextMatrix (page, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
    HPDF_Page_SetFontAndSize (page, font, 20)
    HPDF_Page_TextOut (page, 55, 300,"Type Ctrl+L in order to return from full screen mode.")
    HPDF_Page_EndText (page)

    //HPDF_Page_SetSlideShow (page, style, page delay, effect time )
    HPDF_Page_SetSlideShow (page, style, 2.5, 1.0)

    HPDF_Page_SetFontAndSize (page, font, 20)

    if  Valtype(next)=="P"
        HPDF_Page_BeginText (page)
        HPDF_Page_TextOut (page, 680, 50, "Next=>")
        HPDF_Page_EndText (page)

        rect [ rLEFT ]   := 675
        rect [ rBOTTOM ] := 40
        rect [ rRIGHT ]  := 755
        rect [ rTOP ]    := 70

        dst := HPDF_Page_CreateDestination (next)
        HPDF_Destination_SetFit(dst)
        annot := HPDF_Page_CreateLinkAnnot (page, rect, dst)
        HPDF_LinkAnnot_SetBorderStyle (annot, 0, 0, 0)
        HPDF_LinkAnnot_SetHighlightMode (annot, HPDF_ANNOT_INVERT_BOX)
    Endif

    if  Valtype(prev) =="P"
        HPDF_Page_BeginText (page)
        HPDF_Page_TextOut (page, 50, 50, "<=Prev")
        HPDF_Page_EndText (page)

        rect [ rLEFT ]   := 45
        rect [ rBOTTOM ] := 40
        rect [ rRIGHT ]  := 130
        rect [ rTOP ]    := 70
        dst := HPDF_Page_CreateDestination (prev)
        HPDF_Destination_SetFit(dst)
        annot := HPDF_Page_CreateLinkAnnot (page, rect, dst)
        HPDF_LinkAnnot_SetBorderStyle (annot, 0, 0, 0)
        HPDF_LinkAnnot_SetHighlightMode (annot, HPDF_ANNOT_INVERT_BOX)
    Endif

Return Nil

*------------------------------------------------------------------------*
Static Procedure Page_Zebra( pdf )
*------------------------------------------------------------------------*
   Local page := HPDF_AddPage( pdf ), tw

   HPDF_Page_SetLineWidth(page, 1)
   HPDF_Page_Rectangle(page, 50, 50, HPDF_Page_GetWidth(page) - 100,;
                                     HPDF_Page_GetHeight(page) - 110)
   HPDF_Page_Stroke(page)
   HPDF_Page_SetSize( page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )
   HPDF_Page_SetFontAndSize( page, HPDF_GetFont( pdf, "Helvetica", NIL ), 24 )
   tw = HPDF_Page_TextWidth(page, "Barcode & QrCode")
   HPDF_Page_BeginText(page)
   HPDF_Page_MoveTextPos(page,(HPDF_Page_GetWidth(page) - tw) / 2, ;
                               HPDF_Page_GetHeight(page) - 50)
   HPDF_Page_ShowText(page, "Barcode & QrCode" )
   HPDF_Page_EndText(page)


   HPDF_Page_SetFontAndSize( page, HPDF_GetFont( pdf, "Helvetica", NIL ), 12 )
   DrawBarcode( page,  80,   1, "EAN13",      "477012345678" )
   DrawBarcode( page, 100,   1, "EAN8",       "1234567" )
   DrawBarcode( page, 120,   1, "UPCA",       "01234567891" )
   DrawBarcode( page, 140,   1, "UPCE",       "123456" )
   DrawBarcode( page, 160,   1, "CODE39",     "ABC123" )
   DrawBarcode( page, 180,   1, "CODE39",     "ABC123", HB_ZEBRA_FLAG_CHECKSUM )
   DrawBarcode( page, 200, 0.5, "CODE39",     "ABC123", HB_ZEBRA_FLAG_CHECKSUM + HB_ZEBRA_FLAG_WIDE2_5 )
   DrawBarcode( page, 220,   1, "CODE39",     "ABC123", HB_ZEBRA_FLAG_CHECKSUM + HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, 240,   1, "ITF",        "1234", HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, 260,   1, "ITF",        "12345678901", HB_ZEBRA_FLAG_CHECKSUM )
   DrawBarcode( page, 280,   1, "MSI",        "1234" )
   DrawBarcode( page, 300,   1, "MSI",        "1234", HB_ZEBRA_FLAG_CHECKSUM + HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, 320,   1, "MSI",        "1234567", HB_ZEBRA_FLAG_CHECKSUM )
   DrawBarcode( page, 340,   1, "CODABAR",    "40156", HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, 360,   1, "CODABAR",    "-1234", HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, 380,   1, "CODE93",     "ABC-123" )
   DrawBarcode( page, 400,   1, "CODE93",     "TEST93" )
   DrawBarcode( page, 420,   1, "CODE11",     "12", HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, 440,   1, "CODE11",     "1234567890", HB_ZEBRA_FLAG_CHECKSUM + HB_ZEBRA_FLAG_WIDE3 )
   DrawBarcode( page, 460,   1, "CODE128",    "Code 128")
   DrawBarcode( page, 480,   1, "CODE128",    "1234567890")
   DrawBarcode( page, 500,   1, "CODE128",    "Wikipedia")
   DrawBarcode( page, 520,   1, "PDF417",     "Hello, World of Minigui!!! It's 2D barcode PDF417 :)" )
   DrawBarcode( page, 590,   1, "DATAMATRIX", "Hello, World of Minigui!!! It's 2D barcode DataMatrix :)")
   DrawBarcode( page, 630,   1, "QRCODE",     "http://hmgextended.com/" )

RETURN

*------------------------------------------------------------------------*
PROCEDURE DrawBarcode( page, nY, nLineWidth, cType, cCode, nFlags )
*------------------------------------------------------------------------*
   LOCAL hZebra, nLineHeight, cTxt

   nY := HPDF_Page_GetHeight( page ) - nY

   SWITCH cType
   CASE "EAN13"      ; hZebra := hb_zebra_create_ean13( cCode, nFlags )   ; EXIT
   CASE "EAN8"       ; hZebra := hb_zebra_create_ean8( cCode, nFlags )    ; EXIT
   CASE "UPCA"       ; hZebra := hb_zebra_create_upca( cCode, nFlags )    ; EXIT
   CASE "UPCE"       ; hZebra := hb_zebra_create_upce( cCode, nFlags )    ; EXIT
   CASE "CODE39"     ; hZebra := hb_zebra_create_code39( cCode, nFlags )  ; EXIT
   CASE "ITF"        ; hZebra := hb_zebra_create_itf( cCode, nFlags )     ; EXIT
   CASE "MSI"        ; hZebra := hb_zebra_create_msi( cCode, nFlags )     ; EXIT
   CASE "CODABAR"    ; hZebra := hb_zebra_create_codabar( cCode, nFlags ) ; EXIT
   CASE "CODE93"     ; hZebra := hb_zebra_create_code93( cCode, nFlags )  ; EXIT
   CASE "CODE11"     ; hZebra := hb_zebra_create_code11( cCode, nFlags )  ; EXIT
   CASE "CODE128"    ; hZebra := hb_zebra_create_code128( cCode, nFlags ) ; EXIT
   CASE "PDF417"     ; hZebra := hb_zebra_create_pdf417( cCode, nFlags ); nLineHeight := nLineWidth * 3 ; EXIT
   CASE "DATAMATRIX" ; hZebra := hb_zebra_create_datamatrix( cCode, nFlags ); nLineHeight := nLineWidth ; EXIT
   CASE "QRCODE"     ; hZebra := hb_zebra_create_qrcode( cCode, nFlags ); nLineHeight := nLineWidth ; EXIT
   ENDSWITCH

   IF hZebra != NIL
      IF hb_zebra_geterror( hZebra ) == 0
         IF Empty( nLineHeight )
            nLineHeight := 16
         ENDIF
         HPDF_Page_BeginText( page )
         HPDF_Page_TextOut( page,  60, nY - 13, cType )
         cTxt := hb_zebra_getcode( hZebra )
         IF Len( cTxt ) < 20
            HPDF_Page_TextOut( page, 150, nY - 13, cTxt )
         ENDIF
         HPDF_Page_EndText( page )
         hb_zebra_draw_hpdf( hZebra, page, 300, nY, nLineWidth, -nLineHeight )
      ELSE
         MsgExclamation("Type "+ cType + CRLF +"Code "+ cCode+ CRLF+ "Error  "+ltrim(hb_valtostr(hb_zebra_geterror( hZebra ))) )
      ENDIF
      hb_zebra_destroy( hZebra )
   ELSE
      MsgStop("Invalid barcode type !", cType )
   ENDIF

RETURN

*------------------------------------------------------------------------*
STATIC FUNCTION hb_zebra_draw_hpdf( hZebra, page, ... )
*------------------------------------------------------------------------*

   IF hb_zebra_GetError( hZebra ) != 0
      RETURN HB_ZEBRA_ERROR_INVALIDZEBRA
   ENDIF

   hb_zebra_draw( hZebra, {| x, y, w, h | HPDF_Page_Rectangle( page, x, y, w, h ) }, ... )

   HPDF_Page_Fill( page )

RETURN 0
