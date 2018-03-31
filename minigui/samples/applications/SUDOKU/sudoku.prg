/* Sudoku Game
   original by Rathi

   edited by Alex Gustow
   (try to use "auto-zoom technique")
*/

#include "minigui.ch"

static aPuzzles, aSudoku, aOriginal
****************************
Function Main

  local bColor
  local nRandom
  local nGuess
  local nArrLen
  local cTime := time()
  local cTitle := "HMG Sudoku"

  // GAL - coefficients for "auto-zooming"
  local gkoefh := 1, ;
        gkoefv := 1
  local gw         // for grid columns width
  local nRatio := GetDesktopWidth()/GetDesktopHeight()

  if nRatio == 4/3
     gkoefh := GetDesktopWidth()/1024
     gkoefv := GetDesktopHeight()/768
  elseif nRatio == 1.6
     gkoefv := GetDesktopHeight()/850
  endif
  gw := 50*gkoefh

  aPuzzles := ImportFromTxt("sudoku.csv")
  nArrLen  := len(aPuzzles)
  aSudoku  := { { 0, 0, 0, 2, 0, 3, 8, 0, 1 }, ;
                { 0, 0, 0, 7, 0, 6, 0, 5, 2 }, ;
                { 2, 0, 0, 0, 0, 0, 0, 7, 9 }, ;
                { 0, 2, 0, 1, 5, 7, 9, 3, 4 }, ;
                { 0, 0, 3, 0, 0, 0, 1, 0, 0 }, ;
                { 9, 1, 7, 3, 8, 4, 0, 2, 0 }, ;
                { 1, 8, 0, 0, 0, 0, 0, 0, 6 }, ;
                { 7, 3, 0, 6, 0, 1, 0, 0, 0 }, ;
                { 6, 0, 5, 8, 0, 9, 0, 0, 0 }  }
  aOriginal := {}

  // GAL
  if file("Help.chm")
    set helpfile to 'Help.chm'
  endif

  if nArrLen > 0
    nRandom := val("0."+substr(cTime,8,1)+substr(cTime,5,1)+substr(cTime,8,2))
    nGuess := int(nRandom * (nArrLen+1))
    if nGuess == 0
      nGuess := 1
    endif
    aSudoku := aclone(aPuzzles[nGuess])
    cTitle := "HMG Sudoku"+" Game no: "+hb_ntos(nGuess)+" of "+hb_ntos(nArrLen)
  endif   

  bColor := { || SudokuBackColor() }

  aOriginal := aclone(aSudoku)

  // GAL
  define window Sudoku ;
    at 0,0 ;
    width 486*gkoefh - iif(isthemed(),0,GetBorderWidth()) ;
    height 550*gkoefv - iif(isthemed(),0,GetTitleHeight()) ;
    main ;
    title cTitle ;
    nomaximize ;    /* GAL */
    nosize          /* GAL */

    define grid Square
      row 10
      col 10
      width 460*gkoefh - iif(isthemed(),0,GetBorderWidth())
      height 445*gkoefv - iif(isthemed(),0,GetTitleHeight()+GetBorderHeight())
      showheaders .f.
      widths  {gw, gw, gw, gw, gw, gw, gw, gw, gw}
      justify {2, 2, 2, 2, 2, 2, 2, 2, 2}
      cellnavigation .T.
      allowedit .T.
      columncontrols { {"TEXTBOX", "CHARACTER", "9"}, ;
                       {"TEXTBOX", "CHARACTER", "9"}, ;
                       {"TEXTBOX", "CHARACTER", "9"}, ;
                       {"TEXTBOX", "CHARACTER", "9"}, ;
                       {"TEXTBOX", "CHARACTER", "9"}, ;
                       {"TEXTBOX", "CHARACTER", "9"}, ;
                       {"TEXTBOX", "CHARACTER", "9"}, ;
                       {"TEXTBOX", "CHARACTER", "9"}, ;
                       {"TEXTBOX", "CHARACTER", "9"} }
      fontname "Arial"
      fontsize 30*gkoefh
      dynamicbackcolor { bColor, bColor, bColor, ;
                         bColor, bColor, bColor, ;
                         bColor, bColor, bColor }
      columnwhen { { || entergrid() }, { || entergrid() }, ;
                   { || entergrid() }, { || entergrid() }, ;
                   { || entergrid() }, { || entergrid() }, ;
                   { || entergrid() }, { || entergrid() }, ;
                   { || entergrid() } }
      columnvalid { { || checkgrid() }, { || checkgrid() }, ;
                    { || checkgrid() }, { || checkgrid() }, ;
                    { || checkgrid() }, { || checkgrid() }, ;
                    { || checkgrid() }, { || checkgrid() }, ;
                    { || checkgrid() } }
      onchange CheckPossibleValues()     
    end grid

    define label valid
      row 460*gkoefv - iif(isthemed(),0,GetTitleHeight())
      col 10
      width 370*gkoefh
      height 30*gkoefv
      fontname "Arial"
      fontsize 18*gkoefv
    end label

    // GAL
    if file("help.chm")
      define statusbar
        statusitem 'F1 - Help' action DISPLAY HELP MAIN
      end statusbar

      on key F1 action DISPLAY HELP MAIN
    endif

    define button Next
      row 460*gkoefv - iif(isthemed(),0,GetTitleHeight())
      col 400*gkoefh - iif(isthemed(),0,GetBorderWidth())
      width 70*gkoefh
      caption "Next"
      action NextGame()
    end button

  end window

  on key ESCAPE of Sudoku action Sudoku.Release()

  RefreshSudokuGrid()

  Sudoku.Center()
  Sudoku.Activate()

