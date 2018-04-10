/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample

  Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  Thanks to "Le Roy" Roberto Lopez.

  HMG Data Base Assistant v.3.8.30

  Copyright 2008-2010 © Bicahi Esgici <esgici@gmail.com>

  All bug reports and suggestions are welcome.
*/

/*
* Revised by Grigory Filatov for HMG Extended Edition at 02/11/2010
*/

#include <minigui.ch>
#include "DBA.ch"

PROC Main( cOpFName )

   REQUEST DBFCDX, DBFFPT

   REQUEST FTOC, CTOF, XTOC 

   PUBL cInTFName := cOpFName // Initial ( given with DBA calling ) table file name

   SET DATE GERM
   SET CENT ON
   SET BROWSESYNC ON
   
   #include "DBA.pbl"

   Set Default Icon To "DBAICO"

   #include "DBA_Main.pen"

   DBA_Refr()

   CENTER WINDOW frmDBAMain
   ACTIVATE WINDOW frmDBAMain

RETU // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC InitProg()

   FB_InitBtns()
   LastUsed()
   SetUPrefers()
   
   IF lPref0101
      Recents()
   ENDIF
   IF ISCHAR( cInTFName )
      Open1Tabl( cInTFName )
   ELSE
      RefrMenu()
   ENDIF ISCHAR( cInTFName )

RETU // InitProg()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBA_Refr()

   cMWinName := "frmDBAMain"

   IF _IsWindowDefined ( cMWinName )
      nMainWWid := frmDBAMain.WIDTH
      nMainWHig := frmDBAMain.HEIGHT
      FB_RefrsAll()
      RefrBrow(.t.)
   ENDIF _IsWindowDefined ( cMWinName )

RETU // DBA_Refr()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC RefrMenu()                           // Refresh Menu items

   LOCA nMItem  :=  0,;
        c1Item  := '',;
        b1Item

   FOR nMItem := 1 TO LEN( aMnuItems )
      c1Item  := aMnuItems[ nMItem, 1 ]
      b1Item  := aMnuItems[ nMItem, 2 ]
      IF ISNIL( b1Item )
         b1Item := { || !ISNIL( _GetControlAction( c1Item, "frmDBAMain" ) ) }
      ENDIF
      SetProperty ( cMWinName, c1Item, "ENABLED", EVAL( b1Item  ) )
   NEXT nMItem

