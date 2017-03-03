*******************************************************************************
* PROGRAMA: GRID_CONTROLS_EX.prg
* LENGUAJE: MiniGUI Extended 2.1.4
* FECHA:    Agosto 2012
* AUTOR:    Dr. CLAUDIO SOTO
* PAIS:     URUGUAY
* E-MAIL:   srvet@adinet.com.uy
* BLOG:     http://srvet.blogspot.com
*******************************************************************************


// FUNCTIONS
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


// SYNTAX
**********************************************************************************
* GRID_ColumnCount (cControlName , [cParentForm])
* GRID_AddColumnEx (cControlName, [cParentForm], nColIndex, [aCOLUMNCONTROL], [bDYNAMICBACKCOLOR], [bDYNAMICFORECOLOR], [bCOLUMNWHEN], [bCOLUMNVALID], [bONHEADCLICK])
* GRID_DeleteColumnEx (cControlName, [cParentForm], nColIndex)
* GRID_GetColumnControlsEx (cControlName, [cParentForm], nColIndex)
* GRID_GetColumnControl (cControlName , [cParentForm], nControl, nColIndex)
* GRID_SetColumnControl (cControlName , [cParentForm], nControl, nColIndex, Data)
* GRID_GetColumnDisplayPos (cControlName, [cParentForm], nColIndex)
* GRID_SetColumnDisplayPos (cControlName, [cParentForm], nColIndex, nPos_Display)
* GRID_GetColumnWidthDisplay (cControlName, cParentForm, nColIndex)
* GRID_SetBkImage (cControlName, [cParentForm], nAction, cBMPFileName, yOffset, xOffset)
**********************************************************************************

#include "minigui.ch" 

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


******************
*** Properties ***
******************

******************************************************************************
FUNCTION GRID_ColumnCount (cControlName , cParentForm)
LOCAL i
   IF Valtype (cParentForm) == "U"
      cParentForm := ThisWindow.Name
   ENDIF	
   i:= GetControlIndex (cControlName , cParentForm)
RETURN (LEN(_HMG_aControlPageMap [i]))


******************************************************************************
FUNCTION GRID_GetColumnControlsEx (cControlName, cParentForm, nColIndex)
LOCAL aGridControls := ARRAY (9)
   
   IF Valtype (cParentForm) == "U"
      cParentForm := ThisWindow.Name
   ENDIF	
   
   aGridControls [1] := GRID_GETCOLUMNCONTROL (cControlName, cParentForm, _GRID_COLUMNCAPTION_,    nColIndex)
   aGridControls [2] := GRID_GETCOLUMNCONTROL (cControlName, cParentForm, _GRID_COLUMNWIDTH_,      nColIndex)
   aGridControls [3] := GRID_GETCOLUMNCONTROL (cControlName, cParentForm, _GRID_COLUMNJUSTIFY_,    nColIndex)   
   aGridControls [4] := GRID_GETCOLUMNCONTROL (cControlName, cParentForm, _GRID_COLUMNCONTROLS_,   nColIndex)                  
   aGridControls [5] := GRID_GETCOLUMNCONTROL (cControlName, cParentForm, _GRID_DYNAMICBACKCOLOR_, nColIndex)                  		 
   aGridControls [6] := GRID_GETCOLUMNCONTROL (cControlName, cParentForm, _GRID_DYNAMICFORECOLOR_, nColIndex)                     
   aGridControls [7] := GRID_GETCOLUMNCONTROL (cControlName, cParentForm, _GRID_COLUMNWHEN_,       nColIndex)
   aGridControls [8] := GRID_GETCOLUMNCONTROL (cControlName, cParentForm, _GRID_COLUMNVALID_,      nColIndex)                  		    
   aGridControls [9] := GRID_GETCOLUMNCONTROL (cControlName, cParentForm, _GRID_ONHEADCLICK_,      nColIndex)                  		 
   // Return Array --> {cCAPTION, nWIDTH, nJUSTIFY, aCOLUMNCONTROL, bDYNAMICBACKCOLOR, bDYNAMICFORECOLOR, bCOLUMNWHEN, bCOLUMNVALID, bONHEADCLICK}
RETURN aGridControls


