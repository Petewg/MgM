/*----------------------------------------------------------------------------

  Program: Minilabel Demo v1.0 
  Author:  Pierpaolo Martinello 
  
  This Software Run on HMG [ MiniGui 2.0.20 (2006.06.27) ]
  and Minigui 1.2 Extended (Build 22) 2006.09.20 without any change.

---------------------------------------------------------------------------*/

#include 'minigui.ch' 
#include "miniprint.ch"
#include "fileio.ch"

#translate MSG	=>	MSGBOX
#define COMPILE(cExpr)     &("{||" + cExpr + "}")
#define TRANSARRY(cExpr)   &("{" + cExpr + "}")

memvar P_report, P_Label, Prev_report, Prev_Label, att, linestep, c_rec, nPag, last_pag, eLine
memvar _BC, cIniFile, Stampanti, end_pr
memvar endof_file

*-----------------------------------------------------------------------------*
Procedure main()
*-----------------------------------------------------------------------------*
local cExeFile := GetExeFileName()

	SET MULTIPLE OFF WARNING

	SET DATE BRITISH
	SET CENTURY ON

	SELE 1
	USE TEST
	INDEX ON field->first TO lista

       public _BC := ( "BORLAND" $ upper( HB_COMPILER() ) ), ;
		cIniFile := cFilePath( cExeFile ) + "\" + lower( cFileNoExt( cExeFile ) ) + ".ini", ;
		Stampanti := aPrinters()

       asort(Stampanti)

       m->P_report := m->P_Label := GetDefaultPrinter()
       m->Prev_report := .T.
       m->Prev_Label  := .F. 
       
       Getparam(cInifile)
       
	DEFINE WINDOW PR_FORM ;
		AT 100,100 ;
		WIDTH 630;
		HEIGHT 150 ;
		TITLE 'Minilabel Tests [Miniprint + '+ MiniguiVersion()+']' ;
		ICON 'AASIC';
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON RELEASE ( dbclosearea(), ferase("lista.ntx") )
                                                                                          
		DEFINE MAIN MENU
			POPUP 'File'
				ITEM 'MiniLabel Test 1' ACTION Print_eti()
				SEPARATOR
				ITEM 'SetPrinter' ACTION Set_Printer()
				SEPARATOR
				ITEM 'Exit' ACTION ThisWindow.Release
			END POPUP
		END MENU
                                                                                          
	END WINDOW
                                                                                          
	ACTIVATE WINDOW PR_FORM
Return                                                                                    

*-----------------------------------------------------------------------------*
Function Print_eti()
*-----------------------------------------------------------------------------*
     Local ncopie, scelta
     sele 1
     dbgotop()
     scelta:=popex("*.FLD","Print Template")
     if !empty(scelta)
        scelta := substr(scelta,AT("-",scelta)+1)+".FLD"
     else
        msgstop([Abandoned from user!])            
        return nil
     endif  
     ncopie := 1
     ncopie := MyIn( 'Print on: '+m->P_Report , [Copies] , 1 , {'999'})
     if ncopie [1] == Nil .or. ncopie[1] = 0
        msgstop([Abandoned from user!])            
        return nil
     else
        ncopie:=ncopie[1] 
     endif
     PrintEti(scelta,ncopie)                      // Stampa diretta 
     set filter to 
return nil  

