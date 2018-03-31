
#include 'minigui.ch'
#include 'miniprint.ch'
#include "hbclass.ch"
#include "hbzebra.ch"

#translate MSG	=> MSGBOX
#translate ZAPS(<X>) => ALLTRIM(STR(<X>))
#define NTRIM( n ) LTrim( Str( n ) )
#translate Test( <c> ) => MsgInfo( <c>, [<c>] )
#define MsgInfo( c ) MsgInfo( c, , , .f. )
#define MsgAlert( c ) MsgEXCLAMATION( c, , , .f. )
#define MsgStop( c ) MsgStop( c, , , .f. )

#define MGSYS  .F.

memvar nomevar,hbprn
memvar _money
memvar _separator
memvar _euro
memvar epar
memvar chblk,chblk2
memvar oneatleast, shd, sbt, sgh,insgh
memvar gcounter
memvar counter
memvar gcdemo
memvar grdemo
memvar align
memvar GHstring, GFstring, GTstring
memvar GField
memvar s_head,TTS
memvar last_pag
memvar s_col, t_col,  wheregt
memvar gftotal, Gfexec, s_total
memvar nline
memvar nPag, nPgr, Tpg
memvar eLine, GFline
memvar maxrow, maxcol, mncl, mxH
memvar abort
memvar flob
memvar Cal
memvar Cxx
memvar _pW
memvar _pH
memvar lstep, cStep, atf, mx_pg

//memvar nlinepart
memvar _varmem, _varexec, _aalign
memvar oWr