******************************************************************************
FUNCTION GRID_GetColumnControl (cControlName , cParentForm, nControl, nColIndex)
LOCAL Length, i, Data := NIL
  i := GetControlIndex(cControlName,cParentForm)
  
  IF nControl = _GRID_ONHEADCLICK_ 
     Length := LEN(_HMG_aControlHeadClick [i])      
     IF nColIndex > 0 .AND. nColIndex <= Length 
        Data := _HMG_aControlHeadClick [i] [nColIndex]       
     ENDIF

  ELSEIF nControl = _GRID_COLUMNCAPTION_	 
     Length := LEN(_HMG_aControlPageMap [i])      
     IF nColIndex > 0 .AND. nColIndex <= Length 
        Data := _HMG_aControlPageMap [i] [nColIndex]       
     ENDIF

  ELSEIF Valtype (_HMG_aControlMiscData1 [ i ] [ nControl ]) == "A"       
        Length := LEN(_HMG_aControlMiscData1 [ i ] [ nControl ])
        IF nColIndex > 0 .AND. nColIndex <= Length 
           Data := _HMG_aControlMiscData1 [ i ] [ nControl ] [nColIndex]
        ENDIF                          
  ENDIF
RETURN Data


******************************************************************************
FUNCTION GRID_SetColumnControl (cControlName , cParentForm, nControl, nColIndex, Data)
LOCAL Length, num_Col, i, Old_Data

  num_Col := GRID_ColumnCount(cControlName,cParentForm)
  i := GetControlIndex(cControlName,cParentForm)

   IF (nControl = _GRID_ONHEADCLICK_) .AND. (Valtype (Data) <> "U")
     Length := LEN(_HMG_aControlHeadClick [i])      
     IF Length < num_Col
        ASIZE (_HMG_aControlHeadClick [i], num_Col)
	 ENDIF   
	 
	 Length := LEN(_HMG_aControlHeadClick [i]) 	
	 IF nColIndex > 0 .AND. nColIndex <= num_Col 
        Old_Data := _HMG_aControlHeadClick [i] [nColIndex]
        _HMG_aControlHeadClick [i] [nColIndex] := Data	
     ENDIF

  ELSEIF (nControl = _GRID_COLUMNCAPTION_) .AND. (Valtype (Data) <> "U")	 
     Length := LEN(_HMG_aControlPageMap [i])      
     IF Length < num_Col
        ASIZE (_HMG_aControlPageMap [i] , num_Col)
     ENDIF   
	 
	 IF nColIndex > 0 .AND. nColIndex <= num_Col
        Old_Data := _HMG_aControlPageMap [i] [nColIndex]
        _HMG_aControlPageMap [i] [nColIndex] := Data		
		SetProperty (cParentForm, cControlName, "Header", nColIndex, Data)
     ENDIF
             
  ELSEIF Valtype (Data) <> "U"
       
        IF Valtype (_HMG_aControlMiscData1 [ i ] [ nControl ]) <> "A"
           _HMG_aControlMiscData1 [ i ] [ nControl ] := {}
        ENDIF
        
        Length := LEN(_HMG_aControlMiscData1 [ i ] [ nControl ])
        IF Length < num_Col
           ASIZE (_HMG_aControlMiscData1 [ i ] [ nControl ], num_Col)
        ENDIF
            
        IF nColIndex > 0 .AND. nColIndex <= num_Col           
           Old_Data := _HMG_aControlMiscData1 [ i ] [ nControl ] [nColIndex]
           _HMG_aControlMiscData1 [ i ] [ nControl ] [nColIndex] := Data 
           IF nControl = _GRID_COLUMNWIDTH_
              // Low-level function in C native of HMG (source c_grid.c)
              LISTVIEW_SETCOLUMNWIDTH (GetControlHandle (cControlName, cParentForm), nColIndex-1, Data) 
           ENDIF
           IF nControl = _GRID_COLUMNJUSTIFY_
              // Low-level function in C (see the end of this file)
              LISTVIEW_SETCOLUMNJUSTIFY (GetControlHandle(cControlName, cParentForm), nColIndex-1, Data)                 
     	   ENDIF	   
        ENDIF               
  ENDIF
RETURN Old_Data


