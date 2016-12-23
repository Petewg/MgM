/*
 * Harbour TGif Class v1.2
 * Copyright 2009-2016 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Last revision 27.06.2016
 *
*/

ANNOUNCE CLASS_TGIF

#include "minigui.ch"

*------------------------------------------------------------------------------*
FUNCTION _DefineAniGif ( cControlName, cParentForm, cFilename, nRow, nCol, nWidth, nHeight, nDelay, aBKColor )
*------------------------------------------------------------------------------*
   LOCAL mVar, k, nControlHandle, nParentFormHandle, oGif

   // If defined inside DEFINE WINDOW structure, determine cParentForm

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      cParentForm := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
   ENDIF

   // If defined inside a Tab structure, adjust position and determine cParentForm

   IF _HMG_FrameLevel > 0
      nCol += _HMG_ActiveFrameCol[ _HMG_FrameLevel ]
      nRow += _HMG_ActiveFrameRow[ _HMG_FrameLevel ]
      cParentForm := _HMG_ActiveFrameParentFormName[ _HMG_FrameLevel ]
   ENDIF

   IF .NOT. _IsWindowDefined ( cParentForm )
      MsgMiniGuiError ( "Window: " + cParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined ( cControlName, cParentForm )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " Already defined." )
   ENDIF

   IF ValType ( cFilename ) <> 'C'
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " PICTURE Property Invalid Type." )
   ENDIF

   IF Empty ( cFilename )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " PICTURE Can't be empty." )
   ENDIF

   // Define public variable associated with control

   mVar := '_' + cParentForm + '_' + cControlName

   nParentFormHandle := GetFormHandle ( cParentForm )

   oGif := TGif():New( cFilename, nRow, nCol, nHeight, nWidth, nDelay, aBKColor, cControlName, cParentForm )

   nControlHandle := GetControlHandle ( oGif:hGif, cParentForm )

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap, nControlHandle )
   ENDIF

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType[ k ] := "ANIGIF"
   _HMG_aControlNames[ k ] :=  cControlName
   _HMG_aControlHandles[ k ] :=  nControlHandle
   _HMG_aControlParentHandles[ k ] :=  nParentFormHandle
   _HMG_aControlIds[ k ] :=  oGif
   _HMG_aControlProcedures[ k ] := ""
   _HMG_aControlPageMap[ k ] :=  {}
   _HMG_aControlValue[ k ] :=  cFilename
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
   _HMG_aControlContainerRow[ k ] :=  iif ( _HMG_FrameLevel > 0, _HMG_ActiveFrameRow[ _HMG_FrameLevel ], -1 )
   _HMG_aControlContainerCol[ k ] :=  iif ( _HMG_FrameLevel > 0, _HMG_ActiveFrameCol[ _HMG_FrameLevel ], -1 )
   _HMG_aControlPicture[ k ] :=  ""
   _HMG_aControlContainerHandle[ k ] :=  0
   _HMG_aControlFontName[ k ] :=  Nil
   _HMG_aControlFontSize[ k ] :=  Nil
   _HMG_aControlFontAttributes[ k ] :=  {}
   _HMG_aControlToolTip[ k ] :=  ''
   _HMG_aControlRangeMin[ k ] :=  0
   _HMG_aControlRangeMax[ k ] :=  0
   _HMG_aControlCaption[ k ] :=  ''
   _HMG_aControlVisible[ k ] :=  .T.
   _HMG_aControlHelpId[ k ] :=  0
   _HMG_aControlFontHandle[ k ] :=  Nil
   _HMG_aControlBrushHandle[ k ] :=  0
   _HMG_aControlEnabled[ k ] :=  .T.
   _HMG_aControlMiscData1[ k ] :=  0
   _HMG_aControlMiscData2[ k ] :=  ''

RETURN oGif


PROCEDURE _ReleaseAniGif ( GifName, FormName )

   LOCAL hWnd, x, oGif
   LOCAL i := AScan ( _HMG_aControlNames, GifName )

   IF i > 0
      hWnd := GetFormHandle ( FormName )
      FOR x := 1 TO Len ( _HMG_aControlHandles )
         IF _HMG_aControlParentHandles [x] == hWnd .AND. _HMG_aControlType [x] == "ANIGIF"
             oGif := _HMG_aControlIds [x]
             oGif:End()
            _EraseGifDef ( FormName, x )
         ENDIF
      NEXT x
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

/*
 * TGif Class
*/

