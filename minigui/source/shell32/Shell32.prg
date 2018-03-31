// ===========================================================================
// Shell32.PRG        (c) 2004, Grigory Filatov
// ===========================================================================
//
//   Created   : 08.09.04
//   Extended  : 28.04.07
//   Section   : Shell Extensions
//
//   Windows ShellAPI provides functions to implement:
//   · The drag-drop feature
//   · Associations (used) to find and start applications
//   · Extraction of icons from executable files
//   · Explorer File operation
//
//
// ===========================================================================

#include "Shell32.ch"
#include "common.ch"

// ===========================================================================
// Function ShFolderDelete( hParentWnd, acFolder, lSilent )
//
// Purpose:
//  Use the Windows ShellAPI function to delete folder(s) with all its files and
//  subdirectories.
//  acFolder can be an Array of FolderName string, or a single FolderName string.
//  If lSilent is TRUE (default), you can not an any confirmation
//
// ===========================================================================
FUNCTION SHFolderDelete( hWnd, acFolder, lSilent )

   LOCAL nFlag := 0

   DEFAULT hWnd TO GetActiveWindow()

   IF lSilent == NIL .OR. lSilent
      nFlag := FOF_NOCONFIRMATION + FOF_SILENT
   ENDIF

RETURN ( ShellFiles( hWnd, acFolder, , FO_DELETE, nFlag ) == 0 )


// ===========================================================================
// Function ShFileDelete( hParentWnd, aFiles, lRecycle )
//
// Purpose:
//  Use the Windows ShellAPI function to delete file(s).
//  aFiles can be an Array of FileName strings, or a single FileName string.
//  If lRecycle is TRUE (default), deleted files are moved into the recycle Bin
//
// ===========================================================================
FUNCTION SHFileDelete( hWnd, acFiles, lRecycle )

   LOCAL nFlag := 0

   DEFAULT hWnd TO GetActiveWindow()

   IF lRecycle == NIL .OR. lRecycle
      nFlag := FOF_ALLOWUNDO
   ENDIF

RETURN ( ShellFiles( hWnd, acFiles, , FO_DELETE, nFlag ) == 0 )


// ===========================================================================
// Function ShellFile( hParentWnd, aFiles, aTarget, nFunc, nFlag )
//
// Purpose:
// Performs a copy, move, rename, or delete operation on a file system object.
// Parameters:
//   aFiles  is an Array of Source-Filenamestrings, or a single Filenamestring
//   aTarget is an Array of Target-Filenamestrings, or a single Filenamestring
//   nFunc   determines the action on the files:
//           FO_MOVE, FO_COPY, FO_DELETE, FO_RENAME
//   fFlag   Option Flag ( see the file SHELL32.CH )
//
// ===========================================================================
FUNCTION ShellFiles( hWnd, acFiles, acTarget, wFunc, fFlag  )

   LOCAL cTemp
   LOCAL cx

   // Parent Window
   //
   IF Empty( hWnd )
      hWnd := GetActiveWindow()
   ENDIF

   // Operation Flag
   //
   IF wFunc == NIL
      wFunc := FO_DELETE
   ENDIF

   // Options Flag
   //
   IF fFlag == NIL
      fFlag := FOF_ALLOWUNDO
   ENDIF

   // SourceFiles, convert Array to String
   //
   DEFAULT acFiles TO Chr( 0 )
   IF ValType( acFiles ) == "A"
      cTemp :=  ""
      FOR cx := 1 TO Len( acFiles )
         cTemp += acFiles[ cx ] + Chr( 0 )
      NEXT
      acFiles := cTemp
   ENDIF
   acFiles += Chr( 0 )

   // TargetFiles, convert Array to String
   //
   DEFAULT acTarget TO Chr( 0 )
   IF ValType( acTarget ) == "A"
      cTemp := ""
      FOR cx := 1 TO Len( acTarget )
         cTemp += acTarget[ cx ] + Chr( 0 )
      NEXT
      acTarget := cTemp
   ENDIF
   acTarget += Chr( 0 )

   // call SHFileOperation
   //
RETURN ShellFileOperation( hWnd, acFiles, acTarget, wFunc, fFlag )


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( SHELLFILEOPERATION )
{
   SHFILEOPSTRUCT sh;

   sh.hwnd   = (HWND) hb_parnl(1);
   sh.pFrom  = hb_parc(2);
   sh.pTo    = hb_parc(3);
   sh.wFunc  = hb_parnl(4);
   sh.fFlags = hb_parnl(5);
   sh.hNameMappings = 0;
   sh.lpszProgressTitle = NULL;

   hb_retnl( SHFileOperation (&sh) );
}

#pragma ENDDUMP
