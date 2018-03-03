/*
 * MINIGUI - Harbour Win32 GUI library source code
 *
 * Copyright 2016 P.Chornyj <myorg63@mail.ru>
 */

#include "hbapi.h"

#if ! ( defined( __XHARBOUR__ ) )

#undef _WIN32_WINNT
#define _WIN32_WINNT       0x0600

#undef NTDDI_VERSION
#define NTDDI_VERSION      0x06000000

#define UNICODE

#if defined( __MINGW32__ )
# define MAKEINTRESOURCEA( i )  ( ( LPSTR ) ( ( ULONG_PTR ) ( ( WORD ) ( i ) ) ) )
# define MAKEINTRESOURCEW( i )  ( ( LPWSTR ) ( ( ULONG_PTR ) ( ( WORD ) ( i ) ) ) )
# ifdef UNICODE
#  define MAKEINTRESOURCE  MAKEINTRESOURCEW
# else
#  define MAKEINTRESOURCE  MAKEINTRESOURCEA
# endif /* UNICODE */
#endif  /* __MINGW32__ */

#include <hbwinuni.h>

#include <mgdefs.h>
#include <commctrl.h>

#include "hbapicls.h"
#include "hbapierr.h"
#include "hbapiitm.h"
#include "hbvm.h"

#include "TaskDlgs.h"

#if ( ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 ) )

HRESULT TaskDialog( HWND hwndParent, HINSTANCE hInstance, PCWSTR pszWindowTitle, PCWSTR pszMainInstruction, PCWSTR pszContent, TASKDIALOG_COMMON_BUTTON_FLAGS dwCommonButtons, PCWSTR pszIcon, int * pnButton )
{
   HMODULE hCommCtl = LoadLibraryEx( TEXT( "comctl32.dll" ), NULL, 0 );

   if( hCommCtl )
   {
      fnTaskDialog pfn     = ( fnTaskDialog ) GetProcAddress( hCommCtl, "TaskDialog" );
      HRESULT      hResult = NULL;

      if( NULL != pfn )
      {
         hResult = pfn( hwndParent, hInstance, pszWindowTitle, pszMainInstruction, pszContent, dwCommonButtons, pszIcon, pnButton );
         /* HB_TRACE( HB_TR_DEBUG, ( "TaskDialog() returns %08lX", hResult ) ); */
      }
      FreeLibrary( hCommCtl );
      return hResult;
   }
   return -1;
}

HRESULT TaskDialogIndirect( const TASKDIALOGCONFIG * pTaskConfig, int * pnButton, int * pnRadioButton, BOOL * pfVerificationFlagChecked )
{
   HMODULE hCommCtl = LoadLibraryEx( TEXT( "comctl32.dll" ), NULL, 0 );

   if( hCommCtl )
   {
      fnTaskDialogIndirect pfn = ( fnTaskDialogIndirect ) GetProcAddress( hCommCtl, "TaskDialogIndirect" );
      HRESULT hResult = NULL;

      if( NULL != pfn )
      {
         hResult = pfn( pTaskConfig, pnButton, pnRadioButton, pfVerificationFlagChecked );
      }
      FreeLibrary( hCommCtl );
      return hResult;
   }
   return -1;
}
#endif /* defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 */

HB_FUNC( WIN_TASKDIALOG0 )
{
   HWND      hWndParent = NULL;
   HINSTANCE hInstance  = NULL;
   PCWSTR    pszWindowTitle;
   PCWSTR    pszMainInstruction;
   PCWSTR    pszContent;
   TASKDIALOG_COMMON_BUTTON_FLAGS dwCommonButtons = 0;
   PCWSTR pszIcon = NULL;
   int    nButton;

   HRESULT hResult;

   /*TODO*/
   void ** hText = ( void ** ) hb_xgrab( sizeof( void * ) * 3 );
   int     iText = 0;

   if( HB_ISCHAR( 3 ) )
   {
      pszWindowTitle = HB_PARSTRDEF( 3, &hText[ iText++ ], NULL );
   }
   else if( HB_ISNUM( 3 ) )
   {
      pszWindowTitle = MAKEINTRESOURCE( hb_parni( 3 ) );
   }
   else
   {
      pszWindowTitle = NULL;
   }

   if( HB_ISCHAR( 4 ) )
   {
      pszMainInstruction = HB_PARSTRDEF( 4, &hText[ iText++ ], NULL );
   }
   else if( HB_ISNUM( 4 ) )
   {
      pszMainInstruction = MAKEINTRESOURCE( hb_parni( 4 ) );
   }
   else
   {
      pszMainInstruction = NULL;
   }

   if( HB_ISCHAR( 5 ) )
   {
      pszContent = HB_PARSTRDEF( 5, &hText[ iText++ ], NULL );
   }
   else if( HB_ISNUM( 5 ) )
   {
      pszContent = MAKEINTRESOURCE( hb_parni( 5 ) );
   }
   else
   {
      pszContent = NULL;
   }

   if( HB_ISNUM( 6 ) )
   {
      dwCommonButtons = ( DWORD ) hb_parnl( 6 );
   }

   if( HB_ISNUM( 7 ) )
   {
      pszIcon = MAKEINTRESOURCE( hb_parni( 7 ) );
   }

   hResult = TaskDialog( hWndParent, hInstance, pszWindowTitle, pszMainInstruction, pszContent, dwCommonButtons, pszIcon, &nButton );
   /* HB_TRACE( HB_TR_DEBUG, ( "win_TaskDialog0() returns %08lX", hResult ) ); */

   if( S_OK == hResult )
   {
      if( nButton )
      {
         hb_storni( nButton, 8 );
      }
      else
      {
         hb_stor( 8 );
      }
   }
   else
   {
      hb_stor( 8 );
   }

   hb_retnint( hResult );

   while( --iText >= 0 )
      hb_strfree( hText[ iText ] );

   hb_xfree( hText );
}

