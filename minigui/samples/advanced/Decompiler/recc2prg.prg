/*
 * .C (PCODE) to .Prg  Harbour Recover Code
 *
 * Copyright 2008-2009 Arcangelo Molinaro <arcangelo.molinaro@fastwebnet.it>
 * Donated to Public Domain.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

#include "fileio.ch"

#ifndef __XHARBOUR__
   #xtranslate At(<a>,<b>,[<x,...>]) => hb_At(<a>,<b>,<x>)
#endif

Function decode_c2prg(cFilename)  // *.c file (PCODE)
Local cStringa:="",aReturn:={}
Local cNewFilename:=BEFORATNUM(".",cFilename,1)+".dhr"
Local nHandle:=0,i:=0,k:=0,lMode:=.t.,aFunctionName:={},nMode:=-1
Local nLen:=0,aMacroCode:={},aFunctionCode:={}
Local cFuncCode:=""
 IF FILE(cNewFilename)
     DELETE FILE(cNewFilename)
 ENDIF
 IF ((nHandle:=FCREATE(cNewFilename,FC_NORMAL))==-1)
     MsgInfo("File cannot be created !","Exit Procedure")
     return nil
 ENDIF
 IF !(FCLOSE(nHandle))
     MsgInfo("File cannot be closed !","Exit Procedure")
     return nil
 ENDIF
 aReturn:=dcp_load_Data(cFilename)
 aReturn:=dcp_split_code(aReturn,cNewFileName)
return nil


function dcp_load_Data(cFilename)
Local cStringa:=""
Local cNewString:="" ,cFuncName:="",nLen:=0
Local i:=0,aSFuncName:={},aLFuncName:={},aReturn:={},k:=0,j:=0
Local aCode:={},nResult:=-1, nStart:=0,aParam:={},nEnd:=0,lOneTime:=.T.
Local nTotalVar:=0,nParam:=0,aVar:={},aWFuncName:={},aGlobalVar:={}
cStringa:=MEMOREAD(cFileName)
WHILE .T.
 if !empty(cStringa)
   IF lOneTime
     nStart:=AT("HB_FUNC(",cStringa)
     nEnd:=AT(")",cStringa,nStart)
     cFuncName:=ALLTRIM(Substr(cStringa, nStart,nEnd-nStart))
     lOneTime:=.F.
   ELSE
       cFuncName:=alltrim(BEFORATNUM(";",cStringa,1))
   ENDIF
     cNewString:=alltrim(AFTERATNUM(";",cStringa,1))
   if left(cFuncName,8)="HB_FUNC("
     cFuncName:=alltrim(ATREPL("HB_FUNC(",cFuncName,""))
     cFuncName:=alltrim(ATREPL(")",cFuncName,""))
     AADD(aSFuncName,cFuncName)
   elseif left(cFuncName,15)="HB_FUNC_STATIC("
     cFuncName:=alltrim(ATREPL("HB_FUNC_",cFuncName,""))
     cFuncName:=alltrim(ATREPL("(",cFuncName,""))
     cFuncName:=alltrim(ATREPL(")",cFuncName,""))
     AADD(aSFuncName,cFuncName)
   elseif left(cFuncName,15)="HB_FUNC_EXTERN("
     cFuncName:=alltrim(ATREPL("HB_FUNC_EXTERN(",cFuncName,""))
     cFuncName:=alltrim(ATREPL(")",cFuncName,""))
     AADD(aLFuncName,cFuncName)
   elseif left(cFuncName,8)="HB_FUNC_"            // _INITLINES()
     cFuncName:=alltrim(ATREPL("HB_FUNC",cFuncName,""))
     AADD(aSFuncName,cFuncName)
   endif
   cStringa:=cNewString
 else
    exit // FINE STRINGA
 endif
END
aCode:=dcp_load_array(cFileName)[1]
nStart:=0
I:=0
nLen:=LEN(aCode)  //# of function in original source code
 FOR i= 1 TO nLen
   nResult:=1
   if aCode[i][nResult]==13  //MUST BE ALWAYS THE FIRST PCODE IF VAR/PAR EXIST
     aadd(aParam,{aCode[i][nResult+1],aCode[i][nResult+2]}) // # of var/param.each source func.
     nTotalVar:=aCode[i][nResult+1]+aCode[i][nResult+2]
     nParam:=aCode[i][nResult+2]
     aVar:=array(nTotalVar) // # of total var+param
      for j:=1 to  nTotalVar
            if j <= nParam
                aVar[j]:="Par"+alltrim(str(j))
            else
                aVar[j]:="Var"+alltrim(str(j))
            endif
      next j     
      aadd(aGlobalVar,Avar)
      aVar:={}
   else
     aadd(aParam,{0,0}) // No var/Param     
     aadd(aGlobalVar,Avar)
   endif
 next i
i:=0
k:=0
aWFuncName:=ACLONE(aSFuncName)
 for i=1 to nLen
   cStringa:=""
    if aParam[i][2]>0
      for k:=1 to aParam[i][2]
        if  k<>aParam[i][2]
          cStringa:=cStringa+"Par"+alltrim(str(k))+","
        else
          cStringa:=cStringa+"Par"+alltrim(str(k))+")"
        endif
      next k                         
     if !empty(aWFuncName[i])
       if left(aWFuncName[i],6)="STATIC"
         aWFuncName[i]:="Static Function "+alltrim(substr(aWFuncName[i],7,len(aWFuncName)))+"("+cStringa
       else
         aWFuncName[i]:="Function "+aWFuncName[i]+"("+cStringa
       endif
     endif
    else
     if !empty(aWFuncName[i])
      if left(aWFuncName[i],6)="STATIC"
        aWFuncName[i]:="Static Function "+alltrim(substr(aWFuncName[i],7,len(aWFuncName)))
      else
        aWFuncName[i]:="Function "+aWFuncName[i]
      endif
     endif
    endif
  next i
aadd(aReturn,aSFuncName)  // source name function
aadd(aReturn,aLFuncName)  // function name EXTERN (*.OBJ or *.LIB)
aadd(aReturn,aWFuncName)  // Formatted String for print HEAD FUNCTION
aadd(aReturn,aCode)       // array of PCODE for each single function
aadd(aReturn,aGlobalVar)  // array of var/par for each single function
RETURN aReturn

function dcp_load_array(cFilename)
Local aCode:={},cStringa:="",nPos:=0
Local cGlobalString:="",aTemp:={},nStart:=0,cTempString:=""
cGlobalString:=memoread(cFilename)
while .t.
 nPos:=AT("pcode[] =",cGlobalString,nStart)
 if nPos=0 .AND. empty(aCode)
    Msginfo("Not a valid Harbour 'c'pcode source","Trace Message")
    return nil
 elseif nPos=0 .AND. !empty(aCode)
        exit   // End of Array
 else
   nPos:=nPos+10
   cTempString:="pcode[] ="+alltrim(AFTERATNUM("pcode[] =",cGlobalString,2))
   cGlobalString:=alltrim(substr(cGlobalString,nPos,len(cGlobalString)))
   cGlobalString:=alltrim(ATREPL(chr(13),cGlobalString,""))
   cGlobalString:=alltrim(ATREPL(chr(10),cGlobalString,""))
   cGlobalString:=alltrim(ATREPL(chr(9),cGlobalString,""))
   cGlobalString:=alltrim(ATREPL("{",cGlobalString,""))
   cGlobalString:=alltrim(ATREPL("  ",cGlobalString,""))
   cGlobalString:=alltrim(ATREPL(" ",cGlobalString,""))
   cGlobalString:=alltrim(BEFORATNUM("}",cGlobalString,1))
   if empty(cGlobalString)
      Msginfo("All function were processed !","Trace Message")
      exit
   endif
 endif
 if !empty(cGlobalString)
    AADD(aCode,dcp_str2arr(cGlobalString,","))
 endif
 cGlobalString:=cTempString
 cTempString:=""
end
aadd(aTemp,aCode)
aadd(aTemp,cFilename)
return (aTemp)

static function dcp_str2arr( cList, cDelimiter )
LOCAL nPos
LOCAL aList := {}
LOCAL nlencd:=0
LOCAL asub
DO CASE
 CASE VALTYPE(cDelimiter)=='C'
   cDelimiter:=if(cDelimiter==NIL,",",cDelimiter)
   nlencd:=len(cdelimiter)
   DO WHILE ( nPos := AT( cDelimiter, cList )) != 0
       AADD( aList, VAL(SUBSTR( cList, 1, nPos - 1 )))
      cList := SUBSTR( cList, nPos + nlencd )
   ENDDO
    AADD( aList, VAL(cList) )
 CASE VALTYPE(cDelimiter)=='N'
   DO WHILE len((nPos:=left(cList,cDelimiter)))==cDelimiter
      aadd(aList,nPos)
      cList:=substr(cList,cDelimiter+1)
   ENDDO
 CASE VALTYPE(cDelimiter)=='A'
   AEVAL(cDelimiter,{|x| nlencd+=x})
   DO WHILE len((nPos:=left(cList,nlencd)))==nlencd
      asub:={}
      aeval(cDelimiter,{|x| aadd(asub,left(nPos,x)),nPos:=substr(nPos,x+1)})
      aadd(aList,asub)
      cList:=substr(cList,nlencd+1)
   ENDDO
 ENDCASE
RETURN ( aList )


function dcp_split_code(aReturn,cNewFileName)
Local aGlobalCode:={},aCode:={},aSFuncName:={},aLFuncName:={}
Local aWFuncName:={},aGlobalVar:={},aTemp:={},aVar:={}
Local nLen:=0,i:=0,j:=0,aRowCode:={},nResult:=-1,nStart:=0,nLenCode:=0
Local cStringa:="",nLenRow:=0,nPCode:=0,nNextRow:=0,nJump:=0
Local aStack:={},nLenVar:=0,lDeclaration:=.T.,nAssignedVar:=0
Local aGlobalRowCode:={},aForNextStack:={},aSkipCode:={}
aSFuncName:=aReturn[1]
aLFuncName:=aReturn[2]
aWFuncName:=aReturn[3]
aGlobalCode:=aReturn[4]
aGlobalVar:=aReturn[5]
nLen:=LEN(aGlobalCode)
for j=1 to nLen
    aCode:=aGlobalCode[j]
    aVar:=aGlobalVar[j]
    nLenCode:=LEN(aCode)
    nLenVar:=LEN(aVar)
    nLenRow:=dcp_FindLastRow(aCode)
    aRowCode:=array(nLenRow)
    AFILL(aRowCode,NIL)
    aRowCode[1]:=aWFuncName[j]
    While .t.
      if i<nLenCode
        i:=i+1
         nPcode:=aCode[i]
         DO CASE
            CASE nPcode==51
               // da correggere
               aTemp:=dcp_f51(aCode,i)
               cStringa:=cStringa+aTemp[1]
               nJump:=aTemp[2]
               i:=nJump
            CASE nPcode==36
               //Dovrebbe sTampare stringa a nNextRow
               // e poi cambiare i valori con la nuova lettura
               // azzerando eventualmente cStringa:=""
               // OK FATTO - FUNZIONA ??!!

               aTemp:=dcp_f36(aCode,i,aRowCode,nNextRow,cStringa,lDeclaration)
               nJump:=aTemp[1]               
               if aTemp[2] >= nNextRow
                 nNextRow:=aTemp[2]
               else
                 nNextRow:=nNextRow+1
               endif
               aRowCode:=aTemp[3]
               cStringa:=aTemp[4]
               i:=nJump
               if (nAssignedVar==nLenVar)
                  lDeclaration:=.F.  //write source if .t. write declaration
               endif

            CASE nPcode==4
               aTemp:=dcp_f4(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump


            CASE nPcode==95
               aTemp:=dcp_f95(aCode,i,aStack,aVar)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==72
               aTemp:=dcp_f72(aCode,i,aStack,aVar)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump


            CASE nPcode==101
               aTemp:=dcp_f101(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==106
               aTemp:=dcp_f106(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==98
               altd()  // da correggere !!
               aTemp:=dcp_f98(aCode,i,aLFuncName)
               cStringa:=cStringa+aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==165
               aTemp:=dcp_f165(aCode,i,aStack,aVar,aRowCode,nNextRow,lDeclaration,aSkipCode)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               aRowCode:=aTemp[3]
               nNextRow:=aTemp[4]
               aSkipCode:=aTemp[5]
               i:=nJump

            CASE nPcode==93
               altd()   // da correggere
               aTemp:=dcp_f93(aCode,i,cStringa)
               cStringa:=cStringa+aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==92
               aTemp:=dcp_f92(aCode,i,aStack)
               nJump:=aTemp[1]
               aStack:=aTemp[2]
               i:=nJump

            CASE nPcode==97
               aTemp:=dcp_f97(aCode,i,aStack)
               nJump:=aTemp[1]
               aStack:=aTemp[2]
               i:=nJump

            CASE nPcode==13
               nJump:=i+2
               i:=nJump

            CASE nPcode==25
               aTemp:=dcp_f25(aCode,i,aVar,aStack,cStringa,lDeclaration)
               aStack:=aTemp[1]
               cStringa:=cStringa+aTemp[2]
               nJump:=aTemp[3]
               i:=nJump

            CASE nPcode==120
               aTemp:=dcp_f120(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==9
               aTemp:=dcp_f9(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==121
               aTemp:=dcp_f121(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==122
               aTemp:=dcp_f122(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==80
               aTemp:=dcp_f80(aCode,i,aVar,aStack,cStringa,lDeclaration)
               aStack:=aTemp[1]
               cStringa:=aTemp[2]
               nJump:=aTemp[3]
               nAssignedVar:=aTemp[4]
               i:=nJump

            CASE nPcode==2
               dcp_f2()

            CASE nPcode==175
               aTemp:=dcp_f175(aCode,i,aStack,aVar,aRowCode,nNextRow,aSkipCode)
               aRowCode:=aTemp[1]
               nNextRow:=aTemp[2]
               nJump:=aTemp[3]
               i:=nJump

            CASE nPcode==176
               aTemp:=dcp_f176(aCode,i,aLFuncName)
               cStringa:=cStringa+aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==100
               aTemp:=dcp_f100(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==110
               aTemp:=dcp_f110(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               cStringa:=aTemp[3]
               i:=nJump

            CASE nPcode==7
               aTemp:=dcp_f7(aRowCode,nNextRow,cStringa,i)
               aRowCode:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump
             OTHERWISE
                   Msginfo("PCODE : "+alltrim(str(aCode[i]))+CRLF+;
                   "Not yet coded","Trace Message")
        ENDCASE
      else
         exit   //end of array
      endif
    end
    i:=0
    aGlobalVar[j]:=aVar
    lDeclaration:=.t.
    aadd(aGlobalRowCode,aRowCode)
    aRowCode:={}
    cStringa:=""
next j
if(dcp_Write_Code(aGlobalRowCode,cNewFilename))
   DECLARE WINDOW DECOMPILER
   decompiler.RichEdit_2.value:=memoread(cNewFilename) //all was ok
 else
     MsgInfo("Error occurs writing file "+cNewFilename+CRLF+;
             "NEED CAREFULLY DEBUGGING !" ,"Trace Message decode_c2prg")
 endif
return aReturn

function dcp_Write_Code(aGlobalRowCode,cFilename)
Local nLenFunc:=LEN(aGlobalRowCode),cStringa:="",lMode:=.t.
Local aRigo:={},nLineToWrite:=0,i:=0,j:=0,nHandle,nError
 for i=1 to nLenFunc
   aRigo:=aGlobalRowCode[i]
   nLineToWrite:=LEN(aRigo)
     for j=1 to nLineToWrite
        if empty(aRigo[j])
           cStringa:=cStringa+CRLF
        else
          cStringa:=cStringa+aRigo[j]+CRLF
        endif
     next j
 next i
 if (nHandle:=Fopen(cFilename,FO_READWRITE))>0  // ok
    fseek(nHandle,0,FS_END)
    nError:=fwrite(nHandle,cStringa)
    IF nError==0
       MsgInfo("String cannot be written in file "+cFilename + " !"+CRLF+;
            "Error # : "+alltrim(str((nError))),"Trace Message")
       lMode:=.f.
    endif
 else
    MsgInfo("File "+cFilename + " cannot be opened !","Trace Message")
    lMode:=.f.
 endif
 IF !(FCLOSE(nHandle))
     MsgInfo("File cannot be closed !","Trace Message")
     lMode:=.f.
 ENDIF
return lMode


static function dcp_FindLastRow(aCode)
Local nLastRow:=0,nResult:=-1,nLen:=LEN(aCode),nStart:=nLen-15
 while .t.
 if nStart>1
   nResult:=ASCAN(aCode,36,nStart)
    if nResult > 0
      nLastRow:=aCode[nResult+1]+aCode[nResult+2]*256
      exit
    else
      nResult:=-1
      nStart:=nStart-15
    endif
 else
      Msginfo("No source code found","Trace Message in FindLastRow")
      exit
 endif
 end
return nLastRow


Static Function dcp_CheckVarType(xVar)
Local cStringa:="",xType:=""
IF VALTYPE(xVar)="C"
      cStringa:=xVar
      xType:="c"
ELSEIF VALTYPE(xVar)="N"
     cStringa:=ALLTRIM(STR(xVar))
     xType:="n"
ELSEIF VALTYPE(xVar)="L"
     IF (xVar, cStringa:=".T.",cStringa:=".F.")     
     xType:="l"
ELSEIF VALTYPE(xVar)="D"
     cStringa:=DTOC(xVar)
     xType:="d"
ELSEIF VALTYPE(xVar)="A"
     if (LEN(xVar)==1 .AND. empty(xVar[1]))
         cStringa:="{}"
     else
         cStringa:=xVar[1]
     endif
     xType:="a"
ENDIF
Return {cStringa,xType}

Static Function dcp_FormatVarType(xVar,lArrayEmpty)
Local cStringa:=""
IF VALTYPE(xVar)="C"
      cStringa:=xVar
ELSEIF VALTYPE(xVar)="N"
     cStringa:=ALLTRIM(STR(xVar))
ELSEIF VALTYPE(xVar)="L"
     IF (xVar, cStringa:=".T.",cStringa:=".F.")     
ELSEIF VALTYPE(xVar)="D"
     cStringa:=DTOC(xVar)
ELSEIF VALTYPE(xVar)="A"
     if (LEN(xVar)==1 .AND. empty(xVar[1]) .AND. lArrayEmpty=.t.)
         cStringa:="{}"
     else
         if Valtype(xVar[1])="C"
            cStringa:=xVar[1]
         elseif Valtype(xVar[1])="N"
            cStringa:=ALLTRIM(STR(xVar[1]))
         elseif Valtype(xVar[1])="D"
            cStringa:=DTOC(xVar)
         elseif Valtype(xVar[1])="L"
             IF (xVar[1], cStringa:=".T.",cStringa:=".F.")     
         elseif Valtype(xVar[1])="A"
              Msginfo("Nested array - Not yet coded","Trace message FormatVarType")
         endif
     endif
ENDIF
Return cStringa

static function dcp_f4(aCode,nIndex,aStack)
Local aReturn:={},nElements:=aCode[nIndex+1]+aCode[nIndex+2]*256
Local i:=0,aTemp:={},cTemp:="}",cStringa:="",nStack:=0,lArrayEmpty:=.T.
if nElements>0
 lArrayEmpty:=.F.
 for i= 1 to nElements
  aTemp:=dcp_pop_stack(aStack)
    if i==1
     cTemp:=alltrim(dcp_FormatVarType({aTemp[2]},lArrayEmpty))+cTemp
    elseif i<>nElements
      cTemp:=alltrim(dcp_FormatVarType({aTemp[2]},lArrayEmpty))+","+cTemp
    elseif i==nElements
     cTemp:="{"+alltrim(dcp_FormatVarType({aTemp[2]},lArrayEmpty))+","+cTemp
    endif
  aStack:=aTemp[1]
 next i
else
   cTemp:=""   // Empty array {}  
endif
cStringa:=cStringa+cTemp
aStack:=dcp_push_stack(aStack,{cStringa})
aadd(aReturn,aStack)
aadd(aReturn,nIndex+2)
return aReturn

static function dcp_f101(aCode,nIndex,aStack)
Local aReturn:={},nNumero:=0
nNumero:=RECOVER_DOUBLE(aCode[nIndex+1],+;
               aCode[nIndex+2],+;
               aCode[nIndex+3],+;
               aCode[nIndex+4],+;
               aCode[nIndex+5],+;
               aCode[nIndex+6],+;
               aCode[nIndex+7],+;
               aCode[nIndex+8],+;
               aCode[nIndex+9],+;
               aCode[nIndex+10])
aStack:=dcp_push_stack(aStack,nNumero)
aadd(aReturn,aStack)
aadd(aReturn,nIndex+10)
return aReturn



static function dcp_f95(aCode,nIndex,aStack,aVar)
Local aReturn:={},nVar:=aCode[nIndex+1]
Local cStringa:=aVar[nVar]
aStack:=dcp_push_stack(aStack,cStringa)
aadd(aReturn,aStack)
aadd(aReturn,nIndex+1)
return aReturn


static function dcp_f72(aCode,nIndex,aStack,aVar)
Local aReturn:={},xString1:="", xString2:="",aTemp:={}
aTemp:=dcp_pop_stack(aStack)
xString1:=aTemp[2]
aTemp:=dcp_pop_stack(aTemp[1])
xString2:=aTemp[2]
aStack:={}
aStack:=dcp_push_stack(aStack,":=")
aStack:=dcp_push_stack(aStack,xString2)
aStack:=dcp_push_stack(aStack,"+")
aStack:=dcp_push_stack(aStack,xString1)
aadd(aReturn,aStack)
aadd(aReturn,nIndex)
return aReturn

static function dcp_f175(aCode,nIndex,aStack,aVar,aRowCode,nNextRow,aSkipCode)
Local aReturn:={},cStringa:="",nRow:=0,aTemp:={},nSkipPcode:=0
Local nVar:=aCode[nIndex+1]+aCode[nIndex+2]*256
Local nPrint:=ASCAN(aCode,36,nIndex+1)
aTemp:=dcp_pop_stack(aSkipCode)
aSkipCode:=aTemp[1]
/*
nSkipStart:=aTemp[2][1]
nSkipEnd:=aTemp[2][2]
*/
nSkipPcode:=aTemp[2][2]-aTemp[2][1]
nRow:=aCode[nPrint+1]+aCode[nPrint+2]*256
if nRow<nNextRow
  nRow:=nNextRow
