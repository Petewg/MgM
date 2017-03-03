/*
 * Harbour MiniGUI: Free xBase Win32/GUI Development System
 *
 * Copyright 2002-07 Roberto Lopez <harbourminigui@google.com>
 * http://harbourminigui.googlepages.com
 *
 * Copyright 2007 MigSoft <fugaz_cl@yahoo.es>
*/

#include "minigui.ch"

#ifndef __XHARBOUR__
   #xcommand TRY  => BEGIN SEQUENCE WITH {|oErr| Break( oErr )}
   #xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#endif

Memvar CnAdo, oCursor, lIng, Nuevo
Memvar nFont, cArquivo
*------------------------------------------------------------------------------*
Function Main()
*------------------------------------------------------------------------------*
   Public CnAdo,oCursor,lIng := .T.,Nuevo := .F.
   Seteos()
   ConectaMDB()
   Load Window Principal
   Principal.Maximize
   Activate Window Principal
Return Nil
*------------------------------------------------------------------------------*
Procedure Seteos()
*------------------------------------------------------------------------------*
   set century on
   set date french
   set navigation extended
Return
*------------------------------------------------------------------------------*
Procedure ConectaMDB()
*------------------------------------------------------------------------------*
   Local e
   Try
     CnAdo:=win_oleCreateObject("ADODB.Connection")
     IF Ole2TxtError() != "S_OK"
        MsgStop("ADO is not available.","Error")
        ExitProcess(0)
     ENDIF
     CnAdo:Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=Agenda.mdb")
     oCursor:=win_oleCreateObject("ADODB.Recordset")
   Catch e
     MsgStop("Operation: "+e:operation+"-"+"Description: "+e:Description+chr(10)+vMat(e:Args),"Error")
     ExitProcess(0)
   End
Return
*------------------------------------------------------------------------------*
PROCEDURE AdministradorDeContactos()
*------------------------------------------------------------------------------*
   Load Window Win_1
   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1
RETURN
*------------------------------------------------------------------------------*
PROCEDURE AbrirTablas()
*------------------------------------------------------------------------------*
   Primero()
RETURN
*------------------------------------------------------------------------------*
PROCEDURE CerrarTablas
*------------------------------------------------------------------------------*

RETURN
*------------------------------------------------------------------------------*
PROCEDURE AbrirCursor()
*------------------------------------------------------------------------------*
   if lIng
      oCursor:Open("Select * from contactos order by Apellido",CnAdo,2,3)
      lIng := .F.
   endif
RETURN
*------------------------------------------------------------------------------*
PROCEDURE Primero()
*------------------------------------------------------------------------------*
   AbrirCursor()
   oCursor:MoveFirst()
   CancelarEdicion()
RETURN
*------------------------------------------------------------------------------*
PROCEDURE Siguiente()
*------------------------------------------------------------------------------*
   AbrirCursor()
   if !oCursor:Eof()
      oCursor:MoveNext()
   endif
   CancelarEdicion()
RETURN
*------------------------------------------------------------------------------*
PROCEDURE Anterior()
*------------------------------------------------------------------------------*
   AbrirCursor()
   if !oCursor:Bof()
      oCursor:MovePrevious()
   endif
   CancelarEdicion()
RETURN
*------------------------------------------------------------------------------*
PROCEDURE Ultimo()
*------------------------------------------------------------------------------*
   AbrirCursor()
   oCursor:MoveLast()
   CancelarEdicion()
RETURN
*------------------------------------------------------------------------------*
PROCEDURE DesactivarEdicion
*------------------------------------------------------------------------------*
   Win_1.Control_1.Enabled		:= .F.
   Win_1.Control_3.Enabled		:= .F.
   Win_1.Control_4.Enabled		:= .F.
   Win_1.Control_5.Enabled		:= .F.
   Win_1.Control_6.Enabled		:= .F.
   Win_1.Control_7.Enabled		:= .F.
   Win_1.Control_8.Enabled		:= .F.
   Win_1.Control_9.Enabled		:= .F.
   Win_1.Control_10.Enabled	        := .F.
   Win_1.Control_11.Enabled	        := .F.
   Win_1.Aceptar.Enabled		:= .F.
   Win_1.Cancelar.Enabled		:= .F.
   Win_1.ToolBar_1.Enabled		:= .T.
RETURN
*------------------------------------------------------------------------------*
PROCEDURE ActivarEdicion
*------------------------------------------------------------------------------*
   Win_1.Control_1.Enabled		:= .T.
   Win_1.Control_3.Enabled		:= .T.
   Win_1.Control_4.Enabled		:= .T.
   Win_1.Control_5.Enabled		:= .T.
   Win_1.Control_6.Enabled		:= .T.
   Win_1.Control_7.Enabled		:= .T.
   Win_1.Control_8.Enabled		:= .T.
   Win_1.Control_9.Enabled		:= .T.
   Win_1.Control_10.Enabled	        := .T.
   Win_1.Control_11.Enabled	        := .T.
   Win_1.Aceptar.Enabled		:= .T.
   Win_1.Cancelar.Enabled		:= .T.
   Win_1.ToolBar_1.Enabled		:= .F.
   Win_1.Control_1.SetFocus
