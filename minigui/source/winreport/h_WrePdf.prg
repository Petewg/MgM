#include 'minigui.ch'
#include "hbclass.ch"
#include "harupdf.ch"
#include "BosTaurus.CH"


#TRANSLATE MSG	=> MSGBOX
#TRANSLATE ZAPS(<X>) => ALLTRIM(STR(<X>))
#define NTRIM( n ) LTrim( Str( n ) )
#TRANSLATE Test( <c> ) => MsgInfo( <c>, [<c>] )
#define MsgInfo( c ) MsgInfo( c, , , .f. )
#define MsgAlert( c ) MsgEXCLAMATION( c, , , .f. )
#define MsgStop( c ) MsgStop( c, , , .f. )

#define MGSYS  .F.

memvar nomevar
memvar _money
memvar _separator
memvar _euro
memvar epar
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
memvar last_pag
memvar s_col, t_col,  wheregt
memvar gftotal, Gfexec, s_total
memvar nline
memvar nPag, nPgr, Tpg
memvar eLine, GFline
memvar maxrow, maxcol, mncl, mxH
memvar abort
memvar flob
memvar lstep, atf, mx_pg

memvar oWr
memvar _HMG_HPDFDATA

*-----------------------------------------------------------------------------*
* Printing Procedure                //La Procedura di Stampa
*-----------------------------------------------------------------------------*
Function PrPdfEsegui(_MainArea,_psd,db_arc,_prw)
*-----------------------------------------------------------------------------*
         Local oldrec   := recno()
         local landscape:=.f.
         local lpreview :=.f.
         local lselect  :=.f.
         local str1:=[]
         local ncpl, nfsize
         local condition:=[]
         local StrFlt:=""
         local lbody := 0, miocont := 0, miocnt := 0
         local Amx_pg :={}
         local cdrive := curdrive()
         Local rtv := .F.
         Private ONEATLEAST := .F., shd := .t., sbt := .t., sgh := .t., insgh:=.F.

         valtype(_psd)
         chblk  :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+1],''),'')}
         chblk2 :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+2],''),'')}
         chkArg :={|x|if(ascan(x,{|aVal,y| aVal[1]== y})> 0 ,x[ascan(x,{|aVal,y| aVal[1]==y})][2],'KKK')}

         if !empty(_MainArea)
             oWr:aStat [ 'area1' ]  :=substr(_MainArea,at('(',_MainArea)+1)
             oWr:aStat [ 'FldRel' ] :=substr(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])+2)
             oWr:aStat [ 'FldRel' ] :=substr(oWr:aStat [ 'FldRel' ],1,if(at(')',oWr:aStat [ 'FldRel' ])>0,at(')',oWr:aStat [ 'FldRel' ])-1,len(oWr:aStat [ 'FldRel' ]))) //+(at("->",oWr:aStat [ 'area1' ])))
             oWr:aStat [ 'area1' ]  :=left(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])-1)
         else
             oWr:aStat [ 'area1' ]:=dbf()
             oWr:aStat [ 'FldRel' ]:=''
         endif

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
         endif

         if "LAND" $ Str1 ;landscape:=.t.; endif
         if "SELE" $ Str1 ;lselect :=.t. ; endif
         if "PREV" $ Str1
            lpreview := .t.
         else
            lpreview := _prw
         endif

         str1 := upper(substr(oWr:ABody[1,1],at("/",oWr:aBody[1,1])+1))
         flob := val(str1)
         oWr:aStat [ 'Units' ]:= "MM"
         oWr:Lmargin := 0
         if lselect
            // msgstop(cFilePath(GetExeFileName())+"\")
             oWr:astat[ 'JobPath' ] := c_BrowseForFolder(NIL,[Indicare il percorso dove esportare:];
               ,BIF_EDITBOX + BIF_VALIDATE + BIF_NEWDIALOGSTYLE,CSIDL_DRIVES,oWr:astat[ 'JobPath' ])
            if right(oWr:astat[ 'JobPath' ],1)<> "\"
               oWr:astat[ 'JobPath' ] += "\"
            endif
            if oWr:astat[ 'JobPath' ] = "\"
               msgstop("Invalid file Path Error!")
               r_mem()
               RETURN rtv
            endif
            oWr:aStat [ 'JobName' ] =+ oWr:astat[ 'JobPath' ]+"PdfPrinter.pdf"
         Else
            oWr:aStat [ 'JobName' ] := "PdfPrinter.pdf"
         endif
         _HMG_HPDF_INIT ( "", , , , )

         aeval(oWr:adeclare,{|x,y|if(Y>1 ,oWr:traduci(x[1],,x[2]),'')})

         maxrow := _HMG_HPDF_Pixel2MM( _HMG_HPDFDATA[ 1 ][ 5 ] ) -4 //  are presumed to be about 4 mm, margin physical
         maxcol := _HMG_HPDF_Pixel2MM( _HMG_HPDFDATA[ 1 ][ 4 ] ) -4 //  are presumed to be about 4 mm, margin physical
   if used()
      if !empty(atf)
         set filter to &atf
      endif
      oWr:aStat[ 'end_pr' ] := oWr:quantirec( _mainarea )
   else
      oWr:aStat[ 'end_pr' ] := oWr:quantirec( _mainarea )
   endif

   if file(oWr:aStat [ 'JobName' ])
      Ferase(oWr:aStat [ 'JobName' ])
   Endif

   _hmg_hpdf_startdoc( oWr:aStat [ 'JobName' ] )

   oWr:COUNTSECT(.t.)

   do case
      case oWr:HB=0

      case empty(_MainArea)                // Mono Db List
          if lastrec() > 0 .or. valtype(oWr:argm[3]) == "A"
             Lbody := eval(oWr:Valore,oWr:aBody[1])
             mx_pg := INT(oWr:aStat[ 'end_pr' ]/NOZERODIV(Lbody) )
             if (mx_pg * lbody) # mx_pg
                 mx_pg ++
             endif
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
          endif
          Dbgotop()
          if lastrec()> 0
             lbody := eval(oWr:Valore,oWr:aBody[1])
             while !eof()
                   sele (DB_ARC)
                   StrFlt := oWr:aStat [ 'FldRel' ]+" = "+ oWr:aStat [ 'area1' ]+"->"+oWr:aStat [ 'FldRel' ]
                   DBEVAL( {|| miocont++},{|| &strFLT} )
                   miocnt := int(miocont/NOZERODIV(lbody))
                   if (miocnt * lbody) # miocont
                      miocnt ++
                   endif
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
                      oWr:aStat [ 'EndDoc' ]:=.f.
                      last_pag := .f.
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
   endif
   _hmg_hpdf_enddoc()

   if len(oWr:aStat [ 'ErrorLine' ]) > 0
      msgmulty(oWr:aStat [ 'ErrorLine' ],"Error summary report:")
   else
      if lpreview =.t. .and. file(oWr:astat[ 'JobPath' ]+oWr:aStat [ 'JobName' ])
         EXECUTE FILE oWr:astat[ 'JobPath' ]+oWr:aStat [ 'JobName' ]
