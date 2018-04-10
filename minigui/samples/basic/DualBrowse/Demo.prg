*--------------------------------------------------------------------------------*
*  FUNCTION ClearSearch( nStatus )
*    RETURN nStatus
*  STATIC FUNCTION EditQty
*    RETURN NIL
*  FUNCTION IncrementalSearch( nLastKey, i )
*    RETURN 0
*  FUNCTION MAIN
*    RETURN NIL
*  STATIC FUNCTION MoneyComma( cMoneyString, nLength )
*    RETURN PADL( cDollars, nLength )
*  STATIC FUNCTION MoreThanOne
*    RETURN ( aQuantity[ nElement ] >= 2 )
*  STATIC FUNCTION OpenTables
*    RETURN NIL
*  STATIC FUNCTION PickedIt
*    RETURN ASCAN( aChosenRecs, CATALOG->( RECNO())) > 0
*  FUNCTION PutCashComma( cMoneyString, nCommaHere )
*    RETURN NIL
*  FUNCTION PutItOn
*    RETURN NIL
*  STATIC FUNCTION ShowByCode
*    RETURN NIL
*  STATIC FUNCTION ShowByName
*    RETURN NIL
*  STATIC FUNCTION ShowSelections
*    RETURN NIL
*  STATIC FUNCTION ShowSvcButtons
*    RETURN NIL
*  STATIC FUNCTION StartOver
*    RETURN NIL
*  STATIC FUNCTION TakeItOff
*    RETURN NIL
*  STATIC FUNCTION UpdateChgTotals
*    RETURN NIL
*  STATIC FUNCTION UpdateQty
*    RETURN NIL
*  FUNCTION UpdtSearchText
*    RETURN NIL
*--------------------------------------------------------------------------------*
* File:         IncrementalSearch with Dual Browse
* Author:       Dr Joe Fanucchi <drjoe@meditrax.com>, <meditrax_drjoe@yahoo.com>
* Description:  Opens a file in two browse windows at once. The second window contains only items
*               selected from the first window. Uses DYNAMICBACKCOLOR and DYNAMICFORECOLOR.
*               The indexed data table in the left window may be searched using an
*               incremental search string.
* Status:       Placed in the Public Domain by Dr Joe Fanucchi
*
* This function enables the user to select items from a master "Catalog" browse,
* and display the selected items in a separate "Wanted" list. Items which have
* been selected are displayed on a yellow background in the "Catalog" list.
* Items may be removed from the "Wanted" list
* The quantity of items in the "Wanted" list may be edited.
*
* Items in the "Catalog" list may be displayed alphabetically, or in numeric code
* order.
*------------------------------------------------------------*

#include "minigui.ch"

Set Procedure To MyEvents.prg

#DEFINE cs2UnderScores "__"
#DEFINE cs4sp          SPACE( 4 )
#DEFINE csAlphaValid   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
#DEFINE csDigitValid   '0123456789'

MEMVAR aChosenRecs
MEMVAR aQuantity
MEMVAR cSearchKey
MEMVAR cSearchText
MEMVAR cPreSearch
MEMVAR cValSrchStr
MEMVAR lIncremental
MEMVAR nPicked
MEMVAR a_hdr_image
*------------------------------------------------------------*
FUNCTION MAIN
*------------------------------------------------------------*
LOCAL bColor1    := { || IIF( PickedIt(), RGB( 255, 255, 0 ), RGB( 255, 255, 255 )) }
LOCAL bColor2    := { || RGB( 0, 0, 0 ) }
LOCAL bColor3    := { || IIF( MoreThanOne(), RGB( 208, 68, 68 ), RGB( 0, 0, 0 )) }

PRIVATE aChosenRecs  := { 0 }                        // array of RECNO() values for user-selected records
PRIVATE aQuantity    := { 0 }                        // array of numeric values for item quantities
PRIVATE cSearchKey   := ""                           // contains the incremental character string which the user has typed

