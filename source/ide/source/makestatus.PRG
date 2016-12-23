#include "minigui.ch"
#include "ide.ch"

*-----------------------------------------------------------------------------*
PROCEDURE MakeStatus
*-----------------------------------------------------------------------------*
   LOCAL x         AS NUMERIC
   LOCAL cMsg      AS STRING
   LOCAL nSize     AS NUMERIC
   LOCAL cTooltip  AS STRING
   LOCAL cAction   AS STRING
   LOCAL uAction   AS CODEBLOCK
   LOCAL cBitmap   AS STRING
   LOCAL Styl      AS STRING
   LOCAL Default   AS LOGICAL
   LOCAL w         AS LOGICAL
   LOCAL AMPM      AS LOGICAL
   LOCAL cBackcolor
   LOCAL cFontcolor
   LOCAL cAlign

   IF Len( aStatus ) > 0
      *DEFINE STATUSBAR KEYBOARD FONT "Arial Black" SIZE 12 BOLD ITALIC UNDERLINE STRIKEOUT
      StatusFmgToMem()

      _HMG_ActiveFormName    := iif( Empty( _HMG_ActiveFormName ), 'Form_1', _HMG_ActiveFormName )
      _HMG_BeginWindowActive := .T.

      _BeginMessageBar( "StatusBar", "FORM_1" , aStatusValues[ 1 ], aStatusValues[ 2 ], aStatusValues[ 3 ], ;
                            aStatusValues[ 4 ], aStatusValues[ 5 ], aStatusValues[ 6 ], aStatusValues[ 7 ] )

      FOR x := 1 TO Len( ArrayStatus )

         IF ArrayStatus[ x, 1 ] = "STATUSITEM"
            cMsg  := ArrayStatus[ x, 2 ]
            IF Len( ArrayStatus[ x, 3 ] ) > 0
               nSize := Val( ArrayStatus[ x, 3 ] )
            ELSE
               nSize := nil
            ENDIF

            cToolTip := ArrayStatus[ x, 7 ]
            cAction  := ArrayStatus[ x, 4 ]
           // MSGBOX('cACTION1= ' + cACTION )
            cAction  := IfEmpty( cAction, "Action is not defined", cAction )
           // MSGBOX('cACTION2= ' + cACTION )
            uAction  := "{||MsgInfo( [" + cAction + "])}"
           // MSGBOX('cAction = ' + uAction )
            uAction  := &( uAction )
            cBitmap  := ArrayStatus[ x, 5 ]

            IF ArrayStatus[ x, 6 ] = "1"
               Styl := "FLAT"
            ELSEIF ArrayStatus[ x, 6 ] = "2"
               Styl := "RAISED"
            ELSE
               Styl := ""
            ENDIF

            IF ArrayStatus[ x, 8 ] = "1"
               Default := .T.
            ELSE
               Default := .F.
            ENDIF

            // MsgBox("STATUSITEM")
            // MsgBox("CMSG " + STR(X) + " = "+CMSG)
            // if nsize # nil
            //    MsgBox("NSIZE= "+STR(NSIZE))
            // ENDIF
            // MsgBox("CTOOLTIP= "+CTOOLTIP)
           //  MsgBox("UACTION= "+UACTION) 
           //  MsgBox("CBITMAP= "+CBITMAP)
           //  MsgBox("STYL= "+STYL)
           
           cBackcolor := nil
           cFontcolor := nil
           cAlign := .f.

           ** _DefineItemMessage( "STATUSITEM",              , 0, 0, cMsg   , uAction      , nSize, 0, cBitmap, Styl , cToolTip, Default )
           // _DefineItemMessage ( ControlName, ParentControl, x, y, Caption, ProcedureName, w    , h, icon   , cstyl, tooltip , default, backcolor, fontcolor, align )
           _DefineItemMessage (  "STATUSITEM",              , 0, 0, cMsg   , uAction      , nSize, 0, cBitmap, Styl , cToolTip, Default , cBackcolor, cFontcolor, cAlign )
           

         ENDIF

         IF ArrayStatus[ x, 1 ] = "DATE"  .OR. ArrayStatus[ x, 1 ] = "$DATE"
            //MsgBox("DATE " + STR(X) + " = "+ArrayStatus[ x, 1 ])
            IF Len( ArrayStatus[ x, 3 ] ) > 0
               nSize := Val( ArrayStatus[ x, 3 ] )
               W     := .T.
            ELSE
               nSize := NIL
               W     := .F.
            ENDIF

            cToolTip := ArrayStatus[ x, 7 ]
            uAction  := ArrayStatus[ x, 4 ]
            //_DefineItemMessage( "STATUSITEM", , 0, 0, Dtoc( Date() ), uAction, iif( W == .F., iif( Lower( Left( Set( _SET_DATEFORMAT ) , 4 ) ) == "yyyy" .OR. Lower( Right( Set( _SET_DATEFORMAT ), 4 ) ) == "yyyy", 84, 70 ) , nSize ) , 0, "", cToolTip )
            // _DefineItemMessage ( ControlName, ParentControl, x, y, Caption, ProcedureName, w    , h, icon   , cstyl, tooltip , default, backcolor, fontcolor, align )
             _DefineItemMessage( "STATUSITEM", , 0, 0, Dtoc( Date() ), uAction, iif( W == .F., iif( Lower( Left( Set( _SET_DATEFORMAT ) , 4 ) ) == "yyyy" .OR. Lower( Right( Set( _SET_DATEFORMAT ), 4 ) ) == "yyyy", 84, 70 ) , nSize ) , 0, "", cToolTip, Default , cBackcolor, cFontcolor, cAlign )
         
            //USE NEW FUNCTION C/BACKCOLOR  FONTCOLOR  CALIGN  
         ENDIF

         IF ArrayStatus[ x, 1 ] = "CLOCK"  .OR. ArrayStatus[ x, 1 ] = "$CLOCK"
          // MsgBox("CLOCK " + STR(X) + " = "+ArrayStatus[ x, 1 ])
            nSize    := ArrayStatus[ x, 3 ]
            cToolTip := ArrayStatus[ x, 7 ]
            uAction  := ArrayStatus[ x, 4 ]

            IF  ArrayStatus[ x, 9 ] = "1"
               AMPM := .T.
            ELSE
               AMPM := .F.
            ENDIF

            _SetStatusClock( _HMG_ActiveMessageBarname, _HMG_ActiveFormName, NSIZE, CTOOLTIP, UACTION, AMPM )

         ENDIF

         IF ArrayStatus[ x, 1 ] = "KEYBOARD" .OR.  ArrayStatus[ x, 1 ] = "$KEYBOARD"
          // MsgBox("KEYBOARD " + STR(X) + " = "+ArrayStatus[ x, 1 ])
            IF Len( ArrayStatus[ x, 3 ] ) > 0
               nSize := Val( ArrayStatus[ x, 3 ] )
            ELSE
               nSize := NIL
            ENDIF
            CTOOLTIP := ArrayStatus[ x, 7 ]
            UACTION  := ArrayStatus[ x, 4 ]

            _SetStatusKeybrd( _HMG_ActiveMessageBarname, _HMG_ActiveFormName, nSize, cToolTip, uAction )

         ENDIF

      NEXT X

      _EndMessageBar()

      _HMG_BeginWindowActive := .F.

   ENDIF

RETURN
