
%{
    #include "trabalho.tab.h"

%}
%option nounput
%option noinput
%option noyywrap


M [a-zA-Z0-9]{3,}
Q [0-9][0-9]*
LISTA \([a-zA-Z0-9]{5},(0*)[1-9][0-9]*\)(,[ ]\([a-zA-Z0-9]{5},(0*)[1-9][0-9]*\))*
I (B|T|M|(T,(B|M))|(B,(T|M))|(M,(T|B))|(B,T,M)|(T,M,B)|(M,B,T)|(T,B,M)|(M,T,B)|(B,M,T))
LOCALIZACAO ([ A-Za-z]{7,})

%%

INICIO-DAS-INSTRUCOES { return INICIO_DAS_INSTRUCOES; }
FINAL-DAS-INSTRUCOES  { return FINAL_DAS_INSTRUCOES; }

MANUTENCAO  { yylval.letras=strdup(yytext);return MANUTENCAO; }
CARREGA-BATERIA  { return CARREGA_BATERIA; }
ENTREGA     { return ENTREGA; }
RECOLHE     { return RECOLHE; }
INIT-ESTADO { return INIT_ESTADO; }
ESTADO      {return ESTADO;}

{LOCALIZACAO} {yylval.letras=strdup(yytext);return LOCALIZACAO;}
\(\[{LISTA}\]\)       {yylval.letras=strdup(yytext);return LISTA;}
\[{LISTA}\]|"#"       {yylval.letras=strdup(yytext);return LISTA_1;}

{Q}           {yylval.inteiro=atoi(yytext);return Q;}
{M}           {yylval.letras=strdup(yytext);return M;}
{I}            {yylval.letras=strdup(yytext);return I;}
[\{\}\;\(\)\,]     {return yytext[0];}

[ \t \n \r]+


.                   { printf("Erro lexico: simbolo desconhecido ->%s<- \n ", yytext);return yytext[0];}
<<EOF>>             { return 0;}
%%
