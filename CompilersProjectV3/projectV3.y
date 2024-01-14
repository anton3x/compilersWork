%{
    #include <stdio.h>
    #include <stdbool.h>
    #include <string.h>
    #include <stdlib.h>
    int yyerror(char *s);
    int yylex();
    int nerros=0;

    //array com todas as locations possiveis para o carro
    char locations[4][25] = {"Maintenance Station", "Charging Station", "Warehouse", "Assembly Lines"};
    
    //location onde o carro esta no momento, o valor varia de 0 a 3, sendo 0 o "Posto de Manutencao" e 3 as "Linhas de Montagem"
    int location=1;
    //variavel que armazena a carga da bateria do carro
    float batteryChargeCar=100;
    //variavel que armazena a quantity total de pecas que estao no carro
    int numberOfPiecesTransporting=0;
    //variavel que armazena a quantity maxima de pecas que o carro suporta
    int maxQuantityOfMaterialToTransport=80;
    //variavel que armazena o numero de materiais diferentes que o carro esta a transportar no momento
    int numberOfMaterialsTransporting=0;
    //array que armazena os tipos de materiais que o carro esta a transportar no momento
    char materialsTransportingTypes[80][6] = {};
    //array que armazena a quantity de pecas de todos os tipos de materiais que o carro esta a transportar, a posicao 0 deste array corresponde ao material indice 0 do array acima.
    int quantityOfPiecesArray[80] = {0};
    int indexFreeElementOnMaterialsArray = 0;


    int numberOfTimesInMAINTENANCE=0; //variavel que contem a quantity de vezes que foi a manutencao

    //funcao usada para exibir o estado atual do carro, tanto o estado inicial, como o estado final
    //se quisermos exibir o estado final, passado true como argumento para a funcao
    void printCarInfo(bool final)
    {
        printf("Battery State: %.2f%%\n", batteryChargeCar);
        if (final == true)
            printf("Final Location: %s\n", locations[location]);
        else
            printf("Actual Location: %s\n", locations[location]);
        printf("Pieces List: ");
        for(int i = 0; i< 80; i++)
        {
            if(materialsTransportingTypes[i][0] != '\0')
                printf("\n\tMaterial - %s ; Quantity - %d", materialsTransportingTypes[i], quantityOfPiecesArray[i]);
        }
        printf("\nNumber Of Pieces Transporting: %d\n", numberOfPiecesTransporting);
        printf("Number Of Times in MAINTENANCE: %d\n", numberOfTimesInMAINTENANCE);
        if (final)
            printf("\n");
    }

    //funcao responsavel para contar a quantity de um caracter em especifico em um array
    int charCounterOnArray(char *array, int arraySize, char caracter)
    {
        int quantity=0;
        for(int i = 0; i < arraySize; i++)
        {
            if (array[i] == caracter)
                quantity++;
        }
        return quantity;
    }

    //funcao responsavel para procurar um certo material no array que contem todos os materiais a transportar
    //se encontrar o material a procurar, retorna o indice dele no array, se nao retorna -1
    int searchMaterialInCar(char materialType[6], char materialsTransportingTypes[][6])
    {
        for(int i = 0; i < 80; i++)
            if (strcmp(materialType, materialsTransportingTypes[i]) == 0)
            {
                return i;
            }
        return -1;
    }

    //retorna o indice do elemento livre mais proximo do array de materiais a transportar, se nenhum tiver livre, retorna -1
    int indexOfNextFreeElementInMaterialArray(char materialsTransportingTypes[][6])
    {
        for(int i = 0; i < 80; i++)
        {
            if (materialsTransportingTypes[i][0] == '\0')
            {
                return i;
            }
        }
        return -1;
    }


%}

%union
{
    char *letters;
    float real;
    int inteiro;
}


%start program
%token <letters> MAINTENANCE CHARGE_BATTERY DELIVERY PICKUP STATUS INIT_STATE START_OF_INSTRUCTIONS END_OF_INSTRUCTIONS LIST I LOCATION M LIST_1




%%

program : START_OF_INSTRUCTIONS '{' instructions '}' END_OF_INSTRUCTIONS 
        ;

