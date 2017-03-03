#include <windows.h>
#include <windowsx.h>
#include <stdio.h>


#define VER_LINE_GAP			2
#define NO_OF_GRAPH			4
#define	GRAPH_GAP			6
#define NO_OF_BAR_PARTS			4
#define CENTER_VAL			2.5
#define LINE_GAP_LEN			3
#define BUF_LEN				20
#define VER_MAX_MOV			20
#define GRAPH_HEADER_LOC		20
#define NO_OF_POINTS			30
#define DARK_GREEN			125
#define LIGHT_GREEN			255

struct Health_Graph
{
	long	RxBytes;
	long	TxBytes;
};

struct lp
{
	unsigned long RxValue;
	unsigned long TxValue;
	unsigned int  GraphNo;
};

struct Health_Graph GraphInfo[NO_OF_GRAPH][NO_OF_POINTS];
struct lp *User_Data;

LONG64 TotalRxBytes, TotalTxBytes;
unsigned int MaxRx, MaxTx;

void DrawGraph(HDC hdc, RECT Rect);
void UpdateGraph(HDC hdc, RECT Rect, unsigned long RxValue, unsigned long TxValue, int GraphNo);
void DrawBar(HDC hdc, RECT Rect, int Process_Value);
