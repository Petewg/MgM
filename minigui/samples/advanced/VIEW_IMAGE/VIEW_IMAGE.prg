
***************************************************************************************************
* PROGRAMA:	View BMP Image
* LENGUAJE:	HARBOUR-MINIGUI
* FECHA:	JUNIO 2010
* AUTOR:	Dr. CLAUDIO SOTO
* PAIS:		URUGUAY
* E-MAIL:	srvet@adinet.com.uy
***************************************************************************************************


#include "minigui.ch" 
#include "bitmap.ch"

#define IDI_MAIN 1001

#define MsgInfo( c, t ) MsgInfo( c, t, IDI_MAIN, .f. )

STATIC hWND := 0
STATIC SCR_WIDTH  := 0
STATIC SCR_HEIGHT := 0

STATIC Old_Width
STATIC Old_Height

STATIC View_Full_hBitmap    := 0
STATIC View_Strecht_hBITMAP := 0
STATIC Actual_hBitmap       := 0
STATIC Clip_hBitmap         := 0

STATIC Flag_Image           := .F.

STATIC Reflect_Horizontal   := .F.
STATIC Reflect_Vertical     := .F.
STATIC Rotate_Angle         := 0
STATIC Gray_Level           := 0
STATIC Light_Level          := 0

***************************************************************************************************
Procedure Main 
***************************************************************************************************
    
    DEFINE WINDOW Form_1; 
        AT 0,0; 
        WIDTH 800; 
        HEIGHT 600;  
        VIRTUAL WIDTH  10000; 
        VIRTUAL HEIGHT 10000;  
        TITLE 'View BMP Image' ;  
        MAIN;
        ON RELEASE Release_Handle ();
        ON MAXIMIZE Changue_Size ();    
        ON SIZE Changue_Size () 

        DEFINE MAIN MENU           
           DEFINE POPUP "&File"                       
              MENUITEM "Open"    ACTION Open_File ()                  
              MENUITEM "Close"   ACTION {|| Init_New (), Flag_Image := .F.}   
              MENUITEM "Save as" ACTION Save_As_File ()             
              SEPARATOR                
              MENUITEM "Exit" ACTION {|| Form_1.Release}               
           END POPUP  

           DEFINE POPUP "&Edit" 
              MENUITEM "Copy Clipboard"  ACTION Copy_Clipboard () NAME Copy_Clip
              MENUITEM "Paste Clipboard" ACTION Past_Clipboard () NAME Paste_Clip
              SEPARATOR 
              MENUITEM "Capture desktop" ACTION Capture_Desktop ()
           END POPUP 

           DEFINE POPUP "&View" 
              MENUITEM "View Full"    ACTION Check_View (1) NAME View_1 
              MENUITEM "View Strecht" ACTION Check_View (2) NAME View_2
              SEPARATOR
              MENUITEM "Define Transforms ..."   ACTION Transform_Image ()
           END POPUP 

           POPUP "&Info"			    
              ITEM "Author" ACTION MsgInfo ("Dr. Claudio Soto"+ space (20) +chr(13)+;
                   "srvet@adinet.com.uy"+chr(13)+"Artigas - Uruguay"+chr(13)+"June 2010", "View BMP Image")
           END POPUP
        END MENU

        @ 10, 20 IMAGE Image_1 PICTURE "" WIDTH 0 HEIGHT 0 

        DEFINE TIMER Timer_1 INTERVAL 100 ACTION {|| Form_1.Paste_Clip.Enabled := iif (BMP_CLIPBOARD_EMPTY (),.F.,.T.), Form_1.Copy_Clip.Enabled := Flag_Image}

        Old_Width  := Form_1.Width
        Old_Height := Form_1.Height

        Init_New ()
        Check_View (1)
        SetBar (.F.)

    END WINDOW 

    CENTER WINDOW Form_1

    ACTIVATE WINDOW Form_1

Return



