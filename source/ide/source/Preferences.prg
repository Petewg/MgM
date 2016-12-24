#include "minigui.ch"
#include "ide.ch"

*------------------------------------------------------------*
PROCEDURE Preferences()
*------------------------------------------------------------*
   LOAD WINDOW preferences
   CENTER WINDOW preferences
   ACTIVATE WINDOW preferences
RETURN


*------------------------------------------------------------*
PROCEDURE LoadPreferences()
*------------------------------------------------------------*
   LOCAL ac2       AS ARRAY
   LOCAL x         AS USUAL
   LOCAL cSect     AS STRING := 'wPreferences'
   LOCAL cSect1    AS STRING := 'wcPaths'
   LOCAL d         AS STRING := Lower( SubStr( Application.ExeName, 1, 1 ) )
   LOCAL bccpath   AS STRING := BCC_DETECT()
   LOCAL acPaths   AS ARRAY  := { ProjectFolder, ProjectFolder, ProjectFolder, ProjectFolder, ProjectFolder, ProjectFolder, ProjectFolder }
   LOCAL acwValues AS ARRAY  := { "", d + ":\minigui", bccpath, d + ":\minigui\harbour", d + ":\xharbour", "", "" } // 1-7

   ac2 := { "", "", "", "", "", "", "", "", "", "", "", "" }          // 8-19
   AEval( ac2, { | x | AAdd( acwValues, x )  } )

   ac2 := { ".F.", ".F.", ".F.", ".F.", ".F.", ".T.", ".T.", ".F." }  //20-27
   AEval( ac2, { | x | AAdd( acwValues, x )  } )

   ac2 := { ".T.", ".F.", ".T.", ".F.", "1", ".F.", ".F.", "1", "1" } //28-36
   AEval( ac2, { | x | AAdd( acwValues, x )  } )

   ac2 := { "", "", "", "", "", "", "", "", "", "" } // 37-46
   AEval( ac2, { | x | AAdd( acwValues, x )  } )

   AAdd( acwValues, ".F." )                                 // 47

   AEval( acPaths, { | x | AAdd( acwValues, x )  } ) // 48-54

   AAdd( acwValues, "Arial" )                               // 55
   AAdd( acwValues, 10 )                                    // 56

   IF ! File( cIniFile )
      BEGIN INI File cIniFile
        SET SECTION cSect ENTRY "wFile"                     TO 'HmgsIde_Cfg'
        SET SECTION cSect ENTRY "wMiniGuiFolder"            TO d + ':\minigui'
        SET SECTION cSect ENTRY "wBccFolder"                TO bccpath
        SET SECTION cSect ENTRY "wHarbourFolder"            TO d + ':\minigui\harbour'
        SET SECTION cSect ENTRY "wXHarbourFolder"           TO d + ':\xharbour'
        SET SECTION cSect ENTRY "wEditorFolder"             TO 'notepad.exe'
        SET SECTION cSect ENTRY "wOutputFolder"             TO ""

        SET SECTION cSect ENTRY "wHmg2Folder"               TO 'c:\hmg'
        SET SECTION cSect ENTRY "wHmg2Mingw32Folder"        TO 'c:\hmg\mingw32'
        SET SECTION cSect ENTRY "wHmg2Mingw32HarbourFolder" TO 'c:\hmg\harbour'
        SET SECTION cSect ENTRY "wHmg2XHarbourFolder"       TO 'c:\hmg\xharbour'
        SET SECTION cSect ENTRY "wHmg2EditorFolder"         TO 'notepad.exe'
        SET SECTION cSect ENTRY "wHmg2OutputFolder"         TO ""

        SET SECTION cSect ENTRY "wHmgFolder"                TO d + ':\MiniguiM\minigui'
        SET SECTION cSect ENTRY "wHmgMingw32Folder"         TO d + ':\MiniguiM\comp\mingw32'
        SET SECTION cSect ENTRY "wHmgMingw32HarbourFolder"  TO d + ':\MiniguiM\comp\harbour'
        SET SECTION cSect ENTRY "wHmgXHarbourFolder"        TO d + ':\xharbour'
        SET SECTION cSect ENTRY "wHmgEditorFolder"          TO d + ':\Program Files\Notepad++\notepad++.exe'
        SET SECTION cSect ENTRY "wHmgOutputFolder"          TO ""

        SET SECTION cSect ENTRY "wADS"                      TO ".F."
        SET SECTION cSect ENTRY "wMySql"                    TO ".F."
        SET SECTION cSect ENTRY "wODBC"                     TO ".F."
        SET SECTION cSect ENTRY "wZip"                      TO ".F."

        SET SECTION cSect ENTRY "wConsole"                  TO ".F."
        SET SECTION cSect ENTRY "wGui"                      TO ".T."
        SET SECTION cSect ENTRY "wMiniguiExt"               TO ".T."
        SET SECTION cSect ENTRY "wHmg2"                     TO ".F."
        SET SECTION cSect ENTRY "wMultiThread"              TO ".F."

        SET SECTION cSect ENTRY "wBCC55"                    TO ".T."
        SET SECTION cSect ENTRY "wMingw32"                  TO ".F."
        SET SECTION cSect ENTRY "wHarbour"                  TO ".T."
        SET SECTION cSect ENTRY "wXharbour"         TO ".F."

        SET SECTION cSect ENTRY "wSaveOptions"              TO '1'
        SET SECTION cSect ENTRY "wDisableWarnings"          TO ".F."
        SET SECTION cSect ENTRY "wUPX"                      TO ".F."
        SET SECTION cSect ENTRY "wLayout"                   TO '1'
        SET SECTION cSect ENTRY "wBuildType"                TO '1'

        SET SECTION cSect ENTRY "wAddLibMinBccHb"           TO ""
        SET SECTION cSect ENTRY "wAddLibMinBccXhb"          TO ""
        SET SECTION cSect ENTRY "wAddLibMinMingHb"          TO ""
        SET SECTION cSect ENTRY "wAddLibMinMingXhb"         TO ""
        SET SECTION cSect ENTRY "wAddLibHmg2Hb"             TO ""

        SET SECTION cSect ENTRY "wAddIncMinBccHb"           TO ""
        SET SECTION cSect ENTRY "wAddIncMinBccXhb"          TO ""
        SET SECTION cSect ENTRY "wAddIncMinMingHb"          TO ""
        SET SECTION cSect ENTRY "wAddIncMinMingXnb"         TO ""
        SET SECTION cSect ENTRY "wAddIncHmg2Hb"             TO ""

        SET SECTION cSect1 ENTRY "wProjectPath"             TO acwValues[ _PROJECTPATH ]
        SET SECTION cSect1 ENTRY "wFormPath"                TO acwValues[ _FORMPATH ]
        SET SECTION cSect1 ENTRY "wModulePath"              TO acwValues[ _MODULEPATH ]
        SET SECTION cSect1 ENTRY "wReportPath"              TO acwValues[ _REPORTPATH ]
        SET SECTION cSect1 ENTRY "wMenuPath"                TO acwValues[ _MENUPATH ]
        SET SECTION cSect1 ENTRY "wDbfPath"                 TO acwValues[ _DBFPATH ]
        SET SECTION cSect1 ENTRY "wResourcePath"            TO acwValues[ _RESOURCEPATH ]

        SET SECTION cSect ENTRY "wFontName"                 TO acwValues[ _PROJECTFONTNAME ]
        SET SECTION cSect ENTRY "wFontSize"                 TO acwValues[ _PROJECTFONTSIZE ]
      END INI
   ENDIF

   BEGIN INI File cIniFile
     GET acwvalues[ _FILE ]                     SECTION cSect ENTRY "wFile"                     DEFAULT acwValues[ _FILE ]
     GET acwvalues[ _MG_FOLDER ]                SECTION cSect ENTRY "wMiniGuiFolder"            DEFAULT acwValues[ _MG_FOLDER ]
     GET acwvalues[ _BCC_FOLDER ]               SECTION cSect ENTRY "wBccFolder"                DEFAULT acwValues[ _BCC_FOLDER ]
     GET acwvalues[ _HARBOURFOLDER ]            SECTION cSect ENTRY "wHarbourFolder"            DEFAULT acwValues[ _HARBOURFOLDER ]
     GET acwvalues[ _XHARBOURFOLDER ]           SECTION cSect ENTRY "wXHarbourFolder"           DEFAULT acwValues[ _XHARBOURFOLDER]
     GET acwvalues[ _EDITORFOLDER ]             SECTION cSect ENTRY "wEditorFolder"             DEFAULT acwValues[ _EDITORFOLDER ]
     GET acwvalues[ _OUTPUTFOLDER ]             SECTION cSect ENTRY "wOutputFolder"             DEFAULT acwValues[ _OUTPUTFOLDER ]

     GET acwvalues[ _HMG2FOLDER ]               SECTION cSect ENTRY "wHmg2Folder"               DEFAULT acwValues[ _HMG2FOLDER ]
     GET acwvalues[ _HMG2MING32FOLDER ]         SECTION cSect ENTRY "wHmg2Mingw32Folder"        DEFAULT acwValues[ _HMG2MING32FOLDER ]
     GET acwvalues[ _HMG2MING32HARBOURFOLDER ]  SECTION cSect ENTRY "wHmg2Mingw32HarbourFolder" DEFAULT acwValues[ _HMG2MING32HARBOURFOLDER ]
     GET acwvalues[ _HMG2XHARBOURFOLDER ]       SECTION cSect ENTRY "wHmg2XHarbourFolder"       DEFAULT acwValues[ _HMG2XHARBOURFOLDER ]
     GET acwvalues[ _HMG2EDITORFOLDER ]         SECTION cSect ENTRY "wHmg2EditorFolder"         DEFAULT acwValues[ _HMG2EDITORFOLDER ]
     GET acwvalues[ _HMG2OUTPUTFOLDER ]         SECTION cSect ENTRY "wHmg2OutputFolder"         DEFAULT acwValues[ _HMG2OUTPUTFOLDER ]

     GET acwvalues[ _HMGFOLDER ]                SECTION cSect ENTRY "wHmgFolder"                DEFAULT acwValues[ _HMGFOLDER ]
     GET acwvalues[ _HMGMING32FOLDER ]          SECTION cSect ENTRY "wHmgMingw32Folder"         DEFAULT acwValues[ _HMGMING32FOLDER ]
     GET acwvalues[ _HMGMING32HARBOURFOLDER ]   SECTION cSect ENTRY "wHmgMingw32HarbourFolder"  DEFAULT acwValues[ _HMGMING32HARBOURFOLDER ]
     GET acwvalues[ _HMGXHARBOURFOLDER ]        SECTION cSect ENTRY "wHmgXHarbourFolder"        DEFAULT acwValues[ _HMGXHARBOURFOLDER ]
     GET acwvalues[ _HMGEDITORFOLDER ]          SECTION cSect ENTRY "wHmgEditorFolder"          DEFAULT acwValues[ _HMGEDITORFOLDER ]
     GET acwvalues[ _HMGOUTPUTFOLDER ]          SECTION cSect ENTRY "wHmgOutputFolder"          DEFAULT acwValues[ _HMGOUTPUTFOLDER ]

     GET acwvalues[ _ADS ]                      SECTION cSect ENTRY "wADS"                      DEFAULT acwValues[ _ADS ]
     GET acwvalues[ _MYSQL ]                    SECTION cSect ENTRY "wMySql"                    DEFAULT acwValues[ _MYSQL ]
     GET acwvalues[ _ODBC ]                     SECTION cSect ENTRY "wODBC"                     DEFAULT acwValues[ _ODBC ]
     GET acwvalues[ _ZIP ]                      SECTION cSect ENTRY "wZip"                      DEFAULT acwValues[ _ZIP ]

     GET acwvalues[ _CONSOLE ]                  SECTION cSect ENTRY "wConsole"                  DEFAULT acwValues[ _CONSOLE ]
     GET acwvalues[ _GUI ]                      SECTION cSect ENTRY "wGui"                      DEFAULT acwValues[ _GUI ]

     GET acwvalues[ _MINIGUIEXT ]               SECTION cSect ENTRY  "wMiniguiExt"              DEFAULT acwValues[ _MINIGUIEXT ]
     GET acwvalues[ _HMG2 ]                     SECTION cSect ENTRY  "wHmg2"                    DEFAULT acwValues[ _HMG2 ]

     GET acwvalues[ _BCC55 ]                    SECTION cSect  ENTRY  "wBCC55"                  DEFAULT acwValues[ _BCC55 ]
     GET acwvalues[ _MINGW32 ]                  SECTION cSect  ENTRY  "wMingw32"                DEFAULT acwValues[ _MINGW32 ]
     GET acwvalues[ _HARBOUR ]                  SECTION cSect  ENTRY  "wHarbour"                DEFAULT acwValues[ _HARBOUR ]
     GET acwvalues[ _XHARBOUR ]                 SECTION cSect  ENTRY  "wXharbour"               DEFAULT acwValues[ _XHARBOUR ]

     GET acwvalues[ _SAVEOPTIONS ]              SECTION cSect  ENTRY  "wSaveOptions"            DEFAULT acwValues[ _SAVEOPTIONS ]
     GET acwvalues[ _DISABLEWARNINGS ]          SECTION cSect  ENTRY  "wDisableWarnings"        DEFAULT acwValues[ _DISABLEWARNINGS ]
     GET acwvalues[ _UPX  ]                     SECTION cSect  ENTRY  "wUPX"                    DEFAULT acwValues[ _UPX ]
     GET acwvalues[ _LAYOUT ]                   SECTION cSect  ENTRY  "wLayout"                 DEFAULT acwValues[ _LAYOUT ]
     GET acwvalues[ _BUILDTYPE ]                SECTION cSect  ENTRY  "wBuildType"              DEFAULT acwValues[ _BUILDTYPE ]

     GET acwvalues[ _ADDLIBMINBCCHB ]           SECTION cSect ENTRY  "wAddLibMinBccHb"          DEFAULT acwValues[ _ADDLIBMINBCCHB ]
     GET acwvalues[ _ADDLIBMINNCCXHB ]          SECTION cSect ENTRY  "wAddLibMinBccXhb"         DEFAULT acwValues[ _ADDLIBMINNCCXHB ]
     GET acwvalues[ _ADDLIBMINMINGHB ]          SECTION cSect ENTRY  "wAddLibMinMingHb"         DEFAULT acwValues[ _ADDLIBMINMINGHB ]
     GET acwvalues[ _ADDLIBMINMINGXHB ]         SECTION cSect ENTRY  "wAddLibMinMingXhb"        DEFAULT acwValues[ _ADDLIBMINMINGXHB ]
     GET acwvalues[ _ADDLIBHMG2HB ]             SECTION cSect ENTRY  "wAddLibHmg2Hb"            DEFAULT acwValues[ _ADDLIBHMG2HB ]

     GET acwvalues[ _ADDLIBINCBCCHB ]           SECTION cSect ENTRY  "wAddIncMinBccHb"          DEFAULT acwValues[ _ADDLIBINCBCCHB ]
     GET acwvalues[ _ADDLIBINCBCCXHB ]          SECTION cSect ENTRY  "wAddIncMinBccXhb"         DEFAULT acwValues[ _ADDLIBINCBCCXHB ]
     GET acwvalues[ _ADDLIBINCMINGHB ]          SECTION cSect ENTRY  "wAddIncMinMingHb"         DEFAULT acwValues[ _ADDLIBINCMINGHB ]
     GET acwvalues[ _ADDLIBINCMINGXHB ]         SECTION cSect ENTRY  "wAddIncMinMingXhb"        DEFAULT acwValues[ _ADDLIBINCMINGXHB ]
     GET acwvalues[ _ADDLIBINCHMG2HB ]          SECTION cSect ENTRY  "wAddIncHmg2Hb"            DEFAULT acwValues[ _ADDLIBINCHMG2HB ]

     GET acwvalues[ _MULTITHREAD ]              SECTION cSect ENTRY  "wMultiThread"             DEFAULT acwValues[ _MULTITHREAD ]

     GET acwvalues[ _PROJECTPATH ]              SECTION cSect1 ENTRY "wProjectPath"             DEFAULT acwValues[ _PROJECTPATH ]
     GET acwvalues[ _FORMPATH ]                 SECTION cSect1 ENTRY "wFormPath"                DEFAULT acwValues[ _FORMPATH ]
     GET acwvalues[ _MODULEPATH ]               SECTION cSect1 ENTRY "wModulePath"              DEFAULT acwValues[ _MODULEPATH ]
     GET acwvalues[ _REPORTPATH ]               SECTION cSect1 ENTRY "wReportPath"              DEFAULT acwValues[ _REPORTPATH ]
     GET acwvalues[ _MENUPATH ]                 SECTION cSect1 ENTRY "wMenuPath"                DEFAULT acwValues[ _MENUPATH ]
     GET acwvalues[ _DBFPATH ]                  SECTION cSect1 ENTRY "wDbfPath"                 DEFAULT acwValues[ _DBFPATH ]
     GET acwvalues[ _RESOURCEPATH ]             SECTION cSect1 ENTRY "wResourcePath"            DEFAULT acwValues[ _RESOURCEPATH ]

     GET acwValues[ _PROJECTFONTNAME ]          SECTION cSect  ENTRY "wFontName"                DEFAULT acwValues[ _PROJECTFONTNAME ]
     GET acwValues[ _PROJECTFONTSIZE ]          SECTION cSect  ENTRY "wFontSize"                DEFAULT acwValues[ _PROJECTFONTSIZE ]
   END INI

   aData     := AClone( acwValues )

   SET FONT TO '"' + aData[ _PROJECTFONTNAME ] + '"' , aData[ _PROJECTFONTSIZE ]
   BuildType := iif( aData[ _BUILDTYPE ] = "1", "full", "not" )

   IF ! File( System.TempFolder + "\Test.dbf" )
      CreateTable()
   ENDIF

   SaveEditorName()