CLASS TGif

   DATA  hGif
   DATA  cFilename
   DATA  nTop
   DATA  nLeft
   DATA  nBottom
   DATA  nRight
   DATA  cParentName

   DATA  aPictData
   DATA  aImageData
   DATA  nTotalFrames
   DATA  nCurrentFrame
   DATA  nWidth
   DATA  nHeight
   DATA  lLopping
   DATA  nDelay

   METHOD New( cFileName, nTop, nLeft, nBottom, nRight, nDelay, aBKColor, cControlName, cParentName )

   METHOD PlayGif( cControlName, cParentName )

   METHOD Play() INLINE GifPlay( ::hGif, ::cParentName )
   METHOD Stop() INLINE GifStop( ::hGif, ::cParentName )

   METHOD UpdateGif( cControlName, cParentName )
   METHOD Update() INLINE ::UpdateGif( ::hGif, ::cParentName )

   METHOD RestartGif( cControlName, cParentName )
   METHOD Restart() INLINE ::RestartGif( ::hGif, ::cParentName )

   METHOD IsRunning() INLINE GifIsRunning( ::hGif, ::cParentName )

   METHOD DestroyGif( cControlName, cParentName )
   METHOD End() INLINE ::DestroyGif( ::hGif, ::cParentName )

ENDCLASS


METHOD New( cFileName, nTop, nLeft, nBottom, nRight, nDelay, aBKColor, cControlName, cParentName ) CLASS TGif

   LOCAL aPictInfo := {}, nId, cTimer
   LOCAL aPictures := {}, aImageInfo := {}

   DEFAULT cParentName := _HMG_ActiveFormName, ;
      nTop    := 0, ;
      nLeft   := 0, ;
      nBottom := 100, ;
      nRight  := 100, ;
      nDelay  := 10

   ::nTop    := nTop
   ::nLeft   := nLeft
   ::nBottom := nBottom + nTop
   ::nRight  := nRight + nLeft

   ::cParentName := cParentName
   ::cFileName   := cFileName

   IF ! Empty( cFileName ) .AND. ! File( cFileName )
      RETURN NIL
   ENDIF

   IF ! LoadGif( cFileName, @aPictInfo, @aPictures, @aImageInfo )
      RETURN NIL
   ENDIF

   ::nTotalFrames := Len( aPictures )
   ::nCurrentFrame := 1

   ::nDelay  := nDelay
   ::nWidth  := aPictInfo[ 2 ]
   ::nHeight := aPictInfo[ 3 ]

   ::lLopping := ( ::nWidth <> nRight ) .OR. ( ::nHeight <> nBottom )

   ::aPictData  := AClone( aPictures )
   ::aImageData := AClone( aImageInfo )

   nId := _GetId()

   ::hGif := cControlName + hb_ntos( nId )

   @ nTop, nLeft IMAGE &( ::hGif ) PARENT &cParentName PICTURE cFileName ;
      WIDTH nRight HEIGHT nBottom STRETCH BACKGROUNDCOLOR aBKColor TRANSPARENT

   IF ::nTotalFrames > 1
      cTimer := "tgif_tmr_" + hb_ntos( nId )
      DEFINE TIMER &cTimer ;
         OF &cParentName ;
         INTERVAL GetFrameDelay( ::aImageData[ ::nCurrentFrame ], ::nDelay ) ;
         ACTION ::PlayGif( ::hGif, ::cParentName )

      SetProperty( cParentName, ::hGif, 'Picture', ::aPictData[ ::nCurrentFrame ] )
      SetProperty( cParentName, ::hGif, 'Cargo', { cTimer, ::aPictData, ::nTotalFrames, cFileName } )

   ENDIF

RETURN Self


METHOD PlayGif( cControlName, cParentName ) CLASS TGif

   IF ::nCurrentFrame < ::nTotalFrames
      ::nCurrentFrame++
   ELSE
      ::nCurrentFrame := 1
   ENDIF

   SetProperty( cParentName, cControlName, 'Picture', ::aPictData[ ::nCurrentFrame ] )
   SetProperty( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[ 1 ], 'Value', ;
      GetFrameDelay( ::aImageData[ ::nCurrentFrame ], ::nDelay ) )

   DoMethod( cParentName, cControlName, 'Refresh' )

RETURN NIL