PRIVATE cSearchText  := ""
* cSearchText contains the search string as it is displayed onscreen. This is not the same as cSearchKey
* because the displayed string ends in 2 underscores to indicate that additional characters may be typed:
* for example, if the user has typed "S" and then "M", "SM__" is displayed

PRIVATE cPreSearch   := ""
* cPreSearch is a static character string which precedes the incremental string for filtered searches.
* For example, if I want to search an alphabetic listing of all items in a particular category, the data table
* is indexed on FIELD->CATEGORY + UPPER( FIELD->ITEMNAME ). The desired CATEGORY code is stored in cPreSearch
* and the incremental search is made on the (hidden) category code + the (user-entered) cSearchKey

PRIVATE cValSrchStr  := csAlphaValid + csDigitValid + " ,-"  // contains all valid searchable characters
PRIVATE lIncremental := .T.                          // logical memvar: is incremental searching enabled?
PRIVATE nPicked      := 0                            // running total of user-selected records

Declare a_hdr_image[2]
a_hdr_image[1] = 'UP.BMP'
a_hdr_image[2] = 'DN.BMP'

SET BROWSESYNC ON

SET EVENTS FUNCTION TO MYEVENTS

DEFINE WINDOW SelectItems ;
  AT 0,0 ;
  WIDTH 910 HEIGHT 543 ;
  MAIN NOSIZE ;
  TITLE ' MiniGUI Incremental Search with Dual Browse - ' + CHR( 169) + ' Dr Joe Fanucchi 2005' ;
  ON INIT { || OpenTables() } ;
  ON RELEASE { || DBCLOSEALL(), Ferase("ALFA001.NTX"), Ferase("CODE001.NTX") }

  *----------------------------------------------------------*
  * Frame the browse windows:
  @ 13,15 FRAME Frame_Catalog ;
    WIDTH 355 HEIGHT 369 ;
    FONT "Arial" BOLD SIZE 10 ;
    CAPTION "Items in Catalog:"

  @ 13,509 FRAME Frame_Wanted ;
    WIDTH 381 HEIGHT 369 ;
    FONT "Arial" BOLD SIZE 10 ;
    CAPTION "Items Wanted:"

  *----------------------------------------------------------*
  * Display the browse windows:
  @ 38,18 BROWSE Brw_Catalog ;
    WIDTH 349 ;
    HEIGHT 340 ;
    HEADERS { 'Item', 'Code', 'Amount' } ;
    WIDTHS { 200, 68, 60 } ;
    WORKAREA CATALOG ;
    FIELDS { 'CATALOG->itemname', 'CATALOG->itemcode', 'CATALOG->amount' } ;
    DYNAMICBACKCOLOR { bColor1, bColor1, bColor1 } ;
    JUSTIFY { , , BROWSE_JTFY_RIGHT } ;
    ON GOTFOCUS { || SelectItems.Btn_Remove.Enabled := .F., ;
    SelectItems.Btn_Modify.Enabled := .F., ;
    SelectItems.Btn_Add.Enabled := .T., ;
    lIncremental := .T. } ;
    HEADERIMAGE a_hdr_image ;
    ON HEADCLICK { {|| ShowByName() }, { || ShowByCode() } } ;
    ON DBLCLICK PutItOn()

  @ 38,512 BROWSE Brw_Wanted ;
    WIDTH 375 ;
    HEIGHT 340 ;
    HEADERS { 'Service', 'Code', '#', 'Amount' } ;
    WIDTHS { 218, 50, 26, 60 } ;
    WORKAREA WANTED ;
    FIELDS { 'WANTED->itemname', 'WANTED->itemcode', 'LTRIM( STR( aQuantity[ ASCAN( aChosenRecs, RECNO()) ], 3 ))', ;
    'STR( WANTED->amount * aQuantity[ ASCAN( aChosenRecs, RECNO()) ], 8, 2 )' } ;
    DYNAMICFORECOLOR { bColor2, bColor2, bColor3, bColor3 } ;
    JUSTIFY { , , BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT } ;
    ON GOTFOCUS { || lIncremental := .F., ShowSvcButtons() }

  *----------------------------------------------------------*
  * Buttons for adding, removing, and editing quantity:
  @ 114,379 BUTTON Btn_Add ;
    CAPTION "Add >>" ;
    ACTION { || PutItOn() } ;
    WIDTH 120 HEIGHT 28

  @ 172,379 BUTTON Btn_Remove ;
    CAPTION "<< Remove" ;
    ACTION { || TakeItOff() } ;
    WIDTH 120 HEIGHT 28

  @ 206,379 BUTTON Btn_Modify ;
    CAPTION "Edit Quantity" ;
    ACTION { || EditQty() } ;
    WIDTH 120 HEIGHT 28

  @ 242,409 SPINNER Spin_Qty ;
    RANGE 0,20 ;
    WIDTH 60

  @ 274,379 BUTTON Btn_QtyOK ;
    CAPTION "Accept Quantity" ;
    ACTION { || UpdateQty(), UpdateChgTotals()} ;
    WIDTH 120 HEIGHT 28

  *----------------------------------------------------------*
  * This frame will be used for an incremental search function and display of total cost
  @ 392,15 FRAME Frame_Navig ;
    WIDTH 875 HEIGHT 50

  @ 410,30 LABEL Lbl_AlfaSearch ;
    WIDTH 127 HEIGHT 18 ;
    VALUE 'Alpha Search:' ;
    FONT "Arial" BOLD SIZE 10

  @ 410,30 LABEL Lbl_CodeSearch ;
    WIDTH 127 HEIGHT 18 ;
    VALUE 'Search by Code:' ;
    FONT "Arial" BOLD SIZE 10

  @ 410,125 LABEL SearchText ;
    WIDTH 260 HEIGHT 18 ;
    VALUE cs2UnderScores ;
    FONT "Arial" BOLD SIZE 10

  @ 410,605 LABEL Lbl_ChgExpl ;
    WIDTH 200 HEIGHT 18 ;
    VALUE "Total Charges: $" ;
    FONT "Arial" BOLD SIZE 10 ;
    RIGHTALIGN

  @ 410,805 LABEL Lbl_ChgTotal ;
    WIDTH 58 HEIGHT 18 ;
    VALUE '0.00' ;
    FONT "Arial" SIZE 10 ;
    RIGHTALIGN

  *----------------------------------------------------------*
  @ 450,15 FRAME Frame_Save ;
    WIDTH 875 HEIGHT 50

  @ 462,320 BUTTON Btn_Save ;
    CAPTION "Accept" ;
    ACTION { || ShowSelections(), nPicked := 0, StartOver() } ;
    WIDTH 120 HEIGHT 28

  @ 462, 470 BUTTON Btn_Cancel ;
    CAPTION "Cancel" ;
    ACTION { || nPicked := 0, StartOver() } ;
    WIDTH 120 HEIGHT 28

  SelectItems.Btn_Remove.Enabled := .F.
  SelectItems.Spin_Qty.Hide
  SelectItems.Btn_QtyOK.Hide
  SelectItems.Lbl_CodeSearch.Hide

