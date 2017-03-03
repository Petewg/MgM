
#include "hmg.ch"

STATIC static_module := 33

FUNCTION MAIN

STATIC static_main := 32

LOCAL xxx

LOCAL a := {{{1,2}},3 }, nLine, cFileName


LOCAL hCustomers := { "CC001" => "Pierce Firth",;
                      "CC002" => "Stellan Taylor",;
                      "CC003" => "Chris Cherry",;
                      "CC004" => "Amanda Baranski" }

LOCAL hFruits := { "fruits" => { "apple", "chery", "apricot" } }
LOCAL hDays := { "days" => { "sunday", "monday" } } 
LOCAL hDoris := { "Doris" => { hFruits, hDays } }  


PRIVATE private_x := "X"

PRIVATE oDebugger := HMG_Debugger()

   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'Main Window' ;
      MAIN 

      ON KEY ALT+D ACTION HMG_ShowEventMonitor()

#xtranslate EDITBOX_INFO() => Form1.EditBox_1.Value := ;
                  "--- Vars  ---"   + hb_osNewLine() + VarInfo (HMG_Debugger():GetVars()) +;
                  "--- Stack ---"   + hb_osNewLine() + VarInfo (HMG_Debugger():GetProcStack()) +; 
                                      str (HMG_Debugger():nProcLevel) + hb_osNewLine() +;
                                      str (__dbgProcLevel()) + hb_osNewLine() +;
                                      ListCalledFunctions ()

Form1.TITLE := "Break Point 1"

      @ 10, 500 EDITBOX EditBox_1 ;
         WIDTH 400;
         HEIGHT 400;
         VALUE ""

   @ 100,350 BUTTON Button_1 CAPTION 'DBF' ACTION Test_DBF()

   @ 200,350 BUTTON Button_2 CAPTION 'Fill EditBox' ACTION EDITBOX_INFO()


NextRoutine()


Form1.TITLE := "Break Point 2"


for z = 1 TO 10
      b = z ^ 2
      c = b * 5
      d = c * 44 + 1
      e = d ^ 3 + 22
      IF z == 5
      //  MsgInfo ( z )
      ENDIF
      c = z * 3
next


ON KEY F3 ACTION  Test_Form()

ON KEY F7 ACTION FuncBP()

   END WINDOW

   SHOW WINDOW Form1
   
private_x := 'stop'
   
   CENTER WINDOW Form1

FuncBP()

   ACTIVATE WINDOW Form1

RETURN NIL



FUNCTION VarInfo(aVar)
LOCAL i, cAllVarInfo := ""
   FOR i := 1 TO Len (aVar)
      AAdd (aVar[i],"")
      cAllVarInfo += aVar[i,1] + space(3) + aVar[i,2] + space(3) + aVar[i,3] + space(3) + aVar[i,4] + space(3) + aVar[i,5] + hb_osNewLine()
   NEXT
RETURN cAllVarInfo + hb_osNewLine() 



PROCEDURE NextRoutine
    Form1.TITLE := "Next Routine"
    //MsgDebug ("NextRoutine")
RETURN


PROCEDURE FuncBP()
    Form1.TITLE := "Break Point Func"
    MsgDebug ("Func BP")
RETURN



PROCEDURE Test_Form()
   
   IF IsWindowDefined( Form2 )
      RETURN
   ENDIF
   
   DEFINE WINDOW Form2 ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'Test_Form'

   END WINDOW
    
  ACTIVATE WINDOW Form2
RETURN


*-----------------------------------------------------------------------------*
Function ListCalledFunctions (nActivation, aInfo)
*-----------------------------------------------------------------------------*
LOCAL cMsg := "", i:= 1
LOCAL nProcLine, cProcFile, cProcName
   aInfo := {}
   nActivation := IF (ValType(nActivation) <> "N", 1, nActivation) 
   DO WHILE .NOT.(PROCNAME(nActivation) == "")
      cProcName := PROCNAME(nActivation)
      nProcLine := PROCLINE(nActivation)
      cProcFile := PROCFILE(nActivation)
      AADD (aInfo, {cProcName, nProcLine, cProcFile})
      cMsg := cMsg + aInfo[i,1] + "(" + HB_NTOS(aInfo[i,2]) + ") ("+ aInfo[i,3] + ")" + HB_OSNEWLINE()
      nActivation++
      i++
   ENDDO
Return cMsg
