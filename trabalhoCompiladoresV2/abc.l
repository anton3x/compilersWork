
%x MANUTENCAO

%%
MANUTENCAO\([0-2] {BEGIN(MANUTENCAO);}
<MANUTENCAO>\) {printf("ola");BEGIN(INITIAL);}


 /* as regras seguintes não tem contexto */

<*>.
