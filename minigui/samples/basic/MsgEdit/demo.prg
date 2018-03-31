/*
 * MiniGUI MsgEdit, MsgDate, MsgCopy, MsgMove, MsgDelete, MsgPostIt, 
 * MsgDesktop, MsgOptions, MsgLogo, MsgToolTip Demo
 * (c) 2007-2011 Grigory Filatov
 *
 * Functions MsgEdit(), MsgDate(), MsgCopy(), MsgMove(), MsgDelete(), 
 * MsgPostIt(), MsgDesktop(), MsgOptions(), MsgLogo(), MsgToolTip() for Xailer
 * Author: Bingen Ugaldebere
 * Final revision: 07/11/2006
*/

#include "minigui.ch"
#include "shell32.ch"

//#define _INPUTMASK_

#define BM_WIDTH     1
#define BM_HEIGHT    2
*-------------------------------------------------------------
Procedure Main
*-------------------------------------------------------------

	SET DATE FORMAT "dd-MM-yyyy" // the month mask in uppercase is important for DATEPICKER's format

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'MsgEdit Demo' ;
		ICON "demo.ico" ;
		MAIN ;
		NOMAXIMIZE NOSIZE

		@ 30, 90 FRAME Frame_1 ;
			CAPTION '' ;
			WIDTH  220 ;
			HEIGHT 265

		@ 50 ,100 BUTTON Button_1 ;
			CAPTION "Edit for Text" ;
			ACTION Click_1() ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 100 ,100 BUTTON Button_2 ;
			CAPTION "Edit for Password" ;
			ACTION Click_2() ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 150 ,100 BUTTON Button_3 ;
			CAPTION "Edit for Date" ;
			ACTION Click_3() ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 200 ,100 BUTTON Button_4 ;
			CAPTION "Edit for Numeric" ;
			ACTION Click_4() ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 250 ,100 BUTTON Button_5 ;
			CAPTION "Edit for Logical" ;
			ACTION Click_5() ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 30, 390 FRAME Frame_2 ;
			CAPTION '' ;
			WIDTH  120 ;
			HEIGHT 365

		@ 50 ,400 BUTTON Button_6 ;
			CAPTION "MsgDate" ;
			ACTION Click_6() ;
	                WIDTH 100 ;
			HEIGHT 30

		@ 100 ,400 BUTTON Button_7 ;
			CAPTION "MsgCopy" ;
			ACTION Click_7() ;
	                WIDTH 100 ;
			HEIGHT 30

		@ 150 ,400 BUTTON Button_8 ;
			CAPTION "MsgMove" ;
			ACTION Click_8() ;
	                WIDTH 100 ;
			HEIGHT 30

		@ 200 ,400 BUTTON Button_9 ;
			CAPTION "MsgDelete" ;
			ACTION Click_9() ;
	                WIDTH 100 ;
			HEIGHT 30

		@ 250 ,400 BUTTON Button_10 ;
			CAPTION "MsgPostIt" ;
			ACTION Click_10() ;
	                WIDTH 100 ;
			HEIGHT 30

		@ 300 ,400 BUTTON Button_11 ;
			CAPTION "MsgDesktop" ;
			ACTION Click_11() ;
	                WIDTH 100 ;
			HEIGHT 30

		@ 350 ,400 BUTTON Button_12 ;
			CAPTION "MsgOptions" ;
			ACTION Click_12() ;
	                WIDTH 100 ;
			HEIGHT 30

		@ 330, 90 FRAME Frame_3 ;
			CAPTION '' ;
			WIDTH  220 ;
			HEIGHT 65

		@ 350 ,100 BUTTON Button_13 ;
			CAPTION "MsgLogo" ;
			ACTION Click_13() ;
	                WIDTH 95 ;
			HEIGHT 30

		@ 350 ,205 BUTTON Button_14 ;
			CAPTION "MsgToolTip" ;
			ACTION Click_14() ;
	                WIDTH 95 ;
			HEIGHT 30
	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

#define MsgInfo( c ) MsgInfo( c, , , .f. )

*-------------------------------------------------------------
Procedure Click_1
*-------------------------------------------------------------
Local cNombre:="Bingen Ugaldebere                       "

   If MsgEdit("Teclee su nombre o confirme el actual", "Ejemplo de MsgEdit", @cNombre, "Users.Bmp")
      MsgInfo("El nombre tecleado es "+Trim(cNombre))
   Else
      MsgInfo("Ha salido cancelando la ventana")
   Endif

Return

