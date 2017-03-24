// +---------------------------------------+
// | TMsAgent v1.3            TMsAgent.Prg |
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
// | Esta clase necesita HBOLE.LIB de      |
// | José Jiménez.                         |
// |                                       |
// | Si modificas la clase, mandame los    |
// | cambios para mantenerla actualizada.  |
// | IF you modify the class please let    |
// | me know so i can keep it actualized.  |
// |                                       |
// | 25 de Junio del 2004, México D.F.     |
// |                                       |
// +---------------------------------------+

/*

 - Antes de usar la clase en tus aplicaciones por favor revisa las siguientes páginas:
 - Before use the class in your apps please check next homepages:

 http://www.microsoft.com/msagent/licensing.htm
 http://www.microsoft.com/permission/copyrgt/cop-img.htm#macharacters
 http://www.microsoft.com/msagent/licensing/distlicense.asp
 http://www.microsoft.com/msagent/licensing/DistLicenseV2.asp

 - y puedes descargar mas agentes de:
 - and you can download more agents from:

 http://www.microsoft.com/msagent/downloads.htm

 - EL AGENTE PUEDE HABLAR LO QUE QUIERAS !
   Lo único que tienes que hacer es instalar Text-To-Speech software que puedes
   descargar también de la página:
 - The MsAgent can talk and say what you want!
   The only you can do is install Text-To-Speech software and you can download it
   from:

 http://www.microsoft.com/msagent/downloads.htm

 - Recomiendo usar unicamente los agentes oficiales de Microsoft
 - I recommend use only the official microsoft agents

 - Todos los agentes de microsoft fueron probados satisfacoriamente con la clase
 - All microsoft agents were succefull tested with this class

 - Los agentes diseñados por terceros no fueron probados, usalos bajo tu propio riesgo.
 - Third parthy agents were not tested. Use them at your own risk.

*/

#include "minigui.ch"
#Include "TMsAgent.ch"
#include "hbclass.ch"
#Include "Directry.ch"

CLASS TMsAgent

 DATA oAgent
 DATA oChars
 DATA oChar
 DATA lMenu
 DATA cName
 DATA cFile
 DATA lOK

 DATA lNeedClick
 DATA oBalloon
 DATA cFontName
 DATA nFontSize     INIT 0
 DATA cFontNameDEF
 DATA nFontSizeDEF

 DATA oResp // gracias Daniel Andrade
 DATA lResp

 DATA lWait

 METHOD New( cName, lMenu, cFile, lSound, lWait, cFontName, nFontSize  )
 METHOD End()

 METHOD Show()
 METHOD Hide()
 METHOD Say( cTxt )
 METHOD SayThink( cTxt )

 METHOD Move( nX, nY )
 METHOD Animate( cAnimate )
 METHOD Stop()
 METHOD GetAttention()
 METHOD LookDown()
 METHOD LookLeft()
 METHOD LookRight()
 METHOD LookUp()

 METHOD GetName()
 METHOD GetVersion()
 METHOD GetIntro()
 METHOD GetExtraData()
 METHOD UsedByOtherApps()

 METHOD GetX()
 METHOD GetY()
 METHOD GetWidth()
 METHOD GetHeight()
 METHOD GetMoveCause()
 METHOD GetVisibilityCause()
 METHOD IsVisible()

 METHOD lBusy()   //  - Gracias Daniel Andrade !!
 METHOD WaitEnd() //  /

 METHOD SetBalloon( cFontName, nFontSize, lFlag )
 METHOD SetDefaultBalloon( )

 METHOD IsStaticLooping( cAnimate ) // Uso interno de la clase / Internal use

ENDCLASS

