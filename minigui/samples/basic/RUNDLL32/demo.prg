/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
*/

ANNOUNCE RDDSYS

#include "MiniGUI.ch"

Function Main()
LOCAL aArray := RunDll32()
LOCAL aItems := {}

AEVAL(aArray,{|x| AADD( aItems,{ x[1] }) })

DEFINE WINDOW Win_1 ;
   AT 67,137 WIDTH 380 HEIGHT 440 ;
   TITLE '(c) ElSalnes@Telefonica.Net' ;
   MAIN ;
   NOSIZE NOMAXIMIZE

   @ 15,00 LABEL label_1 ;
     WIDTH 380 HEIGHT 20 ;
     FONT 'MS Sans Serif' SIZE 10 CENTERALIGN ;
     VALUE "UTILIDADES DE PRUEBA: RunDll32"
   
   @ 50,073 BUTTON button_1 CAPTION "Get_RunDll32" ;
     WIDTH 100 HEIGHT 28 ;
     FONT 'MS Sans Serif' SIZE 10 ;
     ACTION RunDll32_Get(aArray)
   
   @ 50,200 BUTTON button_2 CAPTION "&Salir" ;
     WIDTH 100 HEIGHT 28 ;
     FONT 'MS Sans Serif' SIZE 10 ;
     ACTION ThisWindow.Release
   
   @ 90,1 GRID Grid_1                  ;
     WIDTH 372 HEIGHT 316              ;
     HEADERS {"RUNDLL32"}              ;
     WIDTHS  {350}                     ;
     FONT 'MS Sans Serif' SIZE 10      ;
     ON DBLCLICK RunDell32_Run(aArray) ;
     ITEMS aItems                      ;
     VALUE 1
      
END WINDOW

CENTER   WINDOW Win_1
ACTIVATE WINDOW Win_1

RETURN(NIL)


PROCEDURE RunDll32_Get(aArray)
LOCAL nItem := Win_1.Grid_1.Value

InputBox( "Copiar...", "RunDll32...", aArray [nItem, 2] )

RETURN


PROCEDURE RunDell32_Run(aArray)
LOCAL nItem := Win_1.Grid_1.Value
LOCAL cRun

cRun := aArray [nItem, 2]
cRun := SUBSTR( cRun, AT( " ", cRun ) + 1 )

ShellExecute( 0, "open", "rundll32.exe", cRun, , 1 )

RETURN


