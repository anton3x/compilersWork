%x MAINTENANCE CHARGE_BATTERY PICKUP DELIVERY STATUS

%{
    // Declaration of necessary libraries
	#include <stdio.h>
	#include <stdbool.h>
	#include <string.h>
	#include <stdlib.h>

    // Array with all possible locations for the car
	char locations[4][25] = {"Maintenance Station", "Charging Station", "Warehouse", "Assembly Lines"};
	// Location where the car is currently, the value varies from 0 to 3, with 0 being "Maintenance Station" and 3 being "Assembly Lines"
	int location = 1;
	// Variable storing the car's battery charge
	float carBatteryCharge = 100;
	// Variable storing the total amount of pieces on the transport
    int totalAmountOfPiecesOnTransport = 0;
    // Variable storing the maximum amount of materials the car can transport
    int maxAmountOfMaterialsToTransport = 80;
    // Variable storing the number of different materials the car is currently transporting
    int totalOfMaterialsOnTransport = 0;
    // Array storing the types of materials the car is currently transporting
    char materialsOnTransport[80][6] = {};
    // Array storing the quantity of pieces of all types of materials the car is currently transporting, position 0 of this array corresponds to material index 0 of the above array.
    int valueMaterialsOnTransport[80] = {0};
    // Array with all possible contexts
    char contexts[6][16] = {"MAINTENANCE", "CHARGE_BATTERY", "PICKUP", "DELIVERY", "STATUS", "INITIAL"};
    // Variable storing a value between 0 and 5, with 0 being "MAINTENANCE" and 5 being "INITIAL"
    int actualContext = 5;
    // Array storing 0 or 1 for each element, and each element corresponds to a context
    int usedContexts[6] = {0};
    // Array that will store expressions passed by the file that are invalid
    char invalidTokensDetected[1000][1000] = {"\0","\0"};
    // Variable that has the index of the element of the array, in this case, the letter of that element, which is free
    int leterIterator = 0;
    // Variable that has the index of the element of the array that is free
    int wordIterator = 0;
    // Variable that contains the index of the array of materials of the nearest free element from the origin
    int IndexOfFreeElementOnMaterialsListIndex = 0;

	int numberOfTimesInMaintenance = 0; // Variable containing the number of times it went to MAINTENANCE

    // Function used to display the current STATUS of the car, both the initial STATUS and the final STATUS
    // If we want to display the final STATUS, pass true as an argument to the function
	void printCarInfo(bool finalState)
	{
		printf("Battery State: %f%%\n", carBatteryCharge);
        if (finalState == true)
		    printf("Final Location: %s\n", locations[location]);
		else
            printf("Actual Location: %s\n", locations[location]);
        printf("Pieces List: ");
        for(int i = 0; i < maxAmountOfMaterialsToTransport; i++)
        {
            if(materialsOnTransport[i][0] != '\0')
                printf("\n\tMaterial - %s ; Quantity - %d", materialsOnTransport[i], valueMaterialsOnTransport[i]);
        }
		printf("\nTotal Amount Of Pieces On Transport: %d\n", totalAmountOfPiecesOnTransport);
		printf("Number Of Times In Maintenance: %d\n", numberOfTimesInMaintenance);
		if (finalState)
		    printf("\n");
	}

    // Function responsible for counting the number of a specific character in an array
	int charCounterOnArray(char *array, int arraySize, char character)
	{
		int quantityFound = 0;
		for(int i = 0; i < arraySize; i++)
		{
			if (array[i] == character)
				quantityFound++;
		}
		return quantityFound;
	}

	// Function responsible for searching for a certain material in the array containing all the materials to transport
	// If it finds the material to search for, it returns its index in the array; if not, it returns -1
    int materialSearchOnCar(char materialType[6], char materialsOnTransport[][6])
    {
        for(int i = 0; i < maxAmountOfMaterialsToTransport; i++)
            if (strcmp(materialType, materialsOnTransport[i]) == 0)
            {
                return i;
            }
        return -1;
    }

    // Returns the index of the nearest free element in the array of materials to transport; if none is free, returns -1
    int IndexOfFreeElementOnAnyArray(char materialsOnTransport[][6])
    {
        for(int i = 0; i < maxAmountOfMaterialsToTransport; i++)
        {
            if (materialsOnTransport[i][0] == '\0')
            {
                return i;
            }
        }
        return -1;
    }
%}