endif
cStringa:="NEXT "+ aVar[nVar]
aRowCode[nNextRow]:=cStringa
aadd(aReturn,aRowCode)
aadd(aReturn,nRow)
aadd(aReturn,nIndex+2+nSkipPcode)
return aReturn

static function dcp_f121(aCode,nIndex,aStack)
Local aReturn:={},nNumero:=0
aStack:=dcp_push_stack(aStack,nNumero)
aadd(aReturn,aStack)
aadd(aReturn,nIndex)
return aReturn


static function dcp_f122(aCode,nIndex,aStack)
Local aReturn:={},nNumero:=1
aStack:=dcp_push_stack(aStack,nNumero)
aadd(aReturn,aStack)
aadd(aReturn,nIndex)
return aReturn


static function dcp_f120(aCode,nIndex,aStack)
Local aReturn:={},lMode:=.T.
aStack:=dcp_push_stack(aStack,lMode)
aadd(aReturn,aStack)
aadd(aReturn,nIndex)
return aReturn

static function dcp_f9(aCode,nIndex,aStack)
Local aReturn:={},lMode:=.F.
aStack:=dcp_push_stack(aStack,lMode)
aadd(aReturn,aStack)
aadd(aReturn,nIndex)
return aReturn


static function dcp_f25(aCode,nIndex,aVar,aStack,cStringa,lDeclaration)
Local aReturn:={},nJump:=0,nToNumber:=0, nVar:=0,aTemp:={}
if aCode[nIndex-2]==80
     nVar:=aCode[nIndex-1]   // Var Number in FOR  cycle
