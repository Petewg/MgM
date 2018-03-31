#include 'minigui.ch'

ANNOUNCE RDDSYS

MEMVAR cNameApp
MEMVAR aPointG
MEMVAR nFun
MEMVAR Pi
MEMVAR cMess
MEMVAR aUserF
MEMVAR aClr
MEMVAR PathApp
MEMVAR PathGraph
MEMVAR cExpF1
MEMVAR cExpF2
MEMVAR cExpTran1
MEMVAR cExpTran2

//--------------------------------------------------------------------------------\

FUNCTION MAIN

   LOCAL cVer := 'v.2.4'
   LOCAL aFun := { 'Sin(x)', 'Cos(x)', 'Tg(x)', 'ArcSin(x)', 'ArcCos(x)', 'ArcTg(x)', ;
      'RD(x)', 'DR(x)', 'Ln(x)', 'Lg(x)', 'Sqr(x)', 'Abs(x)' }
   LOCAL aConst := { 'Pi', 'Pi/2', 'Pi/3', 'Pi/4', '2*Pi/3', '2*Pi' }
   LOCAL FileUserF, cStr, nTok, i
   LOCAL nColbut, nWBut, cBut
 
   SET CENTURY ON
   SET DATE GERMAN

   SET MULTIPLE OFF WARNING
   SET TOOLTIP BALLOON ON
   SET NAVIGATION EXTENDED

   cNameApp := 'MiniGraph'
   aPointG := {}
   Pi := Pi()
   nFun := 1
   cMess := ''
   aUserF := {}
   PathApp := GetStartupFolder()
   PathGraph := PathApp + '\GRAPH\'
   IF DirChange( PathGraph ) > 0
      MakeDir( PathGraph )
   ENDIF
   DirChange( PathApp )

   aClr := { { 235, 245, 255 }, { 195, 215, 245 }, { 100, 140, 200 } }
   FileUserF := PathApp + '\userfun.txt'
   IF File( FileUserF ) == .F.
      hb_MemoWrit( FileUserF, 'Abs(Abs(x^2-2x)-3)' + CRLF + 'x^3-3x^2+4' + CRLF + 'Sin(2x)+Ln(x+1)' + CRLF, .F. )
   ENDIF
   cStr := MemoRead( FileUserF )
   nTok := NumToken( cStr, CRLF )
   FOR i = 1 TO nTok
      AAdd( aUserF, Token( cStr, CRLF, i ) )
   NEXT

   DEFINE WINDOW WinMain ;
      AT 0, 0 WIDTH 505 HEIGHT 540 ;
      TITLE cNameApp + ' ' + cVer ;
      ICON 'MAIN' ;
      MAIN ;
      NOSIZE NOMAXIMIZE NOCAPTION ;
      FONT 'Courier' SIZE 12 ;
      BACKCOLOR aClr[2]
         
   @ 1, 2  LABEL btnHelp1 WIDTH 25 HEIGHT 30 VALUE '?' ;
      FONT 'Verdana' SIZE 18 BOLD FONTCOLOR BLACK BACKCOLOR aClr[3] RIGHTALIGN ;
      ACTION _Execute ( GetActiveWindow() , "open" , "minigraph.txt" ,  ,  , 1 ) ;
      TOOLTIP 'Description of program'
   @ 0, 1  LABEL btnHelp2 WIDTH 25 HEIGHT 30 VALUE '?' ;
      FONT 'Verdana' SIZE 18 BOLD FONTCOLOR { 255, 255, 128 } TRANSPARENT RIGHTALIGN ;
      ACTION _Execute ( GetActiveWindow() , "open" , "minigraph.txt" ,  ,  , 1 ) ;
      TOOLTIP 'Description of program'

   @ 1, 25 LABEL lblTop1 WIDTH WinMain.Width - 55 HEIGHT 5 VALUE '' ;
      BACKCOLOR aClr[3] ;
      ACTION MoveActiveWindow()
   @ 6, 25 LABEL lblTop2 WIDTH WinMain.Width - 55 HEIGHT 25 VALUE '    ' + cNameApp + ' ' + cVer ;
      FONT 'Times' SIZE 14  FONTCOLOR WHITE  BACKCOLOR aClr[3] ;
      ACTION MoveActiveWindow()

   @ 1, WinMain.Width - 30  LABEL btnCancel WIDTH 30 HEIGHT 30 VALUE Chr( 120 ) ;
      FONT 'Wingdings' SIZE 18  FONTCOLOR WHITE  BACKCOLOR aClr[3] ;
      ACTION DoMethod ( 'WinMain', 'RELEASE' ) ;
      TOOLTIP 'Close'
   @ 28, 0 LABEL  lblTop3 WIDTH WinMain.Width HEIGHT 1 VALUE " " BACKCOLOR WHITE

   LblBox( 'lblB1', 50, 10, 180, 490 , 1, { aClr[3], aClr[3] } )

   @ 40, 30 LABEL  lblV AUTOSIZE VALUE ' Select ' ;
      FONT 'Times' SIZE 11 BOLD FONTCOLOR aClr[3] BACKCOLOR aClr[2]
   @ 65, 30 LABEL lbUFu WIDTH 120 HEIGHT 40 VALUE 'User functions' ;
      FONT 'Arial' SIZE 10 TRANSPARENT
   @ 70, 150  COMBOBOX  cboFun1 WIDTH 330 HEIGHT 160 ITEMS aUserF  VALUE 1 FONT 'Arial' SIZE 10 ;
      ON CHANGE InsertStr( This.Item( This.Value ), 1 ) ;
      TOOLTIP 'Select user function'

   @ 105, 30 LABEL lblFu WIDTH 120 HEIGHT 40 VALUE 'Standard functions' ;
      FONT 'Arial' SIZE 10 TRANSPARENT

   nColbut := 150
   nWBut := 55
   FOR i = 1 TO 6
      cBut := 'butF_' + AllTrim( Str( i ) )
      @ 100, nColBut BUTTONEX &cBut  CAPTION aFun[i]  WIDTH nWBut HEIGHT 20 ;
         ACTION InsertStr( This.Caption, 1 );
         FONT 'Arial' SIZE 9 BACKCOLOR WHITE NOXPSTYLE FLAT
      nColbut += nWBut
   NEXT

   nColbut := 150
   FOR i = 7 TO 12
      cBut := 'butF_' + AllTrim( Str( i ) )
      @ 120, nColBut BUTTONEX &cBut  CAPTION aFun[i]  WIDTH nWBut HEIGHT 20 ;
         ACTION InsertStr( This.Caption, 1 );
         FONT 'Arial' SIZE 9 BACKCOLOR WHITE NOXPSTYLE FLAT
      nColbut += nWBut
   NEXT

   @ 145, 30 LABEL lblCo WIDTH 120 HEIGHT 20 VALUE 'Constants' ;
      FONT 'Arial' SIZE 10 TRANSPARENT

   nColbut := 150
   FOR i = 1 TO 6
      cBut := 'butC_' + AllTrim( Str( i ) )
      @ 145, nColBut BUTTONEX &cBut  CAPTION aConst[i] WIDTH nWBut HEIGHT 20 ;
         ACTION InsertStr( This.Caption, 1 ) ;
         FONT 'Arial' SIZE 9 BACKCOLOR WHITE NOXPSTYLE FLAT
      nColbut += nWBut
   NEXT

   LblBox( 'lblB2', 200, 10, 290, 490 , 1, { aClr[3], aClr[3] } )

   @ 190, 30 LABEL  lblF AUTOSIZE VALUE ' Functions ' ;
      FONT 'Times' SIZE 11 BOLD FONTCOLOR aClr[3] BACKCOLOR aClr[2]
   @ 221, 30 LABEL  L_Y1  WIDTH 50  VALUE 'Y1=' ;
      FONT 'Courier' SIZE 16  FONTCOLOR RED TRANSPARENT
   @ 220, 80 TEXTBOX  txtCalc1 WIDTH 400  VALUE '' FONTCOLOR { 196, 0, 0 } ;
      ON GOTFOCUS nFun := SetnFun( This.Name ) ;
      TOOLTIP 'Function expression 1'
   @ 251, 30 LABEL  L_Y2 WIDTH 50  VALUE 'Y2=' FONT 'Courier' SIZE 16 FONTCOLOR BLUE TRANSPARENT
   @ 250, 80 TEXTBOX  txtCalc2 WIDTH 400  VALUE '' FONTCOLOR { 0, 0, 196 } ;
      ON GOTFOCUS nFun := SetnFun( This.Name ) ;
      TOOLTIP 'Function expression 2'

   LblBox( 'lblB3', 310, 10, 370, 490 , 1, { aClr[3], aClr[3] } )
   @ 300, 30 LABEL  lblA AUTOSIZE VALUE ' Argument ' ;
      FONT 'Times' SIZE 11 BOLD FONTCOLOR aClr[3] BACKCOLOR aClr[2]
   @ 325, 30 LABEL  Label_A1 WIDTH 80 HEIGHT 40  VALUE 'Definitional domain' ;
      FONT 'Arial' SIZE 10    TRANSPARENT

   DEFINE TEXTBOX txtDia1
      ROW 330
      COL 110
      WIDTH 90
      VALUE ''
      NUMERIC .T.
      INPUTMASK '99999.99'
      TOOLTIP 'Bottom border of argument'
      ON GOTFOCUS This.CARETPOS := 0
   END TEXTBOX
   @ 333, 205 LABEL  Label_7 WIDTH 50  VALUE Chr( 163 ) + '  ' + Chr( 67 ) + '  ' + Chr( 163 ) FONT 'Symbol' SIZE 10 TRANSPARENT
   DEFINE TEXTBOX txtDia2
      ROW 330
      COL 245
      WIDTH 90
      VALUE 0
      NUMERIC .T.
      INPUTMASK '99999.99'
      TOOLTIP 'Top border of argument'
      ON GOTFOCUS This.CARETPOS := 0
   END TEXTBOX
   @ 332, 370 LABEL  Label_8 WIDTH 30  VALUE 'Step' FONT 'Arial' SIZE 10 TRANSPARENT
   DEFINE TEXTBOX txtStep
      ROW 330
      COL 400
      WIDTH 80
      VALUE 0
      NUMERIC .T.
      INPUTMASK '999.99'
      TOOLTIP 'Step of argument changing'
      ON GOTFOCUS This.CARETPOS := 0
   END TEXTBOX

   LblBox( 'lblB4', 390, 10, 490, 490 , 1, { aClr[3], aClr[3] } )
   @ 380, 30 LABEL  lblU AUTOSIZE VALUE ' Settings ' ;
      FONT 'Times' SIZE 11 BOLD FONTCOLOR aClr[3] BACKCOLOR aClr[2]
   @ 404, 30 RADIOGROUP rgUg ;
      OPTIONS { 'Angles in degree', 'Angles in radians' } ;
      VALUE 2 WIDTH 120 Spacing 24 FONT 'Arial' SIZE 10 ;
      BACKCOLOR aClr[2] ;
      TOOLTIP 'For trigonometric functions'
   @ 458, 30 TEXTBOX  txtnPen WIDTH 15 HEIGHT 18 VALUE 1 ;
      FONT 'Courier' SIZE 11 NUMERIC ;
      TOOLTIP 'Thickness from 1 to 5 points'
   @ 460, 50 LABEL  Label_9 WIDTH 150  VALUE 'Thickness of line' FONT 'Arial' SIZE 10 TRANSPARENT

   @ 405, 250 CHECKBOX Chk1 CAPTION 'Show vertical grid line'     VALUE .T.  HEIGHT 25  WIDTH 230 FONT 'Arial' SIZE 10 BACKCOLOR aClr[2]
   @ 430, 250 CHECKBOX Chk2 CAPTION 'Show horizontal grid line'   VALUE .T.  HEIGHT 25  WIDTH 230 FONT 'Arial' SIZE 10 BACKCOLOR aClr[2]
   @ 455, 250 CHECKBOX Chk3 CAPTION 'Show mark of value on graph' VALUE .T.  HEIGHT 25  WIDTH 230 FONT 'Arial' SIZE 10 BACKCOLOR aClr[2]

   @ 505, 150 BUTTONEX But_3  CAPTION 'To build the graph'  WIDTH 200 HEIGHT 25 ;
      FONT 'Arial' SIZE 11 FONTCOLOR WHITE BACKCOLOR aClr[3] NOXPSTYLE ;
      ACTION CreateGra()

   LblBox( 'lblW', 0, 0, WinMain.Height - 1, WinMain.Width - 1 , 1, { WHITE, GRAY } )

   END WINDOW
   SET TOOLTIP BACKCOLOR TO aClr[1] OF WinMain

   WinMain .txtCalc1. SetFocus
   WinMain.Center
   ACTIVATE WINDOW WinMain

