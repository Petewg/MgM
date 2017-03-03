/*
 * Harbour TTimer Class v1.0
 * Copyright 2007 P.Chornyj <myorg63@mail.ru>
 *
 * Last revision 18.09.2007
 *
*/

ANNOUNCE CLASS_TTIMER

#include "common.ch"
#include "hbclass.ch"

#define UNDECLARED

/* ------------------------- CLASS TIMER ---------------------- */
CLASS TTimer

PROTECTED:
   CLASSDATA aTimers    INIT {}

   DATA Name            INIT ""
   DATA ID              INIT 0
   DATA lEnabled        INIT FALSE
   DATA nInterval       INIT 500
   DATA pTimerProc      INIT NIL 
   DATA WndHandle       INIT Nil   //0

EXPORTED:
   DATA cargo           INIT NIL

   ACCESS Interval 
   ASSIGN Interval( n ) INLINE ::Interval( n )

   METHOD Init( nHandle, nInterval, bBlock, lStart ) CONSTRUCTOR
   DESTRUCTOR Destroy 

   METHOD Enabled()     INLINE ::lEnabled    
   METHOD ExecTimerProc( hWnd, Msg, TimerId, Time )
   METHOD OnTimer( b ) 
   METHOD Start()
   METHOD Stop()

//   UNDECLARED METHOD ClassName()  INLINE ( "TTimer" )
   UNDECLARED METHOD GetById( nId ) 
   UNDECLARED METHOD GetByName( sName ) 
   UNDECLARED METHOD ObjectName() INLINE ::Name
ENDCLASS

/*
*/
METHOD Init( nHandle, nInterval, bBlock, lStart ) CLASS TTimer

   DEFAULT nInterval TO 500
   DEFAULT lStart    TO FALSE
   
   ::Name := "Timer_" + AllTRim( Str( _GetId() ) )
   ::WndHandle  := nHandle
   ::nInterval  := nInterval

   IF ( Hb_IsBlock ( bBlock ) )
      ::pTimerProc := bBlock
   ENDIF

   IF lStart
      ::Start()
   ENDIF

   //register object
   AAdd( ::aTimers, @Self )
RETURN Self

/*
*/
PROCEDURE Destroy() CLASS TTimer
LOCAL nPos := 0
LOCAL TimerName := ::Name

   ::Stop()

   nPos := AScan( ::aTimers, { |o| o:Name == TimerName } )
   IF nPos <> 0  
      ADel( ::aTimers, nPos ) 
      ASize( ::aTimers, Len( ::aTimers ) - 1 )
   ENDIF
RETURN 

/*
*/
METHOD Start() CLASS TTimer
LOCAL lTimerProc := Hb_IsBlock( ::pTimerProc ) 

   IF ( !::lEnabled )
                 ::ID := _GetId() 

      IF ( Hb_IsNil( ::WndHandle ) )
         ::ID := _InitTimer( ::WndHandle, ::ID, ::nInterval, lTimerProc )
      ELSE
         _InitTimer( ::WndHandle, ::ID, ::nInterval, lTimerProc )               
      ENDIF

      ::lEnabled := TRUE
   ENDIF   
RETURN Self

/*
*/
METHOD Stop() CLASS TTimer

   IF ::lEnabled
      _KillTimer( ::WndHandle, ::ID )

      ::lEnabled := FALSE
   ENDIF
RETURN Self

/*
*/
METHOD Interval( nValue ) CLASS TTimer
LOCAL nOldValue := ::nInterval

   IF ( ( PCOUNT() > 0 ) .AND. Hb_IsNumeric( nValue ) )
      ::Stop()
      ::nInterval := nValue
      ::Start()
   ENDIF
RETURN nOldValue

/*
*/
METHOD OnTimer( b ) CLASS TTimer
LOCAL pOldProc := ::pTimerProc

   IF ( ( PCOUNT() > 0 ) .AND. Hb_IsBlock( b ) )
      ::Stop()
      ::pTimerProc := b
      ::Start()
   ENDIF
RETURN pOldProc

/*
*/
METHOD ExecTimerProc( ... )

   IF ( Hb_IsBlock( ::pTimerProc ) )
      Hb_ExecFromArray( ::pTimerProc, { ... } )
   ENDIF
RETURN Self

/*
 UTILYZE
*/
METHOD GetById( nTimerId ) CLASS TTimer
LOCAL oResult := NIL, nPos := 0

   IF Hb_IsNumeric( nTimerId ) .AND. ( ( nPos := AScan( ::aTimers, {|o| o:ID == nTimerId } ) ) > 0 )
      oResult := ::aTimers[ nPos ]      
   ENDIF
RETURN oResult

METHOD GetByName( sName ) CLASS TTimer
LOCAL oResult := NIL, nPos := 0

   IF Hb_IsString( sName ) .AND. ( ( nPos := AScan( ::aTimers, {|o| o:Name == sName } ) ) > 0 )
      oResult := ::aTimers[ nPos ]   
   ENDIF
RETURN oResult

/* ---------------------- END CLASS TIMER --------------------- */

/*
 (TIMERPROC) _OnTimerEvents  
*/

PROCEDURE _OnTimerEvents( hWnd, Msg, TimerId, Time )
LOCAL T := TTimer():GetById( TimerId )

   IF Hb_IsObject( T )
      T:ExecTimerProc( hWnd, Msg, TimerId, Time )
   ENDIF
RETURN 

/* ------------------------------------------------------------ */
#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "item.api"
#include "hbvm.h"
#include "hbstack.h"

static PHB_SYMB pSymbolEvents = 0;

VOID CALLBACK TTimerProc( HWND, UINT, UINT_PTR, DWORD );

/*
*/
HB_FUNC ( _INITTIMER )
{
   if ( hb_parl( 4 ) )
   {     
   hb_retni( SetTimer ( (HWND) hb_parnl(1), (UINT) hb_parni(2), 
                        (UINT) hb_parni(3),          
                        (TIMERPROC) TTimerProc)) ;  
   }       
   else
      hb_retni( SetTimer ( (HWND) hb_parnl(1), (UINT) hb_parni(2), 
                   (UINT) hb_parni(3),          
                        (TIMERPROC) NULL)) ;  
}

/*
*/
HB_FUNC ( _KILLTIMER )
{
   hb_retni( KillTimer( (HWND) hb_parnl(1), (UINT) hb_parni(2) ) );
}

/*
*/
VOID CALLBACK TTimerProc( HWND hWnd, UINT uMsg, UINT_PTR idEvent, DWORD dwTime)
{
   if ( ! pSymbolEvents )
      pSymbolEvents = hb_dynsymSymbol( hb_dynsymGet( "_ONTIMEREVENTS" ) );

   if ( pSymbolEvents )
   {
      hb_vmPushSymbol( pSymbolEvents );
      hb_vmPushNil();
      hb_vmPushLong( ( LONG ) hWnd );
      hb_vmPushLong( uMsg );
      hb_vmPushLong( idEvent );
      hb_vmPushLong( dwTime );        // TODO
      hb_vmDo( 4 );
   }
}

#pragma ENDDUMP