/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-05 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PRO

#ifdef PRO
	#define PROGRAM 'Desktop Changer Pro'
#else
	#define PROGRAM 'Desktop Changer Lite'
#endif

#define VERSION ' version 1.5.4'
#define COPYRIGHT ' 2003-2007 Grigory Filatov'

#define NTRIM( n ) LTrim( Str( n ) )
#define MsgInfo( c, t ) MsgInfo( c, t, , .f. )

#define SPI_SETDESKWALLPAPER	20
#define SPIF_UPDATEINIFILE	1
#define SPIF_SENDWININICHANGE	2

Static lPreview := .F., lCenter := .F., lTile := .F., lStretch := .F., ;
	lAutoFit := .T., cScaling := "5", lTransparent := .T., ;
	lForce := .F., lAutoShut := .F., lAutoRun := .F.

Memvar x, y, nOld
Memvar cWallpaper
Memvar cPath
Memvar cFileName
Memvar cRunFile, cShortPath
Memvar lChange, lEnable, ;
	cWallPreview
Memvar oReg

*--------------------------------------------------------*
Procedure Main( cStart )
*--------------------------------------------------------*
   LOCAL lHide := .F., lSplash := .T.

   PRIVATE x := GetDesktopWidth(), y := GetDesktopHeight(), nOld := 0
   PRIVATE cWallpaper := GetWindowsFolder()+"\Wallpaper.bmp"
   PRIVATE cPath := cFilePath(GetExeFileName()) + "\"
   PRIVATE cFileName := cPath + cFileNoExt(GetExeFileName())
   PRIVATE cRunFile := cPath + "zoom.exe", cShortPath := _GetShortPathName(cPath)

   DEFAULT cStart := "00"

   Set Delete ON

   lSplash := FILE(cPath + "WALLPAPERS\MGLOGO.GIF")

#ifdef PRO
	if !FI_Init()
	      Return
	endif

   SET MULTIPLE OFF

   SET PROGRAMMATICCHANGE OFF

   DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH 0 HEIGHT 0 ;
	TITLE PROGRAM ;
	MAIN ;
	NOSHOW ;
	ON INIT IF(lSplash, , IF(InitApp( cStart, lSplash ), , ;
		(ShowNotifyIcon( GetFormHandle( "Form_1" ), .F., NIL, NIL ), ExitProcess(0)))) ;
	ON RELEASE ( IF(lHide, DesktopIcons(.T.), ), FI_End(), dbCloseAll(), ;
		IF(FILE(cFileName + ".ntx"), Ferase(cFileName + ".ntx"), ) ) ;
	NOTIFYICON 'MAINICON' ;
	NOTIFYTOOLTIP PROGRAM ;
	ON NOTIFYCLICK IF(Used(), ChangeDesktop(), )
#else

   DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH 0 HEIGHT 0 ;
	TITLE PROGRAM ;
	MAIN ;
	NOSHOW ;
	ON INIT IF(lSplash, , IF(InitApp( cStart, lSplash ), , ;
		(ShowNotifyIcon( GetFormHandle( "Form_1" ), .F., NIL, NIL ), ExitProcess(0)))) ;
	ON RELEASE (dbCloseAll(), IF(FILE(cFileName + ".ntx"), Ferase(cFileName + ".ntx"), )) ;
	NOTIFYICON 'MAINICON' ;
	NOTIFYTOOLTIP PROGRAM ;
	ON NOTIFYCLICK IF(Used(), ChangeDesktop(), )
#endif

	DEFINE NOTIFY MENU 
		ITEM '&Wallpaper Settings...'	ACTION Settings()
		SEPARATOR
		ITEM '&Hide/Show the desktop icons' ;
			ACTION ( lHide := !lHide, DesktopIcons(lHide) )
		ITEM '&Show/Hide the background of icons' ;
			ACTION ( lTransparent := !lTransparent, TransparentIcons() )
		SEPARATOR
		ITEM '&Change Desktop'		ACTION ChangeDesktop() DEFAULT
		SEPARATOR
		ITEM '&Mail to author...' ;
			ACTION ShellExecute(0, "open", "rundll32.exe", ;
				"url.dll,FileProtocolHandler " + ;
				"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
				"&subject=Desktop%20Changer%20Feedback:", , 1)
		ITEM '&About...'			ACTION ShellAbout( "", ;
			PROGRAM + VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, ;
			LoadTrayIcon(GetInstance(), "MAINICON", 32, 32) )
		SEPARATOR	
		ITEM '&Exit'			ACTION Form_1.Release
	END MENU

   END WINDOW

   IF lSplash
	   DEFINE WINDOW Form_Start ;
		AT 0, 0 ;
		WIDTH 157 HEIGHT 240 ;
		ICON 'MAINICON' ;
		TOPMOST NOCAPTION ;
		ON INIT (IF(InitApp( cStart, lSplash ), , ;
			(ShowNotifyIcon( GetFormHandle( "Form_1" ), .F., NIL, NIL ), ExitProcess(0))), ;
			Form_Start.Release) ;
		ON RELEASE ProcessMessages() ;
		BACKCOLOR WHITE

		@ -2, -2 IMAGE Image_1 				;
			PICTURE cPath + "WALLPAPERS\MGLOGO.GIF"	;
			WIDTH Form_Start.Width - 4			;
			HEIGHT Form_Start.Height - 33		;
			STRETCH WHITEBACKGROUND

		@ Form_Start.Height - 32, -2 			;
			PROGRESSBAR Progress_1 			;
			RANGE 0, 100 					;
			WIDTH Form_Start.Width - 4			;
			HEIGHT 28
	END WINDOW

	CENTER WINDOW Form_Start

	ACTIVATE WINDOW Form_Start, Form_1
   ELSE
	ACTIVATE WINDOW Form_1
   ENDIF

Return

