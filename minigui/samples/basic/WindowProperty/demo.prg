/*
 HMG Window Property Demo
 (c) 2016 P.Chornyj <myorg63@mail.ru>
*/

#include "minigui.ch"

#ifdef __XHARBOUR__
//#error "Not xHarbour ready"
#xtranslate BEGIN SEQUENCE WITH { |e| Break(e) } => TRY
#xtranslate RECOVER USING => CATCH
#endif

FUNCTION Main()

//	SET FONT TO "Tahoma", 9

	SET DATE FORMAT TO "dd.mm.yyyy"

	DEFINE WINDOW Win1 ;
		ROW	10 ;
		COL	10 ;
		WIDTH	340 ;
		HEIGHT	400 ;
		TITLE	"Window Property Demo" ;
		WINDOWTYPE	MAIN ;
		ON INIT	Win1_AddProperty() ;
		ON RELEASE	Win1_RemoveProperty()

		DEFINE LABEL Label2
			ROW	10
			COL	10
			WIDTH	300
			VALUE	"See below:"
			ALIGNMENT	LEFT
			ALIGNMENT	VCENTER
		END LABEL

		DEFINE LABEL Label1
			ROW	30
			COL	10
			WIDTH	300
			VALUE	"Initial state of Label1"
			BACKCOLOR	{200,200,200}
			ALIGNMENT	CENTER
			ALIGNMENT	VCENTER
		END LABEL


		DEFINE BUTTON Button1
			ROW	150
			COL	40
			WIDTH	240
			HEIGHT	28
			CAPTION	'Set Property "PROP_1" TO "TEST"'		
			ONCLICK	Win1_AddProperty() 
		END BUTTON

		Win1.Button1.Enabled := .F.

		DEFINE BUTTON Button2
			ROW	180
			COL	40
			WIDTH	240
			HEIGHT	28
			CAPTION	'Get Property "PROP_1"'			
			ONCLICK	Win1_GetProperty() 
		END BUTTON

		DEFINE BUTTON Button3
			ROW	210
			COL	40
			WIDTH	240
			HEIGHT	28
			CAPTION	'Remove Property "PROP_1"'			
			ONCLICK	( Win1_RemoveProperty(), Win1.Button1.Enabled := .T., This.Enabled := .F. )
		END BUTTON

		DEFINE BUTTON Button4
			ROW	240
			COL	40
			WIDTH	240
			HEIGHT	28
			CAPTION	'Count WinProps'			
			ONCLICK	Win1_GetPropertyInfo()
		END BUTTON

	END WINDOW

	CENTER WINDOW	 Win1
	ACTIVATE WINDOW Win1

	RETURN 0

///////////////////////////////////////////////////////////////////////////////
PROCEDURE Win1_AddProperty() 

	LOCAL cMsg, hHash

	// We can set Property as the string
	IF SetProp( Win1.Handle, "PROP_1", "TEST" )
		Win1.Label1.Value := "PROP_1..PROP_6 has been added." 

		Win1.Button1.Enabled := .F.
		Win1.Button3.Enabled := .T.
	ENDIF

	// And the some others simple types
	SET WINDOWPROPERTY "PROP_2" OF Win1 VALUE 2
	SET WINDOWPROPERTY "PROP_3" OF Win1 VALUE 3.14
	SET WINDOWPROPERTY "PROP_4" OF Win1 VALUE .T.
	SET WINDOWPROPERTY "PROP_5" OF Win1 VALUE Date()

	// And of course profit of [x]Harbour
	SetProp( Win1.Handle, "PROP_6", hb_serialize( { "One" => 1, 2 => "Two", "Today" => Date(), 5 => NIL, 6 => { .T., .F. } } ) )

	// It's seem joke, but it is true: Today is !
	hHash := hb_deserialize( GetProp( Win1.Handle, "PROP_6" ) )

	cMsg := hb_ValToStr( hHash[ "Today" ] )
	cMsg += ( CRLF + "Is " + If( hHash[ 6 ][ 1 ], "TRUE", "FALSE" ) + "!" )

	MsgInfo( "Today is " + cMsg )

	RETURN

///////////////////////////////////////////////////////////////////////////////
PROCEDURE Win1_RemoveProperty() 
/*
	Before  a  window  is destroyed (that is, before it returns from processing
   the  WM_NCDESTROY  message),  an application must remove all entries it has
   added to the property list.

   An  application  can remove only those properties it has added. It must not
   remove properties added by other applications or by the system itself.
 */
	RemoveProp( Win1.Handle, "PROP_1" )

	RELEASE WINDOWPROPERTY "PROP_2" OF Win1
	RELEASE WINDOWPROPERTY "PROP_3" OF Win1
	RELEASE WINDOWPROPERTY "PROP_4" OF Win1
	RELEASE WINDOWPROPERTY "PROP_5" OF Win1
	RELEASE WINDOWPROPERTY "PROP_6" OF Win1

	Win1.Button1.Enabled := .T.
	Win1.Button3.Enabled := .F.

	RETURN

///////////////////////////////////////////////////////////////////////////////

PROCEDURE Win1_GetProperty() 

	LOCAL xValue, oError 

	************************************
   BEGIN SEQUENCE WITH { |e| Break(e) }
	************************************
		GET WINDOWPROPERTY "PROP_1" OF Win1 VALUE xValue 
	************************************
   RECOVER USING oError
	************************************
		IF "PROP_1" $ oError:Description .AND. "not defined" $ oError:Description
			MsgInfo( "Be careful if using _Get/_SetWindowProp() (GET/SET WINDOWPROPERTY..)"  )

			xValue := GetProp( Win1.Handle, "PROP_1" )
		ENDIF
	************************************
   END SEQUENCE
	************************************

	IF ! hb_IsNil( xValue )
		Win1.Label1.Value := hb_ValToStr( xValue )
	ELSE
		Win1.Label1.Value := "Undefined."
	ENDIF

	RETURN

///////////////////////////////////////////////////////////////////////////////
PROCEDURE Win1_GetPropertyInfo() 

	LOCAL aProps := EnumProps( Win1.Handle ), e
	LOCAL cMsg   := ""

	FOR EACH e IN aProps
	   // hwnd ( Win1.Handle ) | name of property | handle of data
		cMsg += ( hb_NtoS( e[1] ) + "|" + e[2] + "|" + hb_NtoS( e[3] ) + CRLF )
	NEXT

	cMsg += ( Replicate( "-", 18 ) + CRLF + "Count of Props: " + hb_NtoS( Len( aProps ) ) )

	MsgInfo( cMsg  )

	RETURN