*-------------------------------------------------------------
Procedure Click_2
*-------------------------------------------------------------
Local cPassword:=Space(5)

   If MsgEdit("Teclee la contraseña", , @cPassword, "Gear.Bmp",.T.,.T.)
      MsgInfo("La contraseña tecleada es "+cPassword)
   Else
      MsgInfo("Ha salido cancelando la ventana")
   Endif

Return

*-------------------------------------------------------------
Procedure Click_3
*-------------------------------------------------------------
Local dFecha:=Date(), uFecha:={Date(),Date()-1,Date()+1}

   If MsgEdit("Teclee la fecha deseada", , @dFecha, "Gear.Bmp")
      MsgInfo("La Fecha es "+ToString(dFecha))
   Else
      MsgInfo("Ha salido cancelando la ventana")
   Endif

   // Date with limites
   If MsgEdit("Teclee la fecha deseada entre ayer y mañana, ambos inclusive", , @uFecha, "Gear.Bmp")
      MsgInfo("La Fecha es "+ToString(uFecha))
   Else
      MsgInfo("Ha salido cancelando la ventana")
   Endif

Return

*-------------------------------------------------------------
Procedure Click_4
*-------------------------------------------------------------
Local nValor:=123.45, uValor:={0,1,1000}
#ifdef _INPUTMASK_
   Local cPict1:="9,999.99", cPict2:="9,999"
#else
   Local cPict1:="@E 9,999.99", cPict2:="@E 9,999"
#endif

   If MsgEdit("Teclee el importe deseado", , @nValor, "Gear.Bmp",,,cPict1)
      MsgInfo("El importe es "+ToString(nValor))
   Else
      MsgInfo("Ha salido cancelando la ventana")
   Endif

   // Value with limites
   If MsgEdit("Teclee el importe deseado de 1 a 1000", , @uValor, "Gear.Bmp",,,cPict2)
      MsgInfo("El valor tecleado es "+ToString(uValor))
   Else
      MsgInfo("Ha salido cancelando la ventana")
   Endif

Return

*-------------------------------------------------------------
Procedure Click_5
*-------------------------------------------------------------
Local lLogico:=.F.

   If MsgEdit("Esta seguro de esto", , @lLogico, "Gear.Bmp")
      MsgInfo("Pues va a ser que "+If(lLogico,"Si","No"))
   Else
      MsgInfo("Ha salido cancelando la ventana")
   Endif

Return

*-------------------------------------------------------------
Procedure Click_6
*-------------------------------------------------------------
Local dIni:=Date(), dFin:=Date()+30

   If MsgDate(,"Establezca fechas de consulta",@dIni,@dFin,,,"Gear.Bmp")
      MsgInfo("El intervalo es de "+Alltrim(Str(dFin-dIni))+" días")
   Else
      MsgInfo("Ha salido cancelando la ventana")
   Endif

Return

*-------------------------------------------------------------
Procedure Click_7
*-------------------------------------------------------------

   If MsgCopy("*.*", GetStartupFolder()+"\Copia")
      MsgInfo("Se han copia los archivos de la carpeta a la carpeta \Copia creada dentro de la carpeta del programa")
   Else
      MsgInfo("Error. No se ha podido llevar a cabo la operación de copiado")
   Endif

Return

*-------------------------------------------------------------
Procedure Click_8
*-------------------------------------------------------------

   If MsgMove("Prueba.Doc", GetStartupFolder()+"\Documentación\Prueba.Doc")
      MsgInfo("Se ha movido el documento Prueba.Doc a la carpeta \Documentación que ha sido creada")
   Else
      MsgInfo("Error. No se ha podido llevar a cabo la operación de mover archivos")
   Endif

Return

*-------------------------------------------------------------
Procedure Click_9
*-------------------------------------------------------------

   If MsgDelete(GetStartupFolder()+"\Documentación\*.*",,,.F.)
      MsgInfo("Se ha borrado el contenido de la carpeta \Documentación")
   Else
      MsgInfo("Error. No se ha podido llevar a cabo la operación de borrado")
   Endif

Return

*-------------------------------------------------------------
Procedure Click_10
*-------------------------------------------------------------

   MsgPostIt(space(590)+"Cita con el cliente."+CRLF+CRLF+;
             "Llevar un prototipo válido del programa, si es posible, para "+;
             "que parezca que esta muy elaborado y de esta manera el cliente "+;
             "no se mosquee por el tiempo que llevamos sin ir a verle.",,,.F.)

   MsgPostIt(space(330)+"Cita con el cliente."+CRLF+CRLF+;
             "Este mensaje lleva una imagen que es opcional a la izquierda y por lo "+;
             "tanto el texto sale algo desplazado a la derecha."+CRLF+CRLF+;
             "Además incluye parpadeo para llamar más la atención del usuario",,"Users.Bmp",,{128, 255, 216} )

