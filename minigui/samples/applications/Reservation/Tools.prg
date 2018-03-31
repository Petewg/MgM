/*******************************************************************************
   Filename			: Tools.prg

   Created			: 05 April 2012 (10:50:55)
   Created by		: Pierpaolo Martinello

   Last Updated		: 01/11/2014 16:36:43
   Updated by		: Pierpaolo

   Comments			: Freeware
*******************************************************************************/

#include "minigui.ch"
#include "Prenota.ch"
#include 'inkey.ch'
#include 'fileio.ch'
//#include  "i_pseudofunc.ch"

#define EM_SETSEL 0x00B1
Memvar ofile, _HMG_IsValidInProgres, oFatt

/*
*/
*-----------------------------------------------------------------------------*
Function Srec_lock (tries, interactive, YNmessage)
*-----------------------------------------------------------------------------*
   LOCAL intries, rtv, counter:=0
   intries := tries
   rtv     := .f.
   DO WHILE tries > 0
      if RLOCK()
         rtv := .t.
         exit
      endif
      tries := tries-1
      if tries = 0 .and. interactive
         counter ++
         if MSGRetryCancel(YNmessage,"Tentativo di apertura n° "+zaps(counter)+" "+alias())
            tries := intries
         endif
      else
         inkey(.5)
      endif
   ENDDO
RETURN rtv
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION DtoW (adate,solomese) //Italian Version
*-----------------------------------------------------------------------------*
   Local nm := AMONTHS()
   default solomese to 0
   IF EMPTY(adate)
      RETURN SPACE(18)
   ENDIF

   if solomese = 0
      solomese := month(adate)
   endif
RETURN addspace(TRANS(DAY(adate),"99")+' '+trim(NM[solomese])+' '+TRANS(YEAR(adate),"9999"),18)
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION addspace(string,final_len)
*-----------------------------------------------------------------------------*
return SUBST(string+REPL(' ',final_len-LEN(string)),1,final_len)
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Writefile(filename,arrayname)
*-----------------------------------------------------------------------------*
Local f_handle,kounter
* open file and position pointer at the end of file
IF VALTYPE("filename")=="C"
  f_handle = FOPEN(filename,2)
  *- if not joy opening file, create one
  IF Ferror() <> 0
    f_handle := Fcreate(filename,0)
  ENDIF
  FSEEK(f_handle,0,2)
ELSE
  f_handle := filename
  FSEEK(f_handle,0,2)
ENDIF

IF VALTYPE(arrayname) == "A"
   * if its an array, do a loop to write it out
   FOR kounter = 1 TO len(arrayname)
       *- append a CR/LF
       FWRITE(f_handle,arrayname[kounter]+CRLF )
   NEXT
ELSE
  * must be a character string - just write it
  FWRITE(f_handle,arrayname+CRLF )
ENDIF (VALTYPE(arrayname) == "A")

* close the file
IF VALTYPE("filename") == "C"
   Fclose(f_handle)
ENDIF

RETURN .T.
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION NET_USE( file, ali, ex_use, tries, interactive, YNmessage )
*-----------------------------------------------------------------------------*
/*
 Net_Use( "CATE.DBF", "CATE", .F., 5, .T.,"Impossibile aprire CATE.DBF. Riprovo ancora?" )
*/
Local Rtv := .F.,intries := tries
   if !file(file)
      msgt(3,[Archivio ]+file+[ NON TROVATO! ],"Messaggio Temporizzato (NET_USE)",.t.)
      // InputBox ( 'Operazione:' , 'Stampa annullata!' , [Non hai scelto il report di stampa!], 3000 )
      return rtv
   endif
   while INtries > 0
        if ex_use
           IF !EMPTY(ali) //.and. select(ali)= 0
             USE (file) EXCLUSIVE alias &ali VIA oFatt:Dbf_driver
           else
             USE (file) EXCLUSIVE VIA oFatt:Dbf_driver
           endif
        else
           IF !EMPTY(ali)
             USE (file) alias &ali SHARED VIA oFatt:Dbf_driver
           else
             USE (file) SHARED VIA oFatt:Dbf_driver
           endif
        endif
        if !NETERR()
           rtv := .t.
           exit
        endif
        inkey(.5)
        INtries --             //= m->tries-1
        if INtries = 0 .and. interactive
           if MsgYesNo (YNmessage,"Apertura archivi "+if(ex_use,"esclusiva","condivisa"))
              INtries := tries
           endif
        endif
   enddo
