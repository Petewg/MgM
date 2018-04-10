/******
*
*       Stock.ch
*
*       Common definitions
*
*/

// About program

#define APPTITLE                  'Stock'
#define APPVERSION                '2006.11.1'
#define COPYRIGHT                 'V.V.Chumachenko'

// Program Folder
#define DATA_PATH                 ( GetStartupFolder() + '\Data\' )

// Language files Folder
#define LANGFILE_PATH             ( GetStartupFolder() + '\Langs\' )

// INI filename
#define STOCK_INI                 ( GetStartupFolder() + '\Stock.ini' )

// Key words files

#define FILE_COMMANDS             ( DATA_PATH + 'Commands.lst' )    // Single words and commands
#define FILE_PHRASES              ( DATA_PATH + 'Phrases.lst'  )    // Compound operators

#define COMMENT_CHAR              ';'            // Commentary in key words files


// Array with work params

#define OPTIONS_ONSTART           1              // Startup action
#define OPTIONS_SEARCH            2              // Search mode for list
#define OPTIONS_GETPATH           3              // Last used folder
#define OPTIONS_TITLE             4              // Title
#define OPTIONS_LASTFILE          5              // Last used file
#define OPTIONS_EDITOR            6              // External editor
#define OPTIONS_RUNMODE           7              // Start mode for external editor
#define OPTIONS_EDITOR_PARMS      8              // String with complementary params
                                                 // for external editor
#define OPTIONS_LANGFILE          9              // Language filename
                                                 
#define OPTIONS_ALEN              9              // Dimensionality of params array

// Multilingual interface: requests for strings and appropriate them
// sections in lang file

#define GET_MENU_LANG             1              // Menu strings
#define GET_MAINFORM_LANG         2              // Main menu
#define GET_OPTIONSFORM_LANG      3              // Options dialog
#define GET_SELECTLANGFORM_LANG   4              // Language dialog
#define GET_SETTITLE_LANG         5              // Catalog Title dialog
#define GET_FINDALL_LANG          6              // Search in list dialog
#define GET_FORMATTER_LANG        7              // Code formatting dialog
#define GET_CALLSTABLE_LANG       8              // Function calling dialog
#define GET_SYSDIALOGS_LANG       9              // Strings for system dialogs

#define HEADER_SECTION            'HEADER'
#define MAINMENU_SECTION          'MAINMENU'
#define MAINFORM_SECTION          'MAIN_FORM'
#define OPTIONSFORM_SECTION       'OPTIONS_FORM'
#define SELECTLANGFORM_SECTION    'SELECTLANG_FORM'
#define SETTITLEFORM_SECTION      'SETTITLE_FORM'
#define FINDALLFORM_SECTION       'FINDALL_FORM'
#define FORMATTERFORM_SECTION     'FORMATTER_FORM'
#define CALSSTABLE_SECTION        'CALLSTABLE_FORM'
#define SYSDIALOGSFORM_SECTION    'SYSDIALOGS_FORM'

// Structure of key words array

#define KEYWORD_LONG              1              // Full name (as in file)
#define KEYWORD_FREEZE            2              // Attribute "Use as defined
                                                 // in key words files"
#define KEYWORD_ALEN              2

// Formatting modes (the register changing) for key words

#define KEYWORD_LOWER             1              // to lower
#define KEYWORD_UPPER             2              // to upper
#define KEYWORD_CAPITALIZE        3              // Head first symbol

// Misc

#define CRLF                      HB_OSNewLine()

// Quantity of symbols for key words recognition

#define MINKEYWORD_LEN            5
