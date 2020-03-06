//
//  RJSlotView.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJGlobal.h"
#import "RJSlotView.h"
#import "RJSlotViewDelegate.h"

static NSString *const kRJTransitionAnimationId = @"RJSlotAdTransition";

static NSString *const kRJTransitionAnimationNone = @"NONE";
static NSString *const kRJTransitionAnimationRandom = @"RANDOM";
static NSString *const kRJTransitionAnimationFlipFromLeft = @"FLIPFROMLEFT";
static NSString *const kRJTransitionAnimationFlipFromRight = @"FLIPFROMRIGHT";
static NSString *const kRJTransitionAnimationCurlUp = @"CURLUP";
static NSString *const kRJTransitionAnimationCurlDown = @"CURLDOWN";

NSString *const kRJDefaultTransitionAnimation = @"NONE";

static NSTimeInterval const kRJTransitionToViewAnimationDuration = 1.0f;

@interface RJSlotView()

+ (NSDictionary *)animationTransitionTypesMap;

@property (nonatomic, unsafe_unretained) UIView *adView;
@property (nonatomic, strong) NSArray *animationTypes;
@property (nonatomic, strong) UIView *containerView;

- (void)animationDidStop:(NSString *)anAnimationID finished:(NSNumber *)isFinished
			context:(void *)aContext;
@end

@implementation RJSlotView

@synthesize delegate, adView, animationTypes, containerView, integrationType, isSlotViewVisible;

- (id)initWithDelegate:(id<RJSlotViewDelegate>)aDelegate frame:(CGRect)aRect
{
	if ((self = [super initWithFrame:aRect]))
	{
		self.integrationType = kRJIntegrationRevJetSDKDirect;

		self.delegate = aDelegate;
		self.animationTypes = @[kRJTransitionAnimationNone, kRJTransitionAnimationFlipFromLeft,
				kRJTransitionAnimationFlipFromRight, kRJTransitionAnimationCurlUp, kRJTransitionAnimationCurlDown];
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.clipsToBounds = YES;
	}
  return self;
}

- (void)dealloc
{
	RJLog(@"dealloc");
	self.containerView = nil;
	self.delegate = nil;
}

#pragma mark -

- (void)willMoveToWindow:(UIWindow *)aNewWindow
{
	[super willMoveToWindow:aNewWindow];
	self.isSlotViewVisible = (nil != aNewWindow);
}

#pragma mark -

- (void)transitionToView:(UIView *)aView animation:(NSString *)anAnimationType
{
	if (self.adView == aView)
	{
		[self.delegate slotView:self didShowAd:aView];
		return;
	}
	UIView *theOldAdView = self.adView;
	self.adView = aView;

	CGRect theFrame = self.frame;
	theFrame.origin = CGPointZero;
	
	if (nil != self.containerView)
	{
		[self.containerView removeFromSuperview];
		self.containerView = nil;
	}
	self.containerView = [[UIView alloc] initWithFrame:theFrame];
	self.containerView.backgroundColor = [UIColor clearColor];
	self.containerView.opaque = NO;
	self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Center new view horizontally
	theFrame = aView.frame;
	theFrame.origin.x = (self.containerView.frame.size.width - theFrame.size.width) / 2;
	aView.frame = theFrame;
	[self.containerView addSubview:aView];

	// First Ad - display without transition animation
	if ((nil == theOldAdView) || theOldAdView.isHidden)
	{
		[theOldAdView removeFromSuperview];
		[self addSubview:self.containerView];
		[self.delegate slotView:self didShowAd:aView];
		return;
	}
	
	if (nil == anAnimationType)
	{
		anAnimationType = kRJTransitionAnimationNone;
	}

	if ([kRJTransitionAnimationRandom isEqualToString:anAnimationType])
	{
		NSUInteger theRandomAnimationTypeIndex = arc4random() % [self.animationTypes count];
		anAnimationType = self.animationTypes[theRandomAnimationTypeIndex];
	}

	if ([kRJTransitionAnimationNone isEqualToString:anAnimationType])
	{
		[theOldAdView removeFromSuperview];
		[self addSubview:self.containerView];
		[self.delegate slotView:self didShowAd:aView];
		return;
	}

	[UIView beginAnimations:kRJTransitionAnimationId context:(__bridge void *)(aView)];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:kRJTransitionToViewAnimationDuration];
	
	UIViewAnimationTransition theTransitionType = UIViewAnimationTransitionNone;
	NSNumber *theAnimationTransitionType = [RJSlotView animationTransitionTypesMap][anAnimationType];
	if (theAnimationTransitionType != nil)
	{
		theTransitionType = [theAnimationTransitionType integerValue];
	}
	[UIView setAnimationTransition:theTransitionType forView:self cache:NO];
	
	[theOldAdView removeFromSuperview];
	[self addSubview:self.containerView];

	[UIView commitAnimations];
}

- (void)removeAdView
{
	[self.adView removeFromSuperview];
	self.adView = nil;
}

#pragma mark - Private

+ (NSDictionary *)animationTransitionTypesMap
{
	static NSDictionary *sAnimationTransitionTypeMap = nil;
	if (nil == sAnimationTransitionTypeMap)
	{
		sAnimationTransitionTypeMap = [[NSDictionary alloc] initWithObjectsAndKeys:
				[NSNumber numberWithInteger:UIViewAnimationTransitionFlipFromLeft], kRJTransitionAnimationFlipFromLeft,
				[NSNumber numberWithInteger:UIViewAnimationTransitionFlipFromRight], kRJTransitionAnimationFlipFromRight,
				[NSNumber numberWithInteger:UIViewAnimationTransitionCurlUp], kRJTransitionAnimationCurlUp,
				[NSNumber numberWithInteger:UIViewAnimationTransitionCurlDown], kRJTransitionAnimationCurlDown, nil];
	}
	
	return sAnimationTransitionTypeMap;
}

#pragma mark - UIViewAnimationDelegate

- (void)animationDidStop:(NSString *)anAnimationID finished:(NSNumber *)isFinished
			context:(void *)aContext
{
	if ([anAnimationID isEqualToString:kRJTransitionAnimationId])
	{
		UIView *theAdView = (__bridge UIView *)aContext;
		[self.delegate slotView:self didShowAd:theAdView];
	}
}

@end