RETURN NIL

//--------------------------------------------------------------------------------\

FUNCTION SetnFun( txtName )

   LOCAL nFun := Val( Right( txtName,1 ) )

   IF nFun = 1
      SetProperty( 'WinMain', 'txtCalc2', 'BackColor', aClr[2] )
      SetProperty( 'WinMain', 'txtCalc1', 'BackColor', WHITE )
   ELSEIF nFun = 2
      SetProperty( 'WinMain', 'txtCalc2', 'BackColor', WHITE )
      SetProperty( 'WinMain', 'txtCalc1', 'BackColor', aClr[2] )
   ENDIF

RETURN nFun

//--------------------------------------------------------------------------------\

FUNCTION InsertStr( Str2, nMod )

   LOCAL cText := iif( nFun = 1, AllTrim( WinMain .txtcalc1. Value ), AllTrim( WinMain .txtcalc2. Value ) )
   LOCAL nLen := Len( cText )
   LOCAL nPos, cLeft, cRight, cNewText

   IF nMod = 0
      cNewText := cText + Str2
   ELSEIF nMod = 1
      nPos := iif( nFun = 1, WinMain .txtcalc1. CaretPos, WinMain .txtcalc2. CaretPos )
      cLeft := Left( cText, nPos )
      cRight := Right( cText, nLen - nPos )
      cNewText := cLeft + Str2 + cRight
   ENDIF

   IF nFun = 1
      WinMain .txtcalc1. Value := cNewText
      WinMain .txtcalc1. SetFocus
   ELSEIF nFun = 2
      WinMain .txtcalc2. Value := cNewText
      WinMain .txtcalc2. SetFocus
   ENDIF

