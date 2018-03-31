/*
 * Harbour TTaskbarNotifier Class v1.0 for MiniGUI Ex.
 * by P.Chornyj <myorg63@mail.ru>
 * Partialy based on C# TaskbarNotifier Class v1.0 by John O'Byrne
 *
 * The TaskbarNotifier class allows to display 
 * an MSN Messenger-like animated popup with a skinned background
 *
 * Last revision 19.09.2007
 *
*/

ANNOUNCE CLASS_TTASKBARNOTIFIER

REQUEST CLASS_TTASKBARNOTIFIER_WP
REQUEST CLASS_TTIMER

#include "minigui.ch"
#include "hbclass.ch"
#include "taskbarnotifier.ch"

// mix
#define OBJ_FONT         6
#define OBJ_BITMAP       7  
#define OBJ_REGION       8

#define BM_WIDTH         1
#define BM_HEIGHT        2

#define WM_PAINT      15

#define SWP_NOZORDER     4
#define SWP_NOACTIVATE   16

#define WS_EX_TOOLWINDOW 128

#define MK_LBUTTON       1
#define MK_RBUTTON       2

/* -------------------- CLASS TTASKBARNOTIFIER ----------------- */
CLASS TTaskbarNotifier

HIDDEN:
   DATA Timer                               

   DATA nShowEvents           INIT 10
   DATA nHideEvents           INIT 10
   DATA nVisibleEvents        INIT 10
   DATA nIncrementShow        INIT 10
   DATA nIncrementHide        INIT 10

   DATA WARectangle           INIT { 0, 0, 0, 0 }  // WorkAreaRectangle 

   DATA height                INIT 0
   DATA width                 INIT 0
   DATA left                  INIT 0
   DATA top                   INIT 0

   DATA nPaintLevel           INIT 0 

PROTECTED:
   CLASSDATA aTaskbarNotifiers INIT {}

   DATA Name                  INIT ""         // TaskbarNotifier control name
   DATA TaskbarState          INIT TNS_HIDDEN 
   DATA WndHandle             INIT 0          // TaskbarNotifier window handle

   DATA BackgroundBitmap      INIT Nil   
   DATA BackgroundBitmapName  INIT ""         
   DATA BackgroundBitmapSize  INIT { 0, 0, 1 }         

   DATA CloseBitmap           INIT Nil    
   DATA CloseBitmap1          INIT Nil    
   DATA CloseBitmap2          INIT Nil    
   DATA CloseBitmap3          INIT Nil    
   DATA CloseBitmapName       INIT ""    
   DATA CloseBitmapSize       INIT { 0, 0, 1 }    
   DATA CloseBitmapLocation   INIT { 0, 0 }    
   DATA lCloseButtonClickable INIT FALSE

   DATA sTitleText            INIT "Title"
   DATA aTitleRectangle       INIT { 0, 0, 0, 0 }  
   DATA nTitleNormalColor     INIT 0
   DATA nTitleHoverColor      INIT 0
   DATA oTitleNormalFont      INIT Nil
   DATA oTitleHoverFont       INIT Nil
   DATA lTitleClickable       INIT FALSE
   DATA bTitleOnClickEvent    INIT Nil

   DATA sContentText          INIT ""     
   DATA aContentRectangle     INIT { 0, 0, 0, 0 }  
   DATA nContentNormalColor   INIT 0
   DATA nContentHoverColor    INIT 0
   DATA oContentNormalFont    INIT Nil
   DATA oContentHoverFont     INIT Nil
   DATA lContentClickable     INIT FALSE
   DATA bContentOnClickEvent  INIT Nil

   DATA lIsMouseOverPopup     INIT FALSE
   DATA lIsMouseOverClose     INIT FALSE
   DATA lIsMouseOverContent   INIT FALSE
   DATA lIsMouseOverTitle     INIT FALSE
   DATA lIsMouseDown          INIT FALSE

   DATA lKeepVisibleOnMouseOver INIT FALSE
   DATA lReShowOnMouseOver      INIT FALSE

   METHOD DrawBackground( dc )
   METHOD DrawCloseButton( dc )
   METHOD DrawContent( dc )
   METHOD DrawTitle( dc )
   METHOD OnTimerEvent()
   METHOD SetBounds( n1, n2, n3, n4 ) INLINE SetWindowPos( ::WndHandle, -1, n1, n2, n3, n4, 20 /* SWP_NOZORDER + SWP_NOACTIVATE*/ )
   METHOD SetGetColor( e, aValue )
   METHOD SetGetFont( e, oValue )
   METHOD SetGetRect( e, n1, n2, n3, n4 )
   METHOD SetGetText( e, sValue )

