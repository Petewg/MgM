/*
   HMG Sample : 
   
     Check User Login (ID and password are 'demo')
     
   By Bicahi Esgici 
   
   August 2014 : First release
   April  2015 :
   Added : Move window anywhere on screen
           A different animation when user enter wrong ID or password
*/

#include <hmg.ch>

#define MAX_ATTEMPT 3

STATIC lConfirmed := .F.
STATIC nCursRow
STATIC nCursCol

PROCEDURE Main()

    SET WINDOW MAIN OFF
    CheckUser()  
    SET WINDOW MAIN ON

    IF lConfirmed
        DEFINE WINDOW frmMain ;
           AT 0,0 ;
           WIDTH 400 HEIGHT 400 ;
           TITLE 'Main Window' ;
           MAIN

           ON KEY ESCAPE ACTION ThisWindow.Release      

           @ 150,150  BUTTON Button_1 CAPTION "What is this ?" ;
             ACTION MsgInfo ("This is MAIN window of this program.") 
        END WINDOW

        CENTER WINDOW frmMain
        ACTIVATE WINDOW frmMain
    ENDIF

RETURN // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE CheckUser()  

    LOCAL cPictFNm := "res\FolderLock.png", nPicWidth, nPicHeight, aPicBackColor := BLACK

    IF GetImageInfo( cPictFNm, @nPicWidth, @nPicHeight )

        DEFINE WINDOW frmCheckUser;
            AT 0,0;  
            WIDTH nPicWidth;
            HEIGHT nPicHeight;
            BACKCOLOR aPicBackColor;
            NOSYSMENU;
            NOSIZE;
            NOMINIMIZE;
            NOMAXIMIZE;
            NOCAPTION;
            TOPMOST;
            CHILD ;
	    ON INIT SetCoords() ;
	    ON MOUSEDRAG MoveForm() ;
            ON MOUSEMOVE SetCoords()

	    ON KEY ESCAPE ACTION ThisWindow.Release

            @ 0, 0 IMAGE Image_1 PICTURE cPictFNm 

            @ 100,  30 LABEL   lblUserID VALUE "User ID:"  TRANSPARENT FONTCOLOR YELLOW BOLD AUTOSIZE
            @  95,  90 TEXTBOX txbUserID WIDTH 85 HEIGHT 21  FONTCOLOR BLUE BOLD ON ENTER { || frmCheckUser.txbPasswrd.SetFocus }
            @ 130,  40 LABEL   lblPaswrd VALUE "Password:" TRANSPARENT FONTCOLOR YELLOW BOLD AUTOSIZE
            @ 125, 115 TEXTBOX txbPasswrd WIDTH 85 HEIGHT 21 FONTCOLOR BLUE BOLD PASSWORD ON ENTER { || frmCheckUser.btnApply.SetFocus }

            DEFINE BUTTON btnApply 
               ROW 180
               COL 80 
               PICTURE "key32"
               TOOLTIP "Login"
               WIDTH 42 
               HEIGHT 42            
               ACTION ConfirmUser()
            END BUTTON    

        END WINDOW  // frmCheckUser

        SET WINDOW frmCheckUser TRANSPARENT TO COLOR aPicBackColor

        frmCheckUser.Cursor := "DragCurs"
        frmCheckUser.Center()
        frmCheckUser.Activate()

    ELSE
        MsgStop( cPictFNm + " image file open error ! Program aborted !", "ERROR !" )
    ENDIF

RETURN // CheckUser()     

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE ConfirmUser()

    STATIC nAttempt := 0

    LOCAL n2Right, n2Left, nRepeat
    LOCAL nColumn, nStep

    LOCAL cUserID := frmCheckUser.txbUserID.Value,;
          cPassword := frmCheckUser.txbPasswrd.Value         

    IF cUserID == "demo" .AND. cPassword == "demo"   
        MsgInfo( "Login allowed" )
        lConfirmed := .T.
        frmCheckUser.Release       
    ELSE
        IF ++nAttempt <= MAX_ATTEMPT
	    FOR nRepeat := 1 TO 3
    		    nColumn := frmCheckUser.Col 
	            FOR nStep := 1 TO 50 STEP 10
			nColumn += nStep
			ThisWindow.Col := nColumn
			INKEYGUI( 20 )
		    NEXT
	            FOR nStep := 1 TO 50 STEP 10
			nColumn := frmCheckUser.Col
			nColumn -= nStep
			ThisWindow.Col := nColumn
			INKEYGUI( 20 )
		    NEXT
            NEXT
            MsgStop( "Wrong user ID or Password !", "ERROR" )
        ELSE
            QUIT
        ENDIF
    ENDIF

RETURN // ConfirmUser()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC MoveForm()

   LOCAL nCurWRow  := frmCheckUser.Row,;
         nCurWCol  := frmCheckUser.Col

   LOCAL nCursRowC := GetCursorRow(),;
         nCursColC := GetCursorCol()

   LOCAL nDiffVert := nCursRow - nCurWRow,;
         nDiffHorz := nCursCol - nCurWCol

   nCurWRow := MAX( nCursRowC - nDiffVert, 0 )

   frmCheckUser.Row := nCurWRow

   nCurWCol := MAX( nCursColC - nDiffHorz, 0 )

   frmCheckUser.Col := nCurWCol   

   SetCoords()

RETU // MoveForm()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE SetCoords()

   nCursRow := GetCursorRow()
   nCursCol := GetCursorCol()

RETU // SetCoords() 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNCTION GetImageInfo( cPicFile, nPicWidth, nPicHeight )
   LOCAL aSize := hb_GetImageSize( cPicFile )

   nPicWidth  := aSize [1]
   nPicHeight := aSize [2]

RETURN (nPicWidth > 0) // GetImageInfo()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
