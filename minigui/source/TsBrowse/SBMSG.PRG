/*
   SBMsgPol.prg
   Program to load messages for TSBrowse Multi-Lingual feature
   Author: Manuel Mercado
*/

#include "MiniGui.ch"

Function LoadMsg()
Local aMsg, cLang := Upper( Left( Set ( _SET_LANGUAGE ), 2 ) )
Local aProper

aMsg := { "Yes", ;                   // ::aMsg[ 1 ]
          "No", ;                    // ::aMsg[ 2 ]
          "Record In Use", ;         // ::aMsg[ 3 ]
          "Try Again", ;             // ::aMsg[ 4 ]
          "Record Not Appended", ;   // ::aMsg[ 5 ]
          "&Undo", ;                 // ::aMsg[ 6 ]
          "&Copy Column", ;          // ::aMsg[ 7 ]
          "Cu&t Column", ;           // ::aMsg[ 8 ]
          "&Paste Column", ;         // ::aMsg[ 9 ]
          "&Delete Column", ;        // ::aMsg[ 10 ]
          "Delete", ;                // ::aMsg[ 11 ]
          "Copy", ;                  // ::aMsg[ 12 ]
          "Cut", ;                   // ::aMsg[ 13 ]
          "Move &Down", ;            // ::aMsg[ 14 ]
          "Move &Right", ;           // ::aMsg[ 15 ]
          "Move &Up", ;              // ::aMsg[ 16 ]
          "Move &Left", ;            // ::aMsg[ 17 ]
          "Move &Next", ;            // ::aMsg[ 18 ]
          "Cu&rsor", ;               // ::aMsg[ 19 ]
          "Date:", ;                 // ::aMsg[ 20 ]
          "Page:", ;                 // ::aMsg[ 21 ]
          "Time:", ;                 // ::aMsg[ 22 ]
          "(Preview)", ;             // ::aMsg[ 23 ]
          "Column", ;                // ::aMsg[ 24 ]
          "Visible Area", ;          // ::aMsg[ 25 ]
          "Columns Width", ;         // ::aMsg[ 26 ]
          "Tsbrowse SetFilter() Types don't match current index key type", ;
          "Error", ;                 // ::aMsg[ 28 ]
          "The file", ;              // ::aMsg[ 29 ]
          "doesn't exist", ;         // ::aMsg[ 30 ]
          "Width:", ;                // ::aMsg[ 31 ]
          "Memo Field", ;            // ::aMsg[ 32 ]
          "Editing:", ;              // ::aMsg[ 33 ]
          "&Accept", ;               // ::aMsg[ 34 ]
          "&Cancel", ;               // ::aMsg[ 35 ]
          "&Help", ;                 // ::aMsg[ 36 ]
          "Delete Record ?", ;       // ::aMsg[ 37 ]
          "Delete Row ?", ;          // ::aMsg[ 38 ]
          "Confirm", ;               // ::aMsg[ 39 ]
          "Record in use, it can't be locked", ;  // ::aMsg[ 40 ]
          "Press [Esc] to cancel editing mode", ; // ::aMsg[ 41 ]
          "Key", ;                   // ::aMsg[ 42 ]
          "Value", ;                 // ::aMsg[ 43 ]
          "Print", ;                 // ::aMsg[ 44 ]
          "Exit", ;                  // ::aMsg[ 45 ]
          "", ;    // ::aMsg[ 46 ]      (future possible usage)
          "", ;    // ::aMsg[ 47 ]
          "", ;    // ::aMsg[ 48 ]
          "", ;    // ::aMsg[ 49 ]
          "" }     // ::aMsg[ 50 ]

// some conjunctions and prepositions for TSBrowse:Proper() method
// keep spaces and capitals
      aProper := { " To ", ;    // ::aMsg[ 51 ]
                   " Of ", ;    // ::aMsg[ 52 ]
                   " In ", ;    // ::aMsg[ 53 ]
                   " And ", ;   // ::aMsg[ 54 ]
                   " Or " }     // ::aMsg[ 55 ]


#ifdef _MULTILINGUAL_

// LANGUAGE IS NOT SUPPORTED BY hb_langSelect() FUNCTION

IF _HMG_LANG_ID == 'FI'      // FINNISH
   cLang := 'FI'
ENDIF

do case

    case cLang == "FR"        // French
   /////////////////////////////////////////////////////////////
   // FRENCH
   ////////////////////////////////////////////////////////////
/*
   ISO Name...: French
   Translator.: Richard Chidiak <rcc@cbati.com>
   Country....: France
   Date.......: February 18th, 2002
*/

         aMsg := { "Oui", ;                                    // ::aMsg[ 1 ]
                   "Non", ;                                    // ::aMsg[ 2 ]
                   "Enregistrement en cours d'utilisation", ;  // ::aMsg[ 3 ]
                   "Essayez encore", ;                         // ::aMsg[ 4 ]
                   hb_oemtoansi("Enregistrement non ajoutÈ"), ;   // ::aMsg[ 5 ]
                   "&Annuler", ;              // ::aMsg[ 6 ]
                   "&Copier Colonne", ;       // ::aMsg[ 7 ]
                   "Co&uper Colonne", ;       // ::aMsg[ 8 ]
                   "Co&Ller Colonne", ;       // ::aMsg[ 9 ]
                   "&Supprimer Colonne", ;    // ::aMsg[ 10 ]
                   "Supprimer", ;             // ::aMsg[ 11 ]
                   "Copier", ;                // ::aMsg[ 12 ]
                   "Couper", ;                // ::aMsg[ 13 ]
                   hb_oemtoansi("DÈplacer vers le &bas"), ;        // ::aMsg[ 14 ]
                   hb_oemtoansi("DÈplacer ‡ &droite"), ;           // ::aMsg[ 15 ]
                   hb_oemtoansi("DÈplacer vers le &haut"), ;       // ::aMsg[ 16 ]
                   hb_oemtoansi("DÈplacer ‡ &gauche"), ;           // ::aMsg[ 17 ]
                   hb_oemtoansi("DÈplacer vers le suivant"), ;     // ::aMsg[ 18 ]
                   "Cu&rseur", ;              // ::aMsg[ 19 ]
                   "Date:", ;                 // ::aMsg[ 20 ]
                   "Page:", ;                 // ::aMsg[ 21 ]
                   "Heure:", ;                // ::aMsg[ 22 ]
                   hb_oemtoansi("(PrÈvisualisation)"), ;    // ::aMsg[ 23 ]
                   "Colonne", ;               // ::aMsg[ 24 ]
                   "Partie visible", ;        // ::aMsg[ 25 ]
                   "Largeur Colonnes", ;      // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() les Types ne correspondent pas au type d'index", ;
                   "Erreur", ;                // ::aMsg[ 28 ]
                   "Le fichier", ;            // ::aMsg[ 29 ]
                   "n'existe pas", ;          // ::aMsg[ 30 ]
                   "Largeur:", ;              // ::aMsg[ 31 ]
                   "Champs Memo", ;           // ::aMsg[ 32 ]
                   "Edition:", ;              // ::aMsg[ 33 ]
                   "&Accepter", ;             // ::aMsg[ 34 ]
                   "&Annuler", ;              // ::aMsg[ 35 ]
                   "Ai&de", ;                 // ::aMsg[ 36 ]
                   "Supprimer Enregistrement ?", ;       // ::aMsg[ 37 ]
                   "Supprimler Ligne ?", ;          // ::aMsg[ 38 ]
                   "Confirmer", ;               // ::aMsg[ 39 ]
                   hb_oemtoansi("Enregistrement en cours d'utilisation, ne peut Ítre verrouillÈ"), ;  // ::aMsg[ 40 ]
                   "Appuyez sur Echap pour annuler le mode Edition", ; // ::aMsg[ 41 ]
                   "Clef", ;    // ::aMsg[ 42 ]
                   "Valeur", ;  // ::aMsg[ 43 ]
                   "Copie", ;   // ::aMsg[ 44 ]
                   "Sortie", ;  // ::aMsg[ 45 ]
                   "", ;    // ::aMsg[ 46 ] (future possible usage)
                   "", ;    // ::aMsg[ 47 ]
                   "", ;    // ::aMsg[ 48 ]
                   "", ;    // ::aMsg[ 49 ]
                   "" }     // ::aMsg[ 50 ]

   // some conjunctions and prepositions for TSBrowse:Proper() method
   // keep spaces and capitals
         aProper := { " A ", ;    // ::aMsg[ 51 ]
                      " De ", ;    // ::aMsg[ 52 ]
                      " Dans ", ;    // ::aMsg[ 53 ]
                      " Et ", ;   // ::aMsg[ 54 ]
                      " Ou " }     // ::aMsg[ 55 ]

    case /*cLang == "DEWIN" .OR.*/ cLang == "DE"       // German
   /////////////////////////////////////////////////////////////
   // GERMAN
   ////////////////////////////////////////////////////////////
