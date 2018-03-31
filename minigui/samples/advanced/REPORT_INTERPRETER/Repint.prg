/*******************************************************************************
   Filename		: Repint.prg

   Created			: 17 November 2011 (12:00:20)
   Created by		: Pierpaolo Martinello

   Last Updated	: 22 May 2015
   Updated by		: Pierpaolo

   Comments		:
*******************************************************************************/
#ifndef __CALLDLL__
#define __CALLDLL__
#endif
#include 'minigui.ch'
#include 'winprint.ch'
#include "hbdyn.ch"

#define FR_PRIVATE     0x10
#define FR_NOT_ENUM    0x20

REQUEST __objSetClass

memvar aPrinters, aports
memvar tagged, asay, oWr, _HMG_MINIPRINT
memvar valore, AHEAD, ABody, lstep, nline
/*
*/
*-----------------------------------------------------------------------------*
procedure main()
*-----------------------------------------------------------------------------*
private aPrinters, aports

   AddFont()

   INIT PRINTSYS
   GET PRINTERS TO aprinters
   GET PORTS TO aports
   RELEASE PRINTSYS

   DEFINE WINDOW F1 ;
           AT 10,10 ;
           WIDTH 545 HEIGHT 300 ;
           TITLE 'Report Interpreter Demo' ;
           ICON 'PRINT' ;
           MAIN ;
           FONT 'Arial' SIZE 10 ;
           ON RELEASE RemoveFont()

           ON KEY ESCAPE ACTION exit()

           DEFINE STATUSBAR
                   STATUSITEM '[x] Harbour Power Ready!'
           END STATUSBAR

           @5 ,5   BUTTON Button_1 CAPTION '&Two Db'  ACTION  {||print(1),f1.button_1.setfocus} Tooltip "See Bolla.mod" default
           @5 ,110 BUTTON Button_2 CAPTION '&Fantasy' ACTION  {||print(2),f1.button_2.setfocus} Tooltip "See ReportF.mod"
           @5 ,215 BUTTON Button_3 CAPTION '&Group' ACTION  {||print(3),f1.button_3.setfocus} Tooltip "See ReportG.mod"
           @5 ,320 BUTTON Button_4 CAPTION '&Simple (mm)' ACTION  {||print(4),f1.button_4.setfocus} Tooltip "See ReportS.mod"
           @5 ,425 BUTTON Button_5 CAPTION '&Miniprint (mm)' ACTION  {||print(5),f1.button_5.setfocus} Tooltip "See ReportM.mod"
           @50,5   BUTTON Button_6 CAPTION '&2PageS/Recno' ACTION  {||print(6),f1.button_6.setfocus} Tooltip "See ReportD.mod"
           @50,110 BUTTON Button_7 CAPTION '&Labels' ACTION  {||print(7),f1.button_7.setfocus} Tooltip "See ReportL.mod"
           @50,215 BUTTON Button_8 CAPTION '&Array' ACTION  {||print(9),f1.button_8.setfocus} Tooltip "See ReportA.mod"
           @50,320 BUTTON Button_9 CAPTION '&Pdf (mm)' ACTION  {||print(8),f1.button_9.setfocus} Tooltip "See ReportP.mod"
           @50,425 BUTTON Button_10 CAPTION '&Unified' ACTION {||print(10),f1.button_10.setfocus} Tooltip [See Unified.mod "One script 3 drivers"]

           @100,10  LISTBOX L1 WIDTH 250 HEIGHT 100 ITEMS aprinters
           @100,270 LISTBOX L2 WIDTH 250 HEIGHT 100 ITEMS aports

           @210,160 LABEL LB1 VALUE "Available Printers and Ports" autosize
           @210,425 BUTTON Button_11 CAPTION '&QUIT' ACTION {|| exit()}

   END WINDOW

   CENTER WINDOW F1

   ACTIVATE WINDOW F1

return
/*
*/
*-----------------------------------------------------------------------------*
function print(arg1)
*-----------------------------------------------------------------------------*
local atag := {2,3,4}, afld:= {"First","Last","Birth" }, afldn:={"Simple","Apellido","Nato"}
local choice := 0, aDrv:={[HBPRINTER],[MINIPRINT],[PDFPRINT]}

private tagged, asay :={}
if arg1=1
   SELE 1
   use CLIENTI ALIAS CLIENTI
   index on Field->CLIENTE to CLIENTI

   SELE 2
   USE PRGB2003 ALIAS PROGRB
   index on Field->N_DOC to NPROG
   set filter to Field->n_doc < 3

   SELE 3
   USE bdyb2003 ALIAS BOLLE
   index on Field->N_DOC to NBOLLE
   choice := Scegli({"Use Hbprinter","use Miniprint","Use PdfPrint"},"Driver choice"," Unified Commands Demo",1)

   if choice = 0
      return nil
   Endif

   WinREPINT("Bolla.mod","Bolle",NIL,"PROGRB->n_doc",,,aDRV[choice])

