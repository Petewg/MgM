#include "HBCompat.ch"
#include "MiniGUI.ch"
#include "TsBrowse.ch"
#include "DbStruct.ch"
#include "Modest.ch"

// Program messages

#define MSG_STRUCTURE_LOADED         ' structure loaded'
#define MSG_ERROR_LOAD               'Error load structure for '
#define MSG_NEW_STRUCTURE            'New structure (empty) started'
#define MSG_ERROR_FIELDNAME          'Field names begin with a letter and may contain A-Z, 0-9, and "_"'
#define MSG_CHAR_INCORRECT           'Incorrect symbol ' 
#define MSG_LEN_EMPTY                'Zero length of the field'
#define MSG_DECIMALS_LONG            'Invalid field width or number of decimals'
#define MSG_FIELD_ALREADY            'The field name is duplicated with'
#define MSG_RULE_INCORRECT           'Incorrect transormation rule'
#define MSG_RULE_TYPES               'Types mismatch.'
#define MSG_NOACTIVE_STRUCTURE       'The fields list no active'
#define MSG_STRUCTURE_EMPTY          'A structure does not contain the fields'
#define MSG_NOACTIVE_COLLECTOR       'The Collector no active'
#define MSG_COLLECTOR_EMPTY          'A Collector does not contain the records or record no select'

// Constant part of the help in editing modes

#define SHORTKEY_TOOLTIP              '[F2] - Apply, [Esc] - Discard'

// Allowable field's types

#define CORRECT_TYPES                 { 'C', 'N', 'D', 'L', 'M' }

#define TYPE_IS_CHAR                  1
#define TYPE_IS_NUM                   2
#define TYPE_IS_DATE                  3
#define TYPE_IS_LOGIC                 4
#define TYPE_IS_MEMO                  5

// Restrictions of field length

#define LEN_IS_CHAR                 254
#define LEN_IS_NUM                   20
#define LEN_IS_DATE                   8
#define LEN_IS_LOGIC                  1
#define LEN_IS_MEMO                  10

// Working mode. Utilize at editing/creation of fields.

#define MODE_DEFAULT                  0           // Main mode
#define MODE_NEWFIELD                 1           // Add field
#define MODE_INSFIELD                 2           // Insert field
#define MODE_EDITFIELD                3           // Editing

// End of dialog actions

#define SET_OK                        1           // Accept
#define SET_CANCEL                    2           // Reject

// Transfer record to collector modes

#define MODE_COPY                     0           // Copy
#define MODE_CUT                      1           // Cut

// Color theme

#define NAVY_COLOR                    { 0, 0, 106 }


// Complementary RDD
 
Request DBFCDX, DBFFPT
#include "Requests.ch"                // Function list for transformation rules


Static nShift     := 0         // Row's insert mode. Utilize in
                               // procedure FiniEditField() (for inserting a new
                               // field) and procedure of inserting from collector

Memvar aCollector
Memvar aStat
Memvar oEditStru

/******
*
*       Editing and documenting of database structures
*
*/

Procedure Main( cFile )
Local nModestHeight, ;
      aStru

// Array of working parameters

Private aStat := { 'CurrMode'   => MODE_DEFAULT , ;    // Review mode
                   'FileName'   => ''           , ;    // Working file name
                   'RDD'        => DbSetDriver(), ;    // Current database RDD
                   'DefName'    => 'NEW'        , ;    // Field name prefix at adding
                   'DefType'    => TYPE_IS_CHAR , ;    // Field type (numbet in array) CORRECT_TYPES
                   'DefLen'     => 10           , ;    // Field length
                   'DefDec'     => 0            , ;    // Field decimal
                   'Expression' => THIS_VALUE   , ;    // Transformation rule
                   'ChStruct'   => .F.          , ;    // Structure is changed
                   'ChDescript' => .F.          , ;    // Description is changed
                   'Counter'    => 1            , ;    // Internal counter (for new field adding)
                   'Cargo'      => ''             ;    // Temporary saving of mixed datas
                 }
Private oEditStru                                      // TBrowse-object
Private aCollector := {}                               // Collector of fields

aStru := InitDefault()       // Set empty structure because of TsBrowse reguires the existing
                             // of one value evethough

Set Font to 'Tahoma', 9
Set MenuStyle Extended
Set Navigation Extended

SetMenuTheme()

GetOptions()                // Loading of params from INI

