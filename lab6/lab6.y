%{
 /* 
   Micah Too
   03/28/2023
   LAB 6 CS 370 Cminus into LEX and YACC

   this routine takes Cminus+ EBNF  and translates it into LEX and YACC directives
   the code is a parser definition that defines syntax and the semantics of a given programmin language.
   it has a specification part and a rules part.  specification is used to define the different types of token used like T_INT, T_VOID,...
   it also specifies the type used like nodes 
   
   it has grammar rules that specifies the different data typees that can be used ie int, void, operators

   The code also uses grammar rules to specify how to construct different functions, variables, statements and expressions and defines the way they would 
   each appear. (basically the syntax of the different parts of the code) 
   We define the types of nodes in the AST that will be used in representing the program, 
   it specifies the type of node generated and its memeber


*/

/*code that's copied to generated parser*/
	/* begin specs */
#include <stdio.h>
#include <ctype.h>

#include "ast.h"/*allows access to .h*/

ASTnode *PROGRAM = NULL;/*points to the absract syntax tree*/

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
      ASTnode * node;                          /*structure that allows parsing pointers*/
      enum AST_MY_DATA_TYPE input_type;         /**/
      enum AST_OPERATORS operator;
}

/*defining new tokens*/
%token T_INT
%token <string>T_ID T_STRING
%token  T_VOID
%token <value> T_NUM
%token T_IF
%token T_ELSE
%token T_WHILE
%token T_RETURN
%token T_READ
%token T_WRITE
%token T_LE T_LT T_GT T_GE T_E T_NE
%token T_PLUS T_MINUS
%token T_MULTIPLE T_DIVIDE T_MODULO

%type <node> Declaration_list Declaration Var_Declaration Var_List/**/
%type <node> Fun_Declaration Params Compound_Stmt Local_Declaration Statement_List
%type <node> Statement Write_Stmt Read_Stmt Assignment_Stmt
%type <node> Expression Simple_Expression Additive_Expression Iteration_Stmt
%type <node> Term Factor Var Call 
%type <node> Selection_Stmt
%type <node> Param Params_List
%type <node> Arg_List Args Return_Stmt
%type <node> Expression_Stmt
%type <input_type> Type_Specifier
%type <operator> Addop Relop Multop '='


%%	/* end specs, begin rules */

        /*program → declaration-list */
Program :    Declaration_list { PROGRAM =$1;}
        ;

        /*generates a list of declaration nodes (Declaration or a sequence of Declaration_list) */
Declaration_list : Declaration {$$ =$1;}
                 | Declaration Declaration_list{
                    $$=$1;
                    $$->next=$2;
                 }
                 ;

        /*this rule genrates either var_declaration or Fun_Declaration  */ 
Declaration: Var_Declaration    {$$=$1;}
            |Fun_Declaration    {$$=$1;}
            ;

        /*var-declaration generates  type-specifier   var-list ; */
Var_Declaration   : Type_Specifier Var_List ';'{//add type to all elements in the list
                    /*populate the  s1 connected list with defined type through s1*/
                    ASTnode *p=$2;
                    while(p!=NULL){
                        p->my_data_type=$1;
                        p=p->s1;//advance p
                    }
                        $$=$2;
                    }
                  ;

        /*var-list →    ID [ [ NUM ] ]+ { , ID [ [ NUM ] ]+  } */
Var_List  : T_ID    {$$=ASTCreateNode(A_VARDEC);                        /*creating a node for a variable declaration                          */
                     $$->name=$1;                                       /*stores the name of the variable being declared*/
                    }
          | T_ID '[' T_NUM ']'  {$$ = ASTCreateNode(A_VARDEC);          /*creates a node for variable declaration int his case a array var    */
                                 $$->name =$1;                          /*stores the name of the variable being declared                       */
                                 $$->value =$3;                         /*this shows the value of the array size                              */
                                 }
          | T_ID ',' Var_List   {$$ = ASTCreateNode(A_VARDEC);          /*creates a node for declaring variables in a list format separated by a coma   */
                                 $$->name =$1;                          /*stores the name of the variables                                              */
                                 $$->s1 = $3;                           /*pointer to Var_List                                                           */
                                }
          | T_ID '[' T_NUM ']' ',' Var_List {
                                               $$ = ASTCreateNode(A_VARDEC);          /*creates a node for declaring array variables in alist format separate by a coma    */
                                               $$->name =$1;                          /*stores the name of the variable being declared                       */
                                               $$->value =$3;                         /*this shows the value of the array size                              */ 
                                               $$->s1 = $6;                           /*pointer to Var_List                                                 */
                                            }
          ;

        /*type-specifier →  int | void */
