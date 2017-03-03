/* P.Ch. for 16.10. */

/*
   nToolTip := InitToolTipForRect ;
   ( ;
      nFormHandle [, aRect ][, cToolTip ][, cTitle ][, nIcon ][, lBallon ][, lClosable ][, lNotUsedYet ] [, lCenterTip ] ;
   )

   by default aRect == GetClientRect( nFormHandle )
              nIcon == TTI_NONE
              if lBallon != .t. (.f. or Nil), or cTitle is Nil - lClosable flag is ignored
 */

#include "minigui.ch"

#define TT_TTIP   1
#define TT_TEXT   3
#define TT_ICON   2

MEMVAR aFormTip, aButtTip

INIT PROCEDURE InitIcon

   // initialise local icon subsystem
   _SetGetIcon( If( IsVistaOrLater(), TTI_ERROR_LARGE, TTI_ERROR ) )
   // initialise a public aFormTip and aButtTip
   _PopulateToolTip()

   RETURN   


FUNCTION Main()

   LOCAL nIcon := _SetGetIcon()

	SET TOOLTIPBALLOON ON
  
   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 250 ;
      TITLE "ToolTip with icon and title" ;
      MAIN ;
      NOSIZE ;
      NOMAXIMIZE ;
      ON RELEASE _ReleaseToolTip()

      *------------ create and add for Form1 custom ToolTip
      aFormTip[ TT_TEXT ] := "Form1 (" + Form1.Type + ")"
      aFormTip[ TT_TTIP ] := InitToolTipForRect( Form1.Handle, ;
                                 Nil, aFormTip[ TT_TEXT ], "Obj:", aFormTip[ TT_ICON ], .T., .F., .F., .F. )

      *------------ create button Button1 with standard HMG ToolTip
      @  50, 150 BUTTON Button1 ;
         CAPTION "Close" ;
         ACTION Form1.Release ;
         TOOLTIP aButtTip[ 1 ][ TT_TEXT ]
      *------------ add for button Button1 new custom ToolTip
      aButtTip[ 1 ][ TT_TTIP ] := ;
         InitToolTipForRect( Form1.Button1.Handle, Nil, aButtTip[ 1 ][ TT_TEXT ], "Action:", aButtTip[ 1 ][ TT_ICON ], .T., .F., .F., .T. )

      *------------ create button Button2 with standard HMG ToolTip
      @ 110, 150 BUTTON Button2 ;
         CAPTION "Update Text" ;
         ACTION  _UpdateTipText( aFormTip[ TT_TEXT ], aFormTip[ TT_TTIP ] ) ;
         TOOLTIP aButtTip[ 2 ][ TT_TEXT ]
      *------------ add for button Button2 new custom ToolTip
      aButtTip[ 2 ][ TT_TTIP ] := ;
         InitToolTipForRect( Form1.Button2.Handle, Nil, aButtTip[ 2 ][ TT_TEXT ], "Action:", aButtTip[ 2 ][ TT_ICON ], .T., .F., .F., .T. )

      *------------ create button Button3 with standard HMG ToolTip
      @ 150, 150 BUTTON Button3 ;
         CAPTION "Update Icon" ;
         ACTION  _UpdateTipIcon() ;
         TOOLTIP "Not full implemented yet"

   END WINDOW
   // add an Icon for standard HMG ToolTip of Form1
   ADD TOOLTIPICON nIcon WITH TITLE "Action:" TO Form1

   CENTER   WINDOW Form1 
   ACTIVATE WINDOW Form1

   RETURN 0


STATIC PROCEDURE _PopulateToolTip()
   // initialise aFormTip and aButtTip
   PUBLIC aFormTip := {,,}
   PUBLIC aButtTip := { {,,}, {,,}, {,,} } 

   aFormTip[ TT_ICON ] := If( IsVistaOrLater(), TTI_INFO_LARGE, TTI_INFO )

   aButtTip[ 1 ][ TT_TEXT ] := "Click here for close windows"
   aButtTip[ 1 ][ TT_ICON ] := If( IsVistaOrLater(), TTI_ERROR_LARGE, TTI_ERROR )

   aButtTip[ 2 ][ TT_TEXT ] := "Click here for update Form1.TooTip"
   aButtTip[ 2 ][ TT_ICON ] := If( IsVistaOrLater(), TTI_WARNING_LARGE, TTI_WARNING )

   aButtTip[ 3 ][ TT_TEXT ] := "Click here for update ToolTip.Image"
   aButtTip[ 3 ][ TT_ICON ] := NIL

   RETURN


STATIC PROCEDURE _ReleaseToolTip()

   ReleaseControl( aFormTip[ TT_TTIP ])

   AEval( aButtTip, {|a| ReleaseControl( a[ TT_TTIP ] )} )

   RETURN


STATIC FUNCTION _UpdateTipText( cToolTip, nToolTip )

//   LOCAL cNewToolTip := cToolTip + "(Last updated: " + hb_TToC( hb_DateTime() ) + ")."
   LOCAL cNewToolTip := cToolTip + "(Life time: " + TimeFromStart() + ")."

   RETURN UpdateToolTipText( Form1.Handle, cNewToolTip, nToolTip )


STATIC PROCEDURE _UpdateTipIcon()

   LOCAL nIcon    := _SetGetIcon() // get "old" (current) value nIcon
   LOCAL nMaxIcon := If( IsVistaOrLater(), TTI_ERROR_LARGE, TTI_ERROR )
   LOCAL nMinIcon := 0

	CLEAR TOOLTIPICON OF Form1

   IF ++nIcon > nMaxIcon           
      nIcon := nMinIcon
   ENDIF      

   ADD TOOLTIPICON nIcon WITH TITLE "Action:" TO Form1

   _SetGetIcon( nIcon )            // store "new" value for next usage

   RETURN


STATIC FUNCTION _SetGetIcon( nNewIcon )

   STATIC nIcon    := TTI_NONE
   LOCAL  nOldIcon := nIcon

   LOCAL nMaxIcon := If( IsVistaOrLater(), TTI_ERROR_LARGE, TTI_ERROR )
   LOCAL nMinIcon := TTI_NONE

   IF PCount() > 0
      hb_default( @nNewIcon, If( IsVistaOrLater(), TTI_INFO_LARGE, TTI_INFO ) )
      IF ( nNewIcon >= nMinIcon .AND. nNewIcon <= nMaxIcon ) 
         nIcon := nNewIcon
      ENDIF
   ENDIF

   RETURN nOldIcon
