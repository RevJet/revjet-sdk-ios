//
//  RJSlot.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJSlot.h"

#import "RJGlobal.h"
#import "RJSlotView.h"
#import "RJNetwork.h"

NSString *const kRJSDKVersion = @"1.13.1";

NSString *const kRJMRAIDVersion = @"2";

@interface RJNetwork()

- (BOOL)autoRefresh;
- (void)setAutoRefresh:(BOOL)anAutoRefresh;
- (void)didShowAd:(UIView *)aView;
- (void)pauseAd;
- (void)resumeAd;

@end

@implementation RJSlot

- (id)init
{
	if ((self = [super init]))
	{
		self.network = [[RJNetwork alloc] initWithSlot:self];
	}
	
	return self;
}

- (id)initWithDelegate:(id<RJSlotDelegate>)aDelegate
                tagUrl:(NSString *)aTagUrl
                 frame:(CGRect)aFrame
{
	if ((self = [self init]))
	{
		_delegate = aDelegate;
		_tagUrl = [aTagUrl copy];
		_view = [[RJSlotView alloc] initWithDelegate:self frame:aFrame];
	}
	
	return self;
}

- (void)dealloc
{
	RJLog(@"dealloc");

	_delegate = nil;
	[self.network stopBeingDelegate];
	self.network.slot = nil;
	self.network = nil;
	_view.delegate = nil;
	[_view removeFromSuperview];
	_view = nil;
}

#pragma mark -

- (void)loadAd
{
	[self.network loadAd];
}

- (void)fetchAd
{
	[self.network fetchAd];
}

- (void)showAd
{
	[self.network showAd];
}

- (void)addToView:(UIView *)aView
{
	[aView addSubview:_view];
}

- (BOOL)autoRefresh
{
	return [self.network autoRefresh];
}

- (void)setAutoRefresh:(BOOL)anAutoRefresh
{
	[self.network setAutoRefresh:anAutoRefresh];
}

- (void)pauseAd
{
	[self.network pauseAd];
}

- (void)resumeAd
{
	[self.network resumeAd];
}

#pragma mark - RJSlotViewDelegate

- (void)slotView:(RJSlotView *)aSlotView didShowAd:(UIView *)aView
{
	[self.network didShowAd:aView];
}

@end
