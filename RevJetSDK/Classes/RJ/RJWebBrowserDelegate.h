//
//  RJWebBrowserDelegate.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJWebBrowser;

@protocol RJWebBrowserDelegate <NSObject>
@required
- (UIViewController *)viewControllerForPresentingModalView;
- (BOOL)shouldOpenURL:(NSURL*)url;
@optional
- (void)didDismissWebBrowser:(RJWebBrowser *)webBrowser;
- (void)applicationWillTerminateFromWebBrowser:(RJWebBrowser *)webBrowser;
@end
