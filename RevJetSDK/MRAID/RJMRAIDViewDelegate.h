//
//  RJMRAIDViewDelegate.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJMRAIDView;

@protocol RJMRAIDViewDelegate <NSObject>
@required
- (UIViewController *)viewControllerForPresentingModalView;
- (BOOL)shouldOpenURL:(NSURL*)url;
@optional
- (void)didReceiveAd:(RJMRAIDView *)view;
- (void)didFailToReceiveAd:(RJMRAIDView *)view withError:(NSError *)error;
- (void)applicationWillTerminateFromAd:(RJMRAIDView *)view;

- (void)willExpand;
- (void)didClose;
- (void)willOpenInternalBrowser;
- (void)didCloseInternalBrowser;

- (void)willRequestAccess;
- (void)didRequestAccess;

- (void)openInternalBrowser:(NSString *)url;
@end
