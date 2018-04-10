/* 
 * MINIGUI - Harbour Win32 GUI library Demo 
 * 
 */ 
  
#include "minigui.ch" 
#include "tsbrowse.ch" 
  
REQUEST DBFCDX 
  
FIELD KODS, NAME, ID 
  
MEMVAR oWnd, oBrw1, oMain

*-----------------------------------
FUNCTION Main()
*-----------------------------------
 LOCAL cFile := "datab" 
 LOCAL hSplit, nI, nK, nY, nX, nX1, nW, nH, cPic
 LOCAL oCol, cAls, cWnd := 'win_1', cNam
 LOCAL aColumn, aHeader, aWidth, aOrder, aEdit, aAlign, aFAlign, aPicture
 LOCAL aFixLite, aNoDescend, aOnGotFocusSelect, aEmptyValToChar
 LOCAL nWdt := 210, nHgt := 10, nLen := nWdt - 10

   RddSetDefault("DBFCDX") 
  
   SET CENTURY      ON 
   SET DATE         GERMAN 
   SET DELETED      ON 
   SET EXCLUSIVE    ON 
   SET EPOCH TO     2000 
   SET AUTOPEN      ON 
   SET EXACT        ON 
   SET SOFTSEEK     ON 
  
   SET NAVIGATION   EXTENDED 
   SET FONT TO "Arial", 11 

   *--------------------------------
   SET OOP ON
   *--------------------------------

   Create_Dbf( cFile )
  
   DEFINE FONT FontBold FONTNAME _HMG_DefaultFontName ; 
                            SIZE _HMG_DefaultFontSize BOLD

   USE &cFile ALIAS base NEW 
  
   OrdSetFocus("NAM") 
   dbGoTop() 
 
   cAls := Alias() 
  
	DEFINE WINDOW &cWnd AT 0,0 WIDTH 650 + nWdt HEIGHT 500 ;
		TITLE 'MiniGUI Demo for Window\TsBrowse :UserKeys and events' ;
		ICON  'hmg_ico' ;
		MAIN  NOMAXIMIZE NOSIZE ; 
		ON RELEASE    dbCloseAll() ;
		ON MOUSECLICK ClickProcedure()

      PUBL oMain := ThisWindow.Object
      PRIV oWnd  := oMain, oBrw1

      WITH OBJECT oWnd
      :oUserKeys:Cargo := oKeyData() 
      :oUserKeys:Cargo:Set(1, "Harbour.")
      :oUserKeys:Cargo:Set(2, "MiniGui.")
      :oUserKeys:Cargo:Set(3, "OK !")

      :UserKeys('M_1_1' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_1_2' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_1_3' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_1_4' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_1_5' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_1_6' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_1_7' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_1_8' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_1_9' , {|     | MsgBox( oWnd:Title+' | '+ cValToChar(oWnd:VarName)     , This.Name ) })
      :UserKeys('M_1_E' , {|     | ThisWindow.Release() })
                        
      :UserKeys('M_2_1' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_2_2' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_2_3' , {|o,k,p| MsgBox( o:ClassName+"|"+cValToChar(k)+"|"+cValToChar(p), This.Name ) })
      :UserKeys('M_2_4' , {|o    | MsgBox( o:Cargo:Get(1)+" "+o:Cargo:Get(3)              , This.Name ) })
      :UserKeys('M_2_5' , {|o    | MsgBox( o:Cargo:Get(2)+" "+o:Cargo:Get(3)              , This.Name ) })
                        
      :UserKeys('M_3_1' , {|     | MsgBox( ( This.Name )+"|"+( ThisWindow.Name )          , oWnd:Name ) })
      :UserKeys('M_3_2' , {|     | MsgBox( ( This.Name )+"|"+( ThisWindow.Name )          , oWnd:Name ) })
      :UserKeys('M_3_3' , {|     | MsgBox( ( This.Name )+"|"+( ThisWindow.Name )          , oWnd:Name ) })
                                                             
      :UserKeys('FRM_0' , {|     | PostMessage( oWnd:Handle, WM_LBUTTONDOWN, 0, 0 ), DoEvents()  })

      :UserKeys('FRM_1' , {|o    | MsgBox( ( This.Name )+" | "+o:Cargo:Get(1)+( This.FRM_1.Cargo ), oWnd:Name ) })
      :UserKeys('FRM_2' , {|o    | MsgBox( ( This.Name )+" | "+o:Cargo:Get(2)+( This.FRM_2.Cargo ), oWnd:Name ) })
      :UserKeys('FRM_3' , {|o    | MsgBox( ( This.Name )+" | "+o:Cargo:Get(3)+( This.FRM_3.Cargo ), oWnd:Name ) })
      END WITH

		DEFINE MAIN MENU 
			POPUP 'MENU_1'
				ITEM 'Item main menu 1.1'	ACTION oWnd:UserKeys( This.Name, {3,2,1,0} )       NAME M_1_1 IMAGE 'n1'
				ITEM 'Item main menu 1.2'	ACTION oWnd:UserKeys( This.Name, {1,2,3,4} )       NAME M_1_2 IMAGE 'n2'
				ITEM 'Item main menu 1.3'	ACTION oWnd:UserKeys( This.Name, {'A','B'} )       NAME M_1_3 IMAGE 'n3'
				ITEM 'Item main menu 1.4'	ACTION oWnd:UserKeys( This.Name, {'C'}     )       NAME M_1_4 IMAGE 'n4'
				ITEM 'Item main menu 1.5'	ACTION oWnd:UserKeys( This.Name )                  NAME M_1_5 IMAGE 'n5'
				ITEM 'Item main menu 1.6'	ACTION oWnd:UserKeys( This.Name )                  NAME M_1_6 IMAGE 'n6'
				ITEM 'Item main menu 1.7'	ACTION oWnd:UserKeys( This.Name )                  NAME M_1_7 IMAGE 'n7'
 				ITEM 'Item main menu 1.8'	ACTION This_Msg( oWnd:GetListType(), 'ALL TYPES' ) NAME M_1_8 IMAGE 'n8'
 				ITEM 'Item main menu 1.9'	ACTION Modal_Click()                               NAME M_1_9 IMAGE 'n9'
				SEPARATOR
				ITEM 'Exit'             	ACTION oWnd:UserKeys( This.Name )        NAME M_1_E
			END POPUP
			POPUP 'MENU_2'
				ITEM 'Item main menu 2.1'	ACTION oWnd:UserKeys( This.Name, 2.1 )   NAME M_2_1 IMAGE 'n1'
				ITEM 'Item main menu 2.2'	ACTION oWnd:UserKeys( This.Name, 2.2 )   NAME M_2_2 IMAGE 'n2'
				ITEM 'Item main menu 2.3'	ACTION oWnd:UserKeys( This.Name, 2.3 )   NAME M_2_3 IMAGE 'n3'
				ITEM 'Item main menu 2.4'	ACTION oWnd:UserKeys( This.Name )        NAME M_2_4 IMAGE 'n4'
				ITEM 'Item main menu 2.5'	ACTION oWnd:UserKeys( This.Name )        NAME M_2_5 IMAGE 'n5'
			END POPUP
			POPUP 'MENU_3'
				ITEM 'Item main menu 3.1'	ACTION oWnd:UserKeys( This.Name )        NAME M_3_1 IMAGE 'n1'
				ITEM 'Item main menu 3.2'	ACTION oWnd:UserKeys( This.Name )        NAME M_3_2 IMAGE 'n2'
				ITEM 'Item main menu 3.3'	ACTION oWnd:UserKeys( This.Name )        NAME M_3_3 IMAGE 'n3'
			END POPUP
		END MENU

  		DEFINE STATUSBAR
			STATUSITEM '' 
			STATUSITEM '' WIDTH 300
		END STATUSBAR

		This.StatusBar.Item(2) := "Right click ( TBrowse ) for context menu"

		DEFINE SPLITBOX HANDLE hSplit

		DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 16,16 FLAT
		
			BUTTON  Rec_Add ;
			PICTURE 'page_new' ;
			ACTION  oBrw1:PostMsg( WM_KEYDOWN, VK_F2, 0 ) ;
			TOOLTIP 'Add new record'+space(9)+' F2'
		
			BUTTON  Rec_Del ;
			PICTURE 'page_del' ;
			ACTION  oBrw1:PostMsg( WM_KEYDOWN, VK_F3, 0 ) ;
			TOOLTIP 'Delete selected record'+space(9)+' F3'
		
			BUTTON  Rec_Edit ;
			PICTURE 'page_edit' ;
			ACTION  oBrw1:PostMsg( WM_KEYDOWN, VK_F4, 0 ) ;
			TOOLTIP 'Edit selected record'+space(9)+' F4' ;
			SEPARATOR
		
			BUTTON  Rec_Print ;
			PICTURE 'printer' ;
			ACTION  oBrw1:PostMsg( WM_KEYDOWN, VK_F5, 0 ) ;
			TOOLTIP 'Print table'+space(9)+' F5' ;
			SEPARATOR ;
			DROPDOWN

			DEFINE DROPDOWN MENU BUTTON Rec_Print 
				ITEM 'Item print report 1  default'	ACTION oBrw1:UserKeys( This.Name ) NAME Report_1 IMAGE 'n1'
				ITEM 'Item print report 2'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_2 IMAGE 'n2'
				ITEM 'Item print report 3'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_3 IMAGE 'n3'
				ITEM 'Item print report 4'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_4 IMAGE 'n4'
				ITEM 'Item print report 5'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_5 IMAGE 'n5'
				ITEM 'Item print report 6'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_6 IMAGE 'n6'
				ITEM 'Item print report 7'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_7 IMAGE 'n7'
				ITEM 'Item print report 8'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_8 IMAGE 'n8'
				ITEM 'Item print report 9'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_9 IMAGE 'n9'
			END MENU
		
			BUTTON  Rec_Sort ;
			PICTURE 'page_nr' ;
			ACTION  oBrw1:PostMsg( WM_KEYDOWN, VK_F6, 0 ) ;
			TOOLTIP 'Sorting ...'+space(9)+' F6' ;
			SEPARATOR
		
			BUTTON  Rec_Find ;
			PICTURE 'page_fltr' ;
			ACTION  oBrw1:PostMsg( WM_KEYDOWN, VK_F7, 0 ) ;
			TOOLTIP 'Find record'+space(9)+' F7' ;
			SEPARATOR
		
			BUTTON  Rec_Expo ;
			PICTURE 'page_next' ;
			ACTION  oBrw1:PostMsg( WM_KEYDOWN, VK_F8, 0 ) ;
			TOOLTIP 'Export table'+space(9)+' F8' ;
			SEPARATOR ;
			DROPDOWN

			DEFINE DROPDOWN MENU BUTTON Rec_Expo 
				ITEM 'Item export to Excel  default' 	ACTION oBrw1:UserKeys( This.Name ) NAME Export_Excel IMAGE 'n1'
				ITEM 'Item export to Xml 1'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_Xml1  IMAGE 'n2'
				ITEM 'Item export to Xml 2'		ACTION oBrw1:UserKeys( This.Name ) NAME Report_Xml2  IMAGE 'n3'
			END MENU
		
		END TOOLBAR
		
		DEFINE TOOLBAR ToolBar_3 BUTTONSIZE 16,16 FLAT
		
			BUTTON  FRM_0 ;
			PICTURE 'page_nr' ;
			ACTION  oWnd:UserKeys( This.Name ) ;
			TOOLTIP 'Create form'+space(9)+'<1>, <2>, <3>' ;
			SEPARATOR 

			BUTTON  Typ_Print ;
			PICTURE 'printer' ;
			ACTION  This_Msg( oWnd:GetListType(), 'ALL TYPES' ) ;
			TOOLTIP 'List all types control for window' ;
			SEPARATOR 
		
			BUTTON  Cnt_List ;
			PICTURE 'page_fltr' ;
			ACTION  This_Msg( oWnd:GetObj4Type('BUTT,LABE'), 'TYPE $ "BUTT,LABE"' ) ;
			TOOLTIP 'List name controls for window ( Type $ "BUTT,LABE" )' ;
			SEPARATOR 
		
			BUTTON  Cnt_Label ;
			PICTURE 'page_next' ;
			ACTION  This_Msg( oWnd:GetObj4Type('LABEL'), 'TYPE = "LABEL"' ) ;
			TOOLTIP 'List name controls for window ( Type = "LABEL" )' ;
			SEPARATOR
		
			BUTTON  Cnt_Names ;
			PICTURE 'page_new' ;
			ACTION  This_Msg( oWnd:GetObj4Name('Cnt_,Rec_'), 'NAME $ "Cnt_,Rec_"' ) ;
			TOOLTIP 'List name controls for window ( Name $ "Cnt_,Rec_" )' ;
			SEPARATOR 
		
			BUTTON  Cnt_Result ;
			PICTURE 'page_edit' ;
			ACTION  ( oWnd:SendMsg(3), ;
			This_Msg( oWnd:oCargo:Eval(), "SAVE" ), ;
			oBrw1:SetFocus() ) ;
			TOOLTIP 'Save and view values LABEL, GETBOX ( SendMessage. key 3 from win_1 )'
		
		END TOOLBAR
		
		DEFINE TOOLBAR ToolBar_2 CAPTION space(50) BUTTONSIZE 16,16 FLAT

			BUTTON  Set_Mode ;
			PICTURE 'tools' ;
			ACTION  oBrw1:PostMsg( WM_KEYDOWN, VK_F9, 0 ) ;
			TOOLTIP 'Setting ...'+space(9)+' F9' ;
			DROPDOWN

			DEFINE DROPDOWN MENU BUTTON Set_Mode
				ITEM 'Item set mode VK_RETURN to Edit  default'	ACTION oBrw1:UserKeys( This.Name ) NAME SetMode_1 IMAGE 'n1'
				ITEM 'Item set mode VK_RETURN to Select'	ACTION oBrw1:UserKeys( This.Name ) NAME SetMode_2 IMAGE 'n2'
			END MENU
		
		END TOOLBAR

		END SPLITBOX

      aColumn  := { "KODS"               , "NAME"        , "KOLV"  , "CENA"                 , "ID"    }
      aHeader  := { "Product"+CRLF+"code", "Denomination", "Amount", "Price"+CRLF+"for unit", "Id"    }
      aWidth   := { 110                  , 190           , 110     , 110                    , 80      }    
      aOrder   := { "KOD"                , "NAM"         ,         ,                        ,         }        
      aEdit    := { .F.                  , .T.           , .T.     , .T.                    , .F.     }
      aAlign   := { 1                    , 0             , 2       , 2                      , 1       }
      aFAlign  := { 1                    , 0             , 2       , 2                      , 1       } 
      aPicture := {                      ,               ,         ,                        , "99999" }

		nK       := len(aColumn)

      aFixLite          := array(nK); aFill(aFixLite         , .T.)
      aNoDescend        := array(nK); aFill(aNoDescend       , .T.)
      aOnGotFocusSelect := array(nK); aFill(aOnGotFocusSelect, .T.)
      aEmptyValToChar   := array(nK); aFill(aEmptyValToChar  , .T.)

		nY := GetWindowHeight(hSplit)
      nX := 10
      nW := This.ClientWidth  - nX * 2 - nWdt
      nH := This.ClientHeight - GetWindowHeight( This.StatusBar.Handle ) - nY - 1
		
      DEFINE TBROWSE   oBrw1   AT nY, nX WIDTH nW HEIGHT nH ;
             ALIAS     cAls    CELL ;
             COLUMNS   aColumn

      :hFontHead    := GetFontHandle( "FontBold" ) 
      :hFontFoot    := :hFontHead 
 
      :LoadFields(.T.) 

      :SetDeleteMode(.T., .F.) 

      :aSortBmp     := { LoadImage("br_up"), LoadImage("br_dn") } 
      :bChange      := {|obr| obr:DrawFooters() } 
      
      :nWheelLines  := 1 
      :nClrLine     := COLOR_GRID 
      :nHeightCell  += 5 
      :nHeightHead  += 5 
      :nHeightFoot  := :nHeightCell
      :lNoGrayBar   := .F. 
      :lDrawFooters := .T. 
      :lFooting     := .T. 
      :lNoVScroll   := .F. 
      :lNoHScroll   := .T. 
      :nFreeze      := 1 
      :lLockFreeze  := .T. 
      :nFireKey     := VK_F4                       // default Edit 
  
      :SetColor( { CLR_FOCUSB }, { { |a,b,c| If( c:nCell == b, {Rgb( 66, 255, 236), Rgb(209, 227, 248)}, ;  
                                                               {Rgb(220, 220, 220), Rgb(220, 220, 220)} ) } } )            

      For nI := 1 To nK
          oCol                   := :aColumns        [ nI ]
          oCol:cHeading          := aHeader          [ nI ]
          oCol:nWidth            := aWidth           [ nI ]
          oCol:lEdit             := aEdit            [ nI ]
          oCol:nAlign            := aAlign           [ nI ] 
          oCol:nFAlign           := aFAlign          [ nI ]
          oCol:lFixLite          := aFixLite         [ nI ]
          oCol:lNoDescend        := aNoDescend       [ nI ]
          oCol:lOnGotFocusSelect := aOnGotFocusSelect[ nI ]
          oCol:lEmptyValToChar   := aEmptyValToChar  [ nI ]
          If ! empty(aOrder  [ nI ])
             oCol:cOrder         := aOrder           [ nI ]
          EndIf
          If ! empty(aPicture[ nI ])
             oCol:cPicture       := aPicture         [ nI ]
          EndIf
          If     oCol:cName == "KODS"
		       oCol:cFooting := { |nc,obr| nc := (obr:cAlias)->( OrdKeyNo() ), ;
                                         iif( empty(nc), '', hb_ntos(nc) ) } 
          ElseIf oCol:cName == "ID"
             oCol:cFooting := { |nc,obr| nc := (obr:cAlias)->( OrdKeyCount() ), ;
                                         iif( empty(nc), '', hb_ntos(nc) ) } 
          EndIf
      Next

      :SetIndexCols( :nColumn('KODS'), :nColumn('NAME') ) 
      :SetOrder( :nColumn('NAME') ) 

      if :nLen > :nRowCount() 
         :ResetVScroll( .T. ) 
         :oHScroll:SetRange(0,0) 
      EndIf 

      :bLDblClick       := {|up1,up2,nfl,obr | up1 := up2 := nfl := Nil, ;
                                               obr:PostMsg( WM_KEYDOWN, obr:nFireKey, 0 ) }
      :UserKeys(VK_RETURN     , {|obr        | obr:PostMsg( WM_KEYDOWN, obr:nFireKey, 0 ) })
      :UserKeys(VK_F2         , {|obr,nky,cky| Rec_Addr(obr,nky,cky)})
      :UserKeys(VK_F3         , {|obr,nky,cky| Rec_Delr(obr,nky,cky)})
      :UserKeys(VK_F5         , {|obr,nky,cky| Rec_Prn1(obr,nky,cky)})
      :UserKeys(VK_F6         , {|obr,nky,cky| Rec_Ordn(obr,nky,cky)})
      :UserKeys(VK_F7         , {|obr,nky,cky| Rec_Find(obr,nky,cky)})
      :UserKeys(VK_F8         , {|obr,nky,cky| Rec_Expo(obr,nky,cky)})
      :UserKeys(VK_F9         , {|obr,nky,cky| Set_Mode(obr,nky,cky)})
      :UserKeys('RMenu_1'     , {|obr,nky,cky| Msg_Keys(obr,nky,cky)})
      :UserKeys('RMenu_2'     , {|obr,nky,cky| Msg_Keys(obr,nky,cky)})            
      :UserKeys('RMenu_3'     , {|obr,nky,cky| Msg_Keys(obr,nky,cky)})
      :UserKeys('RMenu_4'     , {|obr,nky,cky| Msg_Keys(obr,nky,cky)})
      :UserKeys('RMenu_5'     , {|obr,nky,cky| Msg_Keys(obr,nky,cky)})
      :UserKeys('RMenu_6'     , {|obr,nky,cky| Msg_Keys(obr,nky,cky)})
      :UserKeys('RMenu_7'     , {|obr,nky,cky| Msg_Keys(obr,nky,cky)})
      :UserKeys('RMenu_8'     , {|obr,nky,cky| Msg_Keys(obr,nky,cky)})
      :UserKeys('RMenu_9'     , {|obr,nky,cky| Msg_Keys(obr,nky,cky)})
      :UserKeys('Report_1'    , {|obr,nky,cky| Rec_Prn1(obr,nky,cky)})
      :UserKeys('Report_2'    , {|obr,nky,cky| Rec_Prn2(obr,nky,cky)})            
      :UserKeys('Report_3'    , {|obr,nky,cky| Rec_Prn3(obr,nky,cky)})
      :UserKeys('Report_4'    , {|obr,nky,cky| Rec_Prn4(obr,nky,cky)})
      :UserKeys('Report_5'    , {|obr,nky,cky| Rec_Prn5(obr,nky,cky)})
      :UserKeys('Report_6'    , {|obr,nky,cky| Rec_Prn6(obr,nky,cky)})
      :UserKeys('Report_7'    , {|obr,nky,cky| Rec_Prn7(obr,nky,cky)})
      :UserKeys('Report_8'    , {|obr,nky,cky| Rec_Prn8(obr,nky,cky)})
      :UserKeys('Report_9'    , {|obr,nky,cky| Rec_Prn9(obr,nky,cky)})
      :UserKeys('SetMode_1'   , {|obr,nky,cky| Set_Mode(obr,nky,cky)})
      :UserKeys('SetMode_2'   , {|obr,nky,cky| Set_Mode(obr,nky,cky)})
      :UserKeys('Export_Excel', {|obr,nky,cky| Rec_Expo(obr,nky,cky)})
      :UserKeys('Report_Xml1' , {|obr,nky,cky| Rec_Expo(obr,nky,cky)})
      :UserKeys('Report_Xml2' , {|obr,nky,cky| Rec_Expo(obr,nky,cky)})
      
      END TBROWSE 
  
      oBrw1:SetNoHoles() 
      oBrw1:SetFocus() 

		DEFINE CONTEXT MENU CONTROL oBrw1
			ITEM 'Item context menu 1'	ACTION oBrw1:UserKeys( This.Name ) NAME RMenu_1 IMAGE 'n1'
			ITEM 'Item context menu 2'	ACTION oBrw1:UserKeys( This.Name ) NAME RMenu_2 IMAGE 'n2'
			ITEM 'Item context menu 3'	ACTION oBrw1:UserKeys( This.Name ) NAME RMenu_3 IMAGE 'n3'
			ITEM 'Item context menu 4'	ACTION oBrw1:UserKeys( This.Name ) NAME RMenu_4 IMAGE 'n4'
			ITEM 'Item context menu 5'	ACTION oBrw1:UserKeys( This.Name ) NAME RMenu_5 IMAGE 'n5'
			ITEM 'Item context menu 6'	ACTION oBrw1:UserKeys( This.Name ) NAME RMenu_6 IMAGE 'n6'
			ITEM 'Item context menu 7'	ACTION oBrw1:UserKeys( This.Name ) NAME RMenu_7 IMAGE 'n7'
			ITEM 'Item context menu 8'	ACTION oBrw1:UserKeys( This.Name ) NAME RMenu_8 IMAGE 'n8'
			ITEM 'Item context menu 9'	ACTION oBrw1:UserKeys( This.Name ) NAME RMenu_9 IMAGE 'n9'
		END MENU

      nY += 20
      nX := This.oBrw1.Width + 20

     @ nY, nX BUTTONEX FRM_1 PICTURE 'n1' CAPTION "" ;
              ACTION ( oWnd:UserKeys( This.Name ), oBrw1:SetFocus() ) ;
              WIDTH 50 HEIGHT 50 ;
              TOOLTIP 'Create form'+space(9)+'<1>' ;
              NOXPSTYLE NOTABSTOP
       This.FRM_1.Cargo := ' Form <1> created !'

       nX1  := nX + This.FRM_1.Width + 2
       cNam := 'Get_1'
     @ nY, nX1 GETBOX &cNam WIDTH 150 ;
              VALUE 'Test oGet:SetKeyEvent(...)' ;
              FONT 'Arial' SIZE 9 ;
              TOOLTIP 'Press F5 or LDblClick' ;
              BACKCOLOR {{255,255,255},{255,255,200},{200,255,255}} ;
              FONTCOLOR {{0,0,0},{255,255,200},{0,0,255}}

       (This.&(cNam).Object):Get:SetKeyEvent( VK_F5, {|o| MsgBox( 'VK_F5 : ' + cValToChar( o:VarGet() ), This.Name ) } )
       (This.&(cNam).Object):Get:SetKeyEvent(  , {|o| MsgBox( 'LDblClick : ' + cValToChar( o:VarGet() ), This.Name ) } )

       nY += This.FRM_1.Height + nHgt

     @ nY, nX BUTTONEX FRM_2 PICTURE 'n2' CAPTION "" ;
              ACTION ( oWnd:UserKeys( This.Name ), oBrw1:SetFocus() ) ;
              WIDTH 50 HEIGHT 50 ;
              TOOLTIP 'Create form'+space(9)+'<2>' ;
              NOXPSTYLE NOTABSTOP
       This.FRM_2.Cargo := ' Form <2> created !'
		
       nY += This.FRM_2.Height + nHgt

     @ nY, nX BUTTONEX FRM_3 PICTURE 'n3' CAPTION "" ;
              ACTION ( oWnd:UserKeys( This.Name ),   ;
                       This_Msg( (This.Object):GetListType(), 'ALL TYPES' ), ;
                       oBrw1:SetFocus() ) ;
              WIDTH 50 HEIGHT 50 ;
              TOOLTIP 'Create form'+space(9)+'<3>' ;
              NOXPSTYLE NOTABSTOP
       This.FRM_3.Cargo := ' Form <3> created !'

       nY += This.FRM_3.Height + nHgt

     @ nY, nX BUTTONEX FRM_4 PICTURE 'n4' CAPTION ""          ;
              ACTION ( oWnd:SendMsg(1, This.FRM_1.Handle),    ; // Do_WindowEventProcedure  for FRM_1 key from win_1
                       oWnd:SendMsg(2, This.FRM_2.Handle),    ; // Do_WindowEventProcedure  for FRM_2 key from win_1
                       oWnd:SendMsg(1),                       ; // Do_WindowEventProcedure  for win_1 key from win_1
                       oWnd:SendMsg(2),                       ; // Do_WindowEventProcedure  for win_1 key from win_1
                       oWnd:GetObj( This.Handle ):SendMsg(1), ; // Do_ControlEventProcedure for FRM_4 key from FRM_4
                       oWnd:GetObj( This.Handle ):SendMsg(2), ; // Do_ControlEventProcedure for FRM_4 key from FRM_4
                       oBrw1:SetFocus() )                     ;
              WIDTH 50 HEIGHT 50 ;
              TOOLTIP 'Test WM_USER+... message ( control and window events )' ;
              NOXPSTYLE NOTABSTOP

     // ---------------------------------------------------------------------------- Control events

       WITH OBJECT oWnd:GetObj( This.FRM_4.Handle )
         :Event( 1, {|ow,ky| This_Msg('Control message ' + "nKey="+cValToChar(ky), ow:Name) } ) 
         :Event( 2, {|ow,ky| This_Msg('Control message ' + "nKey="+cValToChar(ky), ow:Name) } ) 
         // ...
       END WITH 

       nY   += This.FRM_4.Height + nHgt
       cNam := 'ID'
     @ nY, nX LABEL &cNam VALUE '' WIDTH nLen HEIGHT oBrw1:nHeightCell CENTERALIGN

       WITH OBJECT oWnd:GetObj(cNam)
         :Cargo := 0
         :Event( 1, {|oc,kd,id| kd := Eval( oBrw1:GetColumn('KODS'):bData ), ;       // Get
                                id := Eval( oBrw1:GetColumn('ID'):bData ),  ;
                                oc:Value := alltrim(cValToChar(id))+"-<"+ ;
                                            alltrim(cValToChar(kd))+">" } ) 
         :Event( 2, {|oc      | oc:Window:oCargo:Set(oc:Name, oc:Value) } )          // Put
         :Window:oCargo:Set(cNam, :Value )                                           // init value to oCargo
       END WITH 

       nY   += This.&(cNam).Height 
       cNam := 'KOLV'
     @ nY, nX LABEL &cNam VALUE '' WIDTH nLen HEIGHT oBrw1:nHeightCell CENTERALIGN

       WITH OBJECT oWnd:GetObj(cNam)
         :Event( 1, {|oc,kl   | kl := Eval( oBrw1:GetColumn('KOLV'):bData ), ;        // Get
                                oc:Value := alltrim(cValToChar(kl)) } )
         :Event( 2, {|oc      | oc:Window:oCargo:Set(oc:Name, oc:Value) } )           // Put
         :Window:oCargo:Set(cNam, :Value )                                            // init value to oCargo
       END WITH 

       nY   += This.&(cNam).Height 
       cNam := 'CENA'
     @ nY, nX LABEL &cNam VALUE '' WIDTH nLen HEIGHT oBrw1:nHeightCell CENTERALIGN

       WITH OBJECT oWnd:GetObj(cNam)
         :Event( 1, {|oc,cn   | cn := Eval( oBrw1:GetColumn('CENA'):bData ), ;        // Get
                                oc:Value := alltrim(cValToChar(cn)) } )
         :Event( 2, {|oc      | oc:Window:oCargo:Set(oc:Name, oc:Value) } )           // Put
         :Window:oCargo:Set(cNam, :Value )                                            // init value to oCargo
       END WITH 

       nY   += This.&(cNam).Height + 10
       cPic := oBrw1:GetColumn('NAME'):cPicture
       cNam := 'NAME'
     @ nY, nX  GETBOX &cNam  WIDTH nLen HEIGHT oBrw1:nHeightCell VALUE space(len(cPic)) ;
                    PICTURE  cPic ;
                    BACKCOLOR {{255,255,255},{255,255,200},{200,255,255}} ;
                    FONTCOLOR {{0,0,0},{255,255,200},{0,0,255}}

       This.&(cNam).Enabled := .F.

       WITH OBJECT oWnd:GetObj(cNam)
         :Event( 1, {|oc      | oc:Value := Eval( oBrw1:GetColumn('NAME'):bData ) } ) // Get
         :Event( 2, {|oc      | oc:Window:oCargo:Set(oc:Name, oc:Value) } )           // Put
         :Window:oCargo:Set(cNam, :Value )                                            // init value to oCargo
       END WITH 
     // ---------------------------------------------------------------------------- Control events

     DEFINE TIMER REFR INTERVAL 500 ACTION MyEvent( 'ID' )

     This.REFR.Cargo := oWnd:GetObj4Type('LABEL,GETBOX')

     WITH OBJECT oWnd                                                        // ---- Window events
         :Event( 1, {|ow,ky| This_Msg('Window message ' + "nKey="+cValToChar(ky), ow:Name) } )
         :Event( 2, {|ow,ky| This_Msg('Window message ' + "nKey="+cValToChar(ky), ow:Name) } )
         :Event( 3, {|     | AEval( This.REFR.Cargo , {|oc| oc:SendMsg(2) }) } )              // Put
         // ...
     END WITH                                                                // ---- Window events

	END WINDOW

	CENTER   WINDOW &cWnd
	ACTIVATE WINDOW &cWnd

