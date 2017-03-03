#include "minigui.ch"

FUNCTION main()
LOCAL cIniFile := GetStartupFolder() + '\demo.ini'
LOCAL aRet

SetIniValue(cIniFile)

aRet := GetIniValue(cIniFile)

AEVAL( aRet, { |x| MsgInfo( x, 'Type is ' + ValType(x) ) } )

RETURN NIL


PROCEDURE SetIniValue( cIni )

BEGIN INI FILE cIni
  SET SECTION 'Project' ENTRY 'Name' TO 'My Project'
END INI

RETURN


FUNCTION GetIniValue( cIni )
LOCAL cName, nVers

BEGIN INI FILE (cIni)
  GET cName SECTION 'Project' ENTRY 'Name' DEFAULT ''
  GET nVers SECTION 'Project' ENTRY 'Vers' DEFAULT 1.01
END INI

RETURN { cName, nVers }
