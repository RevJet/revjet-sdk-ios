//
//  RJGlobal.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kRJErrorDomain;

#ifdef DEBUG

#define RJLog(format, ...) NSLog(@"%@(%d): %@", [NSString stringWithUTF8String:__FILE__], __LINE__, [NSString stringWithFormat:format,##__VA_ARGS__])

#else

#define RJLog(...) {}

#endif

//! Utility class.
@interface RJGlobal : NSObject

+ (void)disableScrollingAndDraggingForView:(UIView *)aView;
+ (void)disableDraggingForView:(UIView *)aView;

//! Returns the bounds of main screen. The result depends on if status bar is hidded or not.
+ (CGRect)boundsOfMainScreen;
+ (CGSize)screenSize;
+ (CGSize)screenSizeFixedToPortraitOrientation;

//! Returns zero if status bar is hidden.
+ (CGFloat)statusBarHeight;

+ (CGRect)screenBoundsFixedToPortraitOrientation;

@end
