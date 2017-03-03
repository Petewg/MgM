*------------------------------------------------------------------------------*
Function ShowWait_Window( cMessage )
*------------------------------------------------------------------------------*
Local nWidthPix

  if ! IsWindowDefined ( Wait_window ) 

	nWidthPix := GetTextWidth( , cMessage ) + 25

	DEFINE WINDOW Wait_window ;
		AT		Application.Row + GetTitleHeight() + GetBorderHeight() + 2 , Application.Col + Application.Width - nWidthPix - 10  ;
		WIDTH		nWidthPix	;
		HEIGHT		37		;
		MAXWIDTH	nWidthPix	;
		MAXHEIGHT	37		;
		MINWIDTH	nWidthPix	;
		MINHEIGHT	37		;
		TITLE		''		;	
		CHILD		;
		NOSYSMENU	;
		NOCAPTION

		DEFINE WINDOW Wait_window_panel ;
			ROW iif(IsSeven(), 0, 3) ;
			COL iif(IsSeven(), 0, 2) ;
			WIDTH  Wait_window.Width - 11 ;
			HEIGHT Wait_window.Height - 13 ;
			WINDOWTYPE PANEL

			DEFINE LABEL Message
				ROW		iif(IsSeven(), 2, 4)
				COL		5
				PARENT		Wait_window_panel
				AUTOSIZE	.T.
				WIDTH		nWidthPix - 30
				HEIGHT		Wait_window_panel.Height - 5
 				FONTSIZE	10
				FONTBOLD	.T.
				VALUE		cMessage
			END LABEL			
	   	END WINDOW

	END WINDOW

	ACTIVATE WINDOW Wait_window NOWAIT

  Endif

Return Nil

*------------------------------------------------------------------------------*
Function HideWait_Window()
*------------------------------------------------------------------------------*

  if IsWindowDefined ( Wait_window ) 
	Wait_window.Release
  endif

Return Nil