%%

MAINTENANCE  {BEGIN(MAINTENANCE);actualContext = 0;usedContexts[actualContext] = 1;}
CHARGE-BATTERY    {BEGIN(CHARGE_BATTERY);actualContext = 1;usedContexts[actualContext] = 1;}
PICKUP    {BEGIN(PICKUP);actualContext = 2;usedContexts[actualContext] = 1;}
DELIVERY    {BEGIN(DELIVERY);actualContext = 3;usedContexts[actualContext] = 1;}
STATUS    {BEGIN(STATUS);actualContext = 4;usedContexts[actualContext] = 1;}
<MAINTENANCE>\([0-2]\) {
    if (invalidTokensDetected[wordIterator][0] != '\0') {wordIterator++;leterIterator = 0;}
    //prints the initial car STATUS
    printCarInfo(false);
    //prints the passed instruction
    printf("----------------------\n");
    printf("|   MAINTENANCE%s    |\n", yytext);
    printf("----------------------\n");

    //if the car has enough charge to go to MAINTENANCE or is already in MAINTENANCE
    if (carBatteryCharge >= (10 + 0.01 * totalAmountOfPiecesOnTransport) || location == 0)
    {
        //increments the MAINTENANCE visit counter
        numberOfTimesInMaintenance++;
        //if not in the MAINTENANCE station, go to the station and deduct consumed battery
        if (location != 0)
        {
            location = 0;
            carBatteryCharge -= (10 + 0.01 * totalAmountOfPiecesOnTransport);
        }

        //if the MAINTENANCE visit counter is equal to 3, display an error
        if (numberOfTimesInMaintenance >= 3)
        {
            printf("\nBe cautious, the car has already been to maintenance three times!!!\n");
            //reset the MAINTENANCE counter
            numberOfTimesInMaintenance = 0;
        }
    }
    else
    {
        printf("\nThe car doesn't have enough battery to go to maintenance");
    }
    //prints the final car STATUS
    printCarInfo(true);
    printf("\n");
    //return to the initial context
    BEGIN(INITIAL);
    actualContext = 5;
    usedContexts[actualContext] = 0;
}

<CHARGE_BATTERY>\([0-2]\) {
    if (invalidTokensDetected[wordIterator][0] != '\0') {wordIterator++;leterIterator = 0;}
    //prints the initial car STATUS
    printCarInfo(false);
    //prints the passed instruction
    printf("------------------------\n");
    printf("|  CHARGE_BATTERY%s  |\n", yytext);
    printf("------------------------\n");
    //variable with the required battery charge for the journey
    float requiredBatteryCharge = (10 + 0.01 * totalAmountOfPiecesOnTransport);

    //if it has enough charge for the journey and its battery is not at 100%
    if ((carBatteryCharge >= requiredBatteryCharge) && (carBatteryCharge != 100))
    {
        //decreases the battery charge
        carBatteryCharge -= requiredBatteryCharge;
        //car goes to the charging station
        location = 1;
        //sets the car battery charge to 100%
        carBatteryCharge = 100;
    }
    else
    {
        //if the car doesn't have enough charge or its battery is at 100%
        //displays an error for each case
        if (carBatteryCharge < requiredBatteryCharge)
            printf("\nThe car doesn't have enough battery to go to the Charging Station!!!\n");
        if (carBatteryCharge == 100)
            printf("\nThe car battery is already at 100%\n");
    }
    //prints the final car STATUS
    printCarInfo(true);
    //return to the initial context
    BEGIN(INITIAL);
    actualContext = 5;
    printf("\n");
    usedContexts[actualContext] = 0;
}

