//
//  ArgonTypes.h
//  ArgonWorks
//
//  Created by Vincent Coetzee on 13/12/21.
//

#ifndef ArgonTypes_h
#define ArgonTypes_h

typedef unsigned long long SwiftWord;
typedef SwiftWord* SwiftWordPointer;
typedef long long SwiftInt;
typedef unsigned long long SwiftUInt;
typedef unsigned long long SwiftWord;

typedef struct _Slot
    {
    char* name;
    SwiftInt offset;
    }
    Slot;

#endif /* ArgonTypes_h */