/*
   ISO Name...: German
   Translator.: Detlef Hoefner <hoefner@odn.de>
   Country....: Germany
   Date.......: February 19th, 2002
*/

         aMsg :=    { "Ja", ;                                                      // ::aMsg[  1 ]
                      "Nein", ;                                                    // ::aMsg[  2 ]
                      "Der Satz ist gesperrt", ;                                   // ::aMsg[  3 ]
                      "Bitte noch einmal versuchen", ;                             // ::aMsg[  4 ]
                      "Der Satz konnte nicht erzeugt werden", ;                    // ::aMsg[  5 ]
                      "&RÅckgÑngig", ;                                             // ::aMsg[  6 ]
                      "Spalte &Kopieren", ;                                        // ::aMsg[  7 ]
                      "Spalte A&usschneiden", ;                                    // ::aMsg[  8 ]
                      "Spalte E&infÅgen", ;                                        // ::aMsg[  9 ]
                      "Spalte &Lîschen", ;                                         // ::aMsg[ 10 ]
                      "Lîschen", ;                                                 // ::aMsg[ 11 ]
                      "Kopieren", ;                                                // ::aMsg[ 12 ]
                      "Ausschneiden", ;                                            // ::aMsg[ 13 ]
                      "Nach &Unten", ;                                             // ::aMsg[ 14 ]
                      "Nach &Rechts", ;                                            // ::aMsg[ 15 ]
                      "Nach &Oben", ;                                              // ::aMsg[ 16 ]
                      "Nach &Links", ;                                             // ::aMsg[ 17 ]
                      "Zum &NÑchsten", ;                                           // ::aMsg[ 18 ]
                      "Cu&rsor", ;                                                 // ::aMsg[ 19 ]
                      "Datum:", ;                                                  // ::aMsg[ 20 ]
                      "Seite:", ;                                                  // ::aMsg[ 21 ]
                      "Uhrzeit:", ;                                                // ::aMsg[ 22 ]
                      "(Vorschau)", ;                                              // ::aMsg[ 23 ]
                      "Spalte", ;                                                  // ::aMsg[ 24 ]
                      "Sichtbarer Bereich", ;                                      // ::aMsg[ 25 ]
                      "Spaltenbreite", ;                                           // ::aMsg[ 26 ]
                      "Tsbrowse SetFilter() Typ passt nicht zum aktuellen Index", ;// ::aMsg[ 27 ]
                      "Fehler", ;                                                  // ::aMsg[ 28 ]
                      "Die Datei", ;                                               // ::aMsg[ 29 ]
                      "existiert nicht", ;                                         // ::aMsg[ 30 ]
                      "Breite:", ;                                                 // ::aMsg[ 31 ]
                      "Memo Feld", ;                                               // ::aMsg[ 32 ]
                      "Bearbeiten", ;                                              // ::aMsg[ 33 ]
                      "&öbernehmen", ;                                             // ::aMsg[ 34 ]
                      "A&bbrechen", ;                                              // ::aMsg[ 35 ]
                      "&Hilfe", ;                                                  // ::aMsg[ 36 ]
                      "Soll der Satz gelîscht werden ?", ;                         // ::aMsg[ 37 ]
                      "Soll die Zeile gelîscht werden ?", ;                        // ::aMsg[ 38 ]
                      "Bitte bestÑtigen", ;                                        // ::aMsg[ 39 ]
                      "Der Satz wird verwendet und kann nicht gesperrt werden", ;  // ::aMsg[ 40 ]
                      "Taste [Esc] beendet die Bearbeitung", ;                     // ::aMsg[ 41 ]
                      "Schlussel", ;  // ::aMsg[ 42 ]
                      "Wert", ;       // ::aMsg[ 43 ]
                      "Druck", ;      // ::aMsg[ 44 ]
                      "Ausgang", ;    // ::aMsg[ 45 ]
                      "", ;    // ::aMsg[ 46 ] (future possible usage)
                      "", ;    // ::aMsg[ 47 ]
                      "", ;    // ::aMsg[ 48 ]
                      "", ;    // ::aMsg[ 49 ]
                      "" }     // ::aMsg[ 50 ]

   // some conjunctions and prepositions for TSBrowse:Proper() method
   // keep spaces and capitals
         aProper := { " Bis ", ;    // ::aMsg[ 51 ]
                      " Von ", ;    // ::aMsg[ 52 ]
                      " In ", ;     // ::aMsg[ 53 ]
                      " Und ", ;    // ::aMsg[ 54 ]
                      " Oder " }    // ::aMsg[ 55 ]

   case cLang == "IT"        // Italian
   /////////////////////////////////////////////////////////////
   // ITALIAN
   ////////////////////////////////////////////////////////////
/*
   ISO Name...: Italian
   Translator.: Enrico Maria Giordano <e.m.giordano@emagsoftware.it>
   Country....: Italy
   Date.......: February 18th, 2002
*/

         aMsg := { "Si", ;                    // ::aMsg[ 1 ]
                   "No", ;                    // ::aMsg[ 2 ]
                   "Record In uso", ;         // ::aMsg[ 3 ]
                   "Riprova", ;               // ::aMsg[ 4 ]
                   "Record Non Aggiunto", ;   // ::aMsg[ 5 ]
                   "&Annulla", ;              // ::aMsg[ 6 ]
                   "&Copia Colonna", ;        // ::aMsg[ 7 ]
                   "&Taglia Colonna", ;       // ::aMsg[ 8 ]
                   "&Incolla Colonna", ;      // ::aMsg[ 9 ]
                   "Ca&ncella Colonna", ;     // ::aMsg[ 10 ]
                   "Cancella", ;              // ::aMsg[ 11 ]
                   "Copia", ;                 // ::aMsg[ 12 ]
                   "Taglia", ;                // ::aMsg[ 13 ]
                   "Sposta in &Basso", ;      // ::aMsg[ 14 ]
                   "Sposta a &Destra", ;      // ::aMsg[ 15 ]
                   "Sposta in &Alto", ;       // ::aMsg[ 16 ]
                   "Sposta a &Sinistra", ;    // ::aMsg[ 17 ]
                   "Vai al &Prossimo", ;      // ::aMsg[ 18 ]
                   "Cu&rsore", ;              // ::aMsg[ 19 ]
                   "Data:", ;                 // ::aMsg[ 20 ]
                   "Pagina:", ;               // ::aMsg[ 21 ]
                   "Ora:", ;                  // ::aMsg[ 22 ]
                   "(Anteprima)", ;           // ::aMsg[ 23 ]
                   "Colonna", ;               // ::aMsg[ 24 ]
                   "Area Visibile", ;         // ::aMsg[ 25 ]
                   "Larghezza Colonna", ;     // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() Tipi non corrispondenti alla chiave dell'indice corrente", ;
                   "Errore", ;                // ::aMsg[ 28 ]
                   "Il file", ;               // ::aMsg[ 29 ]
                   "non esiste", ;            // ::aMsg[ 30 ]
                   "Larghezza:", ;            // ::aMsg[ 31 ]
                   "Campo Memo", ;            // ::aMsg[ 32 ]
                   "Modifica:", ;             // ::aMsg[ 33 ]
                   "&Conferma", ;             // ::aMsg[ 34 ]
                   "&Annulla", ;              // ::aMsg[ 35 ]
                   "A&iuto", ;                // ::aMsg[ 36 ]
                   "Cancello il Record ?", ;  // ::aMsg[ 37 ]
                   "Cancello la Riga ?", ;    // ::aMsg[ 38 ]
                   "Conferma", ;              // ::aMsg[ 39 ]
                   "Record in uso, impossibile bloccare", ;  // ::aMsg[ 40 ]
                   "Premi [Esc] per uscire dalla fase di modifica", ; // ::aMsg[ 41 ]
                   "Chiave", ;    // ::aMsg[ 42 ]
                   "Valore", ;    // ::aMsg[ 43 ]
                   "Stampa", ;    // ::aMsg[ 44 ]
                   "Uscita", ;    // ::aMsg[ 45 ]
                   "", ;    // ::aMsg[ 46 ] (future possible usage)
                   "", ;    // ::aMsg[ 47 ]
                   "", ;    // ::aMsg[ 48 ]
                   "", ;    // ::aMsg[ 49 ]
                   "" }     // ::aMsg[ 50 ]

   // some conjunctions and prepositions for TSBrowse:Proper() method
   // keep spaces and capitals
         aProper := { " A ", ;    // ::aMsg[ 51 ]
                      " Di ", ;    // ::aMsg[ 52 ]
                      " In ", ;    // ::aMsg[ 53 ]
                      " Y ", ;   // ::aMsg[ 54 ]
                      " O " }     // ::aMsg[ 55 ]

    case cLang == "PL" /*.OR. cLang == "PLWIN" .OR. cLang == "PL852" .OR. cLang == "PLISO" .OR. cLang == "PLMAZ"*/   // Polish
   /////////////////////////////////////////////////////////////
   // POLISH
   ////////////////////////////////////////////////////////////
