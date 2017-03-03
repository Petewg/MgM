/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2013 Dr. Eduardo Luis Azar <elalegal@yahoo.com.ar>
*/

#include <hmg.ch>

STATIC Nuevo := .F.		
STATIC pantadat := "1" 
STATIC recitip := 1
STATIC jacinto, jeranio, alfa

FIELD NOMBRE,DIRECCION,LOCALIDAD,PAIS,CODPOST,;
   MAIL,PROFESIO,RELACION,TELE1,TELE2,TELE3,;
   TELE4,TELE5,TELE6,TELE7,OBSERV1,OBSERV2,OBSERTO

PROCEDURE Main
   
   REQUEST DBFCDX
   RDDSETDEFAULT( "DBFCDX" )
   
   SET DATE BRITISH
   SET CENTURY ON

   SET TOOLTIPSTYLE BALLOON 
   SET NAVIGATION EXTENDED
	
   USE AGENDA SHARED NEW
   IF !FILE('AGENDA.CDX')
      INDEX ON UPPER(nombre) TAG (nombre) TO (Alias())
   ENDIF
   SET ORDER TO TAG (nombre)
   GO TOP

	DEFINE WINDOW Win_1			;
		AT 0,0				;
		WIDTH 1024			;
		HEIGHT 768			;
		TITLE 'PHONE BOOK'		;
		ICON 'WINDOW.ICO'		;
		MAIN				;
		BACKCOLOR {218,229,243} 	;
		NOSYSMENU			;
		NOSIZE				;
		ON INIT Actualizar()		;
		ON RELEASE CerrarTablas()

      DEFINE IMAGE Image_21
         ROW	 0
         COL	 0
         WIDTH	 1024
         HEIGHT  133
         PICTURE 'ribbon1'
         STRETCH .T.
      END IMAGE         

      DEFINE IMAGE Image_22
         ROW	 0
         COL	 0
         WIDTH	 1024
         HEIGHT  133
         PICTURE 'ribbon2'
         STRETCH .T.
      END IMAGE         

      Win_1.Image_22.HIDE   
         
// MESSAGES TO THE USER

      @ 09,184 LABEL Label_EJI1 ;
         WIDTH 550 HEIGHT 20 ;
         VALUE ' Looking selected file.' ;
         FONT 'Calibri' SIZE 11 ;
         FONTCOLOR { 238,0,0 } ;
         TRANSPARENT VCENTERALIGN

      @ 09,184 LABEL Label_EJI2 ;
         WIDTH 550 HEIGHT 20 ;
         VALUE ' New: Press "Cancel" to abort.' ;
         FONT 'Calibri' SIZE 11 ;
         FONTCOLOR { 238,0,0 } ;
         TRANSPARENT VCENTERALIGN

      Win_1.LABEL_EJI2.HIDE

      @ 09,184 LABEL Label_EJI3 ;
         WIDTH 550 HEIGHT 20 ;
         VALUE ' Editing file: Press "Cancel" to abort.' ;
         FONT 'Calibri' SIZE 11 ;
         FONTCOLOR { 238,0,0 } ;
         TRANSPARENT VCENTERALIGN

      Win_1.LABEL_EJI3.HIDE
      
      @ 09,184 LABEL Label_EJI4 ;
         WIDTH 550 HEIGHT 20 ;
         VALUE ' Searching persons.' ;
         FONT 'Calibri' SIZE 11 ;
         FONTCOLOR { 238,0,0 } ;
         TRANSPARENT VCENTERALIGN

      Win_1.LABEL_EJI4.HIDE
      
      @ 09,184 LABEL Label_EJI5 ;
         WIDTH 550 HEIGHT 20 ;
         VALUE ' Deleting file: Warning. Delete will be permanent.' ;
         FONT 'Calibri' SIZE 11 ;
         FONTCOLOR { 238,0,0 } ;
         TRANSPARENT VCENTERALIGN

      Win_1.LABEL_EJI5.HIDE

         
      @ 09,80 LABEL Label_TITACC ;
         WIDTH 200 HEIGHT 15 ;
         VALUE ' Executing' ;
         FONT 'Calibri' SIZE 9 ;
         FONTCOLOR { 0,0,128 } ;
         TRANSPARENT
      
