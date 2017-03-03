/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2013 Verchenko Andrey <verchenkoag@gmail.com>
 * Helped and taught by SergKis  http://clipper.borda.ru
 *
*/

#include "minigui.ch"

STATIC lChangeFont := .F.
////////////////////////////////////////////////////////////
// Function: Change fonts TBROWSE
FUNCTION Form_fonts(aFonts)
   LOCAL nWinWidth := 525, nWinHeight := 530 + IF(IsXPThemeActive(), 6, 0)
   LOCAL aBackColor := {214,223,247}, aBackCol2 := {122,161,230} 
   LOCAL cFont := "Tahoma", nSize := 14, lBold := .F., lItalic := .F.
   LOCAL nFontSize := 12, aFontColor := WHITE    // font size / color buttons
   LOCAL nLenButt := 180   // width button 
   LOCAL nHButt   := 64    // height button 
   LOCAL nCol1 := nWinWidth-nLenButt-20, nCol2 := nWinWidth-nLenButt*2-5-20 
   LOCAL nRow1 := nWinHeight - nHButt - 50 
   LOCAL aObjFrm := {}, aObj2But := {}, aRetFont := {}
   LOCAL cObj, cObject, bAction, nFontSize2 := 10, nFSize, nI
   DEFAULT aFonts := {}

   IF LEN(aFonts) == 0
      AADD( aFonts, {"Times New Roman",11,lBold,lItalic} )
      AADD( aFonts, {"Arial"          ,12,lBold,lItalic} )
      AADD( aFonts, {"Tahoma"         ,14,lBold,lItalic} )
      AADD( aFonts, {"Courier New"    ,16,lBold,lItalic} )
      AADD( aFonts, {"Courier New"    ,12,lBold,lItalic} )
   ENDIF

   AADD( aObjFrm, {"oFrm_1" , 65,50,nWinWidth-50*2,55," Font of columns "          } )
   AADD( aObjFrm, {"oFrm_2" ,130,50,nWinWidth-50*2,55," Font of column headers "   } )
   AADD( aObjFrm, {"oFrm_3" ,195,50,nWinWidth-50*2,55," Font of footer "           } )
   AADD( aObjFrm, {"oFrm_4" ,260,50,nWinWidth-50*2,55," Font of composite header " } )
   AADD( aObjFrm, {"oFrm_5" ,325,50,nWinWidth-50*2,55," Font of cell editing "     } )

   // ------------------ a list of all the buttons ----------------------------------
   AADD( aObj2But, {"oBut_Exit",nRow1,nCol1,nLenButt,nHButt,"Exit"            ,MAROON,{|| aRetFont := {}, ThisWindow.Release           } ,''  } )
   AADD( aObj2But, {"oBut_Save",nRow1,nCol2,nLenButt,nHButt,"Set"+CRLF+"fonts",LGREEN,{|| aRetFont := SaveDimFonts(aFonts),ThisWindow.Release } ,'Set the new fonts of TBROWSE and exit' } )
   AADD( aObj2But, {"oBut_Fnt1", 65+22, 350, 120, 28,"Change the font"        ,BLUE,  {|| ChangeFont(1, aFonts)                        } ,''  } )
   AADD( aObj2But, {"oBut_Fnt2",130+22, 350, 120, 28,"Change the font"        ,BLUE,  {|| ChangeFont(2, aFonts)                        } ,''  } )
   AADD( aObj2But, {"oBut_Fnt3",195+22, 350, 120, 28,"Change the font"        ,BLUE,  {|| ChangeFont(3, aFonts)                        } ,''  } )
   AADD( aObj2But, {"oBut_Fnt4",260+22, 350, 120, 28,"Change the font"        ,BLUE,  {|| ChangeFont(4, aFonts)                        } ,''  } )
   AADD( aObj2But, {"oBut_Fnt5",325+22, 350, 120, 28,"Change the font"        ,BLUE,  {|| ChangeFont(5, aFonts)                        } ,''  } )

	DEFINE WINDOW Form_Font				;
		AT 0,0 					;
		WIDTH nWinWidth 			;
		HEIGHT nWinHeight                       ; 
		TITLE "Menu: change fonts TBROWSE"	;
		ICON "iFont48x1"			;
                BACKCOLOR aBackColor                    ;
                FONT cFont SIZE nSize                   ;
		CHILD 					;
		NOMAXIMIZE NOSIZE			

                nWinWidth  := Form_Font.Width 
                nWinHeight := Form_Font.Height 

                @ 20,20 LABEL Label_Tit1 WIDTH nWinWidth-20*2 HEIGHT 30 VALUE "Properties font table" ;
                  FONTCOLOR WHITE BACKCOLOR { 9, 77,181} SIZE nSize CENTERALIGN 
                @ 50,20 LABEL Label_Tit2 WIDTH nWinWidth-20*2 HEIGHT nWinHeight-185 VALUE "" ;
                  BACKCOLOR aBackCol2 SIZE 12 BOLD CENTERALIGN 

                FOR nI := 1 TO LEN(aObjFrm)
                    cObj := aObjFrm[nI,1]
                    @ aObjFrm[nI,2], aObjFrm[nI,3] FRAME &cObj ;
                      CAPTION aObjFrm[nI,6]  ;
                      WIDTH aObjFrm[nI,4] HEIGHT aObjFrm[nI,5] ;
                      SIZE nSize BACKCOLOR aBackCol2

                    cObj := "Label_"+HB_NTOS(nI)
                    @ aObjFrm[nI,2]+23, aObjFrm[nI,3]+10 LABEL &cObj ;
                      WIDTH 290 HEIGHT 20 ;
                      VALUE aFonts[nI,1] + " " + HB_NtoS(aFonts[nI,2]);
                      BACKCOLOR aBackCol2  FONTCOLOR BLUE SIZE nSize 
                NEXT

                // ----------- withdrawal of all buttons -----------
                FOR nI := 1 TO LEN(aObj2But) 
                    cObject := aObj2But[nI,1]
                    bAction := aObj2But[nI,8] 
                    nFSize := IIF( nI>2,  nFontSize2, nFontSize)
                    @ aObj2But[nI,2],aObj2But[nI,3] BUTTONEX &cObject ;
                      WIDTH aObj2But[nI,4] HEIGHT aObj2But[nI,5]      ;
                      CAPTION aObj2But[nI,6]           ;
                      NOHOTLIGHT NOXPSTYLE             ;
                      FONTCOLOR aFontColor             ;
                      BACKCOLOR aObj2But[nI,7]         ;
                      TOOLTIP aObj2But[nI,9]           ;
                      HANDCURSOR                       ;
                      SIZE nFSize BOLD                     
                    // --- instead ACTION Eval (bAction) use:
                    IF Valtype(bAction) == 'B'        // an array of codeblock
                       Form_Font.&(cObject).Action := bAction
                    ELSEIF valtype(bAction) == 'C'    // for an array of strings
                       Form_Font.&(cObject).Action := hb_MacroBlock( bAction )
                    ENDIF ENDIF
                NEXT

	END WINDOW

	CENTER WINDOW Form_Font
	ACTIVATE WINDOW Form_Font

