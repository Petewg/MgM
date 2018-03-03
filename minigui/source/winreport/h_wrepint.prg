// Created By Pierpaolo Martinello Italy
// Part of this Program is made by Bicahi Esgici <esgici@gmail.com>

#include 'minigui.ch'
#include 'winprint.ch'
#include 'miniprint.ch'
#include "hbclass.ch"
#include "BosTaurus.ch"

#include "hbwin.ch"
#include "hbzebra.ch"
#require "hbzebra"

#define MGSYS  .F.

#define MB_ICONEXCLAMATION 0x30
#define MB_OK 0
#define MB_ICONINFORMATION 64
#define MB_ICONSTOP 16
#define MB_OKCANCEL 1
#define MB_RETRYCANCEL 5
#define MB_SETFOREGROUND 0x10000
#define MB_SYSTEMMODAL 4096
#define MB_TASKMODAL 0x2000
#define MB_YESNO 4
#define MB_YESNOCANCEL 3

#ifndef __XHARBOUR__
   /* FOR EACH hb_enumIndex() */
   #xtranslate hb_enumIndex( <!v!> ) => <v>:__enumIndex()
#endif
#translate MSG	=> MSGBOX
#define NTrim( n ) LTRIM( STR( n,20, IF( n == INT( n ), 0, set(_SET_DECIMALS) ) ))
#translate ZAPS(<X>) => NTrim(<X>)
#translate Test( <c> ) => MsgInfo( <c>, [<c>] )
#define MsgInfo( c ) MsgInfo( c, , , .F. )
#define MsgAlert( c ) MsgEXCLAMATION( c, , , .F. )
#define MsgStop( c ) MsgStop( c, , , .F. )

memvar endof_file, separator, atf
memvar An_Vari, aend
memvar Atutto, Anext, Aivarpt, ActIva, nomevar
memvar _aFnt,ritspl,abort
memvar last_pag
memvar string1
memvar start
memvar LStep
memvar Cstep
memvar pagina
memvar format
memvar _money
memvar _separator
memvar _euro
memvar atr
memvar vsect
memvar epar
memvar vpar
memvar chblk,chblk2
memvar chkArg
memvar oneatleast, shd, sbt, sgh,insgh
memvar gcounter
memvar counter
memvar gcdemo
memvar grdemo

memvar align
memvar GHstring, GFstring, GTstring
memvar GField
memvar s_head, TTS
memvar s_col, t_col, wheregt
memvar gftotal, Gfexec, s_total
memvar nline
memvar nPag, nPgr, Tpg
memvar eLine, GFline
memvar maxrow, maxcol, mncl, mxH
memvar flob, mx_pg

memvar query_exp
memvar __arg1, __arg2
memvar xlwh,xfo,xfc,xbr,xpe,xwa,xbmp
memvar oWr
MEMVAR _HMG_HPDFDATA
/*
*/
*------------------------------------------------------------------------------*
Function WinRepInt(filename,db_arc,_NREC,_MainArea,_psd,_prw,drv)
*------------------------------------------------------------------------------*
Local ritorna:=.t., handle, n, n_var, x_exact := set(1)
Local str1:="", Vcb:='', lcnt:=0, a1:=0, a2:=0, al:=0, L1:=.F., L2:=.F.
Local _object_ := '', Linea, sezione, cWord
private endof_file
public SEPARATOR := [/], atf := ''
default db_arc to dbf(), _nrec to 0, _MainArea to ""
default _prw to .F. , drv to ""

SET( _SET_DELETED , TRUE )
SET CENTURY ON
// SET EPOCH TO Year(Date()) - 50

// init of object conversion
Public oWr   := WREPORT()
oWr:New()
oWr:argm     := {_MainArea,_psd,db_arc,_prw}
oWr:filename := filename
// Pdf
Public _HMG_HPDFDATA := Array( 1 )

if valtype(_nrec)== "C"
   atf :=_nrec
   oWr:nrec := 1
else
   oWr:nrec := _nrec
Endif

*- check for file's existence
if empty(filename) .or. !file(filename)
   _object_ := valtype(filename)
   msgstop([Warning...]+CRLF+[Report not found ]+IF(_object_=="C",': "'+Filename+'"','!')+CRLF+[The type of argument is: ]+_object_,'')
   ritorna:=.F.
ElseIf !file(filename)
   MsgT(2,[Warning...]+CRLF+[The file "]+FILENAME+[" not exist!!!],,"STOP")
   ritorna:=.F.
Endif
if ritorna
   *- open the file, check for errors
   handle := FOPEN(filename,64)
   If Ferror() <> 0
     msg("Error opening file : "+filename)
     ritorna := .F.
   Endif

   *- not at the end of file
   endof_file := .F.
Endif
if ritorna
   Private An_Vari  :={}, aend  :={}
   Private Atutto   :={},Anext    :={},Aivarpt  :={},ActIva:={} , nomevar:={}
   Private _aFnt    :={}

   Private string1  := ''
   Private start    := ''
   _object_         := ''
   Private LStep    := 25.4 / 6          // 1/6 of inch
   Private Cstep    := 0
   Private pagina   := 1
   Private Format   := {}
   Private _money   :=.F.
   Private _separator:=.T.           // Messo a vero per comodit‡ sui conti
   Private _euro    := .T.           // Messo a vero per l'Europa
   Private atr      :=.T.

   // valore := {|x|val(substr(x[1],at("]",x[1])+1))}

   *- for < of lines allowed in box

   do while !endof_file
      Linea := oWr:fgetline(handle)
      if left(linea,1)=="["
         sezione := [A]+upper(substr(linea,2,AT("]", linea)-2))
         oWr:aStat[ 'Define' ] := .F.
         oWr:aStat[ 'Head' ]   := .F.
         oWr:aStat[ 'Feet' ]   := .F.
         oWr:aStat[ 'Body' ]   := .F.
         //aadd(&sezione,linea)

         DO case
            case sezione == "ADECLARE"
                 oWr:aStat[ 'Define' ] := .T.

            case sezione == "AHEAD"
                 oWr:aStat[ 'Head' ]   := .T.

            CASE sezione == "ABODY"
                 oWr:aStat[ 'Body' ]   := .T.

            CASE sezione == "AFEET"
                 oWr:aStat[ 'Feet' ]   := .T.

            CASE sezione == "AEND"
                 oWr:aStat[ 'Head' ]   := .F.
                 oWr:aStat[ 'Feet' ]   := .F.
                 oWr:aStat[ 'Body' ]   := .F.

         EndCASE
      ElseIf left(linea,1) == "!"
          cWord := upper(left(linea,10))
          do case
             case cWord == "!MINIPRINT"
                  oWr:prndrv := "MINI"

             case cWord == "!PDFPRINT"
                  oWr:prndrv := "PDF"

             otherwise
                  oWr:prndrv := "HBPR"
          Endcase
          cWord := ''
      Endif
      Do case
         case Drv = "HBPR"
              oWr:prndrv := "HBPR"

         Case Drv = "MINI"
              oWr:prndrv := "MINI"

         Case Drv = "PDF"
              oWr:PrnDrv := "PDF"
      Endcase
      lcnt ++
      tokeninit(LINEA,";")       //set the command separator -> ONLY A COMMA /
      do While .NOT. tokenend()  //                             _____
         cWord := alltrim(tokennext(LINEA))
         //MSG(CWORD,[CWORD])
         _object_ := eval(oWr:aStat [ 'TrSpace' ], CWORD, .t., lcnt)
         // msg(cWord+crlf+_object_,[linea ]+str(lcnt))
         if left(CWORD,1) != "#" .or. left(CWORD,1) != "[" .and. !empty(trim(_object_))
            if !empty(_object_)
               a1 := at("FONT", upper(_object_))
               do case
                  CASE oWr:aStat[ 'Define' ] == .T.
                       aadd(oWr:ADECLARE,{_object_,lcnt})

                  CASE oWr:aStat[ 'Head' ] == .T.
                       aadd(oWr:aHead,{_object_,lcnt})

                  CASE oWr:aStat[ 'Body' ] == .T.
                       aadd(oWr:ABody,{_object_,lcnt})

                  CASE oWr:aStat[ 'Feet' ] == .T.
                       aadd(oWr:Afeet,{_object_,lcnt})
               endcase
            Endif
         Endif
      ENDDO
    ENDDO
    release endof_file
    a1 := 0
    oWr:CountSect(.t.)
   // aeval(oWr:ahead,{|x,y|msg(x,[Ahead ]+zaps(y))})
   vsect  :={|x|{eval(oWr:Valore,oWr:aHead[1]),eval(oWr:Valore,oWr:aBody[1]),eval(oWr:Valore,oWr:aFeet[1]),nline,x}[at(x,"HBFL"+x)]}
   epar   :={|x|if( "(" $ X .or."->" $ x,&(X),val(eval(vsect,x)))}

   vpar   :={|x,y|if(ascan(x,[y])#0,y[ascan(x,[y])+1],NIL)}
   chblk  :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+1],''),'')}
   chblk2 :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+2],''),'')}
   chkArg :={|x|if(ascan(x,{|aVal,y| aVal[1]== y})> 0 ,x[ascan(x,{|aVal,y| aVal[1]==y})][2],'KKK')}

   //msgbox( zaps(ascan(_aAlign,{|aVal,y| upper(aVal[1])== Y})),"FGFGFG")
   //ie:  eval(chblk,arrypar,[WIDTH]) RETURN A PARAMETER OF WIDTH

   FCLOSE(handle)

   str1:=upper(substr(oWr:Adeclare[1,1],at("/",oWr:Adeclare[1,1])+1))

   if "ASKP"  $ Str1
      IF msgyesno(" Print ?",[])
         ritorna := oWr:splash(if (oWr:PrnDrv = "HBPR",'owr:doPr()','oWr:doMiniPr()') )
      Endif
   else
        ritorna := oWr:splash(if (oWr:PrnDrv = "HBPR",'owr:doPr()','oWr:doMiniPr()') )
   Endif

   if "ASKR" $ Str1
      do while msgYesno("Reprint ?") == .t.
         ritorna := oWr:splash(if (oWr:PrnDrv = "HBPR",'oWr:doPr()','oWr:doMiniPr()') )
      enddo
      filename := '' //release window all
   Endif

   SET( _SET_EXACT  , x_exact )
   release An_Vari,aend ,_aFnt,_Apaper,_abin ,_acharset,_aPen ,_aBrush ,_acolor
   release _aPoly ,_aBkmode ,_aRegion ,_aQlt,_aImgSty, Atutto ,Anext ,Aivarpt,ActIva
   release filtro ,string1,start, pagina ,_money, format, Atf, ritspl
   release _separator, _euro, atr, _t_font ,mx_ln_d,vsect ,epar,Vpar,chblk,chkArg
   release maxrow

   for n = 1 to len(nomevar)
       n_var:=nomevar[n]
       rele &n_var
   next
   rele nomevar,SEPARATOR
Endif
return ritorna
/*
*/
*-----------------------------------------------------------------------------*
* Printing Procedure                //La Procedura di Stampa
*-----------------------------------------------------------------------------*
Function StampeEsegui(_MainArea,_psd,db_arc,_prw)
*-----------------------------------------------------------------------------*
   Local oldrec   := recno(), rtv := .F. ,;
         landscape:=.F., lpreview :=.F., lselect  :=.F. ,;
         str1:=[] , StrFlt := [], ;
         ncpl , nfsize, aprinters, ;
         lbody := 0, miocont:= 0, miocnt:= 0 ,;
         Amx_pg := {}

   Private ONEATLEAST := .F., shd := .t., sbt := .t., sgh := .t., insgh:=.F.
   if !empty(_MainArea)
       oWr:aStat [ 'area1' ]  := substr(_MainArea,at('(',_MainArea)+1)
       oWr:aStat [ 'FldRel' ] := substr(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])+2)
       oWr:aStat [ 'FldRel' ] := substr(oWr:aStat [ 'FldRel' ],1,if(at(')',oWr:aStat [ 'FldRel' ])>0,at(')',oWr:aStat [ 'FldRel' ])-1,len(oWr:aStat [ 'FldRel' ]))) //+(at("->",oWr:aStat [ 'area1' ])))
       oWr:aStat [ 'area1' ]  := left(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])-1)
   else
       oWr:aStat [ 'area1' ]  := dbf()
       oWr:aStat [ 'FldRel' ] :=''
   Endif

   do case

      Case oWr:PrnDrv = "HBPR"
           INIT PRINTSYS
           oWr:CheckUnits()

           GET PRINTERS TO aprinters

      Case oWr:PrnDrv = "MINI"
           aprinters := aprinters()

      Case oWr:PrnDrv = "PFD"
           INIT PRINTSYS

   endcase

   Private counter   := {} , Gcounter := {}
   Private grdemo    := .F., gcdemo   := .F.
   Private Align     :=  0
   Private GHstring  := "", GFstring  := {}, GTstring := {}
   Private GField    := ""
   Private s_head    := "", TTS       := "Totale"

   Private s_col     :=  0, t_col     :=  0,  wheregt :=  0
   Private gftotal   := {}, Gfexec    := .F., s_total := ""
   Private nline     :=  mx_pg        := 0
   Private nPag      :=  0, nPgr      := 0, Tpg       :=  0
   Private last_pag  := .F., eLine    := 0, GFline    := .F.
   Public  maxrow    := 0 ,  maxcol   := 0,  mncl     := 0, mxH := 0
   Private abort     := 0

   ncpl := eval(oWr:Valore,oWr:Adeclare[1])
   str1 := upper(substr(oWr:Adeclare[1,1],at("/",oWr:Adeclare[1,1])+1))

   if "LAND" $ Str1 ;landscape:=.t.; Endif
   if "SELE" $ Str1 ;lselect :=.t. ; Endif
   if "PREV" $ Str1 ;lpreview:=.t. ; else;lpreview := _prw ; Endif

   str1 := upper(substr(oWr:aBody[1,1],at("/",oWr:aBody[1,1])+1))
   flob := val(str1)

   if ncpl = 0
      ncpl   :=80
      nfsize :=12
   else
      do case
         case ncpl= 80
            nfsize:=12
         case ncpl= 96
            nfsize=10
         case ncpl= 120
            nfsize:=8
         case ncpl= 140
           nfsize:=7
         case ncpl= 160
           nfsize:=6
         otherwise
           nfsize:=12
      endcase
   Endif
   if lselect .and. lpreview
      hbprn:selectprinter("",.t.) // SELECT BY DIALOG PREVIEW
   Endif
   if lselect .and. (!lpreview)
      hbprn:selectprinter("",.t.) // SELECT BY DIALOG
   Endif
   if !lselect .and. lpreview
      if ascan(aprinters,_PSD) > 0
         hbprn:selectprinter(_PSD,.t.) // SELECT PRINTER _PSD PREVIEW
      else
         hbprn:selectprinter(NIL,.t.) // SELECT DEFAULT PREVIEW
      Endif
   Endif
   if !lselect .and. !lpreview
      if ascan(aprinters,_PSD) > 0
        hbprn:selectprinter(_psd,.F.) // SELECT PRINTER _PSD
      else
        hbprn:selectprinter(NIL,.F.)   // SELECT default
      Endif
   Endif
   if HBPRNERROR != 0
      r_mem()
      return rtv
   Endif
   DEFINE FONT "Fx" NAME "COURIER NEW" SIZE NFSIZE
   DEFINE FONT "F0" NAME "COURIER NEW" SIZE NFSIZE
   DEFINE FONT "_F1_" NAME "HELVETICA" SIZE NFSIZE BOLD
   DEFINE FONT "_BC_" NAME "HELVETICA" SIZE 9 BOLD
   DEFINE FONT "_RULER_" NAME "HELVETICA" SIZE 6
   DEFINE BRUSH "_BC_" style BS_SOLID color 0x000000
   DEFINE PEN "WHITE" COLOR {255,255,255}
   DEFINE PEN "BLACK" STYLE BS_SOLID WIDTH 5 COLOR {0,0,0}

   if landscape
      set page orientation DMORIENT_LANDSCAPE font "F0"
   else
      set page orientation DMORIENT_PORTRAIT  font "F0"
   Endif

   select font "F0"
   select pen "P0"

   //start doc
   if used()
      if !empty(atf)
         set filter to &atf
      Endif
      oWr:aStat[ 'end_pr' ] := oWr:quantirec( _mainarea )
   else
      oWr:aStat[ 'end_pr' ] := oWr:quantirec( _mainarea )
   Endif

   aeval(oWr:adeclare,{|x,y|if(Y > 1 ,oWr:traduci(x[1],,x[2]),'')})
   maxrow := int(hbprn:devcaps[1]/Lstep)
   oWr:colstep(ncpl,)

   if abort != 0
      r_mem()
      return nil
   Endif
   //msg(zaps(mx_pg)+CRLF+[oWr:Valore= ]+zaps(eval(oWr:Valore,oWr:aBody[1,1]))+CRLF+zaps(oWr:aStat[ 'end_pr' ]),[tutte])

   START DOC NAME oWr:aStat [ 'JobName' ]

   do case
      case oWr:HB=0

      case empty(_MainArea)                // Mono Db List
           if lastrec() > 0 .or. valtype(oWr:argm[3]) == "A"
              Lbody := eval(oWr:Valore,oWr:aBody[1])
              mx_pg := INT(oWr:aStat[ 'end_pr' ]/NOZERODIV(Lbody) )
              if (mx_pg * lbody) # mx_pg
                  mx_pg ++
              Endif
              mx_pg := ROUND( max(1,mx_pg), 0 )
              tpg   := mx_pg
              if valtype(oWr:argm[3]) # "A"
                 Dbgotop()
              Endif
              if oWr:aStat [ 'end_pr' ] # 0
                 while !oWr:aStat [ 'EndDoc' ]
                       oWr:TheHead()
                       oWr:TheBody()
                 enddo
              Endif
           Else
              msgStop("No data to print! ","Attention")
           Endif
      Otherwise                              // Two Db List
           sele (oWr:aStat [ 'area1' ])
           if !empty(atf)
              set filter to &atf
           Endif
           Dbgotop()
           if lastrec()> 0
              lbody := eval(oWr:Valore,oWr:aBody[1])
//              msgbox(StrFlt := oWr:aStat [ 'FldRel' ]+" = "+ oWr:aStat [ 'area1' ]+"->"+oWr:aStat [ 'FldRel' ],"452")
//              msgbox(alias()+CRLF+db_arc+CRLF+ordkey(ordbagname())+crlf+oWr:aStat [ 'area1' ]+CRLF+oWr:aStat [ 'FldRel' ],"453")

              while !eof()
                    sele (DB_ARC)
                    StrFlt := oWr:aStat [ 'FldRel' ]+" = "+ oWr:aStat [ 'area1' ]+"->"+oWr:aStat [ 'FldRel' ]
                    DBEVAL( {|| miocont++},{|| &strFLT} )
                    miocnt := int(miocont/NOZERODIV(lbody))
                    if (miocnt * lbody) # miocont
                       miocnt ++
                    Endif
                    tpg += miocnt
                    aadd(Amx_pg,miocnt)
                    miocont := 0
                    sele (oWr:aStat [ 'area1' ])
                    dbskip()
              enddo
              go top
              if valtype (atail(amx_pg)) == "N"
                 while !eof()
                       sele (DB_ARC)
                       set filter to &strFLT
                       miocont ++
                       mx_pg  := aMx_pg[miocont]
                       go top
                       nPgr := 0
                       while !eof()
                             oWr:TheHead()
                             oWr:TheBody()
                       enddo
                       oWr:aStat [ 'EndDoc' ]:=.F.
                       last_pag := .F.
                       set filter to
                       sele (oWr:aStat [ 'area1' ])
                       dbskip()
                 enddo
              Endif
           Else
              msgStop("No data to print! ","Attention")
           Endif
   Endcase

   if oneatleast
      go top
      oWr:TheHead()
      oWr:TheFeet()
   Endif
   end doc
   if len(oWr:aStat [ 'ErrorLine' ]) > 0
      msgmulty(oWr:aStat [ 'ErrorLine' ],"Error summary report:")
   Endif
   hbprn:setdevmode(256,1)
   if used();dbgoto(oldrec);Endif
   R_mem(.T.)

Return !rtv
/*
*/
*-----------------------------------------------------------------------------*
Function R_mem(Last)
*-----------------------------------------------------------------------------*
   default last to .F.
   aeval(oWr:astat[ 'aImages' ],{|x| Ferase(x) })
   if oWr:prndrv = "HBPR"
      hbprn:end()
   Endif
   if ! last
      domethod("form_splash","HIDE")
   Endif
   domethod("form_splash","release")
   release miocont,counter,Gcounter,grdemo,gcdemo,Align,GField
   release s_head,s_col,gftotal,Gfexec,s_total,t_col,nline,nPag,nPgr,Tpg,last_pag,eLine,wheregt
   release GFline,mx_pg,maxrow,ONEATLEAST,shd,sbt,sgh,insgh,TTS, abort
return .F.
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Proper(interm)             //Created By Piersoft 01/04/95 KILLED Bugs!
*-----------------------------------------------------------------------------*
   Local outStr := '',capnxt := '', c_1
   do while chr(32) $ interm
      c_1 := substr(interm,1,at(chr(32),interm)-1)
      capnxt := capnxt+upper(left(c_1,1))+right(c_1,len(c_1)-1)+" "
      interm := substr(interm,len(c_1)+2,len(interm)-len(c_1))
   enddo
   outStr := capnxt+upper(left(interm,1))+right(interm,len(interm)-1)
RETURN outStr
/*
*/
*-----------------------------------------------------------------------------*
Function Color(GR,GR1,GR2)
*-----------------------------------------------------------------------------*
   Local DATO
   if PCOUNT()=1 .and. valtype(GR)=="C"
      if "," $ GR
         gr :=  STRTRAN(gr,"{",'')
         gr :=  STRTRAN(gr,"}",'')
         tokeninit(GR,",")
         IF oWr:PrnDrv = "HBPR"
            DATO := rgb( VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR)) )
         else
            Dato := { VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR)) }
         Endif
      else
         dato := oWr:SetMyRgb(oWr:DXCOLORS(gr))
      Endif
   ELSEif PCOUNT()=1 .and. VALtype(GR)=="A"
         DATO := rgb(GR[1],GR[2],GR[3])
   elseIF PCOUNT()=3
      DATO := rgb(GR,GR1,GR2)
   Endif

