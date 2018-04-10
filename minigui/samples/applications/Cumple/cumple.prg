***Creado por Jose Miguel (Valencia)***
***josemisu@yahoo.com.ar***

#include "minigui.ch"

MEMVAR RUTAEMPRESA

PROCEDURE main()

   ***CODIGO DE PAGINA español***
   SET CODEPAGE TO SPANISH
   SET LANGUAGE TO SPANISH //Select language for interface messages

   ***Inicializacion RDD DBFCDX Nativo***
   REQUEST DBFCDX
   RDDSETDEFAULT( "DBFCDX" )
   SET AUTOPEN OFF //no abrir los indices automaticamente

   cumple()

RETURN


PROCEDURE cumple()
   LOCAL IRBR2, FECCUM, LAMADA
   Set Navigation Extended //TAB y ENTER
   SET DATE FORMAT "dd-mm-yyyy"
   SET EPOCH TO YEAR(DATE())-50
   SET DELETE ON
   SET MULTIPLE OFF WARNING

   RUTAEMPRESA:=GetCurrentFolder()

   AbrirDBF("cumple")

***BUSCAR SEMANA DATE()***
   IF LASTREC()<1
      IRBR2:=1
   ELSE
      SET SOFTSEEK ON
      SEEK DTOS(DATE())
      IF EOF()
         GO BOTT
      ELSE
         IF FIELD->FECCUM>DATE()-DIASEM(DATE())+28
            SKIP -1
            IF FIELD->FECCUM<DATE()-DIASEM(DATE())+1
               SKIP
            ENDIF
         ENDIF
      ENDIF
      IRBR2:=RECNO()
      SET SOFTSEEK OFF
   ENDIF
***FIN BUSCAR SEMANA DATE()***

   DEFINE WINDOW WinBRcum1 ;
      AT 0,0     ;
      WIDTH 810  ;
      HEIGHT 640 ;
      TITLE "Cumples" ;
      ICON "MAIN" ;
      MAIN ;
      NOMAXIMIZE NOSIZE ;
      BACKCOLOR MiColor("ROSACLARO")


      @ 10,10 BROWSE BR_cum1 ;
      HEIGHT 210 ;
      WIDTH 255 ;
      TOOLTIP 'Consulta cumples' ;
      HEADERS {'Fecha','Nombre'} ;
      WIDTHS { 60,170 } ;
      WORKAREA cumple ;
      FIELDS {'DIA(cumple->Feccum,8)','cumple->Nomcum'} ;
      JUSTIFY {BROWSE_JTFY_CENTER,BROWSE_JTFY_LEFT} ;
      VALUE IRBR2 ;
      ON CHANGE ( Actualiz_cumple("BROWSE") )