else
   use test shared
   // make an array
   DBEval( {|| aadd(asay,{fieldget(1),hb_valtostr(fieldget(2)),fieldget(4),fieldget(7)})},,,,, .F. )

   index on Field->first to lista

   dbgotop()
   do case
      case arg1 = 2

           WinREPINT("ReportF.mod","TEST",,,,,aDRV[1])

      case arg1 = 3
           WinREPINT("ReportG.mod","TEST",)

      case arg1 = 4
           tagged := tagit(atag,aFld ,afldN ,"Make your choice!",,,580,580 )
           if len(tagged) > 0
              set filter to ascan(tagged,recno()) > 0
              WinREPINT("ReportS.mod","TEST")
              set filter to
           Else
               msgExclamation("No choice from user !!!","Print Aborted.")
           Endif

      case arg1 = 5
           WinREPINT("ReportM.mod","TEST",)

      case arg1 = 6
           tagged := {33,34,35,36,37,38,39,40,41,42}
           set filter to ascan(tagged,recno()) > 0
           WinREPINT("ReportD.mod","TEST",)
           set filter to

      case arg1 = 7
           choice := Scegli({"Use Hbprinter","use Miniprint","Use PdfPrint"},"Driver choice"," WinReport Demo",1)

           if choice = 0
              return nil
           Endif
           WinREPINT("ReportL.mod","TEST",nil,nil,,,aDRV[choice])

      case arg1 = 8
           choice := Scegli({"As Miniprint","Generic features (unusual use!)"},"Example choice"," WinReport Pdf Demo",1)

           switch choice
           case 0
                exit
           case 1
                WinREPINT("ReportP.mod","TEST",)
                exit
           case 2
                WinREPINT("ReportPG.mod","TEST",)
           end switch

      case arg1 = 9
           dbclosearea()
           WinREPINT("ReportA.mod",asay)

      case arg1 = 10
           choice := Scegli({"Use Hbprinter","use Miniprint","Use PdfPrint"},"Driver choice"," Unified Commands Demo",1)

           if choice = 0
              return nil
           Endif

           WinREPINT("Unified.mod","TEST",,,,,aDRV[choice])

   endcase
endif
release tagged
return Nil

*-----------------------------------------------------------------------------*
function Page2(row,col,argm1,argl1,argcolor1)
*-----------------------------------------------------------------------------*
 local _Memo1:=argm1, mrow := mlcount(_memo1,argl1), arrymemo:={}
 Local units := hbprn:UNITS, k, mcl , argcolor
 default col to 0, row to nline, argl1 to 10
 argcolor := oWr:UsaColor(argcolor1)
 for k := 1 to mrow
     aadd(arrymemo,oWr:justificalinea(memoline(_memo1,argl1,k),argl1))
 next
 oWr:TheFeet()
 if oWr:prndrv = "MINI"
    oWr:TheMiniHead()
 Else
    oWr:TheHead()
 Endif
 if len(arrymemo) > 0
    nline := row
    for mcl := 1 to len(arrymemo)
        if nline >= oWr:HB -1
           oWr:TheFeet()
           if oWr:prndrv = "MINI"
              oWr:TheMiniHead()
           Else
              oWr:TheHead()
           Endif
        endif
        if oWr:prndrv = "MINI"
           // @ lstep*nline,col PRINT arrymemo[mcl] FONT "ARIAL" SIZE 10 color argcolor
           _HMG_PRINTER_H_PRINT ( _HMG_MINIPRINT[19] , lstep*nline , col ;
                                , "ARIAL" , 10 , argcolor[1] , argcolor[2] , argcolor[3] ;
                                , arrymemo[mcl] , .F. , .F. , .F. , .F. , .T. , .T. , .T. , )
        Else
           hbprn:say(if(UNITS > 0.and.units < 4,nline*lstep,nline),col,arrymemo[mcl],'Fx',argcolor)
        Endif
        nline ++
    next
    oWr:TheFeet()
    if oWr:prndrv = "MINI"
       oWr:TheMiniHead()
    Else
       oWr:TheHead()
    Endif
 Endif
 return nil

/*
*/
*-----------------------------------------------------------------------------*
function exit()
*-----------------------------------------------------------------------------*
     close databases
     release window all
return nil
/*
*/
*-----------------------------------------------------------------------------*
function what(calias, Checosa, nindexorder,ritorna,sync)
*-----------------------------------------------------------------------------*
local px
local retval
local ncurrentpos := recno()             // position of original file
local noldorder   := indexord()          // original file index order
local ntargetpos  := (calias)->(recno()) // position of target file
LOCAL OLD_AREA    := ALIAS()
default sync to .f.

if nindexorder == nil
   nindexorder := 1
endif

dbSelectArea( calias )
(calias)->(dbsetorder(nindexorder))     // set index order
if (calias)->(dbseek(Checosa)) .and. !empty(checosa)
   if valtype(ritorna)="C"
      retval := (calias)->(fieldget(fieldpos(ritorna)))
   elseif valtype(ritorna)="A"
      retval:={}
      for px = 1 to len(ritorna)
          aadd(retval,(calias)->(fieldget(fieldpos(ritorna[px]))))
      next px
   endif
