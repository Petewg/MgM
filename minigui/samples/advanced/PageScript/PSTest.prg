// -----------------------------------------------------------------------------------
// Copyright (c) 2000-2017 Pagescript32.com  ALL RIGHTS RESERVED.
// -----------------------------------------------------------------------------------
// Thanks to Grigory filatov for preparing of MiniGUI Ex demo
// -----------------------------------------------------------------------------------
// You could email at <support@pagescript32.com> for obtain a full version of DLL with
// a license number embedded in the PDF output.
// -----------------------------------------------------------------------------------

#include "PSCRIPT.CH"
#include "minigui.ch"

#define dbINV_MASTER 1
#define dbINV_DETAIL 2
#define CR           Chr(13)
#define LF           Chr(10)
#define CRLF         Chr(13) + Chr(10)
#define CRLF2        CRLF + CRLF
#define SOFTCR       Chr(141)
#define TICK         .1

#define PC_BOLDON    1
#define PC_BOLDOFF   2
#define PC_ITALICON  3
#define PC_ITALICOFF 4
#define PC_UNDERON   5
#define PC_UNDEROFF  6
#define PC_STRIKEON  7
#define PC_STRIKEOFF 8
#define PC_SET8CPI   9
#define PC_SET10CPI  10
#define PC_SET12CPI  11
#define PC_SET15CPI  12
#define PC_SET17CPI  13
#define PC_SET18CPI  14
#define PC_SET20CPI  15
#define PC_SET6LPI   16
#define PC_SET8LPI   17

#define PC_NORMAL    PC_SET10CPI
#define PC_COMPRESS  PC_SET17CPI

/*-----------------------------------------------------------------------------
Procedure ..: Main()
Description : PageScript 32 Main function (entry point)
-----------------------------------------------------------------------------*/
PROCEDURE main()

    SET FONT TO "Ms Sans Serif", 12

    DEFINE WINDOW Win_1 ;
        AT 0,0 ;
        WIDTH 640 ;
        HEIGHT 480 ;
        TITLE 'PageScript 32 test center' ;
        ICON 'MAIN' ;
        MAIN ;
        NOMINIMIZE NOMAXIMIZE NOSIZE ;
        ON INIT OnInit() ;
        ON RELEASE _dummy()

    END WINDOW

    CENTER WINDOW Win_1
    ACTIVATE WINDOW Win_1

RETURN

/*-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
PROCEDURE OnInit()

Local nChoice := 1
Local nDevice
Local nError
Local nFile   := 1
Local aTest   := {"PageScript 32 test page", ;
                  "Rotated text", ;
                  "Current page size", ;
                  "Pattern test", ;
                  "Printing an invoice", ;
                  "Bill of landing", ;
                  "Customer list example", ;
                  "Graphic example (Landscape)", ;
                  "Simulating plain text", ;
                  "Working with Pixels unit", ;
                  "TextBox demo", ;
                  "Barcode types", ;
                  "List all installed printers", ;
                  "Printer paper bins/trays list", ;
                  "Font list", ;
                  "Font size test", ;
                  "Printer capabilities", ;
                  "Ascii to Ansi test", ;
                  "Duplex test (Default printer must support)", ;
                  "Printing on Legal page size (Printer must have Legal paper)", ;
                  "Print RAW data on default printer", ;
                  "Print a document in EMULATION mode", ;
                  "Print text with default parameters", ;
                  "Print an encrypted PDF (Password = PageScript32)", ;
                  "Change Print Preview background color"}

Local aProc   := { {|| PSTestPage()          }, ;
                   {|| RotatedText()         }, ;
                   {|| MsgInfo(AbeePageSize()) }, ;
                   {|| AbeePatterns()        }, ;
                   {|| AbeeInvoice()         }, ;
                   {|| AbeePuroLater()       }, ;
                   {|| AbeeCustList()        }, ;
                   {|| AbeeGraphic()         }, ;
                   {|| AbeeText()            }, ;
                   {|| AbeePixels()          }, ;
                   {|| AbeeTextBox()         }, ;
                   {|| AbeeBarCode()         }, ;
                   {|| AbeePrinters()        }, ;
                   {|| AbeePaperBins()       }, ;
                   {|| AbeeFonts()           }, ;
                   {|| AbeePointSize()       }, ;
                   {|| AbeePrnCaps()         }, ;
                   {|| AbeeConvert()         }, ;
                   {|| AbeeDuplex()          }, ;
                   {|| AbeeLegal()           }, ;
                   {|| AbeeRawData()         }, ;
                   {|| AbeeEmuData()         }, ;
                   {|| AbeeAutoTextCoor()    }, ;
                   {|| AbeeEncryptedPDF()    }, ;
                   {|| AbeeChangePWColor()   }}

if (nError := PSInit()) == PSE_NOERROR

   Win_1.Title := "PageScript 32 version " + PSGetVersion()

   // Set the decimal separator. This is not necessary
   // since the default separator is already the period.
   PSSetDecimalSep(".")

   @ 5, 0 LABEL Label_1 ;
            OF Win_1 ;
            VALUE "PageScript 32 demo for Minigui Extended test center." ;
            WIDTH 630 ;
            HEIGHT 25 ;
            FONT "ARIAL" ;
            Size 12 ;
            CENTERALIGN ;

   @ 30, 0 LABEL Label_2 ;
            OF Win_1 ;
            VALUE "Select a test and press <Enter> key" ;
            WIDTH 630 ;
            HEIGHT 50 ;
            FONT "ARIAL" ;
            Size 12 ;
            CENTERALIGN ;

   DO WHILE .T.

      if (nChoice := AChoice(5, 4, 20, 63, aTest ,, nChoice)) == 0
         exit
      endif

      do case
         case nChoice == 8
            PSSetOrientation(APS_LANDSCAPE)

         case nChoice == 19
            PSSetDuplex(DMDUP_VERTICAL)

      endcase

      if nChoice == 21
         nDevice := DEV_PRINTER
      elseif nChoice == 24
         nDevice := DEV_PDFFILE
      elseif nChoice == 25
         Eval(aProc[nChoice])
         nDevice := 0
      else
         nDevice := SelectDevice()
      endif

      if nDevice > 0
         PSSetDevice(nDevice)

         if nChoice == 24
            PSSetFileName("Encrypted PDF document.pdf")
         elseif nDevice == DEV_PDFFILE
            PSSetFileName("Test" + AllTrim(Str(nFile, 3, 0)) + ".pdf")
         endif

         if nChoice != 21
            if PSPrintDialog()
               Eval(aProc[nChoice])
            endif
         else
            Eval(aProc[nChoice])
         endif

         if nDevice == DEV_PDFFILE .and. nChoice != 3 .and. nChoice != 24
            MsgInfo("Document saved in Test" + AllTrim(Str(nFile, 3, 0)) + ".pdf")
            nFile++
         endif

      endif

   ENDDO

   Win_1.Release

else

   do case
      case nError == PSE_DLLNOTLOADED
         MsgInfo("PageScript 32 DLL not loaded")

      case nError == PSE_NOTINITIALIZED
         MsgInfo("PageScript 32 not initialized")

      otherwise
         MsgInfo("Unknown error")

   endcase
endif

Return

/*-----------------------------------------------------------------------------
Procedure ..: PSTestPage()
Description : PageScript 32 test page
-----------------------------------------------------------------------------*/
Function PSTestPage()

Local nLoop
Local nLine    := 55
Local nR       := 255
Local nG       := 128
Local nB       := 0
Local cText    := "PageScript"
Local cRainbow := "Rainbow text with R G B"
Local aFonts   := {{ 97, APS_PLAIN     ,  6}, {101, APS_BOLD     , 8}, {106, APS_ITALIC   , 10}, ;
                   {110, APS_BOLDITALIC, 12}, {116, APS_UNDERLINE, 8}, {121, APS_STRIKEOUT, 10}}

PSBeginDoc(, "PageScript 32 test page", APS_PORTRAIT)

PSSetFont(APS_ARIAL, APS_BOLD, 10)

// Pattern test
@10, 10 TEXTOUT "Patterns"
for nLoop := APS_SOLID to APS_VERTICAL
   @15, (nLoop * 10) + 10 FRAME TO 25, (nLoop * 10) + 20  THICKNESS .5  COLOR APS_BLACK, APS_WHITE  PATTERN nLoop
next nLoop

@27.5, 10 LINE TO 27.5, 190  THICKNESS 1 COLOR APS_BLACK

// Clipper compatible color test
@30, 10 TEXTOUT "PageScript colors"
@33,163 FRAME TO 47,167  THICKNESS 0  COLOR APS_WHITE, APS_BLACK
@33,173 FRAME TO 47,177  THICKNESS 0  COLOR APS_WHITE, APS_BLACK

for nLoop := Abs(APS_BLACK) to Abs(APS_WHITE)
   @35, (nLoop * 10) FRAME TO 45, (nLoop * 10) + 10  THICKNESS .5  COLOR APS_BLACK, -nLoop
next nLoop

@35,170 FRAME TO 45,180  THICKNESS .5  COLOR APS_BLACK, APS_NONE

@47.5, 10 LINE TO 47.5, 190  THICKNESS 1 COLOR APS_BLACK

