/*----------------------------------------------------------------------------
 *      RL-ARM - RTX Modifed by ECE254 Lab3
 *----------------------------------------------------------------------------
 *      Name:    RT_MEMBLK.H
 *      Purpose: Interface functions for fixed memory block management system
 *      Rev.:    V4.60
 *----------------------------------------------------------------------------
 *      This code is part of the RealView Run-Time Library.
 *      Copyright (c) 2004-2012 KEIL - An ARM Company. All rights reserved.
 *      The code has been modified to suite ECE254 lab3
 *---------------------------------------------------------------------------*/

/* Macros */
#define MEM_NOWAIT 0
#define MEM_WAIT 1

/* Variables */
/* The symbol is defined in the scatter file. Refer to RVCT Linker User Guide */
extern unsigned int Image$$RW_IRAM1$$ZI$$Limit;

/* Functions */
extern OS_RESULT   rt_mem_init     (U32 num_blks, U32 blk_size);
extern void       *rt_mem_alloc    (U8 flag) ;
extern OS_RESULT   rt_mem_free_blk (void *ptr);

/*----------------------------------------------------------------------------
 * end of file
 *---------------------------------------------------------------------------*/