Type_Specifier  : T_INT {$$=A_INTTYPE;          }       /*specifies int type variables          */
                | T_VOID {$$=A_VOIDTYPE;        }       /*specifies void type variables         */
                ;

        /*fun-declaration →type-specifier ID ( params ) compound-stmt */
Fun_Declaration : Type_Specifier T_ID '('Params')' Compound_Stmt 
                {      $$ = ASTCreateNode(A_FUNCTIONDEC);       /*create a node for function declaration     */
                       $$->name =$2;                            /*store the name of the variable ie T_ID     */
                       $$->my_data_type =$1;                    /*store the data type of the function being declared    */
                       $$->s1 = $4;                             /*this shows the parameters of the function that is being declared */
                       $$->s2 = $6;                             /*block(compound statement) */

                 }
                ;

        /*params →  void | param-list */
Params  : T_VOID {$$ = NULL;            }       /*this is when the parameter sectio of the function is not available            */
        | Params_List   {$$ = $1;       }       /*this lists the paramaters given inside the function declaration               */      
        ;

        /*param-list → param { , param } */
Params_List     :Param {$$ = $1;        }               /*param_List == Param                                   */
                |Param ',' Params_List  {$$=$1;         /*first parameter in the list                           */
                                         $$->next = $3; /*moves to the next paramater in the parameter list     */                                        
                                         } 
                ;

        /*param → type-specifier ID [ [] ]+ */
Param   : Type_Specifier T_ID {$$ = ASTCreateNode(A_PARAM);             /*creates a node for parameters                                 */
                               $$->my_data_type = $1;                   /*stores the datat type of the paramater ie int, or void        */
                               $$->name =$2;                            /*stores the name of the paramater                              */
                               $$->value = 0;                           /*added the value to use inside the c fle to help determine if the parameter is an array or just a regular*/
                              }
        | Type_Specifier T_ID '[' ']' {$$ =ASTCreateNode(A_PARAM);      /*creates a node for paramters of array type    */
                                        $$->my_data_type = $1;          /*specifies the datat type of the parameter     */
                                        $$->name = $2;                  /*specifies the name of te paramater            */
                                        $$->value = 1;                  /*value 1 is for show that the paramater is an array type       */
                                      }
        ; 

        /*compound-stmt → {  local-declarations  statement-list  } */
Compound_Stmt   : '{' Local_Declaration Statement_List  '}' {
                        $$ = ASTCreateNode(A_COMPOUND);                 /*we create a node for compound statements       */
                        $$->s1 =$2;                                     /*pointer to local declaration          */
                        $$->s2 =$3;                                     /*pointer to a statement _list          */
                        }

                ; 
 
        /*local-declarations → { var-declaration } */
Local_Declaration   : /* empty */{$$ =NULL;} //empty otherwise we execute the vardec
                    | Var_Declaration Local_Declaration {
                                                         $$=$1;         /*Local_Declaration = Var_Declaration           */
                                                         $$->next =$2;  /*Local_Declaration = Local_Declaration*/
                                                        }
                    ; 

        /*statement-list → { statement } */
Statement_List  : /* empty */                   {$$ = NULL;}            /*when empty, the statement list is null        */
                | Statement Statement_List      {
                                                 $$ = $1;               /*shows that Statement_List is a just a statement       */
                                                 $$->next = $2;         /*else its a Statement_List     */
                                                }                       
                ; 

/*statement → expression-stmt | compound-stmt | selection-stmt | iteration-stmt | assignment-stmt | return-stmt | read-stmt | write-stmt */
Statement       : Expression_Stmt       {$$=$1;         }       /*these shows what a statement can be, either Expression_Stmt, or Compound_Stmt and the rest of the listed*/
                | Compound_Stmt         {$$=$1;         }
                | Selection_Stmt        {$$=$1;         }
                | Iteration_Stmt        {$$=$1;         }
                | Assignment_Stmt       {$$=$1;         }
                | Return_Stmt           {$$=$1;         }
                | Read_Stmt             {$$=$1;         }
                | Write_Stmt            {$$=$1;         }
                ; 

        /*expression-stmt → expression ; | ; */