*      ON HEADCLICK { {|| AbrirDBF("cumple"),DBSETORDER(1), WinBRcum1.BR_cum1.Refresh, Actualiz_cumple("BROWSE")} , ;
*                     {|| AbrirDBF("cumple"),DBSETORDER(2), WinBRcum1.BR_cum1.Refresh, Actualiz_cumple("BROWSE")} }
*      ON DBLCLICK Datos_alumno(WinBRcum1.BR_cum1.Value,"Consultar") ;

      @0,0 TEXTBOX RegNuevo WIDTH 100 VALUE 0 NUMERIC RIGHTALIGN INVISIBLE
      @0,0 TEXTBOX FecNuevo WIDTH 100 VALUE DATE() DATE INVISIBLE

      @010,270 LABEL Dia1 VALUE 'lunes'     WIDTH 70 HEIGHT 15 CENTERALIGN
      @010,345 LABEL Dia2 VALUE 'martes'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @010,420 LABEL Dia3 VALUE 'miercoles' WIDTH 70 HEIGHT 15 CENTERALIGN
      @010,495 LABEL Dia4 VALUE 'jueves'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @010,570 LABEL Dia5 VALUE 'viernes'   WIDTH 70 HEIGHT 15 CENTERALIGN
      @010,645 LABEL Dia6 VALUE 'sabado'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @010,720 LABEL Dia7 VALUE 'domingo'   WIDTH 70 HEIGHT 15 CENTERALIGN

      @025,270 LABEL CabDia1 VALUE 'lunes'     WIDTH 70 HEIGHT 15 CENTERALIGN
      @025,345 LABEL CabDia2 VALUE 'martes'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @025,420 LABEL CabDia3 VALUE 'miercoles' WIDTH 70 HEIGHT 15 CENTERALIGN
      @025,495 LABEL CabDia4 VALUE 'jueves'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @025,570 LABEL CabDia5 VALUE 'viernes'   WIDTH 70 HEIGHT 15 CENTERALIGN
      @025,645 LABEL CabDia6 VALUE 'sabado'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @025,720 LABEL CabDia7 VALUE 'domingo'   WIDTH 70 HEIGHT 15 CENTERALIGN

      @040,270 LABEL CumDia1 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia1.Value))
      @040,345 LABEL CumDia2 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia2.Value))
      @040,420 LABEL CumDia3 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia3.Value))
      @040,495 LABEL CumDia4 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia4.Value))
      @040,570 LABEL CumDia5 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia5.Value))
      @040,645 LABEL CumDia6 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia6.Value))
      @040,720 LABEL CumDia7 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia7.Value))

      @055,270 LABEL CueDia1 VALUE '' WIDTH 70 HEIGHT 30 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia1.Value))
      @055,345 LABEL CueDia2 VALUE '' WIDTH 70 HEIGHT 30 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia2.Value))
      @055,420 LABEL CueDia3 VALUE '' WIDTH 70 HEIGHT 30 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia3.Value))
      @055,495 LABEL CueDia4 VALUE '' WIDTH 70 HEIGHT 30 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia4.Value))
      @055,570 LABEL CueDia5 VALUE '' WIDTH 70 HEIGHT 30 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia5.Value))
      @055,645 LABEL CueDia6 VALUE '' WIDTH 70 HEIGHT 30 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia6.Value))
      @055,720 LABEL CueDia7 VALUE '' WIDTH 70 HEIGHT 30 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia7.Value))

      @090,270 LABEL Dia8  VALUE 'lunes'     WIDTH 70 HEIGHT 15 CENTERALIGN
      @090,345 LABEL Dia9  VALUE 'martes'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @090,420 LABEL Dia10 VALUE 'miercoles' WIDTH 70 HEIGHT 15 CENTERALIGN
      @090,495 LABEL Dia11 VALUE 'jueves'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @090,570 LABEL Dia12 VALUE 'viernes'   WIDTH 70 HEIGHT 15 CENTERALIGN
      @090,645 LABEL Dia13 VALUE 'sabado'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @090,720 LABEL Dia14 VALUE 'domingo'   WIDTH 70 HEIGHT 15 CENTERALIGN

      @105,270 LABEL CabDia8  VALUE 'lunes'     WIDTH 70 HEIGHT 15 CENTERALIGN
      @105,345 LABEL CabDia9  VALUE 'martes'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @105,420 LABEL CabDia10 VALUE 'miercoles' WIDTH 70 HEIGHT 15 CENTERALIGN
      @105,495 LABEL CabDia11 VALUE 'jueves'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @105,570 LABEL CabDia12 VALUE 'viernes'   WIDTH 70 HEIGHT 15 CENTERALIGN
      @105,645 LABEL CabDia13 VALUE 'sabado'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @105,720 LABEL CabDia14 VALUE 'domingo'   WIDTH 70 HEIGHT 15 CENTERALIGN

      @120,270 LABEL CumDia8  VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia8.Value))
      @120,345 LABEL CumDia9  VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia9.Value))
      @120,420 LABEL CumDia10 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia10.Value))
      @120,495 LABEL CumDia11 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia11.Value))
      @120,570 LABEL CumDia12 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia12.Value))
      @120,645 LABEL CumDia13 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia13.Value))
      @120,720 LABEL CumDia14 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia14.Value))

      @135,270 LABEL CueDia8  VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia8.Value))
      @135,345 LABEL CueDia9  VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia9.Value))
      @135,420 LABEL CueDia10 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia10.Value))
      @135,495 LABEL CueDia11 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia11.Value))
      @135,570 LABEL CueDia12 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia12.Value))
      @135,645 LABEL CueDia13 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia13.Value))
      @135,720 LABEL CueDia14 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia14.Value))

      @175,270 LABEL Dia15 VALUE 'lunes'     WIDTH 70 HEIGHT 15 CENTERALIGN
      @175,345 LABEL Dia16 VALUE 'martes'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @175,420 LABEL Dia17 VALUE 'miercoles' WIDTH 70 HEIGHT 15 CENTERALIGN
      @175,495 LABEL Dia18 VALUE 'jueves'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @175,570 LABEL Dia19 VALUE 'viernes'   WIDTH 70 HEIGHT 15 CENTERALIGN
      @175,645 LABEL Dia20 VALUE 'sabado'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @175,720 LABEL Dia21 VALUE 'domingo'   WIDTH 70 HEIGHT 15 CENTERALIGN

      @190,270 LABEL CabDia15 VALUE 'lunes'     WIDTH 70 HEIGHT 15 CENTERALIGN
      @190,345 LABEL CabDia16 VALUE 'martes'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @190,420 LABEL CabDia17 VALUE 'miercoles' WIDTH 70 HEIGHT 15 CENTERALIGN
      @190,495 LABEL CabDia18 VALUE 'jueves'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @190,570 LABEL CabDia19 VALUE 'viernes'   WIDTH 70 HEIGHT 15 CENTERALIGN
      @190,645 LABEL CabDia20 VALUE 'sabado'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @190,720 LABEL CabDia21 VALUE 'domingo'   WIDTH 70 HEIGHT 15 CENTERALIGN

      @205,270 LABEL CumDia15 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia15.Value))
      @205,345 LABEL CumDia16 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia16.Value))
      @205,420 LABEL CumDia17 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia17.Value))
      @205,495 LABEL CumDia18 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia18.Value))
      @205,570 LABEL CumDia19 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia19.Value))
      @205,645 LABEL CumDia20 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia20.Value))
      @205,720 LABEL CumDia21 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia21.Value))

      @220,270 LABEL CueDia15 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia15.Value))
      @220,345 LABEL CueDia16 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia16.Value))
      @220,420 LABEL CueDia17 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia17.Value))
      @220,495 LABEL CueDia18 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia18.Value))
      @220,570 LABEL CueDia19 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia19.Value))
      @220,645 LABEL CueDia20 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia20.Value))
      @220,720 LABEL CueDia21 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia21.Value))

      @260,270 LABEL Dia22 VALUE 'lunes'     WIDTH 70 HEIGHT 15 CENTERALIGN
      @260,345 LABEL Dia23 VALUE 'martes'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @260,420 LABEL Dia24 VALUE 'miercoles' WIDTH 70 HEIGHT 15 CENTERALIGN
      @260,495 LABEL Dia25 VALUE 'jueves'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @260,570 LABEL Dia26 VALUE 'viernes'   WIDTH 70 HEIGHT 15 CENTERALIGN
      @260,645 LABEL Dia27 VALUE 'sabado'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @260,720 LABEL Dia28 VALUE 'domingo'   WIDTH 70 HEIGHT 15 CENTERALIGN

      @275,270 LABEL CabDia22 VALUE 'lunes'     WIDTH 70 HEIGHT 15 CENTERALIGN
      @275,345 LABEL CabDia23 VALUE 'martes'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @275,420 LABEL CabDia24 VALUE 'miercoles' WIDTH 70 HEIGHT 15 CENTERALIGN
      @275,495 LABEL CabDia25 VALUE 'jueves'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @275,570 LABEL CabDia26 VALUE 'viernes'   WIDTH 70 HEIGHT 15 CENTERALIGN
      @275,645 LABEL CabDia27 VALUE 'sabado'    WIDTH 70 HEIGHT 15 CENTERALIGN
      @275,720 LABEL CabDia28 VALUE 'domingo'   WIDTH 70 HEIGHT 15 CENTERALIGN

      @290,270 LABEL CumDia22 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia22.Value))
      @290,345 LABEL CumDia23 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia23.Value))
      @290,420 LABEL CumDia24 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia24.Value))
      @290,495 LABEL CumDia25 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia25.Value))
      @290,570 LABEL CumDia26 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia26.Value))
      @290,645 LABEL CumDia27 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia27.Value))
      @290,720 LABEL CumDia28 VALUE '' WIDTH 70 HEIGHT 15 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia28.Value))

      @305,270 LABEL CueDia22 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia22.Value))
      @305,345 LABEL CueDia23 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia23.Value))
      @305,420 LABEL CueDia24 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia24.Value))
      @305,495 LABEL CueDia25 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia25.Value))
      @305,570 LABEL CueDia26 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia26.Value))
      @305,645 LABEL CueDia27 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia27.Value))
      @305,720 LABEL CueDia28 VALUE '' WIDTH 70 HEIGHT 35 CENTERALIGN ACTION Ir_Cumple(DIACAR(WinBRcum1.CabDia28.Value))


      @345,270 BUTTON Bt_MesAnt CAPTION '<<-Mes anterior' WIDTH 100 HEIGHT 25 ;
              ACTION ( VerSemanaCumple(DIACAR(WinBRcum1.CabDia1.value)-28), ;
                       WinBRcum1.FecNuevo.Value:=DIACAR(WinBRcum1.CabDia1.value) ) NOTABSTOP

      @345,375 BUTTON Bt_SemAnt CAPTION '<-Semana ant.' WIDTH 100 HEIGHT 25 ;
              ACTION ( VerSemanaCumple(DIACAR(WinBRcum1.CabDia1.value)-7), ;
                       WinBRcum1.FecNuevo.Value:=DIACAR(WinBRcum1.CabDia1.value) ) NOTABSTOP

      @345,480 BUTTON Bt_VerHoy CAPTION '<-Ver hoy->' WIDTH 100 HEIGHT 25 ;
              ACTION ( VerSemanaCumple(DATE()), ;
                       WinBRcum1.FecNuevo.Value:=DATE() ) NOTABSTOP

      @345,590 BUTTON Bt_SemSig CAPTION 'Semana sig.->' WIDTH 100 HEIGHT 25 ;
              ACTION ( VerSemanaCumple(DIACAR(WinBRcum1.CabDia1.value)+7,"Bt_SemSig"), ;
                       WinBRcum1.FecNuevo.Value:=DIACAR(WinBRcum1.CabDia1.value) ) NOTABSTOP

      @345,695 BUTTON Bt_MesSig CAPTION 'Mes sig.->>' WIDTH 100 HEIGHT 25 ;
              ACTION ( VerSemanaCumple(DIACAR(WinBRcum1.CabDia1.value)+28), ;
                       WinBRcum1.FecNuevo.Value:=DIACAR(WinBRcum1.CabDia1.value) ) NOTABSTOP


      @355,10 LABEL L_Feccum VALUE 'Fecha cumple' AUTOSIZE TRANSPARENT
      @350,100 TEXTBOX D_Feccum WIDTH 85 HEIGHT 25 DATE 
      @355,190 LABEL L_HoraCum VALUE 'Hora' AUTOSIZE TRANSPARENT
      @350,220 TEXTBOX T_HoraCum WIDTH 45 VALUE "  :  " INPUTMASK '99:99'

      @385,10 LABEL L_CodAlu VALUE 'Codigo' AUTOSIZE TRANSPARENT
      @380,110 TEXTBOX T_CodAlu WIDTH 100 TOOLTIP 'Codigo alumno' NUMERIC RIGHTALIGN

      @230,170 IMAGE I_Foto1 PICTURE '' WIDTH  81 HEIGHT 108 //STRETCH (AJUSTAR)

      @415,10 LABEL L_Nomcum VALUE 'Nombre cumple' AUTOSIZE TRANSPARENT
      @410,110 TEXTBOX T_Nomcum WIDTH 300 VALUE "" MAXLENGTH 30 

      @445,10 LABEL L_Fecnac VALUE 'Fecha Nacimiento' AUTOSIZE TRANSPARENT
      @440,110 TEXTBOX D_Fecnac WIDTH 85 HEIGHT 25 DATE 

      @475,10 LABEL L_NomMadre VALUE 'Nombre madre' AUTOSIZE TRANSPARENT
      @470,110 TEXTBOX T_NomMadre WIDTH 300 VALUE "" MAXLENGTH 30 

      @505,10 LABEL L_Tel1 VALUE 'Telefono' AUTOSIZE TRANSPARENT
      @500,110 TEXTBOX T_Tel1 ;
              WIDTH 150 ;
              VALUE "" ;
              TOOLTIP 'Telefono' ;
              MAXLENGTH 15

      @375,450 LABEL L_Invi VALUE 'Invitaciones' AUTOSIZE TRANSPARENT
      @395,450 TEXTBOX T_Invi WIDTH 50 HEIGHT 20 VALUE 0 NUMERIC MAXLENGTH 3 RIGHTALIGN

      @375,550 LABEL L_Amigos VALUE 'Amigos' AUTOSIZE TRANSPARENT
      @395,550 TEXTBOX T_Amigos WIDTH 50 HEIGHT 20 VALUE 0 NUMERIC MAXLENGTH 3 RIGHTALIGN

      @375,650 LABEL L_Confir VALUE 'Confirmados' AUTOSIZE TRANSPARENT
      @395,650 TEXTBOX T_Confir WIDTH 50 HEIGHT 20 VALUE 0 NUMERIC MAXLENGTH 3 RIGHTALIGN

      @427,450 LABEL L_Papas VALUE 'Papas' AUTOSIZE TRANSPARENT
      @425,550 TEXTBOX T_Papas WIDTH 50 HEIGHT 20 VALUE 0 NUMERIC MAXLENGTH 3 RIGHTALIGN

      @450,450 CHECKBOX C_SiReserva CAPTION 'Reserva' WIDTH 80 HEIGHT 20 VALUE .F. ;
              TOOLTIP 'Reserva cumpleaños' ;
              ON CHANGE Modifcum1(.t.,"RESERVA") TRANSPARENT NOTABSTOP

      @450,550 TEXTBOX T_ImpReserva ;
              WIDTH 100 HEIGHT 20 ;
              VALUE 0 ;
              NUMERIC INPUTMASK '9,999,999,999.99' FORMAT 'E' ;
              RIGHTALIGN
      @450,685 TEXTBOX D_Freserva ;
              WIDTH 80 HEIGHT 20 ;
              TOOLTIP 'Fecha de la reserva' ;
              DATE

      @477,450 LABEL L_Rbo VALUE 'Recibo' AUTOSIZE TRANSPARENT
      @475,550 TEXTBOX T_Rbo ;
              WIDTH 50 HEIGHT 20 ;
              VALUE 0 ;
              NUMERIC ;
              RIGHTALIGN

      @475,650 CHECKBOX C_Promocion CAPTION 'Promocion' WIDTH 80 HEIGHT 20 VALUE .F. ;
              TOOLTIP 'Aplicar promocion publicitaria' TRANSPARENT NOTABSTOP

      @500,350 CHECKBOX C_fotosCD CAPTION 'Fotos CD' WIDTH 80 HEIGHT 20 VALUE .F. ;
              TOOLTIP 'Realizar CD de fotos' ;
              ON CHANGE Modifcum1(.t.,"RESERVA") TRANSPARENT NOTABSTOP

      @500,450 CHECKBOX C_SiEntCD CAPTION 'Entrega CD' WIDTH 80 HEIGHT 20 VALUE .F. ;
              TOOLTIP 'Entrega CD de fotos' ;
              ON CHANGE Modifcum1(.t.,"RESERVA") TRANSPARENT NOTABSTOP

      @500,550 TEXTBOX T_CEntCD ;
              WIDTH 125 HEIGHT 20 ;
              VALUE '' ;
              TOOLTIP 'Persona a la que se entrega el CD de fotos' ;
              MAXLENGTH 20
      @500,685 TEXTBOX D_FEntCD ;
              WIDTH 80 HEIGHT 20 ;
              TOOLTIP 'Fecha de entrega del CD de fotos' ;
              DATE

      @565,010 BUTTONEX Bt_Nuevo ;
         CAPTION 'Nuevo' ;
         ICON 'Znuevo' ;
         ACTION Nuevocum1("NUEVO") ;
         WIDTH 90 HEIGHT 25 ;
         TOOLTIP 'Nuevo cumple' ;
         NOTABSTOP

      @565,110 BUTTONEX Bt_Modif ;
         CAPTION 'Modificar' ;
         ICON 'Zmodificar' ;
         ACTION Modifcum1(.t.) ;
         WIDTH 90 HEIGHT 25 ;
         TOOLTIP 'Modificar cumple' ;
         NOTABSTOP

      @565,210 BUTTONEX Bt_Guardar ;
         CAPTION 'Guardar' ;
         ICON 'Zguardar' ;
         ACTION Guardarcum1() ;
         WIDTH 90 HEIGHT 25 ;
         TOOLTIP 'Guardar cumple' ;
         NOTABSTOP

      @565,310 BUTTONEX Bt_Cancelar ;
         CAPTION 'Cancelar' ;
         ICON 'Zcancelar' ;
         ACTION Actualiz_cumple("CANCELAR") ;
         WIDTH 90 HEIGHT 25 ;
         TOOLTIP 'Cancelar las modificaciones' ;
         NOTABSTOP

      @565,410 BUTTONEX Bt_Elim ;
         CAPTION 'Eliminar' ;
         ICON 'Zeliminar' ;
         WIDTH 90 HEIGHT 25 ;
         TOOLTIP 'Eliminar cumple' ;
         ACTION Eliminar_cumple() ;
         NOTABSTOP

      @565,710 BUTTONEX Bt_Salir ;
         CAPTION 'Salir' ;
         ICON 'Zsalir' ;
         ACTION WinBRcum1.Release ;
         WIDTH 80 HEIGHT 25 ;
         TOOLTIP 'Salir' ;
         NOTABSTOP

   Modifcum1(.F.)

   END WINDOW

   CENTER WINDOW WinBRcum1
   ACTIVATE WINDOW WinBRcum1