/*
   ISO Name...: Polish
   Translator.: Marcin P≥atek <marcinplatek@wp.pl>
   Country....: Poland
   Date.......: February 22th, 2002
*/
         aMsg := { "Tak", ;                   // ::aMsg[ 1 ]
                   "Nie", ;                   // ::aMsg[ 2 ]
                   "Rekord zablokowany", ;    // ::aMsg[ 3 ]
                   "PonÛw", ;                 // ::aMsg[ 4 ]
                   "Nie do≥πczono rekordu", ; // ::aMsg[ 5 ]
                   "OdtwÛrz", ;               // ::aMsg[ 6 ]
                   "Kopiuj columnÍ", ;        // ::aMsg[ 7 ]
                   "UsuÒ kolumnÍ", ;          // ::aMsg[ 8 ]
                   "Wklej kolumnÍ", ;         // ::aMsg[ 9 ]
                   "Kasuj kolumnÍ", ;         // ::aMsg[ 10 ]
                   "Kasuj", ;                 // ::aMsg[ 11 ]
                   "Kopiuj", ;                // ::aMsg[ 12 ]
                   "Wytnij", ;                // ::aMsg[ 13 ]
                   "Na dÛ≥", ;                // ::aMsg[ 14 ]
                   "W prawo", ;               // ::aMsg[ 15 ]
                   "W gÛrÍ", ;                // ::aMsg[ 16 ]
                   "W lewo", ;                // ::aMsg[ 17 ]
                   "NastÍpna pozycja", ;      // ::aMsg[ 18 ]
                   "Kursor", ;                // ::aMsg[ 19 ]
                   "Data:", ;                 // ::aMsg[ 20 ]
                   "Strona:", ;               // ::aMsg[ 21 ]
                   "Czas:", ;                 // ::aMsg[ 22 ]
                   "(Podglπd)", ;             // ::aMsg[ 23 ]
                   "Kolumna", ;               // ::aMsg[ 24 ]
                   "Obszar widoczny", ;       // ::aMsg[ 25 ]
                   "D≥ugoúÊ kolumny", ;       // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() Typ niezgodny z aktualnym kluczem indeksowym", ;
                   "B≥πd", ;                  // ::aMsg[ 28 ]
                   "ZbiÛr", ;                 // ::aMsg[ 29 ]
                   "nie istnieje", ;          // ::aMsg[ 30 ]
                   "D≥ugoúÊ:", ;              // ::aMsg[ 31 ]
                   "Pole memo", ;             // ::aMsg[ 32 ]
                   "Edycja:", ;               // ::aMsg[ 33 ]
                   "&Akceptuj", ;             // ::aMsg[ 34 ]
                   "&OdrzuÊ", ;               // ::aMsg[ 35 ]
                   "&Pomoc", ;                // ::aMsg[ 36 ]
                   "Kasuj rekord ?", ;        // ::aMsg[ 37 ]
                   "Kasuj wiersz ?", ;        // ::aMsg[ 38 ]
                   "Potwierdü", ;             // ::aMsg[ 39 ]
                   "Rekord zajÍty, brak moøliwoúci zablokowania", ;  // ::aMsg[ 40 ]
                   "Naciúnij [Esc] aby przerwaÊ edycjÍ", ; // ::aMsg[ 41 ]
                   "Klucz", ;                 // ::aMsg[ 42 ]
                   "WartoúÊ", ;               // ::aMsg[ 43 ]
                   "Drukuj", ;                // ::aMsg[ 44 ]
                   "Wyjúcie", ;               // ::aMsg[ 45 ]
                   "", ;    // ::aMsg[ 46 ] (future possible usage)
                   "", ;    // ::aMsg[ 47 ]
                   "", ;    // ::aMsg[ 48 ]
                   "", ;    // ::aMsg[ 49 ]
                   "" }     // ::aMsg[ 50 ]

   // some conjunctions and prepositions for TSBrowse:Proper() method
   // keep spaces and capitals
         aProper := { " Do ", ;    // ::aMsg[ 51 ]
                      " Z ", ;     // ::aMsg[ 52 ]
                      " W ", ;     // ::aMsg[ 53 ]
                      " I ", ;     // ::aMsg[ 54 ]
                      " Lub " }    // ::aMsg[ 55 ]

    case cLang == "PT"        // Portuguese
   /////////////////////////////////////////////////////////////
   // PORTUGUESE
   ////////////////////////////////////////////////////////////
/*
   ISO Name...: Portuguese
   Translator.: Antonio Carlos Pantaglione <Toninho@fwi.com.br>
   Country....: Brazil
   Date.......: February 18th, 2002
*/

         aMsg := { "Sim", ;                   // ::aMsg[ 1 ]
                   "N„o", ;                   // ::aMsg[ 2 ]
                   "Registro en uso", ;       // ::aMsg[ 3 ]
                   "Tentar novamente", ;      // ::aMsg[ 4 ]
                   "Registro n„o inserido", ; // ::aMsg[ 5 ]
                   "&Desfazer", ;             // ::aMsg[ 6 ]
                   "&Copiar Coluna", ;        // ::aMsg[ 7 ]
                   "Recor&tar Coluna", ;      // ::aMsg[ 8 ]
                   "Co&lar Coluna", ;         // ::aMsg[ 9 ]
                   "&Deletar Coluna", ;       // ::aMsg[ 10 ]
                   "Deletar", ;               // ::aMsg[ 11 ]
                   "Copiar", ;                // ::aMsg[ 12 ]
                   "Recortar", ;              // ::aMsg[ 13 ]
                   "Mover &Abaixo", ;         // ::aMsg[ 14 ]
                   "Mover &Direita", ;        // ::aMsg[ 15 ]
                   "Mover &Acima", ;          // ::aMsg[ 16 ]
                   "Mover &Esquerda", ;       // ::aMsg[ 17 ]
                   "Mover &PrÛxima", ;        // ::aMsg[ 18 ]
                   "Cu&rsor", ;               // ::aMsg[ 19 ]
                   "Data:", ;                 // ::aMsg[ 20 ]
                   "P·gina:", ;               // ::aMsg[ 21 ]
                   "Hora:", ;                 // ::aMsg[ 22 ]
                   "(VisualizaÁ„o)", ;        // ::aMsg[ 23 ]
                   "Coluna", ;                // ::aMsg[ 24 ]
                   "¡rea VisÌvel", ;          // ::aMsg[ 25 ]
                   "Tamanho das Colunas", ;   // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() Tipos n„o condizentes com o tipo de Ìndice", ;
                   "Erro", ;                  // ::aMsg[ 28 ]
                   "O arquivo", ;             // ::aMsg[ 29 ]
                   "n„o existe", ;            // ::aMsg[ 30 ]
                   "Tamenho:", ;              // ::aMsg[ 31 ]
                   "Campo Memo", ;            // ::aMsg[ 32 ]
                   "Editando:", ;             // ::aMsg[ 33 ]
                   "&Ok", ;                   // ::aMsg[ 34 ]
                   "&Cancelar", ;             // ::aMsg[ 35 ]
                   "&Ajuda", ;                // ::aMsg[ 36 ]
                   "Deletar Registro ?", ;    // ::aMsg[ 37 ]
                   "Deletar Linha ?", ;       // ::aMsg[ 38 ]
                   "Confirme", ;              // ::aMsg[ 39 ]
                   "Registro em uso, ele n„o pode ser travado", ;  // ::aMsg[ 40 ]
                   "Pressione [Esc] para cancelar o modo de ediÁ„o", ; // ::aMsg[ 41 ]
                   "Chave", ;    // ::aMsg[ 42 ]
                   "Valor", ;    // ::aMsg[ 43 ]
                   "Copia", ;    // ::aMsg[ 44 ]
                   "Saida", ;    // ::aMsg[ 45 ]
                   "", ;    // ::aMsg[ 46 ] ( para uso futuro )
                   "", ;    // ::aMsg[ 47 ]
                   "", ;    // ::aMsg[ 48 ]
                   "", ;    // ::aMsg[ 49 ]
                   "" }     // ::aMsg[ 50 ]

   // some conjunctions and prepositions for TSBrowse:Proper() method
   // keep spaces and capitals
         aProper := { " Para ", ;  // ::aMsg[ 51 ]
                      " De ", ;    // ::aMsg[ 52 ]
                      " Em ", ;    // ::aMsg[ 53 ]
                      " E ", ;     // ::aMsg[ 54 ]
                      " Ou " }     // ::aMsg[ 55 ]

        case cLang == "RU" /*.OR. cLang == "RUWIN" .OR. cLang == "RU866" .OR. cLang == "RUKOI8"*/ // Russian
   /////////////////////////////////////////////////////////////
   // RUSSIAN
   ////////////////////////////////////////////////////////////
