#define BASEDEF_MYBUTTON 

#xcommand @ <row>,<col> MYBUTTON <name> ;
		OF <parent> ;
		CAPTION <caption> ;
		ACTION <action> ;
	=>;
	_DefineMyButton(<(name)>,<row>,<col>,<caption>,<{action}>,<(parent)>)

#undef BASEDEF_MYBUTTON


#define BASEDEF_CLBUTTON

#xcommand @ <row>,<col> CLBUTTON <name> ;
		[ <of:OF, PARENT> <parent> ] ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
		CAPTION <caption> ;
		NOTETEXT <notes> ;
		[ <dummy:IMAGE, PICTURE> <cbitmap> ] ;
		ACTION <action> ;
		[ <default: DEFAULT> ] ;
	=>;
	_DefineCLButton(<(name)>,<row>,<col>,<caption>,<notes>,<{action}>,<(parent)>,<.default.>,<w>,<h>,<cbitmap>)

#undef BASEDEF_CLBUTTON


#define BASEDEF_SPBUTTON

#xcommand @ <row>,<col> SPLITBUTTON <name> ;
		[ <of:OF, PARENT> <parent> ] ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
		CAPTION <caption> ;
		ACTION <action> ;
		[ FONT <font> ] ;
		[ SIZE <size> ] ;
		[ <bold : BOLD> ] ;
		[ <italic : ITALIC> ] ;
		[ <underline : UNDERLINE> ] ;
		[ <strikeout : STRIKEOUT> ] ;
		[ TOOLTIP <tooltip> ] ;
		[ <default: DEFAULT> ] ;
	=>;
	_DefineSplitButton(<(name)>,<row>,<col>,<caption>,<{action}>,<(parent)>,<.default.>,<w>,<h>, ;
		<tooltip>, <font>, <size>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>)

#undef BASEDEF_SPBUTTON


#define BASEDEF_MYSYSLINK

#xcommand @ <row>,<col> MYSYSLINK <name> ;
		OF <parent> ;
		CAPTION <caption> ;
		ACTION <action> ;
	=>;
	_DefineMySysLink(<(name)>,<row>,<col>,<caption>,<{action}>,<(parent)>)

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
	_DefineAnimateRes ( <(name)>, <(parent)>, <col>, <row>, <w>, <h>, <file>, <n>, <tooltip>, <helpid>, <.invisible.> )

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
	_DefineWebCam ( <(name)>, <(parent)>, <col>, <row>, <w>, <h>, <.lOn.>, <rate>, <tooltip>, <helpid> )

#undef BASEDEF_WEBCAM


#define BASEDEF_ACTIVEX

#xcommand @ <row>,<col> ACTIVEX <name> ;
		[ <dummy1: OF, PARENT> <parent> ] ;
		WIDTH <w>  ;
		HEIGHT <h>  ;
		PROGID <progid>  ;
		[ EVENTMAP <aEvents> ]  ;
		[ <clientedge: CLIENTEDGE> ] ;
	=>;
	_DefineActivex( <(name)>, <(parent)>, <row>, <col>, <w>, <h>, <progid>, <aEvents>, <.clientedge.> )

#xcommand PROGID <progid> ;
	=>;
	_HMG_ActiveControlBorder	:= <progid>

#xcommand EVENTMAP <aEvents> ;
   =>;
   _HMG_ActiveControlValue := <aEvents>

#xcommand DEFINE ACTIVEX <name> ;
	=>;
	_HMG_ActiveControlName		:= <(name)>	;;
	_HMG_ActiveControlOf		:= ""		;;
	_HMG_ActiveControlRow		:= 0		;;
	_HMG_ActiveControlCol		:= 0		;;
	_HMG_ActiveControlWidth		:= 0		;;
	_HMG_ActiveControlHeight	:= 0		;;
	_HMG_ActiveControlValue         := Nil		;;
	_HMG_ActiveControlClientEdge	:= .f.		;;
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
		_HMG_ActiveControlBorder , ;
		_HMG_ActiveControlValue , ;
		_HMG_ActiveControlClientEdge )

#undef BASEDEF_ACTIVEX