Return Nil

****************************
function SudokuBackColor()

  local rowindex := this.cellrowindex
  local colindex := this.cellcolindex

  do case

    case rowindex <= 3 // first row
      do case
        case colindex <= 3 // first col
          return {200,100,100}
        case colindex > 3 .and. colindex <= 6 // second col
          return {100,200,100}
        case colindex > 6 // third col
          return {100,100,200}
      endcase

    case rowindex > 3 .and. rowindex <= 6  // second row       
      do case
        case colindex <= 3 // first col
          return {100,200,100}
        case colindex > 3 .and. colindex <= 6 // second col
          return {200,200,100}
        case colindex > 6 // third col
          return {100,200,100}
      endcase

    case rowindex > 6 // third row       
      do case
        case colindex <= 3 // first col
          return {100,100,200}
        case colindex > 3 .and. colindex <= 6 // second col
          return {100,200,100}
        case colindex > 6 // third col
          return {200,100,100}
      endcase

  endcase

Return Nil           

****************************
function RefreshSudokuGrid()

  local aLine := {}
  local aValue := sudoku.square.value
  local i
  local j

  sudoku.square.DeleteAllItems()

  if len(aSudoku) == 9
    for i := 1 to len(aSudoku)
      asize(aLine,0)
      for j := 1 to len(aSudoku[i])
        if aSudoku[i,j] > 0
          aadd(aLine, str(aSudoku[i,j],1,0))
        else
          aadd(aLine,'')
        endif
      next j
      sudoku.square.AddItem(aLine)   
    next i
  endif

  sudoku.square.value := aValue

Return Nil

****************************
function EnterGrid()

  local aValue := sudoku.square.value

  if len(aValue) > 0
    if aOriginal[ aValue[1], aValue[2] ] > 0
      return .F.
    else
      return .T.
    endif
  endif

Return .F.

****************************
function CheckGrid()

  local nRow := this.cellrowindex
  local nCol := this.cellcolindex
  local nValue := val(alltrim(this.cellvalue))
  local i
  local j
  local nRowStart := int((nRow-1)/3) * 3 + 1
  local nRowEnd := nRowstart + 2
  local nColStart := int((nCol-1)/3) * 3 + 1
  local nColEnd := nColstart + 2

  if nValue == 0
    this.cellvalue := ''
    sudoku.valid.value := ''
    aSudoku[nRow,nCol] := 0
    return .T.
  endif

  if nValue == aSudoku[nRow,nCol]
    return .T.
  endif

  for i := 1 to 9
    if aSudoku[nRow,i] == nValue // row checking
      return .F.
    endif
    if aSudoku[i,nCol] == nValue // col checking
      return .F.
    endif
  next i

  for i := nRowStart to nRowEnd
    for j := nColStart to nColEnd
      if aSudoku[i,j] == nValue
        return .F.
      endif
    next j
  next i

  sudoku.valid.value := ''

  aSudoku[nRow,nCol] := nValue

  CheckCompletion()

Return .T.
   
****************************
function CheckCompletion()
  local i
  local j

  for i := 1 to len(aSudoku)
    for j := 1 to len(aSudoku[i])
      if aSudoku[i,j] == 0
        return Nil
      endif
    next j
  next i

  MsgInfo("Congrats! You won!","Finish")

Return Nil

