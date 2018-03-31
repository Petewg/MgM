#include "hmg.ch"

/***/

Function Main()
	//
	Load Window Mdi_5Main As frmMain
	CrearMenuPpal()
	frmMain.Center
	frmMain.Activate
	//
Return( Nil )

/***/

Function CrearMenuPpal()
	//
	Define Main Menu Of frmMain
		Define Menu PopUp "&Operaciones"
			MenuItem "&Operación 1" ; 
				Action CrearChild( 1 )
			Separator
			MenuItem "&Operación 2"	;
				Action CrearChild( 2 )
			Separator
			MenuItem "&Operación 3"	;
				Action CrearChild( 3 )
			Separator
			MenuItem "&Salir" ;
				Action ThisWindow.Release()
		End PopUp
		Define Menu PopUp "&Ventanas"
			PopUp '&Tiled'
				MenuItem '&Horizontal' ;
					Action WinChildTile( .F. )
				MenuItem '&Vertical' ;
					Action WinChildTile( .T. )
			End PopUp
			MenuItem '&Cascade' ;
				Action WinChildCascade()
			MenuItem '&Maximize' ;
				Action WinChildMaximize()
			Separator
			MenuItem "&Listar" ;
				Action MostrarVentanasCargadas()
		End PopUp
		Define Menu PopUp "&Ayuda"
			MenuItem 'HMG Version' ;
				Action MsgInfo( MiniGuiVersion() )
			MenuItem "&Ayuda" ;
				Action MsgInfo( "MiniGUI MDI Childs Load Demo" )
		End PopUp

	End Menu
	//
Return( Nil )

/***/

Function CrearChild( nChild )
Local cChild:="Child_"+hb_ntos( nChild )
Local row,col,ntitle:=GetTitleHeight()+GetBorderHeight()
Local width:=.77*frmMain.Width,height:=.618*(frmMain.Height-ntitle)
	//
	If !_IsWindowDefined( cChild )
		Declare Window &cChild
		//
                _HMG_ActiveMDIChildIndex := --nChild
		//
		Load Window Mdi_5Child As Child
		//
		SetProperty( cChild, 'Title', cChild )
		//
		On Key Control+F4 Action _CloseActiveMdi()
		On Key Control+F6 Action SwitchToNextWin()
		//
		Switch Val( Right( cChild, 1 ) )
		Case 1
			row := 0
			col := 0
			Exit
		Case 2
			row := ntitle - 1
			col := 22
			Exit
		Case 3
			row := 2*(ntitle - 1)
			col := 44
		End Switch
		//
		MoveWindow ( GetFormHandle(cChild), col, row, width, height, .T. )
	Else
		DoMethod( cChild, 'Center' )
	End If
	//
Return( Nil )

/***/

Function MostrarVentanasCargadas()
Local I,cNombres
	//
	cNombres := ""
	For I := 1 To Len( _HMG_aFormNames )
		cNombres += ( _HMG_aFormNames[ I ] + Chr( 13 ))
	Next I
	MsgInfo( cNombres )
	//
Return( Nil )

/***/

Function WinChildMaximize()
Local ChildHandle
	//
	ChildHandle := GetActiveMdiHandle()
	If aScan ( _HMG_aFormHandles, ChildHandle ) > 0
		#define WM_MDIMAXIMIZE 0x0225
		SendMessage( _HMG_MainClientMDIHandle, WM_MDIMAXIMIZE, ChildHandle, 0 )
	End If
	//
Return( Nil )

/***/

Function WinChildTile(lVert)
	//
	If lVert
		TILE MDICHILDS VERTICAL
	Else
		TILE MDICHILDS HORIZONTAL
	End If
	//
Return( Nil )

/***/

Function WinChildCascade()
	//
	CASCADE MDICHILDS
	//
Return( Nil )

/***/

Function SwitchToNextWin()
Local ChildName, nForm
	//
	GET WINDOWPROPERTY "PROP_FORMNAME" VALUE ChildName
	nForm := Val( Right( ChildName, 1 ) )
	If ++nForm > 3
		nForm := 1
	EndIf
	If !_IsWindowDefined( "Child_" + hb_ntos(nForm) )
		nForm++
	End If
	If _IsWindowDefined( "Child_" + hb_ntos(nForm) )
		DoMethod( "Child_" + hb_ntos(nForm), "SetFocus" )
	End If
	//
Return( Nil )