*------------------------------------------------*
Procedure PrintEti(modulo,ncopie)
*------------------------------------------------*
        Local oldrec   := recno()
        local landscape:=.f. 
        local lpreview :=.f.
        local lselect  :=.f.
        local errore   :=.f.
        local str1:=[]
        local condition:=[]
        local mx_pg := 0
        local Abody := 1
        local db_arc := alias()
        local c_pag := 0
        local useprint := m->P_Label
        Local MainSetup := {}
        Local Pos_Setup := 0
        Local ReportName := Left(modulo,rat(".",modulo)-1)
 
        default modulo to "MINILABEL"
        default ncopie to 1
        Private att:={}
        linestep := 4.33
        c_rec := 0

        nPag      := 0
        last_pag  :=.f.
        eLine     := 0
        
        if used()
           DBSetOrder(1)
           DBGoTop()
           end_pr=quantirec_o() 
        else
           end_pr=1
        endif    

        mx_pg:=ROUND(((end_pr/ABody)+.5),0)
        
	if "MINILABEL" $ upper(modulo)
           useprint := m->P_Label
           str1 := "PORT"+if(m->Prev_label,"/PREV","")
        else  
           useprint := m->P_Report
           Str1 := if (pos_setup > 0,upper(left(MainSetup[Pos_Setup,2],4)),"PORT")+ if(m->Prev_report,"/PREV","") 
        endif

           set order to 
           set delete off
           dbgotop()
           att := Rd_Fld(modulo)
           MainSetup := settore(att,0)
           Pos_Setup := ascan(Mainsetup,{|x| upper(x[1]) == "ORIENTATION" })
           Pos_Setup := ascan(Mainsetup,{|x| upper(x[1]) == "BODYLEN" })
           abody := max(1,if (pos_setup > 0,val(MainSetup[Pos_Setup,2]),1))
           Pos_Setup := ascan(Mainsetup,{|x| upper(x[1]) == "PRINTERNAME" })
           useprint := if (pos_setup > 0,MainSetup[Pos_Setup,2],useprint)
           Pos_Setup := ascan(Mainsetup,{|x| upper(x[1]) == "REPORTNAME" })
           ReportName := if (pos_setup > 0,MainSetup[Pos_Setup,2],ReportName)

           if abody = 1
              if "LAND" $ Str1 
                 Abody := 40
              else
                 Abody := 60
              endif   
           Endif
           
           if len(att) < 1
              errore:=.t.
           endif   

        if .not. errore
           if "LAND" $ Str1 ;landscape:=.t.; endif   	
           if "PREV" $ Str1 ;lpreview:=.t. ; endif   
           if "SELE" $ Str1 ;lselect :=.t. ; endif   
           
           if lselect .and. lpreview 
              SELECT PRINTER DIALOG PREVIEW
           endif
           if lselect .and. .not. lpreview
              SELECT PRINTER DIALOG
           endif
           if .not. lselect .and. lpreview
              if ascan(Stampanti,useprint) > 0
                 SELECT PRINTER useprint ORIENTATION if(Landscape,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT) COPIES ncopie PREVIEW 
              else    
                 SELECT PRINTER DEFAULT ORIENTATION if(Landscape,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT) COPIES ncopie PREVIEW
              endif   
           endif
           if .not. lselect .and. .not. lpreview
              if ascan(Stampanti,useprint) > 0
                 SELECT PRINTER useprint ORIENTATION if(Landscape,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT) COPIES ncopie
              else    
                 SELECT PRINTER DEFAULT ORIENTATION if(Landscape,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT) COPIES ncopie
              endif   
           endif
            
           START PRINTDOC NAME reportname
           do while !(db_arc)->(Eof())
              if npag = 0  .or. c_pag > 0
                 START PRINTPAGE
                 npag ++
                 c_pag := 0
                 EtiHead(modulo) //Page Header
              endif 
              c_rec := 0  
              do while c_rec < Abody .and. !eof()
                 Etibody(modulo)
                 c_rec ++ 
                 dbskip(1)
              enddo
                
              if eof()    // Document Footer
                 last_pag := .t.
                 c_rec ++ 
              else
                  c_pag := 1 
              endif   
              EtiFeet(modulo)   // Page footer         	  
              END PRINTPAGE
           enddo	  
           END PRINTDOC
           SELECT PRINTER stampanti[ascan(Stampanti,useprint)] ;
           ORIENTATION PRINTER_ORIENT_PORTRAIT
           if used();dbgoto(oldrec);endif
        else
           msgExclamation("I have not found the report necessary "+CRLF+;
                        "In order to create them confirmation printing in the SetPrinter section")
        endif
        release att,linestep,c_rec,nPag,last_pag,eLine

Return

*------------------------------------------------*
Procedure EtiHead(Modulo)
*------------------------------------------------*
local _aPrint:=settore(att,1)
default modulo to "MINILABEL"
   exePrint(_aPrint)
return

