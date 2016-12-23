// +---------------------------------------+
// | TMsAgent v1.3            TMsAgent.ch  |
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
// | 25 de Junio del 2004, México D.F.     |
// |                                       |
// +---------------------------------------+


#define TMSAGENT "TMsAgent v1.3"


#xcommand DEFINE AGENT    <oAgent>                   ;
             [ FILE AGENT <cFileAgent>             ] ;
             [ NAME AGENT <cName>                  ] ;
             [ <lSound: WITH SOUND EFECTS >        ] ;
             [ <lMenu: WITH MENUPOPUP>             ] ;
       => ;
          [ <oAgent> := ] TMsAgent():New( <cName> , <.lMenu.>, <cFileAgent>, <.lSound.> )

#xcommand ACTIVATE AGENT <oAgent> => <oAgent>:Show()

/*
  +---------------------------------------------------------+
  |  Animaciones Sencillas                                  |
  |  Simply animations                                      |
  +---------------------------------------------------------+
*/

#define ANIMATE_ACKNOWLEDGE              "Acknowledge"
#define ANIMATE_ALERT                    "Alert"
#define ANIMATE_ANNOUNCE                 "Announce"
#define ANIMATE_BLINK                    "Blink"
#define ANIMATE_CONFUSED                 "Confused"
#define ANIMATE_CONGRATULATE             "Congratulate"
#define ANIMATE_DECLINE                  "Decline"
#define ANIMATE_DOMAGIC1                 "DoMagic1"
#define ANIMATE_DOMAGIC2                 "DoMagic2"
#define ANIMATE_DONTRECOGNIZE            "DontRecognize"
#define ANIMATE_EXPLAIN                  "Explain"
#define ANIMATE_GETATTENTION             "GetAttention"
#define ANIMATE_GETATTENTIONCONTINUED    "GetAttentionContinued"
#define ANIMATE_GETATTENTIONRETURN       "GetAttentionReturn"
#define ANIMATE_GREET                    "Greet"
#define ANIMATE_HIDE                     "Hide"
#define ANIMATE_IDLE1_1                  "idle1_1"
#define ANIMATE_IDLE1_2                  "idle1_2"
#define ANIMATE_IDLE1_3                  "idle1_3"
#define ANIMATE_IDLE1_4                  "idle1_4"
#define ANIMATE_IDLE2_1                  "idle2_1"
#define ANIMATE_IDLE2_2                  "idle2_2"
#define ANIMATE_IDLE3_1                  "idle3_1"

// Cuidado, para algunos caracteres esta animación es repetitiva
// y necesita oAgent:Stop() / Warning !! for some characters this
// is a looping animation, so it needs oAgent:Stop()
// **************************************************
#define ANIMATE_IDLE3_2                  "idle3_2"
// **************************************************

#define ANIMATE_LOOKDOWN                 "LookDown"
#define ANIMATE_LOOKDOWNRETURN           "LookDownReturn"
#define ANIMATE_LOOKLEFT                 "LookLeft"
#define ANIMATE_LOOKLEFTRETURN           "LookLeftReturn"
#define ANIMATE_LOOKRIGHT                "LookRight"
#define ANIMATE_LOOKRIGHTRETURN          "LookRightReturn"
#define ANIMATE_LOOKUP                   "LookUp"
#define ANIMATE_LOOKUPRETURN             "LookUpReturn"
#define ANIMATE_MOVEDOWN                 "MoveDown"
#define ANIMATE_MOVELEFT                 "MoveLeft"
#define ANIMATE_MOVERIGHT                "MoveRight"
#define ANIMATE_MOVEUP                   "MoveUp"
#define ANIMATE_PLEASED                  "Pleased"
#define ANIMATE_PROCESS                  "Process"
#define ANIMATE_READ                     "Read"
#define ANIMATE_READCONTINUED            "ReadContinued"
#define ANIMATE_READRETURN               "ReadReturn"
#define ANIMATE_RESTPOSE                 "RestPose"
#define ANIMATE_SAD                      "Sad"
#define ANIMATE_SEARCH                   "Search"
#define ANIMATE_SHOW                     "Show"
#define ANIMATE_SUGGEST                  "Suggest"
#define ANIMATE_SURPRISED                "Surprised"
#define ANIMATE_THINK                    "Think"
#define ANIMATE_UNCERTAIN                "Uncertain"
#define ANIMATE_WAVE                     "Wave"
#define ANIMATE_WRITE                    "Write"
#define ANIMATE_WRITECONTINUED           "WriteContinued"
#define ANIMATE_WRITERETURN              "WriteReturn"

/*
  +--------------------------------------------------------------------+
  |  Animaciones repetitivas                                           |
  |  ( Estas animaciones necesitan de oAgent:Stop() para detenerlas )  |
  |                                                                    |
  |  Looping Animations                                                |
  |  ( this animations needs oAgent:Stop() )                           |
  +--------------------------------------------------------------------+
*/

#define ANIMATE_HEARING_1                "Hearing_1"
#define ANIMATE_HEARING_2                "Hearing_2"
#define ANIMATE_HEARING_3                "Hearing_3"
#define ANIMATE_PROCESSING               "Processing"
#define ANIMATE_READING                  "Reading"
#define ANIMATE_SEARCHING                "Searching"
#define ANIMATE_THINKING                 "Thinking"
#define ANIMATE_WRITING                  "Writing"
