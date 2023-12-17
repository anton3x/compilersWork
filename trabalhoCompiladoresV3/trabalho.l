
%{
    #include "trabalho.tab.h"
%}
%option nounput
%option noinput
%option noyywrap


L [A-Z]{2}(0*)([1-9]|[1-9][0-9]|100)
M [a-zA-Z0-9]{5}
Q [0-9][0-9]*
LISTA \([0-9A-Za-z]{5},(0*)[1-9][0-9]*\)(,[ ]\([0-9A-Za-z]{5},(0*)[1-9][0-9]*\))*
I (B|M|T)
LOCALIZACAO ([ A-Za-z]{7,})

%%

INICIO-DAS-INSTRUCOES { return INICIO_DAS_INSTRUCOES; }
FINAL-DAS-INSTRUCOES  { return FINAL_DAS_INSTRUCOES; }

MANUTENCAO\([0-2]\)  { yylval.letras=strdup(yytext);return MANUTENCAO; }
CARREGA-BATERIA  { return CARREGA_BATERIA; }
ENTREGA     { return ENTREGA; }
RECOLHE     { return RECOLHE; }
INIT-ESTADO { return INIT_ESTADO; }

\({LOCALIZACAO},{Q},\(\[{LISTA}\]\),{Q}\)  {yylval.letras=strdup(yytext);return LOCALIZACAO;}
\(\[{LISTA}\]\)        { yylval.letras=strdup(yytext);return LISTA;}
\({L},{M},{Q}\)        {yylval.letras=strdup(yytext); return LMQ;}
{Q}            {yylval.inteiro=atoi(yytext);printf("%s\n", yytext);return Q;}
ESTADO\({I}\)            {yylval.letras=strdup(yytext);return ESTADO;}
[\{\;\}]     {return yytext[0];}

[ \t \n \r]+


.                   { printf("Erro lexico: simbolo desconhecido ->%s<- \n ", yytext);}
<<EOF>>             {return 0;}
%%
