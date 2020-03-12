//
//  DemoViewController.m
//  RevJetSimpleDemoApp
//
//  Copyright © 2020 RevJet. All rights reserved.
//

#import "DemoViewController.h"

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidAppear:(BOOL)anAnimated
{
    [super viewDidAppear:anAnimated];

    CGSize theSize = CGSizeMake(320.0f, 64.0f);
    NSString *tagUrl = @"https://cdn.revjet.com/~cdn/Ads/ad_shared/test/thd/tag-function.html";

    self.slot = [[RJSlot alloc] initWithDelegate:self tagUrl:tagUrl
                frame:CGRectMake(0.0f, 0.0f, theSize.width, theSize.height)];
    
    [self.slot addToView:self.view];
    [self.slot fetchAd];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - RJSlotDelegate

- (BOOL)shouldOpenURL:(NSURL*)url
{
    return YES;
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)didFailToLoadSlot:(RJSlot *)aSlot error:(NSError *)anError
{
}

- (void)didReceiveAd:(UIView *)aView
{
    // Here the ad is ready to be shown.
    // You can fire LOAD pixels, show the ad, etc.
    [self.slot showAd];
}

- (void)didShowAd:(UIView *)aView
{
    // Here the ad is fully shown.
    // You can fire VIEW pixels, etc.
}

- (void)didFailToReceiveAd:(UIView *)aView error:(NSError *)anError
{
}

- (void)willPresentModalViewFromAd:(UIView *)aView
{
}

- (void)didDismissModalViewFromAd:(UIView *)aView
{
}

- (void)applicationWillTerminateFromAd:(UIView *)aView
{
}

- (void)didCloseAd:(UIView *)aView
{
}

// Interstitial

- (void)didShowInterstitialAd:(NSObject *)anAd
{
    // Here the interstitial ad is fully shown.
    // You can fire VIEW pixels, etc.
}

- (void)didReceiveInterstitialAd:(NSObject *)anAd
{
}

- (void)didFailToReceiveInterstitialAd:(NSObject *)anAd error:(NSError *)anError
{
}

- (void)willPresentInterstitialAd:(NSObject *)anAd
{
}

- (void)didDismissInterstitialAd:(NSObject *)anAd
{
}

- (void)applicationWillTerminateFromInterstitialAd:(NSObject *)anAd
{
}

// Additional information
- (NSDictionary *)additionalInfo {
    return @{
            @"storeId": @"12345"
    };
}

- (NSString *)areaCode
{
    return @"925";
}

- (NSString *)city
{
    return @"Walnut Creek";
}

- (NSString *)country
{
    return @"US";
}

- (BOOL)hasLocation
{
    return YES;
}

- (double)latitude
{
    return 37.9136962890625;
}

- (double)longitude
{
    return -122.01170349121094;
}

- (NSString *)metro
{
    return @"807";
}

- (NSString *)zip
{
    return @"94598";
}

- (NSString *)region
{
    return @"CA";
}

- (NSString *)gender
{
    return @"m";
}

@end
