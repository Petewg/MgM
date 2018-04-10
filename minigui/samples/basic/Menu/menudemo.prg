#include "MiniGUI.ch"

Procedure Main

Define window Form_1 ;
       At 0, 0 ;
       Width 400 ;
       Height 200 ;
       Title 'Menu Test' ;
       Icon 'Demo.ico' ;
       Main ;
       NotifyIcon 'Demo.ico'

   Define main menu

      Popup 'File'

        Item 'Open'        Action MsgInfo ( 'File:Open'  ) Image 'Check.Bmp' 
        Item 'Save'        Action MsgInfo ( 'File:Save'  ) Image 'Free.Bmp'  
        Item 'Print'       Action MsgInfo ( 'File:Print' ) Image 'Info.Bmp'  
        Item 'Save As...'  Action MsgInfo ( 'File:Save As' ) Disabled
        Separator
        Item 'Exit' Action Form_1.Release Image 'Exit.Bmp' Default

      End Popup

      Popup 'Test' 
        Item 'Item 1' Action MsgInfo ( 'Item 1' )
        Item 'Item 2' Action MsgInfo ( 'Item 2' )

        Popup 'Item 3'
          Item 'Item 3.1' Action MsgInfo ( 'Item 3.1' ) 
          Item 'Item 3.2' Action MsgInfo ( 'Item 3.2' )

          Popup 'Item 3.3'
            Item 'Item 3.3.1' Action MsgInfo ( 'Item 3.3.1' )
            Item 'Item 3.3.2' Action MsgInfo ( 'Item 3.3.2' )

            Popup 'Item 3.3.3' 	
              Item 'Item 3.3.3.1' Action MsgInfo ( 'Item 3.3.3.1' )
              Item 'Item 3.3.3.2' Action MsgInfo ( 'Item 3.3.3.2' )
              Item 'Item 3.3.3.3' Action MsgInfo ( 'Item 3.3.3.3' )
              Item 'Item 3.3.3.4' Action MsgInfo ( 'Item 3.3.3.4' )
              Item 'Item 3.3.3.5' Action MsgInfo ( 'Item 3.3.3.5' )
              Item 'Item 3.3.3.6' Action MsgInfo ( 'Item 3.3.3.6' )  

            End Popup

            Item 'Item 3.3.4' Action MsgInfo ( 'Item 3.3.4' )

          End Popup

        End Popup

        Item 'Item 4' Action MsgInfo ( 'Item 4' ) Disabled

      End Popup

      Popup 'Help'

        Item 'About' Action MsgInfo ( MiniGuiVersion() )

      End Popup

   End Menu

   Define context menu

      Popup "Context item 1"
         Item "Context item 1.1" Action MsgInfo( "Context item 1.1!" )
         Item "Context item 1.2" Action MsgInfo( "Context item 1.2!" )

         Popup 'Context item 1.3'
           Item "Context item 1.3.1" Action MsgInfo( "Context item 1.3.1!" ) Image 'Info.Bmp'
           Separator
           Item "Context item 1.3.2" Action MsgInfo( "Context item 1.3.2!" ) Checked
         End Popup

      End Popup

      Item "Context item 2 - Simple " Action MsgInfo( "Context item 2 - Simple!" ) Checked Default
      Item "Context item 3 - Disabled" Action MsgInfo( "Context item 3 - Disabled" ) Disabled
      Separator
      Popup "Context item 4"
         Item "Context item 4.1" Action MsgInfo( "Context item 4.1!" )
         Item "Context item 4.2" Action MsgInfo( "Context item 4.2!" )
         Item "Context item 4.3" Action MsgInfo( "Context item 4.3!" ) Disabled
      End Popup
   End Menu

   Define notify menu 
     Item 'About...' Action MsgInfo ( MiniGuiVersion() )
     
     Popup 'Options'
       Item 'Autorun' Action ToggleAutorun() Name SetAuto Checked
     End Popup
     
     Popup 'Notify Icon' Image 'Info.Bmp'
       Item 'Get Notify Icon Name' Action MsgInfo ( Form_1.NotifyIcon ) 
       Item 'Change Notify Icon' Action Form_1.NotifyIcon := 'Demo2.ico'
     End Popup
     Separator	
     Item 'Exit Application' Action Form_1.Release Image 'Exit.Bmp' Default
   End Menu

End Window

Center window Form_1
Activate window Form_1

Return


Static Procedure ToggleAutorun
Local lChecked := Form_1.SetAuto.Checked

If lChecked
   Form_1.SetAuto.Checked := .F.
   MsgInfo( 'Autorun is disabled' )
Else
   Form_1.SetAuto.Checked := .T.
   MsgInfo( 'Autorun is enabled' )
Endif

Return
