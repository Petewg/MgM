/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

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
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - http://harbour-project.org

   "Harbour Project"
   Copyright 1999-2017, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "error.ch"
#include "fileio.ch"
#include "hbmemvar.ch"
#include "hbver.ch"

#ifdef _TSBROWSE_
  MEMVAR _TSB_aControlhWnd
#endif
*-----------------------------------------------------------------------------*
PROCEDURE ErrorSys
*-----------------------------------------------------------------------------*
   ErrorBlock( { | oError | DefError( oError ) } )
#ifndef __XHARBOUR__
   Set( _SET_HBOUTLOG, GetStartUpFolder() + "\error.log" )
   Set( _SET_HBOUTLOGINFO, MiniGUIVersion() )
#endif

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION DefError( oError )
*-----------------------------------------------------------------------------*
   LOCAL cText
   LOCAL HtmArch
   LOCAL HtmText
   LOCAL n

   // By default, division by zero results in zero
   IF oError:genCode == EG_ZERODIV .AND. ;
         oError:canSubstitute
      RETURN 0
   ENDIF

   // By default, retry on RDD lock error failure
   IF oError:genCode == EG_LOCK .AND. ;
         oError:canRetry
      RETURN .T.
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
   cText := ErrorMessage( oError )

   Html_LineText( HtmArch, '<p class="updated">Application: ' + GetExeFileName() )
   Html_LineText( HtmArch, 'Date: ' + DToC( Date() ) + "  " + "Time: " + Time() )
   Html_LineText( HtmArch, 'Time from start: ' + TimeFromStart() )
   Html_LineText( HtmArch, cText + "</p>" )
   cText += CRLF + CRLF

   n := 1
   WHILE ! Empty( ProcName( ++n ) )
      HtmText := "Called from " + ProcName( n ) + "(" + hb_ntos( ProcLine( n ) ) + ")" + ;
         iif( ProcLine( n ) > 0, " in module: " + ProcFile( n ), "" ) + CRLF
      cText += HtmText
      Html_LineText( HtmArch, HtmText )
   ENDDO

   IF _lShowDetailError()
      ErrorLog( HtmArch, oError )
   ENDIF

   Html_Line( HtmArch )
   Html_End( HtmArch )

   ShowError( cText, oError )

   ExitProcess()

RETURN .F.

*-----------------------------------------------------------------------------*
STATIC FUNCTION ErrorMessage( oError )
*-----------------------------------------------------------------------------*
   // start error message
   LOCAL cMessage := iif( oError:severity > ES_WARNING, "Error", "Warning" ) + " "

   // add subsystem name if available
   IF ISCHARACTER( oError:subsystem )
      cMessage += oError:subsystem()
   ELSE
      cMessage += "???"
   ENDIF

   // add subsystem's error code if available
   IF ISNUMBER( oError:subCode )
      cMessage += "/" + hb_ntos( oError:subCode )
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

   // add OS error code if available
   IF !Empty( oError:osCode )
      cMessage += " (DOS Error " + hb_ntos( oError:osCode ) + ")"
   ENDIF

RETURN cMessage

*-----------------------------------------------------------------------------*
STATIC PROCEDURE ShowError( cErrorMessage, oError )
*-----------------------------------------------------------------------------*
   STATIC _lShowError := .T.

   IF _lShowError

      _lShowError := .F.
#ifdef _TSBROWSE_
      _TSB_aControlhWnd := {}
#endif
      MsgStop( iif( _lShowDetailError(), cErrorMessage, ErrorMessage( oError ) ), 'Program Error', NIL, .F. )

      ErrorLevel( 1 )

      ReleaseAllWindows()

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE ErrorLog( nHandle, oErr )
*-----------------------------------------------------------------------------*
   STATIC _lAddError := .T.
#ifdef __XHARBOUR__
   LOCAL nCount
#else
   LOCAL nScope, nCount, tmp, cName, xValue