*-----------------------------------------------------------------------------*
* Printing Procedure                //La Procedura di Stampa
*-----------------------------------------------------------------------------*
Procedure PrMiniEsegui(_MainArea,_psd,db_arc,_prw)
*-----------------------------------------------------------------------------*
         Local oldrec   := recno()
         local landscape:=.f.
         local lpreview :=.f.
         local lselect  :=.f.
         local str1     :=[]
         local ncpl , nfsize
         local condition:=[]
         local aprinters
         local StrFlt   :=""
         local lbody    := 0, miocont := 0, miocnt := 0
         local Amx_pg   :={}
         Local lperror  := .F.
         Local Lsuccess := .F.
         Private ONEATLEAST := .F., shd := .t., sbt := .t., sgh := .t., insgh:=.F.
         Private hbprn :=hbprinter():new()

         chblk  :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+1],''),'')}
         chblk2 :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+2],''),'')}

         if !empty(_MainArea)
             oWr:aStat [ 'area1' ]  :=substr(_MainArea,at('(',_MainArea)+1)
             oWr:aStat [ 'FldRel' ] :=substr(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])+2)
             oWr:aStat [ 'FldRel' ] :=substr(oWr:aStat [ 'FldRel' ],1,if(at(')',oWr:aStat [ 'FldRel' ])>0,at(')',oWr:aStat [ 'FldRel' ])-1,len(oWr:aStat [ 'FldRel' ]))) //+(at("->",oWr:aStat [ 'area1' ])))
             oWr:aStat [ 'area1' ]  :=left(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])-1)
         Else
             oWr:aStat [ 'area1' ]:=dbf()
             oWr:aStat [ 'FldRel' ]:=''
         Endif

         aprinters := aprinters()

         Private counter   := {}  , Gcounter  := {}

         Private grdemo    := .F. , Gcdemo    := .F.

         Private Align     :=  0  , GHstring  := ""
         Private GFstring  := {}  , GTstring  := {}
         Private GField    := ""  , S_head    := ""
         Private TTS       := "Totale"
         Private s_col     :=  0  , Gftotal   := {}
         Private Gfexec    := .F. , S_total   := ""
         Private t_col     :=  0  , nline     := oWr:mx_ln_doc
         Private nPag      :=  0  , mx_pg     := 0
         Private nPgr      :=  0  , Tpg       := 0
         Private last_pag  := .F. , eLine     :=  0
         Private wheregt   :=  0  , GFline    := .F.
         Private abort     := 0
         Private maxcol    := 0,  maxrow :=0, mncl :=0, mxH :=0

         ncpl := eval(oWr:Valore,oWr:Adeclare[1])
         str1 := upper(substr(oWr:Adeclare[1,1],at("/",oWr:Adeclare[1,1])+1))

         If ncpl = 0
            ncpl   :=80
            nfsize :=12
         Else
            do case
               case ncpl= 80
                  nfsize:=12
               case ncpl= 96
                  nfsize:=10
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

         if "LAND" $ Str1 ;landscape:=.t.; Endif
         if "SELE" $ Str1 ;lselect  :=.t.; Endif
         if "PREV" $ Str1
            lpreview := .t.
         else
            lpreview := _prw
         Endif

         str1 := upper(substr(oWr:ABody[1,1],at("/",oWr:aBody[1,1])+1))
         flob := val(str1)

         if ncpl = 0
            ncpl   :=80
            nfsize :=12
         Else
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
            Endcase
         Endif

         oWr:pGenSet()

         If lselect .and. lpreview
            SELECT PRINTER DIALOG to lSuccess PREVIEW
         Endif
         If lselect .and. (!lpreview)
            SELECT PRINTER DIALOG  to lSuccess
         Endif
         if !lselect .and. lpreview
            if ascan(aprinters,_PSD) < 1
               _psd := GetDefaultPrinter()
            Endif
            If oWr:aStat[ 'PaperSize' ]  > 0 .and. oWr:aStat[ 'PaperSize' ] < 256 // Ok
               SELECT PRINTER _psd TO lSuccess ;
               ORIENTATION   oWr:aStat[ 'Orient' ] ;
               PAPERSIZE     oWr:aStat[ 'PaperSize' ] ;
               COPIES        oWr:aStat[ 'Copies' ] ;
               DEFAULTSOURCE oWr:aStat[ 'Source' ] ;
               QUALITY       oWr:aStat[ 'Res' ] ;
               COLOR         oWr:aStat[ 'ColorMode' ] ;
               DUPLEX        oWr:aStat[ 'Duplex' ] ;
               COLLATE       oWr:aStat[ 'Collate' ] ;
               PREVIEW
            Else
               SELECT PRINTER _psd TO lSuccess ;
               ORIENTATION   oWr:aStat[ 'Orient' ] ;
               PAPERSIZE     oWr:aStat[ 'PaperSize' ] ;
               PAPERLENGTH   oWr:aStat[ "PaperLength" ] ;
               PAPERWIDTH    oWr:aStat[ 'PaperWidth' ] ;
               COPIES        oWr:aStat[ 'Copies' ] ;
               DEFAULTSOURCE oWr:aStat[ 'Source' ] ;
               QUALITY       oWr:aStat[ 'Res' ] ;
               COLOR         oWr:aStat[ 'ColorMode' ] ;
               DUPLEX        oWr:aStat[ 'Duplex' ] ;
               COLLATE       oWr:aStat[ 'Collate' ] ;
               PREVIEW
            Endif
         Endif

         If !lselect .and. !lpreview
            if ascan(aprinters,_PSD) < 1
               _psd := GetDefaultPrinter()
            Endif
            If oWr:aStat[ 'PaperSize' ]  > 0 .and. oWr:aStat[ 'PaperSize' ] < 256 // Ok
               SELECT PRINTER _psd TO lSuccess ;
               ORIENTATION   oWr:aStat[ 'Orient' ] ;
               PAPERSIZE     oWr:aStat[ 'PaperSize' ] ;
               COPIES        oWr:aStat[ 'Copies' ] ;
               DEFAULTSOURCE oWr:aStat[ 'Source' ] ;
               QUALITY       oWr:aStat[ 'Res' ] ;
               COLOR         oWr:aStat[ 'ColorMode' ] ;
               DUPLEX        oWr:aStat[ 'Duplex' ] ;
               COLLATE       oWr:aStat[ 'Collate' ]
            Else
               SELECT PRINTER _psd TO lSuccess ;
               ORIENTATION   oWr:aStat[ 'Orient' ] ;
               PAPERSIZE     oWr:aStat[ 'PaperSize' ] ;
               PAPERLENGTH   oWr:aStat[ "PaperLength" ] ;
               PAPERWIDTH    oWr:aStat[ 'PaperWidth' ] ;
               COPIES        oWr:aStat[ 'Copies' ] ;
               DEFAULTSOURCE oWr:aStat[ 'Source' ] ;
               QUALITY       oWr:aStat[ 'Res' ] ;
               COLOR         oWr:aStat[ 'ColorMode' ] ;
               DUPLEX        oWr:aStat[ 'Duplex' ] ;
               COLLATE       oWr:aStat[ 'Collate' ]
            Endif
         Endif

         If if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) == 0 .or. lperror
            r_mem()
            return
         Endif
         If !MGSYS
           _HMG_SYSDATA [ 374 ]:=_hmg_printer_hdc
         Endif
         mncl:=round(( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETX ( _HMG_SYSDATA [ 374 ] ) / _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSX ( _HMG_SYSDATA [ 374 ] ) * 25.4 ),3)
         mncl:=( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETX ( _HMG_SYSDATA [ 374 ] ) / _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSX ( _HMG_SYSDATA [ 374 ] ) * 25.4 )

         Cal :=(_HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETY ( _HMG_SYSDATA [ 374 ] ) / _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSY ( _HMG_SYSDATA [ 374 ] ) )* 25.4 //,2)
         Cxx :=(_HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETX ( _HMG_SYSDATA [ 374 ] ) / _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSX ( _HMG_SYSDATA [ 374 ] ) )* 25.4 //,2)
         oWr:Lmargin := Cxx
         _pW :=round((2*cxx)+_HMG_PRINTER_GETPRINTERWIDTH(_HMG_SYSDATA [ 374 ]),0)
         _pH :=round((2*cal)+_HMG_PRINTER_GETPRINTERHEIGHT(_HMG_SYSDATA [ 374 ]),0)

         mxH    := _HMG_PRINTER_GETPAGEHEIGHT(if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc))
         maxrow := int(mxh/LStep)
         maxcol := _HMG_PRINTER_GETPRINTERWIDTH(_HMG_SYSDATA [ 374 ])-1
         oWr:COLSTEP(ncpl,maxcol)
         cStep  := oWr:aStat[ 'cStep' ]

         aeval(oWr:adeclare,{|x,y|if(Y > 1 ,oWr:traduci(x[1],,x[2]),'')})

         if abort != 0
            r_mem()
            return
         Endif

         if used()
            if !empty(atf)
               set filter to &atf
            Endif
            oWr:aStat [ 'end_pr' ] := oWr:quantirec(_mainarea)
         else
            oWr:aStat [ 'end_pr' ] := oWr:quantirec(_mainarea)
         Endif

         START PRINTDOC NAME _HMG_SYSDATA [ 358 ]

         if empty(_MainArea)
            Lbody := eval(oWr:Valore,oWr:aBody[1])
            mx_pg := INT(oWr:aStat[ 'end_pr' ]/NOZERODIV(Lbody) )
            if (mx_pg * lbody) # mx_pg
               mx_pg ++
            Endif
            mx_pg :=ROUND( max(1,mx_pg), 0 )
            tpg := mx_pg
            if valtype(oWr:argm[3]) # "A"
               Dbgotop()
            Endif
            if oWr:aStat [ 'end_pr' ] # 0
               while !oWr:aStat [ 'EndDoc' ]
                     oWr:TheHead()
                     oWr:TheBody()
               enddo
            Endif
         else
            sele (oWr:aStat [ 'area1' ])
            if !empty(atf)
               set filter to &atf
            Endif
            Dbgotop()
            lbody:=eval(oWr:Valore,oWr:aBody[1])
            while !eof()
                  sele (DB_ARC)
                  StrFlt:= oWr:aStat [ 'FldRel' ]+" = "+ oWr:aStat [ 'area1' ]+"->"+oWr:aStat [ 'FldRel' ]
                  DBEVAL( {|| miocont++},{|| &strFLT} )
                  miocnt:= int(miocont/NOZERODIV(lbody))
                  if (miocnt * lbody) # miocont
                     miocnt ++
                  Endif
                  tpg += miocnt
                  //msg(zaps(tpg)+crlf+zaps(miocnt),[Tpg1])
                  aadd(Amx_pg,miocnt)
                  miocont := 0
                  sele (oWr:aStat [ 'area1' ])
                  dbskip()
            enddo
            go top
            while !eof()
                 sele (DB_ARC)
                 set filter to &strFLT
                 miocont ++
                 mx_pg:=aMx_pg[miocont]
                 go top
                 nPgr:=0
                 while !eof()
                       oWr:TheHead()
                       oWr:TheBody()
                 enddo
                 oWr:aStat [ 'EndDoc' ]:=.f.
                 last_pag:=.f.
                 set filter to
                 sele (oWr:aStat [ 'area1' ])
                 dbskip()
            enddo
         Endif
         if oneatleast
            go top
            oWr:TheHead()
            oWr:TheBody()
         Endif

         END PRINTDOC

         if used();dbgoto(oldrec);Endif
         hbprn:end()
         r_mem(.T.)
