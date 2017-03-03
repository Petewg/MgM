/*
* MINIGUI - Harbour Win32 GUI library
* (c) 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*
* MiniGUI Extended - Harbour Win32 GUI library
* (c) MiniGUI Extended Team Grigory Filatov  Janusz Pora  Jacek Kubica
*
* MsgMenu()
* (c) 2005-06 Carlos Britos  <bcd12a@yahoo.com.ar>
*
* IGCM tool to compile app with Minigui Extended
* http://www.geocities.com/bcd12a/
*/

#include "minigui.ch"

#define msginfo( c ) MsgInfo( c, , , .f. )

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0 , 0 ;
		WIDTH 500 HEIGHT 200 ;
		TITLE 'Message Menu Demo' ;
		MAIN ;
		NOMAXIMIZE NOSIZE

		DEFINE MAIN MENU
			DEFINE POPUP "&Test"
			MENUITEM "&1 Default Style"                      ACTION test(1)
			MENUITEM "&2 Vertical with Cancel button"        ACTION test(2)
			MENUITEM "&3 Yes No, Tooltips"                   ACTION test(3)
			MENUITEM "&4 Horizontal without Cancel button"   ACTION test(4)
			MENUITEM "&5 Message multiline"                  ACTION test(5)
			MENUITEM "&6 No message, Error sound,Flat,Bold"  ACTION test(6)
			MENUITEM "&7 Buttons 3 and 4 Disabled"           ACTION test(7)
			MENUITEM "&8 Text at left, accelerator"          ACTION test(8)
			MENUITEM "&9 Bmp, Gif compiled"                  ACTION test(9)
			MENUITEM "&0 A lot of Buttons, Bmp Left, scroll" ACTION test(10)
			MENUITEM "&Timer to Exit"                        ACTION test(11)
			MENUITEM "&Icon Animated"                        ACTION test(12)
			MENUITEM '&About MsgMenu'                        ACTION About()
			SEPARATOR
			MENUITEM 'Exit'		ACTION Form_1.Release
			END POPUP
		END MENU

	END WINDOW

	Form_1.Center
	Form_1.Activate

Return Nil


procedure test(nTest)
local aPic, aTool, aDis, aCap, nOpt
local aDisa, aBtns, aBmp, xz