RETURN


*------------------------------------------------------------*
PROCEDURE SaveEditorName
*------------------------------------------------------------*
   IF aData[ _MINIGUIEXT ] = ".T."
      IF aData[ _BCC55 ] = ".T."
         MainEditor := aData[ _EDITORFOLDER ]
      ELSE
         MainEditor := aData[ _HMGEDITORFOLDER ]
      ENDIF
   ELSE
      MainEditor := aData[ _HMG2EDITORFOLDER ]
   ENDIF
RETURN


*------------------------------------------------------------*
PROCEDURE InitPreferences()
*------------------------------------------------------------*
   LoadPreferences()

   Preferences.Text_1.Value        := aData[ _MG_FOLDER  ]
   Preferences.Text_2.Value        := aData[ _BCC_FOLDER ]
   Preferences.Text_3.Value        := aData[ _HARBOURFOLDER ]
   Preferences.Text_4.Value        := aData[ _XHARBOURFOLDER ]
   Preferences.Text_5.Value        := aData[ _EDITORFOLDER ]
   Preferences.Text_6.Value        := aData[ _OUTPUTFOLDER ]

   Preferences.Text_7.Value        := aData[ _HMG2FOLDER ]
   Preferences.Text_8.Value        := aData[ _HMG2MING32FOLDER ]
   Preferences.Text_9.Value        := aData[ _HMG2MING32HARBOURFOLDER ]
   Preferences.Text_10.Value       := aData[ _HMG2XHARBOURFOLDER ]
   Preferences.Text_11.Value       := aData[ _HMG2EDITORFOLDER ]
   Preferences.Text_12.Value       := aData[ _HMG2OUTPUTFOLDER ]

   Preferences.Text_13.Value       := aData[ _HMGFOLDER ]
   Preferences.Text_14.Value       := aData[ _HMGMING32FOLDER ]
   Preferences.Text_15.Value       := aData[ _HMGMING32HARBOURFOLDER ]
   Preferences.Text_16.Value       := aData[ _HMGXHARBOURFOLDER ]
   Preferences.Text_17.Value       := aData[ _HMGEDITORFOLDER ]
   Preferences.Text_18.Value       := aData[ _HMGOUTPUTFOLDER ]

   Preferences.Check_1.Value       := iif( aData[ _ADS ]             = ".F.", .F., .T. ) // ads
   Preferences.Check_2.Value       := iif( aData[ _MYSQL ]           = ".F.", .F., .T. ) // mysql
   Preferences.Check_3.Value       := iif( aData[ _ODBC ]            = ".F.", .F., .T. ) // odbc
   Preferences.Check_4.Value       := iif( aData[ _ZIP ]             = ".F.", .F., .T. ) // zip

   Preferences.Check_5.Value       := iif( aData[ _CONSOLE ]         = ".F.", .F., .T. ) // console
   Preferences.Check_6.Value       := iif( aData[ _GUI ]             = ".F.", .F., .T. ) // gui
   Preferences.Check_7.Value       := iif( aData[ _DISABLEWARNINGS ] = ".F.", .F., .T. ) // disable warnings
   Preferences.Check_8.Value       := iif( aData[ _UPX ]             = ".F.", .F., .T. ) // upx

   Preferences.RadioGroup_1.Value  := iif( aData[ _MINIGUIEXT ]      = ".T.", 1, 2 )   // minigui\hmg2
   Preferences.RadioGroup_2.Value  := iif( aData[ _BCC55 ]           = ".T." .OR. aData[ 28 ] = '1', 1, 2 ) // bcc\mingw32
   Preferences.RadioGroup_3.Value  := iif( aData[ _HARBOUR ]         = ".T.", 1, 2 )   // harbour\xharbour
   Preferences.RadioGroup_4.Value  := iif( aData[ _LAYOUT ]          = '1'  , 1, 2 )   // layout
   Preferences.RadioGroup_5.Value  := iif( aData[ _BUILDTYPE ]       = '1'  , 1, 2 )   // buildtype
   Preferences.RadioGroup_6.Value  := iif( aData[ _SAVEOPTIONS ]     = '1'  , 1, 2 )   // save options
   Preferences.RadioGroup_MT.Value := iif( aData[ _MULTITHREAD ]     = ".T.", 1, 2 )   // MutliThread build

   FillAddPreferences()

