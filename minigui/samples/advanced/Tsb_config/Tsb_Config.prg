/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2014 Andrey Verchenko <verchenkoag@gmail.com>
 * Helped and taught by Grigory Filatov <gfilatov@inbox.ru>
 *
*/
#include "MiniGUI.ch"
#include "TSBrowse.ch"

MEMVAR oBrw, nTbrwColorText , nTbrwColorPane , nRecnoDbFilter, aFontEdit, aToolBtn, cRunFunc
///////////////////////////////////////////////////////////////////////////
// Function: list of fields TBrowse
FUNCTION ListFieldsTbrws()
LOCAL aPole := {}
***************************  The list of fields TBrowse ****************************************************************************
*             |            1          |    2    |     3      |      4             |      5     |    6      |   7         |    8      
*             |       Title           |  alias  |   field    | field format       |alignment   |processing |function     |Writing in 
*             |       column          |  base   |   base     |                    |column      |field(type)|treating an  | the field
AADD( aPole, { "Date"                 , ""      , "DATE"     , "99.99.9999"       , DT_CENTER  , "D"       , ""          ,        } )
AADD( aPole, { "Time"                 , ""      , "TIME"     , "99:99:99"         , DT_CENTER  , "C"       , ""          ,        } )
AADD( aPole, { "Code"                 , ""      , "NEVENT"   , "9999"             , DT_CENTER  , "N"       , ""          ,        } )
AADD( aPole, { "Name of the event"    , ""      , "EVENT"    , REPLICATE("x",60)  , DT_LEFT    , "C"       , ""          ,        } )
AADD( aPole, { "Computer"             , ""      , "COMPUTER" , REPLICATE("x",20)  , DT_LEFT    , "C"       , ""          ,        } )
AADD( aPole, { "User"                 , ""      , "USER"     , REPLICATE("x",20)  , DT_LEFT    , "C"       , ""          ,        } )
AADD( aPole, { "Operator"             , "OPER"  , "OPER"     , REPLICATE("x",20)  , DT_LEFT    , "J"       , "DimOperat" ,"KOper" } )
AADD( aPole, { "List"                 , ""      , "MEMO2"    , REPLICATE("x",20)  , DT_LEFT    , "M"       , "Forma_Memo",        } )
AADD( aPole, { "Name"                 , ""      , "FILES"    , REPLICATE("x",20)  , DT_LEFT    , "C"       , ""          ,        } )
AADD( aPole, { "Amount"               , ""      , "NFILE"    , "@Z 999 999"       , DT_CENTER  , "N"       , ""          ,        } )
AADD( aPole, { "Size (Mb)"            , ""      , "NSIZE"    , "@Z 999 999.999"   , DT_RIGHT   , "N"       , ""          ,        } )
AADD( aPole, { "Module / Function"    , ""      , "MODULE"   , REPLICATE("x",20)  , DT_LEFT    , "C"       , ""          ,        } )
AADD( aPole, { "Result operation"     , ""      , "REZULT"   , REPLICATE("x",50)  , DT_LEFT    , "C"       , ""          ,        } )
AADD( aPole, { "Comment"              , ""      , "MEMO"     , REPLICATE("x",20)  , DT_LEFT    , "M"       , ""          ,        } )
AADD( aPole, { "ID recno"             , ""      , "ID"       , "999 999 999"      , DT_CENTER  , "N"       , "Forma_Memo",        } )

RETURN aPole