RETURN


PROCEDURE Nuevocum1(LLAMADA)

   IF LLAMADA="NUEVO"
      WinBRcum1.RegNuevo.Value := 1
   ENDIF
   WinBRcum1.D_Feccum.value    := WinBRcum1.FecNuevo.Value
   WinBRcum1.T_Horacum.value   := "  :  "
   WinBRcum1.D_Fecnac.value    := DATE()-365
   WinBRcum1.T_CodAlu.value    := 0
   WinBRcum1.T_Nomcum.value    := ""
   WinBRcum1.T_NomMadre.value  := ""
   WinBRcum1.T_Invi.value      := 0
   WinBRcum1.T_Amigos.value    := 0
   WinBRcum1.T_Confir.value    := 0
   WinBRcum1.T_Papas.value     := 0
   WinBRcum1.T_Tel1.value      := ""
   WinBRcum1.C_SiReserva.value := .F.
   WinBRcum1.T_ImpReserva.value:= 0
   WinBRcum1.D_Freserva.value  := CTOD("  -  -  ")
   WinBRcum1.C_FotosCD.Value   := .F.
   WinBRcum1.C_SiEntCD.value   := .F.
   WinBRcum1.T_CEntCD.value    := ''
   WinBRcum1.D_FEntCD.value    := CTOD("  -  -  ")
   WinBRcum1.T_Rbo.value       := 0
   WinBRcum1.C_Promocion.Value := .F.

   IF LLAMADA="NUEVO"
      Modifcum1(.t.)
   ENDIF
   WinBRcum1.T_Horacum.SetFocus

