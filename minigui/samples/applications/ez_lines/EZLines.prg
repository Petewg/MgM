/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * NikLines 1.1 by Nikolay Ryabov <niksoft@yandex.ru>
 * http://www.niksoft.ru/eng/programs/niklines.htm
 *
 * Copyright 2005-2011 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM "EZLines"
#define VERSION " v.1.2.3"
#define COPYRIGHT " 2005-2011 Grigory Filatov"

#define CLR_BACK {240, 202, 166}
#define CLR_1    {64, 64, 64}
#define CLR_2    {212, 208, 200}

#define MsgInfo( c, t ) MsgInfo( c, t, , .f. )
#define MsgStop( c, t ) MsgStop( c, t, , .f. )

#define GameReady	0
#define GamePlaying	1
#define GamePaused	2
#define GameEnded	3

MEMVAR cIniFile, aTempField
MEMVAR aGameField, aPrevGameField
MEMVAR aNextBalls, aPrevBalls, aNextBallsPos, aPrevBallsPos
MEMVAR aBallBM, aDestBM, aNextBM, aCurrBM

STATIC nRowCol := 9, nColorNum := 7, lCurrCell := .F., lBusy := .F.
STATIC lFirstRun := .T., lShowNextColors := .T., lShowNextCells := .T.
STATIC lSoundDelete := .T., lSoundSelect := .T., lSoundMove := .F., ;
	lSoundStop := .T., lSoundResult := .T., ;
	lAnimateDelete := .T., lAnimateMove := .T.
STATIC aCurrCellPos := {0, 0}, aDestCellPos := {0, 0}
STATIC nGameState, nBallCount, nPrevGameScore, nPrevBallCount
STATIC nStartTime, nPauseTime
STATIC lBackable := .F., nNext := 2
STATIC nGameScore := 0, nGameTime := 0, cUserName := "NoName"

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*
LOCAL cFileName := Application.ExeName
LOCAL cDatFile := ChangeFileExt( cFileName, ".dat" )
PUBLIC cIniFile := ChangeFileExt( cFileName, ".ini" )

