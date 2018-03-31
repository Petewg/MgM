/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * The idea of 2013 Verchenko Andrey <verchenkoag@gmail.com>
*/

/////////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
Function MyStart(xVal)
	INKEY(xVal)
Return .t.

/////////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
Function Dummy_1(xVal)
	INKEY(xVal)
Return .t.

/////////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
Function Dummy_2(xVal)
	INKEY(xVal)
Return .t.

/////////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
Function MyOpenDbf(xVal)
Local aFilesDbf := {}, nI, cVal

      AADD ( aFilesDbf, "Base01.dbf" )
      AADD ( aFilesDbf, "Base02.dbf" )
      AADD ( aFilesDbf, "Base03.dbf" )
      AADD ( aFilesDbf, "Base04.dbf" )

      cVal := GetProperty("Form_Splash","Label_1","Value") 
      For nI := 1 TO LEN(aFilesDbf)  
          SetProperty("Form_Splash","Label_1","Value",cVal + "->" + aFilesDbf[nI])
          INKEY(xVal)
      NEXT

      INKEY(1)
Return .T.

/////////////////////////////////////////////////////////////////////
// Эта функция заготовка (сделать самостоятельно)
// This function is blank (do it yourself)
Function MyCopyFiles(xVal)
Local aFiles := {}, nI, cVal, cMask := "Rep-"

      For nI := 1 TO 5
          AADD ( aFiles, cMask + StrZero(nI,6) + ".txt" )
      NEXT

      cVal := GetProperty("Form_Splash","Label_1","Value") 
      For nI := 1 TO LEN(aFiles)
          SetProperty("Form_Splash","Label_1","Value",cVal + "->" + aFiles[nI])
          INKEY(0.1)
      NEXT
 
      INKEY(xVal)
Return .T.