HB_FUNC( WIN_TASKDIALOGINDIRECT0 )
{
   PHB_ITEM pConfig = hb_param( 1, HB_IT_ARRAY );

   if( pConfig && hb_arrayLen( pConfig ) >= TDC_CONFIG )
   {
      TASKDIALOGCONFIG config = { 0 };
      int     nButton;
      int     nRadioButton;
      BOOL    fVerificationFlagChecked;
      HRESULT hResult;

      HB_TYPE iType;

      void ** hText = ( void ** ) hb_xgrab( sizeof( void * ) * 10 );
      int     iText = 0;

      TASKDIALOG_BUTTON * buttons;
      void ** hButton = NULL;
      int     iButton = 0;

      TASKDIALOG_BUTTON * radiobuttons;
      void ** hRadioButton = NULL;
      int     iRadioButton = 0;

      PHB_ITEM pCallbackData = NULL;

      // 1 UINT cbSize
      config.cbSize = sizeof( config );

      /*TODO ( HWND )( HB_PTRUINT ) hb_parnint/hb_arrayGetNInt () */
      // 2 HWND hwndParent
      if( hb_arrayGetType( pConfig, TDC_HWND ) & HB_IT_NUMERIC )
      {
         config.hwndParent = ( HWND ) HB_arrayGetNL( pConfig, TDC_HWND );
      }
      else
      {
         config.hwndParent = NULL;
      }

      /*TODO*/
      // 3 HINSTANCE hInstance
      if( hb_arrayGetType( pConfig, TDC_HINSTANCE ) & HB_IT_NUMERIC )
      {
         config.hInstance = ( HINSTANCE ) HB_arrayGetNL( pConfig, TDC_HINSTANCE );
      }
      else
      {
         config.hInstance = NULL;
      }

      // 4 TASKDIALOG_FLAGS dwFlags
      if( hb_arrayGetType( pConfig, TDC_TASKDIALOG_FLAGS ) & HB_IT_NUMERIC )
      {
         config.dwFlags |= ( DWORD ) hb_arrayGetNL( pConfig, TDC_TASKDIALOG_FLAGS );
      }

      // 5 TASKDIALOG_COMMON_BUTTON_FLAGS dwCommonButtons
      if( hb_arrayGetType( pConfig, TDC_COMMON_BUTTON_FLAGS ) & HB_IT_NUMERIC )
      {
         config.dwCommonButtons = ( DWORD ) hb_arrayGetNL( pConfig, TDC_COMMON_BUTTON_FLAGS );
      }

      // 6 PCWSTR pszWindowTitle
      iType = hb_arrayGetType( pConfig, TDC_WINDOWTITLE );
      if( iType & HB_IT_STRING )
      {
         config.pszWindowTitle = HB_PARASTRDEF( 1, TDC_WINDOWTITLE, &hText[ iText++ ], NULL );
      }
      else if( iType & HB_IT_NUMERIC )
      {
         config.pszWindowTitle = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_WINDOWTITLE ) );
      }
      else
      {
         config.pszWindowTitle = NULL;
      }

      /*TODO*/
      // 7 union { HICON  hMainIcon; PCWSTR pszMainIcon; };
      iType = hb_arrayGetType( pConfig, TDC_MAINICON );
      if( iType & HB_IT_NUMERIC )
      {
         #if ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 )
         config.DUMMYUNIONNAME.pszMainIcon = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_MAINICON ) );
         #else
         config.pszMainIcon = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_MAINICON ) );
         #endif
      }
      else if( iType & HB_IT_POINTER )
      {
         #if ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 )
         config.DUMMYUNIONNAME.hMainIcon = ( HICON ) ( hb_arrayGetPtr( pConfig, TDC_MAINICON ) );
         #else
         config.hMainIcon = ( HICON ) ( hb_arrayGetPtr( pConfig, TDC_MAINICON ) );
         #endif
      }
      else
      {
         #if ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 )
         config.DUMMYUNIONNAME.hMainIcon   = NULL;
         config.DUMMYUNIONNAME.pszMainIcon = NULL;
         #else
         config.hMainIcon   = NULL;
         config.pszMainIcon = NULL;
         #endif
      }

      // 8 PCWSTR pszMainInstruction
      iType = hb_arrayGetType( pConfig, TDC_MAININSTRUCTION );
      if( iType & HB_IT_STRING )
      {
         config.pszMainInstruction = HB_PARASTRDEF( 1, TDC_MAININSTRUCTION, &hText[ iText++ ], NULL );
      }
      else if( iType & HB_IT_NUMERIC )
      {
         config.pszMainInstruction = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_MAININSTRUCTION ) );
      }

      // 9 PCWSTR pszContent;
      iType = hb_arrayGetType( pConfig, TDC_CONTENT );
      if( iType & HB_IT_STRING )
      {
         config.pszContent = HB_PARASTRDEF( 1, TDC_CONTENT, &hText[ iText++ ], NULL );
      }
      else if( iType & HB_IT_NUMERIC )
      {
         config.pszContent = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_CONTENT ) );
      }

      // 10 UINT cButtons
      config.cButtons = ( hb_arrayGetType( pConfig, TDC_BUTTON ) & HB_IT_NUMERIC ) ? hb_arrayGetNI( pConfig, TDC_BUTTON ) : 0;

      // 11 const TASKDIALOG_BUTTON *pButtons
      if( hb_arrayGetType( pConfig, TDC_TASKDIALOG_BUTTON ) & HB_IT_ARRAY )
      {
         PHB_ITEM pButtons = hb_arrayGetItemPtr( pConfig, TDC_TASKDIALOG_BUTTON );
         HB_SIZE  arrsize  = hb_arrayLen( pButtons );

         if( ( arrsize > 0 ) && TD_CheckButton( pButtons, arrsize ) )
         {
            HB_SIZE i;

            buttons = ( TASKDIALOG_BUTTON * ) hb_xgrabz( sizeof( TASKDIALOG_BUTTON ) * arrsize );
            hButton = ( void ** ) hb_xgrab( sizeof( void * ) * ( arrsize ) );

            for( i = 0; i < arrsize; ++i )
            {
               PHB_ITEM button = hb_arrayGetItemPtr( pButtons, i + 1 );

               buttons[ i ].nButtonID = hb_arrayGetNI( button, 1 );
               if( ( hb_arrayGetType( button, 2 ) & HB_IT_STRING ) != 0 )
               {
                  buttons[ i ].pszButtonText = HB_ARRAYGETSTR( button, 2, &hButton[ iButton++ ], NULL );
               }
               else
               {
                  buttons[ i ].pszButtonText = MAKEINTRESOURCE( hb_arrayGetNI( button, 2 ) );
               }
            }
            config.cButtons = HB_MIN( config.cButtons, arrsize );
            config.pButtons = buttons;
         }
      }

      // 12 int nDefaultButton
      config.nDefaultButton = ( hb_arrayGetType( pConfig, TDC_DEFAULTBUTTON ) & HB_IT_NUMERIC ) ?
                              hb_arrayGetNI( pConfig, TDC_DEFAULTBUTTON ) : 0;

      // 13 UINT cRadioButtons
      config.cRadioButtons = ( hb_arrayGetType( pConfig, TDC_RADIOBUTTON ) & HB_IT_NUMERIC ) ?
                             hb_arrayGetNI( pConfig, TDC_RADIOBUTTON ) : 0;

      // 14 const TASKDIALOG_BUTTON *pRadioButtons
      if( hb_arrayGetType( pConfig, TDC_TASKDIALOG_RADIOBUTTON ) & HB_IT_ARRAY )
      {
         PHB_ITEM pButtons = hb_arrayGetItemPtr( pConfig, TDC_TASKDIALOG_RADIOBUTTON );
         HB_SIZE  arrsize  = hb_arrayLen( pButtons );

         if( ( arrsize > 0 ) && TD_CheckButton( pButtons, arrsize ) )
         {
            HB_SIZE i;

            radiobuttons = ( TASKDIALOG_BUTTON * ) hb_xgrabz( sizeof( TASKDIALOG_BUTTON ) * arrsize );
            hRadioButton = ( void ** ) hb_xgrab( sizeof( void * ) * ( arrsize ) );

            for( i = 0; i < arrsize; ++i )
            {
               PHB_ITEM button = hb_arrayGetItemPtr( pButtons, i + 1 );

               radiobuttons[ i ].nButtonID = hb_arrayGetNI( button, 1 );
               if( ( hb_arrayGetType( button, 2 ) & HB_IT_STRING ) != 0 )
               {
                  radiobuttons[ i ].pszButtonText = HB_ARRAYGETSTR( button, 2, &hRadioButton[ iRadioButton++ ], NULL );
               }
               else
               {
                  radiobuttons[ i ].pszButtonText = MAKEINTRESOURCE( hb_arrayGetNI( button, 2 ) );
               }
            }
            config.cRadioButtons = HB_MIN( config.cRadioButtons, arrsize );
            config.pRadioButtons = radiobuttons;
         }
      }

      // 15 int nDefaultRadioButton
      config.nDefaultRadioButton = ( hb_arrayGetType( pConfig, TDC_DEFAULTRADIOBUTTON ) & HB_IT_NUMERIC ) ?
                                   hb_arrayGetNI( pConfig, TDC_DEFAULTRADIOBUTTON ) : 0;

      // 16 PCWSTR pszVerificationText
      iType = hb_arrayGetType( pConfig, TDC_VERIFICATIONTEXT );
      if( iType & HB_IT_STRING )
      {
         config.pszVerificationText = HB_PARASTRDEF( 1, TDC_VERIFICATIONTEXT, &hText[ iText++ ], NULL );
      }
      else if( iType & HB_IT_NUMERIC )
      {
         config.pszVerificationText = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_VERIFICATIONTEXT ) );
      }
      else
      {
         config.pszVerificationText = NULL;
      }

      // 17 PCWSTR pszExpandedInformation
      iType = hb_arrayGetType( pConfig, TDC_EXPANDEDINFORMATION );
      if( iType & HB_IT_STRING )
      {
         config.pszExpandedInformation = HB_PARASTRDEF( 1, TDC_EXPANDEDINFORMATION, &hText[ iText++ ], NULL );
      }
      else if( iType & HB_IT_NUMERIC )
      {
         config.pszExpandedInformation = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_EXPANDEDINFORMATION ) );
      }

      // 18 PCWSTR pszExpandedControlText
      iType = hb_arrayGetType( pConfig, TDC_EXPANDEDCONTROLTEXT );
      if( iType & HB_IT_STRING )
      {
         config.pszExpandedControlText = HB_PARASTRDEF( 1, TDC_EXPANDEDCONTROLTEXT, &hText[ iText++ ], NULL );
      }
      else if( iType & HB_IT_NUMERIC )
      {
         config.pszExpandedControlText = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_EXPANDEDCONTROLTEXT ) );
      }

      // 19 PCWSTR pszCollapsedControlText
      iType = hb_arrayGetType( pConfig, TDC_COLLAPSEDCONTROLTEXT );
      if( iType & HB_IT_STRING )
      {
         config.pszCollapsedControlText = HB_PARASTRDEF( 1, TDC_COLLAPSEDCONTROLTEXT, &hText[ iText++ ], NULL );
      }
      else if( iType & HB_IT_NUMERIC )
      {
         config.pszCollapsedControlText = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_COLLAPSEDCONTROLTEXT ) );
      }

      /*TODO*/
      // 20 union { HICON  hFooterIcon; PCWSTR pszFooterIcon; }
      iType = hb_arrayGetType( pConfig, TDC_FOOTERICON );
      if( iType & HB_IT_NUMERIC )
      {
        #if ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 )
         config.DUMMYUNIONNAME2.pszFooterIcon = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_FOOTERICON ) );
        #else
         config.pszFooterIcon = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_FOOTERICON ) );
        #endif
      }
      else if( iType & HB_IT_POINTER )
      {
         #if ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 )
         config.DUMMYUNIONNAME2.hFooterIcon = ( HICON ) ( hb_arrayGetPtr( pConfig, TDC_FOOTERICON ) );
         #else
         config.hFooterIcon = ( HICON ) ( hb_arrayGetPtr( pConfig, TDC_FOOTERICON ) );
         #endif
      }
      else
      {
        #if ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 )
         config.DUMMYUNIONNAME2.hFooterIcon   = NULL;
         config.DUMMYUNIONNAME2.pszFooterIcon = NULL;
        #else
         config.hFooterIcon   = NULL;
         config.pszFooterIcon = NULL;
        #endif
      }

      // 21 PCWSTR pszFooter;
      iType = hb_arrayGetType( pConfig, TDC_FOOTER );
      if( iType & HB_IT_STRING )
         config.pszFooter = HB_PARASTRDEF( 1, TDC_FOOTER, &hText[ iText++ ], NULL );
      else if( iType & HB_IT_NUMERIC )
         config.pszFooter = MAKEINTRESOURCE( hb_arrayGetNI( pConfig, TDC_FOOTER ) );

      // 22 PFTASKDIALOGCALLBACK pfCallback;
      // 23 LONG_PTR lpCallbackData;
      if( hb_arrayGetType( pConfig, TDC_CALLBACK ) & HB_IT_EVALITEM )
         pCallbackData = hb_itemNew( hb_arrayGetItemPtr( pConfig, TDC_CALLBACK ) );

      if( hb_arrayGetType( pConfig, 23 ) & HB_IT_OBJECT )
         pCallbackData = hb_itemNew( hb_arrayGetItemPtr( pConfig, 23 ) );

      if( NULL != pCallbackData )
      {
         hb_gcUnlock( pCallbackData );

         config.lpCallbackData = ( LONG_PTR ) pCallbackData;
         config.pfCallback     = __ClsCBFunc;
      }

      // 24 UINT cxWidth;
      config.cxWidth = ( hb_arrayGetType( pConfig, TDC_WIDTH ) & HB_IT_NUMERIC ) ? hb_arrayGetNI( pConfig, TDC_WIDTH ) : 0;

      ////////////////////////////////////////////////////////////////////////////////////////////
      hResult = TaskDialogIndirect( &config, &nButton, &nRadioButton, &fVerificationFlagChecked );
      ////////////////////////////////////////////////////////////////////////////////////////////
      /* HB_TRACE( HB_TR_DEBUG, ( "win_TaskDialogIndirect0() returns %08lX", hResult ) );*/

      while( --iText >= 0 )
         hb_strfree( hText[ iText ] );

      hb_xfree( hText );

      while( --iButton >= 0 )
         hb_strfree( hButton[ iButton ] );

      if( NULL != hButton )
         hb_xfree( hButton );

      while( --iRadioButton >= 0 )
         hb_strfree( hRadioButton[ iRadioButton ] );

      if( NULL != hRadioButton )
         hb_xfree( hRadioButton );

      if( hb_arrayGetType( pConfig, TDC_CALLBACK ) & HB_IT_EVALITEM )
         hb_itemRelease( ( PHB_ITEM ) config.lpCallbackData );

      if( hResult == S_OK )
      {
         if( nButton )
            hb_storni( nButton, 2 );
         else
            hb_stor( 2 );

         if( nRadioButton )
            hb_storni( nRadioButton, 3 );
         else
            hb_stor( 3 );

         hb_storl( fVerificationFlagChecked, 4 );
      }
      else
      {
         hb_stor( 2 );
         hb_stor( 3 );
         hb_stor( 4 );
      }

      hb_retnint( hResult );
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 5000, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

