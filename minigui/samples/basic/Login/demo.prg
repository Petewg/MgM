/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

static logindata := {}, rank

function main

SET NAVIGATION EXTENDED

aadd(logindata, {"ADMIN","ADMIN",99,1})
aadd(logindata, {"USERNAME","PASSWORD",5,50})
aadd(logindata, {"GUEST","GUEST",3,100})

Define window sample At 0,0 width 600 height 400 main title "Want to login?" on init loginattempt(2)
   Define Main Menu
      Popup "&Login"
         item "Login as &Admin" action loginattempt(1)
         item "Login as &User" action loginattempt(2)
         item "Login as &Guest" action loginattempt(3)
         separator
         item "E&xit" action sample.release
      End Popup
      Popup "&Test"
         item "Check &Permissions" action CheckPermissions()
         item "Show &User List" action ShowUserList() name UserList
      End Popup
   End Menu
End window

sample.center
sample.activate

return nil


FUNCTION loginattempt(level)
local username := logindata[level][1]
local password := logindata[level][2]
local maxattempt := logindata[level][3]
local ok, attempts := 0

   rank := logindata[level][4]

   SET INTERACTIVECLOSE OFF

   DEFINE window login At 0,0 width 220 height 155 title "User Login" modal
      DEFINE label usernamelabel
         Row 10
         Col 10
         width 80
         Value "Username"
      END label
      DEFINE textbox username
         Row 10
         Col 90
         width 100
         value ""
         uppercase .t.
      END textbox
      DEFINE label passwordlabel
         Row 40
         Col 10
         width 80
         Value "Password"
      END label
      DEFINE textbox password
         Row 40
         Col 90
         width 100
         password .t.
         value ""
         uppercase .t.
      END textbox
      DEFINE button login
         Row 80
         Col 45
         width 50
         caption "Login"
         action ( attempts++, ok := (login.username.value == username .and. login.password.value == password),;
                  iif(ok, Loginok(username), iif(attempts < maxattempt, (MsgStop("Not Authorized!"), login.username.setfocus), logincancelled(.t.))) ) 
      END button
      DEFINE button cancel
         Row 80
         Col 115
         width 50
         caption "Cancel"
         action logincancelled(.f.)
      END button
   END window

   login.center
   login.activate

RETURN nil


static function loginok(user)

MsgInfo("Login Successful")

sample.title := "User: " + user

login.release()

SET INTERACTIVECLOSE QUERY MAIN

sample.userlist.enabled := (rank < 99)

return nil


static function logincancelled(immediate)

If immediate
   RELEASE WINDOW ALL
Endif

If MsgYesNo("Are you sure to cancel?", "Confirmation")
   Msginfo("GoodBye!")

   RELEASE WINDOW ALL
Endif

return nil


function CheckPermissions()
local permission

do case
   case rank < 10
        permission := "ALL"
   case rank < 100
        permission := "read/write"
   case rank > 99
        permission := "readonly"
end case

MsgInfo("You have " + permission + " permissions.")

return nil


function ShowUserList()
local i, count := len(logindata), list := {}

   for i=1 to count
      if rank > 9 .and. logindata[i][4] < 10
         loop
      endif
      aadd(list, logindata[i])
   next

   DEFINE window list At 0,0 width 400-if(isvista().or.isseven(),0,8) height 300-if(isvista().or.isseven(),0,10) ;
      title "User List" modal on release if(rank < 10,savelist(),nil)
      DEFINE grid userlist
         Row		0
         Col		0
         width		384
         height		262
         headers	{'User','Password','Max attempt','Rank'} 
         widths		{110,110,90,50} 
         items		list
         value		1
         inplaceedit	{ ;
			{'TEXTBOX','CHARACTER' } , ;
			{'TEXTBOX','CHARACTER' } , ;
			{'TEXTBOX','NUMERIC', '99' } , ;
			{'TEXTBOX','NUMERIC', '999' } , ;
                        }
         justify	{ GRID_JTFY_LEFT,;
			GRID_JTFY_LEFT,;
			GRID_JTFY_RIGHT,;
			GRID_JTFY_RIGHT }
         allowedit	(rank < 10)
         cellnavigation	(rank < 10)
      END grid
   END window

   list.center
   list.activate

return nil


static function savelist()
local i, count := list.userlist.itemcount

logindata := {}
for i=1 to count
   aadd(logindata, {list.userlist.cell(i,1),list.userlist.cell(i,2),list.userlist.cell(i,3),list.userlist.cell(i,4)})
next

return nil
