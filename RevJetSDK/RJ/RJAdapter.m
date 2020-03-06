//
//  RJAdapter.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJGlobal.h"
#import "RJAdapter.h"
#import "RJAdapterDelegate.h"
#import "RJPasteboard.h"
#import "RJWebBrowser.h"

#import "RJNetwork.h"

#import "RJStoreProductViewController.h"

#import "RJURL.h"
#import "RJHTMLScanner.h"

#import "RJUtilities.h"

static NSString *const kRJDomain = @"revjet.com";
static NSString *const kRJRevJetDomain = @"revjet.com";
static NSString *const kRJWWWRevJetDomain = @"www.revjet.com";
static NSString *const kRJAppleDomain = @".apple.com";
static NSString *const kRJGoogleMapsDomain = @"maps.google.com";
static NSString *const kRJTelScheme = @"tel";
static NSString *const kRJMailtoScheme = @"mailto";
static NSString *const kRJSMSScheme = @"sms";

static NSString *const kRJBrowserOption = @"revjet_browser";
static NSString *const kRJInternalBrowser = @"int";
static NSString *const kRJExternalBrowser = @"ext";
static NSString *const kRJiTunesBrowserTypeOption = @"itunes_browser";
static NSString *const kRJiTunesBrowserTypeExternal = @"ext";

static NSString *const kRJAboutBlankURL = @"about:blank";

static NSTimeInterval const kRJStoreProductWaitingTime = 300.0f;
static NSString *const kRJRequestURLTimerUserInfoKey = @"RequestURL";
static NSString *const kRJArgumentsTimerUserInfoKey = @"Arguments";

static NSString *const kRJRequestURLClose = @"revjet://#close";

@interface RJAdapter () <SKStoreProductViewControllerDelegate>

@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, strong) NSString *browserType;
@property (nonatomic, strong) NSString *iTunesBrowserType;

- (void)addReferrerToPasteboardFromURL:(NSDictionary *)args;
- (NSDictionary *)dictionaryWithQueryArguments:(NSString *)query;
- (void)showiTunesModalViewForID:(NSInteger)aniTunesID requestURL:(NSURL *)aRequestURL
			arguments:(NSDictionary *)anArguments;

@property (nonatomic, strong) RJStoreProductViewController *storeProductViewController;
@property (nonatomic, strong) NSTimer *storeProductTimer;

@property (nonatomic, strong) UIWebView *loadingAd;
@property (nonatomic, strong) RJWebBrowser *webBrowser;

@end

@interface RJNetwork (PrivateMethodsOfRJNetwork)

@property (assign) BOOL isAdapterBusy;

@end

@implementation RJAdapter

@synthesize isLoaded = isLoaded_,
			browserType = browserType_, iTunesBrowserType, storeProductViewController, storeProductTimer, loadingAd;

- (id)initWithDelegate:(id<RJAdapterDelegate>)aDelegate
{
	RJLog(@"initWithDelegate:");
	
	self = [super initWithDelegate:aDelegate];
	if (nil != self)
	{
		self.isLoaded = NO;
		
		CGRect theFrame = CGRectZero;
		theFrame.size = [RJUtilities supportedSizeForSize:[self.delegate slotViewFrame].size];

		self.loadingAd = [[UIWebView alloc] initWithFrame:theFrame];
		self.loadingAd.backgroundColor = [UIColor clearColor];
		self.loadingAd.opaque = NO;
		self.loadingAd.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		if ([self.loadingAd respondsToSelector:@selector(setAllowsInlineMediaPlayback:)])
		{
			[self.loadingAd setAllowsInlineMediaPlayback:YES];
		}
		
		if ([self.loadingAd respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)])
		{
			[self.loadingAd setMediaPlaybackRequiresUserAction:NO];
		}
		
		[RJGlobal disableScrollingAndDraggingForView:self.loadingAd];
		
		self.loadingAd.delegate = self;
		self.browserType = kRJExternalBrowser;
  }

  return self;
}

