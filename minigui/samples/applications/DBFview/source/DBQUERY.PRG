#include "minigui.ch"

#define COMPILE(cExpr)    &("{||" + cExpr + "}")
#define MsgInfo( c ) MsgInfo( c, PROGRAM, , .f. )

#define Q_FILE  1   // For the aQuery_ array
#define Q_DESC  2
#define Q_EXPR  3

DECLARE WINDOW Form_Query

STATIC Function AddText(cExpr, aUndo_, cText)

  cExpr += cText
  aadd(aUndo_, cText)
  Form_Query.Edit_1.Value := cExpr
  DO EVENTS

Return(NIL)


STATIC Function GetType(cField, aFlds_, cChar)
  local cType, n

  n := len(aFlds_)

  if cField == aFlds_[n]    // Deleted() == Logical
    cType := "L"
  else
    n := ascan(aFlds_, cField)
    cType := valtype((cAlias)->( fieldget(n) ))
    if cType == "M"
      cType := "C"
    elseif cType == "C"
      cChar := padr(cChar, len((cAlias)->( fieldget(n) )))
    endif
  endif

Return(cType)


STATIC Function CheckComp(cType, cComp)
  local lOk := .T.
  local cTemp := left(cComp, 2)

  do case
    case cType $ "ND"
      if cTemp $ "$ ()"
        lOk := .F.
      endif
    case cType == "L"
      if cTemp <> "==" .and. cTemp <> "<>" .and. cTemp <> '""'
        lOk := .F.
      endif
    otherwise     // All are Ok for character variables
      lOk := .T.
  endcase

  if !lOk
    MsgAlert("Invalid comparison for selected data type.")
  endif

Return(lOk)


STATIC Function AddExpr(cExpr, aUndo_, cField, cComp, uVal)
  local cVT, cTemp
  local xFieldVal := (cAlias)->( fieldget(fieldpos(cField)) )

  cVT := alltrim(left(cComp, 2))
  if cVT == '()'
    cTemp := '"' + rtrim(uVal) + '" $ ' + cField
  elseif cVT == '""'
    cTemp := "empty(" + cField + ")"
  else
    cTemp := cField + ' ' + cVT + ' '
    cVT := valtype(uVal)
    do case
      case cVT == 'C'
        cTemp += '"' + padr(uVal, len(xFieldVal)) + '"'
      case cVT == 'N'
        cTemp += ltrim(str(uVal))
      case cVT == 'D'
        cTemp += 'ctod("' + dtoc(uVal) + '")'
      case cVT == "L"
        cTemp += iif(uVal, '.T.', '.F.')
    endcase
  endif

  cTemp += " "

  AddText(@cExpr, aUndo_, cTemp)

Return(NIL)


STATIC Function Undo(cExpr, aUndo_)
  local l := len(aUndo_)
  local x, cTemp := cExpr

  if (x := rat(aUndo_[l], cTemp)) > 0
    cExpr := InsDel(cTemp, x, len(aUndo_[l]), "")
    Form_Query.Edit_1.Value := cExpr
    DO EVENTS
  endif

  asize(aUndo_, l - 1)

Return(NIL)


STATIC Function RunQuery(cExpr)
  local nCurRec := (cAlias)->( recno() )
  local bOldErr := ErrorBlock({|e| QueryError(e) })
  local lOk := .T.
  local nCount := 0

  begin sequence
    (cAlias)->( DbSetFilter(COMPILE(cExpr), cExpr) )
  recover
    (cAlias)->( DbClearFilter() )
    lOk := .F.
  end sequence
  errorblock(bOldErr)

  if !lOk
    (cAlias)->( DbGoTo(nCurRec) )
    Return(lOk)
  endif

  (cAlias)->( DbGoTop() )
  do while !(cAlias)->( EoF() )
    nCount++
    (cAlias)->( DbSkip() )
    if !(cAlias)->( EoF() )
      exit
    endif
  enddo
  DO EVENTS

  if Empty(nCount)
    lOk := .F.
    MsgAlert( aLangStrings[133] )
    (cAlias)->( DbClearFilter() )
    (cAlias)->( DbGoTo(nCurRec) )
  else
    (cAlias)->( DbGoTop() )
  endif

