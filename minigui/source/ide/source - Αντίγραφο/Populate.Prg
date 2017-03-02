#include "minigui.ch"
#include "ide.ch"
#include "Fileio.CH"
#include 'dbstruct.ch'

#define PROGRAM 'Field Manager'
#define COPYRIGHT ' by Pierpaolo Martinello, 2003-2006 Minigui Extended'

#define WM_CLOSE   0x0010
#define IS_CHAR(x)     (ValType(x) == "C")
#TRANSLATE ZAPS(<X>) => AllTrim(Str(<X>))

DECLARE WINDOW ReportEditor

MEMVAR campi  // Make warning W0001 go away
MEMVAR _DBFNAME1

*-----------------------------------------------------------------------------*
FUNCTION Get_field()
*-----------------------------------------------------------------------------*
  PRIVATE campi AS ARRAY := {} //? Is this Ok

  Populate_List()

  IF Used()

     LOAD WINDOW List_field

     List_Field.Center
     // Escape( "List_field" )
     List_Field.Activate

  ENDIF

RETURN( NIL )


*-----------------------------------------------------------------------------*
FUNCTION Ccampi( Act AS LOGICAL )
*-----------------------------------------------------------------------------*
   LOCAL Fl    AS STRING  := ""
   LOCAL ts    AS STRING  := ""
   LOCAL cs    AS STRING  := ""
   LOCAL Fmt   AS STRING  := ""
   LOCAL kk    AS NUMERIC
   LOCAL n     AS NUMERIC
   LOCAL campi AS ARRAY   := {}

   // act := iif( act==NIL, .F., act )
   DEFAULT Act TO .F.

   FOR kk := 1 TO List_Field.List_102.ItemCount
       aAdd( Campi, List_Field.List_102.Item( kk ) )
   NEXT

   IF act
      FOR n := 1 TO Len( campi )

          cs := Eval( chblk, _DbAnames, Upper( campi[n] ), 2 )

          IF Cs = "L"
             Fl += Zaps( Eval( chblk, _DbAnames, Upper( campi[n] ), 3 ) + 1 ) + ","
          ELSE
             Fl += Zaps( Eval( chblk, _DbAnames, Upper( campi[n] ), 3 )     ) + ","
          ENDIF

          Fmt += "'',"

          IF cs # "N"
             ts += ".F.,"
          ELSE
             ts += ".T.,"
          ENDIF
      NEXT

      Fmt                       := "{" + Left( Fmt, Len(Fmt)-1) + "}"
      ReportEditor.Text_2.Value := Fmt + "," + Fmt
      ReportEditor.Text_4.Value := "{" + Left(Fl,Len(Fl)-1) + "}"
      ReportEditor.Text_5.Value := "{" + Left(ts,Len(ts)-1) + "}"
      ReportEditor.Text_6.Value := Fmt
      ReportEditor.Text_7.Value := Alias()
      campi                     := AToS( campi )

  ENDIF

RETURN( campi )


*-----------------------------------------------------------------------------*
FUNCTION Proper( inString AS STRING )      // Created By Piersoft 01/04/1995 KILLED Bugs!
*-----------------------------------------------------------------------------*
  LOCAL OutString  AS STRING := ""
  LOCAL interm     AS STRING := inString
  LOCAL CapNxt     AS STRING := ""
  LOCAL c_1        AS STRING

  DO WHILE Chr( 32 ) $ interm
     c_1    := SubStr( interm, 1, At( Chr(32), interm ) - 1 )
     capnxt := capnxt + Upper( Left( c_1, 1 ) ) + Right( c_1, Len( c_1 ) - 1 ) + " "
     interm := SubStr( interm, Len( c_1 ) + 2, Len( interm ) - Len( c_1 ) )
  ENDDO

  Outstring := Capnxt + Upper( Left( interm, 1 ) ) + Right( interm, Len( interm ) - 1 )

RETURN( outString )


