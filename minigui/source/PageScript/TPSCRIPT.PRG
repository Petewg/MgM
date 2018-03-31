// ----------------------------------------------------------------------------
// Copyright (c) 2000-2017 Pagescript32.com.  ALL RIGHTS RESERVED.
// ----------------------------------------------------------------------------
// This software is provided "AS IS" without warranty of any kind. The entire
// risk as to the quality and performance of this software is with the purchaser.
// If this software proves defective or inadequate, purchaser assumes the entire
// cost of servicing or repair.

/*-----------------------------------------------------------------------------
Coordinate system used by PageScript 32 (defaults to APS_TOPLEFT)

            nLeft
            |
 --- nTop --+--------------+
            |              |
            |              |
            |              |
            +--------------+-- nBottom
                           |
                           nRight

For example, to draw this rectangle, you would call PSFrameEx() with the following
coordinates : PSFrameEx(nTop, nLeft, nBottom, nRight, ...)

if you change the coordinate system to APS_LEFTTOP then you would use the following
coordinates : PSFrameEx(nLeft, nTop, nRight, nBottom, ...)
------------------------------------------------------------------------------*/
#include "PScript.ch"
#include "FileIO.ch"

#ifdef __XHARBOUR__
   // 02.06.2005 - IBTC - changed for xHarbour Builder:
   #xtranslate Method <Classname>:<x> => Method <x>
   #define DLL_STDCALL NIL

   #include "hbclass.ch"
#else
   #ifdef __HARBOUR__
      #xtranslate Method <Classname>:<x> => Method <x>
      #include "hbclass.ch"
      #include "Dll.ch"
   #else
      #include "Xbp.ch"
      #include "Dll.ch"
   #endif
#endif

// Windows constants for GetDeviceCaps WinApi call (Not complete)
#define HORZSIZE             4         // Horizontal size in millimeters
#define VERTSIZE             6         // Vertical size in millimeters
#define HORZRES              8         // Horizontal width in pixels
#define VERTRES             10         // Vertical height in pixels
#define BITSPIXEL           12         // Number of bits per pixel
#define NUMFONTS            22         // Number of fonts the device has
#define NUMCOLORS           24         // Number of colors the device supports
#define ASPECTX             40         // Length of the X leg
#define ASPECTY             42         // Length of the Y leg
#define LOGPIXELSX          88         // Logical pixelsinch in X
#define LOGPIXELSY          90         // Logical pixelsinch in Y
#define PHYSICALWIDTH      110         // Physical Width in device units
#define PHYSICALHEIGHT     111         // Physical Height in device units
#define PHYSICALOFFSETX    112         // Physical Printable Area x margin
#define PHYSICALOFFSETY    113         // Physical Printable Area y margin
#define SCALINGFACTORX     114         // Scaling factor x
#define SCALINGFACTORY     115         // Scaling factor y

#define pfBUFFERLEN       1024         // Print file buffer length

#define dtRAW                1         // Document Type RAW
#define dtEMULATION          2         // Document Type EMULATION

Static oPScript                        // Holds a generic TPageScript object
Static slInitialized := .f.            // True when PageScript is initialized

/*-----------------------------------------------------------------------------
Class .....: #TPageScript(...)
Description: PageScript for (x)Harbour and xBase++ wrapper class
By ........: Stephan St-Denis
Date ......: March 2005
-----------------------------------------------------------------------------*/
CLASS TPageScript

PROTECTED:

   VAR    hDll                         // Handle to PScript.dll
   VAR    aPrinters                    // Array of available printers
   VAR    bWaterMark                   // Codeblock for Watermark function
   VAR    nWaterMark                   // Indicates if the WaterMark is to be printed in foreground or background
   VAR    lFromDialog                  // Indicates if printer selected from Dialog
   VAR    lClipper                     // Indicates if calls to TextOut and TextBox should be compatible with PageScript for Clipper
   VAR    aDocInfo                     // Print job info array

   METHOD Buffer2String                // Internal function. Returns a string from a buffer

EXPORTED:

   // Numerics
   VAR    nError                       // Error condition. 0 = OK
   VAR    nUnit                        // Current UNIT of measurment

   METHOD Init                         // Class initialization

   METHOD Abort                        // Abort the current document
   METHOD BarCode                      // Print a barcode in either 3 of 9 or 128B
   METHOD QRCode		       // Print QRCode		
   METHOD begindoc                     // Starts a new WINDOWS print job
   METHOD BeginDocEx                   // Starts a new WINDOWS print job, no parameters
   METHOD BeginEmuDoc                  // Starts a new EMULATION print job
   METHOD BeginRawDoc                  // Starts a new RAW print job
   METHOD Bitmap                       // Draw a bitmap on the document. .BMP, .JPG and .GIF files are supported.
   METHOD Ellipse                      // Draw an ellipse
   METHOD EllipseEx                    // Draw an ellipse
   METHOD EndDoc                       // Ends a WINDOWS print job
   METHOD EndEmuDoc                    // Ends an EMULATION print job
   METHOD EndRawDoc                    // Ends a RAW print job
   METHOD FindPrinter                  // Search for a printer name and returns its position within the array
   METHOD Frame                        // Draw a frame
   METHOD FrameEx                      // Draw a frame

   // Gets
   METHOD GetAsciiToAnsi               // Retreive the current conversion value
   METHOD GetBorderColor               // Gets the current border color
   METHOD GetBorderThickness           // Gets the border thickness
   METHOD GetCoorSystem                // Gets the actual coordinate system
   METHOD GetCopies                    // Gets the number of copies
   METHOD GetCPI                       // Gets the current CPI
   METHOD GetDecimalSep                // Gets the current Ascii to Ansi flag
   METHOD GetDefaultPrinter            // Gets the current printer number
   METHOD GetDuplex                    // Gets the current Duplex mode
   METHOD GetFillColor                 // Gets the current fill color
   METHOD GetFillPattern               // Gets the current fill pattern
   METHOD GetFonts                     // Returns an array with all available font names
   METHOD GetFontAngle                 // Gets the current font angle
   METHOD GetFontCount                 // Gets the count of available fonts
   METHOD GetFontName                  // Gets the current font name
   METHOD GetFontNames                 // Returns the name of a font from its index position
   METHOD GetFontJustify               // Gets the current text justification
   METHOD GetFontStyle                 // Gets the current font style
   METHOD GetFontSize                  // Gets the current font size
   METHOD GetFontFColor                // Gets the current font foreground color (text color)
   METHOD GetFontBColor                // Gets the current font background color (bounding box color)
   METHOD GetJustify                   // Gets the current text justification
   METHOD GetLPI                       // Gets the current LPI
   METHOD GetMaxHeight                 // Gets the maximum height of the page in the selected unit
   METHOD GetMaxWidth                  // Gets the maximum width of the page in the selected unit
   METHOD GetOrientation               // Gets the current document's orientation
   METHOD GetPageSize                  // Gets the printer paper size
   METHOD GetPaperBin                  // Gets the current printer paper bin

   METHOD GetPaperBinCount             // Gets the paper bin's count
   METHOD GetPaperBinNames             // Gets the name of any of the available paper bin
   METHOD GetPaperBinNumbers           // Gets the number of any of the available paper bin

   METHOD GetPaperCount                // Gets the count of paper formats available for the selected printer
   METHOD GetPaperNames                // Gets the name of any of the paper formats, based on its index position
   METHOD GetPaperNumbers              // Gets the number of any of the paper formats, based on its index position

   METHOD GetPrinter                   // Returns the number of the currently selected printer
   METHOD GetPrinters                  // Returns the list of available printers for this computer
   METHOD GetPrinterCaps               // Retreive capabilities of the selected printer
   METHOD GetPrinterCapsEx             // Retreive one of the capabilities of the selected printer
   METHOD GetPrinterCount              // Retreive the number of available printers
   METHOD GetPrinterHandle             // Returns handle of the selected printer for direct Win API calls
   METHOD GetPrinterNames              // Returns the name of the selected printer
   METHOD GetTextHeight                // Returns the text height in the selected unit
   METHOD GetTextWidth                 // Returns the text width in the selected unit
   METHOD GetTitle                     // Gets the document's title
   METHOD GetUnit                      // Gets the current unit
   METHOD GetUseDIB                    // Returns the DIB flag
   METHOD GetVersion                   // Returns the .DLL version number
   METHOD GetXerox                     // Returns the Xerox flag

   METHOD IsPreviewVisible             // Returns .t. is print preview window is visible, otherwise, returns .f.

   METHOD Line                         // Draw a line
   METHOD LineEx                       // Draw a line
   METHOD NewPage                      // Signals the end of page, page eject
   METHOD PrintDialog                  // Shows the printer dialog and returns if user clicked OK or Cancel
   METHOD PrintEmuFile                 // Prints an EMULATION file
   METHOD PrintRawFile                 // Prints a RAW file

   // Sets
   METHOD SetAsciiToAnsi               // Set the conversion from Ascii to Ansi for text strings.
   METHOD SetBorder                    // Set the attributes used to draw lines and borders
   METHOD SetBorderColor               // Set the border color
   METHOD SetBorderThickness           // Set the border thickness
   METHOD SetClipperComp               // Set Clipper compatible calls for TextOut() and TextBox()
   METHOD SetCoorSystem                // Set the coordinate system (xbase like: Top/Left or Windows like: Left/Top)
   METHOD SetCPI                       // Set the number of CPI (APS_TEXT only)
   METHOD SetCopies                    // Set the number of copies
   METHOD SetDecimalSep                // Set the decimal separator character
   METHOD SetDevice                    // Set the device to use (see PSCRIPT.CH for device contstant definitions)
   METHOD SetDirectPrint               // Set the direct print flag (used for very special cases)
   METHOD SetDuplex                    // Set the Duplex mode
   METHOD SetFileName                  // Set the file name for a PDF file document
   METHOD SetFill                      // Set the color and/or pattern used to fill text and shapes, like boxes and ellipes
   METHOD SetFillColor                 // Set the color used to fill text and shapes, like boxes and ellipes
   METHOD SetFillPattern               // Set the Pattern used to fill text and shapes, like boxes and ellipes
   METHOD SetFontAttributes            // Set the font attributes used by each call to PSTextOut()
   METHOD SetFontAngle                 // Set the font attributes used by each call to PSTextOut()
   METHOD SetFontBColor                // Set the font attributes used by each call to PSTextOut()
   METHOD SetFontFColor                // Set the font attributes used by each call to PSTextOut()
   METHOD SetFontName                  // Set the font attributes used by each call to PSTextOut()
   METHOD SetFontSize                  // Set the font attributes used by each call to PSTextOut()
   METHOD SetFontStyle                 // Set the font attributes used by each call to PSTextOut()
   METHOD SetJustify                   // Set justification for TextOut
   METHOD SetLPI                       // Set the number of LPI
   METHOD SetOrientation               // Set the paper orientation
   METHOD SetPageSize                  // Set the page size to a user defined ou predifined size
   METHOD SetPaperBin                  // Set the paper bin
   
   METHOD SetPDFCharSet                // Set the PDF text charset // not implemented yet
   METHOD SetPDFOwnerPassword          // Set the encryption password for PDF documents
   METHOD SetPDFEncoding               // Set the PDF encoding to be used
   METHOD SetPDFVersion                // Set the PDF versionnumber to be used
   METHOD SetPDFEmbeddedFonts          // Set the PDF embedding type
   METHOD ShowPDF                      // Show PDF after creation in default PDF reader 

   METHOD SetPWState                   // Set the print preview window state
   METHOD SetPWPosition                // Set the print preview window position
   METHOD SetPWSize                    // Set the print preview window size
   METHOD SetPWBounds                  // Set the print preview window bounds (position and size at the same time)
   METHOD SetPWZoomLevel               // Set the print preview window zoom level
   METHOD SetPWColors                  // Set the print preview window colors

   METHOD SetPrinter                   // Set the er number
   METHOD SetRowCol                    // Set the number of rows and columns when printing using the APS_CLIP unit system
   METHOD SetTitle                     // Set the title of the document
   METHOD SetUnit                      // Set the unit used to calculate dimensions and placement
   METHOD SetUseDIB                    // Set the use of compatible bitmaps printing using DIB
   METHOD SetXerox                     // Set Xerox compatible mode for Xerox WorkCenter and other faulty printers

   METHOD TextBox                      // Prints a string in a box at position X1,Y1, X2,Y2 using parameters
   METHOD TextBoxEx                    // Prints a string in a box at position X1,Y1, X2,Y2 using parameters
   METHOD TextOut                      // Prints a string at position X,Y using parameters
   METHOD TextOutEx                    // Prints a string at position X,Y using parameters
   METHOD WaterMark                    // Sets/Returns the current WaterMark

ENDCLASS

/*-----------------------------------------------------------------------------
Method .....: #Init()
Description : Class constructor
-----------------------------------------------------------------------------*/
METHOD TPageScript:Init()

::bWaterMark  := NIL                   // Codeblock for Watermark function
::nWaterMark  := AWM_NONE              // Indicates if the WaterMark is to be printed foreground or background
::lFromDialog := .f.                   // Indicates if printer selected from printer dialog
::lClipper    := .f.                   // Indicates if calls to TextOut and TextBox should be compatible with PageScript for Clipper
::nUnit       := APS_MILL              // Default unit is MILLIMETERS
::aPrinters   := {}                    // List of available printers
::nError      := PSE_NOERROR           // Indicates an error condition, such as no printer available
::aDocInfo    := {0, "", "", APS_PORTRAIT, 1, APS_COURIER} // Print job info array

::hDll        := DllLoad("PScript.dll") // Handle of the .DLL

