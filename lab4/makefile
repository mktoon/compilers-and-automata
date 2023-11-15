# Micah Too
# 02/08/2023
# makefile for symtable.c
all:	lab4
lab4:	lab4.l lab4.y symtable.c symbtab.h
	lex lab4.l
	yacc -d lab4.y
	gcc y.tab.c lex.yy.c symtable.c -o lab4
clean:
	rm -f lab4