Procedure Release_Handle
       BMP_RELEASE (View_Strecht_hBITMAP)              
       BMP_RELEASE (Actual_hBitmap)
       BMP_RELEASE (Clip_hBitmap)
       BMP_RELEASE (View_Full_hBITMAP)
       IMAGE_SET_hBITMAP ("Form_1", "Image_1", View_Strecht_hBITMAP, 0, 0)
Return



Procedure Init_New
    LOCAL area
    BMP_RELEASE (View_Strecht_hBITMAP)
        
    hWND := IMAGE_GET_hWND ("Form_1", "Image_1")
    area := WIN_GET_CLIENT_RECT (Application.Handle)
    
    SCR_WIDTH  := area [1] - 40
    SCR_HEIGHT := area [2] - 40
            
    IMAGE_SET_hBITMAP ("Form_1", "Image_1", View_Strecht_hBITMAP, 0, 0)         
Return



Procedure Changue_Size
   IF (Old_Width  <> Form_1.Width) .OR. (Old_Height <> Form_1.Height)
       Old_Width  := Form_1.Width
       Old_Height := Form_1.Height
       Init_New () 
       COPY_ACTUAL_TO_VIEW ()
   ENDIF    
Return



Procedure Check_View (n)
    IF n = 1
       Form_1.View_1.Checked := .T.
       Form_1.View_2.Checked := .F.
    ELSE   
       Form_1.View_1.Checked := .F.
       Form_1.View_2.Checked := .T.
    ENDIF   
    
    COPY_ACTUAL_TO_VIEW ()
Return


Procedure Open_File
   LOCAL w, h
   LOCAL FileName
   FileName := GETFILE ({{"BMP Image","*.bmp"}},"Load Image","",.F.,.F.)   
   IF .NOT. EMPTY (FileName)
      BMP_RELEASE (Actual_hBitmap)
      Actual_hBitmap := BMP_LOAD_FILE (FileName)
 
      w := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_WIDTH)
      h := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_HEIGHT)
 
      BMP_RELEASE (View_Full_hBitmap)
      View_Full_hBitmap := BMP_CREATE (w,h)
      BMP_COPY_BITBLT (View_Full_hBitmap, 0, 0, w, h, Actual_hBitmap, 0, 0)
 
      Flag_Image = .T.
      COPY_ACTUAL_TO_VIEW ()
   ENDIF  
Return



Procedure Save_As_File
   LOCAL FileName, ext
   IF Flag_Image = .T.
      FileName := PutFile ({{"BMP Image","*.bmp"}}, "Save As Image", "", .F.)
      IF .NOT. EMPTY (FileName)
         ext := RIGHT(FileName,4)
         IF UPPER (ext) <> ".BMP"
            FileName += ".BMP" 
         ENDIF
         IF FILE (FileName) = .T.
            IF MsgOkCancel ("Overwrite: "+FileName+" ?","The File Exists") = .F.
               Return
            ENDIF 
         ENDIF
          
         BMP_SAVE_FILE (View_Full_hBitmap, FileName)
       ENDIF   
   ENDIF    
Return



Procedure Copy_Clipboard 
   IF Flag_Image = .F.
      Return
   ENDIF   
   IF BMP_PUT_CLIPBOARD (View_Full_hBitmap) = .F.
      MsgInfo ("Error in put Clipboard")
   ENDIF
Return



Procedure Past_Clipboard
  LOCAL w, h
  BMP_RELEASE (Clip_hBitmap)
    
  Clip_hBitmap := BMP_GET_CLIPBOARD ()

  IF Clip_hBitmap = 0
     MsgInfo ("Error in get Clipboard")
     Return
  ENDIF
  
  w := BMP_GET_INFO (Clip_hBitmap, BMP_INFO_WIDTH)
  h := BMP_GET_INFO (Clip_hBitmap, BMP_INFO_HEIGHT)
     
  BMP_RELEASE (Actual_hBitmap)
  Actual_hBitmap := BMP_CREATE (w,h)
      BMP_COPY_BITBLT (Actual_hBitmap, 0, 0, w, h, Clip_hBitmap, 0, 0)
  BMP_RELEASE (Clip_hBitmap)
  
  w := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_WIDTH)
  h := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_HEIGHT)
  BMP_RELEASE (View_Full_hBitmap)
  View_Full_hBitmap := BMP_CREATE (w,h)
  BMP_COPY_BITBLT (View_Full_hBitmap, 0, 0, w, h, Actual_hBitmap, 0, 0)
  
  Flag_Image := .T.   
  COPY_ACTUAL_TO_VIEW ()