if Empty(::hDll)
   ::nError := PSE_DLLNOTLOADED        // DLL not loaded error
else
   ::nError := DllCall(::hDll, DLL_STDCALL, "PSInit")

   // No error, set the coordinate system to TOP/LEFT (Default)
   if ::nError == PSE_NOERROR
      DllCall(::hDll, DLL_STDCALL, "PSSetCoorSystem", APS_TOPLEFT)
   endif
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #Abort() -> Self
Description : Abort the current document
-----------------------------------------------------------------------------*/
METHOD TPageScript:Abort()

DllCall(::hDll, DLL_STDCALL, "PSAbort")
::lFromDialog := .f.

Return Self

/*-----------------------------------------------------------------------------
Method .....: #QRCode(<n>, <n>, <c>, [<n>]) -> NIL
Description : Print a QRcode
Parameter nVersion : can be any value between 1 and 40 ( Symbolsize 21*21 modules to 177 * 177 ) 
                     increasing in steps of 4 modules per side.
Parameter nSize    : Size in pixels 100 * 100 by default  
Parameter nModuleWidth : size in pixels of the dots in the QRCode
-----------------------------------------------------------------------------*/
METHOD TPageScript:QRCode(nTop,nLeft,cCode,nVersion,nSize,nModuleWidth)

nVersion     := iif(nVersion     == NIL, 1, Int(nVersion)) 
nSize        := iif(nSize        == NIL, 100, Int(nSize))
nModuleWidth := iif(nModuleWidth == NIL, 4, Int(nModuleWidth))

DllCall(::hDll, DLL_STDCALL, "PSQRCode", PSFtoI(nTop), PSFtoI(nLeft), cCode, nVersion,nSize,nModuleWidth)	

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #BarCode(<n>, <n>, <c>, [<n>, <n>, <l>, <n>]) -> NIL
Description : Print a barcode with choice of Code 39 and Code 128
-----------------------------------------------------------------------------*/
METHOD TPageScript:BarCode(nTop, nLeft, cCode, nHeight, nThick, lPrintText, nType, lVertical, lUnitMM)

// Default values
nHeight    := iif(nHeight    == NIL, 36       , Int(nHeight))
nThick     := iif(nThick     == NIL, 1        , nThick      )
lPrintText := iif(lPrintText == NIL, .t.      , lPrintText  )
nType      := iif(nType      == NIL, APS_BC128, Int(nType  ))
lVertical  := iif(lVertical  == NIL, .f.      , lVertical   )
lUnitMM    := iif(lUnitMM    == NIL, .f.      , lUnitMM     )   // if .T. measurement is in MM

if nType == APS_BC39
   cCode := Upper(cCode)
endif

DllCall(::hDll, DLL_STDCALL, "PSBarCode", PSFtoI(nTop), PSFtoI(nLeft), cCode, nHeight, PSFtoI(nThick), lPrintText, nType, lVertical, lUnitMM)

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #BeginDoc(<n>, <c>, <n>, <n>, <n>, <n>, <n>) -> lError
Description : Start a new print job using the passed parameters
-----------------------------------------------------------------------------*/
METHOD TPageScript:BeginDoc(nPrinter, cTitle, nOrientation, nCopies, nPageSize, nDuplex, nPaperBin)

::SetTitle(cTitle)

if ! ::lFromDialog
   ::SetPrinter(nPrinter)
   ::SetPageSize(nPageSize)
   ::SetPaperBin(nPaperBin)
   ::SetDuplex(nDuplex)
   ::SetOrientation(nOrientation)
   ::SetCopies(nCopies)
endif

DllCall(::hDll, DLL_STDCALL, "PSBeginDoc")

// Put a WaterMark in the BackGround
if ::nWaterMark = AWM_BACKGROUND .and. ValType(::bWaterMark) == "B"
   Eval(::bWaterMark, Self)
endif

Return ::nError

/*-----------------------------------------------------------------------------
Method .....: #BeginDocEx() -> lError
Description : Start a new print job using the defaults values
-----------------------------------------------------------------------------*/
METHOD TPageScript:BeginDocEx()

DllCall(::hDll, DLL_STDCALL, "PSBeginDoc")

// Put a WaterMark in the BackGround
if ::nWaterMark = AWM_BACKGROUND .and. ValType(::bWaterMark) == "B"
   Eval(::bWaterMark, Self)
endif

Return ::nError

/*-----------------------------------------------------------------------------
Method .....: #BeginEmuDoc(<n>, <c>) -> lError
Description : Start a new EMULATION print job using the passed parameters
-----------------------------------------------------------------------------*/
METHOD TPageScript:BeginEmuDoc(nPrinter, cTitle, nOrientation, nCopies, cFont)

nOrientation := iif(nOrientation == NIL, APS_PORTRAIT, nOrientation)
nPrinter     := iif(nPrinter     == NIL, 0           , nPrinter    )
cFont        := iif(cFont        == NIL, APS_COURIER , cFont       )

::aDocInfo[1] := nPrinter
::aDocInfo[2] := cTitle
::aDocInfo[3] := StrTran(Time(), ":", "-") + ".PRN"
::aDocInfo[4] := nOrientation
::aDocInfo[5] := nCopies
::aDocInfo[6] := cFont

SET PRINTER ON
SET CONSOLE OFF
Set(_SET_DEVICE   , "PRINTER")
Set(_SET_PRINTFILE, ::aDocInfo[3], .f.)

Return ::nError

/*-----------------------------------------------------------------------------
Method .....: #BeginRawDoc(<n>, <c>) -> lError
Description : Start a new RAW print job using the passed parameters
-----------------------------------------------------------------------------*/
METHOD TPageScript:BeginRawDoc(nPrinter, cTitle)

::aDocInfo[1] := nPrinter
::aDocInfo[2] := cTitle
::aDocInfo[3] := StrTran(Time(), ":", "-") + ".PRN"

SET PRINTER ON
SET CONSOLE OFF
Set(_SET_DEVICE   , "PRINTER")
Set(_SET_PRINTFILE, ::aDocInfo[3], .f.)

Return ::nError

/*-----------------------------------------------------------------------------
Method .....: #PSBitmap(<n>, <n>, <n>, <n>, <x>, [<n>]) -> Self
Description : Draw a bitmap on the document.
-----------------------------------------------------------------------------*/
METHOD TPageScript:Bitmap(nTop, nLeft, nBottom, nRight, cBitmap, nTransColor, lKeepRatio)

if File(cBitmap)
   nBottom     := iif(nBottom     == NIL,        0,     nBottom     )
   nRight      := iif(nRight      == NIL,        0,     nRight      )
   nTransColor := iif(nTransColor == NIL, APS_NONE, Int(nTransColor))
   lKeepRatio  := iif(lKeepRatio  == NIL,      .f.,     lKeepRatio  )

   DllCall(::hDll, DLL_STDCALL, "PSBitmap", PSFtoI(nTop), PSFtoI(nLeft), PSFtoI(nBottom), PSFtoI(nRight), cBitmap, nTransColor, iif(lKeepRatio, 1, 0))
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #Ellipse(<n>, <n>, <n>, <n>, [<n>, <n>, <n>, <n>]) -> Self
Description : Draw an ellipse
-----------------------------------------------------------------------------*/
METHOD TPageScript:Ellipse(nTop, nLeft, nBottom, nRight, nThick, nBorderColor, nFillColor, nPattern)

// Sets default values
nThick       := iif(nThick       == NIL, APS_DEFAULT,     nThick       )
nBorderColor := iif(nBorderColor == NIL, APS_DEFAULT, Int(nBorderColor))
nFillColor   := iif(nFillColor   == NIL, APS_DEFAULT, Int(nFillColor  ))
nPattern     := iif(nPattern     == NIL, APS_DEFAULT, Int(nPattern    ))

DllCall(::hDll, DLL_STDCALL, "PSEllipseEx", PSFtoI(nTop), PSFtoI(nLeft), PSFtoI(nBottom), PSFtoI(nRight), PSFtoI(nThick), nBorderColor, nFillColor, nPattern)

Return Self

/*-----------------------------------------------------------------------------
Method .....: #EllipseEx(<n>, <n>, <n>, <n>) -> Self
Description : Draw an ellipse
-----------------------------------------------------------------------------*/
METHOD TPageScript:EllipseEx(nTop, nLeft, nBottom, nRight)

DllCall(::hDll, DLL_STDCALL, "PSEllipse", PSFtoI(nTop), PSFtoI(nLeft), PSFtoI(nBottom), PSFtoI(nRight))

Return Self

/*-----------------------------------------------------------------------------
Method .....: #EndDoc() -> Self
Description : Signal the end of the document (stop spooling)
-----------------------------------------------------------------------------*/
METHOD TPageScript:EndDoc()

// Put a WaterMark in the ForeGround
if ::nWaterMark = AWM_FOREGROUND .and. ValType(::bWaterMark) == "B"
   Eval(::bWaterMark, Self)
endif

DllCall(::hDll, DLL_STDCALL, "PSEndDoc")
::lFromDialog := .f.

Return Self

/*-----------------------------------------------------------------------------
Method .....: #EndRawDoc() -> Self
Description : Ends a RAW print job
-----------------------------------------------------------------------------*/
METHOD TPageScript:EndEmuDoc()

SET CONSOLE ON
SET PRINTER OFF
SET PRINTER TO
Set(_SET_DEVICE   , "SCREEN")
SetPRC(0, 0)

::PrintEmuFile(::aDocInfo[3], .t., ::aDocInfo[1], ::aDocInfo[2], ::aDocInfo[4], ::aDocInfo[5], ::aDocInfo[6])

::aDocInfo := {0, "", "", APS_PORTRAIT, 1, APS_COURIER}

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #EndRawDoc() -> Self
Description : Ends a RAW print job
-----------------------------------------------------------------------------*/
METHOD TPageScript:EndRawDoc()

SET CONSOLE ON
SET PRINTER OFF
SET PRINTER TO
Set(_SET_DEVICE   , "SCREEN")
SetPRC(0, 0)

::PrintRawFile(::aDocInfo[3], .t., ::aDocInfo[1], ::aDocInfo[2])

::aDocInfo := {0, "", "", APS_PORTRAIT, 1, APS_COURIER}

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #FindPrinter(<c>) -> nPrinter
Description : Finds a printer by name and returns its position in the array
-----------------------------------------------------------------------------*/
METHOD TPageScript:FindPrinter(cPrinter)

Local nPos      := -1
Local aPrinters := ::GetPrinters()

// Finds a printer position in the array
if ValType(cPrinter) == "C" .and. Len(cPrinter) > 0
   nPos := aScan(aPrinters, {|x| AllTrim(Upper(x)) == AllTrim(Upper(cPrinter))}, 1, Len(aPrinters))
endif

Return nPos

/*-----------------------------------------------------------------------------
Method .....: #Frame(<n>, <n>, <n>, <n>, [<n>, <n>, <n>, <n>, <n>]) -> Self
Description : Draw a frame
-----------------------------------------------------------------------------*/
METHOD TPageScript:Frame(nTop, nLeft, nBottom, nRight, nThick, nBorderColor, nFillColor, nPattern, nRadius)

// Sets default values
nThick       := iif(nThick       == NIL, APS_DEFAULT,     nThick       )
nBorderColor := iif(nBorderColor == NIL, APS_DEFAULT, Int(nBorderColor))
nFillColor   := iif(nFillColor   == NIL, APS_DEFAULT, Int(nFillColor  ))
nPattern     := iif(nPattern     == NIL, APS_DEFAULT, Int(nPattern    ))
nRadius      := iif(nRadius      == NIL, 0          , Int(nRadius     ))

DllCall(::hDll, DLL_STDCALL, "PSFrameEx", PSFtoI(nTop), PSFtoI(nLeft), PSFtoI(nBottom), PSFtoI(nRight), PSFtoI(nThick), nBorderColor, nFillColor, nPattern, nRadius)

Return Self

/*-----------------------------------------------------------------------------
Method .....: #FrameEx(<n>, <n>, <n>, <n>) -> Self
Description : Draw a frame
-----------------------------------------------------------------------------*/
METHOD TPageScript:FrameEx(nTop, nLeft, nBottom, nRight, nRadius)

nRadius := iif(nRadius == NIL, 0, Int(nRadius))

DllCall(::hDll, DLL_STDCALL, "PSFrame", PSFtoI(nTop), PSFtoI(nLeft), PSFtoI(nBottom), PSFtoI(nRight), nRadius)

Return Self

