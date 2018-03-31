/*******************************************************************************
   Filename			: Prenota.prg

   Created			: 05 April 2012 (10:50:55)
   Created by		: Pierpaolo Martinello

   Last Updated		: 01/11/2014 16:36:23
   Updated by		: Pierpaolo

   Comments			: Freeware
*******************************************************************************/

#include 'minigui.ch'
#include 'inkey.ch'
#include 'hbclass.ch'
#include 'Prenota.ch'

#define STD_PRINT      14

Memvar ofatt,a_res,alng

/*
*/
*-----------------------------------------------------------------------------*
Function aPrenota(risorsa)
*-----------------------------------------------------------------------------*
Local pos:= 0 , n0 := 0, indice:= trueval(this.name)
Local aImages := { "book" ,"book","book","proiector","car" }
Local abHead  := {{"Date", "R", "From", "At" },{"Data", "R", "Dalle", "Alle" }}
   if len(ofatt:aFrecno)>= indice
      pos:= ofatt:aFrecno[indice]
   else
      risorsa:= date()
      risorsa:= GetProperty ( "Principale", "MONTHCAL_1" , "VALUE")
   Endif

   if risorsa < date() .and. len(oFatt:afrecno) < 1
      return msgStop({"impossible to book in this date! ","Impossibile prenotare in questa data! "}[alng])
   Endif
   Presa->(DbGoTop ())
   Presa->(OrdScope (0, dtos(risorsa)+LTRIM(STR(indice)) ))
   Presa->(OrdScope (1, dtos(risorsa)+LTRIM(STR(indice)) ))
   Presa->(DbSeek (dtos(risorsa)+LTRIM(STR(indice))) )

   set browsesync on

   Load Window prenota
   prenota.center

   if risorsa > date()
      Prenota.Datepicker_1.value := risorsa
   Endif

   if alng = 1  // ENG
      Prenota.title := "Reservations details."
      _setitem("statusbar","Prenota",1, " Today:")
   Else
      Prenota.label_1.value := "Risorsa"
      Prenota.label_2.value := "Giorno:"
      Prenota.label_3.value := "Dalle ore:"
      Prenota.label_4.value := "Alle ore:"
      Prenota.label_5.value := "Evento:"
      Prenota.label_6.value := "Prenotato da:"

      Prenota.title := "Dettagli prenotazione."
      _setitem("statusbar","Prenota",1, " Oggi:")
   Endif

   prenota.activate

   Presa->(OrdScope (0, NIL ))
   Presa->(OrdScope (1, NIL ))

   ReviseDate(GetProperty ( "principale", "MONTHCAL_1" , "value" ))
*/
return nil

/*
*/
*-----------------------------------------------------------------------------*
Function Load_prenota_base(risorsa)
*-----------------------------------------------------------------------------*
   escape_on("Prenota")
   default risorsa to 1

   _DefineHotKey ( "PRENOTA" , MOD_ALT + MOD_CONTROL , IF(alng = 1 ,VK_P,VK_S) , {||ListDeleted()} )

if ofatt:prenuova = .f.
   Prenota.ComboBoxEX_1.enabled := .F.
   PRENOTA.DatePicker_1.enabled := .F.
   Prenota.TimePicker_1.enabled := .F.
   Prenota.TimePicker_2.enabled := .F.
   Prenota.Text_5.readonly      := .T.
   prenota.buttonex_1.enabled   := .f.
Endif

Prenota.ComboBoxEX_1.value := val( 1->RESOURCE )
PRENOTA.DatePicker_1.value:= 1->data_in

return nil

/*
*/
*-----------------------------------------------------------------------------*
Function Prenota_Pull()
*-----------------------------------------------------------------------------*
   Prenota.ComboBoxEX_1.value := VAl( presa->resource )
   PRENOTA.DatePicker_1.value := presa->data_in
   Prenota.TimePicker_1.refresh
   Prenota.TimePicker_2.refresh
   Prenota.Text_5.refresh
   Prenota.Text_6.refresh

   //msgbox(tstring(timetosec(PRESA->TIME_out)-timetosec(PRESA->TIME_IN)),"Totale")

return nil
/*
*/
*-----------------------------------------------------------------------------*
Function Prenota_push()
*-----------------------------------------------------------------------------*
local errore := .F. ,ntargetpos
if !prenuova() .or. ofatt:prenuova = .f.
   prenota.buttonex_3.setfocus
   return nil