*------------------------------------------------*
Procedure EtiBody(Modulo)
*------------------------------------------------*
local _aPrint := settore(att,2)
default modulo to "MINILABEL"
   exePrint(_aPrint)
return 

*------------------------------------------------*
Procedure EtiFeet(Modulo)
*------------------------------------------------*
local _aPrint:=settore(att,if(last_pag,4,3))
default modulo to "MINILABEL"
   exePrint(_aPrint)
return

*-----------------------------------------------------------------------------*
Function Osts(arg1)
*-----------------------------------------------------------------------------*
local lr:=if(val(arg1)> 0,.t.,if(arg1=".T.".or.arg1="ON",.t.,.f.))
return lr

*-----------------------------------------------------------------------------*
Function Rd_Fld(Filename)
*-----------------------------------------------------------------------------*
local linea,handle,cnt:=0,szn:='',ar:={}
private endof_file:=.F.

   *- open the file, check for errors
   handle = FOPEN(filename,64)
   IF Ferror() <> 0 
      if "" # filename
         msg("Errore in apertura del file: "+filename)
      endif   
      return {}
   Endif
   *- not at the end of file
   do while !endof_file
      Linea := fgetline(handle)
      cnt++
      if upper(left(linea,2)) == '[S'
         szn := Linea
      else   
         if cnt > 2 .and. ! empty(Linea) 
            if left(linea,1) <> "#"
                aadd (ar,{szn,TRANSARRY(Linea)})
            endif    
         endif   
      endif
   Enddo
   FCLOSE(HANDLE)
return ar

*-----------------------------------------------------------------------------*
Function Settore (arry, arg1, nElement)
*-----------------------------------------------------------------------------*
local settore:="{|e|e[1]=='[S"
default nElement to 2
      settore += zaps(arg1)+"]'}" 
return aextract(arry, &settore, nElement)

*-----------------------------------------------------------------------------*
Function Zaps(nValue)
*-----------------------------------------------------------------------------*
default nValue to 0
return ALLTRIM(STR(nValue))

*-----------------------------------------------------------------------------*
Function aextract(aArray, bCondition, nElement)
*-----------------------------------------------------------------------------*
local aReturn := {}
local i
for i = 1 to len(aArray)
    if eval(bCondition,aArray[i],i)
       if nElement # nil
          aadd(aReturn,aArray[i,nElement])
       else
          aadd(aReturn,aArray[i])
       endif
    endif
next
return aReturn

