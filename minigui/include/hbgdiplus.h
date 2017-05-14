#ifndef HB_GDIPLUS_H_
# define HB_GDIPLUS_H_

# if defined( __BORLANDC__ )
#  pragma option push -b -a8 -pc -A- -w-inl -w-hid /*P_O_Push*/
# endif /* __BORLANDC__ */

# if defined( __BORLANDC__ )
#  define __inline__  __inline
#  define __forceinline  __inline
#  define __extension__
# else /* =======================__MINGW32__======================*/
#  if defined( __MINGW32__ )
#   ifdef __forceinline
#    undef __forceinline
#   endif
#   define __forceinline  __inline__
#  endif /* __MINGW32__ */
# endif /* __BORLANDC__ */

# include "fGdiPlusFlat.h"

# define _GDI_GRAPHICS 1
# define _GDI_PEN      2
# define _GDI_IMAGES   4

# ifdef _HMG_STUB_ /* =======================_HMG_STUB_=======================*/
# include <pshpack8.h>   // set structure packing to 8
typedef void ( WINGDIPAPI * DEBUGEVENTPROC )( void *, char * );

typedef struct
{
   UINT32 GdiPlusVersion;
   DEBUGEVENTPROC DebugEventCallback;
   int SuppressBackgroundThread;
   int SuppressExternalCodecs;
} GDIPLUS_STARTUP_INPUT;

typedef GpStatus ( WINGDIPAPI * GdiplusStartup_ptr )( ULONG_PTR *, GDIPCONST GDIPLUS_STARTUP_INPUT *, void * );
typedef void ( WINGDIPAPI * GdiplusShutdown_ptr )( ULONG_PTR );
# include <poppack.h>    // pop structure packing back to previous state
# else /* =======================_HMG_STUB_=======================*/
extern HMODULE g_GpModule;
# endif /* ======================_HMG_STUB_=======================*/

# ifndef __XHARBOUR__
# include "hbwinuni.h"
# else
typedef wchar_t HB_WCHAR;
# endif

typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromFile_ptr )( GDIPCONST HB_WCHAR *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * GdipCreateHBITMAPFromBitmap_ptr )( GpBitmap *, HBITMAP *, ARGB );
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromResource_ptr )( HINSTANCE, GDIPCONST HB_WCHAR *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromStream_ptr )( IStream *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * GdipDisposeImage_ptr )( GpImage * );

#define EXTERN_FUNCPTR( name )          extern name##_ptr fn_##name
#define DECLARE_FUNCPTR( name )         name##_ptr fn_##name = NULL
#define ASSIGN_FUNCPTR( module, name )  fn_##name = ( name##_ptr )GetProcAddress( module, #name )
#define _EMPTY_PTR( module, name )      NULL == ( ASSIGN_FUNCPTR( module, name ) )

#define HB_REAL( n ) ( float ) hb_parnd( n )

EXTERN_FUNCPTR( GdipCreateBitmapFromFile );
EXTERN_FUNCPTR( GdipCreateBitmapFromResource );
EXTERN_FUNCPTR( GdipCreateBitmapFromStream );
EXTERN_FUNCPTR( GdipCreateHBITMAPFromBitmap );
EXTERN_FUNCPTR( GdipDisposeImage );

# ifdef __BORLANDC__
#  pragma option pop /*P_O_Pop*/
# endif /* __BORLANDC__ */
#endif  /* HB_GDIPLUS_H_ */
