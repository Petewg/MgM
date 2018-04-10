/*
  Handy command from the FiveWin.ch file.
*/

#xcommand DEFAULT <uVar1> := <uVal1> ;
               [, <uVarN> := <uValN> ] => ;
                  <uVar1> := iif( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
                [ <uVarN> := iif( <uVarN> == nil, <uValN>, <uVarN> ); ]