- (void)dealloc
{
	RJLog(@"dealloc");
	[self.loadingAd stopLoading];
	self.loadingAd.delegate = nil;
	self.webBrowser.delegate = nil;
}

#pragma makr - Actions

- (void)closeBanner:(UIButton *)aButton
{
	self.loadingAd.hidden = YES;
	[self.delegate adapter:self didCloseAd:self.loadingAd];
}

#pragma mark -

- (void)getAd
{
	[super getAd];
	
	if (self.showCloseButton)
	{
		UIButton *theCloseButton = [RJUtilities closeButton];
		[self.loadingAd addSubview:theCloseButton];
		theCloseButton.center = CGPointMake(self.loadingAd.frame.size.width - theCloseButton.frame.size.width / 2,
					theCloseButton.frame.size.height / 2);
		[theCloseButton addTarget:self action:@selector(closeBanner:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	[self.loadingAd loadHTMLString:self.params[@"HTML"] baseURL:nil];
}

- (void)didShowAd
{
	[self.loadingAd performSelector:@selector(stringByEvaluatingJavaScriptFromString:)
				withObject:@"webviewDidAppear();" afterDelay:0.1f];
}

#pragma mark -

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	[RJUtilities disableJavaScriptDialogsForWebView:aWebView];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	RJLog(@"webViewDidFinishLoad");
	
	if (self.isLoaded)
	{
		return;
	}
	
	self.isLoaded = YES;
	[self.delegate adapter:self didReceiveAd:aWebView];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)anError
{
	RJLog(@"webView:didFailLoadWithError:");
	
	if (!self.isLoaded)
	{
		[self.delegate adapter:self didFailToReceiveAd:aWebView error:anError];
	}
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)aRequest
			navigationType:(UIWebViewNavigationType)aNavigationType
{
	RJLog(@"webView:shouldStartLoadWithRequest:navigationType:");
	RJLog(@"URL: %@", [aRequest URL]);
	
	NSURL *theRequestURL = [aRequest URL];
	NSString *theHost = [theRequestURL host];
	
	if ([[theRequestURL absoluteString] isEqualToString:kRJRequestURLClose])
	{
		[self closeBanner:nil];
		return NO;
	}
	
	NSDictionary *theArguments = [self dictionaryWithQueryArguments:[theRequestURL query]];

	NSString *theBrowserOptions = theArguments[kRJBrowserOption];
	if ([theBrowserOptions isEqualToString:kRJInternalBrowser])
	{
		self.browserType = kRJInternalBrowser;
		RJLog(@"Browser = %@", self.browserType);
	}
	
	NSString *theiTunesBrowserType = theArguments[kRJiTunesBrowserTypeOption];
	if ([theiTunesBrowserType isEqualToString:kRJiTunesBrowserTypeExternal])
	{
		self.iTunesBrowserType = kRJiTunesBrowserTypeExternal;
		RJLog(@"iTunes browser = %@", self.iTunesBrowserType);
	}
  
	if ([theHost hasSuffix:kRJDomain])
	{
		return YES;
	}
	
	NSString *theURLString = [theRequestURL absoluteString];
	if ((nil == theURLString) || [theURLString isEqualToString:kRJAboutBlankURL])
	{
		return YES;
	}

	NSString *theURLScheme = [theRequestURL scheme];
	if ([kRJTelScheme isEqualToString:theURLScheme] ||
				[kRJMailtoScheme isEqualToString:theURLScheme] ||
				[kRJSMSScheme isEqualToString:theURLScheme])
	{
		if ([self.delegate adapter:self shouldOpenURL:theRequestURL]) {
			[self.delegate trackClickForAdapter:self];
			[self.delegate adapter:self applicationWillTerminateFromAd:aWebView];
			[[UIApplication sharedApplication] openURL:theRequestURL options:@{} completionHandler:nil];
		}

		return NO;
	}

	if ([theHost hasSuffix:kRJAppleDomain] || [theHost hasSuffix:kRJGoogleMapsDomain])
	{
		[self.delegate trackClickForAdapter:self];
		NSInteger theiTunesID = [RJUtilities iTunesIDForRequestURL:theRequestURL];
		if ([self.iTunesBrowserType isEqualToString:kRJiTunesBrowserTypeExternal]
					|| (0 == theiTunesID))
		{
			if ([self.delegate adapter:self shouldOpenURL:theRequestURL]) {
				[self addReferrerToPasteboardFromURL:theArguments];
				[self.delegate adapter:self applicationWillTerminateFromAd:aWebView];
				[[UIApplication sharedApplication] openURL:theRequestURL options:@{} completionHandler:nil];
			}
		}
		else
		{
			if (nil == self.storeProductViewController)
			{
				[self showiTunesModalViewForID:theiTunesID requestURL:theRequestURL arguments:theArguments];
			}
			else
			{
				// assume that store product view controller is going to be shown modally.
				return NO;
			}
		}
		return NO;
	}
	
	BOOL isClicked = ((UIWebViewNavigationTypeOther == aNavigationType) &&
				([theHost isEqualToString:kRJRevJetDomain] ||
				[theHost isEqualToString:kRJWWWRevJetDomain] ||
				[[aRequest URL] isEqual:[aRequest mainDocumentURL]]));
			
	if ((aNavigationType == UIWebViewNavigationTypeLinkClicked) || isClicked)
	{
		[self.delegate trackClickForAdapter:self];
		[self addReferrerToPasteboardFromURL:theArguments];
		
		if ([self.browserType isEqualToString:kRJExternalBrowser])
		{
			if ([self.delegate adapter:self shouldOpenURL:theRequestURL]) {
				[self.delegate adapter:self applicationWillTerminateFromAd:aWebView];
				[[UIApplication sharedApplication] openURL:theRequestURL options:@{} completionHandler:nil];
			}
		}
		else
		{
			if ([self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)])
			{
				UIViewController *theViewController = [self.delegate viewControllerForPresentingModalView];
				if (nil != theViewController)
				{
					[self.delegate adapter:self willPresentModalViewFromAd:aWebView];

					self.webBrowser = [RJWebBrowser RJWebBrowserWithDelegate:self URL:theRequestURL];
					[[self.delegate viewControllerForPresentingModalView]
								presentViewController:self.webBrowser animated:YES completion:nil];
				}
				else if ([self.delegate adapter:self shouldOpenURL:theRequestURL]) {
					[self.delegate adapter:self applicationWillTerminateFromAd:aWebView];
					[[UIApplication sharedApplication] openURL:theRequestURL options:@{} completionHandler:nil];
				}
			}
		}

		return NO;
	}

	return YES;
}

#pragma mark - RJWebBrowserDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	if ([self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)])
	{
		return [self.delegate viewControllerForPresentingModalView];
	}
	return nil;
}

