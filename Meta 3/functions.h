#include "structures.h"

node *newNode(char* type,char* key,int linha, int coluna);
void addBrother(node* brother,node * newBrother);
void addChildren(node *father,node *children);
void printTree(node *current, int n);
void deleteTree(node* current );
void addTipoAux(node *nodeAux,char* t);
void criaTabelasSimbolos(node* p);