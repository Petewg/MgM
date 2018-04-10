/*
 * Proyecto: Debug
 * Fichero: Debug.ch
 * Descripción: Commands for var tracing using Win32 debug functionality, as
 * pro vided by xEdit, dBWin32, etc
 * Autor: Carlos Mora
 * Fecha: 23/03/2007
 */


#ifdef __NODEBUG__

   #xcommand DEBUG <cString1>[, <cStringN>] =>
   #xcommand DEBUGMSG <cString1>[, <cStringN>] =>

#else

   #translate ASSTRING( <x> ) => If( <x> == NIL, 'NIL', Transform( <x> , NIL ) )
   #xcommand DEBUG <cString1>[, <cStringN>] ;
         => ;
          WAPI_OutputDebugString( ProcName() +"("+LTrim(Str(ProcLine())) +") - " + <"cString1"> + " ("+ValType( <cString1> )+"): " + ASSTRING( <cString1> ) + HB_OSNewLine() ) ;
          [ ; WAPI_OutputDebugString( ProcName() +"("+LTrim(Str(ProcLine())) +") - " + <"cStringN">+" ("+ValType( <cStringN> )+"): " + ASSTRING( <cStringN> ) + HB_OSNewLine() ) ]

   #xcommand DEBUGMSG <cString1>[, <cStringN>] ;
         => ;
          WAPI_OutputDebugString( ProcName() +"("+LTrim(Str(ProcLine())) +"): " + ASSTRING( <cString1> ) + HB_OSNewLine() ) ;
          [ ; WAPI_OutputDebugString( ProcName() +"("+LTrim(Str(ProcLine())) +"): " + ASSTRING( <cStringN> ) + HB_OSNewLine() ) ]

#endif
