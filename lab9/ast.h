/*   Abstract syntax tree code
MICAH TOO
LAB7
04/14/23
 this header provides the necessary structures and functions to implement an AST for a programming language

 struct ASTnodetype- holds pointers to AST nodes that will represent the parsed code. 
                   - members -  the type of node, the operator (if the node represents an operation), 
                     the node's name (if it's a variable or function), the node's value (if it's a number), the data type of the node,
                     a pointer to a symbol table for the node, and pointers to child nodes (if any).

*/

#include<stdio.h>
#include<malloc.h>

#include "symtable.h"

#ifndef AST_H
#define AST_H
int mydebug;

/* define the enumerated types for the AST.  THis is used to tell us what 
sort of production rule we came across */

enum ASTtype {
   A_FUNCTIONDEC,
   A_VARDEC,
   A_WRITE,
   A_COMPOUND,
   A_EXPR,
   A_IFELSE,
   A_WHILE,
   A_BODY,
   A_VAR,
   A_ASSIGNMENT,
   A_NUM, 
   A_PARAM,
   A_ARG,
   A_EXPRSTMT,
   A_RETURN,
   A_CALL,
   A_READ
   
   
	   //missing
};

// Math Operators

enum AST_OPERATORS {
   A_PLUS,
   A_MINUS,
   A_TIMES,
   A_UMINUS,
   A_MODULO,
   A_DIVIDE,
   A_LE,
   A_LT,
   A_GT,
   A_GE,
   A_E,
   A_NE

	   //missing
};

enum AST_MY_DATA_TYPE {
   A_INTTYPE,
   A_VOIDTYPE

};

/* define a type AST node which will hold pointers to AST structs that will
   allow us to represent the parsed code 
*/

typedef struct ASTnodetype
{
     enum ASTtype type;
     enum AST_OPERATORS operator;
     char * name;
     char * label;
     int value;
     enum AST_MY_DATA_TYPE my_data_type;
     struct SymbTab * symbol;
     struct ASTnodetype *s1,*s2, *next ; /* used for holding IF and WHILE components -- not very descriptive */
     
} ASTnode;


/* uses malloc to create an ASTnode and passes back the heap address of the newley created node */
ASTnode *ASTCreateNode(enum ASTtype mytype);

void PT(int howmany);


/*  Print out the abstract syntax tree */
/*level - indentations */
void ASTprint(int level,ASTnode *p);

//checking the parameter
int check_params(ASTnode *actuals, ASTnode *formals);

#endif // of AST_H
