***NOTES FOR DIjpg.dll***

Here is how to use the DLL :

Copy your image to "C:\tmp.bmp"
Call the function with your FULL destination path , quality (%) and
0 for non-progressive or 1 for progressive JPEG.
Erase temporary file "C:\tmp.bmp"

The declaration for the function is :
DECLARE DLL_TYPE_LONG DIWriteJpg(DLL_TYPE_LPCSTR DestPath, DLL_TYPE_LONG quality, DLL_TYPE_LONG progressive) IN DIjpg.dll
