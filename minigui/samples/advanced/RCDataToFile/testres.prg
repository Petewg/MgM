/* 
 * testres.prg 
 */ 

#define IDR_HELLO 1001 
  
PROCEDURE main()
   LOCAL cFileOut := hb_dirTemp() + "\" + "he$$o.tmp"
   LOCAL nSize, hProcess, nRet

   DELETE FILE cFileOut

   nSize := RCDataToFile( IDR_HELLO, cFileOut )
   
   CLS

   IF nSize > 0

      hProcess := hb_processOpen( cFileOut ) ; nRet := hb_processValue( hProcess, .T. )
      QOut( nRet )

      WAIT

   ENDIF
   
   hb_FileDelete( cFileOut )
   
   RETURN


#pragma BEGINDUMP 
  
#include "hbapi.h" 
#include "windows.h" 
  
HB_FUNC( RCDATATOFILE ) 
{    
   HMODULE  hModule = GetModuleHandle( NULL );  
   HRSRC    hResInfo; 
   HGLOBAL  hResData; 
   LPVOID   lpData; 
   DWORD    dwSize, dwRet; 
   HANDLE   hFile; 
  
   hResInfo = FindResource( hModule, MAKEINTRESOURCE( hb_parnl(1) ), RT_RCDATA );  

   if ( NULL == hResInfo ) 
   { 
      hb_retnl( -1 );
      return;
   } 
  
   hResData = LoadResource( hModule, hResInfo );  

   if ( NULL == hResData ) 
   { 
      hb_retnl( -2 );
      return;
   } 
  
   lpData = LockResource( hResData );  

   if ( NULL == lpData ) 
   { 
      FreeResource ( hResData );
      hb_retnl( -3 );
      return;
   } 
  
   dwSize = SizeofResource( hModule, hResInfo );     

   hFile = CreateFile( hb_parc(2), GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, (DWORD) NULL, NULL );

   if ( INVALID_HANDLE_VALUE == hFile ) 
   { 
      FreeResource ( hResData );
      hb_retnl( -4 );
      return;
   } 
  
   WriteFile( hFile, lpData, dwSize, &dwRet, NULL );     

   FreeResource ( hResData );

   if ( dwRet != dwSize ) 
   { 
      dwRet = -5; 
   } 

   CloseHandle( hFile ); 
  
   hb_retnl( dwRet );
} 

#pragma ENDDUMP 
