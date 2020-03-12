//
//  RJMRAIDAdapter.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJGlobal.h"
#import "RJAdapterDelegate.h"
#import "RJMRAIDAdapter.h"
#import "RJMRAIDView.h"
#import "RJMRAID.h"

#import "RJUtilities.h"

#import "RJNetwork.h"

@interface RJNetwork (PrivateMethodsForMillennialMedia)

@property (nonatomic, assign) BOOL isAdapterBusy;

@end

@interface RJMRAIDAdapter()

@property (nonatomic, strong) RJMRAIDView *adView;

@end

@implementation RJMRAIDAdapter

@synthesize adView;

- (id)initWithDelegate:(id<RJAdapterDelegate>)aDelegate
{
	RJLog(@"initWithDelegate:");
	
	self = [super initWithDelegate:aDelegate];
	if (nil != self)
	{
		CGRect theFrame = CGRectZero;
		theFrame.size = [RJUtilities supportedSizeForSize:[self.delegate slotViewFrame].size];
		self.adView = [[RJMRAIDView alloc] initWithFrame:theFrame delegate:self];
	}

	return self;
}

- (void)dealloc
{
	RJLog(@"dealloc");
	adView.delegate = nil;
	adView = nil;
}

- (void)getAd
{
	[super getAd];
	RJLog(@"getAd");
	
	if (self.showCloseButton)
	{
		UIButton *theCloseButton = [RJUtilities closeButton];
		[self.adView addSubview:theCloseButton];
		theCloseButton.center = CGPointMake(self.adView .frame.size.width - theCloseButton.frame.size.width / 2,
					theCloseButton.frame.size.height / 2);
		[theCloseButton addTarget:self action:@selector(closeBanner:) forControlEvents:UIControlEventTouchUpInside];
	}

	[self.adView loadHTML:self.params[@"HTML"]];
}

- (void)didShowAd
{
	[self.adView stringByEvaluatingJavaScriptFromString:@"webviewDidAppear();"];
	[self.adView.mraid setViewable:YES];
	[self.delegate adapter:self didShowAd:self.adView];
}

#pragma makr - Actions

- (void)closeBanner:(UIButton *)aButton
{
	[self.delegate adapter:self didCloseAd:self.adView ];
}

#pragma mark - RJMRAIDViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	return [self.delegate viewControllerForPresentingModalView];
}

- (void)didReceiveAd:(RJMRAIDView *)aView
{
	RJLog(@"didReceiveAd:");

	[self.delegate adapter:self didReceiveAd:aView];
}

- (void)didFailToReceiveAd:(RJMRAIDView *)aView withError:(NSError *)anError
{
	RJLog(@"didFailToReceiveAd:withError");

	[self.delegate adapter:self didFailToReceiveAd:aView error:anError];
}

- (void)applicationWillTerminateFromAd:(RJMRAIDView *)aView
{
	RJLog(@"applicationWillTerminateFromAd:");
	[self.delegate trackClickForAdapter:self];
	[self.delegate adapter:self applicationWillTerminateFromAd:aView];
}

- (void)willExpand
{
	RJLog(@"willExpand");
	[self.delegate trackClickForAdapter:self];
	[self.delegate adapter:self willPresentModalViewFromAd:self.adView ];
}

- (void)didClose
{
	RJLog(@"didClose");

	[self.delegate adapter:self didDismissModalViewFromAd:self.adView ];
}

- (void)willOpenInternalBrowser
{
	RJLog(@"willOpenInternalBrowser");
	[self.delegate trackClickForAdapter:self];
	[self.delegate adapter:self willPresentModalViewFromAd:self.adView ];
}

- (void)didCloseInternalBrowser
{
	RJLog(@"didCloseInternalBrowser");

	[self.delegate adapter:self didDismissModalViewFromAd:self.adView ];
}

- (void)willRequestAccess
{
	RJLog(@"willRequestAccess");
	
	[(RJNetwork *)self.delegate setIsAdapterBusy:YES];
}

- (void)didRequestAccess
{
	RJLog(@"didRequestAccess");
	
	[(RJNetwork *)self.delegate setIsAdapterBusy:NO];
}

- (BOOL)shouldOpenURL:(NSURL*)url
{
	return [self.delegate adapter:self shouldOpenURL:url];
}

@end
