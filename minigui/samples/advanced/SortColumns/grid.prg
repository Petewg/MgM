/*
 * MiniGUI Grid Demo
 * (c) 2005 Roberto Lopez
 *
 * ListView SORT ORDER COLUMN 
 * Author: BADIK <badik@mail.ru>
*/

#include "minigui.ch"

Memvar fColor

Function Main

Local aRows [20] [3]

	Private fColor := { |x, CellRowIndex| if ( CellRowIndex/2 == int(CellRowIndex/2) , RGB( 0,0,255 ) , RGB( 0,255,0 ) ) }	

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 400 ;
		TITLE 'Mixed Data Type Grid Test' ;
		MAIN 

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Set New Columns Order'	ACTION SetOrder()
				MENUITEM 'Get Columns Order'		ACTION GetOrder()
				MENUITEM 'Refresh Grid'			ACTION Form_1.Grid_1.Refresh
				SEPARATOR
				MENUITEM 'Exit'				ACTION Form_1.Release
			END POPUP
		END MENU

		aRows [1]	:= { 113.12,Date(),1,1 , .t. }
		aRows [2]	:= { 123.12,Date(),2,2 , .f. } 
		aRows [3]	:= { 133.12,Date(),3,3, .t. } 
		aRows [4]	:= { 143.12,Date(),1,4, .f. } 
		aRows [5]	:= { 153.12,Date(),2,5, .t. } 
		aRows [6]	:= { 163.12,Date(),3,6, .f. } 
		aRows [7]	:= { 173.12,Date(),1,7, .t. } 
		aRows [8]	:= { 183.12,Date(),2,8, .f. } 
		aRows [9]	:= { 193.12,Date(),3,9, .t. } 
		aRows [10]	:= { 113.12,Date(),1,10, .f. } 
		aRows [11]	:= { 123.12,Date(),2,11, .t. } 
		aRows [12]	:= { 133.12,Date(),3,12, .f. } 
		aRows [13]	:= { 143.12,Date(),1,13, .t. } 
		aRows [14]	:= { 153.12,Date(),2,14, .f. } 
		aRows [15]	:= { 163.12,Date(),3,15, .t. } 
		aRows [16]	:= { 173.12,Date(),1,16, .f. } 
		aRows [17]	:= { 183.12,Date(),2,17, .t. } 
		aRows [18]	:= { 193.12,Date(),3,18, .f. } 
		aRows [19]	:= { 113.12,Date(),1,19, .t. } 
		aRows [20]	:= { 123.12,Date(),2,20, .f. } 

		@ 10,10 GRID Grid_1 ;
			WIDTH 620 ;
			HEIGHT 330 ;
			HEADERS {'Column 1','Column 2','Column 3','Column 4','Column 5'} ;
			WIDTHS {140,140,140,140,140} ;
			ITEMS aRows ;
			EDIT ;
			INPLACE { ;
				{'TEXTBOX' , 'NUMERIC' , '$ 999,999.99'} , ;
				{'DATEPICKER' , 'DROPDOWN'} , ;
				{'COMBOBOX' , {'One' , 'Two' , 'Three'}} , ;
				{ 'SPINNER' , 1 , 20 } , ;
				{ 'CHECKBOX' , 'Yes' , 'No' } ;
				} ;
			COLUMNWHEN { ;
				{ || This.CellValue > 120 } , ;
				{ || This.CellValue = Date() } , ;
				Nil , ;
				Nil , ;
				Nil ;
				} ;
			DYNAMICFORECOLOR { fColor , fColor, fColor, fColor, fColor } 

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

PROCEDURE SetOrder()
local aColumns := { 5, 4, 3, 2, 1 }

	_SetColumnOrderArray( "Grid_1", "Form_1", aColumns )

	Form_1.Grid_1.Refresh

RETURN

PROCEDURE GetOrder()
local a

	a := _GetColumnOrderArray( "Grid_1", "Form_1" )

	AEval( a, {|x,i| MsgInfo ( "Column " + LTrim( str ( x ) ), LTrim( str ( i ) ) )} )

RETURN

*--------------------------------------------------------------------
Function _GetColumnOrderArray( ControlName , ParentForm )
*--------------------------------------------------------------------
Local i, nColumn, aSort
	i := GetControlIndex( ControlName , ParentForm )
	nColumn := Len(_HMG_aControlCaption [i])
	aSort := Array(nColumn)
	ListView_GetColumnOrderArray( _HMG_aControlHandles [i], nColumn, @aSort )
Return aSort

*--------------------------------------------------------------------
Function _SetColumnOrderArray( ControlName , ParentForm, aSort )
*--------------------------------------------------------------------
Local i, nColumn
	i := GetControlIndex( ControlName , ParentForm )
	nColumn := Len(_HMG_aControlCaption [i])
	ListView_SetColumnOrderArray( _HMG_aControlHandles [i], nColumn, aSort )
Return Nil


#pragma BEGINDUMP
#define _WIN32_IE      0x0500
#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"

#ifdef __XHARBOUR__
#define HB_PARNI( n, x ) hb_parni( n, x )
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
#define HB_PARNI( n, x ) hb_parvni( n, x )
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

HB_FUNC ( LISTVIEW_GETCOLUMNORDERARRAY )
{
	int nColumn = hb_parni(2);
	LPINT pnOrder = (LPINT) malloc(nColumn*sizeof(int));
	int i;

	ListView_GetColumnOrderArray( (HWND) hb_parnl(1), nColumn, pnOrder );

	for (i=0; i<nColumn; i++) 
	{ 
		HB_STORNI(pnOrder[i]+1, 3, i+1);
	}
}

HB_FUNC ( LISTVIEW_SETCOLUMNORDERARRAY )
{
	int nColumn = hb_parni(2);
	LPINT pnOrder = (LPINT) malloc(nColumn*sizeof(int));
	int i;

	for (i=0; i<nColumn; i++) 
	{ 
		pnOrder[i] = HB_PARNI(3, i+1) - 1;
	}

	ListView_SetColumnOrderArray( (HWND) hb_parnl(1), nColumn, pnOrder );
}

#pragma ENDDUMP