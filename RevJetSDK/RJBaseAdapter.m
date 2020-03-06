//
//  RJBaseAdapter.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJBaseAdapter.h"
#import "RJAdapterDelegate.h"

static NSString *const kRJGetAdMoreThanOnceExceptionName = @"MethodHasAlreadyBeenCalledException";
static NSString *const kRJGetAdMoreThanOnceExceptionReason = @"Method can be called only once";

NSString *const kRJDataParameterKey = @"DATA";

static NSString *const kRJShowCloseButtonParameterKey = @"SHOWCLOSEBUTTON";

@interface RJBaseAdapter ()

@property (nonatomic, assign) NSInteger adCounter;

@end

@implementation RJBaseAdapter

@synthesize delegate;

@synthesize transitionAnimation, params, adCounter, showCloseButton, pixelsTracker;

- (id)initWithDelegate:(id<RJAdapterDelegate>)aDelegate
{
	self = [super init];
	if (nil != self)
	{
		self.delegate = aDelegate;
	}
	
	return self;
}

- (void)dealloc
{
	self.delegate = nil;
}

- (void)getAd
{
	if (self.adCounter > 0)
	{
		@throw [NSException exceptionWithName:kRJGetAdMoreThanOnceExceptionName
									   reason:kRJGetAdMoreThanOnceExceptionReason userInfo:nil];
	}
	else
	{
		adCounter++;
	}
	
	if (nil != [self.delegate showCloseButton])
	{
		self.showCloseButton = [[self.delegate showCloseButton] boolValue];
	}

	id theShowCloseParameter = self.params[kRJShowCloseButtonParameterKey];
	if (nil != theShowCloseParameter)
	{
		if ([theShowCloseParameter isKindOfClass:[NSNumber class]] ||
					[theShowCloseParameter isKindOfClass:[NSString class]])
		{
			self.showCloseButton = [theShowCloseParameter boolValue];
		}
	}
}

- (void)didShowAd
{

}

@end
