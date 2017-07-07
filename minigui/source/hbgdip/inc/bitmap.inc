
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromStream_ptr)(IStream* stream, GpBitmap **bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromFile_ptr)(GDIPCONST WCHAR* filename, GpBitmap **bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromStreamICM_ptr)(IStream* stream, GpBitmap **bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromFileICM_ptr)(GDIPCONST WCHAR* filename, GpBitmap **bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromScan0_ptr)(INT width, INT height, INT stride, PixelFormat format, BYTE* scan0, GpBitmap** bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromGraphics_ptr)(INT width, INT height, GpGraphics* target, GpBitmap** bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromDirectDrawSurface_ptr)(IDirectDrawSurface7* surface, GpBitmap** bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromGdiDib_ptr)(GDIPCONST BITMAPINFO* gdiBitmapInfo, VOID* gdiBitmapData, GpBitmap** bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromHBITMAP_ptr)(HBITMAP hbm, HPALETTE hpal, GpBitmap** bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateHBITMAPFromBitmap_ptr)(GpBitmap* bitmap, HBITMAP* hbmReturn, ARGB background);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromHICON_ptr)(HICON hicon, GpBitmap** bitmap);
//typedef GpStatus (WINGDIPAPI * GdipCreateHICONFromBitmap_ptr)(GpBitmap* bitmap, HICON* hbmReturn);
//typedef GpStatus (WINGDIPAPI * GdipCreateBitmapFromResource_ptr)(HINSTANCE hInstance, GDIPCONST WCHAR* lpBitmapName, GpBitmap** bitmap);
typedef GpStatus (WINGDIPAPI * GdipCloneBitmapArea_ptr)(REAL x, REAL y, REAL width, REAL height, PixelFormat format, GpBitmap *srcBitmap, GpBitmap **dstBitmap);
//typedef GpStatus (WINGDIPAPI * GdipCloneBitmapAreaI_ptr)(INT x, INT y, INT width, INT height, PixelFormat format, GpBitmap *srcBitmap, GpBitmap **dstBitmap);
//typedef GpStatus (WINGDIPAPI * GdipBitmapLockBits_ptr)(GpBitmap* bitmap, GDIPCONST GpRect* rect, UINT flags, PixelFormat format, BitmapData* lockedBitmapData);
//typedef GpStatus (WINGDIPAPI * GdipBitmapUnlockBits_ptr)(GpBitmap* bitmap, BitmapData* lockedBitmapData);
//typedef GpStatus (WINGDIPAPI * GdipBitmapGetPixel_ptr)(GpBitmap* bitmap, INT x, INT y, ARGB *color);
//typedef GpStatus (WINGDIPAPI * GdipBitmapSetPixel_ptr)(GpBitmap* bitmap, INT x, INT y, ARGB color);
//typedef GpStatus (WINGDIPAPI * GdipImageSetAbort_ptr)(GpImage *pImage, GdiplusAbort *pIAbort);
//typedef GpStatus (WINGDIPAPI * GdipGraphicsSetAbort_ptr)(GpGraphics *pGraphics, GdiplusAbort *pIAbort);
//typedef GpStatus (WINGDIPAPI * GdipBitmapConvertFormat_ptr)(GpBitmap *pInputBitmap, PixelFormat format, DitherType dithertype, PaletteType palettetype, ColorPalette *palette, REAL alphaThresholdPercent );
//typedef GpStatus (WINGDIPAPI * GdipInitializePalette_ptr)(ColorPalette *palette, PaletteType palettetype, INT optimalColors, BOOL useTransparentColor, GpBitmap *bitmap);
//typedef GpStatus (WINGDIPAPI * GdipBitmapApplyEffect_ptr)(GpBitmap* bitmap, CGpEffect *effect, RECT *roi, BOOL useAuxData, VOID **auxData, INT *auxDataSize);
//typedef GpStatus (WINGDIPAPI * GdipBitmapCreateApplyEffect_ptr)(GpBitmap **inputBitmaps, INT numInputs, CGpEffect *effect, RECT *roi, RECT *outputRect, GpBitmap **outputBitmap, BOOL useAuxData, VOID **auxData, INT *auxDataSize);
//typedef GpStatus (WINGDIPAPI * GdipBitmapGetHistogram_ptr)(GpBitmap* bitmap, HistogramFormat format, UINT NumberOfEntries, UINT *channel0, UINT *channel1, UINT *channel2, UINT *channel3);
//typedef GpStatus (WINGDIPAPI * GdipBitmapGetHistogramSize_ptr)(HistogramFormat format, UINT *NumberOfEntries);
//typedef GpStatus (WINGDIPAPI * GdipBitmapSetResolution_ptr)(GpBitmap* bitmap, REAL xdpi, REAL ydpi);

//DECLARE_FUNCPTR(GdipCreateBitmapFromStream);
//DECLARE_FUNCPTR(GdipCreateBitmapFromFile);
//DECLARE_FUNCPTR(GdipCreateBitmapFromStreamICM);
//DECLARE_FUNCPTR(GdipCreateBitmapFromFileICM);
//DECLARE_FUNCPTR(GdipCreateBitmapFromScan0);
//DECLARE_FUNCPTR(GdipCreateBitmapFromGraphics);
//DECLARE_FUNCPTR(GdipCreateBitmapFromDirectDrawSurface);
//DECLARE_FUNCPTR(GdipCreateBitmapFromGdiDib);
//DECLARE_FUNCPTR(GdipCreateBitmapFromHBITMAP);
//DECLARE_FUNCPTR(GdipCreateHBITMAPFromBitmap);
//DECLARE_FUNCPTR(GdipCreateBitmapFromHICON);
//DECLARE_FUNCPTR(GdipCreateHICONFromBitmap);
//DECLARE_FUNCPTR(GdipCreateBitmapFromResource);
DECLARE_FUNCPTR(GdipCloneBitmapArea);
//DECLARE_FUNCPTR(GdipCloneBitmapAreaI);
//DECLARE_FUNCPTR(GdipBitmapLockBits);
//DECLARE_FUNCPTR(GdipBitmapUnlockBits);
//DECLARE_FUNCPTR(GdipBitmapGetPixel);
//DECLARE_FUNCPTR(GdipBitmapSetPixel);
//DECLARE_FUNCPTR(GdipImageSetAbort);
//DECLARE_FUNCPTR(GdipGraphicsSetAbort);
//DECLARE_FUNCPTR(GdipBitmapConvertFormat);
//DECLARE_FUNCPTR(GdipInitializePalette);
//DECLARE_FUNCPTR(GdipBitmapApplyEffect);
//DECLARE_FUNCPTR(GdipBitmapCreateApplyEffect);
//DECLARE_FUNCPTR(GdipBitmapGetHistogram);
//DECLARE_FUNCPTR(GdipBitmapGetHistogramSize);
//DECLARE_FUNCPTR(GdipBitmapSetResolution);