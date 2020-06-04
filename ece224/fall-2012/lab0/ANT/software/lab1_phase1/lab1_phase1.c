#include "lab1_phase1.h"

alt_u8 led_state = 0;
alt_u8 timer_0_flag = 0xf;
alt_u8 timer_1_flag = 0xf;
alt_u8 buttons;
alt_u8 led_switches;
alt_u8 hex_switches;
alt_u32 timerPeriod = TIMER_0_FREQ;
int led_count = 0;
int hex_count = 0;

static void timer_0_ISR(void* context, alt_u32 id)
{
	// acknowledge the interrupt by clearing the TO bit in the status register
	IOWR(TIMER_0_BASE, 0, 0x0);

	// set the flag with a non zero value
	timer_0_flag = 0xf;
	
	alt_u8 curr_switch;
	if (led_count < 8) {
		curr_switch = led_switches & 0x1;
		led_switches = led_switches >> 1;
		IOWR(LED_PIO_BASE, 0, curr_switch);
		led_count++;
	} else {
		led_count = 0;
		IOWR(LED_PIO_BASE, 0, 0);
		// turn off timer.
		IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, 0x8);
	}
}
static void timer_1_ISR(void* context, alt_u32 id)
{
	// acknowledge the interrupt by clearing the TO bit in the status register
	IOWR(TIMER_1_BASE, 0, 0x0);

	// set the flag with a non zero value
	timer_1_flag = 0xf;
	
	alt_u8 curr_switch;
	if (hex_count < 8) {
		curr_switch = hex_switches & 0x1;
		hex_switches = hex_switches >> 1;
		
		if (curr_switch == 1)
			IOWR(SEVEN_SEG_PIO_BASE, 0, 0xFF00);
		else 
			IOWR(SEVEN_SEG_PIO_BASE, 0, 0xFFFF);
			
		hex_count++;
	} else {
		hex_count = 0;
		IOWR(SEVEN_SEG_PIO_BASE, 0, 0xFFFF);
		// turn off timer.
		IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_1_BASE, 0x8);
	}
}

static void button_ISR(void* context, alt_u32 id)
{
	/* get value from edge capture register and mask off all bits except
	the 4 least significant */
	buttons = IORD_ALTERA_AVALON_PIO_EDGE_CAP(BUTTON_PIO_BASE) & 0xf;

	if (buttons == 1) {
		/* reset the edge capture register by writing to it (any value will do) */
		IOWR(BUTTON_PIO_BASE, 3, 0x0);
		led_count = 0;
		led_switches = IORD(SWITCH_PIO_BASE, 0);
		IOWR_ALTERA_AVALON_TIMER_PERIODL(TIMER_0_BASE, (alt_u16)timerPeriod);
		IOWR_ALTERA_AVALON_TIMER_PERIODH(TIMER_0_BASE, (alt_u16)(timerPeriod >> 16));
		IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, 0x7);
	} else if (buttons == 2){
		/* reset the edge capture register by writing to it (any value will do) */
		IOWR(BUTTON_PIO_BASE, 3, 0x0);
		hex_count = 0;
		hex_switches = IORD(SWITCH_PIO_BASE, 0);
		IOWR_ALTERA_AVALON_TIMER_PERIODL(TIMER_1_BASE, (alt_u16)timerPeriod);
		IOWR_ALTERA_AVALON_TIMER_PERIODH(TIMER_1_BASE, (alt_u16)(timerPeriod >> 16));
		IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_1_BASE, 0x7);
	}
}


int main () {
	/* Clear Everything */
	IOWR(LED_PIO_BASE, 0, 0);
	IOWR(SEVEN_SEG_PIO_BASE, 0, 0xFFFF);
	IOWR(SEVEN_SEG_MIDDLE_PIO_BASE,0,0xFFFF);
	IOWR(SEVEN_SEG_RIGHT_PIO_BASE,0,0xFFFFFFFF);

	/* reset the edge capture register by writing to it (any value will do) */
	IOWR(BUTTON_PIO_BASE, 3, 0x0);
	// Set up ISRs
	alt_irq_register( BUTTON_PIO_IRQ, (void*)0, button_ISR );

	/* enable interrupts for all four buttons*/
	IOWR(BUTTON_PIO_BASE, 2, 0xf);

	// initialize timer interrupt vector
	alt_irq_register(TIMER_0_IRQ, (void*)0, timer_0_ISR);

	// initialize timer period
	IOWR_ALTERA_AVALON_TIMER_PERIODL(TIMER_0_BASE, (alt_u16)timerPeriod);
	IOWR_ALTERA_AVALON_TIMER_PERIODH(TIMER_0_BASE, (alt_u16)(timerPeriod >> 16));

	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, 0x0);
	// clear timer interrupt bit in status register
	IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_0_BASE, 0x0);

	// initialize timer interrupt vector
	alt_irq_register(TIMER_1_IRQ, (void*)0, timer_1_ISR);

	// initialize timer period
	IOWR_ALTERA_AVALON_TIMER_PERIODL(TIMER_1_BASE, (alt_u16)timerPeriod);
	IOWR_ALTERA_AVALON_TIMER_PERIODH(TIMER_1_BASE, (alt_u16)(timerPeriod >> 16));

	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_1_BASE, 0x0);
	// clear timer interrupt bit in status register
	IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_1_BASE, 0x0);

	while (1){
	}
	return 0;
}