METHOD UpdateGif( cControlName, cParentName ) CLASS TGif

   LOCAL nHeight := iif( ::lLopping, GetProperty( cParentName, cControlName, 'Height' ), ::nHeight )
   LOCAL nWidth := iif( ::lLopping, GetProperty( cParentName, cControlName, 'Width' ), ::nWidth )

   SetProperty( cParentName, cControlName, 'Row', ::nTop )
   SetProperty( cParentName, cControlName, 'Col', ::nLeft )
   SetProperty( cParentName, cControlName, 'Height', nHeight )
   SetProperty( cParentName, cControlName, 'Width', nWidth )

   ::nBottom := nHeight + ::nTop
   ::nRight  := nWidth + ::nLeft

RETURN NIL


METHOD RestartGif( cControlName, cParentName ) CLASS TGif

   LOCAL aPictInfo := {}, cTimer
   LOCAL aPictures := {}, aImageInfo := {}
   LOCAL cOldFile := GetProperty( cParentName, cControlName, 'Cargo' )[ 4 ]

   GifStop( cControlName, cParentName )

   IF LoadGif( ::cFileName, @aPictInfo, @aPictures, @aImageInfo )

      IF cOldFile <> ::cFileName
         AEval( GetProperty( cParentName, cControlName, 'Cargo' )[ 2 ], { |f| FErase( f ) } )
         ::nTotalFrames := Len( aPictures )

         ::aPictData  := AClone( aPictures )
         ::aImageData := AClone( aImageInfo )

         cTimer := GetProperty( cParentName, cControlName, 'Cargo' )[ 1 ]
         SetProperty( cParentName, cControlName, 'Cargo', { cTimer, ::aPictData, ::nTotalFrames, ::cFileName } )
      ENDIF

      ::nWidth  := aPictInfo[ 2 ]
      ::nHeight := aPictInfo[ 3 ]

      ::lLopping := .F.
      ::nCurrentFrame := 1

      ::UpdateGif( cControlName, cParentName )

   ENDIF

   GifPlay( cControlName, cParentName )

RETURN NIL


METHOD DestroyGif( cControlName, cParentName ) CLASS TGif

   LOCAL aPictures := GetProperty( cParentName, cControlName, 'Cargo' )[ 2 ]
   LOCAL TotalFrames := GetProperty( cParentName, cControlName, 'Cargo' )[ 3 ]

   AEval( aPictures, { |f| FErase( f ) } )

   IF TotalFrames > 1
      DoMethod( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[ 1 ], 'Release' )
   ENDIF

RETURN NIL

/*
*/
STATIC FUNCTION GifPlay( cControlName, cParentName )

   LOCAL TotalFrames := GetProperty( cParentName, cControlName, 'Cargo' )[ 3 ]

   IF TotalFrames > 1
      SetProperty( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[ 1 ], 'Enabled', .T. )
   ENDIF

RETURN NIL

/*
*/
STATIC FUNCTION GifStop( cControlName, cParentName )

   LOCAL TotalFrames := GetProperty( cParentName, cControlName, 'Cargo' )[ 3 ]

   IF TotalFrames > 1
      SetProperty( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[ 1 ], 'Enabled', .F. )
   ENDIF

RETURN NIL

/*
*/
STATIC FUNCTION GifIsRunning( cControlName, cParentName )

   LOCAL lRunning := .F.
   LOCAL TotalFrames := GetProperty( cParentName, cControlName, 'Cargo' )[ 3 ]

   IF TotalFrames > 1
      lRunning := GetProperty( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[ 1 ], 'Enabled' )
   ENDIF

RETURN lRunning

/*
 * h_Gif89.prg
 *
 * Author: P.Chornyj <myorg63@mail.ru>
 *
*/

#include "fileio.ch"

#ifndef __XHARBOUR__
  #xtranslate At(<a>,<b>,[<x,...>]) => hb_At(<a>,<b>,<x>)
#endif

#define Alert( c ) MsgExclamation( c, "LoadGif", , .f. )

