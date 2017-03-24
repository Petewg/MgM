//#include <common.ch>
#command    DEFAULT <Param1> TO <Def1> [, <ParamN> TO <DefN> ] ;
=> ;
<Param1> := IF(<Param1> == NIL,<Def1>,<Param1>) ;
[; <ParamN> := IF(<ParamN> == NIL,<DefN>,<ParamN>)]

#define PROGRAM 'Prenotazioni 1.1.0'
#define COPYRIGHT ' By P. C. M. Software, 2014'
#define LICENZA ' Free for use'
#TRANSLATE ZAPS(<X>) => ALLTRIM(STR(<X>))
#TRANSLATE NTRIM( n )=> LTrim( Str( n ) )
#TRANSLATE MSG       => MSGT
#DEFINE DRIVER  "DBFCDX"
#define NTRIM( n ) LTrim( Str( n ) )
#TRANSLATE Test( <c> ) => MsgInfo( <c>, [<c>] )
#define MsgInfo( c ) MsgInfo( c, "Informazione" )
#define MsgAlert( c ) MsgEXCLAMATION( c, "Attenzione" )
#define MsgStop( c ) MsgStop( c, "Stop!" )
#define MGSYS  .F.
#define COLOR_GRAYTEXT          17