<DELIVERY>\([A-Z]{2}(0*)([1-9]|[1-9][0-9]|100),[a-zA-Z0-9]{5},[1-9][0-9]*\)  {
            if (invalidTokensDetected[wordIterator][0] != '\0') {wordIterator++;leterIterator = 0;}
            //variable to indicate if the car has enough charge for the journey, initialized as false
            bool sufficientBatteryCharge = false;
            //variable to store the required battery charge
            float requiredBatteryCharge;

            //prints the initial car STATUS
            printCarInfo(false);
            //prints the passed instruction
            for(int i = 0; i < strlen(yytext) + strlen(contexts[actualContext]) + 6; i++)
            {
                printf("-");
            }
            printf("\n|  DELIVERY%s  |\n", yytext);
            for(int i = 0; i < strlen(yytext) + strlen(contexts[actualContext]) + 6; i++)
            {
                printf("-");
            }
            printf("\n");

            //if the car is already in some assembly line, the required battery charge is assigned to the responsible variable
            //and if the car has equal or more charge than that value, sufficientBatteryCharge is set to true
            //if the car is not in any assembly line, the required battery charge is assigned to the responsible variable
            //and if the car has equal or more charge than that value, sufficientBatteryCharge is set to true
            if (location == 3) {
                requiredBatteryCharge = (5 + 0.01 * totalAmountOfPiecesOnTransport);
                if (carBatteryCharge >= requiredBatteryCharge)
                    sufficientBatteryCharge = true; //has enough charge
            } else {
                requiredBatteryCharge = (10 + 0.01 * totalAmountOfPiecesOnTransport);
                if (carBatteryCharge >= requiredBatteryCharge)
                    sufficientBatteryCharge = true; //has enough charge
            }

            //if the car has enough charge to go to the location
            if (sufficientBatteryCharge) {

                //first, we need to get the material passed in the instruction and its quantity
                //auxiliary variable for information filtering
                int lastPosition = -1;

                //arrays and integers responsible for storing the material type and its quantity
                char desiredMaterial[6] = "\0";
                int quantityPieces;

                //for each character in the passed expression, when it finds the first comma, it marks the position of that character,
                //which is the starting character of the material type, in the "lastPosition" variable
                //when it finds another comma, being the second time commas are found, we know that after the comma is the last character of the material type,
                //so we put in the array "desiredMaterial" the string that starts at the value stored in lastPosition, up to the position detected now,
                //i.e., before the second comma, and thus obtain the material type
                //for the quantity of that material, we store the position after the 2nd comma in the "lastPosition" variable,
                //and when we detect a ")", we know that before this parenthesis is the last character of the quantity of material,
                //so we just need to cut the string from "lastPosition" to before the ")"
                for (int i = 0; i < strlen(yytext); i++) //will put in the arrays the corresponding information
                {
                    if ((yytext[i] == ',') && (lastPosition == -1)) {
                        lastPosition = i + 1;
                    }
                    else if ((yytext[i] == ',') && (lastPosition != -1)) {
                        strncpy(desiredMaterial, yytext + lastPosition, i - lastPosition);
                        lastPosition = i + 1;
                    }
                    else if (yytext[i] == ')') {
                        quantityPieces = atoi(yytext + lastPosition);
                    }
                }
                //obtemos o indice do material no array que contem todos os materiais que o carro transporta
                int materialDesiredIndexOnArray = materialSearchOnCar(desiredMaterial,materialsOnTransport);

                //se retornar -1, o material nao foi encontrado no carro, entao imprime um erro
                //se encontrar, verifica se a quantityFound que o programa recebeu para DELIVERYr desse material nao e superior a quantityFound existente no carro
                //se for superior na expressao face ao carro, imprime um erro
                if (materialDesiredIndexOnArray == -1)
                {
                        printf("\nThe material doesn't exist in the car.!!!\n");
                }
                else if(quantityPieces > valueMaterialsOnTransport[materialDesiredIndexOnArray])
                {
                        printf("\nThere are not so many pieces of that material in the car!!!\n");
                }
                else
                {
                    //se o material existir no carro e a quantityFound para DELIVERY for valida faz o de baixo
                    //a bateria e subtraida a carga de bateria do carro
                    carBatteryCharge -= requiredBatteryCharge;
                    //se nao estiver na linha de montagem, coloca-o la
                    if (location != 3)
                        location = 3;

                    //a quantityFound desse material no array que armazena todas as quantityFounds de materiais e decrementada
                    valueMaterialsOnTransport[materialDesiredIndexOnArray] -= quantityPieces;
                    //variavel que contem a quantityFound total de todas as pecas de todos os materiais tambem e decrementada
                    totalAmountOfPiecesOnTransport -= quantityPieces;
                    //se no array que contem as quantityFounds de pecas de cada material a quantityFound para este material for 0, entao esse material nao existe no carro
                    //entao foi remover esse tipo de material do array que contem os tipos de materiais que estao no carro
                    if (valueMaterialsOnTransport[materialDesiredIndexOnArray] == 0)
                    {
                        //removo a string do elemento correspondente ao material
                        materialsOnTransport[materialDesiredIndexOnArray][0] = '\0';
                        //a variavel que contem o proximo elemento livre no array de materiais e chamada
                        IndexOfFreeElementOnMaterialsListIndex = IndexOfFreeElementOnAnyArray(materialsOnTransport);
                    }
                }
		    }
		    else
		    {
		        printf("\nThe car doesn't have enough battery to go to the assembly line.\n");
		    }
		    //imprimir STATUS finalState do carro
            printCarInfo(true);
            printf("\n");
            //retornar ao contexts inicial
            BEGIN(INITIAL);
            actualContext = 5;
			usedContexts[actualContext] = 0;
        }

