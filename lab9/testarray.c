// Simple program to test while loops and arrays


void main(void){
    int i;
    int A[20];

     i = 0 ;
    while (i< 19)
    {  A[i] = i + 1;
       i = i + 1;
    }
    A[19] = 0;

    write "The following should be 13\n";
    write A[A[A[10]]];
    write "\n";
    write "The following should be 3\n";
    write A[A[A[A[10 + 9]]]];
    write "\n";




}
