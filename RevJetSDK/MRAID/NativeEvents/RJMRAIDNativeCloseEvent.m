//
//  RJMRAIDNativeCloseEvent.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDNativeCloseEvent.h"

#import "RJMRAIDView.h"
#import "RJMRAIDViewDelegate.h"

@implementation RJMRAIDNativeCloseEvent

- (void)executeEventWithParameters:(NSDictionary *)aParameters
{
	[super executeEventWithParameters:aParameters];
	
	RJMRAIDView *theMRAIDView = [self.delegate MRAIDView];
	if ([theMRAIDView isExpandedWebView])
	{
		if (kRJMRAIDPlacementTypeInline == theMRAIDView.placementType)
		{
			[theMRAIDView closeExpandedView];
		}
    
	}
	else
	{
		// Close interstitial ad
		if (kRJMRAIDPlacementTypeInterstitial == theMRAIDView.placementType)
		{
			[theMRAIDView.delegate didClose];
		}
		else
		{
			theMRAIDView.hidden = YES;
		}

		[theMRAIDView hiddenState];
	}
}

@end