Return(lOk)


STATIC Function SaveQuery(cExpr, aQuery_)
  local cDesc := ""
  local cQFile
  local lAppend := .T., x
  local aMask := { { "DataBase Queries (*.dbq)", "*.dbq" }, ;
                 { "All Files        (*.*)", "*.*"} }

  if !empty(aQuery_[Q_DESC])
    cDesc := alltrim(aQuery_[Q_DESC])
  endif

  cDesc := InputBox( aLangStrings[134]+":" , aLangStrings[135] , cDesc )
  if len(cDesc) == 0  // Rather than empty() because they may hit 'Ok' on
    Return(NIL)       // just spaces and that is acceptable.
  endif

  cQFile := PutFile( aMask, aLangStrings[136], cPath, .t. )
  if empty(cQFile)
    Return(NIL)
  endif
  cQFile := cPath + "\" + cFileNoExt( cQFile ) + ".dbq"
  if !file(cQFile)
    Cr_QFile(cQFile)
  endif

  aQuery_[Q_FILE] := padr(cDBFile, 12)
  aQuery_[Q_DESC] := padr(cDesc, 80)
  aQuery_[Q_EXPR] := cExpr

  IF OpenDataBaseFile( cQFile, "QFile", .T., .F., RddSetDefault() )

    if QFile->( NotDBQ(cQFile) )
      QFile->( DBCloseArea() )
      Return(NIL)
    endif

    QFile->( DBGoTop() )
    do while !QFile->( eof() )
      if QFile->FILENAME == aQuery_[Q_FILE]
        if QFile->DESC == aQuery_[Q_DESC]
          x := MsgYesNoCancel( aLangStrings[137] + "." + CRLF + ;
                         aLangStrings[138], aLangStrings[139], , .f. )
          if x == 6
            lAppend := .F.
          elseif x == 2
            QFile->( DBCloseArea() )
            Return(NIL)
          endif
          exit
        endif
      endif
      QFile->( DBSkip() )
    enddo

    if lAppend
      QFile->( DBAppend() )
    endif
    QFile->FILENAME := aQuery_[Q_FILE]
    QFile->DESC := aQuery_[Q_DESC]
    QFile->EXPR := aQuery_[Q_EXPR]

    QFile->( DBCloseArea() )

    MsgInfo(aLangStrings[140])

  ENDIF

Return(NIL)


STATIC Function LoadQuery(cExpr, aQuery_)
  local cQFile
  local lLoaded := .F., lCancel := .F.
  local aMask := { { "DataBase Queries (*.dbq)", "*.dbq" }, ;
                 { "All Files        (*.*)", "*.*"} }

  cQFile := GetFile(aMask, aLangStrings[141], cPath, .f., .t.)

  if empty(cQFile)
    Return(lLoaded)
  endif

  IF OpenDataBaseFile( cQFile, "QFile", .T., .F., RddSetDefault() )

    if QFile->( NotDBQ(cQFile) )
      QFile->( DBCloseArea() )
      Return(lLoaded)
    elseif QFile->( eof() )
      MsgInfo(cQFile + " " + aLangStrings[142] + "!")
    else
	DEFINE WINDOW Form_Load ;
		AT 0, 0 WIDTH 484 HEIGHT 214 ;
		TITLE aLangStrings[143] + " - " + cQFile ;
		ICON 'CHILD' ;
		MODAL ;
		FONT "MS Sans Serif" ;
		SIZE 8

		DEFINE BROWSE Browse_1
			ROW 10
			COL 10
			WIDTH GetProperty( 'Form_Load', 'Width' ) - 28
			HEIGHT GetProperty( 'Form_Load', 'Height' ) - 78
			HEADERS { "X", aLangStrings[144], aLangStrings[145], aLangStrings[146] }
			WIDTHS { 16, 86, 174, if(QFile->( Lastrec() ) > 8, 160, 176) }
			FIELDS { 'iif(QFile->( deleted() ), " X", "  ")', ;
                                  'QFile->FILENAME', ;
                                  'QFile->DESC', ;
                                  'QFile->EXPR' }
			WORKAREA QFile
			VALUE QFile->( Recno() )
			VSCROLLBAR QFile->( Lastrec() ) > 8
			READONLYFIELDS { .t., .t., .t., .t. }
			ONDBLCLICK Form_Load.Button_1.OnClick
	      END BROWSE


		DEFINE BUTTON Button_1
	        ROW    GetProperty( 'Form_Load', 'Height' ) - 58
       	 COL    186
	        WIDTH  80
       	 HEIGHT 24
	        CAPTION aLangStrings[132]
       	 ACTION iif(LoadIt(aQuery_), ThisWindow.Release, )
	        TABSTOP .T.
       	 VISIBLE .T.
		END BUTTON

		DEFINE BUTTON Button_2
	        ROW    GetProperty( 'Form_Load', 'Height' ) - 58
	        COL    286
       	 WIDTH  80
	        HEIGHT 24
       	 CAPTION aLangStrings[4]
	        ACTION (lCancel := .T., ThisWindow.Release )
       	 TABSTOP .T.
	        VISIBLE .T.
		END BUTTON

		DEFINE BUTTON Button_3
	        ROW    GetProperty( 'Form_Load', 'Height' ) - 58
	        COL    386
       	 WIDTH  80
	        HEIGHT 24
       	 CAPTION aLangStrings[147]
	        ACTION iif(QFile->( DelRec() ), ( Form_Load.Browse_1.Refresh, Form_Load.Browse_1.Setfocus ), )
       	 TABSTOP .T.
	        VISIBLE .T.
		END BUTTON

		ON KEY ESCAPE ACTION Form_Load.Button_2.OnClick

	END WINDOW

	CENTER WINDOW Form_Load

	ACTIVATE WINDOW Form_Load

      if !lCancel
        cExpr := aQuery_[Q_EXPR]
        Form_Query.Edit_1.Value := cExpr
        lLoaded := .T.
      endif

    endif

    QFile->( __DBPack() )
    QFile->( DBCloseArea() )

  ENDIF