/*
 =================================================================
 STAT FUNC New( cName, lMenu, cFile, lSound, lWait, cFontName, nFontSize )
 -----------------------------------------------------------------
 cName: Nombre del caracter / Character's Name
 lMenu: Activar menu popup .T., o no activar .F.,
        ACtivate the menu popup .T., or dont activate .f.
 cFile: El archivo del agente que se desea usar, si no se especifica
        se usará el agente que esté por default.
        The Agent's file to be opened, if you dont specify will be
        used the default agent.
 lSound:Si es .T. habrán efectos de sonido, si es .F. no habrán
 lWait: Si es .T. el sistema espera hasta que el agente termine de hacer algo
        antes de continuar con el sistema. / IF .T. the Agent waits until ends
        to do something before to go on with the system.
 < Puedes obtener todos los agentes disponibles usando la funcion
   GetAgentsAvailables(), devolverá un arreglo >
 < you can get all the agents availables by using the
   GetAgentsAvailables() function. Returns an array >
 -----------------------------------------------------------------
*/

METHOD New( cName, lMenu, cFile, lSound, lWait, cFontName, nFontSize  ) CLASS TMsAgent

 Local nMenu
 Local nSound

 DEFAULT cName     := TMSAGENT
 DEFAULT lMenu     := .T.
 DEFAULT lSound    := .T.
 DEFAULT lWait     := .F.
 DEFAULT cFontName := ""
 DEFAULT nFontSize := 0

 ::lWait := lWait

 IF lMenu
    nMenu := 1
 Else
    nMenu := 0
 EndIF

 IF lSound
    nSound := 1
 Else
    nSound := 0
 EndIF

 ::oAgent := TOleAuto():New( "Agent.Control.2" )
 ::oAgent:Connected := 1

 ::oChars   := ::oAgent:Characters

 IF ::oChars # NIL

     IF File(cFile)
         ::oChars:Load( cName, cFile )
     Else
         ::oChars:Load( cName )
     EndIF

     ::oChar := ::oChars:Character( cName )

     IF ::oChar # NIL
        ::cName                := cName
        ::lOK                  := .T.
        ::oChar:AutoPopupMenu  := nMenu
        ::oChar:SoundEffectsOn := nSound
        ::oChar:Name           := cName
        ::oBalloon             := ::oChar:Balloon
        ::cFontNameDEF         := ::oBalloon:FontName
        ::nFontSizeDEF         := ::oBalloon:FontSize
        ::lNeedClick           := .F.
        ::SetBalloon( cFontName, nFontSize, .F. )
     Else
        ::lOK := .F.
     EndIF

 Else

     ::lOK := .F.

 EndIF

Return Self

/*
 =================================================================
 STAT FUNC End()
 -----------------------------------------------------------------
 Finaliza la Clase
 End the class
 -----------------------------------------------------------------
*/
METHOD End() CLASS TMsAgent
   IF ::lOk
      ::oChars:Unload( ::cName )
   EndIF
Return NIL

/*
 =================================================================
 STAT FUNC Show()
 -----------------------------------------------------------------
 Muestra el Agente creado
 Show the Agent
 -----------------------------------------------------------------
*/
METHOD Show() CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
         IF !::IsVisible()
            ::oResp := ::oChar:Show()
            ::WaitEnd()
         EndIF
      Else
         IF !::IsVisible()
            ::oChar:Show()
         EndIF
      EndIF
   EndIF
Return NIL

/*
 ================================================================
 STAT FUNC Hide()
 ----------------------------------------------------------------
 Oculta el agente
 Hides the agent
 ----------------------------------------------------------------
*/
METHOD Hide() CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
         ::oResp := ::oChar:Hide()
         ::WaitEnd()
      Else
         ::oChar:Hide()
      EndIF
   EndIF
Return NIL

/*
 =================================================================
 STAT FUNC IsVisible()
 -----------------------------------------------------------------
 Returns .T. if the agent is visible
 devuelve .T. si el agente está visible
 -----------------------------------------------------------------
*/

METHOD IsVisible() CLASS TMsAgent
  Local lFlag
  Local nAux
  IF ::lOk
     lFlag := ::oChar:Visible
  Else
     lFlag := .F.
  EndIF
Return lFlag