****************************
function CheckPossibleValues()

  local aValue := sudoku.square.value
  local aAllowed := {}
  local cAllowed := ""
  local nRowStart := int((aValue[1]-1)/3) * 3 + 1
  local nRowEnd := nRowstart + 2
  local nColStart := int((aValue[2]-1)/3) * 3 + 1
  local nColEnd := nColstart + 2
  local lAllowed
  local i
  local j
  local k

  if aValue[1] > 0 .and. aValue[2] > 0

    if aOriginal[aValue[1],aValue[2]] > 0

      sudoku.valid.value := ""

    else

      for i := 1 to 9

        lAllowed := .T.
        for j := 1 to 9
          if aSudoku[aValue[1],j] == i
            lAllowed := .F.
          endif
          if aSudoku[j,aValue[2]] == i
            lAllowed := .F.
          endif
        next j

        for j := nRowStart to nRowEnd
          for k := nColStart to nColEnd
            if aSudoku[j,k] == i
              lAllowed := .F.
            endif
          next k
        next j

        if lAllowed
          aadd(aAllowed,i)
        endif

      next i

      if len(aAllowed) > 0
        for i := 1 to len(aAllowed)
          if i == 1
            cAllowed := cAllowed + alltrim(str(aAllowed[i]))
          else
            cAllowed := cAllowed + ", "+ alltrim(str(aAllowed[i]))
          endif
        next i
        sudoku.valid.value := "Possible Numbers: "+cAllowed
      else
        sudoku.valid.value := "Possible Numbers: Nil"
      endif

    endif

  endif

Return Nil

****************************
function ImportFromTxt( cFilename )

  local aLines := {}
  local handle := fopen(cFilename,0)
  local size1
  local sample
  local lineno
  local eof1
  local linestr := ""
  local c := ""
  local x
  local finished
  local m
  local aPuzzles := {}
  local aPuzzle := {}
  local aRow := {}
  local i
  local j
  local k

  if handle == -1
    return aPuzzles
  endif

  size1 := fseek(handle,0,2)

  if size1 > 65000
    sample := 65000
  else
    sample := size1
  endif

  fseek(handle,0)
  lineno := 1
  aadd(aLines,"")
  c := space(sample)
  eof1 := .F.
  linestr := ""

  do while .not. eof1
    x := fread(handle,@c,sample)

    if x < 1

     eof1 := .T.
     aLines[lineno] := linestr

    else

     finished := .F.

     do while .not. finished

       m := at(chr(13),c)

       if m > 0

          if m == 1

            linestr := ""
            lineno += 1
            aadd(aLines,"")
            if asc(substr(c,m+1,1)) == 10
              c := substr(c,m+2,len(c))
            else
              c := substr(c,m+1,len(c))
            endif

          else

            if len(alltrim(linestr)) > 0
              linestr += substr(c,1,m-1)
            else
              linestr := substr(c,1,m-1)
            endif

            if asc(substr(c,m+1,1)) == 10
               c := substr(c,m+2,len(c))
            else
               c := substr(c,m+1,len(c))
            endif   

            aLines[lineno] := linestr
            linestr := ""
            lineno += 1
            aadd(aLines,"")

          endif

        else

          linestr := c
          finished := .T.

        endif

      enddo

      c := space(sample)

    endif

  enddo

  fclose(handle)

  for i := 1 to len(aLines)
    x := 1
    asize(aPuzzle,0)

    for j := 1 to 9 
       asize(aRow,0)
       for k := 1 to 9
         aadd(aRow,val(alltrim(substr(aLines[i],x,1))))
         x += 2
       next k
       if len(aRow) == 9
         aadd(aPuzzle,aclone(aRow))
       endif   
    next j

    if len(aPuzzle) == 9
      aadd(aPuzzles,aclone(aPuzzle))
    endif   

  next i

Return aPuzzles

****************************
function NextGame()

  local cTime := time()
  local nRandom
  local nGuess
  local nArrLen := len(aPuzzles)

  if nArrLen > 0
    nRandom := val("0."+substr(cTime,8,1)+substr(cTime,5,1)+substr(cTime,8,2))
    nGuess := int(nRandom * (nArrLen+1))
    if nGuess == 0
      nGuess := 1
    endif
    aSudoku := aclone(aPuzzles[nGuess])
    aOriginal := aclone(aSudoku)
    sudoku.title := "HMG Sudoku"+" Game no: "+hb_ntos(nGuess)+" of "+hb_ntos(nArrLen)
  endif   

  RefreshSudokuGrid()

Return Nil
