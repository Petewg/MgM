*******************************************************************************
* PROGRAMA: DYNAMIC GRID 
* LENGUAJE: MiniGUI Extended 2.1.4
* FECHA:    Agosto 2012
* AUTOR:    Dr. CLAUDIO SOTO
* PAIS:     URUGUAY
* E-MAIL:   srvet@adinet.com.uy
* BLOG:     http://srvet.blogspot.com
*******************************************************************************


// DESCRIPTION
*******************************************************************************
* DYNAMIC_GRID.PRG 
* Modification of a GRID control at runtime: 
*    # INSERT different types of COLUMNS (NUMERIC,CHARACTER,DATEPICKER,COMBOBOX,SPINNER,CHECKBOX, etc.)
*    # DELETE and MOVE columns and rows
*    # CHANGE specific COLUMN CONTROL.
*    # INSERT background IMAGE in Grid
*******************************************************************************


// GRID_CONTROLS_EX.prg
**********************************************************************************
* GRID_ColumnCount         ---> Return the Number of Column on GRID
*
* GRID_AddColumnEx         ---> Complement of Method:  AddColumn (nColIndex)
* GRID_DeleteColumnEx      ---> Complement of Method:  DeleteColumn (nColIndex)
*
* GRID_GetColumnControlsEx ---> Return Array with Controls of Column(nColIndex) ==> {cCAPTION, nWIDTH, nJUSTIFY, aCOLUMNCONTROL, bDYNAMICBACKCOLOR, bDYNAMICFORECOLOR, bCOLUMNWHEN, bCOLUMNVALID, bONHEADCLICK}
*
* GRID_GetColumnControl    ---> Return specific Control of Column(nColIndex) ==> [cCAPTION, nWIDTH, nJUSTIFY, aCOLUMNCONTROL, bDYNAMICBACKCOLOR, bDYNAMICFORECOLOR, bCOLUMNWHEN, bCOLUMNVALID, bONHEADCLICK]
* GRID_SetColumnControl    ---> Set specific Control of Column(nColIndex)    ==> [cCAPTION, nWIDTH, nJUSTIFY, aCOLUMNCONTROL, bDYNAMICBACKCOLOR, bDYNAMICFORECOLOR, bCOLUMNWHEN, bCOLUMNVALID, bONHEADCLICK]
*
* GRID_GetColumnDisplayPos ---> Get the position of Column(nColIndex) in that display in the GRID
* GRID_SetColumnDisplayPos ---> Set the position of Column(nColIndex) in that display in the GRID
*
* GRID_GetColumnWidthDisplay -> Get the Width of Column(nColIndex) in that display in the GRID
*
* GRID_SetBkImage          ---> Set background image in Grid
**********************************************************************************


// ARRAY_FUNC.prg
*******************************************************************************
* ARRAY_CHANGE (nAction, aData, nIndex, [nPos | DataAdd])      --> Move/Add/Remove: COLUMN or ROW in Array 
* ARRAY_GRID   (cControlName, cParentForm, nAction, aGridData) --> Get/Add: data in GRID 
*******************************************************************************

*** CONSTANTS (nControl) ***
#Define _GRID_COLUMNCAPTION_    -1   // _HMG_aControlPageMap   [i]
#Define _GRID_ONHEADCLICK_      -2   // _HMG_aControlHeadClick [i]
#Define _GRID_COLUMNWIDTH_       2   // _HMG_aControlMiscData1 [i,2]
#Define _GRID_COLUMNJUSTIFY_     3   // _HMG_aControlMiscData1 [i,3]
#Define _GRID_DYNAMICFORECOLOR_ 11   // _HMG_aControlMiscData1 [i,11]
#Define _GRID_DYNAMICBACKCOLOR_ 12   // _HMG_aControlMiscData1 [i,12]
#Define _GRID_COLUMNCONTROLS_   13   // _HMG_aControlMiscData1 [i,13]
#Define _GRID_COLUMNVALID_      14   // _HMG_aControlMiscData1 [i,14]
#Define _GRID_COLUMNWHEN_       15   // _HMG_aControlMiscData1 [i,15]

// CONSTANTS -->  GRID_SetBkImage (nAction)
#define _GRID_SETBKIMAGE_NONE_   0
#define _GRID_SETBKIMAGE_NORMAL_ 1
#define _GRID_SETBKIMAGE_FILL_   2

