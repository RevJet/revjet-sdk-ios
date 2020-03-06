//
//  RJSlotDelegate.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJSlot;

@protocol RJSlotDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;

@optional

- (void)didFailToLoadSlot:(RJSlot *)aSlot error:(NSError *)anError;

- (void)didReceiveAd:(UIView *)aView;
- (void)didFailToReceiveAd:(UIView *)aView error:(NSError *)anError;
- (void)willPresentModalViewFromAd:(UIView *)aView;
- (void)didDismissModalViewFromAd:(UIView *)aView;
- (void)applicationWillTerminateFromAd:(UIView *)aView;

- (void)didCloseAd:(UIView *)aView;
- (BOOL)shouldOpenURL:(NSURL*)url;

- (void)didReceiveInterstitialAd:(NSObject *)anAd;
- (void)didFailToReceiveInterstitialAd:(NSObject *)anAd error:(NSError *)anError;
- (void)willPresentInterstitialAd:(NSObject *)anAd;
- (void)didDismissInterstitialAd:(NSObject *)anAd;
- (void)applicationWillTerminateFromInterstitialAd:(NSObject *)anAd;

// Targeting

- (NSDictionary *)additionalInfo;
- (NSString *)areaCode;
- (NSString *)city;
- (NSString *)country;

//! "hasLocation" method should return <code>YES</code> if <code>latitude</code> and <code>longitude</code> return
//! actual values.
- (BOOL)hasLocation;
- (double)latitude;
- (double)longitude;

- (NSString *)metro;
- (NSString *)zip;
- (NSString *)region;
- (NSString *)gender;

@end