///////////////////////////////////////////////////////////////////////////
FUNCTION Main()
   LOCAL nI, nJ, hFont, nHButt, hWnd, nHStBar, cStr, bBlock, cExp, aPole
   LOCAL nTbColWidth, nWidthFirstColumn, cField, cAlias, cTypeField, cTitleColum
   PUBLIC oBrw, aFontEdit, nTbrwColorText , nTbrwColorPane , nRecnoDbFilter := 0, aToolBtn := {}

   SET EPOCH TO ( Year(Date()) - 50 )
   SET CENTURY ON
   SET DATE TO GERMAN
   SET DELETED ON
   RDDSETDEFAULT('DBFCDX')

   SET FONT TO "Times New Roman", 12   // Set the default font

   IF !DbfLogOpen() // open base -> Tbrws_use.prg
      QUIT
   ENDIF

   // -------------------------------------------------------------------------
   // IniGetPosWindow () - Restore the window coordinates of the ini-file
   // IniGetTbrowse (oBrw) - Recover all values TBROWSE from ini file
   // IniSetPosWindow () - Save the coordinates of the window in the ini-file
   // IniSetTbrowse (oBrw) - Save all values TBROWSE in the ini-file

   DEFINE WINDOW Form_0 AT 0,0 WIDTH 720 HEIGHT 560 ;
     MINWIDTH 720 MINHEIGHT 500 ;
     TITLE "TSBrowse save/restore configuration from ini file - Version 1.0" ;
     MAIN ;
     BACKCOLOR {122,161,230} ;
     NOMINIMIZE              ;
     ON SIZE { ||ResizeBrowse()} ;
     ON MAXIMIZE { || ResizeBrowse() } ;
     ON INIT { || IniGetPosWindow(), IniGetTbrowse(oBrw), Form_0.oBrw.Setfocus } ;
     ON RELEASE { || IniSetTbrowse(oBrw), IniSetPosWindow(), MyDbfIndexDelete() } 

     nHButt := MyToolBar()  // buttons of the window

       DEFINE STATUSBAR  SIZE 10 BOLD
           STATUSITEM ""
           STATUSITEM "Right mouse button - the popup menu TBROWSE" WIDTH 380 
           STATUSITEM " Recno: 0/0" WIDTH 115 
           STATUSITEM "Alias: "+ALIAS() WIDTH 115 ACTION BASE_TEK()
           DATE
       END STATUSBAR

     hWnd := GetFormHandle('Form_0') 
     nHStBar := GetWindowHeight(GetControlHandle('STATUSBAR', 'Form_0')) // height StatusBar 

     SELECT LOG_DBF
     DBSetOrder( 1 )
     cExp := "!Empty(LOG_DBF->DATE)"  // filter condition for example only
     DbSetFilter( &("{||" + cExp + "}"), cExp )
     goto TOP

     DEFINE TBROWSE oBrw       ; 
            AT     nHButt+1,0  ; 
            WIDTH  GetClientWidth(hWnd)   ; 
            HEIGHT GetClientHeight(hWnd)-nHStBar-nHButt-1  ;
            ON CHANGE  { || MyChangeBrowse("oBrw") } ;
            ON GOTFOCUS MyChangeBrowse("oBrw") ;
            SELECTOR .T. ;
            CELL         
     
     END TBROWSE  

     oBrw:bLogicLen := {|| iif( Empty(( oBrw:cAlias )->( DbFilter() )), ;
                             ( oBrw:cAlias )->( LastRec() ), ;
                             ( oBrw:cAlias )->( DbEval( { || M->nRecnoDbFilter++ }, &("{||" + ( oBrw:cAlias )->( DbFilter() ) + "}") ) ) ) }

     // create the first column with the number in the table
     ADD COLUMN TO oBrw ;
         HEADER "No" ;
         DATA oBrw:nLogicPos ;
         SIZE 40 PIXELS ;
         ALIGN DT_CENTER,DT_CENTER,DT_CENTER ;   // cells, header, footer
         COLORS CLR_BLACK, CLR_HGRAY

     nWidthFirstColumn := 40     // Remember the width of the first column
     nJ := 1                     // Install meter columns = 1 

     hFont := oBrw:hFont         // consider the handle font table columns
     aPole := ListFieldsTbrws()  // consider the structure of the table
     FOR nI := 1 TO LEN(aPole)

         nJ++
         ADD COLUMN TO TBROWSE oBrw // add a new column in TBROWSE

         cStr := aPole[nI,4]  // calculation of the length of the text is shown on the template output field
         nTbColWidth := GetTextWidth( NIL, cStr, hFont ) + GetBorderWidth()

         cTitleColum := aPole[nI,1]                  // column heading
         cField      := aPole[nI,3]                  // field name column
         cAlias      := aPole[nI,2]                  // alias name another database
         cTypeField  := FIELDTYPE(FIELDNUM(cField))  // type of database field
         cRunFunc    := aPole[nI,7]                  // Processing function - call  
         oBrw:aColumns[nJ]:cHeading := cTitleColum   // assign a column header
         oBrw:SetColSize( nJ, nTbColWidth )          // assign a column width
         oBrw:aColumns[nJ]:nAlign   := aPole[nI,5]   // assign alignment column
         oBrw:aColumns[nJ]:cPicture := aPole[nI,4]   // assign a template column

         IF LEN(cAlias) > 0                
            bBlock := &( "{ || " + cAlias + "->"+cField+" }" )
         ELSE
            bBlock := FieldWBlock( cField, Select() )
         ENDIF
         IF cTypeField == "M"
           bBlock := "{ || MEMOLINE("+ALIAS()+"->"+cField+","+HB_NTOS(LEN(cStr))+",1) }" 
           oBrw:aColumns[nJ]:bData := &( bBlock )
           oBrw:aColumns[nJ]:Cargo := cField
           oBrw:aColumns[nJ]:lEdit := .T.
           oBrw:aColumns[nJ]:bPrevEdit := { || FORMA_MEMO( oBrw:aColumns[oBrw:nCell]:cHeading, oBrw:aColumns[oBrw:nCell]:Cargo ) } 
           // Function FORMA_MEMO() should return .F.,
           // otherwise it will be editing this cell standard object TBROWSE 
           //oBrw:aColumns[nI]:bPostEdit := {|| ...}  // Other steps (optional) after entering into cell
         ELSE
           oBrw:aColumns[nJ]:bData := bBlock
           IF cTypeField # "+"               // except for autoincrement database fields
              oBrw:aColumns[nJ]:lEdit := .T.

              IF aPole[nI,6] == "J"          // processing field
                // The call - processing functions of aPole[nI,7] 
                // in this case DimOperat () - see Form_operat.prg
                oBrw:aColumns[nJ]:Cargo := { nJ, aPole[nI] }
                &cRunFunc( oBrw:aColumns[nJ]:Cargo )
              ENDIF

           ENDIF
         ENDIF

      NEXT
     
      // ------- assign column superhidera ------------
      ADD  SUPER  HEADER TO oBrw ;
         FROM  COLUMN  3         ;
         TO  COLUMN 4            ;
         HEADER "Event"
  
      ADD   HEADER TO oBrw ;
         FROM   5          ;
         TO   9            ;
         HEADER "Event and location"
         
      ADD   HEADER TO oBrw ;
         FROM   10          ;
         TO   13           ;
         HEADER "Files"
         
      ADD   HEADER TO oBrw ;
         FROM   14         ;
         TO   16           ;
         HEADER "Results event"

       DEFINE CONTEXT MENU CONTROL oBrw
           MENUITEM "Info about the database"            ACTION { || BASE_TEK()        }  
           MENUITEM "Item DB fields"                     ACTION { || MsgDebug( aPole ) }  
           SEPARATOR	
           MENUITEM "Enable display of deleted records"  ACTION { || RecnoViewDel(.T.) }  
           MENUITEM "Disable display of deleted records" ACTION { || RecnoViewDel(.F.) }  
           MENUITEM "Recover deleted record"             ACTION { || RecnoRecovery()   }  
       END MENU

   END WINDOW

   //oBrw:lCellBrw := .F.   // Marker on the entire table
   
   oBrw:lNoChangeOrd := .T.  // remove sort by column
   oBrw:nColOrder := 0       // remove sort icon column

   // See description in the source: h_tbrowse.prg
   oBrw:lNoGrayBar  := .t.  // Do not show inactive cursor
   oBrw:nAdjColumn  := 2    // stretch column 2 to fill the voids in the right Tbrowse
   oBrw:nHeightCell += 6    // to the height of the rows on umolchpaniyu add 6 pixels                                                          

   oBrw:nHeightSuper := 24  // header height (complex, composite) - superhidera

   oBrw:nHeightHead += 4    // to the height of the header row on umolchpaniyu add 4 pixels
   oBrw:lNoHScroll  := .f.  // Showing the horizontal scrolling

   oBrw:lFooting := .T.     // use the basement
   oBrw:lDrawFooters := .T. // draw cellars
   oBrw:nHeightFoot := 20   // line-height basement
   oBrw:DrawFooters()       // perform drawing basement

   oBrw:nFreeze     := 1     // Freeze the first column Tbrowse
   oBrw:lLockFreeze := .T.   // Avoid drawing the cursor on the frozen columns

   // set the value of the basement
   oBrw:aColumns[2]:cFooting := "<-Total"    // set the value in column 2 of the basement
   oBrw:aColumns[1]:cFooting := { || LTrim( Transform( oBrw:nLen, "### ###" ) ) }

   oBrw:aColumns[11]:cFooting := { || LTrim( Transform( GetCountFieldFilter("NFILE") , "999 999"    ) ) }
   oBrw:aColumns[12]:cFooting := { || LTrim( Transform( GetCountFieldFilter("NSIZE"), "999 999.999" ) ) }

   oBrw:ResetVScroll()      // showing vertical scrolling

   oBrw:Refresh(.T.)        // redraw the table
   
   // repartition column 2 (1 + 1 -SELECTOR) - otherwise buggy 
   oBrw:bInit := {|| oBrw:SetColSize( 2, nWidthFirstColumn )} 

   oBrw:nAt := 5         // move the marker on the 5 string
   oBrw:nCell := 3       // move the marker on the 3 column
   //oBrw:GoPos( 5,3 )   // move the marker on the 5 rows and 3 columns

   // ---- Remember two current colors for the ini file and windows memo fields ----
   M->nTbrwColorText := oBrw:nClrText  // Color of text in the table cells
   M->nTbrwColorPane := oBrw:nClrPane  // The background color in the table cells 

   Form_0.oBrw.SetFocus

   CENTER WINDOW Form_0
   ACTIVATE WINDOW Form_0