Return



Procedure Capture_Desktop      
   LOCAL area
   LOCAL w, h
   area := WIN_GET_CLIENT_RECT (BMP_DESKTOP_hWND)
   w := area[1]
   h := area[2]
   BMP_RELEASE (Actual_hBitmap)
   Actual_hBitmap := BMP_CREATE (w,h)
   
   Form_1.Hide
   SYS_DELAY (300) // Tiempo para repintar el Desktop
   BMP_GETSCREEN_BITBLT (Actual_hBitmap, 0, 0, w, h, BMP_DESKTOP_hWND, 0, 0)
   Form_1.Show
         
   w := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_WIDTH)
   h := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_HEIGHT)
   BMP_RELEASE (View_Full_hBitmap)
   View_Full_hBitmap := BMP_CREATE (w,h)
   BMP_COPY_BITBLT (View_Full_hBitmap, 0, 0, w, h, Actual_hBitmap, 0, 0)
   
   Flag_Image := .T.
   COPY_ACTUAL_TO_VIEW ()    
Return



Procedure Transform_Image
#define W_AUX 400
#define H_AUX 300
      
      IF Flag_Image = .F.
         Return
      ENDIF
      
      DEFINE WINDOW Form_aux;
            AT (Form_1.Height - H_AUX)/2 + Form_1.Row,(Form_1.Width - W_AUX)/2 + Form_1.Col;
            WIDTH  W_AUX;
            HEIGHT H_AUX;
            TITLE 'Define Transforms';
            MODAL;
            NOSIZE NOSYSMENU  

		@ 10  ,120 CHECKBOX Checkbox_RH CAPTION "Reflect Horizontal" VALUE Reflect_Horizontal WIDTH 120
		@ 50  ,120 CHECKBOX Checkbox_RV CAPTION "Reflect Vertical"   VALUE Reflect_Vertical WIDTH 120

		@ 90  ,100 LABEL Label_LL VALUE "Light Level" AUTOSIZE
		@ 90  ,200 SLIDER Slider_LL RANGE (-255), 255 VALUE Light_Level ON CHANGE Show_Value () NOTICKS

		@ 130 ,120 LABEL Label_GL VALUE "Gray Level" AUTOSIZE
		@ 130 ,200 SPINNER Spiner_GL RANGE 0, 100 VALUE Gray_Level

		@ 170 ,120 LABEL Label_RA VALUE "Rotate Angle" AUTOSIZE
		@ 170 ,200 SPINNER Spiner_RA RANGE 0, 360 VALUE Rotate_Angle

		@ 90 ,350  BUTTON Boton_Cero     CAPTION '0' WIDTH 25 ONCLICK {||Form_aux.Slider_LL.Value:=0, Show_Value()}  

		@ 215, 30  BUTTON Boton_OK       CAPTION '&OK'      ONCLICK boton (1)
		@ 215, 150 BUTTON Boton_DEFAULT  CAPTION '&Default' ONCLICK boton (2)
		@ 215, 270 BUTTON Boton_CANCEL   CAPTION '&Cancel'  ONCLICK boton (3)

		Show_Value ()

	  END WINDOW	  	  
	  ACTIVATE WINDOW Form_aux
Return

Procedure Show_Value
     Form_aux.Label_LL.Value:= "Light Level ("+ alltrim(str(Form_aux.Slider_LL.Value))+")"
