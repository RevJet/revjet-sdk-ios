//  RJConversionTracker.m
//  RevJetSDK

//  Copyright (c) RevJet. All rights reserved.


#import <UIKit/UIKit.h>

#import "RJConversionTracker.h"
#import "RJConversionConfig.h"
#import "RJConversionCommon.h"

static NSTimeInterval const kRJRequestTimeoutInterval = 60.0f;
static NSInteger const kRJStatusCodeOK = 200;

static RJConversionTracker *sConversionTracker = nil;

@interface RJConversionTracker () <NSURLConnectionDelegate>

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger statusCode;

@end

@implementation RJConversionTracker

+ (RJConversionTracker *)sharedConversionTracker
{
	if (nil == sConversionTracker)
	{
		sConversionTracker = [[RJConversionTracker alloc] init];
	}
	
	return sConversionTracker;
}

#pragma mark -

- (void)reportApplicationDidFinishLaunching
{
	if (![[NSUserDefaults standardUserDefaults] boolForKey:kRJConversionPropertyName])
	{
		NSString *theConversionURL = [RJConversionCommon conversionUrl];
		NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:theConversionURL]
					cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kRJRequestTimeoutInterval];
		[theRequest setValue:[RJConversionCommon getUserAgent] forHTTPHeaderField:@"User-Agent"];
		self.responseData = [NSMutableData data];
		[NSURLConnection connectionWithRequest:theRequest delegate:self];
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
	self.statusCode = [(NSHTTPURLResponse *)aResponse statusCode];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)aRata
{
	[self.responseData appendData:aRata];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	if (self.statusCode == kRJStatusCodeOK && [self.responseData length] > 0)
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kRJConversionPropertyName];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

@end



