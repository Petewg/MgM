#include "minigui.ch"
#include "TSBrowse.ch"

#define ntrim( n ) hb_ntos( n )
#define CLR_SYS GetSysColor( 15 )

MEMVAR afont
MEMVAR zox, luwaga, lprzypo
MEMVAR zoy, zaaf
MEMVAR SYS_COLOR
MEMVAR lAscend
MEMVAR MEG
MEMVAR TME1, TME2, TME3, TME4, TME5, TME6, TME7

// --------------------------------------------------------------------------------------
PROCEDURE main
// --------------------------------------------------------------------------------------

   PUBLIC afont[ 11 ]
   PUBLIC zox := GetDesktopWidth(), luwaga := .F., lprzypo := .F.
   PUBLIC zoy := ( GetDesktopHeight() ), zaaf := {}
   PUBLIC SYS_COLOR := { GetRed( CLR_SYS ), GetGreen( CLR_SYS ), GetBlue( CLR_SYS ) }

   PRIVATE lAscend := .T.

   DEFINE FONT Font_1  FONTNAME "Arial" SIZE 10
   DEFINE FONT Font_2  FONTNAME "Arial" SIZE 12 BOLD
   DEFINE FONT Font_3  FONTNAME "MS Sans Serif" SIZE 16
   DEFINE FONT Font_4  FONTNAME "Arial" SIZE 14 BOLD
   DEFINE FONT Font_5  FONTNAME "WST_Engl" SIZE 18  BOLD
   DEFINE FONT Font_6  FONTNAME "Courier" SIZE 14 BOLD
   DEFINE FONT Font_7  FONTNAME "Times new roman" SIZE 14
   DEFINE FONT Font_8  FONTNAME "Arial" SIZE 12 BOLD UNDERLINE
   DEFINE FONT Font_11 FONTNAME "WingDings" SIZE 12 BOLD
   aFont[ 1 ] := GetFontHandle( "Font_1"  )
   aFont[ 2 ] := GetFontHandle( "Font_2"  )
   aFont[ 3 ] := GetFontHandle( "Font_3"  )
   aFont[ 4 ] := GetFontHandle( "Font_4"  )
   aFont[ 5 ] := GetFontHandle( "Font_5"  )
   aFont[ 6 ] := GetFontHandle( "Font_6"  )
   aFont[ 7 ] := GetFontHandle( "Font_7"  )
   aFont[ 8 ] := GetFontHandle( "Font_8"  )
   aFont[ 11 ] := GetFontHandle( "Font_11"  )

   SET FONT TO "Arial", 12

   TME1 := { { '&A  Shopping ',        {|| fzakup() } }, ;
      { '__', 0 }, ;
      { '&B  Entry costs ', { { '&A  Invoice ', {|| fkoszt( 'A' ) } }, ;
      { '_', 0 }, ;
      { '&B  Account ', {|| fkoszt( 'B' ) } } } }, ;
      { '__', 0 }, ;
      { '&C  Review of purchase invoices',     {|| prze_fak() }, .T. }, ;
      { '&D  Review of invoices costs',     {|| prze_kosz() } }, ;
      { '__', 0 }, ;
      { '&E  Overview adjustments to invoices, purchase', {|| prze_fakK() } }, ;
      { '__', 0 }, ;
      { '&F  Improving purchase invoices',     {|| pop_fakz() } }, ;
      { '&G  Improved invoicing costs **', 18 } }

   TME2 := { { '&A  Sales  ', { { '&A  Wholesale Invoice',   {|| f_sprzedaz( 1 ) } }, ;
      { '&B  Invoice installment ',    {|| f_sprzedaz( 4 ) } }, ;
      { '&C  Invoice and Service ',   {|| f_sprzedaz( 2 ) } }, ;
      { '&D  Online Invoice ',  {|| f_sprzedaz( 8 ) } }, ;
      { '__', 0 }, ;
      { '&E  Document Numbering ', {|| fnumery() } } } }, ;
      { '__', 0 }, ;
      { '&B  Review of invoices  ', { { '&A  All invoices  ',  {|| fwys_fak( 1 ) } }, ;
      { '&B Iinvoices    ',      {|| fwys_fak( 2 ) } }, ;
      { "&C Wholesale",      {|| fwys_fak( 3 ) } }, ;
      { "&D Retail",     {|| fwys_fak( 4 ) } }, ;
      { "&E Corrections",     {|| fwys_fak( 5 ) } }, ;
      { "&F Services",      {|| fwys_fak( 6 ) } }, ;
      { "&G Internet",    {|| fwys_fak( 7 ) } }, ;
      { '_' }, ;
      { '&H  Only correcting invoice', {|| fwys_fak( 17 ) } }, ;
      { '&I  Log corrections', {|| fwys_fak( 18 ) } } } }, ;
      { '__', 0 }, ;
      { '&C  Overview recipients  ', { { '&A  Wholesale ', {|| Lista_odb( 1 ) } }, ;
      { '_', 0 }, ;
      { '&B  Retail ', {|| Lista_odb( 2 ) } } } }, ;
      { '&D  Invoices selected recipient  ',    {|| fak_odb() } }, ;
      { '__', 0 }, ;
      { '&E  Companies takings ',           {|| wpi_u() } }, ;
      { '&F  Fiscal takings ',       {|| futargi() } }, ;
      { '__', 0 }, ;
      { '&I  Overview transfers **', 311 }, ;
      { '&J  View log of corrections to customers',{ { '&A  Selected year', {|| prze_rpk() } }, ;
      { '__' }, ;
      { '&B  All years ', {|| prze_rpk2() } } } } }

   TME3 := { { '&A  History cooperation of providers  ', {|| wsp_dos() } }, ;
      { '&B  History cooperation of customers  ', {|| wsp_dos3() } }, ;
      { '__', 0 }, ;
      { '&C  Counting the total profit', { { '&A From day to day invoices and receipts   ',  {|| fzysk( 1 ) } }, ;
      { '__' }, ;
      { '&B From number to number invoices ',   {|| fzysk( 2 ) } }, ;
      { '__' }, ;
      { '&C selected customer',         {|| fzysk( 3 ) } }, ;
      { '__' }, ;
      { '&D from day to day with handwritten no invoices  ', {|| fzysk( 4 ) } }, ;
      { '__' }, ;
      { '&E Invoices, Bills and Receipts',     {|| fzysk( 5 ) } } } }, ;
      { '&D  Counting profit itemized **', 303 }, ;
      { '&E  Counting profit invoices ', { { '&A  From day to day   ', {|| zysk3( 3 ) } }, ;
      { '__' }, ;
      { '&B  From number to number invoices   ', {|| zysk3( 4 ) } }, ;
      { '__' }, ;
      { '&C  Selected customer', { { '&A  Retail  ', {|| zysk3( 2 ) } }, ;
      { '__' }, ;
      { '&B  Wholesale   ', {|| zysk3( 1 ) } } } } } },;
      { '&F Counting sales from number to number', { { "&A  Wholesale   ",  {|| pob_vat( 1 ) } }, ;
      { '__' }, ;
      { "&B  Retail", {|| pob_vat( 2 ) } }, ;
      { '__' }, ;
      { "&C  Services ", {|| pob_vat( 3 ) } }, ;
      { '__' }, ;
      { "&D  Installments",   {|| pob_vat( 4 ) } }, ;
      { '__' }, ;
      { '&E  Corrections',  {|| pob_vat( 5 ) } }, ;
      { '__' }, ;
      { '&F  Internet', {|| pob_vat( 6 ) } } } }, ;
      { '&G  Costs',    {|| fmarze() } }, ;
      { '&H  Paid VAT', {|| zap_vat() } }, ;
      { '__', 0 }, ;
      { '&I Quantities of purchases and sales ',     {|| Ilosci1() } }, ;
      { '&J Quantities of purchases and sales of the selected range', {|| ilosci2() } }, ;
      { '&K United showing no motion ', {|| ruchy() } }, ;
      { '&L Assortment customers ', { { '&A  Wholesale', {|| asor_odb( 1 ) } }, ;
      { '__' }, ;
      { '&B  Takings fiscal', {|| asor_odb( 2 ) } }, ;
      { '__' }, ;
      { '&C  All the wholesalers  ', {|| asor_odb( 3 ) } } } }, ;
      { '&M  United deliveries',          {|| stanyd() } }, ;
      { '&N  Sellers only invoices', {|| war_sph() } }, ;
      { '__', 0 }, ;
      { '&O  Analysis of sales invoices',      {|| fan_fak() } }, ;
      { '&P  Analysis of product sales **', 317 }, ;
      { '&Q  United deliveries for representatives **', 318 } }


   TME4 := { { '&A  Payments  ', { { '&A  Outstanding ', {|| fplatnosci( 1 ) } }, ;
      { '&B  Settled ',  {|| fplatnosci( 2 ) } }, ;
      { '__', 0 }, ;
      { '&C  Total ',     {|| fplatnosci( 3 ) } } } }, ;
      { '&B Payments all **', 403 }, ;
      { "&C Payments to suppliers ", {|| zalegados() } }, ;
      { '__', 0 }, ;
      { '&D Payments cost  ', { { '&A  Outstanding   ', {|| prze_plako( .F.,, 1 ) } }, ;
      { '&B  Settled', {|| prze_plako( .F.,, 2 ) } }, ;
      { '_' }, ;
      { '&C  Total', {|| prze_plako( .F.,, 3 ) } } } }, ;
      { '&E Payments cost of day to day ', { { '&A  Delivery date  ', { { '&A  Outstanding   ', {|| prze_plako( .T., 1, 1 ) } }, ;
      { '&B  Settled', {|| prze_plako( .T., 1, 2 ) } }, ;
      { '_' }, ;
      { '&C  Total', {|| prze_plako( .T., 1, 3 ) } } } }, ;
      { '_' }, ;
      { '&B  Date of payment ', { { '&A  Outstanding   ', {|| prze_plako( .T., 2, 1 ) } }, ;
      { '&B  Settled', {|| prze_plako( .T., 2, 2 ) } }, ;
      { '_' }, ;
      { '&C  Total', {|| prze_plako( .T., 2, 3 ) } } } } } }, ;
      { '__', 0 }, ;
      { '&F Rreceivables for the selected supplier ', { { '&A  Outstanding ', {|| pla_firma( 1 ) } }, ;
      { '&B  Settled ', {|| pla_firma( 2 ) } }, ;
      { '__', 0 }, ;
      { '&C  Total ', {|| pla_firma( 3 ) } } } }, ;
      { '&G  Receivables from day to day ** ', 43 }, ;
      { '__', 0 }, ;
      { '&H  Customer total payments ',            {|| fpdlu() } }, ;
      { '&I  Customers outstanding payments',         {|| plat_odb2() } }, ;
      { '&J  Customer outstanding payments **', 407 }, ;
      { '__', 0 }, ;
      { '&K  Arrears total for today', {|| zalega_odb() } }, ;
      { '&L  Arrears total to day', {|| zalegaodb() } }, ;
      { '&M  Receivables selected recipient', { { '&A  Retail  ', {|| zalega_ten( 2 ) } }, ;
      { '__' }, ;
      { '&B  Wholesale ', {|| zalega_ten( 1 ) } } } }, ;
      { '__', 0 }, ;
      { '&N  Overview cash ', {|| fkpkw() } }, ;
      { '&O  Overview bank ', { { '&A Whole',   {|| pokabank() } }, ;
      { '&B Bank statement',   {|| pokabank2() } }, ;
      { '&C Contractor', {|| pokabank4() } } } }, ;
      { '&P  Offsetting Review ', {|| prze_komp()  } } }

   TME5 := { { '&A  Commodities ', {|| Lista_dos( .T. ) } }, ;
      { "__" }, ;
      { '&B  Costs  ', {|| Lista_dos( .F. ) } }, ;
      { '__', 0 }, ;
      { '&C  Contract to the supplier  ', {|| zamow_dos() } } }

   TME6 := { { '&A  Overview index ', {|| prze_ind() } }, ;
      { '__', 0 }, ;
      { '&C  Offer  **', 65 }, ;
      { '__', 0 }, ;
      { '&D  Offer telephone **', 62 }, ;
      { '__', 0 }, ;
      { '&E  Shopping to Shop   **', 63 }, ;
      { '&F  Wrestling **', 601 }, ;
      { '&G  Orders **', 602 }, ;
      { '&H  Orders 2 **', 603 } }

   TME7 := { { '&A  End of work', {|| DoMethod( 'o_we', 'release' ) } }, ;
      { '__', 0 }, ;
      { "&B  Who Web **", 777 }, ;
      { '__', 0 }, ;
      { '&C  Overview of prints   ', {|| fkatk() } }, ;
      { '&D  Control of prints **', 77 }, ;
      { '__', 0 }, ;
      { '&E  Improvement of sorts', { { '&A All Files    ', {|| sorty( .T. ) } }, ;
      { '_', 0 }, ;
      { '&B Only selected', {|| sort2() }  } }, 'Sorts' },;
      { '__', 0 }, ;
      { '&G  Changing the password **', 73 }, ;
      { '__', 0 }, ;
      { '&H  Reminders',            {|| fprzypo() } }, ;
      { '&I  Other terms **', 799 }, ;
      { '__', 0 }, ;
      { '&J  List of VAT rates ',          {|| pokvat() } }, ;
      { '&K  List of units ',           {|| Flis_jedn() } }, ;
      { '&L  List cash contributions',        {|| lista_wyp() } }, ;
      { '__', 0 }, ;
      { '&M  List of banks',            {|| fbanki() } }, ;
      { '&N  Statement of cash to the bank **', 400 } }

   MEG := { { '&Shopping', TME1 }, ;
      { '&Takings', TME2 }, ;
      { '&Analysis', TME3 }, ;
      { '&Loans', TME4 }, ;
      { '&Suppliers', TME5 }, ;
      { '&Indexes', TME6 }, ;
      { 'S&ystem', TME7 } }

   TME1 := NIL
   TME2 := NIL
   TME3 := NIL
   TME4 := NIL
   TME5 := NIL
   TME6 := NIL
   TME7 := NIL

   DEFINE WINDOW o_we ;
      AT 0, 0 WIDTH zox HEIGHT zoy ;
      TITLE ' Browse Menu' ;
      MAIN ICON "MAIN" ;
      ON INIT TsMenu( 5, 5, MEG, 'o_we' ) ;
      NOMAXIMIZE NOSIZE NOSYSMENU NOCAPTION

   @ zoy - 100, 10 LABEL Lopis1 VALUE 'Press Enter, Esc, letter or ' WIDTH 300 HEIGHT 20 FONT 'Arial' SIZE 12 BOLD
   @ zoy - 100, 210 LABEL Lopis2 VALUE Chr( 231 ) + Chr( 232 ) + Chr( 233 ) + Chr( 234 ) WIDTH 300 HEIGHT 20 FONT 'WingDings' SIZE 12

   ON KEY ESCAPE ACTION o_we.release

   END WINDOW
   ACTIVATE WINDOW o_we

