//
//  RJMRAIDNativeUseCustomCloseEvent.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDNativeUseCustomCloseEvent.h"

#import "RJMRAIDView.h"

@implementation RJMRAIDNativeUseCustomCloseEvent

- (void)executeEventWithParameters:(NSDictionary *)aParameters
{
	[super executeEventWithParameters:aParameters];
	
	NSString *theCustomCloseString = [aParameters objectForKey:@"shouldUseCustomClose"];
	if (nil == theCustomCloseString)
	{
		return;
	}

	BOOL theUseCustomClose = NO;
	if ([theCustomCloseString isEqualToString:@"true"])
	{
		theUseCustomClose = YES;
	}

	if (theUseCustomClose == [self.delegate useCustomCloseButton])
	{
		return;
	}

	[self.delegate nativeEvent:self willUseCutomCloseButton:theUseCustomClose];

	RJMRAIDView *theMRAIDView = [self.delegate MRAIDView];
	if (![theMRAIDView isExpandedWebView] && kRJMRAIDPlacementTypeInline == theMRAIDView.placementType)
	{
		return;
	}

	if (theUseCustomClose)
	{
		[theMRAIDView hideCloseButton];
	}
	else
	{
		[theMRAIDView showCloseButton];
	}
}

@end
