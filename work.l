%{
	#include <stdio.h>
	#include <stdbool.h>

	char localizacoes[4][25] = {"Posto de Manutenção","Posto de Carregamento","Armazem","Linhas de Montagem"};
	int localizacao=1; //esta associado ao vetor
	int cargaBateriaCarro=100; //carga da bateria do carro
    int quantidadeTotalDeMateriaisATransportar=0; //contador de todos os elementos que estao no carro
    int quantidadeMaximaTransporte=80; //max de todos os tipos de elementos
    int numeroDeMateriaisATransportar=3; //contador de quantos tipos de materiais diferentes transportamos
    char materiasATransportar[80][6] = {"A4gt6","cbv45","13314"};
    int valueMateriasATransportar[80] = {1,2,3};
	
	int numManutencao=0;
	int numCarregabateria=0;
	int numEntrega=0;
	int numRecolhe=0;
	int numEstado=0;

	void printInfo()
	{
		printf("\nEstado da bateria: %d%%\n", cargaBateriaCarro);
		printf("Localizacao final: %s\n", localizacoes[localizacao]);
		printf("Lista de peças: IMPLEMENTAR\n");
		printf("Quantidade de peças a transportar: %d\n", quantidadeTotalDeMateriaisATransportar);
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

	
%}

%%

MANUTENCAO\([0-2]\) {
			printInfo();
			printf("\n%s", yytext);
			if (numManutencao >= 3)
			{
				printf("\nO carro vai ir com o caralho!!!");
				numManutencao = 0; //resetar o contador de manutencao
			}
			int tipoDeManutencao;
			if (yytext[11] == '0')
				{tipoDeManutencao = 0;
				//MANUTENCAO(1);
				}
			else if (yytext[11] == '1')
				tipoDeManutencao = 1;
			else
				tipoDeManutencao = 2;
			//printf("\n\nTIPO DE MANUTENCAO - %d\n\n", tipoDeManutencao);

			if (cargaBateriaCarro >= (10 + 0.01 * quantidadeTotalDeMateriaisATransportar))
			{
				numManutencao++; //counter de vezes que foi a manutencao
		    	localizacao=0;
		    	cargaBateriaCarro-=(10 + 0.01 * quantidadeTotalDeMateriaisATransportar);
				printf("\nCarga bateria - %d", cargaBateriaCarro);}
			else
			{
				printf("\nA bateria esta a morrer!!!");
			}
			printf("\n");
		    }
CARREGA-BATERIA\([0-2]\) {
			printInfo();
			printf("\n%s", yytext);
			if ((cargaBateriaCarro >= (10 + 0.01 * quantidadeTotalDeMateriaisATransportar)) && (cargaBateriaCarro != 100))
			{
				cargaBateriaCarro-=(10 + 0.01 * quantidadeTotalDeMateriaisATransportar);
		    	numCarregabateria++; //counter de vezes que carregou a bateria
		    	localizacao=1;
	        	if (cargaBateriaCarro == 100)
		    	{
					printf("ERROR 404 - Bateria do carro ja se encontra cheia\n");
	        	}
		    	cargaBateriaCarro=100;
				printf("Carga bateria - %d", cargaBateriaCarro);
			}
			else
			{
				printf("A bateria esta a morrer!!!");
			}
		    }

ENTREGA\([A-Z]{2}([1-9]|[1-9][0-9]|100),[a-zA-Z0-9]{5},[1-9][0-9]*\) {
			printInfo();
		    printf("\n%s", yytext);
            numEntrega++; //counter de vezes que foi a entrega
		    if (localizacao == 3)
		    {
		      	cargaBateriaCarro-=(5 + 0.01 * quantidadeTotalDeMateriaisATransportar); 
				printf("Carga bateria - %d", cargaBateriaCarro);//retirar
		    }
		    else{
		     	cargaBateriaCarro-=(10 + 0.01 * quantidadeTotalDeMateriaisATransportar);
				printf("Carga bateria - %d", cargaBateriaCarro);//retirar
		    }
		    }
		    
RECOLHE\(\[\([0-9A-Za-z]{5},[1-9][0-9]*\)(,\([0-9A-Za-z]{5},[1-9][0-9]*\))*\]\) {
			
			printInfo();
		    printf("\n%s", yytext);
            numRecolhe++;//counter de vezes que foi recolher
            cargaBateriaCarro-=(10 + 0.01 * quantidadeTotalDeMateriaisATransportar);

            int quantidadeMateriaisExigida = contarCaracterNoVetor(yytext,strlen(yytext),'(') - 1;
            //quantidade de materiais (tipos) diferentes que nos pedem para por no carro
            int ultimaPosicao=0; //variavel auxiliar para a filtragem de informacao
            int numeroDoElementoLivreNoVetor=0; //variavel auxiliar que tem o proximo elemento livre do vetor

            char vetorAux[80][15] = {"\0"};
            int quantidadesVetorAux[quantidadeMateriaisExigida];

            for(int i = 9 ; i < strlen(yytext); i++) //vai colocar nos vetores as informacoes correspondentes
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
                        //quantidadeMateriaisATransportar++;

                }
                }
            printf("==========%s========", vetorAux[1]);

            int quantidadeTotalDaExigida=0; //calcula o total de todos os tipos de materiais que nos foram pedidos para colocar no carro
            for(int i = 0; i < quantidadeMateriaisExigida; i++)
            {
                    quantidadeTotalDaExigida+=quantidadesVetorAux[i];
            }

            //se
            if (quantidadeTotalDeMateriaisATransportar + quantidadeTotalDaExigida > quantidadeMaximaTransporte)
                printf("a bagageira ta cheia caralho");
            else
            {
                    printf("os materiais cabem");
                    for (int i = 0; i < numeroDeMateriaisATransportar; i++)
                    {
                        for(int j = 0; j < quantidadeMateriaisExigida; j++)
                        {
                            if (strcmp(materiasATransportar[i],vetorAux[j]) == 0)
                            {
                                //char p[1][2] = {"\0"};
                                valueMateriasATransportar[i] += quantidadesVetorAux[j];
                                quantidadeTotalDeMateriaisATransportar+=quantidadesVetorAux[i];
                                //strcpy(valueMateriasATransportar[i], valueMateriasATransportar[i] + quantidadesVetorAux[j]);
                                //strcpy(quantidadeTotalDeMateriaisATransportar, quantidadeTotalDeMateriaisATransportar + quantidadesVetorAux[j]);
                                strcpy(vetorAux[j], "\0");
                                quantidadesVetorAux[j] = 0;
                                //strcpy(quantidadesVetorAux[i], 0);
                                //break; //ADMITINDO QUE TODOS OS ELEMENTOS PASSADOS PARA A EXPRESSAO REGULAR SAO DIFERENTES
                            }
                        }
                    }
                    for(int i = 0 ; i < quantidadeMateriaisExigida; i++)
                    {
                        if (vetorAux[i][0] != '\0')
                        {
                            strcpy(materiasATransportar[numeroDeMateriaisATransportar],vetorAux[i]);
                            valueMateriasATransportar[numeroDeMateriaisATransportar++] = quantidadesVetorAux[i];
                            quantidadeTotalDeMateriaisATransportar+=quantidadesVetorAux[i];
                            strcpy(vetorAux[i],"");
                            quantidadesVetorAux[i] = 0;

                        }
                    }

            }
			
	
		
			}
ESTADO\((B|T|M|(T,(B|M))|(B,(T|M))|(M,(T|B))|(B,T,M)|(T,M,B)|(M,B,T)|(T,B,M)|(M,T,B)|(B,M,T))\) {
			printInfo();
		    printf("\n%s", yytext);
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
			}

.* {printf("INVALID - %s\n", yytext);}
\n 


%%

int main()
{
yylex();
for(int i = 0; i< numeroDeMateriaisATransportar; i++)
{
	printf("\n%s-%d\n", materiasATransportar[i], valueMateriasATransportar[i]);
}

return 0;
}