return DATO
/*
*/
*-----------------------------------------------------------------------------*
Function GROUP(GField, s_head, s_col, gftotal, wheregt, s_total, t_col, p_f_e_g)
*                1        2      3       4        5        6       7       8
*-----------------------------------------------------------------------------*
return oWr:GROUP(GField, s_head, s_col, gftotal, wheregt, s_total, t_col, p_f_e_g)
/*
*/
*-----------------------------------------------------------------------------*
Procedure gridRow(arg1)
*-----------------------------------------------------------------------------*
default arg1 to oWr:aStat ['r_paint']
oWr:aStat ['r_paint'] := arg1
m->grdemo  := .t.
return
/*
*/
*-----------------------------------------------------------------------------*
Procedure gridCol(arg1)
*-----------------------------------------------------------------------------*
default arg1 to oWr:aStat ['r_paint']
oWr:aStat ['r_paint'] := arg1
m->gcdemo := .t.
return
/*
*/
*-----------------------------------------------------------------------------*
static Funct AscArr(string)
*-----------------------------------------------------------------------------*
Local aka :={}, cword := ''
default string to ""
      string := atrepl( "{",string,'')
      string := atrepl( "}",string,'')
      if !empty(string)
         aka := HB_ATOKENS( string, "," )
      Endif
return aka
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION ed_g_pic
*-----------------------------------------------------------------------------*
parameter __arg1,__arg2
Local arg1, arg2
default __arg2 to .F.

if __arg2
   _euro:=.t.
Endif

if Valtype(m->__arg1)="C"
   * MSG(VALtype(m->__arg1),[val1])
   *- make sure it fits on the screen
   arg1 := "@KS" + LTRIM(STR(MIN(LEN((m->__arg1)), 78)))
elseif VALTYPE(m->__arg1) = "N"
   *- convert to a string
   * MSG(VALtype(m->__arg1),[val2])
   arg2 := STR (__arg1)
   *- look for a decimal point
   IF ("." $ arg2)
      *- return a picture reflecting a decimal point
      arg1 := REPLICATE("9", AT(".", arg2) - 1)+[.]

      arg1 := eu_point(arg1)+[.]+ REPLICATE("9", LEN(arg2) - LEN(arg1))
   ELSE
      *- return a string of 9's a the picture
      arg1 := REPLICATE("9", LEN(arg2))
      arg1 := eu_point(arg1)+if( _money,".00","")
   Endif
else
   *- well I just don't know.
   arg1 := ""
Endif

RETURN arg1
/*
*/
*-----------------------------------------------------------------------------*
Function eu_point(valore)
*-----------------------------------------------------------------------------*
Local tappo:='',sep_conto:=0,n

For n = len(valore) to 1 step -1
    If substr(valore,n,1)==[9]
       if sep_conto = 3
          if _separator
             tappo := ","+tappo
          Endif
          sep_conto := 0
       Endif
       tappo := substr(valore,n,1)+TAPPO
       sep_conto ++
    Endif
Next
if _euro
   tappo:= "@E "+tappo
Endif

return tappo
/*
*/
*-----------------------------------------------------------------------------*
Procedure dbselect(area)
*-----------------------------------------------------------------------------*
     if valtype(area)="N"
        dbSelectArea( zaps(area) )
     elseif valtype(area)="C"
        select (area)
     Endif
return
/*
*/
*-----------------------------------------------------------------------------*
Function Divisor(arg1,arg2)
*-----------------------------------------------------------------------------*
default arg2 to 1
return arg1/Nozerodiv(arg2)
/*
*/
*-----------------------------------------------------------------------------*
Function NoZeroDiv(nValue)
*-----------------------------------------------------------------------------*
return IIF(nValue=0,1,nValue)
/*
*/
*-----------------------------------------------------------------------------*
Procedure MsgMulty( xMesaj, cTitle ) // Created By Bicahi Esgici <esgici@gmail.com>
*-----------------------------------------------------------------------------*
   loca cMessage := ""

   IF xMesaj # NIL

      IF cTitle == NIL
         cTitle := PROCNAME(1) + "\" +   NTrim( PROCLINE(1) )
      Endif

      IF VALTYPE( xMesaj  ) # "A"
         xMesaj := { xMesaj }
      Endif

      AEVAL( xMesaj, { | x1 | cMessage +=  Any2Strg( x1 ) + CRLF } )

      MsgInfo( cMessage, cTitle )

   Endif xMesaj # NIL

RETU
/*
*/
*-----------------------------------------------------------------------------*
FUNC Any2Strg( xAny )
*-----------------------------------------------------------------------------*
   loca cRVal  := '???',;
        nType  :=  0,;
        aCases := { { "A", { |  | "{...}" } },;
                    { "B", { |  | "{||}" } },;
                    { "C", { | x | x }},;
                    { "M", { | x | x   } },;
                    { "D", { | x | DTOC( x ) } },;
                    { "L", { | x | IF( x,"On","Off") } },;
                    { "N", { | x | NTrim( x )  } },;
                    { "O", { |  | ":Object:" } },;
                    { "U", { |  | "<NIL>" } } }

   IF (nType := ASCAN( aCases, { | a1 | VALTYPE( xAny ) == a1[ 1 ] } ) ) > 0
      cRVal := EVAL( aCases[ nType, 2 ], xAny )
   Endif

RETU cRVal

#ifdef __XHARBOUR__
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION DecToHexa(nNumber)
*-----------------------------------------------------------------------------*
   Local cNewString:=''
   Local nTemp:=0
   WHILE(nNumber > 0)
      nTemp:=(nNumber%16)
      cNewString:=SubStr('0123456789ABCDEF',(nTemp+1),1)+cNewString
      nNumber:=Int((nNumber-nTemp)/16)
   ENDDO
   RETURN(cNewString)
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION HexaToDec(cString)
*-----------------------------------------------------------------------------*
   Local nNumber:=0,nX:=0
   Local cNewString:=AllTrim(cString)
   Local nLen:=Len(cNewString)
   FOR nX:=1 to nLen
      nNumber+=(At(SubStr(cNewString,nX,1),'0123456789ABCDEF')-1)*;
         (16**(nLen-nX))
   NEXT nX
   RETURN nNumber

#Endif
/*
*/
*-----------------------------------------------------------------------------*
Function Msgt (nTimeout, Message, Title, Flags)
*-----------------------------------------------------------------------------*
* Created at 04/20/2005 By Pierpaolo Martinello Italy                         *
* Modified 15/08/2014                                                         *
*-----------------------------------------------------------------------------*

        local rtv := 0 ,nFlag, nMSec

        DEFAULT Message TO "" , Title TO "", Flags  TO "MSGBOX"

        If ValType (nTimeout) != 'U' .and. ValType (nTimeout) == 'C'
              Flags    := Title
              Title    := Message
              Message  := nTimeout
              nTimeout := 0
        endif

        Flags := trans(Flags,"@!")

        nMSec := nTimeout * 1000

        Message+= if(empty(Message),"Empty string!",'')

           do case

              case "RETRYCANCEL" == FLAGS
                   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_RETRYCANCEL
                   RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

              case "OKCANCEL" == FLAGS
                   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_OKCANCEL
                   RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

               case "YESNO" == FLAGS
                   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_YESNO
                   RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

               case "YESNO_ID" == FLAGS
                   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_YESNO
                   RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

               case "YESNO_CANCEL" == FLAGS
                   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_YESNOCANCEL
                   RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

              case "INFO" == FLAGS
                   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONINFORMATION
                   RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

              case "STOP" == FLAGS
                   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONSTOP
                   RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

              case "EXCLAMATION" == FLAGS .or. "ALERT" == FLAGS
                   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONEXCLAMATION
                   RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

              otherwise

                   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL
                   RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)
           endcase

return rtv
/*
*/
*-----------------------------------------------------------------------------*
Function _dummy_( ... )
*-----------------------------------------------------------------------------*
return nil
/*
*/
*-----------------------------------------------------------------------------*
Function WRVersion( )
*-----------------------------------------------------------------------------*
return "4.3"
/*
*/
*-----------------------------------------------------------------------------*
CREATE CLASS WREPORT
*-----------------------------------------------------------------------------*
DATA FILENAME         INIT ''
DATA NREC             INIT 0
DATA F_HANDLE         INIT 0 PROTECTED
DATA aDeclare         INIT {}
DATA AHead            INIT {}
DATA ABody            INIT {}
DATA AFeet            INIT {}
DATA Hb               INIT 0
DATA aCnt             INIT 0
DATA Valore           INIT {|x|val(substr(x[1],at("]",x[1])+1))}
DATA mx_ln_doc        INIT 0
DATA PRNDRV           INIT "HBPR"
DATA lSuccess         INIT .F.
DATA Lmargin          INIT 0
DATA argm             INIT {nil,nil, nil,nil}
DATA aStat            INIT { 'Define'     => .F. , ;    // Define Section
                             'Head'       => .F. , ;    // Head Section
                             'Body'       => .F. , ;    // Body Section
                             'Feet'       => .F. , ;    // Feet section
                             'Filtro'     => .F. , ;
                             'r_paint'    => .T. , ;
                             'TempHead'   =>  '' , ;
                             'Ghead'      => .F. , ;
                             'P_F_E_G'    => .F. , ;
                             'GHline'     => .F. , ;
                             'TempFeet'   =>  '' , ;
                             'end_pr'     =>  0  , ;
                             'EndDoc'     => .F. , ;
                             'EntroIF'    => .F. , ;
                             'DelMode'    => .F. , ;
                             'ElseStat'   => .F. , ;
                             'ErrorLine'  =>  {} , ;
                             'OneError'   => .F. , ;
                             'area1'      =>  '' , ;
                             'FldRel'     =>  '' , ;
                             'ReadMemo'   =>  '' , ;
                             'lblsplash'  =>  'Attendere......... Creazione stampe!' , ;
                             'TrSpace'    => {|x,y,z|oWr:transpace(x,y,z)} , ;
                             'Yes_Memo'   => .F. , ;
                             'Yes_Array'  => .F. , ;
                             'JobName'    => 'HbPrinter' , ;
                             'JobPath'    => cFilePath(GetExeFileName())+"\" , ;
                             'Test'       => "{|X| LTRIM( STR( X,20, IF( X == INT( X ), 0, 2 ) ))}" , ;
                             'Control'    => .F. , ;
                             'InlineSbt'  => .T. , ;
                             'InlineTot'  => .T. , ;
                             'GroupBold'  => .T. , ;
                             'HGroupColor' => {0,0, 255} , ;
                             'GTGroupColor' => {0,0, 255} , ;
                             'aImages'    => {}  , ;
                             'Memofont'   => {}  , ;
                             'PdfFont'    => {{"",""}} , ;
                             'cStep'      => 2.625 , ;
                             'Units'      => "MM", ;    //
                             'Orient'     =>  1 , ;   // default PORTRAIT
                             'Duplex'     =>  1 , ;   // default NONE
                             'Source'     =>  1 , ;   // default BIN_UPPER
                             'Collate'    =>  0 , ;   // default FALSE
                             'Res'        => -3 , ;   // default MEDIUM
                             'PaperSize'  =>  9 , ;   // default A4
                             'PaperLength'=> 0  , ;   // default 0
                             'PaperWidth' => 0  , ;   // default 0
                             'ColorMode'  => 1  , ;   // default MONOCHROME
                             'Copies'     => 1  , ;   // default 1
                             'Fname'      => "" , ;
                             'Fsize'      => 0  , ;
                             'FBold'      => .F., ;
                             'Fita'       => .F., ;
                             'Funder'     => .F., ;
                             'Fstrike'    => .F., ;
                             'Falign'     => .F., ;
                             'Fangle'     => 0  , ;
                             'Fcolor'     =>    , ;
                             'HRuler'     => {0,.F.} ,;
                             'VRuler'     => {0,.F.} ,;
                             'DebugType'  => "LINE", ;
                             'Hbcompatible'=> 0 ,;
                             'MarginTop'   => 0 ,;
                             'MarginLeft'  => 0 ;
                             }