Define window wModest       ;
       At 0, 0              ;
       Width 720            ;
       Height 580           ;
       Title APPNAME        ;
       Icon '1MODEST'       ;
       Main                 ;
       On Init ReSize()     ;
       On Size ReSize()     ;
       On Maximize ReSize() ;
       On Minimize ReSize() ;
       On InteractiveClose Done()

    // Creation of the program main menu

    Define main menu
    
      Define Popup '&File'
        MenuItem '&New' Action NewFile()               ;
                        Image 'NEW_FILE'               ;
                        Name pdNew                     ;
                        Message 'Create new structure'
        MenuItem '&Open' Action LoadFile() ;
                         Image 'OPEN_FILE' ;
                         Name pdOpen       ;
                         Message 'Open file and load structure'
        MenuItem '&Save' Action SaveData() ;
                         Image 'SAVE'      ;
                         Name pdSave       ;
                         Message 'Save structure and description'
        Separator
        MenuItem '&Print' Action PrintStructure() ;
                          Image 'PRINT'           ;
                          Name pdPrint            ;
                          Message 'Print structure and comments'
        Separator
        MenuItem 'E&xit Alt+X' Action { || Done(), ThisWindow.Release } ;
                               Image 'HBPRINT_CLOSE'                    ;
                               Message 'Exit from application'
      End Popup

      Define Popup '&Edit'
         MenuItem '&Copy'  Action AddInCollector( MODE_COPY ) ;
                           Image 'COPY'                       ;
                           Name pdCopy                        ;
                           Message 'Copy to Collector'
         MenuItem 'C&ut'   Action AddInCollector( MODE_CUT ) ;
                           Image 'CUT'                       ;
                           Name pdCut                        ;
                           Message 'Cut to Collector'
         MenuItem 'Paste (&After)' Action { || nShift := 1, PasteFromCollector() } ;
                                   Image 'PASTE'                                   ;
                                   Name pdPasteAfter                               ;
                                   Message 'Paste from Collector (after current)'
         MenuItem 'Paste (&Before)' Action { || nShift := 0, PasteFromCollector() } ;
                                    Name pdPasteBefore                              ;
                                    Message 'Paste from Collector (before current)'
         Separator
         MenuItem '&Description' Action EditGeneralDesc() ;
                                 Image 'EDIT_TEXT'        ;
                                 Name pdDescription       ;
                                 Message 'Modify database description'
      End Popup
      
      Define Popup 'F&ield'
         MenuItem '&Add' Action EditField( MODE_NEWFIELD ) ;
                         Image 'ADD_FIELD'                 ;
                         Name pdAdd                        ;
                         Message 'Add new field'
         MenuItem '&Edit' Action EditField( MODE_EDITFIELD ) ;
                          Image 'EDIT_FIELD'                 ;
                          Name pdEdit                        ;
                          Message 'Edit current field'
         Separator
         MenuItem '&Insert after' Action { || nShift := 1, EditField( MODE_INSFIELD ) } ;
                                  Image 'INS_FIELD'                                      ;
                                  Name pdInsertAfter                                    ;
                                  Message 'Insert field after current'
         MenuItem 'Insert &before' Action { || nShift := 0, EditField( MODE_INSFIELD ) } ;
                                   Name pdInsertBefore                                   ;
                                   Message 'Insert field before current'
         Separator
         MenuItem '&Delete' Action DelField() ;
                            Image 'DEL_FIELD' ;
                            Name pdDelete     ;
                            Message 'Delete/Undelete field'
      End Popup
      
      Define Popup '&Service'
        MenuItem '&Export to text' Action ExportToTXT() ;
                                   Name pdExport        ;
                                   Message 'Export description to text file'
        Separator
        MenuItem 'Clear &messages' Action ClearMsg() ;
                                   Message 'Clear messages area'
        MenuItem 'Clear &Collector' Action ClearCollector() ;
                                    Message 'Clear Collector'
        Separator
        MenuItem '&Options' Action Options() ;
                            Image 'OPTIONS'  ;
                            Message 'Set parameters application'
      End Popup
      
      Define Popup '?' Name ppHelp
         MenuItem '&About me' Action AboutMe() Image 'ABOUT'
      End Popup
            
    End Menu

   // Toolbar

   Define Toolbar tbrAction ButtonSize 24, 24 Flat
     Button btnNewFile         ;
            Picture 'NEW_FILE' ;
            Action NewFile()   ;
            Tooltip 'New file'
     Button btnOpenFile         ;
            Picture 'OPEN_FILE' ;
            Action LoadFile()   ;
            Tooltip 'Load structure from file'
     Button btnSave           ;
            Picture 'SAVE'    ;
            Action SaveData() ;
            Tooltip 'Save files'
     Button btnPrint Picture 'PRINT'               ;
            Action PrintStructure()                ;
            Tooltip 'Print structure and comments' ;
            Separator
     Button btnEditGeneral                        ;
            Picture 'EDIT_TEXT'                   ;
            Action EditGeneralDesc()              ;
            Tooltip 'Modify database description' ;
            Separator
     Button btnAddField                       ;
            Picture 'ADD_FIELD'               ;
            Action EditField( MODE_NEWFIELD ) ;
            Tooltip 'Add field'
     Button btnInsField                                           ;
            Picture 'INS_FIELD'                                   ;
            Action { || nShift := 1, EditField( MODE_INSFIELD ) } ;
            DropDown                                              ;
            Tooltip 'Insert field after current (default)'
     Button btnEditField                       ;
            Picture 'EDIT_FIELD'               ;
            Action EditField( MODE_EDITFIELD ) ;
            Tooltip 'Modify field'
     Button btnDeleteField         ;
            Picture 'DEL_FIELD'    ;
            Action DelField()      ;
            Tooltip 'Delete field' ;
            Separator
     Button btnCopy                            ;
            Picture 'COPY'                     ;
            Action AddInCollector( MODE_COPY ) ;
            Tooltip 'Copy to Collector'
     Button btnCut                            ;
            Picture 'CUT'                     ;
            Action AddInCollector( MODE_CUT ) ;
            Tooltip 'Cut to Collector'
     Button btnPaste                                               ;
            Picture 'PASTE'                                        ;
            Action { || nShift := 1, PasteFromCollector() }        ;
            DropDown                                               ;
            Tooltip 'Paste from Collector after current (default)' ;
            Separator
     Button btnOptions                           ;
            Picture 'OPTIONS'                    ;
            Action Options()                     ;
            Tooltip 'Set parameters application' ;
            Separator
     Button btnAbout         ;
            Picture 'ABOUT'  ;
            Action AboutMe() ;
            Tooltip 'About me'
   End Toolbar

   // Dropdown menu for inserting a new field

   Define dropdown menu button btnInsField
      MenuItem 'Insert after'  Action { || nShift := 1, EditField( MODE_INSFIELD ) } ;
                               Message 'Insert field after current'
      MenuItem 'Insert before' Action { || nShift := 0, EditField( MODE_INSFIELD ) } ;
                               Message 'Insert field before current'
   End Menu
   
   // Dropdown menu for inserting a field from collector

   Define dropdown menu button btnPaste
      MenuItem 'Insert after'  Action { || nShift := 1, PasteFromCollector() } ;
                               Message 'Paste from Collector (after current)'
      MenuItem 'Insert before' Action { || nShift := 0, PasteFromCollector() } ;
                               Message 'Paste from Collector (before current)'
   End Menu

   // Status bar
   // Declaration is placed before others definitions of controls,
   // because it is necessary for TsBrowse for show of position. 

   Define statusbar Font 'Tahoma' Size 9
     StatusItem '' Default
     StatusItem '' Width 100                           // Show of position
     StatusItem '' Width 30                            // Changing indicator
     StatusItem aStat[ 'RDD' ] Width 100               // Current database RDD
   End Statusbar

   // Warning!
   // The all following coords of controls are conditional and changed by
   // procedure ReSize()

   // Table of existing fields

   Define TBrowse oEditStru                  ;
     At 40 + If(IsXPThemeActive(), 5, 0), 5  ;
     Width 200                               ;
     Height 200                              ;
     On Change ShowValues()                  ;
     On DblClick EditField( MODE_EDITFIELD ) ;
     Celled

     oEditStru : SetArray( aStru )

     // avoids changing of order by double clicking on column's headers

     oEditStru : lNoChangeOrd := .T.

     // 1st column (numbering) is freezed and locked

     oEditStru : nFreeze := 1
     oEditStru : lLockFreeze := .T.
     
     // Column of field's numbering
     
     Add column to TBrowse oEditStru                                      ;
         ShowBlock { | nNum | Iif( nNum == Nil, oEditStru : nAt, nNum ) } ;
         Title '#'                                                        ;
         Size 40                                                          ;
         Colors CLR_BLACK, CLR_HGRAY

     // Columns for datas
     
     Add column to TBrowse oEditStru                          ;
         Data array element DBS_NAME                          ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         Title 'Name'                                         ;
         Size 100
     Add column to TBrowse oEditStru                          ;
         Data array element DBS_TYPE                          ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         Title 'Type'                                         ;
         Size 50
     Add column to TBrowse oEditStru                          ;
         Data array element DBS_LEN                           ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         Title 'Len'                                          ;
         Size 80
     Add column to TBrowse oEditStru                          ;
         Data array element DBS_DEC                           ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         Title 'Dec'                                          ;
         Size 50
     Add column to TBrowse oEditStru                          ;
         Data array element DBS_OLDNAME                       ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         Title 'Old name'                                     ;
         Size 100
     Add column to TBrowse oEditStru                          ;
         Data array element DBS_OLDTYPE                       ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         Title 'Old type'                                     ;
         Size 50
     Add column to TBrowse oEditStru                          ;
         Data array element DBS_OLDLEN                        ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         Title 'Old len'                                      ;
         Size 80
     Add column to TBrowse oEditStru                          ;
         Data array element DBS_OLDDEC                        ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         Title 'Old dec'                                      ;
         Size 50

   End TBrowse   
   
   Define tab tbDescript ;
      At 40 + If(IsXPThemeActive(), 5, 0), 205 ;
      Width 340          ;
      Height 200
      
      Define page 'Field'

        // Field name

        @ 40, 15 Label lblName  ;
                 Value 'Name'   ;
                 Width 50       ;
                 Height 18      ;
                 Bold           ;
                 FontColor NAVY_COLOR
        @ 40, 40 TextBox txbName ;
                 Value ''        ;
                 Width 90        ;
                 MaxLength 10    ;
                 UpperCase

        // Field type

        @ 40, 80 Label lblType  ;
                 Value 'Type'   ;
                 Height 18      ;
                 Width 60       ;
                 Bold           ;
                 FontColor NAVY_COLOR
        @ 40, 100 ComboBox cmbType    ;
                  Width 40            ;
                  Height 110          ;
                  Items CORRECT_TYPES ;
                  Value 1             ;
                  ListWidth 40        ;
                  On change ChangeMaxLimit()

        // Field length

        @ 60, 15 Label lblLen   ;
                 Value 'Length' ;
                 Width 35       ;
                 Height 18      ;
                 Bold           ;
                 FontColor NAVY_COLOR
        @ 60, 40 Spinner spnLen       ;
                 Range 1, LEN_IS_CHAR ;
                 Value 1              ;
                 Width 50             ;
                 On Lostfocus ChangeMaxLimit()

        // Field decimal

        @ 60, 80 Label lblDec     ;
                 Value 'Decimals' ;
                 Height 18        ;
                 Bold             ;
                 FontColor NAVY_COLOR
        @ 60, 100 Spinner spnDec      ;
                  Range 0, LEN_IS_NUM ;
                  Value 0             ;
                  Width 50            ;
                  On LostFocus ChangeMaxLimit()

        // Comment of field

        @ 80, 5 Label lblComment ;
                Value 'Comment'   ;
                Height 18         ;
                Width 60          ;
                Bold              ;
                FontColor NAVY_COLOR
        @ 120, 15 EditBox edtComment ;
                  Value ''           ;
                  NoHScroll          ;
                  ReadOnly

        // Transformation rule of field contexts at the changing of value type

        @ 210, 5 Label lblRule               ;
                 Value 'Transformation rule' ;
                 Height 18                   ;
                 Width 130                   ;
                 Bold                        ;
                 FontColor NAVY_COLOR
        @ 230, 40 TextBox txbRule ;
                  Value ''

        // Buttons Apply/Discard changes in field description

        @ 240, 110 ButtonEx btnFldOk              ;
                   Width 30 Height 30             ;
                   Icon 'OK'                      ;
                   Action FiniEditField( SET_OK ) ;
                   Tooltip 'Apply changes [F2]'   ;
                   Flat                           ;
                   Backcolor WHITE
        @ 240, 145 ButtonEx btnFldCancel              ;
                   Width 30 Height 30                 ;
                   Icon 'CANCEL'                      ;
                   Action FiniEditField( SET_CANCEL ) ;
                   Tooltip 'Discard changes [Esc]'    ;
                   Flat                               ;
                   Backcolor WHITE

      End page
      
      Define page 'Database'

        // General description of database

        @ 30, 5 EditBox edtGeneral ;
                Value ''           ;
                NoHScroll          ;
                ReadOnly

        // Buttons Apply/Discard changes

        @ 240, 110 ButtonEx btnGeneralOk           ;
                   Width 30 Height 30              ;
                   Icon 'OK'                       ;
                   Action FiniEdtGeneral( SET_OK ) ;
                   Tooltip 'Apply changes [F2]'    ;
                   Flat                            ;
                   Backcolor WHITE
        @ 240, 145 ButtonEx btnGeneralCancel           ;
                   Width 30 Height 30                  ;
                   Icon 'CANCEL'                       ;
                   Action FiniEdtGeneral( SET_CANCEL ) ;
                   Tooltip 'Discard changes [Esc]'     ;
                   Flat                                ;
                   Backcolor WHITE
      End page
      
      Define page 'Collector'

        // Collector of fields

        @ 30, 5 Grid grdCollector                                              ;
                Headers { 'Name', 'Type', 'Len', 'Dec', 'Comment' }            ;
                Widths  { 80    , 45    , 40   , 40   , 102    }               ;
                DynamicBackColor { { | xVal, nItem | DynamicColors( nItem ) }, ;
                                   { | xVal, nItem | DynamicColors( nItem ) }, ;
                                   { | xVal, nItem | DynamicColors( nItem ) }, ;
                                   { | xVal, nItem | DynamicColors( nItem ) }, ;
                                   { | xVal, nItem | DynamicColors( nItem ) }  ;
                                 }
      End page
      
   End tab

   // Decoding of used colors in table

   @ 220, 5 Label lblLegend ;
            Value 'Legend:' ;
            Height 20       ;
            Bold            ;
            FontColor NAVY_COLOR  ;
            Autosize
   @ 220, 55 Label lblNew    ;
             Value 'New'     ;
             Height 18       ;
             Width 60        ;
             CenterAlign     ;
             Border          ;
             Backcolor { 227, 227, 234 }
   @ 220, 105 Label lblModified         ;
              Value 'Modified'          ;
              Height 18                 ;
              Width 60                  ;
              CenterAlign               ;
              Border                    ;
              Backcolor { 128, 255, 0 } ;
              FontColor BLACK
   @ 220, 155 Label lblDeleted            ;
              Value 'Deleted'             ;
              Height 18                   ;
              Width 60                    ;
              CenterAlign                 ;
              Border                      ;
              Backcolor { 255, 128, 128 } ;
              FontColor BLACK

  // System messages area

  @ 240, 5 EditBox edtMessages ;
           Value ''            ;
           Height 90           ;
           ReadOnly            ;
           Backcolor WHITE

   On key Alt+X of wModest Action { || Done(), ReleaseAllWindows() }

