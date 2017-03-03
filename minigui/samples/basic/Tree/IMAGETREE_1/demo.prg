#include "minigui.ch"

Function main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 360 ;
		HEIGHT 480 ;
		TITLE 'Three-State Checkboxes TreeView Demo' ;
		MAIN ;
		ON INIT SetTreeCargo()

		DEFINE MAIN MENU
			POPUP '&File'
				ITEM 'Get Tree Value' ACTION MsgInfo( Str ( Form_1.Tree_1.Value ) ) 
				ITEM 'Set Tree Value' ACTION Form_1.Tree_1.Value := 10
				ITEM 'Change Current Item Image' ACTION ChangeItemImage()
				ITEM 'Get Current Item Image' ACTION GetItemImage()
			END POPUP
		END MENU

		DEFINE TREE Tree_1 AT 10,10 WIDTH 320 HEIGHT 400 VALUE 3;
		NODEIMAGES {"0.bmp"} ON DBLCLICK ChangeItemImage()
	
		 	NODE 'Root' IMAGES {"2.bmp"}
				TREEITEM 'Item 1.1' 
				TREEITEM 'Item 1.2' IMAGES {"1.bmp"}
				TREEITEM 'Item 1.3' 
			

				NODE 'Docs' IMAGES {"2.bmp"}
	
					TREEITEM 'Docs 1'
					
				END NODE

				NODE 'Notes' IMAGES {"2.bmp"}
					TREEITEM 'Notes 1'
					TREEITEM 'Notes 2' 
					TREEITEM 'Notes 3' 
					TREEITEM 'Notes 4' 
					TREEITEM 'Notes 5' 
				END NODE

						
				NODE 'Books' IMAGES {"2.bmp"}
					TREEITEM 'Book 1'
					TREEITEM 'Book 2' 
	
					NODE 'Book 3' IMAGES {"2.bmp"}
						TREEITEM 'Book 3.1' 
						TREEITEM 'Book 3.2' 
					END NODE

				END NODE
			END NODE
		END TREE

	END WINDOW

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return Nil


Function SetTreeCargo()
	Local i, aTreeImages := {}

	For i := 1 To Form_1.Tree_1.ItemCount 
		aAdd( aTreeImages, 0 )
	Next

	aTreeImages[ 1 ] := 2
	aTreeImages[ 3 ] := 1
	aTreeImages[ 4 ] := 2
	aTreeImages[ 6 ] := 2
	aTreeImages[ 12 ] := 2
	aTreeImages[ 15 ] := 2

	Form_1.Tree_1.Cargo := aTreeImages

Return Nil


Function ChangeItemImage()
	Local aTreeImages := Form_1.Tree_1.Cargo
	Local i := Form_1.Tree_1.Value

        aTreeImages[ i ] := iif( Empty( aTreeImages[ i ] ), 1, iif( aTreeImages[ i ] > 1, 0, 2 ) )

	Form_1.Tree_1.Image( i ) := { iif( Empty( aTreeImages[ i ] ), '0.bmp', iif( aTreeImages[ i ] > 1, '2.bmp', '1.bmp' ) ) }

	Form_1.Tree_1.Cargo := aTreeImages

Return Nil


Function GetItemImage()
	Local aTreeImages := Form_1.Tree_1.Cargo
	Local i := Form_1.Tree_1.Value

	MsgInfo( iif( Empty( aTreeImages[ i ] ), '0.bmp', iif( aTreeImages[ i ] > 1, '2.bmp', '1.bmp' ) ) )

Return Nil
