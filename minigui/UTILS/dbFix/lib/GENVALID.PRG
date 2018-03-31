/*

  GENVALID.PRG    Functions for validating data entry

*/
#include "default.ch"
#include "fileio.ch"


Function AllNum(cVar)
/*
  Returns a logical indicating if alltrim(cVar) is made up entirely of
  numeric digits.  An empty string will return true.
*/
  local x, lOk := .T.
  local cTemp := alltrim(cVar)
  local nLen := len(cTemp)

  for x := 1 to nLen
    if !IsDigit(substr(cTemp, x, 1))
      lOk := .F.
      exit
    endif
  next

Return(lOk)


#ifndef DOS_ONLY

Function AllValid(oDlg)
/*
  Validates all controls on a dialog.  If any control fails, the function
  will return false & focus will be given to the offending control.
  Requires FiveWin.
*/
  local x, lOk := .T.
  local nLen := len(oDlg:aControls)

  CursorWait()

  for x := 1 to nLen
    if !(lOk := oDlg:aControls[x]:lValid())
      oDlg:aControls[x]:SetFocus()
      exit
    endif
  next

  CursorArrow()
  SysRefresh()

Return(lOk)



Function FldValid(oFld)
/*
  Validates all controls on a TFolder.  If any control fails, the folder
  will flip to the page in question and place focus on the failed control.
  Returns true if all edits were passed.
  Requires FiveWin.
*/
  local lOk := .T., d, x
  local nControls, nDialogs := len(oFld:aDialogs)

  CursorWait()

  for d := 1 to nDialogs
    nControls := len(oFld:aDialogs[d]:aControls)
    for x := 1 to nControls
      if !oFld:aDialogs[d]:aControls[x]:lValid()
        oFld:SetOption(d)
        oFld:aDialogs[d]:aControls[x]:SetFocus()
        lOk := .F.
        exit
      endif
    next
  next

  CursorArrow()
  SysRefresh()

Return(lOk)

#endif