/*
 =================================================================
 STAT FUNC Say( cTxt )
 cTxt: el texto a mostrar / The text to be showed
 -----------------------------------------------------------------
 El agente muestra un texto
 the agent shows a text
 -----------------------------------------------------------------
*/
METHOD Say( cTxt ) CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
         IF ::IsVisible()
            ::oResp := ::oChar:Speak( cTxt )
            ::WaitEnd()
         Else
            MsgInfo( cTxt, ::cName )
         EndIF
      Else
         IF ::IsVisible()
            ::oChar:Speak( cTxt )
         Else
            MsgInfo( cTxt, ::cName )
         EndIF
      EndIF
   Else
      MsgInfo( cTxt, ::cName )
   EndIF
Return NIL

/*
 =================================================================
 STAT FUNC SayThink( cTxt )
 cTxt : El texto a mostrar / the text to be showed
 The agent 'thinks" a text
 -----------------------------------------------------------------
*/
METHOD SayThink( cTxt ) CLASS TMsAgent
   ::lResp := .F.
   IF ::lOk
      IF ::IsVisible()
         ::oChar:Think( cTxt )
      Else
         MsgInfo( cTxt , ::cName )
      EndIF
   Else
      MsgInfo( cTxt , ::cName )
   EndIF
Return NIL

/*
 =================================================================
 STAT FUNC lBusy( )
 devuelve .T. si el agente está ocupado (haciendo algo)
 returns .t. if the agent is busy (doing something)
 -----------------------------------------------------------------
*/
METHOD lBusy() CLASS TMsAgent

   IF ::lOk
      IF ::lResp
         RETURN ::oResp:Status # 0
      EndIF
   EndIF

RETURN .F.

/*
 =================================================================
 STAT FUNC WaitEnd()
 Espera a que el agente termine de hacer algo
 Waits until the agents ends to do something
 -----------------------------------------------------------------
*/
METHOD WaitEnd() CLASS TMsAgent

   IF ::lOk
      IF ::lResp
         Do While ::oResp:Status # 0
            Inkey(0.01)
            Do Events
         EndDo
      EndIF
   EndIf

RETURN Self


/*
 ==================================================================
 STAT FUNC Move( nX, nY )
 nX : La coordenada X / the X coord
 nY : La coordenada Y / the Y coord
 ------------------------------------------------------------------
 Mueve el agente a la coordenada nX,nY
 Moves the agent to nX,nY
*/
METHOD Move( nX,nY ) CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
         ::oResp := ::oChar:MoveTo( nX,nY )
         ::WaitEnd()
      Else
         ::oChar:MoveTo( nX,nY )
      EndIF
   EndIF
Return NIL

/*
 ==================================================================
 STAT FUNC Animate( cAnimate )
 ------------------------------------------------------------------
 cAnimate : nombre de la animacion / the animation's name
 ------------------------------------------------------------------
 Anima al agente ( checa el archivo TMsAgent.CH para ver las animaciones disponibles )
 animate the agent ( check the TMsAgent.Ch File to see animations availables )
*/
METHOD Animate( cAnimate ) CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
         IF !::IsStaticLooping( cAnimate )
            IF ::IsVisible()
               ::oResp := ::oChar:Play( cAnimate )
               ::WaitEnd()
            EndIF
         Else
            IF ::IsVisible()
               ::oChar:Play( cAnimate )
            EndIF
         EndIF
      Else
         IF ::IsVisible()
            ::oChar:Play( cAnimate )
         EndIF
      EndIF
   EndIF
Return NIL

/*
 =======================================================================
 STAT FUNC Stop()
 -----------------------------------------------------------------------
 Detiene la animación en curso
 Stops the animation
*/
METHOD Stop() CLASS TMsAgent
   ::lResp := .F.
   IF ::lOk
      ::oChar:Stop()
   EndIF
Return NIL