RETURN NIL

//--------------------------------------------------------------------------------\

FUNCTION CreateGra()

   LOCAL nDia1 := WinMain .txtDia1. Value
   LOCAL nDia2 := WinMain .txtDia2. Value
   LOCAL nStep := WinMain .txtStep. Value
   LOCAL i, nArg, nC, lblHH
   LOCAL aHr1 := { '¹', 'X', 'Y1' }
   LOCAL aHr2 := { '¹', 'X', 'Y2' }
   LOCAL aW := { 30, 57, 65 }

   cExpF1 := WinMain .txtcalc1. Value
   cExpF2 := WinMain .txtcalc2. Value
   cExpTran1 := ''
   cExpTran2 := ''

   IF Empty( cExpF1 ) .AND. Empty( cExpF2 )
      Msg2( cNameApp, "Function is absent", , 1 )
      RETURN .F.
   ENDIF

   IF Empty( cExpF1 ) = .F.
      cExpTran1 = TransFun( cExpF1, 1 )
      IF Empty( cExpTran1 )
         RETURN .F.
      ENDIF
   ENDIF

   IF Empty( cExpF2 ) = .F.
      cExpTran2 = TransFun( cExpF2, 2 )
      IF Empty( cExpTran2 )
         RETURN .F.
      ENDIF
   ENDIF

   IF nStep <= 0 .OR. nStep >= nDia2
      Msg2( cNameApp, "Invalid step select" )
      RETURN .F.
   ENDIF

   IF nDia2 <= nDia1
      Msg2( cNameApp, "Invalid range select", , 1 )
      RETURN .F.
   ENDIF

   nArg = Abs( ( nDia2 - nDia1 )/nStep )
   IF nArg > 1000
      Msg2( cNameApp, "Overranging argument amount", , 1 )
      RETURN .F.
   ENDIF

   DEFINE WINDOW WinGra ;
      At 0, 0 Width 800 Height 530 ;
      Title cNameApp ;
      MODAL ;
      NOSIZE NOCAPTION ;
      BACKCOLOR aClr[1] ;
      ON INIT DrawGra( 'WinGra', .F. )

   @ 1, 0 LABEL lblTop1 WIDTH WinGra.Width - 30 HEIGHT 5 VALUE '' ;
      BACKCOLOR aClr[3] ;
      ACTION MoveActiveWindow()
   @ 6, 0 LABEL lblTop2 WIDTH WinGra.Width - 30 HEIGHT 25 VALUE Space( 50 ) + cNameApp ;
      FONT 'Times' SIZE 14  FONTCOLOR WHITE  BACKCOLOR aClr[3] ;
      ACTION MoveActiveWindow()
   @ 1, WinGra.Width - 30  LABEL btnCancel WIDTH 30 HEIGHT 30  VALUE Chr( 120 ) ;
      FONT 'Wingdings' SIZE 18  FONTCOLOR WHITE  BACKCOLOR aClr[3]  ;
      ACTION DoMethod ( 'WinGra', 'RELEASE' )
   @ 28, 0 LABEL  lblTop3 WIDTH WinGra.Width HEIGHT 1 VALUE " " BACKCOLOR WHITE

   LblBox( 'lblB1', 40, 10, 520, 600 , 1, { aClr[3], aClr[3] } )

   @ 1, 800 LABEL  LblPoint1 HEIGHT 4 WIDTH 4  VALUE '' BACKCOLOR  RED INVISIBLE
   @ 1, 800 LABEL  LblPoint2 HEIGHT 4 WIDTH 4  VALUE '' BACKCOLOR  BLUE INVISIBLE
   @ 35, 615 LABEL  Label_5 HEIGHT  18 WIDTH 175  VALUE 'Tables of values' ;
      FONT 'Arial' SIZE 11 TRANSPARENT CENTERALIGN
 
   @ 73, 615 GRID Grid1 WIDTH 175 HEIGHT 200 NOHEADER ;
      HEADERS { ' ¹', 'X   ', 'Y1   ' } WIDTHS aW VALUE 1 JUSTIFY { 1, 1, 1 } ;
      FONT 'Arial' SIZE 9 FONTCOLOR RED BACKCOLOR WHITE ;
      ON CHANGE MovePoint( This.Name )
   nC := 0
   FOR i = 1 TO Len( aHr1 )
      lblHH := 'lblH1' + AllTrim( Str( i ) )
      @ 53, 615 + nc LABEL &lblHH WIDTH aW[i] + 2 HEIGHT 20 VALUE aHr1[i] ;
         FONT 'Arial' SIZE 11 BOLD FONTCOLOR WHITE BACKCOLOR RED CENTERALIGN  CLIENTEDGE
      nC += aW[i] + 1
   NEXT

   @ 53, 615 + nc LABEL lblE1 WIDTH WinGra .Grid1. Width - nc - 1 HEIGHT 20 VALUE '' ;
      BACKCOLOR RED CLIENTEDGE

   @ 297, 615 GRID Grid2 WIDTH 175 HEIGHT 200 NOHEADER ;
      HEADERS { ' ¹', 'X   ', 'Y1   ' } WIDTHS aW VALUE 1 JUSTIFY { 1, 1, 1 } ;
      FONT 'Arial' SIZE 9 FONTCOLOR BLUE BACKCOLOR WHITE ;
      ON CHANGE MovePoint( This.Name )

   nC := 0
   FOR i = 1 TO Len( aHr2 )
      lblHH := 'lblH2' + AllTrim( Str( i ) )
      @ 277, 615 + nc LABEL &lblHH WIDTH aW[i] + 2 HEIGHT 20 VALUE aHr2[i] ;
         FONT 'Arial' SIZE 11 BOLD FONTCOLOR WHITE BACKCOLOR BLUE CENTERALIGN  CLIENTEDGE
      nC += aW[i] + 1
   NEXT

   @ 277, 615 + nC LABEL lblE2 WIDTH WinGra .Grid2. Width - nc HEIGHT 20 VALUE '' ;
      BACKCOLOR BLUE CENTERALIGN CLIENTEDGE

   @ 500, 615 BUTTONEX But1 CAPTION 'RTF' WIDTH 85 HEIGHT 22 ;
      ACTION Gra2File( 'RTF' ) ;
      FONTCOLOR WHITE BACKCOLOR aClr[3]  NOXPSTYLE ;
      TOOLTIP 'Save graph and table on hard disk'
   @ 500, 705 BUTTONEX But2 CAPTION 'XLS' WIDTH 85 HEIGHT 22 ;
      ACTION Gra2File( 'XLS' ) ;
      FONTCOLOR WHITE BACKCOLOR aClr[3]  NOXPSTYLE ;
      TOOLTIP 'Save graph and table on hard disk'

   END WINDOW

   WinGra.Center
   WinGra.Activate

