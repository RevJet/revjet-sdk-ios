//
//  RJNetwork.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJNetwork.h"

#import "RJGlobal.h"
#import "RJSlot.h"
#import "RJSlotDelegate.h"
#import "RJSlotView.h"
#import "RJBaseAdapter.h"
#import "RJBaseAdapterInterstitial.h"
#import "RJNetworkMapping.h"
#import "RJURL.h"
#import "RJHTMLScanner.h"
#import "RJAdapterDelegate.h"

#import "RJVASTXMLParserAggregator.h"

#import "RJPixelsTracker.h"
#import "RJPixelsQueue.h"

#import "RJUtilities.h"

#import <objc/message.h>

static NSTimeInterval const kRJDefaultRefreshRate = 40.0f;
static NSTimeInterval const kRJCancelAdapterTimeout = 300.0f;
static NSTimeInterval const kRJDefaultErrorRetryTimeout = 30.0f;

NSString *const kRJParamParameters = @"Parameters";

static NSString *const kRJHTMLContentType = @"html";
static NSString *const kRJJSONContentType = @"json";
static NSString *const kRJXMLContentType = @"xml";


static NSString *const kRJParamNetworksArray = @"networks";
static NSString *const kRJParamAdsParameters = @"adsParams";
static NSString *const kRJParamRequestID = @"requestId";
static NSString *const kRJParamRefreshRate = @"RefreshRate";
static NSString *const kRJParamNetworkType = @"NetworkType";
static NSString *const kRJParamAdType = @"AdType";
static NSString *const kRJParamTransitionAnimation = @"TransitionAnimation";

static NSString *const kRJParamNoBidUrl = @"NobidUrl";

static NSString *const kRJAdTypeVideo = @"VIDEO";
static NSString *const kRJAdTypeAudio = @"AUDIO";

static NSString *const kRJAdvertisementAvailable = @"advertisementAvailable";

static NSString *const kRJReportErrorURL = @"https://mobile-ios.revjet.com/sdkerror";
static NSString *const kRJReportErrorURLFormat = @"&sdkerror=%d&sdkerrorline=%d";
static NSString *const kRJReportErrorSlotURLFormat = @"&slot=%@";
static NSString *const kRJReportErrorExceptionClassFormat = @"&sdkerror_class=%@";
static NSString *const kRJReportErrorReasonFormat = @"&sdkerror_reason=%@";
static NSString *const kRJReportErrorTimeFormat = @"&sdkerror_time=%@";

static NSString *const kRJUnhandledExceptionMessage = @"Unhandled Exception";

static NSString *const kRJHeadersParameterKey = @"X-Headers";

NSString *kRJUserAgent = nil;

typedef enum
{
	kRJErrorCodeNoError,
	kRJErrorCodeUnhandledException,
	kRJErrorCodeLoadNextInterstitialAdapterException,
	kRJErrorCodeLoadNextAdapterException,
	kRJErrorCodeLoadSlotException,
	kRJErrorCodeMissingNetworkType,
	kRJErrorCodeAdViewTransitionFailed,
	kRJErrorCodeBadStatusCode,
	kRJErrorCodeEmptyNetworksArray,
	kRJErrorCodeEmptyResponse,
	kRJErrorCodeUnknownNetworkType,
	kRJErrorCodeNetworkInfoInvalid,
	kRJErrorCodeUnknownAdType,
	kRJErrorCodeUnknownContentType,
	kRJErrorCodeNoTagUrl,
	kRJErrorCodeResumeAdException,
	kRJErrorCodePauseAdException
} RJErrorCodeType;

static NSInteger const kRJFirstNetworkInfoIndex = 0;

@interface RJNetwork () <RJAdapterDelegate>

//! Contains an array of dictionaries with info about each network.
@property (nonatomic, strong) NSArray *networksInfos;

//! An index of current network info which is processing.
@property (nonatomic, assign) NSInteger indexOfCurrentNetworkInfo;

@property (nonatomic, assign) BOOL isJSONResponse;
@property (nonatomic, assign) BOOL isAdapterBusy;

- (void)performLoadAd;
- (void)didLoadSlot;
- (void)didFailWithError:(NSError *)anError;
- (void)didShowAd:(UIView *)aView;

- (void)obtainAdParameters:(NSString *)aContentType;

//! Checks if received network parameters are valid for network type. If it does not contain app ID for
//! the network - returns <code>NO</code>
- (BOOL)isParametersValid:(NSDictionary *)aParameters networkType:(NSString *)aType;
- (BOOL)isParameterValid:(NSString *)aParameter;
- (BOOL)isSlotTagValid:(NSString *)aSlotTag;

- (BOOL)autoRefresh;
- (void)setAutoRefresh:(BOOL)refresh;

- (void)setupTimer;
- (void)cancelTimer;
- (void)timerRefreshAd;

- (void)reportErrorCode:(RJErrorCodeType)aCode;
- (void)reportError:(NSString *)aMessage withCode:(RJErrorCodeType)aCode;
- (void)reportUnhandledException;
@property (assign) int errorCodeLine;

- (void)applicationWillResignActive:(UIApplication *)anApplication;
- (void)applicationDidBecomeActive:(UIApplication *)anApplication;

- (void)loadAdapterFromInfo:(NSDictionary *)aNetworkInfo;
- (void)performLoadAdapterFromInfo:(NSDictionary *)aNetworkInfo;
- (BOOL)isNetworkInfoValid:(NSDictionary *)aNetworkInfo;
- (void)loadNextAdapter;
- (BOOL)isNextAdapterAvailable;
- (void)performCheckIfNextAdapterAvailableForNetworkInfo:(NSDictionary *)aNetworkInfo;

- (NSError *)lastError;
- (NSURLResponse *)response;

@property (nonatomic, strong) NSTimer *cancelAdapterTimer;
- (void)cancelAdapter:(NSTimer *)aTimer;
- (void)notifyDelegateAdapterError:(NSError *)anError;
- (void)notifyDelegateInterstitialAdapterError:(NSError *)anError;

- (void)pauseAd;
- (void)resumeAd;
@property (nonatomic, strong) NSDate *pauseStart;
@property (nonatomic, strong) NSDate *previousFireDate;
@property (nonatomic, assign) BOOL isPaused;

@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isAutoRefresh;

@property (nonatomic, assign) NSInteger refreshRate;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, strong) NSError *lastError;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) RJBaseAdapter *currentAdapter;
@property (nonatomic, strong) RJBaseAdapter *previousAdapter;

@property (nonatomic, strong) NSException *lastException;

- (NSDictionary *)dictionaryWithUppercaseKeysFromDictionary:(NSDictionary *)aDictionary;

@property (nonatomic, assign) BOOL shouldShowAdOnLoad;
@property (nonatomic, strong) UIView *readyAdView;

- (NSString *)adTypeForString:(NSString *)aValue;

