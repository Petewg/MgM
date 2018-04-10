/*
  sistema     : superchef pizzaria
  programa    : backup
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

memvar destino_backup

function backup()

         private destino_backup

         define window form_backup;
                at 000,000;
                width 400;
                height 225;
                title 'Backup do Banco de Dados';
                icon path_imagens+'icone.ico';
                modal ;
                nosize

                define buttonex button_backup
                       picture path_imagens+'img_zip.bmp'
                       col 060
                       row 140
                       width 180
                       height 040
                       caption 'Iniciar o Backup'
                       action CreateZip()
                       fontname 'verdana'
                       fontsize 9
                       fontcolor _preto_001
                end buttonex
                define buttonex button_destino
                       picture path_imagens+'img_destino.bmp'
                       col 280
                       row 010
                       width 100
                       height 040
                       caption 'Pasta ?'
                       action Escolhe_Pasta()
                       fontname 'verdana'
                       fontsize 9
                       fontcolor _preto_001
                end buttonex
                define buttonex button_sair
                       picture path_imagens+'img_sair.bmp'
                       col 250
                       row 140
                       width 090
                       height 040
                       caption 'Sair'
                       action form_backup.release
                end buttonex

                define progressbar progressbar_1
                       row 070
                       col 045
                       width 310
                       height 030
                       rangemin 0
                       rangemax 010
                       value 0
                       forecolor {000,130,000}
                end progressbar

                define label label_local
                       row 010
                       col 010
                       autosize .t.
                       height 20
                       value 'Escolha o local para ser gerado o backup'
                       fontbold .t.
                       transparent .t.
                end label
                define label label_destino
                       row 030
                       col 010
                       width 240
                       height 40
                       value ''
                       fontbold .t.
                       transparent .t.
                       fontcolor BLUE
                end label
                define label label_zip
                       row 110
                       col 25
                       width 350
                       height 20
                       value ''
                       fontname 'arial'
                       fontsize 10
                       tooltip ''
                       fontbold .t.
                       transparent .t.
                       centeralign .t.
                end label
         end window

         form_backup.center
         form_backup.activate

         return(nil)
*-------------------------------------------------------------------------------
static function escolhe_pasta()

       destino_backup := GetFolder('Escolha a pasta')
       SetProperty('form_backup','label_destino','value',alltrim(destino_backup))

       return(nil)
*-------------------------------------------------------------------------------
static function createzip()

       local aDir := directory('c:\super\tabelas\*.dbf'), aFiles:= {}, nLen
       local cPath := 'c:\super\tabelas\'

       if empty(destino_backup)
          msgstop('Você precisa definir para onde o backup será feito','Atenção')
          return(nil)
       endif

       FillFiles( aFiles, aDir, cPath )

       if ( nLen := Len(aFiles) ) > 0
           form_backup.ProgressBar_1.RangeMin := 1
           form_backup.ProgressBar_1.RangeMax := nLen
           MODIFY CONTROL label_zip OF form_backup FONTCOLOR {0,0,0}

           COMPRESS aFiles ;
               TO destino_backup+'\backup_pizzaria.zip' ;
               BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
               LEVEL 9 ;
               OVERWRITE ;
               STOREPATH

           MODIFY CONTROL label_zip OF form_backup FONTCOLOR {0,0,255}
           form_backup.label_zip.value := 'Backup realizado com sucesso'
       endif

       return(nil)
*-------------------------------------------------------------------------------
static Function ProgressUpdate( nPos , cFile , lShowFileName )

       Default lShowFileName := .F.

       form_backup.progressbar_1.Value := nPos
       form_backup.label_zip.value := cFileNoPath( cFile )

       if lShowFileName
          INKEY(.1)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function FillFiles( aFiles, cDir, cPath )

       local aSubDir, cItem

       for cItem :=1 TO LEN(cDir)
           if cDir[cItem][5] <> 'D'
              AADD( aFiles, cPath+cDir[cItem][1] )
           elseif cDir[cItem][1] <> '.' .AND. cDir[cItem][1] <> '..'
              aSubDir := DIRECTORY( cPath+cDir[cItem][1]+'\*.*', 'D' )
              aFiles:=FillFiles( aFiles, aSubdir, cPath+cDir[cItem][1]+'\' )
           endif
       next

       return(aFiles)