Return Nil

*----------------------------------- 
STATIC FUNC MyEvent( cName )
*----------------------------------- 
 Local o := This.&(cName).Object     // oWnd:GetObj(cName)

 This.Enabled := .F.

 If o:Cargo != (oBrw1:cAlias)->( RecNo() )
    AEval( This.Cargo , {|oc| oc:PostMsg(1) } )
    o:Cargo := (oBrw1:cAlias)->( RecNo() )
 EndIf

 This.Enabled := .T.

RETURN Nil

*----------------------------------- 
FUNCTION TR0( c ) 
*----------------------------------- 
RETURN PADL(AllTrim(c), Len(c)) 

*-----------------------------------
STATIC FUNC Create_Dbf( cFile )
*-----------------------------------
 LOCAL i, aStru

 aStru := { ;
            { "KODS", "C", 10, 0 }, ;
            { "NAME", "C", 15, 0 }, ;
            { "EDIZ", "C", 10, 0 }, ;
            { "KOLV", "N", 15, 3 }, ;
            { "CENA", "N", 15, 3 }, ;
            { "ID"  , "+",  4, 0 }  ;
          }
 IF ! hb_FileExists( cFile + ".dbf" )
    dbCreate( cFile, aStru )
 ENDIF
 
 USE &cFile ALIAS base NEW
 
 IF LastRec() == 0
    FOR i := 50 TO 1 STEP -1
       APPEND BLANK
       REPLACE KODS WITH hb_ntos(i), ;
               NAME WITH RandStr(15),;
               EDIZ WITH 'kg',       ;
               KOLV WITH RecNo() * 1.5,;
               CENA WITH RecNo() * 2.5
    NEXT
 ENDIF
 
 GO TOP
 
 IF ! hb_FileExists( cFile + IndexExt() )
    INDEX ON TR0(KODS)   TAG KOD  FOR ! deleted()
    INDEX ON UPPER(NAME) TAG NAM  FOR ! deleted()
    INDEX ON ID          TAG FRE  FOR   deleted()
 EndIf

 USE

