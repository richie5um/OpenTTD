#include "../../stdafx.h"
#include "../../core/bitmath_func.hpp"
#include "../../rev.h"
#include "../../string_func.h"


/*
 * This file contains objective C
 * Apple uses objective C instead of plain C to interact with OS specific/native functions
 *
 * Note: TrueLight's crosscompiler can handle this, but it likely needs a manual modification for each change in this file.
 * To insure that the crosscompiler still works, let him try any changes before they are committed
 */

/** Determine the current user's locale. */
const char *GetCurrentLocale(const char *)
{
	static char retbuf[32] = { '\0' };
	NSUserDefaults *defs = [ NSUserDefaults standardUserDefaults ];
	NSArray *languages = [ defs objectForKey:@"AppleLanguages" ];
	NSString *preferredLang = [ languages objectAtIndex:0 ];
	/* preferredLang is either 2 or 5 characters long ("xx" or "xx_YY"). */

        [ preferredLang getCString:retbuf maxLength:32 encoding:NSASCIIStringEncoding ];
	return retbuf;
}