*-----------------------------------------------------------------------------*
Procedure ExePrint(_aprint)
*-----------------------------------------------------------------------------*
 Local _arrycolor,vcolor,lv

     for lv := 1 to len(_aprint) 
     
         do case
            case upper(_aprint[lv,3]) == 'PRINT LINE TO'
                 _arrycolor:= chkColor(_aprint[lv,7])
                 _HMG_PRINTER_H_LINE ( if(_BC,_hmg_printer_hdc,_HMG_SYSDATA [ 374 ]) ;
                     , eval(COMPILE(_aprint[lv,1])) ;
                     , eval(COMPILE(_aprint[lv,2])) ; 
                     , eval(COMPILE(_aprint[lv,4])) ;
                     , eval(COMPILE(_aprint[lv,5])) ; 
                     , eval(COMPILE(_aprint[lv,6])) ; 
	              , _arrycolor[1] ;
	              , _arrycolor[2] ;
	              , _arrycolor[3] ;
                     , osts(_aprint[lv,6]) ;
                     , if(_arrycolor[1]+_arrycolor[2]+_arrycolor[3] > 0, .t.,.f.) )
         
            case upper(_aprint[lv,3]) == 'PRINT RECTANGLE TO'
                 _arrycolor:= chkColor(_aprint[lv,7])
                 if osts(_aprint[lv,8])
                    _HMG_PRINTER_H_ROUNDRECTANGLE( if(_BC,_hmg_printer_hdc,_HMG_SYSDATA [ 374 ]) ;
                        , eval(COMPILE(_aprint[lv,1])) ;
                        , eval(COMPILE(_aprint[lv,2])) ; 
                        , eval(COMPILE(_aprint[lv,4])) ;
                        , eval(COMPILE(_aprint[lv,5])) ; 
                        , eval(COMPILE(_aprint[lv,6])) ; 
	                 , _arrycolor[1] ;
	                 , _arrycolor[2] ;
	                 , _arrycolor[3] ;
                        , osts(_aprint[lv,6]) ;
                        , if(_arrycolor[1]+_arrycolor[2]+_arrycolor[3] > 0, .t.,.f.) )
                 else
                    _HMG_PRINTER_H_RECTANGLE( if(_BC,_hmg_printer_hdc,_HMG_SYSDATA [ 374 ]) ;
                        , eval(COMPILE(_aprint[lv,1])) ;
                        , eval(COMPILE(_aprint[lv,2])) ; 
                        , eval(COMPILE(_aprint[lv,4])) ;
                        , eval(COMPILE(_aprint[lv,5])) ; 
                        , eval(COMPILE(_aprint[lv,6])) ; 
	                 , _arrycolor[1] ;
	                 , _arrycolor[2] ;
	                 , _arrycolor[3] ;
                        , osts(_aprint[lv,6]) ;
                        , if(_arrycolor[1]+_arrycolor[2]+_arrycolor[3] > 0, .t.,.f.) )
                  Endif   

            case upper(_aprint[lv,3]) == 'PRINT IMAGE'
                 _HMG_PRINTER_H_IMAGE( if(_BC,_hmg_printer_hdc,_HMG_SYSDATA [ 374 ]) ;
                     , _aprint[lv,4] ;
                     , eval(COMPILE(_aprint[lv,1])) ; 
                     , eval(COMPILE(_aprint[lv,2])) ; 
                     , eval(COMPILE(_aprint[lv,6])) ;
                     , eval(COMPILE(_aprint[lv,5])) ; 
                     , osts(_aprint[lv,7]))

         Otherwise
                  _arrycolor:= chkColor(_aprint[lv,10])
                 _HMG_PRINTER_H_PRINT ( if(_BC,_hmg_printer_hdc,_HMG_SYSDATA [ 374 ]) ;
                     , eval(COMPILE(_aprint[lv,1]));
                     , eval(COMPILE(_aprint[lv,2])) ; 
                     , _aprint[lv,4] ;
                     , eval(COMPILE(_aprint[lv,5])) ; 
                     , _arrycolor[1] ;
                     , _arrycolor[2] ;
                     , _arrycolor[3] ;
                     , eval(COMPILE(_aprint[lv,3])) ; 
                     , osts(_aprint[lv,6]);
                     , osts(_aprint[lv,7]);
                     , osts(_aprint[lv,8]);
                     , osts(_aprint[lv,9]);
                     , if(_arrycolor[1]+_arrycolor[2]+_arrycolor[3]>0, .t.,.f.) ;
                     , if(_aprint[lv,4] # '', .t.,.f.) ;
                     , if(eval(COMPILE(_aprint[lv,5]))>0, .t.,.f.) ;
                     , _aprint[lv,11] )
                 
         endcase
     next 
return

*-----------------------------------------------------------------------------*
Function chkcolor(arg1)
*-----------------------------------------------------------------------------*
local r, v
if !empty(arg1) 
   if '('  $ arg1
      v := eval(COMPILE(arg1))
      r := color(v) 
   else
      r :=color(arg1) 
   endif   
else
   r :=color(arg1) 
endif
return r

*-----------------------------------------------------------------------------*
Function Popex(skeleton,title,onlyarr)
*-----------------------------------------------------------------------------*
local Rt := '',matches,selection,skelpath,skepick,popdir
memvar pop_dir
default skeleton to ''
default title to "You choose:"
default onlyarr to .F.
IF EMPTY(skeleton)                                                                    
  Rt := ''                                                                         
ELSE                                                                                     
  * if a path was specified, save it for return                                          
  skelpath = stripskel(skeleton)                                                      
  IF Adir(skeleton) > 0                                                               
    *-create an array to match the filespec                                              
    DECLARE pop_dir[ADIR(skeleton)]                                                   
    Adir(skeleton,pop_dir)                                                            
    Asort(pop_dir)                                                                    
    aeval(pop_dir,{|nome,x|pop_dir[x]:=PROPER(LOWER(NOME))})                             
    aeval(pop_dir,{|nome,x|pop_dir[x]:=ltrim(str(x))+[)-]+substr(nome,1,at(".",nome)-1)})
                                                                                         
    *- do the achoice to get the selection                                               
    if onlyarr
       aeval(pop_dir,{|nome,x|pop_dir[x]:=substr(nome,at(")-",nome)+2)})
       Rt:=m->pop_dir
    else   
       selection := mchoice(pop_dir,,,,,Title)   
       Rt := IIF(selection > 0, skelpath+pop_dir[selection], '')              
    endif
  ELSE                                                                                   
    Rt = ''                                                                       
  ENDIF                                                                                  