static HB_BOOL TD_CheckButton( const PHB_ITEM arrayOfButtons, HB_SIZE arraysize )
{
   PHB_ITEM button;
   HB_SIZE  i;

   for( i = 1; i <= arraysize; ++i )
   {
      button = hb_arrayGetItemPtr( arrayOfButtons, i );
      if( HB_IS_ARRAY( button ) && hb_arrayLen( button ) > 1 )
      {
         if( ! ( ( ( hb_arrayGetType( button, 1 ) & HB_IT_NUMERIC ) != 0 ) &&
                 ( ( hb_arrayGetType( button, 2 ) & ( HB_IT_STRING | HB_IT_NUMERIC ) ) != 0 ) ) )
            return HB_FALSE;
      }
      else
         return HB_FALSE;
   }

   return HB_TRUE;
}

HRESULT CALLBACK __ClsCBFunc( HWND hWnd, UINT uiNotification, WPARAM wParam, LPARAM lParam, LONG_PTR dwRefData )
{
   HB_TYPE iType = hb_itemType( ( PHB_ITEM ) dwRefData );

   if( iType & HB_IT_OBJECT )
   {
      PHB_ITEM     pObject = ( PHB_ITEM ) dwRefData;
      const char * sMsgName;
      HRESULT      hRes;

      // Standard of Behavior
      if( ( uiNotification == TDN_BUTTON_CLICKED ) && ( wParam == IDOK || wParam == IDCANCEL ) )
         return S_OK;

      // Get TimedOut property
      hb_objSendMsg( pObject, ( const char * ) "TIMEDOUT", 0 );

      if( ! ( BOOL ) hb_parl( -1 ) )  // if FALSE - it's not the time yet
      {
         if( uiNotification == TDN_TIMER )
         {
            DWORD nMilliSec;
            // Get timeoutMS property
            hb_objSendMsg( pObject, ( const char * ) "TIMEOUTMS", 0 );
            nMilliSec = hb_parni( -1 );
            // Remember what wParam is the time in milliseconds since dialog created or timer reset
            if( ( 0 != nMilliSec ) && ( nMilliSec < wParam ) ) // If the condition is met - the time out!
            {
               PHB_ITEM itmTimeOut = hb_itemPutL( NULL, HB_TRUE );
               // Set TimedOut property to TRUE
               hb_objSendMsg( pObject, ( const char * ) "TIMEDOUT", 1, itmTimeOut );
               hb_itemRelease( itmTimeOut );
               // And cancel a Dialog
               SendMessage( hWnd, TDM_CLICK_BUTTON, IDCANCEL, ( LPARAM ) 0 );
            }
            else
               TD_objSendMsg( pObject, ( const char * ) "ONTIMER", NULL, hWnd, uiNotification, wParam, lParam );

            return S_OK; // Not reset timer
         }
      }

      sMsgName = TD_NotifyToMsg( uiNotification, ( PHB_ITEM ) dwRefData );

      if( TD_objSendMsg( pObject, sMsgName, &hRes, hWnd, uiNotification, wParam, lParam ) )
         return hRes;
   }
   else if( iType & HB_IT_EVALITEM )
   {
      PHB_ITEM pCallback = ( PHB_ITEM ) dwRefData;

      if( pCallback && hb_vmRequestReenter() )
      {
         HRESULT  hRes;
         PHB_ITEM itmStr = hb_itemNew( NULL );

         hb_vmPushEvalSym();
         hb_vmPush( pCallback );
         hb_vmPushNumInt( ( HB_MAXINT ) ( HB_PTRUINT ) hWnd );
         hb_vmPushNumInt( uiNotification );
         hb_vmPushNumInt( wParam );

         if( uiNotification == TDN_HYPERLINK_CLICKED )
         {
            HB_ITEMPUTSTR( itmStr, ( HB_WCHAR * ) lParam );

            hb_vmPush/*ItemRef*/ ( itmStr );
         }
         else
            hb_vmPushNumInt( lParam );

         hb_vmSend( 4 );

         hRes = ( ( hb_parl( -1 ) == HB_TRUE ) ? S_OK : S_FALSE );

         hb_itemRelease( itmStr );
         hb_vmRequestRestore();

         return hRes;
      }

      return S_OK;
   }

   return S_OK;
}