RETURN


PROCEDURE Modifcum1(Modifcum1,LLAMADA)
   LOCAL LAMADA:=IF(LLAMADA=NIL,' ',LLAMADA)

   ***reserva***
   WinBRcum1.C_SiReserva.Enabled := Modifcum1
   IF WinBRcum1.C_SiReserva.value .AND. Modifcum1=.T.
      WinBRcum1.T_ImpReserva.Enabled:= .T.
      WinBRcum1.D_Freserva.Enabled  := .T.
      IF WinBRcum1.T_ImpReserva.Value=0
         WinBRcum1.D_Freserva.Value := DATE()
      ENDIF
   ELSE
      WinBRcum1.T_ImpReserva.Enabled:= .F.
      WinBRcum1.D_Freserva.Enabled  := .F.
   ENDIF
   WinBRcum1.C_FotosCD.Enabled := Modifcum1
   IF WinBRcum1.C_FotosCD.Value=.T.
      WinBRcum1.C_SiEntCD.Enabled := Modifcum1
      IF WinBRcum1.C_SiEntCD.value .AND. Modifcum1=.T.
         WinBRcum1.T_CEntCD.Enabled:= .T.
         WinBRcum1.D_FEntCD.Enabled:= .T.
         IF WinBRcum1.D_FEntCD.Value=CTOD("  -  -  ")
            WinBRcum1.D_FEntCD.Value := DATE()
         ENDIF
      ELSE
         WinBRcum1.T_CEntCD.Enabled:=.F.
         WinBRcum1.D_FEntCD.Enabled:=.F.
      ENDIF
   ELSE
      WinBRcum1.C_SiEntCD.Enabled:=.F.
      WinBRcum1.T_CEntCD.Enabled :=.F.
      WinBRcum1.D_FEntCD.Enabled :=.F.
   ENDIF
   IF LLAMADA="RESERVA"
      RETURN
   ENDIF
   ***FIN reserva***

   IF UPPER(PROCNAME(1))<>"NUEVO"
      WinBRcum1.RegNuevo.Value   := 0
   ENDIF
   WinBRcum1.BR_Cum1.Enabled     := IF(Modifcum1= .T. , .F. , .T. )
   WinBRcum1.D_Feccum.Enabled    := Modifcum1
   WinBRcum1.T_Horacum.Enabled   := Modifcum1
   WinBRcum1.D_Fecnac.Enabled    := Modifcum1
   WinBRcum1.T_CodAlu.Enabled    := .F.
   WinBRcum1.T_Nomcum.Enabled    := Modifcum1
   WinBRcum1.T_NomMadre.Enabled  := Modifcum1
   WinBRcum1.T_Invi.Enabled      := Modifcum1
   WinBRcum1.T_Amigos.Enabled    := Modifcum1
   WinBRcum1.T_Confir.Enabled    := Modifcum1
   WinBRcum1.T_Papas.Enabled     := Modifcum1
   WinBRcum1.T_Tel1.Enabled      := Modifcum1
   WinBRcum1.T_Rbo.Enabled       := .F.
   WinBRcum1.C_Promocion.Enabled := Modifcum1

   IF Modifcum1 = .T.
      WinBRcum1.Bt_Nuevo.Enabled   := .F.
      WinBRcum1.Bt_Modif.Enabled   := .F.
      WinBRcum1.Bt_Guardar.Enabled := .T.
      WinBRcum1.Bt_Cancelar.Enabled:= .T.
      IF WinBRcum1.RegNuevo.Value=0
         WinBRcum1.Bt_Elim.Enabled    := .T.
      ELSE
         WinBRcum1.Bt_Elim.Enabled    := .F.
      ENDIF
      WinBRcum1.Bt_Salir.Enabled   := .F.
      WinBRcum1.Bt_MesAnt.Enabled  := .F.
      WinBRcum1.Bt_SemAnt.Enabled  := .F.
      WinBRcum1.Bt_VerHoy.Enabled  := .F.
      WinBRcum1.Bt_SemSig.Enabled  := .F.
      WinBRcum1.Bt_MesSig.Enabled  := .F.
      WinBRcum1.T_Confir.SetFocus
   ELSE
      WinBRcum1.Bt_Nuevo.Enabled   := .T.
      WinBRcum1.Bt_Modif.Enabled   := IF(WinBRcum1.BR_cum1.Value=0,.F.,.T.)
      WinBRcum1.Bt_Guardar.Enabled := .F.
      WinBRcum1.Bt_Cancelar.Enabled:= .F.
      WinBRcum1.Bt_Elim.Enabled    := .F.
      WinBRcum1.Bt_Salir.Enabled   := .T.
      WinBRcum1.Bt_MesAnt.Enabled  := .T.
      WinBRcum1.Bt_SemAnt.Enabled  := .T.
      WinBRcum1.Bt_VerHoy.Enabled  := .T.
      WinBRcum1.Bt_SemSig.Enabled  := .T.
      WinBRcum1.Bt_MesSig.Enabled  := .T.
   ENDIF
   VerSemanaCumple(WinBRcum1.D_Feccum.value)

