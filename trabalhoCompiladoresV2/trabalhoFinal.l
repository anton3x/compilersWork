%x MANUTENCAO CARREGA_BATERIA RECOLHE ENTREGA ESTADO

%{
	#include <stdio.h>
	#include <stdbool.h>
	#include <string.h>
	#include <stdlib.h>

	char localizacoes[4][25] = {"Posto de Manutenção","Posto de Carregamento","Armazem","Linhas de Montagem"};
	int localizacao=1; //esta associado ao vetor
	int cargaBateriaCarro=100; //carga da bateria do carro
    int quantidadeTotalDeMateriaisATransportar=0; //contador de todos os elementos que estao no carro
    int quantidadeMaximaTransporte=80; //max de todos os tipos de elementos
    int numeroDeMateriaisATransportar=0; //contador de quantos tipos de materiais diferentes transportamos
    char materiasATransportar[80][6] = {};
    int valueMateriasATransportar[80] = {0};
    char contexto[6][16] = {"MANUTENCAO", "CARREGA-BATERIA", "RECOLHE", "ENTREGA", "ESTADO", "INITIAL"};
    int contextoAtual = 5;
    char palavraInvalida[1000][100] = {"\0","\0"};
    int iteratorLetra = 0;
    int iteratorPalavra = 0;
    int iteratorElementoLivreVetor = 0;


	int numManutencao=0;
	int numCarregabateria=0;
	int numEntrega=0;
	int numRecolhe=0;
	int numEstado=0;

	void printInfo(bool final)
	{
		printf("\nEstado da bateria: %d%%\n", cargaBateriaCarro);
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
	}

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
    int procurarMaterialNoCarro(char tipoMaterial[6], char materiasATransportar[][6])
    {
        for(int i = 0; i < 80; i++)
            if (strcmp(tipoMaterial, materiasATransportar[i]) == 0)
            {
                return i;
            }
        return -1;
    }
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

MANUTENCAO  {BEGIN(MANUTENCAO);contextoAtual = 0;}
CARREGA-BATERIA    {BEGIN(CARREGA_BATERIA);contextoAtual = 1;}
RECOLHE    {BEGIN(RECOLHE);contextoAtual = 2;}
ENTREGA    {BEGIN(ENTREGA);contextoAtual = 3;}
ESTADO    {BEGIN(ESTADO);contextoAtual = 4;}

<MANUTENCAO>\([0-2]\) {
			printInfo(false);
			printf("\nMANUTENCAO%s", yytext);


			if (cargaBateriaCarro >= (10 + 0.01 * quantidadeTotalDeMateriaisATransportar))
			{
				numManutencao++; //counter de vezes que foi a manutencao
		    	if (localizacao != 0)
                {
                    localizacao=0;
		    	    cargaBateriaCarro-=(10 + 0.01 * quantidadeTotalDeMateriaisATransportar);
                }

                if (numManutencao >= 3)
                {
                    printf("\nO carro ja foi 3 vezes a manutencao, cuidado!!!");
                    numManutencao = 0; //resetar o contador de manutencao
                }

            }
			else
			{
				printf("\nNao tem carga suficiente na bateria para o carro chegar a manutencao");
			}
            printInfo(true);
			printf("\n");
			BEGIN(INITIAL);
			contextoAtual = 5;
		}
<CARREGA_BATERIA>\([0-2]\) {
			printInfo(false);
			printf("\nCARREGA_BATERIA%s", yytext);
			float quantidadeBateriaNecessaria = (10 + 0.01 * quantidadeTotalDeMateriaisATransportar);


			if ((cargaBateriaCarro >= quantidadeBateriaNecessaria) && (cargaBateriaCarro != 100))
			{
				cargaBateriaCarro -= quantidadeBateriaNecessaria;
		    	numCarregabateria++; //counter de vezes que carregou a bateria
		    	localizacao=1; //carro vai para o posto de carregamento

		    	cargaBateriaCarro=100; //bateria e resetada
			}
			else
			{
			    if (cargaBateriaCarro < quantidadeBateriaNecessaria)
				    printf("\nNao ha carga suficiente na bateria para o carro chegao ao posto de carregamento!!!");
				if (cargaBateriaCarro == 100)
				    printf("\nBateria do carro ja se encontra cheia!!!");
			}
            printInfo(true);
            BEGIN(INITIAL);
            contextoAtual = 5;
            printf("\n");
		    }

<ENTREGA>\([A-Z]{2}([1-9]|[1-9][0-9]|100),[a-zA-Z0-9]{5},[1-9][0-9]*\)  {
			bool cargaBateriaSuficiente = false;
            printInfo(false);
            printf("\nENTREGA%s", yytext);
            float quantidadeBateriaNecessaria;


            if (localizacao == 3) {
                quantidadeBateriaNecessaria = (5 + 0.01 * quantidadeTotalDeMateriaisATransportar);
                if (cargaBateriaCarro >= quantidadeBateriaNecessaria)
                    cargaBateriaSuficiente = true; //tem carga suficiente

            } else {
                quantidadeBateriaNecessaria = (10 + 0.01 * quantidadeTotalDeMateriaisATransportar);
                if (cargaBateriaCarro >= quantidadeBateriaNecessaria)
                    cargaBateriaSuficiente = true; //tem carga suficiente

            }

            if (cargaBateriaSuficiente) {

                int ultimaPosicao = -1; //variavel auxiliar para a filtragem de informacao

                char tipoMaterialDesejado[6] = "\0";
                int quantidadeMaterialDesejado;

                for (int i = 0; i < strlen(yytext); i++) //vai colocar nos vetores as informacoes correspondentes
                {
                    if ((yytext[i] == ',') && (ultimaPosicao == -1)) {
                        ultimaPosicao = i + 1;
                    }
                    else if ((yytext[i] == ',') && (ultimaPosicao != -1)) {
                        strncpy(tipoMaterialDesejado, (yytext + ultimaPosicao), i - ultimaPosicao);
                        ultimaPosicao = i + 1;
                    }
                    else if (yytext[i] == ')') {
                        char p[100] = "\0";
                        strncpy(p, (yytext + ultimaPosicao), i - ultimaPosicao);
                        quantidadeMaterialDesejado = atoi(p);

                    }
                }

                int indiceMaterialNoVetor = procurarMaterialNoCarro(tipoMaterialDesejado,materiasATransportar);

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
                    cargaBateriaCarro -= quantidadeBateriaNecessaria;
                    if (localizacao != 3)
                        localizacao = 3;
                    numEntrega++;//counter de vezes que foi a entrega

                    valueMateriasATransportar[indiceMaterialNoVetor] -= quantidadeMaterialDesejado;
                    quantidadeTotalDeMateriaisATransportar -= quantidadeMaterialDesejado;
                    if (valueMateriasATransportar[indiceMaterialNoVetor] == 0)
                    {
                        materiasATransportar[indiceMaterialNoVetor][0] = '\0';
                        iteratorElementoLivreVetor = indiceElementoLivreMaisProximo(materiasATransportar);
                    }
                }
		    }
            printInfo(true);
            printf("\n");
            BEGIN(INITIAL);
            contextoAtual = 5;
        }

