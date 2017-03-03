// ///////////////////////////
// Name.........: PRINTRAW.PRG
// Date.........: 11.12.2006
// Author(s)....: Abbougaga Jr from an orginal idea of Rees Software & Systems Ltd 2003
// Copyright....: The following source code is a free contribution.
//                You're free to reuse it as you want at your own risks.
// ///////////////////////////

*------------------------------------------------------------------*
* Translated for MiniGUI by Grigory Filatov <gfilatov@inbox.ru>

ANNOUNCE RDDSYS

#include "minigui.ch"

#ifndef __XHARBOUR__
   #xtranslate At(<a>,<b>,[<x,...>]) => hb_At(<a>,<b>,<x>)
#endif
#define Alert( c ) MsgExclamation( c, "Attention" )

#define TAB       CHR(9)
#define FORMFEED  CHR(12)
#define CR        CHR(13)
#define CRLF      CHR(13)+CHR(10)

#define TESTFILE "__testFile.txt"

//////////////////////////////
PROCEDURE main()
//////////////////////////////

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'PRINTRAW Demo' ;
		MAIN ;
		TOPMOST NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT OnInit() ;
		ON RELEASE FERASE(TESTFILE)

	END WINDOW

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

RETURN

//////////////////////////////
PROCEDURE OnInit()
//////////////////////////////
  LOCAL aPrn, nPos

  @ 10, 10 LABEL Label_1 ;
	OF Win_1 ;
	VALUE "Print to printer in RAW mode - Select printer and press Enter" ;
	AUTOSIZE

  IF EMPTY( aPrn := WinGetPrinters() )
    Alert("Warning: No Printer Installed")
  ELSE
    // Locate default windows printer and set as starting selection
    IF EMPTY( nPos := ASCAN( aPrn, WinDefaultPrinter() ) )
      nPos := 1
    ENDIF
    IF !EMPTY( nPos := ACHOICE( 3,0,20,33,aPrn,,,nPos ) )
      PrintMessage( aPrn[nPos] )
    ELSE
      Win_1.Release
    ENDIF
  ENDIF

RETURN

//////////////////////////////
FUNCTION Achoice( t, l, b, r, aItems, cTitle, dummy, nValue )
//////////////////////////////

	DEFAULT cTitle TO "Please, select", nValue TO 0

	DEFINE WINDOW Win_2 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 300 ;
		TITLE cTitle ;
		ICON 'MAIN' ;
		TOPMOST ;
		NOMAXIMIZE NOSIZE ;
		ON INIT Win_2.Button_1.SetFocus

		@ 235,190 BUTTON Button_1 ;
		CAPTION 'OK' ;
		ACTION {|| nValue := Win_2.List_1.Value, Win_2.Release } ;
		WIDTH 80

		@ 235,295 BUTTON Button_2 ;
		CAPTION 'Cancel' ;
		ACTION {|| nValue := 0, Win_2.Release } ;
		WIDTH 80

		@ 20,15 LISTBOX List_1 ;
		WIDTH 360 ;
		HEIGHT 200 ;
		ITEMS aItems ;
		VALUE nValue ;
		FONT "Ms Sans Serif" ;
		SIZE 12 ;
		ON DBLCLICK {|| nValue := Win_2.List_1.Value, Win_2.Release }

	END WINDOW

	CENTER WINDOW Win_2
	ACTIVATE WINDOW Win_2

RETURN nValue

//////////////////////////////
// This function prints the entire file in one call to PrintFileRaw()
FUNCTION WinPrintRaw(cPrinter,cFileName,cDocumentName)
//////////////////////////////
  LOCAL nPrn:= -1, cMess:= "WinPrintRaw(): "

  IF !EMPTY(cFilename)
    IF (nPrn := PrintFileRaw(cPrinter,cFileName,cDocumentName)) < 0
      DO CASE
      CASE nPrn = -1
        Alert(cMess+"Incorrect parameters passed to function")
      CASE nPrn = -2
        Alert(cMess+"WINAPI OpenPrinter() call failed")
      CASE nPrn = -3
        Alert(cMess+"WINAPI StartDocPrinter() call failed")
      CASE nPrn = -4
        Alert(cMess+"WINAPI StartPagePrinter() call failed")
      CASE nPrn = -5
        Alert(cMess+"WINAPI malloc() of memory failed")
      CASE nPrn = -6
        Alert(cMess+"WINAPI CreateFile() call failed - File "+cFileName+" no found??")
      ENDCASE
    ENDIF
  ENDIF

