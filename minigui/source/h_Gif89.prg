/*
 * Harbour TGif Class v1.4
 * Copyright 2009-2020 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Revised by Ivanil Marcelino <ivanil/at/linkbr.com.br>
 * Last revision 30.10.2020
 */

ANNOUNCE CLASS_TGIF

#include "minigui.ch"

*------------------------------------------------------------------------------*
FUNCTION _DefineAniGif ( cControlName, cParentForm, cFilename, nRow, nCol, nWidth, nHeight, nDelay, aBKColor )
*------------------------------------------------------------------------------*
   LOCAL nControlHandle, nParentFormHandle
   LOCAL mVar
   LOCAL k
   LOCAL oGif
   LOCAL cDiskFile
   Local cResName := ""

   // If defined inside DEFINE WINDOW structure, determine cParentForm
   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      cParentForm := iif ( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
   ENDIF

   IF .NOT. _IsWindowDefined ( cParentForm )
      MsgMiniGuiError ( "Window: " + cParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined ( cControlName, cParentForm )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " Already defined." )
   ENDIF

   IF ! ISCHARACTER ( cFilename )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " PICTURE Property Invalid Type." )
   ENDIF

   IF Empty ( cFilename )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " PICTURE Can't Be Empty." )
   ENDIF

   IF ! hb_FileExists ( cFileName )
      cDiskFile := TempFile ( GetTempFolder(), "gif" )
      IF RCDataToFile ( cFilename, cDiskFile, "GIF" ) > 0
         IF hb_FileExists ( cDiskFile )
            cResName  := cFileName
            cFilename := cDiskFile
         ENDIF
      ENDIF
   ENDIF

   // Define public variable associated with control
   mVar := '_' + cParentForm + '_' + cControlName

   nParentFormHandle := GetFormHandle ( cParentForm )

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType[ k ] := "ANIGIF"
   _HMG_aControlNames[ k ] :=  cControlName
   _HMG_aControlParentHandles[ k ] :=  nParentFormHandle
   _HMG_aControlProcedures[ k ] := ""
   _HMG_aControlPageMap[ k ] :=  {}
   _HMG_aControlValue[ k ] :=  0
   _HMG_aControlInputMask[ k ] :=  ""
   _HMG_aControllostFocusProcedure[ k ] :=  ""
   _HMG_aControlGotFocusProcedure[ k ] :=  ""
   _HMG_aControlChangeProcedure[ k ] :=  ""
   _HMG_aControlDeleted[ k ] :=  .F.
   _HMG_aControlBkColor[ k ] :=  aBKColor
   _HMG_aControlFontColor[ k ] :=  Nil
   _HMG_aControlDblClick[ k ] :=  ""
   _HMG_aControlHeadClick[ k ] :=  {}
   _HMG_aControlRow[ k ] := nRow
   _HMG_aControlCol[ k ] := nCol
   _HMG_aControlWidth[ k ] := nWidth
   _HMG_aControlHeight[ k ] := nHeight
   _HMG_aControlSpacing[ k ] := nDelay
   _HMG_aControlContainerRow[ k ] :=  -1
   _HMG_aControlContainerCol[ k ] :=  -1
   _HMG_aControlPicture[ k ] :=  cResName
   _HMG_aControlContainerHandle[ k ] :=  0
   _HMG_aControlFontName[ k ] :=  Nil
   _HMG_aControlFontSize[ k ] :=  Nil
   _HMG_aControlFontAttributes[ k ] :=  {}
   _HMG_aControlToolTip[ k ] :=  ''
   _HMG_aControlRangeMin[ k ] :=  0
   _HMG_aControlRangeMax[ k ] :=  0
   _HMG_aControlCaption[ k ] :=  cFilename
   _HMG_aControlVisible[ k ] :=  .T.
   _HMG_aControlHelpId[ k ] :=  0
   _HMG_aControlFontHandle[ k ] :=  Nil
   _HMG_aControlBrushHandle[ k ] :=  0
   _HMG_aControlEnabled[ k ] :=  .T.
   _HMG_aControlMiscData1[ k ] :=  0
   _HMG_aControlMiscData2[ k ] :=  ''

   oGif := TGif():New( cFilename, nRow, nCol, nHeight, nWidth, nDelay, aBKColor, cControlName, cParentForm )

   IF ISOBJECT ( oGif )
      nControlHandle := GetControlHandle ( oGif:hGif, cParentForm )
      _HMG_aControlHandles[ k ] := nControlHandle
      _HMG_aControlIds[ k ] := oGif

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap, nControlHandle )
      ENDIF
   ENDIF

   IF hb_FileExists ( cDiskFile )
      FErase ( cDiskFile )
   ENDIF