*-----------------------------------------------------------------------------*
FUNCTION Populate_list( _DBfile AS STRING )   // Created By Piersoft 16/02/2005
*-----------------------------------------------------------------------------*
  PUBLIC _DbStructArr AS ARRAY     := {}
  PUBLIC _DbAnames    AS ARRAY     := {}
  PUBLIC chblk        AS CODEBLOCK := { | arry, Find, RetPos | iif( aScan( arry, find ) > 0, _DbStructarr[ aScan( _DbaNames, Find ) ][ RetPos ], NIL ) }

  IF ! Used()
     DbOpendbf( _DBfile )
  ENDIF

  _DbStructarr := dbStruct()

  aEval( _DbStructArr, { | Campo | aAdd( _DbaNames, Campo[ DBS_NAME ] ) } )

  IF Len( _DbaNames ) == 0
     RETURN( NIL )
  ENDIF

RETURN( _DbaNames )


*-----------------------------------------------------------------------------*
FUNCTION Escape( Arg1 AS STRING )
*-----------------------------------------------------------------------------*
   LOCAL WinName := iif( arg1 == NIL, ProcName( 1 ), Arg1 )

   ON KEY ESCAPE ACTION _ReleaseWindow( WinName )

RETURN( NIL )


*-----------------------------------------------------------------------------*
FUNCTION ModPrintFieldAddAll()
*-----------------------------------------------------------------------------*
  LOCAL i AS NUMERIC

  List_Field.List_102.DeleteAllitems

  FOR i := 1 TO List_Field.List_101.ItemCount
      List_Field.List_102.AddItem(List_Field.List_101.Item( i ) )
  NEXT

  List_Field.List_101.DeleteAllitems

  List_Field.List_102.Value := 1

  List_Field.List_102.SetFocus

RETURN( NIL )


*-----------------------------------------------------------------------------*
FUNCTION Mfield( Arg1 AS STRING )
*-----------------------------------------------------------------------------*
  local Start    AS USUAL   := List_Field.List_102.Value
  local in_list  AS USUAL   := List_Field.List_102.Item( start )
  local old_pre  AS USUAL
  local old_post AS USUAL
  LOCAL cap      AS ARRAY    := {}
  LOCAL v        AS NUMERIC

  arg1 := iif( arg1 == NIL, "UP", Upper( arg1 ) )

  IF arg1 = "UP"
     if start > 1
        old_pre                           := List_Field.List_102.Item( start - 1 )
        List_Field.List_102.Item( start ) := old_pre

        start--

        List_Field.List_102.Item( start ) := in_list
     ELSE
        start := List_Field.List_102.ItemCount
        List_Field.List_102.AddItem( in_list )
        List_Field.List_102.DeleteItem( 1 )
     ENDIF
  ELSE
     // DOWN
     IF start < List_Field.List_102.ItemCount
        old_pre                           := List_Field.List_102.Item( start + 1 )
        List_Field.List_102.Item( start ) := old_pre

        start++

        List_Field.List_102.Item( start ) := in_list
     ELSE
        aAdd( cap, List_Field.List_102.Item( start ) )

        FOR v := 1 TO List_Field.List_102.ItemCount - 1
            aAdd( cap, List_Field.List_102.Item( v ) )
        NEXT

        List_Field.List_102.DeleteAllitems
        aEval( cap, { | x | List_Field.List_102.AddItem( x ) } )
        start := 1
     ENDIF
  ENDIF

  List_Field.List_102.Value := start

  List_Field.List_102.SetFocus

RETURN nil