<RECOLHE>\(\[\([0-9A-Za-z]{5},[1-9][0-9]*\)(,\([0-9A-Za-z]{5},[1-9][0-9]*\))*\]\) {
			printInfo(false);
		    printf("\nRECOLHE%s", yytext);


            if (cargaBateriaCarro >= (10 + 0.01 * quantidadeTotalDeMateriaisATransportar) || (localizacao == 2))
            {
                int quantidadeMateriaisExigida = contarCaracterNoVetor(yytext,strlen(yytext),'(') - 1;
                //quantidade de materiais (tipos) diferentes que nos pedem para por no carro
                int ultimaPosicao=0; //variavel auxiliar para a filtragem de informacao
                int numeroDoElementoLivreNoVetor=0; //variavel auxiliar que tem o proximo elemento livre do vetor

                char vetorAux[80][15] = {"\0"};
                int quantidadesVetorAux[80] = {0,0};

                for(int i = 1 ; i < strlen(yytext); i++) //vai colocar nos vetores as informacoes correspondentes
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


                int quantidadeTotalDaExigida=0; //calcula o total de todos os tipos de materiais que nos foram pedidos para colocar no carro
                for(int i = 0; i < quantidadeMateriaisExigida; i++)
                {
                        quantidadeTotalDaExigida+=quantidadesVetorAux[i];
                }

                //se
                if (quantidadeTotalDeMateriaisATransportar + quantidadeTotalDaExigida > quantidadeMaximaTransporte)
                    printf("\nNao e possivel colocar todos os materiais requisitados no carro");
                else
                {
                    numRecolhe++;//counter de vezes que foi recolher
                    if (localizacao != 2)
                    {
                        cargaBateriaCarro -= (10 + 0.01 * quantidadeTotalDeMateriaisATransportar);
                        localizacao = 2;
                    }

                    printf("\nOs materiais cabem no carro");
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
                printf("\n!!!Carga de bateria insuficiente!!!\n");
            }
            printInfo(true);
            printf("\n");
            BEGIN(INITIAL);
            contextoAtual = 5;
			}
<ESTADO>\((B|T|M|(T,(B|M))|(B,(T|M))|(M,(T|B))|(B,T,M)|(T,M,B)|(M,B,T)|(T,B,M)|(M,T,B)|(B,M,T))\) {

			printInfo(false);
		    printf("\nESTADO%s", yytext);

			char options[3] = {'B','T','M'}; //opcoes disponiveis que podemos passar para o ESTADO()
			bool found[3] = {false, false, false}; //options[i] -> found[i] correspondem uma a outra

			for (int i = 0; i < 3; i++) //Para cada uma das letras que podemos passar para o ESTADO()
			{
				//vai verificar se passando so uma letra, ou duas ou tres, algumas delas corresponde com a letra em causa
				//ESTADO(B) -> B ta no 7 lugar, se for com 2 letras, ESTADO(T,B) -> B ta no 9 lugar, e ESTADO(T,M,B) -> B ta no 11 lugar
				//se o if verificar o B em algum desses lugares, vai definir que encontrou a letras
				//se o B se mantivesse na 1 posicao quando passamos mais de que uma letras, ia definir igual pois a 7 posicao ia ser o B
				if (yytext[7] == options[i] || yytext[9] == options[i] || yytext[11] == options[i])
					found[i] = true;
			}

			printf("\n");
			if (found[0]==true) //Se encontrou o B
				printf("\nEstado da bateria: %d%%", cargaBateriaCarro);
			if (found[1]==true) //Se encontrou o T
			{
				printf("\nLista de peças: IMPLEMENTAR\n");
				printf("Quantidade de peças a transportar: %d", quantidadeTotalDeMateriaisATransportar);
			}
			if (found[2] == true) //Se encontrou o M
				printf("\nTAREFAS PENDENTES");

			printf("\n");
            numEstado++; //Incrementar um a variavel de contagem de vezes que se usou o ESTADO
            printInfo(true);
            BEGIN(INITIAL);
            contextoAtual = 5;
			}

<MANUTENCAO,CARREGA_BATERIA,RECOLHE,ENTREGA,ESTADO>(.*|\n) {strcat(palavraInvalida[iteratorPalavra], contexto[contextoAtual]);if (*yytext != '\n'){strcat(palavraInvalida[iteratorPalavra++], yytext);}else{iteratorPalavra++;}BEGIN(INITIAL);}
<INITIAL>. {palavraInvalida[iteratorPalavra][iteratorLetra++] = *yytext;}
<INITIAL>\n  {if (palavraInvalida[iteratorPalavra][0] != '\0'){iteratorPalavra++;iteratorLetra = 0;}}

<<EOF>> {   if (palavraInvalida[iteratorPalavra][0] != '\0') {iteratorPalavra++;}
            if (iteratorPalavra != 0) {printf("Expressoes invalidas(sintaxe): \n");}
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