/*
 =======================================================================
 STAT FUNC GetAttention()
 -----------------------------------------------------------------------
 Ejecuta la animación GETATTENTION
 plays GETATTENTION animation
*/
METHOD GetAttention() CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
         IF ::IsVisible()
            ::oResp := ::oChar:Play( ANIMATE_GETATTENTION  )
            ::oResp := ::oChar:Play( ANIMATE_GETATTENTIONCONTINUED  )
            ::oResp := ::oChar:Play( ANIMATE_GETATTENTIONRETURN  )
            ::WaitEnd()
         EndIF
      Else
         IF ::IsVisible()
            ::oChar:Play( ANIMATE_GETATTENTION  )
            ::oChar:Play( ANIMATE_GETATTENTIONCONTINUED  )
            ::oChar:Play( ANIMATE_GETATTENTIONRETURN  )
         EndIF
      EndIF
   EndIF
Return NIL

/*
 =======================================================================
 STAT FUNC LookDown()
 -----------------------------------------------------------------------
 Ejecuta la animación LOOKDOWN
 plays LOOKDOWN animation
*/
METHOD LookDown() CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
          IF ::IsVisible()
             ::oResp := ::oChar:Play( ANIMATE_LOOKDOWN  )
             ::oResp := ::oChar:Play( ANIMATE_LOOKDOWNRETURN  )
             ::WaitEnd()
         EndIF
      Else
          IF ::IsVisible()
             ::oChar:Play( ANIMATE_LOOKDOWN  )
             ::oChar:Play( ANIMATE_LOOKDOWNRETURN  )
         EndIF
      EndIF
   EndIF
Return NIL

/*
 =======================================================================
 STAT FUNC LookLeft()
 -----------------------------------------------------------------------
 Ejecuta la animación LOOKLEFT
 plays LOOKLEFT animation
*/
METHOD LookLeft() CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
         IF ::IsVisible()
            ::oResp := ::oChar:Play( ANIMATE_LOOKLEFT  )
            ::oResp := ::oChar:Play( ANIMATE_LOOKLEFTRETURN  )
            ::WaitEnd()
         EndIF
      Else
         IF ::IsVisible()
            ::oChar:Play( ANIMATE_LOOKLEFT  )
            ::oChar:Play( ANIMATE_LOOKLEFTRETURN  )
         EndIF
      EndIF
   EndIF
Return NIL

/*
 =======================================================================
 STAT FUNC LookRight()
 -----------------------------------------------------------------------
 Ejecuta la animación LOOKRIGHT
 plays LOOKRIGHT animation
*/
METHOD LookRight() CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
         IF ::IsVisible()
            ::oResp := ::oChar:Play( ANIMATE_LOOKRIGHT  )
            ::oResp := ::oChar:Play( ANIMATE_LOOKRIGHTRETURN  )
            ::WaitEnd()
         EndIF
      Else
         IF ::IsVisible()
            ::oChar:Play( ANIMATE_LOOKRIGHT  )
            ::oChar:Play( ANIMATE_LOOKRIGHTRETURN  )
         EndIF
      EndIF
   EndIF
Return NIL

/*
 =======================================================================
 STAT FUNC LookUp()
 -----------------------------------------------------------------------
 Ejecuta la animación LOOKUP
 plays LOOKUP animation
*/
METHOD LookUp() CLASS TMsAgent
   ::lResp := .T.
   IF ::lOk
      IF ::lWait
         IF ::IsVisible()
            ::oResp := ::oChar:Play( ANIMATE_LOOKUP  )
            ::oResp := ::oChar:Play( ANIMATE_LOOKUPRETURN  )
            ::WaitEnd()
         EndIF
      Else
         IF ::IsVisible()
            ::oChar:Play( ANIMATE_LOOKUP  )
            ::oChar:Play( ANIMATE_LOOKUPRETURN  )
         EndIF
      EndIF
   EndIF
Return NIL

/*
 =======================================================================
 STAT FUNC GetName()
 -----------------------------------------------------------------------
 obtiene el nombre del MsAgent
 Gets the MsAgent's name
*/
METHOD GetName() CLASS TMsAgent
  Local cName := TMSAGENT
  IF ::lOk
     cName := ::oChar:Name
  EndIF