- (BOOL)shouldOpenURL:(NSURL*)url
{
	return [self.delegate adapter:self shouldOpenURL:url];
}

- (void)didDismissWebBrowser:(RJWebBrowser *)aWebBrowser
{
	[self.delegate adapter:self didDismissModalViewFromAd:self.loadingAd];
}

- (void)applicationWillTerminateFromWebBrowser:(RJWebBrowser *)aWebBrowser
{
	[self.delegate adapter:self applicationWillTerminateFromAd:self.loadingAd];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)aViewController
{
	RJStoreProductViewController *theStoreProductViewController = (RJStoreProductViewController *)aViewController;
	[aViewController dismissViewControllerAnimated:YES completion:nil];
	[self.delegate adapter:theStoreProductViewController.adapter didDismissModalViewFromAd:self.loadingAd];
	self.storeProductViewController = nil;
}

#pragma mark - Private

- (void)storeProductTimerDidEnd:(NSTimer *)aTimer
{
	[self.storeProductViewController dismissViewControllerAnimated:NO completion:nil];
	self.storeProductViewController = nil;
	
	NSDictionary *theUserInfo = [aTimer userInfo];
	NSURL *theRequestURL = theUserInfo[kRJRequestURLTimerUserInfoKey];
	NSDictionary *theArguments = theUserInfo[kRJArgumentsTimerUserInfoKey];
	[(RJNetwork *)self.delegate setIsAdapterBusy:NO];

	if ([self.delegate adapter:self shouldOpenURL:theRequestURL]) {
		[self addReferrerToPasteboardFromURL:theArguments];
		[self.delegate adapter:self applicationWillTerminateFromAd:self.loadingAd];
		[[UIApplication sharedApplication] openURL:theRequestURL options:@{} completionHandler:nil];
	}
}

