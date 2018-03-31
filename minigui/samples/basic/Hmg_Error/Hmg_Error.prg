/*----------------------------------------------------------------------------
 HMG - Harbour Windows GUI library source code

 Copyright 2002-2010 Roberto Lopez <mail.box.hmg@gmail.com>
 http://sites.google.com/site/hmgweb/

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of HMG.

 The exception is that, if you link the HMG library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 HMG library code into it.

 Parts of this project are based upon:

 "Harbour GUI framework for Win32"
  Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
  Copyright 2001 Antonio Linares <alinares@fivetech.com>
 www - https://harbour.github.io

 "Harbour Project"
 Copyright 1999-2018, https://harbour.github.io/

 "WHAT32"
 Copyright 2002 AJ Wos <andrwos@aust1.net>

 "HWGUI"
   Copyright 2001-2008 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/

#include "hmg.ch"
#include "error.ch"
#include "harupdf.ch"
*------------------------------------------------------------------------------*
PROCEDURE ErrorSys
*------------------------------------------------------------------------------*

ErrorBlock( {| oError | DefError( oError ) } )

RETURN

STATIC FUNCTION DefError( oError )

LOCAL cMessage
LOCAL cDOSError

LOCAL n
Local Ai

//Html Arch to ErrorLog
LOCAL HtmArch, xText

// By default, division by zero results in zero
IF oError:genCode == EG_ZERODIV
   RETURN 0
ENDIF

// Set NetErr() of there was a database open error
IF oError:genCode == EG_OPEN .AND. ;
      oError:osCode == 32 .AND. ;
      oError:canDefault
   NetErr( .T. )
   RETURN .F.
ENDIF

// Set NetErr() if there was a lock error on dbAppend()
IF oError:genCode == EG_APPENDLOCK .AND. ;
      oError:canDefault
   NetErr( .T. )
   RETURN .F.
ENDIF

HtmArch := Html_ErrorLog()
cMessage := ErrorMessage( oError )
IF ! Empty( oError:osCode )
   cDOSError := "(DOS Error " + LTrim( Str( oError:osCode ) ) + ")"
ENDIF

// "Quit" selected

IF ! Empty( oError:osCode )
   cMessage += " " + cDOSError
ENDIF
Html_LineText( HtmArch, '<p class="updated">Date:' + DToC( Date() ) + "  " + "Time: " + Time() )
Html_LineText( HtmArch, cMessage + "</p>" )
n := 2
ai = cmessage + Chr( 13 ) + Chr ( 10 ) + Chr( 13 ) + Chr ( 10 )
WHILE ! Empty( ProcName( n ) )
   xText := "Called from " + ProcName( n ) + "(" + AllTrim( Str( ProcLine( n++ ) ) ) + ")" + Chr( 13 ) + Chr( 10 )
   ai = ai + xText
   Html_LineText( HtmArch, xText )
END
Html_Line( HtmArch )

ShowError( oError )

QUIT

RETURN .F.

// [vszakats]

STATIC FUNCTION ErrorMessage( oError )

LOCAL cMessage

// start error message
cMessage := iif( oError:severity > ES_WARNING, "Error", "Warning" ) + " "

// add subsystem name if available
IF ISCHARACTER( oError:subsystem )
   cMessage += oError:subsystem()
ELSE
   cMessage += "???"
ENDIF

// add subsystem's error code if available
IF ISNUMBER( oError:subCode )
   cMessage += "/" + LTrim( Str( oError:subCode ) )
ELSE
   cMessage += "/???"
ENDIF

// add error description if available
IF ISCHARACTER( oError:description )
   cMessage += "  " + oError:description
ENDIF

// add either filename or operation
DO CASE
CASE !Empty( oError:filename )
   cMessage += ": " + oError:filename
CASE !Empty( oError:operation )
   cMessage += ": " + oError:operation
ENDCASE

RETURN cMessage

*******************************************
Function ShowError ( oError )
*******************************************
LOCAL cArq_Log_Erro, x_body_erro
LOCAL i, cType_, cCod_erro, e_x_t, nHandle

Tone( 1000 )

cArq_Log_Erro := StrTran( Lower( hb_cmdargargv() ), ".exe", "_error.log" )

x_body_erro := "" + CRLF
x_body_erro += " " + ErrorMessage( oError ) + CRLF
x_body_erro += "" + CRLF
x_body_erro += " Date.................: " + DToC( Date() ) + "  Time: " + Time() + CRLF
x_body_erro += " Application Name.....: " + hb_cmdargargv() + CRLF
x_body_erro += " Current Workstation..: " + NetName() + CRLF
x_body_erro += " Operating System.....: " + OS() + CRLF
x_body_erro += " Error................: " + ErrorMessage( oError ) + CRLF
x_body_erro += " File.................: " + oError:filename() + CRLF
x_body_erro += " DOS error code.......: " + strvalue( oError:oscode() ) + CRLF
x_body_erro += "" + CRLF
x_body_erro += " Memory for character..: " + hb_ntos( Memory( 0 ) ) + " for Block: " + hb_ntos( Memory( 1 ) ) + " for RUN: " + hb_ntos( Memory( 2 ) ) + CRLF
x_body_erro += "" + CRLF
IF !Empty( Alias() )
   x_body_erro += " Database open........: " + Alias() + " Index Order: " + IndexKey( IndexOrd() ) + CRLF + "" + CRLF
ENDIF
x_body_erro += " Arguments:" + CRLF
x_body_erro += " ----------" + CRLF
IF ValType( oError:args ) == "A"
   x_body_erro += " Array: " + hb_ntos( Len( oError:args ) ) + " Elements " + CRLF
   i := 1
   DO WHILE i < 4
      x_body_erro += " Element[" + hb_ntos( i ) + "]......: = Type: " + ValType( oError:args[ i ] ) + " Val: " + LTrim( hb_CStr( oError:args[ i ] ) ) + CRLF
      IF i == Len( oError:args )
         EXIT
      ENDIF
      i++
   END
ELSE
   x_body_erro += " " + hb_CStr( oError:args ) + CRLF + "" + CRLF
ENDIF
x_body_erro += "" + CRLF
x_body_erro += " Trace for Error:" + CRLF
x_body_erro += " ----------------" + CRLF

i := 2
do while ( !Empty( ProcName( ++i ) ) )
   x_body_erro += " Called from: " + Trim( ProcName( i ) ) + "(" + AllTrim( Str( ProcLine( i ) ) ) + ") - " + Subs( ProcFile( i ), RAt( "/", ProcFile( i ) ) + 1 ) + CRLF
enddo

cCod_erro := RTrim( oError:subSystem ) + '/' + LTrim( Str( oError:subCode ) )
if Left( cCod_erro, 1 ) == '/'
   cCod_erro := SUBS( cCod_erro, 2 )
endif

IF File( "ERROR.DBF" )
   USE ERROR EXCLUSIVE NEW
   e_x_t := ordBagExt()
   IF e_x_t = ".CDX"
      IF !File( "ERROR.CDX" )
         INDEX ON FIELD->CODE_ER TAG INDEX1 TO ERROR
      ENDIF
   ELSE
      IF !File( "ERROR.NTX" )
         INDEX ON FIELD->CODE_ER TO ERROR
      ENDIF
   ENDIF
   USE
   USE ERROR SHARED NEW
   SET INDEX TO ERROR
   GO TOP
   SEEK cCod_erro
   cType_ := ""
   IF Found()
      DO WHILE cCod_erro = AllTrim( ERROR->CODE_ER )
         IF cType_ != ERROR->TYPE_ER
            x_body_erro += "" + CRLF
            cType_ := ERROR->TYPE_ER
            IF cType_ == "C"
               x_body_erro += " Error Description:" + CRLF
            ELSE
               x_body_erro += " Action:" + CRLF
            ENDIF
         ENDIF
         x_body_erro += "   " + ERROR->MESSAGE_ER + CRLF
         SKIP
      ENDDO
      x_body_erro += "" + CRLF
   ENDIF
   USE
ENDIF

IF oError:osCode # 4
   nHandle := FCreate( cArq_Log_Erro, 0 )
   IF nHandle < 3
      nHandle := FCreate( cArq_Log_Erro, 0 )
   ENDIF

   IF nHandle < 3
   ELSE
      FWrite( nHandle, x_body_erro )
   ENDIF
   FClose( nHandle )
ENDIF

DEFINE WINDOW wndError ;
   AT     0, 0 ;
   WIDTH  760 + GetBorderWidth() ;
   HEIGHT 560 + GetBorderHeight() / 2 ;
   TITLE  'Program Error' ;
   MODAL ;
   NOSYSMENU

@ 5, 5 RICHEDITBOX oRichEdit ;
   WIDTH 740 ;
   HEIGHT 475 ;
   VALUE x_body_erro ;
   FONT 'Courier New' ;
   SIZE 10 NOTABSTOP

@ 490, 660 BUTTON Button_1 ;
   CAPTION 'Exit' ;
   ACTION {|| wndError.release } ;
   WIDTH 80 ;
   HEIGHT 28 DEFAULT

@ 490, 105 BUTTON Button_2 ;
   CAPTION 'Export PDF' ;
   ACTION {|| ExpErrorPDF( cArq_Log_Erro ) } ;
   WIDTH 80 ;
   HEIGHT 28

@ 490, 10 BUTTON Button_3 ;
   CAPTION 'Print' ;
   ACTION {|| PrintError( cArq_Log_Erro ) } ;
   WIDTH 80 ;
   HEIGHT 28

END WINDOW

CENTER WINDOW wndError
ACTIVATE WINDOW wndError

dbCloseAll()
IF File( "ERROR.CDX" )
   FErase( "ERROR.CDX" )
ENDIF
IF File( "ERROR.NTX" )
   FErase( "ERROR.NTX" )
ENDIF

ExitProcess( 0 )

Return Nil

*------------------------------------------------------------------------------
*-01-01-2003
*-AUTHOR: Antonio Novo
*-Create/Open the ErrorLog.Htm file
*-Note: Is used in: errorsys.prg and h_error.prg
*------------------------------------------------------------------------------
FUNCTION HTML_ERRORLOG
*---------------------
Local HtmArch := 0
If .NOT. File( "\" + CurDir() + "\ErrorLog.Htm" )
   HtmArch := HtmL_Ini( "\" + CurDir() + "\ErrorLog.Htm", "HMG Errorlog File" )
   Html_Line( HtmArch )
Else
   HtmArch := FOpen( "\" + CurDir() + "\ErrorLog.Htm", 2 )
   FSeek( HtmArch, 0, 2 )    //End Of File
EndIf

RETURN ( HtmArch )

*------------------------------------------------------------------------------
*-30-12-2002
*-AUTHOR: Antonio Novo
*-HTML Page Head
*------------------------------------------------------------------------------
FUNCTION HTML_INI( ARCH, TIT )
*-----------------------------
LOCAL HTMARCH
LOCAL cStilo := "<style> "      + ;
   "body{ "                     + ;
   "font-family: sans-serif;"   + ;
   "background-color: #ffffff;" + ;
   "font-size: 75%;"            + ;
   "color: #000000;"            + ;
   "}"                          + ;
   "h1{"                        + ;
   "font-family: sans-serif;"   + ;
   "font-size: 150%;"           + ;
   "color: #0000cc;"            + ;
   "font-weight: bold;"         + ;
   "background-color: #f0f0f0;" + ;
   "}"                          + ;
   ".updated{"                  + ;
   "font-family: sans-serif;"   + ;
   "color: #cc0000;"            + ;
   "font-size: 110%;"           + ;
   "}"                          + ;
   ".normaltext{"               + ;
   "font-family: sans-serif;"   + ;
   "font-size: 100%;"           + ;
   "color: #000000;"            + ;
   "font-weight: normal;"       + ;
   "text-transform: none;"      + ;
   "text-decoration: none;"     + ;
   "}"                          + ;
   "</style>"

HTMARCH := FCreate( ARCH )
FWrite( HTMARCH, "<HTML><HEAD><TITLE>" + TIT + "</TITLE></HEAD>" + cStilo + "<BODY>" + Chr( 13 ) + Chr( 10 ) )
FWrite( HTMARCH, '<H1 Align=Center>' + TIT + '</H1><BR>' + Chr( 13 ) + Chr( 10 ) )

RETURN ( HTMARCH )

*------------------------------------------------------------------------------
*-30-12-2002
*-AUTHOR: Antonio Novo
*-HTM Page Line
*------------------------------------------------------------------------------
FUNCTION HTML_LINETEXT( HTMARCH, LINEA )
*---------------------------------------
FWrite( HTMARCH, RTrim( LINEA ) + "<BR>" + Chr( 13 ) + Chr( 10 ) )

RETURN ( .T. )

*------------------------------------------------------------------------------
*-30-12-2002
*-AUTHOR: Antonio Novo
*-HTM Line
*------------------------------------------------------------------------------
FUNCTION HTML_LINE( HTMARCH )
*----------------------------
FWrite( HTMARCH, "<HR>" + Chr( 13 ) + Chr( 10 ) )

RETURN ( .T. )

*------------------------------------------------------------------------------
STATIC FUNCTION strvalue( c )

LOCAL cr := "", _l := .F.

SWITCH ValType( c )
CASE "C"
   cr := c
   EXIT
CASE "N"
   cr := hb_ntos( c )
   EXIT
CASE "M"
   cr := c
   EXIT
CASE "D"
   cr := DToC( c )
   EXIT
CASE "L"
   cr := iif( _l, iif( c, "On", "Off" ), iif( c, ".t.", ".f." ) )
ENDSWITCH

RETURN Upper( cr )

*------------------------------------------------------------------------------
FUNCTION ExpErrorPDF( logfile )

local txtfile, txt
local page, height, width, font, fontsize
local l, vpag
local cFileToSave := StrTran( Lower( hb_cmdargargv() ), ".exe", "_error.pdf" )
Local oPdfError := HPDF_New()

if oPdfError == NIL
   return .F.
endif
HPDF_SetCompressionMode( oPdfError, HPDF_COMP_ALL )
page := HPDF_AddPage( oPdfError )
height := HPDF_Page_GetHeight( page )
width  := HPDF_Page_GetWidth( page )
font := HPDF_GetFont( oPdfError, "Courier", NIL )
fontsize := 12

txtfile := MemoRead( logfile )
HPDF_Page_BeginText( page )
HPDF_Page_MoveTextPos( page, 15, height - 20 )
vpag := .F.
for l = 1 to MLCount( txtfile, 255 )
   if vpag
      HPDF_Page_EndText( page )
      page := HPDF_AddPage( oPdfError )
      HPDF_Page_BeginText( page )
      HPDF_Page_MoveTextPos( page, 15, height - 20 )
      vpag := .F.
   endif
   txt := MemoLine( txtfile, 255, l, 1, .F. )
   if Chr( 15 ) + Chr( 14 ) $ txt
      txt := StrTran( txt, Chr( 15 ) + Chr( 14 ), "" )
   ENDIF
   if Chr( 20 ) + Chr( 18 ) $ txt
      txt := StrTran( txt, Chr( 20 ) + Chr( 18 ), "" )
   ENDIF
   If Chr( 12 ) $ txt
      txt := StrTran( txt, Chr( 12 ) + Chr( 13 ), "" )
      vpag := .T.
   endif
   HPDF_Page_SetFontAndSize( page, font, fontsize )
   HPDF_Page_ShowText( page, txt )
   HPDF_Page_MoveTextPos( page, 0, -10 )
next l
HPDF_Page_EndText( page )

HPDF_SaveToFile( oPdfError, cFileToSave )
HPDF_Free( oPdfError )

If File( cFileToSave )
   _EXECUTE( 0, , cFileToSave, , , 5 )
Endif

RETURN .T.

*------------------------------------------------------------------------------
FUNCTION PrintError( logfile )

Local cPrinter, txtfile, i_l, lPag := .F., txt_, nRow_

cPrinter := GetPrinter()

If !Empty ( cPrinter )

   SELECT PRINTER cPrinter ;
      ORIENTATION PRINTER_ORIENT_PORTRAIT ;
      PAPERSIZE PRINTER_PAPER_A4 ;
      PREVIEW

   txtfile := MemoRead( logfile )
   nRow_ := 10
   START PRINTDOC

      START PRINTPAGE

      for i_l = 1 to MLCount( txtfile, 255 )

         if lPag
            END PRINTPAGE
            START PRINTPAGE
            lPag := .F.
            nRow_ := 10
         endif
         txt_ = MemoLine( txtfile, 255, i_l, 1, .F. )
         if Chr( 15 ) + Chr( 14 ) $ txt_
            txt_ := StrTran( txt_, Chr( 15 ) + Chr( 14 ), "" )
         endif
         if Chr( 20 ) + Chr( 18 ) $ txt_
            txt_ := StrTran( txt_, Chr( 20 ) + Chr( 18 ), "" )
         endif
         If Chr( 12 ) $ txt_
            txt_ := StrTran( txt_, Chr( 12 ) + Chr( 13 ), "" )
            lPag := .T.
         endif
         @ nRow_, 15 PRINT txt_ ;
            FONT 'Courier New' ;
            SIZE 10
         nRow_ += 4.5
      Next

      END PRINTPAGE

   END PRINTDOC

EndIf

RETURN NIL