/*
   ISO Name...: Russian
   Translator.: Grigory Filatov <gfilatov@inbox.ru>
   Country....: Ukraine
   Date.......: February 21th, 2002
*/

         aMsg := { "ƒ‡", ;                    // ::aMsg[ 1 ]
                   "ÕÂÚ", ;                   // ::aMsg[ 2 ]
                   "«‡ÔËÒ¸ Á‡ÌˇÚ‡", ;         // ::aMsg[ 3 ]
                   "œÓ‰ÓÎÊËÚ¸ ÒÌÓ‚‡", ;      // ::aMsg[ 4 ]
                   "«‡ÔËÒ¸ ÌÂ ‰Ó·‡‚ÎÂÌ‡", ;   // ::aMsg[ 5 ]
                   "&ŒÚÏÂÌËÚ¸", ;             // ::aMsg[ 6 ]
                   "& ÓÔËÓ‚‡Ú¸ ÒÚÓÎ·Âˆ", ;   // ::aMsg[ 7 ]
                   "¬˚&ÂÁ‡Ú¸ ÒÚÓÎ·Âˆ", ;     // ::aMsg[ 8 ]
                   "&¬ÒÚ‡‚ËÚ¸ ÒÚÓÎ·Âˆ", ;     // ::aMsg[ 9 ]
                   "&”‰‡ÎËÚ¸ ÒÚÓÎ·Âˆ", ;      // ::aMsg[ 10 ]
                   "”‰‡ÎËÚ¸", ;               // ::aMsg[ 11 ]
                   " ÓÔËÓ‚‡Ú¸", ;            // ::aMsg[ 12 ]
                   "¬˚ÂÁ‡Ú¸", ;              // ::aMsg[ 13 ]
                   "ƒ‚Ë„‡Ú¸ &¬ÌËÁ", ;         // ::aMsg[ 14 ]
                   "ƒ‚Ë„‡Ú¸ ¬&Ô‡‚Ó", ;       // ::aMsg[ 15 ]
                   "ƒ‚Ë„‡Ú¸ ¬¬Â&ı", ;        // ::aMsg[ 16 ]
                   "ƒ‚Ë„‡Ú¸ ¬&ÎÂ‚Ó", ;        // ::aMsg[ 17 ]
                   "ƒ‚Ë„‡Ú¸ &—ÎÂ‰Û˛˘ËÈ", ;    // ::aMsg[ 18 ]
                   " Û&ÒÓ", ;               // ::aMsg[ 19 ]
                   "ƒ‡Ú‡:", ;                 // ::aMsg[ 20 ]
                   "—Ú‡ÌËˆ‡:", ;             // ::aMsg[ 21 ]
                   "¬ÂÏˇ:", ;                // ::aMsg[ 22 ]
                   "(œÂ‰‚‡ËÚÂÎ¸Ì˚È ÔÓÒÏÓÚ)", ; // ::aMsg[ 23 ]
                   " ÓÎÓÌÍ‡", ;               // ::aMsg[ 24 ]
                   "¬Ë‰ËÏ‡ˇ Ó·Î‡ÒÚ¸", ;       // ::aMsg[ 25 ]
                   "ÿËËÌ‡ ÍÓÎÓÌÓÍ", ;        // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() “ËÔ ÌÂ ÒÓÓÚ‚ÂÚÒÚ‚ÛÂÚ ÚËÔÛ ÚÂÍÛ˘Â„Ó ËÌ‰ÂÍÒÌÓ„Ó ÍÎ˛˜‡", ;
                   "Œ¯Ë·Í‡", ;                // ::aMsg[ 28 ]
                   "‘‡ÈÎ", ;                  // ::aMsg[ 29 ]
                   "ÌÂ ÒÛ˘ÂÒÚ‚ÛÂÚ", ;         // ::aMsg[ 30 ]
                   "ÿËËÌ‡:", ;               // ::aMsg[ 31 ]
                   "Memo œÓÎÂ", ;             // ::aMsg[ 32 ]
                   "–Â‰‡ÍÚËÓ‚‡ÌËÂ:", ;       // ::aMsg[ 33 ]
                   "&œËÌˇÚ¸", ;              // ::aMsg[ 34 ]
                   "&ŒÚÏÂÌËÚ¸", ;             // ::aMsg[ 35 ]
                   "&œÓÏÓ˘¸", ;               // ::aMsg[ 36 ]
                   "”‰‡ÎËÚ¸ Á‡ÔËÒ¸ ?", ;      // ::aMsg[ 37 ]
                   "”‰‡ÎËÚ¸ ˇ‰ ?", ;         // ::aMsg[ 38 ]
                   "œÓ‰Ú‚ÂÊ‰ÂÌËÂ", ;         // ::aMsg[ 39 ]
                   "«‡ÔËÒ¸ Á‡ÌˇÚ‡ Ë ÌÂ ÏÓÊÂÚ ·˚Ú¸ ·ÎÓÍËÓ‚‡Ì‡", ;  // ::aMsg[ 40 ]
                   "Õ‡ÊÏËÚÂ [Esc] ‰Îˇ ÓÚÏÂÌ˚ Â‰‡ÍÚËÓ‚‡ÌËˇ", ;    // ::aMsg[ 41 ]
                   " ÓÎÓÌÍ‡", ;               // ::aMsg[ 42 ]
                   "«Ì‡˜ÂÌËÂ", ;              // ::aMsg[ 43 ]
                   "œÂ˜‡Ú¸", ;                // ::aMsg[ 44 ]
                   "¬˚ıÓ‰", ;                 // ::aMsg[ 45 ]
                   "", ;    // ::aMsg[ 46 ] (future possible usage)
                   "", ;    // ::aMsg[ 47 ]
                   "", ;    // ::aMsg[ 48 ]
                   "", ;    // ::aMsg[ 49 ]
                   "" }     // ::aMsg[ 50 ]

   // some conjunctions and prepositions for TSBrowse:Proper() method
   // keep spaces and capitals
         aProper := { "   ", ;    // ::aMsg[ 51 ]
                      " ŒÚ ", ;   // ::aMsg[ 52 ]
                      " ¬ ", ;    // ::aMsg[ 53 ]
                      " » ", ;    // ::aMsg[ 54 ]
                      " »ÎË " }   // ::aMsg[ 55 ]

        case cLang == "UK" .OR. cLang == "UA" /*.OR. cLang == "UAWIN" .OR. cLang == "UA866"*/  // Ukrainian
   /////////////////////////////////////////////////////////////
   // UKRAINIAN
   ////////////////////////////////////////////////////////////