******************************************************************************
FUNCTION GRID_GetColumnDisplayPos (cControlName, cParentForm, nColIndex)
LOCAL nPos, ArrayOrder := {}
   IF Valtype (cParentForm) == "U"
      cParentForm := ThisWindow.Name
   ENDIF	
   // LISTVIEW_GETCOLUMNORDERARRAY: Low-level function in C (see the end of this file)
   ArrayOrder := LISTVIEW_GETCOLUMNORDERARRAY (GetControlHandle (cControlName, cParentForm), GRID_ColumnCount (cControlName, cParentForm))
   nPos := ASCAN (ArrayOrder, nColIndex)    
RETURN nPos


******************************************************************************
FUNCTION GRID_SetColumnDisplayPos (cControlName, cParentForm, nColIndex, nPos_Display)
LOCAL nOld_Pos, ArrayOrder := {}
   IF Valtype (cParentForm) == "U"
      cParentForm := ThisWindow.Name
   ENDIF

   // Low-level function in C (see the end of this file)
   ArrayOrder := LISTVIEW_GETCOLUMNORDERARRAY (GetControlHandle (cControlName, cParentForm), GRID_ColumnCount (cControlName, cParentForm))
   nOld_Pos := ASCAN (ArrayOrder, nColIndex)  
     
   IF nOld_pos >= 1 .AND. nPos_Display <> nOld_Pos              	  	  
	  ADEL (ArrayOrder, nOld_Pos)
	  AINS (ArrayOrder, nPos_Display)
      ArrayOrder [nPos_Display] := nColIndex	   
	  
	  // Low-level function in C (see the end of this file)
      LISTVIEW_SETCOLUMNORDERARRAY (GetControlHandle (cControlName, cParentForm), GRID_ColumnCount (cControlName, cParentForm), ArrayOrder)
	ENDIF  	     		        
RETURN nOld_Pos


******************************************************************************
FUNCTION GRID_GetColumnWidthDisplay (cControlName, cParentForm, nColIndex)
LOCAL nWidth
   IF Valtype (cParentForm) == "U"
      cParentForm := ThisWindow.Name
   ENDIF	
   // LISTVIEW_GETCOLUMNWIDTH: Low-level function in C native of HMG (source c_grid.c)
   nWidth := LISTVIEW_GETCOLUMNWIDTH (GetControlHandle (cControlName, cParentForm), nColIndex-1)
RETURN nWidth


******************************************************************************
// CONSTANTS -->  GRID_SetBkImage (nAction)
#define _GRID_SETBKIMAGE_NONE_   0
#define _GRID_SETBKIMAGE_NORMAL_ 1
#define _GRID_SETBKIMAGE_FILL_   2

PROCEDURE GRID_SetBkImage (cControlName, cParentForm, nAction, cBMPFileName, yOffset, xOffset)
   IF Valtype (cParentForm) == "U"
      cParentForm := ThisWindow.Name
   ENDIF	
   // LISTVIEW_SETBKIMAGE and BMP_LOAD_FILE are Low-level functions in C (see the end of this file)
   LISTVIEW_SETBKIMAGE (GetControlHandle (cControlName, cParentForm), BMP_LOAD_FILE (cBMPFileName), xOffset, yOffset, nAction)
RETURN



***************
*** Methods ***
***************

******************************************************************************
PROCEDURE GRID_AddColumnEx (cControlName, cParentForm, nColIndex, aCOLUMNCONTROL, bDYNAMICBACKCOLOR, bDYNAMICFORECOLOR, bCOLUMNWHEN, bCOLUMNVALID, bONHEADCLICK)
   IF Valtype (cParentForm) == "U"
      cParentForm := ThisWindow.Name
   ENDIF	
 
   IF Valtype (nColIndex) == "U"
      nColIndex := GRID_ColumnCount (cControlName , cParentForm)
   ENDIF
 
   GRID_ADDCONTROLS (cControlName, cParentForm, _GRID_COLUMNCONTROLS_,   nColIndex, aCOLUMNCONTROL)                  
   GRID_ADDCONTROLS (cControlName, cParentForm, _GRID_DYNAMICBACKCOLOR_, nColIndex, bDYNAMICBACKCOLOR)                  		 
   GRID_ADDCONTROLS (cControlName, cParentForm, _GRID_DYNAMICFORECOLOR_, nColIndex, bDYNAMICFORECOLOR)                     
   GRID_ADDCONTROLS (cControlName, cParentForm, _GRID_COLUMNWHEN_,       nColIndex, bCOLUMNWHEN)
   GRID_ADDCONTROLS (cControlName, cParentForm, _GRID_COLUMNVALID_,      nColIndex, bCOLUMNVALID)                  		    
   GRID_ADDCONTROLS (cControlName, cParentForm, _GRID_ONHEADCLICK_,      nColIndex, bONHEADCLICK)                  		 
