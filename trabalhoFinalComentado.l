%x MANUTENCAO CARREGA_BATERIA RECOLHE ENTREGA ESTADO

%{
    //declaracao das bibliotecas necessarias
	#include <stdio.h>
	#include <stdbool.h>
	#include <string.h>
	#include <stdlib.h>

    //vetor com todas as localizacoes possiveis para o carro
	char localizacoes[4][25] = {"Posto de Manutenção","Posto de Carregamento","Armazem","Linhas de Montagem"};
	//localizacao onde o carro esta no momento, o valor varia de 0 a 3, sendo 0 o "Posto de Manutencao" e 3 as "Linhas de Montagem"
	int localizacao=1;
	//variavel que armazena a carga da bateria do carro
	int cargaBateriaCarro=100;
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
    char palavraInvalida[1000][100] = {"\0","\0"};
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
		printf("Estado da bateria: %d%%\n", cargaBateriaCarro);
        if (final == true)
		    printf("Localizacao Final: %s\n", localizacoes[localizacao]);
		else
            printf("Localizacao Atual: %s\n", localizacoes[localizacao]);
        printf("Lista de peças: ");
        for(int i = 0; i< 80; i++)
        {
            if(materiasATransportar[i][0] != '\0')
                printf("\n%s-%d", materiasATransportar[i], valueMateriasATransportar[i]);
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

%%

MANUTENCAO  {BEGIN(MANUTENCAO);contextoAtual = 0;contextosUsados[contextoAtual] = 1;}
CARREGA-BATERIA    {BEGIN(CARREGA_BATERIA);contextoAtual = 1;contextosUsados[contextoAtual] = 1;}
RECOLHE    {BEGIN(RECOLHE);contextoAtual = 2;contextosUsados[contextoAtual] = 1;}
ENTREGA    {BEGIN(ENTREGA);contextoAtual = 3;contextosUsados[contextoAtual] = 1;}
ESTADO    {BEGIN(ESTADO);contextoAtual = 4;contextosUsados[contextoAtual] = 1;}

<MANUTENCAO>\([0-2]\) {
            if (palavraInvalida[iteratorPalavra][0] != '\0') {iteratorPalavra++;iteratorLetra = 0;}
            //imprime o estado inicial do carro
			printInfo(false);
			//imprime a instrucao passada
			printf("----------------------\n");
			printf("|   MANUTENCAO%s    |\n", yytext);
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
                    printf("\nO carro ja foi 3 vezes a manutencao, cuidado!!!");
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
			BEGIN(INITIAL);
			contextoAtual = 5;
			contextosUsados[contextoAtual] = 0;
		}
<CARREGA_BATERIA>\([0-2]\) {
            if (palavraInvalida[iteratorPalavra][0] != '\0') {iteratorPalavra++;iteratorLetra = 0;}
            //imprime o estado inicial do carro
			printInfo(false);
			//imprime a instrucao passada
			printf("------------------------\n");
			printf("|  CARREGA-BATERIA%s  |\n", yytext);
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
				    printf("\nNao ha carga suficiente na bateria para o carro chegao ao posto de carregamento!!!");
				if (cargaBateriaCarro == 100)
				    printf("\nBateria do carro ja se encontra cheia!!!");
			}
			//imprimir o estado final do carro
            printInfo(true);
            //retornar ao contexto inicial
            BEGIN(INITIAL);
            contextoAtual = 5;
            printf("\n");
			contextosUsados[contextoAtual] = 0;
		    }

<ENTREGA>\([A-Z]{2}([1-9]|[1-9][0-9]|100),[a-zA-Z0-9]{5},[1-9][0-9]*\)  {
            if (palavraInvalida[iteratorPalavra][0] != '\0') {iteratorPalavra++;iteratorLetra = 0;}
            //variavel que vai conter se o carro tem carga suficiente para o trajeto, se tiver fica a true, se nao false, mas e inicializada com false
			bool cargaBateriaSuficiente = false;
			//imprimir estado inicial do carro
            printInfo(false);
            //imprime a instrucao passada

            for(int i = 0; i < strlen(yytext) + strlen(contexto[contextoAtual]) + 6; i++)
            {
                printf("-");
            }
            printf("\n|  ENTREGA%s  |\n", yytext);
            for(int i = 0; i < strlen(yytext) + strlen(contexto[contextoAtual]) + 6; i++)
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
                quantidadeBateriaNecessaria = (5  + 0.01 * quantidadeTotalDeMateriaisATransportar);
                if (cargaBateriaCarro >= quantidadeBateriaNecessaria)
                    cargaBateriaSuficiente = true; //tem carga suficiente

            } else {
                quantidadeBateriaNecessaria = (10  + 0.01 * quantidadeTotalDeMateriaisATransportar);
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

                //para cada caracter da expressao passada, quando ele encontrar a primeira virgula, ele sabe que a frente dela comeca o caracter do tipo de material,
                //entao marco a posicao desse caracter, ou seja, do caracter de inicio do tipo de material, na variavel "ultimaPosicao"
                //quando encontrar outra virgula, sendo a segunda vez que encontro virgulas, sabemos que atras da virgula e o ultimo caracter do tipo de material,
                //entao colocamos no vetor "tipoMaterialDesejado" essa string que comeca no valor que esta armazenado em ultimaPosicao, ate a posicao que foi detectada agora, ou seja,
                //antes da segunda virgula e assim obtemos o tipo de material, para a quantidade desse material, guardamos a posicao depois da 2 virgula na variavel "ultimaPosicao"
                //e quando detectarmos um ")", sabemos que antes desse parentises e o ultimo caracter da quantidade de material, entao é so recortar da string desde "ultimaPosicao" ate antes do ")"
                for (int i = 0; i < strlen(yytext); i++) //vai colocar nos vetores as informacoes correspondentes
                {
                    if ((yytext[i] == ',') && (ultimaPosicao == -1)) {
                        ultimaPosicao = i + 1;
                    }
                    else if ((yytext[i] == ',') && (ultimaPosicao != -1)) {
                        //colocamos no vetor o tipo de material obtido
                        strncpy(tipoMaterialDesejado, (yytext + ultimaPosicao), i - ultimaPosicao);
                        ultimaPosicao = i + 1;
                    }
                    else if (yytext[i] == ')') {
                        //colocamos na variavel a quantidade do tipo de material
                        char p[100] = "\0";
                        strncpy(p, (yytext + ultimaPosicao), i - ultimaPosicao);
                        quantidadeMaterialDesejado = atoi(p);

                    }
                }

                //obtemos o indice do material no vetor que contem todos os materiais que o carro transporta
                int indiceMaterialNoVetor = procurarMaterialNoCarro(tipoMaterialDesejado,materiasATransportar);

                //se retornar -1, o material nao foi encontrado no carro, entao imprime um erro
                //se encontrar, verifica se a quantidade que o programa recebeu para entregar desse material nao e superior a quantidade existente no carro
                //se for superior na expressao face ao carro, imprime um erro
                if (indiceMaterialNoVetor == -1)
                {
                        printf("\npeca nao existe no carro!!!");
                }
                else if(quantidadeMaterialDesejado > valueMateriasATransportar[indiceMaterialNoVetor])
                {
                        printf("\nnao existem tantas pecas desse material no carro!!!");
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
		    //imprimir estado final do carro
            printInfo(true);
            printf("\n");
            //retornar ao contexto inicial
            BEGIN(INITIAL);
            contextoAtual = 5;
			contextosUsados[contextoAtual] = 0;
        }

<RECOLHE>\(\[\([0-9A-Za-z]{5},[1-9][0-9]*\)(,\([0-9A-Za-z]{5},[1-9][0-9]*\))*\]\) {
            if (palavraInvalida[iteratorPalavra][0] != '\0') {iteratorPalavra++;iteratorLetra = 0;}
            //imprimir estado inicial do carro
			printInfo(false);
			//imprime a instrucao passada
		    for(int i = 0; i < strlen(yytext) + strlen(contexto[contextoAtual]) + 6; i++)
            {
                printf("-");
            }
            printf("\n|  RECOLHE%s  |\n", yytext);
            for(int i = 0; i < strlen(yytext) + strlen(contexto[contextoAtual]) + 6; i++)
            {
                printf("-");
            }
            printf("\n");

            //se o carro tem bateria suficiente ou se ja se encontrar no armazem, pode seguir em frente
            if (cargaBateriaCarro >= (10 + 0.01 * quantidadeTotalDeMateriaisATransportar) || (localizacao == 2))
            {
                //variavel que armazena a quantidade de tipos de materiais diferentes que sao passados para a expressao
                int quantidadeMateriaisExigida = contarCaracterNoVetor(yytext,strlen(yytext),'(') - 1;

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
                for(int i = 1 ; i < strlen(yytext); i++)
                {
                    if ((yytext[i-1]=='[' || yytext[i-1] == ',') && yytext[i]=='(')
                    {
                            ultimaPosicao=i+1;
                    }
                    if (yytext[i+1]!='(' && yytext[i]==',')
                    {
                            strncpy(vetorAux[numeroDoElementoLivreNoVetor], (yytext + ultimaPosicao), i - ultimaPosicao);
                            ultimaPosicao=i+1;
                    }
                    if (yytext[i-1]==')' && (yytext[i]==',' || (yytext[i]==']')))
                    {
                            char p[1][2] = {"\0"};
                            strncpy(p[0], (yytext + ultimaPosicao), i - ultimaPosicao - 1);
                            quantidadesVetorAux[numeroDoElementoLivreNoVetor++] = atoi(p[0]);

                    }
                }

                //calcula o total de todos os tipos de materiais que nos foram pedidos para colocar no carro
                //basicamente pega no vetor que contem todas as quantidades dos materiais que nos foram pedidos e soma tudo
                int quantidadeTotalDaExigida=0;
                for(int i = 0; i < quantidadeMateriaisExigida; i++)
                {
                        quantidadeTotalDaExigida+=quantidadesVetorAux[i];
                }

                //se a quantidade de pecas de todos os materiais mais a quantidade de pecas que ja se encontra no carro for superior a 80, ou seja, á quantidade maxima a transportar
                //vai apresentar um erro, se nao, segue normalmente o programa
                if (quantidadeTotalDeMateriaisATransportar + quantidadeTotalDaExigida > quantidadeMaximaTransporte)
                    printf("\nNao e possivel colocar todos os materiais requisitados no carro");
                else
                {
                    //se ele nao se encontra no armazem, coloca-o la e subtrai a quantidade de bateria da viagem
                    if (localizacao != 2)
                    {
                        cargaBateriaCarro -= (10 + 0.01 * quantidadeTotalDeMateriaisATransportar);
                        localizacao = 2;
                    }

                    //o i itera por todos os elementos do vetor que contem todos os materiais a serem transportados pelo carro
                    //o j itera sobre os materiais que nos foram pedidos para recolher
                    //se detectar que o material a ser iterado no momento ja se encontra no carro, entao incrementa o vetor das quantidades naquele indice em especifico com a quantidade
                    //e reseta a quantidade do material no vetor auxiliar/o material tambem, no vetor auxiliar
                    for (int i = 0; i < 80; i++)
                    {
                        for(int j = 0; j < quantidadeMateriaisExigida; j++)
                        {
                            if (strcmp(materiasATransportar[i],vetorAux[j]) == 0)
                            {
                                valueMateriasATransportar[i] += quantidadesVetorAux[j];
                                quantidadeTotalDeMateriaisATransportar+=quantidadesVetorAux[i];
                                strcpy(vetorAux[j], "\0");
                                quantidadesVetorAux[j] = 0;

                            }
                        }
                    }

                    //visto que podem ter ficado no vetor auxiliar materiais que nao se encontravam anteriormente no carro, temos que os colocar la
                    //entao itero por todos os materiais que ficaram no vetor auxiliar
                    //se o valor do elemento for != \0, ele vai incluir no vetor dos materiais a transportar no carro esse material em questao e a quantidade correspondente
                    //ao fazer isso vai resetar os vetores auxiliares, tanto no nome do material como na quantidade desse material
                    //no final, vai alterar o valor da variavel que tem o indice do elemento vazio mais proximo do inicio do vetor, do vetor de materiais que estao no carro
                    for(int i = 0 ; i < quantidadeMateriaisExigida; i++)
                    {
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

                }

            }
            else
            {
                //se nao tiver carga suficiente apresenta um erro
                printf("\n!!!Carga de bateria insuficiente!!!\n");
            }
            //imprimir estado final do carro
            printInfo(true);
            printf("\n");
            //retornar ao contexto inicial
            BEGIN(INITIAL);
            contextoAtual = 5;
			contextosUsados[contextoAtual] = 0;
			}
<ESTADO>\((B|T|M|(T,(B|M))|(B,(T|M))|(M,(T|B))|(B,T,M)|(T,M,B)|(M,B,T)|(T,B,M)|(M,T,B)|(B,M,T))\) {
            if (palavraInvalida[iteratorPalavra][0] != '\0') {iteratorPalavra++;iteratorLetra = 0;}
            //imprimir estado inicial do carro
	    //printInfo(false);
	    //imprime a instrucao passada
	    for(int i = 0; i < strlen(yytext) + strlen(contexto[contextoAtual]) + 6; i++)
            {
                printf("-");
            }
            printf("\n|  ESTADO%s  |\n", yytext);
            for(int i = 0; i < strlen(yytext) + strlen(contexto[contextoAtual]) + 6; i++)
            {
                printf("-");
            }

            //vetor auxiliar para armazenar o yytext
            char yytextAux[8] = {'\0'};
            //armazenar os caracteres de yytext em yytextAux
            for(int i = 0 ; i < strlen(yytext); i++)
            {
                yytextAux[i] = yytext[i];
            }


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
			if (yytextAux[1] == options[i] || yytextAux[3] == options[i] || yytextAux[5] == options[i])
				found[i] = true;
		}
	
		printf("\n");
		if (found[0]==true) //Se encontrou o B
			printf("Estado da bateria: %d%%\n", cargaBateriaCarro);
		if (found[2]==true) //Se encontrou o M
		{
			printf("Lista de peças: \n");
	for(int i = 0; i< 80; i++)
	{
	    if(materiasATransportar[i][0] != '\0')
		printf("%s-%d\n", materiasATransportar[i], valueMateriasATransportar[i]);
	}
			printf("Quantidade de peças a transportar: %d\n", quantidadeTotalDeMateriaisATransportar);
		}
			if (found[1] == true) //Se encontrou o T
				printf("TAREFAS PENDENTES: NENHUMA\n");

			printf("\n");
            //imprimir estado inicial do carro
            //printInfo(true);
            BEGIN(INITIAL);
            contextoAtual = 5;
			contextosUsados[contextoAtual] = 0;
			}

<MANUTENCAO,CARREGA_BATERIA,RECOLHE,ENTREGA,ESTADO>. {
    //se ele estiver em um destes contextos, e tiver sido passada uma expressao com "CONTEXTO...", mas nao tiver passado na expressao de cima, ele vai colocar o nome do contexto no vetor de palavras invalidas
    //apos isso vai aumentar o valor do iteratorLetra com o numero de caracteres do CONTEXTO, e atribuir o valor 0 ao elemento do vetor
    //apos isso, a letra lida sera acrescentada ao vetor de palavras invalidas e voltamos ao CONTEXTO inicial
    if (contextosUsados[contextoAtual] == 1)
    {
        strcat(palavraInvalida[iteratorPalavra], contexto[contextoAtual]);
        iteratorLetra += strlen(contexto[contextoAtual]);
        contextosUsados[contextoAtual] = 0;
    }
    palavraInvalida[iteratorPalavra][iteratorLetra++] = *yytext;
    BEGIN(INITIAL);

}

<INITIAL>. {
    //no contexto inicial so chega aqui se nao passou em nenhum contexto, ou seja, é uma expresao invalida.
    //para cada caracter lido dessa expressao, vai ser colocado no vetor de palavras invalidas
    palavraInvalida[iteratorPalavra][iteratorLetra++] = *yytext;
}

<MANUTENCAO,CARREGA_BATERIA,RECOLHE,ENTREGA,ESTADO,INITIAL>\n  {
    //em qualquer contexto, se identificar o \n, vai verificar se o primeiro caracter do elemento com indice iteratorPalavra no vetor de palavras invalidas é diferente de \0
    //se isso se verificar, entao esse elemento do vetor corresponde a uma palavra invalida, entao incrementamos o iteratorPalavra e resetamos o iteratorLetra
    //tambem resetamos o contexto
    if (palavraInvalida[iteratorPalavra][0] != '\0')
    {
        iteratorPalavra++;
        iteratorLetra = 0;
    }
    BEGIN(INITIAL);
    contextoAtual = 5;
}

<<EOF>> {   if (palavraInvalida[iteratorPalavra][0] != '\0') {iteratorPalavra++;iteratorLetra = 0;}
            if (iteratorPalavra != 0) {printf("Expressoes/palavras invalidas(sintaxe): \n");}
            for (int i = 0 ; i < iteratorPalavra; i++)
            {
                printf("EXPRESSAO INVALIDA - %s\n", palavraInvalida[i]);

            }
            return 0;
       }

%%

int main()
{
    yylex();

    return 0;
}