- (void)addReferrerToPasteboardFromURL:(NSDictionary *)anArguments
{
	NSString *theReferrer = anArguments[@"referrer"];
	NSString *theCappID = anArguments[@"cappid"];
	
	if (([theCappID length] > 0) && ([theReferrer length] > 0))
	{
		RJLog(@"adding referrer = %@; cappid = %@", theReferrer, theCappID);
		[RJPasteboard setObject:theReferrer forKey:theCappID];
	}
}

- (NSDictionary *)dictionaryWithQueryArguments:(NSString *)aQuery
{
	NSMutableDictionary *theResultDictionary = [NSMutableDictionary dictionaryWithCapacity:6];
	NSArray *thePairs = [aQuery componentsSeparatedByString:@"&"];

	for (NSString *thePair in thePairs)
	{
		NSArray *theElements = [thePair componentsSeparatedByString:@"="];
		NSString *theKey = nil;
		NSString *theValue = nil;
		
		if ([theElements count] > 1)
		{
			theKey = [theElements[0] stringByRemovingPercentEncoding];
			theValue = [theElements[1] stringByRemovingPercentEncoding];
		}
		
		if ([theKey length] <= 0)
		{
			continue;
		}
		theResultDictionary[theKey] = theValue;
	}

	return theResultDictionary;
}

- (void)showiTunesModalViewForID:(NSInteger)aniTunesID requestURL:(NSURL *)aRequestURL
			arguments:(NSDictionary *)anArguments
{
	if ([self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)])
	{
		UIViewController *theViewController = [self.delegate viewControllerForPresentingModalView];
		if (nil != theViewController)
		{
			self.storeProductViewController = [[RJStoreProductViewController alloc] init];
			self.storeProductViewController.delegate = self;
			self.storeProductViewController.adapter = self;
			NSDictionary *theParameters = @{SKStoreProductParameterITunesItemIdentifier: @(aniTunesID)};
			[(RJNetwork *)self.delegate setIsAdapterBusy:YES];
			
			self.storeProductTimer = [NSTimer scheduledTimerWithTimeInterval:kRJStoreProductWaitingTime
					target:self selector:@selector(storeProductTimerDidEnd:)
					userInfo:@{kRJRequestURLTimerUserInfoKey: aRequestURL, kRJArgumentsTimerUserInfoKey: anArguments}
					repeats:NO];

			[self.delegate adapter:self willPresentModalViewFromAd:self.loadingAd];
			[theViewController presentViewController:self.storeProductViewController
						animated:YES completion:
						^{
							[(RJNetwork *)self.delegate setIsAdapterBusy:NO];
						}];
			[self.storeProductViewController loadProductWithParameters:theParameters completionBlock:
			^(BOOL aResult, NSError *anError)
			{
				[self.storeProductTimer invalidate];
				self.storeProductTimer = nil;
				
				if (!aResult)
				{
					if ([self.delegate adapter:self shouldOpenURL:aRequestURL]) {
						[self addReferrerToPasteboardFromURL:anArguments];
						[self.delegate adapter:self applicationWillTerminateFromAd:self.loadingAd];
						[[UIApplication sharedApplication] openURL:aRequestURL options:@{} completionHandler:nil];
					}

					self.storeProductViewController = nil;
				}
		  }];
		}
		else if ([self.delegate adapter:self shouldOpenURL:aRequestURL]) {
			[self addReferrerToPasteboardFromURL:anArguments];
			[self.delegate adapter:self applicationWillTerminateFromAd:self.loadingAd];
			[[UIApplication sharedApplication] openURL:aRequestURL options:@{} completionHandler:nil];
		}
	}
}

@end
