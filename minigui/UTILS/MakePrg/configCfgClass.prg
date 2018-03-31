/*****************************
* Source : configCfgClass.prg
* System : MyProject
* Author : Phil Ide
* Created: 14-May-2004
*
* Purpose: Subclass of the ConfigClass
* ----------------------------
* History:                    
* ----------------------------
* 14-May-2004 14:48:13 idep - Created
*
* ----------------------------
* Last Revision:
*    $Rev: 17 $
*    $Date: 2004-05-14 16:05:19 +0100 (Fri, 14 May 2004) $
*    $Author: idep $
*    
*****************************/

#include "common.ch"
#include "hbclass.ch"

#define CRLF Chr(13)+Chr(10)

CLASS ConfigCls
   EXPORTED:
      VAR imp
      VAR data

      METHOD init
      METHOD findHeader
      METHOD loadSection
ENDCLASS

METHOD ConfigCls:init(cFile)
   ::imp := MemoRead(cFile)
   return self

METHOD ConfigCls:findHeader()
   local i := At('[header]', lower(::imp))
   local cHead := ''

   if i > 0
      i += 10
      cHead := SubStr(::imp,i)
   endif
   return cHead

METHOD ConfigCls:loadSection(cSection)
   local cDef := ''
   local i
   local n
   local cTitle

   if Empty(cSection)
      if (i := At('[',::imp)) > 0 .and. (n := At(']',::imp)) > 0
         cSection := Substr(::imp,i,n-i)
      endif
   endif

   if !Empty(cSection)
      cSection := '['+lower(cSection)+']'
      cTitle := cSection+CRLF
      i := At(cSection, lower(::imp))

      if i > 0
         i += Len(cTitle)
         cDef := SubStr(::imp,i)

         if (i := At(CRLF+'[', cDef)) > 0
            cDef := Left( cDef,i-1 )
         endif
      endif
   endif
   return cDef