RETURN NIL

//////////////////////////////////////////////////////////////////
PROCEDURE CorrectionFirstLast( oBrw )

   IF &oBrw:nRowCount() == &oBrw:nRowPos()
      &oBrw:Refresh( .F. )
   ENDIF

   IF &oBrw:nLogicPos() > 0 .and. &oBrw:nRowPos() == 1
      &oBrw:Refresh( .F. )
   ENDIF

RETURN

//////////////////////////////////////////////////////////////////
FUNCTION ResizeBrowse()
LOCAL cForm := _HMG_ThisFormName
LOCAL hWnd := GetFormHandle(cForm)
LOCAL nHStBar := GetWindowHeight(GetControlHandle('STATUSBAR', cForm)) // height StatusBar 
// By the method Move() starts ReSize(), which starts at the end of the code block bResized
oBrw:Move( oBrw:nLeft ,oBrw:nTop , GetClientWidth(hWnd), ;
                                   GetClientHeight(hWnd) - nHStBar - oBrw:nTop, .t.)
Eval(oBrw:bInit) // read the second column of the table
oBrw:Paint()     // redraw the vertical and horizontal scrolling
CorrectionFirstLast("oBrw")
MyToolBar(.T.)  // redraw button 

Return Nil

////////////////////////////////////////////////////////////
STATIC FUNCTION MyChangeBrowse(oBrw)
   LOCAL cVal := HB_NToS( &oBrw:nAt ) + ' / ' + HB_NToS( &oBrw:nLen )
   //oBrw:nAt - the current line number
   //oBrw:nCell - current column number
   //oBrw:nLen - total number of records in the database
   Form_0.StatusBar.Item(3) := " Recno: " + cVal
   Form_0.oBrw.Setfocus

 RETURN Nil