PUBLIC aGameField := Array(nRowCol, nRowCol), aPrevGameField
PUBLIC aNextBalls := Array(3), aPrevBalls
PUBLIC aNextBallsPos := Array(3, 2), aPrevBallsPos
PUBLIC aBallBM := Array( nColorNum ) // for balls
PUBLIC aDestBM := Array( nColorNum ) // for next balls on the field
PUBLIC aNextBM := Array( nColorNum ) // for next balls on top
PUBLIC aCurrBM := Array( nColorNum ) // for active balls

	IF .not. OpenScore( cDatFile )
		MsgStop("Can not open a Score file", "Error")
		Return
	ENDIF

	IF FILE(cIniFile)
		BEGIN INI FILE cIniFile
			GET cUserName SECTION "Player" ENTRY "Name" DEFAULT cUserName
			GET nNext SECTION "Next" ENTRY "ShowNext" DEFAULT nNext
			GET lSoundDelete SECTION "Sound" ENTRY "Delete" DEFAULT lSoundDelete
			GET lSoundSelect SECTION "Sound" ENTRY "Select" DEFAULT lSoundSelect
			GET lSoundMove SECTION "Sound" ENTRY "Move" DEFAULT lSoundMove
			GET lSoundStop SECTION "Sound" ENTRY "Stop" DEFAULT lSoundStop
			GET lSoundResult SECTION "Sound" ENTRY "Result" DEFAULT lSoundResult
			GET lAnimateDelete SECTION "Animation" ENTRY "Delete" DEFAULT lAnimateDelete
			GET lAnimateMove SECTION "Animation" ENTRY "Move" DEFAULT lAnimateMove
		END INI
		do case
			case nNext = 0
				lShowNextColors := .F.
				lShowNextCells := .F.
			case nNext = 1
				lShowNextColors := .T.
				lShowNextCells := .F.
			case nNext = 2
				lShowNextColors := .T.
				lShowNextCells := .T.
		endcase
	ENDIF

	SET TOOLTIPSTYLE BALLOON
	SET DEFAULT ICON TO "MAIN"

	DEFINE WINDOW Form_1				;
		AT 0,0					;
		WIDTH 378 HEIGHT 461 + IF(IsXPThemeActive(), 8, 0) ;
		TITLE PROGRAM				;
		MAIN					;
		NOMAXIMIZE NOSIZE			;
		FONT 'MS Sans Serif' SIZE 8		;
		BACKCOLOR CLR_BACK			;
		ON MINIMIZE GamePause()		;
		ON RESTORE GameResume()		;
		ON RELEASE ( dbCloseAll(), 		;
			Ferase( cFileNoExt( cFileName ) +	IndexExt() ), ;
			Ferase( cFileNoExt( cFileName ) + "2" +	IndexExt() ) )

		DEFINE MAIN MENU

		POPUP "&Game"
			ITEM '&New game' + Chr(9) + '     F2' ACTION IF( nGameState == GameReady .or. nGameState == GameEnded, GameNew(), )
			ITEM '&Pause/resume game' + Chr(9) + 'Ctrl+P' ;
				ACTION IF( nGameState == GamePlaying, GamePause(), IF( nGameState = GamePaused, GameResume(), ) ) NAME MenuPause
			ITEM 'Move &back' + Chr(9) + 'Ctrl+Z' ACTION IF( nGameState == GamePlaying, OnBackClick(), ) NAME MenuBack
			ITEM 'Game &over' + Chr(9) + 'Ctrl+E' ACTION IF( nGameState == GamePlaying, GameEnd(), ) NAME MenuOver
			SEPARATOR
			ITEM 'E&xit' + Chr(9) + 'Ctrl+X' ACTION Form_1.Release
		END POPUP

		POPUP "&Options"
			ITEM 'Se&ttings' ACTION IF( nGameState # GamePlaying, Settings(), )
			SEPARATOR
			ITEM '&Load game' + Chr(9) + 'Ctrl+L' ACTION IF( nGameState # GamePlaying, LoadGame(), )
			ITEM '&Save game' + Chr(9) + 'Ctrl+S' ACTION IF( nGameState == GamePlaying .or. nGameState = GamePaused, SaveGame(), ) NAME MenuSave
		END POPUP

		POPUP "&?"
			ITEM '&Show Top 10' + Chr(9) + '     F3' ACTION IF( nGameState # GamePlaying, ShowTop10(), )
			SEPARATOR
			ITEM '&Help' + Chr(9) + 'Ctrl+H' ACTION IF( nGameState # GamePlaying, ShowHelp(), )
			ITEM 'A&bout' + Chr(9) + 'Ctrl+B' ACTION IF( nGameState # GamePlaying, MsgAbout(), )
		END POPUP

		END MENU

		Form_1.MenuPause.Enabled := .F.
		Form_1.MenuBack.Enabled := .F.
		Form_1.MenuSave.Enabled := .F.
		Form_1.MenuOver.Enabled := .F.

		ON KEY ESCAPE ACTION IF( nGameState == GameEnded, Form_1.Release, )

		ON KEY F2 ACTION IF( nGameState == GameReady .or. nGameState == GameEnded, GameNew(), )
		ON KEY F3 ACTION IF( nGameState # GamePlaying, ShowTop10(), )

		ON KEY CONTROL+L ACTION IF( nGameState # GamePlaying, LoadGame(), )
		ON KEY CONTROL+S ACTION IF( nGameState == GamePlaying .or. nGameState = GamePaused, SaveGame(), )

		ON KEY CONTROL+P ACTION IF( nGameState == GamePlaying, GamePause(), IF( nGameState = GamePaused, GameResume(), ) )
		ON KEY CONTROL+Z ACTION IF( nGameState == GamePlaying, OnBackClick(), )
		ON KEY CONTROL+E ACTION IF( nGameState == GamePlaying, GameEnd(), )
		ON KEY CONTROL+X ACTION Form_1.Release

		ON KEY CONTROL+H ACTION IF( nGameState # GamePlaying, ShowHelp(), )
		ON KEY CONTROL+B ACTION IF( nGameState # GamePlaying, MsgAbout(), )

		LoadFieldData()

		ShowScores()

		nGameState := GameReady

		SetWindowCursor( GetControlHandle("Next_1", "Form_1"), "hand.cur" )

	END WINDOW

	Form_1.Cursor := "hand.cur"

	ADD TOOLTIPICON INFO WITH MESSAGE "Best score" OF Form_1

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure LoadFieldData()
*--------------------------------------------------------*
LOCAL row, col, cImage, nS := 40, nCnt

  for nCnt := 1 to nColorNum
      do case
        case nCnt == 1
		aBallBM[nCnt] := 'BallBlue'
		aDestBM[nCnt] := 'DestBlue'
		aNextBM[nCnt] := 'NextBlue'
		aCurrBM[nCnt] := 'CurrBlue'
        case nCnt == 2
		aBallBM[nCnt] := 'BallCyan'
		aDestBM[nCnt] := 'DestCyan'
		aNextBM[nCnt] := 'NextCyan'
		aCurrBM[nCnt] := 'CurrCyan'
        case nCnt == 3
		aBallBM[nCnt] := 'BallRed'
		aDestBM[nCnt] := 'DestRed'
		aNextBM[nCnt] := 'NextRed'
		aCurrBM[nCnt] := 'CurrRed'
        case nCnt == 4
		aBallBM[nCnt] := 'BallGreen'
		aDestBM[nCnt] := 'DestGreen'
		aNextBM[nCnt] := 'NextGreen'
		aCurrBM[nCnt] := 'CurrGreen'
        case nCnt == 5
		aBallBM[nCnt] := 'BallYellow'
		aDestBM[nCnt] := 'DestYellow'
		aNextBM[nCnt] := 'NextYellow'
		aCurrBM[nCnt] := 'CurrYellow'
        case nCnt == 6
		aBallBM[nCnt] := 'BallPink'
		aDestBM[nCnt] := 'DestPink'
		aNextBM[nCnt] := 'NextPink'
		aCurrBM[nCnt] := 'CurrPink'
        case nCnt == 7
		aBallBM[nCnt] := 'BallBrown'
		aDestBM[nCnt] := 'DestBrown'
		aNextBM[nCnt] := 'NextBrown'
		aCurrBM[nCnt] := 'CurrBrown'
      endcase
    next

    DRAW BOX IN WINDOW Form_1 AT 49,4 TO 412,367
    DRAW LINE IN WINDOW Form_1 AT 50,5 TO 50,366 ;
	PENCOLOR CLR_1 PENWIDTH 1
    DRAW LINE IN WINDOW Form_1 AT 50,5 TO 411,5 ;
	PENCOLOR CLR_1 PENWIDTH 1
    DRAW LINE IN WINDOW Form_1 AT 50,366 TO 411,366 ;
	PENCOLOR CLR_2 PENWIDTH 1
    DRAW LINE IN WINDOW Form_1 AT 411,5 TO 411,366 ;
	PENCOLOR CLR_2 PENWIDTH 1

    FOR row := 1 TO nRowCol
	FOR col := 1 TO nRowCol
		cImage := "Cell_" + Ltrim(Str((row - 1) * nRowCol + col))
		@ (col-1)*nS + 51, (row-1)*nS + 6 IMAGE &cImage OF Form_1 ;
			PICTURE "Cell" ;
			ACTION OnCellClick() ;
			WIDTH nS HEIGHT nS
	NEXT
    NEXT

    @ 4,25 LABEL Label_GameScoreTitle VALUE "Your score:" WIDTH 100 TRANSPARENT ;
	BOLD FONTCOLOR BLUE

    @ 18,23 LABEL Label_GameScore VALUE "0" CENTERALIGN WIDTH 60 TRANSPARENT ;
	FONT 'Times New Roman' SIZE 18 BOLD FONTCOLOR BLUE

    @ 4,283 LABEL Label_BestScoreTitle VALUE "Best score:" WIDTH 100 TRANSPARENT ;
	TOOLTIP ALLTRIM(SCORE->NAME) + ' - ' + SCORE->TIME ;
	BOLD FONTCOLOR RED

    @ 18,285 LABEL Label_BestScore VALUE "0" CENTERALIGN WIDTH 60 TRANSPARENT ;
	TOOLTIP ALLTRIM(SCORE->NAME) + ' - ' + SCORE->TIME ;
	FONT 'Times New Roman' SIZE 18 BOLD FONTCOLOR RED

    @ 4,137 LABEL Label_NextBalls VALUE "Next three balls:" WIDTH 120 TRANSPARENT ;
	BOLD FONTCOLOR {0, 128, 0}

    DRAW BOX IN WINDOW Form_1 AT 19,151 TO 42,214
    DRAW LINE IN WINDOW Form_1 AT 20,152 TO 20,213 ;
	PENCOLOR CLR_1 PENWIDTH 1
    DRAW LINE IN WINDOW Form_1 AT 20,152 TO 41,152 ;
	PENCOLOR CLR_1 PENWIDTH 1
    DRAW LINE IN WINDOW Form_1 AT 20,213 TO 41,213 ;
	PENCOLOR CLR_2 PENWIDTH 1
    DRAW LINE IN WINDOW Form_1 AT 41,152 TO 41,213 ;
	PENCOLOR CLR_2 PENWIDTH 1

	FOR nCnt := 1 TO 3
		cImage := "Next_" + Ltrim(Str(nCnt))
		@ 21, (nCnt-1)*nS/2 + 153 IMAGE &cImage OF Form_1 ;
			PICTURE "Next" ;
			ACTION OnNextClick() ;
			WIDTH nS/2 HEIGHT nS/2
	NEXT

Return

*--------------------------------------------------------*
Procedure GameNew()
*--------------------------------------------------------*
LOCAL x, y, nCnt

  if !IsControlDefined(Timer_1, Form_1)

	if lFirstRun
		Randomize()
		lFirstRun := .F.
	endif
	nGameScore := 0
	ShowScores()
	Form_1.MenuPause.Enabled := .T.
	Form_1.MenuSave.Enabled := .T.
	Form_1.MenuOver.Enabled := .T.

	FOR x := 1 TO nRowCol
		FOR y := 1 TO nRowCol
			aGameField[x][y] := 0
		NEXT
	NEXT

	for nCnt := 1 to 3
		// Determine of position one from three current balls
		X := Random(9)
		Y := Random(9)
		if aGameField[X,Y] = 0
			// Put balls on field
			aGameField[X,Y] := Random(nColorNum)
		endif
	next

	nBallCount := 3 // There are three balls on the field at start of game
	PrepareNextBalls()
	nGameState := GamePlaying
	lCurrCell := .F.
	DrawNextBalls()
	DrawGameField()

	DEFINE TIMER Timer_1 OF Form_1 INTERVAL 1000 ACTION OnTimer()

	nStartTime := Seconds()

  endif

Return

*--------------------------------------------------------*
Procedure ShowScores()
*--------------------------------------------------------*
	Form_1.Label_GameScore.Value := Ltrim(Str(nGameScore))
	Form_1.Label_BestScore.Value := Ltrim(Str(SCORE->SCORE))
Return

*--------------------------------------------------------*
Procedure OnCellClick()
*--------------------------------------------------------*
LOCAL aPos, ACol, ARow

  if nGameState <> GamePlaying
	Return
  endif
  if !lBusy
	aPos := GetCellPos(This.Name)
	ACol := aPos[1]
	ARow := aPos[2]
      if aGameField[ACol,ARow] > 0 .and. aGameField[ACol,ARow] <= nColorNum
          // If clicked on the cell with ball
          lCurrCell := .T. // Mark that ball is selected
          // Remember of coordinates for selected ball
          aCurrCellPos[1] := ACol
          aCurrCellPos[2] := ARow
          // Redraw of field
          DrawGameField()
          if lSoundSelect
		PLAY WAVE 'Select' FROM RESOURCE
          endif
          Return
	endif
      if lCurrCell .and. ((aGameField[ACol,ARow] = 0) .or. (aGameField[ACol,ARow] > 20))
          // If clicked on the empty cell and the ball is selected
          aDestCellPos[1] := ACol
          aDestCellPos[2] := ARow
          if CheckMove() // We can move a ball
                // Allow undo
                lBackable := .T.
                Form_1.MenuBack.Enabled := .T.
                // Check for presence of the line
                // If line is not remove, throw out the prepare balls
                if .not. CheckLine()
			ProcessNextBalls()
                endif
                CheckLine() // Check for presence of the line after throw out the balls
                // Redraw of field
                DrawGameField()
                // Redraw of the next balls
                DrawNextBalls()
          else // We can not move a ball
                if lSoundStop
			PLAY WAVE 'Stop' FROM RESOURCE
                endif
          endif
	endif
  endif

Return

*--------------------------------------------------------*
Procedure OnNextClick()
*--------------------------------------------------------*
  if nGameState <> GamePlaying
	Return
  endif
  if !lBusy
	ProcessNextBalls()
	DrawNextBalls()
	DrawGameField()
  endif

Return

*--------------------------------------------------------*
Procedure OnBackClick()
*--------------------------------------------------------*

  // Move undo
  lBackable := .F.
  Form_1.MenuBack.Enabled := .F.
  aGameField := aClone(aPrevGameField)
  aNextBalls := aClone(aPrevBalls)
  aNextBallsPos := aClone(aPrevBallsPos)
  nBallCount := nPrevBallCount
  nGameScore := nPrevGameScore
  lCurrCell := .F.
  // Redraw of field
  DrawGameField()
  // Redraw of the next balls
  DrawNextBalls()
  // Redraw of scores
  ShowScores()

Return

*--------------------------------------------------------*
Function CheckMove()
*--------------------------------------------------------*
LOCAL MarkFlag, X, Y, Iteration := 1, nCnt, lResult

PRIVATE aTempField := aClone(aGameField)

  MarkFlag := MarkPath(aCurrCellPos[1], aCurrCellPos[2], Iteration)
  while MarkFlag == .T.
      Iteration++
      MarkFlag := .F.
      for Y := 1 to 9
        for X := 1 to 9
            if aTempField[X,Y] = -(Iteration-1)
              if MarkPath(X, Y, Iteration)
			MarkFlag := .T.
              endif
            endif
        next
      next
  end
  lResult := ( aTempField[aDestCellPos[1], aDestCellPos[2]] < 0 )
  // If the wat to appointed place is not found, go out
  if .not. lResult
	Return lResult
  endif
  // Prepare of the possible move undo
  aPrevGameField := aClone(aGameField)
  aPrevBalls := aClone(aNextBalls)
  aPrevBallsPos := aClone(aNextBallsPos)
  nPrevBallCount := nBallCount
  nPrevGameScore := nGameScore
  // Mark that selected ball is not present
  lCurrCell := .F.
  do case
    case lAnimateMove = .T.
        // Mark a way from the appointed place to ball now
        X := aDestCellPos[1]
        Y := aDestCellPos[2]
        for nCnt := Abs(aTempField[X,Y]) to 1 step -1
            BackPath(@X, @Y, nCnt)
        next
        // Redraw of field
        DrawGameField()
        // Ball's moving animation now
        X := aCurrCellPos[1]
        Y := aCurrCellPos[2]
        for nCnt := 1 to Abs(aTempField[aDestCellPos[1], aDestCellPos[2]])
            MoveBall(@X, @Y, nCnt) // Move a ball
            // Redraw of field
            DrawGameField()
            if lSoundMove
		PLAY WAVE 'Move' FROM RESOURCE
		inkey(.1)
            endif
        next

    case lAnimateMove = .F.
        // Put the ball to this cell
        aGameField[aDestCellPos[1], aDestCellPos[2]] := aGameField[aCurrCellPos[1], aCurrCellPos[2]]
        // Remove the ball from the initial cell
        aGameField[aCurrCellPos[1], aCurrCellPos[2]] := 0
        // Redraw of field
        DrawGameField()
        if lSoundSelect
		PLAY WAVE 'Select' FROM RESOURCE
        endif
  endcase

Return lResult

*--------------------------------------------------------*
Function MarkPath(X, Y, Iteration)
*--------------------------------------------------------*
LOCAL lResult := .F.

  if (X > 1)
	if (aTempField[X-1,Y] = 0) .or. (aTempField[X-1,Y] > 20)
		lResult := .T.
		aTempField[X-1,Y] := -Iteration
	endif
  endif
  if (X < 9)
	if (aTempField[X+1,Y] = 0) .or. (aTempField[X+1,Y] > 20)
		lResult := .T.
		aTempField[X+1,Y] := -Iteration
	endif
  endif
  if (Y > 1)
	if (aTempField[X,Y-1] = 0) .or. (aTempField[X,Y-1] > 20)
		lResult := .T.
		aTempField[X,Y-1] := -Iteration
	endif
  endif
  if (Y < 9)
	if (aTempField[X,Y+1] = 0) .or. (aTempField[X,Y+1] > 20)
		lResult := .T.
		aTempField[X,Y+1] := -Iteration
	endif
  endif

Return lResult

*--------------------------------------------------------*
Procedure BackPath(X, Y, Step)
*--------------------------------------------------------*
  // Inverted order of the Step for this procedure
  aGameField[X,Y] := aTempField[X,Y]
  if (X > 1)
    if aTempField[X-1,Y] = -(Step-1)
        X--
        Return
    endif
  endif
  if (X < 9)
    if aTempField[X+1,Y] = -(Step-1)
        X++
        Return
    endif
  endif
  if (Y > 1)
    if aTempField[X,Y-1] = -(Step-1)
        Y--
        Return
    endif
  endif
  if (Y < 9)
    if aTempField[X,Y+1] = -(Step-1)
        Y++
    endif
  endif

Return

*--------------------------------------------------------*
Procedure MoveBall(X, Y, Step)
*--------------------------------------------------------*
LOCAL nCell, nCnt

  // Remember for ball on the current position
  nCell := aGameField[X,Y]
  // Remove the ball from the current position
  for nCnt := 1 to 3
      if (X = aNextBallsPos[nCnt][1]) .and. (Y = aNextBallsPos[nCnt][2])
            aGameField[X,Y] := aNextBalls[nCnt]+20
            Exit
      else
            aGameField[X,Y] := 0
      endif
  next
  if (X > 1)
    if aGameField[X-1,Y] = -Step
        X--
        // Put the ball in the new position
        aGameField[X,Y] := nCell
        Return
    endif
  endif
  if (X < 9)
    if aGameField[X+1,Y] = -Step
        X++
        // Put the ball in the new position
        aGameField[X,Y] := nCell
        Return
    endif
  endif
  if (Y > 1)
    if aGameField[X,Y-1] = -Step
        Y--
        // Put the ball in the new position
        aGameField[X,Y] := nCell
        Return
    endif
  endif
  if (Y < 9)
    if aGameField[X,Y+1] = -Step
        Y++
        // Put the ball in the new position
        aGameField[X,Y] := nCell
    endif
  endif

Return

*--------------------------------------------------------*
Function CheckLine()
*--------------------------------------------------------*
LOCAL nCell, X, Y, XX, YY, nCnt, nFlash, aTempField
LOCAL Direction, XOffset,YOffset, XBorder,YBorder
LOCAL lLineFlag, nLineSize, lResult := .F.

  for Y := 1 to 9
    for X := 1 to 9
        if (aGameField[X,Y] = 0) .or. (aGameField[X,Y] > 20)
          Loop
        endif
        for Direction := 1 to 4
          do case
            case Direction = 1 // on horizontal at the left to the right
                  XOffset := 1
                  YOffset := 0
                  XBorder := 9
                  YBorder := 10
            case Direction = 2 // on vertical from above downwards
                  XOffset := 0
                  YOffset := 1
                  XBorder := 10
                  YBorder := 9
            case Direction = 3 // diagonally at the left above to the right down
                  XOffset := 1
                  YOffset := 1
                  XBorder := 9
                  YBorder := 9
            case Direction = 4 // diagonally on the right above on the left down
                  XOffset := -1
                  YOffset := 1
                  XBorder := 1
                  YBorder := 9
          endcase
            // The line is begin always at point X,Y
            // The coordinates of line's end be at XX,YY
            // The line's end coincide with beginning at start
            XX := X
            YY := Y
            lLineFlag := .T. // Needed for first check
            nLineSize := 1
            while (XX <> XBorder) .and. (YY <> YBorder) .and. lLineFlag
                XX += XOffset
                YY += YOffset
                if aGameField[X,Y] = aGameField[XX,YY]
                  nLineSize++
                else
                  lLineFlag := .F.
                endif
            end
            if nLineSize < 5
               Loop
            endif
            // Remove founded line from field,
            // if she have a length of 5 and more balls
            nCell := aGameField[X,Y]
            // Removing of ball's line animation
            nFlash := 1
            if lAnimateDelete
               nFlash := 3
            endif
            while nFlash > 0
                XX := X
                YY := Y
                aTempField := aClone(aGameField)
                while aGameField[XX,YY] = nCell
                    for nCnt := 1 to 3
                        if (XX = aNextBallsPos[nCnt][1]) .and. (YY = aNextBallsPos[nCnt][2])
                              aGameField[XX,YY] := aNextBalls[nCnt]+20
                              Exit
                        else
                          aGameField[XX,YY] := 0
                        endif
                    next
                    XX += XOffset
                    YY += YOffset
                    if XX < 1 .or. XX > 9 .or. YY > 9
                       Exit
                    endif
                end
                nFlash--
                // Redraw of field after ball's removing
                DrawGameField()
                if nFlash > 0
                    inkey(.1)
                    aGameField := aClone(aTempField)
                    // Redraw of field after restoration of line
                    DrawGameField()
                    inkey(.1)
                endif
            end
            // Increase the score
            nGameScore += nLineSize*(nLineSize-4)
            ShowScores()
            // Sound for removing of line
            if lSoundDelete
			PLAY WAVE 'Delete' FROM RESOURCE
            endif
            // Reduce a ball's counter
            nBallCount -= nLineSize
            // If line is removed when result of function is True!
            lResult := .T.
            If lResult
               // Pass to next cell X,Y after the line's removing
               Exit
            endif
        next
      next
    next

Return lResult

*--------------------------------------------------------*
Procedure ProcessNextBalls()
*--------------------------------------------------------*
LOCAL x, y, nCnt

  // Throw out the prepare next balls
  for nCnt := 1 to 3
      X := aNextBallsPos[nCnt][1]
      Y := aNextBallsPos[nCnt][2]
      if (aGameField[X,Y] > 0) .and. (aGameField[X,Y] < 20) // If on the position of the next ball already exists the ball
            // Redefine ball's position
            X := Random(9)
            Y := Random(9)
            do while aGameField[X,Y] # 0
               X := Random(9)
               Y := Random(9)
            end
      endif
      aGameField[X,Y] := aNextBalls[nCnt] // Next ball's color is not exchange
  next
  // Redraw of field
  DrawGameField()
  // Increase ball's counter
  nBallCount += 3
  // Prepare of the next balls
  PrepareNextBalls()

Return

*--------------------------------------------------------*
Procedure PrepareNextBalls()
*--------------------------------------------------------*
LOCAL x, y, nCnt

  if nBallCount >= 79
      GameEnd()
      Return
  endif
  for nCnt := 1 to 3
      // Determine of color one from three next balls
      aNextBalls[nCnt] := Random(nColorNum)
      // Determine of position one from three next balls
      X := Random(9)
      Y := Random(9)
      do while aGameField[X,Y] # 0
         X := Random(9)
         Y := Random(9)
      end
      // Mark of ball's position on the field
      aGameField[X,Y] := aNextBalls[nCnt]+20
      aNextBallsPos[nCnt][1] := X
      aNextBallsPos[nCnt][2] := Y
  next

Return

*--------------------------------------------------------*
Procedure GameEnd()
*--------------------------------------------------------*

	Form_1.Timer_1.Release
	Form_1.MenuPause.Enabled := .F.
	lBackable := .F.
	Form_1.MenuBack.Enabled := .F.
	Form_1.MenuSave.Enabled := .F.
	Form_1.MenuOver.Enabled := .F.
	nGameState := GameEnded

	SaveResult()

	Form_1.Title := PROGRAM

Return

*--------------------------------------------------------*
Procedure OnTimer()
*--------------------------------------------------------*
  nGameTime := Seconds() - nStartTime
  if nGameState = GamePlaying
	Form_1.Title := PROGRAM + ' - ' + TimeAsString(nGameTime)
  endif

Return

*--------------------------------------------------------*
Procedure DrawNextBalls()
*--------------------------------------------------------*
LOCAL nCnt, cImage

if lShowNextColors
  for nCnt := 1 to 3
	cImage := "Next_" + Ltrim(Str(nCnt))
	SetProperty("Form_1", cImage, "Picture", aNextBM[aNextBalls[nCnt]])
  next
endif

Return

*--------------------------------------------------------*
Procedure DrawGameField()
*--------------------------------------------------------*
LOCAL row, col, cImage, nCell

   lBusy := .T.

   FOR row := 1 TO nRowCol
	FOR col := 1 TO nRowCol
		nCell := aGameField[Col,Row]
		if .not. lShowNextCells .and. (nCell > 20)
			nCell := 0
		endif
		if lCurrCell .and. (aCurrCellPos[1] == Col) .and. (aCurrCellPos[2] == Row)
			nCell += 10
		endif
		cImage := "Cell_" + Ltrim(Str((row - 1) * nRowCol + col))
		do case
			case nCell = 0
				SetProperty("Form_1", cImage, "Picture", 'Cell') // Empty cell
			case nCell > 0 .and. nCell <= nColorNum
				SetProperty("Form_1", cImage, "Picture", aBallBM[nCell]) // Ball
			case nCell > 10 .and. nCell <= nColorNum + 10
				SetProperty("Form_1", cImage, "Picture", aCurrBM[nCell-10]) // Selected ball
			case nCell > 20 .and. nCell <= nColorNum + 20
				SetProperty("Form_1", cImage, "Picture", aDestBM[nCell-20]) // Next ball
			case nCell < 0
				SetProperty("Form_1", cImage, "Picture", 'Path') // Ball's way
		endcase
	NEXT
   NEXT

   DO EVENTS
   lBusy := .F.

Return

*--------------------------------------------------------*
Function GetCellPos( cName )
*--------------------------------------------------------*
LOCAL row, col, cImage, aResult := {}

   FOR row := 1 TO nRowCol
	FOR col := 1 TO nRowCol
		cImage := "Cell_" + Ltrim(Str((row - 1) * nRowCol + col))
		if cImage == cName
			aadd(aResult, col)
			aadd(aResult, row)
			Exit
		endif
	NEXT
   NEXT

Return aResult

*--------------------------------------------------------*
Procedure GamePause()
*--------------------------------------------------------*
  if nGameState = GamePlaying
      nGameState := GamePaused
      Form_1.Timer_1.Enabled := .F.
      nPauseTime := Seconds()
      Form_1.Title := PROGRAM + ' - Paused'
  endif

Return

*--------------------------------------------------------*
Procedure GameResume()
*--------------------------------------------------------*
  if nGameState = GamePaused
      nGameState := GamePlaying
      Form_1.Title := PROGRAM
      nStartTime := nStartTime + ( Seconds() - nPauseTime )
      Form_1.Timer_1.Enabled := .T.
  endif

Return

*--------------------------------------------------------*
Procedure SaveGame()
*--------------------------------------------------------*
LOCAL nVerMajor := 1, nVerMinor := 2, cName := cUserName, cSaveFile

   GamePause()

   cName := Ltrim( InputBox( 'Enter your name:', 'Save Game To File', cName, 60000, cName ) )

   IF EMPTY(cName)
      // Continue of abortive game
      GameResume()
      Return
   ELSE
      cUserName := cName
   ENDIF

   cSaveFile := Putfile( { {'EZLines saved games (*.ezl)', '*.ezl'} }, 'Save Game As', ;
			cFilePath( hb_ArgV(0) ), .f., cName )

  if Empty(cSaveFile)
      // Continue of abortive game
      GameResume()
      Return
  endif

  BEGIN INI FILE cSaveFile
	SET SECTION "Version" ENTRY "Major" TO nVerMajor
	SET SECTION "Version" ENTRY "Minor" TO nVerMinor
	SET SECTION "Save" ENTRY "Player" TO cName
	SET SECTION "Save" ENTRY "GameField" TO aGameField
	SET SECTION "Save" ENTRY "GameScore" TO nGameScore
	SET SECTION "Save" ENTRY "BallCount" TO nBallCount
	SET SECTION "Save" ENTRY "NextBalls" TO aNextBalls
	SET SECTION "Save" ENTRY "NextBallsPos" TO aNextBallsPos
	SET SECTION "Save" ENTRY "Time" TO Seconds() - nStartTime
  END INI

  if !File(cSaveFile)
	MsgStop("Save of game have been failed!", "Please, try again")
  endif

  GameResume()

Return

*--------------------------------------------------------*
Procedure LoadGame()
*--------------------------------------------------------*
LOCAL nVerMajor := 1, nVerMinor := 2, cSaveFile, nTime := 0

  if !IsControlDefined(Timer_1, Form_1)
	DEFINE TIMER Timer_1 OF Form_1 INTERVAL 1000 ACTION OnTimer()
	nStartTime := Seconds()
  endif

  GamePause()

  cSaveFile := Getfile( { {'EZLines saved games (*.ezl)', '*.ezl'} }, 'Load Game From', ;
			cFilePath( hb_ArgV(0) ) )

  if Empty(cSaveFile)
      // Continue of abortive game
      GameResume()
      if nGameState == GameReady .or. nGameState == GameEnded
		Form_1.Timer_1.Release
      endif
      Return
  endif

  nGameScore := 0 ; nBallCount := 0
  BEGIN INI FILE cSaveFile
	GET nVerMajor SECTION "Version" ENTRY "Major"
	GET nVerMinor SECTION "Version" ENTRY "Minor"
	GET cUserName SECTION "Save" ENTRY "Player"
	GET aGameField SECTION "Save" ENTRY "GameField"
	GET nGameScore SECTION "Save" ENTRY "GameScore"
	GET nBallCount SECTION "Save" ENTRY "BallCount"
	GET aNextBalls SECTION "Save" ENTRY "NextBalls"
	GET aNextBallsPos SECTION "Save" ENTRY "NextBallsPos"
	GET nTime SECTION "Save" ENTRY "Time"
  END INI

  if nVerMajor #1 .and. nVerMinor # 2
      MsgStop("The version of the preserved game does not correspond to the version of program!", ;
		"Version mismatch")
      // Continue of abortive game
      GameResume()
      Return
  endif

  Form_1.MenuPause.Enabled := .T.
  Form_1.MenuSave.Enabled := .T.
  Form_1.MenuOver.Enabled := .T.

  lBackable := .F.
  Form_1.MenuBack.Enabled := .F.

  nStartTime := Seconds() - nTime
  nPauseTime := Seconds()
  nGameState := GamePaused

  GameResume()

  // Redraw of field
  DrawGameField()
  // Redraw of the next balls
  DrawNextBalls()
  // Redraw of scores
  ShowScores()

Return

*--------------------------------------------------------*
Procedure Settings()
*--------------------------------------------------------*

DEFINE WINDOW Form_2 AT 0, 0 WIDTH 306 HEIGHT 322 + IF(IsXPThemeActive(), 6, 0) ;
	TITLE "Settings" ;
	MODAL ;
	NOSIZE ;
	FONT 'MS Sans Serif' SIZE 9

    DEFINE BUTTON Button_1
        ROW    260
        COL    60
        WIDTH  80
        HEIGHT 26
        CAPTION "OK"
        ACTION ( OkClick(), ThisWindow.Release )
        DEFAULT .T.
        TABSTOP .T.
        VISIBLE .T.
    END BUTTON

    DEFINE BUTTON Button_2
        ROW    260
        COL    150
        WIDTH  80
        HEIGHT 26
        CAPTION "Cancel"
        ACTION ThisWindow.Release
        TABSTOP .T.
        VISIBLE .T.
    END BUTTON

    DEFINE FRAME Frame_1
        ROW    10
        COL    10
        WIDTH  130
        HEIGHT 136
        CAPTION "Next balls"
    END FRAME

    DEFINE RADIOGROUP RadioGroup_1
        ROW    30
        COL    20
        WIDTH  110
        HEIGHT 105
        OPTIONS { 'No show', 'Colors only', 'Colors and field' }
        VALUE nNext + 1
        ONCHANGE nNext := Form_2.RadioGroup_1.Value - 1
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .T.
        SPACING 35
    END RADIOGROUP

    DEFINE FRAME Frame_2
        ROW    154
        COL    10
        WIDTH  130
        HEIGHT 96
        CAPTION "Animation"
    END FRAME

    DEFINE CHECKBOX Check_1
        ROW    174
        COL    20
        WIDTH  100
        HEIGHT 28
        CAPTION "Delete of line"
        VALUE lAnimateDelete
        ONCHANGE Nil
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .T.
    END CHECKBOX

    DEFINE CHECKBOX Check_2
        ROW    204
        COL    20
        WIDTH  100
        HEIGHT 28
        CAPTION "Moving of ball"
        VALUE lAnimateMove
        ONCHANGE Form_2.Check_5.Enabled := Form_2.Check_2.Value
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .T.
    END CHECKBOX

    DEFINE FRAME Frame_3
        ROW    10
        COL    150
        WIDTH  140
        HEIGHT 240
        CAPTION "Sound"
    END FRAME

    DEFINE CHECKBOX Check_3
        ROW    30
        COL    160
        WIDTH  100
        HEIGHT 28
        CAPTION "Delete of line"
        VALUE lSoundDelete
        ONCHANGE Nil
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .T.
    END CHECKBOX

    DEFINE CHECKBOX Check_4
        ROW    60
        COL    160
        WIDTH  100
        HEIGHT 28
        CAPTION "Selected ball"
        VALUE lSoundSelect
        ONCHANGE Nil
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .T.
    END CHECKBOX

    DEFINE CHECKBOX Check_5
        ROW    90
        COL    160
        WIDTH  100
        HEIGHT 28
        CAPTION "Moving of ball"
        VALUE lSoundMove
        ONCHANGE Nil
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .T.
    END CHECKBOX

    DEFINE CHECKBOX Check_6
        ROW    120
        COL    160
        WIDTH  120
        HEIGHT 28
        CAPTION "Moving is impossible"
        VALUE lSoundStop
        ONCHANGE Nil
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .T.
    END CHECKBOX

    DEFINE CHECKBOX Check_7
        ROW    150
        COL    160
        WIDTH  120
        HEIGHT 28
        CAPTION "Victory / Fail"
        VALUE lSoundResult
        ONCHANGE Nil
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .T.
    END CHECKBOX

    ON KEY ESCAPE ACTION Form_2.Release

END WINDOW

Form_2.Check_5.Enabled := lAnimateMove

CENTER WINDOW Form_2

ACTIVATE WINDOW Form_2

Return

*--------------------------------------------------------*
Procedure OkClick()
*--------------------------------------------------------*
	switch nNext
		case 0
			lShowNextColors := .F.
			lShowNextCells := .F.
			exit
		case 1
			lShowNextColors := .T.
			lShowNextCells := .F.
			exit
		case 2
			lShowNextColors := .T.
			lShowNextCells := .T.
	endswitch

	lAnimateDelete := Form_2.Check_1.Value
	lAnimateMove := Form_2.Check_2.Value
	lSoundDelete := Form_2.Check_3.Value
	lSoundSelect := Form_2.Check_4.Value
	lSoundMove := Form_2.Check_5.Value
	lSoundStop := Form_2.Check_6.Value
	lSoundResult := Form_2.Check_7.Value

	BEGIN INI FILE cIniFile
		SET SECTION "Next" ENTRY "ShowNext" TO nNext
		SET SECTION "Sound" ENTRY "Delete" TO lSoundDelete
		SET SECTION "Sound" ENTRY "Select" TO lSoundSelect
		SET SECTION "Sound" ENTRY "Move" TO lSoundMove
		SET SECTION "Sound" ENTRY "Stop" TO lSoundStop
		SET SECTION "Sound" ENTRY "Result" TO lSoundResult
		SET SECTION "Animation" ENTRY "Delete" TO lAnimateDelete
		SET SECTION "Animation" ENTRY "Move" TO lAnimateMove
	END INI

Return

*--------------------------------------------------------*
Function OpenScore( cData )
*--------------------------------------------------------*
LOCAL lFirst := .f., cIndex := cFileNoExt( cData ), cIndex2 := cFileNoExt( cData ) + "2"

   If !File( cData )
	DBcreate( cData, { {"NAME", "C", 30, 0}, {"SCORE", "N", 6, 0}, {"TIME", "C", 7, 0}  } )
	lFirst := .t.
   EndIF

   USE ( cData ) ALIAS SCORE SHARED NEW

   If !NetErr()
      If !File( cIndex2 + IndexExt() )
         INDEX ON UPPER(FIELD->NAME) TO ( cIndex2 )
      EndIF
      If !File( cIndex + IndexExt() )
         INDEX ON DESCEND(FIELD->SCORE) TO ( cIndex )
      EndIF
   Else
	MsgStop("Score file have been locked", "Please, try again")
	Return .F.
   EndIF

   SET INDEX TO ( cIndex ), ( cIndex2 )
   SCORE->( DBGoTop() )

   IF lFirst
	APPEND BLANK
	SCORE->NAME  := "Author"
	SCORE->SCORE := 1154
	SCORE->TIME  := "0:56:27"
   EndIF

Return .T.

*--------------------------------------------------------*
Procedure ShowTop10()
*--------------------------------------------------------*
LOCAL cResult := "", n := 1

   SCORE->( DBGoTop() )
   DO WHILE SCORE->( RecNo() ) <= 10 .AND. !EOF()
	cResult += Str(n++, 3) + ". " + PADR(ALLTRIM(SCORE->NAME), 30, ".") + ;
		Str(SCORE->SCORE, 6) + "  -  " + SCORE->TIME + CRLF
	SCORE->( DBskip() )
   ENDDO
   SCORE->( DBGoTop() )

   MsgInfo( cResult, "Top 10" )

Return

*--------------------------------------------------------*
Static Procedure SaveResult()
*--------------------------------------------------------*
LOCAL cName := cUserName

   cName := Ltrim( InputBox( 'Enter your name:', 'Save Result: ' + LTRIM(STR(nGameScore)), cName, 60000, cName ) )

   IF EMPTY(cName)
	cName := "NoName"
   ELSE
	cUserName := cName
	BEGIN INI FILE cIniFile
		SET SECTION "Player" ENTRY "Name" TO cUserName
	END INI
   ENDIF

   SET ORDER TO 2
   SEEK UPPER(cName)
   IF SCORE->( Found() )
	IF SCORE->SCORE < nGameScore
		Rlock()
		SCORE->SCORE := nGameScore
		SCORE->TIME := TimeAsString(nGameTime)
		dbUnlock()
		if lSoundResult
			PLAY WAVE 'Victory' FROM RESOURCE
		endif
	ELSE
		if lSoundResult
			PLAY WAVE 'Fail' FROM RESOURCE
		endif
	ENDIF
   ELSE
	APPEND BLANK
	Rlock()
	SCORE->NAME := cName
	SCORE->SCORE := nGameScore
	SCORE->TIME := TimeAsString(nGameTime)
	dbUnlock()
   ENDIF
   SET ORDER TO 1
   SCORE->( DBGoTop() )

Return

*--------------------------------------------------------*
Function ShowHelp() // Help
*--------------------------------------------------------*
return MsgInfo( padc("Keyboard Control:", 40) + CRLF + ;
	padc(Repl("-", 22), 44) + CRLF + CRLF + ;
	"F2       - begin of the new game" + CRLF + ;
	"F3       - show of the Top 10" + CRLF + CRLF + ;
	"Ctrl+L - load of the preserved game" + CRLF + ;
	"Ctrl+S - save of the current game" + CRLF + CRLF + ;
	"Ctrl+P - pause/resume of the game" + CRLF + ;
	"Ctrl+Z - one move back of the game" + CRLF + ;
	"Ctrl+E - end of the game" + CRLF + ;
	"Ctrl+X - exit from the program", "Help" )

*--------------------------------------------------------*
Function MsgAbout() // About
*--------------------------------------------------------*
return MsgInfo( padc(PROGRAM + VERSION + " - FREEWARE", 40) + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	padc("eMail: gfilatov@inbox.ru", 40) + CRLF + CRLF + ;
	padc("This program is Freeware!", 36) + CRLF + ;
	padc("Copying is allowed!", 40), "About" )

*--------------------------------------------------------*
Function TimeAsString( nSeconds )
*--------------------------------------------------------*
Return StrZero(Int(Mod(nSeconds / 3600, 24)), 1, 0) + ":" + ;
	  StrZero(Int(Mod(nSeconds / 60, 60)), 2, 0) + ":" + ;
	  StrZero(Int(Mod(nSeconds, 60)), 2, 0)


#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

HB_FUNC( RANDOM )
{
   hb_retni( rand() % hb_parni( 1 ) + 1 );
}

HB_FUNC( RANDOMIZE )
{
   srand( GetTickCount() % 32000 );
}

#pragma ENDDUMP
