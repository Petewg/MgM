  MINIGUI - Harbour Win32 GUI library Demo/Sample

  Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  'CuckooClock' is Open Source/Freeware HMG Demo / Sample

  All bug reports and suggestions are welcome.

  Developed with MiniGUI  - Harbour Win32 GUI library (HMG),
  Compiled and Linked with Harbour Compiler and MinGW.

  Thanks to "Le Roy" Roberto Lopez.

  Copyright 2009 © Bicahi Esgici <esgici @ gmail.com>

  History : 2009-6 : First Release
                                                           
                                  
  Notes : 
  
   - 'CuckooClock' uses "LcdD" font and this font is in LCDN.TTF font file. 
     This font file exists in standard distribution of Windows XP but as far as I know
     not found in Vista. If so you can use it simply by copying this font file to your 
     Windows\fonts folder. You can use anything else of course. 
      
   - This sample is a standalone application. If you want use it into your own application :
     add CuckooClock() calling line to your main window's ON INIT event and change "MAIN" 
     property of frmCuckooClock to "CHILD"

   - For seeing CDOW() ( Name of day of week ) in your own language 
     add following two lines at top of Main() procedure / function :
     
     REQUEST HB_LANG_xx
     HB_LANGSELECT( "xx" ) 
     
     and replace "xx" in it with your language code.

           