return rtv
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION add_rec( tries, interactive, YNmessage )
*-----------------------------------------------------------------------------*
   local rtv :=.F., intries
//   param tries, interactive, YNmessage
   intries := tries
   WHILE intries > 0
         APPEND BLANK
         if !NETERR()
            rtv = .t.
            exit
         endif
         intries --
         if intries = 0 .and. interactive
            if msgYesNo(YNmessage)
               intries := tries
            endif
         else
            inkey(.5)
         endif
   END
RETURN rtv
/*
*/
*-----------------------------------------------------------------------------*
Procedure CancFile(File,msg)
*-----------------------------------------------------------------------------*
default msg to .F.
   if file(File)
      IF FERASE(File) == -1
         Msgt(3,"Al momento non è possibile cancellare il file:"+CRLF+CRLF+File+;
              Space(10)+CRLF+CRLF+"Riprovare più tardi!", "Errorre "+zaps(FERROR())+;
              " su "+PROCNAME(1)+" Linea "+zaps(Procline(1)),"EXCLAMATION")
      ENDIF
   Else
       if msg
          msgt(1, "Non trovo il file: "+CRLF+File)
       Endif
   Endif
return
/*
*/
*-----------------------------------------------------------------------------*
Function ESCAPE_ON(ARG1)
*-----------------------------------------------------------------------------*
     local WinName:=if(arg1==NIL,procname(1),arg1)
     if upper(WinName)<>'OFF'
        _definehotkey(arg1,0,27,{||(_HMG_IsValidInProgres:=.t.,_releasewindow(arg1),_HMG_IsValidInProgres:=.F.)})
     else
        ON KEY ESCAPE ACTION nil
     endif
return nil

/*
*/
*-----------------------------------------------------------------------------*
Procedure AzzeraDb(ARG1,start,stop)
*-----------------------------------------------------------------------------*
local archivio:=if (arg1=Nil,alias(),upper(arg1)) , old_sele:=select()
default start to 1, stop to .f.
      sele &archivio
      //msg(archivio,[archivio])
      go top
      do while !eof()
         if rlock()
            delete
            unlock
         else
            msg("Non cancellate",[Azzeradb])
         endif
         dbskip()
      enddo
      if !stop
         msg(2,[Si consiglia la ricostruzione indici!])
      endif
      select (old_sele)
return
/*
*/
*-----------------------------------------------------------------------------*
function cFileName( cPathMask )
*-----------------------------------------------------------------------------*
RETURN cFileNoPath( cPathMask )
/*
*/
*-----------------------------------------------------------------------------*
Function Edata(arg1)
*-----------------------------------------------------------------------------*
default arg1 to ctod("  /  /    ")
return substr(dtoc(arg1),1,2) == "  "
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Trueval(string)
*-----------------------------------------------------------------------------*
   local lenx,I,outval:='',letter
   default string to ''
   lenx := LEN(string)
   For i = 1 TO LEN(string)
       letter := SUBST(string,i,1)
       IF letter $ "-0123456789."
          outval += letter
       ENDIF
   NEXT
RETURN VAL(outval)
/*
*/
#pragma BEGINDUMP

// #define _WIN32_IE      0x0500
#define HB_OS_WIN_32_USED
#define _WIN32_WINNT   0x0400
#include <shlobj.h>
#include <stdio.h>

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "winreg.h"
#include "tchar.h"

#include <winuser.h>
#include <wingdi.h>
#include <olectl.h>
#include <ocidl.h>

#ifndef __XHARBOUR__
   #define ISBYREF( n )          HB_ISBYREF( n )
   #define ISNIL( n )            HB_ISNIL( n )
#endif

HB_FUNC ( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALWIDTH)
{
	HDC hdc = (HDC) hb_parni(1) ;
	hb_retnl ( GetDeviceCaps ( hdc , PHYSICALWIDTH ) ) ;
}

