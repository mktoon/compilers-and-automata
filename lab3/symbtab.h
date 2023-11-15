/*
Micah Too
02/08/2023
Header file for symbtable.c
*/
#ifndef symbtab
#define symbtab
//global variable
int size = 0;

//function prototypes for functions that operate on symbols table
void Display();
void Delete(char *symbol);
struct SymbTab * Search(char *symbol);//changed from void search() to struct
struct SymbTab * Insert(char *symbol, int address);//changed from 

//Structure definition- represents an entry in the symbols table
struct SymbTab{
    //members
    char *symbol;
    int addr;
    struct SymbTab *next;
};  //end SymtTab structure

//prototype
struct SymbTab *first,*last;

#endif