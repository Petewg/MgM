/*

  FILEPART.PRG    Functions dealing with filenames or parts thereof...

*/
#include "default.ch"
#include "filepart.ch"


Function AddSlash(cPath)
/*
  Adds a trailing backslash to a path name if not already present.  An empty
  string will not be affected.  You may pass cPath by reference if desired.
*/

  if !empty(cPath)
    if right(cPath, 1) <> "\"
      cPath += "\"
    endif
  endif

Return(cPath)


#ifndef DOS_ONLY

Function CurPath(lSlash)
/*
  Returns the current drive and path in the format "D:\PATH".  If lSlash is
  true, a trailing backslash will be appended.  lSlash defaults to false.
*/
  local cPath := CurDrive() + ":\" + curdir()

  // CurDrive() is a FiveWin function.

  default lSlash := .F.

Return(iif(lSlash, AddSlash(cPath), StripSlash(cPath)))



Function ExeName()
/*
  Returns the current executable's name.
  Translates directly to GetModuleFileName(GetInstance()).
*/
Return(GetModuleFileName(GetInstance()))



Function ExePath(lSlash)
/*
  Returns the location of the currently running Windows EXE in the format
  "D:\PATH".  If the optional parameter lSlash is true, a trailing backslash
  will be appended.  lSlash defaults to false.
*/
  local cExe := ExeName()

  default lSlash := .F.