/*-----------------------------------------------------------------------------
Method .....: #GetAsciiToAnsi() -> lValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetAsciiToAnsi()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetAsciiToAnsi")

Return (nValue == 1)

/*-----------------------------------------------------------------------------
Method .....: #GetBorderColor() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetBorderColor()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetBorderColor")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetBorderThickness() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetBorderThickness()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetBorderThickness")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetCoorSystem() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetCoorSystem()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetCoorSystem")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetCopies() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetCopies()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetCopies")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetCPI() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetCPI()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetCPI")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetDecimalSep() -> cValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetDecimalSep()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetDecimalSep")

Return Chr(nValue)

/*-----------------------------------------------------------------------------
Method .....: #GetDefaultPrinter() -> nDefaultPrinter
Description : Returns the default Windows printer
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetDefaultPrinter()

Local nDefaultPrinter := DllCall(::hDll, DLL_STDCALL, "PSGetDefaultPrinter")

Return nDefaultPrinter + 1

/*-----------------------------------------------------------------------------
Method .....: #GetDuplex() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetDuplex()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetDuplex")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetFillColor() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFillColor()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetFillColor")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetFillPattern() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFillPattern()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetFillPattern")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetFonts() -> aFontList
Description : Retreive the printer fonts for the currently selected printer
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFonts()

Local aFonts := {}
Local cFont  := ""
Local nCount := 0
Local nLoop  := 0

nCount := DllCall(::hDll, DLL_STDCALL, "PSGetFontCount")

if nCount > 0
   for nLoop := 0 to nCount - 1
      cFont := Space(128)
      DllCall(::hDll, DLL_STDCALL, "PSGetFontNames", nLoop, @cFont)
      aAdd(aFonts, ::Buffer2String(cFont))
   next
endif

Return aFonts

/*-----------------------------------------------------------------------------
Method .....: #GetFontAngle() -> nValue
Description : Returns the current font/text angle
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFontAngle()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetFontAngle")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetFontCount() -> nValue
Description : Returns the current font count
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFontCount()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetFontCount")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetFontJustify() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFontJustify()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetJustify")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetFontName() -> cValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFontName()

Local cFont := Space(128)

DllCall(::hDll, DLL_STDCALL, "PSGetFontName", @cFont)

Return ::Buffer2String(cFont)

/*-----------------------------------------------------------------------------
Method .....: #GetFontNames() -> aFontList
Description : Retreive the name of the font from its index position
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFontNames(nFontIndex)

Local cFontName := ""
Local nCount

nCount := DllCall(::hDll, DLL_STDCALL, "PSGetFontCount")

if nFontIndex >= 1 .and. nFontIndex <= nCount
   cFontName := Space(128)
   DllCall(::hDll, DLL_STDCALL, "PSGetFontNames", nFontIndex - 1, @cFontName)
endif

Return ::Buffer2String(cFontName)

/*-----------------------------------------------------------------------------
Method .....: #GetFontStyle() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFontStyle()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetFontStyle")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetFontSize() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFontSize()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetFontSize")

Return PSItoF(nValue)

/*-----------------------------------------------------------------------------
Method .....: #GetFontBColor() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFontBColor()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetFontBColor")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetFontFColor() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetFontFColor()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetFontFColor")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetJustify() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetJustify()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetJustify")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetLPI() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetLPI()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetLPI")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetMaxHeight() -> nValue
Description : Returns the max height in current unit
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetMaxHeight()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetMaxHeight")

Return PSItoF(nValue)

/*-----------------------------------------------------------------------------
Method .....: #GetMaxWidth() -> nValue
Description : Returns the max width in current unit
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetMaxWidth()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetMaxWidth")

Return PSItoF(nValue)

/*-----------------------------------------------------------------------------
Method .....: #GetOrientation() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetOrientation()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetOrientation")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetPageSize() -> nValue
Description : Retreive the printer paper size
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPageSize()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetPageSize")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetPaperBin() -> nValue
Description : Retreive the currently selected printer paper bin
Note .....: Returns -1 if called while printing
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPaperBin()

Local nBin := DllCall(::hDll, DLL_STDCALL, "PSGetPaperBin")

Return nBin

/*-----------------------------------------------------------------------------
Method .....: #GetPaperBinCount() -> nValue
Description : Retreive the number of paper bins installed
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPaperBinCount()

Local nCount := DllCall(::hDll, DLL_STDCALL, "PSGetPaperBinCount")

Return nCount

/*-----------------------------------------------------------------------------
Method .....: #GetPaperBinNames() -> cValue
Description : Retrieve the name of any of the available paper bin
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPaperBinNames(nIndex)

Local cName := ""
Local nCount   := 0

nCount := DllCall(::hDll, DLL_STDCALL, "PSGetPaperBinCount")

if nIndex >=1 .and. nIndex <= nCount
   cName := Space(24)
   DllCall(::hDll, DLL_STDCALL, "PSGetPaperBinNames", nIndex - 1, @cName)
endif

Return ::Buffer2String(cName)

/*-----------------------------------------------------------------------------
Method .....: #GetPaperBinNumbers() -> nValue
Description : Retrieve the number of any of the available paper bin
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPaperBinNumbers(nIndex)

Local nNumber := -1
Local nCount  := 0

nCount := DllCall(::hDll, DLL_STDCALL, "PSGetPaperBinCount")

if nIndex >=1 .and. nIndex <= nCount
   nNumber := DllCall(::hDll, DLL_STDCALL, "PSGetPaperBinNumbers", nIndex - 1)
endif

Return nNumber

/*-----------------------------------------------------------------------------
Method .....: #GetPaperCount() -> nValue
Description : Retreive the number of paper installed
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPaperCount()

Local nCount := DllCall(::hDll, DLL_STDCALL, "PSGetPaperCount")

Return nCount

/*-----------------------------------------------------------------------------
Method .....: #GetPaperNames() -> nValue
Description : Retreive the name of a paper type based on its index position
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPaperNames(nIndex)

Local cName  := ""
Local nCount := 0

nCount := DllCall(::hDll, DLL_STDCALL, "PSGetPaperCount")

if nIndex >=1 .and. nIndex <= nCount
   cName := Space(64)
   DllCall(::hDll, DLL_STDCALL, "PSGetPaperNames", nIndex - 1, @cName)
endif

Return ::Buffer2String(cName)

/*-----------------------------------------------------------------------------
Method .....: #GetPaperNumbers() -> nValue
Description : Retreive the number of the paper type pointed by nIndex
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPaperNumbers(nIndex)

Local nNumber := -1
Local nCount  := 0

nCount := DllCall(::hDll, DLL_STDCALL, "PSGetPaperCount")

if nIndex >=1 .and. nIndex <= nCount
   nNumber := DllCall(::hDll, DLL_STDCALL, "PSGetPaperNumbers", nIndex - 1)
endif

Return nNumber

/*-----------------------------------------------------------------------------
Method .....: #GetPrinter() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPrinter()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetPrinter")

Return nValue + 1

/*-----------------------------------------------------------------------------
Method .....: #GetPrinterCount() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPrinterCount()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetPrinterCount")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetPrinters() -> aClone(saPrinters)
Description : Returns the list of available printers for this computer
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPrinters()

Local aPrinters := {}
Local cPrinter  := ""
Local nCount    := 0
Local nLoop     := 0

nCount := DllCall(::hDll, DLL_STDCALL, "PSGetPrinterCount")

for nLoop := 0 to nCount - 1
   cPrinter := Space(256)
   DllCall(::hDll, DLL_STDCALL, "PSGetPrinterNames", nLoop, @cPrinter)
   aAdd(aPrinters, ::Buffer2String(cPrinter))
next

Return aClone(aPrinters)

/*-----------------------------------------------------------------------------
Method .....: #GetPrinterCaps() -> aCaps
Description : Retreive the printer capabilities of the selected printer
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPrinterCaps()

Local cDllTemplate
Local nAreaWidth
Local nAreaHeight
Local nTopMargin
Local nLeftMargin
Local nPaperWidth
Local nPaperHeight
// Local nMAreaWidth
// Local nMAreaHeight
Local nHPixelsInch
Local nVPixelsInch
Local nBitDepth

cDllTemplate := DllPrepareCall(::hDll, DLL_STDCALL, "PSGetPrinterCaps")

nAreaWidth   := DllExecuteCall(cDllTemplate, HORZRES)           // Printable Horz area (Width)    Pixels
nAreaHeight  := DllExecuteCall(cDllTemplate, VERTRES)           // Printable Vert area (Height)   Pixels
nTopMargin   := DllExecuteCall(cDllTemplate, PHYSICALOFFSETY)   // Top margin                     Pixels
nLeftMargin  := DllExecuteCall(cDllTemplate, PHYSICALOFFSETX)   // Left margin                    Pixels
nPaperWidth  := DllExecuteCall(cDllTemplate, PHYSICALWIDTH)     // Total paper width              Pixels
nPaperHeight := DllExecuteCall(cDllTemplate, PHYSICALHEIGHT)    // Total paper height             Pixels
// nMAreaWidth  := DllExecuteCall(cDllTemplate, HORZSIZE)          // Printable Horz area            mm
// nMAreaHeight := DllExecuteCall(cDllTemplate, VERTSIZE)          // Printable Vert area            mm
nHPixelsInch := DllExecuteCall(cDllTemplate, LOGPIXELSX)        // Number of Horz pixels/Inch     Pixels
nVPixelsInch := DllExecuteCall(cDllTemplate, LOGPIXELSY)        // Number of Vert pixels/Inch     Pixels
nBitDepth    := DllExecuteCall(cDllTemplate, NUMCOLORS)         // Bit depth (number of bits per pixel)

Return {nPaperWidth , ;
        nPaperHeight, ;
        nAreaWidth  , ;
        nAreaHeight , ;
        nTopMargin  , ;
        nLeftMargin , ;
        nHPixelsInch, ;
        nVPixelsInch, ;
        nBitDepth}

/*-----------------------------------------------------------------------------
Method .....: #GetPrinterCapsEx(<n>) -> nCap
Description : Retreive one of the printer capabilities of the selected printer
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPrinterCapsEx(nCap)

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetPrinterCaps", nCap)

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetPrinterHandle() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPrinterHandle()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetPrinterHandle")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetPrinterNames(<n>) -> cValue
Description : Returns the name of the selected printer
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetPrinterNames(nPrinter)

Local cPrinter := Space(256)

DllCall(::hDll, DLL_STDCALL, "PSGetPrinterNames", nPrinter - 1, @cPrinter)

Return ::Buffer2String(cPrinter)

/*-----------------------------------------------------------------------------
Method .....: #GetTitle() -> cValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetTitle()

Local cTitle := Space(256)

DllCall(::hDll, DLL_STDCALL, "PSGetTitle", @cTitle)

Return ::Buffer2String(cTitle)

/*-----------------------------------------------------------------------------
Method .....: #Get
Description :
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetTextHeight(cText)

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetTextHeight", cText)

Return PSItoF(nValue)

/*-----------------------------------------------------------------------------
Method .....: #Get
Description :
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetTextWidth(cText)

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetTextWidth", cText)

Return PSItoF(nValue)

/*-----------------------------------------------------------------------------
Method .....: #GetUnit() -> nValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetUnit()

Local nValue := DllCall(::hDll, DLL_STDCALL, "PSGetUnit")

Return nValue

/*-----------------------------------------------------------------------------
Method .....: #GetUseDIB() -> lValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetUseDIB()

Local lValue := (DllCall(::hDll, DLL_STDCALL, "PSGetUseDIB") == 1)

Return lValue

/*-----------------------------------------------------------------------------
Method .....: #Version() -> cVersionNumber
Description : Returns the DLL version number
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetVersion()

Local cVersion := Space(24)

DllCall(::hDll, DLL_STDCALL, "PSGetVersion", @cVersion)

Return ::Buffer2String(cVersion)

/*-----------------------------------------------------------------------------
Method .....: #GetXerox() -> lValue
Description : Returns the current setting
-----------------------------------------------------------------------------*/
METHOD TPageScript:GetXerox()

Local lValue := (DllCall(::hDll, DLL_STDCALL, "PSGetXerox") == 1)

Return lValue

/*-----------------------------------------------------------------------------
Method .....: #IsPreviewVisible() -> lValue
Description : Returns .t. is print preview window is visible, otherwise, returns .f.
-----------------------------------------------------------------------------*/
METHOD TPageScript:IsPreviewVisible()

Local lValue := (DllCall(::hDll, DLL_STDCALL, "PSIsPreviewVisible") == 1)

Return lValue

/*-----------------------------------------------------------------------------
Method .....: #Line(<n>, <n>, <n>, <n>, [<n>, <n>]) -> NIL
Description : Draw a line
-----------------------------------------------------------------------------*/
METHOD TPageScript:Line(nTop, nLeft, nBottom, nRight, nThick, nBorderColor)

nThick       := iif(nThick       == NIL, APS_DEFAULT,     nThick       )
nBorderColor := iif(nBorderColor == NIL, APS_DEFAULT, Int(nBorderColor))

DllCall(::hDll, DLL_STDCALL, "PSLineEx", PSFtoI(nTop), PSFtoI(nLeft), PSFtoI(nBottom), PSFtoI(nRight), PSFtoI(nThick), nBorderColor)

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #LineEx(<n>, <n>, <n>, <n>) -> NIL
Description : Draw a line
-----------------------------------------------------------------------------*/
METHOD TPageScript:LineEx(nTop, nLeft, nBottom, nRight)

DllCall(::hDll, DLL_STDCALL, "PSLine", PSFtoI(nTop), PSFtoI(nLeft), PSFtoI(nBottom), PSFtoI(nRight))

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #NewPage() -> NIL
Description : Signal the end of page, page eject
-----------------------------------------------------------------------------*/
METHOD TPageScript:NewPage()

// Put a WaterMark in the ForeGround
if ::nWaterMark = AWM_FOREGROUND .and. ValType(::bWaterMark) == "B"
   Eval(::bWaterMark, Self)
endif

DllCall(::hDll, DLL_STDCALL, "PSNewPage")

// Put a WaterMark in the BackGround
if ::nWaterMark = AWM_BACKGROUND .and. ValType(::bWaterMark) == "B"
   Eval(::bWaterMark, Self)
endif

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #PrintDialog() -> lPrint
Description : Shows the printer dialog and returns if the user clicked OK
-----------------------------------------------------------------------------*/
METHOD TPageScript:PrintDialog()

Local nValue

::lFromDialog := .f.

nValue := DllCall(::hDll, DLL_STDCALL, "PSPrintDialog")

if nValue == 1
   ::lFromDialog := .t.
endif

Return (nValue == 1)  // 1 == Print, 0 == Error or don't print