// END MESSAGES TO USER

// BEGIN SIMULATED RIBBON ACTIONS         

       @ 70,10 LABEL Label_A1 ;
          WIDTH 45 HEIGHT 37 ;
          VALUE '' ;
          ACTION ( dBGoTop() , Win_1.grid_1.Value := RecNo() ) ;
          TOOLTIP 'Go to first register' ;
          TRANSPARENT 

       @ 70,67 LABEL Label_A2 ;
          WIDTH 45HEIGHT 37 ;
          VALUE '' ;
          ACTION ( dBSkip ( -1 ) , Win_1.grid_1.Value := RecNo() ) ;
          TOOLTIP 'Go to previous register' ;
          TRANSPARENT 

       @ 70,122 LABEL Label_A3 ;
          WIDTH 47 HEIGHT 37 ;
          VALUE '' ;
          ACTION ( dBSkip (1) , if ( Eof() , DbGoBottom() , Nil ) , Win_1.grid_1.Value := RecNo() ) ;
          TOOLTIP 'Go to next register' ;
          TRANSPARENT 

       @ 70,179 LABEL Label_A4 ;
          WIDTH 45 HEIGHT 37 ;
          VALUE '' ;
          ACTION ( dBGoBottom () , Win_1.grid_1.Value := RecNo() ) ;
          TOOLTIP 'Go to last register' ;
          TRANSPARENT 

       @ 70,242 LABEL Label_A5 ;
          WIDTH 45 HEIGHT 37 ;
          VALUE '' ;
          ACTION ( Nuevo := .T. , Avialta() , Editando() , Nuevo()  ) ;
          TOOLTIP 'Input New register' ;
          TRANSPARENT 

       @ 70,298 LABEL Label_A6 ;
          WIDTH 45 HEIGHT 37 ;
          VALUE '' ;
          ACTION iif( BloquearRegistro() , ( Aviedit() , Editando() , ActivarEdicion() ), Nil ) ;
          TOOLTIP 'Edit selected register' ;
          TRANSPARENT 

       @ 70,354 LABEL Label_A7 ;
          WIDTH 45 HEIGHT 37 ;
          VALUE '' ;
          ACTION ( Avibaja() , Eliminar() ) ;
          TOOLTIP 'Delete selected register' ;
          TRANSPARENT 

       @ 70,411 LABEL Label_A8 ;
          WIDTH 45 HEIGHT 37 ;
          VALUE '' ;
          ACTION ( Avibusq() , REBUSCAR() ) ;
          TOOLTIP 'Search register' ;
          TRANSPARENT 

       @ 70,474 LABEL Label_A9 ;
          WIDTH 45 HEIGHT 37 ;
          VALUE '' ;
          ACTION ( AceptarEdicion() , reclasificar() , rehabilita() , Avivis() ) ;
          TOOLTIP 'Save new / changes' ;
          TRANSPARENT 

       Win_1.Label_A9.ENABLED := .F.
          
       @ 70,531 LABEL Label_A10 ;
          WIDTH 45 HEIGHT 37 ;
          VALUE '' ;
          ACTION ( CancelarEdicion() , rehabilita() , Avivis()  ) ;
          TOOLTIP 'Cancel new / changes' ;
          TRANSPARENT 

       Win_1.Label_A10.ENABLED := .F.          
          
      @ 05,994 LABEL Label_Exit1 ;
          WIDTH 22 HEIGHT 22 ;
          VALUE '' ;
          ACTION gransalida() ;
          TOOLTIP 'Quit' ;
          TRANSPARENT 

      @ 20,15 LABEL Label_ACERCA ;
         WIDTH 30 HEIGHT 30 ;
         VALUE '' ;
         ACTION acercade() ;
         TOOLTIP 'About.....' ;
         TRANSPARENT 

// END RIBBON SIMULATED ACTIONS