END WINDOW

SelectItems.Brw_Catalog.HeaderImage( 1 ) :=  1 // set image header initial

CENTER WINDOW SelectItems
ACTIVATE WINDOW SelectItems

RETURN NIL
*
*------------------------------------------------------------*
FUNCTION ClearSearch( nStatus )
*------------------------------------------------------------*
* Resets the search key to a blank value, and updates the SearchText display
LOCAL cAlias := ALIAS()
cSearchText  := ""
cSearchKey   := ""                                   // resets the incremental character string to a blank

DO CASE
CASE cAlias == "CATALOG"
  SelectItems.SearchText.Value := cs2UnderScores
  SelectItems.SearchText.Show

* CASE ...
*   Add other browses here ...

ENDCASE

RETURN nStatus
*
*------------------------------------------------------------*
STATIC FUNCTION EditQty
*------------------------------------------------------------*
* Enables the user to update the quantity of an individual item
* by making the "quantity" SPINNER and the "accept" BUTTON visible

LOCAL nElement := ASCAN( aChosenRecs, WANTED->( RECNO()))

SelectItems.Spin_Qty.Value := aQuantity[ nElement ]

SelectItems.Btn_Remove.Enabled := .F.
SelectItems.Btn_Modify.Enabled := .F.
SelectItems.Spin_Qty.Show
SelectItems.Spin_Qty.Enabled   := .T.
SelectItems.Btn_QtyOK.Show