RETURN
*------------------------------------------------------------------------------*
PROCEDURE CancelarEdicion()
*------------------------------------------------------------------------------*
   DesactivarEdicion()
   Actualizar()
   Nuevo := .F.
RETURN
*------------------------------------------------------------------------------*
PROCEDURE AceptarEdicion()
*------------------------------------------------------------------------------*
   Local cSql
   DesactivarEdicion()
   If Nuevo
      cSql:="INSERT INTO CONTACTOS (Apellido,Nombres,Calle,Numero,Piso,Dpto,Tel_Part,Tel_Cel,E_Mail,Fecha_Nac) VALUES ('"
      cSql+=Win_1.Control_1.Value        +"','"
      cSql+=Win_1.Control_3.Value        +"','"
      cSql+=Win_1.Control_4.Value        +"','"
      cSql+=str(Win_1.Control_5.Value)   +"','"
      cSql+=str(Win_1.Control_6.Value)   +"','"
      cSql+=Win_1.Control_7.Value        +"','"
      cSql+=Win_1.Control_8.Value        +"','"
      cSql+=Win_1.Control_9.Value        +"','"
      cSql+=Win_1.Control_10.Value       +"','"
      cSql+=dtoc(Win_1.Control_11.Value) +"')"
      Nuevo := .F.
   Else
      cSql:="UPDATE CONTACTOS SET "
      cSql+="Nombres='"+Win_1.Control_3.Value          +"',"
      cSql+="Calle='"+Win_1.Control_4.Value            +"',"
      cSql+="Numero='"+str(Win_1.Control_5.Value)      +"',"
      cSql+="Piso='"+str(Win_1.Control_6.Value)        +"',"
      cSql+="Dpto='"+Win_1.Control_7.Value             +"',"
      cSql+="Tel_Part='"+Win_1.Control_8.Value         +"',"
      cSql+="Tel_Cel='"+Win_1.Control_9.Value          +"',"
      cSql+="E_Mail='"+Win_1.Control_10.Value          +"',"
      cSql+="Fecha_Nac='"+dtoc(Win_1.Control_11.Value) +"'"
      cSql+="Where Apellido='"+Win_1.Control_1.Value   +"'"
   EndIf
   CnAdo:Execute(cSql)
   oCursor:Close()
   lIng := .T.
   AbrirCursor()
   oCursor:Find("Apellido='"+Win_1.Control_1.Value+"'")
 RETURN
*------------------------------------------------------------------------------*
PROCEDURE Nuevo()
*------------------------------------------------------------------------------*
   Win_1.Control_1.Value := ''
   Win_1.Control_3.Value := ''
   Win_1.Control_4.Value := ''
   Win_1.Control_5.Value := 0
   Win_1.Control_6.Value := 0
   Win_1.Control_7.Value := ''
   Win_1.Control_8.Value := ''
   Win_1.Control_9.Value := ''
   Win_1.Control_10.Value := ''
   Win_1.Control_11.Value := CtoD ('01/01/1976')
   ActivarEdicion()
RETURN
*------------------------------------------------------------------------------*
PROCEDURE Actualizar()
*------------------------------------------------------------------------------*
   Do case
      case oCursor:Bof()
           oCursor:MoveFirst()
      case oCursor:Eof()
           oCursor:MoveLast()
   Endcase
   Win_1.Control_1.Value	:= oCursor:Fields["Apellido"]:value
   Win_1.Control_3.Value	:= oCursor:Fields["Nombres"]:value
   Win_1.Control_4.Value	:= oCursor:Fields["Calle"]:value
   Win_1.Control_5.Value 	:= oCursor:Fields["Numero"]:value
   Win_1.Control_6.Value	:= oCursor:Fields["Piso"]:value
   Win_1.Control_7.Value 	:= oCursor:Fields["Dpto"]:value
   Win_1.Control_8.Value	:= oCursor:Fields["Tel_Part"]:value
   Win_1.Control_9.Value	:= oCursor:Fields["Tel_Cel"]:value
   Win_1.Control_10.Value	:= oCursor:Fields["E_Mail"]:value
   Win_1.Control_11.Value	:= oCursor:Fields["Fecha_Nac"]:value
Return
*------------------------------------------------------------------------------*
Function BloquearRegistro()
*------------------------------------------------------------------------------*

Return Nil
*------------------------------------------------------------------------------*
Procedure Eliminar
*------------------------------------------------------------------------------*
   Local cApeF,cSql,cPreF
   If MsgYesNo ( 'Esta Seguro','Eliminar Registro')
      cApeF := Win_1.Control_1.Value
      oCursor:MovePrevious()
      if oCursor:Bof()
         oCursor:MoveFirst()
         oCursor:MoveNext()
      endif
      CancelarEdicion()
      cPreF := Win_1.Control_1.Value
      cSql := "DELETE FROM CONTACTOS WHERE Apellido='"+cApeF+"'"
      CnAdo:Execute(cSql)
      oCursor:Close()
      lIng := .T.
      AbrirCursor()
      oCursor:Find("Apellido='"+cPreF+"'")
      CancelarEdicion()
   EndIf
