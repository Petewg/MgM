Brief Description
-----------------

Toggle Breakpoint: 
- Sets or removes a Breakpoint at the code line the current cursor position.
- When found a Breakpoint stop the execution of the program.

Tracepoint: 
- stop the execution of the program when a variable or expresion changes value
- e.g. sets Tracepoint, TP var == 3, TP Eof(), etc.

Watchpoint:
- Allows monitoring the value of a variable or expression
- e.g. sets Watchpoint, WP var, WP Recno(), WP var > 12, etc.

Run Mode:
- Animate: runs line by line automatically with a delay that is specified in the setting tab
- Go: is very fast, runs the application in the same manner as it would in Animate mode with the difference that not send info to debugger until one finds a Breakpoint or Tracepoint
- ToCursor: runs application in the same manner as Go mode but until the code line the current cursor position
- NextRoutine: runs application in the same manner as Go mode but until start the next Function/Procedure
- Step: runs line by line manually
- Trace: runs the application in the same manner as it would in Step mode with the difference that Trace mode does not display the code for functions and procedures called by the current program nor does it trace codeblocks back to their definition