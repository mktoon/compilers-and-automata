/*  emit.h
*   MICAH TOO
*   LAB 9
*   interface file for other entities to know abt available functons
*   provides connectivity to MIPS generating subroutines  
*   this header files contains the function definitions of the different helper functions for emit.c
  
*/

#ifndef EMIT_H
#define EMIT_H
#include "ast.h"

#define WSIZE 4
#define LOG_WSIZE 2
//function declarations
void EMIT(ASTnode *p, FILE *fp);
void EMIT_AST(ASTnode *p, FILE * fp);
void emit(FILE *fp, char* label, char*command, char* comment);
void emit_write(ASTnode *p, FILE *fp);
void emit_read(ASTnode *p, FILE *fp);
void emit_assign(ASTnode *p, FILE *fp);
void emit_param(ASTnode *p, FILE *fp);
void emit_expr(ASTnode *p, FILE *fp);
void emit_args(ASTnode * p, FILE * fp);
void emit_var(ASTnode *p, FILE *fp);
void emit_while(ASTnode *p, FILE *fp);
void emit_if(ASTnode *p, FILE *fp);
void emit_call(ASTnode *p, FILE *fp);
void emit_return(ASTnode *p, FILE *fp);
void emit_function(ASTnode *p, FILE *fp);
void EMIT_GLOBALS(ASTnode* p, FILE * fp);
void EMIT_STRINGS(ASTnode * p, FILE *fp);
void EMIT_FUNCTION(ASTnode *p, FILE *fp);
char * create_label();

#endif