ENDIF           
release pop_dir
*- return the selection                                                                  
RETURN Rt 

*-----------------------------------------------------------------------------*
Function stripskel(filespec)                                                                       
*-----------------------------------------------------------------------------*
local lenspec,i,outspec,nextletr                                                       
outspec := ""                                                                             
lenspec := len(filespec)                                                               
for i = lenspec  to 1 step -1                                                     
     nextletr = subst(filespec,i,1)                                                
     if nextletr $ "/\:"                                                                
        outspec := left(filespec,i)                                                  
        exit                                                                              
     endif                                                                               
next                                                                                     
return outspec                                                                        

*-----------------------------------------------------------------------------*
Function TRUESVAL(string)
*-----------------------------------------------------------------------------*
Local lenx := LEN(string),I,outval := '',letter
for i = 1 TO lenx
  letter = SUBST(string,i,1)
  IF !(letter $ "-0123456789.")
    outval = outval+letter
  ENDIF
NEXT
RETURN outval

*-----------------------------------------------------------------------------*
Procedure Set_Printer()
*-----------------------------------------------------------------------------*
     Load Window Setprinter
     Activate Window Setprinter
return

*-----------------------------------------------------------------------------*
Procedure ReadPr()
*-----------------------------------------------------------------------------*
     Getparam(cInifile)
     Setprinter.combo_1.value:= ascan(Stampanti,m->P_report)
     Setprinter.combo_2.value:= ascan(Stampanti,m->P_Label)
     Setprinter.Check_1.value:= m->Prev_Report
     Setprinter.Check_2.value:= m->Prev_Label
return

*-----------------------------------------------------------------------------*
Procedure SetPr()
*-----------------------------------------------------------------------------*
     m->Prev_Report:= Setprinter.Check_1.value
     m->Prev_Label := Setprinter.Check_2.value
     m->P_report := Stampanti[Setprinter.combo_1.value]
     m->P_Label  := Stampanti[Setprinter.combo_2.value]
     Saveparam(cInifile,.t.)
     SetPrinter.release
return

*-----------------------------------------------------------------------------*
Procedure GetParam(cIniFile)
*-----------------------------------------------------------------------------*
        m->P_report    := Getini( "Printers","P_report",m->P_report, cIniFile )        	    	    	    
        m->P_label     := Getini( "Printers","P_Label",m->P_label, cIniFile )
        m->Prev_report := if( "F" $ upper(Getini( "Printers","Prev_report",".T.", cIniFile )),.f.,.t.)
        m->Prev_label  := if( "F" $ upper(Getini( "Printers","Prev_Label",".F.", cIniFile )),.f.,.t.)
return

