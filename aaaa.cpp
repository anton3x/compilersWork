#include <iostream>
#include <string.h>

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

void procurarMaterialNoCarro(char tipoMaterial[6], char materiasATransportar[][6])
{
    printf("%s", materiasATransportar[0]);
    //return 0;
}




int main(void) {
    char localizacoes[4][25] = {"Posto de Manutenção", "Posto de Carregamento", "Armazem", "Linhas de Montagem"};
    int localizacao = 1; //esta associado ao vetor
    int cargaBateriaCarro = 100; //carga da bateria do carro
    int quantidadeTotalDeMateriaisATransportar = 0; //contador de todos os elementos que estao no carro
    int quantidadeMaximaTransporte = 80; //max de todos os tipos de elementos
    int numeroDeMateriaisATransportar = 3; //contador de quantos tipos de materiais diferentes transportamos
    char materiasATransportar[80][6] = {"A4gt6", "cbv45", "13314"};
    int valueMateriasATransportar[80] = {1, 2, 3};

    int numManutencao = 0;
    int numCarregabateria = 0;
    int numEntrega = 0;
    int numRecolhe = 0;
    int numEstado = 0;


    char *yytext = "ENTREGA(LL100,cbv45,100)";//"RECOLHE([(A4gt6,9),(cbv45,36),(13314,1),(13314,1),(12345,20)])";

    bool cargaBateriaSuficiente = false;
    //printInfo();
    printf("\n%s", yytext);

    if (localizacao == 3) {
        if (cargaBateriaCarro >= (5 + 0.01 * quantidadeTotalDeMateriaisATransportar)) {
            cargaBateriaCarro -= (5 + 0.01 *
                                      quantidadeTotalDeMateriaisATransportar);//retiramos a carga da bateria correspondente
            printf("Carga bateria - %d", cargaBateriaCarro);//retirar
            cargaBateriaSuficiente = true; //tem carga suficiente
            //visto que o carro ja se encontra na linha de montagem, nao precisamos de trocar a localizacao dele
        }

    } else {
        if (cargaBateriaCarro >= (10 + 0.01 * quantidadeTotalDeMateriaisATransportar)) {
            cargaBateriaCarro -= (10 + 0.01 *
                                       quantidadeTotalDeMateriaisATransportar);//retiramos a carga da bateria correspondente
            localizacao = 3; //mover o carro para a linha de montagem
            printf("Carga bateria - %d", cargaBateriaCarro);//retirar
            cargaBateriaSuficiente = true; //tem carga suficiente
        }
    }

    if (cargaBateriaSuficiente) {
        numEntrega++;//counter de vezes que foi a entrega

        int ultimaPosicao = -1; //variavel auxiliar para a filtragem de informacao

        char tipoMaterialDesejado[6] = "\0";
        int quantidadeMaterialDesejado;

        for (int i = 6; i < strlen(yytext); i++) //vai colocar nos vetores as informacoes correspondentes
        {
            if ((yytext[i] == ',') && (ultimaPosicao == -1)) {
                ultimaPosicao = i + 1;
            }
            if ((yytext[i] == ',') && (ultimaPosicao != -1)) {
                strncpy(tipoMaterialDesejado, (yytext + ultimaPosicao), i - ultimaPosicao);
                ultimaPosicao = i + 1;
            }
            if (yytext[i] == ')') {
                char p[100] = "\0";
                strncpy(p, (yytext + ultimaPosicao), i - ultimaPosicao);
                quantidadeMaterialDesejado = atoi(p);

            }
        }
        printf("==========%s========", tipoMaterialDesejado);

        if (quantidadeMaterialDesejado <= 80) {

            procurarMaterialNoCarro(tipoMaterialDesejado,materiasATransportar);
        }


        /*
        int quantidadeTotalDaExigida = 0; //calcula o total de todos os tipos de materiais que nos foram pedidos para colocar no carro
        for (int i = 0; i < quantidadeMateriaisExigida; i++) {
            quantidadeTotalDaExigida += quantidadesVetorAux[i];
        }




        //se
        if (quantidadeTotalDeMateriaisATransportar + quantidadeTotalDaExigida > quantidadeMaximaTransporte)
            printf("a bagageira ta cheia caralho");
        else {
            printf("os materiais cabem");
            for (int i = 0; i < numeroDeMateriaisATransportar; i++) {
                for (int j = 0; j < quantidadeMateriaisExigida; j++) {
                    if (strcmp(materiasATransportar[i], vetorAux[j]) == 0) {
                        //char p[1][2] = {"\0"};
                        valueMateriasATransportar[i] += quantidadesVetorAux[j];
                        quantidadeTotalDeMateriaisATransportar += quantidadesVetorAux[i];
                        //strcpy(valueMateriasATransportar[i], valueMateriasATransportar[i] + quantidadesVetorAux[j]);
                        //strcpy(quantidadeTotalDeMateriaisATransportar, quantidadeTotalDeMateriaisATransportar + quantidadesVetorAux[j]);
                        strcpy(vetorAux[j], "\0");
                        quantidadesVetorAux[j] = 0;
                        //strcpy(quantidadesVetorAux[i], 0);
                        //break; //ADMITINDO QUE TODOS OS ELEMENTOS PASSADOS PARA A EXPRESSAO REGULAR SAO DIFERENTES
                    }
                }
            }
            for (int i = 0; i < quantidadeMateriaisExigida; i++) {
                if (vetorAux[i][0] != '\0') {
                    strcpy(materiasATransportar[numeroDeMateriaisATransportar], vetorAux[i]);
                    valueMateriasATransportar[numeroDeMateriaisATransportar++] = quantidadesVetorAux[i];
                    quantidadeTotalDeMateriaisATransportar += quantidadesVetorAux[i];
                    strcpy(vetorAux[i], "");
                    quantidadesVetorAux[i] = 0;

                }
            }

        }

        printf("\n");
        for (int i = 0; i < numeroDeMateriaisATransportar; i++) {
            printf("%s - %d\n", materiasATransportar[i], valueMateriasATransportar[i]);
        }
    }*/



    }
    return 0;
}