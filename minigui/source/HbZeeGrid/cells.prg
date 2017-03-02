/*
 * This file is a part of HbZeeGrid library.
 * Copyright 2017 (C) P.Chornyj <myorg63@mail.ru>
 */

#include "hbclass.ch"
#include "zeegrid.ch"

CREATE CLASS _Cells

   EXPORTED:
      VAR hGrid READONLY 

      METHOD Init( hGrid )

      OPERATOR "[]" ARG nIndex INLINE _Cell():New( ::hGrid, nIndex )

ENDCLASS

METHOD _Cells:Init( hGrid )

   ::hGrid := hGrid

RETURN self

CREATE CLASS _Cell

   EXPORTED:
      VAR hGrid      READONLY 
      VAR nIndex
   
      METHOD Init( hGrid, nIndex )
      METHOD SetBColor( nClrIndex )   
      METHOD SetFColor( nClrIndex )
      METHOD GetBColor()   
      METHOD GetFColor()
      // and more

ENDCLASS

METHOD _Cell:Init( hGrid, nIndex )

   hb_default( @nIndex, 0 ) // title

   ::hGrid  := hGrid
   ::nIndex := nIndex

RETURN self

METHOD PROCEDURE _Cell:SetBColor( nClrIndex  )

   if HB_ISNUMERIC( nClrIndex )
      zgm_setCellBColor( ::hGrid, ::nIndex, nClrIndex )
   endif

RETURN

METHOD PROCEDURE _Cell:SetFColor( nClrIndex  )

   if HB_ISNUMERIC( nClrIndex )
      zgm_setCellFColor( ::hGrid, ::nIndex, nClrIndex )
   endif

RETURN

METHOD _Cell:GetBColor()
RETURN zgm_getCellBColor( ::hGrid, ::nIndex )

METHOD _Cell:GetFColor()
RETURN zgm_getCellFColor( ::hGrid, ::nIndex )
