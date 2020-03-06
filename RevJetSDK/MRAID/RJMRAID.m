//
//  RJMRAID.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAID.h"

#import "RJGlobal.h"
#import "RJMRAIDView.h"
#import "RJMRAIDViewDelegate.h"
#import "RJNetwork.h"

#import "RJMRAIDScript.h"

#import "RJMRAIDNativeEvent.h"
#import "RJMRAIDNativeEventFactory.h"

#import "RJUtilities.h"

#import <objc/message.h>

#import <EventKit/EventKit.h>

static NSString *const kRJDomain = @"revjet.com";
static NSString *const kRJAppleDomain = @".apple.com";
static NSString *const kRJGoogleMapsDomain = @"maps.google.com";
static NSString *const kRJMRAIDScheme = @"mraid";
static NSString *const kRJiOSLogScheme = @"ios-log";
static NSString *const kRJTelScheme = @"tel";
static NSString *const kRJMailtoScheme = @"mailto";
static NSString *const kRJSMSScheme = @"sms";

static NSString *const kRJHtmlTag = @"<html>";
static NSString *const kRJHeadTag = @"<head>";
static NSString *const kRJBodyTag = @"<body>";

static NSString *const kRJStateDefault = @"default";
static NSString *const kRJStateExpanded = @"expanded";
static NSString *const kRJStateHidden = @"hidden";

static NSString *const kRJMRAIDValueTrue = @"true";
static NSString *const kRJMRAIDValueFalse = @"false";

static NSString *const kRJAboutBlankURL = @"about:blank";

typedef enum
{
	kRJMRAIDViewStateDefault,
	kRJMRAIDViewStateExpanded,
	kRJMRAIDViewStateHidden
} RJMRAIDVIewState;

@interface RJMRAID () <RJMRAIDNativeEventDelegate>

@property (nonatomic, assign) RJMRAIDVIewState viewState;
@property (nonatomic, strong) RJMRAIDNativeEvent *currentNativeEvent;

@end

@implementation RJMRAID
{
@private
  BOOL loaded_;
  BOOL expandedLoaded_;
  BOOL useCustomClose_;
  BOOL loading_;
}

@synthesize useCustomClose = useCustomClose_;
@synthesize mraidView, viewState, currentNativeEvent;

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		loaded_ = NO;
		useCustomClose_ = NO;
		loading_ = NO;
		self.viewState = kRJMRAIDViewStateDefault;
	}
	return self;
}

- (id)initWithView:(RJMRAIDView *)aView
{
	self = [self init];
	if (nil != self)
	{
		self.mraidView = aView;
	}
	return self;
}

- (void)dealloc
{
	RJLog(@"dealloc");
	self.mraidView = nil;
	self.currentNativeEvent.delegate = nil;
	self.currentNativeEvent = nil;
}

- (NSString *)prepareHTML:(NSString *)aHTML
{
  NSString *theResult = aHTML;

	// Add HTML tags is necessary
	BOOL hasHTMLTag = (NSNotFound != [aHTML rangeOfString:kRJHtmlTag options:NSCaseInsensitiveSearch].location);
	if (!hasHTMLTag)
	{
		BOOL hasHeadTag = (NSNotFound != [aHTML rangeOfString:kRJHeadTag options:NSCaseInsensitiveSearch].location);
		if (!hasHeadTag)
		{
			BOOL hasBodyTag = (NSNotFound != [aHTML rangeOfString:kRJBodyTag options:NSCaseInsensitiveSearch].location);
			if (!hasBodyTag)
			{
				theResult = [self convertToHTML:aHTML];
			}
		}
	}
	
	// Insert MRAID script
	return [self insertMRAIDScriptTo:theResult];
}

- (BOOL)isExpandedWebView
{
	return (kRJMRAIDViewStateExpanded == self.viewState);
}

- (void)expandedState
{
	RJLog(@"expandedState");
	self.viewState = kRJMRAIDViewStateExpanded;
	[self fireChangeEventForCurrentState];
}

- (void)defaultState
{
	RJLog(@"defaultState");
	self.viewState = kRJMRAIDViewStateDefault;
	[self fireChangeEventForCurrentState];
}

- (void)hiddenState
{
	RJLog(@"hiddenState");
	self.viewState = kRJMRAIDViewStateHidden;
	[self fireChangeEventForCurrentState];
}

- (void)setViewable:(BOOL)aFlag
{
	[self fireChangeEvent:[NSString stringWithFormat:@"viewable: '%@'",
				aFlag ? kRJMRAIDValueTrue : kRJMRAIDValueFalse]];
}