data Ach              INIT  {;
                             {"DMPAPER_FIRST",               1}; /*  */
                            ,{"DMPAPER_LETTER",              1}; /*   Letter 8 1/2 x 11 in               */
                            ,{"DMPAPER_LETTERSMALL",         2}; /*   Letter Small 8 1/2 x 11 in         */
                            ,{"DMPAPER_TABLOID",             3}; /*   Tabloid 11 x 17 in                 */
                            ,{"DMPAPER_LEDGER",              4}; /*   Ledger 17 x 11 in                  */
                            ,{"DMPAPER_LEGAL",               5}; /*   Legal 8 1/2 x 14 in                */
                            ,{"DMPAPER_STATEMENT",           6}; /*   Statement 5 1/2 x 8 1/2 in         */
                            ,{"DMPAPER_EXECUTIVE",           7}; /*   Executive 7 1/4 x 10 1/2 in        */
                            ,{"DMPAPER_A3",                  8}; /*   A3 297 x 420 mm                    */
                            ,{"DMPAPER_A4",                  9}; /*   A4 210 x 297 mm                    */
                            ,{"DMPAPER_A4SMALL",            10}; /*   A4 Small 210 x 297 mm              */
                            ,{"DMPAPER_A5",                 11}; /*   A5 148 x 210 mm                    */
                            ,{"DMPAPER_B4",                 12}; /*   B4 (JIS) 250 x 354                 */
                            ,{"DMPAPER_B5",                 13}; /*   B5 (JIS) 182 x 257 mm              */
                            ,{"DMPAPER_FOLIO",              14}; /*   Folio 8 1/2 x 13 in                */
                            ,{"DMPAPER_QUARTO",             15}; /*   Quarto 215 x 275 mm                */
                            ,{"DMPAPER_10X14",              16}; /*   10x14 in                           */
                            ,{"DMPAPER_11X17",              17}; /*   11x17 in                           */
                            ,{"DMPAPER_NOTE",               18}; /*   Note 8 1/2 x 11 in                 */
                            ,{"DMPAPER_ENV_9",              19}; /*   Envelope #9 3 7/8 x 8 7/8          */
                            ,{"DMPAPER_ENV_10",             20}; /*   Envelope #10 4 1/8 x 9 1/2         */
                            ,{"DMPAPER_ENV_11",             21}; /*   Envelope #11 4 1/2 x 10 3/8        */
                            ,{"DMPAPER_ENV_12",             22}; /*   Envelope #12 4 \276 x 11           */
                            ,{"DMPAPER_ENV_14",             23}; /*   Envelope #14 5 x 11 1/2            */
                            ,{"DMPAPER_CSHEET",             24}; /*   C size sheet                       */
                            ,{"DMPAPER_DSHEET",             25}; /*   D size sheet                       */
                            ,{"DMPAPER_ESHEET",             26}; /*   E size sheet                       */
                            ,{"DMPAPER_ENV_DL",             27}; /*   Envelope DL 110 x 220mm            */
                            ,{"DMPAPER_ENV_C5",             28}; /*   Envelope C5 162 x 229 mm           */
                            ,{"DMPAPER_ENV_C3",             29}; /*   Envelope C3  324 x 458 mm          */
                            ,{"DMPAPER_ENV_C4",             30}; /*   Envelope C4  229 x 324 mm          */
                            ,{"DMPAPER_ENV_C6",             31}; /*   Envelope C6  114 x 162 mm          */
                            ,{"DMPAPER_ENV_C65",            32}; /*   Envelope C65 114 x 229 mm          */
                            ,{"DMPAPER_ENV_B4",             33}; /*   Envelope B4  250 x 353 mm          */
                            ,{"DMPAPER_ENV_B5",             34}; /*   Envelope B5  176 x 250 mm          */
                            ,{"DMPAPER_ENV_B6",             35}; /*   Envelope B6  176 x 125 mm          */
                            ,{"DMPAPER_ENV_ITALY",          36}; /*   Envelope 110 x 230 mm              */
                            ,{"DMPAPER_ENV_MONARCH",        37}; /*   Envelope Monarch 3.875 x 7.5 in    */
                            ,{"DMPAPER_ENV_PERSONAL",       38}; /*   6 3/4 Envelope 3 5/8 x 6 1/2 in    */
                            ,{"DMPAPER_FANFOLD_US",         39}; /*   US Std Fanfold 14 7/8 x 11 in      */
                            ,{"DMPAPER_FANFOLD_STD_GERMAN", 40}; /*   German Std Fanfold 8 1/2 x 12 in   */
                            ,{"DMPAPER_FANFOLD_LGL_GERMAN", 41}; /*   German Legal Fanfold 8 1/2 x 13 in */
                            ,{"DMPAPER_ISO_B4",             42}; /*   B4 (ISO) 250 x 353 mm              */
                            ,{"DMPAPER_JAPANESE_POSTCARD",  43}; /*   Japanese Postcard 100 x 148 mm     */
                            ,{"DMPAPER_9X11",               44}; /*   9 x 11 in                          */
                            ,{"DMPAPER_10X11",              45}; /*   10 x 11 in                         */
                            ,{"DMPAPER_15X11",              46}; /*   15 x 11 in                         */
                            ,{"DMPAPER_ENV_INVITE",         47}; /*   Envelope Invite 220 x 220 mm       */
                            ,{"DMPAPER_RESERVED_48",        48}; /*   RESERVED--DO NOT USE               */
                            ,{"DMPAPER_RESERVED_49",        49}; /*   RESERVED--DO NOT USE               */
                            ,{"DMPAPER_LETTER_EXTRA",       50}; /*   Letter Extra 9 \275 x 12 in        */
                            ,{"DMPAPER_LEGAL_EXTRA",        51}; /*   Legal Extra 9 \275 x 15 in         */
                            ,{"DMPAPER_TABLOID_EXTRA",      52}; /*   Tabloid Extra 11.69 x 18 in        */
                            ,{"DMPAPER_A4_EXTRA",           53}; /*   A4 Extra 9.27 x 12.69 in           */
                            ,{"DMPAPER_LETTER_TRANSVERSE",  54}; /*   Letter Transverse 8 \275 x 11 in   */
                            ,{"DMPAPER_A4_TRANSVERSE",      55}; /*   A4 Transverse 210 x 297 mm         */
                            ,{"DMPAPER_LETTER_EXTRA_TRANSVERSE",56}; /* Letter Extra Transverse 9\275 x 12 in */
                            ,{"DMPAPER_A_PLUS",             57};   /* SuperA/SuperA/A4 227 x 356 mm      */
                            ,{"DMPAPER_B_PLUS",             58};   /* SuperB/SuperB/A3 305 x 487 mm      */
                            ,{"DMPAPER_LETTER_PLUS",        59};   /* Letter Plus 8.5 x 12.69 in         */
                            ,{"DMPAPER_A4_PLUS",            60};   /* A4 Plus 210 x 330 mm               */
                            ,{"DMPAPER_A5_TRANSVERSE",      61};   /* A5 Transverse 148 x 210 mm         */
                            ,{"DMPAPER_B5_TRANSVERSE",      62};   /* B5 (JIS) Transverse 182 x 257 mm   */
                            ,{"DMPAPER_A3_EXTRA",           63};   /* A3 Extra 322 x 445 mm              */
                            ,{"DMPAPER_A5_EXTRA",           64};   /* A5 Extra 174 x 235 mm              */
                            ,{"DMPAPER_B5_EXTRA",           65};   /* B5 (ISO) Extra 201 x 276 mm        */
                            ,{"DMPAPER_A2",                 66};   /* A2 420 x 594 mm                    */
                            ,{"DMPAPER_A3_TRANSVERSE",      67};   /* A3 Transverse 297 x 420 mm         */
                            ,{"DMPAPER_A3_EXTRA_TRANSVERSE",68};   /* A3 Extra Transverse 322 x 445 mm   */
                            ,{"DMPAPER_DBL_JAPANESE_POSTCARD",69};  /* Japanese Double Postcard 200 x 148 mm */
                            ,{"DMPAPER_A6",                  70 };  /*  A6 105 x 148 mm                 */
                            ,{"DMPAPER_JENV_KAKU2",          71 };  /*  Japanese Envelope Kaku #2       */
                            ,{"DMPAPER_JENV_KAKU3",          72 };  /*  Japanese Envelope Kaku #3       */
                            ,{"DMPAPER_JENV_CHOU3",          73 };  /*  Japanese Envelope Chou #3       */
                            ,{"DMPAPER_JENV_CHOU4",          74 };  /*  Japanese Envelope Chou #4       */
                            ,{"DMPAPER_LETTER_ROTATED",      75 };  /*  Letter Rotated 11 x 8 1/2 11 in */
                            ,{"DMPAPER_A3_ROTATED",          76 };  /*  A3 Rotated 420 x 297 mm         */
                            ,{"DMPAPER_A4_ROTATED",          77 };  /*  A4 Rotated 297 x 210 mm         */
                            ,{"DMPAPER_A5_ROTATED",          78 };  /*  A5 Rotated 210 x 148 mm         */
                            ,{"DMPAPER_B4_JIS_ROTATED",      79 };  /*  B4 (JIS) Rotated 364 x 257 mm   */
                            ,{"DMPAPER_B5_JIS_ROTATED",      80 };  /*  B5 (JIS) Rotated 257 x 182 mm   */
                            ,{"DMPAPER_JAPANESE_POSTCARD_ROTATED",81};    /*Japanese Postcard Rotated 148 x 100 mm */
                            ,{"DMPAPER_DBL_JAPANESE_POSTCARD_ROTATED",82};/*double Japanese Postcard Rotated 148 x 200 mm */
                            ,{"DMPAPER_A6_ROTATED",          83 }; /*  A6 Rotated 148 x 105 mm         */
                            ,{"DMPAPER_JENV_KAKU2_ROTATED",  84 }; /*  Japanese Envelope Kaku #2 Rotated */
                            ,{"DMPAPER_JENV_KAKU3_ROTATED",  85 }; /*  Japanese Envelope Kaku #3 Rotated */
                            ,{"DMPAPER_JENV_CHOU3_ROTATED",  86 }; /*  Japanese Envelope Chou #3 Rotated */
                            ,{"DMPAPER_JENV_CHOU4_ROTATED",  87 }; /*  Japanese Envelope Chou #4 Rotated */
                            ,{"DMPAPER_B6_JIS",              88 }; /*  B6 (JIS) 128 x 182 mm           */
                            ,{"DMPAPER_B6_JIS_ROTATED",      89 }; /*  B6 (JIS) Rotated 182 x 128 mm   */
                            ,{"DMPAPER_12X11",               90 }; /*  12 x 11 in                      */
                            ,{"DMPAPER_JENV_YOU4",           91 }; /*  Japanese Envelope You #4        */
                            ,{"DMPAPER_JENV_YOU4_ROTATED",   92 }; /*  Japanese Envelope You #4 Rotated*/
                            ,{"DMPAPER_P16K",                93 }; /*  PRC 16K 146 x 215 mm            */
                            ,{"DMPAPER_P32K",                94 }; /*  PRC 32K 97 x 151 mm             */
                            ,{"DMPAPER_P32KBIG",             95 }; /*  PRC 32K(Big) 97 x 151 mm        */
                            ,{"DMPAPER_PENV_1",              96 }; /*  PRC Envelope #1 102 x 165 mm    */
                            ,{"DMPAPER_PENV_2",              97 }; /*  PRC Envelope #2 102 x 176 mm    */
                            ,{"DMPAPER_PENV_3",              98 }; /*  PRC Envelope #3 125 x 176 mm    */
                            ,{"DMPAPER_PENV_4",              99 }; /*  PRC Envelope #4 110 x 208 mm    */
                            ,{"DMPAPER_PENV_5",              100}; /*  PRC Envelope #5 110 x 220 mm    */
                            ,{"DMPAPER_PENV_6",              101}; /*  PRC Envelope #6 120 x 230 mm    */
                            ,{"DMPAPER_PENV_7",              102}; /*  PRC Envelope #7 160 x 230 mm    */
                            ,{"DMPAPER_PENV_8",              103}; /*  PRC Envelope #8 120 x 309 mm    */
                            ,{"DMPAPER_PENV_9",              104}; /*  PRC Envelope #9 229 x 324 mm    */
                            ,{"DMPAPER_PENV_10",             105}; /*  PRC Envelope #10 324 x 458 mm   */
                            ,{"DMPAPER_P16K_ROTATED",        106}; /*  PRC 16K Rotated                 */
                            ,{"DMPAPER_P32K_ROTATED",        107}; /*  PRC 32K Rotated                 */
                            ,{"DMPAPER_P32KBIG_ROTATED",     108}; /*  PRC 32K(Big) Rotated            */
                            ,{"DMPAPER_PENV_1_ROTATED",      109}; /*  PRC Envelope #1 Rotated 165 x 102 mm */
                            ,{"DMPAPER_PENV_2_ROTATED",      110}; /*  PRC Envelope #2 Rotated 176 x 102 mm */
                            ,{"DMPAPER_PENV_3_ROTATED",      111}; /*  PRC Envelope #3 Rotated 176 x 125 mm */
                            ,{"DMPAPER_PENV_4_ROTATED",      112}; /*  PRC Envelope #4 Rotated 208 x 110 mm */
                            ,{"DMPAPER_PENV_5_ROTATED",      113}; /*  PRC Envelope #5 Rotated 220 x 110 mm */
                            ,{"DMPAPER_PENV_6_ROTATED",      114}; /*  PRC Envelope #6 Rotated 230 x 120 mm */
                            ,{"DMPAPER_PENV_7_ROTATED",      115}; /*  PRC Envelope #7 Rotated 230 x 160 mm */
                            ,{"DMPAPER_PENV_8_ROTATED",      116}; /*  PRC Envelope #8 Rotated 309 x 120 mm */
                            ,{"DMPAPER_PENV_9_ROTATED",      117}; /*  PRC Envelope #9 Rotated 324 x 229 mm */
                            ,{"DMPAPER_PENV_10_ROTATED",     118}; /*  PRC Envelope #10 Rotated 458 x 324 mm */
                            ,{"DMPAPER_USER",                256};
                            ,{"DMBIN_FIRST",          1};   /* bin selections */
                            ,{"DMBIN_UPPER",          1};
                            ,{"DMBIN_ONLYONE",        1};
                            ,{"DMBIN_LOWER",          2};
                            ,{"DMBIN_MIDDLE",         3};
                            ,{"DMBIN_MANUAL",         4};
                            ,{"DMBIN_ENVELOPE",       5};
                            ,{"DMBIN_ENVMANUAL",      6};
                            ,{"DMBIN_AUTO",           7};
                            ,{"DMBIN_TRACTOR",        8};
                            ,{"DMBIN_SMALLFMT",       9};
                            ,{"DMBIN_LARGEFMT",      10};
                            ,{"DMBIN_LARGECAPACITY", 11};
                            ,{"DMBIN_CASSETTE",      14};
                            ,{"DMBIN_FORMSOURCE",    15};
                            ,{"DMBIN_LAST",          15};
                            ,{"DMBIN_USER",         256};     /* device specific bins start here */
                            ,{"ANSI_CHARSET",              0};  /*  _acharset :={; */
                            ,{"DEFAULT_CHARSET",           1};
                            ,{"SYMBOL_CHARSET",            2};
                            ,{"SHIFTJIS_CHARSET",        128};
                            ,{"HANGEUL_CHARSET",         129};
                            ,{"HANGUL_CHARSET",          129};
                            ,{"GB2312_CHARSET",          134};
                            ,{"CHINESEBIG5_CHARSET",     136};
                            ,{"OEM_CHARSET",             255};
                            ,{"JOHAB_CHARSET",           130};
                            ,{"HEBREW_CHARSET",          177};
                            ,{"ARABIC_CHARSET",          178};
                            ,{"GREEK_CHARSET",           161};
                            ,{"TURKISH_CHARSET",         162};
                            ,{"VIETNAMESE_CHARSET",      163};
                            ,{"THAI_CHARSET",            222};
                            ,{"EASTEUROPE_CHARSET",      238};
                            ,{"RUSSIAN_CHARSET",         204};
                            ,{"MAC_CHARSET",              77};
                            ,{"BALTIC_CHARSET",          186};
                            ,{"PS_SOLID",            0};       /* Pen Styles */
                            ,{"PS_DASH",             1};       /* -------  */
                            ,{"PS_DOT",              2};       /* .......  */
                            ,{"PS_DASHDOT",          3};       /* _._._._  */
                            ,{"PS_DASHDOTDOT",       4};       /* _.._.._  */
                            ,{"PS_NULL",             5};
                            ,{"PS_INSIDEFRAME",      6};
                            ,{"PS_USERSTYLE",        7};
                            ,{"PS_ALTERNATE",        8};
                            ,{"PS_STYLE_MASK",       0x0000000F};
                            ,{"BS_SOLID",            0};       /* Brush Styles */
                            ,{"BS_NULL",             1};
                            ,{"BS_HOLLOW",           1};
                            ,{"BS_HATCHED",          2};
                            ,{"BS_PATTERN",          3};
                            ,{"BS_INDEXED",          4};
                            ,{"BS_DIBPATTERN",       5};
                            ,{"BS_DIBPATTERNPT",     6};
                            ,{"BS_PATTERN8X8",       7};
                            ,{"BS_DIBPATTERN8X8",    8};
                            ,{"BS_MONOPATTERN",      9};
                            ,{"ALTERNATE",            1}; /* PolyFill() Modes */
                            ,{"WINDING",              2};
                            ,{"POLYFILL_LAST",        2};
                            ,{"TRANSPARENT",         1}; /* Background Modes */
                            ,{"OPAQUE",              2};
                            ,{"BKMODE_LAST",         2};
                            ,{"TA_NOUPDATECP",       0}; /* Text Alignment Options */
                            ,{"TA_UPDATECP",         1};
                            ,{"TA_LEFT",             0};
                            ,{"TA_RIGHT",            2};
                            ,{"TA_CENTER",           6};
                            ,{"LEFT",                0};
                            ,{"RIGHT",               2};
                            ,{"CENTER",              6};
                            ,{"TA_TOP",              0};
                            ,{"TA_BOTTOM",           8};
                            ,{"TA_BASELINE",         24};
                            ,{"TA_RTLREADING",       256};
                            ,{"TA_MASK",       (TA_BASELINE+TA_CENTER+TA_UPDATECP+TA_RTLREADING)};
                            ,{"RGN_AND",             1};  /* CombineRgn() Styles */
                            ,{"RGN_OR",              2};
                            ,{"RGN_XOR",             3};
                            ,{"RGN_DIFF",            4};
                            ,{"RGN_COPY",            5};
                            ,{"RGN_MIN",       RGN_AND};
                            ,{"RGN_MAX",      RGN_COPY};
                            ,{"AND",                 1};
                            ,{"OR",                  2};
                            ,{"XOR",                 3};
                            ,{"DIFF",                4};
                            ,{"COPY",                5};
                            ,{"MIN",           RGN_AND};
                            ,{"MAX",          RGN_COPY};
                            ,{"DMCOLOR_MONOCHROME", 1}; /* color enable/disable for color printers */
                            ,{"DMCOLOR_COLOR",      2};
                            ,{"MONO",               1};
                            ,{"COLOR",              2};
                            ,{"DMRES_DRAFT",    -1};  /* print qualities */
                            ,{"DMRES_LOW",      -2};
                            ,{"DMRES_MEDIUM",   -3};
                            ,{"DMRES_HIGH",     -4};
                            ,{"DRAFT",          -1};
                            ,{"LOW",            -2};
                            ,{"MEDIUM",         -3};
                            ,{"HIGH",           -4};
                            ,{"ILD_NORMAL",     0x0000}; /* IMAGELIST DRAWING STYLES */
                            ,{"ILD_MASK",       0x0010};
                            ,{"ILD_BLEND25",    0x0002};
                            ,{"ILD_BLEND50",    0x0004};
                            ,{"DMDUP_SIMPLEX"   ,1};   /* duplex enable */
                            ,{"DMDUP_VERTICAL"  ,2};
                            ,{"DMDUP_HORIZONTAL",3};
                            ,{"OFF"             ,1};
                            ,{"SIMPLEX"         ,1};
                            ,{"VERTICAL"        ,2};
                            ,{"HORIZONTAL"      ,3};
                            ,{"DT_TOP"                 , 0x00000000};
                            ,{"DT_LEFT"                , 0x00000000};
                            ,{"DT_CENTER"              , 0x00000001};
                            ,{"DT_RIGHT"               , 0x00000002};
                            ,{"DT_VCENTER"             , 0x00000004};
                            ,{"DT_BOTTOM"              , 0x00000008};
                            ,{"DT_WORDBREAK"           , 0x00000010};
                            ,{"DT_SINGLELINE"          , 0x00000020};
                            ,{"DT_EXPANDTABS"          , 0x00000040};
                            ,{"DT_TABSTOP"             , 0x00000080};
                            ,{"DT_NOCLIP"              , 0x00000100};
                            ,{"DT_EXTERNALLEADING"     , 0x00000200};
                            ,{"DT_CALCRECT"            , 0x00000400};
                            ,{"DT_NOPREFIX"            , 0x00000800};
                            ,{"DT_INTERNAL"            , 0x00001000};
                            ,{"DT_EDITCONTROL"         , 0x00002000};
                            ,{"DT_PATH_ELLIPSIS"       , 0x00004000};
                            ,{"DT_END_ELLIPSIS"        , 0x00008000};
                            ,{"DT_MODIFYSTRING"        , 0x00010000};
                            ,{"DT_RTLREADING"          , 0x00020000};
                            ,{"DT_WORD_ELLIPSIS"       , 0x00040000};
                            ,{"DT_NOFULLWIDTHCHARBREAK", 0x00080000};
                            ,{"DT_HIDEPREFIX"          , 0x00100000};
                            ,{"DT_PREFIXONLY"          , 0x00200000};
                            ,{"HB_ZEBRA_FLAG_CHECKSUM" ,          1};
                            ,{"HB_ZEBRA_FLAG_WIDE2"    ,       0x00};  // Dummy flag - default
                            ,{"HB_ZEBRA_FLAG_WIDE2_5"  ,       0x40};
                            ,{"HB_ZEBRA_FLAG_WIDE3"    ,       0x80};
                            ,{"HB_ZEBRA_FLAG_PDF417_TRUNCATED"    , 0x0100};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL_MASK"   , 0xF000};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL0"       , 0x1000};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL1"       , 0x2000};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL2"       , 0x3000};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL3"       , 0x4000};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL4"       , 0x5000};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL5"       , 0x6000};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL6"       , 0x7000};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL7"       , 0x8000};
                            ,{"HB_ZEBRA_FLAG_PDF417_LEVEL8"       , 0x9000};
                            ,{"HB_ZEBRA_FLAG_DATAMATRIX_SQUARE"   , 0x0100};
                            ,{"HB_ZEBRA_FLAG_DATAMATRIX_RECTANGLE", 0x0200};
                            ,{"HB_ZEBRA_FLAG_QR_LEVEL_MASK"       , 0x0700};
                            ,{"HB_ZEBRA_FLAG_QR_LEVEL_L"          , 0x0100};
                            ,{"HB_ZEBRA_FLAG_QR_LEVEL_M"          , 0x0200};
                            ,{"HB_ZEBRA_FLAG_QR_LEVEL_Q"          , 0x0300};
                            ,{"HB_ZEBRA_FLAG_QR_LEVEL_H"          , 0x0400}}

METHOD New ()  CONSTRUCTOR
METHOD ISMONO(arg1)
METHOD SPLASH ()
METHOD CHOICEDRV()
METHOD DoPr ()
METHOD DoPdf ()
METHOD DoMiniPr ()
METHOD fGetline (handle)
METHOD Transpace ()
METHOD MACROCOMPILE ()
METHOD TRADUCI ()
METHOD LEGGIPAR ()
METHOD WHAT_ELE ()
METHOD MEMOSAY ()
METHOD PUTARRAY(row,col,arr,awidths,rowheight,vertalign,noframes,abrushes,apens,afonts,afontscolor,abitmaps,userfun)
METHOD HATCH ()
METHOD GROUP ()
METHOD GrHead ()
METHOD GFeet ()
METHOD UsaFont ()
METHOD Hgconvert ()
METHOD TheHead ()
METHOD TheBody ()
METHOD TheFeet ()
METHOD UsaColor ()
METHOD SETMYRGB ()
METHOD QUANTIREC ()
METHOD COUNTSECT (EXEC)
METHOD CheckUnits()
METHOD UseFLags(arg1)
METHOD Colstep(nfsize,width)
METHOD PgenSet()
METHOD JUSTIFICALINEA ()
METHOD CheckAlign(arrypar)
METHOD GestImage ( image )
METHOD MixMsay()
METHOD DrawBarcode( nRow,nCol,nHeight, nLineWidth, cType, cCode, nFlags )
METHOD Vruler ( pos )
METHOD Hruler ( pos )
METHOD DXCOLORS(par)
/*
METHOD SaveData()
*/
METHOD END()
*/
ENDCLASS
/*
*/
*-----------------------------------------------------------------------------*
METHOD New() CLASS WREPORT
*-----------------------------------------------------------------------------*
return self
/*
*/
*-----------------------------------------------------------------------------*
METHOD End() CLASS WREPORT
*-----------------------------------------------------------------------------*
release ::F_HANDLE,::aDeclare,::AHead,::ABody,::AFeet,::Hb,::Valore,::mx_ln_doc;
,       ::PRNDRV,::argm,::aStat
RELEASE ::ach , ::filename
return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD IsMono(arg1) CLASS WREPORT
*-----------------------------------------------------------------------------*
Local en, rtv := .F.
for each en in arg1
    if valtype(en)=="A"
       exit
    Else
       rtv := .t.
       Exit
    Endif
next
return rtv
/*
*/
*-----------------------------------------------------------------------------*
METHOD COUNTSECT(EXEC) CLASS WREPORT
*-----------------------------------------------------------------------------*
DEFAULT EXEC TO .F.
    IF EXEC
       ::HB := eval(::Valore,::aHead[1] );
            +  eval(::Valore,::aBody[1] )
       ::mx_ln_doc := ::hb + eval(::Valore,::aFeet[1])
    Endif
return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD CheckUnits( arg1 ) CLASS WREPORT //returns the units used
*-----------------------------------------------------------------------------*
   Local aUnit:={{0,"RC"},{1,"MM"},{2,"IN"},{3,"PN"} }

   Do case
      case oWr:PrnDrv = "MINI"
           ::aStat [ 'Units' ] :="MM"

      case oWr:PrnDrv = "HBPR"
           default arg1 to hbprn:units
           ::aStat [ 'Units' ] := aunit[ascan(aUnit,{|x|x[1]=arg1}),2]

      case oWr:PrnDrv = "PDF"
           ::aStat [ 'Units' ] :="MM"
   Endcase

return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD UseFlags( arg1 ) CLASS WREPORT //returns the FLAGS
*-----------------------------------------------------------------------------*
   Local aFlg := "" , aSrc := 0, nn ,rtv := 0
   default arg1 to ""
   aFlg := HB_ATOKENS(arg1,"+")
   for each nn in aFlg
       aSrc := ASCAN(::aCh, {|aVal| aVal[1] == alltrim(nn)})
       if aSrc > 0  // sum the flags if necessary
          rtv += ::aCh[asrc,2]
       Endif
   next
return rtv
/*
*/
*-----------------------------------------------------------------------------*
METHOD COLSTEP(nfsize,width) CLASS WREPORT
*-----------------------------------------------------------------------------*
Local ncpl1 := eval(oWr:Valore,oWr:Adeclare[1])
DEFAULT width to 1 , nfsize to 12

do case
   case ::aStat [ 'Units' ] = "RC"
        ::aStat [ 'cStep' ] := width / nfsize

   case ::aStat [ 'Units' ] = "MM"
        ::aStat [ 'cStep' ] := width / nfsize

Endcase

return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD pGenSet() CLASS WREPORT
*-----------------------------------------------------------------------------*
Local Plist:= {'ORIENTATION','PAPERSIZE','PAPERLENGTH','PAPERWIDTH';
              ,'COPIES','BIN','DEFAULTSOURCE','QUALITY','COLORMODE','DUPLEX';
              ,'COLLATE'}
Local arrypar := {} , s , k
Local blso := {|x| if(val(x)> 0,min(val(x),1),if(x=".T.".or. x ="ON",1,0))}
// return two array
FOR EACH s IN oWr:aDeclare
    k := HB_enumindex(s)
    aeval(Plist,{|x| if(x $ upper(s[1]);
                        , aadd(arrypar ;
                        ,HB_ATOKENS(upper(::aDeclare[k][1]),chr(07),.T.,.F. ));
                        ,NIL) } )
NEXT
// Set adeguate parameter
FOR EACH s IN arrypar //Pi

    do case
       case ascan(arrypar[HB_enumindex(s)],[ORIENTATION])=2   //SET ORIENTATION
            ::aStat[ 'Orient' ] := ;
            if ([LAND] $ eval(chblk,arrypar[HB_enumindex(s)],[ORIENTATION]),2,1)
            //MSGBOX(VALTYPE(::aStat[ 'Orient' ]))

       case ascan(arryPar[HB_enumindex(s)],[PAPERSIZE])=2   //SET PAPERSIZE
            ::aStat[ 'PaperSize' ] := ::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[PAPERSIZE]),::aCh,"_apaper")

       case ascan(arryPar[HB_enumindex(s)],[PAPERSIZE])=3   //SET PAPERSIZE
            ::aStat[ 'PaperSize' ]   := 0
            ::aStat[ 'PaperLength' ] := val(eval(chblk,arrypar[HB_enumindex(s)],[HEIGHT]))
            ::aStat[ 'PaperWidth' ]  := val(eval(chblk,arrypar[HB_enumindex(s)],[WIDTH] ))

       case ascan(arrypar[HB_enumindex(s)],[COPIE])= 2
            ::aStat[ 'Copies' ] := ;
            max(val(eval(chblk,arrypar[HB_enumindex(s)],[TO])) ,1 )

       case ascan(arrypar[HB_enumindex(s)],[BIN])= 2
            if val(Arrypar[HB_enumindex(s),3])> 0
               ::aStat [ 'Source' ] := val(Arrypar[HB_enumindex(s),3])
            else
               ::aStat [ 'Source' ] := ::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[BIN]),::aCh,"_ABIN")
            Endif
            if ::aStat [ 'Source' ] < 1
               ::aStat [ 'Source' ] := 1
            Endif

       case ascan(arrypar[HB_enumindex(s)],[QUALITY])= 2
            ::aStat [ 'Res' ] := ;
            ::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[QUALITY]),::aCh,"_aQlt")
            if ::aStat [ 'Res' ] > -1
               ::aStat [ 'Res' ] := -3
            Endif

       case ascan(arrypar[HB_enumindex(s)],[COLORMODE])= 2
           ::aStat[ 'ColorMode' ] := ;
           if(val(arrypar[HB_enumindex(s),3])>0,val(arrypar[HB_enumindex(s),3]);
           ,if(arrypar[HB_enumindex(s),3]=".T.",2;
           ,::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[COLORMODE]),::aCh,"_acolor")))
           ::aStat[ 'ColorMode' ] := MIN (::aStat[ 'ColorMode' ] ,2)

       case ascan(arrypar[HB_enumindex(s)],[DUPLEX])= 2
            ::aStat[ 'Duplex' ] := ;
            max(::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[DUPLEX]),::aCh,"_aDuplex"),1)

       case ascan(arrypar[HB_enumindex(s)],[COLLATE])= 2
            if len(arrypar[HB_enumindex(s)])> 2
               ::aStat[ 'Collate' ] := ;
               eval(blso,arrypar[HB_enumindex(s),3])
            Endif

    EndCase
Next

if ::aStat[ 'PaperSize' ] > 0
   ::aStat[ 'PaperLength' ] := 0
   ::aStat[ 'PaperWidth'  ] := 0
Endif
if ::aStat[ 'PaperLength' ] + ::aStat[ 'PaperWidth'  ] = 0
   ::aStat[ 'PaperSize' ] = 9 // A4 Default
Else
   ::aStat[ 'PaperSize' ] = 256 // PAPER USER
Endif
if (::aStat[ 'PaperLength' ] > 0 .and. ::aStat[ 'PaperWidth'  ] = 0) .or. ;
   (::aStat[ 'PaperWidth'  ] > 0 .and. ::aStat[ 'PaperLength' ] = 0)
   MsgExclamation("Incorrect page size !"+CRLF+"Please revise Heigth/width in your script.","Error")
Endif