@end

@implementation RJNetwork

@synthesize networksInfos, indexOfCurrentNetworkInfo, useRequestId, requestId, isJSONResponse, slot, isAdapterBusy,
			cancelAdapterTimer, pauseStart, previousFireDate, isPaused, isRequesting, isAutoRefresh, refreshRate,
			refreshTimer, lastError, response, responseData, currentAdapter, previousAdapter, errorCodeLine,
			lastException, shouldShowAdOnLoad, readyAdView;

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		self.isAutoRefresh = NO;

		if (!kRJUserAgent)
		{
			UIWebView *theWebview = [[UIWebView alloc] init];
			kRJUserAgent = [[theWebview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] copy];
		}

		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

		[notificationCenter addObserver:self selector:@selector(applicationWillResignActive:)
					name:@"UIApplicationWillResignActiveNotification" object:nil];
		[notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive:)
					name:@"UIApplicationDidBecomeActiveNotification" object:nil];
		[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange:)
					name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	
	return self;
}

- (id)initWithSlot:(RJSlot *)aSlot
{
	self = [self init];
	if (nil != self)
	{
		self.slot = aSlot;
	}
	
	return self;
}

- (void)dealloc
{
	RJLog(@"dealloc");

	self.isRequesting = NO;
	self.slot = nil;
	[self stopBeingDelegate];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopBeingDelegate
{
	self.currentAdapter.delegate = nil;
	self.previousAdapter.delegate = nil;
	self.currentAdapter = nil;
	self.previousAdapter = nil;
}

#pragma mark -

- (void)loadAd
{
	self.shouldShowAdOnLoad = YES;
	[self performLoadAd];
}

- (void)fetchAd
{
	self.shouldShowAdOnLoad = NO;
	[self performLoadAd];
}

- (void)showAd
{
	@try
	{
		// check if interstitial
		RJBaseAdapterInterstitial *adapterInterstitial = (RJBaseAdapterInterstitial *)self.currentAdapter;
		if ([adapterInterstitial respondsToSelector:@selector(showAd)])
		{
			[adapterInterstitial showAd];
		}
		else
		{
			// current adapter is banner type.
			[self.slot.view transitionToView:self.readyAdView animation:self.currentAdapter.transitionAnimation];
		}
	}
	@catch (NSException *anException)
	{
		[self reportError:kRJUnhandledExceptionMessage withCode:kRJErrorCodeNoError];
	}
}

- (void)performLoadAd
{
	if (self.isRequesting)
	{
		RJLog(@"Already requesting an Ad");
		return;
	}
	else if (self.isAdapterBusy)
	{
		RJLog(@"Adapter is busy");
		return;
	}
	else if (nil == self.slot.tagUrl)
	{
		RJLog(@"Tag URL is nil");
		self.errorCodeLine = __LINE__;
		[self reportError:@"Slot tag is Nil" withCode:kRJErrorCodeNoTagUrl];
		return;
	}
	else if ([RJUtilities isSmartBanner:self.slot.tagUrl])
	{
		CGRect theFrame = CGRectZero;
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			// always 728x90
			theFrame.size = CGSizeMake([RJGlobal screenSize].width, 90.0f);
		}
		else
		{
			// 320x50 only for portrait
			if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
			{
				theFrame.size = CGSizeMake([RJGlobal screenSize].width, 50.0f);
			}
			else
			{
				NSString *theMessage = @"No-bid for landscape iPhone - smart banner";
				NSError *theError = [NSError errorWithDomain:kRJErrorDomain code:-100 userInfo:
				@{
					NSLocalizedDescriptionKey : NSLocalizedString(theMessage, @"")
				}];
				[self.slot.view removeAdView];
				if ([self.slot.delegate respondsToSelector:@selector(didFailToReceiveAd:error:)])
				{
					[self.slot.delegate didFailToReceiveAd:nil error:theError];
				}
				return;
			}
		}
		self.slot.view.frame = theFrame;
	}
	else
	{
		self.isRequesting = YES;
	}

	RJLog(@"Requesting new Ad");
	
	if (![self isSlotTagValid:self.slot.tagUrl])
	{
		[self reportError:@"Invalid tag URL" withCode:kRJErrorCodeNoError];
		return;
	}

	NSURL *theSlotURL = nil;
	@try
	{
//		NSURL *theURL = [NSURL URLWithString:[RJURL urlForSlot:self.slot]];
		NSURL *theURL = [NSURL URLWithString:self.slot.tagUrl];
		if (nil != theURL)
		{
			theSlotURL = theURL;
		}
	}
	@catch (NSException *anException)
	{
		self.lastException = anException;
		self.errorCodeLine = __LINE__;
		theSlotURL = nil;
	}
	
	if (nil != theSlotURL)
	{
		[self cancelTimer];
		[self loadSlotForURL:theSlotURL];
	}
}

#pragma mark - RJAdapterDelegate

- (NSNumber *)showCloseButton
{
	return self.slot.showCloseButton;
}

- (CGRect)slotViewFrame
{
	return self.slot.view.frame;
}

- (UIViewController *)viewControllerForPresentingModalView
{
	if ([self.slot.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)])
	{
		return [self.slot.delegate viewControllerForPresentingModalView];
	}
	return nil;
}

- (BOOL)runCustomFunction:(NSString *)aFunction withObject:(id)anObject
{
	SEL theSelector = NSSelectorFromString([NSString stringWithFormat:@"%@:", aFunction]);
	if (![self.slot.delegate respondsToSelector:theSelector])
	{
		return NO;
	}

	objc_msgSend(self.slot.delegate, theSelector, anObject);
	return YES;
}

- (void)runDeallocCustomFunction:(NSString *)aFunction withObject:(id)anObject
{
	SEL theSelector = NSSelectorFromString(@"deallocCustomEventAdapter:withName:");
	if ([self.slot.delegate respondsToSelector:theSelector])
	{
		objc_msgSend(self.slot.delegate, theSelector, anObject, aFunction);
	}
}

#pragma mark - RJAdapterDelegate: callbacks from adapters

- (void)adapter:(RJBaseAdapter *)anAdapter didReceiveAd:(UIView *)aView
{
	[self.cancelAdapterTimer invalidate];
	self.cancelAdapterTimer = nil;
	if (!self.isAdapterBusy)
	{
		self.networksInfos = nil;
		self.useRequestId = NO;
		BOOL isTransitionSucceed = YES;
		@try
		{
			if (self.shouldShowAdOnLoad)
			{
				[self.slot.view transitionToView:aView animation:anAdapter.transitionAnimation];
			}
			else
			{
				self.readyAdView = aView;
				if ([self.slot.delegate respondsToSelector:@selector(didReceiveAd:)])
				{
					[self.slot.delegate didReceiveAd:aView];
				}
			}
		}
		@catch (NSException *anException)
		{
			isTransitionSucceed = NO;
			self.lastException = anException;
		}
		if (!isTransitionSucceed)
		{
			self.errorCodeLine = __LINE__;
			[self reportError:@"Transition failed" withCode:kRJErrorCodeAdViewTransitionFailed];
		}
	}
	else
	{
		[self cancelTimer];
		self.isRequesting = NO;
	}
}

