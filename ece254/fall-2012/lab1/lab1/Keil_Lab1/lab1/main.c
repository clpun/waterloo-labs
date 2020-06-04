#include <LPC17xx.h>
#include <RTL.h>
#include "GLCD.h"
#include <stdio.h>

int n = 10; // Number of messages.
int b = 1; // Mailbox size.
//int tick; // System tick.

OS_TID id1; // task ID for event transmit.

os_mbx_declare (MsgBox, 1); // Declare an RTX mailbox with b entries
U32 mpool[1*(2*sizeof(U32))/4]; // Reserve a memory for b messages

__task void rec_task (void);

__task void send_task (void) {
  	/* This task will send a message. */
  	U32 *mptr;
	char buffer[20];
	int i = 0;

	os_tsk_create (rec_task, 1); // Create and start receiver.
	os_mbx_init (MsgBox, sizeof(MsgBox)); // Initialize mailbox.
	
	// Get system time tick.
	/*tick = os_time_get() - tick;
	sprintf(buffer, "Init system: %d ticks", tick);
	GLCD_DisplayString(0,0,1,buffer);*/
	
	while(i < n) {
		mptr = _alloc_box (mpool); //Allocate a memory for the message
		mptr[0] = rand()%50; //Set the message content.
		mptr[1] = 0x0;
		// Send message.
		if (os_mbx_send (MsgBox, mptr, 0x1) == OS_R_TMO) {
			_free_box (mpool, mptr);
		} else {
			i++;
		}
	}
	os_evt_wait_or (1, 0x000f); // Wait for receiver to terminate.
  	os_tsk_delete_self ();
}

__task void rec_task (void) {
 	 /* This task will receive a message. */
  	U32 *rptr, rec_val[2];
	int rec;
	char buffer2[20];
	int nCount = 0;

	// Receive Messages.
 	while(nCount < n) {
		rec = os_mbx_wait (MsgBox, (void**)&rptr, 0xf);
		if (rec == OS_R_OK || rec == OS_R_MBX) {
			rec_val[0] = rptr[0];
			rec_val[1] = rptr[1];
			_free_box (mpool, rptr);
			nCount++;
		}
	}	
	// Get system time tick.
	/*tick = os_time_get() - tick;
	sprintf(buffer2, "Data transfer: %d ticks", tick);
	GLCD_DisplayString(0,0,1,buffer2); */
	
	// Notify sender that receiver is going to terminate.
	os_evt_set (1, id1);
  	os_tsk_delete_self ();
}

void main (void) {
	SystemInit();
	GLCD_Init();
	GLCD_Clear(White);
 	_init_box (mpool, sizeof(mpool), sizeof(U32));
	//tick = os_time_get();
  	os_sys_init(send_task);
}