EXPORTED:
   METHOD Init( sBitmapFile ) CONSTRUCTOR
   DESTRUCTOR TNDestroy

   METHOD Show( strTitle, strContent, nTimeToShow, nTimeToStay, nTimeToHide )
   METHOD Hide()

   METHOD TitleText( s )                INLINE ::SetGetText( @::sTitleText, s )
   METHOD TitleRect( n1, n2, n3, n4 )   INLINE ::SetGetRect( @::aTitleRectangle, n1, n2, n3, n4 )
   METHOD TitleNormalColor( a )         INLINE ::SetGetColor( @::nTitleNormalColor, a )
   METHOD TitleHoverColor( a )          INLINE ::SetGetColor( @::nTitleHoverColor, a )
   METHOD TitleNormalFont( o )          INLINE ::SetGetFont( @::oTitleNormalFont, o )
   METHOD TitleHoverFont( o )           INLINE ::SetGetFont( @::oTitleHoverFont, o )
   METHOD TitleOnClickEvent( l, blk )

   METHOD ContentText( s )              INLINE ::SetGetText( @::sContentText, s )
   METHOD ContentRect( n1, n2, n3, n4 ) INLINE ::SetGetRect ( @::aContentRectangle, n1, n2, n3, n4 )
   METHOD ContentNormalColor( a )       INLINE ::SetGetColor( @::nContentNormalColor, a )
   METHOD ContentHoverColor( a )        INLINE ::SetGetColor( @::nContentHoverColor, a )
   METHOD ContentNormalFont( o )        INLINE ::SetGetFont( @::oContentNormalFont, o )
   METHOD ContentHoverFont( o )         INLINE ::SetGetFont( @::oContentHoverFont, o )
   METHOD ContentOnClickEvent( l, blk )

   METHOD CloseButtonClickable( l )

   METHOD OnMouseEnter( n1, n2 )
   METHOD OnMouseMove( n1, n2 )
   METHOD OnMouseLeave( n1, n2 )
   METHOD OnMouseDblClick( n1, n2 )

   METHOD OnPaint( )  

   METHOD KeepVisibleOnMouseOver( l )
   METHOD ReShowOnMouseOver( l )      

//   UNDECLARED METHOD ClassName()  INLINE ( "TTaskbarNotifier" )
   UNDECLARED METHOD GetById( n ) 
   UNDECLARED METHOD GetByName( s ) 
   UNDECLARED METHOD ObjectName() INLINE ::Name
ENDCLASS