/*
   ISO Name...: Ukrainian
   Translator.: Volodymyr Chumachenko
   Country....: Ukraine
   Date.......: January 3th, 2006
*/

         aMsg := { "“‡Í", ;                   // ::aMsg[ 1 ]
                   "Õ≥", ;                    // ::aMsg[ 2 ]
                   "«‡ÔËÒ Á‡ÈÌˇÚËÈ", ;        // ::aMsg[ 3 ]
                   "œÓ‰Ó‚ÊËÚË ‰‡Î≥", ;       // ::aMsg[ 4 ]
                   "«‡ÔËÒ ÌÂ ‰Ó‰‡ÌÓ", ;       // ::aMsg[ 5 ]
                   "&—Í‡ÒÛ‚‡ÚË", ;            // ::aMsg[ 6 ]
                   "& ÓÔ≥˛‚‡ÚË ÍÓÎÓÌÍÛ", ;    // ::aMsg[ 7 ]
                   "¬Ë&≥Á‡ÚË ÍÓÎÓÌÍÛ", ;     // ::aMsg[ 8 ]
                   "&¬ÒÚ‡‚ËÚË ÍÓÎÓÌÍÛ", ;     // ::aMsg[ 9 ]
                   "¬Ë&‰‡ÎËÚË ÍÓÎÓÌÍÛ", ;     // ::aMsg[ 10 ]
                   "¬Ë‰‡ÎËÚË", ;              // ::aMsg[ 11 ]
                   " ÓÔ≥˛‚‡ÚË", ;             // ::aMsg[ 12 ]
                   "¬Ë≥Á‡ÚË", ;              // ::aMsg[ 13 ]
                   "«Ï≥ÒÚËÚË &ÌËÊ˜Â", ;       // ::aMsg[ 14 ]
                   "«Ï≥ÒÚËÚË &Ô‡‚ÓÛ˜", ;    // ::aMsg[ 15 ]
                   "«Ï≥ÒÚËÚË ‚Ë&˘Â", ;        // ::aMsg[ 16 ]
                   "«Ï≥ÒÚËÚË &Î≥‚ÓÛ˜", ;     // ::aMsg[ 17 ]
                   "«Ï≥ÒÚËÚË &Ì‡ÒÚÛÔÌËÈ", ;   // ::aMsg[ 18 ]
                   " Û&ÒÓ", ;               // ::aMsg[ 19 ]
                   "ƒ‡Ú‡:", ;                 // ::aMsg[ 20 ]
                   "—ÚÓ≥ÌÍ‡:", ;             // ::aMsg[ 21 ]
                   "◊‡Ò:", ;                  // ::aMsg[ 22 ]
                   "(œÓÔÂÂ‰Ì≥È ÔÂÂ„Îˇ‰)", ; // ::aMsg[ 23 ]
                   " ÓÎÓÌÍ‡", ;               // ::aMsg[ 24 ]
                   "¬Ë‰ËÏ‡ Ó·Î‡ÒÚ¸", ;        // ::aMsg[ 25 ]
                   "ÿËËÌ‡ ÍÓÎÓÌÓÍ", ;        // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() “ËÔ ÌÂ ‚≥‰ÔÓ‚≥‰‡∫ ÚËÔÛ ÔÓÚÓ˜ÌÓ„Ó ≥Ì‰ÂÍÒÌÓ„Ó ‚Ë‡ÁÛ", ;
                   "œÓÏËÎÍ‡", ;               // ::aMsg[ 28 ]
                   "‘‡ÈÎ", ;                  // ::aMsg[ 29 ]
                   "ÌÂ ≥ÒÌÛ∫", ;              // ::aMsg[ 30 ]
                   "ÿËËÌ‡:", ;               // ::aMsg[ 31 ]
                   "œÓÎÂ ÔËÏ≥ÚÓÍ", ;         // ::aMsg[ 32 ]
                   "–Â‰‡„Û‚‡ÌÌˇ:", ;          // ::aMsg[ 33 ]
                   "&√‡‡Á‰", ;               // ::aMsg[ 34 ]
                   "&¬≥‰ÏÓ‚‡", ;              // ::aMsg[ 35 ]
                   "&ƒÓÔÓÏÓ„‡", ;             // ::aMsg[ 36 ]
                   "¬Ë‰‡ÎËÚË Á‡ÔËÒ ?", ;      // ::aMsg[ 37 ]
                   "¬Ë‰‡ÎËÚË ˇ‰ÓÍ ?", ;      // ::aMsg[ 38 ]
                   "œ≥‰Ú‚Â‰ÊÂÌÌˇ", ;         // ::aMsg[ 39 ]
                   "«‡ÔËÒ Á‡ÈÌˇÚËÈ, ·ÎÓÍÛ‚‡ÌÌˇ ÌÂÏÓÊÎË‚Â", ;        // ::aMsg[ 40 ]
                   "Õ‡ÚËÒÌ≥Ú¸ [Esc] ‰Îˇ ÒÍ‡ÒÛ‚‡ÌÌˇ Â‰‡„Û‚‡ÌÌˇ", ;  // ::aMsg[ 41 ]
                   " ÓÎÓÌÍ‡", ;               // ::aMsg[ 42 ]
                   "«Ì‡˜ÂÌÌˇ", ;              // ::aMsg[ 43 ]
                   "ƒÛÍ", ;                  // ::aMsg[ 44 ]
                   "¬Ëıi‰", ;                 // ::aMsg[ 45 ]
                   "", ;    // ::aMsg[ 46 ] (future possible usage)
                   "", ;    // ::aMsg[ 47 ]
                   "", ;    // ::aMsg[ 48 ]
                   "", ;    // ::aMsg[ 49 ]
                   "" }     // ::aMsg[ 50 ]

   // ƒÂˇÍ≥ ÒÔÓÎÛ˜Ì≥ ÍÓÌÒÚÛÍˆ≥ø ‰Îˇ ÏÂÚÓ‰‡ TSBrowse:Proper()
   // Á·Â≥„‡˛Ú¸ ÔÓ·≥ÎË ≥ Ì‡ÔËÒ‡ÌÌˇ
         aProper := { " ƒÓ ", ;   // ::aMsg[ 51 ]
                      " ¬≥‰ ", ;  // ::aMsg[ 52 ]
                      " ¬ ", ;    // ::aMsg[ 53 ]
                      " ≤ ", ;    // ::aMsg[ 54 ]
                      " ¿·Ó " }   // ::aMsg[ 55 ]

        case cLang == "SK" /*.OR. cLang == "SKWIN"*/  // Slovak
   /////////////////////////////////////////////////////////////
   // SLOVAK
   ////////////////////////////////////////////////////////////
   /*
      ISO Name...: Slovak
      Update ....: Januar 28, 2012
      Update ....: Jaroslav Janik <Jaroslav.Janik@siemens.com>
      Date.......: December 25, 2011
      Translator.: Julius Bartal Gyula <gybartal@gmail.com>
      Country....: Slovakia
      Date.......: Februar 25, 2010
   */

         aMsg := { "¡no", ;                    // ::aMsg[ 1 ]
                   "Nie", ;                    // ::aMsg[ 2 ]
                   "Z·znam je pouûit˝", ;      // ::aMsg[ 3 ]
                   "Sk˙ste znovu", ;           // ::aMsg[ 4 ]
                   "Z·znam nepridan˝", ;       // ::aMsg[ 5 ]
                   "Sp‰ù", ;                   // ::aMsg[ 6 ]
                   "KopÌruj stÂpe&c", ;        // ::aMsg[ 7 ]
                   "Vys&trihn˙ù stÂpce", ;     // ::aMsg[ 8 ]
                   "Vloûit stÂ&pce", ;         // ::aMsg[ 9 ]
                   "Zmazaù stÂpce", ;          // ::aMsg[ 10 ]
                   "Zmazaù", ;                 // ::aMsg[ 11 ]
                   "KopÌrovaù", ;              // ::aMsg[ 12 ]
                   "Vystrihn˙ù", ;             // ::aMsg[ 13 ]
                   "PosuÚ &dole", ;            // ::aMsg[ 14 ]
                   "PosuÚ nap&ravo", ;         // ::aMsg[ 15 ]
                   "Pos&uÚ hore", ;            // ::aMsg[ 16 ]
                   "PosuÚ na&æavo", ;          // ::aMsg[ 17 ]
                   "PosuÚ &na Ôaæöie", ;       // ::aMsg[ 18 ]
                   "Ku&rzor", ;                // ::aMsg[ 19 ]
                   "D·tum:", ;                 // ::aMsg[ 20 ]
                   "Strana:", ;                // ::aMsg[ 21 ]
                   "»as:", ;                   // ::aMsg[ 22 ]
                   "(N·hæad)", ;               // ::aMsg[ 23 ]
                   "StÂpec", ;                 // ::aMsg[ 24 ]
                   "Viditeæn· oblasù", ;       // ::aMsg[ 25 ]
                   "äÌrka stÂpcov", ;          // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() Typy nezodpovedaj˙ s˙Ëasnemu index typu kl˙Ëa", ; //::aMsg[ 27 ]
                   "Chyba", ;                  // ::aMsg[ 28 ]
                   "S˙bor", ;                  // ::aMsg[ 29 ]
                   "neexistuje", ;             // ::aMsg[ 30 ]
                   "äÌrka:", ;                 // ::aMsg[ 31 ]
                   "Memo pole", ;              // ::aMsg[ 32 ]
                   "⁄prava:", ;                // ::aMsg[ 33 ]
                   "&Akceptovaù", ;            // ::aMsg[ 34 ]
                   "Storno", ;                 // ::aMsg[ 35 ]
                   "Pomoc", ;                  // ::aMsg[ 36 ]
                   "Vymazaù z·znam ?", ;       // ::aMsg[ 37 ]
                   "Vymazat riadok ?", ;       // ::aMsg[ 38 ]
                   "Potvrdenie", ;             // ::aMsg[ 39 ]
                   "Z·znam sa puûÌva, nie je moûnÈ uzamkn˙ù", ;    // ::aMsg[ 40 ]
                   "StlaËte [Esc] k preruöeniu ˙prav.", ;          // ::aMsg[ 41 ]
                   "Kl˙Ë", ;                   // ::aMsg[ 42 ]
                   "Premenn·", ;               // ::aMsg[ 43 ]
                   "TlaË", ;                   // ::aMsg[ 44 ]
                   "Koniec", ;                 // ::aMsg[ 45 ]
                   "", ;                       // ::aMsg[ 46 ] (future possible usage)
                   "", ;                       // ::aMsg[ 47 ]
                   "", ;                       // ::aMsg[ 48 ]
                   "", ;                       // ::aMsg[ 49 ]
                   "" }                        // ::aMsg[ 50 ]

         aProper := { " Do ", ;                // ::aMsg[ 51 ]
                      " Z ", ;                 // ::aMsg[ 52 ]
                      " V ", ;                 // ::aMsg[ 53 ]
                      " A ", ;                 // ::aMsg[ 54 ]
                      " Alebo " }              // ::aMsg[ 55 ]

        case cLang == "CS" /*.OR. cLang == "CSWIN"*/    // Chech
   /////////////////////////////////////////////////////////////
   // CZECH
   ////////////////////////////////////////////////////////////
   /*
      ISO Name...: Czech
      Update ....: Januar 28, 2012
      Update ....: Jaroslav Janik <Jaroslav.Janik@siemens.com>
      Date.......: December 25, 2011
      Translator.: Julius Bartal Gyula <gybartal@gmail.com>
      Country....: Slovakia
      Date.......: Februar 25, 2010
   */

         aMsg := { "Ano", ;                    // ::aMsg[ 1 ]
                   "Ne", ;                     // ::aMsg[ 2 ]
                   "Z·znam v uûÌv·nÌ", ;       // ::aMsg[ 3 ]
                   "Zkuste znovu", ;           // ::aMsg[ 4 ]
                   "Z·znam nep¯id·n", ;        // ::aMsg[ 5 ]
                   "ZpÏt", ;                   // ::aMsg[ 6 ]
                   "KopÌruj sloupe&c", ;       // ::aMsg[ 7 ]
                   "Vys&trihn˙ù sloupec", ;    // ::aMsg[ 8 ]
                   "Vloûit slou&pec", ;        // ::aMsg[ 9 ]
                   "Smazaù sloupec", ;         // ::aMsg[ 10 ]
                   "Smazat", ;                 // ::aMsg[ 11 ]
                   "KopÌrovat", ;              // ::aMsg[ 12 ]
                   "Vyst¯ihnout", ;            // ::aMsg[ 13 ]
                   "Posun &dol˘", ;            // ::aMsg[ 14 ]
                   "Posun vp&ravo", ;          // ::aMsg[ 15 ]
                   "Posun hore", ;             // ::aMsg[ 16 ]
                   "Posun v&levo", ;           // ::aMsg[ 17 ]
                   "Posun &na daæöÌ", ;        // ::aMsg[ 18 ]
                   "Ku&rzor", ;                // ::aMsg[ 19 ]
                   "Datum:", ;                 // ::aMsg[ 20 ]
                   "Strana:", ;                // ::aMsg[ 21 ]
                   "»as:", ;                   // ::aMsg[ 22 ]
                   "(N·hled)", ;               // ::aMsg[ 23 ]
                   "Sloupec", ;                // ::aMsg[ 24 ]
                   "Viditeæn· oblasù", ;       // ::aMsg[ 25 ]
                   "äÌrka sloupc˘ ", ;         // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() Typy neodpovÌdajÌ soucasnÈ index typ klÌce", ; //::aMsg[ 27 ]
                   "Chyba", ;                  // ::aMsg[ 28 ]
                   "Soubor", ;                 // ::aMsg[ 29 ]
                   "neexistuje", ;             // ::aMsg[ 30 ]
                   "äÌ¯ka:", ;                 // ::aMsg[ 31 ]
                   "Memo pole", ;              // ::aMsg[ 32 ]
                   "⁄prava:", ;                // ::aMsg[ 33 ]
                   "&Akceptovat", ;            // ::aMsg[ 34 ]
                   "Storno", ;                 // ::aMsg[ 35 ]
                   "Pomoc", ;                  // ::aMsg[ 36 ]
                   "Smazat z·znam ?", ;        // ::aMsg[ 37 ]
                   "Smazat riadok ?", ;        // ::aMsg[ 38 ]
                   "PotvrÔte", ;               // ::aMsg[ 39 ]
                   "Z·znam uûit˝, nenÌ moûnÈ uzamknouù", ; // ::aMsg[ 40 ]
                   "StisknÏte [Esc] k p¯eruöenÌ ˙prav", ;  // ::aMsg[ 41 ]
                   "KlÌË", ;                   // ::aMsg[ 42 ]
                   "Promenn·", ;               // ::aMsg[ 43 ]
                   "Tisk", ;                   // ::aMsg[ 44 ]
                   "Konec", ;                  // ::aMsg[ 45 ]
                   "", ;                       // ::aMsg[ 46 ] (future possible usage)
                   "", ;                       // ::aMsg[ 47 ]
                   "", ;                       // ::aMsg[ 48 ]
                   "", ;                       // ::aMsg[ 49 ]
                   "" }                        // ::aMsg[ 50 ]

         aProper := { " Do ", ;                // ::aMsg[ 51 ]
                      " Z ", ;                 // ::aMsg[ 52 ]
                      " V ", ;                 // ::aMsg[ 53 ]
                      " A ", ;                 // ::aMsg[ 54 ]
                      " Alebo " }              // ::aMsg[ 55 ]

        case cLang == "HU" /*.OR. cLang == "HUWIN"*/  // Hungarian
   /////////////////////////////////////////////////////////////
   // HUNGARIAN
   ////////////////////////////////////////////////////////////
   /*
      ISO Name...: Hungarian
      Update ....: Januar 28, 2012
      Translator.: Julius Bartal Gyula <gybartal@gmail.com>
      Country....: Slovakia
      Date.......: Februar 25, 2010
   */

         aMsg := { "Igen", ;                                // ::aMsg[ 1 ]
                   "Nem", ;                                 // ::aMsg[ 2 ]
                   "Rekord haszn·lva", ;                    // ::aMsg[ 3 ]
                   "PrÛb·lja ˙jra", ;                       // ::aMsg[ 4 ]
                   "A rekord nem lett hozz·adva", ;         // ::aMsg[ 5 ]
                   "Vissza", ;                              // ::aMsg[ 6 ]
                   "M·sold az oszlopot", ;                  // ::aMsg[ 7 ]
                   "Oszlop kiv·g·sa", ;                     // ::aMsg[ 8 ]
                   "Oszlop besz˙r·sa", ;                    // ::aMsg[ 9 ]
                   "Tˆrˆld az oszlopot", ;                  // ::aMsg[ 10 ]
                   "Tˆrˆld", ;                              // ::aMsg[ 11 ]
                   "M·sold", ;                              // ::aMsg[ 12 ]
                   "V·gd ki", ;                             // ::aMsg[ 13 ]
                   "Menj le", ;                             // ::aMsg[ 14 ]
                   "Menj jobbra", ;                         // ::aMsg[ 15 ]
                   "Menj fel", ;                            // ::aMsg[ 16 ]
                   "Menj balra", ;                          // ::aMsg[ 17 ]
                   "Menj kˆvetkezıre", ;                    // ::aMsg[ 18 ]
                   "Ku&rzor", ;                             // ::aMsg[ 19 ]
                   "D·tum:", ;                              // ::aMsg[ 20 ]
                   "Oldal:", ;                              // ::aMsg[ 21 ]
                   "Idı:", ;                                // ::aMsg[ 22 ]
                   "(ElınÈzet)", ;                          // ::aMsg[ 23 ]
                   "Oszlop", ;                              // ::aMsg[ 24 ]
                   "L·thatÛ ter¸let", ;                     // ::aMsg[ 25 ]
                   "Oszlopok szÈlessÈge", ;                 // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() A tÌpusok nem egyeznek az aktu·lis index kulcs tÌpussal", ; //::aMsg[ 27 ]
                   "Hiba", ;                                // ::aMsg[ 28 ]
                   "¡llom·ny", ;                            // ::aMsg[ 29 ]
                   "nem lÈtezik", ;                         // ::aMsg[ 30 ]
                   "szÈlessÈg:", ;                          // ::aMsg[ 31 ]
                   "Memo mezı", ;                           // ::aMsg[ 32 ]
                   "SzerkesztÈs:", ;                        // ::aMsg[ 33 ]
                   "Fogadd el", ;                           // ::aMsg[ 34 ]
                   "ElvetÈs", ;                             // ::aMsg[ 35 ]
                   "SegÌtsÈg", ;                            // ::aMsg[ 36 ]
                   "A rekord tˆrlÈse ?", ;                  // ::aMsg[ 37 ]
                   "A sor tˆrlÈse ?", ;                     // ::aMsg[ 38 ]
                   "Igazold", ;                             // ::aMsg[ 39 ]
                   "Haszn·lt rekord, nem z·rolhatÛ", ;      // ::aMsg[ 40 ]
                   "A szerkesztÈst az [Esc] gomb lenyom·s·val sz¸ntetheti meg", ; // ::aMsg[ 41 ]
                   "Kulcs", ;                               // ::aMsg[ 42 ]
                   "V·ltozÛ", ;                             // ::aMsg[ 43 ]
                   "Nyomtat", ;                             // ::aMsg[ 44 ]
                   "KilÈpÈs", ;                             // ::aMsg[ 45 ]
                   "", ;                                    // ::aMsg[ 46 ] (future possible usage)
                   "", ;                                    // ::aMsg[ 47 ]
                   "", ;                                    // ::aMsg[ 48 ]
                   "", ;                                    // ::aMsg[ 49 ]
                   "" }                                     // ::aMsg[ 50 ]

         aProper := { " Hoz ", ;                            // ::aMsg[ 51 ]
                      " BÛl ", ;                            // ::aMsg[ 52 ]
                      " Ban ", ;                            // ::aMsg[ 53 ]
                      " …s ", ;                             // ::aMsg[ 54 ]
                      " Vagy " }                            // ::aMsg[ 55 ]


   Case cLang == "HR" /*.OR. cLang == "HRWIN" .OR. cLang == "HR852"*/  // Croatian
   /////////////////////////////////////////////////////////////
   // CROATIAN
   ////////////////////////////////////////////////////////////
   /*
      ISO Name...: Croatian
      Translator.: Alen Uzelac <alen.uzelac@gmail.com>
      Country....: Croatia
      Date.......: March 15, 2010
   */

   aMsg := { "Da", ;                    // ::aMsg[ 1 ]
             "Ne", ;                    // ::aMsg[ 2 ]
             "Zapis se koristi", ;      // ::aMsg[ 3 ]
             "Pokuöati ponovo", ;       // ::aMsg[ 4 ]
             "Zapis nije dodan", ;      // ::aMsg[ 5 ]
             "Poniöti", ;               // ::aMsg[ 6 ]
             "Kopiraj kolonu", ;        // ::aMsg[ 7 ]
             "Izreûi kolonu", ;         // ::aMsg[ 8 ]
             "Zalijepi kolonu", ;       // ::aMsg[ 9 ]
             "Obriöi kolonu", ;         // ::aMsg[ 10 ]
             "Obriöi", ;                // ::aMsg[ 11 ]
             "Kopiraj", ;               // ::aMsg[ 12 ]
             "Izreûi", ;                // ::aMsg[ 13 ]
             "Pomak dolje", ;           // ::aMsg[ 14 ]
             "Pomak desno", ;           // ::aMsg[ 15 ]
             "Pomak gore", ;            // ::aMsg[ 16 ]
             "Pomak lijevo", ;          // ::aMsg[ 17 ]
             "Pomak iduÊi", ;           // ::aMsg[ 18 ]
             "Cu&rsor", ;               // ::aMsg[ 19 ]
             "Datum:", ;                // ::aMsg[ 20 ]
             "Stranica:", ;             // ::aMsg[ 21 ]
             "Vrijeme:", ;              // ::aMsg[ 22 ]
             "(Pregled)", ;             // ::aMsg[ 23 ]
             "Kolona", ;                // ::aMsg[ 24 ]
             "Vidljivo podruËje", ;     // ::aMsg[ 25 ]
             "äirina kolone", ;         // ::aMsg[ 26 ]
             "Tsbrowse SetFilter() Tipovi ne odgovaraju trenutnom tipu indeksa", ;
             "Greöka", ;                // ::aMsg[ 28 ]
             "Datoteka", ;              // ::aMsg[ 29 ]
             "ne postoji", ;            // ::aMsg[ 30 ]
             "äirina:", ;               // ::aMsg[ 31 ]
             "Memo polje", ;            // ::aMsg[ 32 ]
             "Unos:", ;                 // ::aMsg[ 33 ]
             "U redu", ;                // ::aMsg[ 34 ]
             "Odustani", ;              // ::aMsg[ 35 ]
             "PomoÊ", ;                 // ::aMsg[ 36 ]
             "Obrisati zapis ?", ;      // ::aMsg[ 37 ]
             "Obrisati red ?", ;        // ::aMsg[ 38 ]
             "Potvrda", ;               // ::aMsg[ 39 ]
             "Zapis se koristi i ne moûe biti zakljuËan", ;  // ::aMsg[ 40 ]
             "Pritisnite [Esc] za prekid unosa", ;           // ::aMsg[ 41 ]
             "", ;                      // ::aMsg[ 42 ] (future possible usage)
             "", ;                      // ::aMsg[ 43 ]
             "", ;                      // ::aMsg[ 44 ]
             "", ;                      // ::aMsg[ 45 ]
             "", ;                      // ::aMsg[ 46 ]
             "", ;                      // ::aMsg[ 47 ]
             "", ;                      // ::aMsg[ 48 ]
             "", ;                      // ::aMsg[ 49 ]
             "" }                       // ::aMsg[ 50 ]

   // some conjunctions and prepositions for TSBrowse:Proper() method
   // keep spaces and capitals
      aProper := { " Do ", ;            // ::aMsg[ 51 ]
                   " Od ", ;            // ::aMsg[ 52 ]
                   " D ", ;             // ::aMsg[ 53 ]
                   " I ", ;             // ::aMsg[ 54 ]
                   " Ili " }            // ::aMsg[ 55 ]

        case cLang == "ES" /*.OR. cLang == "ESWIN"*/  // Spanish
   /////////////////////////////////////////////////////////////
   // SPANISH
   ////////////////////////////////////////////////////////////