/*-----------------------------------------------------------------------------
Function ...: PSPrintEmuFile(<c>, [<l>, <n>, <c>, <n>, <n>, <c>]) -> lSuccess
Description : Print the file pointed by cFile and optionnaly deletes it.
Author .....: Stephan St-Denis
Date .......: September 2002
Notes ......: You're free to enhance this function. If you do so, please let
              us know : tech@abeelabs.com
-----------------------------------------------------------------------------*/
METHOD TPageScript:PrintEmuFile(cFileName, lDelete, nPrinter, cTitle, nOrientation, nCopies, cFont)

Local lSuccess := .t.                  // Return value
Local nStyle   := APS_PLAIN            // Start with plain font style
Local nRow     := 0                    // Print head line
Local nCol     := 0                    // Print head column
Local lBold    := .f.                  // Bold flag
Local lItalic  := .f.                  // Italic flag
Local lUnder   := .f.                  // Underline flag
Local lStrike  := .f.                  // Strikeout flag
Local cPrintLine                       // Line to print
Local cBuffer                          // File buffer
Local nLoop                            // For / Next loop
Local nCtrl                            // Control character in ASCII
Local nChar                            // Character read
Local nPos                             // Pos of CRLF, EJECT or ESCAPE in buffer (in any)
Local nHandle                          // File handle
Local nBytes                           // Number of bytes read from file
Local nSaveUnit								// Unit in use before in order to restore it at the end

lDelete      := iif(lDelete      == NIL, .t.         , lDelete     )
nOrientation := iif(nOrientation == NIL, APS_PORTRAIT, nOrientation)
nPrinter     := iif(nPrinter     == NIL, 0           , nPrinter    )
cFont        := iif(cFont        == NIL, APS_COURIER , cFont       )
lSuccess     := (nHandle := FOpen(cFileName)) <> -1

if lSuccess
   ::BeginDoc(nPrinter, cTitle, nOrientation, nCopies)          // Start document
	nSaveUnit := ::GetUnit()
   ::SetUnit(APS_TEXT)                                          // Set to millimeters. We'll handle the position by ourself
   ::SetFontAttributes(cFont, APS_PLAIN, 12)                    // Set default font

   while .t.
      cBuffer := Space(pfBUFFERLEN)                             // File buffer
      nBytes  := FRead(nHandle, @cBuffer, pfBUFFERLEN)          // Read a chunk

      if nBytes == 0                                            // If Eof
         exit                                                   // Exit
      endif

      nPos       := At(Chr(13) + Chr(10), cBuffer)              // Finds CR (if any)
      nLoop      := 1
      cPrintLine := ""                                          // Text to print

      if nPos = 0
         nPos := nBytes
      else
         nPos++
      endif

      while .t.
         nChar := Asc(SubStr(cBuffer, nLoop, 1))

         do case
            case nChar == 27                                    // ESCAPE code

               if nLoop < nPos                                  // Advances to next char
                  nLoop++
                  nCtrl := Asc(SubStr(cBuffer, nLoop, 1))       // Read the control character

                  if Len(cPrintLine) != 0                       // If there's still something to print...  // Changed by STD - 2008-02-25 - 1.3.5.0
                     ::TextOut(nRow, nCol, cPrintLine, , , , , nStyle)    // Print the left part of the string, before the ESCAPE code
                     nCol += Len(cPrintLine)
                     cPrintLine := ""
                  endif

                  do case
                     case nCtrl == 66 .and. ! lBold             // B - Set   Bold
                        lBold  := .t.
                        nStyle += APS_BOLD
      
                     case nCtrl == 98 .and. lBold               // b - Reset Bold
                        lBold  := .f.
                        nStyle -= APS_BOLD
      
                     case nCtrl == 73 .and. ! lItalic           // I - Set   Italic
                        lItalic := .t.
                        nStyle  += APS_ITALIC
      
                     case nCtrl == 105 .and. lItalic            // i - Reset Italic
                        lItalic := .f.
                        nStyle  -= APS_ITALIC
      
                     case nCtrl == 85 .and. ! lUnder            // U - Set   Underline
                        lUnder := .t.
                        nStyle += APS_UNDERLINE
      
                     case nCtrl == 117 .and. lUnder             // u - Reset Underline
                        lUnder := .f.
                        nStyle -= APS_UNDERLINE
      
                     case nCtrl == 83 .and. ! lStrike           // S - Set   Strikeout
                        lStrike := .t.
                        nStyle  += APS_STRIKEOUT
      
                     case nCtrl == 115 .and. lStrike            // s - Reset Strikeout
                        lStrike := .f.
                        nStyle  -= APS_STRIKEOUT

                     case nCtrl == 7 // 8 is already taken         8 CPI
                        ::SetCPI(8)
      
                     case nCtrl == 10                           // 10 CPI
                        ::SetCPI(10)
      
                     case nCtrl == 12                           // 12 CPI
                        ::SetCPI(12)
      
                     case nCtrl == 15                           // 15 CPI
                        ::SetCPI(15)
      
                     case nCtrl == 17                           // 17 CPI (16.66)
                        ::SetCPI(17)
      
                     case nCtrl == 18                           // 18 CPI
                        ::SetCPI(18)
      
                     case nCtrl == 20                           // 20 CPI
                        ::SetCPI(20)
      
                     case nCtrl == 6                            // 6 LPI
                        ::SetLPI(6)
      
                     case nCtrl == 8                            // 8 LPI
                        ::SetLPI(8)
         
                  endcase

                  nLoop++
               endif
                  
            case nChar == 12                                    // EJECT code
               nLoop++

               if Len(cPrintLine) != 0                          // If there's still something to print...  // Changed by STD - 2008-02-25 - 1.3.5.0
                  ::TextOut(nRow, nCol, cPrintLine, , , , , nStyle)   // Print the rest
                  nCol += Len(cPrintLine)
                  cPrintLine := ""
               endif

               nRow := 0                                        // Reset row to 0
               nCol := 0                                        // Reset column to 0
               ::NewPage()                                      // Page eject

            case nChar == 13                                    // CR/LF code
               nLoop++

               if nLoop <= nPos
                  if Asc(SubStr(cBuffer, nLoop, 1)) == 10
                     nLoop++

                     if Len(cPrintLine) != 0                    // If there's still something to print...  // Changed by STD - 2008-02-25 - 1.3.5.0
                        ::TextOut(nRow, nCol, cPrintLine, , , , , nStyle)
                        cPrintLine := ""
                     endif
      
                     nRow++                                     // For each CRLF, skip line
                     nCol := 0                                  // Reset to column 0
      
                     FSeek(nHandle, -(nBytes - nLoop + 1), FS_RELATIVE)   // Position file pointer after EJECT or CRLF
                  else
                     nCol := 0                                  // Reset to column 0
                  endif
               endif

            otherwise
               cPrintLine := cPrintLine + SubStr(cBuffer, nLoop, 1)
               nLoop++

         endcase

         if nLoop > nPos
            exit
         endif
      enddo
   enddo

   if Len(cPrintLine) != 0                                      // If there's still something to print...  // Changed by STD - 2008-02-25 - 1.3.5.0
      ::TextOut(nRow, nCol, cPrintLine, , , , , nStyle)
      cPrintLine := ""
   endif

   ::SetUnit(nSaveUnit)                                         // Set to whatever unit was in use before
   ::EndDoc()                                                   // End the document

   FClose(nHandle)

endif

if lDelete
   FErase(cFileName)
endif

SetPRC(0, 0)

Return lSuccess

/*-----------------------------------------------------------------------------
Function ...: PrintRawFile(<c>, [<l>, <n>, <c>]) -> lSuccess
Description : Print the file pointed by cFile and optionnaly deletes it.
              No processing on file. The file is sent "as is" to the printer.
Author .....: Stephan St-Denis
Date .......: September 2002
-----------------------------------------------------------------------------*/
METHOD TPageScript:PrintRawFile(cFileName, lDelete, nPrinter, cTitle)

Local lSuccess  // Return value
Local nHandle   // File handle
Local cBuffer   // File buffer
Local nBytes    // Number of bytes read from file

lDelete  := iif(lDelete  == NIL, .t.       , lDelete )
nPrinter := iif(nPrinter == NIL, 0         , nPrinter)
cTitle   := iif(cTitle   == NIL, "Untitled", cTitle  )
lSuccess := File(cFileName)

lSuccess := (nHandle := FOpen(cFileName)) <> -1

if lSuccess
   ::SetPrinter(nPrinter)
   ::SetTitle(cTitle)

   DllCall(::hDll, DLL_STDCALL, "PSBeginRawDoc")

   while .t.
      cBuffer := Space(pfBUFFERLEN)                             // File buffer
      nBytes  := FRead(nHandle, @cBuffer, pfBUFFERLEN)          // Read a chunk

      if nBytes == 0                                            // If Eof
         exit                                                   // Exit
      endif

      DllCall(::hDll, DLL_STDCALL, "PSPrintRawData", cBuffer, nBytes)
   enddo

   FClose(nHandle)

   if lDelete
      FErase(cFileName)
   endif

   DllCall(::hDLL, DLL_STDCALL, "PSEndRawDoc")
endif

Return lSuccess

/*-----------------------------------------------------------------------------
Method .....: #SetAsciiToAnsi(<l>) -> Self
Description : Set the conversion from Ascii to Ansi for text strings.
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetAsciiToAnsi(lValue)

if ValType(lValue) == "L"
   DllCall(::hDll, DLL_STDCALL, "PSSetAsciiToAnsi", iif(lValue, 1, 0))
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetBorder([<n>, <n>]) -> Self
Description : Sets the attributes used to draw lines and borders
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetBorder(nThickness, nBorderColor)

if ValType(nThickness) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetBorderThickness", PSFtoI(nThickness))
endif

if ValType(nBorderColor) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetBorderColor", nBorderColor)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetBorderColor(<n>) -> Self
Description : Sets the border color
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetBorderColor(nBorderColor)

if ValType(nBorderColor) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetBorderColor", nBorderColor)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetBorderThickness(<n>) -> Self
Description : Sets the border thickness used to draw lines and borders
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetBorderThickness(nThickness)

if ValType(nThickness) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetBorderThickness", PSFtoI(nThickness))
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetClipperComp(<l>) -> Self
Description : Set Clipper compatible calls for TextOut() and TextBox()
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetClipperComp(lClipper)

if ValType(lClipper) == "L"
   ::lClipper := lClipper
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetCoorSystem(<n>) -> Self
Description : Sets the coordinate system
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetCoorSystem(nCoor)

if ValType(nCoor) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetCoorSystem", nCoor)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetCopies([<n>]) -> Self
Description : Sets the number of copies
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetCopies(nCopies)

if ValType(nCopies) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetCopies", nCopies)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetCPI(<n>) -> Self
Description : Sets the number of characters per inch (Text mode only)
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetCPI(nCPI)

if ValType(nCPI) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetCPI", nCPI)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetDevice(<n>) -> Self
Description : Sets the device to use for the next print job
Choices ....: DEV_PRINTER - The output will be sent to a printer
              DEV_PREVIEW - The output will be sent to the print preview dialog
              DEV_PDFFILE - The output will create a PDF file (must set filename)
              DEV_EMFFILE - Print to a serie of EMF files
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetDevice(nDevice)

if ValType(nDevice) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetDevice", nDevice)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetDirectPrint(<c>) -> Self
Description : Set the direct print flag (used for very special cases)
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetDirectPrint(lDirect)

if ValType(lDirect) == "L"
   DllCall(::hDll, DLL_STDCALL, "PSSetDirectPrint", iif(lDirect, 1, 0))
endif

Return self

/*-----------------------------------------------------------------------------
Method .....: #SetDecimalSep(<c>) -> Self
Description : Sets the decimal separator character
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetDecimalSep(cSep)

if ValType(cSep) == "C" .and. Len(cSep) > 0
   DllCall(::hDll, DLL_STDCALL, "PSSetDecimalSep", Asc(cSep))
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetDuplex([<n>]) -> Self
Description : Sets the duplex mode
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetDuplex(nDuplex)

if ValType(nDuplex) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetDuplex", nDuplex)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFileName(<c>) -> Self
Description : Sets the file name of a PDF file
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFileName(cFileName)

if ValType(cFileName) == "C" .and. ! Empty(cFileName)
   DllCall(::hDll, DLL_STDCALL, "PSSetFileName", cFileName)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFill(<n>, [<n>]) -> Self
Description : Sets the color used to fill shapes, like boxes and ellipes
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFill(nFillColor, nFillPattern)

if ValType(nFillColor) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFillColor", nFillColor)
endif

if ValType(nFillPattern) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFillPattern", nFillPattern)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFillColor(<n>) -> Self
Description : Sets the color used to fill shapes, like boxes and ellipes
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFillColor(nFillColor)

if ValType(nFillColor) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFillColor", nFillColor)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFillPattern(<n>) -> Self
Description : Sets the pattern used to fill shapes, like boxes and ellipes
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFillPattern(nFillPattern)

if ValType(nFillPattern) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFillPattern", nFillPattern)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFont([<n>, <n>, <n>, <n>, <n>]) -> Self
Description : Sets the font attributes used by each call to PSTextOut() and others
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFontAttributes(cFont, nStyle, nSize, nTFColor, nTBColor, nAngle)

if ValType(cFont) == "C"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontName"  , cFont)
endif

if ValType(nStyle) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontStyle" , nStyle)
endif

if ValType(nSize) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontSize"  , PSFtoI(nSize))
endif

if ValType(nTFColor) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontFColor", nTFColor)
endif

if ValType(nTBColor) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontBColor", nTBColor)
endif

if ValType(nAngle) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontAngle" , nAngle)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFont() -> Self
Description : Sets the font
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFontAngle(nAngle)

if ValType(nAngle) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontAngle" , nAngle)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFont() -> Self
Description : Sets the font
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFontBColor(nTBColor)

if ValType(nTBColor) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontBColor", nTBColor)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFont() -> Self
Description : Sets the font
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFontFColor(nTFColor)

if ValType(nTFColor) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontFColor", nTFColor)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFont() -> Self
Description : Sets the font
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFontName(cFont)

if ValType(cFont) == "C"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontName"  , cFont)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFont() -> Self
Description : Sets the font
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFontSize(nSize)

if ValType(nSize) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontSize"  , PSFtoI(nSize))
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetFont() -> Self
Description : Sets the font
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetFontStyle(nStyle)

if ValType(nStyle) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetFontStyle" , nStyle)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetJustify(<n>) -> Self
Description : Sets justification for TextOut
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetJustify(nJustify)

if ValType(nJustify) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetJustify" , nJustify)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetLPI(<n>) -> Self
Description : Sets the number of lines per inch (Text mode only)
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetLPI(nLPI)

if ValType(nLPI) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetLPI", nLPI)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetOrientation(<n>) -> Self
Description : Sets the paper orientation
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetOrientation(nOrientation)

if ValType(nOrientation) == "N" .and. (nOrientation == APS_PORTRAIT .or. nOrientation == APS_LANDSCAPE)
   DllCall(::hDll, DLL_STDCALL, "PSSetOrientation", nOrientation)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPaperBin(<n>) -> Self
Description : Sets the paper bin
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPaperBin(nPaperBin)

if ValType(nPaperBin) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetPaperBin", nPaperBin)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPDFCharSet(<n>) -> Self
Description : Set the PDF charset to be use
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPDFCharSet(nCharSet)

if ValType(nCharSet) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetPDFCharSet", nCharSet)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPDFOwnerPassword(<c>) -> Self
Description : Set the encryption password for PDF documents
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPDFOwnerPassword(cPassword)

if ValType(cPassword) == "C" .and. ! Empty(cPassword)
   DllCall(::hDll, DLL_STDCALL, "PSSetPDFOwnerPassword", cPassword)
endif

Return Self


/*-----------------------------------------------------------------------------
Method .....: #SetPDFEncoding(<n>) -> Self
Description : Set the internal encoding for PDF documents, default = 0;
            : 0 -> WinAnsiEncoding  ( Regular encoding for Latin-text Type 1 
		   and TrueType fonts on Windows OS.)
	    : 1 -> StandardEncoding (Adobe Latin-text encoding for standard and 
		   other Type 1 fonts in case of non-symbolic fonts) and the 
                   built-in encoding in case of symbolic fonts.)
            : 2 -> PDFDocEncoding (Rarely used non-Unicode encoding with a 
		   single byte for each character.)   	  
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPDFEncoding(nEncoding)

if ValType(nEncoding) == "N"
   DllCall(::hDll, DLL_STDCALL,"PSSetPDFEncoding",nEncoding)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPDFVersion(<n>) -> Self
Description : Sets the PDF version to be used for creation of PDF
            : 0 - PDFVersion 1.4
            : 1 - PDFVersion 1.5
            : 2 - PDFVersion 1.6
            : 3 - PDfVersion 1.7 
-----------------------------------------------------------------------------*/
METHOD TPagescript:SetPDFVersion(nVersion)

