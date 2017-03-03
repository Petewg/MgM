/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Based on the original work "Picture_Coords" of Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Last Revised By P.Chornyj <myorg63@mail.ru> 10.22.2016
*/

#include "minigui.ch"

/////////////////////////////////////////////////////////////////////////////
SET PROCEDURE TO util.prg
/////////////////////////////////////////////////////////////////////////////

//  { left, top, right, bottom }
STATIC s_aPart1 := {   0, 0, 200, 149 }
STATIC s_aPart2 := { 202, 0, 691, 149 }
STATIC s_aPart3 := { 693, 0, 933, 149 }

MEMVAR m_aImage, m_aTip

FUNCTION Main()

   LOCAL nWidth := 0, nHeight := 0

   SET TOOLTIP ON

   IF IsMousePresent() .AND. GetImageInfo( "logo.jpg", @nWidth, @nHeight )

      DEFINE WINDOW Form_1 ;
         MAIN ;
         CLIENTAREA nWidth, nHeight + 100 ;
         TITLE "Test a mouse click on the one picture which is divided into 3 parts (" + __FILE__ + ")" ;
         ON RELEASE _ReleaseToolTip()

      @ 0,0 IMAGE Img_Logo PICTURE "logo.jpg" WIDTH nWidth HEIGHT nHeight ;
            ON MOUSEHOVER RC_CURSOR( "MINIGUI_FINGER" ) ;
            ACTION Determine_The_Portion_Of_The_Picture()   

      @ 190,30 LABEL Label_1 VALUE "Move a mouse cursor over part # of picture" TRANSPARENT FONT "Arial" SIZE 34 ;
         FONTCOLOR PINK BACKCOLOR YELLOW AUTOSIZE

      @ 162, 650 BUTTON Button_1 CAPTION "Activate ToolTip"  ACTION _ActivateToolTip( .T. ) WIDTH 110 DEFAULT
      @ 162, 770 BUTTON Button_2 CAPTION "Deactivate"         ACTION _ActivateToolTip( .F. )

      END WINDOW

      SET TOOLTIP VISIBLETIME TO 7000 OF Form_1

      _PopulateToolTip()

      CENTER   WINDOW Form_1
      ACTIVATE WINDOW Form_1

   ENDIF

   RETURN 0


STATIC PROCEDURE _PopulateToolTip()

   LOCAL nI, nLen
   LOCAL nStyle := hb_bitOr( TTS_BALLOON, TTS_CLOSE )
   LOCAL nFlags := TTF_SUBCLASS
   LOCAL nIcon := If( IsVistaOrLater(), 4, 1 )
   LOCAL nDelay

   PUBLIC m_aImage := { s_aPart1, s_aPart2, s_aPart3 }
   nLen := Len( m_aImage )

   PUBLIC m_aTip := Array( nLen + 2 ) // 3 area & 2 buttons

   // Init custom tooltips for area of a picture
   FOR nI := 1 TO nLen
      m_aTip[ nI ] := InitToolTipEx( Form_1.Img_Logo.Handle, ;
                                     m_aImage[ nI ], ;
                                     "Part "  + hb_NtoS( nI ) + " of a picture." , ;
                                     "Area #" + hb_NtoS( nI ), ;
                                     ( nIcon + nI - 1 ), ;
                                     nStyle, ;
                                     nFlags ;
                                   )
      // Deactivate tooltip for area of picture
      TTM_Activate( m_aTip[ nI ], .F. )
   NEXT nI
   // Init custom tooltips for buttons
   m_aTip[ nLen + 1 ] := InitToolTipEx( Form_1.Button_1.Handle,, "Activate ToolTip and move your mouse over image (1,2,3)", ;
                                          "Tip:", ;
                                          nIcon, ;
                                          TTS_BALLOON, ;
                                          hb_bitOr( TTF_IDISHWND, TTF_SUBCLASS, TTF_CENTERTIP ) )

   m_aTip[ nLen + 2 ] := InitToolTipEx( Form_1.Button_2.Handle,, "Click here and deactivate ToolTip (ALL!)", ;
                                          "Tip:", ;
                                          nIcon, ;
                                          TTS_BALLOON, ;
                                          hb_bitOr( TTF_IDISHWND, TTF_SUBCLASS, TTF_CENTERTIP ) )

   // Set "visible time" for custom tooltips synchronized with standard MiniGUI tooltips
   nDelay := TTM_GetDelayTime( GetFormToolTipHandle ( "Form_1" ), TTDT_AUTOPOP )
   IF ( 7000 != nDelay )
      MsgInfo( "Something is wrong in TTM_GetDelayTime" )
   ENDIF

   AEval( m_aTip, {|e| TTM_SetDelayTime( e, TTDT_AUTOPOP, nDelay )} )

   IF ( TTM_GetDelayTime( m_aTip[ nLen ] ) != nDelay )
      MsgInfo( "Something is wrong in TTM_SetDelayTime" )
   ENDIF
   // And more..

   Form_1.Button_2.Enabled := .F.

   RETURN


STATIC PROCEDURE _ActivateToolTip( lFlag )

   IF lFlag
      Form_1.Button_1.Enabled := .F.
      Form_1.Button_2.Enabled := .T.
   ELSE
      Form_1.Button_1.Enabled := .T.
      Form_1.Button_2.Enabled := .F.
   ENDIF      

   AEval( m_aTip, {|e| TTM_Activate( e, lFlag )} )
   
   RETURN


STATIC PROCEDURE _ReleaseToolTip()

   AEval( m_aTip, {|e| ReleaseControl( e )} )

   RETURN
