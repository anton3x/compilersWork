%{
    #include <stdio.h>
    #include <stdbool.h>
    #include <string.h>
    #include <stdlib.h>
    int yyerror(char *s);
    int yylex();
    int nerros=0;

    //vetor com todas as localizacoes possiveis para o carro
    char localizacoes[4][25] = {"Posto de Manutenção","Posto de Carregamento","Armazem","Linhas de Montagem"};
    char letrasEstadosPossiveis[3] = {'\0'};
    int iteratorLetraEstado = 0;
    //localizacao onde o carro esta no momento, o valor varia de 0 a 3, sendo 0 o "Posto de Manutencao" e 3 as "Linhas de Montagem"
    int localizacao=1;
    //variavel que armazena a carga da bateria do carro
    float cargaBateriaCarro=100;
    //variavel que armazena a quantidade total de pecas que estao no carro
    int quantidadeTotalDeMateriaisATransportar=0;
    //variavel que armazena a quantidade maxima de pecas que o carro suporta
    int quantidadeMaximaTransporte=80;
    //variavel que armazena o numero de materiais diferentes que o carro esta a transportar no momento
    int numeroDeMateriaisATransportar=0;
    //vetor que armazena os tipos de materiais que o carro esta a transportar no momento
    char materiasATransportar[80][6] = {};
    //vetor que armazena a quantidade de pecas de todos os tipos de materiais que o carro esta a transportar, a posicao 0 deste vetor corresponde ao material indice 0 do vetor acima.
    int valueMateriasATransportar[80] = {0};
    //vetor com todos os contextos possiveis
    char contexto[6][16] = {"MANUTENCAO", "CARREGA-BATERIA", "RECOLHE", "ENTREGA", "ESTADO", "INITIAL"};
    //variavel que armazena um valor entre 0 e 5, sendo 0 a "MANUTENCAO" e 5 o "INITIAL"
    int contextoAtual = 5;
    //vetor que armazena 0 ou 1 para cada elemento, e cada elemento corresponde a um CONTEXTO
    int contextosUsados[6] = {0};
    //vetor que vai armazenar as expressoes passados pelo ficheiro que se encontram invalidas
    char palavraInvalida[1000][1000] = {"\0","\0"};
    //variavel que tem o indice do elemento do vetor, neste caso, a letra desse elemento, que esta livre
    int iteratorLetra = 0;
    //variavel que tem o indice do elemento do vetor que esta livre
    int iteratorPalavra = 0;
    //variavel que contem o indice do vetor de materiais do elemento livre mais proximo da origem
    int iteratorElementoLivreVetor = 0;


    int numManutencao=0; //variavel que contem a quantidade de vezes que foi a manutencao

    //funcao usada para exibir o estado atual do carro, tanto o estado inicial, como o estado final
    //se quisermos exibir o estado final, passado true como argumento para a funcao
    void printInfo(bool final)
    {
        printf("Estado da bateria: %f%%\n", cargaBateriaCarro);
        if (final == true)
            printf("Localizacao Final: %s\n", localizacoes[localizacao]);
        else
            printf("Localizacao Atual: %s\n", localizacoes[localizacao]);
        printf("Lista de peças: ");
        for(int i = 0; i< 80; i++)
        {
            if(materiasATransportar[i][0] != '\0')
                printf("\n\tMaterial - %s ; Quantidade - %d", materiasATransportar[i], valueMateriasATransportar[i]);
        }
        printf("\nQuantidade de peças a transportar: %d\n", quantidadeTotalDeMateriaisATransportar);
        printf("Numero de vezes que foi a manutencao: %d\n", numManutencao);
        if (final)
            printf("\n");
    }

    //funcao responsavel para contar a quantidade de um caracter em especifico em um vetor
    int contarCaracterNoVetor(char *vetor, int tamanhoVetor, char caracter)
    {
        int quantidade=0;
        for(int i = 0; i < tamanhoVetor; i++)
        {
            if (vetor[i] == caracter)
                quantidade++;
        }
        return quantidade;
    }

    //funcao responsavel para procurar um certo material no vetor que contem todos os materiais a transportar
    //se encontrar o material a procurar, retorna o indice dele no vetor, se nao retorna -1
    int procurarMaterialNoCarro(char tipoMaterial[6], char materiasATransportar[][6])
    {
        for(int i = 0; i < 80; i++)
            if (strcmp(tipoMaterial, materiasATransportar[i]) == 0)
            {
                return i;
            }
        return -1;
    }

    //retorna o indice do elemento livre mais proximo do vetor de materiais a transportar, se nenhum tiver livre, retorna -1
    int indiceElementoLivreMaisProximo(char materiasATransportar[][6])
    {
        for(int i = 0; i < 80; i++)
        {
            if (materiasATransportar[i][0] == '\0')
            {
                return i;
            }
        }
        return -1;
    }


%}

