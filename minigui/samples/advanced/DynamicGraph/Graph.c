/***************************************************************************\
*                                                                           *
*  Author: Shanmuga Sundar.V                                                *
*          MNC company in India - Chennai                                   *
*                                                                           *
*  Date:   13 Dec 2006                                                      *
*                                                                           *
\***************************************************************************/

/************************************************************************
	Draw initial Graph 
************************************************************************/
void DrawGraph(HDC hdc, RECT Rect)
{
	// Variable declaration
	POINT penpoint;           

	HBRUSH hOldBrush, hNewBrush;
	HPEN   hOldPen, hNewPen;
	
	LOGBRUSH lbrush;     
	LOGPEN   lpen;          

	int XInt, YInt;
	int iLoop, Index;
	static int IncYAxis = 0;

	penpoint.x     = (long)NULL;
	penpoint.y     = (long)NULL;

	// Set Pen Color
	lpen.lopnColor = RGB( 000, 000, 000 );
	lpen.lopnStyle = PS_SOLID;
	lpen.lopnWidth = penpoint;

	// Set Brush Style
	lbrush.lbStyle = BS_SOLID;
	lbrush.lbColor = RGB( 000, 000, 000 );
	lbrush.lbHatch = 0;

	// Select New Pen DC
	hNewPen        = CreatePenIndirect(&lpen);    
	hOldPen        = SelectPen( hdc, hNewPen);

	// Select New Brush DC
	hNewBrush      = CreateBrushIndirect(&lbrush);
	hOldBrush      = SelectBrush( hdc, hNewBrush);

	// Calculate the diff value for x and y axis
	XInt = (Rect.right - Rect.left)/GRAPH_GAP;
	YInt = (Rect.bottom - Rect.top)/GRAPH_GAP;

	// Draw the Box
	Rectangle(hdc, Rect.left, Rect.top , Rect.right - GRAPH_HEADER_LOC, Rect.bottom);

	//Change the brush color
	lbrush.lbStyle = BS_SOLID;
	lbrush.lbColor = RGB(000, 80, 40);
	lbrush.lbHatch = 0;

	// Select New Brush DC
	hNewBrush = CreateBrushIndirect(&lbrush);
	SelectBrush( hdc, hNewBrush);

	// Draw the Box
	Rectangle(hdc, Rect.right - GRAPH_HEADER_LOC, Rect.top , Rect.right, Rect.bottom);

	//Change pen color to DRAK GREEN
	lpen.lopnColor = RGB( 000, 125, 000 );
	hNewPen        = CreatePenIndirect(&lpen);    
	SelectPen( hdc, hNewPen);

	// Move the Background of the graph
	IncYAxis += VER_LINE_GAP;
	if(IncYAxis > VER_MAX_MOV)
		IncYAxis  = 0;
	//Draw Y Axis . Vertical Line
	for (iLoop = Rect.left + IncYAxis; (iLoop+ IncYAxis) <= (Rect.right - GRAPH_HEADER_LOC); iLoop += XInt)
	{

		MoveToEx(hdc, iLoop + IncYAxis, Rect.top, NULL); 
		LineTo(hdc, iLoop + IncYAxis, Rect.top + (YInt * GRAPH_GAP));
	}

	//Draw X Axis . Horizontal Line
	Index = GRAPH_GAP;
	for (iLoop = Rect.top; iLoop <= Rect.bottom ; iLoop += YInt)
	{
		MoveToEx(hdc, Rect.left, iLoop, NULL); 
		LineTo(hdc, Rect.right - GRAPH_HEADER_LOC, iLoop);
		Index --;
	}
	if(Index == 0)
	{
		MoveToEx(hdc, Rect.left, Rect.bottom, NULL); 
		LineTo(hdc, Rect.right - GRAPH_HEADER_LOC, Rect.bottom);
	}

	SelectObject(hdc, hOldPen);
	DeleteObject(hNewPen);
	SelectObject(hdc, hOldBrush);
	DeleteObject(hNewBrush);
}