/*
   ISO Name...: Spanish
   Translator.: Manuel Mercado <mmercadog@prodigy.net.mx>
   Country....: Mexico
   Date.......: February 18th, 2002
*/

         aMsg := { "Si", ;                    // ::aMsg[ 1 ]
                   "No", ;                    // ::aMsg[ 2 ]
                   "Registro en Uso", ;       // ::aMsg[ 3 ]
                   "Trata Nuevamente", ;      // ::aMsg[ 4 ]
                   "Registro No Agregado", ; // ::aMsg[ 5 ]
                   "&Deshacer", ;             // ::aMsg[ 6 ]
                   "&Copiar Columna", ;       // ::aMsg[ 7 ]
                   "Cor&tar Columna", ;       // ::aMsg[ 8 ]
                   "&Pegar Columna", ;        // ::aMsg[ 9 ]
                   "&Eliminar Columna", ;     // ::aMsg[ 10 ]
                   "Eliminar", ;              // ::aMsg[ 11 ]
                   "Copiar", ;                // ::aMsg[ 12 ]
                   "Cortar", ;                // ::aMsg[ 13 ]
                   "Mover hacia &Abajo", ;    // ::aMsg[ 14 ]
                   "Mover a la &Derecha", ;   // ::aMsg[ 15 ]
                   "Mover hacia A&rriba", ;   // ::aMsg[ 16 ]
                   "Mover a la &Izquierda", ; // ::aMsg[ 17 ]
                   "Mover al &Siguiente", ;   // ::aMsg[ 18 ]
                   "Cu&rsor", ;               // ::aMsg[ 19 ]
                   "Fecha:", ;                // ::aMsg[ 20 ]
                   "Pagina:", ;               // ::aMsg[ 21 ]
                   "Hora:", ;                 // ::aMsg[ 22 ]
                   "(Previsualizaci¢n)", ;    // ::aMsg[ 23 ]
                   "Columna", ;               // ::aMsg[ 24 ]
                   "Area Visible", ;          // ::aMsg[ 25 ]
                   "Anchura de Columnas", ;   // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() Tipo de datos no caza con la clave de °ndice activo", ;
                   "Error", ;                  // ::aMsg[ 28 ]
                   "El fichero", ;             // ::aMsg[ 29 ]
                   "no existe", ;              // ::aMsg[ 30 ]
                   "Anchura:", ;               // ::aMsg[ 31 ]
                   "Campo Memo", ;             // ::aMsg[ 32 ]
                   "Editando:", ;              // ::aMsg[ 33 ]
                   "&Aceptar", ;               // ::aMsg[ 34 ]
                   "&Cancelar", ;              // ::aMsg[ 35 ]
                   "A&yuda", ;                 // ::aMsg[ 36 ]
                   "® Eliminar Registro ?", ;  // ::aMsg[ 37 ]
                   "® Eliminar Rengl¢n ?", ;   // ::aMsg[ 38 ]
                   "Confirmar", ;              // ::aMsg[ 39 ]
                   "Registro en uso, no puede ser bloqueado", ;  // ::aMsg[ 40 ]
                   "Presiona [Esc] para salir del modo de edici¢n", ; // ::aMsg[ 41 ]
                   "Clave", ;                  // ::aMsg[ 42 ]
                   "Valor", ;                  // ::aMsg[ 43 ]
                   "Imprimir", ;               // ::aMsg[ 44 ]
                   "Salir", ;                  // ::aMsg[ 45 ]
                   "", ;    // ::aMsg[ 46 ] (para un posible uso futuro)
                   "", ;    // ::aMsg[ 47 ]
                   "", ;    // ::aMsg[ 48 ]
                   "", ;    // ::aMsg[ 49 ]
                   "" }     // ::aMsg[ 50 ]

   // some conjunctions and prepositions for TSBrowse:Proper() method
   // keep spaces and capitals
         aProper := { " A ", ;    // ::aMsg[ 51 ]
                      " De ", ;   // ::aMsg[ 52 ]
                      " En ", ;   // ::aMsg[ 53 ]
                      " Y ", ;    // ::aMsg[ 54 ]
                      " O " }     // ::aMsg[ 55 ]

        case cLang == "FI"        // Finnish
   ///////////////////////////////////////////////////////////////////////
   // FINNISH
   ///////////////////////////////////////////////////////////////////////
