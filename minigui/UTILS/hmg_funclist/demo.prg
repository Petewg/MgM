/*
 * HMG - Harbour Win32 GUI library Demo
 *
 * Copyright 2015 Dr. Claudio Soto <srvet@adinet.com.uy>
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
*/

#include "hmg.ch"

PROCEDURE Main
   LOCAL aRows1 := HMG_GetHBFunctions()
   LOCAL aRows2 := {}
   LOCAL aData := HMG_GetDLLFunctions( "user32.dll" )

   Aeval( aData, { |x, i| AAdd( aRows2, { Str( i ), x } ) } )

   SET FONT TO "Tahoma", 12

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 660 ;
      TITLE "Harbour Registered And WinAPI Available Functions" ;
      MAIN ;
      NOMAXIMIZE NOSIZE

      ON KEY ESCAPE ACTION ThisWindow.Release      

      @ 10,10 GRID Grid_1 ;
         WIDTH 614 ;
         HEIGHT 300 ;
         HEADERS {'Index','Function Name'} ;
         WIDTHS {120, 250} ;
         ITEMS aRows1

      @ 320,10 GRID Grid_2 ;
         WIDTH 614 ;
         HEIGHT 300 ;
         HEADERS {'Index','Function Name'} ;
         WIDTHS {120, 250} ;
         ITEMS aRows2

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN


FUNCTION HMG_GetHBFunctions()
   LOCAL nSymbols, nFunctions, n, aSym := {}

   nSymbols := __dynsCount()
   nFunctions := 0
   FOR n := nSymbols TO 1 STEP -1
      IF __dynsIsFun( n )
         nFunctions++
         AAdd( aSym, { Str( nFunctions ), __dynsGetName( n ) } )
      ENDIF
   NEXT

RETURN aSym


#pragma BEGINDUMP

#include <windows.h>
#include <imagehlp.h>
#include "hbapi.h"

/*****************************************************************************************
*   MACRO DEFINITION FOR CALL DLL FUNCTION
******************************************************************************************/

#define HMG_DEFINE_DLL_FUNC(\
                             _FUNC_NAME,             \
                             _DLL_LIBNAME,           \
                             _DLL_FUNC_RET,          \
                             _DLL_FUNC_TYPE,         \
                             _DLL_FUNC_NAMESTRINGAW, \
                             _DLL_FUNC_PARAM,        \
                             _DLL_FUNC_CALLPARAM,    \
                             _DLL_FUNC_RETFAILCALL   \
                            )\
\
_DLL_FUNC_RET _DLL_FUNC_TYPE _FUNC_NAME _DLL_FUNC_PARAM \
{\
   typedef _DLL_FUNC_RET (_DLL_FUNC_TYPE *PFUNC) _DLL_FUNC_PARAM;\
   static PFUNC pfunc = NULL;\
   if( pfunc == NULL )\
   {\
      HMODULE hLib = LoadLibrary( _DLL_LIBNAME );\
      pfunc = (PFUNC) GetProcAddress( hLib, _DLL_FUNC_NAMESTRINGAW );\
   }\
   if( pfunc == NULL )\
      return( (_DLL_FUNC_RET) _DLL_FUNC_RETFAILCALL );\
   else\
      return pfunc _DLL_FUNC_CALLPARAM;\
}


HMG_DEFINE_DLL_FUNC ( win_MapAndLoad,                              // user function name
                      "Imagehlp.dll",                              // dll name
                      BOOL,                                        // function return type
                      WINAPI,                                      // function type
                      "MapAndLoad",                                // dll function name
                      (PSTR ImageName, PSTR DllPath, PLOADED_IMAGE LoadedImage, BOOL DotDll, BOOL ReadOnly),   // dll function parameters (types and names)
                      (ImageName, DllPath, LoadedImage, DotDll, ReadOnly),   // function parameters (only names)
                      FALSE                                        // return value if fail call function of dll
                    )

HMG_DEFINE_DLL_FUNC ( win_UnMapAndLoad,                            // user function name
                      "Imagehlp.dll",                              // dll name
                      BOOL,                                        // function return type
                      WINAPI,                                      // function type
                      "UnMapAndLoad",                              // dll function name
                      (PLOADED_IMAGE LoadedImage),                 // dll function parameters (types and names)
                      (LoadedImage),                               // function parameters (only names)
                      FALSE                                        // return value if fail call function of dll
                    )

HMG_DEFINE_DLL_FUNC ( win_ImageDirectoryEntryToData,               // user function name
                      "Dbghelp.dll",                               // dll name
                      PVOID,                                       // function return type
                      WINAPI,                                      // function type
                      "ImageDirectoryEntryToData",                 // dll function name
                      (PVOID Base, BOOLEAN MappedAsImage, USHORT DirectoryEntry, PULONG Size),   // dll function parameters (types and names)
                      (Base, MappedAsImage, DirectoryEntry, Size), // function parameters (only names)
                      NULL                                         // return value if fail call function of dll
                    )

HMG_DEFINE_DLL_FUNC ( win_ImageRvaToVa,                            // user function name
                      "Dbghelp.dll",                               // dll name
                      PVOID,                                       // function return type
                      WINAPI,                                      // function type
                      "ImageRvaToVa",                              // dll function name
                      (PIMAGE_NT_HEADERS NtHeaders,PVOID Base,ULONG Rva,PIMAGE_SECTION_HEADER *LastRvaSection),   // dll function parameters (types and names)
                      (NtHeaders, Base, Rva, LastRvaSection),      // function parameters (only names)
                      NULL                                         // return value if fail call function of dll
                    )


HB_FUNC ( HMG_GETDLLFUNCTIONS )
{
    CHAR *cDllName = ( CHAR * ) hb_parc( 1 );
    CHAR *cName;
    DWORD *dNameRVAs;
    LOADED_IMAGE LI;
    IMAGE_EXPORT_DIRECTORY *IED;
    ULONG DirSize;
    UINT i;

    if ( win_MapAndLoad( cDllName, NULL, &LI, TRUE, TRUE ) )
    {
        IED = ( IMAGE_EXPORT_DIRECTORY * ) win_ImageDirectoryEntryToData( LI.MappedAddress, FALSE, IMAGE_DIRECTORY_ENTRY_EXPORT, &DirSize );
        if (IED != NULL)
        {
            dNameRVAs = ( DWORD * ) win_ImageRvaToVa( LI.FileHeader, LI.MappedAddress, IED->AddressOfNames, NULL );
            hb_reta( IED->NumberOfNames );
            for( i = 0; i < IED->NumberOfNames; i++ )
            {
                cName = ( CHAR * ) win_ImageRvaToVa( LI.FileHeader, LI.MappedAddress, dNameRVAs[i], NULL );
                hb_storvc( cName, -1, i + 1 );
            }
        }
        win_UnMapAndLoad( &LI );
    }
}

#pragma ENDDUMP