End Window

// If program starts with parameter when to load a structure. Certainly,
// if specified file exists, else it is considered, that a such file must be created.

If ( Valtype( cFile ) == 'C' )

   If File( cFile )
      GetStructure( cFile )
   Else
      WriteMsg( MSG_NEW_STRUCTURE )
   Endif

Else
   WriteMsg( MSG_NEW_STRUCTURE )
      
Endif

// Window title

SetWinTitle()

If IsXPThemeActive()
   nModestHeight := wModest.Height + 10
   wModest.Height := nModestHeight
Endif

wModest.MinWidth := 720
wModest.MinHeight := GetProperty( 'wModest', 'Height' )

// All controls for editing are unavailable in review mode

wModest.txbName.Enabled := .F.
wModest.cmbType.Enabled := .F.
wModest.spnLen.Enabled  := .F.
wModest.spnDec.Enabled  := .F.
wModest.txbRule.Enabled := .F. 

// Buttons Ok/Cancel

wModest.btnFldOk.Enabled     := .F.
wModest.btnFldCancel.Enabled := .F.

wModest.btnGeneralOk.Enabled     := .F.
wModest.btnGeneralCancel.Enabled := .F.

// Alignment in column
// 1st parameter - # column
// 2nd - level 1=Cell, 2=Header, 3=Footer
// 3rd - attribute DT_LEFT, DT_CENTER, DT_RIGHT and DT_VERT for header

oEditStru : SetAlign( 1, 1, DT_RIGHT )

wModest.oEditStru.SetFocus

Center window wModest
Activate window wModest

Return

****** End of Main ******


/******
*
*       Done() --> lSuccess
*
*       Program closing procedure
*
*/

Function Done
Memvar aStat

If ( aStat[ 'ChStruct'   ] .or. ;
     aStat[ 'ChDescript' ]      ;
   )
   
   If MsgYesNo( 'Data was changed. Would you like to save?', 'Attention', .F., , .F., .F. )
      SaveData()
   Endif
   
Endif

Return .T.

****** End of Done ******


/******
*
*       GetOptions()
*
*       Parameters initialization
*
*/

Static Procedure GetOptions
Memvar aStat
Local cName  := '', ;
      nType  := 1, ;
      nLen   := 0 , ;
      nDec   := 0 , ;
      cRDD   := '', ;
      cValue := ''

If File( MODEST_INI )

   Begin ini file MODEST_INI

     // Common parameters

     Get cRDD   Section 'Common' Entry 'RDD'        Default ''
     Get cValue Section 'Common' Entry 'Expression' Default ''

     // Field attributes, which are used at the creating
     // the new fields.

     Get cName Section 'Field' Entry 'Field_Name' Default ''
     Get nType Section 'Field' Entry 'Field_Type' Default 0
     Get nLen  Section 'Field' Entry 'Field_Len'  Default 0
     Get nDec  Section 'Field' Entry 'Field_Dec'  Default 0

   End Ini

   // Analyse of input datas.

   If !Empty( cRDD )
   
      // Support for 2 RDD only
      
      If ( ( cRDD == 'DBFCDX' ) .or. ( cRDD == 'DBFNTX' ) )
         aStat[ 'RDD' ] := cRDD
      Endif
      
   Endif
   
   If !Empty( cValue )
      aStat[ 'Expression' ] := cValue
   Endif
   
   If !Empty( cName )
      aStat[ 'DefName' ] := Left( AllTrim( cName ), 7 )
   Endif
   
   If ( ( nType > 0 ) .and. ( nType <= Len( CORRECT_TYPES ) ) )
      aStat[ 'DefType' ] := nType
   Endif

   If ( nLen >= 0 )   
      aStat[ 'DefLen' ] := Min( nLen, LEN_IS_CHAR )
   Endif
   
   If ( nDec >= 0 )
      aStat[ 'DefDec' ] := Min( nDec, LEN_IS_NUM )
   Endif

Endif

Return

****** End of GetOptions ******


/******
*
*       BackColors( nRow, nCol ) --> nColor
*
*       Colors of fields table
*       (color show of the changing)
*
*/

Static Function BackColors( nRow, nCol )
Memvar oEditStru
Local nColor := CLR_WHITE

If !Empty( oEditStru : aArray[ nRow, DBS_NAME ] )

   Do case
      Case  ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_INSERTED )
        // Added row
        nColor := RGB( 227, 227, 234 )
      
      Case  ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_DELETED )
        // Deleted row
        nColor := RGB( 255, 128, 128 )
      
      Otherwise
      
        // Row with changed values

        If ( ( nCol == 2 ) .or. ;          // Field name (current and previous)
             ( nCol == 6 )      ;
           )
          If !( Eval( oEditStru : aColumns[ 2 ] : bData ) ==  Eval( oEditStru : aColumns[ 6 ] : bData ) )
             nColor := RGB( 128, 255, 0 )
          Endif

        ElseIf ( ( nCol == 3 ) .or. ;      // Type (current and previous)
                 ( nCol == 7 )      ;
               )
          If !( Eval( oEditStru : aColumns[ 3 ] : bData ) ==  Eval( oEditStru : aColumns[ 7 ] : bData ) )
             nColor := RGB( 128, 255, 0 )
          Endif

        ElseIf ( ( nCol == 4 ) .or. ;      // Length (current and previous)
                 ( nCol == 8 )      ;
               )
          If !( Eval( oEditStru : aColumns[ 4 ] : bData ) ==  Eval( oEditStru : aColumns[ 8 ] : bData ) )
             nColor := RGB( 128, 255, 0 )
          Endif

        ElseIf ( ( nCol == 5 ) .or. ;      // Decimal
                 ( nCol == 9 )      ;
               )
          If !( Eval( oEditStru : aColumns[ 5 ] : bData ) ==  Eval( oEditStru : aColumns[ 9 ] : bData ) )
             nColor := RGB( 128, 255, 0 )
          Endif

        Endif
      
   Endcase
    
Endif

Return nColor

****** End of BackColors ******


/******
*
*       DynamicColors( nItem )
*
*       Colors in the collector table
*
*/

Static Function DynamicColors( nItem )
Memvar aCollector
Local nColor := RGB( 255, 255, 255 )

// We will show in color only records with attributes
// "New element" аnd "Deleted element"

If !Empty( aCollector )

   If ( nItem > 0 )
   
      If ( aCollector[ nItem, DBS_FLAG ] == FLAG_INSERTED )
         // Added row
         nColor := RGB( 227, 227, 234 )

      ElseIf ( aCollector[ nItem, DBS_FLAG ] == FLAG_DELETED )
         // Deleted row
         nColor := RGB( 255, 128, 128 )

      Endif

   Endif

Endif

Return nColor

****** End of DynamicColors ******


/******
*
*       InitDefault() --> aStru
*
*       "Empty" structure
*
*/

Static Function InitDefault
Memvar aStat
Local aStru := Array( DBS_NEW_ALEN )

aStat[ 'FileName'   ] := ''           // Working file
aStat[ 'ChStruct'   ] := .F.          // Changing is absent
aStat[ 'ChDescript' ] := .F.
aStat[ 'Counter'    ] := 1            // Counter is reestablished

Return { aStru }

****** End of InitDefault ******


/******
*
*       AboutMe()
*
*       About program
*
*/

Static Procedure AboutMe

Load window AboutMe as wAboutMe

wAboutMe.lblAppName.Value    := APPNAME
wAboutMe.lblAppVersion.Value := APPVERSION
wAboutMe.lblCopyright.Value  := ( 'Author:' + COPYRIGHT )
wAboutMe.lblComponents.Value := ( HB_Compiler()    + CRLF + ;
                                  Version()        + CRLF + ;
                                  MiniGuiVersion()          ;
                                )

On key Escape of wAboutMe Action wAboutMe.Release()
On key Alt+X of wAboutMe Action { || Done(), ReleaseAllWindows() }  // Hotkey for urgent program closing

Center window wAboutMe
Activate window wAboutMe

Return

****** End of AboutMe ******


/******
*
*       ReSize()
*
*       Arranging of controls size to main window size
*       It will change the initial arrangement, which is doing in the main procedure
*
*/
 
Static Procedure ReSize
Memvar oEditStru
Local nHeight := ( wModest.Height - 215 - IF(IsXPThemeActive(), 15, 0) )

// Tab control

wModest.tbDescript.Col    := ( wModest.Width - wModest.tbDescript.Width - 15 )
wModest.tbDescript.Height := nHeight

// Field name

wModest.txbName.Row := ( wModest.lblName.Row - 2 )
wModest.txbName.Col := ( wModest.lblName.Col + wModest.lblName.Width + 5 )

// Field type

wModest.lblType.Row   := wModest.lblName.Row
wModest.lblType.Col   := ( wModest.txbName.Col + wModest.txbName.Width + 50 )

wModest.cmbType.Row := ( wModest.lblType.Row - 2 )
wModest.cmbType.Col := ( wModest.lblType.Col + wModest.lblType.Width + 15 )

// Field length

wModest.lblLen.Row   := ( wModest.lblName.Row + 44 )
wModest.lblLen.Col   := wModest.lblName.Col
wModest.lblLen.Width := wModest.lblName.Width

wModest.spnLen.Row := ( wModest.lblLen.Row - 4 )
wModest.spnLen.Col := ( wModest.txbName.Col + ( wModest.txbName.Width - wModest.spnLen.Width + 5 ) )

// Decimal