<PICKUP>\(\[\([0-9A-Za-z]{5},(0*)[1-9][0-9]*\)(,[ ]\([0-9A-Za-z]{5},(0*)[1-9][0-9]*\))*\]\) {
            if (invalidTokensDetected[wordIterator][0] != '\0') {wordIterator++;leterIterator = 0;}
            // Print the initial STATUS of the car
            printCarInfo(false);
            // Print the passed instruction
            for(int i = 0; i < strlen(yytext) + strlen(contexts[actualContext]) + 6; i++)
            {
                printf("-");
            }
            printf("\n|  PICKUP%s  |\n", yytext);
            for(int i = 0; i < strlen(yytext) + strlen(contexts[actualContext]) + 6; i++)
            {
                printf("-");
            }
            printf("\n");
            // If the car has sufficient battery or is already in the warehouse, proceed
            if (carBatteryCharge >= (10 + 0.01 * totalAmountOfPiecesOnTransport) || (location == 2))
            {
                // Variable to store the quantity of different materials passed to the expression
                int quantityOfMaterialsInExpression = charCounterOnArray(yytext,strlen(yytext),'(') - 1;
                // Auxiliary variable for information filtering
                int lastPosition=0;
                // Auxiliary variable indicating the next free element in the array
                int IndexOfFreeElementOnArrayAux=0;
                // Auxiliary arrays to store material types and their quantities
                char arrayAux[80][15] = {"\0"};
                int quantitiesOfMaterials[80] = {0,0};

                // The working method is similar to DELIVERY, but it essentially iterates through all characters and, upon detecting a "(", but having "[" or ","
                // before that, it stores the position after the "(", which corresponds to the first character of the material type, in "lastPosition."
                // When encountering a comma that is not followed by "(", it knows that before this comma is the last character of the material type.
                // So, it extracts the index before the comma using the value of "lastPosition" to cut the string corresponding to the material type.
                // After that, it sets the "lastPosition" to the value of the index following the comma, which corresponds to the first character of the quantityFound of the material.
                // Upon detecting a comma preceded by ")" or "]" followed by a ")", it knows that before the ")" is the last character of the quantityFound of the material.
                // So, it obtains the quantityFound of that material using this index and the value of "lastPosition."
                for(int i = 1 ; i < strlen(yytext); i++)
                {
                    if ((yytext[i-1]=='[' && yytext[i]=='(' ) || ( yytext[i-1] == ',' && yytext[i]==' ' ))
                    {
                            if (yytext[i]=='(' )
                                lastPosition=i+1;
                            else
                                lastPosition=i+2;
                    }
                    if (yytext[i+1]!=' ' && yytext[i]==',')
                    {
                            strncpy(arrayAux[IndexOfFreeElementOnArrayAux], (yytext + lastPosition), i - lastPosition);
                            lastPosition=i+1;
                    }
                    if (yytext[i-1]==')' && (yytext[i]==',' || (yytext[i]==']')))
                    {
                            char p[1][10] = {"\0"};
                            strncpy(p[0], (yytext + lastPosition), i - lastPosition - 1);
                            quantitiesOfMaterials[IndexOfFreeElementOnArrayAux++] = atoi(p[0]);
                    }
                }

                // Calculate the total of all types of materials requested to be placed in the car
                // Basically, it takes the array containing all the quantityFounds of the materials requested and sums them all
                int totalQuantityOfPiecesInExpression=0; // Will contain the quantityFound of materials requested in the regular expression
                int copyOfTotalAmountOfPiecesOnTransport = totalAmountOfPiecesOnTransport; // Use a copy since the normal variable is altered throughout the program execution
                bool batterySubtractionDone = false; // To check if the battery subtraction and location have already been assigned
                for(int i = 0; i < quantityOfMaterialsInExpression; i++)
                {
                    totalQuantityOfPiecesInExpression += quantitiesOfMaterials[i]; // Increment the variable
                    if ((copyOfTotalAmountOfPiecesOnTransport + totalQuantityOfPiecesInExpression) <= maxAmountOfMaterialsToTransport) // If the car limit is not exceeded
                    {
                        if ((!batterySubtractionDone) && (location != 2)) // If the assignment has not been done and it is not there
                        {   // If it is not in the warehouse, place it there and subtract the quantityFound of battery from the trip
                            carBatteryCharge -= (10 + 0.01 * totalAmountOfPiecesOnTransport);
                            location = 2;
                        }

                        // Iterate through all elements of the array containing all materials to be transported by the car
                        // j iterates over the materials requested for PICKUP
                        // If it detects that the material being iterated at the moment is already in the car, then it increments the array of quantityFounds at that specific index with the quantityFound
                        // and resets the quantityFound of the material in the auxiliary array / also the material in the auxiliary array
                        for (int j = 0; j < 80; j++)
                        {
                            if (strcmp(materialsOnTransport[j],arrayAux[i]) == 0)
                            {
                                valueMaterialsOnTransport[j] += quantitiesOfMaterials[i];
                                totalAmountOfPiecesOnTransport += quantitiesOfMaterials[i];
                                strcpy(arrayAux[i], "\0");
                                quantitiesOfMaterials[i] = 0;
                            }
                        }

                        // Since there may be materials left in the auxiliary array that were not previously in the car, they need to be placed there
                        // So, iterate through all the materials left in the auxiliary array
                        // If the value of the element is != \0, it will include in the array of materials to be transported in the car that specific material and the corresponding quantityFound
                        // by doing this, it will reset the auxiliary arrays, both in the name of the material and in the quantityFound of that material
                        // in the final state, it will change the value of the variable that has the index of the empty element closest to the beginning of the array, from the array of materials in the car

                        if (arrayAux[i][0] != '\0')
                        {
                            strcpy(materialsOnTransport[IndexOfFreeElementOnMaterialsListIndex],arrayAux[i]);
                            valueMaterialsOnTransport[IndexOfFreeElementOnMaterialsListIndex] = quantitiesOfMaterials[i];
                            totalAmountOfPiecesOnTransport += quantitiesOfMaterials[i];
                            strcpy(arrayAux[i],"");
                            quantitiesOfMaterials[i] = 0;
                            IndexOfFreeElementOnMaterialsListIndex = IndexOfFreeElementOnAnyArray(materialsOnTransport);
                        }
                    }
                    else
                    {
                        printf("\nIt is not possible to fit all the requested materials in the car.\n");
                        i = quantityOfMaterialsInExpression; //para o loop parar
                    }
                }

            }
            else
            {
                // If there is not enough battery charge, display an error
                printf("\n!!!Insufficient battery charge!!!\n");
            }

            // Print the final STATUS of the car
            printCarInfo(true);
            printf("\n");

            // Return to the initial context
            BEGIN(INITIAL);
            actualContext = 5;
            usedContexts[actualContext] = 0;
			}
