#include <minigui.ch>

#define NTrim( n )   LTrim( TRAN( n,"999,999,999,999,999,999,999" ) )

#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ]                        ;
          =>                                                            ;
          IF <v1> == NIL ; <v1> := <x1> ; END                           ;
          [; IF <vn> == NIL ; <vn> := <xn> ; END ]


Set Procedure To GetDIRList

PROC Main()

   SET CENT ON
   SET DATE GERMAN

   LOAD WINDOW GetParams
   CENTER WINDOW GetParams
   ACTIVATE WINDOW GetParams
   
RETU // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
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
  
  History       :
  
                  7.2006 : First Release  

*/
PROC MsgMulty( xMesaj, cTitle, lEnum )

   LOCA cMessage := ""
    
   DEFAULT cTitle TO PROCNAME(1) + "\" + NTrim( PROCLINE(1) ),;
           lEnum  TO .F.
          
      
   IF VALTYPE( xMesaj  ) # "A"
      xMesaj := { xMesaj }
   ENDIF
   
   AEVAL( xMesaj, { | x1, i1 | cMessage +=  IF(lEnum, PADL( i1, 4 ) + "° ", "" ) + Any2Strg( x1 ) + CRLF } )
   
   MsgInfo( cMessage, cTitle )
      
   
RETU //  MsgMulty()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*
    f.Any2Strg() : Covert any type data to string
    
    Syntax       : Any2Strg( <xAny> ) -> <cString>
    
    Argument     : <xAny> : A value in any data type
    
    Return       : <cString> : String equivalent of <xAny>
    
    History      :
    
                   7.2006 : First Release  
       
*/

FUNC Any2Strg( xAny )

   LOCA cRVal  := '???',;
        nType,;
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
          
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