- (void)closeButtonTouched
{
	RJLog(@"closeButtonTouched");

	if (kRJMRAIDPlacementTypeInterstitial == self.mraidView.placementType)
	{
		[self.mraidView.delegate didClose];
	}
	else
	{
		[self.mraidView closeExpandedView];
	}
}

- (void)reportError:(NSString *)aMessage action:(NSString *)anAction
{
	RJLog(@"reportError:action:");

	[self.mraidView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:
				@"window.mraidbridge.fireErrorEvent(\"%@\", \"%@\");", aMessage, anAction]];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)aRequest
			navigationType:(UIWebViewNavigationType)aNavigationType
{
	RJLog(@"webView:shouldStartLoadWithRequest:navigationType:");
	
	NSURL *theRequestURL = [aRequest URL];
	RJLog(@"URL: %@", theRequestURL);
	
	NSString *theURLString = [theRequestURL absoluteString];

	NSString *theScheme = [theRequestURL scheme];

	if ([kRJMRAIDScheme isEqualToString:theScheme])
	{
		[self callNativeMethod:theRequestURL];
		return NO;
	}
	
	if ([kRJiOSLogScheme isEqualToString:theScheme])
	{
		theURLString = [theURLString stringByReplacingOccurrencesOfString:@"%20" withString:@" "
					options:NSLiteralSearch range:NSMakeRange(0, [theURLString length])];
		RJLog(@"Web console: %@", theURLString);
		return NO;
	}

	if ([kRJTelScheme isEqualToString:theScheme] || [kRJMailtoScheme isEqualToString:theScheme] ||
				[kRJSMSScheme isEqualToString:theScheme])
	{
		[self.mraidView.delegate applicationWillTerminateFromAd:self.mraidView];
		if ([self.mraidView.delegate shouldOpenURL:theRequestURL]) {
			[[UIApplication sharedApplication] openURL:theRequestURL options:@{} completionHandler:nil];
		}
		return NO;
	}

	NSString *theHost = [theRequestURL host];
	if ([theHost hasSuffix:kRJAppleDomain] || [theHost hasSuffix:kRJGoogleMapsDomain])
	{
		[self.mraidView.delegate applicationWillTerminateFromAd:self.mraidView];
		if ([self.mraidView.delegate shouldOpenURL:theRequestURL]) {
			[[UIApplication sharedApplication] openURL:theRequestURL options:@{} completionHandler:nil];
		}
		return NO;
	}

	if ([theHost hasSuffix:kRJDomain])
	{
		return YES;
	}
  
	if ((nil == theURLString) || [theURLString isEqualToString:kRJAboutBlankURL])
	{
		return YES;
	}
	
	BOOL isClicked = ((UIWebViewNavigationTypeOther == aNavigationType) &&
				[theRequestURL isEqual:[aRequest mainDocumentURL]]);
	if ((aNavigationType == UIWebViewNavigationTypeLinkClicked) || isClicked)
	{
		[self.mraidView.delegate applicationWillTerminateFromAd:self.mraidView];
		if ([self.mraidView.delegate shouldOpenURL:theRequestURL]) {
			[[UIApplication sharedApplication] openURL:theRequestURL options:@{} completionHandler:nil];
		}
		return NO;
	}

  return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	RJLog(@"webViewDidStartLoad:");
	[RJUtilities disableJavaScriptDialogsForWebView:aWebView];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	RJLog(@"webViewDidFinishLoad:");

	// Load finished in a seperate UIWebView?
	if (kRJExpandedWebViewTag == aWebView.tag)
	{
		if (expandedLoaded_)
		{
			return;
		}

		expandedLoaded_ = YES;
	}
	else
	{
		if (loaded_)
		{
			return;
		}

		loaded_ = YES;

		if (kRJMRAIDPlacementTypeInline != self.mraidView.placementType)
		{
			if (!useCustomClose_)
			{
				[self.mraidView showCloseButton];
			}
		}
		
		[self notifyDelegateDidFinishLoad];
	}

	[self initializeView];
	[self ready];
}

- (void)notifyDelegateDidFinishLoad
{
	if ([self.mraidView.delegate respondsToSelector:@selector(didReceiveAd:)])
	{
		[self.mraidView.delegate didReceiveAd:self.mraidView];
	}
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)anError
{
  RJLog(@"webView:didFailLoadWithError");

	if (kRJExpandedWebViewTag == aWebView.tag)
	{
		expandedLoaded_ = YES;
	}
	else
	{
		if (loaded_)
		{
			return;
		}

		loaded_ = YES;
		if ([self.mraidView.delegate respondsToSelector:@selector(didFailToReceiveAd:withError:)])
		{
			[self.mraidView.delegate didFailToReceiveAd:self.mraidView withError:anError];
		}
	}
}

#pragma mark - RJMRAIDNativeEventDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	return [self.mraidView.delegate viewControllerForPresentingModalView];
}

- (BOOL)shouldOpenURL:(NSURL*)url
{
	return [self.mraidView.delegate shouldOpenURL:url];
}

- (RJMRAIDView *)MRAIDView
{
	return self.mraidView;
}

- (void)nativeEventWillPresentModalView:(RJMRAIDNativeEvent *)anEvent
{
	if ([self.mraidView.delegate respondsToSelector:@selector(willOpenInternalBrowser)])
	{
		[self.mraidView.delegate willOpenInternalBrowser];
	}
}

- (void)nativeEventDidDismissModalView:(RJMRAIDNativeEvent *)anEvent
{
	if ([self.mraidView.delegate respondsToSelector:@selector(didCloseInternalBrowser)])
	{
		[self.mraidView.delegate didCloseInternalBrowser];
	}
}

- (void)nativeEvent:(RJMRAIDNativeEvent *)anEvent didFailExecute:(NSError *)anError
{
	[self reportError:[anError localizedDescription] action:anEvent.eventName];
}

- (void)nativeEvent:(RJMRAIDNativeEvent *)anEvent willUseCutomCloseButton:(BOOL)aFlag
{
	useCustomClose_ = aFlag;
}

- (BOOL)useCustomCloseButton
{
	return useCustomClose_;
}

- (void)nativeEventWillRequestAccess:(RJMRAIDNativeEvent *)anEvent
{
	if ([self.mraidView.delegate respondsToSelector:@selector(willRequestAccess)])
	{
		[self.mraidView.delegate willRequestAccess];
	}
}

- (void)nativeEventDidRequestAccess:(RJMRAIDNativeEvent *)anEvent
{
	if ([self.mraidView.delegate respondsToSelector:@selector(didRequestAccess)])
	{
		[self.mraidView.delegate didRequestAccess];
	}
}

#pragma mark - Private

- (NSString *)insertMRAIDScriptTo:(NSString *)anAD
{
	NSRange theRangeOfHeadTag = [anAD rangeOfString:kRJHeadTag options:NSCaseInsensitiveSearch];
	NSRange theRangeOfBodyTag = [anAD rangeOfString:kRJBodyTag options:NSCaseInsensitiveSearch];

	NSUInteger theInsertLocation = 0;

	if (NSNotFound != theRangeOfHeadTag.location)
	{
		theInsertLocation = theRangeOfHeadTag.location + [kRJHeadTag length];
	}
	else if (NSNotFound != theRangeOfBodyTag.location)
	{
		theInsertLocation = theRangeOfBodyTag.location + [kRJBodyTag length];
	}
	else
	{
		return anAD;
	}

	NSMutableString *theResult = [anAD mutableCopy];
  
	[theResult insertString: [NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>",
														kRJMRAIDScript] atIndex:theInsertLocation];

	return theResult;
}

- (NSString *)convertToHTML:(NSString *)anAD
{
	return [NSString stringWithFormat:@"<html><head>"
				@"<meta name=\"viewport\" content=\"initial-scale=1.0; user-scalable=no\"/>"
				@"</head><body style=\"background-color: transparent; margin: 0; padding: 0; overflow: hidden;\">"
				@"%@</body></html>", anAD];
}

- (void)callNativeMethod:(NSURL *)aURL
{
	NSString *theViewableString = [self.mraidView
				stringByEvaluatingJavaScriptFromString:@"window.mraid.isViewable()"];
	if ([kRJMRAIDValueFalse isEqualToString:theViewableString] &&
				(kRJMRAIDPlacementTypeInterstitial == self.mraidView.placementType))
	{
		[self reportError:@"Interstitial is not present on the screen" action:[aURL host]];
		return;
	}
	RJLog(@"callNativeMethod: %@", [aURL absoluteString]);
	
	NSDictionary *theParameters = [self parametersFromURL:aURL];
	NSString *theEventName = [aURL host];
	if (nil != theEventName)
	{
		self.currentNativeEvent = [RJMRAIDNativeEventFactory eventWithName:theEventName delegate:self];
		if (nil != self.currentNativeEvent)
		{
			[self.currentNativeEvent executeEventWithParameters:theParameters];
			[self fireNativeCallComplete:theEventName];
		}
		else
		{
			[self reportError:@"Native method not found" action:theEventName];
		}
	}
}

