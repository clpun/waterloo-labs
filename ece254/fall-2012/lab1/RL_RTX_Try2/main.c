/**
 * @brief: A Simple RL-RTX application to blink a LED and
 * display 0-9 in a round robin fashion on LCD
 */

#include <LPC17xx.h>
#include <RTL.h>
#include "GLCD.h"
#include "LED.h"

int g_counter = 0; // a global counter

/**
 * @brief: displays 0-9 in a round robin fashion.
 */
__task void task1(void) {
	int i = 0;
	GLCD_DisplayString(3, 0, 1, "Task 1:");
	
	for (;;) {
	 	GLCD_DisplayChar(3, 7, 1, 1+'0');
		os_dly_wait(100);
		if (i++ == 9) {
		 	i = 0;
		}
	} 	
}

/**
 * @brief: toggles LED #7 at P2.6 every second
 */
__task void task2 (void){
	for(;;) {
		LED_on(7);
		os_dly_wait(60);
		LED_off(7);
		os_dly_wait(40); 	
	}
}

/**
 * @brief: A dummy task that keeps incrementing a counter 
 */
__task void task3 (void){
	for(;;){
		g_counter++;
	}
}

/**
 * @brief: Initialization task that spawns all other tasks.
 */
__task void init(void){
	os_tsk_create(task1, 1); // task1 at priority 1
	os_tsk_create(task2, 1); // task2 at priority 1
	os_tsk_create(task3, 1); // task3 at priority 1
	os_tsk_delete_self(); // delete itself
}

int main(){
	SystemInit(); // initialize the LPC17xx MCU
	LED_init(); // initialize the LED device
	GLCD_Init(); // initialize the LCD device

	LED_on(0); // turn on LED #0 at P1.28

	GLCD_Clear(Yellow);	// clear LCD screen with yellow color
	GLCD_DisplayString(0, 0, 1, "Hello World!");
						  // display a string at row 0 column 0 with
						  // font size 1
	os_sys_init(init); // initiate the first task in the RTOS
}