<STATUS>\((B|T|M|(T,(B|M))|(B,(T|M))|(M,(T|B))|(B,T,M)|(T,M,B)|(M,B,T)|(T,B,M)|(M,T,B)|(B,M,T))\) {
    if (invalidTokensDetected[wordIterator][0] != '\0') { wordIterator++; leterIterator = 0; }

    // Print initial STATUS of the car
    printCarInfo(false);

    // Print the instruction passed
    for (int i = 0; i < strlen(yytext) + strlen(contexts[actualContext]) + 6; i++)
    {
        printf("-");
    }
    printf("\n|  STATUS%s  |\n", yytext);
    for (int i = 0; i < strlen(yytext) + strlen(contexts[actualContext]) + 6; i++)
    {
        printf("-");
    }

    // Auxiliary array to store yytext
    char yytextAux[8] = {'\0'};

    // Store characters of yytext in yytextAux
    for (int i = 0; i < strlen(yytext); i++)
    {
        yytextAux[i] = yytext[i];
    }

    // Options available for STATUS()
    char options[3] = {'B', 'T', 'M'};
    // options[i] -> found[i] correspond to each other, if any element of "found" is true, it means the corresponding element of "options" was passed to the expression
    bool found[3] = {false, false, false};

    // For each letter that can be passed to STATUS()
    for (int i = 0; i < 3; i++)
    {
        // Check if passing one, two, or three letters, some of them correspond to the current letter
        // If B is at the 7th place in STATUS(B), if with 2 letters STATUS(T,B) -> B is at the 9th place, and with 3 letters STATUS(T,M,B) -> B is at the 11th place
        // If the if statement verifies B at any of these positions, it will set that it found the letter
        // If B stayed in the 1st position when passing more than one letter, it would define it as true because the 7th position would be B
        if (yytextAux[1] == options[i] || yytextAux[3] == options[i] || yytextAux[5] == options[i])
            found[i] = true;
    }

    printf("\n");
    if (found[0] == true) // If B is found
        printf("Battery State: %f%%\n", carBatteryCharge);
    if (found[2] == true) // If M is found
    {
        printf("Pieces List: \n");
        for (int i = 0; i < 80; i++)
        {
            if (materialsOnTransport[i][0] != '\0')
                printf("\n\tMaterial %s - Quantity %d", materialsOnTransport[i], valueMaterialsOnTransport[i]);
        }
        printf("Total Amount Of Pieces On Transport: %d\n", totalAmountOfPiecesOnTransport);
    }
    if (found[1] == true) // If T is found
        printf("Pendent Tasks: NONE\n");

    printf("\n");
    // Print final STATUS of the car
    printCarInfo(true);
    BEGIN(INITIAL);
    actualContext = 5;
    usedContexts[actualContext] = 0;
    printf("\n");
}