RETURN oGif


PROCEDURE _ReleaseAniGif ( GifName, FormName )

   LOCAL hWnd
   LOCAL oGif
   LOCAL i

   IF AScan ( _HMG_aControlNames, GifName ) > 0

      hWnd := GetFormHandle ( FormName )

      FOR i := 1 TO Len ( _HMG_aControlHandles )

         IF _HMG_aControlParentHandles [i] == hWnd .AND. _HMG_aControlType [i] == "ANIGIF" 
            oGif := _HMG_aControlIds [i]
            oGif:End()
            _EraseGifDef ( FormName, i )
            EXIT
         ENDIF

      NEXT i

   ENDIF

RETURN


STATIC PROCEDURE _EraseGifDef ( FormName, i )

   LOCAL mVar

   mVar := '_' + FormName + '_' + _HMG_aControlNames [i]

   IF __mvExist( mVar )
#ifndef _PUBLIC_RELEASE_
      __mvPut( mVar, 0 )
#else
      __mvXRelease( mVar )
#endif
   ENDIF

   _HMG_aControlDeleted        [i] := .T.
   _HMG_aControlType           [i] := ""
   _HMG_aControlNames          [i] := ""
   _HMG_aControlHandles        [i] := 0
   _HMG_aControlParentHandles  [i] := 0
   _HMG_aControlIds            [i] := 0
   _HMG_aControlProcedures     [i] := ""
   _HMG_aControlPageMap        [i] := {}
   _HMG_aControlValue          [i] := Nil
   _HMG_aControlInputMask      [i] := ""
   _HMG_aControllostFocusProcedure  [i] := ""
   _HMG_aControlGotFocusProcedure   [i] := ""
   _HMG_aControlChangeProcedure     [i] := ""
   _HMG_aControlBkColor        [i] := Nil
   _HMG_aControlFontColor      [i] := Nil
   _HMG_aControlDblClick       [i] := ""
   _HMG_aControlHeadClick      [i] := {}
   _HMG_aControlRow            [i] := 0
   _HMG_aControlCol            [i] := 0
   _HMG_aControlWidth          [i] := 0
   _HMG_aControlHeight         [i] := 0
   _HMG_aControlSpacing        [i] := 0
   _HMG_aControlContainerRow   [i] := 0
   _HMG_aControlContainerCol   [i] := 0
   _HMG_aControlPicture        [i] := ''
   _HMG_aControlContainerHandle[i] := 0
   _HMG_aControlFontName       [i] := ''
   _HMG_aControlFontSize       [i] := 0
   _HMG_aControlToolTip        [i] := ''
   _HMG_aControlRangeMin       [i] := 0
   _HMG_aControlRangeMax       [i] := 0
   _HMG_aControlCaption        [i] := ''
   _HMG_aControlVisible        [i] := .F.
   _HMG_aControlHelpId         [i] := 0
   _HMG_aControlFontHandle     [i] := 0
   _HMG_aControlFontAttributes [i] := {}
   _HMG_aControlBrushHandle    [i] := 0
   _HMG_aControlEnabled        [i] := .F.
   _HMG_aControlMiscData1      [i] := 0
   _HMG_aControlMiscData2      [i] := ''

RETURN


#include "hbclass.ch"

CLASS TGif

   DATA  hGif
   DATA  cFilename
   DATA  cParentName
   DATA  cControlName
   DATA  aPictData
   DATA  aImageData
   DATA  nTotalFrames
   DATA  nCurrentFrame
   DATA  nDelay
   DATA  aDelay
   Data  cTimer

   METHOD New( cFileName, nTop, nLeft, nBottom, nRight, nDelay, aBKColor, cControlName, cParentName )

   METHOD PlayGif()

   METHOD Play() INLINE GifPlay( Self )

   METHOD Update()

   METHOD Stop() INLINE GifStop( Self )

   METHOD RestartGif()

   METHOD Restart() INLINE ::RestartGif()

   METHOD IsRunning() INLINE GifIsRunning( Self )

   METHOD End()

ENDCLASS