Return
*------------------------------------------------------------------------------*
Procedure Buscar
*------------------------------------------------------------------------------*
   Local Buscar
   Buscar := Upper ( AllTrim ( InputBox( 'Ingrese Apellido a Buscar:' , 'Busqueda' ) ) )
   Buscar := IIf( Empty(Buscar), "A" , Buscar )
   oCursor:Close()
   oCursor:Open("Select * from contactos where Apellido like '"+Buscar+"%'"+" order by Apellido",CnAdo,2,3)
   if !oCursor:Eof()
      Actualizar()
   else
      MsgInfo("Registro no Encontrado","No existe")
   endif
   oCursor:Close()
   lIng := .T.
   AbrirCursor()
   oCursor:Find("Apellido='"+Win_1.Control_1.Value+"'")
Return
*------------------------------------------------------------------------------*
Static function vMat(a)
*------------------------------------------------------------------------------*
   Local cMsg:="",i
   if valtype(a)="A"
      For i=1 to len(a)
          if valtype(a[i])="N"
             cMsg += Str(a[i])+" "
          elseif valtype(a[i])="L"
             cMsg += if(a[i],".T.",".F.")+" "
          elseif valtype(a[i])="D"
             cMsg += Dtoc(a[i])+" "
          else
             cMsg += a[i]+" "
          endif
      Next
   Endif
Return cMsg
*------------------------------------------------------------------------------*
Procedure Imprimir
*------------------------------------------------------------------------------*
   Local nLin:=0,i,nReg:=0,cLetra:="",Handle,cLinea,Ape1,Nom1
   Private nFont := 11
   Private cArquivo := ""
   Handle := fCreate("Rel.tmp")
   if Handle <= 0
      Return
   endif
   oCursor:MoveFirst()
   Do While ! oCursor:Eof()
      If nLin == 0.or.nLin>55
         cLinea := PadC("Agenda de Contactos",78)+CRLF
         cLinea += PadC("Contactos por Apellido"+cLetra,78)+CRLF
         cLinea += PadR("Apellidos",22)+space(3)+PadR("Nombres",23)+CRLF
         cLinea += Replicate("-",78)+CRLF
         Fwrite(Handle,cLinea)
         nLin:=5
      EndIf
      nLin += 1 ; nReg += 1
      Ape1 := oCursor:Fields["Apellido"]:Value ; Nom1 := oCursor:Fields["Nombres"]:Value
      Fwrite(Handle,PadR(ltrim(Ape1),22)+space(3)+PadR(ltrim(Nom1),23)+CRLF)
      oCursor:MoveNext()
   EndDo
   cLinea:=Replicate("-",78)+CRLF
   cLinea+="Registros Impresos: "+StrZero(nReg,4)
   Fwrite(Handle,cLinea)
   fClose(Handle)
   cArquivo := memoRead("REL.TMP")
   fErase("Rel.tmp")

   Define Window Form_3;
   At 0,0	;
   Width 450	;
   Height 500	;
   Title "Contactos por Apellido"+cLetra;
   ICON "Tutor"	;
   MODAL	;
   NOSYSMENU	;
   NOSIZE	;
   BACKCOLOR WHITE

   @ 20,-1  RICHEDITBOX Edit_1 ;
            WIDTH 460 ;
            HEIGHT 510 ;
            VALUE cArquivo ;
            TOOLTIP "Contactos por Apellido"+cLetra ;
            MAXLENGTH 255

   @ 01,01  BUTTON Bt_Zoom_Mais  ;
            CAPTION '&Zoom(+)'             ;
            WIDTH 120 HEIGHT 17    ;
            ACTION ZoomLabel(1);
            FONT "MS Sans Serif" SIZE 09 FLAT

   @ 01,125 BUTTON Bt_Zoom_menos  ;
            CAPTION '&Zoom(-)'             ;
            WIDTH 120 HEIGHT 17    ;
            ACTION ZoomLabel(-1);
            FONT "MS Sans Serif" SIZE 09 FLAT

   @ 01,321 BUTTON Sair_1  ;
            CAPTION '&Salir'             ;
            WIDTH 120 HEIGHT 17    ;
            ACTION Form_3.Release;
            FONT "MS Sans Serif" SIZE 09 FLAT
   End window
   MODIFY CONTROL Edit_1 OF Form_3 FONTSIZE nFont
   Center Window Form_3
   Activate Window Form_3
Return
*------------------------------------------------------------------------------*
Procedure ZoomLabel(nmm)
*------------------------------------------------------------------------------*
   If nmm == 1
      nFont++
   Else
      nFont--
   Endif
   MODIFY CONTROL Edit_1 OF Form_3 FONTSIZE nFont
Return