endif
//****Start Code to read and store Second Operand in FOR cycle*********
nJump:=aCode[nIndex+1]
if nJump > 128   // Negative number
  nJump:=(256-aCode[nIndex+1])
endif
nToNumber:=aCode[nIndex+nJump+1]
aStack:=dcp_push_stack(aStack,nToNumber)
aStack:=dcp_push_stack(aStack,"TO")
//****End Code to read and store Second Operand in FOR cycle*********
aTemp:=dcp_f80(aCode,nIndex-2,aVar,aStack,cStringa,lDeclaration)
aadd(aReturn,aTemp[1])  // aStack
aadd(aReturn,aTemp[2])  // cNewString
aadd(aReturn,nIndex+1)  // nIndex
aadd(aReturn,aTemp[4])  // nVar
return aReturn


static function dcp_f165(aCode,nIndex,aStack,aVar,aRowCode,nNextRow,lDeclaration,aSkipCode)
Local aReturn:={},cVar:="",nJump:=0,cTemp:="",cStringa:="",nNewIndex:=0
Local nResult:=-1,nStart:=0,aTemp:={},nReadEnd:=0
if aCode[nIndex+1]==80 .AND. aCode[nIndex+3]==25
          nJump:=aCode[nIndex+4]  // jump to end of cycle.
          nReadEnd:=nIndex+4+nJump-1  //read next Pcode 36 to skip code control
          nResult:=ASCAN(aCode,36,nReadEnd)
          if nResult>0
            AADD(aSkipCode,{nReadEnd,nResult})
          endif
          if aCode[nReadEnd]==95
                cVar:=aVar[aCode[nIndex+4+nJump]]  
          elseif aCode[nReadEnd]==92
                cVar:=alltrim(dcp_FormatVarType({aCode[nReadEnd+1]},.t.))
          endif
          cTemp:=alltrim(dcp_FormatVarType({dcp_pop_stack(aStack)[2]},.t.))
          cStringa:="FOR "+aVar[aCode[nIndex+2]]+"="+cTemp+" TO "+cVar
          nStart:=nIndex-7
          nResult:=ASCAN(aCode,36,nStart)
          aTemp:=dcp_f36(aCode,nResult,aRowCode,nNextRow,cStringa,lDeclaration)
           nNextRow:=aTemp[2]+1
           aRowCode:=aTemp[3]
           cStringa:=aTemp[4]
           nStart:=nResult+1
           nResult:=-1
           nResult:=ASCAN(aCode,36,nStart) // next 36 > code to skip
           nResult:=nResult+2   //-> first code after for/next previous proc.
