
#ifndef __HB_COMM_H__
#define __HB_COMM_H__
#define HB_OS_WIN_32_USED
#include "hbapi.h"
#include "windows.h"
#ifdef __cplusplus
extern "C"
{
#endif

extern BOOL hb_init_port( int nIdx, char * Nx_port,unsigned int Nbaud,BYTE Ndata,BYTE Nparity, BYTE Nstop,DWORD nBufferSize);
extern void hb_unint_port( int nIdx );
extern void hb_outbufclr( int nIdx );
extern int  hb_outbufsize( int nIdx );
extern BOOL hb_isworking( int nIdx );
extern int  hb_inchr( int nIdx, DWORD nBytes, char *buffer);
extern int  hb_inbufsize( int nIdx );
// extern BOOL hb_outchr(char *szString);
extern BOOL hb_outchr( int nIdx, char *szString, DWORD nBytes);  // EDR*07/03
extern int  FindIndex( int nH );

#ifdef __cplusplus
}
#endif
#endif

#define MAXOPENPORTS     20   // Maximum number of simultaneously open serial ports

