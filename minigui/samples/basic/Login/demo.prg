/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

STATIC logindata := {}, rank

// -------------------------------------------------------------------------- //

FUNCTION main

   SET NAVIGATION EXTENDED

   AAdd( logindata, { "ADMIN", "ADMIN", 99, 1 } )
   AAdd( logindata, { "USERNAME", "PASSWORD", 5, 50 } )
   AAdd( logindata, { "GUEST", "GUEST", 3, 100 } )

   Define window sample ;
     At 0, 0 width 600 height 400 ;
     main ;
     title "Want to login?" ;
     ON INIT loginattempt( 2 )

     Define Main MENU

       Popup "&Login"
         item "Login as &Admin" action loginattempt( 1 )
         item "Login as &User" action loginattempt( 2 )
         item "Login as &Guest" action loginattempt( 3 )
         separator
         item "E&xit" action sample.release
       END Popup

       Popup "&Test"
         item "Check &Permissions" action CheckPermissions()
         item "Show &User List" action ShowUserList() name UserList
       END Popup

     End Menu

   End window

   sample.center
   sample.activate

RETURN NIL

// -------------------------------------------------------------------------- //

FUNCTION loginattempt( level )

   LOCAL username := logindata[ level ][ 1 ]
   LOCAL password := logindata[ level ][ 2 ]
   LOCAL maxattempt := logindata[ level ][ 3 ]
   LOCAL ok, attempts := 0

   rank := logindata[ level ][ 4 ]

   SET INTERACTIVECLOSE OFF

   DEFINE window login At 0, 0 width 220 height 155 title "User Login" modal

   DEFINE LABEL usernamelabel
      Row 10
      Col 10
      width 80
      Value "Username"
   END label
   DEFINE textbox username
      Row 10
      Col 90
      width 100
      value username
      uppercase .T.
   END textbox
   DEFINE LABEL passwordlabel
      Row 40
      Col 10
      width 80
      Value "Password"
   END label
   DEFINE textbox password
      Row 40
      Col 90
      width 100
      password .T.
      value ""
      uppercase .T.
   END textbox
   DEFINE button login
      Row 80
      Col 45
      width 50
      caption "Login"
      action ( attempts++, ok := ( login.username.value == username .AND. login.password.value == password ), ;
         iif( ok, Loginok( username ), iif( attempts < maxattempt, ( MsgStop( "Not Authorized!" ), login.username.setfocus ), logincancelled( .T. ) ) ) )
   END button
   DEFINE button cancel
      Row 80
      Col 115
      width 50
      caption "Cancel"
      action logincancelled( .F. )
   END button

   END window

   login.center
   login.activate

RETURN NIL

// -------------------------------------------------------------------------- //

STATIC FUNCTION loginok( user )

   MsgInfo( "Login Successful" )

   sample.title := "User: " + user

   login.release()

   SET INTERACTIVECLOSE QUERY MAIN

   sample.userlist.enabled := ( rank < 99 )

RETURN NIL

// -------------------------------------------------------------------------- //

STATIC FUNCTION logincancelled( immediate )

   IF immediate
      RELEASE WINDOW ALL
   ENDIF

   IF MsgYesNo( "Are you sure to cancel?", "Confirmation" )
      Msginfo( "GoodBye!" )

      RELEASE WINDOW ALL
   ENDIF

RETURN NIL

// -------------------------------------------------------------------------- //

FUNCTION CheckPermissions()

   LOCAL permission

   DO CASE
   CASE rank < 10
      permission := "ALL"
   CASE rank < 100
      permission := "READ/WRITE"
   CASE rank > 99
      permission := "READ ONLY"
   END CASE

   MsgInfo( "You have " + permission + " permissions." )

RETURN NIL

// -------------------------------------------------------------------------- //

FUNCTION ShowUserList()

   LOCAL i, count := Len( logindata ), list := {}

   FOR i = 1 TO count
      IF rank > 9 .AND. logindata[ i ][ 4 ] < 10
         LOOP
      ENDIF
      AAdd( list, logindata[ i ] )
   NEXT

   DEFINE window LIST ;
      At 0, 0 width 400 - if( isvista() .OR. isseven(), 0, 8 ) height 300 - if( isvista() .OR. isseven(), 0, 10 ) ;
      title "User List" ;
      modal ;
      ON RELEASE if( rank < 10, savelist(), nil )

   DEFINE grid userlist
      Row     0
      Col     0
      width   384
      height  262
      headers { 'User', 'Password', 'Max attempt', 'Rank' }
      widths  { 110, 110, 90, 50 }
      items   list
      value   1
      inplaceedit { ;
              { 'TEXTBOX', 'CHARACTER' }, ;
              { 'TEXTBOX', 'CHARACTER' }, ;
              { 'TEXTBOX', 'NUMERIC', '99' }, ;
              { 'TEXTBOX', 'NUMERIC', '999' }, ;
                  }
      justify { GRID_JTFY_LEFT, ;
              GRID_JTFY_LEFT, ;
              GRID_JTFY_RIGHT, ;
              GRID_JTFY_RIGHT }
      allowedit ( rank < 10 )
      cellnavigation ( rank < 10 )
   END grid

   END window

   LIST.center
   LIST.activate

RETURN NIL

// -------------------------------------------------------------------------- //

STATIC FUNCTION savelist()

   LOCAL i, count := LIST.userlist.itemcount

   logindata := {}
   FOR i = 1 TO count
      AAdd( logindata, { LIST.userlist.cell( i, 1 ), LIST.userlist.cell( i, 2 ), LIST.userlist.cell( i, 3 ), LIST.userlist.cell( i, 4 ) } )
   NEXT

RETURN NIL
