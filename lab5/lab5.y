%{
 /* 
   This is a Yacc routine for a parser that specifies the syntax of a programming
   language. We define the grammar rules and token definitions.
   Every rule in specification is defined by non terminal symbol defined by a set of production rules
   each specification defines different declaration types (function declaration, variable declaration),
   defines statements and the different operators and symbols

   Micah Too
   02/28/2023
   LAB 22 CS 370

*/

/*code that's copied to generated parser*/
	/* begin specs */
#include <stdio.h>
#include <ctype.h>


int yylex();
extern int mydebug;
extern int linecount;

void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s on line %d\n", s, linecount);/*specifies what line the error is in*/
}


%}

/*  this is where the grammar starts */

%start Program 

/*semantic values used in grammar rules*/
%union {
      int value;
      char * string;

}

/*defining new tokens*/
%token T_INT
%token <string>T_ID
%token  T_VOID
%token <value> T_NUM
%token T_IF
%token T_ELSE
%token T_WHILE
%token T_RETURN
%token T_READ
%token T_WRITE
%token T_STRING
%token T_LE T_LT T_GT T_GE T_E T_NE
%token T_PLUS T_MINUS
%token T_MULTIPLE T_DIVIDE


%%	/* end specs, begin rules */

        /*program → declaration-list */
Program :    Declaration_list
        ;

        /*declaration-list → declaration { declaration } */
Declaration_list : Declaration
                 | Declaration Declaration_list
                 ;

        /*declaration →  var-declaration |  fun-declaration*/ 
Declaration: Var_Declaration
            |Fun_Declaration
            ;

        /*var-declaration → type-specifier   var-list ; */
Var_Declaration   : Type_Specifier Var_List ';'
                  ;

        /*var-list →    ID [ [ NUM ] ]+ { , ID [ [ NUM ] ]+  } */
Var_List  : T_ID    {fprintf(stderr,"Var_LIST with value %s\n",$1);}
          | T_ID '[' T_NUM ']'  {fprintf(stderr, "Var_LIST with value %s\n",$1);}
          | T_ID ',' Var_List   {fprintf(stderr, "Var_LISt with value %s\n",$1);}
          | T_ID '[' T_NUM ']' ',' Var_List {fprintf(stderr, "Var_LIST with value %s\n",$1);}
          ;

        /*type-specifier →  int | void */
Type_Specifier  : T_INT
                | T_VOID
                ;

        /*fun-declaration →type-specifier ID ( params ) compound-stmt */
Fun_Declaration : Type_Specifier T_ID '('Params')' Compound_Stmt {fprintf(stderr, "FuncDec with value %s\n",$2);}
                ;

        /*params →  void | param-list */
Params  : T_VOID
        | Params_List
        ;

        /*param-list → param { , param } */
Params_List     :Param
                |Param ',' Params_List   
                ;

        /*param → type-specifier ID [ [] ]+ */
Param   : Type_Specifier T_ID {fprintf(stderr, "Param with value %s\n",$2);}
        | Type_Specifier T_ID '[' ']' {fprintf(stderr, "Param with value  %s\n",$2);}
        ; 

        /*compound-stmt → {  local-declarations  statement-list  } */
Compound_Stmt   : '{' Local_Declaration Statement_List  '}'
                ; 
 
        /*local-declarations → { var-declaration } */
Local_Declaration   : /* empty */
                    | Var_Declaration Local_Declaration
                    ; 

        /*statement-list → { statement } */
Statement_List  : /* empty */
                | Statement Statement_List
                ; 

/*statement → expression-stmt | compound-stmt | selection-stmt | iteration-stmt | assignment-stmt | return-stmt | read-stmt | write-stmt */
Statement       : Expression_Stmt
                | Compound_Stmt
                | Selection_Stmt
                | Iteration_Stmt
                | Assignment_Stmt
                | Return_Stmt
                | Read_Stmt
                | Write_Stmt
                ; 

        /*expression-stmt → expression ; | ; */
Expression_Stmt     : Expression ';'
                    | ';'
                    ; 

        /*selection-stmt → if ( expression ) statement [ else statement ] + */
Selection_Stmt      : T_IF '(' Expression ')' Statement  
                    | T_IF '(' Expression ')' Statement T_ELSE Statement
                    ; 

        /*iteration-stmt → while ( expression ) statement */
Iteration_Stmt      : T_WHILE '(' Expression ')' Statement
                    ; 

        /*return-stmt → return [ expression ]+ ; */
Return_Stmt         : T_RETURN ';' 
                    | T_RETURN Expression ';'
                    ; 

        /*read-stmt → read var ; */
Read_Stmt           : T_READ Var ';'
                    ; 

        /*write-stmt →  write expression; | write string; */
Write_Stmt          : T_WRITE Expression ';'
                    | T_WRITE T_STRING ';'
                    ; 

        /*assignment-stmt →  var = simple-expression   ; */
Assignment_Stmt     : Var '=' Simple_Expression ';'
                    ; 

        /*var → ID  [ [ expression ]  ] + */
Var                 : T_ID {fprintf(stderr, "Var with value %s\n",$1);}
                    | T_ID '[' Expression ']' {fprintf(stderr, "Var with value %s\n",$1);}
                    ; 

        /*expression → simple-expression  */
Expression          : Simple_Expression
                    ; 

        /*simple-expression → additive-expression [ relop additive-expression ] +*/
Simple_Expression   : Addictive_Expression 
                    | Addictive_Expression Relop Addictive_Expression
                    ; 

        /*relop → <= | < | > | >= | == | != */
Relop   : T_LE 
        | T_LT 
        | T_GT
        | T_GE
        | T_E 
        | T_NE 
        ; 

        /*additive-expression → term { addop term } */
Addictive_Expression: Term
                    | Addictive_Expression Addop Term 
                    ; 

        /*addop → + | - */
Addop               : T_PLUS
                    | T_MINUS
                    ; 

        /*term → factor { multop  factor } */
Term                : Factor
                    | Term Multop Factor
                    ; 

        /*multop →  * | / */
Multop              : T_MULTIPLE
                    | T_DIVIDE
                    ; 

        /*factor → ( expression ) | NUM |  var | call  | - factor */
Factor  : '(' Expression ')' 
        | T_NUM
        | Var
        | Call
        | '-' Factor
        ; 
 
        /*call → ID ( args )*/
Call                : T_ID '(' Args ')' {fprintf(stderr, "CALL with value %s\n",$1);}
                    ; 

        /*args → arg-list | empty*/
Args                : Arg_List 
                    | /* empty */
                    ; 

        /*arg-list → expression { , expression } */
Arg_List            : Expression
                    | Expression ',' Arg_List
                    ; 

%%	/* end of rules, start of program */

int main()
{ yyparse();
}