/*
*/
METHOD Init( sBitmapFile /*, sCloseBitmapFile*/ ) CLASS TTaskbarNotifier //EXPORTED
LOCAL nRegion
LOCAL wcName := "TaskBarNotifier_" + AllTRim( Str( _GetId() ) )
LOCAL Brush, oldBrush

   ::Name := wcName
   ::BackgroundBitmapName := sBitmapFile

   // Load bitmaps
   ::BackgroundBitmap := LoadBitmapFromRes( sBitmapFile )
   IF GetObjectType( ::BackgroundBitmap ) <> OBJ_BITMAP
      ::BackgroundBitmap := LoadBitmapFromFile( sBitmapFile )
   ENDIF

   IF GetObjectType( ::BackgroundBitmap ) <> OBJ_BITMAP
      MsgMiniGuiError ( "TaskbarNotifier: LoadBitmap error." )
   ENDIF
   ::BackgroundBitmapSize := GetBitmapSize( ::BackgroundBitmap )

   /*
   ::CloseBitmap := LoadBitmapFromRes( sCloseBitmapFile )
   IF GetObjectType( ::CloseBitmap ) <> OBJ_BITMAP
      ::BackgroundBitmap := LoadBitmapFromFile( sCloseBitmapFile )
   ENDIF

   IF GetObjectType( ::CloseBitmap ) <> OBJ_BITMAP
      MsgMiniGuiError ( "TaskbarNotifier: LoadBitmap error. Program Terminated" )
   ENDIF
   ::CloseBitmapSize := GetBitmapSize( ::BackgroundBitmap )
   ::CloseBitmapSize[ BM_HEIGHT ] := ::CloseBitmapSize[ BM_WIDTH ] / 3

   SplitBitmap( ::BackgroundBitmap, 1, 3, @::CloseBitmap1, @::CloseBitmap2, @::CloseBitmap3 )

   IF ( ( GetObjectType( ::CloseBitmap1 ) <> OBJ_BITMAP ) .OR. ( GetObjectType( ::CloseBitmap2 ) <> OBJ_BITMAP ) .OR. ( GetObjectType( ::CloseBitmap3 ) <> OBJ_BITMAP ) )
      MsgMiniGuiError ( "TaskbarNotifier: BitmapSplit error. Program Terminated" )
   ENDIF
   */

   // Create region from bitmap
   nRegion := BitmapToRegion( ::BackgroundBitmap )
   IF GetObjectType( nRegion ) <> OBJ_REGION
      MsgMiniGuiError ( "TaskbarNotifier: BitmapToRegion error." )
   ENDIF

   // Create a window
   // UnRegisterWindow( wcName ) 
   IF ( ! RegisterTaskbarNotifierWindow( wcName ) )
      MsgMiniGuiError ( "TaskbarNotifier: RegisterTaskbarNotifierWindow error." )
   ENDIF

   ::WndHandle := InitWindow( NIL, 0, 0,;
                                ::BackgroundBitmapSize[1],;
                                ::BackgroundBitmapSize[2],;
                                TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, wcName, 0, FALSE, FALSE, FALSE, FALSE, FALSE )

   IF ! IsWindowHandle( ::WndHandle )
      MsgMiniGuiError ( "TaskbarNotifier: InitWindow error." )
   ENDIF

   ChangeStyle( ::WndHandle, WS_EX_TOOLWINDOW, , .t. )

   SetWindowBitmapRgn( ::WndHandle, nRegion )

   ::Timer := TTimer():New( ::WndHandle )
   ::Timer:OnTimer( {|| ::OnTimerEvent } )

   // Register object 
   AAdd( ::aTaskbarNotifiers, @Self )
RETURN Self

/*
*/
PROCEDURE TNDestroy() CLASS TTaskbarNotifier //EXPORTED
LOCAL nPos := 0
LOCAL TaskbarNotifierName := ::Name

   // Destroy objects
   IF ::BackgroundBitmap <> NIL
      DeleteObject( ::BackgroundBitmap )
   ENDIF
/*
   IF ::CloseBitmap <> NIL
      DeleteObject( ::CloseBitmap )
   ENDIF

   IF ::CloseBitmap1 <> NIL
      DeleteObject( ::CloseBitmap1 )
   ENDIF

   IF ::CloseBitmap2 <> NIL
      DeleteObject( ::CloseBitmap2 )
   ENDIF

   IF ::CloseBitmap3 <> NIL
      DeleteObject( ::CloseBitmap3 )
   ENDIF
*/
   DestroyWindow( ::WndHandle )
   UnRegisterWindow( ::Name ) 

   // Unregister object 
   nPos := AScan( ::aTaskbarNotifiers, { |o| o:Name == TaskbarNotifierName } )
   IF nPos <> 0  
      ADel( ::aTaskbarNotifiers, nPos ) 
      ASize( ::aTaskbarNotifiers, Len( ::aTaskbarNotifiers ) - 1 )
   ENDIF
RETURN

