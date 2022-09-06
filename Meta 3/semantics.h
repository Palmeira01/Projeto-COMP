#include "functions.h"
#include "structures.h"

func_table *addFunc(node *p);
void addVar(node* p);
bool verifica (node *p, char *name);
void addParam (node *p, func_table *fAux, char *name, char *type, bool isFunc);
void addVarsInFuncs(node* p,func_table * fAux);
char* statementExpressions(node *p, func_table *fAux);
bool usedVar(node* p,char *varName);
void guardParamVar(var_table *vAux, char *name, char *type);
void guardParamFunc(param_table *fAux, char *name, char *type);