*-----------------------------------------------------------------------------*
Procedure SaveParam(cIniFile, lForce)
*-----------------------------------------------------------------------------*
       local wrtext:={}, cur_path := GetStartupFolder() + "\"
       default lForce to .f.
       
       if !file(cur_path+"\Report1.Fld")
          aadd(wrtext,'#[Legenda]  Riga  col   expr    Font   Sz  Bld  It  Und  Strk  Color  Align')
          aadd(wrtext,'#             1    2     3       4     5    6    7    8   9     10    11  ')
          aadd(wrtext,'#')
          aadd(wrtext,"#[Legenda]  Row   Col   PRINT   ToRow  ToCol  Width  Color  [Rounded]")
          aadd(wrtext,"#            1     2     3        4      5      6      7       8  ")
          aadd(wrtext,"[S0]")
          aadd(wrtext,"'ReportName','Print Queue - MiniLabel Demo'")
          aadd(wrtext,"'Orientation','PORTRAIT'")
          aadd(wrtext,"#'BodyLen','40'")
          aadd(wrtext,"#'Printername','EPSON Stylus C80 Series'")
          aadd(wrtext,"")
          aadd(wrtext,"[S1]")
          aadd(wrtext,"'6','8','PRINT IMAGE','rosa.jpg','10','10','1'")
          aadd(wrtext,"'6','190','PRINT IMAGE','rosa.jpg','10','10','1'")
          aadd(wrtext,"'12',' 20',' date()','TIMES NEW ROMAN','10','1','','','','','LEFT' ")
          aadd(wrtext,"' 7',' 95','[Head 1] ','Arial','12','1','','','','',''")
          aadd(wrtext,"'12',' 85','[Test header number 2]','COURIER NEW','12','','','','','',''")
          aadd(wrtext,"'16.5','200','[Pag.]+ trans(m->npag,[999])','TIMES NEW ROMAN','11','1','','','','','RIGHT'")
          aadd(wrtext,"'40','140','PRINT RECTANGLE TO','80','190','1.5','255,0,255','1'")
          aadd(wrtext,"'16.5','8','PRINT LINE TO','16.5','200','0.1',''")
          aadd(wrtext,"'21.5','8','PRINT LINE TO','21.5','200','0.1',''")
          aadd(wrtext,"'45','145','PRINT RECTANGLE TO','75','185','0.5','BLUE',''")
          aadd(wrtext,"'60','150','PRINT LINE TO','60','151','1.5','RED'")
          aadd(wrtext,"'61','150','PRINT LINE TO','61','151','1.5','RED'")
          aadd(wrtext,"'62','150','PRINT LINE TO','62','151','1.5','RED'")
          aadd(wrtext,"'60','155','PRINT LINE TO','60','156','1.5','GREEN'")
          aadd(wrtext,"'61','155','PRINT LINE TO','61','156','1.5','GREEN'")
          aadd(wrtext,"'62','155','PRINT LINE TO','62','156','1.5','GREEN'")
          aadd(wrtext,"'55','162','[ITALIAN]','COURIER NEW','10','1','','','','RED',''")
          aadd(wrtext,"'59','162','[MINIPRINT]','COURIER NEW','10','1','','','','',''")
          aadd(wrtext,"'63','162','[DEMO]','COURIER NEW','10','1','','','','GREEN',''")
          aadd(wrtext,"'160','60','PRINT IMAGE','rosa.jpg','15','15','1'")
          aadd(wrtext,"'16.5',' 10','[ Put here as you want!]','COURIER NEW','12','','','','','',''")
          aadd(wrtext,"")
          aadd(wrtext,"[S2]")
          aadd(wrtext,"'22+(c_rec * linestep)',' 15','Field->Code    ','ARIAL','8','','','','','if(recno()<=10,[255,0,0],[BLUE])','RIGHT'")
          aadd(wrtext,['22+(c_rec * linestep)',' 21','if(Field->Married,"Married","No Married")','TIMES NEW ROMAN','8','','','','','',''])
          aadd(wrtext,"'22+(c_rec * linestep)',' 36','Field->First','ARIAL','8','','','','','',''")
          aadd(wrtext,"'22+(c_rec * linestep)',' 79','Field->Last','ARIAL','8','','','','','',''")
          aadd(wrtext,"'22+(c_rec * linestep)','119','Field->BIRTH ','ARIAL','8','','','','','',''")
          aadd(wrtext,'') 
          aadd(wrtext,'[S3]')
          aadd(wrtext,"'22+(c_rec * linestep)','8','PRINT LINE TO','22+(c_rec * linestep)','200','0.1',''")
          aadd(wrtext,['22+(c_rec * linestep)','200','"Continue to pag. "+zaps(m->npag+1)','TIMES NEW ROMAN','11','1','','','','','RIGHT'])
          aadd(wrtext,"") 
          aadd(wrtext,"[S4]")
          aadd(wrtext,['18+(c_rec * linestep)','8','PRINT LINE TO','18+(c_rec * linestep)','200','0.1',''])
          aadd(wrtext,['22+(c_rec * linestep)','200','"End Report "','Arial','8','','','','','','RIGHT'])
          aadd(wrtext,"")
          aadd(wrtext,"[STOP]")
          WriteFile(cur_path+"\Report1.Fld",wrtext) 
       endif                                      

       if lForce .or. !FILE(cIniFile)
          writeini( "Printers","P_report",m->P_report, cIniFile )        	    	    	    
          writeini( "Printers","Prev_report",if(m->Prev_report,".T.",".F."), cIniFile )        	    	    	    
          writeini( "Printers","P_Label",m->P_label, cIniFile )        	    	    	    
          writeini( "Printers","Prev_Label",if(m->Prev_Label,".T.",".F."), cIniFile )  
          writeini( "FORMATI", "ETI_C1","[10+(c_rec*linestep)],'3','Field->Descrizio','Arial','11'", cIniFile ) 
       endif