///////////////////////////////////////////////////////////////////
FUNCTION MyToolBar(lHideShow)  // buttons 
   LOCAL nWinWidth  := ThisWindow.Width
   LOCAL nWinHeight := ThisWindow.Height
   LOCAL cForm := _HMG_ThisFormName
   LOCAL aObj2But, nI, cObject
   LOCAL aFontColor := WHITE, aTbrColor
   LOCAL nLenButt := 84                            // width button 
   LOCAL nHButt   := 28                            // height button 
   LOCAL nRow1    := 5                             // indentation on top of the button 
   LOCAL nCol1, nCol2, nCol3, nCol4, nCol5, nCol6  // button on the X
   LOCAL nLenBut2 := nLenButt/2                    // the width of the button-2 
   DEFAULT lHideShow := .F.

   nCol1 := nWinWidth-16-nLenButt-5     ; nCol2 := nWinWidth-16-nLenButt*2-5*2 
   nCol3 := nWinWidth-16-nLenButt*3-5*3 ; nCol4 := nWinWidth-16-nLenButt*4-5*4 
   nCol5 := nWinWidth-16-nLenButt*5-5*6 + nLenBut2 ; nCol6 := nWinWidth-16-nLenButt*5-5*7 
   // ------------------- a list of all the buttons ---------------------------------------------------
   aObj2But := { ;
               {"oBut_Exit" ,nRow1,nCol1,nLenButt,nHButt,"Exit" ,MAROON,{|| ReleaseAllWindows()                                    } ,''                      }, ;
               {"oBut_Color",nRow1,nCol2,nLenButt,nHButt,"Color",BLUE  ,{|| aTbrColor := Form_color() , TbrUpColor(oBrw,aTbrColor) } ,'Change color TBROWSE'  }, ;
               {"oBut_Font" ,nRow1,nCol3,nLenButt,nHButt,"Fonts",LGREEN,{|| NewFonts(oBrw)    , Form_0.oBrw.SetFocus               } ,'Change fonts TBROWSE'  }, ;
               {"oBut_About",nRow1,nCol4,nLenButt,nHButt,"About",ORANGE,{|| MsgAbout()        , Form_0.oBrw.SetFocus               } ,'About the program'     }, ;
               {"oBut_Del"  ,nRow1,nCol5,nLenBut2,nHButt,"Del"  ,GRAY  ,{|| RecnoDelete(oBrw) , Form_0.oBrw.SetFocus               } ,'Delete a record'       }, ;
               {"oBut_Ins"  ,nRow1,nCol6,nLenBut2,nHButt,"Ins"  ,GRAY  ,{|| RecnoInsert(oBrw) , Form_0.oBrw.SetFocus               } ,'A new record'          }  ;
               }

