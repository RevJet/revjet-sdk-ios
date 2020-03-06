//
//  RJMRAID.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJWebBrowserDelegate.h"

@class RJMRAIDView;

@interface RJMRAID : NSObject<UIWebViewDelegate, RJWebBrowserDelegate>

@property(nonatomic, readonly) BOOL useCustomClose;
@property(nonatomic, unsafe_unretained) RJMRAIDView * mraidView;

- (id)initWithView:(RJMRAIDView *)aView;
- (NSString *)prepareHTML:(NSString *)aHTML;

- (BOOL)isExpandedWebView;
- (void)expandedState;
- (void)defaultState;
- (void)hiddenState;
- (void)notifyScreenSizeChanged;
- (void)setViewable:(BOOL)aFlag;
- (void)reportError:(NSString *)aMessage action:(NSString *)anAction;

- (void)closeButtonTouched;

- (BOOL)expanded;

@end
