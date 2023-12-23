%{
    #include <stdio.h>
    #include <stdbool.h>
    #include <string.h>
    #include <stdlib.h>
    int yyerror(char *s);
    int yylex();
    int nerros=0;

    //vetor com todas as localizacoes possiveis para o carro
    char localizacoes[4][25] = {"Posto de Manutencao","Posto de Carregamento","Armazem","Linhas de Montagem"};
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
    //char palavraInvalida[1000][1000] = {"\0","\0"};
    //variavel que tem o indice do elemento do vetor, neste caso, a letra desse elemento, que esta livre
    //int iteratorLetra = 0;
    //variavel que tem o indice do elemento do vetor que esta livre
    int iteratorPalavra = 0;
    //variavel que contem o indice do vetor de materiais do elemento livre mais proximo da origem
    int iteratorElementoLivreVetor = 0;


    int numManutencao=0; //variavel que contem a quantidade de vezes que foi a manutencao

    //funcao usada para exibir o estado atual do carro, tanto o estado inicial, como o estado final
    //se quisermos exibir o estado final, passado true como argumento para a funcao
    void printInfo(bool final)
    {
        printf("Estado da bateria: %.2f%%\n", cargaBateriaCarro);
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
%token <letras> MANUTENCAO CARREGA_BATERIA ENTREGA RECOLHE ESTADO INIT_ESTADO INICIO_DAS_INSTRUCOES FINAL_DAS_INSTRUCOES LISTA I LOCALIZACAO M LISTA_1
%token <inteiro> Q




%%

program : INICIO_DAS_INSTRUCOES '{' instrucoes '}' FINAL_DAS_INSTRUCOES 
        ;

instrucaoINIT : INIT_ESTADO '(' LOCALIZACAO ',' Q ',' LISTA_1 ',' Q ')'         { 
                                                                bool usados[4] = {false, false,false,false};
                                                                char vetorAux1[2][1000] = {"\0"};
                                                                int quantidades[2] = {0,0};
                                                                int ultimaPosicao1 = 0;
                                                                strncpy(vetorAux1[0], $3, strlen($3));
                                                                strncpy(vetorAux1[1], $7, strlen($7));
                                                                quantidades[0] = $5;
                                                                quantidades[1] = $9;
                                                                
                                                                /*vetorAux1[0] - localizacao inicial
                                                                  vetorAux1[1] - lista de materiais
                                                                  quantidades[0] - carga bateria do carro
                                                                  quantidades[1] - numero de vezes que foi a manutencao
                                                                
                                                                */

                                                                bool localizacaoInvalida = true, quantidadeInvalida = true;
                                                                int numLocalizacao = -1;
                                                                for(int i = 0; i < 4; i++)
                                                                { 
                                                                    if(strcmp(localizacoes[i],vetorAux1[0]) == 0)
                                                                    {
                                                                        numLocalizacao=i;
                                                                        localizacaoInvalida = false;
                                                                    }
                                                                }
                                                                if($5 >= 0 && $5 <= 100)
                                                                    quantidadeInvalida = false;

                                                                if (!localizacaoInvalida && !quantidadeInvalida)
                                                                {
                                                                    printInfo(false);
                                                                    localizacao=numLocalizacao;
                                                                    for(int i = 0; i < 20 + 6 + strlen($3) + strlen($7); i++)
                                                                    {
                                                                        printf("-");
                                                                    }
                                                                    printf("\n|   INIT-ESTADO(%s,%d,%s,%d)   |\n", $3,$5,$7,$9);
                                                                    for(int i = 0; i < 20 + 6 + strlen($3) + strlen($7); i++)
                                                                    {
                                                                        printf("-");
                                                                    }
                                                                    printf("\n");

                                                                    cargaBateriaCarro = quantidades[0];
                                                                    //variavel que armazena a quantidade de tipos de materiais diferentes que sao passados para a expressao
                                                                    int quantidadeMateriaisExigida = contarCaracterNoVetor(vetorAux1[1],strlen(vetorAux1[1]),'(');

                                                                    //variavel auxiliar para a filtragem de informacao
                                                                    int ultimaPosicao=0;
                                                                    //variavel auxiliar que tem o proximo elemento livre do vetor
                                                                    int numeroDoElementoLivreNoVetor=0;

                                                                    //vetores auxiliares para armazenar os tipos de materiais e as quantidades desses materiais
                                                                    char vetorAux[80][15] = {"\0"};
                                                                    int quantidadesVetorAux[80] = {0,0};

                                                                    //o metodo de funcionamento e parecido ao da ENTREGA, mas basicamente ele vai percorrer todos os caracteres e ao detectar um "(", mas tem que ter antes um "[" ou ","
                                                                    //se isso se verificar ele guarda a posicao a seguir ao "(", que corresponde ao primeiro caracter do tipo de material em "ultimaPosicao"
                                                                    //quando encontrar uma virgula que a seguir a ela nao aparece um "(", ele sabe que antes dessa virgula e o ultimo caracter do tipo de material
                                                                    //entao ja sabemos, pegamos no indice antes da virgula usando o valor de "ultimaPosicao" conseguimos recortar a string correspondente ao tipo de material
                                                                    //a seguir a isso, colocamos no "ultimaPosicao" o valor do indice a seguir á virgula, que corresponde ao primeiro caracter da quantidade do material
                                                                    //ao detectar uma virgula antecedida por um ")" ou "]" antecedido por um ")", sabemos que antes do ")" esta o ultimo caracter da quantidade do material
                                                                    //entao obtemos a quantidade desse material recorrendo a esse indice e ao valor da "ultimaPosicao"
                                                                    if(strcmp(vetorAux1[1], "#") != 0)
                                                                    {     
                                                                        for(int i = 1 ; i < strlen(vetorAux1[1]); i++)
                                                                        {
                                                                            if ((vetorAux1[1][i-1]=='[' && vetorAux1[1][i]=='(' ) || ( vetorAux1[1][i-1] == ',' && vetorAux1[1][i]==' ' ))
                                                                            {
                                                                                    if (vetorAux1[1][i]=='(' )
                                                                                        ultimaPosicao=i+1;
                                                                                    else
                                                                                        ultimaPosicao=i+2;
                                                                            }
                                                                            if (vetorAux1[1][i+1]!=' ' && vetorAux1[1][i]==',')
                                                                            {
                                                                                    strncpy(vetorAux[numeroDoElementoLivreNoVetor], (vetorAux1[1] + ultimaPosicao), i - ultimaPosicao);
                                                                                    ultimaPosicao=i+1;
                                                                            }
                                                                            if (vetorAux1[1][i-1]==')' && (vetorAux1[1][i]==',' || (vetorAux1[1][i]==']')))
                                                                            {
                                                                                    char p[1][10] = {"\0"};
                                                                                    strncpy(p[0], (vetorAux1[1] + ultimaPosicao), i - ultimaPosicao - 1);
                                                                                    quantidadesVetorAux[numeroDoElementoLivreNoVetor++] = atoi(p[0]);

                                                                            }
                                                                        }

                                                                       //calcula o total de todos os tipos de materiais que nos foram pedidos para colocar no carro
                                                                        //basicamente pega no vetor que contem todas as quantidades dos materiais que nos foram pedidos e soma tudo
                                                                        int quantidadeTotalDaExigida=0; //vai conter a quantidade de materiais que foram pedidos na expressao regular
                                                                        int quantidadeTotalDeMateriaisATransportarCopia = quantidadeTotalDeMateriaisATransportar; //usamos uma copia pois a variavel normal vai sendo alterada ao longo da execucao do programa
                                                                        bool used = false; //para verificar se a substracao da bateria e a localizacao ja foram atribuidas
                                                                        for(int i = 0; i < quantidadeMateriaisExigida; i++)
                                                                        {

                                                                            quantidadeTotalDaExigida+=quantidadesVetorAux[i]; //incrementa a variavel
                                                                            if ((quantidadeTotalDeMateriaisATransportarCopia + quantidadeTotalDaExigida )<= quantidadeMaximaTransporte) //se ainda nao ultrapassamos o limite do carro
                                                                            {
                                                                                
                                                                                //o i itera por todos os elementos do vetor que contem todos os materiais a serem transportados pelo carro
                                                                                //o j itera sobre os materiais que nos foram pedidos para recolher
                                                                                //se detectar que o material a ser iterado no momento ja se encontra no carro, entao incrementa o vetor das quantidades naquele indice em especifico com a quantidade
                                                                                //e reseta a quantidade do material no vetor auxiliar/o material tambem, no vetor auxiliar
                                                                                for (int j = 0; j < 80; j++)
                                                                                {
                                                                                    if (strcmp(materiasATransportar[j],vetorAux[i]) == 0)
                                                                                    {
                                                                                        valueMateriasATransportar[j] += quantidadesVetorAux[i];
                                                                                        quantidadeTotalDeMateriaisATransportar+=quantidadesVetorAux[i];
                                                                                        strcpy(vetorAux[i], "\0");
                                                                                        quantidadesVetorAux[i] = 0;

                                                                                    }
                                                                                }

                                                                                //visto que podem ter ficado no vetor auxiliar materiais que nao se encontravam anteriormente no carro, temos que os colocar la
                                                                                //entao itero por todos os materiais que ficaram no vetor auxiliar
                                                                                //se o valor do elemento for != \0, ele vai incluir no vetor dos materiais a transportar no carro esse material em questao e a quantidade correspondente
                                                                                //ao fazer isso vai resetar os vetores auxiliares, tanto no nome do material como na quantidade desse material
                                                                                //no final, vai alterar o valor da variavel que tem o indice do elemento vazio mais proximo do inicio do vetor, do vetor de materiais que estao no carro

                                                                                if (vetorAux[i][0] != '\0')
                                                                                {
                                                                                    strcpy(materiasATransportar[iteratorElementoLivreVetor],vetorAux[i]);
                                                                                    valueMateriasATransportar[iteratorElementoLivreVetor] = quantidadesVetorAux[i];
                                                                                    quantidadeTotalDeMateriaisATransportar+=quantidadesVetorAux[i];
                                                                                    strcpy(vetorAux[i],"");
                                                                                    quantidadesVetorAux[i] = 0;
                                                                                    iteratorElementoLivreVetor = indiceElementoLivreMaisProximo(materiasATransportar);

                                                                                }


                                                                            }
                                                                            else
                                                                            {
                                                                                printf("\nNao e possivel colocar todos os materiais requisitados no carro\n");
                                                                                i = quantidadeMateriaisExigida; //para o loop parar
                                                                            }
                                                                        }
                                                                    }
                                                                    numManutencao=quantidades[1];
                                                                    printInfo(true);
                                                                    printf("\n");
                                                                }
                                                                else
                                                                {
                                                                    printf("INIT-ESTADO(%s,%d,%s,%d) - INVALIDA\n", $3,$5,$7,$9);
                                                                    if(localizacaoInvalida)
                                                                        printf("LOCALIZACAO INVALIDA!!!\n");
                                                                    if(quantidadeInvalida)
                                                                        printf("BATERIA INVALIDA!!!\n");
                                                                    printf("\n");
                                                                }
                                                                }
                                                                ;

instrucoes : /*vazio*/
           |  instrucaoINIT instrucoesS /*alterei antes o ; nao existia mas assim garante que tem que ter o ;*/
           |  instrucao instrucoesS
           ;
instrucoesS : /*vazio*/
            | instrucoesS ';' instrucao
            ;

instrucao : MANUTENCAO '(' Q ')' {
                                                if($3 >= 0 && $3 <= 2)
                                                {
                                                    
                                                    //imprime o estado inicial do carro
                                                    printInfo(false);
                                                    //imprime a instrucao passada
                                                    printf("----------------------\n");
                                                    printf("|   %s(%d)    |\n",$1,$3);
                                                    printf("----------------------\n");

                                                    //se o carro tiver carga suficiente para ir a manutencao, ou se ja estiver na manutencao
                                                    if (cargaBateriaCarro >= (10 + 1 * quantidadeTotalDeMateriaisATransportar) || localizacao == 0)
                                                    {
                                                        //incrementa o contador de vezes que foi a manutencao
                                                        numManutencao++;
                                                        //se nao estiver no posto de manutencao, vai para o posto de manutencao e e retirada a bateria consumida
                                                        if (localizacao != 0)
                                                        {
                                                            localizacao=0;
                                                            cargaBateriaCarro-=(10 + 1 * quantidadeTotalDeMateriaisATransportar);
                                                        }

                                                        //se o contador de vezes que foi a manutencao for igual a 3, apresenta um erro
                                                        if (numManutencao > 3)
                                                        {
                                                            printf("\nO carro ja foi mais de 3 vezes a manutencao, cuidado!!!\n");
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
                                                    printf("\n\n");
                                                    //retornar ao contexto inicial
                                     			}
                                     			else
                                     			{
                                                    printf("%s(%d) - INVALIDA\n\n",$1, $3);
                                                }

                                     			}
          | CARREGA_BATERIA '(' Q ')'  {        if($3 >= 0 && $3 <= 2)
                                                {
                                                   
                                                       //imprime o estado inicial do carro
                                           			printInfo(false);
                                           			//imprime a instrucao passada
                                           			printf("------------------------\n");
                                           			printf("|  CARREGA-BATERIA(%d)  |\n", $3);
                                           			printf("------------------------\n");
                                           			//variavel que tem a quantidade necessaria de bateria para o trajeto
                                           			float quantidadeBateriaNecessaria = (10 + 1 * quantidadeTotalDeMateriaisATransportar);

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
                                                    printf("\n\n");
                                                    //retornar ao contexto inicial
                                                }
                                                else
                                                {
                                                    printf("CARREGA-BATERIA(%d) - INVALIDA\n\n", $3);
                                                }
                                        }
          | ENTREGA '(' M ',' M ',' Q ')' {
                                                            //validar a linha de entrega
                                                            //se usasse o L aqui ia dar ambiguidade com o M, visto que o M engloba o L entao usasse o M e verificasse se esta correto
                                                            bool materialValido = false;
                                                            bool quantidadeMaterialValida = false;
                                                            bool linhaDeMontagemValida = false;

                                                            char linhaEntregaAux[100] = {'\0'};
                                                            char numeroLinhaMontagemEmChar[100] = {'\0'};
                                                            int numeroLinhaMontagem=0;
                                                            strncpy(linhaEntregaAux, $3, strlen($3));

                                                            if((linhaEntregaAux[0] >= 'A' && linhaEntregaAux[0] <= 'Z') && (linhaEntregaAux[1] >= 'A' && linhaEntregaAux[1] <= 'Z'))
                                                            {
                                                                for(int i = 2 ; linhaEntregaAux[i] != '\0'; i++)
                                                                {
                                                                    numeroLinhaMontagemEmChar[i-2] = linhaEntregaAux[i];
                                                                }
                                                                numeroLinhaMontagem = atoi(numeroLinhaMontagemEmChar);
                                                                if (numeroLinhaMontagem >= 1 && numeroLinhaMontagem <= 100)
                                                                {
                                                                    linhaDeMontagemValida = true;
                                                                }
                                                            }
                                                            if(strlen($5) == 5)
                                                                materialValido = true;
                                                            if ($7 > 0)
                                                                quantidadeMaterialValida = true;




                                                            if (materialValido && quantidadeMaterialValida && linhaDeMontagemValida){
                                                               //variavel que vai conter se o carro tem carga suficiente para o trajeto, se tiver fica a true, se nao false, mas e inicializada com false
                                                               bool cargaBateriaSuficiente = false;
                                                               //imprimir estado inicial do carro
                                                               printInfo(false);
                                                               //imprime a instrucao passada

                                                               for(int i = 0; i < 30; i++)
                                                               {
                                                                   printf("-");
                                                               }
                                                               printf("\n|  ENTREGA(%s,%s,%d)  |\n", $3, $5, $7);
                                                               for(int i = 0; i < 30; i++)
                                                               {
                                                                   printf("-");
                                                               }
                                                               printf("\n");
                                                               //variavel que vai conter a quantidade de bateria necessaria para o carro fazer o trajeto
                                                               float quantidadeBateriaNecessaria;
                                                               //se o carro ja esta em alguma linha de montagem, a quantidade de bateria necessaria e atribuida a variavel reponsavel e se o carro tiver mais ou igual a esse valor,
                                                               //a variavel cargaBateriaSuficiente e colocada como verdade
                                                               //se o carro nao estiver em alguma linha de montagem, a quantidade de bateria necessaria e atribuida a variavel reponsavel e se o carro tiver mais ou igual a esse valor,
                                                               //a variavel cargaBateriaSuficiente e colocada como verdade
                                                               if (localizacao == 3) {
                                                                   quantidadeBateriaNecessaria = (5  + 1 * quantidadeTotalDeMateriaisATransportar);
                                                                   if (cargaBateriaCarro >= quantidadeBateriaNecessaria)
                                                                       cargaBateriaSuficiente = true; //tem carga suficiente

                                                               } else {
                                                                   quantidadeBateriaNecessaria = (10  + 1 * quantidadeTotalDeMateriaisATransportar);
                                                                   if (cargaBateriaCarro >= quantidadeBateriaNecessaria)
                                                                       cargaBateriaSuficiente = true; //tem carga suficiente

                                                               }

                                                               //se o carro tem carga suficiente para ir para o local
                                                                if (cargaBateriaSuficiente) {

                                                                    //primeiro temos que obter o material que foi passado para a instrucao e a respetiva quantidade desse material
                                                                    //variavel auxiliar para a filtragem de informacao
                                                                    int ultimaPosicao = -1;

                                                                    //vetor e inteiro reponsavel por armazenar o tipo de material e a quantidade necessaria desse material
                                                                    char tipoMaterialDesejado[6] = "\0";
                                                                    int quantidadeMaterialDesejado;

                                                                    strncpy(tipoMaterialDesejado, ($5), strlen($5));
                                                                    quantidadeMaterialDesejado = $7;

                                                                   //obtemos o indice do material no vetor que contem todos os materiais que o carro transporta
                                                                   int indiceMaterialNoVetor = procurarMaterialNoCarro(tipoMaterialDesejado,materiasATransportar);

                                                                   //se retornar -1, o material nao foi encontrado no carro, entao imprime um erro
                                                                   //se encontrar, verifica se a quantidade que o programa recebeu para entregar desse material nao e superior a quantidade existente no carro
                                                                   //se for superior na expressao face ao carro, imprime um erro
                                                                   if (indiceMaterialNoVetor == -1)
                                                                   {
                                                                           printf("\npeca nao existe no carro!!!\n");
                                                                   }
                                                                   else if(quantidadeMaterialDesejado > valueMateriasATransportar[indiceMaterialNoVetor])
                                                                   {
                                                                           printf("\nnao existem tantas pecas desse material no carro!!!\n");
                                                                   }
                                                                   else
                                                                   {
                                                                       //se o material existir no carro e a quantidade para entrega for valida faz o de baixo
                                                                       //a bateria e subtraida a carga de bateria do carro
                                                                       cargaBateriaCarro -= quantidadeBateriaNecessaria;
                                                                       //se nao estiver na linha de montagem, coloca-o la
                                                                       if (localizacao != 3)
                                                                           localizacao = 3;

                                                                       //a quantidade desse material no vetor que armazena todas as quantidades de materiais e decrementada
                                                                       valueMateriasATransportar[indiceMaterialNoVetor] -= quantidadeMaterialDesejado;
                                                                       //variavel que contem a quantidade total de todas as pecas de todos os materiais tambem e decrementada
                                                                       quantidadeTotalDeMateriaisATransportar -= quantidadeMaterialDesejado;
                                                                       //se no vetor que contem as quantidades de pecas de cada material a quantidade para este material for 0, entao esse material nao existe no carro
                                                                       //entao foi remover esse tipo de material do vetor que contem os tipos de materiais que estao no carro
                                                                       if (valueMateriasATransportar[indiceMaterialNoVetor] == 0)
                                                                       {
                                                                           //removo a string do elemento correspondente ao material
                                                                           materiasATransportar[indiceMaterialNoVetor][0] = '\0';
                                                                           //a variavel que contem o proximo elemento livre no vetor de materiais e chamada
                                                                           iteratorElementoLivreVetor = indiceElementoLivreMaisProximo(materiasATransportar);
                                                                       }
                                                                   }
                                                               }
                                                               else
                                                               {
                                                                    printf("\nO carro nao tem bateria suficiente para ir para a linha de montagem\n");
                                                               }
                                                                //imprimir estado final do carro
                                                               printInfo(true);
                                                               printf("\n\n");
                                                                //retornar ao contexto inicial
                                                                
                                                            }
                                                            else
                                                            {
                                                                    printf("\n|  ENTREGA(%s,%s,%d)  - INVALIDA|\n", $3, $5, $7);
                                                                    if(!materialValido)
                                                                        printf("Material Invalido\n");
                                                                    if(!quantidadeMaterialValida)
                                                                        printf("Quantidade de Material Invalida\n");
                                                                    if(!linhaDeMontagemValida)
                                                                        printf("Linha de Montagem Invalida\n");
                                                                    printf("\n");

                                                            }
                                                            }


          | RECOLHE LISTA   {               
                                            //imprimir estado inicial do carro
                                            printInfo(false);
                                            //imprime a instrucao passada
                                            for(int i = 0; i < strlen($2) + 13; i++)
                                            {
                                                printf("-");
                                            }
                                            printf("\n|  RECOLHE%s  |\n", $2);
                                            for(int i = 0; i < strlen($2) + 13; i++)
                                            {
                                                printf("-");
                                            }
                                            printf("\n");
                                            //se o carro tem bateria suficiente ou se ja se encontrar no armazem, pode seguir em frente
                                            if (cargaBateriaCarro >= (11) || (localizacao == 2))
                                            {
                                                //variavel que armazena a quantidade de tipos de materiais diferentes que sao passados para a expressao
                                                int quantidadeMateriaisExigida = contarCaracterNoVetor($2,strlen($2),'(') - 1;

                                                //variavel auxiliar para a filtragem de informacao
                                                int ultimaPosicao=0;
                                                //variavel auxiliar que tem o proximo elemento livre do vetor
                                                int numeroDoElementoLivreNoVetor=0;

                                                //vetores auxiliares para armazenar os tipos de materiais e as quantidades desses materiais
                                                char vetorAux[80][15] = {"\0"};
                                                int quantidadesVetorAux[80] = {0,0};

                                                //o metodo de funcionamento e parecido ao da ENTREGA, mas basicamente ele vai percorrer todos os caracteres e ao detectar um "(", mas tem que ter antes um "[" ou ","
                                                //se isso se verificar ele guarda a posicao a seguir ao "(", que corresponde ao primeiro caracter do tipo de material em "ultimaPosicao"
                                                //quando encontrar uma virgula que a seguir a ela nao aparece um "(", ele sabe que antes dessa virgula e o ultimo caracter do tipo de material
                                                //entao ja sabemos, pegamos no indice antes da virgula usando o valor de "ultimaPosicao" conseguimos recortar a string correspondente ao tipo de material
                                                //a seguir a isso, colocamos no "ultimaPosicao" o valor do indice a seguir á virgula, que corresponde ao primeiro caracter da quantidade do material
                                                //ao detectar uma virgula antecedida por um ")" ou "]" antecedido por um ")", sabemos que antes do ")" esta o ultimo caracter da quantidade do material
                                                //entao obtemos a quantidade desse material recorrendo a esse indice e ao valor da "ultimaPosicao"
                                                for(int i = 1 ; i < strlen($2); i++)
                                                {
                                                    if (($2[i-1]=='[' && $2[i]=='(' ) || ( $2[i-1] == ',' && $2[i]==' ' ))
                                                    {
                                                            if ($2[i]=='(' )
                                                                ultimaPosicao=i+1;
                                                            else
                                                                ultimaPosicao=i+2;
                                                    }
                                                    if ($2[i+1]!=' ' && $2[i]==',')
                                                    {
                                                            strncpy(vetorAux[numeroDoElementoLivreNoVetor], ($2 + ultimaPosicao), i - ultimaPosicao);
                                                            ultimaPosicao=i+1;
                                                    }
                                                    if ($2[i-1]==')' && ($2[i]==',' || ($2[i]==']')))
                                                    {
                                                            char p[1][10] = {"\0"};
                                                            strncpy(p[0], ($2 + ultimaPosicao), i - ultimaPosicao - 1);
                                                            quantidadesVetorAux[numeroDoElementoLivreNoVetor++] = atoi(p[0]);

                                                    }
                                                }


                                                //calcula o total de todos os tipos de materiais que nos foram pedidos para colocar no carro
                                                //basicamente pega no vetor que contem todas as quantidades dos materiais que nos foram pedidos e soma tudo
                                                int quantidadeTotalDaExigida=0; //vai conter a quantidade de materiais que foram pedidos na expressao regular
                                                int quantidadeTotalDeMateriaisATransportarCopia = quantidadeTotalDeMateriaisATransportar; //usamos uma copia pois a variavel normal vai sendo alterada ao longo da execucao do programa
                                                bool used = false; //para verificar se a substracao da bateria e a localizacao ja foram atribuidas
                                                for(int i = 0; i < quantidadeMateriaisExigida; i++)
                                                {

                                                    quantidadeTotalDaExigida+=quantidadesVetorAux[i]; //incrementa a variavel
                                                    if ((quantidadeTotalDeMateriaisATransportarCopia + quantidadeTotalDaExigida )<= quantidadeMaximaTransporte) //se ainda nao ultrapassamos o limite do carro
                                                    {
                                                        if ((!used) && (localizacao != 2)) //se ainda nao foi feita atribuicao e se nao se encontra la
                                                        {   //se ele nao se encontra no armazem, coloca-o la e subtrai a quantidade de bateria da viagem
                                                        cargaBateriaCarro -= (10 + 1 * quantidadeTotalDeMateriaisATransportar);
                                                        localizacao = 2;
                                                        }

                                                        //o i itera por todos os elementos do vetor que contem todos os materiais a serem transportados pelo carro
                                                        //o j itera sobre os materiais que nos foram pedidos para recolher
                                                        //se detectar que o material a ser iterado no momento ja se encontra no carro, entao incrementa o vetor das quantidades naquele indice em especifico com a quantidade
                                                        //e reseta a quantidade do material no vetor auxiliar/o material tambem, no vetor auxiliar
                                                        for (int j = 0; j < 80; j++)
                                                        {
                                                            if (strcmp(materiasATransportar[j],vetorAux[i]) == 0)
                                                            {
                                                                valueMateriasATransportar[j] += quantidadesVetorAux[i];
                                                                quantidadeTotalDeMateriaisATransportar+=quantidadesVetorAux[i];
                                                                strcpy(vetorAux[i], "\0");
                                                                quantidadesVetorAux[i] = 0;

                                                            }
                                                        }

                                                        //visto que podem ter ficado no vetor auxiliar materiais que nao se encontravam anteriormente no carro, temos que os colocar la
                                                        //entao itero por todos os materiais que ficaram no vetor auxiliar
                                                        //se o valor do elemento for != \0, ele vai incluir no vetor dos materiais a transportar no carro esse material em questao e a quantidade correspondente
                                                        //ao fazer isso vai resetar os vetores auxiliares, tanto no nome do material como na quantidade desse material
                                                        //no final, vai alterar o valor da variavel que tem o indice do elemento vazio mais proximo do inicio do vetor, do vetor de materiais que estao no carro

                                                        if (vetorAux[i][0] != '\0')
                                                        {
                                                            strcpy(materiasATransportar[iteratorElementoLivreVetor],vetorAux[i]);
                                                            valueMateriasATransportar[iteratorElementoLivreVetor] = quantidadesVetorAux[i];
                                                            quantidadeTotalDeMateriaisATransportar+=quantidadesVetorAux[i];
                                                            strcpy(vetorAux[i],"");
                                                            quantidadesVetorAux[i] = 0;
                                                            iteratorElementoLivreVetor = indiceElementoLivreMaisProximo(materiasATransportar);
                                                        }
                                                    }
                                                    else
                                                    {
                                                        printf("\nNao e possivel colocar todos os materiais requisitados no carro\n");
                                                        i = quantidadeMateriaisExigida; //para o loop parar
                                                    }
                                                }

                                            }
                                            else
                                            {
                                                //se nao tiver carga suficiente apresenta um erro
                                                printf("\n!!!Carga de bateria insuficiente!!!\n");
                                            }
                                            //imprimir estado final do carro
                                            printInfo(true);
                                            printf("\n\n");
                                            //retornar ao contexto inicial
                                            
            }
          | ESTADO '(' I ')'  {
                                                        //printf("%s", $3);
                                                        /*printf("Letra detectada: %c\n", $4[0]);*/

                                                        //imprimir estado inicial do carro
                                            			printInfo(false);
                                                        //imprime a instrucao passada
                                                        printf("\n------------------\n");
                                                        printf("|  ESTADO(%s) |\n", $3);
                                                        printf("------------------");

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
                                                            if ($3[0] == options[i] || $3[2] == options[i] || $3[4] == options[i])
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
                                                                    printf("\tMaterial %s - Quantidade %d", materiasATransportar[i], valueMateriasATransportar[i]);
                                                            }
                                                            printf("\nQuantidade de peças a transportar: %d\n", quantidadeTotalDeMateriaisATransportar);
                                                        }
                                                        if (found[1] == true) //Se encontrou o T
                                                            printf("TAREFAS PENDENTES: NENHUMA\n");
                                            			printf("\n");
                                                        //imprimir estado inicial do carro
                                                        printInfo(true);
                                            			printf("\n\n");
                                            			iteratorLetraEstado=0; //resetar iterador das letras do vetor com cada uma das letras passadas para a espressao estado
                                            			}
                                                                
                                                        ;



%%
int main() {
    yyparse();
    yylex();
    if (nerros == 0) {
        printf("\nFicheiro de Entrada É VÁLIDO!!!");
    } else {
        printf("\nFicheiro de Entrada É INVÁLIDO!!! com %d erros", nerros);
    }
}

int yyerror(char *s) {
    nerros ++;
    printf ( "erro sintatico/semantico : %s\n",s);
    return 0;
}
