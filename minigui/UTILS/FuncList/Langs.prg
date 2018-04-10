#include "Directry.ch"
#include "MiniGUI.ch"
#include "Stock.ch"


// Language template

#define TEMPLATE_NAME        'TEMPLATE.LNG'
#define TEMPLATE_FILE        ( LANGFILE_PATH + TEMPLATE_NAME )

// Messages arrays

// Main menu

#define ARRMENU_LANG         { { 'File', 'File'                                          }, ;
                               { 'New'    , 'New'                                        }, ;
                               { 'msgNew' , 'Build new list'                             }, ;
                               { 'Open'   , 'Open'                                       }, ;
                               { 'msgOpen', 'Load existing list'                         }, ;
                               { 'Save'   , 'Save'                                       }, ;
                               { 'msgSave', 'Save list to file'                          }, ;
                               { 'Exit'   , 'Exit'                                       }, ;
                               { 'msgExit', 'Leaving programm'                           }, ;
                             { 'Edit', 'Edit'                                            }, ;
                               { 'SetTitle'     , 'Description'                          }, ;
                               { 'msgSetTitle'  , 'Set description current catalog'      }, ;
                               { 'OpenEditor'   , 'Open in editor'                       }, ;
                               { 'msgOpenEditor', 'Open module in external editor'       }, ;
                               { 'CopyName'     , 'Copy name'                            }, ;
                               { 'msgCopyName'  , 'Copy name to buffer Windows'          }, ;
                             { 'Tools', 'Tools'                                          }, ;
                               { 'CodeFormat'   , 'Code formatting'                      }, ;
                               { 'msgCodeFormat', 'Source code formatter'                }, ;
                               { 'CallsTable'   , 'Functions calls'                      }, ;
                               { 'msgCallsTable', 'Procedures and functions calls table' }, ;
                             { 'Service', 'Service'                                      }, ;
                               { 'Language'      , 'Language'                            }, ;
                                 { 'SelectLang'  , 'Choose language'                     }, ;
                                 { 'msgLanguage' , 'Select language'                     }, ;
                                 { 'TemplateLang', 'Create template'                     }, ;
                                 { 'msgTemplate', 'Create language template file'        }, ;
                             { 'Options', 'Options'                                      }, ;
                               { 'msgOptions', 'Set options of programm'                 }, ;
                             { 'About', 'About'                                          }, ;
                             { 'msgAbout', 'About Stock'                                 }  ;
                             }

// Main window

#define ARRMAINFORM_LANG     { { 'Title'        , APPTITLE                  }, ;
                               { 'btnNew'       , 'Create new list'         }, ;
                               { 'btnOpen'      , 'Load list from file'     }, ;
                               { 'btnSave'      , 'Save to file'            }, ;
                               { 'btnEdit'      , 'Open in external editor' }, ;
                               { 'btnOptions'   , 'Settings'                }, ;
                               { 'NameColumn'   , 'Name'                    }, ;
                               { 'TypeColumn'   , 'Type'                    }, ;
                               { 'CommentColumn', 'Comment'                 }, ;
                               { 'lblSearch'    , 'Find'                    }, ;
                               { 'msgSearch'    , 'String for search'       }, ;
                               { 'btnSearch'    , 'Find more'               }, ;
                               { 'btnFindAll'   , 'Find all'                }  ;
                             }

// Options form

#define ARROPTIONFORM_LANG   { { 'Title'         , 'Options'           }, ;
                               { 'frmOnStart'    , 'On start'          }, ;
                               { 'rdgOnStart1'   , 'Nothing'           }, ;
                               { 'rdgOnStart2'   , 'Load last list'    }, ;
                               { 'frmSearch'     , 'Search mode'       }, ;
                               { 'rdgSearch1'    , 'Exact'             }, ;
                               { 'rdgSearch2'    , 'Match'             }, ;
                               { 'Editor'        , 'External editor'   }, ;
                               { 'rdgParameters1', 'Simple'            }, ;
                               { 'rdgParameters2', 'Goto line %N'      }, ;
                               { 'rdgParameters3', 'Goto procedure %P' }  ;
                             }

// Language selecting form

#define ARRSELECTLANG_LANG   { { 'Title', 'Select language' } }

// Catalog Title selecting form

#define ARRSETTITLE_LANG     { { 'Title'  , 'Title catalog' }, ;
                               { 'lblName', 'Name'          }  ;
                             }

// Search in list form

