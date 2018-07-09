Comments to Harbour distribution offered by HMG Extended Edition
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Version: 3.2.0dev (r1806032230)

Built on: Jun 25 2018

Last ChangeLog entry: 2018-06-04 01:30 UTC-0300 Lailton Fernando Mariano

ChangeLog ID: 1b05385b046db903a97f7d79311af9a8ec65b3e8

Compiler: Borland C++ 5.5.1 (32-bit)

Extra C compiler options: -DHB_GC_AUTO -DHB_GUI

Build options: (Clipper 5.3b) (Clipper 5.x undoc)


Harbour Project contrib and extras libraries are included on this distribution:

	- hbct.lib		/* Clipper Tools */
	- hbnf.lib		/* NanForum Toolkits */
	- hbmisc.lib		/* Miscellaneous functions */
	- hbfoxpro.lib		/* FoxPro compatibility */
	- hbfship.lib		/* FlagShip compatibility */
	- hbodbc.lib		/* ODBC Access */
	- hbsqldd.lib		/* SQL Database Driver */
	- sddodbc.lib		/* ODBC Database Driver */
	- sddmy.lib		/* MySQL Database Driver */
	- sddsqlt3.lib		/* SQLite3 Database Driver */
	- hbmemio.lib		/* Memory file system */
	- hbnetio.lib		/* Alternative RDD IO API */
	- hbcomio.lib		/* I/O driver for serial port streams */
	- hbpipeio.lib		/* I/O driver for pipe streams */
	- hbtcpio.lib		/* I/O driver for TCP streams */
	- hbgzio.lib		/* I/O driver for GZIP compressed streams */
	- hbsqlit3.lib		/* SQLite3 wrapper library */
	- hbssl.lib 		/* OpenSSL wrapper library */
	- hbtip.lib 		/* Internet protocol */
	- adordd.lib		/* RDD to automatically manage Microsoft ADO */
	- rddads.lib		/* RDD for Advantage Database Server */
	- rddbm.lib		/* Alternative BMDBF* implementation */
	- hbziparc.lib		/* ZipArchive interface compatibility */
	- hbmzip.lib		/* ZIP file support based on minizip library */
	- hbzebra.lib		/* Zebra barcode library */
	- hbfimage.lib		/* FreeImage wrapper library */
	- hbhpdf.lib		/* LibHaru Pdf wrapper library */
	- hbvpdf.lib		/* Victor K. Clipper Pdf Library */
	- hbmysql.lib		/* MySQL DBMS classes */
	- hbpgsql.lib		/* PostgreSQL DBMS classes */
	- hbwin.lib		/* Windows API functions */
	- hbxlsxml.lib		/* Excel Writer XML class */
	- hbxpp.lib		/* Xbase++ compatibility */
	- xhb.lib		/* xHarbour compatibility */


Additional 3rd party C-code Libraries:

	- ziparchive.lib	*obsolete* ZipArchive library for compatibility with an old code only
	- minizip.lib		MiniZip library from http://www.winimage.com/zLibDll/minizip.html


Others Extras Libraries:

	- FreeImage.lib:	Created from freeimage.dll (distributed along with FreeImage)
				by adding the following statement in the Harbour make script:
				set HB_WITH_FREEIMAGE=C:\FreeImage\Dist

	- libmysql.lib:		Created from libmysql.dll (distributed along with MySql) 
				using Borland implib utility.

	- libpq.lib:		Created from libpq.lib (distributed along with PostgreSQL) 
				using Digital Mars coffimplib utility.

	- ace32.lib:		Created from ace32.dll (distributed along with Advantage 
				local server) using Borland implib utility.

	- odbc32.lib:		Created from odbc32.dll (distributed along with Windows) 
				using Borland implib utility.

	- libeay32.lib:		Created from libeay32.dll (distributed along with OpenSSL) 
				by adding the following statement in the Harbour make script:
				set HB_WITH_OPENSSL=C:\openssl\include

	- ssleay32.lib:		Created from ssleay32.dll (distributed along with OpenSSL) 
				by adding the following statement in the Harbour make script:
				set HB_WITH_OPENSSL=C:\openssl\include

	- dll.lib:		What32's DLL access code.
				Authors: 
				Andrew Wos <andrwos@aust1.net>
				Vic McClung <vicmcclung@vicmcclung.com>
				Source code available in the folder \source\Dll.

	- calldll.lib:		Dll Access Code. 
				Copyright 2010 Viktor Szakats <harbour@syenar.net>
				Copyright 2015 Claudio Soto <srvet@adinet.com.uy>
				Source code available in the folder \source\CallDll.

	- hbcomm.lib:		Win32 serial port routines.
				Copyright 2003 Luiz Rafael <luiz@xharbour.com.br>
				Modified by Ned Robertson for Harbour
				Source code available in the folder \source\HbComm.

	- hbxml.lib:		Harbour XML Library. Part of HWGUI project
				Copyright 2003 Alexander S.Kresin <alex@belacy.ru>
				Source code available in the folder \source\HbXML.

	- hbgdip.lib:		GdiPlus Dll access library.
				Copyright 2017 P.Chornyj <myorg63@mail.ru>
				Source code available in the folder \source\hbgdip.

	- hbunrar.lib:		UnRar Dll access library.
				Copyright 2007 P.Chornyj <myorg63@mail.ru>
				Source code available in the folder \samples\Advanced\UnRar.

	- hbprinter.lib:	Harbour Win32 Printing library.
				Copyright 2002-2005 Richard Rylko <rrylko@poczta.onet.pl>
				Source code available in the folder \source\HbPrinter.

	- miniprint.lib:	Harbour MiniGUI Print library.
				Copyright 2004-2010 Roberto Lopez <harbourminigui@gmail.com>
				Source code available in the folder \source\MiniPrint.

	- hbaes.lib:		AES File Encryption library.
				Copyright 2012 S.Rathinagiri <srgiri@dataone.in>
				Source code available in the folder \source\HbAES.

	- hmg_hpdf.lib:		HaruPDF access with using xBase syntax.
				Copyright 2012 S.Rathinagiri <srgiri@dataone.in>
				Source code available in the folder \source\HMG_HPDF.

	- shell32.lib:		Shell Extensions library.
				Copyright 2004 Grigory Filatov <gfilatov@inbox.ru>
				Source code available in the folder \source\shell32.

	- socket.lib:		Harbour Socket Library.
				Copyright 2001-2003 Matteo Baccan <baccan@infomedia.it>
				Source code available in the folder \source\Socket.

	- TMsAgent.lib:		MS Agent access library.
				Copyright 2004 Juan Carlos Salinas Ojeda <jcso@esm.com.mx>
				Source code available in the folder \source\TMsAgent.

	- BosTaurus.lib:	GDIPlus-based Graphics Library.
				Copyright 2012-2014 Dr. Claudio Soto <srvet@adinet.com>
				Source code available in the folder \source\BosTaurus.

	- SQLite3Facade:	a facade for Harbour SQLite3 contrib library.
				Copyright 2010 Daniel Goncalves <daniel-at-base4-com-br>
				Source code available in the folder \source\SQLite3Facade.

	- pscript.lib:		PScript Dll access library.
				Copyright 2000-2017 Pagescript32.com <support@pagescript32.com>
				Source code available in the folder \source\PageScript.
