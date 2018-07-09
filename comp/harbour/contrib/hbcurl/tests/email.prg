/* Copyright 2014-2017 Viktor Szakats (vszakats.net/harbour) */

#require "hbcurl"
#require "hbtip"

#include "simpleio.ch"

PROCEDURE Main( cFrom, cPassword, cTo, cHost )

   LOCAL lSystemCA, cCA := hb_PathJoin( iif( hb_DirBase() == "", hb_cwd(), hb_DirBase() ), "cacert.pem" )
   #if defined( __PLATFORM__WINDOWS )
   LOCAL tmp
   #endif

   LOCAL curl
   LOCAL lAPI_curl := curl_version_info()[ HB_CURLVERINFO_VERSION_NUM ] >= 0x073800

   LOCAL cUser
   LOCAL cText
   LOCAL cHTML
   LOCAL cSubject

   /* Require STARTTLS on port 587 (true) or allow it to proceed without it (false) */
   LOCAL lSTARTTLS_force

   IF hb_AScan( curl_version_info()[ HB_CURLVERINFO_PROTOCOLS ], "smtps",,, .T. ) == 0
      ? "Error: Requires libcurl 7.20.0 or newer, built with TLS/SSL and SMTP protocol support"
      RETURN
   ENDIF

   hb_default( @cFrom    , "from@example.net" )
   hb_default( @cPassword, "password" )
   hb_default( @cTo      , "to@example.org" )
   hb_default( @cHost    , "localhost" )

   cFrom := "<" + ( cUser := hb_curl_mail_address_to_email( cFrom ) ) + ">"
   cTo := "<" + hb_curl_mail_address_to_email( cTo ) + ">"
   cHost := Lower( cHost )

   cSubject := "Example sending a MIME-formatted message"

   cText := ;
      e"This is the inline text message of the email.\r\n" + ;
      e"\r\n" + ;
      e"  It could be a lot of lines that would be displayed in an email\r\n" + ;
      e"viewer that is not able to handle HTML.\r\n"

   cHTML := ;
      e"<html><body>\r\n" + ;
      e"<p>This is the inline <strong>HTML</strong> message of the email.</p>" + ;
      e"<br>\r\n" + ;
      e"<p>It could be a lot of HTML data that would be displayed by " + ;
      e"email viewers able to handle HTML.</p>" + ;
      e"</body></html>\r\n"

   lSTARTTLS_force := .F.

   /* NOTE: Consult your provider for updated settings
            and create a Pull Request if necessary. */

   DO CASE
   CASE cHost == "apple" .OR. "@icloud.com" $ cFrom .OR. "@mac.com" $ cFrom .OR. "@me.com" $ cFrom
      cHost := "smtp://smtp.mail.me.com:587"; lSTARTTLS_force := .T.
   CASE cHost == "fastmail" .OR. "@fastmail.com" $ cFrom .OR. "@fastmail.fm" $ cFrom
      cHost := "smtps://smtp.fastmail.com"
   CASE cHost == "gmx.net" .OR. "@gmx.net" $ cFrom .OR. "@gmx.ch" $ cFrom .OR. "@gmx.de" $ cFrom
      cHost := "smtps://mail.gmx.net"
   CASE cHost == "google" .OR. "@gmail.com" $ cFrom .OR. "@googlemail.com" $ cFrom
      cHost := "smtps://smtp.gmail.com"
   CASE cHost == "mail.ru" .OR. "@mail.ru" $ cFrom
      cHost := "smtps://smtp.mail.ru"
   CASE cHost == "netease" .OR. "@163.com" $ cFrom
      cHost := "smtps://smtp.163.com"
   CASE cHost == "office365"
      cHost := "smtp://smtp.office365.com:587"; lSTARTTLS_force := .T.
   CASE cHost == "outlook" .OR. "@outlook.com" $ cFrom .OR. "@hotmail.com" $ cFrom
      cHost := "smtp://smtp-mail.outlook.com:587"; lSTARTTLS_force := .T.
   CASE cHost == "sina" .OR. "@sina.com" $ cFrom
      cHost := "smtps://smtp.vip.sina.com"
   CASE cHost == "uol" .OR. "@uol.com.br" $ cFrom
      cHost := "smtps://smtps.uol.com.br"
   CASE cHost == "yahoo" .OR. "@yahoo.com" $ cFrom
      cHost := "smtps://smtp.mail.yahoo.com"
   CASE cHost == "mailtrap.io" .OR. "@mailtrap.io" $ cFrom
      cHost := "smtp://smtp.mailtrap.io:465"; lSTARTTLS_force := .T.
      cUser := StrTran( cUser, "@mailtrap.io" )
   CASE cHost == "localhost"
      cHost := "smtp://localhost:1025"  /* MailHog */
      cUser := cPassword := NIL
   ENDCASE

   ? "libcurl:", curl_version_info()[ HB_CURLVERINFO_VERSION ]
   ? "Payload API:", iif( lAPI_curl, "libcurl native", "tip_MailAssemble()" )
   ? "Host:", cHost, iif( lSTARTTLS_force, "(must STARTTLS)", "" )

   #if defined( __PLATFORM__UNIX )
      lSystemCA := .T.
   #elif defined( __PLATFORM__WINDOWS )
      /* Switch to SChannel SSL backend, if available (on Windows).
         Doing this to use the OS certificate store. */
      curl_global_sslset( -1,, @tmp )
      IF ( lSystemCA := ;
         HB_CURLSSLBACKEND_SCHANNEL $ tmp .AND. ;
         curl_global_sslset( HB_CURLSSLBACKEND_SCHANNEL ) == HB_CURLSSLSET_OK )
         cCA := NIL
      ELSE
         cCA := hb_DirBase() + hb_DirSepToOS( "../../../bin/" ) + cCA
      ENDIF
   #else
      lSystemCA := .F.
   #endif

   curl_global_init()

   IF Empty( curl := curl_easy_init() )
      ? "Failed to init"
   ELSE
      IF ! lSystemCA
         IF hb_vfExists( cCA )
            curl_easy_setopt( curl, HB_CURLOPT_CAINFO, cCA )
         ELSE
            ?
            ? "Error: Trusted Root Certificates missing. Open this URL in your web browser:"
            ? "  " + "https://curl.haxx.se/ca/cacert.pem"
            ? "and save the file as:"
            ? "  " + cCA
            RETURN
         ENDIF
      ENDIF
      curl_easy_setopt( curl, HB_CURLOPT_USE_SSL, ;
         iif( lSTARTTLS_force, HB_CURLUSESSL_ALL, HB_CURLUSESSL_TRY ) )
      curl_easy_setopt( curl, HB_CURLOPT_UPLOAD )
      curl_easy_setopt( curl, HB_CURLOPT_URL, cHost )
      curl_easy_setopt( curl, HB_CURLOPT_PROTOCOLS, ;
         hb_bitOr( HB_CURLPROTO_SMTPS, HB_CURLPROTO_SMTP ) )
      curl_easy_setopt( curl, HB_CURLOPT_TIMEOUT_MS, 15000 )
      curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, .T. )
      curl_easy_setopt( curl, HB_CURLOPT_USERNAME, cUser )
      curl_easy_setopt( curl, HB_CURLOPT_PASSWORD, cPassword )
      curl_easy_setopt( curl, HB_CURLOPT_MAIL_FROM, cFrom )
      curl_easy_setopt( curl, HB_CURLOPT_MAIL_RCPT, { cTo } )

      IF lAPI_curl
         curl_easy_setopt( curl, HB_CURLOPT_HTTPHEADER, { ;
            "Date: " + hb_curl_date(), ;
            "To: " + cTo, ;
            "From: hbcurl " + cFrom, ;
            "Cc: " + cTo, ;
            "Message-ID: <dcd7cb36-11db-487a-9f3a-e652a9458efd@rfcpedant.example.org>", ;
            "Reply-To: " + cFrom, ;
            "Disposition-Notification-To: " + cFrom, ;
            "X-Priority: " + hb_ntos( 3 ), ;  /* 1: high, 3: standard, 5: low */
            "Subject: " + cSubject } )

         /* NOTE: 'charset' to be added when implemented */
         curl_easy_setopt( curl, HB_CURLOPT_MIMEPOST, { ;
            { "subparts" => { ;
              { "data" => cHTML, ;
                "type" => "text/html" }, ;
              { "data" => cText } }, ;
              "type" => "multipart/alternative", ;
              "headers" => { "Content-Disposition: inline" } }, ;
            { "filedata" => __FILE__ }, ;
            { "data" => Replicate( hb_BChar( 123 ), 1024 ), ;
              "type" => "image/png", ;
              "encoder" => "base64", ;  /* binary, 8bit, 7bit, base64, quoted-printable */
              "filename" => "mock.png" } } )
      ELSE
         cText := tip_MailAssemble( ;
            "hbtip " + cFrom, ;
            { cTo }, ;
            /* aCC */, ;
            cText, ;
            cSubject, ;
            { __FILE__, { "mock.png", Replicate( hb_BChar( 123 ), 1024 ) } } /* attachments */, ;
            /* nPriority */, ;
            /* lRead */, ;
            /* cReplyTo */, ;
            /* cCharset */, ;
            /* cEncoding */, ;
            .F. /* lBodyHTML */, ;
            /* bSMIME */ )
         curl_easy_setopt( curl, HB_CURLOPT_UL_BUFF_SETUP, cText )
         curl_easy_setopt( curl, HB_CURLOPT_INFILESIZE_LARGE, hb_BLen( cText ) )
      ENDIF

      ? "Result:", curl_easy_perform( curl )

      curl_easy_cleanup( curl )
   ENDIF

   RETURN
