#include "minigui.ch"

Procedure main()
Local aColor

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE 'TreeView Sample' ;
      MAIN

      DEFINE MAIN MENU
         POPUP '&File'
            ITEM 'Get Tree Value' ACTION MsgInfo( Str ( Form_1.Tree_1.Value ) )
            ITEM 'Set Tree Value' ACTION Form_1.Tree_1.Value := val(inputbox('',''))
            ITEM 'Collapse Item' ACTION Form_1.Tree_1.Collapse ( val(inputbox('','','1') ) )
            ITEM 'Expand Item' ACTION Form_1.Tree_1.Expand ( val(inputbox('','','1') ) )
         END POPUP
                POPUP 'Freeze'
                       ITEM 'Freeze update' ACTION Form_1.Tree_1.DisableUpdate
                       ITEM 'Unfreeze update' ACTION Form_1.Tree_1.EnableUpdate
                End POPUP
             POPUP 'Colors'
             ITEM 'Set FontColor to RED' ACTION Form_1.Tree_1.Fontcolor:=RED
             ITEM 'Set FontColor to BLACK' ACTION Form_1.Tree_1.Fontcolor:=BLACK
             ITEM 'Get FontColor ' ACTION {|| ( aColor:= Form_1.Tree_1.FontColor, MsgBox("R:"+chr(9)+str(aColor[1])+CRLF+"G:"+chr(9)+str(aColor[2])+CRLF+"B:"+chr(9)+str(aColor[3])+CRLF,"FontColor" ))}

             SEPARATOR
             ITEM 'Set BackColor to WHITE ' ACTION Form_1.Tree_1.Backcolor := WHITE
             ITEM 'Set BackColor to YELLOW' ACTION Form_1.Tree_1.Backcolor  := YELLOW
             ITEM 'Get BackColor ' ACTION {|| ( aColor:= Form_1.Tree_1.BackColor, MsgBox("R:"+chr(9)+str(aColor[1])+CRLF+"G:"+chr(9)+str(aColor[2])+CRLF+"B:"+chr(9)+str(aColor[3])+CRLF,"BackColor" ))}

             SEPARATOR
             ITEM 'Set LineColor to RED' ACTION Form_1.Tree_1.LineColor := RED
             ITEM 'Set LineColor to BLACK' ACTION Form_1.Tree_1.LineColor := BLACK
             ITEM 'Get LineColor ' ACTION {|| ( aColor:= Form_1.Tree_1.LineColor, MsgBox("R:"+chr(9)+str(aColor[1])+CRLF+"G:"+chr(9)+str(aColor[2])+CRLF+"B:"+chr(9)+str(aColor[3])+CRLF,"LineColor" ))}

          END POPUP
          POPUP 'Other Properties'
             ITEM 'Set ItemHeight to 24' ACTION Form_1.Tree_1.ItemHeight := 24
             ITEM 'Set ItemHeight to default' ACTION Form_1.Tree_1.ItemHeight := -1
             Item 'Get ItemHeight value ' ACTION msgbox(str( Form_1.Tree_1.ItemHeight),"ItemHeight")

             SEPARATOR
             ITEM 'Set indent to 30' ACTION Form_1.Tree_1.Indent:=30
             ITEM 'Set indent to default' ACTION Form_1.Tree_1.Indent := 0
             Item 'Get indent value ' ACTION msgbox(str( Form_1.Tree_1.Indent),"Indent")
          End POPUP

      END MENU

      DEFINE CONTEXT MENU
         ITEM 'About'   ACTION MsgInfo ( "Free GUI Library For Harbour", "MiniGUI Tree Demo" )
      END MENU

      DEFINE TREE Tree_1 AT 10,10 WIDTH 200 HEIGHT 400 VALUE 15 ;
                       BACKCOLOR {255,255,200} ;
                       FONTCOLOR {255,0,0} ;
                       LINECOLOR {255,0,0} ;
                       INDENT 20 ;
                       ITEMHEIGHT 20  

         NODE 'Item 1'
            TREEITEM 'Item 1.1'
            TREEITEM 'Item 1.2' ID 999
            TREEITEM 'Item 1.3'
         END NODE

         NODE 'Item 2'

            TREEITEM 'Item 2.1'

            NODE 'Item 2.2'
               TREEITEM 'Item 2.2.1'
               TREEITEM 'Item 2.2.2'
               TREEITEM 'Item 2.2.3'
               TREEITEM 'Item 2.2.4'
               TREEITEM 'Item 2.2.5'
               TREEITEM 'Item 2.2.6'
               TREEITEM 'Item 2.2.7'
               TREEITEM 'Item 2.2.8'
            END NODE

            TREEITEM 'Item 2.3'

         END NODE

         NODE 'Item 3'
            TREEITEM 'Item 3.1'
            TREEITEM 'Item 3.2'

            NODE 'Item 3.3'
               TREEITEM 'Item 3.3.1'
               TREEITEM 'Item 3.3.2'
            END NODE

         END NODE

      END TREE


      DEFINE BUTTON Button_1
        ROW    10
        COL    400
        WIDTH  150
        HEIGHT 28
        CAPTION "Delete Item"
        ACTION IF(!Empty(Form_1.Tree_1.Value), Form_1.Tree_1.DeleteItem( Form_1.Tree_1.Value ), )
        TOOLTIP "Delete Selected Item"
      END BUTTON

      @ 40,400 BUTTON Button_2 ;
        CAPTION 'Delete All Items' ;
        ACTION Form_1.Tree_1.DeleteAllItems ;
        WIDTH 150

      @ 70,400 BUTTON Button_3 ;
        CAPTION 'Get Item Count' ;
        ACTION MsgInfo ( Str ( Form_1.Tree_1.ItemCount ) ) ;
        WIDTH 150

      @ 100,400 BUTTON Button_4 ;
        CAPTION 'DeleteAll / Add Test' ;
        ACTION AddItemTest() ;
        WIDTH 150

      @ 130,400 BUTTON Button_5 ;
        CAPTION 'Set Value' ;
        ACTION Form_1.Tree_1.Value := 1 ;
        WIDTH 150

      @ 160,400 BUTTON Button_6 ;
        CAPTION 'Get Item' ;
        ACTION MsgInfo ( Form_1.Tree_1.Item ( Form_1.Tree_1.Value ) ) ;
        WIDTH 150

      @ 190,400 BUTTON Button_7 ;
        CAPTION 'Set Item' ;
        ACTION IF(!Empty(Form_1.Tree_1.Value), Form_1.Tree_1.Item( Form_1.Tree_1.Value ) := 'New Item text', ) ;
        WIDTH 150

      @ 220,400 BUTTON Button_8 ;
        CAPTION 'Freeze Update' ;
        ACTION Form_1.Tree_1.DisableUpdate ;
        WIDTH 150

      @ 250,400 BUTTON Button_9 ;
        CAPTION 'UnFreeze Update' ;
        ACTION Form_1.Tree_1.EnableUpdate ;
        WIDTH 150

      @ 280,400 BUTTONEX Button_10 WIDTH 150 HEIGHT 28;
        CAPTION 'Change colors 1' ;
        BACKCOLOR WHITE;
        FONTCOLOR BLACK;
        NOXPSTYLE;
        ACTION {|| (Form_1.Tree_1.FontColor:=BLACK,Form_1.Tree_1.LineColor:=BLACK, Form_1.Tree_1.BackColor:=WHITE)}

      @ 310,400 BUTTONEX Button_11 ;
        WIDTH 150 HEIGHT 28;
        CAPTION 'Change colors 2' ;
        BACKCOLOR YELLOW;
        FONTCOLOR RED;
        NOXPSTYLE;
        ACTION {|| (Form_1.Tree_1.FontColor:=RED,Form_1.Tree_1.LineColor:=RED, Form_1.Tree_1.BackColor:=YELLOW)}

      @ 340,400 BUTTONEX Button_12 ;
        WIDTH 150 HEIGHT 28;
        CAPTION 'Change colors 3' ;
        BACKCOLOR BLUE;
        FONTCOLOR WHITE;
        NOXPSTYLE;
        ACTION {|| (Form_1.Tree_1.FontColor:=WHITE,Form_1.Tree_1.LineColor:=WHITE, Form_1.Tree_1.BackColor:=BLUE)}

   END WINDOW
   
   Form_1.Center
   Form_1.Activate

Return

Procedure AddItemTest()

   Form_1.Tree_1.DeleteAllItems

   Form_1.Tree_1.AddItem( 'New Root Item 1' , 0 )

   Form_1.Tree_1.AddItem( 'New Item 1.1' , 1 )
   Form_1.Tree_1.AddItem( 'New Item 1.2' , 1 )
   Form_1.Tree_1.AddItem( 'New Item 1.3' , 1 )

   Form_1.Tree_1.AddItem( 'New Root Item 2' , 0 )

   Form_1.Tree_1.AddItem( 'New Item 2.1' , 5 )
   Form_1.Tree_1.AddItem( 'New Item 2.2' , 5 )
   Form_1.Tree_1.AddItem( 'New Item 2.3' , 5 )

   Form_1.Tree_1.AddItem( 'New Item 1.4' , 1 )
   Form_1.Tree_1.AddItem( 'New Item 1.4.1' , 5 )

Return
