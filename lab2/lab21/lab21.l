         /* simple lex program which removes comments from a source program
            The main key is that a variable "comment" is set when the start of a comment
            is seen and then unset when the ending set is seen.  It is possible to have
            two starts closed by on end.
            
            Micah Too
            lab 21  CS 370
            01/30/2023
         */
        int comment = 0;
        int debug=0;  /* prints out debug statements if desired */
        int newLine = 1; /*variable to count the new lines */

%%
"/*"	{
  	if (comment && debug) fprintf(stderr,
		" >>>>>>>>line %d: Possible Nested comment <<<<<<<<<<\n", newLine);/*enhancing error message to include line number*/
	comment = 1;
	}

"*/"	{
          if (!comment) printf("line %d: %s",newLine, yytext); /*print out if it is not in a comment */
  	  comment = 0;
	}
  
. { if (!comment) printf("%s", yytext);}

\n  {newLine++; if(comment == 0){ printf("\n");
} }  /*identifies and increments everytime new line is matched*/

      
%%

int yywrap(void)
{ return 1;
}

int main()
{
  yylex();
}

