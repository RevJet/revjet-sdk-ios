//
//  RJMRAIDExpandViewController.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJMRAIDExpandViewController : UIViewController

- (id)initWithOrientationMask:(UIInterfaceOrientationMask)anOrientationMask;

@property (nonatomic, assign) UIInterfaceOrientationMask orientationMask;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIWebView *expandedWebView;
@property (nonatomic, assign) CGSize expandedSize;
@property (nonatomic, assign) NSString *content;

@end