Return( left(cExe, rat("\", cExe) - iif(lSlash, 0, 1)) )

#endif



Function FileParts(cFileSpec, nPart)
/*
    This function returns requested part(s) from an extended filename.

    The part of cFileSpec you get is determined by the value of nPart:

      FP_FILENAME  = Filename, including extension
      FP_NAMEONLY  = Filename, without the extension
      FP_EXTENSION = Extension (no period)
      FP_PATH      = Pathname including a trailing backslash
      FP_DIR       = Pathname without a trailing backslash
      FP_DRIVE     = Drive letter including a trailing colon
      FP_STRIPEXT  = Returns everything to the left of the extension.

      These constants are defined in FILEPART.CH.

    Examples:

      ? FileParts("C:\TEMP\JUNK.TMP", FP_FILENAME)  --> "JUNK.TMP"
      ? FileParts("C:\TEMP\JUNK.TMP", FP_NAMEONLY)  --> "JUNK"
      ? FileParts("C:\TEMP\JUNK.TMP", FP_EXTENSION) --> "TMP"
      ? FileParts("C:\TEMP\JUNK.TMP", FP_PATH)      --> "C:\TEMP\"
      ? FileParts("C:\TEMP\JUNK.TMP", FP_DIR)       --> "C:\TEMP"
      ? FileParts("C:\TEMP\JUNK.TMP", FP_DRIVE)     --> "C:"
      ? FileParts("C:\TEMP\JUNK.TMP", FP_STRIPEXT)  --> "C:\TEMP\JUNK"

    If nPart is empty or omitted, it will default to FP_FILENAME.

    If the requested part is not found within cFileSpec, a null string ("")
     is returned, except for FP_STRIPEXT, where the whole string will be
     returned if no extension is found.

      ? FileParts("JUNK.TMP", FP_PATH)    --> ""
      ? FileParts("JUNK.TMP", FP_DRIVE)   --> ""
      ? FileParts("C:\JUNK"), FP_STRIPEXT --> "C:\JUNK"

    If a path is requested, but only a drive letter exists, a trailing
     backslash will be added to the returned text:

      ? FileParts("B:REPORT.TXT", FP_PATH) --> "B:\"

    FP_DIR is the same as FP_PATH except that it strips a trailing backslash
     if present.

    Note: FileParts() assumes that the last thing in cFileSpec is a filename
     unless it ends with a trailing backslash.  In the following example,
     FileParts() thinks "DOCS" is a filename without an extension:

      ? FileParts("C:\WP51\DOCS", FP_PATH)     --> "C:\WP51\"
      ? FileParts("C:\WP51\DOCS", FP_FILENAME) --> "DOCS"

    By adding a trailing backslash to the above example, the confusion would
     be avoided.

    Also, directories with extensions (periods) really confuse the function.
    Don't allow them!
*/
  local cText := "", nL, nR
  local nColon := at(":", cFileSpec)
  local nDot   := rat(".", cFileSpec)
  local nSlash := rat("\", cFileSpec)

  default nPart := FP_FILENAME

  do case
    case nPart == FP_FILENAME
      if nSlash > 0                               // Is there a path?
        cText := substr(cFileSpec, nSlash + 1)
      elseif nColon > 0                           // How about a colon?
        cText := substr(cFileSpec, nColon + 1)
      else                                        // Must be filename only
        cText := cFileSpec
      endif

    case nPart == FP_NAMEONLY
      if nSlash > 0                               // Find the left boundary
        nL := nSlash + 1                          //  (Just like filename)
      elseif nColon > 0
        nL := nColon + 1
      else
        nL := 1
      endif
      if nDot > 0                                 // Find the right boundary
        nR := nDot - 1                            // at the dot
      else
        nR := len(cFileSpec)                      // No dot?
      endif
      cText := substr(cFileSpec, nL, (nR - nL) + 1) // Get the stuff between

    case nPart == FP_EXTENSION
      if nDot > 0                                 // Take everything past the
        cText := substr(cFileSpec, nDot + 1)      // dot.
      endif

    case nPart == FP_PATH .or. nPart == FP_DIR
      if nSlash > 0
        cText := left(cFileSpec, nSlash - iif(nPart == FP_DIR, 1, 0))
      elseif nColon > 0
        cText := left(cFileSpec, nColon) + iif(nPart == FP_PATH, "\", "")
      endif

    case nPart == FP_DRIVE
      if nColon > 0
        cText := left(cFileSpec, nColon)
      endif

    case nPart == FP_STRIPEXT
      if nDot > 0
        cText := left(cFileSpec, nDot - 1)
      else
        cText := cFileSpec
      endif

  endcase

Return(cText)



Function GetTempDir(lSlash)
/*
  Returns the name of the temp directory.  lSlash determines if the string
  will end with a trailing backslash or not (default is false).

  The function first looks for the environment variable "TEMP", then "TMP".
  If neither of these is found or the specified directories do not exist,
  C:\TEMP then C:\WINDOWS\TEMP will be used if found.  If all these fail,
  the function will return a null string.
*/
  local x, cDir := ""
  #ifdef DOS_ONLY
  local aTemp_ := { getenv("TEMP"), ;
                    getenv("TMP") , ;
                    "C:\TEMP"      }
  #else
  local aTemp_ := { getenv("TEMP"), ;
                    getenv("TMP") , ;
                    "C:\TEMP"     , ;
                    AddSlash(GetWinDir()) + "TEMP" }
  #endif

  default lSlash := .F.

  for x := 1 to len(aTemp_)
    if !empty(aTemp_[x])
      if GoodFile(Temp_Name(".TMP", aTemp_[x]))
        cDir := iif(lSlash, AddSlash(aTemp_[x]), StripSlash(aTemp_[x]))
        exit
      endif
    endif
  next

Return(cDir)



Function IndexOf(cFile)
/*
  Returns the name of a file's structural index by stripping the extension
  off the given filename & adding the index extension.  Merely a convenience
  item and to make code more readable.

  Translates directly to: NewExt(cFile, ordBagExt())
*/
Return(NewExt(cFile, ordBagExt()))



Function MemoOf(cFile)
/*
  Returns the name of a database's memo file.  The function does not check
  if the database has a memo or not, just what it would be called.  It uses
  the Comix function cmxMemoExt() to get the extension.  Obviously, this
  function only works with the Comix RDD.
*/
Return(NewExt(cFile, sx_MemoExt()))



Function NewExt(cFile, cExt)
/*
  Strips the current extension off a file and replaces it with cExt.  The
   function will add the period if not provided.

  Translates directly to FileParts(cFile, FP_STRIPEXT) + cExt
*/

  if left(cExt, 1) <> "." // Add period if needed
    cExt := "." + cExt
  endif

Return(FileParts(cFile, FP_STRIPEXT) + cExt)



Function RevExt(cFile)
/*
  Returns <cFile> with its extension reversed.  Useful for making backup
  copies of files, etc.

  RevExt("FILE.DBF") -> "FILE.FBD"
*/
  local cRev := FileParts(cFile, FP_STRIPEXT) + "."
  local cExt := FileParts(cFile, FP_EXTENSION)
  local x

  for x := len(cExt) to 1 step -1
    cRev += substr(cExt, x, 1)
  next

Return(cRev)



Function StripExt(cFile)
/*
  Just a quick way to write FileParts(cFile, FP_STRIPEXT)
*/
Return(FileParts(cFile, FP_STRIPEXT))



Function StripSlash(cPath)
/*
  Removes a trailing backslash (if any) from cPath.  You may pass cPath by
  reference if desired.
*/

  if right(cPath, 1) == "\"
    cPath := left(cPath, len(cPath) - 1)
  endif

Return(cPath)



Function Temp_Name(cExt, cPath)
/*
  Returns a temporary, unique filename based on the current value of the
    system timer.

  cExt is an optional extension to use for the file, defaulting to ".TMP".

  cPath is an optional path to locate the temporary file in.  It defaults to
    the current path (blank).

  The extension and path (if any) will be part of the returned filename.

  Examples:

    Temp_Name()                   -->  "_0123456.TMP"
    Temp_Name(".CDX")             -->  "_0123456.CDX"
    Temp_Name(".DBF", "C:\TEMP")  -->  "C:\TEMP\_0123456.DBF"
*/
  local cTemp
  static cLast := ""

  default cExt  := ".TMP", ;
          cPath := ""

  if left(cExt, 1) <> "."   // Add dot if needed
    cExt := "." + cExt
  endif

  cPath := AddSlash(cPath)  // Add trailing backslash if needed

  do while .T.

    cTemp := cPath + "_" + ;
             padl(ltrim(str(seconds() * 100, 7, 0)), 7, "0") + cExt

    if cTemp == cLast .or. file(cTemp)                 // Already exist or
      loop                                             // same as last time?
    endif

    cLast := cTemp                                     // Record it & exit
    exit

  enddo

Return(cTemp)