FUNCTION RunDll32()
LOCAL aArray :=                                                                                                                      {;
{ "Panel de Control"                                            , "rundll32.exe shell32.dll,Control_RunDLL"                        } ,;
{ "Opciones de Accesibilidad"                                   , "rundll32.exe shell32.dll,Control_RunDLL access.cpl,,1"          } ,;
{ "Agregar o quitar programas"                                  , "rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,,1"          } ,;
{ "Propiedades de pantalla"                                     , "rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,0"            } ,;
{ "Configuracion regional y de idioma"                          , "rundll32.exe shell32.dll,Control_RunDLL intl.cpl,,0"            } ,;
{ "Dispositivos de juego"                                       , "rundll32.exe shell32.dll,Control_RunDLL joy.cpl"                } ,;
{ "Propiedades de Mouse"                                        , "rundll32.exe shell32.dll,Control_RunDLL main.cpl @0"            } ,;
{ "Propiedades de Teclado"                                      , "rundll32.exe shell32.dll,Control_RunDLL main.cpl @1"            } ,;
{ "Asistente para agregar impresoras"                           , "rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL AddPrinter"     } ,;
{ "Propiedades de Dispositivos de sonido y audio"               , "rundll32.exe shell32.dll,Control_RunDLL mmsys.cpl,,0"           } ,;
{ "Opciones de telefono y modem"                                , "rundll32.exe shell32.dll,Control_RunDLL modem.cpl"              } ,;
{ "Propiedades del sistema"                                     , "rundll32.exe shell32.dll,Control_RunDLL sysdm.cpl,,0"           } ,;
{ "Propiedades Fecha y hora"                                    , "rundll32.exe shell32.dll,Control_RunDLL timedate.cpl"           } ,;
{ "Open With (File Associations)"                               , "rundll32.exe shell32.dll,OpenAs_RunDLL d:\path\filname.ext"     } ,;
{ "Impresoras y fases"                                          , "rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL PrintersFolder" } ,;
{ "Fonts"                                                       , "rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL FontsFolder"    } ,;
{ "Open 'About Shell' Window"                                   , "rundll32.exe shell32.dll,ShellAboutA Info-Box"                  } ,;
{ "Diskcopy Diskettes"                                          , "rundll32.exe diskcopy.dll,DiskCopyRunDll"                       } ,;
{ "Create new shortcut in the location specified by %1"         , "rundll32.exe AppWiz.Cpl,NewLinkHere %1"                         } ,;
{ "Install New Hardware Wizard"                                 , "rundll32.exe sysdm.cpl,InstallDevice_RunDLL"                    } ,;
{ "Dial-up Networking Wizard"                                   , "rundll32.exe rnaui.dll,RnaWizard"                               } ,;
{ "Run 'Net Connection' Dialog"                                 , "rundll32.exe rnaui.dll,RnaDial 'MyConnect'"                     } ,;
{ "Open a scrap document"                                       , "rundll32.exe shscrap.dll,OpenScrap_RunDLL /r /x %1"             } ,;
{ "Create a Briefcase"                                          , "rundll32.exe syncui.dll,Briefcase_Create"                       } ,;
{ "Disable Mouse"                                               , "rundll32.exe mouse.dll,disable"                                 } ,;
{ "Lock The Keyboard"                                           , "rundll32.exe keyboard.dll,disable"                              } ,;
{ "Cascade All Windows"                                         , "rundll32.exe user.dll,cascadechildwindows"                      } ,;
{ "Minimize All Child-Windows"                                  , "rundll32.exe user.dll,tilechildwindows"                         } ,;
{ "Refresh Desktop"                                             , "rundll32.exe user.dll,repaintscreen"                            } ,;
{ "Swap Mouse Buttons"                                          , "rundll32.exe user.dll,swapmousebutton"                          } ,;
{ "Set Cursor Position To (0,0)"                                , "rundll32.exe user.dll,setcursorpos"                             } ,;
{ "Show 'Map Network Drive'  Window"                            , "rundll32.exe user.dll,wnetconnectdialog"                        } ,;
{ "Show 'Disconnect Network Disk'  Window"                      , "rundll32.exe user.dll,wnetdisconnectdialog"                     } ,;
{ "Display The BSOD (blue screen of death)Window"               , "rundll32.exe user.dll,disableoemlayer"                          } ,;
{ "Set New DblClick Speed (Rate)"                               , "rundll32.exe user.dll,setdoubleclicktime"                       } ,;
{ "Default beep sound"                                          , "rundll32.exe user.dll,MessageBeep"                              } ,;
{ "Set New Cursor Rate Speed"                                   , "rundll32.exe user.dll,setcaretblinktime"                        } ,;
{ "Run 'Format Disk (A)' Window"                                , "rundll32.exe shell32.dll,SHFormatDrive"                         } ,;
{ "Cold Restart Of Windows Explorer"                            , "rundll32.exe shell32.dll,SHExitWindowsEx -1"                    } ,;
{ "Shut Down Computer"                                          , "rundll32.exe shell32.dll,SHExitWindowsEx 1"                     } ,;
{ "Logoff Current User"                                         , "rundll32.exe shell32.dll,SHExitWindowsEx 0"                     } ,;
{ "Windows9x Quick Reboot"                                      , "rundll32.exe shell32.dll,SHExitWindowsEx 2"                     } ,;
{ "Add/remove programs"                                         , "rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl"             } ,;
{ "Propiedades de fecha y hora"                                 , "rundll32.exe shell32.dll,Control_RunDLL timedate.cpl,,0"        } ,;
{ "Force Windows 9x To Exit (no confirmation)"                  , "rundll32.exe krnl386.exe,exitkernel"                            } ,;
{ "Choose & Print Test Page Of Current Printer"                 , "rundll32.exe msprint2.dll,RUNDLL_PrintTestPage"                 } ,;
{ "Open DUN (dial up networking exported file)"                 , "rundll32.exe rnaui.dll,RnaRunImport"                            } ,;
{ "Start a dialup connection by name"                           , "rundll32.exe rnaui.dll,RnaDial %1"                              } ,;
{ "NetMeeting Speeddial CNF"                                    , "rundll32.exe msconf.dll,OpenConfLink %l"                        } ,;
{ "H.323 -or- Intel IPhone Internet telephony"                  , "rundll32.exe msconf.dll,NewMediaPhone %l"                       } ,;
{ "URL Rlogin / Telnet / TN3270"                                , "rundll32.exe url.dll,TelnetProtocolHandler %l"                  } ,;
{ "INF active install"                                          , "rundll32.exe advpack.dll,LaunchINFSection %1,DefaultInstall"    } ,;
{ "New briefcase"                                               , "rundll32.exe syncui.dll,Briefcase_Create %1!d! %2"              } ,;
{ "Open unknown file"                                           , "rundll32.exe shell32.dll,OpenAs_RunDLL %1"                      }  }

RETURN(aArray)
