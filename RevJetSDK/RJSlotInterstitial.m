//
//  RJSlotInterstitial.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJSlotInterstitial.h"

#import "RJNetworkInterstitial.h"

@interface RJNetwork()

- (BOOL)autoRefresh;
- (void)setAutoRefresh:(BOOL)anAutoRefresh;

@end

@implementation RJSlotInterstitial

- (id)initWithDelegate:(id<RJSlotDelegate>)aDelegate tagUrl:(NSString *)aTagUrl
{
	self = [super initWithDelegate:aDelegate tagUrl:aTagUrl frame:CGRectZero];
	if (nil != self)
	{
		self.network = [[RJNetworkInterstitial alloc] initWithSlot:self];
		[self.network setAutoRefresh:NO];
	}
	
	return self;
}

// Do not autorefresh interstitial ads.
- (BOOL)autoRefresh
{
	return NO;
}

- (void)setAutoRefresh:(BOOL)anAutoRefresh
{
}

@end
