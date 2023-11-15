/*
*   MICAH TOO
*   LAB 9: emit.c
*   program that emits MIPS code. It defines several helper functions to print out MIPS code for global variables, 
*strings, and functions, ifststements, while loops, expression statements,write, var, read, assign return and call
*It also includes a function to emit MIPS code for an abstract syntax tree (AST). 
*The main EMIT function calls the helper functions in order to generate the MIPS code for the entire program. 
*Additionally, there is a function to generate MIPS code for a specific command with an optional label and comment.
*
*GRADING THROUGH  FUNCTION CALL
*/
#include <string.h>
#include <stdlib.h>
#include "ast.h"
#include "emit.h"



int GLABEL=0;  /* Global Temp counter */
char *globalName;

char * create_label()
{    char hold[100];
     char *s;
     sprintf(hold,"_L%d",GLABEL++);
     s=strdup(hold);
     return (s);
}

//PRE: PTR to top of AST, and FILE  ptr to print to 
//POSt: prints MIPS based global variables into file
void EMIT_GLOBALS(ASTnode* p, FILE *fp)
{
    if(p ==NULL) return;
    if(p->type == A_VARDEC && p->symbol->level == 0)
    {
        
        fprintf(fp, "%s: .space %d  # global variable\n",p->name , p->symbol->mysize*WSIZE);
    }

    EMIT_GLOBALS(p->s1, fp);
    EMIT_GLOBALS(p->s2, fp);
    EMIT_GLOBALS(p->next, fp);
}

//PRE: PTR to top of AST and FILE ptr to print M_TOP_PAD
//POST: Adds  a labe into AST for use in written statement
//POST: prints MIPS based string into fill
void EMIT_STRINGS(ASTnode *p, FILE *fp)
{
    if (p == NULL) return;
    if (p->type == A_WRITE && p->name != NULL) //check type and name
    {//add labelto that the node    
        p->label = create_label();
        fprintf(fp,"%s: .asciiz %s\t\t\n", p->label, p->name );//print it
    }

    EMIT_STRINGS(p->s1, fp);
    EMIT_STRINGS(p->s2, fp);
    EMIT_STRINGS(p->next, fp);
     
}

//PRE:PTR to AST, PTR file
//POST: prints out the MIPS code into file, using helper functions

