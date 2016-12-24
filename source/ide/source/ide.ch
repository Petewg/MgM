/*
   HMGS - MiniGUI - IDE - Harbour Win32 GUI Designer

   Copyright 2005-2015 Walter Formigoni <walter.formigoni@gmail.com>
   http://sourceforge.net/projects/hmgs-minigui/
*/

#define _FILE                      1

#define _MG_FOLDER                 2
#define _BCC_FOLDER                3
#define _HARBOURFOLDER             4
#define _XHARBOURFOLDER            5
#define _EDITORFOLDER              6
#define _OUTPUTFOLDER              7

#define _HMG2FOLDER                8
#define _HMG2MING32FOLDER          9
#define _HMG2MING32HARBOURFOLDER  10
#define _HMG2XHARBOURFOLDER       11
#define _HMG2EDITORFOLDER         12
#define _HMG2OUTPUTFOLDER         13

#define _HMGFOLDER                14
#define _HMGMING32FOLDER          15
#define _HMGMING32HARBOURFOLDER   16
#define _HMGXHARBOURFOLDER        17
#define _HMGEDITORFOLDER          18
#define _HMGOUTPUTFOLDER          19

#define _ADS                      20
#define _MYSQL                    21
#define _ODBC                     22
#define _ZIP                      23
#define _CONSOLE                  24
#define _GUI                      25

#define _MINIGUIEXT               26
#define _HMG2                     27
#define _BCC55                    28
#define _MINGW32                  29
#define _HARBOUR                  30
#define _XHARBOUR                 31

#define _SAVEOPTIONS              32
#define _DISABLEWARNINGS          33
#define _UPX                      34
#define _LAYOUT                   35
#define _BUILDTYPE                36

#define _ADDLIBMINBCCHB           37
#define _ADDLIBMINNCCXHB          38
#define _ADDLIBMINMINGHB          39
#define _ADDLIBMINMINGXHB         40
#define _ADDLIBHMG2HB             41

#define _ADDLIBINCBCCHB           42
#define _ADDLIBINCBCCXHB          43
#define _ADDLIBINCMINGHB          44
#define _ADDLIBINCMINGXHB         45
#define _ADDLIBINCHMG2HB          46

#define _MULTITHREAD              47

#define _PROJECTPATH              48
#define _FORMPATH                 49
#define _MODULEPATH               50
#define _REPORTPATH               51
#define _MENUPATH                 52
#define _DBFPATH                  53
#define _RESOURCEPATH             54

#define _PROJECTFONTNAME          55
#define _PROJECTFONTSIZE          56

#xtranslate NO_FORM_MSG() => MsgExclamation( "There isn't any active form!", "Invalid operation!" )

// Public variable Memvar declaration to kill all warning W0001  Ambiguous reference "???"
MEMVAR xParam
MEMVAR xArray
MEMVAR aData
MEMVAR aMenu
MEMVAR aToolbar
MEMVAR aContext
MEMVAR aStatus
MEMVAR aNotify
MEMVAR aDropdown
MEMVAR aReport
MEMVAR xProp
MEMVAR nrControl
MEMVAR nrControle
MEMVAR aPrgNames
MEMVAR aFmgNames
MEMVAR aRcNames
MEMVAR aRptNames
MEMVAR DesignForm
MEMVAR CurrentProject
MEMVAR CurrentControl
MEMVAR CurrentControlName
MEMVAR CurrentForm
MEMVAR ProjectFolder
MEMVAR MainHeight
MEMVAR xEvent
MEMVAR cFile
MEMVAR lChanges
MEMVAR lSnap
MEMVAR InDelete
MEMVAR lUpdate
MEMVAR ProcessFrameOk
MEMVAR cTextNotes
MEMVAR aError
MEMVAR aLinesPrg
MEMVAR aTbrowse
MEMVAR aOTbrowse
MEMVAR nTotControl
MEMVAR nPosControl

// Was missing from memvar list in main prog.
MEMVAR aLibs
MEMVAR aFormDir
MEMVAR PgMpPos
MEMVAR aMainModule
MEMVAR aModules
MEMVAR aTempDeletedControls
MEMVAR BuildType
MEMVAR cIniFile
MEMVAR lBuildUpdate
MEMVAR lDisabled
MEMVAR mFound
MEMVAR MainType
MEMVAR MainEditor
MEMVAR aXControls
MEMVAR aUciNames
MEMVAR aUciControls
MEMVAR aUciProps
MEMVAR aUciEvents
MEMVAR lenUci
MEMVAR aItens
MEMVAR VLHASH
MEMVAR A1
MEMVAR A2
MEMVAR A3
MEMVAR A4
MEMVAR Ans
MEMVAR xItens
MEMVAR aInclude


// For Status.prg
MEMVAR ArrayStatus
MEMVAR lAction
MEMVAR aStatusValues

// For Dropdown.prg
MEMVAR aVLDropDown

// For Context.prg
MEMVAR ArrayContext

// For Readflds.prg
MEMVAR _lChngd

// For Populate.prg
MEMVAR _DbStructArr
MEMVAR _DbAnames
MEMVAR chblk

// For LoadFmg.prg
MEMVAR new_name

// For MainMenu.prg
// MEMVAR lAction already declare for status.prg
MEMVAR ArrayMenu

// For Toolbar.prg
MEMVAR aVLToolbarHash
MEMVAR aVLButtonHash
MEMVAR lastitem
MEMVAR DisableChange

// For mpmc.prg
MEMVAR cOutputFolder
