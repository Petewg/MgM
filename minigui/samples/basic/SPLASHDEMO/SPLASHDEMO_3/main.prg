/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * The idea of 2013-14 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Implementation (c) 2013-14 Grigory Filatov <gfilatov@inbox.ru>
*/

REQUEST DBFCDX

#include "minigui.ch"

/*
 * Главный модуль. Показ логотипа программы и загрузка основной формы.
 * Список функций проверки при запуске программы.
 * The main module. Logo show program and load the main form.
 * The list of features check at startup.
*/
Function Main
Local cTitle := "The MAIN form of the program"
Public aRunCheck 

   M->aRunCheck := {}
   AADD (M->aRunCheck, { "Start of programm/Запуск программы"    , "MyStart()"     , 1    } )
   AADD (M->aRunCheck, { "Dummy procedure 1"                     , "Dummy_1()"     , 0.5  } )
   AADD (M->aRunCheck, { "Dummy procedure 2"                     , "Dummy_2()"     , 0.5  } )
   AADD (M->aRunCheck, { "Opening Database:"                     , "MyOpenDbf()"   , 0.01 } ) 
   AADD (M->aRunCheck, { "Checking / copying files:"             , "MyCopyFiles()" , 2    } )
   AADD (M->aRunCheck, { "Starting the main form of the program" , "MyStart()"     , 5    } )
 
   // Проверка на запуск второй копии программы
   // Check to run a second copy of the program
   OnlyOneInstance( cTitle ) 

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE cTitle  ;
                ICON "1_MAIN" ;
		MAIN ;
		NOSHOW ;
                ON INIT MyInitForm() ; 
                ON INTERACTIVECLOSE { || MyExit(.F.) } 

	END WINDOW

	// Показ логотипа программы
        // Splash screen:   DEFINE WINDOW      PICTURE/DELAY/   ON RELEASE
        _DefineSplashWindow( "Form_Splash",,,,, "DEMO", 0.1, {|| Addition_MainForms()} )

	ACTIVATE WINDOW Form_Splash, Form_Main

Return Nil

/*
 * Проверка запуска программы на ВТОРУЮ копию программы
 * Check the start of the program on the second copy of the program
*/
Function OnlyOneInstance( cAppTitle )
Local hWnd := FindWindowEx( ,,, cAppTitle )
 
if hWnd # 0
   iif( IsIconic( hWnd ), _Restore( hWnd ), SetForeGroundWindow( hWnd ) )
   ExitProcess( 0 )
endif

Return NIL

/*
 * Показ логотипа программы.
 * Show of program's Logo.
*/
Procedure _DefineSplashWindow( name, row, col, width, height, cbitmap, nTime, Release )
Local aImgSize := BmpSize( cbitmap )  

DEFAULT row := 0, col := 0, width := aImgSize[1], height := aImgSize[2], nTime := 0.1

 	DEFINE WINDOW &name ;
		AT row, col ;
		WIDTH width HEIGHT height ;
		CHILD TOPMOST ;
		NOSIZE NOMAXIMIZE NOMINIMIZE NOSYSMENU NOCAPTION ;
		ON INIT _SplashDelay( name, nTime, aImgSize[1] ) ;
		ON RELEASE Eval( Release )

            @ 0,0 IMAGE Image_1 ;
		PICTURE cbitmap ;
		WIDTH width ;
		HEIGHT height

            // надпись под бегунком / signature on progresbar
            @ 360,25 LABEL Label_1 ;
		VALUE "" ;
		WIDTH width - 55 ;
           	HEIGHT 22 TRANSPARENT;
                FONT "Arial" SIZE 10 BOLD FONTCOLOR RED 

            @ 113,20 LABEL Label_2 ;
		VALUE "Free open source GUI: " + MiniGUIVersion()  ;
		WIDTH width - 30   ;
		HEIGHT 22 CENTERALIGN TRANSPARENT;
                FONT "Arial" SIZE 12 BOLD FONTCOLOR YELLOW
               
            @ 245,20 LABEL Label_3 ;
		VALUE "Free open source: " + Version()    ;
		WIDTH width - 30   ;
		HEIGHT 22 CENTERALIGN TRANSPARENT;
                FONT "Arial" SIZE 12 BOLD FONTCOLOR BLACK 

            @ 275,220 LABEL Label_4 ;
		VALUE hb_compiler()    ;
		WIDTH width - 30   ;
		HEIGHT 22 TRANSPARENT;
                FONT "Arial" SIZE 12 BOLD FONTCOLOR YELLOW 

		DRAW LINE IN WINDOW &name ;
			AT 0, 0 TO 0, Width ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW LINE IN WINDOW &name ;
			AT Height, 0 TO Height, Width ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW LINE IN WINDOW &name ;
			AT 0, 0 TO Height, 0 ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW LINE IN WINDOW &name ;
			AT 0, Width TO Height, Width ;
			PENCOLOR BLACK ;
			PENWIDTH 2
               
	END WINDOW

	IF EMPTY(row) .AND. EMPTY(col)
		CENTER WINDOW &name
	ENDIF

	SHOW WINDOW &name