Return

*-------------------------------------------------------------
Procedure Click_11
*-------------------------------------------------------------

  MsgDesktop(space(250)+"Mensaje sobre el escritorio."+CRLF+CRLF+;
             "Este mensaje se muestra fuera del form de la aplicación sobre el escritorio "+;
             "así que permanece incluso si el form de la aplicación ha sido cerrada "+;
             "ya que en realidad pertenece al escritorio."+CRLF+CRLF+;
             "En realidad es un form al mismo nivel que el form principal de la aplicación "+;
             "de forma que la aplicación global no se cierra hasta que se cierren "+;
             "todos los formularios.",,"Users.Bmp")

Return

*-------------------------------------------------------------
Procedure Click_12
*-------------------------------------------------------------
   Local nOption:=0

   nOption:=MsgOptions(, , "Users.Bmp" , {"&Imprimir","&Mandar a la porra","&Enviar por email","&Destruir"}, 2, 20 )

   MsgInfo("Ha seleccionado la opción "+Alltrim(Str(nOption)) )

Return

*-------------------------------------------------------------
Procedure Click_13
*-------------------------------------------------------------

   MsgLogo("..\SPLASHDEMO\Demo.Bmp")
   MsgLogo("Splash.jpg", 6, .T.)

Return

#define COLOR_INFOBK     24
*-------------------------------------------------------------
Procedure Click_14
*-------------------------------------------------------------
Local ControlName:=This.Name, ParentName:=ThisWindow.Name
Local nIdx:=GetControlIndex( ControlName, ParentName )
Local nColor:=GetSysColor( COLOR_INFOBK )
Local aColor:={GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor )}

   MsgToolTip(nIdx, "Prueba de tooltip"+CRLF+"Multilinea", "Titulo", aColor)

Return

*-------------------------------------------------------------
STATIC FUNCTION ToString( xValue )
*-------------------------------------------------------------
LOCAL cType := ValType( xValue )
LOCAL cValue := "", nDecimals := Set( _SET_DECIMALS)

   DO CASE
      CASE cType $  "CM";  cValue := xValue
      CASE cType == "N" ;  nDecimals := iif( xValue == int(xValue), 0, nDecimals) ; cValue := LTrim( Str( xValue, 20, nDecimals ) )
      CASE cType == "D" ;  cValue := DToC( xValue )
      CASE cType == "L" ;  cValue := IIf( xValue, "T", "F" )
      CASE cType == "A" ;  cValue := AToC( xValue )
      CASE cType $  "UE";  cValue := "NIL"
      CASE cType == "B" ;  cValue := "{|| ... }"
      CASE cType == "O" ;  cValue := "{" + xValue:className + "}"
   ENDCASE

RETURN cValue


/*
 * MsgEdit([cText], [cTitle], uVar, [cImage], [lPassWord], [lNoCancel], [cPicture])
*/

Function MsgEdit(cText, cTitle, uVar, cImage, lPassWord, lNoCancel, cPicture)
   Local uLimitInf, uLimitSup, aImgInfo, cDateFormat := Set(_SET_DATEFORMAT)

   Default cText     To "Introduzca un valor"
   Default cTitle    To _HMG_MESSAGE [5]
   Default cImage    To ""
   Default lPassWord To .F.
   Default lNoCancel To .F.
#ifdef _INPUTMASK_
   Default cPicture  To "999,999.99"
#else
   Default cPicture  To "@E 999,999.99"
#endif

   If Valtype(uVar)="A"
      Asize(uVar,3)
      uLimitInf:=uVar[2]
      uLimitSup:=uVar[3]
      uVar:=uVar[1]
   Endif

   DEFINE WINDOW _EditForm ;
      AT 0,0               ;
      WIDTH 320            ;
      HEIGHT 150           ;
      TITLE cTitle         ;
      ICON "demo.ico"      ;
      MODAL                ;
      NOSIZE               ;
      FONT 'MS Sans Serif' ;
      SIZE 9

      ON KEY ESCAPE ACTION ( _HMG_DialogCancelled := .T. , _EditForm.Release )

      If lPassWord
         @ 10, 10 LABEL _Label VALUE cText WIDTH 295 TRANSPARENT
         @ 40, 10 TEXTBOX _TextBox VALUE '' WIDTH 295 HEIGHT 25 PASSWORD ;
                 ON ENTER _EditForm._Ok.OnClick
      Else
         DO Case
            Case ValType(uVar)=="C"
               @ 10, 10 LABEL _Label VALUE cText WIDTH 295 TRANSPARENT
               @ 40, 10 TEXTBOX _TextBox VALUE uVar WIDTH 295 HEIGHT 25 MAXLENGTH Len(uVar) ;
                 ON ENTER _EditForm._Ok.OnClick

            Case ValType(uVar)=="N"
               @ 10, 10 LABEL _Label VALUE cText WIDTH 295 TRANSPARENT