Return(lLoaded)


STATIC Function NotDBQ(cQFile)
  local lNot := .F.

  if fieldpos("FILENAME") == 0 .or. ;
     fieldpos("DESC") == 0 .or. ;
     fieldpos("EXPR") == 0
    lNot := .T.
    MsgAlert(cQFile + " " + aLangStrings[148] + ".")
  endif

Return(lNot)


STATIC Function LoadIt(aQuery_)
  local lLoaded := .F.

  if QFile->FILENAME <> padr(cDBFile, 12)
    if MsgYesNo(aLangStrings[149] + "." + CRLF + ;
		aLangStrings[150], aLangStrings[151])
      lLoaded := .T.
    endif
  else
    lLoaded := .T.
  endif

  if lLoaded
    aQuery_[Q_FILE] := alltrim(QFile->FILENAME)
    aQuery_[Q_DESC] := alltrim(QFile->DESC)
    aQuery_[Q_EXPR] := alltrim(QFile->EXPR) + " "
  endif

Return(lLoaded)


Function DelRec()
  local lDel := .F.
  local cMsg, cTitle

  if deleted()
    cMsg := aLangStrings[152]
    cTitle := aLangStrings[153]
  else
    cMsg := aLangStrings[154]
    cTitle := aLangStrings[155]
  endif

  if MsgYesNo(cMsg, cTitle)
    if deleted()
      DBRecall()
    else
      DBDelete()
    endif
    lDel := .T.
  endif

Return(lDel)


STATIC Function QueryError(e)
  local cMsg := aLangStrings[156]

  if valtype(e:description) == "C"
    cMsg := e:description
    cMsg += if(!empty(e:filename), ": " + e:filename, ;
            if(!empty(e:operation), ": " + e:operation, "" ))
  endif

  MsgAlert(cMsg)

Return break(e)

STATIC Procedure Cr_QFile(cQFile)
  local aArray_ := { { "FILENAME", "C",  12, 0 }, ;
			{ "DESC", "C",  80, 0 }, ;
			{ "EXPR", "C", 255, 0 } }

  DBCreate(cQFile, aArray_)

Return

STATIC Function InsDel(cOrig, nStart, nDelete, cInsert)
  local cLeft := left(cOrig, nStart - 1)
  local cRight := substr(cOrig, nStart + nDelete)

Return(cLeft + cInsert + cRight)
