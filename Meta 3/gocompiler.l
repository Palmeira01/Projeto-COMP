%x COMMENT_1 COMMENT_2 STRINGLIT  

%{
  /*
  Paulo Meira - 2019215095
  André Graça - 2019215067
  */
#include <ctype.h>
#include <stdbool.h>
#include "functions.h"
#include "symbol_table.h"
#include "y.tab.h"

#define SEND_TOKEN(...)\
        if (parse == 1){\
                straux=yytext;yylval.key = (char*) strdup(yytext);\
                return __VA_ARGS__;\
        }

#define SEND_TOKEN2(...)\
        if (parse == 1){\
                yylval.node = newNode("NULL",NULL,linha,coluna-strlen(yytext));\
                return __VA_ARGS__;\
        }

#define SEND_STRLIT(...)\
        if (parse == 1){\
                strcpy(bufferAux,"\"");\
                strcat(bufferAux,buffer);\
                strcat(bufferAux, "\"");\
                straux=bufferAux;yylval.key = (char*) strdup(bufferAux);\
                return STRLIT;\
        }
    
// Error Flags
extern int syntax_error; 
extern node* root;

int linha = 1;
int coluna = 1;
int linhaAux = 1;
int colunaAux = 1;
int ctrl = 0;
int lerro = 0;
int cerro = 0;
int check = 0;
int semicolon = 0;
int str2 = 0;
char buffer[512];
char bufferAux[512];
char *str;
int parse = 0;
int yyparse(void);
char *straux;

%}
letra             [A-Za-z_]
numero            [0-9]+
numero_octal      [0-7]+
string            ([a-zA-Z]|{numero}|"."|","|"("|")"|"-"|"_"|";"|":"|"!"|"?"|"<"|">"|"=")+
reserved          ("++"|"--"|"break"|"default"|"interface"|"select"|"case"|"defer"|"go"|"map"|"struct"|"chan"|"goto"|"switch"|"const"|"fallthrough"|"range"|"type"|"continue"|"import")
escaped           ("\\"("f"|"n"|"r"|"t"|"\\"|"\"")) 

%%