RETURN


******************************************************************************
PROCEDURE GRID_DeleteColumnEx (cControlName, cParentForm, nColIndex)
   IF Valtype (cParentForm) == "U"
      cParentForm := ThisWindow.Name
   ENDIF	
 
   IF Valtype (nColIndex) == "U"
      nColIndex := GRID_ColumnCount (cControlName , cParentForm)
   ENDIF
 
   GRID_DELETECONTROLS (cControlName, cParentForm, _GRID_COLUMNCONTROLS_,   nColIndex)                  
   GRID_DELETECONTROLS (cControlName, cParentForm, _GRID_DYNAMICBACKCOLOR_, nColIndex)                  		 
   GRID_DELETECONTROLS (cControlName, cParentForm, _GRID_DYNAMICFORECOLOR_, nColIndex)                     
   GRID_DELETECONTROLS (cControlName, cParentForm, _GRID_COLUMNWHEN_,       nColIndex)
   GRID_DELETECONTROLS (cControlName, cParentForm, _GRID_COLUMNVALID_,      nColIndex)                  		    
   GRID_DELETECONTROLS (cControlName, cParentForm, _GRID_ONHEADCLICK_,      nColIndex)                  		 
RETURN





**********************************************************************************************************
*** Internal Functions ***
**********************************************************************************************************

PROCEDURE GRID_ADDCONTROLS (cControlName , cParentForm, nControl, nColIndex, Data)
LOCAL Length, num_Col, i

  num_Col := GRID_ColumnCount(cControlName,cParentForm)
  i := GetControlIndex(cControlName,cParentForm)
  
  IF nControl = _GRID_ONHEADCLICK_ .AND. Valtype (Data) <> "U"
     Length := LEN(_HMG_aControlHeadClick [i])
     IF Length < num_Col
        ASIZE (_HMG_aControlHeadClick [i] , num_Col)
     ENDIF   
        
     IF nColIndex > 0 .AND. nColIndex <= num_Col
        AINS  (_HMG_aControlHeadClick [i], nColIndex)
        _HMG_aControlHeadClick [i] [nColIndex] := Data
     ENDIF   
     
  ELSE
     IF Valtype (Data) <> "U"
       
        IF Valtype (_HMG_aControlMiscData1 [ i ] [ nControl ]) <> "A"
           _HMG_aControlMiscData1 [ i ] [ nControl ] := {}
        ENDIF
        
        Length := LEN(_HMG_aControlMiscData1 [ i ] [ nControl ])
        IF Length < num_Col
           ASIZE (_HMG_aControlMiscData1 [ i ] [ nControl ], num_Col)
        ENDIF
            
        IF nColIndex > 0 .AND. nColIndex <= num_Col
           AINS  (_HMG_aControlMiscData1 [ i ] [ nControl ], nColIndex)
           _HMG_aControlMiscData1 [ i ] [ nControl ] [nColIndex] := Data 
        ENDIF       
     ENDIF        
  ENDIF

RETURN



PROCEDURE GRID_DELETECONTROLS (cControlName , cParentForm, nControl, nColIndex)
LOCAL Length, i
  
  i := GetControlIndex(cControlName,cParentForm)
  
  IF nControl = _GRID_ONHEADCLICK_
     Length := LEN(_HMG_aControlHeadClick [i])      
     IF nColIndex > 0 .AND. nColIndex <= Length 
        ADEL  (_HMG_aControlHeadClick [i], nColIndex)
        ASIZE (_HMG_aControlHeadClick [i], Length-1)        
     ENDIF   
     
  ELSE
     IF Valtype (_HMG_aControlMiscData1 [ i ] [ nControl ]) == "A"
       
        Length := LEN(_HMG_aControlMiscData1 [ i ] [ nControl ])
        IF nColIndex > 0 .AND. nColIndex <= Length 
           ADEL  (_HMG_aControlMiscData1 [ i ] [ nControl ], nColIndex)
           ASIZE (_HMG_aControlMiscData1 [ i ] [ nControl ], Length-1)        
        ENDIF                   
     ENDIF       
  ENDIF
  