#ifdef _INPUTMASK_
               @ 40,105 TEXTBOX _TextBox VALUE uVar WIDTH 120 HEIGHT 25 NUMERIC INPUTMASK cPicture ;
                 ON ENTER _EditForm._Ok.OnClick
#else
               @ 40,105 GETBOX _TextBox VALUE uVar WIDTH 120 HEIGHT 25 PICTURE cPicture
                 ON KEY RETURN ACTION _EditForm._Ok.OnClick
#endif
            Case ValType(uVar)=="D"
               If Len(cText) < 40
                  cText := CRLF+cText
               Endif
               @ 17, 30 LABEL _Label VALUE cText WIDTH 140 HEIGHT 45 TRANSPARENT
               @ 25,170 DATEPICKER _TextBox VALUE uVar WIDTH 95 HEIGHT 25 DATEFORMAT cDateFormat ;
                 ON ENTER _EditForm._Ok.OnClick

            Case ValType(uVar)=="L"
               @ 35, 15 CHECKBOX _TextBox CAPTION " "+cText VALUE uVar WIDTH 260 HEIGHT 25 TRANSPARENT
                 ON KEY RETURN ACTION _EditForm._Ok.OnClick

            OtherWise
               MsgInfo("No se puede editar un valor de tipo "+Valtype(uVar))
         EndCase
      Endif

      If !Empty(cImage)
         aImgInfo := BmpSize(cImage)
         If !Empty(aImgInfo [BM_WIDTH])
           @ 70, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
         Endif
      Endif

      If lNoCancel
         @ 80,120 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
                   ACTION If(ValType(uVar)<>"L", ;
                              ( If(MsgEditValid(_EditForm._TextBox.Value, uLimitInf, uLimitSup),;
                                  (_HMG_DialogCancelled := .F. , uVar := _EditForm._TextBox.Value , _EditForm.Release),;
                                  _EditForm._TextBox.SetFocus) ),;
                                  (_HMG_DialogCancelled := .F. , uVar := _EditForm._TextBox.Value , _EditForm.Release))
      Else
         @ 80, 60 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
                   ACTION If(ValType(uVar)<>"L", ;
                              ( If(MsgEditValid(_EditForm._TextBox.Value, uLimitInf, uLimitSup),;
                                  (_HMG_DialogCancelled := .F. , _EditForm._Ok.SetFocus, uVar := _EditForm._TextBox.Value , _EditForm.Release),;
                                  _EditForm._TextBox.SetFocus) ),;
                                  (_HMG_DialogCancelled := .F. , uVar := _EditForm._TextBox.Value , _EditForm.Release))

         @ 80,180 BUTTON _Cancel CAPTION "&"+_HMG_MESSAGE [7] WIDTH 80 HEIGHT 25 ;
                   ACTION ( _HMG_DialogCancelled := .T. , _EditForm.Release )
      Endif

   END WINDOW

   CENTER WINDOW _EditForm

   ACTIVATE WINDOW _EditForm

Return !(_HMG_DialogCancelled)

*-------------------------------------------------------------
Static Function MsgEditValid(uValue, uLimitInf, uLimitSup)
*-------------------------------------------------------------

   If uLimitInf==Nil .And. uLimitSup==Nil
      Return .T.
   Endif

   If uLimitInf<>Nil .And. uValue<uLimitInf
      MsgInfo("El límite inferior es "+ToString( uLimitInf ),"Valor incorrecto")
      Return .F.
   Endif

   If uLimitSup<>Nil .And. uValue>uLimitSup
      MsgInfo("El límite superior es "+ToString( uLimitSup ),"Valor incorrecto")
      Return .F.
   Endif

Return .T.

/*
 * MsgDate([cText], [cTitle], @uVarIni, @uVarFin, [cTextIni], [cTextFin], [cImage], [lNoCancel])
*/

Function MsgDate(cText, cTitle, uVarIni, uVarFin, cTextIni, cTextFin, cImage, lNoCancel)
   Local cDateFormat := Set(_SET_DATEFORMAT), aImgInfo