#endif

   IF _lAddError

      _lAddError := .F.

      Html_LineText( nHandle, "" )
      Html_LineText( nHandle, PadC( " System Information ", 79, "-" ) )
      Html_LineText( nHandle, "" )

      Html_LineText( nHandle, "Workstation name...: " + NetName() )
      Html_LineText( nHandle, "Active user name...: " + GetUserName() )
      Html_LineText( nHandle, "Available memory...: " + strvalue( MemoryStatus( 2 ) ) + " MB" )
      Html_LineText( nHandle, "Current disk.......: " + DiskName() )
      Html_LineText( nHandle, "Current directory..: " + CurDir() )
      Html_LineText( nHandle, "Free disk space....: " + strvalue( Round( DiskSpace() / ( 1024 * 1024 ), 0 ) ) + " MB" )
      Html_LineText( nHandle, "" )
      Html_LineText( nHandle, "Operating system...: " + OS() )
      Html_LineText( nHandle, "MiniGUI version....: " + MiniGUIVersion() )
      Html_LineText( nHandle, "Harbour version....: " + Version() )
#if ( __HARBOUR__ - 0 > 0x030200 )
      Html_LineText( nHandle, "Harbour built on...: " + hb_Version( HB_VERSION_BUILD_DATE_STR ) )
#else
      Html_LineText( nHandle, "Harbour built on...: " + hb_BuildDate() )
#endif
      Html_LineText( nHandle, "C/C++ compiler.....: " + hb_Compiler() )

#ifdef __XHARBOUR__
      Html_LineText( nHandle, "Multi Threading....: " + iif( Hb_MultiThread(), "YES", "NO" ) )
      Html_LineText( nHandle, "VM Optimization....: " + strvalue( hb_VMMode() ) )

      IF Type( "Select()" ) == "UI" .OR. Type( "Select()" ) == "N"
         Html_LineText( nHandle, "" )
         Html_LineText( nHandle, "Current Work Area..: " + strvalue( &("Select()") ) )
#else
      Html_LineText( nHandle, "Multi Threading....: " + iif( hb_mtvm(), "YES", "NO" ) )

      IF hb_IsFunction( "Select" )
         Html_LineText( nHandle, "" )
         Html_LineText( nHandle, "Current Work Area..: " + strvalue( Eval( hb_macroBlock( "Select()" ) ) ) )
#endif
      ENDIF

      Html_LineText( nHandle, "" )
      Html_LineText( nHandle, PadC( " Environmental Information ", 79, "-" ) )
      Html_LineText( nHandle, "" )

      Html_LineText( nHandle, "SET ALTERNATE......: " + strvalue( Set( _SET_ALTERNATE ), .T. ) )
      Html_LineText( nHandle, "SET ALTFILE........: " + strvalue( Set( _SET_ALTFILE ) ) )
      Html_LineText( nHandle, "SET AUTOPEN........: " + strvalue( Set( _SET_AUTOPEN ), .T. ) )
      Html_LineText( nHandle, "SET AUTORDER.......: " + strvalue( Set( _SET_AUTORDER ) ) )
      Html_LineText( nHandle, "SET AUTOSHARE......: " + strvalue( Set( _SET_AUTOSHARE ) ) )

#ifdef __XHARBOUR__
      Html_LineText( nHandle, "SET BACKGROUNDTASKS: " + strvalue( Set( _SET_BACKGROUNDTASKS ), .T. ) )
      Html_LineText( nHandle, "SET BACKGROUNDTICK.: " + strvalue( Set( _SET_BACKGROUNDTICK ), .T. ) )
#endif
      Html_LineText( nHandle, "SET CENTURY........: " + strvalue( __SetCentury(), .T. ) )
      Html_LineText( nHandle, "SET COUNT..........: " + strvalue( Set( _SET_COUNT ) ) )

      Html_LineText( nHandle, "SET DATE FORMAT....: " + strvalue( Set( _SET_DATEFORMAT ) ) )
      Html_LineText( nHandle, "SET DBFLOCKSCHEME..: " + strvalue( Set( _SET_DBFLOCKSCHEME ) ) )
      Html_LineText( nHandle, "SET DEBUG..........: " + strvalue( Set( _SET_DEBUG ), .T. ) )
      Html_LineText( nHandle, "SET DECIMALS.......: " + strvalue( Set( _SET_DECIMALS ) ) )
      Html_LineText( nHandle, "SET DEFAULT........: " + strvalue( Set( _SET_DEFAULT ) ) )
      Html_LineText( nHandle, "SET DEFEXTENSIONS..: " + strvalue( Set( _SET_DEFEXTENSIONS ), .T. ) )
      Html_LineText( nHandle, "SET DELETED........: " + strvalue( Set( _SET_DELETED ), .T. ) )
      Html_LineText( nHandle, "SET DELIMCHARS.....: " + strvalue( Set( _SET_DELIMCHARS ) ) )
      Html_LineText( nHandle, "SET DELIMETERS.....: " + strvalue( Set( _SET_DELIMITERS ), .T. ) )
      Html_LineText( nHandle, "SET DIRCASE........: " + strvalue( Set( _SET_DIRCASE ) ) )
      Html_LineText( nHandle, "SET DIRSEPARATOR...: " + strvalue( Set( _SET_DIRSEPARATOR ) ) )

      Html_LineText( nHandle, "SET EOL............: " + strvalue( Asc( Set( _SET_EOL ) ) ) )
      Html_LineText( nHandle, "SET EPOCH..........: " + strvalue( Set( _SET_EPOCH ) ) )
      Html_LineText( nHandle, "SET ERRORLOG.......: " + strvalue( _GetErrorlogFile() ) )
