//
//  RJBaseInterstitialController.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJBaseInterstitialController.h"

#import "RJStatusBarVisibility.h"
#import "RJGlobal.h"

typedef enum
{
	kRJInterstitialOrientationPortrait,
	kRJInterstitialOrientationLandscape,
	kRJInterstitialOrientationCurrentOnly
} RJInterstitialOrientationType;

static const CGSize kRJAdSize320x480 = {320.0f, 480.0f};
static const CGSize kRJAdSize320x568 = {320.0f, 568.0f};
static const CGSize kRJAdSize768x1024 = {768.0f, 1024.0f};

static const CGSize kRJAdSize480x320 = {480.0f, 320.0f};
static const CGSize kRJAdSize568x320 = {568.0f, 320.0f};
static const CGSize kRJAdSize1024x768 = {1024.0f, 768.0f};

@interface RJBaseInterstitialController ()

@property (nonatomic, assign) RJInterstitialOrientationType orientationType;
@property (nonatomic, strong) RJStatusBarVisibility *statusBarVisibility;

@end

@implementation RJBaseInterstitialController

- (id)initWithDelegate:(id<RJInterstitialControllerDelegate>)aDelegate html:(NSString *)aHTML
			showCloseButton:(BOOL)aFlag adSize:(CGSize)aSize
{
	self = [super initWithNibName:nil bundle:nil];
	if (nil != self)
	{
		self.delegate = aDelegate;
		self.HTML = aHTML;
		self.showCloseButton = aFlag;
		self.adSize = [RJGlobal screenBoundsFixedToPortraitOrientation].size;
		self.statusBarVisibility = [[RJStatusBarVisibility alloc] init];
		
		RJInterstitialOrientationType theOrientationType = kRJInterstitialOrientationCurrentOnly;
		if (CGSizeEqualToSize(kRJAdSize320x480, aSize) || CGSizeEqualToSize(kRJAdSize768x1024, aSize) ||
					CGSizeEqualToSize(kRJAdSize320x568, aSize))
		{
			theOrientationType = kRJInterstitialOrientationPortrait;
		}
		else if (CGSizeEqualToSize(kRJAdSize480x320, aSize) || CGSizeEqualToSize(kRJAdSize1024x768, aSize) ||
					CGSizeEqualToSize(kRJAdSize568x320, aSize))
		{
			theOrientationType = kRJInterstitialOrientationLandscape;
			self.adSize = CGSizeMake(self.adSize.height, self.adSize.width);
		}
		self.orientationType = theOrientationType;
	}
	return self;
}

- (void)loadAd
{
	// base interstitial controller does nothing for this method
}

- (CGRect)preferredwebViewFrame
{
	CGRect theWebViewFrame = [RJGlobal boundsOfMainScreen];
	theWebViewFrame.size.height = theWebViewFrame.size.height + [RJGlobal statusBarHeight];
	CGSize theAdSize = self.adSize;
	if (!CGSizeEqualToSize(CGSizeZero, theAdSize))
	{
		if (CGSizeEqualToSize(kRJAdSize320x480, theAdSize) || CGSizeEqualToSize(kRJAdSize480x320, theAdSize) ||
					CGSizeEqualToSize(kRJAdSize768x1024, theAdSize) || CGSizeEqualToSize(kRJAdSize1024x768, theAdSize) ||
					CGSizeEqualToSize(kRJAdSize320x568, theAdSize) || CGSizeEqualToSize(kRJAdSize568x320, theAdSize))
		{
			CGFloat theWebViewHeight = theWebViewFrame.size.height;
			CGFloat theWebViewWidth = theWebViewFrame.size.width;
			CGFloat theAdSizeHeight = theAdSize.height;
			CGFloat theAdSizeWidth = theAdSize.width;
			if ((theWebViewWidth > theWebViewHeight && theAdSizeWidth < theAdSizeHeight) ||
						(theWebViewHeight > theWebViewWidth && theAdSizeHeight < theAdSizeWidth))
			{
				theWebViewHeight = theWebViewFrame.size.width;
				theWebViewWidth = theWebViewFrame.size.height;
			}
			theWebViewFrame.origin = CGPointMake((theWebViewWidth - theAdSizeWidth) / 2,
						(theWebViewHeight - theAdSizeHeight) / 2);
			theWebViewFrame.size = CGSizeMake(theAdSize.width, theAdSize.height);
		}
	}
	
	return theWebViewFrame;
}

