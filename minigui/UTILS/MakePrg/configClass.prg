/*****************************
* Source : configClass.prg
* System : Tools/MakePrg
* Author : Phil Ide
* Created: 14-May-2004
*
* Purpose: Configuration class for MakePrg.exe
* ----------------------------
* History:                    
* ----------------------------
* 14-May-2004 12:34:53 idep - Created
*
* ----------------------------
* Last Revision:
*    $Rev: 17 $
*    $Date: 2004-05-14 16:05:19 +0100 (Fri, 14 May 2004) $
*    $Author: idep $
*    
*****************************/

#include "minigui.ch"
#include "hbclass.ch"

#ifndef __XHARBOUR__
   # xtranslate At( < a >, < b >, [ < x, ... > ] ) => hb_At( < a >, < b >, < x > )
#endif

CLASS Config
   EXPORTED:
      VAR aimp
      VAR data

      METHOD init
      METHOD write
      METHOD findHeader
      METHOD findDefault
      METHOD loadSection
      METHOD convertToInclude
      METHOD loadVars
      METHOD insertVars
      METHOD envVars
ENDCLASS

METHOD Config:init()
   local cFile := GetExeFileName()
   local cPath

   ::aimp := Array(3)
   ::data = ''

   cPath := ChangeFileExt( cFile, 'cfg' )

   ::aImp[1] := ConfigCls():new('makeprg.cfg')
   ::aImp[2] := ConfigCls():new(GetEnv('USERPROFILE')+'\Application Data\MakePrg\MakePrg.cfg')
   ::aImp[3] := ConfigCls():new(cPath)
   return self

METHOD Config:write(cFile, cMode, cMsg)
   local cHead
   local cSection
   local nH
   local aVars
   local cFData

   cHead := ::findHeader()

   if !Empty(cMode)
      if lower(cMode) == '/c'
         cSection := 'console'
      elseif lower(cmode) == '/g'
         cSection := 'graphics'
      endif
   endif

   default cSection to ::findDefault()
   cSection := ::loadSection(cSection)

   cSection := ::convertToInclude(cSection)

   aVars := ::loadVars('vars')
   cHead := ::insertVars( cHead, aVars, cFile, cMsg )

   cHead := StrTran( cHead, '$$INCLUDE$$', cSection )
   if hb_FileExists(cFile)
      cFData := MemoRead( cFile )
   endif
   if (nH := FCreate(cFile)) <> 0
      FWrite(nH, cHead)
      if !Empty(cFData)
         FWrite(nH, cFData)
      endif
      FClose(nH)
   endif
   return self

METHOD Config:findHeader()
   local cData := ''
   local i := 1

   While i < Len(::aImp) .and. Empty(cData)
      cData := ::aImp[i++]:findHeader()
   enddo
   return cData

METHOD Config:findDefault()
   local i
   local cDef := ::loadSection('default')

   if !Empty(cDef)
      if (i := At('mode=',cDef)) > 0
         cDef := SubStr(cDef,i+5)
         if (i := At(CRLF,cDef)) > 0
            cDef := Left(cDef,i-1)
         endif
      endif
   endif
   return cDef

METHOD Config:loadVars()
   local cData := ::loadSection('vars')
   local aRet := {}
   local i, v, n := 1
   local cTmp
   local cKey, cVal

   cData := ::aImp[1]:loadSection('vars')
   cData += ::aImp[2]:loadSection('vars')
   cData += ::aImp[2]:loadSection('vars')


   if !Empty(cData)
      if !(Right(cData,2) == CRLF)
         cData += CRLF
      endif

      While n <= Len(cData) .and. SubStr(cData,n,1) $ CRLF
         n++
      Enddo

      While (i := At(CRLF,cData,n)) > 0
         cTmp := SubStr(cData,n,i-n)
         if (v := At('=',cTmp)) > 0
            cKey := Left(cTmp,v-1)
            cVal := SubStr(cTmp,v+1)
            if AScan( aRet, {|e| lower(e[1]) == lower(cKey) } ) == 0
               aadd( aRet, { cKey, cVal })
            endif
         endif
         n := i+2
      Enddo
   endif
   return aRet