Return

Procedure Boton (n)   
  LOCAL modo
  LOCAL Angle
  LOCAL New_hBitmap
  LOCAL w, h
  DO CASE
     CASE n = 1       
          Reflect_Horizontal := Form_aux.Checkbox_RH.Value
          Reflect_Vertical   := Form_aux.Checkbox_RV.Value
          Rotate_Angle       := Form_aux.Spiner_RA.Value
          Gray_Level         := Form_aux.Spiner_GL.Value
          Light_Level        := Form_aux.Slider_LL.Value
          Form_aux.Release   

          modo  := 0
          Angle := 0
      
          IF Reflect_Horizontal
             modo += BMP_REFLECT_HORIZONTAL 
          ENDIF  
      
          IF Reflect_Vertical
             modo += BMP_REFLECT_VERTICAL 
          ENDIF  
      
          IF Rotate_Angle > 0
             modo += BMP_ROTATE
             Angle := Rotate_Angle
          ENDIF      
  
          WaitWindow ("WAIT: processing the image ...", .T.)

          IF modo > 0
             New_hBitmap := BMP_TRANSFORM (Actual_hBitmap, modo, Angle, RGB (0,0,0))      
                 w := BMP_GET_INFO (New_hBitmap, BMP_INFO_WIDTH)
                 h := BMP_GET_INFO (New_hBitmap, BMP_INFO_HEIGHT)
                 BMP_RELEASE (View_Full_hBitmap)
                 View_Full_hBitmap := BMP_CREATE (w,h)
                 BMP_COPY_BITBLT (View_Full_hBitmap, 0, 0, w, h, New_hBitmap, 0, 0)
             BMP_RELEASE (New_hBitmap)
             BMP_LIGHT (View_Full_hBitmap, 0, 0, w, h, Light_Level)
             BMP_GRAY  (View_Full_hBitmap, 0, 0, w, h, Gray_Level)
             COPY_ACTUAL_TO_VIEW ()
          ELSE 
             w := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_WIDTH)
             h := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_HEIGHT)
                
             BMP_RELEASE (View_Full_hBitmap)
             View_Full_hBitmap := BMP_CREATE (w,h)                    
                
             BMP_COPY_BITBLT (View_Full_hBitmap, 0, 0, w, h, Actual_hBitmap, 0, 0)
             BMP_LIGHT (View_Full_hBitmap, 0, 0, w, h, Light_Level)
             BMP_GRAY  (View_Full_hBitmap, 0, 0, w, h, Gray_Level)             
             COPY_ACTUAL_TO_VIEW ()      
          ENDIF
        WaitWindow ()
         
     CASE n = 2
          Reflect_Horizontal := .F.
          Reflect_Vertical   := .F.
          Rotate_Angle       :=  0
          Gray_Level         :=  0
          Light_Level        :=  0
          Form_aux.Release   

          w := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_WIDTH)
          h := BMP_GET_INFO (Actual_hBitmap, BMP_INFO_HEIGHT)
          BMP_RELEASE (View_Full_hBitmap)
          View_Full_hBitmap := BMP_CREATE (w,h)
          BMP_COPY_BITBLT (View_Full_hBitmap, 0, 0, w, h, Actual_hBitmap, 0, 0)
          COPY_ACTUAL_TO_VIEW ()
          
     OTHERWISE
          Form_aux.Release
  ENDCASE   
Return