else
    Msginfo("dcp_f165->80,<>25 not yet improved function","Trace Message")
endif
aStack:={}
aadd(aReturn,aStack)
aadd(aReturn,nResult)
aadd(aReturn,aRowCode)
aadd(aReturn,nNextRow)
aadd(aReturn,aSkipCode)
return aReturn


static function dcp_f80(aCode,nIndex,aVar,aStack,cStringa,lDeclaration)
Local aReturn:={},nVar:=aCode[nIndex+1],aTemp:={},xReturn,aType:={}
Local cValue:="",xType,cNewString:=cStringa, nLastVar:=LEN(aVar)
Local aStringa:={}
// for i =1 to nLen aStack - deve riversare tutto il contenuto dello stack
// tener conto anche della lDeclaration - Se .t. = dichiarazione variabile
// se .f. manipolazione variabili nel source
if lDeclaration
 aTemp:=dcp_pop_stack(aStack)
 aStack:=aTemp[1]
 xReturn:=aTemp[2]
 aType:=dcp_CheckVarType(xReturn)  
 cValue:=aType[1]
 xType:=aType[2]
 If Empty(cNewString)
   cNewString:=xType+aVar[nVar]+":="+cValue+","
   aVar[nVar]:=xType+aVar[nVar]
 else
   cNewString:=cStringa+xType+aVar[nVar]+":="+cValue+","
   aVar[nVar]:=xType+aVar[nVar]
 endif