/*
   Default cText     To "Limites of dates"
   Default cTitle    To "Introduce dates"
   Default cTextIni  To "FROM ........................"
   Default cTextFin  To "T0 .........................."
*/
   Default cText     To "Límites de fechas"
   Default cTitle    To "Introduzca fechas"
   Default cTextIni  To "DESDE ......................."
   Default cTextFin  To "HASTA ......................."
   Default lNoCancel To .F.

   DEFINE WINDOW _DateForm ;
      AT 0,0               ;
      WIDTH 320            ;
      HEIGHT 175           ;
      TITLE cTitle         ;
      ICON "demo.ico"      ;
      MODAL                ;
      NOSIZE               ;
      FONT 'MS Sans Serif' ;
      SIZE 9

      ON KEY ESCAPE ACTION ( _HMG_DialogCancelled := .T. , _DateForm.Release )

      @ 10, 10 LABEL _Label VALUE cText WIDTH 295 HEIGHT 35 TRANSPARENT

      @ 43, 10 LABEL _LabelIni VALUE cTextIni WIDTH 155 HEIGHT 25 TRANSPARENT
      @ 73, 10 LABEL _LabelFin VALUE cTextFin WIDTH 155 HEIGHT 25 TRANSPARENT

      @ 40,170 DATEPICKER _TextBox_1 VALUE uVarIni WIDTH 90 HEIGHT 25 DATEFORMAT cDateFormat ;
		ON ENTER _DateForm._Ok.OnClick

      @ 70,170 DATEPICKER _TextBox_2 VALUE uVarFin WIDTH 90 HEIGHT 25 DATEFORMAT cDateFormat ;
		ON ENTER _DateForm._Ok.OnClick

      If !Empty(cImage)
         aImgInfo := BmpSize(cImage)
         If !Empty(aImgInfo [BM_WIDTH])
           @ 100, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
         Endif
      Endif

      If lNoCancel
         @ 110,120 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
                   ACTION ( _HMG_DialogCancelled := .F. , ;
			uVarIni := Min( _DateForm._TextBox_1.Value , _DateForm._TextBox_2.Value ) , ;
			uVarFin := Max( _DateForm._TextBox_1.Value , _DateForm._TextBox_2.Value ) , _DateForm.Release )
      Else
         @ 110, 60 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
                   ACTION ( _HMG_DialogCancelled := .F. , ;
			uVarIni := Min( _DateForm._TextBox_1.Value , _DateForm._TextBox_2.Value ) , ;
			uVarFin := Max( _DateForm._TextBox_1.Value , _DateForm._TextBox_2.Value ) , _DateForm.Release )

         @ 110,180 BUTTON _Cancel CAPTION "&"+_HMG_MESSAGE [7] WIDTH 80 HEIGHT 25 ;
                   ACTION ( _HMG_DialogCancelled := .T. , _DateForm.Release )
      Endif

   END WINDOW

   CENTER WINDOW _DateForm

   ACTIVATE WINDOW _DateForm

Return !(_HMG_DialogCancelled)

/*
 * MsgCopy([acOrigName], [acDestName], [cTitle], [lFilesOnly], [lDeleteIfExist], [lAlarm]) 
*/

Function MsgCopy(acOrigName, acDestName, cTitle, lFilesOnly, lOkToAll, lAlarm )
   Local aFrom:={}, aTo:={}, lResult:=.F., nFlag:=0

   Default cTitle          To ""
   DEFAULT acOrigName      To ""
   DEFAULT acDestName      To ""
   DEFAULT lFilesOnly      To .T.
   DEFAULT lOkToAll        To .T.
   DEFAULT lAlarm          To .F.

   //Cargar los Array
   If ValType(acOrigName)="C"
      Aadd(aFrom,acOrigName)
   ElseIf ValType(acOrigName)="A"
      aFrom:=acOrigName
   Endif
   If ValType(acDestName)="C"
      Aadd(aTo,acDestName)
   ElseIf ValType(acDestName)="A"
      aTo:=acDestName
   Endif

   If lFilesOnly
      nFlag+=FOF_FILESONLY
   Endif
   If lOkToAll
      nFlag+=FOF_NOCONFIRMATION
      nFlag+=FOF_NOCONFIRMMKDIR
   Endif
   If lAlarm
      nFlag+=FOF_NOERRORUI
   Endif

   lResult:=( ShellFiles( , aFrom, aTo, FO_COPY, nFlag ) == 0 )

Return lResult

/*
 * MsgMove([acOrigName], [acDestName], [cTitle], [lFilesOnly], [lDeleteIfExist], [lAlarm]) 
*/

