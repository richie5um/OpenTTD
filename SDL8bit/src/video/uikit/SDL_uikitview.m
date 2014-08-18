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

#import "SDL_uikitview.h"
#import "SDL_windowevents_c.h"

#if SDL_IPHONE_KEYBOARD
#import "SDL_keyboard_c.h"
#import "keyinfotable.h"
#import "SDL_uikitappdelegate.h"
#import "SDL_uikitwindow.h"
#endif

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>

int VideoAddressCount = 0;
unsigned long VideoAddress[20][1024*768];
unsigned long VideoBaseAddress[1024*768];
unsigned int current_width = 0;
unsigned int current_height = 0;

SDL_uikitview* sharedSDL_uikitview = nil;
SDL_uikitviewcontroller* sharedSDL_uikitviewcontroller = nil;


@implementation SDL_uikitviewcontroller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    sharedSDL_uikitviewcontroller = self;
    
    return self;
}

- (void)loadView
{
    CGRect viewSize = [UIScreen mainScreen].bounds;
    viewSize = CGRectMake(0,0, 1024, 768);
    
    SDL_uikitview *uikitview = [[SDL_uikitview alloc] initWithFrame:viewSize];
    uikitview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    uikitview.layer.borderWidth = 1.0f;
    //[uikitview setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    self.view = uikitview;
    [uikitview release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleMultiTap:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.cancelsTouchesInView = YES;
    tapGesture.delaysTouchesBegan = YES;
    [self.view addGestureRecognizer:tapGesture];
    
    /*
     UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
     action:@selector(handlePinch:)];
     pinchGesture.cancelsTouchesInView = YES;
     pinchGesture.delaysTouchesBegan = YES;
     [self.view addGestureRecognizer:pinchGesture];
     */
    
    
    /*
     UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
     action:@selector(handleTap:)];
     [self.view addGestureRecognizer:gestureRecognizer];
     gestureRecognizer.cancelsTouchesInView = NO;  // this prevents the gesture recognizers to 'block' touches
     */
}


- (void)handlePinch:(UIGestureRecognizer *)gestureRecognizer {
}

- (void)handleMultiTap:(UIGestureRecognizer *)gestureRecognizer {
    
    NSLog( @"DoubleTap!");
    
    CGFloat scale = ((SDL_uikitview*)self.view).openTTDScaleFactor;
    if ( 1.0 == scale ) {
        scale = 2.0;
    } else {
        scale= 1.0;
    }
    
    current_width = ( IPAD_1024 * 2 ) / scale;
    current_height = ( IPAD_768 * 2 ) / scale;
    
    ((SDL_uikitview*)self.view).openTTDScaleFactor = scale;
    
    [((SDL_uikitview*)self.view) checkOrientation];
}

- (void)dealloc
{
	[super dealloc];
}

@end

@implementation SDL_uikitview

- (void)dealloc {
#if SDL_IPHONE_KEYBOARD
	SDL_DelKeyboard(0);
	[textField release];
#endif
	[super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    
}

- (void) drawLayer: (CALayer*) layer
         inContext: (CGContextRef) ctx
{
    const int buffercount = VideoAddressCount;
	const unsigned char* videobuffer = (unsigned char*)VideoAddress[buffercount == 0 ? 19 : buffercount - 1];
    
    //NSLog( @"ViewSize: %@", NSStringFromCGRect(self.frame));
    //NSLog( @"MainSize: %@", NSStringFromCGRect([UIScreen mainScreen].bounds));
    
    SDL_Window *window = SDL_GetWindowFromID([SDLUIKitDelegate sharedAppDelegate].windowID);
    
    // RichS: The rotation isn't called anymore, so these values are not set.
    if ( 0 == current_width && 0 == current_height ) {
        current_width = [UIScreen mainScreen].bounds.size.width;
        current_height = [UIScreen mainScreen].bounds.size.height;
        
        window->w = current_width;
        window->h = current_height;
        SDL_OnWindowResized(window);
    }
	
	if (NULL != window)
    {
        if (!(window->flags & SDL_WINDOW_FULLSCREEN) && !(current_width == window->w && current_height == window->h))
        {
            window->w = current_width;
            window->h = current_height;
            SDL_OnWindowResized(window);
            VideoAddressCount = 0;
            memset(VideoAddress, 0, 20*1024*768*4);
        }
    }
    else
    {
        return;
    }
    
    const int w = current_width;
    const int h = current_height;
    const int bufferlength = w*h;
    
    
    CGImageRef renderImage = CGImageCreate(
                                           w,
                                           h,
                                           8,
                                           32,
                                           w * 4,
                                           CGColorSpaceCreateDeviceRGB(),
                                           (kCGBitmapByteOrder32Host | kCGImageAlphaNoneSkipFirst),
                                           CGDataProviderCreateWithData( NULL, videobuffer, bufferlength * 4, NULL ),
                                           NULL,
                                           0,
                                           kCGRenderingIntentDefault
                                           );
    
    CGContextTranslateCTM(ctx, 0.0f, (float)h);
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
    CGContextDrawImage( ctx, CGRectMake(0, 0, (float)w, (float)h), renderImage );
    
    CGImageRelease(renderImage);
    /*
     free(tempData);
     */
    // UIGraphicsEndImageContext();
}

- (id)initWithFrame:(CGRect)frame {
    
	self = [super initWithFrame: frame];
	
    sharedSDL_uikitview = self;
    
#if SDL_IPHONE_KEYBOARD
	[self initializeKeyboard];
#endif
    
	int i;
	for (i=0; i<MAX_SIMULTANEOUS_TOUCHES; i++) {
        mice[i].id = i;
		mice[i].driverdata = NULL;
		SDL_AddMouse(&mice[i], "Mouse", 0, 0, 1);
	}
    self.opaque = YES;
    self.clearsContextBeforeDrawing = NO;
	self.multipleTouchEnabled = YES;
    [[self layer] setMinificationFilter:kCAFilterNearest];
    [[self layer] setMagnificationFilter:kCAFilterNearest];
    [[self layer] setOpaque: YES];
    
    CGSize frameSize = frame.size;
    frameSize = CGSizeMake(IPAD_1024, IPAD_768);
    [self setCenter:CGPointMake(frameSize.width/2.0, frameSize.height/2.0)];
    [self setCenter:CGPointMake(frameSize.width/2.0, frameSize.height/2.0)];
    
    _openTTDScaleFactor = 1.0;
    
    [self checkOrientation];
    
	return self;
    
}

- (void)checkOrientation
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if(UIDeviceOrientationIsPortrait(deviceOrientation))
    {
        current_width = [UIScreen mainScreen].bounds.size.width;
        current_height = [UIScreen mainScreen].bounds.size.height;
    }
    else if(true || UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        //current_width = IPAD_1024;
        //current_height = IPAD_768;
        
        current_width = ( IPAD_1024 * 2.0 ) / self.openTTDScaleFactor; //[UIScreen mainScreen].bounds.size.height;
        current_height = ( IPAD_768 * 2.0 ) / self.openTTDScaleFactor; //[UIScreen mainScreen].bounds.size.width;
        
        if(current_width > current_height)
        {
            CGAffineTransform transform = CGAffineTransformIdentity; //self.transform;
            CGPoint center = CGPointMake(768.0 / 2.0, 1024.0 / 2.0);
            self.center = center;
            // Rotate the view around its new center point.
            transform = CGAffineTransformRotate(transform, ((deviceOrientation == UIDeviceOrientationLandscapeLeft ? 1.0 : 3.0) * M_PI / 2.0));
            transform = CGAffineTransformScale(transform, self.openTTDScaleFactor, self.openTTDScaleFactor);
            if ( 1.0 != self.openTTDScaleFactor ) {
                transform = CGAffineTransformTranslate(transform, IPAD_1024/2, IPAD_768/2);
            }
            
            self.transform = transform;
            //self.frame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
            self.bounds = CGRectMake(0.0, 0.0, 1024.0, 768.0);
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Handler to easily cancel actions (by pressing with two fingers.
    if ( 1 < [event.allTouches count] ) {
        SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_ESCAPE);
		SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_ESCAPE);
        
        [self touchesEnded: touches withEvent: event];
    } else {
        NSEnumerator *enumerator = [touches objectEnumerator];
        UITouch *touch =(UITouch*)[enumerator nextObject];
        
        /* associate touches with mice, so long as we have slots */
        int i;
        int found = 0;
        for(i=0; touch && i < MAX_SIMULTANEOUS_TOUCHES; i++) {
            
            /* check if this mouse is already tracking a touch */
            if (mice[i].driverdata != NULL) {
                continue;
            }
            /*
             mouse not associated with anything right now,
             associate the touch with this mouse
             */
            found = 1;
            
            /* save old mouse so we can switch back */
            int oldMouse = SDL_SelectMouse(-1);
            
            /* select this slot's mouse */
            SDL_SelectMouse(i);
            CGPoint locationInView = [touch locationInView: self];
            
            /* set driver data to touch object, we'll use touch object later */
            mice[i].driverdata = [touch retain];
            
            /* send moved event */
            SDL_SendMouseMotion(i, 0, locationInView.x, locationInView.y, 0);
            
            /* send mouse down event */
            SDL_SendMouseButton(i, SDL_PRESSED, SDL_BUTTON_LEFT);
            
            /* re-calibrate relative mouse motion */
            SDL_GetRelativeMouseState(i, NULL, NULL);
            
            /* grab next touch */
            touch = (UITouch*)[enumerator nextObject];
            
            /* switch back to our old mouse */
            SDL_SelectMouse(oldMouse);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSEnumerator *enumerator = [touches objectEnumerator];
	UITouch *touch=nil;
	
	while(touch = (UITouch *)[enumerator nextObject]) {
		/* search for the mouse slot associated with this touch */
		int i, found = NO;
		for (i=0; i<MAX_SIMULTANEOUS_TOUCHES && !found; i++) {
			if (mice[i].driverdata == touch) {
				/* found the mouse associate with the touch */
				[(UITouch*)(mice[i].driverdata) release];
				mice[i].driverdata = NULL;
				/* send mouse up */
				SDL_SendMouseButton(i, SDL_RELEASED, SDL_BUTTON_LEFT);
				/* discontinue search for this touch */
				found = YES;
			}
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	/*
     this can happen if the user puts more than 5 touches on the screen
     at once, or perhaps in other circumstances.  Usually (it seems)
     all active touches are canceled.
     */
	[self touchesEnded: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSEnumerator *enumerator = [touches objectEnumerator];
	UITouch *touch=nil;
	
	while(touch = (UITouch *)[enumerator nextObject]) {
		/* try to find the mouse associated with this touch */
		int i, found = NO;
		for (i=0; i<MAX_SIMULTANEOUS_TOUCHES && !found; i++) {
			if (mice[i].driverdata == touch) {
				/* found proper mouse */
				CGPoint locationInView = [touch locationInView: self];
				/* send moved event */
				SDL_SendMouseMotion(i, 0, locationInView.x, locationInView.y, 0);
				/* discontinue search */
				found = YES;
			}
		}
	}
}

/*
 ---- Keyboard related functionality below this line ----
 */
#if SDL_IPHONE_KEYBOARD

/* Is the iPhone virtual keyboard visible onscreen? */
- (BOOL)keyboardVisible {
	return keyboardVisible;
}

/* Set ourselves up as a UITextFieldDelegate */
- (void)initializeKeyboard {
    
	textField = [[[UITextField alloc] initWithFrame: CGRectZero] autorelease];
	textField.delegate = self;
	/* placeholder so there is something to delete! */
	textField.text = @" ";
	
	/* set UITextInputTrait properties, mostly to defaults */
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.enablesReturnKeyAutomatically = NO;
	textField.keyboardAppearance = UIKeyboardAppearanceDefault;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyDefault;
	textField.secureTextEntry = NO;
	
	textField.hidden = YES;
	keyboardVisible = NO;
	/* add the UITextField (hidden) to our view */
	[self addSubview: textField];
	
	/* create our SDL_Keyboard */
	SDL_Keyboard keyboard;
	SDL_zero(keyboard);
	SDL_AddKeyboard(&keyboard, 0);
	SDLKey keymap[SDL_NUM_SCANCODES];
	SDL_GetDefaultKeymap(keymap);
	SDL_SetKeymap(0, 0, keymap, SDL_NUM_SCANCODES);
	
}

/* reveal onscreen virtual keyboard */
- (void)showKeyboard {
	keyboardVisible = YES;
	[textField becomeFirstResponder];
}

/* hide onscreen virtual keyboard */
- (void)hideKeyboard {
	keyboardVisible = NO;
	[textField resignFirstResponder];
}

/* UITextFieldDelegate method.  Invoked when user types something. */
- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if ([string length] == 0) {
		/* it wants to replace text with nothing, ie a delete */
		SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_DELETE);
		SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_DELETE);
	}
	else {
		/* go through all the characters in the string we've been sent
         and convert them to key presses */
		int i;
		for (i=0; i<[string length]; i++) {
			
			unichar c = [string characterAtIndex: i];
			
			Uint16 mod = 0;
			SDL_scancode code;
			
			if (c < 127) {
				/* figure out the SDL_scancode and SDL_keymod for this unichar */
				code = unicharToUIKeyInfoTable[c].code;
				mod  = unicharToUIKeyInfoTable[c].mod;
			}
			else {
				/* we only deal with ASCII right now */
				code = SDL_SCANCODE_UNKNOWN;
				mod = 0;
			}
			
			if (mod & KMOD_SHIFT) {
				/* If character uses shift, press shift down */
				SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LSHIFT);
			}
			/* send a keydown and keyup even for the character */
			SDL_SendKeyboardKey( 0, SDL_PRESSED, code);
			SDL_SendKeyboardKey( 0, SDL_RELEASED, code);
			if (mod & KMOD_SHIFT) {
				/* If character uses shift, press shift back up */
				SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
			}
		}
	}
	return NO; /* don't allow the edit! (keep placeholder text there) */
}

/* Terminates the editing session */
- (BOOL)textFieldShouldReturn:(UITextField*)_textField {
	[self hideKeyboard];
	return YES;
}

#endif

@end

/* iPhone keyboard addition functions */
#if SDL_IPHONE_KEYBOARD

int SDL_iPhoneKeyboardShow(SDL_WindowID windowID) {
	
	SDL_Window *window = SDL_GetWindowFromID(windowID);
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (nil == view) {
		SDL_SetError("Window has no view");
		return -1;
	}
	else {
		[view showKeyboard];
		return 0;
	}
}

int SDL_iPhoneKeyboardHide(SDL_WindowID windowID) {
	
	SDL_Window *window = SDL_GetWindowFromID(windowID);
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (NULL == view) {
		SDL_SetError("Window has no view");
		return -1;
	}
	else {
		[view hideKeyboard];
		return 0;
	}
}

SDL_bool SDL_iPhoneKeyboardIsShown(SDL_WindowID windowID) {
	
	SDL_Window *window = SDL_GetWindowFromID(windowID);
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (NULL == view) {
		SDL_SetError("Window has no view");
		return 0;
	}
	else {
		return view.keyboardVisible;
	}
}

int SDL_iPhoneKeyboardToggle(SDL_WindowID windowID) {
	
	SDL_Window *window = SDL_GetWindowFromID(windowID);
	SDL_WindowData *data;
	SDL_uikitview *view;
	
	if (NULL == window) {
		SDL_SetError("Window does not exist");
		return -1;
	}
	
	data = (SDL_WindowData *)window->driverdata;
	view = data->view;
	
	if (NULL == view) {
		SDL_SetError("Window has no view");
		return -1;
	}
	else {
		if (SDL_iPhoneKeyboardIsShown(windowID)) {
			SDL_iPhoneKeyboardHide(windowID);
		}
		else {
			SDL_iPhoneKeyboardShow(windowID);
		}
		return 0;
	}
}

#else

/* stubs, used if compiled without keyboard support */

int SDL_iPhoneKeyboardShow(SDL_WindowID windowID) {
	SDL_SetError("Not compiled with keyboard support");
	return -1;
}

int SDL_iPhoneKeyboardHide(SDL_WindowID windowID) {
	SDL_SetError("Not compiled with keyboard support");
	return -1;
}

SDL_bool SDL_iPhoneKeyboardIsShown(SDL_WindowID windowID) {
	return 0;
}

int SDL_iPhoneKeyboardToggle(SDL_WindowID windowID) {
	SDL_SetError("Not compiled with keyboard support");
	return -1;
}


#endif /* SDL_IPHONE_KEYBOARD */