Return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD CheckAlign( arrypar, cmdline , section ) CLASS WREPORT //returns the correct alignment
*-----------------------------------------------------------------------------*
Local vr:= "", _arg3, aAlign := {"CENTER","RIGHT","JUSTIFY"}
empty(cmdline);empty(section)

      if ASCAN(arryPar,[ALIGN]) > 0
         vr := rtrim(if("->" $ eval(chblk,arrypar,[ALIGN]) .or. [(] $ eval(chblk,arrypar,[ALIGN]),::MACROCOMPILE(eval(chblk,arrypar,[ALIGN]),.t.,cmdline,section),eval(chblk,arrypar,[ALIGN])))
      Else
         _arg3 := ascan( aAlign,atail (arrypar))
         if _arg3 > 0
            vr := aAlign[_arg3]
         Else
            vr :=""
         Endif
      Endif

return vr
/*
*/
*-----------------------------------------------------------------------------*
METHOD Splash(prc_init,sezione,rit) CLASS WREPORT
*-----------------------------------------------------------------------------*
   Local rtv ,cbWork :={|x| x }
   private ritspl
   default sezione to ""
   default prc_init to "_dummy_("+sezione+")"
   default rit to .F.
   ritspl := rit
   if _IsWIndowDefined ( "Form_splash" )
      Setproperty ("FORM_SPLASH","Label_1","VALUE", ::aStat [ 'lblsplash' ] )
      domethod("FORM_SPLASH","SHOW")
      ::choiceDrv()
      DOMETHOD("FORM_SPLASH","RELEASE")
      return nil
   Endif
   if empty(::aStat[ 'lblsplash' ])
      DEFINE WINDOW FORM_SPLASH AT 140 , 235 WIDTH 0 HEIGHT 0 MODAL NOSHOW NOSIZE NOSYSMENU NOCAPTION ;
      ON INIT {||::choiceDrv()}

   else
      DEFINE WINDOW FORM_SPLASH AT 140 , 235 WIDTH 550 HEIGHT 240 MODAL NOSIZE NOCAPTION ;
      ON INIT {||::choiceDrv()}

      DRAW RECTANGLE IN WINDOW Form_splash AT 2,2 TO 235, 548
   Endif
   DEFINE LABEL Label_1
          ROW    50
          COL    30
          WIDTH  480
          HEIGHT 122
          VALUE ::aStat[ 'lblsplash' ]
          FONTNAME "Times New Roman"
          FONTSIZE 36
          FONTBOLD .T.
          FONTCOLOR {255,0,0}
          CENTERALIGN .T.
   END LABEL

END WINDOW

   center window Form_Splash
   activate window Form_Splash //NOWAIT
   rtv := ritspl
   release ritspl
return rtv
/*
*/
*-----------------------------------------------------------------------------*
METHOD DoPr() CLASS WREPORT
*-----------------------------------------------------------------------------*
*   ::argm:={_MainArea,_psd,db_arc,_prw}
*   stampeEsegui(_MainArea,_psd,db_arc,_prw)
    CursorWait()
    ritspl := StampeEsegui(::argm[1],::argm[2],::argm[3],::argm[4])
    CursorArrow()
return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD DoMiniPr() CLASS WREPORT
*-----------------------------------------------------------------------------*
   CursorWait()
   ritspl := PrminiEsegui(::argm[1],::argm[2],::argm[3],::argm[4])
   CursorArrow()
return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD DoPdf() CLASS WREPORT
*-----------------------------------------------------------------------------*
   CursorWait()
   ritspl := PrPdfEsegui(::argm[1],::argm[2],::argm[3],::argm[4])
   CursorArrow()
return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD ChoiceDrv() CLASS WREPORT
*-----------------------------------------------------------------------------*
      do case
         case oWr:PrnDrv = "HBPR"
              ::doPr()

         Case oWr:PrnDrv = "MINI"
              ::doMiniPr()

         Case oWr:PrnDrv = "PDF"
              ::dopdf()
      End
return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD FgetLine(handle)  CLASS WREPORT
*-----------------------------------------------------------------------------*
Local rt_line := '', chunk := '', bigchunk := '', at_chr13 :=0 , oldoffset := 0

        oldoffset := FSEEK(handle,0,1)
        DO WHILE .T.

          *- read in a chunk of the file
          chunk := ''
          chunk := Freadstr(handle,100)

          *- if we didn't read anything in, guess we're at the EOF
          IF LEN(chunk)=0
             endof_file := .T.

             IF !EMPTY(bigchunk)
               rt_line := bigchunk
             Endif
             EXIT
          elseif len(bigchunk) > 1024
             EXIT
          Endif

          *- add this chunk to the big chunk
          bigchunk := bigchunk+chunk

          *- if we've got a CR , we've read in a line
          *- otherwise we'll loop again and read in another chunk
          IF AT(CHR(13),bigchunk) > 0
             at_chr13 := AT(CHR(13),bigchunk)

             *- go back to beginning of line
             FSEEK(handle,oldoffset)

             *- read in from here to next CR (-1)
             rt_line := Freadstr(handle,at_chr13-1)

             *- move the pointer 1 byte
             FSEEK(handle,1,1)

             EXIT
          Endif
        ENDDO

        *- move the pointer 1 byte
        *- this should put us at the beginning of the next line
        FSEEK(handle,1,1)

RETURN rt_line

/*
*/
*-----------------------------------------------------------------------------*
METHOD Transpace(arg1,arg2,arg3) CLASS WREPORT // The core of parser
*-----------------------------------------------------------------------------*
     Local al1 := .F., al2 := .F., extFnc := .F. , tmpstr := '' , n
     Local nr  := '', opp := 0 , pt := '', cdbl := .F., cdc := 0
     Local last_func  := rat(")",arg1), last_sapex := rat(['],arg1)
     Local last_Dapex := rat(["],arg1), last_codeb := rat([}],arg1)
     Local arges := '' ;
         , aFsrc :={"SELECT"+CHR(7)+"FONT","DRAW"+CHR(7)+"TEXT","TEXTOUT"+CHR(7),"SAY"+CHR(7);
                   ,"PRINT" +CHR(7),"GET"+CHR(7)+"TEXT","DEFINE"+CHR(7)+"FONT"}
     Static xcl := .F.
     default arg2 to .T.
     arg1 := alltrim(arg1)
     arges := arg1
     // (#*&/) char exclusion
     if left (arges,1) = chr(35) .or. left(arges,1) = chr(38); arges := '' ;Endif
     if left (arges,2) = chr(47)+chr(47) ;arges := '' ;Endif
     if left (arges,2) = chr(47)+chr(42) ; xcl := .T. ;Endif
     if right(arges,2) = chr(42)+chr(47) ; xcl := .F. ;Endif
     if left (arges,1) = chr(42) .or. empty(arges) .or. xcl
        return ''
     Endif
     if "SET SPLASH TO" $ upper(arg1)
        ::aStat [ 'lblsplash' ] := substr(arg1,at("TO",upper(arg1))+2)
        // msgbox("|"+::aStat [ 'lblsplash' ]+"|" ,"Arges")
        return ''
     Endif
     for n := 1 to len (arg1)
         pt := substr(arg1,n,1)
         if pt <> chr(32)
            tmpstr := pt
            nr += pt
            if tmpstr == chr(40) //.or. upper(substr(arg1,2,3)) = [VAR]  // (=chr(40)
               opp ++
               extFnc := .T.     // Interno a Funzione
            Endif
            if tmpstr == chr(41) // ")"
               opp --
               extFnc := .F.    // Fine Funzione
            Endif
            if tmpstr == '"' .or. tmpstr == '[' .or. tmpstr == ['] .or. tmpstr == [{]
               al1 := !al1
               if tmpstr == '{'
                  cdc ++
               Endif
            Endif
            if tmpstr == "]" .or. n = last_Dapex .or. n = last_sapex .or. n = last_codeb  .or. tmpstr == [}]
               al1 := .F.
               if tmpstr == [}]
                  cdc --
               Endif
            Endif
            if n >= last_func
               extFnc := .F.
               al2 := .F.
            Endif
            if tmpstr = "|" .and. cdc > 0
               extfnc := .T.
            elseif cdc < 1
               extfnc := .F.
            Endif
            if Pt == ',' .and. extFnc == .F. .and. al1 == .F. .and. opp < 1
               nr := substr(nr,1,len(nr)-1) + chr(07)
            Endif
         else
            if extFnc == .F.        //esterno a funzione
               if al1 == .F.
                  if opp < 1
                     nr += IIF(al2," ",chr(07)) //"/")
                  Endif
               else
                  nr += pt
               Endif
            else
               nr += pt
            Endif
         Endif
     next
     nr := strtran(nr,chr(07)+chr(07),chr(07))
     tmpstr = left(ltrim(nr),1)
     do case
        case tmpstr = chr(60) .or. tmpstr = "@" .or. tmpstr = chr(07) //"<" ex "{"
             nr := substr(nr,2)

        case left(nr,1) = chr(07) .or. left(nr,1) = chr(64)
             nr := substr(nr,2)

        case right(nr,1)=chr(62) //">" ex "}"
             nr := substr(nr,1,rat(">",nr)-1)

        case ")" == alltrim(nR) .or. "(" == alltrim(nR)
             nr := ''

     endcase
     nr := STRTRAN(nr,chr(07)+chr(07),chr(07))
     if arg2
        arg1 := upper(nr)
        aeval(aFsrc,{|x|if ( at(x,arg1) > 0, aadd(_aFnt,{upper(Nr),arg3}), Nil ) } )
     Endif

return nr
/*
*/
*-----------------------------------------------------------------------------*
METHOD MACROCOMPILE(cStr, lMesg,cmdline,section) CLASS WREPORT
*-----------------------------------------------------------------------------*
Local bOld,xResult, dbgstr:='', lvl:= 0
default cmdline to 0, section to ''
if lMesg == NIL
  return &(cStr)
Endif
bOld := ErrorBlock({|| break(NIL)})
BEGIN SEQUENCE
xResult := &(cStr)
RECOVER
if lMesg
    //msgBox(alltrim(cStr),"Error in evaluation of:")
    errorblock (bOld)
    if ::aStat [ 'Control' ]
       MsgMiniGuiError("Program Report Interpreter"+CRLF+"Section "+section+CRLF+"I have found error on line "+;
       zaps(cmdline)+CRLF+"Error is in: "+alltrim(cStr)+CRLF+"Please revise it!","MiniGUI Error")
       Break
    else
       do case
          case SECTION = "STAMPEESEGUI"
               SECTION :="DECLARE : "
          case SECTION = "PORT:THEBODY"
               SECTION :="BODY       : "
          case SECTION = "PORT:THEMINIBODY"
               SECTION :="BODY       : "
          case SECTION = "WREPORT_THEHEAD"
               SECTION :="HEAD       : "
          case SECTION = "WREPORT_THEFEET"
               SECTION :="FEET         : "
       endcase

       dbgstr := section+" "+zaps(cmdline)+" With: "+cStr
       aeval(::aStat[ 'ErrorLine' ],{|x|if (dbgstr == x,  lvl:=1 ,'')} )
       if lvl < 1 .and. cmdline > 0 //# ::aStat [ 'ErrorLine' ]
          MSGSTOP(dbgstr,"MiniGui Extended Report Interpreter Error")
          if ascan( ::aStat [ 'ErrorLine' ] , dbgstr ) < 1
             aadd(::aStat [ 'ErrorLine' ] , dbgstr )
          Endif
       Endif
       ::aStat [ 'OneError' ]  := .T.
       break
    Endif
Endif
xResult := "**Error**:"+cStr
END SEQUENCE
errorblock (bOld)
return xResult
/*
*/
*-----------------------------------------------------------------------------*
METHOD Traduci(elemento,ctrl,cmdline) CLASS WREPORT  // The interpreter
*-----------------------------------------------------------------------------*
Local string, ritorno :=.F., ev1th, sSection, dbg := ''
Local TransPar:={}, ArryPar :={}, cWord
Local oErrAntes, oErr, lMyError := .F., ifc:='',IEXE := .F.

sSection := iif(procname(1)="STAMPEESEGUI","DECLARE",substr(procname(1),4))
default ctrl to .F.
string := alltrim(elemento)

if empty(string);return ritorno ;Endif

DO CASE
   CASE upper(left(string,8))="DEBUG_ON"
        ::aStat [ 'Control' ] := .T.
        RETURN RITORNO
   CASE upper(left(string,8))="DEBUG_OF"
        ::aStat [ 'Control' ] := .F.
        ::aStat['DebugType'] := "LINE"
   CASE upper(left(string,9))=="SET"+chr(07)+"DEBUG"
        dbg := upper(right(string,4))
        ::aStat [ 'Control' ] := if(val(dbg)> 0,.t.,if(".T." $ dbg .or. "ON" $ Dbg ,.t.,.F.))
        if "LINE" $ dbg
           ::aStat [ 'Control' ] := .t.
           ::aStat['DebugType'] := "LINE"
        Endif
        if "STEP" $ dbg
           ::aStat [ 'Control' ] := .t.
           ::aStat['DebugType'] := "STEP"
        Endif
        RETURN RITORNO
ENDCASE

TOKENINIT(string,chr(07))    //set the command separator -> ONLY A BEL

While ! TOKENEND()           //                             ----
   cWord  :=  TOKENNEXT(String)
   if left(cword,1)="[" .and. right(cword,1) <> "]"
      cword := substr(cword,2)+" "+TOKENNEXT(String)
      while .t.
         if right(cword,1)="]"
            cword := substr(cword,1,len(cword)-1)
            cword := strtran(cword,chr(4),"/")
            aadd(TransPar,cWord)
            exit
         else
            cword += " "+TOKENNEXT(String)
         Endif
      end
   elseif left(cword,1)="[" .AND. "]" $ cWord
          cWord := substr(cword,at("[",cWord)+1,rat("]",cword)-2)
          cword := strtran(cword,chr(4),"/")
          aadd(TransPar,cWord)
   else
       if "[" $ cWord .or. ["] $ cWord .or. ['] $ cWord
          cword := strtran(cword,chr(4),"/")
          aadd(TransPar,cWord)
       else
          cword := strtran(cword,chr(4),"/")
          aadd(TransPar,upper(cWord))
       Endif
   Endif
END

if "{" $ left(TransPar[1],2)
   ev1th := alltrim(substr(TransPar[1],at("||",TransPar[1])+2,at("}",Transpar[1])-4))
   if empty(ev1th)
      MsgMiniGuiError("Program Report Interpreter"+CRLF+"Section: "+procname(1);
      +" command n› "+zaps(cmdline)+CRLF+"Program terminated","MiniGUI Error")
   Endif
   do case
      case ev1th = ".T."
          adel(TransPar,1)

      case ev1th = ".F."
          adel(TransPar,1)
          return ritorno
   otherwise

      if eval(epar,ev1th)
         adel(TransPar,1)
         ritorno := .F.
      else
         if sSEction=="HEAD"
            nline ++
         Endif
         ritorno := .t.
      Endif
   endcase
Endif
ifc := alltrim( upper( TransPar[1] ) )
oErrAntes := ERRORBLOCK({ |objErr| BREAK(objErr) } )
BEGIN SEQUENCE
      if ifc == "IF"     /// Start adaptation if else construct - 03/Feb/2008
         ::aStat [ 'EntroIF' ] := .T.
         ifc := substr(string,at(chr(07),string)+1 )
         if &ifc //MACROCOMPILE(ifc,.t.,cmdline,ssection)
            // msgbox(ifc,"valido")
            ::aStat [ 'DelMode' ] := .F.
         Else
            // msgstop(ifc, "Non valido")
            ::aStat [ 'DelMode' ]:= .T.
         Endif
      Elseif "ENDI" $ ifc
         TransPar := {}
         ::aStat [ 'DelMode' ] := .F.
         ::aStat [ 'ElseStat' ] := .F.
      Elseif "ELSE" $ ifc
         ::aStat [ 'EntroIF' ] := .F.
         ::aStat [ 'ElseStat' ] := .T.
      Endif
       //msgbox(if( ::aStat [ 'DelMode' ]," ::aStat [ 'DelMode' ] .t.","::aStat [ 'DelMode' ] .F.")+crlf+if( ::aStat [ 'ElseStat' ]," ::aStat [ 'ElseStat' ] .t.","::aStat [ 'ElseStat' ] .F.")," risulta")
      if !::aStat [ 'EntroIF' ] .and. !::aStat [ 'DelMode' ] // i am on false condition
         if ::aStat [ 'ElseStat' ]
            //msginfo(ifc ,"Cancellato")
            adel(TransPar,1)    // i must erase else commands
         Endif
      Endif
      if ::aStat [ 'EntroIF' ] .and. ::aStat [ 'DelMode' ] // i am on verified condition
         if ::aStat [ 'DelMode' ] .and. !::aStat [ 'ElseStat' ]
            //msgbox(ifc ,"Cancellato")
            adel(TransPar,1)// i must erase if commands
         Endif
      Endif

      aeval(transpar,{|x| if(x # NIL,aadd(ArryPar,X), nil ) } )

      if (::aStat [ 'Control' ] .and. (UPPER(LEFT(STRING,5)) <> "DEBUG") ) .and.  npag < 2
         if ::aStat['DebugType'] = "LINE"
            MsgBox("Section "+ssection+" Line is n∞ "+zaps(cmdline)+CRLF+"String = "+string ;
            ,::Filename+[ Pag n∞]+zaps(npag))
         Elseif ::aStat['DebugType'] = "STEP"
            aeval(Arrypar,{|x,y|x:=nil,MsgBox("Section "+ssection+" Line is n∞ "+zaps(cmdline)+CRLF+"String =";
            +string+CRLF+CRLF+"Argument N∞-> "+zaps(y)+[ ]+ArryPar[y],::Filename+[ Pag n∞]+zaps(npag))})
         Endif
      Endif
      ::leggipar(Arrypar,cmdline,substr(procname(1),4))
      RECOVER USING oErr
      if oErr <> NIL
         lMyError := .T.
         MyErrorFunc(oErr)
      Endif
END
ERRORBLOCK(oErrAntes)
   if lMyError .and. ::aStat [ 'Control' ]
      MsgBox("Error in  line n∞ "+zaps(cmdline)+CRLF+string,+::Filename+[ Pag n∞]+zaps(npag) )
   Endif
*/
return ritorno
/*
*/
*-----------------------------------------------------------------------------*
METHOD Leggipar(ArryPar,cmdline,section) CLASS WREPORT // The core of  interpreter
*-----------------------------------------------------------------------------*
     Local _arg1,_arg2, _arg3,__elex ,aX:={} , _varmem ,;
     blse := {|x| if(val(x)> 0,.t.,if(x=".T.".or. x ="ON",.T.,.F.))}, al, _align;

     string1 := ''
     empty(_arg3)
     if len (ArryPar) < 1 ;return .F. ;Endif

     do case
        case ::PrnDrv = "MINI"
             //msginfo(arrypar[1],"Rmini")
             RMiniPar(ArryPar,cmdline,section)

        case ::PrnDrv = "PDF"
             //msginfo(arrypar[1],"Pdf")
             RPdfPar(ArryPar,cmdline,section)

        case ::PrnDrv = "HBPR"
             //msginfo(arrypar[1],"HBPRN")
         m->MaxCol := hbprn:maxcol
        //m->MaxRow := hbprn:maxrow
        do case
           case ArryPar[1]=[VAR]
                _varmem := ArryPar[2]
                If ! __MVEXIST ( ArryPar[2] )
                   _varmem := ArryPar[2]
                   Public &_varmem
                   aadd(nomevar,_varmem)
                Endif
                do case
                   case ArryPar[3] == "C"
                        &_varmem := xvalue(ArryPar[4],ArryPar[3])

                   case ArryPar[3] == "N"
                        &_varmem := xvalue(ArryPar[4],ArryPar[3])

                   case ArryPar[3] == "A"
                        &_varmem := ::MACROCOMPILE("("+ArryPar[4]+")",.t.,cmdline,section)

                   case ArryPar[4] == "C"
                        &_varmem := xvalue(ArryPar[3],ArryPar[4])

                   case ArryPar[4] == "N"
                        &_varmem := xvalue(ArryPar[3],ArryPar[4])

                   case ArryPar[4] == "A"
                        &_varmem := ::MACROCOMPILE("("+ArryPar[3]+")",.t.,cmdline,section)
                Endcase
                //msgmulty({&_varmem[1],valtype(&_varmem),_varmem})

           case arryPar[1]==[GROUP]
                Group(arryPar[2],arryPar[3],arryPar[4],arryPar[5],arryPar[6],arryPar[7],arryPar[8],arryPar[9])
                /* Alternate method
                aX:={} ; aeval(ArryPar,{|x,y|if (Y >1,aadd(aX,x),Nil)})
                Hb_execFromarray("GROUP",ax)
                asize(ax,0)
                */
           case arryPar[1]==[ADDLINE]
                nline ++

           case arryPar[1]==[SUBLINE]
                nline --

           case ascan(arryPar,[HBPRN ]) > 0
                HBPRNMAXROW:=hbprn:maxrow

           case len(ArryPar)=1
                //msgExclamation(arrypar[1],"int Traduci")
                if "DEBUG_" != left(ArryPar[1],6) .and. "ELSE" != left(ArryPar[1],4)
                   ::MACROCOMPILE(ArryPar[1],.t.,cmdline,section)
                Endif

           case ArryPar[1]+ArryPar[2]=[ENABLETHUMBNAILS]
                hbprn:thumbnails:=.t.

           case ArryPar[1]=[POLYBEZIER]
                hbprn:polybezier(&(arrypar[2]),eval(chblk,arrypar,[PEN]))

           case ArryPar[1]=[POLYBEZIERTO]
                hbprn:polybezierto(&(arrypar[2]),eval(chblk,arrypar,[PEN]))

           case ArryPar[1]+ArryPar[2]=[DEFINEBRUSH]
                hbprn:definebrush(Arrypar[3],::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_abrush");
                ,::UsaColor(eval(chblk,arrypar,[COLOR])),::HATCH(eval(chblk,arrypar,[HATCH])))

           case ArryPar[1]+ArryPar[2]=[CHANGEBRUSH]
                hbprn:changebrush(Arrypar[3],::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_abrush");
                ,color(eval(chblk,arrypar,[COLOR])),::HATCH(eval(chblk,arrypar,[HATCH])))

           case ArryPar[1]+ArryPar[2]=[CHANGEPEN]
                hbprn:modifypen(Arrypar[3],::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_apen"),val(eval(chblk,arrypar,[WIDTH])),color(eval(chblk,arrypar,[COLOR])))

           case ArryPar[1]+ArryPar[2]=[DEFINEIMAGELIST]
                hbprn:defineimagelist(Arrypar[3],eval(chblk,arrypar,[PICTURE]),eval(chblk,arrypar,[ICONCOUNT]))

           case ascan(arrypar,[IMAGELIST]) > 0 .and. len(arrypar) > 6
                do case
                   case ascan(arryPar,[BLEND25]) > 0
                        hbprn:drawimagelist(eval(chblk,arrypar,[IMAGELIST]),val(eval(chblk,arrypar,[ICON]));
                        ,eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
                        ,ILD_BLEND25,::UsaColor(eval(chblk,arrypar,[BACKGROUND])))

                   case ascan(arryPar,[BLEND50]) > 0
                        hbprn:drawimagelist(eval(chblk,arrypar,[IMAGELIST]),val(eval(chblk,arrypar,[ICON]));
                        ,eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
                        ,ILD_BLEND50,::UsaColor(eval(chblk,arrypar,[BACKGROUND])))

                   case ascan(arryPar,[MASK]) > 0
                        hbprn:drawimagelist(eval(chblk,arrypar,[IMAGELIST]),val(eval(chblk,arrypar,[ICON]));
                        ,eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
                        ,ILD_MASK,::UsaColor(eval(chblk,arrypar,[BACKGROUND])))

                   otherwise
                        hbprn:drawimagelist(eval(chblk,arrypar,[IMAGELIST]),val(eval(chblk,arrypar,[ICON]));
                        ,eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
                        ,ILD_NORMAL,::UsaColor(eval(chblk,arrypar,[BACKGROUND])))

                endcase

           case ArryPar[1]+ArryPar[2]=[DEFINEPEN]
                hbprn:definepen(Arrypar[3],::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_apen"),val(eval(chblk,arrypar,[WIDTH])),color(eval(chblk,arrypar,[COLOR])))

           case ArryPar[1]+ArryPar[2]=[DEFINERECT]
                hbprn:definerectrgn(eval(chblk,arrypar,[REGION]),val(eval(chblk,arrypar,[AT]));
                ,val(Arrypar[7]),val(Arrypar[8]),val(Arrypar[9]))

           case ArryPar[1]+ArryPar[2]=[DEFINEROUNDRECT]
                hbprn:defineroundrectrgn(eval(chblk,arrypar,[REGION]),val(eval(chblk,arrypar,[AT]));
                ,val(Arrypar[7]),val(Arrypar[8]),val(Arrypar[9]);
                ,eval(chblk,arrypar,[ELLIPSE]),Val(ArryPar[12]))

           case ArryPar[1]+ArryPar[2]=[DEFINEPOLYGON]
                hbprn:definepolygonrgn(eval(chblk,arrypar,[REGION]),&(eval(chblk,arrypar,[VERTEX]));
                ,eval(chblk,arrypar,[STYLE]))

           case ArryPar[1]+ArryPar[2]=[DEFINEELLIPTIC]
                hbprn:defineEllipticrgn(eval(chblk,arrypar,[REGION]),val(eval(chblk,arrypar,[AT]));
                ,eval(epar,ArryPar[7]),eval(epar,ArryPar[8]),eval(epar,ArryPar[9]))

           case ArryPar[1]+arryPar[2]=[DEFINEFONT]
                //                    1        2      3      4       5        6        7            8            9
                //hbprn:definefont(<cfont>,<cface>,<size>,<width>,<angle>,<.bold.>,<.italic.>,<.underline.>,<.strikeout.>)
                hbprn:definefont(if(ascan(arryPar,[FONT])=2,ArryPar[3],NIL);
                           ,if(ascan(arryPar,[NAME])=4,ArryPar[5],NIL);
                           ,if(ascan(arryPar,[SIZE])=6,VAL(ArryPar[7]),NIL);
                           ,if(ascan(arryPar,[WIDTH])# 0, VAL(eval(chblk,arrypar,[WIDTH])),NIL);
                           ,if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL);
                           ,if(ascan(arryPar,[BOLD])# 0,1,"");
                           ,if(ascan(arryPar,[ITALIC])# 0,1,"");
                           ,if(ascan(arryPar,[UNDERLINE])# 0,1,"");
                           ,if(ascan(arryPar,[STRIKEOUT])# 0,1,""))

           case ArryPar[1]+arryPar[2]=[CHANGEFONT]
                hbprn:modifyfont(if(ascan(arryPar,[FONT])=2,ArryPar[3],NIL);
                           ,if(ascan(arryPar,[NAME])=4,ArryPar[5],NIL);
                           ,if(ascan(arryPar,[SIZE])=6,VAL(ArryPar[7]),NIL);
                           ,if(ascan(arryPar,[WIDTH])# 0, VAL(eval(chblk,arrypar,[WIDTH])),NIL);
                           ,if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL);
                           ,if(ascan(arryPar,[BOLD])#0,.T.,.F.);
                           ,if(ascan(arryPar,[NOBOLD])#0,.T.,.F.);
                           ,if(ascan(arryPar,[ITALIC])#0,.t.,.F.);
                           ,if(ascan(arryPar,[NOITALIC])#0,.t.,.F.);
                           ,if(ascan(arryPar,[UNDERLINE])#0,.t.,.F.);
                           ,if(ascan(arryPar,[NOUNDERLINE])#0,.t.,.F.);
                           ,if(ascan(arryPar,[STRIKEOUT])#0,.t.,.F.);
                           ,if(ascan(arryPar,[NOSTRIKEOUT])#0,.t.,.F.))

           case ArryPar[1]+arryPar[2]=[COMBINEREGIONS]
                hbprn:combinergn(eval(chblk,arrypar,[TO]),ArryPar[3],ArryPar[4];
                ,if( val(ArryPar[8])>0,val(ArryPar[8]),::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_aRegion")))

           case ascan(arryPar,"SELECT")=1 .and. len(ArryPar)=3
                if len(ArryPar)=3
                   do case
                      case ascan(ArryPar,[PRINTER])=2
                           hbprn:selectprinter(arrypar[3])

                      case ascan(ArryPar,[FONT])=2
                           hbprn:selectfont(arrypar[3])

                      case ascan(ArryPar,[PEN])=2
                           hbprn:selectpen(arrypar[3])

                      case ascan(ArryPar,[BRUSH])=2
                           hbprn:selectbrush(arrypar[3])

                   endcase
                Endif

           case ArryPar[1]+ArryPar[2]="SELECTCLIP" .and. len(ArryPar)=4
                hbprn:selectcliprgn(eval(chblk,arrypar,[REGION]))

           case ascan(arryPar,"DELETE")=1 .and. len(ArryPar)=4
                hbprn:deletecliprgn()

           case ascan(arryPar,"SET")=1
                do case
                   case ascan(arryPar,[VRULER])= 2
                        ::astat ['VRuler'][1] := val(eval(chblk,arrypar,[VRULER]))
                        if len(arrypar) > 3
                           ::astat ['VRuler'][2] := eval(blse,eval(chblk2,arrypar,[VRULER]))
                        Else
                           ::astat ['VRuler'][2] := .F.
                        Endif

                   case ascan(arryPar,[HRULER])= 2
                        ::astat ['HRuler'][1] := val(eval(chblk,arrypar,[HRULER]))
                        if len(arrypar) > 3
                           ::astat ['HRuler'][2] := eval(blse,eval(chblk2,arrypar,[HRULER]))
                        Else
                           ::astat ['HRuler'][2] := .F.
                        Endif

                   case ascan(arryPar,[COPIES])= 2
                        ::aStat[ 'Copies' ] := val(eval(chblk,arrypar,[TO]))
                        hbprn:setdevmode(256,::aStat[ 'Copies' ] )

                   case ascan(arryPar,[JOB])= 2
                        ::aStat [ 'JobName' ] := eval(chblk,arrypar,[NAME])

                   case ascan(ArryPar,[PAGE])=2
                        _arg1 :=eval(chblk,arrypar,[ORIENTATION])
                        ::aStat[ 'Orient' ] := if([LAND]$ _arg1,2,1)
                        ::aStat[ 'PaperSize' ] := ::what_ele(eval(chblk,arrypar,[PAPERSIZE]),::aCh,"_apaper")
                        _arg2 :=eval(chblk,arrypar,[FONT])
                        hbprn:setpage(if(val(_arg1)>0,val(_arg1),::aStat[ 'Orient' ]);
                        ,::aStat[ 'PaperSize' ],_arg2)

                   case ascan(arryPar,[ALIGN])=3
                        if val(Arrypar[4])> 0
                           _align := val(Arrypar[4])
                        else
                           _align := ::what_ele(eval(chblk,arrypar,[ALIGN]),::aCh,"_aAlign")
                        Endif
                        hbprn:settextalign(_align)

                   case ascan(arryPar,[RGB])=2
                        &(eval(chblk,arrypar,[TO])):=hbprn:setrgb(arrypar[1],arrypar[2],arrypar[3])

                   case ascan(arryPar,[SCALE])=3      //SET SCALE
                        if ascan(arryPar,[SCALE])> 0
                           hbprn:previewscale:=(val(eval(chblk,arrypar,[SCALE])))
                        elseif ascan(arryPar,[RECT])> 0
                           hbprn:previewrect:={eval(epar,arrypar[4]),eval(epar,arrypar[5]),eval(epar,arrypar[6]),eval(epar,arrypar[7])}
                        Endif

                   case ascan(ArryPar,[DUPLEX])=2
                        ::aStat[ 'Duplex' ] := ::what_ele(eval(chblk,arrypar,[DUPLEX]),::aCh,"_aDuplex")
                        hbprn:setdevmode(DM_DUPLEX,::aStat[ 'Duplex' ])

    	               case ascan(ArryPar,[PREVIEW])=2 .and. len(arrypar)= 3
                        hbprn:PreviewMode := if(eval(chblk,arrypar,[PREVIEW])=[OFF],.F.,.T.)

                   case ascan(arryPar,[BIN])=2
                        if val(Arrypar[3])> 0
                           ::aStat [ 'Source' ] := val(Arrypar[3])
                           hbprn:setdevmode(DM_DEFAULTSOURCE,val(Arrypar[3]))
                        else
                            ::aStat [ 'Source' ] := ::what_ele(eval(chblk,arrypar,[BIN]),::aCh,"_ABIN")
                            hbprn:setdevmode(DM_DEFAULTSOURCE,::aStat [ 'Source' ] )
                        Endif

                   case ascan(arryPar,[PAPERSIZE])=2   //SET PAPERSIZE
                        ::aStat[ 'PaperSize' ] := ::what_ele(eval(chblk,arrypar,[PAPERSIZE]),::aCh,"_apaper")
                        hbprn:setdevmode(DM_PAPERSIZE,::aStat[ 'PaperSize' ])

                   case ascan(arryPar,[PAPERSIZE])=3   //SET PAPERSIZE
                        ::aStat[ 'PaperLength' ] := val(eval(chblk,arrypar,[HEIGHT]))
                        ::aStat[ 'PaperWidth' ]  := val(eval(chblk,arrypar,[WIDTH] ))
                        // SET USER PAPERSIZE WIDTH <width> HEIGHT <height> => hbprn:setusermode(DMPAPER_USER,<width>,<height>)
                        hbprn:setusermode(256,::aStat[ 'PaperWidth' ],::aStat[ 'PaperLength' ])

                   case ascan(arryPar,[ORIENTATION])=2   //SET ORIENTATION
                        if [LAND] $ eval(chblk,arrypar,[ORIENTATION])
                           oWr:aStat[ 'Orient' ] := 2
                           hbprn:setdevmode(DM_ORIENTATION,DMORIENT_LANDSCAPE) //DMORIENT_LANDSCAPE
                        else
                           oWr:aStat[ 'Orient' ] := 1
                           hbprn:setdevmode(DM_ORIENTATION,DMORIENT_PORTRAIT) //DMORIENT_PORTRAIT
                        Endif

                   case ascan(arryPar,[UNITS])=2
                        do case
                           case arryPar[3]==[ROWCOL] .OR. LEN(ArryPar)==2
                                hbprn:setunits(0)

                           case arryPar[3]==[MM]
                                hbprn:setunits(1)

                           case arryPar[3]==[INCHES]
                                hbprn:setunits(2)

                           case arryPar[3]==[PIXELS]
                                hbprn:setunits(3)

                        endcase
                        oWr:checkUnits(hbprn:units)

                   case ascan(arryPar,[BKMODE])=2
                        if val(Arrypar[3])> 0
                           hbprn:setbkmode(val(Arrypar[3]))
                        else
                            hbprn:setbkmode(::what_ele(eval(chblk,arrypar,[BKMODE]),::aCh,"_aBkmode"))
                        Endif

                   case ascan(ArryPar,[CHARSET])=2
                        hbprn:setcharset(::what_ele(eval(chblk,arrypar,[CHARSET]),::aCh,"_acharset"))

                   case ascan(arryPar,[TEXTCOLOR])=2
                        hbprn:settextcolor( ::UsaColor( eval( chblk,arrypar,[TEXTCOLOR] ) ) )

                   case ascan(arryPar,[BACKCOLOR])=2
                        hbprn:setbkcolor( ::UsaColor( eval( chblk,arrypar,[BACKCOLOR] ) ) )

                   case ascan(arryPar,[ONEATLEAST])= 2
                        ONEATLEAST :=eval(blse,arrypar[3])

                   case ascan(arryPar,[THUMBNAILS])= 2
                        hbprn:thumbnails:=eval(blse,arrypar[3])

                   case ascan(arryPar,[EURO])=2
                        _euro:=eval(blse,arrypar[3])

                   case ascan(arryPar,[CLOSEPREVIEW])=2
                        hbprn:closepreview(eval(blse,arrypar[3]))

                   case ascan(arryPar,[SUBTOTALS])=2
                        m->sbt := (eval(blse,arrypar[3]))

                   case ascan(arryPar,[SHOWGHEAD])=2
                        m->sgh := (eval(blse,arrypar[3]))

                   case ascan(arryPar,[INLINESBT])=2
                       ::aStat['InlineSbt'] := (eval(blse,arrypar[3]))

                   case ascan(arryPar,[GROUPBOLD])=2
                       ::aStat['GroupBold'] := (eval(blse,arrypar[3]))

                   case ascan(arryPar,[HGROUPCOLOR])=2
                       ::aStat['HGroupColor'] := ::UsaColor(eval(chblk,arrypar,[HGROUPCOLOR]))

                   case ascan(arryPar,[GTGROUPCOLOR])=2
                       ::aStat['GTGroupColor'] := ::UsaColor(eval(chblk,arrypar,[GTGROUPCOLOR]))

                   case ascan(arryPar,[INLINETOT])=2
                       ::aStat['InlineTot'] := (eval(blse,arrypar[3]))

                   case ascan(arryPar,[TOTALSTRING])=2
                        m->TTS := eval( chblk,arrypar,[TOTALSTRING] )

                   case ascan(arryPar,[MONEY])=2
                        _money:=eval(blse,arrypar[3])

                   case ascan(arryPar,[SEPARATOR])=2
                        _separator:=eval(blse,arrypar[3])

                   case ascan(arryPar,[JUSTIFICATION])=3
                        hbprn:settextjustification(val(ArryPar[4]))

                   case ascan(arryPar,[MARGINS])=3
                        hbprn:setviewportorg(val(eval(chblk,arrypar,[TOP])),val(eval(chblk,arrypar,[LEFT])))

                   case (ascan(ArryPar,[POLYFILL])=2 .and. Arrypar[3]==[MODE])
                        if val(Arrypar[4])> 0
                            hbprn:setpolyfillmode(val(Arrypar[4]))
                        else
                            hbprn:setpolyfillmode(::what_ele(eval(chblk,arrypar,[MODE]),::aCh,"_apoly"))
                        Endif

                   case ascan(ArryPar,[POLYFILL])=2 .and. len(arrypar)=3
                        hbprn:setpolyfillmode(::what_ele(eval(chblk,arrypar,[POLYFILL]),::aCh,"_aPoly"))

                   case ascan(ArryPar,[VIEWPORTORG])=2
                        hbprn:setviewportorg(val(Arrypar[3]),Val(arrypar[4]))

                   case ascan(ArryPar,[TEXTCHAR])=2
                        hbprn:settextcharextra(Val(eval(chblk,arrypar,[EXTRA])))

                   case ArryPar[2]= [COLORMODE] //=1
                        ::aStat[ 'ColorMode' ] :=;
                        if(val(arrypar[3])>0,val(arrypar[3]),if(arrypar[3]=".T.",2;
                        ,::what_ele(eval(chblk,arrypar,[COLORMODE]),::aCh,"_acolor")))
                        hbprn:setdevmode(DM_COLOR,::aStat[ 'ColorMode'])

                   case ArryPar[2]= [QUALITY]   //=1
                        ::aStat [ 'Res' ] := ::what_ele(eval(chblk,arrypar,[QUALITY]),::aCh,"_aQlt")
                        hbprn:setdevmode(DM_PRINTQUALITY,::aStat [ 'Res' ])

                endcase

           case ascan(arryPar,"GET")=1

                do case
                   case ascan(arryPar,[TEXTCOLOR])> 0
                        if len(ArryPar)> 3
                           &(eval(chblk,arrypar,[TO])):=hbprn:gettextcolor()
                        else
                           &(eval(chblk,arrypar,[TEXTCOLOR])):=hbprn:gettextcolor()
                        Endif

                   case ascan(arryPar,[BACKCOLOR])> 0
                        if len(ArryPar)> 3
                           &(eval(chblk,arrypar,[TO])):=hbprn:getbkcolor()
                        else
                           &(eval(chblk,arrypar,[BACKCOLOR])):=hbprn:getbkcolor()
                        Endif

                   case ascan(arryPar,[BKMODE])> 0
                        if len(ArryPar)> 3
                           &(eval(chblk,arrypar,[TO])):=hbprn:getbkmode()
                        else
                           &(eval(chblk,arrypar,[BKMODE])):=hbprn:getbkmode()
                        Endif

                   case ascan(arryPar,[ALIGN])> 0
                        if len(ArryPar)> 4
                           &(eval(chblk,arrypar,[TO])):=hbprn:gettextalign()
                        else
                           &(eval(chblk,arrypar,[ALIGN])):=hbprn:gettextalign()
                        Endif

                   case ascan(arryPar,[EXTENT])> 0
                        hbprn:gettextextent(eval(chblk,arrypar,[EXTENT]);
                        ,&(eval(chblk,arrypar,[TO])),if(ascan(arryPar,[FONT])>0,eval(chblk,arrypar,[FONT]),NIL))

                   case ArryPar[1]+ArryPar[2]+ArryPar[3]+ArryPar[4]=[GETPOLYFILLMODETO]
                        &(eval(chblk,arrypar,[TO])):=hbprn:getpolyfillmode()

                   case ArryPar[2]+ArryPar[3]=[VIEWPORTORGTO]
                        hbprn:getviewportorg()
                        &(eval(chblk,arrypar,[TO])):=aclone(hbprn:viewportorg)

                   case ascan(ArryPar,[TEXTCHAR])=2
                        &(eval(chblk,arrypar,[TO])):=hbprn:gettextcharextra()

                   case ascan(arryPar,[JUSTIFICATION])=3
                        &(eval(chblk,arrypar,[TO])):=hbprn:gettextjustification()

                endcase

           case ascan(arryPar,[START])=1 .and. len(ArryPar)=2
                if ArryPar[2]=[DOC]
                   hbprn:startdoc()
                elseif ArryPar[2]=[PAGE]
                   hbprn:startpage()
                Endif

           case ascan(arryPar,[END])=1 .and. len(ArryPar)=2
                if ArryPar[2]=[DOC]
                   hbprn:enddoc()
                elseif ArryPar[2]=[PAGE]
                   hbprn:endpage()
                Endif

           case ascan(arryPar,[POLYGON])=1
                hbprn:polygon(&(arrypar[2]),eval(chblk,arrypar,[PEN]);
                ,eval(chblk,arrypar,[BRUSH]),eval(chblk,arrypar,[STYLE]))

           case ascan(arryPar,[DRAW])=5 .and. ascan(arryPar,[TEXT])=6
                /*
                aeval(arrypar,{|x,y|msginfo(x,zaps(y)) } )
                #xcommand @ <row>,<col>,<row2>,<col2> DRAW TEXT <txt> [STYLE <style>] [FONT <cfont>];
                => hbprn:drawtext(<row>,<col>,<row2>,<col2>,<txt>,<style>,<cfont>)
                */
                //msgbox(zaps(::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_STYLE")),"GGGGG")
                al := ::UsaFont(arrypar)

                hbprn:drawtext(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]);
                ,eval(epar,ArryPar[3]),eval(epar,Arrypar[4]),eval(chblk,arrypar,[TEXT]);
                ,::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_STYLE"), "Fx" )

                hbprn:settextalign( al[1] )
                hbprn:settexcolor ( al[2] )

           case ascan(arryPar,[RECTANGLE])=5
                //MSG([PEN=]+eval(chblk,arrypar,[PEN])+CRLF+[BRUSH=]+eval(chblk,arrypar,[BRUSH]),[RETTANGOLO])
                hbprn:rectangle(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]);
                ,eval(chblk,arrypar,[PEN]),eval(chblk,arrypar,[BRUSH]))

           case ascan(ArryPar,[FRAMERECT])=5 .OR. ascan(ArryPar,[FOCUSRECT])=5
                hbprn:framerect(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]);
                ,eval(chblk,arrypar,[BRUSH]))

           case ascan(ArryPar,[FILLRECT])=5
                hbprn:fillrect(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]);
                ,eval(chblk,arrypar,[BRUSH]))

           case ascan(ArryPar,[INVERTRECT])=5
                hbprn:invertrect(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]))

           case ascan(ArryPar,[ELLIPSE])=5
                hbprn:ellipse(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]);
                ,eval(chblk,arrypar,[PEN]), eval(chblk,arrypar,[BRUSH]))

           case ascan(arryPar,[RADIAL1])>0
                do case
                   case arrypar[5]=[ARC]
                        hbprn:arc(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]);
                        ,eval(epar,Arrypar[4]),eval(epar,Arrypar[7]),eval(epar,Arrypar[8]);
                        ,eval(epar,Arrypar[10]),eval(epar,Arrypar[11]),eval(chblk,arrypar,[PEN]))

                   case arrypar[3]=[ARCTO]
                        hbprn:arcto(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[5]);
                        ,eval(epar,Arrypar[6]),eval(epar,Arrypar[8]),eval(epar,Arrypar[9]);
                        ,eval(chblk,arrypar,[PEN]))

                   case arrypar[5]=[CHORD]
                        hbprn:chord(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]);
                        ,eval(epar,Arrypar[4]),eval(epar,Arrypar[7]),eval(epar,Arrypar[8]);
                        ,eval(epar,Arrypar[10]),eval(epar,Arrypar[11]),eval(chblk,arrypar,[PEN]);
                        ,eval(chblk,arrypar,[BRUSH]))

                   case arrypar[5]=[PIE]
                        hbprn:pie(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]);
                        ,eval(epar,Arrypar[4]),eval(epar,Arrypar[7]),eval(epar,Arrypar[8]);
                        ,eval(epar,Arrypar[10]),eval(epar,Arrypar[11]),eval(chblk,arrypar,[PEN]);
                        ,eval(chblk,arrypar,[BRUSH]))

                endcase

           case ASCAN(ArryPar,[LINETO])=3
                hbprn:lineto(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),if(ASCAN(ArryPar,[PEN])= 4,ArryPar[5],NIL))

           case ascan(ArryPar,[LINE])=5
                hbprn:line(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]),if(ASCAN(ArryPar,[PEN])= 6,ArryPar[7],NIL))

           case ascan(ArryPar,[PICTURE])=3
                /*
                            1     2       3      4     5     6     7       8      9      10
                #xcommand @<row>,<col> PICTURE <cpic> SIZE <row2>,<col2> [EXTEND <row3>,<col3>] ;
                            => hbprn:picture(<row>,<col>,<row2>,<col2>,<cpic>,<row3>,<col3>)
                                                 1     2     6      7      4      9      10
                */
                if "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
                   ArryPar[4]:= ::MACROCOMPILE(ArryPar[4],.t.,cmdline,section)
                Endif
                do case
                   case len(ArryPar)= 4
                        hbprn:picture(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),,,::Gestimage(ArryPar[4]))

                   case len(ArryPar)= 7
                        hbprn:picture(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[6]),eval(epar,Arrypar[7]),::Gestimage(ArryPar[4]))

                   case len(ArryPar)=10
                        if ascan(ArryPar,[EXTEND])=8
                           hbprn:picture(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[6]),eval(epar,Arrypar[7]),::Gestimage(ArryPar[4]),eval(epar,ArryPar[9]),eval(epar,ArryPar[10]))
                        Endif

                endcase

           case ascan(ArryPar,[IMAGE])= 4
                hbprn:picture(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),VAl(eval(chblk,arrypar,[HEIGHT])),val(eval(chblk,arrypar,[WIDTH])),::Gestimage(ArryPar[5]))

           case ascan(ArryPar,[ROUNDRECT])=5   //da rivedere
                /*
                @ <row>,<col>,<row2>,<col2> ROUNDRECT  [ROUNDR <tor>] [ROUNDC <toc>] [PEN <cpen>] [BRUSH <cbrush>];
                            => hbprn:roundrect(<row>,<col>,<row2>,<col2>,<tor>,<toc>,<cpen>,<cbrush>)
                RoundRect(row,col,torow,tocol,widthellipse,heightellipse,defpen,defbrush)
                */
               set exact on
               hbprn:roundrect( eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
               ,val(eval(chblk,arrypar,[ROUNDR])),val(eval(chblk,arrypar,[ROUNDC])),eval(chblk,arrypar,[PEN]),eval(chblk,arrypar,[BRUSH]))
               set exact off

           case ascan(ArryPar,[TEXTOUT])=3

                al := ::UsaFont(arrypar)

                if ascan(ArryPar,[FONT])=5
                   if "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
                      __elex:=ArryPar[4]
                      hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),&(__elex),"FX")
                   else
                      hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),ArryPar[4],"Fx")
                   Endif
                elseif LEN(ArryPar)=4
                   if "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
                      __elex:=ArryPar[4]
                      hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),&(__elex))
                   else
                      hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),ArryPar[4])
                   Endif
                Endif

                hbprn:settextalign( al[1] )
                hbprn:settexcolor ( al[2] )

           case ascan(ArryPar,[PRINT])=3 .OR. ascan(ArryPar,[SAY])= 3

                al := ::UsaFont(arrypar,cmdline,section)
