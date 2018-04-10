// ----------------------------------------------------------------------------
// Copyright (c) 2000-2017 Pagescript32.com.  ALL RIGHTS RESERVED.
// ----------------------------------------------------------------------------
// This software is provided "AS IS" without warranty of any kind. The entire
// risk as to the quality and performance of this software is with the purchaser.
// If this software proves defective or inadequate, purchaser assumes the entire
// cost of servicing or repair.

/*-----------------------------------------------------------------------------
 Devices
-----------------------------------------------------------------------------*/
#define DEV_PRINTER         1     // Printer
#define DEV_PREVIEW         2     // Printer with Print preview
#define DEV_PDFFILE         3     // Print to a PDF File
#define DEV_RESERVED        4     // Reserved for future use
#define DEV_EMFFILE         5     // Print to a serie of EMF files

/*-----------------------------------------------------------------------------
*** OBSOLETE ***    Special printer numbers
-----------------------------------------------------------------------------*/
#define PRN_DEFAULT          0         // Select Windows default printer
#define PRN_PREVIEW         -1         // Print preview     (Obsolete)
#define PRN_PDF             -2         // Print to PDF File (Obsolete)

/*-----------------------------------------------------------------------------
Possible error codes
-----------------------------------------------------------------------------*/
#define PSE_NOERROR          0         // No error
#define PSE_NOPRINTER        1         // No printer installed
#define PSE_DLLNOTLOADED     2         // Could not load DLL
#define PSE_NOTINITIALIZED   3         // Library not initialized
#define PSE_TIMEDOUT         5         // Beta version timed out

/*-----------------------------------------------------------------------------
 Misc. definitions
-----------------------------------------------------------------------------*/
#define APS_DEFAULT      -999          // Default value for Integer and Double parameters

/*-----------------------------------------------------------------------------
 Basic fonts definitions. Any other valid font is accepted
-----------------------------------------------------------------------------*/
#define APS_SYSTEM          "Courier New"     // System font
#define APS_COURIER         "Courier New"     // Courier new
#define APS_ARIAL           "Arial"           // Arial
#define APS_TIMES           "Times New Roman" // Times new roman
#define APS_DINGBATS        "WingDings"       // WingDings
#define APS_VERDANA         "Verdana"         // Verdana

/*-----------------------------------------------------------------------------
 Supported font styles definitions.
-----------------------------------------------------------------------------*/
#define APS_PLAIN           0     // Plain
#define APS_BOLD            1     // Bold
#define APS_ITALIC          2     // Italic
#define APS_UNDERLINE       4     // UnderLine
#define APS_STRIKEOUT       8     // StrikeOut
#define APS_BOLDITALIC      APS_BOLD + APS_ITALIC   // BoldItalic (Compatibility)

/*-----------------------------------------------------------------------------
 Text justification definitions                                         X,Y
-------------------------------------------------------------------------|---*/
#define APS_LEFT            0     // Text is left justified              PageScript
#define APS_RIGHT           1     // Text is right justified    PageScript
#define APS_CENTER          2     // Text is centered                PageScript
#define APS_DECIMAL         3     // Text is aligned on the decimal 9,999.99

/*-----------------------------------------------------------------------------
 Units of mesurement used to calculate position on the document
-----------------------------------------------------------------------------*/
#define APS_TEXT            0     // Unit is text coordinates (Row, Col)
#define APS_MILL            1     // Unit is millimeter
#define APS_CENT            2     // Unit is centimeter
#define APS_INCH            3     // Unit is inch
#define APS_PIXEL           4     // Unit is pixel
#define APS_PICA            5     // Unit is pica (6 picas per inch)
#define APS_POINT           6     // Unit is point (72 points per inch)
#define APS_TWIPS           7     // Unit is twips (1440 twips per inch)
#define APS_CLIP            8     // Unit is text coordinates (Row, Col) but compatible with PageScript for Clipper

/*-----------------------------------------------------------------------------
 Page orientation
-----------------------------------------------------------------------------*/
#define APS_PORTRAIT        1     // Print in portrait
#define APS_LANDSCAPE       2     // Print in landscape

