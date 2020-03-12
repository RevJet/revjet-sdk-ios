//
//  RJInterstitialController.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJInterstitialController.h"

#import "RJGlobal.h"
#import "RJInterstitialControllerDelegate.h"

#import "RJUtilities.h"

static NSString * const kRJAppleDomain = @".apple.com";
static NSString * const kRJGoogleMapsDomain = @"maps.google.com";
static NSString * const kRJTelScheme = @"tel";
static NSString * const kRJMailtoScheme = @"mailto";
static NSString * const kRJSMSScheme = @"sms";

static NSString *const kRJAboutBlankURL = @"about:blank";
static NSString *const kRJDomain = @"revjet.com";

static NSString *const kRJRequestURLCloseInterstitial1 = @"revjet:closeInterstitialAd";
static NSString *const kRJRequestURLCloseInterstitial2 = @"revjet://#close";

@interface RJInterstitialController()

- (void)openURL:(NSURL *)aUrl;
- (void)close;

@end

@implementation RJInterstitialController

@synthesize webView;

- (void)dealloc
{
	RJLog(@"dealloc");

	[self.webView stopLoading];
	self.webView.delegate = nil;
	self.webView = nil;

	self.delegate = nil;
}

- (void)loadAd
{
	// Root view
	CGRect theAppFrame = [RJGlobal boundsOfMainScreen];
	UIView *theContentView = [[UIView alloc] initWithFrame:theAppFrame];
	theContentView.backgroundColor = [UIColor blackColor];
	theContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view = theContentView;

	self.webView = [[UIWebView alloc] initWithFrame:[self preferredwebViewFrame]];
	self.webView.delegate = self;
	self.webView.opaque = NO;
	self.webView.backgroundColor = [UIColor clearColor];
	[RJGlobal disableDraggingForView:self.webView];
	
	[self.webView loadHTMLString:self.HTML baseURL:nil];

	[self.view addSubview:self.webView];
}

#pragma mark -

- (void)didPresentInterstitial
{
	[[self webView] performSelector:@selector(stringByEvaluatingJavaScriptFromString:)
				withObject:@"webviewDidAppear();" afterDelay:0.1f];

	if ([self.delegate respondsToSelector:@selector(didShowInterstitialAd:)]) {
		[self.delegate didShowInterstitialAd:self];
	}
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)anAnimated
{
	[super viewWillAppear:anAnimated];
	
	if (self.showCloseButton)
	{
		UIButton *theCloseButton = [RJUtilities closeButton];
		[self.view addSubview:theCloseButton];
		
		CGRect theBounds = [RJGlobal boundsOfMainScreen];
		theCloseButton.center = CGPointMake(theBounds.size.width - theCloseButton.frame.size.width / 2,
					theCloseButton.frame.size.height / 2);
		[theCloseButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
	}
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	[RJUtilities disableJavaScriptDialogsForWebView:aWebView];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)aRequest
			navigationType:(UIWebViewNavigationType)aNavigationType
{
	NSURL *theRequestURL = [aRequest URL];
	NSString *theHost = [theRequestURL host];

	if ([[theRequestURL absoluteString] isEqualToString:kRJRequestURLCloseInterstitial1] ||
		[[theRequestURL absoluteString] isEqualToString:kRJRequestURLCloseInterstitial2])
	{
		[self close];
		return NO;
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

	NSString *theScheme = [theRequestURL scheme];
	if ([kRJTelScheme isEqualToString:theScheme] || [kRJMailtoScheme isEqualToString:theScheme] ||
				[kRJSMSScheme isEqualToString:theScheme])
	{
		[self openURL:theRequestURL];
		return NO;
	}

	if ([theHost hasSuffix:kRJAppleDomain] || [theHost hasSuffix:kRJGoogleMapsDomain])
	{
		[self openURL:theRequestURL];
		return NO;
	}
  
	BOOL isClicked = ((UIWebViewNavigationTypeOther == aNavigationType) &&
				[[aRequest URL] isEqual:[aRequest mainDocumentURL]]);
	if ((UIWebViewNavigationTypeLinkClicked == aNavigationType) || isClicked)
	{
		[self openURL:theRequestURL];
	}

	return YES;
}

- (void)openURL:(NSURL *)aUrl
{
	[self close];

	if ([self.delegate respondsToSelector:@selector(applicationWillTerminateFromInterstitialController:)])
	{
		[self.delegate applicationWillTerminateFromInterstitialController:self];
	}

	if ([self.delegate shouldOpenURL:aUrl]) {
		[[UIApplication sharedApplication] openURL:aUrl options:@{} completionHandler:nil];
	}
}

- (void)close
{
	[self.webView stopLoading];
	self.webView.delegate = nil;
	
	UIViewController *theViewController = self;
	if ([self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)])
	{
		if (nil != [self.delegate viewControllerForPresentingModalView])
		{
			theViewController = [self.delegate viewControllerForPresentingModalView];
		}
	}
	[theViewController dismissViewControllerAnimated:YES completion:nil];

	if ([self.delegate respondsToSelector:@selector(didDismissInterstitialController:)])
	{
		[self.delegate didDismissInterstitialController:self];
	}
}

@end
