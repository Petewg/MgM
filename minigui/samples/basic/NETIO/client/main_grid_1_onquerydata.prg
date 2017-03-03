#include "hmg.ch"

declare window Main

MEMVAR aRecordSet

Function main_grid_1_onquerydata

	This.QueryData := aRecordSet [This.QueryRowIndex] [This.QueryColIndex]

Return Nil