RETU // RefrMenu()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC RefrStBar( cMark )

   LOCA cDbgInfo := AnyToStr( cMark ) + ": " + ;
                    "OpnDat : " + NTrim( nOpTablCo ) + "; " +;
                    "CurDat : " + NTrim( nCurDatNo ) + "; " +;
                    "OpnPag : " + NTrim( nOpnPagCo ) + "; " +;
                    "CurPag : " + NTrim( nCurPagNo ) + "; " +;
                    "1PagDt : " + NTrim( n1PagDtNo ) + "; " +;
                    "BtnLen : " + NTrim( nBtnWidth ) ,;
        aStatus  := {}

   IF lFBDebug
      _SetItem ( "StatusBar", cMWinName, 1, cDbgInfo )
   ELSE
      IF EMPTY( aOpnDatas ) .OR. EMPTY( nCurDatNo )
        aStatus  := { '', '', '' }
      ELSE
        aStatus  := { NTrim(nCurDatNo) + "°" + aOpnDatas[ nCurDatNo, 3 ] ,; // Full File Name
                      PADC( NTrim( RECN() ) + '\' + NTrim( LASTREC() ) ,17) ,;
                      IF( CDIsTable() .AND. DELETED(),'*','') }
      ENDIF
      _SetItem ( "StatusBar", cMWinName, 1, aStatus[ 1 ]  )
      _SetItem ( "StatusBar", cMWinName, 2, aStatus[ 2 ]  )
      _SetItem ( "StatusBar", cMWinName, 3, aStatus[ 3 ]  )
   ENDIF lFBDebug

RETU // RefrStBar()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC CDIsTable()                          // Is Current Data a table ?
   LOCA lRVal := ( nCurDatNo > 0 .AND. ;
                   !EMPTY( aOpnDatas ) .AND. ;
                   aOpnDatas[ nCurDatNo, 1 ] == "T" )
RETU lRVal // CDIsTable()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC HasIndex()                          // Is Current Data Is a table and it has index ?
   LOCA lRVal := .F.
   IF CDIsTable()
      lRVal := ( LEN( aOpnDatas[ nCurDatNo ] ) > 5 .AND.;
                 !EMPTY( aOpnDatas[ nCurDatNo, 6 ] ) )
   ENDIF CDIsTable()
RETU lRVal // HasIndex()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC RefrBrow(lInit)                           // Refresh Browse

   default lInit := .f.
   IF _IsControlDefined ( "brwDBAMain", "frmDBAMain" )
      if lInit
         frmDBAMain.brwDBAMain.WIDTH  := nMainWWid - 15
         frmDBAMain.brwDBAMain.HEIGHT := nMainWHig - 105
      endif
      frmDBAMain.brwDBAMain.Value := RECN()
      frmDBAMain.brwDBAMain.Refresh
   ENDIF _IsControlDefined ( "brwDBAMain", "frmDBAMain" )

RETU // RefrBrow()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC Recents(;             // Set/Reset Recent ( Last Opened ) Datas ( Files )
              aCurrents )  // Currently open data's full file names

   LOCA cRecsFNm := cProgFold + "\" + PROCNAME() + ".lst",;
        cRecsStr := '',;
        c1FFName := ''

   IF ISNIL( aCurrents )
      IF FILE( cRecsFNm )
         cRecsStr := MEMOREAD( cRecsFNm )
         IF EMPTY( cRecsStr )
            MsgBox( "Recorded recent data file is empty." )
         ELSE
            WHILE !EMPTY( cRecsStr )
               c1FFName := ExtrcSFS( @cRecsStr, CRLF )
               Open1Tabl( c1FFName, .F. )
            ENDDO
         ENDIF
      ELSE
         MsgBox( "Recorded recent data file not found" )
      ENDIF ISNIL( cLastFile )
   ELSE
      AEVAL( aCurrents, { | a1 | cRecsStr += a1[ 3 ] + CRLF } )
      MEMOWRIT( cRecsFNm, cRecsStr )
   ENDIF ISNIL( aCurrents )

RETU // Recents()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC LastUsed(;               // Read/Set/ReSet Last used Folder
               cLastFile,;    // Full file name last used file
               cFoldType )    // 'D:' : data, 'C:' : Code ( eg . Find String )

   LOCA cLUDsFNm := cProgFold + "\" + PROCNAME() + ".dirs",; // Last Used Dirs Recorded File Name
        cLUFDNam := '',;     // Last Used File's Folder Name
        cLUFStrg := ''       // Last Used Files record string

*  cLastCDir, cLastDDir are PUBL

   DEFAULT cFoldType TO 'D'

   IF ISNIL( cLastFile )  // Program first running
      IF FILE( cLUDsFNm )
         cLUFStrg  := MEMOREAD( cLUDsFNm )
         cLastCDir := ExtrcSIS( cLUFStrg, '<C>', CRLF )
         cLastDDir := ExtrcSIS( cLUFStrg, '<D>', CRLF )
      ELSE
         cLUFStrg := '<C>' + ExOPFFFS( cLUDsFNm ) + CRLF + ;
                     '<D>' + ExOPFFFS( cLUDsFNm ) + CRLF
         MEMOWRIT( cLUDsFNm, cLUFStrg )
      ENDIF
   ELSE
      DO CASE
         CASE cFoldType == 'C'
            cLastCDir := ExOPFFFS( cLastFile )
         CASE cFoldType == 'D'
            cLastDDir := ExOPFFFS( cLastFile )
      ENDCASE
      cLUFStrg := '<C>' + cLastCDir + CRLF + ;
                  '<D>' + cLastDDir + CRLF
      MEMOWRIT( cLUDsFNm, cLUFStrg )
   ENDIF ISNIL( cLastFile )

RETU // LastUsed()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC DBA_HowTo()
   LOCA cHowTo := "What is it, how is it."
   MsgInfo( cHowTo )
