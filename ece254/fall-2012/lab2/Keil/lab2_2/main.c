#include <LPC17xx.h>
#include <RTL.h>
#include "GLCD.h"
#include <stdio.h>
#include <math.h>

int P = 1; // Number of producers.
int C = 1; // Number of consumers.
int index_in = 0; // Insert index.
int index_out = 0; // Remove index.

int B = 4; // Buffer size.
int buffer[4];// Create fixed buffer.

int N = 100;	// Max. number of integers.
int sent; // Sent count.
int receive; // Receive count.

int tick = 0;

// Create semaphore s, n, r, b, e.
OS_SEM s;
OS_SEM n;
OS_SEM r;
OS_SEM b;
OS_SEM e;

__task void rec_task0 (void) {
	char stringBuffer[20];
	int cid = 0; // Consumer id. 
	int i = 0;
	double root = 0;
	while (receive < N)	{
		os_sem_wait(b, 0xf); // Check if there is something in the buffer.
		os_sem_wait(s, 0xf); // Check if another task is using the buffer.
		// consume number in buffer.
		i = buffer[index_out];
		index_out = (index_out + 1)%B;
		os_sem_wait(r, 0xf); // Global variable lock.
		receive++;
		os_sem_send(r); // Global variable unlock.
		os_sem_send(s);	// Unlock buffer.
		os_sem_send(e);	// More empty space.
	
		root = sqrt(i);
		if ((root - (int)root) == 0) {
			// print cid, root, i. 
			sprintf(stringBuffer, "cid:%d i:%d root:%f", cid, i, root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);	
		} else {
			// print root.
			sprintf(stringBuffer, "root:%f", root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);
		}
		// Sleep for 0.5 seconds.
		os_dly_wait(30);
	}
	tick = os_time_get();
	//sprintf(stringBuffer, "tick:%d", tick);
	//GLCD_DisplayString(0, 0, 1, stringBuffer);
	os_tsk_delete_self();
}

__task void rec_task1 (void) {
	char stringBuffer[20];
	int cid = 1; // Consumer id.
	int i = 0;
	double root = 0;
	while (receive < N)	{
		os_sem_wait(b, 0xf); // Check if there is something in the buffer.
		os_sem_wait(s, 0xf); // Check if another task is using the buffer.
		// consume number in buffer.
		i = buffer[index_out];
		index_out = (index_out + 1)%B;
		os_sem_wait(r, 0xf); // Global variable lock.
		receive++;
		os_sem_send(r); // Global variable unlock.
		os_sem_send(s);	// Unlock buffer.
		os_sem_send(e);	// More empty space.
	
		root = sqrt(i);
		if ((root - (int)root) == 0) {
			// print cid, root, i. 
			sprintf(stringBuffer, "cid:%d i:%d root:%f", cid, i, root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);	
		} else {
			// print root.
			sprintf(stringBuffer, "root:%f", root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);
		}
		// Sleep for 0.5 seconds.
		os_dly_wait(30);
	}
	tick = os_time_get();
	//sprintf(stringBuffer, "tick:%d", tick);
	//GLCD_DisplayString(0, 0, 1, stringBuffer);
	os_tsk_delete_self();
}

__task void rec_task2 (void) {
	char stringBuffer[20];
	int cid = 2; // Consumer id.
	int i = 0;
	double root = 0;
	while (receive < N)	{
		os_sem_wait(b, 0xf); // Check if there is something in the buffer. 
		os_sem_wait(s, 0xf); // Check if another task is using the buffer.
		// consume number in buffer.
		i = buffer[index_out];
		index_out = (index_out + 1)%B;
		os_sem_wait(r, 0xf); // Global variable lock.
		receive++;
		os_sem_send(r); // Global variable unlock.
		os_sem_send(s);	// Unlock buffer.
		os_sem_send(e);	// More empty space.
	
		root = sqrt(i);
		if ((root - (int)root) == 0) {
			// print cid, root, i. 
			sprintf(stringBuffer, "cid:%d i:%d root:%f", cid, i, root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);	
		} else {
			// print root.
			sprintf(stringBuffer, "root:%f", root);
			GLCD_DisplayString(0, 0, 1, stringBuffer);
		}
		// Sleep for 0.5 seconds.
		os_dly_wait(30);
	}
	tick = os_time_get();
	//sprintf(stringBuffer, "tick:%d", tick);
	//GLCD_DisplayString(0, 0, 1, stringBuffer);
	os_tsk_delete_self();
}

__task void send_task0 (void) {
	int pid = 0;
	int i = 0;
	while (sent < N) {
		// Produce integer. 
		if (i%P == pid) {
			os_sem_wait(e, 0xf); // Wait for empty space.
			os_sem_wait(s, 0xf); // Check if another task is using the buffer. 
			// put number in buffer.
			buffer[index_in] = i;
			index_in = (index_in + 1)%B;
			os_sem_wait(n, 0xf); // Global variable lock.
			sent++;
			os_sem_send(n);	// Global variable unlock.
			os_sem_send(s);	// Unlock buffer.
			os_sem_send(b);	// More messages in buffer. 
			// Sleep for 0.5 seconds.
			//os_dly_wait(30);
		}
		i++;
	}
	os_tsk_delete_self();
}

__task void send_task1 (void) {
	int pid = 1;
	int i = 0;
	while (sent < N) {
		if (i%P == pid) {
			os_sem_wait(e, 0xf);
			os_sem_wait(s, 0xf);
			// put number in buffer.
			buffer[index_in] = i;
			index_in = (index_in + 1)%B;
			os_sem_wait(n, 0xf);
			sent++;
			os_sem_send(n);
			os_sem_send(s);
			os_sem_send(b);
			// Sleep for 0.5 seconds.
			//os_dly_wait(30);
		}
		i++;
	}
	os_tsk_delete_self();
}

__task void send_task2 (void) {
	int pid = 2;
	int i = 0;
	while (sent < N) {
		if (i%P == pid) {
			os_sem_wait(e, 0xf);
			os_sem_wait(s, 0xf);
			// put number in buffer.
			buffer[index_in] = i;
			index_in = (index_in + 1)%B;
			os_sem_wait(n, 0xf);
			sent++;
			os_sem_send(n);
			os_sem_send(s);
			os_sem_send(b);
			// Sleep for 0.5 seconds.
			//os_dly_wait(30);
		}
		i++;
	}
	os_tsk_delete_self();
}

__task void initialize_task (void) {
	tick = os_time_get();
	sent = 0;
	receive = 0;

	os_sem_init(s, 1); // s locks the buffer. Initiate it with 1.
	os_sem_init(n, 1); // n locks the variable "sent". Initiate it with 1.
	os_sem_init(r, 1); // r locks the variable "receive". Initiate it with 1.
	os_sem_init(b, 0); // b is the number of messages currently in the buffer. Initiate it with 0.
	os_sem_init(e, B); // e is the number of empty spaces in the buffer. Initiate it with buffer size.

 	// Initialize all tasks. 
	os_tsk_create(send_task0, 1);
	if (P >= 2) {
		os_tsk_create(send_task1, 1);
	}
	if (P == 3) {
		os_tsk_create(send_task2, 1);
	}
	os_tsk_create(rec_task0, 1); 
	if (C >= 2) {
		os_tsk_create(rec_task1, 1);
	}
	if (C == 3) {
		os_tsk_create(rec_task2, 1);
	}
	os_tsk_delete_self();
}

void main (void) {
	SystemInit();
	GLCD_Init();
	GLCD_Clear(White);
  	os_sys_init(initialize_task);
}
