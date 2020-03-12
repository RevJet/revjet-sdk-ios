//
//  RJInterstitialControllerDelegate.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJBaseInterstitialController;

@protocol RJInterstitialControllerDelegate <NSObject>

@required
- (UIViewController *)viewControllerForPresentingModalView;
- (BOOL)shouldOpenURL:(NSURL*)url;

@optional
- (void)didShowInterstitialAd:(RJBaseInterstitialController *)aController;
- (void)didDismissInterstitialController:(RJBaseInterstitialController *)aController;
- (void)applicationWillTerminateFromInterstitialController:(RJBaseInterstitialController *)aController;

@end