/*
*/
METHOD Show( strTitle, strContent, nTimeToShow, nTimeToStay, nTimeToHide ) CLASS TTaskbarNotifier //EXPORTED
LOCAL nEvents 

   IF ( ::WndHandle == 0 )
      RETURN .F.
   ENDIF   

   DEFAULT strTitle TO "Title", strContent TO ""
   DEFAULT nTimeToShow TO 500
   DEFAULT nTimeToStay TO 3000
   DEFAULT nTimeToHide TO 500

   GetWorkingArea( @::WARectangle )

   IF ( ! Empty( strTitle ) ) 
      ::sTitleText     := strTitle 
   ENDIF

   IF ( ! Empty( strContent ) ) 
      ::sContentText   := strContent
   ENDIF
   ::nVisibleEvents := nTimeToStay

   // We calculate the pixel increment 
   // and the timer value for the showing animation
   IF ( nTimeToShow > 10 )
      nEvents := Min( nTimeToShow/10, ::BackgroundBitmapSize[BM_HEIGHT] ) 
      ::nShowEvents := nTimeToShow / nEvents
      ::nIncrementShow := ( ::BackgroundBitmapSize[BM_HEIGHT] / nEvents )
   ELSE
      ::nShowEvents := 10
      ::nIncrementShow := ::BackgroundBitmapSize[2] 
   ENDIF

   // Calculate the pixel increment 
   // and the timer value for the hiding animation
   IF ( nTimeToHide > 10 )
      nEvents := Min( (nTimeToHide / 10), ::BackgroundBitmapSize[BM_HEIGHT] )
      ::nHideEvents := nTimeToHide / nEvents
      ::nIncrementHide := ( ::BackgroundBitmapSize[BM_HEIGHT] / nEvents )
   ELSE
      ::nHideEvents := 10
      ::nIncrementHide := ::BackgroundBitmapSize[BM_HEIGHT]
   ENDIF

   // WARectangle is WorkArreaRectangle 
   SWITCH   ::TaskbarState
      CASE TNS_HIDDEN
         ::TaskbarState := TNS_APPEARING

         ::height := 0
         ::width  := ::BackgroundBitmapSize[BM_WIDTH]
         ::left   := ::WARectangle[3] - ( ::BackgroundBitmapSize[BM_WIDTH] + 1 )
         ::top    := ::WARectangle[4] - 1
         ::SetBounds( ::left, ::top, ::width, ::height )
         // Show the popup without stealing focus
         ShowWindow( ::WndHandle, SW_SHOWNOACTIVATE )

         ::Timer:Interval := ::nShowEvents
         ::Timer:Start()
         EXIT

      CASE TNS_APPEARING
         EXIT

      CASE TNS_VISIBLE
         ::Timer:Stop()
         ::Timer:Interval := ::nVisibleEvents
         ::Timer:Start()
         EXIT

      CASE TNS_DISAPPEARING
         ::Timer:Stop()
         ::TaskbarState := TNS_VISIBLE

         ::height := ::BackgroundBitmapSize[BM_HEIGHT]
         ::width  := ::BackgroundBitmapSize[BM_WIDTH]
         ::left   := ::WARectangle[3] - ( ::BackgroundBitmapSize[BM_WIDTH] + 1 )
         ::top    := ::WARectangle[4] - ::BackgroundBitmapSize[BM_HEIGHT] - 1
         ::SetBounds( ::left, ::top, ::width, ::height )

         ::Timer:Interval := ::nVisibleEvents
         ::Timer:Start()
         EXIT
   END SWITCH
RETURN Self

/*
*/
METHOD Hide( ) CLASS TTaskbarNotifier //EXPORTED

   IF ::TaskbarState <> TNS_HIDDEN
      ::Timer:Stop()
      ::TaskbarState := TNS_HIDDEN
   ENDIF
RETURN 0

/*
*/
METHOD DrawBackground( dc ) CLASS TTaskbarNotifier //PROTECTED

   DrawGlyph( dc, 0, 0, ::BackgroundBitmapSize[BM_WIDTH], ::BackgroundBitmapSize[BM_HEIGHT],;
   ::BackgroundBitmap, RGB( 255, 255, 0 ), FALSE, FALSE )
RETURN Nil

/*
*/
METHOD DrawCloseButton( dc ) CLASS TTaskbarNotifier //PROTECTED

   IF ( ::lIsMouseOverClose .AND. ::lIsMouseDown )
      DrawGlyph( dc, ::CloseBitmapLocation[1], ::CloseBitmapLocation[2], ::CloseBitmapSize[BM_WIDTH], ::CloseBitmapSize[BM_HEIGHT],;
     ::CloseBitmap3, RGB( 255, 255, 0 ), FALSE, FALSE )
   ELSEIF ::lIsMouseOverClose
      DrawGlyph( dc, ::CloseBitmapLocation[1], ::CloseBitmapLocation[2], ::CloseBitmapSize[BM_WIDTH], ::CloseBitmapSize[BM_HEIGHT],;
     ::CloseBitmap2, RGB( 255, 255, 0 ), FALSE, FALSE )
   ELSE
      DrawGlyph( dc, ::CloseBitmapLocation[1], ::CloseBitmapLocation[2], ::CloseBitmapSize[BM_WIDTH], ::CloseBitmapSize[BM_HEIGHT],;
     ::CloseBitmap2, RGB( 255, 255, 0 ), FALSE, FALSE )
   ENDIF
