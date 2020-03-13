//
//  RJVASTInterstitialController.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJVASTInterstitialController.h"

#import "RJGlobal.h"
#import "RJUtilities.h"
#import "RJUIImage.h"

#import "RJVASTAdRepresentation.h"
#import "RJVASTCompanionAdRepresentation.h"
#import "RJInterstitialControllerDelegate.h"

#import "RJVASTToolbarView.h"
#import "RJVASTToolbarViewCloseButton.h"
#import "RJVASTToolbarViewLearnMoreButton.h"

#import "RJPixelsQueue.h"

#import "RJWebBrowser.h"
#import "RJWebBrowserDelegate.h"

#import <MediaPlayer/MediaPlayer.h>

static NSTimeInterval const kRJVideoProgressTimeInterval = 0.05f;

static NSTimeInterval const kRJFirstQuartilePercentage = 0.25f;
static NSTimeInterval const kRJMidpointPercentage = 0.5f;
static NSTimeInterval const kRJThirdQuartilePercentage = 0.75f;

static NSTimeInterval const kRJShowCloseButtonDelayDefault = 5.0f;
static NSTimeInterval const kRJShowCloseButtonDelayMax = 16.0f;

@interface RJVASTInterstitialController () <RJWebBrowserDelegate>

@property (nonatomic, strong) RJVASTAdRepresentation *adRepresentation;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, strong) UIImageView *companionAdImageView;
@property (nonatomic, strong) RJVASTToolbarView *toolbarView;

@property (nonatomic, assign) BOOL shouldCheckVideoProgress;
@property (nonatomic, assign) NSTimer *videoProgressTimer;

@property (nonatomic, assign) BOOL startEventTracked;
@property (nonatomic, assign) BOOL firstQuartileEventTracked;
@property (nonatomic, assign) BOOL midpointEventTracked;
@property (nonatomic, assign) BOOL thirdQuartileEventTracked;

@property (nonatomic, assign) NSTimeInterval showCloseButtonDelay;

@property (nonatomic, assign) BOOL isInteractable;
@property (nonatomic, assign) BOOL shouldPlayVideo;

@property (nonatomic, assign) NSTimeInterval currentPlaybackTime;

@end

@implementation RJVASTInterstitialController

- (id)initWithDelegate:(id<RJInterstitialControllerDelegate>)aDelegate
			adRepresentation:(RJVASTAdRepresentation *)aRepresentation
{
	if (nil == aRepresentation)
	{
		return nil;
	}
	
	CGRect theScreenRect = [RJGlobal screenBoundsFixedToPortraitOrientation];
	// always in landscape
	CGSize theScreenSize = CGSizeMake(theScreenRect.size.width, theScreenRect.size.height);
	if ([RJUtilities isLandscapeSupported])
	{
		theScreenSize = CGSizeMake(theScreenSize.height, theScreenSize.width);
	}
	
	self = [super initWithDelegate:aDelegate html:nil showCloseButton:NO adSize:theScreenSize];
	if (nil != self)
	{
		self.adRepresentation = aRepresentation;
	}
	return self;
}