else
   if ofatt:prenuova = .t.
      if !add_rec(3, .t., "File not available on network"+CRLF+"Do I retry?")
         errore:=.t.
      endif
   Endif
   ofatt:prenuova := .f.
   Prenota.browse_1.disableUpdate
Endif
if !errore
   ntargetpos  := Presa->(recno()) // position of target file
   if srec_lock(2,.T.,"Non modifiable booking because in use. Do I retry?")
      presa->resource := zaps(Prenota.ComboBoxEX_1.value)
      presa->data_in  := Prenota.DatePicker_1.value
      Prenota.TimePicker_1.save
      Prenota.TimePicker_2.save
      Prenota.Text_5.save
      presa->da       := Prenota.Text_6.value
      presa->in_data  := date()
      Presa->delay    := ofatt:delay
      dbcommit()
   Endif
Endif
TestData()
Prenota.browse_1.value := ntargetpos
Prenota.browse_1.EnableUpdate
Prenota.browse_1.refresh
enableNew()

Return nil
/*
*/
*-----------------------------------------------------------------------------*
Function ListDeleted()
*-----------------------------------------------------------------------------*
  ofatt:Listdelete := .T.
return Listato()
/*
*/
*-----------------------------------------------------------------------------*
Function Listato()
*-----------------------------------------------------------------------------*
   Local cnt := 0 , oldDb := alias(), ;
         noldorder   := Presa->(indexord()), ; // original file index order
         ntargetpos  := Presa->(recno())       // position of target file
   Local aLbl    := {{ 'From day:' ,'to day:'},{'Dal giorno:','Al giorno' }}[alng] ,;
         aIniVal := { presa->data_in, date() },;
         aFmt    := { '99/99/99' , '99/99/99' },;
         a_msg   := {"The final date cannot be inferior to that initial!";
                    ,"La data finale NON può essere inferiore a quella iniziale !"},;
         a_imsg  := {'Print options:','Opzioni di stampa:' } [alng]
   Private a_res := {}
      a_Res    := InputWindow ( a_imsg , aLbl , aIniVal , aFmt )

      If a_Res [1] == Nil
         return nil
      elseif a_Res[2] < a_Res [1]
         msgstop(a_msg[alng])
         return nil
      Endif

      Presa->(dbsetorder(1))  // mette in ordine di val(codice articolo)

      Presa->(DbGoTop ())
      Presa->(OrdScope (0, dtos(a_res[1])))
      Presa->(OrdScope (1, dtos(a_res[2])))
      Presa->(DbSeek (dtos(a_Res[1])) )

      if ordkeycount() > 0
         if recc() > 0
            Winrepint([Presa.mod],[Presa],,, ) //oFatt:Rpset[1,1] , oFatt:Rpset[1,2)
            SET( _SET_DELETED   , .f.  )
            ofatt:ListDelete := .f.
         Endif
      Else
         msginfo({"There am no booking among the gives suitable!";
         ,"Non ci sono prenotazioni tra le date indicate!"}[alng] )
      Endif
      Presa->(OrdScope (0, NIL ))
      Presa->(OrdScope (1, NIL ))

   Presa->(dbgoto(ntargetpos))
   Presa->(dbsetorder(noldorder))  // restore index order
   Release a_res
return nil
/*
*/
*-----------------------------------------------------------------------------*
Function Prenuova(nuova)
*-----------------------------------------------------------------------------*
Local vSta   := timetosec(left(prenota.timepicker_1.value,5)+":00:00")
Local vSto   := timetosec(left(prenota.timepicker_2.value,5)+":00:00")
lOCAL Ldelay := (ofatt:delay*60)
local Tsta   := vSta - Ldelay
Local Tsto   := Vsto + Ldelay
Local Limiti := {min(0,tsta),max(0,tsto)} , ok := .F.  ,c1 := 0
local causa  := "", tot_ok := .T.
local rcn    := recno(), changed := .f.
local gstate := {||presa->time_in+presa->time_out+dtos(presa->data_in)+presa->resource}
local astate := {||left(prenota.timepicker_1.value,5)+left(prenota.timepicker_2.value,5) ;
                   + dtos(PRENOTA.DatePicker_1.value)+zaps(Prenota.ComboBoxEX_1.value) }
DEFAULT NUOVA TO .F.
     changed := left(prenota.timepicker_1.value,5)+left(prenota.timepicker_2.value,5);
                 +dtos(PRENOTA.DatePicker_1.value)+zaps(Prenota.ComboBoxEX_1.value) ;
                 <> ;
                 presa->time_in+presa->time_out+dtos(presa->data_in)+presa->resource
