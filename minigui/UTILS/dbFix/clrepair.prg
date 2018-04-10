/*

  REPAIR.PRG   Main Database Repair Function

*/
#include "cldbfix.ch"
#include "error.ch"

#define CRLF      chr(13)+chr(10)

#define MAX_64K   65500 // 65516 is the most I can get into a string w/o an overflow.
                        // 65520 is the max memo size as defined by Comix.
#define TYPE_FPT  1
#define TYPE_III  2
#define TYPE_IV   3

#define MEMO_HDR_SIZE   512 // Standard memo header size for all types

#define ERR_BLANK "B"
#define ERR_SIZE  "S"
#define ERR_EOF   "T"

static lLog, hLog, nMemoType, nBlockSize, nMemoEOF, nMaxMemoSize


Function DBRepair(cDbf, cLog, cDonor, cRDD, cJunkChar, ;
                  lPreload, lDeleted, lPartial, lTotal, lCharJunk, lMemoJunk)

  local cTitle := "Database Repair: " + FileParts(cDbf, FP_FILENAME)
  local lOk := .F., lRestore := .F., lRestMemo := .F., lRestIndex := .F.
  local hDBF, nEvery, nBytes, f, i, n, x
  local cTemp, cMsg, cRecord, cField, cBakDbf, cBakIndex, cIndex
  local cMemo, cBakMemo, cMemoDups, cMemoData, hMemo, lMemo := .F.
  local nDBFSize, nRecCount, nHdrLen, nRecLen, nFields
  local aStruct_ := {}, aTemp_ := array(4), cEOF := chr(26)
  local nSaved := 0, nLost := 0, nDamaged := 0, nDeleted := 0
  local nDCount, nProcessed := 0, lDamage
  local cCont := "Correct this error and attempt to continue?"
  local lDonor := !empty(cDonor)
  local lLogDeleted := .F. // GetIni(INI_SECT, "LogDeleted", .F.)
  local lCopyBackup := .F. // GetIni(INI_SECT, "CopyBackup", .F.)
  local lSaveTemp   := .F. // GetIni(INI_SECT, "SaveTemp",   .F.)
  local lEnd := .F.
  local nLastPercent := 0
      
  nMaxMemoSize := 60000 // min(GetIni(INI_SECT, "MaxMemoSize", MAX_64K), MAX_64K)

  nBlockSize := 0

  // Set these "undocumented" INI entries so they're easier to edit:

  // SetIni(INI_SECT, "LogDeleted",  lLogDeleted)
  // SetIni(INI_SECT, "CopyBackup",  lCopyBackup)
  // SetIni(INI_SECT, "SaveTemp",    lSaveTemp)
  // SetIni(INI_SECT, "MaxMemoSize", nMaxMemoSize)

  // Set default values for parameters:

  cDbf := alltrim(cDbf)

  default cLog      := "", ;
          cRDD      := rddSetDefault(), ;
          cJunkChar := "?", ;
          lCharJunk := .F., ;
          lMemoJunk := .F., ;
          lDeleted  := .F., ;
          lPartial  := .F., ;
          lTotal    := .F.

  cLog := alltrim(cLog)

  lLog := !empty(cLog)
  hLog := F_ERROR

  // Make sure required files exist & ask to overwrite those that do:

  if !file(cDbf)
    ? cDbf + " not found."
    Return(.F.)
  endif

  cBakDbf := RevExt(cDBF)

  if file(cBakDbf)
    if !GetYesNo("The backup file " + cBakDbf + " exists.  Overwrite?", .F.)
      Return(.F.)
    endif
  endif

  // If this file is less than 66 bytes, it can't be a dbf!

  if FSize(cDbf) < 66
    ? cDbf + " is too small to be a DBF file (minimum size is 66 bytes)."
    Return(.F.)
  endif

  begin sequence

    // Start the log:

    if lLog
      if file(cLog)
        if !GetYesNo("The log file " + cLog + " exists.  Overwrite?", .F.)
          lLog := .F.
          break
        endif
      endif
      hLog := fcreate(cLog, FC_NORMAL)
      if hLog == F_ERROR
        FileErrMsg(cLog, "creating")
        lLog := .F.
        break
      endif
      LogText("CLDBFix v" + DBFIX_VERSION)
      LogText("Database Repair Log: " + cDbf)
      LogText("Repair started " + dtoc(date()) + " " + time())
      LogText(CRLF + "Repair Options:")
      LogText("Preload memo data................" + transform(lPreload,  "Y"))
      LogText("Save deleted records............." + transform(lDeleted,  "Y"))
      LogText("Save partially damaged records..." + transform(lPartial,  "Y"))
      LogText("  Save totally damaged records..." + transform(lTotal,    "Y"))
      LogText("Allow junk in character fields..." + transform(lCharJunk, "Y"))
      LogText("Allow junk in memo fields........" + transform(lMemoJunk, "Y"))
      LogText("Junk replacement character......." + cJunkChar)
      if lDonor
        LogText(CRLF + "Header Donor database: " + cDonor)
      endif
    endif

    // Convert a three-digit ASCII code into a real replacement character:

    if len(cJunkChar) > 1
      cJunkChar := chr(val(cJunkChar))
    endif

    // See if we can determine what RDD this file was created with, first by
    // finding an index that would give it away, then by looking at the
    // version byte:

    ? "Determining RDD..."
    if inkey() = K_ESC
      break
    endif

    cTemp := cRDD
    cIndex := FindIndex(cDbf, @cTemp)
    if !empty(cIndex)
      cRDD := cTemp
    endif

    cTemp := iif(lDonor, cDonor, cDbf)
    n := fopen(cTemp, FO_READ + FO_SHARED)
    if n == F_ERROR
      FileErrMsg(cTemp)
      break
    endif
    cField := " "
    fread(n, @cField, 1)
    fclose(n)
    n := asc(cField)

    LogText(CRLF + "DBF version byte: " + Nstr(n))

    cMemo := NewExt(cDbf, ".DBT")

    do case
      case n == 2 .or. n == 3 .or. n == 4
        // Database without a memo - use the default RDD
      case n == 11
        // dBase IV without memo
        if cRDD <> "DBFIV" .and. cRDD <> "DBFMDX"
          cRDD := "DBFMDX"
        endif
      case n == 131
        // dBase III with memo
        lMemo := .T.
        if cRDD <> "DBF" .and. cRDD <> "DBFNDX" .and. cRDD <> "DBFNTX"
          cRDD := "DBFNTX"
        endif
      case n == 139
        // dBase IV with memo
        lMemo := .T.
        if cRDD <> "DBFIV" .and. cRDD <> "DBFMDX"
          cRDD := "DBFMDX"
        endif
      case n == 245
        // Comix/DBFCDX/FoxPro with memo
        lMemo := .T.
        cMemo := NewExt(cDbf, ".FPT")
        if cRDD <> "SIXCDX" .and. cRDD <> "DBFCDX"
          cRDD := "SIXCDX"
        endif
      case file(cMemo)  // *.DBT?
        lMemo := .T.
        cRDD := DBT_Type(cMemo, cRDD)
      case file(cMemo := NewExt(cDbf, ".FPT"))
        lMemo := .T.
        if cRDD <> "SIXCDX" .and. cRDD <> "DBFCDX"
          cRDD := "SIXCDX"
        endif
    endcase

    if lMemo
      LogText("Memo file: " + cMemo)
    endif
    if !empty(cIndex)
      LogText("Index file: " + cIndex)
    endif

    LogText("Using " + cRDD + " RDD", .T.)
    LogText("Maximum memo size: " + Nstr(nMaxMemoSize))
    rddSetDefault(cRDD)

    // Make sure the memo file is present if required...

    if lMemo
      if !file(cMemo)
        cMsg := "Memo file not found.  "
        if GetYesNo(cMsg + "Proceed without memo data?", .F.)
          LogText(cMsg + "Proceeding without memo." + CRLF)
          lMemo := .F.
        else
          LogText(cMsg + "Repair cancelled." + CRLF, .T.)
          break
        endif
      endif
    endif

    // Copy the original file to the backup name:

    // Copying is used rather than just renaming due to certain OS errors
    // involving misreported file sizes (such as the Novell Turbo-FAT bug).
    // This can be turned off by changing the "CopyBackup" INI entry.

    // I changed the default to renaming because copying takes so long...

    ? "Creating backup..."
    if inkey() = K_ESC
      break
    endif
    
    cTemp := iif(lCopyBackup, " copied to ", " renamed to ")

    if iif(lCopyBackup, CopyFile(cDbf, cBakDbf), RenFile(cDbf, cBakDbf))
      LogText(CRLF + cDbf + cTemp + cBakDbf)
      ferase(cDbf)
      lRestore := .T.
      if lMemo
        cBakMemo := RevExt(cMemo)
        if iif(lCopyBackup, CopyFile(cMemo, cBakMemo), RenFile(cMemo, cBakMemo))
          lRestMemo := .T.
          LogText(cMemo + cTemp + cBakMemo)
          ferase(cMemo)
        else
          LogText("Failed to create backup of memo.", .T.)
          break
        endif
      endif
      if !empty(cIndex)
        cBakIndex := RevExt(cIndex)
        if RenFile(cIndex, cBakIndex)
          lRestIndex := .T.
          LogText(cIndex + " renamed to " + cBakIndex)
        else
          LogText("Failed to create backup of index.", .T.)
          break
        endif
      endif
    else
      LogText(CRLF + "Failed to create backup of DBF.", .T.)
      break
    endif

    // Read the header from the corrupt file:

    ? "Reading header..."
    if inkey() = K_ESC
      break
    endif

    lOk := .T.

    hDbf := fopen(cBakDbf, FO_READ + FO_EXCLUSIVE)

    if hDbf == F_ERROR
      FileErrMsg(cBakDbf)
      hDbf := NIL
      break
    endif

    if lMemo
      hMemo := fopen(cBakMemo, FO_READ + FO_EXCLUSIVE)
      if hMemo == F_ERROR
        FileErrMsg(cBakMemo)
        hMemo := NIL
        break
      endif
    endif

    nDBFSize := fseek(hDbf, 0, FS_END)
    fseek(hDbf, 0, FS_SET)

    /* Main Header Structure - first 32 bytes

    Pos     Data
    --------------------------
    1       Version byte
    2-4     Last update (ymd)
    5-8     Record count
    9-10    Header length
    11-12   Record length
    13-32   Reserved
    --------------------------
    */

    cRecord := space(32)
    fread(hDbf, @cRecord, 32)

    cField := substr(cRecord, 5, 4)
    nRecCount := CtoN(cField)

    cField := substr(cRecord, 9, 2)
    nHdrLen := CtoN(cField)

    cField := substr(cRecord, 11, 2)
    nRecLen := CtoN(cField)

    if lDonor

      if NetUse(cDonor + " alias Donor readonly", .F.,, .F.) // Don't open index
        nRecLen  := Donor->( recsize() )
        nHdrLen  := Donor->( header() )
        nFields  := Donor->( fcount() )
        aStruct_ := Donor->( DBStruct() )
        Donor->( DBCloseArea() )
      else
        lOk := .F.
        break
      endif

    else

      /*

      Try to find the actual end of the header to see if it matches the
      header length read from the file.

      In a Clipper database where nHdrLen will always be an even number,
      we should find chr(13)+chr(0) at offset (nHdrLen - 2).  In any case
      it will always be on a 32-byte boundary at offset 64 or greater.

      For dBase databases, nHdrLen will be an odd number and the chr(13)
      should be found at (nHdrLen - 1).

      */

      lOk := .F.
      i := chr(13)
      cTemp := space(32)

      n := 64 // This is the earliest place it could be (main hdr + 1 field)
      fseek(hDbf, n, FS_SET)

      do while fread(hDbf, @cTemp, 32) == 32
        if left(cTemp, 1) == i // Found it!
          lOk := .T.
          n++
          if substr(cTemp, 2, 1) == chr(0)
            n++
          endif
          exit
        endif
        n += 32
      enddo

      fseek(hDbf, 32, FS_SET) // Return to the end of the main file header

      /*

      If unable to find the terminator, that part of the file must have
      been damaged so we'll have to go by the value from the header.  If
      we did find it, make sure it matches:

      */

      if lOk .and. n <> nHdrLen
        // "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
        ?  "The file header reports the header length as " + Nstr(nHdrLen) + ", but the header terminator"
        x := GetYesNo("was found at position " + Nstr(n) + ".  Use the found value instead?")
        if x == NIL
          lOk := .F.
          break
        elseif x
          LogText(CRLF + "Header length changed from " + Nstr(nHdrLen) + ;
                  " to the location of the terminator found at " + Nstr(n) + ".")
          nHdrLen := n
        endif
      endif
      
      lOk := .T.

      // Is the dbf big enough to hold the header?

      if nHdrLen > nDBFSize
        LogText("Database header truncated by eof.  Data is unrecoverable.", .T.)
        lOk := .F.
        break
      endif

      // Retrieve the database structure:

      nFields := (int(nHdrLen / 32) - 1) // Calculate # of fields

      x := 1 // Count the record length.  Start with 1 for the deleted byte.

      for f := 1 to nFields

        /* Field Header Structure

        Pos     Data
        -------------------------------
        1-11    Name (padded w/ chr(0))
        12      Type
        13-16   Reserved
        17      Length
        18      Decimals
        19-32   Reserved
        -------------------------------
        */

        if fread(hDbf, @cRecord, 32) <> 32
          FileErrMsg(cBakDbf, "reading")
          lOk := .F.
          exit
        endif

        // Name:
        cField := substr(cRecord, 1, 11)
        cTemp := left(cField, at(chr(0), cField) - 1)
        if !FieldValid(cTemp, .F.)
          lOk := .F.
          LogText(CRLF + "Field #" + Nstr(f) + " has an invalid field name: " + cTemp)
          ? "Field #" + Nstr(f) + " has an invalid field name." 
          if GetYesNo("Would you like to try and correct it?", .F.)
            do while !FieldValid(cTemp, .F.)
              ACCEPT "Enter the corrected field name (blank to cancel): " TO cTemp
              if empty(cTemp) 
                exit
              endif
              cTemp := upper(left(alltrim(cTemp), 10))
            enddo
            if !empty(cTemp)
              lOk := .T.
              LogText("Field #" + Nstr(f) + " name corrected to " + cTemp)
            endif
          endif
          if !lOk
            exit
          endif
        endif
        aTemp_[DBS_NAME] := alltrim(cTemp)

        // Type:
        cField := substr(cRecord, 12, 1)
        if .not. (cField $ "CDLMN")
          lOk := .F.
          if !IsAlpha(cField)
            cField := "?"
          endif
          LogText(CRLF + "Field " + aTemp_[DBS_NAME] + ;
                  " has an unsupported or invalid data type: " + cField)
          ? "Field " + aTemp_[DBS_NAME] + " has an unsupported or invalid data type (" + cField + ")."
          if GetYesNo("Would you like to try and correct it?", .F.)
            do while at(cField, "CDLMN") == 0
              ACCEPT "Enter the correct data type (C,D,L,M,N, blank to cancel): " TO cField
              if empty(cField)
                exit
              endif
              cField := upper(left(cField, 1))
            enddo
            if !empty(cField)
              lOk := .T.
              LogText("Field " + aTemp_[DBS_NAME] + ;
                      " data type corrected to " + cField)
            endif
          endif
          if !lOk
            exit
          endif
        endif
        aTemp_[DBS_TYPE] := cField

        // Assign type adjective and required length (0=any length)
        do case
          case cField == "C"
            cTemp := "character"
            i := 0
          case cField == "D"
            cTemp := "date"
            i := 8
          case cField == "L"
            cTemp := "logical"
            i := 1
          case cField == "M"
            cTemp := "memo"
            i := 10
          case cField == "N"
            cTemp := "numeric"
            i := 0
        endcase

        // Length:
        cField := substr(cRecord, 17, 1)
        n := asc(cField)
        if i > 0 .and. n <> i
          cMsg := "The " + cTemp + " field " + aTemp_[DBS_NAME] + ;
                  " should have a length of " + Nstr(i) + ;
                  ", but is reporting a length of " + Nstr(n) + "."
          ? cMsg
          if GetYesNo(cCont, .F.)
            LogText(CRLF + cMsg + " - Corrected")
            n := i
          else
            LogText(CRLF + cMsg)
            lOk := .F.
            exit
          endif
        endif
        aTemp_[DBS_LEN] := n

        // Decimals:
        cField := substr(cRecord, 18, 1)
        n := asc(cField)
        if n > 0
          if aTemp_[DBS_TYPE] == "C" // Char field > 255 length
            aTemp_[DBS_LEN] += (n * 256)
            n := 0
          elseif aTemp_[DBS_TYPE] $ "DLM"
            cMsg := "The " + cTemp + " field " + aTemp_[DBS_NAME] + ;
                    " should not have a decimal value but is reporting " + ;
                    Nstr(n) + " decimal places."
            ? cMsg
            if GetYesNo(cCont, .F.)
              LogText(CRLF + cMsg + " - Corrected")
              n := 0
            else
              LogText(CRLF + cMsg)
              lOk := .F.
              exit
            endif
          endif
        endif
        aTemp_[DBS_DEC] := n

        // Add this field to the structure
        aadd(aStruct_, aclone(aTemp_))

        // Add the field length to the record length tally:
        x += aTemp_[DBS_LEN]

        lEnd := inkey() == K_ESC
        if lEnd
          lOk := .F.
          break
        endif

      next

      // Check the record length:

      if lOk .and. x <> nRecLen
        cMsg := "The database header gives a record length of " + ;
                Nstr(nRecLen) + ".  The database structure indicates a" + ;
                " record length of " + Nstr(x) + "."
        ? cMsg
        if GetYesNo(cCont, .F.)
          LogText(CRLF + cMsg + " - Corrected")
          nRecLen := x
        else
          LogText(CRLF + cMsg)
          lOk := .F.
        endif
      endif

      // Did any of the above fail?

      cTemp := cDbf + " can not be repaired due to "

      if !lOk .and. !lEnd
        cMsg := cTemp + "header damage."
        LogText(CRLF + cMsg, .T.)
        break
      endif

    endif // lDonor

    // See how often we need to update the meter (at least every 100 recs):

    nEvery := Crop(1, int((nDBFSize / nRecLen) / 100), 100)

    // Initialize the memo data:

    if lMemo
      if MemoInit(hMemo, cRDD) > 0 // Returns nBlockSize
        // Create a database to detect duplicate memos:
        cMemoDups := Temp_Name(".TMP", FileParts(cDbf, FP_PATH))
        DBCreate(cMemoDups, {{ "POINTER", "C", 10, 0 }, ;
                             { "RECORD",  "N", 10, 0 }, ;
                             { "FIELD",   "C", 10, 0 }}, "SIXCDX")
        if !NetUse(cMemoDups + " alias MemoDups via SIXCDX", .T.)
          lOk := .F.
          break
        endif
        select MemoDups
        index on ("POINTER") tag POINTER
        // Preload all the memo data:
        if lPreload
          cMemoData := Temp_Name(".TMP", FileParts(cDbf, FP_PATH))
          DBCreate(cMemoData, {{ "POINTER",  "C", 10, 0 }, ;
                               { "ERROR",    "C",  1, 0 }, ;
                               { "MEMOTEXT", "M", 10, 0 }}, "SIXCDX")
          if !NetUse(cMemoData + " alias MemoData via SIXCDX", .T.)
            lOk := .F.
            break
          endif
          select MemoData
          index on ("POINTER") tag POINTER
          if !MemoPreload(hMemo, @lEnd)
            lOk := .F.
            break
          endif
        endif
      endif
    endif

    // Create a new copy of the database and open it up:

    ? "Creating new database..."

    DBCreate(cDbf, aStruct_)
    if !NetUse(cDbf + " alias Target", .T.)
      lOk := .F.
      break
    endif

    // Begin reading the data:

    ? "Evaluating data..."
    
    LogText("")

    fseek(hDbf, nHdrLen, FS_SET) // Position to start of data
    
    aTemp_ := array(nFields)

    cRecord := space(nRecLen)

    nBytes := nRecLen

    do while lOk .and. nBytes == nRecLen

      nBytes := fread(hDbf, @cRecord, nRecLen)

      if nBytes == 0 .or. ; // No more data?
         (nBytes == 1 .and. left(cRecord, nBytes) == cEOF)
        exit
      endif

      nProcessed++

      if nBytes < nRecLen // Was this record truncated by eof?
        LogText("Record #" + Nstr(nProcessed) + ;
                " truncated by eof after " + Nstr(nBytes) + " bytes.")
        cRecord := left(cRecord, nBytes)
      endif

      if !lDeleted // Ignore deleted records?
        if left(cRecord, 1) == "*"
          if lLogDeleted
            LogText("Deleted record #" + Nstr(nProcessed) + " discarded.")
          endif
          nDeleted++
          loop
        endif
      endif

      nDCount := 0 // Count the number of damaged fields

      x := 2
      for f := 1 to nFields
        cMsg := "Record #" + Nstr(nProcessed) + ;
                " field " + aStruct_[f, DBS_NAME] + " "
        cField := substr(cRecord, x, aStruct_[f, DBS_LEN])
        x += aStruct_[f, DBS_LEN]
        do case
          case len(cField) == 0 //-------------------------- Truncated by EOF
            nDCount++
            LogText(cMsg + "truncated by eof.")
            aTemp_[f] := NIL
          case aStruct_[f, DBS_TYPE] == "C" //--------------------- Character
            // Allow anything unless checking for junk
            if !lCharJunk
              if HasJunk(@cField, .F., cJunkChar)
                LogText(cMsg + "contains junk.")
                nDCount++
              endif
            endif
            aTemp_[f] := cField
          case aStruct_[f, DBS_TYPE] == "D" //-------------------------- Date
            // Dates must be valid or blank:
            aTemp_[f] := StoD(cField)
            if dtos(aTemp_[f]) <> cField
              LogText(cMsg + "invalid date (" + cField + ")")
              nDCount++
            endif
          case aStruct_[f, DBS_TYPE] == "L" //----------------------- Logical
            // Logicals must be T or F.
            // Blank and ? are also valid for uninitialized data.
            aTemp_[f] := (cField == "T")
            if !(cField $ "TF ?")
              LogText(cMsg + "invalid logical (" + cField + ")")
              nDCount++
            endif
          case aStruct_[f, DBS_TYPE] == "M" //-------------------------- Memo
            aTemp_[f] := ""
            if nBlockSize > 0 .and. !empty(cField)
              n := val(cField)
              if n > 0 .and. str(n, 10, 0) == cField
                if (n * nBlockSize) > nMemoEOF
                  LogText(cMsg + "memo pointer * blocksize > eof: " + ;
                                 alltrim(cField))
                  nDCount++
                else
                  lDamage := MemoDupe(cField, cMsg, ;
                                      aStruct_[f, DBS_NAME], nProcessed)
                  if lPreLoad
                    cTemp := MemoSeek(cField, cMsg, @lDamage)
                  else
                    cTemp := MemoRead(hMemo, cField, cMsg, @lDamage)
                  endif
                  if !empty(cTemp)
                    if !lMemoJunk
                      if HasJunk(@cTemp, .T., cJunkChar)
                        lDamage := .T.
                        // If the whole thing is junk, don't bother saving it.
                        if AllJunk(cTemp, cJunkChar)
                          cTemp := ""
                          LogText(cMsg + "is 100% junk, memo discarded.")
                        else
                          LogText(cMsg + "contains junk.")
                        endif
                      endif
                    endif
                    aTemp_[f] := cTemp
                  endif
                  if lDamage
                    nDCount++
                  endif
                endif
              else
                LogText(cMsg + "invalid memo pointer (" + cField + ")")
                nDCount++
              endif
            endif
          case aStruct_[f, DBS_TYPE] == "N" //----------------------- Numeric
            // Numbers must have the correct number of decimal places.
            // Blank numbers (including lone decimal points) are normal for
            // uninitialized data.
            n := val(cField)
            cTemp := str(n, aStruct_[f, DBS_LEN], aStruct_[f, DBS_DEC])
            if !empty(cField)
              if cTemp <> cField .and. alltrim(cField) <> "."
                LogText(cMsg + "invalid number (" + cField + ")")
                nDCount++
              endif
            endif
            aTemp_[f] := val(cTemp)
        endcase
        if !lPartial .and. nDCount > 0  // Not saving damaged records?
          nDCount := nFields // Pretend it's a total loss and move on.
          exit
        endif
      next

      if nDCount == nFields .and. !lTotal  // Was this record totalled?
        LogText("Record #" + Nstr(nProcessed) + " lost to corruption.")
        nLost++
        loop
      endif

      Target->( DBAppend() ) // Add the record to the database
      for f := 1 to nFields
        Target->( fieldput(f, aTemp_[f]) )
      next

      if left(cRecord, 1) == "*" // Was this record deleted?  Preserve that.
        Target->( DBDelete() )
      endif

      if nDCount > 0 // Count the damaged/saved records
        // Log entry for easy lookup when the record numbers don't match:
        if Target->( recno() ) <> nProcessed
          LogText("Target record #" + Nstr(Target->( recno() )) + ;
                 " contains damaged data.")
        endif
        nDamaged++
      else
        nSaved++
      endif

      if nProcessed % nEvery == 0
        x := fseek(hDbf, 0, FS_RELATIVE)
        x := round((x / nDBFSize) * 100, 0)
        if (x % 10 == 0) .and. (x <> nLastPercent)
          ? "Repair " + Nstr(x) + "% complete"
          nLastPercent := x
        endif
        lEnd := inkey() == K_ESC
        if lEnd
          lOk := .F.
          break
        endif
      endif

    enddo

    Target->( DBCommit() )

  end sequence

  DBCloseAll()

  if !lSaveTemp
    if !empty(cMemoDups)
      ferase(cMemoDups)
      ferase(NewExt(cMemoDups, "CDX")) // IndexOf() uses the default RDD!
    endif
    if !empty(cMemoData)
      ferase(cMemoData)
      ferase(NewExt(cMemoData, "CDX"))
      ferase(NewExt(cMemoData, "FPT"))
    endif
  endif

  if valtype(hDbf) == "N"
    fclose(hDbf)
  endif

  if valtype(hMemo) == "N"
    fclose(hMemo)
  endif

  if lOk

    n := len(Nstr(max(nRecCount, nProcessed))) // Length of longest number

    cMsg := str(nRecCount, n) + ;
            " records were reported in the original DBF header." + CRLF + ;
            str(nProcessed, n) + " records were processed."

    if nDeleted > 0
      cMsg += CRLF + str(nDeleted, n) + " deleted records were discarded."
    endif

    if nLost > 0
      cMsg += CRLF + str(nLost, n) + " records were lost to corruption."
    endif

    cMsg += CRLF + str(nSaved + nDamaged, n) + " records were saved." + ;
            CRLF + iif(nDamaged > 0, str(nDamaged, n), "None") + ;
                   " of the saved records were damaged."

    if lLog
      LogText(CRLF + "*** Repair Summary ***" + CRLF + cMsg, .T.)
      LogText(CRLF + "Repair ended " + dtoc(date()) + " " + time())
    endif

    ? "Repair Complete"
    ?
    
  else

    LogText("")

    if lEnd
      LogText("Repair cancelled by user: " + ;
              dtoc(date()) + " " + time() + CRLF)
    endif

    if lRestore
      ? "Cancelled - Restoring original files..."
      if RenFile(cBakDbf, cDbf)
        LogText(cBakDbf + " restored to " + cDbf)
        if lRestMemo
          if RenFile(cBakMemo, cMemo)
            LogText(cBakMemo + " restored to " + cMemo)
          else
            cMsg := "Failed to restore " + cBakMemo + " to " + cMemo + "!"
            LogText(CRLF + cMsg, .T.)
          endif
        endif
        if lRestIndex
          if RenFile(cBakIndex, cIndex)
            LogText(cBakIndex + " restored to " + cIndex)
          else
            cMsg := "Failed to restore " + cBakIndex + " to " + cIndex + "!"
            LogText(CRLF + cMsg, .T.)
          endif
        endif
      else
        cMsg := "Failed to restore " + cBakDbf + " to " + cDbf + "!"
        LogText(CRLF + cMsg, .T.)
      endif
    endif

    if lEnd
      ? "Repair Cancelled"
    endif

  endif

  if hLog <> F_ERROR
    fclose(hLog)
  endif