RETURN(nPrn)

//////////////////////////////
STATIC FUNCTION PrintMessage(cPrinter)
//////////////////////////////
  SET CONS OFF
  SET ALTE TO (TESTFILE)
  SET ALTE ON
  ? ' PRNTEST.PRG'
  ?
  ? '  Copyright:'
  ? '   Rees Software & Systems Ltd 2003'
  ? '   Nelson, New Zealand'
  ?
  ? ' Contents :'
  ? '    Sample printing to file'
  ? '    This is donated to the public domain and is free software.'
  ?
  ? 'An alternative to "SET PRINTER TO" for printing under Windows'
  ? '-------------------------------------------------------------'
  ?
  ? 'Print to a temporary file (we use WINAPI GetTempFileName()) first. Then use'
  ? 'WinPrintRaw() to send the file to the windows spooler.'
  ?
  ? 'Obviously to make use of this you need to know what type of printer you are'
  ? 'printing to and you must also include the appropriate "Escape codes" in the'
  ? 'file - as we used to do in Clipper. The trick we use to determine what type'
  ? 'of printer is installed is to add special characters to the Windows printer'
  ? 'name.'
  ?
  ? '(E)= Epson compatible DOT matrix e.g. Panasonic KXP3200 Series (E)'
  ? '(6)= PCL 6 compatible'
  ? '(D)= Deskjet'
  ? ''
  ? 'etc....'
  ?
  ? 'Then to determine the correct "Escape codes" do the following in your code:'
  ?
  ? 'BEGIN CASE'
  ? "CASE '(6)'$cPrinter"
  ? "   s_prnReset = CHR(27)+'E'+........"
  ? '   s_underOn  = CHR(27)+"&d1D"'
  ? '   s_UnderOff = CHR(27)+"&d@"'
  ? "   s_compress = CHR(27)+ '(s1b16.66h6T'"
  ? '  file://etc....'
  ? "CASE '(E)'$cPrinter"
  ? '  file://etc......'
  ? 'ENDCASE'
  ?
  ? 'This is the exact same approach we used in Clipper - except that printing'
  ? 'is to the Windows printer not a LPT port. The only caveat is that not all'
  ? 'printers support RAW mode. These are Windows GDI only printers.'
  ?
  ? 'We have been using this approach for the last 4 years with Xbase++ with no'
  ? 'problems.'
  ?
  ? FORMFEED
  SET ALTE OFF
  SET ALTE TO
  SET CONS ON
  WinPrintRaw(cPrinter, TESTFILE, "Test Print Job")
RETURN(.T.)

//////////////////////////////
FUNCTION WinGetPrinters()
//////////////////////////////
  LOCAL aPrn := {}, nStart := 1, cPrinters, nStop, nPos, cPrn
  cPrinters := EnumPrinters()+';'
  nStop := LEN(cPrinters)+1
  DO WHILE nStart < nStop
    nPos := AT(';', cPrinters, nStart)
    IF !EMPTY(cPrn := SUBSTR(cPrinters, nStart, nPos-nStart))
      AADD(aPrn, cPrn)
    ENDIF
    nStart := nPos+1
  ENDDO
RETURN(aPrn)


#pragma BEGINDUMP

#undef UNICODE

#include <windows.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"

#ifndef __XHARBOUR__
   #define ISCHAR( n )           HB_ISCHAR( n )
#endif

#define MAX_FILE_NAME 1024
#define BIG_BUFFER (1024*32)