/*-----------------------------------------------------------------------------
 BarCode types
-----------------------------------------------------------------------------*/
#define APS_BC39            1     // Code 3 of 9
#define APS_BC128           2     // Code 128 B
#define APS_EAN128A         3
#define APS_EAN128B 	    4
#define APS_EAN128C         5
#define APS_EAN8    	    6
#define APS_EAN13   	    7
#define APS_CODE128A 	    8
#define APS_CODE128B        9
#define APS_CODE128C       10  
#define APS_UPCA           11    
#define APS_UPCE0          12
#define APS_CODABAR        13
#define APS_POSTNET        14  
#define APS_INTER25        15

/*-----------------------------------------------------------------------------
 PDF Encoding
------------------------------------------------------------------------------*/
#define APS_PDF_WINANSI_ENC  0
#define APS_PDF_STD_ENC      1
#define APS_PDF_DOC_ENC      2

/*-----------------------------------------------------------------------------
 PDF Version
------------------------------------------------------------------------------*/
#define APS_PDF14      	0
#define APS_PDF15      	1
#define APS_PDF16      	2
#define APS_PDF17	3

/*-----------------------------------------------------------------------------
 PDF Embedded fonts
------------------------------------------------------------------------------*/
#define APS_PDF_FNT_NONE      	0
#define APS_PDF_FNT_FULL      	1
#define APS_PDF_FNT_SUB      	2


/*-----------------------------------------------------------------------------
 Basic colors supported. Corresponds to Clipper's. We're using negative
 values because we don't want to interfere with RGS values that are
 represented by a positive integer.
-----------------------------------------------------------------------------*/
#define APS_BLACK          -1     // Black
#define APS_BLUE           -2     // Dark blue
#define APS_GREEN          -3     // Dark green
#define APS_CYAN           -4     // Dark cyan
#define APS_RED            -5     // Dark red
#define APS_MAGENTA        -6     // Dark magenta
#define APS_BROWN          -7     // Brown (more orange than brown)
#define APS_PALEGRAY       -8     // Pale gray
#define APS_GRAY           -9     // Dark gray
#define APS_BBLUE         -10     // Bright blue
#define APS_BGREEN        -11     // Bright green
#define APS_BCYAN         -12     // Bright cyan
#define APS_BRED          -13     // Bright red
#define APS_BMAGENTA      -14     // Bright magenta
#define APS_YELLOW        -15     // Yellow
#define APS_WHITE         -16     // White
#define APS_NONE         -255     // Transparent (No color)

/*-----------------------------------------------------------------------------
 Supported patterns used in conjunction with the filling color
-----------------------------------------------------------------------------*/
#define APS_SOLID           0     // Û  Solid
#define APS_CLEAR           1     //    Clear (no color / transparent)
#define APS_BDIAGONAL       2     // \\ Backward diagonal
#define APS_FDIAGONAL       3     // // Forward diagonal
#define APS_CROSS           4     // ++ Cross
#define APS_DIAGCROSS       5     // XX Diagonal cross
#define APS_HORIZONTAL      6     // ÍÍ Horizontal
#define APS_VERTICAL        7     // ³³ Vertical

/*-----------------------------------------------------------------------------
 Watermark type
-----------------------------------------------------------------------------*/
#define AWM_NONE            0     // No Watermark
#define AWM_FOREGROUND      1     // Watermark is printed in foreground
#define AWM_BACKGROUND      2     // Watermark is printed in background

/*-----------------------------------------------------------------------------
 Coordinate system
-----------------------------------------------------------------------------*/
#define APS_LEFTTOP         0     // Left/Top coordinate system
#define APS_TOPLEFT         1     // Top/Left coordinate system

