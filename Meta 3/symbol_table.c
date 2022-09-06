#include "symbol_table.h"

void printTables(){
    printGlobalTable();
    printFunctionTables();
}

void printGlobalTable(){
    printf("===== Global Symbol Table =====\n");
    struct func_table *fAux =funcHead;
    while(fAux){
        printf("%s",fAux->name);
        if(fAux->isFunc){
            printf("\t(");
            param_table *paAux = (struct param_table*)malloc(sizeof( param_table));
            paAux = fAux->params;
            if(paAux != NULL){
                printf("%s",paAux->type);
                paAux=paAux->nextNode;
                while(paAux){
                    printf(",%s",paAux->type);
                    paAux=paAux->nextNode;
                }
            }
            printf(")");
            paAux = NULL;
            free(paAux); 
        }
        else
            printf("\t");
        printf("\t%s\n", fAux->type);
        fAux = fAux->nextNode;
    }
}

void printFunctionTables(){
    struct func_table *fAux =funcHead;
    while(fAux){
        if(fAux->isFunc){
            printf("\n===== Function ");
            printf("%s(",fAux->name);
            struct param_table *paAux=fAux->params;
            if(paAux){
                printf("%s",paAux->type);
                paAux=paAux->nextNode;
                while(paAux){
                    printf(",%s",paAux->type);
                    paAux=paAux->nextNode;
                }
            }
            printf(") Symbol Table =====\n");
            printf("%s\t\t%s\n","return",fAux->type);                     // print return 

            paAux=fAux->params;
            while(paAux){
                printf("%s\t\t%s\tparam\n",paAux->name,paAux->type); // print parametros como variaveis locais
                paAux=paAux->nextNode;
            }
            struct var_table *vAux=fAux->vars;                         // print variaveis locais
            while(vAux){
                printf("%s\t\t%s\n",vAux->name,vAux->type);
                vAux=vAux->nextNode;
            }
        }
        fAux=fAux->nextNode;
    }
    printf("\n");
}