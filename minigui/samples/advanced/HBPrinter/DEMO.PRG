#include "minigui.ch"
#include "winprint.ch"

MEMVAR aPrinters, aports, prys

*--------------------------------------------------------*
Procedure main(rysunek)
*--------------------------------------------------------*
PRIVATE aPrinters, aports, prys:=if(!empty(rysunek), rysunek, "gfx/piasek.gif")

	INIT PRINTSYS
		GET PRINTERS TO aprinters
		GET PORTS TO aports
	RELEASE PRINTSYS

	DEFINE WINDOW F1 ;
                AT 0,0 ;
                WIDTH 600 HEIGHT 300 ;
                TITLE 'HBPrinter Demo' ;
                ICON 'printicon' ;
                MAIN ;
                FONT 'Arial' SIZE 10

                DEFINE STATUSBAR
                        STATUSITEM '[x] Harbour Power Ready!'
                END STATUSBAR

                @5 ,10 BUTTON Button_1 CAPTION '&Print' ACTION print() DEFAULT
                @50,10 BUTTON Button_2 CAPTION '&QUIT'  ACTION {|| _ReleaseWindow ("F1")}

                @5 ,200 LABEL LB1 VALUE "SELECT PRINTER:"
                @22,180 RADIOGROUP R1 ;
                  OPTIONS {"Print on default printer","I select printer from dialog","Print on printer selected below"} ;
                  VALUE 1 WIDTH 200 ;
                  ON CHANGE (F1.L1.ENABLED := (F1.R1.VALUE == 3), F1.L2.ENABLED := F1.L1.ENABLED)

                @100,10  LISTBOX L1 WIDTH 250 HEIGHT 100 ITEMS aprinters ;
                  ON CHANGE F1.L2.VALUE := F1.L1.VALUE
                @100,270 LISTBOX L2 WIDTH 250 HEIGHT 100 ITEMS aports ;
                  ON CHANGE F1.L1.VALUE := F1.L2.VALUE

                @210, 10 CHECKBOX CK1 CAPTION 'I want preview'             width 150 value .t.
                @210,160 CHECKBOX CK2 CAPTION 'I want thumbnails'          width 150 value .t.
                @210,310 CHECKBOX CK3 CAPTION 'No default size of preview' width 200 value .f.

	END WINDOW

	F1.L1.ENABLED := .F.
	F1.L2.ENABLED := .F.

	CENTER WINDOW F1

	ACTIVATE WINDOW F1

Return

*--------------------------------------------------------*
Procedure print()
*--------------------------------------------------------*
LOCAL cprn,lprev,lr,lck,i,j,apoly,apoly2

