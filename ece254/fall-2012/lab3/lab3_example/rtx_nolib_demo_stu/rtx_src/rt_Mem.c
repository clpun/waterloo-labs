/*----------------------------------------------------------------------------
 *      Name:    RT_MEM.C
 *      Purpose: Interface functions for dynamic memory block management system
 *      NOTES:   Template file for ECE254 Lab3 Assignment
 *----------------------------------------------------------------------------*/

/** 
  * @author: PUT YOUR GROUP ID and NAME HERE
  */

/* 
   The following are some header files you may need,
   feel free to add more or remove some 
 */

#include "rt_TypeDef.h"
#include "RTX_Config.h"
#include "rt_System.h"
#include "rt_MemBox.h"
#include "rt_HAL_CM.h"
#include "rt_Task.h"
#include "rt_Mem.h"



/*--------------------------- rt_init_mem -----------------------------------*/
/** 
 * @brief: initialize the free memory region for dynamic memory allocation
 *         For example buddy system
 * @param addr_start, starting address value of a dynamic memory region
 * @param addr_end, end address value of a dynamic memory region
 * @return: 0 on success and -1 otherwise
 * NOTE: You are allowed to change the signature of this function.
 *       You may also need to extern this function 
 */

OS_RESULT rt_init_mem  (U32 addr_start, U32 addr_end) {
  return (OS_R_OK);
}

/*--------------------------- rt_mem_alloc ----------------------------------*/

void *rt_mem_alloc (U8 flag) {

  return NULL; 
}


/*--------------------------- rt_mem_free -----------------------------------*/

/**
 * @brief: free memory pointed by ptr
 * @return: OS_R_OK on success and OS_R_NOK otherwise.
 */
OS_RESULT rt_mem_free (void *ptr) {
  return (OS_R_OK);
}

/*----------------------------------------------------------------------------
 * end of file
 *---------------------------------------------------------------------------*/
