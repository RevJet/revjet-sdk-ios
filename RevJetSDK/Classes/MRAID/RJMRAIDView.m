//
//  RJMRAIDView.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJGlobal.h"
#import "RJMRAIDView.h"
#import "RJMRAIDViewDelegate.h"
#import "RJMRAID.h"
#import "RJSlotView.h"

#import "RJUtilities.h"

#import "RJMRAIDExpandViewController.h"

static NSString *const kRJExpandAnimationId = @"RJSlotAdExpand";
static NSString *const kRJCloseAnimationId = @"RJSlotAdClose";

@interface RJMRAIDView()

- (UIWebView *)mraidWebViewWithFrame:(CGRect)aFrame;
- (void)deviceOrientationDidChange:(NSNotification *)notification;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) RJMRAIDExpandViewController *expandViewController;
@property (nonatomic, assign) UIInterfaceOrientationMask orientationMask;
@property (nonatomic, assign) BOOL isExpanded;

@end

@implementation RJMRAIDView
{
@private
  kRJMRAIDPlacementType placementType_;

  UIWebView __strong * webView_;
  UIWebView __strong * expandedWebView_;
  UIButton __strong * closeButton_;
  RJMRAID __strong * mraid_;
}

@synthesize delegate, containerView;
@synthesize placementType = placementType_;
@synthesize webView = webView_;
@synthesize expandedWebView = expandedWebView_;
@synthesize mraid = mraid_;

- (id)initWithFrame:(CGRect)aFrame
{
	RJLog(@"initWithFrame:");

	if ((self = [super initWithFrame:aFrame]))
	{
		mraid_ = [[RJMRAID alloc] initWithView:self];
		placementType_ = kRJMRAIDPlacementTypeInline;

		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];

		CGRect theContainerRect = CGRectMake(0, 0, aFrame.size.width, aFrame.size.height);
		self.containerView = [[UIView alloc] initWithFrame:theContainerRect];
		self.containerView.opaque = NO;
		self.containerView.backgroundColor = [UIColor clearColor];
		[self addSubview:self.containerView];

		webView_ = [self mraidWebViewWithFrame:theContainerRect];
		[self.containerView addSubview:webView_];

		closeButton_ = [RJUtilities closeButton];
		closeButton_.center = CGPointMake(self.frame.size.width - closeButton_.frame.size.width / 2,
					closeButton_.frame.size.height / 2);
		[closeButton_ addTarget:mraid_ action:@selector(closeButtonTouched)
					forControlEvents:UIControlEventTouchUpInside];
		self.orientationMask = UIInterfaceOrientationMaskAll;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:)
					name:UIDeviceOrientationDidChangeNotification object:nil];
	}

	return self;
}

- (id)initWithFrame:(CGRect)aFrame delegate:(id<RJMRAIDViewDelegate>)aDelegate
{
	RJLog(@"initWithFrame:delegate:");

	if ((self = [self initWithFrame:aFrame]))
	{
		self.delegate = aDelegate;
	}
	return self;
}

- (void)dealloc
{
	RJLog(@"dealloc");

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification
				object:nil];

	self.delegate = nil;
  
	[webView_ setDelegate:nil];
	[webView_ stopLoading];
	webView_ = nil;

	[expandedWebView_ setDelegate:nil];
	[expandedWebView_ stopLoading];
	expandedWebView_ = nil;

	[self.containerView removeFromSuperview];
	self.containerView = nil;

	closeButton_ = nil;
	
	if (self.isExpanded)
	{
		[self.expandViewController dismissViewControllerAnimated:NO completion:nil];
	}

	mraid_.mraidView = nil;
	mraid_ = nil;
}

- (void)loadHTML:(NSString *)anHTML
{
	RJLog(@"loadHTML:");
	NSString *theHTML = [mraid_ prepareHTML:anHTML];
	[webView_ loadHTMLString:theHTML baseURL:nil];
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)aScript
{
	if (expandedWebView_ == nil)
	{
		return [webView_ stringByEvaluatingJavaScriptFromString:aScript];
	}
	return [expandedWebView_ stringByEvaluatingJavaScriptFromString:aScript];
}

- (BOOL)isExpandedWebView
{
	return self.mraid.isExpandedWebView;
}

- (void)hiddenState
{
	[self.mraid hiddenState];
}