/*
                if eval(chblk,arrypar,[FONT])="TIMES"
                   msgmulty({eval(epar,arrypar[1]),eval(epar,arrypar[2]),hbprn:convert({eval(epar,arrypar[1]),eval(epar,arrypar[2])})[1],hbprn:convert({eval(epar,arrypar[1]),eval(epar,arrypar[2])})[2];
                   ,"---",hbprn:devcaps[5],hbprn:devcaps[6],hbprn:devcaps[9],hbprn:devcaps[10]})
                Endif
*/
                hbprn:say(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]);
                         ,if("->" $ ArryPar[4] .or. [(] $ ArryPar[4],::MACROCOMPILE(ArryPar[4],.t.,cmdline,section),ArryPar[4]);
                         ,if(ascan(hbprn:Fonts[2],eval(chblk,arrypar,[FONT]) )> 0,eval(chblk,arrypar,[FONT]),"FX")  ;
                         ,if(ascan(arryPar,[COLOR])>0,::UsaColor(eval(chblk,arrypar,[COLOR])),NIL);
                         ,nil )
                         //,if(ascan(arryPar,[ALIGN])>0,::what_ele(eval(chblk,arrypar,[ALIGN]),::aCh,"_aAlign"),NIL))

                hbprn:settextalign( al[1] )
                hbprn:settexcolor ( al[2] )

           case ascan(ArryPar,[MEMOSAY])=3

                al := ::UsaFont(arrypar)

                ::MemoSay(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                   ,eval(epar,ArryPar[2]) ;
                   ,::MACROCOMPILE(ArryPar[4],.t.,cmdline,section) ;
                   ,if(ascan(arryPar,[LEN])>0,if(valtype(oWr:argm[3])=="A",;
                                              ::MACROCOMPILE(eval(chblk,arrypar,[LEN]),.t.,cmdline,section) , ;
                                              val(eval(chblk,arrypar,[LEN]))),NIL) ;
                   ,if(ascan(arryPar,[FONT])>0,"FX",NIL);
                   ,if(ascan(arryPar,[COLOR])>0,::UsaColor(eval(chblk,arrypar,[COLOR])),NIL);
                   ,NIL ;
                   ;//,if(ascan(arryPar,[ALIGN])>0,::what_ele(eval(chblk,arrypar,[ALIGN]),::aCh,"_aAlign"),NIL);
                   ,if(ascan(arryPar,[.F.])>0,".F.","");
                   ,arrypar)

                hbprn:settextalign( al[1] )
                hbprn:settexcolor ( al[2] )

          case ascan(ArryPar,[PUTARRAY])=3

                al := ::UsaFont(arrypar)

                ::Putarray(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                   ,eval(epar,ArryPar[2]) ;
                   ,::MACROCOMPILE(ArryPar[4],.t.,cmdline,section)    ;            //arr
                   ,if(ascan(arryPar,[LEN])>0,::macrocompile(eval(chblk,arrypar,[LEN])),NIL) ; //awidths
                   ,nil                                                           ;      //rowheight
                   ,nil                                                           ;      //vertalign
                   ,(ascan(arryPar,[NOFRAME])>0)                                  ;      //noframes
                   ,nil                                                           ;      //abrushes
                   ,nil                                                           ;      //apens
                   ,if(ascan(arryPar,[FONT])>0,NIL,NIL)                           ;      //afonts
                   ,if(ascan(arryPar,[COLOR])> 0,::UsaColor(eval(chblk,arrypar,[COLOR])),NIL);//afontscolor
                   ,NIL                                                           ;      //abitmaps
                   ,nil )                                                                //userfun

                hbprn:settextalign( al[1] )
                hbprn:settexcolor ( al[2] )

          case ascan(ArryPar,[BARCODE])=3
                     oWr:DrawBarcode(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]);
                         , VAL(eval(chblk,arrypar,[HEIGHT]));
                         , VAL(eval(chblk,arrypar,[WIDTH])) ;
                         , eval(chblk,arrypar,[TYPE])  ;
                         , if("->" $ ArryPar[4] .or. [(] $ ArryPar[4],::MACROCOMPILE(ArryPar[4],.t.,cmdline,section),ArryPar[4]);
                         , oWr:UseFlags(eval(chblk,arrypar,[FLAG]));
                         ,(ascan(arryPar,[SUBTITLE])>0);
                         ,(ascan(arryPar,[INTERNAL])< 1) ;
                         , cmdline ;
                         ,VAL(eval(chblk,arrypar,[VSH])) )

          case ascan(ArryPar,[NEWPAGE])=1 .or. ascan(ArryPar,[EJECT])=1
                hbprn:endpage()
                hbprn:startpage()

        endcase
     endcase