// PRINCIPAL CONTROLS
         
		@ 224,112 BROWSE grid_1				;
			WIDTH 205 				;
			HEIGHT 392 				;	
			HEADERS { 'First & Last Names' }	;
			WIDTHS { 180 }				;
			BACKCOLOR {250,250,210}			;
			WORKAREA AGENDA				;
			FIELDS { 'AGENDA->NOMBRE' } 		;
			ON CHANGE Actualizar()			;
			ON DBLCLICK iif( BloquearRegistro(), ( Aviedit() , Editando() , ActivarEdicion() ), Nil )

	DEFINE STATUSBAR 
         STATUSITEM 'Dr. Eduardo Luis Azar (®) - Copyright 2013' WIDTH 250
         CLOCK WIDTH 80
         DATE WIDTH 100
         STATUSITEM ' ' WIDTH 50 ICON 'WINDOW.ICO'
	END STATUSBAR

	@ 227 , 342 LABEL LABEL_T1 ;
	VALUE 'Person in process: ';
	WIDTH 200 ;
         TRANSPARENT
         
	@ 225 , 462 TEXTBOX Control_T1 ;
	WIDTH 440 ;
	MAXLENGTH 25 ;
         BACKCOLOR {250,250,210} ;
         FONTCOLOR {0,0,0 } ;
         FONT "Arial" SIZE 9 ;
	BOLD 

		DEFINE TAB Tab_1 ;
			AT 258,337 ;
			WIDTH 570 ;
			HEIGHT 358 ;
			VALUE 1 ;
			BACKCOLOR {218,229,243} ;
			TOOLTIP 'Multiple Data Options' 

			PAGE 'Personal Data' 
				@ 32, 10   LABEL LABEL_M1  VALUE 'Name:' WIDTH 85 TRANSPARENT
				@ 32, 400  LABEL LABEL_M2  VALUE 'Home 1:' WIDTH 50 TRANSPARENT
				@ 55, 10   LABEL LABEL_M3  VALUE 'Address:' WIDTH 65 TRANSPARENT
				@ 55, 400  LABEL LABEL_M4  VALUE 'Home 2:' WIDTH 50 TRANSPARENT
				@ 80, 10   LABEL LABEL_M5  VALUE 'City:' WIDTH 65 TRANSPARENT
				@ 80, 400  LABEL LABEL_M6  VALUE 'Office 1:' WIDTH 50 TRANSPARENT
				@ 104, 10  LABEL LABEL_M7  VALUE 'Country:' WIDTH 65 TRANSPARENT
				@ 104, 400 LABEL LABEL_M8  VALUE 'Office 2:' WIDTH 50 TRANSPARENT
				@ 128, 10  LABEL LABEL_M9  VALUE 'ZIP:' WIDTH 65 TRANSPARENT
				@ 128, 400 LABEL LABEL_M10 VALUE 'Familiar:'  WIDTH 50 TRANSPARENT
				@ 152, 10  LABEL LABEL_M11 VALUE 'Profession:' WIDTH 65 TRANSPARENT
				@ 152, 400 LABEL LABEL_M12 VALUE 'Cel. 1:' WIDTH 50 TRANSPARENT
				@ 176, 10  LABEL LABEL_M13 VALUE 'Relation:' WIDTH 65 TRANSPARENT
				@ 176, 400 LABEL LABEL_M14 VALUE 'Cel. 2:' WIDTH 50 TRANSPARENT
				@ 200, 10  LABEL LABEL_M15 VALUE 'Email:' WIDTH 65 TRANSPARENT
				@ 252, 10  LABEL LABEL_M16 VALUE 'Reference 1:' WIDTH 85 TRANSPARENT
				@ 276, 10  LABEL LABEL_M17 VALUE 'Reference 2:' WIDTH 85 TRANSPARENT
				@ 310, 10  LABEL LABEL_M18 VALUE 'Notes:' WIDTH 85 TRANSPARENT

            DEFINE FRAME Frame_1	
               ROW 	230
               COL	5
               CAPTION  'Notes: ' 
               WIDTH    560 
               HEIGHT   120
               BACKCOLOR {218,229,243}
            END FRAME

				@ 30,95 TEXTBOX Control_M1 ;
					HEIGHT 20 ;
					WIDTH 300 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 40 ;
					UPPERCASE

				@ 54,95 TEXTBOX Control_M2 ;
					HEIGHT 20 ;
					WIDTH 300 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 40 ;
					UPPERCASE

				@ 78,95 TEXTBOX Control_M3 ;
					HEIGHT 20 ;
					WIDTH 300 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 40 ;
					UPPERCASE
					

				@ 102 , 95 TEXTBOX Control_M4 ;
					HEIGHT 20 ;
					WIDTH 300 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 40 ;
					UPPERCASE

				@ 126, 95 TEXTBOX Control_M5 ;
					HEIGHT 20 ;
					WIDTH 50 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 7;
					UPPERCASE

				@ 150, 95 TEXTBOX Control_M7 ;
					HEIGHT 20 ;
					WIDTH 300 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 50;
					UPPERCASE

				@ 174, 95 TEXTBOX Control_M8 ;
					HEIGHT 20 ;
					WIDTH 300 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 50 ;
					UPPERCASE

				@ 198, 95 TEXTBOX Control_M6 ;
					HEIGHT 20 ;
					WIDTH 470 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 50 ;
					UPPERCASE

				@ 30,452 TEXTBOX Control_M9 ;
 					HEIGHT 20 ;
 					WIDTH 113 ;
 					FONT "Arial" SIZE 9 ;
 					BOLD ;
 					BACKCOLOR {250,250,210} ;
					MAXLENGTH 16

 				@ 54,452 TEXTBOX Control_M10 ;
 					HEIGHT 20 ;
 					WIDTH 113 ;
 					FONT "Arial" SIZE 9 ;
 					BOLD ;
 					BACKCOLOR {250,250,210} ;
					MAXLENGTH 16
               
				@ 78,452 TEXTBOX Control_M11 ;
 					HEIGHT 20 ;
 					WIDTH 113 ;
 					FONT "Arial" SIZE 9 ;
 					BOLD ;
 					BACKCOLOR {250,250,210} ;
					MAXLENGTH 16

				@ 102,452 TEXTBOX Control_M12 ;
 					HEIGHT 20 ;
 					WIDTH 113 ;
 					FONT "Arial" SIZE 9 ;
 					BOLD ;
 					BACKCOLOR {250,250,210} ;
					MAXLENGTH 16

				@ 126,452 TEXTBOX Control_M13 ;
 					HEIGHT 20 ;
 					WIDTH 113 ;
 					FONT "Arial" SIZE 9 ;
 					BOLD ;
 					BACKCOLOR {250,250,210} ;
					MAXLENGTH 16
               
				@ 150,452 TEXTBOX Control_M14 ;
 					HEIGHT 20 ;
 					WIDTH 113 ;
 					FONT "Arial" SIZE 9 ;
 					BOLD ;
 					BACKCOLOR {250,250,210} ;
					INPUTMASK '(99) 9999-9999'

				@ 174,452 TEXTBOX Control_M15 ;
 					HEIGHT 20 ;
 					WIDTH 113 ;
 					FONT "Arial" SIZE 9 ;
 					BOLD ;
 					BACKCOLOR {250,250,210} ;
					INPUTMASK '(99) 9999-9999'

				@ 250, 95 TEXTBOX Control_M16 ;
					HEIGHT 20 ;
					WIDTH 460 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 50 ;
					UPPERCASE

				@ 274, 95 TEXTBOX Control_M17 ;
					HEIGHT 20 ;
					WIDTH 460 ;
					FONT "Arial" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 50 ;
					UPPERCASE

				@ 298,95 EDITBOX CONTROL_M18 ;
					WIDTH 460 ;
					HEIGHT 45 ;
					FONT "ARIAL" SIZE 9 ;
					BOLD ;
					BACKCOLOR {250,250,210} ;
					MAXLENGTH 5000 ;
					NOHSCROLL
               
			END PAGE
