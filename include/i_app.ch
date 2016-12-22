////////////////////////////////////////////
// Application pseudo-properties
////////////////////////////////////////////

#translate <p:Application,App>.ExeName => GetExeFileName()
#translate <p:Application,App>.Handle => _HMG_MainHandle
#translate <p:Application,App>.Cargo => _HMG_MainCargo
#translate <p:Application,App>.FormName => _HMG_aFormNames \[ Ascan ( _HMG_aFormHandles, <p>.Handle ) \]
#translate <p:Application,App>.Col => GetWindowCol ( <p>.Handle )
#translate <p:Application,App>.Col := <arg> => MoveWindow ( <p>.Handle , <arg> , <p>.Row , <p>.Width , <p>.Height , .t. )
#translate <p:Application,App>.Row => GetWindowRow ( <p>.Handle )
#translate <p:Application,App>.Row := <arg> => MoveWindow ( <p>.Handle , <p>.Col , <arg> , <p>.Width , <p>.Height , .t. )
#translate <p:Application,App>.Width => GetWindowWidth ( <p>.Handle )
#translate <p:Application,App>.Width := <arg> => MoveWindow ( <p>.Handle , <p>.Col , <p>.Row , <arg> , <p>.Height , .t. )
#translate <p:Application,App>.Height => GetWindowHeight ( <p>.Handle )
#translate <p:Application,App>.Height := <arg> => MoveWindow ( <p>.Handle , <p>.Col , <p>.Row , <p>.Width , <arg> , .t. )
#translate <p:Application,App>.ClientWidth  => _GetClientRect ( <p>.Handle ) \[3]
#translate <p:Application,App>.ClientHeight => _GetClientRect ( <p>.Handle ) \[4]
#translate <p:Application,App>.Title => GetWindowText ( <p>.Handle )
#translate <p:Application,App>.Title := <arg> => SetWindowText ( <p>.Handle, <arg> )
#translate <p:Application,App>.Icon => _HMG_DefaultIconName
#translate <p:Application,App>.Cursor := <arg> => SetWindowCursor ( <p>.Handle, <arg> )
#translate <p:Application,App>.BackColor => _HMG_aFormBkColor \[ Ascan ( _HMG_aFormHandles, <p>.Handle ) \]
#translate <p:Application,App>.BackColor := <arg> => _SetWindowBackColor ( <p>.Handle, <arg> )
#translate <p:Application,App>.Topmost => GetProperty ( <p>.FormName, 'Topmost' )
#translate <p:Application,App>.Topmost := <arg> => _ChangeWindowTopmostStyle ( <p>.Handle, <arg> )
#translate <p:Application,App>.HelpButton => GetProperty ( <p>.FormName, 'HelpButton' )
#translate <p:Application,App>.HelpButton := <arg> => _ChangeWindowHelpButtonStyle ( <p>.FormName, <arg> )

////////////////////////////////////////////////////////////
// Application Cargo support
////////////////////////////////////////////////////////////

#xtranslate _GetAppCargo () => _HMG_MainCargo

////////////////////////////////////////////
// System pseudo-properties
////////////////////////////////////////////

#translate System.Clipboard          => RetrieveTextFromClipboard()
#translate System.Clipboard := <arg> => CopyToClipboard ( <arg> )
#translate System.DesktopWidth       => GetDesktopWidth()
#translate System.DesktopHeight      => GetDesktopHeight()
#translate System.DefaultPrinter     => GetDefaultPrinter()

#translate System.DesktopFolder      => GetDesktopFolder()
#translate System.MyDocumentsFolder  => GetMyDocumentsFolder()
#translate System.ProgramFilesFolder => GetProgramFilesFolder()
#translate System.SystemFolder       => GetSystemFolder()
#translate System.TempFolder         => GetTempFolder()
#translate System.WindowsFolder      => GetWindowsFolder()