IF lHideShow == .F.  // first built all the buttons on the form

   FOR nI := 1 TO LEN(aObj2But) // ----------- withdrawal of all buttons -----------
       cObject := aObj2But[nI,1]+str(nI,1)
       @ aObj2But[nI,2],aObj2But[nI,3] BUTTONEX &cObject ;
         PARENT &cForm                                   ;
         WIDTH aObj2But[nI,4] HEIGHT aObj2But[nI,5]      ;
         CAPTION aObj2But[nI,6]           ;
         ACTION  DoAction( Val(Right(this.name, 1)), aObj2But ) ;
         NOHOTLIGHT NOXPSTYLE             ;
         FONTCOLOR aFontColor             ;
         BACKCOLOR aObj2But[nI,7]         ;
         TOOLTIP aObj2But[nI,9]           ;
         HANDCURSOR                       ;
         SIZE 10 BOLD                     
   NEXT

   AEVAL( aObj2But, {|x| AADD(aToolBtn, x[1])} )

ELSE

   // ----------- hide all buttons -----------
   FOR nI := 1 TO LEN(aObj2But)
       cObject := aObj2But[nI,1]+str(nI,1)
       SetProperty(ThisWindow.Name, cObject, "Visible", .F.) 
   NEXT
   // ----------- show all buttons -----------
   FOR nI := 1 TO LEN(aObj2But)
       cObject := aObj2But[nI,1]+str(nI,1)
       SetProperty(ThisWindow.Name, cObject, "Row"  , aObj2But[nI,2] ) 
       SetProperty(ThisWindow.Name, cObject, "Col"  , aObj2But[nI,3] ) 
       SetProperty(ThisWindow.Name, cObject, "Visible", .T.) 
   NEXT

ENDIF // lHideShow == .F.  

RETURN nHButt + nRow1*2  // Returns start on Y for TBROWSE 
/////////////////////////////////////////////////////////////////////////////////////////
function DoAction( nMode, aBut )
   LOCAL bAction := aBut[nMode,8]

   Eval(bAction)

return nil

////////////////////////////////////////////////////////////////////////////////////////
// Text / Background Color on the condition to display a table row
STATIC FUNCTION ConditionLinesColor(nText,nBack)
LOCAL aClr2Usl:={}, nI, aRet2Color:={}
LOCAL cPoleOne, cPoleTwo, cMsg
LOCAL nBlack := MyRGB( BLACK ), nGray := MyRGB( GRAY )
LOCAL nRed   := MyRGB( RED   ), nBlue := MyRGB( BLUE )
LOCAL nYell  := MyRGB( YELLOW), nWhit := MyRGB( WHITE )
LOCAL nRed2  := MyRGB( {235, 117, 123} ) // bright red

nWhit := IIF(nBack == nWhit, MyRGB(PURPLE), nWhit )

