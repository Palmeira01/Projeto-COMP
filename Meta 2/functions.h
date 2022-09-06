#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

typedef struct node{
	struct node *children;
    struct node *brother;
    char* key;
    char* type;
} node;

node *newNode(char* type,char* key);
void addBrother(node* brother,node * newBrother);
void addChildren(node *father,node *children);
void printTree(node *current, int n);