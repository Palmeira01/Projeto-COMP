%{
    #include "y.tab.h"
    #include "functions.h"
    
    int yylex(void);
    int yyparse(void);
    void yyerror(char *s);

    int stat_list=0;
    int coluna;
    int linha;
    int colunaAux;
    int linhaAux;
    char* straux;
    int syntax_error=0;

    node* root=NULL;
    node* rootAux=NULL;
    node* rootAux2=NULL;
%}


%union{
    char* key ;
    struct node* node;
};


//%define parse.error verbose

%token PACKAGE IF ELSE FOR RETURN PRINT PARSEINT FUNC CMDARGS
%token VAR INT FLOAT32 BOOL STRING
%token STAR DIV MINUS PLUS MOD
%token EQ NE GE GT LE LT AND OR NOT RSQ LSQ
%token ASSIGN COMMA LBRACE LPAR RBRACE RPAR SEMICOLON BLANKID
%token <key> RESERVED INTLIT REALLIT STRLIT ID 

%type <node> Program 
%type <node> Declarations DeclarationsAux
%type <node> VarDeclaration 
%type <node> VarSpec VarSpecAux
%type <node> Type 
%type <node> FuncDeclaration
%type <node> Parameters ParametersAux
%type <node> FuncBody
%type <node> VarsAndStatements 
%type <node> Statement StatementAux
%type <node> ParseArgs
%type <node> FuncInvocation FuncInvocationAux
%type <node> Expr

%type <node> Id
%type <node> ExprStrlit


%left COMMA
%right ASSIGN

%left OR 
%left AND
%left LT LE GT GE EQ NE
%left PLUS MINUS
%left STAR DIV MOD

%right NOT
%left LPAR RPAR LSQ RSQ

%nonassoc ELSE IF
%%

Program: PACKAGE ID SEMICOLON Declarations                                                              {root=newNode("Program",NULL);addChildren(root,$4);}
    ;


Declarations:                                                                                           {$$=NULL;}
    | DeclarationsAux                                                                                   {$$=$1;}
    ;

DeclarationsAux: DeclarationsAux VarDeclaration SEMICOLON                                               {$$=$1; addBrother($1,$2);}
    | DeclarationsAux FuncDeclaration SEMICOLON                                                         {$$=$1; addBrother($1,$2);}
    | FuncDeclaration SEMICOLON                                                                         {$$=$1;}
    | VarDeclaration SEMICOLON                                                                          {$$=$1;}
    ;


VarDeclaration: VAR VarSpec                                                                             {$$=$2;}
    | VAR LPAR VarSpec SEMICOLON RPAR                                                                   {$$=$3;}
    ;    

VarSpec: Id Type                                                                                        {$$=newNode("VarDecl",NULL);addChildren($$,$2);addBrother($2,$1);}  
    | Id VarSpecAux Type                                                                                {$$=newNode("VarDecl",NULL);addChildren($$,$3);addBrother($3,$1);addBrother($$,$2);rootAux2=$$->brother;
                                                                                                         while(rootAux2!=NULL&&strcmp(rootAux2->children->type,"faketype")==0){
                                                                                                             strcpy(rootAux2->children->type,$3->type);
                                                                                                             //rootAux2->type=$3->type;
                                                                                                             rootAux2=rootAux2->brother;
                                                                                                         }
                                                                                                        }  
    ;

VarSpecAux: COMMA Id VarSpecAux                                                                         {$$=newNode("VarDecl",NULL);rootAux=newNode("faketype",NULL);addBrother($$,$3);addChildren($$,rootAux);addBrother(rootAux,$2);}
    | COMMA Id                                                                                          {$$=newNode("VarDecl",NULL);rootAux=newNode("faketype",NULL);addChildren($$,rootAux);addBrother(rootAux,$2);}
    ;

Type: INT                                                                                               {$$=newNode("Int",NULL);}
    | FLOAT32                                                                                           {$$=newNode("Float32",NULL);}
    | STRING                                                                                            {$$=newNode("String",NULL);}
    | BOOL                                                                                              {$$=newNode("Bool",NULL);}
    ;

FuncDeclaration: FUNC Id LPAR RPAR FuncBody                                                             {$$=newNode("FuncDecl",NULL);rootAux= newNode("FuncHeader",NULL);addChildren($$,rootAux);addChildren(rootAux,$2);addBrother($2,newNode("FuncParams",NULL));addBrother(rootAux,$5);}
    | FUNC Id LPAR RPAR Type FuncBody                                                                   {$$=newNode("FuncDecl",NULL);rootAux= newNode("FuncHeader",NULL);addChildren($$,rootAux);addBrother(rootAux,$6);addChildren(rootAux,$2);addBrother($2,$5);addBrother($5,newNode("FuncParams",NULL));}
    | FUNC Id LPAR Parameters RPAR Type FuncBody                                                        {$$=newNode("FuncDecl",NULL);rootAux= newNode("FuncHeader",NULL);addChildren($$,rootAux);addBrother(rootAux,$7);addChildren(rootAux,$2);addBrother($6,$4);addBrother($2,$6);}
    | FUNC Id LPAR Parameters RPAR FuncBody                                                             {$$=newNode("FuncDecl",NULL);rootAux= newNode("FuncHeader",NULL);addChildren($$,rootAux);addBrother(rootAux,$6);addChildren(rootAux,$2);addBrother($2,$4);}
    ;