void EMIT(ASTnode *p, FILE* fp)
{
    if(p==NULL)     return;
    if (fp==NULL)   return;

    fprintf(fp, "MIPS CODE GENERATE by Compilers Class\n\n");//printing to a file
    fprintf(fp, ".data\n\n");//printing to a file

    EMIT_STRINGS(p,fp);
    fprintf(fp, ".align 2\n");//printing to file
    EMIT_GLOBALS(p,fp);
    fprintf(fp, ".text\n\n\n");//print to file
    fprintf(fp, ".globl main\n\n\n");//print to file
    EMIT_AST(p,fp);
}
//PRE: possible label command,correct
//POST: formatted output to the file
void emit(FILE *fp, char* label, char*command, char* comment)
{
    if (strcmp("", comment) == 0){//check if the comment is an empty string
         if(strcmp("", label) == 0)//checks if the label is an empty string
            fprintf(fp,"\t%s\t\t\n", command);//write cmd to file
            else
            fprintf(fp,"%s:\t%s\t\t\n", label,  command);//file label and cmd to file
        }       
        else{
            if(strcmp("",label) == 0)//chck if label is empty
            fprintf(fp, "\t%s\t\t# %s\n", command, comment);//write cmd and comment to file
            else{
                    fprintf(fp, "%s:\t%s\t\t# %s\n", label, command, comment);//write lbel, cmd and cmment to file
                    
            }
            
        }
        
}
//PRE: PTR to ASTnode A_FUNCTIONDEC
//POST: MIPS code to the file for the tree
void emit_function(ASTnode* p, FILE* fp)
{
    char s[100];
    globalName =p->name;//declare a global var

    sprintf(s,"%s", p->name);// getting the name of the fn 
    emit(fp, s, "", "function definition");

    //carving out the parameter to the formal from registers 
    emit(fp, "","move $a1, $sp", "Activation Record carve out copy SP");
    sprintf(s, "subi $a1 $a1 %d", p->symbol->offset*WSIZE);
    emit(fp, "",s,  "Activation Record carve out copy size of function");//display the MIPS of S +offset and size
    emit(fp, "","sw $ra , ($a1)", "Store Return address");//MIPS to store return address
    sprintf(s, "sw $sp %d($a1)", WSIZE);//det the old stack ptr
    emit(fp, "",s, "Store the old Stack pointer");//str stack ptr
    emit(fp, "","move $sp, $a1", "Make SP the current activation record");// SP == curr act rec
    fprintf(fp, "\n\n\n\n");

    //copy the parameter to the format from the registers $t0 
    EMIT_AST(p->s1, fp);
    //generate compound statement
    EMIT_AST(p->s2, fp);

    //create an implicit return depending on if its at main or not
    //restore RA and SP  befre return
    emit(fp, "", "lw $ra ($sp)", "restore old environment RA");
    sprintf(s, "lw $sp %d($sp)", WSIZE);
    emit(fp, "", s, "Return from function store SP");
    fprintf(fp, "\n");
    
      if(strcmp(p->name, "main")==0)//check if its main
      {//exit
        emit(fp, "","li $v0, 10", "Exit from Main we are done");//leaving main MIPS
        emit(fp, "", "syscall", "EXIT everything"); //exiting the whole prg
        emit(fp, "", "", "END OF FUNCTION");//end of fn
      }
      else
      {//jump back to caller
        emit(fp, "", "jr $ra", "Return to the caller");
      }
}
//PRE:ptr to expr family
//POST: MIPS code tht sets $a0 to value of expr
void emit_expr(ASTnode *p, FILE *fp)
{
    char s[100];
    //base cases

    switch (p->type){
        case A_NUM:
                    sprintf(s, "li $a0, %d", p->value);//getting the val of the A_NUM
                    emit(fp, "",s, "expression is a constant");//display the mips
                    return;
                    break;
        case A_VAR:
                    emit_var(p,fp);//helper fn
                    emit(fp, "", "lw $a0, ($a0)", "Expression is a VAR");//loading var in a0 to a0
                    return;
                    break;
        case A_CALL:
                    emit_call(p, fp);//call helper fn
                    sprintf(s, "\n\tjal %s\t", p->name);
                    emit(fp, "", s, "Call the function\n\n");
                    return;
                    break;           
        case A_EXPR:
               
                emit_expr(p->s1,fp); //emit p->s1
                sprintf(s, "sw $a0, %d($sp)", p->symbol->offset*WSIZE);//offset+ptr
                emit(fp, "", s, "expression store LHS temporarily");//stre LHS of exp temporarily
                emit_expr(p->s2, fp);//emit p->s2
                emit(fp, "", "move $a1, $a0", "#right hand side needs to be a1");//retrieving stored value into a1
                sprintf(s, "lw $a0, %d($sp)", p->symbol->offset*WSIZE);//offset+size
                emit(fp, "", s, "expression restore LHS from memory");//restoring LHS from storage
               
                switch(p->operator){
                    case A_PLUS://case for a + operator and its MIPS code
                                emit(fp, "","add $a0, $a0, $a1", "#EXPR ADD\n");
                                break;
                    case A_MINUS://case for - operator and its MIPS code
                                emit(fp, "","sub $a0, $a0, $a1", "#EXPR SUB\n");
                                break;
                    case A_MODULO://case for % operator and its MIPS code
                                emit(fp, "","div $a0 $a1", "#DIV remainder\n");
                                emit(fp, "","mfhi $a0", "DIV remainder\n");
			                    break;
                    case A_TIMES://case for * operator   and the MIPS code                              
                                emit(fp, "","mult $a0 $a1", "#EXPR MULT\n");
                                emit(fp, "","mflo $a0", "#EXPR MULT\n");
                                break; 
                    case A_DIVIDE:// case for / operator    and the MIPS code 
                                emit(fp, "","div $a0 $a1", "#EXPR DIVIDE\n");
                                emit(fp, "","mflo $a0", "EXPR DIVIDE\n");
                                break; 
                    case A_LE://case for <= operator    and the MIPS code 
                            emit(fp, "","add $a1 ,$a1, 1", "EXPR LE add one to do compare\n");
                            emit(fp, "","slt $a0, $a0, $a1", "EXPR LE\n");
                            break;
                    case A_LT://case for < operator                            
                            emit(fp, "","slt $a0, $a0, $a1", "#EXPR Lessthan\n");
                            break;
                    case A_GT://case for > operatr   and the MIPS code                           
                            emit(fp, "","slt $a0, $a1, $a0", "EXPR Greaterthan\n");
                            break;
                    case  A_GE://case for >=  and its MIPS code                           
                            emit(fp, "","add $a0 ,$a0, 1", "EXPR  ADD GE\n");
                            emit(fp, "","slt $a0, $a1, $a0", "EXPR Greaterthan\n");
                            break;
                    case A_NE://case for != operator and its MIPS code
                            emit(fp, "","", "EXPR NE\n");
                            break;
                    case A_E://case for == operator   and its MIPS code                          
                            emit(fp, "","slt $t2 ,$a0, $a1", "EXPR EQUAL\n");
                            emit(fp, "","slt $t3 ,$a1, $a0", "EXPR EQUAL\n");
                            emit(fp, "","nor $a0 ,$t2, $t3", "EXPR EQUAL\n");
                            emit(fp, "","andi $a0 , 1", "EXPR EQUAL\n");
                            break;
                    default:printf("unknown operator in A_EXPR\n");
                }//end switch
                

                break;//handled after switch
    default:printf("emit expr switch NEVER SHOULD BE HERE\n");
            printf("FIX FIX \n");
            exit(1);

    }
}
//PRE:PTR to A_WRITE
//POST: MIPS code to generate WRITE string or write a number
//depending  on our  argument
void emit_write(ASTnode *p, FILE *fp)
{
    char s[100];
    //if writing string
    if(p->name != NULL)
    {//load address of label to $a0 then call print string
        sprintf(s, "la $a0, %s", p->label);//load labl to reg a0
        emit(fp,"",s,"The string address");//emit the adddress
        emit(fp, "", "li $v0, 4","About to print a string");//load  address of string to a0
        emit(fp, "","syscall\t", "call write string");//call the write string
        fprintf(fp, "\n\n");
    }
    else{//write an expression
            emit_expr(p->s1, fp);//now $a0 has expr value
            emit(fp, "", "li $v0, 1", "About to print a number");//emit 
            emit(fp, "", "syscall\t", "call write number");//call write string
            fprintf(fp, "\n\n");
    }
}//end emit_write