*-----------------------------------------------------------------------------*
FUNCTION Single_Add( insert AS LOGICAL )
*-----------------------------------------------------------------------------*
  LOCAL pos1    AS NUMERIC
  LOCAL pos2    AS NUMERIC
  LOCAL pos3    AS NUMERIC
  LOCAL n_label AS NUMERIC
  LOCAL p_rel   AS NUMERIC := 0
  LOCAL i       AS NUMERIC

  // insert := iif( insert==NIL, .F., insert )
  DEFAULT Insert TO .F.

  List_Field.List_101.SetFocus

  Pos1 := List_Field.List_101.Value

  IF Pos1 > 0
     Pos2 := List_Field.List_102.Value
     Pos3 := List_Field.List_102.ItemCount

     List_Field.List_102.AddItem( List_Field.List_101.Item( Pos1 ) )

     n_label := List_Field.List_102.ItemCount

     List_Field.List_101.DeleteItem( Pos1 )

     IF insert
        IF Pos2 < Pos3
           List_Field.List_102.Value := pos3 + 1
           FOR i := 1 TO ( Pos3 - Pos2 + 1 )
               Mfield( "UP" )
           NEXT
        ENDIF
     ELSE
        List_Field.List_102.Value := Pos3 + 1
     ENDIF

     Pos3  := List_Field.List_102.ItemCount
     p_rel := 0

  ENDIF

  IF List_Field.List_101.ItemCount >= Pos1
     List_Field.List_101.Value := Pos1
  ELSE
     List_Field.List_101.Value := Pos1 - 1
  ENDIF

  List_Field.List_101.SetFocus

  Check_Len()

RETURN( NIL )


*-----------------------------------------------------------------------------*
FUNCTION Remove_All()
*-----------------------------------------------------------------------------*
  LOCAL aName AS ARRAY := populate_list()

  List_Field.List_101.DeleteAllitems

  aEval( _DbaNames, { | x | List_Field.List_101.AddItem( x ) } )

  List_Field.List_102.DeleteAllitems

  List_Field.List_101.Value := 1

  List_Field.List_101.SetFocus

  Check_Len()

RETURN Nil


*-----------------------------------------------------------------------------*
FUNCTION Single_Remove()
*-----------------------------------------------------------------------------*
  LOCAL Pos1  AS NUMERIC
  LOCAL Pos2  AS NUMERIC
  LOCAL Pos3  AS NUMERIC
  LOCAL Cap   AS ARRAY   := {}
  LOCAL _dba  AS ARRAY   := {}

  List_Field.List_102.SetFocus

  Pos1 := List_Field.List_102.Value
  Pos3 := List_Field.List_102.ItemCount

  IF Pos1 > 0
     List_Field.List_102.DeleteItem( Pos1 )

     cap := Ccampi()

     List_Field.List_101.DeleteAllitems

     aEval( _DbaNames, { | x | iif( aScan( Cap, x ) < 1, List_Field.List_101.AddItem( x ), "" ) } )
  ELSE
     List_Field.List_102.Value := 1
  ENDIF

  IF Pos3 = Pos1
     List_Field.List_102.Value := Pos3 - 1
  ELSE
     List_Field.List_102.Value := Pos1
  ENDIF

  List_Field.List_102.SetFocus

  Check_Len()

RETURN NIL


*-----------------------------------------------------------------------------*
PROCEDURE Check_Len()
*-----------------------------------------------------------------------------*
  LOCAL LK    AS NUMERIC := 1
  LOCAL nxt_C AS NUMERIC := 0
  LOCAL tmp_L AS NUMERIC := 0
// LOCAL v     AS NUMERIC := 0

  FOR lk := 1 TO List_Field.List_102.ItemCount
      tmp_l := Eval( chblk, _DbaNames, List_Field.List_102.Item( LK ), 3 ) + 1
      nxt_C += tmp_L
  NEXT

  IF nxt_c > 0
     List_Field.Label_101.Value := "Colum lengt := " + Zaps( nxt_c ) + " Chars."
  ELSE
     List_Field.Label_101.Value := "Colum lengt := "
  ENDIF

RETURN