RETURN Nil

/*
*/
METHOD DrawContent( dc ) CLASS TTaskbarNotifier //PROTECTED

   IF ( ::lIsMouseOverContent )
      _DrawText( dc, ::sContentText, ::aContentRectangle, ::nContentHoverColor, ::oContentHoverFont, .f.)
   ELSE
      _DrawText( dc, ::sContentText, ::aContentRectangle, ::nContentNormalColor, ::oContentNormalFont, .f.)
   ENDIF
RETURN Nil

/*
*/
METHOD DrawTitle( dc ) CLASS TTaskbarNotifier //PROTECTED

   IF ( ::lIsMouseOverTitle )
      _DrawText( dc, ::sTitleText, ::aTitleRectangle, ::nTitleHoverColor, ::oTitleHoverFont, .t.)
   ELSE
      _DrawText( dc, ::sTitleText, ::aTitleRectangle, ::nTitleNormalColor, ::oTitleNormalFont, .t.)
   ENDIF
RETURN Nil

/*
*/
METHOD OnTimerEvent( ) CLASS TTaskbarNotifier //PROTECTED

   SWITCH   ::TaskbarState
      CASE TNS_APPEARING
         IF ( ::height < ::BackgroundBitmapSize[2] )
             ::SetBounds( ::left, ::top -= ::nIncrementShow, ::width, ::height += ::nIncrementShow )
         ELSE
            ::Timer:Stop()

            ::TaskbarState := TNS_VISIBLE

            ::height := ::BackgroundBitmapSize[2]
            ::width  := ::BackgroundBitmapSize[1]
            ::left   := ::WARectangle[3] - ( ::BackgroundBitmapSize[1] + 1 )
            ::top    := ::WARectangle[4] - ::BackgroundBitmapSize[2] - 1
            ::SetBounds( ::left, ::top, ::width, ::height )

            ::Timer:Interval := ::nVisibleEvents
            ::Timer:Start()
         END
         EXIT

      CASE TNS_VISIBLE
         ::Timer:Stop()
         ::Timer:Interval := ::nHideEvents

         IF ( ( ::lKeepVisibleOnMouseOver .AND. ! ::lIsMouseOverPopup) .OR. ( ! ::lKeepVisibleOnMouseOver ) ) 
            ::TaskbarState := TNS_DISAPPEARING
         ENDIF

         ::Timer:Start()
         EXIT

      CASE TNS_DISAPPEARING
         IF ( ::lReShowOnMouseOver .AND. ::lIsMouseOverPopup ) 
            ::TaskbarState := TNS_APPEARING
         ELSE
            IF ( ::top < ::WARectangle[4] )
               ::SetBounds( ::left, ::top += ::nIncrementShow, ::width, ::height -= ::nIncrementShow )
            ELSE
               ::Hide()

               ::height := 0
               ::width  := ::BackgroundBitmapSize[1]
               ::left   := ::WARectangle[3] - ( ::BackgroundBitmapSize[1] + 1 )
               ::top    := ::WARectangle[4] - 1

               ::TaskbarState := TNS_HIDDEN
            ENDIF
         ENDIF
         EXIT
   END SWITCH
RETURN 0

/*
*/
METHOD OnMouseEnter( nKeys, nPos ) CLASS TTaskbarNotifier //EXPORTED

   ::lIsMouseOverPopup := TRUE
   ::lIsMouseOverClose := FALSE
   ::lIsMouseOverContent  := FALSE
   ::lIsMouseOverTitle  := FALSE
   ::lIsMouseDown       := iif( ( nKeys == MK_LBUTTON ) .OR. ( nKeys == MK_RBUTTON ), TRUE, FALSE )
RETURN 1