static const char * TD_NotifyToMsg( UINT uiNotification, PHB_ITEM pObj )
{
   typedef struct
   {
      UINT Notification;
      const char * MsgName;
   } NOTIFY_MSG;

   static const NOTIFY_MSG s_NOTIFY_MSG[] = {
      { TDN_CREATED,                "ONCREATED"              },
      { TDN_DIALOG_CONSTRUCTED,     "ONCONSTRUCTED"          },
      { TDN_DESTROYED,              "ONDESTROYED"            },
      /* { TDN_NAVIGATED, "ONNAVIGATED" }, */
      { TDN_BUTTON_CLICKED,         "ONBUTTONCLICKED"        },
      { TDN_HYPERLINK_CLICKED,      "ONHYPERLINKCLICKED"     },
      { TDN_TIMER,                  "ONTIMER"                },
      { TDN_RADIO_BUTTON_CLICKED,   "ONRADIOBUTTONCLICKED"   },
      { TDN_VERIFICATION_CLICKED,   "ONVERIFICATIONCLICKED"  },
      { TDN_HELP,                   "ONHELP"                 },
      { TDN_EXPANDO_BUTTON_CLICKED, "ONEXPANDOBUTTONCLICKED" }
   };
   UINT uiPos;
   const char * sMsgName = NULL;

   for( uiPos = 0; uiPos < ( UINT ) HB_SIZEOFARRAY( s_NOTIFY_MSG ); ++uiPos )
   {
      if( s_NOTIFY_MSG[ uiPos ].Notification == uiNotification )
      {
         sMsgName = s_NOTIFY_MSG[ uiPos ].MsgName;
         break;
      }
   }

   if( ( NULL != sMsgName ) && hb_objHasMsg( pObj, sMsgName ) )
      return sMsgName;

   return ( const char * ) "LISTENER";
}