RETURN




************************************************************************************************************
* Low-level Functions in C
************************************************************************************************************
#pragma begindump

#define _WIN32_IE      0x0500
#define _WIN32_WINNT   0x501


#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"

#ifdef __XHARBOUR__
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

//******************************************************************************
// LISTVIEW_SETCOLUMNJUSTIFY (ControlHandle, nCol, nJustify)
HB_FUNC ( LISTVIEW_SETCOLUMNJUSTIFY )
{
   LV_COLUMN   COL;
   COL.mask = LVCF_FMT; 
   COL.fmt  = hb_parni(3);   
   ListView_SetColumn ((HWND) hb_parnl(1), hb_parni(2), &COL);
}


//******************************************************************************
// LISTVIEW_GETCOLUMNORDERARRAY (ControlHandle, nColumnCount) --> Return Array: {Column Order}
HB_FUNC ( LISTVIEW_GETCOLUMNORDERARRAY )
{
   int i, *p;
   p = (int*) GlobalAlloc (GMEM_FIXED | GMEM_ZEROINIT, sizeof(int)*hb_parni(2));
   ListView_GetColumnOrderArray ((HWND) hb_parnl(1), hb_parni(2), (int*) p);
   hb_reta (hb_parni(2)); 
   for( i= 0; i < hb_parni(2); i++ ) 
        HB_STORNI( (int)(*(p+i))+1, -1, i+1);
   GlobalFree (p);
}


//******************************************************************************
// LISTVIEW_SETCOLUMNORDERARRAY (ControlHandle, nColumnCount, aArrayOrder) 
HB_FUNC ( LISTVIEW_SETCOLUMNORDERARRAY )
{
   int i, *p;
   PHB_ITEM aArray;
   aArray = hb_param (3, HB_IT_ARRAY);
   p = (int*) GlobalAlloc (GMEM_FIXED | GMEM_ZEROINIT, sizeof(int)*hb_parni(2));
   for( i= 0; i < hb_parni(2); i++ )
        *(p+i) = (int) hb_arrayGetNI (aArray, i+1)-1;	  
   ListView_SetColumnOrderArray ((HWND) hb_parnl(1), hb_parni(2), (int*) p);	  
   GlobalFree (p);
}


//******************************************************************************
// LISTVIEW_SETBKIMAGE (ControlHandle, hBitmap, yOffset, xOffset, nFlag)
HB_FUNC ( LISTVIEW_SETBKIMAGE )
{  
   LVBKIMAGE plBackImage;
   ULONG flag = hb_parnl(5);
    
   plBackImage.ulFlags = LVBKIF_SOURCE_NONE;
   if (flag == 1) 
      plBackImage.ulFlags =  LVBKIF_SOURCE_HBITMAP | LVBKIF_STYLE_NORMAL; 	
    
   if (flag == 2) 
       plBackImage.ulFlags =  LVBKIF_SOURCE_HBITMAP | LVBKIF_STYLE_TILE; 	 
		
   plBackImage.hbm = (HBITMAP) hb_parnl(2);
   plBackImage.pszImage = NULL;
   plBackImage.cchImageMax = 0;
   plBackImage.yOffsetPercent = hb_parni(3);
   plBackImage.xOffsetPercent = hb_parni(4);
    
   ListView_SetBkImage ((HWND) hb_parnl(1), &plBackImage);
   
//   DeleteObject ((HBITMAP) hb_parnl (2));
}


//******************************************************************************
// BMP_LOAD_FILE (cFileBMP) ---> Return hBITMAP
HB_FUNC (BMP_LOAD_FILE)
{   
    HBITMAP hBitmapFile;
    char *FileName;

    FileName = (char *) hb_parcx (1);
  
  // Load file .BMP
     hBitmapFile = (HBITMAP)LoadImage(NULL, FileName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_CREATEDIBSECTION);
        
  // If fail: load resourse in .EXE file   
     if (hBitmapFile == NULL)
         hBitmapFile = (HBITMAP)LoadImage(GetModuleHandle(NULL), FileName, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
                          
      hb_retnl( (LONG) hBitmapFile );      
}


#pragma enddump

