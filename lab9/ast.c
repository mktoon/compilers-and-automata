/*   Abstract syntax tree code

    This code is used to define an AST node, 
    routine for printing out the AST
    defining an enumerated type so we can figure out what we need to
    do with this.  The ENUM is basically going to be every non-terminal
    and terminal in our language.

    The code contains different functions
    ASTCreatenode(): takes an AST type and returns a pointer to heap memory where a new node is created.

    ASTtypetostring(): takes an AST data type and returns a string that represents the name of that type

    ASTprint()-  contains switch cases for different types of AST nodes: A_VARDEC, A_PARAM, A_FUNCTIONDEC, A_COMPOUND, A_WRITE, and A_READ
    For each case, the function prints out relevant information for the corresponding node type.(data type, name, and value of the variable, level 
    and offset of the corresponding symbol table entry). 
    also prints out an indented output using AST order printing with indentation
    also recursively calls itself to print out child nodes of the current node until there are no more nodes to print

    Micah Too
    04/14/2023
    lab 7 ast.c file

*/

#include<stdio.h>
#include<malloc.h>
#include "ast.h" 


/* uses malloc to create an ASTnode and passes back the heap address of the newley created node */
//  PRE:  Ast Node Type
//  POST:   PTR To heap memory and ASTnode set and all other pointers set to NULL
ASTnode *ASTCreateNode(enum ASTtype mytype)

{
    ASTnode *p;
    if (mydebug) fprintf(stderr,"Creating AST Node \n");
    p=(ASTnode *)malloc(sizeof(ASTnode));
    p->type=mytype;
    p->s1=NULL;     //pointer to node s1
    p->s2=NULL;     //pointer to node s2
    p->next=NULL; // points to the next node in a tree
    p->value=0;
    return(p);
}

/*  Helper function to print tabbing */
//PRE:  Number of spaces desired
//POST:  Number of spaces printed on standard output

void PT(int howmany)
{
	 
     for(int i=1; i<=howmany; i++){
        printf(" ");
     }
}

//  PRE:  A declaration type
//  POST:  A character string that is the name of the type
//          Typically used in formatted printing
char * ASTtypeToString(enum AST_MY_DATA_TYPE mytype)
{
    //determines what is to be returned when a variable of type int and void is given
    if(mytype ==    A_INTTYPE){
        return "INT";
    }
    if(mytype == A_VOIDTYPE){
        return "VOID";
    }

}



/*  Print out the abstract syntax tree */
// PRE:   PRT to an ASTtree
// POST:  indented output using AST order printing with indentation

