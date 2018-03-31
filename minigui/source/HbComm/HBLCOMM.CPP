#include "comm.h"
#include "hbcomm.h"
#include "stdio.h"

static  TCommPort Tcomm[ MAXOPENPORTS ];

/*int main()
{
char *szBuffer;
hb_init_port("COM2",57600,8,NOPARITY,ONESTOPBIT,4000);
hb_outbufclr();
if (hb_isworking())
   printf(" a porta abriu\n");
else
   printf(" a porta nÆo abriu\n");
   szBuffer= inchr(21);
hb_unint_port();
}
*/

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ //

BOOL hb_init_port(int nIdx, char * Nx_port,unsigned int Nbaud,BYTE Ndata,BYTE Nparity, BYTE Nstop,DWORD nBufferSize)
{
BOOL bReturn=TRUE;

Tcomm[ nIdx ].SetCommPort( Nx_port);
try {
   Tcomm[ nIdx ].OpenCommPort();
}
   catch(ECommError &e)  {
      if (e.Error == ECommError::OPEN_ERROR)
         bReturn=FALSE;
      }

Tcomm[ nIdx ].SetBaudRate( Nbaud);
switch (Nparity) {
case 0:
   Tcomm[ nIdx ].SetParity(NOPARITY);
   break;
case 1:
   Tcomm[ nIdx ].SetParity(ODDPARITY);
   break;

case 2:
   Tcomm[ nIdx ].SetParity(MARKPARITY);
   break;

case 3:
   Tcomm[ nIdx ].SetParity(EVENPARITY);
   break;

}

Tcomm[ nIdx ].SetByteSize(Ndata);

switch (Nstop) {
case 1 :
   Tcomm[ nIdx ].SetStopBits(0);
   break;
case 2:
   Tcomm[ nIdx ].SetStopBits(2);
   break;

default:
   Tcomm[ nIdx ].SetStopBits(1);
   break;

}
Tcomm[ nIdx ].dwBufferSize = nBufferSize;
return bReturn         ;
}

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ //

void hb_unint_port( int nIdx )
{
   Tcomm[ nIdx ].CloseCommPort();
}

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ //

void hb_outbufclr( int nIdx )
{
   Tcomm[ nIdx ].PurgeOCommPort();
}

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ //

BOOL hb_isworking( int nIdx )
{
   if (Tcomm[ nIdx ].GetConnected())
      return TRUE;
   else
      return FALSE;
}

int hb_outbufsize( int nIdx )
{
return   Tcomm[ nIdx ].BytesOAvailable();
}
int hb_inbufsize( int nIdx )
{
return   Tcomm[ nIdx ].BytesAvailable();
}

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ //

// char * hb_inchr(DWORD nBytes)
int hb_inchr( int nIdx, DWORD nBytes, char *buffer)    // EDR*7/03
{
// char *buffer = new char[nBytes];
// DWORD BytesRead = 0 ;

// BytesRead = Tcomm[ nIdx ].ReadBytes(buffer,nBytes);

  return Tcomm[ nIdx ].ReadBytes(buffer,nBytes);       // EDR*7/03

//   return buffer;

}

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ //

// BOOL hb_outchr(char *szString)
BOOL hb_outchr(int nIdx, char *szString, DWORD nBytes)  // EDR*7/03
{
// BOOL bReturn = FALSE;
   BOOL bReturn = TRUE;        // EDR*7/03
   try {

//      Tcomm[ nIdx ].WriteString(szString);
        Tcomm[ nIdx ].WriteBuffer( szString, nBytes );  // EDR*7/03

   }

   catch(ECommError &e)  {
      if (e.Error == ECommError::WRITE_ERROR)
         bReturn=FALSE;
      }

   return bReturn;
}