// CONSTANTS --> ARRAY_CHANGE (nAction)
#define _ARRAY_MOVE_ROW_    1
#define _ARRAY_MOVE_COL_    2
#define _ARRAY_ADD_ROW_     3
#define _ARRAY_ADD_COL_     4
#define _ARRAY_REMOVE_ROW_  5
#define _ARRAY_REMOVE_COL_  6

// CONSTANTS -->  ARRAY_GRID (nAction)
#define _ARRAY_GRID_ADD_DATA_  1
#define _ARRAY_GRID_GET_DATA_  2


#include <hmg.ch>

****************************************************************************
Set Procedure To GRID_CONTROLS_EX.prg
Set Procedure To ARRAY_FUNC.prg
****************************************************************************

MEMVAR aColor
MEMVAR aWidths
MEMVAR aJustify
MEMVAR bDynamicBackColor
MEMVAR aColumnControls        
MEMVAR data
MEMVAR aTypeControls
MEMVAR aGrid_Data
MEMVAR aGrid_CTRL
MEMVAR hBitmap
MEMVAR cHeader, aDynamicForeColor


****************************************************************************
FUNCTION Main
LOCAL k

    SET DATE TO BRITISH

    PRIVATE aColor := {"{0,0,230}", "{0,150,0}", "{220,220,0}", "{128,64,64}", "{128,0,128}", "{255,128,64}"}
    PRIVATE aWidths  := {100,100,120,80,80,80}
    PRIVATE aJustify := {GRID_JTFY_RIGHT,GRID_JTFY_RIGHT,GRID_JTFY_CENTER,GRID_JTFY_RIGHT,GRID_JTFY_RIGHT,GRID_JTFY_CENTER}
    PRIVATE bDynamicBackColor := {|| IF (This.CellRowIndex/2 == int(This.CellRowIndex/2), {222,222,222}, {192,192,192})} 

    PRIVATE aColumnControls:= { {'TEXTBOX','NUMERIC','$ 999,999.99'},;                
                            {'TEXTBOX','CHARACTER'} ,;		   		       
		            {'DATEPICKER','DROPDOWN'} ,;
                            {'COMBOBOX',{'One','Two','Three'}} ,;
                            {'SPINNER', 0 , 20 } ,;
                            {'CHECKBOX', 'Yes' , 'No' } }                              

    PRIVATE data := {100.50, "HMG", CTOD("07/08/2012"), 1, 0, .T.}  // Default data of aColumnControls 
    PRIVATE aTypeControls := {'NUMERIC','CHARACTER','DATEPICKER','COMBOBOX','SPINNER','CHECKBOX'} 
    PRIVATE aGrid_Data := {}
    PRIVATE aGrid_CTRL := {0}

    PRIVATE hBitmap := 0

    DEFINE WINDOW Win1 ;
		AT 0,0 ;
		WIDTH 800-5 HEIGHT 600-25 ;		
		TITLE "Dynamic Grid" ;
		MAIN ;
		NOMAXIMIZE NOSIZE

        DEFINE MAIN MENU
               POPUP "ADD Column"
                  MENUITEM "NUMERIC"    ACTION DYNAMIC_Col (1,1)
                  MENUITEM "CHARACTER"  ACTION DYNAMIC_Col (1,2)
                  MENUITEM "DATEPICKER" ACTION DYNAMIC_Col (1,3)
                  MENUITEM "COMBOBOX"   ACTION DYNAMIC_Col (1,4)
                  MENUITEM "SPINNER"    ACTION DYNAMIC_Col (1,5)
                  MENUITEM "CHECKBOX"   ACTION DYNAMIC_Col (1,6)
               END POPUP

               POPUP "CHANGE Column 1"
                  MENUITEM "Caption"            ACTION DYNAMIC_Change (1)
                  MENUITEM "Justify"            ACTION DYNAMIC_Change (2)
                  MENUITEM "Width"              ACTION DYNAMIC_Change (3)
                  MENUITEM "OnHeadClick"        ACTION DYNAMIC_Change (4)
                  MENUITEM "DynamicForeColor"   ACTION DYNAMIC_Change (5)
                  MENUITEM "DynamicBackColor"   ACTION DYNAMIC_Change (6)
                  MENUITEM "EditControl"        ACTION DYNAMIC_Change (7)
               END POPUP

               POPUP "IMAGE"
                  MENUITEM "IMAGE Normal 1" ACTION GRID_SetBkImage ("Grid1", "Win1", _GRID_SETBKIMAGE_NORMAL_, "FONDO.bmp", 0, 0)
		  MENUITEM "IMAGE Normal 2" ACTION GRID_SetBkImage ("Grid1", "Win1", _GRID_SETBKIMAGE_NORMAL_, "HMG.bmp", 30, 50)
		  MENUITEM "IMAGE Fill"     ACTION GRID_SetBkImage ("Grid1", "Win1", _GRID_SETBKIMAGE_FILL_,   "HMG.bmp",  0,  0)
		  MENUITEM "IMAGE None"     ACTION GRID_SetBkImage ("Grid1", "Win1", _GRID_SETBKIMAGE_NONE_,   "",         0,  0)
               END POPUP

        END MENU

        DEFINE GRID Grid1
               ROW		50
               COL		20 
               WIDTH		735
               HEIGHT		250
               FONTNAME 	"Times New Roman"
               FONTSIZE 	14
               FONTBOLD 	.F.
               FONTCOLOR    	BLUE 
               BACKCOLOR	{222,222,222} 
               HEADERS		{"Row"} 
               WIDTHS		{100}          
               COLUMNWHEN   	{{|| .F.}}						   
               COLUMNCONTROLS 	{{"TEXTBOX","NUMERIC","99999",NIL}} 
               DYNAMICFORECOLOR {{|| RED}}
               DYNAMICBACKCOLOR {bDynamicBackColor}
               CELLNAVIGATION 	.T.
               ALLOWEDIT	.T.
               JUSTIFY 		{GRID_JTFY_LEFT}                           		   
        END GRID                         

    	@ 330, 175 BUTTON Button_1 CAPTION "UP Row"    BOLD ACTION MOVE_Row (1)
	@ 380, 175 BUTTON Button_2 CAPTION "DOWN Row"  BOLD ACTION MOVE_Row (2)

        @ 450, 100 BUTTON Button_3 CAPTION "ADD Row"  BOLD ACTION DYNAMIC_Row (1)
        @ 450, 250 BUTTON Button_4 CAPTION "DEL Row"  BOLD ACTION DYNAMIC_Row (2)

	@ 450, 600 BUTTON Button_5 CAPTION "DEL Column"   BOLD ACTION DYNAMIC_Col (2)
	@ 350, 545 BUTTON Button_6 CAPTION "<< LEFT Col"  BOLD ACTION MOVE_Col (1)
	@ 350, 655 BUTTON Button_7 CAPTION "RIGHT Col >>" BOLD ACTION MOVE_Col (2)

        @  10, 655 BUTTON Button_8 CAPTION "GET Cell Info" BOLD ACTION Get_Info ()

    END WINDOW

    FOR k = 1 TO 8
        DYNAMIC_Row (1)
    NEXT
    FOR k = 1 TO 6
        DYNAMIC_Col (1,k)
    NEXT
    Win1.Grid1.Value := { 1 , 1 }

    Win1.CENTER
    Win1.ACTIVATE
