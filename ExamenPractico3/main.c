#include <msp430.h> 

extern int concatenateString(char  *string1, char *string2, char *string);


//       char concatenateString2(char *, char*);
/**
 * main.c
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	char string1[] = "Primera frase y ";   //15
	char string2[] = "frase 2 !";     //14
	const int size = sizeof(string1) + sizeof(string2);
	char string[size];


	int completeString = 0;

	completeString = concatenateString(string1, string2, string);

	return 0;
}