*--------------------------------------------------------*
Function InitApp( cStart, lSplash )
*--------------------------------------------------------*
   LOCAL aWallpaper, cIni := "", nExit := 30
   LOCAL aStruct := { {"NAME","C",80,0}, {"ENABLED","N",1,0}, ;
                      {"POSITION","N",1,0}, {"SCALE","N",1,0} }

   IF DIRCHANGE( cPath + "WALLPAPERS" ) > 0
	MAKEDIR( cPath + "Wallpapers" )
   ELSE
	DIRCHANGE( cPath )
   ENDIF

   aWallpaper := GetWallpapers()

   IF lSplash
	Form_Start.Progress_1.Value := 20
	INKEY(.1)
   ENDIF

   IF EMPTY( LEN(aWallpaper) )
	MsgStop( 'The wallpapers is not found', 'Stop!' )
	Return .F.
   ENDIF

   If !File( cFileName + ".dat" )
      DBcreate( Lower(cFileName) + ".dat", aStruct )
   EndIF

   USE ( cFileName + ".dat" ) ALIAS WALL SHARED NEW

   IF !USED()
	MsgStop( 'The database is corrupted', 'Stop!' )
	Return .F.
   ENDIF

   IF lSplash
	Form_Start.Progress_1.Value := 40
	INKEY(.1)
   ENDIF

   If WALL->( LastRec() ) == 0
	Aeval(aWallpaper, {|e| WALL->( dbappend() ), ;
				WALL->NAME := e, WALL->ENABLED := 1, ;
				WALL->POSITION := 1, WALL->SCALE := 5})
   ElseIf WALL->( LastRec() ) # Len( aWallpaper )
	INDEX ON WALL->NAME TO ( cFileName )
	SET INDEX TO ( cFileName )
	Aeval(aWallpaper, {|e| WALL->( dbseek( e ) ), ;
				IF(WALL->( found() ), , (WALL->( dbappend() ), ;
				WALL->NAME := e, WALL->ENABLED := 1, ;
				WALL->POSITION := 1, WALL->SCALE := 5))})
	SET INDEX TO
	Ferase(cFileName + ".ntx")
   EndIF
   WALL->( dbgotop() )

   IF lSplash
	Form_Start.Progress_1.Value := 60
	INKEY(.1)
   ENDIF

   IF !FILE(cFileName + '.ini')
	BEGIN INI FILE Lower(cFileName) + '.ini'
		SET SECTION "Information" ENTRY "Program" TO PROGRAM + VERSION
		SET SECTION "Information" ENTRY "Author" TO Chr(169) + COPYRIGHT
		SET SECTION "Information" ENTRY "Contact" TO "gfilatov@inbox.ru"
		SET SECTION "Information" ENTRY "Command line" TO cFileName + ".EXE [-|/STARTUP]"
		SET SECTION "Position" ENTRY "AutoFit" TO "1"
		SET SECTION "Position" ENTRY "Center" TO "0"
		SET SECTION "Position" ENTRY "Tile" TO "0"
		SET SECTION "Position" ENTRY "Stretch" TO "0"
		SET SECTION "Option" ENTRY "Transparent" TO "1"
		SET SECTION "Option" ENTRY "ForceChange" TO "0"
		SET SECTION "Option" ENTRY "AutoShut" TO "0"
		SET SECTION "Option" ENTRY "AutoRun" TO "0"
		SET SECTION "Option" ENTRY "Preview" TO "1"
	END INI
   ENDIF

   BEGIN INI FILE Lower(cFileName) + '.ini'
	SET SECTION "Information" ENTRY "Date" TO DTOC( Date() )
	SET SECTION "Information" ENTRY "Time" TO Time()

	GET cIni SECTION "Position" ENTRY "AutoFit" DEFAULT "1"
	lAutoFit := IF(cIni $ "1 YES TRUE", .T., .F.)

	GET cIni SECTION "Position" ENTRY "Center" DEFAULT "0"
	lCenter := IF(cIni $ "1 YES TRUE", .T., .F.)

	GET cIni SECTION "Position" ENTRY "Tile" DEFAULT "0"
	lTile := IF(cIni $ "1 YES TRUE", .T., .F.)

	GET cIni SECTION "Position" ENTRY "Stretch" DEFAULT "0"
	lStretch := IF(cIni $ "1 YES TRUE", .T., .F.)

	GET cIni SECTION "Option" ENTRY "Transparent" DEFAULT "1"
	lTransparent := IF(cIni $ "1 YES TRUE", .T., .F.)

	GET cIni SECTION "Option" ENTRY "ForceChange" DEFAULT "0"
	lForce := IF(cIni $ "1 YES TRUE", .T., .F.)

	GET cIni SECTION "Option" ENTRY "AutoShut" DEFAULT "0"
	lAutoShut := IF(cIni $ "1 YES TRUE", .T., .F.)

	GET cIni SECTION "Option" ENTRY "AutoRun" DEFAULT "0"
	lAutoRun := IF(cIni $ "1 YES TRUE", .T., .F.)

	GET cIni SECTION "Option" ENTRY "Preview" DEFAULT "1"
	lPreview := IF(cIni $ "1 YES TRUE", .T., .F.)

	GET cScaling SECTION "Scale" ENTRY "Type" DEFAULT cScaling
   END INI

   IF lSplash
	Form_Start.Progress_1.Value := 80
	INKEY(.1)
   ENDIF

   IF lCenter
	SetCenterWallpaper()
   ELSEIF lTile
	SetTileWallpaper()
   ELSEIF lStretch
	SetStretchWallpaper()
   ENDIF

   IF UPPER(SUBSTR(cStart, 2)) == "STARTUP"
	SysWait()
   ENDIF

   IF UPPER(SUBSTR(cStart, 2)) == "STARTUP" .OR. lForce
	ChangeDesktop(.T.)
   ELSEIF lTransparent
	TransparentIcons()
   ENDIF

   IF lSplash
	Form_Start.Progress_1.Value := 100
	INKEY(.1)
   ENDIF

   IF lForce .AND. lAutoShut
	DEFINE TIMER Timer_1 		;
		OF Form_1      		;
		INTERVAL nExit * 1000 	;
		ACTION (lTransparent := .F., Form_1.Release)

	DEFINE TIMER Timer_2 		;
		OF Form_1      		;
		INTERVAL 1000  		;
		ACTION (Form_1.NotifyTooltip := ;
		PROGRAM + ": Exiting in " + NTRIM(--nExit) + " seconds")
   ENDIF

Return .T.

#define FILTER_BOX        0
#define FILTER_BICUBIC    1
#define FILTER_BILINEAR   2
#define FILTER_BSPLINE    3
#define FILTER_CATMULLROM 4
#define FILTER_LANCZOS3   5