Procedure SetBar (Bar)
       LOCAL hMainHandle := Application.Handle
       LOCAL w, h
       LOCAL k
       LOCAL VirtualHeight
       LOCAL VirtualWidth
       #define SB_HORZ	0
       #define SB_VERT	1
       #define SB_LEFT	6
       #define SB_TOP	6
       #define SB_LINEUP	0
       #define SB_ENDSCROLL	8
       #define WM_VSCROLL  0x0115
       #define WM_HSCROLL	276

       IF Form_1.View_2.Checked = .T.
          SetScrollPos ( hMainHandle, SB_VERT , 0 , .F. )
          SetScrollPos ( hMainHandle, SB_HORZ , 0 , .F. )     
          SendMessage  ( hMainHandle, WM_VSCROLL, SB_LINEUP, 0)
       ENDIF

       w := 0
       h := 0
       IF Flag_Image = .T.
          w := BMP_GET_INFO (View_Full_hBitmap, BMP_INFO_WIDTH)
          h := BMP_GET_INFO (View_Full_hBitmap, BMP_INFO_HEIGHT)
       ENDIF
      
       k := aScan ( _HMG_aFormHandles , GetFormHandle ("Form_1") )
       
       VirtualHeight := 0
       VirtualWidth  := 0
       
       IF Bar
          VirtualHeight := MAX (0, (h - Form_1.Height + 140))
          VirtualWidth  := MAX (0, (w - Form_1.Width +  100))
       ENDIF
        
       _HMG_aFormVirtualHeight [k] := VirtualHeight 
       _HMG_aFormVirtualWidth  [k] := VirtualWidth  
      
       IF VirtualHeight > 0
          SetScrollRange ( hMainHandle , SB_VERT , 0 , VirtualHeight, .T. )
       ELSE      
          SetScrollRange ( hMainHandle , SB_VERT , 0 , 0, .T. )
       ENDIF
   
       IF VirtualWidth > 0 
          SetScrollRange ( hMainHandle , SB_HORZ , 0 , VirtualWidth, .T. )
       ELSE      
          SetScrollRange ( hMainHandle , SB_HORZ , 0 , 0, .T. )
       ENDIF
      
      SendMessage (hMainHandle, WM_VSCROLL, SB_LINEUP, 0)
Return



Procedure COPY_ACTUAL_TO_VIEW
  LOCAL w, h
  LOCAL New_hBitmap
  IF Flag_Image == .F.
     Return
  ENDIF
      
  IF Form_1.View_1.Checked = .T. 
     IMAGE_SET_hBITMAP ("Form_1", "Image_1", View_Full_hBitmap, BMP_GET_INFO (View_Full_hBitmap, BMP_INFO_WIDTH), BMP_GET_INFO (View_Full_hBitmap, BMP_INFO_HEIGHT))
     SetBar (.T.)
     Return
  ENDIF   
    
  w := BMP_GET_INFO (View_Full_hBitmap, BMP_INFO_WIDTH)
  h := BMP_GET_INFO (View_Full_hBitmap, BMP_INFO_HEIGHT)
   
  IF w <= SCR_WIDTH .AND. h <= SCR_HEIGHT               
     BMP_RELEASE (View_Strecht_hBITMAP)
     View_Strecht_hBITMAP := BMP_CREATE (w,h)
     BMP_COPY_BITBLT (View_Strecht_hBITMAP, 0, 0, w, h, View_Full_hBitmap, 0, 0)         
  ELSE     
     new_hBitmap := BMP_RESIZE (View_Full_hBitmap, SCR_WIDTH, SCR_HEIGHT, BMP_SCALE)
         w := BMP_GET_INFO (new_hBitmap, BMP_INFO_WIDTH)
         h := BMP_GET_INFO (new_hBitmap, BMP_INFO_HEIGHT)
         BMP_RELEASE (View_Strecht_hBITMAP)
         View_Strecht_hBITMAP := BMP_CREATE (w,h)
         BMP_COPY_BITBLT (View_Strecht_hBITMAP, 0, 0, w, h, new_hBitmap, 0, 0)           
     BMP_RELEASE (new_hBitmap)
  ENDIF
  
  IMAGE_SET_hBITMAP ("Form_1", "Image_1", View_Strecht_hBITMAP, BMP_GET_INFO (View_Strecht_hBITMAP, BMP_INFO_WIDTH), BMP_GET_INFO (View_Strecht_hBITMAP, BMP_INFO_HEIGHT))
  SetBar (.F.)
Return
