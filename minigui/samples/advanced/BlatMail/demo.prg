/*
 * Autor : Claudinei de Lima
 * data  : 07.09.2004
 * msn   : claudinei@vsp.com.br
 * e-mail: climadc@brturbo.com
 * Dois Irmãos - RS
 *
 * Revized: Grigory Filatov <gfilatov@inbox.ru>
 * Date: 01/30/2007
 * Lib HMG 1.3 Extended Build 31
 *
 * Fixed: Grigory Filatov <gfilatov@inbox.ru>
 * Date: 05/11/2007
 * Lib HMG 1.4 Extended Build 46
*/

ANNOUNCE RDDSYS

#include "MiniGui.ch"

#define _use_CallDLL

Memvar _usuario
Memvar _senha
Memvar _smtp
Memvar _ident
Memvar _de
Memvar _autentica
/*
*/
Procedure Main()
  Private _usuario   := ""
  Private _senha     := ""
  Private _smtp      := ""
  Private _ident     := ""
  Private _de        := ""
  Private _autentica := .F.

  IF File("demo.ini")
    BEGIN INI FILE ("demo.ini")
       GET _smtp       SECTION "E-Mail" ENTRY "SMTP"
       GET _usuario    SECTION "E-Mail" ENTRY "Conta"
       GET _ident      SECTION "E-Mail" ENTRY "Rementente"
       GET _de         SECTION "E-Mail" ENTRY "De"
       GET _senha      SECTION "E-Mail" ENTRY "Senha"
    END INI
    _Autentica := !EMPTY(_senha)
  ENDIF

  DEFINE WINDOW Form_Email ;
    AT 00,00         ;
    WIDTH  546       ;
    HEIGHT 560       ;
    TITLE "Send E-Mail" ;
;// TITLE "Módulo de envio de E-Mail" ;
    ICON 'MAIL'      ;
    MAIN             ;
    NOMAXIMIZE       ;
    NOSIZE           ;
    FONT "Courier New" SIZE 10

    @014,020 LABEL  Label_T_smtp      ;
       VALUE "Serv.SMTP:"             ;
       WIDTH 110                      ;
       HEIGHT 27                      ;
       FONT "Courier New" Size 10

    @010,130 TEXTBOX T_smtp;
       WIDTH 390           ;
       VALUE _smtp         ;
       TOOLTIP "Informe o Servidor de saídas de E-mails(SMTP).";
       FONT "Courier New" Size 10     ;
       ON ENTER DoMethod("Form_Email","T_usuario","SetFocus");
       MAXLENGTH 60 LOWERCASE

    @044,020 LABEL  Label_T_usuario   ;
       VALUE "Sender Name:"           ;
;//    VALUE "Conta....:"             ;
       WIDTH 110                      ;
       HEIGHT 27                      ;
       FONT "Courier New" Size 10

    @040,130 TEXTBOX T_usuario        ;
       WIDTH 390                      ;
       VALUE _usuario                 ;
       TOOLTIP "Informe o usuario."   ;
       FONT "Courier New" Size 10     ;
       ON ENTER DoMethod("Form_Email","T_id","SetFocus");
       MAXLENGTH 60

    @074,020 LABEL  Label_T_id        ;
       VALUE "Sender Addr:"           ;
       WIDTH 110                      ;
       HEIGHT 27                      ;
       FONT "Courier New" Size 10

    @070,130 TEXTBOX T_id ;
       WIDTH 390          ;
       VALUE _ident       ;
       TOOLTIP "Informe o nome pelo qual você será identificado pelo desetinatário.";
       FONT "Courier New" Size 10     ;
       ON ENTER DoMethod("Form_Email","T_De","SetFocus");
       MAXLENGTH 60 LOWERCASE

    @104,020 LABEL  Label_T_De        ;
       VALUE "Reply To:"              ;
;//       VALUE "De.....:"            ;
       WIDTH 090                      ;
       HEIGHT 27                      ;
       FONT "Courier New" Size 10

    @100,110 TEXTBOX T_De ;
       WIDTH 410          ;
       VALUE _de          ;
       TOOLTIP "Informe o endereço de E-Mail do pessoa que está enviando.";
       FONT "Courier New" Size 10     ;
       ON ENTER DoMethod("Form_Email","T_Para","SetFocus");
       MAXLENGTH 60 LOWERCASE


    @134,020 LABEL  Label_T_Para      ;
       VALUE "To.....:"               ;