RETU // DBA_HowTo()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC ShutDown( xCaller )                  // QUIT / CANCEL program

   *
   *  xCaller : ON RELEASE : 1, others : NIL
   *
   *

   LOCA lRVal := .F.

   IF ISNIL( xCaller )
      IF lPref0103
         lRVal := MsgYesNo( "Are You Sure ? " )
      ELSE
         lRVal := .T.
      ENDIF
   ELSE
      lRVal := .T.
   ENDIF

   IF lRVal
      IF !EMPTY( aOpnDatas )
         Recents( aOpnDatas )
         ClosData("A","A")  // Bu ilerde lâzým olacak ( non-dbf'leri kapatmadan önce "save" sormak için.)
      ENDIF
      IF ISNIL( xCaller )
         frmDBAMain.Release
      ENDIF
   ENDIF

RETU lRVal // ShutDown()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC DBAbout()                            // About DBA

   LOCA cDBAbout := ;   
   "{\rtf1\ansi\ansicpg1254\deff0\deflang1055\deflangfe1055{\fonttbl{\f0\fswiss\fprq2\" + ;
   "fcharset162 Verdana;}{\f1\fswiss\fprq2\fcharset0 Verdana;}}{\colortbl;\red0\green0\blue255;}"+;
   "{\*\generator Msftedit 5.41.15.1507;}\viewkind4\uc1\pard\nowidctlpar\ri-1418\f0\fs18\par"+;
   "               HMG Data Base Assistant v." + ExeFD2Vrs() + "\par"+;
   "\pard\nowidctlpar\ri-1748\qj\fs16\par                          \'a9 \cf1 esgici@gmail.com\par"+;
   "\cf0\b\par     \b0 DBA\b  \b0 is an imitative work to the \'a9 \b dBASE III'\b0 s Assistant.\par"+;
   "\par     It may be an easy tool for people who are familiar to \par"+;
   "        this \b base\b0  architecture of  the whole  xBase family. \par"+;
   "\par     Many thanks to : \par\par"+;
   "            \b Antonio Linares  \b0 ( Initiator of \'a9 \b Harbour\b0  ) and\par"+;
   "            \i Le Roy \b\i0 Roberto Lopez \b0 ( Initiator of \'a9 \b MiniGUI  \b0 ).\par"+;
   "\par   Without this two big men and their volunteer coworkers, \par"+;
   "\b       \b0 DBA ( and many others of course) couldn't be exist.\par"+;
   "\par\pard\sb100\sa100             \cf1\lang1033\f1 https://harbour.github.io\cf0\lang1055\f0\par"+;
   "\pard\nowidctlpar\ri-1748\qj\cf1             http://harbourminigui.googlepages.com\cf0\par}"
               
   LOCA cCmd3Head := 'Close'
   
   DEFINE WINDOW frmAbout;
      AT 0, 0 ;
      WIDTH  374 ;
      HEIGHT 314 ;
      MODAL ;
      NOCAPTION NOSIZE ;
      ON INIT frmAbout.cmdClose.Setfocus

      ON KEY ESCAPE ACTION frmAbout.Release

      DEFINE RICHEDITBOX rtfAbout
          ROW       0
          COL       0
          WIDTH     frmAbout.WIDTH - 4
          HEIGHT    frmAbout.HEIGHT - 24
          VALUE     cDBAbout
          READONLY .T.
      END RICHEDITBOX // rtfAbout

      DEFINE BUTTON cmdClose
         ROW      frmAbout.HEIGHT - 21
         COL      ( frmAbout.WIDTH - 41 ) / 2
         CAPTION  cCmd3Head                      
         TOOLTIP  cCmd3Head                      
         FONTNAME   "Tahoma"
         FONTSIZE   8
         WIDTH    41                             
         HEIGHT   18                             
         ACTION   frmAbout.Release              
      END BUTTON // cmdClose
      
   END WINDOW // frmAbout

   CENTER   WINDOW frmAbout
   ACTIVATE WINDOW frmAbout

RETU // DBAbout()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
 
FUNC ExeFD2Vrs()                          // .exe File Date to .prg version number

   LOCA dEFDate := FILEDATE( GetProgramFileName() )
   
   LOCA cRVal   := NTrim( YEAR( dEFDate ) - 2007 ) + '.' +;
            	   NTrim( MONT( dEFDate ) ) + '.' +;
            	   NTrim( DAY( dEFDate ) )
        
RETU cRVal // ExeFD2Vrs()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

 