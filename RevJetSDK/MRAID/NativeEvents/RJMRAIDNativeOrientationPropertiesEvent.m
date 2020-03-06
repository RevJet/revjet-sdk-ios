//
//  RJMRAIDNativeOrientationPropertiesEvent.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDNativeOrientationPropertiesEvent.h"

#import "RJMRAIDView.h"

@implementation RJMRAIDNativeOrientationPropertiesEvent

- (void)executeEventWithParameters:(NSDictionary *)aParameters
{
	[super executeEventWithParameters:aParameters];
	
	BOOL lockOrientation = NO;
	NSString *theAllowOrientationChangeParameter = [aParameters objectForKey:@"allowOrientationChange"];
	if (nil != theAllowOrientationChangeParameter)
	{
		lockOrientation = [theAllowOrientationChangeParameter isEqualToString:@"false"];
	}
	
	NSString *theForceOrientationParameter = [aParameters objectForKey:@"forceOrientation"];
	NSNumber *theForceOrientationMaskValue = nil;
	if ([theForceOrientationParameter isEqualToString:@"portrait"])
	{
		theForceOrientationMaskValue = @( UIInterfaceOrientationMaskPortrait );
	}
	else if ([theForceOrientationParameter isEqualToString:@"landscape"])
	{
		theForceOrientationMaskValue = @( UIInterfaceOrientationMaskLandscape );
	}
	
	[[self.delegate MRAIDView] lockOrientation:lockOrientation force:theForceOrientationMaskValue];
}


@end