RETURN Nil

*-----------------------------------
STATIC FUNC RandStr( nLen )
*-----------------------------------
   LOCAL cSet  := "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
   LOCAL cPass := ""
   LOCAL i

   If pCount() < 1
      cPass := " "
   Else
      FOR i := 1 TO nLen
         cPass += SubStr( cSet, Random( 52 ), 1 )
      NEXT
   EndIf

RETURN cPass

*----------------------------------------------
STATIC FUNC TBrw_Msg( oBrw, nKey, cKey, cDop )
*----------------------------------------------
 Local cTx := oBrw:cControlName + CRLF

 Default cDop := ''

 cTx += cValToChar(nKey) + CRLF
 cTx += cValToChar(cKey) + CRLF

 MsgBox( cTx+cDop, ProcName() )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Addr( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Delr( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Gets( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Prn1( oBrw, nKey, cKey )
*---------------------------------------
 Local cTx := ''

 If val(cKey) == VK_F5                // default
    cTx += CRLF + 'Report_1'
 EndIf

 TBrw_Msg( oBrw, nKey, cKey, cTx )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Prn2( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Prn3( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Prn4( oBrw, nKey, cKey )
*---------------------------------------
 Local cTx := oBrw:cControlName + CRLF

 cTx += iif( ValType(nKey) == 'N', hb_ntos(nKey), nKey ) + CRLF + cKey

 MsgBox( cTx, ProcName() )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Prn5( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Prn6( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Prn7( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Prn8( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Prn9( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Ordn( oBrw, nKey, cKey )
*---------------------------------------
 Local cOrd := ( oBrw:cAlias )->( OrdSetFocus() )

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetOrder( oBrw:nColumn(iif( cOrd == "KOD", 'NAME', 'KODS' )) )
 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Find( oBrw, nKey, cKey )
*---------------------------------------

 TBrw_Msg( oBrw, nKey, cKey )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------
STATIC FUNC Rec_Expo( oBrw, nKey, cKey )
*---------------------------------------
 Local cTx := ''

 If val(cKey) == VK_F8                // default
    cTx += CRLF + 'Export_Excel'
 EndIf

 TBrw_Msg( oBrw, nKey, cKey, cTx )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------------
STATIC FUNC Set_Mode( oBrw, nKey, cKey )
*---------------------------------------------
 Local cTx := ''

 If val(cKey) == VK_F9                // default
    cKey := 'SetMode_1'
 EndIf

 If cKey == 'SetMode_1'
    cTx  += CRLF + "Mode EDIT"
    oBrw:bLDblClick  := {|up1,up2,nfl,obr | up1 := up2 := nfl := Nil, ;
                                            obr:PostMsg( WM_KEYDOWN, obr:nFireKey, 0 ) }
    oBrw:UserKeys(VK_RETURN, {|obr        | obr:PostMsg( WM_KEYDOWN, obr:nFireKey, 0 ) })
 Else
    cTx  += CRLF + "Mode SELECT"
    oBrw:bLDblClick := {|up1,up2,nfl,obr  | nfl := Nil, Rec_Gets(obr,up1,up2) }
    oBrw:UserKeys(VK_RETURN, {|obr,nky,cky| Rec_Gets(obr,nky,cky) })
 EndIf

 TBrw_Msg( oBrw, nKey, cKey, cTx )

 oBrw:SetFocus()

RETURN Nil

*---------------------------------------------------------
STATIC FUNC Msg_Keys( oBrw, nKey, cKey, Par1, Par2, Par3 )
*---------------------------------------------------------
 Local cTx := ''

 If Par1 != Nil
    cTx += CRLF + cValToChar(Par1)
 Endif

 If Par2 != Nil
    cTx += CRLF + cValToChar(Par2)
 Endif

 If Par3 != Nil
    cTx += CRLF + cValToChar(Par3)
 Endif

 TBrw_Msg( oBrw, nKey, cKey, cTx )

 oBrw:SetFocus()

RETURN Nil

*-----------------------------------
STATIC FUNC ClickProcedure()
*-----------------------------------
 Local nRow := _HMG_MouseRow
 Local nCol := _HMG_MouseCol
 Local cWnd := _HMG_ThisFormName
 Local aNam := {'FRM_1', 'FRM_2', 'FRM_3'}      // button control name
 Local i, h

 If nRow == 0 .and. nCol == 0 

    For i := 1 To len(aNam)
        h := GetControlHandle(aNam[ i ], cWnd)
        SendMessage( h, WM_LBUTTONDOWN, 0, 0 )  //   press button
        SendMessage( h, WM_LBUTTONUP  , 0, 0 )  // unpress button
        InkeyGui(100)
    Next

 EndIf

RETURN Nil

*-----------------------------------
STATIC FUNC This_Msg( cT, xC )
*-----------------------------------
Local cTx := ""

  If valtype(cT) == 'A'
     If len(cT) > 0
        If     HB_ISOBJECT(cT[1])      
           AEval(cT, {|o | cTx += CRLF + o:Type+" | "+o:Name+" | "+o:VarName })
        ElseIf HB_ISARRAY (cT[1])
           If Len(cT[1]) > 1
              AEval(cT, {|v  | cTx += CRLF + cValToChar(v[3]) + ". " + ;
                                             cValToChar(v[2]) + " = "+ ;
                                             cValToChar(v[1]) })
           Else
              AEval(cT, {|v,n| cTx += CRLF + cValToChar( n  ) + ". " + ;
                                             cValToChar(v[1]) })
           EndIf
        Else
           AEval(cT, {|v| cTx += CRLF + cValToChar(v) })
        EndIf
     EndIf
     cT  := cTx
     cTx := ""
  ElseIf valtype(cT) == 'O'
     cTx += CRLF + cT:Type+" | "+cT:Name+" | "+cT:VarName
     cT  := cTx
     cTx := ""
  EndIf

  Default cT := ""

  cTx += '_HMG_ThisEventType   ' + _HMG_ThisEventType            + CRLF
  cTx += '_HMG_ThisFormName    ' + _HMG_ThisFormName             + CRLF
  cTx += '_HMG_ThisFormIndex   ' + hb_ntos( _HMG_ThisFormIndex ) + CRLF
  cTx += '_HMG_ThisType        ' + _HMG_ThisType                 + CRLF
  cTx += '_HMG_ThisControlName ' + _HMG_ThisControlName          + CRLF
  cTx += '_HMG_ThisIndex       ' + hb_ntos( _HMG_ThisIndex )     + CRLF

  MsgBox(cTx + cT, ProcName()+". "+cValToChar(xC))

RETURN Nil

*-----------------------------------
PROCEDURE Modal_CLick
*-----------------------------------

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 430 HEIGHT 400 ;
		TITLE 'Modal Window' ;
		MODAL ;
		NOSIZE ;
		FONT 'Arial' ;
		SIZE 10

		@ 15,10 LABEL Label_1 ;
		VALUE 'F1' AUTOSIZE

		@ 45,10 LABEL Label_2 ;
		VALUE 'F2' AUTOSIZE

		@ 80,10 BUTTON Button_0 CAPTION 'All Types' ;
		ACTION MsgDebug( (This.Object):GetListType() )

	END WINDOW
  
	Form_2.Center
	Form_2.Activate

RETURN
