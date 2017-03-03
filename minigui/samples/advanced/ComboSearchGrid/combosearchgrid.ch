
    #command @ <row>, <col> COMBOSEARCHGRID <name>          ;
             [ <dummy1: OF, PARENT> <parent> ]              ;
                            [ HEIGHT <height> ]             ;
                            [ WIDTH <width> ]               ;
                            [ VALUE <value> ]               ;
                            [ FONT <fontname> ]             ;
                            [ SIZE <fontsize> ]             ;
                            [ <bold : BOLD> ]               ;
                            [ <italic : ITALIC> ]           ;
                            [ <underline : UNDERLINE> ]     ;
                            [ TOOLTIP <tooltip> ]           ;
                            [ BACKCOLOR <backcolor> ]       ;
                            [ FONTCOLOR <fontcolor> ]       ;
                            [ MAXLENGTH <maxlenght> ]       ;
                            [ <upper: UPPERCASE> ]          ;
                            [ <lower: LOWERCASE> ]          ;
                            [ <numeric: NUMERIC> ]          ;
                            [ ON GOTFOCUS <gotfocus> ]      ;
                            [ ON LOSTFOCUS <lostfocus> ]    ;
                            [ ON ENTER <enter> ]            ;
                            [ <RightAlign: RIGHTALIGN> ]    ;
                            [ <notabstop: NOTABSTOP> ]      ;
                            [ HELPID <helpid> ]             ;
                            [ ITEMS <aitems>  ]             ;
                            [ <anywhere :ANYWHERESEARCH> ]  ;
                            [ <dropheight :DROPPEDHEIGHT> ] ;
                            [ HEADERS <headers> ]           ;
                            [ WIDTHS <widths> ]             ;
                            [ JUSTIFY <aJust> ]             ;
                            [ <noshowheaders: NOHEADERS> ]  ;
             =>;
             _DefineComboSearchGrid( <"name">, <"parent">, <col>, <row>, <width>, <height>, <value>, ;
                <fontname>, <fontsize>, <tooltip>, <maxlenght>, <.upper.>, <.lower.>, <.numeric.>, ;
                <{lostfocus}>, <{gotfocus}>, <{enter}>, ;
                <.RightAlign.>, <helpid>, <.bold.>, <.italic.>, <.underline.>, <backcolor> , ;
                <fontcolor> , <.notabstop.>, <aitems>,<.anywhere.>,<dropheight>,<headers>, <aJust>, <widths>, !<.noshowheaders.> )

	#xcommand ANYWHERESEARCH	<sort>	;
	=>;
	_HMG_ActiveControlSort		:= <sort>

	#xcommand DROPPEDHEIGHT	<dropheight>	;
	=>;
	_HMG_ActiveControlIncrement	:= <dropheight>

    #xcommand DEFINE COMBOSEARCHGRID <name>;
       =>;
       _HMG_ActiveControlName		:= <"name">;;
       _HMG_ActiveControlOf   		:= Nil     ;;
       _HMG_ActiveControlRow           := Nil      ;;
       _HMG_ActiveControlCol           := Nil      ;;
       _HMG_ActiveControlHeight        := Nil      ;;
       _HMG_ActiveControlWidth         := Nil      ;;
       _HMG_ActiveControlValue         := Nil      ;;
       _HMG_ActiveControlFont          := Nil      ;;
       _HMG_ActiveControlSize          := Nil      ;;
       _HMG_ActiveControlFontBold      := .f.      ;;
       _HMG_ActiveControlFontItalic    := .f.      ;;
       _HMG_ActiveControlFontUnderLine := .f.      ;;
       _HMG_ActiveControlTooltip       := Nil      ;;
       _HMG_ActiveControlBackColor     := Nil      ;;
       _HMG_ActiveControlFontColor     := Nil      ;;
       _HMG_ActiveControlMaxLength     := Nil      ;;
       _HMG_ActiveControlUpperCase     := .f.      ;;
       _HMG_ActiveControlLowerCase     := .f.      ;;
       _HMG_ActiveControlNumeric       := .f.      ;;
       _HMG_ActiveControlOnGotFocus    := Nil      ;;
       _HMG_ActiveControlOnLostFocus   := Nil      ;;
       _HMG_ActiveControlOnEnter       := Nil      ;;
       _HMG_ActiveControlRightAlign    := .f.      ;;
       _HMG_ActiveControlNoTabStop     := .t.      ;;
       _HMG_ActiveControlHelpId        := Nil      ;;
       _HMG_ActiveControlItems		:= Nil     ;;
       _HMG_ActiveControlSort		:= .f.     ;; // anywhere search
       _HMG_ActiveControlIncrement	:= 0       ;; // dropped height
       _HMG_ActiveControlHeaders	:= Nil     ;;
       _HMG_ActiveControlWidths		:= Nil     ;;
       _HMG_ActiveControlJustify	:= Nil     ;;
       _HMG_ActiveControlSpacing	:= .t.
         
    #xcommand END COMBOSEARCHGRID;
       =>;
          _DefineComboSearchGrid(;
             _HMG_ActiveControlName,;
             _HMG_ActiveControlOf,;
             _HMG_ActiveControlCol,;
             _HMG_ActiveControlRow,;
             _HMG_ActiveControlWidth,;
             _HMG_ActiveControlHeight,;
             _HMG_ActiveControlValue,;
             _HMG_ActiveControlFont,;
             _HMG_ActiveControlSize,;
             _HMG_ActiveControlTooltip,;
             _HMG_ActiveControlMaxLength,;
             _HMG_ActiveControlUpperCase,;
             _HMG_ActiveControlLowerCase,;
             _HMG_ActiveControlNumeric,;
             _HMG_ActiveControlOnLostFocus,;
             _HMG_ActiveControlOnGotFocus,;
             _HMG_ActiveControlOnEnter,;
             _HMG_ActiveControlRightAlign,;
             _HMG_ActiveControlHelpId,;
             _HMG_ActiveControlFontBold,;
             _HMG_ActiveControlFontItalic,;
             _HMG_ActiveControlFontUnderLine,;
             _HMG_ActiveControlBackColor,;
             _HMG_ActiveControlFontColor,;
             _HMG_ActiveControlNoTabStop,;
             _HMG_ActiveControlItems,;
             _HMG_ActiveControlSort,;      //  anywhere search
             _HMG_ActiveControlIncrement,; //  droppedheight
             _HMG_ActiveControlHeaders ,;
             _HMG_ActiveControlJustify ,;
             _HMG_ActiveControlWidths ,;
             _HMG_ActiveControlSpacing ) 