{reserved}                      {semicolon=0;if(ctrl == 1){printf("RESERVED(%s)\n",yytext);}coluna=coluna+strlen(yytext);SEND_TOKEN(RESERVED);}
";"                             {semicolon=0;if(ctrl == 1){printf("SEMICOLON\n");}coluna++;SEND_TOKEN(SEMICOLON);}
","                             {semicolon=0;if(ctrl == 1){printf("COMMA\n");}coluna++;SEND_TOKEN2(COMMA);}
"_"                             {semicolon=0;if(ctrl == 1){printf("BLANKID\n");}coluna++;SEND_TOKEN(BLANKID);}
"="                             {semicolon=0;if(ctrl == 1){printf("ASSIGN\n");}coluna++;SEND_TOKEN2(ASSIGN);}
"*"                             {semicolon=0;if(ctrl == 1){printf("STAR\n");}coluna++;SEND_TOKEN2(STAR);}
"/"                             {semicolon=0;if(ctrl == 1){printf("DIV\n");}coluna++;SEND_TOKEN2(DIV);}
"-"                             {semicolon=0;if(ctrl == 1){printf("MINUS\n");}coluna++;SEND_TOKEN2(MINUS);}
"+"                             {semicolon=0;if(ctrl == 1){printf("PLUS\n");}coluna++;SEND_TOKEN2(PLUS);}
"=="                            {semicolon=0;if(ctrl == 1){printf("EQ\n");}coluna=coluna+2;SEND_TOKEN2(EQ);}
">="                            {semicolon=0;if(ctrl == 1){printf("GE\n");}coluna=coluna+2;SEND_TOKEN2(GE);}
">"                             {semicolon=0;if(ctrl == 1){printf("GT\n");}coluna++;SEND_TOKEN2(GT);}
"{"                             {semicolon=0;if(ctrl == 1){printf("LBRACE\n");}coluna++;SEND_TOKEN(LBRACE);}
"<="                            {semicolon=0;if(ctrl == 1){printf("LE\n");}coluna=coluna+2;SEND_TOKEN2(LE);}
"("                             {semicolon=0;if(ctrl == 1){printf("LPAR\n");}coluna++;SEND_TOKEN(LPAR);}
"["                             {semicolon=0;if(ctrl == 1){printf("LSQ\n");}coluna++;SEND_TOKEN(LSQ);}
"<"                             {semicolon=0;if(ctrl == 1){printf("LT\n");}coluna++;SEND_TOKEN2(LT);}
\%                              {semicolon=0;if(ctrl == 1){printf("MOD\n");}coluna++;SEND_TOKEN2(MOD);}
"!="                            {semicolon=0;if(ctrl == 1){printf("NE\n");}coluna=coluna+2;SEND_TOKEN2(NE);}
"!"                             {semicolon=0;if(ctrl == 1){printf("NOT\n");}coluna++;SEND_TOKEN2(NOT);}
"&&"                            {semicolon=0;if(ctrl == 1){printf("AND\n");}coluna=coluna+2;SEND_TOKEN2(AND);}
"||"                            {semicolon=0;if(ctrl == 1){printf("OR\n");}coluna=coluna+2;SEND_TOKEN2(OR);}
"}"                             {semicolon=1;if(ctrl == 1){printf("RBRACE\n");}coluna++;SEND_TOKEN(RBRACE);}
")"                             {semicolon=1;if(ctrl == 1){printf("RPAR\n");}coluna++;SEND_TOKEN(RPAR);}
"]"                             {semicolon=1;if(ctrl == 1){printf("RSQ\n");}coluna++;SEND_TOKEN(RSQ);}
"package"                       {semicolon=0;if(ctrl == 1){printf("PACKAGE\n");}coluna=coluna+7;SEND_TOKEN(PACKAGE);}
"return"                        {semicolon=1;if(ctrl == 1){printf("RETURN\n");}coluna=coluna+6;SEND_TOKEN2(RETURN);}
"else"                          {semicolon=0;if(ctrl == 1){printf("ELSE\n");}coluna=coluna+4;SEND_TOKEN(ELSE);}
"for"                           {semicolon=0;if(ctrl == 1){printf("FOR\n");}coluna=coluna+3;SEND_TOKEN2(FOR);}
"if"                            {semicolon=0;if(ctrl == 1){printf("IF\n");}coluna=coluna+2;SEND_TOKEN2(IF);}
"var"                           {semicolon=0;if(ctrl == 1){printf("VAR\n");}coluna=coluna+3;SEND_TOKEN(VAR);}
"int"                           {semicolon=0;if(ctrl == 1){printf("INT\n");}coluna=coluna+3;SEND_TOKEN(INT);}
"float32"                       {semicolon=0;if(ctrl == 1){printf("FLOAT32\n");}coluna=coluna+7;SEND_TOKEN(FLOAT32);}
"bool"                          {semicolon=0;if(ctrl == 1){printf("BOOL\n");}coluna=coluna+4;SEND_TOKEN(BOOL);}
"string"                        {semicolon=0;if(ctrl == 1){printf("STRING\n");}coluna=coluna+6;SEND_TOKEN(STRING);}
"fmt.Println"                   {semicolon=0;if(ctrl == 1){printf("PRINT\n");}coluna=coluna+11;SEND_TOKEN(PRINT);}
"strconv.Atoi"                  {semicolon=0;if(ctrl == 1){printf("PARSEINT\n");}coluna=coluna+strlen(yytext);SEND_TOKEN2(PARSEINT);}
"func"                          {semicolon=0;if(ctrl == 1){printf("FUNC\n");}coluna=coluna+4;SEND_TOKEN(FUNC);}
"os.Args"                       {semicolon=0;if(ctrl == 1){printf("CMDARGS\n");}coluna=coluna+7;SEND_TOKEN(CMDARGS);}
"//"                            {BEGIN COMMENT_1;coluna=coluna+2;}
"/*"                            {BEGIN COMMENT_2;lerro=linha;cerro=coluna;coluna=coluna+2;}

{letra}({letra}|[0-9])*                                                   {if(ctrl == 1){printf("ID(%s)\n", yytext);}semicolon=1;coluna=coluna+strlen(yytext);SEND_TOKEN(ID);}

"\""                                                                      {str2=0;BEGIN STRINGLIT;lerro=linha;cerro=coluna;coluna++;check=0;str=buffer;}

"0"({numero}*[8-9]+{numero}*)                                             {semicolon=0;printf("Line %d, column %d: invalid octal constant (%s)\n",linha,coluna,yytext);coluna=coluna+strlen(yytext);}
"0"{numero_octal}|(("0x"|"0X")([a-f]+|[A-F]+|{numero})+)|{numero}         {if(ctrl == 1){printf("INTLIT(%s)\n", yytext);}semicolon=1;coluna=coluna+strlen(yytext);SEND_TOKEN(INTLIT);}

(({numero}+"."?{numero}*)(("E"|"e")("+"|"-")?{numero})?)                  {if(ctrl == 1){printf("REALLIT(%s)\n", yytext);}semicolon=1;coluna=coluna+strlen(yytext);SEND_TOKEN(REALLIT);}
(({numero}*"."?{numero}+)(("E"|"e")("+"|"-")?{numero})?)                  {if(ctrl == 1){printf("REALLIT(%s)\n", yytext);}semicolon=1;coluna=coluna+strlen(yytext);SEND_TOKEN(REALLIT);}

\r  			                                  	                            {semicolon=1;coluna=1;} 
\n|\r\n  			                                                            {linhaAux=linha;colunaAux=coluna;
                                                                          linha++;coluna=1;
                                                                          if(semicolon==1){
                                                                            if(ctrl == 1){
                                                                              printf("SEMICOLON\n");
                                                                            }
                                                                            semicolon=0;
                                                                            if(parse == 1){
                                                                              straux="";yylval.key = (char*) strdup(yytext);
                                                                              return SEMICOLON;
                                                                            }
                                                                          }
                                                                          } 


