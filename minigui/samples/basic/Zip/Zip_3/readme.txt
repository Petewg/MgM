Harbour functions to manage ZIP files:
======================================

HB_ZipOpen( cFileName, [ iMode = HB_ZIP_CREATE ],
            [ @cGlobalComment ] ) --> hZip
HB_ZipClose( hZip, [ cGlobalComment ] ) --> nError
HB_ZipFileCreate( hZip, cZipName, dDate, cTime,
                  nInternalAttr, nExternalAttr,
                  [ nMethod = HB_ZLIB_METHOD_DEFLATE ], 
                  [ nLevel = HB_ZLIB_COMPRESSION_DEFAULT ], 
                  [ cPassword, ulFileCRC32 ], [ cComment ] ) --> nError
HB_ZipFileWrite( hZip, cData [, nLen ] ) --> nError
HB_ZipFileClose( hZip ) --> nError
HB_ZipStoreFile( hZip, cFileName, [ cZipName ], ;
                 [ cPassword ], [ cComment ] ) --> nError
HB_zipFileCRC32( cFileName ) --> nError


HB_UnzipOpen( cFileName ) --> hUnzip
HB_UnzipClose( hUnzip ) --> nError
HB_UnzipGlobalInfo( hUnzip, @nEntries, @cGlobalComment ) --> nError
HB_UnzipFileFirst( hUnzip ) --> nError
HB_UnzipFileNext( hUnzip ) --> nError
HB_UnzipFilePos( hUnzip ) --> nPosition
HB_UnzipFileGoto( hUnzip, nPosition ) --> nError
HB_UnzipFileInfo( hUnzip, @cZipName, @dDate, @cTime,
                  @nInternalAttr, @nExternalAttr,
                  @nMethod, @nSize, @nCompressedSize,
                  @lCrypted, @cComment ) --> nError
HB_UnzipFileOpen( hUnzip, [ cPassword ] ) --> nError
HB_UnzipFileRead( hUnzip, @cBuf [, nLen ] ) --> nRead
HB_UnzipFileClose( hUnzip ) --> nError
HB_UnzipExtractCurrentFile( hUnzip, [ cFileName ], [ cPassword ] ) --> nError


HB_ZipDeleteFile( cZipFile, cFileMask ) --> nError
