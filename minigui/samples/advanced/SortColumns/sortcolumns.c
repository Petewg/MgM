#pragma BEGINDUMP

#define _WIN32_IE      0x0500

#include <mgdefs.h>
#include <commctrl.h>

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