/*
			PAGE 'Future Extensions I' 
			END PAGE
			PAGE 'Future Extensions II' 
			END PAGE
			PAGE 'Future Extensions III' 
			END PAGE
*/
			
		END TAB

		ON KEY ALT+X ACTION ThisWindow.Release()
	END WINDOW

	SET TOOLTIP BACKCOLOR TO { 250, 250, 210 } OF Win_1

	DesactivarEdicion()

	Win_1.grid_1.SetFocus

	Win_1.grid_1.Value := AGENDA->( RecNo() )
	
	CENTER WINDOW Win_1

	ACTIVATE WINDOW Win_1

RETURN

*------------------------------------------------------------------------------*
PROCEDURE AbrirTablas
*------------------------------------------------------------------------------*
	USE AGENDA INDEX AGENDA
	GO TOP
RETURN

*------------------------------------------------------------------------------*
PROCEDURE CerrarTablas
*------------------------------------------------------------------------------*
	CLOSE AGENDA
RETURN

*------------------------------------------------------------------------------*
PROCEDURE DesactivarEdicion
*------------------------------------------------------------------------------*
	Win_1.grid_1.Enabled		:= .T.
	Win_1.Control_T1.Enabled	:= .F.
	Win_1.Control_M1.ENABLED	:= .F.
	Win_1.Control_M2.ENABLED	:= .F.
	Win_1.Control_M3.ENABLED	:= .F.
	Win_1.Control_M4.ENABLED	:= .F.
	Win_1.Control_M5.ENABLED	:= .F.
	Win_1.Control_M6.ENABLED	:= .F.
	Win_1.Control_M7.ENABLED	:= .F.
	Win_1.Control_M8.ENABLED	:= .F.
	Win_1.Control_M9.ENABLED	:= .F.
	Win_1.Control_M10.ENABLED	:= .F.
	Win_1.Control_M11.ENABLED	:= .F.
	Win_1.Control_M12.ENABLED	:= .F.
	Win_1.Control_M13.ENABLED	:= .F.
	Win_1.Control_M14.ENABLED	:= .F.
	Win_1.Control_M15.ENABLED	:= .F.
	Win_1.Control_M16.ENABLED	:= .F.
	Win_1.Control_M17.ENABLED	:= .F.
	Win_1.Control_M18.ENABLED	:= .F.
	Win_1.grid_1.SetFocus
