/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"

Function Main

define window tabsample at 0,0 width 400 height 300 title 'Add control test' main

   define tab tab1 at 10,10 width 370 height 200

      define page 'Page1'

         define button b1
            row 30
            col 10
            caption 'Press here to add a control'
            width 180
            action addnewcontrols({'lbl1','text1'})
         end button   

      end page

      define page 'Page2'
      
         define button b2
            row 30
            col 10
            caption 'Press here to add a control'
            width 180
            action addnewcontrol2('btn1')
         end button   

      end page

   end tab

   on key escape action thiswindow.release()

end window

tabsample.center
tabsample.activate

Return nil


function addnewcontrols(actrl)
local c1, c2

c1 := actrl[1]
c2 := actrl[2]

if iscontroldefined(&c1,tabsample)
   tabsample.&(c1).release
endif

define label &c1
   parent tabsample
   row 50
   col 10
   width 40
   value 'label'
end label

if iscontroldefined(&c2,tabsample)
   tabsample.&(c2).release
endif

define textbox &c2
   parent tabsample
   row 50
   col 50
   width 100
end textbox

tabsample.tab1.addcontrol(c1,1,84,10)
tabsample.tab1.addcontrol(c2,1,80,50)

return nil


function addnewcontrol2(ctrl)

if iscontroldefined(&ctrl,tabsample)
   tabsample.&(ctrl).release
endif

define buttonex &ctrl
   parent tabsample
   row 10
   col 10
   width 180
   caption 'Click me'
   action MsgBox('Button action','Result')
end buttonex

tabsample.tab1.addcontrol(ctrl,2,80,10)

return nil
