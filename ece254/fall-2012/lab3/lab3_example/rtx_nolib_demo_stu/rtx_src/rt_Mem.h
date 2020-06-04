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

/* Functions */
extern OS_RESULT   rt_mem_init     (U32 addr_start, U32 addr_end);
extern void       *rt_mem_alloc    (U8 flag) ;
extern OS_RESULT   rt_mem_free_blk (void *ptr);

/*----------------------------------------------------------------------------
 * end of file
 *---------------------------------------------------------------------------*/