RETURN

*------------------------------------------------------------------------------*
PROCEDURE ActivarEdicion
*------------------------------------------------------------------------------*
	Win_1.grid_1.Enabled		:= .F.
	Win_1.Control_T1.Enabled	:= .F.
	Win_1.Control_M1.ENABLED	:= .T.
	Win_1.Control_M2.ENABLED	:= .T.
	Win_1.Control_M3.ENABLED	:= .T.
	Win_1.Control_M4.ENABLED	:= .T.
	Win_1.Control_M5.ENABLED	:= .T.
	Win_1.Control_M6.ENABLED	:= .T.
	Win_1.Control_M7.ENABLED	:= .T.
	Win_1.Control_M8.ENABLED	:= .T.
	Win_1.Control_M9.ENABLED	:= .T.
	Win_1.Control_M10.ENABLED	:= .T.
	Win_1.Control_M11.ENABLED	:= .T.
	Win_1.Control_M12.ENABLED	:= .T.
	Win_1.Control_M13.ENABLED	:= .T.
	Win_1.Control_M14.ENABLED	:= .T.
	Win_1.Control_M15.ENABLED	:= .T.
	Win_1.Control_M16.ENABLED	:= .T.
	Win_1.Control_M17.ENABLED	:= .T.
	Win_1.Control_M18.ENABLED	:= .T.
	Win_1.Label_A9.Enabled		:= .T.
	Win_1.Label_A10.Enabled		:= .T.
	Win_1.Control_M1.SetFocus
RETURN

*------------------------------------------------------------------------------*
PROCEDURE CancelarEdicion()
*------------------------------------------------------------------------------*
	DesactivarEdicion()
	Actualizar()
	UNLOCK
	Nuevo := .F.
RETURN