/*
*/
METHOD OnMouseMove( nKeys, nPos ) CLASS TTaskbarNotifier //EXPORTED
LOCAL aYX := GetCursorPos()
LOCAL x := aYX[2] - ::left 
LOCAL y := aYX[1] - ::top  
LOCAL b1 := ::lIsMouseOverTitle
LOCAL b2 := ::lIsMouseOverContent

   IF ( ( ::aTitleRectangle[3]  >= x .AND. ::aTitleRectangle[1] <= x ) .AND. ;
      ( ::aTitleRectangle[4] >= y .AND. ::aTitleRectangle[2] <= y ) )
      ::lIsMouseOverTitle := TRUE
   ELSE
      ::lIsMouseOverTitle := FALSE
   ENDIF

   IF ( ( ::aContentRectangle[3] >= x .AND. ::aContentRectangle[1] <= x ) .AND. ;
      ( ::aContentRectangle[4] >= y .AND. ::aContentRectangle[2] <= y ) )
      ::lIsMouseOverContent := TRUE
   ELSE
      ::lIsMouseOverContent := FALSE
   ENDIF

   IF ::CloseBitmap <> NIL
      IF ( ( ( ::CloseBitmapLocation[1] + ::CloseBitmapSize[ BM_WIDTH ] ) >= x .AND. ::CloseBitmapLocation[1] <= x ) .AND. ;
         ( ::CloseBitmapLocation[2] + ::CloseBitmapSize[ BM_HEIGHT ] ) >= y .AND. ::CloseBitmapLocation[1] <= y )
         ::lIsMouseOverClose := TRUE
      ELSE
         ::lIsMouseOverClose := FALSE
      ENDIF
   ENDIF

   ::lIsMouseDown := iif( ( nKeys == MK_LBUTTON ) .OR. ( nKeys == MK_RBUTTON ), TRUE, FALSE )

   IF ( ( b1 <> ::lIsMouseOverTitle ) .OR. ( b2 <> ::lIsMouseOverContent ) )
      SendMessage( ::WndHandle, WM_PAINT, 0, 0 )
   ENDIF
RETURN 1

/*
*/
METHOD OnMouseLeave( nKeys, nPos ) CLASS TTaskbarNotifier //EXPORTED

   ::lIsMouseOverPopup := FALSE
   ::lIsMouseOverClose := FALSE
   ::lIsMouseOverContent  := FALSE
   ::lIsMouseOverTitle  := FALSE
   ::lIsMouseDown       := iif( ( nKeys == MK_LBUTTON ) .OR. ( nKeys == MK_RBUTTON ), TRUE, FALSE )
RETURN 1

/*
*/
METHOD OnMouseDblClick( nKeys, nPos ) CLASS TTaskbarNotifier //EXPORTED

   IF ( ::lIsMouseOverTitle )
      IF ( ::lTitleClickable .AND. Hb_IsBlock( ::bTitleOnClickEvent ) )
         Hb_ExecFromArray( ::bTitleOnClickEvent, { nKeys, nPos } )
      ENDIF

   ELSEIF ( ::lIsMouseOverContent )
      IF ( ::lContentClickable .AND. Hb_IsBlock( ::bContentOnClickEvent ) )
         Hb_ExecFromArray( ::bContentOnClickEvent, { nKeys, nPos } )
      ENDIF

   ELSEIF ::lIsMouseOverClose
      ::Hide()
   ELSE
   ENDIF

   //::lIsMouseDown  
RETURN 1

/*
*/
METHOD OnPaint() CLASS TTaskbarNotifier //EXPORTED
LOCAL dc

   IF ( ::nPaintLevel == 0 )
      ::nPaintLevel += 1
      dc := GetDC( ::WndHandle )

      IF ( GetObjectType( ::BackgroundBitmap ) == OBJ_BITMAP )
         ::DrawBackground( dc )
      ENDIF
/*
      IF ( GetObjectType( ::CloseBitmap ) == OBJ_BITMAP )
         ::DrawCloseButton( dc )
      ENDIF
*/
      IF ! Empty( ::sTitleText )
         ::DrawTitle( dc )
      ENDIF

      IF ! Empty( ::sContentText )
         ::DrawContent( dc )
      ENDIF

      ReleaseDC( dc )

      ::nPaintLevel -= 1
   ENDIF