*--------------------------------------------------------*
Function ChangeDesktop( lDel, nNumber )
*--------------------------------------------------------*
LOCAL nMaxNumber, cFile, nPos, handle

	DEFAULT lDel TO .F.

	IF PCOUNT() < 2
		SET FILTER TO WALL->ENABLED == 1
		WALL->( dbgotop() )
		nMaxNumber := Count("WALL")

		nNumber := Max( Random( nMaxNumber ), 1 )
		IF nMaxNumber > 1
			DO WHILE nOld == nNumber
				nNumber := Max( Random( nMaxNumber ), 1 )
			ENDDO
		ENDIF
		nOld := nNumber

		WALL->( dbgotop() )
		IF nNumber > 1
			WALL->( dbskip(nNumber - 1) )
		ENDIF
	ENDIF

	cFile := cShortPath + "WALLPAPERS\" + TRIM( WALL->NAME )

	nPos := WALL->POSITION

	cScaling := NTRIM(WALL->SCALE)

	SET FILTER TO

	IF RIGHT(cFile, 3) == "BMP"

		COPY FILE ( cFile ) TO ( cWallpaper )

	ELSE

#ifndef PRO
		IF !FILE( cRunFile )
			MsgStop( 'The Zoomer is not found', 'Stop!' )
			Return NIL
		EndIf
#endif
		lAutoFit := .F.

		DO CASE
			CASE nPos == 2
				SetCenterWallpaper()
			CASE nPos == 3
				SetTileWallpaper()
			CASE nPos == 4
				SetStretchWallpaper()
			OTHERWISE
				lAutoFit := .T.
		ENDCASE

		IF lDel
			FERASE( cWallpaper )
		ENDIF

#ifdef PRO
		handle := FI_Load( cFile )

		IF lAutoFit
			do case
				case cScaling == "0"
					nNumber := FILTER_BOX
				case cScaling == "1"
					nNumber := FILTER_BICUBIC
				case cScaling == "2"
					nNumber := FILTER_BILINEAR
				case cScaling == "3"
					nNumber := FILTER_CATMULLROM
				case cScaling == "4"
					nNumber := FILTER_BSPLINE
				otherwise
					nNumber := FILTER_LANCZOS3
			endcase

			handle := FI_Rescale( handle, x, y, nNumber )
		ENDIF

		FI_Save( handle, cWallpaper )
		FI_UnLoad( handle )
#else
		EXECUTE FILE cRunFile + " -t" + cScaling +	;
			IF(lAutoFit, " -x" + NTRIM(x), "") +	;
			" -b " + cFile + " " + cWallpaper 		;
			WAIT 							;
			MINIMIZE
#endif
	ENDIF

	SystemParametersInfo( SPI_SETDESKWALLPAPER, 0, @cWallpaper, SPIF_UPDATEINIFILE + SPIF_SENDWININICHANGE )

	IF lTransparent
		TransparentIcons()
	ENDIF

Return NIL

*--------------------------------------------------------*
Function Settings()
*--------------------------------------------------------*
LOCAL aImage := {"uncheck", "check"}, nItem := 1
LOCAL nPos := IF(lAutoFit, 1, IF(lCenter, 2, IF(lTile, 3, 4)))

