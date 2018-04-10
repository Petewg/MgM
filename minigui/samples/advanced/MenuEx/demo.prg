/*
 * Author: P.Chornyj <myorg63@mail.ru>
*/

#include "minigui.ch"

PROCEDURE Main

LOCAL aColors
LOCAL Font1, Font2, Font3, Font4 

	DEFINE FONT font_0 FONTNAME GetDefaultFontName() SIZE 10
	DEFINE FONT font_1 FONTNAME 'Times New Roman' SIZE 10 BOLD
	DEFINE FONT font_2 FONTNAME 'Arial'   SIZE 12 ITALIC
	DEFINE FONT font_3 FONTNAME 'Verdana' SIZE 14 UNDERLINE  
	DEFINE FONT font_4 FONTNAME 'Courier' SIZE 16 STRIKEOUT

	Font0 := GetFontHandle( "font_0" )
	Font1 := GetFontHandle( "font_1" )
	Font2 := GetFontHandle( "font_2" )
	Font3 := GetFontHandle( "font_3" )
	Font4 := GetFontHandle( "font_4" )

	SET MENUSTYLE EXTENDED
//	SET MENUSTYLE STANDARD

//  	SetMenuBitmapHeight( 16 ) 
//  	SetMenuBitmapHeight( BmpSize( "NEW" )[ 1 ] ) 

	SetThemes()

	DEFINE WINDOW Form_1 ;
	AT 0,0 WIDTH 640 HEIGHT 480 ;
	TITLE "MenuEx Test" ICON "SMILE" NOTIFYICON "SMILE" ;
	MAIN

	DEFINE MAIN MENU
		POPUP "&File" FONT Font0
			ITEM "&New" + space(18) + "Ctrl+N"       ACTION MsgInfo( "File:New" )     IMAGE "NEW" 
			ITEM "&Open" + space(17) + "Ctrl+O"      ACTION MsgInfo( "File:Open" )    
		        ITEM "&Save" + space(17) + "Ctrl+S"      ACTION MsgInfo( "File:Save" )    IMAGE "SAVE"  
		        ITEM "Save &As.." ACTION MsgInfo( "File:Save As" ) IMAGE "SAVE_AS" 
		        SEPARATOR
			ITEM "&Print" + space(18) + "Ctrl+P"           ACTION MsgInfo( "File:Print" ) IMAGE "PRINTER" 
			ITEM "Print Pre&view"   ACTION MsgInfo( "File:Print Preview" ) 
			SEPARATOR
			ITEM "E&xit" + space(19) + "Alt+F4"  ACTION Form_1.Release IMAGE "DOOR"
		END POPUP

		POPUP "F&onts" FONT Font0
			ITEM "10- Bold"       FONT Font1
			ITEM "12- Italic"     FONT Font2
			ITEM "14- UnderLine"  FONT Font3
			ITEM "16- StrikeOut"  FONT Font4
		END POPUP

		POPUP "&Test" FONT Font0
			ITEM "Item 1" ACTION MsgInfo( Str( GetMenuItemCount( GetMenu( _HMG_MainHandle ) ) ) ) 
			ITEM "Item 2" ACTION MsgInfo( "Item 2" )

			POPUP "Item 3"
          			ITEM "Item 3.1" ACTION MsgInfo( "Item 3.1" ) 
				ITEM "Item 3.2" ACTION MsgInfo ( "Item 3.2" )

				POPUP "Item 3.3"
					ITEM "Item 3.3.1" ACTION MsgInfo ( "Item 3.3.1" )
					ITEM "Item 3.3.2" ACTION MsgInfo ( "Item 3.3.2" )

					POPUP "Item 3.3.3" 	
						ITEM "Item 3.3.3.1" ACTION MsgInfo ( "Item 3.3.3.1" ) 
						ITEM "Item 3.3.3.2" ACTION MsgInfo ( "Item 3.3.3.2" )
						ITEM "Item 3.3.3.3" ACTION MsgInfo ( "Item 3.3.3.3" )
						ITEM "Item 3.3.3.4" ACTION MsgInfo ( "Item 3.3.3.4" )
						ITEM "Item 3.3.3.5" ACTION MsgInfo ( "Item 3.3.3.5" )
						ITEM "Item 3.3.3.6" ACTION MsgInfo ( "Item 3.3.3.6" )  
					END POPUP

					ITEM "Item 3.3.4" ACTION MsgInfo ( "Item 3.3.4" )
				END POPUP
			END POPUP
			ITEM "Item 4" ACTION MsgInfo ( "Item 4" ) DISABLED
		END POPUP

		POPUP "T&est 1-2" FONT Font0
			ITEM "Test 1.1" ACTION Test1( "1" ) NAME Test11 CHECKED CHECKMARK "TICK"
			ITEM "Test 1.2" ACTION Test1( "2" ) NAME Test12 CHECKED CHECKMARK "TICK"
			ITEM "Test 1.3" ACTION Test1( "3" ) NAME Test13 CHECKED 
			SEPARATOR
			ITEM "Test 1.4" ACTION Test2( "4" ) NAME Test14 CHECKED CHECKMARK "SHADING"
			ITEM "Test 1.5" ACTION Test2( "5" ) NAME Test15 CHECKMARK "SHADING"
			ITEM "Test 1.6" ACTION Test2( "6" ) NAME Test16 CHECKMARK "SHADING" IMAGE "BUG"
		END POPUP

		POPUP "Te&st 3" FONT Font0
			ITEM "Test 2.1" NAME Test21 
			ITEM "Test 2.2" NAME Test22 
			ITEM "Test 2.3" NAME Test23 CHECKED CHECKMARK "MARK"
			SEPARATOR
			ITEM "Disable Items" ACTION Test3( _GetMenuItemCaption( "SetOnOff", "Form_1" ) <> "Disable Items" ) NAME SetOnOff
		END POPUP

		POPUP "&UI theme" FONT Font0
			ITEM "Default" ACTION SetThemes( 0 )
			SEPARATOR
			ITEM "Classic" ACTION SetThemes( 1 ) NAME Theme1
			ITEM "Office 2000 theme" ACTION SetThemes( 2 ) NAME Theme2
		END POPUP

		SetProperty( "Form_1", "Theme1", "Enabled", IsExtendedMenuStyleActive() )
		SetProperty( "Form_1", "Theme2", "Enabled", IsExtendedMenuStyleActive() )

		POPUP "&Misc" FONT Font0
			ITEM "Get MenuBitmap Height" ACTION MsgInfo ( "Current height is " + Ltrim( Str( GetMenuBitmapHeight() ) ) )
		END POPUP

		POPUP "&Help" FONT Font0
			ITEM "Index" IMAGE "BMPHELP"
			ITEM "Using help" 
			SEPARATOR
			ITEM "Online forum" IMAGE "WORLD"
			ITEM "Buy/register" IMAGE "CART_ADD"
			SEPARATOR
			ITEM "About" ACTION MsgInfo ( MiniGuiVersion() ) ICON "SMILE"
		END POPUP
	END MENU

	DEFINE NOTIFY MENU 
		ITEM "About..." ACTION MsgInfo( MiniGuiVersion() ) IMAGE "ABOUT"

		POPUP "Options"
	 		ITEM "Autorun" ACTION ToggleAutorun() NAME SetAuto CHECKED CHECKMARK "CHECK"
		END POPUP

		POPUP "Notify Icon"
			ITEM "Get Notify Icon Name" ACTION MsgInfo( Form_1.NotifyIcon ) 
			ITEM "Change Notify Icon"   ACTION Form_1.NotifyIcon := "Demo2.ico"
		END POPUP

		SEPARATOR

		ITEM "Exit Application" ACTION Form_1.Release IMAGE "res\cancel.bmp"
	END MENU

	DEFINE CONTEXT MENU
		POPUP "Context item 1"
			ITEM "Context item 1.1" ACTION MsgInfo( "Context item 1.1" )
		        ITEM "Context item 1.2" ACTION MsgInfo( "Context item 1.2" )

			POPUP 'Context item 1.3'
				ITEM "Context item 1.3.1" ACTION MsgInfo( "Context item 1.3.1" ) IMAGE "BUG"
				SEPARATOR
			        ITEM "Context item 1.3.2" ACTION MsgInfo( "Context item 1.3.2" ) CHECKED CHECKMARK "CHECK"
			END POPUP
		END POPUP

		ITEM "Context item 2 - Simple"   ACTION MsgInfo( "Context item 2 - Simple" )  CHECKED CHECKMARK "CHECK"
		ITEM "Context item 3 - Disabled" ACTION MsgInfo( "Context item 3 - Disabled" ) DISABLED
		SEPARATOR
		POPUP "Context item 4"
			ITEM "Context item 4.1" ACTION MsgInfo( "Context item 4.1" )
			ITEM "Context item 4.2" ACTION MsgInfo( "Context item 4.2" )
			ITEM "Context item 4.3" ACTION MsgInfo( "Context item 4.3" ) DISABLED
		END POPUP
	END MENU

	END WINDOW

	CENTER   WINDOW  Form_1
	ACTIVATE WINDOW  Form_1