cPoleOne := ALIAS()+"->NEVENT"
cPoleTwo := ALIAS()+"->EVENT"
// -------------------------- Conditions rows show ------------------------------------
AADD(aClr2Usl, { { || DELETED()                      } , { nBlack, nGray } } ) // black/gray
AADD(aClr2Usl, { { || &(cPoleOne) == 0               } , {  nRed2, 255   } } ) // bright red/red
AADD(aClr2Usl, { { || &(cPoleOne) == 1               } , {  nBack, nWhit } } ) // background/White
AADD(aClr2Usl, { { || &(cPoleOne) == 2               } , {  nBack, nYell } } ) // background/yellow
AADD(aClr2Usl, { { || &(cPoleOne) == 3               } , {  nBack, nRed  } } ) // background/red - error!
AADD(aClr2Usl, { { || &(cPoleOne) == 4               } , {  nBack, nGray } } ) // background/gray - removal!
AADD(aClr2Usl, { { || &(cPoleOne) == 5               } , {  nBack, nBlue } } ) // background/blue   
AADD(aClr2Usl, { { || LEN(ALLTRIM(&(cPoleTwo))) == 0 } , {  nRed2, 128   } } ) // bright red/red
AADD(aClr2Usl, { { || 1 == 1                         } , { nBack , nText } } ) // background/text - other records
cMsg := " &("+cPoleOne + " ) == 0               }" + CRLF
cMsg += "LEN(ALLTRIM(&("+cPoleTwo+"))) == 0 }" + CRLF
//MsgInfo(cMsg)  // проверка

IF Len(aClr2Usl) > 0
   For nI := 1 to len(aClr2Usl)
     if eval(aClr2Usl[nI,1])
        Aadd(aRet2Color,aClr2Usl[nI,2,1])
        Aadd(aRet2Color,aClr2Usl[nI,2,2])
        Exit
     endif
   next
ENDIF

RETURN aRet2Color
////////////////////////////////////////////////////////////////////
// Functions of the color conversion
FUNCTION MyRGB(aDim)
   RETURN RGB(aDim[1],aDim[2],aDim[3])

/////////////////////////////////////////////////////////////////////////////////////////
// Function read color TBROWSE
FUNCTION TbrUpColor(oBrw,aTbrColor) 
  LOCAL nI, nJ, nTextColor, nBackColor 

  IF LEN(aTbrColor) > 0

     // ------ restore color TBROWSE ------------
     FOR nI := 1 TO LEN(aTbrColor)
       FOR nJ := 1 to LEN(oBrw:aColumns)  // change the color of all columns
         IF !((nI = 16 .OR. nI = 17) .AND. nJ > Len( oBrw:aSuperHead))
             oBrw:Setcolor( { nI }, { aTbrColor[nI] }, nJ )
         ENDIF
       NEXT
     NEXT
     // ------ restore color and SUPERHINDER ----------
     oBrw:Setcolor( { 16 }, { aTbrColor[16] } , 0 )
     oBrw:Setcolor( { 17 }, { aTbrColor[17] }, 0 )
     oBrw:Refresh(.T.)

     // ------ Remember two current colors for the ini file -------------
     M->nTbrwColorText := aTbrColor[1] ; M->nTbrwColorPane := aTbrColor[2] 
     // ------ Consider the current color display rows in a table ----------
     nTextColor := oBrw:nClrText  // Color of text in the table cells
     nBackColor := aTbrColor[2]   // oBrw:nClrPane  // The background color in the table cells
     // ------ Set a new color display rows in a table ----------
     oBrw:SetColor( { 1 }, { { || ConditionLinesColor(nTextColor,nBackColor)[2]}}) 
     oBrw:SetColor( { 2 }, { { || ConditionLinesColor(nTextColor,nBackColor)[1]}}) 

  ENDIF
  Form_0.oBrw.SetFocus

RETURN Nil 

/////////////////////////////////////////////////////////////////////////////////////////
// Function: menu button "Fonts"
FUNCTION NewFonts(oBrw)
   LOCAL aTbrFonts
   
   aTbrFonts := LoadTbrwFonts(oBrw)     // view fonts from TBROWSE
   aTbrFonts := Form_fonts(aTbrFonts)   // Form for changing fonts -> Form_fonts.prg
   TbrUpFonts(oBrw,aTbrFonts)           // update the fonts in TBROWSE