RETURN NIL


****************************************************************************
PROCEDURE Get_Info
LOCAL aux, Text
LOCAL Grid_row
LOCAL Grid_col

   aux := Win1.Grid1.Value
   Grid_row := aux[1]
   Grid_col := aux[2]

   IF Grid_row >= 1 .AND. Grid_row <= Win1.Grid1.Itemcount .AND. Grid_col >= 1 .AND. Grid_col <= GRID_ColumnCount ("Grid1","Win1")
	  Text := "GRID Row:        " + STR (Grid_row) +CHR(13)+CHR(10)
	  Text += "GRID Col:        " + STR (Grid_col) +CHR(13)+CHR(10)
	  Text += "Pos. Disp. Col:  " + STR (GRID_GetColumnDisplayPos ("Grid1", "Win1", Grid_Col)) +CHR(13)+CHR(10)
	  Text += "Width Col Disp.: " + STR (GRID_GetColumnWidthDisplay ("Grid1", "Win1", Grid_Col)) +CHR(13)+CHR(10)
	  MsgInfo (Text,"Current Cell Info")
   ENDIF
RETURN


****************************************************************************
PROCEDURE DYNAMIC_Change (action)
LOCAL nCol, i

   nCol := 1

   DO CASE
      CASE action = 1
           GRID_SetColumnControl ("Grid1", "Win1", _GRID_COLUMNCAPTION_,    nCol, "# ROW #")
      CASE action = 2
           GRID_SetColumnControl ("Grid1", "Win1", _GRID_COLUMNJUSTIFY_,    nCol, GRID_JTFY_CENTER)                     
      CASE action = 3
           GRID_SetColumnControl ("Grid1", "Win1", _GRID_COLUMNWIDTH_,      nCol, 150) 
      CASE action = 4
           GRID_SetColumnControl ("Grid1", "Win1", _GRID_ONHEADCLICK_,      nCol, {||msginfo(GRID_GetColumnControl ("Grid1", "Win1", _GRID_COLUMNCAPTION_, 1))}) 
      CASE action = 5
           GRID_SetColumnControl ("Grid1", "Win1", _GRID_DYNAMICFORECOLOR_, nCol, {|| BLUE})
      CASE action = 6
           GRID_SetColumnControl ("Grid1", "Win1", _GRID_DYNAMICBACKCOLOR_, nCol, {|| YELLOW})
      CASE action = 7
           GRID_SetColumnControl ("Grid1", "Win1", _GRID_COLUMNCONTROLS_,   nCol, {'TEXTBOX','NUMERIC','9999.99'})     
                         		          
	   ***********************************************************************
	   * This change only has effect when write in the items (in any column) *
	   ***********************************************************************		   
           FOR i = 1 TO Win1.Grid1.ItemCount
              Win1.Grid1.Cell (i,nCol) := Win1.Grid1.Cell (i,nCol)      // Force the rewrite in the item
	   NEXT

   ENDCASE     
   Win1.Grid1.Refresh