Function MsgMove(acOrigName, acDestName, cTitle, lFilesOnly, lOkToAll, lAlarm )
   Local aFrom:={}, aTo:={}, lResult:=.F., nFlag:=0

   Default cTitle          To ""
   DEFAULT acOrigName      To ""
   DEFAULT acDestName      To ""
   DEFAULT lFilesOnly      To .T.
   DEFAULT lOkToAll        To .T.
   DEFAULT lAlarm          To .F.

   //Cargar los Array
   If ValType(acOrigName)="C"
      Aadd(aFrom,acOrigName)
   ElseIf ValType(acOrigName)="A"
      aFrom:=acOrigName
   Endif
   If ValType(acDestName)="C"
      Aadd(aTo,acDestName)
   ElseIf ValType(acDestName)="A"
      aTo:=acDestName
   Endif

   If lFilesOnly
      nFlag+=FOF_FILESONLY
   Endif
   If lOkToAll
      nFlag+=FOF_NOCONFIRMATION
      nFlag+=FOF_NOCONFIRMMKDIR
   Endif
   If lAlarm
      nFlag+=FOF_NOERRORUI
   Endif

   lResult:=( ShellFiles( , aFrom, aTo, FO_MOVE, nFlag ) == 0 )

Return lResult

/*
 * MsgDelete([acOrigName], [cTitle], [lFilesOnly], [lDeleteIfExist], [lAlarm])
*/

Function MsgDelete(acOrigName, cTitle, lFilesOnly, lOkToAll, lAlarm )
   Local aFrom:={}, lResult:=.F., nFlag:=0

   Default cTitle          To ""
   DEFAULT acOrigName      To ""
   DEFAULT lFilesOnly      To .T.
   DEFAULT lOkToAll        To .T.
   DEFAULT lAlarm          To .F.

   //Cargar los Array
   If ValType(acOrigName)="C"
      Aadd(aFrom,acOrigName)
   ElseIf ValType(acOrigName)="A"
      aFrom:=acOrigName
   Endif

   If lFilesOnly
      nFlag+=FOF_FILESONLY
   Endif
   If lOkToAll
      nFlag+=FOF_NOCONFIRMATION
   Endif
   If lAlarm
      nFlag+=FOF_NOERRORUI
   Endif

   lResult:=( ShellFiles( , aFrom, , , nFlag ) == 0 )

Return lResult

/*
 * MsgOptions([cText], [cTitle], [cImage], aOptions, [nDefaultOption], [nSeconds])
*/

Function MsgOptions(cText, cTitle, cImage, aOptions, nDefaultOption, nSeconds )
   Local nItem:=0, nBtnWidth:=0, aBtn:=Array(Len(aOptions)), aImgInfo
   Local nBtnPosX:=10, nBtnPosY:=85, cOption:=""

   Default cText           To "Seleccione una opción..."
   Default cTitle          To UPPER(_HMG_BRWLangError [10])+"!"
   Default cImage          To ""
   Default nDefaultOption  To 1
   Default nSeconds        To 0

   DEFINE FONT _Font_Options FONTNAME "MS Sans Serif" SIZE 9

   //Calcular anchura máxima de un botón para igualarlos todos
   For nItem:=1 To Len(aOptions)
      aOptions[nItem]:=Alltrim(aOptions[nItem])
      nBtnWidth:=Max( GetTextWidth(, aOptions[nItem], GetFontHandle("_Font_Options")), nBtnWidth )
   Next
   nBtnWidth+=5

   DEFINE WINDOW _Options  ;
      AT 0,0               ;
      WIDTH (Len(aOptions)*(10+nBtnWidth))+15 ;
      HEIGHT 155           ;
      TITLE cTitle         ;
      ICON "demo.ico"      ;
      MODAL                ;
      NOSIZE               ;
      ON RELEASE IF( IsControlDefined( Timer_1, _Options ), _Options.Timer_1.Release, )

      ON KEY ESCAPE ACTION _Options.Release

      If !Empty(cImage)
         aImgInfo := BmpSize(cImage)
         If !Empty(aImgInfo [BM_WIDTH])
           @ 20, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
           @ 40, 55 LABEL _Label VALUE cText WIDTH (Len(aOptions)*(10+nBtnWidth))-50 HEIGHT 30 ;
             TRANSPARENT CENTERALIGN FONT "_Font_Options"
         Endif
      Else
           @ 40, 10 LABEL _Label VALUE cText WIDTH (Len(aOptions)*(10+nBtnWidth))-10 HEIGHT 30 ;
             TRANSPARENT CENTERALIGN FONT "_Font_Options"
      Endif

      For nItem:=1 To Len(aOptions)
         aBtn[nItem]:="_Btn_"+Ltrim(Str(nItem))
         cOption:=aBtn[nItem]
         @ nBtnPosY, nBtnPosX BUTTON &cOption CAPTION aOptions[nItem] WIDTH nBtnWidth HEIGHT 25 FONT "_Font_Options" ;
                   ACTION ( cOption:=GetProperty("_Options", This.Name, "Caption"), _Options.Release )
         nBtnPosX+=nBtnWidth+10
      Next

      DoMethod("_Options", aBtn[nDefaultOption], "SetFocus")

      If nSeconds>0
         DEFINE TIMER Timer_1 Interval nSeconds*1000  ;
                ACTION ( cOption:=aOptions[nDefaultOption], _Options.Release )
      Endif

   END WINDOW

   CENTER WINDOW _Options

   ACTIVATE WINDOW _Options

   RELEASE FONT _Font_Options