RETURN .T.

//--------------------------------------------------------------------------------\

FUNCTION TransFun( cExp, nExp )

   LOCAL cExpErr := 'Function -' + Str( nExp, 1 ) + '   '
   LOCAL cExpTran := StrTran( cExp, ',', '.' )
   LOCAL i, cLX, cExpC

   cExpTran := StrTran( cExpTran, 'x', 'X' )
   cExpTran := StrTran( cExpTran, 'õ', 'X' )
   cExpTran := StrTran( cExpTran, 'Õ', 'X' )

   IF At( 'X', cExpTran ) = 0
      Msg2( cNameApp, cExpErr + "Function's argument is absent", , 1 )
      RETURN ''
   ENDIF

   cExpTran := Upper( cExpTran )                  // for calculation
   FOR i = 1 TO Len( cExpTran )
      IF SubStr( cExpTran, i, 1 ) = 'X'
         cLX := SubStr( cExpTran, i - 1, 1 )
         IF cLX <> '0'
            IF Val( cLX ) <> 0 .OR. cLX = ')' .OR. cLX = 'I'
               cExpTran := StrTran( cExpTran, cLX + 'X', cLX + '*X' )
            ENDIF
         ELSE
            cExpTran := StrTran( cExpTran, cLX + 'X', cLX + '*X' )
         ENDIF
         i++
      ENDIF
   NEXT

   cExpTran := StrTran( cExpTran, 'SIN', 'SINF' )
   cExpTran := StrTran( cExpTran, 'COS', 'COSF' )
   cExpTran := StrTran( cExpTran, 'X', '(X)' )
   cExpC := StrTran( cExpTran, 'X', '1' )

   IF Type( cExpC ) $ "UE"
      Msg2( cNameApp, cExpErr + "Invalid expression" + cExpTran, , 1 )
      RETURN ''
   ENDIF

RETURN cExpTran

//--------------------------------------------------------------------------------\

PROCEDURE DrawGra( cWinGra, lFile )

   LOCAL aYVal := {}
   LOCAL aSer := {}
   LOCAL aSer0 := {}                            // bee-line
   LOCAL aSer1 := {}                            // 1-st graph
   LOCAL aGrid1 := {}
   LOCAL aSer2 := {}                            // 2-nd graph
   LOCAL aGrid2 := {}
   LOCAL lxGrid := GetProperty ( 'WinMain', 'Chk2', 'VALUE' )
   LOCAL lyGrid := GetProperty ( 'WinMain', 'Chk1', 'VALUE' )

   LOCAL nStep := WinMain .txtStep. Value
   LOCAL nDia1 := WinMain .txtDia1. Value
   LOCAL nDia2 := WinMain .txtDia2. Value
   LOCAL aClrGr := { aClr[1], RED, BLUE }
   LOCAL aSerName := { "", "", "" }

   LOCAL nDc := 0, cRight2, XV, nInt, nLen, cExpr, Rez
   LOCAL nMax, nMin, lAdd, i, cTit, nGra, nPen

   cMess := ''

   cRight2 := Right( AllTrim( Str(nStep ) ), 2 )
   IF cRight2 <> '00'
      nDc = iif( Right( cRight2,1 ) = '0', 1, 2 )
   ENDIF
   XV := nDia1

   DO WHILE XV <= nDia2
      nInt := Len( AllTrim( Str(Int(XV ) ) ) )
      IF XV < 0
         nInt++
      ENDIF
      nLen := iif( nDc = 0, nInt, nInt + 1 + nDc )
      AAdd( aYVal, AllTrim( Str(XV,nLen,nDc ) ) )
      IF Empty( cExpTran1 ) = .F.
         cExpr := StrTran( cExpTran1, 'X', AllTrim( Str(XV ) ) )
         Rez := &( cExpr )
         AAdd( aSer1, Rez )
      ENDIF
      IF Empty( cExpTran2 ) = .F.
         cExpr := StrTran( cExpTran2, 'X', AllTrim( Str(XV ) ) )
         Rez := &( cExpr )
         AAdd( aSer2, Rez )
      ENDIF
      XV += nStep
   ENDDO

   nMax := 0
   nMin := 0
   lAdd := .F.
   FOR i = 1 TO Len( aSer1 )
      nMax = Max( nMax, aSer1[i] )
      nMin = Min( nMin, aSer1[i] )
   NEXT

   FOR i = 1 TO Len( aSer2 )
      nMax = Max( nMax, aSer2[i] )
      nMin = Min( nMin, aSer2[i] )
   NEXT

   IF nMin < 0
      IF nMax <= Abs( nMin )
         lAdd := .T.
      ENDIF
   ENDIF

   FOR i = 1 TO Len( aYVal )               // bee-line
      IF lAdd == .T.
         AAdd( aSer0, Round( Abs(nMin ),nDc ) )
      ELSE
         AAdd( aSer0, 0 )
      ENDIF

      IF Empty( cExpTran1 ) = .F.
         AAdd( aGrid1, { Str( i,3 ), aYVal[i], AllTrim( Str(aSer1[I] ) ) } )
      ENDIF
      IF Empty( cExpTran2 ) = .F.
         AAdd( aGrid2, { Str( i,3 ), aYVal[i], AllTrim( Str(aSer2[I] ) ) } )
      ENDIF
   NEXT

   AAdd( aSer, aSer0 )
   IF Len( aSer1 ) = 0
      AAdd( aSer, aSer2 )
      AAdd( aSer, aSer2 )
   ELSEIF Len( aSer2 ) = 0
      AAdd( aSer, aSer1 )
      AAdd( aSer, aSer1 )
   ELSE
      AAdd( aSer, aSer1 )
      AAdd( aSer, aSer2 )
   ENDIF

   IF Empty( cMess ) = .F.
      Msg2( cNameApp, cMess, , 1 )
   ENDIF

   cTit := ''
   IF Empty( cExpF1 ) = .F.
      cTit := cTit + "Y1=" + cExpF1 + '  '
      nGra := 1
   ENDIF

   IF Empty( cExpF2 ) = .F.
      cTit := cTit + "Y2=" + cExpF2
      nGra := 2
   ENDIF

   IF Empty( cExpF1 ) = .F. .AND. Empty( cExpF2 ) = .F.
      nGra := 0
   ENDIF

   nPen := WinMain .txtNPen. Value
   nPen := iif( nPen <> 0, nPen, 1 )
   nPen := iif( nPen < 6, nPen, 5 )

   aPointG := GraShow( cWinGra, 35, 0, 520, 620, aSer, cTit , aYVal, 5, 15, 15, ;
      lxGrid, lyGrid, aSerName, aClrGr, lFile, nGra, nPen )

   WinGra .Grid1. DisableUpdate
   FOR i = 1 TO Len( aGrid1 )
      ADD ITEM aGrid1[i] TO Grid1 OF WinGra
   NEXT
   WinGra .Grid1. EnableUpdate
   WinGra .Grid1. Value := 1

   WinGra .Grid2. DisableUpdate
   FOR i = 1 TO Len( aGrid2 )
      ADD ITEM aGrid2[i] TO Grid2 OF WinGra
   NEXT
   WinGra .Grid2. EnableUpdate
   WinGra .Grid2. Value := 1

   IF GetProperty ( 'WinMain', 'Chk3', 'VALUE' ) = .F.
      SetProperty( 'WinGra', 'LblPoint1', 'Visible', .F. )
      SetProperty( 'WinGra', 'LblPoint2', 'Visible', .F. )
   ELSE
      SetProperty( 'WinGra', 'LblPoint1', 'Visible', !Empty( cExpF1 ) )
      SetProperty( 'WinGra', 'LblPoint2', 'Visible', !Empty( cExpF2 ) )
   ENDIF

   SetProperty( 'WinGra', 'LblPoint1', 'Width' , GetProperty( 'WinGra','LblPoint1','Width' ) + nPen )
   SetProperty( 'WinGra', 'LblPoint1', 'Height', GetProperty( 'WinGra','LblPoint1','Height' ) + nPen )
   SetProperty( 'WinGra', 'LblPoint2', 'Width' , GetProperty( 'WinGra','LblPoint2','Width' ) + nPen )
   SetProperty( 'WinGra', 'LblPoint2', 'Height', GetProperty( 'WinGra','LblPoint2','Height' ) + nPen )