// RGB color test
@50, 10 TEXTOUT "RGB colors"
for nLoop := 1 to 255 step 5
   PSLine(nLine, 10, nLine,  30, 2, RGB(nR, nG, nB))
   PSLine(nLine, 35, nLine,  55, 2, RGB(nR, nB, nG))
   PSLine(nLine, 60, nLine,  80, 2, RGB(nG, nB, nR))
   PSLine(nLine, 85, nLine, 105, 2, RGB(nG, nR, nB))
   PSLine(nLine,110, nLine, 130, 2, RGB(nB, nG, nR))
   PSLine(nLine,135, nLine, 155, 2, RGB(nB, nR, nG))
   nLine += .5
   nR -= 5
   nG += 2
   nB += 5
next nLoop

@82.5, 10 LINE TO 82.5, 190  THICKNESS 1  COLOR APS_BLACK

// Various fonts test
@85, 10 TEXTOUT "Some fonts"
@90, 10 FRAME TO  95, 190  THICKNESS  0  COLOR APS_WHITE, APS_BLACK
@95, 10 FRAME TO 125,  40  THICKNESS  0  COLOR APS_WHITE, APS_BLACK

for nLoop := 100 to 125 step 5
   @nLoop, 10 LINE TO nLoop, 190  THICKNESS .75 COLOR APS_BLACK
next nLoop

for nLoop := 95 to 125 step 5
   @nLoop, 10 LINE TO nLoop, 40   THICKNESS  1  COLOR APS_WHITE
next nLoop

for nLoop := 70 to 190 step 30
   @90, nLoop LINE TO 125, nLoop  THICKNESS .75 COLOR APS_BLACK
next nLoop

for nLoop := 40 to 160 step 30
   @90, nLoop LINE TO  95, nLoop  THICKNESS  1  COLOR APS_WHITE
next nLoop

PSSetFont(APS_ARIAL, APS_BOLD, 8, APS_WHITE)
PSSetJustify(APS_CENTER)

@ 91, 25 TEXTOUT "Font point and style"
@ 91, 55 TEXTOUT "System"
@ 91, 85 TEXTOUT "Courier"
@ 91,115 TEXTOUT "Arial"
@ 91,145 TEXTOUT "Times"
@ 91,175 TEXTOUT "Verdana"

@ 96, 25 TEXTOUT "Plain 6 points"
@101, 25 TEXTOUT "Bold 8 points"
@106, 25 TEXTOUT "Italic 10 points"
@111, 25 TEXTOUT "Bold Italic 12 points"
@116, 25 TEXTOUT "Underline 8 points"
@121, 25 TEXTOUT "StrikeOut 10 points"

PSSetJustify(APS_LEFT)

for nLoop := 1 to 6
   PSSetFont(, aFonts[nLoop, 2], aFonts[nLoop, 3], APS_BLACK)
   @aFonts[nLoop, 1], 41 TEXTOUT cText FONT APS_SYSTEM
   @aFonts[nLoop, 1], 71 TEXTOUT cText FONT APS_COURIER
   @aFonts[nLoop, 1],101 TEXTOUT cText FONT APS_ARIAL
   @aFonts[nLoop, 1],131 TEXTOUT cText FONT APS_TIMES
   @aFonts[nLoop, 1],161 TEXTOUT cText FONT APS_VERDANA
next nLoop

@126.5, 10 LINE TO 126.5, 190  THICKNESS 1  COLOR APS_BLACK

// Shapes and bitmap test
PSSetFont(APS_ARIAL, APS_BOLD, 10, APS_BLACK)  // Resets the font properties
@128, 10 TEXTOUT "Shapes (Oval, Rectangle, Line)"
@220, 10 TEXTOUT "Text rotation, size and colors"

@133, 10 FRAME   TO 167, 60   THICKNESS 0  COLOR APS_NONE , APS_MAGENTA  PATTERN APS_FDIAGONAL
@140, 77 FRAME   TO 160, 123  THICKNESS 0  COLOR APS_NONE , APS_BLUE

@135, 80 ELLIPSE TO 165, 120  THICKNESS 2  COLOR APS_BLUE , APS_MAGENTA  PATTERN APS_CROSS
@135,130 ELLIPSE TO 165, 160  THICKNESS 4  COLOR APS_RED  , APS_YELLOW   PATTERN APS_SOLID

@140,170 FRAME   TO 160, 190  THICKNESS 2  COLOR APS_BCYAN, APS_BLUE     PATTERN APS_FDIAGONAL
@140,170 LINE    TO 160, 190  THICKNESS 2  COLOR APS_RED
@160,170 LINE    TO 140, 190  THICKNESS 2  COLOR APS_GREEN

@172, 10 LINE    TO 172, 190  THICKNESS 1  COLOR APS_BLACK
@175, 10 TEXTOUT "Bitmaps and JPEGs images"

PSSetFont(APS_ARIAL, APS_PLAIN, 8, APS_BLACK)
@180, 10 TEXTOUT "Natural size"
@180, 50 TEXTOUT "Stretched"
@180,100 TEXTOUT "Calculated Width"  
@210,143 TEXTOUT "Calculated Height" ANGLE 90

