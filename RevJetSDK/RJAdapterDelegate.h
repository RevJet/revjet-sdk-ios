//
//  RJAdapterDelegate.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJBaseAdapter;

@protocol RJAdapterDelegate <NSObject>

- (NSNumber *)showCloseButton;
- (CGRect)slotViewFrame;
- (UIViewController *)viewControllerForPresentingModalView;
- (void)trackClickForAdapter:(RJBaseAdapter *)anAdapter;
- (BOOL)runCustomFunction:(NSString *)aFunction withObject:(id)anObject;
- (void)runDeallocCustomFunction:(NSString *)aFunction withObject:(id)anObject;

- (BOOL)adapter:(RJBaseAdapter *)adapter shouldOpenURL:(NSURL*)url;

#pragma mark - Normal ads

- (void)adapter:(RJBaseAdapter *)adapter didShowAd:(UIView *)aView;
- (void)adapter:(RJBaseAdapter *)adapter didReceiveAd:(UIView *)aView;
- (void)adapter:(RJBaseAdapter *)adapter didFailToReceiveAd:(UIView *)aView error:(NSError *)anError;
- (void)adapter:(RJBaseAdapter *)adapter willPresentModalViewFromAd:(UIView *)aView;
- (void)adapter:(RJBaseAdapter *)adapter didDismissModalViewFromAd:(UIView *)aView;
- (void)adapter:(RJBaseAdapter *)adapter applicationWillTerminateFromAd:(UIView *)aView;

- (void)adapter:(RJBaseAdapter *)adapter didCloseAd:(UIView *)aView;

#pragma mark - Interstitial ads

- (void)adapter:(RJBaseAdapter *)adapter didShowInterstitialAd:(NSObject *)anInterstitialAd;
- (void)adapter:(RJBaseAdapter *)adapter didReceiveInterstitialAd:(NSObject *)anInterstitialAd;
- (void)adapter:(RJBaseAdapter *)adapter didFailToReceiveInterstitialAd:(NSObject *)ad error:(NSError *)anError;
- (void)adapter:(RJBaseAdapter *)adapter willPresentInterstitialAd:(NSObject *)anInterstitialAd;
- (void)adapter:(RJBaseAdapter *)adapter didDismissInterstitialAd:(NSObject *)anInterstitialAd;
- (void)adapter:(RJBaseAdapter *)adapter applicationWillTerminateFromInterstitialAd:(NSObject *)anInterstitialAd;

#pragma mark - Targeting

- (NSString *)areaCode;
- (NSString *)city;
- (NSString *)country;
- (BOOL)hasLocation;
- (double)latitude;
- (double)longitude;
- (NSString *)metro;
- (NSString *)zip;
- (NSString *)region;
- (NSString *)gender;

@end