return 

*-----------------------------------------------------------------------------*
Function WriteFile(filename,arrayname)
*-----------------------------------------------------------------------------*
Local f_handle,kounter 

* open file and position pointer at the end of file
IF VALTYPE("filename")="C"
  f_handle = FOPEN(filename,2)
  *- if not joy opening file, create one
  IF Ferror() <> 0
    f_handle := Fcreate(filename,0)
  ENDIF
  FSEEK(f_handle,0,2)
ELSE
  f_handle := filename
  FSEEK(f_handle,0,2)
ENDIF

IF VALTYPE(arrayname) == "A"
  * if its an array, do a loop to write it out
  FOR kounter = 1 TO len(arrayname)
    *- append a CR/LF
    FWRITE(f_handle,arrayname[kounter]+CRLF )
  NEXT
ELSE
  * must be a character string - just write it
  FWRITE(f_handle,arrayname+CRLF )
ENDIF (VALTYPE(arrayname) == "A")

* close the file
IF VALTYPE("filename")="C"
  Fclose(f_handle)
ENDIF
RETURN .T.

*-----------------------------------------------------------------------------*
Procedure ESCAPE_ON(ARG1)
*-----------------------------------------------------------------------------*
     local WinName:=if(arg1==NIL,Procname(1),arg1)
     if upper(WinName)<>'OFF' 
        _definehotkey(arg1,0,27,{||_releasewindow(arg1)})
     else
        ON KEY ESCAPE ACTION nil         
     endif   
return  

*-----------------------------------------------------------------------------*
Function Color(GR,GR1,GR2)
*-----------------------------------------------------------------------------*
         LOCAL DATO:={0,0,0}
         if PCOUNT()=1 .and. VALTYPE("GR")=="C"
            do case
               case upper(GR)=[YELLOW]
                    DATO:={255,255,0}
            
               case upper(GR)=[PINK]
                    DATO:={255,128,192}
            
               case upper(GR)=[RED]
                    DATO:={255,0,0}
            
               case upper(GR)=[FUCHSIA]
                    DATO:={255,0,255}
            
               case upper(GR)=[BROWN]
                    DATO:={128,64,64}
            
               case upper(GR)=[ORANGE]
                    DATO:={255,128,64}
            
               case upper(GR)=[GREEN]
                    DATO:={0,255,0}
            
               case upper(GR)=[PURPLE]
                    DATO:={128,0,128}
            
               case upper(GR)=[BLACK]
                    DATO:={0,0,0}
            
               case upper(GR)=[WHITE]
                    DATO:={255,255,255}
            
               case upper(GR)=[GRAY]
                    DATO:={128,128,128}
            
               case upper(GR)=[BLUE]
                    DATO:={0,0,255}
            
               case "," $ GR
                    tokeninit(GR,",")   
                    DATO:={VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR))}
            endcase
         elseif PCOUNT()=1 .and. VALTYPE(GR)=="A"
               DATO:= GR
         elseif PCOUNT()=3
            DATO:={GR,GR1,GR2}
         endif   
