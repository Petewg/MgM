// ===========================================================================
// Shell32.CH					  (c) 2004, Grigory Filatov
// =========================================================================== 
//
//   Created   : 08.09.04
//   Section   : Shell Extensions
//
//   Windows ShellAPI provides functions to implement:
//   ·	The drag-drop feature 
//   ·	Associations (used) to find and start applications 
//   ·	Extraction of icons from executable files 
//   ·	Explorer File operation
//
//      
// =========================================================================== 

// file operations
// wFunc 
#define FO_MOVE                  1
#define FO_COPY                  2 
#define FO_DELETE                3
#define FO_RENAME                4

// nFlag
#define FOF_ALLOWUNDO           64
#define FOF_FILESONLY          128  // on *.*, do only files
#define FOF_SIMPLEPROGRESS     256  // means don't show names of files
#define FOF_NOCONFIRMMKDIR     512  // don't confirm making any needed dirs
#define FOF_NOERRORUI         1024  // don't put up error UI

#define FOF_MULTIDESTFILES       1
#define FOF_CONFIRMMOUSE         2
#define FOF_SILENT               4  // don't create progress/report
#define FOF_RENAMEONCOLLISION    8
#define FOF_NOCONFIRMATION      16  // Don't prompt the user.
#define FOF_WANTMAPPINGHANDLE   32  // Fill in SHFILEOPSTRUCT.hNameMappings
