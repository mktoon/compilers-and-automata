# Micah Too
# 04/14/2023
# makefile for Lab7
all:	lab7

lab7:	lab7.l lab7.y symtable.c ast.c symtable.h ast.h
	lex lab7.l
	yacc -d lab7.y
	gcc y.tab.c lex.yy.c ast.c symtable.c  -o lab7

clean:
	rm -f lab7