/************************************************************************
	Plot Graph points
************************************************************************/
void UpdateGraph(HDC hdc, RECT Rect, unsigned long RxValue, unsigned long TxValue, int GraphNo)
{
	HFONT  hNewFont;
	HPEN   hNewPen;
	
	LOGPEN   lpen;          
	LOGFONT  lfont;          

	POINT penpoint;           

	char Buf[20];
	int XAxisValues;
	int ModVal;
	int iLoop, Index, Check_Index;
	float XPlotDiff, YPlotDiff;
	int XInt, YInt;

	XInt = (Rect.right - Rect.left)/GRAPH_GAP;
	YInt = (Rect.bottom - Rect.top)/GRAPH_GAP;

	// Update the Max Bytes that has send / Received through the socket
	if(RxValue > MaxRx)
		MaxRx = RxValue;
	if(TxValue > MaxTx)
		MaxTx = TxValue;

	if(MaxTx <= 0 && MaxRx <= 0)
		MaxTx = 100;
	// Assign the x axis difference values. Get six intervals values for x axis
	if(MaxTx > MaxRx)
		XAxisValues = MaxTx / GRAPH_GAP;
	else
		XAxisValues = MaxRx / GRAPH_GAP;
	
	// Round off the xaxis values for draw graph
	ModVal = (int) XAxisValues % 10;
	ModVal = 10 - ModVal;
	if(ModVal != 10)
		XAxisValues += ModVal;

	// Set the font to display the x - axis values
	lfont.lfHeight		= -9;
	lfont.lfWeight		= FW_THIN;
	lfont.lfWidth		= 0;
	lfont.lfEscapement	= 0;
	lfont.lfOrientation	= 0;
	lfont.lfUnderline	= FALSE;
	lfont.lfStrikeOut	= FALSE;
	lfont.lfItalic		= FALSE;
	lfont.lfCharSet		= DEFAULT_CHARSET;
	lfont.lfOutPrecision	= OUT_TT_PRECIS;
	lfont.lfPitchAndFamily	= VARIABLE_PITCH | FF_DONTCARE;
	lfont.lfQuality		= PROOF_QUALITY;
	lfont.lfClipPrecision	= CLIP_DEFAULT_PRECIS;
	strcpy(lfont.lfFaceName, "Times New Roman");
	hNewFont = CreateFontIndirect(&lfont);
	SelectFont(hdc, hNewFont);

	SetTextColor(hdc, RGB( 255, 255, 255));
	SetTextAlign(hdc, TA_LEFT | TA_BASELINE);

	// Display the x axis values
	Index = GRAPH_GAP;
	SetBkColor(hdc, RGB(000, 80, 40));
	for (iLoop = Rect.top; iLoop < Rect.bottom ; iLoop += YInt)
	{
		memset(Buf, 0x00, sizeof(Buf));
		sprintf(Buf, "%d", XAxisValues * Index);
		if(Index == 0)
			TextOut(hdc, Rect.right - GRAPH_HEADER_LOC+1, iLoop, Buf, strlen(Buf));
		else
			TextOut(hdc, Rect.right - GRAPH_HEADER_LOC+1, iLoop + 8, Buf, strlen(Buf));
		Index --;
	}
	if(Index == 0)
		TextOut(hdc, Rect.right - GRAPH_HEADER_LOC+1, Rect.bottom, "0", strlen("0"));

	// Format the bytes structure
	for(iLoop = NO_OF_POINTS; iLoop > 1; iLoop--)
	{
		GraphInfo[GraphNo][iLoop-1].RxBytes	=	GraphInfo[GraphNo][iLoop-2].RxBytes;
		GraphInfo[GraphNo][iLoop-1].TxBytes	=	GraphInfo[GraphNo][iLoop-2].TxBytes;
	}
	// Move the current value into the structure
	GraphInfo[GraphNo][0].RxBytes	=	RxValue;
	GraphInfo[GraphNo][0].TxBytes	=	TxValue;

	// Get Plot Pos Difference
	XPlotDiff = (float) XInt * GRAPH_GAP;
	XPlotDiff /= NO_OF_POINTS;
	XPlotDiff++;

	YPlotDiff = (float) Rect.bottom - (Rect.top);
	YPlotDiff /=  (XAxisValues*GRAPH_GAP);

	// Change pen color to DRAK GREEN
	penpoint.x           = (long)NULL;
	penpoint.y           = (long)NULL;

	lpen.lopnColor = RGB( 000, 255, 000);
	lpen.lopnStyle = PS_SOLID;
	lpen.lopnWidth = penpoint;
	
	hNewPen   = CreatePenIndirect(&lpen);    
	SelectPen( hdc, hNewPen);

	TotalRxBytes = TotalTxBytes = 0;

	// Plot Rx Bytes information on the graph
	Check_Index = 0;
	for (iLoop = 0; iLoop < NO_OF_POINTS; iLoop ++)
	{
		if((Rect.left+Check_Index+XPlotDiff) > (Rect.right - GRAPH_HEADER_LOC))
			break;
		
		if(((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop].RxBytes * YPlotDiff)) < (GRAPH_HEADER_LOC + Rect.top ) )
		{
			MoveToEx(hdc, (int)(Rect.left+Check_Index), Rect.top, NULL); 
		}
		else if(((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop].RxBytes * YPlotDiff)) > Rect.bottom )
		{
			MoveToEx(hdc, (int)(Rect.left+Check_Index), Rect.bottom, NULL); 
		}
		else
		{
			MoveToEx(hdc, (int)(Rect.left+Check_Index), (int) ((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop].RxBytes * YPlotDiff)), NULL); 
		}
		
		if(((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop+1].RxBytes * YPlotDiff)) < (GRAPH_HEADER_LOC + Rect.top ) )
		{
			LineTo(hdc, (int)((Rect.left+Check_Index+XPlotDiff)), Rect.top); 
		}
		else if(((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop].RxBytes * YPlotDiff)) > Rect.bottom )
		{
			LineTo(hdc, (int)(Rect.left+Check_Index), Rect.bottom); 
		}
		else
		{
			LineTo(hdc, (int)((Rect.left+Check_Index+XPlotDiff)), (int) ((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop+1].RxBytes * YPlotDiff))); 
		}
		Check_Index += (int) XPlotDiff;
		TotalRxBytes += GraphInfo[GraphNo][iLoop].RxBytes;
	}

	// Change pen color to DRAK GREEN
	lpen.lopnColor = RGB( 255, 000, 000 );
	lpen.lopnStyle = PS_SOLID;
	lpen.lopnWidth = penpoint;
	hNewPen   = CreatePenIndirect(&lpen);    
	SelectPen( hdc, hNewPen);
 
	// Plot Tx Bytes information on the graph
	Check_Index = 0;
	for (iLoop = 0; iLoop < NO_OF_POINTS; iLoop ++)
	{
		if((Rect.left+Check_Index+XPlotDiff) > (Rect.right - GRAPH_HEADER_LOC))
			break;
		if(((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop].TxBytes * YPlotDiff)) < (GRAPH_HEADER_LOC + Rect.top ) )
		{
			MoveToEx(hdc, (int)(Rect.left+Check_Index), Rect.top, NULL); 
		}
		else if(((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop].TxBytes * YPlotDiff)) > Rect.bottom )
		{
			MoveToEx(hdc, (int)(Rect.left+Check_Index), Rect.bottom, NULL); 
		}
		else
		{
			MoveToEx(hdc, (int)(Rect.left+Check_Index), (int) ((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop].TxBytes * YPlotDiff)), NULL); 
		}

		if(((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop+1].TxBytes * YPlotDiff)) < (GRAPH_HEADER_LOC + Rect.top ) )
		{
			LineTo(hdc, (int)((Rect.left+Check_Index+XPlotDiff)), Rect.top); 
		}
		else if(((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop].TxBytes * YPlotDiff)) > Rect.bottom )
		{
			LineTo(hdc, (int)(Rect.left+Check_Index), Rect.bottom); 
		}
		else
		{
			LineTo(hdc, (int)((Rect.left+Check_Index+XPlotDiff)), (int) ((Rect.top + (YInt * GRAPH_GAP)) - (GraphInfo[GraphNo][iLoop+1].TxBytes * YPlotDiff))); 
		}
		Check_Index += (int) XPlotDiff;

		TotalTxBytes += GraphInfo[GraphNo][iLoop].TxBytes;
	}

}