PRIVATE lChange := .F., lEnable := .F., ;
	cWallPreview := "Wallpaper.jpg"

   IF IsControlDefined( Timer_1, Form_1 )
	Form_1.Timer_1.Enabled := .F.
	Form_1.Timer_2.Enabled := .F.
	Form_1.NotifyTooltip := PROGRAM
   ENDIF

   IF IsWindowDefined( Form_2 )
	BringWindowToTop( GetFormHandle( "Form_2" ) )
	Return Nil
   ENDIF

   DEFINE WINDOW Form_2 ; 
        AT 0,0 ; 
        WIDTH 418 ; 
        HEIGHT 414 ; 
        TITLE 'Wallpaper Settings' ; 
        ICON 'MAINICON' ;
        MODAL NOSIZE ;
        ON RELEASE IF(FILE(cWallPreview), Ferase(cWallPreview), ) ;
        ON PAINT (Form_2.CONTROL_12.Picture := IF(lPreview, cWallPreview, 'BLACKBOX'))

        @ 12,6 FRAME CONTROL_1 ; 
            WIDTH 220 ; 
            HEIGHT 334 ; 
		OPAQUE ;
            FONT 'MS Sans Serif' ; 
            SIZE 9

        @ 6,234 FRAME CONTROL_2 ; 
            CAPTION 'Wallpaper Position' ; 
            WIDTH 170 ; 
            HEIGHT 190 ; 
		OPAQUE ;
            FONT 'MS Sans Serif' ; 
            SIZE 9

        @ 200,234 FRAME CONTROL_3 ; 
            CAPTION 'Options' ; 
            WIDTH 170 ; 
            HEIGHT 146 ; 
		OPAQUE ;
            FONT 'MS Sans Serif' ; 
            SIZE 9

        @ 24,16 BROWSE CONTROL_4 ; 
            WIDTH 174 ; 
            HEIGHT 178 ; 
            HEADERS { "", "Wallpaper" } ; 
            WIDTHS { if(_hmg_IsXP, 20, 0), if(_hmg_IsXP, 132, 135) } ; 
		WORKAREA WALL ;
		FIELDS {"WALL->ENABLED", "TRIM(WALL->NAME)"} ;
		VALUE nItem ;
            ON CHANGE (nItem := Form_2.CONTROL_4.Value, ;
			IF(EMPTY(nItem), , (WALL->( dbgoto(nItem) ), ;
			Form_2.CONTROL_13.Value := WALL->POSITION, ;
			Form_2.CONTROL_18.Value := WALL->SCALE)), ;
			IF(lPreview, (lChange := .T., ;
			SetPicturePreview( nItem ), lChange := .F.), )) ;
		ON HEADCLICK { , {|| Head_Click()} } ;
		ON DBLCLICK (lEnable := .T., ;
			ToggleEnabled( Form_2.CONTROL_4.Value ), lEnable := .F.) ;
            NOLINES ;
            IMAGE aImage

        @ 30,197 BUTTON CONTROL_5 ; 
            PICTURE 'OPEN' ; 
            ACTION AddItem() ; 
            WIDTH 22 ; 
            HEIGHT 22 ;
		TOOLTIP "Add to List"

        @ 60,197 BUTTON CONTROL_6 ; 
            PICTURE 'UP' ; 
            ACTION MovePicture(.T.) ; 
            WIDTH 22 ; 
            HEIGHT 22 ;
		TOOLTIP "Move up"

        @ 90,197 BUTTON CONTROL_7 ; 
            PICTURE 'DOWN' ; 
            ACTION MovePicture(.F.) ; 
            WIDTH 22 ; 
            HEIGHT 22 ;
		TOOLTIP "Move down"

        @ 120,197 BUTTON CONTROL_8 ; 
            PICTURE 'TRASH' ; 
            ACTION RemoveItem( Form_2.CONTROL_4.Value ) ; 
            WIDTH 22 ; 
            HEIGHT 22 ;
		TOOLTIP "Delete from List"

        @ 150,197 BUTTON CONTROL_9 ; 
            PICTURE 'ACT' ; 
            ACTION (nItem := Max(1, Form_2.CONTROL_4.Value), ;
			WALL->( dbeval({|| WALL->( rlock() ), ;
			WALL->ENABLED := 1, WALL->( dbrunlock() )}) ), ;
			Form_2.CONTROL_4.Value := nItem, ;
			Form_2.CONTROL_4.Refresh) ; 
            WIDTH 22 ; 
            HEIGHT 22 ;
		TOOLTIP "Activate all"

        @ 180,197 BUTTON CONTROL_10 ; 
            PICTURE 'DEACT' ; 
            ACTION (nItem := Max(1, Form_2.CONTROL_4.Value), ;
			WALL->( dbeval({|| WALL->( rlock() ), ;
			WALL->ENABLED := 0, WALL->( dbrunlock() )}) ), ;
			Form_2.CONTROL_4.Value := nItem, ;
			Form_2.CONTROL_4.Refresh) ; 
            WIDTH 22 ; 
            HEIGHT 22 ;
		TOOLTIP "Deactivate all"

        @ 206,78 CHECKBOX CONTROL_11 ; 
            CAPTION 'Pre&view' ; 
            WIDTH 64 ; 
            HEIGHT 23 ; 
            VALUE lPreview ; 
            ON CHANGE (lPreview := Form_2.CONTROL_11.Value,  ;
			IF(lPreview, (lChange := .T., ;
			SetPicturePreview( Form_2.CONTROL_4.Value ), lChange := .F.), ;
			Form_2.CONTROL_12.Picture := 'BLACKBOX'))

        @ 232,38 IMAGE CONTROL_12 ; 
            PICTURE 'BLACKBOX' ; 
            WIDTH 134 ; 
            HEIGHT 100

        @ 22,250 RADIOGROUP CONTROL_13 ; 
            OPTIONS { "Auto &Fit", "Ce&nter", "Ti&le", "Str&etch" } ; 
            VALUE nPos ; 
            WIDTH 80 ; 
            ON CHANGE (nPos := Form_2.CONTROL_13.Value, ;
			WALL->( dbgoto(Form_2.CONTROL_4.Value) ), ;
			WALL->( rlock() ), WALL->POSITION := nPos, WALL->( dbrunlock() ))

        @ 130,260 LABEL CONTROL_17 ; 
            VALUE 'Scaling type:' ; 
            WIDTH 70 ; 
            HEIGHT 23 ; 

        @ 128,336 SPINNER CONTROL_18 ; 
            RANGE 0 , 6 ; 
            VALUE VAL(cScaling) ; 
            WIDTH 40 ; 
            HEIGHT 20 ; 
            ON CHANGE (cScaling := NTRIM(Form_2.CONTROL_18.Value), ;
			WALL->( dbgoto(Form_2.CONTROL_4.Value) ), ;
			WALL->( rlock() ), WALL->SCALE := VAL(cScaling), WALL->( dbrunlock() ))

        @ 160,250 BUTTON CONTROL_19 ; 
            CAPTION 'Apply to &All wallpapers' ; 
            ACTION (nPos := Form_2.CONTROL_13.Value, ;
			cScaling := NTRIM(Form_2.CONTROL_18.Value), ;
			WALL->( dbeval({|| WALL->( rlock() ), ;
			WALL->POSITION := nPos,	WALL->SCALE := VAL(cScaling), ;
			WALL->( dbrunlock() )}) )) ; 
            WIDTH 138 ; 
            HEIGHT 23 ; 
            FONT 'MS Sans Serif' ; 
            SIZE 9 ;
		TOOLTIP "Apply the changes to all items in the list"

        @ 220,250 CHECKBOX CONTROL_14 ; 
            CAPTION '&Transparent icons' ; 
            WIDTH 140 ; 
            HEIGHT 23 ; 
            VALUE lTransparent ; 
            ON CHANGE ( lTransparent := Form_2.CONTROL_14.Value, TransparentIcons() )

        @ 250,250 CHECKBOX CONTROL_15 ; 
            CAPTION 'C&hanges on Startup' ; 
            WIDTH 140 ; 
            HEIGHT 23 ; 
            VALUE lForce ; 
            ON CHANGE (lForce := Form_2.CONTROL_15.Value, Form_2.CONTROL_16.Enabled := lForce)

        @ 280,268 CHECKBOX CONTROL_16 ; 
            CAPTION 'Aut&o Shutdown' ; 
            WIDTH 100 ; 
            HEIGHT 23 ; 
            VALUE lAutoShut ; 
            ON CHANGE (lAutoShut := Form_2.CONTROL_16.Value)

        @ 310,250 CHECKBOX CONTROL_20 ; 
            CAPTION '&Run at Start Windows' ; 
            WIDTH 140 ; 
            HEIGHT 23 ; 
            VALUE lAutoRun ; 
            ON CHANGE (lAutoRun := Form_2.CONTROL_20.Value, StartUp(lAutoRun))

	Form_2.CONTROL_16.Enabled := lForce

	DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 132, 20 FLAT BOTTOM RIGHTTEXT

		BUTTON Button_1  ;
			CAPTION padc('&Powered by ...', 24) ;
	            PICTURE 'TOOLS' ; 
			ACTION MsgAbout() SEPARATOR

		BUTTON Button_2 ;
			CAPTION padc('&Save', 27) ;
	            PICTURE 'OK' ; 
			ACTION ( SaveConfig(), Form_2.Release )

		BUTTON Button_3 ;
			CAPTION padc('&Cancel', 26) ;
	            PICTURE 'CANCEL' ; 
			ACTION Form_2.Release

	END TOOLBAR

	DEFINE CONTEXT MENU CONTROL CONTROL_4
		ITEM 'Set As &Wallpaper'	ACTION (nItem := Form_2.CONTROL_4.Value, ;
							IF(EMPTY(nItem), , ChangeDesktop( .T., nItem)))
		SEPARATOR
		ITEM 'Select &All'		ACTION (nItem := Max(1, Form_2.CONTROL_4.Value), ;
							WALL->( dbeval({|| WALL->( rlock() ), ;
							WALL->ENABLED := 1, WALL->( dbrunlock() )}) ), ;
							Form_2.CONTROL_4.Value := nItem, ;
							Form_2.CONTROL_4.Refresh)
		ITEM '&Unselect All'		ACTION (nItem := Max(1, Form_2.CONTROL_4.Value), ;
							WALL->( dbeval({|| WALL->( rlock() ), ;
							WALL->ENABLED := 0, WALL->( dbrunlock() )}) ), ;
							Form_2.CONTROL_4.Value := nItem, ;
							Form_2.CONTROL_4.Refresh)
		ITEM '&Invert Selection'	ACTION (nItem := Max(1, Form_2.CONTROL_4.Value), ;
							WALL->( dbeval({|| WALL->( rlock() ), ;
							WALL->ENABLED := IF(WALL->ENABLED = 1, 0, 1), ;
							WALL->( dbrunlock() )}) ), ;
							Form_2.CONTROL_4.Value := nItem, ;
							Form_2.CONTROL_4.Refresh)
		SEPARATOR
		ITEM '&Sort Items'		ACTION Head_Click()
		ITEM '&Remove Duplicate Items'	ACTION RemoveDuplicate()
	END MENU

   END WINDOW

   CENTER WINDOW Form_2

   ACTIVATE WINDOW Form_2