Function GenValid(uVar, Edits, Misc1, Misc2, lMsgs, lEmpty)
/*

  Accepts:  uVar    - The variable in question.  Not recommended for logicals.
            Edits   - A comma-delimited string of edit codes.  Alternatively,
                      an array can be passed if the edits can not reasonably
                      be represented as a comma delimited string.
            Misc1   - Varies depending on the value of Edits
            Misc2   - Varies depending on the value of Edits
            lMsgs   - Logical indicating whether you want MsgAlert()s with an
                      appropriate error message.  Defaults to true.
            lEmpty  - Takes the place of the "NE" edit when used.  When true
                      (the default) the entry is allowed to be empty, when
                      false, it is the same as passing "NE" as an edit.

  Returns:  .F.     - Variable failed an edit
            .T.     - Variable passed all edits

  Default behaviors:

    Character vars must be left justified (no leading spaces)
    Trailing spaces are ignored on character variables.
    Character variables are not case sensitive except when using $.
    Entry may be empty (any data type).

  Edit codes:

  The Edits parameter does not necessarily have to be a comma delimited
  string.  If the first character of the string is "D", the character that
  follows will be used as the delimiter.  For example, "D~NE~MCO@#!*," would
  be delimited by the tilde (~) and would be broken into two edits, "NE" and
  "MCO@#!*," respectively.

  Edit codes are processed in the order given.  As soon as any edit fails,
  no further checks are made and the function returns false.  Checks for
  empty variables and leading spaces are processed before other edits.

        Data
  Code  Type  Description

  Generic edits -

  NE    Any   Entry may Not be Empty
  $     Any   Must be one of the values in the array passed as Misc1
  !     Any   Must NOT equal any of the values in the array passed as Misc1.
  R     Any   Range - min and max values are passed as Misc1 & Misc2.  If
              either of these parameters are nil, no respective range check
              is made.  Special: If uVar is character, and Misc1/Misc1 are
              numeric, the range comparison will be made using val(uVar).

  Special edits -

  DIR   C     Must be a valid existing directory (Requires FiveWin)
  FILE  C     Must be a valid filename
  XFILE C     Must be an existing file
  MCY   C     Variable must be a valid MMCCYY combination.  The minimum and
              maximum years allowed can be passed as Misc1 & Misc2
              respectively.  These values should be numeric, such as 1900 or
              2100.  The minimum year defaults to 1.  The entry must have a
              length of 6 and must not contain a slash.
  CYM   C     Just like MCY but in CCYYMM order.
  MY    C     Variable must be a valid MMYY combination.  The entry must have
              a length of 4 and must not contain a slash.
  SSN   CN    Must be a valid SSN (001010001 or greater)
  TEL   CN    Must be a valid 10-digit phone number (1000000000 or greater)
  ZIP5  C     Must be a valid 5-digit zip code
  ZIP9  C     Must be a valid 9-digit zip code.  The last 4 digits may be
              blank.

  Character only -

  LSA   C     Leading Spaces Allowed (they are not allowed by default)
  FF    C     Must Fill Field - no trailing spaces

  @     C     Must contain alpha characters only
  #     C     Must contain numeric characters only
  MCOx  C     Must Contain Only the characters represented by x. x can be a
              list of valid characters or one of the following special items:
              @ = A-Z, use @@ for a literal at-sign, @@@ for both.
              # = 0-9, use ## for a literal pound sign, ### for both.
              Don't forget to include a space if they are allowed!
  MNCx  C     Must Not Contain the characters represented by x.  The same
              formatting rules as MCO apply.

  <@    C     First character must be alpha.
  <#    C     First character must be numeric.
  >@    C     Last character must be alpha.
  >#    C     Last character must be numeric.
  <<    C     Leading characters must match one of the values in an array
              passed as Misc1.  How many leading characters is determined by
              the length of the first value in Misc1.
  >>    C     Trailing characters must match one of the values in an array
              passed as Misc2 (so you can use both << and >>).  Works the
              same as << except that the values are passed in Misc2.
*/
  local lOk := .T.
  local aEdits_ := {}, nEdits, e
  local x, y, nLen
  local cVT := valtype(uVar)
  local cTemp, uTemp
  local cMsg := ""

  default lMsgs := .T.
  default lEmpty := .T.   // Allow things to be empty by default

  // See if Edits is an array or comma delimited string and turn it into the
  // aEdits_ array either way:

  if valtype(Edits) == "A"
    aEdits_ := aclone(Edits)
  elseif valtype(Edits) == "C"
    e := ","
    if left(Edits, 1) == "D"            // Different delimiter?
      e := substr(Edits, 2, 1)
      Edits := substr(Edits, 3)
    endif
    do while (x := at(e, Edits)) > 0
      aadd(aEdits_, left(Edits, x - 1))
      Edits := substr(Edits, x + 1)
    enddo
    aadd(aEdits_, Edits)
  endif

  // Check for an empty var:

  if empty(uVar)
    if ascan(aEdits_, "NE") > 0 .or. !lEmpty
      if lMsgs
        MsgAlert("Entry may not be blank")
      endif
      Return(.F.)
    else
      Return(.T.)   // Allowed to be empty, so we're done.
    endif
  endif

  // Check for leading spaces on a character variable:

  if cVT == "C" .and. ascan(aEdits_, "LSA") == 0
    if left(uVar, 1) == " "
      if lMsgs
        MsgAlert("Entry may not contain leading spaces")
      endif
      Return(.F.)
    endif
  endif

  // Check the rest of the edits:

  nEdits := len(aEdits_)

  for x := 1 to nEdits

    e := aEdits_[x]

    do case
      case e == "$" //----------------------------------------------------- $
        if ascan(Misc1, uVar) == 0
          lOk := .F.
          cMsg := "Entry must be one of the following: "
          nLen := len(Misc1)
          for y := 1 to nLen
            cMsg += Misc1[y] + ", "
          next
          cMsg := left(cMsg, len(cMsg) - 2)
        endif
      case e == "!" //----------------------------------------------------- !
        if ascan(Misc1, uVar) > 0
          lOk := .F.
          cMsg := "Entry must not equal the following value(s): "
          nLen := len(Misc1)
          for y := 1 to nLen
            cMsg += Misc1[y] + ", "
          next
          cMsg := left(cMsg, len(cMsg) - 2)
        endif
      case e == "R" .and. cVT $ "CDN" //------------------------------- Range
        uTemp := uVar
        // If uVar is character, and Misc1 and/or Misc2 are numeric, compare
        // them as numerics:
        if cVT == "C" .and. (valtype(Misc1) == "N" .or. valtype(Misc2) == "N")
          uTemp := val(uVar)
        endif
        if Misc1 <> NIL .and. Misc2 <> NIL
          if uTemp < Misc1 .or. uTemp > Misc2
            lOk := .F.
            cMsg := "Valid range is " + ;
                    cValToChar(Misc1) + " to " + cValToChar(Misc2)
          endif
        else
          if Misc1 <> NIL
            if uTemp < Misc1
              lOk := .F.
              cMsg := "Minimum value is " + cValToChar(Misc1)
            endif
          endif
          if Misc2 <> NIL
            if uTemp > Misc2
              lOk := .F.
              cMsg := "Maximum value is " + cValToChar(Misc2)
            endif
          endif
        endif
      case e == "SSN" .and. cVT $ "CN"  //------------------------------- SSN
        cMsg := "Invalid SSN"
        uTemp := uVar
        if cVT == "C"
          lOk := AllNum(uVar)
          lOk := (len(alltrim(uVar)) == 9)
          uTemp := val(uVar)
        endif
        if uTemp < 1010001
          lOk := .F.
        endif
      case e == "TEL" .and. cVT $ "CN"  //------------------------- Telephone
        cMsg := "Invalid phone number"
        uTemp := uVar
        if cVT == "C"
          lOk := AllNum(uVar)
          uTemp := val(uVar)
        endif
        if uTemp < 1000000000
          lOk := .F.
        endif
      case cVT <> "C" //--- All of the following apply only to character vars
        loop
      case e == "DIR" //------------------------------------------- Directory
        cMsg := "Invalid directory"
        #ifdef DOS_ONLY
        lOk := .T. // We have no way to tell...
        #else
        lOk := lIsDir(StripSlash(alltrim(uVar)))
        #endif
      case e == "FILE" //----------------------------------------------- File
        if !GoodFile(uVar)
          cMsg := "Invalid filename"
          lOk := .F.
        endif
      case e == "XFILE" //------------------------------------- Existing File
        uTemp := alltrim(uVar)
        if !file(uTemp)
          cMsg := "File not found: " + uTemp
          lOk := .F.
        endif
      case e == "MY" //------------------------------------------------- MMYY
        cMsg := "Invalid MMYY value"
        lOk := AllNum(uVar)
        if len(uVar) < 4
          lOk := .F.
        endif
        uTemp := val(left(uVar, 2))
        if uTemp < 1 .or. uTemp > 12
          lOk := .F.
        endif
        uTemp := val(substr(uVar, 3))
        if uTemp < 0 .or. uTemp > 99
          lOk := .F.
        endif
      case e $ "MCY,CYM" //------------------------------------ MMCCYY/CCYYMM
        cMsg := "Invalid MMCCYY value"
        lOk := AllNum(uVar)
        if len(uVar) < 6
          lOk := .F.
        endif
        uTemp := val(left(uVar, 2))
        if uTemp < 1 .or. uTemp > 12
          lOk := .F.
        endif
        uTemp := val(substr(uVar, 3))
        if uTemp < 100 .or. uTemp > 2999
          cMsg := "Valid year range is 0100 to 2999"
          lOk := .F.
        endif
        if lOk
          if Misc1 <> NIL .and. Misc2 <> NIL
            if uTemp < Misc1 .or. uTemp > Misc2
              cMsg := "Valid year range is " + ltrim(str(Misc1)) + ;
                      " to " + ltrim(str(Misc2))
              lOk := .F.
            endif
          else
            if Misc1 <> NIL
              if uTemp < Misc1
                cMsg := "Minimum year is " + ltrim(str(Misc1))
                lOk := .F.
              endif
            endif
            if Misc2 <> NIL
              if uTemp > Misc2
                cMsg := "Maximum year is " + ltrim(str(Misc2))
                lOk := .F.
              endif
            endif
          endif
        endif
      case e $ "ZIP5,ZIP9" //-------------------------------------- Zip Codes
        cMsg := "Invalid zip code"
        cTemp := alltrim(left(uVar, 5))
        lOk := AllNum(cTemp)
        if val(cTemp) == 0 .or. len(cTemp) < 5
          lOk := .F.
        endif
        if lOk .and. e == "ZIP9"
          cTemp := alltrim(right(uVar, 4))
          if !empty(cTemp)
            lOk := AllNum(cTemp) .and. len(cTemp) == 4
          endif
        endif
      case e == "FF" //-------------------------------------- Must Fill Field
        if right(uVar, 1) == " "
          lOk := .F.
          cMsg := "Entry may not have trailing spaces"
        endif
      case e == "@" //-------------------------------------------- Alpha only
        cMsg := "Entry must contain only alpha characters"
        cTemp := alltrim(uVar)
        nLen := len(cTemp)
        for y := 1 to nLen
          if !IsAlpha(substr(cTemp, y, 1))
            lOk := .F.
            exit
          endif
        next
      case e == "#" //------------------------------------------- Digits only
        cMsg := "Entry must contain only numeric digits"
        lOk := AllNum(uVar)
      case left(e, 3) == "MCO" //-------------------------- Must Contain Only
        if FindBad(uVar, substr(e, 4), .F., lMsgs)
          lOk := .F.
          exit  // Does its own message
        endif
      case left(e, 3) == "MNC" //--------------------------- Must Not Contain
        if FindBad(uVar, substr(e, 4), .T., lMsgs)
          lOk := .F.
          exit  // Does its own message
        endif
      case e == "<@" //------------------------------------------ First Alpha
        if !IsAlpha(uVar)
          lOk := .F.
          cMsg := "First character must be alpha"
        endif
      case e == "<#" //------------------------------------------ First Digit
        if !IsDigit(uVar)
          lOk := .F.
          cMsg := "First character must be a digit"
        endif
      case e == ">@" //------------------------------------------- Last Alpha
        if !IsAlpha(right(alltrim(uVar), 1))
          lOk := .F.
          cMsg := "Last character must be alpha"
        endif
      case e == ">#" //------------------------------------------- Last Digit
        if !IsDigit(right(alltrim(uVar), 1))
          lOk := .F.
          cMsg := "Last character must be a digit"
        endif
      case e == "<<" //------------------------------------- First Characters
        cTemp := left(uVar, len(Misc1[1]))
        if ascan(Misc1, cTemp) == 0
          lOk := .F.
          cMsg := "Entry must start with "
          nLen := len(Misc1)
          for y := 1 to nLen
            cMsg += Misc1[y] + ", "
          next
          cMsg := left(cMsg, len(cMsg) - 2)
        endif
      case e == ">>" //-------------------------------------- Last Characters
        cTemp := right(alltrim(uVar), len(Misc2[1]))
        if ascan(Misc2, cTemp) == 0
          lOk := .F.
          cMsg := "Entry must end with "
          nLen := len(Misc2)
          for y := 1 to nLen
            cMsg += Misc2[y] + ", "
          next
          cMsg := left(cMsg, len(cMsg) - 2)
        endif
    endcase

    if !lOk
      if lMsgs
        MsgAlert(cMsg)
      endif
      exit
    endif

  next