Return Ascan(aOptions,Alltrim(cOption))

/*
 * MsgLogo(cImage, [nSeconds])
*/

Function MsgLogo( cImage, nSeconds, lRound )

Local aImgInfo:=GetImageSize(cImage), width, height

Default nSeconds To 5, lRound To .F.

   If .Not. IsWindowDefined( _Logo )
      If .Not. Empty( aImgInfo [BM_WIDTH] )

         width := aImgInfo [BM_WIDTH] + GetBorderWidth()
         height:= aImgInfo [BM_HEIGHT] + GetBorderHeight()

         DEFINE WINDOW _Logo   ;
            AT 0,0             ;
            WIDTH width        ;
            HEIGHT height      ;
            CHILD TOPMOST      ;
            NOCAPTION          ;
            ON SIZE (_Logo.Width:=width, _Logo.Height:=height ) ;
            ON MOUSECLICK _Logo.Release

            @ 0, 0 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]

            DEFINE TIMER Timer_1 INTERVAL nSeconds*1000 ACTION _Logo.Release

         END WINDOW

         If lRound
            SET REGION OF _Logo ROUNDRECT 68,68,width,height
         Endif

         CENTER WINDOW _Logo

         ACTIVATE WINDOW _Logo

      Else
         MsgInfo("No se ha podido llevar a cabo la operación", "Error")
      Endif
   Endif

Return Nil

*-------------------------------------------------------------
Static Function GetImageSize( cImagePath )
*-------------------------------------------------------------
Local aRetArr

   If Upper( Right( cImagePath, 4 ) ) == ".BMP"

	aRetArr := BmpSize( cImagePath )

   Else

	aRetArr := hb_GetImageSize( cImagePath )

   Endif

Return aRetArr

/*
 * MsgDesktop([cText], [cTitle], [cImage], [lFlash])
*/

Function MsgDesktop(cText, cTitle, cImage, lFlash)

Local aImgInfo

   Default cText     To ""
   Default cTitle    To UPPER(_HMG_BRWLangError [10])+"!"
   Default cImage    To ""
   Default lFlash    To .T.

   If .Not. IsWindowDefined( _Desktop )

      DEFINE WINDOW _Desktop   ;
         AT 0,0                ;
         WIDTH 330             ;
         HEIGHT 290            ;
         TITLE cTitle          ;
         ICON "demo.ico"       ;
         NOMAXIMIZE NOMINIMIZE ;
         NOSIZE                ;
         ON RELEASE IF( IsControlDefined( Timer_1, _Desktop ), _Desktop.Timer_1.Release, ) ;
         FONT 'MS Sans Serif'  ;
         SIZE 9

         ON KEY ESCAPE ACTION _Desktop.Release

         If !Empty(cImage)
            aImgInfo := BmpSize(cImage)
            If !Empty(aImgInfo [BM_WIDTH])
              @ 5, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
              @ 20, 55 LABEL _Label VALUE cText WIDTH 250 HEIGHT 250 TRANSPARENT
            Endif
         Else
            @ 20, 10 LABEL _Label VALUE cText WIDTH 295 HEIGHT 250 TRANSPARENT
         Endif

         If lFlash
            DEFINE TIMER Timer_1 INTERVAL 500 ACTION FlashWindow( GetFormHandle('_Desktop') )
         Endif

      END WINDOW

      CENTER WINDOW _Desktop

      ACTIVATE WINDOW _Desktop

   Endif

Return Nil

/*
 * MsgPostIt([cText], [cTitle], [cImage], [lFlash], [aColor])
*/

Function MsgPostit(cText, cTitle, cImage, lFlash, aColor)