if ValType(nVersion) == "N"
   DllCall(::hDll,DLL_STDCALL,"PSSetPDFVersion",nVersion)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #ShowPDF(<l>) -> Self
Description : Show PDF in default reader after creation
-----------------------------------------------------------------------------*/
METHOD TPageScript:ShowPDF(lShow)

if ValType(lShow) == "L"
   DllCall(::hDll,DLL_STDCALL,"PSShowPDF",iif(lShow, 1, 0))
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPDFEmbeddedPDFFonts(<n>) -> Self
Description : Set usage of embedded fonts
            : 0 -> None
            : 1 -> Full
            : 2 -> Subset 
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPDFEmbeddedFonts(nEmbedded)

if ValType(nEmbedded) == "N"
   DllCall(::hDll,DLL_STDCALL,"PSSetPDFEmbeddedFonts",nEmbedded)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPageSize(<n>) -> Self
Description : Sets the page size to a predifined paper size
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPageSize(nPageSize)

if ValType(nPageSize) == "N" // .and. (nPageSize >= DMPAPER_FIRST .and. nPageSize <= DMPAPER_LAST)
   DllCall(::hDll, DLL_STDCALL, "PSSetPageSize", nPageSize)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPrinter(<n>) -> Self
Description : Sets the printer number to which we want to print
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPrinter(nPrinter)

if ValType(nPrinter) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetPrinter", nPrinter - 1)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPWState(<n>) -> Self
Description : Set the print preview window state
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPWState(nState)

if (ValType(nState) == "N") .and. (nState >= PWS_MINIMIZED) .and. (nState <= PWS_AUTO)
   DllCall(::hDll, DLL_STDCALL, "PSSetPWState", nState)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPWPosition(<n>, <n>) -> Self
Description : Set the print preview window position
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPWPosition(nLeft, nTop)

if (ValType(nLeft) == "N") .and. (ValType(nTop) == "N")
   DllCall(::hDll, DLL_STDCALL, "PSSetPWPosition", nLeft, nTop)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPWSize(<n>, <n>) -> Self
Description : Set the print preview window size (-1, -1 = Auto size)
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPWSize(nWidth, nHeight)

if (ValType(nWidth) == "N") .and. (ValType(nHeight) == "N")
   DllCall(::hDll, DLL_STDCALL, "PSSetPWSize", nWidth, nHeight)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPWBounds(<n>, <n>, <n>, <n>) -> Self
Description : Set the print preview window bounds (position and size at the same time)
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPWBounds(nLeft, nTop, nWidth, nHeight)

if (ValType(nLeft) == "N") .and. (ValType(nTop) == "N") .and. (ValType(nWidth) == "N") .and. (ValType(nHeight) == "N")
   DllCall(::hDll, DLL_STDCALL, "PSSetPWBounds", nLeft, nTop, nWidth, nHeight)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPWColors(<n>, <n>, <n>, <n>) -> Self
Description : Set the print preview window colors
Version ....: 3.0.0.0
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPWColors(nBackground, nPaper, nShadow, nToolbar)

if (ValType(nBackground) == "N") .and. (ValType(nPaper) == "N") .and. (ValType(nShadow) == "N") .and. (ValType(nToolbar) == "N")
   DllCall(::hDll, DLL_STDCALL, "PSSetPWColors", nBackground, nPaper, nShadow, nToolbar)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetPWZoomLevel(<n>) -> Self
Description : Set the print preview window zoom level
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetPWZoomLevel(nZoomLevel)

if (ValType(nZoomLevel) == "N")
   DllCall(::hDll, DLL_STDCALL, "PSSetPWZoomLevel", nZoomLevel)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetRowCol(<n>, <n>) -> Self
Description : Sets the number of rows and columns in the way PageScript for Clipper does
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetRowCol(nRow, nCol)

if ValType(nRow) == "N" .and. ValType(nCol) == "N"
   DllCall(::hDll, DLL_STDCALL, "PSSetRowCol", nRow, nCol)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetTitle(<c>) -> Self
Description : Sets the title of the document
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetTitle(cTitle)

if ValType(cTitle) == "C" .and. ! Empty(cTitle)
   DllCall(::hDll, DLL_STDCALL, "PSSetTitle", cTitle)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetUnit(<n>) -> Self
Description : Sets the unit used to calculate dimensions and placement
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetUnit(nUnit)

if ValType(nUnit) == "N"
   ::nUnit := nUnit
   DllCall(::hDll, DLL_STDCALL, "PSSetUnit", nUnit)
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetUseDIB(<l>) -> Self
Description : Sets the use of DIB (Device Independant Bitmap) when printing bitmaps
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetUseDIB(lUseDIB)

if ValType(lUseDIB) == "L"
   DllCall(::hDll, DLL_STDCALL, "PSSetUseDIB", iif(lUseDIB, 1, 0))
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #SetXerox(<l>) -> Self
Description : Sets the use of Xerox compatible printing mode (Slower, but
            compatible with all Xerox printers)
-----------------------------------------------------------------------------*/
METHOD TPageScript:SetXerox(lXerox)

if ValType(lXerox) == "L"
   DllCall(::hDll, DLL_STDCALL, "PSSetXerox", iif(lXerox, 1, 0))
endif

Return Self

/*-----------------------------------------------------------------------------
Method .....: #PSTextBox(<n>, <n>, <n>, <n>, <x>, [<n>, <c>, <n>, <n>, <n>, <n>,
                       <n>, <n>]) -> NIL
Description : Prints a string in a box at position X1,Y1, X2,Y2 using parameters
-----------------------------------------------------------------------------*/
METHOD TPageScript:TextBox(nTop, nLeft, nBottom, nRight, cText, nJustify, cFont, nSize, ;
                           nStyle, nFColor, nBColor, nThick)

Local Temp

if (ValType(cText) == "C" .and. Len(cText) < 65001)  // Must be a string and Length of less than 65001 bytes
   cFont      := iif(cFont      == NIL, ""        ,     cFont     )
   nJustify   := iif(nJustify   == NIL, APS_DEFAULT, Int(nJustify ))
   nStyle     := iif(nStyle     == NIL, APS_DEFAULT, Int(nStyle   ))
   nSize      := iif(nSize      == NIL, APS_DEFAULT,     nSize     )
   nFColor    := iif(nFColor    == NIL, APS_DEFAULT, Int(nFColor  ))
   nBColor    := iif(nBColor    == NIL, APS_DEFAULT, Int(nBColor  ))
   nThick     := iif(nThick     == NIL, APS_DEFAULT,     nThick    )

   // Clipper compatible call
   if ::lClipper
      Temp   := nSize
      nSize  := nStyle
      nStyle := Temp
   endif

   DllCall(::hDll, DLL_STDCALL, "PSTextBoxEx", PSFtoI(nTop), PSFtoI(nLeft), PSFtoI(nBottom), PSFtoI(nRight), cText, nJustify, cFont, PSFtoI(nSize), nStyle, nFColor, nBColor, PSFtoI(nThick))
endif

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #PSTextBoxEx(<n>, <n>, <n>, <n>, <x>) -> NIL
Description : Prints a string in a box at position X1,Y1, X2,Y2 using parameters
-----------------------------------------------------------------------------*/
METHOD TPageScript:TextBoxEx(nTop, nLeft, nBottom, nRight, cText)

if (ValType(cText) == "C" .and. Len(cText) < 65001 .and. ! (cText == ""))  // Must be a non empty string and Length of less than 65001 bytes
   DllCall(::hDll, DLL_STDCALL, "PSTextBox", PSFtoI(nTop), PSFtoI(nLeft), PSFtoI(nBottom), PSFtoI(nRight), cText)
endif

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #TextOut(<n>, <n>, <x>, [<c>, <n>, <n>, <n>, <n>, <n>, <n>, <n>]) -> NIL
Description : Prints a string at position X,Y using parameters

PSTEXTOUT(YY1, XX2 + XXO, ' {continued)', pic, just, font, PTS3, APS_PLAIN)
-----------------------------------------------------------------------------*/
METHOD TPageScript:TextOut(nTop, nLeft, xValue, cPicture, nJustify, cFont, nSize, ;
                           nStyle, nTFColor, nTBColor, nAngle)

Local cValType
Local Temp

cValType := ValType(xValue)
nTop     := iif(nTop     == NIL, APS_DEFAULT,     nTop     )
nLeft    := iif(nLeft    == NIL, APS_DEFAULT,     nLeft    )
cPicture := iif(cPicture == NIL, ""         ,     cPicture )
nJustify := iif(nJustify == NIL, APS_DEFAULT, Int(nJustify))
cFont    := iif(cFont    == NIL, ""         ,     cFont    )
nStyle   := iif(nStyle   == NIL, APS_DEFAULT, Int(nStyle  ))
nSize    := iif(nSize    == NIL, APS_DEFAULT,     nSize )
nTFColor := iif(nTFColor == NIL, APS_DEFAULT, Int(nTFColor))
nTBColor := iif(nTBColor == NIL, APS_DEFAULT, Int(nTBColor))
nAngle   := iif(nAngle   == NIL, APS_DEFAULT, Int(nAngle  ))

if Empty(cPicture)
   do case
      case cValType == "N"
         cPicture := "@N"

      case cValType == "D"
         cPicture := "@D"

      case cValType == "L"
         cPicture := "@Y"

      otherwise
         cPicture := "@X"

   endcase
endif

xValue := Transform(xValue, cPicture)

if nAngle <> APS_DEFAULT .and. (nAngle < 0 .or. nAngle > 360)
   nAngle := 0
endif

// Clipper compatible call
if ::lClipper
   Temp   := nSize
   nSize  := nStyle
   nStyle := Temp
endif

if ! xValue == ""
   DllCall(::hDll, DLL_STDCALL, "PSTextOutEx", PSFtoI(nTop), PSFtoI(nLeft), xValue, nJustify, cFont, PSFtoI(nSize), nStyle, nTFColor, nTBColor, nAngle)
endif

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #TextOutEx(<n>, <n>, <x>, [<c>]) -> NIL
Description : Prints a string at position X,Y using parameters
-----------------------------------------------------------------------------*/
METHOD TPageScript:TextOutEx(nTop, nLeft, xValue, cPicture)

Local cValType := ValType(xValue)

nTop     := iif(nTop     == NIL, APS_DEFAULT,  nTop   )
nLeft    := iif(nLeft    == NIL, APS_DEFAULT,  nLeft  )
cPicture := iif(cPicture == NIL, ""         , cPicture)

