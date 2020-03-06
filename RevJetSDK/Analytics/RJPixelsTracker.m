//
//  RJPixelsTracker.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJPixelsTracker.h"

#import "RJPixelsQueue.h"

static NSString *const kRJImpressionKey = @"ImpressionUrl";
static NSString *const kRJClickKey = @"ClickUrl";
static NSString *const kRJNoBidKey = @"NobidUrl";

static NSString *const kRJHeadersParameterKey = @"X-Headers";
static NSString *const kRJImpressionURLHeaderKey = @"X-ImpURL";

enum
{
	kRJPixelsTrackerURLImpressionFromHeaders = 333
};

@interface RJPixelsTracker ()

+ (NSString *)URLKeyFromType:(RJPixelsTrackerURLType)aType;

@property (nonatomic, strong) NSDictionary *pixelsMap;

@end

@implementation RJPixelsTracker

@synthesize pixelsMap;

- (id)initWithNetworkInfo:(NSDictionary *)aNetworkInfo
{
	if (nil == aNetworkInfo)
	{
		return nil;
	}
	
	self = [super init];
	if (nil != self)
	{
		NSMutableDictionary *thePixelsMap = [NSMutableDictionary dictionaryWithCapacity:3];
		NSString *theM2ImpressionURL = aNetworkInfo[kRJImpressionKey];
		if (nil != theM2ImpressionURL)
		{
			thePixelsMap[kRJImpressionKey] = theM2ImpressionURL;
		}
		
		NSString *theImpressionURL = [aNetworkInfo[kRJHeadersParameterKey]
					objectForKey:kRJImpressionURLHeaderKey];
		if (nil != theImpressionURL)
		{
			thePixelsMap[kRJImpressionURLHeaderKey] = theImpressionURL;
		}
		
		NSString *theClickURL = aNetworkInfo[kRJClickKey];
		if (nil != theClickURL)
		{
			thePixelsMap[kRJClickKey] = theClickURL;
		}
		NSString *theNoBidURL = aNetworkInfo[kRJNoBidKey];
		if (nil != theNoBidURL)
		{
			thePixelsMap[kRJNoBidKey] = theNoBidURL;
		}
		
		self.pixelsMap = [NSDictionary dictionaryWithDictionary:thePixelsMap];
	}
	
	return self;
}

- (id)init
{
	return [self initWithNetworkInfo:nil];
}

#pragma mark -

- (void)trackPixelOfURLType:(RJPixelsTrackerURLType)aType
{
	NSString *theURLKey = [RJPixelsTracker URLKeyFromType:aType];
	[self trackPixelForURLKey:theURLKey];
	if (kRJPixelsTrackerURLImpression == aType)
	{
		theURLKey = [RJPixelsTracker URLKeyFromType:kRJPixelsTrackerURLImpressionFromHeaders];
		[self trackPixelForURLKey:theURLKey];
	}
}

#pragma mark - Private

+ (NSString *)URLKeyFromType:(RJPixelsTrackerURLType)aType
{
	static NSDictionary *sURLKeysMap = nil;
	static dispatch_once_t sURLKeysMapMapispatch = 0;
	dispatch_once(&sURLKeysMapMapispatch, ^
	{
		sURLKeysMap = [NSDictionary dictionaryWithObjectsAndKeys:
				kRJImpressionKey, [NSNumber numberWithInt:kRJPixelsTrackerURLImpression],
				kRJImpressionURLHeaderKey, [NSNumber numberWithInt:kRJPixelsTrackerURLImpressionFromHeaders],
				kRJClickKey, [NSNumber numberWithInt:kRJPixelsTrackerURLClick],
				kRJNoBidKey, [NSNumber numberWithInt:kRJPixelsTrackerURLNoBid], nil];
	});
	
	return [sURLKeysMap objectForKey:[NSNumber numberWithInt:aType]];
}

- (void)trackPixelForURLKey:(NSString *)aURLKey
{
	if (nil != aURLKey)
	{
		NSString *theURLString = self.pixelsMap[aURLKey];
		if (nil != theURLString)
		{
			NSURL *theURL = [NSURL URLWithString:theURLString];
			[[RJPixelsQueue defaultQueue] addPixelToQueue:theURL];
		}
	}
}


@end