RETURN


PROCEDURE Guardarcum1()

   AbrirDBF("cumple")

   IF WinBRcum1.RegNuevo.Value=1
      APPEND BLANK
   ELSE
      GO WinBRcum1.BR_cum1.Value
      IF MSGYESNO("¡Atencion!"+chr(13)+chr(10)+ ;
               "¿Desea modificar los datos del cumple?")=.F.
         RETURN
      ENDIF
   ENDIF

IF RLOCK()
   IF WinBRcum1.RegNuevo.Value=1
      REPLACE FECALTA WITH DATE()
      REPLACE HORALTA WITH TIME()
   ELSE
      REPLACE FECMODIF WITH DATE()
      REPLACE HORMODIF WITH TIME()
   ENDIF
   REPLACE FECCUM WITH WinBRcum1.D_Feccum.value
   REPLACE HORACUM WITH WinBRcum1.T_Horacum.value
   REPLACE FECNAC WITH WinBRcum1.D_Fecnac.value
   REPLACE CODALU WITH WinBRcum1.T_CodAlu.value
   REPLACE NOMCUM WITH WinBRcum1.T_Nomcum.value
   REPLACE NOMMADRE WITH WinBRcum1.T_NomMadre.value
   REPLACE INVITACION WITH WinBRcum1.T_Invi.value
   REPLACE AMIGOS WITH WinBRcum1.T_Amigos.value
   REPLACE CONFIR WITH WinBRcum1.T_Confir.value
   REPLACE PAPAS  WITH WinBRcum1.T_Papas.value
   REPLACE TEL1   WITH WinBRcum1.T_Tel1.value
   REPLACE SIRESERVA WITH WinBRcum1.C_SiReserva.value
   REPLACE IMPRESERVA WITH WinBRcum1.T_ImpReserva.value
   IF FIELD->SIRESERVA=.T.
      REPLACE FRESERVA WITH WinBRcum1.D_Freserva.value
   ELSE
      REPLACE FRESERVA WITH CTOD("  -  -    ")
   ENDIF
   REPLACE FOTOSCD WITH WinBRcum1.C_FotosCD.Value
   REPLACE SIENTCD WITH WinBRcum1.C_SiEntCD.value
   REPLACE CENTCD WITH WinBRcum1.T_CEntCd.value
   IF FIELD->SIENTCD=.T.
      REPLACE FENTCD WITH WinBRcum1.D_FEntCd.value
   ELSE
      REPLACE FENTCD WITH CTOD("  -  -    ")
   ENDIF
   REPLACE PROMOCION WITH WinBRcum1.C_Promocion.Value

   DBCOMMIT()
   DBUNLOCK()
   MsgInfo('Los datos han sido guardados en fecha: '+DIA(FIELD->FECCUM,10),'Datos guardados')
   WinBRcum1.BR_cum1.Value:=RECNO()
   WinBRcum1.BR_cum1.Refresh
