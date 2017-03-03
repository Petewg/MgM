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
LOCAL cGifHeader, cGifEnd := Chr(0) + Chr(33) + Chr(249)
LOCAL i, j, nImgCount, nFileHandle
LOCAL cStream, cFile, cPicBuf, imgHeader
LOCAL bLoadGif := TRUE

	aGifInfo := Array( 3 )
	aFrames := {}
	aImgInfo := {}
	DEFAULT path TO GetTempFolder()

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

	aGifInfo[ 1 ] := Substr( cGifHeader, 4, 3 )          // GifVersion
	aGifInfo[ 2 ] := Bin2W( Substr( cGifHeader, 7, 2 ) ) // LogicalScreenWidth
	aGifInfo[ 3 ] := Bin2W( Substr( cGifHeader, 9, 2 ) ) // LogicalScreenHeight

	i := j + 2

	/* Split GIF Files at separate pictures 
           and load them into ImageList */

	DO WHILE .T.  
	        nImgCount ++
		j := At( cGifEnd, cStream, i ) + 3
	        IF j > Len( cGifEnd )
		        cFile := path + "\" + cFileNoExt( GIF) + "_frame_" + StrZero( nImgCount, 4 ) + ".gif"
			nFileHandle := FCreate( cFile, FC_NORMAL )
			IF FError() <> 0
				Alert( "Error while creatingg a temp file:" + Str( Ferror() ) )
				RETURN FALSE
			ENDIF

	                cPicBuf := cGifHeader + Substr( cStream, i - 1, j - i )
	                imgHeader = Left( Substr ( cStream, i - 1, j - i ), 16 )

			IF FWrite( nFileHandle, cPicBuf ) <> Len( cPicBuf )
				Alert( "Error while writing a file:" + Str( FError() ) )
				RETURN FALSE
			ENDIF

                        IF .NOT. FClose( nFileHandle )
				Alert( "Error while closing a file:" + Str( FError() ) )
				RETURN FALSE
			ENDIF

	       		aSize( aFrames, nImgCount )
                        aFrames[ nImgCount ]  := cFile

       			aSize( aImgInfo, nImgCount )
	                aImgInfo[ nImgCount ] := imgHeader
		ENDIF
		
		DoEvents()

                IF j == 3
			EXIT
		ELSE
			i := j	
		ENDIF
	END DO	

	IF i < Len( cStream )
	        cFile := path + "\" + cFileNoExt( GIF) + "_frame_" + StrZero( nImgCount, 4 ) + ".gif"
		nFileHandle := FCreate( cFile, FC_NORMAL )
		IF FError() <> 0
			Alert( "Error while creatingg a temp file:" + Str( Ferror() ) )
			RETURN FALSE
		ENDIF

                cPicBuf := cGifHeader + Substr( cStream, i - 1, Len( cStream ) - i )
                imgHeader := Left( Substr( cStream, i - 1, Len( cStream ) - i ), 16 )

		IF FWrite( nFileHandle, cPicBuf ) <> Len( cPicBuf )
			Alert( "Error while writing a file:" + Str( FError() ) )
			RETURN FALSE
		ENDIF

                IF .NOT. FClose( nFileHandle )
			Alert( "Error while closing a file:" + Str( FError() ) )
			RETURN FALSE
		ENDIF

       		aSize( aFrames, nImgCount )
                aFrames[ nImgCount ]  := cFile

		aSize( aImgInfo, nImgCount )
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

RETURN ( FError( ) == 0 .AND. .NOT. Empty( cStream ) )

/*
*/
FUNCTION GetFrameDelay( cImageInfo, nDelay )
	DEFAULT nDelay TO 10
RETURN ( Bin2W( Substr( cImageInfo, 4, 2) ) * nDelay )