- (void)adapter:(RJBaseAdapter *)anAdapter didFailToReceiveAd:(UIView *)aView error:(NSError *)anError
{
	[self.cancelAdapterTimer invalidate];
	self.cancelAdapterTimer = nil;
	if (!self.isAdapterBusy)
	{
		RJLog(@"adapter:%@ didFailToReceiveAd:%@ error:%@", anAdapter, aView, anError);
		[anAdapter.pixelsTracker trackPixelOfURLType:kRJPixelsTrackerURLNoBid];
		
		self.indexOfCurrentNetworkInfo++;
		if ((nil == self.networksInfos) || (self.indexOfCurrentNetworkInfo >= [self.networksInfos count]))
		{
			self.useRequestId = YES;
			if (nil != self.previousAdapter)
			{
				[self.slot.view removeAdView];
				self.previousAdapter = nil;
			}
			if ([self.slot.delegate respondsToSelector:@selector(didFailToReceiveAd:error:)])
			{
				[self.slot.delegate didFailToReceiveAd:aView error:anError];
			}

			[self setupTimer];
			self.currentAdapter = nil;
			self.isRequesting = NO;
			self.networksInfos = nil;
		}
		else
		{
			@try
			{
				[self loadAdapterFromInfo:[self.networksInfos objectAtIndex:self.indexOfCurrentNetworkInfo]];
			}
			@catch (NSException *anException)
			{
				self.lastException = anException;
				[self reportUnhandledException];
			}
		}
	}
	else
	{
		[self cancelTimer];
		self.isRequesting = NO;
	}
}

- (void)adapter:(RJBaseAdapter *)anAdapter willPresentModalViewFromAd:(UIView *)aView
{
	if (self.isAutoRefresh && [self.refreshTimer isValid])
	{
		NSNumber *theTimerTime = [self.refreshTimer userInfo];
		NSInteger theElapsedTime = (NSInteger) [[NSDate date] timeIntervalSince1970] - [theTimerTime doubleValue];
		NSInteger theNewRefreshRate = self.refreshRate - theElapsedTime;

		if (theNewRefreshRate >= 0)
		{
			self.refreshRate = theNewRefreshRate;
		}
	}

	[self cancelTimer];

	if ([self.slot.delegate respondsToSelector:@selector(willPresentModalViewFromAd:)])
	{
		[self.slot.delegate willPresentModalViewFromAd:aView];
	}
}

- (void)adapter:(RJBaseAdapter *)anAdapter didDismissModalViewFromAd:(UIView *)aView
{
	[self setupTimer];

	if ([self.slot.delegate respondsToSelector:@selector(didDismissModalViewFromAd:)])
	{
		[self.slot.delegate didDismissModalViewFromAd:aView];
	}
}

- (void)adapter:(RJBaseAdapter *)anAdapter applicationWillTerminateFromAd:(UIView *)aView
{
	if ([self.slot.delegate respondsToSelector:@selector(applicationWillTerminateFromAd:)])
	{
		[self.slot.delegate applicationWillTerminateFromAd:aView];
	}
}

- (void)adapter:(RJBaseAdapter *)adapter didCloseAd:(UIView *)aView
{
	[self.slot.view transitionToView:nil animation:self.currentAdapter.transitionAnimation];
	[self stopBeingDelegate];
	if ([self.slot.delegate respondsToSelector:@selector(didCloseAd:)])
	{
		[self.slot.delegate didCloseAd:aView];
	}
}

- (BOOL)adapter:(RJBaseAdapter *)adapter shouldOpenURL:(NSURL*)url
{
	if ([self.slot.delegate respondsToSelector:@selector(shouldOpenURL:)]) {
		return [self.slot.delegate shouldOpenURL:url];
	} else {
		return YES;
	}
}

#pragma mark - RJAdapterDelegate: callbacks from interstitial adapters

- (void)adapter:(RJBaseAdapter *)anAdapter didReceiveInterstitialAd:(NSObject *)anInterstitialAd
{
	[self.cancelAdapterTimer invalidate];
	self.cancelAdapterTimer = nil;
	
	self.networksInfos = nil;
	if (nil != self.previousAdapter)
	{
		[self.slot.view removeAdView];
		self.previousAdapter = nil;
	}
	self.useRequestId = NO;

	if ([self.slot.delegate respondsToSelector:@selector(didReceiveInterstitialAd:)])
	{
		[self.slot.delegate didReceiveInterstitialAd:anInterstitialAd];
	}
	
	if (self.shouldShowAdOnLoad)
	{
		[self showAd];
	}
}

- (void)adapter:(RJBaseAdapter *)anAdapter didFailToReceiveInterstitialAd:(NSObject *)anInterstitialAd
			error:(NSError *)anError
{
	[self.cancelAdapterTimer invalidate];
	self.cancelAdapterTimer = nil;
	RJLog(@"adapter:%@ didFailToReceiveInterstitialAd:%@ error:%@", anAdapter, anInterstitialAd, anError);
	[anAdapter.pixelsTracker trackPixelOfURLType:kRJPixelsTrackerURLNoBid];
	
	self.indexOfCurrentNetworkInfo++;
	if ((nil == self.networksInfos) || (self.indexOfCurrentNetworkInfo >= [self.networksInfos count]))
	{
		self.useRequestId = YES;
		if ([self.slot.delegate respondsToSelector:@selector(didFailToReceiveInterstitialAd:error:)])
		{
			[self.slot.delegate didFailToReceiveInterstitialAd:anInterstitialAd error:anError];
		}

		[self setupTimer];
		self.currentAdapter = nil;
		self.currentAdapter = self.previousAdapter;
		self.previousAdapter = nil;
		self.isRequesting = NO;
	}
	else
	{
		@try
		{
			[self loadAdapterFromInfo:[self.networksInfos objectAtIndex:self.indexOfCurrentNetworkInfo]];
		}
		@catch (NSException *anExeption)
		{
			self.lastException = anExeption;
			[self reportUnhandledException];
		}
	}
}