- (id)init
{
	return [self initWithDelegate:nil adRepresentation:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (self.shouldPlayVideo)
	{
		[self startTracking];
		[[NSNotificationCenter defaultCenter] addObserver:self
					selector:@selector(moviePlayerControllerDidFinish:)
					name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];
		[self.moviePlayerController play];
		
		[[RJPixelsQueue defaultQueue] addStringPixelsToQueue:self.adRepresentation.impressions];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
				name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];
	[self.moviePlayerController stop];
	[self stopTracking];
}

#pragma mark -

- (void)loadAd
{
	self.showCloseButtonDelay = kRJShowCloseButtonDelayDefault;
	self.shouldPlayVideo = YES;
	
	self.companionAdImageView = [[UIImageView alloc] initWithFrame:
				CGRectMake(0.0f, 0.0f, self.adSize.width, self.adSize.height)];
	self.companionAdImageView.contentMode = UIViewContentModeScaleAspectFit;
	self.companionAdImageView.backgroundColor = [UIColor blackColor];
	self.companionAdImageView.userInteractionEnabled = YES;
	[self.view addSubview:self.companionAdImageView];
	
	UIImage *theCompanionAdImage = nil;
	if (self.adRepresentation.companionAdPath.length > 0)
	{
		NSURL *theFilePathURL = [NSURL fileURLWithPath:self.adRepresentation.companionAdPath];
		if (nil != theFilePathURL)
		{
			theCompanionAdImage = [RJUIImage animatedImageWithAnimatedGIFURL:theFilePathURL];
		}
	}
	if (nil != theCompanionAdImage)
	{
		self.companionAdImageView.image = theCompanionAdImage;
	}
	self.companionAdImageView.hidden = YES;
	
	self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:
				[NSURL fileURLWithPath:self.adRepresentation.mediaFilePath]];
	self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
	self.moviePlayerController.view.frame = CGRectMake(0.0f, 0.0f, self.adSize.width, self.adSize.height);
	
	[self.view addSubview:self.moviePlayerController.view];
	UIView *theVideoClickOverlay = [[UIView alloc] initWithFrame:CGRectMake(
				0.0f, 40.0f, self.adSize.width, self.adSize.height)];
	theVideoClickOverlay.backgroundColor = [UIColor clearColor];
	theVideoClickOverlay.userInteractionEnabled = YES;
	[self.moviePlayerController.view addSubview:theVideoClickOverlay];
	[theVideoClickOverlay addGestureRecognizer:[[UITapGestureRecognizer alloc]
				initWithTarget:self action:@selector(moviePlayerControllerDidClick:)]];
	
	self.toolbarView = [[RJVASTToolbarView alloc] initWithFrame:CGRectMake(
				0, 0, self.adSize.width, 40.0f)];
	[self.toolbarView initializeElements];
	[self.view addSubview:self.toolbarView];
	[self.toolbarView.closeButton addTarget:self action:@selector(didClickCloseButton:)
				forControlEvents:UIControlEventTouchUpInside];
	[self.toolbarView.learnMoreButton addTarget:self action:@selector(didClickLearnMoreButton:)
				forControlEvents:UIControlEventTouchUpInside];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
				name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
				name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Private

- (void)startTracking
{
	if (!self.shouldCheckVideoProgress)
	{
		self.shouldCheckVideoProgress = YES;
		self.videoProgressTimer = [NSTimer scheduledTimerWithTimeInterval:kRJVideoProgressTimeInterval
					target:self selector:@selector(checkVideoProgressTimer:) userInfo:nil repeats:YES];
	}
}

- (void)stopTracking
{
	if (self.shouldCheckVideoProgress)
	{
		self.shouldCheckVideoProgress = NO;
		[self.videoProgressTimer invalidate];
		self.videoProgressTimer = nil;
	}
}

- (void)makeVideoInteractable
{
	self.isInteractable = YES;
	[self.toolbarView makeInteractable];
}

- (void)checkVideoProgressTimer:(NSTimer *)aTimer
{
	NSTimeInterval theDuration = self.moviePlayerController.duration;
	NSTimeInterval thePosition = self.moviePlayerController.currentPlaybackTime;
	if (theDuration > 0)
	{
		if (self.moviePlayerController.duration < kRJShowCloseButtonDelayMax)
		{
			self.showCloseButtonDelay = theDuration;
		}
	
		float thePercentage = thePosition / theDuration;
		if (!self.startEventTracked && thePosition > 1.0f)
		{
			self.startEventTracked = YES;
			[[RJPixelsQueue defaultQueue] addStringPixelsToQueue:
						self.adRepresentation.startTrackingEvents];
		}
		if (!self.firstQuartileEventTracked && thePercentage > kRJFirstQuartilePercentage)
		{
			self.firstQuartileEventTracked = YES;
			[[RJPixelsQueue defaultQueue] addStringPixelsToQueue:
						self.adRepresentation.firstQuartileTrackingEvents];
		}
		if (!self.midpointEventTracked && thePercentage > kRJMidpointPercentage)
		{
			self.midpointEventTracked = YES;
			[[RJPixelsQueue defaultQueue] addStringPixelsToQueue:
						self.adRepresentation.midpointTrackingEvents];
		}
		if (!self.thirdQuartileEventTracked && thePercentage > kRJThirdQuartilePercentage)
		{
			self.thirdQuartileEventTracked = YES;
			[[RJPixelsQueue defaultQueue] addStringPixelsToQueue:
						self.adRepresentation.thirdQuartileTrackingEvents];
		}
		
		if (theDuration >= kRJShowCloseButtonDelayMax)
		{
			[self.toolbarView updateCountdownElement:self.showCloseButtonDelay - thePosition];
		}
		
		if (!self.isInteractable && thePosition > self.showCloseButtonDelay)
		{
			[self makeVideoInteractable];
		}
	}
	
	[self.toolbarView updateDuration:(theDuration - thePosition)];
}

#pragma mrak - Notifications

- (void)moviePlayerControllerDidFinish:(NSNotification *)aNotification
{
	self.shouldPlayVideo = NO;
	[[RJPixelsQueue defaultQueue] addStringPixelsToQueue:
				self.adRepresentation.completeTrackingEvents];
	
	[self stopTracking];
	
	[self makeVideoInteractable];
	[self.moviePlayerController.view removeFromSuperview];
	
	self.companionAdImageView.hidden = NO;
	[self.companionAdImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
				initWithTarget:self action:@selector(companionAdImageViewDidClick:)]];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
				name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
				name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
				name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)companionAdImageViewDidClick:(UIGestureRecognizer *)aGestureRecognizer
{
	[self processClickTrough:self.adRepresentation.bestCompanionAd.clickThroughURL
				trackingEvents:self.adRepresentation.bestCompanionAd.clickTrackers];
}