/*
   ISO Name...: Finnish
   Translator.: Lars J W Holm <lasse@the-holms.org>
   Country....: Finland
   Date.......: May 3d, 2006
*/

         aMsg := { "Kyll‰", ;                 // ::aMsg[ 1 ]
                   "Ei", ;                    // ::aMsg[ 2 ]
                   "Tietue k‰ytˆss‰", ;       // ::aMsg[ 3 ]
                   "Yrit‰ uudestaan", ;       // ::aMsg[ 4 ]
                   "Tietue ei lis‰tty", ;     // ::aMsg[ 5 ]
                   "&Peruta", ;               // ::aMsg[ 6 ]
                   "&Kopioi sarake", ;        // ::aMsg[ 7 ]
                   "&Leikkaa sarake", ;       // ::aMsg[ 8 ]
                   "L&iit‰ sarake", ;         // ::aMsg[ 9 ]
                   "&Poista sarake", ;        // ::aMsg[ 10 ]
                   "Poista", ;                // ::aMsg[ 11 ]
                   "Kopioi", ;                // ::aMsg[ 12 ]
                   "Leikkaa", ;               // ::aMsg[ 13 ]
                   "&Alas", ;                 // ::aMsg[ 14 ]
                   "&Oikealle", ;             // ::aMsg[ 15 ]
                   "&Ylˆs", ;                 // ::aMsg[ 16 ]
                   "&Vasemmalle", ;           // ::aMsg[ 17 ]
                   "&Seuraava", ;             // ::aMsg[ 18 ]
                   "Ku&rsori", ;              // ::aMsg[ 19 ]
                   "Pvm.:", ;                 // ::aMsg[ 20 ]
                   "Sivu:", ;                 // ::aMsg[ 21 ]
                   "Aika:", ;                 // ::aMsg[ 22 ]
                   "(Esikatso)", ;            // ::aMsg[ 23 ]
                   "Sarake", ;                // ::aMsg[ 24 ]
                   "N‰kyv‰ alue", ;           // ::aMsg[ 25 ]
                   "Sarakeleveys", ;          // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() Tyyppi ei vastaa indeksiavaimen tyyppi‰", ;
                   "Virhe", ;                 // ::aMsg[ 28 ]
                   "Tiedosto", ;              // ::aMsg[ 29 ]
                   "ei olemassa", ;           // ::aMsg[ 30 ]
                   "Leveys:", ;               // ::aMsg[ 31 ]
                   "Memo Kentt‰", ;           // ::aMsg[ 32 ]
                   "Muokkaan:", ;             // ::aMsg[ 33 ]
                   "&Hyv‰ksy", ;              // ::aMsg[ 34 ]
                   "&Peruuta", ;              // ::aMsg[ 35 ]
                   "Apua", ;                  // ::aMsg[ 36 ]
                   "Poistatko tietueen ?", ;  // ::aMsg[ 37 ]
                   "Poistatko rivin ?", ;     // ::aMsg[ 38 ]
                   "Vahvista", ;              // ::aMsg[ 39 ]
                   "Tietue k‰ytˆss‰, ei voida lukita", ;  // ::aMsg[ 40 ]
                   "Paina [Esc] poistuaaksesi muokkaustilasta", ; // ::aMsg[ 41 ]
                   "", ;    // ::aMsg[ 42 ] (future possible usage)
                   "", ;    // ::aMsg[ 43 ]
                   "", ;    // ::aMsg[ 44 ]
                   "", ;    // ::aMsg[ 45 ]
                   "", ;    // ::aMsg[ 46 ]
                   "", ;    // ::aMsg[ 47 ]
                   "", ;    // ::aMsg[ 48 ]
                   "", ;    // ::aMsg[ 49 ]
                   "" }     // ::aMsg[ 50 ]

   // some conjunctions and prepositions for TSBrowse:Proper() method
   // keep spaces and capitals
         aProper := { " To ", ;    // ::aMsg[ 51 ]
                      " Of ", ;    // ::aMsg[ 52 ]
                      " In ", ;    // ::aMsg[ 53 ]
                      " And ", ;   // ::aMsg[ 54 ]
                      " Or " }     // ::aMsg[ 55 ]

        case cLang == "NL"        // Dutch
   /////////////////////////////////////////////////////////////
   // DUTCH
   ////////////////////////////////////////////////////////////