*-----------------------------------------------------------------------------*
FUNCTION DbOpendbf( _DBfile AS STRING, edMODE )
*-----------------------------------------------------------------------------*
  LOCAL cOpen       AS STRING  := aData[ _DBFPATH ]
  LOCAL _DBFNAME    AS STRING

  PRIVATE _DBFNAME1 AS STRING

  IF ! Empty( ReportEditor.Text_7.Value ) .AND. Used()
     IF ! MsgYesNo( "Abandon the current Workarea?" )
         RETURN ReportEditor.Text_7.Value
     ELSE
        ReportEditor.Text_7.Value := ""
     ENDIF
  ENDIF

  _dbFile := iif( _dbFile == NIL, ReportEditor.Text_7.Value, _dbFile )

  IF Empty( _dbFile ) .OR. _dbFile == NIL .OR. ! File( _dbFile + ".dbf" )
     _DbfName1 := ""
     _DbfName1 := GetFile( { { "xBase File  (*.dbf)", "*.dbf" } }, "Select a dbf to open", cOpen, .F. )

     IF Empty( _DbfName1 )
        _DbfName1 := ReportEditor.Text_7.Value
     ELSE
        aData[ _DBFPATH ] := GetCurrentFolder()
        SavePreferences()
     ENDIF

  ELSE
     _DbfName1 := _DBfile
  ENDIF

  _DbfName1 := AllTrim( _DbfName1 )

  IF Len( _DbfName1 ) > 0
     IF Used()
        CLOSE ALL
        IF MG_USE( "&_DbfName1", NIL, .T., 5, .T., "" )
          _DBfname := _DbfName1
        ENDIF
     ELSE
        IF MG_USE( "&_DbfName1", NIL, .T., 5, .T., "" )
           _DBfname := _DbfName1
        ENDIF
     ENDIF
  ENDIF

RETURN Proper( Lower( cFileNoExt( _DbfName1 ) ) )


*-----------------------------------------------------------------------------*
FUNCTION MG_USE(                             ;
                 cDbfName      AS STRING,    ; // Database Name
                 cAlias        AS STRING,    ; // Database Alias
                 lUseExclusive AS LOGICAL,   ; // Open Exclusive ?
                 nTries        AS NUMERIC,   ; // How many retry
                 lAsk          AS LOGICAL,   ; // Ask if you want to retry
                 cMessage      AS STRING,    ; // NOT USED!!
                 cdPage        AS USUAL      ; // Code Page
               )
*-----------------------------------------------------------------------------*
  LOCAL nTriesOrig
  LOCAL lReturn    := .F.

  IF File( cDbfName ) = .F. .AND. File( cDbfName + ".dbf" ) = .F.
     MsgStop( "No access to database file!", cDbfName )
     RETURN lReturn
  ENDIF

  nTriesOrig := nTries
  lReturn    := .F.

  DO WHILE nTries > 0
     DBUSEAREA( .T., NIL, cDbfName, cAlias, ! lUseExclusive, NIL, cdPage )
     IF (! NetErr()) .AND. Used()
        lReturn := .T.
        EXIT
     ENDIF

     Inkey( .5 )
     nTries--

     IF nTries = 0 .AND. lAsk
        IF MsgRetryCancel( "Database is occupied by another user", "No access" )
           nTries := nTriesOrig
        ENDIF
     ENDIF
  ENDDO

RETURN( lReturn )

/*  // FUNCTIONs already defined in h_controlmisc.prg

 *-----------------------------------------------------------------------------*
 FUNCTION cFileNoPath( cPathMask )
 *-----------------------------------------------------------------------------*
  LOCAL n := RAt( "\", cPathMask )

  RETURN iif( n > 0 .AND. n < Len( cPathMask ), ;
      Right( cPathMask, Len( cPathMask ) - n ), ;
     iif( ( n := At( ":", cPathMask ) ) > 0, ;
     Right( cPathMask, Len( cPathMask ) - n ), cPathMask ) )

  *-----------------------------------------------------------------------------*
  FUNCTION cFileNoExt( cPathMask )
  *-----------------------------------------------------------------------------*>
     LOCAL cName := AllTrim( cFileNoPath( cPathMask ) )
     LOCAL n     := At( ".", cName )

  RETURN AllTrim( iif( n > 0, Left( cName, n - 1 ), cName ) )
*/


