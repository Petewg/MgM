/*
   Este ejemplo requiere que tengas instalado el ocx de RMChart
   puedes descargarlo de http://www.rmchart.com/
   Oscar Lira Lira |oSkAr| - adaptado para ooHG por MigSoft
   
   coment�rio inserido em 16 de outubro de 2007
   ********************************************
   Este exemplo de uso do rmchart para gera��o de gr�ficos, foi copiado
   do exemplo demochart.prg que consta da instala��o da ooHG, e est� na
   pasta samples\activex, portanto os cr�ditos s�o de quem montou o programa
   original.

   Para conseguir utilizar o rmchart, � preciso fazer o que est� escrito
   logo no come�o do arquivo, entrar no site do rmchart, baixar a �ltima
   vers�o, instalar em sua m�quina, e depois registrar o arquivo ocx dele,
   que deve ser feito da seguinte forma :
   - clique no bot�o iniciar do windows, depois no menu clique em executar,
     na caixa onde � solicitado um comando, escreva : regsvr32 rmchart.ocx
     aparecer� uma janela em sua tela dizendo que o arquivo foi registrado
     e que programas que fa�am uso do conte�do desse arquivo j� podem
     funcionar, depois, em uma pasta qualquer em seu computador, execute
     o compile.bat para gerar o .exe e ver o resultado. este exemplo foi
     gerado usando harbour e minigui, mas pode ser usado xharbour tbem.
     
   As mudan�as realizadas, foram para adaptar o uso para a MiniGUI, e foram
   feitas por Marcelo Neves - msdn_001@yahoo.com.br - software_facil@hotmail.com
*/

#include 'minigui.ch'
#include 'RMChart.ch'

Set Procedure To tAxPrg.prg

Static oChart, oActiveX

FUNCTION Main()

   Define Window Win_1 ;
          At 0,0 ;
          Width 480 ;
          Height 330 ;
          Title 'Usando RMChart com a MiniGUI' ;
          Icon "Main" ;
          Main ;
          On Init fOpenActivex() ;
          On Size Ajust() ;
          On Maximize Ajust() ;
          On Release fCloseActivex()

   End Window

   Center Window Win_1
   Activate Window Win_1

RETURN(Nil)

Static Procedure fOpenActivex()
   Local nVersion

          oActiveX := TActiveX():New( ThisWindow.Name, 'RMChart.RMChartX' , 0 , 0 , ;
                          GetProperty(ThisWindow.Name, "width") -  2 * GetBorderWidth() , ;
                          GetProperty(ThisWindow.Name, "height") - 2 * GetBorderHeight() - ;
                                                                       GetTitleHeight() )
          oChart := oActiveX:Load()

          nVersion := oChart:RMCVersion

          oChart:RMCStyle         := RMC_CTRLSTYLEFLAT // pode ser alterado, consultar documenta��o do rmchart
          oChart:RMCUserWatermark := 'Texto de Fundo - Opcional'

          oChart:AddRegion()

          WITH OBJECT oChart:Region( 1 )

               :Footer = 'RMChart version' + Str(nVersion/100, 5, 2)
               :AddCaption()

               WITH OBJECT :Caption()
                    :Titel     := 'Gr�fico Teste'
                    :FontSize  := 10
                    :Bold      := .T.
               END

               :AddGridlessSeries()

               WITH OBJECT :GridLessSeries
                    :SeriesStyle      := RMC_PIE_GRADIENT
                    :Alignment        := RMC_FULL
                    :Explodemode      := RMC_EXPLODE_NONE
                    :Lucent           := .F.
                    :ValueLabelOn     := RMC_VLABEL_ABSOLUTE
                    :HatchMode        := RMC_HATCHBRUSH_OFF
                    :StartAngle       := 0
                    :DataString       := '30*15*40*35'
               END

          END

          oChart:Draw()

Return


Static Procedure fCloseActivex()

   IF VALTYPE(oActiveX) <> "U"
      oActiveX:Release()
   ENDIF

Return


Static Procedure Ajust()

   oActiveX:Adjust()

Return