HB_FUNC ( ENUMPRINTERS )
{
  UCHAR *Result ;
  DWORD x, Flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS ;
  LPSTR Name = NULL ;
  DWORD Level = 5 ;
  PRINTER_INFO_5 *pPrinterEnum, *pFree;
  PRINTER_INFO_4 *pPrinterEnum4, *pFree4;
  DWORD cbBuf  ;
  DWORD BytesNeeded=0 ;
  DWORD NumOfPrinters=0 ;
  OSVERSIONINFO osvi ;  //  altered to check Windows Version
  osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
  GetVersionEx (&osvi);
  if (osvi.dwPlatformId == VER_PLATFORM_WIN32_NT)
  {
    Level = 4 ;
    EnumPrinters(Flags,Name,Level,(LPBYTE) pPrinterEnum4,0,&BytesNeeded,&NumOfPrinters) ;
    if (BytesNeeded > 0)
    {
      Result = (UCHAR *) hb_xgrab(BytesNeeded) ;
      *Result = '\0' ;
      pFree4 = pPrinterEnum4 = (PRINTER_INFO_4 *)  hb_xgrab(BytesNeeded) ;
      cbBuf = BytesNeeded ;
      if (EnumPrinters(Flags,Name,Level,(LPBYTE) pPrinterEnum4,cbBuf,&BytesNeeded,&NumOfPrinters))
      {
        for (x=0 ; x < NumOfPrinters ; x++, pPrinterEnum4++ )
        {
          strcat(Result,pPrinterEnum4->pPrinterName) ;
          strcat(Result,";") ;
        }
      }
      hb_retc(Result) ;
      hb_xfree(Result) ;
      hb_xfree(pFree4) ;
    }
    else
      hb_retc("") ;
  }
  else
   {
    EnumPrinters(Flags,Name,Level,(LPBYTE) pPrinterEnum,0,&BytesNeeded,&NumOfPrinters) ;
    if (BytesNeeded > 0)
    {
      Result = (UCHAR *) hb_xgrab(BytesNeeded) ;
      *Result = '\0' ;
      pFree = pPrinterEnum = (PRINTER_INFO_5 *)  hb_xgrab(BytesNeeded) ;
      cbBuf = BytesNeeded ;
      if (EnumPrinters(Flags,Name,Level,(LPBYTE) pPrinterEnum,cbBuf,&BytesNeeded,&NumOfPrinters))
      {
        for (x=0 ; x < NumOfPrinters ; x++, pPrinterEnum++ )
        {
          strcat(Result,pPrinterEnum->pPrinterName) ;
          strcat(Result,";") ;
        }
      }
      hb_retc(Result) ;
      hb_xfree(Result) ;
      hb_xfree(pFree) ;
    }
    else
      hb_retc("") ;
  }
}

HB_FUNC( WINDEFAULTPRINTER )
{
  DWORD x, y ;
  UCHAR lpReturnedString[MAX_FILE_NAME] ;
  x = GetProfileString("windows","device","",lpReturnedString,MAX_FILE_NAME-1);
  y = 0 ;
  while ( y < x && lpReturnedString[y] != ',' )
    y++ ;
  hb_retclen(lpReturnedString,y) ;
}

HB_FUNC( PRINTFILERAW )
{
  UCHAR  printBuffer[BIG_BUFFER], *cPrinterName, *cFileName, *cDocName ;
  HANDLE  hPrinter, hFile ;
  DOC_INFO_1 DocInfo ;
  DWORD nRead, nWritten, rVal = -1 ;
  if (ISCHAR(1) && ISCHAR(2))
  {
    cPrinterName= (UCHAR*)hb_parc(1) ;
    cFileName= (UCHAR*)hb_parc(2) ;
    if ( OpenPrinter(cPrinterName, &hPrinter, NULL) != 0 )
    {
      DocInfo.pDocName = (UCHAR*)hb_parc(3) ;
      DocInfo.pOutputFile = NULL ;
      DocInfo.pDatatype = "RAW" ;
      if ( StartDocPrinter(hPrinter,1,(char *) &DocInfo) != 0 )
      {
        if ( StartPagePrinter(hPrinter) != 0 )
        {
          hFile = CreateFile(cFileName,GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL)   ;
          if (hFile != INVALID_HANDLE_VALUE )
           {
            while (ReadFile(hFile, printBuffer, BIG_BUFFER, &nRead, NULL) && (nRead > 0))
            {
              if (printBuffer[nRead-1] == 26 )
                nRead-- ; // Skip the EOF() character
              WritePrinter(hPrinter, printBuffer, nRead, &nWritten) ;
            }
            rVal = 1 ;
            CloseHandle(hFile) ;
          }
          else
            rVal= -6 ;
          EndPagePrinter(hPrinter) ;  // 28/11/2001 10:16
        }
        else
          rVal = -4 ;
        EndDocPrinter(hPrinter);
      }
      else
        rVal= -3 ;
      ClosePrinter(hPrinter) ;
    }
    else
      rVal= -2 ;
  }
  hb_retnl(rVal) ;
}

#pragma ENDUMP

/////////////////////////////////////////////////////////////////////////
////   THE END   ////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