RETURN


*------------------------------------------------------------*
PROCEDURE FillAddPreferences()
*------------------------------------------------------------*
   IF lDisabled
      RETURN
   ENDIF

   IF Preferences.RadioGroup_1.Value = 1

      IF Preferences.RadioGroup_2.Value = 1

         IF Preferences.RadioGroup_3.Value = 1
            Preferences.Text_19.Value := aData[ _ADDLIBMINBCCHB ]   //bcchb
            Preferences.Text_20.Value := aData[ _ADDLIBINCBCCHB ]   //bcchb

         ELSE
            Preferences.Text_19.Value := aData[ _ADDLIBMINNCCXHB ]  //bccxhb
            Preferences.Text_20.Value := aData[ _ADDLIBINCBCCXHB ]  //bccxhb
         ENDIF

      ELSE
         IF Preferences.RadioGroup_3.Value = 1
            Preferences.Text_19.Value := aData[ _ADDLIBMINMINGHB ]  //minghb
            Preferences.Text_20.Value := aData[ _ADDLIBINCMINGHB ]  //minghb

         ELSE
            Preferences.Text_19.Value := aData[ _ADDLIBMINMINGXHB ] //mingxhb
            Preferences.Text_20.Value := aData[ _ADDLIBINCMINGXHB ] //mingxhb
         ENDIF
      ENDIF

   ELSE
      lDisabled                      := .T.
      Preferences.RadioGroup_2.Value := 2
      Preferences.RadioGroup_3.Value := 1
      Preferences.Text_19.Value      := aData[ _ADDLIBHMG2HB ]    //hmg2hb
      Preferences.Text_20.Value      := aData[ _ADDLIBINCHMG2HB ] //hmg2hb
      lDisabled                      := .F.
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE SavePreferences()
*------------------------------------------------------------*
   LOCAL cSect  := 'wPreferences'
   LOCAL cSect1 := 'wcPaths'

   IF isWindowActive( PREFERENCES )

      aData[ _FILE ]                    := 'HmgsIde_Cfg'
      aData[ _MG_FOLDER ]               := Preferences.Text_1.Value
      aData[ _BCC_FOLDER ]              := Preferences.Text_2.Value
      aData[ _HARBOURFOLDER ]           := Preferences.Text_3.Value
      aData[ _XHARBOURFOLDER ]          := Preferences.Text_4.Value
      aData[ _EDITORFOLDER ]            := Preferences.Text_5.Value
      aData[ _OUTPUTFOLDER ]            := Preferences.Text_6.Value

      aData[ _HMG2FOLDER ]              := Preferences.Text_7.Value
      aData[ _HMG2MING32FOLDER ]        := Preferences.Text_8.Value
      aData[ _HMG2MING32HARBOURFOLDER ] := Preferences.Text_9.Value
      aData[ _HMG2XHARBOURFOLDER ]      := Preferences.Text_10.Value
      aData[ _HMG2XHARBOURFOLDER ]      := Preferences.Text_11.Value
      aData[ _HMG2OUTPUTFOLDER ]        := Preferences.Text_12.Value

      aData[ _HMGFOLDER ]               := Preferences.Text_13.Value
      aData[ _HMGMING32FOLDER ]         := Preferences.Text_14.Value
      aData[ _HMGMING32HARBOURFOLDER ]  := Preferences.Text_15.Value
      aData[ _HMGXHARBOURFOLDER ]       := Preferences.Text_16.Value
      aData[ _HMGEDITORFOLDER ]         := Preferences.Text_17.Value
      aData[ _HMGOUTPUTFOLDER ]         := Preferences.Text_18.Value

      IF Preferences.RadioGroup_1.Value = 1

         IF Preferences.RadioGroup_2.Value = 1

            IF Preferences.RadioGroup_3.Value = 1
               aData[ _ADDLIBMINBCCHB ] := Preferences.Text_19.Value   //bcchb
               aData[ _ADDLIBINCBCCHB ] := Preferences.Text_20.Value   //bcchb

            ELSE
               aData[ _ADDLIBMINNCCXHB ] := Preferences.Text_19.Value  //bccxhb
               aData[ _ADDLIBINCBCCXHB ] := Preferences.Text_20.Value  //bccxhb
            ENDIF

         ELSE
            IF Preferences.RadioGroup_3.Value = 1
               aData[ _ADDLIBMINMINGHB ] := Preferences.Text_19.Value  //minghb
               aData[ _ADDLIBINCMINGHB ] := Preferences.Text_20.Value  //minghb

            ELSE
               aData[ _ADDLIBMINMINGXHB ] := Preferences.Text_19.Value //mingxhb
               aData[ _ADDLIBINCMINGXHB ] := Preferences.Text_20.Value //mingxhb
            ENDIF
         ENDIF

      ELSE
         aData[ _ADDLIBHMG2HB ]    := Preferences.Text_19.Value //hmg2hb
         aData[ _ADDLIBINCHMG2HB ] := Preferences.Text_20.Value //hmg2hb
      ENDIF

      aData[ _ADS ]             := iif( Preferences.check_1.Value = .F., ".F.", ".T." ) // ads
      aData[ _MYSQL ]           := iif( Preferences.check_2.Value = .F., ".F.", ".T." ) // mysql
      aData[ _ODBC ]            := iif( Preferences.check_3.Value = .F., ".F.", ".T." ) // odbc
      aData[ _ZIP ]             := iif( Preferences.check_4.Value = .F., ".F.", ".T." ) // zip
      aData[ _CONSOLE ]         := iif( Preferences.check_5.Value = .F., ".F.", ".T." ) // console
      aData[ _GUI ]             := iif( Preferences.check_6.Value = .F., ".F.", ".T." ) // gui
      aData[ _DISABLEWARNINGS ] := iif( Preferences.check_7.Value = .F., ".F.", ".T." ) // disable warnings
      aData[ _UPX ]             := iif( Preferences.check_8.Value = .F., ".F.", ".T." ) // upx

      aData[ _MINIGUIEXT ]      := iif( Preferences.RadioGroup_1.Value = 1, ".T.", ".F." ) // minigui
      aData[ _HMG2 ]            := iif( Preferences.RadioGroup_1.Value = 2, ".T.", ".F." ) // hmg
      aData[ _BCC55 ]           := iif( Preferences.RadioGroup_2.Value = 1, ".T.", ".F." ) // bcc
      aData[ _MINGW32 ]         := iif( Preferences.RadioGroup_2.Value = 2, ".T.", ".F." ) // ming
      aData[ _HARBOUR ]         := iif( Preferences.RadioGroup_3.Value = 1, ".T.", ".F." ) // hb
      aData[ _XHARBOUR ]        := iif( Preferences.RadioGroup_3.Value = 2, ".T.", ".F." ) // xhb

      aData[ _LAYOUT ]          := iif( Preferences.RadioGroup_4.Value = 1, '1', '2' )     // layout
      aData[ _BUILDTYPE ]       := iif( Preferences.RadioGroup_5.Value = 1, '1', '2' )     // buildtype
      aData[ _SAVEOPTIONS ]     := iif( Preferences.RadioGroup_6.Value = 1, '1', '2' )     // save options

      aData[ _MULTITHREAD ]     := iif( Preferences.RadioGroup_MT.Value = 1, ".T.", ".F." ) // MT

      BEGIN INI File cIniFile
        SET SECTION cSect ENTRY "wFile"                     TO aData[ _FILE           ]
        SET SECTION cSect ENTRY "wMiniGuiFolder"            TO aData[ _MG_FOLDER      ]
        SET SECTION cSect ENTRY "wBccFolder"                TO aData[ _BCC_FOLDER     ]
        SET SECTION cSect ENTRY "wHarbourFolder"            TO aData[ _HARBOURFOLDER  ]
        SET SECTION cSect ENTRY "wXHarbourFolder"           TO aData[ _XHARBOURFOLDER ]
        SET SECTION cSect ENTRY "wEditorFolder"             TO aData[ _EDITORFOLDER   ]
        SET SECTION cSect ENTRY "wOutputFolder"             TO aData[ _OUTPUTFOLDER   ]

        SET SECTION cSect ENTRY "wHmg2Folder"               TO aData[ _HMG2FOLDER              ]
        SET SECTION cSect ENTRY "wHmg2Mingw32Folder"        TO aData[ _HMG2MING32FOLDER        ]
        SET SECTION cSect ENTRY "wHmg2Mingw32HarbourFolder" TO aData[ _HMG2MING32HARBOURFOLDER ]
        SET SECTION CSECT ENTRY "wHmg2XHarbourFolder"       TO aData[ _HMG2XHARBOURFOLDER      ]
        SET SECTION CSECT ENTRY "wHmg2EditorFolder"         TO aData[ _HMG2EDITORFOLDER        ]
        SET SECTION CSECT ENTRY "wHmg2OutputFolder"         TO aData[ _HMG2OUTPUTFOLDER        ]

        SET SECTION CSECT ENTRY "wHmgFolder"                TO aData[ _HMGFOLDER               ]
        SET SECTION CSECT ENTRY "wHmgMinGW32Folder"         TO aData[ _HMGMING32FOLDER         ]
        SET SECTION CSECT ENTRY "wHmgMinGW32HarbourFolder"  TO aData[ _HMGMING32HARBOURFOLDER  ]
        SET SECTION CSECT ENTRY "wHmgxHarbourFolder"        TO aData[ _HMGXHARBOURFOLDER       ]
        SET SECTION CSECT ENTRY "wHmgEditorFolder"          TO aData[ _HMGEDITORFOLDER         ]
        SET SECTION CSECT ENTRY "wHmgOutputFolder"          TO aData[ _HMGOUTPUTFOLDER         ]

        SET SECTION CSECT ENTRY "wADS"                      TO aData[ _ADS        ]
        SET SECTION CSECT ENTRY "wMYSQL"                    TO aData[ _MYSQL      ]
        SET SECTION CSECT ENTRY "wODBC"                     TO aData[ _ODBC       ]
        SET SECTION CSECT ENTRY "wZIP"                      TO aData[ _ZIP        ]
        SET SECTION cSect ENTRY "wConsole"                  TO aData[ _CONSOLE    ]
        SET SECTION cSect ENTRY "wGui"                      TO aData[ _GUI        ]
        SET SECTION cSect ENTRY "wMiniguiExt"               TO aData[ _MINIGUIEXT ]
        SET SECTION cSect ENTRY "wHmg2"                     TO aData[ _HMG2       ]


        SET SECTION cSect ENTRY "wBCC55"                    TO aData[ _BCC55    ]
        SET SECTION cSect ENTRY "wMingW32"                  TO aData[ _MINGW32  ]
        SET SECTION cSect ENTRY "wHarbour"                  TO aData[ _HARBOUR  ]
        SET SECTION cSect ENTRY "wXharbour"                 TO aData[ _XHARBOUR ]

        SET SECTION cSect ENTRY "wSaveOptions"              TO aData[ _SAVEOPTIONS     ]
        SET SECTION cSect ENTRY "wDisableWarnings"          TO aData[ _DISABLEWARNINGS ]
        SET SECTION cSect ENTRY "wUPX"                      TO aData[ _UPX             ]
        SET SECTION cSect ENTRY "wLayout"                   TO aData[ _LAYOUT          ]
        SET SECTION cSect ENTRY "wBuildType"                TO aData[ _BUILDTYPE       ]

        SET SECTION cSect ENTRY  "wAddLibMinBccHb"          TO aData[ _ADDLIBMINBCCHB   ]
        SET SECTION cSect ENTRY  "wAddLibMinBccXhb"         TO aData[ _ADDLIBMINNCCXHB  ]
        SET SECTION cSect ENTRY  "wAddLibMinMingHb"         TO aData[ _ADDLIBMINMINGHB  ]
        SET SECTION cSect ENTRY  "wAddLibMinMingXhb"        TO aData[ _ADDLIBMINMINGXHB ]
        SET SECTION cSect ENTRY  "wAddLibHmg2Hb"            TO aData[ _ADDLIBHMG2HB     ]

        SET SECTION cSect ENTRY  "wAddIncMinBccHb"          TO aData[ _ADDLIBINCBCCHB   ]
        SET SECTION cSect ENTRY  "wAddIncMinBccXhb"         TO aData[ _ADDLIBINCBCCXHB  ]
        SET SECTION cSect ENTRY  "wAddIncMinMingHb"         TO aData[ _ADDLIBINCMINGHB  ]
        SET SECTION cSect ENTRY  "wAddIncMinMingXhb"        TO aData[ _ADDLIBINCMINGXHB ]
        SET SECTION cSect ENTRY  "wAddIncHmg2Hb"            TO aData[ _ADDLIBINCHMG2HB  ]
        SET SECTION cSect ENTRY  "wMultiThread"             TO aData[ _MULTITHREAD      ]
      END INI

      SaveEditorName()

      RELEASE WINDOW preferences
   ENDIF

   BEGIN INI File cIniFile
     SET SECTION cSect1 ENTRY "wProjectPath"  TO aData[ _PROJECTPATH  ]
     SET SECTION cSect1 ENTRY "wFormPath"     TO aData[ _PROJECTPATH  ]
     SET SECTION cSect1 ENTRY "wModulePath"   TO aData[ _MODULEPATH   ]
     SET SECTION cSect1 ENTRY "wReportPath"   TO aData[ _REPORTPATH   ]
     SET SECTION cSect1 ENTRY "wMenuPath"     TO aData[ _MENUPATH     ]
     SET SECTION cSect1 ENTRY "wDbfPath"      TO aData[ _DBFPATH      ]
     SET SECTION cSect1 ENTRY "wResourcePath" TO aData[ _RESOURCEPATH ]
     *----------------------------------------------------------------*
     SET SECTION cSect  ENTRY "wFontName"     TO aData[ _PROJECTFONTNAME ]
     SET SECTION cSect  ENTRY "wFontSize"     TO aData[ _PROJECTFONTSIZE ]
   END INI