wModest.lblDec.Row   := wModest.lblLen.Row
wModest.lblDec.Col   := wModest.lblType.Col
wModest.lblDec.Width := wModest.lblType.Width

wModest.spnDec.Row := wModest.spnLen.Row
wModest.spnDec.Col := ( wModest.cmbType.Col - 10 )

// Description of field

wModest.lblComment.Row :=  ( wModest.lblLen.Row + 40 )
wModest.lblComment.Col := wModest.lblName.Col

wModest.edtComment.Row := ( wModest.lblComment.Row + 20 )
wModest.edtComment.Col := wModest.lblComment.Col
wModest.edtComment.Height := ( nHeight - wModest.lblComment.Row - 145 )
wModest.edtComment.Width  := ( wModest.tbDescript.Width - 30 )

// Transformation rule at the type changing

wModest.lblRule.Row :=  ( wModest.edtComment.Row + wModest.edtComment.Height + 20 )
wModest.lblRule.Col := wModest.lblName.Col

wModest.txbRule.Row   := ( wModest.lblRule.Row + 20 )
wModest.txbRule.Col   := wModest.lblRule.Col
wModest.txbRule.Width := wModest.edtComment.Width

// Ok/Cancel

wModest.btnFldOk.Row := ( wModest.txbRule.Row + wModest.txbRule.Height + 15 )
wModest.btnFldOk.Col := ( wModest.tbDescript.Width - 80 )

wModest.btnFldCancel.Row := wModest.btnFldOk.Row
wModest.btnFldCancel.Col := ( wModest.btnFldOk.Col + wModest.btnFldOk.Width + 5 )

// System messages

wModest.edtMessages.Row   := ( wModest.oEditStru.Row + nHeight + 10 )
wModest.edtMessages.Col   := wModest.oEditStru.Col
wModest.edtMessages.Width := ( wModest.Width - 20 )

// Field table

wModest.oEditStru.Height := ( nHeight - 33 )
wModest.oEditStru.Width  := ( wModest.Width - wModest.tbDescript.Width - 25 )

oEditStru : Refresh()

// Decoding of table colors

wModest.lblLegend.Row := ( wModest.oEditStru.Row + wModest.oEditStru.Height + 15 )
wModest.lblLegend.Col := wModest.oEditStru.Col

wModest.lblNew.Row := ( wModest.lblLegend.Row - 2 )
wModest.lblNew.Col := ( wModest.lblLegend.Col + wModest.lblLegend.Width + 5 )

wModest.lblModified.Row := wModest.lblNew.Row
wModest.lblModified.Col := (wModest.lblNew.Col + wModest.lblNew.Width + 5 )

wModest.lblDeleted.Row := wModest.lblNew.Row
wModest.lblDeleted.Col := ( wModest.lblModified.Col + wModest.lblModified.Width + 5 )

// Description of database

wModest.edtGeneral.Width  := ( wModest.tbDescript.Width - 12 )
wModest.edtGeneral.Height := ( wModest.tbDescript.Height - 85 )

// Description editing (Ok/Cancel)

wModest.btnGeneralOk.Row := wModest.btnFldOk.Row 
wModest.btnGeneralOk.Col := wModest.btnFldOk.Col

wModest.btnGeneralCancel.Row := wModest.btnGeneralOk.Row
wModest.btnGeneralCancel.Col := wModest.btnFldCancel.Col

// Collector

wModest.grdCollector.Width  := ( wModest.tbDescript.Width - 12 )
wModest.grdCollector.Height := ( wModest.tbDescript.Height - 40 )

// Refresh the all aboved movings

InvalidateRect( Application.Handle, 0 )

Return

****** End of ReSize ******


/******
*
*       SetWinTitle()
*
*       Show info about working file at the window title
*
*/

Procedure SetWinTitle
Memvar aStat

If !Empty( aStat[ 'FileName' ] )
   wModest.Title := APPNAME + ' - ' + aStat[ 'FileName' ]
Else
   wModest.Title := APPNAME + ' - New file'
Endif

Return

****** End of SetWinTitle ******


/******
*
*       SetIconSave( nIcon )
*
*       Show the icon of saving necessity in status
*
*/

Procedure SetIconSave( nIcon )
wModest.StatusBar.Icon( 3 ) := IIf( ( nIcon == 1 ), 'MUST_SAVE', '' )
Return

****** End of SetIconSave ******


/******
*
*       SetRDDName()
*
*       Show the current database RDD in status
*
*/

Procedure SetRDDName
Memvar aStat
wModest.StatusBar.Item( 4 ) := aStat[ 'RDD' ]
Return

****** End of SetRDDName ******


/******
*
*       ShowValues()
*
*       Filling and show the current values in the editing fields
*
*/

Static Procedure ShowValues
Memvar oEditStru
Local nRow := oEditStru : nAt, ;
      nPos

If !Empty( oEditStru : aArray[ nRow, DBS_NAME ] )
   wModest.txbName.Value := oEditStru : aArray[ nRow, DBS_NAME ]
   
   If !Empty( nPos := AScan( CORRECT_TYPES, oEditStru : aArray[ nRow, DBS_TYPE ] ) )
      wModest.cmbType.Value := nPos
   Else
      wModest.cmbType.Value := TYPE_IS_CHAR
   Endif
   
   wModest.spnLen.Value     := oEditStru : aArray[ nRow, DBS_LEN     ]
   wModest.spnDec.Value     := oEditStru : aArray[ nRow, DBS_DEC     ]
   wModest.edtComment.Value := oEditStru : aArray[ nRow, DBS_COMMENT ]
   wModest.txbRule.Value    := oEditStru : aArray[ nRow, DBS_RULE    ]

   wModest.StatusBar.Item( 2 ) := ( LTrim( Str( nRow ) ) + '/' + LTrim( Str( Len( oEditStru : aArray ) ) ) )

Else

   wModest.StatusBar.Item( 2 ) := 'Empty'
   
Endif

Return

****** End of ShowValues *****


/******
*
*       WriteMsg( cMessage )
*
*       Filling the messages area
*
*/

Procedure WriteMsg( cMessage )
Local cText := GetProperty( 'wModest', 'edtMessages', 'Value' )

cText += ( cMessage + CRLF )
SetProperty( 'wModest', 'edtMessages', 'Value', cText )

// Showing of last row

SendMessage( GetControlHandle( 'edtMessages', 'wModest' ), WM_VSCROLL, SB_BOTTOM, 0 )

Return

****** End of WriteMsg ******


/******
*
*       ClearCollector()
*
*       Clear of the collector
*/

Static Procedure ClearCollector
Memvar aCollector

If MsgYesNo( 'Clear Collector?', 'Confirm', .T., , .F., .F. )
   aCollector := {}
   FillCollector() 
Endif

Return

****** End of ClearCollector ******


/******
*
*       ClearMsg()
*
*       Clear of the messages area
*/

Static Procedure ClearMsg

If MsgYesNo( 'Clear messages area?', 'Confirm', .T., , .F., .F. )
   SetProperty( 'wModest', 'edtMessages', 'Value', '' )
   SendMessage( GetControlHandle( 'edtMessages', 'wModest' ), WM_VSCROLL, SB_TOP, 0 )
Endif

Return

****** End of ClearMsg ******


/******
*
*       StructASize( aStructure ) --> aStructure
*
*       Expanded array of structure description
*
*/

Static Function StructASize( aStructure )

AEval( aStructure, { | elem | ASize( elem, DBS_NEW_ALEN )            , ;
                              elem[ DBS_COMMENT ] := ''              , ;
                              elem[ DBS_FLAG    ] := FLAG_DEFAULT    , ;
                              elem[ DBS_OLDNAME ] := elem[ DBS_NAME ], ;
                              elem[ DBS_OLDTYPE ] := elem[ DBS_TYPE ], ;
                              elem[ DBS_OLDLEN  ] := elem[ DBS_LEN  ], ;
                              elem[ DBS_OLDDEC  ] := elem[ DBS_DEC  ], ;
                              elem[ DBS_RULE    ] := ''                ;
                    } )

Return aStructure

****** End of StructASize ******


/******
*
*       InvertEnable( cName )
*
*       Inverting of the attribute Enabled for one element
*
*/

Static Procedure InvertEnable( cName )
Local lEnable := GetProperty( 'wModest', cName, 'Enabled' )
SetProperty( 'wModest', cName, 'Enabled', !lEnable )
Return

****** End of InvertEnable ******


/******
*
*       InvertReadOnly( cName )
*
*       Inverting of the attribute ReadOnly for one element
*
*/

Static Procedure InvertReadOnly( cName )
Local lReadOnly := GetProperty( 'wModest', cName, 'ReadOnly' )
SetProperty( 'wModest', cName, 'ReadOnly', !lReadOnly )
Return

****** End of InvertReadOnly ******


/******
*
*       InvertForEdit( lEnabled )
*
*       Inverting of the attributes (menu, toolbar)
*       at the editing
*
*/

Static Procedure InvertForEdit( lEnabled )

// Menu

// Access to menu items are changed here, but is not in procedure InvertEnable(),
// because the function GetProperty() no determine the current value of property Enabled
// for menu item
 
// File

SetProperty( 'wModest', 'pdNew'  , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdOpen' , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdSave' , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdPrint', 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdNew'  , 'Enabled', lEnabled )

// Edit

SetProperty( 'wModest', 'pdCopy'       , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdCut'        , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdPasteAfter' , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdPasteBefore', 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdDescription', 'Enabled', lEnabled )

// Field

SetProperty( 'wModest', 'pdAdd'         , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdInsertAfter' , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdInsertBefore', 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdEdit'        , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdDelete'      , 'Enabled', lEnabled )
SetProperty( 'wModest', 'pdExport'      , 'Enabled', lEnabled )

// Toolbar

