
# Makefile, ECE254 lab0
# Irene Huang, 2012/04/30

CC=gcc
CFLAGS=-Wall -g
LD=gcc
LDFLAGS=-g


OBJS=main.o

all: main.out

main.out: $(OBJS) 
	$(CC) $(CFLAGS) $(LDFLAGS) -o main.out $(OBJS) 

main.o: main.c
	$(CC) $(CFLAGS) -c main.c


.PHONY: clean
clean:
	rm -f *.o *.out 
