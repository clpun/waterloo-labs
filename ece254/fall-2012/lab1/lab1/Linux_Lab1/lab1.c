#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <mqueue.h>
#include <time.h>
#include <signal.h>
#include <sys/stat.h>
#include "common.h"

#define N 20 // The number of messages the sender is going to send.
#define B 1 // Number of messages the mqueue can hold.

// Time measurement variables.
struct timeval tv;
double t1;
double t2;
double t3;

int main(){
	pid_t child_pid;
	gettimeofday(&tv, NULL); // Measure time. (get t1)
	t1 = tv.tv_sec + tv.tv_usec/1000000.0; // Convert time to seconds.
	
	child_pid = fork(); // Create child process.
	
	if (child_pid != 0) {
		// Inside parent process
		// Implement sender
		mqd_t qdes; // Declare message queue descriptors(handler).
		char  qname[] = "/msgqueue"; //Queue name.
		mode_t mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH; // Mode of file.
		struct mq_attr attr; // Queue attribute.

		attr.mq_maxmsg = B; // Set message queue size.
		attr.mq_msgsize = sizeof(int); // Set message size.
		attr.mq_flags = 0;

		qdes  = mq_open(qname, O_RDWR | O_CREAT, mode, &attr); // Create and open the message queue.
		
		srand(time(0));
		int j = 0;
		int i = 0;

		// Measure time. (get t2)
		gettimeofday(&tv, NULL);
		t2 = tv.tv_sec + tv.tv_usec/1000000.0;
		
		do {
			i = rand() % 50; // Generate random number.
			// Send random number.
			if (attr.mq_curmsgs < B) {
				if (mq_send(qdes, (char *)&i, sizeof(int), 0) == -1) {
					perror("mq_send() failed");
				} else {
					//printf("sending %i\n", i);
					j++;
				}
			}
		} while(j < N);
		
		wait(); // wait for child process to finish.
		
		// Measure time. (get t3)
		gettimeofday(&tv, NULL);
		t3 = tv.tv_sec + tv.tv_usec/1000000.0;
		
		printf("time to initialize system: %f seconds\n", (t2-t1));
		printf("time to transimit data: %f seconds\n", (t3-t2));

		// close message queue
		if (mq_close(qdes) == -1) {
			perror("mq_close() failed");
			exit(2);
		}
	} else {
		// Inside child process
		// Implement receiver
		mqd_t qdes;
		char  qname[] = "/msgqueue";
		mode_t mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH;
		struct mq_attr attr;

		attr.mq_maxmsg = B;
		attr.mq_msgsize = sizeof(int);
		attr.mq_flags = 0;

		qdes  = mq_open(qname, O_RDONLY, mode, &attr);
		if (qdes == -1 ) {
			perror("mq_open()");
			exit(1);
		}
		
		int j = 0;
		while(j < N) {
			int i;
			struct timespec ts = {time(0) + 5, 0};
			// Receive messages.
			if (mq_timedreceive(qdes, (char *) &i, sizeof(int), 0, &ts) == -1) {
				perror("mq_timedreceive() failed");
			} else {
				printf("%i is consumed.\n", i);
				j++;
			}			
		}
	}
	
	return 0;
}
