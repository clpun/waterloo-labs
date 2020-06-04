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

OS_MUT mutex1;
OS_MUT printf_mutex;  

__task void task_init(void);
__task void task1(void);
__task void task2(void);
__task void task3(void);

__task void task_init(void) {
	os_mut_init (&mutex1);
	os_mut_init (&printf_mutex);
	os_tsk_create(task1, 3); // For last test, use 3.
	os_tsk_create(task2, 2); // For last test, use 2.
	os_tsk_create(task3, 3); // For last test, use 3.
	os_tsk_delete_self();
}

/*--------------------------- task1 -----------------------------------*/
__task void task1(void)
{ 
  int i = 0;
  void *ptr[4];
  OS_RESULT ret_val;
  //printf("I am in task 1\n");

  os_mut_wait (&mutex1, 0xffff);
  for (i = 0; i < 4; i++ ) {
    ptr[i] = os_mem_alloc(MEM_WAIT);
    //printf("t1:ptr[%d]=%p\n", i, ptr[i]);
  }
  os_mut_release (&mutex1);

  os_dly_wait(500);
   
  for (i = 0; i < 4; i++) {
    ret_val = os_mem_free(ptr[i]);
    //printf("t1:free ptr[%d]=%p returns %d\n", i, ptr[i], ret_val);
  } 
  
  os_tsk_delete_self();
}

__task void task2(void) {
	void *ptr;
	OS_RESULT ret_val;
  	printf("I am in task 2\n");

	os_mut_wait (&mutex1, 0xffff);
	ptr = os_mem_alloc(MEM_WAIT);
	os_mut_release (&mutex1);
	printf("t2:ptr = %p\n", ptr);
	
	ret_val = os_mem_free(ptr);
	printf("t2:free ptr=%p returns %d\n", ptr, ret_val);

	os_tsk_delete_self();
}

__task void task3(void) {
	void *ptr;
	OS_RESULT ret_val;
  	printf("I am in task 3\n");

	os_mut_wait (&mutex1, 0xffff);
	ptr = os_mem_alloc(MEM_WAIT);
	os_mut_release (&mutex1);
	printf("t3:ptr = %p\n", ptr);
	
	ret_val = os_mem_free(ptr);
	printf("t3:free ptr=%p returns %d\n", ptr, ret_val);

	os_tsk_delete_self();
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

	os_sys_init(task_init);
	
	return 0;
}
