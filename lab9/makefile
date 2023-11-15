# Micah Too
# 04/14/2023
# makefile for Lab9
all:	lab9

lab9:	lab9.l lab9.y symtable.c emit.c ast.c symtable.h ast.h emit.h
	lex lab9.l
	yacc -d lab9.y
	gcc y.tab.c lex.yy.c ast.c emit.c symtable.c  -o lab9

clean:
	rm -f lab9