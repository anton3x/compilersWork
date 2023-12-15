%{
    #include "trabalho.tab.h"
%}
%option nounput
%option noinput
%option noyywrap

%%

INICIO-DAS-INSTRUCOES { return INICIO_DAS_INSTRUCOES; }
FINAL-DAS-INSTRUCOES  { return FINAL_DAS_INSTRUCOES; }
";"                    { return ';'; }

MANUTENCAO  { return MANUTENCAO; }
CARREGA-BATERIA  { return CARREGA_BATERIA; }
ENTREGA     { return ENTREGA; }
RECOLHE     { return RECOLHE; }
ESTADO      { return ESTADO; }
INIT-ESTADO { return INIT_ESTADO; }

"{"          {return '{';}
"}"        {return '}';}
[ \t\n]+
[BMT]    {yylval.letras=yytext; return LETRAESTADO;}
[A-Za-z] {yylval.letras=yytext; return STR;}
[0-9]+\.[0-9]+ {yylval.real=atof(yytext);return CARGABATERIA;}
[0-9]+      { yylval.inteiro = atoi(yytext); return NUM; }
[\(\)\[\],]     {return yytext[0];}

.                   { printf("Erro lexico: simbolo desconhecido ->%s<- \n ", yytext);}
<<EOF>>             {return 0;}
%%