RETURN NIL
*
*------------------------------------------------------------*
FUNCTION IncrementalSearch( nLastKey, i )
*------------------------------------------------------------*
* This function conducts an incremental search for the search string 'cSearchKey'
* It is called only by EVENTS(), and returns a numeric value of 0 or 1
* Parameters:
*   nLastKey       the numeric value of the last key pressed
*   i              a pointer to the browse control
* The following PUBLIC memvars are assumed:
*   cSearchKey     contains the incremental character string which the user has typed
*   cValSrchStr    contains all valid searchable characters
*   cSearchText    contains the search string as it is displayed onscreen
*   cPreSearch     a static character string which precedes the incremental string for filtered searches
*                  (such as an employer code, for a data table indexed on employer code + employee name)
*------------------------------------------------------------*
LOCAL cLastKey  := ""                             // the last character typed
LOCAL cKeyValue := INDEXKEY( IndexOrd())

DO CASE
CASE nLastKey == 8                                   // backspace
  cSearchKey := LEFT( cSearchKey, LEN( cSearchKey ) -1 )  // just trim off the last character

CASE nLastKey == 188                                 // comma was entered in a search string
  IF ',' $ cValSrchStr
    cLastKey := ","
  ELSE
    RETU 1
  ENDIF

CASE nLastKey == 189                                 // hyphen was entered in a search string
  IF "-" $ cValSrchStr
    cLastKey := "-"
  ELSE
    RETU 1
  ENDIF

* Convert alpha characters to uppercase (I always index on UPPER( cFieldValue ))
CASE IsAlpha( CHR( nLastKey )) .AND. UPPER( CHR( nLastKey )) $ cValSrchStr
  cLastKey := UPPER( CHR( nLastKey ))

OTHERWISE
  cLastKey := CHR( nLastKey )
  IF ! cLastKey $ cValSrchStr
    cLastKey := ""
    RETU 1
  ENDIF
ENDCASE

*------------------------------------------------------------*
SEEK ( cPreSearch + cSearchKey + cLastKey )

* The next line seems too complicated, but for some reason when I am using the CODE001 index
* I can keep typing additional characters which are NOT in the ITEMCODE field, and the SEEK
* command reports we are NOT at EOF(). For example, if the long IF line is commented out
* and the IF ! EOF() line is substituted, I can type "0188000000MMM" and the SEEK will not
* result in an EOF() result. This ONLY happens with the CODE001 index, not with the ALFA001
* index. I am baffled as to the reason for this.
IF ( ! EOF()) .AND. (( cPreSearch + cSearchKey + cLastKey ) $ &cKeyValue )
* IF ! EOF()

*------------------------------------------------------------*
  * We found a record that ends in cLastKey, so reset the Browse pointer and update the search display
  cSearchKey += cLastKey
  * Update the Search Text display and reset the browse pointer
  UpdtSearchText()
ENDIF

RETURN 1
*
*------------------------------------------------------------*
STATIC FUNCTION MoneyComma( cMoneyString, nLength )
*------------------------------------------------------------*
* Formats money amounts in US $, adding commas before thousands
* e.g.: 12337.89 -> 12,337.89
* This can be customized for other countries.
LOCAL cDollars   := cMoneyString
LOCAL cPennies := ""
LOCAL i
LOCAL lInTheHole := .F.

IF ! VALTYPE( nLength ) == "N"
  nLength := LEN( cMoneyString )
ENDIF

IF VAL( cMoneyString ) < 0.00
  lInTheHole := .T.
  cMoneyString := CharRem( { "-", " " }, cMoneyString )
ENDIF

cMoneyString := LTRIM( TRIM( cMoneyString ))