#define ARRFINDALL_LANG      { { 'Title'     , 'Result search' }, ;
                               { 'lblName'   , 'Entry'         }, ;
                               { 'NameColumn', 'Name'          }, ;
                               { 'FileColumn', 'File'          }, ;
                               { 'TypeColumn', 'Type'          }, ;
                               { 'btnGoto'   , 'Go'            }  ;
                             }

// Code formatting form

#define ARRFORMAT_LANG       { { 'Title'      , 'Source code formatting' }, ;
                               { 'frmFiles'   , 'To Do'                  }, ;
                               { 'rdgFiles1'  , 'Current file only'      }, ;
                               { 'rdgFiles2'  , 'All files'              }, ;
                               { 'frmCase'    , 'Keyword case'           }, ;
                               { 'rdgCase1'   , 'lower'                  }, ;
                               { 'rdgCase2'   , 'UPPER'                  }, ;
                               { 'rdgCase3'   , 'Capitalize'             }, ;
                               { 'btnGoto'    , 'Start'                  }, ;
                               { 'Console'    , 'Progress'               }, ;
                               { 'Started'    , 'Started'                }, ;
                               { 'Skipped'    , 'skipped'                }, ;
                               { 'Finished'   , 'Finished'               }, ;
                               { 'Elapsed'    , 'Elapsed time'           }, ;
                               { 'KeyLoad'    , 'Keywords list loaded'   }, ;
                               { 'KeyEmpty'   , 'Keywords list empty'    }, ; 
                               { 'PhLoad'     , 'Phrases list loaded'    }, ;
                               { 'PhEmpty'    , 'Phrases list empty'     }, ;
                               { 'OpenError'  , 'Error open'             }, ;
                               { 'CreateError', 'Error create'           }  ;
                             }

// Function calling form

#define ARRCALLSTABLE_LANG   { { 'Console'      , 'Build ...'       }, ;
                               { 'Title'        , 'Functions calls' }, ;
                               { 'NameColumn'   , 'Name'            }, ;
                               { 'TypeColumn'   , 'Type'            }, ;
                               { 'DefinedColumn', 'Defined'         }, ;
                               { 'CalledColumn' , 'Called from'     }  ;
                             }
 
// System messages

#define ARRSYSDIALOGS_LANG   { { 'FromFile'    , 'Load from file'           }, ;
                               { 'ChoiceEditor', 'Choice editor'            }, ;
                               { 'TextFiles'   , 'Text'                     }, ;
                               { 'AppFiles'    , 'Executable'               }, ;
                               { 'AllFiles'    , 'All files'                }, ;
                               { 'SourceDir'   , 'Source directory'         }, ;
                               { 'ToFile'      , 'Save to file'             }, ;
                               { 'Warning'     , 'Warning'                  }, ;
                               { 'FileExist'   , 'File %N exist. Rewrite ?' }, ;
                               { 'Inform'      , 'Information'              }, ;
                               { 'Created'     , 'Created file %N'          }  ;
                             }



/******
*
*       SelectLanguage()
*
*       Change the language interface
*
*/

Procedure SelectLanguage
Memvar aOptions
Local aFiles  , ;
      nLen    , ;
      Cycle   , ;
      cName   , ;
      aStrings := GetLangStrings( GET_SELECTLANGFORM_LANG )
      
// If defined lang file and its exist, do initialization

If !Empty( aOptions[ OPTIONS_LANGFILE ] )
   If File( LANGFILE_PATH + aOptions[ OPTIONS_LANGFILE ] )
      aStrings := GetLangStrings( GET_SELECTLANGFORM_LANG, aOptions[ OPTIONS_LANGFILE ] )
   Endif
   
Endif

Define window wLangs           ;
       At 0, 0                 ;
       Width 245               ;
       Height 125              ;
       Title aStrings[ 1, 2 ] ;
       Icon 'STOCK'            ;
       Modal

   @ 15, 10 ComboBox cmbLangs ;
            Width 215         ;
            Height 165        ;
            Items {}          ;
            On Change SetProperty( 'wLangs', 'btnOK', 'Enabled', !Empty( This.Value ) )       

   @ ( wLangs.cmbLangs.Row + 40 ), wLangs.cmbLangs.Col ;
     Button btnOK                                      ;
     Caption _HMG_MESSAGE[ 6 ]                         ;
     Action LangReset( aFiles )

   @ wLangs.btnOk.Row, ( wLangs.btnOk.Col + wLangs.btnOk.Width + 15 ) ;
     Button btnCancel                                                 ;
     Caption _HMG_MESSAGE[ 7 ]                                        ;
     Action ThisWindow.Release
     
   On key Escape of wLangs Action wLangs.Release
   On key Alt+X  of wLangs Action ReleaseAllWindows()
                 
End Window

// Create lang files list