PSBitmap(185,  10,   0,   0, "\" + CurDir() + "\LOGOABEE.BMP") // Natural size
PSBitmap(185,  50, 195,  80, "\" + CurDir() + "\LOGOABEE.BMP") // Stretch
PSBitmap(185, 100, 215,   0, "\" + CurDir() + "\PS4.JPG")      // Calculated Width
PSBitmap(185, 150,   0, 180, "\" + CurDir() + "\PS4.JPG")      // Calculated Height

@218, 10 LINE    TO 218, 190  THICKNESS 1  COLOR APS_BLACK

// Font roration, size and color
@250, 10 TEXTOUT "Text rotated at 90∞" ANGLE 90

for nLoop := 0 to 330 step 30
   @240, 30 TEXTOUT "        Rotation" SIZE 6 ANGLE nLoop
next nLoop

nLine := 225
for nLoop := 6 to 8 step .25
   @nLine, 50 TEXTOUT "Font size = " + LTrim(Str(nLoop, 5, 2)) SIZE nLoop
   nLine += 3
next nLoop

@220, 80 TEXTOUT "PageScript colors"

nLine := 225
for nLoop := Abs(APS_BLACK) to Abs(APS_PALEGRAY)
   @nLine, 80  TEXTOUT " Colored text " SIZE 7  STYLE APS_BOLD  COLOR -(nLoop), RGB(nLoop * 25 + 25, nLoop * 15 + 35, nLoop * 10 + 120)
   @nLine, 100 TEXTOUT " Colored text " SIZE 7  STYLE APS_BOLD  COLOR -(nLoop + 8), RGB(nLoop * 15 + 50, nLoop * 10 + 75, nLoop * 35 + 40)
   nLine += 3.5
next nLoop

nR := 255
nG := 128
nB := 0

@220, 125 TEXTOUT "RGB colors"

for nLoop := 0 to (Len(cRainbow) - 1)
   @225,125 + (nLoop * 2.5) TEXTOUT SubStr(cRainbow, nLoop + 1, 1) SIZE 10  STYLE APS_BOLD  COLOR RGB(nR, nG, nB)
   @230,125 + (nLoop * 2.5) TEXTOUT SubStr(cRainbow, nLoop + 1, 1) SIZE 10  STYLE APS_BOLD  COLOR RGB(nR, nB, nG)
   @235,125 + (nLoop * 2.5) TEXTOUT SubStr(cRainbow, nLoop + 1, 1) SIZE 10  STYLE APS_BOLD  COLOR RGB(nG, nR, nB)
   @240,125 + (nLoop * 2.5) TEXTOUT SubStr(cRainbow, nLoop + 1, 1) SIZE 10  STYLE APS_BOLD  COLOR RGB(nG, nB, nR)
   @245,125 + (nLoop * 2.5) TEXTOUT SubStr(cRainbow, nLoop + 1, 1) SIZE 10  STYLE APS_BOLD  COLOR RGB(nB, nR, nG)
   nR -= 15
   nG += 20
   nB += 15
next nLoop

PSEndDoc()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: RotatedText()
Description : Rotated text sample
Author .....: Stephan St-Denis
Date .......: September 2000
-----------------------------------------------------------------------------*/
Static Function RotatedText()

Local nLoop := 0

PSBeginDoc(, "Rotated text sample", APS_PORTRAIT)

   PSSetFont(APS_ARIAL, APS_BOLD, 4)

   @100, 100 TEXTOUT "X"
   for nLoop := 0 to 345 step 15
      @100, 100 TEXTOUT "            Rotated text is easy using PageScript !" ANGLE nLoop
   next nLoop

   @200, 100 TEXTOUT "X" JUSTIFY APS_CENTER
   for nLoop := 0 to 345 step 15
      @200, 100 TEXTOUT "            Rotated text is easy using PageScript !" ANGLE nLoop JUSTIFY APS_CENTER
   next nLoop

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeePageSize()
Description : Return current printer page size
Author .....: Stephan St-Denis
Date .......: April 2001
-----------------------------------------------------------------------------*/
Static Function AbeePageSize()

Local  nPaper
Static aPaper := { ;
   "LETTER", ;
   "LETTERSMALL", ;
   "TABLOID", ;
   "LEDGER", ;
   "LEGAL", ;
   "STATEMENT", ;
   "EXECUTIVE", ;
   "A3", ;
   "A4", ;
   "A4SMALL", ;
   "A5", ;
   "B4", ;
   "B5", ;
   "FOLIO", ;
   "QUARTO", ;
   "10X14", ;
   "11X17", ;
   "NOTE", ;
   "ENV_9", ;
   "ENV_10", ;
   "ENV_11", ;
   "ENV_12", ;
   "ENV_14", ;
   "CSHEET", ;
   "DSHEET", ;
   "ESHEET", ;
   "ENV_DL", ;
   "ENV_C5", ;
   "ENV_C3", ;
   "ENV_C4", ;
   "ENV_C6", ;
   "ENV_C65", ;
   "ENV_B4", ;
   "ENV_B5", ;
   "ENV_B6", ;
   "ENV_ITALY", ;
   "ENV_MONARCH", ;
   "ENV_PERSONAL", ;
   "FANFOLD_US", ;
   "FANFOLD_STD_GERMAN", ;
   "FANFOLD_LGL_GERMAN", ;
   "ISO_B4", ;
   "JAPANESE_POSTCARD", ;
   "9X11", ;
   "10X11", ;
   "15X11", ;
   "ENV_INVITE", ;
   "RESERVED_48", ;
   "RESERVED_49", ;
   "LETTER_EXTRA", ;
   "LEGAL_EXTRA", ;
   "TABLOID_EXTRA", ;
   "A4_EXTRA", ;
   "LETTER_TRANSVERSE", ;
   "A4_TRANSVERSE", ;
   "LETTER_EXTRA_TRANSVERSE", ;
   "A_PLUS", ;
   "B_PLUS", ;
   "LETTER_PLUS", ;
   "A4_PLUS", ;
   "A5_TRANSVERSE", ;
   "B5_TRANSVERSE", ;
   "A3_EXTRA", ;
   "A5_EXTRA", ;
   "B5_EXTRA", ;
   "A2", ;
   "A3_TRANSVERSE", ;
   "A3_EXTRA_TRANSVERSE"}

nPaper := PSGetPageSize()

if nPaper > Len(aPaper)
   Return "UNDEFINED"
endif

Return aPaper[nPaper]

/*-----------------------------------------------------------------------------
Function ...: AbeePatterns()
Description : Patterns test
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Static Function AbeePatterns()

Local nLoop

PSBeginDoc(, "Abee PageScript Patterns test", APS_PORTRAIT)
   @10, 25 LINE    TO 150, 25  THICKNESS 1  COLOR APS_BLACK

   for nLoop := APS_SOLID to APS_VERTICAL
      @15, (nLoop * 10) + 10 FRAME TO 25, (nLoop * 10) + 20  THICKNESS .5  COLOR APS_BLACK, APS_WHITE  PATTERN nLoop
      @30, (nLoop * 10) + 10 FRAME TO 40, (nLoop * 10) + 20  THICKNESS .5  COLOR APS_RED  , APS_BLUE   PATTERN nLoop
      @45, (nLoop * 10) + 10 FRAME TO 55, (nLoop * 10) + 20  THICKNESS .5  COLOR APS_GREEN, APS_YELLOW PATTERN nLoop
      @60, (nLoop * 10) + 10 FRAME TO 70, (nLoop * 10) + 20  THICKNESS .5  COLOR APS_BLACK, APS_NONE   PATTERN nLoop
      @75, (nLoop * 10) + 10 FRAME TO 85, (nLoop * 10) + 20  THICKNESS .5  COLOR APS_NONE , APS_BLACK  PATTERN nLoop
   next nLoop

PSEndDoc()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeInvoice()
Description : Invoice example
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function AbeeInvoice()

dbSelectArea(dbINV_DETAIL)
use InvDetai exclusive

dbSelectArea(dbINV_MASTER)
use InvMaste exclusive

BEGINDOC WITH 0 TITLE "Abee invoice" ORIENTATION APS_PORTRAIT
   PSSetDecimalSep(".")

   // Default unit = milimeters
   PSFrame(10, 140, 20, 200, 0, , APS_PALEGRAY)
   PSFrame(25, 155, 35, 190, 0, , APS_PALEGRAY)

   // WARNING : Make sure that this is a valid path
   PSBitmap(10, 10, 32, 85, "\" + CurDir() + "\LOGOABEE.BMP", , .t.)
   
   PSFrame( 73,  10,  80, 206, 0, , APS_PALEGRAY)
   PSFrame( 86,  10,  92, 206, 0, , APS_PALEGRAY)
   PSFrame( 99,  10, 105, 206, 0, , APS_PALEGRAY)
   PSFrame(215,  10, 265, 130, 0, , APS_PALEGRAY)
   
   PSLine( 73,   10,  73, 206, .5, APS_BLUE)
   PSLine( 80,   10,  80, 206, .5, APS_BLACK)
   PSLine( 86,   10,  86, 206, .5, APS_BLACK)
   PSLine( 92,   10,  92, 206, .5, APS_BLACK)
   PSLine( 99,   10,  99, 206, .5, APS_BLACK)
   PSLine(105,   10, 105, 206, .5, APS_BLACK)
   PSLine(215,   10, 215, 206, .5, APS_BLACK)
   PSLine(265,   10, 265, 206, .5, APS_BLACK)
   
   PSLine(215,  130, 215, 206, .5, APS_BLACK)
   PSLine(223,  130, 223, 206, .5, APS_BLACK)
   PSLine(231,  130, 231, 206, .5, APS_BLACK)
   PSLine(240,  130, 240, 206, .5, APS_BLACK)
   PSLine(248,  130, 248, 206, .5, APS_BLACK)
   PSLine(257,  130, 257, 206, .5, APS_BLACK)
   
   PSLine(215,  130, 265, 130, .5, APS_BLACK)
   PSLine(215,  169, 265, 169, .5, APS_BLACK)
   
   PSLine( 73,   10, 265,  10, .5, APS_BLACK)
   PSLine( 73,  206, 265, 206, .5, APS_BLACK)
   
   PSLine( 73,   30,  86,  30, .5, APS_BLACK)
   PSLine( 73,   70,  86,  70, .5, APS_BLACK)
   PSLine( 73,  124,  86, 124, .5, APS_BLACK)
   PSLine( 73,  165,  86, 165, .5, APS_BLACK)
   
   PSLine( 86,   81,  99,  81, .5, APS_BLACK)
   PSLine( 86,  125,  99, 125, .5, APS_BLACK)
   PSLine( 86,  156,  99, 156, .5, APS_BLACK)
   PSLine( 86,  177,  99, 177, .5, APS_BLACK)
   
   PSLine( 99,  123, 105, 123, .5, APS_BLACK)
   PSLine( 99,  151, 105, 151, .5, APS_BLACK)
   PSLine( 99,  179, 105, 179, .5, APS_BLACK)
   
   PSSetFont(APS_TIMES,, 8, APS_BLACK)
   @ 12,170 TEXTOUT "INVOICE"            JUSTIFY APS_CENTER  FONT APS_ARIAL  STYLE APS_BOLD  POINT 14
   @ 28,158 TEXTOUT "No"                 FONT APS_ARIAL
   @ 13,90  TEXTOUT "Working"
   @ 16,90  TEXTOUT "like bees,"
   @ 19,90  TEXTOUT "to bring you"
   @ 22,90  TEXTOUT "the best software."
   @ 33,50  TEXTOUT "70, de la Gare Street, St.Jerome, (Quebec), Canada, J7Z 2B8"  JUSTIFY APS_CENTER
   @ 36,50  TEXTOUT "Phone: 555 555-5555 - Fax: (555) 555-5550"                    JUSTIFY APS_CENTER
   
   PSSetFont(APS_ARIAL,, 7)
   @ 75, 20 TEXTOUT "CUSTOMER #"         JUSTIFY APS_CENTER
   @ 75, 52 TEXTOUT "PURCHASE ORDER #"   JUSTIFY APS_CENTER
   @ 75, 98 TEXTOUT "SHIP VIA"           JUSTIFY APS_CENTER
   @ 75,145 TEXTOUT "PHONE #"            JUSTIFY APS_CENTER
   @ 75,185 TEXTOUT "FAX #"              JUSTIFY APS_CENTER
   
   @ 88, 45 TEXTOUT "SALESPERSON"        JUSTIFY APS_CENTER
   @ 88,103 TEXTOUT "TERMS"              JUSTIFY APS_CENTER
   @ 88,140 TEXTOUT "DATE"               JUSTIFY APS_CENTER
   @ 88,167 TEXTOUT "OUR ORDER #"        JUSTIFY APS_CENTER
   @ 88,191 TEXTOUT "SHIP DATE"          JUSTIFY APS_CENTER
   
   @101, 75 TEXTOUT "DESCRIPTION"        JUSTIFY APS_CENTER
   @101,138 TEXTOUT "QTY"                JUSTIFY APS_CENTER
   @101,165 TEXTOUT "UNIT PRICE"         JUSTIFY APS_CENTER
   @101,192 TEXTOUT "EXTENSION"          JUSTIFY APS_CENTER
   
   @218,150 TEXTOUT "SUB-TOTAL"          JUSTIFY APS_CENTER
   @226,150 TEXTOUT "SALES TAX 1"        JUSTIFY APS_CENTER
   @234,150 TEXTOUT "SALES TAX 2"        JUSTIFY APS_CENTER
   @243,150 TEXTOUT "TOTAL"              JUSTIFY APS_CENTER
   @252,150 TEXTOUT "AMOUNT RECEIVED"    JUSTIFY APS_CENTER
   @260,150 TEXTOUT "BALANCE DUE"        JUSTIFY APS_CENTER

   InvoiceHeader()  // Print the header
   InvoiceDetail()  // Print the detail
   InvoiceTotal()   // Print the total

ENDDOC

dbCloseAll()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: InvoiceHeader()
Description : Print the invoice header section
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function InvoiceHeader()

PSSetFont(APS_ARIAL, APS_PLAIN, 10, APS_BLACK, APS_NONE)

PSSetJustify(APS_LEFT)
@28,165 TEXTOUT dbINV_MASTER->invoice  picture "999999"  STYLE APS_BOLD
@45,20  TEXTOUT dbINV_MASTER->name
@50,20  TEXTOUT dbINV_MASTER->address1
@55,20  TEXTOUT dbINV_MASTER->address2
@60,20  TEXTOUT dbINV_MASTER->address3

PSSetJustify(APS_CENTER)
@81,20  TEXTOUT AllTrim(dbINV_MASTER->custno)  POINT 8
@81,50  TEXTOUT AllTrim(dbINV_MASTER->orderno)
@81,95  TEXTOUT AllTrim(dbINV_MASTER->shipvia)
@81,145 TEXTOUT dbINV_MASTER->phone    picture "@R (999) 999-9999"
@81,185 TEXTOUT dbINV_MASTER->fax      picture "@R (999) 999-9999"

@94,45  TEXTOUT AllTrim(dbINV_MASTER->sales)
@94,103 TEXTOUT AllTrim(dbINV_MASTER->terms)
@94,140 TEXTOUT Date()
@94,168 TEXTOUT dbINV_MASTER->ourno    picture "999999"
@94,190 TEXTOUT dbINV_MASTER->shipdate

Return NIL

/*-----------------------------------------------------------------------------
Function ...: InvoiceDetail()
Description : Print the invoice detail section
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function InvoiceDetail()

Local nLine := 107

PSSetFont(APS_ARIAL, APS_PLAIN, 10, APS_BLACK, APS_NONE)

while ! dbINV_DETAIL->(Eof())
   @nLine,15  TEXTOUT dbINV_DETAIL->descrip                                             JUSTIFY APS_LEFT
   @nLine,145 TEXTOUT dbINV_DETAIL->qty                            PICTURE "99,999.99"  JUSTIFY APS_DECIMAL
   @nLine,173 TEXTOUT dbINV_DETAIL->unitprice                      PICTURE "99,999.99"  JUSTIFY APS_DECIMAL
   @nLine,200 TEXTOUT dbINV_DETAIL->qty * dbINV_DETAIL->unitprice  PICTURE "99,999.99"  JUSTIFY APS_DECIMAL

   dbINV_DETAIL->(dbSkip())

   nLine += 4

   if nLine > 210 .and. ! dbINV_DETAIL->(Eof())
      InvoiceHeader()
      nLine := 107
   endif
enddo

Return NIL

/*-----------------------------------------------------------------------------
Function ...: InvoiceTotal()
Description : Print the invoice total section
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function InvoiceTotal()

PSSetFont(APS_ARIAL, APS_PLAIN, 10, APS_BLACK, APS_NONE)

PSSetJustify(APS_DECIMAL)
@218,200 TEXTOUT "999,999.99"
@226,200 TEXTOUT "999,999.99"
@234,200 TEXTOUT "999,999.99"
@243,200 TEXTOUT "999,999.99"
@252,200 TEXTOUT "999,999.99"
@260,200 TEXTOUT "999,999.99"

PSSetJustify(APS_LEFT)
@220,15  TEXTOUT "Abeelabs Systems inc. is working hard to make programmer's"
@225,15  TEXTOUT "life easier"

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeePuroLater()
Description : A bill of Lading example with a bit of humour.
Author .....: Stephan St-Denis
Date .......: April 2000
-----------------------------------------------------------------------------*/
Static Function AbeePuroLater()

Local nLoop
Local cText := "Paradise is engineered on Vos, the hidden sister planet of Earth that " + ;
               "orbits the sun directly opposite our own planet; sirens and satyrs dance " + ;
               "to the music of love and bounty; the seer arrives to warn of the approaching " + ;
               "Dark and is ignored. Los the Irrational attempts to stifle the music; " + ;
               "the sirens and satyrs are concerned, but are too apathetic to act; the music " + ;
               "wheel on which Vos rotates grinds to a halt; the birds and insects leave " + ;
               "Paradise; the Darkness begins. Many sirens and satyrs perish in the frigid " + ;
               "Darkness; Emau stumbles across a hollow reed in the forests and creates music; " + ;
               "Los the Irrational battles Emau with Silence; Emau triumphs; light returns to Paradise."

BEGINDOC WITH 0 TITLE "Bill of Lading example"  ORIENTATION APS_PORTRAIT
    PSSetUnit(APS_MILL)

   // Puro Logo
   PSBitmap(15, 8, 22, 50, "\" + CurDir() + "\PUROLOGO.BMP")

   // Top/Left Two frames
   PSFrame(25,  8,  62, 100, 2, APS_BLACK, APS_WHITE, APS_SOLID)
   PSFrame(65,  8, 112, 100, 2, APS_BLACK, APS_WHITE, APS_SOLID)

   @ 27, 55 TEXTOUT "SENDER (FROM)"          FONT APS_ARIAL  SIZE 8                   JUSTIFY APS_CENTER
   @ 33, 10 TEXTOUT "AbeeLabs Systems Inc."  FONT APS_ARIAL  SIZE 8   STYLE APS_BOLD
   @ 37, 10 TEXTOUT "70, de la Gare Street"  FONT APS_ARIAL  SIZE 8   STYLE APS_BOLD
   @ 42, 10 TEXTOUT "St. Jerome, Quebec"     FONT APS_ARIAL  SIZE 8   STYLE APS_BOLD
   @ 51, 10 TEXTOUT "J7Z 2B8"                FONT APS_ARIAL  SIZE 8   STYLE APS_BOLD
   @ 56, 10 TEXTOUT "(999) 555-5555"         FONT APS_ARIAL  SIZE 8   STYLE APS_BOLD

   @ 67, 55 TEXTOUT "RECEIVER (TO)"          FONT APS_ARIAL  SIZE 10                  JUSTIFY APS_CENTER
   @ 72, 10 TEXTOUT "Liza Peabody"           FONT APS_ARIAL  SIZE 14  STYLE APS_BOLD
   @ 78, 10 TEXTOUT "Mistral Floors Ltd."    FONT APS_ARIAL  SIZE 14  STYLE APS_BOLD
   @ 84, 10 TEXTOUT "2211, Industrial blvd." FONT APS_ARIAL  SIZE 14  STYLE APS_BOLD
   @ 95, 10 TEXTOUT "Springfield, Ill 24551" FONT APS_ARIAL  SIZE 14  STYLE APS_BOLD
   @101, 10 TEXTOUT "(888) 555-1111"         FONT APS_ARIAL  SIZE 14  STYLE APS_BOLD

   @ 10,112 TEXTOUT "PACKAGE I.D. NO."       FONT APS_ARIAL  SIZE 8
   @  8,143 TEXTOUT "7 0 3  8 2 3  8 7 3 4"  FONT APS_ARIAL  SIZE 16  STYLE APS_BOLD
   @ 18,60  TEXTOUT "0 1 5 1 8 1 6 9 6"      FONT APS_ARIAL  SIZE 14  STYLE APS_BOLD
   @ 25,120 TEXTOUT "BILL CHARGES TO"        FONT APS_ARIAL  SIZE 8                   JUSTIFY APS_CENTER
   @ 25,145 TEXTOUT "TOTAL WEIGHT"           FONT APS_ARIAL  SIZE 8                   JUSTIFY APS_CENTER
   @ 25,170 TEXTOUT "PIECES"                 FONT APS_ARIAL  SIZE 8                   JUSTIFY APS_CENTER
   @ 25,192 TEXTOUT "DATE"                   FONT APS_ARIAL  SIZE 8                   JUSTIFY APS_CENTER

   @ 29,145 TEXTOUT "SUBJECT TO AUDIT"       FONT APS_ARIAL  SIZE 6                   JUSTIFY APS_CENTER
   @ 29,192 TEXTOUT "MO  DAY  YEAR"          FONT APS_ARIAL  SIZE 6                   JUSTIFY APS_CENTER

   @ 34,120 TEXTOUT "RECEIVER"               FONT APS_ARIAL  SIZE 10  STYLE APS_BOLD  JUSTIFY APS_CENTER
   @ 34,145 TEXTOUT "1 POUND"                FONT APS_ARIAL  SIZE 10  STYLE APS_BOLD  JUSTIFY APS_CENTER
   @ 34,170 TEXTOUT "1 OF 1"                 FONT APS_ARIAL  SIZE 10  STYLE APS_BOLD  JUSTIFY APS_CENTER
   @ 34,192 TEXTOUT Date()                   FONT APS_ARIAL  SIZE 10  STYLE APS_BOLD  JUSTIFY APS_CENTER

   @ 45,155 TEXTOUT "SERVICE OPTIONS"        FONT APS_ARIAL  SIZE 11  STYLE APS_BOLD + APS_ITALIC  JUSTIFY APS_CENTER

   @109,135 TEXTOUT "PIN"                    FONT APS_ARIAL  SIZE 6                   JUSTIFY APS_CENTER
   @108,160 TEXTOUT "7 0 3  8 2 3  8 7 3 4"  FONT APS_ARIAL  SIZE 10                  JUSTIFY APS_CENTER

   @115, 14 TEXTOUT "UNICODE"                FONT APS_ARIAL  SIZE 6                   JUSTIFY APS_CENTER
   @115, 60 TEXTOUT "AIRPORT CODE"           FONT APS_ARIAL  SIZE 6                   JUSTIFY APS_CENTER
   @115, 95 TEXTOUT "SERVICE GARANTEE"       FONT APS_ARIAL  SIZE 6                   JUSTIFY APS_CENTER

   @125, 14 TEXTOUT "32"                     FONT APS_ARIAL  SIZE 36  STYLE APS_BOLD  JUSTIFY APS_CENTER
   @141,205 TEXTOUT "45333 4.0000426033411"  FONT APS_ARIAL  SIZE 6                   JUSTIFY APS_RIGHT
   @143,  8 TEXTOUT "Fold this Bill of Lading on the dotted line and insert it into the labelope. Attach a Bill of Lading to each package." ;
                                             FONT APS_ARIAL  SIZE 8   STYLE APS_BOLD

   PSBarCode(112, 110, "A7038238734", 64, 1, .f., APS_BC39)

   for nLoop := 8 to 205 step 2
      PSLine(140, nLoop, 140, nLoop + 1, 1, APS_BLACK)
   next nLoop

   @157,  8 TEXTOUT "Description :"          FONT APS_ARIAL  SIZE 8   STYLE APS_BOLD
   PSLine(160, 27, 160, 115, 1, APS_BLACK)
   @162,  8 TEXTOUT "No Declared Value Entered in Software By Sender" FONT APS_ARIAL  SIZE 8   STYLE APS_BOLD

   @176,107 TEXTOUT "TRANSPORTATION CONDITIONS"                       FONT APS_ARIAL  SIZE 8   STYLE APS_BOLD  JUSTIFY APS_CENTER

   @180, 8 TO 192, 205 TEXTBOX "1)  " + cText  FONT APS_ARIAL  SIZE 7  COLOR APS_BLACK, APS_NONE
   @193, 8 TO 205, 205 TEXTBOX "2)  " + cText  FONT APS_ARIAL  SIZE 7  COLOR APS_BLACK, APS_NONE
   @206, 8 TO 212, 205 TEXTBOX "3)  " + cText  FONT APS_ARIAL  SIZE 7  COLOR APS_BLACK, APS_NONE
   @213, 8 TO 216, 205 TEXTBOX "4)  " + cText  FONT APS_ARIAL  SIZE 7  COLOR APS_BLACK, APS_NONE
   @218, 8 TO 230, 205 TEXTBOX "5)  " + cText  FONT APS_ARIAL  SIZE 7  COLOR APS_BLACK, APS_NONE
   @231, 8 TO 238, 205 TEXTBOX "6)  " + cText  FONT APS_ARIAL  SIZE 7  COLOR APS_BLACK, APS_NONE
   @239, 8 TO 254, 205 TEXTBOX "7)  " + cText  FONT APS_ARIAL  SIZE 7  COLOR APS_BLACK, APS_NONE

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeCustList()
Description : Customer list example
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function AbeeCustList()

Local nRow     := 7
Local nPage    := 1

use customer exclusive

// Add a watermark. Print it in the background
PSWaterMark({|| WaterMark()}, .f.)
PSSetPageSize(DMPAPER_LETTER)

PSBeginDoc(, "Customer list", APS_PORTRAIT)

   PSSetUnit(APS_TEXT)
   PSSetFont(APS_COURIER, APS_PLAIN, 12, APS_BLACK, APS_NONE)

   nRow := CustHeader(nPage)
   
   while ! Eof()
   
      PSTextOut(nRow  , 0, field->custno,, APS_LEFT)
      PSTextOut(nRow  ,11, field->name)
      PSTextOut(nRow+1,11, field->address1)
      PSTextOut(nRow+2,11, field->address2)
      PSTextOut(nRow+3,11, field->address3)
      PSTextOut(nRow  ,51, field->phone   , "@R (999) 999-9999")
      PSTextOut(nRow+1,51, field->fax     , "@R (999) 999-9999")
      PSTextOut(nRow  ,78, field->due     , "999,999,999.99", APS_DECIMAL)
      PSLine(nRow + 4.5, 0, nRow + 4.5, 80, .5, APS_BLACK)
      nRow += 5
   
      if nRow > 58
         PSNewPage()
         nPage++
         nRow := CustHeader(nPage)
      endif
   
      dbSkip()
   
   enddo

PSEndDoc()

PSSetPageSize(DMPAPER_LETTER)

// Disable watermark.
PSWaterMark()

dbCloseAll()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: CustHeader(<n>) -> nRow
Description : Prints the customer list header
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function CustHeader(nPage)

PSTextOut(0 , 0, Date())
PSTextOut(0 ,70, "Page : " + Str(nPage, 3, 0))
PSTextOut(0 ,39, "Your company name here",, APS_CENTER)
PSTextOut(2 ,39, "Customer list in no particular order",, APS_CENTER)
PSTextOut(4 , 0, "Cust. No   Name and address                           Phone/Fax       Amount due")

PSLine(3.25, 0, 3.25, 80, .5, APS_BLACK)
PSLine(5.50, 0, 5.50, 80,  1, APS_BLACK)

Return 7

/*-----------------------------------------------------------------------------
Function ...: WaterMark() -> NIL
Description : Prints the watermark in the background of each page
Author .....: Stephan St-Denis
Date .......: April 2000
-----------------------------------------------------------------------------*/
Function WaterMark()

Local nOldUnit := PSGetUnit()

PSSetUnit(APS_MILL)

@140, 107 TEXTOUT "WATERMARK"  FONT APS_ARIAL  SIZE 36  STYLE APS_BOLD + APS_ITALIC  JUSTIFY APS_CENTER  COLOR APS_PALEGRAY

PSSetUnit(nOldUnit)

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeGraphic()
Description : Using Abee PageScript capabilities to print good looking graphics
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function AbeeGraphic()

Local nLoop
Local nScale := 120000
Local nLine  := 68
Local aAmnt  := {72152, 55269, 117698, 92658, 69856, 19251, 115632, 98556, 94630, 72335, 31827, 5958}

PSBeginDoc(, "Graph test")

   PSFrame(25, 30, 190, 245, 4, APS_BLACK, APS_WHITE, APS_SOLID)
   PSLine(40, 60, 160, 60, 1, APS_BLACK)

   @30 ,140 TEXTOUT "Salesperson : Steve Von Denis" FONT APS_ARIAL;
            POINT 14  STYLE APS_BOLD  JUSTIFY APS_CENTER  COLOR APS_BLACK

   @170,140 TEXTOUT "Months" FONT APS_ARIAL;
            POINT 14  STYLE APS_BOLD  JUSTIFY APS_CENTER  COLOR APS_BLACK

   for nLoop := 40 to 160 step 10
      PSLine(nLoop, 58, nLoop, 235, 1, APS_BLACK)
      @nLoop-2,55 TEXTOUT TransForm(nScale, "999,999") + " $"  JUSTIFY APS_RIGHT  FONT APS_ARIAL
      nScale -= 10000
   next nLoop

   for nLoop := 1 to 12
      PSLine(160, nLine, 162, nLine, 1, APS_BLACK)
      @165,nLine TEXTOUT LTrim(Str(nLoop, 2, 0)) JUSTIFY APS_CENTER  FONT APS_ARIAL
      PSFrame(160, nLine - 3, CalcTop(aAmnt[nLoop]), nLine + 3, 1, APS_BLACK, -(nLoop + 1), APS_SOLID)
      nLine += 15
   next nLoop

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeText()
Description : Simulating a plain text report
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function AbeeText()

Local nRow
Local nPos
Local nWidth
Local S1 := 'This is a test to calculate'
Local S2 := 'the width of a string.'

PSBeginDoc(, "Simulating a plain text report")

PSSetUnit(APS_TEXT)
PSSetCPI(10)

PSTextOut(0, 0, '00000000001111111111222222222233333333334444444444555555555566666666667777777777')
PSTextOut(1, 0, '01234567890123456789012345678901234567890123456789012345678901234567890123456789')

for nRow := 3 to 6
   PSTextOut(nRow, 0, 'Text coordinate system. Printed at 10 CPI and 6 LPI (the defaults)')
next nRow

PSSetCPI(8)
PSTextOut( 8,  0, 'Testing at 8 CPI')

PSSetCPI(10)
PSTextOut( 9,  0, 'Testing at 10 CPI')

PSSetCPI(12)
PSTextOut(10,  0, 'Testing at 12 CPI')

PSSetCPI(15)
PSTextOut(11,  0, 'Testing at 15 CPI')

PSSetCPI(16)
PSTextOut(12,  0, 'Testing at 16 CPI (simulating condensed on certain printers)')

PSSetCPI(17)
PSTextOut(13,  0, 'Testing at 17 CPI (simulating condensed on certain printers)')

PSSetCPI(18)
PSTextOut(14,  0, 'Testing at 18 CPI')

PSSetCPI(20)
PSTextOut(15, 0, 'Testing at 20 CPI')

PSSetLPI(8)
PSSetCPI(10)
PSTextOut(22, 0, 'Now testing at 8 LPI and 10 CPI')
PSTextOut(23, 0, 'Now testing at 8 LPI and 10 CPI')

//PSSetFont(cFont, nStyle, nSize, nTFColor, nTBColor, nAngle)

PSSetFont('Arial',, 8)
PSTextOut(25, 0, 'You can also use proportional fonts when printing using text coordinates.')
PSTextOut(30, 45, 'Why not print at 90 degres !', , , , , , , , 90)

PSSetLPI(6)
PSLine(25, 39, 32, 39)

PSTextOut(25, 39, 'Text justification')
PSTextOut(26, 39, 'Left justify', , APS_LEFT)
PSTextOut(27, 39, 'Right justify', , APS_RIGHT)
PSTextOut(28, 39, 'Center justify', , APS_CENTER)

PSSetDecimalSep('.')
PSTextOut(29, 39, '9999.99 Justify on .', , APS_DECIMAL)

PSSetDecimalSep(',')
PSTextOut(30, 39, '9999,99 Justify on ,', , APS_DECIMAL)

PSSetDecimalSep('/')
PSTextOut(31, 39, '9999/99 Justify on /', , APS_DECIMAL)

// Calculating width for text positionning
PSSetFont(APS_COURIER)
PSSetCPI(10)
nPos   := 5
nWidth := PSGetTextWidth(S1)
PSTextOut(38, nPos, S1)
nPos := nPos + nWidth + 1
PSTextOut(38, nPos, S2)

PSSetCPI(20)
nPos   := 10
nWidth := PSGetTextWidth(S1)
PSTextOut(39, nPos, S1)
nPos := nPos + nWidth + 1
PSTextOut(39, nPos, S2)

PSSetCPI(10)
PSSetFont('Arial',, 8)
nPos   := 5
nWidth := PSGetTextWidth(S1)
PSTextOut(40, nPos, S1)
nPos := nPos + nWidth + 1
PSTextOut(40, nPos, S2)

PSSetFont(,, 10)
nPos   := 5
nWidth := PSGetTextWidth(S1)
PSTextOut(41, nPos, S1)
nPos := nPos + nWidth + 1
PSSetFont(APS_VERDANA,, 8)
nWidth := PSGetTextWidth(S2)
PSTextOut(41, nPos, S2)
nPos := nPos + nWidth + 1
PSSetFont(APS_TIMES,, 10)
PSTextOut(41, nPos, 'And you may mix fonts and sizes (not recommanded in text unit).')

PSEndDoc()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeePixels()
Description : Printing using pixels coordinates
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function AbeePixels()

Local aCaps

BEGINDOC WITH 0  TITLE "Printing using pixel unit"  ORIENTATION APS_PORTRAIT
   aCaps := PSGetPrinterCaps()

    PSSetUnit(APS_PIXEL)
    PSFrame((aCaps[APC_AREAHEIGHT] / 2) - (aCaps[APC_VPIXELS] / 2), ;
           (aCaps[APC_AREAWIDTH]  / 2) - (aCaps[APC_VPIXELS] / 2), ;
            (aCaps[APC_AREAHEIGHT] / 2) + (aCaps[APC_VPIXELS] / 2), ;
           (aCaps[APC_AREAWIDTH]  / 2) + (aCaps[APC_VPIXELS] / 2), ;
           1, APS_BLACK, APS_PALEGRAY)
    PSLine (0, 0, aCaps[APC_AREAHEIGHT], aCaps[APC_AREAWIDTH], 2, APS_BLACK) // Big X
    PSLine (aCaps[APC_AREAHEIGHT], 0, 0, aCaps[APC_AREAWIDTH], 2, APS_BLACK) // Big X
ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeTextBox()
Description : Prints a long character string in a box region
Author .....: Stephan St-Denis
Date .......: March 2000

Function PSTextBox(nTop, nLeft, nBottom, nRight, cText, nJustify, cFont, nSize, ;
                   nStyle, nFColor, nBColor, nThick)

if slInitialized
   oPScript:TextBox(nTop, nLeft, nBottom, nRight, cText, nJustify, cFont, nSize, ;
                    nStyle, nFColor, nBColor, nThick)
endif

-----------------------------------------------------------------------------*/
Static Function AbeeTextBox()

Local cText := "This is a very long character string. It simulates a memo field and helps showing the capabilities of the PSTextBox() function available since PageScript version 2." + CRLF + CRLF + "*** THAT is a very long character string. It simulates a memo field and helps showing the capabilities of the PSTextBox() function available since PageScript version 2."

PSBeginDoc(, "Testing PSTextBox()", APS_PORTRAIT)

   PSSetUnit(APS_TEXT)   // Text coordinates
   PSSetCPI(17)

   @1 ,5 TEXTOUT "Left justified"   FONT APS_ARIAL  STYLE APS_BOLD  SIZE 10
   @11,5 TEXTOUT "Right justified"  FONT APS_ARIAL  STYLE APS_BOLD  SIZE 10
   @21,5 TEXTOUT "Center justified" FONT APS_ARIAL  STYLE APS_BOLD  SIZE 10

   PSTextBox( 2, 5, 10, 60, cText, APS_LEFT  , APS_COURIER,  8, APS_PLAIN , APS_BLACK, RGB(233, 197, 222), 0)
   PSTextBox(12, 5, 20, 60, cText, APS_RIGHT , APS_ARIAL  , 10, APS_BOLD  , APS_BLACK, RGB(173, 200, 187), 1)

   PSTextBox(22, 5, 30, 60, cText, APS_CENTER, APS_TIMES  , 12, APS_ITALIC, APS_BLACK, RGB(173, 176, 214), 2)
   PSTextBox( 2,75, 10, 95, cText, APS_LEFT  , APS_COURIER,  8, APS_PLAIN , APS_BLACK, RGB(233, 197, 222), 0)

   PSTextBox(12,75, 20, 95, cText, APS_RIGHT , APS_ARIAL  , 10, APS_BOLD  , APS_BLACK, RGB(173, 200, 187), 1)
   PSTextBox(22,75, 30, 95, cText, APS_CENTER, APS_TIMES  , 12, APS_ITALIC, APS_BLACK, RGB(173, 176, 214), 2)

   @32, 5 TO 40, 60  TEXTBOX cText  JUSTIFY APS_CENTER  FONT APS_SYSTEM  SIZE  16  COLOR APS_BLUE , APS_RED   THICKNESS 2
   @32, 75,  40, 95  TEXTBOX cText  JUSTIFY APS_CENTER  FONT APS_SYSTEM  SIZE  10  COLOR APS_BLACK, APS_BLUE  THICKNESS 1

PSEndDoc()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeBarCode()
Description : Show barcode capabilities
Author .....: Stephan St-Denis
Date .......: February 2000
-----------------------------------------------------------------------------*/
Static Function AbeeBarCode()

BEGINDOC WITH 0  TITLE "Printing barcodes"  ORIENTATION APS_PORTRAIT

    PSSetUnit(APS_TEXT)
    PSSetFont(APS_ARIAL, APS_PLAIN, 12)

   @0,20 TEXTOUT "Barcode Symbol 128B"    JUSTIFY APS_CENTER
   @0,60 TEXTOUT "Barcode Symbol 3 of 9"  JUSTIFY APS_CENTER

    PSSetUnit(APS_MILL)
   PSBarCode( 20, 20, "Barcode 128B"  , 24,  .5, .t., APS_BC128)
   PSBarCode( 20,120, "BARCODE 3 OF 9", 24,  .5, .t., APS_BC39)

   PSBarCode( 40, 20, "BarCode128"    , 24,  .5, .t., APS_BC128)
   PSBarCode( 60, 20, "BarCode128"    , 24, .75, .t., APS_BC128)
   PSBarCode( 80, 20, "BarCode128"    , 24,   1, .t., APS_BC128)

   PSBarCode( 40,120, "BarCode39"     , 24,  .5, .t., APS_BC39)
   PSBarCode( 60,120, "barcode39"     , 24, .75, .t., APS_BC39)
   PSBarCode( 80,120, "BARCODE39"     , 24,   1, .t., APS_BC39)

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeePrinters()
Description : Station's available printers list
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function AbeePrinters()

Local nLoop
Local nRow      := 0
Local aPrinters := PSGetPrinters()

BEGINDOC WITH 0  TITLE "List of printers"  ORIENTATION APS_PORTRAIT
    PSSetUnit(APS_TEXT)
    PSSetFont(APS_ARIAL, APS_PLAIN, 12)

   for nLoop := 1 to Len(aPrinters)
      @nRow,5 TEXTOUT aPrinters[nLoop]
      if ++nRow > 50
         nRow := 0
         PSNewPage()
      endif
   next nLoop
ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeePaperBins()
Description : Station's available printers paper bin list
Author .....: Stephan St-Denis
Date .......: May 2006
-----------------------------------------------------------------------------*/
Static Function AbeePaperBins()

Local nLoop
Local nRow  := 3
Local aBins

aBins := PSGetPaperBins()

BEGINDOC WITH 0 TITLE "List of paper bins for the selected printer"  ORIENTATION APS_PORTRAIT
    PSSetUnit(APS_TEXT)
    PSSetRowCol(50, 80)
    PSSetFont(APS_ARIAL, APS_PLAIN, 12)

   @0,5 TEXTOUT "List of paper bins for the selected printer"

   for nLoop := 1 to Len(aBins)
      @nRow,5 TEXTOUT aBins[nLoop, 1] PICTURE "9999"
      @nRow,9 TEXTOUT aBins[nLoop, 2]
      if ++nRow > 45
         nRow := 3
         PSNewPage()
         @0,5 TEXTOUT "List of paper bins for the selected printer"
      endif
   next nLoop
ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeFonts()
Description : List of available fonts for a specific printer
Author .....: Stephan St-Denis
Date .......: March 2000
-----------------------------------------------------------------------------*/
Static Function AbeeFonts()

Local nLoop
Local nRow      := 0
Local aFonts

BEGINDOC WITH 0  TITLE "List of available fonts"  ORIENTATION APS_PORTRAIT
   aFonts := aSort(PSGetFonts())

    PSSetUnit(APS_TEXT)
    PSSetFont(APS_ARIAL, APS_PLAIN, 8)

   for nLoop := 1 to Len(aFonts)
      @nRow,0  TEXTOUT aFonts[nLoop]
      @nRow,39 TEXTOUT aFonts[nLoop]  FONT aFonts[nLoop]
      PSLine(nRow + 1, 0, nRow + 1, 80, 1, APS_BLACK)
      if ++nRow > 56
         nRow := 0
         PSNewPage()
      endif
   next nLoop

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeePointSize()
Description : Print the same string using different point size
Author .....: Stephan St-Denis
Date .......: March 2000
-----------------------------------------------------------------------------*/
Static Function AbeePointSize()

Local nLoop
Local nPoint    := 4

BEGINDOC WITH 0  TITLE "Point size test"  ORIENTATION APS_PORTRAIT
    PSSetUnit(APS_TEXT)
    PSSetFont(APS_ARIAL, APS_PLAIN, nPoint)

   for nLoop := 0 to 31
      @nLoop,0  TEXTOUT "This is printed at " + Str(nPoint, 5, 2) + " points." POINT nPoint
      nPoint += .25
   next nLoop

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeePrnCaps
Description : List of supported printer caps as returned by PSGetCaps()
Author .....: Stephan St-Denis
Date .......: September 2000
-----------------------------------------------------------------------------*/
Static Function AbeePrnCaps()

Local nLoop
Local aCaps
Local aText := {;
   "Paper width :", ;
   "Paper height :", ;
   "Printable area width :", ;
   "Printable area height :", ;
   "Top margin :", ;
   "Left margin :", ;
   "Number of horizontal pixels per inch :", ;
   "Number of vertical pixels per inch :", ;
   "Number of bits per pixel (1 = B&W) :"}

PSBeginDoc(, "Selected printer capabilities", APS_PORTRAIT)
    PSSetUnit(APS_TEXT)
    PSSetFont(APS_ARIAL, APS_PLAIN, 10)

   aCaps := PSGetPrinterCaps()

   @0, 39 TEXTOUT "Capabilities of " + PSGetPrinters()[PSGetPrinter()] JUSTIFY APS_CENTER  STYLE APS_BOLD  POINT 14

   for nLoop := 1 to Len(aCaps)
      @nLoop + 5, 30 TEXTOUT aText[nLoop] JUSTIFY APS_RIGHT
      @nLoop + 5, 31 TEXTOUT aCaps[nLoop]
   next nLoop

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: CalcTop(<n>) -> nTopCoor
Description : Calculates the top coor. of a bar
Author .....: Stephan St-Denis
Date .......: August 1999
-----------------------------------------------------------------------------*/
Static Function CalcTop(nAmnt)

Return 160 - (nAmnt / 1000)

/*-----------------------------------------------------------------------------
Function ...: AbeeConvert()
Description : Print a string with and without Ascii to Ansi convertion
Author .....: Stephan St-Denis
Date .......: March 2001
-----------------------------------------------------------------------------*/
Static Function AbeeConvert()

Local nLoop

BEGINDOC WITH 0  TITLE "Ascii to Ansi convertion test"  ORIENTATION APS_PORTRAIT
    PSSetUnit(APS_TEXT)
    PSSetFont(APS_COURIER, APS_PLAIN, 10)

   @0,0  TEXTOUT "Converted"
   @0,40 TEXTOUT "Not converted"

   for nLoop := 1 to 42
      PSSetAsciiToAnsi(.t.)
      @nLoop + 1,  0 TEXTOUT Str(nLoop + 127, 3, 0) + " = " + Chr(nLoop + 127)
      @nLoop + 1, 10 TEXTOUT Str(nLoop + 169, 3, 0) + " = " + Chr(nLoop + 169)
      @nLoop + 1, 20 TEXTOUT Str(nLoop + 211, 3, 0) + " = " + Chr(nLoop + 211)

      PSSetAsciiToAnsi(.f.)
      @nloop + 1, 40 TEXTOUT Str(nLoop + 127, 3, 0) + " = " + Chr(nLoop + 127)
      @nLoop + 1, 50 TEXTOUT Str(nLoop + 169, 3, 0) + " = " + Chr(nLoop + 169)
      @nLoop + 1, 60 TEXTOUT Str(nLoop + 211, 3, 0) + " = " + Chr(nLoop + 211)
   next nLoop

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeConvert()
Description : Print a string with and without Ascii to Ansi convertion
Author .....: Stephan St-Denis
Date .......: March 2001
-----------------------------------------------------------------------------*/
Static Function AbeeDuplex()

Local nLoop
Local nCopies

BEGINDOC WITH 0 TITLE "Duplex mode test"  ORIENTATION APS_PORTRAIT
    PSSetUnit(APS_TEXT)
    PSSetFont(APS_COURIER, APS_PLAIN, 10)

   for nCopies := 1 to 2
      for nLoop := 1 to 25
         @nLoop, 10 TEXTOUT "This is a Duplex test"
      next nLoop

      if nCopies < 2
         PSNewPage()
      endif
   next nCopies
ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeLegal()
Description : Print on a LEGAL paper size format
Author .....: Stephan St-Denis
Date .......: May 2001
-----------------------------------------------------------------------------*/
Static Function AbeeLegal()

Local nLoop
Local nMax

PSSetPageSize(DMPAPER_LEGAL)

   BEGINDOC WITH 0  TITLE "Printing on Legal format"
    PSSetUnit(APS_TEXT)
   PSSetCPI(10)
   PSSetLPI(6)
    PSSetFont(APS_COURIER, APS_PLAIN, 12)

   nMax := Int(PSGetMaxHeight()) - 1

   @0,  0 TEXTOUT "This is the first line"
   @0, 29 TEXTOUT "This is the first line"
   @0, 58 TEXTOUT "This is the first line"

   for nLoop := 1 to nMax - 1
      @nLoop,  0 TEXTOUT "This is a test"
      @nLoop, 29 TEXTOUT "This is a test"
      @nLoop, 58 TEXTOUT "This is a test"
   next nLoop

   @nMax,  0 TEXTOUT "This is the last line"
   @nMax, 29 TEXTOUT "This is the last line"
   @nMax, 58 TEXTOUT "This is the last line"

   ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeRawData()
Description : Prints RAW data
Author .....: Stephan St-Denis
Date .......: May 2001
-----------------------------------------------------------------------------*/
Static Function AbeeRAWData()

Local nRow := 0
Local nModel

Scroll(4, 0, 23, 79, 0)
@4,2 to 8, 28
@5,46 say "Please select a printer brand"
@6,46 say "to send raw data."

if (nModel := AChoice(5, 4, 20, 26, {"Compatible HP LaserJet", "Compatible IBM Graphics", "Compatible Epson LQ"})) == 0
   Return NIL
endif

SetPrinterCodes(nModel + 1)

PSBeginRawDoc(0, "RAW data")

// USING @SAY
@nRow,0  say "Printing using @SAY"
nRow += 2

@nRow  ,0 say "Basic styles"
nRow += 2

@nRow++,0 say PC(PC_BOLDON)   + "This line is printed in bold" + PC(PC_BOLDOFF)
@nRow  ,0 say PC(PC_ITALICON) + "This line is printed in italic" + PC(PC_ITALICOFF)
nRow += 2

@nRow  ,0 say "Mixed styles"
nRow += 2

@nRow  ,0 say PC(PC_BOLDON)   + "Printed using bold  " + PC(PC_ITALICON) + "and italic" + PC(PC_ITALICOFF) + PC(PC_BOLDOFF)
nRow += 2

@nRow  ,0 say "Font size (CPI)"
nRow += 2

@nRow++,0 say PC(PC_SET17CPI) + "17 CPI " + Repl("X", 125)  // 17 CPI
@nRow  ,0 say PC(PC_SET10CPI) + "10 CPI " + Repl("X",  73)  // 10 CPI
nRow += 2

@nRow  ,0 say "IBM Character set II Test - (may not print on your printer)"
nRow += 2

@nRow  ,0 say "∞±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ"

EJECT

// USING ? / ??
?? "Printing using ? / ?? (QOut / QQOut)" + CRLF2
?? "Basic styles"  + CRLF2
?? PC(PC_BOLDON)   + "This line is printed in bold" + PC(PC_BOLDOFF) + CRLF
?? PC(PC_ITALICON) + "This line is printed in italic" + PC(PC_ITALICOFF) + CRLF2

?? "Mixed styles"  + CRLF2
?? PC(PC_BOLDON)   + "Printed using bold  " + PC(PC_ITALICON) + "and italic" + PC(PC_ITALICOFF) + PC(PC_BOLDOFF) + CRLF2

?? "Font size (CPI)" + CRLF2
?? PC(PC_SET17CPI) + "17 CPI " + Repl("X", 125) + CRLF  // 17 CPI
?? PC(PC_SET10CPI) + "10 CPI " + Repl("X",  73) + CRLF2 // 10 CPI

?? "IBM Character set II Test - (may not print on your printer)" + CRLF2

?? "∞±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ"

EJECT

PSEndRawDoc()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeEmuData()
Description : Prints using the EMULATION mode
Author .....: Stephan St-Denis
Date .......: May 2001
-----------------------------------------------------------------------------*/
Static Function AbeeEMUData()

SetPrinterCodes(1)

PSBeginEmuDoc(0, "EMULATION mode")

@ 0,0  say "Basic styles"
@ 2,0  say PC(PC_BOLDON)   + "This line is printed in bold" + PC(PC_BOLDOFF)
@ 3,0  say PC(PC_ITALICON) + "This line is printed in italic" + PC(PC_ITALICOFF)
@ 4,0  say PC(PC_UNDERON)  + "This line is underlined" + PC(PC_UNDEROFF)
@ 5,0  say PC(PC_STRIKEON) + "This line is striked out" + PC(PC_STRIKEOFF)

@ 7,0  say "Mixed styles"
@ 9,0  say PC(PC_BOLDON)   + "Printed using bold " + PC(PC_STRIKEON) + "and strikeout" + PC(PC_STRIKEOFF) + PC(PC_BOLDOFF)
@10,0  say PC(PC_ITALICON) + "Let's start printing using italic"
@11,0  say PC(PC_UNDERON)  + "and continue by adding underline"
@12,0  say PC(PC_BOLDON)   + "and why not adding bold" + PC(PC_BOLDOFF) + PC(PC_UNDEROFF) + PC(PC_ITALICOFF)

@14,0  say "Font size (CPI)"
@16,0  say PC(PC_SET8CPI)  + "08 CPI " + Repl("X",  57)  // 8  CPI
@17,0  say PC(PC_SET10CPI) + "10 CPI " + Repl("X",  73)  // 10 CPI
@18,0  say PC(PC_SET12CPI) + "12 CPI " + Repl("X",  89)  // 12 CPI
@19,0  say PC(PC_SET15CPI) + "15 CPI " + Repl("X", 113)  // 15 CPI
@20,0  say PC(PC_SET17CPI) + "17 CPI " + Repl("X", 125)  // 17 CPI
@21,0  say PC(PC_SET18CPI) + "18 CPI " + Repl("X", 137)  // 18 CPI
@22,0  say PC(PC_SET20CPI) + "20 CPI " + Repl("X", 153)  // 20 CPI

EJECT

?? PC(PC_SET10CPI) + "Line spacing (8 LPI)" + CRLF2
?? PC(PC_SET8LPI)  + "Line spacing = 8 LPI" + Repl("X",  50) + CRLF  // 8 LPI
?? "Line spacing = 8 LPI" + Repl("X",  50) + CRLF
?? "Line spacing = 8 LPI" + Repl("X",  50)

EJECT

?? "Line spacing (6 LPI)" + CRLF2
?? PC(PC_SET6LPI)  + "Line spacing = 6 LPI" + Repl("X",  50) + CRLF  // 6 LPI
?? "Line spacing = 6 LPI" + Repl("X",  50) + CRLF
?? "Line spacing = 6 LPI" + Repl("X",  50) + CRLF2
?? "Everything back to normal"

PSEndEmuDoc()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeAutoTextCoor()
Description : 
Author .....: Stephan St-Denis
Date .......: April 2006
-----------------------------------------------------------------------------*/
Static Function AbeeAutoTextCoor()

PSBeginDoc(0, "Default text coordinates test")
PSSetUnit(APS_TEXT)
PSSetCPI(10)
PSSetLPI(6)
PSSetFont(APS_COURIER, APS_PLAIN, 12)

/*
Function PSTextOut(nTop, nLeft, xValue, cPicture, nJustify, cFont, nSize, nStyle, nTFColor, nTBColor, nAngle)
*/

PSTextOut( , , "This is a test "  , , , APS_VERDANA,  9)
PSTextOut( , , "using different " , , , APS_ARIAL  , 10, APS_BOLD)
PSTextOut( , , "styles "          , , , APS_TIMES  , 10, APS_ITALIC)
PSTextOut( , , "and fonts "       , , , APS_VERDANA,  9, APS_BOLD + APS_ITALIC)
PSTextOut( , , "on the same line.", , , APS_ARIAL  , 10)

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeEncryptedPDF()
Description : 
Author .....: Stephan St-Denis
Date .......: April 2007
-----------------------------------------------------------------------------*/
Static Function AbeeEncryptedPDF()

Local cPassword := "PageScript32"

PSSetPDFOwnerPassword(cPassword)

PSShowPDF(.t.)

PSBeginDoc(0, "Encrypted PDF")
PSSetUnit(APS_TEXT)
PSSetCPI(10)
PSSetLPI(6)
PSSetFont(APS_COURIER, APS_PLAIN, 10)

@10, 10 TEXTOUT "This document is protected using a password."

ENDDOC

Return NIL

/*-----------------------------------------------------------------------------
Function ...: AbeeChangePWColor()
Description : 
Author .....: Stephan St-Denis
Date .......: April 2007
-----------------------------------------------------------------------------*/
Static Function AbeeChangePWColor()

Local nBackground := RGB(165, 187, 205)
Local nPaper := RGB(239, 241, 225)
Local nShadow := RGB(93, 93, 93)
Local nToolbar := RGB(231, 247, 255)

PSSetPWColors(nBackground, nPaper, nShadow, nToolbar)

Return NIL

/*-----------------------------------------------------------------------------
Function .: #PC(<n>, <c>)
Fonction .: Get/Set the printer codes
Author ...: Stephan St-Denis
Date .....: October 2002
-----------------------------------------------------------------------------*/
Function PC(nCode, cCode)

Static aPC := {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""}

if ValType(cCode) == "C"
   aPC[nCode] := cCode
endif

Return aPC[nCode]

/*-----------------------------------------------------------------------------
Function .: #SetPrinter()
Fonction .: Sets the printer codes
Author ...: Stephan St-Denis
Date .....: October 2002
-----------------------------------------------------------------------------*/
Function SetPrinterCodes(nRecNo)

USE PRINTERS

dbGoto(nRecNo)

PC(PC_BOLDON   , CtoEsc(field->boldon)   )
PC(PC_BOLDOFF  , CtoEsc(field->boldoff)  )
PC(PC_ITALICON , CtoEsc(field->italicon) )
PC(PC_ITALICOFF, CtoEsc(field->italicoff))
PC(PC_UNDERON  , CtoEsc(field->underon)  )
PC(PC_UNDEROFF , CtoEsc(field->underoff) )
PC(PC_STRIKEON , CtoEsc(field->strikeon) )
PC(PC_STRIKEOFF, CtoEsc(field->strikeoff))
PC(PC_SET8CPI  , CtoEsc(field->set8cpi)  )
PC(PC_SET10CPI , CtoEsc(field->set10cpi) )
PC(PC_SET12CPI , CtoEsc(field->set12cpi) )
PC(PC_SET15CPI , CtoEsc(field->set15cpi) )
PC(PC_SET17CPI , CtoEsc(field->set17cpi) )
PC(PC_SET18CPI , CtoEsc(field->set18cpi) )
PC(PC_SET20CPI , CtoEsc(field->set20cpi) )
PC(PC_SET6LPI  , CtoEsc(field->set6lpi)  )
PC(PC_SET8LPI  , CtoEsc(field->set8lpi)  )

dbCloseArea()

Return NIL

/*-----------------------------------------------------------------------------
Function .: #CtoEsc(<c>) -> cEscapedCode
Fonction .: Convert a string in the form of \nnn + \nnn ... to real escape codes
Author ...: Stephan St-Denis
Date .....: October 2002
-----------------------------------------------------------------------------*/
Function CtoEsc(cIn)

Local cOut   := ""
Local nAscii := 0
Local nLoop  := 0

for nLoop := 1 to Len(cIn)
   if SubStr(cIn, nLoop, 1) == "\"   // C'est un code \nnn (ascii)
      nAscii := Val(SubStr(cIn, nLoop + 1, 3))
      if ValType(nAscii) == "N"
         if nAscii > 255
            nAscii := 32
         endif
      else
         nAscii := 32
      endif

      cOut  += Chr(nAscii)
      nLoop += 3

      if nLoop > Len(cIn)
         exit
      endif
   else
      cOut += SubStr(cIn, nLoop, 1)  // C'est un caractäre tel quel
   endif
next nLoop

Return AllTrim(cOut)

/*-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
Function SelectDevice()

Local aDevices  := {"Printer", "Print preview", "PDF File"}
Local nDevice   := 0

nDevice := AChoice(5, 3, 7, 31, aDevices)

Return nDevice

/*-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
FUNCTION Achoice(t, l, b, r, aItems, cTitle, nValue)

    t := l := b := r := Nil
    DEFAULT cTitle TO "Please, select", nValue TO 2

    DEFINE WINDOW Win_2 ;
        AT 0,0 ;
        WIDTH 440 HEIGHT 300 + IF(IsXPThemeActive(), 7, 0) ;
        TITLE cTitle ;
        ICON 'MAIN' ;
        CHILD ;
        NOMAXIMIZE NOSIZE ;
        ON INIT Win_2.Button_1.SetFocus

        @ 235,220 BUTTON Button_1 ;
        CAPTION 'OK' ;
        ACTION {|| nValue := Win_2.List_1.Value, Win_2.Release } ;
        WIDTH 90

        @ 235,325 BUTTON Button_2 ;
        CAPTION 'Cancel' ;
        ACTION {|| nValue := 0, Win_2.Release } ;
        WIDTH 90

        @ 20,15 LISTBOX List_1 ;
        WIDTH 400 ;
        HEIGHT 200 ;
        ITEMS aItems ;
        VALUE nValue ;
        ON DBLCLICK {|| nValue := Win_2.List_1.Value, Win_2.Release }

        ON KEY ESCAPE ACTION Win_2.Button_2.OnClick

    END WINDOW

    CENTER WINDOW Win_2
    ACTIVATE WINDOW Win_2

RETURN nValue
/*
*/