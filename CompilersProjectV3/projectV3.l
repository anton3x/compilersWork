
%{
    #include "trabalho.tab.h"

%}
%option nounput
%option noinput
%option noyywrap


M [a-zA-Z0-9]{1,5}
LIST \([a-zA-Z0-9]{5},(0*)[1-9][0-9]*\)(,[ ]\([a-zA-Z0-9]{5},(0*)[1-9][0-9]*\))*
I (B|T|M|(T,(B|M))|(B,(T|M))|(M,(T|B))|(B,T,M)|(T,M,B)|(M,B,T)|(T,B,M)|(M,T,B)|(B,M,T))
LOCATION ([ A-Za-z]{7,})

%%

START-OF-INSTRUCTIONS { return START_OF_INSTRUCTIONS; }
END-OF-INSTRUCTIONS  { return END_OF_INSTRUCTIONS; }

MAINTENANCE  { return MAINTENANCE; }
CHARGE-BATTERY  { return CHARGE_BATTERY; }
DELIVERY     { return DELIVERY; }
PICKUP     { return PICKUP; }
INIT-STATE { return INIT_STATE; }
STATUS      {return STATUS;}

{LOCATION} {yylval.letras=strdup(yytext);return LOCATION;}
\(\[{LIST}\]\)       {yylval.letras=strdup(yytext);return LIST;}
\[{LIST}\]|"#"       {yylval.letras=strdup(yytext);return LIST_1;}

{M}           {yylval.letras=strdup(yytext);return M;}             
{I}            {yylval.letras=strdup(yytext);return I;}
[\{\}\;\(\)\,]     {return yytext[0];}

[ \t \n \r]+


.                   { printf("Lexical error: unknown symbol ->%s<- \n ", yytext);return yytext[0];}
<<EOF>>             { return 0;}
%%