- (void)moviePlayerControllerDidClick:(UIGestureRecognizer *)aGestureRecognizer
{
	[self processMovieClick];
}

- (void)didClickCloseButton:(UIButton *)aButton
{
	[self dismissViewControllerAnimated:YES completion:^
	{
		[self.delegate didDismissInterstitialController:self];
	}];
}

- (void)didClickLearnMoreButton:(UIButton *)aButton
{
	[self processMovieClick];
}

- (void)processMovieClick
{
	[self processClickTrough:self.adRepresentation.clickThrough
				trackingEvents:self.adRepresentation.clickTrackingEvents];
}

- (void)processClickTrough:(NSString *)aClickThrough trackingEvents:(NSArray *)aTrackingEvents
{
	if (self.isInteractable)
	{
		[[RJPixelsQueue defaultQueue] addStringPixelsToQueue:aTrackingEvents];
		
		if (nil != aClickThrough)
		{
			self.shouldPlayVideo = NO;
			RJWebBrowser *theBrowser = [RJWebBrowser RJWebBrowserWithDelegate:self
																		  URL:[NSURL URLWithString:aClickThrough]];
			[self presentViewController:theBrowser animated:YES completion:nil];
		}
	}
}

#pragma mark - Notifications

- (void)applicationWillResignActive:(UIApplication *)anApplication
{
	[self stopTracking];
	[self.moviePlayerController pause];
	self.currentPlaybackTime =  self.moviePlayerController.currentPlaybackTime;
}

- (void)applicationDidBecomeActive:(UIApplication *)anApplication
{
	if (self.shouldPlayVideo)
	{
		[self startTracking];
		self.moviePlayerController.currentPlaybackTime = self.currentPlaybackTime;
		[self.moviePlayerController play];
	}
}


#pragma mark - RJWebBrowserDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
	return [self.delegate viewControllerForPresentingModalView];
}

- (void)didDismissWebBrowser:(RJWebBrowser *)aWebBrowser
{
	[self dismissViewControllerAnimated:YES completion:^
	{
		[self.delegate didDismissInterstitialController:self];
	}];
}

- (void)applicationWillTerminateFromWebBrowser:(RJWebBrowser *)aWebBrowser
{
	[self.delegate applicationWillTerminateFromInterstitialController:self];
}

- (BOOL)shouldOpenURL:(NSURL*)url
{
	return [self.delegate shouldOpenURL:url];
}

@end
