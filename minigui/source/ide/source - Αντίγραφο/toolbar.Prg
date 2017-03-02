#include "minigui.ch"
#include "ide.ch"




DECLARE WINDOW ToolbarBuilder

*------------------------------------------------------------*
PROCEDURE ToolbarProp()
*------------------------------------------------------------*
  LOAD WINDOW ToolbarProp
  CENTER WINDOW ToolbarProp
  ACTIVATE WINDOW ToolbarProp

RETURN

 
*------------------------------------------------------------*
PROCEDURE ToolbarInit( Mode AS STRING )  //? Invalid Hungarian
*------------------------------------------------------------*
 LOCAL Prop1          AS STRING
 LOCAL Prop2          AS STRING
 LOCAL A1             AS STRING
 LOCAL A2             AS STRING
 LOCAL x              AS NUMERIC
 LOCAL x1             AS NUMERIC
 LOCAL x2             AS NUMERIC
 LOCAL lFound         AS LOGICAL
 LOCAL itenspesq      AS NUMERIC
 LOCAL itenspesq2     AS NUMERIC
 LOCAL aitens         AS ARRAY
 LOCAL LinMain        AS STRING
 LOCAL xButton        AS NUMERIC   //? Invalid Hungarian
 LOCAL aToolbarValues AS ARRAY
 LOCAL xProps         AS ARRAY     //? Invalid Hungarian
 LOCAL cValue         AS STRING

 
 PUBLIC aVLToolbarHash AS ARRAY := HB_HASH()
 PUBLIC AVLButtonHash AS ARRAY := HB_HASH()
 PUBLIC lastitem      AS NUMERIC := 1
 PUBLIC DisableChange AS LOGICAL := .F.

 aItens  := {"DEFINE TOOLBAR","CAPTION","ACTION","BUTTONSIZE","FONT"," SIZE","BOLD","ITALIC","UNDERLINE","STRIKEOUT","TOOLTIP","FLAT","BOTTOM","RIGHTTEXT","GRIPPERTEXT","BORDER","BREAK","WRAP","CUSTOMIZE"}
 LinMain := ""

 IF Len( aToolbar ) > 0

    A1 := AllTrim( aToolbar[ 1 ] )

    // MsgBox( "A1= " + A1 )
    FOR itenspesq := 1 TO Len( aItens )
        // MsgBox( "searching " + Str( ITENSPESQ ) + " " + aItens[itenspesq] + " in string " + A1 )
        x1 := At( aItens[ itenspesq ], A1 )
        IF X1 # 0
           lFound := .F.
           FOR ITENSPESQ2 := ITENSPESQ+1 TO Len( aItens )
               X2 := At( aItens[ itenspesq2 ], A1 )

               IF X2 # 0
                  lFound  := .T.
                  LinMain += SubStr( A1, X1, x2-1 ) + CRLF
                  // MsgBox( "a-LinMain= "+LinMain )

                  A1      := SubStr( A1, x2, Len( A1 ) )
                  // MsgBox( "rest= " + A1 )

                  itenspesq2 := Len( aItens )
              ENDIF
           NEXT ITENSPESQ2

           IF ! lFound
              cValue  := SubStr( A1, X1 + Len( aItens[ itenspesq ] ), Len( A1 ) )
              A1      := ""
              LinMain += aItens[ itenspesq ] + " " + cValue + CRLF
              // MsgBox( "c-LinMain= " + LinMain )
           ENDIF
        ELSE
           LinMain += aItens[ itenspesq ] + " NIL" + CRLF
           // MsgBox( "b-LinMain= " + LinMain )
        ENDIF

     NEXT Itenspesq

    // MsgBox( "d-LinMain= " + LinMain )

     FOR X := 1 TO Len( aItens )
         A1 := AllTrim( MemoLine( LinMain, 1000, x, NIL, .T. ) )
         // MsgBox( "A1= " + A1 )

         A2 := AllTrim( SubStr( A1, ( Len( aItens[X])+1 ), ( Len(A1) - Len(aItens[X]))))
         // MsgBox( "A2= " + A2 )

         Prop1 := aItens[ X ]
         Prop2 := A2

         IF Prop1 = "FONT"
            Prop2 := StrTran( Prop2, '"', "" )
         ENDIF

         IF Prop1 = "BOLD"      .OR. ;
            Prop1 = "ITALIC"    .OR. ;
            Prop1 = "UNDERLINE" .OR. ;
            Prop1 = "STRIKEOUT" .OR. ;
            Prop1 = "FLAT"      .OR. ;
            Prop1 = "BOTTOM"    .OR. ;
            Prop1 = "RIGHTTEXT" .OR. ;
            Prop1 = "WRAP"      .OR. ;
            Prop1 = "BORDER"    .OR. ;
            Prop1 = "CUSTOMIZE" .OR. ;
            Prop1 = "BREAK"

            IF Prop2 = "NIL"
               Prop2 := ".F."
            ELSE
               Prop2 := ".T."
            ENDIF
         ENDIF

         IF Prop1 = "CAPTION"     .OR. ;
            Prop1 = "TOOLTIP"     .OR. ;
            Prop1 = "GRIPPERTEXT"

            // MsgBox( "Prop2-A= " + Prop2 )
            IF Prop2 <> "NIL"
               Prop2 := SubStr( Prop2, 2, Len( Prop2 ) - 2 )
               // MsgBox( "Prop2-B= " + Prop2 )
            ELSE
               Prop2 := ""
            ENDIF
         ENDIF
         
         if prop1 = " SIZE"
           prop1 := "SIZE"
        ENDIF 
       // IF PROP1 =   "DEFINE TOOLBAR"
       //  PROP1 := "NAME"
       // ENDIF 

         // MsgBox(str(x)+" valor de "+Prop1+CRLF)
          aVLToolbarHash[Prop1] := Prop2
      NEXT X

     

      ****read prop of buttons

      // Keywork list for a Button
      aItens := {"BUTTON","CAPTION","PICTURE","ADJUST","ACTION","TOOLTIP","SEPARATOR","AUTOSIZE"," DROPDOWN","WHOLEDROPDOWN","CHECK","GROUP"}

      FOR XBUTTON := 1 TO Len( aToolbar )-2

          LinMain := ""
          A1      := AllTrim( aToolbar[ XBUTTON +1] )
          // MsgBox("A1= "+A1)

          FOR itenspesq := 1 TO Len( aItens )
              // MsgBox( "searching " + Str( ITENSPESQ ) + " " + aItens[itenspesq]+" in string " + A1 )
              x1 := at(aItens[itenspesq],A1)

              IF X1 # 0
                 lFound := .F.

                 FOR ITENSPESQ2 := ITENSPESQ+1 TO Len( aItens )
                     X2 := At( aItens[ itenspesq2 ], A1 )

                     IF X2 # 0
                        lFound := .T.
                        LinMain += SubStr(A1,X1,x2-1) + CRLF
                        // MsgBox( "a-LinMain= " + LinMain )

                        A1 := SubStr( A1, x2, Len( A1 ) )
                        // MsgBox("rest= "+A1)

                        itenspesq2 := Len(aitens)
                     ENDIF

                 NEXT ITENSPESQ2

                 IF ! lFound
                    cValue  := SubStr( A1, X1 + Len( aItens[ itenspesq ] ), Len( A1 ) )
                    A1      := ""
                    LinMain += aItens[ itenspesq ] + " " + cValue + CRLF
                    // MsgBox( "c-LinMain= " + LinMain )
                 ENDIF
              ELSE
                 LinMain += aItens[ itenspesq ] + " NIL" + CRLF
                 // MsgBox( "b-LinMain= " + LinMain )
              ENDIF

           NEXT Itenspesq

           ******save values of button
           xProps:= Array( Len( aItens ) )
          

           FOR X := 1 TO Len( aItens )

               A1 := AllTrim( MemoLine( LinMain, 1000, x, NIL, .T. ) )
               // MsgBox( "A1= " + A1 )

               A2 := AllTrim( SubStr( A1, ( Len( aItens[ X ] ) + 1 ), ( Len( A1 ) - Len( aItens[ X ] ) ) ) )
               // MsgBox( "A2= " + A2 )

               Prop1 := lTrim( aItens[ X ] )
               Prop2 := A2

               IF Prop1 = "ADJUST"        .OR. ;
                  Prop1 = "SEPARATOR"     .OR. ;
                  Prop1 = "AUTOSIZE"      .OR. ;
                  Prop1 = "DROPDOWN"      .OR. ;
                  Prop1 = "WHOLEDROPDOWN" .OR. ;
                  Prop1 = "CHECK"         .OR. ;
                  Prop1 = "GROUP"

                  IF Prop2 = "NIL"
                     Prop2 := ".F."
                  ELSE
                     Prop2 := ".T."
                  ENDIF
               ENDIF

               IF Prop1 = "CAPTION" .OR. ;
                  Prop1 = "PICTURE" .OR. ;
                  Prop1 = "TOOLTIP"

                  IF Prop2 = "NIL"
                     // MsgBox( "Prop2A=" + Prop2 )
                     Prop2 := ""
                     // MsgBox( "Prop2B=" + Prop2 )
                  ELSE
                     // MsgBox( "Prop2A=" + Prop2 )
                     Prop2 = SubStr( Prop2, 2, Len( Prop2 ) - 2 )
                     // MsgBox( "Prop2B=" + Prop2 )
                  ENDIF
               ENDIF

               xProps[ x ] := Prop2
            
               
               // MsgBox( "xProps= " + Str( x ) + " = " + xProps[ x ] )
            NEXT X

          
          if .not. empty(xprops)                     
                aVLButtonHash[XBUTTON]  := HB_HASH()
            
        //      MSGBOX('XBUTTON=' + STR(XBUTTON)+ ' LEN= ' + Str( Len( aVLButtonHash ) ) )
              
               ToolbarFillButtonHash(XBUTTON,xProps)
          endif     

     //  msgbox('value hash a= ' +str(XBUTTON) + ' ' + aVLButtonHash[XBUTTON]["NAME"]+ ' key = >' + str(hb_HKeyAt( aVLButtonHash,XBUTTON ))+'<-'  )

         NEXT XBUTTON

      //     MsgBox('len hash= ' +   Str( Len( aVLButtonHash ) ) )
      //   MsgBox('len hash keys = ' +   Str( Len( hb_hkeys(aVLButtonHash) ) ) )

     IF mode == NIL
        ToolbarBuilder.Grid_1.DeleteAllitems

      
         FOR XBUTTON := 1 TO Len( aVLButtonHash )
         //MSGBOX(' VALOR = ' + aVLButtonHash[ XBUTTON ]["NAME"] )
            ToolbarBuilder.Grid_1.AddItem( {aVLButtonHash[ XBUTTON ]["NAME"] } )
         NEXT
        
         ToolbarFillForm()

        ToolbarBuilder.Grid_1.Value := 1
     ENDIF

  ELSE
    IF mode == NIL
       // MsgBox( "Len( atoolbar ) <= 0" )

       ToolbarBuilder.Grid_1.DeleteAllitems
       
       aItens  := {"DEFINE TOOLBAR","CAPTION","ACTION","BUTTONSIZE","FONT"," SIZE","BOLD","ITALIC","UNDERLINE","STRIKEOUT","TOOLTIP","FLAT","BOTTOM","RIGHTTEXT","GRIPPERTEXT","BORDER","BREAK","WRAP","CUSTOMIZE"}
       aToolbarValues := { "Toolbar_1","Toolbar_1","NIL","64,64","Arial","9",".F.",".F.",".F.",".F.","",".F.",".F.",".F.","",".F.",".F.",".F.",".F."}

       FOR x := 1 TO Len(aToolbarValues)
           prop1 := aItens[x]
           IF prop1 = " SIZE"
              prop1 := "SIZE"
           ENDIF 
           aVLToolbarHash[prop1] := aToolBarValues[x]
       NEXT

       ToolbarNewButtom()

    ENDIF

  ENDIF