do case
    case nTest = 1
       msginfo( 'return value '+ str( ;
          MsgMenu( "Send file to.."                                      ,; /* [cMessage    ] */
                {'&Printer','&Fax','Fi&le','C&Drom','&E-mail','Fl&oppy'} ,; /*  aCaptions     */
                                                                         ,; /*  aPictures     */
                ".\res\print.gif"                                        ,; /* [cBitmap     ] */
                "Default style"                                          ,; /* [cTitle      ] */
                                                                         ,; /* [nFocusBtn   ] */
                                                                         ,; /* [aToolTips   ] */
                                                                         ,; /* [cStyle      ] */
                                                                         ,; /* [aDisableBtns] */
                                                                         ,; /* [nBtnsPorLine] */
                                                                         ,; /* [aBackColWin ] */
                                                                         ,; /* [aBackColBtn ] */
                                                                         ,; /* [aFontColBtn ] */
                                                                         ,; /* [nSizeBmpBtn ] */
                       )                                                 ,; /* [nTimeToExit ] */
                 2,0))


    case nTest = 2
       aPic := {'.\res\print.bmp','.\res\fax.bmp','.\res\book.bmp','.\res\CDrom.bmp','.\res\mail.bmp','.\res\Exit.bmp'}

       msginfo( 'return value ' + str( ;
          MsgMenu(                                                       ,; /* [cMessage    ] */
                {'&Printer','&Fax','Fi&le','C&Drom','&E-mail','&Exit' }  ,; /*  aCaptions     */
                aPic                                                     ,; /*  aPictures     */
                                                                         ,; /* [cBitmap     ] */
                "Vertical"                                               ,; /* [cTitle      ] */
                6                                                        ,; /* [nFocusBtn   ] */
                                                                         ,; /* [aToolTips   ] */
                "45 can left AST bold"                                   ,; /* [cStyle      ] */
                                                                         ,; /* [aDisableBtns] */
                1                                                        ,; /* [nBtnsPorLine] */
                {   0,240, 30 }                                          ,; /* [aBackColWin ] */
                { 230,240,250 }                                          ,; /* [aBackColBtn ] */
                { 255,  0, 50 }                                          ,; /* [aFontColBtn ] */
                45                                                       ,; /* [nSizeBmpBtn ] */
                     )                                                   ,; /* [nTimeToExit ] */
                   2,0))


    case nTest = 3
       aPic := {'.\res\Acept.bmp','.\res\Cancel.bmp'}
       aTool := {'Return value 1' ,'Return value 2'}

       msginfo( 'return value '+ str( ;
          MsgMenu( "Make a report ?"    ,; /* [cMessage    ] */
                {'Accept','Cancel'}     ,; /*  aCaptions     */
                aPic                    ,; /*  aPictures     */
                ".\res\Folder.Gif"      ,; /* [cBitmap     ] */
                "Yes No with bmps"      ,; /* [cTitle      ] */
                                        ,; /* [nFocusBtn   ] */
                aTool                   ,; /* [aToolTips   ] */
                'left EXC'              ,; /* [cStyle      ] */
                                        ,; /* [aDisableBtns] */
                                        ,; /* [nBtnsPorLine] */
                                        ,; /* [aBackColWin ] */
                                        ,; /* [aBackColBtn ] */
                                        ,; /* [aFontColBtn ] */
                 45                     ,; /* [nSizeBmpBtn ] */
                     )                  ,; /* [nTimeToExit ] */
                 2,0))


    case nTest = 4
       aPic := {'.\res\print.bmp','.\res\fax.bmp','.\res\book.bmp','.\res\CDrom.bmp','.\res\mail.bmp'}

       msginfo( 'return value ' + str( ;
          MsgMenu( "Send file to.."                            ,; /* [cMessage    ] */
                {'&Printer','&Fax','Fi&le','C&Drom','&E-mail'} ,; /*  aCaptions     */
                aPic                                           ,; /*  aPictures     */
                ".\res\ask.gif"                                ,; /* [cBitmap     ] */
                "Send to:"                                     ,; /* [cTitle      ] */
                                                               ,; /* [nFocusBtn   ] */
                                                               ,; /* [aToolTips   ] */
                "EXC"                                          ,; /* [cStyle      ] */
                                                               ,; /* [aDisableBtns] */
                5                                              ,; /* [nBtnsPorLine] */
                                                               ,; /* [aBackColWin ] */
                { 230,240,250 }                                ,; /* [aBackColBtn ] */
                                                               ,; /* [aFontColBtn ] */
                                                               ,; /* [nSizeBmpBtn ] */
                      )                                        ,; /* [nTimeToExit ] */
                  2,0))


    case nTest = 5
       aPic := {'.\res\print.bmp','.\res\fax.bmp','.\res\book.bmp','.\res\CDrom.bmp','.\res\mail.bmp','.\res\Exit.bmp'}

       msginfo( 'return value ' + str( ;
          MsgMenu( "Only pictures, no captions" +chr(13)+chr(10)+ "no Icon, no Esc key" +chr(13)+chr(10)+ ;
                   "Message multiline, Size buttons=40"   ,; /* [cMessage    ] */
                                                          ,; /*  aCaptions     */
                aPic                                      ,; /*  aPictures     */
                                                          ,; /* [cBitmap     ] */
                "Send to:"                                ,; /* [cTitle      ] */
                                                          ,; /* [nFocusBtn   ] */
                                                          ,; /* [aToolTips   ] */
                "40"                                      ,; /* [cStyle      ] */
                                                          ,; /* [aDisableBtns] */
                6                                         ,; /* [nBtnsPorLine] */
                { 250,240,230 }                           ,; /* [aBackColWin ] */
                { 230,240,250 }                           ,; /* [aBackColBtn ] */
                                                          ,; /* [aFontColBtn ] */
                                                          ,; /* [nSizeBmpBtn ] */
                      )                                   ,; /* [nTimeToExit ] */
                   2,0))


    case nTest = 6

       msginfo( 'return value '+ str( ;
          MsgMenu(                              ,; /* [cMessage    ] */
                {'&Abort','&Retry','Can&cel' }  ,; /*  aCaptions     */
                                                ,; /*  aPictures     */
                                                ,; /* [cBitmap     ] */
                "Error sound, flat, bold"       ,; /* [cTitle      ] */
                                                ,; /* [nFocusBtn   ] */
                                                ,; /* [aToolTips   ] */
                '50 Err flat bold'              ,; /* [cStyle      ] */
                                                ,; /* [aDisableBtns] */
                                                ,; /* [nBtnsPorLine] */
                {250 ,255, 0  }                 ,; /* [aBackColWin ] */
                {250 ,  0, 0  }                 ,; /* [aBackColBtn ] */
                { 0  ,  0, 100}                 ,; /* [aFontColBtn ] */
                                                ,; /* [nSizeBmpBtn ] */
                      )                         ,; /* [nTimeToExit ] */
                 2,0))


    case nTest = 7
       aPic := {'.\res\new.bmp','.\res\copy.bmp','.\res\paste.bmp','.\res\cut.bmp','.\res\close.bmp'}
       aDis := {3,4}

       msginfo( 'return value '+ str( ;
          MsgMenu( "Text is at the rigth"                 ,; /* [cMessage    ] */
                {'&New','&Copy','&Paste','C&ut','Clo&se'} ,; /*  aCaptions     */
                aPic                                      ,; /*  aPictures     */
                ".\res\Folder.Gif"                        ,; /* [cBitmap     ] */
                "Edition"                                 ,; /* [cTitle      ] */
                                                          ,; /* [nFocusBtn   ] */
                {'New','Copy','Paste','Cut','Close'}      ,; /* [aToolTips   ] */
                'left cancel ask'                         ,; /* [cStyle      ] */
                aDis                                      ,; /* [aDisableBtns] */
                                                          ,; /* [nBtnsPorLine] */
                                                          ,; /* [aBackColWin ] */
                                                          ,; /* [aBackColBtn ] */
                                                          ,; /* [aFontColBtn ] */
                 40                                       ,; /* [nSizeBmpBtn ] */
                      )                                   ,; /* [nTimeToExit ] */
                 2,0))


    case nTest = 8
       aPic := {'.\res\new.bmp','.\res\copy.bmp','.\res\paste.bmp','.\res\cut.bmp','.\res\close.bmp'}

       msginfo( 'return value '+ str( ;
          MsgMenu( "Text is at the left"              ,; /* [cMessage    ] */
                {'&New','&Copy','&Paste','C&ut','Clo&se'} ,; /*  aCaptions     */
                aPic                                  ,; /*  aPictures     */
                ".\res\Folder.Gif"                    ,; /* [cBitmap     ] */
                "Edition"                             ,; /* [cTitle      ] */
                                                      ,; /* [nFocusBtn   ] */
                {'New','Copy','Paste','Cut','Close'}  ,; /* [aToolTips   ] */
                'lefttext'                            ,; /* [cStyle      ] */
                                                      ,; /* [aDisableBtns] */
                                                      ,; /* [nBtnsPorLine] */
                                                      ,; /* [aBackColWin ] */
                                                      ,; /* [aBackColBtn ] */
                                                      ,; /* [aFontColBtn ] */
                 40                                   ,; /* [nSizeBmpBtn ] */
                       )                              ,; /* [nTimeToExit ] */
                 2,0))


    case nTest = 9
       aPic := {'bold','italic','under','right','left','center'}

       msginfo( 'return value '+ str( ;
          MsgMenu( "Gif,Bmp in Rc"      ,; /* [cMessage    ] */
                                        ,; /*  aCaptions     */
                aPic                    ,; /*  aPictures     */
                "Folder"                ,; /* [cBitmap     ] */
                "Resources compiled"    ,; /* [cTitle      ] */
                                        ,; /* [nFocusBtn   ] */
                                        ,; /* [aToolTips   ] */
                                        ,; /* [cStyle      ] */
                                        ,; /* [aDisableBtns] */
                3                       ,; /* [nBtnsPorLine] */
                                        ,; /* [aBackColWin ] */
                                        ,; /* [aBackColBtn ] */
                                        ,; /* [aFontColBtn ] */
                  50                    ,; /* [nSizeBmpBtn ] */
                      )                 ,; /* [nTimeToExit ] */
                 2,0))


    case nTest = 10
        aDisa := { 2 , 4 , 8 , 15 , 24 ,37 , 66 , 77 }
        aBtns := {'btn-&1','btn-&2','btn-&3','btn-&4','btn-&5','btn-&6','btn-&7','btn-&8','btn-&9','btn-10','btn-11','btn-12','btn-13','btn-14','btn-15','btn-16' ,;
                  'btn-17','btn-18','btn-19','btn-20','btn-21','btn-22','btn-23','btn-24','btn-25','btn-26','btn-27','btn-28','btn-29','btn-30','btn-31','btn-32' ,;
                  'btn-33','btn-34','btn-35','btn-36','btn-37','btn-38','btn-39','btn-40','btn-41','btn-42','btn-43','btn-44','btn-45','btn-46','btn-47','btn-48' ,;
                  'btn-49','btn-50','btn-51','btn-52','btn-53','btn-54','btn-55','btn-56','btn-57','btn-58','btn-59','btn-60','btn-61','btn-62','btn-63','btn-64' ,;
                  'btn-65','btn-66','btn-67','btn-68','btn-69','btn-70','btn-71','btn-72','btn-73','btn-74','btn-75','btn-76','btn-77','btn-78','btn-79','btn-&n' }
       aBmp := {}
       FOR xz := 1 TO 80
          aadd( aBmp , '.\res\info.bmp' )
       NEXT

       msginfo( 'return value ' + str( ;
          MsgMenu( "Select one .."          ,; /* [cMessage    ] */
                aBtns                       ,; /*  aCaptions     */
                aBmp                        ,; /*  aPictures     */
                ".\res\alert.gif"           ,; /* [cBitmap     ] */
                "Too much buttons to..."    ,; /* [cTitle      ] */
                80                          ,; /* [nFocusBtn   ] */
                                            ,; /* [aToolTips   ] */
                "LEF can ASK"               ,; /* [cStyle      ] */
                aDisa                       ,; /* [aDisableBtns] */
                6                           ,; /* [nBtnsPorLine] */
                                            ,; /* [aBackColWin ] */
                { 240 ,240 ,240 }           ,; /* [aBackColBtn ] */
                {255 ,100, 0  }             ,; /* [aFontColBtn ] */
                40                          ,; /* [nSizeBmpBtn ] */
                      )                     ,; /* [nTimeToExit ] */
                   2,0))


    case nTest = 11
       aPic := {'.\res\print.bmp','.\res\fax.bmp','.\res\book.bmp','.\res\CDrom.bmp','.\res\mail.bmp' ,;
                 '.\res\new.bmp','.\res\copy.bmp','.\res\paste.bmp','.\res\cut.bmp','.\res\close.bmp'}

       msginfo( 'return value ' + str( ;
          MsgMenu( "In 3 seconds" +chr(13)+chr(10)+ ;
                   "the timer return" +chr(13)+chr(10)+ ;
                   "the value of" +chr(13)+chr(10)+ ;
                   "focused button"        ,; /* [cMessage    ] */
                                           ,; /*  aCaptions     */
                aPic                       ,; /*  aPictures     */
                                           ,; /* [cBitmap     ] */
                "Timer return value 2"     ,; /* [cTitle      ] */
                2                          ,; /* [nFocusBtn   ] */
                                           ,; /* [aToolTips   ] */
                "50"                       ,; /* [cStyle      ] */
                                           ,; /* [aDisableBtns] */
                2                          ,; /* [nBtnsPorLine] */
                { 250,240,230 }            ,; /* [aBackColWin ] */
                { 240,230,220 }            ,; /* [aBackColBtn ] */
                                           ,; /* [aFontColBtn ] */
                                           ,; /* [nSizeBmpBtn ] */
                3     )                    ,; /* [nTimeToExit ] */
                   2,0))


    case nTest = 12
       aPic := {'.\res\Uruguay.bmp','.\res\Spain.bmp','.\res\France.bmp'}
       aCap := {'Uruguay','Spain','France'}

       nOpt:=MsgMenu( "My country is...",; /* [cMessage    ] */
                   aCap                 ,; /*  aCaptions     */
                   aPic                 ,; /*  aPictures     */
                   ".\res\Globe.Ani"    ,; /* [cBitmap     ] */
                   "Animate icon"       ,; /* [cTitle      ] */
                                        ,; /* [nFocusBtn   ] */
                                        ,; /* [aToolTips   ] */
                                        ,; /* [cStyle      ] */
                                        ,; /* [aDisableBtns] */
                                        ,; /* [nBtnsPorLine] */
                                        ,; /* [aBackColWin ] */
                                        ,; /* [aBackColBtn ] */
                                        ,; /* [aFontColBtn ] */
                    40                  ,; /* [nSizeBmpBtn ] */
                        )                  /* [nTimeToExit ] */

       msginfo( aCap[nOpt] + " is" + IF( nOpt == 1 , "" , " not" ) + " my country" )