Expression_Stmt     : Expression ';'{$$=$1;     }
                    | ';'{$$ = ASTCreateNode(A_EXPRSTMT);       /*create a node foe expr stmt   */   
                                     $$->s1 = NULL; }           /*expr stmt does not exist      */
                    ; 

        /*selection-stmt → if ( expression ) statement [ else statement ] + */
Selection_Stmt      : T_IF '(' Expression ')' Statement  
                                { $$ = ASTCreateNode(A_IFELSE);         /*if statement. s2.s2 =null because we do not have an else part         */
                                  $$->s1 = $3;                          /*pointer to the expression if(expression).....                         */
                                  $$->s2 = ASTCreateNode(A_BODY);       /*if(stmt) body.... create a node for the body of the if statement      */
                                  $$->s2->s1 = $5;                      /*points to the statement part- which is the body                       */
                                  $$->s2->s2 = NULL;                    /*null because there is no else part                                    */
                                }
                    | T_IF '(' Expression ')' Statement T_ELSE Statement
                                {$$ = ASTCreateNode(A_IFELSE);          /*creating a node for if()body else body                                */
                                 $$->s1 = $3;                           /*pointer to the expression if(expression)....                          */
                                 $$->s2 = ASTCreateNode(A_BODY);        /*if(stmt) body.... create a node for the body of the if statement      */
                                 $$->s2->s1 = $5;                       /*points to the statement part- which is the body                       */
                                 $$->s2->s2 = $7;                       /*points to else body node.s2.node.s2 (body)                            */
                                }
                    ; 

        /*iteration-stmt → while ( expression ) statement */
Iteration_Stmt      : T_WHILE '(' Expression ')' Statement{ 
                                  $$ = ASTCreateNode(A_WHILE);          /*we create a node for the while loop                   */
                                  $$->s1 = $3;                          /*pointer to the expression while(expression).....      */
                                  $$->s2 = $5;                          /*points to the statement part- which is the body       */
                                }
                    ; 

        /*return-stmt → return [ expression ]+ ; */
Return_Stmt         : T_RETURN ';' { 
                                     $$ = ASTCreateNode(A_RETURN);     //create a node A_RETURN  
                                     $$->s1 = NULL;                    //return statement is null
                                   }
                    | T_RETURN Expression ';'{ 
                                               $$ = ASTCreateNode(A_RETURN);    //create a node for A_RETURN     
                                               $$->s1 = $2;                     //node returns a expression ie return x; ....
                                        }
                    ; 

        /*read-stmt → read var ; */
Read_Stmt           : T_READ Var ';'{   
                                        $$ =ASTCreateNode(A_READ);      //create a node for reading ststements 
                                        $$->s1 =$2;                     //node returns variable of the read statement
                                     }
                    ; 

        /*write-stmt →  write expression; | write string; */
Write_Stmt          : T_WRITE Expression ';'    { 
                                                  $$ = ASTCreateNode(A_WRITE);  //create a node for writing a expression statement
                                                  $$ -> s1 = $2;                //s1 gives an expression
                                                }
                    | T_WRITE T_STRING ';'  {
                                             $$ = ASTCreateNode(A_WRITE);       //create a node for writing an string statement
                                             $$ -> name = $2;   //print out T_STRING if its a string 
                                             }    
                    ; 

        /*assignment-stmt →  var = simple-expression   ; */
Assignment_Stmt     : Var '=' Simple_Expression ';'     {
                                                        $$=ASTCreateNode(A_ASSIGNMENT);         //creating a node for assigning var to simple expr     
                                                        $$->s1 =$1;                             //s1  respresent the variable to assign
                                                        $$->s2 =$3;                             //s2 represnt the simple expression to be assigned to the variable
                                                        }
                    ; 

        /*var → ID  [ [ expression ]  ] + */
Var                 : T_ID {
                            $$=ASTCreateNode(A_VAR);            //creating a node for variables without expr
                            $$->name = $1;                        //name represent the T_ID 
                            $$->s1 =NULL;                         //s1 is null for this TID because it has no expr
                        }
                    | T_ID '[' Expression ']'{
                                              $$=ASTCreateNode(A_VAR);              //create a node for cars w expression
                                              $$->name = $1;                        //name reps the T_ID
                                              $$->s1 =$3;                           //s1 reps the expression part of the variable
                                        }
                    ; 

        /*expression → simple-expression  */
Expression          : Simple_Expression{$$=$1;  }               //exp = simple expression
                    ; 

        /*simple-expression → additive-expression [ relop additive-expression ] +*/