Return NIL

*--------------------------------------------------------*
Procedure SaveConfig()
*--------------------------------------------------------*
LOCAL nPos := Form_2.CONTROL_13.Value

   BEGIN INI FILE Lower(cFileName) + '.ini'
	SET SECTION "Information" ENTRY "Time" TO Time()

	SET SECTION "Position" ENTRY "AutoFit" TO IF(nPos == 1, "1", "0")
	SET SECTION "Position" ENTRY "Center" TO IF(nPos == 2, "1", "0")
	SET SECTION "Position" ENTRY "Tile" TO IF(nPos == 3, "1", "0")
	SET SECTION "Position" ENTRY "Stretch" TO IF(nPos == 4, "1", "0")

	SET SECTION "Option" ENTRY "Transparent" TO IF(lTransparent, "1", "0")
	SET SECTION "Option" ENTRY "ForceChange" TO IF(lForce, "1", "0")
	SET SECTION "Option" ENTRY "AutoShut" TO IF(lAutoShut, "1", "0")
	SET SECTION "Option" ENTRY "AutoRun" TO IF(lAutoRun, "1", "0")

	SET SECTION "Option" ENTRY "Preview" TO IF(lPreview, "1", "0")
   END INI

Return

*--------------------------------------------------------*
Procedure ToggleEnabled( nItem )
*--------------------------------------------------------*
LOCAL nEnable := 0

   IF !lChange .AND. lEnable

	WALL->( dbgoto(nItem) )
	nEnable := WALL->ENABLED

	WALL->( rlock() )
	WALL->ENABLED := IF(EMPTY(nEnable), 1, 0)
	WALL->( dbrunlock() )

	Form_2.CONTROL_4.Refresh

   ENDIF

Return

*--------------------------------------------------------*
Function SetPicturePreview( nItem )
*--------------------------------------------------------*
LOCAL cPicture := "", cFile := "", handle

   IF lChange .AND. !lEnable

	WALL->( dbgoto(nItem) )

	cPicture := TRIM( WALL->NAME )
	cFile := cShortPath + "WALLPAPERS\" + cPicture

	IF FILE( cWallPreview )
		FERASE( cWallPreview )
	ENDIF

#ifdef PRO
	handle := FI_Load( cFile )

	handle := FI_Rescale( handle, Form_2.CONTROL_12.Width, Form_2.CONTROL_12.Height, FILTER_BOX )

	FI_Save( handle, cWallPreview, 256 )
	FI_UnLoad( handle )
#else
	IF !FILE( cRunFile )
		MsgStop( 'The Zoomer is not found', 'Stop!' )
		Return NIL
	EndIf

	EXECUTE FILE cRunFile + " -t5" +	 		;
		" -x134 " + cFile + " " + cWallPreview	;
		WAIT						;
		MINIMIZE
#endif

	Form_2.CONTROL_12.Picture := cWallPreview

   ENDIF

Return NIL

*--------------------------------------------------------*
Function MovePicture( lGo )
*--------------------------------------------------------*
LOCAL nItem := Max(1, Form_2.CONTROL_4.Value), aSwap, aPicture

   WALL->( dbgoto(nItem) )
   SET INDEX TO

   IF lGo
	IF nItem > 1
		aPicture := WALL->( Scatter() )
		WALL->( dbskip( -1 ) )
		aSwap := WALL->( Scatter() )

		WALL->( rlock() )
		WALL->( Gather( aPicture ) )

		Form_2.CONTROL_4.Value := WALL->( recno() )

		WALL->( dbskip() )
		WALL->( rlock() )
		WALL->( Gather( aSwap ) )
		WALL->( dbunlock() )
	ENDIF
   ELSE
	IF nItem < WALL->( LastRec() )

		aPicture := WALL->( Scatter() )
		WALL->( dbskip() )
		aSwap := WALL->( Scatter() )

		WALL->( rlock() )
		WALL->( Gather( aPicture ) )

		Form_2.CONTROL_4.Value := WALL->( recno() )

		WALL->( dbskip( -1 ) )
		WALL->( rlock() )
		WALL->( Gather( aSwap ) )
		WALL->( dbunlock() )
	ENDIF
   ENDIF

   Form_2.CONTROL_4.Refresh

Return NIL

*--------------------------------------------------------*
Function AddItem()
*--------------------------------------------------------*
LOCAL cWall, cFile := GetFile( { {"JPG Files", "*.jpg"}, ;
		{"GIF Files", "*.gif"}, {"BMP Files", "*.bmp"} }, ;
		"Browse for file" )

   IF !EMPTY(cFile)
	DIRCHANGE( cPath )

	cWall := cPath + "WALLPAPERS\" + StrTran(cFileNoPath(cFile), " ", "_")

	IF cFilePath(cFile) # cPath + "WALLPAPERS"
		COPY FILE ( cFile ) TO ( cWall )
	ENDIF

	SET INDEX TO
	WALL->( dbappend() )
	WALL->( rlock() )
	WALL->NAME := cFileNoPath( cWall )
	WALL->ENABLED := 1 ; WALL->POSITION := 1 ; WALL->SCALE := 5
	WALL->( dbrunlock() )

	Form_2.CONTROL_4.Value := WALL->( recno() )
	Form_2.CONTROL_4.Refresh

	IF lPreview
		lChange := .T.
		SetPicturePreview( Form_2.CONTROL_4.Value )
		lChange := .F.
	ENDIF
   ENDIF