Return

/*
* Показ бегунка и надписи. Запуск функции из списка функций проверки при запуске программы.
* Show the slider and labels. Running function from the function test is started.
*/
#define WM_PAINT	15

Procedure _SplashDelay( name, nTime, nWidthImg )
Local i, n, cRun

   SendMessage( GetFormHandle(name), WM_PAINT, 0, 0 )

   For i:=1 To LEN(M->aRunCheck)

	n := 100 / LEN(M->aRunCheck)

	SetProperty(name,"Label_1","Value",M->aRunCheck[i,1])

	cRun := Left(M->aRunCheck[i,2], len(M->aRunCheck[i,2])-1) + iif(M->aRunCheck[i,3]==NIL, "", hb_ntos(M->aRunCheck[i,3])) + ")"
	IF ! Eval( hb_macroBlock( cRun ) )
  	     MsgStop("Error")
	     QUIT
	ENDIF

	custom_progress_bar(name,335,25,nWidthImg-55,25,{255,0,0},n*i,100)
	INKEY(nTime)
	SendMessage( GetFormHandle(name), WM_PAINT, 0, 0 )

   Next

   // Удаление окна Form_Splash / Removing window Form_Splash
   DoMethod( name, 'Release' )

Return

/*
*  Функция рисования бегунка на логотипе программы
* The drawing slider on the logo program
*/
Function custom_progress_bar(cWindowName,nRow,nCol,nWidth,nHeight,aColor,nValue,nMax)
LOCAL nStartRow, nStartCol, nFinishRow, nFinishCol

// progress bar
IF nWidth > nHeight  // Horizontal Progress Bar
   nStartRow := nRow + 1
   nStartCol := nCol + 1
   nFinishRow := nRow + nHeight - 1
   nFinishCol := nCol + 1 + ((nWidth - 2) * nValue / nMax)
ELSE  // Vertical Progress Bar
   nStartRow := nRow + nHeight - 1
   nStartCol := nCol + 1
   nFinishRow := nStartRow - ((nHeight - 2) * nValue / nMax)
   nFinishCol := nCol + nWidth - 1
ENDIF

DRAW RECTANGLE IN WINDOW &cWindowName AT nStartRow,nStartCol TO nFinishRow,nFinishCol PENCOLOR aColor FILLCOLOR aColor

Return NIL

/////////////////////////////////////////////////////////////////////
// Инициализация моих переменных для программы (пример)
// Initialize variables for my program (example)
INIT PROCEDURE MyInitWin()   
   LOCAL cFileIni, cPath

   MEMVAR cPubMainFolder, aDirFrom, aDirTo
   MEMVAR aBtnColor
   PUBLIC cPubMainFolder, aDirFrom := {}, aDirTo := {}
   PUBLIC aBtnColor := WHITE

   SET EPOCH TO ( Year(Date()) - 50 )
   SET DATE FORMAT "DD.MM.YYYY"
   SET TOOLTIP BALLOON ON
   //SET LANGUAGE TO RUSSIAN  
   //SET CODEPAGE TO RUSSIAN  
   RDDSETDEFAULT('DBFCDX')

   // Узнаём текущий путь программы / Know the current path of the program
   cPath := GetStartUpFolder()+"\"
   M->cPubMainFolder := cPath

   cFileIni := ChangeFileExt( Application.ExeName, ".ini" )
   M->cPubFileIni := cFileIni

   // Чтение параметров из INI-файла / Reading of INI-file
   //ReadIniFile( cFileIni, cPath )

RETURN
////////////////////////////////////////////////////////////
// Меню выхода из программы - Exit programm
FUNCTION MyExit( lClose )          
   LOCAL cMess, lExit

   cMess := ';    Do you really want to exit? '+SPACE(20)+' ; ;'
   cMess := AtRepl( ";", cMess, CRLF )
   lExit := MsgYesNo( cMess, "Exit", .F.,, .F. )
   IF lExit .AND. lClose
      Form_Main.Release
   ENDIF

RETURN lExit