// astar:= {{0,12},{24,6},{12,24},{12,0},{24,18}}
 apoly:= {{20,30},{43,2},{12,24},{15,15},{24,18},{30,5},{20,11}}
 apoly2:={{12,2},{17,24},{25,15},{24,28},{30,25},{20,1}}

 lr:=f1.r1.value
 lprev:=f1.ck1.value

 INIT PRINTSYS

 do case
    case lr==1
               if lprev
                   SELECT DEFAULT PREVIEW
               else
                   SELECT DEFAULT
               endif
    case lr==2
               if lprev
                   SELECT BY DIALOG PREVIEW
               else
                   SELECT BY DIALOG
               endif

    case lr==3
               lck:=f1.l1.value
               if lck>0
                  cprn:=aprinters[lck]
                  if lprev
                      SELECT PRINTER cprn PREVIEW
                  else
                      SELECT PRINTER cprn
                  endif
               else
                  msgexclamation("No printer selected","Alert")
                  return
               endif
 endcase

 if HBPRNERROR>0
    return
 endif

 if f1.ck2.value
      ENABLE THUMBNAILS
 endif

 if f1.ck3.value
      SET PREVIEW RECT 20,20,GetDesktopHeight()-GetTaskbarHeight()-18,GetDesktopWidth()-20
 endif

  set page orientation DMORIENT_PORTRAIT papersize DMPAPER_A4 font "f0"

  define imagelist "ILIST1" picture "flags"
  define imagelist "ILIST2" picture "mytoolbar" iconcount 11

  define font "f0" name "courier new" size 12 bold
  define font "f1" name "times new roman" size 30 width 30 bold italic underline strikeout
  define font "f2" name "times new roman" size 30 bold
  define font "f3" name "times new roman" size 12 bold

  define pen "p0" style PS_SOLID width 1 color 0x000000
  define pen "p1" style PS_SOLID width 10 color 0xFF0000
  define pen "p2" style PS_NULL

  define brush "b0" style BS_SOLID color 0xCCFFAA
  define brush "b1" style BS_HATCHED color hbprn:dxcolors("YELLOW") hatch HS_DIAGCROSS
  define brush "b2" style BS_NULL


  define elliptic region "r0" at 0 ,0 ,20,30
  define elliptic region "r1" at 0 ,hbprnmaxcol-30,20,hbprnmaxcol
  define elliptic region "r2" at 10,20,40,hbprnmaxcol-20
  combine regions "r0","r1" to "r4" style WINDING
  combine regions "r4","r2" to "r5" style WINDING

  select font "f0"
  select pen "p0"

  START DOC NAME f1.title

    START PAGE
       @0,0,hbprnmaxrow+1,hbprnmaxcol+1 RECTANGLE pen "p1" brush "b1"
       @10,10 PICTURE prys SIZE 5,5 EXTEND HBPRNMAXROW-20,HBPRNMAXCOL-20
       POLYGON apoly PEN "p0" BRUSH "b1"
       @5,1 SAY "FONT F1 BOLD ITALIC UNDERLINE STRIKEOUT 30%WIDTH" FONT "f1" TO PRINT
       @8,1 SAY "FONT F2 BOLD" FONT "f2" TO PRINT
    END PAGE

    START PAGE
      SELECT CLIP REGION "r5"
      @ 0,0 PICTURE prys size 41,HBPRNMAXCOL+1
      @15,20 SAY "Mickey Mouse !!!" TO PRINT
      @17,20 SAY "Regions demo" TO PRINT
      DELETE CLIP REGION
    END PAGE

    START PAGE
       SELECT PEN   "P1"
       SELECT BRUSH "B0"

       @1,0,5,30 RECTANGLE
       @3,1 say "RECTANGLE" to print

       @1,31,5,60 FILLRECT
       @3,32 say "FILLRECT" to print

       @6,0,10,30 ROUNDRECT ROUNDR 1 ROUNDC 1
       @8,1 say "ROUNDRECT" to print

       @6,31,10,60 FRAMERECT BRUSH "b1"
       @8,32 say "FRAMERECT" to print

       @13,1 say "INVERTRECT" to print
       @11,0,15,30 INVERTRECT

       @11,31,15,60 ELLIPSE
       @13,32 say "ELLIPSE" to print
    END PAGE

    SET PAGE  ORIENTATION DMORIENT_PORTRAIT PAPERSIZE DMPAPER_A4 FONT "f0"

    START PAGE
       @10,10 PICTURE prys size 15,15 EXTEND 35,35
       SET TEXTCOLOR 0xff0000
       for j:=0 to HBPRNMAXROW
           @j,5 SAY "This is a text. This is only a text."+str(j,3) font "f3" TO PRINT
       next
       @12,12,HBPRNMAXROW-10,HBPRNMAXCOL-10 INVERTRECT
    END PAGE

    SET PAGE ORIENTATION DMORIENT_LANDSCAPE PAPERSIZE DMPAPER_A4 FONT "f0"
    CHANGE PEN "p2" STYLE PS_SOLID
    SELECT PEN "p2"
    SELECT FONT "f2"

    START PAGE
        CHANGE BRUSH "b0" COLOR 0xCCFFAA
        CHANGE PEN "P2" COLOR 0xff0000 WIDTH 5
        @0,0,HBPRNMAXROW,HBPRNMAXCOL RECTANGLE PEN "p2" BRUSH "b0"
        SET TEXTCOLOR 0xFF0000
        for j:=1 to 8
         if j%2==0
             CHANGE FONT "F2" size 45 nobold noitalic nounderline nostrikeout width 100
         else
             CHANGE FONT "F2" size 30 bold italic underline strikeout angle 10 width 50
         endif
         @j*5,5 SAY "This is a text. This is only a text." FONT "f2" TO PRINT
        next
    END PAGE

    SET PAGE ORIENTATION DMORIENT_PORTRAIT

    START PAGE
         SELECT FONT  "F0"
         SELECT PEN   "P0"
         SELECT BRUSH "B2"

         @1,7 say "IMAGELIST 1" COLOR 0xff to print
         for i:=1 to 20
              @i*2,2,(i+0.9)*2,6 draw imagelist "ILIST1" icon i
              @i*2,2,(i+0.9)*2,6 rectangle
              @i*2,7 SAY "Flag number "+str(i,2) to print
         next
         @1,1,43,22 RECTANGLE

         @1,45 say "IMAGELIST 2" COLOR 0xff to print
         @2,25 say "STYLE:" to print
         @3,25 say "NORMAL BLEND50 BLEND25 MASK  BACKGROUND" to print
         @4,54 say "GREEN" to print
         for i:=5 to 16
             @i,25,i+1,27 draw imagelist "ILIST2" icon I-4
             @i,32,i+1,34 draw imagelist "ILIST2" icon I-4 blend50
             @i,40,i+1,42 draw imagelist "ILIST2" icon I-4 blend25
             @i,48,i+1,50 draw imagelist "ILIST2" icon I-4 mask
             @i,54,i+1,56 draw imagelist "ILIST2" icon I-4 background rgb(0,255,0)
          next
          @1,24,17,65 RECTANGLE

          @19,24 SAY "JPG from resource (HMGPICTURE)" TO PRINT
          @20,24 PICTURE "PICTUREJPG" size 15,30

          @39,24 SAY "GIF from resource (HMGPICTURE)" TO PRINT
          @40,24 PICTURE "PICTUREGIF" size 5,30
      END PAGE

  END DOC

  RELEASE PRINTSYS

Return
