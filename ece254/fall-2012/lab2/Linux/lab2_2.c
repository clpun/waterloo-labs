#include <pthread.h>
#include <stdio.h>
#include <semaphore.h>

#define B 4
#define N 100
#define P 1
#define C 1
int buffer[B];
int index_in = 0;
int index_out = 0;

int sent;
int receive;

struct timeval tv;
double t1;
double t2;

sem_t sem_mutex; // buffer semaphore.
sem_t b; // number of messages currently in queue.
sem_t e; // number of empty spaces in queue.

// Producer 0.
void *Producer0() {
	int pid = 0; // Producer id.
	int i = 0; 
	while(sent < N) {
		if (i%P == pid) {
			sem_wait(&e); // Check if buffer is empty.
			sem_wait(&sem_mutex); // Lock buffer.
			// Put integer in buffer.
			buffer[index_in] = i;
			index_in = (index_in + 1)%B;
			sent++;
			sem_post(&b); // More integers in buffer.
			sem_post(&sem_mutex); // Unlock buffer.
		}
		i++;
		sleep(1);
	}
}

// Producer 1.
void *Producer1() {
	int pid = 1;
	int i = 0;
	while(sent < N) {
		if (i%P == pid) {
			sem_wait(&e);
			sem_wait(&sem_mutex);
			buffer[index_in] = i;
			index_in = (index_in + 1)%B;
			sent++;
			sem_post(&b);
			sem_post(&sem_mutex);
		}
		i++;
		sleep(1);
	}
}

// Producer 2.
void *Producer2() {
	int pid = 2;
	int i = 0;
	while(sent < N) {
		if (i%P == pid) {
			sem_wait(&e);
			sem_wait(&sem_mutex);
			buffer[index_in] = i;
			index_in = (index_in + 1)%B;
			sent++;
			sem_post(&b);
			sem_post(&sem_mutex);
		}
		i++;
		sleep(1);
	}
}

void *Consumer0(){
	int cid = 0;
	double i = 0;
	double root = 0;
	while (receive < N)	{
		sem_wait(&b);
		sem_wait(&sem_mutex);
		i = buffer[index_out];
		index_out = (index_out + 1)%B;
		receive++;
		sem_post(&e);		
		sem_post(&sem_mutex);
		
		//printf("received:%d\n", receive);
		root = sqrt(i);
		if ((root - (int)root) == 0) {
			// print cid, root, i. 
			printf("cid:%d i:%f root:%f\n", cid, i, root);	
		} else {
			// print root.
			printf("root:%f\n", root);
		}
	}
	if (receive <= N) {
		gettimeofday(&tv, NULL); // Measure time. (get t1)
		t2 = tv.tv_sec + tv.tv_usec/1000000.0; // Convert time to seconds.
	}
	sleep(2);
}

void *Consumer1(){
	int cid = 1;
	double i = 0;
	double root = 0;
	while (receive < N)	{
		sem_wait(&b);
		sem_wait(&sem_mutex);
		i = buffer[index_out];
		index_out = (index_out + 1)%B;
		receive++;
		sem_post(&e);		
		sem_post(&sem_mutex);
		
		//printf("received:%d", receive);
		root = sqrt(i);
		if ((root - (int)root) == 0) {
			// print cid, root, i. 
			printf("cid:%d i:%f root:%f\n", cid, i, root);	
		} else {
			// print root.
			printf("root:%f\n", root);
		}
	}
	if (receive <= N) {
		gettimeofday(&tv, NULL); // Measure time. (get t1)
		t2 = tv.tv_sec + tv.tv_usec/1000000.0; // Convert time to seconds.
	}
	sleep(2);
}

void *Consumer2(){
	int cid = 2;
	double i = 0;
	double root = 0;
	while (receive < N)	{
		sem_wait(&b);
		sem_wait(&sem_mutex);
		i = buffer[index_out];
		index_out = (index_out + 1)%B;
		receive++;
		sem_post(&e);		
		sem_post(&sem_mutex);
		
		//printf("received:%d", receive);
		root = sqrt(i);
		if ((root - (int)root) == 0) {
			// print cid, root, i. 
			printf("cid:%d i:%f root:%f\n", cid, i, root);	
		} else {
			// print root.
			printf("root:%f\n", root);
		}
	}
	if(receive <= N) {
		gettimeofday(&tv, NULL); // Measure time. (get t1)
		t2 = tv.tv_sec + tv.tv_usec/1000000.0; // Convert time to seconds.
	}
	sleep(2);
}

int main(){
	gettimeofday(&tv, NULL); // Measure time. (get t1)
	t1 = tv.tv_sec + tv.tv_usec/1000000.0; // Convert time to seconds.
	
	pthread_t ptid0,ctid0;
	pthread_t ptid1, ptid2;
	pthread_t ctid1, ctid2;
	
	sent = 0;
	receive = 0;
	
	//initialize the semaphores
	sem_init(&sem_mutex,0,1);
	sem_init(&b, 0, 0);
	sem_init(&e, 0, B);

	//creating producer and consumer threads
	if(pthread_create(&ptid0, NULL, Producer0, NULL)){
		printf("\n ERROR creating Producer0");
		exit(1);
    	}
	if (P >= 2) {
		if(pthread_create(&ptid1, NULL, Producer1, NULL)){
			printf("\n ERROR creating Producer1");
			exit(1);
		}
	}
	if (P == 3) {
		if(pthread_create(&ptid2, NULL, Producer2, NULL)){
			printf("\n ERROR creating Producer2");
			exit(1);
		}
	}

	if(pthread_create(&ctid0, NULL, Consumer0, NULL)) {
		printf("\n ERROR creating Consumer0");
		exit(1);
   	}
	if (C >= 2) {
		if(pthread_create(&ctid1, NULL, Consumer1, NULL)) {
			printf("\n ERROR creating Consumer1");
			exit(1);
   		}
	}
	if (C == 3) {
		if(pthread_create(&ctid2, NULL, Consumer2, NULL)) {
			printf("\n ERROR creating Consumer2");
			exit(1);
   		}
	}

   	// wait for the producers to finish
	if(pthread_join(ptid0, NULL)){
		printf("\n ERROR joining thread");
		exit(1);
	}
	
	if (P >= 2) {
		if(pthread_join(ptid1, NULL)){
			printf("\n ERROR joining thread");
			exit(1);
		}
	}

	if (P == 3) {
		if(pthread_join(ptid2, NULL)){
			printf("\n ERROR joining thread");
			exit(1);
		}
	}
	
	// wait for consumers to finish
	if(pthread_join(ctid0, NULL)) {
		printf("\n ERROR joining thread");
		exit(1);
	}

	if (C >= 2) {
		if(pthread_join(ctid1, NULL)){
			printf("\n ERROR joining thread");
			exit(1);
		}
	}
	
	if (C == 3) {
		if(pthread_join(ctid2, NULL)) {
			printf("\n ERROR joining thread");
			exit(1);
		}
	}
	
	printf("time: %f seconds\n", (t2-t1));
	
	sem_destroy(&sem_mutex);
	sem_destroy(&b);
	sem_destroy(&e);

	//exit the main thread
    	pthread_exit(NULL);
	return 1;
}