;//       VALUE "Para...:"            ;
       WIDTH 090                      ;
       HEIGHT 27                      ;
       FONT "Courier New" Size 10

    @130,110 TEXTBOX T_Para ;
       WIDTH 410           ;
       TOOLTIP "Informe o endereço de E-Mail do pessoa para quem está enviando.";
       FONT "Courier New" Size 10     ;
       ON ENTER DoMethod("Form_Email","T_Assunto","SetFocus");
       MAXLENGTH 60 LOWERCASE

    @164,020 LABEL  Label_T_Assunto   ;
       VALUE "Subject:"               ;
;//       VALUE "Assunto:"            ;
       WIDTH 090                      ;
       HEIGHT 27                      ;
       FONT "Courier New" Size 10

    @160,110 TEXTBOX T_Assunto        ;
       WIDTH 410                      ;
       TOOLTIP "Informe/Confirme o Assunto do E-Mail a ser enviado.";
       FONT "Courier New" Size 10     ;
       ON ENTER DoMethod("Form_Email","ECorpo","SetFocus");
       MAXLENGTH 60

    @194,020 LABEL  Label_T_Axeno     ;
       VALUE "Attach file(s):"        ;
       WIDTH 060                      ;
       HEIGHT 54                      ;
       FONT "Courier New" Size 10

    @190,077 BUTTONEX BAnexar         ;
       PICTURE "B_Anexar"             ;
       ACTION Anexar()                ;
       WIDTH 32 HEIGHT 32

    @190,110 LISTBOX L_Anexo          ;
       WIDTH 410                      ;
       HEIGHT 070                     ;
       FONT "Courier New" Size 10     ;
       ON DBLCLICK Dele_Anexo()       ;
       ON GOTFOCUS DoMethod("Form_Email","ECorpo","SetFocus")

    @270,020 EDITBOX ECorpo ;
       WIDTH 500 ;
       HEIGHT 200 ;
       TOOLTIP 'EditBox' ;
       FONT "Courier New" Size 10 ;
       MAXLENGTH 500 ;
       NOVSCROLL NOHSCROLL

    DEFINE CHECKBOX vAutenticar
       ROW   494
       COL   265
       CAPTION "Authentication"
       WIDTH 130
       HEIGHT 18
       VALUE _Autentica
       FONTNAME "Courier New"
       FONTSIZE 11
       TOOLTIP "Informe se seu servidor exige Auteticação."
       ON CHANGE Ativa_senha()
    END CHECKBOX

    @490,400 TEXTBOX T_Senha ;
       WIDTH 120 ;
       VALUE _senha ;
       TOOLTIP "Informe/Confirme a Senha." ;
       FONT "Courier New" Size 10 ;
       PASSWORD ;
       ON ENTER DoMethod("Form_Email","BEnviar","SetFocus");
       MAXLENGTH 12

    @484,020 BUTTONEX BEnviar ;
       PICTURE "B_Enviar" ;
       CAPTION "S&END" ;
       FONT "Courier New" Size 10 BOLD ;
       ACTION  Enviar_email() ;
       WIDTH 100 HEIGHT 38

    @484,140 BUTTONEX BSair ;
       PICTURE "B_Sair" ;
       CAPTION "E&XIT" ;
       FONT "Courier New" Size 10 BOLD ;
       ACTION DoMethod("Form_Email","Release") ;
       WIDTH 100 HEIGHT 38

  END WINDOW

  ON KEY ESCAPE OF Form_Email ACTION DoMethod("Form_Email","Release")

  SetProperty("Form_Email","T_Senha","Enabled",_Autentica)
  DoMethod("Form_Email","T_smtp","SetFocus")

  CENTER   WINDOW Form_Email
  ACTIVATE WINDOW Form_Email