static BOOL TD_objSendMsg( PHB_ITEM pObject, const char * sMsgName, HRESULT * hRes, HWND hWnd, UINT uiNotification, WPARAM wParam, LPARAM lParam )
{
   if( hb_objHasMsg( pObject, sMsgName ) )
   {
      PHB_ITEM itmHWND   = hb_itemPutNInt( NULL, ( HB_MAXINT ) ( HB_PTRUINT ) hWnd );
      PHB_ITEM itmNotify = hb_itemPutNInt( NULL, uiNotification );
      PHB_ITEM itmWParam = hb_itemPutNInt( NULL, wParam );
      PHB_ITEM itmLParam = hb_itemNew( NULL );
      PHB_ITEM itmResult;

      if( uiNotification == TDN_HYPERLINK_CLICKED )
         HB_ITEMPUTSTR( itmLParam, ( HB_WCHAR * ) lParam );
      else
         hb_itemPutNInt( itmLParam, lParam );

      itmResult = hb_objSendMsg( pObject, sMsgName, 4, itmHWND, itmNotify, itmWParam, itmLParam );

      if( NULL != hRes )
         ( *hRes ) = ( hb_itemGetL(  itmResult ) == HB_TRUE ? S_OK : S_FALSE );

      hb_itemRelease( itmResult );
      hb_itemRelease( itmHWND );
      hb_itemRelease( itmNotify );
      hb_itemRelease( itmWParam );
      hb_itemRelease( itmLParam );

      return TRUE;
   }

   return FALSE;
}

