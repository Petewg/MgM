/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2004 Janusz Pora <januszpora@onet.eu>
*/



#include "minigui.ch"

#define KON_LIN   chr(13)+chr(10)

#define IDD_ABOUT	100
#define DLG_0300	300
#define DLG_0400	400
#define	DIALOG_1WS	700


#define DLG_TEST1	9999
#define DLG_TEST2	9998
#define DLG_TEST3	9997

#define DLG_BRW1	9989
#define DLG_BRW2	9988
#define DLG_BRW3	9987

#define	DLG_CAL	        302
#define	DLG_OK	          1
#define	DLG_COMBO	    303

#define IDOK                1
#define IDCANCEL            2
#define IDIGNORE            5


Procedure main()

    DEFINE WINDOW MainForm ;
	    AT 0,0 ;
	    WIDTH 450 ;
	    HEIGHT 200 ;
	    TITLE 'Demo for Dialog   -   By Janusz Pora' ;
        ICON 'Dialog.ico' ; 
	    MAIN 

	    ON KEY ALT+X ACTION THISWINDOW.RELEASE
		DEFINE MAIN MENU 
			POPUP 'Dialogs - Tests'
				ITEM 'Test - Standard Window '   ACTION Test(1)
				ITEM 'Test - Dialog from RC  '   ACTION Test(2)
				ITEM 'Test - Dialog Indirect '   ACTION Test(3)
		    	SEPARATOR	
				ITEM '&Exit'			ACTION MainForm.Release
			END POPUP
			POPUP 'Browse - Test'
				ITEM 'Browse - Standard '   ACTION Test(4)
				ITEM 'Browse - from RC  '   ACTION Test(5)
				ITEM 'Browse - Indirect '   ACTION Test(6)
			END POPUP
			POPUP 'RC WorkShop'
				ITEM 'Test1'   ACTION RC_WS_test()
			END POPUP
		    POPUP '&Help'
				ITEM '&About'		ACTION dlg_about() 
			END POPUP
		END MENU


      @ 30,70    LABEL Lbl_1 ; 
          VALUE 'Dialogs Demo' AUTOSIZE ;
          FONT 'Arial' SIZE 24 ;
          BOLD ITALIC FONTCOLOR RED 

           
       @ 80,150    LABEL Lbl_2 ; 
          VALUE 'in MiniGUI' AUTOSIZE ;
          FONT 'Arial' SIZE 24 ;
          BOLD ITALIC FONTCOLOR BLUE 

    END WINDOW

    CENTER WINDOW MainForm
    ACTIVATE WINDOW MainForm
Return

*-------------------------------------------------------------
Function dlg_about()
*-------------------------------------------------------------

    DEFINE DIALOG f_dialog ;
        OF MainForm ;
		RESOURCE IDD_ABOUT ;

    REDEFINE BUTTON Btn_1 ID 101 ;
    	ACTION thiswindow.release

    REDEFINE IMAGE image_1 ID 200 ;
    	PICTURE 'BMP_0' ;
	    STRETCH

    END DIALOG
Return Nil


*-------------------------------------------------------------
Function Test(typ)
*-------------------------------------------------------------
    do case
    case typ == 1
        Testfunc(DLG_TEST1)
    case typ == 2
        Testfunc(DLG_TEST2)
    case typ == 3
        Testfunc(DLG_TEST3)
    case typ == 4
        Testfunc(DLG_BRW1)
    case typ == 5
        Testfunc(DLG_BRW2)
    case typ == 6
        Testfunc(DLG_BRW3)
    endcase

Return Nil
	
