/*

   PlayDraw.prg

   Needless affairs !

   Some 2 dimension drawing efforts on a totally 3 dimensioned world !

   Experimentations on some HMG's DRAW commands.

   Copyrigth : Everybody can play with any way like :)

   Author : Bicahi Esgici

   History :
            July 2012 : First release

*/

#include <hmg.ch>

#define  n2Pi ( 44 / 7 )
#define  nStylCount  4

Static nSkipLevel := 0
Static aColorS    := { YELLOW, RED, WHITE, BLUE, FUCHSIA, GREEN,  PURPLE, GRAY, PINK, BROWN, ORANGE }
Static lFrmRSized := .F.  // Form ReSized

PROCEDURE Main()

   DEFINE WINDOW frmPlayDraw ;
      AT 0, 0 ;
      WIDTH  600 ;
      HEIGHT 600 ;
      TITLE "Playing by Drawing" ;
      MAIN ;
      BACKCOLOR { 0, 0, 0 }  ;
      ON INIT GoDraw() ;
      ON SIZE ( lFrmRSized := .T. ) ;
      ON MAXIMIZE ( lFrmRSized := .T. )

      ON KEY ESCAPE    ACTION frmPlayDraw.Release

      ON KEY HOME      ACTION ( nSkipLevel := 4 )   // Go BOF   
      ON KEY NEXT      ACTION ( nSkipLevel := 3 )   // Next Style
      ON KEY DOWN      ACTION ( nSkipLevel := 2 )   // Next Color
      ON KEY RIGHT     ACTION ( nSkipLevel := 1 )   // Next Shape

      @ 20, 20 BUTTON btnHelp CAPTION "?" BOLD WIDTH 20 HEIGHT 20 ;
               TOOLTIP "Keys" ;
               ACTION MsgInfo( "HOME : Restart"    + CRLF +;
                               "NEXT : Next Style" + CRLF +;
                               "DOWN : Next Color" + CRLF +;
                               "RIGHT : Next Shape" )

   END WINDOW // frmPlayDraw

   frmPlayDraw.Center
   frmPlayDraw.Activate