Return(lLog)



STATIC Function AllJunk(cMemo, cJunkChar)
/*
  Returns true if a memo consists entirely of cJunkChar and/or whitespace.
*/
  local lAllJunk := .T.
  local cJunk := cJunkChar + " " + chr(9) + chr(10) + chr(13) + chr(141)
  local x, nLen := len(cMemo)

  for x := 1 to nLen
    if .not. substr(cMemo, x, 1) $ cJunk
      lAllJunk := .F.
      exit
    endif
  next

Return(lAllJunk)



STATIC Function CopyFile(cSource, cTarget)

  copy file (cSource) to (cTarget)

Return(file(cTarget))



STATIC Function DBT_Type(cMemo, cDefault)
  local cRDD := cDefault
  local h, cTemp := ""

  if !file(cMemo) // No memo?  Worry about it later...
    Return(cRDD)
  endif

  FindIndex(cMemo, @cTemp) // Got a good index to go by?  Use it.
  if !empty(cTemp)
    Return(cTemp)
  endif

  h := fopen(cMemo, FO_READ + FO_SHARED)

  if h == F_ERROR
    FileErrMsg(cMemo)
    Return(cRDD)
  endif

  // Try to find something in the header to clue us in:

  cTemp := space(MEMO_HDR_SIZE)
  fread(h, cTemp, MEMO_HDR_SIZE)
  fclose(h)

  do case
    case substr(cTemp, 32, 6) == "DBFNTX"
      cRDD := "DBFNTX"
    case substr(cTemp, 32, 6) == "DBFNDX"
      cRDD := "DBFNDX"
    case substr(cTemp, 32, 3) == "DBF"
      cRDD := "DBF"
    case ".NTX" $ cTemp
      cRDD := "DBFNTX"
    case ".NDX" $ cTemp
      cRDD := "DBFNDX"
    case ".MDX" $ cTemp
      cRDD := "DBFMDX"
    case cRDD == "SIXCDX" .or. cRDD == "DBFCDX"
      // Unable to determine anything from the header.  If the default RDD
      // is set to the wrong type (FPT memos), change to DBFNTX since it's
      // the Clipper default.
      cRDD := "DBFNTX"
  endcase