return .t.
/*
*/
*-----------------------------------------------------------------------------*
METHOD WHAT_ELE(Arg1,Arg2,Arg3) CLASS WREPORT
*-----------------------------------------------------------------------------*
     Local rtv ,sets:='',kl := 0 , ltemp := '' ,;
     Asr := {{"_APAPER","DMPAPER_A4"} ,{"_ABIN","DMBIN_AUTO"},{"_APEN","PS_SOLID"},;
             {"_ABRUSH","BS_SOLID"},{"_APOLY","ALTERNATE"},{"_ABKMODE","TRANSPARENT"},;
             {"_AALIGN","TA_LEFT"} ,{"_AREGION","RGN_AND"} ,{"_ACOLOR","MONO"}, ;
             {"_AQLT","DMRES_DRAFT"}, {"_STYLE","DT_TOP"}}
     default arg3 to "_APAPER"
     Arg3:=upper(Arg3)
     aeval(aSr,{|x| if(x[1]== Arg3,ltemp:=x[2],'')})
     if ! empty(ltemp)
        default arg1 to ltemp
        if arg3="_ACOLOR" .and. arg1 = ".F."
           arg1 := "MONO"
        Endif
     Endif

     rtv := ASCAN(arg2, {|aVal| aVal[1] == arg1})

     if rtv > 0
        sets := arg2[rtv,1]
        rtv  := arg2[rtv,2]
     else
        if arg3 = "TEST" //_AQLT"
           for kl:=01 to len(arg2)
               msg(arg1+CRLF+arg2[kl,1]+CRLF+zaps(arg2[kl,2]),arg3)
           next
        Endif
     Endif
     /*
     if arg3 = ""  //_ABKMODE"      //If you want test it ...
        msg({sets+" = "+zaps(rtv),CRLF,ARG1},arg3)
     Endif
     */
return rtv
/*
*/
*-----------------------------------------------------------------------------*
METHOD MEMOSAY(row,col,argm1,argl1,argf1,argcolor1,argalign,onlyone,arrypar) CLASS WREPORT
*-----------------------------------------------------------------------------*
 Local _Memo1:=argm1, mrow:=max(1,mlcount(_memo1,argl1)), arrymemo:={}, esci:=.F.
 Local units := hbprn:UNITS, k, mcl ,ain, str :='', typa := .F.
 default col to 0 ,row to 0, argl1 to 10, onlyone to ''

 if valtype(argm1)=="A"
    typa := .t.
    arrymemo := {}
    if ::IsMono(argm1)
       arrymemo := aclone(argm1)
    Else
       for each ain IN argm1
           aeval( ain,{|x,y| str += substr(hb_valtostr(x),1,argl1[y])+" " } )
           str := rtrim(str)
           aadd(arrymemo,str)
           STR := ""
       next ain
    Endif
 Else
   for k := 1 to mrow
       aadd(arrymemo,oWr:justificalinea(memoline(_memo1,argl1,k),argl1))
   next
 Endif
 if empty(onlyone)
    hbprn:say(if(UNITS > 0.and.units < 4,nline*lstep,nline),col,arrymemo[1],argf1,argcolor1,argalign)
    ::aStat [ 'Yes_Memo' ]:= .t.
 else
    for mcl := 2 to len(arrymemo)
        nline ++
        if nline >= ::HB - 1
           ::TheFeet()
           ::TheHead()
           ::UsaFont(arrypar)
        Endif
        hbprn:say(if(UNITS > 0.and.units < 4,nline*lstep,nline),col,arrymemo[mcl],argf1,argcolor1,argalign)
    next
    if !typa
       dbskip()
    Endif
 Endif
 return self
/*
*/
*-----------------------------------------------------------------------------*
METHOD PUTARRAY(row,col,arr,awidths,rowheight,vertalign,noframes,abrushes,apens,afonts,afontscolor,abitmaps,userfun) CLASS Wreport
*-----------------------------------------------------------------------------*
Local j,ltc,lxc,lvh,lnf:=!noframes,lafoc,lafo,labr,lape,xlwh1,labmp,lcol,lwh,old_pfbu
Local IsMono,nw,align

private xlwh,xfo,xfc,xbr,xpe,xwa,xbmp
default afonts to ::Astat['Fname'],afontscolor to ::Astat['Fcolor']
if empty(arr)
   return nil
Endif
::aStat [ 'Yes_Array' ]:= .t.
Do case
   case oWr:PrnDrv = "HBPR"
        old_pfbu:={hbprn:PENS[hbprn:CURRPEN,2],hbprn:FONTS[hbprn:CURRFONT,2] ;
                  ,hbprn:BRUSHES[hbprn:CURRBRUSH,2],hbprn:UNITS,hbprn:GetTextAlign()}

        afontscolor:=if(afontscolor==NIL,0,afontscolor)
        lafoc:=if(valtype(afontscolor)=="N",afill(array(len(arr[1])),afontscolor),afontscolor)

   otherwise
        lafoc:=if(::IsMono(afontscolor),afill(array(len(arr[1])),afontscolor),afontscolor)
Endcase

afonts:=if(afonts==NIL,"",afonts)
lafo:=if(valtype(afonts)=="C",afill(array(len(arr[1])),afonts),afonts)

abitmaps:=if(abitmaps==NIL,"",abitmaps)
labmp:=if(valtype(abitmaps)=="C",afill(array(len(arr[1])),abitmaps),abitmaps)

abrushes:=if(abrushes==NIL,"",abrushes)
labr:=if(valtype(abrushes)=="C",afill(array(len(arr[1])),abrushes),abrushes)

apens:=if(apens==NIL,"BLACK",apens)
lape:=if(valtype(apens)=="C",afill(array(len(arr[1])),apens),apens)
ltc:=if(awidths==NIL,afill(array(len(arr[1])),10),awidths)

lwh:=if(empty(rowheight),1,rowheight)
lvh:=if(vertalign==NIL,0,vertalign)
IsMono := ::Ismono(arr)

  do case
     case lvh==TA_CENTER ; lvh:=rowheight/2-0.5
     case lvh==TA_BOTTOM ; lvh:=rowheight-1
     otherwise           ; lvh:=0  // TA_TOP
  endcase
//  msgbox(lvh,"lvh2805")
  lxc   := col
  xlwh1 := 0
  nw := if (IsMono,1 ,len(arr[1]))

  for j:=1 to Nw
      xlwh := lwh
      xfo  := lafo[j]
      xfc  := lafoc[j]

      if oWr:PrnDrv = "HBPR"
         xbr := labr[j]
         xpe := lape[j]
      Endif

      if IsMono
         xwa := arr[::acnt]
      Else
         xwa := arr[::acnt,j]
      Endif

      xbmp := labmp[j]

      if valtype(userfun)=="C"
         &userfun(::acnt,j,(nline*lstep),@xwa,@xlwh,@xfo,@xfc,@xbr,@xpe,@xbmp)
      Endif
      if xlwh > xlwh1
         xlwh1 := xlwh
      Endif
      Do Case
         Case ::PrnDrv = "HBPR"
              if lnf
                @row,lxc,(nline*lstep)+xlwh+5,lxc+ltc[j] rectangle brush xbr pen xpe
              Endif
              if !empty(xbmp)
                @row,lxc picture xbmp size xlwh,ltc[j]
              Endif
              if valtype(xwa)=="N"
                 lcol := lxc+ltc[j]-0.5
                 set text align TA_RIGHT
              else
                 lcol :=lxc+1
                 set text align TA_LEFT
              Endif
              @row,lcol say xwa Font "FX" color xfc to print

         Case ::PrnDrv = "MINI"
              if lnf
                _HMG_PRINTER_H_RECTANGLE ( _hmg_printer_hdc , Row , lxc , (nline*lstep)+xlwh+5 , lxc+ltc[j] , 0.2 , 0 , 0 , 0 ,.T.) // <.lcolor.> , <.lfilled.> , <.lnoborder.> )
              Endif

              if valtype(xwa)=="N"
                 lcol  := lxc+ltc[j]-0.5
                 Align := "RIGHT"
              else
                 lcol  :=lxc+1
                 Align := "LEFT"
              Endif

              _HMG_PRINTER_H_PRINT ( _hmg_printer_hdc ,row ,lcol ;
             , xfo , ::Astat['Fsize'] ,xfc[1] ,xfc[2] ,xfc[3] , xwa , ::Astat['FBold'] , ::Astat['Fita'] ,::Astat['Funder'] ,::Astat['Fstrike'] , .T. , .T. , .T. , align)

         Case ::PrnDrv = "PDF"
              if lnf
                 _HMG_HPDF_RECTANGLE ( Row+.2 , lxc ,(nline*lstep)+xlwh-5 ,lxc+ltc[j] ,.2 , 0 , 0 , 0 ,.T.)
              Endif

              if valtype(xwa)=="N"
                 lcol  := lxc+ltc[j]-0.5
                 Align := "RIGHT"
                 xwa   := Any2Strg( xwa )
              else
                 xwa   := Any2Strg( xwa )
                 lcol  := lxc+1
                 Align := "LEFT"
              Endif
              _HMG_HPDF_PRINT ( row ,lcol , xfo , ::Astat['Fsize'] ,xfc[1] ,xfc[2] ,xfc[3] , xwa , ::Astat['FBold'] , ::Astat['Fita'] ,::Astat['Funder'] ,::Astat['Fstrike'] , .T. , .T. , .T. , align)

      EndCase
      lxc += ltc[j]
  next
  if oWr:PrnDrv = "HBPR"
     hbprn:selectpen(old_pfbu[1])
     hbprn:selectfont(old_pfbu[2])
     hbprn:selectbrush(old_pfbu[3])
     hbprn:setunits(old_pfbu[4])
  // hbprn:SetTextAlign(old_pfbu[5])
  endif
return nil
/*
*/
*-----------------------------------------------------------------------------*
Method MixMsay(arg1,arg2,argm1,argl1,argf1,argsize,abold,aita,aunder,astrike,argcolor1,argalign,onlyone) Class Wreport
*-----------------------------------------------------------------------------*
 local _Memo1:=argm1, k, mcl ,maxrow:=max(1,mlcount(_memo1,argl1))
 local arrymemo:={} , esci:=.F. ,str :="" , ain, typa := .F., _arg5
 default arg2 to 0 , arg1 to 0 , argl1 to 10, onlyone to "", argalign to "LEFT"

 if valtype(argm1)=="A"
    typa := .t.
    arrymemo := {}
    if oWr:IsMono(argm1)
       arrymemo := aclone(argm1)
    Else
       for each ain IN argm1
           aeval( ain,{|x,y| str += substr(hb_valtostr(x),1,argl1[y])+" " } )
           str := rtrim(str)
           aadd(arrymemo,str)
           STR := ""
       next ain
    Endif
 Else
    for k:=1 to maxrow
        aadd(arrymemo,oWr:justificalinea(memoline(_memo1,argl1,k),argl1))
    next
 Endif
 _arg5:= argSize*25.4/100
 if empty(onlyone)
    _HMG_PRINTER_H_PRINT ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
   , arg1-oWr:aStat[ 'Hbcompatible' ]-_arg5 ;
   , arg2  ;
   , argf1 ;
   , argsize ;
   , argcolor1[1] ;
   , argcolor1[2] ;
   , argcolor1[3] ;
   , arrymemo[1] ;
   , abold;
   , aita;
   , aunder;
   , astrike;
   , if(valtype(argcolor1)=="A", .t.,.F.) ;
   , if(valtype(argf1)=="C", .t.,.F.) ;
   , if(valtype(argsize)=="N", .t.,.F.) ;
   , argalign )
   oWr:aStat [ 'Yes_Memo' ] :=.t.
 else
     for mcl=2 to len(arrymemo)
         nline ++
         if nline >= oWr:HB-1
            oWr:TheFeet()
            oWr:TheHead()
         Endif
         _HMG_PRINTER_H_PRINT ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
         , (nline*lstep)-oWr:aStat[ 'Hbcompatible' ]-_arg5 , arg2, argf1 , argsize , argcolor1[1], argcolor1[2], argcolor1[3] ;
         , arrymemo[mcl], abold, aita, aunder, astrike;
         , if(valtype(argcolor1)=="A", .t.,.F.) ;
         , if(valtype(argf1)=="C", .t.,.F.) ;
         , if(valtype(argsize)=="N", .t.,.F.) ;
         , argalign )
     next
     if !Typa
        dbskip()
     Endif
 Endif
 return nil

/*
*/
*-----------------------------------------------------------------------------*
METHOD HATCH(arg1) CLASS WREPORT
*-----------------------------------------------------------------------------*
   Local ritorno := 0 ,;
   Asr := {"HS_HORIZONTAL","HS_VERTICAL","HS_FDIAGONAL","HS_BDIAGONAL","HS_CROSS","HS_DIAGCROSS"}
   ritorno := max(0, ascan(Asr,arg1)-1 )
