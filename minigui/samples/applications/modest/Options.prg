#include "Modest.ch"
#include "MiniGUI.ch"


Memvar aStat


/******
*
*       Options()
*
*       Setting of typical params
*
*/

Procedure Options

Load window Options as wOptions

wOptions.Title := APPNAME + ' - Options'

wOptions.txbName.Value := aStat[ 'DefName' ]
wOptions.cmbType.Value := aStat[ 'DefType' ]
wOptions.spnLen.Value  := aStat[ 'DefLen'  ]
wOptions.spnDec.Value  := aStat[ 'DefDec'  ]

wOptions.cmbRDD.Value        := Iif( ( aStat[ 'RDD' ] == 'DBFCDX' ), 2, 1 )
wOptions.txbExpression.Value := aStat[ 'Expression' ]

On key Escape of wOptions Action wOptions.Release
On key Alt+X of wOptions Action { || Done(), ReleaseAllWindows() }

Center window wOptions
Activate window wOptions

Return

****** End of Options ******


/******
*
*       DoSave()
*
*       Save of params
*
*/

Static Procedure DoSave
Local cValue

aStat[ 'RDD' ] := Iif( ( wOptions.cmbRDD.Value == 2 ), 'DBFCDX', 'DBFNTX' )

cValue := AllTrim( wOptions.txbName.Value )
aStat[ 'DefName' ] := Iif( !Empty( cValue ), cValue, 'NEW' )
aStat[ 'DefType' ] := wOptions.cmbType.Value
aStat[ 'DefLen'  ] := wOptions.spnLen.Value
aStat[ 'DefDec'  ] := wOptions.spnDec.Value

cValue := AllTrim( wOptions.txbExpression.Value )
aStat[ 'Expression' ] :=  Iif( !Empty( cValue ), cValue, THIS_VALUE )


Begin ini file MODEST_INI

   // Common parameters
     
   Set Section 'Common' Entry 'RDD'        to aStat[ 'RDD' ]
   Set Section 'Common' Entry 'Expression' to aStat[ 'Expression' ]
      
   // Field characterizations which are used at the new fields creation
     
   Set Section 'Field' Entry 'Field_Name' to aStat[ 'DefName' ]
   Set Section 'Field' Entry 'Field_Type' to aStat[ 'DefType' ]
   Set Section 'Field' Entry 'Field_Len'  to aStat[ 'DefLen'  ]
   Set Section 'Field' Entry 'Field_Dec'  to aStat[ 'DefDec'  ]
   
End Ini

// Show selected RDD name in status row

SetRDDName()

Return

****** End of DoSave ******
