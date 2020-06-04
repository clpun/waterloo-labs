#include <LPC17xx.h>
#include <RTL.h>
#include "GLCD.h"
#include <stdio.h>
#include <math.h>

int P = 1;
int C = 1;

int n = 100; // Number of messages.
int b = 4; // Mailbox size.
int sent; // Number of sent messages.
int receive; // Number of received messages.
int tick; // System timer tick count. For time measurement.

os_mbx_declare (MsgBox, 1); // Declare an RTX mailbox with b entries
U32 mpool[1*(2*sizeof(U32))/4 + 3]; // Reserve a memory for b messages

OS_SEM s; // Control access to the mailbox.
OS_SEM m; // Number of messages in the mailbox.
OS_SEM e; // Number of empty spaces in the mailbox.

__task void rec_task0 (void) {
 	/* This task will receive a message. */
	int cid = 0; // Consumer id.
	U32 *rptr;
	int rec;
	double i = 0;
	double root = 0;
	char stringBuffer[20];

 	while(receive < n) {
		os_sem_wait(m, 0xf); // Wait for messages.
		os_sem_wait(s, 0xf);
		// Receive message.
		rec = os_mbx_wait (MsgBox, (void**)&rptr, 0x0); 
		if (rec == OS_R_OK || rec == OS_R_MBX) {
			i = rptr[0];
			_free_box (mpool, rptr);
			receive++;
			os_sem_send(e); // More empty space in mailbox.
		}
		os_sem_send(s);
		// Calculate and print outputs.
		root = sqrt(i);
		if ((root - (int)root) == 0) {
			// print cid, root, i. 
			sprintf(stringBuffer, "cid:%d i:%f root:%f", cid, i, root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);	
		} else {
			// print root.
			sprintf(stringBuffer, "root:%f", root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);
		}
		os_dly_wait(30);
	}	
	// Measure time. 
	tick = os_time_get();
	//sprintf(stringBuffer, "tick:%d", tick);
	//GLCD_DisplayString(0, 0, 1, stringBuffer);
  	os_tsk_delete_self ();
}

__task void rec_task1 (void) {
 	 	/* This task will receive a message. */
	int cid = 1; // Consumer id.
	U32 *rptr;
	int rec;
	double i = 0;
	double root = 0;
	char stringBuffer[20];

 	while(receive < n) {
		os_sem_wait(m, 0xf); // Wait for messages.
		os_sem_wait(s, 0xf);
		// Receive message.
		rec = os_mbx_wait (MsgBox, (void**)&rptr, 0x0);
		if (rec == OS_R_OK || rec == OS_R_MBX) {
			i = rptr[0];
			_free_box (mpool, rptr);
			receive++;
			os_sem_send(e);	// More empty spaces. 
		}
		os_sem_send(s);
		// Calculate and print output.
		root = sqrt(i);
		if ((root - (int)root) == 0) {
			// print cid, root, i. 
			sprintf(stringBuffer, "cid:%d i:%f root:%f", cid, i, root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);	
		} else {
			// print root.
			sprintf(stringBuffer, "root:%f", root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);
		}
		os_dly_wait(30);
	}	
	tick = os_time_get();
	//sprintf(stringBuffer, "tick:%d", tick);
	//GLCD_DisplayString(0, 0, 1, stringBuffer);
  	os_tsk_delete_self ();
}

__task void rec_task2 (void) {
 	/* This task will receive a message. */
	int cid = 2; // Consumer id.
	U32 *rptr;
	int rec;
	double i = 0;
	double root = 0;
	char stringBuffer[20];

 	while(receive < n) {
		os_sem_wait(m, 0xf); // Wait for messages.
		os_sem_wait(s, 0xf);
		// Receive message.
		rec = os_mbx_wait (MsgBox, (void**)&rptr, 0x0);
		if (rec == OS_R_OK || rec == OS_R_MBX) {
			i = rptr[0];
			_free_box (mpool, rptr);
			receive++;
			os_sem_send(e);
		}
		os_sem_send(s);
		// Calculate and print output.
		root = sqrt(i);
		if ((root - (int)root) == 0) {
			// print cid, root, i. 
			sprintf(stringBuffer, "cid:%d i:%f root:%f", cid, i, root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);	
		} else {
			// print root.
			sprintf(stringBuffer, "root:%f", root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);
		}
		os_dly_wait(30);
	}
	// Measure time.	
	tick = os_time_get();
	//sprintf(stringBuffer, "tick:%d", tick);
	//GLCD_DisplayString(0, 0, 1, stringBuffer);
  	os_tsk_delete_self ();
}

