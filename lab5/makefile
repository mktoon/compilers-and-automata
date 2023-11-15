# Micah Too
# 02/28/2023
# makefile for Lab5
all:	lab5

lab5:	lab5.l lab5.y
	lex lab5.l
	yacc -d lab5.y
	gcc y.tab.c lex.yy.c -o lab5

clean:
	rm -f lab5