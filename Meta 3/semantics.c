#include "semantics.h"
 
struct func_table *funcHead;                                     // ponteiro para a cabeça da lista ligada de funcoes
struct errors_list *errHead;                                     // ponteiro para a cabeça da lista ligada de erros
int linha;
int coluna;
int n_error = 0;
extern int syntax_error;

void criaTabelasSimbolos(node* p){

    funcHead = NULL;
    p=p->children;                      // vai buscar o primeiro VarDec/FuncDec                                                 
    node* funcVarHead=p;                // faz uma copia do primeiro filho da cabeça da lista

    // 'Global Symbol Table' (1ª parte)
    while(strcmp(p->type,"FuncDecl")==0||strcmp(p->type,"VarDecl")==0){         // verifica as declaraçoes de primerio nivel
        if(strcmp(p->type,"FuncDecl")==0){
            addFunc(p);
        }
        else if(strcmp(p->type,"VarDecl")==0){
            addVar(p);
        }
        p=p->brother;                   // passa para o irmão seguinte
        if (p==NULL)                    // se nao houver mais irmaos, sai fora do ciclo
            break;
    }
    
    p=funcVarHead;                      // vai buscar novamente o primeiro filho do primeiro subnivel

    // 'Functions' (2ª parte)
    while(strcmp(p->type,"FuncDecl")==0||strcmp(p->type,"VarDecl")==0){
        if(strcmp(p->type,"FuncDecl")==0){                 
            func_table *fAux=NULL;
            struct func_table *fAux2 =funcHead; 
            // se a função ainda não foi declarada, vai buscar o ponteiro da função
            while(fAux2){
                if(fAux2->isFunc){
                    if(strcmp(fAux2->name,p->children->children->key)==0){ 
                        if(fAux2->isDeclared==false){
                            fAux2->isDeclared=true;
                            fAux=fAux2;
                            break;
                        }
                        break;
                    }
                }
                fAux2=fAux2->nextNode;
            }

            if(fAux != NULL){
                node* pAux=p->children->brother->children; 

                while(pAux){
                    if(strcmp(pAux->type,"VarDecl")==0){                     // caso variavel
                        addVarsInFuncs(pAux,fAux);
                    }
                    else if(strcmp(pAux->type,"NULL")!=0){                   // caso statement
                        statementExpressions(pAux,fAux);
                    }
                    pAux=pAux->brother;
                }
            }
        }
        p=p->brother;
        if (p==NULL)
            break;
    }
}

func_table *addFunc(node *p){

    char* funcName = (char *)malloc(sizeof(char)*256);                  // funcDcl FuncHeader Id
    char* funcType = (char *)malloc(sizeof(char)*256);  
    
    strcpy(funcName, p->children->children->key);                       // faz uma copia do nome
    strcpy(funcType, p->children->children->brother->type);             // faz uma copia do tipo do nó irmão

    if (verifica(p->children->children, funcName)){                     // verifica se a variavel ja existe
        free(funcName);                                                 // liberta a memoria reservada para a variavel 
        free(funcType);
        return NULL;
    }

    funcType[0]=tolower(funcType[0]);                                   // coloca a primeira letra minuscula
    
    if(funcHead == NULL){                                               // no caso em que nao foi adicionada nenhuma funcao/variavel  
        
        funcHead=(struct func_table*)malloc(sizeof(func_table));
        if(strcmp(funcType,"funcParams")==0){                           // strcmp(funcType,"funcParams")==0||strcmp(funcType,"FuncParams")==0
            funcType="none";    
        }

        addParam(p,funcHead,funcName,funcType,true);                    // os parametros podem ser adicionados porque podem ter o mesmo nome que variaveis globais/ funcoes
        return funcHead;
    }
    else {
        struct func_table *fAux = funcHead;                          // faz uma copia da cabeça principal da lista ligada 

        while(fAux->nextNode != NULL){                               // percorre as funcoes ate encontrar um espaço para colocar uma variavel nova
            fAux=fAux->nextNode;
        }
        fAux->nextNode=(struct func_table*)malloc(sizeof( func_table));
        fAux = fAux->nextNode;
        
        if(strcmp(funcType,"funcParams")==0){
            funcType="none";                                            // adiciona Type none se nao houver type
        }

        addParam(p,fAux,funcName,funcType,true);                        // os parametros podem ser adicionados porque podem ter o mesmo nome que variaveis globais/ funcoes
        return fAux;
    }
}