Return(cRDD)



STATIC Function FieldValid(cName, lMsgs)
/*
  Returns a logical indicating if cName is a valid field name
*/
Return(GenValid(cName, "NE,<@,MCO@#_",,, lMsgs))



STATIC Function FileErrMsg(cFile, cVerb)
  local cMsg

  default cVerb := "opening"

  cMsg := "Error #" + Nstr(ferror()) + " " + cVerb + " " + cFile

  if hLog <> F_ERROR
    LogText(cMsg)
  endif

  ? cMsg

Return(NIL)



STATIC Function FindIndex(cDbf, cRDD)
  local aExt_ := { "CDX",   "IDX",    "MDX",    "NDX",    "NTX"    }
  local aRDD_ := { "SIXCDX", "DBFCDX", "DBFMDX", "DBFNDX", "DBFNTX" }
  local cStub := StripExt(cDbf) + "."
  local x, cIndex := ""

  for x := 1 to len(aExt_)
    if file(cStub + aExt_[x])
      cIndex := cStub + aExt_[x]
      cRDD := aRDD_[x]
      exit
    endif
  next

Return(cIndex)



STATIC Function HasJunk(cText, lMemo, cJunkChar)
/*
  Checks a character var for low/high ASCII characters.  If cText is passed
  by reference, these occurences will be replaced with <cJunkChar>.
*/
  local nLen, n, x
  local lJunk := .F.

  #ifdef SHOWJUNK
    local cJunk := ""
  #endif

  nLen := len(rtrim(cText))

  for x := 1 to nLen
    n := asc(substr(cText, x, 1))
    if n < 32 .or. n > 126
      lJunk := iif(lMemo, ;
                   .not. (n == 9 .or. n == 10 .or. n == 13 .or. n == 141), ;
                   .T.)
      if lJunk
        cText := InsDel(cText, x, 1, cJunkChar)
        #ifdef SHOWJUNK
          cJunk += Nstr(n) + " "
        #endif
      endif
    endif
  next

  #ifdef SHOWJUNK
    if lJunk
      LogText(cJunk)
    endif
  #endif