<MAINTENANCE,CHARGE_BATTERY,PICKUP,DELIVERY,STATUS,INITIAL>[\r] { }

<MAINTENANCE,CHARGE_BATTERY,PICKUP,DELIVERY,STATUS>. {
    // If the lexer is in one of these contexts, and an expression with "contexts..." has been passed, but not passed in the above expression,
    // it will put the name of the context in the array of invalid words
    // After that, it will increase the value of "leterIterator" by the number of characters in the context,
    // and assign the value 0 to the element of the array
    // After that, the read letter will be added to the array of invalid words, and we return to the initial context
    if (usedContexts[actualContext] == 1)
    {
        strcat(invalidTokensDetected[wordIterator], contexts[actualContext]);
        leterIterator += strlen(contexts[actualContext]);
        usedContexts[actualContext] = 0;
    }
    invalidTokensDetected[wordIterator][leterIterator++] = *yytext;
    BEGIN(INITIAL);
}

<INITIAL>. {
    // In the initial context, it only reaches here if it didn't match any context, meaning it is an invalid expression.
    // For each character read from this expression, it will be placed in the array of invalid words
    invalidTokensDetected[wordIterator][leterIterator++] = *yytext;
}

<MAINTENANCE,CHARGE_BATTERY,PICKUP,DELIVERY,STATUS,INITIAL>\n  {
    // In any context, if it identifies the \n, it will check if the first character of the element with index wordIterator in the array of invalid words is different from \0
    // If this is true, then this array element corresponds to an invalid word, so we increment wordIterator and reset leterIterator
    // Also, reset the context
    if (invalidTokensDetected[wordIterator][0] != '\0')
    {
        wordIterator++;
        leterIterator = 0;
    }
    BEGIN(INITIAL);
    actualContext = 5;
}


<<EOF>> {   if (invalidTokensDetected[wordIterator][0] != '\0') {wordIterator++;leterIterator = 0;}
            if (wordIterator != 0) {printf("Invalid Tokens: \n");}
            for (int i = 0 ; i < wordIterator; i++)
            {
                printf("Invalid Expression - %s\n", invalidTokensDetected[i]);

            }
            return 0;
       }

%%

int main()
{
    yylex();

    return 0;
}