#include "functions.h"


node *newNode(char *type, char *key){

    node *new = (node *)malloc(sizeof(node));
    new->type = (char *)strdup(type);
    new->children = NULL;
    new->brother = NULL;

    if (key == NULL){
        new->key = NULL;
        return new;
    }

    new->key = (char *)strdup(key);
    return new;
}


void addBrother(node *brother, node *newBrother){

    if (brother != NULL && newBrother != NULL){
        node *auxBrother = brother;
        while (auxBrother->brother != NULL){
            auxBrother = auxBrother->brother;
        }
        auxBrother->brother = newBrother;
    }

}


void addChildren(node *father, node *child){

    if (father != NULL && child != NULL){
        father->children = child;
    }

}


void printTree(node *current, int n){

    if (current == NULL){
        return;
    }

    if (current != NULL){
        if (current->type != NULL){
            if(strcmp(current->type,"NULL")!=0){

                for (int i = 0; i < n; i++)
                    printf("..");

                if (current->key != NULL){
                    printf("%s(%s)\n", current->type, current->key);
                } else {
                    printf("%s\n", current->type);
                }

                if (current->children != NULL)
                    printTree(current->children, n + 1);
                
                if (current->brother != NULL)
                    printTree(current->brother, n);

            }

            else{
                if (current->children != NULL)
                    printTree(current->children, n );

                if (current->brother != NULL)
                    printTree(current->brother, n);
            }   
        }
    }
}