HB_FUNC( _SETWINDOWTITLE )
{
   void * hText = NULL;
   PCWSTR pszText;

   if( HB_ISCHAR( 2 ) || HB_ISNUM( 2 ) )
   {
      pszText = HB_ISCHAR( 2 ) ? HB_PARSTRDEF( 2, &hText, NULL ) : MAKEINTRESOURCE( hb_parni( 2 ) );

      SetWindowText( ( HWND ) HB_PARNL( 1 ), pszText );

      if( HB_ISCHAR( 2 ) )
         hb_strfree( hText );
   }
}

/* Task Dialog Messages  */

// TDM_CLICK_BUTTON - Simulates the action of a button click in a task dialog
HB_FUNC( _CLICKBUTTON )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_CLICK_BUTTON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 );
}

// TDM_CLICK_RADIO_BUTTON - Simulates the action of a radio button click in a task dialog
HB_FUNC( _CLICKRADIOBUTTON )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_CLICK_RADIO_BUTTON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 );
}

// TDM_CLICK_VERIFICATION - Simulates a click of the verification checkbox of a task dialog, if it exists.
HB_FUNC( _CLICKVERIFICATION )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_CLICK_VERIFICATION, ( WPARAM ) ( BOOL ) hb_parl( 2 ), ( LPARAM ) ( BOOL ) hb_parl( 3 ) );
}