//PRE: PTR to ASTnode or null
//POSt MIPS code into the file for the tree
void EMIT_AST(ASTnode *p, FILE * fp)
{
    if (p==NULL)    return;
    //switch  statement for the different types 
    switch(p->type)
    {
        case A_VARDEC: //no real action
                        EMIT_AST(p->next, fp);
                        break;
        case A_FUNCTIONDEC:        
                            emit_function(p, fp);//calling helper function
                            EMIT_AST(p->next,fp);//next connected
                            break;
        case A_COMPOUND://no action for S1 vardec already in stack size
                        EMIT_AST(p->s2,fp);
                        EMIT_AST(p->next,fp);//nnxt connected
                        break;
        case A_WRITE:    //deals with using hlper function
                    emit_write(p, fp);//calling helper function
                    EMIT_AST(p->next, fp);//next connected
                    break;           
        case A_READ:    //deals with using hlper function
                    emit_read(p, fp);//call help fn
                    EMIT_AST(p->next, fp);//nxt conn
                    break;
        
        case A_ASSIGNMENT://esing helper function
                            emit_assign(p,fp);//caling helper function
                            EMIT_AST(p->next, fp);
                            break; 
        case A_PARAM:
                    emit_param(p,fp);
                    EMIT_AST(p->next, fp);
                    break;
        case A_RETURN:
                        emit_return(p,fp);//call helper fn
                        EMIT_AST(p->next, fp);     //nxt conn
                        break;   
        case A_WHILE:
                    emit_while(p, fp);//call helper fn
                    EMIT_AST(p->next, fp);  //nxt conn
                    break;
        case A_IFELSE:
                    emit_if(p,fp);//call helper fn
                    EMIT_AST(p->next,fp);//nxt connected
                    break;
        
        default:    printf("EMIT_AST case %d not implemented\n", p->type);
        exit(1);
    }//close switch

}//end EMIT_AST
//PRE:PRT to a VAR
//POST: $ao has exact memory location of var 
void emit_var(ASTnode *p, FILE *fp){
    char s[100];
    //handles internal ofset of array
    if(p->s1 != NULL)
    {//its an array
        emit_expr(p->s1, fp);//index is now in register a0
        emit(fp, "", "move $a1, $a0","VAR copy index array in a1" );//emit expr and store in a1
        sprintf(s, "sll $a1 $a1 %d", LOG_WSIZE);//determine the no of times we have to shift
        emit(fp, "", s, "muliply the index by wordsize via SLL");//emit the no of times we shift
    }
        

    if(p->symbol->level ==0)//if global var
    {   //get the  direct address of global var
        sprintf(s, "la $a0, %s", p->name);
        emit(fp, "", s, "EMIT Var global variable");//emiting the global var
    }else
    {   //local var stack ptr plus offset
        sprintf(s, "1a $a0, %s", p->name);//local var name
        emit(fp, "", "move $a0 $sp", "VAR local make a copy of stack pointer");//store sp in a0
        sprintf(s, "addi $a0 $a0 %d", p->symbol->offset*WSIZE);//loc var  sp plus offset
        emit(fp, "", s, "VAR local stack pointer plus offset");//emit loc var sp + ofst
       
    //check if its a array or normal var
    if(p->s1 !=NULL)
    {   //array
        emit(fp,"", "add $a0 $a0 $a1","VAR array add internal offset" );    //add a1 to a0
    }//end if
        
    }//end ifelse
}
//end emit_var

