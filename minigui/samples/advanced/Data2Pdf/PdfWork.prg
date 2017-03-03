/*
MINIGUI - Harbour Win32 GUI library Demo

Copyright 2007 Pierpaolo Martinello <pier at bmm.it>

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
   (or visit the web site http://www.gnu.org/).

   Parts of this project are based upon:

   FileStr, StrFile Borrowed from xHarbour

   MINIGUI
   Harbour MiniGUI: Free xBase Win32/GUI Development System
   (c) 2002-2007 Roberto Lopez
   Mail: harbourminigui@gmail.com
   Web: http://harbourminigui.googlepages.com

   (c) 2007 Pierpaolo Martinello <pier at bmm.it>
   PdFWork.Prg donated to public domain
*/


#include 'minigui.ch'

DECLARE WINDOW F1
*------------------------------------------------------------------------------*
Function PdfWork(filename,fileout,DbSource)
*------------------------------------------------------------------------------*
local rt :=.t.,handle
local lcnt := 0
default fileout to filename+"_1.pdf"
//SET DATE ITALIAN //BRITISH
SET CENT ON
SET EPOCH TO 1950
SET SCORE OFF
SET CENTURY ON
*- check for file's existence
sele DBD
if used()
   lcnt:= ed_Data( Dbsource )
   if lcnt > 0
      sele 3
      delete for Field->UseIt = .f.
      pack
      PdfMerge(Filename, Fileout,"", lcnt)
   Endif
else
   rt := .F.
Endif
return rt
/*
*/
*-----------------------------------------------------------------------------*
Function PDFMERGE(cSource, cDestination, mSource, cnt)
*-----------------------------------------------------------------------------*
   Local lSuccess:= .F., TmpBuff:='', ErrFile := .f., mltp := .F., trimDest:=''
   Local esct := 0, destReport, scritti := 0, ak := 0, cVar, cVarStore, n, par
   Local aSrc := {}, aDs := {}, oDestination := Cdestination
   Default mSource to "External.txt"

   F1.StatusBar.Item(1):="Adding Data: Work in progress ..."
   cVar := FILESTR(cSource, MEMORY(1) *1024 -100)
   && Remove watermark
   cVar:=strtran(cvar,"Edited by Foxit Reader\rCopyright\(C\) by Foxit Software Company,2005-2006\rFor Evaluation Only.\r",Space(98))
   && Search  Token into Textmatrix definition
   Tokeninit(@cvar,"<<")
   do while (!tokenend())
      TmpBuff := tokennext (cVar)
      if "TextMatrix" $ TmpBuff
         ak := at("/OriginX",TmpBuff)
         if ! empty( substr(TmpBuff,1,ak ) ) .and. "#" $ TmpBuff
             TmpBuff := Substr(TmpBuff,at("/FontSize",TmpBuff),at("/LineFeed",TmpBuff)-at("/FontSize",TmpBuff )+1 )
             aadd( aSrc, TmpBuff )
         Endif
      endif
   enddo
   Tokenexit()  && Release "Token" Memory