/*-----------------------------------------------------------------------------
 Printer Caps. All caps are in pixels
-----------------------------------------------------------------------------*/
#define APC_PAPERWIDTH      1     // Paper width
#define APC_PAPERHEIGHT     2     // Paper height
#define APC_AREAWIDTH       3     // Printable area width
#define APC_AREAHEIGHT      4     // Printable area height
#define APC_TOPMARGIN       5     // Top margin
#define APC_LEFTMARGIN      6     // Left margin
#define APC_HPIXELS         7     // Number of horizontal pixels per inch
#define APC_VPIXELS         8     // Number of vertical pixels per inch
#define APC_BITSPIXEL       9     // Number of bits per pixel (1 = B&W printer)

/*-----------------------------------------------------------------------------
 Print Preview Window State
-----------------------------------------------------------------------------*/
#define PWS_MINIMIZED       0     // Minimized
#define PWS_MAXIMIZED       1     // Maximized - Default
#define PWS_NORMAL          2     // Normal
#define PWS_NORMALCENTERED  3     // Normal centered (Only Width and Height required)
#define PWS_AUTO            4     // Saves and reuses the size and pos automaticaly

/*-----------------------------------------------------------------------------
 PDF font character sets (As defined by Microsoft)
-----------------------------------------------------------------------------*/
#define ANSI_CHARSET         0    // Latin - Western European languages: English, French, German, Spanish, Italian, Portuguese...
#define ARABIC_CHARSET     178    // Arabic -Arabic, Syriac
#define BALTIC_CHARSET     186    // Baltic - Estonian, Latvian, Lithuanian
#define EASTEUROPE_CHARSET 238    // European - Eastern European languages: Czech, Croatian, Hungarian, Polish, Romanian, Slovak, Slovenian...
#define GREEK_CHARSET      161    // Greek
#define HEBREW_CHARSET     177    // Hebrew
#define RUSSIAN_CHARSET    204    // Cyrillic - Belarussian, Bulgarian, Russian, Serbian, Ukrainian...
#define TURKISH_CHARSET    162    // Turkish