#ifdef __XHARBOUR__
      Html_LineText( nHandle, "SET ERRORLOOP......: " + strvalue( Set( _SET_ERRORLOOP ) ) )
#endif
      Html_LineText( nHandle, "SET EXACT..........: " + strvalue( Set( _SET_EXACT ), .T. ) )
      Html_LineText( nHandle, "SET EXCLUSIVE......: " + strvalue( Set( _SET_EXCLUSIVE ), .T. ) )
      Html_LineText( nHandle, "SET EXTRA..........: " + strvalue( Set( _SET_EXTRA ), .T. ) )
      Html_LineText( nHandle, "SET EXTRAFILE......: " + strvalue( Set( _SET_EXTRAFILE ) ) )

      Html_LineText( nHandle, "SET FILECASE.......: " + strvalue( Set( _SET_FILECASE ) ) )
      Html_LineText( nHandle, "SET FIXED..........: " + strvalue( Set( _SET_FIXED ), .T. ) )
      Html_LineText( nHandle, "SET FORCEOPT.......: " + strvalue( Set( _SET_FORCEOPT ), .T. ) )

      Html_LineText( nHandle, "SET HARDCOMMIT.....: " + strvalue( Set( _SET_HARDCOMMIT ), .T. ) )

      Html_LineText( nHandle, "SET IDLEREPEAT.....: " + strvalue( Set( _SET_IDLEREPEAT ), .T. ) )

      Html_LineText( nHandle, "SET LANGUAGE.......: " + strvalue( Set( _SET_LANGUAGE ) ) )

      Html_LineText( nHandle, "SET MARGIN.........: " + strvalue( Set( _SET_MARGIN ) ) )
      Html_LineText( nHandle, "SET MBLOCKSIZE.....: " + strvalue( Set( _SET_MBLOCKSIZE ) ) )
      Html_LineText( nHandle, "SET MFILEEXT.......: " + strvalue( Set( _SET_MFILEEXT ) ) )

      Html_LineText( nHandle, "SET OPTIMIZE.......: " + strvalue( Set( _SET_OPTIMIZE ), .T. ) )
#ifdef __XHARBOUR__
      Html_LineText( nHandle, "SET OUTPUTSAFETY...: " + strvalue( Set( _SET_OUTPUTSAFETY ), .T. ) )
#endif

      Html_LineText( nHandle, "SET PATH...........: " + strvalue( Set( _SET_PATH ) ) )
      Html_LineText( nHandle, "SET PRINTER........: " + strvalue( Set( _SET_PRINTER ), .T. ) )
#ifdef __XHARBOUR__
      Html_LineText( nHandle, "SET PRINTERJOB.....: " + strvalue( Set( _SET_PRINTERJOB ) ) )
#endif
      Html_LineText( nHandle, "SET PRINTFILE......: " + strvalue( Set( _SET_PRINTFILE ) ) )

      Html_LineText( nHandle, "SET SOFTSEEK.......: " + strvalue( Set( _SET_SOFTSEEK ), .T. ) )

#ifdef __XHARBOUR__
      Html_LineText( nHandle, "SET TRACE..........: " + strvalue( Set( _SET_TRACE ), .T. ) )
      Html_LineText( nHandle, "SET TRACEFILE......: " + strvalue( Set( _SET_TRACEFILE ) ) )
      Html_LineText( nHandle, "SET TRACESTACK.....: " + strvalue( Set( _SET_TRACESTACK ) ) )