return ritorno
/*
*/
*-----------------------------------------------------------------------------*
METHOD GROUP(GField, s_head, s_col, gftotal, wheregt, s_total, t_col, p_f_e_g) CLASS WREPORT
*                1        2      3       4        5        6       7       8
*-----------------------------------------------------------------------------*
Local ritorno := if( indexord()> 0 ,.t.,.F. )
Local posiz   := 0, P1 := 0, P2 := 0, P3 := 0, cnt := 1
Local Aposiz  := {}, k, Rl, Rm, Rr, ghf:=''
Local db_arc:=dbf() , units , tgftotal , nk, EXV := {||NIL},EXT := {||NIL}

      If ::PrnDrv = "HBPR"
         Units := hbprn:UNITS
      else
         Units := 3
      Endif

      default S_TOTAL TO '', s_head to '', gftotal to ''
      default wheregt to [AUTO], s_col to [AUTO], t_col to 0
      default P_F_E_G to .F.

      Asize(counter,0)

      if valtype( s_col)== "N"; s_col:=zaps(s_col); Endif

      if valtype(P_F_E_G) == "C"
         ::aStat [ 'P_F_E_G' ]  :=  (".T." $ upper(P_F_E_G))
      elseif valtype(P_F_E_G) == "L"
         ::aStat [ 'P_F_E_G' ]  := P_F_E_G
      Endif

      if !empty(gfield)
         ::aStat [ 'Ghead' ]   :=.t.
         ::aStat[ 'TempFeet' ] := trans((db_arc)->&(GField),"@!")
      Endif
      if empty(GField)
         msgExclamation('Missing Field Name id Group declaration!')
         ritorno   := .F.
      else
         m->GField := GField
      Endif

      if !empty(s_head)
         ::aStat [ 'GHline' ]    := .t.
         m->s_head := s_head
         m->s_col  := val( s_col )
      else
         m->s_head :=""
      Endif

      if !empty(s_total)
         GFline     := .t.
         IF "{||" = LEFT(S_total,3)
            EXT := alltrim(substr(S_Total,at("||",S_Total)+2,at("}",S_Total)-4))
            m->s_total := ::macrocompile( EXT )
         Else
            m->s_total := s_total
         Endif
         m->t_col   := Val( t_col )
      Endif

      if valtype(gftotal)== "C"    // sistemazione per conti su colonne multiple
         && make an array for gftotal
         gftotal := AscArr(upper( gftotal ) )
      Endif
      && make an array for counters
      Aeval(gftotal,{|| aadd( counter,0),aadd(Gcounter,0)})

      if !empty(gftotal) .or. !empty(s_total)
         GFline    :=.t.
         m->gfexec :=.t.
         IF "{||" = LEFT(S_total,3)
            EXT := alltrim(substr(S_Total,at("||",S_Total)+2,at("}",S_Total)-4))
            // m->s_total := macrocompile("("+Any2Strg(eval({||EXT }))+ ")")
            m->s_total := ::macrocompile(EXT )
         Else
            m->s_total := s_total
         Endif

         m->t_col  := Val( t_col )
      Endif

      && make autoset for stringHead position
      Aeval(::aBody,{|x,y|if(upper(m->gfield) $ upper(x[1]),Posiz :=y,'')})

      if posiz > 0  //IS A BODY DECLARED FIELD
         P1 := max (at("SAY",upper ( ::aBody[posiz,1] ))+3,at("PRINT", upper( ::aBody[posiz,1] ) )+5)
         P2 := at("FONT",upper( ::aBody[posiz,1] ) )-2
         IF "{||" = LEFT(S_HEAD,3)
            EXV := alltrim(substr(S_HEAD,at("||",S_HEAD)+2,at("}",S_HEAD)-4))
         Endif
         GHstring:=substr(::aBody[posiz,1],1,P1)+;
         IF("{||" = LEFT(S_HEAD,3), Any2Strg(eval({||exv })) ;
          ,"(["+ s_head+"]+"+::Hgconvert(substr(::aBody[posiz,1],P1+1,P2-p1))+")" ) ;
         +substr(::aBody[posiz,1],p2+1)
         if upper(s_col) # [AUTO]
            GHstring:=left(::aBody[posiz,1],at(chr(07),::aBody[posiz,1]))+s_col+chr(07)+substr(Ghstring,at("SAY",Ghstring))
         Endif
      else   // NOT DECLARED INTO BODY
         ghf := ::Hgconvert(gfield)
         Ghstring :=if (UNITS > 0 .and. units < 4 ,"(NLINE*LSTEP)","NLINE")+CHR(07)+zaps(M->S_COL)+CHR(07)
         Ghstring +="SAY"+CHR(07)+"(["+s_head+']+'+ghf+')'+CHR(07)+"FONT"+CHR(07)+"FNT01"
      Endif
      IF LEFT(GHstring,1) == chr(07)
         GHstring := Substr(GHstring,2)
      Endif
      if ::aStat['GroupBold']= .T.
         GhString += CHR(07)+"BOLD"
      Endif
      // MSGBOX(ghSTRING,"2988")

      // Gestisce l'automatismo del posizionamento dei subtotali
      && make autoset for Counter(s) position
      tgftotal   := aclone(gftotal)
      m->gftotal := aclone(gftotal)

      for each k in ::aBody
          P1 := at( "SAY", upper( k[1] ) ); P2 := at( "PRINT", upper ( k[1] ) )
          P3 := at( "TEXTOUT", upper( k[1] ) )
          if max(p3,max(p1,p2)) = p3
             P1 := P3 + 8
          elseif p2 > p1
             P1 := max(p2,p1) + 6
          elseif p2 < p1
             P1 := max(p2,p1) + 4
          Endif
          Rl := substr(k[1],1,p1-1)
          Rm := substr(substr(k[1],p1),1,at(chr(07),substr(k[1],p1))-1)
          Rr := substr(substr(k[1],p1),at(chr(07),substr(k[1],p1)))
          for nk = 1 to len(tgftotal)
              if tgftotal[nk] $ upper(Rm)
                 rm := upper(rm)
                 if upper(tgftotal[nk]) $ Rm    &&  Ë maiuscolo
                    // msginfo(rm+CRLF+tgftotal[nk],"1")
                    rm:= strtran(rm,tgftotal[nk],"m->counter["+zaps(cnt)+"]")
                 Endif
/*
                 else
                    msginfo(rm+CRLF+tgftotal[nk],"2")
                    rm:= strtran(rm,lower(tgftotal[nk]),"m->counter["+zaps(cnt)+"]")
                 Endif
               // msgbox(Rl+CRLF+Rm+CRLF+Rr,zaps(nk)+"-GFFFSTRING")
*/
                 aadd(GFstring,Rl+Rm+Rr+if(::aStat['GroupBold']= .T.,CHR(07)+"BOLD","") )
                 tgftotal[nk]:=''
                 cnt ++
              Endif
          next
      next
      //Aeval(gfstring,{|x| msgstop( zaps( len( gfstring ) ) +crlf+x,"Gfstring" ) })
      if valtype( wheregt)== "N"
         wheregt:=zaps(wheregt)
      Endif

      // Grand Total
      Aeval(GFstring,{|x| aadd(GTstring,strtran(x,"counter[","gcounter["))})
      if val(wheregt) > 0
         if len(wheregt) < 2
            for k=1 to len(GFstring)
                GTstring[k]:=left(GTstring[k],at(chr(07),GTstring[k]))+wheregt+chr(07)+substr(Gtstring[k],at("SAY",Gtstring[k]))
            next
         else
            GTstring[1]:=left(GTstring[1],at(chr(07),GTstring[1]))+wheregt+chr(07)+substr(Gtstring[1],at("SAY",Gtstring[1]))
         Endif
      Endif
      if ::aStat['GroupBold']= .T.
          Aeval(GTstring,{|x,y|x:=nil, GTstring[y] += CHR(07)+"BOLD" })
          // msgmulty(GTstring)
      Endif

return ritorno
/*
*/
*-----------------------------------------------------------------------------*
METHOD GrHead() CLASS WREPORT
*-----------------------------------------------------------------------------*
Local db_arc:=dbf()
Local ValSee:= if(!empty(gfield),trans((db_arc)->&(GField),"@!"),"")

      if ValSee == ::aStat[ 'TempHead' ]
         ::aStat [ 'Ghead' ]    := .F.
      else
         ::aStat [ 'Ghead' ]    := .T.
         ::aStat [ 'TempHead' ] := ValSee
      Endif

return ::aStat [ 'Ghead' ]
/*
*/
*-----------------------------------------------------------------------------*
METHOD GFeet() CLASS WREPORT
*-----------------------------------------------------------------------------*
Local db_arc:=dbf(), Gfeet
Local ValSee:=if(!empty(gfield),trans((db_arc)->&(GField),"@!"),"")
      if ValSee == ::aStat[ 'TempFeet' ]
         Gfeet := .F.
      else
         Gfeet := .T.
         ::aStat[ 'TempFeet' ]:= ValSee
      Endif