#pragma mark -

- (void)didPresentInterstitial
{
}

- (void)didDismissInterstitial
{
}

- (UIWebView *)webView
{
	return nil;
}

#pragma mark -

- (void)viewDidAppear:(BOOL)anAnimated
{
	[super viewDidAppear:anAnimated];
	[self didPresentInterstitial];
}

- (void)viewDidDisappear:(BOOL)anAnimated
{
	[super viewDidDisappear:anAnimated];
	[self didDismissInterstitial];
}

#pragma mark - Status Bar

- (void)viewWillAppear:(BOOL)anAnimated
{
	[super viewWillAppear:anAnimated];
	[self.statusBarVisibility hideStatusBar];
}

- (void)viewWillDisappear:(BOOL)anAnimated
{
	[super viewWillDisappear:anAnimated];
	[self.statusBarVisibility showStatusBar];
}

// iOS 7
- (BOOL)prefersStatusBarHidden
{
	return [self.statusBarVisibility shouldHideStatusBar];
}

#pragma mark - Orientation

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0

// iOS 6 and higher
- (BOOL)shouldAutorotate
{
    return (self.orientationType != kRJInterstitialOrientationCurrentOnly);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	UIInterfaceOrientationMask theSupportedOrientations = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:
				[UIApplication sharedApplication].keyWindow];
	if (kRJInterstitialOrientationPortrait == self.orientationType)
	{
		theSupportedOrientations &= (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	}
	else if (kRJInterstitialOrientationLandscape == self.orientationType)
	{
		theSupportedOrientations &= UIInterfaceOrientationMaskLandscape;
	}

	return theSupportedOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	UIInterfaceOrientationMask theSupportedOrientations = [self supportedInterfaceOrientations];
	UIInterfaceOrientation theCurrentOrientation = [UIApplication sharedApplication].statusBarOrientation;
	UIInterfaceOrientationMask theCurrentOrientationMask = (1 << theCurrentOrientation);
	
	UIInterfaceOrientation theResultOrientation = UIInterfaceOrientationLandscapeRight;
	if (theSupportedOrientations & theCurrentOrientationMask)
	{
		theResultOrientation = theCurrentOrientation;
	}
	else if (theSupportedOrientations & UIInterfaceOrientationMaskPortrait)
	{
		theResultOrientation = UIInterfaceOrientationPortrait;
	}
	else if (theSupportedOrientations & UIInterfaceOrientationMaskPortraitUpsideDown)
	{
		theResultOrientation = UIInterfaceOrientationPortraitUpsideDown;
	}
	else if (theSupportedOrientations & UIInterfaceOrientationMaskLandscapeLeft)
	{
		theResultOrientation = UIInterfaceOrientationLandscapeLeft;
	}

	return theResultOrientation;
}
#endif


// Prior iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)anInterfaceOrientation
{
	BOOL theResult = (anInterfaceOrientation == [UIApplication sharedApplication].statusBarOrientation);
	if (self.orientationType == kRJInterstitialOrientationPortrait)
	{
		theResult = ((UIInterfaceOrientationPortrait == anInterfaceOrientation) ||
					(UIInterfaceOrientationPortraitUpsideDown == anInterfaceOrientation));
	}
	else if (self.orientationType == kRJInterstitialOrientationLandscape)
	{
		theResult = ((UIInterfaceOrientationLandscapeLeft == anInterfaceOrientation) ||
					(UIInterfaceOrientationLandscapeRight == anInterfaceOrientation));
	}
	
	return theResult;
}

@end