IF "." $ cMoneyString                                // cents are shown
  cDollars   := LEFT( cMoneyString, AT( ".", cMoneyString ) - 1 )
  cPennies := RIGHT( cMoneyString, 2 )
ELSE
  cDollars := cMoneyString
ENDIF

FOR i := 3 TO 15 STEP 4                              // add commas to money display: 1,234,567.89
  IF LEN( cDollars ) > i
    PutCashComma( @cDollars, i )                     // 000,000
  ENDIF
NEXT i

IF lInTheHole                                        // we started out with a negative amount
  cDollars := "-" + cDollars
ENDIF

IF "." $ cMoneyString                                // cents are shown
  IF LEN( cDollars + "." + cPennies ) > nLength
    nLength := LEN( cDollars ) + 3
  ENDIF
  RETU PADL( cDollars + "." + cPennies, nLength )
ENDIF

IF LEN( cDollars ) > nLength
  nLength := LEN( cDollars )
ENDIF

RETURN PADL( cDollars, nLength )
*
*------------------------------------------------------------*
STATIC FUNCTION MoreThanOne
*------------------------------------------------------------*
* Determines whether a multiple quantity of a WANTED item has
* been ordered. Called by the DYNAMICFORECOLOR control.
LOCAL nElement := ASCAN( aChosenRecs, WANTED->( RECNO()))

RETURN ( aQuantity[ nElement ] >= 2 )
*
*------------------------------------------------------------*
STATIC FUNCTION OpenTables
*------------------------------------------------------------*
FIELD itemname, itemcode
* Open the same data table in two windows
USE SUPPLIES
IF ! FILE( "ALFA001.NTX" )
  INDEX ON UPPER( itemname ) TO ALFA001
ENDIF
IF ! FILE( "CODE001.NTX" )
  INDEX ON itemcode TO CODE001
ENDIF
CLOSE SUPPLIES

USE SUPPLIES ALIAS WANTED NEW SHARED
SET INDEX TO ALFA001, CODE001
SET FILTER TO ASCAN( aChosenRecs, WANTED->( RECNO())) > 0
GO TOP

USE SUPPLIES ALIAS CATALOG NEW SHARED
SET INDEX TO ALFA001, CODE001
GO TOP

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION PickedIt
*------------------------------------------------------------*
* Determines whether a CATALOG item has been selected. Called by
* the DYNAMICBACKCOLOR control.

RETURN ASCAN( aChosenRecs, CATALOG->( RECNO())) > 0
*
*------------------------------------------------------------*
FUNCTION PutCashComma( cMoneyString, nCommaHere )
*------------------------------------------------------------*
* Inserts a comma into the string
cMoneyString := LEFT( cMoneyString, LEN( cMoneyString ) - nCommaHere ) ;
  + "," + RIGHT( cMoneyString, nCommaHere )

RETURN NIL
*
*------------------------------------------------------------*
FUNCTION PutItOn()
*------------------------------------------------------------*
* Adds an item from the "Catalog" browse to the "Wanted" browse,
* by adding the RECNO() to the array of chosen items. Prevents
* duplicate selection of the same item.

LOCAL nThisRecNo := CATALOG->( RECNO())

IF ASCAN( aChosenRecs, nThisRecNo ) == 0
  ASIZE( aChosenRecs, ++nPicked )
  ASIZE( aQuantity, nPicked )
  aChosenRecs[ nPicked ] := nThisRecNo
  aQuantity[ nPicked ]   := 1
  SelectItems.Brw_Wanted.Value := nThisRecNo
  SelectItems.Brw_Wanted.Refresh
  UpdateChgTotals()
ELSE
  MsgExclamation( "This item has already been selected.", " Duplicate Selection !" )
ENDIF

ClearSearch( NIL )                                   // resets cSearchKey to ""

SELECT CATALOG
SelectItems.Brw_Catalog.Value := nThisRecNo
SelectItems.Brw_Catalog.Refresh
SelectItems.Brw_Catalog.SetFocus

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION ShowByCode
*------------------------------------------------------------*
* Changes the display of items in both browse windows so they
* appear in order of their numeric code.
LOCAL nThisRecNo := CATALOG->( RECNO())

