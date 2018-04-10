/*******************************************************************************
   Filename			: Indici.prg

   Created			: 05 April 2012 (10:50:55)
   Created by		: Pierpaolo Martinello

   Last Updated		: 01/06/2013 15:39:30
   Updated by		: Pierpaolo

   Comments			: Freeware
*******************************************************************************/


*-----------------------------------------------------------------------------*
Procedure Opentable()
*-----------------------------------------------------------------------------*
   local aarq, dbd :="."+right(oFatt:Dbf_driver,3), error :=.f. , lf:={}
   local archivio := oFatt:DataPath+"Presa.DbF"
   Local aMsg := {"Archive Bookings unavailable try again?"," Archivio Prenotazioni non disponibile Riprovo?"} [alng]

   CLEAN MEMORY

   If ! ISDIRECTORY(ofatt:DataPath)
      Createfolder(oFatt:DataPath)
      MSGT(1.5,[Cartella Dati creata!],,.t.)
   Endif
   Archivio:= oFatt:DataPath+'Presa.DbF'

   If ! File(Archivio)
      aarq := {}
      Aadd( aarq ,  {'RESOURCE  ','C',1, 0} )
      Aadd( aarq ,  {'DATA_IN   ','D',8, 0} )
      Aadd( aarq ,  {'DATA_OUT  ','D',8, 0} )
      Aadd( aarq ,  {'TIME_IN   ','C',5, 0} )
      Aadd( aarq ,  {'TIME_OUT  ','C',5, 0} )
      Aadd( aarq ,  {'DELAY     ','N',3, 0} )
      Aadd( aarq ,  {'MOTIVO    ','C',60,0} )
      Aadd( aarq ,  {'DA        ','C',30,0} )
      Aadd( aarq ,  {'IN_DATA   ','D',8, 0} )
      Aadd( aarq ,  {'DATA_CANC ','D',8, 0} )
      Aadd( aarq ,  {'OLD_USER  ','C',30,0} )

      DbCreate((Archivio), aarq, oFatt:Dbf_driver)
      MSGT(1.5,[Archivio Prenotazioni creato!],,.t.)

      aarq:={}
   Endif
   dbSelectArea( "1" )
   if net_use( Archivio,"PRESA",.t.,2,.F.,aMsg )
      //  msgbox("indicizzo",alias())
      Lf := directory(oFatt:DataPath+"Maint*.txt","H")
      if len(lf) > 0
         aeval(lf,{|x| deletefile(oFatt:DataPath+x[1])} )
      Endif

      if ofatt:pack
         pack
      Endif
      index on dtos(PRESA->DATA_IN)+PRESA->RESOURCE+PRESA->TIME_IN to Presa
      dbcloseall()
   Endif

   dbSelectArea( "1" )
   Apridb({"PRESA","1"},Archivio,.F.,2,.F.,aMsg ;
        ,{"Presa",{"Presa"}},1,.F.,.t.) // error)
return
/*
*/
*------------------------------------------------------------------------------*
Function Apridb(warea,dbfile,modo,tries,interattivo,msg,indice,ordine,error,cl_Msg)
*------------------------------------------------------------------------------*
   //Net_use( file, ali, ex_use, tries, interactive, YNmessage )
   Local dbd := "."+right(oFatt:Dbf_driver,3), abag := indice[2], rtv := .T.
   default msg to " Archivio "+warea[1]+" non disponibile Riprovo?"
   default tries to 5, modo to .F., interattivo to .T., error to .F.,cl_Msg to ''
   dbSelectArea( warea[2] )

   If net_use( Dbfile, warea[1], .f., tries, interattivo, msg ) .and. !error
      If !.F. ; ordListClear() ; end
         if dbd == ".NTX"
            aeval(abag,{|x| ordListAdd( oFatt:DataPath+x )})
         Else   // CDX
            if indice[1] # NIL .or. !Empty(indice[1])
               ordListAdd( oFatt:DataPath+indice[1])
            endif
         Endif
         ordSetFocus( ordine )
         go top
   Else
      if (empty(Cl_Msg),ChiudiPrg(.T.),ErrTipo(Cl_Msg,alias()) )
      rtv := .F.
   Endif

return rtv
/*
*/
*-----------------------------------------------------------------------------*
Function ErrTipo( dove ,label)
*-----------------------------------------------------------------------------*
   Local aMsg:={ dove+CRLF+[Repeat the rebuilding indexes]+CRLF+[as the only active user!];
     ,dove+CRLF+[Ripetere la ricostruzione indici]+CRLF+[come unico utente attivo!]} [alng]
   default label to  ''
   msgExclamation( aMsg,label)
return .T.
/*
*/
*-----------------------------------------------------------------------------*

*-----------------------------------------------------------------------------*