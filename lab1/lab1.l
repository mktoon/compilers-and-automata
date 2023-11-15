 /*     Micah Too
        lab1
        1/20/2023
 
         This lex routine that counts the number of times a number occurs      
        */
   
	int lgths[100];
     /*intitializing count to 0 */
     int count[100];
     /*declare digits from 0 to 9 for matching*/

%%
[a-zA-Z]+ {lgths[yyleng]++;}
[0-9]+    {count[yyleng]++; }/*increments count everytime  0-9 is matched*/
.    |
\n   ;
%%
/*add and int to remove the defaults to int warning*/
int yywrap()
{
	int i;
	printf("Length  No. words\n");
	for (i=1; i<100; i++) {
		if (lgths[i] > 0) {
			printf("%5d%10d\n",i,lgths[i]);
          }
                   
	}
     /*printing the number of count*/
     for(i=1; i<100; i++){
          if(count[i] > 0){
            printf("Number count: %d %d\n", i, count[i]);   
          }
     }
	return(1);
}
/*add and int in the main to remove the second warning*/
int main()
{  
     yylex();  
}
