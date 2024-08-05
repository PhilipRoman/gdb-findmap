const char constant[] = "test";

#include <stdio.h>
int main(int argc, char *argv[]) {
	printf("Hello, world! %p\n", (void*)&argc);
}