else
 while !empty(aStack)
   aTemp:=dcp_pop_stack(aStack)
   aStack:=aTemp[1]
   xReturn:=aTemp[2]
   aadd(aStringa,dcp_FormatVarType(xReturn,if(Valtype(xReturn)="A",.t.,.f.)))
 end
 cNewString:=dcp_mask_convert(aStringa,aVar,nVar,aCode,nIndex)
endif
aadd(aReturn,aStack)
aadd(aReturn,cNewString)
aadd(aReturn,nIndex+1)
aadd(aReturn,nVar)
return aReturn


static function dcp_f51(aCode,nIndex)
Local aReturn:={},cStringa:=""
Local i:=nIndex
 while .t.
   i:=i+1
   cStringa:=cStringa+CHR(aCode[i])
   if aCode[i]==0
     cStringa:=substr(cStringa,1,LEN(cStringa)-1)
     exit
   endif
 end
aadd(aReturn,cStringa)
aadd(aReturn,i)
return aReturn

static function dcp_f36(aCode,nIndex,aRowCode,nNextRow,cStringa,lDeclaration)
Local aReturn:={},nJump:=nIndex+2
Local nRow:=aCode[nIndex+1]+aCode[nIndex+2]*256
if (!empty(cStringa) .AND. lDeclaration = .t.)
     cStringa:="Local "+cStringa