Return
/*
*/
*-----------------------------------------------------------------------------*
Function RMiniPar(ArryPar,cmdline,section)
*-----------------------------------------------------------------------------*
   local Aclr,blse := {|x| if(val(x)> 0,.t.,if(x=".T.".or. x ="ON",.T.,.F.))}
   local ax := {}, _Arg2, _Arg3, _Arg4, _Arg5

   if len (ArryPar) < 1 ;return .F. ;Endif

   maxrow  := int(_HMG_PRINTER_GETPAGEHEIGHT(if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc))/LStep)
   maxcol := _HMG_PRINTER_GETPRINTERWIDTH(_HMG_SYSDATA [ 374 ])-1
//   msgmulty(arrypar)
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
                   &_varmem := oWr:MACROCOMPILE("("+ArryPar[4]+")",.t.,cmdline,section)

              case ArryPar[4] == "C"
                   &_varmem := xvalue(ArryPar[3],ArryPar[4])

              case ArryPar[4] == "N"
                   &_varmem := xvalue(ArryPar[3],ArryPar[4])

              case ArryPar[4] == "A"
                   &_varmem := oWr:MACROCOMPILE("("+ArryPar[3]+")",.t.,cmdline,section)
           Endcase

      case arryPar[1]==[GROUP]
              Group(arryPar[2],arryPar[3],arryPar[4],arryPar[5],arryPar[6],arryPar[7],arryPar[8],arryPar[9])

      case arryPar[1]==[ADDLINE]
           nline ++

      case arryPar[1]==[SUBLINE]
           nline --

      case len(ArryPar)=1
           if "DEBUG_" != left(ArryPar[1],6) .and. "ELSE" != left(ArryPar[1],4)
               oWr:MACROCOMPILE(ArryPar[1],.t.,cmdline,section)
           Endif

      case ascan(arryPar,[ONEATLEAST])= 2
           ONEATLEAST :=eval(blse,arrypar[3])

      case ascan(arryPar,[SUBTOTALS])=2
           m->sbt := (eval(blse,arrypar[3]))

      case ascan(arryPar,[SHOWGHEAD])=2
           m->sgh := (eval(blse,arrypar[3]))

      case ascan(arryPar,[INLINESBT])=2
          oWr:aStat['InlineSbt'] := (eval(blse,arrypar[3]))

      case ascan(arryPar,[INLINETOT])=2
          oWr:aStat['InlineTot'] := (eval(blse,arrypar[3]))

      case ascan(arryPar,[TOTALSTRING])=2
           m->TTS := eval( chblk,arrypar,[TOTALSTRING] )

      case ascan(arryPar,[GROUPBOLD])=2
           oWr:aStat['GroupBold'] := (eval(blse,arrypar[3]))

      case ascan(arryPar,[HGROUPCOLOR])=2
           oWr:aStat['HGroupColor'] := oWr:UsaColor(eval(chblk,arrypar,[HGROUPCOLOR]))

      case ascan(arryPar,[GTGROUPCOLOR])=2
           oWr:aStat['GTGroupColor'] := oWr:UsaColor(eval(chblk,arrypar,[GTGROUPCOLOR]))

      case ascan(arryPar,"SET")=1
           do case
              case ascan(arryPar,[VRULER])= 2
                   oWr:astat ['VRuler'][1] := val(eval(chblk,arrypar,[VRULER]))
                   if len(arrypar) > 3
                      oWr:astat ['VRuler'][2] := eval(blse,eval(chblk2,arrypar,[VRULER]))
                   Else
                      oWr:astat ['VRuler'][2] := .F.
                   Endif

              case ascan(arryPar,[HRULER])= 2
                   oWr:astat ['HRuler'][1] := val(eval(chblk,arrypar,[HRULER]))
                   if len(arrypar) > 3
                      oWr:astat ['HRuler'][2] := eval(blse,eval(chblk2,arrypar,[HRULER]))
                   Else
                      oWr:astat ['HRuler'][2] := .F.
                   Endif

              case ascan(arryPar,[EURO])=2
                  _euro:= eval(blse,arrypar[3])

              case ascan(arryPar,[MONEY])=2
                   _money:= eval(blse,arrypar[3])

              case ascan(arryPar,[SEPARATOR])=2
                   _separator:= eval(blse,arrypar[3])

              case ascan(arryPar,[PREVIEW])=2  .and. len(arrypar)= 3
                   _hmg_printer_preview:= eval(blse,arrypar[3])

              case ascan(arryPar,[HBPCOMPATIBLE])= 3
                   _ARG2 := VAL(eval(chblk,arrypar,[HBPCOMPATIBLE]))
                   IF _ARG2 # 0
                      oWr:aStat[ 'Hbcompatible' ] := _ARG2
                   Else
                      oWr:aStat[ 'Hbcompatible' ] := -2.5
                   Endif

              case ascan(arryPar,[JOB])= 2
                   _HMG_SYSDATA [ 358 ]:= eval(chblk,arrypar,[NAME])

              case ascan(arryPar,[MARGINS])=3
                   WRM_SETVIEWPORTORG(_hmg_printer_hdc;
                   ,Mconvert({val(eval(chblk,arrypar,[TOP])),val(eval(chblk,arrypar,[LEFT]))}))

             case ascan(ArryPar,[CHARSET])=2
                  _HMG_SETCHARSET(oWr:what_ele(eval(chblk,arrypar,[CHARSET]),oWr:aCh,"_acharset"))

           endcase

      case ascan(ArryPar,[ROUNDRECT])=5
           Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
           _arg2 := max(.1,val(eval(chblk,arrypar,[PENWIDTH])))
           _HMG_PRINTER_H_ROUNDRECTANGLE ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
           , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
           , eval(epar,ArryPar[2]) ;
           , eval(epar,ArryPar[3]) ;
           , eval(epar,ArryPar[4]) ;
           , _arg2 ; //val(eval(chblk,arrypar,[PENWIDTH])) ;
           , Aclr[1] ;
           , Aclr[2] ;
           , Aclr[3] ;
           , .T. ; //if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
           , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )

      case ascan(ArryPar,[RECTANGLE])=5
           Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
           _arg2 := max(.1,val(eval(chblk,arrypar,[PENWIDTH])))
           _HMG_PRINTER_H_RECTANGLE ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
           , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
           , eval(epar,ArryPar[2]) ;
           , eval(epar,ArryPar[3]) ;
           , eval(epar,ArryPar[4]) ;
           , _arg2 ;
           , Aclr[1] ;
           , Aclr[2] ;
           , Aclr[3] ;
           , .T. ;
           , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )

      case ascan(ArryPar,[LINE])=5
           Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
           _arg2 := max(.1,val(eval(chblk,arrypar,[PENWIDTH])))

           _HMG_PRINTER_H_LINE ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc),;
                if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                , eval(epar,ArryPar[2]) ;
                , if([LINE]$ Arrypar[3],&(Arrypar[3]),eval(epar,ArryPar[3])) ;
                , eval(epar,ArryPar[4]) ;
                , _arg2 ;
                , Aclr[1] ;
                , Aclr[2] ;
                , Aclr[3] ;
                , .t. ; //if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                , if(ascan(arryPar,[DOTTED])>0, .T.,.f.))

      case ascan(ArryPar,[PRINT])=3 .OR. ascan(ArryPar,[SAY])= 3
              Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
              do case
                 case ASCAN(ArryPar,[IMAGE]) > 0
                    _HMG_PRINTER_H_IMAGE ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
                    , oWr:GestImage(eval(chblk,arrypar,[IMAGE]));
                    , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                    , eval(epar,ArryPar[2]) ;
                    , val(eval(chblk,arrypar,[HEIGHT]));
                    , val(eval(chblk,arrypar,[WIDTH]));
                    , if(ascan(ArryPar,[STRETCH])> 0,.t.,.T.)) // Put true for better compatibility with HBPRINTER
                    // Unfortunately miniprint has a misbehaving without stretch clause
                    // _HMG_PRINTER_IMAGE (if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc),"hmglogo.gif",25,25,20,16 )

                 case ASCAN(ArryPar,[LINE]) > 0
                       // 1: hDC
                       // 2: y
                       // 3: x
                       // 4: toy
                       // 5: tox
                       // 6: width
                       // 7: R Color
                       // 8: G Color
                       // 9: B Color
                       // 10: lWindth
                       // 11: lColor
                       // 12: Dotted
                       // @ 260,20 PRINT LINE TO 260,190 ==
                       //_HMG_PRINTER_LINE (if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc),260,20,260,190,,"1","2","3",.F.,.F. )
                      _arg2 := max(.1,val(eval(chblk,arrypar,[PENWIDTH])))
                      _HMG_PRINTER_H_LINE ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
                      , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                      , eval(epar,ArryPar[2]) ;
                      , eval(epar,ArryPar[6]) ;
                      , eval(epar,ArryPar[7]) ;
                      , _arg2 ;
                      , Aclr[1] ;
                      , Aclr[2] ;
                      , Aclr[3] ;
                      , .t. ;
                      , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                      , if(ascan(arryPar,[DOTTED])>0, .T.,.f.) )

                 case ASCAN(ArryPar,[RECTANGLE]) > 0

                      // @ 20,20 PRINT RECTANGLE TO 50,190 ==
                      //_HMG_PRINTER_RECTANGLE (if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc),20,20,50,190,,"1","2","3",.F.,.F. )
                      _arg2 := max(.1,val(eval(chblk,arrypar,[PENWIDTH])))

                      if ASCAN(ArryPar,[ROUNDED])> 0
                         _HMG_PRINTER_H_ROUNDRECTANGLE ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
                         , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                         , eval(epar,ArryPar[2]) ;
                         , eval(epar,ArryPar[6]) ;
                         , eval(epar,ArryPar[7]) ;
                         , _arg2 ;
                         , Aclr[1] ;
                         , Aclr[2] ;
                         , Aclr[3] ;
                         , .t. ;
                         , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )
                      else
                         _HMG_PRINTER_H_RECTANGLE ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
                         , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                         , eval(epar,ArryPar[2]) ;
                         , eval(epar,ArryPar[6]) ;
                         , eval(epar,ArryPar[7]) ;
                         , _arg2 ;
                         , Aclr[1] ;
                         , Aclr[2] ;
                         , Aclr[3] ;
                         , .T. ;
                         , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )

                     Endif

              otherwise
                  // 1:  Hdc
                  // 2:  y
                  // 3:  x
                  // 4:  FontName
                  // 5:  FontSize
                  // 6:  R Color
                  // 7:  G Color
                  // 8:  B Color
                  // 9:  Text
                  // 10: Bold
                  // 11: Italic
                  // 12: Underline
                  // 13: StrikeOut
                  // 14: Color Flag
                  // 15: FontName Flag
                  // 16: FontSize Flag
                  // 17: Angle Flag
                  // 18: Angle

                 _varexec:=Arrypar[4]
                 _arg2 := oWr:CheckAlign( arrypar )
                 // msgbox(ARRYPAR[4]+CRLF+valtype(_varexec),[LEN AP=]+zaps(len(arrypar)))
                 _arg3 := eval(chblk,arrypar,[FONT])
                 _arg4 := eval(chblk,arrypar,[SIZE])

                 _arg3 := if("->" $ _arg3 .or. [(] $ _arg3 ,&_arg3 ,_arg3 )
                 _arg4 := if("->" $ _arg4 .or. [(] $ _arg4 ,oWr:MACROCOMPILE( _arg4),val(_arg4) )
                 if "->" $ ArryPar[4] .or. [(] $ ArryPar[4]
                    ArryPar[4]:= trans(eval(epar,ArryPar[4]),"@A")
                 Endif
                 _arg5:= _arg4*25.4/100
/*
                 if arrypar[4]== "E"
                    msgbox(_arg5,"617")
                 Endif
*/
                 if ascan(arryPar,[TO]) > 1  //require multiline

                    _HMG_PRINTER_H_MULTILINE_PRINT( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
                    , if([LINE]$ Arrypar[1],&(Arrypar[1])-oWr:aStat[ 'Hbcompatible' ]-_arg5,eval(epar,ArryPar[1])-oWr:aStat[ 'Hbcompatible' ]-_arg5) ;
                    , eval(epar,ArryPar[2])  ;
                    , val(eval(chblk,arrypar,[TO])) ;
                    , val(eval(chblk2,arrypar,[TO])) ;
                    , _arg3 ;
                    , _arg4 ;
                    , Aclr[1] ;
                    , Aclr[2] ;
                    , Aclr[3] ;
                    , arrypar[4] ;
                    , if(ascan(arryPar,[BOLD])#0,.T.,.f.);
                    , if(ascan(arryPar,[ITALIC])#0,.t.,.f.) ;
                    , if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.);
                    , if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.);
                    , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                    , if(ascan(arryPar,[FONT])>0, .t.,.f.) ;
                    , if(ascan(arryPar,[SIZE])>0, .t.,.f.) ;
                    , _arg2 ;
                    )
                 else
                    _HMG_PRINTER_H_PRINT ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
                    , if([LINE]$ Arrypar[1],&(Arrypar[1])-oWr:aStat[ 'Hbcompatible' ]-_arg5,eval(epar,ArryPar[1])-oWr:aStat[ 'Hbcompatible' ]-_arg5) ;
                    , MAX(eval(epar,ArryPar[2]),oWr:Lmargin) ;
                    , _arg3 ;
                    , _arg4 ;
                    , Aclr[1] ;
                    , Aclr[2] ;
                    , Aclr[3] ;
                    , arrypar[4];
                    , if(ascan(arryPar,[BOLD])#0,.T.,.f.);
                    , if(ascan(arryPar,[ITALIC])#0,.t.,.f.) ;
                    , if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.);
                    , if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.);
                    , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                    , if(ascan(arryPar,[FONT])>0, .t.,.f.) ;
                    , if(ascan(arryPar,[SIZE])>0, .t.,.f.) ;
                    , _arg2 ;
                    , if(ascan(arryPar,[ANGLE])>0, .t.,.f.) ;
                    , val(eval(chblk,arrypar,[ANGLE])) )
                 Endif
              endcase

      case ascan(ArryPar,[BARCODE])=3
                 oWr:DrawBarcode(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]);
                          , VAL(eval(chblk,arrypar,[HEIGHT])) ;
                          , VAL(eval(chblk,arrypar,[WIDTH])) ;
                          , eval(chblk,arrypar,[TYPE])  ;
                          , if("->" $ ArryPar[4] .or. [(] $ ArryPar[4],oWr:MACROCOMPILE(ArryPar[4],.t.,cmdline,section),ArryPar[4]);
                          , oWr:UseFlags( upper(eval(chblk,arrypar,[FLAG]))) ;
                          ,(ascan(arryPar,[SUBTITLE])>0);
                          ,(ascan(arryPar,[INTERNAL])< 1) ;
                          , cmdline )

      case ascan(ArryPar,[MEMOSAY])=3
            oWr:mixmsay(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1]) ) ,MAX(eval(epar,ArryPar[2]),oWr:Lmargin) ,&(ArryPar[4]) ;
           ,if(ascan(arryPar,[LEN])>0,if(valtype(oWr:argm[3])=="A", ;
                                      oWr:MACROCOMPILE(eval(chblk,arrypar,[LEN]),.t.,cmdline,section) , ;
                                      val(eval(chblk,arrypar,[LEN]))),NIL) ;
           ,if(ascan(arryPar,[FONT])>0,eval(chblk,arrypar,[FONT]),NIL);
           ,if(ascan(arryPar,[SIZE])>0,val( eval(chblk,arrypar,[SIZE] ) ),NIL );
           ,if(ascan(arryPar,[BOLD])#0,.T.,.f.);
           ,if(ascan(arryPar,[ITALIC])#0,.t.,.f.) ;
           ,if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.);
           ,if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.);
           ,if(ascan(arryPar,[COLOR])>0,oWr:usacolor(eval(chblk,arrypar,[COLOR])),NIL);
           ,if(ascan(arryPar,[ALIGN])>0,oWr:what_ele(eval(chblk,arrypar,[ALIGN]),_aAlign,"_aAlign"),NIL);
           ,if(ascan(arryPar,[.F.])>0,".F.",""))


      case ascan(ArryPar,[PUTARRAY])=3
           if(ascan(arryPar,[FONT])>0,oWr:Astat['Fname']:= eval(chblk,arrypar,[FONT]),NIL)

           oWr:Astat['Fsize']   := if(ascan(arryPar,[SIZE])>0,val( eval(chblk,arrypar,[SIZE] ) ),oWr:Astat['Fsize'] )
           oWr:Astat['FBold']   := if(ascan(arryPar,[BOLD])#0,.T.,.f.)
           oWr:Astat['Fita']    := if(ascan(arryPar,[ITALIC])#0,.t.,.f.)
           oWr:Astat['Funder']  := if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.)
           oWr:Astat['Fstrike'] := if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.)
           oWr:Astat['Falign']  := oWr:CheckAlign( arrypar )
           oWr:Astat['Fangle']  := val(eval(chblk,arrypar,[ANGLE]))
           oWr:Astat['Fcolor']  := if(ascan(arryPar,[COLOR])> 0,oWr:UsaColor(eval(chblk,arrypar,[COLOR])),NIL)

           oWr:Putarray(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
              ,eval(epar,ArryPar[2]) ;
              ,oWr:MACROCOMPILE(ArryPar[4],.t.,cmdline,section)    ;            //arr
              ,if(ascan(arryPar,[LEN])>0,oWr:macrocompile(eval(chblk,arrypar,[LEN])),NIL) ; //awidths
              ,nil                                                           ;      //rowheight
              ,nil                                                           ;      //vertalign
              ,(ascan(arryPar,[NOFRAME])>0)                                  ;      //noframes
              ,nil                                                           ;      //abrushes
              ,nil                                                           ;      //apens
              ,if(ascan(arryPar,[FONT])>0,eval(chblk,arrypar,[FONT]),NIL)    ;      //afonts
              ,if(ascan(arryPar,[COLOR])> 0,oWr:UsaColor(eval(chblk,arrypar,[COLOR])),NIL);//afontscolor
              ,NIL                                                           ;      //abitmaps
              ,nil )                                                                //userfun