RETURN

//--------------------------------------------------------------------------------\

FUNCTION MovePoint( NameGrid )

   LOCAL nRow := GetProperty ( 'WinGra', NameGrid, 'VALUE' )

   IF GetProperty ( 'WinMain', 'Chk3', 'VALUE' ) = .F.
      RETURN NIL
   ENDIF

   IF NameGrid = 'Grid1'
      SetProperty ( 'WinGra', 'LblPoint1', 'ROW', aPointG[2,nRow,1] - 3 )
      SetProperty ( 'WinGra', 'LblPoint1', 'COL', aPointG[2,nRow,2] - 3 )
   ELSEIF NameGrid = 'Grid2'
      SetProperty ( 'WinGra', 'LblPoint2', 'ROW', aPointG[3,nRow,1] - 3 )
      SetProperty ( 'WinGra', 'LblPoint2', 'COL', aPointG[3,nRow,2] - 3 )
   ENDIF

   RedrawWindow( GetControlHandle( 'LblPoint1', 'WinGra' ) )
   RedrawWindow( GetControlHandle( 'LblPoint2', 'WinGra' ) )

RETURN NIL

//--------------------------------------------------------------------------------\

PROCEDURE Gra2File( cType )

   LOCAL I, cFileG, cFileT, lxls, cMsg
   LOCAL cFun1 := iif( Empty( cExpF1 ) = .T. , '', "Y1=" + cExpF1 )
   LOCAL cFun2 := iif( Empty( cExpF2 ) = .T. , '', "Y2=" + cExpF2 )

   FOR i = 1 TO 999
      cFileG = PathGraph + 'graph_' + AllTrim( Str( i ) ) + '.bmp'
      IF !File( cFileG )
         EXIT
      ENDIF
   NEXT

   IF cType = 'RTF'
      cFileT := PathGraph + 'graph_' + AllTrim( Str( i ) ) + '.rtf'
      Gra2rtf( cFileT, cFun1, cFun2 )
      cMsg := 'Look for graph in the file ' + cFileG + CRLF + 'Look for table in the file  ' + cFileT
   ELSEIF cType = 'XLS'
      cFileT = PathGraph + 'graph_' + AllTrim( Str( i ) ) + '.xls'
      lxls := Gra2xls( cFileT, cFun1, cFun2 )
      cMsg := 'Look for graph in the file ' + cFileG + iif( lxls, CRLF + 'Look for table in the file ' + cFileT , '' )
   ENDIF

   WinGra.width := 610
   DO EVENTS
   WndCopy( GetFormHandle( 'WinGra' ), .F. , cFileG )
   WinGra.width := 800
   Msg2( cNameApp, cMsg, , 1 )

RETURN

//--------------------------------------------------------------------------------\

PROCEDURE Gra2rtf( cFileT, cFun1, cFun2 )

   LOCAL nCount := GetProperty ( 'WinGra', 'Grid1', 'ITEMCOUNT' )
   LOCAL I, aItem1, aItem2
   LOCAL aCol := { { '  #',1000 }, { 'Value X',3000 }, { 'Value Y1',5000 } , { 'Value Y2',7000 }  }
   LOCAL cRtf := '{\rtf1\ansi\ansicpg1251\deff0\deflang1049{\fonttbl{\f0\fswiss\fcharset204{\*\fname Arial;}Arial CYR;}}\viewkind4\uc1\pard\f0\fs24' + CRLF

   cRtf := cRtf + '\b       Table of functions values \par       ' + cFun1 + '\par       ' + cFun2 + '\par ' + CRLF
   cRtf := cRtf + InitRowRTF( aCol, '350' )

   FOR i = 1 TO Len( aCol )
      cRtf := cRtf + ' \qc' + aCol[i,1] + '\cell'
   NEXT
   cRtf := cRtf + '\b0\row' + CRLF

   FOR i = 1 TO nCount
      cRtf := cRtf + InitRowRTF( aCol, '250' )
      aItem1 := GetProperty ( 'WinGra', 'Grid1', 'ITEM', i )
      aItem2 := GetProperty ( 'WinGra', 'Grid2', 'ITEM', i )
      cRtf := cRtf + ' \qc ' + AllTrim( aItem1[1] ) + '\cell'
      cRtf := cRtf + ' \qc ' + aItem1[2] + '\cell'
      cRtf := cRtf + ' \qc ' + aItem1[3] + '\cell'
      cRtf := cRtf + ' \qc ' + aItem2[3] + '\cell'
      cRtf := cRtf + '\row ' + CRLF
   NEXT

   cRtf := cRtf + '\pard\nowidctlpar\par}'
   hb_MemoWrit( cFileT, cRtf, .F. )