endif
if nNextRow==0
  if (!empty(cStringa) .AND. alltrim(cStringa)<>"Local")
    aRowCode[nRow-1]:=substr(cStringa,1,LEN(cStringa)-1)
  endif
else
  if !empty(cStringa) .AND. lDeclaration=.T.
    aRowCode[nNextRow]:=substr(cStringa,1,LEN(cStringa)-1)
  elseif !empty(cStringa) .AND. lDeclaration=.F.
    aRowCode[nNextRow]:=cStringa
  endif
endif
cStringa:=""
aadd(aReturn,nJump)
aadd(aReturn,nRow)
aadd(aReturn,aRowCode)
aadd(aReturn,cStringa)
return aReturn

static function dcp_f106(aCode,nIndex,aStack)
Local aReturn:={},cStringa:=""
Local i:=0,nLen:=aCode[nIndex+1]
for i=nIndex+2 to nIndex+nLen+1
   cStringa:=cStringa+CHR(aCode[i])
next i
cStringa:=substr(cStringa,1,LEN(cStringa)-1)
aStack:=dcp_push_stack(aStack,cStringa)
i:=nIndex+nLen+1
aadd(aReturn,aStack)
aadd(aReturn,i)
return aReturn

static function dcp_f98(aCode,nIndex,aLFuncName)
Local aReturn:={},cStringa:=""
Local nFunction:=aCode[nIndex+1]+aCode[nIndex+2]*256
Local i:=nIndex+2
cStringa:=aLFuncName[nFunction]
aadd(aReturn,cStringa)
aadd(aReturn,i)
return aReturn

