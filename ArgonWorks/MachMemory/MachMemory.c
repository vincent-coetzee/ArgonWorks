//
//  MachMemory.c
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/12/21.
//

#include <stdio.h>
#include "MachMemory.h"

mach_vm_address_t AllocateSegment(mach_vm_address_t address,vm_size_t size)
    {
    mach_vm_address_t vmAddress = address;
    int error;
//    vm_size_t hostPageSize = 0;
    
//    int pageSize = host_page_size(mach_host_self(),&hostPageSize);
    error = mach_vm_allocate(mach_task_self(),&vmAddress,size, 0);
    if (error == 0)
        {
        return(vmAddress);
        }
    if (error == KERN_INVALID_ADDRESS)
        {
        printf("The address was not valid\n");
        }
    else if (error == KERN_NO_SPACE)
        {
        printf("Not enough space in the address space\n");
        }
    return(0);
    }
    
SWord ClassAtAddress(SWord address)
    {
    SWord newAddress = address + 16;
    return(*((SWord*)newAddress));
    }
    
SWord WordAtAddress(SWord address)
    {
    return(*((SWord*)address));
    }
    
void SetWordAtAddress(SWord word,SWord address)
    {
    *((SWord*)address) = word;
    }
    
void ResetMemory(SWord address,SWord count)
    {
    void* pointer = (void*)address;
    bzero(pointer,count);
    }

int DeallocateSegment(mach_vm_address_t address,vm_size_t size)
    {
    return(mach_vm_deallocate(mach_task_self(),address,size));
    }