else
   if valtype(ritorna)="C"
      retval :=azzera((calias)->(fieldget(fieldpos(ritorna))))
   elseif valtype(ritorna)="A"
      retval:={}
      for px = 1 to len(ritorna)
          aadd(retval,azzera((calias)->(fieldget(fieldpos(ritorna[px])))))
      next px
   endif
   sync := .f.
endif
if !sync
   (calias)->(dbgoto(ntargetpos))       // reposition target file
   (calias)->(dbsetorder(noldorder))    // restore index order
   dbSelectArea( OLD_AREA )
   dbgoto(ncurrentpos)                  // reposition original file
endif
return retval
/*
*/
*-----------------------------------------------------------------------------*
function azzera(y_campo)
*-----------------------------------------------------------------------------*
local ritorno
do case
   case valtype(y_campo) = "C"
      ritorno:= space(len(y_campo))
   case valtype(y_campo) = "D"
      ritorno:= ctod("")
   case valtype(y_campo) = "N"
      ritorno:= 0
   case valtype(y_campo) = "L"
      ritorno:= .f.
   case valtype(y_campo) = "M"
      ritorno:= ''
endcase
return ritorno

#include "S_Mchoice.prg"

Static Function AddFont

   Local nRet := AddFontResourceEx("FREE3OF9.ttf",FR_PRIVATE+FR_NOT_ENUM,0)

   If nRet == 0
      MsgStop("An error is occured at installing of font FREE3OF9.ttf.","Warning")
   EndIf
   Return Nil

Static Function RemoveFont

   Local lRet := RemoveFontResourceEx("FREE3OF9.ttf",FR_PRIVATE+FR_NOT_ENUM,0)

   If lRet == .F.
      MsgStop("An error is occured at removing of font FREE3OF9.ttf.","Warning")
   EndIf
   return Nil

DECLARE HB_DYN_CTYPE_INT AddFontResourceEx ( lpszFilename, fl, pdv ) IN GDI32.DLL
DECLARE HB_DYN_CTYPE_BOOL RemoveFontResourceEx ( lpFileName, fl, pdv ) IN GDI32.DLL
/*
*/
*-----------------------------------------------------------------------------*
Function Scegli(opt,title,note,def)
*-----------------------------------------------------------------------------*
   local r:= 0, S_HG := 0
   default title to "Scelta stampe", opt to {"Questa Scheda","Tutte"}
   Default note to "", def to 1
   note := space(10)+ note
   s_hg := len (opt)*25 + 125

   DEFINE WINDOW SCEGLI AT 140 , 235 WIDTH 286 HEIGHT S_hg TITLE "Azzeramento Flag" ;
                 ICON NIL MODAL NOSIZE NOSYSMENU CURSOR NIL ;
                 ON INIT Load_Scegli_base(title,def) ;

          DEFINE STATUSBAR FONT "Arial" SIZE 9 BOLD
                 STATUSITEM note
          END STATUSBAR

          DEFINE RADIOGROUP RadioGroup_1
                 ROW    11
                 COL    21
                 WIDTH  230
                 HEIGHT 59
                 OPTIONS OPT
                 VALUE 1
                 FONTNAME "Arial"
                 FONTSIZE 9
                 SPACING 25
          END RADIOGROUP

          DEFINE BUTTONEX Button_1
                 ROW    S_HG - 105
                 COL    20
                 WIDTH  100
                 HEIGHT 40
                 PICTURE "Minigui_EDIT_OK"
                 CAPTION _HMG_aLangButton[8]
                 ACTION  ( r:= Scegli.RadioGroup_1.value ,Scegli.release)
                 FONTNAME  "Arial"
                 FONTSIZE  9
          END BUTTONEX

          DEFINE BUTTONEX Button_2
                 ROW    S_Hg - 105
                 COL    160
                 WIDTH  100
                 HEIGHT 40
                 PICTURE "Minigui_EDIT_CANCEL"
                 CAPTION _HMG_aLangButton[7]
                 ACTION   Scegli.release
                 FONTNAME  "Arial"
                 FONTSIZE  9
          END BUTTONEX

   END WINDOW

   Scegli.center
   Scegli.activate
return r
/*
*/
*-----------------------------------------------------------------------------*
Procedure load_Scegli_base(title,def)
*-----------------------------------------------------------------------------*
   ON KEY RETURN OF SCEGLI ACTION ( SCEGLI.BUTTON_1.SETFOCUS, _PUSHKEY( VK_SPACE ) )
   escape_on('Scegli')
   Scegli.Title := Title
   Scegli.RadioGroup_1.value := def
return
/*
*/
*-----------------------------------------------------------------------------*
Procedure ESCAPE_ON(ARG1)
*-----------------------------------------------------------------------------*
     local WinName:=if(arg1==NIL,procname(1),arg1)
     if upper(WinName)<>'OFF'
        _definehotkey(arg1,0,27,{||_releasewindow(arg1)})
     else
        ON KEY ESCAPE ACTION nil
     endif
return