InvertEnable( 'btnNewFile' )
InvertEnable( 'btnOpenFile' )
InvertEnable( 'btnSave' )
InvertEnable( 'btnPrint' )
InvertEnable( 'btnAddField' )
InvertEnable( 'btnInsField' )
InvertEnable( 'btnEditField' )
InvertEnable( 'btnDeleteField' )
InvertEnable( 'btnCopy' )
InvertEnable( 'btnCut' )
InvertEnable( 'btnPaste' )
InvertEnable( 'btnEditGeneral' )

Return

****** End of InvertForEdit ******


/*****
*
*       InvertForGeneral()
*
*       Inverting of elements availability at the editing
*       of general database description
*
*/

Static Procedure InvertForGeneral
Memvar oEditStru

// Fields list

InvertEnable( 'oEditStru' )

// Editing field and buttons Ok/Cancel

InvertReadOnly( 'edtGeneral' )
InvertEnable( 'btnGeneralOk' )
InvertEnable( 'btnGeneralCancel' )

Return

****** End of InvertForGeneral ******


/******
*
*       InvertForFields()
*
*       Changing of elements availability at the editing
*       of field characteristics
*
*/

Static Procedure InvertForFields

// Field list

InvertEnable( 'oEditStru' )

// Editing is available

InvertEnable( 'txbName' )
InvertEnable( 'cmbType' )
InvertEnable( 'spnLen' )
InvertEnable( 'spnDec' )
InvertReadOnly( 'edtComment' )

InvertEnable( 'btnFldOk' )
InvertEnable( 'btnFldCancel' )

Return

****** End of InvertForFields ******
 

/******
*
*       GetStructure( cFile )
*
*       Loading of existing structure
*
*/

Static Procedure GetStructure( cFile )
Memvar aStat, oEditStru
Local aStru := {}, ;
      nPos       , ;
      cName      , ;
      cRDD

Try

   // Select RDD

   If ( ( nPos := RAt( '.', cFile ) ) > 0 )
      
      If !Empty( cName := Left( cFile, nPos ) )
         
         If File( cName + 'FPT' )
            cRDD := 'DBFCDX'
         Else
            cRDD := aStat[ 'RDD' ]
         Endif
         
      Endif
      
   Endif 
   
   // Reading the database structure, array is transformed to working format.
   // The database is closed after reading.

   DbUseArea( , cRDD, cFile,, .T. )
   aStru := DbStruct()
   aStru := StructASize( aStru )
   DbCloseAll()
   
   // Filling of comments.
   
   If ( nPos > 0 )
      cName := ( Left( cFile, nPos ) + 'XML' )
      If File( cName )
         aStru := LoadXML( cName, aStru )
      Endif
   Endif
   
   WriteMsg( cFile + MSG_STRUCTURE_LOADED )

   aStat[ 'FileName'   ] := cFile
   aStat[ 'RDD'        ] := cRDD
   aStat[ 'ChStruct'   ] := .F.          // Changing is absent
   aStat[ 'ChDescript' ] := .F.
   aStat[ 'Counter'    ] := 1            // Counter is reestablished

   SetWinTitle()
   SetIconSave( 0 )
   SetRDDName()
      
Catch
   WriteMsg( MSG_ERROR_LOAD + cFile )

End

// If array is empty when to do the initialization

If Empty( aStru )
   aStru := InitDefault()
   SetWinTitle()
Endif

oEditStru : SetArray( aStru )
oEditStru : Display()

oEditStru : goTop()
oEditStru : Refresh()

Return

****** End of GetStructure ******


/******
*
*       LoadXML( cFile, aStru ) --> aStru
*
*       Filling of comments of fields
*
*/

Static Function LoadXML( cFile, aStru )
Local oXMLDoc  := TXMLDocument() : New(), ;
      oXMLNode                          , ;
      cName                             , ;
      cField                            , ;
      nPos

oXMLDoc : Read( Memoread( cFile ) )

oXMLNode := oXMLDoc : FindFirst()

// Usually for positioning to the needed XML node it is used the
// function FindFirst() with node name as parameter. But
// for me this function finds only root node.
// Therefore desctiption analyse we will do by exhaustive search of the all nodes.
 
Do while ( Valtype( oXMLNode ) == 'O' )

   cName := oXMLNode : cName                    // Node name

   Do case
      Case ( cName == XML_TAG_DESCRIPTION )     // Description of database
        wModest.edtGeneral.Value := oXMLNode : cData

      Case ( cName == XML_TAG_FIELD )           // Description of field row
      
        // Filling array with only existing description

        If !Empty( oXMLNode : cData )
        
           cField := Upper( oXMLNode : GetAttribute( XML_ATTR_NAME ) )
           
           If !Empty( nPos := AScan( aStru, { | elem | Upper( elem[ DBS_NAME ] ) == cField } ) )
              aStru[ nPos, DBS_COMMENT ] := AllTrim( oXMLNode : cData ) 
           Endif 
        Endif
         
   Endcase

   // Go to the next node
   
   oXmlNode := oXMLDoc : FindNext()

Enddo

Return aStru

****** End of LoadXML ******


/******
*
*       NewFile()
*
*       Create a new structure
*
*/

Static procedure NewFile
Memvar aStat, oEditStru
Local aStru

If ( aStat[ 'ChStruct'   ] .or. ;
     aStat[ 'ChDescript' ]      ;
   )
   
   If MsgYesNo( 'Data changed. Save?', 'Attention', .T., , .F., .F. )
      If !SaveData()
         Return
      Endif
   Endif
   
Endif

aStru := InitDefault()
oEditStru : SetArray( aStru )

oEditStru : Display()

oEditStru : goTop()
oEditStru : Refresh()

// Change the datas which ate show in editing fields.
        
wModest.txbName.Value    := ''
wModest.cmbType.Value    := TYPE_IS_CHAR
wModest.spnLen.Value     := 1
wModest.spnDec.Value     := 0
wModest.edtComment.Value := ''
wModest.txbRule.Value    := ''

wModest.edtGeneral.Value := ''

SetWinTitle()
SetIconSave( 0 )

WriteMsg( MSG_NEW_STRUCTURE )

Return

****** End of NewFile ******


/******
*
*       LoadFile()
*
*       Loading of database structure
*
*/

Static Procedure LoadFile
Memvar aStat
Local cFile

If ( aStat[ 'ChStruct'   ] .or. ;
     aStat[ 'ChDescript' ]      ;
   )
   
   If MsgYesNo( 'Data changed. Save?', 'Attention', .T., , .F., .F. )
      If !SaveData()
         Return
      Endif
   Endif
   
Endif

cFile := GetFile( FILEDLG_FILTER, 'Select dBASE file', , .F., .T. )

If !Empty( cFile )
   GetStructure( cFile )
Endif

Return

****** End of LoadFile ******


/******
*
*       EditGeneralDesc()
*
*       Editing of general database description
*
*/

Static Procedure EditGeneralDesc
Memvar aStat

// Available only controls which are needed for editing

InvertForEdit( .F. )         // Locking of menu, toolbar
InvertForGeneral()           // Tab controls

// Save the current value (for possible refusal from changing)

aStat[ 'Cargo' ] := wModest.edtGeneral.Value

// Show needed tab and buttons

wModest.tbDescript.Value := 2

wModest.StatusBar.Item( 1 ) := ( 'Edit general base description. ' + SHORTKEY_TOOLTIP )

// Assignment of hotkeys

On key F2 of wModest Action FiniEdtGeneral( SET_OK )
On key Escape of wModest Action FiniEdtGeneral( SET_CANCEL )

wModest.edtGeneral.SetFocus 

Return

****** End of EditGeneralDesc ******


/******
*
*       FiniEdtGeneral( nMode )
*
*       Finish of editing of general database description
*
*/

Static Procedure FiniEdtGeneral( nMode )
Memvar aStat, oEditStru

If ( nMode == SET_CANCEL )

   // Restore the previous value
   wModest.edtGeneral.Value := aStat[ 'Cargo' ]

Else
   
   // Check for changing
   aStat[ 'ChDescript' ] := !( wModest.edtGeneral.Value == aStat[ 'Cargo' ] )
   
Endif

aStat[ 'Cargo' ] := ''

// Open the locked controls

InvertForEdit( .T. )        // Menu, toolbar
InvertForGeneral()          // Tab controls

If aStat[ 'ChDescript' ]
   SetIconSave( 1 )
Endif

wModest.StatusBar.Item( 1 ) := ''

Release key F2 of wModest
Release key Escape of wModest

wModest.oEditStru.SetFocus
   
Return

****** End of FiniEdtGeneral ******


/******
*
*       EditField( nMode )
*
*       Field's editing
*
*/

Static Procedure EditField( nMode )
Memvar aStat, oEditStru
Local nRow, ;
      nPos

// Перечитуємо характеристики. Пов’язане з тим, що при перегортанні
// рядків по PageDown вказівник може стояти на останній позиціїї, а
// факт зміни внутрішніх змінних в TsBrowse не реєструється в опції
// On change
 
ShowValues()
nRow := oEditStru : nAt

// Спочатку перевіряємо можливість виконання операцій. Якщо назва поля порожня,
// вважаємо, що структура не заповнена. В цьому випадку дозволяється лише
// додавання нового поля.

If ( ( nMode == MODE_INSFIELD  ) .or. ;
     ( nMode == MODE_EDITFIELD )      ;
   )
   
   If Empty( oEditStru : aArray[ nRow, DBS_NAME ] )
   
      // Якщо пробують виконати вставку або редагування запису в порожній структурі,
      // перемикаємо на режим додавання.
      
      nMode := MODE_NEWFIELD
      
   Endif
   
Endif

