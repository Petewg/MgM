/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2011 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

*--------------------------------------------------------*
Procedure Main
*--------------------------------------------------------*
  Local aVer := GetWinVersionInfo()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 550 HEIGHT 350 ;
		TITLE 'WinVersion Test' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		FONT 'Tahoma' SIZE 9

		DEFINE TREE Tree_1 ;
			AT 0,0 ;
			WIDTH Form_1.Width - GetBorderWidth() + 2 ;
			HEIGHT Form_1.Height - GetTitleHeight() - GetBorderHeight() + 2 ;
			VALUE 1 ;
			NODEIMAGES { 'cl_fl.bmp', 'op_fl.bmp' } ;
			ITEMIMAGES { 'op_fl.bmp' } ;
			NOROOTBUTTON

			NODE 'Operate System'
				TREEITEM "Name: " + GetWinVerString() IMAGES { 'mswin.bmp' }
				TREEITEM "Version: " + hb_ntos(aVer[1]) + "." + hb_ntos(aVer[2]) + "." + hb_ntos(aVer[3]) IMAGES { 'mswin.bmp' }
				TREEITEM "Service Pack Version: " + WinVersion()[2] IMAGES { 'mswin.bmp' }
				TREEITEM "Manufacturer: Microsoft Corporation" IMAGES { 'home.bmp' }

				TREEITEM "Visible Memory Size: " + hb_ntos(MemoryStatus(1)) + " MB (remaining " + hb_ntos(MemoryStatus(2)) + " MB)" IMAGES { 'memory.bmp' }
				TREEITEM "Virtual Memory Size: " + hb_ntos(MemoryStatus(5)) + " MB (remaining " + hb_ntos(MemoryStatus(6)) + " MB)" IMAGES { 'memory.bmp' }
				TREEITEM "Free Space In Paging File: " + hb_ntos(MemoryStatus(4)) + " MB" IMAGES { 'memory.bmp' }

				TREEITEM "System Drive: " + Left(System.WindowsFolder, 2)
				TREEITEM "Windows Directory: " + System.WindowsFolder
				TREEITEM "System Directory: " + System.SystemFolder
			END NODE

		END TREE

		ON KEY ESCAPE ACTION ThisWindow.Release()

	END WINDOW

	Form_1.Tree_1.Expand( 1 )

	Form_1.Center()

	Form_1.Activate()

Return


#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"
#include "hbapiitm.h"

//
// Product types
// This list grows with each OS release.
//
// There is no ordering of values to ensure callers
// do an equality test i.e. greater-than and less-than
// comparisons are not useful.
//
// NOTE: Values in this list should never be deleted.
//       When a product-type 'X' gets dropped from a
//       OS release onwards, the value of 'X' continues
//       to be used in the mapping table of GetProductInfo.
//

#define PRODUCT_UNDEFINED                           0x00000000