Simple_Expression   : Additive_Expression       {$$=$1;              }          //expr = Sim expr
                    | Additive_Expression Relop Additive_Expression   {
                                                                        $$=ASTCreateNode(A_EXPR);       //create a node for the simple expression
                                                                        $$->s1 =$1;                    //s1 represents a node that has additive expr
                                                                        $$->s2 =$3;                    //s2 reps a node that has the second Additive_Expression
                                                                        $$->operator =$2;              //operator represnts the relop
                                                                }
                    ; 

        /*relop → <= | < | > | >= | == | != */
Relop   : T_LE {$$ = A_LE;      }       //represnts <=
        | T_LT {$$ = A_LT;      }       //reps <
        | T_GT{$$ = A_GT;       }       //reps >
        | T_GE{$$ = A_GE;       }       //reps G=
        | T_E {$$ = A_E;        }       //reps ==
        | T_NE {$$ = A_NE;      }       //reps !=
        ; 

        /*additive-expression → term { addop term } */
Additive_Expression: Term {$$ =$1;     }
                    | Additive_Expression Addop Term { 
                                                       $$ = ASTCreateNode(A_EXPR);   //creates a node for additive express under A_EXPR
                                                       $$->s1 =$1;                   //node s1 reps the additive expr 
                                                       $$->s2 =$3;                   //node s2 respresents the Term part 
                                                       $$->operator =$2;             //reps the operator part which is addop
                                                }
                    ; 

        /*addop → + | - */
Addop               : T_PLUS {$$ =A_PLUS;  }    //reps expr +
                    | T_MINUS {$$=A_MINUS;  }   //reps expr -
                    ; 

        /*term → factor { multop  factor } */
Term                : Factor    {$$=$1;         }
                    | Term Multop Factor{
                                        $$ = ASTCreateNode(A_EXPR);     //creating a node for an expression
                                        $$->s1 =$1;                     //node s1 reps the term 
                                        $$->s2 =$3;                     //node s2 reps the factor       
                                        $$->operator =$2;               //operator reps the Multop
                                }
                    ; 

        /*multop →  * | / | % *///
Multop              : T_MULTIPLE        {$$ = A_TIMES;   }//added A_TIMES for *
                    | T_DIVIDE          {$$ = A_DIVIDE;    }//added the A_DIV for /
                    | T_MODULO          {$$ = A_MODULO;    }//added the modulo operator for %
                    ; 

        /*factor → ( expression ) | NUM |  var | call  | - factor */
Factor  : '(' Expression ')' {  $$ =$2;   }
        | T_NUM {  $$ = ASTCreateNode(A_NUM); //create a node A_NUM
                   $$ ->value = $1;      //leaf value from Lex A_VAR.s1.A_NUM
                }
        | Var           {$$ = $1;   }
        | Call          {$$ = $1;   }
        | T_MINUS Factor    {
                             $$ = ASTCreateNode(A_EXPR);//creating a A_UMINUS node
                             $$->s1 =$2;//storing a node factor
                             $$->operator = A_UMINUS;//operator for A_UMINUS
                             $$->s2=NULL;
                        }
        ; 
 
        /*call → ID ( args )*/
Call                : T_ID '(' Args ')' { 
                                          $$=ASTCreateNode(A_CALL);     //creating a 
                                          $$->name = $1;                //name of the argument
                                          $$->s1 = $3;                  // pointer represents arguments inside the brackets
                                        }
                    ; 

        /*args → arg-list | empty*/
Args                : Arg_List {$$ = $1;        }       // has argument in the list thus $1
                    | /* empty */ {$$ = NULL;   }       //no argument list thus NULL
                    ; 

        /*arg-list → expression { , expression } */
Arg_List            : Expression { 
                                   $$ = ASTCreateNode(A_ARG);          //creating a node for Arg_List  
                                   $$->s1 = $1;                        // node s1 reps the expr part of the arg_list
                                 }
                    | Expression ',' Arg_List { 
                                                $$ = ASTCreateNode(A_ARG);      //creating a superior list A_ARG for expression  
                                                $$->s1 = $1;                    //node s1 = expression
                                                $$->next = $3;                  //going to the next argument in the list
                                        }
                    ; 

%%	/* end of rules, start of program */

int main()
{ yyparse();
printf("\nFinished Parsing\n\n");
/*Global var prog has a ptr to top of tree*/
/*print out the tree'*/
ASTprint(0, PROGRAM);
}
