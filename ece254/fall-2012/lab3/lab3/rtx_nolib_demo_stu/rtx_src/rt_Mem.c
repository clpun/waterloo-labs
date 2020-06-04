/*----------------------------------------------------------------------------
 *      RL-ARM - RTX
 *----------------------------------------------------------------------------
 *      Name:    RT_MEM.C
 *      Purpose: Interface functions for fixed memory block management system
 *      Rev.:    V4.60
 *      NOTES:   Modified version of RT_MEMBOX.C for ECE254 Lab3 Assignment  
 *----------------------------------------------------------------------------
 *      This code is part of the RealView Run-Time Library.
 *      Copyright (c) 2004-2012 KEIL - An ARM Company. All rights reserved.
 *---------------------------------------------------------------------------*/

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

/*----------------------------------------------------------------------------
 *      Global Variables
 *---------------------------------------------------------------------------*/

/* The dynamic memory pool starting addr. */
void *gp_mpool;


/*--------------------------- rt_mem_init -----------------------------------*/
/** 
 * @brief: initialize the free memory region for dynamic memory allocation
 *         For example buddy system
 * @param num_blks, number of memory blocks in the pool 
 * @param blk_size, how many bytes per memory block 
 * @return: OS_R_OK on success and OS_R_NOK otherwise
 * NOTE: You are allowed to change the signature of this function.
 *       You may also need to extern this function 
 */

OS_RESULT rt_mem_init  (U32 num_blks, U32 blk_size) {
  void *p_end;
  void *p_blk;
  void *p_next;
  U32  sizeof_bm;
  U32  mpool_size;     /* memory pool size including meta data space */
 
  /* starting address of the memory pool is the end addr. of image
     adding a word padding for safety reason
   */
  gp_mpool = (void *)((&Image$$RW_IRAM1$$ZI$$Limit) + 1);

  mpool_size = sizeof(struct OS_BM) + blk_size * num_blks;
  
  /* Create memory structure. */
  if (blk_size & BOX_ALIGN_8) {
    /* Memory blocks 8-byte aligned. */ 
    blk_size = ((blk_size & ~BOX_ALIGN_8) + 7) & ~7;
    sizeof_bm = (sizeof (struct OS_BM) + 7) & ~7;
  }
  else {
    /* Memory blocks 4-byte aligned. */
    blk_size = (blk_size + 3) & ~3;
    sizeof_bm = sizeof (struct OS_BM);
  }
  if (blk_size == 0) {
    return (OS_R_NOK);
  }
  
  if ((blk_size + sizeof_bm) > mpool_size) {
    return (OS_R_NOK);
  }
  
  /* Create a Memory structure. */
  p_blk = ((U8 *) gp_mpool) + sizeof_bm; // gp_mpool is the dynamic memory pool starting addr.
  ((P_BM) gp_mpool)->free = p_blk; // set start addr of mem region.
  p_end = ((U8 *) gp_mpool) + mpool_size; // start addr + mpool size = end addr.
  ((P_BM) gp_mpool)->end      = p_end; // set end addr of mem region. 
  ((P_BM) gp_mpool)->blk_size = blk_size; // define size of a mem block.

  /* Link all free blocks using offsets. */
  p_end = ((U8 *) p_end) - blk_size;
  while (1)  {
    p_next = ((U8 *) p_blk) + blk_size;
    if (p_next > p_end)  break;
    *((void **)p_blk) = p_next;
    p_blk = p_next;
  }
  /* end marker */
  *((void **)p_blk) = 0;
  return (OS_R_OK);
}

/*--------------------------- rt_mem_alloc ----------------------------------*/

/*  
   This implementation ignores the "flag" parameter
   It returns NULL when the memory pool is full.
   You need to change the code to finish lab3.
   You may want to consider using your own data structure
   to manage the memory pool instead of using the P_BM.
 */
void *rt_mem_alloc (U8 flag) {
    /* Allocate a memory block and return start address. */
 	if(flag == MEM_NOWAIT) {
  		void **free;
 		int  irq_dis;
  		irq_dis = __disable_irq ();

  		free = ((P_BM) gp_mpool)->free; 
  		if (free) {
  			((P_BM) gp_mpool)->free = *free; // To the next mem block.
  		}
  		if (!irq_dis) __enable_irq ();
		return (free);
	} else if (flag == MEM_WAIT) {
		void **free;
 		int  irq_dis;
  		irq_dis = __disable_irq ();

		free = ((P_BM) gp_mpool)->free; 
  		if (free) {
			((P_BM) gp_mpool)->free = *free; // To the next mem block.
		} else {
			// block calling task.
			if (((P_BM)gp_mpool)->p_lnk != NULL) {
        		rt_put_prio((P_XCB)gp_mpool, os_tsk.run);
			} else {
			 	((P_BM)gp_mpool)->p_lnk = os_tsk.run;
       			os_tsk.run->p_lnk  = NULL;
				os_tsk.run->p_rlnk = NULL;
			}
			rt_block (0x0fff, WAIT_MEM);
      	}
		if (!irq_dis) __enable_irq ();
		return (free);
	}
	
	return NULL;
}


/*--------------------------- rt_mem_free -----------------------------------*/

/**
 * @brief: free memory pointed by ptr
 * @return: OS_R_OK on success and OS_R_NOK if ptr does not belong to gp_mpool 
 */
/* NOTE: This implementation does not unblock a WAIT_MEM task.
 *       You will need to change the code in order to do so.
 *       If you find the default P_BM structure is not sufficient,
 *       feel free to use your own data structure.
 */
OS_RESULT rt_mem_free (void *ptr) {
	P_TCB p_TCB;
	int irq_dis;
	/* This is a very loose check (taken from the stocked RTX). 
		For better fault tolernace, it should have also checked 
		whether the ptr is not pointing to the middle of the memory block. 
	*/
	if (ptr < gp_mpool || ptr >= ((P_BM)gp_mpool)->end) {
		return (OS_R_NOK);
	}

	irq_dis = __disable_irq ();
	*((void **)ptr) = ((P_BM) gp_mpool)->free;
	((P_BM) gp_mpool)->free = ptr;

	if (((P_BM) gp_mpool)->p_lnk != NULL) {
		// A task is waiting for a memory block.
		p_TCB = ((P_BM) gp_mpool)->p_lnk;
		p_TCB->ret_val = (U32)rt_mem_alloc(MEM_WAIT);
		// remove task from waiting list.
		((P_BM)gp_mpool)->p_lnk = p_TCB->p_lnk;
      	rt_dispatch (p_TCB);
      	//os_tsk.run->ret_val = OS_R_OK;
	}

	if (!irq_dis) __enable_irq ();
	return (OS_R_OK);
}

/*----------------------------------------------------------------------------
 * end of file
 *---------------------------------------------------------------------------*/