#endif
      Html_LineText( nHandle, "SET TRIMFILENAME...: " + strvalue( Set( _SET_TRIMFILENAME ) ) )

      Html_LineText( nHandle, "SET UNIQUE.........: " + strvalue( Set( _SET_UNIQUE ), .T. ) )

      Html_LineText( nHandle, "" )
      Html_LineText( nHandle, PadC( " Detailed Work Area Items ", 79, "-" ) )
      Html_LineText( nHandle, "" )

#ifdef __XHARBOUR__
      IF Type( "Select()" ) == "UI" .OR. Type( "Select()" ) == "N"
         FOR nCount := 1 TO 250
            IF !Empty( ( nCount )->( &("Alias()" ) ) )
               ( nCount )->( Html_LineText( nHandle, "Work Area No ......: " + strvalue( &("Select()" ) ) ) )
               ( nCount )->( Html_LineText( nHandle, "Alias .............: " + &("Alias()" ) ) )
               ( nCount )->( Html_LineText( nHandle, "Current Recno .....: " + strvalue( &("RecNo()" ) ) ) )
               ( nCount )->( Html_LineText( nHandle, "Current Filter ....: " + &("DbFilter()" ) ) )
               ( nCount )->( Html_LineText( nHandle, "Relation Exp. .....: " + &("DbRelation()" ) ) )
               ( nCount )->( Html_LineText( nHandle, "Index Order .......: " + strvalue( &("IndexOrd(0)" ) ) ) )
               ( nCount )->( Html_LineText( nHandle, "Active Key ........: " + strvalue( &("IndexKey(0)" ) ) ) )
               ( nCount )->( Html_LineText( nHandle, "" ) )
            ENDIF
         NEXT
      ENDIF
#else
      hb_WAEval( {||
         IF hb_IsFunction( "Select" )
            Html_LineText( nHandle, "Work Area No ......: " + strvalue( Do( "Select" ) ) )
         ENDIF
         IF hb_IsFunction( "Alias" )
            Html_LineText( nHandle, "Alias .............: " + Do( "Alias" ) )
         ENDIF
         IF hb_IsFunction( "RecNo" )
            Html_LineText( nHandle, "Current Recno .....: " + strvalue( Do( "RecNo" ) ) )
         ENDIF
         IF hb_IsFunction( "dbFilter" )
            Html_LineText( nHandle, "Current Filter ....: " + Do( "dbFilter" ) )
         ENDIF
         IF hb_IsFunction( "dbRelation" )
            Html_LineText( nHandle, "Relation Exp. .....: " + Do( "dbRelation" ) )
         ENDIF
         IF hb_IsFunction( "IndexOrd" )
            Html_LineText( nHandle, "Index Order .......: " + strvalue( Do( "IndexOrd" ) ) )
         ENDIF
         IF hb_IsFunction( "IndexKey" )
            Html_LineText( nHandle, "Active Key ........: " + strvalue( Eval( hb_macroBlock( "IndexKey( 0 )" ) ) ) )
         ENDIF
         Html_LineText( nHandle, "" )
         RETURN .T.
         } )
#endif
      Html_LineText( nHandle, PadC( " Internal Error Handling Information ", 79, "-" ) )
      Html_LineText( nHandle, "" )
      Html_LineText( nHandle, "Subsystem Call ....: " + oErr:subsystem() )
      Html_LineText( nHandle, "System Code .......: " + strvalue( oErr:subcode() ) )
      Html_LineText( nHandle, "Default Status ....: " + strvalue( oErr:candefault() ) )
      Html_LineText( nHandle, "Description .......: " + oErr:description() )
      Html_LineText( nHandle, "Operation .........: " + oErr:operation() )
      Html_LineText( nHandle, "Involved File .....: " + oErr:filename() )
      Html_LineText( nHandle, "Dos Error Code ....: " + strvalue( oErr:oscode() ) )

#ifdef __XHARBOUR__
#ifdef HB_THREAD_SUPPORT
      Html_LineText( nHandle, "Running threads ...: " + strvalue( oErr:RunningThreads() ) )
      Html_LineText( nHandle, "VM thread ID ......: " + strvalue( oErr:VmThreadId() ) )
      Html_LineText( nHandle, "OS thread ID ......: " + strvalue( oErr:OsThreadId() ) )