If !Empty( aFiles := Directory( LANGFILE_PATH + '*.lng' ) )

   nLen := Len( aFiles )
   For Cycle := 1 to nLen
   
     // Look for existing files and add to list
     // the lang name (exception - template file)

     If !( Upper( aFiles[ Cycle, F_NAME ] ) == TEMPLATE_NAME )
     
        cName := ''
     
        Begin ini file ( LANGFILE_PATH + aFiles[ Cycle, F_NAME ] )
           Get cName Section HEADER_SECTION Entry 'NativeLanguage' Default ''
        End ini
     
        If Empty( cName )
           cName := aFiles[ Cycle, F_NAME ]
        Endif
           
        wLangs.cmbLangs.AddItem( cName )

     Endif
           
   Next
   
   // Setup position of current language
   
   nLen := AScan( aFiles, { | elem | Upper( elem[ F_NAME ] ) == Upper( aOptions[ OPTIONS_LANGFILE ] ) } )

   If !Empty( nLen )
      wLangs.cmbLangs.Value := nLen
   Endif

Endif

If Empty( wLangs.cmbLangs.Value )
   wLangs.btnOK.Enabled := .F.
Endif

Center window wLangs
Activate window wLangs

Return

****** End of SelectLanguage ******


/******
*
*       LangReset( aFiles )
*
*       Reinstallation the language interface
*
*/

Static Procedure LangReset( aFiles )
Memvar aOptions
Local nValue := wLangs.cmbLangs.Value

If !Empty( nValue )

   aOptions[ OPTIONS_LANGFILE ] := aFiles[ nValue, F_NAME ]
   
   Begin ini file STOCK_INI
     Set section 'MAIN' entry 'LangFile' to aOptions[ OPTIONS_LANGFILE ] 
   End ini

   // Change main window, menu, setup messages
      
   ModifyMainForm( GetLangStrings( GET_MAINFORM_LANG, aOptions[ OPTIONS_LANGFILE ] ) )
   BuildMenu( GetLangStrings( GET_MENU_LANG, aOptions[ OPTIONS_LANGFILE ] ) )

   SetBaseLang()

Endif

wLangs.Release

Return

****** End of LangReset ******


/******
*
*       SetBaseLang()
*
*       Setup messages (buttons caption, messages, ...)
*
*/

Procedure SetBaseLang
Memvar aOptions
Local cName := ''
 
// Get english name of selecting language and setup
// as environment

If !Empty( aOptions[ OPTIONS_LANGFILE ] )
   
   If File( LANGFILE_PATH + aOptions[ OPTIONS_LANGFILE ] )
      
      Begin ini file ( LANGFILE_PATH + aOptions[ OPTIONS_LANGFILE ] )
        Get cName Section HEADER_SECTION Entry 'Language' Default ''
      End ini
   
   Endif
   
Endif

If !Empty( cName  )

   cName := Upper( cName )

   Do case
      Case ( cName == 'SPANISH' )
        Set language to Spanish

      Case ( cName == 'FRENCH' )
        Set language to French

      Case ( cName == 'PORTUGUESE' )
        Set language to Portuguese
   
      Case ( cName == 'ITALIAN' )
        Set language to Italian

      Case ( cName == 'GERMAN' )
        Set language to German

      Case ( cName == 'POLISH' )
        Set language to Polish

      Case ( cName == 'FINNISH' )
        Set language to Finnish

      Case ( cName == 'DUTCH' )
        Set language to Dutch

      Case ( cName == 'RUSSIAN' )
        Set language to Russian

//      Case ( cName == 'UKRAINIAN' )
//        Set language to Ukrainian

      Otherwise
        Set language to English
     
   Endcase

Else
  Set language to English
  
Endif

Return

****** End of SetBaseLang ******


/*****
*
*       GetLangStrings( nType, cFile ) --> aStrings
*
*       Getting array of lang strings.
*
*/

Function GetLangStrings( nType, cFile )
Local aStrings    , ;
      cSectionName

