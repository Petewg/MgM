#include "minigui.ch"
#include "TSBrowse.ch"

#define ntrim( n ) hb_ntos( n )
#define C_SYS      GetSysColor( COLOR_INACTIVECAPTION ) // current color system
#define C_TEK      GetSysColor( COLOR_CAPTIONTEXT )     // current color system
#define CLR_SYS    GetSysColor( COLOR_BTNFACE )         // current color system

MEMVAR afont
MEMVAR MEG
MEMVAR zox
MEMVAR zoy
MEMVAR zpp
MEMVAR ztsm_szer
MEMVAR zhotkey
MEMVAR sc_color
MEMVAR st_color

MEMVAR ts_ob1, ts_ob2, ts_ob3, ts_ob4, ts_ob5, ts_ob6, ts_ob7, ts_ob8, ts_ob9 // handles the main menu must be PUBLIC
MEMVAR SYS_COLOR, tatx, ob, zzob

MEMVAR Y, X, TABL, ckno // parameters  menu: row, col, array menu, cform
MEMVAR atab, tss_wyb, mob
MEMVAR tss_zwie, zkol, ax, ctitle

STATIC tss_nmenu := 1, ts_zx_poz := 0, tss_zx_poz := 0, ts_nkla := 0, tss_nkla := 0, ts_dpl := 1, tss_dpl := 1, atsm_count := 0, ts_okno
STATIC ts_y := 0, ts_x := 0, ts_color1, ts_color2, ts_color3, runonce := .F.