METHOD New( cFileName, nTop, nLeft, nBottom, nRight, nDelay, aBKColor, cControlName, cParentName ) CLASS TGif

   LOCAL nId
   LOCAL aPictures := {}, aImageInfo := {}

   hb_default( @cParentName, _HMG_ActiveFormName )
   hb_default( @nTop, 0 )
   hb_default( @nLeft, 0 )
   hb_default( @nBottom, 100 )
   hb_default( @nRight, 100 )
   hb_default( @nDelay, 10 )

   ::cParentName  := cParentName
   ::cControlName := cControlName
   ::cFileName    := cFileName

   IF ! LoadGif( cFileName, @aPictures, @aImageInfo, Self )
      aPictures := { "" }
      aImageInfo := { "" }
   ENDIF

   ::nTotalFrames := Len( aPictures )
   ::nCurrentFrame := 1

   ::nDelay := nDelay

   ::aPictData  := AClone( aPictures )
   ::aImageData := AClone( aImageInfo )

   nId := _GetId()

   ::hGif := cControlName + hb_ntos( nId )

   @ nTop, nLeft IMAGE ( ::hGif ) PARENT ( cParentName ) PICTURE cFileName ;
      WIDTH nRight HEIGHT nBottom STRETCH BACKGROUNDCOLOR aBKColor TRANSPARENT

   IF ::nTotalFrames > 1
      ::cTimer := "tgif_tmr_" + hb_ntos( nId )
      DEFINE TIMER ( ::cTimer ) ;
         OF (cParentName) ;
         INTERVAL ::aDelay[ ::nCurrentFrame ] ;
         ACTION ::PlayGif()

      SetProperty( cParentName, ::hGif, "Picture", ::aPictData[ ::nCurrentFrame ] )
   ENDIF

RETURN Self


METHOD PlayGif() CLASS TGif

   IF ::nCurrentFrame < ::nTotalFrames
      ::nCurrentFrame++
   ELSE
      ::nCurrentFrame := 1
   ENDIF

   SetProperty( ::cParentName, ::hGif, "Picture", ::aPictData[ ::nCurrentFrame ] )
   SetProperty( ::cParentName, ::cTimer, "Value", ::aDelay[ ::nCurrentFrame ] )

RETURN NIL


METHOD Update() CLASS TGif

   IF ! Empty( ::hGif ) .and. _IsControlDefined ( ::hGif, ::cParentName )

      IF GetProperty( ::cParentName, ::hGif, "Row" ) <> GetProperty( ::cParentName, ::cControlName, "Row" ) .OR. ;
         GetProperty( ::cParentName, ::hGif, "Col" ) <> GetProperty( ::cParentName, ::cControlName, "Col" ) .OR. ;
         GetProperty( ::cParentName, ::hGif, "Width" )  <> GetProperty( ::cParentName, ::cControlName, "Width" ) .OR. ;
         GetProperty( ::cParentName, ::hGif, "Height" ) <> GetProperty( ::cParentName, ::cControlName, "Height" )

         SetProperty( ::cParentName, ::hGif, "Row", GetProperty( ::cParentName, ::cControlName, "Row" ) )
         SetProperty( ::cParentName, ::hGif, "Col", GetProperty( ::cParentName, ::cControlName, "Col" ) )
         SetProperty( ::cParentName, ::hGif, "Width", GetProperty( ::cParentName, ::cControlName, "Width" ) )
         SetProperty( ::cParentName, ::hGif, "Height", GetProperty( ::cParentName, ::cControlName, "Height" ) )
      ENDIF
         
   ENDIF

RETURN NIL


METHOD RestartGif() CLASS TGif

   LOCAL aPictures := {}, aImageInfo := {}

   GifStop( Self )
   
   AEval( ::aPictData, { |f| FErase( f ) } )

   IF LoadGif( ::cFileName, @aPictures, @aImageInfo, Self )

      ::nTotalFrames := Len( aPictures )
      ::aPictData  := AClone( aPictures )
      ::aImageData := AClone( aImageInfo )

      ::nCurrentFrame := 1
      ::Update()

   ENDIF

   ::Play()

RETURN NIL


METHOD End() CLASS TGif

   IF _IsControlDefined ( ::cControlName , ::cParentName )

      AEval( ::aPictData, { |f| FErase( f ) } )

      IF ::nTotalFrames > 1
         DoMethod( ::cParentName, ::cTimer, 'Release' )
      ENDIF

      IF _IsControlDefined ( ::hGif , ::cParentName )
         _ReleaseControl ( ::hGif, ::cParentName )
      ENDIF

   ENDIF

RETURN NIL

/*
 *  Auxiliary static functions
 */

STATIC FUNCTION GifPlay( oGif )

   IF oGif:nTotalFrames > 1
      SetProperty( oGif:cParentName, oGif:cTimer, 'Enabled', .T. )
   ENDIF

