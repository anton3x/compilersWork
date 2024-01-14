%{
    #include <stdio.h>
    #include <stdbool.h>
    #include <string.h>
    #include <stdlib.h>
    int yyerror(char *s);
    int yylex();
    int numberOfErrors=0;
    
    // array with all possible locations for the car
    char locations[4][25] = {"Maintenance Station", "Charging Station", "Warehouse", "Assembly Lines"};
    
    // location where the car is currently, the value ranges from 0 to 3, with 0 being "Maintenance Station" and 3 being the "Assembly Lines"
    int location=1;
    // variable that stores the car's battery charge
    float batteryChargeCar=100;
    // variable that stores the total quantity of pieces in the car
    int numberOfPiecesTransporting=0;
    // variable that stores the maximum quantity of pieces the car can transport
    int maxQuantityOfMaterialToTransport=80;
    // variable that stores the number of different materials the car is currently transporting
    int numberOfMaterialsTransporting=0;
    // array that stores the types of materials the car is currently transporting
    char materialsTransportingTypes[80][6] = {};
    // array that stores the quantity of pieces for all types of materials the car is currently transporting, position 0 of this array corresponds to material index 0 of the array above.
    int quantityOfPiecesArray[80] = {0};
    int indexFreeElementOnMaterialsArray = 0;
    
    int numberOfTimesInMAINTENANCE=0; // variable that contains the number of times the car has undergone maintenance
    
    // function used to display the current state of the car, both the initial state and the final state
    // if we want to display the final state, pass true as an argument to the function
    void printCarInfo(bool final)
    {
        printf("Battery State: %.2f%%\n", batteryChargeCar);
        if (final == true)
            printf("Final Location: %s\n", locations[location]);
        else
            printf("Actual Location: %s\n", locations[location]);
        printf("Pieces List: ");
        for(int i = 0; i < 80; i++)
        {
            if(materialsTransportingTypes[i][0] != '\0')
                printf("\n\tMaterial - %s ; Quantity - %d", materialsTransportingTypes[i], quantityOfPiecesArray[i]);
        }
        printf("\nNumber Of Pieces Transporting: %d\n", numberOfPiecesTransporting);
        printf("Number Of Times in MAINTENANCE: %d\n", numberOfTimesInMAINTENANCE);
        if (final)
            printf("\n");
    }
    
    // function responsible for counting the quantity of a specific character in an array
    int charCounterOnArray(char *array, int arraySize, char character)
    {
        int quantity=0;
        for(int i = 0; i < arraySize; i++)
        {
            if (array[i] == character)
                quantity++;
        }
        return quantity;
    }
    
    // function responsible for searching for a certain material in the array that contains all materials to transport
    // if it finds the material to search for, it returns its index in the array, if not, it returns -1
    int searchMaterialInCar(char materialType[6], char materialsTransportingTypes[][6])
    {
        for(int i = 0; i < 80; i++)
            if (strcmp(materialType, materialsTransportingTypes[i]) == 0)
            {
                return i;
            }
        return -1;
    }
    
    // returns the index of the nearest free element in the array of materials to transport, if none is free, returns -1
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


instructionINIT : INIT_STATE '(' LOCATION ',' M ',' LIST_1 ',' M ')' {
    // Declaring and initializing arrays and variables to store information.
    char arrayAux1[2][1000] = {"\0"};
    int quantities[2] = {0, 0};
    int lastPosition1 = 0;

    // Copying values from Bison tokens to the corresponding arrays and variables.
    strncpy(arrayAux1[0], $3, strlen($3));
    strncpy(arrayAux1[1], $7, strlen($7));
    quantities[0] = atoi($5);
    quantities[1] = atoi($9);

    /*
    arrayAux1[0] - initial location
    arrayAux1[1] - list of materials
    quantities[0] - car battery charge
    quantities[1] - number of maintenance cycles
    */

    // Boolean variables to check the validity of location, battery, and maintenance.
    bool invalidLocation = true, invalidBattery = true, invalidMaintenance = true;
    int numlocation = -1;

    // Checking the validity of the location by comparing it with predefined locations.
    for (int i = 0; i < 4; i++)
    {
        if (strcmp(locations[i], arrayAux1[0]) == 0)
        {
            numlocation = i;
            invalidLocation = false;
        }
    }

    // Checking the validity of the battery charge.
    if (atoi($5) >= 0 && atoi($5) <= 100)
        invalidBattery = false;

    // Checking the validity of the maintenance number.
    if (atoi($9) >= 0)
        invalidMaintenance = false;

    // If all inputs are valid, proceed with the INIT_STATE operation.
    if (!invalidLocation && !invalidBattery && !invalidMaintenance)
    {
        // Displaying information about the car before initialization.
        printCarInfo(false);

        // Updating the car's location.
        location = numlocation;

        // Displaying the INIT_STATE information in a formatted manner.
        for (int i = 0; i < 20 + 6 + strlen($3) + strlen($7); i++)
        {
            printf("-");
        }
        printf("\n|   INIT-STATE(%s,%s,%s,%s)   |\n", $3, $5, $7, $9);
        for (int i = 0; i < 20 + 6 + strlen($3) + strlen($7); i++)
        {
            printf("-");
        }
        printf("\n");

        // Updating the car's battery charge.
        batteryChargeCar = quantities[0];

        // Variable to store the quantity of different materials to pick up in the expression.
        int quantityOfDifferentMaterialToPickup = charCounterOnArray(arrayAux1[1], strlen(arrayAux1[1]), '(');

        // Variables for filtering information during the process.
        int lastPosition = 0;
        int indexOfFreeElementOnArrayAux = 0;

        // Arrays to store material types and their quantities.
        char arrayAux[80][15] = {"\0"};
        int quantityArrayAux[80] = {0, 0};

        /*
        The operating method is similar to the DELIVERY function. It essentially iterates through all characters and, upon detecting a "(", but with a "[" or ",",
        if this is true, it saves the position following the "(", which corresponds to the first character of the material type in "lastPosition."
        When encountering a comma that is not followed by a "(", it knows that before this comma is the last character of the material type.
        So, we already know that by taking the index before the comma using the value of "lastPosition," we can cut the string corresponding to the material type.
        After that, we set the "lastPosition" to the value of the index following the comma, which corresponds to the first character of the material quantity.
        Upon detecting a comma preceded by a ")" or "]" and preceded by a ")", we know that before the ")" is the last character of the material quantity.
        So, we obtain the quantity of that material using that index and the value of "lastPosition."
        */

        if (strcmp(arrayAux1[1], "#") != 0)
        {
            for (int i = 1; i < strlen(arrayAux1[1]); i++)
            {
                if ((arrayAux1[1][i - 1] == '[' && arrayAux1[1][i] == '(') || (arrayAux1[1][i - 1] == ',' && arrayAux1[1][i] == ' '))
                {
                    if (arrayAux1[1][i] == '(')
                        lastPosition = i + 1;
                    else
                        lastPosition = i + 2;
                }
                if (arrayAux1[1][i + 1] != ' ' && arrayAux1[1][i] == ',')
                {
                    strncpy(arrayAux[indexOfFreeElementOnArrayAux], (arrayAux1[1] + lastPosition), i - lastPosition);
                    lastPosition = i + 1;
                }
                if (arrayAux1[1][i - 1] == ')' && (arrayAux1[1][i] == ',' || (arrayAux1[1][i] == ']')))
                {
                    char p[1][10] = {"\0"};
                    strncpy(p[0], (arrayAux1[1] + lastPosition), i - lastPosition - 1);
                    quantityArrayAux[indexOfFreeElementOnArrayAux++] = atoi(p[0]);
                }
            }

            // Calculate the total quantity of all types of materials requested to put in the car.
            int quantityTotalDaExigida = 0;
            int numberOfPiecesTransportingCopia = numberOfPiecesTransporting;

            for (int i = 0; i < quantityOfDifferentMaterialToPickup; i++)
            {
                quantityTotalDaExigida += quantityArrayAux[i];
                if ((numberOfPiecesTransportingCopia + quantityTotalDaExigida) <= maxQuantityOfMaterialToTransport)
                {
                    for (int j = 0; j < 80; j++)
                    {
                        if (strcmp(materialsTransportingTypes[j], arrayAux[i]) == 0)
                        {
                            quantityOfPiecesArray[j] += quantityArrayAux[i];
                            numberOfPiecesTransporting += quantityArrayAux[i];
                            strcpy(arrayAux[i], "\0");
                            quantityArrayAux[i] = 0;
                        }
                    }

                    if (arrayAux[i][0] != '\0')
                    {
                        strcpy(materialsTransportingTypes[indexFreeElementOnMaterialsArray], arrayAux[i]);
                        quantityOfPiecesArray[indexFreeElementOnMaterialsArray] = quantityArrayAux[i];
                        numberOfPiecesTransporting += quantityArrayAux[i];
                        strcpy(arrayAux[i], "");
                        quantityArrayAux[i] = 0;
                        indexFreeElementOnMaterialsArray = indexOfNextFreeElementInMaterialArray(materialsTransportingTypes);
                    }
                }
                else
                {
                    printf("\nUnable to place all requested materials in the car\n");
                    i = quantityOfDifferentMaterialToPickup; //make loop stop
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

instructions :  instructionINIT instructionS
           |  instruction instructionS
           ;
instructionS : /*empty*/
            | instructionS ';' instruction
            ;

instruction : MAINTENANCE '(' M ')' {
    if ((atoi($3) >= 0 && atoi($3) <= 2) && (strlen($3) == 1))
    {
    // Print the initial state of the car
    printCarInfo(false);

    // Print the passed instruction
    printf("----------------------\n");
    printf("|   %s(%s)    |\n", $1, $3);
    printf("----------------------\n");

    // Check if the car has enough charge to go to maintenance or is already in maintenance
    if (batteryChargeCar >= (10 + 1 * numberOfPiecesTransporting) || location == 0)
    {
    // Increment the maintenance counter
    numberOfTimesInMAINTENANCE++;

    // If not at the maintenance station, go to the maintenance station and deduct the consumed battery
    if (location != 0)
    {
    location = 0;
    batteryChargeCar -= (10 + 1 * numberOfPiecesTransporting);
    }

    // If the maintenance counter reaches 3, display an error
    if (numberOfTimesInMAINTENANCE >= 3)
    {
    printf("\nThe car has been to maintenance more than 3 times, be careful!!!\n");

    // Reset the maintenance counter
    numberOfTimesInMAINTENANCE = 0;
    }
    }
    else
    {
    printf("\nInsufficient battery charge for the car to reach maintenance");
    }

    // Print the final state of the car
    printCarInfo(true);
    printf("\n\n");

    // Return to the initial context
    }
    else
    {
    // Display an error for an invalid instruction
    printf("%s(%s) - INVALID\n\n", $1, $3);
    }

    }
            | CHARGE_BATTERY '(' M ')'  {
    if ((atoi($3) >= 0 && atoi($3) <= 2) && (strlen($3) == 1))
    {
       // Print the initial state of the car
       printCarInfo(false);

       // Print the passed instruction
       printf("------------------------\n");
       printf("|  CHARGE-BATTERY(%s)  |\n", $3);
       printf("------------------------\n");

       // Variable with the required battery quantity for the journey
       float quantityBateriaNecessaria = (10 + 1 * numberOfPiecesTransporting);

       // If the car has enough charge for the journey and its battery is not at 100%
       if ((batteryChargeCar >= quantityBateriaNecessaria) && (batteryChargeCar != 100))
       {
           // Decrease the battery charge
           batteryChargeCar -= quantityBateriaNecessaria;

           // Move the car to the charging station
           location = 1;

           // Set the car's battery charge to 100%
           batteryChargeCar = 100;
       }
       else
       {
           // If the car doesn't have enough charge or the battery is already at 100%
           // Display an error message for each case
           if (batteryChargeCar < quantityBateriaNecessaria)
               printf("\nInsufficient battery charge for the car to reach the charging station!!!\n");
           if (batteryChargeCar == 100)
               printf("\nThe car's battery is already fully charged!!!\n");
       }

       // Print the final state of the car
       printCarInfo(true);
       printf("\n\n");

       // Return to the initial context
    }
    else
    {
        // Display an error for an invalid instruction
        printf("CHARGE_BATTERY(%s) - INVALID\n\n", $3);
    }

   }
            | DELIVERY '(' M ',' M ',' M ')' {
   // Validate the delivery line
    // If 'L' was used here, it would create ambiguity with 'M', as 'M' encompasses 'L'. Therefore, 'M' is used, and its correctness is verified.
   bool validMaterial = false;
   bool validMaterialQuantity = false;
   bool validAssemblyLine = false;

   char assemblyLineAux[100] = {'\0'};
   char assemblyLineNumberCHAR[100] = {'\0'};
   int assemblyLineNumber = 0; // LM035
   strncpy(assemblyLineAux, $3, strlen($3));

   if ((assemblyLineAux[0] >= 'A' && assemblyLineAux[0] <= 'Z') && (assemblyLineAux[1] >= 'A' && assemblyLineAux[1] <= 'Z'))
   {
        for (int i = 2; assemblyLineAux[i] != '\0'; i++)
        {
            assemblyLineNumberCHAR[i - 2] = assemblyLineAux[i];
        }
        assemblyLineNumber = atoi(assemblyLineNumberCHAR);
        if (assemblyLineNumber >= 1 && assemblyLineNumber <= 100)
        {
            validAssemblyLine = true;
        }
   }

   if (strlen($5) == 5)
      validMaterial = true;

   if (atoi($7) > 0)
      validMaterialQuantity = true;

   if (validMaterial && validMaterialQuantity && validAssemblyLine)
   {
      // Variable to indicate whether the car has enough charge for the journey, initialized to false
      bool batteryChargeEnough = false;

      // Print the initial state of the car
      printCarInfo(false);

      // Print the passed instruction
      for (int i = 0; i < 30; i++)
      {
          printf("-");
      }
      printf("\n|  DELIVERY(%s,%s,%s)  |\n", $3, $5, $7);
      for (int i = 0; i < 30; i++)
      {
          printf("-");
      }
      printf("\n");

      // Variable to contain the battery quantity necessary for the car to make the journey
      float quantityBateriaNecessaria;

      // If the car is already on an assembly line, the necessary battery quantity is assigned to the responsible variable, and if the car has equal or more than that value,
      // the batteryChargeEnough variable is set to true.
      // If the car is not on any assembly line, the necessary battery quantity is assigned to the responsible variable, and if the car has equal or more than that value,
      // the batteryChargeEnough variable is set to true.
      if (location == 3)
      {
          quantityBateriaNecessaria = (5 + 1 * numberOfPiecesTransporting);
          if (batteryChargeCar >= quantityBateriaNecessaria)
              batteryChargeEnough = true; // Has sufficient charge
      }
      else
      {
          quantityBateriaNecessaria = (10 + 1 * numberOfPiecesTransporting);
          if (batteryChargeCar >= quantityBateriaNecessaria)
              batteryChargeEnough = true; // Has sufficient charge
      }

       // If the car has enough charge to go to the location
       if (batteryChargeEnough)
       {
            // First, we need to obtain the material passed to the instruction and its corresponding quantity
            // Variable for information filtering
            int lastPosition = -1;

            // Array and integer responsible for storing the material type and the required quantity of that material
            char materialTypeDesired[6] = "\0";
            int quantityMaterialDesired;

            strncpy(materialTypeDesired, ($5), strlen($5));
            quantityMaterialDesired = atoi($7);

            // Obtain the index of the material in the array that contains all the materials the car transports
            int indiceMaterialNoarray = searchMaterialInCar(materialTypeDesired, materialsTransportingTypes);

            // If it returns -1, the material was not found in the car, so an error is printed
            // If found, check if the quantity received for delivery from that material is not greater than the quantity existing in the car
            // If it is greater in the expression compared to the car, print an error
            if (indiceMaterialNoarray == -1)
            {
                printf("\nPiece does not exist in the car!!!\n");
            }
            else if (quantityMaterialDesired > quantityOfPiecesArray[indiceMaterialNoarray])
            {
                printf("\nThere are not enough pieces of that material in the car!!!\n");
            }
            else
            {
                // If the material exists in the car and the quantity for delivery is valid, perform the following
                // Subtract the battery charge from the car's battery
                batteryChargeCar -= quantityBateriaNecessaria;

                // If not on the assembly line, move it there
                if (location != 3)
                    location = 3;

                // Decrement the quantity of that material in the array that stores all the quantities of materials
                quantityOfPiecesArray[indiceMaterialNoarray] -= quantityMaterialDesired;

                // Decrement the variable containing the total quantity of all pieces of all materials
                numberOfPiecesTransporting -= quantityMaterialDesired;

                // If in the array that contains the quantities of pieces of each material the quantity for this material is 0, then this material does not exist in the car
                // So, remove that type of material from the array that contains the types of materials in the car
                if (quantityOfPiecesArray[indiceMaterialNoarray] == 0)
                {
                    // Remove the string from the element corresponding to the material
                    materialsTransportingTypes[indiceMaterialNoarray][0] = '\0';

                    // Call the variable that contains the next free element in the array of materials
                    indexFreeElementOnMaterialsArray = indexOfNextFreeElementInMaterialArray(materialsTransportingTypes);
                }
            }
       }
       else
       {
           printf("\nThe car does not have enough battery to go to the assembly line\n");
       }

       // Print the final state of the car
       printCarInfo(true);
       printf("\n\n");
       // Return to the initial context
   }
   else
   {
       for (int i = 0; i < 39; i++)
       {
           printf("-");
       }
       printf("\n|  DELIVERY(%s,%s,%s)  - INVALID|\n", $3, $5, $7);
       for (int i = 0; i < 39; i++)
       {
           printf("-");
       }
       printf("\n");
       if (!validMaterial)
           printf("Invalid Material\n");
       if (!validMaterialQuantity)
           printf("Invalid Material Quantity\n");
       if (!validAssemblyLine)
           printf("Invalid Assembly Line\n");
       printf("\n\n\n");
   }
}
            | PICKUP LIST   {
    // Print the initial state of the car
    printCarInfo(false);

    // Print the passed instruction
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

    // If the car has enough battery or is already in the warehouse, it can proceed
    if (batteryChargeCar >= (10 + 1 * numberOfPiecesTransporting) || (location == 2))
    {
        // Variable that stores the quantity of different materials requested in the expression
        int quantityOfDiferentMaterialToPickup = charCounterOnArray($2, strlen($2), '(') - 1;

        // Auxiliary variables for information filtering
        int lastPosition = 0;
        int indexOfFreeElementOnArrayAux = 0;

        // Auxiliary arrays to store material types and their quantities
        char arrayAux[80][15] = {"\0"};
        int quantityArrayAux[80] = {0, 0};

        // The operating method is similar to the DELIVERY function. It essentially iterates through all characters and, upon detecting a "(", but with a "[" or ",",
        // if this is true, it saves the position following the "(", which corresponds to the first character of the material type in "lastPosition."
        // When encountering a comma that is not followed by a "(", it knows that before this comma is the last character of the material type.
        // So, we already know that by taking the index before the comma using the value of "lastPosition," we can cut the string corresponding to the material type.
        // After that, we set the "lastPosition" to the value of the index following the comma, which corresponds to the first character of the material quantity.
        // Upon detecting a comma preceded by a ")" or "]" and preceded by a ")", we know that before the ")" is the last character of the material quantity.
        // So, we obtain the quantity of that material using that index and the value of "lastPosition."
        for(int i = 1; i < strlen($2); i++)
        {
            if (($2[i - 1] == '[' && $2[i] == '(') || ($2[i - 1] == ',' && $2[i] == ' '))
            {
                if ($2[i] == '(')
                    lastPosition = i + 1;
                else
                    lastPosition = i + 2;
            }
            if ($2[i + 1] != ' ' && $2[i] == ',')
            {
                strncpy(arrayAux[indexOfFreeElementOnArrayAux], ($2 + lastPosition), i - lastPosition);
                lastPosition = i + 1;
            }
            if ($2[i - 1] == ')' && ($2[i] == ',' || ($2[i] == ']')))
            {
                char p[1][10] = {"\0"};
                strncpy(p[0], ($2 + lastPosition), i - lastPosition - 1);
                quantityArrayAux[indexOfFreeElementOnArrayAux++] = atoi(p[0]);
            }
        }

        // Calculate the total of all types of materials requested to be placed in the car
        // Basically, it takes the array containing all the quantities of the requested materials and adds them up
        int quantityTotalDaExigida = 0;
        int numberOfPiecesTransportingCopia = numberOfPiecesTransporting;
        bool used = false;

        // Iterate through the requested materials
        for(int i = 0; i < quantityOfDiferentMaterialToPickup; i++)
        {
            quantityTotalDaExigida += quantityArrayAux[i];

            // If the total quantity does not exceed the car's limit
            if ((numberOfPiecesTransportingCopia + quantityTotalDaExigida) <= maxQuantityOfMaterialToTransport)
            {
                if ((!used) && (location != 2))
                {
                    // If the assignment has not been made yet and the car is not in the warehouse, move it there and subtract the battery quantity for the trip
                    batteryChargeCar -= (10 + 1 * numberOfPiecesTransporting);
                    location = 2;
                    used = true;
                }

                // Iterate through all elements of the array containing all materials to be transported by the car
                // Iterate over the requested materials
                // If it detects that the material being iterated at the moment is already in the car, it increments the array of quantities at that specific index with the quantity
                // and resets the quantity of the material in the auxiliary array/the material as well, in the auxiliary array
                for (int j = 0; j < 80; j++)
                {
                    if (strcmp(materialsTransportingTypes[j], arrayAux[i]) == 0)
                    {
                        quantityOfPiecesArray[j] += quantityArrayAux[i];
                        numberOfPiecesTransporting += quantityArrayAux[i];
                        strcpy(arrayAux[i], "\0");
                        quantityArrayAux[i] = 0;
                    }
                }

                // Since there may be materials left in the auxiliary array that were not previously in the car, we have to put them there
                // Iterate through all materials that remained in the auxiliary array
                // If the value of the element is != \0, it will include in the array of materials to be transported in the car that material and the corresponding quantity
                // By doing this, it will reset the auxiliary arrays, both in the name of the material and in the quantity of that material
                // In the end, it will change the value of the variable that has the index of the element closest to the beginning of the array, from the array of materials that are in the car
                if (arrayAux[i][0] != '\0')
                {
                    strcpy(materialsTransportingTypes[indexFreeElementOnMaterialsArray], arrayAux[i]);
                    quantityOfPiecesArray[indexFreeElementOnMaterialsArray] = quantityArrayAux[i];
                    numberOfPiecesTransporting += quantityArrayAux[i];
                    strcpy(arrayAux[i], "");
                    quantityArrayAux[i] = 0;
                    indexFreeElementOnMaterialsArray = indexOfNextFreeElementInMaterialArray(materialsTransportingTypes);
                }
            }
            else
            {
                printf("\nUnable to place all requested materials in the car\n");
                i = quantityOfDiferentMaterialToPickup; // Stop the loop
            }
        }
    }
    else
    {
        // If there is not enough battery charge, display an error
        printf("\n!!!Insufficient battery charge!!!\n");
    }

    // Print the final state of the car
    printCarInfo(true);
    printf("\n\n");
    // Return to the initial context

    }
            | STATUS '(' I ')'  {

    // Print the initial state of the car
    printCarInfo(false);

    // Print the passed instruction
    printf("\n------------------\n");
    printf("|  STATUS(%s) |\n", $3);
    printf("------------------");

    // Available options that can be passed to the STATUS()
    char options[3] = {'B', 'T', 'M'};
    // options[i] -> found[i] correspond to each other. If any element of "found" is true, it means that the element in "options" was passed to the expression.
    bool found[3] = {false, false, false};

    // For each of the letters that can be passed to STATUS()
    for (int i = 0; i < 3; i++)
    {
    // Check if, by passing one, two, or three letters, some of them correspond to the current letter
    // STATUS(B) -> B is in the 7th position. If with 2 letters, STATUS(T, B) -> B is in the 9th position, and STATUS(T, M, B) -> B is in the 11th position
    // If the if statement verifies B in any of these positions, it will define that it found the letter
    // If B remained in the 1st position when we passed more than one letter, it would define it as equal because the 7th position would be B
    if ($3[0] == options[i] || $3[2] == options[i] || $3[4] == options[i])
    found[i] = true;
    }

    printf("\n");
    if (found[0] == true) // If it found B
    printf("Battery State: %f%%\n", batteryChargeCar);
    if (found[2] == true) // If it found M
    {
    printf("Pieces List: \n");
    for (int i = 0; i < 80; i++)
    {
    if (materialsTransportingTypes[i][0] != '\0')
        printf("\tMaterial %s - Quantity %d\n", materialsTransportingTypes[i], quantityOfPiecesArray[i]);
    }
    printf("Number Of Pieces Transporting: %d\n", numberOfPiecesTransporting);
    }
    if (found[1] == true) // If it found T
    printf("Pendent Tasks: NONE\n");

    printf("\n");
    // Print the final state of the car
    printCarInfo(true);
    printf("\n\n");
    }

    ;



%%
int main() {
    yyparse();
    yylex();
    if (numberOfErrors == 0) {
        printf("\nInput File is VALID!!!");
    } else {
        printf("\nInput File is INVALID!!! with %d errors", numberOfErrors);
    }
}

int yyerror(char *s) {
    numberOfErrors++;
    printf("Syntax/Semantic error: %s\n", s);
    return 0;
}