void addVar(node* p){  

    struct func_table *fAux = funcHead;

    char* varName = (char *)malloc(sizeof(char)*256);                   // VarDcl Type Id
    char* varType =(char *)malloc(sizeof(char)*256) ;                   // alterar o tamanho ?

    strcpy(varName,p->children->brother->key);
    strcpy(varType,p->children->type);
    
    if (verifica(p->children->brother,varName)){                        // devolve 0 se a variavel existe
        free(varName);
        free(varType);
        return;
    }

    varType[0]=tolower(varType[0]);
    
    if(funcHead == NULL){                                                      // no caso em que nao foi adicionada nenhuma funcao/variavel  
        funcHead=(struct func_table*)malloc(sizeof( func_table));
        funcHead->name=varName;
        funcHead->type=varType;
        funcHead->isFunc=false;
        funcHead->isDeclared=false;
        funcHead->nextNode=NULL;
        funcHead->params=NULL;
        funcHead->vars=NULL;
        return;
    }
    else{
        while(fAux->nextNode != NULL){
            fAux=fAux->nextNode;
        }

        fAux->nextNode=(struct func_table*)malloc(sizeof( func_table));
        fAux =fAux->nextNode;
        addParam(p,fAux,varName,varType,false);
        return;
    }
}

bool verifica (node *p, char *name){
    struct func_table *fAux = funcHead;
    while (fAux){
        if (strcmp(name, fAux->name)==0){       // ja existe
            syntax_error = 1;
            printf("Line %d, column %d: Symbol %s already defined\n",p->linha,p->coluna,name);
            return 1;
        }
        fAux = fAux->nextNode;
    }
    // nao encontrou variavel com o mesmo nome
    return 0;
}

void addParam (node *p, func_table *fAux, char *name, char *type, bool isFunc){
    
    // adidiona parametros na estrutura
    fAux->name=name;
    fAux->type=type;
    fAux->isFunc=isFunc;
    fAux->isDeclared=false;
    fAux->nextNode=NULL;
    fAux->params=NULL;
    fAux->vars=NULL;

    if (isFunc){
        node* pAux=p->children->children;                                                // aponta para o id
        pAux=pAux->brother;

        if(strcmp(pAux->type,"FuncParams")!=0 && strcmp(pAux->type,"funcParams")!=0){ // porque depois do id nao vem necessariamente um type , pode ser de tipo none 
            pAux=pAux->brother;
        }

        pAux=pAux->children;                                                          // passa para a primeira funcao do funcsParams
        if(pAux == NULL){                                                                // No caso de nao ter parametros simplesmente sai porque nao ha nada para adicionar
            return;
        }

        param_table* funcParamsHead=NULL;
        param_table* funcParams2=NULL;
        param_table* funcParams3=funcParamsHead;

        bool ver;
        while (pAux != NULL){
            ver = false;
            
            // verifica se a variavel ja foi definida anteriormente nos parametros da funcao
            while(funcParams3){                                                              
                if(strcmp(funcParams3->name,pAux->children->brother->key)==0){
                    ver=true;
                    syntax_error = 1;
                    printf("Line %d, column %d: Symbol %s already defined\n",pAux->children->brother->linha,pAux->children->brother->coluna,pAux->children->brother->key);
                }
                funcParams3=funcParams3->nextNode;
            }

            if(!ver){
                if (funcParams2 == NULL){               // caso seja o primeiro parametro a ser inserido na funcao
                    funcParams2 = (struct param_table*)malloc(sizeof( param_table));
                    guardParamFunc(funcParams2, pAux->children->brother->key, pAux->children->type);          // faz a inserçao dos parametro na estrutura param_table
                    funcParamsHead=funcParams2;         // a cabeça do funcParamsHed guarda a cabeça do funcParams2
                }
                else {
                    funcParams2->nextNode = (struct param_table*)malloc(sizeof( param_table));
                    funcParams2=funcParams2->nextNode;
                    guardParamFunc(funcParams2, pAux->children->brother->key, pAux->children->type);          // faz a inserçao dos parametro na estrutura param_table
                }
                // incializa nextNode
            }
            funcParams3=funcParamsHead;
            pAux=pAux->brother;                       // passa para o parametro seguinte
        }
        fAux->params=funcParamsHead;
    }
    return;
}

