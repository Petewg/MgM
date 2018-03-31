/*
   FILEPART.CH - Header file for the FileParts() function in FILEPART.PRG.
*/
#define FP_FILENAME     0   // "FILENAME.EXT"
#define FP_NAMEONLY     1   // "FILENAME"
#define FP_EXTENSION    2   // "EXT"
#define FP_PATH         3   // "C:\PATH\"
#define FP_DRIVE        4   // "C:"
#define FP_STRIPEXT     5   // "C:\PATH\FILENAME"
#define FP_DIR          6   // "C:\PATH"  Note lack of trailing backslash compared to FP_PATH