/*
         IF ShellExecute(0, "OPEN", oWr:aStat [ 'JobName' ], oWr:astat[ 'JobPath' ], ,1) <=32
            MSGINFO("There is no program associated with PDF"+HB_OsNewLine()+HB_OsNewLine()+ ;
                   "File recorded in:"+HB_OsNewLine()+oWr:aStat [ 'JobPath' ])
         ENDIF
*/
      Endif
   Endif
   if used();dbgoto(oldrec);endif
   R_mem(.T.)
   RELEASE _HMG_HPDFDATA

Return !rtv
/*
*/
*-----------------------------------------------------------------------------*
Static Function pdfmemosay(arg1,arg2,argm1,argl1,argf1,argsize,abold,aita,aunder,astrike,argcolor1,argalign,onlyone)
*-----------------------------------------------------------------------------*
 local _Memo1:=argm1, k, mcl ,maxrow:=max(1,mlcount(_memo1,argl1))
 local arrymemo:={} , esci:=.f. ,str :="" , ain, typa := .f.
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
 if empty(onlyone)
          _HMG_HPDF_PRINT( ;
                          arg1+oWr:aStat[ 'Hbcompatible' ] ;
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
                        , if(valtype(argcolor1)=="A", .t.,.f.) ;
                        , if(valtype(argf1)=="C", .t.,.f.) ;
                        , if(valtype(argsize)=="N", .t.,.f.) ;
                        , argalign ;
                        , NIL ) // angle not used here!

   oWr:aStat [ 'Yes_Memo' ] :=.t.
 else
     for mcl=2 to len(arrymemo)
         nline ++
         if nline >= oWr:HB-1
            oWr:TheFeet()
            oWr:TheHead()
         endif

         _HMG_HPDF_PRINT ( ;
          (nline*lstep)+oWr:aStat[ 'Hbcompatible' ] , arg2, argf1 , argsize , argcolor1[1], argcolor1[2], argcolor1[3] ;
         , arrymemo[mcl], abold, aita, aunder, astrike;
         , if(valtype(argcolor1)=="A", .t.,.f.) ;
         , if(valtype(argf1)=="C", .t.,.f.) ;
         , if(valtype(argsize)=="N", .t.,.f.) ;
         , argalign,NIL )
     next
     if !Typa
        dbskip()
     Endif
 endif
 return nil