RETURN // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE GoDraw()                       // Drawing lines by predefined styles

   LOCAL nStyleNum    := 1,;
         nFormWidth,;
         nFormHeigth,;
         nFormCenterX,;
         nFormCenterY,;
         nHorRadius,;
         nVerRadius,;
         nLinePenW

   LOCAL aPCCounts := { ;                       // Point & Corner Counts per Style
                        { 12, 48, 48, 32 },;       // Point Counts
                        { 12, 48,  3,  1 } }       // Corner Counts

   LOCAL nPCount,;
         nCCount,;
         nRatio

   LOCAL nHDecrement,;
         nVDecrement,;
         nZStep       := 0

   LOCAL aParams

   LOCAL nFactor,;
         nLineBeg,;
         nLineEnd

   LOCAL nFactBeg,;
         nFactEnd,;      
         nFactStp,;         
         nLBegBeg,;
         nLBegEnd,;
         nLBegStp,;
         nLCrmBeg,;
         nLCrmEnd,;
         nLCrmStp

   LOCAL a1Color, aColorNo, nDelay, nCornCremnt, nHRadius, nVRadius,;
         nLineBegY, nLineBegX, nLineEndY, nLineEndX, nBaseCrm

   WHILE .T.
   
      nPCount     := aPCCounts[ 1, nStyleNum ]
      nCCount     := aPCCounts[ 2, nStyleNum ] 
      nRatio      := nPCOunt / nCCOunt 
      aParams     := { ;
                        { ;                                       // Style 1
                          { 1,        2,       .1 },;             // nFactor
                          { 1,        nPCount,  1 },;             // nLineBeg
                          { 1,        nPCount,  1 };              // nCornCremnt
                        },;                                          // EOF Style 1 
                        { ;                                       // Style 2
                          { 0,        3,       .5 },;             // nFactor
                          { 1,        nPCount,  1 },;             // nLineBeg
                          { 0,        nPCount,  nPCOunt / 4 };    // nCornCremnt
                        },;                                          // EOF Style 2 
                        { ;                                       // Style 3
                          { 0,        8,        1 },;             // nFactor
                          { 1,        nRatio,   1 },;             // nLineBeg
                          { nRatio,   nPCount,  nRatio };         // nCornCremnt
                        },;                                          // EOF Style 3
                        { ;                                       // Style 4
                          { 2,        8,        1 },;             // nFactor
                          { 1,        nPCount,  1 },;             // nLineBeg
                          { nZStep-1, nPCount,  nZStep };         // nCornCremnt
                        };                                           // EOF Style 4
                     }                                            // EOF aParams
                          
      nFactBeg := aParams[ nStyleNum, 1, 1 ]
      nFactEnd := aParams[ nStyleNum, 1, 2 ]
      nFactStp := aParams[ nStyleNum, 1, 3 ]
      nLBegBeg := aParams[ nStyleNum, 2, 1 ]
      nLBegEnd := aParams[ nStyleNum, 2, 2 ]
      nLBegStp := aParams[ nStyleNum, 2, 3 ]
      nLCrmBeg := aParams[ nStyleNum, 3, 1 ]
      nLCrmEnd := aParams[ nStyleNum, 3, 2 ]
      nLCrmStp := aParams[ nStyleNum, 3, 3 ]
      
      WHILE .T.     
      
         ERASE WINDOW frmPlayDraw
         
         nFormWidth   := frmPlayDraw.WIDTH
         nFormHeigth  := frmPlayDraw.HEIGHT - 20
         nFormCenterX := nFormWidth / 2
         nFormCenterY := nFormHeigth / 2
         nHorRadius   := nFormCenterX * .75
         nVerRadius   := nFormCenterY * .75
         nLinePenW    := 1
         
         nHDecrement  := nHorRadius / nPCOunt
         nVDecrement  := nVerRadius / nPCOunt
      
         FOR aColorNo := 1 TO LEN( aColorS )
         
            a1Color := aColorS[ aColorNo ]
               
            IF nStyleNum = 1               
               nHRadius := nHorRadius
               nVRadius := nVerRadius
            ENDIF nStyleNum = 1               
         
            FOR nFactor := nFactBeg TO nFactEnd STEP nFactStp     
            
               ERASE WINDOW frmPlayDraw
               
               IF nStyleNum = 1
               
                  IF nFactor < nFactBeg + ( nFactEnd - nFactBeg ) / 2 
                     nHRadius := nHorRadius / nFactor
                  ELSE
                     nVRadius := nVerRadius / ( nFactBeg + ( nFactEnd - nFactor ) )
                     nHRadius := nHorRadius
                  ENDIF nFactor < 6
                  
               ENDIF nStyleNum = 1
               
               IF nStyleNum = 4               
                  nHRadius := nHorRadius
                  nVRadius := nVerRadius
               
                  nLineBegX := nHRadius * COS( n2Pi / nPCOunt ) + nFormCenterX
                  nLineBegY := nVRadius * SIN( n2Pi / nPCOunt ) + nFormCenterY
      
                  nZStep    := ( nPCOunt + 1 ) / nFactor
                  
                  nLCrmBeg  := nZStep - 1
                  nLCrmStp  := nZStep
                  
               ENDIF nStyleNum = 4               
               
               FOR nLineBeg := nLBegBeg TO nLBegEnd STEP nLBegstp
               
                  IF nStyleNum > 1 .AND. nStyleNum < 4
                     nVRadius := nVerRadius - nFactor * nLineBeg
                     nHRadius := nHorRadius - nFactor * nLineBeg
                  ENDIF nStyleNum > 1 .AND. nStyleNum < 4
               
                  IF nStyleNum < 3 .OR. nLineBeg < 2
                     nLineBegY := nVRadius * COS( n2Pi / nPCOunt * nLineBeg ) + nFormCenterY
                     nLineBegX := nHRadius * SIN( n2Pi / nPCOunt * nLineBeg ) + nFormCenterX
                  ENDIF
                  
                  IF nStyleNum = 1    
                     nLCrmBeg := nLineBeg
                  ENDIF nStyleNum = 1               
                  
                  IF nStyleNum = 4               
                     nHRadius := nHRadius - nHDecrement
                     nVRadius := nVRadius - nVDecrement
                  ENDIF nStyleNum = 4               
      
                  FOR nCornCremnt := nLCrmBeg TO nLCrmEnd STEP nLCrmStp
                  
                     IF nStyleNum = 1               
                        nBaseCrm := 0                         
                     ELSE
                        nBaseCrm := nLineBeg
                     ENDIF   
                     
                     nLineEnd := nBaseCrm + nCornCremnt
                     
                     IF nStyleNum < 4               
                        IF nLineEnd > nPCOunt
                           nLineEnd := nLineEnd - nCornCremnt
                        ENDIF
                     ENDIF nStyleNum < 4               
                     
                     IF nStyleNum > 1 .AND. nStyleNum < 4              
                        nVRadius := nVerRadius - nFactor * nLineEnd
                        nHRadius := nHorRadius - nFactor * nLineEnd
                     ENDIF nStyleNum > 1 .AND. nStyleNum < 4              
         
                     nLineEndY := nFormCenterY + ( nVRadius * COS( n2Pi / nPCount * nLineEnd ) )
                     nLineEndX := nFormCenterX + ( nHRadius * SIN( n2Pi / nPCount * nLineEnd ) )
                           
                     DRAW LINE IN WINDOW frmPlayDraw  AT nLineBegY, nLineBegX ;
                                                      TO nLineEndY, nLineEndX ;
                                                      PENCOLOR a1Color ;
                                                      PENWIDTH nLinePenW
                                                      
                     IF nStyleNum > 2               
                        nLineBegY := nLineEndY
                        nLineBegX := nLineEndX
                     ENDIF nStyleNum > 2               
                     
                     nDelay := SECONDS()
                           
                     WHILE ( SECONDS() - nDelay ) < .01
                        DO EVENTS
                     ENDDO
                     
                     IF lFrmRSized
                        EXIT
                     ENDIF
   
                     IF nSkipLevel > 0
                        EXIT
                     ENDIF
                     
                  NEXT nCornCremnt
                  
                  IF lFrmRSized
                     EXIT
                  ENDIF
                  
                  IF nSkipLevel > 0
                     --nSkipLevel
                     EXIT
                  ENDIF
                        
               NEXT nLineBeg
   
               IF lFrmRSized
                  EXIT
               ENDIF
               
               IF nSkipLevel > 0
                  --nSkipLevel
                  EXIT
               ENDIF

            NEXT nFactor
            
            IF nSkipLevel > 0
               --nSkipLevel
               EXIT
            ENDIF
            
            IF lFrmRSized
               EXIT
            ENDIF
                  
         NEXT a1Color   
         
         IF lFrmRSized
            lFrmRSized := .F. 
            LOOP
         ENDIF
         
         IF nSkipLevel > 0
            nSkipLevel := 0
            nStyleNum  := 0
         ENDIF
         
         EXIT
         
      ENDDO
      
      ++nStyleNum
      
      IF nStyleNum > nStylCount
         nStyleNum := 1
      ENDIF
      
   ENDDO
   
RETURN // GoDraw()   

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
