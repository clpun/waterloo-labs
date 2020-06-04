/**
 * @brief: ECE254 lab0: simple ls command to list file names of a directory 
 */

/* This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>          // printf() needs this, man 3 printf
#include <stdlib.h>         // exit() needs this, man 3 exit
#include <pwd.h>            // getpwuid()
#include <grp.h>            // getgrgid()
#include <time.h>           // ctime()
#include <string.h>         // strlen()

#define STRLEN1 128
#define STRLEN2 64


char g_buf[STRLEN1]="";  // global var for output a file attribute string

int 
main(int argc, char *argv[]) 
{
    DIR * p_dir;
    struct dirent* p_dirent;

    if (argc < 2) {
        printf("Usage: %s <directory name>\n", argv[0]);
        exit (1);
    }

    if ((p_dir = opendir(argv[1])) == NULL) {
        printf("opendir(%s) failed\n", argv[1]);
        exit(1);
    }

    while ((p_dirent = readdir(p_dir)) != NULL) 
    {
        char * pc_path = p_dirent->d_name;
        if ( pc_path == NULL ) {
            printf("Null pointer found!"); 
            exit(2);
        } else {
            printf("%s\n", pc_path);
        }
    }

    return 0;
}