RETURN 0

/*
*/
METHOD KeepVisibleOnMouseOver( lValue ) CLASS TTaskbarNotifier //EXPORTED
LOCAL lOldValue := ::lKeepVisibleOnMouseOver

   IF ( ( PCOUNT() > 0 ) .AND. Hb_IsLogical( lValue ) )
      ::lKeepVisibleOnMouseOver := lValue
   ENDIF
RETURN lOldValue

/*
*/
METHOD ReShowOnMouseOver( lValue ) CLASS TTaskbarNotifier //EXPORTED
LOCAL lOldValue := ::lReShowOnMouseOver

   IF ( ( PCOUNT() > 0 ) .AND. Hb_IsLogical( lValue ) )
      ::lReShowOnMouseOver := lValue
   ENDIF
RETURN lOldValue

/*
*/
METHOD SetGetColor( e, aValue ) CLASS TTaskbarNotifier //PROTECTED
LOCAL aOldValue := { GetRed( e ), GetGreen( e ), GetBlue( e ) }

   IF ( ( PCOUNT() > 1 ) .AND. Hb_IsArray( aValue ) .AND. ( Len( aValue ) > 2 ) .AND. ;
   Hb_IsNumeric( aValue[ 1 ] ) .AND. Hb_IsNumeric( aValue[ 2 ] ) .AND. Hb_IsNumeric( aValue[ 3 ] ) )

      e := RGB( aValue[1], aValue[2], aValue[3] )
   ENDIF
RETURN aOldValue

/*
*/
METHOD SetGetFont( e, oValue ) CLASS TTaskbarNotifier //PROTECTED
LOCAL oOldValue := e

   IF ( ( PCOUNT() > 1 ) .AND. ( GetObjectType( oValue ) == OBJ_FONT ) )

      e := oValue
   ENDIF
RETURN oOldValue

/*
*/
METHOD SetGetText( e, sValue ) CLASS TTaskbarNotifier //PROTECTED
LOCAL sOldText := e

   IF ( ( PCOUNT() > 1 ) .AND. Hb_IsString( sValue ) )
      e := sValue
   ENDIF
RETURN sOldText

/*
*/
METHOD SetGetRect( e, n1, n2, n3, n4 ) CLASS TTaskbarNotifier //PROTECTED
LOCAL aOldRect := e

   IF ( ( PCOUNT() > 1 ) .AND. Hb_IsNumeric( n1 ) .AND. Hb_IsNumeric( n2 ) .AND. Hb_IsNumeric( n3 ).AND. Hb_IsNumeric( n4 ) )
      e := NIL
      e := { n1, n2, n3, n4 }
   ENDIF
RETURN aOldRect

/*
*/
METHOD TitleOnClickEvent( lAllowed, EventBlock )
LOCAL lOldValue := ::lTitleClickable

   IF Hb_IsLogical( lAllowed )
      ::lTitleClickable := lAllowed
   ELSE
      ::lTitleClickable := FALSE
   ENDIF

   IF Hb_IsBlock( EventBlock )
      ::bTitleOnClickEvent := EventBlock
   ELSE
      ::bTitleOnClickEvent := NIL
   ENDIF
RETURN lOldValue

/*
*/
METHOD ContentOnClickEvent( lAllowed, EventBlock )
LOCAL lOldValue := ::lContentClickable

   IF Hb_IsLogical( lAllowed )
      ::lContentClickable := lAllowed
   ELSE
      ::lContentClickable := FALSE
   ENDIF

   IF Hb_IsBlock( EventBlock )
      ::bContentOnClickEvent := EventBlock
   ELSE
      ::bContentOnClickEvent := NIL
   ENDIF
RETURN lOldValue

/*
*/
METHOD CloseButtonClickable( lAllowed )
LOCAL lOldValue := ::lCloseButtonClickable

   IF Hb_IsLogical( lAllowed )
      ::lCloseButtonClickable := lAllowed
   ELSE
      ::lCloseButtonClickable := FALSE
   ENDIF
RETURN lOldValue

