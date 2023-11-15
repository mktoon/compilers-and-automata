%{
 /* 
 
   Micah Too
   05/5/2023
   LAB9 -- CMINUS+ add symbol table and type checking
   UPDATED MAIN TO TAKE ARGUMENTS
   Objective: ensuring that variables that are used in a program have been declared, 
   and are used within the correct levels and with the appropriate types. 
   Also ensuring that everytime a variable is defined, it is trored into a symbol table

  adding every defined variable to the symbol table 
  removing from symbol table  once we are no longer using it to free memory
  maintaining offset values 
        checklist:
        Increment level everytime we enter a compound statement
        delete a level evertym we exit a compound statement
        delete every  symbols defined at the level  and reset offset to release the memory


   Documentation for the already existing lab 6 code:

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
#include <string.h>
#include <stdlib.h>
#include "ast.h"/*allows access to ast.h*/
#include "symtable.h"/*allows access to symtable.h*/
#include "emit.h"

ASTnode *PROGRAM;/*points to the absract syntax tree*/

int yylex();
extern int mydebug;
extern int linecount;

int  LEVEL = 0;     //global context variable to know how deep we are
int OFFSET = 0;      //global value for accumulation needed at runtime
int GOFFSET = 0;      //global variable for accumulation global variable offset
int maxoffset = 0;    //the largest offset needed of the current function


void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("YACC PARSE ERROR: %s on line %d\n", s, linecount);/*specifies what line the error is in*/
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
                    while(p!=NULL)
                    {
                        p->my_data_type=$1;
                        

                    //check if variable in list to see if has been declared at the level
                        if(Search(p->name, LEVEL, 0) != NULL){
                            yyerror(p->name);
                            yyerror("Symbol already defined");
                            exit(1);
                        }//end if

                        //if not inserted into the symbol table, then insert
                        
                        if(p->value == 0){      //we have a scalar 
                            p->symbol =   Insert(p->name, p->my_data_type, SYM_SCALAR,  LEVEL, 1, OFFSET);

                            OFFSET = OFFSET + 1; //increment offset by the size that we just added
                        }
                        else{   //we have an array
                            p->symbol = Insert(p->name, p->my_data_type, SYM_ARRAY,  LEVEL, p->value, OFFSET);

                            OFFSET = OFFSET + p->value; //increment offset by p->value

                        }//end if

                        p=p->s1;                //advance p

                    }// end while

                       $$ = $2; 
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
Fun_Declaration : Type_Specifier T_ID 
                {       //check to see if function has been defined
                        if(Search($2, LEVEL,0)!= 0)
                                {//the ID has been used ERROR
                                        yyerror($2);
                                        yyerror("function name already in use");
                                        exit(1);
                                }

                                //insert into symbol table
                                Insert($2, $1, SYM_FUNCTION, LEVEL, 0,0);

                                GOFFSET = OFFSET;       //set global offset to offset
                                OFFSET = 2;             //set initial offset
                                maxoffset = OFFSET;     //set maxoffset as initial offset

                }
                '('Params')' 
                {
                        Search($2, LEVEL, 0) ->fparams = $5;

                } 
                Compound_Stmt
                        {       $$ = ASTCreateNode(A_FUNCTIONDEC);       /*create a node for function declaration     */
                                $$->name =$2;                            /*store the name of the variable ie T_ID     */
                                $$->my_data_type =$1;                    /*store the data type of the function being declared    */
                                $$->s1 = $5;                             /*this shows the parameters of the function that is being declared */
                                $$->s2 = $8;                             /*block(compound statement) */
                                $$->symbol = Search($2,LEVEL,0);
                                $$->symbol->offset = maxoffset;
                                
                                OFFSET = GOFFSET;                       //resets the offset for global variable 

                                
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
Param   : Type_Specifier T_ID {
                                if(Search($2, LEVEL+1, 0) !=NULL)
                                 {
                                        yyerror($2);
                                        yyerror("Paramater already used ");
                                        exit(1);
                                 }
                               $$ = ASTCreateNode(A_PARAM);             /*creates a node for parameters                                 */
                               $$->my_data_type = $1;                   /*stores the datat type of the paramater ie int, or void        */
                               $$->name =$2;                            /*stores the name of the paramater                              */
                               $$->value = 0;                           /*added the value to use inside the c fle to help determine if the parameter is an array or just a regular*/
                               
                               $$->symbol = Insert($$->name, $$->my_data_type, SYM_SCALAR, LEVEL+1,1, OFFSET); //set as symbol

                               OFFSET = OFFSET + 1; //increment offset
                              }
        | Type_Specifier T_ID '[' ']' {
                                        if(Search($2, LEVEL+1, 0) !=NULL)
                                         {//paramaters already used
                                                yyerror($2);
                                                yyerror("Paramater already used ");
                                                exit(1);
                                         }
                                        $$ =ASTCreateNode(A_PARAM);      /*creates a node for paramters of array type    */
                                        $$->my_data_type = $1;          /*specifies the datat type of the parameter     */
                                        $$->name = $2;                  /*specifies the name of te paramater            */
                                        $$->value = 1;                  /*value 1 is for show that the paramater is an array type       */

                                        $$->symbol = Insert($$->name, $$->my_data_type, SYM_ARRAY, LEVEL+1, 1, OFFSET); //set symbol as inserted 

                                       OFFSET  = OFFSET + 1; //increment offsett
                                      }
                                      

        /*compound-stmt → {  local-declarations  statement-list  } */
Compound_Stmt   : '{' { LEVEL++ ;}
                        Local_Declaration Statement_List  '}' 
                        { $$ = ASTCreateNode(A_COMPOUND);                 /*we create a node for compound statements       */
                          $$->s1 =$3;                                     /*pointer to local declaration          */
                          $$->s2 =$4;                                     /*pointer to a statement _list          */
                          if(mydebug)   Display();
                          
                          //we set the maxoffset
                          if (OFFSET > maxoffset) maxoffset = OFFSET;
                          OFFSET -= Delete(LEVEL);
                          LEVEL--; //decrement level when we exit a compound statemnt

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
Assignment_Stmt     : Var '=' Simple_Expression ';'     
                                        {
                                                if($1 ->my_data_type != $3->my_data_type)
                                                {//check for type mismatches.
                                                 yyerror("Type mismatch");
                                                 exit(1);
                                                }
                                                $$=ASTCreateNode(A_ASSIGNMENT);         //creating a node for assigning var to simple expr     
                                                $$->s1 =$1;                             //s1  respresent the variable to assign
                                                $$->s2 =$3;                             //s2 represnt the simple expression to be assigned to the variable

                                                $$->name = CreateTemp();
                                                $$->symbol = Insert($$->name, $3->my_data_type, SYM_SCALAR, LEVEL, 1, OFFSET); //store as as symbol
                                                $$->my_data_type = $3->my_data_type;        //set data type                                                   
                                                OFFSET = OFFSET + 1;                            // increment offset                     
                                        }
                    ; 

        /*var → ID  [ [ expression ]  ] + */
Var                 : T_ID {
                            struct SymbTab *p;
                            p = Search($1, LEVEL, 1);
                            if (p == NULL){
                                //ref var not in table
                                yyerror($1);
                                yyerror("symbol used but not defined");
                                exit(1);
                            }

                            if(p->SubType != SYM_SCALAR){//referenced var is not a scalar
                                yyerror($1);
                                yyerror("symbol used is not a SCALAR");
                                exit(1);
                            }

                            $$=ASTCreateNode(A_VAR);            //creating a node for variables without expr
                            $$->name = $1;                        //name represent the T_ID 
                            $$->s1 =NULL;                         //s1 is null for this TID because it has no expr
                            $$->symbol =p;
                            $$->my_data_type =p->Declared_Type;

                        }
                    | T_ID '[' Expression ']'
                                        {
                                                struct SymbTab *p;
                                                p = Search($1, LEVEL, 1);
                                                if (p == NULL){
                                                //ref var not in table
                                                yyerror($1);
                                                yyerror("symbol used but not defined");
                                                exit(1);
                                        }

                                        if(p->SubType != SYM_ARRAY)
                                        {//referenced var is not an array
                                                yyerror($1);
                                                yyerror("symbol used is not an ARRAY");
                                                exit(1);
                                        }
                                              $$=ASTCreateNode(A_VAR);              //create a node for cars w expression
                                              $$->name = $1;                        //name reps the T_ID
                                              $$->s1 =$3;                           //s1 reps the expression part of the variable
                                              $$->symbol =p;                            //set symbol as search result
                                              $$->my_data_type = p->Declared_Type;      //set to searched result
                                        }
                    ; 

        /*expression → simple-expression  */
Expression          : Simple_Expression{$$=$1;  }               //exp = simple expression
                    ; 

        /*simple-expression → additive-expression [ relop additive-expression ] +*/
Simple_Expression   : Additive_Expression       {$$=$1;              }          //expr = Sim expr
                    | Additive_Expression Relop Additive_Expression   {
                                                                        if($1 ->my_data_type != $3->my_data_type)
                                                                                {//check for type mismatches.
                                                                                        yyerror("Type mismatch");
                                                                                        exit(1);
                                                                                }
                                                                        $$=ASTCreateNode(A_EXPR);       //create a node for the simple expression
                                                                        $$->s1 =$1;                    //s1 represents a node that has additive expr
                                                                        $$->s2 =$3;                    //s2 reps a node that has the second Additive_Expression
                                                                        $$->operator =$2;              //operator represnts the relop

                                                                        $$->name = CreateTemp();                //create temp
                                                                        $$->symbol = Insert($$->name, $1->my_data_type, SYM_SCALAR, LEVEL, 1, OFFSET);          // set as symbol
                                                                        $$->my_data_type =$1->my_data_type;     //set data type                                                          
                                                                        OFFSET = OFFSET + 1;  //increment oofset

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
                                                        if($1 ->my_data_type != $3->my_data_type)
                                                        {//check for type mismatches.
                                                                yyerror("Type mismatch");
                                                                exit(1);
                                                        }
                                                       $$ = ASTCreateNode(A_EXPR);   //creates a node for additive express under A_EXPR
                                                       $$->s1 =$1;                   //node s1 reps the additive expr 
                                                       $$->s2 =$3;                   //node s2 respresents the Term part 
                                                       $$->operator =$2;             //reps the operator part which is addop

                                                       $$->name = CreateTemp();         //creates a temp
                                                       $$->symbol = Insert($$->name, $1->my_data_type, SYM_SCALAR, LEVEL, 1, OFFSET); //assigns symbol to inserted 
                                                       $$ ->my_data_type = $1->my_data_type;        // set data type to  the type of addtve_expr                                               
                                                       OFFSET = OFFSET + 1;             //increment offset
                                                
                                                }
                    ; 

        /*addop → + | - */
Addop               : T_PLUS {$$ =A_PLUS;  }    //reps expr +
                    | T_MINUS {$$=A_MINUS;  }   //reps expr -
                    ; 

        /*term → factor { multop  factor } */
Term                : Factor    {$$=$1;         }
                    | Term Multop Factor
                                {
                                         if($1 ->my_data_type != $3->my_data_type)
                                                {//check for type mismatches.
                                                        yyerror("Type mismatch");
                                                        exit(1);
                                                }
                                        $$ = ASTCreateNode(A_EXPR);     //creating a node for an expression
                                        $$->s1 =$1;                     //node s1 reps the term 
                                        $$->s2 =$3;                     //node s2 reps the factor       
                                        $$->operator =$2;               //operator reps the Multop

                                        $$->name = CreateTemp();
                                        $$->symbol = Insert($$->name, $1->my_data_type, SYM_SCALAR, LEVEL, 1, OFFSET); 
                                        $$ ->my_data_type = $1->my_data_type;                                                       
                                        OFFSET = OFFSET + 1;
                                }
                    ; 

        /*multop →  * | / | % *///
Multop              : T_MULTIPLE        {$$ = A_TIMES;   }//added A_TIMES for *
                    | T_DIVIDE          {$$ = A_DIVIDE;    }//added the A_DIV for /
                    | T_MODULO          {$$ = A_MODULO;    }//added the modulo operator for %
                    ; 

        /*factor → ( expression ) | NUM |  var | call  | - factor */
Factor  : '(' Expression ')' {  $$ =$2;   }
        | T_NUM {  
                   $$ = ASTCreateNode(A_NUM); //create a node A_NUM
                   $$ ->value = $1;      //leaf value from Lex A_VAR.s1.A_NUM
                   $$ ->my_data_type = A_INTTYPE;
                }
        | Var           {$$ = $1;   }
        | Call          {$$ = $1;   }
        | T_MINUS Factor    {
                             if($2->my_data_type != A_INTTYPE)
                             {//checking  if factor type is an int
                                yyerror("Type mismatch Unary minus");
                                exit(1);
                             }
                             $$ = ASTCreateNode(A_EXPR);        //creating a A_UMINUS node
                             $$->s1 =$2;//storing a node factor
                             $$->operator = A_UMINUS;   //operator for A_UMINUS
                             $$->s2=NULL;

                             $$->name = CreateTemp();
                             $$->my_data_type = A_INTTYPE;      //set data type to integer 
                             $$->symbol = Insert($$->name,$2->my_data_type, SYM_SCALAR, LEVEL, 1, OFFSET);      //set inserted  as symbol
                             OFFSET = OFFSET + 1;       //increment offset
                        }
        ; 
 
        /*call → ID ( args )*/
Call                : T_ID '(' Args ')' { 
                                          struct SymbTab *p;
                                          p = Search($1,0,0);

                                          if(p==NULL)
                                                {//function name not defined
                                                        yyerror($1);
                                                        yyerror("Function Name not defined");
                                                        exit(1);
                                                }
                                                //name has been defined check if its a function
                                                if(p->SubType != SYM_FUNCTION)
                                                        {
                                                                yyerror($1);
                                                                yyerror("is not defined as a function");
                                                                exit(1);
                                                        }
                                                //check if formal and actual parameters are same length and type
                                                if(check_params($3, p->fparams) == 0)
                                                        {
                                                                yyerror($1);
                                                                yyerror("Actuals and Formals do not match");
                                                                exit(1);
                                                        }

                                          $$=ASTCreateNode(A_CALL);     //creating a 
                                          $$-> name = $1;                //name of the argument
                                          $$-> s1 = $3;                  // pointer represents arguments inside the brackets
                                          $$-> symbol = p;              //assigned the search result to symbol
                                          $$->my_data_type =$$->symbol->Declared_Type;  //sets the data type for the search result
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
                                   $$->name = CreateTemp();
                                   $$->symbol = Insert($$->name, $1->my_data_type, SYM_SCALAR, LEVEL, 1, OFFSET);  //assign symbol to inserted  scalar
                                   $$ ->my_data_type = $1->my_data_type;      //set data type to data type of expresion                                                 
                                   OFFSET = OFFSET + 1;                 // increment offset
                                   
                                 }
                    | Expression ',' Arg_List { 
                                                if($1 ->my_data_type != $3->my_data_type)
                                                {//check for type mismatches.
                                                        yyerror("Type mismatch");
                                                        exit(1);
                                                }
                                                $$ = ASTCreateNode(A_ARG);      //creating a superior list A_ARG for expression  
                                                $$->s1 = $1;                    //node s1 = expression
                                                $$->next = $3;                  //going to the next argument in the list

                                                $$->name = CreateTemp();                //create temp
                                                $$->symbol = Insert($$->name, $1->my_data_type, SYM_SCALAR, LEVEL, 1, OFFSET);  
                                                $$ ->my_data_type = $1->my_data_type;        //set data type  to expression data type                                               
                                                OFFSET = OFFSET + 1; //increment offset
                                        }
                    ; 

%%	/* end of rules, start of program */

//updating main to take some argments
int main(int argc, char *argv[])//counter and pointer to list of strings
{ 
        FILE *fp;
        //read our input arguments
        int i;
        char s[100];
        //option -d turn on debug
        //option -o next argument is output fil name
        for(i=0; i<argc; i++)
        {
                if(strcmp(argv[i],"-d") == 0) mydebug =1;
                if(strcmp(argv[i], "-o") == 0)
                {       //we hve file input
                        strcpy(s, argv[i+1]);
                        strcat(s, ".asm");
                        //printf("File name is %s\n", s);
                }
                //printf("%s\n", argv[i]);
        }

        //opening the file referenced by s

        fp = fopen(s, "w");
        if(fp == NULL)
        {
                printf("can' open file %s\n", s);
                exit(1);
        }
        yyparse();
        if(mydebug)     printf("\nFinished Parsing\n\n");
        if(mydebug)     Display();  //shows our global variables function
        if(mydebug)     printf("\n\nAST PRINT \n\n");
        /*Global var prog has a ptr to top of tree*/
        /*print out the tree'*/
        if(mydebug)     ASTprint(0, PROGRAM);

        EMIT(PROGRAM, fp);
}