*-------------------------------------------------------------
Function Testfunc(Idd)
*-------------------------------------------------------------
    Do Case
    Case Idd ==  DLG_TEST1

        DEFINE WINDOW f_FrameTest ;
            AT 12, 36 ;
	        WIDTH 790 ;
            HEIGHT 600  ;
	        TITLE 'Standard Window with Controls '; 
	    	CHILD  

            @ 10,20 LABEL Lbl_1  ;
    	        VALUE 'New Label - Bold' BOLD ;
	            WIDTH 170   ;
                HEIGHT 24  ;
                TOOLTIP 'Tooltip for Label' 

            @ 40,20  EDITBOX EdBox_1a  ;
	            WIDTH 200   ;
                HEIGHT 70 ;
 	            VALUE ' Sample Edit Text'   ;
                TOOLTIP 'Defined EditBox ' 

            @ 120,20 COMBOBOX cBox_1a  ;
		        ITEMS {'Item 1','Item 2','Item 3'} ; 
		        VALUE 1 ;
	            WIDTH 200   ;
                HEIGHT 70 ;
	            TOOLTIP 'Defined ComboBox ' 


	        @ 190,20 FRAME frame_1a ;
    	        CAPTION 'Frame ';
	            WIDTH 200   ;
                HEIGHT 100 

            @ 205,30  CHECKBOX chkbox_1A ;
		        CAPTION 'Active CheckBox';
	            WIDTH 160   ;
                HEIGHT 24  ;
                TOOLTIP 'Defined CheckBox ' 

            @ 235,30 RADIOGROUP RadioGrp_1a  ; 
 	          	OPTIONS {'Radio 1','Radio 2' } ;
			    VALUE 1	;
	            WIDTH 140   ;
                SPACING 25 ;
		        FONT 'System' ;
			    SIZE 12	;
                TOOLTIP 'Defined RadioGroup' 

            @ 310,20   LISTBOX lBox_1a ;
	            WIDTH 200   ;
                HEIGHT 100 ;
	            ITEMS {'Line 1','Line 2','Line 3'} ;
	            VALUE 2 ;
	            TOOLTIP 'Defined ListBox ' 

            @ 430,20 TEXTBOX TextBox_1  ;
                HEIGHT 24  ;
                VALUE 'TextBox Value'  ;
 	            WIDTH 200  ;
                TOOLTIP 'TextBox Created ' 

            @ 470,20 IMAGE image_1a  ;
 	            PICTURE 'DEMO' ;
	            WIDTH 50   ;
                HEIGHT 50 

		    DEFINE TAB Tab_1a ID 316 ;
                AT 30,240 ;
	            WIDTH 300   ;
                HEIGHT 120 ;
    			VALUE 1 ;
	    		TOOLTIP 'Defined Tab Control' 

    			DEFINE PAGE 'Page 1' IMAGE 'Exit.Bmp'

                    @ 50,20 LABEL Lbl_2a  ;
    	                VALUE 'Label on Page 1' ;
	                    WIDTH 170   ;
                        HEIGHT 24  ;
                        TOOLTIP 'Defined Label on Page 1' 

	    		END PAGE

		    	DEFINE PAGE 'Page &2' IMAGE 'Info.Bmp'

                    @ 50,120 LABEL Lbl_3a  ;
    	                VALUE 'Label on Page 2' ;
	                    WIDTH 170   ;
                        HEIGHT 24  ;
                        TOOLTIP 'Defined Label on Page 2' 

			    END PAGE

    			DEFINE PAGE 'Page 3' IMAGE 'Check.Bmp'

	    		END PAGE

		    END TAB


            @ 180,240 BUTTON Btn_2a ;
        		PICTURE "PLAY.BMP" ;
		        ACTION {|| _PlayAnimateBox ( 'Ani_1a' , 'f_FrameTest' )};
	            WIDTH 30   ;
                HEIGHT 30 ;
		        TOOLTIP 'Defined Imagebutton' 

		    @ 180, 270 CHECKBUTTON CheckBtn_1a ;
		        PICTURE 'info.bmp'  ;
	            WIDTH 30   ;
                HEIGHT 30 ;
		        VALUE .F. ;
		        TOOLTIP 'Graphical CheckButton' 

		  @ 170,310 ANIMATEBOX Ani_1a  ;
	            WIDTH 240   ;
                HEIGHT 50 ;
			    FILE 'Sample.Avi' 


            @ 250,240 SLIDER sld_1a  ;
            	RANGE 1,10 ;
	            VALUE 20 ;
	            WIDTH 300   ;
                HEIGHT 30 ;
	            TOOLTIP 'Defined Slider '


            @ 290,240 PROGRESSBAR progrBar_1a  ;
        	    RANGE 1 , 200		;
	            VALUE 50		;
	            WIDTH 300   ;
                HEIGHT 30 ;
	            TOOLTIP 'Defined ProgressBar '	


            @ 330,240 GRID Grid_1a  ;
	            WIDTH 300   ;
                HEIGHT 130 ;
		        HEADERS {'Key','Name','Data'}	;
		        WIDTHS {60,200,100}		;
		        ITEMS {{'10','Adrian','256'}}
	            TOOLTIP 'Defined Grid '	

            @ 500,240 BUTTON Btn_1a  ;
                CAPTION 'Exit'  ;
       	        ACTION thiswindow.release ;
 	            WIDTH 70   ;
                HEIGHT 24  ;
                TOOLTIP 'End Demo Dialog' 

            @ 30 ,560  DATEPICKER DatePicker_1   ; 
                VALUE date(); 
                WIDTH 180;
                TOOLTIP 'Defined DatePicker'

            @ 60 ,560 MONTHCALENDAR MonthCal_1 ; 
                VALUE date(); 
                TOOLTIP 'Defined MonthCalendar '

            DEFINE TREE tree_1a  ;
                AT 270,560 ;
	            WIDTH 170   ;
                HEIGHT 230 ;
	            VALUE 1 ;
	            TOOLTIP 'Defined Tree '

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


	    END WINDOW

	    f_FrameTest.Center

	    f_FrameTest.Activate


    Case Idd ==  DLG_TEST2

       InitExCommonControls(1)


        DEFINE DIALOG f_dialogTest2 ;
            OF MainForm ;
		    RESOURCE DLG_0400;
            CAPTION 'Available REDEFINE for Controls';
            DIALOGPROC { |x,y,z| DialogFun(x,y,z) };
            ON INIT InitProc()

            REDEFINE LABEL Lbl_1 ID 100 ;
    	        VALUE 'New Label - Bold' BOLD ;
                TOOLTIP 'Redefined Label' 

            REDEFINE EDITBOX EdBox_1 ID 102 ;
 	            VALUE ' Sample Edit Text'   ;
                TOOLTIP 'Redefined EditBox' 


            REDEFINE COMBOBOX cBox_1 ID 108 ;
		        ITEMS {'Item 1','Item 2','Item 3'} ; 
		        VALUE 1 ;
	            TOOLTIP 'Redefined ComboBox' 

	        REDEFINE FRAME frame_1 ID 106;
    	        CAPTION 'Redefined Frame'

            REDEFINE CHECKBOX chkbox_1 ID 103;
		        CAPTION 'Active CheckBox';
                TOOLTIP 'Redefined CheckBox' 

            REDEFINE RADIOGROUP RadioGrp_1 ID  {104,105} ; 
	          	OPTIONS {'Radio 1','Radio 2' } ;
			    VALUE 2	;
		        FONT 'System' ;
			    SIZE 12	;
                TOOLTIP 'Redefined RadioGroup' 

            REDEFINE LISTBOX lBox_1 ID 107;
	            ITEMS {'Line 1','Line 2','Line 3'} ;
	            VALUE 2 ;
	            TOOLTIP 'Redefined ListBox' 


           REDEFINE IMAGE image_1 ID 110 ;
	            PICTURE 'DEMO' ;


 		    REDEFINE ANIMATEBOX Ani_1 ID 117 ;
			FILE 'Sample.Avi' 

            REDEFINE BUTTON Btn_2 ID 118;
        		PICTURE "PLAY.BMP" ;
		        ACTION {|| _PlayAnimateBox ( 'Ani_1' , 'f_DialogTest2' )};
		        TOOLTIP 'Redefined Imagebutton' 

            REDEFINE BUTTON Btn_1 ID 101 ;
                CAPTION 'Exit'  ;
    	        ACTION thiswindow.release ;
                TOOLTIP 'End Demo Dialog' 

		    REDEFINE CHECKBUTTON CheckBtn ID 119;
		        PICTURE 'info.bmp'  ;
		        VALUE .F. ;
		        TOOLTIP 'Graphical CheckButton' 

            REDEFINE SLIDER sld_1 ID 111 ;
            	RANGE 1,10 ;
	            VALUE 20 ;
	            TOOLTIP 'Redefined Slider'

            REDEFINE PROGRESSBAR progrBar_1 ID 112 ;
        	    RANGE 1 , 200		;
	            VALUE 50		;
	            TOOLTIP 'Redefined ProgressBar'	


            REDEFINE GRID Grid_1 ID 114 ;
		        HEADERS {'Key','Name','Data'}	;
		        WIDTHS {60,200,100}		;
		        ITEMS {{'10','Adrian','256'}}
	            TOOLTIP 'Redefined Grid'	

          REDEFINE TEXTBOX TextBox_1 ID 123 ;
                VALUE 'TextBox Value'  ;
                TOOLTIP 'TextBox Redefined' 

            REDEFINE TREE tree_1 ID 115 ;
	            VALUE 1 ;
	            TOOLTIP 'Redefined Tree'

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
    
            REDEFINE DATEPICKER DatePicker_1 ID 124; 
                VALUE date(); 
                TOOLTIP 'Redefined DatePicker'


            REDEFINE MONTHCALENDAR MonthCal_1 ID 125; 
                VALUE date(); 
                TOOLTIP 'Redefined MonthCalendar'


		    REDEFINE TAB Tab_1 ID 116 ;
    			VALUE 1 ;
	    		TOOLTIP 'Redefined Tab Control' 

    			DEFINE PAGE 'Page 1' IMAGE 'Exit.Bmp'

                    REDEFINE LABEL Lbl_2 ID 121 ;
    	                VALUE 'Label on Page 1' ;
                        TOOLTIP 'Redefined Label on Page 1' 

	    		END PAGE

		    	DEFINE PAGE 'Page &2' IMAGE 'Info.Bmp'
                    REDEFINE LABEL Lbl_3 ID 122 ;
    	                VALUE 'Label on Page 2' ;
                        TOOLTIP 'Redefined Label on Page 2' 

			    END PAGE

    			DEFINE PAGE 'Page 3' IMAGE 'Check.Bmp'

	    		END PAGE

		    END TAB



        END DIALOG 

    Case Idd ==  DLG_TEST3

         DEFINE DIALOG f_DialogTest3 ;
            OF MainForm ;
            AT 10, 10 ;
            WIDTH 790  ;
            HEIGHT 600 ;
            CAPTION 'Dialog in Memory';
            DIALOGPROC { |x,y,z| DialogFun(x,y,z) };
            ON INIT InitProc()


            @ 10,20 LABEL Lbl_1 ID 402 ;
    	        VALUE 'New Label - Bold' BOLD ;
	            WIDTH 170   ;
                HEIGHT 24  ;
                TOOLTIP 'Tooltip for Label' 

            @ 40,20  EDITBOX EdBox_1a ID 302 ;
	            WIDTH 200   ;
                HEIGHT 70 ;
 	            VALUE ' Sample Edit Text'   ;
                TOOLTIP 'Defined EditBox in Memory' 

            @ 120,20 COMBOBOX cBox_1a ID 308 ;
		        ITEMS {'Item 1','Item 2','Item 3'} ; 
		        VALUE 1 ;
	            WIDTH 200   ;
                HEIGHT 70 ;
	            TOOLTIP 'Defined ComboBox in Memory' 


	        @ 190,20 FRAME frame_1a ID 306;
    	        CAPTION 'Frame ';
	            WIDTH 200   ;
                HEIGHT 100 

            @ 205,30  CHECKBOX chkbox_1A ID 303;
		        CAPTION 'Active CheckBox';
	            WIDTH 160   ;
                HEIGHT 24  ;
                TOOLTIP 'Defined CheckBox in Memory' 

            @ 235,30 RADIOGROUP RadioGrp_1a ID  {304,305} ; 
 	          	OPTIONS {'Radio 1','Radio 2' } ;
			    VALUE 1	;
	            WIDTH 140   ;
                SPACING 25 ;
		        FONT 'System' ;
			    SIZE 12	;
                TOOLTIP 'Defined RadioGroup' 

            @ 310,20   LISTBOX lBox_1a ID 307;
	            WIDTH 200   ;
                HEIGHT 100 ;
	            ITEMS {'Line 1','Line 2','Line 3'} ;
	            VALUE 2 ;
	            TOOLTIP 'Defined ListBox in Memory' 

            @ 430,20 TEXTBOX TextBox_1 ID 323 ;
                HEIGHT 24  ;
                VALUE 'TextBox Value'  ;
 	            WIDTH 200  ;
                TOOLTIP 'TextBox Created In Memory' 

            @ 470,20 IMAGE image_1a ID 310 ;
 	            PICTURE 'DEMO' ;
	            WIDTH 50   ;
                HEIGHT 50 

		    DEFINE TAB Tab_1a ID 316 ;
                AT 30,240 ;
	            WIDTH 300   ;
                HEIGHT 120 ;
    			VALUE 1 ;
	    		TOOLTIP 'Redefined Tab Control' 

    			DEFINE PAGE 'Page 1' IMAGE 'Exit.Bmp'

                    @ 50,20 LABEL Lbl_2a ID 321 ;
    	                VALUE 'Label on Page 1' ;
	                    WIDTH 170   ;
                        HEIGHT 24  ;
                        TOOLTIP 'Redefined Label on Page 1' 

	    		END PAGE

		    	DEFINE PAGE 'Page &2' IMAGE 'Info.Bmp'

                    @ 50,120 LABEL Lbl_3a ID 322 ;
    	                VALUE 'Label on Page 2' ;
	                    WIDTH 170   ;
                        HEIGHT 24  ;
                        TOOLTIP 'Redefined Label on Page 2' 

			    END PAGE

    			DEFINE PAGE 'Page 3' IMAGE 'Check.Bmp'

	    		END PAGE

		    END TAB


            @ 180,240 BUTTON Btn_2a ID 318;
        		PICTURE "PLAY.BMP" ;
		        ACTION {|| _PlayAnimateBox ( 'Ani_1a' , 'f_DialogTest3' )};
	            WIDTH 30   ;
                HEIGHT 30 ;
		        TOOLTIP 'Defined Imagebutton' 

		    @ 180, 270 CHECKBUTTON CheckBtn_1a ID 319;
		        PICTURE 'info.bmp'  ;
	            WIDTH 30   ;
                HEIGHT 30 ;
		        VALUE .F. ;
		        TOOLTIP 'Graphical CheckButton' 

		  @ 170,310 ANIMATEBOX Ani_1a ID 317 ;
	            WIDTH 240   ;
                HEIGHT 50 ;
			    FILE 'Sample.Avi' 


            @ 250,240 SLIDER sld_1a ID 311 ;
            	RANGE 1,10 ;
	            VALUE 20 ;
	            WIDTH 300   ;
                HEIGHT 30 ;
	            TOOLTIP 'Defined Slider in Memory'


            @ 290,240 PROGRESSBAR progrBar_1a ID 312 ;
        	    RANGE 1 , 200		;
	            VALUE 50		;
	            WIDTH 300   ;
                HEIGHT 30 ;
	            TOOLTIP 'Defined ProgressBar in Memory'	


            @ 330,240 GRID Grid_1a ID 314 ;
	            WIDTH 300   ;
                HEIGHT 130 ;
		        HEADERS {'Key','Name','Data'}	;
		        WIDTHS {60,200,100}		;
		        ITEMS {{'10','Adrian','256'}}
	            TOOLTIP 'Defined Grid in Memory'	

            @ 500,240 BUTTON Btn_1a ID 301 ;
                CAPTION 'Exit'  ;
       	        ACTION thiswindow.release ;
 	            WIDTH 70   ;
                HEIGHT 24  ;
                TOOLTIP 'End Demo Dialog' 


            @ 30 ,560  DATEPICKER DatePicker_1  ID 324 ; 
                VALUE date(); 
                WIDTH 180;
                TOOLTIP 'Defined DatePicker'

            @ 60 ,560 MONTHCALENDAR MonthCal_1 ID 125; 
                VALUE date(); 
                TOOLTIP 'Defined MonthCalendar in Memory'

            DEFINE TREE tree_1a ID 315 ;
                AT 270,560 ;
	            WIDTH 170   ;
                HEIGHT 230 ;
	            VALUE 1 ;
	            TOOLTIP 'Defined Tree in Memory'

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


        END DIALOG 

   Case Idd ==  DLG_BRW1

        DEFINE WINDOW f_FrameTest ;
            AT 12, 36 ;
	        WIDTH 640 ;
            HEIGHT 500  ;
	        TITLE 'Standard Window with Browse '; 
	    	CHILD ; 
		    ON INIT OpenTables() ;
		    ON RELEASE CloseTables()


           @ 34, 20 BROWSE Browse_1a 		;
	            WIDTH 600  ;
                HEIGHT 300  ;
		        HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
		        WIDTHS { 100 , 150 , 150 , 100 , 50 , 150 } ;
		        WORKAREA Test ;
		        FIELDS { 'Test->Code' , 'Test->Code' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
		        VALUE 1;
        		ON CHANGE ChangeTest1()

            @ 350, 300 BUTTON Btn_1a  ;
                CAPTION 'Exit'  ;
    	        ACTION thiswindow.release ;
                WIDTH 80;
                HEIGHT 28;
                TOOLTIP 'End Browse Dialog' 
	    END WINDOW

	    f_FrameTest.Center

	    f_FrameTest.Activate


    Case Idd ==  DLG_BRW2
        DEFINE DIALOG f_dialog1 ;
            OF MainForm ;
		    RESOURCE DLG_0300;
            CAPTION 'Dialog from RC with Browse';
		    ON INIT OpenTables() ;
		    ON RELEASE CloseTables()


            REDEFINE BROWSE Browse_1 		;
                ID 	DLG_CAL	;
		        HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
		        WIDTHS { 100 , 150 , 150 , 100 , 50 , 150 } ;
		        WORKAREA Test ;
		        FIELDS { 'Test->Code' , 'Test->Code' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
		        VALUE 1;
        		ON CHANGE ChangeTest()

            REDEFINE COMBOBOX cBox_0 ID DLG_COMBO ;
		        ITEMSOURCE Test->Last ;
        		VALUESOURCE 1  ;
	            TOOLTIP 'Redefined ComboBox' 

            REDEFINE BUTTON Btn_1 ID DLG_OK ;
                CAPTION 'Exit'  ;
    	        ACTION thiswindow.release ;
                TOOLTIP 'End Browse Dialog' 


        END DIALOG 
        SetProperty ( "f_dialog1","Browse_1","SetFocus" )            

   Case Idd ==  DLG_BRW3

        DEFINE DIALOG f_dialog1a ;
            OF MainForm ;
            AT 12, 36 ;
	        WIDTH 640   ;
            HEIGHT 380  ;
            CAPTION 'Dialog in Memory with Browse';
		    ON INIT OpenTables() ;
		    ON RELEASE CloseTables()


            @ 34, 20 BROWSE Browse_1a 		;
                ID 	DLG_CAL	;
	            WIDTH 600  ;
                HEIGHT 300  ;
		        HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
		        WIDTHS { 100 , 150 , 150 , 100 , 50 , 150 } ;
		        WORKAREA Test ;
		        FIELDS { 'Test->Code' , 'Test->Code' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
		        VALUE 1;
        		ON CHANGE ChangeTest1()

            @ 350, 300 BUTTON Btn_1a ID DLG_OK ;
                CAPTION 'Exit'  ;
    	        ACTION thiswindow.release ;
                WIDTH 80;
                HEIGHT 28;
                TOOLTIP 'End Browse Dialog' 

        END DIALOG 
        SetProperty ( "f_dialog1a","Browse_1a","SetFocus" )            

    Endcase

Return Nil


Function RC_WS_test()
       DEFINE DIALOG f_dialogTest2 ;
            OF MainForm ;
		    RESOURCE DIALOG_1WS;
            CAPTION 'Test Dialogs from Resource Workshop';
            DIALOGPROC { |x,y,z| DialogFun(x,y,z) };

        END DIALOG 
Return Nil


Function DialogFun( nMsg, Id, Notify )
    local ret := 0
    if Id != Nil
        do case
        case Id == IDOK .and. Notify ==0
            _ReleaseWindow ( 'f_DialogTest2')
        case Id == IDCANCEL .and. Notify ==0
            _ReleaseWindow ( 'f_DialogTest2')
        case Id == 1110 .and. Notify ==0
//            dlg_about()
            ret := 1
        case Id == 1030 .and. Notify ==0
            _ReleaseWindow ( 'f_DialogTest2')
        case Id == 116
            msginfo(' Notify - '+ str(Notify))
        otherwise
                
    	     If Id >= 101 .and. Id <=199 .and. Notify < 3
                if GetProperty ( "f_DialogTest2","CheckBtn","Value" )            
		    	    Msginfo('Control Id'+str(Id)+KON_LIN+' Notify - '+ str(Notify))
                Endif
            else
//			    Msginfo('Test - Control Id'+str(Id)+KON_LIN+' Notify - '+ str(Notify))
            endif
    	     If Id >= 301 .and. Id <=399 .and. Notify < 3
                if GetProperty ( "f_DialogTest3","CheckBtn_1a","Value" )            
		    	    Msginfo('Control Id'+str(Id)+KON_LIN+' Notify - '+ str(Notify))
                Endif
            endif
         endcase
    endif
Return ret

Function InitProc()
    //    msginfo('InitDialog Procedure')
Return Nil

Procedure OpenTables()
	Use Test 
Return

Procedure CloseTables()
	Use
Return

Procedure ChangeTest()

// Test          

Return 



Procedure ChangeTest1()

//	Test           

Return 