RETURN


*------------------------------------------------------------*
PROCEDURE ClosePreferences()
*------------------------------------------------------------*
   RELEASE WINDOW preferences
RETURN


*------------------------------------------------------------*
PROCEDURE AddFolder( Param AS STRING)
*------------------------------------------------------------*
   LOCAL cOldFolder  AS STRING
   LOCAL cInitFolder AS STRING
   LOCAL AddFolder   AS STRING

   cOldFolder := GetProperty( 'PREFERENCES', Param, 'VALUE' )

   IF ! Empty( cOldFolder )
      cInitFolder := cOldFolder
   ELSE
      cInitFolder := ProjectFolder
   ENDIF

   AddFolder := GetFolder( 'Add Folder', cInitFolder )

   IF ! Empty( AddFolder )
      SetProperty( 'PREFERENCES', param, 'VALUE', AddFolder )
   ENDIF
RETURN


*------------------------------------------------------------*
PROCEDURE AddFile( param )
*------------------------------------------------------------*
   LOCAL AddFile AS STRING := GetFile( { { '*.exe', '*.exe' } }, 'Editor', ProjectFolder )

   IF ! Empty( AddFile )
      SetProperty( 'PREFERENCES', param, 'VALUE', AddFile )
   ENDIF
RETURN


*------------------------------------------------------------*
STATIC FUNCTION BCC_DETECT()
*------------------------------------------------------------*
   LOCAL cFileName AS STRING := "bcc32.exe"
   LOCAL cDirDef AS STRING := "c:\borland\bcc55"
   LOCAL cPath, aPath, cDir

   cPath := GetEnv( "MG_BCC" )
   IF ! Empty( cDir := NoQuota( cPath ) )
        RETURN Lower( cDir )
   ENDIF

   cPath := GetEnv( "PATH" )
   aPath := hb_ATokens( cPath, hb_osPathListSeparator(), .T., .T. )

   FOR EACH cDir IN aPath
      IF ! Empty( cDir := NoQuota( cDir ) )
         IF hb_FileExists( hb_DirSepAdd( cDir ) + cFileName )
            RETURN Lower( cDir )
         ENDIF
      ENDIF
   NEXT
RETURN cDirDef
