
#ifndef HB_GDIPLUS_H_
# ifdef __BORLANDC__
#  pragma option push -b -a8 -pc -A- -w-inl -w-hid /*P_O_Push*/
# endif /* __BORLANDC__ */
# define HB_GDIPLUS_H_

# ifdef _HMG_STUB_  /* =======================_HMG_STUB_=======================*/
#  define WINGDIPAPI  __stdcall
#  define GDIPCONST   const
# ifdef __XHARBOUR__
   typedef wchar_t         HB_WCHAR;
# endif

#  include <pshpack8.h>   // set structure packing to 8

typedef void ( WINGDIPAPI * DEBUGEVENTPROC )( void *, char * );

typedef struct
{
   UINT32 GdiPlusVersion;
   DEBUGEVENTPROC DebugEventCallback;
   int SuppressBackgroundThread;
   int SuppressExternalCodecs;
} GDIPLUS_STARTUP_INPUT;

#  include <poppack.h>    // pop structure packing back to previous state

typedef enum
{
   Ok                        = 0,
   GenericError              = 1,
   InvalidParameter          = 2,
   OutOfMemory               = 3,
   ObjectBusy                = 4,
   InsufficientBuffer        = 5,
   NotImplemented            = 6,
   Win32Error                = 7,
   WrongState                = 8,
   Aborted                   = 9,
   FileNotFound              = 10,
   ValueOverflow             = 11,
   AccessDenied              = 12,
   UnknownImageFormat        = 13,
   FontFamilyNotFound        = 14,
   FontStyleNotFound         = 15,
   NotTrueTypeFont           = 16,
   UnsupportedGdiplusVersion = 17,
   GdiplusNotInitialized     = 18,
   PropertyNotFound          = 19,
   PropertyNotSupported      = 20,
   ProfileNotFound           = 21
} GpStatus;

typedef void * GpBitmap;
typedef void * GpImage;
typedef DWORD  ARGB;
#ifndef IStream
typedef struct IStream IStream;
#endif

typedef GpStatus ( WINGDIPAPI * GdiplusStartupPtr )( ULONG_PTR *, GDIPCONST GDIPLUS_STARTUP_INPUT *, void * );
typedef void ( WINGDIPAPI * GdiplusShutdownPtr )( ULONG_PTR );

typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromFilePtr)( GDIPCONST HB_WCHAR * filename, GpBitmap * );
typedef GpStatus ( WINGDIPAPI * GdipCreateHBITMAPFromBitmapPtr)( GpBitmap, HBITMAP *, ARGB );
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromResourcePtr)( HINSTANCE, GDIPCONST HB_WCHAR *, GpBitmap *);
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromStreamPtr)( IStream*, GpBitmap *);
typedef GpStatus ( WINGDIPAPI * GdipDisposeImagePtr)( GpImage * );

#else /* =======================_HMG_STUB_=======================*/
# if ( defined( __BORLANDC__ ) )
#  define __inline__  __inline
#  define __extension__
# endif /* __BORLANDC__ */

# if ( ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 ) )
typedef ULONG PROPID;
# endif /* __BORLANDC__ */
#//include "gdiplus.h"
extern HMODULE g_GpModule;
#endif /* =======================_HMG_STUB_=======================*/

#define EXTERN_FUNCPTR( name )          extern name##Ptr g_##name
#define DECLARE_FUNCPTR( name )         name##Ptr g_##name = NULL
#define ASSIGN_FUNCPTR( module, name )  g_##name           = ( name##Ptr )GetProcAddress( module, #name )
#define _EMPTY_PTR(module, name)        NULL == ( ASSIGN_FUNCPTR(module, name) )

EXTERN_FUNCPTR( GdipCreateBitmapFromFile );
EXTERN_FUNCPTR( GdipCreateBitmapFromResource );
EXTERN_FUNCPTR( GdipCreateBitmapFromStream );
EXTERN_FUNCPTR( GdipCreateHBITMAPFromBitmap );
EXTERN_FUNCPTR( GdipDisposeImage );

# ifdef __BORLANDC__
#  pragma option pop /*P_O_Pop*/
# endif /* __BORLANDC__ */
#endif  /* HB_GDIPLUS_H_ */
