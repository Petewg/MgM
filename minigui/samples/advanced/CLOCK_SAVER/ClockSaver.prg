/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2003-2008 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Modificado: 27/11/2008 por Walter H.TAVERNA <walhug@yahoo.com.ar>
 *             para evitar el parpadeo del reloj.
 *             in order to avoid the blinking of the clock
*/

ANNOUNCE RDDSYS

#define __SCRSAVERDATA__
#include "minigui.ch"

#define PROGRAM "Clock Screen Saver"
#define VERSION " v.1.02"
#define COPYRIGHT " 2003-2008 Grigory Filatov"

#define PS_SOLID   0

Static ParentHandle
Static ahPen, ahUPen, nDiametr, xcent, ycent
Static nlseg, nlmin, nlhor, radio

Static lInit := .T.

Memvar nWidth, nHeight

*-----------------------------------------------------------------------------*
PROCEDURE Main( cParameters )
*-----------------------------------------------------------------------------*
   Private nWidth := GetDesktopWidth(), nHeight := GetDesktopHeight()

   ahPen  := Array(4)
   ahUPen := Array(4)  // WHT 26/11/2008

   IF cParameters # NIL .AND. ( LOWER(cParameters) $ "-p/p" .OR. ;
      LOWER(cParameters) = "/a" .OR. LOWER(cParameters) = "-a" .OR. ;
      LOWER(cParameters) = "/c" .OR. LOWER(cParameters) = "-c" )

      DEFINE SCREENSAVER ;
         WINDOW Form_SSaver ;
         MAIN ;
         NOSHOW
   ELSE

      DEFINE SCREENSAVER ;
         WINDOW Form_SSaver ;
         MAIN ;
         ON RELEASE ( Aeval(ahPen, {|e| DeleteObject( e )}), ;
                      Aeval(ahUPen, {|e,i| iif(i>1, DeleteObject( e ), )}), .T. ) ;
         ON PAINT DrawClock() ;
         INTERVAL 1 ;
         BACKCOLOR BLACK
   ENDIF

   INSTALL SCREENSAVER TO FILE ClockSaver.scr

   CONFIGURE SCREENSAVER MsgAbout()

   ACTIVATE SCREENSAVER ;
      WINDOW Form_SSaver ;
      PARAMETERS cParameters

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE DrawClock()
*-----------------------------------------------------------------------------*
   Local hDC, hOldPen, ntime := time()
   Local ngseg, ngmin, nghor, t

   Static nGSeg1, nGMin1, nGHor1   // WHT 26/11/2008

   if lInit
      // Cuadrante
      ahPen[1] := CREATEPEN( PS_SOLID, 6, RGB( 255, 255, 255 ) )
      // Segundos
      ahPen[2] := CREATEPEN( PS_SOLID, 1, RGB( 255, 0, 0 ) )
      ahUPen[2]:= CREATEPEN( PS_SOLID, 1, RGB( 0, 0, 0 ) )
      // Minutos
      ahPen[3] := CREATEPEN( PS_SOLID, 4, RGB(  128, 128, 128 ) )
      ahUPen[3]:= CREATEPEN( PS_SOLID, 4, RGB( 0, 0, 0 ) )
      // Horas
      ahPen[4] := CREATEPEN( PS_SOLID, 8, RGB( 128, 128, 128 ) )
      ahUPen[4]:= CREATEPEN( PS_SOLID, 8, RGB( 0, 0, 0 ) )

      xcent    := nWidth / 2
      ycent    := nHeight / 2
      nDiametr := nHeight / 2 + 60
      radio    := ndiametr / 2
      nlseg    := radio - 1
      nlmin    := radio * 3 / 4
      nlhor    := radio / 2

      ParentHandle := _HMG_MainHandle
   endif

   // Manecilla Segundos
   nGSeg := val(substr(ntime,7))*6

   // Manecilla Minutos
   nGMin := val(substr(ntime,4,2))*6

   // Manecilla Horas
   nGHor := mod(val(substr(ntime,1,2)),12)*30 + int(ngmin/12)

   if lInit
      nGSeg1 := nGSeg	;      nGHor1 := nGHor	;      nGMin1 := nGMin
      lInit := .F.
   endif

   hDC := GetDC( ParentHandle )

   // Segundos
   hOldPen := SelectObject( hDC, ahUPen[2] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlseg*sin(ngseg1), ycent-nlseg*cos(ngseg1), ahUPen[2])

   // Cuadrante
   SelectObject( hDC, ahPen[1] )
   for t = 0 to 330 step 30
      MoveTo(hDC, xCent+nLSeg*Sin(t), yCent-nLSeg*Cos(t))
      LineTo(hDC, xCent+(nLSeg+5)*Sin(t), yCent-(nLSeg+5)*Cos(t), ahPen[1])
   next

   // Minutos
   SelectObject( hDC, ahUPen[3] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlmin*sin(nGMin1), ycent-nlmin*cos(nGMin1), ahUPen[3])

   SelectObject( hDC, ahPen[3] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlmin*sin(ngmin), ycent-nlmin*cos(ngmin), ahPen[3])

   // Horas
   SelectObject( hDC, ahUPen[4] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlhor*sin(nGHor1), ycent-nlhor*cos(nGHor1), ahUPen[4])

   SelectObject( hDC, ahPen[4] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlhor*sin(nghor), ycent-nlhor*cos(nghor), ahPen[4])

   // Segundos
   SelectObject( hDC, ahPen[2] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlseg*sin(ngseg), ycent-nlseg*cos(ngseg), ahPen[2])

   SelectObject( hDC, ahPen[4] )
   RoundRect( hDC, xcent-6, ycent-6, xcent+6, ycent+6, 12, 12 )

   SelectObject( hDC, hOldPen )

   ReleaseDC( ParentHandle, hDC )

   nGSeg1 := nGSeg	;   nGMin1 := nGMin	;   nGHor1 := nGHor