if Empty(cPicture)
   do case
      case cValType == "N"
         cPicture := "@N"

      case cValType == "D"
         cPicture := "@D"

      case cValType == "L"
         cPicture := "@Y"

      otherwise
         cPicture := "@X"

   endcase
endif

xValue := Transform(xValue, cPicture)

if ! xValue == ""
   DllCall(::hDll, DLL_STDCALL, "PSTextOut", PSFtoI(nTop), PSFtoI(nLeft), xValue)
endif

Return NIL

/*-----------------------------------------------------------------------------
Method .....: #WaterMark([<b>]) -> Previous WaterMark
Description : Sets/Returns the current WaterMark
Note .......: This method is not implemented in PSCRIPT.DLL
-----------------------------------------------------------------------------*/
METHOD TPageScript:WaterMark(bWaterMark, nWaterMark)

Local bOldWaterMark := ::bWaterMark
Local nOldWaterMark := ::nWaterMark

nWaterMark := iif(nWaterMark == NIL, ::nWaterMark, nWaterMark)

if ValType(bWaterMark) $ "BU"
   ::bWaterMark := bWaterMark
   ::nWaterMark := nWaterMark
endif

Return {bOldWaterMark, nOldWaterMark}


/*-----------------------------------------------------------------------------


                            HELPER FUNCTIONS START HERE


-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------
Method .....: #Buffer2String()
Description : Internal function. Returns a string from a buffer
-----------------------------------------------------------------------------*/
METHOD TPageScript:Buffer2String(cBuffer)

Local cString

cString := AllTrim(cBuffer)

Return Left(cString, Len(cString) - 1)

/*-----------------------------------------------------------------------------
Function ...: #PSFtoI(AValue) -> Value
Description : Converts a Double to an Integer for PSInt compatibility
-----------------------------------------------------------------------------*/
Function PSFtoI(AValue)

Return Int(AValue * 10000)

/*-----------------------------------------------------------------------------
Function ...: #PSItoF(AValue) -> Value
Description : Converts a PSInt to a Double for PSInt compatibility
-----------------------------------------------------------------------------*/
Function PSItoF(AValue)

Return Round(AValue / 10000, 4)


/*-----------------------------------------------------------------------------


                            FUNCTIONS START HERE


-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Function ...: PSInit() -> nErrorCode
Description : Initialization of the printer driver
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSInit()

// If not Initialized, then do it !!!
if ! slInitialized
   oPScript      := TPageScript():New()
   slInitialized := (oPScript:nError == PSE_NOERROR)
endif

Return oPScript:nError

/*-----------------------------------------------------------------------------
Function ...: PSAbort() -> NIL
Description : Abort the current document
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSAbort()

if slInitialized
   oPScript:Abort()
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSAsciiToAnsi([<l>]) -> lOldValue
Description : Set/Get the conversion from Ascii to Ansi for text strings.
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSAsciiToAnsi(lValue)

Local lOldValue := .f.

if slInitialized
   lOldValue := oPScript:GetAsciiToAnsi()
   oPScript:SetAsciiToAnsi(lValue)
endif

Return lOldValue

Function PSBarCodeEx(nTop, nLeft, cCode, nHeight, nThick, nType, lValidate)

if slInitialized
   oPScript:BarCodeEx(nTop, nLeft, cCode, nHeight, nThick, nType, lValidate)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSQRCode(<n>, <n>, <c>, [<n>,<n>]) -> NIL
Description : Print a QRCode
Author .....: R.Visscher
Date .......: June 2017
-----------------------------------------------------------------------------*/
Function PSQRCode(nTop, nLeft, cCode, nVersion, nSize, nModuleWidth)

if slInitialized
   oPScript:QRCode(nTop, nLeft, cCode, nVersion, nSize, nModuleWidth)
endif

Return NIL
 

/*-----------------------------------------------------------------------------
Function ...: PSBarCode(<n>, <n>, <c>, [<n>, <n>, <l>, <n>, <l>]) -> NIL
Description : Print a barcode with choice of Code 39 and Code 128
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSBarCode(nTop, nLeft, cCode, nHeight, nThick, lPrintText, nType, lVertical, lUnitMM)

if slInitialized
   oPScript:BarCode(nTop, nLeft, cCode, nHeight, nThick, lPrintText, nType, lVertical, lUnitMM)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSBeginDoc(<n>, <c>, <n>, <n>) -> nError
Description : Starts a new print job with parameters
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSBeginDoc(nPrinter, cTitle, nOrientation, nCopies, nPageSize, nDuplex, nPaperBin)

Local nError := PSE_NOTINITIALIZED

if slInitialized
   nError := oPScript:BeginDoc(nPrinter, cTitle, nOrientation, nCopies, nPageSize, nDuplex, nPaperBin)
endif

Return nError

/*-----------------------------------------------------------------------------
Function ...: PSBeginDocEx() -> nError
Description : Starts a new print job with defaults parameters
Author .....: Stephan St-Denis
Date .......: July 2006
-----------------------------------------------------------------------------*/
Function PSBeginDocEx()

Local nError := PSE_NOTINITIALIZED

if slInitialized
   nError := oPScript:BeginDocEx()
endif

Return nError

/*-----------------------------------------------------------------------------
Function ...: PSBeginEmuDoc(<n>, <c>, <n>, <n>, <n>, <c>) -> lError
Description :
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSBeginEmuDoc(nPrinter, cTitle, nOrientation, nCopies, cFont)

Local nError := PSE_NOTINITIALIZED

if slInitialized
   nError := oPScript:BeginEmuDoc(nPrinter, cTitle, nOrientation, nCopies, cFont)
endif

Return nError

/*-----------------------------------------------------------------------------
Function ...: PSBeginRawDoc(<n>, <c>, <n>, <n>) -> nError
Description : Starts the printer driver with some parameters
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSBeginRawDoc(nPrinter, cTitle)

Local nError := PSE_NOTINITIALIZED

if slInitialized
   nError := oPScript:BeginRawDoc(nPrinter, cTitle)
endif

Return nError

/*-----------------------------------------------------------------------------
Function ...: PSBitmap(<n>, <n>, <n>, <n>, <x>, [<n>]) -> NIL
Description : Draw a bitmap on the document.
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSBitmap(nTop, nLeft, nBottom, nRight, cBitmap, nTransColor, lKeepRatio)

if slInitialized
   oPScript:Bitmap(nTop, nLeft, nBottom, nRight, cBitmap, nTransColor, lKeepRatio)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSEllipse(<n>, <n>, <n>, <n>, [<n>, <n>, <n>, <n>]) -> NIL
Description : Draw an ellipse
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSEllipse(nTop, nLeft, nBottom, nRight, nThick, nBorderColor, nFillColor, nPattern)

if slInitialized
   oPScript:Ellipse(nTop, nLeft, nBottom, nRight, nThick, nBorderColor, nFillColor, nPattern)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSEllipseEx(<n>, <n>, <n>, <n>) -> NIL
Description : Draw an ellipse
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSEllipseEx(nTop, nLeft, nBottom, nRight)

if slInitialized
   oPScript:EllipseEx(nTop, nLeft, nBottom, nRight)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSEndDoc() -> NIL
Description : Signal the end of the document
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSEndDoc()

if slInitialized
   oPScript:EndDoc()
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSEndEmuDoc() -> NIL
Description : Signal the end of the document
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSEndEmuDoc()

if slInitialized
   oPScript:EndEmuDoc()
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSEndRawDoc() -> NIL
Description : Signal the end of the document
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSEndRawDoc()

if slInitialized
   oPScript:EndRawDoc()
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSFindPrinter(<c>) -> nPos
Description : Search for a printer name and returns its position within the array
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSFindPrinter(cPrinter)

Local nPos := -1

if slInitialized
   nPos := oPScript:FindPrinter(cPrinter)
endif

Return nPos

/*-----------------------------------------------------------------------------
Function ...: PSFrame(<n>, <n>, <n>, <n>, [<n>, <n>, <n>, <n>, <n>]) -> NIL
Description : Draw a frame
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSFrame(nTop, nLeft, nBottom, nRight, nThick, nBorderColor, nFillColor, nPattern, nRadius)

if slInitialized
   oPScript:Frame(nTop, nLeft, nBottom, nRight, nThick, nBorderColor, nFillColor, nPattern, nRadius)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSFrameEx(<n>, <n>, <n>, <n>) -> NIL
Description : Draw a frame
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSFrameEx(nTop, nLeft, nBottom, nRight, nRadius)

if slInitialized
   oPScript:FrameEx(nTop, nLeft, nBottom, nRight, nRadius)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSGetAsciiToAnsi() -> lValue
Description : Retreive the translation setting
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSGetAsciiToAnsi()

Local lValue := .f.

if slInitialized
   lValue := oPScript:GetAsciiToAnsi()
endif

Return lValue

/*-----------------------------------------------------------------------------
Function ...: PSGetBorderColor() -> nValue
Description : Returns the current border color
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetBorderColor()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetBorderColor()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetBorderThickness() -> nValue
Description : Returns the current border thickness
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetBorderThickness()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetBorderThickness()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetCaps() -> aCaps
Description : Retreive the printer capabilities of the selected printer
Author .....: Stephan St-Denis
Date .......: March 2005
Note .......: Compatibility
-----------------------------------------------------------------------------*/
Function PSGetCaps()

Return PSGetPrinterCaps()

/*-----------------------------------------------------------------------------
Function ...: PSGetCoorSystem() -> nValue
Description : Returns the current coordinate system
Author .....: Stephan St-Denis
Date .......: April 2006
-----------------------------------------------------------------------------*/
Function PSGetCoorSystem()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetCoorSystem()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetCopies() -> nValue
Description : Returns the number of copies set for the current print job
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetCopies()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetCopies()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetCPI() -> nValue
Description : Returns the number of character per inch in use (text mode only)
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetCPI()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetCPI()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetDecimalSep() -> cValue
Description : Returns the decimal separator in use
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetDecimalSep()

Local cValue := "?"

if slInitialized
   cValue := oPScript:GetDecimalSep()
endif

Return cValue

/*-----------------------------------------------------------------------------
Function ...: PSGetDefPrinter() -> nValue
Description : Returns the default Windows printer
Author .....: Stephan St-Denis
Date .......: March 2005
Note .......: Compatibility
-----------------------------------------------------------------------------*/
Function PSGetDefPrinter()

Return PSGetDefaultPrinter()

/*-----------------------------------------------------------------------------
Function ...: PSGetDefaultPrinter() -> nValue
Description : Returns the default Windows printer
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSGetDefaultPrinter()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetDefaultPrinter()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetDuplex() -> nValue
Description : Returns the current Duplex mode
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetDuplex()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetDuplex()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFillColor() -> nValue
Description : Returns the current fill color
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetFillColor()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetFillColor()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFillPattern() -> nValue
Description : Returns the current fill pattern
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetFillPattern()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetFillPattern()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFontAngle() -> nValue
Description : Returns the current font angle
Author .....: Stephan St-Denis
Date .......: April 2006
-----------------------------------------------------------------------------*/
Function PSGetFontAngle()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetFontAngle()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFontCount() -> nValue
Description : Returns the current font count
Author .....: Stephan St-Denis
Date .......: April 2006
-----------------------------------------------------------------------------*/
Function PSGetFontCount()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetFontCount()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFonts() -> aFonts
Description : Retreive the printer fonts for the selected printer
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSGetFonts()

Local aFonts := {"Arial", "Courier New", "System", "Times New Roman", "Verdana", "WingDings"}

if slInitialized
   aFonts := oPScript:GetFonts()
endif

Return aClone(aFonts)

/*-----------------------------------------------------------------------------
Function ...: PSGetFontName() -> cValue
Description : Returns the current font name
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetFontName()

Local cValue := ""

if slInitialized
   cValue := oPScript:GetFontName()
endif

Return cValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFontNames(<n>) -> cValue
Description : Returns the font name from its index position
Author .....: Stephan St-Denis
Date .......: April 2006
-----------------------------------------------------------------------------*/
Function PSGetFontNames(nFontIndex)

Local cValue := ""

if slInitialized
   cValue := oPScript:GetFontNames(nFontIndex)
endif

Return cValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFontStyle() -> nValue
Description : Returns the current font style
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetFontStyle()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetFontStyle()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFontSize() -> nValue
Description : Returns the current font size
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetFontSize()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetFontSize()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFontBColor() -> nValue
Description : Returns the current Font background color
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetFontBColor()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetFontBColor()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFontFColor() -> nValue
Description : Returns the current font Foreground color
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetFontFColor()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetFontFColor()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetJustify() -> nValue
Description : Returns the current text justification
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetJustify()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetJustify()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetFontJustify() -> nValue
Description : Returns the current text justification
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetFontJustify()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetFontJustify()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetLPI() -> nValue
Description : Returns the current number of lines per inch (text mode only)
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetLPI()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetLPI()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetMaxHeight() -> nValue
Description :
Author .....: Stephan St-Denis
Date .......: May 2005
-----------------------------------------------------------------------------*/
Function PSGetMaxHeight()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetMaxHeight()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetMaxWidth() -> nValue
Description :
Author .....: Stephan St-Denis
Date .......: May 2005
-----------------------------------------------------------------------------*/
Function PSGetMaxWidth()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetMaxWidth()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetOrientation() -> nValue
Description : Returns the current page orientation (Portrait or Landscape)
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetOrientation()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetOrientation()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPageSize() -> nValue
Description : Retreive the printer paper size
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSGetPageSize()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPageSize()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPaperBin() -> nValue
Description : Returns the current paper bin
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSGetPaperBin()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPaperBin()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPaperBins() -> aBinArray
Description : Returns a two dimensions array with bins/trays numbers/names
Author .....: Stephan St-Denis
Date .......: May 2006
-----------------------------------------------------------------------------*/
Function PSGetPaperBins()

