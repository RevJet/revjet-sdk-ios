//
//  RJStoreProductViewController.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJStoreProductViewController.h"

#import "RJStatusBarVisibility.h"

@interface RJStoreProductViewController ()

@property (nonatomic, strong) RJStatusBarVisibility *statusBarVisibility;

@end

@implementation RJStoreProductViewController

@synthesize adapter, statusBarVisibility;

// iOS 7
- (BOOL)prefersStatusBarHidden
{
	return [self.statusBarVisibility shouldHideStatusBar];
}

#pragma mark -

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.statusBarVisibility = [[RJStatusBarVisibility alloc] init];
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

@end
