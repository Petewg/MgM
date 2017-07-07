/*

  MINIGUI - Harbour Win32 GUI library Demo
 
  Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com/
 
  MsgMulty is Freevare HMG Message function. 
  Accepts any type data values.
    
  Without changing and modifying any way, 
  using and distributing is totally free.

  All bug reports and suggestions are welcome.
    
  Developed under Harbour Compiler and 
  MINIGUI - Harbour Win32 GUI library (HMG). 
  
  Thanks to "Le Roy" Roberto Lopez.
 
  Copyright 2006 Bicahi Esgici <esgici@gmail.com>
 
  History :
  
     7.2006 : First Release
*/

/*
   
  p.MsgMulty()  : Display a message in any type data
  
  Syntax        : MsgMulty( <xMesaj> [, <cTitle> ] ) -> NIL
  
  Arguments     : <xMesaj> : Any type data value.
  
                             If <xMesaj> is an array, each element will display as 
                             a seperated line.
                             
                  <cTitle> : Title of message box. 
                             Default is calling module name and line number.
  
  Return        : NIL
  
  Uses          : Any2Strg()
  
*/

PROC MsgMulty( xMesaj, cTitle )

   LOCA cMessage := ""
    
   IF xMesaj # NIL
   
      IF cTitle == NIL
         cTitle := PROCNAME(1) + "\" + NTrim( PROCLINE(1) ) 
      ENDIF
      
      IF VALTYPE( xMesaj  ) # "A"
         xMesaj := { xMesaj }
      ENDIF
      
      AEVAL( xMesaj, { | x | cMessage += Any2Strg( x ) + CRLF } )
      
      MsgInfo( cMessage, cTitle, , .f. )
      
   ENDIF
   
RETU //  MsgMulty()

/*
    f.Any2Strg() : Covert any type data to string
    
    Syntax       : Any2Strg( <xAny> ) -> <cString>
    
    Argument     : <xAny> : A value in any data type
    
    Return       : <cString> : String equivalent of <xAny>
    
*/

FUNC Any2Strg( xAny )

   LOCA cRVal  := '???',;
        nType  ,;
        aCases := { { "A", { | | "{...}" } },;                
                    { "B", { | | "{||}" } },;                
                    { "C", { | x | x }},;
                    { "M", { | x | x   } },;                   
                    { "D", { | x | DTOC( x ) } },;             
                    { "L", { | x | IF( x,"On","Off") } },;    
                    { "N", { | x | NTrim( x )  } },;
                    { "O", { | | ":Object:" } },;
                    { "U", { | | "<NIL>" } } }
                    
   IF (nType := ASCAN( aCases, { | a1 | VALTYPE( xAny ) == a1[ 1 ] } ) ) > 0
      cRVal := EVAL( aCases[ nType, 2 ], xAny )
   ENDIF    
                   
RETU cRVal // Any2Strg()