Local aBins     := {}
Local nBinCount := 0
Local nLoop

if slInitialized
   nBinCount := PSGetPaperBinCount()

   for nLoop := 1 to nBinCount
      aAdd(aBins, {PSGetPaperBinNumbers(nLoop), PSGetPaperBinNames(nLoop)} )
   next nLoop
endif

Return aClone(aBins)

/*-----------------------------------------------------------------------------
Function ...: PSGetPaperBinCount() -> nValue
Description : Retreive the number of paper bins installed
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSGetPaperBinCount()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPaperBinCount()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPaperBinNames() -> cValue
Description : Retrieve the name of any of the available paper bin
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSGetPaperBinNames(nIndex)

Local cValue := ""

if slInitialized
   cValue := oPScript:GetPaperBinNames(nIndex)
endif

Return cValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPaperBinNumbers() -> nValue
Description : Retrieve the number of any of the available paper bin
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSGetPaperBinNumbers(nIndex)

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPaperBinNumbers(nIndex)
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPaperCount() -> nValue
Description : Retreive the number of paper installed
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSGetPaperCount()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPaperCount()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPaperNames(<nIndex>) -> cValue
Description : Retreive the name of a paper type based on its index position
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSGetPaperNames(nIndex)

Local cValue := ""

if slInitialized
   cValue := oPScript:GetPaperNames(nIndex)
endif

Return cValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPaperNumbers() -> nValue
Description : Retreive the number of the paper type pointed by nIndex
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSGetPaperNumbers(nIndex)

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPaperNumbers(nIndex)
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPrinter() -> nValue
Description : Returns the currently selected printer
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetPrinter()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPrinter()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPrinterCount() -> nValue
Description : Returns the number of installed printer drivers
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetPrinterCount()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPrinterCount()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPrinterNames(nIndex) -> cValue
Description : Returns the name of the printer pointed by nIndex
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetPrinterNames(nIndex)

Local cValue := ""

if slInitialized
   cValue := oPScript:GetPrinterNames(nIndex)
endif

Return cValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPrinters() -> aClone(saPrinters)
Description : Returns the list of available printers for this computer
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSGetPrinters()

Local aPrinters := {}

if slInitialized
   aPrinters := oPScript:GetPrinters()
endif

Return aPrinters

/*-----------------------------------------------------------------------------
Function ...: PSGetPrinterCaps() -> aCaps
Description : Retreive the printer capabilities of the selected printer
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSGetPrinterCaps()

Local aCaps := {-1, -1, -1, -1, -1, -1, -1, -1, -1}

if slInitialized
   aCaps := oPScript:GetPrinterCaps()
endif

Return aCaps

/*-----------------------------------------------------------------------------
Function ...: PSGetPrinterCapsEx(nCap)
Description : Retreive the printer capabilities of the selected printer
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSGetPrinterCapsEx(nCap)

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPrinterCapsEx(nCap)
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPrinterHandle() -> nValue
Description : Returns the printer handle (for direct API calls)
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetPrinterHandle()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetPrinterHandle()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetPrinterName() -> cValue
Description : Returns the name of the printer number passed in parameter
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetPrinterName(nPrinter)

Local cValue := ""

if slInitialized
   cValue := oPScript:GetPrinterName(nPrinter)
endif

Return cValue

/*-----------------------------------------------------------------------------
Function ...: PSGetTextHeight() -> nValue
Description : Returns the height of the text in the current unit
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetTextHeight(cText)

Local nValue := 0

if slInitialized
   nValue := oPScript:GetTextHeight(cText)
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetTextWidth() -> nValue
Description : Returns the width of the text in the current unit
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetTextWidth(cText)

Local nValue := 0

if slInitialized
   nValue := oPScript:GetTextWidth(cText)
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetTitle() -> cValue
Description : Returns the title of the print job
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetTitle()

Local cValue := ""

if slInitialized
   cValue := oPScript:GetTitle()
endif

Return cValue

/*-----------------------------------------------------------------------------
Function ...: PSGetUnit() -> nValue
Description : Returns the unit in use
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetUnit()

Local nValue := -1

if slInitialized
   nValue := oPScript:GetUnit()
endif

Return nValue

/*-----------------------------------------------------------------------------
Function ...: PSGetUseDIB() -> lValue
Description : Returns the current setting for DIB (Device Independant Bitmap)
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetUseDIB()

Local lValue := .t.

if slInitialized
   lValue := oPScript:GetUseDIB()
endif

Return lValue

/*-----------------------------------------------------------------------------
Function ...: PSGetVersion() -> cValue
Description : Returns the current PageScript version number as a character string
Author .....: Stephan St-Denis
Date .......: April 2006
-----------------------------------------------------------------------------*/
Function PSGetVersion()

Return oPScript:GetVersion()

/*-----------------------------------------------------------------------------
Function ...: PSGetXerox() -> lValue
Description : Returns the current setting for Xerox compatibility
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSGetXerox()

Local lValue := .f.

if slInitialized
   lValue := oPScript:GetXerox()
endif

Return lValue

/*-----------------------------------------------------------------------------
Function ...: PSIsPreviewVisible() -> lValue
Description : Returns .t. if Print Preview Window is shown
Author .....: Stephan St-Denis
Date .......: May 2012
-----------------------------------------------------------------------------*/
Function PSIsPreviewVisible()

Local lValue := .f.

if slInitialized
   lValue := oPScript:IsPreviewVisible()
endif

Return lValue

/*-----------------------------------------------------------------------------
Function ...: PSLine(<n>, <n>, <n>, <n>, [<n>, <n>]) -> NIL
Description : Draw a line
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSLine(nTop, nLeft, nBottom, nRight, nThick, nBorderColor)

if slInitialized
   oPScript:Line(nTop, nLeft, nBottom, nRight, nThick, nBorderColor)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSLineEx(<n>, <n>, <n>, <n>) -> NIL
Description : Draw a line
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSLineEx(nTop, nLeft, nBottom, nRight)

if slInitialized
   oPScript:LineEx(nTop, nLeft, nBottom, nRight)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSNewPage() -> NIL
Description : Signal the end of page, page eject
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSNewPage()

if slInitialized
   oPScript:NewPage()
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSPrintDialog() -> lPrint
Description : Shows the printer dialog and returns if may print or not
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSPrintDialog()

Local lPrint := .f.

if slInitialized
   lPrint := oPScript:PrintDialog()
endif

Return lPrint

/*-----------------------------------------------------------------------------
Function ...: PSPrintFile(<c>, [<l>, <n>, <c>, <n>, <n>, <c>]) -> lSuccess
Description : Prints the file pointed by cFile and optionnaly deletes it.
              EMULATION mode service.
Author .....: Stephan St-Denis
Date .......: September 2002
Note .......: Compatibility
-----------------------------------------------------------------------------*/
Function PSPrintFile(cFileName, lDelete, nPrinter, cTitle, nOrientation, nCopies, cFont)

Local lSuccess := .f.

if slInitialized
   lSuccess := oPScript:PrintEmuFile(cFileName, lDelete, nPrinter, cTitle, nOrientation, nCopies, cFont)
endif

Return lSuccess

/*-----------------------------------------------------------------------------
Function ...: PSPrintEmuFile(<c>, [<l>, <n>, <c>, <n>, <n>, <c>]) -> lSuccess
Description : Prints the file pointed by cFile and optionnaly deletes it.
              EMULATION mode service.
Author .....: Stephan St-Denis
Date .......: September 2002
-----------------------------------------------------------------------------*/
Function PSPrintEmuFile(cFileName, lDelete, nPrinter, cTitle, nOrientation, nCopies, cFont)

Local lSuccess := .f.

if slInitialized
   lSuccess := oPScript:PrintEmuFile(cFileName, lDelete, nPrinter, cTitle, nOrientation, nCopies, cFont)
endif

Return lSuccess

/*-----------------------------------------------------------------------------
Function ...: PSPrintRawFile(<c>, [<l>, <n>, <c>]) -> lSuccess
Description : Prints the file pointed by cFile and optionnaly deletes it.
              No processing on file. The file is sent "as is" to the printer.
Author .....: Stephan St-Denis
Date .......: September 2002
-----------------------------------------------------------------------------*/
Function PSPrintRawFile(cFileName, lDelete, nPrinter, cTitle)

Local lSuccess := .f.

if slInitialized
   lSuccess := oPScript:PrintRawFile(cFileName, lDelete, nPrinter, cTitle)
endif

Return lSuccess

/*-----------------------------------------------------------------------------
Function ...: PSSetAsciiToAnsi([<l>]) -> NIL
Description : Set the conversion from Ascii to Ansi for text strings.
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetAsciiToAnsi(lValue)

Local OldValue := oPScript:GetAsciiToAnsi()

if slInitialized
   oPScript:SetAsciiToAnsi(lValue)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetBin(<n>) -> NIL
Description : Sets the paper bin
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetBin(nPaperBin)

Local OldValue := oPScript:GetPaperBin()

PSSetPaperBin(nPaperBin)

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetBorder([<n>, <n>]) -> NIL
Description : Sets the attributes used to draw lines and borders
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetBorder(nThickness, nBorderColor)

Local OldValue := {oPScript:GetBorderThickness(), oPScript:GetBorderColor()}

if slInitialized
   oPScript:SetBorder(nThickness, nBorderColor)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetBorderColor(<n>) -> NIL
Description : Sets the border color used to draw lines and borders
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSSetBorderColor(nBorderColor)

Local OldValue := oPScript:GetBorderColor()

if slInitialized
   oPScript:SetBorderColor(nBorderColor)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetBorderThickness(<n>) -> NIL
Description : Sets the border thickness used to draw lines and borders
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSSetBorderThickness(nThickness)

Local OldValue := oPScript:GetBorderThickness()

if slInitialized
   oPScript:SetBorderThickness(nThickness)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Method .....: #PSSetClipperComp(<l>) -> NIL
Description : Set Clipper compatible calls for TextOut() and TextBox()
-----------------------------------------------------------------------------*/
Function PSSetClipperComp(lClipper)

oPScript:SetClipperComp(lClipper)

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetCoorSystem(<n>) -> NIL
Description : Sets the Coordinate system
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSSetCoorSystem(nCoor)

Local OldValue := oPScript:GetCoorSystem()

if slInitialized
   oPScript:SetCoorSystem(nCoor)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetCopies([<n>]) -> NIL
Description : Sets the number of copies
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetCopies(nCopies)

Local OldValue := oPScript:GetCopies()

if slInitialized
   oPScript:SetCopies(nCopies)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetCPI([<n>]) -> NIL
Description : Sets the number of characters per inch (Text mode only)
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSSetCPI(nCPI)

Local OldValue := oPScript:GetCPI()

if slInitialized
   oPScript:SetCPI(nCPI)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetDecimalSep([<c>]) -> cOldSeparator
Description : Sets the decimal separator character
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetDecimalSep(cSep)

Local OldValue := oPScript:GetDecimalSep()

if slInitialized
   oPScript:SetDecimalSep(cSep)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetDevice([<n>]) -> NIL
Description : Sets the device for the next print job
Author .....: Stephan St-Denis
Date .......: January 2007
-----------------------------------------------------------------------------*/
Function PSSetDevice(nDevice)

if slInitialized
   oPScript:SetDevice(nDevice)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetDirectPrint(<l>) -> NIL
Description : Sets the direct print mode (use for very special cases)
Author .....: Stephan St-Denis
Date .......: March 2010
-----------------------------------------------------------------------------*/
Function PSSetDirectPrint(lDirect)

if slInitialized
   oPScript:SetDirectPrint(lDirect)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetDuplex([<n>]) -> NIL
Description : Sets the Duplex mode
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetDuplex(nDuplex)

Local OldValue := oPScript:GetDuplex()

if slInitialized
   oPScript:SetDuplex(nDuplex)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFileName([<c>]) -> NIL
Description : Sets the file name of a PDF file document
Author .....: Stephan St-Denis
Date .......: January 2007
-----------------------------------------------------------------------------*/
Function PSSetFileName(cFileName)

if slInitialized
   oPScript:SetFileName(cFileName)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetFill(<n>, [<n>]) -> NIL
Description : Sets the color used to fill shapes, like boxes and ellipes
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetFill(nFillColor, nFillPattern)

Local OldValue := {oPScript:GetFillColor(), oPScript:GetFillPattern()}

if slInitialized
   oPScript:SetFill(nFillColor, nFillPattern)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFillColor(<n>) -> NIL
Description : Sets the color used to fill shapes, like boxes and ellipes
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetFillColor(nFillColor)

Local OldValue := oPScript:GetFillColor()

if slInitialized
   oPScript:SetFillColor(nFillColor)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFillPattern(<n>) -> NIL
Description : Sets the pattern used to fill shapes, like boxes and ellipes
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetFillPattern(nFillPattern)

Local OldValue := oPScript:GetFillPattern()

if slInitialized
   oPScript:SetFillPattern(nFillPattern)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFont([<n>, <n>, <n>, <n>, <n>]) -> NIL
Description : Sets the font attributes used by each call to PSTextOut()
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetFont(cFont, nStyle, nSize, nTFColor, nTBColor, nAngle)