/*
<</TextMatrix [1 0 0 1 281.372 772.46 ]/FontName (Helvetica)/FontSize 10 /Text (#1#)/CharColor 0 /CharSpace 0 /LineFeed 0 /HorzScale 100 /OriginX 281.372 /OriginY 772.46 /bChangeBox 0 /BoxWidth 16.45 >>endobj
"/FontSize 10 /Text ("+Field->+")/CharColor 16711680 /CharSpace 100.00 /
*/
   && Sort The Array
   asort (aSrc,,,{|x,y| val( substr( x,at( "#",x )+1 ,4 ) ) < val( substr( y,at( "#",y )+1,4 ) ) } )
   && make an unique definition
   ads := aclone( aSrc)
   For n = 1 to len(ads)-1
       if val( substr( ads[n],at( "#",ads[n] )+1 ,4 ) )= val( substr( ads[n+1],at( "#",ads[n+1] )+1,4 ) )
          ads[n]:= ""
       Endif
   next
   asize(aSrc,0)
   aeval( ads,{|x|if ( !empty( x ),aadd( aSrc,x ), nil ) } )
   asize(ads,0)
   //mchoice(aSrc)
   sele 3
   dbgotop()
   trimDest := substr(cDestination,1,at(".",cDestination)-1)
   Do while !eof()
      cVarStore := cvar
      sele 2
      dbgotop()
      esct ++
      Do while ! eof()
         if d2p->Token = SrcTk(asrc,d2p->Token)
            cVarStore := strtran(cvarStore,aSrc[D2P->token],&(D2P->REPLAWITH))
         Endif
         dbskip()
      enddo
      aadd(ads,TrimDest+"_"+Zaps(esct)+".Pdf")
      scritti := StrFile(cVarStore,ads[esct])
      if scritti < 0
         ErrFile:=.T.
      Endif
      sele 3
      dbskip()
   EndDo

   if !Errfile
      lSuccess := .t.
      if esct > 1 .and. File ("PDFTK.EXE")
         if msgYesNo("Do you want join into one Pdf?","PdfMerge Ok")
            cDestination := InputBox ( 'Enter the output Filename with full extension' , 'Output Filename', cDestination )
            //Join in1.pdf and in2.pdf into a new PDF, out1.pdf
            if !empty(cDestination)
               IF FILE(cDestination)
                  Ferase(cDestination)
               Endif
               par := TrimDest+"_*.pdf cat output "+ cDestination +" compress "
               EXECUTE FILE "PDFTK.EXE" PARAMETERS par MINIMIZE
               mltp := .t.
               inkey(1)
            Else
               cDestination := oDestination
               if Ferase(cDestination) = 0 .or. !file(cdestination)
                  Frename( ads[1],cDestination )
               Endif
            Endif
         Else
             if Ferase(cDestination) = 0 .or. !file(cdestination)
                Frename( ads[1],cDestination )
             Endif
         Endif
      else
         if Ferase(cDestination) = 0 .or. !file(cdestination)
            Frename( ads[1],cDestination )
         Endif
      Endif
      if msgYesNo("Written "+cDestination +" With "+ltrim(Str(scritti))+" Bytes."+IF(len(ads)> 1.and. !mltp,+CRLF+CRLF+"And warning, "+Zaps(len(ads)-1)+" "+TrimDest+"_?.Pdf files was created!",'') ;
         +CRLF+CRLF+"Do you want open "+Cdestination+" ?","PdfMerge Ok")
         EXECUTE FILE cDestination
      Endif
   else
     lSuccess := .F.
     msgStop("Writing of"+cDestination+ " Failed !","DataToPdf Merging Error...")
   Endif

   IF lSuccess
      F1.StatusBar.Item(1):= "DataToPdFmixer finished successfully !"
   ELSE
      F1.StatusBar.Item(1):= "DataToPdFmixer failed !"
   Endif

   inkey(1)
   if mltp
      aeval(ads,{|x|Ferase(x)})
   endif
   Return lSuccess
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION PROPER(interm)             //Created By Piersoft 01/04/95 KILLED Bugs!
*-----------------------------------------------------------------------------*
local c_1, outstring:='',capnxt:=''
do while chr(32) $ interm
   c_1:=substr(interm,1,at(chr(32),interm)-1)
   capnxt:=capnxt+upper(left(c_1,1))+right(c_1,len(c_1)-1)+" "
   interm:=substr(interm,len(c_1)+2,len(interm)-len(c_1))
enddo
outstring=capnxt+upper(left(interm,1))+right(interm,len(interm)-1)
RETURN outstring
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Ed_data (udb)
*-----------------------------------------------------------------------------*
   Local aarq := {}, aStru := Dbstruct() , bcolor, rt := 0, oBrwd
   aadd(aarq, {'UseIT','L',1,0})
   aeval(aStru,{|x| aadd( aarq ,x)})
   DBSELECTAREA(3)
   if used()
      dbclosearea()
   Endif
   DbCreate("UseIt", aarq, "DBFNTX")
   sele 3
   use Useit exclusive
   append from &udb