RETURN


FUNCTION InitRowRTF( aCol, hRow )

   LOCAL iCel := '\clvertalc\clbrdrl\brdrw5\brdrs\brdrcf0\clbrdrt\brdrw5\brdrs\brdrcf0\clbrdrr\brdrw5\brdrs\brdrcf0\clbrdrb\brdrw5\brdrs\brdrcf0 \cellx'
   LOCAL cRow := '\trowd\trgaph10\trleft-10\trrh' + hRow + '\trpaddl10\trpaddr10\trpaddfl3\trpaddfr3' + CRLF
   LOCAL i

   FOR i = 1 TO Len( aCol )
      cRow := cRow + iCel + AllTrim( Str( aCol[i,2] ) ) + CRLF
   NEXT

RETURN cRow + '\pard\intbl\nowidctlpar'

//--------------------------------------------------------------------------------\

FUNCTION Gra2XLS( FileT, cTit1, cTit2 )

   LOCAL oExcel, oSheet, oRange, cCell, cText, i
   LOCAL nCount1 := GetProperty ( 'WinGra', 'Grid1', 'ITEMCOUNT' )
   LOCAL nCount2 := GetProperty ( 'WinGra', 'Grid2', 'ITEMCOUNT' )
   LOCAL nCount := Max( nCount1, nCount2 ), aItem1, aItem2, cEndT

   oExcel := TOleAuto():New( "Excel.Application" )
   IF Ole2TxtError() != 'S_OK'
      RETURN .F.
   ENDIF

   oExcel:WorkBooks:Add()
   oSheet := oExcel:Get( "ActiveSheet" )
   cText := '#' + Chr( 9 ) + '  Value X  ' + Chr( 9 ) + '  Value Y1  ' + Chr( 9 ) + '  Value Y2 ' + Chr( 13 )

   FOR i = 1 TO nCount
      aItem1 := GetProperty ( 'WinGra', 'Grid1', 'ITEM', i )
      aItem2 := GetProperty ( 'WinGra', 'Grid2', 'ITEM', i )
      IF nCount1 = 0
         cText = cText + aItem2[1] + Chr( 9 ) + StrTran( aItem2[2], '.' , ',' ) + Chr( 9 ) + '  ' + Chr( 9 ) + StrTran( aItem2[3], '.' , ',' ) + Chr( 13 )
      ELSEIF nCount2 = 0
         cText = cText + aItem1[1] + Chr( 9 ) + StrTran( aItem1[2], '.' , ',' ) + Chr( 9 ) + StrTran( aItem1[3], '.' , ',' ) + Chr( 9 ) + '  ' + Chr( 13 )
      ELSE
         cText = cText + aItem1[1] + Chr( 9 ) + StrTran( aItem1[2], '.' , ',' ) + Chr( 9 ) + StrTran( aItem1[3], '.' , ',' ) + Chr( 9 ) + StrTran( aItem2[3], '.' , ',' ) + Chr( 13 )
      ENDIF
   NEXT

   CopyToClipboard( cText )
   cCell := "A5"
   oRange := oSheet:Range( cCell )
   oRange:Select()
   oSheet:Paste()

   oRange := oSheet:Range( "A5:D5" )
   oRange:Set( "HorizontalAlignment", 7 )
   oRange:Font:Bold := .T.
   oRange:Font:Size := 10
   cEndT = AllTrim( Str( nCount + 5 ) )
// table framing overshadow
   oRange := oSheet:Range( "A5:D" + cEndT )
   oRange:Borders():LineStyle := 1
   oRange:Set( "HorizontalAlignment", 7 )
   oRange:Columns:AutoFit()

   oSheet:Cells( 1, 1 ):Value := 'Table of functions values'
   oSheet:Cells( 2, 1 ):Value := cTit1 + ' ' + cTit2
   oSheet:Cells( 3, 1 ):Value := 'Date:  ' + DToC( Date() )

   oRange := oSheet:Range( "A1:A2" )
   oRange :FONT:Size := 10
   oRange :Font:Bold := .T.
   oSheet:Range( "A1" ):Select()
   oSheet:SaveAS( FileT )
   oExcel:Quit()

RETURN .T.

//--------------------------------------------------------------------------------\

FUNCTION SinF( x )

RETURN iif( WinMain .rgUg. Value = 1, Sin( DTOR(x ) ), Sin( x ) )


FUNCTION CosF( x )

RETURN iif( WinMain .rgUg. Value = 1, Cos( DTOR(x ) ), Cos( x ) )


FUNCTION Tg( x )

   LOCAL nZ := iif( x < 0, - 1, 1 )
   IF WinMain .rgUg. Value = 1
      x := DToR( x )
   ENDIF

   x := Abs( x )
   IF x >= 1.5 * Pi .AND. x < 1.5 * Pi + 0.02
      x := 1.5 * Pi + 0.02
   ELSEIF x < 1.5 * Pi .AND. x > 1.5 * Pi - 0.02
      x := 1.5 * Pi - 0.02
   ELSEIF x >= 0.5 * Pi .AND. x < 0.5 * Pi + 0.02
      x := 0.5 * Pi + 0.02
   ELSEIF x < 0.5 * Pi .AND. x > 0.5 * Pi - 0.02
      x := 0.5 * Pi - 0.02
   ENDIF

RETURN Tan( nZ * x )


FUNCTION ArcSinF( x )
   IF x > 1 .OR. x <- 1
      IF At( 'ArcSin', cMess ) = 0
         cMess := cMess + 'ArcSin - Invalid argument' + CRLF
      ENDIF
      x := 1
   ENDIF

RETURN iif ( WinMain .rgUg. Value = 1, RToD( ASin(x ) ), ASin( x ) )


FUNCTION ArcCosF( x )
   IF x > 1 .OR. x <- 1
      IF At( 'ArcCos', cMess ) = 0
         cMess := cMess + 'ArcCos - Invalid argument' + CRLF
      ENDIF
      x := 1
   ENDIF

RETURN iif( WinMain .rgUg. Value = 1, RToD( ACos(x ) ), ACos( x ) )


FUNCTION ArcTg( x )

RETURN iif( WinMain .rgUg. Value = 1, RToD( ATan(x ) ), ATan( x ) )


FUNCTION RD( x )

RETURN RToD( x )


FUNCTION DR( x )

RETURN DToR( x )


FUNCTION Lg( x )
   IF x <= 0
      IF At( 'Lg', cMess ) == 0
         cMess := cMess + 'Lg - Invalid argument' + CRLF
      ENDIF
      RETURN 0
   ENDIF

RETURN Log10( x )


FUNCTION Ln( x )
   IF x <= 0
      IF At( 'Ln', cMess ) == 0
         cMess := cMess + 'Ln - Invalid argument' + CRLF
      ENDIF
      RETURN 0
   ENDIF

RETURN Log( x )


