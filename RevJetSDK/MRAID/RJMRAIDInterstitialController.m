//
//  RJMRAIDInterstitialController.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDInterstitialController.h"

#import "RJGlobal.h"
#import "RJInterstitialControllerDelegate.h"
#import "RJMRAIDView.h"
#import "RJWebBrowser.h"
#import "RJMRAID.h"
#import "RJMRAIDViewDelegate.h"

@interface RJMRAIDInterstitialController () <RJMRAIDViewDelegate>

@property (nonatomic, strong) RJMRAIDView *MRAIDView;
@property (nonatomic, strong) NSString *internalBrowserURL;
@property (nonatomic, strong) RJWebBrowser *webBrowser;

@end

@implementation RJMRAIDInterstitialController

@synthesize MRAIDView, internalBrowserURL;

- (void)dealloc
{
	RJLog(@"dealloc");

	self.delegate = nil;
	self.MRAIDView.delegate = nil;
	self.MRAIDView = nil;
	self.internalBrowserURL = nil;
	self.webBrowser.delegate = nil;
}

- (void)loadView
{
	RJLog(@"loadView");

	// Root view
	CGRect theAppFrame = [RJGlobal boundsOfMainScreen];
	UIView *theContentView = [[UIView alloc] initWithFrame:theAppFrame];
	theContentView.backgroundColor = [UIColor blackColor];
	theContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view = theContentView;
}

- (void)loadAd
{
	// Root view
	CGRect theAppFrame = [RJGlobal boundsOfMainScreen];
	UIView *theContentView = [[UIView alloc] initWithFrame:theAppFrame];
	theContentView.backgroundColor = [UIColor blackColor];
	theContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view = theContentView;
	
	self.MRAIDView = [[RJMRAIDView alloc] initWithFrame:[self preferredwebViewFrame] delegate:self];
	self.MRAIDView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.MRAIDView.placementType = kRJMRAIDPlacementTypeInterstitial;
	[self.view addSubview:self.MRAIDView];
	[self.MRAIDView loadHTML:self.HTML];
}

- (void)didPresentInterstitial
{
	[super didPresentInterstitial];
	[self.MRAIDView stringByEvaluatingJavaScriptFromString:@"webviewDidAppear();"];
	[self.MRAIDView.mraid setViewable:YES];
}

- (void)didDismissInterstitial
{
	[super didDismissInterstitial];
	[self.MRAIDView.mraid setViewable:NO];
}

- (void)viewDidDisappear:(BOOL)anAnimated
{
	[super viewDidDisappear:anAnimated];
	
	// Open internal browser
	if (nil != self.internalBrowserURL)
	{
		self.webBrowser= [RJWebBrowser RJWebBrowserWithDelegate:self.MRAIDView.mraid
															URL:[NSURL URLWithString:self.internalBrowserURL]];

		[[self viewControllerForPresentingModalView] presentViewController:self.webBrowser
					animated:YES completion:nil];
	}
	else
	{
		if ([self.delegate respondsToSelector:@selector(didDismissInterstitialController:)])
		{
			[self.delegate didDismissInterstitialController:self];
		}
	}
}

#pragma mark - RJMRAIDViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	if (nil != self.internalBrowserURL)
	{
		if ([self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)])
		{
			return [self.delegate viewControllerForPresentingModalView];
		}
	}
	return self;
}

- (void)applicationWillTerminateFromAd:(RJMRAIDView *)aView
{
	RJLog(@"applicationWillTerminateFromAd:");

	if ([self.delegate respondsToSelector:@selector(applicationWillTerminateFromInterstitialController:)])
	{
		[self.delegate applicationWillTerminateFromInterstitialController:self];
	}
}

- (void)didClose
{
	RJLog(@"didClose");

	[[self.delegate viewControllerForPresentingModalView] dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCloseInternalBrowser
{
	RJLog(@"didCloseInternalBrowser");

	if ([self.delegate respondsToSelector:@selector(didDismissInterstitialController:)])
	{
		[self.delegate didDismissInterstitialController:self];
	}
}

- (void)openInternalBrowser:(NSString *)aURL
{
	self.internalBrowserURL = aURL;

	// First, we need to close interstitial modal controller
	// and only than we can display web browser modal controller
	[[self.delegate viewControllerForPresentingModalView] dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldOpenURL:(NSURL*)url
{
	return [self.delegate shouldOpenURL:url];
}

@end
