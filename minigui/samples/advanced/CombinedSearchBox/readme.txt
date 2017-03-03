@...COMBOSEARCHBOX / DEFINE COMBOSEARCHBOX : Define a Combined Search Box Control.
 

      @ <nRow> , <nCol> COMBOSEARCHBOX <ControlName>

            [ OF | PARENT <ParentWindowName> ]

            [ HEIGHT <nHeight> ]

            [ WIDTH <nWidth> ]

            [ VALUE <nValue> ]

            [ FONT <cFontName> SIZE <nFontSize> ]

            [ BOLD ] [ ITALIC ] [ UNDERLINE ] [ STRIKEOUT ]

            [ TOOLTIP <cToolTipText> ]

            [ BACKCOLOR <aBackColor> ]

            [ FONTCOLOR <aFontColor> ]

            [ MAXLENGTH <nInputLength> ]

            [ UPPERCASE | LOWERCASE ]

            [ ON GOTFOCUS <OnGotFocusProcedur> | <bBlock> ]

            [ ON LOSTFOCUS <OnLostFocusProcedure> | <bBlock> ]

            [ ON ENTER <OnEnterProcedure> | <bBlock> ]

            [ RIGHTALIGN ]

            [ NOTABSTOP ]

            [ HELPID <nHelpId> ]

            [ ITEMS <aItems> ]
 

      DEFINE COMBOSEARCHBOX <Controlname>

            <PropertyName>    <PropertyValue>

            <EventName> <EventProcedure> | <bBlock>

      END COMBOSEARCHBOX 
 

- Properties:

	Row
	Col
	Height
	Width
	Value
	Items
	FontName
	FontSize
	FontItalic
	FontUnderline
	FontStrikeout
	ToolTip
	BackColor
	FontColor
	CaretPos
	Name (R)
	TabStop (D)
	Parent (D)
	Numeric (D)
	MaxLength  (D)
	UpperCase  (D)
	LowerCase (D)
	RightAlign (D)
	HelpId (D)

      D: Available at control definition only
      R: Read-Only

- Events:

      - OnGotFocus
      - OnChange
      - OnLostFocus
      - OnEnter

- Methods:

      - Show
      - Hide
      - SetFocus
      - Release
      - Refresh
      - Save

- Caution:

The user can't have 'on change' procedure block for this box, since this event is handled internally.