Return(lJunk)



STATIC Function LogText(cMsg, lShow)

  default lShow := .F.
  
  if lLog
    FWriteLn(hLog, cMsg)
  endif
  
  if !lLog .or. lShow
    ? cMsg
  endif

Return(NIL)



STATIC Function MemoDupe(cPointer, cMsg, cFieldName, nRecno)
  local lDupe := .F.

  if MemoDups->( DBSeek(cPointer) )
    lDupe := .T.
    LogText(cMsg + "duplicate memo pointer of record #" + ;
            Nstr(MemoDups->RECORD) + " field " + ;
            alltrim(MemoDups->FIELD) + ": " + ;
            alltrim(cPointer))
  else
    MemoDups->( DBAppend() )
    MemoDups->POINTER := cPointer
    MemoDups->RECORD  := nRecno
    MemoDups->FIELD   := cFieldName
    MemoDups->( XCommit(.T.) )
  endif

Return(lDupe)



STATIC Function MemoInit(hMemo, cRDD)
  local cBuff, cTemp, n

  do case
    case cRDD $ "DBF,DBFNDX,DBFNTX"
      nMemoType := TYPE_III
    case cRDD $ "DBFIV,DBFMDX"
      nMemoType := TYPE_IV
    case cRDD $ "SIXCDX,DBFCDX"
      nMemoType := TYPE_FPT
  endcase

  nMemoEOF := fseek(hMemo, 0, FS_END)

  cBuff := space(MEMO_HDR_SIZE)
  fseek(hMemo, 0, FS_SET)
  n := fread(hMemo, @cBuff, MEMO_HDR_SIZE)

  do case
    case nMemoEOF < MEMO_HDR_SIZE
      // The file is smaller than it's header should be!
      // If the next available block is 1, it means the memo is empty.
      // Otherwise, the file has been badly truncated.
      // In either case, set nBlockSize to zero to avoid any further reads.
      nBlockSize := 0
      cTemp := left(cBuff, 4)
      n := CtoN(cTemp)
      if n == 1 .and. nMemoType == TYPE_III // Empty DBT?
        LogText("Memo file is empty (normal).")
      else
        LogText("Memo file has been truncated and is not recoverable.")
      endif
    case nMemoType == TYPE_III
      nBlockSize := 512 // Standard DBT memo blocks are 512 bytes.
    case nMemoType == TYPE_IV
      cTemp := substr(cBuff, 21, 2)
      nBlockSize := CtoN(cTemp)
    case nMemoType == TYPE_FPT
      cTemp := substr(cBuff, 7, 2)
      nBlockSize := CtoN(cTemp, .T.) // Big-endian value
      if nBlockSize < 32 .or. nBlockSize > 16384
        LogText("Invalid block size in memo header: " + ;
                Nstr(nBlockSize) + ".  Assuming the default of 64.")
        nBlockSize := 64
      endif
      sx_SetMemoBlock(nBlockSize)
  endcase

  if nBlockSize > 0
    LogText(CRLF + "Memo block size: " + Nstr(nBlockSize))
  endif