*------------------------------------------------------------------------------*
PROCEDURE AceptarEdicion()
*------------------------------------------------------------------------------*
	LOCAL nNuevoRecNo
	DesactivarEdicion()
	If Nuevo == .T.
		AGENDA->(DbAppend())
	Else
		AGENDA->( dbGoTo ( Win_1.grid_1.Value ) )
	EndIf

	nNuevoRecNo := AGENDA->( RecNo() )

	AGENDA->NOMBRE	   := Win_1.Control_M1.Value
	AGENDA->DIRECCION	:= Win_1.Control_M2.Value
	AGENDA->LOCALIDAD	:= Win_1.Control_M3.Value
	AGENDA->PAIS    	:= Win_1.Control_M4.Value
	AGENDA->CODPOST	:= Win_1.Control_M5.Value
	AGENDA->PROFESIO	:= Win_1.Control_M7.Value
	AGENDA->RELACION  := Win_1.Control_M8.Value
	AGENDA->MAIL	   := Win_1.Control_M6.Value
	AGENDA->TELE1     := Win_1.Control_M9.Value
	AGENDA->TELE2     := Win_1.Control_M10.Value
	AGENDA->TELE3  	:= Win_1.Control_M11.Value
	AGENDA->TELE4	   := Win_1.Control_M12.Value
	AGENDA->TELE5   	:= Win_1.Control_M13.Value
	AGENDA->TELE6	   := Win_1.Control_M14.Value
	AGENDA->TELE7   	:= Win_1.Control_M15.Value
	AGENDA->OBSERV1	:= Win_1.Control_M16.Value
	AGENDA->OBSERV2	:= Win_1.Control_M17.Value
	AGENDA->OBSERTO	:= Win_1.Control_M18.Value

	If Nuevo == .T.
		Win_1.grid_1.Value := nNuevoRecNo
		Nuevo := .F.
	Else
		Win_1.grid_1.Value := alfa
	EndIf

	UNLOCK
	Win_1.grid_1.Refresh

RETURN

*------------------------------------------------------------------------------*
PROCEDURE Nuevo()
*------------------------------------------------------------------------------*
	Win_1.Control_T1.Value  := ''
	Win_1.Control_M1.Value	:= ''
	Win_1.Control_M2.Value	:= ''
	Win_1.Control_M3.Value	:= ''
	Win_1.Control_M4.Value	:= ''
	Win_1.Control_M5.Value	:= ''
	Win_1.Control_M6.Value	:= ''
	Win_1.Control_M7.Value	:= ''
	Win_1.Control_M8.Value	:= ''
	Win_1.Control_M9.Value  := ''
	Win_1.Control_M10.Value	:= ''
	Win_1.Control_M11.Value	:= ''
  	Win_1.Control_M12.Value	:= ''
	Win_1.Control_M13.Value	:= ''
	Win_1.Control_M14.Value	:= ''
	Win_1.Control_M15.Value	:= ''
	Win_1.Control_M16.Value	:= ''
	Win_1.Control_M17.Value	:= ''
	Win_1.Control_M18.Value	:= ''
	ActivarEdicion()

RETURN

*------------------------------------------------------------------------------*
PROCEDURE Actualizar()
*------------------------------------------------------------------------------*
	AGENDA->( dbGoTo ( Win_1.grid_1.Value ) )
	Win_1.Control_T1.Value  := AGENDA->NOMBRE	
	Win_1.Control_M1.Value	:= AGENDA->NOMBRE
	Win_1.Control_M2.Value	:= AGENDA->DIRECCION
	Win_1.Control_M3.Value	:= AGENDA->LOCALIDAD
	Win_1.Control_M4.Value	:= AGENDA->PAIS
	Win_1.Control_M5.Value	:= AGENDA->CODPOST
	Win_1.Control_M6.Value	:= AGENDA->MAIL
	Win_1.Control_M7.Value	:= AGENDA->PROFESIO
	Win_1.Control_M8.Value	:= AGENDA->RELACION
	Win_1.Control_M9.Value	:= AGENDA->TELE1
	Win_1.Control_M10.Value	:= AGENDA->TELE2
	Win_1.Control_M11.Value	:= AGENDA->TELE3
	Win_1.Control_M12.Value	:= AGENDA->TELE4
	Win_1.Control_M13.Value	:= AGENDA->TELE5
	Win_1.Control_M14.Value	:= AGENDA->TELE6
	Win_1.Control_M15.Value	:= AGENDA->TELE7
	Win_1.Control_M16.Value	:= AGENDA->OBSERV1
	Win_1.Control_M17.Value	:= AGENDA->OBSERV2
	Win_1.Control_M18.Value	:= AGENDA->OBSERTO