RETURN

// --------------------------------------------------------------------------------------
PROCEDURE fzakup()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fkoszt()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE prze_fak()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE prze_kosz()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE prze_fakK()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE pop_fakz()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE f_sprzedaz()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fnumery()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fwys_fak()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE Lista_odb()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fak_odb()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE wpi_u()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE futargi()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE prze_rpk()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE prze_rpk2()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE wsp_dos()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE wsp_dos3()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fzysk()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE zysk3()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE pob_vat()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fmarze()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE zap_vat()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE Ilosci1()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE Ilosci2()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE ruchy()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE asor_odb()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE war_sph()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fan_fak()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fplatnosci()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE zalegados()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE prze_plako()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE pla_firma()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fpdlu()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE plat_odb2()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE zalega_odb()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE zalegaodb()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE zalega_ten()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fkpkw()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE pokabank()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE pokabank2()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE pokabank4()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE prze_komp()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE Lista_dos()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE zamow_dos()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE prze_ind()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE sorty()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE sort2()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fprzypo()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE pokvat()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE Flis_jedn()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fbanki()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE lista_wyp()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE f_pvat()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE stanyd()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
// --------------------------------------------------------------------------------------
PROCEDURE fkatk()
   msginfo( ProcFile() + CRLF + ProcName(), ntrim( ProcLine() ) )
