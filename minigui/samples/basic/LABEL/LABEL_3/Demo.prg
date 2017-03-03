/*
 * HMG - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "hmg.ch"

Set Procedure To BoxLetterShow

*------------------------------------------------------------------------------*
Function Main
*------------------------------------------------------------------------------*

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 1200 HEIGHT 700 ;
		TITLE "HMG OwnerDraw Box and Letters Demo" ;
		MAIN ;
		BACKCOLOR LGREEN 

*------------------------------------------------------------------------------*
	BoxShadowL( 100, 50, "01" , " Hello, how are you? ", 10, GREEN , BLACK ) 
*------------------------------------------------------------------------------*
	
	Line( 225, 50, 175, 003 ,"02", WHITE )
	Line( 225, 225, 001, 50 ,"03", RED )
	Line( 225, 50, 003, 50 ,"04",  BLUE )
	Line( 275, 50, 175, 001 ,"05", YELLOW )
	
*------------------------------------------------------------------------------*
	Line( 360, 0, 1200, 001 ,"06",  GRAY )
	Line( 0, 280, 1, 700 ,"07",  GRAY )
*------------------------------------------------------------------------------*
	
	BoxShadow( 20, 600, 175, 058 ,"08", BLUE,  , 1 ) 
	BoxShadow( 90, 600, 175, 058 ,"09", BLUE,  , 2 ) 
	BoxShadow(160, 600, 175, 058 ,"10", BLUE,"", 3 )
	BoxShadow(230, 600, 175, 058 ,"11", BLUE,"", 4 )
	
	BoxShadow( 20, 800, 175, 058 ,"12", BLUE, BLACK , 1 ) 
	BoxShadow( 90, 800, 175, 058 ,"13", BLUE, RED   , 2 ) 
	BoxShadow(160, 800, 175, 058 ,"14", BLUE, YELLOW, 3 )
	BoxShadow(230, 800, 175, 058 ,"15", BLUE, BROWN , 4 )	

*------------------------------------------------------------------------------*

	Rectangle(50,300,175,50,"16",BLUE,1,5,1)
	Rectangle(110,300,175,50,"17",RED,2,5,1)
	Rectangle(170,300,175,50,"18",PURPLE,3,5,1)
	Rectangle(230,300,175,50,"19",YELLOW,4,5,1)
	
*------------------------------------------------------------------------------*
	MyFrame(300,300,175,50,"20","My Frame",BLUE,LGREEN)
*------------------------------------------------------------------------------*

	LetterShadow( 380, 300,"21" , "This Is a Test Line" ,10 ,BLUE )
	LetterShadow( 400, 300,"22" , "This Is a Test Line" ,10 ,GREEN )
	LetterShadow( 420, 300,"23" , "This Is a Test Line" ,20 ,PINK )
	LetterShadow( 445, 300,"24" , "This Is a Test Line" ,30 ,PURPLE )
	LetterShadow( 480, 300,"25" , "This Is a Test Line" ,40 ,ORANGE )
	LetterShadow( 525, 300,"26" , "This Is a Test Line" ,49 ,BROWN )
	LetterShadow( 580, 300,"27" , "This Is a Test Line" ,60 ,BLUE )
	
	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