RETURN


****************************************************************************
PROCEDURE MOVE_Col (action)
LOCAL aux, nCol_Disp
LOCAL Grid_col

    IF Win1.Grid1.Itemcount = 0
	RETURN
    ENDIF

    aux := Win1.Grid1.Value
    Grid_col := aux[2]

    IF Grid_col < 1 .OR. Grid_col > GRID_ColumnCount ("Grid1","Win1")
       RETURN
    ENDIF

    nCol_Disp := GRID_GetColumnDisplayPos ("Grid1", "Win1", Grid_Col)

    IF action = 1
       nCol_Disp --  // Move column: LEFT
    ELSE
       nCol_Disp ++  // Move column: RIGHT
    ENDIF

    IF nCol_Disp >= 1 .AND. nCol_Disp <= GRID_ColumnCount ("Grid1","Win1")
       GRID_SetColumnDisplayPos ("Grid1", "Win1", Grid_Col, nCol_Disp)
    ENDIF

    Win1.Grid1.Refresh
RETURN


****************************************************************************
PROCEDURE MOVE_Row (action)
LOCAL aux, aItem
LOCAL Grid_row, Old_Grid_row
LOCAL Grid_col

   aux := Win1.Grid1.Value
   Grid_row := aux[1]
   Grid_col := aux[2]

   IF Win1.Grid1.Itemcount <= 1 .OR. Grid_row > Win1.Grid1.Itemcount
      RETURN
   ENDIF

   IF (action = 1 .AND. Grid_row <= 1) .OR. (action = 2 .AND. Grid_row >= Win1.Grid1.Itemcount)
      RETURN
   ENDIF

   Old_Grid_row := Grid_row
   aItem := Win1.Grid1.Item (Old_Grid_row)
   IF action = 1 // Move row: UP
      Grid_row --
   ELSE          // Move row: DOWN
      Grid_row ++
   ENDIF

   Win1.Grid1.Item (Old_Grid_row) := Win1.Grid1.Item (Grid_row)
   Win1.Grid1.Item (Grid_row)     := aItem
       
   Win1.Grid1.Value := {Grid_row, Grid_Col} // Update new position of cursor
RETURN