RETURN aRetFont

////////////////////////////////////////////////////////////////////////////
// Function: Submitting modified fonts TBROWSE
STATIC FUNCTION SaveDimFonts(aFonts)
   LOCAL aDim := {}
   
   IF lChangeFont // user changed font
      aDim := ACLONE(aFonts)
   ENDIF

RETURN aDim

////////////////////////////////////////////////////////////////////////////
// Function: call the standard Windows font menu
Static FUNCTION ChangeFont(nItem, aFonts) 
Local aF := aFonts[nItem], cObj, cStr

   //aF := GetFont ( 'Arial' , 12 , .f. , .t. , {0,0,0} , .f. , .f. , 0 )
   aF := GetFont ( aF[1] , aF[2], aF[3], aF[4] , {0,0,0} , .f. , .f. , 0 )
   if empty ( aF[1] )
      // exit without selecting a font
   Else
      //                                Bold   Italic
      aFonts[nItem] := { aF[1] , aF[2], aF[3], aF[4] }
      lChangeFont := .T. // user changed font 
      cObj := "Label_"+STR(nItem,1)
      cStr := aF[1] + STR(aF[2],3)
      SetProperty(ThisWindow.Name, cObj, "Value", cStr) 
   EndIf

RETURN NIL

////////////////////////////////////////////////////////////////////////////
