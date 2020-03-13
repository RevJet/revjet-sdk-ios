//
//  RJGlobal.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJGlobal.h"

NSString *const kRJErrorDomain = @"com.revjet";

@implementation RJGlobal

+ (void)disableScrollingAndDraggingForView:(UIView *)aView
{
	for (id theSubview in aView.subviews)
	{
		if ([[theSubview class] isSubclassOfClass:[UIScrollView class]])
		{
			UIScrollView *theView = theSubview;
			theView.scrollEnabled = NO;
			theView.bounces = NO;
		}
	}
}

+ (void)disableDraggingForView:(UIView *)aView
{
	for (id theSubview in aView.subviews)
	{
		if ([[theSubview class] isSubclassOfClass:[UIScrollView class]])
		{
			((UIScrollView *)theSubview).bounces = NO;
		}
	}
}

+ (CGRect)boundsOfMainScreen
{
	CGRect theResultBounds = [RJGlobal screenBoundsFixedToPortraitOrientation];
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
	{
		theResultBounds.size = CGSizeMake(theResultBounds.size.height, theResultBounds.size.width);
	}
	
	theResultBounds.size.height -= [RJGlobal statusBarHeight];

	return theResultBounds;
}

+ (CGSize)screenSize
{
	return [RJGlobal screenSizeFixedToPortraitOrientation:NO];
}

+ (CGSize)screenSizeFixedToPortraitOrientation
{
	return [RJGlobal screenSizeFixedToPortraitOrientation:YES];
}

+ (CGFloat)statusBarHeight
{
	CGFloat theResult = 0.0f;
	if (![UIApplication sharedApplication].statusBarHidden)
	{
		CGSize theStatusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
		theResult = MIN(theStatusBarSize.width, theStatusBarSize.height);
	}
	
	return theResult;
}

+ (CGRect)screenBoundsFixedToPortraitOrientation
{
	UIScreen *theScreen = [UIScreen mainScreen];
	if ([theScreen respondsToSelector:@selector(fixedCoordinateSpace)])
	{
		return [theScreen.coordinateSpace convertRect:theScreen.bounds
					toCoordinateSpace:theScreen.fixedCoordinateSpace];
	}
	return theScreen.bounds;
}

#pragma mark - Private

+ (CGSize)screenSizeFixedToPortraitOrientation:(BOOL)fixed
{
	CGRect theBounds = [UIScreen mainScreen].bounds;
	if (fixed)
	{
		theBounds = [RJGlobal screenBoundsFixedToPortraitOrientation];
	}
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
	{
		theBounds.size.width -= [RJGlobal statusBarHeight];
	}
	else
	{
		theBounds.size.height -= [RJGlobal statusBarHeight];
	}
	
	return theBounds.size;
}

@end