//PRE: PTR t A_READ
//POST: MIPS code to read in a valu and place it in VAR or READ
void emit_read(ASTnode *p, FILE *fp){
    emit_var(p->s1, fp);        //$a0 is var location
    emit(fp, "", "li $v0, 5", "about to read in value"); //emit var read in val
    emit(fp, "", "syscall", " read in value $v0 now has the read in value");//emit to syst
    emit(fp, "", "sw $v0, ($a0)","store read in value to memory");//stre the val to mem
    fprintf(fp, "\n\n");
}//end emit_read

//PRE: PTR to A_ASSIGN
//POST: GENERATES MIps code for the assign stataement
void emit_assign(ASTnode *p, FILE *fp){
    char s[100];
    if(p==NULL) return;
    
    emit_expr(p->s2,fp);   //emit_exp RHS of the expr
    sprintf(s, "sw $a0 %d($sp)", p->symbol->offset*WSIZE);//store in reg 0
    emit(fp, "", s, "Assign store RHS temporarily");//emit the stored expr
    emit_var(p->s1, fp);//emit the LHS of the expr
    sprintf(s, "lw $a1 %d($sp)", p->symbol->offset*WSIZE);//calc the offset of LHS
    emit(fp, "", s, "Assign gets RHS temporarily");//retrieving stored value into a1
    emit(fp, "", "sw $a1 ($a0)", "Assign place RHS into memory");//store a1 into a0

}//end emit_assign

//PRE:
//POST:
void emit_return(ASTnode *p, FILE *fp){
    if(p == NULL)    return;
    if(strcmp(globalName, "main")== 0){//if its in the main function
        if(p->s1 == NULL)//$a0 will be 0
        {
            emit(fp, "", "li $a0, 0", "RETURN has no specified value set to 0"); //if no parameter then $a0 will be 0
        }else{//result of expression
            emit(fp,"", "lw $sp, 4($sp)", "Return from function store SP" );
            emit(fp, "", "jr $ra", "return to the caller");
        }
    }
    else{//if its not main function

        if(p->s1 == NULL)//p->s1 means that i am not returning an expression
        {
            //emit(fp, "", "jr $ra", "return to the caller");
            emit(fp, "", "li $a0, 0", "RETURN has no specified value set to 0");  //if no parameter then $a0 will be 0
        }else{//returning result of expression
                emit(fp, "", "jr $ra", "return to the caller");
        }

    }
    
}//end emit_return
//PRE:PTR to A_WHILE
//POST:emits the MIPS assembly code necessary to implement the while loop
void emit_while(ASTnode *p, FILE *fp){
    char s[100];
    char *label1;
    char *label2;
    //creating first label 
        label1 = create_label();
        //creating second label
        label2 = create_label();

        sprintf(s, "%s", label1);//creates label for the top target(start)
        emit(fp, s, "", "#WHILE TOP target\n");//emit the label
        emit_expr(p->s1,fp);//emit the s1 part of the expr
        sprintf(s, "beq $a0 $0 %s", label2);//label branching to the end of the loop
        emit(fp, "", s, "#WHILE branch out\n");///emit the label
        EMIT_AST(p->s2,fp);//emit the s2 part of the expr
        sprintf(s, "j %s", label1);//mips code for jumping back to start
        emit(fp, "", s, "#WHILE Jump back\n");//emit the label gnerted above
        sprintf(s, "%s", label2);//stre  in label2
        emit(fp,  s, "", "End of WHILE\n");//emit the label
}//end emit_while

