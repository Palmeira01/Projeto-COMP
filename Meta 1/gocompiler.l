%X COMMENT_1 COMMENT_2 STRING  
%{
/*
  Paulo Meira - 2019215095
  André Graça - 2019215067
  */
#include <ctype.h>
int linha = 1;
int coluna = 1;
int ctrl = 0;
int lerro = 0;
int cerro = 0;
int check = 0;
int semicolon = 0;
int str2 = 0;
char buffer[200];
char *string;

%}
letra             [A-Za-z_]
numero            [0-9]+
numero_octal      [0-7]+
string            ([a-zA-Z]|{numero}|"."|","|"("|")"|"-"|"_"|";"|":"|"!"|"?"|"<"|">"|"=")+
reserved          ("++"|"--"|"break"|"default"|"interface"|"select"|"case"|"defer"|"go"|"map"|"struct"|"chan"|"goto"|"switch"|"const"|"fallthrough"|"range"|"type"|"continue"|"import")
escaped           ("\\"("f"|"n"|"r"|"t"|"\\"|"\"")) 

%%

{reserved}                      {if(ctrl == 1){semicolon=0;printf("RESERVED(%s)\n",yytext);}coluna=coluna+strlen(yytext);}
";"                             {if(ctrl == 1){semicolon=0;printf("SEMICOLON\n");}coluna++;}
","                             {if(ctrl == 1){semicolon=0;printf("COMMA\n");}coluna++;}
"_"                             {if(ctrl == 1){semicolon=0;printf("BLANKID\n");}coluna++;}
"="                             {if(ctrl == 1){semicolon=0;printf("ASSIGN\n");}coluna++;}
"*"                             {if(ctrl == 1){semicolon=0;printf("STAR\n");}coluna++;}
"/"                             {if(ctrl == 1){semicolon=0;printf("DIV\n");}coluna++;}
"-"                             {if(ctrl == 1){semicolon=0;printf("MINUS\n");}coluna++;}
"+"                             {if(ctrl == 1){semicolon=0;printf("PLUS\n");}coluna++;}
"=="                            {if(ctrl == 1){semicolon=0;printf("EQ\n");}coluna=coluna+2;}
">="                            {if(ctrl == 1){semicolon=0;printf("GE\n");}coluna=coluna+2;}
">"                             {if(ctrl == 1){semicolon=0;printf("GT\n");}coluna++;}
"{"                             {if(ctrl == 1){semicolon=0;printf("LBRACE\n");}coluna++;}
"<="                            {if(ctrl == 1){semicolon=0;printf("LE\n");}coluna=coluna+2;}
"("                             {if(ctrl == 1){semicolon=0;printf("LPAR\n");}coluna++;}
"["                             {if(ctrl == 1){semicolon=0;printf("LSQ\n");}coluna++;}
"<"                             {if(ctrl == 1){semicolon=0;printf("LT\n");}coluna++;}
\%                              {if(ctrl == 1){semicolon=0;printf("MOD\n");}coluna++;}
"!="                            {if(ctrl == 1){semicolon=0;printf("NE\n");}coluna=coluna+2;}
"!"                             {if(ctrl == 1){semicolon=0;printf("NOT\n");}coluna++;}
"&&"                            {if(ctrl == 1){semicolon=0;printf("AND\n");}coluna=coluna+2;}
"||"                            {if(ctrl == 1){semicolon=0;printf("OR\n");}coluna=coluna+2;}
"}"                             {if(ctrl == 1){semicolon=1;printf("RBRACE\n");}coluna++;}
")"                             {if(ctrl == 1){semicolon=1;printf("RPAR\n");}coluna++;}
"]"                             {if(ctrl == 1){semicolon=1;printf("RSQ\n");}coluna++;}
"package"                       {if(ctrl == 1){semicolon=0;printf("PACKAGE\n");}coluna=coluna+7;}
"return"                        {if(ctrl == 1){semicolon=1;printf("RETURN\n");}coluna=coluna+6;}
"else"                          {if(ctrl == 1){semicolon=0;printf("ELSE\n");}coluna=coluna+4;}
"for"                           {if(ctrl == 1){semicolon=0;printf("FOR\n");}coluna=coluna+3;}
"if"                            {if(ctrl == 1){semicolon=0;printf("IF\n");}coluna=coluna+2;}
"var"                           {if(ctrl == 1){semicolon=0;printf("VAR\n");}coluna=coluna+3;}
"int"                           {if(ctrl == 1){semicolon=0;printf("INT\n");}coluna=coluna+3;}
"float32"                       {if(ctrl == 1){semicolon=0;printf("FLOAT32\n");}coluna=coluna+7;}
"bool"                          {if(ctrl == 1){semicolon=0;printf("BOOL\n");}coluna=coluna+4;}
"string"                        {if(ctrl == 1){semicolon=0;printf("STRING\n");}coluna=coluna+6;}
"fmt.Println"                   {if(ctrl == 1){semicolon=0;printf("PRINT\n");}coluna=coluna+11;}
"strconv.Atoi"                  {if(ctrl == 1){semicolon=0;printf("PARSEINT\n");}coluna=coluna+2;}
"func"                          {if(ctrl == 1){semicolon=0;printf("FUNC\n");}coluna=coluna+4;}
"os.Args"                       {if(ctrl == 1){semicolon=0;printf("CMDARGS\n");}coluna=coluna+7;}
"//"                            {BEGIN COMMENT_1;coluna=coluna+2;}
"/*"                            {BEGIN COMMENT_2;lerro=linha;cerro=coluna;coluna=coluna+2;}