If ( nMode == MODE_EDITFIELD )      // Редагування. Значення існують.

   wModest.txbName.Value := oEditStru : aArray[ nRow, DBS_NAME ]

   If !Empty( nPos := AScan( CORRECT_TYPES, oEditStru : aArray[ nRow, DBS_TYPE ] ) )
      wModest.cmbType.Value := nPos
   Else
      wModest.cmbType.Value := aStat[ 'DefType' ]
   Endif
   
   wModest.spnLen.Value     := oEditStru : aArray[ nRow, DBS_LEN     ]
   wModest.spnDec.Value     := oEditStru : aArray[ nRow, DBS_DEC     ]
   wModest.edtComment.Value := oEditStru : aArray[ nRow, DBS_COMMENT ]
   wModest.txbRule.Value    := oEditStru : aArray[ nRow, DBS_RULE    ]

   // Правило перетворення
   
   aStat[ 'Cargo' ] := Upper( AllTrim( wModest.txbRule.Value ) )
      
Else
   wModest.txbName.Value    := ( aStat[ 'DefName' ] + StrZero( aStat[ 'Counter' ], 3 ) )
   wModest.cmbType.Value    := aStat[ 'DefType' ]
   wModest.spnLen.Value     := aStat[ 'DefLen'  ]
   wModest.spnDec.Value     := aStat[ 'DefDec'  ]
   wModest.edtComment.Value := ''
   wModest.txbRule.Value    := ''

Endif

// Залишаємо доступними тільки елементи, необхідні для редагування

InvertForEdit( .F. )      // Меню, панель інструментів
InvertForFields()         // Елементи вкладок

// Заповнюювати поле правила перетворення даних має сенс тільки в режимі
// редагування (дані мають існувати)
// TODO: додаткого перевіряти ознаку рядка в списку і ігнорувати
// створені записи

If ( nMode == MODE_EDITFIELD )
   InvertEnable( 'txbRule' )
Endif
 
wModest.tbDescript.Value := 1           // Відображаємо потрібну закладку

Do case
   Case ( nMode == MODE_NEWFIELD )
     aStat[ 'CurrMode' ] := MODE_NEWFIELD
     wModest.StatusBar.Item( 1 ) := ( 'Create new field. ' + SHORTKEY_TOOLTIP )
     
   Case ( nMode == MODE_INSFIELD )
     aStat[ 'CurrMode' ] := MODE_INSFIELD
     wModest.StatusBar.Item( 1 ) := ( 'Insert ' + Iif( ( nShift < 0 ), '(before)', '(after)' ) + ;
                                      ' new field. ' + SHORTKEY_TOOLTIP )
     
   Case ( nMode == MODE_EDITFIELD )
     aStat[ 'CurrMode' ] := MODE_EDITFIELD
     wModest.StatusBar.Item( 1 ) := ( 'Edit current field. ' + SHORTKEY_TOOLTIP )
     
Endcase

// Призначення клавіш для швидкого завершення редагування

On key F2 of wModest Action FiniEditField( SET_OK )
On key Escape of wModest Action FiniEditField( SET_CANCEL )

wModest.txbName.SetFocus 

Return

****** End of EditField ******


/******
*
*       ChangeMaxLimit()
*
*       Changing of max field size limit in dependence from type
*
*/

Static Procedure ChangeMaxLimit

// Коригуємо співвідношення розмірності поля та дробноъ частини.
// Для логічних полів не має сенсу встановлювати довжину поля понад 1,
// полів приміток - 10. І, звичайно, такі поля не повинні мати дробної частини.
// А дата має розмірність 8.

Do case
   Case ( wModest.cmbType.Value == TYPE_IS_CHAR )
      wModest.spnLen.RangeMax := LEN_IS_CHAR
      wModest.spnLen.Value    := Min( LEN_IS_CHAR, wModest.spnLen.Value )
     
      // Для символьних полів дозволяється вказувати дробну частину.
      // В Clipper за допомогою цього можна було обходити обмеження
      // довжини поля.
     
      wModest.spnDec.RangeMax := LEN_IS_NUM
      wModest.spnDec.Value    := Min( LEN_IS_CHAR, wModest.spnDec.Value )
     
   Case ( wModest.cmbType.Value == TYPE_IS_NUM )
      wModest.spnLen.RangeMax := LEN_IS_NUM
      wModest.spnLen.Value    := Min( LEN_IS_NUM, wModest.spnLen.Value )

      wModest.spnDec.RangeMax := LEN_IS_NUM
      wModest.spnDec.Value    := Min( LEN_IS_CHAR, wModest.spnDec.Value )

   Case ( wModest.cmbType.Value == TYPE_IS_DATE )
      wModest.spnLen.RangeMax := LEN_IS_DATE
      wModest.spnLen.Value    := LEN_IS_DATE

      wModest.spnDec.RangeMax := 0
      wModest.spnDec.Value    := 0

   Case ( wModest.cmbType.Value == TYPE_IS_LOGIC )
      wModest.spnLen.RangeMax := LEN_IS_LOGIC
      wModest.spnLen.Value    := LEN_IS_LOGIC

      wModest.spnDec.RangeMax := 0
      wModest.spnDec.Value    := 0
   
   Case ( wModest.cmbType.Value == TYPE_IS_MEMO )
      wModest.spnLen.RangeMax := LEN_IS_MEMO
      wModest.spnLen.Value    := LEN_IS_MEMO
      wModest.spnDec.RangeMax := 0
      wModest.spnDec.Value    := 0

Endcase

Return

****** End of ChangeMaxLimit ******


/******
*
*       FiniEditField( nMode )
*
*       Finish the field editing
*
*/

Static Procedure FiniEditField( nMode )
Memvar aStat, oEditStru
Local nRow := oEditStru : nAt, ;
      aItem                  , ;
      nType := wModest.cmbType.Value

If ( nMode == SET_OK )

   // Перевіримо коректність внесених даних
   
   If !CheckData()
      Return
   Endif
   
   // Зберігаємо зміни

   If ( ( aStat[ 'CurrMode' ] == MODE_NEWFIELD ) .or. ;
        ( aStat[ 'CurrMode' ] == MODE_INSFIELD )      ;
      )
      
      aItem := Array( DBS_NEW_ALEN )
      
      aItem[ DBS_FLAG    ] := FLAG_INSERTED
      aItem[ DBS_NAME    ] := wModest.txbName.Value
      aItem[ DBS_TYPE    ] := CORRECT_TYPES[ nType ]
      aItem[ DBS_LEN     ] := wModest.spnLen.Value
      aItem[ DBS_DEC     ] := wModest.spnDec.Value
      aItem[ DBS_OLDNAME ] := ''
      aItem[ DBS_OLDTYPE ] := ''
      aItem[ DBS_OLDLEN  ] := 0
      aItem[ DBS_OLDDEC  ] := 0
      aItem[ DBS_COMMENT ] := wModest.edtComment.Value
      aItem[ DBS_RULE    ] := wModest.txbRule.Value

      aStat[ 'Counter'    ] ++
      aStat[ 'ChStruct'   ] := .T.
      aStat[ 'ChDescript' ] := .T.
                  
  Endif
   
  Do case
     Case ( aStat[ 'CurrMode' ] == MODE_NEWFIELD )
      
       If Empty( oEditStru : aArray[ 1, DBS_NAME ] )
          oEditStru : aArray[ 1, DBS_FLAG    ] := FLAG_INSERTED
          oEditStru : aArray[ 1, DBS_NAME    ] := wModest.txbName.Value
          oEditStru : aArray[ 1, DBS_TYPE    ] := CORRECT_TYPES[ nType ]
          oEditStru : aArray[ 1, DBS_LEN     ] := wModest.spnLen.Value
          oEditStru : aArray[ 1, DBS_DEC     ] := wModest.spnDec.Value
          oEditStru : aArray[ 1, DBS_OLDNAME ] := ''
          oEditStru : aArray[ 1, DBS_OLDTYPE ] := ''
          oEditStru : aArray[ 1, DBS_OLDLEN  ] := 0
          oEditStru : aArray[ 1, DBS_OLDDEC  ] := 0
          oEditStru : aArray[ 1, DBS_COMMENT ] := wModest.edtComment.Value
          oEditStru : aArray[ 1, DBS_RULE    ] := wModest.txbRule.Value
           
       Else
         nRow := ( oEditStru : nLen + 1 )
         oEditStru : Insert( aItem, nRow )
         oEditStru : GoPos( nRow, 2 )
         oEditStru : Display()
       Endif

     Case ( aStat[ 'CurrMode' ] == MODE_INSFIELD )
       
       // Рядок вставляється після поточного (nShift == 1) або попереду (nShift == 0)

       oEditStru : Insert( aItem, nRow + nShift )
       oEditStru : Display()
     
     Case ( aStat[ 'CurrMode' ] == MODE_EDITFIELD )

       // Що змінилося
       
       If ( !( oEditStru : aArray[ nRow, DBS_NAME ] == wModest.txbName.Value  ) .or. ;
            !( oEditStru : aArray[ nRow, DBS_TYPE ] == CORRECT_TYPES[ nType ] ) .or. ;
            !( oEditStru : aArray[ nRow, DBS_LEN  ] == wModest.spnLen.Value   ) .or. ;
            !( oEditStru : aArray[ nRow, DBS_DEC  ] == wModest.spnDec.Value   )      ;
          )
          aStat[ 'ChStruct' ] := .T.
       Endif

       If !( oEditStru : aArray[ nRow, DBS_COMMENT ] == wModest.edtComment.Value )
          aStat[ 'ChDescript' ] := .T.
       Endif            

       If !( Upper( AllTrim( wModest.txbRule.Value ) ) == aStat[ 'Cargo' ] )
          aStat[ 'ChStruct' ] := .T.
       Endif

       oEditStru : aArray[ nRow, DBS_NAME    ] := wModest.txbName.Value
       oEditStru : aArray[ nRow, DBS_TYPE    ] := CORRECT_TYPES[ nType ]
       oEditStru : aArray[ nRow, DBS_LEN     ] := wModest.spnLen.Value
       oEditStru : aArray[ nRow, DBS_DEC     ] := wModest.spnDec.Value
       oEditStru : aArray[ nRow, DBS_COMMENT ] := wModest.edtComment.Value
       oEditStru : aArray[ nRow, DBS_RULE    ] := wModest.txbRule.Value
     
  Endcase

  oEditStru : GoPos( ( nRow + nShift ), 2 )
   