ELSE
   MsgStop('No se han podigo guardar los datos - '+CHR(13)+ ;
        'El registro esta siendo utilizado por otro usuario'+CHR(13)+ ;
        'Por favor, intentelo mas tarde','Error')
ENDIF

   Modifcum1(.f.)

RETURN


PROCEDURE Actualiz_cumple(LLAMADA)
   AbrirDBF("cumple")

   IF LLAMADA="BROWSE" .OR. LLAMADA="CANCELAR"
      GO WinBRcum1.BR_cum1.Value
   ENDIF

   IF .NOT. EOF()
      WinBRcum1.FecNuevo.Value    :=FIELD->FECCUM
      WinBRcum1.D_Feccum.value    :=FIELD->FECCUM
      WinBRcum1.T_Horacum.value   :=FIELD->HORACUM
      WinBRcum1.D_Fecnac.value    :=FIELD->FECNAC
      WinBRcum1.T_CodAlu.value    :=FIELD->CODALU
      WinBRcum1.T_Nomcum.value    :=FIELD->NOMCUM
      WinBRcum1.T_NomMadre.value  :=FIELD->NOMMADRE
      WinBRcum1.T_Invi.value      :=FIELD->INVITACION
      WinBRcum1.T_Amigos.value    :=FIELD->AMIGOS
      WinBRcum1.T_Confir.value    :=FIELD->CONFIR
      WinBRcum1.T_Papas.value     :=FIELD->PAPAS
      WinBRcum1.T_Tel1.value      :=FIELD->TEL1
      WinBRcum1.C_SiReserva.value :=FIELD->SIRESERVA
      WinBRcum1.T_ImpReserva.value:=FIELD->IMPRESERVA
      WinBRcum1.D_Freserva.value  :=FIELD->FRESERVA
      WinBRcum1.C_FotosCD.Value   :=FIELD->FOTOSCD
      WinBRcum1.C_SiEntCD.value   :=FIELD->SIENTCD
      WinBRcum1.T_CEntCD.value    :=FIELD->CENTCD
      WinBRcum1.D_FEntCD.value    :=FIELD->FENTCD
      WinBRcum1.T_Rbo.value       :=FIELD->CODRBO
      WinBRcum1.C_Promocion.Value :=FIELD->PROMOCION
   ELSE
      WinBRcum1.FecNuevo.Value    := DATE()
      WinBRcum1.D_Feccum.value    := CTOD("  -  -  ")
      WinBRcum1.T_Horacum.value   := ""
      WinBRcum1.D_Fecnac.value    := CTOD("  -  -  ")
      WinBRcum1.T_CodAlu.value    := 0
      WinBRcum1.T_Nomcum.value    := ""
      WinBRcum1.T_NomMadre.value  := ""
      WinBRcum1.T_Invi.value      := 0
      WinBRcum1.T_Amigos.value    := 0
      WinBRcum1.T_Confir.value    := 0
      WinBRcum1.T_Papas.value     := 0
      WinBRcum1.T_Tel1.value      := ""
      WinBRcum1.C_SiReserva.value := .F.
      WinBRcum1.T_ImpReserva.value:= 0
      WinBRcum1.D_Freserva.value  := CTOD("  -  -  ")
      WinBRcum1.C_FotosCD.Value   := .F.
      WinBRcum1.C_SiEntCD.value   := .F.
      WinBRcum1.T_CEntCD.value    := ""
      WinBRcum1.D_FEntCD.value    := CTOD("  -  -  ")
      WinBRcum1.T_Rbo.value       := 0
      WinBRcum1.C_Promocion.Value :=.F.
   ENDIF

   Modifcum1(.f.)

