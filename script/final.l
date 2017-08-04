%{
    #include<iostream>
    #include<cstdlib>
    #include<stack>
    #include "AST.h"
    #include "final.tab.hh"
    extern std::stack<ASTType> stack_ASTtype;
    extern std::stack<ASTType> stack_Operant;
%}
separator  [ \t\n\r]
letter     [a-z]
digit      [0-9]
number     0|[1-9]{digit}*|-[1-9]{digit}*
ID         {letter}({letter}|{digit}|"-")*
bool-val   ("#t"|"#f")
%%
<<EOF>>      { return(0); }
{separator}  { }
"mod"        { stack_ASTtype.push(AST_MOD); return(MOD); }
"and"        { stack_ASTtype.push(AST_AND); return(AND); }
"or"         { stack_ASTtype.push(AST_OR); return(OR); }
"not"        { stack_ASTtype.push(AST_NOT); return(NOT); }
"define"     { stack_ASTtype.push(AST_DEF); return(DEFINE); }
"fun"        { stack_ASTtype.push(AST_FUN_EXP); return(FUN); }
"if"         { stack_ASTtype.push(AST_IF); return(IF); }
"print-num"  { stack_ASTtype.push(AST_PNUM); return(PRINT_NUM); }
"print-bool" { stack_ASTtype.push(AST_PBOOL); return(PRINT_BOOL); }
{bool-val}   { 
             if(strcmp(yytext, "#t")==0){
                 yylval.boolean = 1;
                return(BOOL);
             }else if(strcmp(yytext, "#f") == 0){
                 yylval.boolean = 0;
                return(BOOL);
             } }
{number}     { yylval.num = atoi(yytext); return(NUM); }
{ID}         { yylval.id = strdup(yytext); return(ID); }
"+"          { stack_ASTtype.push(AST_PLUS); return(yytext[0]); }
"-"          { stack_ASTtype.push(AST_MINUS); return(yytext[0]); }
"*"          { stack_ASTtype.push(AST_MUL); return(yytext[0]); }
"/"          { stack_ASTtype.push(AST_DIV); return(yytext[0]); }
"="          { stack_ASTtype.push(AST_EQUAL); return(yytext[0]); }
">"          { stack_ASTtype.push(AST_GREATER); return(yytext[0]); }
"<"          { stack_ASTtype.push(AST_SMALLER); return(yytext[0]); }
.            { return(yytext[0]); }
%%