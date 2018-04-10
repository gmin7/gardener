#include<stdlib.h>
#include<stdio.h>
#include<ctype.h>

extern int ROSE;
extern int MINT;
extern int PARSELY;
extern int UNKNOWN_PLANT;
extern int COUNTER;

void herb_select(){
	if((COUNTER)>0 && (COUNTER) < 3)
		DRAW_IMAGE(&ROSE);
	else if((COUNTER) >= 3 && (COUNTER) < 5)
		DRAW_IMAGE(&MINT);
	else if((COUNTER) >= 5)
		DRAW_IMAGE(&PARSELY);
	else 
		DRAW_IMAGE(&UNKNOWN_PLANT);

}