- (void)adapter:(RJBaseAdapter *)anAdapter willPresentInterstitialAd:(NSObject *)anInterstitialAd
{
	if (self.isAutoRefresh && [self.refreshTimer isValid])
	{
		NSNumber *theTimerTime = [self.refreshTimer userInfo];
		NSInteger theElapsedTime = (NSInteger) [[NSDate date] timeIntervalSince1970] - [theTimerTime doubleValue];
		NSInteger theNewRefreshRate = self.refreshRate - theElapsedTime;

		if (theNewRefreshRate >= 0)
		{
			self.refreshRate = theNewRefreshRate;
		}
	}

	[self cancelTimer];
	
	[anAdapter.pixelsTracker trackPixelOfURLType:kRJPixelsTrackerURLImpression];

	if ([self.slot.delegate respondsToSelector:@selector(willPresentInterstitialAd:)])
	{
		[self.slot.delegate willPresentInterstitialAd:anInterstitialAd];
	}
}

- (void)adapter:(RJBaseAdapter *)anAdapter didDismissInterstitialAd:(NSObject *)anInterstitialAd
{
	[self setupTimer];

	if ([self.slot.delegate respondsToSelector:@selector(didDismissInterstitialAd:)])
	{
		[self.slot.delegate didDismissInterstitialAd:anInterstitialAd];
	}

	self.isRequesting = NO;
}

- (void)adapter:(RJBaseAdapter *)anAdapter applicationWillTerminateFromInterstitialAd:(NSObject *)anInterstitialAd
{
	if ([self.slot.delegate respondsToSelector:@selector(applicationWillTerminateFromInterstitialAd:)])
	{
		[self.slot.delegate applicationWillTerminateFromInterstitialAd:anInterstitialAd];
	}

	self.isRequesting = NO;
}

- (void)trackClickForAdapter:(RJBaseAdapter *)anAdapter
{
	[anAdapter.pixelsTracker trackPixelOfURLType:kRJPixelsTrackerURLClick];
}

#pragma mark - Private methods

- (void)loadSlotForURL:(NSURL *)aURL
{
	RJLog(@"Loading slot: %@", aURL);
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:aURL
				cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kRJDefaultErrorRetryTimeout];
	if (nil != kRJUserAgent)
	{
		[theRequest setValue:kRJUserAgent forHTTPHeaderField:@"User-Agent"];
	}
	self.responseData = [NSMutableData data];
	self.lastError = nil;
	[NSURLConnection connectionWithRequest:theRequest delegate:self];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
	self.response = aResponse;
}

- (BOOL)connection:(NSURLConnection *)aConnection
			canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)aProtectionSpace
{
	return [aProtectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}


- (void)connection:(NSURLConnection *)aConnection
			didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)aChallenge
{
    [aChallenge.sender useCredential:[NSURLCredential credentialForTrust:aChallenge.protectionSpace.serverTrust]
				forAuthenticationChallenge:aChallenge];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	[self didLoadSlot];
} 
- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)aData
{
	[self.responseData appendData:aData];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)anError
{
	self.lastError = anError;
	[self didLoadSlot];
}

