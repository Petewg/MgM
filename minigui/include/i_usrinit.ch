#define BASEDEF_MYBUTTON 

#xcommand @ <row>,<col> MYBUTTON <name> ;
		OF <parent> ;
		CAPTION <caption> ;
		ACTION <action> ;
	=>;
	_DefineMyButton(<"name">,<row>,<col>,<caption>,<{action}>,<"parent">)

#undef BASEDEF_MYBUTTON


#define BASEDEF_CLBUTTON

#xcommand @ <row>,<col> CLBUTTON <name> ;
		OF <parent> ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
		CAPTION <caption> ;
		NOTETEXT <notes> ;
		ACTION <action> ;
		[ <default: DEFAULT> ] ;
	=>;
	_DefineCLButton(<"name">,<row>,<col>,<caption>,<notes>,<{action}>,<"parent">,<.default.>,<w>,<h>)

#undef BASEDEF_CLBUTTON


#define BASEDEF_MYSYSLINK

#xcommand @ <row>,<col> MYSYSLINK <name> ;
		OF <parent> ;
		CAPTION <caption> ;
		ACTION <action> ;
	=>;
	_DefineMySysLink(<"name">,<row>,<col>,<caption>,<{action}>,<"parent">)

#undef BASEDEF_MYSYSLINK


#define BASEDEF_ANIMATERES

#command @ <row>,<col> ANIMATERES <name> ;
		[ <dummy1: OF, PARENT> <parent> ] ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
		FILE <file> ;
		ID <n> ;
		[ TOOLTIP <tooltip> ] ;
		[ HELPID <helpid> ] ;
		[ <invisible : INVISIBLE> ] ;
	=>;
	_DefineAnimateRes ( <"name">, <"parent">, <col>, <row>, <w>, <h>, <file>, <n>, ;
			<tooltip>, <helpid>, <.invisible.> )

#undef BASEDEF_ANIMATERES


#define BASEDEF_WEBCAM

#xcommand @ <row>, <col> WEBCAM <name> ;
		[ <of:OF, PARENT> <parent> ] ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
		[ <lOn: START> ] ;
		[ RATE <rate> ] ;
		[ TOOLTIP <tooltip> ] ;
		[ HELPID <helpid> ] ;
   =>;
	_DefineWebCam ( <"name">, <"parent">, <col>, <row>, <w>, <h>, <.lOn.>, <rate>, ;
			<tooltip>, <helpid> )

#undef BASEDEF_WEBCAM


#define BASEDEF_ACTIVEX

#xcommand @ <row>,<col> ACTIVEX <name> ;
		[ <dummy1: OF, PARENT> <parent> ] ;
		WIDTH <w>  ;
		HEIGHT <h>  ;
		PROGID <progid>  ;
	=>;
	_DefineActivex( <"name">, <"parent">, <row>, <col>, <w>, <h>, <progid> )

#xcommand PROGID <progid> ;
	=>;
	_HMG_ActiveControlBorder	:= <progid>

#xcommand DEFINE ACTIVEX <name> ;
	=>;
	_HMG_ActiveControlName		:= <"name">	;;
	_HMG_ActiveControlOf		:= ""		;;
	_HMG_ActiveControlRow		:= 0		;;
	_HMG_ActiveControlCol		:= 0		;;
	_HMG_ActiveControlWidth		:= 0		;;
	_HMG_ActiveControlHeight	:= 0		;;
	_HMG_ActiveControlBorder	:= 0		

#xcommand END ACTIVEX ;
	=>;
	_DefineActivex( ;
		_HMG_ActiveControlName , ;
		_HMG_ActiveControlOf , ;
		_HMG_ActiveControlRow , ;
		_HMG_ActiveControlCol , ;
		_HMG_ActiveControlWidth , ;
		_HMG_ActiveControlHeight , ;
		_HMG_ActiveControlBorder )

#undef BASEDEF_ACTIVEX