dbgotop()

if prenota.DatePicker_1.value < date()
   msgStop({"impossible to book in this date! ","Impossibile prenotare in questa data! "}[alng])
   Return .f.
Endif

if Prenota.ComboBoxEX_1.value < 1
   msgExclamation({"Provide a resource to book !","Scegliere una risorsa da prenotare !"}[alng])
   Prenota.ComboBoxEX_1.setfocus
   return ok
Endif

if empty(alltrim(Prenota.Text_5.value) )
   msgExclamation({"Provide the reason for booking !","Fornire la ragione per la prenotazione!"}[alng])
   Prenota.Text_5.setfocus
   return ok
Endif

if vsta > vsto
   msgExclamation({" The start time must not be higher than that of the end reservation" ;
   ,"L'ora di inizio non deve essere superiore a quella di fine prenotazione!"}[alng] )
   PRENOTA.TimePicker_1.setfocus
   return ok
Endif
if left(prenota.timepicker_1.value,5) = left(prenota.timepicker_2.value,5)
   msgExclamation({"The start time must NOT coincide with the end of the event !" ;
   ,"L'ora di inizio non deve coincidere con quella di inizio! "}[alng] )
   PRENOTA.TimePicker_1.setfocus
   return ok
Endif

while !eof() .and. (presa->data_in = prenota.datepicker_1.value .and. zaps(Prenota.ComboBoxEX_1.value) = presa->resource)

      Ok:= ( Tsto <= TIMETOSEC(alltrim(1->time_in )+":00:00") .and. Vsta < Vsto) ;
           .or.;
           ( Tsta >= TIMETOSEC(alltrim(1->time_out)+":00:00") .and. Vsto > Vsta)

      if eval(gstate) = eval(astate)
         ok := .F.
         causa := {"Existing reservation !","Prenotazione già esistente"}[alng]
      Endif
      tot_ok := tot_ok .and. ok
      c1 ++
      dbskip()
end
dbgoto(rcn)

if !tot_ok
   MsgExclamation({"Values NOT admitted!","Valori NON ammessi!"}[alng] +CRLF+causa;
   ,{" Recheck !","Ricontrolla!" }[alng])
   oFatt:prenuova := .F.
   enableNew()
Endif

Return tot_ok
/*
*/
*-----------------------------------------------------------------------------*
Function TestData()
*-----------------------------------------------------------------------------*
   Local Vl1 := PRENOTA.DatePicker_1.value ,;
         Vl2 := zaps(PRENOTA.comboBoxEx_1.value)

         Presa->(DbGoTop ())
         Presa->(OrdScope (0, dtos(Vl1)+Vl2))
         Presa->(OrdScope (1, dtos(Vl1)+Vl2))
         Presa->(DbSeek  (   dtos(Vl1)+Vl2) )
return nil

/*
*/
*-----------------------------------------------------------------------------*
Function EnableNew()
*-----------------------------------------------------------------------------*
   Prenota.ComboBoxEX_1.enabled := ofatt:prenuova
   PRENOTA.DatePicker_1.enabled := ofatt:prenuova
   Prenota.TimePicker_1.enabled := ofatt:prenuova
   Prenota.TimePicker_2.enabled := ofatt:prenuova
   Prenota.text_5.readonly      := !ofatt:prenuova
   prenota.buttonex_1.enabled   := ofatt:prenuova
   prenota.buttonex_3.enabled   := !ofatt:prenuova
   prenota.buttonex_4.enabled   := !ofatt:prenuova
   PRENOTA.TimePicker_1.setfocus
   if PRENOTA.DatePicker_1.value < date()
      PRENOTA.DatePicker_1.value := date()
   Endif
   Prenota.text_6.value         := getusername()

Return nil

/*
*/
*-----------------------------------------------------------------------------*
Function DelRecord()
*-----------------------------------------------------------------------------*
if srec_lock(2,.T.,{"Non modifiable booking because in use. Do I retry?" ;
        ,"Prenotazione non modificabile perchè in uso. Riprovo?"}[alng] )
   presa->data_canc := date()
   Presa->OLD_USER  := PRESA->DA
   Presa->da        := getusername()
   DbDelete()
   DbUnlock()
   prenota.browse_1.refresh
Endif

RETURN Nil
