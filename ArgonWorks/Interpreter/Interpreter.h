//
//  Interpreter.h
//  Interpreter
//
//  Created by Vincent Coetzee on 27/7/21.
//

#ifndef Interpreter_h
#define Interpreter_h

#include <stdio.h>

typedef unsigned long long CWord;
typedef CWord* CWordPointer;
typedef long SInt;
typedef long long SInt64;

typedef struct _SlotKey
    {
    char* name;
    CWord offset;
    }
    SlotKey;

typedef struct _Class
	{
	CWord _header;
	CWord _magicNumber;
	CWord _classPointer;
	CWord _TypeHeader;
	CWord _TypeMagicNumber;
	CWord _TypeClassPointer;
	CWord _ObjectHeader;
	CWord _ObjectMagicNumber;
	CWord _ObjectClassPointer;
	CWord hash;
	CWord name;
	CWord typeCode;
	CWord extraSizeInBytes;
	CWord hasBytes;
	CWord instanceSizeInBytes;
	CWord isValue;
	CWord magicNumber;
	CWord slots;
	CWord superclasses;
	}
	CClass;

typedef struct _Array
	{
	CWord _header;
	CWord _magicNumber;
	CWord _classPointer;
	CWord _CollectionHeader;
	CWord _CollectionMagicNumber;
	CWord _CollectionClassPointer;
	CWord _ObjectHeader;
	CWord _ObjectMagicNumber;
	CWord _ObjectClassPointer;
	CWord hash;
	CWord _IterableHeader;
	CWord _IterableMagicNumber;
	CWord _IterableClassPointer;
	CWord count;
	CWord elementType;
	CWord firstBlock;
	CWord size;
	}
	CArray;

typedef CArray* CArrayPointer;

typedef struct _Slot
	{
	CWord _header;
	CWord _magicNumber;
	CWord _classPointer;
	CWord _ObjectHeader;
	CWord _ObjectMagicNumber;
	CWord _ObjectClassPointer;
	CWord hash;
	CWord name;
	CWord offset;
	CWord type;
	CWord typeCode;
	}
	CSlot;

typedef CSlot* CSlotPointer;

typedef struct _String
	{
	CWord _header;
	CWord _magicNumber;
	CWord _classPointer;
	CWord _ObjectHeader;
	CWord _ObjectMagicNumber;
	CWord _ObjectClassPointer;
	CWord hash;
	CWord count;
	}
	CString;

typedef CString* CStringPointer;

typedef struct _Function
	{
	CWord _header;
	CWord _magicNumber;
	CWord _classPointer;
	CWord _InvokableHeader;
	CWord _InvokableMagicNumber;
	CWord _InvokableClassPointer;
	CWord _BehaviorHeader;
	CWord _BehaviorMagicNumber;
	CWord _BehaviorClassPointer;
	CWord _ObjectHeader;
	CWord _ObjectMagicNumber;
	CWord _ObjectClassPointer;
	CWord hash;
	}
	CFunction;

typedef CFunction* CFunctionPointer;

typedef CClass* CClassPointer;

typedef struct _Enumeration
	{
	CWord _header;
	CWord _magicNumber;
	CWord _classPointer;
	CWord _TypeHeader;
	CWord _TypeMagicNumber;
	CWord _TypeClassPointer;
	CWord _ObjectHeader;
	CWord _ObjectMagicNumber;
	CWord _ObjectClassPointer;
	CWord hash;
	CWord name;
	CWord typeCode;
	CWord cases;
	CWord valueType;
	}
	CEnumeration;

typedef CEnumeration* CEnumerationPointer;

typedef void (*SwiftClosureType) (void);

void InitClassPointerSlotKeys();
CWord WordAtAddressAtOffset(CWord address,CWord offset);
SInt64 IntegerAtAddressAtOffset(CWord address,CWord offset);
double FloatAtAddressAtOffset(CWord address,CWord offset);
void SetFloatAtAddressAtOffset(double value,CWord address,CWord offset);
void SetIntegerAtAddressAtOffset(SInt64 value,CWord address,CWord offset);
void SetWordAtAddressAtOffset(CWord value,CWord address,CWord offset);
CWord CallSymbolWithArguments(CWord symbol,CWord* arguments,unsigned long long count);
void CallSymbol(CWord symbol,CWord* arguments,CWord count,CWord* result);
SwiftClosureType MutateSymbol(CWord word);

#endif /* Interpreter_h */
