//
//  RJMRAIDNativeEventFactory.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDNativeEventFactory.h"

#import "RJMRAIDNativeEvent.h"

@interface RJMRAIDNativeEventFactory ()

+ (NSString *)classNameFromEventName:(NSString *)anEventName;

@end

@implementation RJMRAIDNativeEventFactory

+ (RJMRAIDNativeEvent *)eventWithName:(NSString *)anEventName delegate:(id<RJMRAIDNativeEventDelegate>)aDelegate
{
	RJMRAIDNativeEvent *theEvent = nil;
	NSString *theClassName = [RJMRAIDNativeEventFactory classNameFromEventName:anEventName];
	if (nil != theClassName)
	{
		Class theClass = NSClassFromString(theClassName);
		if (Nil != theClass)
		{
			theEvent = [[theClass alloc] initWithDelegate:aDelegate];
			theEvent.eventName = anEventName;
		}
	}
	
	return theEvent;
}

#pragma mark - Private

+ (NSString *)classNameFromEventName:(NSString *)anEventName
{
	static NSDictionary *sClassNamesMap = nil;
	static dispatch_once_t sClassNamesMapispatch = 0;
	dispatch_once(&sClassNamesMapispatch, ^
	{
		sClassNamesMap = [NSDictionary dictionaryWithObjectsAndKeys:
					@"Expand", @"expand",
					@"UseCustomClose", @"usecustomclose",
					@"Close", @"close",
					@"Open", @"open",
					@"Calendar", @"createCalendarEvent",
					@"PlayVideo", @"playVideo",
					@"StorePicture", @"storePicture",
					@"OrientationProperties", @"setOrientationProperties",
					nil];
	});
	
	NSString *theClassName = [sClassNamesMap objectForKey:anEventName];
	if (nil != theClassName)
	{
		theClassName = [NSString stringWithFormat:@"RJMRAIDNative%@Event", theClassName];
	}
	
	return theClassName;
}

@end