Parameters: ParametersAux                                                                               {$$=newNode("FuncParams",NULL);addChildren($$,$1);} 
    ;

ParametersAux: Id Type COMMA ParametersAux                                                              {$$=newNode("ParamDecl",NULL); addChildren($$,$2);addBrother($2,$1);addBrother($$,$4);}
    | Id Type                                                                                           {$$=newNode("ParamDecl",NULL); addChildren($$,$2);addBrother($2,$1);}
    ;

FuncBody: LBRACE VarsAndStatements RBRACE                                                               {$$=newNode("FuncBody",NULL);addChildren($$,$2);}
    ;

VarsAndStatements: VarsAndStatements SEMICOLON                                                          {$1=$1;}
    | VarsAndStatements VarDeclaration SEMICOLON                                                        {$$=$1; addBrother($1,$2);}
    | VarsAndStatements Statement SEMICOLON                                                             {$$=$1; addBrother($1,$2);}
    |                                                                                                   {$$=newNode("NULL",NULL);}
    ;

Statement: Id ASSIGN Expr                                                                               {$$=newNode("Assign",NULL);addChildren($$,$1);addBrother($1,$3);}
    | LBRACE  RBRACE                                                                                    {$$=newNode("NULL",NULL);}
    | LBRACE StatementAux RBRACE                                                                        {rootAux2=$2;int numStatements=0;
                                                                                                         while(rootAux2!=NULL){
                                                                                                             if(strcmp(rootAux2->type,"NULL")!=0){
                                                                                                                 numStatements++;
                                                                                                             }
                                                                                                             rootAux2=rootAux2->brother;
                                                                                                         }
                                                                                                         if(numStatements>=2){
                                                                                                             $$=newNode("Block",NULL);
                                                                                                             addChildren($$,$2);
                                                                                                         }
                                                                                                         else{
                                                                                                             $$=$2;
                                                                                                         }
                                                                                                        }
    | IF Expr LBRACE  RBRACE                                                                            {$$=newNode("If",NULL);addChildren($$,$2);rootAux=newNode("Block",NULL);addBrother($2,rootAux);addBrother(rootAux,newNode("Block",NULL));}
    | IF Expr LBRACE StatementAux RBRACE                                                                {$$=newNode("If",NULL);addChildren($$,$2);rootAux=newNode("Block",NULL);addBrother($2,rootAux);addChildren(rootAux,$4);addBrother(rootAux,newNode("Block",NULL));}
    | IF Expr LBRACE  RBRACE ELSE LBRACE RBRACE                                                         {$$=newNode("If",NULL);addChildren($$,$2);rootAux=newNode("Block",NULL);addBrother($2,rootAux);addBrother(rootAux,newNode("Block",NULL));}
    | IF Expr LBRACE  RBRACE ELSE LBRACE StatementAux RBRACE                                            {$$=newNode("If",NULL);addChildren($$,$2);rootAux=newNode("Block",NULL);rootAux2=newNode("Block",NULL);addBrother($2,rootAux);addBrother(rootAux,rootAux2);addChildren(rootAux2,$7);}
    | IF Expr LBRACE StatementAux RBRACE ELSE LBRACE RBRACE                                             {$$=newNode("If",NULL);addChildren($$,$2);rootAux=newNode("Block",NULL);addBrother($2,rootAux);addChildren(rootAux,$4);addBrother(rootAux,newNode("Block",NULL));}
    | IF Expr LBRACE StatementAux RBRACE ELSE LBRACE StatementAux RBRACE                                {$$=newNode("If",NULL);addChildren($$,$2);rootAux=newNode("Block",NULL);rootAux2=newNode("Block",NULL);addBrother($2,rootAux);addChildren(rootAux,$4);addBrother(rootAux,rootAux2);addChildren(rootAux2,$8);}
    | FOR LBRACE RBRACE                                                                                 {$$=newNode("For",NULL);addChildren($$,newNode("Block",NULL));}
    | FOR Expr LBRACE RBRACE                                                                            {$$=newNode("For",NULL);addChildren($$,$2);addBrother($2,newNode("Block",NULL));}
    | FOR Expr LBRACE StatementAux RBRACE                                                               {$$=newNode("For",NULL);addChildren($$,$2);rootAux=newNode("Block",NULL);addBrother($2,rootAux);addChildren(rootAux,$4);}
    | FOR LBRACE StatementAux RBRACE                                                                    {$$=newNode("For",NULL);rootAux=newNode("Block",NULL);addChildren($$,rootAux);addChildren(rootAux,$3);}
    | RETURN                                                                                            {$$=newNode("Return",NULL);}
    | RETURN Expr                                                                                       {$$=newNode("Return",NULL);addChildren($$,$2);}
    | FuncInvocation                                                                                    {$$=newNode("Call",NULL);addChildren($$,$1);}
    | ParseArgs                                                                                         {$$=$1;}
    | PRINT LPAR ExprStrlit RPAR                                                                        {$$=newNode("Print",NULL);addChildren($$,$3);}
    | error                                                                                             {$$=newNode("Error",NULL);syntax_error=1;}
    ;

