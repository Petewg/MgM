/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample

  Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  AutoFill in Text Box

  Started by Bicahi Esgici <esgici@gmail.com>

  Enhanced by Roberto Lopez and Rathinagiri

  2009.05.12
*/

#include "minigui.ch"


PROCEDURE Main()

   Local aCountries := HB_ATOKENS( MEMOREAD( "Countries.lst" ), CRLF )

   ASORT( aCountries )             // This Array MUST be sorted

   DEFINE WINDOW frmAFTest;
      AT 0,0;
      WIDTH  550;
      HEIGHT 300;
      TITLE 'AutoFill in Text Box (by Bicahi Esgici)';
      MAIN

      ON KEY ESCAPE ACTION frmAFTest.Release

      DEFINE LABEL lblCountry
         ROW        50
         COL        50
         VALUE      "Country :"
         RIGHTALIGN .T.
         AUTOSIZE   .T.
      END LABEL

      DEFINE TEXTBOX txbCountry
         ROW         48
         COL         110
         WIDTH       200
         ONCHANGE    AutoFill( aCountries )
         ONGOTFOCUS  AFKeySet( aCountries )
         ONLOSTFOCUS AFKeyRls(  )
      END TEXTBOX

      DEFINE LISTBOX LIST1
         ROW 80
         COL 110
         WIDTH 200
         ITEMS {"Item 1","Item 2","Item 3","Item 4","Item 5","Item 6"}
         VALUE 1
      END LISTBOX

   END WINDOW

   frmAFTest.Center

   frmAFTest.Activate

RETURN

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE AutoFill( ;        // Auto filling text box
                aList,;      // Items list
                nCaller )    // NIL : OnChange, 1: UP, 2: Down

   STATIC cLastVal := '',;
      n1Result := 0

   LOCAL  cFrmName,;
          cTxBname,;
          cTxBValue,;        // Text Box Value
          nCarePos,;         // Text Box CaretPos
          cCurval := ''

   cFrmName := thiswindow.name
   cTxBName := this.focusedcontrol

   cTxBValue := GetProperty( cFrmName, cTxBName, "Value" )     // Text Box Value
   nCarePos  := GetProperty( cFrmName, cTxBName, "CaretPos" )  // Text Box CaretPos

   IF HB_ISNIL( nCaller )

      IF !( cLastVal == cTxBValue )

         cCurval  := LEFT( cTxBValue, nCarePos )

         IF !EMPTY( cCurval )

            n1Result := ASCAN( aList, { | c1 | UPPER( LEFT( c1, LEN( cCurval ) ) ) == UPPER( cCurval )} )

            IF n1Result > 0

               cCurval := aList[ n1Result ]

            ENDIF n1Result > 0

         ENDIF !EMPTY( cCurval )

         cLastVal := cCurval

         AF_Apply( cFrmName,cTxBName,cCurval, nCarePos )

      ENDIF

   ELSE

      IF n1Result > 0

         IF nCaller < 2
            n1Result -= IF( n1Result > 1, 1, 0 )
         ELSE
            n1Result += IF( n1Result < LEN( aList ), 1, 0 )
         ENDIF

         cCurval := aList[ n1Result ]

         cLastVal := cCurval

         AF_Apply( cFrmName,cTxBName,cCurval, nCarePos )

      ENDIF

   ENDIF

RETURN

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE AF_Apply(;
   cFrmName,;
   cTxBName,;
   cValue,;
   nPosit )

   SetProperty( cFrmName, cTxBName, "Value", cValue )
   SetProperty( cFrmName, cTxBName, "CaretPos", nPosit )

RETURN

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC AFKeySet( aitems )
   Local cFrmName := thiswindow.name

   ON KEY UP   OF &cFrmName  ACTION AutoFill( aitems, 1 )
   ON KEY DOWN OF &cFrmName  ACTION AutoFill( aitems, 2 )

RETURN

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE AFKeyRls()
   Local cFrmName := thiswindow.name

   RELEASE KEY UP   OF &cFrmName
   RELEASE KEY DOWN OF &cFrmName

   RETURN

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