Return Nil

*--------------------------------------------------------*
Function RemoveItem( nItem )
*--------------------------------------------------------*

IF !Empty( nItem )

   IF MsgYesNo( "Are you sure you want to remove the selected wallpaper?", "Confirm", , , .f. )

      WALL->( dbgoto(nItem) )
	Ferase( cPath + "WALLPAPERS\" + WALL->NAME )

	WALL->( rlock() )
      WALL->( dbdelete() )
	WALL->( dbclosearea() )

	USE ( cFileName + ".dat" ) ALIAS WALL NEW
      WALL->( __dbpack() )
	WALL->( dbclosearea() )

	USE ( cFileName + ".dat" ) ALIAS WALL SHARED NEW

	Form_2.CONTROL_4.Value := IF(nItem > WALL->( LastRec() ), WALL->( LastRec() ), nItem)
	Form_2.CONTROL_4.Refresh

	IF lPreview
		lChange := .T.
		SetPicturePreview( Form_2.CONTROL_4.Value )
		lChange := .F.
	ENDIF

   ENDIF

ENDIF

Return Nil

*--------------------------------------------------------*
Function RemoveDuplicate()
*--------------------------------------------------------*
LOCAL nItems := LastRec()

	INDEX ON WALL->NAME TO ( Lower(cFileName) ) UNIQUE
	SET INDEX TO ( cFileName )

	COPY TO _TEMP_
	WALL->( dbclosearea() )

	USE ( cFileName + ".dat" ) ALIAS WALL NEW
	WALL->( __dbzap() )

	APPEND FROM _TEMP_
	WALL->( dbclosearea() )

	Ferase( "_TEMP_.dbf" )
	USE ( cFileName + ".dat" ) ALIAS WALL SHARED NEW

	MsgInfo("Duplicate items removed: " + NTRIM(nItems - LastRec()), ;
		"Result")

Return Nil

*--------------------------------------------------------*
Procedure Head_click
*--------------------------------------------------------*
LOCAL nItem := Form_2.CONTROL_4.Value

   IF !Empty( nItem )

	SET INDEX TO
	INDEX ON Lower(WALL->NAME) TO ( Lower(cFileName) )
	SET INDEX TO ( cFileName )
	WALL->(dbgoto(nItem))

	Form_2.CONTROL_4.Value := nItem
	Form_2.CONTROL_4.Refresh

   ENDIF

Return

*--------------------------------------------------------*
Static Function StartUp(lMode)
*--------------------------------------------------------*
LOCAL cFileName := cFileNoExt(GetModuleFileName(GetInstance()))
LOCAL cRunName := GetModuleFileName( GetInstance() ) + " /STARTUP", ;
	oReg, cKeyName := ""

	OPEN REGISTRY oReg KEY HKEY_CURRENT_USER ;
		SECTION "Software\Microsoft\Windows\CurrentVersion\Run"

	GET VALUE cKeyName NAME PROGRAM OF oReg

	IF lMode
      	IF Empty(cKeyName) .OR. cKeyName # cRunName
			SET VALUE PROGRAM OF oReg TO cRunName
	      ENDIF
	ELSE
		SET VALUE PROGRAM OF oReg TO cFileName + ".BAK"
	ENDIF

	CLOSE REGISTRY oReg

return NIL

*--------------------------------------------------------*
Function MsgAbout()
*--------------------------------------------------------*
#ifdef PRO
return MsgInfo( PROGRAM + VERSION + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	Substr(MiniGuiVersion(), 1, 38) + CRLF + ;
	"FreeImage.dll version: " + FI_Version() + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 40), "About" )
#else
return MsgInfo( PROGRAM + VERSION + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	Substr(MiniGuiVersion(), 1, 38) + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 40), "About" )
#endif

*--------------------------------------------------------*
Function GetWallpapers()
*--------------------------------------------------------*
LOCAL aArrJpg := DIRECTORY( cPath + "WALLPAPERS\*.JPG" )
LOCAL aArrGif := DIRECTORY( cPath + "WALLPAPERS\*.GIF" )
LOCAL aArrBmp := DIRECTORY( cPath + "WALLPAPERS\*.BMP" )
LOCAL aArray := {}

	IF LEN(aArrJpg) > 0
	      aEval( aArrJpg, {|uFile| AAdd( aArray, uFile[1] )} )
	ENDIF

	IF LEN(aArrGif) > 0
	      aEval( aArrGif, {|uFile| AAdd( aArray, uFile[1] )} )
	ENDIF

	IF LEN(aArrBmp) > 0
	      aEval( aArrBmp, {|uFile| AAdd( aArray, uFile[1] )} )
	ENDIF

Return(aArray)

*--------------------------------------------------------*
Procedure TransparentIcons()
*--------------------------------------------------------*

	IF lTransparent
		SetTransparentIcons()
	ELSE
		SetSolidIcons()
	ENDIF

Return

*--------------------------------------------------------*
Procedure DesktopIcons( lMode )
*--------------------------------------------------------*
LOCAL cPrgMngr := 'Program Manager'

	IF lMode
		HideWindow( FindWindow( cPrgMngr ) )
	ELSE
		ShowWindow( FindWindow( cPrgMngr ) )
	ENDIF

Return

*--------------------------------------------------------*
Procedure SetCenterWallpaper()
*--------------------------------------------------------*
LOCAL oReg

	OPEN REGISTRY oReg KEY HKEY_CURRENT_USER ;
		SECTION "Control Panel\Desktop"

	SET VALUE "TileWallpaper" OF oReg TO "0"
	SET VALUE "WallpaperStyle" OF oReg TO "0"

	CLOSE REGISTRY oReg

Return

*--------------------------------------------------------*
Procedure SetTileWallpaper()
*--------------------------------------------------------*
LOCAL oReg

	OPEN REGISTRY oReg KEY HKEY_CURRENT_USER ;
		SECTION "Control Panel\Desktop"

	SET VALUE "TileWallpaper" OF oReg TO "1"
	SET VALUE "WallpaperStyle" OF oReg TO "0"

	CLOSE REGISTRY oReg

Return

