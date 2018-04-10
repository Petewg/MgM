#include "cldbfix.ch"

REQUEST DBFCDX
REQUEST SIXCDX
REQUEST HB_GT_WIN_DEFAULT

function Main(cDbf, o1, o2, o3, o4, o5)
  local aArgs_ := {}
  local cTemp, cOpt, cValue
  local c, i, j  
  local cLog, cDonor, cRDD, cJunkChar
  local lUpper, lPreload, lDeleted, lPartial, lTotal, lCharJunk, lMemoJunk

  if empty(cDbf)
    Usage()
    Return(NIL)  
  endif
  
  if !file(cDbf)
    Usage("Repair file not found: " + cDbf)
    Return(NIL)
  endif
    
  // Default options:
  cLog      := ""
  cDonor    := ""
  cRDD      := "SIXCDX"
  cJunkChar := "?"
  lPreload  := .F.
  lDeleted  := .F.
  lPartial  := .T.
  lTotal    := .T.
  lCharJunk := .T.
  lMemoJunk := .T.
  
  // Gather the command line parameters into an array:
  if !empty(o1)
    aadd(aArgs_, o1)
  endif
  if !empty(o2)
    aadd(aArgs_, o2)
  endif
  if !empty(o3)
    aadd(aArgs_, o3)
  endif
  if !empty(o4)
    aadd(aArgs_, o4)
  endif
  if !empty(o5)
    aadd(aArgs_, o5)
  endif
  
  // Parse the various options from the command line:
  for i := 1 to len(aArgs_)
    cTemp := aArgs_[i]
    j := at(":", cTemp)
    if j <> 2
      Usage("Unrecognized argument: " + cTemp)
      Return(NIL)
    endif
    cOpt := left(cTemp, 1)
    cValue := substr(cTemp, 3)
    do case
      case cOpt == "L" // Log file
        cLog := cValue
      case cOpt == "D" // Donor file
        cDonor := cValue         
      case cOpt == "R" // RDD
        cRDD := cValue         
      case cOpt == "J" // Junk replacement character
        cJunkChar := cValue
      case cOpt == "O" // Options
        for j := 1 to len(cValue)
          c := substr(cValue, j, 1)
          lUpper := c == upper(c)
          c := upper(c)
          do case
            case c == "L"
              lPreload := lUpper
            case c == "D"
              lDeleted := lUpper
            case c == "P"
              lPartial := lUpper
            case c == "T"
              lTotal := lUpper
            case c == "C"
              lCharJunk := lUpper
            case c == "M"
              lMemoJunk := lUpper
            otherwise
              Usage("Unrecognized option: " + c)
              Return(NIL)
          endcase
        next            
      otherwise
        Usage("Unrecognized argument: " + cTemp)
        Return(NIL)
    endcase
  next // aArgs_
  
  // Make sure the options we got are valid:
  if !file(cDbf)    
    Usage("Repair file not found: " + cDbf)
    Return(NIL)
  endif

  if !empty(cDonor) .and. !file(cDonor) 
    Usage("Donor file not found: " + cDonor)
    Return(NIL)
  endif
    
  if at("/" + cRDD + "/", "/DBFIV/DBFMDX/DBF/DBFNDX/DBFNTX/SIXCDX/DBFCDX/") = 0 
    Usage("Unrecognised RDD: " + cRDD)
    Return(NIL)
  endif

  if lTotal
    lPartial := lTotal
  endif
    
  // OK! Let 'er rip!
  
  DBRepair(cDbf, cLog, cDonor, cRDD, cJunkChar, ;
           lPreload, lDeleted, lPartial, lTotal, lCharJunk, lMemoJunk)

Return(NIL)


STATIC Function Usage(cError)

  if !empty(cError)
    ? cError
    ?
  endif
  
  //"12345678901234567890123456789012345678901234567890123456789012345678901234567890"
  ? "CLDBFIX v" + DBFIX_VERSION + " Syntax:"
  ?
  ? "CLDBFIX damaged.dbf [L:log.txt] [D:donor.dbf] [R:RDD] [J:?] [O:LDPTCM]"
  ?
  ? "If a log file is not specified, log output goes to the screen."
  ? 
  ? "The default RDD is SIXCDX.  Change this with the R: option if needed."
  ?
  ? "The J: option specifies the junk replacement character, either as a single"
  ? "character or a three-digit ASCII code.  (Default=?)"
  ? 
  ? "The O: options toggle based on case:  upper=ON  lower=OFF"
  ? " L = preLoad memos (default=OFF)"
  ? " D = save Deleted records (default=OFF)"
  ? " P = save Partially damaged records (default=ON)"
  ? " T = save Totally damaged records (default=ON)"
  ? " C = allow junk in Character fields (default=ON)"
  ? " M = allow junk in Memo fields (default=ON)"
  ?
  //"12345678901234567890123456789012345678901234567890123456789012345678901234567890"
  
Return(NIL)
