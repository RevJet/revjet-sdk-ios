//
//  RJStatusBarVisibility.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJStatusBarVisibility.h"

@interface RJStatusBarVisibility ()

@property (nonatomic, assign) BOOL isStatusBarHidden;

@end

@implementation RJStatusBarVisibility

@synthesize isStatusBarHidden;

- (void)hideStatusBar
{
	self.isStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
	if (!self.isStatusBarHidden)
	{
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
	}
}

- (void)showStatusBar
{
	if (!self.isStatusBarHidden)
	{
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
	}
}

- (BOOL)shouldHideStatusBar
{
	return YES;
}

@end