__task void send_task0 (void) {
  /* This task will send a message. */
	int pid = 0; // Producer id. 
  	U32 *mptr;
	char stringBuffer[20];
	int i = 0;
	
	while(sent < n) {
		os_sem_wait(e, 0xf); // Wait for an empty space.
		os_sem_wait(s, 0xf);
		// Produce message.
		if (i%P == pid) {
			mptr = _alloc_box (mpool); //Allocate a memory for the message
			mptr[0] = i; //Set the message content.
			mptr[1] = 0;
			// Send message.
			if (os_mbx_send (MsgBox, mptr, 0x0) == OS_R_TMO) {
				_free_box (mpool, mptr);
			} else {
				sent++;
				os_sem_send(m);
			}
		}
		os_sem_send(s);
		i++;
	}
	
  	os_tsk_delete_self ();
}

__task void send_task1 (void) {
  /* This task will send a message. */
	int pid = 1; // Producer id.
  	U32 *mptr;
	char stringBuffer[20];
	int i = 0;
	
	while(sent < n) {
		os_sem_wait(e, 0xf); // Wait for an empty space.
		os_sem_wait(s, 0xf);
		// Produce message.
		if (i%P == pid) {
			mptr = _alloc_box (mpool); //Allocate a memory for the message
			mptr[0] = i; //Set the message content.
			mptr[1] = 0;
			// Send message.
			if (os_mbx_send (MsgBox, mptr, 0x0) == OS_R_TMO) {
				_free_box (mpool, mptr);
			} else {
				sent++;
				os_sem_send(m);
			}
		}
		os_sem_send(s);
		i++;
	}
	
  os_tsk_delete_self ();
}

__task void send_task2 (void) {
  /* This task will send a message. */
	int pid = 2; // Producer id.
  	U32 *mptr;
	char stringBuffer[20];
	int i = 0;
	
	while(sent < n) {
		os_sem_wait(e, 0xf); // Wait for empty space.
		os_sem_wait(s, 0xf);
		// Produce message.
		if (i%P == pid) {
			mptr = _alloc_box (mpool); //Allocate a memory for the message
			mptr[0] = i; //Set the message content.
			mptr[1] = 0;
			// Send message.
			if (os_mbx_send (MsgBox, mptr, 0x0) == OS_R_TMO) {
				_free_box (mpool, mptr);
			} else {
				sent++;
				os_sem_send(m);
			}
		}
		os_sem_send(s);
		i++;
	}
	
  os_tsk_delete_self ();
}

__task void initialize_task (void) {
	// Initialize semaphores.
	os_sem_init(s, 1);
	os_sem_init(m, 0);
	os_sem_init(e, b);

	sent = 0;
	receive = 0;

	os_mbx_init (MsgBox, sizeof(MsgBox)); // Initialize mailbox.

	// Create tasks.
	os_tsk_create (send_task0, 1);
	if (P >= 2) {
		os_tsk_create (send_task1, 1);
	}
	if (P >= 3) {
		os_tsk_create (send_task2, 1);
	}
	os_tsk_create (rec_task0, 1);
	if (C >= 2) {
		os_tsk_create (rec_task1, 1);
	}
	if (C >= 3) {
		os_tsk_create (rec_task2, 1);
	}
	tick = os_time_get();
	os_tsk_delete_self();
}

void main (void) {
	SystemInit();
	GLCD_Init();
	GLCD_Clear(White);
 	_init_box (mpool, sizeof(mpool), sizeof(U32));
  os_sys_init(initialize_task);
}