*--------------------------------------------------------*
Procedure SetStretchWallpaper()
*--------------------------------------------------------*
LOCAL oReg

	OPEN REGISTRY oReg KEY HKEY_CURRENT_USER ;
		SECTION "Control Panel\Desktop"

	SET VALUE "WallpaperStyle" OF oReg TO "2"
	SET VALUE "TileWallpaper" OF oReg TO "0"

	CLOSE REGISTRY oReg

Return

*--------------------------------------------------------*
Procedure SysWait( nWait )
*--------------------------------------------------------*
LOCAL nUsage, iTime := Seconds()
PRIVATE oReg := InitCpu()

	DEFAULT nWait := 10

	nUsage := CpuUsage()

	Do While Seconds() - iTime < nWait .AND. nUsage > 50
		InkeyGUI(250)
		nUsage := CpuUsage()
	EndDo

	EndCpu()

Return

*--------------------------------------------------------*
Static Function InitCpu()
*--------------------------------------------------------*
LOCAL oReg, uVar

   If !IsWinNT()
      oReg := TReg32():New(HKEY_DYN_DATA,"PerfStats\StartStat")
      uVar := oReg:Get("KERNEL\CPUUsage","")
      oReg:Close()
      oReg := TReg32():New(HKEY_DYN_DATA,"PerfStats\StatData")
   Endif

Return oReg

*--------------------------------------------------------*
Static Function EndCpu()
*--------------------------------------------------------*
LOCAL uVar

   If !IsWinNT()
      oReg:Close()
      oReg := TReg32():New(HKEY_DYN_DATA,"PerfStats\StopStat")
      uVar := oReg:Get("KERNEL\CPUUsage","")
      oReg:Close()
   Endif

Return .T.

*--------------------------------------------------------*
Static Function CpuUsage()
*--------------------------------------------------------*
LOCAL uVar := chr(0), uuVar := chr(0)

   If !IsWinNT()
      uVar := oReg:Get("KERNEL\CPUUsage","00")
   Else
      oReg := TReg32():New(HKEY_LOCAL_MACHINE,;
            "Software\Microsoft\Windows NT\CurrentVersion\Perflib\009")
      uuVar := oReg:Get("Counters","")
      uVar := Str(oReg:Get("% Processor Time",0))
      oReg:Close()
   Endif

Return Asc(uVar)

*--------------------------------------------------------*
FUNCTION Count(cAlias)
*--------------------------------------------------------*
LOCAL nCnt := 0

	( cAlias )->( DBeval( {|| nCnt++} ) )

Return nCnt

*--------------------------------------------------------*
Function Scatter()
*--------------------------------------------------------*
Local aRecord[fcount()]

Return aeval( aRecord, {|x,n| aRecord[n] := fieldget( n ) } )

*--------------------------------------------------------*
Function Gather( paRecord )
*--------------------------------------------------------*
Return aeval( paRecord, {|x,n| fieldput( n, x ) } )


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include "mgdefs.h"
#include "commctrl.h"

static HWND GetDeskTopListView(void);

HB_FUNC ( SETTRANSPARENTICONS )
{
	HWND hListView = GetDeskTopListView();

	SendMessage( hListView, LVM_SETTEXTBKCOLOR, 0, CLR_NONE );
	InvalidateRect( hListView, 0, TRUE );
	UpdateWindow( hListView );
} 

HB_FUNC ( SETSOLIDICONS )
{
	HWND hListView = GetDeskTopListView();

	SendMessage( hListView, LVM_SETTEXTBKCOLOR, 0, GetSysColor( COLOR_DESKTOP ) );
	InvalidateRect( hListView, 0, TRUE );
	UpdateWindow( hListView );
} 

static HWND GetDeskTopListView()
{
	static HWND hKnownListView=0;
	HWND hDesktop, hListView;

	hDesktop = FindWindowEx(FindWindow("Progman", 
                                       0), 
                            0, 
                            "SHELLDLL_DefView", 
                            0);
	hListView = FindWindowEx(hDesktop, 
                             0, 
                             "SysListView32", 
                             0);
	if (hListView)
		hKnownListView=hListView;
	else
		hListView=hKnownListView;
	return hListView;
}

HB_FUNC ( FINDWINDOW )
{
   hb_retnl( ( LONG ) FindWindow( 0, hb_parc( 1 ) ) );
}