// TDM_ENABLE_BUTTON - Enables or disables a push button in a task dialog
HB_FUNC( _ENABLEBUTTON )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_ENABLE_BUTTON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) ( BOOL ) hb_parl( 3 ) );
}

// TDM_ENABLE_RADIO_BUTTON - Enables or disables a push button in a task dialog
HB_FUNC( _ENABLERADIOBUTTON )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_ENABLE_RADIO_BUTTON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) ( BOOL ) hb_parl( 3 ) );
}

// TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE - Specifies whether a given task dialog button or command link should have a UAC shield icon
HB_FUNC( _SETBUTTONELEVATIONREQUIRED )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) ( BOOL ) hb_parl( 3 ) );
}

// TDM_SET_ELEMENT_TEXT - Updates a text element in a task dialog
HB_FUNC( _SETMAININSTRUCTION )
{
   void * hText = NULL;
   PCWSTR pszMainInstruction = HB_ISCHAR( 2 ) ? HB_PARSTRDEF( 2, &hText, NULL ) :
                               ( HB_ISNUM( 2 ) ? MAKEINTRESOURCE( hb_parni( 2 ) ) : NULL );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_ELEMENT_TEXT, ( WPARAM ) TDE_MAIN_INSTRUCTION, ( LPARAM ) pszMainInstruction );

   if( hText )
      hb_strfree( hText );
}

HB_FUNC( _SETCONTENT )
{
   void * hText      = NULL;
   PCWSTR pszContent = HB_ISCHAR( 2 ) ? HB_PARSTRDEF( 2, &hText, NULL ) :
                       ( HB_ISNUM( 2 ) ? MAKEINTRESOURCE( hb_parni( 2 ) ) : NULL );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_ELEMENT_TEXT, ( WPARAM ) TDE_CONTENT, ( LPARAM ) pszContent );

   if( hText )
      hb_strfree( hText );
}

HB_FUNC( _SETFOOTER )
{
   void * hText     = NULL;
   PCWSTR pszFooter = HB_ISCHAR( 2 ) ? HB_PARSTRDEF( 2, &hText, NULL ) :
                      ( HB_ISNUM( 2 ) ? MAKEINTRESOURCE( hb_parni( 2 ) ) : NULL );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_ELEMENT_TEXT, ( WPARAM ) TDE_FOOTER, ( LPARAM ) pszFooter );

   if( hText )
      hb_strfree( hText );
}

HB_FUNC( _SETEXPANDEDINFORMATION )
{
   void * hText = NULL;
   PCWSTR pszExpandedInformation = HB_ISCHAR( 2 ) ? HB_PARSTRDEF( 2, &hText, NULL ) :
                                   ( HB_ISNUM( 2 ) ? MAKEINTRESOURCE( hb_parni( 2 ) ) : NULL );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_ELEMENT_TEXT, ( WPARAM ) TDE_EXPANDED_INFORMATION, ( LPARAM ) pszExpandedInformation );

   if( hText )
      hb_strfree( hText );
}

// TDM_SET_PROGRESS_BAR_POS - Sets the position of the progress bar in a task dialog
HB_FUNC( _SETPROGRESSBARPOS )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_PROGRESS_BAR_POS, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 );
}

// TDM_SET_PROGRESS_BAR_RANGE - Sets the minimum and maximum values for the progress bar in a task dialog
HB_FUNC( _SETPROGRESSBARRANGE )
{
   LPARAM range = MAKELPARAM( ( ( WORD ) hb_parni( 2 ) ), ( ( WORD ) hb_parni( 3 ) ) );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_PROGRESS_BAR_RANGE, ( WPARAM ) 0, range );
}

// TDM_SET_PROGRESS_BAR_STATE - Sets the state of the progress bar in a task dialog.
HB_FUNC( _SETPROGRESSBARSTATE )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_PROGRESS_BAR_STATE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 );
}

