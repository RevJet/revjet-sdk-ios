//
//  RJAdapterInterstitial.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJAdapterInterstitial.h"

#import "RJGlobal.h"
#import "RJAdapterDelegate.h"
#import "RJInterstitialController.h"
#import "RJInterstitialControllerDelegate.h"

@interface RJAdapterInterstitial () <RJInterstitialControllerDelegate>

@property (nonatomic, strong) RJInterstitialController *loadingAd;

@end

@implementation RJAdapterInterstitial

@synthesize loadingAd;

- (id)initWithDelegate:(id<RJAdapterDelegate>)aDelegate
{
	self = [super initWithDelegate:aDelegate];
	if (nil != self)
	{
		self.showCloseButton = YES;
	}
	
	return self;
}

- (void)dealloc
{
	RJLog(@"dealloc");
	self.loadingAd.delegate = nil;
	self.delegate = nil;
	self.loadingAd = nil;
}

- (void)getAd
{
	[super getAd];
	CGSize theAdSize = CGSizeMake([self.params[@"WIDTH"] doubleValue],
				[self.params[@"HEIGHT"] doubleValue]);
	self.loadingAd = [[RJInterstitialController alloc] initWithDelegate:self
			html:self.params[@"HTML"] showCloseButton:self.showCloseButton adSize:theAdSize];
	[self.loadingAd loadAd];
	[self.delegate adapter:self didReceiveInterstitialAd:self.loadingAd];
}

- (void)showAd
{
	[self.delegate adapter:self willPresentInterstitialAd:self.loadingAd];
	UIViewController *theController = [self.delegate viewControllerForPresentingModalView];
	
	BOOL isControllerVisible = NO;
	if (nil != theController)
	{
		if ([theController isViewLoaded] && (nil != theController.view.window))
		{
			isControllerVisible = YES;
		}
	}
	
	if (isControllerVisible)
	{
		[theController presentViewController:self.loadingAd animated:YES completion:nil];
	}
}

#pragma mark - RJInterstitialControllerDelegate

- (UIViewController *)viewControllerForPresentingModalView {
  return [self.delegate viewControllerForPresentingModalView];
}

- (BOOL)shouldOpenURL:(NSURL*)url {
	return [self.delegate adapter:self shouldOpenURL:url];
}

- (void)didShowInterstitialAd:(RJInterstitialController *)aController {
	[self.delegate adapter:self didShowInterstitialAd:self.loadingAd];
}

- (void)didDismissInterstitialController:(RJInterstitialController *)controller {
  [self.delegate adapter:self didDismissInterstitialAd:self.loadingAd];
}

- (void)applicationWillTerminateFromInterstitialController:(RJInterstitialController *)controller
{
	[self.delegate trackClickForAdapter:self];
	[self.delegate adapter:self applicationWillTerminateFromInterstitialAd:self.loadingAd];
}

@end