/*
 * FreeImage wrappers for Harbour
 *
 * Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://www.geocities.com/alkresin/
 *
 * Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "hbvm.h"
#include "FreeImage.h"

typedef char * ( WINAPI *FREEIMAGE_GETVERSION )( void );
typedef FIBITMAP* ( WINAPI *FREEIMAGE_LOAD)( FREE_IMAGE_FORMAT fif, char *filename, int flags FI_DEFAULT(0) );
typedef void ( WINAPI *FREEIMAGE_UNLOAD )( FIBITMAP *dib );
typedef FIBITMAP* ( WINAPI *FREEIMAGE_ALLOCATE)( int width, int height, int bpp );
typedef BOOL ( WINAPI *FREEIMAGE_SAVE)( FREE_IMAGE_FORMAT fif, FIBITMAP* dib, char *filename, int flags FI_DEFAULT(0) );
typedef FIBITMAP* ( WINAPI *FREEIMAGE_CONVERTTO8BITS)( FIBITMAP* dib );
typedef FIBITMAP* ( WINAPI *FREEIMAGE_CONVERTTO24BITS)( FIBITMAP* dib );
typedef FIBITMAP* ( WINAPI *FREEIMAGE_RESCALE)( FIBITMAP *dib, int dst_width, int dst_height, FREE_IMAGE_FILTER filter );
typedef FREE_IMAGE_FORMAT ( WINAPI *FREEIMAGE_GETFIFFROMFILENAME)( char *filename);
typedef ULONG ( WINAPI *FREEIMAGE_GETWIDTH )( FIBITMAP *dib );
typedef ULONG ( WINAPI *FREEIMAGE_GETHEIGHT )( FIBITMAP *dib );
typedef ULONG ( WINAPI *FREEIMAGE_GETBPP )( FIBITMAP *dib );
typedef BYTE * ( WINAPI *FREEIMAGE_GETBITS )( FIBITMAP *dib );
typedef BITMAPINFO * ( WINAPI *FREEIMAGE_GETINFO )( FIBITMAP *dib );
typedef BITMAPINFOHEADER * ( WINAPI *FREEIMAGE_GETINFOHEADER )( FIBITMAP *dib );

static HINSTANCE hFreeImageDll = NULL;
static FREEIMAGE_LOAD pLoad = NULL;
static FREEIMAGE_UNLOAD pUnload = NULL;
static FREEIMAGE_ALLOCATE pAllocate = NULL;
static FREEIMAGE_SAVE pSave = NULL;
static FREEIMAGE_CONVERTTO8BITS pConvertTo8Bits = NULL;
static FREEIMAGE_CONVERTTO24BITS pConvertTo24Bits = NULL;
static FREEIMAGE_RESCALE pRescale = NULL;
static FREEIMAGE_GETFIFFROMFILENAME pGetfiffromfile = NULL;
static FREEIMAGE_GETWIDTH pGetwidth = NULL;
static FREEIMAGE_GETHEIGHT pGetheight = NULL;
static FREEIMAGE_GETBPP pGetbpp = NULL;
static FREEIMAGE_GETBITS pGetbits = NULL;
static FREEIMAGE_GETINFO pGetinfo = NULL;
static FREEIMAGE_GETINFOHEADER pGetinfoHead = NULL;

BOOL FreeImgInit( void )
{
   if( !hFreeImageDll )
   {
      hFreeImageDll = LoadLibrary( (LPCTSTR)"FreeImage.dll" );
      if( !hFreeImageDll )
      {
         MessageBox( GetActiveWindow(), "Library not loaded", "FreeImage.dll", MB_OK | MB_ICONSTOP );
         return 0;
      }
   }
   return 1;
}

FARPROC GetFunction( FARPROC h, LPCSTR funcname )
{
   if( !h )
   {
      if( !hFreeImageDll && !FreeImgInit() )
      {
         return (FARPROC)NULL;
      }
      else
         return GetProcAddress( hFreeImageDll, funcname );
   }
   else
      return h;
}

HB_FUNC( FI_INIT )
{
   hb_retl( FreeImgInit() );
}

HB_FUNC( FI_END )
{
   if( hFreeImageDll )
   {
      FreeLibrary( hFreeImageDll );
      hFreeImageDll = NULL;
      pLoad = NULL;
      pUnload = NULL;
      pAllocate = NULL;
      pSave = NULL;
      pConvertTo8Bits = NULL;
      pConvertTo24Bits = NULL;
      pRescale = NULL;
      pGetfiffromfile = NULL;
      pGetwidth = NULL;
      pGetheight = NULL;
      pGetbpp = NULL;
      pGetbits = NULL;
      pGetinfo = NULL;
      pGetinfoHead = NULL;
   }
}

HB_FUNC( FI_VERSION )
{
   FREEIMAGE_GETVERSION pFunc =
     (FREEIMAGE_GETVERSION) GetFunction( NULL,"_FreeImage_GetVersion@0" );

   hb_retc( (pFunc)? pFunc() : "" );
}

HB_FUNC( FI_UNLOAD )
{
   pUnload = (FREEIMAGE_UNLOAD) GetFunction( (FARPROC)pUnload,"_FreeImage_Unload@4" );

   if( pUnload )
      pUnload( (FIBITMAP*)hb_parnl(1) );
}

HB_FUNC( FI_RESCALE )
{
   FIBITMAP* dib = (FIBITMAP*) hb_parnl( 1 );
   FIBITMAP* new_dib;
   int bpp;

 	pUnload = (FREEIMAGE_UNLOAD) GetFunction( (FARPROC)pUnload,"_FreeImage_Unload@4" );

	if(dib) {
		pGetbpp = (FREEIMAGE_GETBPP) GetFunction( (FARPROC)pGetbpp,"_FreeImage_GetBPP@4" );
		bpp = pGetbpp( dib );

		if(bpp < 8) {
			// Convert to 8-bit
			pConvertTo8Bits = (FREEIMAGE_CONVERTTO8BITS) GetFunction( (FARPROC)pConvertTo8Bits,"_FreeImage_ConvertTo8Bits@4" );
			new_dib = pConvertTo8Bits( dib );
			if(new_dib) {
				pUnload( dib );
				dib = new_dib;
			}
			else {
			       hb_retl( 0 );
				return;
			}
		} else if(bpp == 16) {
			// Convert to 24-bit
			pConvertTo24Bits = (FREEIMAGE_CONVERTTO24BITS) GetFunction( (FARPROC)pConvertTo24Bits,"_FreeImage_ConvertTo24Bits@4" );
			new_dib = pConvertTo24Bits( dib );
			if(new_dib) {
				pUnload( dib );
				dib = new_dib;
			}
			else {
			       hb_retl( 0 );
				return;
			}
		}

		// Perform upsampling / downsampling
		pRescale = (FREEIMAGE_RESCALE) GetFunction( (FARPROC)pRescale,"_FreeImage_Rescale@16" );
		hb_retnl( (LONG) pRescale( dib, hb_parni( 2 ), hb_parni( 3 ), (FREE_IMAGE_FILTER) hb_parnl(4) ) );
		pUnload( dib );
	}
	else
	       hb_retl( 0 );
}

HB_FUNC( FI_LOAD )
{
   pLoad = (FREEIMAGE_LOAD) GetFunction( (FARPROC)pLoad,"_FreeImage_Load@12" );
   pGetfiffromfile = (FREEIMAGE_GETFIFFROMFILENAME) GetFunction( (FARPROC)pGetfiffromfile,"_FreeImage_GetFIFFromFilename@4" );

   if( pGetfiffromfile && pLoad )
   {
      char *name = (char *) hb_parc( 1 );
      hb_retnl( (LONG) pLoad( pGetfiffromfile(name), name, (hb_pcount()>1)? hb_parni(2) : 0 ) );
   }
   else
      hb_retnl( 0 );
}

HB_FUNC( FI_SAVE )
{
   pSave = (FREEIMAGE_SAVE) GetFunction( (FARPROC)pSave,"_FreeImage_Save@16" );
   pGetfiffromfile = (FREEIMAGE_GETFIFFROMFILENAME) GetFunction( (FARPROC)pGetfiffromfile,"_FreeImage_GetFIFFromFilename@4" );

   if( pGetfiffromfile && pSave )
   {
      char *name = (char *) hb_parc( 2 );
      hb_retl( (BOOL) pSave( pGetfiffromfile(name), (FIBITMAP*)hb_parnl(1), name, (hb_pcount()>2)? hb_parni(3) : 0 ) );
   }
}

#pragma ENDDUMP
