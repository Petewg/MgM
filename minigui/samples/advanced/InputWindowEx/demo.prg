/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2008 Jozef Rudnicki <j_rudnicki@wp.pl>
*/

#include "minigui.ch"

Procedure Main
***************
  local cTekst:=''

  if file('InputWindowEx.txt')
    cTekst:=MemoRead('InputWindowEx.txt')
  endif

  DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH 800 ;
	HEIGHT 600 ;
	TITLE 'InputWindowEx Demo' ;
	MAIN ;
	ON INIT test()

	DEFINE MAIN MENU
 	  POPUP 'InputWindowEx'
	    ITEM 'Run demo' ACTION test() 
	    SEPARATOR
	    ITEM 'Exit' ACTION ThisWindow.Release
 	  END POPUP
 	  POPUP 'InputWindow standard'
	    ITEM 'Test' ACTION test2()
 	  END POPUP
 	END MENU

        DEFINE EDITBOX Edit_1
          COL 10
          ROW 20
          WIDTH 760
          HEIGHT 500
          VALUE cTekst
          READONLY .t.  
        END EDITBOX

  END WINDOW

  CENTER WINDOW Form_1
  ACTIVATE WINDOW Form_1

  Return

proc test()
***********
  local aLabels:={}, aValues:={}, aFormats:={}

  AAdd(aLabels,'1. Label with default settings')
  AAdd(aValues, nil)
  AAdd(aFormats,nil)
//
  AAdd(aLabels,'2. Label with fixed width and font bold+italic+strikeout+underline')
  AAdd(aValues, nil)
  AAdd(aFormats,{250,,,,'BOLD ITALIC STRIKEOUT UNDERLINE'})
//
  AAdd(aLabels,'3. TextBox with default settings :')
  AAdd(aValues, nil)
  AAdd(aFormats,{,,,,'BOLD'})

  AAdd(aLabels,'textbox label')
  AAdd(aValues,'textbox value')
  AAdd(aFormats,{,'TX',,,})
//
  AAdd(aLabels,'4. TextBox numeric with fixed widths :')
  AAdd(aValues, nil)
  AAdd(aFormats,{,,,,'BOLD'})

  AAdd(aLabels,'textbox numeric')
  AAdd(aValues, 1234.5)
  AAdd(aFormats,{100,'TN',80,,'9 999.9'})
//
  AAdd(aLabels,'5. EditBox with default settings :')
  AAdd(aValues, nil)
  AAdd(aFormats,{,,,,'BOLD'})

  AAdd(aLabels,'multiline editbox label')
  AAdd(aValues,'editbox value')
  AAdd(aFormats,{,'EB',,,})
//
  AAdd(aLabels,'6. EditBox with fixed size :')
  AAdd(aValues, nil)
  AAdd(aFormats,{,,,,'BOLD'})

  AAdd(aLabels,'multiline editbox label')
  AAdd(aValues,'editbox value')
  AAdd(aFormats,{120,'EB',250,60,})
//
  AAdd(aLabels,'7. DatePicker :')
  AAdd(aValues, nil)
  AAdd(aFormats,{,,,,'BOLD'})

  AAdd(aLabels,'label')
  AAdd(aValues,date())
  AAdd(aFormats,{100,'DP',100,,})
//
  AAdd(aLabels,'8. CheckBox :')
  AAdd(aValues, nil)
  AAdd(aFormats,{,,,,'BOLD'})

  AAdd(aLabels,'label')
  AAdd(aValues, .t.)
  AAdd(aFormats,{100,'CH',,,})
//
  AAdd(aLabels,'9. ComboBox :')
  AAdd(aValues, nil)
  AAdd(aFormats,{,,,,'BOLD'})

  AAdd(aLabels,'label')
  AAdd(aValues, 2)
  AAdd(aFormats,{100,'CB',200,,{'item 1','item 2','item 3','item 4'}})
//
  InputWindowEx('InputWindowEx test',;
                aLabels,;
                aValues,;
                aFormats,,,.t. )
//
  InputWindowEx('InputWindowEx modified by external codeblock',;
                aLabels,;
                aValues,;
                aFormats,,,.t.,,{||xTestCode()} )

// InputWindow compatibility test
  aLabels:={}; aValues:={}; aFormats:={}

  AAdd(aLabels,'1. textbox')
  AAdd(aValues,'textbox value')
  AAdd(aFormats,30)
  //
  AAdd(aLabels,'2. editbox')
  AAdd(aValues,'editbox value')
  AAdd(aFormats,35)
  //
  AAdd(aLabels,'3. checkbox')
  AAdd(aValues,.t.)
  AAdd(aFormats,nil)
  //
  AAdd(aLabels,'4. combobox')
  AAdd(aValues,2)
  AAdd(aFormats,{'item 1','item 2','item 3','item 4'})
  //
  AAdd(aLabels,'5. textbox numeric')
  AAdd(aValues,1234.5)
  AAdd(aFormats,' 9999.9')
  //
  AAdd(aLabels,'6. datepicker')
  AAdd(aValues,date())
  AAdd(aFormats,nil)
  //
  InputWindowEx('InputWindow compatibility test',;
                aLabels,;
                aValues,;
                aFormats,,,.t.)
  RETURN