RETURN


PROCEDURE Eliminar_cumple()
   AbrirDBF("cumple")
   IF WinBRcum1.BR_cum1.Value=0
      MsgStop("No ha selecionado ningun registro","Error")
   ELSE
      IF MsgYesNo("¿Desea eliminar el registro activo?","Atencion")
         GO WinBRcum1.BR_cum1.Value
         IF RLOCK()
            DELETE
            SKIP
            IF EOF()
               GO BOTT
            ENDIF
            DBCOMMIT()
            DBUNLOCK()
            WinBRcum1.BR_cum1.Value:=RECNO()
            WinBRcum1.BR_cum1.Refresh
            VerSemanaCumple(DIACAR(WinBRcum1.CabDia1.value))
         ELSE
            MsgStop('No se han podigo eliminar el registro'+CHR(13)+ ;
               'El registro esta siendo utilizado por otro usuario'+CHR(13)+ ;
               'Por favor, intentelo mas tarde','Error')
         ENDIF
      ENDIF
   ENDIF

RETURN


PROCEDURE VerSemanaCumple(FEC2,LLAMADA)
   LOCAL N, DATOS2, LAMADA:=IF(LLAMADA=NIL,' ',LLAMADA)

   IF YEAR(FEC2)=0
      RETURN
   ENDIF
***Esta en la segunda semana***
   IF LLAMADA<>"Bt_SemSig"
      IF FEC2-DIACAR(WinBRcum1.CabDia1.Value)>=7 .AND. FEC2-DIACAR(WinBRcum1.CabDia1.Value)<=13
         FEC2:=FEC2-7
      ENDIF
      IF FEC2-DIACAR(WinBRcum1.CabDia1.Value)>=14 .AND. FEC2-DIACAR(WinBRcum1.CabDia1.Value)<=20
         FEC2:=FEC2-14
      ENDIF
      IF FEC2-DIACAR(WinBRcum1.CabDia1.Value)>=21 .AND. FEC2-DIACAR(WinBRcum1.CabDia1.Value)<=27
         FEC2:=FEC2-21
      ENDIF
   ENDIF
***FIN Esta en la segunda semana***
   FOR N= 1 TO 7
      IF UPPER(DIANOM(FEC2))="LUNES"
         EXIT
      ENDIF
      FEC2:=FEC2-1
   NEXT
   IF UPPER(DIANOM(FEC2))<>"LUNES"
      RETURN
   ENDIF

