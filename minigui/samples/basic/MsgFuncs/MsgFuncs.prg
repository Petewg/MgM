#include <hmg.ch>

MEMVAR aTestData, aTstDTyps

PROCEDURE Main()

   aTestData := { "String-1", Random( 2^16 ), DATE(), .T.,;
                 { 'String-2', Random( 2^8 ), DATE() - Random( 2^5 ), .F. }, '' }

   aTstDTyps := { "Character", "Numeric", "Date", "Logical", "Array" }

   SET CENTURY ON
   SET DATE GERMAN

   LOAD WINDOW MsgFTsts 

   ON KEY ESCAPE OF MsgFTsts ACTION ThisWindow.Release()

   CENTER   WINDOW MsgFTsts
   ACTIVATE WINDOW MsgFTsts

RETURN // Main()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE ApplyMsg()

   LOCAL nMsgType  := MsgFTsts.cmbMsgTypes.Value,;
         nDataType := MsgFTsts.cmbDataTypes.Value

   LOCAL xData := aTestData[ nDataType ],;
         cDTyp := aTstDTyps[ nDataType ] + " type"

   SWITCH nMsgType
     CASE 1 // MsgBox
        MsgBox( xData, cDTyp )
        EXIT
     CASE 2 // MsgExclamation
        MsgExclamation( xData, cDTyp )
        EXIT
     CASE 3 // MsgInfo
        MsgInfo( xData, cDTyp )
        EXIT
     CASE 4 // MsgOkCancel
        MsgOkCancel( xData, cDTyp )
        EXIT
     CASE 5 // MsgRetryCancel
        MsgRetryCancel( xData, cDTyp )
        EXIT
     CASE 6 // MsgStop
        MsgStop( xData, cDTyp )
        EXIT
     CASE 7 // MsgYesNo
        MsgYesNo( xData, cDTyp)
        EXIT
     CASE 8 // MsgDebug
        MsgDebug( aTestData[ 1 ],;
                aTestData[ 2 ],;
                aTestData[ 3 ],;           
                aTestData[ 4 ],;
                aTestData[ 5 ] )
        EXIT
     CASE 9 // WhereIsIt
        SubLevel1()       
   END SWITCH
RETURN // ApplyMsg()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE SubLevel1()
   SubLevel2()
RETURN   
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE SubLevel2()
   SubLevel3()
RETURN   
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE SubLevel3()
   SubLevel4()
RETURN   
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE SubLevel4()
   SubLevel5()
RETURN   
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE SubLevel5()
   SubLevel6()
RETURN   
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE SubLevel6()
   SubLevel7()
RETURN   
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE SubLevel7()
   SubLevel8()
RETURN   
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE SubLevel8()
   SubLevel9()
RETURN   
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE SubLevel9()
   WhereIsIt() 
RETURN   
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROCEDURE WhereIsIt()
   MsgInfo ( ListCalledFunctions(), "Where Is It ?" )
RETURN   

*-----------------------------------------------------------------------------*
Function ListCalledFunctions( nActivation, aInfo )
*-----------------------------------------------------------------------------*
LOCAL cMsg := "", i := 1

   aInfo := {}
   nActivation := iif( ValType(nActivation) <> "N", 1, nActivation )

   DO WHILE !( ProcName(nActivation) == "" )
      AADD( aInfo, { ProcName(nActivation), ProcLine(nActivation), ProcFile(nActivation) } )
      cMsg += aInfo[i, 1] + "(" + hb_ntos(aInfo[i, 2]) + ") ("+ aInfo[i++, 3] + ")" + CRLF
      nActivation++
   ENDDO

Return cMsg