return Gfeet
/*
*/
*-----------------------------------------------------------------------------*
METHOD UsaFont(arrypar, cmdline , section) CLASS WREPORT
*-----------------------------------------------------------------------------*
   Local al := { hbprn:gettextalign(), hbprn:gettexcolor() }
   empty(cmdline);empty(section)

   hbprn:modifyfont("Fx",;
         if("->" $ eval(chblk,arrypar,[FONT]) .or. [(] $ eval(chblk,arrypar,[FONT]),::MACROCOMPILE(eval(chblk,arrypar,[FONT]),.t.,cmdline,section),eval(chblk,arrypar,[FONT])) ,;
         if("->" $ eval(chblk,arrypar,[SIZE]) .or. [(] $ eval(chblk,arrypar,[SIZE]),::MACROCOMPILE(eval(chblk,arrypar,[SIZE]),.t.,cmdline,section),val(eval(chblk,arrypar,[SIZE]))) ,;
         val(eval(chblk,arrypar,[WIDTH]) ) ,;
         val(eval(chblk,arrypar,[ANGLE]) ) ,;
         (ascan(arryPar,[BOLD])>0),!(ascan(arryPar,[BOLD])>0) , ;
         (ascan(arryPar,[ITALIC])>0),!(ascan(arryPar,[ITALIC])>0) ,;
         (ascan(arryPar,[UNDERLINE])>0) ,!(ascan(arryPar,[UNDERLINE])>0) ,;
         (ascan(arryPar,[STRIKEOUT])>0),!(ascan(arryPar,[STRIKEOUT])>0) )

   if ascan(arryPar,[COLOR]) > 0
      hbprn:settextcolor(::UsaColor(eval(chblk,arrypar,[COLOR])))
   Endif
   hbprn:settextalign(::what_ele(::CheckAlign( arrypar, cmdline , section),::aCh,"_AALIGN") )
/*
   if eval(chblk,arrypar,[FONT])= "TIMES"
      asize:={0,0}
      LQ := (hbprn:gettextextent_mm(ArryPar[4],asize,"Fx")[1])
     // lq := _HMG_HPDF_Pixel2MM(GETTEXTHEIGHT( _hmg_printer_hdc, arrypar[4],FH ))
      msgmulty({arrypar[4],eval(chblk,ArryPar[4]),lq,eval(epar,ArryPar[1]),eval(epar,ArryPar[1])-lq} )
      msgmulty(arrypar)
   Endif
*/

return al
/*
*/
*-----------------------------------------------------------------------------*
METHOD UsaColor(arg1) CLASS WREPORT
*-----------------------------------------------------------------------------*
   Local ritorno:=arg1
   if "X" $ upper(arg1)
      arg1 := substr( arg1,at("X",arg1)+1)
      IF ::PrnDrv = "HBPR"
         ritorno := Rgb(HEXATODEC(substr(arg1,-2));
                ,HEXATODEC(substr(arg1,5,2)),HEXATODEC(substr(arg1,3,2)) )
      Else
         ritorno := {HEXATODEC(substr(arg1,-2));
                ,HEXATODEC(substr(arg1,5,2) ),HEXATODEC(substr(arg1,3,2)) }
      Endif
   else
      ritorno := color(arg1)
   Endif
return ritorno
/*
*/
*-----------------------------------------------------------------------------*
METHOD DXCOLORS(par) CLASS WREPORT
*-----------------------------------------------------------------------------*
Local rgbColorNames:=;
   {{ "aliceblue",             0xfffff8f0 },;
    { "antiquewhite",          0xffd7ebfa },;
    { "aqua",                  0xffffff00 },;
    { "aquamarine",            0xffd4ff7f },;
    { "azure",                 0xfffffff0 },;
    { "beige",                 0xffdcf5f5 },;
    { "bisque",                0xffc4e4ff },;
    { "black",                 0xff000000 },;
    { "blanchedalmond",        0xffcdebff },;
    { "blue",                  0xffff0000 },;
    { "blueviolet",            0xffe22b8a },;
    { "brown",                 0xff2a2aa5 },;
    { "burlywood",             0xff87b8de },;
    { "cadetblue",             0xffa09e5f },;
    { "chartreuse",            0xff00ff7f },;
    { "chocolate",             0xff1e69d2 },;
    { "coral",                 0xff507fff },;
    { "cornflowerblue",        0xffed9564 },;
    { "cornsilk",              0xffdcf8ff },;
    { "crimson",               0xff3c14dc },;
    { "cyan",                  0xffffff00 },;
    { "darkblue",              0xff8b0000 },;
    { "darkcyan",              0xff8b8b00 },;
    { "darkgoldenrod",         0xff0b86b8 },;
    { "darkgray",              0xffa9a9a9 },;
    { "darkgreen",             0xff006400 },;
    { "darkkhaki",             0xff6bb7bd },;
    { "darkmagenta",           0xff8b008b },;
    { "darkolivegreen",        0xff2f6b55 },;
    { "darkorange",            0xff008cff },;
    { "darkorchid",            0xffcc3299 },;
    { "darkred",               0xff00008b },;
    { "darksalmon",            0xff7a96e9 },;
    { "darkseagreen",          0xff8fbc8f },;
    { "darkslateblue",         0xff8b3d48 },;
    { "darkslategray",         0xff4f4f2f },;
    { "darkturquoise",         0xffd1ce00 },;
    { "darkviolet",            0xffd30094 },;
    { "deeppink",              0xff9314ff },;
    { "deepskyblue",           0xffffbf00 },;
    { "dimgray",               0xff696969 },;
    { "dodgerblue",            0xffff901e },;
    { "firebrick",             0xff2222b2 },;
    { "floralwhite",           0xfff0faff },;
    { "forestgreen",           0xff228b22 },;
    { "fuchsia",               0xffff00ff },;
    { "gainsboro",             0xffdcdcdc },;
    { "ghostwhite",            0xfffff8f8 },;
    { "gold",                  0xff00d7ff },;
    { "goldenrod",             0xff20a5da },;
    { "gray",                  0xff808080 },;
    { "green",                 0xff008000 },;
    { "greenyellow",           0xff2fffad },;
    { "honeydew",              0xfff0fff0 },;
    { "hotpink",               0xffb469ff },;
    { "indianred",             0xff5c5ccd },;
    { "indigo",                0xff82004b },;
    { "ivory",                 0xfff0ffff },;
    { "khaki",                 0xff8ce6f0 },;
    { "lavender",              0xfffae6e6 },;
    { "lavenderblush",         0xfff5f0ff },;
    { "lawngreen",             0xff00fc7c },;
    { "lemonchiffon",          0xffcdfaff },;
    { "lightblue",             0xffe6d8ad },;
    { "lightcoral",            0xff8080f0 },;
    { "lightcyan",             0xffffffe0 },;
    { "lightgoldenrodyellow",  0xffd2fafa },;
    { "lightgreen",            0xff90ee90 },;
    { "lightgrey",             0xffd3d3d3 },;
    { "lightpink",             0xffc1b6ff },;
    { "lightsalmon",           0xff7aa0ff },;
    { "lightseagreen",         0xffaab220 },;
    { "lightskyblue",          0xffface87 },;
    { "lightslategray",        0xff998877 },;
    { "lightsteelblue",        0xffdec4b0 },;
    { "lightyellow",           0xffe0ffff },;
    { "lime",                  0xff00ff00 },;
    { "limegreen",             0xff32cd32 },;
    { "linen",                 0xffe6f0fa },;
    { "magenta",               0xffff00ff },;
    { "maroon",                0xff000080 },;
    { "mediumaquamarine",      0xffaacd66 },;
    { "mediumblue",            0xffcd0000 },;
    { "mediumorchid",          0xffd355ba },;
    { "mediumpurple",          0xffdb7093 },;
    { "mediumseagreen",        0xff71b33c },;
    { "mediumslateblue",       0xffee687b },;
    { "mediumspringgreen",     0xff9afa00 },;
    { "mediumturquoise",       0xffccd148 },;
    { "mediumvioletred",       0xff8515c7 },;
    { "midnightblue",          0xff701919 },;
    { "mintcream",             0xfffafff5 },;
    { "mistyrose",             0xffe1e4ff },;
    { "moccasin",              0xffb5e4ff },;
    { "navajowhite",           0xffaddeff },;
    { "navy",                  0xff800000 },;
    { "oldlace",               0xffe6f5fd },;
    { "olive",                 0xff008080 },;
    { "olivedrab",             0xff238e6b },;
    { "orange",                0xff00a5ff },;
    { "orangered",             0xff0045ff },;
    { "orchid",                0xffd670da },;
    { "palegoldenrod",         0xffaae8ee },;
    { "palegreen",             0xff98fb98 },;
    { "paleturquoise",         0xffeeeeaf },;
    { "palevioletred",         0xff9370db },;
    { "papayawhip",            0xffd5efff },;
    { "peachpuff",             0xffb9daff },;
    { "peru",                  0xff3f85cd },;
    { "pink",                  0xffcbc0ff },;
    { "plum",                  0xffdda0dd },;
    { "powderblue",            0xffe6e0b0 },;
    { "purple",                0xff800080 },;
    { "red",                   0xff0000ff },;
    { "rosybrown",             0xff8f8fbc },;
    { "royalblue",             0xffe16941 },;
    { "saddlebrown",           0xff13458b },;
    { "salmon",                0xff7280fa },;
    { "sandybrown",            0xff60a4f4 },;
    { "seagreen",              0xff578b2e },;
    { "seashell",              0xffeef5ff },;
    { "sienna",                0xff2d52a0 },;
    { "silver",                0xffc0c0c0 },;
    { "skyblue",               0xffebce87 },;
    { "slateblue",             0xffcd5a6a },;
    { "slategray",             0xff908070 },;
    { "snow",                  0xfffafaff },;
    { "springgreen",           0xff7fff00 },;
    { "steelblue",             0xffb48246 },;
    { "tan",                   0xff8cb4d2 },;
    { "teal",                  0xff808000 },;
    { "thistle",               0xffd8bfd8 },;
    { "tomato",                0xff4763ff },;
    { "turquoise",             0xffd0e040 },;
    { "violet",                0xffee82ee },;
    { "wheat",                 0xffb3def5 },;
    { "white",                 0xffffffff },;
    { "whitesmoke",            0xfff5f5f5 },;
    { "yellow",                0xff00ffff },;
    { "yellowgreen",           0xff32cd9a }}
local ltemp:=0

if valtype(par)=="C"
   par:=lower(alltrim(par))
   aeval(rgbcolornames,{|x| if(x[1]==par,ltemp:=x[2],'')})
elseif valtype(par)=="N"
   ltemp := if(par<=len(rgbcolornames),rgbcolornames[par,2],0)
endif
return ltemp


/*
*/
*-----------------------------------------------------------------------------*
METHOD SetMyRgb(dato) CLASS WREPORT
*-----------------------------------------------------------------------------*
   Local HexNumber, r
   default dato to 0
   hexNumber := DECTOHEXA(dato)
   IF ::PrnDrv = "HBPR"
      r := Rgb(HEXATODEC(substr(HexNumber,-2));
              ,HEXATODEC(substr(HexNumber,5,2)),HEXATODEC(substr(HexNumber,3,2)) )
   else
      r:={HEXATODEC(substr(HexNumber,-2));
         ,HEXATODEC(substr(HexNumber,5,2)),HEXATODEC(substr(HexNumber,3,2)) }
   Endif
return r

/*
*/
*-----------------------------------------------------------------------------*
METHOD Hgconvert(ltxt) CLASS WREPORT
*-----------------------------------------------------------------------------*
   do case
      case valtype(&ltxt)$"MC" ; return if("trans" $ lower(ltxt),ltxt,'FIELD->'+ltxt)
      case valtype(&ltxt)=="N" ; return 'str(FIELD->'+ltxt+')'
      case valtype(&ltxt)=="D" ; return 'dtoc(FIELD->'+ltxt+')'
      case valtype(&ltxt)=="L" ; return 'if(FIELD->'+ltxt+',".T.",".F.")'
   endcase
return ''
/*
*/
*-----------------------------------------------------------------------------*
METHOD TheHead() CLASS WREPORT
*-----------------------------------------------------------------------------*
Local grd, nkol
         if nPgr == mx_pg; last_pag:=.t. ;Endif
         do case
            case oWr:PrnDrv = "MINI"
                 START PRINTPAGE

            case oWr:PrnDrv = "PDF"
                 _hmg_hpdf_startpage()

            case oWr:PrnDrv = "HBPR"
                 START PAGE
         End

         nPgr ++ ; nPag ++ ; nline := 0

         // Top of Form //La Testa
         if oWr:PrnDrv = "HBPR"
            hbprn:settextcolor(0)
            if (grdemo .or. gcdemo) .and. nPgr < 2
               hbprn:modifypen("*",0,0.1,{255,255,255})
               if grdemo
                   for grd= 0 to ::mx_ln_doc -1
                       @grd,0 say grd to print
                       @grd+1,0,grd+1,hbprn:maxcol LINE
                   next
               Endif
               if gcdemo
                  for nkol = 0 to hbprn:maxcol
                      @ 0,nKol,::mx_ln_doc,nkol line
                      if int(nkol/10)-(nkol/10) = 0
                         @0,nKol say [*] to print
                      Endif
                  next
               Endif
            Endif
         Endif
         if ::aStat ['r_paint']        // La testa
            aeval(::aHead,{|x,y|if(Y>1 ,::traduci(x[1],,x[2]),'')})
         Endif
         nline := if(nPgr =1,if(flob < 1,eval(oWr:Valore,oWr:aHead[1])-1,flob),eval(oWr:Valore,oWr:aHead[1])-1)
         shd := .t.

return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD TheBody() CLASS WREPORT
*-----------------------------------------------------------------------------*
Local db_arc:=dbf(), noline:=.F., subcolor, nxtp :=.F., n, an, al
Local sstring := "NLINE"+if (::aStat [ 'Units' ] = "MM","*Lstep","")+chr(07) ;
      +NTrim(t_col*if (::aStat [ 'Units' ] = "MM",1,::aStat [ 'cStep' ] ))+chr(07)+"SAY"+chr(07)
      sstring += chr(05)+chr(07)+substr(ghstring,at("FONT",ghstring))
      if valtype(::argm[3])=="A"
         al := len(::argm[3])
         for an = 1 to al
             ::aCnt := an
             for N = 2 TO LEN(::aBody)
                 if ::traduci(::aBody[N,1],.F.,::aBody[N,2]) //n-1)
                     noline := .t.
                 Endif
                 if "MEMOSAY" $ upper( ::aBody[N,1] )
                    ::aStat [ 'ReadMemo' ] := ::aBody[n,1] + chr(07)+".F."
                 Endif
             next

             if  ::aStat [ 'Yes_Memo' ]    //memo Fields
                 ::traduci(::aStat [ 'ReadMemo' ])
                 if !noline
                    nline ++
                 Endif
                 noline := .F.
                 an := al
             else
                 if !noline
                    nline ++
                 Endif
                 noline := .F.
             Endif
             if an < al
                insgh := ( nline >= ::hb ) //head group checker
                // @0,0 say "**"+if(m->insgh =.T.,[.T.],[.F.])  FONT "F1" to print
                if nline >= ::HB-1
                   ::TheFeet()
                   ::TheHead()
                   nxtp := .t.
                Endif
             else
                 eline := nline
                 if eline < ::HB
                    nline := ::HB -1
                 Endif
                 last_pag := .t.
                 ::TheFeet(.t.)
             Endif
          next
      Else

         do While if(used(),! (dbf())->(Eof()),nPgr < ::aStat [ 'end_pr' ] )
            ::aStat [ 'GHline' ] := if (sbt =.F.,sbt ,::aStat [ 'GHline' ] )

            if nxtp .and. ::aStat [ 'GHline' ] .and. ::aStat ['r_paint'] .and. sgh // La seconda pagina
               get textcolor to subcolor
               set textcolor ::aStat['HGroupColor']
               ::traduci(Ghstring)
               set textcolor subcolor
               // @nline,0 say "**"+if(m->insgh =.T.,[.T.],[.F.])  FONT "F1" to print
               nxtp := .F. ; nline ++
            Endif

            if ::GrHead() //.and. ::aStat [ 'GHline' ]    // La testata
               if ::aStat ['r_paint'] .and. (shd .or. sbt) .and. sgh .and. !insgh
                  get textcolor to subcolor
                  set textcolor ::aStat['HGroupColor']
                  ::traduci(Ghstring)
                  set textcolor subcolor
                  // @nline,0 say "@@"+if(m->insgh =.T.,[.T.],[.F.])  FONT "F1" to print
                  nxtp := .F. ; nline ++
               Endif
               insgh:=.F.
            else
                for N = 2 TO LEN(::aBody)
                     if grdemo .or. gcdemo
                        if ::aStat ['r_paint']
                           if ::traduci(::aBody[N,1],,n-1)
                              noline := .t.
                           Endif
                           if "MEMOSAY" $ upper( ::aBody[N,1] )
                              ::aStat [ 'ReadMemo' ] := ::aBody[n,1] + chr(07)+".F."
                           Endif
                        Endif
                     else
                        if ::traduci(::aBody[N,1],.F.,::aBody[N,2]) //n-1)
                           noline := .t.
                        Endif
                        if "MEMOSAY" $ upper( ::aBody[N,1] )
                           ::aStat [ 'ReadMemo' ] := ::aBody[n,1] + chr(07)+".F."
                        Endif
                     Endif
                next
                // qui i conteggi

                Aeval(GFtotal,{|x,y| counter[y] += (db_arc)->&(x)})
                if  ::aStat [ 'Yes_Memo' ]    //memo Fields
                    ::traduci(::aStat [ 'ReadMemo' ])
                    if !noline
                       nline ++
                    Endif
                    noline := .F.
                else
                    if !noline
                       nline ++
                    Endif
                    noline := .F.
                    dbskip()
                Endif

                if Gfexec        // Display the subtotal of group
                   if ::GFeet()
                      if gfline .and. sbt
                         //Rivedere
                         get textcolor to subcolor
                         set textcolor ::aStat['GTGroupColor']
                         ::traduci(strtran(sstring,chr(05),"["+s_total+"]"))
                         if ::aStat['InlineSbt']= .F.
                            nline ++
                         Endif
                         Aeval(GFstring,{|x|::traduci(x)})
                         set textcolor subcolor
                         nline ++
                      Endif

                      Aeval(counter,{|x,y| gcounter[y] += x })
                      if ::aStat [ 'P_F_E_G' ]
                         eline := nline
                         ::TheFeet()
                         ::TheHead()
                      Endif
                      afill(Counter,0)
                   Endif
                Endif

                if !eof()
                   insgh := ( nline >= ::hb ) //head group checker
                   // @0,0 say "**"+if(m->insgh =.T.,[.T.],[.F.])  FONT "F1" to print
                   if nline >= ::HB-1
                      ::TheFeet()
                      ::TheHead()
                      nxtp := .t.
                   Endif
                else
                    if Gfexec  //display group total
                       if len(m->tts) > 0
                          ::traduci(strtran(sstring,chr(05),"["+m->tts+"]"))
                          if ::aStat['InlineTot']= .F.
                             NLINE ++
                          Endif
                          Aeval(GTstring,{|x|::traduci(x)})
                          nline++
                          nline++
                       Endif
                    Endif
                    eline := nline
                    if eline < ::HB
                       nline := ::HB -1
                    Endif
                    last_pag:=.t.
                    ::TheFeet(.t.)
                    afill(GCounter,0)
                Endif
            Endif
          Enddo
      Endif
return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD TheFeet(last) CLASS WREPORT            //Feet // IL Piede
*-----------------------------------------------------------------------------*
   default last to .F.
   if !last_pag
      eline := nline // if (eval(::Valore,::aBody[1])+eval(::Valore,::aBody[1]) < nline,nline,eline)
   Endif
   aeval(::aFeet,{|x,y|if(Y>1 ,::traduci(x[1],if(!(grdemo .or. gcdemo),'',.F.),x[2]),'')})
   last_pag := last
   Last := .T.
   if oWr:astat ['VRuler'] [2]
      ::VRuler(::astat ['VRuler'][1])
   Endif
   if oWr:astat ['HRuler'][2]
      ::HRuler(::astat ['HRuler'][1])
   Endif

   DO CASE
      CASE ::PrnDrv = "HBPR"
           End PAGE

      CASE ::PrnDrv = "MINI"
           if ( _HMG_MINIPRINT [23] == .T. , _HMG_PRINTER_ENDPAGE_PREVIEW (_HMG_MINIPRINT [19]) , _HMG_PRINTER_ENDPAGE ( _HMG_MINIPRINT [19] ) )

      CASE ::PrnDrv = "PDF"
           _hmg_hpdf_endpage()

   EndCASE
   if last
      nPgr := 0
      ::aStat [ 'EndDoc' ] := .T.
      ONEATLEAST := .F.
   Endif
return nil
/*
*/
*-----------------------------------------------------------------------------*
METHOD Quantirec(_MainArea) CLASS WREPORT     //count record that will be print
*-----------------------------------------------------------------------------*
Local conta:=0 , StrFlt :="",Typ_i := (indexord() > 0)
Private query_exp:=""
StrFlt := ::aStat [ 'FldRel' ]+" = "+ ::aStat [ 'area1' ]+"->"+::aStat [ 'FldRel' ]
if valtype(::argm[3])=="A"     // {_MainArea,_psd,db_arc,_prw}
  Return len(::argm[3])
Endif
// msgExclamation(typ_i,"quantirec 3522")
if !EMPTY(dbfilter())
   query_exp := dbfilter()
   DBGOTOP()
   if !empty(_MainArea)
      // msgbox(StrFlt)
      **count to conta FOR &StrFlt
      count to conta FOR &(::aStat [ 'FldRel' ]) = (::aStat [ 'area1' ])->&(::aStat [ 'FldRel' ])
      //msgbox([conta= ]+zaps(conta)+CRLF+" "+CRLF+query_exp,[Trovati Cxx])
   else
      if left(query_exp,3)=="{||"  // codeblock
         DBEval( {|| conta  ++ }, &(query_exp) ,,,, .F. )
      Else
         DBEval( {|| conta  ++ }, {||&query_exp  } ,,,, .F. )
      Endif
   Endif
   DBGOTOP()
else
   if valtype(::nrec)=="C"
      ::rec := val(::nrec)
   Endif
   conta := If (::NREC < 1, ordkeycount(), ::NREC )
Endif
 // msgbox(zaps(conta)+" per ["+query_exp+"]",[step 3])
return conta
/*
*/
*-----------------------------------------------------------------------------*
METHOD JustificaLinea(WPR_LINE,WTOPE) CLASS WREPORT
*-----------------------------------------------------------------------------*
Local I, SPACE1 := SPACE(1)
Local WLARLIN := LEN(TRIM(WPR_LINE))
FOR I=1 TO WLARLIN
   IF WLARLIN = WTOPE
      EXIT
   Endif
   IF SUBSTR(WPR_LINE,I,1)=SPACE1 .AND. SUBSTR(WPR_LINE,I-1,1)#SPACE1 .AND. SUBSTR(WPR_LINE,I+1,1)#SPACE1
      WPR_LINE := LTRIM(SUBSTR(WPR_LINE,1,I-1))+SPACE(2)+LTRIM(SUBSTR(WPR_LINE,I+1,LEN(WPR_LINE)-I))
      WLARLIN++
   Endif
NEXT I
RETURN WPR_LINE
/*
*/
*-----------------------------------------------------------------------------*
METHOD GestImage ( cImage ) CLASS WREPORT
*-----------------------------------------------------------------------------*
   Local Savefile := GetTempFolder(), nh := nil
   cImage := upper(cImage)
   if file( cImage )
      if ".PNG" $ cImage .or. ".TIF" $ cImage
         Savefile += "\_"+cfilenoext(cimage)+"_.JPG"
         aadd(::aStat[ 'aImages' ],SaveFile)
         if !file(Savefile)
            nh := BT_BitmapLoadFile (cimage)
            BT_BitmapSaveFile (nh, Savefile, BT_FILEFORMAT_JPG )
            BT_BitmapRelease (nh)
         Endif
      Else
         Savefile := cImage
      EndIf
   Endif
Return SaveFile
/*
*/
*-----------------------------------------------------------------------------*
METHOD DrawBarcode( nRow,nCol,nHeight, nLineWidth, cType, cCode, nFlags, SubTitle, Under, CmdLine ,Vsh) CLASS WREPORT
*-----------------------------------------------------------------------------*
   LOCAL hZebra, Ctxt, asize := {0,0}, nSh := 2, kj , KL := 0 , KH := 0
   LOCAL ny := 10 ,uobj := .F. ,i, fh ,sF := 9, page, dbgstr, lvl := 0
   Local aError := {"INVALID CODE ","BAD CHECKSUM ","TOO LARGE ","ARGUMENT ERROR " }

   DEFAULT SubTitle to .F., UNDER TO .F. , vSh to 0

   SWITCH cType
   CASE "EAN13"      ; hZebra := hb_zebra_create_ean13( cCode, nFlags )   ; EXIT
   CASE "EAN8"       ; hZebra := hb_zebra_create_ean8( cCode, nFlags )    ; EXIT
   CASE "UPCA"       ; hZebra := hb_zebra_create_upca( cCode, nFlags )    ; EXIT
   CASE "UPCE"       ; hZebra := hb_zebra_create_upce( cCode, nFlags )    ; EXIT
   CASE "CODE39"     ; hZebra := hb_zebra_create_code39( cCode, nFlags )  ; EXIT
   CASE "ITF"        ; hZebra := hb_zebra_create_itf( cCode, nFlags )     ; EXIT
   CASE "MSI"        ; hZebra := hb_zebra_create_msi( cCode, nFlags )     ; EXIT
   CASE "CODABAR"    ; hZebra := hb_zebra_create_codabar( cCode, nFlags ) ; EXIT
   CASE "CODE93"     ; hZebra := hb_zebra_create_code93( cCode, nFlags )  ; EXIT
   CASE "CODE11"     ; hZebra := hb_zebra_create_code11( cCode, nFlags )  ; EXIT
   CASE "CODE128"    ; hZebra := hb_zebra_create_code128( cCode, nFlags ) ; EXIT
   CASE "PDF417"     ; hZebra := hb_zebra_create_pdf417( cCode, nFlags ); nHeight := nLineWidth * 3 ;Uobj :=.T.; EXIT
   CASE "DATAMATRIX" ; hZebra := hb_zebra_create_datamatrix( cCode, nFlags ); nHeight := nLineWidth ;Uobj :=.T.; EXIT
   CASE "QRCODE"     ; hZebra := hb_zebra_create_qrcode( cCode, nFlags ); nHeight := nLineWidth ;Uobj :=.T.; EXIT

   ENDSWITCH

   IF hZebra != NIL
      IF hb_zebra_geterror( hZebra ) == 0
         IF EMPTY( nHeight )
            nHeight := 10
         ENDIF
         if nHeight < 10
            sF := 6
         Endif
         RELEASE FONT _BCF_
         DEFINE FONT _BCF_ FONTNAME 'HELVETICA' SIZE sF BOLD

         cTxt := hb_zebra_getcode( hZebra )
         if empty(cTxt); cTxt := cCode ;Endif
         i := AScan( _HMG_aControlNames, "_BCF_" )
         IF i > 0 .AND. _HMG_aControlType [i] == "FONT"
            fH := _HMG_aControlFontHandle [i]
         ENDIF

         Do Case

            Case oWr:prndrv = "HBPR"  // hbprinter
                 HBPRN:MODIFYFONT("_BC_","HELVETICA",SF,0,0,.T.,.F.,.F.,.T.,.F.,.T.,.F.,.T.)
                 kj:= hb_zebra_draw_wapi( hZebra, "_BC_" , nCol,NRow,NLineWidth,nHeight)
                 if SubTitle
                    hbprn:gettextextent_mm(" "+Ctxt+" ",asize,"_BC_")
                    KL := (Kj[1]+nSh-ncol)/2 + nCol -(asize[2]/2)
                    KH := (Kj[1]+nSh-ncol)/2 + nCol +(asize[2]/2)
                    if Uobj
                       HBPRN:SAY(kj[2]+2,(Kj[1]+nSh-ncol)/2+nCol,cTxt,"_BC_",{0,0,0},6)
                    Else
                       if under
                          HBPRN:SAY(nRow+nHeight+if(sf < 9,-1,.3)+vSh,(Kj[1]+nSh-ncol)/2+nCol,cTxt,"_BC_",{0,0,0},6)
                       Else
                          hbprn:rectangle(nRow+nHeight-asize[1]+.5,KL,nRow+nHeight,KH,"WHITE","B0")
                          HBPRN:SAY(nRow+nHeight-asize[1]+if(sf < 9,-1,.2)+vSh,(Kj[1]+nSh-ncol)/2+nCol,Ctxt,"_BC_",{0,0,0},6)
                       Endif
                    Endif
                 Endif

            Case oWr:prndrv = "MINI" // miniprint
                 kj:= hb_zebra_draw_wapi( hZebra, _hmg_printer_hdc , nCol,NRow,NLineWidth,nHeight)

                 if SubTitle
                    asize[1] := _HMG_HPDF_Pixel2MM(GETTEXTHEIGHT( _hmg_printer_hdc, Ctxt,FH ))
                    asize[2] := _HMG_HPDF_Pixel2MM(GETTEXTWIDTH( Nil, Ctxt,FH ))

                    KL := (Kj[1]+nSh-ncol)/2 + nCol -(asize[2]/2)
                    KH := (Kj[1]+nSh-ncol)/2 + nCol +(asize[2]/2)
                    if Uobj
                       _HMG_PRINTER_H_PRINT ( _hmg_printer_hdc ,kj[2]+2 ,(kj[1]+nSh-nCol)/2+ncol  ;
                       , "HELVETICA" , sF ,0 ,0 ,0 , cTxt , .T. , .F. , .F. , .F. , .F. , .T. , .T. , "CENTER" )
                    Else
                       if under
                          _HMG_PRINTER_H_PRINT ( _hmg_printer_hdc , nRow+nHeight-if(sf < 9,0,-.5) ,(kj[1]+nSh-nCol)/2+ncol  ;
                          , "HELVETICA" , sF ,0 ,0 ,0 , cTxt , .T. , .F. , .F. , .F. , .F. , .T. , .T. , "CENTER" )
                       Else
                          _HMG_PRINTER_H_RECTANGLE ( _hmg_printer_hdc , nrow+nHeight-asize[1]+2;
                          , KL , nRow+nHeight , KH , 0 , 255 , 255 , 255 , .T. , .T. , .T. , .T. )
                          _HMG_PRINTER_H_PRINT ( _hmg_printer_hdc , nRow+nHeight-asize[1]+if(sf < 9,1.5,2) ,(kj[1]+nSh-nCol)/2+ncol  ;
                          , "HELVETICA" , sF ,0 ,0 ,0 , cTxt , .T. , .F. , .F. , .F. , .F. , .T. , .T. , "CENTER" )
                       Endif
                    Endif
                 Endif

            Case oWr:PrnDrv = "PDF"   // PdfPrint
                 page := _HMG_HPDFDATA[ 1 ][ 7 ]

                 nY := HPDF_Page_GetHeight( page ) - _HMG_HPDF_MM2Pixel(nrow)
                 HPDF_Page_SetRGBFill( page, 0.0, 0.0, 0.0 )
                 kj := hb_zebra_draw_wapi( hZebra, page ,_HMG_HPDF_MM2Pixel(nCol),nY, _HMG_HPDF_MM2Pixel(nLineWidth), -_HMG_HPDF_MM2Pixel( nHeight ) )

                 if SubTitle
                    HPDF_Page_SetFontAndSize( page , HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], "Helvetica-Bold", NIL ), sF )
                    asize[1] := GETTEXTHEIGHT( Nil, Ctxt, fH )
                    asize[2] := HPDF_Page_TextWidth( page, cTxt+"  " )

                    KL := (kj[1]-_HMG_HPDF_MM2Pixel(nCol)+_HMG_HPDF_MM2Pixel(nSh))/2 + _HMG_HPDF_MM2Pixel(nCol)-(asize[2]/2) //COL
                    KH :=  kj[2]-_HMG_HPDF_MM2Pixel(nheight)-aSize[1]+(Asize[1]/2)+sf   // ROW

                    if Uobj
                       HPDF_Page_BeginText( page )
                       HPDF_Page_TextOut( page , KL , KH -2- sF , cTxt )
                       HPDF_Page_EndText( page )
                    Else
                       if under
                          HPDF_Page_BeginText(page)
                          HPDF_Page_TextOut( page , KL , KH-2-sf , cTxt )
                       Else
                          HPDF_Page_SetRGBFill(page, 1, 1, 1) // for white rectangle
                          HPDF_Page_Rectangle( page, kl-2, KH-2, asize[2], sF )
                          HPDF_Page_Fill( page )

                          HPDF_Page_BeginText(page)
                          HPDF_Page_SetRGBFill( page, 0.0, 0.0, 0.0 )
                          HPDF_Page_TextOut( page , KL , KH-1 , cTxt )
                       Endif
                       HPDF_Page_EndText( page )
                    Endif
                 Endif

         Endcase
      ELSE

         dbgstr := "Error on script line :"+ZAPS( cmdline )
         aeval(::aStat[ 'ErrorLine' ],{|x|if (dbgstr == x,  lvl:=1 ,'')} )
         if lvl < 1 .and. cmdline > 0
         dbgstr :=("Type "+ cType + " Code "+ cCode+CRLF+ "Error is: "+ aError[hb_zebra_geterror( hZebra )]+CRLF+"Barcode NOT generated!" )
            if ascan( ::aStat [ 'ErrorLine' ] , dbgstr ) < 1
               aadd(::aStat [ 'ErrorLine' ] , dbgstr )
               MSGSTOP(dbgstr,"MiniGui Extended Report Interpreter Error")
            Endif
            ::aStat [ 'OneError' ]  := .T.
         Endif
      ENDIF
      hb_zebra_destroy( hZebra )
   ELSE
      dbgstr := "Error on script line :"+ZAPS( cmdline )
      aeval(::aStat[ 'ErrorLine' ],{|x|if (dbgstr == x,  lvl:=1 ,'')} )
      if lvl < 1 .and. cmdline > 0
         MSGSTOP(dbgstr,"MiniGui Extended Report Interpreter Error")
         if ascan( ::aStat [ 'ErrorLine' ] , dbgstr ) < 1
            aadd(::aStat [ 'ErrorLine' ] , dbgstr )
            dbgstr :=("Type "+ cType + " Code "+ cCode+CRLF+ "Error is: "+ aError[hb_zebra_geterror( hZebra )]+CRLF+"Barcode NOT generated!" )
         Endif
         ::aStat [ 'OneError' ]  := .T.
      Endif
   ENDIF
   RELEASE FONT _BCF_

RETURN SELF
/*
*/
*-----------------------------------------------------------------------------*
METHOD VRuler( vPos ) CLASS WREPORT
*-----------------------------------------------------------------------------*
    LOCAL i1, mx, ounits
    DEFAULT vPos := 4

    Do case
       case oWr:prndrv = "HBPR"
            ounits:=hbprn:units
            hbprn:setunits(1)
            mx :=  hbprn:maxrow
            FOR i1 = 10 TO mx
                hbprn:line(000+i1 , vPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0", vPos+007 ;
                ,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", vPos+005, vPos+4 ) ),"BLACK" )
                hbprn:say((i1-3.5),vPos,IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), ""),"_RULER_",0)
            NEXT
            hbprn:setunits(ounits)

       Case oWr:prndrv = "MINI"
            mx := _HMG_PRINTER_GETPRINTERHEIGHT(_HMG_MINIPRINT[19])
            FOR i1 = 10 TO mx
                _HMG_PRINTER_H_PRINT ( _HMG_MINIPRINT[19] , -2+i1 , vPos , , 6 , { 0 } , { 0 }, { 0 } , IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") , .F. , .F. , .F. , .F. , .T. , .F. , .T. , , .F. , )
                _HMG_PRINTER_H_LINE ( _HMG_MINIPRINT[19] , 000+i1 , vPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0", vPos+007,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", vPos+005, vPos+4 ) ) , .1 , { 128 } , { 128 } , { 128 } , .T. , .T. , .F. )
            NEXT

       Case oWr:prndrv = "PDF"
            mx:= _HMG_HPDF_Pixel2MM(HPDF_Page_GetHeight(_HMG_HPDFDATA[ 1 ][ 7 ]))-5
            FOR i1=10 TO mx
                _HMG_HPDF_PRINT ( 000+i1 , vPos-1 , , 6 , 0 , 0 , 0 , IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") , .F. , .F. , .F. , .F. , .T. , .F. , .T. , , )
                _HMG_HPDF_LINE  ( 000+i1 , vPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0", vPos+007,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", vPos+005, vPos+4 ) ) , .1 , 128 , 128 , 128 , .T. , .T. )
            NEXT
    Endcase
RETURN  NIL
/*
*/
*-----------------------------------------------------------------------------*
METHOD HRuler( hPos ) CLASS WREPORT
*-----------------------------------------------------------------------------*
    LOCAL i1, mx
    DEFAULT hPos := 4
    Do case
       case oWr:prndrv = "HBPR"
            mx :=  hbprn:maxcol
            FOR i1 = 10 TO mx
               hbprn:say(hPos-3,(000+i1)-1,IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), ""),"_RULER_",{0,0,0})
               hbprn:line(hpos,000+i1,IF( RIGHT( STR( INT( i1 ) ),1 )="0",hPos+007 ;
                         ,IF( RIGHT( STR( INT( i1 ) ),1 )="5", hPos+005, hPos+4 ) ),000+i1,"BLACK" )
            Next
       Case oWr:prndrv = "MINI"
            mx := _HMG_PRINTER_GETPRINTERWIDTH(_HMG_MINIPRINT[19])
            FOR i1 = 10 TO mx
                _HMG_PRINTER_H_PRINT ( _HMG_MINIPRINT[19] , hPos-2,-1+i1 , , 6 , { 0} , { 0 } , { 0 } , IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") , .F. , .F. , .F. , .F. , .T. , .F. , .T. , , .F. , )
                _HMG_PRINTER_H_LINE ( _HMG_MINIPRINT[19] , hPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0",hPos+007,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", hPos+005, hPos+4 ) ) , 000+i1 , .1 , { 128 }, { 128 } , { 128 } , .T. , .T. , .F. )
            NEXT

       Case oWr:prndrv = "PDF"
            mx:= _HMG_HPDF_Pixel2MM(HPDF_Page_Getwidth(_HMG_HPDFDATA[ 1 ][ 7 ]))-5
            FOR i1 = 10 TO mx
                _HMG_HPDF_PRINT ( hPos , (000+i1)-1 , , 6 , 0 , 0 , 0 , IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") , .F. , .F. , .F. , .F. , .T. , .F. , .T. , , )
                _HMG_HPDF_LINE  ( hPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0",hPos+007,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", hPos+005, hPos+4 ) ) , 000+i1 , .1 , 128 , 128 , 128 , .T. , .T. )
            NEXT
    Endcase
RETURN NIL
