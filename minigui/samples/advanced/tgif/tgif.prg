/*
 * Harbour TGif Class v1.0
 * Copyright 2009 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Last revision 17.12.2009
 *
*/

ANNOUNCE CLASS_TGIF

#include "minigui.ch"
#include "hbclass.ch"

//-----------------------------------------------------------
// Class TGif
//-----------------------------------------------------------

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

   METHOD New( cFileName, nTop, nLeft, nBottom, nRight, nDelay, cParentName )

   METHOD PlayGif( cControlName, cParentName )

   METHOD Play() INLINE GifPlay( ::hGif, ::cParentName )
   METHOD Stop() INLINE GifStop( ::hGif, ::cParentName )

   METHOD UpdateGif()
   METHOD Update() INLINE ::UpdateGif( ::hGif, ::cParentName )

   METHOD RestartGif()
   METHOD Restart() INLINE ::RestartGif( ::hGif, ::cParentName )

   METHOD IsRunning() INLINE GifIsRunning( ::hGif, ::cParentName )

   METHOD DestroyGif()
   METHOD End() INLINE ::DestroyGif( ::hGif, ::cParentName )

ENDCLASS

//----------------------------------------------------------------//

METHOD New( cFileName, nTop, nLeft, nBottom, nRight, nDelay, cParentName ) CLASS TGif

    local aPictInfo := {}, nId, cControlName, cTimer
    local aPictures := {}, aImageInfo := {}

    default cParentName := _HMG_ActiveFormName,;
            nTop    := 0,;
            nLeft   := 0,;
            nBottom := 100,;
            nRight  := 100,;
            nDelay  := 10

   ::nTop    := nTop
   ::nLeft   := nLeft
   ::nBottom := nBottom + nTop
   ::nRight  := nRight + nLeft         

   ::cParentName := cParentName
   ::cFileName   := cFileName

   if ! Empty( cFileName ) .And. ! File( cFileName )
      return nil
   endif

   if ! LoadGif( cFileName, @aPictInfo, @aPictures, @aImageInfo )
      return nil
   endif

   ::nTotalFrames := Len( aPictures )
   ::nCurrentFrame := 1

   ::nDelay  := nDelay
   ::nWidth  := aPictInfo [2]
   ::nHeight := aPictInfo [3]

   ::lLopping := (::nWidth <> nRight) .OR. (::nHeight <> nBottom)

   ::aPictData  := Aclone( aPictures )
   ::aImageData := Aclone( aImageInfo )

   nId := _GetId()
   cControlName := "_tgif_Img_" + hb_ntos(nId)

   ::hGif     := cControlName

   @ nTop, nLeft IMAGE &cControlName PARENT &cParentName PICTURE cFileName WIDTH nRight HEIGHT nBottom STRETCH TRANSPARENT

   IF ::nTotalFrames > 1
	cTimer := "_tgif_Tmr_" + hb_ntos(nId)
	DEFINE TIMER &cTimer ;
		OF &cParentName ;
		INTERVAL GetFrameDelay( ::aImageData [ ::nCurrentFrame ], ::nDelay ) ;
                ACTION ::PlayGif( ::hGif, ::cParentName )

	SetProperty( cParentName, cControlName, 'Picture', ::aPictData [ ::nCurrentFrame ] )
	SetProperty( cParentName, cControlName, 'Cargo', { cTimer, ::aPictData, ::nTotalFrames, cFileName } )

   ENDIF

Return self

METHOD PlayGif( cControlName, cParentName ) CLASS TGif

	IF ::nCurrentFrame < ::nTotalFrames
		::nCurrentFrame ++
	ELSE
		::nCurrentFrame := 1
	ENDIF

	SetProperty( cParentName, cControlName, 'Picture', ::aPictData [ ::nCurrentFrame ] )
	SetProperty( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[1], 'Value', ;
		GetFrameDelay( ::aImageData [ ::nCurrentFrame ], ::nDelay ) )

	DoMethod( cParentName, cControlName, 'Refresh' )

Return Nil

METHOD UpdateGif( cControlName, cParentName ) CLASS TGif

	local nHeight := iif( ::lLopping, GetProperty( cParentName, cControlName, 'Height' ), ::nHeight )
	local nWidth := iif( ::lLopping, GetProperty( cParentName, cControlName, 'Width' ), ::nWidth )

	SetProperty( cParentName, cControlName, 'Row', ::nTop )
	SetProperty( cParentName, cControlName, 'Col', ::nLeft )
	SetProperty( cParentName, cControlName, 'Height', nHeight )
	SetProperty( cParentName, cControlName, 'Width', nWidth )

	::nBottom := nHeight + ::nTop
	::nRight  := nWidth + ::nLeft

Return Nil

METHOD RestartGif( cControlName, cParentName ) CLASS TGif

	local aPictInfo := {}, cTimer
	local aPictures := {}, aImageInfo := {}
	local cOldFile := GetProperty( cParentName, cControlName, 'Cargo' )[4]

	GifStop( cControlName, cParentName )

	IF LoadGif( ::cFileName, @aPictInfo, @aPictures, @aImageInfo )

		IF cOldFile <> ::cFileName
			Aeval( GetProperty( cParentName, cControlName, 'Cargo' )[2], {|f| FErase( f ) } )
			::nTotalFrames := Len( aPictures )

			::aPictData  := Aclone( aPictures )
			::aImageData := Aclone( aImageInfo )

			cTimer := GetProperty( cParentName, cControlName, 'Cargo' )[1]
			SetProperty( cParentName, cControlName, 'Cargo', { cTimer, ::aPictData, ::nTotalFrames, ::cFileName } )
		ENDIF

		::nWidth  := aPictInfo [2]
		::nHeight := aPictInfo [3]

		::lLopping := .F.
		::nCurrentFrame := 1

		::UpdateGif( cControlName, cParentName )

	ENDIF

	GifPlay( cControlName, cParentName )

Return Nil

METHOD DestroyGif( cControlName, cParentName ) CLASS TGif

	local aPictures := GetProperty( cParentName, cControlName, 'Cargo' )[2]
	local TotalFrames := GetProperty( cParentName, cControlName, 'Cargo' )[3]

	Aeval( aPictures, {|f| FErase( f ) } )

	IF TotalFrames > 1
		DoMethod( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[1], 'Release' )
	ENDIF

Return Nil

/*
*/
Static Function GifPlay( cControlName, cParentName )

	local TotalFrames := GetProperty( cParentName, cControlName, 'Cargo' )[3]

	IF TotalFrames > 1
		SetProperty( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[1], 'Enabled', .T. )
	ENDIF

Return Nil

/*
*/
Static Function GifStop( cControlName, cParentName )

	local TotalFrames := GetProperty( cParentName, cControlName, 'Cargo' )[3]

	IF TotalFrames > 1
		SetProperty( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[1], 'Enabled', .F. )
	ENDIF

Return Nil

/*
*/
Static Function GifIsRunning( cControlName, cParentName )

	local lRunning := .F.
	local TotalFrames := GetProperty( cParentName, cControlName, 'Cargo' )[3]

	IF TotalFrames > 1
		lRunning := GetProperty( cParentName, GetProperty( cParentName, cControlName, 'Cargo' )[1], 'Enabled' )
	ENDIF

Return lRunning

/*
*/
#include "h_Gif89.prg"