RETURN Nil 
/////////////////////////////////////////////////////////////////////////////////////////
// Function: read fonts TBROWSE
FUNCTION TbrUpFonts(oBrw,aTbrFonts) 
  LOCAL nI, nEle, hFont, aF, cFontName

  IF LEN(aTbrFonts) > 0
     FOR nI := 1 TO 5
        aF := aTbrFonts[nI]
        cFontName := "Font_" + hb_ntos( _GetId() )
        _DefineFont( cFontName, aF[1], aF[2], aF[3], aF[4] )
        hFont := GetFontHandle( cFontName )
        IF nI = 5

         For nEle := 1 TO Len( oBrw:aColumns )
             oBrw:aColumns[ nEle ]:hFontEdit := hFont
         Next

        ELSE
           oBrw:ChangeFont( hFont, , nI )
        ENDIF
     NEXT
  ENDIF
  
  Form_0.oBrw.SetFocus

RETURN Nil 

/////////////////////////////////////////////////////////////////////////////////////////
// Function: considered established fonts TBrowse
// --------- TSCOLUMN.PRG -------------------------------
// DATA hFont          // 1-cells font
// DATA hFontHead      // 2-header font
// DATA hFontFoot      // 3-footer font
// DATA hFontSpcHd     // 4-special header font
// DATA hFontEdit      // 5-edition font
FUNCTION LoadTbrwFonts(oBrw)   
   LOCAL aFontTmp, hFont, aFonts := {}

    hFont := oBrw:aColumns[ 1 ]:hFont     // 1-cells font
    If hFont != Nil
       aFontTmp := GetFontParam(hFont)
       AADD( aFonts, aFontTmp )
    ENDIF

    hFont := oBrw:aColumns[ 1 ]:hFontHead  // 2-header font
    If hFont != Nil
       aFontTmp := GetFontParam(hFont)
       AADD( aFonts, aFontTmp )
    ENDIF

    hFont := oBrw:aColumns[ 1 ]:hFontFoot  // 3-footer font
    If hFont != Nil
       aFontTmp := GetFontParam(hFont)
       AADD( aFonts, aFontTmp )
    ENDIF

    hFont := oBrw:aSuperHead[ 1, 7 ]  // 4-special header font
    If hFont != Nil
       aFontTmp := GetFontParam(hFont)
       AADD( aFonts, aFontTmp )
    ENDIF

    hFont := oBrw:aColumns[ 1 ]:hFontEdit   // 5-edition font
    If hFont != Nil
       aFontTmp := GetFontParam(hFont)
       AADD( aFonts, aFontTmp )
    ENDIF

    // ---- Remember font editing window for memo fields ----
    M->aFontEdit := GetFontParam(hFont)

RETURN aFonts

//////////////////////////////////////////////////////////////////////////////
// Function: add a record to the database
FUNCTION RecnoInsert() 
    LOCAL nI, cMemo := "Test Insert Recno !" + CRLF
    FOR nI := 0 TO 5
        cMemo += ProcName(nI) + "(" +HB_NtoS(procline(nI))+")" + CRLF
    NEXT
    // write to database log
    DbfLogWrite(1,'...',ProcName()+';'+HB_NtoS(procline()),1, "Test - Insert records !" ,'Success - Ins',cMemo) 
    oBrw:nLen := GetCountUnderFilter()
    oBrw:nAt := 5
    oBrw:Refresh(.T.)
    MyChangeBrowse("oBrw")

  RETURN Nil

//////////////////////////////////////////////////////////////////////////////
// Function: delete a record from a database
FUNCTION RecnoDelete(oBrw) 
    LOCAL nI, cMemo := "Test Delete Recno !" + CRLF
    LOCAL cEvent := "Recno "+HB_NtoS(RECNO())+" delete. DB: " + ALIAS()
    FOR nI := 0 TO 5
        cMemo += ProcName(nI) + "(" +HB_NtoS(procline(nI))+")" + CRLF
    NEXT

