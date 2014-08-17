//
//  RichS_Hack.cpp
//  openttd
//
//  Created by RichS on 8/16/14.
//
//

#include "RichS_Hack.h"

#include "stdlib.h"

#define SQ_MALLOC(__size) sq_vm_malloc_RSHack((__size));
#define SQ_FREE(__ptr,__size) sq_vm_free_RSHack((__ptr),(__size));
#define SQ_REALLOC(__ptr,__oldsize,__size) sq_vm_realloc_RSHack((__ptr),(__oldsize),(__size));

void *sq_vm_malloc_RSHack(SQUnsignedInteger size){	return malloc(size); }
void *sq_vm_realloc_RSHack(void *p, SQUnsignedInteger oldsize, SQUnsignedInteger size){ return realloc(p, size); }
void sq_vm_free_RSHack(void *p, SQUnsignedInteger size){	free(p); }