instructionINIT : INIT_STATE '(' LOCATION ',' M ',' LIST_1 ',' M ')'         { 
                                                                char arrayAux1[2][1000] = {"\0"};
                                                                int quantities[2] = {0,0};
                                                                int lastPosition1 = 0;
                                                                strncpy(arrayAux1[0], $3, strlen($3));
                                                                strncpy(arrayAux1[1], $7, strlen($7));
                                                                quantities[0] = atoi($5);
                                                                quantities[1] = atoi($9);
                                                                
                                                                /*arrayAux1[0] - location inicial
                                                                  arrayAux1[1] - lista de materiais
                                                                  quantities[0] - carga bateria do carro
                                                                  quantities[1] - numero de vezes que foi a manutencao
                                                                
                                                                */

                                                                bool invalidLocation = true, invalidBattery = true, invalidMaintenance = true;
                                                                int numlocation = -1;
                                                                for(int i = 0; i < 4; i++)
                                                                { 
                                                                    if(strcmp(locations[i],arrayAux1[0]) == 0)
                                                                    {
                                                                        numlocation=i;
                                                                        invalidLocation = false;
                                                                    }
                                                                }
                                                                if(atoi($5) >= 0 && atoi($5) <= 100)
                                                                    invalidBattery = false;

                                                                if(atoi($9) >= 0)
                                                                    invalidMaintenance = false;

                                                                if (!invalidLocation && !invalidBattery && !invalidMaintenance)
                                                                {
                                                                    printCarInfo(false);
                                                                    location=numlocation;
                                                                    for(int i = 0; i < 20 + 6 + strlen($3) + strlen($7); i++)
                                                                    {
                                                                        printf("-");
                                                                    }
                                                                    printf("\n|   INIT-STATE(%s,%s,%s,%s)   |\n", $3,$5,$7,$9);
                                                                    for(int i = 0; i < 20 + 6 + strlen($3) + strlen($7); i++)
                                                                    {
                                                                        printf("-");
                                                                    }
                                                                    printf("\n");

                                                                    batteryChargeCar = quantities[0];
                                                                    //variavel que armazena a quantity de tipos de materiais diferentes que sao passados para a expressao
                                                                    int quantityOfDiferentMaterialToPickup = charCounterOnArray(arrayAux1[1],strlen(arrayAux1[1]),'(');

                                                                    //variavel auxiliar para a filtragem de informacao
                                                                    int lastPosition=0;
                                                                    //variavel auxiliar que tem o proximo elemento livre do array
                                                                    int indexOfFreeElementOnArrayAux=0;

                                                                    //arrayes auxiliares para armazenar os tipos de materiais e as quantities desses materiais
                                                                    char arrayAux[80][15] = {"\0"};
                                                                    int quantityArrayAux[80] = {0,0};

                                                                    //o metodo de funcionamento e parecido ao da ENTREGA, mas basicamente ele vai percorrer todos os caracteres e ao detectar um "(", mas tem que ter antes um "[" ou ","
                                                                    //se isso se verificar ele guarda a posicao a seguir ao "(", que corresponde ao primeiro caracter do tipo de material em "lastPosition"
                                                                    //quando encontrar uma virgula que a seguir a ela nao aparece um "(", ele sabe que antes dessa virgula e o ultimo caracter do tipo de material
                                                                    //entao ja sabemos, pegamos no indice antes da virgula usando o valor de "lastPosition" conseguimos recortar a string correspondente ao tipo de material
                                                                    //a seguir a isso, colocamos no "lastPosition" o valor do indice a seguir á virgula, que corresponde ao primeiro caracter da quantity do material
                                                                    //ao detectar uma virgula antecedida por um ")" ou "]" antecedido por um ")", sabemos que antes do ")" esta o ultimo caracter da quantity do material
                                                                    //entao obtemos a quantity desse material recorrendo a esse indice e ao valor da "lastPosition"
                                                                    if(strcmp(arrayAux1[1], "#") != 0)
                                                                    {     
                                                                        for(int i = 1 ; i < strlen(arrayAux1[1]); i++)
                                                                        {
                                                                            if ((arrayAux1[1][i-1]=='[' && arrayAux1[1][i]=='(' ) || ( arrayAux1[1][i-1] == ',' && arrayAux1[1][i]==' ' ))
                                                                            {
                                                                                    if (arrayAux1[1][i]=='(' )
                                                                                        lastPosition=i+1;
                                                                                    else
                                                                                        lastPosition=i+2;
                                                                            }
                                                                            if (arrayAux1[1][i+1]!=' ' && arrayAux1[1][i]==',')
                                                                            {
                                                                                    strncpy(arrayAux[indexOfFreeElementOnArrayAux], (arrayAux1[1] + lastPosition), i - lastPosition);
                                                                                    lastPosition=i+1;
                                                                            }
                                                                            if (arrayAux1[1][i-1]==')' && (arrayAux1[1][i]==',' || (arrayAux1[1][i]==']')))
                                                                            {
                                                                                    char p[1][10] = {"\0"};
                                                                                    strncpy(p[0], (arrayAux1[1] + lastPosition), i - lastPosition - 1);
                                                                                    quantityArrayAux[indexOfFreeElementOnArrayAux++] = atoi(p[0]);

                                                                            }
                                                                        }

                                                                       //calcula o total de todos os tipos de materiais que nos foram pedidos para colocar no carro
                                                                        //basicamente pega no array que contem todas as quantities dos materiais que nos foram pedidos e soma tudo
                                                                        int quantityTotalDaExigida=0; //vai conter a quantity de materiais que foram pedidos na expressao regular
                                                                        int numberOfPiecesTransportingCopia = numberOfPiecesTransporting; //usamos uma copia pois a variavel normal vai sendo alterada ao longo da execucao do programa
                                                                        
                                                                        for(int i = 0; i < quantityOfDiferentMaterialToPickup; i++)
                                                                        {

                                                                            quantityTotalDaExigida+=quantityArrayAux[i]; //incrementa a variavel
                                                                            if ((numberOfPiecesTransportingCopia + quantityTotalDaExigida )<= maxQuantityOfMaterialToTransport) //se ainda nao ultrapassamos o limite do carro
                                                                            {
                                                                                
                                                                                //o i itera por todos os elementos do array que contem todos os materiais a serem transportados pelo carro
                                                                                //o j itera sobre os materiais que nos foram pedidos para recolher
                                                                                //se detectar que o material a ser iterado no momento ja se encontra no carro, entao incrementa o array das quantities naquele indice em especifico com a quantity
                                                                                //e reseta a quantity do material no array auxiliar/o material tambem, no array auxiliar
                                                                                for (int j = 0; j < 80; j++)
                                                                                {
                                                                                    if (strcmp(materialsTransportingTypes[j],arrayAux[i]) == 0)
                                                                                    {
                                                                                        quantityOfPiecesArray[j] += quantityArrayAux[i];
                                                                                        numberOfPiecesTransporting+=quantityArrayAux[i];
                                                                                        strcpy(arrayAux[i], "\0");
                                                                                        quantityArrayAux[i] = 0;

                                                                                    }
                                                                                }

                                                                                //visto que podem ter ficado no array auxiliar materiais que nao se encontravam anteriormente no carro, temos que os colocar la
                                                                                //entao itero por todos os materiais que ficaram no array auxiliar
                                                                                //se o valor do elemento for != \0, ele vai incluir no array dos materiais a transportar no carro esse material em questao e a quantity correspondente
                                                                                //ao fazer isso vai resetar os arrayes auxiliares, tanto no nome do material como na quantity desse material
                                                                                //no final, vai alterar o valor da variavel que tem o indice do elemento vazio mais proximo do inicio do array, do array de materiais que estao no carro

                                                                                if (arrayAux[i][0] != '\0')
                                                                                {
                                                                                    strcpy(materialsTransportingTypes[indexFreeElementOnMaterialsArray],arrayAux[i]);
                                                                                    quantityOfPiecesArray[indexFreeElementOnMaterialsArray] = quantityArrayAux[i];
                                                                                    numberOfPiecesTransporting+=quantityArrayAux[i];
                                                                                    strcpy(arrayAux[i],"");
                                                                                    quantityArrayAux[i] = 0;
                                                                                    indexFreeElementOnMaterialsArray = indexOfNextFreeElementInMaterialArray(materialsTransportingTypes);

                                                                                }


                                                                            }
                                                                            else
                                                                            {
                                                                                printf("\nNao e possivel colocar todos os materiais requisitados no carro\n");
                                                                                i = quantityOfDiferentMaterialToPickup; //para o loop parar
                                                                            }
                                                                        }
                                                                    }
                                                                    numberOfTimesInMAINTENANCE=quantities[1];
                                                                    printCarInfo(true);
                                                                    printf("\n");
                                                                }
                                                                else
                                                                {
                                                                    printf("INIT-STATE(%s,%s,%s,%s) - INVALID\n", $3,$5,$7,$9);
                                                                    if(invalidLocation)
                                                                        printf("Invalid Location!!!\n");
                                                                    if(invalidBattery)
                                                                        printf("Invalid Battery!!!\n");
                                                                    if(invalidMaintenance)
                                                                        printf("Invalid Maintenance Number!!!\n");

                                                                    printf("\n");
                                                                }
                                                                }
                                                                ;

