%{

/*
 *			**** CALC ****
 *
 * This routine will function like a desk calculator
 * There are 26 integer registers, named 'a' thru 'z'
 *
 */

/* This calculator depends on a LEX description which outputs either VARIABLE or INTEGER.
   The return type via yylval is integer 

   When we need to make yylval more complicated, we need to define a pointer type for yylval 
   and to instruct YACC to use a new type so that we can pass back better values
 
   The registers are based on 0, so we substract 'a' from each single letter we get.

   based on context, we have YACC do the correct memmory look up or the storage depending
   on position

   Micah Too
   02/22/2023
   LAB 22 CS 370

   problems  fix unary minus, fix parenthesis, add multiplication
   problems  make it so that verbose is on and off with an input argument instead of compiled in
*/


	/* begin specs */
#include <stdio.h>
#include <ctype.h>
#include "symbtab.h"


#define MAX 2

int regs[MAX];/*defining the maximum number of variables that can be entered*/
int count_reg = 0;/*variable to count the number of entries*/
int base;
extern int debugsw;

int yylex();
void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s\n", s);
}


%}
/*  defines the start symbol, what values come back from LEX and how the operators are associated  */

/*Allows lex to return integer or string*/
%union {
      int value;
      char * string;

}

/*defining tokens according to types specified inside union*/
%start P
%token T_INT
%token <value>INTEGER
%token  <string>VARIABLE
%type<value>expr

%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left UMINUS


%%	/* end specs, begin rules */

P	: DECLS list
	;

DECLS	:DECLS DECL 
		| /*empty*/
		;
DECL	:T_INT VARIABLE ';' '\n'{/*code that searches if a variable has laready been declared and if there is enough space for declaration of additional */
					if(Search($2) == 0 && count_reg<MAX){
						Insert($2,count_reg);
						count_reg++;
					}
					else if(count_reg >= MAX){
						fprintf(stderr, "Not enough space in register");
					}
					else{
						fprintf(stderr, "Variable %s already exists", $2);
					}
				}
		;


list	:	/* empty */
	|	list stat '\n'
	|	list error '\n'
			{ yyerrok; }
	;

stat	:	expr
			{ fprintf(stderr,"the answer is %d\n", $1); }
	|	VARIABLE '=' expr
			{ if(Search($1) == 0){
					fprintf(stderr,"the variable has not been declared\n");	
					}				
				regs[fetchAddr($1)] = $3; }
	;

expr	:	'(' expr ')'
			{ $$ = $2; }
	|	expr '-' expr
			{ $$ = $1 - $3; }
	|	expr '+' expr
			{ $$ = $1 + $3; }
	|	expr '/' expr
			{ $$ = $1 / $3; }
	|	expr '%' expr
			{ $$ = $1 % $3; }
	|	expr '*' expr
			{ $$ = $1 * $3; }
	|	expr '&' expr
			{ $$ = $1 & $3; }
	|	expr '|' expr
			{ $$ = $1 | $3; }
	|	'-' expr	%prec UMINUS
			{ $$ = -$2; }
	|	VARIABLE /*searches if variable has been declared in symbol table*/
			{if(Search($1) !=NULL){
				$$ = regs[fetchAddr($1)];
			}
			else{
				fprintf(stderr, "%sVariable not in the table\n",$1);
				$$=0;
			} }
	|	INTEGER {$$=$1; /*fprintf(stderr,"found an integer\n")*/;}
	;



%%	/* end of rules, start of program */

int main()
{ yyparse();
}