Endif

// Відкриваємо доступ до елементів

InvertForEdit( .T. )        // Меню, панель інструментів
InvertForFields()           // Елементи вкладок

// Правило перетворення заповнюється тільки в режимі
// редагування існуючого поля

If ( aStat[ 'CurrMode' ] == MODE_EDITFIELD )
   InvertEnable( 'txbRule' )
Endif

If ( aStat[ 'ChStruct'   ] .or. ;
     aStat[ 'ChDescript' ]      ;
   )
   SetIconSave( 1 )
Endif

wModest.StatusBar.Item( 1 ) := ''

aStat[ 'CurrMode' ] := MODE_DEFAULT
aStat[ 'Cargo'    ] := ''

Release key F2 of wModest
Release key Escape of wModest

oEditStru : Refresh()

ShowValues()

Return

****** End of FiniEditField ******


/******
*
*       DelField()
*
*       To remove the row
*
*/

Static Procedure DelField
Memvar aStat, oEditStru
Local nRow := oEditStru : nAt

If Empty( oEditStru : aArray[ nRow, DBS_NAME ] )
   Return
Endif

// Створені рядки видаляємо з таблиці, а ті, що вже існували,
// лише помічаємо як видалені. Це дає можливість зняти відмітку

If ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_INSERTED )

     If ( oEditStru : nLen == 1 )
        
        // Якщо таблиця містить тільки один рядок, просто
        // видаляємо існуючі значення

        oEditStru : aArray[ 1, DBS_FLAG    ] := FLAG_DEFAULT
        oEditStru : aArray[ 1, DBS_NAME    ] := Nil
        oEditStru : aArray[ 1, DBS_TYPE    ] := Nil
        oEditStru : aArray[ 1, DBS_LEN     ] := Nil
        oEditStru : aArray[ 1, DBS_DEC     ] := Nil
        oEditStru : aArray[ 1, DBS_OLDNAME ] := Nil
        oEditStru : aArray[ 1, DBS_OLDTYPE ] := Nil
        oEditStru : aArray[ 1, DBS_OLDLEN  ] := Nil
        oEditStru : aArray[ 1, DBS_OLDDEC  ] := Nil
        oEditStru : aArray[ 1, DBS_COMMENT ] := Nil
        oEditStru : aArray[ 1, DBS_RULE    ] := Nil
        
     Else
     
       // Для видалення тимчасово вмикаємо штатну можливість
        
       oEditStru : SetDeleteMode( .T. )
       oEditStru : DeleteRow()
       oEditStru : SetDeleteMode( .F. )
     
     Endif

Else

   If ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_DELETED )
      oEditStru : aArray[ nRow, DBS_FLAG ] := FLAG_DEFAULT
   Else
      oEditStru : aArray[ nRow, DBS_FLAG ] := FLAG_DELETED
   Endif
   
Endif

oEditStru : Refresh()

// Відображаємо зміну

aStat[ 'ChStruct' ] := .T.
SetIconSave( 1 )

Return

****** End of DelField ******


/******
*
*       CheckData() --> lSuccess
*
*       Checkup for valid field attributes
*/

Static Function CheckData
Memvar aStat, oEditStru
Local lSuccess   := .F.             , ;
      Cycle                         , ;
      nLen       := oEditStru : nLen, ;
      nRow       := oEditStru : nAt , ;
      cFieldName                    , ;
      cValue                        , ;
      nType                         , ;
      xRule

Begin Sequence

   // Перевірка імені поля. Ім’я має починатися з символу, складатися
   // виключно з латинських літер "A"-"Z", чисел 0-9 і, можливо, символа
   // підкреслювання "_" 
   
   If !CheckNameField( AllTrim( wModest.txbName.Value ) )
      Break
   Endif
   
   // Перевіримо дублювання полів
   
   For Cycle := 1 to nLen

       cFieldName := Iif( Empty( oEditStru : aArray[ Cycle, DBS_NAME ] )           , ;
                          ''                                                       , ;
                          AllTrim( Upper( oEditStru : aArray[ Cycle, DBS_NAME ] ) )  ;
                        )
   
       If ( AllTrim( Upper( wModest.txbName.Value ) ) == cFieldName )
          
          If ( aStat[ 'CurrMode' ] == MODE_EDITFIELD )
             If !( Cycle == nRow )
                WriteMsg( MSG_FIELD_ALREADY + ' #' + LTrim( Str( Cycle ) ) + ' - ' + cFieldName )
                Break
             Endif
          Else
             WriteMsg( MSG_FIELD_ALREADY + ' #' + LTrim( Str( Cycle ) ) + ' - ' + cFieldName )
             Break
          Endif
           
       Endif
    
   Next
   
   // Розмірність поля обмежена. Для символьних полів - 255,
   // числових - 20. Тому додатково перевіряємо співідношення
   // довжини поля і дробної частини для чисел.
   
   If ( wModest.cmbType.Value == TYPE_IS_NUM )
   
      If ( wModest.spnLen.Value > LEN_IS_NUM )
         WriteMsg( MSG_DECIMALS_LONG )
         Break
      Endif
       
      // Якщо є дробна частина, то загальна довжина поля має
      // враховувати її розмірність + 1 позиція для розділового знаку
   
      If !Empty( wModest.spnDec.Value )
   
         If ( ( wModest.spnDec.Value + 1 ) >= wModest.spnLen.Value )
            WriteMsg( MSG_DECIMALS_LONG )
            Break
         Endif
      
      Endif

   Endif
     
   // Перевірки пройшли успішно. Але якщо вказано формулу перетворення
   // даних, ця ознака буде переглянута.
   
   lSuccess := .T.
   
   // Правило трансформації. Тільки для полів, що вже існували
   // в структурі. Заодно підправляється ознака корекності заповнення
   // даних
   
   If ( aStat[ 'CurrMode' ] == MODE_EDITFIELD )
   
      xRule := AllTrim( wModest.txbRule.Value )
      
      If !Empty( xRule )
   
        // Спочатку виконуємо підстановку у вираз тестових значень
        
        Do case
           Case ( ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'C' ) .or. ;
                  ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'M' )      ;
                )
             
             cValue := '"'
             For Cycle := 1 to oEditStru : aArray[ nRow, DBS_OLDLEN ]
               cValue += LTrim( Str( Cycle ) )
             Next
             cValue += '"'
             
           Case ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'N' )
              
              If !Empty( oEditStru : aArray[ nRow, DBS_OLDDEC ] )
                 cValue := Replicate( '8', oEditStru : aArray[ nRow, DBS_OLDDEC ] )
                 cValue := ( Replicate( '8', ( oEditStru : aArray[ nRow, DBS_OLDLEN ]       - ;
                                               oEditStru : aArray[ nRow, DBS_OLDDEC ] - 1 )   ;
                                      ) + '.' + cValue )
              Else
                 cValue := Replicate( '8', oEditStru : aArray[ nRow, DBS_OLDLEN ] )               
              Endif
              
           Case ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'D' )
             cValue := 'Date()'
             
           Case ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'L' )
             cValue := '.T.'
             
        Endcase
        
        xRule := StrTran( xRule, aStat[ 'Expression' ], cValue )

        Try
        
          xRule := &( '{ || ' + xRule + ' }' )
          nType := wModest.cmbType.Value
        
          cValue := Valtype( Eval( xRule ) )
          If !( cValue == CORRECT_TYPES[ nType ] )
             WriteMsg( MSG_RULE_TYPES + 'Rule - ' + cValue + ', field - ' + CORRECT_TYPES[ nType ] )
             lSuccess := .F.
          Endif
          
        Catch
          WriteMsg( MSG_RULE_INCORRECT )
          lSuccess := .F.
        End        
        
      Endif
      
   Endif
   
   ChangeMaxLimit()
   
End

Return lSuccess

****** End of CheckData ******


/******
*
*       CheckNameField( cName ) --> lSuccess
*
*       Checkup for valid field name
*
*/

Static Function CheckNameField( cName )
Local lSuccess := .T.         , ;
      nLen     := Len( cName ), ;
      Cycle                   , ;
      cChar

