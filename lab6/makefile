# Micah Too
# 03/28/2023
# makefile for Lab6
all:	lab6

lab6:	lab6.l lab6.y ast.c ast.h
	lex lab6.l
	yacc -d lab6.y
	gcc y.tab.c lex.yy.c ast.c -o lab6

clean:
	rm -f lab6