#define PRODUCT_ULTIMATE                            0x00000001
#define PRODUCT_HOME_BASIC                          0x00000002
#define PRODUCT_HOME_PREMIUM                        0x00000003
#define PRODUCT_ENTERPRISE                          0x00000004
#define PRODUCT_HOME_BASIC_N                        0x00000005
#define PRODUCT_BUSINESS                            0x00000006
#define PRODUCT_STANDARD_SERVER                     0x00000007
#define PRODUCT_DATACENTER_SERVER                   0x00000008
#define PRODUCT_SMALLBUSINESS_SERVER                0x00000009
#define PRODUCT_ENTERPRISE_SERVER                   0x0000000A
#define PRODUCT_STARTER                             0x0000000B
#define PRODUCT_DATACENTER_SERVER_CORE              0x0000000C
#define PRODUCT_STANDARD_SERVER_CORE                0x0000000D
#define PRODUCT_ENTERPRISE_SERVER_CORE              0x0000000E
#define PRODUCT_ENTERPRISE_SERVER_IA64              0x0000000F
#define PRODUCT_BUSINESS_N                          0x00000010
#define PRODUCT_WEB_SERVER                          0x00000011
#define PRODUCT_CLUSTER_SERVER                      0x00000012
#define PRODUCT_HOME_SERVER                         0x00000013
#define PRODUCT_STORAGE_EXPRESS_SERVER              0x00000014
#define PRODUCT_STORAGE_STANDARD_SERVER             0x00000015
#define PRODUCT_STORAGE_WORKGROUP_SERVER            0x00000016
#define PRODUCT_STORAGE_ENTERPRISE_SERVER           0x00000017
#define PRODUCT_SERVER_FOR_SMALLBUSINESS            0x00000018
#define PRODUCT_SMALLBUSINESS_SERVER_PREMIUM        0x00000019
#define PRODUCT_HOME_PREMIUM_N                      0x0000001A
#define PRODUCT_ENTERPRISE_N                        0x0000001B
#define PRODUCT_ULTIMATE_N                          0x0000001C
#define PRODUCT_WEB_SERVER_CORE                     0x0000001D
#define PRODUCT_MEDIUMBUSINESS_SERVER_MANAGEMENT    0x0000001E
#define PRODUCT_MEDIUMBUSINESS_SERVER_SECURITY      0x0000001F
#define PRODUCT_MEDIUMBUSINESS_SERVER_MESSAGING     0x00000020
#define PRODUCT_SMALLBUSINESS_SERVER_PRIME          0x00000021
#define PRODUCT_HOME_PREMIUM_SERVER                 0x00000022
#define PRODUCT_SERVER_FOR_SMALLBUSINESS_V          0x00000023
#define PRODUCT_STANDARD_SERVER_V                   0x00000024
#define PRODUCT_DATACENTER_SERVER_V                 0x00000025
#define PRODUCT_ENTERPRISE_SERVER_V                 0x00000026
#define PRODUCT_DATACENTER_SERVER_CORE_V            0x00000027
#define PRODUCT_STANDARD_SERVER_CORE_V              0x00000028
#define PRODUCT_ENTERPRISE_SERVER_CORE_V            0x00000029
#define PRODUCT_HYPERV                              0x0000002A

#define PRODUCT_UNLICENSED                          0xABCDABCD


#if _WIN32_WINNT >= 0x0501
  WINBASEAPI void WINAPI
  GetNativeSystemInfo(
     OUT LPSYSTEM_INFO lpSystemInfo
     );
#endif

#if defined( __BORLANDC__ )
  #define VER_SUITE_PERSONAL		0x00000200
  #define VER_SUITE_BLADE		0x00000400
  #define VER_SUITE_STORAGE_SERVER	0x00002000

  #define PROCESSOR_ARCHITECTURE_AMD64  9
#endif

#define STR_LEN   255
#define BUFSIZE   80