void ASTprint(int level,ASTnode *p)
{
   int i;
   if (p == NULL ) return;
   
       switch (p->type) {
        case A_VARDEC : //this is a case for variable declarations
                      PT(level); 
                      //this if else statement is used to determine if the variable declared is a regular var or an array
                      if(p->value >0){//p.value >0 means its an array
                        printf("Variable %s %s [%d]  level %d offset %d\n", ASTtypeToString(p->my_data_type), p->name, p->value,p->symbol->level, p->symbol ->offset);//prints out data type, name and val inside the sqre brackets
                      }else{//regular variable
                      printf("Variable %s %s level %d offset %d", ASTtypeToString(p->my_data_type), p->name, p->symbol->level, p->symbol->offset);//prints out var type, and name
                      printf("\n");
                      }//end if else
                      ASTprint(level, p->s1);//prints out node s1
                      ASTprint(level, p->next);//goes to next node in the tree
                     break;

        case A_PARAM://case for parameter definition inside function declarations
                    PT(level);
                    if(p->value == 0){//for regular parameter it int x, void y
                        printf("Parameter %s %s level %d offset %d\n", ASTtypeToString(p->my_data_type), p->name, p->symbol->level, p->symbol->offset);//prints out parameter type, and name
                    }
                    else{//array style parameter
                        printf("Parameter %s %s[] level %d offset %d \n", ASTtypeToString(p->my_data_type), p->name, p->symbol->level, p->symbol->offset);//prints out parameter type and name
                    }//end if else
                    ASTprint(level, p->next);//goes to next node in the tree
                    break;
        case A_FUNCTIONDEC : //case for function declaration 
                    PT(level);
                    printf("Function  %s %s level %d offset %d ",ASTtypeToString(p->my_data_type), p->name, p->symbol->level, p->symbol->offset);//prints out function type and name
                    printf("\n");
                    ASTprint(level + 1, p->s1);//parameters of the function
                    ASTprint(level + 1, p->s2);//compount statement of the function
                    ASTprint(level, p->next); // moves to next node
                    break;                                       
        case A_COMPOUND://case for compound statements
                    PT(level);
                    printf("Compound statement\n");
                    ASTprint(level + 1,p->s1);//local declarations
                    ASTprint(level + 1, p->s2);//statement list
                    ASTprint(level, p->next);//goes to next node
                    break;

        case A_WRITE://case for write strings
                    PT(level);
                    //if else statement to determine if it is an expression or a string 
                    if(p->name != NULL){//write a string
                        printf("Write String %s \n", p->name);//prints out the name of the string
                    }
                    else{// else its an expression
                        printf("Write expresssion\n");
                        ASTprint(level+1, p->s1);//prints out the expression
                        }//end if else
                    ASTprint(level, p->next);//prints the next node
                    break;
        case A_READ:    //case for a read statement inside the code
                    PT(level);
                    printf("READ STATEMENT\n");
                    ASTprint(level+1, p->s1);   // prints out the statement
                    ASTprint(level, p->next);   // prints out the next node
                    break;

        case A_NUM: //case for number values
                PT(level+1);
                printf("NUMBER value %d\n", p->value);//printing out the value of the number
                break;
        case A_EXPR:    // case for expressions
                PT(level);
                //this switch statement is used to determine what arithmentic operator is used
                switch(p->operator){
                    case A_PLUS://case for a + operator
                                printf("EXPRESSION operator PLUS\n");
                                break;
                    case A_MINUS://case for - operator
                                printf("EXPRESSION operator MINUS\n");
                                break;
                    case A_MODULO://case for % operator
                                printf("EXPRESSION operator %\n");
                                break;
                    case A_TIMES://case for * operator
                                printf("EXPRESSION operator TIMES\n");
                                break; 
                    case A_DIVIDE:// case for / operator
                                printf("EXPRESSION operator / \n");
                                break; 
                    case A_UMINUS://case for unary  minus
                                printf("EXPRESSION operator Unary-minus\n");
                                break;
                    case A_LE://case for <= operator
                            printf("EXPRESSION operator <= \n");
                            break;
                    case A_LT://case for < operator
                            printf("EXPRESSION operator < \n");
                            break;
                    case A_GT://case for > operatr
                            printf("EXPRESSION operator > \n");
                            break;
                    case  A_GE://case for >=
                            printf("EXPRESSION operator >= \n");
                            break;
                    case A_NE://case for != operator
                            printf("EXPRESSION operator !=\n");
                            break;
                    case A_E://case for == operator
                            printf("EXPRESSION operator ==\n");
                            break;
                    default:printf("unknown operator in A_EXPR in ASTprint\n");
                }//end switch0000000000000

                ASTprint(level+1, p->s1);//printd out node s1
                ASTprint(level+1, p->s2);//prints out node s2
                ASTprint(level, p->next);//print the next node

                break;
        case A_ASSIGNMENT://case for assigning ie x=3, x=c etc
                        PT(level);
                        printf("ASSIGNMENT STATEMENT\n");
                        ASTprint(level+1, p->s1); //prints out the node s1 part of the assignment ie in x=3. his prints out the x part
                        PT(level);
                        printf("is assigned\n");
                        ASTprint(level+1, p->s2);//prints out the second part of the assignment
                        ASTprint(level, p->next);//prints out the next node
                        break;
        
        case A_IFELSE://case for the if else statement
                    PT(level);
                    printf("IF STATEMENT\n");
                    PT(level+1);
                    printf("IF expression\n");
                    ASTprint(level+1, p->s1);//prints node s1  which is the expression part of the if(expr)stmt
                    ASTprint(level, p->s2);//prints out s2 which is the statement part of the if(expression)statement
                    ASTprint(level, p->next);//prints out the next node
                    break;
        case A_WHILE://case for the while loop
                    PT(level);
                    printf("WHILE STATEMENT\n");
                    printf("WHILE expression\n");
                    ASTprint(level+1, p->s1);//prints out the s1 part of the while(expr)stmt which it the expr part
                    printf("WHILE body\n");
                    ASTprint(level+1, p->s2);//prints out the stmt part of the while loop
                    ASTprint(level, p->next);//prints out next node
                    break;
        
        case A_BODY://case for the stmt(or the body of the if(expr)stmt else stmt)
                    PT(level);
                    //this loop determines if the stement is just an if ststement or an if..else.. 
                    if(p->s2 == NULL){//s2 node is empty for the if ststement
                        printf("IF Body\n");
                        ASTprint(level+1, p->s1);//prints the stmt part of the if(expr)stmt
                    }
                    else{//this is when the statement is an if...else...
                        printf("IF Body\n");
                        ASTprint(level+1, p->s1);//prints out the body 1 before the else
                        printf("ELSE body\n");
                        ASTprint(level+1, p->s2);//prints out the stmt  after the else
                    }//end if else                    
                    break;
        case A_VAR://case for variables
                  PT(level);
                  if(p->s1 != NULL){//s1 is null because it has no expression
                        printf("VARIABLE %s  level %d offset %d\n",p->name, p->symbol->level, p->symbol->offset );//prints name, level and offset of the array
                        PT(level+1);
                        printf("[\n");
                        ASTprint(level +1, p->s1);//prints the node s1 which is the expression in T_ID[EXPR]
                        PT(level+1);
                        printf("]\n");
                      }else{
                        printf("VARIABLE %s level %d  offset %d \n", p->name,p->symbol->level, p->symbol->offset);//prints the scalar name, level and offset
                      }
                  break;
        case A_ARG:
                PT(level);
                printf("CALL argument %s\n", p->s1);
                ASTprint(level+1, p->s1);       //prints the pointer to S1 
                ASTprint(level, p->next);       //prints the next thing in the argList node
                
                break;  
        case A_RETURN://case for the return stmt
                    PT(level) ;//
                    printf("Return Statement\n");
                    ASTprint(level+1, p->s1);   //prints the node s1 of expression statemnt whch can be null or an expression.
                    break;
        case A_EXPRSTMT:
                    PT(level) ;
                    printf("Expression STATEMENT\n");
                    ASTprint(level+1, p->s1);   //prints out the node s1 of the expression statement
                    ASTprint(level, p->next);   //prints the next node in the tree
                    break;
                
        case A_CALL:
                   PT(level);
                   printf("Expression STATEMENT\n");
                   PT(level);
                   printf("CALL STATEMENT ");
                   printf("function %s \n", p->name);   //prints the function name 
                   PT(level);
                   printf("(\n");
                   //printf("CALL argument %s", p->s1);
                    ASTprint(level+1, p->s1);
                   PT(level);
                   printf(")\n");
                   ASTprint(level, p->next);
                   break;
        
        
        default: printf("unknown AST Node type %d in ASTprint\n", p->type);
       }//end switch
}//end ASTprint


/*function to check whether two lists of function parameters have the same types or not*/
/*PRE: PTRS to actuals and formals
POST: 1 if they are not same and 0 if they are same*/
int check_params(ASTnode *actuals, ASTnode *formals){
    if(actuals == NULL && formals ==NULL) {
        return 1;
    }
    if(actuals == NULL || formals == NULL) {
        return 0;
    }
    if(actuals->my_data_type != formals -> my_data_type) {//compare data types
        return 0;
    }
    return check_params(actuals->next, formals->next);
       }//end check params


/* dummy main program so I can compile for syntax error independently   
main()
{
}
/* */
