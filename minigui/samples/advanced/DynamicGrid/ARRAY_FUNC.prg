// ******************************************************************************
// PROGRAMA: ARRAY_FUNC.prg
// LENGUAJE: MiniGUI Extended 2.1.4
// FECHA:    Agosto 2012
// AUTOR:    Dr. CLAUDIO SOTO
// PAIS:     URUGUAY
// E-MAIL:   srvet@adinet.com.uy
// BLOG:     http://srvet.blogspot.com
// ******************************************************************************

// DESCRIPTION
// ******************************************************************************
// ARRAY_CHANGE (nAction, aData, nIndex, [nPos | DataAdd])      --> Move/Add/Remove: COLUMN or ROW in Array
// ARRAY_GRID   (cControlName, cParentForm, nAction, aGridData) --> Get/Add: data in GRID
// ******************************************************************************

#include "minigui.ch"

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


***************************************************************************
FUNCTION ARRAY_CHANGE ( nAction, aData, nIndex, xData )

   LOCAL k, DataMove, nLength, nPos, DataAdd

   IF nAction = _ARRAY_ADD_ROW_ .OR. nAction = _ARRAY_ADD_COL_
      DataAdd := xData
   ELSE
      nPos := xData
   ENDIF

   // Action _ARRAY_xxx_COL_ in array of ONE dimension ---> equal Action _ARRAY_xxx_ROW_ in array of ONE dimension
   IF ValType ( aData[1 ] ) <> "A"
      nAction := IF ( nAction = _ARRAY_MOVE_COL_,   _ARRAY_MOVE_ROW_,   nAction )
      nAction := IF ( nAction = _ARRAY_ADD_COL_,    _ARRAY_ADD_ROW_,    nAction )
      nAction := IF ( nAction = _ARRAY_REMOVE_COL_, _ARRAY_REMOVE_ROW_, nAction )
   ENDIF

   DO CASE

   CASE nAction = _ARRAY_MOVE_ROW_
      DataMove :=  aData[nIndex ]
      ADel ( aData, nIndex )
      AIns ( aData, nPos )
      aData[nPos ] := DataMove


   CASE nAction = _ARRAY_MOVE_COL_
      FOR k = 1 TO Len ( aData )
         DataMove := aData[k ][nIndex ]
         ADel ( aData[k ], nIndex )
         AIns ( aData[k ], nPos )
         aData[k ][nPos ] := DataMove
      NEXT


   CASE nAction = _ARRAY_ADD_ROW_
      nLength := Len ( aData )
      ASize ( aData, nLength + 1 )
      AIns  ( aData, nIndex )
      IF ValType ( aData[1 ] ) == "A" // Array dimension: TWO
         aData[nIndex ] := Array ( nLength )
         FOR k = 1 TO Len ( aData[nIndex ] )
            IF ValType ( DataAdd ) == "A"
               aData[nIndex ][k ] := DataAdd[k ]
            ELSE
               aData[nIndex ][k ] := DataAdd
            ENDIF
         NEXT
      ELSE   // Array dimension: ONE
         aData[nIndex ] := DataAdd
      ENDIF


   CASE nAction = _ARRAY_ADD_COL_
      nLength := Len ( aData[1 ] )
      FOR k = 1 TO Len ( aData )
         ASize ( aData[k ], nLength + 1 )
         AIns ( aData[k ], nIndex )
      NEXT
      FOR k = 1 TO Len ( aData )
         IF ValType ( DataAdd ) == "A"
            aData[k ][nIndex ] := DataAdd[k ]
         ELSE
            aData[k ][nIndex ] := DataAdd
         ENDIF
      NEXT


   CASE nAction = _ARRAY_REMOVE_ROW_
      nLength := Len ( aData )
      ADel  ( aData, nIndex )
      ASize ( aData, nLength -1 )


   CASE nAction = _ARRAY_REMOVE_COL_
      nLength := Len ( aData[1 ] )
      FOR k = 1 TO Len ( aData )
         ADel ( aData[k ], nIndex )
         ASize ( aData[k ], nLength -1 )
      NEXT

   ENDCASE

RETURN aData


***************************************************************************
FUNCTION ARRAY_GRID ( cControlName, cParentForm, nAction, aGridData )

   LOCAL k

   IF ValType ( cParentForm ) == "U"
      cParentForm := ThisWindow.Name
   ENDIF

   DO CASE
   CASE nAction = _ARRAY_GRID_ADD_DATA_
      FOR k = 1 TO Len ( aGridData )
         DoMethod ( cParentForm, cControlName, "AddItem", aGridData[k ] )
      NEXT
   CASE nAction = _ARRAY_GRID_GET_DATA_
      ASize ( aGridData, GetProperty ( cParentForm, cControlName, "ItemCount" ) )
      FOR k = 1 TO Len ( aGridData )
         aGridData[k ] := GetProperty ( cParentForm, cControlName, "Item", k )
      NEXT
   ENDCASE

RETURN aGridData