StatementAux: StatementAux Statement SEMICOLON                                                          {$$=$1;addBrother($1,$2);}
    | Statement SEMICOLON                                                                               {$$=$1;}
    ;

ExprStrlit: Expr                                                                                        {$$=$1;}
    | STRLIT                                                                                            {$$=newNode("StrLit",$1);}
    ;

ParseArgs: Id COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR                              {$$=newNode("ParseArgs",NULL);addChildren($$,$1);addBrother($1,$9);}
    | Id COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                                                  {$$=newNode("ParseArgs",NULL);addChildren($$,$1);addBrother($1,newNode("Error",NULL));syntax_error=1;}
    ;

FuncInvocation: Id LPAR error RPAR                                                                      {$$=$1;addBrother($1,newNode("Error",NULL));syntax_error=1;}
    | Id LPAR RPAR                                                                                      {$$=$1;}
    | Id LPAR Expr RPAR                                                                                 {$$=$1;addBrother($1,$3);}
    | Id LPAR Expr FuncInvocationAux RPAR                                                               {$$=$1;addBrother($1,$3);addBrother($3,$4);}
    ;

FuncInvocationAux: FuncInvocationAux COMMA Expr                                                         {$$=$1;addBrother($1,$3);}
    | COMMA Expr                                                                                        {$$=$2;}
    ;

Id: ID                                                                                                  {$$=newNode("Id",yylval.key);}
    ;

Expr: INTLIT                                                                                            {$$=newNode("IntLit",$1);}
    | REALLIT                                                                                           {$$=newNode("RealLit",$1);}
    | Id                                                                                                {$$=$1;}
    | FuncInvocation                                                                                    {$$=newNode("Call",NULL);addChildren($$,$1);}
    | LPAR Expr RPAR                                                                                    {$$=$2;}
    | NOT Expr                                                                                          {$$=newNode("Not",NULL);addChildren($$,$2);}
    | MINUS Expr          %prec NOT                                                                     {$$=newNode("Minus",NULL);addChildren($$,$2);}
    | PLUS Expr           %prec NOT                                                                     {$$=newNode("Plus",NULL);addChildren($$,$2);}
    | Expr OR Expr                                                                                      {$$=newNode("Or",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr AND Expr                                                                                     {$$=newNode("And",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr LT Expr                                                                                      {$$=newNode("Lt",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr GT Expr                                                                                      {$$=newNode("Gt",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr EQ Expr                                                                                      {$$=newNode("Eq",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr NE Expr                                                                                      {$$=newNode("Ne",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr LE Expr                                                                                      {$$=newNode("Le",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr GE Expr                                                                                      {$$=newNode("Ge",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr PLUS Expr                                                                                    {$$=newNode("Add",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr MINUS Expr                                                                                   {$$=newNode("Sub",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr STAR Expr                                                                                    {$$=newNode("Mul",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr DIV Expr                                                                                     {$$=newNode("Div",NULL);addChildren($$,$1);addBrother($1,$3);}
    | Expr MOD Expr                                                                                     {$$=newNode("Mod",NULL);addChildren($$,$1);addBrother($1,$3);}
    | LPAR  error RPAR                                                                                  {$$=newNode("Error",NULL);syntax_error=1;}
    ;

%%


void yyerror(char *string){
    int i=0;
    while(straux[i]!='\0'){
        i++;
    }
    if(strcmp(yylval.key,"\n")!=0 && strcmp(yylval.key,"\r")!=0 && strcmp(yylval.key,"\r\n")!=0 && strcmp(yylval.key,"\n\r")!=0){
        if(strcmp(yylval.key,"EOF")==0){
            printf("Line %d, column %d: %s: %s\n",linha,coluna,string,straux);
            return;
        }
        else{
            i=0;
            while(yylval.key[i]!='\0'){
                i++;
            }
            printf("Line %d, column %d: %s: %s\n",linha,coluna-i,string,yylval.key);
        }
    }
    else{
        printf("Line %d, column %d: %s: \n\n",linhaAux,colunaAux-i,string);
    }
}