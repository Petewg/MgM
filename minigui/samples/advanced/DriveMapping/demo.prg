//  Network Drive mapping    // Mapeamento para driver de rede
//  The modifications and improvements send me the e-mail: roberto@conexxus.com.br
//  Modificações e melhoramentos se possivel me enviar


#include "minigui.ch"

#ifdef __HARBOUR__
   #xcommand TRY => BEGIN SEQUENCE WITH s_bBreak
   #xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
   #xcommand FINALLY => ALWAYS
   static s_bBreak := { |oErr| break( oErr ) }
#endif

memvar lgImpos,lgImpos1,lgImpos2

Function Main()
    Local cDriveLetter:="M:", cRemotePath:="\\srv\dados"
    Local lgTITLE,lgStat,lgbtn1,lgbtn2,lgbtn3,lgbtn3Y,lgbtn3N
    Private lgImpos,lgImpos1,lgImpos2
    
   // Set default language to English
   SET LANGUAGE TO English
   // Set default language to Portuguese
   //SET LANGUAGE TO PORTUGUESE

    if upper(left(HB_LANGSELECT(),2)) == "PT"

	lgTITLE:="Mapeamento de Unidade da Rede"
	lgStat:= 'Conexão com a Rede!'
	lgbtn1:= 'Mapear uma unidade de rede' 
	lgbtn2:= 'Remover o mapeamento da unidade'
	lgbtn3:= 'A unidade já está mapeada?'
	lgbtn3Y:="Mapeado para "
	lgbtn3N:="Não mapeada" 
	lgImpos:="Impossível mapaear "	   	   
	lgImpos1:=" para "	
	lgImpos2:=" Impossível remover  "  	   	    	   	   

    else
        
	   lgTITLE:="Network Drive mapping"
	   lgStat:= 'Network Connection!'
	   lgbtn1:= 'Map a Network Drive'
	   lgbtn2:= 'Remove Mapped Drive'
	   lgbtn3:= 'Is Drive Mapped ?'
	   lgbtn3Y:="Mapped to "
	   lgbtn3N:="Not mapped"
	   lgImpos:="Unable to map "
	   lgImpos1:=" to "	
	   lgImpos2:=" Unable to remove  "   	   

    endif       

	DEFINE WINDOW DRVMAP ;
		AT 0,0 ;
		WIDTH 250 + GetBorderWidth() ;
		HEIGHT 150 ;
		TITLE lgTITLE ;
		MAIN ;
		NOMAXIMIZE NOSIZE      

 		DEFINE STATUSBAR
			STATUSITEM lgStat
		END STATUSBAR

	        @ 5,10 BUTTON Btn1 ;
	            CAPTION lgbtn1 ;
	            WIDTH 230 ;
	            HEIGHT 24 ;
	            FONT 'Arial' ;
	            SIZE 9 ON CLICK DriveMapping( cDriveLetter, cRemotePath )

	        @ 30,10 BUTTON Btn2 ;
	            CAPTION lgbtn2 ;
	            WIDTH 230 ;
	            HEIGHT 24 ;
	            FONT 'Arial' ;
	            SIZE 9 ON CLICK RemoveDriveMapping( cDriveLetter )

	        @ 55,10 BUTTON Btn3 ;
	            CAPTION lgbtn3 ;
	            WIDTH 230 ;
	            HEIGHT 24 ;
	            FONT 'Arial' ;
	            SIZE 9 ON CLICK MsgInfo( iif(Ismappeddrive(cDriveLetter), lgbtn3Y+cDriveLetter, lgbtn3N) )

 	END WINDOW   

	CENTER WINDOW   DRVMAP

	ACTIVATE WINDOW DRVMAP

Return NIL  


Function DriveMapping(cDriveLetter,cRemotePath,lPermanent,cUserName,cPassword)
    Local oNetwork

    DEFAULT lPermanent:=.F.

    oNetwork:=CreateObject("WScript.Network") 
    TRY
        oNetwork:MapNetworkDrive(cDriveLetter, cRemotePath,lPermanent,cUserName,cPassword)
    CATCH 
        MsgInfo(lgImpos+cDriveLetter+ lgImpos1 +cRemotePath)
    END
Return NIL


Function RemoveDriveMapping(cDriveLetter)
    Local oNetwork

    oNetwork:=CreateObject("WScript.Network") 
    TRY
        oNetwork:RemoveNetworkDrive(cDriveLetter)
    CATCH
        MsgInfo(lgImpos2+cDriveLetter)
    END
Return NIL


Function Ismappeddrive(cDriveLetter)
    Local oNetwork,oNetworkDrives,i,lAlreadyConnected:=.F.

    oNetwork:=CreateObject("WScript.Network") 
    oNetworkDrives:=oNetwork:EnumNetworkDrives() 

    For i:=0 to oNetworkDrives:Count - 1 STEP 2
        if Upper(oNetworkDrives:Item(i)) == Upper(cDriveLetter)
            lAlreadyConnected:=.T.
        Endif
    Next
Return lAlreadyConnected