RETURN

/*
*/
STATIC PROCEDURE SetThemes( type )
LOCAL aColors := GetMenuColors()

	DEFAULT type TO 0

	SWITCH type
	CASE 0
		aColors[ MNUCLR_MENUBARBACKGROUND1 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARBACKGROUND2 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARTEXT ]         := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := RGB( 192, 192, 192 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= RGB( 255, 252, 248 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= RGB( 136, 133, 116 )

		aColors[ MNUCLR_MENUITEMTEXT ]        := RGB(   0,   0,   0 ) 
		aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := RGB( 192, 192, 192 )

		aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := RGB( 255, 255, 255 )
		aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := RGB( 255, 255, 255 )

		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB( 182, 189, 210 )
		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB( 182, 189, 210 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := RGB( 255, 255, 255 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := RGB( 255, 255, 255 )

		aColors[ MNUCLR_IMAGEBACKGROUND1 ] := RGB( 246, 245, 244 )
		aColors[ MNUCLR_IMAGEBACKGROUND2 ] := RGB( 207, 210, 200 )

		aColors[ MNUCLR_SEPARATOR1 ] := RGB( 168, 169, 163 )
		aColors[ MNUCLR_SEPARATOR2 ] := RGB( 255, 255, 255 )

		aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := RGB(  10, 36, 106 ) 
		aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := RGB(  10, 36, 106 )
		aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := RGB(  10, 36, 106 )
		aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := RGB(  10, 36, 106 )

		SET MENUCURSOR FULL

		SET MENUSEPARATOR SINGLE RIGHTALIGN

		SET MENUITEM BORDER 3DSTYLE

		EXIT

	CASE 1
		aColors[ MNUCLR_MENUBARBACKGROUND1 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARBACKGROUND2 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARTEXT ]         := GetSysColor(  7 )
		aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := GetSysColor( 14 )
		aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := GetSysColor( 17 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= GetSysColor( 13 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= GetSysColor( 13 )

		aColors[ MNUCLR_MENUITEMTEXT ]        := GetSysColor(  7 )  
		aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= GetSysColor( 14 )  
		aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := GetSysColor( 17 )   

		aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := IF( _HMG_IsXP, GetSysColor( 4 ), RGB( 255, 255, 255 ) )
		aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := IF( _HMG_IsXP, GetSysColor( 4 ), RGB( 255, 255, 255 ) )

		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := GetSysColor( 13 )
		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := GetSysColor( 13 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := IF( _HMG_IsXP, GetSysColor( 4 ), RGB( 255, 255, 255 ) )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := IF( _HMG_IsXP, GetSysColor( 4 ), RGB( 255, 255, 255 ) )

		aColors[ MNUCLR_IMAGEBACKGROUND1 ] := GetSysColor( 15 )
		aColors[ MNUCLR_IMAGEBACKGROUND2 ] := GetSysColor( 15 )

		aColors[ MNUCLR_SEPARATOR1 ] := GetSysColor( 17 )
		aColors[ MNUCLR_SEPARATOR2 ] := GetSysColor( 14 )

		aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := GetSysColor( 13 ) 
		aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := GetSysColor( 13 )
		aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := GetSysColor( 17 )
		aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := GetSysColor( 14 )

		SET MENUCURSOR FULL

		SET MENUSEPARATOR DOUBLE RIGHTALIGN

		SET MENUITEM BORDER FLAT

		EXIT

	CASE 2
		aColors[ MNUCLR_MENUBARBACKGROUND1 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARBACKGROUND2 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARTEXT ]         := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := RGB( 128, 128, 128 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= GetSysColor(15)
		aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= GetSysColor(15)

		aColors[ MNUCLR_MENUITEMTEXT ]        := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= RGB( 255, 255, 255 )
		aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := RGB( 128, 128, 128 )

		aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := RGB( 212, 208, 200 )
		aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := RGB( 212, 208, 200 )

		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB(  10,  36, 106 )
		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB(  10,  36, 106 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := RGB( 212, 208, 200 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := RGB( 212, 208, 200 )

		aColors[ MNUCLR_IMAGEBACKGROUND1 ] := RGB( 212, 208, 200 )
		aColors[ MNUCLR_IMAGEBACKGROUND2 ] := RGB( 212, 208, 200 )

		aColors[ MNUCLR_SEPARATOR1 ] := RGB( 128, 128, 128 )
		aColors[ MNUCLR_SEPARATOR2 ] := RGB( 255, 255, 255 )

		aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := RGB(  10,  36, 106 )
		aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := RGB( 128, 128, 128 )
		aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := RGB(  10,  36, 106 )
		aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := RGB( 255, 255, 255 )

		SET MENUCURSOR SHORT
		SET MENUSEPARATOR DOUBLE LEFTALIGN
		SET MENUITEM BORDER 3D

	END

	SetMenuColors( aColors )

RETURN

/*
*/
STATIC PROCEDURE ToggleAutorun

	Form_1.SetAuto.Checked := !Form_1.SetAuto.Checked

	_SetMenuItemBitmap( "SetAuto" , "Form_1" , if( Form_1.SetAuto.Checked == .T., NIL, "UNCHECK" ) )

	MsgInfo( "Autorun is " + ;
		if( Form_1.SetAuto.Checked == .T., "enabled", "disabled") )
RETURN

/*
*/
STATIC PROCEDURE Test1( param )
LOCAL lChecked 

	lChecked := GetProperty( "Form_1", "Test1"+param , "Checked" )
	SetProperty( "Form_1", "Test1"+param , "Checked", !lChecked )

	MsgInfo( "Item Test1"+param + " is " + ;
		if( GetProperty( "Form_1", "Test1"+param , "Checked" ) == .T., ;
                	"checked", "unchecked" ) )
RETURN

/*
*/
STATIC PROCEDURE Test2( param )

	SetProperty( "Form_1", "Test1"+param , "Checked" , .T. )

	SWITCH param
	CASE "4"
		SetProperty( "Form_1", "Test15", "Checked" , .F. )		
		SetProperty( "Form_1", "Test16", "Checked" , .F. )	
		EXIT
	CASE "5"
		SetProperty( "Form_1", "Test14", "Checked" , .F. )		
		SetProperty( "Form_1", "Test16", "Checked" , .F. )		
		EXIT
	CASE "6"
		SetProperty( "Form_1", "Test14", "Checked" , .F. )		
		SetProperty( "Form_1", "Test15", "Checked" , .F. )		
	END

	PlayBeep()

RETURN

/*
*/
STATIC PROCEDURE Test3( param )

	_SetMenuItemCaption( "SetOnOff", "Form_1", iif( param == .F., "Enable Items", "Disable Items" ) )

	SetProperty( "Form_1", "Test21", "Enabled", param )
	SetProperty( "Form_1", "Test22", "Enabled", param )
	SetProperty( "Form_1", "Test23", "Enabled", param )

	MsgInfo( "Items Test21-Test23 is " + ;
		if( GetProperty( "Form_1", "Test21", "Enabled" ) == .F., ;
                	"disabled", "enabled" ) )
RETURN
