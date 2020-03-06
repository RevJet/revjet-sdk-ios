//
//  RJMRAIDNativeOpenEvent.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDNativeOpenEvent.h"

#import "RJMRAIDView.h"
#import "RJMRAIDViewDelegate.h"

#import "RJWebBrowser.h"
#import "RJWebBrowserDelegate.h"

@interface RJMRAIDNativeOpenEvent () <RJWebBrowserDelegate>

@property (nonatomic, strong) RJWebBrowser *webBrowser;

@end

@implementation RJMRAIDNativeOpenEvent

@synthesize webBrowser;

- (void)dealloc
{
	self.webBrowser.delegate = nil;
}

#pragma mark -

- (void)executeEventWithParameters:(NSDictionary *)aParameters
{
	[super executeEventWithParameters:aParameters];
	
	RJMRAIDView *theMRAIDView = [self.delegate MRAIDView];
	NSString *theURL = [aParameters objectForKey:@"url"];
	if (nil != theURL)
	{
		if (kRJMRAIDPlacementTypeInterstitial == theMRAIDView.placementType)
		{
			[theMRAIDView.delegate openInternalBrowser:theURL];
		}
		else
		{
			if ([theMRAIDView isExpandedWebView])
			{
				[theMRAIDView closeExpandedView];
			}
		
			if (![theMRAIDView isExpandedWebView] &&
						[theMRAIDView.delegate respondsToSelector:@selector(willOpenInternalBrowser)])
			{
				[theMRAIDView.delegate willOpenInternalBrowser];
			}
			
			self.webBrowser.delegate = nil;
			self.webBrowser = [RJWebBrowser RJWebBrowserWithDelegate:self URL:[NSURL URLWithString:theURL]];

			[[self.delegate viewControllerForPresentingModalView]
						presentViewController:self.webBrowser animated:YES completion:nil];
		}
	}
}

#pragma mark - RJWebBrowserDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	return [self.delegate viewControllerForPresentingModalView];
}

- (void)didDismissWebBrowser:(RJWebBrowser *)aWebBrowser
{
	RJMRAIDView *theMRAIDView = [self.delegate MRAIDView];
	if (![theMRAIDView isExpandedWebView] && [theMRAIDView.delegate respondsToSelector:
				@selector(didCloseInternalBrowser)])
	{
		[theMRAIDView.delegate didCloseInternalBrowser];
	}
}

- (void)applicationWillTerminateFromWebBrowser:(RJWebBrowser *)aWebBrowser
{
	RJMRAIDView *theMRAIDView = [self.delegate MRAIDView];
	if ([theMRAIDView.delegate respondsToSelector:@selector(applicationWillTerminateFromAd:)])
	{
		[theMRAIDView.delegate applicationWillTerminateFromAd:theMRAIDView];
	}
}

- (BOOL)shouldOpenURL:(NSURL*)url
{
	RJMRAIDView *theMRAIDView = [self.delegate MRAIDView];
	return [theMRAIDView.delegate shouldOpenURL:url];
}

@end