*-----------------------------------------------------------------------------*
STATIC FUNCTION aToS( aArray AS ARRAY )                      // Array to String
*-----------------------------------------------------------------------------*
  LOCAL i        AS NUMERIC
  LOCAL nLen     AS NUMERIC := Len( aArray )
  LOCAL cType    AS STRING
  LOCAL cElement AS STRING
  LOCAL cArray   AS STRING  := ""

  FOR i := 1 TO nLen
      cElement := xChar( aArray[ i ] )
      IF ( cType := ValType( aArray[ i ] ) ) == "A"
         cArray += cElement
      ELSE
         cArray += "'" + cElement + "',"
      ENDIF
  NEXT

  cArray := "{" + Left( cArray, Len( cArray ) - 1 ) + "}"

RETURN( cArray )


*-----------------------------------------------------------------------------*
STATIC FUNCTION xChar( pxValue AS USUAL )
*-----------------------------------------------------------------------------*
   LOCAL cType     AS STRING  := ValType( pxValue )
   LOCAL cValue    AS STRING  := ""
   LOCAL nDecimals AS NUMERIC := Set( _SET_DECIMALS )

   DO CASE
      CASE cType $  "CM";  cValue := pxValue
      CASE cType == "N" ;  nDecimals := iif( pxValue == Int( pxValue ), 0, nDecimals ) ; cValue := LTrim( Str( pxValue, 20, nDecimals ) )
      CASE cType == "D" ;  cValue := dTos( pxValue )
      CASE cType == "L" ;  cValue := iif( pxValue, "T", "F" )
      CASE cType == "A" ;  cValue := aToS( pxValue )
      CASE cType $  "UE";  cValue := "NIL"
      CASE cType == "B" ;  cValue := "{|| ... }"
      CASE cType == "O" ;  cValue := "{" + pxValue:ClassName + "}"
   ENDCASE

RETURN( cValue )


*-----------------------------------------------------------------------------*
* Start Of custom Addon controls for ReportEditor.Fmg 23/08/2006 16.58
*-----------------------------------------------------------------------------*

