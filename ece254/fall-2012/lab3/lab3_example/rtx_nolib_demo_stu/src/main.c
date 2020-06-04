/**
 * @brief: A simple RL-RTX application compiled with RTX source instead of 
 *         linking with the stocked RTX_CM3.LIB. 
 *         The printf is retargetd to UART so that the output appears 
 *         in UART #2 window inside simulator in debug mode
 * @author:Yiqing Huang 
 * @date:  2012/10/25 
 */

#include <LPC17xx.h>
#include "Serial.h"
#include "../INC/RTL.h"  /* modified RTL.h file. NOT the default one! */
#include <stdio.h>

/* The symbol is defined in the scatter file. Refer to RVCT Linker User Guide */
extern unsigned int Image$$RW_IRAM1$$ZI$$Limit;  

__task void task1(void);

/*--------------------------- task1 -----------------------------------*/
__task void task1(void)
{ 
  printf("I am in task 1\n");
  for(;;);
}

/*--------------------------- main -----------------------------------*/
int main()
{
	unsigned int *p_sp = (unsigned int *) (0x0);
  unsigned int free_mem = (unsigned int) &Image$$RW_IRAM1$$ZI$$Limit;
	 
  SystemInit();
	
  /* 
     initialize the 2nd serial port (UART#2 in simulator)
     UART index starts from 0 in the code.
     UART index starts from 1 in the simulator.
	*/
	SER_init(1); 
	
  /* 
	   You can de-reference a NULL pointer on MCB1700! 
	   Address 0x0 contains the initial MSP value, 
	   which is the end address of your application.
	
     WARNING: de-referencing a NULL pointer on general purpose OS
              such as Linux will produce segmentation fault!  
	*/      
  printf("Method 1: The free mem starts at 0x%x\n", *p_sp); 

  /* 
	   To use Image$$RW_IRAM1$$ZI$$Limit symbol might require
     the project to be compiled by a licensed IDE first.
     This is a more standard way of getting the end address 
     of your application 
  */
  printf("Method 2: The free mem starts at 0x%x\n", free_mem);
    
  /* 
     In case you want to read the MSP value, here is an example
     of how to use the CMSIS intrinsic fuction to do so.
     NOTE: MSP value here is different than its initial value
           upon board reset.     
  */
  printf("The MSP is 0x%x\n", __get_MSP());
   
  /* Think where we should initialize your dynamic memory region */

	os_sys_init(task1);
	
	return 0;
}
