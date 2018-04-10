/*

  DIRSTUFF.PRG    Directory-type functions

*/
#include "default.ch"
#include "directry.ch"
#include "filepart.ch"


Function FileDate(cFile)
/*
  Returns a file's directory() date.
  An empty date will be returned if the file does not exist.
*/
  local dFile := ctod("")
  local aDir_ := directory(cFile)

  if len(aDir_) >= 1
    dFile := aDir_[1, F_DATE]
  endif

Return(dFile)



Function FSize(xFileSpec)
/*
    Returns the size of an individual file, or the combined size of a number
    of files, depending on whether the argument passed is a single filename
    or an array of filenames.  Wildcards are accepted.

    Examples:  FSize("CUSTOMER.DBF")
               FSize({"*.DBF","*.CDX"})

    If the file(s) do not exist, FSize() will return zero.
*/
  local aFiles_ := {}, nFiles, x
  local nSize := 0

  // Create an array of filenames, even if only one file:

  if valtype(xFileSpec) == "A"
    aFiles_ := aclone(xFileSpec)
  else
    aadd(aFiles_, xFileSpec)
  endif

  // Do a directory() for each of the requested filespecs and tally the sizes

  nFiles := len(aFiles_)

  for x := 1 to nFiles
    aeval(directory(aFiles_[x]), {|a| nSize += a[F_SIZE] })
  next

Return(nSize)



Function FStamp(cFile)
/*
  Returns a character date/time stamp of a file that can be directly compared
  to another file's date/time stamp.

  This stamp is in the form of YYYYMMDDHHMMSS or a null string if the file
  does not exist.
*/
  local cStamp := ""
  local aDir_ := directory(cFile)

  if !empty(aDir_)
    cStamp := dtos(aDir_[1, F_DATE]) + ;
              substr(aDir_[1, F_TIME], 1, 2) + ;
              substr(aDir_[1, F_TIME], 4, 2) + ;
              substr(aDir_[1, F_TIME], 7, 2)
 endif

Return(cStamp)



Function MultiDel(xDelMask)
/*
  Used to delete all files matching a certain filespec mask, like "*.TMP",
    or "C:\TEMP\*.*".

  The xDelMask argument can be either a character string of the mask, or
    an array of several masks.

  Examples:  MultiDel("A:\TEMPFILE.TMP")
             MultiDel({"*.TMP","*.NTX"})

  Note: Passing a null string ("") as a filespec mask is equivalent to
    passing "*.*", therefore, any empty masks will be ignored.  To delete
    all files in a directory, "*.*" must be explicitly passed.
*/
  local aMasks_ := {}, x
  local cTemp

  // Make an array of masks whether the argument is an array or not.

  cTemp := valtype(xDelMask)

  if cTemp == "A"
    aMasks_ := aclone(xDelMask)
  elseif cTemp == "C"
    aadd(aMasks_, xDelMask)
  endif

  // Delete all files found for each mask, making sure we include it's
  // pathname in case we're not deleting files from the current directory.

  // Note: DO NOT PROCESS EMPTY MASKS - passing a null string to the
  //       directory() function is equivalent to passing "*.*" !

  for x := 1 to len(aMasks_)
    if !empty(aMasks_[x])
      cTemp := FileParts(aMasks_[x], FP_PATH)
      aeval(directory(aMasks_[x]), {|a| ferase(cTemp + a[F_NAME]) })
    endif
  next

Return(NIL)