endcase

return


FUNCTION About()
LOCAL nOpcion := 0
LOCAL cAbout := chr(13)+chr(10)
LOCAL aTips := {"Email to author", "Exit"}
LOCAL aPic := {'.\res\Contact.Bmp', '.\res\Acept.bmp'}

    cAbout += 'MsgMenu()' +chr(13)+chr(10)
    cAbout += 'All in one line of code' +chr(13)+chr(10)
    cAbout += 'With the power of Minigui Extended' +chr(13)+chr(10)
    cAbout += replicate( '-' , 80) +chr(13)+chr(10)
    cAbout += MiniGuiVersion() +chr(13)+chr(10)
    cAbout += Version() +chr(13)+chr(10)
    cAbout += hb_compiler() +chr(13)+chr(10)
    cAbout += replicate( '-' , 80) +chr(13)+chr(10)
    cAbout += 'bcd12a@yahoo.com.ar' +chr(13)+chr(10)
    cAbout += '(c) Carlos Britos' +chr(13)+chr(10)
    cAbout += replicate( '-' , 80)

   nOpcion := MsgMenu( cAbout           ,; /* [cMessage     ] */
                   {'Email','Ok'}       ,; /*  aCaptions      */
                   aPic                 ,; /*  aPictures      */
                                        ,; /* [cBitmap      ] */
                   'About MsgMenu'      ,; /* [cTitle       ] */
                   2                    ,; /* [nFocusBtn    ] */
                   aTips                ,; /* [aToolTips    ] */
                   "can bol leftex exc" ,; /* [cStyle       ] */
                                        ,; /* [aDisableBtns ] */
                                        ,; /* [nBtnsPorLine ] */
                   { 250,240,230 }      ,; /* [aBackColWin  ] */
                   { 200,230,255 }      ,; /* [aBackColBtn  ] */
                   {  0 ,130, 0  }      ,; /* [aFontColBtn  ] */
                   50                   ,; /* [nSizeBmpBtn  ] */
                      )                    /* [nTimeToExit  ] */
   IF nOpcion == 1
      ShellExecute( 0 , "open", "rundll32.exe", "url.dll,FileProtocolHandler mailto:bcd12a@yahoo.com.ar? &subject=MsgMenu() &body=" , , 1 )
   ENDIF

RETURN NIL


#include "Msg_menu.Prg"