/*
   Public _HMG_ActiveTBrowseName := ""
   Public _HMG_ActiveTBrowseHandle := 0
   Public _HMG_BeginTBrowseActive := .F.
*/
   DEFINE WINDOW Form_4 ;
   AT 100,50 ;
   WIDTH 500 HEIGHT 450 ;
   TITLE "Choice of record(s) to add for use" ;
   ICON 'ACROBAT.ICO' ;
   MODAL NOSIZE ;
   FONT "MS Sans Serif" SIZE 8

   dbgotop()

   DEFINE TBROWSE oBrwD AT 20,20 OF Form_4 CELLED ;
          WIDTH 450 HEIGHT 300  ;
          ON DBLCLICK (SetUseIt(oBrwd),oBrwD:Refresh())

          bColor := { || If( 3->UseIt, CLR_ORANGE, CLR_WHITE ) }

          oBrwD:LoadFields(.f.)
          oBrwD:nFreeze := 1

          oBrwD:nHeightCell += 1
          oBrwD:SetAppendMode( .F. )
          oBrwD:SetDeleteMode( .F., .T.)

          oBrwD:SetColor({ 1, 2 },{0,bcolor} ,1 )

   END TBROWSE

   @ 333,46 Label Lbl1 value "Double click on row for select it or.." WIDTH 180 HEIGHT 24

   @ 350,46  BUTTON Btn_1a CAPTION "&Select / Unselect" WIDTH 170 HEIGHT 24 ACTION (SetUseIt(.F.,.F.))
   
   @ 380,46  BUTTON Btn_1 CAPTION "&UnSelect all" WIDTH 80 HEIGHT 24 ACTION ( SetUseIt(.T.,.F.),oBrwD:Reset() )

   @ 380,136 BUTTON Btn_2 CAPTION "Select &all" WIDTH 80 HEIGHT 24 ACTION ( SetUseIt(.T.,.T.),oBrwD:Reset() )

   @ 365,226 BUTTON Btn_3 CAPTION "&Generate" WIDTH 80 HEIGHT 24 ACTION (rt:=HowRec(), if( rt > 0,ThisWindow.Release,(Form_4.oBrwD.setfocus,oBrwD:Reset() ) ) )
*/
   @ 365,316 BUTTON Btn_4 CAPTION "E&xit" WIDTH 80 HEIGHT 24 ACTION ThisWindow.Release

   END WINDOW
   oBrwD:Reset()
   Form_4.center
   Form_4.activate
   Return rt
/*
*/
*-----------------------------------------------------------------------------*
Proc SetUSeIt (alw,vl)
*-----------------------------------------------------------------------------*
local top:=.f.
default alw to .f.
default  vl to .f.
   if valtype(alw)=="L" .and. alw  = .t.
      replace 3->useit with vl ALL
      top :=.t.
   else
      3->useit := !Field->useit
   Endif
   dbcommit()
   if recno() = recc()
      _pushkey(VK_UP)
      _pushkey(VK_DOWN)
   else
      _pushkey(VK_DOWN)
      _pushkey(VK_UP)
   Endif
   if top
      dbgotop()
   Endif
   Form_4.Obrwd.setfocus
return
*/
*/
*-----------------------------------------------------------------------------*
Function HowRec ()
*-----------------------------------------------------------------------------*
local Rt
   SELE 3
   dbgotop()
   count to Rt for field->useit = .T.
   dbgotop()
Return rt
/*
*/
*-----------------------------------------------------------------------------*
Static Function SrcTk(afld,src)
*-----------------------------------------------------------------------------*
Local nret := 0
   nret := ascan(afld,{|x| Zaps(val( substr( x,at( "#",x )+1 ,4 ) ) )==  zaps(src)})
   If nret > 0
      nret := val ( substr( afld[nret],at( "#",afld[nret] )+1 ,4 ) )
   Endif
return  nret
*** END OF PRG