Return

*------------------------------------------------------------------------------*
Function BloquearRegistro()
*------------------------------------------------------------------------------*
	LOCAL RetVal
	alfa :=	Win_1.grid_1.Value
	AGENDA->( dbGoTo ( alfa ) )

	If AGENDA->( RLock() )
		RetVal := .t.
	Else
		MsgExclamation ('This Register has been used by another user. Try later. Thanks')
		RetVal := .f.
	EndIf

Return RetVal

*------------------------------------------------------------------------------*
Procedure Eliminar
*------------------------------------------------------------------------------*
   If MsgYesNo ( 'Are you sure you want to delete this file ?','Deleting Files:')
       AGENDA->(DBDelete())
       PACK
       USE
       AbrirTablas()
       MsgINFO("Person Was Deleted!","Phone Book")	
       ACTUALIZAR()
       Win_1.grid_1.Value := RecNo() 
   EndIf
   AGENDA->(dBGoTop () )
   Win_1.grid_1.Value := RecNo() 
   Win_1.grid_1.Refresh
   Avivis()
Return

*------------------------------------------------------------------------------*
Procedure REBuscar
*------------------------------------------------------------------------------*
   LOCAL elloco, Buscar
   Buscar := Upper ( AllTrim ( InputBox( 'Input any data to begin the search:' , 'Global Search' ) ) )

   If .Not. Empty(Buscar)
      LOCATE FOR TRIM(Buscar) $ (NOMBRE+DIRECCION+LOCALIDAD+PROFESIO+RELACION+TELE1+TELE2+TELE3+TELE4+TELE5+TELE6+TELE7+OBSERV1+OBSERV2+UPPER(TRIM(OBSERTO)))
      DO WHILE FOUND()      
         elloco := RecNo()
         Win_1.grid_1.Value := elloco
         If MsgYesNo( "User: Is this the person you are looking ?"+Chr(13)+Chr(10)+"            Please confirm your decision." + chr(13)+chr(10), "Searching persons." )
            Avivis()
            RETURN
         ELSE
         IF elloco == RECCOUNT()
               MsgExclamation(" No more persons were found with your request."+Chr(13)+Chr(10)+"                    Press OK to quit." + chr(13)+chr(10), "Searching persons." )
               Avivis()
               RETURN
            ELSE 
               CONTINUE
            ENDIF
         ENDIF            
      ENDDO
      MsgExclamation(" No more persons were found with your request."+Chr(13)+Chr(10)+"                    Press OK to quit." + chr(13)+chr(10), "Searching aborted." )
      Avivis()
      RETURN
   Else
      MsgExclamation('No data were input to begin the search.')
      Avivis()
   EndIf
Avivis()
Return

****************************************************************
PROCEDURE gransalida()
****************************************************************

If MsgYesNo( "User: you have chosen quiting system."+Chr(13)+Chr(10)+"            Please confirm your decision." + chr(13)+chr(10), "Quiting Phone Book" )
   Win_1.Release
Endif
RETURN

PROCEDURE ACERCADE
        LOCAL cMessage := CRLF
        cMessage += "                           Phone Book                      " + CRLF
        cMessage += "                     Simple Sample HMG          " + CRLF
        cMessage += "                    Dr. Eduardo Luis Azar          " + CRLF
        cMessage += "                      Argentina - 2013          " + CRLF
        cMessage += "                  elalegal@yahoo.com.ar          " + CRLF
        cMessage += CRLF
        MsgInfo( cMessage, "About Phone Book (®)" )
