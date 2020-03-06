//
//  RJMRAIDNativeEvent.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDNativeEvent.h"

static NSString *const kRJErrorDomain = @"com.revjet";

@implementation RJMRAIDNativeEvent

- (id)initWithDelegate:(id<RJMRAIDNativeEventDelegate>)aDelegate
{
	self = [super init];
	if (nil != self)
	{
		self.delegate = aDelegate;
	}
	
	return self;
}

#pragma mark -

- (void)executeEventWithParameters:(NSDictionary *)aParameters
{
}

#pragma mark -

- (void)reportErrorWithMessage:(NSString *)aMessage
{
	NSDictionary *theDictionary = @{NSLocalizedDescriptionKey: NSLocalizedString(aMessage, @"")};
	[self.delegate nativeEvent:self didFailExecute:[NSError errorWithDomain:kRJErrorDomain
				code:500 userInfo:theDictionary]];
}

@end