- (NSDictionary *)parametersFromURL:(NSURL *)aURL
{
	NSMutableDictionary *theParameters = [NSMutableDictionary dictionaryWithCapacity:4];
	NSArray *thePairs = [[aURL query] componentsSeparatedByString:@"&"];

	for (NSString *thePair in thePairs)
	{
		NSArray *theElements = [thePair componentsSeparatedByString:@"="];
		if ([theElements count] > 1)
		{
			NSString *theKey = [theElements[0] stringByRemovingPercentEncoding];
			NSString *theValue = [theElements[1] stringByRemovingPercentEncoding];
			if ([theKey length] > 0)
			{
				theParameters[theKey] = theValue;
			}
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:theParameters];
}

- (void)ready
{
	RJLog(@"ready");
	[self.mraidView stringByEvaluatingJavaScriptFromString:@"window.mraidbridge.fireReadyEvent();"];
}

- (void)initializeView
{
	RJLog(@"initializeView");
	NSString *theInitializeEvent = [NSString stringWithFormat:@"%@, %@, %@, %@", [self placementType],
				[self currentViewState], [self screenSize], [self supportedFeatures]];
	[self fireChangeEvent:theInitializeEvent];
}

- (BOOL)expanded
{
	return kRJMRAIDViewStateExpanded == self.viewState;
}

- (void)notifyScreenSizeChanged
{
	[self fireChangeEvent:[self screenSize]];
}

#pragma mark -

- (NSString *)placementType
{
	return [NSString stringWithFormat:@"placementType: '%@'",
				(self.mraidView.placementType == kRJMRAIDPlacementTypeInline ? @"inline" : @"interstitial")];
}

- (NSString *)currentViewState
{
	static NSDictionary *sStatesMap = nil;
	static dispatch_once_t sStatesMapDispatch = 0;
	dispatch_once(&sStatesMapDispatch, ^
	{
		sStatesMap = @{
		        @(kRJMRAIDViewStateDefault): kRJStateDefault,
                @(kRJMRAIDViewStateExpanded): kRJStateExpanded,
                @(kRJMRAIDViewStateHidden): kRJStateHidden
		};
	});

	NSString *theState = sStatesMap[@(self.viewState)];
	if (nil == theState)
	{
		theState = kRJStateDefault;
	}

	return [NSString stringWithFormat:@"state: '%@'", theState];
}

- (NSString *)screenSize
{
	CGSize theScreenSize = [RJGlobal boundsOfMainScreen].size;
	return [NSString stringWithFormat:@"screenSize: {width: %f, height: %f}",
				theScreenSize.width, theScreenSize.height];
}

- (NSString *)supportedFeatures
{
	BOOL checkSMSSupported = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]];
	BOOL checkTELSupported = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
	BOOL checkCalendarSupported = YES;

	#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
		if ([EKEventStore respondsToSelector:@selector(authorizationStatusForEntityType:)])
		{
			checkCalendarSupported = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] ==
						EKAuthorizationStatusNotDetermined ||
						[EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized;
		}
	#endif
	BOOL checkStorePictureSupported = YES;
	BOOL checkInlineVideoSupported = YES;
	
	return [NSString stringWithFormat:@"supports: {sms: %@, tel: %@, calendar: %@, storePicture: %@, inlineVideo: %@}",
				[self jsonValueForBool:checkSMSSupported], [self jsonValueForBool:checkTELSupported],
				[self jsonValueForBool:checkCalendarSupported], [self jsonValueForBool:checkStorePictureSupported],
				[self jsonValueForBool:checkInlineVideoSupported]];
}

- (NSString *)jsonValueForBool:(BOOL)aFlag
{
	return aFlag ? kRJMRAIDValueTrue : kRJMRAIDValueFalse;
}

- (void)fireChangeEventForCurrentState
{
	[self fireChangeEvent:[self currentViewState]];
}

- (void)fireNativeCallComplete:(NSString *)aCommand
{
	if (nil != aCommand)
	{
		[self.mraidView stringByEvaluatingJavaScriptFromString:
					[NSString stringWithFormat:@"window.mraidbridge.nativeCallComplete('%@');", aCommand]];
	}
}

- (void)fireChangeEvent:(NSString *)anEvent
{
	if (nil != anEvent)
	{
		NSString *theScript = [NSString stringWithFormat:@"window.mraidbridge.fireChangeEvent({%@});", anEvent];
		[self.mraidView stringByEvaluatingJavaScriptFromString:theScript];
	}
}

@end