RETURN

****************************************
PROCEDURE EDITANDO()
****************************************
WIN_1.LABEL_A1.ENABLED    := .F.
WIN_1.LABEL_A2.ENABLED    := .F.
WIN_1.LABEL_A3.ENABLED    := .F.
WIN_1.LABEL_A4.ENABLED    := .F.
WIN_1.LABEL_A5.ENABLED    := .F.
WIN_1.LABEL_A6.ENABLED    := .F.
WIN_1.LABEL_A7.ENABLED    := .F.
WIN_1.LABEL_A8.ENABLED    := .F.
WIN_1.LABEL_EXIT1.ENABLED := .F.
WIN_1.LABEL_A9.ENABLED    := .T.
WIN_1.LABEL_A10.ENABLED   := .T.
RETURN

****************************************
PROCEDURE REHABILITA()
****************************************
WIN_1.LABEL_A1.ENABLED    := .T.
WIN_1.LABEL_A2.ENABLED    := .T.
WIN_1.LABEL_A3.ENABLED    := .T.
WIN_1.LABEL_A4.ENABLED    := .T.
WIN_1.LABEL_A5.ENABLED    := .T.
WIN_1.LABEL_A6.ENABLED    := .T.
WIN_1.LABEL_A7.ENABLED    := .T.
WIN_1.LABEL_A8.ENABLED    := .T.
WIN_1.LABEL_EXIT1.ENABLED := .T.
WIN_1.LABEL_A9.ENABLED    := .F.
WIN_1.LABEL_A10.ENABLED   := .F.
RETURN

***************************************
PROCEDURE AVIVIS()
***************************************
Win_1.Image_22.HIDE   
Win_1.Image_21.SHOW
Win_1.LABEL_EJI2.HIDE   
Win_1.LABEL_EJI3.HIDE   
Win_1.LABEL_EJI4.HIDE   
Win_1.LABEL_EJI5.HIDE   
Win_1.LABEL_EJI1.SHOW
RETURN

***************************************
PROCEDURE AVIALTA()
***************************************
Win_1.Image_21.HIDE   
Win_1.Image_22.SHOW
Win_1.LABEL_EJI1.HIDE   
Win_1.LABEL_EJI3.HIDE   
Win_1.LABEL_EJI4.HIDE   
Win_1.LABEL_EJI5.HIDE   
Win_1.LABEL_EJI2.SHOW
RETURN

***************************************
PROCEDURE AVIEDIT()
Win_1.Image_21.HIDE   
Win_1.Image_22.SHOW
Win_1.LABEL_EJI1.HIDE   
Win_1.LABEL_EJI2.HIDE   
Win_1.LABEL_EJI4.HIDE   
Win_1.LABEL_EJI5.HIDE   
Win_1.LABEL_EJI3.SHOW
***************************************
RETURN

***************************************
PROCEDURE AVIBUSQ()
***************************************
Win_1.LABEL_EJI1.HIDE   
Win_1.LABEL_EJI2.HIDE   
Win_1.LABEL_EJI3.HIDE   
Win_1.LABEL_EJI5.HIDE   
Win_1.LABEL_EJI4.SHOW
RETURN

***************************************
PROCEDURE AVIBAJA()
***************************************
Win_1.LABEL_EJI1.HIDE   
Win_1.LABEL_EJI2.HIDE   
Win_1.LABEL_EJI3.HIDE   
Win_1.LABEL_EJI4.HIDE   
Win_1.LABEL_EJI5.SHOW
RETURN

PROCEDURE RECLASIFICAR()
Win_1.LABEL_T1.HIDE
Win_1.CONTROL_T1.HIDE
Win_1.grid_1.HIDE
Win_1.TAB_1.HIDE
Win_1.CONTROL_T1.SHOW
Win_1.LABEL_T1.SHOW
Win_1.grid_1.SHOW
Win_1.tab_1.SHOW
dBGoTop()
Win_1.grid_1.Value := RecNo()
Win_1.grid_1.Refresh
RETURN

