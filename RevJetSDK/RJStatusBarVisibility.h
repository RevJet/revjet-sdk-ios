//
//  RJStatusBarVisibility.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Incapsulates status bar visibility behavior. Create an instance of this class per view controller.
@interface RJStatusBarVisibility : NSObject

//! Use this methods for controlling status bar visibility on iOS 6 version and lover.
- (void)hideStatusBar;
- (void)showStatusBar;

//! This method mainly should be used for iOS 7 and higher.
- (BOOL)shouldHideStatusBar;

@end