proc test2()
***********
// InputWindow standard test
  local aLabels:={}, aValues:={}, aFormats:={}

  AAdd(aLabels,'1. textbox')
  AAdd(aValues,'textbox value')
  AAdd(aFormats,30)
  //
  AAdd(aLabels,'2. editbox')
  AAdd(aValues,'editbox value')
  AAdd(aFormats,35)
  //
  AAdd(aLabels,'3. checkbox')
  AAdd(aValues,.t.)
  AAdd(aFormats,nil)
  //
  AAdd(aLabels,'4. combobox')
  AAdd(aValues,2)
  AAdd(aFormats,{'item 1','item 2','item 3','item 4'})
  //
  AAdd(aLabels,'5. textbox numeric')
  AAdd(aValues,1234.5)
  AAdd(aFormats,' 9999.9')
  //
  AAdd(aLabels,'6. datepicker')
  AAdd(aValues,date())
  AAdd(aFormats,nil)
  //
  InputWindow('InputWindow standard test',;
                aLabels,;
                aValues,;
                aFormats,,,,,120)
  RETURN

static proc xTestCode()
***********************
  local i,imax
  // set some properties
  SetProperty('_InputWindow','Label_1','BackColor',RED)
  SetProperty('_InputWindow','Label_3','FontColor',YELLOW)
  SetProperty('_InputWindow','Label_10','FontSize',12)
  SetProperty('_InputWindow','Label_12','FontItalic',.t.)
  SetProperty('_InputWindow','Control_6','BackColor',YELLOW)
  DoMethod('_InputWindow','Control_6','SetFocus')
  SetProperty('_InputWindow','Control_8','ReadOnly',.t.)
  // count InputWindow rows
  imax:=1
  do while _IsControlDefined('Label_'+xtoc(imax),'_InputWindow')
    imax++
  enddo
  // set tooltips
  for i:=1 to imax-1
    if _IsControlDefined('Control_'+xtoc(i),'_InputWindow')
      SetProperty('_InputWindow','Control_'+xtoc(i),'Tooltip','Tooltip for control no.'+xtoc(i))
    endif
  next
  // set LOSTFOCUS method code for TEXTBOX control
  SetMethodCode('_InputWindow','Control_4','LOSTFOCUS',{||xIfEmpty()})
  RETURN

static proc xIfEmpty()
**********************
  if empty(This.Value)
    SetProperty('_InputWindow',This.Name,'BackColor',RED)
    PlayBeep()
    inkey(.5)
    DoMethod('_InputWindow',This.Name,'SetFocus')
    SetProperty('_InputWindow',This.Name,'BackColor',WHITE)
  endif
  RETURN

proc SetMethodCode( cForm, cControl, cMethod, bCode )
*****************************************************
  local k

  k:=GetControlIndex( cControl, cForm )
  DO CASE
  CASE k=0
  CASE _HMG_aControlType[k] = "COMBO"
    do case
    case cMethod='DISPLAYCHANGE'
      _HMG_aControlProcedures[k] :=  bCode
    case cMethod='LISTDISPLAY'
      _HMG_aControlInputMask[k] := bCode
    case cMethod='LOSTFOCUS'
      _HMG_aControllostFocusProcedure[k] :=  bCode
    case cMethod='GOTFOCUS'
      _HMG_aControlGotFocusProcedure[k] :=  bCode
    case cMethod='CHANGE'
      _HMG_aControlChangeProcedure[k] :=  bCode
    case cMethod='ENTER'
      _HMG_aControlDblClick[k] :=  bCode
    case cMethod='LISTCLOSE'
      _HMG_aControlPicture[k] :=  bCode
    endcase
  CASE _HMG_aControlType[k] = "TEXT"
    do case
    case cMethod='LOSTFOCUS'
      _HMG_aControllostFocusProcedure[k] :=  bCode
    case cMethod='GOTFOCUS'
      _HMG_aControlGotFocusProcedure[k] :=  bCode
    case cMethod='CHANGE'
      _HMG_aControlChangeProcedure[k] :=  bCode
    case cMethod='ENTER'
      _HMG_aControlDblClick[k] :=  bCode
    endcase
  CASE _HMG_aControlType[k] = "EDIT"
    do case
    case cMethod='LOSTFOCUS'
      _HMG_aControllostFocusProcedure[k] :=  bCode
    case cMethod='GOTFOCUS'
      _HMG_aControlGotFocusProcedure[k] :=  bCode
    case cMethod='CHANGE'
      _HMG_aControlChangeProcedure[k] :=  bCode
    endcase
  CASE _HMG_aControlType[k] = "GRID"
    do case
    case cMethod='LOSTFOCUS'
      _HMG_aControllostFocusProcedure[k] :=  bCode
    case cMethod='GOTFOCUS'
      _HMG_aControlGotFocusProcedure[k] :=  bCode
    case cMethod='CHANGE'
      _HMG_aControlChangeProcedure[k] :=  bCode
    endcase
  ENDCASE
  RETURN

#include "InputWindowEx.prg"