Local OldValue := PSSetFontAttributes(cFont, nStyle, nSize, nTFColor, nTBColor, nAngle)

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFontAttributes([<n>, <n>, <n>, <n>, <n>]) -> NIL
Description : Sets the font attributes used by each call to PSTextOut()
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetFontAttributes(cFont, nStyle, nSize, nTFColor, nTBColor, nAngle)

Local OldValue := {oPScript:GetFontName()  , oPScript:GetFontStyle() , oPScript:GetFontSize(), ;
                   oPScript:GetFontFColor(), oPScript:GetFontBColor(), oPScript:GetFontAngle()}

if slInitialized
   oPScript:SetFontAttributes(cFont, nStyle, nSize, nTFColor, nTBColor, nAngle)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFontAngle(<n>) -> NIL
Description : Sets the font angle
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSSetFontAngle(nValue)

Local OldValue := oPScript:GetFontAngle()

if slInitialized
   oPScript:SetFontAngle(nValue)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFontBColor(<n>) -> NIL
Description : Sets the text background color
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSSetFontBColor(nValue)

Local OldValue := oPScript:GetFontBColor()

if slInitialized
   oPScript:SetFontBColor(nValue)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFontFColor(<n>) -> NIL
Description : Sets the text foreground color
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSSetFontFColor(nValue)

Local OldValue := oPScript:GetFontFColor()

if slInitialized
   oPScript:SetFontFColor(nValue)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFontName(<c>) -> NIL
Description : Sets the text foreground color
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSSetFontName(cValue)

Local OldValue := oPScript:GetFontName()

if slInitialized
   oPScript:SetFontName(cValue)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFontSize(<n>) -> NIL
Description : Sets the text size in points
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSSetFontSize(nValue)

Local OldValue := oPScript:GetFontSize()

if slInitialized
   oPScript:SetFontSize(nValue)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetFontStyle(<n>) -> NIL
Description : Sets the font style
Author .....: Stephan St-Denis
Date .......: March 2006
-----------------------------------------------------------------------------*/
Function PSSetFontStyle(nValue)

Local OldValue := oPScript:GetFontStyle()

if slInitialized
   oPScript:SetFontStyle(nValue)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetJustify(<n>) -> NIL
Description : Sets justification for TextOut
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetJustify(nJustify)

Local OldValue := oPScript:GetJustify()

if slInitialized
   oPScript:SetJustify(nJustify)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetLPI([<n>]) -> NIL
Description : Sets The number of Lines per inch (Text mode only)
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSSetLPI(nLPI)

Local OldValue := oPScript:GetLPI()

if slInitialized
   oPScript:SetLPI(nLPI)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetOrientation([<n>]) -> NIL
Description : Sets the paper orientation
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetOrientation(nOrientation)

Local OldValue := oPScript:GetOrientation()

if slInitialized
   oPScript:SetOrientation(nOrientation)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetPaperBin(<n>) -> NIL
Description : Sets the paper bin
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetPaperBin(nPaperBin)

Local OldValue := oPScript:GetPaperBin()

if slInitialized
   oPScript:SetPaperBin(nPaperBin)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetPageSize(<n>) -> NIL
Description : Sets the page size to a predifined size
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetPageSize(nPageSize)

Local OldValue := oPScript:GetPageSize()

if slInitialized
   oPScript:SetPageSize(nPageSize)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetPDFCharSet(<N>) -> NIL
Description : Set the character set to be use when printing text in PDF docs
Author .....: Stephan St-Denis
Date .......: October 2011
-----------------------------------------------------------------------------*/
Function PSSetPDFCharSet(nCharSet)

if slInitialized
   oPScript:SetPDFCharSet(nCharSet)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetPDFOwnerPassword(<C>) -> NIL
Description : Set the encryption password for PDF documents
Author .....: Stephan St-Denis
Date .......: April 2011
-----------------------------------------------------------------------------*/
Function PSSetPDFOwnerPassword(cPassword)

if slInitialized
   oPScript:SetPDFOwnerPassword(cPassword)
endif

Return NIL


/*-----------------------------------------------------------------------------
Function ...: PSSetPDFEncoding(<N>) -> NIL
Description : Set the internal encoding for PDF documents
Author .....: R.Visscher
Date .......: July 2017
-----------------------------------------------------------------------------*/
Function PSSetPDFEncoding(nEncoding)

if slInitialized
   oPScript:SetPDFEncoding(nEncoding)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetPDFVersion(<N>) -> NIL
Description : Set the version number for PDF documents
Author .....: R.Visscher
Date .......: July 2017
-----------------------------------------------------------------------------*/
Function PSSetPDFVersion(nVersion)

if slInitialized
   oPScript:SetPDFVersion(nVersion)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSShowPDF(<L>) -> NIL
Description : Show PDF after creation in default PDF reader
Author .....: R.Visscher
Date .......: July 2017
-----------------------------------------------------------------------------*/
Function PSShowPDF(lShow)

if slInitialized
   oPScript:ShowPDF(lShow)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetPDFEmbeddedFonts(<N>) -> NIL
Description : Set the embedding for PDF documents ( none/sub/full )
Author .....: R.Visscher
Date .......: July 2017
-----------------------------------------------------------------------------*/
Function PSSetPDFEmbeddedFonts(nEmbedded)

if slInitialized
   oPScript:SetPDFEmbeddedFonts(nEmbedded)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetPrinter([<n>]) -> NIL
Description : Sets the printer
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSSetPrinter(nPrinter)

Local OldValue := oPScript:GetPrinter()

if slInitialized
   oPScript:SetPrinter(nPrinter)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: #PSSetPWState(<n>) -> NIL
Description : Set the print preview window state
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
Function PSSetPWState(nState)

if slInitialized
   oPScript:SetPWState(nState)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetPWPosition(<n>, <n>) -> NIL
Description : Set the print preview window position
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
Function PSSetPWPosition(nLeft, nTop)

if slInitialized
   oPScript:SetPWPosition(nLeft, nTop)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: #PSSetPWSize(<n>, <n>) -> NIL
Description : Set the print preview window size (-1, -1 = Auto size)
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
Function PSSetPWSize(nWidth, nHeight)

if slInitialized
   oPScript:SetPWSize(nWidth, nHeight)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: #PSSetPWBounds(<n>, <n>, <n>, <n>) -> NIL
Description : Set the print preview window bounds (position and size at the same time)
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
Function PSSetPWBounds(nLeft, nTop, nWidth, nHeight)

if slInitialized
   oPScript:SetPWBounds(nLeft, nTop, nWidth, nHeight)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: #PSSetPWZoomLevel(<n>) -> NIL
Description : Set the print preview window zoom level
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
Function PSSetPWZoomLevel(nZoomLevel)

if slInitialized
   oPScript:SetPWZoomLevel(nZoomLevel)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: #PSSetPWColors(<n>, <n>, <n>, <n>)) -> NIL
Description : Set the print preview window zoom level
Version ....: 2.1.0.0
-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------
Method .....: #SetPWColors(<n>, <n>, <n>, <n>) -> Self
Description : Set the print preview window colors
Version ....: 3.0.0.0
-----------------------------------------------------------------------------*/
Function PSSetPWColors(nBackground, nPaper, nShadow, nToolbar)

if slInitialized
   oPScript:SetPWColors(nBackground, nPaper, nShadow, nToolbar)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSetRowCol([<n>, <n>]) -> {60, 80}
Description : Sets the number of virtual Rows and Columns in APS_TEXT unit.
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSSetRowCol(nRow, nCol)

Local nCPI := 10
Local nLPI := 6

if slInitialized
   if oPScript:nUnit == APS_CLIP
      oPScript:SetRowCol(nRow, nCol)
   else
      do case
         case nCol >=   1 .and. nCol <=  64
            nCPI := 8
   
         case nCol >=  65 .and. nCol <=  80
            nCPI := 10
   
         case nCol >=  81 .and. nCol <=  96
            nCPI := 12
   
         case nCol >=  97 .and. nCol <= 120
            nCPI := 15
   
         case nCol >= 121 .and. nCol <= 136
            nCPI := 17
   
         case nCol >= 137 .and. nCol <= 144
            nCPI := 18
   
         case nCol >= 145
            nCPI := 20
   
      endcase
   
      do case
         case nRow >= 1 .and. nRow <= 66
            nLPI := 6
   
         case nRow > 66
            nLPI := 8
   
      endcase
   
      PSSetCPI(nCPI)
      PSSetLPI(nLPI)
   endif
endif

Return {60, 80}

/*-----------------------------------------------------------------------------
Function ...: PSSetTitle([<c>]) -> cOldValue
Description : Sets the document title
Author .....: Stephan St-Denis
Date .......: April 2005
-----------------------------------------------------------------------------*/
Function PSSetTitle(cTitle)

Local OldValue := oPScript:GetTitle()

if slInitialized
   oPScript:SetTitle(cTitle)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetUnit(<n>) -> nOldValue
Description : Sets the unit used to calculate dimensions and placement
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetUnit(nUnit)

Local OldValue := oPScript:GetUnit()

if slInitialized
   oPScript:SetUnit(nUnit)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetUseDIB(<l>) -> lOldValue
Description : Sets the use of DIB for printing Bitmaps
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetUseDIB(lUseDIB)

Local OldValue := oPScript:GetUseDIB()

if slInitialized
   oPScript:SetUseDIB(lUseDIB)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSSetXerox(<l>) -> lOldValue
Description : Sets Xerox compatible mode for Xerox WorkCenter and other
              faulty printers
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSSetXerox(lXerox)

Local OldValue := oPScript:GetXerox()

if slInitialized
   oPScript:SetXerox(lXerox)
endif

Return OldValue

/*-----------------------------------------------------------------------------
Function ...: PSTextBox(<n>, <n>, <n>, <n>, <x>, [<n>, <c>, <n>, <n>, <n>, <n>,
                        <n>, <n>]) -> NIL
Description : Prints a string in a box at position X1,Y1, X2,Y2 using parameters
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSTextBox(nTop, nLeft, nBottom, nRight, cText, nJustify, cFont, nSize, ;
                   nStyle, nFColor, nBColor, nThick)

if slInitialized
   oPScript:TextBox(nTop, nLeft, nBottom, nRight, cText, nJustify, cFont, nSize, ;
                    nStyle, nFColor, nBColor, nThick)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSTextBoxEx(<n>, <n>, <n>, <n>, <x>) -> NIL
Description : Prints a string in a box at position X1,Y1, X2,Y2 using parameters
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSTextBoxEx(nTop, nLeft, nBottom, nRight, cText)

if slInitialized
   oPScript:TextBoxEx(nTop, nLeft, nBottom, nRight, cText)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSTextOut(<n>, <n>, <x>, [<c>, <n>, <n>, <n>, <n>, <n>, <n>, <n>]) -> NIL
Description : Prints a string at position X,Y using parameters
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSTextOut(nTop, nLeft, xValue, cPicture, nJustify, cFont, nSize, nStyle, ;
                   nTFColor, nTBColor, nAngle)

if slInitialized
   oPScript:TextOut(nTop, nLeft, xValue, cPicture, nJustify, cFont, nSize, ;
                    nStyle, nTFColor, nTBColor, nAngle)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSTextOutEx(<n>, <n>, <x>, [<c>]) -> NIL
Description : Prints a string at position X,Y using parameters
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSTextOutEx(nTop, nLeft, xValue, cPicture)

if slInitialized
   oPScript:TextOutEx(nTop, nLeft, xValue, cPicture)
endif

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSVersion() -> cVersionNumber
Description : Returns the version number
Author .....: Stephan St-Denis
Date .......: March 2005
-----------------------------------------------------------------------------*/
Function PSVersion()

Return oPScript:GetVersion()

/*-----------------------------------------------------------------------------
Function ...: PSWaterMark([<b>]) -> Previous WaterMark
Description : Sets/Returns the current WaterMark
Author .....: Stephan St-Denis
Date .......: March 2005
Note .......: This funtion is not implemented in PSCRIPT.DLL
-----------------------------------------------------------------------------*/
Function PSWaterMark(bWaterMark, lWaterMark)

Local aOldValues := {{|| NIL}, .f.}
Local nWM        := AWM_NONE

if slInitialized
   if ValType(lWaterMark) = "L"
      if lWaterMark
         nWM := AWM_FOREGROUND
      else
         nWM := AWM_BACKGROUND
      endif
   endif

   aOldValues := oPScript:WaterMark(bWaterMark, nWM)
endif

Return aOldValues

/*-----------------------------------------------------------------------------
Unsupported / Obsolete functions
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Function ...: PSPrnChanged()
Note .......: This funtion is not implemented in PSCRIPT.DLL
-----------------------------------------------------------------------------*/
Function PSPrnChanged()

Return .f.

/*-----------------------------------------------------------------------------
Function ...: PSRefreshPrinters()
Note .......: This funtion is not implemented in PSCRIPT.DLL
-----------------------------------------------------------------------------*/
Function PSRefreshPrinters()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSSendMail()
Note .......: This funtion is not implemented in PSCRIPT.DLL
-----------------------------------------------------------------------------*/
Function PSSendMail()

Return {.f., ""}

/*-----------------------------------------------------------------------------
Function ...: PSSetTimeSlice()
Note .......: This funtion is not implemented in PSCRIPT.DLL
-----------------------------------------------------------------------------*/
Function PSSetTimeSlice()

Return {|| NIL}

/*-----------------------------------------------------------------------------
Function ...: PSSShowIcon()
Note .......: This funtion is not implemented in PSCRIPT.DLL
-----------------------------------------------------------------------------*/
Function PSShowIcon()

Return NIL

/*-----------------------------------------------------------------------------
Function ...: PSShutDown()
Note .......: This funtion is not implemented in PSCRIPT.DLL
-----------------------------------------------------------------------------*/
Function PSShutDown()

Return NIL