/*-----------------------------------------------------------------------------
 Predefined Paper selection (based on Windows API constants)
-----------------------------------------------------------------------------*/
#define DMPAPER_LETTER                    1  // Letter 8 12 x 11 in
#define DMPAPER_FIRST                     DMPAPER_LETTER
#define DMPAPER_LETTERSMALL               2  // Letter Small 8 12 x 11 in
#define DMPAPER_TABLOID                   3  // Tabloid 11 x 17 in
#define DMPAPER_LEDGER                    4  // Ledger 17 x 11 in
#define DMPAPER_LEGAL                     5  // Legal 8 12 x 14 in
#define DMPAPER_STATEMENT                 6  // Statement 5 12 x 8 12 in
#define DMPAPER_EXECUTIVE                 7  // Executive 7 14 x 10 12 in
#define DMPAPER_A3                        8  // A3 297 x 420 mm
#define DMPAPER_A4                        9  // A4 210 x 297 mm
#define DMPAPER_A4SMALL                  10  // A4 Small 210 x 297 mm
#define DMPAPER_A5                       11  // A5 148 x 210 mm
#define DMPAPER_B4                       12  // B4 (JIS) 250 x 354
#define DMPAPER_B5                       13  // B5 (JIS) 182 x 257 mm
#define DMPAPER_FOLIO                    14  // Folio 8 12 x 13 in
#define DMPAPER_QUARTO                   15  // Quarto 215 x 275 mm
#define DMPAPER_10X14                    16  // 10x14 in
#define DMPAPER_11X17                    17  // 11x17 in
#define DMPAPER_NOTE                     18  // Note 8 12 x 11 in
#define DMPAPER_ENV_9                    19  // Envelope #9 3 78 x 8 78
#define DMPAPER_ENV_10                   20  // Envelope #10 4 18 x 9 12
#define DMPAPER_ENV_11                   21  // Envelope #11 4 12 x 10 38
#define DMPAPER_ENV_12                   22  // Envelope #12 4 \276 x 11
#define DMPAPER_ENV_14                   23  // Envelope #14 5 x 11 12
#define DMPAPER_CSHEET                   24  // C size sheet
#define DMPAPER_DSHEET                   25  // D size sheet
#define DMPAPER_ESHEET                   26  // E size sheet
#define DMPAPER_ENV_DL                   27  // Envelope DL 110 x 220mm
#define DMPAPER_ENV_C5                   28  // Envelope C5 162 x 229 mm
#define DMPAPER_ENV_C3                   29  // Envelope C3  324 x 458 mm
#define DMPAPER_ENV_C4                   30  // Envelope C4  229 x 324 mm
#define DMPAPER_ENV_C6                   31  // Envelope C6  114 x 162 mm
#define DMPAPER_ENV_C65                  32  // Envelope C65 114 x 229 mm
#define DMPAPER_ENV_B4                   33  // Envelope B4  250 x 353 mm
#define DMPAPER_ENV_B5                   34  // Envelope B5  176 x 250 mm
#define DMPAPER_ENV_B6                   35  // Envelope B6  176 x 125 mm
#define DMPAPER_ENV_ITALY                36  // Envelope 110 x 230 mm
#define DMPAPER_ENV_MONARCH              37  // Envelope Monarch 3.875 x 7.5 in
#define DMPAPER_ENV_PERSONAL             38  // 6 34 Envelope 3 58 x 6 12 in
#define DMPAPER_FANFOLD_US               39  // US Std Fanfold 14 78 x 11 in
#define DMPAPER_FANFOLD_STD_GERMAN       40  // German Std Fanfold 8 12 x 12 in
#define DMPAPER_FANFOLD_LGL_GERMAN       41  // German Legal Fanfold 8 12 x 13 in
#define DMPAPER_ISO_B4                   42  // B4 (ISO) 250 x 353 mm
#define DMPAPER_JAPANESE_POSTCARD        43  // Japanese Postcard 100 x 148 mm
#define DMPAPER_9X11                     44  // 9 x 11 in
#define DMPAPER_10X11                    45  // 10 x 11 in
#define DMPAPER_15X11                    46  // 15 x 11 in
#define DMPAPER_ENV_INVITE               47  // Envelope Invite 220 x 220 mm
#define DMPAPER_RESERVED_48              48  // RESERVED--DO NOT USE
#define DMPAPER_RESERVED_49              49  // RESERVED--DO NOT USE
#define DMPAPER_LETTER_EXTRA             50  // Letter Extra 9 \275 x 12 in
#define DMPAPER_LEGAL_EXTRA              51  // Legal Extra 9 \275 x 15 in
#define DMPAPER_TABLOID_EXTRA            52  // Tabloid Extra 11.69 x 18 in
#define DMPAPER_A4_EXTRA                 53  // A4 Extra 9.27 x 12.69 in
#define DMPAPER_LETTER_TRANSVERSE        54  // Letter Transverse 8 \275 x 11 in
#define DMPAPER_A4_TRANSVERSE            55  // A4 Transverse 210 x 297 mm
#define DMPAPER_LETTER_EXTRA_TRANSVERSE  56  // Letter Extra Transverse 9\275 x 12 in
#define DMPAPER_A_PLUS                   57  // SuperASuperAA4 227 x 356 mm
#define DMPAPER_B_PLUS                   58  // SuperBSuperBA3 305 x 487 mm
#define DMPAPER_LETTER_PLUS              59  // Letter Plus 8.5 x 12.69 in
#define DMPAPER_A4_PLUS                  60  // A4 Plus 210 x 330 mm
#define DMPAPER_A5_TRANSVERSE            61  // A5 Transverse 148 x 210 mm
#define DMPAPER_B5_TRANSVERSE            62  // B5 (JIS) Transverse 182 x 257 mm
#define DMPAPER_A3_EXTRA                 63  // A3 Extra 322 x 445 mm
#define DMPAPER_A5_EXTRA                 64  // A5 Extra 174 x 235 mm
#define DMPAPER_B5_EXTRA                 65  // B5 (ISO) Extra 201 x 276 mm
#define DMPAPER_A2                       66  // A2 420 x 594 mm
#define DMPAPER_A3_TRANSVERSE            67  // A3 Transverse 297 x 420 mm
#define DMPAPER_A3_EXTRA_TRANSVERSE      68  // A3 Extra Transverse 322 x 445 mm
#define DMPAPER_LAST                     DMPAPER_A3_EXTRA_TRANSVERSE
#define DMPAPER_USER                    256  // User defined paper size

