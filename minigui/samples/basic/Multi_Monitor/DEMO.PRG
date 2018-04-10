/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2016 P.Chornyj <myorg63@mail.ru>
 *
*/

ANNOUNCE RDDSYS

#define _HMG_OUTLOG

#include "hmg.ch"

#define MONITOR_HANDLE			1
#define MONITOR_RECT			2

#define MONITOR_DEFAULTTONULL		0x00000000
#define MONITOR_DEFAULTTOPRIMARY	0x00000001
#define MONITOR_DEFAULTTONEAREST	0x00000002

#define MONITORINFOF_PRIMARY		0x00000001

#xtranslate IS_MONITOR_PRIMARY ( <mInfo> ) ;
=> ;
	( hb_BitAnd( <mInfo>\[3], MONITORINFOF_PRIMARY ) != 0 )

#define MONITOR_CENTER			0x0001        // center rect to monitor 
#define MONITOR_CLIP			0x0000        // clip rect to monitor 
#define MONITOR_WORKAREA		0x0002        // use monitor work area 
#define MONITOR_AREA			0x0000        // use monitor entire area 

#command ASSERT( <exp> [, <msg>] ) ;
=> ;
	IF !( <exp> )                                                   ;
	;    ?                                                          ;
                    hb_eol() + ProcName( 0 ) +                          ;
                    "(" + hb_ntos( ProcLine() ) + ")" +                 ;
                    "  Assertion failed: " +                            ;
                    iif( <.msg.>, <msg>, <"exp"> )                      ;
	; END

*-----------------------------------------------------------------------------*
FUNCTION Main()
*-----------------------------------------------------------------------------*
	LOCAL nCount := CountMonitors() // Counts only the display monitors	
	LOCAL aMonitors, m, rc
	LOCAL aMonInfo, mi
	LOCAL nX, nY, aXY

	SET WINDOW MAIN OFF

	ERASE "output.txt" 
	SET LOGFILE TO "output.txt"

	IF nCount == 0
		? "No monitors installed."
		RETURN 1
	ENDIF

	? "Count of display monitors:", hb_NtoS( nCount )
	? "All the monitors have a same color format:", iif( IsSameDisplayFormat(), 'TRUE', 'FALSE' )

	// Enumerates display monitors 
	// (including invisible pseudo-monitors associated with the mirroring drivers)
	aMonitors := EnumDisplayMonitors()

	IF nCount != Len( aMonitors )
		? "Count of display monitors (with invisible pseudo-monitors):", hb_NtoS( Len( aMonitors ) )
	ELSE
		? "No invisible pseudo-monitors."
	ENDIF

	? "-----------"

	FOR EACH m IN aMonitors
		? "Handle:", m[MONITOR_HANDLE]
		FOR EACH rc IN m[MONITOR_RECT]
			? PadR( rc:__enumKey(), 6 ) + ":", rc:__enumValue()
		NEXT
	NEXT

	? "-----------"
	// Get more details for each monitor using GetMonitorInfo
	FOR EACH m IN aMonitors 
		aMonInfo := GetMonitorInfo( m[ MONITOR_HANDLE ] )

		IF hb_IsArray( aMonInfo )
			? "#" + hb_NtoS( m:__enumIndex ) + " " + iif( IS_MONITOR_PRIMARY( aMonInfo ), "(PRIMARY)", "SECONDARY" )
			? "Monitor Info:"
			? "-----------"
			? "Handle:", m[MONITOR_HANDLE]

			? "Display monitor rectangle*"
			// be careful - left, not Left, not LEFT..
			? "left  :", aMonInfo[1]["left"]     
			? "top   :", aMonInfo[1]["top"]
			? "right :", aMonInfo[1]["right"]
			? "bottom:", aMonInfo[1]["bottom"]
			? "-----------"
			? "Work area rectangle of the display monitor*"
			? "left  :", aMonInfo[2]["left"]
			? "top   :", aMonInfo[2]["top"]
			? "right :", aMonInfo[2]["right"]
			? "bottom:", aMonInfo[2]["bottom"]
			? "-----------"
			? "* - in virtual-screen coordinates"
		ELSE
			? "GetMonitorInfo is failed."
		ENDIF	

		? "-----------"
		? "Test for MonitorFromPoint()"

		nX  := aMonInfo[1]["left"] + 10
		nY  := aMonInfo[1]["top"] + 10
		aXY := { nX, nY }

		ASSERT( MonitorFromPoint( nX, nY ) == m[MONITOR_HANDLE], "Failed." )
		ASSERT( MonitorFromPoint( aXY ) == m[MONITOR_HANDLE], "Failed." )

		nX  := aMonInfo[1]["right"] + 10
		nY  := aMonInfo[1]["bottom"] + 10
		aXY := { nX, nY }

		ASSERT( MonitorFromPoint( aXY, MONITOR_DEFAULTTONULL ) == 0, "Failed." )
		IF nCount == 1
			ASSERT( MonitorFromPoint( aXY, MONITOR_DEFAULTTOPRIMARY ) == m[MONITOR_HANDLE], "Failed." )
			ASSERT( MonitorFromPoint( aXY, MONITOR_DEFAULTTONEAREST ) == m[MONITOR_HANDLE], "Failed." )
		ENDIF

		? "Passed."		

	NEXT

	ShowTxt ( MemoRead( "Output.txt" ) )

RETURN 0


*-----------------------------------------------------------------------------*
PROCEDURE ShowTxt( cText )
*-----------------------------------------------------------------------------*

   DEFINE WINDOW Form_1 ;
	CLIENTAREA 800, 600 ;
	TITLE 'Show output' ;
	MODAL

	DEFINE EDITBOX Edit_1
		COL 10
		ROW 10
		WIDTH 780
		HEIGHT 580
		VALUE cText
		READONLY .T.
		HSCROLLBAR .F.
		FONTNAME "Courier New"
		FONTSIZE 12
	END EDITBOX

	ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN
