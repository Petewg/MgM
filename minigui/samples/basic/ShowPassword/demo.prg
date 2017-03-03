/*
 * HMG TextBox Password Demo
*/

#include 'hmg.ch'

FUNCTION Main()

  DEFINE WINDOW Main_WA;
    MAIN;
    ROW    100;
    COL    100;
    WIDTH  225;
    HEIGHT 150;
    TITLE  'TextBox Password Test';
    NOSIZE;
    NOMAXIMIZE;
    NOMINIMIZE

    DEFINE LABEL Pass_LA
      ROW     08
      COL     10
      WIDTH  200
      HEIGHT  16
      VALUE  'Type password:'
    END LABEL

    DEFINE TEXTBOX Pass_TE
      ROW        26
      COL        10
      WIDTH     200
      HEIGHT     21
      VALUE     'my password'
      PASSWORD  .T.
    END TEXTBOX

    DEFINE CHECKBOX Pass_CBO
      ROW       55
      COL       10
      WIDTH    200
      HEIGHT    16
      CAPTION  'Show password'
      ONCHANGE ShowPassword()
    END CHECKBOX

    DEFINE BUTTON OK_BU
      ROW     85
      COL     25
      WIDTH   80
      HEIGHT  25
      CAPTION 'OK'
      ACTION  Main_WA.RELEASE
    END BUTTON

    DEFINE BUTTON Cancel_BU
      ROW     85
      COL    115
      WIDTH   80
      HEIGHT  25
      CAPTION 'Cancel'
      ACTION  Main_WA.RELEASE
    END BUTTON

    ON KEY ESCAPE ACTION Main_WA.RELEASE

  END WINDOW

  Main_WA.ACTIVATE

RETURN NIL


#define EM_SETPASSWORDCHAR      0x00CC

FUNCTION ShowPassword()
  LOCAL cPass := Main_WA.Pass_TE.VALUE
  LOCAL lShowPass := Main_WA.Pass_CBO.VALUE

  If lShowPass
     SendMessage(Main_WA.Pass_TE.HANDLE, EM_SETPASSWORDCHAR, 0, 0)
     Main_WA.Pass_TE.REFRESH
  Else
     Main_WA.Pass_TE.RELEASE
     DoEvents()
     DEFINE TEXTBOX Pass_TE
       PARENT Main_WA
       ROW        26
       COL        10
       WIDTH     200
       HEIGHT     21
       VALUE     cPass
       PASSWORD  .T.
     END TEXTBOX
  EndIf

RETURN NIL