/*-----------------------------------------------------------------------------
 Paper bin selection (based on Windows API constants)
-----------------------------------------------------------------------------*/
#define DMBIN_UPPER                       1  // Upper bin
#define DMBIN_FIRST                       DMBIN_UPPER
#define DMBIN_ONLYONE                     1  // Same as Upper bin
#define DMBIN_LOWER                       2  // Lower bin
#define DMBIN_MIDDLE                      3  // Middle bin
#define DMBIN_MANUAL                      4  // Manual feed
#define DMBIN_ENVELOPE                    5  // Envelope
#define DMBIN_ENVMANUAL                   6  // Envelope manual feed
#define DMBIN_AUTO                        7  // Auto select (depending on paper size)
#define DMBIN_TRACTOR                     8  // Tractor feed
#define DMBIN_SMALLFMT                    9  // Small forms
#define DMBIN_LARGEFMT                   10  // Large forms
#define DMBIN_LARGECAPACITY              11  // Large capacity bin
#define DMBIN_CASSETTE                   14  // Cassette
#define DMBIN_FORMSOURCE                 15  // Form source
#define DMBIN_LAST                       DMBIN_FORMSOURCE
#define DMBIN_USER                      256  // Device specific bins start here

// XEROX N4525 specific Trays numbers
// Contributed by Jeremy Suiter, England, UK. Thanks.
#define XEROX_4525_1_W98                  1  // Xerox N4525 Tray 1
#define XEROX_4525_2_W98                  2  // Xerox N4525 Tray 2
// Tray's 3,4,5 belong to optional 2,500 feeder unit
#define XEROX_4525_3_W98                258  // Xerox N4525 Tray 3
#define XEROX_4525_4_W98                259  // Xerox N4525 Tray 4
#define XEROX_4525_5_W98                260  // Xerox N4525 Tray 5

// Windows 2000 Pro/NT/XP
#define XEROX_4525_1_W2K                262  // Xerox N4525 Tray 1
#define XEROX_4525_2_W2K                261  // Xerox N4525 Tray 2
// Tray's 3,4,5 belong to optional 2,500 feeder unit
#define XEROX_4525_3_W2K                260  // Xerox N4525 Tray 3
#define XEROX_4525_4_W2K                259  // Xerox N4525 Tray 4
#define XEROX_4525_5_W2K                258  // Xerox N4525 Tray 5

/*-----------------------------------------------------------------------------
 Duplex mode support for printers with Duplex printing options
-----------------------------------------------------------------------------*/
#define DMDUP_SIMPLEX                     1  // Simplex mode
#define DMDUP_VERTICAL                    2  // Vertical Duplex
#define DMDUP_HORIZONTAL                  3  // Horizontal Duplex

/*-----------------------------------------------------------------------------
 Commands definitions
-----------------------------------------------------------------------------*/
#translate RGB(<nRed>, <nGreen>, <nBlue>)                  ;
                                                           ;
      => (<nRed> + (<nGreen> * 256) + (<nBlue> * 65536))


#xcommand ABORT                                            ;
                                                           ;
      => PSAbort()


#xcommand ENDDOC                                           ;
                                                           ;
      => PSEndDoc()


#xcommand ENDRAWDOC                                        ;
                                                           ;
      => PSEndRawDoc()


#xcommand NEWPAGE                                          ;
                                                           ;
      => PSNewPage()


#xcommand BEGINDOC       [<with: WITH, USING> <printer>]   ;
                         [TITLE <title>]                   ;
                         [ORIENTATION <orientation>]       ;
                         [COPIES <copies>]                 ;
                                                           ;
      => PSBeginDoc(<printer>, <title>, <orientation>, <copies>)