// ------------------------------------------------------------------------------------------------
PROCEDURE TsMenu
// ------------------------------------------------------------------------------------------------

   LOCAL i, iv, v, cwybor := '', tab_m := {}, o
   PRIVATE zpp := 1
   PRIVATE ztsm_szer := 1
   PRIVATE zhotkey := ''
   PRIVATE sc_color := { GetRed( C_SYS ), GetGreen( C_SYS ), GetBlue( C_SYS ) }
   PRIVATE st_color := { GetRed( C_TEK ), GetGreen( C_TEK ), GetBlue( C_TEK ) }

   PUBLIC ts_ob1, ts_ob2, ts_ob3, ts_ob4, ts_ob5, ts_ob6, ts_ob7, ts_ob8, ts_ob9 // handles the main menu must be PUBLIC
   PUBLIC SYS_COLOR := { GetRed( CLR_SYS ), GetGreen( CLR_SYS ), GetBlue( CLR_SYS ) }

   PARAMETERS Y, X, TABL, ckno // parameters  menu: row, col, array menu, cform
   ts_color1 := st_color
   ts_color2 := { 0, 0, 0 }
   ts_color3 := sc_color
   ts_y := y
   ts_x := x

   ts_okno := ckno
   atsm_count := Len( tabl )  // counter arrays

   DECLARE tatx[ atsm_count ] // columns position, menu arrays

   FOR o := 1 TO atsm_count                                 // counter arrays
      tatx[ o ] := if( o > 1, ( 10 + ( Len( StrTran( tabl[ o - 1, 1 ], '&', '' ) ) * 10 ) + tatx[ o - 1 ] ), 10 + x )    // assignment the position arrays
      zpp := At( '&', TABL[ o, 1 ] )                                // looking for a hot key
      IF zpp > 0
         zhotkey += Upper( SubStr( TABL[ o, 1 ], zpp + 1, 1 ) )     // assignment hot keys
         cwybor += '`Alt+' + Lower( SubStr( TABL[ o, 1 ], zpp + 1, 1 ) ) + '`-' + Lower( StrTran( tabl[ o, 1 ], '&', '' ) ) + ' ' // description of the hot keys, to remove
      ENDIF
      v := 'L' + LTrim( Str( o ) )   // menu label handle
      ob := 'ts_ob' + ntrim( o )     // menu array handle
      iv := ntrim( o )
      zzob := 'f_ts_lr(' + iv + ',.t.)' // parameters  of the procedure, called by the label

      @ y, tatx[ o ] LABEL &v OF &ts_okno WIDTH ( ( Len( StrTran( TABL[ o, 1 ], '&', '' ) ) * 10 ) ) HEIGHT 20 VALUE TABL[ o, 1 ] ; // labels horizontal menu
      FONT "MS Sans Serif" SIZE 10 BOLD BACKCOLOR GRAY FONTCOLOR WHITE CENTERALIGN ACTION &zzob

      SetProperty( ts_okno, v, 'backcolor', SYS_COLOR ) // horizontal menu, background color
      SetProperty( ts_okno, V, 'Fontcolor', BLACK )     // horizontal menu, fonts
      tab_m := {}             // temporary array
      FOR i := 1 TO Len( tabl[ o, 2 ] )
         IF Left( tabl[ o, 2, i, 1 ], 1 ) = '_'         // looking for separator
            tabl[ o, 2, i, 1 ] := StrTran( PadC( Trim( tabl[ o, 2, i, 1 ] ), 50, Chr( 151 ) ), '_', Chr( 151 ) ) // replace the underscore separator
            AAdd( tab_m, { '', PadC( '', 50, Chr( 151 ) ), '' } )
         ELSE
            zpp := At( '&', TABL[ o, 2, i, 1 ] )        // looking for a hot key
            IF zpp > 0
               AAdd( tab_m, { SubStr( TABL[ o, 2, i, 1 ], zpp + 1, 1 ), AllTrim( SubStr( TABL[ o, 2, i, 1 ], zpp + 2 ) ), if( ValType( tabl[ o, 2, i, 2 ] ) = 'A', Chr( 238 ), ' ' ) } ) // adding an arrow when submenu
            ELSE
               AAdd( tab_m, { '', AllTrim( SubStr( TABL[ o, 2, i, 1 ], zpp + 2 ) ), if( ValType( tabl[ o, 2, i, 2 ] ) = 'A', Chr( 238 ), '\' ) } )
            ENDIF
            ztsm_szer := Max( ztsm_szer, Len( tab_m[ i, 2 ] ) + if( ValType( tabl[ o, 2, i, 2 ] ) = 'A', 5, 2 ) )
         ENDIF
      NEXT

      IF !_IsControlDefined ( ob, ts_okno ) // vertical menu

         DEFINE TBROWSE &( ob ) AT y + 20, tatx[ o ] OF &ts_okno WIDTH ( ztsm_szer * 10 ) + 21 HEIGHT ( Len( TAB_m ) * 25 ) + 1 FONT "Arial" SIZE 12 BOLD VALUE 1 ON CHANGE f_ts_change() ;
            ON DBLCLICK f_tsrun()

         &ob:SetArray( tab_m,, .F. )

         ADD COLUMN TO TBROWSE &ob DATA ARRAY ELEMENT 1 ALIGN DT_CENTER, DT_CENTER SIZE 20 COLORS C_TEK, C_SYS
         ADD COLUMN TO TBROWSE &ob DATA ARRAY ELEMENT 2 ALIGN DT_LEFT, DT_CENTER SIZE ( ( ztsm_szer * 10 ) -20 )
         ADD COLUMN TO TBROWSE &ob DATA ARRAY ELEMENT 3 ALIGN DT_LEFT, DT_CENTER SIZE ( 20 )

         &ob:lDrawHeaders := .F.
         &ob:nHeightCell := 25
         &ob:nLineStyle := 0
         &ob:nWheelLines := 1
         &ob:lNoHScroll := .T.
         &ob:lNoVScroll := .T.
         &ob:ChangeFont( afont[ 8 ], 1, 1 )
         &ob:bUserKeys := {| ts_nkey, nFlags| f_ts_key( ts_nkey, nflags ) } // use a key
         &ob:ChangeFont( afont[ 11 ], 3, 1 )

         END TBROWSE
         &ob:hide()
      ENDIF
      ztsm_szer := 1
   NEXT

   ts_ob1:show()
   ts_ob1:reset()
   ts_ob1:setfocus()
   ts_ob1:DrawSelect()
   SetProperty( ts_okno, 'L1', 'BackColor', ts_color3 ) // first LABEL horizontal menu
   SetProperty( ts_okno, 'L1', 'FontColor', ts_color1 )

   FOR i := 1 TO Len( zhotkey ) // horizontal menu, declare the hot keys
      v := ntrim( i )
      zzob := '{|| f_ts_lr(' + v + ',.t.) }'
      _DefineHotKey ( ts_okno, 1, Asc( SubStr( zhotkey, i, 1 ) ), &zzob  ) // hot key of labels
   NEXT
   SetProperty( ts_okno, 'ts_ob1', 'show' ) // show first vertical menu

   // ON KEY RETURN OF &ts_okno ACTION f_tsrun()        // selected items - letter - enter - DBLCLICK
   ON KEY ESCAPE OF &ts_okno ACTION DoMethod ( ts_okno, "release" ) // exit
   DoMethod ( ts_okno, "restore" )
   SetProperty( ts_okno, 'ts_ob1', 'show' )

RETURN
// ------------------------------------------------------------------------------------------------------------
STATIC PROCEDURE f_tsrun() // selected items

   LOCAL zob := 'ts_ob' + Str( ts_dpl, 1 )
   LOCAL tx := MEG[ ts_dpl, 2, &zob:nat, 2 ]
   LOCAL zKol, oCol, nRow
   IF ValType( tx ) = 'B'
      Eval( tx )     // procedure to perform
   ELSE
      IF ValType( tx ) = 'A'
         zKol   := GetProperty( ts_okno, zob, 'col' )
         oCol  := &zob:aColumns[ &zob:nCell ]
         nRow  := &zob:nRowPos -1
         nRow  := ( nRow * &zob:nHeightCell ) + &zob:nHeightHead + &zob:nHeightSuper + &zob:nHeightSpecHd + If( oCol:l3DLook, 2, 0 )

         fmenu( ts_y + nRow + 45, ts_x + zKol + 30, TX ) // show submenu
      ELSE
         msginfo( 'Selected ' + Str( tx ), 'Info.' ) // info if number, main menu
      ENDIF
   ENDIF

RETURN
// ------------------------------------------------------------------------------------------------------------
STATIC PROCEDURE f_ts_key( ts_nkey, nflags ) // pressed a key, main menu

   LOCAL zob := 'ts_ob' + Str( ts_dpl, 1 )     // assignment  handle array
   LOCAL tx := MEG[ ts_dpl, 2, &zob:nat, 1 ]   // load array elements
   LOCAL nl := Len( MEG[ ts_dpl, 2 ] ), ax, zp

   IF ts_nkey = 40 .AND. ts_zx_poz = nl  // if the cursor down and the pointer to the end
      ts_zx_poz := -1        // pointer to the beginning position of the negative
      &zob:gotop()
      &zob:UpAStable()
      ts_nkey := 38
      ts_nkla := 38
      ts_zx_poz := -1
      RETURN
   ELSEIF ts_nkey = 38 .AND. ts_zx_poz = 1 // if the cursor up and the pointer to the beginning
      &zob:nat := nl
      &zob:UpAStable()
      ts_zx_poz := -nl       // pointer position at the end of the negative
      ts_nkey := 40
      ts_nkla := 40
      RETURN
   ELSE
      ts_nkla := ts_nkey
   ENDIF
   IF ts_nkey = 37     // if the cursor to the left
      ts_zx_poz := 0    // pointer to zero position
      f_ts_lr( -1, .F. )    // transfer to another menu to the left
      RETURN
   ELSEIF ts_nkey = 39   // if the cursor to the right
      ts_zx_poz := 0    // pointer to zero position
      f_ts_lr( 1, .F. )     // transfer to another menu to the right
      RETURN
   ENDIF

   IF ts_nkey > 47 // if asci
      ax := MEG[ ts_dpl, 2 ]
      zp := AScan( ax, {| x| Left( LTrim( StrTran( x[ 1 ],'&', '' ) ), 1 ) = Chr( ts_nkey ) } ) // find a hot character
      IF zp > 0       // includes a hot character
         &zob:nat := zp
         &zob:UpAStable()
         f_tsrun()      // selected items
      ENDIF
   ENDIF
   IF ( ts_nkey = 40 ) .AND. Left( tx, 1 ) == Chr( 151 ) // cursor down and separator
      &zob:godown()
      SetProperty( ts_okno, zob, 'Refresh' )
   ENDIF

RETURN
// ------------------------------------------------------------------------------------------------------------
STATIC PROCEDURE f_ts_change    // If the pointer change

   LOCAL nl := 0
   LOCAL zob := 'ts_ob' + Str( ts_dpl, 1 )   // assignment  handle array
   LOCAL tx := MEG[ ts_dpl, 2, &zob:nat, 1 ] // load array elements

   IF ts_zx_poz < 0          // if the position of negative
      ts_nkla := 0           // reset subcode
      &zob:nat := Abs( ts_zx_poz )    // new position
      &zob:UpAStable()        // show cursor menu
      ts_zx_poz := Abs( ts_zx_poz )   // save old position
      RETURN
   ENDIF

   ts_zx_poz := &zob:nat   // read new position

   IF ( ts_nkla = 40 )       // if cursor down
      IF Left( tx, 1 ) == Chr( 151 )  // if separator
         &zob:godown()    // cursor down
         ts_nkla := 0      // reset subcode
      ENDIF
   ELSEIF ( ts_nkla = 38 )     // if cursor up
      IF Left( tx, 1 ) == Chr( 151 )  // if separator
         &zob:goup()      // cursor up
         ts_nkla := 0      // reset subcode
      ENDIF
   ELSE          // if mouse
      IF Left( tx, 1 ) == Chr( 151 )  // if separator
         &zob:goup()      // cursor up
         ts_nkla := 0      // reset subcode
      ENDIF
   ENDIF

RETURN
// ------------------------------------------------------------------------------------------------------------
PROCEDURE f_ts_lr( zco, jak )     // transfer to other menu, right or left

   LOCAL lob := 'L' + Str( ts_dpl, 1 )    // label holder
   LOCAL zob := 'ts_ob' + Str( ts_dpl, 1 )   // array holder

   SetProperty( ts_okno, lob, 'Fontcolor', BLACK )     // label color standard
   SetProperty( ts_okno, lob, 'Backcolor', SYS_COLOR ) // label color standard

   SetProperty( ts_okno, zob, 'Enabled', .F. ) // access denied to the array
   &zob:hide()             // hide the current array
   IF jak = .F.            // if .F. change the number array
      ts_dpl += zco        // change number array
   ELSE
      ts_dpl := zco        // set the indicated array
   ENDIF
   IF ts_dpl > atsm_count  // If the index exceeds the amount of tables set the first
      ts_dpl := 1
   ELSEIF ts_dpl < 1       // If the index smaller than the one set last
      ts_dpl := atsm_count
   ENDIF
   zob := 'ts_ob' + Str( ts_dpl, 1 )        // handle new array
   lob := 'L' + Str( ts_dpl, 1 )            // handle new label
   SetProperty( ts_okno, lob, 'Backcolor', ts_color3 )  // color label selected
   SetProperty( ts_okno, lob, 'Fontcolor', ts_color1 )  // color label selected

   SetProperty( ts_okno, zob, 'Enabled', .T. )  // access restored
   zpp := &zob:nat          // store old array pointer

   &zob:show()              // show new array
   &zob:Refresh()           //
   &zob:Reset()             //

   DoMethod( ts_okno, zob, 'Refresh' )
   DoMethod( ts_okno, zob, "SetFocus" )

   &zob:nat := zpp           // restoration of the old array pointer settings
   &zob:UpAStable()          //
   ts_zx_poz := &zob:nat     // recording a pointer array

RETURN
// ---------------------------------------------------------------
FUNCTION fmenu()  // submenu or menu from key

   LOCAL zsze := 1, zcenter := .F., o_pm, ncap := 0, nszy := 0, i
   PRIVATE atab := {}, tss_wyb := 0, mob

   PARAMETERS tss_zwie, zkol, ax, ctitle  // parameters  submenu: [row], [col], array submenu, [ctitle]
   runonce := .F.
   tss_nmenu += 1

   mob := 'obm' + Str( tss_nmenu, 1 )
   o_pm := 'okm' + Str( tss_nmenu, 1 )
   FOR i := 1 TO Len( ax )
      IF Left( ax[ i, 1 ], 1 ) = '_'
         AAdd( atab, { '', PadC( '', 50, Chr( 151 ) ), '' } )
      ELSE
         zpp := At( '&', ax[ i, 1 ] )
         IF zpp > 0
            AAdd( atab, { SubStr( ax[ i, 1 ], zpp + 1, 1 ), AllTrim( SubStr( ax[ i, 1 ], zpp + 2 ) ), if( ValType( ax[ i, 2 ] ) = 'A', Chr( 238 ), ' ' ) } )
         ELSE
            AAdd( atab, { '', AllTrim( ax[ i, 1 ] ), if( ValType( ax[ i, 2 ] ) = 'A', Chr( 238 ), ' ' ) } )
         ENDIF
         zsze := Max( zsze, Len( atab[ i, 2 ] ) + if( ValType( ax[ i, 2 ] ) = 'A', 5, 2 ) )
      ENDIF
   NEXT
   IF Empty( zkol )
      zkol := ( ( zox / 2 ) - ( ( ( zsze * 10 ) + 5 ) ) / 2 )
   ENDIF
   IF Empty( tss_zwie )
      tss_zwie := ( ( zoy / 2 ) -( ( Len( ax ) / 2 ) * 20 ) )
   ENDIF
   IF ( zkol + ( ( zsze * 10 ) + 15 ) > zox )
      zkol := zox - ( ( zsze * 10 ) + 25 )
   ENDIF
   IF Empty( ctitle )
      ctitle := ''
   ELSE
      zsze := Max( zsze, Len( ctitle ) )
      ncap := 1
      nszy := 30
   ENDIF
   _DefineModalWindow ( o_pm, ctitle, zkol, tss_zwie, ( zsze * 10 ) + 25, ( Len( ax ) * 25 ) + 5 + nszy + ncap + iif( isseven(), GetBorderHeight(), 0 ), "", .F., .F., .T., {, }, {, },, , , , ,, , , "MAIN", "ARIAL", 12,, , , , , , , , , , .F., , .F., .F., , , )

   IF Len( ctitle ) > 0
      _DefineLabel ( "L1",, 2, 2, ctitle, ( zsze * 10 ) -4 + 20, 25, "Arial", 12, .T., .F., .F., .F., .F., .F.,ts_color3, ts_color1,,,, .F., .F., .F., .F., .F., .F., .T., .F.,,, )
   ENDIF

   &mob := _DefineTBrowse ( mob, "o_pm", 0, nszy, ( zsze * 10 ) + 45, ( Len( ax ) * 25 ) + 1, , ,, 1, "Arial", 12,, {|| f_tss_change() }, {| nRow, nCol, nFlags| f_tss_run() },,,,,,,,, , .T.,,,, ,,,,,,,,,,,,,,, .F.,,,,,,,,,,, )
   WITH OBJECT &mob

      &mob:SetArray( atab,, .F. )

      &mob:AddColumn( TSColumn():New(, {| x| If( PCount() > 0, &mob:aArray[ &mob:nAt, 1 ] := x, &mob:aArray[ &mob:nAt, 1 ] ) },, { GetSysColor( 9 ), GetSysColor( 3 ) }, { 1, 1 }, 20,,,,, Nil,,,,,,,, &mob,,,,,,,, ) )
      &mob:AddColumn( TSColumn():New(, {| x| If( PCount() > 0, &mob:aArray[ &mob:nAt, 2 ] := x, &mob:aArray[ &mob:nAt, 2 ] ) },,, { 0, 1 }, ( ( zsze * 10 ) -20 ),,,,, Nil,,,,,,,, &mob,,,,,,,, ) )
      ADD COLUMN TO TBROWSE &mob DATA ARRAY ELEMENT 3 ALIGN DT_LEFT, DT_CENTER SIZE ( 20 )

      &mob:lDrawHeaders := .F.
      &mob:nHeightCell := 25
      &mob:nLineStyle := 6
      &mob:nWheelLines := 1
      &mob:lNoHScroll := .T.
      &mob:lNoVScroll := .T.
      &mob:ChangeFont( afont[ 8 ], 1, 1 )

      &mob:bUserKeys := {| ts_nkey, nFlags| f_ts_key_pod( ts_nkey, nflags ) }
      &mob:ChangeFont( afont[ 11 ], 3, 1 )
      &mob:reset()
      &mob:setfocus()
      &mob:DrawSelect()

      _EndTBrowse ()

   END OBJECT
   _DefineHotKey ( , 0, 27, {|| f_tss_close( o_pm ) } )
   _EndWindow ()

   _ActivateWindow ( { o_pm }, .F. )
   tss_nmenu -= 1

RETURN ( tss_wyb )
// --------------------------------------------------------------------------------------
PROCEDURE f_tss_close()

   LOCAL o_pm := 'okm' + Str( tss_nmenu, 1 )

   RELEASE WINDOW &o_pm

RETURN
// --------------------------------------------------------------------------------------
STATIC PROCEDURE f_ts_key_pod( ts_nkey, nflags )

   LOCAL zpp, zkol, nrow, ocol, ncrow, nl
   LOCAL mob  := 'obm' + Str( tss_nmenu, 1 )
   LOCAL o_pm  := 'okm' + Str( tss_nmenu, 1 )
   LOCAL zsze  := getProperty( o_pm, mob, 'width' )

   tss_nkla := ts_nkey

   IF ts_nkey = 13      // call procedure, key ENTER
      zpp := &mob:nat
      IF ValType( ax[ zpp, 2 ] ) = 'B'
         IF runonce
            runonce := .F.
            RETURN
         ENDIF
         runonce := .T.
         Eval( ax[ zpp, 2 ] )
      ELSEIF ValType( ax[ zpp, 2 ] ) = 'A'
         zkol   := getProperty( o_pm, 'col' )
         nrow  := getProperty( o_pm, 'row' )
         oCol  := &mob:aColumns[ &mob:nCell ]
         ncRow := &mob:nRowPos -1
         ncRow := ( ncRow * &mob:nHeightCell ) + &mob:nHeightHead + &mob:nHeightSuper + &mob:nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
         nrow  += ncrow

         fmenu( nrow + 25, zkol + 25, ax[ zpp, 2 ] ) // parameters  submenu: row, col, array submenu
      ELSE
         tss_wyb := ax[ zpp, 2 ]
         f_tss_close()
         RETURN
      ENDIF
   ENDIF
   nl := Len( ax )
   IF ts_nkey = 40 .AND. tss_zx_poz = nl
      tss_zx_poz := -1
      &mob:gotop()
      &mob:UpAStable()
      ts_nkey := 38
      tss_nkla := 38
      tss_zx_poz := -1
      RETURN
   ELSEIF ts_nkey = 38 .AND. tss_zx_poz = 1
      &mob:nat := nl
      &mob:UpAStable()
      tss_zx_poz := -nl
      ts_nkey := 40
      tss_nkla := 40
      RETURN
   ELSE
      tss_nkla := ts_nkey
   ENDIF
   IF ts_nkey > 47
      zpp := AScan( ax, {| x| Left( LTrim( StrTran( x[ 1 ],'&', '' ) ), 1 ) = Chr( ts_nkey ) } )
      IF zpp > 0
         &mob:nat := zpp
         &mob:UpAStable()
         IF ValType( ax[ zpp, 2 ] ) = 'B'
            Eval( ax[ zpp, 2 ] )
         ELSEIF ValType( ax[ zpp, 2 ] ) = 'A'
            zkol   := getProperty( o_pm, 'col' )
            nrow  := getProperty( o_pm, 'row' )
            oCol  := &mob:aColumns[ &mob:nCell ]
            ncRow := &mob:nRowPos -1
            ncRow := ( ncRow * &mob:nHeightCell ) + &mob:nHeightHead + &mob:nHeightSuper + &mob:nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
            nrow  += ncrow

            fmenu( nrow + 25, zkol + 25, ax[ zpp, 2 ] )
         ELSE
            tss_wyb := ax[ zpp, 2 ]
            f_tss_close()
            RETURN
         ENDIF
      ENDIF
   ENDIF

RETURN
// ------------------------------------------------------------------------------------------------------------
STATIC PROCEDURE f_tss_run()

   LOCAL zkol, nrow, ocol, ncrow
   LOCAL zob := 'obm' + Str( tss_nmenu, 1 )
   LOCAL o_pm := 'okm' + Str( tss_nmenu, 1 )
   LOCAL zsze := getProperty( o_pm, zob, 'width' )
   LOCAL zpp := &zob:nat

   IF ValType( ax[ zpp, 2 ] ) = 'B'
      IF runonce
         runonce := .F.
         RETURN
      ENDIF
      runonce := .T.
      Eval( ax[ zpp, 2 ] )
   ELSE
      IF ValType( ax[ zpp, 2 ] ) = 'A'
         zkol   := getProperty( o_pm, 'col' )
         nrow  := getProperty( o_pm, 'row' )
         oCol  := &zob:aColumns[ &zob:nCell ]
         ncRow := &zob:nRowPos -1
         ncRow := ( ncRow * &zob:nHeightCell ) + &zob:nHeightHead + &zob:nHeightSuper + &zob:nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
         nrow  += ncrow

         fmenu( nrow + 25, zkol + 25, ax[ zpp, 2 ] )
      ELSE
         tss_wyb := ax[ zpp, 2 ]
         f_tss_close()
         RETURN
      ENDIF
   ENDIF

RETURN
// --------------------------------------------------------------------------------------
PROCEDURE f_tss_change()

   LOCAL nl := 0
   LOCAL mob := 'obm' + Str( tss_nmenu, 1 )
   IF tss_zx_poz < 0
      tss_nkla := 0
      &mob:nat := Abs( tss_zx_poz )
      &mob:UpAStable()
      tss_zx_poz := Abs( tss_zx_poz )
      RETURN
   ENDIF
   IF ( tss_nkla = 40 )
      IF Left( &mob:aArray[ &mob:nAt, 2 ], 1 ) = Chr( 151 )
         &mob:godown()
      ENDIF
   ELSEIF ( tss_nkla = 38 )
      IF Left( &mob:aArray[ &mob:nAt, 2 ], 1 ) = Chr( 151 )
         &mob:goup()
      ENDIF
   ELSEIF Left( &mob:aArray[ &mob:nAt, 2 ], 1 ) = Chr( 151 )
      &mob:goup()
   ENDIF
   tss_zx_poz := &mob:nat

RETURN