Return(nBlockSize)



STATIC Function MemoPreload(hMemo, lEnd)
  local cError, cBuffer, cData
  local nMemoLen, n, x
  local nEOM, cEOM := chr(26) // Memo terminator character
  local nEvery, nNext, nPos := MEMO_HDR_SIZE
  local nLastPercent := 0
  
  ? "Preloading memo data..."

  // Refresh 100 times or every megabyte, whichever comes more often:
  nEvery := Crop(nBlockSize, nMemoEOF / 100, 1024 * 1024)
  nEvery -= nEvery % nBlockSize
  nNext := nEvery

  do while nPos < nMemoEOF .and. !lEnd

    fseek(hMemo, nPos, FS_SET)

    cError := ""
    cData  := ""

    if nMemoType == TYPE_III

      n := nBlockSize
      cBuffer := space(n)
      nMemoLen := 0
      nEOM := 0

      do while nEOM == 0 .and. n == nBlockSize
        n := fread(hMemo, @cBuffer, nBlockSize)
        nEOM := at(cEOM, left(cBuffer, n))
        if nEOM > 0
          x := nEOM - 1
        else
          x := n
        endif
        if nMemoLen + x > nMaxMemoSize
          cError := ERR_SIZE // Memo size > max, truncated.
          x := nMaxMemoSize - nMemoLen
          nEOM := 1 // No need for another loop
        elseif n < nBlockSize .and. nEOM == 0
          cError := ERR_EOF // Truncated by EOF
        endif
        cData += left(cBuffer, x)
        nMemoLen += x
      enddo

    else

      nMemoLen := 8 // The first 8 bytes contain memo type & size info
      cBuffer := space(nMemoLen)
      n := fread(hMemo, @cBuffer, nMemoLen)

      if n == nMemoLen
        if nMemoType == TYPE_FPT
          nMemoLen := CtoN(substr(cBuffer, 7, 2), .T.)
        else // TYPE_IV
          nMemoLen := CtoN(substr(cBuffer, 5, 2)) - 8
        endif
        if nMemoLen > 0
          if nMemoLen > nMaxMemoSize
            cError := ERR_SIZE
            nMemoLen := nMaxMemoSize
          endif
          // Read the entire memo in one gulp:
          cBuffer := space(nMemoLen)
          n := fread(hMemo, @cBuffer, nMemoLen)
          cData := left(cBuffer, n)
          if n < nMemoLen
            cError := ERR_EOF
          endif
          nMemoLen += 8 // Add the 8-byte header back in
        endif
      else
        cError := ERR_EOF
        nMemoLen := 0
      endif

    endif // nMemoType

    if nMemoLen == 0
      if empty(cError)
        cError := ERR_BLANK // Blank memo but otherwise no error
      endif
      nMemoLen := nBlockSize // Advance the pointer to the next block
    endif

    MemoData->( DBAppend() )
    MemoData->POINTER  := str(int(nPos / nBlockSize), 10, 0)
    MemoData->ERROR    := cError
    MemoData->MEMOTEXT := cData

    nPos += nMemoLen
    n := nPos % nBlockSize
    if n > 0
      nPos += nBlockSize - n // Jump to the start of the next block
    endif

    if nPos >= nNext
      x := round((nPos / nMemoEOF) * 100, 0)
      if (x % 10 == 0) .and. (x <> nLastPercent)
        ? "Memo " + Nstr(x) + "% preloaded"
        nLastPercent := x
      endif
      lEnd := inkey() == K_ESC
      do while nNext < nPos
        nNext += nEvery
      enddo
    endif

  enddo

  MemoData->( DBCommit() )