- (void)didLoadSlot
{
	@try
	{
		if (nil == self.slot)
		{
			return;
		}
		RJLog(@"didLoadSlot:");

		if (([self lastError] != nil) || !self.responseData || ![self response])
		{
			[self reportError:@"Network error" withCode:kRJErrorCodeNoError];
			return;
		}

		if ([[self response] isKindOfClass:[NSHTTPURLResponse class]])
		{
			NSInteger theStatusCode = [(NSHTTPURLResponse *)[self response] statusCode];
			if (theStatusCode != 200)
			{
				self.errorCodeLine = __LINE__;
				[self reportError:[NSString stringWithFormat:@"Bad status code: %ld", (long)theStatusCode]
							withCode:kRJErrorCodeBadStatusCode];
				return;
			}
		}

		NSString *theContentType = [[self response] MIMEType];
		RJLog(@"MIME type: %@", theContentType);

		RJLog(@"Received response: %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);

		if ([theContentType rangeOfString:kRJHTMLContentType].location != NSNotFound) {
			self.responseData = [self insertTagMacros:self.responseData];
		}

		[self obtainAdParameters:theContentType];
	}
	@catch (NSException *anException)
	{
		self.lastException = anException;
		[self reportUnhandledException];
	}
}

- (NSMutableData *)insertTagMacros:(NSData *)data {
	NSDictionary *parameters = [RJURL parametersForSlot:self.slot.tagUrl];
	NSDictionary *targetingParameters = [RJURL targetingParametersForSlot:self.slot];
	NSDictionary *additionalInfo = @{};

	id<RJSlotDelegate> slotDelegate = self.slot.delegate;
	if ([slotDelegate respondsToSelector:@selector(additionalInfo)]) {
		additionalInfo = [slotDelegate additionalInfo];
	}

	NSMutableDictionary *macros = [NSMutableDictionary dictionary];
	[macros addEntriesFromDictionary:parameters];
	[macros addEntriesFromDictionary:targetingParameters];
	[macros addEntriesFromDictionary:additionalInfo];

	RJLog(@"Available tag macros: %@", macros);

	NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	for (NSString *name in macros) {
		NSString *value = [RJUtilities stringEscapedForJavaScript:macros[name]];
		NSString *macro = [NSString stringWithFormat:@"{%@}", name];
		responseText = [responseText stringByReplacingOccurrencesOfString:macro withString:value];
	}

	return [NSMutableData dataWithData:[responseText dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)obtainAdParameters:(NSString *)aContentType
{
	NSMutableDictionary *theParams = nil;
	if ([aContentType rangeOfString:kRJHTMLContentType].location != NSNotFound)
	{
		if (![self.responseData length])
		{
			self.errorCodeLine = __LINE__;
			[self reportError:@"Empty response" withCode:kRJErrorCodeEmptyResponse];
			[self finishWithParameters:nil];
			return;
		}

		NSString *theHTMLBody = [[NSString alloc] initWithData:self.responseData
					encoding:NSUTF8StringEncoding];
		theParams = [NSMutableDictionary dictionaryWithDictionary:
					[RJHTMLScanner getParametersFromHTML:theHTMLBody]];
		NSDictionary *theParametersFromSlotTag = [RJUtilities getParametersFromSlotTag:self.slot.tagUrl];
		if ([theParametersFromSlotTag count] > 0)
		{
			[theParams addEntriesFromDictionary:theParametersFromSlotTag];
		}
		self.isJSONResponse = NO;
	}
	else if ([aContentType rangeOfString:kRJJSONContentType].location != NSNotFound)
	{
		NSError *theJSONError = nil;
		theParams = [NSMutableDictionary dictionaryWithDictionary:
                     [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&theJSONError]];
		self.isJSONResponse = YES;
		if (nil == theParams)
		{
			self.errorCodeLine = __LINE__;
			[self reportErrorCode:kRJErrorCodeNetworkInfoInvalid];
			[self didFailWithError:theJSONError];
			[self finishWithParameters:nil];
			return;
		}

		// Parameter NetworkType is required for JSON object
		if ((nil == [theParams valueForKey:kRJParamNetworkType]) &&
					(nil == [[[theParams valueForKey:kRJParamNetworksArray] lastObject] objectForKey:kRJParamNetworkType]))
		{
			NSNumber *theAdvertisementAvailable = theParams[kRJAdvertisementAvailable];
			BOOL theAdvertisementAvailableBool = YES;
			if ([theAdvertisementAvailable isKindOfClass:[NSNumber class]])
			{
				theAdvertisementAvailableBool = [theAdvertisementAvailable boolValue];
			}
			if ((nil != theAdvertisementAvailable) && !theAdvertisementAvailableBool)
			{
				[self reportError:@"No ad available" withCode:kRJErrorCodeNoError];
			}
			else
			{
				self.errorCodeLine = __LINE__;
				[self reportError:@"Parameter NetworkType is missing" withCode:kRJErrorCodeMissingNetworkType];
			}
			[self finishWithParameters:nil];
			return;
		}
	}
	else if ([aContentType rangeOfString:kRJXMLContentType].location != NSNotFound)
	{
		if (![self.responseData length])
		{
			self.errorCodeLine = __LINE__;
			[self reportError:@"Empty response" withCode:kRJErrorCodeEmptyResponse];
			[self finishWithParameters:nil];
			return;
		}
		
		NSString *theXML = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
		RJVASTXMLParserAggregator *theParser = [[RJVASTXMLParserAggregator alloc] init];
		[theParser parseVASTXML:theXML withHandler:^(NSDictionary *aParameters)
		{
			NSMutableDictionary *theParameters = [NSMutableDictionary dictionaryWithDictionary:aParameters];
			theParameters[kRJParamNetworkType] = kRJVASTNetworkType;
			[self finishWithParameters:theParameters];
		}];
		return;
	}
	else
	{
		self.errorCodeLine = __LINE__;
		[self reportError:@"Unknown content type" withCode:kRJErrorCodeUnknownContentType];
		[self finishWithParameters:nil];
		return;
	}
	
	[self finishWithParameters:theParams];
}

- (void)finishWithParameters:(NSDictionary *)aParameters
{
	//RJLog(@"finishWithParameters: %@", aParameters);

	if (nil == aParameters)
	{
		return;
	}

	if (0 == [self.requestId length])
	{
		NSDictionary *theAdsParams = aParameters[kRJParamAdsParameters];
		if ([theAdsParams isKindOfClass:[NSDictionary class]])
		{
			NSString *theRequestID = theAdsParams[kRJParamRequestID];
			if ([theRequestID isKindOfClass:[NSString class]])
			{
				self.requestId = theRequestID;
			}
		}
	}

	NSArray *theNetworks = aParameters[kRJParamNetworksArray];
	if ((nil != theNetworks) && ([theNetworks isKindOfClass:[NSArray class]]))
	{
		self.networksInfos = theNetworks;
		if ([theNetworks count] > 0)
		{
			self.indexOfCurrentNetworkInfo = kRJFirstNetworkInfoIndex;
			[self loadAdapterFromInfo:self.networksInfos[self.indexOfCurrentNetworkInfo]];
		}
		else
		{
			self.errorCodeLine = __LINE__;
			[self reportError:@"Empty networks array" withCode:kRJErrorCodeEmptyNetworksArray];
		}
	}
	else
	{
		self.networksInfos = nil;
		[self loadAdapterFromInfo:aParameters];
	}
}

- (void)didShowAd:(UIView *)aView
{
	RJLog(@"didShowAd");

	[self setupTimer];
	self.previousAdapter = nil;
	
	if (nil != aView)
	{
		[self.currentAdapter didShowAd];
		[self.currentAdapter.pixelsTracker trackPixelOfURLType:kRJPixelsTrackerURLImpression];
		if (self.shouldShowAdOnLoad)
		{
			if ([self.slot.delegate respondsToSelector:@selector(didReceiveAd:)])
			{
				[self.slot.delegate didReceiveAd:aView];
			}
		}

		self.isRequesting = NO;
	}
}

- (NSString *)adTypeForString:(NSString *)aValue
{
	NSString *theAdType = nil;
	if ((nil == aValue) || ![aValue isKindOfClass:[NSString class]])
	{
		theAdType = kRJAdTypeBanner;
	}
	else
	{
		theAdType = [aValue uppercaseString];
	}
	
	return theAdType;
}

#pragma mark -

- (BOOL)autoRefresh
{
	return self.isAutoRefresh;
}

- (void)setAutoRefresh:(BOOL)autoRefresh
{
	if (autoRefresh == self.isAutoRefresh)
	{
		return;
	}
	
	self.isAutoRefresh = autoRefresh;

	if (autoRefresh)
	{
		[self setupTimer];
	}
	else
	{
		[self cancelTimer];
	}
}

- (void)pauseAd
{
	@try
	{
		if (nil != self.refreshTimer)
		{
			self.pauseStart = [NSDate date];
			self.previousFireDate = [self.refreshTimer fireDate];
			[self.refreshTimer setFireDate:[NSDate distantFuture]];
		}
		else
		{
			self.pauseStart = nil;
			[self cancelTimer];
		}
		self.isPaused = YES;
	}
	@catch (NSException *anException)
	{
		self.lastException = anException;
		[self reportUnhandledException];
	}
}

- (void)resumeAd
{
	@try
	{
		self.isPaused = NO;
		if (nil != self.pauseStart)
		{
			NSTimeInterval thePauseTime = - [self.pauseStart timeIntervalSinceNow];
			[self.refreshTimer setFireDate:[previousFireDate initWithTimeInterval:thePauseTime sinceDate:self.previousFireDate]];
		}
		else
		{
			[self setupTimer];
		}
	}
	@catch (NSException *anException)
	{
		self.lastException = anException;
		[self reportUnhandledException];
	}
}

- (void)setupTimer
{
	if (!self.isAutoRefresh || self.refreshRate <= 0 || self.isPaused)
	{
		return;
	}

	[self cancelTimer];

	NSNumber *theCurrentTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
	self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.refreshRate target:self
				selector:@selector(timerRefreshAd) userInfo:theCurrentTime repeats:NO];
}

- (void)cancelTimer
{
	[self.refreshTimer invalidate];
}

- (void)timerRefreshAd
{
	RJLog(@"timerRefreshAd");

	if (self.isAutoRefresh && self.slot.view.isSlotViewVisible)
	{
		[self performLoadAd];
	}
	else
	{
		RJLog(@"An AD will not refresh. Setup timer again");
		[self setupTimer];
	}
}

- (void)didFailWithError:(NSError *)anError
{
	RJLog(@"didFailWithError: %@", anError);

	// Try to request a new ad
	if (self.refreshRate <= 0)
	{
		self.refreshRate = kRJDefaultRefreshRate;
	}

	[self setupTimer];
	[self.slot.view removeAdView];
	self.previousAdapter = nil;
	self.currentAdapter = nil;
	if ([self.slot.delegate respondsToSelector:@selector(didFailToLoadSlot:error:)])
	{
		[self.slot.delegate didFailToLoadSlot:self.slot error:anError];
	}
	
	self.isRequesting = NO;
}

- (void)reportError:(NSString *)aMessage withCode:(RJErrorCodeType)aCode
{
	if (aCode != kRJErrorCodeNoError)
	{
		[self reportErrorCode:aCode];
	}
	NSDictionary *theDictionary = @{NSLocalizedDescriptionKey: NSLocalizedString(aMessage, @"")};
	NSError *theError = [NSError errorWithDomain:kRJErrorDomain code:aCode userInfo:theDictionary];
	[self didFailWithError:theError];
}

- (void)reportErrorCode:(RJErrorCodeType)aCode
{
	NSString *theErrorURL = [RJURL stringURLForSlotTag:kRJReportErrorURL];
	NSString *tagUrl = [RJURL slotTagFromSlotURL:self.slot.tagUrl];
	if (nil != tagUrl)
	{
		theErrorURL = [theErrorURL stringByAppendingFormat:kRJReportErrorSlotURLFormat, tagUrl];
	}
	
	if (nil != theErrorURL)
	{
		theErrorURL = [theErrorURL stringByAppendingFormat:kRJReportErrorURLFormat, aCode, self.errorCodeLine];
		
		if (nil != self.lastException)
		{
			NSString *theReason = [self.lastException reason];
			if (nil != theReason)
			{
				theErrorURL = [theErrorURL stringByAppendingFormat:kRJReportErrorReasonFormat, theReason];
			}
			
			NSString *theErrorClass = nil;
			@try
			{
				NSArray *theStackTrace = [self.lastException callStackSymbols];
				for (NSString *theLine in theStackTrace)
				{
					NSRange theRange = [theLine rangeOfString:@"[RJ"];
					if (NSNotFound != theRange.location)
					{
						NSRange theSpaceRange = [theLine rangeOfString:@"]" options:NSCaseInsensitiveSearch
									range:NSMakeRange(theRange.location, [theLine length] - theRange.location - 1)];
						if (NSNotFound != theSpaceRange.location)
						{
							theErrorClass = [theLine substringWithRange:NSMakeRange(
										theRange.location + 1, theSpaceRange.location - theRange.location - 1)];
							break;
						}
					}
				}
			}
			@catch (NSException *anException) {}
			
			if (nil != theErrorClass)
			{
				theErrorURL = [theErrorURL stringByAppendingFormat:kRJReportErrorExceptionClassFormat, theErrorClass];
			}
		}
		
		NSDateFormatter *theDateFormatter = [[NSDateFormatter alloc] init];
		[theDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
		[theDateFormatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
		NSString *theStringDate = [theDateFormatter stringFromDate:[NSDate date]];
		if (nil != theStringDate)
		{
			theErrorURL = [theErrorURL stringByAppendingFormat:kRJReportErrorTimeFormat, theStringDate];
		}
		
		theErrorURL = [theErrorURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[[RJPixelsQueue defaultQueue] addStringPixelToQueue:theErrorURL];
	}
}

- (void)reportUnhandledException
{
	[self reportError:kRJUnhandledExceptionMessage withCode:kRJErrorCodeUnhandledException];
}

- (void)loadAdapterFromInfo:(NSDictionary *)aNetworkInfo
{
	if (![self isNetworkInfoValid:aNetworkInfo] && self.isJSONResponse)
	{
		self.isRequesting = NO;
		[[RJPixelsQueue defaultQueue] addStringPixelToQueue:[aNetworkInfo valueForKey:kRJParamNoBidUrl]];
		if ([self isNextAdapterAvailable])
		{
			[self reportErrorCode:kRJErrorCodeNetworkInfoInvalid];
			[self loadNextAdapter];
		}
		else
		{
			self.useRequestId = YES;
			[self reportError:@"Network Info is not valid" withCode:kRJErrorCodeNetworkInfoInvalid];
		}
		return;
	}
	
	[self performLoadAdapterFromInfo:aNetworkInfo];
}

- (void)performLoadAdapterFromInfo:(NSDictionary *)aNetworkInfo
{
	@try
	{
		NSString *theNetworkType = [[aNetworkInfo valueForKey:kRJParamNetworkType] uppercaseString];
		NSDictionary *theParameters = [aNetworkInfo valueForKey:kRJParamParameters];

		if (theNetworkType == nil) {
			if (theParameters[kRJParamNetworkType] != nil) {
				theNetworkType = [theParameters[kRJParamNetworkType] uppercaseString];
			} else {
				theNetworkType = kRJNetworkType; // Default network type
			}
		}

		NSMutableDictionary *adapterParameters = [NSMutableDictionary dictionaryWithCapacity:4];
		if ([kRJNetworkType isEqualToString:theNetworkType] || [kRJMRAIDNetworkType isEqualToString:theNetworkType] ||
					[kRJ2NetworkType isEqualToString:theNetworkType])
		{
			// Pass HTML response to adapter parameters
			NSString *theHTMLBody = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
			[adapterParameters setValue:theHTMLBody forKey:@"HTML"];
			
			if ([kRJ2NetworkType isEqualToString:theNetworkType])
			{
				NSDictionary *theAdditionalParametersFromSlotTag =
							[RJUtilities getParametersFromSlotTag:self.slot.tagUrl];
				if (0 != [theAdditionalParametersFromSlotTag count])
				{
					[adapterParameters addEntriesFromDictionary:theAdditionalParametersFromSlotTag];
				}
			}
			else
			{
				[adapterParameters addEntriesFromDictionary:aNetworkInfo];
			}

			// TODO

			// MRAID compliant?
//			if (![kRJMRAIDNetworkType isEqualToString:theNetworkType] &&
//						[theHTMLBody rangeOfString:@"mraid" options:NSCaseInsensitiveSearch].location != NSNotFound)
//			{
//				theNetworkType = kRJMRAIDNetworkType;
//			}
		}
		else if ([kRJVASTNetworkType isEqualToString:theNetworkType])
		{
			adapterParameters = [NSMutableDictionary dictionaryWithDictionary:aNetworkInfo];
		}

		RJLog(@"networkType = %@", theNetworkType);
	  
		NSString *theAdType = [aNetworkInfo valueForKey:kRJParamAdType];
		theAdType = [self adTypeForString:theAdType];

		RJLog(@"adType = %@", theAdType);

		// Find class for the network type
		Class theAdapterClass = Nil;
		if ([kRJAdTypeInterstitial isEqualToString:theAdType])
		{
			theAdapterClass = [[RJNetworkMapping sharedMapping] interstitialAdapterClassForType:theNetworkType];
		}
		else if ([kRJAdTypeBanner isEqualToString:theAdType])
		{
			theAdapterClass = [[RJNetworkMapping sharedMapping] adapterClassForType:theNetworkType];
		}
		else
		{
			[[RJPixelsQueue defaultQueue] addStringPixelToQueue:[aNetworkInfo valueForKey:kRJParamNoBidUrl]];
			if ([self isNextAdapterAvailable])
			{
				[self reportErrorCode:kRJErrorCodeUnknownAdType];
				[self loadNextAdapter];
			}
			else
			{
				self.useRequestId = YES;
				self.errorCodeLine = __LINE__;
				NSString *theUnknownAdTypeError = [NSString stringWithFormat:@"Unknown ad type: %@", theAdType];
				[self reportError:theUnknownAdTypeError withCode:kRJErrorCodeUnknownAdType];
			}
			return;
		}

		if (Nil == theAdapterClass)
		{
			[[RJPixelsQueue defaultQueue] addStringPixelToQueue:[aNetworkInfo valueForKey:kRJParamNoBidUrl]];
			if ([self isNextAdapterAvailable])
			{
				[self reportErrorCode:kRJErrorCodeUnknownNetworkType];
				[self loadNextAdapter];
			}
			else
			{
				NSString *theUnknownNetworkTypeError = [NSString stringWithFormat:@"Unknown network type: %@", theNetworkType];
				self.useRequestId = YES;
				self.errorCodeLine = __LINE__;
				[self reportError:theUnknownNetworkTypeError withCode:kRJErrorCodeUnknownNetworkType];
			}
			return;
		}

		// Instantiate the adapter
		self.previousAdapter = self.currentAdapter;
		self.currentAdapter = [[theAdapterClass alloc] initWithDelegate:self];

		// Initialize parameters
		NSString *theRefreshRate = [aNetworkInfo valueForKey:kRJParamRefreshRate];
		NSInteger theRegreshRateValue = [theRefreshRate integerValue];
		if (0 == theRegreshRateValue)
		{
			theRegreshRateValue = kRJDefaultRefreshRate;
		}
		self.refreshRate = theRegreshRateValue;

		NSString *theTransitionAnimation = [aNetworkInfo valueForKey:kRJParamTransitionAnimation];
		self.currentAdapter.transitionAnimation = theTransitionAnimation ? [theTransitionAnimation uppercaseString] :
					kRJDefaultTransitionAnimation;

		NSMutableDictionary *theNetworkInfoForTracker = [NSMutableDictionary dictionaryWithDictionary:aNetworkInfo];
		if ([[self response] isKindOfClass:[NSHTTPURLResponse class]])
		{
			NSDictionary *theHeaders = [(NSHTTPURLResponse *)[self response] allHeaderFields];
			if ([kRJ2NetworkType isEqualToString:theNetworkType] || [kRJNetworkType isEqualToString:theNetworkType] ||
						[kRJMRAIDNetworkType isEqualToString:theNetworkType])
			{
				theNetworkInfoForTracker[kRJHeadersParameterKey] = theHeaders;
			}
		}
		self.currentAdapter.pixelsTracker = [[RJPixelsTracker alloc] initWithNetworkInfo:theNetworkInfoForTracker];

		// Additional parameters for 3rd party adapters

		if (nil != theParameters)
		{
			for (NSString *theKey in [theParameters keyEnumerator])
			{
				adapterParameters[[theKey uppercaseString]] = theParameters[theKey];
			}
		}
		

		self.currentAdapter.params = adapterParameters;
		RJLog(@"%@", adapterParameters);

		[self.cancelAdapterTimer invalidate];
		self.cancelAdapterTimer = nil;
		self.cancelAdapterTimer = [NSTimer scheduledTimerWithTimeInterval:kRJCancelAdapterTimeout target:self
																 selector:@selector(cancelAdapter:) userInfo:[NSDictionary dictionaryWithObject:theAdType
					forKey:kRJParamAdType]                        repeats:NO];
		// Load ad
		[self.currentAdapter getAd];
	}
	@catch (NSException *anException)
	{
		self.errorCodeLine = __LINE__;
		self.lastException = anException;
		[self reportUnhandledException];
	}
}

- (void)performCheckIfNextAdapterAvailableForNetworkInfo:(NSDictionary *)aNetworkInfo
{
	[[RJPixelsQueue defaultQueue] addStringPixelToQueue:[aNetworkInfo valueForKey:kRJParamNoBidUrl]];
	if ([self isNextAdapterAvailable])
	{
		[self loadNextAdapter];
	}
	else
	{
		self.useRequestId = YES;
		[self reportError:@"No ad available" withCode:kRJErrorCodeNoError];
	}
}

- (void)cancelAdapter:(NSTimer *)aTimer
{
	NSDictionary *theErrorDictionary = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Timeout error", @"")
				forKey:NSLocalizedDescriptionKey];
	NSError *theError = [NSError errorWithDomain:kRJErrorDomain code:408 userInfo:theErrorDictionary];
	
	NSDictionary *theUserInfo = [aTimer userInfo];
	NSString *theAdType = theUserInfo[kRJParamAdType];
	SEL theFailSelector = @selector(notifyDelegateAdapterError:);
	if ([kRJAdTypeInterstitial isEqualToString:theAdType])
	{
		theFailSelector = @selector(notifyDelegateInterstitialAdapterError:);
	}
	
	[self performSelectorOnMainThread:theFailSelector withObject:theError waitUntilDone:NO];
}

- (void)notifyDelegateAdapterError:(NSError *)anError
{
	[self adapter:self.currentAdapter didFailToReceiveAd:nil error:anError];
}

- (void)notifyDelegateInterstitialAdapterError:(NSError *)anError
{
	[self adapter:self.currentAdapter didFailToReceiveInterstitialAd:nil error:anError];
}

- (BOOL)isNetworkInfoValid:(NSDictionary *)aNetworkInfo
{
	NSString *theNetworkType = aNetworkInfo[kRJParamNetworkType];
	if (nil == theNetworkType)
	{
		self.errorCodeLine = __LINE__;
		return NO;
	}

	return [self isParametersValid:aNetworkInfo[kRJParamParameters] networkType:theNetworkType];
}

- (BOOL)isNextAdapterAvailable
{
	BOOL theResult = NO;
	self.indexOfCurrentNetworkInfo++;
	if ((nil != self.networksInfos) && (self.indexOfCurrentNetworkInfo < [self.networksInfos count]))
	{
		theResult = YES;
	}
	
	self.indexOfCurrentNetworkInfo--;
	
	return theResult;
}

- (void)loadNextAdapter
{
	self.indexOfCurrentNetworkInfo++;
	if ((nil != self.networksInfos) && (self.indexOfCurrentNetworkInfo < [self.networksInfos count]))
	{
		[self loadAdapterFromInfo:self.networksInfos[self.indexOfCurrentNetworkInfo]];
	}
}

- (NSError *)lastError
{
	return lastError;
}

- (NSURLResponse *)response
{
	return response;
}

- (BOOL)isParametersValid:(NSDictionary *)aParameters networkType:(NSString *)aType
{
	if ([[aType uppercaseString] isEqualToString:kRJIAdNetworkType])
	{
		return YES;
	}

	if ((nil == aParameters) || ![aParameters isKindOfClass:[NSDictionary class]] ||
				![aType isKindOfClass:[NSString class]])
	{
		self.errorCodeLine = __LINE__;
		return NO;
	}
	
	NSString *theNetworkType = [aType uppercaseString];
	NSDictionary *theParameters = [self dictionaryWithUppercaseKeysFromDictionary:aParameters];
	
	if ([theNetworkType isEqualToString:kRJAdMobNetworkType])
	{
		self.errorCodeLine = __LINE__;
		return [self isParameterValid:theParameters[kRJAdMobAppIDKey]];
	}
	else if ([theNetworkType isEqualToString:kRJMillennialMediaNetworkType])
	{
		self.errorCodeLine = __LINE__;
		return [self isParameterValid:theParameters[kRJMillennialMediaAppIDKey]];
	}
	else if ([theNetworkType isEqualToString:kRJ2NetworkType])
	{
		self.errorCodeLine = __LINE__;
		NSString *theSlotTag = theParameters[kRJNetworkSlotTagKey];
		if ([self isParameterValid:theSlotTag])
		{
			return [self isSlotTagValid:theSlotTag];
		}
		
		return NO;
	}
	else if ([theNetworkType isEqualToString:kRJInMobiNetworkType])
	{
		self.errorCodeLine = __LINE__;
		return [self isParameterValid:theParameters[kRJInMobiAppIDKey]];
	}
	else if ([theNetworkType isEqualToString:kRJGreystripeNetworkType])
	{
		self.errorCodeLine = __LINE__;
		return [self isParameterValid:theParameters[kRJGreystripeAppIDKey]];
	}
	else if ([theNetworkType isEqualToString:kRJMobclixNetworkType])
	{
		self.errorCodeLine = __LINE__;
		return [self isParameterValid:theParameters[kRJMobclixAppIDKey]];
	}
	else if ([theNetworkType isEqualToString:kRJJumptapNetworkType])
	{
		self.errorCodeLine = __LINE__;
		return [self isParameterValid:theParameters[kRJJumptapAppIDKey]];
	}
	else if ([theNetworkType isEqualToString:kRJMoPubNetworkType])
	{
		self.errorCodeLine = __LINE__;
		return [self isParameterValid:theParameters[kRJMoPubAppIDKey]];
	}
	else if ([theNetworkType isEqualToString:kRJMobFoxNetworkType])
	{
		self.errorCodeLine = __LINE__;
		return [self isParameterValid:theParameters[kRJMobFoxAppIDKey]];
	}
	
	return YES;
}

- (BOOL)isParameterValid:(NSString *)aParameter
{
	BOOL theResult = NO;
	if ([aParameter isKindOfClass:[NSString class]])
	{
		theResult = ([aParameter length] > 0);
	}
	
	return theResult;
}

- (BOOL)isSlotTagValid:(NSString *)aSlotTag
{
	return YES;
}

- (NSDictionary *)dictionaryWithUppercaseKeysFromDictionary:(NSDictionary *)aDictionary
{
	NSMutableDictionary *theResultDictionary = nil;
	if (nil != aDictionary)
	{
		theResultDictionary = [NSMutableDictionary dictionaryWithCapacity:[aDictionary count]];
		for (NSString *theKey in [aDictionary keyEnumerator])
		{
			[theResultDictionary setObject:[aDictionary objectForKey:theKey] forKey:[theKey uppercaseString]];
		}
	}
	
	return theResultDictionary;
}

#pragma mark - Notifications

- (void)applicationWillResignActive:(UIApplication *)anApplication
{
	RJLog(@"applicationWillResignActive:");
	self.isRequesting = NO;
	[self cancelTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)anApplication
{
	RJLog(@"applicationDidBecomeActive:");
	
	BOOL isConrollerVisible = NO;
	UIViewController *theViewController = [self.slot.delegate viewControllerForPresentingModalView];
	if (nil != theViewController)
	{
		if ([theViewController isViewLoaded] && (nil != theViewController.view.window))
		{
			isConrollerVisible = YES;
		}
	}
	
	if (self.isAdapterBusy)
	{
		if (isConrollerVisible)
		{
			self.isAdapterBusy = NO;
		}
		else
		{
			self.isAdapterBusy = YES;
		}
	}
	
	if (nil != self.cancelAdapterTimer)
	{
		self.isRequesting = YES;
	}
	// Resume the timer
	if (self.isAutoRefresh && ![self.refreshTimer isValid] && isConrollerVisible)
	{
		[self setupTimer];
	}
}

- (void)deviceOrientationDidChange:(NSNotification *)aNotification
{
	if ([RJUtilities isSmartBanner:self.slot.tagUrl])
	{
		[self loadAd];
	}
}

#pragma mark - RJAdapterDelegate: Targeting

- (NSString *)areaCode
{
	if ([self.slot.delegate respondsToSelector:@selector(areaCode)])
	{
		return [self.slot.delegate areaCode];
	}

	return nil;
}

- (NSString *)city
{
	if ([self.slot.delegate respondsToSelector:@selector(city)])
	{
		return [self.slot.delegate city];
	}

	return nil;
}

- (NSString *)country
{
	if ([self.slot.delegate respondsToSelector:@selector(country)])
	{
		return [self.slot.delegate country];
	}

	return nil;
}

- (BOOL)hasLocation
{
	if ([self.slot.delegate respondsToSelector:@selector(hasLocation)])
	{
		return [self.slot.delegate hasLocation];
	}
	
	return NO;
}

- (double)latitude
{
	if ([self.slot.delegate respondsToSelector:@selector(latitude)])
	{
		return [self.slot.delegate latitude];
	}

	return 0;
}

- (double)longitude
{
	if ([self.slot.delegate respondsToSelector:@selector(longitude)])
	{
		return [self.slot.delegate longitude];
	}

	return 0;
}

- (NSString *)metro
{
	if ([self.slot.delegate respondsToSelector:@selector(metro)])
	{
		return [self.slot.delegate metro];
	}

	return nil;
}

- (NSString *)zip
{
	if ([self.slot.delegate respondsToSelector:@selector(zip)])
	{
		return [self.slot.delegate zip];
	}

	return nil;
}

- (NSString *)region
{
	if ([self.slot.delegate respondsToSelector:@selector(region)])
	{
		return [self.slot.delegate region];
	}

	return nil;
}

- (NSString *)gender
{
	if ([self.slot.delegate respondsToSelector:@selector(gender)])
	{
		return [self.slot.delegate gender];
	}

	return nil;
}

@end
