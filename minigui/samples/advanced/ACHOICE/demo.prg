/*
  MINIGUI - Harbour Win32 GUI library Demo

  Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  Author: S.Rathinagiri <srgiri@dataone.in>

  Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "hmg.ch"

memvar _aItems, _nSelected, lAnyWhereSearch

Function Main
LOCAL aCountries := HB_ATOKENS( MEMOREAD( "Countries.lst" ), CRLF )

aCountries := {}
for n := 1 to 100
   aadd( aCountries, { hb_ntos(n) + ". покитеиа / йяатос with a very long name ", hb_ntos(n) } )
next

set font to _GetSysFont() , 10

define window sample at 0,0 width 640 height 480 title "HMG Achoice Demo" main
   define label label1
      row 10
      col 20
      width 100
      value "Name"
   end label
   define textbox textbox1
      row 10
      col 110
      width 180
      on enter sample.textbox2.setfocus
   end textbox
   define label label2
      row 40
      col 20
      width 100
      value "Country"
   end label
   define btntextbox textbox2
      row 40
      col 110
      width 180
      action iif(empty(doachoice(aCountries)),nil,sample.textbox3.setfocus)
      ongotfocus sample.label4.visible:=.t.
      onlostfocus sample.label4.visible:=.f.
      on enter iif(! empty(sample.textbox2.value),doachoice(aCountries),sample.textbox3.setfocus)
   end btntextbox
   define label label3
      row 70
      col 20
      width 100
      value "City"
   end label
   define textbox textbox3
      row 70
      col 110
      width 180
      on enter sample.textbox1.setfocus
   end textbox
   define label label4
      row 100
      col 110
      width 140
      value "F2 - select country"
      fontbold .t.
      visible .f.
   end label
   on key F2 action iif(thiswindow.focusedcontrol=='textbox2',doachoice(aCountries),nil)
end window
sample.center
sample.activate
Return Nil


FUNCTION DoAchoice( aItems )
LOCAL nTop := 10
LOCAL nLeft := 300
LOCAL nDefault := 1
LOCAL nSelected
LOCAL control := thiswindow.focusedcontrol
LOCAL value := GetProperty( thiswindow.name, control, 'value' )
LOCAL aList := {}, aSaveItems, lMultiDim := .F.
nTop := GetProperty(thiswindow.name,control,'row')
nLeft := GetProperty(thiswindow.name,control,'col') + GetProperty(thiswindow.name,control,'width') + 5


if valtype( aItems[1] ) == "A"
   aeval( aItems, {|e| aadd( aList, e[1])} )
   aSaveItems := Aclone( aItems )
   aItems := aList
   lMultiDim := .T. 
endif

if len(alltrim(value)) > 0
   nDefault := ascan(aItems,value)
endif   

nSelected := HMG_AChoice( nTop, nLeft, , , aItems, nDefault )

setproperty(thiswindow.name,control,'value',iif(nSelected > 0,aItems[nSelected],''))
if lMultiDIm
   aItems := AClone( aSaveItems )
   msginfo( iif( nSelected > 0, aItems[nSelected, 2], "Esc pressed. Return value is: "+ hb_ntos(nSelected) ) )
endif   
return nSelected

STATIC FUNCTION HMG_Achoice(nTop,nLeft,nBottom,nRight,aList,nDefault,lAnyWhere)
LOCAL nRow := thiswindow.row + GetTitleHeight()
LOCAL nCol := thiswindow.col
LOCAL nWindowWidth := thiswindow.width
LOCAL nWindowHeight := thiswindow.height
LOCAL nWidth
LOCAL nHeight

private _aItems := aclone(aList)
private _nSelected := 0
private lAnyWhereSearch

default lAnyWhere := .f.
default nDefault := 0
default nBottom := thiswindow.height - GetTitleHeight() - 10
default nRight := thiswindow.width - 2*GetBorderWidth() - 10
lAnyWhereSearch := lAnyWhere
nWidth := iif(nRight < nWindowWidth,  nRight - nLeft,nWindowWidth - nLeft - 2*GetBorderWidth() - 10)
nHeight := iif(nBottom < nWindowHeight, nBottom - nTop,nWindowHeight - nTop - GetTitleHeight() - 10)
if iswindowdefined(_HMG_aChoice)
   release window _HMG_aChoice
endif

DEFINE WINDOW _HMG_aChoice AT nRow+nTop, nCol+nLeft ;
            WIDTH  nWidth  ;
            HEIGHT nHeight ;
            TITLE '' ;
            MODAL ;
            NOCAPTION ;
            NOSIZE

   define textbox _edit
      row 5
      col 5
      width nWidth - 2*GetBorderWidth()
      on change     _aChoiceTextChanged( lAnyWhere )
      on enter      _aChoiceSelected()
      on gotfocus   _achoicelistchanged()
   end textbox
   define listbox _list
      row 30
      col 5
      width nWidth - 2*GetBorderWidth()
      height nHeight - 50
      items aList
      on change _achoicelistchanged()
      on dblclick _aChoiceSelected()
   end listbox
END WINDOW

ON KEY UP     OF _HMG_achoice ACTION _aChoiceDoUpKey()
ON KEY DOWN   OF _HMG_achoice ACTION _aChoiceDoDownKey()
ON KEY PRIOR  OF _HMG_achoice ACTION _aChoicePgUpKey()
ON KEY NEXT   OF _HMG_achoice ACTION _aChoicePgDownKey()
ON KEY ESCAPE OF _HMG_achoice ACTION _aChoiceDoEscKey()

if len(_aItems) > 0
   if nDefault > 0
      _HMG_aChoice._list.value := nDefault
      _HMG_aChoice._edit.value := _aItems[nDefault]
   endif
endif        
_HMG_Achoice.activate
return _nSelected

STATIC PROC _aChoiceTextChanged( lAnyWhere )
   LOCAL cCurValue := _HMG_aChoice._edit.value 
   LOCAL nItemNo
   LOCAL lFound := .f.
   
   for nItemNo := 1 to len(_aitems)
      if lAnyWhere
         if at(upper(cCurValue),upper(_aItems[nItemNo])) > 0
            _HMG_aChoice._list.value := nItemNo
            lFound := .t.
            exit
         endif            
      else
         if upper(left(_aitems[nItemNo],len(cCurValue))) == upper(cCurValue)
            _HMG_aChoice._list.value := nItemNo
            lFound := .t.
            exit
         endif
      endif   
   next nItemNo
   if .not. lFound
      _HMG_aChoice._list.value := 0
   endif
return 

STATIC FUNCTION _aChoiceselected
if _HMG_aChoice._List.value > 0
   _nSelected := _HMG_aChoice._list.value
else
   _nSelected := 0
endif   
release window _HMG_aChoice
return nil

STATIC FUNCTION _aChoiceDoUpKey()
   IF _HMG_aChoice._List.value > 1 
      _HMG_aChoice._List.value := _HMG_aChoice._List.value - 1
      _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value)
      textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
   ENDIF
return nil
  
STATIC FUNCTION _aChoiceDoDownKey()
   IF _HMG_aChoice._List.value < _HMG_aChoice._List.ItemCount 
      _HMG_aChoice._List.value := _HMG_aChoice._List.value + 1
      _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value) 
      textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
   ENDIF
return nil

STATIC FUNCTION _aChoicePgUpKey()
   IF _HMG_aChoice._List.value > 1 
      IF _HMG_aChoice._List.value - 23 < 1
         _HMG_aChoice._List.value := 1
      ELSE
         _HMG_aChoice._List.value := _HMG_aChoice._List.value - 23
      ENDIF
      _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value)
      textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
   ENDIF
return nil
  
STATIC FUNCTION _aChoicePgDownKey()
   IF _HMG_aChoice._List.value < _HMG_aChoice._List.ItemCount 
      IF _HMG_aChoice._List.value + 23 > _HMG_aChoice._List.ItemCount 
         _HMG_aChoice._List.value := _HMG_aChoice._List.ItemCount
      ELSE
         _HMG_aChoice._List.value := _HMG_aChoice._List.value + 23
      ENDIF
      _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value) 
      textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
   ENDIF
return nil

STATIC FUNCTION _aChoiceDoEscKey()
_nSelected := 0
release window _HMG_aChoice
return nil

STATIC FUNCTION _achoicelistchanged
if upper(this.name) == "_EDIT" .and. upper(thiswindow.name) == "_HMG_ACHOICE" .and. .not. lAnyWhereSearch
   _HMG_aChoice._edit.value := _HMG_aChoice._List.item(_HMG_aChoice._List.value) 
   textboxeditsetsel("_HMG_aChoice","_Edit",0,-1)
endif   
return nil

#define EM_SETSEL		177

STATIC FUNCTION textboxeditsetsel(cParent,cControl,nStart,nEnd)
   LOCAL i := GetControlIndex ( cControl, cParent )

   if i == 0
      Return Nil
   EndIf

   SendMessage( _HMG_aControlhandles [i], EM_SETSEL, nStart, nEnd )
return nil
