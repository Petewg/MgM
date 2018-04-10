#define VERSION_MAJOR      1
#define VERSION_MINOR      0
#define VERSION_BUILD      213

#define HELP_MSG_NO_PARAMETERS  0
#define HELP_MSG_FILE_NOT_FOUND 1

#define DBF_FS 'FlagShip'
#define DBF_FB 'FoxBase'
#define DBF_FP 'FoxPro'
#define DBF_CL 'Clipper'
#define DBF_D3 'dBaseIII'
#define DBF_D4 'dBaseIV'
#define DBF_D5 'dBaseV'

#define MEMO_TYPE_NONE 1
#define MEMO_TYPE_DBV  2
#define MEMO_TYPE_DBTV 3
#define MEMO_TYPE_DBT  4
#define MEMO_TYPE_DBT4 5
#define MEMO_TYPE_SQL  6
#define MEMO_TYPE_FMP  7
#define MEMO_TYPE_FPT  8

#define MEMO_TYPE_DESC {{MEMO_TYPE_NONE, "None"},;
                        {MEMO_TYPE_DBV , ".dbv"},;
                        {MEMO_TYPE_DBTV, '.dbv and .dbt'},;
                        {MEMO_TYPE_DBT , '.dbt'},;
                        {MEMO_TYPE_DBT4 , '.dbt in dBaseIV format'},;
                        {MEMO_TYPE_SQL , 'SQL table'},;
                        {MEMO_TYPE_FMP , '.fmp'},;
                        {MEMO_TYPE_FPT , '.fpt'}}


#define DBF_TYPE {{0x03,{DBF_FS,DBF_D3,DBF_D4,DBF_D5,DBF_FB,DBF_FP,DBF_CL},MEMO_TYPE_NONE},;
                  {0x04,{DBF_D4,DBF_D5,DBF_FS},MEMO_TYPE_NONE},;
                  {0x05,{DBF_D5,DBF_FP,DBF_FS},MEMO_TYPE_NONE},;
                  {0x30,{DBF_FP},MEMO_TYPE_FPT},;
                  {0x43,{DBF_FS},MEMO_TYPE_DBV},;
                  {0xB3,{DBF_FS},,MEMO_TYPE_DBTV},;
                  {0x83,{DBF_FS,DBF_D3,DBF_D4,DBF_D5,DBF_FB,DBF_FP,DBF_CL},MEMO_TYPE_DBT},;
                  {0x8B,{DBF_D4,DBF_D5},MEMO_TYPE_DBT4},;
                  {0x8E,{DBF_D4,DBF_D5},MEMO_TYPE_SQL},;
                  {0xF5,{DBF_FP},MEMO_TYPE_FMP}}
