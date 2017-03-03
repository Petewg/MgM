* Comandos SQL

* SELECT

#command SELECT <arg1> FROM <*arg2*> ;
=> ;
SqlResult := SqlDoQuery( nHandle , 'SELECT ' + <"arg1"> + ' FROM ' + <"arg2"> )

* DELETE

#command DELETE FROM <arg1> WHERE <*arg2*> ;
=> ;
SqlAffectedRows := SqlDoCommand( nHandle , 'DELETE FROM ' + <"arg1"> + ' WHERE ' + <"arg2"> )

* INSERT

#command INSERT INTO <arg1> SET <*arg2*> ;
=> ;
SqlAffectedRows := SqlDoCommand( nHandle , 'INSERT INTO ' + <"arg1"> + ' SET ' + <"arg2"> )

* UPDATE

#command UPDATE <arg1> SET <*arg2*> ;
=> ;
SqlAffectedRows := SqlDoCommand( nHandle , 'UPDATE ' + <"arg1"> + ' SET ' + <"arg2"> )

* LOCK

#command LOCK TABLES <*arg*> ;
=> ;
SqlDoCommand( nHandle , 'LOCK TABLES ' + <"arg"> )

* UNLOCK

#command UNLOCK TABLES ;
=> ;
SqlDoCommand( nHandle , 'UNLOCK TABLES')

* TRACE

#command SET SQLTRACE ON ;
=> ;
Public SqlTrace := .T.

#command SET SQLTRACE OFF ;
=> ;
Public SqlTrace := .F.


