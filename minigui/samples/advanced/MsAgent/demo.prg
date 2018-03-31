// +---------------------------------------+
// | TMsAgent v1.3                Test.Prg |
// |                                       |
// | AUTOR: Juan Carlos Salinas Ojeda      |
// |        jcso@esm.com.mx                |
// |        jcso@hotmail.com               |
// |                                       |
// | AGRADECIMIENTO ESPECIAL: Patrick Fan  |
// | *Gracias Patrick, era mas sencillo de |
// |  lo que podía imaginar*               |
// |                                       |
// | Con esta clase se puede tener acceso  |
// | al agente de microsoft.               |
// |                                       |
// |                                       |
// | 25 de Junio del 2004,  México DF      |
// |                                       |
// +---------------------------------------+

* Translated for MiniGUI by Grigory Filatov <gfilatov@inbox.ru>

#Include "minigui.ch"
#Include "TMsAgent.Ch"

DECLARE WINDOW progress

Function Main()

  Local oAgent
  Local cFileAgent

  Local aAvailables := {}

  // Obtenemos todos los agentes disponibles
  // Get all agents availables
  aAvailables := GetAgentsAvailables()

  // Vamos a escoger el ultimo agente disponible de la lista
  // Let's choice the last agent in the list

  IF Len(aAvailables) > 0
    cFileAgent := aAvailables[ Len(aAvailables) ]
    oAgent := TMsAgent():New( "MsAgent",.T.,cFileAgent, .T. , .T. )  // Checa este ultimo parametro
                                                                     // Check this last parameter
    // Ahora tambien puedes hacer esto / now you can do this !
    // oAgent := TMsAgent():New( "MsAgent",.T.,cFileAgent, .T. , .T., "COURIER NEW", 18 )
  ELSE
    MsgInfo( "No se pudo iniciar MsAgent / Can't found MsAgent" )
    oAgent := TMsAgent():New( "MsAgent",.T.)
  ENDIF

  /*
    Tambien Puedes usar comandos xBase para construir el agente
    You can use also xbase commands to build the agent

    Revisa el archivo MsAgent.Ch para checar la sintaxis
    Look for the MsAgent.Ch file to check the syntax

    DEFINE AGENT oAgent NAME AGENT "MsAgent" ;
           FILE AGENT cFileAgent             ;
           WITH SOUND EFECTS                 ;
           WITH MENUPOPUP

  */

  // Intenta esto y verás el cambio / Try this to see what happend
  // de esta forma puedes usar el agente que esté predeterminado
  // With this way you're gonna use the default agent
  // --------------------------------------------------------------
  // oAgent := TMsAgent():New( "MsAgent",.T.)


  // hay que verificar si se puede usar el agente
  // LEt's check if we can use the agent
  IF !oAgent:lOk
    MsgInfo( "No se pudo iniciar MsAgent / Can't start MsAgent" )
    // Si el agente no pudo iniciarse, los métodos NO tendrán efecto, NO habrá errores en tiempo de ejecución
    // if the agent could not started, the METHODs will have no efect. Wont be runtime errors.
  EndIF

  // habrá otras aplicaciones usándolo?
  // Are there another apps using the agent ?
  IF oAgent:UsedByOtherApps()
     MsgInfo( "MsAgent es usado por otras aplicaciones" + CRLF + ;
              "MsAgent is used by other apps", "Cuidado / Carefull" )
  EndIF

  // Todo bien !! ahora a divertirse !!!
  // Everything its good! Time to have some fun !!!

  // para escuchar la voz del personaje necesitas tener instalado Text-to-Speech Engines
  // to hear the character's voice you need Text-to-Speech Engines

  DEFINE WINDOW oWnd AT 0,0 ;
      WIDTH 600 HEIGHT 400 ;
      TITLE TMSAGENT+", jcso@esm.com.mx" ;
      ICON "MSAGENT.ICO" ;
      MAIN ;
      ON INIT ( oAgent:Show(), oAgent:Move( 600, 400 ) ) ;
      ON RELEASE ( oAgent:Hide(), ProcessMessages(), oAgent:End() ) ;
      BACKCOLOR GetSysColor(1)

      DEFINE MAIN MENU

       DEFINE POPUP "Opciones"

         ITEM "Mostrar un Texto" ;
         ACTION oAgent:Say( "Hola, yo soy "+oAgent:GetName()+", Estoy funcionando bajo la Clase TMsAgent v1.3! Es fabulosa!" )

         DEFINE POPUP "Cambiando tipos de letra"

             ITEM "Usando COURIER NEW TAMAÑO 18" ;
             ACTION ( oAgent:SetBalloon( "COURIER NEW", 18 ), oAgent:Say( "Estoy usando un tipo de letra diferente!" ) )

             ITEM "Usando ARIAL EN TAMAÑO 14" ;
             ACTION ( oAgent:SetBalloon( "ARIAL", 14 ), oAgent:Say( "Aca también estoy usando un tipo de letra diferente!" ) )

             ITEM "Usando los valores por default" ;
             ACTION ( oAgent:SetDefaultBalloon(), oAgent:Say( "Estoy usando mis valores por default" ) )

         END POPUP

         SEPARATOR

         ITEM "MsgInfo() cuando está oculto" ;
         ACTION ( oAgent:Say( "Primero me oculto!"), oAgent:Hide(), ;
                  oAgent:Say( "Esto está con el METHOD SAY pero al no estar visible el agente muestra un MsgInfo()" ), ;
                  oAgent:Show(), ;
                  oAgent:Say( "Qué te pareció?" ) )

         ITEM "Texto sin desaparecer" ;
         ACTION ( oAgent:SetBalloon(,, .T. ), ;
                  oAgent:Say( "El texto no se va a quitar hasta que hagas click en mi, me arrastres o me pongas a decir otra cosa" ) )

         ITEM "Texto que desaparece al terminar" ;
         ACTION ( oAgent:SetBalloon(,, .F. ), ;
                  oAgent:Say( "El texto se va a quitar cuando termine de hablar" ) )

         SEPARATOR

         // \Spd=100\ significa 100 palabras por minuto
         // \Spd=100\ means 100 words per minute
         ITEM "Cambiando la velocidad del texto" ;
         ACTION oAgent:Say( "\Spd=100\Hola, estoy hablando un poco mas lento. ¿Qué te parece?" )

         // Otros TAGs que puedes usar en los textos
         // Other TAGs you can use in the texts
         // ------------------------------------------------
         // \Spd=number\ number = Words per minute / palabras por minuto
         // \Pau=number\ number = Pauses speech for the specified number of milliseconds / Hace una pause de number milisegundos
         // \Vol=number\ number = volumen de 0 (silencio) a 65535 (mas alto) / volume 0 is silence and 65535 maximum volume
         // Hay mas TAGs pero no entiendo porque no funcionan, tal vez sea problema del idioma, no lo se.
         // there are more tags but i cant understand why doesnt work, may be the problem be the language, i dont know.
         // checa el archivo TAGS.TXT para verlas todas
         // Check the TAGS.TXT file to see them all

         ITEM "Pensar un texto" ;
         ACTION oAgent:SayThink( "mmmmmmmmm........estoy pensando que MiniGUI es realmente muy bueno" )
         // :Saythink NO espera a que termine el agente para seguir con el flujo del programa
         // :SayThink doesnt wait to go on with the program.

         ITEM "Muévete de ahi Anda!!!" ;
         ACTION oAgent:Move( Random(600), Random(400) )

         SEPARATOR

         DEFINE POPUP "Animaciones Sencillas"

             ITEM "ANIMATE_ANNOUNCE" ;
             ACTION ( oAgent:Animate( ANIMATE_ANNOUNCE ), oAgent:Say( "llegueeee yooooooooo!!!! JEJE" ) )

             ITEM "ANIMATE_SUGGEST" ;
             ACTION ( oAgent:Animate( ANIMATE_SUGGEST ), ;
                      oAgent:Say( "si me incluyes en tus aplicaciones se verán muy profesionales" ) )

             ITEM "ANIMATE_CONFUSED" ;
             ACTION ( oAgent:Say("¿Esto es muy bueno para ser xBase, Que será?"), oAgent:Animate( ANIMATE_CONFUSED ) )

             ITEM "ANIMATE_CONGRATULATE" ;
             ACTION ( oAgent:Animate( ANIMATE_CONGRATULATE ), oAgent:Say("Eres el mejor! Felicidades!") )

             ITEM "ANIMATE_SURPRISED" ;
             ACTION ( oAgent:Animate(ANIMATE_SURPRISED ), oAgent:Say("Vaya! MiniGUI si que es Genial!") )

             ITEM "ANIMATE_DECLINE" ;
             ACTION ( oAgent:Say("No estoy de acuerdo en que programes con xBase. ¿Qué te pasa?"), ;
                      oAgent:Animate( ANIMATE_DECLINE ) )

             ITEM "ANIMATE_EXPLAIN" ;
             ACTION (oAgent:Animate( ANIMATE_EXPLAIN ), ;
                     oAgent:Say( "hay mas animaciones disponibles! Chécalas en el archivo TMsAgent.CH" ))

         END POPUP

         // No olvides esto / Dont forget this
         // Las animaciones repetitivas, necesitan ser detenidas con oAgent:Stop()
         // Looping animations needs oAgent:Stop() to be Stoped
         DEFINE POPUP "Animaciones Repetitivas"

              ITEM "ANIMATE_READING" ;
              ACTION Accion( oAgent, ANIMATE_READING )

              ITEM "ANIMATE_WRITING" ;
              ACTION Accion( oAgent, ANIMATE_WRITING )

              ITEM "ANIMATE_SEARCHING" ;
              ACTION Accion( oAgent, ANIMATE_SEARCHING )

              ITEM "ANIMATE_THINKING" ;
              ACTION Accion( oAgent, ANIMATE_THINKING )

              ITEM "ANIMATE_PROCESSING" ;
              ACTION Accion( oAgent, ANIMATE_PROCESSING )

		END POPUP

		DEFINE POPUP "Animaciones Predefinidas"

              ITEM "oAgent:GetAttention()" ;
              ACTION   ( oAgent:Say( "hey!!, ponme atención!" ), oAgent:GetAttention() )

              ITEM "oAgent:LookDown()" ;
              ACTION   ( oAgent:Say( "Quien anda alla abajo!" ), oAgent:LookDown() )

              ITEM "oAgent:LookLeft()" ;
              ACTION   ( oAgent:Say( "Quien anda alla !" ), oAgent:LookLeft() )

              ITEM "oAgent:LookRight()" ;
              ACTION   ( oAgent:Say( "Quien anda mas alla !" ), oAgent:LookRight() )

              ITEM "oAgent:LookUp()" ;
              ACTION   ( oAgent:Say( "Quien anda alla arriba!" ), oAgent:LookUp() )

         END POPUP

         SEPARATOR

         ITEM "Comentarios del Autor" ;
         ACTION ( oAgent:Say( "Si modificas la Clase, por favor hazme llegar los cambios " + ;
                              "para mantenerla actualizada. GRACIAS!!" ), ;
                  oAgent:Animate( ANIMATE_GREET ) )

         ITEM "Licencia de MsAgent" ;
         ACTION   oAgent:Say( "Antes de usar MsAgent en tu aplicación, revisa el archivo " + ;
                              "de la licencia (licence.pdf)" )

         SEPARATOR

         ITEM "&Salir" ACTION oWnd.Release()

      END POPUP

    END MENU

  END WINDOW

  oWnd.Maximize

  ACTIVATE WINDOW oWnd