#xcommand BEGINRAWDOC    [<with: WITH, USING> <printer>]   ;
                         [TITLE <title>]                   ;
                                                           ;
      => PSBeginRawDoc(<printer>, <title>)


#xcommand @ <x1>, <y1>   [TO <x2>, <y2>]                   ;
                         BITMAP <bitmap>                   ;
                         [COLOR <color>]                   ;
                         [<kr: KEEPRATIO>]                 ;
                                                           ;
      => PSBitmap(<x1>, <y1>, <x2>, <y2>,                  ;
                  <bitmap>, <color>, <.kr.>)

#xcommand @ <x1>, <y1> [, <x2>, <y2>]                      ;
                         BITMAP <bitmap>                   ;
                         [COLOR <color>]                   ;
                         [<kr: KEEPRATIO>]                 ;
                                                           ;
      => PSBitmap(<x1>, <y1>, <x2>, <y2>,                  ;
                  <bitmap>, <color>, <.kr.>)


#xcommand @ <x1> ,<y1>   ELLIPSE [TO] <x2>, <y2>           ;
                         [THICKNESS <thick>]               ;
                         [COLOR <border>[,<fill>]]         ;
                         [PATTERN <pattern>]               ;
                                                           ;
      => PSEllipse(<x1>, <y1>, <x2>, <y2>,                 ;
                   <thick>, <border>, <fill>, <pattern>)


#xcommand @ <x1>, <y1>   FRAME [TO] <x2>, <y2>             ;
                         [THICKNESS <thick>]               ;
                         [COLOR <border>[,<fill>]]         ;
                         [PATTERN <pattern>]               ;
                                                           ;
      => PSFrame(<x1>, <y1>, <x2>, <y2>,                   ;
                 <thick>, <border>, <fill>, <pattern>)


#xcommand @ <x1>, <y1>   LINE [TO] <x2>, <y2>              ;
                         [THICKNESS <thick>]               ;
                         [COLOR <color>]                   ;
                                                           ;
      => PSLine(<x1>, <y1>, <x2>, <y2>, <thick>, <color>)



#xcommand @ <x1>, <y1> TO <x2>, <y2>                       ;
                         TEXTBOX <Text>                    ;
                         [JUSTIFY <just>]                  ;
                         [FONT <font>]                     ;
                         [<point: POINT,SIZE> <psize>]     ;
                         [STYLE <style>]                   ;
                         [COLOR <textcol>[,<fillcol>]]     ;
                         [THICKNESS <thick>]               ;
                                                           ;
      => PSTextBox(<x1>, <y1>, <x2>, <y2>, <Text>, <just>, ;
                   <font>, <psize>, <style>, <textcol>,    ;
                   <fillcol>, <thick>)


#xcommand @ <x1>, <y1>, <x2>, <y2>                         ;
                         TEXTBOX <Text>                    ;
                         [JUSTIFY <just>]                  ;
                         [FONT <font>]                     ;
                         [<point: POINT,SIZE> <psize>]     ;
                         [STYLE <style>]                   ;
                         [COLOR <textcol>[,<fillcol>]]     ;
                         [THICKNESS <thick>]               ;
                                                           ;
      => PSTextBox(<x1>, <y1>, <x2>, <y2>, <Text>, <just>, ;
                   <font>, <psize>, <style>, <textcol>,    ;
                   <fillcol>, <thick>)


#xcommand @ <row>, <col> TEXTOUT <txtxpr>                  ;
                         [PICTURE <pic>]                   ;
                         [JUSTIFY <just>]                  ;
                         [FONT <font>]                     ;
                         [<point: POINT,SIZE> <psize>]     ;
                         [STYLE <style>]                   ;
                         [COLOR <color>[,<fill>]]          ;
                         [<rot: ANGLE, ROTATE> <angle>]    ;
                                                           ;
      => PSTextOut(<row>, <col>, <txtxpr>, <pic>, <just>,  ;
                   <font>, <psize>, <style>, <color>, <fill>, <angle>)