#endif
#else
      /* NOTE: Adapted from hb_mvSave() source in Harbour RTL. */
      Html_LineText( nHandle, "" )
      Html_LineText( nHandle, PadC( " Available Memory Variables ", 79, "+" ) )
      Html_LineText( nHandle, "" )

      FOR EACH nScope IN { HB_MV_PUBLIC, HB_MV_PRIVATE }
         nCount := __mvDbgInfo( nScope )
         FOR tmp := 1 TO nCount
            xValue := __mvDbgInfo( nScope, tmp, @cName )
            IF ValType( xValue ) $ "CNDTL" .AND. Left( cName, 1 ) <> "_"
               Html_LineText( nHandle, "      " + cName + " TYPE " + ValType( xValue ) + " [" + hb_CStr( xValue ) + "]" )
            ENDIF
         NEXT
      NEXT

      IF nCount > 0
         Html_LineText( nHandle, "" )
      ENDIF
#endif
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION strvalue( c, l )
*-----------------------------------------------------------------------------*

   SWITCH ValType( c )
   CASE "C"
   CASE "M" ; RETURN c
   CASE "N" ; RETURN hb_ntos( c )
   CASE "D" ; RETURN DToC( c )
   CASE "L" ; RETURN iif( hb_defaultValue( l, .F. ), iif( c, "ON", "OFF" ), iif( c, ".T.", ".F." ) )
   ENDSWITCH

RETURN ""

/* Date Created: 14/11/2005
   Author: Antonio Novo <antonionovo@gmail.com>
   Enable/Disable Error Detail */
*-----------------------------------------------------------------------------*
FUNCTION _lShowDetailError( lNewValue )
*-----------------------------------------------------------------------------*
   STATIC _lShowDetailError := .T.
   LOCAL lOldValue := _lShowDetailError

   IF ISLOGICAL( lNewValue )
      _lShowDetailError := lNewValue
   ENDIF

RETURN lOldValue

#if defined( __XHARBOUR__ ) .OR. ( __HARBOUR__ - 0 < 0x030200 )
*-01-01-2003
*-Author: Antonio Novo
*-Create/Open the ErrorLog.Htm file
*-----------------------------------------------------------------------------*
FUNCTION HTML_ERRORLOG
*-----------------------------------------------------------------------------*
   LOCAL HtmArch := -1
   LOCAL cErrorLogFile := _GetErrorlogFile()

   IF IsErrorLogActive()
      IF .NOT. File( cErrorLogFile )
         HtmArch := Html_Ini( cErrorLogFile, "Harbour MiniGUI Errorlog File" )
         IF HtmArch > 0
            Html_Line( HtmArch )
         ENDIF
      ELSE
         HtmArch := FOpen( cErrorLogFile, FO_READWRITE )
         IF HtmArch > 0
            FSeek( HtmArch, 0, FS_END )
         ENDIF
      ENDIF
   ENDIF

RETURN ( HtmArch )

*-30-12-2002
*-Author: Antonio Novo
*-HTML Page Head
*-----------------------------------------------------------------------------*
FUNCTION HTML_INI( ARCH, TITLE )
*-----------------------------------------------------------------------------*
   LOCAL HtmArch := -1
   LOCAL cStyle  := "<style> "     + ;
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

   IF IsErrorLogActive()
      HtmArch := FCreate( ARCH )
      IF FError() != 0
         MsgStop( "Can`t open errorlog file " + ARCH, "Error" )
      ELSE
         FWrite( HtmArch, "<HTML><HEAD><TITLE>" + TITLE + "</TITLE></HEAD>" + cStyle + "<BODY>" + Chr( 13 ) + Chr( 10 ) )
         FWrite( HtmArch, "<H1 Align=Center>" + TITLE + "</H1><BR>" + Chr( 13 ) + Chr( 10 ) )
      ENDIF
   ENDIF

RETURN ( HtmArch )

