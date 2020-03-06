//
//  RJMRAIDInterstitialAdapter.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDInterstitialAdapter.h"

#import "RJGlobal.h"
#import "RJAdapterDelegate.h"
#import "RJMRAIDInterstitialController.h"
#import "RJInterstitialControllerDelegate.h"

@interface RJMRAIDInterstitialAdapter () <RJInterstitialControllerDelegate>

@property (nonatomic, strong) RJMRAIDInterstitialController *interstitialController;

@end

@implementation RJMRAIDInterstitialAdapter

@synthesize interstitialController;

- (void)dealloc
{
	RJLog(@"dealloc");

	self.interstitialController.delegate = nil;
	self.interstitialController = nil;
}

- (void)getAd
{
	[super getAd];
	RJLog(@"getAd");
	
	CGSize theAdSize = CGSizeMake([[self.params objectForKey:@"WIDTH"] doubleValue],
				[[self.params objectForKey:@"HEIGHT"] doubleValue]);
	self.interstitialController = [[RJMRAIDInterstitialController alloc] initWithDelegate:self
                                                                                     html:[self.params objectForKey:@"HTML"] showCloseButton:YES adSize:theAdSize];
	[self.interstitialController loadAd];
	[self.delegate adapter:self didReceiveInterstitialAd:self.interstitialController];
}

- (void)showAd
{
	[self.delegate adapter:self willPresentInterstitialAd:self.interstitialController];
	UIViewController *theViewControllerForPresenting = [self.delegate viewControllerForPresentingModalView];
	
	BOOL isConrollerVisible = NO;
	if (nil != theViewControllerForPresenting)
	{
		if ([theViewControllerForPresenting isViewLoaded] && (nil != theViewControllerForPresenting.view.window))
		{
			isConrollerVisible = YES;
		}
	}
	
	if (isConrollerVisible)
	{
		[theViewControllerForPresenting presentViewController:self.interstitialController
					animated:YES completion:nil];
	}
}

#pragma mark - RJInterstitialControllerDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	return [self.delegate viewControllerForPresentingModalView];
}

- (BOOL)shouldOpenURL:(NSURL*)url
{
	return [self.delegate adapter:self shouldOpenURL:url];
}

- (void)didDismissInterstitialController:(RJMRAIDInterstitialController *)aController
{
	[self.delegate adapter:self didDismissInterstitialAd:self.interstitialController];
	self.interstitialController = nil;
}

- (void)applicationWillTerminateFromInterstitialController:(RJMRAIDInterstitialController *)aController
{
	[self.delegate adapter:self applicationWillTerminateFromInterstitialAd:self.interstitialController];
}

@end
