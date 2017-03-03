@call %~d0\miniguim\batch\buildapp.bat sqlite3_test -c -lrddsql -lsddsqlt3 -lhbsqlit3 -lsqlite3

@call %~d0\miniguim\batch\buildapp.bat metadata -c -lrddsql -lsddsqlt3 -lhbsqlit3 -lsqlite3

@call %~d0\miniguim\batch\buildapp.bat blob -c -lrddsql -lsddsqlt3 -lhbsqlit3 -lsqlite3
@call %~d0\miniguim\batch\buildapp.bat pack -c -lrddsql -lsddsqlt3 -lhbsqlit3 -lsqlite3
@call %~d0\miniguim\batch\buildapp.bat authorizer -c -lrddsql -lsddsqlt3 -lhbsqlit3 -lsqlite3
@call %~d0\miniguim\batch\buildapp.bat backup -c -lrddsql -lsddsqlt3 -lhbsqlit3 -lsqlite3
@call %~d0\miniguim\batch\buildapp.bat hooks -c -lrddsql -lsddsqlt3 -lhbsqlit3 -lsqlite3