FUNCTION Sqr( x )
   IF x < 0
      cMess := cMess + 'Sqr - Invalid argument' + CRLF
      RETURN 0
   ENDIF

RETURN Sqrt( x )

//--------------------------------------------------------------------------------\

FUNCTION Msg2( cTitle, cMess, aButCap, nMod )

   LOCAL nWinW, i
   LOCAL nLenMess := 0
   LOCAL nMess := NumToken( cMess, CRLF )
   LOCAL nLblH := 20 * nMess
   LOCAL nRowBut := 50 + nLblH
   LOCAL nWinH := nRowBut + 40
   LOCAL nRet := 2

   DEFAULT nMod := 0, aButCap := { 'Ok' }

   FOR i = 1 TO nMess
      nLenMess := Max( nLenMess, Len( Token(cMess,CRLF,i ) ) * 9 )
   NEXT
   nWinW := iif( nLenMess < 300, 320, nLenMess )

   DEFINE WINDOW WinMsg AT 0, 0 WIDTH nWinW HEIGHT nWinH ;
      MODAL NOSIZE NOCAPTION NOSYSMENU  FONT 'Arial' SIZE 11 BACKCOLOR aCLR[2]
   @ 1, 0   LABEL LblTit WIDTH nWinW - 25 HEIGHT 25  VALUE '  ' + cTitle ;
      FONT 'Times' SIZE 12 BOLD FONTCOLOR WHITE  BACKCOLOR aClr[3] ;
      ACTION MoveActiveWindow()
   @ 1, nWinW - 25  LABEL btnCancel WIDTH 25 HEIGHT 25  VALUE Chr( 120 ) ;
      FONT 'Wingdings' SIZE 16  FONTCOLOR WHITE  BACKCOLOR aClr[3] ;
      ACTION DoMethod ( 'WinMsg', 'RELEASE' )
   @ 24, 0 LABEL Line1 WIDTH nWinW HEIGHT 1 VALUE "" BACKCOLOR WHITE
   @ 40, 0  LABEL lblMess VALUE cMess WIDTH nWinW HEIGHT nLblH ;
      CENTERALIGN TRANSPARENT

   IF Len( aButCap ) = 2
      @ nRowBut, nWinW/2 - 125 BUTTONEx But1  CAPTION aButCap[1] ;
         WIDTH 120 HEIGHT 25 FONTCOLOR WHITE BACKCOLOR aCLR[3] NOXPSTYLE;
         ACTION ( nRet := 1 , WinMsg.Release  )
      @ nRowBut, nWinW/2 + 5 BUTTONEx But2  CAPTION aButCap[2];
         WIDTH 120 HEIGHT 25 FONTCOLOR WHITE BACKCOLOR aCLR[3] NOXPSTYLE;
         ACTION ( nRet := 2 , WinMsg.Release  )
   ELSE
      @ nRowBut, nWinW/2 - 60 BUTTONEX But1  CAPTION aButCap[1];
         WIDTH 120 HEIGHT 25 FONTCOLOR WHITE BACKCOLOR aCLR[3] NOXPSTYLE;
         ACTION WinMsg.Release
   ENDIF
   IF nMod <> 0
      LblBox( 'lblW', 0, 0, WinMsg.Height - 1, WinMsg.Width - 1 , 1, { WHITE, GRAY } )
   ENDIF
   END WINDOW
   _SetFocus ( 'LblMess', 'WinMsg' )

   CENTER WINDOW WinMsg
   ACTIVATE WINDOW WinMsg

RETURN nRet

//------------------------------------------------------------------------------*

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

PROCEDURE MoveActiveWindow( hWnd )
   DEFAULT hWnd := GetActiveWindow()
   PostMessage( hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0 )

RETURN

//------------------------------------------------------------------------------*

FUNCTION LblBox( cLbl, nR1, nC1, nR2, nC2, nT, aClrB )

   @ nR1, nC1  LABEL  &( cLbl + '1' )  WIDTH  nC2 - nC1 HEIGHT nT         VALUE ''  BACKCOLOR aClrB[1]
   @ nR1, nC1  LABEL  &( cLbl + '2' )  WIDTH  nT      HEIGHT nR2 - nR1    VALUE ''  BACKCOLOR aClrB[1]
   @ nR2, nC1  LABEL  &( cLbl + '3' )  WIDTH  nC2 - nC1 HEIGHT nT         VALUE ''  BACKCOLOR aClrB[2]
   @ nR1, nC2  LABEL  &( cLbl + '4' )  WIDTH  nT      HEIGHT nR2 - nR1 + nT VALUE ''  BACKCOLOR aClrB[2]

RETURN NIL


//------------------------------------------------------------------------------*
// Functions from h_graph.prg
//------------------------------------------------------------------------------*