Return(!lEnd)



STATIC Function MemoRead(hMemo, cPointer, cMsg, lDamage)
  local cBuffer, cData := ""
  local nMemoLen, n, x
  local nEOM, cEOM

  // We already know at this point if we don't have a memo to read or that
  // the pointer is empty or invalid, so don't check for any of that again.

  // All memo files have a header of 512 bytes (bytes 0-511).
  // The first actual memo data starts at byte 512.

  n := (val(cPointer) * nBlockSize)

  if n < MEMO_HDR_SIZE
    LogText(cMsg + "memo pointer * blocksize < header size: " + ;
            alltrim(cPointer))
    lDamage := .T.
    Return(cData)
  endif

  // Read the data:

  fseek(hMemo, n, FS_SET)

  if nMemoType == TYPE_III

    cBuffer := space(nBlockSize)
    cEOM := chr(26) // Memo terminator character
    nEOM := 0
    n := nBlockSize
    nMemoLen := 0

    do while nEOM == 0 .and. n == nBlockSize
      n := fread(hMemo, @cBuffer, nBlockSize)
      nEOM := at(cEOM, left(cBuffer, n))
      if nEOM > 0
        x := nEOM - 1
      else
        x := n
      endif
      if nMemoLen + x > nMaxMemoSize
        LogText(cMsg + "memo size > max.  Truncating.")
        lDamage := .T.
        x := nMaxMemoSize - nMemoLen
        nEOM := 1 // No need for another loop
      elseif n < nBlockSize .and. nEOM == 0
        LogText("memo truncated by eof.  " + ;
                Nstr(nMemoLen + x) + " bytes saved.")
        lDamage := .T.
      endif
      cData += left(cBuffer, x)
      nMemoLen += x
    enddo

  else

    nMemoLen := 8 // The first 8 bytes contain memo type & size info
    cBuffer := space(nMemoLen)
    n := fread(hMemo, @cBuffer, nMemoLen)

    if n == nMemoLen
      if nMemoType == TYPE_FPT
        // Bytes 0-3 are the FPT "record type".  Usage?  Who knows...
        // Bytes 4-7 are the memo length (big-endian).
        // Since I can't use more than 64K, just take the last two bytes.
        // This allows bytes 4-5 to be corrupted without consequence.
        nMemoLen := CtoN(substr(cBuffer, 7, 2), .T.)
      else // TYPE_IV
        // Bytes 4-7 are the memo length (little-endian) including this
        // 8-byte "header".
        // Since I can't use more than 64K, just take the first two bytes.
        // This allows bytes 6-7 to be corrupted without consequence.
        nMemoLen := CtoN(substr(cBuffer, 5, 2)) - 8
      endif
      if nMemoLen > 0
        if nMemoLen > nMaxMemoSize
          LogText(cMsg + "reports a memo size > max.  Truncating.")
          lDamage := .T.
          nMemoLen := nMaxMemoSize
        endif
        // Read the entire memo in one gulp:
        cBuffer := space(nMemoLen)
        n := fread(hMemo, @cBuffer, nMemoLen)
        cData := left(cBuffer, n)
        if n < nMemoLen
          LogText(cMsg + "memo truncated by eof.  " + Nstr(n) + ;
                  " of " + Nstr(nMemoLen) + " bytes saved.")
          lDamage := .T.
        endif
      endif
    else
      LogText(cMsg + "memo truncated by eof.  Entire memo lost.")
      lDamage := .T.
    endif

  endif // nMemoType

Return(cData)



STATIC Function MemoSeek(cPointer, cMsg, lDamage)
  local cData := ""

  if MemoData->( DBSeek(cPointer) )
    if MemoData->ERROR <> ERR_BLANK
      cData := MemoData->MEMOTEXT
      if !empty(MemoData->ERROR)
        lDamage := .T.
        do case
          case MemoData->ERROR == ERR_SIZE
            LogText(cMsg + "reports a memo size > max.  Truncated.")
          case MemoData->ERROR == ERR_EOF
            LogText(cMsg + "memo partially truncated by eof.")
        endcase
      endif
    endif
  else
    lDamage := .T.
    LogText(cMsg + "incorrect memo pointer (" + cPointer + ")")
  endif

Return(cData)


STATIC Function GetYesNo(cMsg, lEsc)
  local i

  ? cMsg + " (Y/N/Esc) "
    
  do while .T.
    i := inkey(0)
    if i == K_ESC
      Return(lEsc)
    elseif i == asc("Y") .or. i == asc("y")
      ?? "Y"
      Return(.T.)
    elseif i == asc("N") .or. i == asc("n")
      ?? "N"
      Return(.F.)
    endif
  enddo
  
Return(NIL)