instructions :  instructionINIT instructionS /*alterei antes o ; nao existia mas assim garante que tem que ter o ;*/
           |  instruction instructionS
           ;
instructionS : /*vazio*/
            | instructionS ';' instruction
            ;

instruction : MAINTENANCE '(' M ')' {
                                                if((atoi($3) >= 0 && atoi($3) <= 2) && (strlen($3) == 1))
                                                {
                                                    
                                                    //imprime o estado inicial do carro
                                                    printCarInfo(false);
                                                    //imprime a instrucao passada
                                                    printf("----------------------\n");
                                                    printf("|   %s(%s)    |\n",$1,$3);
                                                    printf("----------------------\n");

                                                    //se o carro tiver carga suficiente para ir a manutencao, ou se ja estiver na manutencao
                                                    if (batteryChargeCar >= (10 + 1 * numberOfPiecesTransporting) || location == 0)
                                                    {
                                                        //incrementa o contador de vezes que foi a manutencao
                                                        numberOfTimesInMAINTENANCE++;
                                                        //se nao estiver no posto de manutencao, vai para o posto de manutencao e e retirada a bateria consumida
                                                        if (location != 0)
                                                        {
                                                            location=0;
                                                            batteryChargeCar-=(10 + 1 * numberOfPiecesTransporting);
                                                        }

                                                        //se o contador de vezes que foi a manutencao for igual a 3, apresenta um erro
                                                        if (numberOfTimesInMAINTENANCE >= 3)
                                                        {
                                                            printf("\nO carro ja foi mais de 3 vezes a manutencao, cuidado!!!\n");
                                                            //resetar o contador de manutencao
                                                            numberOfTimesInMAINTENANCE = 0;
                                                        }

                                                    }
                                                    else
                                                    {
                                                        printf("\nNao tem carga suficiente na bateria para o carro chegar a manutencao");
                                                    }
                                                    //imprimir o estado final do carro
                                                    printCarInfo(true);
                                                    printf("\n\n");
                                                    //retornar ao contexto inicial
                                     			}
                                     			else
                                     			{
                                                    printf("%s(%s) - INVALID\n\n",$1, $3);
                                                }

                                     			}
          | CHARGE_BATTERY '(' M ')'  {        if((atoi($3) >= 0 && atoi($3) <= 2) && (strlen($3) == 1))
                                                {
                                                   
                                                    //imprime o estado inicial do carro
                                           			printCarInfo(false);
                                           			//imprime a instrucao passada
                                           			printf("------------------------\n");
                                           			printf("|  CHARGE-BATTERY(%s)  |\n", $3);
                                           			printf("------------------------\n");
                                           			//variavel que tem a quantity necessaria de bateria para o trajeto
                                           			float quantityBateriaNecessaria = (10 + 1 * numberOfPiecesTransporting);

                                                       //se ele tem carga suficiente para fazer o trajeto e a sua bateria nao esta a 100%
                                           			if ((batteryChargeCar >= quantityBateriaNecessaria) && (batteryChargeCar != 100))
                                           			{
                                           			    //carga da bateria e decrementada
                                           				batteryChargeCar -= quantityBateriaNecessaria;
                                           		    	//carro vai para o posto de carregamento
                                           		    	location=1;
                                                        //variavel com a carga da bateria do carro e colocada a 100%
                                           		    	batteryChargeCar=100;
                                           			}
                                           			else
                                           			{
                                           			    //se o carro nao tiver carga suficiente ou/e tiver a bateria a 100
                                           			    //para cada uma delas apresenta um erro
                                           			    if (batteryChargeCar < quantityBateriaNecessaria)
                                           				    printf("\nNao ha carga suficiente na bateria para o carro chegar ao posto de carregamento!!!\n");
                                           				if (batteryChargeCar == 100)
                                           				    printf("\nBateria do carro ja se encontra cheia!!!\n");
                                           			}
                                           			//imprimir o estado final do carro
                                                    printCarInfo(true);
                                                    printf("\n\n");
                                                    //retornar ao contexto inicial
                                                }
                                                else
                                                {
                                                    printf("CHARGE_BATTERY(%s) - INVALID\n\n", $3);
                                                }
                                        }
          | DELIVERY '(' M ',' M ',' M ')' {
                                                            //validar a linha de entrega
                                                            //se usasse o L aqui ia dar ambiguidade com o M, visto que o M engloba o L entao usasse o M e verificasse se esta correto
                                                            bool validMaterial = false;
                                                            bool validMaterialQuantity = false;
                                                            bool validAssemblyLine = false;

                                                            char assemblyLineAux[100] = {'\0'};
                                                            char assemblyLineNumberCHAR[100] = {'\0'};
                                                            int assemblyLineNumber=0; //LM035
                                                            strncpy(assemblyLineAux, $3, strlen($3));

                                                            if((assemblyLineAux[0] >= 'A' && assemblyLineAux[0] <= 'Z') && (assemblyLineAux[1] >= 'A' && assemblyLineAux[1] <= 'Z'))
                                                            {
                                                                for(int i = 2 ; assemblyLineAux[i] != '\0'; i++)
                                                                {
                                                                    assemblyLineNumberCHAR[i-2] = assemblyLineAux[i];
                                                                }
                                                                assemblyLineNumber = atoi(assemblyLineNumberCHAR);
                                                                if (assemblyLineNumber >= 1 && assemblyLineNumber <= 100)
                                                                {
                                                                    validAssemblyLine = true;
                                                                }
                                                            }

                                                            if(strlen($5) == 5)
                                                                validMaterial = true;

                                                            if (atoi($7) > 0)
                                                                validMaterialQuantity = true;

                                                            if (validMaterial && validMaterialQuantity && validAssemblyLine){
                                                               //variavel que vai conter se o carro tem carga suficiente para o trajeto, se tiver fica a true, se nao false, mas e inicializada com false
                                                               bool batteryChargeEnough = false;
                                                               //imprimir estado inicial do carro
                                                               printCarInfo(false);
                                                               //imprime a instrucao passada

                                                               for(int i = 0; i < 30; i++)
                                                               {
                                                                   printf("-");
                                                               }
                                                               printf("\n|  DELIVERY(%s,%s,%s)  |\n", $3, $5, $7);
                                                               for(int i = 0; i < 30; i++)
                                                               {
                                                                   printf("-");
                                                               }
                                                               printf("\n");
                                                               //variavel que vai conter a quantity de bateria necessaria para o carro fazer o trajeto
                                                               float quantityBateriaNecessaria;
                                                               //se o carro ja esta em alguma linha de montagem, a quantity de bateria necessaria e atribuida a variavel reponsavel e se o carro tiver mais ou igual a esse valor,
                                                               //a variavel batteryChargeEnough e colocada como verdade
                                                               //se o carro nao estiver em alguma linha de montagem, a quantity de bateria necessaria e atribuida a variavel reponsavel e se o carro tiver mais ou igual a esse valor,
                                                               //a variavel batteryChargeEnough e colocada como verdade
                                                               if (location == 3) {
                                                                   quantityBateriaNecessaria = (5  + 1 * numberOfPiecesTransporting);
                                                                   if (batteryChargeCar >= quantityBateriaNecessaria)
                                                                       batteryChargeEnough = true; //tem carga suficiente

                                                               } else {
                                                                   quantityBateriaNecessaria = (10  + 1 * numberOfPiecesTransporting);
                                                                   if (batteryChargeCar >= quantityBateriaNecessaria)
                                                                       batteryChargeEnough = true; //tem carga suficiente

                                                               }

                                                               //se o carro tem carga suficiente para ir para o local
                                                                if (batteryChargeEnough) {

                                                                    //primeiro temos que obter o material que foi passado para a instrucao e a respetiva quantity desse material
                                                                    //variavel auxiliar para a filtragem de informacao
                                                                    int lastPosition = -1;

                                                                    //array e inteiro reponsavel por armazenar o tipo de material e a quantity necessaria desse material
                                                                    char materialTypeDesired[6] = "\0";
                                                                    int quantityMaterialDesired;

                                                                    strncpy(materialTypeDesired, ($5), strlen($5));
                                                                    quantityMaterialDesired = atoi($7);

                                                                   //obtemos o indice do material no array que contem todos os materiais que o carro transporta
                                                                   int indiceMaterialNoarray = searchMaterialInCar(materialTypeDesired,materialsTransportingTypes);

                                                                   //se retornar -1, o material nao foi encontrado no carro, entao imprime um erro
                                                                   //se encontrar, verifica se a quantity que o programa recebeu para entregar desse material nao e superior a quantity existente no carro
                                                                   //se for superior na expressao face ao carro, imprime um erro
                                                                   if (indiceMaterialNoarray == -1)
                                                                   {
                                                                           printf("\npeca nao existe no carro!!!\n");
                                                                   }
                                                                   else if(quantityMaterialDesired > quantityOfPiecesArray[indiceMaterialNoarray])
                                                                   {
                                                                           printf("\nnao existem tantas pecas desse material no carro!!!\n");
                                                                   }
                                                                   else
                                                                   {
                                                                       //se o material existir no carro e a quantity para entrega for valida faz o de baixo
                                                                       //a bateria e subtraida a carga de bateria do carro
                                                                       batteryChargeCar -= quantityBateriaNecessaria;
                                                                       //se nao estiver na linha de montagem, coloca-o la
                                                                       if (location != 3)
                                                                           location = 3;

                                                                       //a quantity desse material no array que armazena todas as quantities de materiais e decrementada
                                                                       quantityOfPiecesArray[indiceMaterialNoarray] -= quantityMaterialDesired;
                                                                       //variavel que contem a quantity total de todas as pecas de todos os materiais tambem e decrementada
                                                                       numberOfPiecesTransporting -= quantityMaterialDesired;
                                                                       //se no array que contem as quantities de pecas de cada material a quantity para este material for 0, entao esse material nao existe no carro
                                                                       //entao foi remover esse tipo de material do array que contem os tipos de materiais que estao no carro
                                                                       if (quantityOfPiecesArray[indiceMaterialNoarray] == 0)
                                                                       {
                                                                           //removo a string do elemento correspondente ao material
                                                                           materialsTransportingTypes[indiceMaterialNoarray][0] = '\0';
                                                                           //a variavel que contem o proximo elemento livre no array de materiais e chamada
                                                                           indexFreeElementOnMaterialsArray = indexOfNextFreeElementInMaterialArray(materialsTransportingTypes);
                                                                       }
                                                                   }
                                                               }
                                                               else
                                                               {
                                                                    printf("\nO carro nao tem bateria suficiente para ir para a linha de montagem\n");
                                                               }
                                                                //imprimir estado final do carro
                                                               printCarInfo(true);
                                                               printf("\n\n");
                                                                //retornar ao contexto inicial
                                                                
                                                            }
                                                            else
                                                            {
                                                                    for(int i = 0; i < 39; i++)
                                                                    {
                                                                        printf("-");
                                                                    }
                                                                    printf("\n|  DELIVERY(%s,%s,%s)  - INVALID|\n", $3, $5, $7);
                                                                    for(int i = 0; i < 39; i++)
                                                                    {
                                                                        printf("-");
                                                                    }printf("\n");
                                                                    if(!validMaterial)
                                                                        printf("Material Invalido\n");
                                                                    if(!validMaterialQuantity)
                                                                        printf("quantity de Material Invalida\n");
                                                                    if(!validAssemblyLine)
                                                                        printf("Linha de Montagem Invalida\n");
                                                                    printf("\n\n\n");

                                                            }
                                                            }


          | PICKUP LIST   {               
                                            //imprimir estado inicial do carro
                                            printCarInfo(false);
                                            //imprime a instrucao passada
                                            for(int i = 0; i < strlen($2) + 13; i++)
                                            {
                                                printf("-");
                                            }
                                            printf("\n|  PICKUP%s  |\n", $2);
                                            for(int i = 0; i < strlen($2) + 13; i++)
                                            {
                                                printf("-");
                                            }
                                            printf("\n");
                                            //se o carro tem bateria suficiente ou se ja se encontrar no armazem, pode seguir em frente
                                            if (batteryChargeCar >= (10 + 1 * numberOfPiecesTransporting) || (location == 2))
                                            {
                                                //variavel que armazena a quantity de tipos de materiais diferentes que sao passados para a expressao
                                                int quantityOfDiferentMaterialToPickup = charCounterOnArray($2,strlen($2),'(') - 1;

                                                //variavel auxiliar para a filtragem de informacao
                                                int lastPosition=0;
                                                //variavel auxiliar que tem o proximo elemento livre do array
                                                int indexOfFreeElementOnArrayAux=0;

                                                //arrayes auxiliares para armazenar os tipos de materiais e as quantities desses materiais
                                                char arrayAux[80][15] = {"\0"};
                                                int quantityArrayAux[80] = {0,0};

                                                //o metodo de funcionamento e parecido ao da ENTREGA, mas basicamente ele vai percorrer todos os caracteres e ao detectar um "(", mas tem que ter antes um "[" ou ","
                                                //se isso se verificar ele guarda a posicao a seguir ao "(", que corresponde ao primeiro caracter do tipo de material em "lastPosition"
                                                //quando encontrar uma virgula que a seguir a ela nao aparece um "(", ele sabe que antes dessa virgula e o ultimo caracter do tipo de material
                                                //entao ja sabemos, pegamos no indice antes da virgula usando o valor de "lastPosition" conseguimos recortar a string correspondente ao tipo de material
                                                //a seguir a isso, colocamos no "lastPosition" o valor do indice a seguir á virgula, que corresponde ao primeiro caracter da quantity do material
                                                //ao detectar uma virgula antecedida por um ")" ou "]" antecedido por um ")", sabemos que antes do ")" esta o ultimo caracter da quantity do material
                                                //entao obtemos a quantity desse material recorrendo a esse indice e ao valor da "lastPosition"
                                                for(int i = 1 ; i < strlen($2); i++)
                                                {
                                                    if (($2[i-1]=='[' && $2[i]=='(' ) || ( $2[i-1] == ',' && $2[i]==' ' ))
                                                    {
                                                            if ($2[i]=='(' )
                                                                lastPosition=i+1;
                                                            else
                                                                lastPosition=i+2;
                                                    }
                                                    if ($2[i+1]!=' ' && $2[i]==',')
                                                    {
                                                            strncpy(arrayAux[indexOfFreeElementOnArrayAux], ($2 + lastPosition), i - lastPosition);
                                                            lastPosition=i+1;
                                                    }
                                                    if ($2[i-1]==')' && ($2[i]==',' || ($2[i]==']')))
                                                    {
                                                            char p[1][10] = {"\0"};
                                                            strncpy(p[0], ($2 + lastPosition), i - lastPosition - 1);
                                                            quantityArrayAux[indexOfFreeElementOnArrayAux++] = atoi(p[0]);

                                                    }
                                                }


                                                //calcula o total de todos os tipos de materiais que nos foram pedidos para colocar no carro
                                                //basicamente pega no array que contem todas as quantities dos materiais que nos foram pedidos e soma tudo
                                                int quantityTotalDaExigida=0; //vai conter a quantity de materiais que foram pedidos na expressao regular
                                                int numberOfPiecesTransportingCopia = numberOfPiecesTransporting; //usamos uma copia pois a variavel normal vai sendo alterada ao longo da execucao do programa
                                                bool used = false; //para verificar se a substracao da bateria e a location ja foram atribuidas
                                                for(int i = 0; i < quantityOfDiferentMaterialToPickup; i++)
                                                {

                                                    quantityTotalDaExigida+=quantityArrayAux[i]; //incrementa a variavel
                                                    if ((numberOfPiecesTransportingCopia + quantityTotalDaExigida )<= maxQuantityOfMaterialToTransport) //se ainda nao ultrapassamos o limite do carro
                                                    {
                                                        if ((!used) && (location != 2)) //se ainda nao foi feita atribuicao e se nao se encontra la
                                                        {   //se ele nao se encontra no armazem, coloca-o la e subtrai a quantity de bateria da viagem
                                                        batteryChargeCar -= (10 + 1 * numberOfPiecesTransporting);
                                                        location = 2;
                                                        }

                                                        //o i itera por todos os elementos do array que contem todos os materiais a serem transportados pelo carro
                                                        //o j itera sobre os materiais que nos foram pedidos para recolher
                                                        //se detectar que o material a ser iterado no momento ja se encontra no carro, entao incrementa o array das quantities naquele indice em especifico com a quantity
                                                        //e reseta a quantity do material no array auxiliar/o material tambem, no array auxiliar
                                                        for (int j = 0; j < 80; j++)
                                                        {
                                                            if (strcmp(materialsTransportingTypes[j],arrayAux[i]) == 0)
                                                            {
                                                                quantityOfPiecesArray[j] += quantityArrayAux[i];
                                                                numberOfPiecesTransporting+=quantityArrayAux[i];
                                                                strcpy(arrayAux[i], "\0");
                                                                quantityArrayAux[i] = 0;

                                                            }
                                                        }

                                                        //visto que podem ter ficado no array auxiliar materiais que nao se encontravam anteriormente no carro, temos que os colocar la
                                                        //entao itero por todos os materiais que ficaram no array auxiliar
                                                        //se o valor do elemento for != \0, ele vai incluir no array dos materiais a transportar no carro esse material em questao e a quantity correspondente
                                                        //ao fazer isso vai resetar os arrayes auxiliares, tanto no nome do material como na quantity desse material
                                                        //no final, vai alterar o valor da variavel que tem o indice do elemento vazio mais proximo do inicio do array, do array de materiais que estao no carro

                                                        if (arrayAux[i][0] != '\0')
                                                        {
                                                            strcpy(materialsTransportingTypes[indexFreeElementOnMaterialsArray],arrayAux[i]);
                                                            quantityOfPiecesArray[indexFreeElementOnMaterialsArray] = quantityArrayAux[i];
                                                            numberOfPiecesTransporting+=quantityArrayAux[i];
                                                            strcpy(arrayAux[i],"");
                                                            quantityArrayAux[i] = 0;
                                                            indexFreeElementOnMaterialsArray = indexOfNextFreeElementInMaterialArray(materialsTransportingTypes);
                                                        }
                                                    }
                                                    else
                                                    {
                                                        printf("\nNao e possivel colocar todos os materiais requisitados no carro\n");
                                                        i = quantityOfDiferentMaterialToPickup; //para o loop parar
                                                    }
                                                }

                                            }
                                            else
                                            {
                                                //se nao tiver carga suficiente apresenta um erro
                                                printf("\n!!!Carga de bateria insuficiente!!!\n");
                                            }
                                            //imprimir estado final do carro
                                            printCarInfo(true);
                                            printf("\n\n");
                                            //retornar ao contexto inicial
                                            
            }
          | STATUS '(' I ')'  {

                                                        //imprimir estado inicial do carro
                                            			printCarInfo(false);
                                                        //imprime a instrucao passada
                                                        printf("\n------------------\n");
                                                        printf("|  STATUS(%s) |\n", $3);
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
                                                            printf("Battery State: %f%%\n", batteryChargeCar);
                                                        if (found[2]==true) //Se encontrou o M
                                                        {
                                                            printf("Pieces List: \n");
                                                            for(int i = 0; i< 80; i++)
                                                            {
                                                                if(materialsTransportingTypes[i][0] != '\0')
                                                                    printf("\tMaterial %s - Quantity %d\n", materialsTransportingTypes[i], quantityOfPiecesArray[i]);
                                                            }
                                                            printf("Number Of Pieces Transporting: %d\n", numberOfPiecesTransporting);
                                                        }
                                                        if (found[1] == true) //Se encontrou o T
                                                            printf("Pendent Tasks: NONE\n");
                                            			printf("\n");
                                                        //imprimir estado inicial do carro
                                                        printCarInfo(true);
                                            			printf("\n\n");
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