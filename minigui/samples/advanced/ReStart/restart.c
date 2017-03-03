#include <windows.h>
// restart.c
// parameters:
// 1. progname;
// 2. windows handle to close
int main(int argc, char** argv)
{
   HWND handle = ( HWND ) atol( argv[ 2 ] );

   PostMessage( handle, WM_QUIT, 0, 0 );

   WinExec( argv[ 1 ], 1 );

   return EXIT_SUCCESS;
}
