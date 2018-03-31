
#define BUFFLEN  4096

*��������������������������������������������������������������͸
*� Function Bopen( <cFileName>, [nAccessMode] )                 �
*� Return:   .t. if file was opened                             �
*� Assumes:  All file access will be done with the B* functions �
*��������������������������������������������������������������;
function Bopen( cFileName, nAccMode )

default nAccMode to FO_READ // default access mode is Read Only

nHandle := fopen( cFileName, nAccMode )
cLineBuffer := ''
lFullBuff := .t.
nTotBytes := 0
lIsOpen := .t.

return ( nHandle != -1 )

*��������������������������������������������������������������͸
*� Function BReadLine()                                         �
*� Return:   The next line of the file read buffer              �
*� Assumes:  The file pointer will be left as last positioned   �
*��������������������������������������������������������������;
Function BReadLine( cDelimiter )

local ThisLine
local nCrLfAt

default cDelimiter to chr( 13 ) + chr( 10 )

do While .t.
   
   nCrLfAt := at( cDelimiter, cLineBuffer )
   
   if empty( nCrLfAt ) .and. lFullBuff
      BDisk2Buff()
      loop
   endif
   
   if empty( nCrLfAt )
      ThisLine := strtran( cLineBuffer, chr( 26 ) )
      cLineBuffer := ''
   else
      ThisLine := left( cLineBuffer, nCrLfAt - 1 )
      cLineBuffer := substr( cLineBuffer, nCrLfAt + len( cdelimiter ) )
   endif
   
   exit
   
EndDo

Return ThisLine

*��������������������������������������������������������������͸
*� Function BDisk2Buff()                                        �
*� Return:   .t. if there was no read error                     �
*��������������������������������������������������������������;
STATIC FUNCTION BDisk2Buff()

STATIC cDiskBuffer := ''

if len( cDiskBuffer ) != BUFFLEN
   cDiskBuffer := space( BUFFLEN )
endif

nBytesRead := fread( nHandle, @cDiskBuffer, BUFFLEN )

nTotBytes += nBytesRead

lFullBuff := ( nBytesRead == BUFFLEN )

if lFullBuff
   cLineBuffer += cDiskBuffer
else
   cLineBuffer += left( cDiskBuffer, nBytesRead )
endif

return ferror()

*��������������������������������������������������������������͸
*� Function BEof()                                              �
*� Return:   TRUE  if End of buffered file                      �
*�           FALSE if not                                       �
*��������������������������������������������������������������;
Function BEof()

Return !lFullBuff .and. len( cLineBuffer ) == 0

*��������������������������������������������������������������͸
*� Function BClose()                                            �
*��������������������������������������������������������������;
Function BClose()

if lIsOpen
   fclose( nHandle )
   lIsOpen := .f.
endif

Return FError()

*��������������������������������������������������������������͸
*� Function BPosition()                                         �
*� Returns the position of virtual file pointer                 �
*��������������������������������������������������������������;
Function BPosition()

Return nTotBytes