static function dcp_f93(aCode,nIndex,cStringa)
Local aReturn:={},nNumero:=0
nNumero:=aCode[nIndex+1]+aCode[nIndex+2]
cStringa:=cStringa+"["+alltrim(str(nNumero))+"]"
aadd(aReturn,cStringa)
aadd(aReturn,nIndex+2)
return aReturn

static function dcp_f92(aCode,nIndex,aStack)
Local aReturn:={},nNumero:=0
nNumero:=aCode[nIndex+1]
if nNumero>127  
   nNumero:=(256-nNumero)*(-1)  //Negative value
endif
aStack:=dcp_push_stack(aStack,nNumero)
aadd(aReturn,nIndex+1)
aadd(aReturn,aStack)
return aReturn

static function dcp_f97(aCode,nIndex,aStack)
Local aReturn:={},nNumero:=0
nNumero:=HB_MAKELONG (aCode[nIndex+1],+;
                      aCode[nIndex+2],+;
                      aCode[nIndex+3],+;
                      aCode[nIndex+4])
aStack:=dcp_push_stack(aStack,nNumero)
aadd(aReturn,nIndex+4)
aadd(aReturn,aStack)
return aReturn


static function dcp_f2()
return NIL


static function dcp_f100(aCode,nIndex,aStack)
Local aReturn:={},cReturn:="NIL"
aStack:=dcp_push_stack(aStack,cReturn)
aadd(aReturn,aStack)
aadd(aReturn,nIndex)
return aReturn