" "|\t                                                                    {coluna=coluna+strlen(yytext);straux=yytext;} 
.	            			                                                      {semicolon=0;printf("Line %d, column %d: illegal character (%c)\n",linha,coluna,yytext[0]);coluna=coluna+strlen(yytext);}

<COMMENT_1><<EOF>>                                                        { if(semicolon==1){
                                                                              semicolon = 0;
                                                                              if(ctrl == 1){
                                                                                printf("SEMICOLON\n");
                                                                              }
                                                                              if(parse == 1){
                                                                                return SEMICOLON;
                                                                              }
                                                                            }
                                                                            yylval.key = (char*) strdup("EOF");
                                                                            yyterminate();
                                                                            return EOF;
                                                                          }

<COMMENT_1>\r							                                                {semicolon=1;BEGIN 0;coluna = 1;}
<COMMENT_1>(\n|\r\n)                   				                            {linha++;coluna = 1;if(semicolon==1){semicolon=0;if(parse == 1){straux="";yylval.key = (char*) strdup(yytext);return SEMICOLON;}if(ctrl == 1){printf("SEMICOLON\n");}}BEGIN 0;}
<COMMENT_1>.                                  			                      {coluna=coluna+strlen(yytext);}

<COMMENT_2><<EOF>>     			                                              {printf("Line %d, column %d: unterminated comment\n",lerro,cerro);return 0;}
<COMMENT_2>\r  							                                              {semicolon=1;coluna = 1;}
<COMMENT_2>(\n|\r\n)                            		                      {linha++;coluna = 1;if(semicolon==1){semicolon=0;if(parse == 1){straux="";yylval.key = (char*) strdup(yytext);return SEMICOLON;}if(ctrl == 1){printf("SEMICOLON\n");}}}  
<COMMENT_2>"*/"                               			                      {BEGIN 0;coluna=coluna+2;}
<COMMENT_2>.                                  			                      {coluna=coluna+strlen(yytext);}

<STRINGLIT>\\                                                      {str2=1;printf("Line %d, column %d: invalid escape sequence (\\)\n",linha,coluna);BEGIN 0;linha++;coluna=1;semicolon=0;}                   
<STRINGLIT>\\(f|n|r|t|\\|\")                                       {check=1;coluna=coluna+strlen(yytext); for(int i = 0;i < strlen(yytext); i++) *str++ = yytext[i];} 
<STRINGLIT>\\.                                                     {str2=1;printf("Line %d, column %d: invalid escape sequence (%s)\n",linha,coluna,yytext);coluna=coluna+strlen(yytext);}                   
<STRINGLIT>\"                                                      {*str=0;if(ctrl == 1 && str2 == 0){if(check==1){printf("STRLIT(\"%s\")\n", buffer);}if(check==0){printf("STRLIT(\"\")\n");}}if(str2==0){semicolon=1;}if(str2==1){semicolon=0;}BEGIN 0;coluna++;if(str2==0){SEND_STRLIT(STRLIT,buffer);}}
<STRINGLIT>(\n|\r\n|\r)                                            {printf("Line %d, column %d: unterminated string literal\n",lerro,cerro);BEGIN 0;linha++;coluna = 1;semicolon=0;}  
<STRINGLIT><<EOF>>                                                 {printf("Line %d, column %d: unterminated string literal\n",lerro,cerro);return 0;}  
<STRINGLIT>.                                                       {check=1;coluna=coluna+strlen(yytext); *str++ = *yytext;} 

<<EOF>>                                                         { if(semicolon==1){
                                                                    semicolon = 0;
                                                                    if(ctrl == 1){
                                                                      printf("SEMICOLON\n");
                                                                    }
                                                                    if(parse == 1){
                                                                      return SEMICOLON;
                                                                    }
                                                                  }
                                                                  yylval.key = (char*) strdup("EOF");
                                                                  yyterminate();
                                                                  return EOF;
                                                                }


%%
int main(int argc, char* argv[]){
  if (argc == 1){
    parse=1;
    yyparse();
    if(syntax_error==0){
      // só analise semantica
      criaTabelasSimbolos(root);
      if (syntax_error == 0){
        printTables();
      }
    }
  }
  else{
    if (strcmp(argv[1],"-l")==0){
      ctrl = 1;             //emite os tokens e as mensagens de erro
      yylex();
    }
    else if (strcmp(argv[1],"-t")==0){
      parse=1;
      yyparse();
      if(syntax_error==0){
        printTree(root,0);
      }
    }
    else if (strcmp(argv[1],"-s")==0){
      parse = 1;
      yyparse();
      if (syntax_error == 0){

        criaTabelasSimbolos(root);
        if (syntax_error == 0){
          printTables();
          printTree(root,0);
        }
      }
    }
  }
  
  return 0;
}


int yywrap() {
  return 1;
}

