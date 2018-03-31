#include <hmg.ch>

PROCEDURE DrawBorder(;                             // Draw a border around any control
		cPWinName,;      // Name of parent window
		cControlName,;   // Name of control to be bordered 
		nPenWidth,;
		aUpColor,;
		aDnColor,;
		nSpace )

    LOCAL nControlRow := GetProperty( cPWinName, cControlName, "ROW" ),;
          nControlCol := GetProperty( cPWinName, cControlName, "COL" ),;
          nControlWid := GetProperty( cPWinName, cControlName, "WIDTH" ),;
          nControlHig := GetProperty( cPWinName, cControlName, "HEIGHT" )

    LOCAL nBordrRow,;
          nBordrCol,;
          nBordrWid,;
          nBordrHig

    LOCAL aCoords,;
	      nLineNo  

    HB_DEFAULT( @nPenWidth, 1 )
    HB_DEFAULT( @nSpace, 0 )

	IF HB_ISNIL( aUpColor )
	   aUpColor := BLACK
	ENDIF

	IF HB_ISNIL( aDnColor )
	   aDnColor := BLACK
	ENDIF

	IF HB_ISNUMERIC( aUpColor )
	   IF aUpColor = 1
	      aUpColor := GRAY
	   ELSEIF aUpColor = 0
	      aUpColor := WHITE
	   ENDIF
	ENDIF

	IF HB_ISNUMERIC( aDnColor )
	   IF aDnColor = 1
	      aDnColor := GRAY
	   ELSEIF aDnColor = 0
	      aDnColor := WHITE
	   ENDIF
	ENDIF

	IF ! HB_ISARRAY( aDnColor )
	   aDnColor := WHITE
	ENDIF

    nBordrRow := nControlRow - nPenWidth - nSpace
    nBordrCol := nControlCol - nPenWidth - nSpace
    nBordrWid := nControlWid + nSpace
    nBordrHig := nControlHig + nSpace

	aCoords := { { nControlRow + nBordrHig, nBordrCol             },;  // Down left corner
	             { nBordrRow,               nBordrCol             },;  // Up left corner
	             { nBordrRow,               nControlCol + nBordrWid },;  // Up right corner
	             { nControlRow + nBordrHig, nControlCol + nBordrWid },;  // Down right corner
	             { nControlRow + nBordrHig, nBordrCol             } }  // Down left corner

    FOR nLineNo := 1 TO 4 	

        DRAW LINE IN WINDOW &cPWinName ;
            AT aCoords[ nLineNo, 1 ],   aCoords[ nLineNo, 2 ];
            TO aCoords[ nLineNo+1, 1 ], aCoords[ nLineNo+1, 2 ];
            PENWIDTH nPenWidth ;
            PENCOLOR IF( nLineNo < 3, aUpColor, aDnColor )

    NEXT nLineNo

RETURN // DrawBorder()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