* Update the label for the search text
SelectItems.Lbl_AlfaSearch.Hide
SelectItems.Lbl_CodeSearch.Show
SelectItems.SearchText.Col := 140
ClearSearch( NIL )                                   // resets cSearchKey to ""

SelectItems.Brw_Catalog.HeaderImage( 1 ) :=  0
SelectItems.Brw_Catalog.HeaderImage( 2 ) :=  1

SELECT WANTED
SET ORDER TO 2                     // index code001
GO TOP
SelectItems.Brw_Wanted.Value := RECNO()
SelectItems.Brw_Wanted.Refresh

SELECT CATALOG
SET ORDER TO 2                     // index code001
GO TOP
SelectItems.Brw_Catalog.Value := nThisRecNo
SelectItems.Brw_Catalog.Refresh

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION ShowByName
*------------------------------------------------------------*
* Changes the display of items in both browse windows so they
* appear in alphabetic order.

* Update the label for the search text
SelectItems.Lbl_CodeSearch.Hide
SelectItems.Lbl_AlfaSearch.Show
SelectItems.SearchText.Col := 125
ClearSearch( NIL )                                   // resets cSearchKey to ""

SelectItems.Brw_Catalog.HeaderImage( 2 ) :=  0
SelectItems.Brw_Catalog.HeaderImage( 1 ) :=  1

SELECT WANTED
SET ORDER TO 1                   // index alfa001
GO TOP
SelectItems.Brw_Wanted.Value := RECNO()
SelectItems.Brw_Wanted.Refresh

SELECT CATALOG
SET ORDER TO 1                  // index alfa001
GO TOP
SelectItems.Brw_Catalog.Value := RECNO()
SelectItems.Brw_Catalog.Refresh

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION ShowSelections()
*------------------------------------------------------------*
* Displays the items which have been selected. In my application code, this
* message is not displayed, but the values in the aChosenRecs array are stored
* in another data table ORDER.DBF

LOCAL cMessage := "You selected:"

IF nPicked < 1
  MsgInfo( "You did not select any items." + cs4sp, " No Selections Made !" )
  RETU NIL
ELSE
  SELECT WANTED
  SET ORDER TO 1
  GO TOP
  WHILE ! EOF()
    IF ASCAN( aChosenRecs, RECNO()) > 0
      cMessage += CRLF + "  " + TRIM( WANTED->itemname ) ;
        + " [ " + LTRIM( STR( aQuantity[ ASCAN( aChosenRecs, RECNO()) ], 3 )) ;
        + " @ " + LTRIM( STR( WANTED->amount, 8, 2 )) + " ]" ;
        + cs4sp                                      // padding at the end of each line helps improve readability
    ENDIF
    SKIP
  ENDDO
  MsgInfo( cMessage, " Selected Items" )
ENDIF
RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION ShowSvcButtons()
*------------------------------------------------------------*
* This function is called when the WANTED browse gains focus.
* It enables the buttons which modify or remove items from the WANTED browse,
* and disables the button which adds items from the CATALOG browse.
IF nPicked > 0
  SelectItems.Btn_Remove.Enabled := .T.
  SelectItems.Btn_Modify.Enabled := .T.
  SelectItems.Btn_Add.Enabled    := .F.
ENDIF

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION StartOver
*------------------------------------------------------------*
aChosenRecs := { 0 }
aQuantity   := { 0 }
SelectItems.Lbl_ChgTotal.Value := "0.00"

SELECT WANTED
GO TOP
SelectItems.Brw_Wanted.Value := RECNO()
SelectItems.Brw_Wanted.Refresh

ClearSearch( NIL )                                   // resets cSearchKey to ""