void addVarsInFuncs(node* p,func_table * fAux){
    param_table *paAux =fAux->params;
    node *pAux=p->children->brother;

    while(paAux!=NULL){
        if(strcmp(paAux->name,pAux->key)==0){                         // se variável ja foi definida, dá erro
            syntax_error = 1;
            printf("Line %d, column %d: Symbol %s already defined\n",pAux->linha,pAux->coluna,pAux->key);
            return;
        }
        paAux=paAux->nextNode;  
    }    

    var_table *vAux =fAux->vars;
    if(vAux == NULL){
        vAux= (struct var_table*)malloc(sizeof( var_table));
        guardParamVar(vAux, p->children->brother->key, p->children->type);           // faz a inserçao dos parametro na estrutura var_table
        fAux->vars=vAux;
        if (usedVar(p->brother,vAux->name)==0){                                            // se variável foi declarada e não foi usada, dá erro
            syntax_error = 1;
            printf("Line %d, column %d: Symbol %s declared but never used\n",pAux->linha,pAux->coluna,vAux->name);
        }
    }
    else{
        while(vAux->nextNode){     // percorre os restantes elementos
            if(strcmp(vAux->nextNode->name,p->children->brother->key)==0){    // se variável ja foi definida, dá erro
                syntax_error = 1;
                printf("Line %d, column %d: Symbol %s already defined\n",pAux->linha,pAux->coluna,pAux->key);
                return;
            }
            vAux=vAux->nextNode;
        }

        vAux->nextNode= (struct var_table*)malloc(sizeof( var_table));
        vAux=vAux->nextNode;
        guardParamVar(vAux, p->children->brother->key, p->children->type);               // faz a inserçao dos parametro na estrutura var_table
        if (usedVar(p->brother,vAux->name)==0){     // Se a variável foi declarada e não foi usada, dá erro
            syntax_error = 1;
            printf("Line %d, column %d: Symbol %s declared but never used\n",pAux->linha,pAux->coluna,vAux->name);
        }
    }
}

void guardParamVar(var_table *vAux, char *name, char *type){
    vAux->nextNode=NULL;
    vAux->name=(char *)malloc(sizeof( char)*256); 
    vAux->type=(char *)malloc(sizeof( char)*256);
    strcpy(vAux->name,name);
    strcpy(vAux->type,type); 
    vAux->type[0]=tolower(vAux->type[0]);
}

void guardParamFunc(param_table *fAux, char *name, char *type){
    fAux->nextNode=NULL;
    fAux->name=(char *)malloc(sizeof( char)*256); 
    fAux->type=(char *)malloc(sizeof( char)*256);
    strcpy(fAux->name,name);
    strcpy(fAux->type,type); 
    fAux->type[0]=tolower(fAux->type[0]);
}