*-30-12-2002
*-Author: Antonio Novo
*-HTM Page Line
*-----------------------------------------------------------------------------*
PROCEDURE HTML_LINETEXT( HTMARCH, LINEA )
*-----------------------------------------------------------------------------*
   IF HTMARCH > 0 .AND. IsErrorLogActive()
      FWrite( HTMARCH, RTrim( LINEA ) + "<BR>" + Chr( 13 ) + Chr( 10 ) )
   ENDIF

RETURN

*-30-12-2002
*-Author: Antonio Novo
*-HTM Line
*-----------------------------------------------------------------------------*
PROCEDURE HTML_LINE( HTMARCH )
*-----------------------------------------------------------------------------*
   IF HTMARCH > 0 .AND. IsErrorLogActive()
      FWrite( HTMARCH, "<HR>" + Chr( 13 ) + Chr( 10 ) )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE HTML_END( HTMARCH )
*-----------------------------------------------------------------------------*
   IF HTMARCH > 0 .AND. IsErrorLogActive()
      FWrite( HTMARCH, "</BODY></HTML>" )
      FClose( HTMARCH )
   ENDIF

RETURN

#else
*-01-01-2003
*-Author: Antonio Novo
*-Create/Open the ErrorLog.Htm file
*-----------------------------------------------------------------------------*
FUNCTION HTML_ERRORLOG
*-----------------------------------------------------------------------------*
   LOCAL HtmArch
   LOCAL cErrorLogFile := _GetErrorlogFile()

   IF IsErrorLogActive()
      IF .NOT. hb_vfExists( cErrorLogFile )
         HtmArch := Html_Ini( cErrorLogFile, "Harbour MiniGUI Errorlog File" )
         IF HtmArch != NIL
            Html_Line( HtmArch )
         ENDIF
      ELSE
         HtmArch := hb_vfOpen( cErrorLogFile, FO_WRITE )
         IF HtmArch != NIL
            hb_vfSeek( HtmArch, 0, FS_END )
         ENDIF
      ENDIF
   ENDIF

RETURN ( HtmArch )

*-30-12-2002
*-Author: Antonio Novo
*-HTML Page Head
*-----------------------------------------------------------------------------*
FUNCTION HTML_INI( ARCH, TITLE )
*-----------------------------------------------------------------------------*
   LOCAL HtmArch := -1
   LOCAL cStyle  := "<style> "     + ;
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

   IF IsErrorLogActive()
      HtmArch := hb_vfOpen( ARCH, FO_CREAT + FO_TRUNC + FO_WRITE )
      IF HtmArch == NIL
         MsgStop( "Can`t open errorlog file " + ARCH, "Error" )
      ELSE
         hb_vfWrite( HtmArch, "<HTML><HEAD><TITLE>" + TITLE + "</TITLE></HEAD>" + cStyle + "<BODY>" + CRLF )
         hb_vfWrite( HtmArch, "<H1 Align=Center>" + TITLE + "</H1><BR>" + CRLF )
      ENDIF
   ENDIF

RETURN ( HtmArch )

*-30-12-2002
*-Author: Antonio Novo
*-HTM Page Line
*-----------------------------------------------------------------------------*
PROCEDURE HTML_LINETEXT( HTMARCH, LINEA )
*-----------------------------------------------------------------------------*
   IF HTMARCH != NIL .AND. IsErrorLogActive()
      hb_vfWrite( HTMARCH, RTrim( LINEA ) + "<BR>" + CRLF )
   ENDIF

RETURN

*-30-12-2002
*-Author: Antonio Novo
*-HTM Line
*-----------------------------------------------------------------------------*
PROCEDURE HTML_LINE( HTMARCH )
*-----------------------------------------------------------------------------*
   IF HTMARCH != NIL .AND. IsErrorLogActive()
      hb_vfWrite( HTMARCH, "<HR>" + CRLF )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE HTML_END( HTMARCH )
*-----------------------------------------------------------------------------*
   IF HTMARCH != NIL .AND. IsErrorLogActive()
      hb_vfWrite( HTMARCH, "</BODY></HTML>" )
      hb_vfClose( HTMARCH )
   ENDIF

RETURN
#endif

// (JK) HMG 1.0 Build 6
*-----------------------------------------------------------------------------*
PROCEDURE _SetErrorLogFile( cFile )
*-----------------------------------------------------------------------------*
   _HMG_ErrorLogFile := IFEMPTY( cFile, GetStartUpFolder() + "\ErrorLog.htm", cFile )

RETURN