/*
*/
METHOD GetById( nHandle ) CLASS TTaskbarNotifier
LOCAL oResult := NIL, nPos := 0

   IF Hb_IsNumeric( nHandle ) .AND. ( ( nPos := AScan( ::aTaskbarNotifiers, {|o| o:WndHandle == nHandle } ) ) > 0 )
      oResult := ::aTaskbarNotifiers[ nPos ]      
   ENDIF
RETURN oResult

/*
*/
METHOD GetByName( sName ) CLASS TTaskbarNotifier
LOCAL oResult := NIL, nPos := 0

   IF Hb_IsString( sName ) .AND. ( ( nPos := AScan( ::aTaskbarNotifiers, {|o| o:Name == sName } ) ) > 0 )
      oResult := ::aTaskbarNotifiers[ nPos ]   
   ENDIF
RETURN oResult

/* --------------------- END TTASKBARNOTIFIER ------------------ */

#pragma BEGINDUMP

#include "windows.h"
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "item.api"

extern BOOL Array2Rect( PHB_ITEM aRect, RECT *rc );
extern HRGN BitmapToRegion( HBITMAP, COLORREF, COLORREF );

/*
*/
HB_FUNC ( LOADBITMAPFROMRES )
{
   HBITMAP hBitmap;

   hBitmap = (HBITMAP) LoadImage( GetModuleHandle( NULL ), hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );

   hb_retnl( (LONG) hBitmap );
}

HB_FUNC ( LOADBITMAPFROMFILE )
{
   HBITMAP hBitmap;

   hBitmap = (HBITMAP) LoadImage( 0, hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE|LR_CREATEDIBSECTION );

   hb_retnl( (LONG) hBitmap );
}

HB_FUNC ( BITMAPTOREGION )
{
   HRGN hrgn;
   HBITMAP hBitmap = (HBITMAP) hb_parnl( 1 );

   if ( hBitmap != NULL )
      hrgn = BitmapToRegion( hBitmap, RGB( 255, 0, 255 ), 0x101010 );

   if ( hrgn != NULL )
      hb_retnl( (LONG) hrgn );
   else
      hb_ret(); // NIL
}

HB_FUNC ( SETWINDOWBITMAPRGN )
{
   HRGN hrgn = (HRGN) hb_parnl( 2 );
   if ( hrgn != NULL )
      SetWindowRgn( (HWND) hb_parnl( 1 ), hrgn, TRUE);
}

#ifdef __XHARBOUR__
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif
/*
*/
HB_FUNC ( GETWORKINGAREA )
{
   RECT rect;
   hb_retl( SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 ) );
   HB_STORNI( rect.left,   1, 1 );
   HB_STORNI( rect.top,    1, 2 );
   HB_STORNI( rect.right,  1, 3 );
   HB_STORNI( rect.bottom, 1, 4 );
} 

/*
*/
HB_FUNC( _DRAWTEXT )
{
   HDC hdc = (HDC) hb_parnl( 1 );
   LPSTR caption = ( char * ) hb_parc( 2 );
   INT iLen = hb_strnlen( caption, 255 );
   RECT rect;
   COLORREF clrText;
   UINT bkMode;
   HFONT hFont, oldfont;
   BOOL bFlag = hb_parl( 6 );

   Array2Rect( hb_param( 3, HB_IT_ARRAY ), &rect );

   clrText = SetTextColor( hdc, (COLORREF) hb_parnl( 4 ) );
   bkMode  = SetBkMode( hdc, TRANSPARENT );

   if ( GetObjectType( (HGDIOBJ) hb_parnl( 5 ) ) == OBJ_FONT )
   {
           oldfont = (HFONT) SelectObject( hdc, (HFONT) hb_parnl( 5 ) );
   }
   else
      oldfont = (HFONT) SelectObject( hdc, GetStockObject( DEFAULT_GUI_FONT ) );

   if ( bFlag )
   {
      DrawText( hdc, caption, iLen, &rect, DT_CENTER | DT_VCENTER | DT_SINGLELINE | DT_END_ELLIPSIS | DT_EXPANDTABS );
   }
   else
   {
      DrawText( hdc, caption, iLen, &rect, DT_CENTER | DT_VCENTER | DT_EDITCONTROL | DT_WORDBREAK);
   }
   SelectObject( hdc, oldfont );

   SetTextColor( hdc, clrText );
   SetBkMode( hdc, bkMode );
}

#pragma ENDDUMP