/******************************************************************
	Process Bar
******************************************************************/
void DrawBar(HDC hdc, RECT Rect, int Process_Value)
{
	POINT penpoint;           

	HBRUSH hOldBrush, hNewBrush;
	HFONT  hOldFont, hNewFont;
	HPEN   hOldPen, hNewPen;
	
	LOGBRUSH lbrush;     
	LOGPEN   lpen;          
	LOGFONT  lfont;          

	int XInt, YInt;
	int iLoop, EndPos = 0;
	float IncYAxis;
	char Buf[BUF_LEN];

	// Set Brush Style
	lbrush.lbStyle     = BS_SOLID;
	lbrush.lbColor     = RGB( 000, 000, 000 );
	lbrush.lbHatch     = 0;

	// Select New Brush DC
	hNewBrush	= CreateBrushIndirect(&lbrush);
	hOldBrush	= SelectBrush( hdc, hNewBrush);

	// Calculate the diff value for x and y axis
	XInt = (Rect.right  - Rect.left)/ NO_OF_BAR_PARTS;
	YInt = (Rect.bottom - Rect.top + GRAPH_GAP) / NO_OF_BAR_PARTS;

	// Draw the Box
	Rectangle(hdc, Rect.left, Rect.top, Rect.right, Rect.bottom);

	// Select the dark green pen for draw the line
	penpoint.x	= (long)0;
	penpoint.y	= (long)0;

	lpen.lopnColor  = RGB( 000, DARK_GREEN, 000 );
	lpen.lopnStyle  = PS_SOLID;
	lpen.lopnWidth  = penpoint;
	hNewPen		= CreatePenIndirect(&lpen);    
	hOldPen		= SelectPen( hdc, hNewPen);

	// Draw the initial horizontal line 
	for(iLoop = (Rect.top + GRAPH_GAP); iLoop <= (Rect.bottom - YInt); iLoop += LINE_GAP_LEN)
	{
		MoveToEx(hdc, (Rect.left + XInt), iLoop, NULL);
		LineTo(hdc, (Rect.right - XInt), iLoop);
		EndPos = iLoop;
	}

	//Get the length of plot area in y axis
	IncYAxis = (float) (Rect.bottom - YInt) - (Rect.top + GRAPH_GAP);
	// Calculate the percentage value for the value
	IncYAxis = (IncYAxis * Process_Value / 100);
	// Get the exact y axis value to display the graph
	IncYAxis = (Rect.bottom - YInt) - IncYAxis;

	// Change the pen style and color for draw the graph
	penpoint.x	= (long)0;
	penpoint.y	= (long)0;
	lpen.lopnColor  = RGB( 000, LIGHT_GREEN, 000 );
	lpen.lopnStyle  = PS_SOLID;
	lpen.lopnWidth  = penpoint;
	hNewPen		= CreatePenIndirect(&lpen);    
	SelectPen( hdc, hNewPen);

	// Fill the percentage area
	for(iLoop = EndPos; iLoop >= IncYAxis; iLoop -= LINE_GAP_LEN)
	{
		MoveToEx(hdc, (Rect.left + XInt), iLoop, NULL);
		LineTo(hdc, (Rect.right - XInt), iLoop);
	}

	// Set Font Parameters
	lfont.lfHeight		= -20;
	lfont.lfWeight		= FW_THIN;
	lfont.lfWidth		= 14;
	lfont.lfEscapement	= 0;
	lfont.lfOrientation	= 0;
	strcpy(lfont.lfFaceName, "Courier");
	lfont.lfUnderline	= FALSE;
	lfont.lfStrikeOut	= FALSE;
	lfont.lfItalic		= FALSE;
	lfont.lfCharSet		= DEFAULT_CHARSET;
	lfont.lfOutPrecision	= OUT_TT_PRECIS;
	lfont.lfPitchAndFamily  = VARIABLE_PITCH | FF_DONTCARE;
	lfont.lfQuality         = PROOF_QUALITY;
	lfont.lfClipPrecision   = CLIP_DEFAULT_PRECIS;

	// Select New font DC
	hNewFont = CreateFontIndirect(&lfont);
	hOldFont = SelectFont(hdc, hNewFont);

	// Set the text color and display the percentage as a text
	SetBkColor(hdc, RGB(000, 000, 000));
	SetTextColor(hdc, RGB(000, LIGHT_GREEN, 000));
	sprintf(Buf, "%d %%",Process_Value);
	TextOut(hdc, Rect.left + (int) ((Rect.right  - Rect.left) / CENTER_VAL), (Rect.bottom - YInt) + (YInt/3), Buf, strlen(Buf));

	SelectObject(hdc, hOldPen);
	DeleteObject(hNewPen);
	SelectObject(hdc, hOldBrush);
	DeleteObject(hNewBrush);
	SelectObject(hdc, hOldFont);
	DeleteObject(hNewFont);
}
