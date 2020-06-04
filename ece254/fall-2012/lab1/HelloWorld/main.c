#include <LPC17xx.h>
#include "GLCD.h"

int main() {
	SystemInit();
	GLCD_Init();
	GLCD_Clear(Yellow);
	GLCD_DisplayString(0, 0, 1, "Hello World!");
}
