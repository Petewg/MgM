/*

The Harbour interface routines for the HBCOMM library.  It is not clear who
produced the harbour routines to interface with Harold Howe's TCommPort
encapsulation.  Regardless, the Harbour interface has been modified to
allow for more than one port to be open (MAXOPENPORTS) compiled at 20 and
to allow for the sending and receiving of data containing NULL characters
(Chr(0)).

As a C/C++ coder, I make a fair plumber.  Anyone who wishes to clean-up my
code is welcome to do so.

    Ned Robertson
    XpertCTI, LLC
    Richmond, VA  USA
    July, 2003

*/


#include "hbapi.h"
#include "hbcomm.h"

static int aHandles[ MAXOPENPORTS ] ;   // assumes initialized to zeros
static int nHBase = 256 ;

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

HB_FUNC(INIT_PORT) /* Nx_port(string),Nbaud(numerico),Ndata(numerico),Nparity(numerico),Nstop(numerico),nBufferSize(numerico)
                   retorna .t. se abriu a porta */

/*  cPort, nBaudrate, nDatabits, nParity, nStopbits, nBuffersize

Main initiator/port opener.

   cPort may take either the form 'COMn' or the more general '\\.\COMn'
         The more general form is required for port numbers > 9.

   nParity codes: 0,1,2,3 -> none, odd, mark, even

   nStopBits codes: 0,1,2 -> 1, 1.5, 2

   Returns a "handle" >= 256.  A return of -1 means open failed.

   The handle must be used on all references to the port and is equivalent to
   nComm used in 16 bit Clipper/Fivewin routines.  All routines take the
   handle reference as their first argument.

*/

{

    int i = 0, n = -1, nHandle ;

    while ( n < 0 && i < MAXOPENPORTS ) {

       if ( aHandles[ i++ ] == 0 )

          n = i - 1 ;

    }

    if ( n != -1 ) {

       nHandle = nHBase++ ;

       aHandles[ n ] = nHandle ;

        if ( hb_init_port( n, (char *) hb_parc( 1 ) , hb_parnl( 2 ) ,
              hb_parnl( 3 ) , hb_parnl( 4 ) , hb_parnl( 5 ) ,
              hb_parnl( 6 ) ) )

           hb_retnl( nHandle ) ;

        else

           hb_retnl( 0 ) ;

    }

}

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

HB_FUNC( OUTBUFCLR )  // purge output buffer
{
    int nIdx ;

    nIdx = FindIndex( hb_parnl( 1 ) ) ;

    if ( nIdx != -1 ) {

       hb_outbufclr( nIdx )        ;

       hb_retl( TRUE ) ;

       }

    else

       hb_retl( FALSE ) ;


}

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

HB_FUNC( ISWORKING )  // See if port is opened correctly
{
    int nIdx ;

    nIdx = FindIndex( hb_parnl( 1 ) ) ;

    if ( nIdx != -1 )

        hb_retl( hb_isworking( nIdx ) );

    else

       hb_retl( FALSE ) ;

}

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

HB_FUNC( INCHR )  // fetch hb_parnl( 2 ) chars into hb_parc( 3 )
{

    int nIdx ;

    nIdx = FindIndex( hb_parnl( 1 ) ) ;

    if ( nIdx != -1 )

//        hb_retc( hb_inchr( nIdx, hb_parnl( 1 ) ) );
        hb_retnl( hb_inchr( nIdx, hb_parnl( 2 ), (char *) hb_parc( 3 ) ) );  // EDR*7/03

    else

       hb_retnl( 0 ) ;

}

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

HB_FUNC( OUTCHR )   // Send out characters.  Returns .t. if successful.
{

    int nIdx ;

    nIdx = FindIndex( hb_parnl( 1 ) ) ;

    if ( nIdx != -1 )

//        hb_retl( hb_outchr( hb_parc( 1 ) ) );
        hb_retl( hb_outchr( nIdx, (char *) hb_parc( 2 ), hb_parclen( 2 ) ) );  // EDR*7/03

    else

       hb_retl( FALSE ) ;

}

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

HB_FUNC( INBUFSIZE )      // Find out how many chars are in input buffer
{

    int nIdx ;

    nIdx = FindIndex( hb_parnl( 1 ) ) ;

    if ( nIdx != -1 )

        hb_retnl( hb_inbufsize( nIdx ) );

    else

       hb_retnl( 0 ) ;

}

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

HB_FUNC( OUTBUFSIZE )     // Find out how many characters are in out buf ?
{

    int nIdx ;

    nIdx = FindIndex( hb_parnl( 1 ) ) ;

    if ( nIdx != -1 )

        hb_retnl( hb_outbufsize( nIdx ) );

    else

       hb_retnl( 0 ) ;

}

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

HB_FUNC( UNINT_PORT )     // Close port and clear handle
{
    int nIdx ;

    nIdx = FindIndex( hb_parnl( 1 ) ) ;

    if ( nIdx != -1 ) {

       hb_unint_port( nIdx );

       aHandles[ nIdx ] = 0 ;

       hb_retl( TRUE ) ;

       }

    else

       hb_retl( FALSE ) ;
}

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

int FindIndex ( int nH )  // Convert "handle" to tcomm array index
{
    int i = 0, n = -1 ;

    while ( n < 0 && i < MAXOPENPORTS ) {

       if ( aHandles[ i++ ] == nH )

          n = i - 1 ;

    }

//  printf( "index= %8d\n", n );

   return n ;
}

// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 //

HB_FUNC( CHKIDX )         // For debugging - not normally used

{
    int nIdx ;

    nIdx = FindIndex( hb_parnl( 1 ) ) ;

    hb_retnl( nIdx );

}

