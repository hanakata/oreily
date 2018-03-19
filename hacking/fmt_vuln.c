#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc,char *argv[]){
    char text[1024];
    static int test_val = -72;

    if(argc < 2){
        printf("usage: %s <output text>\n",argv[0]);
        exit(0);
    }
    strcpy(text,argv[1]);

    printf("success\n");
    printf("%s",text);

    printf("\nfailed\n");
    printf(text);

    printf("\n");

    printf("[*] test_val @ 0x%08x = %d 0x%08x\n",&test_val,test_val,test_val);

    exit(0);
}