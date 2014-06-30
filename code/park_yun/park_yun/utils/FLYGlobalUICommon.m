//
//  CONST.h
//
//  Created by chen on 14-6-7.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//


#import "FLYGlobalUICommon.h"

const CGFloat FLYkDefaultRowHeight = 44;
              
const CGFloat FLYkDefaultPortraitToolbarHeight   = 44;
const CGFloat FLYkDefaultLandscapeToolbarHeight  = 33;

const CGFloat FLYkDefaultPortraitKeyboardHeight      = 216;
const CGFloat FLYkDefaultLandscapeKeyboardHeight     = 160;
const CGFloat FLYkDefaultPadPortraitKeyboardHeight   = 264;
const CGFloat FLYkDefaultPadLandscapeKeyboardHeight  = 352;

const CGFloat FLYkGroupedTableCellInset = 9;
const CGFloat FLYkGroupedPadTableCellInset = 42;

const CGFloat FLYkDefaulFLYransitionDuration      = 0.3;
const CGFloat FLYkDefaultFasFLYransitionDuration  = 0.2;
const CGFloat FLYkDefaultFlipTransitionDuration  = 0.7;



///////////////////////////////////////////////////////////////////////////////////////////////////
float FLYOSVersion()
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL FLYOSVersionIsAtLeast(float version)
{
    static const CGFloat kEpsilon = 0.0000001;
#ifdef __IPHONE_6_0
    return 6.0 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_5_1
    return 5.1 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_5_0
    return 5.0 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_4_2
    return 4.2 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_4_1
    return 4.1 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_4_0
    return 4.0 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_3_2
    return 3.2 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_3_1
    return 3.1 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_3_0
    return 3.0 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_2_2
    return 2.2 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_2_1
    return 2.1 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_2_0
    return 2.0 - version >= -kEpsilon;
#endif
    return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL FLYIsKeyboardVisible() {
    // Operates on the assumption that the keyboard is visible if and only if there is a first
    // responder; i.e. a control responding to key events
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    return ![window isFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL FLYIsPhoneSupported() {
    NSString* deviceType = [UIDevice currentDevice].model;
    return [deviceType isEqualToString:@"iPhone"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL FLYIsPad() {
#ifdef __IPHONE_3_2
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#else
    return NO;
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
UIDeviceOrientation FLYDeviceOrientation() {
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationUnknown == orient) {
        return UIDeviceOrientationPortrait;
        
    } else {
        return orient;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL FLYIsSupportedOrientation(UIInterfaceOrientation orientation) {
    if (FLYIsPad()) {
        return YES;
        
    } else {
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                return YES;
            default:
                return NO;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGAffineTransform FLYRotateTransformForOrientation(UIInterfaceOrientation orientation) {
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
        
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
        
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
        
    } else {
        return CGAffineTransformIdentity;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

CGRect FLYApplicationBounds()
{
    return [UIScreen mainScreen].bounds;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect FLYApplicationFrame() {
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    return CGRectMake(0, 0, frame.size.width, frame.size.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat FLYToolbarHeightForOrientation(UIInterfaceOrientation orientation) {
    if (UIInterfaceOrientationIsPortrait(orientation) || FLYIsPad()) {
        return FLY_ROW_HEIGHT;
        
    } else {
        return FLY_LANDSCAPE_TOOLBAR_HEIGHT;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat FLYKeyboardHeightForOrientation(UIInterfaceOrientation orientation) {
    if (FLYIsPad()) {
        return UIInterfaceOrientationIsPortrait(orientation) ? FLY_IPAD_KEYBOARD_HEIGHT
        : FLY_IPAD_LANDSCAPE_KEYBOARD_HEIGHT;
        
    } else {
        return UIInterfaceOrientationIsPortrait(orientation) ? FLY_KEYBOARD_HEIGHT
        : FLY_LANDSCAPE_KEYBOARD_HEIGHT;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat FLYGroupedTableCellInset() {
    return FLYIsPad() ? FLYkGroupedPadTableCellInset : FLYkGroupedTableCellInset;
}