RETURN


*--------------------------------------------------------------------*
PROCEDURE ToolbarFillButtonHash(XBUTTON AS NUMERIC, xProps AS ARRAY )
*--------------------------------------------------------------------*
  
                aVLButtonHash [XBUTTON] := HB_HASH() 
                aVLButtonHash [XBUTTON]["NAME"]         := xProps[1]
                aVLButtonHash [XBUTTON]["CAPTION"]      := xProps[2]
                aVLButtonHash [XBUTTON]["PICTURE"]      := xProps[3]           
                aVLButtonHash [XBUTTON]["ADJUST"]       := xProps[4]
                aVLButtonHash [XBUTTON]["ACTION"]       := xProps[5]
                aVLButtonHash [XBUTTON]["TOOLTIP"]      := xProps[6]
                aVLButtonHash [XBUTTON]["SEPARATOR"]    := xProps[7]
                aVLButtonHash [XBUTTON]["AUTOSIZE"]     := xProps[8]
                aVLButtonHash [XBUTTON]["DROPDOWN"]     := xProps[9]           
                aVLButtonHash [XBUTTON]["WHOLEDROPDOWN"]:= xProps[10]
                aVLButtonHash [XBUTTON]["CHECK"]        := xProps[11]
                aVLButtonHash [XBUTTON]["GROUP"]        := xProps[12]  