Return
/*
*/
Function Enviar_email()
  Local _anexo_ := ''
  Local _id
  Local _para_
  Local _assunto_
  Local _emai_
  Local nanexos_, x

  _para_ := Alltrim(GetProperty("Form_Email","T_Para","Value"))
  IF EMPTY(_para_)
	Return Nil
  ENDIF
  _id := Alltrim(GetProperty("Form_Email","T_id","Value"))
  _de := Alltrim(GetProperty("Form_Email","T_De","Value"))
  _assunto_ := Alltrim(GetProperty("Form_Email","T_Assunto","Value"))
  _emai_ := GetProperty("Form_Email","ECorpo","Value")
  _smtp  := Alltrim(GetProperty("Form_Email","T_smtp","Value"))
  _usuario := Alltrim(GetProperty("Form_Email","T_usuario","Value"))
  _senha := Alltrim(GetProperty("Form_Email","T_senha","Value"))
  nanexos_ := GetProperty("Form_Email","L_Anexo","ItemCount")
  IF nanexos_ > 0
	FOR x = 1 TO nanexos_
		_anexo_ += _GetShortPathName(GetProperty("Form_Email","L_Anexo","Item",x)) + if(x<nanexos_,",","")
	NEXT
  ENDIF
  EnviaEmail_(_smtp, _id, _de, _para_, _assunto_, _emai_, _anexo_, _usuario, _senha )
  Salvar_dados()
  SetProperty("Form_Email","T_Para","Value","")
  SetProperty("Form_Email","T_Assunto","Value","")
  SetProperty("Form_Email","ECorpo","Value","")
  DELETE ITEM ALL FROM L_Anexo OF Form_Email
  DoMethod("Form_Email","T_smtp","SetFocus")
Return Nil
/*
*/
Function Anexar()
  Local aArqGet, x
  aArqGet := Getfile( { {"Todos os Arquivos (*.*)", "*.*"} }, "Anexar arquivo...", , .T. )
  If Len(aArqGet) > 0
	for x = 1 to Len(aArqGet)
		ADD ITEM aArqGet[x] TO L_Anexo OF Form_Email
	next
  EndIf
Return NIL
/*
*/
Function Dele_Anexo()
  Local oanexo := GetProperty("Form_Email","L_Anexo","Value")
  DELETE ITEM oanexo FROM L_Anexo OF Form_Email
  DoMethod("Form_Email","L_Anexo","SetFocus")
Return Nil
/*
*/
Function Salvar_dados()
  _smtp      := Alltrim(GetProperty("Form_Email","T_smtp","Value"))
  _usuario   := Alltrim(GetProperty("Form_Email","T_usuario","Value"))
  _ident     := Alltrim(GetProperty("Form_Email","T_id","Value"))
  _de        := Alltrim(GetProperty("Form_Email","T_De","Value"))
  _senha     := Alltrim(GetProperty("Form_Email","T_Senha","Value"))
  BEGIN INI FILE ("demo.ini")
     SET SECTION "E-Mail"        ENTRY "SMTP"       To _smtp
     SET SECTION "E-Mail"        ENTRY "Conta"      To _usuario
     SET SECTION "E-Mail"        ENTRY "Rementente" To _ident
     SET SECTION "E-Mail"        ENTRY "De"         To _de
     SET SECTION "E-Mail"        ENTRY "Senha"      To _senha
  END INI
Return Nil
/*
*/
Function Ativa_senha()
  _Autentica := GetProperty("Form_Email","vAutenticar","Value")
  SetProperty("Form_Email","T_Senha","Enabled",_Autentica)
Return Nil
/*
*/
Procedure EnviaEmail_(_smtp, _id, _de, _para_, _assunto_, _emai_, _anexo_, _usuario, _senha )
LOCAL nRet
LOCAL oMail := BlatMail():New()
   
  * Addresses and password

  oMail:cSMTPServer=_smtp		// SMTP Server address
  IF _Autentica
     oMail:cSMTPLogin=_id		// SMTP authenticated login account
     oMail:cSMTPPassword :=_senha	// Password for SMTP authenticated login - default is skip value
  ENDIF
  oMail:cSendAddress :=_id		// Sender mail address
  oMail:cAltSendAddress :=_de		// address displayed as from address - used for 'Reply To'
  oMail:cFromName :=_usuario		// Plain text name - e.g. John Doe - shown as the sender

  * Lists of recipients and flags

  oMail:cToList:=_para_			// List of recipients comma delimited
  oMail:cSubject :=_assunto_		// Subject line
  oMail:cMessageFile :=''		// File name of file containing plain message text
  oMail:cMessage :=_emai_		// Plain message text
  oMail:cAttachFiles :=_anexo_		// Attached binary files (filenames comma separated)

  oMail:lLogFile=.T.			// use a log file
  oMail:cLogFile='BlatMail.log'		// log filename - default is BlatLog.Log
    
  oMail:SetCommandLine()		// initialize command line common switches

  nRet := oMail:MailSend()		// Actually send the mail

#ifdef _use_CallDLL
  oMail:BlatUnload(.T.)			// Calling this when not using CallDLL doesn't cause harm
#endif

  IF nRet == 0
	MsgInfo( "E-Mail was sent successfully!", "BlatMail" )
  ENDIF

RETURN
