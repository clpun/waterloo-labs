/**
 *@file main.c - rlimit example
 *@brief display system limits by calling getrlimit
 *@author Irene Huang
 *@date 2012/04/30
 */

#include <stdio.h>
#include <sys/time.h>
#include <sys/resource.h>

int main( void )
{
    struct rlimit proc_limit;

    printf("Resource\tlimit\t\tmax\n");

    getrlimit(RLIMIT_CPU, &proc_limit);
    printf("CPU\t\t%lld\t\t%lld\n", 
            (long long)proc_limit.rlim_cur, (long long)proc_limit.rlim_max);

    getrlimit(RLIMIT_NPROC, &proc_limit);
    printf("NPROC\t\t%lld\t\t%lld\n", 
            (long long)proc_limit.rlim_cur, (long long)proc_limit.rlim_max);
    return 0;
}