Local aImgInfo

   Default cText     To ""
   Default cTitle    To UPPER(_HMG_BRWLangError [10])+"!"
   Default cImage    To ""
   Default lFlash    To .T.
   Default aColor    To YELLOW

   DEFINE WINDOW _Postit   ;
      AT 0,0               ;
      WIDTH 320            ;
      HEIGHT 280           ;
      TITLE cTitle         ;
      ICON "demo.ico"      ;
      MODAL                ;
      NOSIZE               ;
      BACKCOLOR aColor     ;
      ON RELEASE IF( IsControlDefined( Timer_1, _Postit ), _Postit.Timer_1.Release, ) ;
      FONT 'MS Sans Serif' ;
      SIZE 9

      If !Empty(cImage)
         aImgInfo := BmpSize(cImage)
         If !Empty(aImgInfo [BM_WIDTH])
           @ 5, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
           @ 20, 55 LABEL _Label VALUE cText WIDTH 250 HEIGHT 250 TRANSPARENT
         Endif
      Else
           @ 20, 10 LABEL _Label VALUE cText WIDTH 295 HEIGHT 250 TRANSPARENT
      Endif

      If lFlash
           DEFINE TIMER Timer_1 INTERVAL 500 ACTION FlashWindow( GetFormHandle('_Postit') )
      Endif

   END WINDOW

   CENTER WINDOW _Postit

   ACTIVATE WINDOW _Postit

Return Nil

*-------------------------------------------------------------
STATIC PROCEDURE FlashWindow( hWnd )
*-------------------------------------------------------------
Static	nStatus := 0
	IF IsWindowVisible( hWnd )
		FlashWnd( hWnd, (nStatus := IF( nStatus == 1, 0, 1 )) )
	ENDIF
RETURN

DECLARE DLL_TYPE_LONG FlashWindow( DLL_TYPE_LONG hWnd, DLL_TYPE_LONG nInvert ) ;
	IN USER32.DLL ;
	ALIAS FlashWnd

/*
 * MsgToolTip(nSender, cText, [cTitle], [aColor])
*/

Function MsgToolTip(nSender, cText, cTitle, aColor)
   Local FontHandle, FormIndex, FormName, ControlName
   Local nWidth, nHeight:=14*1.2, n:=1, nSeconds:=3, nLines:=1

   Default cText  To ""
   Default cTitle To ""
   Default aColor To YELLOW

   cText          :=Alltrim(cText)
   cTitle         :=Alltrim(cTitle)

   FormIndex := ascan ( _HMG_aFormHandles , _HMG_aControlParentHandles[nSender] )
   FormName := _HMG_aFormNames [ FormIndex ]
   ControlName := _HMG_aControlNames [ nSender ]

   DEFINE FONT _Font_ToolTip FONTNAME "MS Sans Serif" SIZE 9
   FontHandle:=GetFontHandle("_Font_ToolTip")

   //Calcular tamaño respecto al fuente
   For n:=1 to Mlcount(cText)
        nWidth:=Max( GetTextWidth(, Alltrim( Memoline(cText,n) ), FontHandle), GetTextWidth(, cTitle, FontHandle) )+60
   Next
   nWidth:=If( nWidth>=GetDesktopWidth(), GetProperty(FormName, "Width")-60, nWidth )
   nLines:=MlCount(cText)+If(Len(cTitle)>0,1,0)

   DEFINE WINDOW _ToolTip       ;
      AT GetProperty(FormName, "Row")+GetProperty(FormName, ControlName, "Row")+(GetProperty(FormName, ControlName, "Height")*2)-5, ;
         GetProperty(FormName, "Col")+GetProperty(FormName, ControlName, "Col")+(GetProperty(FormName, ControlName, "Width")/2) ;
      WIDTH nWidth+60           ;
      HEIGHT nHeight*(nLines+1) ;
      MODAL                     ;
      NOCAPTION                 ;
      BACKCOLOR aColor          ;
      ON MOUSECLICK _ToolTip.Release

      If Len(cTitle)>0
         @ 0,5 LABEL _Title VALUE cTitle WIDTH nWidth HEIGHT nHeight ;
             TRANSPARENT FONT "_Font_ToolTip" ACTION _ToolTip.Release
         @ nHeight+.5,30 LABEL _Label VALUE cText WIDTH nWidth HEIGHT nHeight*(nLines-1) ;
             TRANSPARENT CENTERALIGN FONT "_Font_ToolTip" ACTION _ToolTip.Release
      Else
         @ nHeight/2,30 LABEL _Label VALUE cText WIDTH nWidth HEIGHT nHeight*nLines ;
             TRANSPARENT CENTERALIGN FONT "_Font_ToolTip" ACTION _ToolTip.Release
      Endif

      DEFINE TIMER Timer_1 INTERVAL nSeconds*1000 ACTION _ToolTip.Release

   END WINDOW

   ACTIVATE WINDOW _ToolTip

   RELEASE FONT _Font_ToolTip

Return Nil
