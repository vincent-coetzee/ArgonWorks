//
//  Interpreter.c
//  Interpreter
//
//  Created by Vincent Coetzee on 27/7/21.
//

#include "Interpreter.h"

char* _class_slot_names[19] = {"_header","_magicNumber","_classPointer","_TypeHeader","_TypeMagicNumber","_TypeClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","typeCode","extraSizeInBytes","hasBytes","instanceSizeInBytes","isValue","magicNumber","slots","superclasses"};
SlotKey classSlotKeys[19];
void InitClassPointerSlotKeys(void);

void InitClassPointerSlotKeys()
    {
    CWord offset = 0;
    for (int index=0;index<19;index++)
        {
        classSlotKeys[index].name = _class_slot_names[index];
        classSlotKeys[index].offset = offset;
        offset += 8;
        }
    }

CWord WordAtAddressAtOffset(CWord address,CWord offset)
    {
    CWordPointer pointer = (CWordPointer)(address + offset);
    return(*pointer);
    }
    
void SetWordAtAddressAtOffset(CWord value,CWord address,CWord offset)
    {
    CWordPointer pointer = (CWordPointer)(address + offset);
    *pointer = value;
    }

SInt64 IntegerAtAddressAtOffset(CWord address,CWord offset)
    {
    SInt64* pointer = (long long*)(address + offset);
    return(*pointer);
    }

void SetIntegerAtAddressAtOffset(SInt64 value,CWord address,CWord offset)
    {
    SInt64* pointer = (SInt64*)(address + offset);
    *pointer = value;
    }
    
double FloatAtAddressAtOffset(CWord address,CWord offset)
    {
    double* pointer = (double*)(address + offset);
    return(*pointer);
    }

void SetFloatAtAddressAtOffset(double value,CWord address,CWord offset)
    {
    double* pointer = (double*)(address + offset);
    *pointer = value;
    }

CWord CallSymbolWithArguments(CWord symbol,CWord* arguments,CWord count)
    {
    if (count == 1)
        {
        void (*function1)(CWord) = (void (*) (CWord)) symbol;
        function1(*arguments);
        return(0);
        }
    return(0);
    }

void CallSymbol(CWord symbol,CWord* arguments,CWord count,CWord* result)
    {
    }

SwiftClosureType MutateSymbol(CWord word)
    {
    return((SwiftClosureType)word);
    }