%union
{
    char *letras;
    float real;
    int inteiro;
}


%start program
%token <letras> MANUTENCAO CARREGA_BATERIA ENTREGA RECOLHE ESTADO INIT_ESTADO INICIO_DAS_INSTRUCOES FINAL_DAS_INSTRUCOES STR LETRAESTADO
%token <inteiro> NUM
%token <real> CARGABATERIA



%%

program : INICIO_DAS_INSTRUCOES '{' instrucoes instrucao '}' FINAL_DAS_INSTRUCOES { /* código C aqui */ }
        ;

instrucoes : /*vazio*/
           | instrucoes instrucao ';'
           ;

instrucao : MANUTENCAO '(' NUM ')' { if (palavraInvalida[iteratorPalavra][0] != '\0') {iteratorPalavra++;iteratorLetra = 0;}
                                                 //imprime o estado inicial do carro
                                     			printInfo(false);
                                     			//imprime a instrucao passada
                                     			printf("----------------------\n");
                                     			printf("|   MANUTENCAO(%d)    |\n",$3);
                                     			printf("----------------------\n");

                                                 //se o carro tiver carga suficiente para ir a manutencao, ou se ja estiver na manutencao
                                     			if (cargaBateriaCarro >= (10 + 0.01 * quantidadeTotalDeMateriaisATransportar) || localizacao == 0)
                                     			{
                                     			    //incrementa o contador de vezes que foi a manutencao
                                     				numManutencao++;
                                     				//se nao estiver no posto de manutencao, vai para o posto de manutencao e e retirada a bateria consumida
                                     		    	if (localizacao != 0)
                                                     {
                                                         localizacao=0;
                                     		    	    cargaBateriaCarro-=(10 + 0.01 * quantidadeTotalDeMateriaisATransportar);
                                                     }

                                                     //se o contador de vezes que foi a manutencao for igual a 3, apresenta um erro
                                                     if (numManutencao == 3)
                                                     {
                                                         printf("\nO carro ja foi 3 vezes a manutencao, cuidado!!!\n");
                                                         //resetar o contador de manutencao
                                                         numManutencao = 0;
                                                     }

                                                 }
                                     			else
                                     			{
                                     				printf("\nNao tem carga suficiente na bateria para o carro chegar a manutencao");
                                     			}
                                     			//imprimir o estado final do carro
                                                 printInfo(true);
                                     			printf("\n");
                                     			//retornar ao contexto inicial

                                     			 }
          | CARREGA_BATERIA '(' NUM ')'  { if (palavraInvalida[iteratorPalavra][0] != '\0') {iteratorPalavra++;iteratorLetra = 0;}
                                                       //imprime o estado inicial do carro
                                           			printInfo(false);
                                           			//imprime a instrucao passada
                                           			printf("------------------------\n");
                                           			printf("|  CARREGA-BATERIA(%d)  |\n", $3);
                                           			printf("------------------------\n");
                                           			//variavel que tem a quantidade necessaria de bateria para o trajeto
                                           			float quantidadeBateriaNecessaria = (10 + 0.01 * quantidadeTotalDeMateriaisATransportar);

                                                       //se ele tem carga suficiente para fazer o trajeto e a sua bateria nao esta a 100%
                                           			if ((cargaBateriaCarro >= quantidadeBateriaNecessaria) && (cargaBateriaCarro != 100))
                                           			{
                                           			    //carga da bateria e decrementada
                                           				cargaBateriaCarro -= quantidadeBateriaNecessaria;
                                           		    	//carro vai para o posto de carregamento
                                           		    	localizacao=1;
                                                           //variavel com a carga da bateria do carro e colocada a 100%
                                           		    	cargaBateriaCarro=100;
                                           			}
                                           			else
                                           			{
                                           			    //se o carro nao tiver carga suficiente ou/e tiver a bateria a 100
                                           			    //para cada uma delas apresenta um erro
                                           			    if (cargaBateriaCarro < quantidadeBateriaNecessaria)
                                           				    printf("\nNao ha carga suficiente na bateria para o carro chegar ao posto de carregamento!!!\n");
                                           				if (cargaBateriaCarro == 100)
                                           				    printf("\nBateria do carro ja se encontra cheia!!!\n");
                                           			}
                                           			//imprimir o estado final do carro
                                                       printInfo(true);
                                                       //retornar ao contexto inicial

                                                       }
          | ENTREGA '(' STR ',' STR ',' NUM ')'  { /* código C aqui */ }
          | RECOLHE '(' '[' lista_materiais ']' ')'  { /* código C aqui */ }
          | ESTADO '(' letras_estados LETRAESTADO ')'  {
                                                        letrasEstadosPossiveis[iteratorLetraEstado++] = $4[0];
                                                        /*printf("Letra detectada: %c\n", $4[0]);*/

                                                        //imprimir estado inicial do carro
                                            			printInfo(false);
                                                        //imprime a instrucao passada
                                                        printf("\n------------------\n");
                                                        printf("|  ESTADO(");
                                                        if(letrasEstadosPossiveis[0] != '\0')
                                                            printf("%c",letrasEstadosPossiveis[0]);
                                                        if(letrasEstadosPossiveis[1] != '\0')
                                                            printf(",%c",letrasEstadosPossiveis[1]);
                                                        if(letrasEstadosPossiveis[2] != '\0')
                                                            printf(",%c",letrasEstadosPossiveis[2]);
                                                        printf(")  |\n");
                                                        printf("------------------\n");

                                                        //opcoes disponiveis que podemos passar para o ESTADO()
                                                        char options[3] = {'B','T','M'};
                                                        //options[i] -> found[i] correspondem uma a outra, se algum elemento do "found" for true, quer dizer que o elemento corresponde de "options" foi passado para a expresao
                                                        bool found[3] = {false, false, false};

                                                        //Para cada uma das letras que podemos passar para o ESTADO()
                                                        for (int i = 0; i < 3; i++) //Para cada uma das letras que podemos passar para o ESTADO()
                                                        {
                                                            //vai verificar se passando so uma letra, ou duas ou tres, algumas delas corresponde com a letra em causa
                                                            //ESTADO(B) -> B ta no 7 lugar, se for com 2 letras, ESTADO(T,B) -> B ta no 9 lugar, e ESTADO(T,M,B) -> B ta no 11 lugar
                                                            //se o if verificar o B em algum desses lugares, vai definir que encontrou a letras
                                                            //se o B se mantivesse na 1 posicao quando passamos mais de que uma letras, ia definir igual pois a 7 posicao ia ser o B
                                                            if (letrasEstadosPossiveis[0] == options[i] || letrasEstadosPossiveis[1] == options[i] || letrasEstadosPossiveis[2] == options[i])
                                                                found[i] = true;
                                                        }

                                                        printf("\n");
                                                        if (found[0]==true) //Se encontrou o B
                                                            printf("Estado da bateria: %f%%\n", cargaBateriaCarro);
                                                        if (found[2]==true) //Se encontrou o M
                                                        {
                                                            printf("Lista de peças: \n");
                                                            for(int i = 0; i< 80; i++)
                                                            {
                                                                if(materiasATransportar[i][0] != '\0')
                                                                    printf("\n\tMaterial %s - Quantidade %d", materiasATransportar[i], valueMateriasATransportar[i]);
                                                            }
                                                            printf("Quantidade de peças a transportar: %d\n", quantidadeTotalDeMateriaisATransportar);
                                                        }
                                                        if (found[1] == true) //Se encontrou o T
                                                            printf("TAREFAS PENDENTES: NENHUMA\n");
                                            			printf("\n");
                                                        //imprimir estado inicial do carro
                                                        printInfo(true);
                                            			printf("\n");
                                            			iteratorLetraEstado=0; //resetar iterador das letras do vetor com cada uma das letras passadas para a espressao estado
                                            			}
          | INIT_ESTADO '(' NUM ',' CARGABATERIA ',' STR ',' NUM ')' { cargaBateriaCarro = $5;
                                                                  /*char localizacoes[4][25] = {"Posto de Manutenção","Posto de Carregamento","Armazem","Linhas de Montagem"};
                                                                  localizacao onde o carro esta no momento, o valor varia de 0 a 3, sendo 0 o "Posto de Manutencao" e 3 as "Linhas de Montagem"
                                                                  int localizacao=1;*/


                                                                  localizacao=$3;

                                                                  numManutencao=$9;





           }
          ;
letras_estados: /*vazio*/
                | letras_estados LETRAESTADO ',' { letrasEstadosPossiveis[iteratorLetraEstado++] = $2[0];/*printf("Letra detectada: %c\n", $2[0]);*/}
                ;

lista_materiais : elemento
                | lista_materiais ',' elemento
                ;

elemento : '(' STR ',' NUM ')' { /* código C aqui */ }
        ;
%%
int main() {
    yyparse();
    yylex();
    if (nerros == 0) {
        printf("FRASE É VÁLIDA!!!");
    } else {
        printf("FRASE É INVÁLIDA!!! com %d erros", nerros);
    }
}

int yyerror(char *s) {
    nerros ++;
    return 0;
}