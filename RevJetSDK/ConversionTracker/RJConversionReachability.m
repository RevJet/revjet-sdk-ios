//  RJConversionReachability.m
//  RevJetSDK

//  Copyright (c) RevJet. All rights reserved.

#import "RJConversionReachability.h"

NSString *const kRJReachabilityStatusChanged = @"RJReachabilityStatusChanged";

// Private function.
static void RJReachabilityCallback(SCNetworkReachabilityRef aTarget, SCNetworkReachabilityFlags aFlags, void *anInfo);

@interface RJConversionReachability ()

@property (nonatomic, assign) BOOL localWiFiRef;
@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;

@end

@implementation RJConversionReachability

@synthesize localWiFiRef, reachabilityRef;

- (void)dealloc
{
	[self stopNotifier];
	if(reachabilityRef != NULL)
	{
		CFRelease(reachabilityRef);
	}
	
}

#pragma mark -

+ (RJConversionReachability *)reachabilityWithHostName:(NSString *)aHostName;
{
	RJConversionReachability *theReachability = nil;
	SCNetworkReachabilityRef theReachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [aHostName UTF8String]);
	if(theReachabilityRef != NULL)
	{
		theReachability= [[self alloc] init];
		if (nil != theReachability)
		{
			theReachability.reachabilityRef = theReachabilityRef;
			theReachability.localWiFiRef = NO;
		}
	}
	return theReachability;
}

+ (RJConversionReachability *)reachabilityWithAddress:(const struct sockaddr_in *)aHostAddress;
{
	RJConversionReachability *theReachability = nil;
	SCNetworkReachabilityRef theReachabilityRef = SCNetworkReachabilityCreateWithAddress(
				kCFAllocatorDefault, (const struct sockaddr *)aHostAddress);
	if(theReachabilityRef != NULL)
	{
		theReachability = [[self alloc] init];
		if (nil != theReachability)
		{
			theReachability.reachabilityRef = theReachabilityRef;
			theReachability.localWiFiRef = NO;
		}
	}
	return theReachability;
}

+ (RJConversionReachability *)reachabilityForInternetConnection;
{
	struct sockaddr_in theZeroAddress;
	bzero(&theZeroAddress, sizeof(theZeroAddress));
	theZeroAddress.sin_len = sizeof(theZeroAddress);
	theZeroAddress.sin_family = AF_INET;
	return [self reachabilityWithAddress: &theZeroAddress];
}

+ (RJConversionReachability *)reachabilityForLocalWiFi;
{
	struct sockaddr_in theLocalWifiAddress;
	bzero(&theLocalWifiAddress, sizeof(theLocalWifiAddress));
	theLocalWifiAddress.sin_len = sizeof(theLocalWifiAddress);
	theLocalWifiAddress.sin_family = AF_INET;
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	theLocalWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	RJConversionReachability *theReachability = [self reachabilityWithAddress:&theLocalWifiAddress];
	theReachability.localWiFiRef = YES;
	
	return theReachability;
}

- (BOOL)startNotifier
{
	BOOL theReturnValue = NO;
	SCNetworkReachabilityContext theContext = { 0, (__bridge void *)(self), NULL, NULL, NULL };
	if(SCNetworkReachabilitySetCallback(self.reachabilityRef, RJReachabilityCallback, &theContext))
	{
		if(SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
		{
			theReturnValue = YES;
		}
	}
	return theReturnValue;
}

- (void)stopNotifier
{
	if(reachabilityRef != NULL)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}

- (RJConversionReachabilityStatusType)currentReachabilityStatus
{
	NSAssert(self.reachabilityRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
	RJConversionReachabilityStatusType theResultStatus = kRJConversionReachabilityStatusNotReachable;
	SCNetworkReachabilityFlags theReachabilityFlags;
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &theReachabilityFlags))
	{
		if(localWiFiRef)
		{
			theResultStatus = [self localWiFiStatusForFlags:theReachabilityFlags];
		}
		else
		{
			theResultStatus = [self networkStatusForFlags:theReachabilityFlags];
		}
	}
	return theResultStatus;
}

#pragma mark Network Flag Handling

- (RJConversionReachabilityStatusType)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)aFlags
{
	RJPrintReachabilityFlags(aFlags, "localWiFiStatusForFlags");
    
	RJConversionReachabilityStatusType theResultStatus = kRJConversionReachabilityStatusNotReachable;
	if ((aFlags & kSCNetworkReachabilityFlagsReachable) && (aFlags & kSCNetworkReachabilityFlagsIsDirect))
	{
		theResultStatus = kRJConversionReachabilityStatusWiFi;
	}
	return theResultStatus;
}

- (RJConversionReachabilityStatusType)networkStatusForFlags:(SCNetworkReachabilityFlags)aFlags
{
	RJPrintReachabilityFlags(aFlags, "networkStatusForFlags");
	if ((aFlags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// if target host is not reachable
		return kRJConversionReachabilityStatusNotReachable;
	}
    
	RJConversionReachabilityStatusType theResultStatus = kRJConversionReachabilityStatusNotReachable;
	
	if ((aFlags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		// if target host is reachable and no connection is required
		//  then we'll assume (for now) that your on Wi-Fi
		theResultStatus = kRJConversionReachabilityStatusWiFi;
	}
	
	
	if ((((aFlags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
				(aFlags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((aFlags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            theResultStatus = kRJConversionReachabilityStatusWiFi;
        }
    }
	
	if ((aFlags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		// ... but WWAN connections are OK if the calling application
		//     is using the CFNetwork (CFSocketStream?) APIs.
		theResultStatus = kRJConversionReachabilityStatusWWAN;
	}
	return theResultStatus;
}

- (BOOL)connectionRequired;
{
	NSAssert(self.reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags theReachabilityFlags;
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &theReachabilityFlags))
	{
		return (theReachabilityFlags & kSCNetworkReachabilityFlagsConnectionRequired);
	}
	
	return NO;
}

#define kShouldPrintReachabilityFlags 0

static void RJPrintReachabilityFlags(SCNetworkReachabilityFlags aFlags, const char* aComment)
{
#if kShouldPrintReachabilityFlags
	
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)				  ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}

static void RJReachabilityCallback(SCNetworkReachabilityRef aTarget, SCNetworkReachabilityFlags aFlags, void *anInfo)
{
#pragma unused (aTarget, aFlags)

	NSCAssert(anInfo != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject *)anInfo isKindOfClass:[RJConversionReachability class]],
				@"info was wrong class in ReachabilityCallback");
    
	// We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
	// in case someon uses the Reachablity object in a different thread.
	@autoreleasepool {
	
		RJConversionReachability* theNoteObject = (__bridge RJConversionReachability *)anInfo;
		// Post a notification to notify the client that the network reachability changed.
		[[NSNotificationCenter defaultCenter] postNotificationName:kRJReachabilityStatusChanged object:theNoteObject];
	
	}
}

@end


