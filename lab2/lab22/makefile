##lab2 CS 370
##Micah Too
##Jan 20, 2023
##simple word and number counting in Lex

all:	lab22	
lab22:	lab22.l lab22.y
	lex lab22.l  yacc -d lab22.y
	gcc y.tab.c -o lab22
clean:	rm -f lab22