/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997-2009 Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

    Sam Lantinga
    slouken@libsdl.org
*/

#import <UIKit/UIKit.h>
#include "SDL_stdinc.h"
#include "SDL_mouse.h"
#include "SDL_mouse_c.h"
#include "SDL_events.h"

@interface SDL_uikitviewcontroller : UIViewController <UIActionSheetDelegate>
{
    // Dispatch queue
    dispatch_queue_t _dispatchQueue;
    
    // A source of potential notifications
    dispatch_source_t _source;
}

@property (assign) BOOL zoomed;

@end

// RichS: Removing the multiple mice code to enable a 'double-touch-to-cancel-action'
#undef SDL_IPHONE_MULTIPLE_MICE
#if SDL_IPHONE_MULTIPLE_MICE
#define MAX_SIMULTANEOUS_TOUCHES 5
#else
#define MAX_SIMULTANEOUS_TOUCHES 1
#endif

/* *INDENT-OFF* */
#if SDL_IPHONE_KEYBOARD
@interface SDL_uikitview : UIScrollView<UITextFieldDelegate, UIGestureRecognizerDelegate> {
#else
@interface SDL_uikitview : UIScrollView {
#endif
		
	SDL_Mouse mice[MAX_SIMULTANEOUS_TOUCHES];

#if SDL_IPHONE_KEYBOARD
	UITextField *textField;
	BOOL keyboardVisible;
#endif	
	
}
    
@property (assign) CGFloat openTTDScaleFactor;
    
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)checkOrientation;
  
#if SDL_IPHONE_KEYBOARD
- (void)showKeyboard;
- (void)hideKeyboard;
- (void)initializeKeyboard;
@property (readonly) BOOL keyboardVisible;
#endif 

@end
/* *INDENT-ON* */