*/
     endcase
return .t.
*-----------------------------------------------------------------------------*
Static Function Mconvert(arg1)
*-----------------------------------------------------------------------------*
Local cal := {0,0}
DEFAULT arg1 to {0,0}

Cal[1] := arg1[1] * _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSX ( _HMG_SYSDATA [ 374 ] ) / 25.4
Cal[2] := arg1[2] * _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSY ( _HMG_SYSDATA [ 374 ] ) / 25.4

return Cal
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION hb_zebra_draw_wapi( hZebra, arg2, ... )
*-----------------------------------------------------------------------------*
local lru := {0,0}, Under := "A"
IF hb_zebra_GetError( hZebra ) != 0
   RETURN HB_ZEBRA_ERROR_INVALIDZEBRA
ENDIF
do case
   Case oWr:prndrv = "HBPR" // hbprinter
        hb_zebra_draw( hZebra, {| nc, nr, w, h |(lru[1] := nc ,Lru[2]:= NR ;
                             , hbprn:FillRect( nr,nC,nr+h,nc+w,arg2) ) }, ... )

   Case oWr:prndrv = "MINI" // miniprint
        hb_zebra_draw( hZebra, {| nc, nr, w, h |(lru[1] := nc ,Lru[2]:= NR ;
        ,_HMG_PRINTER_H_RECTANGLE ( arg2 , nr , nc , nr+h , nc+w , 1 , 0 , 0;
        , 0 , .f. , .f. , .t., .t. ) ) }, ... )

   Case oWr:PrnDrv = "PDF"  // PdfPrint
        hb_zebra_draw( hZebra, {| x, y, w, h |(lru[1] := x ,Lru[2]:= y ;
                            , HPDF_Page_Rectangle( arg2, x, y, w, h ) ) }, ... )
        HPDF_Page_Fill( arg2 )

Endcase

RETURN lru

/*
*/
#pragma BEGINDUMP

#define _WIN32_IE    0x0500

#include <mgdefs.h>
#include <windows.h>
#include "hbapi.h"

#ifdef __XHARBOUR__
   #undef HB_PARNI( n, x )
   #undef HB_PARNL( n, x )
   #define HB_PARNI( n, x )      hb_parni( n, x )
   #define HB_PARNL( n, x )      hb_parnl( n, x )
#endif

HB_FUNC( WRM_SETVIEWPORTORG )
{
  HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

  hb_retl( SetViewportOrgEx( hdcPrint , HB_PARNI( 2, 2 ), HB_PARNI( 2, 1 ), NULL ) );
}

HB_FUNC( H_FONT )
{
   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );
   int Fontsize ;
   int FontHeight;

   Fontsize = hb_parni( 2 ) ;

   FontHeight = -MulDiv( Fontsize, GetDeviceCaps( hdcPrint, LOGPIXELSY ), 72 ) ;

   hb_retnl( FontHeight );
}
#pragma ENDDUMP