***Resaltar la fecha actual***
   FOR N=1 TO 28
      IF DATE()=FEC2+N-1
         SetProperty("WinBRcum1","Dia"+LTRIM(STR(N)),"BACKCOLOR",MiColor("ROJO"))
      ELSE
         SetProperty("WinBRcum1","Dia"+LTRIM(STR(N)),"BACKCOLOR",MiColor("ROSACLARO"))
      ENDIF
   NEXT
***FIN Resaltar la fecha actual***

   FOR N=1 TO 28
      SetProperty("WinBRcum1","CabDia"+LTRIM(STR(N)),"Value",DIA(FEC2+N-1,11))
      IF DIAFIESTA(FEC2+N-1) .OR. UPPER(DIANOM(FEC2+N-1))="DOMINGO"
         SetProperty("WinBRcum1","CabDia"+LTRIM(STR(N)),"BACKCOLOR",MiColor("ROSAPALIDO"))
      ELSE
         SetProperty("WinBRcum1","CabDia"+LTRIM(STR(N)),"BACKCOLOR",MiColor("CIAN"))
      ENDIF
      DATOS2:=DatosCumpleHoy(FEC2+N-1)
      IF DATOS2[1]<>0
         SetProperty("WinBRcum1","CumDia"+LTRIM(STR(N)),"Value",'Cumple: '+LTRIM(STR(DATOS2[1])) )
         IF DATOS2[5]=0
            SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"Value", ;
            'Niños: ' +LTRIM(STR(DATOS2[3]))+"/"+LTRIM(STR(DATOS2[2])) +chr(13)+chr(10)+ ;
            'Papas: ' +LTRIM(STR(DATOS2[4])) )
         ENDIF
      ELSE
         SetProperty("WinBRcum1","CumDia"+LTRIM(STR(N)),"Value","" )
         SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"Value","" )
      ENDIF
      DO CASE
      CASE DATOS2[1]<=0
         SetProperty("WinBRcum1","CumDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("Blanco") )
         SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("Blanco") )
      CASE DATOS2[1]=1
         SetProperty("WinBRcum1","CumDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("VERDEPALIDO") )
         SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("VERDEPALIDO") )
      CASE DATOS2[1]=2
         SetProperty("WinBRcum1","CumDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("AMARILLOCUMPLE") )
         SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("AMARILLOCUMPLE") )
      CASE DATOS2[1]>=3
         SetProperty("WinBRcum1","CumDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("ROJOCUMPLE") )
         SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("ROJOCUMPLE") )
      ENDCASE
      IF DATOS2[5]<>0
         SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("GRISCLARO") )
      ENDIF
   NEXT

***Resaltar la fecha del browse***
   FOR N=1 TO 28
      IF WinBRcum1.D_Feccum.Value=FEC2+N-1
         SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"BACKCOLOR",MiColor("NARANJAFUERTE"))
      ENDIF
   NEXT
***FIN Resaltar la fecha del browse***

RETURN


FUNCTION DatosCumpleHoy(FEC3)
   LOCAL NCUM2:=0
   LOCAL NCON2:=0
   LOCAL NAMI2:=0
   LOCAL NPAP2:=0
   LOCAL NNOC2:=0
   LOCAL NEDU2:=0
   LOCAL DATOS
   AbrirDBF("cumple")

   SEEK DTOS(FEC3)
   DO WHILE FIELD->FECCUM=FEC3
      NCUM2++
      NAMI2:=NAMI2+FIELD->AMIGOS
      NCON2:=NCON2+FIELD->CONFIR
      NPAP2:=NPAP2+FIELD->PAPAS
      IF FIELD->NOCUMPLE<>0
         NNOC2:=FIELD->NOCUMPLE
      ENDIF
      IF FIELD->EDUCADORA<>0
         NEDU2:=FIELD->EDUCADORA
      ENDIF
      SKIP
   ENDDO

   DATOS:={NCUM2,NAMI2,NCON2,NPAP2,NNOC2,NEDU2}

RETURN(DATOS)


PROCEDURE Ir_Cumple(IRFEC2)
   LOCAL FEC2, N
   AbrirDBF("cumple")
*   SET SOFTSEEK ON
   SEEK DTOS(IRFEC2)
*   SET SOFTSEEK OFF
   IF .NOT. EOF()
      WinBRcum1.BR_cum1.Value := RECNO()
      WinBRcum1.BR_cum1.Refresh
   ENDIF

   WinBRcum1.FecNuevo.Value:=IRFEC2 //SIEMPRE DESPUES DE WinBRcum1.BR_cum1.Value
***Resaltar la fecha del raton***
   FEC2:=DIACAR( GetProperty("WinBRcum1","CabDia1","Value") )
   FOR N=1 TO 28
      IF WinBRcum1.FecNuevo.Value=FEC2+N-1 .AND. WinBRcum1.D_Feccum.Value<>FEC2+N-1
         SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("AMARILLO"))
      ELSE
         IF LEN(LTRIM(GetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"Value")))=0
            SetProperty("WinBRcum1","CueDia"+LTRIM(STR(N)),"BACKCOLOR",MICOLOR("BLANCO"))
         ENDIF
      ENDIF
   NEXT
***FIN Resaltar la fecha del raton***

RETURN
*------------------------------ Archivos --------------------------------------*
***libreria***
#Include "l_abrir.prg"
#Include "l_color.prg"
#Include "l_dia.prg"
#Include "l_festa.prg"