//PRE: PTR to A_IFELSE
//POST: emits the MIPS assembly code necessary to implement the if statement 
void emit_if(ASTnode *p, FILE *fp){
    char s[100];
    //define two labels
    char *label1;
    char *label2;
    //create two labels
    label1 = create_label();
    label2 = create_label();
    
    
//emit the condition of if stmt
    emit_expr(p->s1,fp);
    sprintf(s, "beq $a0 $0 %s", label1);//label to branch to the else 
    emit(fp, "", s, "IF branch to else part\n");//emit label

    EMIT_AST(p->s2->s1,fp); //s2.s1 
    sprintf(s, "j %s", label2);//jump instrc mips
    emit(fp, "", s, "IF S1 end\n");//emit the label created

    sprintf(s, "%s", label1);//create label fror the else prtn
    emit(fp, s, "", "ELSE target\n");//emit the label created 
    emit(fp, "", "", "the negative  portion of IF if there is an else\n");
    emit(fp, "", "", "otherwise just these lines\n\n");

    EMIT_AST(p->s2->s2, fp);
    sprintf(s, "%s", label2);//create label for end of if
    emit(fp, s, "", "End of IF\n");//emit the label
    
}//end emit_if

//PRE:PTR to A_CALL
//POST: MIPS code toimplement A_CALL 
void emit_call(ASTnode *p, FILE *fp){
        char s[100];
        int count_args = 0;
        emit(fp, "", "", "Setting Up Function Call");
        emit(fp, "", "", "evaluate  Function Parameters");
        
        emit_args(p->s1, fp);
        emit(fp, "", "", "place  Parameters into T registers");
        //first arg prt
        ASTnode *arg = p->s1;
        
        int count =0;//var to count the arguments
        ASTnode *no_of_arg = arg;
        while(no_of_arg !=NULL){
            count++;
            no_of_arg = no_of_arg->next;
        }
        if (count >8){
                fprintf(stderr,"too many arguments we can only handle 8");
                exit(1);
            }

        while(arg !=NULL){
            sprintf(s, "lw $a0, %d($sp)", arg->symbol->offset*WSIZE);
            emit(fp, "", s, "pull out stored  Arg");
            sprintf(s,"move $t%d, $a0", count_args);
            emit(fp, "", s, "move arg in temp\n");
            count_args++;
            arg = arg->next;
        }
}//end  emit_call

//PRE: PTR to  arg
//POST MIPS to A _ARG
void emit_args(ASTnode * p, FILE *fp){
    char s[100];
    while(p!=NULL){
        if (p->my_data_type != SYM_FUNCTION){
        emit_expr(p->s1, fp);
        sprintf(s, "sw $a0, %d($sp)", p->symbol->offset*WSIZE);
        emit(fp, "", s, "Store call Arg temporarily");
        p =p->next;
        }  
        else{
        exit(1);
        }      //end if
    }//end while
    
}//end emit_call

//PRE: PTR to A_PARAM
//POST:MIPS to A_PARAM
void emit_param(ASTnode *p, FILE *fp)
{
    char s[100];
    int count = 0;
    if(p!=NULL){
    if(p->value ==0){//for an array 
         sprintf(s, "sw $t%d %d($sp)",count,  p->symbol->offset*WSIZE);
         emit(fp, "", s, "Parameter store start of function\n");
          
    }
    else{  
        sprintf(s, "sw $t%d %d($sp)",count,  p->symbol->offset*WSIZE);
        emit(fp, "", s, "Parameter store start of function ARRAY\n");
    } 
    
    count++;
    }//end if
    if (p->next ==NULL){
        count =0;
    }
}//end emit_params

