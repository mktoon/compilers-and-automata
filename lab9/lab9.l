/*                 
This is a Lex routine that generates tokens from an input of characters.
these are then used by the parser to construct a syntax tree for a given language.
It scans through input and identifies the different tokens and assigns specific token types which are passed 
to a  parser and implemented separately
different reg expressions are defined to match input code and returns a corresponding token type
identifiers and numerical vals return T_ID and T_NUM
Micah Too
04/26/2023
LAB9 CS 370


*/
%{

int mydebug=0;
int linecount=1;

#include "ast.h"
#include "y.tab.h"

%}


%%

"int"           {return(T_INT);     }/*returns token when characters corresponding keywords are matched*/
"void"          {return(T_VOID);    }
"if"            { return(T_IF);     }   
"else"          { return(T_ELSE);   } 
"while"         { return(T_WHILE);  }
"return"        { return(T_RETURN); }
"read"          { return(T_READ);   }
"write"         { return(T_WRITE);  }
\".*\"          { yylval.string=strdup(yytext); return(T_STRING); }/*returns corresponding token when an identifier is matched */
"=="            { return(T_E);      } 
"!="            { return(T_NE);     } 
"<"             { return(T_LT);     } 
"<="            { return(T_LE);     } 
">"             { return(T_GT);     } 
">="            { return(T_GE);     } 
"+"             {return(T_PLUS);    }
"-"             {return(T_MINUS);   }
"*"             {return(T_MULTIPLE);    }
"/"             {return(T_DIVIDE);  }
"%"             {return(T_MODULO);  }

[a-zA-Z][a-zA-Z0-9_]*		{if(mydebug) fprintf(stderr,"ID found"); yylval.string=strdup(yytext); return(T_ID);}/*matches string*/
[0-9][0-9]*	{if (mydebug) fprintf(stderr,"Digit found\n");
            yylval.value=atoi((const char *)yytext); return(T_NUM);}/*matches digits*/
[ \t]	{}/*matches white spaces*/
[;=\*/%&|(),[\] {\}] 	{return (*yytext);}/*matches operators*/
\/\/.*   {}/*matches comments*/
\n     { linecount++;}/*matches newline*/
%%

/*called when end of input stream is reached. returns to 1 when no more tokens are generating*/
int yywrap(void)
{ return 1;}