RETURN                




*------------------------------------------------------------*
PROCEDURE ToolbarFillForm( nItem AS NUMERIC )
*------------------------------------------------------------*
  DisableChange := .T.

  //if nitem = NIL
  nItem := ToolbarBuilder.Grid_1.Value
  //ENDIF

    IF nitem > 0 .AND. Len( aVLButtonHash ) > 0    
     
     ToolbarBuilder.Text_1.Value  := aVLButtonHash[ nitem]["NAME"]               	  // NAME
     ToolbarBuilder.Text_2.Value  := aVLButtonHash[ nitem]["CAPTION"]            	  // CAPTION
     ToolbarBuilder.Text_3.Value  := aVLButtonHash[ nitem]["PICTURE"]           	  // PICTURE
     ToolbarBuilder.Text_4.Value  := aVLButtonHash[ nitem]["TOOLTIP"]            	  // TOOLTIP
     ToolbarBuilder.Text_5.Value  := aVLButtonHash[ nitem]["ACTION"]             	  // ACTION
     ToolbarBuilder.check_1.Value := aVLButtonHash[ nitem]["ADJUST"]        == ".T."  // ADJUST
     ToolbarBuilder.check_2.Value := aVLButtonHash[ nitem]["SEPARATOR"]     == ".T."  // SEPARATOR
     ToolbarBuilder.check_3.Value := aVLButtonHash[ nitem]["AUTOSIZE"]      == ".T."  // AUTOSIZE
     ToolbarBuilder.check_4.Value := aVLButtonHash[ nitem]["DROPDOWN"]      == ".T."  // DROPDOWN
     ToolbarBuilder.check_5.Value := aVLButtonHash[ nitem]["WHOLEDROPDOWN"] == ".T."  // WHOLEDROPDOWN
     ToolbarBuilder.check_6.Value := aVLButtonHash[ nitem]["CHECK"]         == ".T."  // CHECK
     ToolbarBuilder.check_7.Value := aVLButtonHash[ nitem]["GROUP"]         == ".T."  // GROUP     
     
  ELSE
     ToolbarBuilder.Text_1.Value  := ""     // NAME
     ToolbarBuilder.Text_2.Value  := ""     // CAPTION
     ToolbarBuilder.Text_3.Value  := ""     // PICTURE
     ToolbarBuilder.Text_4.Value  := ""     // TOOLTIP
     ToolbarBuilder.Text_5.Value  := ""     // ACTION
     ToolbarBuilder.check_1.Value := .F.    // ADJUST
     ToolbarBuilder.check_2.Value := .F.    // SEPARATOR
     ToolbarBuilder.check_3.Value := .F.    // AUTOSIZE
     ToolbarBuilder.check_4.Value := .F.    // DROPDOWN
     ToolbarBuilder.check_5.Value := .F.    // WHOLEDROPDOWN
     ToolbarBuilder.check_6.Value := .F.    // CHECK
     ToolbarBuilder.check_7.Value := .F.    // GROUP
  ENDIF

  DisableChange := .F.

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarPropInit()
*------------------------------------------------------------*
  LOCAL cValue  AS STRING
  LOCAL nPos    AS NUMERIC
  LOCAL nWidth  AS NUMERIC
  LOCAL nHeight AS NUMERIC

    IF Len( aVLToolbarHash ) > 0
    
     ToolbarProp.Text_1.Value  :=      aVLToolbarHash[ "DEFINE TOOLBAR" ]                                   // Name
     ToolbarProp.Text_2.Value  := iif( aVLToolbarHash[ "CAPTION" ] # "NIL", aVLToolbarHash[ "CAPTION" ], ""    ) // Caption  **
     ToolbarProp.Text_3.Value  := iif( aVLToolbarHash[ "ACTION" ]  # "NIL", aVLToolbarHash[ "ACTION" ], "NIL" ) // Action   **
          
     cValue                    := aVLToolbarHash[ "BUTTONSIZE" ]
     nPos                      := At( ",", cValue )
     nWidth                    := SubStr( cValue, 1     , nPos-1        )
     nHeight                   := SubStr( cValue, nPos+1, Len( cValue ) )

     ToolbarProp.Text_4.Value  := nWidth                                                 // Width
     ToolbarProp.Text_5.Value  := nHeight                                                // Height
     ToolbarProp.Text_6.Value  := iif( aVLToolbarHash[ "TOOLTIP" ]    # "NIL", aVLToolbarHash[ "TOOLTIP" ], "" )  // Tooltip      **
     ToolbarProp.Text_7.Value  := iif( aVLToolbarHash[ "GRIPPERTEXT"] # "NIL", aVLToolbarHash[ "GRIPPERTEXT" ], "" )  // Grippertext  **
     ToolbarProp.Check_1.Value :=      aVLToolbarHash[ "FLAT" ]       == ".T."                              // Flat
     ToolbarProp.Check_2.Value :=      aVLToolbarHash[ "BOTTOM" ]     == ".T."                              // Bottom
     ToolbarProp.Check_3.Value :=      aVLToolbarHash[ "RIGHTTEXT" ]  == ".T."                              // Righttext
     ToolbarProp.Check_4.Value := 	   aVLToolbarHash[ "BORDER" ]     == ".T."                              // Border
     ToolbarProp.Check_5.Value := 	   aVLToolbarHash[ "BREAK" ]      == ".T."                              // Break
     ToolbarProp.Check_6.Value := 	   aVLToolbarHash[ "WRAP" ]       == ".T."                              // Customize
     ToolbarProp.Check_7.Value := 	   aVLToolbarHash[ "CUSTOMIZE" ]  == ".T."                              // Wrap
     
     
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarPropFont()
*------------------------------------------------------------*
  LOCAL Size      AS NUMERIC
  LOCAL Bold      AS LOGICAL
  LOCAL Italic    AS LOGICAL
  LOCAL Underline AS LOGICAL
  LOCAL StrikeOut AS LOGICAL
  LOCAL Font      AS USUAL      //? VarType
  LOCAL aFont     AS ARRAY

    IF Len( aVLToolbarHash ) > 0
     Font      := aVLToolbarHash[ "FONT" ]
     Size      := Val( aVLToolbarHash[ "SIZE" ] )
     Bold      := aVLToolbarHash[ "BOLD" ] == ".T."
     Italic    := aVLToolbarHash[ "ITALIC" ] == ".T."
     Underline := aVLToolbarHash[ "UNDERLINE" ] == ".T."
     Strikeout := aVLToolbarHash[ "STRIKEOUT" ] == ".T."

     aFont     := GetFont( Font, Size, Bold, Italic, NIL, Underline, Strikeout, 0 )

     IF ! EMPTY( aFont[ 1 ] )
        
        aVLToolbarHash[ "FONT" ]      := aFont[ 1 ]          // FontName
        aVLToolbarHash[ "SIZE" ]      := Str(  aFont[ 2 ] )  // FontSize
        aVLToolbarHash[ "BOLD" ]      := xToc( aFont[ 3 ] )  // FontBold
        aVLToolbarHash[ "ITALIC" ]    := xToc( aFont[ 4 ] )  // FontItalic
        aVLToolbarHash[ "UNDERLINE" ] := xToc( aFont[ 6 ] )  // FontUnderline
        aVLToolbarHash[ "STRIKEOUT" ] := xToc( aFont[ 7 ] )  // FontStrikeout

     ENDIF

  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarPropOk()
*------------------------------------------------------------*

   IF Len( aVLToolbarHash ) > 0
   
   
     aVLToolbarHash[ "DEFINE TOOLBAR" ] := ToolbarProp.Text_1.Value                                  // Name
     aVLToolbarHash[ "CAPTION" ]        := ToolbarProp.Text_2.Value                                  // caption
     aVLToolbarHash[ "ACTION" ]         := ToolbarProp.Text_3.Value                                  // Action
     aVLToolbarHash[ "BUTTONSIZE" ]     := ToolbarProp.Text_4.Value + "," + ToolbarProp.Text_5.Value // Width, height
     aVLToolbarHash[ "TOOLTIP" ]        := ToolbarProp.Text_6.Value                                  // Tooltip
     aVLToolbarHash[ "GRIPPERTEXT" ]    := ToolbarProp.Text_7.Value                                  // Grippertext

     aVLToolbarHash[ "FLAT" ]           := xToc( ToolbarProp.check_1.Value )                         // Flat
     aVLToolbarHash[ "BOTTOM" ]         := xToc( ToolbarProp.check_2.Value )                         // Bottom
     aVLToolbarHash[ "RIGHTTEXT" ]      := xToc( ToolbarProp.check_3.Value )                         // Righttext
     aVLToolbarHash[ "BORDER" ]         := xToc( ToolbarProp.check_4.Value )                         // Border
     aVLToolbarHash[ "BREAK" ]          := xToc( ToolbarProp.check_5.Value )                         // Break
     aVLToolbarHash[ "WRAP" ]           := xToc( ToolbarProp.check_6.Value )                         // Customize
     aVLToolbarHash[ "CUSTOMIZE" ]      := xToc( ToolbarProp.check_7.Value )                         // Wrap
     
     
  ENDIF

  RELEASE WINDOW ToolbarProp

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarPropCancel()
*------------------------------------------------------------*
  RELEASE WINDOW ToolbarProp
RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarNameChange()
*------------------------------------------------------------*
  IF DisableChange
     RETURN
  ENDIF

  IF Len( AllTrim( ToolbarBuilder.Text_1.Value ) ) = 0
     MsgInfo( "ToolBar Button Must Have a Name (Item:" + Str( ToolbarBuilder.Grid_1.Value ) + ")", "HMGS-IDE" )
     ToolbarBuilder.Text_1.SetFocus
     RETURN
  ENDIF

  ToolbarBuilder.Grid_1.Item( ToolbarBuilder.Grid_1.Value ) := ToolbarBuilder.Text_1.Value

  ToolbarValueChange()

RETURN


*------------------------------------------------------------------------------
PROCEDURE ToolbarDropDownChange()

  IF DisableChange
     RETURN
  ENDIF

  IF ToolbarBuilder.Check_4.Value .AND. ToolbarBuilder.Check_5.Value
     MsgInfo( "DropDown and WholeDropDown Styles Are Mutually Exclusive (Item:" + Str( ToolbarBuilder.Grid_1.Value ) + ")", "HMGS-IDE" )
     ToolbarBuilder.Check_4.Value := iif( ToolbarBuilder.Check_4.Value, .F., .T. )
     RETURN
  ENDIF

  ToolbarValueChange()

RETURN


*------------------------------------------------------------------------------
PROCEDURE ToolbarWholeDropDownChange()

  IF DisableChange
     RETURN
  ENDIF

  IF ToolbarBuilder.Check_5.Value .AND. ToolbarBuilder.Check_4.Value
     MsgInfo( "DropDown and WholeDropDown Styles Are Mutually Exclusive (Item:" + Str( ToolbarBuilder.Grid_1.Value ) + ")", "HMGS-IDE" )
     ToolbarBuilder.Check_5.Value := iif( ToolbarBuilder.Check_5.Value, .F., .T. )
     RETURN
  ENDIF

  ToolbarValueChange()

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarValueChange( Param ) // Added to take out Warning W0001 Ambiguous Reference
*------------------------------------------------------------*
  LOCAL nItem AS NUMERIC

  IF DisableChange
     RETURN
  ENDIF

  IF Param = nil  //? Where does Param come from (never called with a parameter)
     nItem := ToolbarBuilder.Grid_1.Value
     // MsgBox( "nitem= " + Str( nItem ) )
  ELSE
     nitem := Param
     // MsgBox( "param ->nitem= " + Str( param ) )
  ENDIF

 IF nItem > 0 .AND. nItem <= Len( aVLButtonHash )
 
     aVLButtonHash[nitem][ "NAME" ]          := ToolbarBuilder.Text_1.Value           // NAME
     aVLButtonHash[nitem][ "CAPTION" ]       := ToolbarBuilder.Text_2.Value           // CAPTION
     aVLButtonHash[nitem][ "PICTURE" ]       := ToolbarBuilder.Text_3.Value           // PICTURE
     aVLButtonHash[nitem][ "TOOLTIP" ]       := ToolbarBuilder.Text_4.Value           // TOOLTIP     
     aVLButtonHash[nitem][ "ACTION" ]        := ToolbarBuilder.Text_5.Value           // ACTION    
     aVLButtonHash[nitem][ "ADJUST" ]        := xToc( ToolbarBuilder.check_1.Value )  // ADJUST
     aVLButtonHash[nitem][ "SEPARATOR" ]     := xToc( ToolbarBuilder.check_2.Value )  // SEPARATOR
     aVLButtonHash[nitem][ "AUTOSIZE" ]      := xToc( ToolbarBuilder.check_3.Value )  // AUTOSIZE
     aVLButtonHash[nitem][ "DROPDOWN" ]      := xToc( ToolbarBuilder.check_4.Value )  // DROPDOWN
     aVLButtonHash[nitem][ "WHOLEDROPDOWN" ] := xToc( ToolbarBuilder.check_5.Value )  // WHOLEDROPDOWN
     aVLButtonHash[nitem][ "CHECK" ]         := xToc( ToolbarBuilder.check_6.Value )  // CHECK
     aVLButtonHash[nitem][ "GROUP" ]         := xToc( ToolbarBuilder.check_7.Value )  // GROUP
     
  ENDIF

RETURN


*------------------------------------------------------------*
// save prop of TOOLBAR and buttons
PROCEDURE ToolbarOk( Mode AS USUAL )  //? Invalid Hungarian
*------------------------------------------------------------*
  LOCAL cText      AS STRING
  LOCAL aTempArray AS ARRAY   := {}
  LOCAL nItem      AS NUMERIC

  LOCAL T2         AS USUAL  //? VarType
  LOCAL T3         AS USUAL  //? VarType
  LOCAL T4         AS USUAL  //? VarType
  LOCAL T5         AS USUAL  //? VarType
  LOCAL T6         AS USUAL  //? VarType
  LOCAL T11        AS USUAL  //? VarType
  LOCAL T15        AS USUAL  //? VarType

//LOCAL XTEXT      AS USUAL := ""  // TO TEST

  IF Mode == NIL
     ToolbarValueChange()
  ENDIF


   IF Len( aVLToolbarHash ) > 0 .AND. Len( aVLButtonHash ) > 0
         
     t2    := AllTrim( aVLToolbarHash[ "CAPTION" ] )
     t3    := AllTrim( aVLToolbarHash[ "ACTION" ] )
     t4    := AllTrim( aVLToolbarHash[ "BUTTONSIZE" ] )
     t5    := AllTrim( aVLToolbarHash[ "FONT" ] )
     t6    := AllTrim( aVLToolbarHash[ "SIZE" ] )
     t11   := AllTrim( aVLToolbarHash[ "TOOLTIP" ] )
     t15   := AllTrim( aVLToolbarHash[ "GRIPPERTEXT" ] )
         
     cText := Space( 5 ) + "DEFINE TOOLBAR " + aVLToolbarHash[ "DEFINE TOOLBAR" ]

      iif( Len(t2) > 0 .AND. t2 # "NIL"   , cText += " CAPTION "      + '"' + t2 + '"'   , NIL )
      iif( Len(t3) > 0 .AND. t3 # "NIL"   , cText += " ACTION "       +       t3         , NIL )
      iif( Len(t4) > 0 .AND. t4 # "NIL"   , cText += " BUTTONSIZE "   +       t4         , NIL )
      iif( Len(t5) > 0 .AND. t5 # "NIL"   , cText += " FONT "         + '"' + t5 + '"'   , NIL )
      iif( Len(t6) > 0 .AND. t6 # "NIL"   , cText += " SIZE "         +       t6         , NIL )
      iif( aVLToolbarHash[ "BOLD" ]      = ".T."       , cText += " BOLD"                             , NIL )
      iif( aVLToolbarHash[ "ITALIC" ]    = ".T."       , cText += " ITALIC"                           , NIL )
      iif( aVLToolbarHash[ "UNDERLINE" ] = ".T."       , cText += " UNDERLINE"                        , NIL )
      iif( aVLToolbarHash[ "STRIKEOUT" ] = ".T."       , cText += " STRIKEOUT"                        , NIL )
      iif( Len(t11) > 0 .AND. t11 # "NIL" , cText += " TOOLTIP "      + '"' + t11 + '"'  , NIL )
      iif( aVLToolbarHash[ "FLAT" ]      = ".T."       , cText += " FLAT"                             , NIL )
      iif( aVLToolbarHash[ "BOTTOM" ]    = ".T."       , cText += " BOTTOM"                           , NIL )
      iif( aVLToolbarHash[ "RIGHTTEXT" ] = ".T."       , cText += " RIGHTTEXT"                        , NIL )
   //iif( Len(t15) > 0 .AND. t15 # "NIL" , cText += " GRIPPERTEXT " + '"' + t15 + '"'   , NIL ) //GRIPPERTEXT Property works only for toolbars defined inside splitbox.
     iif( aVLToolbarHash[ "BORDER" ]    = ".T."       , cText += " BORDER"                           , NIL )
     iif( aVLToolbarHash[ "BREAK" ]     = ".T."       , cText += " BREAK"                            , NIL )
     iif( aVLToolbarHash[ "WRAP" ]      = ".T."       , cText += " CUSTOMIZE"                        , NIL )
     iif( aVLToolbarHash[ "CUSTOMIZE" ] = ".T."       , cText += " WRAP"                             , NIL )


     aAdd( aTempArray, cText )
     cText := ""

     ******PROPERTIES OF BUTTON
       FOR nItem := 1 TO Len( aVLButtonHash )           
         
         cText += Space( 12 ) + "BUTTON " + aVLButtonHash[ nitem][ "NAME" ]                                                       // NAME **
         iif( Len( AllTrim( aVLButtonHash[nitem]["CAPTION"])) > 0, cText += " CAPTION " + '"' + aVLButtonHash[ nitem]["CAPTION" ] + '"', NIL )  // CAPTION
         iif( Len( AllTrim( aVLButtonHash[nitem]["PICTURE"])) > 0, cText += " PICTURE " + '"' + aVLButtonHash[ nitem]["PICTURE" ] + '"', NIL )  // PICTURE
         iif( aVLButtonHash[nitem]["ADJUST"] = ".T."            ,  cText += " ADJUST"       , NIL )                                             // ADJUST
         cText += " ACTION " + iif( Empty( aVLButtonHash[nitem]["ACTION"] ), "NIL"         ,    aVLButtonHash[ nitem]["ACTION" ] )              // ACTION **
         iif( Len( AllTrim( aVLButtonHash[nitem]["TOOLTIP"])) > 0 .AND. aVLButtonHash[nitem]["TOOLTIP"] # "NIL", cText += " TOOLTIP " + '"' + aVLButtonHash[ nitem]["TOOLTIP" ] + '"', NIL )  // TOOLTIP
         iif( aVLButtonHash[nitem]["SEPARATOR"] = ".T."          , cText += " SEPARATOR"    , NIL )                                 			// SEPARATOR
         iif( aVLButtonHash[nitem]["AUTOSIZE"] = ".T."           , cText += " AUTOSIZE"     , NIL )                                 			// AUTOSIZE
         iif( aVLButtonHash[nitem]["DROPDOWN"] = ".T."           , cText += " DROPDOWN"     , NIL )                                 			// DROPDOWN
         iif( aVLButtonHash[nitem]["WHOLEDROPDOWN"] = ".T."      , cText += " WHOLEDROPDOWN", NIL )                                 			// WHOLEDROPDOWN
         iif( aVLButtonHash[nitem]["CHECK"] = ".T."              , cText += " CHECK"        , NIL )                                 			// CHECK
         iif( aVLButtonHash[nitem]["GROUP"] = ".T."              , cText += " GROUP"        , NIL )                                 			// GROUP

         aAdd( aTempArray, cText )

         // xText += cText + CRLF  // TO TEST
         cText := ""
     next

     cText := Space( 5 ) + "END TOOLBAR"

     aAdd( aTempArray, cText )

     aToolBar := aTempArray
     // MsgBox( xText ) // TO TEST
     lChanges := .T.
  ELSE
     aToolbar := {}
  ENDIF

  //? To be completed new code to show Toolbar on form when added/change like Menu Builder -> ok done
  if len(aToolBar) > 0 .and. Valtype(Mode) <> "C"
     xCreateToolbar( aToolBar )
  endif 

  //A := ""
  //FOR Y := 1 TO Len( aToolbar )
  //    A += aToolbar[ Y ] + CRLF
  //NEXT Y
  //
  // MsgBox( A, "Toolbar-FINAL" )

  IF IsWindowDefined( ToolbarBuilder )
     RELEASE WINDOW ToolbarBuilder
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarCancel()
*------------------------------------------------------------*
   RELEASE WINDOW ToolbarBuilder
RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarUp()
*------------------------------------------------------------*
   LOCAL nValue AS NUMERIC
   LOCAL xTemp  AS USUAL

   IF ToolbarBuilder.Grid_1.Value > 1

      nValue := ToolbarBuilder.Grid_1.Value
      // MsgBox( "nValue-up= " + Str( nValue ) )

      xTemp                       := aVLButtonHash[ nValue     ]
      aVLButtonHash[ nValue     ] := aVLButtonHash[ nValue - 1 ]
      aVLButtonHash[ nValue - 1 ] := xTemp
     

      ToolbarFillGrid()

      lastitem := nValue - 1
      // MsgBox( "last-up= " + Str( lastitem ) )

      ToolbarBuilder.Grid_1.Value := nValue - 1

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarDown()
*------------------------------------------------------------*
  LOCAL tValue AS NUMERIC  //? Invalid Hungarian
  LOCAL xTemp  AS USUAL

  IF ToolbarBuilder.Grid_1.Value < ToolbarBuilder.Grid_1.ItemCount

      tValue                  := ToolbarBuilder.Grid_1.Value
      xTemp                       := aVLButtonHash[ tValue     ]
      aVLButtonHash[ tValue     ] := aVLButtonHash[ tValue + 1 ]
      aVLButtonHash[ tValue + 1 ] := xTemp
    

     // MsgBox( "tValue-down= " + Str( tValue ) )

     ToolbarFillGrid()

     LastItem := tValue + 1 //? Public Var Change Name
     // MsgBox("last-down= " + Str( lastitem ) )

     ToolbarBuilder.Grid_1.Value := TValue + 1
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarNext()
*------------------------------------------------------------*

  IF ToolbarBuilder.Grid_1.Value < ToolbarBuilder.Grid_1.ItemCount
     // MsgBox( "Value= "     + Str( ToolbarBuilder.Grid_1.Value     ) )
     // MsgBox( "ItemCount= " + Str( ToolbarBuilder.Grid_1.ItemCount ) )
     ToolbarBuilder.Grid_1.Value := ToolbarBuilder.Grid_1.Value + 1
  ELSE
     *******INSERT IN LAST TOOLBARINSERT()
     ToolbarNewButtom()
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarNewButtom()
*------------------------------------------------------------*
  LOCAL XBUTTON AS NUMERIC
  LOCAL xProps
  LOCAL cName  AS STRING  := "NewButton" + AllTrim( Str( Len( aVLButtonHash ) + 1 ) )
  
  LOCAL aValue AS ARRAY   := { cName,"New Caption","",".F.","","NIL",".F.",".F.",".F.",".F.",".F.",".F." }
  LOCAL nValue AS NUMERIC := ToolbarBuilder.Grid_1.ItemCount

   //MsgBox( "LEN-aVLButtonHash a=" + Str( Len( aVLButtonHash ) ) )
    
  XBUTTON := len(aVLButtonHash)+1
  xProps := aValue
  ToolbarFillButtonHash(XBUTTON,xProps)
    
   //MsgBox( "LEN-aVLButtonHash b=" + Str( Len( aVLButtonHash ) )  + ' VALUE = '+  aVLButtonHash [XBUTTON]["NAME"] )

  ToolbarFillGrid()

  ToolbarBuilder.Grid_1.Value := ToolbarBuilder.Grid_1.ItemCount

  ToolbarFillForm()

  lastitem := nValue

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarPrior()
*------------------------------------------------------------*

  IF ToolbarBuilder.Grid_1.Value > 1
     ToolbarBuilder.Grid_1.Value := ToolbarBuilder.Grid_1.Value - 1
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarInsert()
*------------------------------------------------------------*
  LOCAL cName   AS STRING
  LOCAL aValue  AS ARRAY
  LOCAL nValue  AS NUMERIC
  LOCAL XBUTTON AS NUMERIC
  LOCAL xProps, aNewTemp
  LOCAL nPosini, nPosfin, x

  IF ToolbarBuilder.Grid_1.Value > 0
  
     cName         := "NewButton" + AllTrim( Str( Len( aVLButtonHash )+1 ) )
     aValue        := { cName, "New Caption","",".F.","","NIL",".F.",".F.",".F.",".F.",".F.",".F." }
    
              
     XBUTTON := len(aVLButtonHash)+1
     xProps := aValue
     ToolbarFillButtonHash(XBUTTON,xProps)  
     
     nPosini := ToolbarBuilder.Grid_1.Value        
     aNewTemp := aVLButtonHash[XBUTTON] 
     nPosfin := ToolbarBuilder.Grid_1.ItemCount+1
     
          
     //msgbox('xbutton value = ' + str(xbutton) )
     
     
      for x =  nPosfin to nPosini+1 step -1
          // msgbox( ' x= ' + str(x) )
          aVLButtonHash[ x ] := aVLButtonHash[ x-1 ]     
      next x   
      aVLButtonHash[ nPosini ] := aNewTemp
     
   
     nValue    := ToolbarBuilder.Grid_1.Value

     ToolbarFillGrid()
     ToolbarFillForm()

     lastitem                    := nValue
     ToolbarBuilder.Grid_1.Value := nValue
  ELSE
     // MsgBox( "go to ToolbarNext" )
     ToolbarNext()
  ENDIF

RETURN



*------------------------------------------------------------*
PROCEDURE ToolbarDelete()
*------------------------------------------------------------*
  LOCAL nValue AS NUMERIC
  LOCAL nPosini AS NUMERIC
  LOCAL nPosfin AS NUMERIC
  LOCAL x AS NUMERIC

  IF ToolbarBuilder.Grid_1.ItemCount > 0

    // msgbox('len avlbuttonhash= ' + str(len(aVLButtonHash))  ) 
       
     nPosini := ToolbarBuilder.Grid_1.Value
    // FOR X = 1 TO LEN(aVLButtonHash)
    //   msgbox('value hash a= ' +str(x) + ' ' + aVLButtonHash[X]["NAME"]+ ' key = >' + str(hb_HKeyAt( aVLButtonHash, x ))+'<-'  )
    // NEXT  
     
           
    // msgbox('value hash = ' + aVLButtonHash[ToolbarBuilder.Grid_1.ItemCount]["NAME"]  )
    if nPosini = len(aVLButtonHash)
       HB_HDELAT(aVLButtonHash,nPosini)
    else
       nPosfin := len(aVLButtonHash)
        for x =  nPosini+1 to  nPosfin 
        // msgbox( ' x= ' + str(x) )
         aVLButtonHash[ x-1 ] :=    aVLButtonHash[ x ]     
         next x          
       HB_HDELAT(aVLButtonHash,nPosfin )           
     endif
     
    // msgbox('len avlbuttonhash= ' + str(len(aVLButtonHash))  )           
    // FOR X = 1 TO LEN(aVLButtonHash)
    //   msgbox('value hash c= '+str(x) + ' '  + aVLButtonHash[X]["NAME"]  )
    // NEXT  
                  
        nValue := iif( Len( aVLButtonHash ) = 0, 0, ToolbarBuilder.Grid_1.Value )
     // MsgBox( "nValue = " + Str( nValue ) )

     ToolbarFillGrid()

     IF nValue > 1
        // MsgBox( "Value1= " + Str( ToolbarBuilder.Grid_1.Value ) )
        ToolbarFillForm()
        ToolbarBuilder.Grid_1.Value := nValue -1
     ELSE
        // MsgBox( "Value2= " + Str( ToolbarBuilder.Grid_1.Value ) )
        ToolbarFillForm()
        ToolbarBuilder.Grid_1.Value := nValue
        // MsgBox( "Value2A= " + Str( ToolbarBuilder.Grid_1.Value ) )
     ENDIF
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ToolbarFillGrid()
*------------------------------------------------------------*
  LOCAL xValue AS USUAL
  LOCAL i      AS NUMERIC

  ToolbarBuilder.Grid_1.DeleteAllitems

 
 FOR i := 1 TO Len( aVLButtonHash )
     //MSGBOX('VALUE = ' + STR(I) +" "+  aVLButtonHash[ i]["NAME" ] )
      xvalue := aVLButtonHash[ i]["NAME" ]
      ToolbarBuilder.Grid_1.AddItem( { xValue } )
 NEXT
 

RETURN


*------------------------------------------------------------*
 PROCEDURE MakeToolbar()
*------------------------------------------------------------*
  ToolbarInit("NOBUILDER")
  if len(aVLToolbarHash) > 0
    xCreateToolbar()
  endif

RETURN


*------------------------------------------------------------*
 FUNCTION xCreateToolbar()
*------------------------------------------------------------*
  LOCAL t4         := AllTrim( aVLToolbarHash[  "BUTTONSIZE"] )
  LOCAL nbutwidth  := substr(t4,1,(at(',',t4)-1) )
  LOCAL nbutheight := substr(t4,(at(',',t4)+1),len(t4))
  LOCAL cCaption   := AllTrim( aVLToolbarHash[ "CAPTION" ] )
  LOCAL cAction    := AllTrim( aVLToolbarHash[ "ACTION" ] )  
     // MSGBOX('cACTION2= ' + cACTION )
  LOCAL uAction    := "{||MsgInfo( [" + cAction + "])}"
     // MSGBOX('cAction = ' + uAction )
  LOCAL x := 0
  LOCAL y := 0
  LOCAL w :=  nbutwidth
  LOCAL h :=  nbutheight
  
  LOCAL cFontname      := AllTrim( aVLToolbarHash[ "FONT" ] )
  LOCAL nFontsize      := Val( AllTrim( aVLToolbarHash[ "SIZE" ] ) )
  LOCAL ctooltip       := AllTrim( aVLToolbarHash[ "TOOLTIP" ] )
  LOCAL lflat          :=          aVLToolbarHash[ "FLAT" ] 
  LOCAL lbottom        :=          aVLToolbarHash[ "BOTTOM" ] 
  LOCAL lrighttext     :=          aVLToolbarHash[ "RIGHTTEXT" ] 
  LOCAL lbreak         :=          aVLToolbarHash[ "BREAK" ]
  LOCAL lbold          :=          aVLToolbarHash[ "BOLD" ]
  LOCAL litalic        :=          aVLToolbarHash[ "ITALIC" ]
  LOCAL lunderline     :=          aVLToolbarHash[ "UNDERLINE" ] 
  LOCAL lstrikeout     :=          aVLToolbarHash[ "STRIKEOUT" ]
  LOCAL lborder        :=          aVLToolbarHash[ "BORDER" ]     
  LOCAL lmixedbuttons  := NIL
  LOCAL nrows          := NIL
  LOCAL ntbsize        := NIL
  LOCAL cimagelst      := NIL
  LOCAL chotimagelst   := NIL     
  LOCAL lwrap          :=          aVLToolbarHash[ "CUSTOMIZE" ] 
  LOCAL lcustom        :=          aVLToolbarHash[ "WRAP" ]
  LOCAL nItem,;
        cName,;
        cimage,;
        ladjust,;
        lseparator,;
        lautosize,;
        lcheck,;
        lgroup,;
        ldropdown,;
        lWholeDropDown,;
        cgotfocus,;
        clostfocus,;
        cimageindex

     cAction := IFEMPTY( cAction, "Action is not defined", cAction )

     if IsControlDefined( Toolbar, Form_1 )
        DoMethod( "Form_1", "Toolbar", "Release" )
     endif  

     _HMG_ActiveFormName    := iif( Empty( _HMG_ActiveFormName ), 'Form_1', _HMG_ActiveFormName )
     _HMG_BeginWindowActive := .T.
     _HMG_ActiveToolBarName := "Toolbar"

     _DefineToolBar ( "Toolbar", "Form_1", x,y, cCaption, uAction, &nbutwidth, &nbutheight, cFontname, nFontsize, ctooltip , &lflat ,;
                    &lbottom , &lrighttext, &lbreak ,  &lbold ,  &litalic , &lunderline ,  &lstrikeout , &lborder , ;
                    lmixedbuttons, nrows , ntbsize , cimagelst , chotimagelst , &lwrap, lcustom )

    FOR nItem := 1 TO Len( aVLButtonHash )   
    
        cName      :=  AllTrim( aVLButtonHash[nitem]["NAME"]) 
        cCaption   :=  AllTrim( aVLButtonHash[nitem]["CAPTION"])           
        cimage     :=  AllTrim( aVLButtonHash[nitem]["PICTURE"])
        ladjust    :=           aVLButtonHash[nitem]["ADJUST"]         
        caction    :=  AllTrim( aVLButtonHash[nitem]["ACTION"])
        cAction    :=  IfEmpty( cAction, "Action is not defined", cAction )
        uAction    :=  "{||MsgInfo( [" + cAction + "])}"
        cTooltip   :=  AllTrim( aVLButtonHash[nitem]["TOOLTIP"])
        lseparator :=           aVLButtonHash[nitem]["SEPARATOR"] 
        lautosize  :=           aVLButtonHash[nitem]["AUTOSIZE"] 
        lcheck     :=           aVLButtonHash[nitem]["CHECK"]
        lgroup     :=           aVLButtonHash[nitem]["GROUP"] 
        ldropdown  :=           aVLButtonHash[nitem]["DROPDOWN"]
        lWholeDropDown :=       aVLButtonHash[nitem]["WHOLEDROPDOWN"]
        cgotfocus      := NIL
        clostfocus     := NIL
        lflat          := NIL
        cimageindex    := NIL

    _DefineToolButton (  cName, "Toolbar",x,y,cCaption, caction, w, h, cimage , ctooltip , cgotfocus , clostfocus , lflat ,;
      &lseparator , &lautosize , &lcheck , &lgroup , &ldropdown , &lWholeDropDown, &ladjust , cimageindex )

    NEXT nItem

    _EndToolBar()

     _HMG_BeginWindowActive := .F.

RETURN( NIL )

