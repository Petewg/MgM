
#define BUFFLEN  4096

*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
*ณ Function Bopen( <cFileName>, [nAccessMode] )                 ณ
*ณ Return:   .t. if file was opened                             ณ
*ณ Assumes:  All file access will be done with the B* functions ณ
*ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
function Bopen( cFileName, nAccMode )

default nAccMode to FO_READ // default access mode is Read Only

nHandle := fopen( cFileName, nAccMode )
cLineBuffer := ''
lFullBuff := .t.
nTotBytes := 0
lIsOpen := .t.

return ( nHandle != -1 )

*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
*ณ Function BReadLine()                                         ณ
*ณ Return:   The next line of the file read buffer              ณ
*ณ Assumes:  The file pointer will be left as last positioned   ณ
*ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
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

*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
*ณ Function BDisk2Buff()                                        ณ
*ณ Return:   .t. if there was no read error                     ณ
*ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
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

*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
*ณ Function BEof()                                              ณ
*ณ Return:   TRUE  if End of buffered file                      ณ
*ณ           FALSE if not                                       ณ
*ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
Function BEof()

Return !lFullBuff .and. len( cLineBuffer ) == 0

*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
*ณ Function BClose()                                            ณ
*ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
Function BClose()

if lIsOpen
   fclose( nHandle )
   lIsOpen := .f.
endif

Return FError()

*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
*ณ Function BPosition()                                         ณ
*ณ Returns the position of virtual file pointer                 ณ
*ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
Function BPosition()

Return nTotBytes