Do case
   Case ( nType == GET_MENU_LANG )            // Menu items and status help
     aStrings     := ARRMENU_LANG
     cSectionName := MAINMENU_SECTION     

   Case ( nType == GET_MAINFORM_LANG )        // Main window
     aStrings     := ARRMAINFORM_LANG
     cSectionName := MAINFORM_SECTION     

   Case ( nType == GET_OPTIONSFORM_LANG )     // Options dialog
     aStrings     := ARROPTIONFORM_LANG
     cSectionName := OPTIONSFORM_SECTION     

   Case ( nType == GET_SELECTLANGFORM_LANG )  // Language dialog
     aStrings     := ARRSELECTLANG_LANG
     cSectionName := SELECTLANGFORM_SECTION     

   Case ( nType == GET_SETTITLE_LANG )        // Catalog Title dialog
     aStrings     := ARRSETTITLE_LANG
     cSectionName := SETTITLEFORM_SECTION     

   Case ( nType == GET_FINDALL_LANG )         // Search list dialog
     aStrings     := ARRFINDALL_LANG
     cSectionName := FINDALLFORM_SECTION     

   Case ( nType == GET_FORMATTER_LANG )       // Code formatting dialog
     aStrings     := ARRFORMAT_LANG
     cSectionName := FORMATTERFORM_SECTION     

   Case ( nType == GET_CALLSTABLE_LANG )      // Function calling dialog
     aStrings     := ARRCALLSTABLE_LANG
     cSectionName := CALSSTABLE_SECTION     

   Case ( nType == GET_SYSDIALOGS_LANG )      // System dialogs (Get file,...)
     aStrings     := ARRSYSDIALOGS_LANG
     cSectionName := SYSDIALOGSFORM_SECTION     
               
Endcase

If !( cFile == nil )
   aStrings := FillLangArray( aStrings, cFile, cSectionName )     
Endif

Return aStrings

****** End of GetLangStrings *****


/******
*
*       FillLangArray( aStrings, cFile, cSection ) --> aStrings
*
*       Filling the array of lang strings from the appropriate file
*
*/

Static Function FillLangArray( aStrings, cFile, cSection )
Local nLen     := Len( aStrings ), ;
      cString                    , ;
      Cycle

cFile := ( LANGFILE_PATH + cFile )

If File( cFile )

   Begin ini file cFile
    
     For Cycle := 1 to nLen
      
       cString := ''
       Get cString Section cSection Entry aStrings[ Cycle, 1 ] Default ''
      
       If !Empty( cString )
          aStrings[ Cycle, 2 ] := AllTrim( cString )
       Endif
                
     Next
    
   End ini

Endif

Return aStrings

****** End of FillLangArray ******


/******
*
*       MakeLangTemplate()
*
*       Making template for language interface
*
*/

Procedure MakeLangTemplate
Memvar aOptions
Local aStrings := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      cString

Begin Sequence

   If File( TEMPLATE_FILE )
   
     cString := StrTran( aStrings[ 9, 2 ]               , ;
                         '%N'                           , ;
                         ( CRLF + TEMPLATE_FILE + CRLF )  ;
                       )
   
     If !MsgYesNo( cString, aStrings[ 8, 2 ], .T. )
        Break
     Else
        Erase ( TEMPLATE_FILE )
     Endif
     
   Endif

   Begin ini file TEMPLATE_FILE

     Set section HEADER_SECTION entry 'Language'       to 'Language in English'
     Set section HEADER_SECTION entry 'NativeLanguage' to 'Language national name'

     SaveToTemplate( MAINFORM_SECTION      , GetLangStrings( GET_MAINFORM_LANG ) )
     SaveToTemplate( MAINMENU_SECTION      , GetLangStrings( GET_MENU_LANG ) )
     SaveToTemplate( OPTIONSFORM_SECTION   , GetLangStrings( GET_OPTIONSFORM_LANG ) )
     SaveToTemplate( SELECTLANGFORM_SECTION, GetLangStrings( GET_SELECTLANGFORM_LANG ) )
     SaveToTemplate( SETTITLEFORM_SECTION  , GetLangStrings( GET_SETTITLE_LANG ) )
     SaveToTemplate( FORMATTERFORM_SECTION , GetLangStrings( GET_FORMATTER_LANG ) )
     SaveToTemplate( FINDALLFORM_SECTION   , GetLangStrings( GET_FINDALL_LANG ) )
     SaveToTemplate( SYSDIALOGSFORM_SECTION, GetLangStrings( GET_SYSDIALOGS_LANG ) )

   End Ini

   cString := StrTran( aStrings[ 11, 2 ], '%N', ( CRLF + TEMPLATE_FILE ) )
   MsgInfo( cString, aStrings[ 10, 2 ] )

End

Return

****** End of MakeLangTemplate ******


/******
*
*       SaveToTemplate( cSection, aStrings )
*
*       Section saving to lang template
*
*/

Static Procedure SaveToTemplate( cSection, aStrings )
Local nLen  := Len( aStrings ), ;
      Cycle

For Cycle := 1 to nLen
  Set section cSection entry aStrings[ Cycle, 1 ] to aStrings[ Cycle, 2 ]
Next

Return

****** End of SaveToTemplate ******
