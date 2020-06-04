
# Makefile, ECE254 lab0
# Irene Huang, 2012/09/10

CC=gcc
CFLAGS=-Wall -g
LD=gcc
LDFLAGS=-g


OBJS1=ls_ftype.o
OBJS2=ls_fname.o

all: ls_ftype.out ls_fname.out

ls_ftype.out: $(OBJS1) 
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS1) 

ls_fname.out: $(OBJS2) 
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS2) 

.c.o:
	$(CC) $(CFLAGS) -c $<

.PHONY: clean
clean:
	rm -f *.o *.out 
