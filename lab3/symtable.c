/*
Micah Too
02/06/2023
C code  that implements the symbol table contains insert, modify, search and display functions

main data structure - linked lists are used to implement the symbol table 
fields - insert, delete, display, search

malloc - used to dynamically allocate memory during runtime
we use malloc to dynamically allocate memory for a new element that will be inserted into the linked list
*/
#include<stdio.h>
/* #include<conio.h> */
#include<malloc.h>
#include<string.h>
#include<stdlib.h>
#include "symbtab.h"//included header file 

/*pre condition - none
post condition - program will be executed and user can do operations
that insert, delete, display, delete search and modify an element
*/

void main(){

    //variable declarations 
    int op,y;
    char S[100];
    int addr;
    struct SymbTab *p;
    
    //this is a program driven by the menu
    do{ 
        printf("\n\tSYMBOL TABLE IMPLEMENTATION\n");
        printf("\n\t1.INSERT\n\t2.DISPLAY\n\t3.DELETE\n\t4.SEARCH\n\t6.END\n");
        printf("\n\tEnter your option : ");
        scanf("%d",&op);

    /*moved all the user interactions from the respective function to main (Insert, Search,Delete)*/
    switch(op){
        case 1:
            //user prompts
            printf("\n\tEnter the symbol : ");
            scanf("%s", S);
            printf("\n\tEnter the address : ");
            scanf("%d", &addr);
            Insert(S, addr);
            break;
        case 2:
            Display();
            break;
        case 3:
            //user prompts
            printf("\n\tEnter the symbol to be deleted : ");
            scanf("%s",S);
            Delete(S);
            break;
        case 4:
        //user prompts
            printf("\n\tEnter the symbol to be searched : ");
            scanf("%s",S);
            p=Search(S);
            printf("\n\tSearch Result:");

            if(p!=NULL)
                printf("\n\tThe symbol is present in the symbol table\n");
            else
                printf("\n\tThe symbol is not present in the symbol table\n");
            break;
        case 5:
            exit(0);
}//end switch
} while(op<5);//while loop runs until user enters 5

}  /* end of main */

/*a function to insert a new element into the symbol table
pre conditinon - pointer to character string
post condition - pointer to structure new symbol,exits when symbol already exists,
*/
struct SymbTab * Insert(char *symbol, int address){
    
    struct SymbTab *p;
    p=Search(symbol);

    //check if symbol already exists
    if(p!=NULL)
        printf("\n\tThe symbol exists already in the symbol table\n\tDuplicate can.t be inserted");
    else{//executed when symbol does not already exist
        struct SymbTab *p;
        p=malloc(sizeof(struct SymbTab));//creates and stores a new node and stores in malloc
        p->symbol = strdup(symbol);//makes a duplicate of the symbol
        p->addr = address;
        p->next=NULL;

        if(size==0){
            first=p;
            last=p;
        }
        else {
            last->next=p;
            last=p;
        }
        size++;
    }
    printf("\n\tSymbol inserted\n");
}//end insert

/*function to display all the elements in the symbol table
pre condition - atleast 1 element is in the symbol table
post condition - every element that is already in the table will be displayed
*/
void Display(){
    int i;
    struct SymbTab *p;
    p=first;
    printf("\n\tSYMBOL\t\tADDRESS\n");

    for(i=0;i<size;i++){
        printf("\t%s\t\t%d\n",p->symbol,p->addr);
        p=p->next;
    }//end for loop
}//end display function

/*function to search for an element in the symbol table
pre condition pointer to character string
post condition - pointer to matching structure or null
*/
struct SymbTab * Search(char *symbol){
    int i;
    struct SymbTab *p;
    p=first;
    /*loop to traverse the LL*/
    for(i=0;i<size;i++){
        if(strcmp(p->symbol,symbol)==0)
            return p;//returns pointer p when symbols match
        p=p->next;
    }//end for loop
    //executed when not a match
    return NULL;
}/*end searcch function*/

/*a function to delete and element in the symbol table 
pre condition - symbol table should have atleast 1 element to be deleted
post conditon - an element is deleted from the symbol table
*/
void Delete(char *symbol){
    int a;
    struct SymbTab *p,*q;//uses two pointers to traverse the LL
    p=first;
    p = Search(symbol);

    if(p==NULL)
        printf("\n\tSymbol not found\n");
    else{
        if(strcmp(first->symbol,symbol)==0)//deletes first node
            first=first->next;
        else if(strcmp(last->symbol,symbol)==0){//deletes last node
            q=p->next;
            /*this while loopfinds node before the last node when deleting last node
            pointers p,q are updated on each iteration
            */
            while(strcmp(q->symbol,symbol)!=0){
                p=p->next;
                q=q->next;
            }
            p->next=NULL;
            last=p;
        }
        else{
            q=p->next;
            /*finds node before the node to be deleted when in the middle of LL updates
             p,q in each iteration till node to delete is reached*/
            while(strcmp(q->symbol,symbol)!=0){
                p=p->next;
                q=q->next;
            }
            p->next=q->next;
        }
    size--;
    printf("\n\tAfter Deletion:\n");
    Display();
    }
}//end delete function