HB_FUNC( GETWINVERSTRING )
{
    OSVERSIONINFOEX osvi;
    SYSTEM_INFO si;
    BOOL bOsVersionInfoEx;

    BOOL bIsWow64 = FALSE;

    typedef BOOL ( WINAPI * P_ISWOW64PROCESS )( HANDLE, PBOOL );

    P_ISWOW64PROCESS pIsWow64Process;

    char szResult[ STR_LEN ];
    char szBuff[ 80 ];

    //szResult = ( char * ) hb_xgrab( STR_LEN + 2 );
    strcpy( szResult, "" );

    // Try calling GetVersionEx using the OSVERSIONINFOEX structure.
    // If that fails, try using the OSVERSIONINFO structure.

    ZeroMemory(&si, sizeof(SYSTEM_INFO));
    ZeroMemory(&osvi, sizeof(OSVERSIONINFOEX));
    osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);

    if( !(bOsVersionInfoEx = GetVersionEx ((OSVERSIONINFO *) &osvi)) )
    {
       osvi.dwOSVersionInfoSize = sizeof (OSVERSIONINFO);
       if (! GetVersionEx ( (OSVERSIONINFO *) &osvi) )
          hb_retc( "version unknown" );
          return;
    }

    switch (osvi.dwPlatformId)
    {
       // Test for the Windows NT product family.

       case VER_PLATFORM_WIN32_NT:

       // Test for the specific product.

       if ( osvi.dwMajorVersion == 6 )
       {
          typedef BOOL (WINAPI *PGPI)(DWORD, DWORD, DWORD, DWORD, PDWORD);

          PGPI pGPI;
          DWORD dwType;

          if ( osvi.dwMinorVersion == 0 )
          {
             if( osvi.wProductType == VER_NT_WORKSTATION )
             {
                strcat( szResult, "Microsoft Windows Vista " );
             }
             else
             {
                strcat( szResult, "Windows Server 2008 " );
             }
          }
          else if ( osvi.dwMinorVersion == 1 )
          {
             if( osvi.wProductType == VER_NT_WORKSTATION )
             {
                strcat( szResult, "Microsoft Windows 7 " );
             }
             else
             {
                strcat( szResult, "Windows Server 2008 R2 " );
             }
          }

          pGPI = (PGPI) GetProcAddress(
             GetModuleHandle(TEXT("kernel32.dll")),
             "GetProductInfo");

          pGPI( 6, 0, 0, 0, &dwType);

          switch( dwType )
          {
             case PRODUCT_ULTIMATE:
                strcat( szResult, "Ultimate Edition" );
                break;
             case PRODUCT_HOME_PREMIUM:
                strcat( szResult, "Home Premium Edition" );
                break;
             case PRODUCT_HOME_BASIC:
                strcat( szResult, "Home Basic Edition" );
                break;
             case PRODUCT_ENTERPRISE:
                strcat( szResult, "Enterprise Edition" );
                break;
             case PRODUCT_BUSINESS:
                strcat( szResult, "Business Edition" );
                break;
             case PRODUCT_STARTER:
                strcat( szResult, "Starter Edition" );
                break;
             case PRODUCT_CLUSTER_SERVER:
                strcat( szResult, "Cluster Server Edition" );
                break;
             case PRODUCT_DATACENTER_SERVER:
                strcat( szResult, "Datacenter Edition" );
                break;
             case PRODUCT_DATACENTER_SERVER_CORE:
                strcat( szResult, "Datacenter Edition (core installation)" );
                break;
             case PRODUCT_ENTERPRISE_SERVER:
                strcat( szResult, "Enterprise Edition" );
                break;
             case PRODUCT_ENTERPRISE_SERVER_CORE:
                strcat( szResult, "Enterprise Edition (core installation)" );
                break;
             case PRODUCT_ENTERPRISE_SERVER_IA64:
                strcat( szResult, "Enterprise Edition for Itanium-based Systems" );
                break;
             case PRODUCT_SMALLBUSINESS_SERVER:
                strcat( szResult, "Small Business Server" );
                break;
             case PRODUCT_SMALLBUSINESS_SERVER_PREMIUM:
                strcat( szResult, "Small Business Server Premium Edition" );
                break;
             case PRODUCT_STANDARD_SERVER:
                strcat( szResult, "Standard Edition" );
                break;
             case PRODUCT_STANDARD_SERVER_CORE:
                strcat( szResult, "Standard Edition (core installation)" );
                break;
             case PRODUCT_WEB_SERVER:
                strcat( szResult, "Web Server Edition" );
                break;
          }


          pIsWow64Process = ( P_ISWOW64PROCESS ) GetProcAddress( GetModuleHandle( TEXT( "kernel32" ) ), "IsWow64Process" );

          if( pIsWow64Process )
          {
             if( ! pIsWow64Process( GetCurrentProcess(), &bIsWow64 ) )
             {
               /* Try alternative method? */
             }
          }

          if( bIsWow64 )
             strcat( szResult, ", 64-bit " );
          else if (si.wProcessorArchitecture==PROCESSOR_ARCHITECTURE_INTEL )
             strcat( szResult, ", 32-bit ");

       }

       if ( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2 )
       {
          typedef VOID (WINAPI *LPFN_GETNATIVESYSTEMINFO) (SYSTEM_INFO *);

          LPFN_GETNATIVESYSTEMINFO fnGetNativeSystemInfo =
          (LPFN_GETNATIVESYSTEMINFO) GetProcAddress( GetModuleHandle("kernel32"), "GetNativeSystemInfo");

          if (NULL != fnGetNativeSystemInfo)
          {
             (fnGetNativeSystemInfo) (&si);
          }

          #ifndef SM_SERVERR2
             #define SM_SERVERR2 89
          #endif
          if( GetSystemMetrics(SM_SERVERR2) )
             strcat( szResult, "Microsoft Windows Server 2003 \"R2\" " );
          else if ( osvi.wSuiteMask==VER_SUITE_STORAGE_SERVER )
             strcat( szResult, "Windows Storage Server 2003");
          else if( si.wProcessorArchitecture==PROCESSOR_ARCHITECTURE_IA64 &&
                   osvi.wProductType == VER_NT_WORKSTATION )
          {
             strcat( szResult, "Microsoft Windows XP Professional x64 Edition " );
          }
          else strcat( szResult, "Microsoft Windows Server 2003, " );
       }

       if ( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 1 )
          strcat( szResult, "Microsoft Windows XP " );

       if ( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0 )
          strcat( szResult, "Microsoft Windows 2000 " );

       if ( osvi.dwMajorVersion <= 4 )
          strcat( szResult, "Microsoft Windows NT " );

       // Test for specific product on Windows NT 4.0 SP6 and later.
       if( bOsVersionInfoEx )
       {
          // Test for the workstation type.
          if ( osvi.wProductType == VER_NT_WORKSTATION && osvi.dwMajorVersion < 6 )
          {
             if( osvi.dwMajorVersion == 4 )
                strcat( szResult, "Workstation 4.0 " );
             else if( osvi.wSuiteMask & VER_SUITE_PERSONAL )
                strcat( szResult, "Home Edition " );
             else strcat( szResult, "Professional " );
          }

          // Test for the server type.
          else if ( osvi.wProductType == VER_NT_SERVER ||
                    osvi.wProductType == VER_NT_DOMAIN_CONTROLLER )
          {
             if(osvi.dwMajorVersion==5 && osvi.dwMinorVersion==2)
             {
                if ( si.wProcessorArchitecture==PROCESSOR_ARCHITECTURE_IA64 )
                {
                    if( osvi.wSuiteMask & VER_SUITE_DATACENTER )
                       strcat( szResult, "Datacenter Edition for Itanium-based Systems" );
                    else if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                       strcat( szResult, "Enterprise Edition for Itanium-based Systems" );
                }

                else if ( si.wProcessorArchitecture==PROCESSOR_ARCHITECTURE_AMD64 )
                {
                    if( osvi.wSuiteMask & VER_SUITE_DATACENTER )
                       strcat( szResult, "Datacenter x64 Edition " );
                    else if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                       strcat( szResult, "Enterprise x64 Edition " );
                    else strcat( szResult, "Standard x64 Edition " );
                }

                else
                {
                    if( osvi.wSuiteMask & VER_SUITE_DATACENTER )
                       strcat( szResult, "Datacenter Edition " );
                    else if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                       strcat( szResult, "Enterprise Edition " );
                    else if ( osvi.wSuiteMask == VER_SUITE_BLADE )
                       strcat( szResult, "Web Edition " );
                    else strcat( szResult, "Standard Edition " );
                }
             }
             else if(osvi.dwMajorVersion==5 && osvi.dwMinorVersion==0)
             {
                if( osvi.wSuiteMask & VER_SUITE_DATACENTER )
                   strcat( szResult, "Datacenter Server " );
                else if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                   strcat( szResult, "Advanced Server " );
                else strcat( szResult, "Server " );
             }
             else  // Windows NT 4.0
             {
                if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                   strcat( szResult, "Server 4.0, Enterprise Edition " );
                else strcat( szResult, "Server 4.0 " );
             }
          }
       }
       // Test for specific product on Windows NT 4.0 SP5 and earlier
       else
       {
          HKEY hKey;
          char szProductType[BUFSIZE];
          DWORD dwBufLen=BUFSIZE;
          LONG lRet;

          lRet = RegOpenKeyEx( HKEY_LOCAL_MACHINE,
             "SYSTEM\\CurrentControlSet\\Control\\ProductOptions",
             0, KEY_QUERY_VALUE, &hKey );
          if( lRet != ERROR_SUCCESS )
          {
             hb_retc( "version unknown" );
             return;
          }

          lRet = RegQueryValueEx( hKey, "ProductType", NULL, NULL,
             (LPBYTE) szProductType, &dwBufLen);
          RegCloseKey( hKey );

          if( (lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) )
          {
             hb_retc( "version unknown" );
             return;
          }

          if ( lstrcmpi( "WINNT", szProductType) == 0 )
             strcat( szResult, "Workstation " );
          if ( lstrcmpi( "LANMANNT", szProductType) == 0 )
             strcat( szResult, "Server " );
          if ( lstrcmpi( "SERVERNT", szProductType) == 0 )
             strcat( szResult, "Advanced Server " );
          sprintf( szBuff, "%d.%d ", osvi.dwMajorVersion, osvi.dwMinorVersion );
          strcat( szResult, szBuff );
       }

       // Display service pack (if any) and build number.

       if( osvi.dwMajorVersion == 4 &&
           lstrcmpi( osvi.szCSDVersion, "Service Pack 6" ) == 0 )
       {
          HKEY hKey;
          LONG lRet;

          // Test for SP6 versus SP6a.
          lRet = RegOpenKeyEx( HKEY_LOCAL_MACHINE,
             "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Hotfix\\Q246009",
             0, KEY_QUERY_VALUE, &hKey );
          if( lRet == ERROR_SUCCESS )
          {
             sprintf( szBuff, "Service Pack 6a (Build %d)", osvi.dwBuildNumber & 0xFFFF );
             strcat( szResult, szBuff );
          }
          else // Windows NT 4.0 prior to SP6a
          {
             sprintf( szBuff, "%s (Build %d)",
                osvi.szCSDVersion,
                osvi.dwBuildNumber & 0xFFFF);
             strcat( szResult, szBuff );
          }

          RegCloseKey( hKey );
       }
       else // not Windows NT 4.0
       {
          sprintf( szBuff, "%s (Build %d)",
             osvi.szCSDVersion,
             osvi.dwBuildNumber & 0xFFFF);
          strcat( szResult, szBuff );
       }

       break;

       // Test for the Windows Me/98/95.
       case VER_PLATFORM_WIN32_WINDOWS:

       if (osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 0)
       {
           strcat( szResult, "Microsoft Windows 95 ");
           if (osvi.szCSDVersion[1]=='C' || osvi.szCSDVersion[1]=='B')
              strcat( szResult, "OSR2 " );
       }

       if (osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 10)
       {
           strcat( szResult, "Microsoft Windows 98 ");
           if ( osvi.szCSDVersion[1]=='A' || osvi.szCSDVersion[1]=='B')
              strcat( szResult, "SE " );
       }

       if (osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 90)
       {
           strcat( szResult, "Microsoft Windows Millennium Edition");
       }
       break;

       case VER_PLATFORM_WIN32s:

       strcat( szResult, "Microsoft Win32s\n");
       break;
    }

    hb_retc( szResult );
}

HB_FUNC( GETWINVERSIONINFO )
{
  OSVERSIONINFO osvi;
  PHB_ITEM pArray = hb_itemArrayNew( 3 );

  osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
  GetVersionEx ( &osvi );

  hb_itemPutNL( hb_arrayGetItemPtr( pArray, 1 ), osvi.dwMajorVersion );
  hb_itemPutNL( hb_arrayGetItemPtr( pArray, 2 ), osvi.dwMinorVersion );
  if ( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS )
  {
    osvi.dwBuildNumber = LOWORD( osvi.dwBuildNumber );
  }
  hb_itemPutNL( hb_arrayGetItemPtr( pArray, 3 ), osvi.dwBuildNumber  );
  hb_itemRelease( hb_itemReturn( pArray) );
}

#pragma ENDDUMP