Return NIL

// *****************************************************************************************

STAT FUNC Accion( oAgent, cAnimacion )

 Local bAction

 oAgent:Animate( cAnimacion )
 bAction  := { || Procesa() }
 Porcentaje( oAgent, bAction, "Procesando....", "Espere" )

Return NIL

// ********************************************************************************************

STAT FUNC Procesa()

  Local nI

  progress.progress_1.value := 0

  For nI := 1 To 10000
      IF !IsWindowDefined( progress )
         Return .T.
      EndIF
      progress.progress_1.value := nI
      IF nI%5 == 0
         ProcessMessages()
      EndIF
  Next nI

Return .F.

// ********************************************************************************************

Function Porcentaje( oAgent, bAction, cMsg, cTitle )

   Local lCancela := .f.

   DEFAULT bAction := { || nil },;
           cMsg := "Procesando...", cTitle := "Por favor espere"

   DEFINE WINDOW progress				;
	AT 0, 0						;
	WIDTH 400					;
	HEIGHT 136					;
	TITLE cTitle					;
	CHILD						;
	NOMAXIMIZE					;
	NOSIZE						;
	ON INIT ( ProcessMessages(), Eval( bAction ), IF( IsWindowDefined( progress ), progress.Release, ) ) ;
	ON RELEASE oAgent:Stop() ;
	FONT "Tahoma" SIZE 10

	@ 12, 20 LABEL Msg_1				;
		VALUE cMsg				;
		WIDTH  300                 		;
		HEIGHT 17

	@ 36, 20 PROGRESSBAR Progress_1 RANGE 0, 10000 WIDTH 360 SMOOTH ;
		FORECOLOR { 0, 0, 248 }

	@ 75, 155 BUTTON Button_1 ;
			CAPTION "&Cancelar" ;
			ACTION ( lCancela := .t., progress.Release ) ;
			WIDTH 90 HEIGHT 26

	END WINDOW

	CENTER WINDOW progress

	ACTIVATE WINDOW progress

Return NIL