/*
   ISO Name...: Dutch
   Translator.: Douwe Bouma <haverkort.commsystems@planet.nl>
   Country....: Nederlands
   Date.......: February 18th, 2002
*/

         aMsg := { "Ja", ;                     // ::aMsg[ 1 ]
                   "Nee", ;                    // ::aMsg[ 2 ]
                   "Record in gebruik", ;      // ::aMsg[ 3 ]
                   "Probeer opnieuw", ;        // ::aMsg[ 4 ]
                   "Record niet toegevoegd", ; // ::aMsg[ 5 ]
                   "&Undo", ;                  // ::aMsg[ 6 ]
                   "&Kopieer Kolom", ;         // ::aMsg[ 7 ]
                   "Kn&ip Kolom", ;            // ::aMsg[ 8 ]
                   "&Plak Kolom", ;            // ::aMsg[ 9 ]
                   "&Verwijder Kolom", ;       // ::aMsg[ 10 ]
                   "Verwijder", ;              // ::aMsg[ 11 ]
                   "Kopieer", ;                // ::aMsg[ 12 ]
                   "Knip", ;                   // ::aMsg[ 13 ]
                   "Naar &Beneden", ;          // ::aMsg[ 14 ]
                   "Naar &Rechts", ;           // ::aMsg[ 15 ]
                   "Naar &Boven", ;            // ::aMsg[ 16 ]
                   "Naar &Links", ;            // ::aMsg[ 17 ]
                   "Naar &Volgende", ;         // ::aMsg[ 18 ]
                   "Cu&rsor", ;                // ::aMsg[ 19 ]
                   "Datum:", ;                 // ::aMsg[ 20 ]
                   "Pagina:", ;                // ::aMsg[ 21 ]
                   "Tijd:", ;                  // ::aMsg[ 22 ]
                   "(Voorbeeld)", ;            // ::aMsg[ 23 ]
                   "Kolom", ;                  // ::aMsg[ 24 ]
                   "Zichtbaar gebied", ;       // ::aMsg[ 25 ]
                   "Kolom breedte", ;          // ::aMsg[ 26 ]
                   "Tsbrowse SetFilter() Type komt niet overeen met de huidige index sleutel", ; //::aMsg[ 27 ]
                   "Fout", ;                   // ::aMsg[ 28 ]
                   "The file", ;               // ::aMsg[ 29 ]
                   "Bestaat niet", ;           // ::aMsg[ 30 ]
                   "Breedte:", ;               // ::aMsg[ 31 ]
                   "Memo veld", ;              // ::aMsg[ 32 ]
                   "Bewerken:", ;              // ::aMsg[ 33 ]
                   "&Accepteer", ;             // ::aMsg[ 34 ]
                   "&Annuleer", ;              // ::aMsg[ 35 ]
                   "&Help", ;                  // ::aMsg[ 36 ]
                   "Verwijder record ?", ;     // ::aMsg[ 37 ]
                   "Verwijder regel ?", ;      // ::aMsg[ 38 ]
                   "Bevestig", ;               // ::aMsg[ 39 ]
                   "Record is in gebruik, er kan geen lock verkregen worden", ;  // ::aMsg[ 40 ]
                   "Toets [Esc] om de bewerkings-mode te annuleren", ; // ::aMsg[ 41 ]
                   "Kolom", ;                  // ::aMsg[ 42 ]
                   "Waarde", ;                 // ::aMsg[ 43 ]
                   "Druk", ;                   // ::aMsg[ 44 ]
                   "Uitgang", ;                // ::aMsg[ 45 ]
                   "", ;    // ::aMsg[ 46 ] (future possible usage)
                   "", ;    // ::aMsg[ 47 ]
                   "", ;    // ::aMsg[ 48 ]
                   "", ;    // ::aMsg[ 49 ]
                   "" }     // ::aMsg[ 50 ]

         aProper := { " Aan ", ;    // ::aMsg[ 51 ]
                      " Van ", ;    // ::aMsg[ 52 ]
                      " In ", ;     // ::aMsg[ 53 ]
                      " En ", ;     // ::aMsg[ 54 ]
                      " Of " }      // ::aMsg[ 55 ]

endcase

#endif

AEval( aProper, { |e| AAdd( aMsg, e ) } )

Return aMsg