HB_FUNC ( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALHEIGTH)
{
	HDC hdc = (HDC) hb_parni(1) ;
	hb_retnl ( GetDeviceCaps ( hdc , PHYSICALHEIGHT ) ) ;
}

BOOL DirectoryExists( LPTSTR szDirName )
{
   unsigned int nAttributes;
   if ( ( nAttributes = GetFileAttributes( szDirName ) ) == -1 ) return FALSE;
   if ( ( nAttributes & FILE_ATTRIBUTE_DIRECTORY ) != 0 ) return TRUE;
   return FALSE;
}

HB_FUNC( ISDIRECTORY )
{
   hb_retl( DirectoryExists((char *) hb_parc(1) ) ) ;
}

HB_FUNC ( ZAPDIRECTORY )
{
	SHFILEOPSTRUCT sh;

	sh.hwnd   = GetActiveWindow();
	sh.wFunc  = FO_DELETE;
	sh.pFrom  = hb_parc(1);
	sh.pTo    = NULL;
	sh.fFlags = FOF_NOCONFIRMATION | FOF_SILENT;
	sh.hNameMappings = 0;
	sh.lpszProgressTitle = NULL;

	SHFileOperation (&sh);
}


#pragma argsused    // We need a lowercase!!! Solo per Experimental

HB_FUNC( GETFILESIZE )
{
   HANDLE hFile;
   DWORD nFileSize;
   hFile = CreateFile(hb_parc(1), GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
   if (hFile == INVALID_HANDLE_VALUE)
       nFileSize = -1 ;
   else
   nFileSize = GetFileSize(hFile, NULL);
   CloseHandle(hFile);
   hb_retnd( nFileSize);
}

HB_FUNC( GETFILETIME )
{
   HANDLE hFile;
   FILETIME Ft;
   SYSTEMTIME St;
   CHAR StrTime[32];

   hFile = CreateFile(hb_parc(1), GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
   if (hFile == INVALID_HANDLE_VALUE)
   {
     sprintf(StrTime, "00:00:00");
     hb_retc( StrTime );
   }
   else
   {
   GetFileTime(hFile,&Ft,NULL,NULL);
   CloseHandle(hFile);
   FileTimeToSystemTime(&Ft,&St);
   sprintf(StrTime, "%02d:%02d:%02d",(int) St.wHour,(int) St.wMinute,(int) St.wSecond);
   hb_retc( StrTime );
   }
}

HB_FUNC( GETFILEDATE )
{
   HANDLE hFile;
   FILETIME Fd;
   SYSTEMTIME Sd;
   CHAR StrDate[32];

   hFile = CreateFile(hb_parc(1), GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
   if (hFile == INVALID_HANDLE_VALUE)
   {
     sprintf(StrDate, "00/00/0000");
     hb_retc( StrDate );
   }
   else
   {
   GetFileTime(hFile,&Fd,NULL,NULL);
   CloseHandle(hFile);
   FileTimeToSystemTime(&Fd,&Sd);
   sprintf(StrDate, "%02d/%02d/%04d",(int) Sd.wDay,(int) Sd.wMonth,(int) Sd.wYear);
   hb_retc( StrDate );
   }
}

HB_FUNC ( ISEXERUNNING ) // ( cExeNameCaseSensitive ) --> lResult
{
   HANDLE hMutex = CreateMutex( NULL, TRUE, ( LPTSTR ) hb_parc( 1 ) );

   hb_retl( GetLastError() == ERROR_ALREADY_EXISTS );

   ReleaseMutex( hMutex );
}

HB_FUNC( ISICONIC )
{
   hb_retl( IsIconic( ( HWND ) hb_parnl( 1 ) ) );
}

HB_FUNC ( FINDWINDOW )
{
   hb_retnl( ( LONG ) FindWindow( 0, hb_parc( 1 ) ) );
}

HB_FUNC( COPYFILE )
{
   hb_retnl( (LONG) CopyFile( (LPCSTR) hb_parc(1), (LPCSTR) hb_parc(2), ISNIL(3) ? NULL : (LONG) hb_parni(3) ) );
}

#pragma ENDDUMP
