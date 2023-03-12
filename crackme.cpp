#include <stdio.h>
#include <stdlib.h>

int main()
{
    FILE* binary = fopen("../CRACKME.com", "r+");
    if (!binary)
    {
        fprintf(stderr, "NO FILE!\n");
        abort();
    }

    char hack[] = {0, 0};
    fseek(binary, 0xcb, SEEK_SET);
    fwrite(hack, sizeof(char), 2, binary);
    fclose(binary); 

    return 0;
}

