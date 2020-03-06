//
//  RJWebBrowser.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJWebBrowser.h"

#import "RJGlobal.h"
#import "RJWebBrowserDelegate.h"

#import "RJUtilities.h"
#import "RJStoreProductViewController.h"

#import "RJStatusBarVisibility.h"

static NSString * const kRJAppleDomain = @".apple.com";
static NSString * const kRJGoogleMapsDomain = @"maps.google.com";

@interface RJWebBrowser () <SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) RJStatusBarVisibility *statusBarVisibility;
@property (nonatomic, assign) BOOL shouldNotifyClose;

@end

@implementation RJWebBrowser

@synthesize delegate = delegate_;
@synthesize webView = webView_;
@synthesize toolbar = toolbar_;
@synthesize backButton = backButton_;
@synthesize forwardButton = forwardButton_, statusBarVisibility;

- (id)initWithDelegate:(id<RJWebBrowserDelegate>)delegate URL:(NSURL *)url {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    url_ = url;
    delegate_ = delegate;
	 self.statusBarVisibility = [[RJStatusBarVisibility alloc] init];
	 self.shouldNotifyClose = YES;
  }
  return self;
}

+ (RJWebBrowser *)RJWebBrowserWithDelegate:(id <RJWebBrowserDelegate>)delegate
                                       URL:(NSURL *)url {
  return [[RJWebBrowser alloc] initWithDelegate:delegate URL:url];
}

- (void)dealloc {
  RJLog(@"dealloc");

  delegate_ = nil;

  [webView_ stopLoading];
  self.webView.delegate = nil;
  webView_ = nil;

}

// iOS 7
- (BOOL)prefersStatusBarHidden
{
	return [self.statusBarVisibility shouldHideStatusBar];
}

#pragma mark - View lifecycle

- (void)loadView {
  RJLog(@"loadView");

  CGRect bounds = [RJGlobal boundsOfMainScreen];

  // Root view
  UIView *contentView = [[UIView alloc] initWithFrame:bounds];
  contentView.backgroundColor = [UIColor whiteColor];
  contentView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.view = contentView;

  // Setup toolbar
  self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
  self.toolbar.barStyle = UIBarStyleBlack;
  self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleTopMargin;

  CGSize size = [self.toolbar sizeThatFits:bounds.size];
  self.toolbar.frame = CGRectMake(0, bounds.size.height - size.height,
                                  size.width, size.height);

  [self.view addSubview:self.toolbar];

  // Toolbar buttons
  self.backButton =
  [[UIBarButtonItem alloc] initWithTitle:@"<"
                                    style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(back)];
  self.backButton.enabled = NO;

  self.forwardButton =
  [[UIBarButtonItem alloc] initWithTitle:@">"
                                    style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(forward)];
  self.forwardButton.enabled = NO;

  UIBarButtonItem *closeButton =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                 target:self
                                                 action:@selector(close)];
  closeButton.style = UIBarButtonItemStylePlain;

  UIBarButtonItem *flexibleSpace =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                 target:self action:nil];

  [self.toolbar setItems:@[self.backButton, self.forwardButton, flexibleSpace, closeButton]
                animated:NO];

  // Setup web view
  self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
  self.webView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.webView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height - size.height);
  self.webView.delegate = self;
  [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)anAnimated
{
	[super viewWillAppear:anAnimated];
	
	[self.statusBarVisibility hideStatusBar];
}

- (void)viewWillDisappear:(BOOL)anAnimated
{
	[super viewWillDisappear:anAnimated];
	[self.statusBarVisibility showStatusBar];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	  NSURLRequest *request =
  [NSURLRequest requestWithURL:url_
                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
               timeoutInterval:30];
  [self.webView loadRequest:request];
}

- (void)viewDidUnload {
  RJLog(@"viewDidUnload");

  [super viewDidUnload];
  self.webView.delegate = nil;
  self.webView = nil;
  self.backButton = nil;
  self.forwardButton = nil;
  self.toolbar = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
	RJLog(@"viewDidDisappear:");

	[super viewDidDisappear:animated];
	
	if (self.shouldNotifyClose)
	{
		if ([self.delegate respondsToSelector:@selector(didDismissWebBrowser:)])
		{
			[self.delegate didDismissWebBrowser:self];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
  self.toolbar.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  RJLog(@"didRotateFromInterfaceOrientation:");

  CGRect bounds = self.view.bounds;
  CGSize size = [self.toolbar sizeThatFits:bounds.size];
  self.toolbar.frame = CGRectMake(0, bounds.size.height - size.height,
                                  size.width, size.height);

  self.webView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height - size.height);
  self.toolbar.hidden = NO;  
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
  self.backButton.enabled = self.webView.canGoBack;
  self.forwardButton.enabled = self.webView.canGoForward;

  NSURL *url = [request URL];
  NSString *host = [url host];

  if ([host hasSuffix:kRJAppleDomain] ||
      [host hasSuffix:kRJGoogleMapsDomain]) {
	 
	 NSInteger theItunesId = [RJUtilities iTunesIDForRequestURL:url];
	 if (0 == theItunesId)
	 {
		 [self close];
		 if ([self.delegate respondsToSelector:@selector(applicationWillTerminateFromWebBrowser:)]) {
			[self.delegate applicationWillTerminateFromWebBrowser:self];
		 }

		 if ([self.delegate shouldOpenURL:url]) {
             [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
		 }
	 }
	 else
	 {
		[self showiTunesModalViewForID:theItunesId requestURL:url arguments:nil];
	 }
	 
    return NO;
  }

  return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  RJLog(@"webViewDidFinishLoad:");

  self.backButton.enabled = self.webView.canGoBack;
  self.forwardButton.enabled = self.webView.canGoForward;
}

#pragma mark - Private methods

- (void)back
{
	[self.webView goBack];
}

- (void)forward
{
	[self.webView goForward];
}

- (void)close
{
	[self.webView stopLoading];
	UIViewController *theViewController = self;
	if ([self.delegate respondsToSelector:@selector(viewControllerForPresentingModalView)])
	{
		theViewController = [self.delegate viewControllerForPresentingModalView];
	}
	[theViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showiTunesModalViewForID:(NSInteger)aniTunesID requestURL:(NSURL *)aRequestURL
			arguments:(NSDictionary *)anArguments
{
	self.shouldNotifyClose = NO;
	RJStoreProductViewController *theStoreViewController =
				[[RJStoreProductViewController alloc] init];
	theStoreViewController.delegate = self;
	NSDictionary *theParameters = [NSDictionary dictionaryWithObject:
				[NSNumber numberWithInteger:aniTunesID]
				forKey:SKStoreProductParameterITunesItemIdentifier];
	[self presentViewController:theStoreViewController
					animated:YES completion:nil];
	[theStoreViewController loadProductWithParameters:theParameters completionBlock:
	^(BOOL aResult, NSError *anError)
	{
		if (!aResult)
		{
			if ([self.delegate respondsToSelector:@selector(applicationWillTerminateFromWebBrowser:)])
			{
				[self.delegate applicationWillTerminateFromWebBrowser:self];
			}

            if ([self.delegate shouldOpenURL:aRequestURL]) {
                [[UIApplication sharedApplication] openURL:aRequestURL options:@{} completionHandler:nil];
            }
		}
  }];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)aViewController
{
	self.shouldNotifyClose = YES;
	[aViewController dismissViewControllerAnimated:NO completion:nil];
	[self dismissViewControllerAnimated:NO completion:nil];
}

@end