static function dcp_f110(aCode,nIndex,aStack)
Local aReturn:={},cStringa:="Return ",aTemp:={}
aTemp:=dcp_pop_stack(aStack)
aStack:=aTemp[1]
cStringa:=cStringa+aTemp[2]
aadd(aReturn,aStack)
aadd(aReturn,nIndex)
aadd(aReturn,cStringa)
return aReturn

static function dcp_f7(aRowCode,nNextRow,cStringa,nIndex)
Local aReturn:={}
 aRowCode[nNextRow]:=cStringa
aadd(aReturn,aRowCode)
aadd(aReturn,nIndex)
return aReturn


static function dcp_push_stack(aStack,xvariable)
Local aNewStack:=ACLONE(aStack)
 aadd(aNewStack,xVariable)
 aStack:=ACLONE(aNewStack)
return aStack


static function dcp_pop_stack(aStack)
Local aNewStack:={},xReturn:=NIL
Local nLen:=LEN(aStack),i:=0
if nLen<>0       // !empty array
  xReturn:=aStack[nLen]
  if nLen>2
    FOR i= 1 TO nLen-1
      aadd(aNewStack,aStack[i])  //
    NEXT I
  elseif nLen=2
      aadd(aNewStack,aStack[1])
  else
     //Msginfo("function dcp_pop_stack - aStack:={}","Trace Message")
  endif
//else
// nLen==0  ????? empty array
endif
return {aNewStack,xReturn}


static function dcp_toppush_stack(aStack,xvariable)
Local aTemp:={},nLen:=LEN(aStack)
Local i:=0
 aadd(aTemp,xVariable)  //xVariable at TOP of stack
 for i=1 to nLen
   aadd(aTemp,aStack[i])
 next i
 aStack:=ACLONE(aTemp)
return aStack


static function dcp_f176(aCode,nIndex,aLFuncName)
Local aReturn:={},nFunction,cStringa
nFunction:=aCode[nIndex+1]+aCode[nIndex+2]
cStringa:=aLFuncName[nFunction]
aadd(aReturn,cStringa)
aadd(aReturn,nIndex+2)
return aReturn


static function dcp_Mask_convert(aStringa,aVar,nVar,aCode,nIndex)
Local i:=0,cStringa:="",nLen:=LEN(aStringa),cStartNumber:=""
Local nPcodeFor:=aCode[nIndex-1]
If nPcodeFor==165
 for i=1 to  nLen
    DO CASE
        CASE aStringa[i]="FOR"
            cStringa:=aStringa[i]+" "+cStringa
        CASE aStringa[i]="="
            cStringa:=cStringa+aVar[nVar]+aStringa[i]
        CASE aStringa[i]="TO"
            cStringa:=cStringa+" "+aStringa[i]+" "
        OTHERWISE
           cStartNumber:=aStringa[i]
    ENDCASE
 next i
 cStringa:=cStringa+cStartNumber
else
 for i=1 to  nLen
   cStartNumber:=aStringa[i]+cStartNumber
 next i
 cStringa:=aVar[nVar]+cStartNumber
endif
return cStringa

#pragma BEGINDUMP
#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#define WINVER   0x0400
#include <windows.h>
#include <hbapiitm.h>

HB_FUNC (HB_MAKELONG)
{
  (hb_retnl) HB_MKLONG( hb_parni(1), hb_parni(2), hb_parni(3), hb_parni(4) );
}

HB_FUNC (HB_MAKESHORT)
{
  (hb_retnl) HB_MKSHORT( hb_parni(1), hb_parni(2));
}

#pragma ENDDUMP
