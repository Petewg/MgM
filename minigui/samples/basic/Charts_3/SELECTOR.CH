/***
* Selector.ch
*
*/

#xcommand @ <array> SELECT [<clauses,...>] ;
          => <array> := {} ;
           ; @ <array> SELECT , [ <clauses> ]

#xcommand @ <array> SELECT ;
          [FROM <from>] ;
          [OTM <otm> SEEK <seek> EQUAL <equal>] ;
          [FOR <for>] ;
          [WHILE <while>] ;
          [<rest:REST>] ;
          [TO <(file)>] ;
          [ALIAS <alias>] ;
          [<add:ADDITIVE> [IF <condition>]] ;
          [SUMMARY <summary>] ;
          [EVAL <block>] ;
          => Selector(<array>, <(from)>, [ { <(otm)>, <{seek}>, <{equal}> } ], ;
                      <{for}>, <{while}>, <.rest.>, ;
                      <(file)>, <(alias)>, <.add.> [.and. <condition>], <summary>, ;
                      <{block}>)

// @ SELECT <field> ...
#xcommand @ <array> SELECT , <field> [<clauses,...>] ;
          => aAdd(<array>, { <{field}>, <"field">, , , 'X', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> ...
#xcommand @ <array> SELECT , <expr> AS <name> [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, , , 'X', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> LENGHT <lenght> DEC <dec> ...
#xcommand @ <array> SELECT , <expr> AS <name> LENGHT <lenght> DEC <dec> [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, <lenght>, <dec>, 'X', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <field> GROUP ...
#xcommand @ <array> SELECT , <field> GROUP [<clauses,...>] ;
          => aAdd(<array>, { <{field}>, <"field">, , , 'G', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> GROUP ...
#xcommand @ <array> SELECT , <expr> AS <name> GROUP [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, , , 'G', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> LENGHT <lenght> DEC <dec> GROUP ...
#xcommand @ <array> SELECT , <expr> AS <name> LENGHT <lenght> DEC <dec> GROUP [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, <lenght>, <dec>, 'G', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <field> TOTAL ...
#xcommand @ <array> SELECT , <field> TOTAL [<clauses,...>] ;
          => aAdd(<array>, { <{field}>, <"field">, , , 'T', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <field> AVERAGE ...
#xcommand @ <array> SELECT , <field> AVERAGE [<clauses,...>] ;
          => aAdd(<array>, { <{field}>, <"field">, , , 'A', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> TOTAL ...
#xcommand @ <array> SELECT , <expr> AS <name> TOTAL [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, , , 'T', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> AVERAGE ...
#xcommand @ <array> SELECT , <expr> AS <name> AVERAGE [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, , , 'A', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> LENGHT <lenght> DEC <dec> TOTAL ...
#xcommand @ <array> SELECT , <expr> AS <name> LENGHT <lenght> DEC <dec> TOTAL [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, <lenght>, <dec>, 'T', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> LENGHT <lenght> DEC <dec> AVERAGE ...
#xcommand @ <array> SELECT , <expr> AS <name> LENGHT <lenght> DEC <dec> AVERAGE [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, <lenght>, <dec>, 'A', .F. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <field> SUMMARY ...
#xcommand @ <array> SELECT , <field> SUMMARY [<clauses,...>] ;
          => aAdd(<array>, { <{field}>, <"field">, , , 'X', .T. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> SUMMARY ...
#xcommand @ <array> SELECT , <expr> AS <name> SUMMARY [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, , , 'X', .T. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> LENGHT <lenght> DEC <dec> SUMMARY ...
#xcommand @ <array> SELECT , <expr> AS <name> LENGHT <lenght> DEC <dec> SUMMARY [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, <lenght>, <dec>, 'X', .T. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <field> TOTAL SUMMARY ...
#xcommand @ <array> SELECT , <field> TOTAL SUMMARY [<clauses,...>] ;
          => aAdd(<array>, { <{field}>, <"field">, , , 'T', .T. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <field> AVERAGE SUMMARY ...
#xcommand @ <array> SELECT , <field> AVERAGE SUMMARY [<clauses,...>] ;
          => aAdd(<array>, { <{field}>, <"field">, , , 'A', .T. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> TOTAL SUMMARY ...
#xcommand @ <array> SELECT , <expr> AS <name> TOTAL SUMMARY [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, , , 'T', .T. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> AVERAGE SUMMARY ...
#xcommand @ <array> SELECT , <expr> AS <name> AVERAGE SUMMARY [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, , , 'A', .T. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> LENGHT <lenght> DEC <dec> TOTAL SUMMARY ...
#xcommand @ <array> SELECT , <expr> AS <name> LENGHT <lenght> DEC <dec> TOTAL SUMMARY [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, <lenght>, <dec>, 'T', .T. }) ;
           ; @ <array> SELECT [ <clauses> ]

// @ SELECT <expr> AS <name> LENGHT <lenght> DEC <dec> AVERAGE SUMMARY ...
#xcommand @ <array> SELECT , <expr> AS <name> LENGHT <lenght> DEC <dec> AVERAGE SUMMARY [<clauses,...>] ;
          => aAdd(<array>, { <{expr}>, <"name">, <lenght>, <dec>, 'A', .T. }) ;
           ; @ <array> SELECT [ <clauses> ]

#xcommand @ SELECT [<clauses,...>] ;
          => @ SelectList SELECT [ <clauses> ]