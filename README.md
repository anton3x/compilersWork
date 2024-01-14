# Compilers Project

## Overview

Welcome to the Compilers project, a comprehensive practical project split into three parts designed for the 1st semester of the 2nd year of Informatics Engineering. This project focuses on developing a set of regular expressions, finite automata, and syntactic analysis tools to enable communication with an autonomous electric vehicle in the Compiling&Building factory.

## Part 1 - Regular Expressions and Finite Automata
### Assignment Details:

- **Objective:**
  Develop a set of regular expressions and equivalent finite automata for a set of instructions used to communicate with the autonomous vehicle.

- **Instructions:**
  1. **MAINTENANCE(V):** Instructs the vehicle to go to the maintenance station.
  2. **CHARGE-BATTERY(V):** Instructs the vehicle to go to the charging station.
  3. **DELIVERY(L,M,Q):** Instructs the vehicle to make a delivery on an assembly line.
  4. **PICKUP(LIST):** Instructs the vehicle to pick up materials from the warehouse.
  5. **STATUS(I):** Instructs the vehicle to communicate its current state.

## Part 2 - Lexical Analysis
### Assignment Details:

- **Objective:**
  Design a lexical analyzer using LEX/FLEX for the set of instructions related to the autonomous vehicle.

- **Tasks:**
  1. **Lexical Analysis:** Develop regular expressions and equivalent finite automata for each instruction.
  2. **Tokenization:** Implement LEX/FLEX to tokenize the input and identify valid instructions.
  3. **Action Triggers:** Implement actions for each recognized instruction to update and print the vehicle's state.
  4. **Error Handling:** Validate irregular situations and raise alerts when they occur.
  5. **Initial and Final State Printing:** Print the initial and final state of the vehicle.
- **How To Use:**
    ```bash #Prerequisites:
     sudo apt update
     sudo apt install gcc make bison flex
    
     #Building and Running
    
     #Navigate to the CompilersProjectV2 directory:
    cd CompilersProjectV2
    
     #Compile the lexical analyzer using this shell script:
    ./scriptV2.sh projectV2
    
     #Run the program with the input file provided:
    ./a.out fileForTestingV2.txt

## Part 3 - Syntactic Analysis
### Assignment Details:

- **Objective:**
  Develop a syntactic analyzer using YACC/BISON and its interaction with LEX/FLEX for validating and processing a file containing instructions.

- **Tasks:**
  1. **Syntax Validation:** Use YACC/BISON to recognize and validate a file containing instructions in a specific format.
  2. **Action Triggers:** Implement actions for each valid instruction to save and print the current vehicle state.
  3. **Error Handling:** Validate irregular situations and raise alerts when they occur.
  4. **Initial and Final State Printing:** Print the initial and final state of the vehicle.
  5. **Additional Instruction:** Handle a new instruction for initializing the vehicle's state.

**Stay tuned for updates and additional instructions as you progress through each part of the project. Feel free to reach me out for any clarifications or assistance.**

Happy coding! 🚀