- (void)expandToSize:(CGSize)aSize withContent:(NSString *)aContent
{
	if ([mraid_ expanded])
	{
		return;
	}
	
	self.expandViewController = [[RJMRAIDExpandViewController alloc] initWithOrientationMask:self.orientationMask];
	self.containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self.expandViewController.view addSubview:self.containerView];
	self.expandViewController.containerView = self.containerView;
	
	self.webView.hidden = YES;
	[[self.delegate viewControllerForPresentingModalView] presentViewController:self.expandViewController
				animated:NO completion:^{
					
					if (nil == self.containerView)
					{
						dispatch_after(0, dispatch_get_main_queue(), ^
						{
							[self.expandViewController dismissViewControllerAnimated:NO completion:nil];
						});
						return;
					}
				
					CGSize theScreenSize = [RJGlobal screenSize];

					CGRect theExpandRect = CGRectMake(0, 0, aSize.width, aSize.height);
					
					if (theExpandRect.size.width <= 0)
					{
						theExpandRect.size.width = theScreenSize.width;
					}
					if (theExpandRect.size.height <= 0)
					{
						theExpandRect.size.height = theScreenSize.height;
					}

					if (theExpandRect.size.width > theScreenSize.width)
					{
						theExpandRect.size.width = theScreenSize.width;
					}

					if (theExpandRect.size.height > theScreenSize.height)
					{
						theExpandRect.size.height = theScreenSize.height;
					}

					CGRect theContainerRect = theExpandRect;
					if (theExpandRect.size.width > theScreenSize.width)
					{
						theContainerRect.origin.x = 0;
					}

					if (theExpandRect.size.height > theScreenSize.height)
					{
						theContainerRect.origin.y = 0;
					}
					
					if (!UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
					{
						theExpandRect.origin.y = [RJGlobal statusBarHeight];
					}

					// One-part creative
					if (aContent == nil)
					{
						[self.containerView setNeedsLayout];
						self.containerView.frame = theContainerRect;
						self->webView_.frame = theExpandRect;
						self.webView.hidden = NO;
					}
					else // Two-part creative
					{
						[self->webView_ removeFromSuperview];
						self.containerView.frame = theContainerRect;

						self->expandedWebView_ = [self mraidWebViewWithFrame:theExpandRect];
						self->expandedWebView_.tag = kRJExpandedWebViewTag;
						[self.containerView addSubview:self->expandedWebView_];

						NSString *theHTMLAd = [self->mraid_ prepareHTML:aContent];
						[self->expandedWebView_ loadHTMLString:theHTMLAd baseURL:nil];
					}
					
					[self->mraid_ expandedState];
					self.isExpanded = YES;
				}];

	if (!mraid_.useCustomClose)
	{
		[self showCloseButton];
	}
}

- (void)closeExpandedView
{
	RJLog(@"closeExpandedView");

	[self.expandViewController dismissViewControllerAnimated:NO completion:nil];
	self.expandViewController = nil;
	
	[self hideCloseButton];

	CGSize theSize = self.frame.size;

	// One-part creative
	if (expandedWebView_ == nil)
	{
		webView_.frame = CGRectMake(0, 0, theSize.width, theSize.height);
		self.containerView.frame = CGRectMake(0, 0, theSize.width, theSize.height);
		[self addSubview:self.containerView];
	}
	else
	{
		// Two-part creative
		expandedWebView_.delegate = nil;
		[expandedWebView_ stopLoading];
		[expandedWebView_ removeFromSuperview];
		expandedWebView_ = nil;

		self.containerView.frame = CGRectMake(0, 0, theSize.width, theSize.height);
		[self addSubview:self.containerView];
		[self.containerView addSubview:webView_];
	}

	[mraid_ defaultState];
	self.isExpanded = NO;

	if ([self.delegate respondsToSelector:@selector(didClose)])
	{
		[self.delegate didClose];
	}
}

- (void)showCloseButton
{
	CGRect theFrame = closeButton_.frame;
	theFrame.origin.x = self.expandViewController.view.frame.size.width - theFrame.size.width;
	closeButton_.frame = theFrame;

	[self.expandViewController.view addSubview:closeButton_];
	[self.expandViewController.view bringSubviewToFront:closeButton_];
}

- (void)hideCloseButton
{
	[closeButton_ removeFromSuperview];
}

- (void)lockOrientation:(BOOL)lockOrientation force:(NSNumber *)aForceOrientationMask
{
	if (nil != aForceOrientationMask)
	{
		self.orientationMask = [aForceOrientationMask integerValue];
	}
	else
	{
		if (lockOrientation)
		{
			UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
			if (UIInterfaceOrientationIsLandscape(currentOrientation))
			{
				self.orientationMask = UIInterfaceOrientationMaskLandscape;
			}
			else if (currentOrientation == UIInterfaceOrientationPortrait)
			{
				self.orientationMask = UIInterfaceOrientationMaskPortrait;
			}
			else if (currentOrientation == UIInterfaceOrientationPortraitUpsideDown)
			{
				self.orientationMask = UIInterfaceOrientationMaskPortraitUpsideDown;
			}
		}
		else
		{
			self.orientationMask = UIInterfaceOrientationMaskAll;
		}
	}
	
	if (nil != self.expandViewController)
	{
		[self.expandViewController dismissViewControllerAnimated:NO completion:^
		{
			self.expandViewController = [[RJMRAIDExpandViewController alloc]
						initWithOrientationMask:self.orientationMask];
			[self.expandViewController.view addSubview:self.containerView];
			[[self.delegate viewControllerForPresentingModalView]
						presentViewController:self.expandViewController animated:NO completion:nil];
		}];
	}
}

#pragma mark - Notifications

- (void)deviceOrientationDidChange:(NSNotification *)aNotification
{
	if ([mraid_ expanded])
	{
		return;
	}
	
	[mraid_ notifyScreenSizeChanged];
}

#pragma mark - Private methods

- (UIWebView *)mraidWebViewWithFrame:(CGRect)aFrame
{
	UIWebView *theWebView = [[UIWebView alloc] initWithFrame:aFrame];
	theWebView.backgroundColor = [UIColor clearColor];
	theWebView.opaque = NO;
	theWebView.clipsToBounds = YES;

	if ([theWebView respondsToSelector:@selector(setAllowsInlineMediaPlayback:)])
	{
		[theWebView setAllowsInlineMediaPlayback:YES];
	}

	if ([theWebView respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)])
	{
		[theWebView setMediaPlaybackRequiresUserAction:NO];
	}

	[RJGlobal disableScrollingAndDraggingForView:theWebView];

	theWebView.delegate = mraid_;

	return theWebView;
}

@end
