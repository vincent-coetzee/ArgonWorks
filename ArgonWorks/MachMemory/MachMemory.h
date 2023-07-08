//
//  MachMemory.h
//  ArgonWorks
//
//  Created by Vincent Coetzee on 17/12/21.
//

#ifndef MachMemory_h
#define MachMemory_h

#import <mach/mach.h>
#import <mach/mach_init.h>
#import <mach/vm_map.h>
#import <sys/sysctl.h>
#import <mach/mach_traps.h>

mach_vm_address_t AllocateSegment(mach_vm_address_t address,vm_size_t size);
int DeallocateSegment(mach_vm_address_t address,vm_size_t size);
#endif /* MachMemory_h */
