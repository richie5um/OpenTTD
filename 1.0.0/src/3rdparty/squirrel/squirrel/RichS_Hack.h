//
//  RichS_Hack.h
//  openttd
//
//  Created by RichS on 8/16/14.
//
//

#ifndef __openttd__RichS_Hack__
#define __openttd__RichS_Hack__

#include "squirrel.h"

#define SQ_MALLOC(__size) sq_vm_malloc_RSHack((__size));
#define SQ_FREE(__ptr,__size) sq_vm_free_RSHack((__ptr),(__size));
#define SQ_REALLOC(__ptr,__oldsize,__size) sq_vm_realloc_RSHack((__ptr),(__oldsize),(__size));

void *sq_vm_malloc_RSHack(SQUnsignedInteger size);
void *sq_vm_realloc_RSHack(void *p, SQUnsignedInteger oldsize, SQUnsignedInteger size);
void sq_vm_free_RSHack(void *p, SQUnsignedInteger size);

#endif /* defined(__openttd__RichS_Hack__) */
