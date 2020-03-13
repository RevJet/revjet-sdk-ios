//
//  RJMRAIDExpandViewController.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDExpandViewController.h"

#import "RJGlobal.h"

@interface RJMRAIDExpandViewController ()

@property (nonatomic, assign) BOOL wasStatusBarHidden;

@end

@implementation RJMRAIDExpandViewController

- (id)initWithOrientationMask:(UIInterfaceOrientationMask)anOrientationMask
{
	self = [super init];
	if (nil != self)
	{
		_orientationMask = anOrientationMask;
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.wasStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
				self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
	{
		self.containerView.center = CGPointMake(self.view.frame.size.width / 2.0f,
					self.view.frame.size.height / 2.0f);
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	if (!self.wasStatusBarHidden)
	{
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		// iOS 7
		if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
		{
			[self setNeedsStatusBarAppearanceUpdate];
		}
	}
}

// iOS 7
- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void)setOrientationMask:(UIInterfaceOrientationMask)anOrientationMask
{
	_orientationMask = anOrientationMask;
	[UIViewController attemptRotationToDeviceOrientation];
}

#pragma mark -

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return self.orientationMask;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)anInterfaceOrientation
{
	return (anInterfaceOrientation << self.orientationMask);
}

@end