/*
*/
*-----------------------------------------------------------------------------*
Function RPdfPar(ArryPar,cmdline,section) // The core of Pff interpreter
*-----------------------------------------------------------------------------*
     local _arg1,_arg2, _arg3,_arg4, aX:={} , _varmem , Aclr , _varexec ,;
     blse := {|x| if(val(x)> 0,.t.,if(x=".T.".or. x ="ON",.T.,.F.))}, al, _align
     Local string1 := ''

     if len (ArryPar) < 1 ;return .F. ;endif
     do case
        case oWr:PrnDrv = "MINI"
             //msginfo(arrypar[1],"Rmini")
             RMiniPar(ArryPar,cmdline,section)

        case oWr:PrnDrv = "PDF"
        *m->MaxCol := hbprn:maxcol
        *m->MaxRow := hbprn:maxrow
        // m->maxcol := _HMG_HPDF_Pixel2MM( _HMG_HPDFDATA[ 1 ][ 4 ] ) -4 //  are presumed to be about 4 mm, margin physical
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
                /* Alternate method
                aX:={} ; aeval(ArryPar,{|x,y|if (Y >1,aadd(aX,x),Nil)})
                Hb_execFromarray("GROUP",ax)
                asize(ax,0)
                */
           case arryPar[1]==[ADDLINE]
                nline ++

           case arryPar[1]==[SUBLINE]
                nline --

           case len(ArryPar)=1

                if "DEBUG_" != left(ArryPar[1],6) .and. "ELSE" != left(ArryPar[1],4)
                   oWr:MACROCOMPILE(ArryPar[1],.t.,cmdline,section)
                Endif

           case ArryPar[1]+ArryPar[2]=[ENABLETHUMBNAILS]

           case ascan(arryPar,[PAGELINK]) > 0
                Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))

                if "->" $ ArryPar[4] .or. [(] $ ArryPar[4]
                   ArryPar[4]:= trans(eval(epar,ArryPar[4]),"@A")
                endif

                _arg1 := CheckFont( eval(chblk,arrypar,[FONT]) )
                _arg2 := oWr:CheckAlign( arrypar )
                _HMG_HPDF_SetPageLink( ;
                     if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                     , eval(epar,ArryPar[2])  ;
                     , arrypar[4] ;
                     , val(eval(chblk,arrypar,[TO])) ;
                     , _arg1 ;
                     , if(ascan(arryPar,[SIZE])#0,val(eval(chblk,arrypar,[SIZE])) ,_HMG_HPDFDATA[ 1 ][9]);
                     , Aclr[1] ;
                     , Aclr[2] ;
                     , Aclr[3] ;
                     , _arg2 ;
                     , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                     , if(ascan(arryPar,[FONT])>0, .t.,.f.) ;
                     , if(ascan(arryPar,[SIZE])>0, .t.,.f.) ;
                     , if(ascan(arryPar,[BORDER])#0,.t.,.f.);
                     , if(ascan(arryPar,[WIDTH])#0,.t.,.f.);
                     , if(ascan(arryPar,[WIDTH])# 0,VAL(eval(chblk,arrypar,[WIDTH])),NIL) )

           case ascan(arryPar,[URLLINK]) > 0
                Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
                if "->" $ ArryPar[4] .or. [(] $ ArryPar[4]
                   ArryPar[4]:= trans(eval(epar,ArryPar[4]),"@A")
                endif

                _arg1 := CheckFont( eval(chblk,arrypar,[FONT]) )
                _arg2 := oWr:CheckAlign( arrypar )

                _HMG_HPDF_SetURLLink( ;
                     if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                     , eval(epar,ArryPar[2])  ;
                     , arrypar[4] ;
                     , eval(chblk,arrypar,[TO]) ;
                     , _arg1 ;
                     , if(ascan(arryPar,[SIZE])#0,val(eval(chblk,arrypar,[SIZE])) ,_HMG_HPDFDATA[ 1 ][9]);
                     , Aclr[1] ;
                     , Aclr[2] ;
                     , Aclr[3] ;
                     , _arg2 ;
                     , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                     , if(ascan(arryPar,[FONT]) >0, .t.,.f.) ;
                     , if(ascan(arryPar,[SIZE]) >0, .t.,.f.) )

           case ascan(arryPar,[TOOLTIP]) > 0
                _HMG_HPDF_SetTextAnnot(  ;
                          if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                        , eval(epar,ArryPar[2]) ;
                        , eval(chblk,arrypar,[TOOLTIP]) ;
                        , eval(chblk,arrypar,[ICON]) )

           case ascan(arryPar,[SET])=1

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

                   case ascan(arryPar,[HRULER])= 2
                        oWr:astat ['HRuler'] := val(eval(chblk,arrypar,[HRULER]))

                   case ascan(arryPar,[HPDFDOC])= 2
                       do case
                           case ascan(arryPar,[COMPRESS]) > 0
                               _HMG_HPDF_SetCompression( eval(chblk,arrypar,[COMPRESS]) )

                           case ascan(arryPar,[PASSWORD]) > 0
                              _HMG_HPDF_SetPassword( eval(chblk,arrypar,[OWNER]), eval(chblk,arrypar,[USER] ) )

                           case ascan(arryPar,[PERMISSION]) > 0
                              _HMG_HPDF_SetPermission( eval(chblk,arrypar,[TO]) )

                           case ascan(arryPar,[PAGEMODE]) > 0
                              _HMG_HPDF_SetPageMode( eval(chblk,arrypar,[TO]) )

                           case ascan(arryPar,[PAGENUMBERING]) > 0

                              _HMG_HPDF_SetPageLabel( ;
                                   MAX(val(eval(chblk,arrypar,[FROM])),1) ; // <nPage>;
                                  ,eval(chblk,arrypar,[STYLE]) ;           // <"cStyle">;
                                  ,IF (ASCAN(ARRYPAR,[UPPER])>0,"UPPER","LOWER") ;// <"cCase">;
                                  ,eval(chblk,arrypar,[PREFIX]) )          // ;<cPrefix> )

                           case ascan(arryPar,[ENCODING]) > 0
                              _HMG_HPDF_SetEncoding( eval(chblk,arrypar,[TO]) )

                           case ascan(arryPar,[ROOTOUTLINE]) > 0
                              _HMG_HPDF_RootOutline( eval(chblk,arrypar,[TITLE]), eval(chblk,arrypar,[NAME]), eval(chblk,arrypar,[PARENT]) )

                           case ascan(arryPar,[PAGEOUTLINE]) > 0

                              _HMG_HPDF_PageOutline( eval(chblk,arrypar,[TITLE]), eval(chblk,arrypar,[NAME]), eval(chblk,arrypar,[PARENT]) )

                           case ascan(arryPar,[PDF/A]) > 0
                                // msgbox("Pdf/a","527Wrepdf")
                                // MSGBOX(HPDF_PDFA_SETPDFACONFORMANCE(_HMG_HPDFDATA[1][1], 1))

                        end case

                   case ascan(arryPar,[HPDFPAGE])= 2
                        do case

                           case ascan(arryPar,[LINESPACING]) > 0

                                _HMG_HPDF_SetLineSpacing( val(eval(chblk,arrypar,[TO])) )

                           case ascan(arryPar,[DASH]) > 0

                                _HMG_HPDF_SetDash( val(eval(chblk,arrypar,[TO])) )

                        Endcase

                   case ascan(arryPar,[HPDFINFO])= 2
                        _arg1 := eval(chblk,arrypar,[TO])
                        _arg2 := eval(chblk,arrypar,[TIME])
                        if ascan(arrypar,[DATE] ) > 0
                           if "DATE()" $ upper(_arg1)
                              _arg1 := date()
                           else
                              _arg1 := ctod(_arg1)
                           Endif
                        Endif
                        if ascan(arrypar,[TIME] ) > 0
                           if "TIME()" $ upper(_arg2)
                              _arg2 := time()
                           Endif
                        Endif
                        _HMG_HPDF_SetInfo( eval(chblk,arrypar,arrypar[2]),_arg1, _arg2 )

                   case ascan(arryPar,[COPIE])= 2

                   case ascan(arryPar,[HBPCOMPATIBLE])= 3
                        _ARG1:= VAL(eval(chblk,arrypar,[HBPCOMPATIBLE]))
                        IF _ARG1 # 0
                           oWr:aStat[ 'Hbcompatible' ] := _ARG1
                        Else
                           oWr:aStat[ 'Hbcompatible' ] := 3
                        Endif

                   case ascan(arryPar,[JOB])= 2
                        _arg3 := eval(chblk,arrypar,[NAME])
                        _arg3 := if("->" $ _arg3 .or. [(] $ _arg3 ,oWr:MACROCOMPILE( _arg3),_arg3 )
                        if ".pdf" $ _arg3
                           oWr:aStat [ 'JobName' ] := _arg3
                        Elseif empty(_arg3)
                           oWr:aStat [ 'JobName' ] := "PdfPrinter.pdf"
                        else
                           oWr:aStat [ 'JobName' ] := _arg3+".Pdf"
                        Endif
                        _HMG_HPDFDATA[1][2] := oWr:aStat [ 'JobPath' ] +oWr:aStat [ 'JobName' ]

                   case ascan(ArryPar,[PAGE])=2

                        _arg1:=eval(chblk,arrypar,[ORIENTATION])
                        _arg2:=eval(chblk,arrypar,[PAPERSIZE])
                        _arg3:=eval(chblk,arrypar,[FONT])

                   case ascan(arryPar,[ALIGN])=3

                        if val(Arrypar[4])> 0
                           _align := val(Arrypar[4])
                        else
                           _align := oWr:what_ele(eval(chblk,arrypar,[ALIGN]),oWr:aCh,"_aAlign")
                        endif

                   case ascan(arryPar,[PAPERSIZE])=2   //SET PAPERSIZE
                        _arg3:= oWr:what_ele(eval(chblk,arrypar,[PAPERSIZE]),oWr:aCh,"_apaper")
                        _HMG_HPDFDATA[ 1 ][ 3 ]:= _arg3
                        _HMG_HPDF_INIT_PAPERSIZE( _arg3 )
*/
                   case ascan(arryPar,[PAPERSIZE])=3   //SET PAPERSIZE
                        // SET USER PAPERSIZE WIDTH <width> HEIGHT <height> => //hbprn:setusermode(DMPAPER_USER,<width>,<height>)
                        _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( val(eval(chblk,arrypar,[WIDTH] )) )
                        _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( val(eval(chblk,arrypar,[HEIGHT])) )

                   case ascan(arryPar,[ORIENTATION])=2   //SET ORIENTATION
                        ax:= {_HMG_HPDFDATA[ 1 ][ 4 ] ,_HMG_HPDFDATA[ 1 ][ 5 ] }
                        if [LAND] $ eval(chblk,arrypar,[ORIENTATION])
                            _HMG_HPDFDATA[ 1 ][ 4 ] := ax[2]
                            _HMG_HPDFDATA[ 1 ][ 5 ] := ax[1]
                        else
                           _HMG_HPDFDATA[ 1 ][ 4 ]  := ax[1]
                           _HMG_HPDFDATA[ 1 ][ 5 ]  := ax[2]
                        endif

                   case ascan(arryPar,[UNITS])=2
                        do case
                           case arryPar[3]==[ROWCOL] .OR. LEN(ArryPar)==2
                                oWr:aStat [ 'Units' ]:= "RC"

                           case arryPar[3]==[MM]
                                oWr:aStat [ 'Units' ]:= "MM"

                           case arryPar[3]==[INCHES]
                                oWr:aStat [ 'Units' ]:= "IN"

                           case arryPar[3]==[PIXELS]
                                oWr:aStat [ 'Units' ]:= "PI"

                        endcase

                   case ascan(arryPar,[BKMODE])=2
                        if val(Arrypar[3])> 0
                        else
                        endif
*/
                   case ascan(ArryPar,[CHARSET])=2
                        /* Tentative for Miras! */
                        _hmg_hpdf_setencoding( "CP1250" )

                   case ascan(arryPar,[TEXTCOLOR])=2

                   case ascan(arryPar,[BACKCOLOR])=2

                   case ascan(arryPar,[ONEATLEAST])= 2
                        ONEATLEAST :=eval(blse,arrypar[3])

                   case ascan(arryPar,[THUMBNAILS])= 2

                   case ascan(arryPar,[EURO])=2
                        _euro:=eval(blse,arrypar[3])

                   case ascan(arryPar,[CLOSEPREVIEW])=2

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
                       Owr:aStat['GroupBold'] := (eval(blse,arrypar[3]))

                   case ascan(arryPar,[HGROUPCOLOR])=2
                       oWr:aStat['HGroupColor'] := oWr:UsaColor(eval(chblk,arrypar,[HGROUPCOLOR]))

                   case ascan(arryPar,[GTGROUPCOLOR])=2
                       oWr:aStat['GTGroupColor'] := oWr:UsaColor(eval(chblk,arrypar,[GTGROUPCOLOR]))

                   case ascan(arryPar,[MONEY])=2
                        _money:=eval(blse,arrypar[3])

                   case ascan(arryPar,[SEPARATOR])=2
                        _separator:=eval(blse,arrypar[3])

                   case ascan(arryPar,[JUSTIFICATION])=3

                   case ascan(arryPar,[MARGINS])=3
                        oWr:aStat['MarginTop'] := val(eval(chblk,arrypar,[TOP]))
                        oWr:aStat['MarginLeft'] := val(eval(chblk,arrypar,[LEFT]))

                   case (ascan(ArryPar,[POLYFILL])=2 .and. Arrypar[3]==[MODE])
                        if val(Arrypar[4])> 0
                        else
                        endif

                   case ascan(ArryPar,[POLYFILL])=2 .and. len(arrypar)=3

                   case ascan(ArryPar,[VIEWPORTORG])=2

                   case ascan(ArryPar,[TEXTCHAR])=2
                        HPDF_Page_SetCharSpace(_HMG_HPDFDATA[ 1 ][ 7 ] ,_HMG_HPDF_MM2Pixel(Val(eval(chblk,arrypar,[EXTRA]))) )

                   case ArryPar[2]= [COLORMODE] //=1

                   case ArryPar[2]= [QUALITY]   //=1

                endcase

           case ascan(arryPar,"GET")=1

                do case
                   case ascan(arryPar,[TEXTCOLOR])> 0
                        if len(ArryPar)> 3

                        else

                        endif

                   case ascan(arryPar,[BACKCOLOR])> 0
                        if len(ArryPar)> 3

                        else

                        endif

                   case ascan(arryPar,[BKMODE])> 0
                        if len(ArryPar)> 3

                        else

                        endif

                   case ascan(arryPar,[ALIGN])> 0
                        if len(ArryPar)> 4
                        else
                        endif

                   case ascan(arryPar,[EXTENT])> 0

                   case ArryPar[1]+ArryPar[2]+ArryPar[3]+ArryPar[4]=[GETPOLYFILLMODETO]

                   case ArryPar[2]+ArryPar[3]=[VIEWPORTORGTO]

                   case ascan(ArryPar,[TEXTCHAR])=2

                   case ascan(arryPar,[JUSTIFICATION])=3

                endcase

           case ascan(arryPar,[START])=1 .and. len(ArryPar)=2

                if ArryPar[2]=[DOC]
                   _hmg_hpdf_startdoc()
                elseif ArryPar[2]=[PAGE]
                   _hmg_hpdf_startpage()
                endif

           case ascan(arryPar,[END])=1 .and. len(ArryPar)=2

                if ArryPar[2]=[DOC]
                   _hmg_hpdf_enddoc()
                elseif ArryPar[2]=[PAGE]
                   _hmg_hpdf_endpage()
                endif

           case ascan(arryPar,[POLYGON])=1

           case ascan(arryPar,[DRAW])=5 .and. ascan(arryPar,[TEXT])=6
                // al := oWr:UsaFont(arrypar)
                Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
                        _arg3 := eval(chblk,arrypar,[FONT])
                        _arg4 := eval(chblk,arrypar,[SIZE])

                        _arg3 := if("->" $ _arg3 .or. [(] $ _arg3 ,&_arg3 ,_arg3 )
                        _arg4 := if("->" $ _arg4 .or. [(] $ _arg4 ,oWr:MACROCOMPILE( _arg4),val(_arg4) )

                        //_arg5 := 3 //_arg4 *2.54/7.2

                        _varexec := Arrypar[4]

                        if "->" $ ArryPar[4] .or. [(] $ ArryPar[4]
                           ArryPar[4]:= trans(eval(epar,ArryPar[4]),"@A")
                        Endif

                        if ValType (ArryPar[4]) == "N"
                           ArryPar[4] := AllTrim(Str(ArryPar[4]))
                        Elseif ValType (ArryPar[4]) == "D"
                           ArryPar[4] := dtoc (ArryPar[4])
                        Elseif ValType (ArryPar[4]) == "L"
                           ArryPar[4] := iif ( ArryPar[4] == .T. , M->_hmg_printer_usermessages [24] , M->_hmg_printer_usermessages [25] )
                        EndIf

                        _arg1 := CheckFont( _arg3 )

                        _arg2 := owr:what_ele(eval(chblk,arrypar,[STYLE]),owr:aCh,"_STYLE")
                        // msgbox(_arg2,"779")
//                         if val(eval(chblk,arrypar,[1]))+ val(eval(chblk2,arrypar,[TO]))> 0 ///require multiline
                /*
                aeval(arrypar,{|x,y|msginfo(x,zaps(y)) } )
                #xcommand @ <row>,<col>,<row2>,<col2> DRAW TEXT <txt> [STYLE <style>] [FONT <cfont>];
                => hbprn:drawtext(<row>,<col>,<row2>,<col2>,<txt>,<style>,<cfont>)

                //msgbox(zaps(::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_STYLE")),"GGGGG")
                al := ::UsaFont(arrypar)

                hbprn:drawtext(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]);
                ,eval(epar,ArryPar[3]),eval(epar,Arrypar[4]),eval(chblk,arrypar,[TEXT]);
                ,::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_STYLE"), "Fx" )

*/
                           _HMG_HPDF_MULTILINE_PRINT( ;
                               if([LINE]$ Arrypar[1],&(Arrypar[1])+oWr:aStat[ 'Hbcompatible' ],eval(epar,ArryPar[1])+oWr:aStat[ 'Hbcompatible' ]) ;
                               , eval(epar,ArryPar[2])  ;
                               , val(eval(chblk,arrypar,[TO])) ;
                               , val(eval(chblk2,arrypar,[TO])) ;
                               , _arg1 ;
                               , if(ascan(arryPar,[SIZE])#0,min(_arg4,300) ,_HMG_HPDFDATA[ 1 ][9]);
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
                               , if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL) ) // angolo

           case ascan(arryPar,[RECTANGLE])=5

                Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
               // msgmulty({val(eval(chblk,arrypar,[PENWIDTH])),val(eval(chblk,arrypar,[WIDTH]))} )
                _HMG_HPDF_RECTANGLE ( ;
                                 if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                                 , eval(epar,ArryPar[2]) ;
                                 , eval(epar,ArryPar[3]) ;
                                 , eval(epar,ArryPar[4]) ;
                                 , val(eval(chblk,arrypar,[PENWIDTH])) ;
                                 , Aclr[1] ;
                                 , Aclr[2] ;
                                 , Aclr[3] ;
                                 , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                                 , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                                 , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

           case ascan(ArryPar,[FRAMERECT])=5 .OR. ascan(ArryPar,[FOCUSRECT])=5

           case ascan(ArryPar,[FILLRECT])=5

           case ascan(ArryPar,[INVERTRECT])=5

           case ascan(ArryPar,[ELLIPSE])=5

           case ascan(arryPar,[RADIAL1])>0
                do case
                   case arrypar[5]=[ARC]

                   case arrypar[3]=[ARCTO]

                   case arrypar[5]=[CHORD]

                   case arrypar[5]=[PIE]

                endcase

           case ASCAN(ArryPar,[LINETO])=3

           case ascan(ArryPar,[LINE])=5

                     Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
                     _HMG_HPDF_LINE ( ;
                          if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                          , eval(epar,ArryPar[2]) ;
                          , if([LINE]$ Arrypar[3],&(Arrypar[3]),eval(epar,ArryPar[3])) ;
                          , eval(epar,ArryPar[4]) ;
                          , val(eval(chblk,arrypar,[PENWIDTH])) ;
                          , Aclr[1] ;
                          , Aclr[2] ;
                          , Aclr[3] ;
                          , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                          , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )

           case ascan(ArryPar,[PICTURE])=3

                        _WR_IMAGE_PDF ( eval(chblk,arrypar,[PICTURE]);
                        , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                        , eval(epar,ArryPar[2]) ;
                        , val(eval(chblk,arrypar,[SIZE]));
                        , val(eval(chblk2,arrypar,[SIZE]));
                        , if(ascan(ArryPar,[STRETCH])> 0,.t.,.f.))

           case ascan(ArryPar,[ROUNDRECT])=5

                _ARG1 := INT(MIN(eval(epar,ArryPar[4])-eval(epar,ArryPar[2]),eval(epar,ArryPar[3])-eval(epar,ArryPar[1]))/2)
                 Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
                _HMG_HPDF_ROUNDRECTANGLE ( ;
                          if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                          , eval(epar,ArryPar[2]) ;
                          , eval(epar,ArryPar[3]) ;
                          , eval(epar,ArryPar[4]) ;
                          , val(eval(chblk,arrypar,[PENWIDTH])) ;
                          , Aclr[1] ;
                          , Aclr[2] ;
                          , Aclr[3] ;
                          , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                          , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                          , if(ascan(arryPar,[FILLED])>0, .t.,.f.) ;
                          , MIN(VAL(eval(chblk2,arrypar,[ROUNDR])),_ARG1) )  // CURVE value is aprox 1/3 ROUNDR
/*
           case ascan(ArryPar,[TEXTOUT])=3000

                al := oWr:UsaFont(arrypar)

                if ascan(ArryPar,[FONT])=5
                   if "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
                      __elex:=ArryPar[4]
                      //hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),&(__elex),"FX")
                   else
                      //hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),ArryPar[4],"Fx")
                   endif
                elseif LEN(ArryPar)=4
                   if "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
                      __elex:=ArryPar[4]
                      //hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),&(__elex))
                   else
                      //hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),ArryPar[4])
                   endif
                ENDIF
*/
           case ascan(ArryPar,[PRINT])= 3 .OR. ascan(ArryPar,[SAY])= 3 .OR. ascan(ArryPar,[TEXTOUT])= 3
                Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
                do case

                   case ASCAN(ArryPar,[IMAGE]) > 0

                        _WR_IMAGE_PDF ( eval(chblk,arrypar,[IMAGE]);
                        , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                        , eval(epar,ArryPar[2]) ;
                        , val(eval(chblk,arrypar,[HEIGHT]));
                        , val(eval(chblk,arrypar,[WIDTH]));
                        , if(ascan(ArryPar,[STRETCH])> 0,.t.,.f.))

                   case ASCAN(ArryPar,[LINE]) > 0

                     _HMG_HPDF_LINE ( ;
                          if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                          , eval(epar,ArryPar[2]) ;
                          , if([LINE]$ Arrypar[6],&(Arrypar[6]),eval(epar,ArryPar[6])) ;
                          , eval(epar,ArryPar[7]) ;
                          , val(eval(chblk,arrypar,[PENWIDTH])) ;
                          , Aclr[1] ;
                          , Aclr[2] ;
                          , Aclr[3] ;
                          , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                          , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )

                   case ASCAN(ArryPar,[RECTANGLE]) > 0

                   IF ASCAN(ArryPar,[ROUNDED]) > 0
                            _HMG_HPDF_ROUNDRECTANGLE ( ;
                                 if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                                 , eval(epar,ArryPar[2]) ;
                                 , eval(epar,ArryPar[6]) ;
                                 , eval(epar,ArryPar[7]) ;
                                 , val(eval(chblk,arrypar,[PENWIDTH])) ;
                                 , Aclr[1] ;
                                 , Aclr[2] ;
                                 , Aclr[3] ;
                                 , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                                 , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                                 , if(ascan(arryPar,[FILLED])>0, .t.,.f.) ;
                                 , VAL(eval(chblk,arrypar,[CURVE])) )
                     Else
                            _HMG_HPDF_RECTANGLE ( ;
                                 if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                                 , eval(epar,ArryPar[2]) ;
                                 , eval(epar,ArryPar[6]) ;
                                 , eval(epar,ArryPar[7]) ;
                                 , val(eval(chblk,arrypar,[PENWIDTH])) ;
                                 , Aclr[1] ;
                                 , Aclr[2] ;
                                 , Aclr[3] ;
                                 , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                                 , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                                 , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

                      Endif

                   case ASCAN(ArryPar,[CIRCLE]) > 0

                            _HMG_HPDF_CIRCLE ( ;
                                 if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                                 , eval(epar,ArryPar[2]) ;
                                 , val(eval(chblk,arrypar,[RADIUS])) ;
                                 , val(eval(chblk,arrypar,[PENWIDTH])) ;
                                 , Aclr[1] ;
                                 , Aclr[2] ;
                                 , Aclr[3] ;
                                 , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                                 , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                                 , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

                   case len(arrypar) > 4 .and. ArryPar[4]+ArryPar[5]=[CURVEFROM]

                            _HMG_HPDF_CURVE ( ;
                                 if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                                 , eval(epar,ArryPar[2]) ;
                                 , val(eval(chblk,arrypar,[FROM])) ;
                                 , val(eval(chblk2,arrypar,[FROM])) ;
                                 , val(eval(chblk,arrypar,[TO])) ;
                                 , val(eval(chblk2,arrypar,[TO])) ;
                                 , val(eval(chblk,arrypar,[PENWIDTH])) ;
                                 , Aclr[1] ;
                                 , Aclr[2] ;
                                 , Aclr[3] ;
                                 , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                                 , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )

                   case ASCAN(ArryPar,[ARC]) > 0

                            _HMG_HPDF_ARC ( ;
                                 if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                                 , eval(epar,ArryPar[2]) ;
                                 , val(eval(chblk2,arrypar,[ARC])) ;
                                 , val(eval(chblk2,arrypar,[ANGLE])) ;
                                 , val(eval(chblk,arrypar,[TO])) ;
                                 , val(eval(chblk,arrypar,[PENWIDTH])) ;
                                 , Aclr[1] ;
                                 , Aclr[2] ;
                                 , Aclr[3] ;
                                 , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                                 , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                                 , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

                   case ASCAN(ArryPar,[ELLIPSE]) > 0

                            _HMG_HPDF_ELLIPSE ( ;
                                 if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                                 , eval(epar,ArryPar[2]) ;
                                 , val(eval(chblk2,arrypar,[HORIZONTAL])) ;
                                 , val(eval(chblk2,arrypar,[VERTICAL])) ;
                                 , val(eval(chblk,arrypar,[PENWIDTH])) ;
                                 , Aclr[1] ;
                                 , Aclr[2] ;
                                 , Aclr[3] ;
                                 , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                                 , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                                 , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

                   Otherwise

                        _arg3 := eval(chblk,arrypar,[FONT])
                        _arg4 := eval(chblk,arrypar,[SIZE])

                        _arg3 := if("->" $ _arg3 .or. [(] $ _arg3 ,&_arg3 ,_arg3 )
                        _arg4 := if("->" $ _arg4 .or. [(] $ _arg4 ,oWr:MACROCOMPILE( _arg4),val(_arg4) )

                        //_arg5 := 3 //_arg4 *2.54/7.2

                        _varexec := Arrypar[4]

                        if "->" $ ArryPar[4] .or. [(] $ ArryPar[4]
                           ArryPar[4]:= trans(eval(epar,ArryPar[4]),"@A")
                        Endif

                        if ValType (ArryPar[4]) == "N"
                           ArryPar[4] := AllTrim(Str(ArryPar[4]))
                        Elseif ValType (ArryPar[4]) == "D"
                           ArryPar[4] := dtoc (ArryPar[4])
                        Elseif ValType (ArryPar[4]) == "L"
                           ArryPar[4] := iif ( ArryPar[4] == .T. , M->_hmg_printer_usermessages [24] , M->_hmg_printer_usermessages [25] )
                        EndIf

                        _arg1 := CheckFont( _arg3 )

                        _arg2 := oWr:CheckAlign( arrypar )

                        if ascan(arryPar,[TO]) > 4 .and. val(eval(chblk,arrypar,[TO]))+ val(eval(chblk2,arrypar,[TO]))> 0 ///require multiline

                           _HMG_HPDF_MULTILINE_PRINT( ;
                               if([LINE]$ Arrypar[1],&(Arrypar[1])+oWr:aStat[ 'Hbcompatible' ],eval(epar,ArryPar[1])+oWr:aStat[ 'Hbcompatible' ]) ;
                               , eval(epar,ArryPar[2])  ;
                               , val(eval(chblk,arrypar,[TO])) ;
                               , val(eval(chblk2,arrypar,[TO])) ;
                               , _arg1 ;
                               , if(ascan(arryPar,[SIZE])#0,min(_arg4,300) ,_HMG_HPDFDATA[ 1 ][9]);
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
                               , if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL) ) // angolo

                        Else

                           _HMG_HPDF_PRINT( ;
                               if([LINE]$ Arrypar[1],&(Arrypar[1])+oWr:aStat[ 'Hbcompatible' ],eval(epar,ArryPar[1])+oWr:aStat[ 'Hbcompatible' ]) ;  // row
                               , eval(epar,ArryPar[2])  ;                                                // col
                               , _arg1 ;
                               , if(ascan(arryPar,[SIZE])#0,min(_arg4,300) ,_HMG_HPDFDATA[ 1 ][9]);
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
                               , if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL) ) // angolo
                        Endif

           Endcase

           case ascan(ArryPar,[MEMOSAY])=3

                _arg1 := CheckFont( eval(chblk,arrypar,[FONT]) )
                _arg2 := oWr:CheckAlign( arrypar )

                pdfmemosay(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1]) ) ,eval(epar,ArryPar[2]) ,&(ArryPar[4]) ;
                          ,if(ascan(arryPar,[LEN])>0,if(valtype(oWr:argm[3])=="A", ;
                              oWr:MACROCOMPILE(eval(chblk,arrypar,[LEN]),.t.,cmdline,section) , ;
                              val(eval(chblk,arrypar,[LEN]))),NIL) ;
                          ,_arg1 ;//if(ascan(arryPar,[FONT])>0,eval(chblk,arrypar,[FONT]),NIL);
                          ,if(ascan(arryPar,[SIZE])>0,val( eval(chblk,arrypar,[SIZE] ) ),NIL );
                          ,if(ascan(arryPar,[BOLD])#0,.T.,.f.);
                          ,if(ascan(arryPar,[ITALIC])#0,.t.,.f.) ;
                          ,if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.);
                          ,if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.);
                          ,if(ascan(arryPar,[COLOR])>0,oWr:usacolor(eval(chblk,arrypar,[COLOR])),NIL);
                          ,_arg2 ;//,if(ascan(arryPar,[ALIGN])>0,oWr:what_ele(eval(chblk,arrypar,[ALIGN]),_aAlign,"_aAlign"),NIL);
                          ,if(ascan(arryPar,[.F.])>0,".F.",""))

          case ascan(ArryPar,[PUTARRAY])=3

               al := CheckFont( eval(chblk,arrypar,[FONT]) )

               if(ascan(arryPar,[FONT])>0,oWr:Astat['Fname']:= al,NIL)
               oWr:Astat['Fsize']   := if(ascan(arryPar,[SIZE])>0,val( eval(chblk,arrypar,[SIZE] ) ),oWr:Astat['Fsize'] )
               oWr:Astat['FBold']   := if(ascan(arryPar,[BOLD])#0,.T.,.f.)
               oWr:Astat['Fita']    := if(ascan(arryPar,[ITALIC])#0,.t.,.f.)
               oWr:Astat['Funder']  := if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.)
               oWr:Astat['Fstrike'] := if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.)
               oWr:Astat['Falign']  := oWr:CheckAlign( arrypar )
               oWr:Astat['Fangle']  := val(eval(chblk,arrypar,[ANGLE]))
               oWr:Astat['Fcolor']  := if(ascan(arryPar,[COLOR])> 0,oWr:UsaColor(eval(chblk,arrypar,[COLOR])),NIL)
               */
               oWr:Putarray(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                   ,eval(epar,ArryPar[2]) ;
                   ,oWr:MACROCOMPILE(ArryPar[4],.t.,cmdline,section)    ;            //arr
                   ,if(ascan(arryPar,[LEN])>0,oWr:macrocompile(eval(chblk,arrypar,[LEN])),NIL) ; //awidths
                   ,nil                                                           ;      //rowheight
                   ,nil                                                           ;      //vertalign
                   ,(ascan(arryPar,[NOFRAME])>0)                                  ;      //noframes
                   ,nil                                                           ;      //abrushes
                   ,nil                                                           ;      //apens
                   ,if(ascan(arryPar,[FONT])>0,NIL,NIL)                           ;      //afonts
                   ,if(ascan(arryPar,[COLOR])> 0,oWr:UsaColor(eval(chblk,arrypar,[COLOR])),NIL);//afontscolor
                   ,NIL                                                           ;      //abitmaps
                   ,nil )                                                                //userfun

          case ascan(ArryPar,[BARCODE])=3
               oWr:DrawBarcode(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]);
                         , VAL(eval(chblk,arrypar,[HEIGHT]));
                         , VAL(eval(chblk,arrypar,[WIDTH])) ;
                         , eval(chblk,arrypar,[TYPE])  ;
                         , if("->" $ ArryPar[4] .or. [(] $ ArryPar[4],oWr:MACROCOMPILE(ArryPar[4],.t.,cmdline,section),ArryPar[4]);
                         , oWr:UseFlags( upper(eval(chblk,arrypar,[FLAG]))) ;
                         ,(ascan(arryPar,[SUBTITLE])> 0)  ;
                         ,(ascan(arryPar,[INTERNAL])< 1) ;
                         , cmdline )

          case ascan(ArryPar,[NEWPAGE])=1 .or. ascan(ArryPar,[EJECT])=1

               _hmg_hpdf_EndPage()
               _hmg_hpdf_StartPage()
        endcase
     endcase
return .t.
/*
*/
*-----------------------------------------------------------------------------*
Function CheckFont( cFontName)  //returns the name and path
*-----------------------------------------------------------------------------*
   LOCAL nPos := 0 , cFont := ''
   LOCAL aHpdf_Font := {'Courier',;
                   'Courier-Bold',;
                   'Courier-Oblique',;
                   'Courier-BoldOblique',;
                   'Helvetica',;
                   'Helvetica-Bold',;
                   'Helvetica-Oblique',;
                   'Helvetica-BoldOblique',;
                   'Times-Roman',;
                   'Times-Bold',;
                   'Times-Italic',;
                   'Times-BoldItalic',;
                   'Symbol',;
                   'ZapfDingbats'}
   aeval( aHpdf_Font,{|x,y| if(upper(x)==cFontname,npos:= y,NIL )})
   IF npos > 0
      cFont := aHpdf_Font[nPos]
   Else
      if ".TTF" $ upper(cFontname)
         if file(oWr:astat[ 'JobPath' ]+cFontname)
            cFont:= oWr:astat[ 'JobPath' ]+cFontname
         Else
            cfontname:=cFilenopath(cfontname)
            if file(oWr:astat[ 'JobPath' ]+cFontname)
               cfont:= oWr:astat[ 'JobPath' ]+cFontname
            Elseif file(GetWindowsFolder ( )+"\Fonts\"+cfontname)
                cfont := GetWindowsFolder ( )+"\Fonts\"+cfontname
            Endif
         Endif
      Else
        if "COURIER NEW" $ cfontname
           cfontname := "COUR"
        Endif
        if file(GetWindowsFolder ( )+"\Fonts\"+cfontname+".TTF")
           cfont := GetWindowsFolder ( )+"\Fonts\"+cfontname+".TTF"
        Endif
      Endif
   Endif
return cFont
/*
*/
*-----------------------------------------------------------------------------*
Function _HMG_HPDF_SetFont( cFontName, lBold, lItalic )
*-----------------------------------------------------------------------------*
   LOCAL nPos := 0 , cFont := '', jld :=''
   LOCAL aHpdf_Font := {'Courier',;
                   'Courier-Bold',;
                   'Courier-Oblique',;
                   'Courier-BoldOblique',;
                   'Helvetica',;
                   'Helvetica-Bold',;
                   'Helvetica-Oblique',;
                   'Helvetica-BoldOblique',;
                   'Times-Roman',;
                   'Times-Bold',;
                   'Times-Italic',;
                   'Times-BoldItalic',;
                   'Symbol',;
                   'ZapfDingbats'}
   Default lBold := .f., lItalic := .f.

   IF len( alltrim( cFontName ) ) == 0
      cFont := _HMG_HPDFDATA[ 1 ][ 8 ]
      IF lBold .and. lItalic
         cFont += '-BoldOblique'
      ELSEIF lBold
         cFont += '-Bold'
      ELSEIF lItalic
         cFont += '-Oblique'
      ENDIF
   ELSEIF (nPos := AScan(aHpdf_Font, {|cFont| At(cFontName, cFont) > 0 })) > 0
      cFont := aHpdf_Font[nPos]
      IF (nPos := At('-',cFont)) > 0 .and. At('-',cFontName) == 0
         cfont := SubStr(cFont, 1, nPos-1)
      ENDIF
      IF SubStr(cFont, 1, 5) == 'Times'
         IF lBold .and. lItalic
            cFont += '-BoldItalic'
         ELSEIF lBold
            cFont += '-Bold'
         ELSEIF lItalic
            cFont += '-Italic'
         ELSE
            IF At('-',cFontName) != 0
               cFont := cFontName
            ELSE
               cFont := 'Times-Roman'
            ENDIF
         ENDIF
      ELSEIF alltrim( cFontName ) == "Symbol" .or. alltrim( cFontName ) == "ZapfDingbats"

      ELSE
         IF lBold .and. lItalic
            cFont += '-BoldOblique'
         ELSEIF lBold
            cFont += '-Bold'
         ELSEIF lItalic
            cFont += '-Oblique'
         ELSE
            IF At('-',cFontName) != 0
               cFont := cFontName
            ENDIF
         ENDIF
      ENDIF
   ELSEIF upper( substr( cFontName, len( cFontName ) - 3 ) ) == '.TTF' // load ttf font
      cFont := substr( cFontName, 1, len( cFontName ) - 4 )
      IF lBold .and. lItalic
         cFontName := cFont + 'bi.ttf'
      ELSEIF lBold
         cFontName := cFont + 'bd.ttf'
      ELSEIF lItalic
         cFontName := cFont + 'i.ttf'
      ENDIF
      * controlla se il font è già stato creato
      * check if the font has already been created
      aeval(oWR:astat[ 'PdfFont' ],{|x| if(x[1]==UPPER(cFontname),jld:=x[2],'')})
      if empty(jld)  // a new font is required
         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, .t. )
         * memorizzare il nome del font caricato
         * store the name of the loaded font
         aadd(oWR:astat[ 'PdfFont' ], {UPPER(cFontname),cfont} )
      else
         cFont := jld
      Endif
      IF len( alltrim( cFont ) ) == 0
         Return ''
      ENDIF
   ELSE
      cFont := cFontName
   ENDIF
Return cFont
/*
*/
*-----------------------------------------------------------------------------*
function _WR_IMAGE_PDF ( cImage, nRow, nCol, nImageheight, nImageWidth, lStretch )
*-----------------------------------------------------------------------------*
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local oImage ,cExt
   Local nh := nil
   Local Savefile := GetTempFolder()
   default lStretch := .f.
   cImage:= upper(cImage)

   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   if file( cImage )
      hb_FNameSplit( cImage, , , @cExt )
      cExt := upper(cExt)
      do case
         case cExt == ".PNG"
              oImage := HPDF_LoadPngImageFromFile2( _HMG_HPDFDATA[ 1 ][ 1 ], cImage )
         case cExt == ".JPG"
              oImage := HPDF_LoadJPEGImageFromFile( _HMG_HPDFDATA[ 1 ][ 1 ], cImage )

      OTHERWISE

         Savefile += "\_"+cfilenoext(cimage)+"_.Png"

         if !file(Savefile)
            nh := BT_BitmapLoadFile (cimage)
            BT_BitmapSaveFile (nh, Savefile, BT_FILEFORMAT_PNG )
            BT_BitmapRelease (nh)
         Endif
         oImage := HPDF_LoadPngImageFromFile( _HMG_HPDFDATA[ 1 ][ 1 ], Savefile )
         ferase(Savefile)

      EndCase

   else
      _HMG_HPDF_Error( 7 )
      return nil
   endif
   if empty( oImage )
      _HMG_HPDF_Error( 7 )
      return nil
   endif
   if lstretch
      nImageHeight := _HMG_HPDF_Pixel2MM( nypos )
      nImageWidth  := _HMG_HPDF_Pixel2MM( nWidth - nxpos )
   Endif
   HPDF_Page_DrawImage( _HMG_HPDFDATA[ 1 ][ 7 ], oImage, nxPos, nyPos - _HMG_HPDF_MM2Pixel( nImageHeight ), _HMG_HPDF_MM2Pixel( nImageWidth ), _HMG_HPDF_MM2Pixel( nImageHeight ) )
return nil