// TDM_SET_PROGRESS_BAR_MARQUEE - Starts and stops the marquee display of the progress bar in a task dialog,
//                                and sets the speed of the marquee.
HB_FUNC( _SETPROGRESSBARMARQUEE )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_PROGRESS_BAR_MARQUEE, ( WPARAM ) hb_parl( 2 ), ( LPARAM ) hb_parni( 3 ) );
}

// TDM_SET_MARQUEE_PROGRESS_BAR - Indicates whether the hosted progress bar of a task dialog should be displayed in marquee mode
HB_FUNC( _SETMARQUEEPROGRESSBAR )
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_SET_MARQUEE_PROGRESS_BAR, ( WPARAM ) hb_parl( 2 ), ( LPARAM ) 0 );
}

// TDM_UPDATE_ELEMENT_TEXT - Updates a text element in a task dialog
HB_FUNC( _UPDATEMAININSTRUCTION )
{
   void * hText = NULL;
   PCWSTR pszMainInstruction = HB_ISCHAR( 2 ) ? HB_PARSTRDEF( 2, &hText, NULL ) :
                               ( HB_ISNUM( 2 ) ? MAKEINTRESOURCE( hb_parni( 2 ) ) : NULL );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ELEMENT_TEXT, ( WPARAM ) TDE_MAIN_INSTRUCTION, ( LPARAM ) pszMainInstruction );

   if( hText )
      hb_strfree( hText );
}

HB_FUNC( _UPDATECONTENT )
{
   void * hText      = NULL;
   PCWSTR pszContent = HB_ISCHAR( 2 ) ? HB_PARSTRDEF( 2, &hText, NULL ) :
                       ( HB_ISNUM( 2 ) ? MAKEINTRESOURCE( hb_parni( 2 ) ) : NULL );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ELEMENT_TEXT, ( WPARAM ) TDE_CONTENT, ( LPARAM ) pszContent );

   if( hText )
      hb_strfree( hText );
}

HB_FUNC( _UPDATEFOOTER )
{
   void * hText     = NULL;
   PCWSTR pszFooter = HB_ISCHAR( 2 ) ? HB_PARSTRDEF( 2, &hText, NULL ) :
                      ( HB_ISNUM( 2 ) ? MAKEINTRESOURCE( hb_parni( 2 ) ) : NULL );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ELEMENT_TEXT, ( WPARAM ) TDE_FOOTER, ( LPARAM ) pszFooter );

   if( hText )
      hb_strfree( hText );
}

HB_FUNC( _UPDATEEXPANDEDINFORMATION )
{
   void * hText = NULL;
   PCWSTR pszExpandedInformation = HB_ISCHAR( 2 ) ? HB_PARSTRDEF( 2, &hText, NULL ) :
                                   ( HB_ISNUM( 2 ) ? MAKEINTRESOURCE( hb_parni( 2 ) ) : NULL );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ELEMENT_TEXT, ( WPARAM ) TDE_EXPANDED_INFORMATION, ( LPARAM ) pszExpandedInformation );

   if( HB_ISCHAR( 2 ) )
      hb_strfree( hText );
}

/* TODO */
HB_FUNC( _UPDATEMAINICON )
{
   if( HB_ISNUM( 2 ) )
      SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ICON, ( WPARAM ) TDIE_ICON_MAIN, ( LPARAM ) MAKEINTRESOURCE( hb_parni( 2 ) ) );
   else if( HB_ISCHAR( 2 ) )
   {
      void * hText;
      PCWSTR pszIcon = HB_PARSTRDEF( 2, &hText, NULL );

      SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ICON, ( WPARAM ) TDIE_ICON_MAIN, ( LPARAM ) pszIcon );
      hb_strfree( hText );
   }
   else if( HB_ISPOINTER( 2 ) )
      SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ICON, ( WPARAM ) TDIE_ICON_MAIN, ( LPARAM ) ( HICON ) hb_parptr( 2 ) );
   else
      SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ICON, ( WPARAM ) TDIE_ICON_MAIN, ( LPARAM ) NULL );
}

/* TODO */
HB_FUNC( _UPDATEFOOTERICON )
{
   if( HB_ISNUM( 2 ) )
      SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ICON, ( WPARAM ) TDIE_ICON_FOOTER, ( LPARAM ) MAKEINTRESOURCE( hb_parni( 2 ) ) );
   else if( HB_ISCHAR( 2 ) )
   {
      void * hText;
      PCWSTR pszIcon = HB_PARSTRDEF( 2, &hText, NULL );

      SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ICON, ( WPARAM ) TDIE_ICON_FOOTER, ( LPARAM ) pszIcon );
      hb_strfree( hText );
   }
   else if( HB_ISPOINTER( 2 ) )
      SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ICON, ( WPARAM ) TDIE_ICON_FOOTER, ( LPARAM ) ( HICON ) hb_parptr( 2 ) );
   else
      SendMessage( ( HWND ) HB_PARNL( 1 ), TDM_UPDATE_ICON, ( WPARAM ) TDIE_ICON_FOOTER, ( LPARAM ) NULL );
}

#endif /* __XHARBOUR__ */