return DATO

*-----------------------------------------------------------------------------*
Function PROPER(interm)
*-----------------------------------------------------------------------------*
local c_1, outstring:='', capnxt:=''

do while chr(32) $ interm 
   c_1:=substr(interm,1,at(chr(32),interm)-1)
   capnxt+=upper(left(c_1,1))+right(c_1,len(c_1)-1)+" "
   interm:=substr(interm,len(c_1)+2,len(interm)-len(c_1))
enddo

RETURN capnxt+upper(left(interm,1))+right(interm,len(interm)-1)

*-----------------------------------------------------------------------------*
Function GetIni( cSection, cEntry, cDefault, cFileIni )
*-----------------------------------------------------------------------------*
RETURN GetPrivateProfileString(cSection, cEntry, cDefault, cFileIni )

*-----------------------------------------------------------------------------*
Function WriteIni( cSection, cEntry, cValue, cFileIni )
*-----------------------------------------------------------------------------*
RETURN WritePrivateProfileString( cSection, cEntry, cValue, cFileIni )

*-----------------------------------------------------------------------------*
Function fgetline(handle)
*-----------------------------------------------------------------------------*
Local return_line,chunk,bigchunk,oldoffset,at_chr13

        return_line = ''
        bigchunk = ''
        oldoffset = FSEEK(handle,0,1)
        DO WHILE .T.
        
          *- read in a chunk of the file
          chunk = ''
          chunk = Freadstr(handle,100)
        
          *- if we didn't read anything in, guess we're at the EOF
          IF LEN(chunk)=0
             endof_file = .T.
             
             IF !EMPTY(bigchunk)
               return_line = bigchunk
             ENDIF
             EXIT
          elseif len(bigchunk) > 1024
             EXIT
          ENDIF
        
          *- add this chunk to the big chunk
          bigchunk += chunk
        
          *- if we've got a CR , we've read in a line
          *- otherwise we'll loop again and read in another chunk
          IF AT(CHR(13),bigchunk) > 0
             at_chr13 =AT(CHR(13),bigchunk)
             
             *- go back to beginning of line
             FSEEK(handle,oldoffset)
             
             *- read in from here to next CR (-1)
             return_line = Freadstr(handle,at_chr13-1)
             
             *- move the pointer 1 byte
             FSEEK(handle,1,1)
             
             EXIT
          ENDIF
        ENDDO
        
        *- move the pointer 1 byte
        *- this should put us at the beginning of the next line
        FSEEK(handle,1,1)
        
*- return the contents of the line
RETURN return_line

*-----------------------------------------------------------------------------*
func quantirec_o(Warea,_nrec)            //count record that will be print
*-----------------------------------------------------------------------------*
local conta:=0,query_exp
_nrec:=iif(_nrec==NIL,0,_nrec) 
if !EMPTY(query_exp:=dbfilter())
   DBGOTOP()
   count to conta FOR &query_exp
   DBGOTOP()                     
ELSE
   If _NREC < 1
      conta:= reccount()
   Else
      conta:= _NREC
   EndIF
endif
return CONTA

*-----------------------------------------------------------------------------*
Function MyIn(Title,arg1,argd)
*-----------------------------------------------------------------------------*
     local out:={nil}
     default title to ''
     default arg1 to ''
     default argd to 1
     load window getnum
     center window getnum
     getnum.title:=title
     getnum.label_1.value := arg1
     getnum.Spinner_1.value := argd
     activate window getnum
return out

*-----------------------------------------------------------------------------*
Procedure Ld_base(arg1)         
*-----------------------------------------------------------------------------*
     ON KEY ESCAPE OF &arg1 ACTION ThisWindow.Release
     ON KEY RETURN OF &arg1 ACTION Add_ok(arg1)
return

*-----------------------------------------------------------------------------*
Procedure Add_ok(arg1)          
*-----------------------------------------------------------------------------*
     _pushkey( VK_TAB )
     RELEASE KEY RETURN OF &arg1 
     _pushkey( VK_SPACE )
return


#include "s_mchoice.prg"
