//
//  RJPixelsQueue.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJPixelsQueue.h"

#import "RJNetwork.h"

static NSString *const kRJPixelsQueueKey = @"com.revjetsdk.pixelsqueue";

static RJPixelsQueue *sPixelsQueque = nil;

@interface RJPixelsQueue ()

@property (nonatomic, strong) NSMutableArray *pixelsQueue;
@property (nonatomic, assign) BOOL shouldDoPostCheck;

@end

@implementation RJPixelsQueue

@synthesize pixelsQueue;

+ (RJPixelsQueue *)defaultQueue
{
	if (nil == sPixelsQueque)
	{
		sPixelsQueque = [[RJPixelsQueue alloc] init];
	}
	
	return sPixelsQueque;
}

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		self.pixelsQueue = [NSMutableArray array];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
					name:UIApplicationWillResignActiveNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
					name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)addPixelToQueue:(NSURL *)aPixelURL
{
	if ([self isURLValid:aPixelURL])
	{
		[self sendPixel:aPixelURL];
	}
}

- (void)addStringPixelToQueue:(NSString *)aPixelString
{
	if (nil != aPixelString)
	{
		NSURL *thePixelURL = [NSURL URLWithString:aPixelString];
		[self addPixelToQueue:thePixelURL];
	}
}

- (void)addStringPixelsToQueue:(NSArray *)aStringPixels
{
	for (NSString *thePixel in aStringPixels)
	{
		[self addStringPixelToQueue:thePixel];
	}
}

#pragma mark - Private

- (BOOL)isURLValid:(NSURL *)anURL
{
	BOOL theResult = (nil != anURL);
	if (theResult)
	{
		BOOL hasScheme = (nil != [anURL scheme]);
		BOOL hasHost = (nil != [anURL host]);
		theResult = (hasScheme && hasHost);
	}
	return theResult;
}

- (void)sendPixel:(NSURL *)anURL
{
	[self.pixelsQueue addObject:anURL];
	NSMutableURLRequest *theTrackRequest = [NSMutableURLRequest requestWithURL:anURL
				cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
	[theTrackRequest setValue:kRJUserAgent forHTTPHeaderField:@"User-Agent"];
	[self performSelectorInBackground:@selector(performSendRequest:) withObject:theTrackRequest];
}

- (void)performSendRequest:(NSMutableURLRequest *)aRequest
{
	@autoreleasepool
	{
		NSURLResponse *theResponse = nil;
		NSError *theError = nil;
		[NSURLConnection sendSynchronousRequest:aRequest returningResponse:&theResponse error:&theError];
		if ((nil == theError) && (nil != theResponse))
		{
			[self performSelectorOnMainThread:@selector(removeURLFromQueue:) withObject:[aRequest URL]
						waitUntilDone:NO];
		}
	}
}

- (void)removeURLFromQueue:(NSURL *)anURL
{
	[self.pixelsQueue removeObject:anURL];
	
	if (self.shouldDoPostCheck)
	{
		NSData *thePixelsQueueData = [[NSUserDefaults standardUserDefaults] valueForKey:kRJPixelsQueueKey];
		if (nil != thePixelsQueueData)
		{
			NSArray *thePixels = [NSKeyedUnarchiver unarchiveObjectWithData:thePixelsQueueData];
			if ([thePixels containsObject:anURL])
			{
				NSData *thePixelsQueueData = [NSKeyedArchiver archivedDataWithRootObject:self.pixelsQueue];
				if (nil != thePixelsQueueData)
				{
					[[NSUserDefaults standardUserDefaults] setValue:thePixelsQueueData forKey:kRJPixelsQueueKey];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
			}
		}
	}
}

#pragma mark - Notifications

- (void)applicationWillResignActive:(NSNotification *)aNotifications
{
	if (0 != [self.pixelsQueue count])
	{
		NSData *thePixelsQueueData = [NSKeyedArchiver archivedDataWithRootObject:self.pixelsQueue];
		if (nil != thePixelsQueueData)
		{
			[[NSUserDefaults standardUserDefaults] setValue:thePixelsQueueData forKey:kRJPixelsQueueKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			self.shouldDoPostCheck = YES;
		}
	}
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotifications
{
	NSData *thePixelsQueueData = [[NSUserDefaults standardUserDefaults] valueForKey:kRJPixelsQueueKey];
	if (nil != thePixelsQueueData)
	{
		NSArray *thePixels = [NSKeyedUnarchiver unarchiveObjectWithData:thePixelsQueueData];
		for (NSURL *thePixel in thePixels)
		{
			[self sendPixel:thePixel];
		}
		[[NSUserDefaults standardUserDefaults] setValue:nil forKey:kRJPixelsQueueKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		self.shouldDoPostCheck = NO;
	}
}

@end