SELECT CATALOG
GO TOP
SelectItems.Brw_Catalog.Value := RECNO()
SelectItems.Brw_Catalog.Refresh
SelectItems.Brw_Catalog.SetFocus

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION TakeItOff()
*------------------------------------------------------------*
* Removes a selected item from the WANTED browse
LOCAL nThisRecNo := RECNO()
LOCAL nElement   := ASCAN( aChosenRecs, WANTED->( RECNO()))

* Delete the element from aChosenRecs and aQuantity
ADEL( aChosenRecs, nElement )
ADEL( aQuantity, nElement )
* Decrement the running tally of items selected
--nPicked
* Update the display of the total cost of items selected
UpdateChgTotals()

SELECT WANTED
GO TOP
SelectItems.Brw_Wanted.Value := RECNO()
SelectItems.Brw_Wanted.Refresh

* If all items have been deleted from aChosenRecs, the WANTED browse is empty.
* In that case, return focus to the CATALOG browse.
IF nPicked > 0
  SelectItems.Brw_Wanted.SetFocus
ELSE
  SELECT CATALOG
  SelectItems.Brw_Catalog.Value := nThisRecNo
  SelectItems.Brw_Catalog.Refresh
  SelectItems.Brw_Catalog.SetFocus
ENDIF

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION UpdateChgTotals()
*------------------------------------------------------------*
* Displays the total cost of selected items
LOCAL i
LOCAL cAlias := ALIAS()
LOCAL nRecNo := RECNO()
LOCAL nTotal := 0

IF nPicked > 0
  SELECT CATALOG
  FOR i := 1 TO nPicked
    GO aChosenRecs[ i ]
    nTotal += CATALOG->amount * aQuantity[ i ]
  NEXT i
ENDIF

SelectItems.Lbl_ChgTotal.Value := LTRIM( MoneyComma( STR( nTotal, 8, 2 ), 9 ))

SelectItems.Btn_Save.Enabled   := .T.
SelectItems.Btn_Cancel.Enabled := .T.

IF cAlias == "CATALOG"
  SELECT CATALOG
  GO nRecNo
  SelectItems.Brw_Catalog.Value := nRecNo
  SelectItems.Brw_Catalog.Refresh
  SelectItems.Brw_Catalog.SetFocus
ELSE
  SELECT WANTED
  GO nRecNo
  SelectItems.Brw_Wanted.Value := nRecNo
  SelectItems.Brw_Wanted.Refresh
  SelectItems.Brw_Wanted.SetFocus
ENDIF

RETURN NIL
*
*------------------------------------------------------------*
STATIC FUNCTION UpdateQty
*------------------------------------------------------------*
* Enables the user to modify the quantity of WANTED items.
LOCAL nElement

SELECT WANTED
nElement := ASCAN( aChosenRecs, WANTED->( RECNO()))
aQuantity[ nElement ] := SelectItems.Spin_Qty.Value

SelectItems.Btn_QtyOK.Hide
SelectItems.Spin_Qty.Hide
SelectItems.Brw_Wanted.Refresh
SelectItems.Brw_Wanted.SetFocus

SELECT CATALOG

RETURN NIL
*
*------------------------------------------------------------*
FUNCTION UpdtSearchText
*------------------------------------------------------------*
* Updates the display of Search Text when an incremental search is being performed
* Requires prior declaration of the following PUBLIC memvars:
*   cSearchKey     contains the incremental character string which the user has typed
*   cSearchText    contains the search string as it is displayed onscreen
*------------------------------------------------------------*
LOCAL cAlias := ALIAS()

cSearchText := cSearchKey

DO CASE
CASE cAlias == "CATALOG"
  SelectItems.SearchText.Value  := cSearchText + cs2UnderScores
  SelectItems.SearchText.Show

  SelectItems.Brw_Catalog.Value := RECNO()
  SelectItems.Brw_Catalog.SetFocus

* CASE ...
*   Add other browses here ...

OTHERWISE
  MsgInfo( "You're browsing " + TRIM( cAlias ) ;
    + CRLF +  "UpdtSrchText() is not configured for this data table" )
ENDCASE

RETURN NIL
*
*------------------------------------------------------------*
* EOF()
*------------------------------------------------------------*