RETURN NIL


STATIC FUNCTION GifStop( oGif )

   IF oGif:nTotalFrames > 1
      SetProperty( oGif:cParentName, oGif:cTimer, 'Enabled', .F. )
   ENDIF

RETURN NIL


STATIC FUNCTION GifIsRunning( oGif )

   LOCAL lRunning := .F.

   IF oGif:nTotalFrames > 1
      lRunning := GetProperty( oGif:cParentName, oGif:cTimer, 'Enabled' )
   ENDIF

RETURN lRunning


/*
 * h_Gif89.prg
 *
 * Author: P.Chornyj <myorg63@mail.ru>
 */

#include "fileio.ch"

/*
*/
FUNCTION LoadGif( GIF, aFrames, aImgInfo, oGif )

   LOCAL path := GetTempFolder()
   LOCAL cGifHeader
   LOCAL cGifEnd := Chr( 0 ) + Chr( 33 ) + Chr( 249 )
   LOCAL cStream
   LOCAL cFile
   LOCAL cPicBuf
   LOCAL imgHeader
   LOCAL nImgCount
   LOCAL nFileHandle
   LOCAL i, j

   STATIC nID := 0

   nID++

   oGif:aDelay := {}
   hb_default( @aFrames, {} )
   hb_default( @aImgInfo, {} )

   IF ! ReadFromStream( GIF, @cStream )
      RETURN FALSE
   ENDIF

   nImgCount := 0
   i := 1
   j := At( cGifEnd, cStream, i ) + 1
   cGifHeader = Left( cStream, j )

   i := j + 2

   /* Split GIF Files at separate pictures and load them into ImageList */

   DO WHILE .T.

      nImgCount++

      j := At( cGifEnd, cStream, i ) + 3

      IF j > Len( cGifEnd )
         cFile := path + "\" + cFileNoExt( GIF ) + "_frame_" + hb_ntos( nID ) + "_" + StrZero( nImgCount, 4 ) + ".gif"
         nFileHandle := FCreate( cFile, FC_NORMAL )
         IF FError() <> 0
            RETURN FALSE
         ENDIF

         cPicBuf := cGifHeader + SubStr( cStream, i - 1, j - i )
         imgHeader = Left( SubStr ( cStream, i - 1, j - i ), 16 )

         IF FWrite( nFileHandle, cPicBuf ) <> Len( cPicBuf )
            RETURN FALSE
         ENDIF

         IF .NOT. FClose( nFileHandle )
            RETURN FALSE
         ENDIF

         AAdd( aFrames, cFile )
         AAdd( oGif:aDelay, GetFrameDelay( imgHeader, oGif:nDelay ) )
      ENDIF

      DO EVENTS

      IF j == 3
         EXIT
      ELSE
         i := j
      ENDIF

   ENDDO

   IF i < Len( cStream )

      cFile := path + "\" + cFileNoExt( GIF ) + "_frame_" + hb_nTos( nID ) + "_" + StrZero( ++nImgCount, 4 ) + ".gif"
      nFileHandle := FCreate( cFile, FC_NORMAL )
      IF FError() <> 0
         RETURN FALSE
      ENDIF

      cPicBuf := cGifHeader + SubStr( cStream, i - 1, Len( cStream ) - i )
      imgHeader := Left( SubStr( cStream, i - 1, Len( cStream ) - i ), 16 )

      IF FWrite( nFileHandle, cPicBuf ) <> Len( cPicBuf )
         RETURN FALSE
      ENDIF

      IF .NOT. FClose( nFileHandle )
         RETURN FALSE
      ENDIF

      AAdd( aFrames, cFile )
      AAdd( oGif:aDelay, GetFrameDelay( imgHeader, oGif:nDelay ) )

   ENDIF

RETURN TRUE

/*
*/
STATIC FUNCTION ReadFromStream( cFile, cStream )

   LOCAL nFileSize
   LOCAL nFileHandle := FOpen( cFile )

   IF FError() == 0
      nFileSize := FSeek( nFileHandle, 0, FS_END )
      cStream   := Space( nFileSize )
      FSeek( nFileHandle, 0, FS_SET )
      FRead( nFileHandle, @cStream, nFileSize )
      FClose( nFileHandle )
   ENDIF

RETURN ( FError() == 0 .AND. .NOT. Empty( cStream ) )

/*
*/
FUNCTION GetFrameDelay( cImageInfo, nDelay )

RETURN ( Bin2W( SubStr( cImageInfo, 4, 2 ) ) * hb_defaultValue( nDelay, 10 ) )