METHOD Config:loadSection(cSection)
   local cData := ''
   local i := 1

   While i < Len(::aImp) .and. Empty(cData)
      cData := ::aImp[i++]:loadSection(cSection)
   enddo
   return cData

METHOD Config:convertToInclude(cData)
   local i, n := 1
   local cRet := ''
   local cTmp

   if !(Right(cData,2)  == CRLF)
      cData += CRLF
   endif

   While n <= Len(cData) .and. SubStr(cData,n,1) $ CRLF
      n++
   Enddo

   While (i := At(CRLF,cData,n)) > 0
      cTmp := SubStr(cData,n,i-n)
      cRet += '#include "'+cTmp+'"'+CRLF
      n := i+2
   Enddo
   return cRet

METHOD Config:insertVars( cData, aVars, cFile, cMsg )
   local i

   default cMsg to ''

   cData := StrTran(cData, '$$FILE$$', cFile)
   cData := StrTran(cData, '$$DATE$$', CGIDate1())
   cData := StrTran(cData, '$$TIME$$', Left(Time(),5))
   cData := StrTran(cData, '$$DATETIME$$', SubStr(CGIDate2(),6))
   cData := StrTran(cData, '$$MESSAGE$$', cMsg)

   for i := 1 to Len(aVars)
      hb_SetEnv( aVars[i][1], aVars[i][2] )
      cData := StrTran(cData, '$$'+aVars[i][1]+'$$', '$$%'+aVars[i][1]+'%$$')
   next

   cData := ::envVars( cData )

   return cData

METHOD Config:envVars( cData )
   local i, n
   local cTmp
   local cVar
   local cValue

   altd()
   While (i := At('$$%', cData)) > 0 .and. (n := At('%$$', cData)) > 0
      cTmp := SubStr(cData, i, (n-i)+3)
      cVar := StrTran( cTmp, '$$%' )
      cVar := StrTran( cVar, '%$$' )
      cValue := GetEnv( cVar )
      cData := StrTran( cData, cTmp, cValue )
   Enddo
   return cData

STATIC Function CGIDate1()
   local cDate := CGIDate2()

   return SubStr(cDate,6,11)

STATIC Function CGIDate2( nSecs )
   local nDays
   local nTime := Seconds()
   local dDate := Date()
   local nDayLeft := 86400 - nTime
   local cRet

   default nSecs to 0

   if nSecs > 0
      nDays := Int(nSecs/86400)
      nSecs -= nDays*86400

      if nSecs > nDayLeft
         nDays++
         nSecs -= nDayLeft
      endif

      nTime += nSecs

      dDate += nDays
   endif

   cRet := Left(cDow(dDate),3)+', '
   cRet += StrZero(Day(dDate),2)+'-'+Left(CMonth(dDate),3)+'-'+LTrim(Str(Year(dDate)))+' '
   cRet += Secs2Time(nTime)
   return (cRet)

STATIC Function Secs2Time( n )
   local nHrs  := int(n/3600)
   local nMins
   local nSecs

   n := n%3600
   nMins := int(n/60)
   nSecs := n%60

   return StrZero(nHrs,2)+':'+StrZero(nMins,2)+':'+StrZero(nSecs,2)

Function Time2Secs( c )
   local nH := Val(left(c,2))
   local nM := Val(substr(c,4,2))
   local nS := if(len(c) == 8, Val(right(c,2)), 0 )
   local nRet

   nM *= 60
   nH *= 60
   nH *= 60

   nRet := nS+nM+nH
   return (nRet)

FUNCTION cFilePath( cPathMask )
   LOCAL cPath

   hb_FNameSplit( cPathMask, @cPath )

   RETURN Left( cPath, Len( cPath ) - 1 )

FUNCTION cFileNoExt( cPathMask )
   LOCAL cName

   hb_FNameSplit( cPathMask, , @cName )

   RETURN cName
