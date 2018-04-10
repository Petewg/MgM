/*

  MpmBuild.prg

  Runs _Build.bat.  Used by Mpm to run the build as a terminatable process.

  Last modifed 2007.11.14 by 
  Kevin Carmody <i@kevincarmody.com>

*/

//***************************************************************************

ANNOUNCE RDDSYS

#include "minigui.ch"

#DEFINE MPMB_NOLOCFILE    -101
#DEFINE MPMB_NOLOCREAD    -102
#DEFINE MPMB_NOBUILDFILE  -103

//***************************************************************************

PROCEDURE Main
  
  LOCAL nExit    := 0
  LOCAL cLocFile := AddSlash(GetTempFolder()) + '_MpmBuild.txt'
  LOCAL cBuildFile

  BEGIN SEQUENCE
    IF !FILE(cLocFile)
      nExit := MPMB_NOLOCFILE
      BREAK
    ENDIF
    cBuildFile := MEMOREAD(cLocFile)
    IF EMPTY(cBuildFile)
      nExit := MPMB_NOLOCREAD
      BREAK
    ENDIF
    IF !FILE(cBuildFile)
      nExit := MPMB_NOBUILDFILE
      BREAK
    ENDIF
    DELETE FILE (cLocFile)
    nExit := WaitRun(cBuildFile, 0)
  END SEQUENCE

  ERRORLEVEL(nExit)

RETURN

//***************************************************************************

FUNCTION AddSlash(cInFolder)

  LOCAL cOutFolder := ALLTRIM(cInFolder)

  IF !EMPTY(cOutFolder) .AND. RIGHT(cOutfolder, 1) != '\'
    cOutFolder += '\'
  ENDIF

RETURN cOutFolder

//***************************************************************************

FUNCTION AddQuote(cInPath)

  LOCAL cOutPath := ALLTRIM(cInPath)
  LOCAL cQuote   := '"'
  LOCAL cSpace   := SPACE(1)

  IF cSpace $ cOutPath .AND. ;
    !(LEFT(cOutPath, 1) == cQuote) .AND. !(RIGHT(cOutPath, 1) == cQuote)
    cOutPath := cQuote + cOutPath + cQuote
  ENDIF

RETURN cOutPath

//***************************************************************************