/*
*/
FUNCTION LoadGif( GIF, aGifInfo, aFrames, aImgInfo, path )

   LOCAL cGifHeader, cGifEnd := Chr( 0 ) + Chr( 33 ) + Chr( 249 )
   LOCAL i, j, nImgCount, nFileHandle
   LOCAL cStream, cFile, cPicBuf, imgHeader
   LOCAL bLoadGif := TRUE

   aGifInfo := Array( 3 )
   aFrames := {}
   aImgInfo := {}
   DEFAULT PATH TO GetTempFolder()

   IF ! File( GIF )
      Alert( "File " + GIF + " is not found!" )
      RETURN FALSE
   ENDIF

   IF ! ReadFromStream( GIF, @cStream )
      Alert( "Error when reading file " + GIF )
      RETURN FALSE
   ENDIF

   nImgCount := 0
   i := 1
   j := At( cGifEnd, cStream, i ) + 1

   cGifHeader = Left( cStream, j )

   IF  Left( cGifHeader, 3 ) <> "GIF"
      Alert( "This file is not a GIF file!" )
      RETURN FALSE
   ENDIF

   aGifInfo[ 1 ] := SubStr( cGifHeader, 4, 3 )          // GifVersion
   aGifInfo[ 2 ] := Bin2W( SubStr( cGifHeader, 7, 2 ) ) // LogicalScreenWidth
   aGifInfo[ 3 ] := Bin2W( SubStr( cGifHeader, 9, 2 ) ) // LogicalScreenHeight

   i := j + 2

 /* Split GIF Files at separate pictures
           and load them into ImageList */

   DO WHILE .T.
      nImgCount++
      j := At( cGifEnd, cStream, i ) + 3
      IF j > Len( cGifEnd )
         cFile := path + "\" + cFileNoExt( GIF ) + "_frame_" + StrZero( nImgCount, 4 ) + ".gif"
         nFileHandle := FCreate( cFile, FC_NORMAL )
         IF FError() <> 0
#ifdef _DEBUG_
            Alert( "Error while creating a temp file:" + Str( FError() ) )
#endif
            RETURN FALSE
         ENDIF

         cPicBuf := cGifHeader + SubStr( cStream, i -1, j - i )
         imgHeader = Left( SubStr ( cStream, i -1, j - i ), 16 )

         IF FWrite( nFileHandle, cPicBuf ) <> Len( cPicBuf )
#ifdef _DEBUG_
            Alert( "Error while writing a file:" + Str( FError() ) )
#endif
            RETURN FALSE
         ENDIF

         IF .NOT. FClose( nFileHandle )
#ifdef _DEBUG_
            Alert( "Error while closing a file:" + Str( FError() ) )
#endif
            RETURN FALSE
         ENDIF

         ASize( aFrames, nImgCount )
         aFrames[ nImgCount ]  := cFile

         ASize( aImgInfo, nImgCount )
         aImgInfo[ nImgCount ] := imgHeader
      ENDIF

      DO EVENTS

      IF j == 3
         EXIT
      ELSE
         i := j
      ENDIF
   END DO

   IF i < Len( cStream )
      cFile := path + "\" + cFileNoExt( GIF ) + "_frame_" + StrZero( nImgCount, 4 ) + ".gif"
      nFileHandle := FCreate( cFile, FC_NORMAL )
      IF FError() <> 0
#ifdef _DEBUG_
         Alert( "Error while creating a temp file:" + Str( FError() ) )
#endif
         RETURN FALSE
      ENDIF

      cPicBuf := cGifHeader + SubStr( cStream, i -1, Len( cStream ) - i )
      imgHeader := Left( SubStr( cStream, i -1, Len( cStream ) - i ), 16 )

      IF FWrite( nFileHandle, cPicBuf ) <> Len( cPicBuf )
#ifdef _DEBUG_
         Alert( "Error while writing a file:" + Str( FError() ) )
#endif
         RETURN FALSE
      ENDIF

      IF .NOT. FClose( nFileHandle )
#ifdef _DEBUG_
         Alert( "Error while closing a file:" + Str( FError() ) )
#endif
         RETURN FALSE
      ENDIF

      ASize( aFrames, nImgCount )
      aFrames[ nImgCount ]  := cFile

      ASize( aImgInfo, nImgCount )
      aImgInfo[ nImgCount ] := imgHeader
   ENDIF

RETURN bLoadGif

/*
*/
FUNCTION ReadFromStream( cFile, cStream )

   LOCAL nFileHandle := FOpen( cFile )
   LOCAL nFileSize

   IF FError() <> 0
      RETURN FALSE
   ENDIF

   nFileSize := FSeek( nFileHandle, 0, FS_END )
   cStream   := Space( nFileSize )
   FSeek( nFileHandle, 0, FS_SET )
   FRead( nFileHandle, @cStream, nFileSize )
   FClose( nFileHandle )

RETURN ( FError() == 0 .AND. .NOT. Empty( cStream ) )

/*
*/
FUNCTION GetFrameDelay( cImageInfo, nDelay )
   DEFAULT nDelay TO 10

RETURN ( Bin2W( SubStr( cImageInfo, 4, 2 ) ) * nDelay )