If !Empty( nLen )

   // First symbol of name must be the letter
   
   If IsAlpha( Left( cName, 1 ) )
   
      For Cycle := 1 to nLen
   
        cChar := Substr( cName, Cycle, 1 )
     
        If !( cChar $ 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_' )
           WriteMsg( MSG_CHAR_INCORRECT + cChar )
           lSuccess := .F.
        Endif
     
      Next
      
   Else
      WriteMsg( MSG_ERROR_FIELDNAME )
      lSuccess := .F.
   Endif
   
Else
   WriteMsg( MSG_ERROR_FIELDNAME )
   lSuccess := .F.
Endif

Return lSuccess

****** End of CheckNameField ******


/******
*
*       AddInCollector( nMode )
*
*       To copy (nMode = MODE_COPY) or cut (nMode = MODE_CUT)
*       row in collector
*
*/

Static Procedure AddInCollector( nMode )
Memvar aStat, oEditStru, aCollector
Local cObj  := ThisWindow.FocusedControl, ;
      nRow  := oEditStru : nAt          , ;
      aItem

// The focus must be in the field list for bring the field to collector

If !( cObj == 'oEditStru' )
   WriteMsg( MSG_NOACTIVE_STRUCTURE )
   Return
Endif

If Empty( oEditStru : aArray[ nRow, DBS_NAME ] )
   WriteMsg( MSG_STRUCTURE_EMPTY )
   Return
Endif

aItem := Array( DBS_NEW_ALEN )
      
aItem[ DBS_FLAG    ] := oEditStru : aArray[ nRow, DBS_FLAG    ]
aItem[ DBS_NAME    ] := oEditStru : aArray[ nRow, DBS_NAME    ]
aItem[ DBS_TYPE    ] := oEditStru : aArray[ nRow, DBS_TYPE    ]
aItem[ DBS_LEN     ] := oEditStru : aArray[ nRow, DBS_LEN     ]
aItem[ DBS_DEC     ] := oEditStru : aArray[ nRow, DBS_DEC     ]
aItem[ DBS_OLDNAME ] := oEditStru : aArray[ nRow, DBS_OLDNAME ]
aItem[ DBS_OLDTYPE ] := oEditStru : aArray[ nRow, DBS_OLDTYPE ]
aItem[ DBS_OLDLEN  ] := oEditStru : aArray[ nRow, DBS_OLDLEN  ]
aItem[ DBS_OLDDEC  ] := oEditStru : aArray[ nRow, DBS_OLDDEC  ]
aItem[ DBS_COMMENT ] := oEditStru : aArray[ nRow, DBS_COMMENT ]
aItem[ DBS_RULE    ] := oEditStru : aArray[ nRow, DBS_RULE    ]

AAdd( aCollector, aItem )

wModest.grdCollector.AddItem( { aItem[ DBS_NAME ]         , ;
                                aItem[ DBS_TYPE ]         , ;
                                Str( aItem[ DBS_LEN ], 3 ), ;
                                Str( aItem[ DBS_DEC ], 3 ), ;
                                aItem[ DBS_COMMENT ]        ;
                              } )

// If row is cut to collector, when to delete from field list
 
If ( nMode == MODE_CUT )
   oEditStru : SetDeleteMode( .T., .F. )
   oEditStru : DeleteRow()
   oEditStru : SetDeleteMode( .F. )

   // Cut a row to collector changes the srtucture (and, probably, description)
   // Establish the appropriate flag.
   
   aStat[ 'ChStruct' ] := .T.
   
   If !Empty( aItem[ DBS_COMMENT ] )
      aStat[ 'ChDescript' ] := .T.
   Endif
   
   SetIconSave( 1 )
   
Endif

// Show needed tab (for see the contents of collector)

wModest.tbDescript.Value := 3

Return

****** End of AddInCollector ******
 

/******
*
*       PasteFromCollector()
*
*       Paste field from collector
*
*/

Static Procedure PasteFromCollector
Memvar oEditStru, aStat, aCollector
Local cObj       := ThisWindow.FocusedControl, ;
      nItem                                  , ;
      aItem      := Array( DBS_NEW_ALEN )    , ;
      nLen       := oEditStru : nLen         , ;
      Cycle                                  , ;
      nRow                                   , ;
      cFieldName

// If control focus is not the collector, when it is ignored.
// Also don't execute, if collector is empty or
// active element is absent.

If !( cObj == 'grdCollector' )
   WriteMsg( MSG_NOACTIVE_COLLECTOR )
   Return
Endif

nItem := wModest.grdCollector.Value

If ( Empty( wModest.grdCollector.ItemCount ) .or. Empty( nItem ) )
   WriteMsg( MSG_COLLECTOR_EMPTY )
   Return
Endif

ACopy( aCollector[ nItem ], aItem )        // Get inserted data from collector

// Checking for field dublication
   
For Cycle := 1 to nLen

    cFieldName := Iif( Empty( oEditStru : aArray[ Cycle, DBS_NAME ] )           , ;
                       ''                                                       , ;
                       AllTrim( Upper( oEditStru : aArray[ Cycle, DBS_NAME ] ) )  ;
                     )
   
    If ( AllTrim( Upper( aItem[ DBS_NAME ] ) ) == cFieldName )
       WriteMsg( MSG_FIELD_ALREADY + ' #' + LTrim( Str( Cycle ) ) + ' - ' + cFieldName )
       Return
    Endif
    
Next

nRow := oEditStru : nAt

If Empty( oEditStru : aArray[ 1, DBS_NAME ] )
   oEditStru : aArray[ 1, DBS_FLAG    ] := aItem[ DBS_FLAG    ]
   oEditStru : aArray[ 1, DBS_NAME    ] := aItem[ DBS_NAME    ]
   oEditStru : aArray[ 1, DBS_TYPE    ] := aItem[ DBS_TYPE    ]
   oEditStru : aArray[ 1, DBS_LEN     ] := aItem[ DBS_LEN     ]
   oEditStru : aArray[ 1, DBS_DEC     ] := aItem[ DBS_DEC     ]
   oEditStru : aArray[ 1, DBS_OLDNAME ] := aItem[ DBS_OLDNAME ]
   oEditStru : aArray[ 1, DBS_OLDTYPE ] := aItem[ DBS_OLDTYPE ]
   oEditStru : aArray[ 1, DBS_OLDLEN  ] := aItem[ DBS_OLDLEN  ]
   oEditStru : aArray[ 1, DBS_OLDDEC  ] := aItem[ DBS_OLDDEC  ]
   oEditStru : aArray[ 1, DBS_COMMENT ] := aItem[ DBS_COMMENT ]
   oEditStru : aArray[ 1, DBS_RULE    ] := aItem[ DBS_RULE    ]

Else
   oEditStru : Insert( aItem, nRow + nShift )
   oEditStru : Display()
   oEditStru : GoPos( ( nRow + nShift ), 2 )
Endif

aStat[ 'ChStruct' ] := .T.

If !Empty( aItem[ DBS_COMMENT ] )
   aStat[ 'ChDescript' ] := .T.
Endif

SetIconSave( 1 )

oEditStru : Refresh()

ShowValues()

Return

****** End of PasteFromCollector ******


/******
*
*       FillCollector()
*
*       Filling of collector list
*
*/

Procedure FillCollector
Memvar aCollector

wModest.grdCollector.DeleteAllItems      

AEval( aCollector, { | aItem | wModest.grdCollector.AddItem( { aItem[ DBS_NAME ]         , ;
                                                               aItem[ DBS_TYPE ]         , ;
                                                               Str( aItem[ DBS_LEN ], 3 ), ;
                                                               Str( aItem[ DBS_DEC ], 3 ), ;
                                                               aItem[ DBS_COMMENT ]        ;
                                                              } )                          ;
                   } ) 

Return

****** End of FillCollector ******


/******
*
*       SetMenuTheme()
*
*       Set Themed Menu is based on OS type
*
*/

Static Procedure SetMenuTheme()
LOCAL aColors := GetMenuColors()

	aColors[ MNUCLR_MENUBARBACKGROUND1 ]  := GetSysColor( 15 )
	aColors[ MNUCLR_MENUBARBACKGROUND2 ]  := GetSysColor( 15 )

If IsThemed()

	aColors[ MNUCLR_MENUBARTEXT ]         := GetSysColor(  7 )
	aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := GetSysColor( 14 )
	aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := GetSysColor( 17 )
	aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= GetSysColor( 13 )
	aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= GetSysColor( 13 )
	aColors[ MNUCLR_MENUITEMTEXT ]        := GetSysColor(  7 )  
	aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= GetSysColor( 14 )  
	aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := GetSysColor( 17 )   

	aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := GetSysColor( 4 )
	aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := GetSysColor( 4 )

	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := GetSysColor( 13 )
	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := GetSysColor( 13 )
	aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := GetSysColor( 4 )
	aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := GetSysColor( 4 )

	aColors[ MNUCLR_IMAGEBACKGROUND1 ] := GetSysColor( 15 )
	aColors[ MNUCLR_IMAGEBACKGROUND2 ] := GetSysColor( 15 )

	aColors[ MNUCLR_SEPARATOR1 ] := GetSysColor( 17 )
	aColors[ MNUCLR_SEPARATOR2 ] := GetSysColor( 14 )

	aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := GetSysColor( 13 ) 
	aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := GetSysColor( 13 )
	aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := GetSysColor( 17 )
	aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := GetSysColor( 14 )

	SET MENUCURSOR FULL
	SET MENUSEPARATOR DOUBLE RIGHTALIGN
	SET MENUITEM BORDER FLAT

Else
	If ! IsWinNT()
		SetMenuBitmapHeight( BmpSize( "CUT" )[ 1 ] ) 
	EndIf

	aColors[ MNUCLR_MENUBARTEXT ]         := RGB(   0,   0,   0 )
	aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := RGB(   0,   0,   0 )
	aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := RGB( 128, 128, 128 )
	aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= GetSysColor(15)
	aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= GetSysColor(15)

	aColors[ MNUCLR_MENUITEMTEXT ]        := RGB(   0,   0,   0 )
	aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= RGB( 255, 255, 255 )
	aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := RGB( 128, 128, 128 )

	aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := GetSysColor( 4 )
	aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := GetSysColor( 4 )

	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB(  10,  36, 106 )
	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB(  10,  36, 106 )
	aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := RGB( 212, 208, 200 )
	aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := RGB( 212, 208, 200 )

	aColors[ MNUCLR_IMAGEBACKGROUND1 ] := GetSysColor( 4 )
	aColors[ MNUCLR_IMAGEBACKGROUND2 ] := GetSysColor( 4 )

	aColors[ MNUCLR_SEPARATOR1 ] := RGB( 128, 128, 128 )
	aColors[ MNUCLR_SEPARATOR2 ] := RGB( 255, 255, 255 )

	aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := RGB(  10,  36, 106 )
	aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := RGB( 128, 128, 128 )
	aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := RGB(  10,  36, 106 )
	aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := RGB( 255, 255, 255 )

	SET MENUCURSOR SHORT
	SET MENUSEPARATOR DOUBLE LEFTALIGN
	SET MENUITEM BORDER 3D

EndIf

SetMenuColors( aColors )

Return

****** End of SetMenuTheme ******
