#ifndef STRUCTURES_H
#define STRUCTURES_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <stdbool.h>

struct func_table *funcHead;                                     // ponteiro para a cabeça da lista ligada de funcoes
struct errors_list *errHead;                                     // ponteiro para a cabeça da lista ligada de erros

typedef struct node{
    int linha, coluna;
    char* key;
    char* type;
    char* tipoAux;
	struct node *children;
    struct node *brother;
} node;

typedef struct func_table{ // representa uma lista ligada de funcores e de variaveis globais
    char* name;
    char* type;
    bool isFunc;
    bool isDeclared;
    struct var_table *vars;
    struct param_table *params;
    struct func_table *nextNode;
} func_table;

typedef struct var_table{ // representa uma lista ligada de variaveis locais de uma funcao
    char* name;
    char* type;
    struct var_table *nextNode;
} var_table;

typedef struct param_table{ // representa uma lista ligada de parametros de uma funcao
    char* name;
    char* type;
    struct param_table *nextNode;
} param_table;

typedef struct errors_list{
    int linha;
    int coluna;
    char *strError;
    bool isUsed;
    struct errors_list *nextNode;
} errors_list;

#endif