char* statementExpressions(node *p, func_table *fAux){
    
    if(strcmp(p->type,"ParseArgs")==0){

        char *tipo1=statementExpressions(p->children,fAux);
        char *tipo2=statementExpressions(p->children->brother,fAux);
        if(strcmp(tipo1,"int")!=0||strcmp(tipo2,"int")!=0){
            syntax_error = 1;
            printf("Line %d, column %d: Operator strconv.Atoi cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);
            addTipoAux(p,"undef");
            return "undef";
        }
        
        addTipoAux(p,"int");
        return "int"; 
    }
    else if(strcmp(p->type,"Return")==0){
    
        if(p->children){
            char *tipo1=statementExpressions(p->children,fAux);
            if(strcmp(tipo1,fAux->type)!=0){
                syntax_error = 1;
                printf("Line %d, column %d: Incompatible type %s in return statement\n",p->children->linha,p->children->coluna,tipo1);
            }
        }
        else{
            if(strcmp("none",fAux->type)!=0){
                syntax_error = 1;
                printf("Line %d, column %d: Incompatible type none in return statement\n",p->linha,p->coluna);
            }
        }
        
        return "null"; 
    }
    else if(strcmp(p->type,"Print")==0){
        char *tipo=statementExpressions(p->children,fAux);
        
        if(strcmp(tipo,"undef")==0){
            syntax_error = 1;
            printf("Line %d, column %d: Incompatible type %s in fmt.Println statement\n",p->children->linha,p->children->coluna,tipo);
        }
        
        return "null"; 
    }
    else if(strcmp(p->type,"StrLit")==0){
        addTipoAux(p,"string");
        return "string"; 
    }
    else if(strcmp(p->type,"RealLit")==0){
        addTipoAux(p,"float32");
        return "float32"; 
    }
    else if(strcmp(p->type,"IntLit")==0){

        if(p->key[0]=='0'){            // é um octal ou hexadecimal
            if((p->key[1]=='x'||p->key[1]=='X')){   // é hexadecimal
                addTipoAux(p,"int");
                return "int";
                
            }
            int i=1;

            while(p->key[i]!='\0'){     // é um octa
                if((p->key[i]<'0'||p->key[i]>'7')){
                    syntax_error = 1;
                    printf("Line %d, column %d: Invalid octal constant: %s\n",p->linha,p->coluna,p->key);
                    addTipoAux(p,"int");
                    return "int";
                }
                i++;
            }

        }
        addTipoAux(p,"int");
        return "int";
    }
    else if(strcmp(p->type,"Id")==0){

        bool aux = false;
        // verifica se variavel existe
        while(aux==false){
            if(strcmp("Id",p->type)!=0){
                break;
            }
            var_table *varAux=fAux->vars;               // verifica nas variaveis locais    
            while(varAux){
                if(strcmp(varAux->name,p->key)==0){
                    aux=true;
                    break;
                }
                varAux=varAux->nextNode;
            }
            if(aux==true){
                break;
            }
            param_table *parAux=fAux->params;            // verifica nos parametros   
            while(parAux){
                if(strcmp(parAux->name,p->key)==0){
                    aux=true;
                    break;
                }
                parAux=parAux->nextNode;
            }
            if(aux==true){
                break;
            }
            func_table *fAux2=funcHead;                  // verifica nas variaveis globais   
            while(fAux2){
                if(!fAux2->isFunc){
                    if(strcmp(fAux2->name,p->key)==0){
                        aux=true;
                        break;
                    }
                }
                fAux2=fAux2->nextNode;
            }
            if(aux==true){
                break;
            }
            // variavel nao existe
            syntax_error = 1;
            printf("Line %d, column %d: Cannot find symbol %s\n",p->linha,p->coluna,p->key);
            aux=true;
        }
        
        var_table *varAux=fAux->vars;                    // verifica nas variaveis locais    
        while(varAux){

            if(strcmp(varAux->name,p->key)==0){

                addTipoAux(p,varAux->type);
                return varAux->type;
            }
            varAux=varAux->nextNode;
        }
        param_table *parAux=fAux->params;                // verifica nos parametros   
        while(parAux){

            if(strcmp(parAux->name,p->key)==0){
                addTipoAux(p,parAux->type);
                return parAux->type;
            }
            parAux=parAux->nextNode;
        }
        func_table *fAux2=funcHead;                      // verifica nas variaveis globais   
        while(fAux2){
            if(!fAux2->isFunc){
                if(strcmp(fAux2->name,p->key)==0){
                    addTipoAux(p,fAux2->type);
                    return fAux2->type;
                }
            }
            
            fAux2=fAux2->nextNode;
        }
        addTipoAux(p,"undef");
        return "undef";
    
    }
    else if(strcmp(p->type,"Not")==0){
        // resultado sempre bool
        char *tipo1=statementExpressions(p->children,fAux);
        if(strcmp("bool",tipo1)!=0){
            syntax_error = 1;
            printf("Line %d, column %d: Operator ! cannot be applied to type %s\n",p->linha,p->coluna,tipo1);
        }
        addTipoAux(p,"bool");
        return "bool";
    }
    else if(strcmp(p->type,"Minus")==0||strcmp(p->type,"Plus")==0){
        char *tipo1=statementExpressions(p->children,fAux);
        if(strcmp("int",tipo1)==0){
            addTipoAux(p,"int");
            return "int";
        }
        else if(strcmp("float32",tipo1)==0){
            addTipoAux(p,"float32");
            return "float32";
        }
        else{
            if(strcmp(p->type,"Minus")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator - cannot be applied to type %s\n",p->linha,p->coluna,tipo1);
            }
            else{
                syntax_error = 1;
                printf("Line %d, column %d: Operator + cannot be applied to type %s\n",p->linha,p->coluna,tipo1);
            }
            addTipoAux(p,"undef");
            return "undef";
        }
    }
    else if(strcmp(p->type,"If")==0){
        char *tipo1=statementExpressions(p->children,fAux);
        
        if(strcmp(tipo1,"bool")!=0){
            syntax_error = 1;
            printf("Line %d, column %d: Incompatible type %s in if statement\n",p->children->linha,p->children->coluna,tipo1);

        }
        
        statementExpressions(p->children->brother,fAux);                 // bloco do if existe sempre
        statementExpressions(p->children->brother->brother,fAux);        // bloco do else existe sempre mesmo que o else nao

    
    }
    else if(strcmp(p->type,"For")==0){


        if(strcmp(p->children->type,"Block")==0){

            statementExpressions(p->children,fAux);
            return "null";
        }
        char *tipo1=statementExpressions(p->children,fAux);
        if(strcmp(tipo1,"bool")!=0){
            syntax_error = 1;
            printf("Line %d, column %d: Incompatible type %s in for statement\n",p->children->linha,p->children->coluna,tipo1);
        }
        statementExpressions(p->children->brother,fAux);
        
        return "null";
    
    }
    else if(strcmp(p->type,"Call")==0){
        func_table *fAux2=funcHead;      // verifica variaveis globais   
        while(fAux2){
            if(fAux2->isFunc){
                if(strcmp(fAux2->name,p->children->key)==0){
                    node* pAux=p->children->brother;
                    param_table *paAux=fAux2->params;
                    int params1=0;          // numero de parametros do no 
                    int params2=0;          // numero de parametros na arvore
                    int invalido=0;
                    char strAux[1024]="\0";
                    strcat(strAux,"(");
                    while(pAux||paAux){
                        char *tipo1;
                        if(pAux){        // precisa de percorrer todos os nos, mesmo sem parametros
                            tipo1=statementExpressions(pAux,fAux);
                            if(strcmp(strAux,"(")==0){
                                strcat(strAux,tipo1);
                            }
                            else{
                                strcat(strAux,",");
                                strcat(strAux,tipo1);
                            }
                        }
                        if(pAux&&paAux){
                            if(strcmp(tipo1,paAux->type)!=0){
                                invalido=1;
                            }
                        }
                        if(pAux){
                            params1++;
                            pAux=pAux->brother;
                        }
                        if(paAux){
                            paAux=paAux->nextNode;
                            params2++;
                        }
                    }
                    strcat(strAux,")");
                    if(params1==params2&&invalido==0){
                            // se estiver certo, adiciona o tipoAux e da return do seu tipo
                            addTipoAux(p->children,strAux);
                            char *tipo= fAux2->type;
                            addTipoAux(p,tipo);
                            return tipo ;
                    }
                    syntax_error = 1;
                    // simbolo nao encontrado
                    printf("Line %d, column %d: Cannot find symbol %s%s\n",p->children->linha,p->children->coluna,p->children->key,strAux);
                    addTipoAux(p->children,"undef");
                    char *tipo= "undef";
                    addTipoAux(p,tipo);
                    return tipo ;
                
                }
            }
            fAux2=fAux2->nextNode;
        }
        // se variavel nao existir
        node* pAux=p->children->brother;
        char strAux[1024]="\0";
        strcat(strAux,"(");
        while(pAux){
            char *tipo1=statementExpressions(pAux,fAux);
            if(strcmp(strAux,"(")==0){
                strcat(strAux,tipo1);
            }
            else{
                    strcat(strAux,",");
                    strcat(strAux,tipo1);
            }            
            pAux=pAux->brother;
        }
        strcat(strAux,")");
        syntax_error = 1;
        // simbolo nao encontrado
        printf("Line %d, column %d: Cannot find symbol %s%s\n",p->children->linha,p->children->coluna,p->children->key,strAux);
        addTipoAux(p->children,"undef");
        char *tipo= "undef";
        addTipoAux(p,tipo);
        return tipo ;
    }
    
    else if(strcmp(p->type,"Assign")==0){

        // verifica se a var existe e se o tipo que lhe esta a ser dado esta correto
        char *tipo1=statementExpressions(p->children,fAux);
        char *tipo2=statementExpressions(p->children->brother,fAux);
        if(strcmp(tipo1,"undef")==0||strcmp(tipo2,"undef")==0){
            syntax_error = 1;
            printf("Line %d, column %d: Operator = cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);   
            addTipoAux(p,"undef");
            return tipo1;            
        }

        if(strcmp(tipo1,tipo2)==0){
            addTipoAux(p,tipo1);
            return tipo1;
        }
        
        syntax_error = 1;
        printf("Line %d, column %d: Operator = cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
        addTipoAux(p,tipo1);
        return tipo1;
    
    }
    else if(strcmp(p->type,"Eq")==0||strcmp(p->type,"Lt")==0||strcmp(p->type,"Gt")==0||strcmp(p->type,"Ne")==0||strcmp(p->type,"Le")==0||strcmp(p->type,"Ge")==0){
        char *tipo1 =statementExpressions(p->children, fAux);
        char *tipo2 =statementExpressions(p->children->brother, fAux);

        if(strcmp(tipo1,"bool")==0&&strcmp(tipo2,"bool")==0){   
            if(strcmp(p->type,"Lt")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator < cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Gt")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator > cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Le")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator <= cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Ge")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator >= cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else{
                addTipoAux(p,tipo1);
            }
            addTipoAux(p,tipo1);
        
        }
        else if(strcmp(tipo1,"int")==0&&strcmp(tipo2,"int")==0){
            addTipoAux(p,"bool");

        }
        
        else if(strcmp(tipo1,"float32")==0&&strcmp(tipo2,"float32")==0){
            addTipoAux(p,"bool");

        }
        else if(strcmp(tipo1,"string")==0&&strcmp(tipo2,"string")==0){
            addTipoAux(p,"bool");

        }
        else{
            if(strcmp(p->type,"Eq")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator == cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Lt")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator < cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Gt")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator > cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Ne")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator != cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Le")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator <= cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Ge")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator >= cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            
            addTipoAux(p,"bool");    
  
        }
                
        return "bool";

    }
    else if(strcmp(p->type,"Add")==0||strcmp(p->type,"Sub")==0||strcmp(p->type,"Mul")==0||strcmp(p->type,"Div")==0||strcmp(p->type,"Mod")==0){
        char *tipo1 =statementExpressions(p->children, fAux);
        char *tipo2 =statementExpressions(p->children->brother, fAux);
    
        if((strcmp(tipo1,"bool")==0&&strcmp(tipo2,"bool")==0)||(strcmp(tipo1,"undef")==0&&strcmp(tipo2,"undef")==0)){
            if(strcmp(p->type,"Add")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator + cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Sub")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator - cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Mul")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator * cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Div")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator / cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Mod")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator %% cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            addTipoAux(p,tipo1);
            return "undef";
        }
        else if(strcmp(tipo1,tipo2)!=0){   
            if(strcmp(p->type,"Add")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator + cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Sub")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator - cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Mul")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator * cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Div")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator / cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Mod")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator %% cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            addTipoAux(p,"undef");
            return "undef";
        
        }
        else{
            if(strcmp(tipo1,"float32")==0){
                if(strcmp(p->type,"Mod")==0){
                    syntax_error = 1;
                    printf("Line %d, column %d: Operator %% cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
                    addTipoAux(p,"undef");
                    return "undef";
                }
                addTipoAux(p,"float32");
                return "float32";
            }
            if(strcmp(tipo1,"string")==0){
                if(strcmp(p->type,"Add")==0){
                    addTipoAux(p,"string");
                    return "string";               
                }
                else if(strcmp(p->type,"Sub")==0){
                    syntax_error = 1;
                    printf("Line %d, column %d: Operator - cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);         
                    addTipoAux(p,"undef");
                    return "undef";      
                }
                else if(strcmp(p->type,"Mul")==0){
                    syntax_error = 1;
                    printf("Line %d, column %d: Operator * cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2); 
                    addTipoAux(p,"undef");
                    return "undef";                
                }
                else if(strcmp(p->type,"Div")==0){
                    syntax_error = 1;
                    printf("Line %d, column %d: Operator / cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2); 
                    addTipoAux(p,"undef");
                    return "undef";                
                }
                else if(strcmp(p->type,"Mod")==0){
                    syntax_error = 1;
                    printf("Line %d, column %d: Operator %% cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2); 
                    addTipoAux(p,"undef");
                    return "undef";                
                }
            }
            addTipoAux(p,tipo1);
            return tipo1;
        }
        
        return tipo1;

    }
    else if(strcmp(p->type,"And")==0||strcmp(p->type,"Or")==0){
        char *tipo1 =statementExpressions(p->children, fAux);
        char *tipo2 =statementExpressions(p->children->brother, fAux);
        if(strcmp(tipo1,"bool")==0&&strcmp(tipo2,"bool")==0){           
            addTipoAux(p,tipo1);
            return "bool";
        
        }
        else {           
            if(strcmp(p->type,"And")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator && cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);               
            }
            else if(strcmp(p->type,"Or")==0){
                syntax_error = 1;
                printf("Line %d, column %d: Operator || cannot be applied to types %s, %s\n",p->linha,p->coluna,tipo1,tipo2);                           
            }
        
        }
        addTipoAux(p,"bool");
        return "bool";

    }
    else if(strcmp(p->type,"Block")==0){
        
        
        if(p->children){
            
            node *pAux = p->children;
            
            while(pAux){
                
                statementExpressions(pAux, fAux);
                pAux=pAux->brother;
            }
        }
            
    }
    return "null";
}

bool usedVar(node* p,char *varName){
    if(p==NULL){
        return 0;            // variavel nao existe
    }
    if(strcmp(p->type,"Id")==0){
        if(strcmp(p->key,varName)==0){
            return 1;        // variavel existe
        }
    }
    return (usedVar(p->children,varName) || usedVar(p->brother,varName)); // verifica em todos os nos filhos e irmaos
}