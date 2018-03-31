 #include "minigui.ch" 
 #include "TSBrowse.ch" 
  
  
 PROCEDURE MAIN 
  
    LOCAL oBrw, aDatos, aArray, aHead, aSize, aFoot, aPict, aAlign, aName, aFontHF 
    LOCAL aFont := {} 
    LOCAL cFontName := _HMG_DefaultFontName 
    LOCAL nFontSize := 11 
    LOCAL nY, nX, oCol 
  
  
    SET DECIMALS TO 4 
    SET DATE     TO GERMAN 
    SET EPOCH    TO 2000 
    SET CENTURY  ON 
    SET EXACT    ON 
  
    DEFINE FONT Font_1  FONTNAME cFontName SIZE nFontSize 
    DEFINE FONT Font_2  FONTNAME cFontName SIZE nFontSize BOLD 
  
    AAdd( aFont, GetFontHandle( "Font_1" ) ) 
    AAdd( aFont, GetFontHandle( "Font_2" ) ) 
  
    DEFINE WINDOW test ; 
       TITLE "SetArray For Report Demo" ; 
       MAIN ; 
       NOMAXIMIZE NOSIZE 
  
    DEFINE STATUSBAR FONT cFontName SIZE nFontSize 
       STATUSITEM "0"                 // WIDTH 0 FONTCOLOR BLACK 
       STATUSITEM "Item 1" WIDTH 230  // FONTCOLOR BLACK 
       STATUSITEM "Item 2" WIDTH 230  // FONTCOLOR BLACK 
       STATUSITEM "Item 3" WIDTH 230  // FONTCOLOR BLACK 
    END STATUSBAR 
  
    nY := test.HEIGHT - GetProperty( "test", "StatusBar", "Height" ) - 70 
    nX := 20 
  
    @ nY, nX LABEL Lbl_Test  VALUE ""  WIDTH 200  HEIGHT 40  BACKCOLOR { 35, 179, 15} 
  
  
    DEFINE TBROWSE oBrw ; 
       AT 1 + iif( IsVistaOrLater(), GetBorderWidth()/2, 0 ), ; 
          1 + iif( IsVistaOrLater(), GetBorderHeight()/2, 0 ) ; 
       WIDTH test.WIDTH - 2 * GetBorderWidth() ; 
       HEIGHT test.HEIGHT - GetTitleHeight() - ; 
          GetProperty( "test", "StatusBar", "Height" ) - ; 
          2 * GetBorderHeight() - 50 ; 
       ENUMERATOR ; 
       FONT  cFontName  SIZE  nFontSize ; 
       GRID  EDIT 
  
       aDatos   := CreateDatos() 
  
       aArray   := aDatos[ 1 ] 
       aHead    := aDatos[ 2 ] 
       aSize    := aDatos[ 3 ] 
       aFoot    := aDatos[ 4 ] 
       aPict    := aDatos[ 5 ] 
       aAlign   := aDatos[ 6 ] 
       aName    := aDatos[ 7 ] 
  
    // hFontHead := aFont[1]                // normal Header 
    // hFontFoot := aFont[2]                //  bold  Footer 
    // aFontHF   := { hFontHead, hFontFoot } 
  
    // aFontHF   := aFont[1]                // normal Header, Footer 
       aFontHF   := aFont[2]                //  bold  Header, Footer 
  
       oBrw := SetArrayTo( "oBrw", "test", aArray, aFontHF, aHead, aSize, aFoot, aPict, aAlign, aName ) 
  
       oBrw:nWheelLines    := 1 
       oBrw:nClrLine       := COLOR_GRID 
       oBrw:nHeightCell    += 5 
       oBrw:nHeightHead    += 5 
       IF ! Empty( aFoot ) 
          oBrw:nHeightFoot += 5 
       ENDIF 
       IF oBrw:lEnum 
          oBrw:nHeightSpecHd := oBrw:nHeightCell 
       ENDIF 
  
       oCol := oBrw:GetColumn("ColName_7") 
       oCol:bPrevEdit := {|uVl,oBr    | mPrevEdit(uVl, oBr) } 
       oCol:bPostEdit := {|uVl,oBr,lAp| mPostEdit(uVl, oBr, lAp) } 
  
    END TBROWSE 
  
    END WINDOW 
  
    DoMethod( "test", "Activate" ) 
  
 RETURN 
  
 * ====================================================================== 
  
 STATIC FUNCTION CreateDatos() 
  
    LOCAL i, k := 1000, aDatos, aHead, aSize, aFoot, aPict, aAlign, aName 
  
    aDatos := Array( k ) 
    FOR i := 1 TO k 
       aDatos[ i ] := { " ", ;                         // 1 
          i, ;                                         // 2 
          ntoc( i ) + "_123", ;                        // 3 
          Date() + i, ;                                // 4 
          PadR( "Test line - " + ntoc( i ), 20 ), ;    // 5 
          Round( ( 10000 -i ) * i / 3, 2 ), ;          // 6 
          100.00 * i, ;                                // 7 
          0.12, ;                                      // 8 
          Round( 100.00 * i * 0.12, 2 ), ;             // 9 
          Round( 1234567.00 / i, 3 ), ;                // 10 
          PadR( "Line " + StrZero( i, 5 ), 20 ), ;     // 11 
          Date(), ;                                    // 12 
          Time(), ;                                    // 13 
          i % 2 == 0 }                                 // 14 
    NEXT 
  
    aHead  := AClone( aDatos[ 1 ] ) 
    // AEval(aHead, {|x,n| aHead[ n ] := "Head_" + hb_ntos(n) }) 
    AEval( aHead, {| x, n| aHead[ n ] := "Head" + hb_ntos( n ) + ; 
       iif( n % 2 == 0, CRLF + "SubHead" + hb_ntos( n ), "" ) } ) 
  
    aFoot  := Array( Len( aDatos[ 1 ] ) ) 
    AEval( aFoot, {| x, n| aFoot[ n ] := n } ) 
    // aFoot  := .T.                        // подножие есть с пустыми значениями 
  
    aPict     := Array( Len( aDatos[ 1 ] ) )   // можно не задавать, формируются 
    aPict[ 10 ] := "99999999999.999"           // автоматом для C,N по мах значению 
  
    aSize     := Array( Len( aDatos[ 1 ] ) )   // можно не задавать, формируются 
    aSize[ 10 ] := aPict[ 10 ]                 // автоматом по мах значению в колонке 
  
    aAlign    := Array( Len( aDatos[ 1 ] ) )   // тип поля C   - DT_LEFT 
    aAlign[ 2 ] := DT_CENTER                   // D,L - DT_CENTER 
                                               // N   - DT_RIGHT 
  
    aName     := Array( Len( aDatos[ 1 ] ) ) 
    AEval( aName, {| x, n| aName[ n ] := "ColName_" + hb_ntos( n ) } ) 
  
 RETURN { aDatos, aHead, aSize, aFoot, aPict, aAlign, aName } 
  

 STATIC FUNCTION mPrevEdit( uVal, oBrw ) 
 LOCAL cForm   := oBrw:cParentWnd 
 LOCAL cBrw    := oBrw:cControlName 
 LOCAL nRowPos := oBrw:nRowPos 
 LOCAL nCell   := oBrw:nCell 
 LOCAL oCol    := oBrw:aColumns[ nCell ] 
 LOCAL lRet    := .T., oCell, nY, nX, nW, nH, cLbl := "Lbl_Test" 
  
 LOCAL lSH     := .T.   // .T. - SpecHead, .F. - Cell
  
  If oCol:cName == "ColName_7"
     oCell := oBrw:GetCellinfo(nRowPos, nCell, lSH) 
     nY := oCell:nRow + If( lSH, 0, oCell:nHeight ) 
     nX := oCell:nCol 
     nW := oCell:nWidth 
     nH := oCell:nHeight
     SetProperty(cForm, cLbl, "Row"    , nY) 
     SetProperty(cForm, cLbl, "Col"    , nX) 
     SetProperty(cForm, cLbl, "Width"  , nW) 
     SetProperty(cForm, cLbl, "Height" , nH) 
     SetProperty(cForm, cLbl, "Visible", .T.) 
     SetProperty(cForm, cLbl, "Value"  , "") 
  EndIf 
  
 RETURN lRet 
  

 STATIC FUNCTION mPostEdit( uVal, oBrw, lApp ) 
 LOCAL cForm   := oBrw:cParentWnd 
 LOCAL cBrw    := oBrw:cControlName 
 LOCAL nCell   := oBrw:nCell 
 LOCAL oCol    := oBrw:aColumns[ nCell ] 
 LOCAL lRet    := .T., cLbl := "Lbl_Test" 
  
  If oCol:cName == "ColName_7" 
     SetProperty(cForm, cLbl, "Visible", .F.) 
  EndIf 
  
 RETURN lRet 
 