RETURN

*-----------------------------------------------------------------------------*
FUNCTION MsgAbout()
*-----------------------------------------------------------------------------*
RETURN MsgInfo( PROGRAM + VERSION + CRLF +;
      "Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF +;
      "eMail: gfilatov@inbox.ru" + CRLF + CRLF +;
      "This Screen Saver is Freeware!" + CRLF +;
      padc("Copying is allowed!", 30), "About..." )


FUNCTION RadToDeg(x); RETURN 180.0*x/PI()
/*
*/
FUNCTION DegToRad(x); RETURN x*PI()/180.0
/*
*/
FUNCTION Signo(nValue); RETURN if(nValue<0, -1.0, 1.0)
/*
*/
FUNCTION Sin(nAngle,lRad)
   Local nHalfs:=0, nDouble, nFact:=1, nPower, nSquare, nCont, lMinus
   Local nSin, nSin0, nQuadrant
   lRad:=if(lRad=nil,.F.,lRad)
   nAngle:=Angle360(nAngle,lRad,@nQuadrant)
   nAngle:=Abs(nAngle)
   nAngle:=if(lRad,nAngle,DegToRad(nAngle))

   do while nAngle>=0.001
      nAngle/=2
      nHalfs++
   enddo
   nPower:=nAngle
   nSquare:=nAngle^2
   nSin:=nPower
   lMinus:=.T.
   nCont:=1
   DO WHILE .T.
      nSin0:=nSin
      nPower*=nSquare
      nFact*=(nCont+1)*(nCont+2)
      nSin+=if(lMinus,-1,+1)*nPower/nFact
      if Abs(nSin-nSin0)<10^-10
         exit
      endif
      nCont+=2
      lMinus:=!lMinus
   ENDDO
   for nDouble:=1 to nHalfs
      nSin:=2*nSin*(1-nSin^2)^(1/2)
   next
RETURN Round(if(nQuadrant>=3,-1.0,1.0)*nSin,6)
/*
*/
FUNCTION Cos(nAngle,lRad)
   Local nQuadrant, lMinus
   Angle360(nAngle,lRad,@nQuadrant)
   lMinus:=(nQuadrant=2) .or. (nQuadrant=3)
RETURN Round(if(lMinus,-1.0,1.0)*(1.0-Sin(nAngle,lRad)^2)^0.5,6)
/*
*/
FUNCTION Angle360(nAngle,lRad,nQuadrant)
   Local nAngInt, nAngFrac, nSigno:=Signo(nAngle)
   lRad:=if(lRad=nil,.F.,lRad)
   nAngle:=Abs(nAngle)
   nAngle:=if(lRad,RadToDeg(nAngle),nAngle)

   nAngInt:=Int(nAngle); nAngFrac:=nAngle-nAngInt
   nQuadrant:=Int(nAngInt/90)%4+1
   if nSigno<0
      nQuadrant:=5-nQuadrant
   endif
   nAngle:=nAngInt%360+nAngFrac
   nAngle:=if(lRad,DegToRad(nAngle),nAngle)
RETURN nSigno*nAngle


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC ( MOVETO )
{

   hb_retl( MoveToEx(
                      (HDC) hb_parnl( 1 ),   // device context handle
                      hb_parni( 2 )      ,   // x-coordinate of line's ending point
                      hb_parni( 3 )      ,   // y-coordinate of line's ending point
                      NULL
                   ) );
}

HB_FUNC( LINETO )
{
   hb_retl( LineTo( (HDC) hb_parnl( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

HB_FUNC ( ROUNDRECT ) // hDC, nLeftRect, nTopRect, nRightRect, nBottomRect,
                      // nEllipseWidth, nEllipseHeight)
{
   hb_retl( RoundRect( ( HDC ) hb_parnl( 1 ), hb_parnl( 2 ), hb_parnl( 3 ), hb_parnl( 4 ),
                               hb_parnl( 5 ), hb_parnl( 6 ), hb_parnl( 7 ) ) );
}

HB_FUNC ( CREATEPEN )
{
   hb_retnl( (LONG) CreatePen(
                               hb_parni( 1 ),	// pen style
                               hb_parni( 2 ),	// pen width
                    (COLORREF) hb_parnl( 3 ) 	// pen color
                 ) );
}

#pragma ENDDUMP