****************************************************************************
PROCEDURE DYNAMIC_Col (action, i)
STATIC cont := 1, bColumnWhen
LOCAL aux
LOCAL Grid_row
LOCAL Grid_col
LOCAL ctrl1, bColumnValid

    ARRAY_GRID ("Grid1", "Win1", _ARRAY_GRID_GET_DATA_, aGrid_Data)

    IF GRID_ColumnCount ("Grid1","Win1") = 1
      cont := 1
    ENDIF

    IF action = 1  // GRID Column: INSERT

       aux := Win1.Grid1.Value
       Grid_row := aux[1]

       Grid_col := GRID_ColumnCount ("Grid1","Win1")
       Grid_col++
       cont++

       Win1.Grid1.AddColumn (Grid_col, "Col_"+ALLTRIM(STR(cont)), aWidths[i], aJustify[i])

       ctrl1 := aColumnControls [i]
       bColumnValid := IF (i=1, {||IF(This.CellValue >= 0,.T.,.F.)}, NIL)
       bColumnWhen := {|| .T.}
       cHeader := CHR(34) + "Click Header -> " + Win1.Grid1.Header(Grid_col)+ "  " + aTypeControls [i] + CHR(34)
       aDynamicForeColor := aColor[i]

       GRID_AddColumnEx ("Grid1", "Win1", Grid_col, ctrl1, bDynamicBackColor, {|| &aDynamicForeColor}, bColumnWhen, bColumnValid, {|| MsgInfo(&cHeader)})

       IF LEN (aGrid_Data) > 0
          ARRAY_CHANGE (_ARRAY_ADD_COL_, aGrid_Data, Grid_col, data [i])
       ENDIF

       Win1.Grid1.Visible := .F.
       ARRAY_GRID ("Grid1", "Win1", _ARRAY_GRID_ADD_DATA_, aGrid_Data)
       Win1.Grid1.Visible := .T.

       ARRAY_CHANGE (_ARRAY_ADD_ROW_, aGrid_CTRL, Grid_col, i)   	   
       Win1.Grid1.Value := {Grid_Row, Grid_Col} // Update new position of cursor

    ELSE  // GRID Column: DELETE

       IF Win1.Grid1.Itemcount = 0
          RETURN
       ENDIF
       aux := Win1.Grid1.Value
       Grid_row := aux[1]
       Grid_col := aux[2]
       
       IF Grid_col = 1
          MsgInfo ("Can't be deleted: Column One")
          RETURN
       ENDIF

       IF Grid_col >= 1 .AND. Grid_col <= GRID_ColumnCount ("Grid1","Win1")      
          IF MsgOkCancel ("DELETE COLUMN: "+Win1.Grid1.Header(Grid_Col)) = .T.
            Win1.Grid1.DeleteColumn (Grid_Col)
            GRID_DeleteColumnEx ("Grid1","Win1", Grid_Col)

            IF LEN (aGrid_Data) > 0
               ARRAY_CHANGE (_ARRAY_REMOVE_COL_, aGrid_Data, Grid_col)
               ARRAY_CHANGE (_ARRAY_REMOVE_ROW_, aGrid_CTRL, Grid_col)
            ENDIF

            Win1.Grid1.Visible := .F.
            ARRAY_GRID ("Grid1", "Win1", _ARRAY_GRID_ADD_DATA_, aGrid_Data)
            Win1.Grid1.Visible := .T.

            IF Grid_Col > GRID_ColumnCount ("Grid1","Win1")
               Win1.Grid1.Value := {Grid_row, GRID_ColumnCount ("Grid1","Win1")} // Update position of cursor if last column is delete
            ENDIF
          ENDIF
       ENDIF

    ENDIF

    Win1.Grid1.Refresh
RETURN


****************************************************************************
PROCEDURE DYNAMIC_Row (action)
STATIC cont := 0
LOCAL aux, k, aItem
LOCAL Grid_row
LOCAL Grid_col

     IF Win1.Grid1.ItemCount = 0
        cont := 0
     ENDIF

     IF action = 1  // GRID Row: INSERT

        aux := Win1.Grid1.Value
        Grid_col := aux[2]
        cont++
        aItem := ARRAY (GRID_ColumnCount ("Grid1","Win1"))
        aItem [1] := cont
        FOR k = 2 TO LEN (aItem)
           aItem [k] := data [aGrid_CTRL [k]]
        NEXT
        Win1.Grid1.AddItem (aItem)
        Win1.Grid1.Value := {Win1.Grid1.ItemCount, Grid_Col}  // Update position of cursor

     ELSE  // GRID Row: DELETE

       aux := Win1.Grid1.Value
       Grid_row := aux[1]
       Grid_col := aux[2]
       IF Win1.Grid1.Itemcount > 0 .AND. Grid_Row > 0
          IF MsgOkCancel ("DELETE ITEM: "+str(Win1.Grid1.Cell(Grid_Row,1))) = .T.
             Win1.Grid1.DeleteItem (Grid_Row)
             IF Grid_Row > Win1.Grid1.ItemCount
                Win1.Grid1.Value := {Win1.Grid1.ItemCount, Grid_Col} // Update position of cursor if last item is delete
             ENDIF
             IF Grid_Row = 1
                Win1.Grid1.Value := {1, Grid_Col} // Update position of cursor if first item is delete
             ENDIF
          ENDIF
       ENDIF

     ENDIF

     Win1.Grid1.Refresh
RETURN
