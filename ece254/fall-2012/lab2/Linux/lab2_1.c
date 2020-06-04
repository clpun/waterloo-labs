#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdbool.h>
#include <mqueue.h>
#include <time.h>
#include <signal.h>
#include <sys/stat.h>
#include <math.h>

#define P 1
#define C 1
#define N 100 // The number of messages the sender is going to send.
#define B 4 // Number of messages the mqueue can hold.

struct timeval tv;
double t1;
double t2;

void producer(int pid) {
	if (pid == 0) {
		gettimeofday(&tv, NULL); // Measure time. (get t1)
		t1 = tv.tv_sec + tv.tv_usec/1000000.0; // Convert time to seconds.
		printf("start time:%f\n", t1);
	}
	mqd_t qdes; // Declare message queue descriptors(handler).
	char  qname[] = "/msgqueuetwo"; //Queue name.
	mode_t mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH; // Mode of file.
	struct mq_attr attr; // Queue attribute.

	attr.mq_maxmsg = B; // Set message queue size.
	attr.mq_msgsize = sizeof(int); // Set message size.
	attr.mq_flags = 0;

	qdes  = mq_open(qname, O_RDWR | O_CREAT, mode, &attr); // Create and open the message queue.
	
	int i = 0;
	
	// Produce integer.
	while(i < N) {
		if (i%P == pid) {
			if (mq_send(qdes, (char *)&i, sizeof(int), 0) == -1) {
				perror("mq_send() failed");
			} else {
				printf("sending %i\n", i);
			}
		}
		i++;
		sleep(1);
	}
}

void consumer(int cid) {
	//printf("in consumer.\n");
	mqd_t qdes;
	char  qname[] = "/msgqueuetwo";
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
	
	double root = 0;
	
	while(true) {
		int count = 0;
		int i;
		struct timespec ts = {time(0) + 2, 0};
		// Receive messages.
		if (mq_timedreceive(qdes, (char *) &i, sizeof(int), 0, &ts) == -1) {
			count++;
		} else {
			printf("%i is consumed.\n", i);
			root = sqrt((double)i);
			if ((root - (int)root) == 0) {
				printf("cid:%d, i:%d, root:%f\n", cid, i, root);
			}else{
				printf("root:%f\n", root);
			}
		}
		
		if (i == (N-1)) {
            gettimeofday(&tv, NULL); // Measure time. (get t2)
            t2 = tv.tv_sec + tv.tv_usec/1000000.0; // Convert time to seconds.
            printf("end time:%f\n", t2);
			break;
        }
		if (count == 3) {
			break;
		}
	}
}

int main() {
	pid_t ppid[P];
	pid_t cpid[C];
	pid_t parentpid = getpid();
	int i;
	int j;
	
	// Create producers and consumers.
	for(i = 0; i < (P - 1); i++) {
		ppid[i] = fork();
		if (ppid[i] < 0) {
			printf("Child not created.\n");
		} else if (ppid[i] == 0) {
			producer(i+1);
			break;
		} else {
			
		}
	}
	if (getpid() == parentpid) {
		for (j = 0; j < C; j++) {
			cpid[j] = fork();
			if (cpid[j] < 0) {
				printf("Child not created.\n");
			} else if (cpid[j] == 0) {
				consumer(j);
				break;
			} else {
				
			}
		}
	}
	if (getpid() == parentpid) {
		producer(0);
	}
	return 0;
}