{letra}({letra}|[0-9])*                                                   {if(ctrl == 1){printf("ID(%s)\n", yytext);}semicolon=1;coluna=coluna+strlen(yytext);}

"\""                                                                      {str2=0;BEGIN STRING;lerro=linha;cerro=coluna;coluna++;check=0;string=buffer;}

"0"({numero}*[8-9]+{numero}*)                                             {semicolon=0;printf("Line %d, column %d: invalid octal constant (%s)\n",linha,coluna,yytext);coluna=coluna+strlen(yytext);}
"0"{numero_octal}|(("0x"|"0X")([a-f]+|[A-F]+|{numero})+)|{numero}         {if(ctrl == 1){printf("INTLIT(%s)\n", yytext);}semicolon=1;coluna=coluna+strlen(yytext);}

(({numero}+"."?{numero}*)(("E"|"e")("+"|"-")?{numero})?)                   {if(ctrl == 1){printf("REALLIT(%s)\n", yytext);}semicolon=1;coluna=coluna+strlen(yytext);}
(({numero}*"."?{numero}+)(("E"|"e")("+"|"-")?{numero})?)                   {if(ctrl == 1){printf("REALLIT(%s)\n", yytext);}semicolon=1;coluna=coluna+strlen(yytext);}

\r  			                                  	{semicolon=1;coluna=1;} 
\n|\r\n  			                                {if(ctrl == 1 && semicolon==1){printf("SEMICOLON\n");}semicolon=0;linha++;coluna=1;} 
" "|\t                                                          {coluna++;} 
.	            			                        {semicolon=0;printf("Line %d, column %d: illegal character (%c)\n",linha,coluna,yytext[0]);coluna=coluna+strlen(yytext);}

<COMMENT_1><<EOF>>                                              {if(ctrl == 1 && semicolon==1){printf("SEMICOLON\n");}return 0;}
<COMMENT_1>\r							{semicolon=1;BEGIN 0;coluna = 1;}
<COMMENT_1>(\n|\r\n)                   				{if(ctrl == 1 && semicolon==1){printf("SEMICOLON\n");}BEGIN 0;semicolon=0;linha++;coluna = 1;}
<COMMENT_1>.                                  			{coluna=coluna+strlen(yytext);}

<COMMENT_2><<EOF>>     			                        {printf("Line %d, column %d: unterminated comment\n",lerro,cerro);return 0;}
<COMMENT_2>\r  							{semicolon=1;coluna = 1;}
<COMMENT_2>(\n|\r\n)                            		{if(ctrl == 1 && semicolon==1){printf("SEMICOLON\n");}semicolon=0;linha++;coluna = 1;}  
<COMMENT_2>"*/"                               			{BEGIN 0;coluna=coluna+2;}
<COMMENT_2>.                                  			{coluna=coluna+strlen(yytext);}
           
<STRING>\\                                                      {str2=1;printf("Line %d, column %d: invalid escape sequence (\\)\n",linha,coluna);BEGIN 0;linha++;coluna=1;semicolon=0;}                   
<STRING>\\(f|n|r|t|\\|\")                                       {check=1;coluna=coluna+strlen(yytext); for(int i = 0;i < strlen(yytext); i++) *string++ = yytext[i];} 
<STRING>\\.                                                     {str2=1;printf("Line %d, column %d: invalid escape sequence (%s)\n",linha,coluna,yytext);coluna=coluna+strlen(yytext);}                   
<STRING>\"                                                      {*string=0;if(ctrl == 1 && str2 == 0){if(check==1){printf("STRLIT(\"%s\")\n", buffer);}if(check==0){printf("STRLIT(\"\")\n");}}if(str2==0){semicolon=1;}if(str2==1){semicolon=0;}BEGIN 0;coluna++;}
<STRING>(\n|\r\n|\r)                                            {printf("Line %d, column %d: unterminated string literal\n",lerro,cerro);BEGIN 0;linha++;coluna = 1;semicolon=0;}  
<STRING><<EOF>>                                                 {printf("Line %d, column %d: unterminated string literal\n",lerro,cerro);return 0;}  
<STRING>.                                                       {check=1;coluna=coluna+strlen(yytext); *string++ = *yytext;} 

<<EOF>>                                                         {if(ctrl == 1 && semicolon==1){printf("SEMICOLON\n");}return 0;}

%%


int main(int argc, char* argv[]){
  if(argc > 1 && strcmp(argv[1],"-l")==0){
    ctrl = 1;             //emite os tokens e as mensagens de erro
  }
  yylex();
  return 0;
}

int yywrap() {
  return 1;
}