Return cName

/*
 =======================================================================
 STAT FUNC UsedByOtherApps()
 -----------------------------------------------------------------------
 Devuelve .T. si el agente es usado por otras aplicaciones
 Returns .T. if msagent is used by other apps.
*/
METHOD UsedByOtherApps()CLASS TMsAgent
Return IF( ::lOk, ::oChar:HasOtherClients, .F. )

/*
 =======================================================================
 STAT FUNC GetVersion()
 -----------------------------------------------------------------------
 Devuelve la versión del Agente
 returns the agents version
*/
METHOD GetVersion()CLASS TMsAgent
Return IF( ::lOk, ::oChar:Version, TMSAGENT )

/*
 =======================================================================
 STAT FUNC GetIntro()
 -----------------------------------------------------------------------
 Devuelve la introducción del agente
 returns the agents introduction
*/
METHOD GetIntro()CLASS TMsAgent
Return IF( ::lOk, ::oChar:Description, TMSAGENT )

/*
 =======================================================================
 STAT FUNC GetExtraData()
 -----------------------------------------------------------------------
 Devuelve otra descripcion del agente
 returns the another agent description
*/
METHOD GetExtraData()CLASS TMsAgent
Return IF( ::lOk, ::oChar:ExtraData, TMSAGENT )

/*
 =======================================================================
 STAT FUNC GetX()
 -----------------------------------------------------------------------
 Returns the X coord
 devuelve la coordenada X
*/
METHOD GetX() CLASS TMsAgent
Return IF( ::lOk, ::oChar:left, 0 )

/*
 =======================================================================
 STAT FUNC GetY()
 -----------------------------------------------------------------------
 Returns the Y coord
 devuelve la coordenada Y
*/
METHOD GetY() CLASS TMsAgent
Return IF( ::lOk, ::oChar:Top, 0 )

/*
 =======================================================================
 STAT FUNC GetWidth()
 -----------------------------------------------------------------------
 Returns the Agent's width
 devuelve el ancho del agente
*/
METHOD GetWidth() CLASS TMsAgent
Return IF( ::lOk, ::oChar:Width, 0 )

/*
 =======================================================================
 STAT FUNC GetHeight()
 -----------------------------------------------------------------------
 Returns the Agent's Height
 devuelve lo alto del agente
*/
METHOD GetHeight() CLASS TMsAgent
Return IF( ::lOk, ::oChar:Height, 0 )

/*
 =======================================================================
 STAT FUNC GetMoveCause()
 -----------------------------------------------------------------------
 Returns an integer value indicating who moves the agent
 Devuelve un valor entero indicando quien movio el agente

 0 = El agente NO ha sido movido / The agent has no move
 1 = El usuario movió el Agente  / The user moves the agent
 2 = Tu aplicación movió el agente / Your app moves the agent
 3 = Otra aplicación movió el agente / Another App moves the agent
*/

METHOD GetMoveCause() CLASS TMsAgent
Return IF( ::lOk, ::oChar:MoveCause, 0 )

/*
 =======================================================================
 STAT FUNC GetVisibilityCause()
 -----------------------------------------------------------------------
 Returns an integer value indicating who shows/hide the agent
 Devuelve un valor entero indicando quien visualizó/escondió el agente

 0 = El agente no ha sido visualizado / The agent has not been showed.
 1 = El usuario escondió el agente usando el comando esconder del menu
     de  la barra de tareas / User hid the character using the command on
     the agent's taskbar icon pop-up menu..
 2 = El usuario mostró el agente / The user showed the character
 3 = tu aplicacion escondió el agente / Your application hid the agent
 4 = tu aplicación mostró el agente / Your application showed the agent.
 5 = Otra app escondió el agente / Another client application hid the agent.
 6 = Otra app visualizó el agente / Another client application showed the agent
 7 = El usuario escondió el agente usandop el comando esconder del meno
     de la barra de tareas / The user hid the character using the command on
     the character's pop-up menu.
*/