Return(lOk)



STATIC Function FindBad(uVar, cChars, lNotAllowed, lMsgs)
  local x, a, c, cTemp, nLen
  local lBad := .F.
  local cFind := ""

  // Parse cChars to get list of valid/invalid characters:

  cTemp := upper(cChars)
  nLen := len(cTemp)

  for x := 1 to nLen
    c := substr(cTemp, x, 1)
    if c == "@"
      if substr(cTemp, x + 1, 1) == c       // Is this a literal?
        cFind += c
        x++
      else                                  // Nope - add alpha characters
        cFind += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      endif
    elseif c == "#"
      if substr(cTemp, x + 1, 1) == c       // Is this a literal?
        cFind += c
        x++
      else                                  // Nope - add digits
        cFind += "1234567890"
      endif
    else                                    // Regular character
      cFind += c
    endif
  next

  // Go through the input and look for characters in cFind:

  cTemp := upper(alltrim(uVar))
  nLen := len(cTemp)

  for x := 1 to nLen
    c := substr(cTemp, x, 1)
    a := at(c, cFind)
    if lNotAllowed
      if a > 0                              // Found and not allowed?
        lBad := .T.
        exit
      endif
    elseif a == 0                           // Not found and needs to be?
      lBad := .T.
      exit
    endif
  next

  // If a bad character was found, identify it:

  if lBad .and. lMsgs
    if c == " "
      MsgAlert("Entry may not contain spaces")
    else
      MsgAlert("Invalid character in position " + ltrim(str(x)) + ": " + c)
    endif
  endif

Return(lBad)



Function GoodFile(cFile)
/*
  Returns a logical indicating whether the given filename is valid or not.
  Passing an empty filename will return false.
  If the file exists, the function returns true.
  If the file can be CREATED, the function returns true.
*/
  local h, lOk := .F.

  if file(cFile)
    lOk := .T.
  else
    if (h := fcreate(cFile)) <> F_ERROR
      fclose(h)
      ferase(cFile)
      lOk := .T.
    endif
  endif

Return(lOk)



