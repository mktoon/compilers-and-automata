/*                 Small LEX routine which returns two formal tokens (INTEGER and VARIABLE)
                   along with single string elements like '+'.
 
                   This LEX definition is the companion to the lab4.y YACC routine which
                   is a simple calculator

                    Micah Too
                    02/22/2023
                    LAB4 CS 370

*/
%{

int mydebug=0;
#include "y.tab.h"
%}


%%
"int"    {return(T_INT);}/*token that returns an T_INT when character has int keyword*/
[a-zA-Z][a-zA-Z0-9]*		{if (mydebug) fprintf(stderr,"Letter found\n"); 
                       yylval.string=strdup(yytext); return(VARIABLE);}
[0-9][0-9]*	{if (mydebug) fprintf(stderr,"Digit found\n"); 
                       yylval.value=atoi((const char *)yytext); return(INTEGER);} /*this converts entered string value and return an integer*/
[ \t]		{if (mydebug) fprintf(stderr,"Whitespace found\n");}
[;=\-+*/%&|()] 	{ if (mydebug) fprintf(stderr,"return a token %c\n",*yytext); /*added a semicolon for variable declaration*/
                       return (*yytext);}
\n 		{ if (mydebug) fprintf(stderr,"cariage return %c\n",*yytext); 
                       return (*yytext);}

%%

int yywrap(void)
{ return 1;}