METHOD GetVisibilityCause() CLASS TMsAgent
Return IF( ::lOk, ::oChar:VisibilityCause, 0 )

/*
 =================================================================
 STAT FUNC IsStaticLooping( cAnimate )
 -----------------------------------------------------------------
 cAnimate: La animación a verificar
           Animation to check
 -----------------------------------------------------------------
 Devuelve .T. si es una animación repetitiva fija
 Returns .t. if is a static looping animation
 -----------------------------------------------------------------
*/

METHOD IsStaticLooping( cAnimate ) CLASS TMsAgent
  Local lFlag := .F.
  DO CASE
     CASE cAnimate == ANIMATE_HEARING_1  ; lFlag := .T.
     CASE cAnimate == ANIMATE_HEARING_2  ; lFlag := .T.
     CASE cAnimate == ANIMATE_HEARING_3  ; lFlag := .T.
     CASE cAnimate == ANIMATE_PROCESSING ; lFlag := .T.
     CASE cAnimate == ANIMATE_READING    ; lFlag := .T.
     CASE cAnimate == ANIMATE_SEARCHING  ; lFlag := .T.
     CASE cAnimate == ANIMATE_THINKING   ; lFlag := .T.
     CASE cAnimate == ANIMATE_WRITING    ; lFlag := .T.
     OTHERWISE
     lFlag := .F.
  ENDCASE
Return lFlag

/*
 =================================================================
 STAT FUNC SetBalloon( cFontSize, nFontsize, lNeedClick )
 -----------------------------------------------------------------
 cFontSize: El nombre de la fuente a utilizar / the font name
 nFontSize: el tamaño de la fuente / the font size
 lNeedClick:Si necesita darse un click en el agente para que el
            globo desaparezca
 -----------------------------------------------------------------
 Cambia el tipo de letra y tamaño de la letra del globo
 Changes the font type and the font size of the balloon
 lNeedClick: IF the balloon needs a click to disapear
 -----------------------------------------------------------------
*/
METHOD SetBalloon( cFontName, nFontSize, lNeedClick ) CLASS TMsAgent
 DEFAULT lNeedClick := ::lNeedClick , ;
         cFontName  := ""           , ;
         nFontSize  := 0
 IF ::lOk
    IF !Empty(cFontName)
       ::cFontName         := cFontName
       ::oBalloon:FontName := cFontName
    EndIF
    IF nFontSize > 0
       ::nFontSize         := nFontSize
       ::oBalloon:FontSize := nFontSize
    EndIF
    IF lNeedClick
       ::oBalloon:Style := 11
    Else
       ::oBalloon:Style := 15
    EndIF
 EndIF
Return NIL

/*
 =================================================================
 STAT FUNC SetDefaultBalloon( )
 -----------------------------------------------------------------
 Pone los valores por default del globo
 Set the default values for the balloon
 -----------------------------------------------------------------
*/

METHOD SetDefaultBalloon( ) CLASS TMsAgent
  IF ::lOk
     IF ::oBalloon # NIL
        ::oBalloon:FontName := ::cFontNameDEF
        ::oBalloon:FontSize := ::nFontSizeDEF
     EndIF
  EndIF
Return NIL

/*
 =================================================================
 -----------------------------------------------------------------
 cDir: El directorio donde se encuentran los agentes
       por default X:\WINDOWS\MSAGENT\CHARS
       The directory where agents files are stored
       by default X:\WINDOWS\MSAGENT\CHARS
 -----------------------------------------------------------------
 obtiene todos los agentes disponibles
 Get all available agents
 -----------------------------------------------------------------
*/
Function GetAgentsAvailables( cDir )

 Local aAgents := {}
 Local aFiles  := {}

 DEFAULT cDir := GetWindowsFolder() + "\msagent\chars"

 aFiles := DIRECTORY( cDir + "\*.acs" )
 AEVAL( aFiles, { |aFile| aAdd( aAgents, cDir + "\" + aFile[F_NAME])} )

Return  aAgents