FUNCTION GraShow( parent, nTop, nLeft, nBottom, nRight, aData, cTitle, aYVals, nBarD, nWideB, nXRanges, ;
      lxGrid, lyGrid, aSeries, aColors, lFile, nGra, nPen )

   LOCAL nI, nJ, nPos, nMax, nMin, nMaxBar
   LOCAL nRange, nResV, aPoint, cName
   LOCAL nXMax, nXMin, nHigh, nRel, nZero, nRPos, nRNeg
   LOCAL MaxYLen, nStep, i, nPic
   LOCAL nYVal, nKrat, lZero

   IF ( Len ( aSeries ) != Len ( aData ) ) .OR. ( Len ( aSeries ) != Len ( aColors ) )
      MsgInfo( "DRAW GRAPH: 'Series' / 'SerieNames' / 'Colors' arrays size mismatch.", cNameApp )
      RETURN NIL
   ENDIF
   nBottom -=  42
   nRight  -=  32
   nTop    += 1 + IF( Empty( cTitle ), 30, 44 )  // Top gap
   nLeft   += 1 + 80 + nBarD                 // Left
   nMaxBar := nBottom - nTop - 5
   nResV := 1

   @ nTop - 30 * nResV, nLeft LABEL Graph_Title OF &parent ;
      VALUE cTitle WIDTH nRight - nLeft HEIGHT 18 ;
      FONT "Times" SIZE 11 BOLD CENTERALIGN BACKCOLOR iif( lFile = .T. , WHITE , aclr[1] )
   RedrawWindow( GetControlHandle( 'Graph_Title', parent ) )

   nMax := 0
   FOR nJ := 1 TO Len( aSeries )
      FOR nI := 1 TO Len( aData[nJ] )
         nMax := Max( aData[nJ][nI], nMax )
      NEXT nI
   NEXT nJ
   nMin := 0
   FOR nJ := 1 TO Len( aSeries )
      FOR nI := 1 TO Len( aData[nJ] )
         nMin := Min( aData[nJ][nI], nMin )
      NEXT nI
   NEXT nJ

   nXMax := IF( nMax > 0, DetMaxVal( nMax ), 0 )
   nXMin := IF( nMin < 0, DetMaxVal( nMin ), 0 )
   nHigh := nXMax + nXMin
   nMax  := Max( nXMax, nXMin )
   nRel  := ( nMaxBar / nHigh )
   nMaxBar := nMax * nRel
   nZero := nTop + ( nMax * nRel ) +  5    // Zero pos
   aPoint := Array( Len( aSeries ), Len( aData[1] ), 2 )
   nRange := nMax / nXRanges

   // xLabels
   nRPos := nRNeg := nZero
   IF lxGrid
      FOR nI := 0 TO nXRanges
         IF nRange * nI <= nXMax
            cName := "xPVal_Name_" + LTrim( Str( nI ) )
            @ nRPos - 5, nLeft - 70 LABEL &cName OF &parent ;
               VALUE Transform( nRange * nI, '99999.99' ) ;
               WIDTH 60 HEIGHT 14 ;
               FONTCOLOR BLACK  FONT "Arial" SIZE 8  RIGHTALIGN BACKCOLOR aclr[1]
            RedrawWindow( GetControlHandle( cName, parent ) )

         ENDIF
         IF nRange * ( - nI ) >= nXMin * ( - 1 )
            cName := "xNVal_Name_" + LTrim( Str( nI ) )
            @ nRNeg - 5, nLeft - 70 LABEL &cName OF &parent ;
               VALUE Transform( nRange *- nI, '99999.99' ) ;
               WIDTH 60 HEIGHT 14 ;
               FONTCOLOR BLACK FONT "Arial" SIZE 8 RIGHTALIGN BACKCOLOR aclr[1]
            RedrawWindow( GetControlHandle( cName, parent ) )
         ENDIF
         IF nRange * nI <= nXMax
            drawline( parent, nRPos, nLeft, nRPos, nRight, { 160, 160, 160 } )
         ENDIF
         IF nRange *- nI >= nXMin *- 1
            drawline( parent, nRNeg, nLeft, nRNeg, nRight, { 160, 160, 160 } )
         ENDIF
         nRPos -= ( nMaxBar / nXRanges )
         nRNeg += ( nMaxBar / nXRanges )
      NEXT nI
   ELSE
      drawline( parent, nZero - 1, nLeft - 2, nZero - 1, nRight, BLACK, 1 ) // horiz  tolst
   ENDIF

   IF lFile
      IF lxGrid
         FOR nI := 0 TO nXRanges
            IF nRange * nI <= nXMax
               cName := "xPVal_Name_" + LTrim( Str( nI ) )
               SetProperty( Parent, cName, 'BackColor', WHITE )
            ENDIF
            IF nRange * ( - nI ) >= nXMin * ( - 1 )
               cName := "xNVal_Name_" + LTrim( Str( nI ) )
               SetProperty( Parent, cName, 'BackColor', WHITE )
            ENDIF
         NEXT
      ENDIF
   ENDIF

   MaxYLen := 1
   nPos := nTop - 5
   IF  Len( aYVals ) > 0                // Show yLabels
      lZero := iif( Val( aYVals[1] ) <= 0, .T. , .F. )
      FOR i = 1 TO Len( aYVals )
         MaxYLen = Max( MaxYLen, Len( aYVals[i] ) )
      NEXT
      nStep := Abs( Val( aYVals[2] ) - Val( aYVals[1] ) )
      nWideB := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
      nI := nLeft + nWideB
      nPic := nWideB/nStep
      FOR nJ := 1 TO nMax( aData )
         nYVal := Val( aYVals[nJ] )
         nKrat := Int( ( Len(aYVals ) * MaxYLen )/80 ) + 1
         IF Mod( nJ, nKrat ) == 0
            IF lYGrid == .T.
               drawline( parent, nBottom, nI, nPos, nI, { 160, 160, 160 } )
               cName := "yVal_Name_" + LTrim( Str( nJ ) )
               @ nBottom + 8, nI -  8 LABEL &cName OF &parent ;
                  VALUE aYVals[nJ] HEIGHT 20 AUTOSIZE ;
                  FONTCOLOR BLACK  FONT "Arial" SIZE 8  TRANSPARENT
            ELSE
               IF lZero == .T.
                  drawline( parent, nTop, ni - nYVal * nPic, nBottom - 2, ni - nYVal * nPic, BLACK, 1 )
                  lZero := .F.
               ENDIF
            ENDIF
         ENDIF
         nI += nWideB
      NEXT
   ENDIF

   nMin := nMax / nMaxBar

   // Lines
   //
   nWideB  := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
   nPos := nLeft + nWideB
   FOR nI := 1 TO Len( aData[1] )
      FOR nJ = 1 TO Len( aSeries )
         aPoint[nJ,nI,2] := nPos
         aPoint[nJ,nI,1] := nZero - ( aData[nJ,nI] / nMin )
      NEXT nJ
      nPos += nWideB
   NEXT nI
   FOR nI := 1 TO Len( aData[1] ) - 1
      FOR nJ := 2 TO Len( aSeries )
         IF nGra = 0
            drawline( parent, aPoint[nJ,nI,1], aPoint[nJ,nI,2], aPoint[nJ,nI+1,1], aPoint[nJ,nI+1,2], aColors[nJ], nPen )
         ELSEIF nGra = 1
            drawline( parent, aPoint[nJ,nI,1], aPoint[nJ,nI,2], aPoint[nJ,nI+1,1], aPoint[nJ,nI+1,2], RED, nPen )
         ELSEIF nGra = 2
            drawline( parent, aPoint[nJ,nI,1], aPoint[nJ,nI,2], aPoint[nJ,nI+1,1], aPoint[nJ,nI+1,2], BLUE, nPen )
         ENDIF
      NEXT nI
   NEXT nI

RETURN aPoint

//------------------------------------------------------------------------------*

STATIC FUNCTION nMax( aData )

   LOCAL nI, nMax := 0

   FOR nI := 1 TO Len( aData )
      nMax := Max( Len( aData[nI] ), nMax )
   NEXT nI

RETURN( nMax )

//------------------------------------------------------------------------------*

STATIC FUNCTION DetMaxVal( nNum )

   LOCAL nE, nMax, nMan, nVal, nOffset

   nE := 9
   nVal := 0
   nNum := Abs( nNum )

   DO WHILE .T.

      nMax := 10 ** nE

      IF Int( nNum/nMax ) > 0

         nMan := ( nNum/nMax ) - Int( nNum/nMax )
         nOffset := 1
         nOffset := IF( nMan <= .75, .75, nOffset )
         nOffset := IF( nMan <= .50, .50, nOffset )
         nOffset := IF( nMan <= .25, .25, nOffset )
         nOffset := IF( nMan <= .00, .00, nOffset )
         nVal := ( Int( nNum/nMax ) + nOffset ) * nMax
         EXIT

      ENDIF

      nE--

   ENDDO

RETURN ( nVal )