IF MsgYesNo( "Delete record from database ?", "Remove", .f. )
  IF (oBrw:cAlias)->(RLock())    
     (oBrw:cAlias)->(DbDelete())
     // write to database log
     DbfLogWrite(1,'...',ProcName()+';'+HB_NtoS(procline()),4, cEvent,'Success - Delete',cMemo) 
     oBrw:nLen := GetCountUnderFilter()
     oBrw:nAt := 5
     oBrw:Refresh(.T.)
     MyChangeBrowse("oBrw")
  ELSE
     MsgInfo("Account is locked !")
  ENDIF
ENDIF

RETURN Nil

//////////////////////////////////////////////////////////////////////////////
// Function: Enable/Disable display of deleted records
Static FUNCTION RecnoViewDel(lVal)
    LOCAL cMsg

    IF lVal 
       SET DELETED OFF
       cMsg := "Included a display of deleted records !"
    ELSE
       SET DELETED ON
       cMsg := "Offline mode display of deleted records !"
    ENDIF
    MsgInfo(cMsg)

    oBrw:nLen := GetCountUnderFilter()
    // Adding one of SELECTOR (more columns)
    oBrw:aColumns[2]:cFooting := { || LTrim( Transform( oBrw:nLen, "### ###" ) ) }
    oBrw:aColumns[12]:cFooting := { || LTrim( Transform( GetCountFieldFilter("NFILE") , "999 999"    ) ) }
    oBrw:aColumns[13]:cFooting := { || LTrim( Transform( GetCountFieldFilter("NSIZE"), "999 999.999" ) ) }
    oBrw:DrawFooters()       // perform drawing basement

    oBrw:Refresh(.T.)
    MyChangeBrowse("oBrw")

    RETURN Nil

//////////////////////////////////////////////////////////////////////////////
// Function: Recover deleted record
Static FUNCTION RecnoRecovery()

IF MsgYesNo( "Recover deleted record from database ?", "Recovery", .f. )
  IF (oBrw:cAlias)->( RLock() )    
     (oBrw:cAlias)->( DbRecall() )
     oBrw:nLen := GetCountUnderFilter()
     oBrw:Refresh(.T.)
  ELSE
     MsgInfo("Account is locked!")
  ENDIF
ENDIF

RETURN Nil

///////////////////////////////////////////////////////////////////////////////////////////
// Function: calculating the sum of the field by the condition of the filter
FUNCTION GetCountFieldFilter(cField) 
    LOCAL cAlias := oBrw:cAlias
    LOCAL nLen := 0, nRec := ( cAlias )->( RecNo() )

    ( cAlias )->( DbEval( { || nLen += &(cField) }, &("{||" + ( cAlias )->( DbFilter() ) + "}") ) )
    ( cAlias )->( DbGoTo( nRec ) )

  RETURN nLen

///////////////////////////////////////////////////////////////////////////////////////////
// Function: counting the total number of records on the condition of the filter
FUNCTION GetCountUnderFilter() 
    LOCAL cAlias := oBrw:cAlias
    LOCAL nLen := 0, nRec := ( cAlias )->( RecNo() )

    ( cAlias )->( DbEval( { || nLen++ }, &("{||" + ( cAlias )->( DbFilter() ) + "}") ) )
    ( cAlias )->( DbGoTo( nRec ) )

  RETURN nLen

///////////////////////////////////////////////////////////////////////////////////////////
// SergKis  http://clipper.borda.ru/?1-1-0-00000389-000-0-1-1408089634
// 
// GETCLIENTHEIGHT (0) - the height of the client (internal) region Desktop based on the availability line Start
// GETCLIENTWIDTH (0) - the width of the client (internal) region Desktop
// GETCLIENTHEIGHT (hWnd) - the height of the client (internal) area of the window (or control)
// GETCLIENTWIDTH (hWnd) - width of the client (internal) area of the window (or control)
// le:
// hWnd := GetFormHandle('Form_0')
// CreateBrowse( "oBrw_1", 'Form_0', 32, 2, GetClientWidth(hWnd), GetClientHeight(hWnd), 'LOG_DBF' )

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( GETCLIENTWIDTH )
{
   RECT rect;

   GetClientRect( ( HWND ) hb_parnl(1), &rect );
   hb_retni( ( int ) rect.right - rect.left );
}

HB_FUNC( GETCLIENTHEIGHT )
{
   RECT rect;

   GetClientRect( ( HWND ) hb_parnl(1), &rect );
   hb_retni( ( int ) rect.bottom - rect.top );
}

#pragma ENDDUMP