*-----------------------------------------------------------------------------*
FUNCTION Check_ALen( Arg1 AS STRING, Campo AS STRING )
*-----------------------------------------------------------------------------*
  LOCAL Fl  AS STRING  := ""
  LOCAL Fn  AS STRING  := ""
  LOCAL e   AS LOGICAL := .T.
  LOCAL p1  AS ARRAY   := {}
  LOCAL p2  AS ARRAY   := {}
  local s1  AS NUMERIC := 0
  LOCAL s2  AS NUMERIC := 0
  LOCAL e1  AS NUMERIC := 0
  LOCAL e2  AS NUMERIC := 0
  LOCAL cfn AS LOGICAL := .F.

  Campo := iif( Campo == NIL, "Widths", Campo )
  Arg1  := AllTrim( Arg1 )

  IF Campo = "Header"

     s1 := At(  "{", Arg1 )
     s2 := Rat( "{", Arg1 )
     e1 := At(  "}", Arg1 )
     e2 := Rat( "}", Arg1 )

     IF s1 < s2
        IF e1 < e2
           BEGIN SEQUENCE
             P1 := macrocompile(left(arg1,e1),"Part ONE of Header!")
             aEval( P1,{|x| cfn := ValType(x)#"C"})
           END SEQUENCE

           IF cfn
              e := .F.
              MsgStop("Type Argument Error in part ONE of Header!")
              RETURN e
           ENDIF

           BEGIN SEQUENCE
             P2 := macrocompile(SubStr(arg1,s2),"Part TWO of Header!")
             aEval( P2,{|x| cfn := ValType(x) # "C"})
           END SEQUENCE

           IF cfn
              e := .F.
              MsgStop("Type Argument Error in part TW0 of Header!")
              RETURN e
           ENDIF

           Fl := &( ReportEditor.Text_3.Value )

           IF Len( P1 ) # Len( Fl )
              e := .F.
              MsgStop( "Number of Argument Error in part ONE of Header!" )
              RETURN e
           ENDIF

           IF Len( P2 ) # Len( Fl )
              e := .F.
              MsgStop( "Number of Argument Error in part TWO of Header!" )
              RETURN e
           ENDIF
        ELSE
           e := .F.
           MsgStop("Header must be contain two array!")
           RETURN e
        ENDIF
     ELSE
        e := .F.
        MsgStop( "Header must be contain two array!" )
        RETURN e
     ENDIF
     RETURN e
  ENDIF   */

  BEGIN SEQUENCE
    Fl := MacroCompile( ReportEditor.Text_3.Value, Campo )
    Fn := MacroCompile( Arg1, Campo )
  END SEQUENCE

  IF ValType( Fl )== "A"
     IF Len( Fl ) # Len( fn ) .AND. Campo # "Header"
        MsgStop( "Number of wrong elements between the fields"        + CRLF + ;
                 PadC( "declares and those inserting to you in", 44 ) + CRLF + PadC( Upper( Campo ) + ".", 44 ) )
         e := .F.
     ENDIF

     IF Campo = "Totals" .AND. e
        Check_t( Fl, Fn )
     ENDIF
  ELSE
     e := .F.
  ENDIF

RETURN e


*-----------------------------------------------------------------------------*
FUNCTION Check_T( Fl, Fn )
*-----------------------------------------------------------------------------*
  LOCAL e  AS LOGICAL := .T.
  LOCAL ts AS STRING  := ""
  LOCAL cs AS STRING  := ""
  LOCAL x  AS NUMERIC

  FOR x := 1 TO Len( Fl )
      IF ValType( Fn[ x ] )== "L"
         IF Fn[ x ]
            cs := Eval( chblk, _DbaNames, Upper( Fl[ x ] ), 2 )
            IF cs # "N"
               Fn[ x ] := .F.
            ENDIF
         ENDIF
      ELSE
         Fn[ x ] := .F.
      ENDIF
      Ts += iif( Fn[ x ], ".T.", ".F." ) + ","
  NEXT

  Ts := "{" + Left( ts, Len( ts ) - 1 ) + "}"

  ReportEditor.Text_5.Value := Ts

RETURN( e )


*-----------------------------------------------------------------------------*
FUNCTION Check_Name()
*-----------------------------------------------------------------------------*
  LOCAL Fl := ""
  LOCAL e  := .T.

  BEGIN SEQUENCE
    Fl := MACROCOMPILE(ReportEditor.Text_3.Value,"Name")
  END SEQUENCE

  IF ValType( Fl ) == "A"
     e := vld_f( ReportEditor.Text_7.Value, Fl, "name" )
  ELSE
     e := .F.
  ENDIF

RETURN( e )


*-----------------------------------------------------------------------------*
PROCEDURE Re_AddL()
*-----------------------------------------------------------------------------*
  LOCAL Fl AS USUAL  := ReportEditor.Text_4.Value  //? Vartype (not used?)
  LOCAL Wa AS STRING := ReportEditor.Text_7.Value

  IF Empty( Wa ) .OR. ! Used()
     MsgStop( "Put a correct Workarea Before This." )
     RETURN
  ELSE
     IF wa # Alias()
        MsgStop( "This workarea isn't correct" )
        RETURN
     ENDIF
  ENDIF

RETURN


*-----------------------------------------------------------------------------*
FUNCTION vld_f( wa AS STRING, af AS ARRAY, ty AS STRING )
*-----------------------------------------------------------------------------*
   LOCAL e  AS LOGICAL := .T.
   LOCAL wh AS NUMERIC := 0

   wa := iif( wa == NIL, ReportEditor.Text_7.Value, wa )
   af := iif( af == NIL, {}, af )
   ty := iif( ty == NIL, "name", ty )

   Populate_list( wa )

   IF ty = "name"
      aEval( af, {| x, y | af[y] := Upper( AllTrim(x))})
      aEval( af, {| x, y | iif( aScan( _DbaNames, x ) < 1,( e := .F., wh := y ), "" ) } )
   ENDIF

   IF ! e
      MsgStop( "Found Error with " + af[ wh ] + ".", "Incorrect Field Name" )
   ENDIF

RETURN( e )


*-----------------------------------------------------------------------------*
FUNCTION Chk_Img()
*-----------------------------------------------------------------------------*
RETURN ! Empty( ReportEditor.Text_14.Value )


*-----------------------------------------------------------------------------*
FUNCTION MacroCompile( cStr AS STRING, lMesg AS LOGICAL )
*-----------------------------------------------------------------------------*
  LOCAL bOld    AS CODEBLOCK
  LOCAL xResult AS USUAL

  IF lMesg == NIL
     RETURN  &(cStr)
  ENDIF

  bOld := ErrorBlock( { || Break( NIL ) } )

  BEGIN SEQUENCE
    xResult := &cStr
  RECOVER
    IF lMesg
       MsgStop("Error in evaluation of:" + CRLF + AllTrim( cStr ) + CRLF + "In " + lMesg, "Error" )
       Errorblock ( bOld )
       BREAK
    ENDIF
    xResult := "**Error**:" + cStr
  END SEQUENCE

  ErrorBlock( bOld )

RETURN( xResult )


*-----------------------------------------------------------------------------*
PROCEDURE Mnu_Act( pnLevel AS NUMERIC )
*-----------------------------------------------------------------------------*
  // Level := iif( pnLevel=NIL, PgmpPos, pnLevel )
  DEFAULT pnLevel TO PgmpPos

  IF pnLevel = 1
     _EnableMenuItem( "SMAIN"    , "ProjectBrowser" )
     _DisableMenuItem( "RRefresh", "ProjectBrowser" )
  ELSEIF pnLevel = 4
     _EnableMenuItem( "RRefresh" , "ProjectBrowser" )
     _DisableMenuItem( "SMAIN"   , "ProjectBrowser" )
  ELSE
     _DisableMenuItem( "SMAIN"   , "ProjectBrowser" )
     _DisableMenuItem( "RRefresh", "ProjectBrowser" )
  ENDIF

RETURN


*-----------------------------------------------------------------------------*
FUNCTION Exe_Cnt( PgmPpos AS NUMERIC, Act AS STRING )
*-----------------------------------------------------------------------------*
  DO CASE
     CASE Act == "ADD"
          DO CASE
             CASE PgmpPos= 1  ; AddModule()
             CASE PgmpPos= 2  ; AddForm()
             CASE PgmpPos= 3  ; AddResource()
             CASE PgmpPos= 4  ; AddReport()
             CASE PgmpPos= 5  ; AddTables()
          ENDCASE

     CASE Act == "NEW"
          DO CASE
             CASE PgmpPos = 1  ; NewModule()
             CASE PgmpPos = 2  ; NewForm()
             CASE PgmpPos = 3  ; NewResource()
             CASE PgmpPos = 4  ; NewReport()
          // CASE PgmpPos = 5  ; NewTable()
          ENDCASE

     CASE Act == "REMOVE"
          // Check if there is an active project ?
          IF Chk_Prj()
             RETURN( NIL )
          ENDIF
          DeleteItem()

     CASE Act == "MAIN"
          IF PgmpPos = 1
             SetModuleAsMain()
          ENDIF

     CASE Act == "REFRESH"
          IF PgmpPos = 4
             RefreshReport()
          ENDIF

     CASE Act == "EDIT"
          EditFile()

  ENDCASE

RETURN( NIL )
